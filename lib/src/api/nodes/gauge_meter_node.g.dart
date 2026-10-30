// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gauge_meter_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$GaugeMeterNodeOmitDefaults(
  GaugeMeterNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.value, 0)) json.remove('value');
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

Map<String, dynamic> _$GaugeMeterPropertiesOmitDefaults(
  GaugeMeterProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.shape, GaugeShape.arc)) json.remove('shape');
  if (isJsonDefault(instance.min, 0)) json.remove('min');
  if (isJsonDefault(instance.max, 100)) json.remove('max');
  if (isJsonDefault(
    instance.color,
    const ColorRGBA(r: 0.24, g: 0.84, b: 0.55, a: 1),
  ))
    json.remove('color');
  if (isJsonDefault(
    instance.trackColor,
    const ColorRGBA(r: 0.16, g: 0.18, b: 0.21, a: 1),
  ))
    json.remove('trackColor');
  if (isJsonDefault(instance.fillStartOpacity, 1))
    json.remove('fillStartOpacity');
  if (isJsonDefault(instance.segments, 0)) json.remove('segments');
  if (isJsonDefault(instance.segmentGap, 1.25)) json.remove('segmentGap');
  if (isJsonDefault(instance.thickness, 0)) json.remove('thickness');
  if (isJsonDefault(instance.startAngle, 135)) json.remove('startAngle');
  if (isJsonDefault(instance.sweepAngle, 270)) json.remove('sweepAngle');
  if (isJsonDefault(instance.cornerRadius, 0)) json.remove('cornerRadius');
  if (isJsonDefault(instance.backgroundColor, ColorRGBA.transparent))
    json.remove('backgroundColor');
  if (isJsonDefault(instance.borderColor, ColorRGBA.transparent))
    json.remove('borderColor');
  if (isJsonDefault(instance.inset, 0)) json.remove('inset');
  if (isJsonDefault(instance.edgeWidth, 0)) json.remove('edgeWidth');
  if (isJsonDefault(instance.edgeColor, ColorRGBA.white))
    json.remove('edgeColor');
  if (isJsonDefault(instance.ticks, 0)) json.remove('ticks');
  if (isJsonDefault(instance.majorTickEvery, 0)) json.remove('majorTickEvery');
  if (isJsonDefault(
    instance.tickColor,
    const ColorRGBA(r: 0.23, g: 0.25, b: 0.28, a: 1),
  ))
    json.remove('tickColor');
  if (isJsonDefault(
    instance.limitColor,
    const ColorRGBA(r: 0.95, g: 0.76, b: 0.19, a: 1),
  ))
    json.remove('limitColor');
  if (isJsonDefault(instance.limitWidth, 3)) json.remove('limitWidth');
  if (isJsonDefault(instance.limitStyle, GaugeLimitStyle.solid))
    json.remove('limitStyle');
  if (isJsonDefault(instance.limitPointer, false)) json.remove('limitPointer');
  if (isJsonDefault(instance.animate, true)) json.remove('animate');
  if (isJsonDefault(instance.animationDurationInMillis, 700))
    json.remove('animationDurationInMillis');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GaugeMeterNode _$GaugeMeterNodeFromJson(Map json) =>
    GaugeMeterNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        visible: json['visible'] as bool? ?? true,
        enabled: json['enabled'] as bool? ?? true,
        rotationDegrees: json['rotation'] == null
            ? 0
            : castRotation(json['rotation']),
        alignment: json['alignment'] == null
            ? AlignmentModel.none
            : AlignmentModel.fromJson(json['alignment'] as Map),
        margin: json['margin'] == null
            ? EdgeInsetsModel.zero
            : EdgeInsetsModel.fromJson(json['margin']),
        padding: json['padding'] == null
            ? EdgeInsetsModel.zero
            : EdgeInsetsModel.fromJson(json['padding']),
        horizontalFit:
            $enumDecodeNullable(_$SizeFitEnumMap, json['horizontalFit']) ??
            SizeFit.fixed,
        verticalFit:
            $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
            SizeFit.fixed,
        flex: (json['flex'] as num?)?.toInt() ?? 1,
        constraints: json['constraints'] == null
            ? const BoxConstraintsModel()
            : BoxConstraintsModel.fromJson(json['constraints'] as Map),
        edgePins: json['edgePins'] == null
            ? EdgePinsModel.standard
            : EdgePinsModel.fromJson(
                Map<String, dynamic>.from(json['edgePins'] as Map),
              ),
        aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
        positioningMode:
            $enumDecodeNullable(
              _$PositioningModeEnumMap,
              json['positioningMode'],
            ) ??
            PositioningMode.align,
        reactions:
            (json['reactions'] as List<dynamic>?)
                ?.map((e) => Reaction.fromJson(e as Map))
                .toList() ??
            const [],
        value: (json['value'] as num?)?.toDouble() ?? 0,
        limit: (json['limit'] as num?)?.toDouble(),
        properties: GaugeMeterProperties.fromJson(json['properties'] as Map),
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
      ..type = json['type'] as String;

