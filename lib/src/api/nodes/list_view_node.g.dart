// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_view_node.dart';

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
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..ephemeral = json['ephemeral'] as bool? ?? false
      ..allowedTypes = (json['allowedTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList()
      ..deniedTypes = (json['deniedTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList()
      ..maxAllowedSize = json['maxAllowedSize'] == null
          ? null
          : SizeC.fromJson(json['maxAllowedSize'] as Map)
      ..isScrollable = json['isScrollable'] as bool
      ..useFlutterListView = json['useFlutterListView'] as bool
      ..type = json['type'] as String;

Map<String, dynamic> _$ListViewNodeToJson(ListViewNode instance) =>
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
      'aspectRatioLock': instance.aspectRatioLock,
      'alignment': instance.alignment.toJson(),
      'basicBoxLocal': instance.basicBoxLocal.toJson(),
      'margin': instance.margin.toJson(),
      'padding': instance.padding.toJson(),
      'rotation': instance.rotationDegrees,
      'widthFactor': ?instance.widthFactor,
      'heightFactor': ?instance.heightFactor,
      'enabled': instance.enabled,
      'children': instance.children,
      'ephemeral': instance.ephemeral,
      'allowedTypes': instance.allowedTypes,
      'deniedTypes': instance.deniedTypes,
      'maxAllowedSize': ?instance.maxAllowedSize?.toJson(),
      'clipsContent': instance.clipsContent,
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
      'whereFilters': instance.whereFilters.map((e) => e.toJson()).toList(),
      'orderByFilters': instance.orderByFilters.map((e) => e.toJson()).toList(),
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

ListViewProperties _$ListViewPropertiesFromJson(Map json) => ListViewProperties(
  itemCount: (json['itemCount'] as num?)?.toInt(),
  itemExtent: (json['itemExtent'] as num?)?.toDouble(),
  cacheExtent: (json['cacheExtent'] as num?)?.toDouble(),
  separator:
      $enumDecodeNullable(_$ListItemSeparatorEnumMap, json['separator']) ??
      ListItemSeparator.space,
  separatorSpacing: (json['separatorSpacing'] as num?)?.toDouble() ?? 0,
  hasSeparator: json['hasSeparator'] as bool? ?? false,
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
    };

const _$ListItemSeparatorEnumMap = {
  ListItemSeparator.divider: 'divider',
  ListItemSeparator.space: 'space',
};
