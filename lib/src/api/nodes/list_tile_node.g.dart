// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_tile_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ListTileNodeOmitDefaults(
  ListTileNode instance,
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

Map<String, dynamic> _$ListTilePropertiesOmitDefaults(
  ListTileProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.isThreeLine, false)) json.remove('isThreeLine');
  if (isJsonDefault(instance.dense, false)) json.remove('dense');
  if (isJsonDefault(instance.visualDensity, VisualDensityModel.standard))
    json.remove('visualDensity');
  if (isJsonDefault(instance.contentPadding, kDefaultListTileContentPadding))
    json.remove('contentPadding');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.selected, false)) json.remove('selected');
  if (isJsonDefault(instance.autofocus, false)) json.remove('autofocus');
  if (isJsonDefault(instance.enableFeedback, true))
    json.remove('enableFeedback');
  if (isJsonDefault(instance.showLeading, true)) json.remove('showLeading');
  if (isJsonDefault(instance.showTitle, true)) json.remove('showTitle');
  if (isJsonDefault(instance.showSubtitle, true)) json.remove('showSubtitle');
  if (isJsonDefault(instance.showTrailing, true)) json.remove('showTrailing');
  if (isJsonDefault(instance.shape, CShapeBorder.rectangle))
    json.remove('shape');
  if (isJsonDefault(instance.cornerRadius, CornerRadius.zero))
    json.remove('cornerRadius');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListTileNode _$ListTileNodeFromJson(Map json) =>
    ListTileNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        leading: json['leading'] as String?,
        title: json['title'] as String?,
        subtitle: json['subtitle'] as String?,
        trailing: json['trailing'] as String?,
        properties: ListTileProperties.fromJson(json['properties'] as Map),
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
      ..type = json['type'] as String;

Map<String, dynamic> _$ListTileNodeToJson(ListTileNode instance) =>
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
      'children': instance.children,
      'type': instance.type,
      'leading': ?instance.leading,
      'title': ?instance.title,
      'subtitle': ?instance.subtitle,
      'trailing': ?instance.trailing,
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

ListTileProperties _$ListTilePropertiesFromJson(Map json) => ListTileProperties(
  showLeading: json['showLeading'] as bool? ?? true,
  showTitle: json['showTitle'] as bool? ?? true,
  showSubtitle: json['showSubtitle'] as bool? ?? true,
  showTrailing: json['showTrailing'] as bool? ?? true,
  isThreeLine: json['isThreeLine'] as bool? ?? false,
  dense: json['dense'] as bool? ?? false,
  visualDensity: json['visualDensity'] == null
      ? VisualDensityModel.standard
      : VisualDensityModel.fromJson(
          Map<String, dynamic>.from(json['visualDensity'] as Map),
        ),
  shape:
      $enumDecodeNullable(_$CShapeBorderEnumMap, json['shape']) ??
      CShapeBorder.rectangle,
  selectedColor: json['selectedColor'] == null
      ? null
      : ColorRGBA.fromJson(json['selectedColor']),
  iconColor: json['iconColor'] == null
      ? null
      : ColorRGBA.fromJson(json['iconColor']),
  textColor: json['textColor'] == null
      ? null
      : ColorRGBA.fromJson(json['textColor']),
  contentPadding: json['contentPadding'] == null
      ? kDefaultListTileContentPadding
      : EdgeInsetsModel.fromJson(json['contentPadding']),
  enabled: json['enabled'] as bool? ?? true,
  selected: json['selected'] as bool? ?? false,
  focusColor: json['focusColor'] == null
      ? null
      : ColorRGBA.fromJson(json['focusColor']),
  hoverColor: json['hoverColor'] == null
      ? null
      : ColorRGBA.fromJson(json['hoverColor']),
  autofocus: json['autofocus'] as bool? ?? false,
  cornerRadius: json['cornerRadius'] == null
      ? CornerRadius.zero
      : CornerRadius.fromJson(json['cornerRadius']),
  tileColor: json['tileColor'] == null
      ? null
      : ColorRGBA.fromJson(json['tileColor']),
  selectedTileColor: json['selectedTileColor'] == null
      ? null
      : ColorRGBA.fromJson(json['selectedTileColor']),
  enableFeedback: json['enableFeedback'] as bool? ?? true,
  horizontalTitleGap: (json['horizontalTitleGap'] as num?)?.toDouble(),
  minVerticalPadding: (json['minVerticalPadding'] as num?)?.toDouble(),
  minLeadingWidth: (json['minLeadingWidth'] as num?)?.toDouble(),
  borderColor: json['borderColor'] == null
      ? null
      : ColorRGBA.fromJson(json['borderColor']),
  borderWidth: (json['borderWidth'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ListTilePropertiesToJson(ListTileProperties instance) =>
    <String, dynamic>{
      'shape': _$CShapeBorderEnumMap[instance.shape]!,
      'cornerRadius': instance.cornerRadius.toJson(),
      'borderWidth': ?instance.borderWidth,
      'borderColor': ?instance.borderColor?.toJson(),
      'isThreeLine': instance.isThreeLine,
      'dense': instance.dense,
      'visualDensity': instance.visualDensity.toJson(),
      'selectedColor': ?instance.selectedColor?.toJson(),
      'iconColor': ?instance.iconColor?.toJson(),
      'textColor': ?instance.textColor?.toJson(),
      'contentPadding': instance.contentPadding.toJson(),
      'enabled': instance.enabled,
      'selected': instance.selected,
      'focusColor': ?instance.focusColor?.toJson(),
      'hoverColor': ?instance.hoverColor?.toJson(),
      'autofocus': instance.autofocus,
      'tileColor': ?instance.tileColor?.toJson(),
      'selectedTileColor': ?instance.selectedTileColor?.toJson(),
      'enableFeedback': instance.enableFeedback,
      'horizontalTitleGap': ?instance.horizontalTitleGap,
      'minVerticalPadding': ?instance.minVerticalPadding,
      'minLeadingWidth': ?instance.minLeadingWidth,
      'showLeading': instance.showLeading,
      'showTitle': instance.showTitle,
      'showSubtitle': instance.showSubtitle,
      'showTrailing': instance.showTrailing,
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
