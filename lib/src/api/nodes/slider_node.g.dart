// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slider_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SliderNode _$SliderNodeFromJson(Map json) => SliderNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      value: (json['value'] as num).toDouble(),
      outerBoxLocal: json['outerBoxLocal'] == null
          ? null
          : OuterNodeBox.fromJson(json['outerBoxLocal'] as Map),
      visible: json['visible'] as bool? ?? true,
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding'] as Map),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin'] as Map),
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          const [],
      horizontalFit:
          $enumDecodeNullable(_$SizeFitEnumMap, json['horizontalFit']) ??
              SizeFit.fixed,
      verticalFit: $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
          SizeFit.fixed,
      flex: json['flex'] as int? ?? 1,
      aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
      constraints: json['constraints'] == null
          ? const BoxConstraintsModel()
          : BoxConstraintsModel.fromJson(json['constraints'] as Map),
      positioningMode: $enumDecodeNullable(
              _$PositioningModeEnumMap, json['positioningMode']) ??
          PositioningMode.align,
      edgePins: json['edgePins'] == null
          ? EdgePinsModel.standard
          : EdgePinsModel.fromJson(
              Map<String, dynamic>.from(json['edgePins'] as Map)),
      properties: SliderProperties.fromJson(json['properties'] as Map),
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
      multipleVariables: (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {},
    )
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$SliderNodeToJson(SliderNode instance) {
  final val = <String, dynamic>{
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
    'variables': instance.variables,
    'multipleVariables': instance.multipleVariables,
    'id': instance.id,
    'name': instance.name,
    'visible': instance.visible,
    'constraints': instance.constraints.toJson(),
    'edgePins': instance.edgePins.toJson(),
    'positioningMode': _$PositioningModeEnumMap[instance.positioningMode]!,
    'horizontalFit': _$SizeFitEnumMap[instance.horizontalFit]!,
    'verticalFit': _$SizeFitEnumMap[instance.verticalFit]!,
    'flex': instance.flex,
    'aspectRatioLock': instance.aspectRatioLock,
    'alignment': instance.alignment.toJson(),
    'outerBoxLocal': instance.outerBoxLocal.toJson(),
    'basicBoxLocal': instance.basicBoxLocal.toJson(),
    'margin': instance.margin.toJson(),
    'padding': instance.padding.toJson(),
    'rotation': instance.rotationDegrees,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('widthFactor', instance.widthFactor);
  writeNotNull('heightFactor', instance.heightFactor);
  val['type'] = instance.type;
  val['value'] = instance.value;
  val['properties'] = instance.properties.toJson();
  return val;
}

const _$SizeFitEnumMap = {
  SizeFit.locked: 'locked',
  SizeFit.fixed: 'fixed',
  SizeFit.expanded: 'expanded',
  SizeFit.flexible: 'flexible',
  SizeFit.shrinkWrap: 'shrinkWrap',
};

const _$PositioningModeEnumMap = {
  PositioningMode.align: 'align',
  PositioningMode.pin: 'pin',
};

SliderProperties _$SliderPropertiesFromJson(Map json) => SliderProperties(
      activeTrackColor: json['activeTrackColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['activeTrackColor'] as Map),
      inactiveTrackColor: json['inactiveTrackColor'] == null
          ? kSliderDefaultInactiveTrackColor
          : ColorRGBA.fromJson(json['inactiveTrackColor'] as Map),
      thumbColor: json['thumbColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['thumbColor'] as Map),
      overlayColor: json['overlayColor'] == null
          ? const ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.38)
          : ColorRGBA.fromJson(json['overlayColor'] as Map),
      autofocus: json['autofocus'] as bool? ?? false,
      divisions: json['divisions'] as int?,
      min: (json['min'] as num?)?.toDouble() ?? 0,
      max: (json['max'] as num?)?.toDouble() ?? 100,
      trackHeight: (json['trackHeight'] as num?)?.toDouble() ??
          kSliderDefaultTrackHeight,
      label: json['label'] as String? ?? kSliderDefaultLabel,
      isDiscrete: json['isDiscrete'] as bool? ?? false,
      showLabel: json['showLabel'] as bool? ?? false,
      activeTickMarkColor: json['activeTickMarkColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['activeTickMarkColor'] as Map),
      inactiveTickMarkColor: json['inactiveTickMarkColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['inactiveTickMarkColor'] as Map),
      allowFractionalPoints: json['allowFractionalPoints'] as bool? ?? false,
      valueIndicatorColor: json['valueIndicatorColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['valueIndicatorColor'] as Map),
      valueIndicatorTextColor: json['valueIndicatorTextColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['valueIndicatorTextColor'] as Map),
      valueIndicatorFontSize:
          (json['valueIndicatorFontSize'] as num?)?.toDouble() ?? 14,
      thumbRadius: (json['thumbRadius'] as num?)?.toDouble() ??
          kSliderDefaultThumbRadius,
      showThumb: json['showThumb'] as bool? ?? true,
      trackShape: $enumDecodeNullable(
              _$SliderTrackShapeEnumEnumMap, json['trackShape']) ??
          SliderTrackShapeEnum.roundedRectangle,
      tickMarkRadius: (json['tickMarkRadius'] as num?)?.toDouble() ??
          kSliderDefaultTickMarkRadius,
      valueIndicatorShape: $enumDecodeNullable(
              _$SliderValueIndicatorShapeEnumMap,
              json['valueIndicatorShape']) ??
          SliderValueIndicatorShape.rectangle,
      overlayRadius: (json['overlayRadius'] as num?)?.toDouble() ??
          kSliderDefaultOverlayRadius,
      deriveOverlayColorFromThumb:
          json['deriveOverlayColorFromThumb'] as bool? ?? true,
    );

Map<String, dynamic> _$SliderPropertiesToJson(SliderProperties instance) {
  final val = <String, dynamic>{
    'activeTrackColor': instance.activeTrackColor.toJson(),
    'inactiveTrackColor': instance.inactiveTrackColor.toJson(),
    'overlayColor': instance.overlayColor.toJson(),
    'thumbColor': instance.thumbColor.toJson(),
    'autofocus': instance.autofocus,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('divisions', instance.divisions);
  val['min'] = instance.min;
  val['max'] = instance.max;
  val['trackHeight'] = instance.trackHeight;
  val['label'] = instance.label;
  val['isDiscrete'] = instance.isDiscrete;
  val['showLabel'] = instance.showLabel;
  val['activeTickMarkColor'] = instance.activeTickMarkColor.toJson();
  val['inactiveTickMarkColor'] = instance.inactiveTickMarkColor.toJson();
  val['valueIndicatorColor'] = instance.valueIndicatorColor.toJson();
  val['valueIndicatorTextColor'] = instance.valueIndicatorTextColor.toJson();
  val['valueIndicatorFontSize'] = instance.valueIndicatorFontSize;
  val['allowFractionalPoints'] = instance.allowFractionalPoints;
  val['thumbRadius'] = instance.thumbRadius;
  val['showThumb'] = instance.showThumb;
  val['trackShape'] = _$SliderTrackShapeEnumEnumMap[instance.trackShape]!;
  val['tickMarkRadius'] = instance.tickMarkRadius;
  val['valueIndicatorShape'] =
      _$SliderValueIndicatorShapeEnumMap[instance.valueIndicatorShape]!;
  val['overlayRadius'] = instance.overlayRadius;
  val['deriveOverlayColorFromThumb'] = instance.deriveOverlayColorFromThumb;
  return val;
}

const _$SliderTrackShapeEnumEnumMap = {
  SliderTrackShapeEnum.rectangle: 'rectangle',
  SliderTrackShapeEnum.roundedRectangle: 'roundedRectangle',
};

const _$SliderValueIndicatorShapeEnumMap = {
  SliderValueIndicatorShape.paddle: 'paddle',
  SliderValueIndicatorShape.rectangle: 'rectangle',
};
