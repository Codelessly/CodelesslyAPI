// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grid_view_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GridViewNode _$GridViewNodeFromJson(Map json) => GridViewNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
      visible: json['visible'] as bool? ?? true,
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
      flex: json['flex'] as int? ?? 1,
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
      properties: GridViewProperties.fromJson(json['properties'] as Map),
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
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
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

Map<String, dynamic> _$GridViewNodeToJson(GridViewNode instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('visible', instance.visible, instance.visible, true);
  if (!excludeConstraintsIf(instance)) {
    writeNotNull('constraints', instance.constraints,
        instance.constraints.toJson(), const BoxConstraintsModel());
  }
  if (!excludeEdgePinsIf(instance)) {
    writeNotNull('edgePins', instance.edgePins, instance.edgePins.toJson(),
        EdgePinsModel.standard);
  }
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
  writeNotNull('reactions', instance.reactions,
      instance.reactions.map((e) => e.toJson()).toList(), const []);
  writeNotNull('variables', instance.variables, instance.variables, {});
  writeNotNull('multipleVariables', instance.multipleVariables,
      instance.multipleVariables, {});
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
  writeNotNull('children', instance.children, instance.children, []);
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

GridViewProperties _$GridViewPropertiesFromJson(Map json) => GridViewProperties(
      itemCount: json['itemCount'] as int?,
      cacheExtent: (json['cacheExtent'] as num?)?.toDouble(),
      gridDelegate:
          GridDelegateProperties.fromJson(json['gridDelegate'] as Map),
    );

Map<String, dynamic> _$GridViewPropertiesToJson(GridViewProperties instance) {
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
  writeNotNull('cacheExtent', instance.cacheExtent, instance.cacheExtent, null);
  val['gridDelegate'] = instance.gridDelegate.toJson();
  return val;
}

FixedCrossAxisCountGridDelegateProperties
    _$FixedCrossAxisCountGridDelegatePropertiesFromJson(Map json) =>
        FixedCrossAxisCountGridDelegateProperties(
          crossAxisCount: json['crossAxisCount'] as int,
          mainAxisSpacing: (json['mainAxisSpacing'] as num?)?.toDouble() ?? 0,
          crossAxisSpacing: (json['crossAxisSpacing'] as num?)?.toDouble() ?? 0,
          childAspectRatio: (json['childAspectRatio'] as num?)?.toDouble() ?? 1,
          mainAxisExtent: (json['mainAxisExtent'] as num?)?.toDouble(),
        );

Map<String, dynamic> _$FixedCrossAxisCountGridDelegatePropertiesToJson(
    FixedCrossAxisCountGridDelegateProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'mainAxisSpacing', instance.mainAxisSpacing, instance.mainAxisSpacing, 0);
  writeNotNull('crossAxisSpacing', instance.crossAxisSpacing,
      instance.crossAxisSpacing, 0);
  writeNotNull('childAspectRatio', instance.childAspectRatio,
      instance.childAspectRatio, 1);
  writeNotNull(
      'mainAxisExtent', instance.mainAxisExtent, instance.mainAxisExtent, null);
  val['crossAxisCount'] = instance.crossAxisCount;
  return val;
}

MaxCrossAxisExtentGridDelegateProperties
    _$MaxCrossAxisExtentGridDelegatePropertiesFromJson(Map json) =>
        MaxCrossAxisExtentGridDelegateProperties(
          maxCrossAxisExtent: (json['maxCrossAxisExtent'] as num).toDouble(),
          mainAxisSpacing: (json['mainAxisSpacing'] as num?)?.toDouble() ?? 0,
          crossAxisSpacing: (json['crossAxisSpacing'] as num?)?.toDouble() ?? 0,
          childAspectRatio: (json['childAspectRatio'] as num?)?.toDouble() ?? 1,
          mainAxisExtent: (json['mainAxisExtent'] as num?)?.toDouble(),
        );

Map<String, dynamic> _$MaxCrossAxisExtentGridDelegatePropertiesToJson(
    MaxCrossAxisExtentGridDelegateProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'mainAxisSpacing', instance.mainAxisSpacing, instance.mainAxisSpacing, 0);
  writeNotNull('crossAxisSpacing', instance.crossAxisSpacing,
      instance.crossAxisSpacing, 0);
  writeNotNull('childAspectRatio', instance.childAspectRatio,
      instance.childAspectRatio, 1);
  writeNotNull(
      'mainAxisExtent', instance.mainAxisExtent, instance.mainAxisExtent, null);
  val['maxCrossAxisExtent'] = instance.maxCrossAxisExtent;
  return val;
}
