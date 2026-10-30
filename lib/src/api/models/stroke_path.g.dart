// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stroke_path.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$StrokePathOmitDefaults(
  StrokePath instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.points, const [])) json.remove('points');
  if (isJsonDefault(instance.xUnit, PathUnit.fraction)) json.remove('xUnit');
  if (isJsonDefault(instance.yUnit, PathUnit.pixels)) json.remove('yUnit');
  if (isJsonDefault(instance.curve, PathCurve.straight)) json.remove('curve');
  if (isJsonDefault(instance.color, '#FFFFFFFF')) json.remove('color');
  if (isJsonDefault(instance.width, 4)) json.remove('width');
  if (isJsonDefault(instance.dash, const [])) json.remove('dash');
  if (isJsonDefault(instance.cap, PathCap.round)) json.remove('cap');
  if (isJsonDefault(instance.inFront, false)) json.remove('inFront');
  return json;
}

Map<String, dynamic> _$RevealModelOmitDefaults(
  RevealModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.alignment, 0.5)) json.remove('alignment');
  if (isJsonDefault(instance.durationMs, 600)) json.remove('durationMs');
  if (isJsonDefault(instance.delayMs, 0)) json.remove('delayMs');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StrokePath _$StrokePathFromJson(Map json) => StrokePath(
  points:
      (json['points'] as List<dynamic>?)
          ?.map(
            (e) =>
                (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
          )
          .toList() ??
      const [],
  xUnit:
      $enumDecodeNullable(_$PathUnitEnumMap, json['xUnit']) ??
      PathUnit.fraction,
  yUnit:
      $enumDecodeNullable(_$PathUnitEnumMap, json['yUnit']) ?? PathUnit.pixels,
  curve:
      $enumDecodeNullable(_$PathCurveEnumMap, json['curve']) ??
      PathCurve.straight,
  color: json['color'] as String? ?? '#FFFFFFFF',
  width: (json['width'] as num?)?.toDouble() ?? 4,
  dash:
      (json['dash'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      const [],
  cap: $enumDecodeNullable(_$PathCapEnumMap, json['cap']) ?? PathCap.round,
  inFront: json['inFront'] as bool? ?? false,
);

Map<String, dynamic> _$StrokePathToJson(StrokePath instance) =>
    <String, dynamic>{
      'points': instance.points,
      'xUnit': _$PathUnitEnumMap[instance.xUnit]!,
      'yUnit': _$PathUnitEnumMap[instance.yUnit]!,
      'curve': _$PathCurveEnumMap[instance.curve]!,
      'color': instance.color,
      'width': instance.width,
      'dash': instance.dash,
      'cap': _$PathCapEnumMap[instance.cap]!,
      'inFront': instance.inFront,
    };

const _$PathUnitEnumMap = {
  PathUnit.fraction: 'fraction',
  PathUnit.pixels: 'pixels',
};

const _$PathCurveEnumMap = {
  PathCurve.straight: 'straight',
  PathCurve.vertical: 'vertical',
  PathCurve.horizontal: 'horizontal',
};

const _$PathCapEnumMap = {
  PathCap.butt: 'butt',
  PathCap.round: 'round',
  PathCap.square: 'square',
};

RevealModel _$RevealModelFromJson(Map json) => RevealModel(
  alignment: (json['alignment'] as num?)?.toDouble() ?? 0.5,
  durationMs: (json['durationMs'] as num?)?.toInt() ?? 600,
  delayMs: (json['delayMs'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RevealModelToJson(RevealModel instance) =>
    <String, dynamic>{
      'alignment': instance.alignment,
      'durationMs': instance.durationMs,
      'delayMs': instance.delayMs,
    };
