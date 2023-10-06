// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_end_prop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartEndProp _$StartEndPropFromJson(Map json) => StartEndProp(
      start: json['start'] as int,
      end: json['end'] as int,
      fills: (json['fills'] as List<dynamic>?)
          ?.map((e) => PaintModel.fromJson(e as Map))
          .toList(),
      textDecoration: $enumDecodeNullable(
              _$TextDecorationEnumEnumMap, json['textDecoration']) ??
          TextDecorationEnum.none,
      letterSpacing: json['letterSpacing'] == null
          ? LetterSpacing.zero
          : LetterSpacing.fromJson(json['letterSpacing'] as Map),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 18,
      fontName: json['fontName'] == null
          ? FontName.robotoRegular
          : FontName.fromJson(json['fontName'] as Map),
      lineHeight: json['lineHeight'] == null
          ? LineHeight.auto
          : LineHeight.fromJson(json['lineHeight'] as Map),
      link: json['link'] as String? ?? '',
      isJsonPath: json['isJsonPath'] as bool? ?? false,
    );

Map<String, dynamic> _$StartEndPropToJson(StartEndProp instance) {
  final val = <String, dynamic>{
    'fills': instance.fills.map((e) => e.toJson()).toList(),
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'textDecoration',
      instance.textDecoration,
      _$TextDecorationEnumEnumMap[instance.textDecoration]!,
      TextDecorationEnum.none);
  writeNotNull('fontSize', instance.fontSize, instance.fontSize, 18);
  writeNotNull('letterSpacing', instance.letterSpacing,
      instance.letterSpacing.toJson(), LetterSpacing.zero);
  writeNotNull('fontName', instance.fontName, instance.fontName.toJson(),
      FontName.robotoRegular);
  writeNotNull('lineHeight', instance.lineHeight, instance.lineHeight.toJson(),
      LineHeight.auto);
  writeNotNull('link', instance.link, instance.link, '');
  writeNotNull('isJsonPath', instance.isJsonPath, instance.isJsonPath, false);
  val['start'] = instance.start;
  val['end'] = instance.end;
  return val;
}

const _$TextDecorationEnumEnumMap = {
  TextDecorationEnum.none: 'none',
  TextDecorationEnum.underline: 'underline',
  TextDecorationEnum.overline: 'overline',
  TextDecorationEnum.strikethrough: 'strikethrough',
};

TextProp _$TextPropFromJson(Map json) => TextProp(
      fills: (json['fills'] as List<dynamic>?)
          ?.map((e) => PaintModel.fromJson(e as Map))
          .toList(),
      textDecoration: $enumDecodeNullable(
              _$TextDecorationEnumEnumMap, json['textDecoration']) ??
          TextDecorationEnum.none,
      letterSpacing: json['letterSpacing'] == null
          ? LetterSpacing.zero
          : LetterSpacing.fromJson(json['letterSpacing'] as Map),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 18,
      fontName: json['fontName'] == null
          ? FontName.robotoRegular
          : FontName.fromJson(json['fontName'] as Map),
      lineHeight: json['lineHeight'] == null
          ? LineHeight.auto
          : LineHeight.fromJson(json['lineHeight'] as Map),
      link: json['link'] as String? ?? '',
      isJsonPath: json['isJsonPath'] as bool? ?? false,
    );

Map<String, dynamic> _$TextPropToJson(TextProp instance) {
  final val = <String, dynamic>{
    'fills': instance.fills.map((e) => e.toJson()).toList(),
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'textDecoration',
      instance.textDecoration,
      _$TextDecorationEnumEnumMap[instance.textDecoration]!,
      TextDecorationEnum.none);
  writeNotNull('fontSize', instance.fontSize, instance.fontSize, 18);
  writeNotNull('letterSpacing', instance.letterSpacing,
      instance.letterSpacing.toJson(), LetterSpacing.zero);
  writeNotNull('fontName', instance.fontName, instance.fontName.toJson(),
      FontName.robotoRegular);
  writeNotNull('lineHeight', instance.lineHeight, instance.lineHeight.toJson(),
      LineHeight.auto);
  writeNotNull('link', instance.link, instance.link, '');
  writeNotNull('isJsonPath', instance.isJsonPath, instance.isJsonPath, false);
  return val;
}
