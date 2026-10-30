// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_view_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ListViewNodeOmitDefaults(
  ListViewNode instance,
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
  if (isJsonDefault(instance.useCloudDatabase, false))
    json.remove('useCloudDatabase');
  if (isJsonDefault(instance.limit, 20)) json.remove('limit');
  if (isJsonDefault(instance.paging, QueryPaging.scroll)) json.remove('paging');
  if (isJsonDefault(instance.loadRelated, [])) json.remove('loadRelated');
  if (isJsonDefault(instance.whereFilters, [])) json.remove('whereFilters');
  if (isJsonDefault(instance.orderByFilters, [])) json.remove('orderByFilters');
  return json;
}

Map<String, dynamic> _$ListViewPropertiesOmitDefaults(
  ListViewProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.separatorSpacing, 0))
    json.remove('separatorSpacing');
  if (isJsonDefault(instance.separator, ListItemSeparator.space))
    json.remove('separator');
  if (isJsonDefault(instance.hasSeparator, false)) json.remove('hasSeparator');
  if (isJsonDefault(instance.stacked, false)) json.remove('stacked');
  if (isJsonDefault(instance.wrap, false)) json.remove('wrap');
  if (isJsonDefault(instance.wrapSpacing, 0)) json.remove('wrapSpacing');
  if (isJsonDefault(instance.wrapRunSpacing, 0)) json.remove('wrapRunSpacing');
  if (isJsonDefault(instance.wrapAlignment, MainAxisAlignmentC.start))
    json.remove('wrapAlignment');
  if (isJsonDefault(instance.runSpacing, 0)) json.remove('runSpacing');
  if (isJsonDefault(instance.layout, ListLayout.list)) json.remove('layout');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListViewNode _$ListViewNodeFromJson(Map json) =>
    ListViewNode(
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
        properties: ListViewProperties.fromJson(json['properties'] as Map),
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
        multipleVariables:
            (json['multipleVariables'] as Map?)?.map(
              (k, e) => MapEntry(
                k as String,
                (e as List<dynamic>).map((e) => e as String).toList(),
              ),
            ) ??
            {},
        clipsContent: json['clipsContent'] as bool? ?? true,
        statusVariable: json['statusVariable'] == null
            ? null
            : VariableData.fromJson(
                Map<String, dynamic>.from(json['statusVariable'] as Map),
              ),
        useCloudDatabase: json['useCloudDatabase'] as bool? ?? false,
        collectionPath: json['collectionPath'] as String?,
        limit: (json['limit'] as num?)?.toInt() ?? 20,
        whereFilters: (json['whereFilters'] as List<dynamic>?)
            ?.map(
              (e) => WhereQueryFilter.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
        orderByFilters: (json['orderByFilters'] as List<dynamic>?)
            ?.map(
              (e) => OrderByQueryFilter.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
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
      ..drag = json['drag'] == null
          ? null
          : DragModel.fromJson(json['drag'] as Map)
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
      ..ephemeral = json['ephemeral'] as bool? ?? false
      ..paging =
          $enumDecodeNullable(_$QueryPagingEnumMap, json['paging']) ??
          QueryPaging.scroll
      ..loadRelated =
          (json['loadRelated'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          []
      ..type = json['type'] as String;

Map<String, dynamic> _$ListViewNodeToJson(ListViewNode instance) =>
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
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
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
      'drag': ?instance.drag?.toJson(),
      'children': instance.children,
      'allowedTypes': instance.allowedTypes,
      'deniedTypes': instance.deniedTypes,
      'maxAllowedSize': ?instance.maxAllowedSize?.toJson(),
      'clipsContent': instance.clipsContent,
      'ephemeral': instance.ephemeral,
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
      'useCloudDatabase': instance.useCloudDatabase,
      'collectionPath': ?instance.collectionPath,
      'limit': ?instance.limit,
      'paging': _$QueryPagingEnumMap[instance.paging]!,
      'loadRelated': instance.loadRelated,
      'whereFilters': instance.whereFilters.map((e) => e.toJson()).toList(),
      'orderByFilters': instance.orderByFilters.map((e) => e.toJson()).toList(),
      'type': instance.type,
      'properties': instance.properties.toJson(),
      'statusVariable': ?instance.statusVariable?.toJson(),
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

const _$QueryPagingEnumMap = {
  QueryPaging.scroll: 'scroll',
  QueryPaging.button: 'button',
};

ListViewProperties _$ListViewPropertiesFromJson(Map json) => ListViewProperties(
  layout:
      $enumDecodeNullable(_$ListLayoutEnumMap, json['layout']) ??
      ListLayout.list,
  itemCount: (json['itemCount'] as num?)?.toInt(),
  itemExtent: (json['itemExtent'] as num?)?.toDouble(),
  cacheExtent: (json['cacheExtent'] as num?)?.toDouble(),
  separator:
      $enumDecodeNullable(_$ListItemSeparatorEnumMap, json['separator']) ??
      ListItemSeparator.space,
  separatorSpacing: (json['separatorSpacing'] as num?)?.toDouble() ?? 0,
  hasSeparator: json['hasSeparator'] as bool? ?? false,
  stacked: json['stacked'] as bool? ?? false,
  wrap: json['wrap'] as bool? ?? false,
  wrapSpacing: (json['wrapSpacing'] as num?)?.toDouble() ?? 0,
  wrapRunSpacing: (json['wrapRunSpacing'] as num?)?.toDouble() ?? 0,
  wrapAlignment:
      $enumDecodeNullable(_$MainAxisAlignmentCEnumMap, json['wrapAlignment']) ??
      MainAxisAlignmentC.start,
  runSpacing: (json['runSpacing'] as num?)?.toDouble() ?? 0,
  dividerProperties: json['dividerProperties'] == null
      ? null
      : DividerProperties.fromJson(json['dividerProperties'] as Map),
);

Map<String, dynamic> _$ListViewPropertiesToJson(ListViewProperties instance) =>
    <String, dynamic>{
      'itemCount': ?instance.itemCount,
      'itemExtent': ?instance.itemExtent,
      'cacheExtent': ?instance.cacheExtent,
      'separatorSpacing': instance.separatorSpacing,
      'separator': _$ListItemSeparatorEnumMap[instance.separator]!,
      'hasSeparator': instance.hasSeparator,
      'dividerProperties': instance.dividerProperties.toJson(),
      'stacked': instance.stacked,
      'wrap': instance.wrap,
      'wrapSpacing': instance.wrapSpacing,
      'wrapRunSpacing': instance.wrapRunSpacing,
      'wrapAlignment': _$MainAxisAlignmentCEnumMap[instance.wrapAlignment]!,
      'runSpacing': instance.runSpacing,
      'layout': _$ListLayoutEnumMap[instance.layout]!,
    };

const _$ListLayoutEnumMap = {
  ListLayout.list: 'list',
  ListLayout.stack: 'stack',
};

const _$ListItemSeparatorEnumMap = {
  ListItemSeparator.divider: 'divider',
  ListItemSeparator.space: 'space',
};

const _$MainAxisAlignmentCEnumMap = {
  MainAxisAlignmentC.start: 'start',
  MainAxisAlignmentC.center: 'center',
  MainAxisAlignmentC.end: 'end',
  MainAxisAlignmentC.spaceBetween: 'spaceBetween',
  MainAxisAlignmentC.spaceAround: 'spaceAround',
  MainAxisAlignmentC.spaceEvenly: 'spaceEvenly',
};
