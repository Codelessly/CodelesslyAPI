// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dropdown_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DropdownNode _$DropdownNodeFromJson(Map json) => DropdownNode(
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
      properties: DropdownProperties.fromJson(json['properties'] as Map),
      value: json['value'] as int?,
    )
      ..variables = (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {}
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$DropdownNodeToJson(DropdownNode instance) {
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

DropdownProperties _$DropdownPropertiesFromJson(Map json) => DropdownProperties(
      enabled: json['enabled'] as bool? ?? true,
      dense: json['dense'] as bool? ?? false,
      expanded: json['expanded'] as bool? ?? false,
      autoFocus: json['autoFocus'] as bool? ?? false,
      enableFeedback: json['enableFeedback'] as bool? ?? true,
      items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
      itemTextStyle: json['itemTextStyle'] == null
          ? null
          : TextProp.fromJson(json['itemTextStyle'] as Map),
      itemAlignment: json['itemAlignment'] == null
          ? AlignmentModel.centerLeft
          : AlignmentModel.fromJson(json['itemAlignment'] as Map),
      selectedItemTextStyle: json['selectedItemTextStyle'] == null
          ? null
          : TextProp.fromJson(json['selectedItemTextStyle'] as Map),
      selectedItemAlignment: json['selectedItemAlignment'] == null
          ? AlignmentModel.centerLeft
          : AlignmentModel.fromJson(json['selectedItemAlignment'] as Map),
      hint: json['hint'] as String? ?? '',
      hintStyle: json['hintStyle'] == null
          ? null
          : TextProp.fromJson(json['hintStyle'] as Map),
      iconDisabledColor: json['iconDisabledColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['iconDisabledColor']),
      iconEnabledColor: json['iconEnabledColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['iconEnabledColor']),
      iconSize: (json['iconSize'] as num?)?.toDouble() ?? 24,
      icon: json['icon'] == null
          ? const MultiSourceIconModel.icon(show: false)
          : MultiSourceIconModel.fromJson(json['icon'] as Map),
      dropdownColor: json['dropdownColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['dropdownColor']),
      focusColor: json['focusColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['focusColor']),
      hoverColor: json['hoverColor'] == null
          ? null
          : ColorRGBA.fromJson(json['hoverColor']),
      splashColor: json['splashColor'] == null
          ? null
          : ColorRGBA.fromJson(json['splashColor']),
      elevation: json['elevation'] as int? ?? 8,
      borderRadius: json['borderRadius'] == null
          ? CornerRadius.zero
          : CornerRadius.fromJson(json['borderRadius']),
      underline: json['underline'] as bool? ?? true,
      useDataSource: json['useDataSource'] as bool? ?? false,
      itemLabel: json['itemLabel'] as String? ?? '',
    );

Map<String, dynamic> _$DropdownPropertiesToJson(DropdownProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('enabled', instance.enabled, instance.enabled, true);
  writeNotNull('dense', instance.dense, instance.dense, false);
  writeNotNull('expanded', instance.expanded, instance.expanded, false);
  writeNotNull('autoFocus', instance.autoFocus, instance.autoFocus, false);
  writeNotNull(
      'enableFeedback', instance.enableFeedback, instance.enableFeedback, true);
  val['items'] = instance.items;
  val['itemTextStyle'] = instance.itemTextStyle.toJson();
  writeNotNull('itemAlignment', instance.itemAlignment,
      instance.itemAlignment.toJson(), AlignmentModel.centerLeft);
  val['selectedItemTextStyle'] = instance.selectedItemTextStyle.toJson();
  writeNotNull('selectedItemAlignment', instance.selectedItemAlignment,
      instance.selectedItemAlignment.toJson(), AlignmentModel.centerLeft);
  writeNotNull('hint', instance.hint, instance.hint, '');
  val['hintStyle'] = instance.hintStyle.toJson();
  writeNotNull('iconDisabledColor', instance.iconDisabledColor,
      instance.iconDisabledColor.toJson(), ColorRGBA.grey);
  writeNotNull('iconEnabledColor', instance.iconEnabledColor,
      instance.iconEnabledColor.toJson(), ColorRGBA.black);
  writeNotNull('iconSize', instance.iconSize, instance.iconSize, 24);
  writeNotNull('icon', instance.icon, instance.icon.toJson(),
      const MultiSourceIconModel.icon(show: false));
  writeNotNull('dropdownColor', instance.dropdownColor,
      instance.dropdownColor.toJson(), ColorRGBA.white);
  writeNotNull('focusColor', instance.focusColor, instance.focusColor.toJson(),
      ColorRGBA.white);
  writeNotNull(
      'hoverColor', instance.hoverColor, instance.hoverColor?.toJson(), null);
  writeNotNull('splashColor', instance.splashColor,
      instance.splashColor?.toJson(), null);
  writeNotNull('elevation', instance.elevation, instance.elevation, 8);
  writeNotNull('borderRadius', instance.borderRadius,
      instance.borderRadius.toJson(), CornerRadius.zero);
  writeNotNull('underline', instance.underline, instance.underline, true);
  writeNotNull(
      'useDataSource', instance.useDataSource, instance.useDataSource, false);
  writeNotNull('itemLabel', instance.itemLabel, instance.itemLabel, '');
  return val;
}
