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
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PulseModel _$PulseModelFromJson(Map json) => PulseModel(
  minOpacity: (json['minOpacity'] as num?)?.toDouble() ?? 0.45,
  durationMillis: (json['durationMillis'] as num?)?.toInt() ?? 1100,
);

Map<String, dynamic> _$PulseModelToJson(PulseModel instance) =>
    <String, dynamic>{
      'minOpacity': instance.minOpacity,
      'durationMillis': instance.durationMillis,
    };
