// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_bar_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NavigationBarNode _$NavigationBarNodeFromJson(Map json) => NavigationBarNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      visible: json['visible'] as bool? ?? true,
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding']),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin']),
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          const [],
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
      currentIndex: json['currentIndex'] as int? ?? 0,
      properties: navigationBarPropertiesFromJson(json['properties'] as Map),
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
      multipleVariables: (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {},
    )
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$NavigationBarNodeToJson(NavigationBarNode instance) {
  final val = <String, dynamic>{};

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool listsEqual(List? a, List? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool mapsEqual(Map? a, Map? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final k in a.keys) {
      var bValue = b[k];
      if (bValue == null && !b.containsKey(k)) return false;
      if (bValue != a[k]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool setsEqual(Set? a, Set? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    return a.containsAll(b);
  }

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    if (value == null) return;
    bool areEqual = false;
    if (value is List) {
      areEqual = listsEqual(value, defaultValue);
    } else if (value is Map) {
      areEqual = mapsEqual(value, defaultValue);
    } else if (value is Set) {
      areEqual = setsEqual(value, defaultValue);
    } else {
      areEqual = value == defaultValue;
    }

    if (!areEqual) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('reactions', instance.reactions,
      instance.reactions.map((e) => e.toJson()).toList(), const []);
  writeNotNull('variables', instance.variables, instance.variables, {});
  writeNotNull('multipleVariables', instance.multipleVariables,
      instance.multipleVariables, {});
  val['id'] = instance.id;
  val['name'] = instance.name;
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
  val['type'] = instance.type;
  writeNotNull('currentIndex', instance.currentIndex, instance.currentIndex, 0);
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
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
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
      labelBehavior: $enumDecodeNullable(
              _$MaterialNavigationBarLabelBehaviorEnumMap,
              json['labelBehavior']) ??
          MaterialNavigationBarLabelBehavior.alwaysShow,
    )..styleDefinition =
        $enumDecode(_$StyleDefinitionEnumMap, json['styleDefinition']);

Map<String, dynamic> _$M3NavigationBarPropertiesToJson(
    M3NavigationBarProperties instance) {
  final val = <String, dynamic>{
    'items': instance.items.map((e) => e.toJson()).toList(),
  };

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool listsEqual(List? a, List? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool mapsEqual(Map? a, Map? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final k in a.keys) {
      var bValue = b[k];
      if (bValue == null && !b.containsKey(k)) return false;
      if (bValue != a[k]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool setsEqual(Set? a, Set? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    return a.containsAll(b);
  }

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    if (value == null) return;
    bool areEqual = false;
    if (value is List) {
      areEqual = listsEqual(value, defaultValue);
    } else if (value is Map) {
      areEqual = mapsEqual(value, defaultValue);
    } else if (value is Set) {
      areEqual = setsEqual(value, defaultValue);
    } else {
      areEqual = value == defaultValue;
    }

    if (!areEqual) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'makeNotched', instance.makeNotched, instance.makeNotched, false);
  writeNotNull('notchMargin', instance.notchMargin, instance.notchMargin, 4);
  val['styleDefinition'] = _$StyleDefinitionEnumMap[instance.styleDefinition]!;
  writeNotNull('indicatorColor', instance.indicatorColor,
      instance.indicatorColor?.toJson(), null);
  val['selectedLabelStyle'] = instance.selectedLabelStyle.toJson();
  val['unselectedLabelStyle'] = instance.unselectedLabelStyle.toJson();
  writeNotNull('unselectedIconColor', instance.unselectedIconColor,
      instance.unselectedIconColor?.toJson(), null);
  writeNotNull('selectedIconColor', instance.selectedIconColor,
      instance.selectedIconColor?.toJson(), null);
  writeNotNull('unselectedIconSize', instance.unselectedIconSize,
      instance.unselectedIconSize, 24);
  writeNotNull('selectedIconSize', instance.selectedIconSize,
      instance.selectedIconSize, 24);
  writeNotNull('elevation', instance.elevation, instance.elevation, 0);
  writeNotNull('backgroundColor', instance.backgroundColor,
      instance.backgroundColor?.toJson(), null);
  writeNotNull(
      'labelBehavior',
      instance.labelBehavior,
      _$MaterialNavigationBarLabelBehaviorEnumMap[instance.labelBehavior]!,
      MaterialNavigationBarLabelBehavior.alwaysShow);
  return val;
}

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
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
      navigationBarType: $enumDecodeNullable(
              _$M2NavigationBarTypeEnumMap, json['navigationBarType']) ??
          M2NavigationBarType.fixed,
      landscapeLayout: $enumDecodeNullable(
              _$M2NavigationBarLandscapeLayoutEnumMap,
              json['landscapeLayout']) ??
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
      labelBehavior: $enumDecodeNullable(
              _$MaterialNavigationBarLabelBehaviorEnumMap,
              json['labelBehavior']) ??
          MaterialNavigationBarLabelBehavior.alwaysShow,
    )..styleDefinition =
        $enumDecode(_$StyleDefinitionEnumMap, json['styleDefinition']);

Map<String, dynamic> _$M2NavigationBarPropertiesToJson(
    M2NavigationBarProperties instance) {
  final val = <String, dynamic>{
    'items': instance.items.map((e) => e.toJson()).toList(),
  };

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool listsEqual(List? a, List? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool mapsEqual(Map? a, Map? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final k in a.keys) {
      var bValue = b[k];
      if (bValue == null && !b.containsKey(k)) return false;
      if (bValue != a[k]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool setsEqual(Set? a, Set? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    return a.containsAll(b);
  }

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    if (value == null) return;
    bool areEqual = false;
    if (value is List) {
      areEqual = listsEqual(value, defaultValue);
    } else if (value is Map) {
      areEqual = mapsEqual(value, defaultValue);
    } else if (value is Set) {
      areEqual = setsEqual(value, defaultValue);
    } else {
      areEqual = value == defaultValue;
    }

    if (!areEqual) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'makeNotched', instance.makeNotched, instance.makeNotched, false);
  writeNotNull('notchMargin', instance.notchMargin, instance.notchMargin, 4);
  val['styleDefinition'] = _$StyleDefinitionEnumMap[instance.styleDefinition]!;
  writeNotNull(
      'navigationBarType',
      instance.navigationBarType,
      _$M2NavigationBarTypeEnumMap[instance.navigationBarType]!,
      M2NavigationBarType.fixed);
  writeNotNull(
      'landscapeLayout',
      instance.landscapeLayout,
      _$M2NavigationBarLandscapeLayoutEnumMap[instance.landscapeLayout]!,
      M2NavigationBarLandscapeLayout.spread);
  val['selectedLabelStyle'] = instance.selectedLabelStyle.toJson();
  val['unselectedLabelStyle'] = instance.unselectedLabelStyle.toJson();
  writeNotNull('unselectedIconColor', instance.unselectedIconColor,
      instance.unselectedIconColor?.toJson(), null);
  writeNotNull('selectedIconColor', instance.selectedIconColor,
      instance.selectedIconColor?.toJson(), null);
  writeNotNull('unselectedIconSize', instance.unselectedIconSize,
      instance.unselectedIconSize, 24);
  writeNotNull('selectedIconSize', instance.selectedIconSize,
      instance.selectedIconSize, 24);
  writeNotNull('elevation', instance.elevation, instance.elevation, 0);
  writeNotNull('backgroundColor', instance.backgroundColor,
      instance.backgroundColor?.toJson(), null);
  writeNotNull(
      'labelBehavior',
      instance.labelBehavior,
      _$MaterialNavigationBarLabelBehaviorEnumMap[instance.labelBehavior]!,
      MaterialNavigationBarLabelBehavior.alwaysShow);
  return val;
}

const _$M2NavigationBarTypeEnumMap = {
  M2NavigationBarType.fixed: 'fixed',
  M2NavigationBarType.shifting: 'shifting',
};

const _$M2NavigationBarLandscapeLayoutEnumMap = {
  M2NavigationBarLandscapeLayout.spread: 'spread',
  M2NavigationBarLandscapeLayout.centered: 'centered',
  M2NavigationBarLandscapeLayout.linear: 'linear',
};
