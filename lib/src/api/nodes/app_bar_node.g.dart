// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_bar_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$AppBarNodeOmitDefaults(
  AppBarNode instance,
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

Map<String, dynamic> _$AppBarPropertiesOmitDefaults(
  AppBarProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.centerTitle, false)) json.remove('centerTitle');
  if (isJsonDefault(instance.elevation, 0)) json.remove('elevation');
  if (isJsonDefault(instance.automaticallyImplyLeading, true))
    json.remove('automaticallyImplyLeading');
  if (isJsonDefault(instance.titleSpacing, 16)) json.remove('titleSpacing');
  if (isJsonDefault(instance.actions, const [])) json.remove('actions');
  if (isJsonDefault(instance.shadowColor, ColorRGBA.black))
    json.remove('shadowColor');
  return json;
}

Map<String, dynamic> _$IconAppBarActionItemOmitDefaults(
  IconAppBarActionItem instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.reactions, const [])) json.remove('reactions');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppBarNode _$AppBarNodeFromJson(Map json) =>
    AppBarNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        rotationDegrees: json['rotation'] == null
            ? 0
            : castRotation(json['rotation']),
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
        properties: AppBarProperties.fromJson(json['properties'] as Map),
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
      ..type = json['type'] as String;

Map<String, dynamic> _$AppBarNodeToJson(AppBarNode instance) =>
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

AppBarProperties _$AppBarPropertiesFromJson(Map json) => AppBarProperties(
  title: json['title'] as String,
  backgroundColor: ColorRGBA.fromJson(json['backgroundColor']),
  leading: IconAppBarActionItem.fromJson(json['leading'] as Map),
  actions:
      (json['actions'] as List<dynamic>?)
          ?.map((e) => IconAppBarActionItem.fromJson(e as Map))
          .toList() ??
      const [],
  centerTitle: json['centerTitle'] as bool? ?? false,
  titleStyle: json['titleStyle'] == null
      ? null
      : TextProp.fromJson(json['titleStyle'] as Map),
  elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
  automaticallyImplyLeading: json['automaticallyImplyLeading'] as bool? ?? true,
  titleSpacing: (json['titleSpacing'] as num?)?.toDouble() ?? 16,
  shadowColor: json['shadowColor'] == null
      ? ColorRGBA.black
      : ColorRGBA.fromJson(json['shadowColor']),
  foregroundColor: json['foregroundColor'] == null
      ? null
      : ColorRGBA.fromJson(json['foregroundColor']),
  scrolledUnderElevation: (json['scrolledUnderElevation'] as num?)?.toDouble(),
);

Map<String, dynamic> _$AppBarPropertiesToJson(AppBarProperties instance) =>
    <String, dynamic>{
      'centerTitle': instance.centerTitle,
      'elevation': instance.elevation,
      'leading': instance.leading.toJson(),
      'automaticallyImplyLeading': instance.automaticallyImplyLeading,
      'titleStyle': instance.titleStyle.toJson(),
      'backgroundColor': instance.backgroundColor.toJson(),
      'title': instance.title,
      'titleSpacing': instance.titleSpacing,
      'actions': instance.actions.map((e) => e.toJson()).toList(),
      'shadowColor': instance.shadowColor.toJson(),
      'foregroundColor': ?instance.foregroundColor?.toJson(),
      'scrolledUnderElevation': ?instance.scrolledUnderElevation,
    };

IconAppBarActionItem _$IconAppBarActionItemFromJson(Map json) =>
    IconAppBarActionItem(
      id: json['id'] as String,
      icon: MultiSourceIconModel.fromJson(json['icon'] as Map),
      tooltip: json['tooltip'] as String?,
      reactions:
          (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          const [],
    )..type = json['type'] as String;

Map<String, dynamic> _$IconAppBarActionItemToJson(
  IconAppBarActionItem instance,
) => <String, dynamic>{
  'reactions': instance.reactions.map((e) => e.toJson()).toList(),
  'id': instance.id,
  'icon': instance.icon.toJson(),
  'tooltip': ?instance.tooltip,
  'type': instance.type,
};
