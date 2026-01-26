// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeNode _$BadgeNodeFromJson(Map json) =>
    BadgeNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
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
        rotationDegrees: json['rotation'] == null
            ? 0
            : castRotation(json['rotation']),
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
        aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
        edgePins: json['edgePins'] == null
            ? EdgePinsModel.standard
            : EdgePinsModel.fromJson(
                Map<String, dynamic>.from(json['edgePins'] as Map),
              ),
        positioningMode:
            $enumDecodeNullable(
              _$PositioningModeEnumMap,
              json['positioningMode'],
            ) ??
            PositioningMode.align,
        properties: BadgeProperties.fromJson(json['properties'] as Map),
        childID: json['childID'] as String?,
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

Map<String, dynamic> _$BadgeNodeToJson(BadgeNode instance) => <String, dynamic>{
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
  'childID': ?instance.childID,
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

BadgeProperties _$BadgePropertiesFromJson(Map json) => BadgeProperties(
  badgeType:
      $enumDecodeNullable(_$BadgeTypeEnumMap, json['badgeType']) ??
      BadgeType.count,
  label: json['label'] as String? ?? '',
  backgroundColor: json['backgroundColor'] == null
      ? null
      : ColorRGBA.fromJson(json['backgroundColor']),
  labelStyle: json['labelStyle'] == null
      ? null
      : TextProp.fromJson(json['labelStyle'] as Map),
  alignment:
      $enumDecodeNullable(_$BadgeAlignmentEnumMap, json['alignment']) ??
      BadgeAlignment.topRight,
  offsetX: (json['offsetX'] as num?)?.toDouble() ?? 0,
  offsetY: (json['offsetY'] as num?)?.toDouble() ?? 0,
  isLabelVisible: json['isLabelVisible'] as bool? ?? true,
  dotSize: (json['dotSize'] as num?)?.toDouble() ?? 6,
  padding: json['padding'] == null
      ? null
      : EdgeInsetsModel.fromJson(json['padding']),
);

Map<String, dynamic> _$BadgePropertiesToJson(BadgeProperties instance) =>
    <String, dynamic>{
      'badgeType': _$BadgeTypeEnumMap[instance.badgeType]!,
      'label': instance.label,
      'backgroundColor': ?instance.backgroundColor?.toJson(),
      'labelStyle': instance.labelStyle.toJson(),
      'alignment': _$BadgeAlignmentEnumMap[instance.alignment]!,
      'offsetX': instance.offsetX,
      'offsetY': instance.offsetY,
      'isLabelVisible': instance.isLabelVisible,
      'dotSize': instance.dotSize,
      'padding': instance.padding.toJson(),
    };

const _$BadgeTypeEnumMap = {
  BadgeType.dot: 'dot',
  BadgeType.label: 'label',
  BadgeType.count: 'count',
};

const _$BadgeAlignmentEnumMap = {
  BadgeAlignment.topRight: 'topRight',
  BadgeAlignment.topLeft: 'topLeft',
  BadgeAlignment.bottomRight: 'bottomRight',
  BadgeAlignment.bottomLeft: 'bottomLeft',
};
