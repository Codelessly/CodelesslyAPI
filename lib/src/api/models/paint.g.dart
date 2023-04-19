// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaintModel _$PaintModelFromJson(Map json) => PaintModel(
      id: json['id'] as String?,
      type: $enumDecode(_$PaintTypeEnumMap, json['type']),
      visible: json['visible'] as bool? ?? true,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
      color: json['color'] == null
          ? null
          : ColorRGB.fromJson(json['color'] as Map),
      blendMode: $enumDecodeNullable(_$BlendModeCEnumMap, json['blendMode'],
              unknownValue: BlendModeC.srcOver) ??
          BlendModeC.srcOver,
      gradientTransform: (json['gradientTransform'] as List<dynamic>?)
          ?.map((e) => e as num)
          .toList(),
      gradientStops: (json['gradientStops'] as List<dynamic>?)
          ?.map((e) => ColorStop.fromJson(e as Map))
          .toList(),
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
      imageRepeat:
          $enumDecodeNullable(_$ImageRepeatEnumEnumMap, json['imageRepeat']) ??
              ImageRepeatEnum.noRepeat,
    );

Map<String, dynamic> _$PaintModelToJson(PaintModel instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'type': _$PaintTypeEnumMap[instance.type]!,
    'visible': instance.visible,
    'opacity': instance.opacity,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('color', instance.color?.toJson());
  val['blendMode'] = _$BlendModeCEnumMap[instance.blendMode]!;
  writeNotNull('gradientTransform', instance.gradientTransform);
  writeNotNull(
      'gradientStops', instance.gradientStops?.map((e) => e.toJson()).toList());
  writeNotNull('imageTransform', instance.imageTransform);
  writeNotNull('downloadUrl', instance.downloadUrl);
  writeNotNull('imageName', instance.imageName);
  writeNotNull('imageHash', instance.imageHash);
  val['fit'] = _$FitEnumMap[instance.fit]!;
  val['alignment'] = instance.alignment.toJson();
  val['scaleX'] = instance.scaleX;
  val['scaleY'] = instance.scaleY;
  writeNotNull('cropData', instance.cropData?.toJson());
  writeNotNull('croppedImageURL', instance.croppedImageURL);
  writeNotNull('sourceWidth', instance.sourceWidth);
  writeNotNull('sourceHeight', instance.sourceHeight);
  val['imageRepeat'] = _$ImageRepeatEnumEnumMap[instance.imageRepeat]!;
  return val;
}

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
