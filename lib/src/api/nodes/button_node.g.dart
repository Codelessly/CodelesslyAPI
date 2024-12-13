// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'button_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ButtonNode _$ButtonNodeFromJson(Map json) => ButtonNode(
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
      ..componentId = json['componentId'] as String?
      ..markerType =
          $enumDecodeNullable(_$ComponentMarkerTypeEnumMap, json['markerType'])
      ..componentVersion = (json['componentVersion'] as num).toInt()
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$ButtonNodeToJson(ButtonNode instance) {
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

ButtonProperties _$ButtonPropertiesFromJson(Map json) => ButtonProperties(
      buttonType:
          $enumDecodeNullable(_$ButtonTypeEnumEnumMap, json['buttonType']) ??
              ButtonTypeEnum.elevated,
      buttonColor: json['buttonColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['buttonColor']),
      shadowColor: json['shadowColor'] == null
          ? const ColorRGBA(r: 0.65, g: 0.65, b: 0.65, a: 1)
          : ColorRGBA.fromJson(json['shadowColor']),
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
          : CornerRadius.fromJson(json['cornerRadius']),
      borderColor: json['borderColor'] == null
          ? null
          : ColorRGBA.fromJson(json['borderColor']),
      shape: $enumDecodeNullable(_$CShapeBorderEnumMap, json['shape']) ??
          CShapeBorder.roundedRectangle,
      borderWidth: (json['borderWidth'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ButtonPropertiesToJson(ButtonProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('shape', instance.shape, _$CShapeBorderEnumMap[instance.shape]!,
      CShapeBorder.roundedRectangle);
  writeNotNull(
      'cornerRadius',
      instance.cornerRadius,
      instance.cornerRadius.toJson(),
      const CornerRadius.all(RadiusModel.circular(4)));
  writeNotNull('borderWidth', instance.borderWidth, instance.borderWidth, null);
  writeNotNull('borderColor', instance.borderColor,
      instance.borderColor?.toJson(), null);
  writeNotNull('buttonType', instance.buttonType,
      _$ButtonTypeEnumEnumMap[instance.buttonType]!, ButtonTypeEnum.elevated);
  writeNotNull('buttonColor', instance.buttonColor,
      instance.buttonColor.toJson(), ColorRGBA.black);
  writeNotNull(
      'shadowColor',
      instance.shadowColor,
      instance.shadowColor.toJson(),
      const ColorRGBA(r: 0.65, g: 0.65, b: 0.65, a: 1));
  writeNotNull('elevation', instance.elevation, instance.elevation, 0);
  writeNotNull('enabled', instance.enabled, instance.enabled, true);
  writeNotNull('label', instance.label, instance.label, '');
  writeNotNull(
      'labelAlignment',
      instance.labelAlignment,
      _$TextAlignHorizontalEnumEnumMap[instance.labelAlignment]!,
      TextAlignHorizontalEnum.center);
  val['labelStyle'] = instance.labelStyle.toJson();
  writeNotNull('placement', instance.placement,
      _$IconPlacementEnumEnumMap[instance.placement]!, IconPlacementEnum.start);
  writeNotNull('gap', instance.gap, instance.gap, 8);
  writeNotNull('icon', instance.icon, instance.icon.toJson(),
      const MultiSourceIconModel(size: 20, color: null));
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
