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

  /// Triggered when the user hovers over a target with mouse cursor.
  hover,

  /// Triggered when the user drags the target.
  drag,

  /// Triggered when the cursor enters the target region.
  cursorEnter,

  /// Triggered when the cursor exits the target region.
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
  swipeDown;

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
    }
  }
}

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

  /// The key a [TriggerType.keyPress] listens for, as a logical key label
  /// (`Arrow Right`, `Enter`, `Space`, `A`).
  final String? key;

  /// Creates a [TriggerModel] with given data.
  TriggerModel({
    required this.type,
    this.debounceMs = 0,
    this.variable,
    this.intervalMs,
    this.key,
  });

  /// The interval of a timer trigger; one second when unset.
  int get effectiveIntervalMs => (intervalMs ?? 1000).clamp(16, 86400000);

  @override
  List<Object?> get props => [type, debounceMs, variable, intervalMs, key];

  /// Duplicate this [TriggerModel] with given data overrides.
  TriggerModel copyWith({
    TriggerType? type,
    int? debounceMs,
    String? variable,
    int? intervalMs,
    String? key,
  }) => TriggerModel(
    type: type ?? this.type,
    debounceMs: debounceMs ?? this.debounceMs,
    variable: variable ?? this.variable,
    intervalMs: intervalMs ?? this.intervalMs,
    key: key ?? this.key,
  );

  /// Factory constructor for creating a new [TriggerModel] instance from
  /// JSON data.
  factory TriggerModel.fromJson(Map json) => _$TriggerModelFromJson(json);

  @override
  Map toJson() => _$TriggerModelOmitDefaults(this, _$TriggerModelToJson(this));
}
