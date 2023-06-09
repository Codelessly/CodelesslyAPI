// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WidthRange _$WidthRangeFromJson(Map json) => WidthRange(
      from: json['from'] as int,
      to: json['to'] as int,
    );

Map<String, dynamic> _$WidthRangeToJson(WidthRange instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
    };

TextNode _$TextNodeFromJson(Map json) => TextNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      outerBoxLocal: json['outerBoxLocal'] == null
          ? null
          : OuterNodeBox.fromJson(json['outerBoxLocal'] as Map),
      visible: json['visible'] as bool? ?? true,
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin'] as Map),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding'] as Map),
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
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          const [],
      characters: json['characters'] as String,
      textMixedProps: (json['textMixedProps'] as List<dynamic>?)
              ?.map((e) => StartEndProp.fromJson(e as Map))
              .toList() ??
          const [],
      paragraphIndent: (json['paragraphIndent'] as num?)?.toDouble() ?? 0,
      paragraphSpacing: (json['paragraphSpacing'] as num?)?.toDouble() ?? 0,
      textAlignHorizontal: $enumDecodeNullable(
              _$TextAlignHorizontalEnumEnumMap, json['textAlignHorizontal']) ??
          TextAlignHorizontalEnum.left,
      textAlignVertical: $enumDecodeNullable(
              _$TextAlignVerticalEnumEnumMap, json['textAlignVertical']) ??
          TextAlignVerticalEnum.top,
      maxLines: json['maxLines'] as int?,
      overflow: $enumDecodeNullable(_$TextOverflowCEnumMap, json['overflow']) ??
          TextOverflowC.clip,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      isMask: json['isMask'] as bool? ?? false,
      effects: (json['effects'] as List<dynamic>?)
              ?.map((e) => Effect.fromJson(e as Map))
              .toList() ??
          const [],
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
  final val = <String, dynamic>{
    'variables': instance.variables,
    'multipleVariables': instance.multipleVariables,
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
    'characters': instance.characters,
    'outerBoxLocal': instance.outerBoxLocal.toJson(),
    'textMixedProps': instance.textMixedProps.map((e) => e.toJson()).toList(),
    'textAlignHorizontal':
        _$TextAlignHorizontalEnumEnumMap[instance.textAlignHorizontal]!,
    'textAlignVertical':
        _$TextAlignVerticalEnumEnumMap[instance.textAlignVertical]!,
    'paragraphIndent': instance.paragraphIndent,
    'paragraphSpacing': instance.paragraphSpacing,
    'basicBoxLocal': instance.basicBoxLocal.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('maxLines', instance.maxLines);
  val['overflow'] = _$TextOverflowCEnumMap[instance.overflow]!;
  val['margin'] = instance.margin.toJson();
  val['padding'] = instance.padding.toJson();
  val['rotation'] = instance.rotationDegrees;
  writeNotNull('widthFactor', instance.widthFactor);
  writeNotNull('heightFactor', instance.heightFactor);
  val['opacity'] = instance.opacity;
  val['blendMode'] = _$BlendModeCEnumMap[instance.blendMode]!;
  val['isMask'] = instance.isMask;
  val['effects'] = instance.effects.map((e) => e.toJson()).toList();
  writeNotNull('inkWell', instance.inkWell?.toJson());
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
