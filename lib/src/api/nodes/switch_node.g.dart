// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'switch_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$SwitchNodeOmitDefaults(
  SwitchNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.value, false)) json.remove('value');
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

Map<String, dynamic> _$SwitchPropertiesOmitDefaults(
  SwitchProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.activeTrackColor, ColorRGBA.black))
    json.remove('activeTrackColor');
  if (isJsonDefault(instance.inactiveTrackColor, ColorRGBA.grey))
    json.remove('inactiveTrackColor');
  if (isJsonDefault(instance.activeThumbColor, ColorRGBA.white))
    json.remove('activeThumbColor');
  if (isJsonDefault(instance.inactiveThumbColor, ColorRGBA.white))
    json.remove('inactiveThumbColor');
  if (isJsonDefault(instance.hoverColor, ColorRGBA.grey10))
    json.remove('hoverColor');
  if (isJsonDefault(instance.focusColor, ColorRGBA.grey10))
    json.remove('focusColor');
  if (isJsonDefault(instance.splashRadius, kRadialReactionRadius))
    json.remove('splashRadius');
  if (isJsonDefault(instance.autofocus, false)) json.remove('autofocus');
  if (isJsonDefault(instance.activeTrackBorderColor, ColorRGBA.transparent))
    json.remove('activeTrackBorderColor');
  if (isJsonDefault(instance.inactiveTrackBorderColor, ColorRGBA.transparent))
    json.remove('inactiveTrackBorderColor');
  if (isJsonDefault(instance.trackOutlineWidth, 2))
    json.remove('trackOutlineWidth');
  if (isJsonDefault(instance.useMaterial3, false)) json.remove('useMaterial3');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwitchNode _$SwitchNodeFromJson(Map json) =>
    SwitchNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        value: json['value'] as bool? ?? false,
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
        properties: SwitchProperties.fromJson(json['properties'] as Map),
        variables:
            (json['variables'] as Map?)?.map(
              (k, e) => MapEntry(k as String, e as String),
            ) ??
            {},
      )
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

Map<String, dynamic> _$SwitchNodeToJson(SwitchNode instance) =>
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
      'enabled': instance.enabled,
      'motion': ?instance.motion?.toJson(),
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

SwitchProperties _$SwitchPropertiesFromJson(Map json) => SwitchProperties(
  activeTrackColor: json['activeTrackColor'] == null
      ? ColorRGBA.black
      : ColorRGBA.fromJson(json['activeTrackColor']),
  inactiveTrackColor: json['inactiveTrackColor'] == null
      ? ColorRGBA.grey
      : ColorRGBA.fromJson(json['inactiveTrackColor']),
  activeThumbColor: json['activeThumbColor'] == null
      ? ColorRGBA.white
      : ColorRGBA.fromJson(json['activeThumbColor']),
  inactiveThumbColor: json['inactiveThumbColor'] == null
      ? ColorRGBA.white
      : ColorRGBA.fromJson(json['inactiveThumbColor']),
  hoverColor: json['hoverColor'] == null
      ? ColorRGBA.grey10
      : ColorRGBA.fromJson(json['hoverColor']),
  focusColor: json['focusColor'] == null
      ? ColorRGBA.grey10
      : ColorRGBA.fromJson(json['focusColor']),
  splashRadius:
      (json['splashRadius'] as num?)?.toDouble() ?? kRadialReactionRadius,
  autofocus: json['autofocus'] as bool? ?? false,
  activeTrackBorderColor: json['activeTrackBorderColor'] == null
      ? ColorRGBA.transparent
      : ColorRGBA.fromJson(json['activeTrackBorderColor']),
  inactiveTrackBorderColor: json['inactiveTrackBorderColor'] == null
      ? ColorRGBA.transparent
      : ColorRGBA.fromJson(json['inactiveTrackBorderColor']),
  trackOutlineWidth: (json['trackOutlineWidth'] as num?)?.toDouble() ?? 2,
  useMaterial3: json['useMaterial3'] as bool? ?? false,
);

Map<String, dynamic> _$SwitchPropertiesToJson(SwitchProperties instance) =>
    <String, dynamic>{
      'activeTrackColor': instance.activeTrackColor.toJson(),
      'inactiveTrackColor': instance.inactiveTrackColor.toJson(),
      'activeThumbColor': instance.activeThumbColor.toJson(),
      'inactiveThumbColor': instance.inactiveThumbColor.toJson(),
      'hoverColor': instance.hoverColor.toJson(),
      'focusColor': instance.focusColor.toJson(),
      'splashRadius': instance.splashRadius,
      'autofocus': instance.autofocus,
      'activeTrackBorderColor': ?instance.activeTrackBorderColor?.toJson(),
      'inactiveTrackBorderColor': ?instance.inactiveTrackBorderColor?.toJson(),
      'trackOutlineWidth': instance.trackOutlineWidth,
      'useMaterial3': instance.useMaterial3,
    };
