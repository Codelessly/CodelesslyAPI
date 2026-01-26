// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segmented_button_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SegmentedButtonNode _$SegmentedButtonNodeFromJson(Map json) =>
    SegmentedButtonNode(
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
        rotationDegrees: json['rotation'] == null
            ? 0
            : castRotation(json['rotation']),
        reactions:
            (json['reactions'] as List<dynamic>?)
                ?.map((e) => Reaction.fromJson(e as Map))
                .toList() ??
            const [],
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
        aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
        edgePins: json['edgePins'] == null
            ? EdgePinsModel.standard
            : EdgePinsModel.fromJson(
                Map<String, dynamic>.from(json['edgePins'] as Map),
              ),
        positioningMode:
            $enumDecodeNullable(
              _$PositioningModeEnumMap,
              json['positioningMode'],
            ) ??
            PositioningMode.align,
        properties: SegmentedButtonProperties.fromJson(
          json['properties'] as Map,
        ),
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
      ..type = json['type'] as String;

Map<String, dynamic> _$SegmentedButtonNodeToJson(
  SegmentedButtonNode instance,
) => <String, dynamic>{
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
  'reactions': instance.reactions.map((e) => e.toJson()).toList(),
  'basicBoxLocal': instance.basicBoxLocal.toJson(),
  'margin': instance.margin.toJson(),
  'padding': instance.padding.toJson(),
  'rotation': instance.rotationDegrees,
  'widthFactor': ?instance.widthFactor,
  'heightFactor': ?instance.heightFactor,
  'enabled': instance.enabled,
  'type': instance.type,
  'properties': instance.properties.toJson(),
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

const _$ComponentMarkerTypeEnumMap = {
  ComponentMarkerType.component: 'component',
  ComponentMarkerType.instance: 'instance',
};

ButtonSegment _$ButtonSegmentFromJson(Map json) => ButtonSegment(
  value: json['value'] as String,
  label: json['label'] as String? ?? '',
  icon: json['icon'] == null
      ? null
      : MultiSourceIconModel.fromJson(json['icon'] as Map),
  tooltip: json['tooltip'] as String?,
  enabled: json['enabled'] as bool? ?? true,
);

Map<String, dynamic> _$ButtonSegmentToJson(ButtonSegment instance) =>
    <String, dynamic>{
      'value': instance.value,
      'label': instance.label,
      'icon': ?instance.icon?.toJson(),
      'tooltip': ?instance.tooltip,
      'enabled': instance.enabled,
    };

SegmentedButtonProperties _$SegmentedButtonPropertiesFromJson(Map json) =>
    SegmentedButtonProperties(
      segments: (json['segments'] as List<dynamic>?)
          ?.map((e) => ButtonSegment.fromJson(e as Map))
          .toList(),
      selectedSegments:
          (json['selectedSegments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      multiSelectionEnabled: json['multiSelectionEnabled'] as bool? ?? false,
      emptySelectionAllowed: json['emptySelectionAllowed'] as bool? ?? false,
      borderColor: json['borderColor'] == null
          ? null
          : ColorRGBA.fromJson(json['borderColor']),
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1,
      selectedColor: json['selectedColor'] == null
          ? null
          : ColorRGBA.fromJson(json['selectedColor']),
      unselectedColor: json['unselectedColor'] == null
          ? null
          : ColorRGBA.fromJson(json['unselectedColor']),
      cornerRadius: json['cornerRadius'] == null
          ? null
          : CornerRadius.fromJson(json['cornerRadius']),
    );

Map<String, dynamic> _$SegmentedButtonPropertiesToJson(
  SegmentedButtonProperties instance,
) => <String, dynamic>{
  'segments': instance.segments.map((e) => e.toJson()).toList(),
  'selectedSegments': instance.selectedSegments,
  'multiSelectionEnabled': instance.multiSelectionEnabled,
  'emptySelectionAllowed': instance.emptySelectionAllowed,
  'borderColor': ?instance.borderColor?.toJson(),
  'borderWidth': instance.borderWidth,
  'selectedColor': ?instance.selectedColor?.toJson(),
  'unselectedColor': ?instance.unselectedColor?.toJson(),
  'cornerRadius': instance.cornerRadius.toJson(),
};
