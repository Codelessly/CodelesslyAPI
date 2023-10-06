// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icon_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaterialIcon _$MaterialIconFromJson(Map json) => MaterialIcon(
      codepoint: json['codepoint'] as int,
      fontFamily: json['fontFamily'] as String? ?? 'MaterialIcons',
      name: json['name'] as String,
      style: $enumDecode(_$MaterialIconStyleEnumMap, json['style']),
      version: json['version'] as int? ?? 1,
    );

Map<String, dynamic> _$MaterialIconToJson(MaterialIcon instance) {
  final val = <String, dynamic>{
    'codepoint': instance.codepoint,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'fontFamily', instance.fontFamily, instance.fontFamily, 'MaterialIcons');
  val['name'] = instance.name;
  val['style'] = _$MaterialIconStyleEnumMap[instance.style]!;
  writeNotNull('version', instance.version, instance.version, 1);
  return val;
}

const _$MaterialIconStyleEnumMap = {
  MaterialIconStyle.outlined: 'outlined',
  MaterialIconStyle.filled: 'filled',
  MaterialIconStyle.rounded: 'rounded',
  MaterialIconStyle.sharp: 'sharp',
  MaterialIconStyle.twoTone: 'twoTone',
};

MaterialSymbol _$MaterialSymbolFromJson(Map json) => MaterialSymbol(
      codepoint: json['codepoint'] as int,
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
      codepoint: json['codepoint'] as int,
      fontFamily: json['fontFamily'] as String? ?? 'CupertinoIcons',
      name: json['name'] as String,
    );

Map<String, dynamic> _$CupertinoIconToJson(CupertinoIcon instance) {
  final val = <String, dynamic>{
    'codepoint': instance.codepoint,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'fontFamily', instance.fontFamily, instance.fontFamily, 'CupertinoIcons');
  val['name'] = instance.name;
  return val;
}
