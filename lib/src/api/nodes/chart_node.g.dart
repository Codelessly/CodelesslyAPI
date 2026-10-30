// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ChartSeriesOmitDefaults(
  ChartSeries instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.name, '')) json.remove('name');
  if (isJsonDefault(instance.kind, ChartSeriesKind.bar)) json.remove('kind');
  if (isJsonDefault(
    instance.color,
    const ColorRGBA(r: 46 / 255, g: 209 / 255, b: 122 / 255, a: 1),
  ))
    json.remove('color');
  if (isJsonDefault(instance.dashed, false)) json.remove('dashed');
  if (isJsonDefault(instance.strokeWidth, 2)) json.remove('strokeWidth');
  if (isJsonDefault(instance.endDot, false)) json.remove('endDot');
  if (isJsonDefault(instance.fillOpacity, 0.25)) json.remove('fillOpacity');
  return json;
}

Map<String, dynamic> _$ChartReferenceLineOmitDefaults(
  ChartReferenceLine instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.color, const ColorRGBA(r: 1, g: 1, b: 1, a: 0.6)))
    json.remove('color');
  if (isJsonDefault(instance.dashed, true)) json.remove('dashed');
  if (isJsonDefault(instance.strokeWidth, 1.5)) json.remove('strokeWidth');
  return json;
}

Map<String, dynamic> _$ChartNodeOmitDefaults(
  ChartNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.selectedIndex, -1)) json.remove('selectedIndex');
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

Map<String, dynamic> _$ChartPropertiesOmitDefaults(
  ChartProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.chartType, ChartType.bar))
    json.remove('chartType');
  if (isJsonDefault(instance.series, kDefaultChartSeries))
    json.remove('series');
  if (isJsonDefault(instance.labelField, 'label')) json.remove('labelField');
  if (isJsonDefault(instance.sampleData, kDefaultChartSampleData))
    json.remove('sampleData');
  if (isJsonDefault(instance.gridLines, 4)) json.remove('gridLines');
  if (isJsonDefault(
    instance.gridColor,
    const ColorRGBA(r: 41 / 255, g: 46 / 255, b: 51 / 255, a: 1),
  ))
    json.remove('gridColor');
  if (isJsonDefault(instance.showYAxis, true)) json.remove('showYAxis');
  if (isJsonDefault(instance.yAxisWidth, 36)) json.remove('yAxisWidth');
  if (isJsonDefault(instance.showXAxis, true)) json.remove('showXAxis');
  if (isJsonDefault(instance.xLabelEvery, 1)) json.remove('xLabelEvery');
  if (isJsonDefault(
    instance.axisLabelColor,
    const ColorRGBA(r: 112 / 255, g: 120 / 255, b: 130 / 255, a: 1),
  ))
    json.remove('axisLabelColor');
  if (isJsonDefault(instance.axisFontSize, 10)) json.remove('axisFontSize');
  if (isJsonDefault(instance.referenceLines, const []))
    json.remove('referenceLines');
  if (isJsonDefault(instance.barWidthFraction, 0.62))
    json.remove('barWidthFraction');
  if (isJsonDefault(instance.maxBarWidth, 36)) json.remove('maxBarWidth');
  if (isJsonDefault(instance.barGap, 2)) json.remove('barGap');
  if (isJsonDefault(instance.barRadius, 0)) json.remove('barRadius');
  if (isJsonDefault(instance.dashEmpty, true)) json.remove('dashEmpty');
  if (isJsonDefault(
    instance.selectionColor,
    const ColorRGBA(r: 1, g: 212 / 255, b: 0, a: 0.08),
  ))
    json.remove('selectionColor');
  if (isJsonDefault(instance.xSlots, 0)) json.remove('xSlots');
  if (isJsonDefault(instance.startField, 'from')) json.remove('startField');
  if (isJsonDefault(instance.endField, 'to')) json.remove('endField');
  if (isJsonDefault(instance.segmentColorField, 'color'))
    json.remove('segmentColorField');
  if (isJsonDefault(instance.domainMin, 0)) json.remove('domainMin');
  if (isJsonDefault(instance.domainMax, 100)) json.remove('domainMax');
  if (isJsonDefault(
    instance.trackColor,
    const ColorRGBA(r: 18 / 255, g: 19 / 255, b: 22 / 255, a: 1),
  ))
    json.remove('trackColor');
  if (isJsonDefault(instance.divisions, 8)) json.remove('divisions');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartSeries _$ChartSeriesFromJson(Map json) => ChartSeries(
  field: json['field'] as String,
  name: json['name'] as String? ?? '',
  kind:
      $enumDecodeNullable(_$ChartSeriesKindEnumMap, json['kind']) ??
      ChartSeriesKind.bar,
  color: json['color'] == null
      ? const ColorRGBA(r: 46 / 255, g: 209 / 255, b: 122 / 255, a: 1)
      : ColorRGBA.fromJson(json['color']),
  colorField: json['colorField'] as String?,
  stack: json['stack'] as String?,
  dashed: json['dashed'] as bool? ?? false,
  strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2,
  endDot: json['endDot'] as bool? ?? false,
  fillTo: json['fillTo'] as String?,
  fillOpacity: (json['fillOpacity'] as num?)?.toDouble() ?? 0.25,
);

