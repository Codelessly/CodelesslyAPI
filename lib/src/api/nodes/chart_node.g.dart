// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ChartNodeOmitDefaults(
  ChartNode instance,
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

Map<String, dynamic> _$ChartTextStyleOmitDefaults(
  ChartTextStyle instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.fontSize, 10)) json.remove('fontSize');
  if (isJsonDefault(instance.color, ColorRGBA.black54)) json.remove('color');
  if (isJsonDefault(instance.fontWeight, 400)) json.remove('fontWeight');
  return json;
}

Map<String, dynamic> _$ChartLabelOmitDefaults(
  ChartLabel instance,
  Map<String, dynamic> json,
) {
  return json;
}

Map<String, dynamic> _$ChartRangeOmitDefaults(
  ChartRange instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.color, ColorRGBA.black10)) json.remove('color');
  return json;
}

Map<String, dynamic> _$ChartMarkerOmitDefaults(
  ChartMarker instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.label, '')) json.remove('label');
  if (isJsonDefault(instance.color, ColorRGBA.black)) json.remove('color');
  if (isJsonDefault(instance.position, ChartMarkerPosition.above))
    json.remove('position');
  return json;
}

Map<String, dynamic> _$ChartPropertiesOmitDefaults(
  ChartProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.points, const [])) json.remove('points');
  if (isJsonDefault(instance.xMin, 0)) json.remove('xMin');
  if (isJsonDefault(instance.xMax, 1)) json.remove('xMax');
  if (isJsonDefault(instance.plotInset, 8)) json.remove('plotInset');
  if (isJsonDefault(instance.lineColor, kChartDefaultLineColor))
    json.remove('lineColor');
  if (isJsonDefault(instance.lineWidth, 2)) json.remove('lineWidth');
  if (isJsonDefault(instance.smooth, false)) json.remove('smooth');
  if (isJsonDefault(instance.gridColor, ColorRGBA.black10))
    json.remove('gridColor');
  if (isJsonDefault(instance.xLabels, const [])) json.remove('xLabels');
  if (isJsonDefault(instance.gridLabels, const [])) json.remove('gridLabels');
  if (isJsonDefault(instance.labelStyle, const ChartTextStyle()))
    json.remove('labelStyle');
  if (isJsonDefault(instance.labelHeight, 16)) json.remove('labelHeight');
  if (isJsonDefault(instance.ranges, const [])) json.remove('ranges');
  if (isJsonDefault(instance.markers, const [])) json.remove('markers');
  if (isJsonDefault(instance.markerRadius, 3.5)) json.remove('markerRadius');
  if (isJsonDefault(
    instance.markerLabelStyle,
    const ChartTextStyle(fontWeight: 700),
  ))
    json.remove('markerLabelStyle');
  if (isJsonDefault(instance.referenceColor, kChartDefaultReferenceColor))
    json.remove('referenceColor');
  if (isJsonDefault(instance.referenceWidth, 1.5))
    json.remove('referenceWidth');
  if (isJsonDefault(instance.referenceDashed, true))
    json.remove('referenceDashed');
  if (isJsonDefault(instance.selectable, true)) json.remove('selectable');
  if (isJsonDefault(instance.selectionStep, 1)) json.remove('selectionStep');
  if (isJsonDefault(instance.selectionColor, ColorRGBA.black10))
    json.remove('selectionColor');
  if (isJsonDefault(instance.selectionLineColor, ColorRGBA.black))
    json.remove('selectionLineColor');
  if (isJsonDefault(instance.selectionLineWidth, 1.5))
    json.remove('selectionLineWidth');
  if (isJsonDefault(instance.selectionDotRadius, 6.5))
    json.remove('selectionDotRadius');
  if (isJsonDefault(instance.selectionDotColor, ColorRGBA.white))
    json.remove('selectionDotColor');
  if (isJsonDefault(instance.selectionDotStrokeColor, ColorRGBA.black))
    json.remove('selectionDotStrokeColor');
  if (isJsonDefault(instance.selectionDotStrokeWidth, 2.5))
    json.remove('selectionDotStrokeWidth');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartNode _$ChartNodeFromJson(Map json) =>
    ChartNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
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
        constraints: json['constraints'] == null
            ? const BoxConstraintsModel()
            : BoxConstraintsModel.fromJson(json['constraints'] as Map),
        aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
        edgePins: json['edgePins'] == null
            ? EdgePinsModel.standard
            : EdgePinsModel.fromJson(
                Map<String, dynamic>.from(json['edgePins'] as Map),
              ),
        positioningMode:
            $enumDecodeNullable(
              _$PositioningModeEnumMap,
              json['positioningMode'],
            ) ??
            PositioningMode.align,
        properties: ChartProperties.fromJson(json['properties'] as Map),
        selectedX: (json['selectedX'] as num?)?.toDouble(),
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
      ..type = json['type'] as String;

