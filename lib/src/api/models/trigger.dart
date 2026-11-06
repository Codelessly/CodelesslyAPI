import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../json_defaults.dart';
import '../mixins.dart';

part 'trigger.g.dart';

/// Types of triggers.
enum TriggerType {
  /// Triggered when the user clicks on the target. `${result}` says where:
  /// `x`, `y` in pixels from the target's top left, `globalX`, `globalY` on
  /// screen, the target's `width` and `height`, and `fx`, `fy`, the spot as
  /// a share (0 to 1) of the target's width and height, e.g. to place a pin
  /// where a map that resizes with the screen was tapped.
  click,

  /// Triggered when text is changed inside a text input field.
  changed,

  /// Triggered when a text field loses focus (the user clicked or tabbed
  /// elsewhere), e.g. to save an inline edit.
  editingComplete,

  /// Triggered when the user submits a text field from the keyboard (Enter
  /// on a one-line field, the keyboard's done/go key).
  submitted,

  /// Triggered when the user long presses on a target. `${result}` says
  /// where, as for [click]: `x`, `y`, `globalX`, `globalY`, `fx`, `fy`,
  /// `width`, `height`.
  longPress,

  /// Triggered each time the mouse cursor moves over the target, after it
  /// entered. Use [cursorEnter] and [cursorExit] to track whether the cursor
  /// is over the target: they fire once each.
  hover,

  /// Triggered when the user drags the target.
  drag,

  /// Triggered once when the mouse cursor enters the target region. Touch
  /// input doesn't fire it.
  cursorEnter,

  /// Triggered once when the mouse cursor exits the target region. Touch
  /// input doesn't fire it.
  cursorExit,

  /// Triggered when a pointer down event is received on the target.
  /// `${result}` says where, as for [click] (`x`, `y`, `globalX`,
  /// `globalY`, `fx`, `fy`, `width`, `height`), plus `button` and the
  /// modifier keys.
  pointerDown,

  /// Triggered when a pointer up event is received on the target, with the
  /// same `${result}` as [pointerDown].
  pointerUp,

  /// Triggered when the canvas is loaded.
  load,

  /// Triggered when the variable named by [TriggerModel.variable] changes,
  /// while the screen it is set on shows.
  valueChanged,

  /// Triggered over and over while the canvas is shown, every
  /// [TriggerModel.intervalMs].
  timer,

  /// Triggered when a key is pressed while the canvas is shown. The key is
  /// [TriggerModel.key], a logical key label such as `Arrow Right`, `Enter`
  /// or `A`, compared without case: `a` and `A` are both the A key, pressed
  /// with or without Shift.
  keyPress,

  /// Triggered when the user swipes the target to the left.
  swipeLeft,

  /// Triggered when the user swipes the target to the right.
  swipeRight,

  /// Triggered when the user swipes the target up.
  swipeUp,

  /// Triggered when the user swipes the target down.
  swipeDown,

  /// Triggered when the user taps the target twice in quick succession.
  /// A node with a double tap reaction delays its single taps ([click]) by
  /// the double tap timeout (300ms), the way Flutter tells the two apart.
  /// `${result}` says where, as for [click].
  doubleTap,

  /// Triggered when the user presses and holds the target for the trigger's
  /// [TriggerModel.duration]. Releasing early cancels it. While held, the
  /// target's descendants can read the progress, 0 to 1, as `${hold}`, for
  /// example to fill a hold-to-confirm button.
  hold,

  /// Triggered when the user lets go of a slider after changing it, with
  /// the final value. [changed] fires on every step of the drag.
  changeEnd,

  /// Triggered repeatedly while the canvas is shown, every
  /// [TriggerModel.intervalMillis] milliseconds.
  interval,

  /// Triggered once when the user lifts the pointer after dragging the
  /// target (see [drag], which fires on every move).
  dragEnd,

  /// Triggered when a key is pressed while the screen it is set on shows
  /// and no text field has focus (Escape and Command/Control shortcuts such
  /// as ⌘↵ also fire while typing, with `${result.typing}` true). The actions read
  /// `${result.key}` (the key's label: `a`, `ArrowLeft`, `Delete`,
  /// `Escape`, ...), `${result.shift}`, `${result.alt}` and `${result.meta}`
  /// (Command on macOS, Control elsewhere). On a text field it fires for
  /// keys pressed while the field
  /// has focus (e.g. ↑ ↓ Escape to drive a type-ahead menu), before the
  /// field's own editing keys, so Enter can send a message instead of
  /// breaking the line. [TriggerModel.key] limits it to one key or
  /// combination, such as `Meta+Enter`, and [TriggerModel.when] to the
  /// moments a formula is true.
  keyDown,

