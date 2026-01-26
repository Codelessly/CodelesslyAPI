// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expansion_tile_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpansionTileNode _$ExpansionTileNodeFromJson(Map json) =>
    ExpansionTileNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        isExpanded: json['isExpanded'] as bool?,
        listTileChild: json['listTileChild'] as String?,
        properties: ExpansionTileProperties.fromJson(
          Map<String, dynamic>.from(json['properties'] as Map),
        ),
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
      ..rowColumnType = $enumDecode(
        _$RowColumnTypeEnumMap,
        json['rowColumnType'],
      )
      ..mainAxisAlignment = $enumDecode(
        _$MainAxisAlignmentCEnumMap,
        json['mainAxisAlignment'],
      )
      ..crossAxisAlignment = $enumDecode(
        _$CrossAxisAlignmentCEnumMap,
        json['crossAxisAlignment'],
      )
      ..type = json['type'] as String;

Map<String, dynamic> _$ExpansionTileNodeToJson(
  ExpansionTileNode instance,
) => <String, dynamic>{
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
  'children': instance.children,
  'rowColumnType': _$RowColumnTypeEnumMap[instance.rowColumnType]!,
  'mainAxisAlignment': _$MainAxisAlignmentCEnumMap[instance.mainAxisAlignment]!,
  'crossAxisAlignment':
      _$CrossAxisAlignmentCEnumMap[instance.crossAxisAlignment]!,
  'type': instance.type,
  'isExpanded': instance.isExpanded,
  'listTileChild': ?instance.listTileChild,
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
      expandedCrossAxisAlignment:
          $enumDecodeNullable(
            _$CrossAxisAlignmentCEnumMap,
            json['expandedCrossAxisAlignment'],
          ) ??
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
        _$ListTileControlAffinityCEnumMap,
        json['controlAffinity'],
      ),
      visualDensity: json['visualDensity'] == null
          ? VisualDensityModel.standard
          : VisualDensityModel.fromJson(
              Map<String, dynamic>.from(json['visualDensity'] as Map),
            ),
      showDividers: json['showDividers'] as bool? ?? true,
    );

Map<String, dynamic> _$ExpansionTilePropertiesToJson(
  ExpansionTileProperties instance,
) => <String, dynamic>{
  'backgroundColor': ?instance.backgroundColor?.toJson(),
  'collapsedBackgroundColor': ?instance.collapsedBackgroundColor?.toJson(),
  'initiallyExpanded': instance.initiallyExpanded,
  'maintainState': instance.maintainState,
  'tilePadding': ?instance.tilePadding?.toJson(),
  'expandedAlignment': instance.expandedAlignment.toJson(),
  'expandedCrossAxisAlignment':
      _$CrossAxisAlignmentCEnumMap[instance.expandedCrossAxisAlignment]!,
  'childrenPadding': ?instance.childrenPadding?.toJson(),
  'iconColor': ?instance.iconColor?.toJson(),
  'collapsedIconColor': ?instance.collapsedIconColor?.toJson(),
  'textColor': ?instance.textColor?.toJson(),
  'collapsedTextColor': ?instance.collapsedTextColor?.toJson(),
  'controlAffinity':
      ?_$ListTileControlAffinityCEnumMap[instance.controlAffinity],
  'visualDensity': instance.visualDensity.toJson(),
  'showDividers': instance.showDividers,
};

const _$ListTileControlAffinityCEnumMap = {
  ListTileControlAffinityC.leading: 'leading',
  ListTileControlAffinityC.trailing: 'trailing',
  ListTileControlAffinityC.platform: 'platform',
};
