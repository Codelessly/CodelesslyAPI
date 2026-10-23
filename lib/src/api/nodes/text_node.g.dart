// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$WidthRangeOmitDefaults(
  WidthRange instance,
  Map<String, dynamic> json,
) {
  return json;
}

Map<String, dynamic> _$TextNodeOmitDefaults(
  TextNode instance,
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
  if (isJsonDefault(instance.opacity, 1.0)) json.remove('opacity');
  if (isJsonDefault(instance.blendMode, BlendModeC.srcOver))
    json.remove('blendMode');
  if (isJsonDefault(instance.isMask, false)) json.remove('isMask');
  if (isJsonDefault(instance.effects, const [])) json.remove('effects');
  if (isJsonDefault(instance.textMixedProps, const []))
    json.remove('textMixedProps');
  if (isJsonDefault(instance.textAlignHorizontal, TextAlignHorizontalEnum.left))
    json.remove('textAlignHorizontal');
  if (isJsonDefault(instance.textAlignVertical, TextAlignVerticalEnum.top))
    json.remove('textAlignVertical');
  if (isJsonDefault(instance.paragraphIndent, 0))
    json.remove('paragraphIndent');
  if (isJsonDefault(instance.paragraphSpacing, 0))
    json.remove('paragraphSpacing');
  if (isJsonDefault(instance.overflow, TextOverflowC.clip))
    json.remove('overflow');
  if (isJsonDefault(instance.softWrap, true)) json.remove('softWrap');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WidthRange _$WidthRangeFromJson(Map json) => WidthRange(
  from: (json['from'] as num).toInt(),
  to: (json['to'] as num).toInt(),
);

Map<String, dynamic> _$WidthRangeToJson(WidthRange instance) =>
    <String, dynamic>{'from': instance.from, 'to': instance.to};

TextNode _$TextNodeFromJson(Map json) =>
    TextNode(
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
        characters: json['characters'] as String,
        textMixedProps:
            (json['textMixedProps'] as List<dynamic>?)
                ?.map((e) => StartEndProp.fromJson(e as Map))
                .toList() ??
            const [],
        paragraphIndent: (json['paragraphIndent'] as num?)?.toDouble() ?? 0,
        paragraphSpacing: (json['paragraphSpacing'] as num?)?.toDouble() ?? 0,
        textAlignHorizontal:
            $enumDecodeNullable(
              _$TextAlignHorizontalEnumEnumMap,
              json['textAlignHorizontal'],
            ) ??
            TextAlignHorizontalEnum.left,
        textAlignVertical:
            $enumDecodeNullable(
              _$TextAlignVerticalEnumEnumMap,
              json['textAlignVertical'],
            ) ??
            TextAlignVerticalEnum.top,
        maxLines: (json['maxLines'] as num?)?.toInt(),
        overflow:
            $enumDecodeNullable(_$TextOverflowCEnumMap, json['overflow']) ??
            TextOverflowC.clip,
        softWrap: json['softWrap'] as bool? ?? true,
        textScaleFactor: (json['textScaleFactor'] as num?)?.toDouble(),
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
        isMask: json['isMask'] as bool? ?? false,
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
        inkWell: json['inkWell'] == null
            ? null
            : InkWellModel.fromJson(
                Map<String, dynamic>.from(json['inkWell'] as Map),
              ),
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
      ..transition = json['transition'] == null
          ? null
          : NodeTransition.fromJson(json['transition'] as Map)
      ..type = json['type'] as String;

Map<String, dynamic> _$TextNodeToJson(TextNode instance) => <String, dynamic>{
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
  'characters': instance.characters,
  'textMixedProps': instance.textMixedProps.map((e) => e.toJson()).toList(),
  'textAlignHorizontal':
      _$TextAlignHorizontalEnumEnumMap[instance.textAlignHorizontal]!,
  'textAlignVertical':
      _$TextAlignVerticalEnumEnumMap[instance.textAlignVertical]!,
  'paragraphIndent': instance.paragraphIndent,
  'reactions': instance.reactions.map((e) => e.toJson()).toList(),
  'paragraphSpacing': instance.paragraphSpacing,
  'maxLines': ?instance.maxLines,
  'overflow': _$TextOverflowCEnumMap[instance.overflow]!,
  'softWrap': instance.softWrap,
  'textScaleFactor': ?instance.textScaleFactor,
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
  'opacity': instance.opacity,
  'blendMode': _$BlendModeCEnumMap[instance.blendMode]!,
  'isMask': instance.isMask,
  'effects': instance.effects.map((e) => e.toJson()).toList(),
  'inkWell': ?instance.inkWell?.toJson(),
  'transition': ?instance.transition?.toJson(),
  'type': instance.type,
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

const _$TextAlignHorizontalEnumEnumMap = {
  TextAlignHorizontalEnum.left: 'left',
  TextAlignHorizontalEnum.center: 'center',
  TextAlignHorizontalEnum.right: 'right',
  TextAlignHorizontalEnum.justified: 'justified',
  TextAlignHorizontalEnum.start: 'start',
  TextAlignHorizontalEnum.end: 'end',
};

const _$TextAlignVerticalEnumEnumMap = {
  TextAlignVerticalEnum.top: 'top',
  TextAlignVerticalEnum.center: 'center',
  TextAlignVerticalEnum.bottom: 'bottom',
};

const _$TextOverflowCEnumMap = {
  TextOverflowC.clip: 'clip',
  TextOverflowC.fade: 'fade',
  TextOverflowC.ellipsis: 'ellipsis',
  TextOverflowC.visible: 'visible',
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
