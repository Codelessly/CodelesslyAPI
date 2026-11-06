import 'dart:math';

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

  /// Where in its loop the pulse starts, as a fraction (0 to 1) of one
  /// whole loop (there and back for a reversing pulse), so pulses with
  /// different phases ripple in sequence: three loading dots with phases
  /// 0, 0.15 and 0.3. Bindable per node, e.g. per list item, through the
  /// node's `pulsePhase` variable (`${= index * 0.15}`).
  final double phase;

  /// How far, in milliseconds, the pulse runs behind one with no delay: the
  /// same as a [phase] of `delayMs / loop length`, added to it. Bindable
  /// through the node's `pulseDelayMs` variable (`${= index * 160}`).
  final int delayMs;

  /// Creates a [PulseModel] with the given data.
  const PulseModel({
    this.minOpacity = 0.45,
    this.durationMillis = 1100,
    this.phase = 0,
    this.delayMs = 0,
  });

  /// Duplicates this [PulseModel] with the given values replaced.
  PulseModel copyWith({
    double? minOpacity,
    int? durationMillis,
    double? phase,
    int? delayMs,
  }) => PulseModel(
    minOpacity: minOpacity ?? this.minOpacity,
    durationMillis: durationMillis ?? this.durationMillis,
    phase: phase ?? this.phase,
    delayMs: delayMs ?? this.delayMs,
  );

  /// One whole loop of this pulse in milliseconds: there and back.
  int get loopMillis => 2 * durationMillis.clamp(16, 60000);

  /// The fraction (0 to 1) of its loop this pulse starts at: [phase] plus
  /// [delayMs] of [loopMillis], behind a pulse with neither.
  double get startFraction {
    final double loop = loopMillis.toDouble();
    final double raw =
        (phase.isFinite ? phase : 0) - (loop <= 0 ? 0 : delayMs / loop);
    final double wrapped = raw % 1;
    return wrapped < 0 ? wrapped + 1 : wrapped;
  }

  /// Reads the [phase] and [delayMs] shared by both pulse modes.
  static double _phaseOf(Map json) => (json['phase'] as num?)?.toDouble() ?? 0;

  static int _delayOf(Map json) => (json['delayMs'] as num?)?.toInt() ?? 0;

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
    phase: _phaseOf(json),
    delayMs: _delayOf(json),
  );

  @override
  Map<String, dynamic> toJson() => {
    'pulseKind': 'relative',
    if (minOpacity != 0.45) 'minOpacity': minOpacity,
    if (durationMillis != 1100) 'durationMillis': durationMillis,
    if (phase != 0) 'phase': phase,
    if (delayMs != 0) 'delayMs': delayMs,
  };

  @override
  List<Object?> get props => [minOpacity, durationMillis, phase, delayMs];
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
    super.phase,
    super.delayMs,
  });

  @override
  int get loopMillis {
    final int period = max(1, periodMs);
    return reverse ? 2 * period : period;
  }

  @override
  MotionPulseModel copyWith({
    double? minOpacity,
    int? durationMillis,
    double? phase,
    int? delayMs,
  }) => MotionPulseModel(
    periodMs: periodMs,
    reverse: reverse,
    opacityFrom: opacityFrom,
    opacityTo: opacityTo,
    scaleFrom: scaleFrom,
    scaleTo: scaleTo,
    phase: phase ?? this.phase,
    delayMs: delayMs ?? this.delayMs,
  );

  /// Reads an explicit or exclusive-key motion pulse.
  factory MotionPulseModel.fromJson(Map json) => MotionPulseModel(
    periodMs: (json['periodMs'] as num?)?.toInt() ?? 1000,
    reverse: json['reverse'] as bool? ?? true,
    opacityFrom: (json['opacityFrom'] as num?)?.toDouble() ?? 1,
    opacityTo: (json['opacityTo'] as num?)?.toDouble() ?? 1,
    scaleFrom: (json['scaleFrom'] as num?)?.toDouble() ?? 1,
    scaleTo: (json['scaleTo'] as num?)?.toDouble() ?? 1,
    phase: PulseModel._phaseOf(json),
    delayMs: PulseModel._delayOf(json),
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
    if (phase != 0) 'phase': phase,
    if (delayMs != 0) 'delayMs': delayMs,
  };

  @override
  List<Object?> get props => [
    phase,
    delayMs,
    periodMs,
    reverse,
    opacityFrom,
    opacityTo,
    scaleFrom,
    scaleTo,
  ];
}
