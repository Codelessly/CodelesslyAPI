// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icon_model.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$MaterialIconOmitDefaults(
  MaterialIcon instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.version, 1)) json.remove('version');
  if (isJsonDefault(instance.fontFamily, 'MaterialIcons'))
    json.remove('fontFamily');
  return json;
}

Map<String, dynamic> _$MaterialSymbolOmitDefaults(
  MaterialSymbol instance,
  Map<String, dynamic> json,
) {
  return json;
}

Map<String, dynamic> _$CupertinoIconOmitDefaults(
  CupertinoIcon instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.fontFamily, 'CupertinoIcons'))
    json.remove('fontFamily');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaterialIcon _$MaterialIconFromJson(Map json) => MaterialIcon(
  codepoint: (json['codepoint'] as num).toInt(),
  fontFamily: json['fontFamily'] as String? ?? 'MaterialIcons',
  name: json['name'] as String,
  style: $enumDecode(_$MaterialIconStyleEnumMap, json['style']),
  version: (json['version'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$MaterialIconToJson(MaterialIcon instance) =>
    <String, dynamic>{
      'codepoint': instance.codepoint,
      'fontFamily': instance.fontFamily,
      'name': instance.name,
      'style': _$MaterialIconStyleEnumMap[instance.style]!,
      'version': ?instance.version,
    };

const _$MaterialIconStyleEnumMap = {
  MaterialIconStyle.outlined: 'outlined',
  MaterialIconStyle.filled: 'filled',
  MaterialIconStyle.rounded: 'rounded',
  MaterialIconStyle.sharp: 'sharp',
  MaterialIconStyle.twoTone: 'twoTone',
};

MaterialSymbol _$MaterialSymbolFromJson(Map json) => MaterialSymbol(
  codepoint: (json['codepoint'] as num).toInt(),
  fontFamily: json['fontFamily'] as String,
  name: json['name'] as String,
  style: $enumDecode(_$MaterialSymbolStyleEnumMap, json['style']),
);

Map<String, dynamic> _$MaterialSymbolToJson(MaterialSymbol instance) =>
    <String, dynamic>{
      'codepoint': instance.codepoint,
      'fontFamily': instance.fontFamily,
      'name': instance.name,
      'style': _$MaterialSymbolStyleEnumMap[instance.style]!,
    };

const _$MaterialSymbolStyleEnumMap = {
  MaterialSymbolStyle.outlined: 'outlined',
  MaterialSymbolStyle.rounded: 'rounded',
  MaterialSymbolStyle.sharp: 'sharp',
};

CupertinoIcon _$CupertinoIconFromJson(Map json) => CupertinoIcon(
  codepoint: (json['codepoint'] as num).toInt(),
  fontFamily: json['fontFamily'] as String? ?? 'CupertinoIcons',
  name: json['name'] as String,
);

Map<String, dynamic> _$CupertinoIconToJson(CupertinoIcon instance) =>
    <String, dynamic>{
      'codepoint': instance.codepoint,
      'fontFamily': instance.fontFamily,
      'name': instance.name,
    };