  /// Triggered when the user right-clicks the target (or taps it with two
  /// fingers on a trackpad). `${result.x}` and `${result.y}` are where, in
  /// screen coordinates, e.g. to open a context menu there; `localX`,
  /// `localY` are in the target, `fx`, `fy` a share (0 to 1) of its `width`
  /// and `height`.
  secondaryClick,

  /// Triggered on a draggable node when the user picks it up. The actions
  /// read the payload as `${drag.data}`.
  dragStart,

  /// Triggered on a draggable node when its drag ends without a drop (let go
  /// outside every target, on a target that refused it, or cancelled).
  dragCancel,

  /// Triggered on a drop target when a drag it accepts is dropped on it.
  /// `${result}` (and `${drag}`) hold `data`, `group`, `count`, `key`,
  /// `beforeId`, `before` (the item it lands before), `index`,
  /// `accepted`, and where the dragged node's centre landed on the target:
  /// `x`, `y` in pixels from its top left and `fx`, `fy` as a share of its
  /// size (0 to 1), e.g. a pin dropped on a map. A drop its `acceptIf`
  /// refuses doesn't fire it.
  drop,

  /// Triggered on a drop target when a drag it accepts moves onto it.
  dragEnter,

  /// Triggered on a drop target when a drag leaves it without dropping.
  dragExit,

  /// Triggered on a drop target when a drag has stayed over it for its
  /// `hoverDelayMs`, e.g. to switch to the tab or page it stands for.
  dragHover,

  /// Triggered on a draggable node when a drop target accepts its drop
  /// (after the target's `drop` reactions start), e.g. to remove it from
  /// the list it came from.
  dragCompleted,

  /// Triggered on a drop target when a drag of a group it accepts is let go
  /// on it but its `acceptIf` refuses it: a wrong answer, a full column.
  /// The actions read the drop like `drop` does; the draggable springs back.
  /// A target that is full ([DropTargetModel.fullIf]) fires [dropFull]
  /// instead.
  dropRejected,

  /// Triggered on a drop target that is full ([DropTargetModel.fullIf]) when
  /// a drag of a group it accepts is let go on it: not a wrong answer, but
  /// a reason to say so ("A2 is full"). The actions read the drop like
  /// `drop` does; the draggable springs back. While a drag is over a full
  /// target, `${drag.over}` names it and `${drag.full}` is true.
  dropFull,

  /// A steady clock for rhythm: ticks every [TriggerModel.every]
  /// milliseconds (a formula such as `${= 60000 / bpm}`, read again at each
  /// tick so tempo changes apply from the next one) while
  /// [TriggerModel.runWhen] is true, on the audio clock, without drift.
  ///
  /// Each tick's actions run [TriggerModel.lookaheadMs] before the tick is
  /// due, with `${result.tick}` (0, 1, 2… since it started), `${result.at}`
  /// (the tick's time on the audio clock, for a Play Sound action's `at`)
  /// and `${result.waitMs}` (how long until it's due, for a Delay that
  /// lines visuals up with the sound). Set on a canvas.
  clock,

  /// Triggered when a row of a data list has been dragged to a new place by
  /// this node, its reorder handle ([DragModel.reorder]). The actions read
  /// `${result.from}` and `${result.to}`: the row's old index and its index
  /// in the new order. A list with a `ReorderModel` also fires it, on the
  /// list, with `${result.item}` (the moved item) and `${result.fromList}`
  /// and `${result.toList}` (the lists' keys; the same within one list).
  reorder,

  /// Triggered on every scroll update of a scrolling row, column or
  /// canvas. The actions read `${result.offset}` (how far it is scrolled,
  /// in logical pixels), `${result.max}` (how far it can scroll) and
  /// `${result.fraction}` (0 at the start, 1 at the end), so a header can
  /// collapse, a bar fade in or a button appear as the content scrolls.
  scroll,

