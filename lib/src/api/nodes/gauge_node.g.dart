// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gauge_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$GaugeNodeOmitDefaults(
  GaugeNode instance,
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

Map<String, dynamic> _$GaugeZoneOmitDefaults(
  GaugeZone instance,
  Map<String, dynamic> json,
) {
  return json;
}

Map<String, dynamic> _$GaugePropertiesOmitDefaults(
  GaugeProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.min, 0)) json.remove('min');
  if (isJsonDefault(instance.max, 100)) json.remove('max');
  if (isJsonDefault(instance.startAngle, 150)) json.remove('startAngle');
  if (isJsonDefault(instance.sweepAngle, 240)) json.remove('sweepAngle');
  if (isJsonDefault(instance.thickness, 14)) json.remove('thickness');
  if (isJsonDefault(
    instance.trackColor,
    const ColorRGBA(r: 18 / 255, g: 19 / 255, b: 22 / 255, a: 1),
  ))
    json.remove('trackColor');
  if (isJsonDefault(
    instance.valueColor,
    const ColorRGBA(r: 1, g: 212 / 255, b: 0, a: 1),
  ))
    json.remove('valueColor');
  if (isJsonDefault(instance.colorByZone, true)) json.remove('colorByZone');
  if (isJsonDefault(instance.segments, 40)) json.remove('segments');
  if (isJsonDefault(instance.segmentGap, 0.9)) json.remove('segmentGap');
  if (isJsonDefault(instance.zones, kDefaultGaugeZones)) json.remove('zones');
  if (isJsonDefault(instance.zoneThickness, 4)) json.remove('zoneThickness');
  if (isJsonDefault(instance.zoneOpacity, 0.55)) json.remove('zoneOpacity');
  if (isJsonDefault(instance.majorTicks, 10)) json.remove('majorTicks');
  if (isJsonDefault(instance.minorTicks, 1)) json.remove('minorTicks');
  if (isJsonDefault(
    instance.tickColor,
    const ColorRGBA(r: 163 / 255, g: 171 / 255, b: 178 / 255, a: 1),
  ))
    json.remove('tickColor');
  if (isJsonDefault(instance.labels, const [0, 60, 85, 100]))
    json.remove('labels');
  if (isJsonDefault(
    instance.labelColor,
    const ColorRGBA(r: 112 / 255, g: 120 / 255, b: 130 / 255, a: 1),
  ))
    json.remove('labelColor');
  if (isJsonDefault(instance.labelFontSize, 10)) json.remove('labelFontSize');
  if (isJsonDefault(instance.showTarget, true)) json.remove('showTarget');
  if (isJsonDefault(instance.target, 85)) json.remove('target');
  if (isJsonDefault(
    instance.targetColor,
    const ColorRGBA(r: 232 / 255, g: 235 / 255, b: 237 / 255, a: 1),
  ))
    json.remove('targetColor');
  if (isJsonDefault(instance.showNeedle, true)) json.remove('showNeedle');
  if (isJsonDefault(
    instance.needleColor,
    const ColorRGBA(r: 232 / 255, g: 235 / 255, b: 237 / 255, a: 1),
  ))
    json.remove('needleColor');
  if (isJsonDefault(instance.needleClearance, 0.62))
    json.remove('needleClearance');
  if (isJsonDefault(instance.animate, true)) json.remove('animate');
  if (isJsonDefault(instance.animationDurationInMillis, 420))
    json.remove('animationDurationInMillis');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GaugeNode _$GaugeNodeFromJson(Map json) =>
    GaugeNode(
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
        properties: GaugeProperties.fromJson(json['properties'] as Map),
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

Map<String, dynamic> _$GaugeNodeToJson(GaugeNode instance) => <String, dynamic>{
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
  'value': instance.value,
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

GaugeZone _$GaugeZoneFromJson(Map json) => GaugeZone(
  from: (json['from'] as num).toDouble(),
  to: (json['to'] as num).toDouble(),
  color: ColorRGBA.fromJson(json['color']),
);

Map<String, dynamic> _$GaugeZoneToJson(GaugeZone instance) => <String, dynamic>{
  'from': instance.from,
  'to': instance.to,
  'color': instance.color.toJson(),
};

GaugeProperties _$GaugePropertiesFromJson(Map json) => GaugeProperties(
  min: (json['min'] as num?)?.toDouble() ?? 0,
  max: (json['max'] as num?)?.toDouble() ?? 100,
  startAngle: (json['startAngle'] as num?)?.toDouble() ?? 150,
  sweepAngle: (json['sweepAngle'] as num?)?.toDouble() ?? 240,
  thickness: (json['thickness'] as num?)?.toDouble() ?? 14,
  trackColor: json['trackColor'] == null
      ? const ColorRGBA(r: 18 / 255, g: 19 / 255, b: 22 / 255, a: 1)
      : ColorRGBA.fromJson(json['trackColor']),
  valueColor: json['valueColor'] == null
      ? const ColorRGBA(r: 1, g: 212 / 255, b: 0, a: 1)
      : ColorRGBA.fromJson(json['valueColor']),
  colorByZone: json['colorByZone'] as bool? ?? true,
  segments: (json['segments'] as num?)?.toInt() ?? 40,
  segmentGap: (json['segmentGap'] as num?)?.toDouble() ?? 0.9,
  zones:
      (json['zones'] as List<dynamic>?)
          ?.map((e) => GaugeZone.fromJson(e as Map))
          .toList() ??
      kDefaultGaugeZones,
  zoneThickness: (json['zoneThickness'] as num?)?.toDouble() ?? 4,
  zoneOpacity: (json['zoneOpacity'] as num?)?.toDouble() ?? 0.55,
  majorTicks: (json['majorTicks'] as num?)?.toInt() ?? 10,
  minorTicks: (json['minorTicks'] as num?)?.toInt() ?? 1,
  tickColor: json['tickColor'] == null
      ? const ColorRGBA(r: 163 / 255, g: 171 / 255, b: 178 / 255, a: 1)
      : ColorRGBA.fromJson(json['tickColor']),
  labels:
      (json['labels'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      const [0, 60, 85, 100],
  labelColor: json['labelColor'] == null
      ? const ColorRGBA(r: 112 / 255, g: 120 / 255, b: 130 / 255, a: 1)
      : ColorRGBA.fromJson(json['labelColor']),
  labelFontSize: (json['labelFontSize'] as num?)?.toDouble() ?? 10,
  labelFontFamily: json['labelFontFamily'] as String?,
  showTarget: json['showTarget'] as bool? ?? true,
  target: (json['target'] as num?)?.toDouble() ?? 85,
  targetColor: json['targetColor'] == null
      ? const ColorRGBA(r: 232 / 255, g: 235 / 255, b: 237 / 255, a: 1)
      : ColorRGBA.fromJson(json['targetColor']),
  showNeedle: json['showNeedle'] as bool? ?? true,
  needleColor: json['needleColor'] == null
      ? const ColorRGBA(r: 232 / 255, g: 235 / 255, b: 237 / 255, a: 1)
      : ColorRGBA.fromJson(json['needleColor']),
  needleClearance: (json['needleClearance'] as num?)?.toDouble() ?? 0.62,
  animate: json['animate'] as bool? ?? true,
  animationDurationInMillis:
      (json['animationDurationInMillis'] as num?)?.toInt() ?? 420,
);

Map<String, dynamic> _$GaugePropertiesToJson(GaugeProperties instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'startAngle': instance.startAngle,
      'sweepAngle': instance.sweepAngle,
      'thickness': instance.thickness,
      'trackColor': instance.trackColor.toJson(),
      'valueColor': instance.valueColor.toJson(),
      'colorByZone': instance.colorByZone,
      'segments': instance.segments,
      'segmentGap': instance.segmentGap,
      'zones': instance.zones.map((e) => e.toJson()).toList(),
      'zoneThickness': instance.zoneThickness,
      'zoneOpacity': instance.zoneOpacity,
      'majorTicks': instance.majorTicks,
      'minorTicks': instance.minorTicks,
      'tickColor': instance.tickColor.toJson(),
      'labels': instance.labels,
      'labelColor': instance.labelColor.toJson(),
      'labelFontSize': instance.labelFontSize,
      'labelFontFamily': ?instance.labelFontFamily,
      'showTarget': instance.showTarget,
      'target': instance.target,
      'targetColor': instance.targetColor.toJson(),
      'showNeedle': instance.showNeedle,
      'needleColor': instance.needleColor.toJson(),
      'needleClearance': instance.needleClearance,
      'animate': instance.animate,
      'animationDurationInMillis': instance.animationDurationInMillis,
    };
