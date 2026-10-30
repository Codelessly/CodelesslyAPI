// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accordion_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$AccordionNodeOmitDefaults(
  AccordionNode instance,
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
  if (isJsonDefault(instance.children, [])) json.remove('children');
  if (isJsonDefault(instance.rowColumnType, RowColumnType.column))
    json.remove('rowColumnType');
  if (isJsonDefault(instance.mainAxisAlignment, MainAxisAlignmentC.center))
    json.remove('mainAxisAlignment');
  if (isJsonDefault(instance.crossAxisAlignment, CrossAxisAlignmentC.center))
    json.remove('crossAxisAlignment');
  if (isJsonDefault(instance.spacing, 0.0)) json.remove('spacing');
  if (isJsonDefault(instance.wrap, false)) json.remove('wrap');
  if (isJsonDefault(instance.runSpacing, 0.0)) json.remove('runSpacing');
  return json;
}

Map<String, dynamic> _$AccordionPropertiesOmitDefaults(
  AccordionProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.isExpanded, true)) json.remove('isExpanded');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccordionNode _$AccordionNodeFromJson(Map json) =>
    AccordionNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        rowColumnType:
            $enumDecodeNullable(
              _$RowColumnTypeEnumMap,
              json['rowColumnType'],
            ) ??
            RowColumnType.column,
        mainAxisAlignment:
            $enumDecodeNullable(
              _$MainAxisAlignmentCEnumMap,
              json['mainAxisAlignment'],
            ) ??
            MainAxisAlignmentC.center,
        crossAxisAlignment:
            $enumDecodeNullable(
              _$CrossAxisAlignmentCEnumMap,
              json['crossAxisAlignment'],
            ) ??
            CrossAxisAlignmentC.center,
        visible: json['visible'] as bool? ?? true,
        enabled: json['enabled'] as bool? ?? true,
        rotationDegrees: json['rotation'] == null
            ? 0
            : castRotation(json['rotation']),
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
        reactions:
            (json['reactions'] as List<dynamic>?)
                ?.map((e) => Reaction.fromJson(e as Map))
                .toList() ??
            const [],
        children:
            (json['children'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
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
        properties: json['properties'] == null
            ? null
            : AccordionProperties.fromJson(json['properties'] as Map),
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
      ..loopAnimation = json['loopAnimation'] == null
          ? null
          : LoopAnimation.fromJson(json['loopAnimation'] as Map)
      ..transitionMs = (json['transitionMs'] as num?)?.toInt() ?? 0
      ..drawScale = (json['drawScale'] as num?)?.toDouble() ?? 1.0
      ..pulse = json['pulse'] == null
          ? null
          : PulseModel.fromJson(json['pulse'] as Map)
      ..draggable = json['draggable'] == null
          ? null
          : DraggableModel.fromJson(json['draggable'] as Map)
      ..dropTarget = json['dropTarget'] == null
          ? null
          : DropTargetModel.fromJson(json['dropTarget'] as Map)
      ..motion = json['motion'] == null
          ? null
          : MotionModel.fromJson(json['motion'] as Map)
      ..spacing = (json['spacing'] as num?)?.toDouble() ?? 0.0
      ..wrap = json['wrap'] as bool? ?? false
      ..runSpacing = (json['runSpacing'] as num?)?.toDouble() ?? 0.0
      ..type = json['type'] as String;

Map<String, dynamic> _$AccordionNodeToJson(
  AccordionNode instance,
) => <String, dynamic>{
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
  'squeezable': instance.squeezable,
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
  'draggable': ?instance.draggable?.toJson(),
  'dropTarget': ?instance.dropTarget?.toJson(),
  'enabled': instance.enabled,
  'motion': ?instance.motion?.toJson(),
  'children': instance.children,
  'rowColumnType': _$RowColumnTypeEnumMap[instance.rowColumnType]!,
  'mainAxisAlignment': _$MainAxisAlignmentCEnumMap[instance.mainAxisAlignment]!,
  'crossAxisAlignment':
      _$CrossAxisAlignmentCEnumMap[instance.crossAxisAlignment]!,
  'spacing': instance.spacing,
  'wrap': instance.wrap,
  'runSpacing': instance.runSpacing,
  'type': instance.type,
  'properties': instance.properties.toJson(),
};

const _$RowColumnTypeEnumMap = {
  RowColumnType.row: 'row',
  RowColumnType.column: 'column',
};

const _$MainAxisAlignmentCEnumMap = {
  MainAxisAlignmentC.start: 'start',
  MainAxisAlignmentC.center: 'center',
  MainAxisAlignmentC.end: 'end',
  MainAxisAlignmentC.spaceBetween: 'spaceBetween',
  MainAxisAlignmentC.spaceAround: 'spaceAround',
  MainAxisAlignmentC.spaceEvenly: 'spaceEvenly',
};

const _$CrossAxisAlignmentCEnumMap = {
  CrossAxisAlignmentC.start: 'start',
  CrossAxisAlignmentC.center: 'center',
  CrossAxisAlignmentC.end: 'end',
  CrossAxisAlignmentC.stretch: 'stretch',
  CrossAxisAlignmentC.baseline: 'baseline',
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

AccordionProperties _$AccordionPropertiesFromJson(Map json) =>
    AccordionProperties(isExpanded: json['isExpanded'] as bool? ?? true);

Map<String, dynamic> _$AccordionPropertiesToJson(
  AccordionProperties instance,
) => <String, dynamic>{'isExpanded': instance.isExpanded};
