import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../codelessly_api.dart';
import '../../schema/flutter_prop.dart';

part 'node_transition.g.dart';

/// The easing of a [NodeTransition]: the same curves as [MotionCurve].
enum TransitionCurve {
  /// Constant speed.
  linear,

  /// Starts slowly, ends quickly.
  easeIn,

  /// Starts quickly, ends slowly.
  easeOut,

  /// Slow at both ends.
  easeInOut,

  /// A strong ease out, for things that arrive.
  easeOutCubic,

  /// Overshoots a little and settles, like a spring.
  easeOutBack,

  /// Slow at both ends, with a stronger (cubic) acceleration in the middle.
  easeInOutCubic,

  /// Holds the start value, then jumps to the end value halfway through.
  step;

  /// Displayable name.
  String get prettify => switch (this) {
    TransitionCurve.linear => 'Linear',
    TransitionCurve.easeIn => 'Ease in',
    TransitionCurve.easeOut => 'Ease out',
    TransitionCurve.easeInOut => 'Ease in out',
    TransitionCurve.easeOutCubic => 'Ease out cubic',
    TransitionCurve.easeOutBack => 'Ease out back',
    TransitionCurve.easeInOutCubic => 'Ease in out cubic',
    TransitionCurve.step => 'Step',
  };
}

/// How a node animates when a condition, a bound variable or a formula
/// changes its style at runtime: instead of jumping, its opacity tweens to
/// the new value over [durationMillis].
///
/// A pulsing loading placeholder is an opacity bound to a variable that an
/// interval reaction toggles, with a transition as long as the interval.
@JsonSerializable()
class NodeTransition with Equatable, SerializableMixin {
  /// How long a change takes.
  @FlutterProp(
    'durationMillis',
    type: 'integer',
    group: 'Appearance',
    control: 'number',
    field: 'transition.durationMillis',
    flutterParam: false,
    a2ui: false,
    note: 'Codelessly opacity transition timing, not a parent widget constructor parameter.',
  )
  final int durationMillis;

  /// The easing of the change.
  final TransitionCurve curve;

  /// Creates a [NodeTransition].
  const NodeTransition({
    this.durationMillis = 200,
    this.curve = TransitionCurve.easeInOut,
  });

  /// [durationMillis] as a [Duration], never negative.
  Duration get duration =>
      Duration(milliseconds: durationMillis < 0 ? 0 : durationMillis);

  /// Duplicates this with the given overrides.
  NodeTransition copyWith({int? durationMillis, TransitionCurve? curve}) =>
      NodeTransition(
        durationMillis: durationMillis ?? this.durationMillis,
        curve: curve ?? this.curve,
      );

  /// Creates a [NodeTransition] from JSON.
  factory NodeTransition.fromJson(Map json) => _$NodeTransitionFromJson(json);

  @override
  Map toJson() =>
      _$NodeTransitionOmitDefaults(this, _$NodeTransitionToJson(this));

  @override
  List<Object?> get props => [durationMillis, curve];
}
