// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loading_indicator_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoadingIndicatorNode _$LoadingIndicatorNodeFromJson(Map json) =>
    LoadingIndicatorNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
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
      properties:
          LoadingIndicatorProperties.fromJson(json['properties'] as Map),
    )..type = json['type'] as String;

Map<String, dynamic> _$LoadingIndicatorNodeToJson(
        LoadingIndicatorNode instance) =>
    <String, dynamic>{
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

MaterialLoadingIndicatorProperties _$MaterialLoadingIndicatorPropertiesFromJson(
        Map json) =>
    MaterialLoadingIndicatorProperties(
      color: ColorRGBA.fromJson(json['color'] as Map),
      backgroundColor: json['backgroundColor'] == null
          ? ColorRGBA.transparent
          : ColorRGBA.fromJson(json['backgroundColor'] as Map),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 4,
      value: (json['value'] as num?)?.toDouble(),
    )..type = json['type'] as String;

Map<String, dynamic> _$MaterialLoadingIndicatorPropertiesToJson(
    MaterialLoadingIndicatorProperties instance) {
  final val = <String, dynamic>{
    'type': instance.type,
    'color': instance.color.toJson(),
    'backgroundColor': instance.backgroundColor.toJson(),
    'strokeWidth': instance.strokeWidth,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('value', instance.value);
  return val;
}

CupertinoLoadingIndicatorProperties
    _$CupertinoLoadingIndicatorPropertiesFromJson(Map json) =>
        CupertinoLoadingIndicatorProperties(
          color: ColorRGBA.fromJson(json['color'] as Map),
          radius: (json['radius'] as num?)?.toDouble() ?? 10,
        )..type = json['type'] as String;

Map<String, dynamic> _$CupertinoLoadingIndicatorPropertiesToJson(
        CupertinoLoadingIndicatorProperties instance) =>
    <String, dynamic>{
      'type': instance.type,
      'color': instance.color.toJson(),
      'radius': instance.radius,
    };
