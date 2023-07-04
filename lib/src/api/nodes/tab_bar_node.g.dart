// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_bar_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TabBarNode _$TabBarNodeFromJson(Map json) => TabBarNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      outerBoxLocal: json['outerBoxLocal'] == null
          ? null
          : OuterNodeBox.fromJson(json['outerBoxLocal'] as Map),
      visible: json['visible'] as bool? ?? true,
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin'] as Map),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding'] as Map),
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
          const [],
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
      properties: TabBarProperties.fromJson(json['properties'] as Map),
      isScrollable: json['isScrollable'] as bool? ?? false,
      physics: $enumDecodeNullable(_$ScrollPhysicsCEnumMap, json['physics']) ??
          ScrollPhysicsC.alwaysScrollableScrollPhysics,
      initialIndex: json['initialIndex'] as int? ?? 0,
    )
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..scrollDirection = $enumDecode(_$AxisCEnumMap, json['scrollDirection'])
      ..reverse = json['reverse'] as bool
      ..primary = json['primary'] as bool
      ..keyboardDismissBehavior = $enumDecode(
          _$ScrollViewKeyboardDismissBehaviorCEnumMap,
          json['keyboardDismissBehavior'])
      ..useFlutterListView = json['useFlutterListView'] as bool
      ..type = json['type'] as String;

