// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'floating_action_button_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FloatingActionButtonNode _$FloatingActionButtonNodeFromJson(Map json) =>
    FloatingActionButtonNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
      visible: json['visible'] as bool? ?? true,
      enabled: json['enabled'] as bool? ?? true,
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding']),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin']),
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          [],
      horizontalFit:
          $enumDecodeNullable(_$SizeFitEnumMap, json['horizontalFit']) ??
              SizeFit.fixed,
      verticalFit: $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
          SizeFit.fixed,
      flex: (json['flex'] as num?)?.toInt() ?? 1,
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
      multipleVariables: (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {},
    )
      ..componentId = json['componentId'] as String?
      ..markerType =
          $enumDecodeNullable(_$ComponentMarkerTypeEnumMap, json['markerType'])
      ..componentVersion = (json['componentVersion'] as num).toInt()
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$FloatingActionButtonNodeToJson(
    FloatingActionButtonNode instance) {
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
  writeNotNull('componentId', instance.componentId, instance.componentId, null);
  writeNotNull('markerType', instance.markerType,
      _$ComponentMarkerTypeEnumMap[instance.markerType], null);
  val['componentVersion'] = instance.componentVersion;
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
  writeNotNull('alignment', instance.alignment, instance.alignment.toJson(),
      AlignmentModel.none);
  writeNotNull('reactions', instance.reactions,
      instance.reactions.map((e) => e.toJson()).toList(), const []);
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

const _$ComponentMarkerTypeEnumMap = {
  ComponentMarkerType.component: 'component',
  ComponentMarkerType.instance: 'instance',
};

FloatingActionButtonProperties _$FloatingActionButtonPropertiesFromJson(
        Map json) =>
    FloatingActionButtonProperties(
      backgroundColor: json['backgroundColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['backgroundColor']),
      foregroundColor: json['foregroundColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['foregroundColor']),
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
          : ColorRGBA.fromJson(json['focusColor']),
      hoverColor: json['hoverColor'] == null
          ? null
          : ColorRGBA.fromJson(json['hoverColor']),
      splashColor: json['splashColor'] == null
          ? null
          : ColorRGBA.fromJson(json['splashColor']),
      shape: $enumDecodeNullable(_$CShapeBorderEnumMap, json['shape']) ??
          CShapeBorder.circle,
      cornerRadius: json['cornerRadius'] == null
          ? CornerRadius.zero
          : CornerRadius.fromJson(json['cornerRadius']),
      borderColor: json['borderColor'] == null
          ? null
          : ColorRGBA.fromJson(json['borderColor']),
      borderWidth: (json['borderWidth'] as num?)?.toDouble(),
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => Reaction.fromJson(e as Map))
          .toList(),
    );

Map<String, dynamic> _$FloatingActionButtonPropertiesToJson(
    FloatingActionButtonProperties instance) {
  final val = <String, dynamic>{
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('shape', instance.shape, _$CShapeBorderEnumMap[instance.shape]!,
      CShapeBorder.circle);
  writeNotNull('cornerRadius', instance.cornerRadius,
      instance.cornerRadius.toJson(), CornerRadius.zero);
  writeNotNull('borderWidth', instance.borderWidth, instance.borderWidth, null);
  writeNotNull('borderColor', instance.borderColor,
      instance.borderColor?.toJson(), null);
  writeNotNull('backgroundColor', instance.backgroundColor,
      instance.backgroundColor.toJson(), ColorRGBA.black);
  writeNotNull('foregroundColor', instance.foregroundColor,
      instance.foregroundColor.toJson(), ColorRGBA.white);
  writeNotNull('elevation', instance.elevation, instance.elevation, 0);
  writeNotNull(
      'focusElevation', instance.focusElevation, instance.focusElevation, 0);
  writeNotNull(
      'hoverElevation', instance.hoverElevation, instance.hoverElevation, 0);
  writeNotNull('highlightElevation', instance.highlightElevation,
      instance.highlightElevation, 0);
  writeNotNull(
      'type',
      instance.type,
      _$FloatingActionButtonTypeEnumMap[instance.type]!,
      FloatingActionButtonType.regular);
  writeNotNull('location', instance.location,
      _$FABLocationEnumMap[instance.location]!, FABLocation.endFloat);
  writeNotNull('icon', instance.icon, instance.icon.toJson(),
      const MultiSourceIconModel());
  writeNotNull('label', instance.label, instance.label, '');
  val['labelStyle'] = instance.labelStyle.toJson();
  writeNotNull(
      'focusColor', instance.focusColor, instance.focusColor?.toJson(), null);
  writeNotNull(
      'hoverColor', instance.hoverColor, instance.hoverColor?.toJson(), null);
  writeNotNull('splashColor', instance.splashColor,
      instance.splashColor?.toJson(), null);
  writeNotNull('extendedIconLabelSpacing', instance.extendedIconLabelSpacing,
      instance.extendedIconLabelSpacing, 0);
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
