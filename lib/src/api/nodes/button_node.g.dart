// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'button_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ButtonNodeOmitDefaults(
  ButtonNode instance,
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
  if (isJsonDefault(instance.transitionMs, 0)) json.remove('transitionMs');
  if (isJsonDefault(instance.drawScale, 1.0)) json.remove('drawScale');
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

Map<String, dynamic> _$ButtonPropertiesOmitDefaults(
  ButtonProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.shape, CShapeBorder.roundedRectangle))
    json.remove('shape');
  if (isJsonDefault(
    instance.shadowColor,
    const ColorRGBA(r: 0.65, g: 0.65, b: 0.65, a: 1),
  ))
    json.remove('shadowColor');
  if (isJsonDefault(instance.elevation, 0)) json.remove('elevation');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.label, '')) json.remove('label');
  if (isJsonDefault(instance.labelAlignment, TextAlignHorizontalEnum.center))
    json.remove('labelAlignment');
  if (isJsonDefault(instance.placement, IconPlacementEnum.start))
    json.remove('placement');
  if (isJsonDefault(instance.gap, 8)) json.remove('gap');
  if (isJsonDefault(
    instance.icon,
    const MultiSourceIconModel(size: 20, color: null),
  ))
    json.remove('icon');
  if (isJsonDefault(
    instance.cornerRadius,
    const CornerRadius.all(RadiusModel.circular(4)),
  ))
    json.remove('cornerRadius');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ButtonNode _$ButtonNodeFromJson(Map json) =>
    ButtonNode._forJson(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        properties: ButtonProperties.fromJson(json['properties'] as Map),
        wireType: json['type'] as String,
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
        constraints: json['constraints'] == null
            ? const BoxConstraintsModel()
            : BoxConstraintsModel.fromJson(json['constraints'] as Map),
        aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
        edgePins: json['edgePins'] == null
            ? EdgePinsModel.standard
            : EdgePinsModel.fromJson(
                Map<String, dynamic>.from(json['edgePins'] as Map),
              ),
        positioningMode:
            $enumDecodeNullable(
              _$PositioningModeEnumMap,
              json['positioningMode'],
            ) ??
            PositioningMode.align,
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
      ..squeezable = json['squeezable'] as bool? ?? false
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
      ..loopAnimation = json['loopAnimation'] == null
          ? null
          : LoopAnimation.fromJson(json['loopAnimation'] as Map)
      ..transitionMs = (json['transitionMs'] as num?)?.toInt() ?? 0
      ..drawScale = (json['drawScale'] as num?)?.toDouble() ?? 1.0
      ..pulse = json['pulse'] == null
          ? null
          : PulseModel.fromJson(json['pulse'] as Map)
      ..motion = json['motion'] == null
          ? null
          : MotionModel.fromJson(json['motion'] as Map)
      ..heroTag = json['heroTag'] as String?
      ..heroFlight = $enumDecodeNullable(
        _$HeroFlightEnumMap,
        json['heroFlight'],
      );

Map<String, dynamic> _$ButtonNodeToJson(ButtonNode instance) =>
    <String, dynamic>{
      'squeezable': instance.squeezable,
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
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
      'loopAnimation': ?instance.loopAnimation?.toJson(),
      'transitionMs': instance.transitionMs,
      'drawScale': instance.drawScale,
      'pulse': ?instance.pulse?.toJson(),
      'enabled': instance.enabled,
      'motion': ?instance.motion?.toJson(),
      'heroTag': ?instance.heroTag,
      'heroFlight': ?_$HeroFlightEnumMap[instance.heroFlight],
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

const _$HeroFlightEnumMap = {
  HeroFlight.standard: 'standard',
  HeroFlight.morphCorners: 'morphCorners',
};

ButtonProperties _$ButtonPropertiesFromJson(Map json) => ButtonProperties(
  buttonColor: json['buttonColor'] == null
      ? null
      : ColorRGBA.fromJson(json['buttonColor']),
  shadowColor: json['shadowColor'] == null
      ? const ColorRGBA(r: 0.65, g: 0.65, b: 0.65, a: 1)
      : ColorRGBA.fromJson(json['shadowColor']),
  label: json['label'] as String? ?? '',
  elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
  enabled: json['enabled'] as bool? ?? true,
  labelAlignment:
      $enumDecodeNullable(
        _$TextAlignHorizontalEnumEnumMap,
        json['labelAlignment'],
      ) ??
      TextAlignHorizontalEnum.center,
  placement:
      $enumDecodeNullable(_$IconPlacementEnumEnumMap, json['placement']) ??
      IconPlacementEnum.start,
  gap: (json['gap'] as num?)?.toDouble() ?? 8,
  labelStyle: json['labelStyle'] == null
      ? null
      : TextProp.fromJson(json['labelStyle'] as Map),
  icon: json['icon'] == null
      ? const MultiSourceIconModel(size: 20, color: null)
      : MultiSourceIconModel.fromJson(json['icon'] as Map),
  cornerRadius: json['cornerRadius'] == null
      ? const CornerRadius.all(RadiusModel.circular(4))
      : CornerRadius.fromJson(json['cornerRadius']),
  borderColor: json['borderColor'] == null
      ? null
      : ColorRGBA.fromJson(json['borderColor']),
  shape:
      $enumDecodeNullable(_$CShapeBorderEnumMap, json['shape']) ??
      CShapeBorder.roundedRectangle,
  borderWidth: (json['borderWidth'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ButtonPropertiesToJson(
  ButtonProperties instance,
) => <String, dynamic>{
  'cornerRadius': instance.cornerRadius.toJson(),
  'borderWidth': ?instance.borderWidth,
  'borderColor': ?instance.borderColor?.toJson(),
  'shape': _$CShapeBorderEnumMap[instance.shape]!,
  'buttonColor': ?instance.buttonColor?.toJson(),
  'shadowColor': instance.shadowColor.toJson(),
  'elevation': instance.elevation,
  'enabled': instance.enabled,
  'label': instance.label,
  'labelAlignment': _$TextAlignHorizontalEnumEnumMap[instance.labelAlignment]!,
  'labelStyle': instance.labelStyle.toJson(),
  'placement': _$IconPlacementEnumEnumMap[instance.placement]!,
  'gap': instance.gap,
  'icon': instance.icon.toJson(),
};

const _$TextAlignHorizontalEnumEnumMap = {
  TextAlignHorizontalEnum.left: 'left',
  TextAlignHorizontalEnum.center: 'center',
  TextAlignHorizontalEnum.right: 'right',
  TextAlignHorizontalEnum.justified: 'justified',
  TextAlignHorizontalEnum.start: 'start',
  TextAlignHorizontalEnum.end: 'end',
};

const _$IconPlacementEnumEnumMap = {
  IconPlacementEnum.start: 'start',
  IconPlacementEnum.end: 'end',
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
