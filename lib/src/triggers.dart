// Reactions: what a node (or a screen) does when something happens to it.
// A reaction is a trigger and the chain of actions it runs, in order
// (actions.dart). Pure data; the SDK's runtime wires the triggers and runs
// the actions (DESIGN.md §5.2).
import 'package:meta/meta.dart';

import 'actions.dart';
import 'json.dart';
import 'values/paint.dart' show listEquals;

/// What starts a reaction.
enum TriggerType {
  /// A tap (a click with a mouse). `${result}` holds where it landed (`x`,
  /// `y` in the node, `globalX`, `globalY`) and the modifier keys held
  /// (`meta`, `shift`, `alt`).
  click,

  /// Two taps in quick succession. A node with double tap reactions waits
  /// out the double tap timeout before its single taps run.
  doubleTap,

  /// A long press.
  longPress,

  /// A press held for [Trigger.holdMs]; letting go early cancels it.
  hold,

  /// A right click, or a two-finger tap on a trackpad (`${result.x}`,
  /// `${result.y}`: where, on screen).
  secondaryClick,

  /// A pointer went down on the node.
  pointerDown,

  /// A pointer went up (or was cancelled) on the node.
  pointerUp,

  /// The mouse cursor moved over the node (fires when it enters, too).
  hover,

  /// The mouse cursor entered the node (once).
  cursorEnter,

  /// The mouse cursor left the node (once).
  cursorExit,

  /// A swipe (a fling) to the left, right, up or down.
  swipeLeft,
  swipeRight,
  swipeUp,
  swipeDown,

  /// The node is dragged (every move); [dragEnd] when it's let go.
  drag,
  dragEnd,

  /// Wheel or trackpad scroll over the node; a pinch on it.
  wheel,
  pinch,

  /// An input's value changed (typed text, a toggled checkbox, a slider
  /// step, a picked item). `${result}` is the new value (a text field's:
  /// its text, word and selection).
  changed,

  /// A slider was let go, with its final value.
  changeEnd,

  /// A text field was submitted from the keyboard.
  submitted,

  /// A text field lost focus after editing.
  editingComplete,

  /// A text field gained or lost focus.
  focusGained,
  focusLost,

  /// A screen appeared (set on its canvas).
  load,

  /// On a screen (its canvas): the user tried to leave it (the system or
  /// browser back button, a back gesture, Escape on a dialog) while the
  /// canvas's `blockBack` holds (`props.blockBack`, usually bound:
  /// `${= dirty}`). The screen stays and these actions run instead, e.g. a
  /// "Discard changes?" confirm that leaves with a navigate pop, which the
  /// block doesn't stop. While `blockBack` is false, back leaves as usual
  /// and this doesn't fire.
  backPressed,

  /// Variable [Trigger.variable] changed while the screen shows.
  valueChanged,

  /// Every [Trigger.intervalMs] while the screen shows.
  timer,

  /// A steady audio clock: ticks every [Trigger.every] ms while
  /// [Trigger.runWhen] holds (`${result.tick}`, `${result.at}`,
  /// `${result.waitMs}`).
  clock,

  /// A key went down (or up) while the screen shows; [Trigger.key] limits
  /// it to one key or combination, [Trigger.when] to while a formula holds.
  /// `${result.key}`, `${result.shift}`, `${result.alt}`, `${result.meta}`.
  keyDown,
  keyUp,

  /// The node (a scrolling row, column or canvas) scrolled
  /// (`${result.offset}`, `${result.max}`, `${result.fraction}`), or came
  /// near its end (load the next page).
  scroll,
  scrollEnd,

  /// At least [Trigger.visibleFraction] of the node became visible, or it
  /// fell below that after being visible.
  enterViewport,
  exitViewport,

  /// Drag and drop: on a draggable (start, cancel, completed) and on a drop
  /// target (drop, enter, exit, hover, rejected; full: [dropFull]).
  /// `${result}` and `${drag}` hold the drag.
  dragStart,
  dragCancel,
  dragCompleted,
  drop,
  dragEnter,
  dragExit,
  dragHover,
  dropRejected,

