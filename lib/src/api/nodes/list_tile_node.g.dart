// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_tile_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListTileNode _$ListTileNodeFromJson(Map json) => ListTileNode(
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
      ..componentVersion = (json['componentVersion'] as num?)?.toInt() ?? 1
      ..componentSchema = (json['componentSchema'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e),
          ) ??
          {}
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$ListTileNodeToJson(ListTileNode instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('reactions', instance.reactions,
      instance.reactions.map((e) => e.toJson()).toList(), const []);
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
  val['type'] = instance.type;
  writeNotNull('leading', instance.leading, instance.leading, null);
  writeNotNull('title', instance.title, instance.title, null);
  writeNotNull('subtitle', instance.subtitle, instance.subtitle, null);
  writeNotNull('trailing', instance.trailing, instance.trailing, null);
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
              Map<String, dynamic>.from(json['visualDensity'] as Map)),
      shape: $enumDecodeNullable(_$CShapeBorderEnumMap, json['shape']) ??
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

Map<String, dynamic> _$ListTilePropertiesToJson(ListTileProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('shape', instance.shape, _$CShapeBorderEnumMap[instance.shape]!,
      CShapeBorder.rectangle);
  writeNotNull('cornerRadius', instance.cornerRadius,
      instance.cornerRadius.toJson(), CornerRadius.zero);
  writeNotNull('borderWidth', instance.borderWidth, instance.borderWidth, null);
  writeNotNull('borderColor', instance.borderColor,
      instance.borderColor?.toJson(), null);
  writeNotNull(
      'isThreeLine', instance.isThreeLine, instance.isThreeLine, false);
  writeNotNull('dense', instance.dense, instance.dense, false);
  writeNotNull('visualDensity', instance.visualDensity,
      instance.visualDensity.toJson(), VisualDensityModel.standard);
  writeNotNull('selectedColor', instance.selectedColor,
      instance.selectedColor?.toJson(), null);
  writeNotNull(
      'iconColor', instance.iconColor, instance.iconColor?.toJson(), null);
  writeNotNull(
      'textColor', instance.textColor, instance.textColor?.toJson(), null);
  writeNotNull('contentPadding', instance.contentPadding,
      instance.contentPadding.toJson(), kDefaultListTileContentPadding);
  writeNotNull('enabled', instance.enabled, instance.enabled, true);
  writeNotNull('selected', instance.selected, instance.selected, false);
  writeNotNull(
      'focusColor', instance.focusColor, instance.focusColor?.toJson(), null);
  writeNotNull(
      'hoverColor', instance.hoverColor, instance.hoverColor?.toJson(), null);
  writeNotNull('autofocus', instance.autofocus, instance.autofocus, false);
  writeNotNull(
      'tileColor', instance.tileColor, instance.tileColor?.toJson(), null);
  writeNotNull('selectedTileColor', instance.selectedTileColor,
      instance.selectedTileColor?.toJson(), null);
  writeNotNull(
      'enableFeedback', instance.enableFeedback, instance.enableFeedback, true);
  writeNotNull('horizontalTitleGap', instance.horizontalTitleGap,
      instance.horizontalTitleGap, null);
  writeNotNull('minVerticalPadding', instance.minVerticalPadding,
      instance.minVerticalPadding, null);
  writeNotNull('minLeadingWidth', instance.minLeadingWidth,
      instance.minLeadingWidth, null);
  writeNotNull('showLeading', instance.showLeading, instance.showLeading, true);
  writeNotNull('showTitle', instance.showTitle, instance.showTitle, true);
  writeNotNull(
      'showSubtitle', instance.showSubtitle, instance.showSubtitle, true);
  writeNotNull(
      'showTrailing', instance.showTrailing, instance.showTrailing, true);
  return val;
}

const _$CShapeBorderEnumMap = {
  CShapeBorder.rectangle: 'rectangle',
  CShapeBorder.circle: 'circle',
  CShapeBorder.stadium: 'stadium',
  CShapeBorder.roundedRectangle: 'roundedRectangle',
  CShapeBorder.continuousRectangle: 'continuousRectangle',
  CShapeBorder.beveledRectangle: 'beveledRectangle',
};