Map<String, dynamic> _$TabBarNodeToJson(TabBarNode instance) {
  final val = <String, dynamic>{
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
  val['isScrollable'] = instance.isScrollable;
  val['scrollDirection'] = _$AxisCEnumMap[instance.scrollDirection]!;
  val['reverse'] = instance.reverse;
  val['primary'] = instance.primary;
  val['physics'] = _$ScrollPhysicsCEnumMap[instance.physics]!;
  val['keyboardDismissBehavior'] = _$ScrollViewKeyboardDismissBehaviorCEnumMap[
      instance.keyboardDismissBehavior]!;
  val['useFlutterListView'] = instance.useFlutterListView;
  val['type'] = instance.type;
  val['properties'] = instance.properties.toJson();
  val['initialIndex'] = instance.initialIndex;
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

const _$ScrollPhysicsCEnumMap = {
  ScrollPhysicsC.alwaysScrollableScrollPhysics: 'alwaysScrollableScrollPhysics',
  ScrollPhysicsC.bouncingScrollPhysics: 'bouncingScrollPhysics',
  ScrollPhysicsC.clampingScrollPhysics: 'clampingScrollPhysics',
  ScrollPhysicsC.neverScrollableScrollPhysics: 'neverScrollableScrollPhysics',
  ScrollPhysicsC.rangeMaintainingScrollPhysics: 'rangeMaintainingScrollPhysics',
};

const _$AxisCEnumMap = {
  AxisC.horizontal: 'horizontal',
  AxisC.vertical: 'vertical',
};

const _$ScrollViewKeyboardDismissBehaviorCEnumMap = {
  ScrollViewKeyboardDismissBehaviorC.manual: 'manual',
  ScrollViewKeyboardDismissBehaviorC.onDrag: 'onDrag',
};

TabBarProperties _$TabBarPropertiesFromJson(Map json) => TabBarProperties(
      tabs: (json['tabs'] as List<dynamic>?)
              ?.map((e) => TabItem.fromJson(e as Map))
              .toList() ??
          const [],
      indicatorColor: json['indicatorColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['indicatorColor'] as Map),
      indicatorWeight: (json['indicatorWeight'] as num?)?.toDouble() ?? 2.0,
      indicatorSize: $enumDecodeNullable(
              _$TabBarIndicatorSizeEnumEnumMap, json['indicatorSize']) ??
          TabBarIndicatorSizeEnum.tab,
      labelColor: json['labelColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['labelColor'] as Map),
      unselectedLabelColor: json['unselectedLabelColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['unselectedLabelColor'] as Map),
      labelStyle: json['labelStyle'] == null
          ? null
          : TextProp.fromJson(json['labelStyle'] as Map),
      unselectedLabelStyle: json['unselectedLabelStyle'] == null
          ? null
          : TextProp.fromJson(json['unselectedLabelStyle'] as Map),
      overlayColor: json['overlayColor'] == null
          ? ColorRGBA.grey10
          : ColorRGBA.fromJson(json['overlayColor'] as Map),
      indicatorPadding: json['indicatorPadding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['indicatorPadding'] as Map),
      dividerColor: json['dividerColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['dividerColor'] as Map),
      labelPadding: json['labelPadding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['labelPadding'] as Map),
      tabItemDirection:
          $enumDecodeNullable(_$AxisCEnumMap, json['tabItemDirection']) ??
              AxisC.horizontal,
      gap: (json['gap'] as num?)?.toDouble() ?? 10,
      contentType: $enumDecodeNullable(
              _$TabBarContentTypeEnumMap, json['contentType']) ??
          TabBarContentType.labelAndIcon,
      showDivider: json['showDivider'] as bool? ?? true,
      indicatorStyle: $enumDecodeNullable(
              _$TabIndicatorStyleEnumMap, json['indicatorStyle']) ??
          TabIndicatorStyle.underline,
      indicatorShape:
          $enumDecodeNullable(_$CShapeBorderEnumMap, json['indicatorShape']) ??
              CShapeBorder.roundedRectangle,
      indicatorCornerRadius: json['indicatorCornerRadius'] == null
          ? CornerRadius.zero
          : CornerRadius.fromJson(json['indicatorCornerRadius'] as Map),
    );

Map<String, dynamic> _$TabBarPropertiesToJson(TabBarProperties instance) {
  final val = <String, dynamic>{
    'tabs': instance.tabs.map((e) => e.toJson()).toList(),
    'indicatorColor': instance.indicatorColor.toJson(),
    'indicatorWeight': instance.indicatorWeight,
    'indicatorSize': _$TabBarIndicatorSizeEnumEnumMap[instance.indicatorSize]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('labelColor', instance.labelColor?.toJson());
  val['labelStyle'] = instance.labelStyle.toJson();
  writeNotNull('unselectedLabelColor', instance.unselectedLabelColor?.toJson());
  val['unselectedLabelStyle'] = instance.unselectedLabelStyle.toJson();
  writeNotNull('overlayColor', instance.overlayColor?.toJson());
  val['indicatorPadding'] = instance.indicatorPadding.toJson();
  val['labelPadding'] = instance.labelPadding.toJson();
  writeNotNull('dividerColor', instance.dividerColor?.toJson());
  val['tabItemDirection'] = _$AxisCEnumMap[instance.tabItemDirection]!;
  val['gap'] = instance.gap;
  val['contentType'] = _$TabBarContentTypeEnumMap[instance.contentType]!;
  val['showDivider'] = instance.showDivider;
  val['indicatorStyle'] = _$TabIndicatorStyleEnumMap[instance.indicatorStyle]!;
  val['indicatorShape'] = _$CShapeBorderEnumMap[instance.indicatorShape]!;
  val['indicatorCornerRadius'] = instance.indicatorCornerRadius.toJson();
  return val;
}

const _$TabBarIndicatorSizeEnumEnumMap = {
  TabBarIndicatorSizeEnum.tab: 'tab',
  TabBarIndicatorSizeEnum.label: 'label',
};

const _$TabBarContentTypeEnumMap = {
  TabBarContentType.label: 'label',
  TabBarContentType.icon: 'icon',
  TabBarContentType.labelAndIcon: 'labelAndIcon',
};

const _$TabIndicatorStyleEnumMap = {
  TabIndicatorStyle.none: 'none',
  TabIndicatorStyle.underline: 'underline',
  TabIndicatorStyle.filled: 'filled',
  TabIndicatorStyle.border: 'border',
};

const _$CShapeBorderEnumMap = {
  CShapeBorder.rectangle: 'rectangle',
  CShapeBorder.circle: 'circle',
  CShapeBorder.stadium: 'stadium',
  CShapeBorder.roundedRectangle: 'roundedRectangle',
  CShapeBorder.continuousRectangle: 'continuousRectangle',
  CShapeBorder.beveledRectangle: 'beveledRectangle',
};

TabItem _$TabItemFromJson(Map json) => TabItem(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] == null
          ? const MultiSourceIconModel(size: 20, color: null)
          : MultiSourceIconModel.fromJson(json['icon'] as Map),
    );

Map<String, dynamic> _$TabItemToJson(TabItem instance) => <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'icon': instance.icon.toJson(),
    };