  /// Triggered when the mouse wheel or a trackpad scrolls over the target.
  /// The actions read `${result.deltaX}` and `${result.deltaY}` (how far it
  /// scrolled, positive down and right), `${result.x}` and `${result.y}`
  /// (the pointer, relative to the target's top-left) and
  /// `${result.ctrl}` (Control or Command held: browsers send trackpad
  /// pinches as Control + wheel), `${result.shift}` and `${result.trackpad}`.
  /// The scroll doesn't also scroll the page.
  wheel,

  /// Triggered on every step of a two-finger pinch (or trackpad pinch) on
  /// the target. The actions read `${result.scale}` (the zoom since the
  /// previous step: above 1 spreads, below 1 pinches), `${result.totalScale}`
  /// (since the pinch started), `${result.x}`, `${result.y}` (the point
  /// between the fingers, relative to the target) and `${result.deltaX}`,
  /// `${result.deltaY}` (how far that point moved). A one-finger drag on a
  /// target with pinch reactions still runs its [drag] reactions.
  pinch,

  /// Triggered when a key is released while the screen it is set on shows
  /// and no text field has focus, with the same `${result}` as [keyDown]:
  /// together they track a held key (Space to pan).
  keyUp,

  /// Triggered when a text field gains focus.
  focusGained,

  /// Triggered when a text field loses focus.
  focusLost,

  /// A scrolling list, grid, row or column came within a short distance of
  /// its end (or its content doesn't fill it): load the next page.
  scrollEnd,

  /// Triggered when the target scrolls (or is laid out) into view: when the
  /// share of it that is visible on screen, inside every scrollable around
  /// it, rises to [TriggerModel.visibleFraction]. Fires on the first frame
  /// when the target is already in view. For example, highlights an anchor
  /// nav's link while its section is on screen.
  enterViewport,

  /// Triggered when the target leaves the view: when the share of it that
  /// is visible falls below [TriggerModel.visibleFraction] after it was in
  /// view (see [enterViewport]). For example, gives a sticky header its
  /// "scrolled" style once the hero scrolls away.
  exitViewport,

  /// Triggered when the user pulls a list or grid past its start to
  /// refresh it (its pagination's `pullToRefresh`). The list's pagination
  /// controller, if any, reloads its first page; these reactions run too,
  /// to reload anything else. The indicator spins until they finish.
  refresh,

  /// Triggered when a swipe action of a list item runs (the list's
  /// `SwipeActionsModel`). The actions read `${result.action}` (the
  /// action's id), `${result.label}`, `${result.item}` and `${result.index}`.
  swipeAction,

  /// Triggered on a screen (canvas) when the user tries to leave it with the
  /// browser's back button, the system back button or gesture (Android,
  /// iOS swipe back) or Escape on a dialog, while the screen's
  /// [CanvasNode.blockBackVariable] binding (`variables['blockBack']`, e.g.
  /// `${= dirty}`) is true. The screen then stays, and these actions run
  /// instead, e.g. a "Discard changes?" confirm whose agreeing branch leaves
  /// with a Navigation pop, which the block does not stop. While the binding
  /// is false (or the canvas has none), back leaves as usual and this
  /// trigger doesn't fire.
  backPressed;

  /// The triggers for the target entering and leaving the view.
  static const List<TriggerType> viewport = [
    TriggerType.enterViewport,
    TriggerType.exitViewport,
  ];

  /// The triggers for the mouse cursor entering and leaving the target.
  static const List<TriggerType> hovers = [
    TriggerType.cursorEnter,
    TriggerType.cursorExit,
  ];

  /// Earlier names of trigger types, read as the types they became.
  static const Map<String, String> aliases = {
    'hoverEnter': 'cursorEnter',
    'hoverExit': 'cursorExit',
  };

  /// The triggers of a draggable node.
  static const List<TriggerType> dragSource = [
    TriggerType.dragStart,
    TriggerType.dragCancel,
    TriggerType.dragCompleted,
  ];

  /// The triggers of a drop target.
  static const List<TriggerType> dropTarget = [
    TriggerType.drop,
    TriggerType.dragEnter,
    TriggerType.dragExit,
    TriggerType.dragHover,
    TriggerType.dropRejected,
    TriggerType.dropFull,
  ];

  /// The swipe triggers.
  static const List<TriggerType> swipes = [
    TriggerType.swipeLeft,
    TriggerType.swipeRight,
    TriggerType.swipeUp,
    TriggerType.swipeDown,
  ];

