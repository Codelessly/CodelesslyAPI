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
  if (isJsonDefault(instance.transitionMs, 0)) json.remove('transitionMs');
  if (isJsonDefault(instance.drawScale, 1.0)) json.remove('drawScale');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.effectAnimations, []))
    json.remove('effectAnimations');
  if (isJsonDefault(instance.flightKey, '')) json.remove('flightKey');
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
  if (isJsonDefault(instance.thumbShape, SliderThumbShapeEnum.circle))
    json.remove('thumbShape');
  if (isJsonDefault(instance.thumbWidth, kSliderDefaultThumbSize))
    json.remove('thumbWidth');
  if (isJsonDefault(instance.thumbHeight, kSliderDefaultThumbSize))
    json.remove('thumbHeight');
  if (isJsonDefault(
    instance.thumbCornerRadius,
    kSliderDefaultThumbCornerRadius,
  ))
    json.remove('thumbCornerRadius');
  if (isJsonDefault(instance.showThumb, true)) json.remove('showThumb');
  if (isJsonDefault(instance.thumbBorderWidth, 2))
    json.remove('thumbBorderWidth');
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
  if (isJsonDefault(instance.orientation, AxisC.horizontal))
    json.remove('orientation');
  if (isJsonDefault(instance.inverted, false)) json.remove('inverted');
  if (isJsonDefault(instance.thumbStrokeWidth, 0))
    json.remove('thumbStrokeWidth');
  if (isJsonDefault(instance.fillFromEnd, false)) json.remove('fillFromEnd');
  if (isJsonDefault(instance.tickMarkStyle, SliderTickMarkStyle.dot))
    json.remove('tickMarkStyle');
  if (isJsonDefault(instance.notchEvery, 1)) json.remove('notchEvery');
  if (isJsonDefault(instance.markerColor, ColorRGBA.white))
    json.remove('markerColor');
  if (isJsonDefault(instance.markerWidth, 2)) json.remove('markerWidth');
  if (isJsonDefault(instance.markerHeight, 14)) json.remove('markerHeight');
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
        markerValue: (json['markerValue'] as num?)?.toDouble(),
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
      ..transitionMs = (json['transitionMs'] as num?)?.toInt() ?? 0
      ..drawScale = (json['drawScale'] as num?)?.toDouble() ?? 1.0
      ..pulse = json['pulse'] == null
          ? null
          : PulseModel.fromJson(json['pulse'] as Map)
      ..motion = json['motion'] == null
          ? null
          : MotionModel.fromJson(json['motion'] as Map)
      ..draggable = json['draggable'] == null
          ? null
          : DraggableModel.fromJson(json['draggable'] as Map)
      ..dropTarget = json['dropTarget'] == null
          ? null
          : DropTargetModel.fromJson(json['dropTarget'] as Map)
      ..effectAnimations =
          (json['effectAnimations'] as List<dynamic>?)
              ?.map((e) => EffectAnimation.fromJson(e as Map))
              .toList() ??
          []
      ..particles = json['particles'] == null
          ? null
          : ParticleEmitter.fromJson(json['particles'] as Map)
      ..flightKey = json['flightKey'] as String? ?? ''
      ..strokePath = json['strokePath'] == null
          ? null
          : StrokePath.fromJson(json['strokePath'] as Map)
      ..reveal = json['reveal'] == null
          ? null
          : RevealModel.fromJson(json['reveal'] as Map)
      ..type = json['type'] as String;

