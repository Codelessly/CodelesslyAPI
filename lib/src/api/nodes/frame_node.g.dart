// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frame_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$FrameNodeOmitDefaults(
  FrameNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.contentAlignment, AlignmentModel.center))
    json.remove('contentAlignment');
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
  if (isJsonDefault(instance.opacity, 1)) json.remove('opacity');
  if (isJsonDefault(instance.blendMode, BlendModeC.srcOver))
    json.remove('blendMode');
  if (isJsonDefault(instance.isMask, false)) json.remove('isMask');
  if (isJsonDefault(instance.effects, const [])) json.remove('effects');
  if (isJsonDefault(instance.fills, const [])) json.remove('fills');
  if (isJsonDefault(instance.strokes, const [])) json.remove('strokes');
  if (isJsonDefault(instance.strokeWeight, 0)) json.remove('strokeWeight');
  if (isJsonDefault(instance.strokeMiterLimit, 4.0))
    json.remove('strokeMiterLimit');
  if (isJsonDefault(instance.strokeAlign, StrokeAlignC.inside))
    json.remove('strokeAlign');
  if (isJsonDefault(instance.strokeCap, StrokeCapEnum.none))
    json.remove('strokeCap');
  if (isJsonDefault(instance.dashPattern, const [])) json.remove('dashPattern');
  if (isJsonDefault(instance.strokeSide, StrokeSide.all))
    json.remove('strokeSide');
  if (isJsonDefault(instance.cornerSmoothing, 0))
    json.remove('cornerSmoothing');
  if (isJsonDefault(instance.cornerRadius, CornerRadius.zero))
    json.remove('cornerRadius');
  if (isJsonDefault(instance.clipsContent, true)) json.remove('clipsContent');
  if (isJsonDefault(instance.children, [])) json.remove('children');
  if (isJsonDefault(instance.isScrollable, false)) json.remove('isScrollable');
  if (isJsonDefault(instance.scrollDirection, AxisC.vertical))
    json.remove('scrollDirection');
  if (isJsonDefault(instance.reverse, false)) json.remove('reverse');
  if (isJsonDefault(instance.primary, true)) json.remove('primary');
  if (isJsonDefault(instance.physics, ScrollPhysicsC.platformDependent))
    json.remove('physics');
  if (isJsonDefault(
    instance.keyboardDismissBehavior,
    ScrollViewKeyboardDismissBehaviorC.manual,
  ))
    json.remove('keyboardDismissBehavior');
  if (isJsonDefault(instance.useFlutterListView, false))
    json.remove('useFlutterListView');
  if (isJsonDefault(instance.shouldAlwaysScroll, true))
    json.remove('shouldAlwaysScroll');
  if (isJsonDefault(instance.showPortal, false)) json.remove('showPortal');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FrameNode _$FrameNodeFromJson(Map json) =>
    FrameNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        children:
            (json['children'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        rotationDegrees: json['rotation'] == null
            ? 0
            : castRotation(json['rotation']),
        fills:
            (json['fills'] as List<dynamic>?)
                ?.map((e) => PaintModel.fromJson(e as Map))
                .toList() ??
            const [],
        strokes:
            (json['strokes'] as List<dynamic>?)
                ?.map((e) => PaintModel.fromJson(e as Map))
                .toList() ??
            const [],
        effects:
            (json['effects'] as List<dynamic>?)
                ?.map((e) => Effect.fromJson(e as Map))
                .toList() ??
            const [],
        blendMode:
            $enumDecodeNullable(
              _$BlendModeCEnumMap,
              json['blendMode'],
              unknownValue: BlendModeC.srcOver,
            ) ??
            BlendModeC.srcOver,
        visible: json['visible'] as bool? ?? true,
        enabled: json['enabled'] as bool? ?? true,
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
        isMask: json['isMask'] as bool? ?? false,
        strokeWeight: (json['strokeWeight'] as num?)?.toDouble() ?? 0,
        strokeMiterLimit: (json['strokeMiterLimit'] as num?)?.toDouble() ?? 4.0,
        strokeAlign:
            $enumDecodeNullable(_$StrokeAlignCEnumMap, json['strokeAlign']) ??
            StrokeAlignC.inside,
        strokeCap:
            $enumDecodeNullable(
              _$StrokeCapEnumEnumMap,
              json['strokeCap'],
              unknownValue: StrokeCapEnum.none,
            ) ??
            StrokeCapEnum.none,
        cornerSmoothing: (json['cornerSmoothing'] as num?)?.toDouble() ?? 0,
        cornerRadius: json['cornerRadius'] == null
            ? CornerRadius.zero
            : CornerRadius.fromJson(json['cornerRadius']),
        dashPattern:
            (json['dashPattern'] as List<dynamic>?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            const [],
        alignment: json['alignment'] == null
            ? AlignmentModel.none
            : AlignmentModel.fromJson(json['alignment'] as Map),
        padding: json['padding'] == null
            ? EdgeInsetsModel.zero
            : EdgeInsetsModel.fromJson(json['padding']),
        margin: json['margin'] == null
            ? EdgeInsetsModel.zero
            : EdgeInsetsModel.fromJson(json['margin']),
        strokeSide:
            $enumDecodeNullable(_$StrokeSideEnumMap, json['strokeSide']) ??
            StrokeSide.all,
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
        clipsContent: json['clipsContent'] as bool? ?? true,
        isScrollable: json['isScrollable'] as bool? ?? false,
        scrollDirection:
            $enumDecodeNullable(_$AxisCEnumMap, json['scrollDirection']) ??
            AxisC.vertical,
        reverse: json['reverse'] as bool? ?? false,
        physics:
            $enumDecodeNullable(
              _$ScrollPhysicsCEnumMap,
              json['physics'],
              unknownValue: ScrollPhysicsC.platformDependent,
            ) ??
            ScrollPhysicsC.platformDependent,
        primary: json['primary'] as bool? ?? true,
        keyboardDismissBehavior:
            $enumDecodeNullable(
              _$ScrollViewKeyboardDismissBehaviorCEnumMap,
              json['keyboardDismissBehavior'],
            ) ??
            ScrollViewKeyboardDismissBehaviorC.manual,
        useFlutterListView: json['useFlutterListView'] as bool? ?? false,
        shouldAlwaysScroll: json['shouldAlwaysScroll'] as bool? ?? true,
        canvasID: json['canvasID'] as String?,
        pageID: json['pageID'] as String?,
        layoutID: json['layoutID'] as String?,
        showPortal: json['showPortal'] as bool? ?? false,
        contentFit: $enumDecodeNullable(_$FitEnumMap, json['contentFit']),
        contentAlignment: json['contentAlignment'] == null
            ? AlignmentModel.center
            : AlignmentModel.fromJson(json['contentAlignment'] as Map),
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
      ..inkWell = json['inkWell'] == null
          ? null
          : InkWellModel.fromJson(
              Map<String, dynamic>.from(json['inkWell'] as Map),
            )
      ..transition = json['transition'] == null
          ? null
          : NodeTransition.fromJson(json['transition'] as Map)
      ..type = json['type'] as String;

Map<String, dynamic> _$FrameNodeToJson(FrameNode instance) => <String, dynamic>{
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
  'reactions': instance.reactions.map((e) => e.toJson()).toList(),
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
  'children': instance.children,
  'opacity': instance.opacity,
  'blendMode': _$BlendModeCEnumMap[instance.blendMode]!,
  'isMask': instance.isMask,
  'effects': instance.effects.map((e) => e.toJson()).toList(),
  'inkWell': ?instance.inkWell?.toJson(),
  'transition': ?instance.transition?.toJson(),
  'fills': instance.fills.map((e) => e.toJson()).toList(),
  'strokes': instance.strokes.map((e) => e.toJson()).toList(),
  'strokeWeight': instance.strokeWeight,
  'strokeMiterLimit': instance.strokeMiterLimit,
  'strokeAlign': _$StrokeAlignCEnumMap[instance.strokeAlign]!,
  'strokeCap': _$StrokeCapEnumEnumMap[instance.strokeCap]!,
  'dashPattern': instance.dashPattern,
  'strokeSide': _$StrokeSideEnumMap[instance.strokeSide]!,
  'clipsContent': instance.clipsContent,
  'cornerSmoothing': instance.cornerSmoothing,
  'cornerRadius': instance.cornerRadius.toJson(),
  'isScrollable': instance.isScrollable,
  'scrollDirection': _$AxisCEnumMap[instance.scrollDirection]!,
  'reverse': instance.reverse,
  'primary': instance.primary,
  'physics': _$ScrollPhysicsCEnumMap[instance.physics]!,
  'keyboardDismissBehavior':
      _$ScrollViewKeyboardDismissBehaviorCEnumMap[instance
          .keyboardDismissBehavior]!,
  'useFlutterListView': instance.useFlutterListView,
  'shouldAlwaysScroll': instance.shouldAlwaysScroll,
  'canvasID': ?instance.canvasID,
  'pageID': ?instance.pageID,
  'layoutID': ?instance.layoutID,
  'showPortal': instance.showPortal,
  'type': instance.type,
  'contentFit': ?_$FitEnumMap[instance.contentFit],
  'contentAlignment': instance.contentAlignment.toJson(),
};

const _$BlendModeCEnumMap = {
  BlendModeC.clear: 'clear',
  BlendModeC.src: 'src',
  BlendModeC.dst: 'dst',
  BlendModeC.srcOver: 'srcOver',
  BlendModeC.dstOver: 'dstOver',
  BlendModeC.srcIn: 'srcIn',
  BlendModeC.dstIn: 'dstIn',
  BlendModeC.srcOut: 'srcOut',
  BlendModeC.dstOut: 'dstOut',
  BlendModeC.srcATop: 'srcATop',
  BlendModeC.dstATop: 'dstATop',
  BlendModeC.xor: 'xor',
  BlendModeC.plus: 'plus',
  BlendModeC.modulate: 'modulate',
  BlendModeC.screen: 'screen',
  BlendModeC.overlay: 'overlay',
  BlendModeC.darken: 'darken',
  BlendModeC.lighten: 'lighten',
  BlendModeC.colorDodge: 'colorDodge',
  BlendModeC.colorBurn: 'colorBurn',
  BlendModeC.hardLight: 'hardLight',
  BlendModeC.softLight: 'softLight',
  BlendModeC.difference: 'difference',
  BlendModeC.exclusion: 'exclusion',
  BlendModeC.multiply: 'multiply',
  BlendModeC.hue: 'hue',
  BlendModeC.saturation: 'saturation',
  BlendModeC.color: 'color',
  BlendModeC.luminosity: 'luminosity',
};

const _$StrokeAlignCEnumMap = {
  StrokeAlignC.center: 'center',
  StrokeAlignC.outside: 'outside',
  StrokeAlignC.inside: 'inside',
};

const _$StrokeCapEnumEnumMap = {
  StrokeCapEnum.round: 'round',
  StrokeCapEnum.none: 'none',
  StrokeCapEnum.square: 'square',
};

const _$StrokeSideEnumMap = {
  StrokeSide.left: 'left',
  StrokeSide.right: 'right',
  StrokeSide.bottom: 'bottom',
  StrokeSide.top: 'top',
  StrokeSide.all: 'all',
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

const _$AxisCEnumMap = {
  AxisC.horizontal: 'horizontal',
  AxisC.vertical: 'vertical',
};

const _$ScrollPhysicsCEnumMap = {
  ScrollPhysicsC.platformDependent: 'platformDependent',
  ScrollPhysicsC.bouncingScrollPhysics: 'bouncingScrollPhysics',
  ScrollPhysicsC.clampingScrollPhysics: 'clampingScrollPhysics',
  ScrollPhysicsC.neverScrollableScrollPhysics: 'neverScrollableScrollPhysics',
  ScrollPhysicsC.rangeMaintainingScrollPhysics: 'rangeMaintainingScrollPhysics',
};

const _$ScrollViewKeyboardDismissBehaviorCEnumMap = {
  ScrollViewKeyboardDismissBehaviorC.manual: 'manual',
  ScrollViewKeyboardDismissBehaviorC.onDrag: 'onDrag',
};

const _$FitEnumMap = {
  Fit.contain: 'contain',
  Fit.cover: 'cover',
  Fit.fill: 'fill',
  Fit.fitHeight: 'fitHeight',
  Fit.fitWidth: 'fitWidth',
  Fit.none: 'none',
  Fit.scaleDown: 'scaleDown',
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
