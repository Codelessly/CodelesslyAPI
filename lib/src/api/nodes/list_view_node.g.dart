// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_view_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListViewNode _$ListViewNodeFromJson(Map json) => ListViewNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
      visible: json['visible'] as bool? ?? true,
      enabled: json['enabled'] as bool? ?? true,
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
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
      verticalFit: $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
          SizeFit.fixed,
      flex: (json['flex'] as num?)?.toInt() ?? 1,
      constraints: json['constraints'] == null
          ? const BoxConstraintsModel()
          : BoxConstraintsModel.fromJson(json['constraints'] as Map),
      edgePins: json['edgePins'] == null
          ? EdgePinsModel.standard
          : EdgePinsModel.fromJson(
              Map<String, dynamic>.from(json['edgePins'] as Map)),
      aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
      positioningMode: $enumDecodeNullable(
              _$PositioningModeEnumMap, json['positioningMode']) ??
          PositioningMode.align,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          [],
      properties: ListViewProperties.fromJson(json['properties'] as Map),
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
      multipleVariables: (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {},
      clipsContent: json['clipsContent'] as bool? ?? true,
      useCloudDatabase: json['useCloudDatabase'] as bool? ?? false,
      collectionPath: json['collectionPath'] as String?,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      whereFilters: (json['whereFilters'] as List<dynamic>?)
          ?.map((e) =>
              WhereQueryFilter.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      orderByFilters: (json['orderByFilters'] as List<dynamic>?)
          ?.map((e) =>
              OrderByQueryFilter.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      scrollDirection:
          $enumDecodeNullable(_$AxisCEnumMap, json['scrollDirection']) ??
              AxisC.vertical,
      reverse: json['reverse'] as bool? ?? false,
      physics: $enumDecodeNullable(_$ScrollPhysicsCEnumMap, json['physics'],
              unknownValue: ScrollPhysicsC.platformDependent) ??
          ScrollPhysicsC.platformDependent,
      primary: json['primary'] as bool? ?? false,
      keyboardDismissBehavior: $enumDecodeNullable(
              _$ScrollViewKeyboardDismissBehaviorCEnumMap,
              json['keyboardDismissBehavior']) ??
          ScrollViewKeyboardDismissBehaviorC.manual,
      shouldAlwaysScroll: json['shouldAlwaysScroll'] as bool? ?? true,
    )
      ..componentId = json['componentId'] as String?
      ..markerType =
          $enumDecodeNullable(_$ComponentMarkerTypeEnumMap, json['markerType'])
      ..componentVersion = (json['componentVersion'] as num).toInt()
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

Map<String, dynamic> _$ListViewNodeToJson(ListViewNode instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('reactions', instance.reactions,
      instance.reactions.map((e) => e.toJson()).toList(), const []);
  writeNotNull('variables', instance.variables, instance.variables, {});
  writeNotNull('multipleVariables', instance.multipleVariables,
      instance.multipleVariables, {});
  writeNotNull('componentId', instance.componentId, instance.componentId, null);
  writeNotNull('markerType', instance.markerType,
      _$ComponentMarkerTypeEnumMap[instance.markerType], null);
  val['componentVersion'] = instance.componentVersion;
  val['id'] = instance.id;
  val['name'] = instance.name;
  writeNotNull('visible', instance.visible, instance.visible, true);
  if (!excludeConstraintsIf(instance)) {
    writeNotNull('constraints', instance.constraints,
        instance.constraints.toJson(), const BoxConstraintsModel());
  }
  writeNotNull('edgePins', instance.edgePins, instance.edgePins.toJson(),
      EdgePinsModel.standard);
  writeNotNull(
      'positioningMode',
      instance.positioningMode,
      _$PositioningModeEnumMap[instance.positioningMode]!,
      PositioningMode.align);
  writeNotNull('horizontalFit', instance.horizontalFit,
      _$SizeFitEnumMap[instance.horizontalFit]!, SizeFit.fixed);
  writeNotNull('verticalFit', instance.verticalFit,
      _$SizeFitEnumMap[instance.verticalFit]!, SizeFit.fixed);
  writeNotNull('flex', instance.flex, instance.flex, 1);
  writeNotNull('aspectRatioLock', instance.aspectRatioLock,
      instance.aspectRatioLock, false);
  writeNotNull('alignment', instance.alignment, instance.alignment.toJson(),
      AlignmentModel.none);
  val['basicBoxLocal'] = instance.basicBoxLocal.toJson();
  writeNotNull('margin', instance.margin, instance.margin.toJson(),
      EdgeInsetsModel.zero);
  writeNotNull('padding', instance.padding, instance.padding.toJson(),
      EdgeInsetsModel.zero);
  writeNotNull(
      'rotation', instance.rotationDegrees, instance.rotationDegrees, 0);
  writeNotNull('widthFactor', instance.widthFactor, instance.widthFactor, null);
  writeNotNull(
      'heightFactor', instance.heightFactor, instance.heightFactor, null);
  writeNotNull('enabled', instance.enabled, instance.enabled, true);
  writeNotNull('children', instance.children, instance.children, []);
  writeNotNull('ephemeral', instance.ephemeral, instance.ephemeral, false);
  val['allowedTypes'] = instance.allowedTypes;
  val['deniedTypes'] = instance.deniedTypes;
  writeNotNull('maxAllowedSize', instance.maxAllowedSize,
      instance.maxAllowedSize?.toJson(), null);
  writeNotNull(
      'clipsContent', instance.clipsContent, instance.clipsContent, true);
  val['isScrollable'] = instance.isScrollable;
  writeNotNull('scrollDirection', instance.scrollDirection,
      _$AxisCEnumMap[instance.scrollDirection]!, AxisC.vertical);
  writeNotNull('reverse', instance.reverse, instance.reverse, false);
  writeNotNull('primary', instance.primary, instance.primary, false);
  writeNotNull(
      'physics',
      instance.physics,
      _$ScrollPhysicsCEnumMap[instance.physics]!,
      ScrollPhysicsC.platformDependent);
  writeNotNull(
      'keyboardDismissBehavior',
      instance.keyboardDismissBehavior,
      _$ScrollViewKeyboardDismissBehaviorCEnumMap[
          instance.keyboardDismissBehavior]!,
      ScrollViewKeyboardDismissBehaviorC.manual);
  val['useFlutterListView'] = instance.useFlutterListView;
  writeNotNull('shouldAlwaysScroll', instance.shouldAlwaysScroll,
      instance.shouldAlwaysScroll, true);
  writeNotNull('useCloudDatabase', instance.useCloudDatabase,
      instance.useCloudDatabase, false);
  writeNotNull(
      'collectionPath', instance.collectionPath, instance.collectionPath, null);
  writeNotNull('limit', instance.limit, instance.limit, 20);
  val['whereFilters'] = instance.whereFilters.map((e) => e.toJson()).toList();
  val['orderByFilters'] =
      instance.orderByFilters.map((e) => e.toJson()).toList();
  val['type'] = instance.type;
  val['properties'] = instance.properties.toJson();
  return val;
}

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

Map<String, dynamic> _$ListViewPropertiesToJson(ListViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('itemCount', instance.itemCount, instance.itemCount, null);
  writeNotNull('itemExtent', instance.itemExtent, instance.itemExtent, null);
  writeNotNull('cacheExtent', instance.cacheExtent, instance.cacheExtent, null);
  writeNotNull('separatorSpacing', instance.separatorSpacing,
      instance.separatorSpacing, 0);
  writeNotNull('separator', instance.separator,
      _$ListItemSeparatorEnumMap[instance.separator]!, ListItemSeparator.space);
  writeNotNull(
      'hasSeparator', instance.hasSeparator, instance.hasSeparator, false);
  val['dividerProperties'] = instance.dividerProperties.toJson();
  return val;
}

const _$ListItemSeparatorEnumMap = {
  ListItemSeparator.divider: 'divider',
  ListItemSeparator.space: 'space',
};
