// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_bar_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$NavigationBarNodeOmitDefaults(
  NavigationBarNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.currentIndex, 0)) json.remove('currentIndex');
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

Map<String, dynamic> _$M3NavigationBarPropertiesOmitDefaults(
  M3NavigationBarProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.unselectedIconSize, 24))
    json.remove('unselectedIconSize');
  if (isJsonDefault(instance.selectedIconSize, 24))
    json.remove('selectedIconSize');
  if (isJsonDefault(instance.elevation, 0.0)) json.remove('elevation');
  if (isJsonDefault(
    instance.labelBehavior,
    MaterialNavigationBarLabelBehavior.alwaysShow,
  ))
    json.remove('labelBehavior');
  if (isJsonDefault(instance.makeNotched, false)) json.remove('makeNotched');
  if (isJsonDefault(instance.notchMargin, 4)) json.remove('notchMargin');
  return json;
}

Map<String, dynamic> _$M2NavigationBarPropertiesOmitDefaults(
  M2NavigationBarProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.navigationBarType, M2NavigationBarType.fixed))
    json.remove('navigationBarType');
  if (isJsonDefault(
    instance.landscapeLayout,
    M2NavigationBarLandscapeLayout.spread,
  ))
    json.remove('landscapeLayout');
  if (isJsonDefault(instance.unselectedIconSize, 24))
    json.remove('unselectedIconSize');
  if (isJsonDefault(instance.selectedIconSize, 24))
    json.remove('selectedIconSize');
  if (isJsonDefault(instance.elevation, 0.0)) json.remove('elevation');
  if (isJsonDefault(
    instance.labelBehavior,
    MaterialNavigationBarLabelBehavior.alwaysShow,
  ))
    json.remove('labelBehavior');
  if (isJsonDefault(instance.makeNotched, false)) json.remove('makeNotched');
  if (isJsonDefault(instance.notchMargin, 4)) json.remove('notchMargin');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NavigationBarNode _$NavigationBarNodeFromJson(Map json) =>
    NavigationBarNode(
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
        currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
        properties: navigationBarPropertiesFromJson(json['properties'] as Map),
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
      ..type = json['type'] as String;

Map<String, dynamic> _$NavigationBarNodeToJson(NavigationBarNode instance) =>
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
      'currentIndex': instance.currentIndex,
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

M3NavigationBarProperties _$M3NavigationBarPropertiesFromJson(Map json) =>
    M3NavigationBarProperties(
        items: (json['items'] as List<dynamic>)
            .map((e) => M3NavigationBarItem.fromJson(e as Map))
            .toList(),
        makeNotched: json['makeNotched'] as bool? ?? false,
        notchMargin: (json['notchMargin'] as num?)?.toDouble() ?? 4,
        backgroundColor: json['backgroundColor'] == null
            ? null
            : ColorRGBA.fromJson(json['backgroundColor']),
        elevation: (json['elevation'] as num?)?.toDouble() ?? 0.0,
        selectedLabelStyle: json['selectedLabelStyle'] == null
            ? null
            : TextProp.fromJson(json['selectedLabelStyle'] as Map),
        unselectedLabelStyle: json['unselectedLabelStyle'] == null
            ? null
            : TextProp.fromJson(json['unselectedLabelStyle'] as Map),
        unselectedIconColor: json['unselectedIconColor'] == null
            ? null
            : ColorRGBA.fromJson(json['unselectedIconColor']),
        selectedIconColor: json['selectedIconColor'] == null
            ? null
            : ColorRGBA.fromJson(json['selectedIconColor']),
        indicatorColor: json['indicatorColor'] == null
            ? null
            : ColorRGBA.fromJson(json['indicatorColor']),
        unselectedIconSize:
            (json['unselectedIconSize'] as num?)?.toDouble() ?? 24,
        selectedIconSize: (json['selectedIconSize'] as num?)?.toDouble() ?? 24,
        labelBehavior:
            $enumDecodeNullable(
              _$MaterialNavigationBarLabelBehaviorEnumMap,
              json['labelBehavior'],
            ) ??
            MaterialNavigationBarLabelBehavior.alwaysShow,
      )
      ..styleDefinition = $enumDecode(
        _$StyleDefinitionEnumMap,
        json['styleDefinition'],
      );

Map<String, dynamic> _$M3NavigationBarPropertiesToJson(
  M3NavigationBarProperties instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'makeNotched': instance.makeNotched,
  'notchMargin': instance.notchMargin,
  'styleDefinition': _$StyleDefinitionEnumMap[instance.styleDefinition]!,
  'indicatorColor': ?instance.indicatorColor?.toJson(),
  'selectedLabelStyle': instance.selectedLabelStyle.toJson(),
  'unselectedLabelStyle': instance.unselectedLabelStyle.toJson(),
  'unselectedIconColor': ?instance.unselectedIconColor?.toJson(),
  'selectedIconColor': ?instance.selectedIconColor?.toJson(),
  'unselectedIconSize': instance.unselectedIconSize,
  'selectedIconSize': instance.selectedIconSize,
  'elevation': instance.elevation,
  'backgroundColor': ?instance.backgroundColor?.toJson(),
  'labelBehavior':
      _$MaterialNavigationBarLabelBehaviorEnumMap[instance.labelBehavior]!,
};

const _$MaterialNavigationBarLabelBehaviorEnumMap = {
  MaterialNavigationBarLabelBehavior.alwaysShow: 'alwaysShow',
  MaterialNavigationBarLabelBehavior.alwaysHide: 'alwaysHide',
  MaterialNavigationBarLabelBehavior.onlyShowSelected: 'onlyShowSelected',
  MaterialNavigationBarLabelBehavior.onlyShowUnselected: 'onlyShowUnselected',
};

const _$StyleDefinitionEnumMap = {
  StyleDefinition.material_2: 'material_2',
  StyleDefinition.material_3: 'material_3',
};

M2NavigationBarProperties _$M2NavigationBarPropertiesFromJson(Map json) =>
    M2NavigationBarProperties(
        items: (json['items'] as List<dynamic>)
            .map((e) => M2NavigationBarItem.fromJson(e as Map))
            .toList(),
        makeNotched: json['makeNotched'] as bool? ?? false,
        notchMargin: (json['notchMargin'] as num?)?.toDouble() ?? 4,
        backgroundColor: json['backgroundColor'] == null
            ? null
            : ColorRGBA.fromJson(json['backgroundColor']),
        elevation: (json['elevation'] as num?)?.toDouble() ?? 0.0,
        navigationBarType:
            $enumDecodeNullable(
              _$M2NavigationBarTypeEnumMap,
              json['navigationBarType'],
            ) ??
            M2NavigationBarType.fixed,
        landscapeLayout:
            $enumDecodeNullable(
              _$M2NavigationBarLandscapeLayoutEnumMap,
              json['landscapeLayout'],
            ) ??
            M2NavigationBarLandscapeLayout.spread,
        selectedLabelStyle: json['selectedLabelStyle'] == null
            ? null
            : TextProp.fromJson(json['selectedLabelStyle'] as Map),
        unselectedLabelStyle: json['unselectedLabelStyle'] == null
            ? null
            : TextProp.fromJson(json['unselectedLabelStyle'] as Map),
        selectedIconColor: json['selectedIconColor'] == null
            ? null
            : ColorRGBA.fromJson(json['selectedIconColor']),
        unselectedIconColor: json['unselectedIconColor'] == null
            ? null
            : ColorRGBA.fromJson(json['unselectedIconColor']),
        unselectedIconSize:
            (json['unselectedIconSize'] as num?)?.toDouble() ?? 24,
        selectedIconSize: (json['selectedIconSize'] as num?)?.toDouble() ?? 24,
        labelBehavior:
            $enumDecodeNullable(
              _$MaterialNavigationBarLabelBehaviorEnumMap,
              json['labelBehavior'],
            ) ??
            MaterialNavigationBarLabelBehavior.alwaysShow,
      )
      ..styleDefinition = $enumDecode(
        _$StyleDefinitionEnumMap,
        json['styleDefinition'],
      );

Map<String, dynamic> _$M2NavigationBarPropertiesToJson(
  M2NavigationBarProperties instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'makeNotched': instance.makeNotched,
  'notchMargin': instance.notchMargin,
  'styleDefinition': _$StyleDefinitionEnumMap[instance.styleDefinition]!,
  'navigationBarType':
      _$M2NavigationBarTypeEnumMap[instance.navigationBarType]!,
  'landscapeLayout':
      _$M2NavigationBarLandscapeLayoutEnumMap[instance.landscapeLayout]!,
  'selectedLabelStyle': instance.selectedLabelStyle.toJson(),
  'unselectedLabelStyle': instance.unselectedLabelStyle.toJson(),
  'unselectedIconColor': ?instance.unselectedIconColor?.toJson(),
  'selectedIconColor': ?instance.selectedIconColor?.toJson(),
  'unselectedIconSize': instance.unselectedIconSize,
  'selectedIconSize': instance.selectedIconSize,
  'elevation': instance.elevation,
  'backgroundColor': ?instance.backgroundColor?.toJson(),
  'labelBehavior':
      _$MaterialNavigationBarLabelBehaviorEnumMap[instance.labelBehavior]!,
};

const _$M2NavigationBarTypeEnumMap = {
  M2NavigationBarType.fixed: 'fixed',
  M2NavigationBarType.shifting: 'shifting',
};

const _$M2NavigationBarLandscapeLayoutEnumMap = {
  M2NavigationBarLandscapeLayout.spread: 'spread',
  M2NavigationBarLandscapeLayout.centered: 'centered',
  M2NavigationBarLandscapeLayout.linear: 'linear',
};
