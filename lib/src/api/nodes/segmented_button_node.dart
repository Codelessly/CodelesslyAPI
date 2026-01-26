import 'package:json_annotation/json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'segmented_button_node.g.dart';

/// A Material 3 segmented button for single or multi-selection.
/// Refer to [SegmentedButton](https://api.flutter.dev/flutter/material/SegmentedButton-class.html)
/// for more details.
@JsonSerializable()
class SegmentedButtonNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'segmentedButton';

  @override
  final bool supportsPadding = true;

  /// Holds configurable properties of this segmented button.
  @override
  covariant SegmentedButtonProperties properties;

  /// Strictly used for previews. e.g in components panel.
  SegmentedButtonNode.empty()
      : properties = SegmentedButtonProperties(),
        super(
          id: 'segmentedButton',
          name: 'Segmented Button',
          basicBoxLocal: NodeBox(0, 0, 300, 40),
        );

  /// Strictly used for previews. e.g in components panel.
  SegmentedButtonNode.fromProperties(this.properties)
      : super(
          id: 'segmentedButton',
          name: 'Segmented Button',
          basicBoxLocal: NodeBox(0, 0, 300, 40),
        );

  /// Creates a [SegmentedButtonNode] with given data.
  SegmentedButtonNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.visible,
    super.enabled,
    super.alignment,
    super.padding,
    super.margin,
    super.rotationDegrees,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.aspectRatioLock,
    super.edgePins,
    super.parentID,
    super.positioningMode,
    required this.properties,
    super.variables,
    super.multipleVariables,
  });

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'properties': ObjectFieldAccess<SegmentedButtonProperties>(
          'Properties',
          'Properties of a segmented button',
          () => properties,
          (value) => properties = value,
        ),
      };

  @override
  List<TriggerType> get triggerTypes => [
        TriggerType.changed,
      ];

  @override
  late final List<ValueModel> propertyVariables = [
        ...super.propertyVariables,
        ObjectValue(name: 'selected', value: properties.selectedSegments),
      ];

  @override
  List<Object?> get props => [
        ...super.props,
        properties,
        variables,
        multipleVariables,
      ];

  /// Creates a [SegmentedButtonNode] from a JSON data.
  factory SegmentedButtonNode.fromJson(Map json) =>
      _$SegmentedButtonNodeFromJson(json);

  @override
  Map toJson() => _$SegmentedButtonNodeToJson(this);
}

/// Represents a single segment in a segmented button.
@JsonSerializable()
class ButtonSegment with SerializableMixin {
  /// Unique value for this segment.
  final String value;

  /// Label text for this segment.
  final String label;

  /// Icon for this segment.
  final MultiSourceIconModel? icon;

  /// Tooltip for this segment.
  final String? tooltip;

  /// Whether this segment is enabled.
  final bool enabled;

  /// Creates a [ButtonSegment] with given data.
  const ButtonSegment({
    required this.value,
    this.label = '',
    this.icon,
    this.tooltip,
    this.enabled = true,
  });

  /// Duplicates this [ButtonSegment] instance with given data overrides.
  ButtonSegment copyWith({
    String? value,
    String? label,
    MultiSourceIconModel? icon,
    String? tooltip,
    bool? enabled,
  }) {
    return ButtonSegment(
      value: value ?? this.value,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      tooltip: tooltip ?? this.tooltip,
      enabled: enabled ?? this.enabled,
    );
  }

  /// Creates a [ButtonSegment] from a JSON data.
  factory ButtonSegment.fromJson(Map json) => _$ButtonSegmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ButtonSegmentToJson(this);

  @override
  List<Object?> get props => [
        value,
        label,
        icon,
        tooltip,
        enabled,
      ];
}

/// Holds configurable properties of a [SegmentedButtonNode].
@JsonSerializable()
class SegmentedButtonProperties extends CustomProperties with FieldsHolder {
  /// List of segments in this button.
  late List<ButtonSegment> segments;

  /// List of selected segment values.
  late List<String> selectedSegments;

  /// Whether multiple segments can be selected.
  late bool multiSelectionEnabled;

  /// Whether the button requires at least one selection.
  late bool emptySelectionAllowed;

  /// Style for segment borders.
  late ColorRGBA? borderColor;

  /// Border width.
  late double borderWidth;

  /// Selected segment background color.
  late ColorRGBA? selectedColor;

