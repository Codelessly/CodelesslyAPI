// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_bar_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$TabBarNodeOmitDefaults(
  TabBarNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.initialIndex, 0)) json.remove('initialIndex');
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
  if (isJsonDefault(instance.aspectRatioLock, false))
    json.remove('aspectRatioLock');
  if (isJsonDefault(instance.alignment, AlignmentModel.none))
    json.remove('alignment');
  if (isJsonDefault(instance.margin, EdgeInsetsModel.zero))
    json.remove('margin');
  if (isJsonDefault(instance.padding, EdgeInsetsModel.zero))
    json.remove('padding');
  if (isJsonDefault(instance.rotationDegrees, 0)) json.remove('rotation');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.variables, {})) json.remove('variables');
  if (isJsonDefault(instance.multipleVariables, {}))
    json.remove('multipleVariables');
  if (isJsonDefault(instance.componentVersion, 1))
    json.remove('componentVersion');
  if (isJsonDefault(instance.componentSchema, {}))
    json.remove('componentSchema');
  if (isJsonDefault(instance.reactions, const [])) json.remove('reactions');
  if (isJsonDefault(instance.isScrollable, false)) json.remove('isScrollable');
  if (isJsonDefault(instance.physics, ScrollPhysicsC.platformDependent))
    json.remove('physics');
  if (isJsonDefault(instance.shouldAlwaysScroll, true))
    json.remove('shouldAlwaysScroll');
  return json;
}

Map<String, dynamic> _$TabBarPropertiesOmitDefaults(
  TabBarProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.tabs, const [])) json.remove('tabs');
  if (isJsonDefault(instance.indicatorColor, ColorRGBA.black))
    json.remove('indicatorColor');
  if (isJsonDefault(instance.indicatorWeight, 2.0))
    json.remove('indicatorWeight');
  if (isJsonDefault(instance.indicatorSize, TabBarIndicatorSizeEnum.tab))
    json.remove('indicatorSize');
  if (isJsonDefault(instance.labelColor, ColorRGBA.black))
    json.remove('labelColor');
  if (isJsonDefault(instance.unselectedLabelColor, ColorRGBA.black))
    json.remove('unselectedLabelColor');
  if (isJsonDefault(instance.overlayColor, ColorRGBA.grey10))
    json.remove('overlayColor');
  if (isJsonDefault(instance.indicatorPadding, EdgeInsetsModel.zero))
    json.remove('indicatorPadding');
  if (isJsonDefault(instance.labelPadding, EdgeInsetsModel.zero))
    json.remove('labelPadding');
  if (isJsonDefault(instance.dividerColor, ColorRGBA.black))
    json.remove('dividerColor');
  if (isJsonDefault(instance.tabItemDirection, AxisC.horizontal))
    json.remove('tabItemDirection');
  if (isJsonDefault(instance.gap, 10)) json.remove('gap');
  if (isJsonDefault(instance.contentType, TabBarContentType.labelAndIcon))
    json.remove('contentType');
  if (isJsonDefault(instance.showDivider, true)) json.remove('showDivider');
  if (isJsonDefault(instance.indicatorStyle, TabIndicatorStyle.underline))
    json.remove('indicatorStyle');
  if (isJsonDefault(instance.indicatorShape, CShapeBorder.roundedRectangle))
    json.remove('indicatorShape');
  if (isJsonDefault(instance.indicatorCornerRadius, CornerRadius.zero))
    json.remove('indicatorCornerRadius');
  return json;
}

