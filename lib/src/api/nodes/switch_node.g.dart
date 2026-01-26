// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'switch_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwitchNode _$SwitchNodeFromJson(Map json) =>
    SwitchNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        value: json['value'] as bool? ?? false,
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
        aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
        constraints: json['constraints'] == null
            ? const BoxConstraintsModel()
            : BoxConstraintsModel.fromJson(json['constraints'] as Map),
        positioningMode:
            $enumDecodeNullable(
              _$PositioningModeEnumMap,
              json['positioningMode'],
            ) ??
            PositioningMode.align,
        edgePins: json['edgePins'] == null
            ? EdgePinsModel.standard
            : EdgePinsModel.fromJson(
                Map<String, dynamic>.from(json['edgePins'] as Map),
              ),
        properties: SwitchProperties.fromJson(json['properties'] as Map),
        variables:
            (json['variables'] as Map?)?.map(
              (k, e) => MapEntry(k as String, e as String),
            ) ??
            {},
      )
      ..multipleVariables =
          (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(
              k as String,
              (e as List<dynamic>).map((e) => e as String).toList(),
            ),
          ) ??
          {}
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

Map<String, dynamic> _$SwitchNodeToJson(SwitchNode instance) =>
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
      'value': instance.value,
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

SwitchProperties _$SwitchPropertiesFromJson(Map json) => SwitchProperties(
  activeTrackColor: json['activeTrackColor'] == null
      ? ColorRGBA.black
      : ColorRGBA.fromJson(json['activeTrackColor']),
  inactiveTrackColor: json['inactiveTrackColor'] == null
      ? ColorRGBA.grey
      : ColorRGBA.fromJson(json['inactiveTrackColor']),
  activeThumbColor: json['activeThumbColor'] == null
      ? ColorRGBA.white
      : ColorRGBA.fromJson(json['activeThumbColor']),
  inactiveThumbColor: json['inactiveThumbColor'] == null
      ? ColorRGBA.white
      : ColorRGBA.fromJson(json['inactiveThumbColor']),
  hoverColor: json['hoverColor'] == null
      ? ColorRGBA.grey10
      : ColorRGBA.fromJson(json['hoverColor']),
  focusColor: json['focusColor'] == null
      ? ColorRGBA.grey10
      : ColorRGBA.fromJson(json['focusColor']),
  splashRadius:
      (json['splashRadius'] as num?)?.toDouble() ?? kRadialReactionRadius,
  autofocus: json['autofocus'] as bool? ?? false,
  activeTrackBorderColor: json['activeTrackBorderColor'] == null
      ? ColorRGBA.transparent
      : ColorRGBA.fromJson(json['activeTrackBorderColor']),
  inactiveTrackBorderColor: json['inactiveTrackBorderColor'] == null
      ? ColorRGBA.transparent
      : ColorRGBA.fromJson(json['inactiveTrackBorderColor']),
  trackOutlineWidth: (json['trackOutlineWidth'] as num?)?.toDouble() ?? 2,
  useMaterial3: json['useMaterial3'] as bool? ?? false,
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
      'activeTrackBorderColor': ?instance.activeTrackBorderColor?.toJson(),
      'inactiveTrackBorderColor': ?instance.inactiveTrackBorderColor?.toJson(),
      'trackOutlineWidth': instance.trackOutlineWidth,
      'useMaterial3': instance.useMaterial3,
    };