  /// Displayable string representation of the trigger type.
  String get prettify {
    switch (this) {
      case TriggerType.click:
        return 'Click';
      case TriggerType.longPress:
        return 'Long Press';
      case TriggerType.hover:
        return 'Hover';
      case TriggerType.drag:
        return 'Drag';
      case TriggerType.cursorEnter:
        return 'Cursor Enter';
      case TriggerType.cursorExit:
        return 'Cursor Exit';
      case TriggerType.pointerDown:
        return 'Pointer Down';
      case TriggerType.pointerUp:
        return 'Pointer Up';
      case TriggerType.changed:
        return 'Changed';
      case TriggerType.editingComplete:
        return 'Editing Complete';
      case TriggerType.submitted:
        return 'Submitted';
      case TriggerType.load:
        return 'Load';
      case TriggerType.valueChanged:
        return 'Value Changed';
      case TriggerType.timer:
        return 'Timer';
      case TriggerType.keyPress:
        return 'Key Press';
      case TriggerType.swipeLeft:
        return 'Swipe Left';
      case TriggerType.swipeRight:
        return 'Swipe Right';
      case TriggerType.swipeUp:
        return 'Swipe Up';
      case TriggerType.swipeDown:
        return 'Swipe Down';
      case TriggerType.doubleTap:
        return 'Double Tap';
      case TriggerType.hold:
        return 'Hold to Confirm';
      case TriggerType.interval:
        return 'Interval';
      case TriggerType.changeEnd:
        return 'Change End';
      case TriggerType.dragEnd:
        return 'Drag End';
      case TriggerType.keyDown:
        return 'Key Down';
      case TriggerType.secondaryClick:
        return 'Right Click';
      case TriggerType.dragStart:
        return 'Drag Start';
      case TriggerType.dragCancel:
        return 'Drag Cancel';
      case TriggerType.drop:
        return 'Drop';
      case TriggerType.dragEnter:
        return 'Drag Enter';
      case TriggerType.dragExit:
        return 'Drag Exit';
      case TriggerType.dragHover:
        return 'Drag Hover';
      case TriggerType.dragCompleted:
        return 'Drag Completed';
      case TriggerType.dropRejected:
        return 'Drop Rejected';
      case TriggerType.dropFull:
        return 'Drop On Full';
      case TriggerType.clock:
        return 'Beat Clock';
      case TriggerType.reorder:
        return 'Reorder';
      case TriggerType.scroll:
        return 'Scroll';
      case TriggerType.wheel:
        return 'Wheel';
      case TriggerType.pinch:
        return 'Pinch';
      case TriggerType.keyUp:
        return 'Key Up';
      case TriggerType.focusGained:
        return 'Focus Gained';
      case TriggerType.focusLost:
        return 'Focus Lost';
      case TriggerType.scrollEnd:
        return 'Reached End';
      case TriggerType.enterViewport:
        return 'Enter Viewport';
      case TriggerType.exitViewport:
        return 'Exit Viewport';
      case TriggerType.refresh:
        return 'Pull to Refresh';
      case TriggerType.swipeAction:
        return 'Swipe Action';
      case TriggerType.backPressed:
        return 'Back Pressed';
    }
  }
}

/// How long a [TriggerType.hold] trigger is held by default, in
/// milliseconds.
const int kDefaultHoldDuration = 1200;

/// How much of a node must be visible, by default, for a
/// [TriggerType.enterViewport] trigger to fire or a
/// [MotionModel.revealOnScroll] entrance to play.
const double kDefaultVisibleFraction = 0.15;

/// A model representing a trigger event data.
@JsonSerializable()
class TriggerModel with Equatable, SerializableMixin {
  /// The type of the trigger.
  final TriggerType type;

  /// Waits this many milliseconds after the last trigger before running,
  /// so a burst (typing in a search field) runs the actions once. 0 runs
  /// them every time.
  @JsonKey(defaultValue: 0)
  final int debounceMs;

  /// For [TriggerType.valueChanged], the name of the variable to watch.
  final String? variable;

  /// How often a [TriggerType.timer] fires, in milliseconds.
  final int? intervalMs;

