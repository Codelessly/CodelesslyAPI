// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rectangle_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RectangleNode _$RectangleNodeFromJson(Map json) => RectangleNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      outerBoxLocal: json['outerBoxLocal'] == null
          ? null
          : OuterNodeBox.fromJson(json['outerBoxLocal'] as Map),
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      fills: (json['fills'] as List<dynamic>?)
              ?.map((e) => PaintModel.fromJson(e as Map))
              .toList() ??
          const [],
      strokes: (json['strokes'] as List<dynamic>?)
              ?.map((e) => PaintModel.fromJson(e as Map))
              .toList() ??
          const [],
      effects: (json['effects'] as List<dynamic>?)
              ?.map((e) => Effect.fromJson(e as Map))
              .toList() ??
          const [],
      blendMode: $enumDecodeNullable(_$BlendModeCEnumMap, json['blendMode'],
              unknownValue: BlendModeC.srcOver) ??
          BlendModeC.srcOver,
      visible: json['visible'] as bool? ?? true,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
      isMask: json['isMask'] as bool? ?? false,
      strokeWeight: (json['strokeWeight'] as num?)?.toDouble() ?? 0,
      strokeMiterLimit: (json['strokeMiterLimit'] as num?)?.toDouble(),
      strokeAlign:
          $enumDecodeNullable(_$StrokeAlignCEnumMap, json['strokeAlign']) ??
              StrokeAlignC.inside,
      strokeCap: $enumDecodeNullable(_$StrokeCapEnumEnumMap, json['strokeCap'],
              unknownValue: StrokeCapEnum.square) ??
          StrokeCapEnum.square,
      dashPattern: (json['dashPattern'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding'] as Map),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin'] as Map),
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      strokeSide:
          $enumDecodeNullable(_$StrokeSideEnumMap, json['strokeSide']) ??
              StrokeSide.all,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          const [],
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
      cornerSmoothing: (json['cornerSmoothing'] as num?)?.toDouble() ?? 0,
      cornerRadius: json['cornerRadius'] == null
          ? CornerRadius.zero
          : CornerRadius.fromJson(json['cornerRadius'] as Map),
      clipsContent: json['clipsContent'] as bool? ?? true,
    )
      ..variables = (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {}
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..inkWell = json['inkWell'] == null
          ? null
          : InkWellModel.fromJson(
              Map<String, dynamic>.from(json['inkWell'] as Map))
      ..type = json['type'] as String;

Map<String, dynamic> _$RectangleNodeToJson(RectangleNode instance) {
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
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
    'alignment': instance.alignment.toJson(),
    'outerBoxLocal': instance.outerBoxLocal.toJson(),
    'basicBoxLocal': instance.basicBoxLocal.toJson(),
    'margin': instance.margin.toJson(),
    'padding': instance.padding.toJson(),
    'rotation': instance.rotationDegrees,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('widthFactor', instance.widthFactor);
  writeNotNull('heightFactor', instance.heightFactor);
  val['opacity'] = instance.opacity;
  val['blendMode'] = _$BlendModeCEnumMap[instance.blendMode]!;
  val['isMask'] = instance.isMask;
  val['effects'] = instance.effects.map((e) => e.toJson()).toList();
  writeNotNull('inkWell', instance.inkWell?.toJson());
  val['fills'] = instance.fills.map((e) => e.toJson()).toList();
  val['strokes'] = instance.strokes.map((e) => e.toJson()).toList();
  val['strokeWeight'] = instance.strokeWeight;
  val['strokeMiterLimit'] = instance.strokeMiterLimit;
  val['strokeAlign'] = _$StrokeAlignCEnumMap[instance.strokeAlign]!;
  val['strokeCap'] = _$StrokeCapEnumEnumMap[instance.strokeCap]!;
  val['dashPattern'] = instance.dashPattern;
  val['strokeSide'] = _$StrokeSideEnumMap[instance.strokeSide]!;
  val['clipsContent'] = instance.clipsContent;
  val['cornerSmoothing'] = instance.cornerSmoothing;
  val['cornerRadius'] = instance.cornerRadius.toJson();
  val['type'] = instance.type;
  return val;
}

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
  StrokeCapEnum.butt: 'butt',
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
