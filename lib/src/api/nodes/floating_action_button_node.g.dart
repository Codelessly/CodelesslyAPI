// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'floating_action_button_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FloatingActionButtonNode _$FloatingActionButtonNodeFromJson(Map json) =>
    FloatingActionButtonNode(
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
      aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
      constraints: json['constraints'] == null
          ? const BoxConstraintsModel()
          : BoxConstraintsModel.fromJson(json['constraints'] as Map),
      positioningMode: $enumDecodeNullable(
              _$PositioningModeEnumMap, json['positioningMode']) ??
          PositioningMode.align,
      edgePins: json['edgePins'] == null
          ? EdgePinsModel.standard
          : EdgePinsModel.fromJson(
              Map<String, dynamic>.from(json['edgePins'] as Map)),
      properties:
          FloatingActionButtonProperties.fromJson(json['properties'] as Map),
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
    )
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..type = json['type'] as String;

Map<String, dynamic> _$FloatingActionButtonNodeToJson(
    FloatingActionButtonNode instance) {
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

FloatingActionButtonProperties _$FloatingActionButtonPropertiesFromJson(
        Map json) =>
    FloatingActionButtonProperties(
      backgroundColor: json['backgroundColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['backgroundColor'] as Map),
      foregroundColor: json['foregroundColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['foregroundColor'] as Map),
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
      focusElevation: (json['focusElevation'] as num?)?.toDouble() ?? 0,
      hoverElevation: (json['hoverElevation'] as num?)?.toDouble() ?? 0,
      highlightElevation: (json['highlightElevation'] as num?)?.toDouble() ?? 0,
      extendedIconLabelSpacing:
          (json['extendedIconLabelSpacing'] as num?)?.toDouble() ?? 0,
      icon: json['icon'] == null
          ? const MultiSourceIconModel()
          : MultiSourceIconModel.fromJson(json['icon'] as Map),
      type: $enumDecodeNullable(
              _$FloatingActionButtonTypeEnumMap, json['type']) ??
          FloatingActionButtonType.regular,
      location: $enumDecodeNullable(_$FABLocationEnumMap, json['location']) ??
          FABLocation.endFloat,
      label: json['label'] as String? ?? '',
      labelStyle: json['labelStyle'] == null
          ? null
          : TextProp.fromJson(json['labelStyle'] as Map),
      focusColor: json['focusColor'] == null
          ? null
          : ColorRGBA.fromJson(json['focusColor'] as Map),
      hoverColor: json['hoverColor'] == null
          ? null
          : ColorRGBA.fromJson(json['hoverColor'] as Map),
      splashColor: json['splashColor'] == null
          ? null
          : ColorRGBA.fromJson(json['splashColor'] as Map),
      shape: $enumDecodeNullable(_$CShapeBorderEnumMap, json['shape']) ??
          CShapeBorder.circle,
      cornerRadius: json['cornerRadius'] == null
          ? CornerRadius.zero
          : CornerRadius.fromJson(json['cornerRadius'] as Map),
      borderColor: json['borderColor'] == null
          ? null
          : ColorRGBA.fromJson(json['borderColor'] as Map),
      borderWidth: (json['borderWidth'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$FloatingActionButtonPropertiesToJson(
    FloatingActionButtonProperties instance) {
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
  val['backgroundColor'] = instance.backgroundColor.toJson();
  val['foregroundColor'] = instance.foregroundColor.toJson();
  val['elevation'] = instance.elevation;
  val['focusElevation'] = instance.focusElevation;
  val['hoverElevation'] = instance.hoverElevation;
  val['highlightElevation'] = instance.highlightElevation;
  val['type'] = _$FloatingActionButtonTypeEnumMap[instance.type]!;
  val['location'] = _$FABLocationEnumMap[instance.location]!;
  val['icon'] = instance.icon.toJson();
  val['label'] = instance.label;
  val['labelStyle'] = instance.labelStyle.toJson();
  writeNotNull('focusColor', instance.focusColor?.toJson());
  writeNotNull('hoverColor', instance.hoverColor?.toJson());
  writeNotNull('splashColor', instance.splashColor?.toJson());
  val['extendedIconLabelSpacing'] = instance.extendedIconLabelSpacing;
  return val;
}

const _$FloatingActionButtonTypeEnumMap = {
  FloatingActionButtonType.regular: 'regular',
  FloatingActionButtonType.small: 'small',
  FloatingActionButtonType.large: 'large',
  FloatingActionButtonType.extended: 'extended',
};

const _$FABLocationEnumMap = {
  FABLocation.startTop: 'startTop',
  FABLocation.miniStartTop: 'miniStartTop',
  FABLocation.centerTop: 'centerTop',
  FABLocation.miniCenterTop: 'miniCenterTop',
  FABLocation.endTop: 'endTop',
  FABLocation.miniEndTop: 'miniEndTop',
  FABLocation.startFloat: 'startFloat',
  FABLocation.miniStartFloat: 'miniStartFloat',
  FABLocation.centerFloat: 'centerFloat',
  FABLocation.miniCenterFloat: 'miniCenterFloat',
  FABLocation.endFloat: 'endFloat',
  FABLocation.miniEndFloat: 'miniEndFloat',
  FABLocation.startDocked: 'startDocked',
  FABLocation.miniStartDocked: 'miniStartDocked',
  FABLocation.centerDocked: 'centerDocked',
  FABLocation.miniCenterDocked: 'miniCenterDocked',
  FABLocation.endDocked: 'endDocked',
  FABLocation.miniEndDocked: 'miniEndDocked',
};

const _$CShapeBorderEnumMap = {
  CShapeBorder.rectangle: 'rectangle',
  CShapeBorder.circle: 'circle',
  CShapeBorder.stadium: 'stadium',
  CShapeBorder.roundedRectangle: 'roundedRectangle',
  CShapeBorder.continuousRectangle: 'continuousRectangle',
  CShapeBorder.beveledRectangle: 'beveledRectangle',
};