  /// The key a [TriggerType.keyPress], [TriggerType.keyDown] or
  /// [TriggerType.keyUp] listens for.
  /// Key labels (e.g. `ArrowLeft`) are case-insensitive; null listens
  /// for every key.
  ///
  /// A key is a key of the keyboard, not the character it types, so a
  /// letter matches without case: `f` and `F` both name the F key, and both
  /// match it pressed with or without Shift. Two reactions for `f` and `F`
  /// are two reactions for the same key and both run on one press. To act
  /// on Shift+F only, name the modifier: `Shift+F` (key down and key up).
  ///
  /// A key down key can name modifiers before the key, joined by `+`:
  /// `Meta+Enter` (`Meta` is Command or Control, so the same shortcut works
  /// on macOS and elsewhere), `Shift+Enter`, `Alt+ArrowUp`, `Meta+b`. A key
  /// then matches only with exactly those modifiers held; see [KeyCombo].
  final String? key;

  /// A formula or variable, e.g. `${= menuOpen}`: a [TriggerType.keyDown]
  /// or [TriggerType.keyPress] reaction runs, and takes the key, only while
  /// it is true. Null or empty: always. Lets one key do different things,
  /// such as Enter picking a suggestion while a menu is open and sending
  /// otherwise.
  final String? when;

  /// How long, in milliseconds, a [TriggerType.hold] trigger must be held
  /// before it fires.
  @JsonKey(defaultValue: kDefaultHoldDuration)
  final int duration;

  /// How often a [TriggerType.interval] trigger fires, in milliseconds.
  /// Ignored by other triggers.
  final int intervalMillis;

  /// For [TriggerType.clock]: milliseconds between ticks, as a number or a
  /// formula (`${= 60000 / bpm / subdivision}`).
  final String? every;

  /// For [TriggerType.clock]: a formula; the clock runs while it is true
  /// (`${playing}`) and starts again from tick 0 each time it turns true.
  /// Empty runs it while the screen shows.
  final String? runWhen;

  /// For [TriggerType.clock]: how early each tick's actions run, so sounds
  /// can be scheduled on time.
  @JsonKey(defaultValue: 100)
  final int lookaheadMs;

  /// The shortest interval allowed, so a typo can't flood the app.
  static const int minIntervalMillis = 100;

  /// How much of the target must be visible for a
  /// [TriggerType.enterViewport] trigger to fire, from 0 to 1;
  /// [TriggerType.exitViewport] fires when it falls below again. 0 means any
  /// visible pixel, 1 the whole target. A target larger than the view
  /// counts as wholly visible when it covers the view, so a tall section
  /// can still reach 1. Ignored by other triggers.
  @JsonKey(defaultValue: kDefaultVisibleFraction)
  final double visibleFraction;

  /// Creates a [TriggerModel] with given data.
  TriggerModel({
    required this.type,
    this.debounceMs = 0,
    this.variable,
    this.intervalMs,
    this.key,
    this.when,
    this.duration = kDefaultHoldDuration,
    this.intervalMillis = 1000,
    this.every,
    this.runWhen,
    this.lookaheadMs = 100,
    this.visibleFraction = kDefaultVisibleFraction,
  });

  /// [key] read as a key combination; null when [key] is null or empty.
  KeyCombo? get keyCombo => KeyCombo.tryParse(key);

  /// The interval of a timer trigger; one second when unset.
  int get effectiveIntervalMs => (intervalMs ?? 1000).clamp(16, 86400000);

  /// [intervalMillis], no shorter than [minIntervalMillis].
  int get effectiveIntervalMillis =>
      intervalMillis < minIntervalMillis ? minIntervalMillis : intervalMillis;

  @override
  List<Object?> get props => [
    type,
    debounceMs,
    variable,
    intervalMs,
    key,
    when,
    duration,
    intervalMillis,
    every,
    runWhen,
    lookaheadMs,
    visibleFraction,
  ];

  /// Duplicate this [TriggerModel] with given data overrides.
  TriggerModel copyWith({
    TriggerType? type,
    int? debounceMs,
    String? variable,
    int? intervalMs,
    String? key,
    String? when,
    int? duration,
    int? intervalMillis,
    String? every,
    String? runWhen,
    int? lookaheadMs,
    double? visibleFraction,
  }) => TriggerModel(
    type: type ?? this.type,
    debounceMs: debounceMs ?? this.debounceMs,
    variable: variable ?? this.variable,
    intervalMs: intervalMs ?? this.intervalMs,
    key: key ?? this.key,
    when: when ?? this.when,
    duration: duration ?? this.duration,
    intervalMillis: intervalMillis ?? this.intervalMillis,
    every: every ?? this.every,
    runWhen: runWhen ?? this.runWhen,
    lookaheadMs: lookaheadMs ?? this.lookaheadMs,
    visibleFraction: visibleFraction ?? this.visibleFraction,
  );

