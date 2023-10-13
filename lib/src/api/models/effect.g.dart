// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effect.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Effect _$EffectFromJson(Map json) => Effect(
      id: _readId(json, 'id') as String,
      type: $enumDecode(_$EffectTypeEnumMap, json['type']),
      radius: (json['radius'] as num).toDouble(),
      visible: json['visible'] as bool? ?? true,
      color: json['color'] == null ? null : ColorRGBA.fromJson(json['color']),
      blendMode: $enumDecodeNullable(_$BlendModeCEnumMap, json['blendMode'],
          unknownValue: BlendModeC.srcOver),
      offset: json['offset'] == null ? null : Vec.fromJson(json['offset']),
      spread: (json['spread'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$EffectToJson(Effect instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'type': _$EffectTypeEnumMap[instance.type]!,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('visible', instance.visible, instance.visible, true);
  val['radius'] = instance.radius;
  writeNotNull('spread', instance.spread, instance.spread, null);
  writeNotNull('color', instance.color, instance.color?.toJson(), null);
  writeNotNull('blendMode', instance.blendMode,
      _$BlendModeCEnumMap[instance.blendMode], null);
  writeNotNull('offset', instance.offset, instance.offset?.toJson(), null);
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
