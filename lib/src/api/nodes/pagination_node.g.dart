// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$PaginationNodeOmitDefaults(
  PaginationNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.controller, '')) json.remove('controller');
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
  if (isJsonDefault(instance.ignorePointer, false))
    json.remove('ignorePointer');
  if (isJsonDefault(instance.keepAspect, 0)) json.remove('keepAspect');
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
  if (isJsonDefault(instance.effectAnimations, []))
    json.remove('effectAnimations');
  if (isJsonDefault(instance.flightKey, '')) json.remove('flightKey');
  if (isJsonDefault(instance.floating, false)) json.remove('floating');
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

Map<String, dynamic> _$PaginationPropertiesOmitDefaults(
  PaginationProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.showFirstLast, true)) json.remove('showFirstLast');
  if (isJsonDefault(instance.showPrevNext, true)) json.remove('showPrevNext');
  if (isJsonDefault(instance.showPageNumbers, true))
    json.remove('showPageNumbers');
  if (isJsonDefault(instance.siblingCount, 1)) json.remove('siblingCount');
  if (isJsonDefault(instance.boundaryCount, 1)) json.remove('boundaryCount');
  if (isJsonDefault(instance.showPageSize, false)) json.remove('showPageSize');
  if (isJsonDefault(instance.showSummary, true)) json.remove('showSummary');
  if (isJsonDefault(instance.summaryText, 'Showing {from}–{to} of {total}'))
    json.remove('summaryText');
  if (isJsonDefault(instance.pageSizeLabel, 'Rows per page'))
    json.remove('pageSizeLabel');
  if (isJsonDefault(instance.firstLabel, '«')) json.remove('firstLabel');
  if (isJsonDefault(instance.previousLabel, '‹')) json.remove('previousLabel');
  if (isJsonDefault(instance.nextLabel, '›')) json.remove('nextLabel');
  if (isJsonDefault(instance.lastLabel, '»')) json.remove('lastLabel');
  if (isJsonDefault(instance.alignment, MainAxisAlignmentC.spaceBetween))
    json.remove('alignment');
  if (isJsonDefault(instance.fontSize, 14)) json.remove('fontSize');
  if (isJsonDefault(instance.fontWeight, 400)) json.remove('fontWeight');
  if (isJsonDefault(
    instance.textColor,
    const ColorRGBA(r: 0.2, g: 0.22, b: 0.26, a: 1),
  ))
    json.remove('textColor');
  if (isJsonDefault(
    instance.activeColor,
    const ColorRGBA(r: 0.15, g: 0.39, b: 0.92, a: 1),
  ))
    json.remove('activeColor');
  if (isJsonDefault(instance.activeTextColor, ColorRGBA.white))
    json.remove('activeTextColor');
  if (isJsonDefault(
    instance.borderColor,
    const ColorRGBA(r: 0.85, g: 0.87, b: 0.9, a: 1),
  ))
    json.remove('borderColor');
  if (isJsonDefault(instance.borderWidth, 1)) json.remove('borderWidth');
  if (isJsonDefault(instance.cornerRadius, 6)) json.remove('cornerRadius');
  if (isJsonDefault(instance.buttonSize, 32)) json.remove('buttonSize');
  if (isJsonDefault(instance.spacing, 4)) json.remove('spacing');
  if (isJsonDefault(instance.disabledOpacity, 0.4))
    json.remove('disabledOpacity');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginationNode _$PaginationNodeFromJson(Map json) =>
    PaginationNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
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
        controller: json['controller'] as String? ?? '',
        properties: PaginationProperties.fromJson(json['properties'] as Map),
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
      ..squeezable = json['squeezable'] as bool? ?? false
      ..ignorePointer = json['ignorePointer'] as bool? ?? false
      ..keepAspect = (json['keepAspect'] as num?)?.toDouble() ?? 0
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
      ..effectAnimations =
          (json['effectAnimations'] as List<dynamic>?)
              ?.map((e) => EffectAnimation.fromJson(e as Map))
              .toList() ??
          []
      ..particles = json['particles'] == null
          ? null
          : ParticleEmitter.fromJson(json['particles'] as Map)
      ..flightKey = json['flightKey'] as String? ?? ''
      ..strokePath = json['strokePath'] == null
          ? null
          : StrokePath.fromJson(json['strokePath'] as Map)
      ..reveal = json['reveal'] == null
          ? null
          : RevealModel.fromJson(json['reveal'] as Map)
      ..drag = json['drag'] == null
          ? null
          : DragModel.fromJson(json['drag'] as Map)
      ..floating = json['floating'] as bool? ?? false
      ..heroTag = json['heroTag'] as String?
      ..heroFlight = $enumDecodeNullable(
        _$HeroFlightEnumMap,
        json['heroFlight'],
      )
      ..key = json['key'] as String?
      ..layoutAspectRatio = (json['layoutAspectRatio'] as num?)?.toDouble()
      ..sizeTransition = json['sizeTransition'] == null
          ? null
          : NodeTransition.fromJson(json['sizeTransition'] as Map)
      ..type = json['type'] as String;

