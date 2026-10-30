// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bar_chart_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$BarChartNodeOmitDefaults(
  BarChartNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.values, [])) json.remove('values');
  if (isJsonDefault(instance.labels, [])) json.remove('labels');
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

Map<String, dynamic> _$BarChartPropertiesOmitDefaults(
  BarChartProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.max, 0)) json.remove('max');
  if (isJsonDefault(
    instance.color,
    const ColorRGBA(r: 0.95, g: 0.76, b: 0.19, a: 1),
  ))
    json.remove('color');
  if (isJsonDefault(instance.dimmedOpacity, 0.55)) json.remove('dimmedOpacity');
  if (isJsonDefault(instance.barGap, 3)) json.remove('barGap');
  if (isJsonDefault(instance.barRadius, 1)) json.remove('barRadius');
  if (isJsonDefault(
    instance.emptyColor,
    const ColorRGBA(r: 0.23, g: 0.25, b: 0.28, a: 1),
  ))
    json.remove('emptyColor');
  if (isJsonDefault(instance.emptyHeight, 2)) json.remove('emptyHeight');
  if (isJsonDefault(instance.gridLines, 3)) json.remove('gridLines');
  if (isJsonDefault(
    instance.gridColor,
    const ColorRGBA(r: 0.17, g: 0.19, b: 0.22, a: 1),
  ))
    json.remove('gridColor');
  if (isJsonDefault(instance.gridLabels, [])) json.remove('gridLabels');
  if (isJsonDefault(instance.gridLabelWidth, 40)) json.remove('gridLabelWidth');
  if (isJsonDefault(
    instance.baselineColor,
    const ColorRGBA(r: 0.23, g: 0.25, b: 0.28, a: 1),
  ))
    json.remove('baselineColor');
  if (isJsonDefault(instance.labelFontFamily, 'JetBrains Mono'))
    json.remove('labelFontFamily');
  if (isJsonDefault(instance.labelFontSize, 10)) json.remove('labelFontSize');
  if (isJsonDefault(
    instance.labelColor,
    const ColorRGBA(r: 0.42, g: 0.45, b: 0.49, a: 1),
  ))
    json.remove('labelColor');
  if (isJsonDefault(
    instance.highlightLabelColor,
    const ColorRGBA(r: 0.91, g: 0.92, b: 0.93, a: 1),
  ))
    json.remove('highlightLabelColor');
  if (isJsonDefault(instance.labelGap, 6)) json.remove('labelGap');
  if (isJsonDefault(instance.animate, true)) json.remove('animate');
  if (isJsonDefault(instance.animationDurationInMillis, 700))
    json.remove('animationDurationInMillis');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarChartNode _$BarChartNodeFromJson(Map json) =>
    BarChartNode(
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
        values: (json['values'] as List<dynamic>?)
            ?.map((e) => (e as num?)?.toDouble())
            .toList(),
        labels: (json['labels'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        highlight: (json['highlight'] as num?)?.toInt(),
        properties: BarChartProperties.fromJson(json['properties'] as Map),
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

Map<String, dynamic> _$BarChartNodeToJson(
  BarChartNode instance,
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
  'properties': instance.properties.toJson(),
  'values': instance.values,
  'labels': instance.labels,
  'highlight': ?instance.highlight,
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

BarChartProperties _$BarChartPropertiesFromJson(Map json) => BarChartProperties(
  max: (json['max'] as num?)?.toDouble() ?? 0,
  color: json['color'] == null
      ? const ColorRGBA(r: 0.95, g: 0.76, b: 0.19, a: 1)
      : ColorRGBA.fromJson(json['color']),
  dimmedOpacity: (json['dimmedOpacity'] as num?)?.toDouble() ?? 0.55,
  barGap: (json['barGap'] as num?)?.toDouble() ?? 3,
  barRadius: (json['barRadius'] as num?)?.toDouble() ?? 1,
  emptyColor: json['emptyColor'] == null
      ? const ColorRGBA(r: 0.23, g: 0.25, b: 0.28, a: 1)
      : ColorRGBA.fromJson(json['emptyColor']),
  emptyHeight: (json['emptyHeight'] as num?)?.toDouble() ?? 2,
  gridLines: (json['gridLines'] as num?)?.toInt() ?? 3,
  gridColor: json['gridColor'] == null
      ? const ColorRGBA(r: 0.17, g: 0.19, b: 0.22, a: 1)
      : ColorRGBA.fromJson(json['gridColor']),
  gridLabels: (json['gridLabels'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  gridLabelWidth: (json['gridLabelWidth'] as num?)?.toDouble() ?? 40,
  baselineColor: json['baselineColor'] == null
      ? const ColorRGBA(r: 0.23, g: 0.25, b: 0.28, a: 1)
      : ColorRGBA.fromJson(json['baselineColor']),
  labelFontFamily: json['labelFontFamily'] as String? ?? 'JetBrains Mono',
  labelFontSize: (json['labelFontSize'] as num?)?.toDouble() ?? 10,
  labelColor: json['labelColor'] == null
      ? const ColorRGBA(r: 0.42, g: 0.45, b: 0.49, a: 1)
      : ColorRGBA.fromJson(json['labelColor']),
  highlightLabelColor: json['highlightLabelColor'] == null
      ? const ColorRGBA(r: 0.91, g: 0.92, b: 0.93, a: 1)
      : ColorRGBA.fromJson(json['highlightLabelColor']),
  labelGap: (json['labelGap'] as num?)?.toDouble() ?? 6,
  animate: json['animate'] as bool? ?? true,
  animationDurationInMillis:
      (json['animationDurationInMillis'] as num?)?.toInt() ?? 700,
);

Map<String, dynamic> _$BarChartPropertiesToJson(BarChartProperties instance) =>
    <String, dynamic>{
      'max': instance.max,
      'color': instance.color.toJson(),
      'dimmedOpacity': instance.dimmedOpacity,
      'barGap': instance.barGap,
      'barRadius': instance.barRadius,
      'emptyColor': instance.emptyColor.toJson(),
      'emptyHeight': instance.emptyHeight,
      'gridLines': instance.gridLines,
      'gridColor': instance.gridColor.toJson(),
      'gridLabels': instance.gridLabels,
      'gridLabelWidth': instance.gridLabelWidth,
      'baselineColor': instance.baselineColor.toJson(),
      'labelFontFamily': instance.labelFontFamily,
      'labelFontSize': instance.labelFontSize,
      'labelColor': instance.labelColor.toJson(),
      'highlightLabelColor': instance.highlightLabelColor.toJson(),
      'labelGap': instance.labelGap,
      'animate': instance.animate,
      'animationDurationInMillis': instance.animationDurationInMillis,
    };
