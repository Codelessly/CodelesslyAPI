// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_bar_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppBarNode _$AppBarNodeFromJson(Map json) => AppBarNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      visible: json['visible'] as bool? ?? true,
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding']),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin']),
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          [],
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
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
      multipleVariables: (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {},
      properties: AppBarProperties.fromJson(json['properties'] as Map),
    )
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$AppBarNodeToJson(AppBarNode instance) {
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
  val['id'] = instance.id;
  val['name'] = instance.name;
  writeNotNull('visible', instance.visible, instance.visible, true);
  if (!excludeConstraintsIf(instance)) {
    writeNotNull('constraints', instance.constraints,
        instance.constraints.toJson(), const BoxConstraintsModel());
  }
  if (!excludeEdgePinsIf(instance)) {
    writeNotNull('edgePins', instance.edgePins, instance.edgePins.toJson(),
        EdgePinsModel.standard);
  }
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
      backgroundColor: ColorRGBA.fromJson(json['backgroundColor']),
      leading: IconAppBarActionItem.fromJson(json['leading'] as Map),
      actions: (json['actions'] as List<dynamic>?)
              ?.map((e) => IconAppBarActionItem.fromJson(e as Map))
              .toList() ??
          [],
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
          : ColorRGBA.fromJson(json['shadowColor']),
    );

Map<String, dynamic> _$AppBarPropertiesToJson(AppBarProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'centerTitle', instance.centerTitle, instance.centerTitle, false);
  writeNotNull('elevation', instance.elevation, instance.elevation, 0);
  val['leading'] = instance.leading.toJson();
  writeNotNull('automaticallyImplyLeading', instance.automaticallyImplyLeading,
      instance.automaticallyImplyLeading, true);
  val['titleStyle'] = instance.titleStyle.toJson();
  val['backgroundColor'] = instance.backgroundColor.toJson();
  val['title'] = instance.title;
  writeNotNull(
      'titleSpacing', instance.titleSpacing, instance.titleSpacing, 16);
  writeNotNull('actions', instance.actions,
      instance.actions.map((e) => e.toJson()).toList(), const []);
  writeNotNull('shadowColor', instance.shadowColor,
      instance.shadowColor.toJson(), ColorRGBA.black);
  return val;
}

IconAppBarActionItem _$IconAppBarActionItemFromJson(Map json) =>
    IconAppBarActionItem(
      id: json['id'] as String,
      icon: MultiSourceIconModel.fromJson(json['icon'] as Map),
      tooltip: json['tooltip'] as String?,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          [],
    )..type = json['type'] as String;

Map<String, dynamic> _$IconAppBarActionItemToJson(
    IconAppBarActionItem instance) {
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
  val['id'] = instance.id;
  val['icon'] = instance.icon.toJson();
  writeNotNull('tooltip', instance.tooltip, instance.tooltip, null);
  val['type'] = instance.type;
  return val;
}
