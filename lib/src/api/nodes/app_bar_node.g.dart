// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_bar_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppBarNode _$AppBarNodeFromJson(Map json) =>
    AppBarNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        rotationDegrees: json['rotation'] == null
            ? 0
            : castRotation(json['rotation']),
        visible: json['visible'] as bool? ?? true,
        enabled: json['enabled'] as bool? ?? true,
        alignment: json['alignment'] == null
            ? AlignmentModel.none
            : AlignmentModel.fromJson(json['alignment'] as Map),
        padding: json['padding'] == null
            ? EdgeInsetsModel.zero
            : EdgeInsetsModel.fromJson(json['padding']),
        margin: json['margin'] == null
            ? EdgeInsetsModel.zero
            : EdgeInsetsModel.fromJson(json['margin']),
        reactions:
            (json['reactions'] as List<dynamic>?)
                ?.map((e) => Reaction.fromJson(e as Map))
                .toList() ??
            const [],
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
        properties: AppBarProperties.fromJson(json['properties'] as Map),
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

Map<String, dynamic> _$AppBarNodeToJson(AppBarNode instance) =>
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
      'type': instance.type,
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

AppBarProperties _$AppBarPropertiesFromJson(Map json) => AppBarProperties(
  title: json['title'] as String,
  backgroundColor: json['backgroundColor'] == null
      ? null
      : ColorRGBA.fromJson(json['backgroundColor']),
  leading: json['leading'] == null
      ? null
      : IconAppBarActionItem.fromJson(json['leading'] as Map),
  actions:
      (json['actions'] as List<dynamic>?)
          ?.map((e) => IconAppBarActionItem.fromJson(e as Map))
          .toList() ??
      const [],
  centerTitle: json['centerTitle'] as bool? ?? false,
  titleStyle: json['titleStyle'] == null
      ? null
      : TextProp.fromJson(json['titleStyle'] as Map),
  elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
  automaticallyImplyLeading: json['automaticallyImplyLeading'] as bool? ?? true,
  titleSpacing: (json['titleSpacing'] as num?)?.toDouble() ?? 16,
  shadowColor: json['shadowColor'] == null
      ? ColorRGBA.black
      : ColorRGBA.fromJson(json['shadowColor']),
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
      reactions:
          (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          const [],
    )..type = json['type'] as String;

Map<String, dynamic> _$IconAppBarActionItemToJson(
  IconAppBarActionItem instance,
) => <String, dynamic>{
  'reactions': instance.reactions.map((e) => e.toJson()).toList(),
  'id': instance.id,
  'icon': instance.icon.toJson(),
  'tooltip': ?instance.tooltip,
  'type': instance.type,
};
