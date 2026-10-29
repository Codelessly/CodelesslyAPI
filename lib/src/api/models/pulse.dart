import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../codelessly_api.dart';

part 'pulse.g.dart';

/// A looping fade: the node's opacity eases from [minOpacity] to its own
/// opacity and back, one way in [durationMillis]. Used for skeleton
/// placeholders and blinking alarm indicators.
@JsonSerializable()
class PulseModel with Equatable, SerializableMixin {
  /// The opacity, as a fraction of the node's own, at the faint end.
  final double minOpacity;

  /// How long one fade (faint to full, or back) takes.
  final int durationMillis;

  /// Creates a [PulseModel] with the given data.
  const PulseModel({this.minOpacity = 0.45, this.durationMillis = 1100});

  /// Duplicates this [PulseModel] with the given values replaced.
  PulseModel copyWith({double? minOpacity, int? durationMillis}) => PulseModel(
    minOpacity: minOpacity ?? this.minOpacity,
    durationMillis: durationMillis ?? this.durationMillis,
  );

  /// Creates a [PulseModel] from JSON data.
  factory PulseModel.fromJson(Map json) => _$PulseModelFromJson(json);

  @override
  Map toJson() => _$PulseModelOmitDefaults(this, _$PulseModelToJson(this));

  @override
  List<Object?> get props => [minOpacity, durationMillis];
}