Map<String, dynamic> _$GaugeMeterNodeToJson(GaugeMeterNode instance) =>
    <String, dynamic>{
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'aspectRatioLock': instance.aspectRatioLock,
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
      'type': instance.type,
      'properties': instance.properties.toJson(),
      'value': instance.value,
      'limit': ?instance.limit,
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

GaugeMeterProperties _$GaugeMeterPropertiesFromJson(Map json) =>
    GaugeMeterProperties(
      shape:
          $enumDecodeNullable(_$GaugeShapeEnumMap, json['shape']) ??
          GaugeShape.arc,
      min: (json['min'] as num?)?.toDouble() ?? 0,
      max: (json['max'] as num?)?.toDouble() ?? 100,
      color: json['color'] == null
          ? const ColorRGBA(r: 0.24, g: 0.84, b: 0.55, a: 1)
          : ColorRGBA.fromJson(json['color']),
      trackColor: json['trackColor'] == null
          ? const ColorRGBA(r: 0.16, g: 0.18, b: 0.21, a: 1)
          : ColorRGBA.fromJson(json['trackColor']),
      fillStartOpacity: (json['fillStartOpacity'] as num?)?.toDouble() ?? 1,
      segments: (json['segments'] as num?)?.toInt() ?? 0,
      segmentGap: (json['segmentGap'] as num?)?.toDouble() ?? 1.25,
      thickness: (json['thickness'] as num?)?.toDouble() ?? 0,
      startAngle: (json['startAngle'] as num?)?.toDouble() ?? 135,
      sweepAngle: (json['sweepAngle'] as num?)?.toDouble() ?? 270,
      cornerRadius: (json['cornerRadius'] as num?)?.toDouble() ?? 0,
      backgroundColor: json['backgroundColor'] == null
          ? ColorRGBA.transparent
          : ColorRGBA.fromJson(json['backgroundColor']),
      borderColor: json['borderColor'] == null
          ? ColorRGBA.transparent
          : ColorRGBA.fromJson(json['borderColor']),
      inset: (json['inset'] as num?)?.toDouble() ?? 0,
      edgeWidth: (json['edgeWidth'] as num?)?.toDouble() ?? 0,
      edgeColor: json['edgeColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['edgeColor']),
      ticks: (json['ticks'] as num?)?.toInt() ?? 0,
      majorTickEvery: (json['majorTickEvery'] as num?)?.toInt() ?? 0,
      tickColor: json['tickColor'] == null
          ? const ColorRGBA(r: 0.23, g: 0.25, b: 0.28, a: 1)
          : ColorRGBA.fromJson(json['tickColor']),
      limitColor: json['limitColor'] == null
          ? const ColorRGBA(r: 0.95, g: 0.76, b: 0.19, a: 1)
          : ColorRGBA.fromJson(json['limitColor']),
      limitWidth: (json['limitWidth'] as num?)?.toDouble() ?? 3,
      limitStyle:
          $enumDecodeNullable(_$GaugeLimitStyleEnumMap, json['limitStyle']) ??
          GaugeLimitStyle.solid,
      limitPointer: json['limitPointer'] as bool? ?? false,
      animate: json['animate'] as bool? ?? true,
      animationDurationInMillis:
          (json['animationDurationInMillis'] as num?)?.toInt() ?? 700,
    );

Map<String, dynamic> _$GaugeMeterPropertiesToJson(
  GaugeMeterProperties instance,
) => <String, dynamic>{
  'shape': _$GaugeShapeEnumMap[instance.shape]!,
  'min': instance.min,
  'max': instance.max,
  'color': instance.color.toJson(),
  'trackColor': instance.trackColor.toJson(),
  'fillStartOpacity': instance.fillStartOpacity,
  'segments': instance.segments,
  'segmentGap': instance.segmentGap,
  'thickness': instance.thickness,
  'startAngle': instance.startAngle,
  'sweepAngle': instance.sweepAngle,
  'cornerRadius': instance.cornerRadius,
  'backgroundColor': instance.backgroundColor.toJson(),
  'borderColor': instance.borderColor.toJson(),
  'inset': instance.inset,
  'edgeWidth': instance.edgeWidth,
  'edgeColor': instance.edgeColor.toJson(),
  'ticks': instance.ticks,
  'majorTickEvery': instance.majorTickEvery,
  'tickColor': instance.tickColor.toJson(),
  'limitColor': instance.limitColor.toJson(),
  'limitWidth': instance.limitWidth,
  'limitStyle': _$GaugeLimitStyleEnumMap[instance.limitStyle]!,
  'limitPointer': instance.limitPointer,
  'animate': instance.animate,
  'animationDurationInMillis': instance.animationDurationInMillis,
};

const _$GaugeShapeEnumMap = {GaugeShape.arc: 'arc', GaugeShape.bar: 'bar'};

const _$GaugeLimitStyleEnumMap = {
  GaugeLimitStyle.solid: 'solid',
  GaugeLimitStyle.dashed: 'dashed',
};
