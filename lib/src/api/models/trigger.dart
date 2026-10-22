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

  /// Triggered repeatedly while the canvas is shown, every
  /// [TriggerModel.intervalMillis] milliseconds. Live readouts, countdowns
  /// and polling use it.
  interval;

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
      case TriggerType.interval:
        return 'Interval';
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

  /// How often an [TriggerType.interval] trigger fires, in milliseconds.
  /// Ignored by other triggers.
  final int intervalMillis;

  /// The shortest interval allowed, so a typo can't flood the app.
  static const int minIntervalMillis = 100;

  /// Creates a [TriggerModel] with given data.
  TriggerModel({
    required this.type,
    this.debounceMs = 0,
    this.variable,
    this.intervalMillis = 1000,
  });

  /// [intervalMillis], no shorter than [minIntervalMillis].
  int get effectiveIntervalMillis =>
      intervalMillis < minIntervalMillis ? minIntervalMillis : intervalMillis;

  @override
  List<Object?> get props => [type, debounceMs, variable, intervalMillis];

  /// Duplicate this [TriggerModel] with given data overrides.
  TriggerModel copyWith({
    TriggerType? type,
    int? debounceMs,
    String? variable,
    int? intervalMillis,
  }) => TriggerModel(
    type: type ?? this.type,
    debounceMs: debounceMs ?? this.debounceMs,
    variable: variable ?? this.variable,
    intervalMillis: intervalMillis ?? this.intervalMillis,
  );

  /// Factory constructor for creating a new [TriggerModel] instance from
  /// JSON data.
  factory TriggerModel.fromJson(Map json) => _$TriggerModelFromJson(json);

  @override
  Map toJson() => _$TriggerModelOmitDefaults(this, _$TriggerModelToJson(this));
}
