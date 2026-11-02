// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_chart_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$LineChartNodeOmitDefaults(
  LineChartNode instance,
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

Map<String, dynamic> _$LineChartPropertiesOmitDefaults(
  LineChartProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.xField, 'x')) json.remove('xField');
  if (isJsonDefault(instance.yField, 'y')) json.remove('yField');
  if (isJsonDefault(instance.padLeft, 44)) json.remove('padLeft');
  if (isJsonDefault(instance.padRight, 14)) json.remove('padRight');
  if (isJsonDefault(instance.padTop, 30)) json.remove('padTop');
  if (isJsonDefault(instance.padBottom, 30)) json.remove('padBottom');
  if (isJsonDefault(instance.smooth, false)) json.remove('smooth');
  if (isJsonDefault(instance.lineColor, ColorRGBA.black))
    json.remove('lineColor');
  if (isJsonDefault(instance.lineWidth, 2)) json.remove('lineWidth');
  if (isJsonDefault(instance.areaTopColor, ColorRGBA.black10))
    json.remove('areaTopColor');
  if (isJsonDefault(instance.areaBottomColor, ColorRGBA.transparent))
    json.remove('areaBottomColor');
  if (isJsonDefault(instance.gridColor, ColorRGBA.black10))
    json.remove('gridColor');
  if (isJsonDefault(instance.zeroLineColor, ColorRGBA.black54))
    json.remove('zeroLineColor');
  if (isJsonDefault(instance.axisColor, ColorRGBA.black))
    json.remove('axisColor');
  if (isJsonDefault(instance.markerHollowColor, ColorRGBA.white))
    json.remove('markerHollowColor');
  if (isJsonDefault(instance.tagBackground, ColorRGBA.black))
    json.remove('tagBackground');
  if (isJsonDefault(instance.cursorColor, ColorRGBA.black))
    json.remove('cursorColor');
  if (isJsonDefault(instance.cursorRingFill, ColorRGBA.white))
    json.remove('cursorRingFill');
  if (isJsonDefault(instance.tooltipBackground, ColorRGBA.black))
    json.remove('tooltipBackground');
  if (isJsonDefault(instance.tooltipShadowColor, ColorRGBA.transparent))
    json.remove('tooltipShadowColor');
  if (isJsonDefault(instance.yAxisTitle, '')) json.remove('yAxisTitle');
  if (isJsonDefault(instance.scrubEnabled, false)) json.remove('scrubEnabled');
  if (isJsonDefault(instance.scrubStep, 1)) json.remove('scrubStep');
  if (isJsonDefault(instance.tooltipXFormat, 'h:mm a'))
    json.remove('tooltipXFormat');
  if (isJsonDefault(instance.tooltipYScale, 1)) json.remove('tooltipYScale');
  if (isJsonDefault(instance.tooltipYDecimals, 1))
    json.remove('tooltipYDecimals');
  if (isJsonDefault(instance.tooltipYSuffix, '')) json.remove('tooltipYSuffix');
  if (isJsonDefault(instance.tooltipTrend, false)) json.remove('tooltipTrend');
  if (isJsonDefault(instance.semanticLabel, '')) json.remove('semanticLabel');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineChartNode _$LineChartNodeFromJson(Map json) =>
    LineChartNode(
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
        properties: json['properties'] == null
            ? null
            : LineChartProperties.fromJson(json['properties'] as Map),
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
      ..draggable = json['draggable'] == null
          ? null
          : DraggableModel.fromJson(json['draggable'] as Map)
      ..dropTarget = json['dropTarget'] == null
          ? null
          : DropTargetModel.fromJson(json['dropTarget'] as Map)
      ..motion = json['motion'] == null
          ? null
          : MotionModel.fromJson(json['motion'] as Map)
      ..type = json['type'] as String;

Map<String, dynamic> _$LineChartNodeToJson(LineChartNode instance) =>
    <String, dynamic>{
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
      'draggable': ?instance.draggable?.toJson(),
      'dropTarget': ?instance.dropTarget?.toJson(),
      'enabled': instance.enabled,
      'motion': ?instance.motion?.toJson(),
      'type': instance.type,
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

LineChartProperties _$LineChartPropertiesFromJson(Map json) =>
    LineChartProperties(
      xField: json['xField'] as String? ?? 'x',
      yField: json['yField'] as String? ?? 'y',
      xMin: (json['xMin'] as num?)?.toDouble(),
      xMax: (json['xMax'] as num?)?.toDouble(),
      yMin: (json['yMin'] as num?)?.toDouble(),
      yMax: (json['yMax'] as num?)?.toDouble(),
      padLeft: (json['padLeft'] as num?)?.toDouble() ?? 44,
      padRight: (json['padRight'] as num?)?.toDouble() ?? 14,
      padTop: (json['padTop'] as num?)?.toDouble() ?? 30,
      padBottom: (json['padBottom'] as num?)?.toDouble() ?? 30,
      smooth: json['smooth'] as bool? ?? false,
      lineColor: json['lineColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['lineColor']),
      lineWidth: (json['lineWidth'] as num?)?.toDouble() ?? 2,
      areaTopColor: json['areaTopColor'] == null
          ? ColorRGBA.black10
          : ColorRGBA.fromJson(json['areaTopColor']),
      areaBottomColor: json['areaBottomColor'] == null
          ? ColorRGBA.transparent
          : ColorRGBA.fromJson(json['areaBottomColor']),
      gridColor: json['gridColor'] == null
          ? ColorRGBA.black10
          : ColorRGBA.fromJson(json['gridColor']),
      zeroLineColor: json['zeroLineColor'] == null
          ? ColorRGBA.black54
          : ColorRGBA.fromJson(json['zeroLineColor']),
      axisColor: json['axisColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['axisColor']),
      markerHollowColor: json['markerHollowColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['markerHollowColor']),
      tagBackground: json['tagBackground'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['tagBackground']),
      cursorColor: json['cursorColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['cursorColor']),
      cursorRingFill: json['cursorRingFill'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['cursorRingFill']),
      tooltipBackground: json['tooltipBackground'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['tooltipBackground']),
      tooltipShadowColor: json['tooltipShadowColor'] == null
          ? ColorRGBA.transparent
          : ColorRGBA.fromJson(json['tooltipShadowColor']),
      yAxisTitle: json['yAxisTitle'] as String? ?? '',
      axisLabelStyle: json['axisLabelStyle'] == null
          ? null
          : TextProp.fromJson(json['axisLabelStyle'] as Map),
      axisTitleStyle: json['axisTitleStyle'] == null
          ? null
          : TextProp.fromJson(json['axisTitleStyle'] as Map),
      markerLabelStyle: json['markerLabelStyle'] == null
          ? null
          : TextProp.fromJson(json['markerLabelStyle'] as Map),
      tagTextStyle: json['tagTextStyle'] == null
          ? null
          : TextProp.fromJson(json['tagTextStyle'] as Map),
      tooltipLabelStyle: json['tooltipLabelStyle'] == null
          ? null
          : TextProp.fromJson(json['tooltipLabelStyle'] as Map),
      tooltipValueStyle: json['tooltipValueStyle'] == null
          ? null
          : TextProp.fromJson(json['tooltipValueStyle'] as Map),
      scrubEnabled: json['scrubEnabled'] as bool? ?? false,
      scrubStep: (json['scrubStep'] as num?)?.toDouble() ?? 1,
      tooltipXFormat: json['tooltipXFormat'] as String? ?? 'h:mm a',
      tooltipYScale: (json['tooltipYScale'] as num?)?.toDouble() ?? 1,
      tooltipYDecimals: (json['tooltipYDecimals'] as num?)?.toInt() ?? 1,
      tooltipYSuffix: json['tooltipYSuffix'] as String? ?? '',
      tooltipTrend: json['tooltipTrend'] as bool? ?? false,
      semanticLabel: json['semanticLabel'] as String? ?? '',
    );

Map<String, dynamic> _$LineChartPropertiesToJson(
  LineChartProperties instance,
) => <String, dynamic>{
  'xField': instance.xField,
  'yField': instance.yField,
  'xMin': ?instance.xMin,
  'xMax': ?instance.xMax,
  'yMin': ?instance.yMin,
  'yMax': ?instance.yMax,
  'padLeft': instance.padLeft,
  'padRight': instance.padRight,
  'padTop': instance.padTop,
  'padBottom': instance.padBottom,
  'smooth': instance.smooth,
  'lineColor': instance.lineColor.toJson(),
  'lineWidth': instance.lineWidth,
  'areaTopColor': instance.areaTopColor.toJson(),
  'areaBottomColor': instance.areaBottomColor.toJson(),
  'gridColor': instance.gridColor.toJson(),
  'zeroLineColor': instance.zeroLineColor.toJson(),
  'axisColor': instance.axisColor.toJson(),
  'markerHollowColor': instance.markerHollowColor.toJson(),
  'tagBackground': instance.tagBackground.toJson(),
  'cursorColor': instance.cursorColor.toJson(),
  'cursorRingFill': instance.cursorRingFill.toJson(),
  'tooltipBackground': instance.tooltipBackground.toJson(),
  'tooltipShadowColor': instance.tooltipShadowColor.toJson(),
  'yAxisTitle': instance.yAxisTitle,
  'axisLabelStyle': instance.axisLabelStyle.toJson(),
  'axisTitleStyle': instance.axisTitleStyle.toJson(),
  'markerLabelStyle': instance.markerLabelStyle.toJson(),
  'tagTextStyle': instance.tagTextStyle.toJson(),
  'tooltipLabelStyle': instance.tooltipLabelStyle.toJson(),
  'tooltipValueStyle': instance.tooltipValueStyle.toJson(),
  'scrubEnabled': instance.scrubEnabled,
  'scrubStep': instance.scrubStep,
  'tooltipXFormat': instance.tooltipXFormat,
  'tooltipYScale': instance.tooltipYScale,
  'tooltipYDecimals': instance.tooltipYDecimals,
  'tooltipYSuffix': instance.tooltipYSuffix,
  'tooltipTrend': instance.tooltipTrend,
  'semanticLabel': instance.semanticLabel,
};
