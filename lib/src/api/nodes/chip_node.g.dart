// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chip_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ChipNodeOmitDefaults(
  ChipNode instance,
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

Map<String, dynamic> _$ChipPropertiesOmitDefaults(
  ChipProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.chipType, ChipType.action))
    json.remove('chipType');
  if (isJsonDefault(instance.label, 'Chip')) json.remove('label');
  if (isJsonDefault(instance.selected, false)) json.remove('selected');
  if (isJsonDefault(instance.showCheckmark, true)) json.remove('showCheckmark');
  if (isJsonDefault(instance.borderWidth, 1)) json.remove('borderWidth');
  if (isJsonDefault(instance.cornerRadius, 8)) json.remove('cornerRadius');
  if (isJsonDefault(instance.elevation, 0)) json.remove('elevation');
  if (isJsonDefault(instance.padding, const EdgeInsetsModel.all(8)))
    json.remove('padding');
  if (isJsonDefault(
    instance.labelPadding,
    const EdgeInsetsModel.symmetric(horizontal: 8),
  ))
    json.remove('labelPadding');
  if (isJsonDefault(instance.autofocus, false)) json.remove('autofocus');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChipNode _$ChipNodeFromJson(Map json) =>
    ChipNode(
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
        properties: ChipProperties.fromJson(json['properties'] as Map),
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
      ..loopAnimation = json['loopAnimation'] == null
          ? null
          : LoopAnimation.fromJson(json['loopAnimation'] as Map)
      ..type = json['type'] as String;

Map<String, dynamic> _$ChipNodeToJson(ChipNode instance) => <String, dynamic>{
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

ChipProperties _$ChipPropertiesFromJson(Map json) => ChipProperties(
  chipType:
      $enumDecodeNullable(_$ChipTypeEnumMap, json['chipType']) ??
      ChipType.action,
  label: json['label'] as String? ?? 'Chip',
  labelStyle: json['labelStyle'] == null
      ? null
      : TextProp.fromJson(json['labelStyle'] as Map),
  icon: json['icon'] == null
      ? null
      : MultiSourceIconModel.fromJson(json['icon'] as Map),
  avatar: json['avatar'] as String?,
  deleteIcon: json['deleteIcon'] == null
      ? null
      : MultiSourceIconModel.fromJson(json['deleteIcon'] as Map),
  deleteIconColor: json['deleteIconColor'] == null
      ? null
      : ColorRGBA.fromJson(json['deleteIconColor']),
  selected: json['selected'] as bool? ?? false,
  showCheckmark: json['showCheckmark'] as bool? ?? true,
  checkmarkColor: json['checkmarkColor'] == null
      ? null
      : ColorRGBA.fromJson(json['checkmarkColor']),
  backgroundColor: json['backgroundColor'] == null
      ? null
      : ColorRGBA.fromJson(json['backgroundColor']),
  selectedColor: json['selectedColor'] == null
      ? null
      : ColorRGBA.fromJson(json['selectedColor']),
  borderColor: json['borderColor'] == null
      ? null
      : ColorRGBA.fromJson(json['borderColor']),
  borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1,
  cornerRadius: (json['cornerRadius'] as num?)?.toDouble() ?? 8,
  elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
  shadowColor: json['shadowColor'] == null
      ? null
      : ColorRGBA.fromJson(json['shadowColor']),
  padding: json['padding'] == null
      ? const EdgeInsetsModel.all(8)
      : EdgeInsetsModel.fromJson(json['padding']),
  labelPadding: json['labelPadding'] == null
      ? const EdgeInsetsModel.symmetric(horizontal: 8)
      : EdgeInsetsModel.fromJson(json['labelPadding']),
  tooltip: json['tooltip'] as String?,
  autofocus: json['autofocus'] as bool? ?? false,
);

Map<String, dynamic> _$ChipPropertiesToJson(ChipProperties instance) =>
    <String, dynamic>{
      'chipType': _$ChipTypeEnumMap[instance.chipType]!,
      'label': instance.label,
      'labelStyle': instance.labelStyle.toJson(),
      'icon': ?instance.icon?.toJson(),
      'avatar': ?instance.avatar,
      'deleteIcon': ?instance.deleteIcon?.toJson(),
      'deleteIconColor': ?instance.deleteIconColor?.toJson(),
      'selected': instance.selected,
      'showCheckmark': instance.showCheckmark,
      'checkmarkColor': ?instance.checkmarkColor?.toJson(),
      'backgroundColor': ?instance.backgroundColor?.toJson(),
      'selectedColor': ?instance.selectedColor?.toJson(),
      'borderColor': ?instance.borderColor?.toJson(),
      'borderWidth': instance.borderWidth,
      'cornerRadius': instance.cornerRadius,
      'elevation': instance.elevation,
      'shadowColor': ?instance.shadowColor?.toJson(),
      'padding': instance.padding.toJson(),
      'labelPadding': instance.labelPadding.toJson(),
      'tooltip': ?instance.tooltip,
      'autofocus': instance.autofocus,
    };

const _$ChipTypeEnumMap = {
  ChipType.basic: 'basic',
  ChipType.action: 'action',
  ChipType.choice: 'choice',
  ChipType.filter: 'filter',
  ChipType.input: 'input',
};
