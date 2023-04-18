// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_bar_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppBarNode _$AppBarNodeFromJson(Map json) => AppBarNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      outerBoxLocal: json['outerBoxLocal'] == null
          ? null
          : OuterNodeBox.fromJson(json['outerBoxLocal'] as Map),
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      visible: json['visible'] as bool? ?? true,
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding'] as Map),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin'] as Map),
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          const [],
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
      properties: AppBarProperties.fromJson(json['properties'] as Map),
    )
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
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

Map<String, dynamic> _$AppBarNodeToJson(AppBarNode instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'visible': instance.visible,
    'constraints': instance.constraints.toJson(),
    'edgePins': instance.edgePins.toJson(),
    'positioningMode': _$PositioningModeEnumMap[instance.positioningMode]!,
    'horizontalFit': _$SizeFitEnumMap[instance.horizontalFit]!,
    'verticalFit': _$SizeFitEnumMap[instance.verticalFit]!,
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
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
  val['variables'] = instance.variables;
  val['multipleVariables'] = instance.multipleVariables;
  val['type'] = instance.type;
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

AppBarProperties _$AppBarPropertiesFromJson(Map json) => AppBarProperties(
      title: json['title'] as String,
      backgroundColor: ColorRGBA.fromJson(json['backgroundColor'] as Map),
      leading: IconAppBarActionItem.fromJson(json['leading'] as Map),
      actions: (json['actions'] as List<dynamic>?)
              ?.map((e) => IconAppBarActionItem.fromJson(e as Map))
              .toList() ??
          const [],
      centerTitle: json['centerTitle'] as bool? ?? false,
      titleStyle: json['titleStyle'] == null
          ? null
          : TextProp.fromJson(json['titleStyle'] as Map),
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
      automaticallyImplyLeading:
          json['automaticallyImplyLeading'] as bool? ?? true,
      titleSpacing: (json['titleSpacing'] as num?)?.toDouble() ?? 16,
      shadowColor: json['shadowColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['shadowColor'] as Map),
    );

Map<String, dynamic> _$AppBarPropertiesToJson(AppBarProperties instance) =>
    <String, dynamic>{
      'centerTitle': instance.centerTitle,
      'elevation': instance.elevation,
      'leading': instance.leading.toJson(),
      'automaticallyImplyLeading': instance.automaticallyImplyLeading,
      'titleStyle': instance.titleStyle.toJson(),
      'backgroundColor': instance.backgroundColor.toJson(),
      'title': instance.title,
      'titleSpacing': instance.titleSpacing,
      'actions': instance.actions.map((e) => e.toJson()).toList(),
      'shadowColor': instance.shadowColor.toJson(),
    };

IconAppBarActionItem _$IconAppBarActionItemFromJson(Map json) =>
    IconAppBarActionItem(
      id: json['id'] as String,
      icon: MultiSourceIconModel.fromJson(json['icon'] as Map),
      tooltip: json['tooltip'] as String?,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          const [],
    )..type = json['type'] as String;

Map<String, dynamic> _$IconAppBarActionItemToJson(
    IconAppBarActionItem instance) {
  final val = <String, dynamic>{
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
    'id': instance.id,
    'icon': instance.icon.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('tooltip', instance.tooltip);
  val['type'] = instance.type;
  return val;
}
