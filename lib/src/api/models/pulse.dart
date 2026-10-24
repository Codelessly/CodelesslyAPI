import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'pulse.g.dart';

/// A looping animation on a node: its opacity and scale go from the `from`
/// values to the `to` values over [periodMs], then back when [reverse] (a
/// breathing skeleton, a ring pulsing around a pin), or start over.
@JsonSerializable()
class PulseModel with Equatable, SerializableMixin {
  /// Milliseconds from the `from` values to the `to` values.
  final int periodMs;

  /// Whether each loop runs back from `to` to `from` (else it restarts).
  final bool reverse;

  /// Opacity at the start of a loop, 0 to 1.
  final double opacityFrom;

  /// Opacity at the end of a loop, 0 to 1.
  final double opacityTo;

  /// Scale at the start of a loop, around the node's center.
  final double scaleFrom;

  /// Scale at the end of a loop, around the node's center.
  final double scaleTo;

  /// Creates a [PulseModel]; by default it changes nothing.
  const PulseModel({
    this.periodMs = 1000,
    this.reverse = true,
    this.opacityFrom = 1,
    this.opacityTo = 1,
    this.scaleFrom = 1,
    this.scaleTo = 1,
  });

  @override
  List<Object?> get props => [
    periodMs,
    reverse,
    opacityFrom,
    opacityTo,
    scaleFrom,
    scaleTo,
  ];

  /// Creates a [PulseModel] from JSON.
  factory PulseModel.fromJson(Map json) => _$PulseModelFromJson(json);

  @override
  Map toJson() => _$PulseModelOmitDefaults(this, _$PulseModelToJson(this));
}
