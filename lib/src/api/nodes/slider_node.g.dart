// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slider_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$SliderNodeOmitDefaults(
  SliderNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.visible, true)) json.remove('visible');
  if (excludeConstraintsIf(instance)) json.remove('constraints');
  if (isJsonDefault(instance.constraints, const BoxConstraintsModel()))
    json.remove('constraints');
  if (isJsonDefault(instance.edgePins, EdgePinsModel.standard))
    json.remove('edgePins');
  if (isJsonDefault(instance.positioningMode, PositioningMode.align))
    json.remove('positioningMode');
  if (isJsonDefault(instance.horizontalFit, SizeFit.fixed))
    json.remove('horizontalFit');
  if (isJsonDefault(instance.verticalFit, SizeFit.fixed))
    json.remove('verticalFit');
  if (isJsonDefault(instance.flex, 1)) json.remove('flex');
  if (isJsonDefault(instance.squeezable, false)) json.remove('squeezable');
  if (isJsonDefault(instance.aspectRatioLock, false))
    json.remove('aspectRatioLock');
  if (isJsonDefault(instance.alignment, AlignmentModel.none))
    json.remove('alignment');
  if (isJsonDefault(instance.margin, EdgeInsetsModel.zero))
    json.remove('margin');
  if (isJsonDefault(instance.padding, EdgeInsetsModel.zero))
    json.remove('padding');
  if (isJsonDefault(instance.rotationDegrees, 0)) json.remove('rotation');
  if (isJsonDefault(instance.interactionStates, {}))
    json.remove('interactionStates');
  if (isJsonDefault(instance.tooltip, '')) json.remove('tooltip');
  if (isJsonDefault(instance.zoomable, false)) json.remove('zoomable');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.variables, {})) json.remove('variables');
  if (isJsonDefault(instance.multipleVariables, {}))
    json.remove('multipleVariables');
  if (isJsonDefault(instance.componentVersion, 1))
    json.remove('componentVersion');
  if (isJsonDefault(instance.componentSchema, {}))
    json.remove('componentSchema');
  if (isJsonDefault(instance.reactions, const [])) json.remove('reactions');
  return json;
}

Map<String, dynamic> _$SliderPropertiesOmitDefaults(
  SliderProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.activeTrackColor, ColorRGBA.black))
    json.remove('activeTrackColor');
  if (isJsonDefault(
    instance.inactiveTrackColor,
    kSliderDefaultInactiveTrackColor,
  ))
    json.remove('inactiveTrackColor');
  if (isJsonDefault(
    instance.overlayColor,
    const ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.38),
  ))
    json.remove('overlayColor');
  if (isJsonDefault(instance.thumbColor, ColorRGBA.black))
    json.remove('thumbColor');
  if (isJsonDefault(instance.autofocus, false)) json.remove('autofocus');
  if (isJsonDefault(instance.min, 0)) json.remove('min');
  if (isJsonDefault(instance.max, 100)) json.remove('max');
  if (isJsonDefault(instance.trackHeight, kSliderDefaultTrackHeight))
    json.remove('trackHeight');
  if (isJsonDefault(instance.label, kSliderDefaultLabel)) json.remove('label');
  if (isJsonDefault(instance.isDiscrete, false)) json.remove('isDiscrete');
  if (isJsonDefault(instance.showLabel, false)) json.remove('showLabel');
  if (isJsonDefault(instance.activeTickMarkColor, ColorRGBA.grey))
    json.remove('activeTickMarkColor');
  if (isJsonDefault(instance.inactiveTickMarkColor, ColorRGBA.grey))
    json.remove('inactiveTickMarkColor');
  if (isJsonDefault(instance.valueIndicatorColor, ColorRGBA.grey))
    json.remove('valueIndicatorColor');
  if (isJsonDefault(instance.valueIndicatorTextColor, ColorRGBA.white))
    json.remove('valueIndicatorTextColor');
  if (isJsonDefault(instance.valueIndicatorFontSize, 14))
    json.remove('valueIndicatorFontSize');
  if (isJsonDefault(instance.allowFractionalPoints, false))
    json.remove('allowFractionalPoints');
  if (isJsonDefault(instance.thumbRadius, kSliderDefaultThumbRadius))
    json.remove('thumbRadius');
  if (isJsonDefault(instance.showThumb, true)) json.remove('showThumb');
  if (isJsonDefault(instance.trackShape, SliderTrackShapeEnum.roundedRectangle))
    json.remove('trackShape');
  if (isJsonDefault(instance.tickMarkRadius, kSliderDefaultTickMarkRadius))
    json.remove('tickMarkRadius');
  if (isJsonDefault(
    instance.valueIndicatorShape,
    SliderValueIndicatorShape.rectangle,
  ))
    json.remove('valueIndicatorShape');
  if (isJsonDefault(instance.overlayRadius, kSliderDefaultOverlayRadius))
    json.remove('overlayRadius');
  if (isJsonDefault(instance.deriveOverlayColorFromThumb, true))
    json.remove('deriveOverlayColorFromThumb');
  return json;
}

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
      ..squeezable = json['squeezable'] as bool? ?? false
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..interactionStates =
          (json['interactionStates'] as Map?)?.map(
            (k, e) => MapEntry(
              $enumDecode(_$InteractionStateEnumMap, k),
              (e as Map).map(
                (k, e) =>
                    MapEntry(k as String, Map<String, dynamic>.from(e as Map)),
              ),
            ),
          ) ??
          {}
      ..tooltip = json['tooltip'] as String? ?? ''
      ..zoomable = json['zoomable'] as bool? ?? false
      ..loopAnimation = json['loopAnimation'] == null
          ? null
          : LoopAnimation.fromJson(json['loopAnimation'] as Map)
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
      'squeezable': instance.squeezable,
      'aspectRatioLock': instance.aspectRatioLock,
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'alignment': instance.alignment.toJson(),
      'basicBoxLocal': instance.basicBoxLocal.toJson(),
      'margin': instance.margin.toJson(),
      'padding': instance.padding.toJson(),
      'rotation': instance.rotationDegrees,
      'widthFactor': ?instance.widthFactor,
      'heightFactor': ?instance.heightFactor,
      'interactionStates': instance.interactionStates.map(
        (k, e) => MapEntry(_$InteractionStateEnumMap[k]!, e),
      ),
      'tooltip': instance.tooltip,
      'zoomable': instance.zoomable,
      'loopAnimation': ?instance.loopAnimation?.toJson(),
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

