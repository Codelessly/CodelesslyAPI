// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_view_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$PageViewNodeOmitDefaults(
  PageViewNode instance,
  Map<String, dynamic> json,
) {
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
  if (isJsonDefault(instance.children, [])) json.remove('children');
  if (isJsonDefault(instance.isScrollable, false)) json.remove('isScrollable');
  if (isJsonDefault(instance.scrollDirection, AxisC.vertical))
    json.remove('scrollDirection');
  if (isJsonDefault(instance.reverse, false)) json.remove('reverse');
  if (isJsonDefault(instance.primary, false)) json.remove('primary');
  if (isJsonDefault(instance.physics, ScrollPhysicsC.platformDependent))
    json.remove('physics');
  if (isJsonDefault(
    instance.keyboardDismissBehavior,
    ScrollViewKeyboardDismissBehaviorC.manual,
  ))
    json.remove('keyboardDismissBehavior');
  if (isJsonDefault(instance.useFlutterListView, false))
    json.remove('useFlutterListView');
  if (isJsonDefault(instance.shouldAlwaysScroll, true))
    json.remove('shouldAlwaysScroll');
  if (isJsonDefault(instance.clipsContent, true)) json.remove('clipsContent');
  return json;
}

Map<String, dynamic> _$PageViewPropertiesOmitDefaults(
  PageViewProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.pageSnapping, true)) json.remove('pageSnapping');
  if (isJsonDefault(instance.padEnds, true)) json.remove('padEnds');
  if (isJsonDefault(instance.keepPage, true)) json.remove('keepPage');
  if (isJsonDefault(instance.initialPage, 0)) json.remove('initialPage');
  if (isJsonDefault(instance.viewportFraction, 1))
    json.remove('viewportFraction');
  if (isJsonDefault(instance.allowImplicitScrolling, false))
    json.remove('allowImplicitScrolling');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageViewNode _$PageViewNodeFromJson(Map json) =>
    PageViewNode(
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
        properties: PageViewProperties.fromJson(json['properties'] as Map),
        children:
            (json['children'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        variables:
            (json['variables'] as Map?)?.map(
              (k, e) => MapEntry(k as String, e as String),
            ) ??
            {},
        clipsContent: json['clipsContent'] as bool? ?? true,
        isScrollable: json['isScrollable'] as bool? ?? false,
        useFlutterListView: json['useFlutterListView'] as bool? ?? false,
        scrollDirection:
            $enumDecodeNullable(_$AxisCEnumMap, json['scrollDirection']) ??
            AxisC.vertical,
        reverse: json['reverse'] as bool? ?? false,
        physics:
            $enumDecodeNullable(
              _$ScrollPhysicsCEnumMap,
              json['physics'],
              unknownValue: ScrollPhysicsC.platformDependent,
            ) ??
            ScrollPhysicsC.platformDependent,
        primary: json['primary'] as bool? ?? false,
        keyboardDismissBehavior:
            $enumDecodeNullable(
              _$ScrollViewKeyboardDismissBehaviorCEnumMap,
              json['keyboardDismissBehavior'],
            ) ??
            ScrollViewKeyboardDismissBehaviorC.manual,
        shouldAlwaysScroll: json['shouldAlwaysScroll'] as bool? ?? true,
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
      ..maxAllowedSize = json['maxAllowedSize'] == null
          ? null
          : SizeC.fromJson(json['maxAllowedSize'] as Map)
      ..type = json['type'] as String;

Map<String, dynamic> _$PageViewNodeToJson(PageViewNode instance) =>
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
      'children': instance.children,
      'clipsContent': instance.clipsContent,
      'ephemeral': instance.ephemeral,
      'allowedTypes': instance.allowedTypes,
      'deniedTypes': instance.deniedTypes,
      'maxAllowedSize': ?instance.maxAllowedSize?.toJson(),
      'isScrollable': instance.isScrollable,
      'scrollDirection': _$AxisCEnumMap[instance.scrollDirection]!,
      'reverse': instance.reverse,
      'primary': instance.primary,
      'physics': _$ScrollPhysicsCEnumMap[instance.physics]!,
      'keyboardDismissBehavior':
          _$ScrollViewKeyboardDismissBehaviorCEnumMap[instance
              .keyboardDismissBehavior]!,
      'useFlutterListView': instance.useFlutterListView,
      'shouldAlwaysScroll': instance.shouldAlwaysScroll,
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

const _$AxisCEnumMap = {
  AxisC.horizontal: 'horizontal',
  AxisC.vertical: 'vertical',
};

const _$ScrollPhysicsCEnumMap = {
  ScrollPhysicsC.platformDependent: 'platformDependent',
  ScrollPhysicsC.bouncingScrollPhysics: 'bouncingScrollPhysics',
  ScrollPhysicsC.clampingScrollPhysics: 'clampingScrollPhysics',
  ScrollPhysicsC.neverScrollableScrollPhysics: 'neverScrollableScrollPhysics',
  ScrollPhysicsC.rangeMaintainingScrollPhysics: 'rangeMaintainingScrollPhysics',
};

const _$ScrollViewKeyboardDismissBehaviorCEnumMap = {
  ScrollViewKeyboardDismissBehaviorC.manual: 'manual',
  ScrollViewKeyboardDismissBehaviorC.onDrag: 'onDrag',
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

PageViewProperties _$PageViewPropertiesFromJson(Map json) => PageViewProperties(
  itemCount: (json['itemCount'] as num?)?.toInt(),
  pageSnapping: json['pageSnapping'] as bool? ?? true,
  padEnds: json['padEnds'] as bool? ?? true,
  keepPage: json['keepPage'] as bool? ?? true,
  initialPage: (json['initialPage'] as num?)?.toInt() ?? 0,
  viewportFraction: (json['viewportFraction'] as num?)?.toDouble() ?? 1,
  allowImplicitScrolling: json['allowImplicitScrolling'] as bool? ?? false,
);

Map<String, dynamic> _$PageViewPropertiesToJson(PageViewProperties instance) =>
    <String, dynamic>{
      'itemCount': ?instance.itemCount,
      'pageSnapping': instance.pageSnapping,
      'padEnds': instance.padEnds,
      'keepPage': instance.keepPage,
      'initialPage': instance.initialPage,
      'viewportFraction': instance.viewportFraction,
      'allowImplicitScrolling': instance.allowImplicitScrolling,
    };