Map<String, dynamic> _$PaginationNodeToJson(
  PaginationNode instance,
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
  'ignorePointer': instance.ignorePointer,
  'keepAspect': instance.keepAspect,
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
  'effectAnimations': instance.effectAnimations.map((e) => e.toJson()).toList(),
  'particles': ?instance.particles?.toJson(),
  'flightKey': instance.flightKey,
  'strokePath': ?instance.strokePath?.toJson(),
  'reveal': ?instance.reveal?.toJson(),
  'drag': ?instance.drag?.toJson(),
  'floating': instance.floating,
  'heroTag': ?instance.heroTag,
  'heroFlight': ?_$HeroFlightEnumMap[instance.heroFlight],
  'key': ?instance.key,
  'layoutAspectRatio': ?instance.layoutAspectRatio,
  'sizeTransition': ?instance.sizeTransition?.toJson(),
  'type': instance.type,
  'controller': instance.controller,
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
  InteractionState.dragged: 'dragged',
};

const _$HeroFlightEnumMap = {
  HeroFlight.standard: 'standard',
  HeroFlight.morphCorners: 'morphCorners',
  HeroFlight.arc: 'arc',
};

PaginationProperties _$PaginationPropertiesFromJson(Map json) =>
    PaginationProperties(
      showFirstLast: json['showFirstLast'] as bool? ?? true,
      showPrevNext: json['showPrevNext'] as bool? ?? true,
      showPageNumbers: json['showPageNumbers'] as bool? ?? true,
      siblingCount: (json['siblingCount'] as num?)?.toInt() ?? 1,
      boundaryCount: (json['boundaryCount'] as num?)?.toInt() ?? 1,
      showPageSize: json['showPageSize'] as bool? ?? false,
      showSummary: json['showSummary'] as bool? ?? true,
      summaryText:
          json['summaryText'] as String? ?? 'Showing {from}–{to} of {total}',
      pageSizeLabel: json['pageSizeLabel'] as String? ?? 'Rows per page',
      firstLabel: json['firstLabel'] as String? ?? '«',
      previousLabel: json['previousLabel'] as String? ?? '‹',
      nextLabel: json['nextLabel'] as String? ?? '›',
      lastLabel: json['lastLabel'] as String? ?? '»',
      alignment:
          $enumDecodeNullable(_$MainAxisAlignmentCEnumMap, json['alignment']) ??
          MainAxisAlignmentC.spaceBetween,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14,
      fontWeight: (json['fontWeight'] as num?)?.toInt() ?? 400,
      textColor: json['textColor'] == null
          ? const ColorRGBA(r: 0.2, g: 0.22, b: 0.26, a: 1)
          : ColorRGBA.fromJson(json['textColor']),
      buttonColor: json['buttonColor'] == null
          ? null
          : ColorRGBA.fromJson(json['buttonColor']),
      activeColor: json['activeColor'] == null
          ? const ColorRGBA(r: 0.15, g: 0.39, b: 0.92, a: 1)
          : ColorRGBA.fromJson(json['activeColor']),
      activeTextColor: json['activeTextColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['activeTextColor']),
      borderColor: json['borderColor'] == null
          ? const ColorRGBA(r: 0.85, g: 0.87, b: 0.9, a: 1)
          : ColorRGBA.fromJson(json['borderColor']),
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1,
      cornerRadius: (json['cornerRadius'] as num?)?.toDouble() ?? 6,
      buttonSize: (json['buttonSize'] as num?)?.toDouble() ?? 32,
      spacing: (json['spacing'] as num?)?.toDouble() ?? 4,
      disabledOpacity: (json['disabledOpacity'] as num?)?.toDouble() ?? 0.4,
    );

Map<String, dynamic> _$PaginationPropertiesToJson(
  PaginationProperties instance,
) => <String, dynamic>{
  'showFirstLast': instance.showFirstLast,
  'showPrevNext': instance.showPrevNext,
  'showPageNumbers': instance.showPageNumbers,
  'siblingCount': instance.siblingCount,
  'boundaryCount': instance.boundaryCount,
  'showPageSize': instance.showPageSize,
  'showSummary': instance.showSummary,
  'summaryText': instance.summaryText,
  'pageSizeLabel': instance.pageSizeLabel,
  'firstLabel': instance.firstLabel,
  'previousLabel': instance.previousLabel,
  'nextLabel': instance.nextLabel,
  'lastLabel': instance.lastLabel,
  'alignment': _$MainAxisAlignmentCEnumMap[instance.alignment]!,
  'fontSize': instance.fontSize,
  'fontWeight': instance.fontWeight,
  'textColor': instance.textColor.toJson(),
  'buttonColor': ?instance.buttonColor?.toJson(),
  'activeColor': instance.activeColor.toJson(),
  'activeTextColor': instance.activeTextColor.toJson(),
  'borderColor': ?instance.borderColor?.toJson(),
  'borderWidth': instance.borderWidth,
  'cornerRadius': instance.cornerRadius,
  'buttonSize': instance.buttonSize,
  'spacing': instance.spacing,
  'disabledOpacity': instance.disabledOpacity,
};

const _$MainAxisAlignmentCEnumMap = {
  MainAxisAlignmentC.start: 'start',
  MainAxisAlignmentC.center: 'center',
  MainAxisAlignmentC.end: 'end',
  MainAxisAlignmentC.spaceBetween: 'spaceBetween',
  MainAxisAlignmentC.spaceAround: 'spaceAround',
  MainAxisAlignmentC.spaceEvenly: 'spaceEvenly',
};
