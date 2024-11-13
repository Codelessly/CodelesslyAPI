// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkbox_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckboxNode _$CheckboxNodeFromJson(Map json) => CheckboxNode(
      value: json['value'] as bool?,
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
      visible: json['visible'] as bool? ?? true,
      enabled: json['enabled'] as bool? ?? true,
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin']),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding']),
      horizontalFit:
          $enumDecodeNullable(_$SizeFitEnumMap, json['horizontalFit']) ??
              SizeFit.fixed,
      verticalFit: $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
          SizeFit.fixed,
      flex: (json['flex'] as num?)?.toInt() ?? 1,
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
          [],
      properties: CheckboxProperties.fromJson(json['properties'] as Map),
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

Map<String, dynamic> _$CheckboxNodeToJson(CheckboxNode instance) {
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
  writeNotNull('enabled', instance.enabled, instance.enabled, true);
  val['type'] = instance.type;
  val['properties'] = instance.properties.toJson();
  writeNotNull('value', instance.value, instance.value, null);
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

CheckboxProperties _$CheckboxPropertiesFromJson(Map json) => CheckboxProperties(
      checkColor: json['checkColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['checkColor']),
      activeColor: json['activeColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['activeColor']),
      hoverColor: json['hoverColor'] == null
          ? ColorRGBA.grey10
          : ColorRGBA.fromJson(json['hoverColor']),
      focusColor: json['focusColor'] == null
          ? ColorRGBA.grey10
          : ColorRGBA.fromJson(json['focusColor']),
      tristate: json['tristate'] as bool? ?? false,
      borderColor: json['borderColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['borderColor']),
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1.5,
      cornerRadius: json['cornerRadius'] == null
          ? const CornerRadius.all(RadiusModel.circular(3))
          : CornerRadius.fromJson(json['cornerRadius']),
      splashRadius:
          (json['splashRadius'] as num?)?.toDouble() ?? kRadialReactionRadius,
      autofocus: json['autofocus'] as bool? ?? false,
      compact: json['compact'] as bool? ?? false,
    );

Map<String, dynamic> _$CheckboxPropertiesToJson(CheckboxProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('checkColor', instance.checkColor, instance.checkColor.toJson(),
      ColorRGBA.white);
  writeNotNull('activeColor', instance.activeColor,
      instance.activeColor.toJson(), ColorRGBA.black);
  writeNotNull('borderColor', instance.borderColor,
      instance.borderColor.toJson(), ColorRGBA.grey);
  writeNotNull('hoverColor', instance.hoverColor, instance.hoverColor.toJson(),
      ColorRGBA.grey10);
  writeNotNull('focusColor', instance.focusColor, instance.focusColor.toJson(),
      ColorRGBA.grey10);
  writeNotNull('splashRadius', instance.splashRadius, instance.splashRadius,
      kRadialReactionRadius);
  writeNotNull('autofocus', instance.autofocus, instance.autofocus, false);
  writeNotNull('tristate', instance.tristate, instance.tristate, false);
  writeNotNull('borderWidth', instance.borderWidth, instance.borderWidth, 1.5);
  writeNotNull(
      'cornerRadius',
      instance.cornerRadius,
      instance.cornerRadius.toJson(),
      const CornerRadius.all(RadiusModel.circular(3)));
  writeNotNull('compact', instance.compact, instance.compact, false);
  return val;
}
