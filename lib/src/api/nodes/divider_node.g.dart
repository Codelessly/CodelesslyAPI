// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divider_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DividerNode _$DividerNodeFromJson(Map json) => DividerNode(
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
      properties: DividerProperties.fromJson(json['properties'] as Map),
    )
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$DividerNodeToJson(DividerNode instance) {
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
    'alignment': instance.alignment.toJson(),
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
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

DividerProperties _$DividerPropertiesFromJson(Map json) => DividerProperties(
      color: json['color'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['color'] as Map),
      indent: (json['indent'] as num?)?.toDouble() ?? 0,
      endIndent: (json['endIndent'] as num?)?.toDouble() ?? 0,
      thickness: (json['thickness'] as num?)?.toDouble() ?? 1,
      isVertical: json['isVertical'] as bool? ?? false,
    );

Map<String, dynamic> _$DividerPropertiesToJson(DividerProperties instance) =>
    <String, dynamic>{
      'color': instance.color.toJson(),
      'indent': instance.indent,
      'endIndent': instance.endIndent,
      'isVertical': instance.isVertical,
      'thickness': instance.thickness,
    };