Map<String, dynamic> _$ChartNodeToJson(ChartNode instance) => <String, dynamic>{
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
  'interactionStates': instance.interactionStates.map(
    (k, e) => MapEntry(_$InteractionStateEnumMap[k]!, e),
  ),
  'tooltip': instance.tooltip,
  'zoomable': instance.zoomable,
  'enabled': instance.enabled,
  'type': instance.type,
  'properties': instance.properties.toJson(),
  'selectedX': ?instance.selectedX,
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

ChartTextStyle _$ChartTextStyleFromJson(Map json) => ChartTextStyle(
  fontSize: (json['fontSize'] as num?)?.toDouble() ?? 10,
  color: json['color'] == null
      ? ColorRGBA.black54
      : ColorRGBA.fromJson(json['color']),
  fontFamily: json['fontFamily'] as String?,
  fontWeight: (json['fontWeight'] as num?)?.toInt() ?? 400,
  height: (json['height'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ChartTextStyleToJson(ChartTextStyle instance) =>
    <String, dynamic>{
      'fontSize': instance.fontSize,
      'color': instance.color.toJson(),
      'fontFamily': ?instance.fontFamily,
      'fontWeight': instance.fontWeight,
      'height': ?instance.height,
    };

ChartLabel _$ChartLabelFromJson(Map json) => ChartLabel(
  x: (json['x'] as num).toDouble(),
  label: json['label'] as String,
);

Map<String, dynamic> _$ChartLabelToJson(ChartLabel instance) =>
    <String, dynamic>{'x': instance.x, 'label': instance.label};

ChartRange _$ChartRangeFromJson(Map json) => ChartRange(
  from: (json['from'] as num).toDouble(),
  to: (json['to'] as num).toDouble(),
  color: json['color'] == null
      ? ColorRGBA.black10
      : ColorRGBA.fromJson(json['color']),
);

Map<String, dynamic> _$ChartRangeToJson(ChartRange instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'color': instance.color.toJson(),
    };

ChartMarker _$ChartMarkerFromJson(Map json) => ChartMarker(
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num?)?.toDouble(),
  label: json['label'] as String? ?? '',
  color: json['color'] == null
      ? ColorRGBA.black
      : ColorRGBA.fromJson(json['color']),
  position:
      $enumDecodeNullable(_$ChartMarkerPositionEnumMap, json['position']) ??
      ChartMarkerPosition.above,
);

Map<String, dynamic> _$ChartMarkerToJson(ChartMarker instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': ?instance.y,
      'label': instance.label,
      'color': instance.color.toJson(),
      'position': _$ChartMarkerPositionEnumMap[instance.position]!,
    };

const _$ChartMarkerPositionEnumMap = {
  ChartMarkerPosition.above: 'above',
  ChartMarkerPosition.below: 'below',
};

ChartProperties _$ChartPropertiesFromJson(Map json) => ChartProperties(
  points:
      (json['points'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      const [],
  xMin: (json['xMin'] as num?)?.toDouble() ?? 0,
  xMax: (json['xMax'] as num?)?.toDouble() ?? 1,
  yMin: (json['yMin'] as num?)?.toDouble(),
  yMax: (json['yMax'] as num?)?.toDouble(),
  plotInset: (json['plotInset'] as num?)?.toDouble() ?? 8,
  lineColor: json['lineColor'] == null
      ? kChartDefaultLineColor
      : ColorRGBA.fromJson(json['lineColor']),
  lineWidth: (json['lineWidth'] as num?)?.toDouble() ?? 2,
  fillColor: json['fillColor'] == null
      ? null
      : ColorRGBA.fromJson(json['fillColor']),
  smooth: json['smooth'] as bool? ?? false,
  gridStepX: (json['gridStepX'] as num?)?.toDouble(),
  gridColor: json['gridColor'] == null
      ? ColorRGBA.black10
      : ColorRGBA.fromJson(json['gridColor']),
  axisColor: json['axisColor'] == null
      ? null
      : ColorRGBA.fromJson(json['axisColor']),
  xLabels:
      (json['xLabels'] as List<dynamic>?)
          ?.map((e) => ChartLabel.fromJson(e as Map))
          .toList() ??
      const [],
  gridLabels:
      (json['gridLabels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  labelStyle: json['labelStyle'] == null
      ? const ChartTextStyle()
      : ChartTextStyle.fromJson(json['labelStyle'] as Map),
  labelHeight: (json['labelHeight'] as num?)?.toDouble() ?? 16,
  ranges:
      (json['ranges'] as List<dynamic>?)
          ?.map((e) => ChartRange.fromJson(e as Map))
          .toList() ??
      const [],
  markers:
      (json['markers'] as List<dynamic>?)
          ?.map((e) => ChartMarker.fromJson(e as Map))
          .toList() ??
      const [],
  markerRadius: (json['markerRadius'] as num?)?.toDouble() ?? 3.5,
  markerLabelStyle: json['markerLabelStyle'] == null
      ? const ChartTextStyle(fontWeight: 700)
      : ChartTextStyle.fromJson(json['markerLabelStyle'] as Map),
  referenceX: (json['referenceX'] as num?)?.toDouble(),
  referenceColor: json['referenceColor'] == null
      ? kChartDefaultReferenceColor
      : ColorRGBA.fromJson(json['referenceColor']),
  referenceWidth: (json['referenceWidth'] as num?)?.toDouble() ?? 1.5,
  referenceDashed: json['referenceDashed'] as bool? ?? true,
  selectable: json['selectable'] as bool? ?? true,
  selectionStep: (json['selectionStep'] as num?)?.toDouble() ?? 1,
  selectionMin: (json['selectionMin'] as num?)?.toDouble(),
  selectionMax: (json['selectionMax'] as num?)?.toDouble(),
  selectionColor: json['selectionColor'] == null
      ? ColorRGBA.black10
      : ColorRGBA.fromJson(json['selectionColor']),
  selectionLineColor: json['selectionLineColor'] == null
      ? ColorRGBA.black
      : ColorRGBA.fromJson(json['selectionLineColor']),
  selectionLineWidth: (json['selectionLineWidth'] as num?)?.toDouble() ?? 1.5,
  selectionDotRadius: (json['selectionDotRadius'] as num?)?.toDouble() ?? 6.5,
  selectionDotColor: json['selectionDotColor'] == null
      ? ColorRGBA.white
      : ColorRGBA.fromJson(json['selectionDotColor']),
  selectionDotStrokeColor: json['selectionDotStrokeColor'] == null
      ? ColorRGBA.black
      : ColorRGBA.fromJson(json['selectionDotStrokeColor']),
  selectionDotStrokeWidth:
      (json['selectionDotStrokeWidth'] as num?)?.toDouble() ?? 2.5,
);

Map<String, dynamic> _$ChartPropertiesToJson(ChartProperties instance) =>
    <String, dynamic>{
      'points': instance.points,
      'xMin': instance.xMin,
      'xMax': instance.xMax,
      'yMin': ?instance.yMin,
      'yMax': ?instance.yMax,
      'plotInset': instance.plotInset,
      'lineColor': instance.lineColor.toJson(),
      'lineWidth': instance.lineWidth,
      'fillColor': ?instance.fillColor?.toJson(),
      'smooth': instance.smooth,
      'gridStepX': ?instance.gridStepX,
      'gridColor': instance.gridColor.toJson(),
      'axisColor': ?instance.axisColor?.toJson(),
      'xLabels': instance.xLabels.map((e) => e.toJson()).toList(),
      'gridLabels': instance.gridLabels,
      'labelStyle': instance.labelStyle.toJson(),
      'labelHeight': instance.labelHeight,
      'ranges': instance.ranges.map((e) => e.toJson()).toList(),
      'markers': instance.markers.map((e) => e.toJson()).toList(),
      'markerRadius': instance.markerRadius,
      'markerLabelStyle': instance.markerLabelStyle.toJson(),
      'referenceX': ?instance.referenceX,
      'referenceColor': instance.referenceColor.toJson(),
      'referenceWidth': instance.referenceWidth,
      'referenceDashed': instance.referenceDashed,
      'selectable': instance.selectable,
      'selectionStep': instance.selectionStep,
      'selectionMin': ?instance.selectionMin,
      'selectionMax': ?instance.selectionMax,
      'selectionColor': instance.selectionColor.toJson(),
      'selectionLineColor': instance.selectionLineColor.toJson(),
      'selectionLineWidth': instance.selectionLineWidth,
      'selectionDotRadius': instance.selectionDotRadius,
      'selectionDotColor': instance.selectionDotColor.toJson(),
      'selectionDotStrokeColor': instance.selectionDotStrokeColor.toJson(),
      'selectionDotStrokeWidth': instance.selectionDotStrokeWidth,
    };
