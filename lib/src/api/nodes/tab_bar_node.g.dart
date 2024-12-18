// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_bar_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TabBarNode _$TabBarNodeFromJson(Map json) => TabBarNode(
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
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
      properties: TabBarProperties.fromJson(json['properties'] as Map),
      isScrollable: json['isScrollable'] as bool? ?? false,
      physics: $enumDecodeNullable(_$ScrollPhysicsCEnumMap, json['physics'],
              unknownValue: ScrollPhysicsC.platformDependent) ??
          ScrollPhysicsC.platformDependent,
      initialIndex: (json['initialIndex'] as num?)?.toInt() ?? 0,
      shouldAlwaysScroll: json['shouldAlwaysScroll'] as bool? ?? true,
    )
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..componentId = json['componentId'] as String?
      ..markerType =
          $enumDecodeNullable(_$ComponentMarkerTypeEnumMap, json['markerType'])
      ..componentVersion = (json['componentVersion'] as num?)?.toInt() ?? 1
      ..componentSchema = (json['componentSchema'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e),
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
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('variables', instance.variables, instance.variables, {});
  writeNotNull('multipleVariables', instance.multipleVariables,
      instance.multipleVariables, {});
  writeNotNull('componentId', instance.componentId, instance.componentId, null);
  writeNotNull('markerType', instance.markerType,
      _$ComponentMarkerTypeEnumMap[instance.markerType], null);
  writeNotNull('componentVersion', instance.componentVersion,
      instance.componentVersion, 1);
  writeNotNull('componentSchema', instance.componentSchema,
      instance.componentSchema, {});
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
  writeNotNull('reactions', instance.reactions,
      instance.reactions.map((e) => e.toJson()).toList(), const []);
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
  writeNotNull(
      'isScrollable', instance.isScrollable, instance.isScrollable, false);
  val['scrollDirection'] = _$AxisCEnumMap[instance.scrollDirection]!;
  val['reverse'] = instance.reverse;
  val['primary'] = instance.primary;
  writeNotNull(
      'physics',
      instance.physics,
      _$ScrollPhysicsCEnumMap[instance.physics]!,
      ScrollPhysicsC.platformDependent);
  val['keyboardDismissBehavior'] = _$ScrollViewKeyboardDismissBehaviorCEnumMap[
      instance.keyboardDismissBehavior]!;
  val['useFlutterListView'] = instance.useFlutterListView;
  writeNotNull('shouldAlwaysScroll', instance.shouldAlwaysScroll,
      instance.shouldAlwaysScroll, true);
  val['type'] = instance.type;
  val['properties'] = instance.properties.toJson();
  writeNotNull('initialIndex', instance.initialIndex, instance.initialIndex, 0);
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
  ScrollPhysicsC.platformDependent: 'platformDependent',
  ScrollPhysicsC.bouncingScrollPhysics: 'bouncingScrollPhysics',
  ScrollPhysicsC.clampingScrollPhysics: 'clampingScrollPhysics',
  ScrollPhysicsC.neverScrollableScrollPhysics: 'neverScrollableScrollPhysics',
  ScrollPhysicsC.rangeMaintainingScrollPhysics: 'rangeMaintainingScrollPhysics',
};

