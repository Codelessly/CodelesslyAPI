// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expansion_tile_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ExpansionTileNodeOmitDefaults(
  ExpansionTileNode instance,
  Map<String, dynamic> json,
) {
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
  if (isJsonDefault(instance.interactionStates, {}))
    json.remove('interactionStates');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.variables, {})) json.remove('variables');
  if (isJsonDefault(instance.multipleVariables, {}))
    json.remove('multipleVariables');
  if (isJsonDefault(instance.componentVersion, 1))
    json.remove('componentVersion');
  if (isJsonDefault(instance.componentSchema, {}))
    json.remove('componentSchema');
  if (isJsonDefault(instance.reactions, const [])) json.remove('reactions');
  if (isJsonDefault(instance.children, [])) json.remove('children');
  return json;
}

Map<String, dynamic> _$ExpansionTilePropertiesOmitDefaults(
  ExpansionTileProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.backgroundColor, ColorRGBA.transparent))
    json.remove('backgroundColor');
  if (isJsonDefault(instance.collapsedBackgroundColor, ColorRGBA.transparent))
    json.remove('collapsedBackgroundColor');
  if (isJsonDefault(instance.initiallyExpanded, false))
    json.remove('initiallyExpanded');
  if (isJsonDefault(instance.maintainState, false))
    json.remove('maintainState');
  if (isJsonDefault(
    instance.tilePadding,
    EdgeInsetsModel.symmetric(horizontal: 16),
  ))
    json.remove('tilePadding');
  if (isJsonDefault(instance.expandedAlignment, AlignmentModel.center))
    json.remove('expandedAlignment');
  if (isJsonDefault(
    instance.expandedCrossAxisAlignment,
    CrossAxisAlignmentC.center,
  ))
    json.remove('expandedCrossAxisAlignment');
  if (isJsonDefault(instance.childrenPadding, EdgeInsetsModel.zero))
    json.remove('childrenPadding');
  if (isJsonDefault(instance.iconColor, ColorRGBA.grey))
    json.remove('iconColor');
  if (isJsonDefault(instance.collapsedIconColor, ColorRGBA.grey))
    json.remove('collapsedIconColor');
  if (isJsonDefault(instance.textColor, ColorRGBA.grey))
    json.remove('textColor');
  if (isJsonDefault(instance.collapsedTextColor, ColorRGBA.grey))
    json.remove('collapsedTextColor');
  if (isJsonDefault(instance.visualDensity, VisualDensityModel.standard))
    json.remove('visualDensity');
  if (isJsonDefault(instance.showDividers, true)) json.remove('showDividers');
  if (isJsonDefault(instance.showTrailingIcon, true))
    json.remove('showTrailingIcon');
  if (isJsonDefault(instance.cornerRadius, CornerRadius.zero))
    json.remove('cornerRadius');
  return json;
}

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
      ..interactionStates =
          (json['interactionStates'] as Map?)?.map(
            (k, e) => MapEntry(
              $enumDecode(_$InteractionStateEnumMap, k),
              (e as Map).map(
                (k, e) =>
                    MapEntry(k as String, Map<String, dynamic>.from(e as Map)),
              ),
            ),
          ) ??
          {}
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
  'interactionStates': instance.interactionStates.map(
    (k, e) => MapEntry(_$InteractionStateEnumMap[k]!, e),
  ),
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

const _$InteractionStateEnumMap = {
  InteractionState.hovered: 'hovered',
  InteractionState.focused: 'focused',
  InteractionState.pressed: 'pressed',
  InteractionState.selected: 'selected',
  InteractionState.disabled: 'disabled',
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
      tilePadding: _readLegacyTilePadding(json, 'tilePadding') == null
          ? kDefaultListTileContentPadding
          : EdgeInsetsModel.fromJson(
              _readLegacyTilePadding(json, 'tilePadding'),
            ),
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
      showTrailingIcon: json['showTrailingIcon'] as bool? ?? true,
      shape: $enumDecodeNullable(_$CShapeBorderEnumMap, json['shape']),
      collapsedShape: $enumDecodeNullable(
        _$CShapeBorderEnumMap,
        json['collapsedShape'],
      ),
      cornerRadius: json['cornerRadius'] == null
          ? CornerRadius.zero
          : CornerRadius.fromJson(json['cornerRadius']),
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
  'showTrailingIcon': instance.showTrailingIcon,
  'shape': ?_$CShapeBorderEnumMap[instance.shape],
  'collapsedShape': ?_$CShapeBorderEnumMap[instance.collapsedShape],
  'cornerRadius': instance.cornerRadius.toJson(),
};

const _$ListTileControlAffinityCEnumMap = {
  ListTileControlAffinityC.leading: 'leading',
  ListTileControlAffinityC.trailing: 'trailing',
  ListTileControlAffinityC.platform: 'platform',
};

const _$CShapeBorderEnumMap = {
  CShapeBorder.rectangle: 'rectangle',
  CShapeBorder.circle: 'circle',
  CShapeBorder.stadium: 'stadium',
  CShapeBorder.roundedRectangle: 'roundedRectangle',
  CShapeBorder.continuousRectangle: 'continuousRectangle',
  CShapeBorder.beveledRectangle: 'beveledRectangle',
  CShapeBorder.roundedSuperellipse: 'roundedSuperellipse',
};
