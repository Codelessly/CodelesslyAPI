// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expansion_tile_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpansionTileNode _$ExpansionTileNodeFromJson(Map json) => ExpansionTileNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      isExpanded: json['isExpanded'] as bool?,
      listTileChild: json['listTileChild'] as String?,
      properties: ExpansionTileProperties.fromJson(
          Map<String, dynamic>.from(json['properties'] as Map)),
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
      children:
          (json['children'] as List<dynamic>).map((e) => e as String).toList(),
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
      ..rowColumnType =
          $enumDecode(_$RowColumnTypeEnumMap, json['rowColumnType'])
      ..mainAxisAlignment =
          $enumDecode(_$MainAxisAlignmentCEnumMap, json['mainAxisAlignment'])
      ..crossAxisAlignment =
          $enumDecode(_$CrossAxisAlignmentCEnumMap, json['crossAxisAlignment'])
      ..type = json['type'] as String;

Map<String, dynamic> _$ExpansionTileNodeToJson(ExpansionTileNode instance) {
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
  val['children'] = instance.children;
  val['rowColumnType'] = _$RowColumnTypeEnumMap[instance.rowColumnType]!;
  val['mainAxisAlignment'] =
      _$MainAxisAlignmentCEnumMap[instance.mainAxisAlignment]!;
  val['crossAxisAlignment'] =
      _$CrossAxisAlignmentCEnumMap[instance.crossAxisAlignment]!;
  val['type'] = instance.type;
  val['isExpanded'] = instance.isExpanded;
  writeNotNull('listTileChild', instance.listTileChild);
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
          : ColorRGBA.fromJson(json['backgroundColor'] as Map),
      collapsedBackgroundColor: json['collapsedBackgroundColor'] == null
          ? ColorRGBA.transparent
          : ColorRGBA.fromJson(json['collapsedBackgroundColor'] as Map),
      initiallyExpanded: json['initiallyExpanded'] as bool? ?? false,
      maintainState: json['maintainState'] as bool? ?? false,
      tilePadding: json['tilePadding'] == null
          ? kDefaultListTileContentPadding
          : EdgeInsetsModel.fromJson(json['tilePadding'] as Map),
      expandedAlignment: json['expandedAlignment'] == null
          ? AlignmentModel.center
          : AlignmentModel.fromJson(json['expandedAlignment'] as Map),
      expandedCrossAxisAlignment: $enumDecodeNullable(
              _$CrossAxisAlignmentCEnumMap,
              json['expandedCrossAxisAlignment']) ??
          CrossAxisAlignmentC.center,
      childrenPadding: json['childrenPadding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['childrenPadding'] as Map),
      iconColor: json['iconColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['iconColor'] as Map),
      collapsedIconColor: json['collapsedIconColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['collapsedIconColor'] as Map),
      textColor: json['textColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['textColor'] as Map),
      collapsedTextColor: json['collapsedTextColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['collapsedTextColor'] as Map),
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

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('backgroundColor', instance.backgroundColor?.toJson());
  writeNotNull(
      'collapsedBackgroundColor', instance.collapsedBackgroundColor?.toJson());
  val['initiallyExpanded'] = instance.initiallyExpanded;
  val['maintainState'] = instance.maintainState;
  writeNotNull('tilePadding', instance.tilePadding?.toJson());
  writeNotNull('expandedAlignment', instance.expandedAlignment?.toJson());
  val['expandedCrossAxisAlignment'] =
      _$CrossAxisAlignmentCEnumMap[instance.expandedCrossAxisAlignment]!;
  writeNotNull('childrenPadding', instance.childrenPadding?.toJson());
  writeNotNull('iconColor', instance.iconColor?.toJson());
  writeNotNull('collapsedIconColor', instance.collapsedIconColor?.toJson());
  writeNotNull('textColor', instance.textColor?.toJson());
  writeNotNull('collapsedTextColor', instance.collapsedTextColor?.toJson());
  writeNotNull('controlAffinity',
      _$ListTileControlAffinityCEnumMap[instance.controlAffinity]);
  val['visualDensity'] = instance.visualDensity.toJson();
  val['showDividers'] = instance.showDividers;
  return val;
}

const _$ListTileControlAffinityCEnumMap = {
  ListTileControlAffinityC.leading: 'leading',
  ListTileControlAffinityC.trailing: 'trailing',
  ListTileControlAffinityC.platform: 'platform',
};
