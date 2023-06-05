// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'switch_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwitchNode _$SwitchNodeFromJson(Map json) => SwitchNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      value: json['value'] as bool? ?? false,
      outerBoxLocal: json['outerBoxLocal'] == null
          ? null
          : OuterNodeBox.fromJson(json['outerBoxLocal'] as Map),
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
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
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
      aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
      constraints: json['constraints'] == null
          ? const BoxConstraintsModel()
          : BoxConstraintsModel.fromJson(json['constraints'] as Map),
      positioningMode: $enumDecodeNullable(
              _$PositioningModeEnumMap, json['positioningMode']) ??
          PositioningMode.align,
      edgePins: json['edgePins'] == null
          ? EdgePinsModel.standard
          : EdgePinsModel.fromJson(
              Map<String, dynamic>.from(json['edgePins'] as Map)),
      properties: SwitchProperties.fromJson(json['properties'] as Map),
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
    )
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$SwitchNodeToJson(SwitchNode instance) {
  final val = <String, dynamic>{
    'variables': instance.variables,
    'multipleVariables': instance.multipleVariables,
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
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('widthFactor', instance.widthFactor);
  writeNotNull('heightFactor', instance.heightFactor);
  val['type'] = instance.type;
  val['value'] = instance.value;
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

SwitchProperties _$SwitchPropertiesFromJson(Map json) => SwitchProperties(
      activeTrackColor: json['activeTrackColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['activeTrackColor'] as Map),
      inactiveTrackColor: json['inactiveTrackColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['inactiveTrackColor'] as Map),
      activeThumbColor: json['activeThumbColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['activeThumbColor'] as Map),
      inactiveThumbColor: json['inactiveThumbColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['inactiveThumbColor'] as Map),
      hoverColor: json['hoverColor'] == null
          ? ColorRGBA.grey10
          : ColorRGBA.fromJson(json['hoverColor'] as Map),
      focusColor: json['focusColor'] == null
          ? ColorRGBA.grey10
          : ColorRGBA.fromJson(json['focusColor'] as Map),
      splashRadius:
          (json['splashRadius'] as num?)?.toDouble() ?? kRadialReactionRadius,
      autofocus: json['autofocus'] as bool? ?? false,
    );

Map<String, dynamic> _$SwitchPropertiesToJson(SwitchProperties instance) =>
    <String, dynamic>{
      'activeTrackColor': instance.activeTrackColor.toJson(),
      'inactiveTrackColor': instance.inactiveTrackColor.toJson(),
      'activeThumbColor': instance.activeThumbColor.toJson(),
      'inactiveThumbColor': instance.inactiveThumbColor.toJson(),
      'hoverColor': instance.hoverColor.toJson(),
      'focusColor': instance.focusColor.toJson(),
      'splashRadius': instance.splashRadius,
      'autofocus': instance.autofocus,
    };