Map<String, dynamic> _$ChartSeriesToJson(ChartSeries instance) =>
    <String, dynamic>{
      'field': instance.field,
      'name': instance.name,
      'kind': _$ChartSeriesKindEnumMap[instance.kind]!,
      'color': instance.color.toJson(),
      'colorField': ?instance.colorField,
      'stack': ?instance.stack,
      'dashed': instance.dashed,
      'strokeWidth': instance.strokeWidth,
      'endDot': instance.endDot,
      'fillTo': ?instance.fillTo,
      'fillOpacity': instance.fillOpacity,
    };

const _$ChartSeriesKindEnumMap = {
  ChartSeriesKind.bar: 'bar',
  ChartSeriesKind.line: 'line',
  ChartSeriesKind.area: 'area',
  ChartSeriesKind.tick: 'tick',
};

ChartReferenceLine _$ChartReferenceLineFromJson(Map json) => ChartReferenceLine(
  value: (json['value'] as num).toDouble(),
  color: json['color'] == null
      ? const ColorRGBA(r: 1, g: 1, b: 1, a: 0.6)
      : ColorRGBA.fromJson(json['color']),
  dashed: json['dashed'] as bool? ?? true,
  strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 1.5,
);

Map<String, dynamic> _$ChartReferenceLineToJson(ChartReferenceLine instance) =>
    <String, dynamic>{
      'value': instance.value,
      'color': instance.color.toJson(),
      'dashed': instance.dashed,
      'strokeWidth': instance.strokeWidth,
    };

