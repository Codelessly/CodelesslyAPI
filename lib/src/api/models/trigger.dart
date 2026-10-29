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
  /// and no text field has focus. The actions read `${result.key}` (the
  /// key's label: `a`, `ArrowLeft`, `Delete`, `Escape`, ...),
  /// `${result.shift}`, `${result.alt}` and `${result.meta}` (Command on
  /// macOS, Control elsewhere). [TriggerModel.key] limits it to one key.
  keyDown;

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
  final String? key;

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
    this.duration = kDefaultHoldDuration,
    this.intervalMillis = 1000,
  });

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
    int? duration,
    int? intervalMillis,
  }) => TriggerModel(
    type: type ?? this.type,
    debounceMs: debounceMs ?? this.debounceMs,
    variable: variable ?? this.variable,
    intervalMs: intervalMs ?? this.intervalMs,
    key: key ?? this.key,
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
