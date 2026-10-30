import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../json_defaults.dart';
import '../mixins.dart';

part 'trigger.g.dart';

/// Types of triggers.
enum TriggerType {
  /// Triggered when the user clicks on the target.
  click,

  /// Triggered when text is changed inside a text input field.
  changed,

  /// Triggered when text editing is completed on a text input field and
  /// it is about to submit.
  editingComplete,

  /// Triggered when a text field is submitted.
  submitted,

  /// Triggered when the user long presses on a target.
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
  pointerDown,

  /// Triggered when a pointer up event is received on the target.
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
  /// or `A`.
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
  /// and no text field has focus, or, set on a text field, while that field
  /// has focus (before the field's own editing keys, so Enter can send a
  /// message instead of breaking the line). The actions read `${result.key}`
  /// (the key's label: `a`, `ArrowLeft`, `Delete`, `Escape`, ...),
  /// `${result.shift}`, `${result.alt}` and `${result.meta}` (Command on
  /// macOS, Control elsewhere). [TriggerModel.key] limits it to one key or
  /// combination, such as `Meta+Enter`, and [TriggerModel.when] to the
  /// moments a formula is true.
  keyDown,

  /// A scrolling list, grid, row or column came within a short distance of
  /// its end (or its content doesn't fill it): load the next page.
  scrollEnd;

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
      case TriggerType.scrollEnd:
        return 'Reached End';
    }
  }
}

/// How long a [TriggerType.hold] trigger is held by default, in
/// milliseconds.
const int kDefaultHoldDuration = 1200;

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

  /// The key a [TriggerType.keyPress] or [TriggerType.keyDown] listens for.
  /// Key down labels (e.g. `ArrowLeft`) are case-insensitive; null listens
  /// for every key.
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

  /// The shortest interval allowed, so a typo can't flood the app.
  static const int minIntervalMillis = 100;

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
  }) => TriggerModel(
    type: type ?? this.type,
    debounceMs: debounceMs ?? this.debounceMs,
    variable: variable ?? this.variable,
    intervalMs: intervalMs ?? this.intervalMs,
    key: key ?? this.key,
    when: when ?? this.when,
    duration: duration ?? this.duration,
    intervalMillis: intervalMillis ?? this.intervalMillis,
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
/// as `Escape` and `Return` as `Enter`.
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
