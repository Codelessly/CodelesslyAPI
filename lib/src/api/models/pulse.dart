import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';
import '../../schema/flutter_prop.dart';

part 'pulse.g.dart';

/// A looping fade: the node's opacity eases from [minOpacity] to its own
/// opacity and back, one way in [durationMillis]. Used for skeleton
/// placeholders and blinking alarm indicators.
///
/// [MotionPulseModel] is a distinct pulse mode; both travel in a node's
/// existing `pulse` field so generated node serializers need no new key.
@JsonSerializable()
class PulseModel with Equatable, SerializableMixin {
  /// The opacity, as a fraction of the node's own, at the faint end.
  @FlutterProp(
    'minOpacity',
    type: 'number',
    group: 'Effects',
    control: 'number',
    field: 'pulse.minOpacity',
    flutterParam: false,
    a2ui: false,
    note: 'Codelessly relative opacity pulse setting, not a Flutter widget constructor parameter.',
  )
  final double minOpacity;

  /// How long one fade (faint to full, or back) takes.
  @FlutterProp(
    'durationMillis',
    type: 'integer',
    group: 'Effects',
    control: 'number',
    field: 'pulse.durationMillis',
    flutterParam: false,
    a2ui: false,
    note: 'Codelessly relative opacity pulse timing, not a Flutter widget constructor parameter.',
  )
  final int durationMillis;

  /// Creates a [PulseModel] with the given data.
  const PulseModel({this.minOpacity = 0.45, this.durationMillis = 1100});

  /// Duplicates this [PulseModel] with the given values replaced.
  PulseModel copyWith({double? minOpacity, int? durationMillis}) => PulseModel(
    minOpacity: minOpacity ?? this.minOpacity,
    durationMillis: durationMillis ?? this.durationMillis,
  );

  /// Reads a relative or motion pulse from the existing node `pulse` key.
  /// An unmarked empty object cannot be assigned a mode safely.
  factory PulseModel.fromJson(Map json) {
    final kind = json['pulseKind'];
    const relativeKeys = {'minOpacity', 'durationMillis'};
    const motionKeys = {
      'periodMs',
      'reverse',
      'opacityFrom',
      'opacityTo',
      'scaleFrom',
      'scaleTo',
    };
    final relative = json.keys.any(relativeKeys.contains);
    final motion = json.keys.any(motionKeys.contains);
    if (relative && motion ||
        kind == 'relative' && motion ||
        kind == 'motion' && relative) {
      throw const FormatException('Conflicting pulse schema fields');
    }
    if (kind == 'relative') return _relativeFromJson(json);
    if (kind == 'motion') return MotionPulseModel.fromJson(json);
    if (kind != null) throw FormatException('Unknown pulseKind: $kind');

    // Old data can be read only when its fields unambiguously identify it.
    if (relative && !motion) return _relativeFromJson(json);
    if (motion && !relative) return MotionPulseModel.fromJson(json);
    throw const FormatException(
      'Unmarked pulse is ambiguous; provide pulseKind: relative or motion',
    );
  }

  static PulseModel _relativeFromJson(Map json) => PulseModel(
    minOpacity: (json['minOpacity'] as num?)?.toDouble() ?? 0.45,
    durationMillis: (json['durationMillis'] as num?)?.toInt() ?? 1100,
  );

  @override
  Map<String, dynamic> toJson() => {
    'pulseKind': 'relative',
    if (minOpacity != 0.45) 'minOpacity': minOpacity,
    if (durationMillis != 1100) 'durationMillis': durationMillis,
  };

  @override
  List<Object?> get props => [minOpacity, durationMillis];
}

/// Absolute opacity and scale motion, independent of the relative fade mode.
/// A cycle goes from the `from` values to `to` over [periodMs], then runs
/// backward when [reverse], or restarts otherwise.
class MotionPulseModel extends PulseModel {
  /// Duration of one forward animation cycle in milliseconds.
  final int periodMs;

  /// Whether the next cycle runs back instead of restarting.
  final bool reverse;

  /// Starting absolute opacity.
  final double opacityFrom;

  /// Ending absolute opacity.
  final double opacityTo;

  /// Starting draw-scale multiplier.
  final double scaleFrom;

  /// Ending draw-scale multiplier.
  final double scaleTo;

  /// Creates a motion pulse with inert defaults.
  const MotionPulseModel({
    this.periodMs = 1000,
    this.reverse = true,
    this.opacityFrom = 1,
    this.opacityTo = 1,
    this.scaleFrom = 1,
    this.scaleTo = 1,
  });

  /// Reads an explicit or exclusive-key motion pulse.
  factory MotionPulseModel.fromJson(Map json) => MotionPulseModel(
    periodMs: (json['periodMs'] as num?)?.toInt() ?? 1000,
    reverse: json['reverse'] as bool? ?? true,
    opacityFrom: (json['opacityFrom'] as num?)?.toDouble() ?? 1,
    opacityTo: (json['opacityTo'] as num?)?.toDouble() ?? 1,
    scaleFrom: (json['scaleFrom'] as num?)?.toDouble() ?? 1,
    scaleTo: (json['scaleTo'] as num?)?.toDouble() ?? 1,
  );

  @override
  Map<String, dynamic> toJson() => {
    'pulseKind': 'motion',
    if (periodMs != 1000) 'periodMs': periodMs,
    if (!reverse) 'reverse': reverse,
    if (opacityFrom != 1) 'opacityFrom': opacityFrom,
    if (opacityTo != 1) 'opacityTo': opacityTo,
    if (scaleFrom != 1) 'scaleFrom': scaleFrom,
    if (scaleTo != 1) 'scaleTo': scaleTo,
  };

  @override
  List<Object?> get props => [
    periodMs,
    reverse,
    opacityFrom,
    opacityTo,
    scaleFrom,
    scaleTo,
  ];
}
