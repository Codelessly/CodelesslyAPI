// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slider_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SliderNode _$SliderNodeFromJson(Map json) => SliderNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
      value: (json['value'] as num).toDouble(),
      visible: json['visible'] as bool? ?? true,
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
      properties: SliderProperties.fromJson(json['properties'] as Map),
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

Map<String, dynamic> _$SliderNodeToJson(SliderNode instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('reactions', instance.reactions,
      instance.reactions.map((e) => e.toJson()).toList(), const []);
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
  writeNotNull('alignment', instance.alignment, instance.alignment.toJson(),
      AlignmentModel.none);
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
  val['type'] = instance.type;
  val['value'] = instance.value;
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

SliderProperties _$SliderPropertiesFromJson(Map json) => SliderProperties(
      activeTrackColor: json['activeTrackColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['activeTrackColor']),
      inactiveTrackColor: json['inactiveTrackColor'] == null
          ? kSliderDefaultInactiveTrackColor
          : ColorRGBA.fromJson(json['inactiveTrackColor']),
      thumbColor: json['thumbColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['thumbColor']),
      overlayColor: json['overlayColor'] == null
          ? const ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.38)
          : ColorRGBA.fromJson(json['overlayColor']),
      autofocus: json['autofocus'] as bool? ?? false,
      divisions: json['divisions'] as int?,
      min: (json['min'] as num?)?.toDouble() ?? 0,
      max: (json['max'] as num?)?.toDouble() ?? 100,
      trackHeight: (json['trackHeight'] as num?)?.toDouble() ??
          kSliderDefaultTrackHeight,
      label: json['label'] as String? ?? kSliderDefaultLabel,
      isDiscrete: json['isDiscrete'] as bool? ?? false,
      showLabel: json['showLabel'] as bool? ?? false,
      activeTickMarkColor: json['activeTickMarkColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['activeTickMarkColor']),
      inactiveTickMarkColor: json['inactiveTickMarkColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['inactiveTickMarkColor']),
      allowFractionalPoints: json['allowFractionalPoints'] as bool? ?? false,
      valueIndicatorColor: json['valueIndicatorColor'] == null
          ? ColorRGBA.grey
          : ColorRGBA.fromJson(json['valueIndicatorColor']),
      valueIndicatorTextColor: json['valueIndicatorTextColor'] == null
          ? ColorRGBA.white
          : ColorRGBA.fromJson(json['valueIndicatorTextColor']),
      valueIndicatorFontSize:
          (json['valueIndicatorFontSize'] as num?)?.toDouble() ?? 14,
      thumbRadius: (json['thumbRadius'] as num?)?.toDouble() ??
          kSliderDefaultThumbRadius,
      showThumb: json['showThumb'] as bool? ?? true,
      trackShape: $enumDecodeNullable(
              _$SliderTrackShapeEnumEnumMap, json['trackShape']) ??
          SliderTrackShapeEnum.roundedRectangle,
      tickMarkRadius: (json['tickMarkRadius'] as num?)?.toDouble() ??
          kSliderDefaultTickMarkRadius,
      valueIndicatorShape: $enumDecodeNullable(
              _$SliderValueIndicatorShapeEnumMap,
              json['valueIndicatorShape']) ??
          SliderValueIndicatorShape.rectangle,
      overlayRadius: (json['overlayRadius'] as num?)?.toDouble() ??
          kSliderDefaultOverlayRadius,
      deriveOverlayColorFromThumb:
          json['deriveOverlayColorFromThumb'] as bool? ?? true,
    );

Map<String, dynamic> _$SliderPropertiesToJson(SliderProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('activeTrackColor', instance.activeTrackColor,
      instance.activeTrackColor.toJson(), ColorRGBA.black);
  writeNotNull('inactiveTrackColor', instance.inactiveTrackColor,
      instance.inactiveTrackColor.toJson(), kSliderDefaultInactiveTrackColor);
  writeNotNull(
      'overlayColor',
      instance.overlayColor,
      instance.overlayColor.toJson(),
      const ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.38));
  writeNotNull('thumbColor', instance.thumbColor, instance.thumbColor.toJson(),
      ColorRGBA.black);
  writeNotNull('autofocus', instance.autofocus, instance.autofocus, false);
  writeNotNull('divisions', instance.divisions, instance.divisions, null);
  writeNotNull('min', instance.min, instance.min, 0);
  writeNotNull('max', instance.max, instance.max, 100);
  writeNotNull('trackHeight', instance.trackHeight, instance.trackHeight,
      kSliderDefaultTrackHeight);
  writeNotNull('label', instance.label, instance.label, kSliderDefaultLabel);
  writeNotNull('isDiscrete', instance.isDiscrete, instance.isDiscrete, false);
  writeNotNull('showLabel', instance.showLabel, instance.showLabel, false);
  writeNotNull('activeTickMarkColor', instance.activeTickMarkColor,
      instance.activeTickMarkColor.toJson(), ColorRGBA.grey);
  writeNotNull('inactiveTickMarkColor', instance.inactiveTickMarkColor,
      instance.inactiveTickMarkColor.toJson(), ColorRGBA.grey);
  writeNotNull('valueIndicatorColor', instance.valueIndicatorColor,
      instance.valueIndicatorColor.toJson(), ColorRGBA.grey);
  writeNotNull('valueIndicatorTextColor', instance.valueIndicatorTextColor,
      instance.valueIndicatorTextColor.toJson(), ColorRGBA.white);
  writeNotNull('valueIndicatorFontSize', instance.valueIndicatorFontSize,
      instance.valueIndicatorFontSize, 14);
  writeNotNull('allowFractionalPoints', instance.allowFractionalPoints,
      instance.allowFractionalPoints, false);
  writeNotNull('thumbRadius', instance.thumbRadius, instance.thumbRadius,
      kSliderDefaultThumbRadius);
  writeNotNull('showThumb', instance.showThumb, instance.showThumb, true);
  writeNotNull(
      'trackShape',
      instance.trackShape,
      _$SliderTrackShapeEnumEnumMap[instance.trackShape]!,
      SliderTrackShapeEnum.roundedRectangle);
  writeNotNull('tickMarkRadius', instance.tickMarkRadius,
      instance.tickMarkRadius, kSliderDefaultTickMarkRadius);
  writeNotNull(
      'valueIndicatorShape',
      instance.valueIndicatorShape,
      _$SliderValueIndicatorShapeEnumMap[instance.valueIndicatorShape]!,
      SliderValueIndicatorShape.rectangle);
  writeNotNull('overlayRadius', instance.overlayRadius, instance.overlayRadius,
      kSliderDefaultOverlayRadius);
  writeNotNull(
      'deriveOverlayColorFromThumb',
      instance.deriveOverlayColorFromThumb,
      instance.deriveOverlayColorFromThumb,
      true);
  return val;
}

const _$SliderTrackShapeEnumEnumMap = {
  SliderTrackShapeEnum.rectangle: 'rectangle',
  SliderTrackShapeEnum.roundedRectangle: 'roundedRectangle',
};

const _$SliderValueIndicatorShapeEnumMap = {
  SliderValueIndicatorShape.paddle: 'paddle',
  SliderValueIndicatorShape.rectangle: 'rectangle',
};
