// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slider_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SliderNode _$SliderNodeFromJson(Map json) =>
    SliderNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        value: (json['value'] as num).toDouble(),
        visible: json['visible'] as bool? ?? true,
        enabled: json['enabled'] as bool? ?? true,
        alignment: json['alignment'] == null
            ? AlignmentModel.none
            : AlignmentModel.fromJson(json['alignment'] as Map),
        padding: json['padding'] == null
            ? EdgeInsetsModel.zero
            : EdgeInsetsModel.fromJson(json['padding']),
        margin: json['margin'] == null
            ? EdgeInsetsModel.zero
            : EdgeInsetsModel.fromJson(json['margin']),
        rotationDegrees: json['rotation'] == null
            ? 0
            : castRotation(json['rotation']),
        reactions:
            (json['reactions'] as List<dynamic>?)
                ?.map((e) => Reaction.fromJson(e as Map))
                .toList() ??
            const [],
        horizontalFit:
            $enumDecodeNullable(_$SizeFitEnumMap, json['horizontalFit']) ??
            SizeFit.fixed,
        verticalFit:
            $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
            SizeFit.fixed,
        flex: (json['flex'] as num?)?.toInt() ?? 1,
        aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
        constraints: json['constraints'] == null
            ? const BoxConstraintsModel()
            : BoxConstraintsModel.fromJson(json['constraints'] as Map),
        positioningMode:
            $enumDecodeNullable(
              _$PositioningModeEnumMap,
              json['positioningMode'],
            ) ??
            PositioningMode.align,
        edgePins: json['edgePins'] == null
            ? EdgePinsModel.standard
            : EdgePinsModel.fromJson(
                Map<String, dynamic>.from(json['edgePins'] as Map),
              ),
        properties: SliderProperties.fromJson(json['properties'] as Map),
        variables:
            (json['variables'] as Map?)?.map(
              (k, e) => MapEntry(k as String, e as String),
            ) ??
            {},
        multipleVariables:
            (json['multipleVariables'] as Map?)?.map(
              (k, e) => MapEntry(
                k as String,
                (e as List<dynamic>).map((e) => e as String).toList(),
              ),
            ) ??
            {},
      )
      ..componentId = json['componentId'] as String?
      ..markerType = $enumDecodeNullable(
        _$ComponentMarkerTypeEnumMap,
        json['markerType'],
      )
      ..componentVersion = (json['componentVersion'] as num?)?.toInt() ?? 1
      ..componentSchema =
          (json['componentSchema'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e),
          ) ??
          {}
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$SliderNodeToJson(SliderNode instance) =>
    <String, dynamic>{
      'variables': instance.variables,
      'multipleVariables': instance.multipleVariables,
      'componentId': ?instance.componentId,
      'markerType': ?_$ComponentMarkerTypeEnumMap[instance.markerType],
      'componentVersion': instance.componentVersion,
      'componentSchema': instance.componentSchema,
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
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'basicBoxLocal': instance.basicBoxLocal.toJson(),
      'margin': instance.margin.toJson(),
      'padding': instance.padding.toJson(),
      'rotation': instance.rotationDegrees,
      'widthFactor': ?instance.widthFactor,
      'heightFactor': ?instance.heightFactor,
      'enabled': instance.enabled,
      'type': instance.type,
      'value': instance.value,
      'properties': instance.properties.toJson(),
    };

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

const _$ComponentMarkerTypeEnumMap = {
  ComponentMarkerType.component: 'component',
  ComponentMarkerType.instance: 'instance',
};

