// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accordion_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccordionNode _$AccordionNodeFromJson(Map json) => AccordionNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      rowColumnType:
          $enumDecodeNullable(_$RowColumnTypeEnumMap, json['rowColumnType']) ??
              RowColumnType.column,
      mainAxisAlignment: $enumDecodeNullable(
              _$MainAxisAlignmentCEnumMap, json['mainAxisAlignment']) ??
          MainAxisAlignmentC.center,
      crossAxisAlignment: $enumDecodeNullable(
              _$CrossAxisAlignmentCEnumMap, json['crossAxisAlignment']) ??
          CrossAxisAlignmentC.center,
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
      children:
          (json['children'] as List<dynamic>).map((e) => e as String).toList(),
      isExpanded: json['isExpanded'] as bool? ?? true,
    )
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..variables = (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {}
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..type = json['type'] as String;

Map<String, dynamic> _$AccordionNodeToJson(AccordionNode instance) {
  final val = <String, dynamic>{
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
  val['children'] = instance.children;
  val['variables'] = instance.variables;
  val['multipleVariables'] = instance.multipleVariables;
  val['rowColumnType'] = _$RowColumnTypeEnumMap[instance.rowColumnType]!;
  val['mainAxisAlignment'] =
      _$MainAxisAlignmentCEnumMap[instance.mainAxisAlignment]!;
  val['crossAxisAlignment'] =
      _$CrossAxisAlignmentCEnumMap[instance.crossAxisAlignment]!;
  val['type'] = instance.type;
  val['isExpanded'] = instance.isExpanded;
  return val;
}

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
