// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loading_indicator_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$LoadingIndicatorNodeOmitDefaults(
  LoadingIndicatorNode instance,
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
  if (isJsonDefault(instance.semanticLabel, '')) json.remove('semanticLabel');
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

Map<String, dynamic> _$MaterialLoadingIndicatorPropertiesOmitDefaults(
  MaterialLoadingIndicatorProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.backgroundColor, ColorRGBA.transparent))
    json.remove('backgroundColor');
  if (isJsonDefault(instance.strokeWidth, 4)) json.remove('strokeWidth');
  if (isJsonDefault(instance.strokeCap, StrokeCapEnum.square))
    json.remove('strokeCap');
  return json;
}

Map<String, dynamic> _$CupertinoLoadingIndicatorPropertiesOmitDefaults(
  CupertinoLoadingIndicatorProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.radius, 10)) json.remove('radius');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoadingIndicatorNode _$LoadingIndicatorNodeFromJson(Map json) =>
    LoadingIndicatorNode(
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
        properties: LoadingIndicatorProperties.fromJson(
          json['properties'] as Map,
        ),
      )
      ..variables =
          (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {}
      ..multipleVariables =
          (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(
              k as String,
              (e as List<dynamic>).map((e) => e as String).toList(),
            ),
          ) ??
          {}
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
      ..semanticLabel = json['semanticLabel'] as String? ?? ''
      ..loopAnimation = json['loopAnimation'] == null
          ? null
          : LoopAnimation.fromJson(json['loopAnimation'] as Map)
      ..type = json['type'] as String;

Map<String, dynamic> _$LoadingIndicatorNodeToJson(
  LoadingIndicatorNode instance,
) => <String, dynamic>{
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
  'semanticLabel': instance.semanticLabel,
  'loopAnimation': ?instance.loopAnimation?.toJson(),
  'enabled': instance.enabled,
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

MaterialLoadingIndicatorProperties _$MaterialLoadingIndicatorPropertiesFromJson(
  Map json,
) => MaterialLoadingIndicatorProperties(
  color: ColorRGBA.fromJson(json['color']),
  backgroundColor: json['backgroundColor'] == null
      ? ColorRGBA.transparent
      : ColorRGBA.fromJson(json['backgroundColor']),
  strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 4,
  value: (json['value'] as num?)?.toDouble(),
  strokeCap:
      $enumDecodeNullable(_$StrokeCapEnumEnumMap, json['strokeCap']) ??
      StrokeCapEnum.square,
  strokeAlign: (json['strokeAlign'] as num?)?.toDouble(),
  trackGap: (json['trackGap'] as num?)?.toDouble(),
)..type = json['type'] as String;

Map<String, dynamic> _$MaterialLoadingIndicatorPropertiesToJson(
  MaterialLoadingIndicatorProperties instance,
) => <String, dynamic>{
  'type': instance.type,
  'color': instance.color.toJson(),
  'backgroundColor': instance.backgroundColor.toJson(),
  'strokeWidth': instance.strokeWidth,
  'value': ?instance.value,
  'strokeCap': _$StrokeCapEnumEnumMap[instance.strokeCap]!,
  'strokeAlign': ?instance.strokeAlign,
  'trackGap': ?instance.trackGap,
};

const _$StrokeCapEnumEnumMap = {
  StrokeCapEnum.round: 'round',
  StrokeCapEnum.none: 'none',
  StrokeCapEnum.square: 'square',
};

CupertinoLoadingIndicatorProperties
_$CupertinoLoadingIndicatorPropertiesFromJson(Map json) =>
    CupertinoLoadingIndicatorProperties(
      color: ColorRGBA.fromJson(json['color']),
      radius: (json['radius'] as num?)?.toDouble() ?? 10,
    )..type = json['type'] as String;

Map<String, dynamic> _$CupertinoLoadingIndicatorPropertiesToJson(
  CupertinoLoadingIndicatorProperties instance,
) => <String, dynamic>{
  'type': instance.type,
  'color': instance.color.toJson(),
  'radius': instance.radius,
};