  /// On a drop target that is full (its `fullIf` holds) when a drag of a
  /// group it accepts is let go on it: the drag springs back and these
  /// run, reading the drop as [drop] does; `${drag.full}` is true.
  dropFull,

  /// A data list row was dragged to a new place by this node, its reorder
  /// handle (`${result.from}`, `${result.to}`). A list with a `reorder`
  /// fires it too, with `${result.item}`, `${result.fromList}`,
  /// `${result.toList}`.
  reorder,

  /// A list or grid was pulled past its start to refresh (its pagination's
  /// `pullToRefresh`); its pagination reloads its first page too.
  refresh,

  /// A swipe action of a list item ran (the list's `swipeActions`):
  /// `${result.action}`, `${result.label}`, `${result.item}`,
  /// `${result.index}`.
  swipeAction,

  /// On the current canvas: a failed action chain or cloud subscription.
  /// `${result.error}` is `{type, message, action, nodeId}` (no stack or
  /// raw service objects). A failure in this reaction reports to the host
  /// without recursively firing another actionError reaction.
  actionError;

  /// The swipe triggers.
  static const List<TriggerType> swipes = [swipeLeft, swipeRight, swipeUp, swipeDown];

  /// The triggers a node's pointer input fires (the render tree wires them
  /// on the node's box).
  static const Set<TriggerType> pointer = {
    click, doubleTap, longPress, hold, secondaryClick, pointerDown, pointerUp, hover, cursorEnter, cursorExit, //
    swipeLeft, swipeRight, swipeUp, swipeDown, drag, dragEnd, wheel, pinch,
  };

  /// The triggers of a screen: they fire while it shows, wherever they're set.
  static const Set<TriggerType> screen = {load, valueChanged, timer, clock, keyDown, keyUp, backPressed, actionError};

  /// The triggers an input fires.
  static const Set<TriggerType> input = {changed, changeEnd, submitted, editingComplete, focusGained, focusLost};
}

/// How long a [TriggerType.hold] is held by default, in milliseconds.
const int kDefaultHoldMs = 1200;

/// How much of a node must be visible, by default, for
/// [TriggerType.enterViewport].
const double kDefaultVisibleFraction = 0.15;

/// A trigger and its settings. JSON (sparse): `{"type": "click"}`,
/// `{"type": "changed", "debounceMs": 300}`, `{"type": "timer",
/// "intervalMs": 500}`, `{"type": "keyDown", "key": "Meta+Enter"}`.
@immutable
final class Trigger {
  const Trigger(
    this.type, {
    this.debounceMs = 0,
    this.variable = '',
    this.intervalMs = 1000,
    this.key = '',
    this.when = '',
    this.holdMs = kDefaultHoldMs,
    this.every = '',
    this.runWhen = '',
    this.lookaheadMs = 100,
    this.visibleFraction = kDefaultVisibleFraction,
  });

  final TriggerType type;

  /// Waits this long after the last trigger before running, so a burst
  /// (typing in a search field) runs once. 0 runs every time.
  final int debounceMs;

  /// [TriggerType.valueChanged]: the variable watched.
  final String variable;

  /// [TriggerType.timer]: how often it fires.
  final int intervalMs;

  /// Key triggers: the key or combination ([KeyCombo]); empty: any key.
  final String key;

  /// Key triggers: a formula; they run (and take the key) only while it's
  /// true. Empty: always.
  final String when;

  /// [TriggerType.hold]: how long the press is held.
  final int holdMs;

  /// [TriggerType.clock]: milliseconds between ticks, a number or formula.
  final String every;

  /// [TriggerType.clock]: runs while this formula is true; empty: always.
  final String runWhen;

  /// [TriggerType.clock]: how early each tick's actions run.
  final int lookaheadMs;