const _$ComponentMarkerTypeEnumMap = {
  ComponentMarkerType.component: 'component',
  ComponentMarkerType.instance: 'instance',
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
          [],
      indicatorColor: json['indicatorColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['indicatorColor']),
      indicatorWeight: (json['indicatorWeight'] as num?)?.toDouble() ?? 2.0,
      indicatorSize: $enumDecodeNullable(
              _$TabBarIndicatorSizeEnumEnumMap, json['indicatorSize']) ??
          TabBarIndicatorSizeEnum.tab,
      labelColor: json['labelColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['labelColor']),
      unselectedLabelColor: json['unselectedLabelColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['unselectedLabelColor']),
      labelStyle: json['labelStyle'] == null
          ? null
          : TextProp.fromJson(json['labelStyle'] as Map),
      unselectedLabelStyle: json['unselectedLabelStyle'] == null
          ? null
          : TextProp.fromJson(json['unselectedLabelStyle'] as Map),
      overlayColor: json['overlayColor'] == null
          ? ColorRGBA.grey10
          : ColorRGBA.fromJson(json['overlayColor']),
      indicatorPadding: json['indicatorPadding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['indicatorPadding']),
      dividerColor: json['dividerColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['dividerColor']),
      labelPadding: json['labelPadding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['labelPadding']),
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
          : CornerRadius.fromJson(json['indicatorCornerRadius']),
    );

Map<String, dynamic> _$TabBarPropertiesToJson(TabBarProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('tabs', instance.tabs,
      instance.tabs.map((e) => e.toJson()).toList(), const []);
  writeNotNull('indicatorColor', instance.indicatorColor,
      instance.indicatorColor.toJson(), ColorRGBA.black);
  writeNotNull('indicatorWeight', instance.indicatorWeight,
      instance.indicatorWeight, 2.0);
  writeNotNull(
      'indicatorSize',
      instance.indicatorSize,
      _$TabBarIndicatorSizeEnumEnumMap[instance.indicatorSize]!,
      TabBarIndicatorSizeEnum.tab);
  writeNotNull('labelColor', instance.labelColor, instance.labelColor?.toJson(),
      ColorRGBA.black);
  val['labelStyle'] = instance.labelStyle.toJson();
  writeNotNull('unselectedLabelColor', instance.unselectedLabelColor,
      instance.unselectedLabelColor?.toJson(), ColorRGBA.black);
  val['unselectedLabelStyle'] = instance.unselectedLabelStyle.toJson();
  writeNotNull('overlayColor', instance.overlayColor,
      instance.overlayColor?.toJson(), ColorRGBA.grey10);
  writeNotNull('indicatorPadding', instance.indicatorPadding,
      instance.indicatorPadding.toJson(), EdgeInsetsModel.zero);
  writeNotNull('labelPadding', instance.labelPadding,
      instance.labelPadding.toJson(), EdgeInsetsModel.zero);
  writeNotNull('dividerColor', instance.dividerColor,
      instance.dividerColor?.toJson(), ColorRGBA.black);
  writeNotNull('tabItemDirection', instance.tabItemDirection,
      _$AxisCEnumMap[instance.tabItemDirection]!, AxisC.horizontal);
  writeNotNull('gap', instance.gap, instance.gap, 10);
  writeNotNull(
      'contentType',
      instance.contentType,
      _$TabBarContentTypeEnumMap[instance.contentType]!,
      TabBarContentType.labelAndIcon);
  writeNotNull('showDivider', instance.showDivider, instance.showDivider, true);
  writeNotNull(
      'indicatorStyle',
      instance.indicatorStyle,
      _$TabIndicatorStyleEnumMap[instance.indicatorStyle]!,
      TabIndicatorStyle.underline);
  writeNotNull(
      'indicatorShape',
      instance.indicatorShape,
      _$CShapeBorderEnumMap[instance.indicatorShape]!,
      CShapeBorder.roundedRectangle);
  writeNotNull('indicatorCornerRadius', instance.indicatorCornerRadius,
      instance.indicatorCornerRadius.toJson(), CornerRadius.zero);
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
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => Reaction.fromJson(e as Map))
          .toList(),
      icon: json['icon'] == null
          ? const MultiSourceIconModel(size: 20, color: null)
          : MultiSourceIconModel.fromJson(json['icon'] as Map),
    );

Map<String, dynamic> _$TabItemToJson(TabItem instance) {
  final val = <String, dynamic>{
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
    'id': instance.id,
    'label': instance.label,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('icon', instance.icon, instance.icon.toJson(),
      const MultiSourceIconModel(size: 20, color: null));
  return val;
}
