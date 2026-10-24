// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paint.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$PaintModelOmitDefaults(
  PaintModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.visible, true)) json.remove('visible');
  if (isJsonDefault(instance.opacity, 1)) json.remove('opacity');
  if (isJsonDefault(instance.blendMode, BlendModeC.srcOver))
    json.remove('blendMode');
  if (isJsonDefault(instance.fit, Fit.none)) json.remove('fit');
  if (isJsonDefault(instance.alignment, AlignmentModel.none))
    json.remove('alignment');
  if (isJsonDefault(instance.scaleX, 1)) json.remove('scaleX');
  if (isJsonDefault(instance.scaleY, 1)) json.remove('scaleY');
  if (isJsonDefault(instance.imageRepeat, ImageRepeatEnum.noRepeat))
    json.remove('imageRepeat');
  if (isJsonDefault(instance.saturation, 1)) json.remove('saturation');
  return json;
}

Map<String, dynamic> _$CropDataOmitDefaults(
  CropData instance,
  Map<String, dynamic> json,
) {
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaintModel _$PaintModelFromJson(Map json) => PaintModel(
  id: _readId(json, 'id') as String,
  type: $enumDecode(_$PaintTypeEnumMap, json['type']),
  visible: json['visible'] as bool? ?? true,
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
  color: json['color'] == null ? null : ColorRGB.fromJson(json['color']),
  blendMode:
      $enumDecodeNullable(
        _$BlendModeCEnumMap,
        json['blendMode'],
        unknownValue: BlendModeC.srcOver,
      ) ??
      BlendModeC.srcOver,
  gradientTransform: (json['gradientTransform'] as List<dynamic>?)
      ?.map((e) => e as num)
      .toList(),
  gradientStops: (json['gradientStops'] as List<dynamic>?)
      ?.map((e) => ColorStop.fromJson(e as Map))
      .toList(),
  gradientRepeatEvery: (json['gradientRepeatEvery'] as num?)?.toDouble(),
  imageTransform: (json['imageTransform'] as List<dynamic>?)
      ?.map((e) => (e as List<dynamic>).map((e) => e as num).toList())
      .toList(),
  downloadUrl: json['downloadUrl'] as String?,
  imageHash: json['imageHash'] as String?,
  fit: $enumDecodeNullable(_$FitEnumMap, json['fit']) ?? Fit.none,
  alignment: json['alignment'] == null
      ? AlignmentModel.none
      : AlignmentModel.fromJson(json['alignment'] as Map),
  scaleX: (json['scaleX'] as num?)?.toDouble() ?? 1,
  scaleY: (json['scaleY'] as num?)?.toDouble() ?? 1,
  cropData: json['cropData'] == null
      ? null
      : CropData.fromJson(json['cropData'] as Map),
  croppedImageURL: json['croppedImageURL'] as String?,
  imageName: json['imageName'] as String?,
  sourceWidth: (json['sourceWidth'] as num?)?.toDouble(),
  sourceHeight: (json['sourceHeight'] as num?)?.toDouble(),
  assetID: json['assetID'] as String?,
  imageRepeat:
      $enumDecodeNullable(_$ImageRepeatEnumEnumMap, json['imageRepeat']) ??
      ImageRepeatEnum.noRepeat,
  saturation: (json['saturation'] as num?)?.toDouble() ?? 1,
);

Map<String, dynamic> _$PaintModelToJson(PaintModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$PaintTypeEnumMap[instance.type]!,
      'visible': instance.visible,
      'opacity': roundDoubleToJson(instance.opacity),
      'color': ?instance.color?.toJson(),
      'blendMode': _$BlendModeCEnumMap[instance.blendMode]!,
      'gradientTransform': ?instance.gradientTransform,
      'gradientStops': ?instance.gradientStops?.map((e) => e.toJson()).toList(),
      'gradientRepeatEvery': ?instance.gradientRepeatEvery,
      'imageTransform': ?instance.imageTransform,
      'downloadUrl': ?instance.downloadUrl,
      'imageName': ?instance.imageName,
      'imageHash': ?instance.imageHash,
      'assetID': ?instance.assetID,
      'fit': _$FitEnumMap[instance.fit]!,
      'alignment': instance.alignment.toJson(),
      'scaleX': instance.scaleX,
      'scaleY': instance.scaleY,
      'cropData': ?instance.cropData?.toJson(),
      'croppedImageURL': ?instance.croppedImageURL,
      'sourceWidth': ?instance.sourceWidth,
      'sourceHeight': ?instance.sourceHeight,
      'imageRepeat': _$ImageRepeatEnumEnumMap[instance.imageRepeat]!,
      'saturation': instance.saturation,
    };

const _$PaintTypeEnumMap = {
  PaintType.solid: 'solid',
  PaintType.gradientLinear: 'gradientLinear',
  PaintType.gradientRadial: 'gradientRadial',
  PaintType.gradientAngular: 'gradientAngular',
  PaintType.gradientDiamond: 'gradientDiamond',
  PaintType.image: 'image',
  PaintType.emoji: 'emoji',
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

const _$FitEnumMap = {
  Fit.contain: 'contain',
  Fit.cover: 'cover',
  Fit.fill: 'fill',
  Fit.fitHeight: 'fitHeight',
  Fit.fitWidth: 'fitWidth',
  Fit.none: 'none',
  Fit.scaleDown: 'scaleDown',
};

const _$ImageRepeatEnumEnumMap = {
  ImageRepeatEnum.repeat: 'repeat',
  ImageRepeatEnum.repeatX: 'repeatX',
  ImageRepeatEnum.repeatY: 'repeatY',
  ImageRepeatEnum.noRepeat: 'noRepeat',
};

CropData _$CropDataFromJson(Map json) => CropData(
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  width: (json['width'] as num).toDouble(),
  height: (json['height'] as num).toDouble(),
);

Map<String, dynamic> _$CropDataToJson(CropData instance) => <String, dynamic>{
  'x': instance.x,
  'y': instance.y,
  'width': instance.width,
  'height': instance.height,
};