ChartNode _$ChartNodeFromJson(Map json) =>
    ChartNode(
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
        selectedIndex: (json['selectedIndex'] as num?)?.toInt() ?? -1,
        properties: ChartProperties.fromJson(json['properties'] as Map),
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
      ..type = json['type'] as String;

Map<String, dynamic> _$ChartNodeToJson(ChartNode instance) => <String, dynamic>{
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
  'type': instance.type,
  'properties': instance.properties.toJson(),
  'selectedIndex': instance.selectedIndex,
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

ChartProperties _$ChartPropertiesFromJson(Map json) => ChartProperties(
  chartType:
      $enumDecodeNullable(_$ChartTypeEnumMap, json['chartType']) ??
      ChartType.bar,
  series:
      (json['series'] as List<dynamic>?)
          ?.map((e) => ChartSeries.fromJson(e as Map))
          .toList() ??
      kDefaultChartSeries,
  labelField: json['labelField'] as String? ?? 'label',
  sampleData:
      (json['sampleData'] as List<dynamic>?)
          ?.map((e) => Map<String, Object?>.from(e as Map))
          .toList() ??
      kDefaultChartSampleData,
  minY: (json['minY'] as num?)?.toDouble(),
  maxY: (json['maxY'] as num?)?.toDouble(),
  gridLines: (json['gridLines'] as num?)?.toInt() ?? 4,
  gridColor: json['gridColor'] == null
      ? const ColorRGBA(r: 41 / 255, g: 46 / 255, b: 51 / 255, a: 1)
      : ColorRGBA.fromJson(json['gridColor']),
  showYAxis: json['showYAxis'] as bool? ?? true,
  yAxisWidth: (json['yAxisWidth'] as num?)?.toDouble() ?? 36,
  showXAxis: json['showXAxis'] as bool? ?? true,
  xLabelEvery: (json['xLabelEvery'] as num?)?.toInt() ?? 1,
  axisLabelColor: json['axisLabelColor'] == null
      ? const ColorRGBA(r: 112 / 255, g: 120 / 255, b: 130 / 255, a: 1)
      : ColorRGBA.fromJson(json['axisLabelColor']),
  axisFontSize: (json['axisFontSize'] as num?)?.toDouble() ?? 10,
  axisFontFamily: json['axisFontFamily'] as String?,
  referenceLines:
      (json['referenceLines'] as List<dynamic>?)
          ?.map((e) => ChartReferenceLine.fromJson(e as Map))
          .toList() ??
      const [],
  barWidthFraction: (json['barWidthFraction'] as num?)?.toDouble() ?? 0.62,
  maxBarWidth: (json['maxBarWidth'] as num?)?.toDouble() ?? 36,
  barGap: (json['barGap'] as num?)?.toDouble() ?? 2,
  barRadius: (json['barRadius'] as num?)?.toDouble() ?? 0,
  dashEmpty: json['dashEmpty'] as bool? ?? true,
  selectionColor: json['selectionColor'] == null
      ? const ColorRGBA(r: 1, g: 212 / 255, b: 0, a: 0.08)
      : ColorRGBA.fromJson(json['selectionColor']),
  xSlots: (json['xSlots'] as num?)?.toInt() ?? 0,
  startField: json['startField'] as String? ?? 'from',
  endField: json['endField'] as String? ?? 'to',
  segmentColorField: json['segmentColorField'] as String? ?? 'color',
  domainMin: (json['domainMin'] as num?)?.toDouble() ?? 0,
  domainMax: (json['domainMax'] as num?)?.toDouble() ?? 100,
  nowValue: (json['nowValue'] as num?)?.toDouble(),
  nowColor: json['nowColor'] == null
      ? null
      : ColorRGBA.fromJson(json['nowColor']),
  trackColor: json['trackColor'] == null
      ? const ColorRGBA(r: 18 / 255, g: 19 / 255, b: 22 / 255, a: 1)
      : ColorRGBA.fromJson(json['trackColor']),
  divisions: (json['divisions'] as num?)?.toInt() ?? 8,
);

Map<String, dynamic> _$ChartPropertiesToJson(ChartProperties instance) =>
    <String, dynamic>{
      'chartType': _$ChartTypeEnumMap[instance.chartType]!,
      'series': instance.series.map((e) => e.toJson()).toList(),
      'labelField': instance.labelField,
      'sampleData': instance.sampleData,
      'minY': ?instance.minY,
      'maxY': ?instance.maxY,
      'gridLines': instance.gridLines,
      'gridColor': instance.gridColor.toJson(),
      'showYAxis': instance.showYAxis,
      'yAxisWidth': instance.yAxisWidth,
      'showXAxis': instance.showXAxis,
      'xLabelEvery': instance.xLabelEvery,
      'axisLabelColor': instance.axisLabelColor.toJson(),
      'axisFontSize': instance.axisFontSize,
      'axisFontFamily': ?instance.axisFontFamily,
      'referenceLines': instance.referenceLines.map((e) => e.toJson()).toList(),
      'barWidthFraction': instance.barWidthFraction,
      'maxBarWidth': instance.maxBarWidth,
      'barGap': instance.barGap,
      'barRadius': instance.barRadius,
      'dashEmpty': instance.dashEmpty,
      'selectionColor': instance.selectionColor.toJson(),
      'xSlots': instance.xSlots,
      'startField': instance.startField,
      'endField': instance.endField,
      'segmentColorField': instance.segmentColorField,
      'domainMin': instance.domainMin,
      'domainMax': instance.domainMax,
      'nowValue': ?instance.nowValue,
      'nowColor': ?instance.nowColor?.toJson(),
      'trackColor': instance.trackColor.toJson(),
      'divisions': instance.divisions,
    };

const _$ChartTypeEnumMap = {
  ChartType.bar: 'bar',
  ChartType.line: 'line',
  ChartType.timeline: 'timeline',
};
