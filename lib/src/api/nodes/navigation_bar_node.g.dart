// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_bar_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NavigationBarNode _$NavigationBarNodeFromJson(Map json) => NavigationBarNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      outerBoxLocal: json['outerBoxLocal'] == null
          ? null
          : OuterNodeBox.fromJson(json['outerBoxLocal'] as Map),
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      visible: json['visible'] as bool? ?? true,
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding'] as Map),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin'] as Map),
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
  final val = <String, dynamic>{
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
    'variables': instance.variables,
    'multipleVariables': instance.multipleVariables,
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
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
    'outerBoxLocal': instance.outerBoxLocal.toJson(),
    'basicBoxLocal': instance.basicBoxLocal.toJson(),
    'margin': instance.margin.toJson(),
    'padding': instance.padding.toJson(),
    'rotation': instance.rotationDegrees,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('widthFactor', instance.widthFactor);
  writeNotNull('heightFactor', instance.heightFactor);
  val['type'] = instance.type;
  val['currentIndex'] = instance.currentIndex;
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
          : ColorRGBA.fromJson(json['backgroundColor'] as Map),
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
      selectedLabelStyle: json['selectedLabelStyle'] == null
          ? null
          : TextProp.fromJson(json['selectedLabelStyle'] as Map),
      unselectedLabelStyle: json['unselectedLabelStyle'] == null
          ? null
          : TextProp.fromJson(json['unselectedLabelStyle'] as Map),
      unselectedIconColor: json['unselectedIconColor'] == null
          ? null
          : ColorRGBA.fromJson(json['unselectedIconColor'] as Map),
      selectedIconColor: json['selectedIconColor'] == null
          ? null
          : ColorRGBA.fromJson(json['selectedIconColor'] as Map),
      indicatorColor: json['indicatorColor'] == null
          ? null
          : ColorRGBA.fromJson(json['indicatorColor'] as Map),
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
    'makeNotched': instance.makeNotched,
    'notchMargin': instance.notchMargin,
    'styleDefinition': _$StyleDefinitionEnumMap[instance.styleDefinition]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('indicatorColor', instance.indicatorColor?.toJson());
  val['selectedLabelStyle'] = instance.selectedLabelStyle.toJson();
  val['unselectedLabelStyle'] = instance.unselectedLabelStyle.toJson();
  writeNotNull('unselectedIconColor', instance.unselectedIconColor?.toJson());
  writeNotNull('selectedIconColor', instance.selectedIconColor?.toJson());
  val['unselectedIconSize'] = instance.unselectedIconSize;
  val['selectedIconSize'] = instance.selectedIconSize;
  val['elevation'] = instance.elevation;
  writeNotNull('backgroundColor', instance.backgroundColor?.toJson());
  val['labelBehavior'] =
      _$MaterialNavigationBarLabelBehaviorEnumMap[instance.labelBehavior]!;
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
          : ColorRGBA.fromJson(json['backgroundColor'] as Map),
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
          : ColorRGBA.fromJson(json['selectedIconColor'] as Map),
      unselectedIconColor: json['unselectedIconColor'] == null
          ? null
          : ColorRGBA.fromJson(json['unselectedIconColor'] as Map),
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
    'makeNotched': instance.makeNotched,
    'notchMargin': instance.notchMargin,
    'styleDefinition': _$StyleDefinitionEnumMap[instance.styleDefinition]!,
    'navigationBarType':
        _$M2NavigationBarTypeEnumMap[instance.navigationBarType]!,
    'landscapeLayout':
        _$M2NavigationBarLandscapeLayoutEnumMap[instance.landscapeLayout]!,
    'selectedLabelStyle': instance.selectedLabelStyle.toJson(),
    'unselectedLabelStyle': instance.unselectedLabelStyle.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('unselectedIconColor', instance.unselectedIconColor?.toJson());
  writeNotNull('selectedIconColor', instance.selectedIconColor?.toJson());
  val['unselectedIconSize'] = instance.unselectedIconSize;
  val['selectedIconSize'] = instance.selectedIconSize;
  val['elevation'] = instance.elevation;
  writeNotNull('backgroundColor', instance.backgroundColor?.toJson());
  val['labelBehavior'] =
      _$MaterialNavigationBarLabelBehaviorEnumMap[instance.labelBehavior]!;
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
