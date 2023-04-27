// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dropdown_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DropdownNode _$DropdownNodeFromJson(Map json) => DropdownNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      outerBoxLocal: json['outerBoxLocal'] == null
          ? null
          : OuterNodeBox.fromJson(json['outerBoxLocal'] as Map),
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
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
    )
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$DropdownNodeToJson(DropdownNode instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'visible': instance.visible,
    'constraints': instance.constraints.toJson(),
    'edgePins': instance.edgePins.toJson(),
    'positioningMode': _$PositioningModeEnumMap[instance.positioningMode]!,
    'horizontalFit': _$SizeFitEnumMap[instance.horizontalFit]!,
    'verticalFit': _$SizeFitEnumMap[instance.verticalFit]!,
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
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

DropdownProperties _$DropdownPropertiesFromJson(Map json) => DropdownProperties(
      value: json['value'] as int? ?? 0,
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
          : ColorRGBA.fromJson(json['iconDisabledColor'] as Map),
      iconEnabledColor: json['iconEnabledColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['iconEnabledColor'] as Map),
      iconSize: (json['iconSize'] as num?)?.toDouble() ?? 24,
      icon: json['icon'] == null
          ? const MultiSourceIconModel.icon(show: false)
          : MultiSourceIconModel.fromJson(json['icon'] as Map),
      dropdownColor: json['dropdownColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['dropdownColor'] as Map),
      focusColor: json['focusColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['focusColor'] as Map),
      elevation: json['elevation'] as int? ?? 8,
      borderRadius: json['borderRadius'] == null
          ? CornerRadius.zero
          : CornerRadius.fromJson(json['borderRadius'] as Map),
      underline: json['underline'] as bool? ?? true,
    );

Map<String, dynamic> _$DropdownPropertiesToJson(DropdownProperties instance) =>
    <String, dynamic>{
      'value': instance.value,
      'enabled': instance.enabled,
      'dense': instance.dense,
      'expanded': instance.expanded,
      'autoFocus': instance.autoFocus,
      'enableFeedback': instance.enableFeedback,
      'items': instance.items,
      'itemTextStyle': instance.itemTextStyle.toJson(),
      'itemAlignment': instance.itemAlignment.toJson(),
      'selectedItemTextStyle': instance.selectedItemTextStyle.toJson(),
      'selectedItemAlignment': instance.selectedItemAlignment.toJson(),
      'hint': instance.hint,
      'hintStyle': instance.hintStyle.toJson(),
      'iconDisabledColor': instance.iconDisabledColor.toJson(),
      'iconEnabledColor': instance.iconEnabledColor.toJson(),
      'iconSize': instance.iconSize,
      'icon': instance.icon.toJson(),
      'dropdownColor': instance.dropdownColor.toJson(),
      'focusColor': instance.focusColor.toJson(),
      'elevation': instance.elevation,
      'borderRadius': instance.borderRadius.toJson(),
      'underline': instance.underline,
    };