  /// Viewport triggers: the visible share (0–1) that counts as in view.
  final double visibleFraction;

  /// The shortest timer interval.
  static const int minIntervalMs = 16;

  /// [intervalMs], kept between [minIntervalMs] and a day.
  int get effectiveIntervalMs => intervalMs.clamp(minIntervalMs, 86400000);

  /// [key] as a key combination; null for any key.
  KeyCombo? get keyCombo => KeyCombo.tryParse(key);

  static Trigger? fromJson(Object? json) {
    if (json is String) {
      final t = _type(json);
      return t == null ? null : Trigger(t);
    }
    final m = readMap(json);
    final type = _type(m?['type']);
    if (m == null || type == null) return null;
    return Trigger(
      type,
      debounceMs: (readInt(m['debounceMs']) ?? 0).clamp(0, 600000),
      variable: readString(m['variable']) ?? '',
      intervalMs: readInt(m['intervalMs']) ?? 1000,
      key: readString(m['key']) ?? '',
      when: readString(m['when']) ?? '',
      holdMs: readInt(m['holdMs']) ?? kDefaultHoldMs,
      every: m['every'] == null ? '' : '${m['every']}',
      runWhen: readString(m['runWhen']) ?? '',
      lookaheadMs: readInt(m['lookaheadMs']) ?? 100,
      visibleFraction: (readDouble(m['visibleFraction']) ?? kDefaultVisibleFraction).clamp(0, 1).toDouble(),
    );
  }

  static TriggerType? _type(Object? v) {
    if (v is! String) return null;
    for (final t in TriggerType.values) {
      if (t.name == v) return t;
    }
    return null;
  }

  Json toJson() => {
        'type': type.name,
        if (debounceMs != 0) 'debounceMs': debounceMs,
        if (variable.isNotEmpty) 'variable': variable,
        if (intervalMs != 1000) 'intervalMs': intervalMs,
        if (key.isNotEmpty) 'key': key,
        if (when.isNotEmpty) 'when': when,
        if (holdMs != kDefaultHoldMs) 'holdMs': holdMs,
        if (every.isNotEmpty) 'every': every,
        if (runWhen.isNotEmpty) 'runWhen': runWhen,
        if (lookaheadMs != 100) 'lookaheadMs': lookaheadMs,
        if (visibleFraction != kDefaultVisibleFraction) 'visibleFraction': writeDouble(visibleFraction),
      };

  @override
  bool operator ==(Object other) => other is Trigger && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());

  @override
  String toString() => 'Trigger(${type.name})';
}

/// A trigger and the actions it runs, in order: one chain. A blocking
/// action is awaited before the next; a failing one stops the chain.
/// JSON:
///
/// ```json
/// {"id": "r1", "name": "Add one", "trigger": {"type": "click"},
///  "actions": [{"type": "setVariable", "variable": "count", "op": "add", "value": "1"}]}
/// ```
@immutable
final class Reaction {
  const Reaction({this.id = '', this.name = '', required this.trigger, this.actions = const []});

  final String id;
  final String name;
  final Trigger trigger;
  final List<ActionDef> actions;

  TriggerType get type => trigger.type;

  /// Every action, nested ones included, depth first.
  Iterable<ActionDef> get allActions => actions.expand((a) => a.selfAndNested);

  /// Decodes a reaction; null without a known trigger.
  static Reaction? fromJson(Object? json) {
    final m = readMap(json);
    final trigger = Trigger.fromJson(m?['trigger']);
    if (m == null || trigger == null) return null;
    return Reaction(
      id: readString(m['id']) ?? '',
      name: readString(m['name']) ?? '',
      trigger: trigger,
      actions: ActionDef.listFromJson(m['actions']),
    );
  }

  static List<Reaction> listFromJson(Object? json) => [...?readList(json)?.map(fromJson).nonNulls];

