// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_end_prop.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$StartEndPropOmitDefaults(
  StartEndProp instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.textDecoration, TextDecorationEnum.none))
    json.remove('textDecoration');
  if (isJsonDefault(instance.fontSize, 18)) json.remove('fontSize');
  if (isJsonDefault(instance.letterSpacing, LetterSpacing.zero))
    json.remove('letterSpacing');
  if (isJsonDefault(instance.fontName, FontName.robotoRegular))
    json.remove('fontName');
  if (isJsonDefault(instance.lineHeight, LineHeight.auto))
    json.remove('lineHeight');
  if (isJsonDefault(instance.link, '')) json.remove('link');
  if (isJsonDefault(instance.isJsonPath, false)) json.remove('isJsonPath');
  return json;
}

Map<String, dynamic> _$TextPropOmitDefaults(
  TextProp instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.textDecoration, TextDecorationEnum.none))
    json.remove('textDecoration');
  if (isJsonDefault(instance.fontSize, 18)) json.remove('fontSize');
  if (isJsonDefault(instance.letterSpacing, LetterSpacing.zero))
    json.remove('letterSpacing');
  if (isJsonDefault(instance.fontName, FontName.robotoRegular))
    json.remove('fontName');
  if (isJsonDefault(instance.lineHeight, LineHeight.auto))
    json.remove('lineHeight');
  if (isJsonDefault(instance.link, '')) json.remove('link');
  if (isJsonDefault(instance.isJsonPath, false)) json.remove('isJsonPath');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartEndProp _$StartEndPropFromJson(Map json) => StartEndProp(
  start: (json['start'] as num).toInt(),
  end: (json['end'] as num).toInt(),
  fills: (json['fills'] as List<dynamic>?)
      ?.map((e) => PaintModel.fromJson(e as Map))
      .toList(),
  textDecoration:
      $enumDecodeNullable(
        _$TextDecorationEnumEnumMap,
        json['textDecoration'],
      ) ??
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

Map<String, dynamic> _$StartEndPropToJson(StartEndProp instance) =>
    <String, dynamic>{
      'fills': instance.fills.map((e) => e.toJson()).toList(),
      'textDecoration': _$TextDecorationEnumEnumMap[instance.textDecoration]!,
      'fontSize': instance.fontSize,
      'letterSpacing': instance.letterSpacing.toJson(),
      'fontName': instance.fontName.toJson(),
      'lineHeight': instance.lineHeight.toJson(),
      'link': instance.link,
      'isJsonPath': instance.isJsonPath,
      'start': instance.start,
      'end': instance.end,
    };

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
  textDecoration:
      $enumDecodeNullable(
        _$TextDecorationEnumEnumMap,
        json['textDecoration'],
      ) ??
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

Map<String, dynamic> _$TextPropToJson(TextProp instance) => <String, dynamic>{
  'fills': instance.fills.map((e) => e.toJson()).toList(),
  'textDecoration': _$TextDecorationEnumEnumMap[instance.textDecoration]!,
  'fontSize': instance.fontSize,
  'letterSpacing': instance.letterSpacing.toJson(),
  'fontName': instance.fontName.toJson(),
  'lineHeight': instance.lineHeight.toJson(),
  'link': instance.link,
  'isJsonPath': instance.isJsonPath,
};