  /// Unselected segment background color.
  late ColorRGBA? unselectedColor;

  /// Corner radius.
  late CornerRadius cornerRadius;

  /// Creates a [SegmentedButtonProperties] with given data.
  SegmentedButtonProperties({
    List<ButtonSegment>? segments,
    this.selectedSegments = const [],
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.borderColor,
    this.borderWidth = 1,
    this.selectedColor,
    this.unselectedColor,
    CornerRadius? cornerRadius,
  })  : segments = segments ??
            [
              const ButtonSegment(value: 'option1', label: 'Option 1'),
              const ButtonSegment(value: 'option2', label: 'Option 2'),
              const ButtonSegment(value: 'option3', label: 'Option 3'),
            ],
        cornerRadius = cornerRadius ?? const CornerRadius.all(RadiusModel.circular(20));

  /// Duplicates this [SegmentedButtonProperties] instance with given data overrides.
  SegmentedButtonProperties copyWith({
    List<ButtonSegment>? segments,
    List<String>? selectedSegments,
    bool? multiSelectionEnabled,
    bool? emptySelectionAllowed,
    ColorRGBA? borderColor,
    double? borderWidth,
    ColorRGBA? selectedColor,
    ColorRGBA? unselectedColor,
    CornerRadius? cornerRadius,
  }) {
    return SegmentedButtonProperties(
      segments: segments ?? this.segments,
      selectedSegments: selectedSegments ?? this.selectedSegments,
      multiSelectionEnabled:
          multiSelectionEnabled ?? this.multiSelectionEnabled,
      emptySelectionAllowed:
          emptySelectionAllowed ?? this.emptySelectionAllowed,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      selectedColor: selectedColor ?? this.selectedColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      cornerRadius: cornerRadius ?? this.cornerRadius,
    );
  }

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'segments': IterableFieldAccess<ButtonSegment>(
          'Segments',
          'List of segments in the button.',
          () => segments,
          (value) => segments = value,
          (item) => item.label,
          requiresLayout: true,
        ),
        'selectedSegments': IterableFieldAccess<String>(
          'Selected Segments',
          'List of selected segment values.',
          () => selectedSegments,
          (value) => selectedSegments = value,
          (item) => item,
        ),
        'multiSelectionEnabled': BoolFieldAccess(
          'Multi Selection',
          'Whether multiple segments can be selected.',
          () => multiSelectionEnabled,
          (bool? value) {
            if (value != null) multiSelectionEnabled = value;
          },
        ),
        'emptySelectionAllowed': BoolFieldAccess(
          'Allow Empty Selection',
          'Whether empty selection is allowed.',
          () => emptySelectionAllowed,
          (bool? value) {
            if (value != null) emptySelectionAllowed = value;
          },
        ),
        'borderColor': ColorFieldAccess<ColorRGBA?>(
          'Border Color',
          'Color of segment borders.',
          () => borderColor,
          (ColorRGBA? value) => borderColor = value,
        ),
        'borderWidth': NumFieldAccess<double>(
          'Border Width',
          'Width of segment borders.',
          () => borderWidth,
          (double value) => borderWidth = value,
        ),
        'selectedColor': ColorFieldAccess<ColorRGBA?>(
          'Selected Color',
          'Background color of selected segments.',
          () => selectedColor,
          (ColorRGBA? value) => selectedColor = value,
        ),
        'unselectedColor': ColorFieldAccess<ColorRGBA?>(
          'Unselected Color',
          'Background color of unselected segments.',
          () => unselectedColor,
          (ColorRGBA? value) => unselectedColor = value,
        ),
        'cornerRadius': RadiusFieldAccess(
          'Corner Radius',
          'Corner radius of the button.',
          () => cornerRadius,
          (CornerRadius? value) {
            if (value != null) cornerRadius = value;
          },
        ),
      };

  /// Creates a [SegmentedButtonProperties] from a JSON data.
  factory SegmentedButtonProperties.fromJson(Map json) =>
      _$SegmentedButtonPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SegmentedButtonPropertiesToJson(this);

  @override
  List<Object?> get props => [
        segments,
        selectedSegments,
        multiSelectionEnabled,
        emptySelectionAllowed,
        borderColor,
        borderWidth,
        selectedColor,
        unselectedColor,
        cornerRadius,
      ];
}
