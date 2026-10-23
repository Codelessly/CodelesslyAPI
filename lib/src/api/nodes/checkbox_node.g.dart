// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkbox_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$CheckboxNodeOmitDefaults(
  CheckboxNode instance,
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

Map<String, dynamic> _$CheckboxPropertiesOmitDefaults(
  CheckboxProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.checkColor, ColorRGBA.white))
    json.remove('checkColor');
  if (isJsonDefault(instance.activeColor, ColorRGBA.black))
    json.remove('activeColor');
  if (isJsonDefault(instance.borderColor, ColorRGBA.grey))
    json.remove('borderColor');
  if (isJsonDefault(instance.hoverColor, ColorRGBA.grey10))
    json.remove('hoverColor');
  if (isJsonDefault(instance.focusColor, ColorRGBA.grey10))
    json.remove('focusColor');
  if (isJsonDefault(instance.splashRadius, kRadialReactionRadius))
    json.remove('splashRadius');
  if (isJsonDefault(instance.autofocus, false)) json.remove('autofocus');
  if (isJsonDefault(instance.tristate, false)) json.remove('tristate');
  if (isJsonDefault(instance.borderWidth, 1.5)) json.remove('borderWidth');
  if (isJsonDefault(
    instance.cornerRadius,
    const CornerRadius.all(RadiusModel.circular(3)),
  ))
    json.remove('cornerRadius');
  if (isJsonDefault(instance.compact, false)) json.remove('compact');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckboxNode _$CheckboxNodeFromJson(Map json) =>
    CheckboxNode(
        value: json['value'] as bool?,
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
        properties: CheckboxProperties.fromJson(json['properties'] as Map),
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
      ..type = json['type'] as String;

Map<String, dynamic> _$CheckboxNodeToJson(CheckboxNode instance) =>
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
      'value': ?instance.value,
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

CheckboxProperties _$CheckboxPropertiesFromJson(Map json) => CheckboxProperties(
  checkColor: json['checkColor'] == null
      ? ColorRGBA.white
      : ColorRGBA.fromJson(json['checkColor']),
  activeColor: json['activeColor'] == null
      ? ColorRGBA.black
      : ColorRGBA.fromJson(json['activeColor']),
  hoverColor: json['hoverColor'] == null
      ? ColorRGBA.grey10
      : ColorRGBA.fromJson(json['hoverColor']),
  focusColor: json['focusColor'] == null
      ? ColorRGBA.grey10
      : ColorRGBA.fromJson(json['focusColor']),
  tristate: json['tristate'] as bool? ?? false,
  borderColor: json['borderColor'] == null
      ? ColorRGBA.grey
      : ColorRGBA.fromJson(json['borderColor']),
  borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1.5,
  cornerRadius: json['cornerRadius'] == null
      ? const CornerRadius.all(RadiusModel.circular(3))
      : CornerRadius.fromJson(json['cornerRadius']),
  splashRadius:
      (json['splashRadius'] as num?)?.toDouble() ?? kRadialReactionRadius,
  autofocus: json['autofocus'] as bool? ?? false,
  compact: json['compact'] as bool? ?? false,
);

Map<String, dynamic> _$CheckboxPropertiesToJson(CheckboxProperties instance) =>
    <String, dynamic>{
      'checkColor': instance.checkColor.toJson(),
      'activeColor': instance.activeColor.toJson(),
      'borderColor': instance.borderColor.toJson(),
      'hoverColor': instance.hoverColor.toJson(),
      'focusColor': instance.focusColor.toJson(),
      'splashRadius': instance.splashRadius,
      'autofocus': instance.autofocus,
      'tristate': instance.tristate,
      'borderWidth': instance.borderWidth,
      'cornerRadius': instance.cornerRadius.toJson(),
      'compact': instance.compact,
    };
