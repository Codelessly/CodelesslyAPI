// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WidthRange _$WidthRangeFromJson(Map json) => WidthRange(
      from: (json['from'] as num).toInt(),
      to: (json['to'] as num).toInt(),
    );

Map<String, dynamic> _$WidthRangeToJson(WidthRange instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
    };

TextNode _$TextNodeFromJson(Map json) => TextNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
      visible: json['visible'] as bool? ?? true,
      enabled: json['enabled'] as bool? ?? true,
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
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
      verticalFit: $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
          SizeFit.fixed,
      flex: (json['flex'] as num?)?.toInt() ?? 1,
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
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          [],
      characters: json['characters'] as String,
      textMixedProps: (json['textMixedProps'] as List<dynamic>?)
              ?.map((e) => StartEndProp.fromJson(e as Map))
              .toList() ??
          [],
      paragraphIndent: (json['paragraphIndent'] as num?)?.toDouble() ?? 0,
      paragraphSpacing: (json['paragraphSpacing'] as num?)?.toDouble() ?? 0,
      textAlignHorizontal: $enumDecodeNullable(
              _$TextAlignHorizontalEnumEnumMap, json['textAlignHorizontal']) ??
          TextAlignHorizontalEnum.left,
      textAlignVertical: $enumDecodeNullable(
              _$TextAlignVerticalEnumEnumMap, json['textAlignVertical']) ??
          TextAlignVerticalEnum.top,
      maxLines: (json['maxLines'] as num?)?.toInt(),
      overflow: $enumDecodeNullable(_$TextOverflowCEnumMap, json['overflow']) ??
          TextOverflowC.clip,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      isMask: json['isMask'] as bool? ?? false,
      effects: (json['effects'] as List<dynamic>?)
              ?.map((e) => Effect.fromJson(e as Map))
              .toList() ??
          [],
      blendMode: $enumDecodeNullable(_$BlendModeCEnumMap, json['blendMode'],
              unknownValue: BlendModeC.srcOver) ??
          BlendModeC.srcOver,
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
      multipleVariables: (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {},
      inkWell: json['inkWell'] == null
          ? null
          : InkWellModel.fromJson(
              Map<String, dynamic>.from(json['inkWell'] as Map)),
    )
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$TextNodeToJson(TextNode instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

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
  writeNotNull('edgePins', instance.edgePins, instance.edgePins.toJson(),
      EdgePinsModel.standard);
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
  val['characters'] = instance.characters;
  writeNotNull('alignment', instance.alignment, instance.alignment.toJson(),
      AlignmentModel.none);
  writeNotNull('textMixedProps', instance.textMixedProps,
      instance.textMixedProps.map((e) => e.toJson()).toList(), const []);
  writeNotNull(
      'textAlignHorizontal',
      instance.textAlignHorizontal,
      _$TextAlignHorizontalEnumEnumMap[instance.textAlignHorizontal]!,
      TextAlignHorizontalEnum.left);
  writeNotNull(
      'textAlignVertical',
      instance.textAlignVertical,
      _$TextAlignVerticalEnumEnumMap[instance.textAlignVertical]!,
      TextAlignVerticalEnum.top);
  writeNotNull(
      'paragraphIndent', instance.paragraphIndent, instance.paragraphIndent, 0);
  writeNotNull('paragraphSpacing', instance.paragraphSpacing,
      instance.paragraphSpacing, 0);
  writeNotNull('reactions', instance.reactions,
      instance.reactions.map((e) => e.toJson()).toList(), const []);
  writeNotNull('maxLines', instance.maxLines, instance.maxLines, null);
  writeNotNull('overflow', instance.overflow,
      _$TextOverflowCEnumMap[instance.overflow]!, TextOverflowC.clip);
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
  writeNotNull('enabled', instance.enabled, instance.enabled, true);
  writeNotNull('opacity', instance.opacity, instance.opacity, 1.0);
  writeNotNull('blendMode', instance.blendMode,
      _$BlendModeCEnumMap[instance.blendMode]!, BlendModeC.srcOver);
  writeNotNull('isMask', instance.isMask, instance.isMask, false);
  writeNotNull('effects', instance.effects,
      instance.effects.map((e) => e.toJson()).toList(), const []);
  writeNotNull('inkWell', instance.inkWell, instance.inkWell?.toJson(), null);
  val['type'] = instance.type;
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

const _$TextAlignHorizontalEnumEnumMap = {
  TextAlignHorizontalEnum.left: 'left',
  TextAlignHorizontalEnum.center: 'center',
  TextAlignHorizontalEnum.right: 'right',
  TextAlignHorizontalEnum.justified: 'justified',
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