const _$InteractionStateEnumMap = {
  InteractionState.hovered: 'hovered',
  InteractionState.focused: 'focused',
  InteractionState.pressed: 'pressed',
  InteractionState.selected: 'selected',
  InteractionState.disabled: 'disabled',
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
  showValueIndicator: $enumDecodeNullable(
    _$ShowValueIndicatorCEnumMap,
    json['showValueIndicator'],
  ),
  secondaryTrackValue: (json['secondaryTrackValue'] as num?)?.toDouble(),
  secondaryActiveTrackColor: json['secondaryActiveTrackColor'] == null
      ? null
      : ColorRGBA.fromJson(json['secondaryActiveTrackColor']),
  padding: json['padding'] == null
      ? null
      : EdgeInsetsModel.fromJson(json['padding']),
);

Map<String, dynamic> _$SliderPropertiesToJson(
  SliderProperties instance,
) => <String, dynamic>{
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
  'showValueIndicator':
      ?_$ShowValueIndicatorCEnumMap[instance.showValueIndicator],
  'secondaryTrackValue': ?instance.secondaryTrackValue,
  'secondaryActiveTrackColor': ?instance.secondaryActiveTrackColor?.toJson(),
  'padding': ?instance.padding?.toJson(),
};

const _$SliderTrackShapeEnumEnumMap = {
  SliderTrackShapeEnum.rectangle: 'rectangle',
  SliderTrackShapeEnum.roundedRectangle: 'roundedRectangle',
  SliderTrackShapeEnum.gapped: 'gapped',
};

const _$SliderValueIndicatorShapeEnumMap = {
  SliderValueIndicatorShape.paddle: 'paddle',
  SliderValueIndicatorShape.rectangle: 'rectangle',
  SliderValueIndicatorShape.drop: 'drop',
  SliderValueIndicatorShape.roundedRectangle: 'roundedRectangle',
};

const _$ShowValueIndicatorCEnumMap = {
  ShowValueIndicatorC.onlyForDiscrete: 'onlyForDiscrete',
  ShowValueIndicatorC.onlyForContinuous: 'onlyForContinuous',
  ShowValueIndicatorC.onDrag: 'onDrag',
  ShowValueIndicatorC.alwaysVisible: 'alwaysVisible',
  ShowValueIndicatorC.never: 'never',
};
