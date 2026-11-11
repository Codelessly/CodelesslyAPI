// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_extras.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$InlineCodeStyleOmitDefaults(
  InlineCodeStyle instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.fontSizeScale, 1)) json.remove('fontSizeScale');
  if (isJsonDefault(instance.paddingSpaces, 0)) json.remove('paddingSpaces');
  return json;
}

Map<String, dynamic> _$CountUpModelOmitDefaults(
  CountUpModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.durationMs, 450)) json.remove('durationMs');
  if (isJsonDefault(instance.curve, MotionCurve.easeOutCubic))
    json.remove('curve');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InlineCodeStyle _$InlineCodeStyleFromJson(Map json) => InlineCodeStyle(
  fontFamily: json['fontFamily'] as String?,
  fontWeight: (json['fontWeight'] as num?)?.toInt(),
  color: json['color'] == null ? null : ColorRGBA.fromJson(json['color']),
  background: json['background'] == null
      ? null
      : ColorRGBA.fromJson(json['background']),
  fontSizeScale: (json['fontSizeScale'] as num?)?.toDouble() ?? 1,
  paddingSpaces: (json['paddingSpaces'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$InlineCodeStyleToJson(InlineCodeStyle instance) =>
    <String, dynamic>{
      'fontFamily': ?instance.fontFamily,
      'fontWeight': ?instance.fontWeight,
      'color': ?instance.color?.toJson(),
      'background': ?instance.background?.toJson(),
      'fontSizeScale': instance.fontSizeScale,
      'paddingSpaces': instance.paddingSpaces,
    };

CountUpModel _$CountUpModelFromJson(Map json) => CountUpModel(
  durationMs: (json['durationMs'] as num?)?.toInt() ?? 450,
  curve:
      $enumDecodeNullable(_$MotionCurveEnumMap, json['curve']) ??
      MotionCurve.easeOutCubic,
);

Map<String, dynamic> _$CountUpModelToJson(CountUpModel instance) =>
    <String, dynamic>{
      'durationMs': instance.durationMs,
      'curve': _$MotionCurveEnumMap[instance.curve]!,
    };

const _$MotionCurveEnumMap = {
  MotionCurve.linear: 'linear',
  MotionCurve.easeInOut: 'easeInOut',
  MotionCurve.easeOut: 'easeOut',
  MotionCurve.easeIn: 'easeIn',
  MotionCurve.easeOutBack: 'easeOutBack',
  MotionCurve.easeOutCubic: 'easeOutCubic',
  MotionCurve.easeInOutCubic: 'easeInOutCubic',
  MotionCurve.step: 'step',
};