Map<String, dynamic> _$TabItemOmitDefaults(
  TabItem instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(
    instance.icon,
    const MultiSourceIconModel(size: 20, color: null),
  ))
    json.remove('icon');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TabBarNode _$TabBarNodeFromJson(Map json) =>
    TabBarNode(
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
        variables:
            (json['variables'] as Map?)?.map(
              (k, e) => MapEntry(k as String, e as String),
            ) ??
            {},
        properties: TabBarProperties.fromJson(json['properties'] as Map),
        isScrollable: json['isScrollable'] as bool? ?? false,
        physics:
            $enumDecodeNullable(
              _$ScrollPhysicsCEnumMap,
              json['physics'],
              unknownValue: ScrollPhysicsC.platformDependent,
            ) ??
            ScrollPhysicsC.platformDependent,
        initialIndex: (json['initialIndex'] as num?)?.toInt() ?? 0,
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
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..scrollDirection = $enumDecode(_$AxisCEnumMap, json['scrollDirection'])
      ..reverse = json['reverse'] as bool
      ..primary = json['primary'] as bool
      ..keyboardDismissBehavior = $enumDecode(
        _$ScrollViewKeyboardDismissBehaviorCEnumMap,
        json['keyboardDismissBehavior'],
      )
      ..useFlutterListView = json['useFlutterListView'] as bool
      ..type = json['type'] as String;

Map<String, dynamic> _$TabBarNodeToJson(TabBarNode instance) =>
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
      'aspectRatioLock': instance.aspectRatioLock,
      'alignment': instance.alignment.toJson(),
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'basicBoxLocal': instance.basicBoxLocal.toJson(),
      'margin': instance.margin.toJson(),
      'padding': instance.padding.toJson(),
      'rotation': instance.rotationDegrees,
      'widthFactor': ?instance.widthFactor,
      'heightFactor': ?instance.heightFactor,
      'enabled': instance.enabled,
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
      'initialIndex': instance.initialIndex,
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
  tabs:
      (json['tabs'] as List<dynamic>?)
          ?.map((e) => TabItem.fromJson(e as Map))
          .toList() ??
      const [],
  indicatorColor: json['indicatorColor'] == null
      ? ColorRGBA.black
      : ColorRGBA.fromJson(json['indicatorColor']),
  indicatorWeight: (json['indicatorWeight'] as num?)?.toDouble() ?? 2.0,
  indicatorSize:
      $enumDecodeNullable(
        _$TabBarIndicatorSizeEnumEnumMap,
        json['indicatorSize'],
      ) ??
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
  contentType:
      $enumDecodeNullable(_$TabBarContentTypeEnumMap, json['contentType']) ??
      TabBarContentType.labelAndIcon,
  showDivider: json['showDivider'] as bool? ?? true,
  indicatorStyle:
      $enumDecodeNullable(_$TabIndicatorStyleEnumMap, json['indicatorStyle']) ??
      TabIndicatorStyle.underline,
  indicatorShape:
      $enumDecodeNullable(_$CShapeBorderEnumMap, json['indicatorShape']) ??
      CShapeBorder.roundedRectangle,
  indicatorCornerRadius: json['indicatorCornerRadius'] == null
      ? CornerRadius.zero
      : CornerRadius.fromJson(json['indicatorCornerRadius']),
);

Map<String, dynamic> _$TabBarPropertiesToJson(
  TabBarProperties instance,
) => <String, dynamic>{
  'tabs': instance.tabs.map((e) => e.toJson()).toList(),
  'indicatorColor': instance.indicatorColor.toJson(),
  'indicatorWeight': instance.indicatorWeight,
  'indicatorSize': _$TabBarIndicatorSizeEnumEnumMap[instance.indicatorSize]!,
  'labelColor': ?instance.labelColor?.toJson(),
  'labelStyle': instance.labelStyle.toJson(),
  'unselectedLabelColor': ?instance.unselectedLabelColor?.toJson(),
  'unselectedLabelStyle': instance.unselectedLabelStyle.toJson(),
  'overlayColor': ?instance.overlayColor?.toJson(),
  'indicatorPadding': instance.indicatorPadding.toJson(),
  'labelPadding': instance.labelPadding.toJson(),
  'dividerColor': ?instance.dividerColor?.toJson(),
  'tabItemDirection': _$AxisCEnumMap[instance.tabItemDirection]!,
  'gap': instance.gap,
  'contentType': _$TabBarContentTypeEnumMap[instance.contentType]!,
  'showDivider': instance.showDivider,
  'indicatorStyle': _$TabIndicatorStyleEnumMap[instance.indicatorStyle]!,
  'indicatorShape': _$CShapeBorderEnumMap[instance.indicatorShape]!,
  'indicatorCornerRadius': instance.indicatorCornerRadius.toJson(),
};

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

Map<String, dynamic> _$TabItemToJson(TabItem instance) => <String, dynamic>{
  'reactions': instance.reactions.map((e) => e.toJson()).toList(),
  'id': instance.id,
  'label': instance.label,
  'icon': instance.icon.toJson(),
};
