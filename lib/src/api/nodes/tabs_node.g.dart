// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tabs_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$TabsItemOmitDefaults(
  TabsItem instance,
  Map<String, dynamic> json,
) {
  return json;
}

Map<String, dynamic> _$TabsNodeOmitDefaults(
  TabsNode instance,
  Map<String, dynamic> json,
) {
  if (excludeConstraintsIf(instance)) json.remove('constraints');
  if (isJsonDefault(instance.squeezable, false)) json.remove('squeezable');
  if (isJsonDefault(instance.interactionStates, {}))
    json.remove('interactionStates');
  if (isJsonDefault(instance.tooltip, '')) json.remove('tooltip');
  if (isJsonDefault(instance.zoomable, false)) json.remove('zoomable');
  if (isJsonDefault(instance.transitionMs, 0)) json.remove('transitionMs');
  if (isJsonDefault(instance.drawScale, 1.0)) json.remove('drawScale');
  if (isJsonDefault(instance.variables, {})) json.remove('variables');
  if (isJsonDefault(instance.multipleVariables, {}))
    json.remove('multipleVariables');
  if (isJsonDefault(instance.componentVersion, 1))
    json.remove('componentVersion');
  if (isJsonDefault(instance.componentSchema, {}))
    json.remove('componentSchema');
  if (isJsonDefault(instance.reactions, const [])) json.remove('reactions');
  if (isJsonDefault(instance.children, [])) json.remove('children');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TabsItem _$TabsItemFromJson(Map json) =>
    TabsItem(title: json['title'] as String, child: json['child'] as String);

Map<String, dynamic> _$TabsItemToJson(TabsItem instance) => <String, dynamic>{
  'title': instance.title,
  'child': instance.child,
};

TabsNode _$TabsNodeFromJson(Map json) =>
    TabsNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        tabs: (json['tabs'] as List<dynamic>)
            .map((e) => TabsItem.fromJson(e as Map))
            .toList(),
        reactions:
            (json['reactions'] as List<dynamic>?)
                ?.map((e) => Reaction.fromJson(e as Map))
                .toList() ??
            const [],
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
      ..visible = json['visible'] as bool
      ..edgePins = EdgePinsModel.fromJson(
        Map<String, dynamic>.from(json['edgePins'] as Map),
      )
      ..positioningMode = $enumDecode(
        _$PositioningModeEnumMap,
        json['positioningMode'],
      )
      ..horizontalFit = $enumDecode(_$SizeFitEnumMap, json['horizontalFit'])
      ..verticalFit = $enumDecode(_$SizeFitEnumMap, json['verticalFit'])
      ..flex = (json['flex'] as num).toInt()
      ..squeezable = json['squeezable'] as bool? ?? false
      ..aspectRatioLock = json['aspectRatioLock'] as bool
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
      ..enabled = json['enabled'] as bool
      ..motion = json['motion'] == null
          ? null
          : MotionModel.fromJson(json['motion'] as Map)
      ..drag = json['drag'] == null
          ? null
          : DragModel.fromJson(json['drag'] as Map)
      ..children =
          (json['children'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          []
      ..type = json['type'] as String;

Map<String, dynamic> _$TabsNodeToJson(TabsNode instance) => <String, dynamic>{
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
  'edgePins': instance.edgePins.toJson(),
  'positioningMode': _$PositioningModeEnumMap[instance.positioningMode]!,
  'horizontalFit': _$SizeFitEnumMap[instance.horizontalFit]!,
  'verticalFit': _$SizeFitEnumMap[instance.verticalFit]!,
  'flex': instance.flex,
  'squeezable': instance.squeezable,
  'aspectRatioLock': instance.aspectRatioLock,
  'basicBoxLocal': instance.basicBoxLocal.toJson(),
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
  'drag': ?instance.drag?.toJson(),
  'children': instance.children,
  'type': instance.type,
  'tabs': instance.tabs.map((e) => e.toJson()).toList(),
};

const _$ComponentMarkerTypeEnumMap = {
  ComponentMarkerType.component: 'component',
  ComponentMarkerType.instance: 'instance',
};

const _$PositioningModeEnumMap = {
  PositioningMode.align: 'align',
  PositioningMode.pin: 'pin',
};

const _$SizeFitEnumMap = {
  SizeFit.locked: 'locked',
  SizeFit.fixed: 'fixed',
  SizeFit.expanded: 'expanded',
  SizeFit.flexible: 'flexible',
  SizeFit.shrinkWrap: 'shrinkWrap',
};

const _$InteractionStateEnumMap = {
  InteractionState.hovered: 'hovered',
  InteractionState.focused: 'focused',
  InteractionState.pressed: 'pressed',
  InteractionState.selected: 'selected',
  InteractionState.disabled: 'disabled',
};