  /// Factory constructor for creating a new [TriggerModel] instance from
  /// JSON data.
  ///
  /// A type named by an earlier name ([TriggerType.aliases]) reads as the
  /// type it became.
  factory TriggerModel.fromJson(Map json) =>
      _$TriggerModelFromJson(switch (TriggerType.aliases[json['type']]) {
        final String type => {...json, 'type': type},
        null => json,
      });

  @override
  Map toJson() => _$TriggerModelOmitDefaults(this, _$TriggerModelToJson(this));
}

/// A key with the modifiers held with it, as a [TriggerModel.key] names it:
/// `Enter`, `Meta+Enter`, `Shift+Tab`, `Meta+b`, `ArrowDown`, `Escape`.
///
/// Parts are joined by `+`; every part but the last is a modifier:
/// - `Meta` (also `Cmd`, `Command`, `Ctrl`, `Control`, `Mod`): Command on
///   macOS or Control elsewhere,
/// - `Shift`,
/// - `Alt` (also `Option`).
///
/// The last part is the key, compared without case or spaces, so
/// `Arrow Down`, `ArrowDown` and `arrowdown` are the same key. `Esc` reads
/// as `Escape` and `Return` as `Enter`. A letter is the key, not the
/// character: `F` is the F key, as `f` is, and not Shift+F; write
/// `Shift+F` for that. A one-character key without `Shift` also matches
/// with Shift held (see [matches]).
class KeyCombo with Equatable {
  /// The key, lower case and without spaces: `enter`, `arrowdown`, `b`.
  final String key;

  /// Whether Command (macOS) or Control is held.
  final bool meta;

  /// Whether Shift is held.
  final bool shift;

  /// Whether Alt (Option) is held.
  final bool alt;

  /// Creates a [KeyCombo] for a normalized [key] (see [normalizeKey]).
  const KeyCombo(
    this.key, {
    this.meta = false,
    this.shift = false,
    this.alt = false,
  });

  static const Set<String> _metaNames = {
    'meta',
    'cmd',
    'command',
    'ctrl',
    'control',
    'mod',
  };
  static const Set<String> _altNames = {'alt', 'option'};

  /// Reads [text] such as `Meta+Enter`; null when it is null, empty or
  /// names an unknown modifier.
  static KeyCombo? tryParse(String? text) {
    if (text == null) return null;
    String value = text.trim();
    if (value.isEmpty) return null;
    // A trailing `+` after a separator is the plus key: `Meta++`, `+`.
    String key;
    if (value == '+') {
      return const KeyCombo('+');
    } else if (value.endsWith('++')) {
      key = '+';
      value = value.substring(0, value.length - 2);
    } else {
      final int at = value.lastIndexOf('+');
      key = value.substring(at + 1);
      value = at < 0 ? '' : value.substring(0, at);
    }
    bool meta = false, shift = false, alt = false;
    if (value.isNotEmpty) {
      for (final String part in value.split('+')) {
        final String name = part.trim().toLowerCase();
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
    final String normalized = normalizeKey(key);
    if (normalized.isEmpty) return null;
    return KeyCombo(normalized, meta: meta, shift: shift, alt: alt);
  }

  /// [label] in the form combos compare: lower case, without spaces, with
  /// `Esc` as `escape` and `Return` as `enter`.
  static String normalizeKey(String label) {
    final String key = label.replaceAll(' ', '').toLowerCase();
    return switch (key) {
      'esc' => 'escape',
      'return' => 'enter',
      'spacebar' => 'space',
      _ => key,
    };
  }

  /// Whether a key labeled [label] pressed with the given modifiers is this
  /// combination. The modifiers must match exactly, except Shift for a
  /// one-character key with no Shift in the combination, since typing `?` or
  /// `@` takes Shift on most keyboards.
  bool matches(
    String label, {
    bool meta = false,
    bool shift = false,
    bool alt = false,
  }) {
    if (normalizeKey(label) != key) return false;
    if (meta != this.meta || alt != this.alt) return false;
    if (this.shift) return shift;
    return !shift || key.length == 1;
  }

  @override
  List<Object?> get props => [key, meta, shift, alt];

  @override
  String toString() =>
      [if (meta) 'Meta', if (shift) 'Shift', if (alt) 'Alt', key].join('+');
}