  Json toJson() => {
        if (id.isNotEmpty) 'id': id,
        if (name.isNotEmpty) 'name': name,
        'trigger': trigger.toJson(),
        'actions': [for (final a in actions) a.toJson()],
      };

  Reaction copyWith({String? id, String? name, Trigger? trigger, List<ActionDef>? actions}) => Reaction(
        id: id ?? this.id,
        name: name ?? this.name,
        trigger: trigger ?? this.trigger,
        actions: actions ?? this.actions,
      );

  @override
  bool operator ==(Object other) =>
      other is Reaction &&
      other.id == id &&
      other.name == name &&
      other.trigger == trigger &&
      listEquals(other.actions, actions);

  @override
  int get hashCode => Object.hash(id, name, trigger, Object.hashAll(actions));

  @override
  String toString() => 'Reaction(${trigger.type.name} → ${actions.map((a) => a.type).join(', ')})';
}

/// A key with the modifiers held with it, as [Trigger.key] names it:
/// `Enter`, `Meta+Enter`, `Shift+Tab`, `Meta+b`, `ArrowDown`, `Escape`.
/// Every part but the last is a modifier: `Meta` (also `Cmd`, `Command`,
/// `Ctrl`, `Control`, `Mod`: Command on macOS, Control elsewhere), `Shift`,
/// `Alt` (also `Option`). The key compares without case or spaces; `Esc`
/// reads as `Escape`, `Return` as `Enter`.
@immutable
final class KeyCombo {
  const KeyCombo(this.key, {this.meta = false, this.shift = false, this.alt = false});

  /// The key, lower case, without spaces.
  final String key;
  final bool meta, shift, alt;

  static const _metaNames = {'meta', 'cmd', 'command', 'ctrl', 'control', 'mod'};
  static const _altNames = {'alt', 'option'};

  /// [text] (`Meta+Enter`) as a combination; null when empty or naming an
  /// unknown modifier.
  static KeyCombo? tryParse(String? text) {
    if (text == null) return null;
    var value = text.trim();
    if (value.isEmpty) return null;
    String key;
    if (value == '+') return const KeyCombo('+');
    if (value.endsWith('++')) {
      key = '+';
      value = value.substring(0, value.length - 2);
    } else {
      final at = value.lastIndexOf('+');
      key = value.substring(at + 1);
      value = at < 0 ? '' : value.substring(0, at);
    }
    var meta = false, shift = false, alt = false;
    if (value.isNotEmpty) {
      for (final part in value.split('+')) {
        final name = part.trim().toLowerCase();
        if (_metaNames.contains(name)) {
          meta = true;
        } else if (name == 'shift') {
          shift = true;
        } else if (_altNames.contains(name)) {
          alt = true;
        } else {
          return null;
        }
      }
    }
    final normalized = normalizeKey(key);
    if (normalized.isEmpty) return null;
    return KeyCombo(normalized, meta: meta, shift: shift, alt: alt);
  }

  /// [label] as combinations compare it.
  static String normalizeKey(String label) => switch (label.replaceAll(' ', '').toLowerCase()) {
        'esc' => 'escape',
        'return' => 'enter',
        'spacebar' => 'space',
        final k => k,
      };

  /// Whether key [label] pressed with these modifiers is this combination.
  /// Modifiers match exactly, except Shift on a one-character key the
  /// combination doesn't shift (typing `?` takes Shift).
  bool matches(String label, {bool meta = false, bool shift = false, bool alt = false}) {
    if (normalizeKey(label) != key) return false;
    if (meta != this.meta || alt != this.alt) return false;
    if (this.shift) return shift;
    return !shift || key.length == 1;
  }

  @override
  bool operator ==(Object other) =>
      other is KeyCombo && other.key == key && other.meta == meta && other.shift == shift && other.alt == alt;

  @override
  int get hashCode => Object.hash(key, meta, shift, alt);

  @override
  String toString() => [if (meta) 'Meta', if (shift) 'Shift', if (alt) 'Alt', key].join('+');
}
