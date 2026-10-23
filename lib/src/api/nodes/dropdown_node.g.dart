// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dropdown_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$DropdownNodeOmitDefaults(
  DropdownNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.visible, true)) json.remove('visible');
  if (excludeConstraintsIf(instance)) json.remove('constraints');
  if (isJsonDefault(instance.constraints, const BoxConstraintsModel()))
    json.remove('constraints');
  if (isJsonDefault(instance.edgePins, EdgePinsModel.standard))
    json.remove('edgePins');
  if (isJsonDefault(instance.positioningMode, PositioningMode.align))
    json.remove('positioningMode');
  if (isJsonDefault(instance.horizontalFit, SizeFit.fixed))
    json.remove('horizontalFit');
  if (isJsonDefault(instance.verticalFit, SizeFit.fixed))
    json.remove('verticalFit');
  if (isJsonDefault(instance.flex, 1)) json.remove('flex');
  if (isJsonDefault(instance.squeezable, false)) json.remove('squeezable');
  if (isJsonDefault(instance.aspectRatioLock, false))
    json.remove('aspectRatioLock');
  if (isJsonDefault(instance.alignment, AlignmentModel.none))
    json.remove('alignment');
  if (isJsonDefault(instance.margin, EdgeInsetsModel.zero))
    json.remove('margin');
  if (isJsonDefault(instance.padding, EdgeInsetsModel.zero))
    json.remove('padding');
  if (isJsonDefault(instance.rotationDegrees, 0)) json.remove('rotation');
  if (isJsonDefault(instance.interactionStates, {}))
    json.remove('interactionStates');
  if (isJsonDefault(instance.tooltip, '')) json.remove('tooltip');
  if (isJsonDefault(instance.zoomable, false)) json.remove('zoomable');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.variables, {})) json.remove('variables');
  if (isJsonDefault(instance.multipleVariables, {}))
    json.remove('multipleVariables');
  if (isJsonDefault(instance.componentVersion, 1))
    json.remove('componentVersion');
  if (isJsonDefault(instance.componentSchema, {}))
    json.remove('componentSchema');
  if (isJsonDefault(instance.reactions, const [])) json.remove('reactions');
  return json;
}

Map<String, dynamic> _$DropdownPropertiesOmitDefaults(
  DropdownProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.dense, false)) json.remove('dense');
  if (isJsonDefault(instance.expanded, false)) json.remove('expanded');
  if (isJsonDefault(instance.autoFocus, false)) json.remove('autoFocus');
  if (isJsonDefault(instance.enableFeedback, true))
    json.remove('enableFeedback');
  if (isJsonDefault(instance.itemAlignment, AlignmentModel.centerLeft))
    json.remove('itemAlignment');
  if (isJsonDefault(instance.selectedItemAlignment, AlignmentModel.centerLeft))
    json.remove('selectedItemAlignment');
  if (isJsonDefault(instance.hint, '')) json.remove('hint');
  if (isJsonDefault(instance.iconDisabledColor, ColorRGBA.grey))
    json.remove('iconDisabledColor');
  if (isJsonDefault(instance.iconEnabledColor, ColorRGBA.black))
    json.remove('iconEnabledColor');
  if (isJsonDefault(instance.iconSize, 24)) json.remove('iconSize');
  if (isJsonDefault(
    instance.icon,
    const MultiSourceIconModel.icon(show: false),
  ))
    json.remove('icon');
  if (isJsonDefault(instance.dropdownColor, ColorRGBA.white))
    json.remove('dropdownColor');
  if (isJsonDefault(instance.focusColor, ColorRGBA.white))
    json.remove('focusColor');
  if (isJsonDefault(instance.elevation, 8)) json.remove('elevation');
  if (isJsonDefault(instance.borderRadius, CornerRadius.zero))
    json.remove('borderRadius');
  if (isJsonDefault(instance.underline, true)) json.remove('underline');
  if (isJsonDefault(instance.useDataSource, false))
    json.remove('useDataSource');
  if (isJsonDefault(instance.itemLabel, '')) json.remove('itemLabel');
  return json;
}

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
      ..squeezable = json['squeezable'] as bool? ?? false
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..interactionStates =
          (json['interactionStates'] as Map?)?.map(
            (k, e) => MapEntry(
              $enumDecode(_$InteractionStateEnumMap, k),
              (e as Map).map(
                (k, e) =>
                    MapEntry(k as String, Map<String, dynamic>.from(e as Map)),
              ),
            ),
          ) ??
          {}
      ..tooltip = json['tooltip'] as String? ?? ''
      ..zoomable = json['zoomable'] as bool? ?? false
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
      'squeezable': instance.squeezable,
      'aspectRatioLock': instance.aspectRatioLock,
      'alignment': instance.alignment.toJson(),
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'basicBoxLocal': instance.basicBoxLocal.toJson(),
      'margin': instance.margin.toJson(),
      'padding': instance.padding.toJson(),
      'rotation': instance.rotationDegrees,
      'widthFactor': ?instance.widthFactor,
      'heightFactor': ?instance.heightFactor,
      'interactionStates': instance.interactionStates.map(
        (k, e) => MapEntry(_$InteractionStateEnumMap[k]!, e),
      ),
      'tooltip': instance.tooltip,
      'zoomable': instance.zoomable,
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

const _$InteractionStateEnumMap = {
  InteractionState.hovered: 'hovered',
  InteractionState.focused: 'focused',
  InteractionState.pressed: 'pressed',
  InteractionState.selected: 'selected',
  InteractionState.disabled: 'disabled',
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
