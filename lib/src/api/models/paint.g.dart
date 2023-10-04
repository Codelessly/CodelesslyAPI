// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaintModel _$PaintModelFromJson(Map json) => PaintModel(
      id: _readId(json, 'id') as String,
      type: $enumDecode(_$PaintTypeEnumMap, json['type']),
      visible: json['visible'] as bool? ?? true,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
      color: json['color'] == null ? null : ColorRGB.fromJson(json['color']),
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
      assetID: json['assetID'] as String?,
      imageRepeat:
          $enumDecodeNullable(_$ImageRepeatEnumEnumMap, json['imageRepeat']) ??
              ImageRepeatEnum.noRepeat,
    );

Map<String, dynamic> _$PaintModelToJson(PaintModel instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'type': _$PaintTypeEnumMap[instance.type]!,
  };

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool listsEqual(List? a, List? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool mapsEqual(Map? a, Map? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final k in a.keys) {
      var bValue = b[k];
      if (bValue == null && !b.containsKey(k)) return false;
      if (bValue != a[k]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool setsEqual(Set? a, Set? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    return a.containsAll(b);
  }

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    if (value == null) return;
    bool areEqual = false;
    if (value is List) {
      areEqual = listsEqual(value, defaultValue);
    } else if (value is Map) {
      areEqual = mapsEqual(value, defaultValue);
    } else if (value is Set) {
      areEqual = setsEqual(value, defaultValue);
    } else {
      areEqual = value == defaultValue;
    }

    if (!areEqual) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('visible', instance.visible, instance.visible, true);
  writeNotNull(
      'opacity', instance.opacity, roundDoubleToJson(instance.opacity), 1);
  writeNotNull('color', instance.color, instance.color?.toJson(), null);
  writeNotNull('blendMode', instance.blendMode,
      _$BlendModeCEnumMap[instance.blendMode]!, BlendModeC.srcOver);
  writeNotNull('gradientTransform', instance.gradientTransform,
      instance.gradientTransform, null);
  writeNotNull('gradientStops', instance.gradientStops,
      instance.gradientStops?.map((e) => e.toJson()).toList(), null);
  writeNotNull(
      'imageTransform', instance.imageTransform, instance.imageTransform, null);
  writeNotNull('downloadUrl', instance.downloadUrl, instance.downloadUrl, null);
  writeNotNull('imageName', instance.imageName, instance.imageName, null);
  writeNotNull('imageHash', instance.imageHash, instance.imageHash, null);
  writeNotNull('assetID', instance.assetID, instance.assetID, null);
  writeNotNull('fit', instance.fit, _$FitEnumMap[instance.fit]!, Fit.none);
  writeNotNull('alignment', instance.alignment, instance.alignment.toJson(),
      AlignmentModel.none);
  writeNotNull('scaleX', instance.scaleX, instance.scaleX, 1);
  writeNotNull('scaleY', instance.scaleY, instance.scaleY, 1);
  writeNotNull(
      'cropData', instance.cropData, instance.cropData?.toJson(), null);
  writeNotNull('croppedImageURL', instance.croppedImageURL,
      instance.croppedImageURL, null);
  writeNotNull('sourceWidth', instance.sourceWidth, instance.sourceWidth, null);
  writeNotNull(
      'sourceHeight', instance.sourceHeight, instance.sourceHeight, null);
  writeNotNull(
      'imageRepeat',
      instance.imageRepeat,
      _$ImageRepeatEnumEnumMap[instance.imageRepeat]!,
      ImageRepeatEnum.noRepeat);
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
