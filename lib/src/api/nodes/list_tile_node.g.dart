// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_tile_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListTileNode _$ListTileNodeFromJson(Map json) => ListTileNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      leading: json['leading'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      trailing: json['trailing'] as String?,
      properties: ListTileProperties.fromJson(json['properties'] as Map),
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
    )
      ..variables = (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {}
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..type = json['type'] as String;

Map<String, dynamic> _$ListTileNodeToJson(ListTileNode instance) {
  final val = <String, dynamic>{
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
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
    'alignment': instance.alignment.toJson(),
    'outerBoxLocal': instance.outerBoxLocal.toJson(),
    'basicBoxLocal': instance.basicBoxLocal.toJson(),
    'margin': instance.margin.toJson(),
    'padding': instance.padding.toJson(),
    'rotation': instance.rotationDegrees,
    'children': instance.children,
    'variables': instance.variables,
    'multipleVariables': instance.multipleVariables,
    'type': instance.type,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('leading', instance.leading);
  writeNotNull('title', instance.title);
  writeNotNull('subtitle', instance.subtitle);
  writeNotNull('trailing', instance.trailing);
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
          : ColorRGBA.fromJson(json['selectedColor'] as Map),
      iconColor: json['iconColor'] == null
          ? null
          : ColorRGBA.fromJson(json['iconColor'] as Map),
      textColor: json['textColor'] == null
          ? null
          : ColorRGBA.fromJson(json['textColor'] as Map),
      contentPadding: json['contentPadding'] == null
          ? kDefaultListTileContentPadding
          : EdgeInsetsModel.fromJson(json['contentPadding'] as Map),
      enabled: json['enabled'] as bool? ?? true,
      selected: json['selected'] as bool? ?? false,
      focusColor: json['focusColor'] == null
          ? null
          : ColorRGBA.fromJson(json['focusColor'] as Map),
      hoverColor: json['hoverColor'] == null
          ? null
          : ColorRGBA.fromJson(json['hoverColor'] as Map),
      autofocus: json['autofocus'] as bool? ?? false,
      cornerRadius: json['cornerRadius'] == null
          ? CornerRadius.zero
          : CornerRadius.fromJson(json['cornerRadius'] as Map),
      tileColor: json['tileColor'] == null
          ? null
          : ColorRGBA.fromJson(json['tileColor'] as Map),
      selectedTileColor: json['selectedTileColor'] == null
          ? null
          : ColorRGBA.fromJson(json['selectedTileColor'] as Map),
      enableFeedback: json['enableFeedback'] as bool? ?? true,
      horizontalTitleGap: (json['horizontalTitleGap'] as num?)?.toDouble(),
      minVerticalPadding: (json['minVerticalPadding'] as num?)?.toDouble(),
      minLeadingWidth: (json['minLeadingWidth'] as num?)?.toDouble(),
      borderColor: json['borderColor'] == null
          ? null
          : ColorRGBA.fromJson(json['borderColor'] as Map),
      borderWidth: (json['borderWidth'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ListTilePropertiesToJson(ListTileProperties instance) {
  final val = <String, dynamic>{
    'shape': _$CShapeBorderEnumMap[instance.shape]!,
    'cornerRadius': instance.cornerRadius.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('borderWidth', instance.borderWidth);
  writeNotNull('borderColor', instance.borderColor?.toJson());
  val['isThreeLine'] = instance.isThreeLine;
  val['dense'] = instance.dense;
  val['visualDensity'] = instance.visualDensity.toJson();
  writeNotNull('selectedColor', instance.selectedColor?.toJson());
  writeNotNull('iconColor', instance.iconColor?.toJson());
  writeNotNull('textColor', instance.textColor?.toJson());
  val['contentPadding'] = instance.contentPadding.toJson();
  val['enabled'] = instance.enabled;
  val['selected'] = instance.selected;
  writeNotNull('focusColor', instance.focusColor?.toJson());
  writeNotNull('hoverColor', instance.hoverColor?.toJson());
  val['autofocus'] = instance.autofocus;
  writeNotNull('tileColor', instance.tileColor?.toJson());
  writeNotNull('selectedTileColor', instance.selectedTileColor?.toJson());
  val['enableFeedback'] = instance.enableFeedback;
  writeNotNull('horizontalTitleGap', instance.horizontalTitleGap);
  writeNotNull('minVerticalPadding', instance.minVerticalPadding);
  writeNotNull('minLeadingWidth', instance.minLeadingWidth);
  val['showLeading'] = instance.showLeading;
  val['showTitle'] = instance.showTitle;
  val['showSubtitle'] = instance.showSubtitle;
  val['showTrailing'] = instance.showTrailing;
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
