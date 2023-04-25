// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effect.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Effect _$EffectFromJson(Map json) => Effect(
      id: json['id'] as String?,
      type: $enumDecode(_$EffectTypeEnumMap, json['type']),
      radius: (json['radius'] as num).toDouble(),
      visible: json['visible'] as bool? ?? true,
      color: json['color'] == null
          ? null
          : ColorRGBA.fromJson(json['color'] as Map),
      blendMode: $enumDecodeNullable(_$BlendModeCEnumMap, json['blendMode'],
          unknownValue: BlendModeC.srcOver),
      offset:
          json['offset'] == null ? null : Vec.fromJson(json['offset'] as Map),
      spread: (json['spread'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$EffectToJson(Effect instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'type': _$EffectTypeEnumMap[instance.type]!,
    'visible': instance.visible,
    'radius': instance.radius,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('spread', instance.spread);
  writeNotNull('color', instance.color?.toJson());
  writeNotNull('blendMode', _$BlendModeCEnumMap[instance.blendMode]);
  writeNotNull('offset', instance.offset?.toJson());
  return val;
}

const _$EffectTypeEnumMap = {
  EffectType.innerShadow: 'innerShadow',
  EffectType.dropShadow: 'dropShadow',
  EffectType.layerBlur: 'layerBlur',
  EffectType.backgroundBlur: 'backgroundBlur',
};

const _$BlendModeCEnumMap = {
  BlendModeC.clear: 'clear',
  BlendModeC.src: 'src',
  BlendModeC.dst: 'dst',
  BlendModeC.srcOver: 'srcOver',
  BlendModeC.dstOver: 'dstOver',
  BlendModeC.srcIn: 'srcIn',
  BlendModeC.dstIn: 'dstIn',
  BlendModeC.srcOut: 'srcOut',
  BlendModeC.dstOut: 'dstOut',
  BlendModeC.srcATop: 'srcATop',
  BlendModeC.dstATop: 'dstATop',
  BlendModeC.xor: 'xor',
  BlendModeC.plus: 'plus',
  BlendModeC.modulate: 'modulate',
  BlendModeC.screen: 'screen',
  BlendModeC.overlay: 'overlay',
  BlendModeC.darken: 'darken',
  BlendModeC.lighten: 'lighten',
  BlendModeC.colorDodge: 'colorDodge',
  BlendModeC.colorBurn: 'colorBurn',
  BlendModeC.hardLight: 'hardLight',
  BlendModeC.softLight: 'softLight',
  BlendModeC.difference: 'difference',
  BlendModeC.exclusion: 'exclusion',
  BlendModeC.multiply: 'multiply',
  BlendModeC.hue: 'hue',
  BlendModeC.saturation: 'saturation',
  BlendModeC.color: 'color',
  BlendModeC.luminosity: 'luminosity',
};
