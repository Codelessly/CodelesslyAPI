// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dropdown_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DropdownNode _$DropdownNodeFromJson(Map json) =>
    DropdownNode(
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
        properties: DropdownProperties.fromJson(json['properties'] as Map),
        value: json['value'],
      )
      ..variables =
          (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {}
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

Map<String, dynamic> _$DropdownNodeToJson(DropdownNode instance) =>
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
      'value': ?instance.value,
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
  elevation: (json['elevation'] as num?)?.toInt() ?? 8,
  borderRadius: json['borderRadius'] == null
      ? CornerRadius.zero
      : CornerRadius.fromJson(json['borderRadius']),
  underline: json['underline'] as bool? ?? true,
  useDataSource: json['useDataSource'] as bool? ?? false,
  itemLabel: json['itemLabel'] as String? ?? '',
);

Map<String, dynamic> _$DropdownPropertiesToJson(DropdownProperties instance) =>
    <String, dynamic>{
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
      'hoverColor': ?instance.hoverColor?.toJson(),
      'splashColor': ?instance.splashColor?.toJson(),
      'elevation': instance.elevation,
      'borderRadius': instance.borderRadius.toJson(),
      'underline': instance.underline,
      'useDataSource': instance.useDataSource,
      'itemLabel': instance.itemLabel,
    };
