// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'floating_action_button_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$FloatingActionButtonNodeOmitDefaults(
  FloatingActionButtonNode instance,
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

Map<String, dynamic> _$FloatingActionButtonPropertiesOmitDefaults(
  FloatingActionButtonProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.shape, CShapeBorder.circle)) json.remove('shape');
  if (isJsonDefault(instance.cornerRadius, CornerRadius.zero))
    json.remove('cornerRadius');
  if (isJsonDefault(instance.backgroundColor, ColorRGBA.black))
    json.remove('backgroundColor');
  if (isJsonDefault(instance.foregroundColor, ColorRGBA.white))
    json.remove('foregroundColor');
  if (isJsonDefault(instance.elevation, 0.0)) json.remove('elevation');
  if (isJsonDefault(instance.focusElevation, 0.0))
    json.remove('focusElevation');
  if (isJsonDefault(instance.hoverElevation, 0.0))
    json.remove('hoverElevation');
  if (isJsonDefault(instance.highlightElevation, 0.0))
    json.remove('highlightElevation');
  if (isJsonDefault(instance.type, FloatingActionButtonType.regular))
    json.remove('type');
  if (isJsonDefault(instance.location, FABLocation.endFloat))
    json.remove('location');
  if (isJsonDefault(instance.icon, const MultiSourceIconModel()))
    json.remove('icon');
  if (isJsonDefault(instance.label, '')) json.remove('label');
  if (isJsonDefault(instance.extendedIconLabelSpacing, 0.0))
    json.remove('extendedIconLabelSpacing');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FloatingActionButtonNode _$FloatingActionButtonNodeFromJson(Map json) =>
    FloatingActionButtonNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
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
        reactions: json['reactions'] == null
            ? const []
            : reactionsFromJson(json['reactions']),
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
        properties: FloatingActionButtonProperties.fromJson(
          json['properties'] as Map,
        ),
        variables:
            (json['variables'] as Map?)?.map(
              (k, e) => MapEntry(k as String, e as String),
            ) ??
            {},
        multipleVariables:
            (json['multipleVariables'] as Map?)?.map(
              (k, e) => MapEntry(
                k as String,
                (e as List<dynamic>).map((e) => e as String).toList(),
              ),
            ) ??
            {},
      )
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