Map<String, dynamic> _$SliderNodeToJson(
  SliderNode instance,
) => <String, dynamic>{
  'reactions': instance.reactions.map((e) => e.toJson()).toList(),
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
  'transitionMs': instance.transitionMs,
  'drawScale': instance.drawScale,
  'pulse': ?instance.pulse?.toJson(),
  'enabled': instance.enabled,
  'motion': ?instance.motion?.toJson(),
  'draggable': ?instance.draggable?.toJson(),
  'dropTarget': ?instance.dropTarget?.toJson(),
  'effectAnimations': instance.effectAnimations.map((e) => e.toJson()).toList(),
  'particles': ?instance.particles?.toJson(),
  'flightKey': instance.flightKey,
  'strokePath': ?instance.strokePath?.toJson(),
  'reveal': ?instance.reveal?.toJson(),
  'type': instance.type,
  'value': instance.value,
  'markerValue': ?instance.markerValue,
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
  thumbShape:
      $enumDecodeNullable(_$SliderThumbShapeEnumEnumMap, json['thumbShape']) ??
      SliderThumbShapeEnum.circle,
  thumbWidth:
      (json['thumbWidth'] as num?)?.toDouble() ?? kSliderDefaultThumbSize,
  thumbHeight:
      (json['thumbHeight'] as num?)?.toDouble() ?? kSliderDefaultThumbSize,
  thumbCornerRadius:
      (json['thumbCornerRadius'] as num?)?.toDouble() ??
      kSliderDefaultThumbCornerRadius,
  showThumb: json['showThumb'] as bool? ?? true,
  thumbBorderColor: json['thumbBorderColor'] == null
      ? null
      : ColorRGBA.fromJson(json['thumbBorderColor']),
  thumbBorderWidth: (json['thumbBorderWidth'] as num?)?.toDouble() ?? 2,
  thumbGripColor: json['thumbGripColor'] == null
      ? null
      : ColorRGBA.fromJson(json['thumbGripColor']),
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
  orientation:
      $enumDecodeNullable(_$AxisCEnumMap, json['orientation']) ??
      AxisC.horizontal,
  inverted: json['inverted'] as bool? ?? false,
  thumbStrokeColor: json['thumbStrokeColor'] == null
      ? null
      : ColorRGBA.fromJson(json['thumbStrokeColor']),
  thumbStrokeWidth: (json['thumbStrokeWidth'] as num?)?.toDouble() ?? 0,
  fillFromEnd: json['fillFromEnd'] as bool? ?? false,
  tickMarkStyle:
      $enumDecodeNullable(
        _$SliderTickMarkStyleEnumMap,
        json['tickMarkStyle'],
      ) ??
      SliderTickMarkStyle.dot,
  notchEvery: (json['notchEvery'] as num?)?.toInt() ?? 1,
  markerColor: json['markerColor'] == null
      ? ColorRGBA.white
      : ColorRGBA.fromJson(json['markerColor']),
  markerWidth: (json['markerWidth'] as num?)?.toDouble() ?? 2,
  markerHeight: (json['markerHeight'] as num?)?.toDouble() ?? 14,
  selectableMin: (json['selectableMin'] as num?)?.toDouble(),
  selectableMax: (json['selectableMax'] as num?)?.toDouble(),
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
  'thumbShape': _$SliderThumbShapeEnumEnumMap[instance.thumbShape]!,
  'thumbWidth': instance.thumbWidth,
  'thumbHeight': instance.thumbHeight,
  'thumbCornerRadius': instance.thumbCornerRadius,
  'showThumb': instance.showThumb,
  'thumbBorderColor': ?instance.thumbBorderColor?.toJson(),
  'thumbBorderWidth': instance.thumbBorderWidth,
  'thumbGripColor': ?instance.thumbGripColor?.toJson(),
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
  'orientation': _$AxisCEnumMap[instance.orientation]!,
  'inverted': instance.inverted,
  'thumbStrokeColor': ?instance.thumbStrokeColor?.toJson(),
  'thumbStrokeWidth': instance.thumbStrokeWidth,
  'fillFromEnd': instance.fillFromEnd,
  'tickMarkStyle': _$SliderTickMarkStyleEnumMap[instance.tickMarkStyle]!,
  'notchEvery': instance.notchEvery,
  'markerColor': instance.markerColor.toJson(),
  'markerWidth': instance.markerWidth,
  'markerHeight': instance.markerHeight,
  'selectableMin': ?instance.selectableMin,
  'selectableMax': ?instance.selectableMax,
};

const _$SliderThumbShapeEnumEnumMap = {
  SliderThumbShapeEnum.circle: 'circle',
  SliderThumbShapeEnum.roundedRect: 'roundedRect',
  SliderThumbShapeEnum.rectangle: 'rectangle',
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

const _$AxisCEnumMap = {
  AxisC.horizontal: 'horizontal',
  AxisC.vertical: 'vertical',
};

const _$SliderTickMarkStyleEnumMap = {
  SliderTickMarkStyle.dot: 'dot',
  SliderTickMarkStyle.notch: 'notch',
};
