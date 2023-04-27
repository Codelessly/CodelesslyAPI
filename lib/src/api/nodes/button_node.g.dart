// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'button_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ButtonNode _$ButtonNodeFromJson(Map json) => ButtonNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      outerBoxLocal: json['outerBoxLocal'] == null
          ? null
          : OuterNodeBox.fromJson(json['outerBoxLocal'] as Map),
      visible: json['visible'] as bool? ?? true,
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding'] as Map),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin'] as Map),
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
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
      aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
      edgePins: json['edgePins'] == null
          ? EdgePinsModel.standard
          : EdgePinsModel.fromJson(
              Map<String, dynamic>.from(json['edgePins'] as Map)),
      positioningMode: $enumDecodeNullable(
              _$PositioningModeEnumMap, json['positioningMode']) ??
          PositioningMode.align,
      properties: ButtonProperties.fromJson(json['properties'] as Map),
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
      multipleVariables: (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {},
    )
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$ButtonNodeToJson(ButtonNode instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'visible': instance.visible,
    'constraints': instance.constraints.toJson(),
    'edgePins': instance.edgePins.toJson(),
    'positioningMode': _$PositioningModeEnumMap[instance.positioningMode]!,
    'horizontalFit': _$SizeFitEnumMap[instance.horizontalFit]!,
    'verticalFit': _$SizeFitEnumMap[instance.verticalFit]!,
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
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
  val['variables'] = instance.variables;
  val['multipleVariables'] = instance.multipleVariables;
  val['type'] = instance.type;
  val['properties'] = instance.properties.toJson();
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

ButtonProperties _$ButtonPropertiesFromJson(Map json) => ButtonProperties(
      buttonType:
          $enumDecodeNullable(_$ButtonTypeEnumEnumMap, json['buttonType']) ??
              ButtonTypeEnum.elevated,
      buttonColor: json['buttonColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['buttonColor'] as Map),
      shadowColor: json['shadowColor'] == null
          ? const ColorRGBA(r: 0.65, g: 0.65, b: 0.65, a: 1)
          : ColorRGBA.fromJson(json['shadowColor'] as Map),
      label: json['label'] as String? ?? '',
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
      enabled: json['enabled'] as bool? ?? true,
      labelAlignment: $enumDecodeNullable(
              _$TextAlignHorizontalEnumEnumMap, json['labelAlignment']) ??
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
          : CornerRadius.fromJson(json['cornerRadius'] as Map),
      borderColor: json['borderColor'] == null
          ? null
          : ColorRGBA.fromJson(json['borderColor'] as Map),
      shape: $enumDecodeNullable(_$CShapeBorderEnumMap, json['shape']) ??
          CShapeBorder.roundedRectangle,
      borderWidth: (json['borderWidth'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ButtonPropertiesToJson(ButtonProperties instance) {
  final val = <String, dynamic>{
    'shape': _$CShapeBorderEnumMap[instance.shape]!,
    'cornerRadius': instance.cornerRadius.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('borderWidth', instance.borderWidth);
  writeNotNull('borderColor', instance.borderColor?.toJson());
  val['buttonType'] = _$ButtonTypeEnumEnumMap[instance.buttonType]!;
  val['buttonColor'] = instance.buttonColor.toJson();
  val['shadowColor'] = instance.shadowColor.toJson();
  val['elevation'] = instance.elevation;
  val['enabled'] = instance.enabled;
  val['label'] = instance.label;
  val['labelAlignment'] =
      _$TextAlignHorizontalEnumEnumMap[instance.labelAlignment]!;
  val['labelStyle'] = instance.labelStyle.toJson();
  val['placement'] = _$IconPlacementEnumEnumMap[instance.placement]!;
  val['gap'] = instance.gap;
  val['icon'] = instance.icon.toJson();
  return val;
}

const _$ButtonTypeEnumEnumMap = {
  ButtonTypeEnum.elevated: 'elevated',
  ButtonTypeEnum.text: 'text',
  ButtonTypeEnum.outlined: 'outlined',
  ButtonTypeEnum.icon: 'icon',
};

const _$TextAlignHorizontalEnumEnumMap = {
  TextAlignHorizontalEnum.left: 'left',
  TextAlignHorizontalEnum.center: 'center',
  TextAlignHorizontalEnum.right: 'right',
  TextAlignHorizontalEnum.justified: 'justified',
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
};
