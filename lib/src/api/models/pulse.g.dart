// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pulse.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$PulseModelOmitDefaults(
  PulseModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.minOpacity, 0.45)) json.remove('minOpacity');
  if (isJsonDefault(instance.durationMillis, 1100))
    json.remove('durationMillis');
  if (isJsonDefault(instance.phase, 0)) json.remove('phase');
  if (isJsonDefault(instance.delayMs, 0)) json.remove('delayMs');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PulseModel _$PulseModelFromJson(Map json) => PulseModel(
  minOpacity: (json['minOpacity'] as num?)?.toDouble() ?? 0.45,
  durationMillis: (json['durationMillis'] as num?)?.toInt() ?? 1100,
  phase: (json['phase'] as num?)?.toDouble() ?? 0,
  delayMs: (json['delayMs'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PulseModelToJson(PulseModel instance) =>
    <String, dynamic>{
      'minOpacity': instance.minOpacity,
      'durationMillis': instance.durationMillis,
      'phase': instance.phase,
      'delayMs': instance.delayMs,
    };
