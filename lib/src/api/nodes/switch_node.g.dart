// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'switch_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwitchNode _$SwitchNodeFromJson(Map json) => SwitchNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
      value: json['value'] as bool? ?? false,
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
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          [],
      horizontalFit:
          $enumDecodeNullable(_$SizeFitEnumMap, json['horizontalFit']) ??
              SizeFit.fixed,
      verticalFit: $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
          SizeFit.fixed,
      flex: (json['flex'] as num?)?.toInt() ?? 1,
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
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

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
  writeNotNull('reactions', instance.reactions,
      instance.reactions.map((e) => e.toJson()).toList(), const []);
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
  writeNotNull('value', instance.value, instance.value, false);
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

Map<String, dynamic> _$SwitchPropertiesToJson(SwitchProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('activeTrackColor', instance.activeTrackColor,
      instance.activeTrackColor.toJson(), ColorRGBA.black);
  writeNotNull('inactiveTrackColor', instance.inactiveTrackColor,
      instance.inactiveTrackColor.toJson(), ColorRGBA.grey);
  writeNotNull('activeThumbColor', instance.activeThumbColor,
      instance.activeThumbColor.toJson(), ColorRGBA.white);
  writeNotNull('inactiveThumbColor', instance.inactiveThumbColor,
      instance.inactiveThumbColor.toJson(), ColorRGBA.white);
  writeNotNull('hoverColor', instance.hoverColor, instance.hoverColor.toJson(),
      ColorRGBA.grey10);
  writeNotNull('focusColor', instance.focusColor, instance.focusColor.toJson(),
      ColorRGBA.grey10);
  writeNotNull('splashRadius', instance.splashRadius, instance.splashRadius,
      kRadialReactionRadius);
  writeNotNull('autofocus', instance.autofocus, instance.autofocus, false);
  writeNotNull('activeTrackBorderColor', instance.activeTrackBorderColor,
      instance.activeTrackBorderColor?.toJson(), ColorRGBA.transparent);
  writeNotNull('inactiveTrackBorderColor', instance.inactiveTrackBorderColor,
      instance.inactiveTrackBorderColor?.toJson(), ColorRGBA.transparent);
  writeNotNull('trackOutlineWidth', instance.trackOutlineWidth,
      instance.trackOutlineWidth, 2);
  writeNotNull(
      'useMaterial3', instance.useMaterial3, instance.useMaterial3, false);
  return val;
}
