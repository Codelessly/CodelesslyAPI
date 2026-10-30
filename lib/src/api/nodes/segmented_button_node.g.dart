// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segmented_button_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$SegmentedButtonNodeOmitDefaults(
  SegmentedButtonNode instance,
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
  if (isJsonDefault(instance.floating, false)) json.remove('floating');
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

Map<String, dynamic> _$ButtonSegmentModelOmitDefaults(
  ButtonSegmentModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.label, '')) json.remove('label');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

Map<String, dynamic> _$SegmentedButtonPropertiesOmitDefaults(
  SegmentedButtonProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.segments, kDefaultButtonSegments))
    json.remove('segments');
  if (isJsonDefault(instance.selected, const []))
    json.remove('selectedSegments');
  if (isJsonDefault(instance.multiSelectionEnabled, false))
    json.remove('multiSelectionEnabled');
  if (isJsonDefault(instance.emptySelectionAllowed, false))
    json.remove('emptySelectionAllowed');
  if (isJsonDefault(instance.showSelectedIcon, true))
    json.remove('showSelectedIcon');
  if (isJsonDefault(instance.direction, AxisC.horizontal))
    json.remove('direction');
  if (isJsonDefault(instance.borderWidth, 1)) json.remove('borderWidth');
  if (isJsonDefault(
    instance.cornerRadius,
    const CornerRadius.all(
      RadiusModel.circular(kSegmentedButtonDefaultHeight / 2),
    ),
  ))
    json.remove('cornerRadius');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SegmentedButtonNode _$SegmentedButtonNodeFromJson(Map json) =>
    SegmentedButtonNode(
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
        properties: SegmentedButtonProperties.fromJson(
          json['properties'] as Map,
        ),
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
      ..floating = json['floating'] as bool? ?? false
      ..type = json['type'] as String;

Map<String, dynamic> _$SegmentedButtonNodeToJson(
  SegmentedButtonNode instance,
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
  'floating': instance.floating,
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

ButtonSegmentModel _$ButtonSegmentModelFromJson(Map json) => ButtonSegmentModel(
  value: json['value'] as String,
  label: json['label'] as String? ?? '',
  icon: json['icon'] == null
      ? null
      : MultiSourceIconModel.fromJson(json['icon'] as Map),
  tooltip: json['tooltip'] as String?,
  enabled: json['enabled'] as bool? ?? true,
);

Map<String, dynamic> _$ButtonSegmentModelToJson(ButtonSegmentModel instance) =>
    <String, dynamic>{
      'value': instance.value,
      'label': instance.label,
      'icon': ?instance.icon?.toJson(),
      'tooltip': ?instance.tooltip,
      'enabled': instance.enabled,
    };

SegmentedButtonProperties _$SegmentedButtonPropertiesFromJson(Map json) =>
    SegmentedButtonProperties(
      segments:
          (json['segments'] as List<dynamic>?)
              ?.map((e) => ButtonSegmentModel.fromJson(e as Map))
              .toList() ??
          kDefaultButtonSegments,
      selected:
          (json['selectedSegments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      multiSelectionEnabled: json['multiSelectionEnabled'] as bool? ?? false,
      emptySelectionAllowed: json['emptySelectionAllowed'] as bool? ?? false,
      showSelectedIcon: json['showSelectedIcon'] as bool? ?? true,
      selectedIcon: json['selectedIcon'] == null
          ? null
          : MultiSourceIconModel.fromJson(json['selectedIcon'] as Map),
      direction:
          $enumDecodeNullable(_$AxisCEnumMap, json['direction']) ??
          AxisC.horizontal,
      borderColor: json['borderColor'] == null
          ? null
          : ColorRGBA.fromJson(json['borderColor']),
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1,
      selectedBackgroundColor: json['selectedColor'] == null
          ? null
          : ColorRGBA.fromJson(json['selectedColor']),
      backgroundColor: json['unselectedColor'] == null
          ? null
          : ColorRGBA.fromJson(json['unselectedColor']),
      selectedForegroundColor: json['selectedForegroundColor'] == null
          ? null
          : ColorRGBA.fromJson(json['selectedForegroundColor']),
      foregroundColor: json['foregroundColor'] == null
          ? null
          : ColorRGBA.fromJson(json['foregroundColor']),
      cornerRadius: json['cornerRadius'] == null
          ? const CornerRadius.all(
              RadiusModel.circular(kSegmentedButtonDefaultHeight / 2),
            )
          : CornerRadius.fromJson(json['cornerRadius']),
    );

Map<String, dynamic> _$SegmentedButtonPropertiesToJson(
  SegmentedButtonProperties instance,
) => <String, dynamic>{
  'segments': instance.segments.map((e) => e.toJson()).toList(),
  'selectedSegments': instance.selected,
  'multiSelectionEnabled': instance.multiSelectionEnabled,
  'emptySelectionAllowed': instance.emptySelectionAllowed,
  'showSelectedIcon': instance.showSelectedIcon,
  'selectedIcon': ?instance.selectedIcon?.toJson(),
  'direction': _$AxisCEnumMap[instance.direction]!,
  'borderColor': ?instance.borderColor?.toJson(),
  'borderWidth': instance.borderWidth,
  'selectedColor': ?instance.selectedBackgroundColor?.toJson(),
  'unselectedColor': ?instance.backgroundColor?.toJson(),
  'selectedForegroundColor': ?instance.selectedForegroundColor?.toJson(),
  'foregroundColor': ?instance.foregroundColor?.toJson(),
  'cornerRadius': instance.cornerRadius.toJson(),
};

const _$AxisCEnumMap = {
  AxisC.horizontal: 'horizontal',
  AxisC.vertical: 'vertical',
};