Map<String, dynamic> _$FloatingActionButtonNodeToJson(
  FloatingActionButtonNode instance,
) => <String, dynamic>{
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
  'interactionStates': instance.interactionStates.map(
    (k, e) => MapEntry(_$InteractionStateEnumMap[k]!, e),
  ),
  'tooltip': instance.tooltip,
  'zoomable': instance.zoomable,
  'enabled': instance.enabled,
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

FloatingActionButtonProperties _$FloatingActionButtonPropertiesFromJson(
  Map json,
) => FloatingActionButtonProperties(
  backgroundColor: json['backgroundColor'] == null
      ? ColorRGBA.black
      : ColorRGBA.fromJson(json['backgroundColor']),
  foregroundColor: json['foregroundColor'] == null
      ? ColorRGBA.white
      : ColorRGBA.fromJson(json['foregroundColor']),
  elevation: (json['elevation'] as num?)?.toDouble() ?? 0.0,
  focusElevation: (json['focusElevation'] as num?)?.toDouble() ?? 0.0,
  hoverElevation: (json['hoverElevation'] as num?)?.toDouble() ?? 0.0,
  highlightElevation: (json['highlightElevation'] as num?)?.toDouble() ?? 0.0,
  extendedIconLabelSpacing:
      (json['extendedIconLabelSpacing'] as num?)?.toDouble() ?? 0.0,
  icon: json['icon'] == null
      ? const MultiSourceIconModel()
      : MultiSourceIconModel.fromJson(json['icon'] as Map),
  type:
      $enumDecodeNullable(_$FloatingActionButtonTypeEnumMap, json['type']) ??
      FloatingActionButtonType.regular,
  location:
      $enumDecodeNullable(_$FABLocationEnumMap, json['location']) ??
      FABLocation.endFloat,
  label: json['label'] as String? ?? '',
  labelStyle: json['labelStyle'] == null
      ? null
      : TextProp.fromJson(json['labelStyle'] as Map),
  focusColor: json['focusColor'] == null
      ? null
      : ColorRGBA.fromJson(json['focusColor']),
  hoverColor: json['hoverColor'] == null
      ? null
      : ColorRGBA.fromJson(json['hoverColor']),
  splashColor: json['splashColor'] == null
      ? null
      : ColorRGBA.fromJson(json['splashColor']),
  shape:
      $enumDecodeNullable(_$CShapeBorderEnumMap, json['shape']) ??
      CShapeBorder.circle,
  cornerRadius: _readLegacyCornerRadius(json, 'cornerRadius') == null
      ? const CornerRadius.all(RadiusModel.circular(16))
      : CornerRadius.fromJson(_readLegacyCornerRadius(json, 'cornerRadius')),
  borderColor: json['borderColor'] == null
      ? null
      : ColorRGBA.fromJson(json['borderColor']),
  borderWidth: (json['borderWidth'] as num?)?.toDouble(),
  reactions: reactionsFromJson(json['reactions']),
);

Map<String, dynamic> _$FloatingActionButtonPropertiesToJson(
  FloatingActionButtonProperties instance,
) => <String, dynamic>{
  'reactions': instance.reactions.map((e) => e.toJson()).toList(),
  'borderWidth': ?instance.borderWidth,
  'borderColor': ?instance.borderColor?.toJson(),
  'shape': _$CShapeBorderEnumMap[instance.shape]!,
  'cornerRadius': instance.cornerRadius.toJson(),
  'backgroundColor': instance.backgroundColor.toJson(),
  'foregroundColor': instance.foregroundColor.toJson(),
  'elevation': instance.elevation,
  'focusElevation': instance.focusElevation,
  'hoverElevation': instance.hoverElevation,
  'highlightElevation': instance.highlightElevation,
  'type': _$FloatingActionButtonTypeEnumMap[instance.type]!,
  'location': _$FABLocationEnumMap[instance.location]!,
  'icon': instance.icon.toJson(),
  'label': instance.label,
  'labelStyle': instance.labelStyle.toJson(),
  'focusColor': ?instance.focusColor?.toJson(),
  'hoverColor': ?instance.hoverColor?.toJson(),
  'splashColor': ?instance.splashColor?.toJson(),
  'extendedIconLabelSpacing': instance.extendedIconLabelSpacing,
};

const _$FloatingActionButtonTypeEnumMap = {
  FloatingActionButtonType.regular: 'regular',
  FloatingActionButtonType.small: 'small',
  FloatingActionButtonType.large: 'large',
  FloatingActionButtonType.extended: 'extended',
};

const _$FABLocationEnumMap = {
  FABLocation.startTop: 'startTop',
  FABLocation.miniStartTop: 'miniStartTop',
  FABLocation.centerTop: 'centerTop',
  FABLocation.miniCenterTop: 'miniCenterTop',
  FABLocation.endTop: 'endTop',
  FABLocation.miniEndTop: 'miniEndTop',
  FABLocation.startFloat: 'startFloat',
  FABLocation.miniStartFloat: 'miniStartFloat',
  FABLocation.centerFloat: 'centerFloat',
  FABLocation.miniCenterFloat: 'miniCenterFloat',
  FABLocation.endFloat: 'endFloat',
  FABLocation.miniEndFloat: 'miniEndFloat',
  FABLocation.startDocked: 'startDocked',
  FABLocation.miniStartDocked: 'miniStartDocked',
  FABLocation.centerDocked: 'centerDocked',
  FABLocation.miniCenterDocked: 'miniCenterDocked',
  FABLocation.endDocked: 'endDocked',
  FABLocation.miniEndDocked: 'miniEndDocked',
  FABLocation.endContained: 'endContained',
};

const _$CShapeBorderEnumMap = {
  CShapeBorder.rectangle: 'rectangle',
  CShapeBorder.circle: 'circle',
  CShapeBorder.stadium: 'stadium',
  CShapeBorder.roundedRectangle: 'roundedRectangle',
  CShapeBorder.continuousRectangle: 'continuousRectangle',
  CShapeBorder.beveledRectangle: 'beveledRectangle',
  CShapeBorder.roundedSuperellipse: 'roundedSuperellipse',
};