SliderProperties _$SliderPropertiesFromJson(Map json) => SliderProperties(
  activeTrackColor: json['activeTrackColor'] == null
      ? ColorRGBA.black
      : ColorRGBA.fromJson(json['activeTrackColor']),
  inactiveTrackColor: json['inactiveTrackColor'] == null
      ? kSliderDefaultInactiveTrackColor
      : ColorRGBA.fromJson(json['inactiveTrackColor']),
  thumbColor: json['thumbColor'] == null
      ? ColorRGBA.black
      : ColorRGBA.fromJson(json['thumbColor']),
  overlayColor: json['overlayColor'] == null
      ? const ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.38)
      : ColorRGBA.fromJson(json['overlayColor']),
  autofocus: json['autofocus'] as bool? ?? false,
  divisions: (json['divisions'] as num?)?.toInt(),
  min: (json['min'] as num?)?.toDouble() ?? 0,
  max: (json['max'] as num?)?.toDouble() ?? 100,
  trackHeight:
      (json['trackHeight'] as num?)?.toDouble() ?? kSliderDefaultTrackHeight,
  label: json['label'] as String? ?? kSliderDefaultLabel,
  isDiscrete: json['isDiscrete'] as bool? ?? false,
  showLabel: json['showLabel'] as bool? ?? false,
  activeTickMarkColor: json['activeTickMarkColor'] == null
      ? ColorRGBA.grey
      : ColorRGBA.fromJson(json['activeTickMarkColor']),
  inactiveTickMarkColor: json['inactiveTickMarkColor'] == null
      ? ColorRGBA.grey
      : ColorRGBA.fromJson(json['inactiveTickMarkColor']),
  allowFractionalPoints: json['allowFractionalPoints'] as bool? ?? false,
  valueIndicatorColor: json['valueIndicatorColor'] == null
      ? ColorRGBA.grey
      : ColorRGBA.fromJson(json['valueIndicatorColor']),
  valueIndicatorTextColor: json['valueIndicatorTextColor'] == null
      ? ColorRGBA.white
      : ColorRGBA.fromJson(json['valueIndicatorTextColor']),
  valueIndicatorFontSize:
      (json['valueIndicatorFontSize'] as num?)?.toDouble() ?? 14,
  thumbRadius:
      (json['thumbRadius'] as num?)?.toDouble() ?? kSliderDefaultThumbRadius,
  showThumb: json['showThumb'] as bool? ?? true,
  trackShape:
      $enumDecodeNullable(_$SliderTrackShapeEnumEnumMap, json['trackShape']) ??
      SliderTrackShapeEnum.roundedRectangle,
  tickMarkRadius:
      (json['tickMarkRadius'] as num?)?.toDouble() ??
      kSliderDefaultTickMarkRadius,
  valueIndicatorShape:
      $enumDecodeNullable(
        _$SliderValueIndicatorShapeEnumMap,
        json['valueIndicatorShape'],
      ) ??
      SliderValueIndicatorShape.rectangle,
  overlayRadius:
      (json['overlayRadius'] as num?)?.toDouble() ??
      kSliderDefaultOverlayRadius,
  deriveOverlayColorFromThumb:
      json['deriveOverlayColorFromThumb'] as bool? ?? true,
);

Map<String, dynamic> _$SliderPropertiesToJson(SliderProperties instance) =>
    <String, dynamic>{
      'activeTrackColor': instance.activeTrackColor.toJson(),
      'inactiveTrackColor': instance.inactiveTrackColor.toJson(),
      'overlayColor': instance.overlayColor.toJson(),
      'thumbColor': instance.thumbColor.toJson(),
      'autofocus': instance.autofocus,
      'divisions': ?instance.divisions,
      'min': instance.min,
      'max': instance.max,
      'trackHeight': instance.trackHeight,
      'label': instance.label,
      'isDiscrete': instance.isDiscrete,
      'showLabel': instance.showLabel,
      'activeTickMarkColor': instance.activeTickMarkColor.toJson(),
      'inactiveTickMarkColor': instance.inactiveTickMarkColor.toJson(),
      'valueIndicatorColor': instance.valueIndicatorColor.toJson(),
      'valueIndicatorTextColor': instance.valueIndicatorTextColor.toJson(),
      'valueIndicatorFontSize': instance.valueIndicatorFontSize,
      'allowFractionalPoints': instance.allowFractionalPoints,
      'thumbRadius': instance.thumbRadius,
      'showThumb': instance.showThumb,
      'trackShape': _$SliderTrackShapeEnumEnumMap[instance.trackShape]!,
      'tickMarkRadius': instance.tickMarkRadius,
      'valueIndicatorShape':
          _$SliderValueIndicatorShapeEnumMap[instance.valueIndicatorShape]!,
      'overlayRadius': instance.overlayRadius,
      'deriveOverlayColorFromThumb': instance.deriveOverlayColorFromThumb,
    };

const _$SliderTrackShapeEnumEnumMap = {
  SliderTrackShapeEnum.rectangle: 'rectangle',
  SliderTrackShapeEnum.roundedRectangle: 'roundedRectangle',
};

const _$SliderValueIndicatorShapeEnumMap = {
  SliderValueIndicatorShape.paddle: 'paddle',
  SliderValueIndicatorShape.rectangle: 'rectangle',
};
