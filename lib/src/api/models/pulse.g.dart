// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pulse.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$PulseModelOmitDefaults(
  PulseModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.periodMs, 1000)) json.remove('periodMs');
  if (isJsonDefault(instance.reverse, true)) json.remove('reverse');
  if (isJsonDefault(instance.opacityFrom, 1)) json.remove('opacityFrom');
  if (isJsonDefault(instance.opacityTo, 1)) json.remove('opacityTo');
  if (isJsonDefault(instance.scaleFrom, 1)) json.remove('scaleFrom');
  if (isJsonDefault(instance.scaleTo, 1)) json.remove('scaleTo');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PulseModel _$PulseModelFromJson(Map json) => PulseModel(
  periodMs: (json['periodMs'] as num?)?.toInt() ?? 1000,
  reverse: json['reverse'] as bool? ?? true,
  opacityFrom: (json['opacityFrom'] as num?)?.toDouble() ?? 1,
  opacityTo: (json['opacityTo'] as num?)?.toDouble() ?? 1,
  scaleFrom: (json['scaleFrom'] as num?)?.toDouble() ?? 1,
  scaleTo: (json['scaleTo'] as num?)?.toDouble() ?? 1,
);

Map<String, dynamic> _$PulseModelToJson(PulseModel instance) =>
    <String, dynamic>{
      'periodMs': instance.periodMs,
      'reverse': instance.reverse,
      'opacityFrom': instance.opacityFrom,
      'opacityTo': instance.opacityTo,
      'scaleFrom': instance.scaleFrom,
      'scaleTo': instance.scaleTo,
    };
