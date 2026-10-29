// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variance_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$VarianceNodeOmitDefaults(
  VarianceNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.properties, const VarianceProperties()))
    json.remove('properties');
  if (isJsonDefault(instance.ephemeral, false)) json.remove('ephemeral');
  if (isJsonDefault(instance.allowedTypes, <String>[]))
    json.remove('allowedTypes');
  if (isJsonDefault(instance.deniedTypes, <String>[]))
    json.remove('deniedTypes');
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

Map<String, dynamic> _$VariantOmitDefaults(
  Variant instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.skeleton, false)) json.remove('skeleton');
  return json;
}

Map<String, dynamic> _$VariancePropertiesOmitDefaults(
  VarianceProperties instance,
  Map<String, dynamic> json,
) {
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VarianceNode _$VarianceNodeFromJson(Map json) =>
    VarianceNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        variants: (json['variants'] as List<dynamic>)
            .map((e) => Variant.fromJson(e as Map))
            .toList(),
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
        currentVariantId: json['currentVariantId'] as String?,
        maxAllowedSize: json['maxAllowedSize'] == null
            ? null
            : SizeC.fromJson(json['maxAllowedSize'] as Map),
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
        properties: json['properties'] == null
            ? null
            : VarianceProperties.fromJson(
                Map<String, dynamic>.from(json['properties'] as Map),
              ),
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
      ..motion = json['motion'] == null
          ? null
          : MotionModel.fromJson(json['motion'] as Map)
      ..ephemeral = json['ephemeral'] as bool? ?? false
      ..allowedTypes =
          (json['allowedTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          []
      ..deniedTypes =
          (json['deniedTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          []
      ..type = json['type'] as String;

Map<String, dynamic> _$VarianceNodeToJson(VarianceNode instance) =>
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
      'motion': ?instance.motion?.toJson(),
      'ephemeral': instance.ephemeral,
      'allowedTypes': instance.allowedTypes,
      'deniedTypes': instance.deniedTypes,
      'maxAllowedSize': ?instance.maxAllowedSize?.toJson(),
      'type': instance.type,
      'currentVariantId': instance.currentVariantId,
      'variants': instance.variants.map((e) => e.toJson()).toList(),
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

Variant _$VariantFromJson(Map json) => Variant(
  id: json['id'] as String,
  name: json['name'] as String,
  children: (json['children'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  breakpoint: $enumDecodeNullable(
    _$ScreenBreakpointEnumMap,
    json['breakpoint'],
  ),
  overrides: (json['overrides'] as Map?)?.map(
    (k, e) => MapEntry(k as String, Map<String, dynamic>.from(e as Map)),
  ),
  skeleton: json['skeleton'] as bool? ?? false,
);

Map<String, dynamic> _$VariantToJson(Variant instance) => <String, dynamic>{
  'name': instance.name,
  'id': instance.id,
  'children': instance.children,
  'breakpoint': ?_$ScreenBreakpointEnumMap[instance.breakpoint],
  'overrides': ?instance.overrides,
  'skeleton': instance.skeleton,
};

const _$ScreenBreakpointEnumMap = {
  ScreenBreakpoint.mobile: 'mobile',
  ScreenBreakpoint.tablet: 'tablet',
  ScreenBreakpoint.desktop: 'desktop',
};

VarianceProperties _$VariancePropertiesFromJson(Map json) =>
    VarianceProperties();

Map<String, dynamic> _$VariancePropertiesToJson(VarianceProperties instance) =>
    <String, dynamic>{};
