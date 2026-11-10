import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'animate_variable_action.g.dart';

/// What an [AnimateVariableAction] does to its variable's animation.
enum AnimateVariableMode {
  /// Animates the variable from [AnimateVariableAction.from] (or its
  /// current value) to [AnimateVariableAction.to], replacing any animation
  /// of it that runs. The action finishes when the animation does (or is
  /// stopped), so the actions after it run then; make it non-blocking to
  /// run them at once.
  play,

  /// Holds the variable's animation where it is.
  pause,

  /// Carries a paused animation on from the variable's current value (it
  /// may have been scrubbed meanwhile) to its end, in the time left for
  /// that distance. With nothing to resume it plays from the current value
  /// to [AnimateVariableAction.to], so one "Play" button can both start and
  /// resume.
  resume,

  /// Ends the variable's animation, leaving the value where it is. A
  /// blocking play of it finishes.
  stop,

  /// Sets the variable to [AnimateVariableAction.to] at once; a running or
  /// paused animation carries on (or stays paused) from there.
  seek;

  /// Displayable name.
  String get prettify => switch (this) {
    AnimateVariableMode.play => 'Play',
    AnimateVariableMode.pause => 'Pause',
    AnimateVariableMode.resume => 'Resume',
    AnimateVariableMode.stop => 'Stop',
    AnimateVariableMode.seek => 'Seek',
  };
}

/// Animates a number variable over time: a timeline that plays, pauses,
/// resumes, stops and seeks, e.g. a sunrise preview that runs `sunriseT`
/// from 0 to 1 over 12 seconds while everything bound to it follows.
///
/// Animations are kept per variable (by name) for the screen's app: a play
/// replaces the variable's running animation, and pause, resume, stop and
/// seek act on it. A drag track that writes the variable (a playhead being
/// scrubbed) pauses it.
///
/// [from], [to] and [duration] take numbers, variables or formulas, e.g.
/// `"duration": "${= sunrise.previewSeconds * 1000}"`.
@JsonSerializable()
class AnimateVariableAction extends ActionModel
    with Equatable, SerializableMixin {
  /// The number variable to animate, by name.
  final String variable;

  /// What to do.
  @JsonKey(unknownEnumValue: AnimateVariableMode.play)
  final AnimateVariableMode mode;

  /// The value a [AnimateVariableMode.play] starts from; empty starts from
  /// the variable's current value.
  @JsonKey(fromJson: _jsonText)
  final String from;

  /// The value a play ends at, or a seek jumps to.
  @JsonKey(fromJson: _jsonText)
  final String to;

  /// How long a play takes from [from] to [to], in milliseconds.
  final int durationMs;

  /// A variable or formula giving [durationMs], e.g.
  /// `${= sunrise.previewSeconds * 1000}`. When it gives a number it is used
  /// instead of [durationMs].
  @JsonKey(fromJson: _jsonTextOrNull)
  final String? duration;

  /// The easing of the animation.
  @JsonKey(unknownEnumValue: MotionCurve.linear)
  final MotionCurve curve;

  /// Creates an [AnimateVariableAction].
  AnimateVariableAction({
    this.variable = '',
    this.mode = AnimateVariableMode.play,
    this.from = '',
    this.to = '1',
    this.durationMs = 1000,
    this.duration,
    this.curve = MotionCurve.linear,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.animateVariable);

  /// Duplicates this action with the given values replaced.
  AnimateVariableAction copyWith({
    String? variable,
    AnimateVariableMode? mode,
    String? from,
    String? to,
    int? durationMs,
    String? duration,
    bool clearDuration = false,
    MotionCurve? curve,
    bool? nonBlocking,
  }) => AnimateVariableAction(
    variable: variable ?? this.variable,
    mode: mode ?? this.mode,
    from: from ?? this.from,
    to: to ?? this.to,
    durationMs: durationMs ?? this.durationMs,
    duration: clearDuration ? null : duration ?? this.duration,
    curve: curve ?? this.curve,
    nonBlocking: nonBlocking ?? this.nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [
    variable,
    mode,
    from,
    to,
    durationMs,
    duration,
    curve,
    nonBlocking,
  ];

  /// Creates an instance from a JSON object.
  factory AnimateVariableAction.fromJson(Map json) =>
      _$AnimateVariableActionFromJson(json);

  @override
  Map toJson() => _$AnimateVariableActionOmitDefaults(
    this,
    _$AnimateVariableActionToJson(this),
  );

  @override
  R? accept<R>(ActionVisitor<R> visitor) =>
      visitor.visitAnimateVariableAction(this);
}

/// A JSON number or string as text ("" for null).
String _jsonText(Object? value) => value == null ? '' : '$value';

/// A JSON number or string as text, or null.
String? _jsonTextOrNull(Object? value) => value == null ? null : '$value';
