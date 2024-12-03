// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expansion_tile_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpansionTileNode _$ExpansionTileNodeFromJson(Map json) => ExpansionTileNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
      isExpanded: json['isExpanded'] as bool?,
      listTileChild: json['listTileChild'] as String?,
      properties: ExpansionTileProperties.fromJson(
          Map<String, dynamic>.from(json['properties'] as Map)),
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
    )
      ..componentId = json['componentId'] as String?
      ..markerType =
          $enumDecodeNullable(_$ComponentMarkerTypeEnumMap, json['markerType'])
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..rowColumnType =
          $enumDecode(_$RowColumnTypeEnumMap, json['rowColumnType'])
      ..mainAxisAlignment =
          $enumDecode(_$MainAxisAlignmentCEnumMap, json['mainAxisAlignment'])
      ..crossAxisAlignment =
          $enumDecode(_$CrossAxisAlignmentCEnumMap, json['crossAxisAlignment'])
      ..type = json['type'] as String;

Map<String, dynamic> _$ExpansionTileNodeToJson(ExpansionTileNode instance) {
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
  writeNotNull('children', instance.children, instance.children, []);
  val['rowColumnType'] = _$RowColumnTypeEnumMap[instance.rowColumnType]!;
  val['mainAxisAlignment'] =
      _$MainAxisAlignmentCEnumMap[instance.mainAxisAlignment]!;
  val['crossAxisAlignment'] =
      _$CrossAxisAlignmentCEnumMap[instance.crossAxisAlignment]!;
  val['type'] = instance.type;
  val['isExpanded'] = instance.isExpanded;
  writeNotNull(
      'listTileChild', instance.listTileChild, instance.listTileChild, null);
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

const _$ComponentMarkerTypeEnumMap = {
  ComponentMarkerType.component: 'component',
  ComponentMarkerType.instance: 'instance',
};

const _$RowColumnTypeEnumMap = {
  RowColumnType.row: 'row',
  RowColumnType.column: 'column',
};

const _$MainAxisAlignmentCEnumMap = {
  MainAxisAlignmentC.start: 'start',
  MainAxisAlignmentC.center: 'center',
  MainAxisAlignmentC.end: 'end',
  MainAxisAlignmentC.spaceBetween: 'spaceBetween',
  MainAxisAlignmentC.spaceAround: 'spaceAround',
  MainAxisAlignmentC.spaceEvenly: 'spaceEvenly',
};

const _$CrossAxisAlignmentCEnumMap = {
  CrossAxisAlignmentC.start: 'start',
  CrossAxisAlignmentC.center: 'center',
  CrossAxisAlignmentC.end: 'end',
  CrossAxisAlignmentC.stretch: 'stretch',
  CrossAxisAlignmentC.baseline: 'baseline',
};

ExpansionTileProperties _$ExpansionTilePropertiesFromJson(Map json) =>
    ExpansionTileProperties(
      backgroundColor: json['backgroundColor'] == null
          ? ColorRGBA.transparent
          : ColorRGBA.fromJson(json['backgroundColor']),
      collapsedBackgroundColor: json['collapsedBackgroundColor'] == null
          ? ColorRGBA.transparent
          : ColorRGBA.fromJson(json['collapsedBackgroundColor']),
      initiallyExpanded: json['initiallyExpanded'] as bool? ?? false,
      maintainState: json['maintainState'] as bool? ?? false,
      tilePadding: json['tilePadding'] == null
          ? kDefaultListTileContentPadding
          : EdgeInsetsModel.fromJson(json['tilePadding']),
      expandedAlignment: json['expandedAlignment'] == null
          ? AlignmentModel.center
          : AlignmentModel.fromJson(json['expandedAlignment'] as Map),
      expandedCrossAxisAlignment: $enumDecodeNullable(
              _$CrossAxisAlignmentCEnumMap,
              json['expandedCrossAxisAlignment']) ??
          CrossAxisAlignmentC.center,
      childrenPadding: json['childrenPadding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['childrenPadding']),
      iconColor: json['iconColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['iconColor']),
      collapsedIconColor: json['collapsedIconColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['collapsedIconColor']),
      textColor: json['textColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['textColor']),
      collapsedTextColor: json['collapsedTextColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['collapsedTextColor']),
      controlAffinity: $enumDecodeNullable(
          _$ListTileControlAffinityCEnumMap, json['controlAffinity']),
      visualDensity: json['visualDensity'] == null
          ? VisualDensityModel.standard
          : VisualDensityModel.fromJson(
              Map<String, dynamic>.from(json['visualDensity'] as Map)),
      showDividers: json['showDividers'] as bool? ?? true,
    );

Map<String, dynamic> _$ExpansionTilePropertiesToJson(
    ExpansionTileProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('backgroundColor', instance.backgroundColor,
      instance.backgroundColor?.toJson(), ColorRGBA.transparent);
  writeNotNull('collapsedBackgroundColor', instance.collapsedBackgroundColor,
      instance.collapsedBackgroundColor?.toJson(), ColorRGBA.transparent);
  writeNotNull('initiallyExpanded', instance.initiallyExpanded,
      instance.initiallyExpanded, false);
  writeNotNull(
      'maintainState', instance.maintainState, instance.maintainState, false);
  writeNotNull('tilePadding', instance.tilePadding,
      instance.tilePadding?.toJson(), kDefaultListTileContentPadding);
  writeNotNull('expandedAlignment', instance.expandedAlignment,
      instance.expandedAlignment?.toJson(), AlignmentModel.center);
  writeNotNull(
      'expandedCrossAxisAlignment',
      instance.expandedCrossAxisAlignment,
      _$CrossAxisAlignmentCEnumMap[instance.expandedCrossAxisAlignment]!,
      CrossAxisAlignmentC.center);
  writeNotNull('childrenPadding', instance.childrenPadding,
      instance.childrenPadding?.toJson(), EdgeInsetsModel.zero);
  writeNotNull('iconColor', instance.iconColor, instance.iconColor?.toJson(),
      ColorRGBA.grey);
  writeNotNull('collapsedIconColor', instance.collapsedIconColor,
      instance.collapsedIconColor?.toJson(), ColorRGBA.grey);
  writeNotNull('textColor', instance.textColor, instance.textColor?.toJson(),
      ColorRGBA.grey);
  writeNotNull('collapsedTextColor', instance.collapsedTextColor,
      instance.collapsedTextColor?.toJson(), ColorRGBA.grey);
  writeNotNull('controlAffinity', instance.controlAffinity,
      _$ListTileControlAffinityCEnumMap[instance.controlAffinity], null);
  writeNotNull('visualDensity', instance.visualDensity,
      instance.visualDensity.toJson(), VisualDensityModel.standard);
  writeNotNull(
      'showDividers', instance.showDividers, instance.showDividers, true);
  return val;
}

const _$ListTileControlAffinityCEnumMap = {
  ListTileControlAffinityC.leading: 'leading',
  ListTileControlAffinityC.trailing: 'trailing',
  ListTileControlAffinityC.platform: 'platform',
};
