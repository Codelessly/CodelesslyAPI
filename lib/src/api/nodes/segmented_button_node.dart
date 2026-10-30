import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'segmented_button_node.g.dart';

/// Default width of a segmented button node.
const double kSegmentedButtonDefaultWidth = 300;

/// Default height of a segmented button node, the Material 3 height.
const double kSegmentedButtonDefaultHeight = 40;

/// A Material 3 segmented button for single or multiple selection among a
/// few options.
/// Refer to [SegmentedButton](https://api.flutter.dev/flutter/material/SegmentedButton-class.html)
/// in Flutter for more details.
@FlutterNode('SegmentedButton', family: 'material', nodeType: 'segmentedButton')
@JsonSerializable()
class SegmentedButtonNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'segmentedButton';

  @override
  bool get supportsPadding => true;

  /// Holds configurable properties of this segmented button.
  @override
  covariant SegmentedButtonProperties properties;

  /// Strictly used for previews. e.g in components panel.
  SegmentedButtonNode.empty()
    : properties = SegmentedButtonProperties(selected: const ['option1']),
      super(
        id: 'segmentedButton',
        name: 'Segmented Button',
        basicBoxLocal: NodeBox(
          0,
          0,
          kSegmentedButtonDefaultWidth,
          kSegmentedButtonDefaultHeight,
        ),
      );

  /// Strictly used for previews. e.g in components panel.
  SegmentedButtonNode.fromProperties(this.properties)
    : super(
        id: 'segmentedButton',
        name: 'Segmented Button',
        basicBoxLocal: NodeBox(
          0,
          0,
          kSegmentedButtonDefaultWidth,
          kSegmentedButtonDefaultHeight,
        ),
      );

  /// Creates a [SegmentedButtonNode] with the given data.
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
    // Custom properties.
    required this.properties,
    super.variables,
    super.multipleVariables,
  });

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<SegmentedButtonProperties>(
      'Properties',
      'Properties of the segmented button.',
      () => properties,
      (value) => properties = value,
    ),
  };

  /// [TriggerType.changed] fires with the list of selected segment values
  /// whenever the selection changes.
  @override
  List<TriggerType> get triggerTypes => [TriggerType.changed];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    ObjectValue(name: 'selected', value: properties.selected),
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
  Map toJson() => _$SegmentedButtonNodeOmitDefaults(
    this,
    _$SegmentedButtonNodeToJson(this),
  );
}

/// A single segment of a [SegmentedButtonNode], like Flutter's
/// [ButtonSegment](https://api.flutter.dev/flutter/material/ButtonSegment-class.html).
@JsonSerializable()
class ButtonSegmentModel with Equatable, SerializableMixin {
  /// Unique value of this segment, used in
  /// [SegmentedButtonProperties.selected].
  final String value;

  /// Label text of this segment.
  final String label;

  /// Icon of this segment.
  final MultiSourceIconModel? icon;

  /// Tooltip of this segment.
  final String? tooltip;

  /// Whether this segment can be selected.
  final bool enabled;

  /// Creates a [ButtonSegmentModel] with the given data.
  const ButtonSegmentModel({
    required this.value,
    this.label = '',
    this.icon,
    this.tooltip,
    this.enabled = true,
  });

  /// Duplicates this [ButtonSegmentModel] with the given data overrides.
  ButtonSegmentModel copyWith({
    String? value,
    String? label,
    MultiSourceIconModel? icon,
    String? tooltip,
    bool? enabled,
  }) {
    return ButtonSegmentModel(
      value: value ?? this.value,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      tooltip: tooltip ?? this.tooltip,
      enabled: enabled ?? this.enabled,
    );
  }

  /// Creates a [ButtonSegmentModel] from a JSON data.
  factory ButtonSegmentModel.fromJson(Map json) =>
      _$ButtonSegmentModelFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ButtonSegmentModelOmitDefaults(this, _$ButtonSegmentModelToJson(this));

  @override
  List<Object?> get props => [value, label, icon, tooltip, enabled];
}

/// The default segments of a new segmented button.
const List<ButtonSegmentModel> kDefaultButtonSegments = [
  ButtonSegmentModel(value: 'option1', label: 'Option 1'),
  ButtonSegmentModel(value: 'option2', label: 'Option 2'),
  ButtonSegmentModel(value: 'option3', label: 'Option 3'),
];

/// Holds configurable properties of a [SegmentedButtonNode].
@JsonSerializable()
class SegmentedButtonProperties extends CustomProperties with FieldsHolder {
  /// Segments of the button.
  List<ButtonSegmentModel> segments;

  /// Values of the selected segments.
  @JsonKey(name: 'selectedSegments')
  List<String> selected;

  /// Whether more than one segment can be selected.
  @FlutterProp(
    'multiSelectionEnabled',
    type: 'boolean',
    group: 'Selection',
    control: 'switch',
    field: 'properties.multiSelectionEnabled',
  )
  bool multiSelectionEnabled;

  /// Whether no segment may be selected.
  @FlutterProp(
    'emptySelectionAllowed',
    type: 'boolean',
    group: 'Selection',
    control: 'switch',
    field: 'properties.emptySelectionAllowed',
  )
  bool emptySelectionAllowed;

  /// Whether selected segments show [selectedIcon].
  @FlutterProp(
    'showSelectedIcon',
    type: 'boolean',
    group: 'Appearance',
    control: 'switch',
    field: 'properties.showSelectedIcon',
  )
  bool showSelectedIcon;

  /// Icon shown on selected segments. Defaults to Flutter's check icon.
  MultiSourceIconModel? selectedIcon;

  /// Whether the segments are laid out in a row or a column.
  AxisC direction;

  /// Border color. Defaults to the theme's `colorScheme.outline`.
  ColorRGBA? borderColor;

  /// Border width.
  double borderWidth;

  /// Background color of selected segments. Defaults to the theme's
  /// `colorScheme.secondaryContainer`.
  @JsonKey(name: 'selectedColor')
  ColorRGBA? selectedBackgroundColor;

  /// Background color of unselected segments. Transparent by default.
  @JsonKey(name: 'unselectedColor')
  ColorRGBA? backgroundColor;

  /// Label and icon color of selected segments.
  ColorRGBA? selectedForegroundColor;

  /// Label and icon color of unselected segments.
  ColorRGBA? foregroundColor;

  /// Corner radius of the outer corners. Material 3 segmented buttons are
  /// stadium-shaped, which a radius of half the default height matches.
  CornerRadius cornerRadius;

  /// Creates a [SegmentedButtonProperties] with the given data.
  SegmentedButtonProperties({
    this.segments = kDefaultButtonSegments,
    this.selected = const [],
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showSelectedIcon = true,
    this.selectedIcon,
    this.direction = AxisC.horizontal,
    this.borderColor,
    this.borderWidth = 1,
    this.selectedBackgroundColor,
    this.backgroundColor,
    this.selectedForegroundColor,
    this.foregroundColor,
    this.cornerRadius = const CornerRadius.all(
      RadiusModel.circular(kSegmentedButtonDefaultHeight / 2),
    ),
  });

  /// Duplicates this [SegmentedButtonProperties] with the given data
  /// overrides.
  SegmentedButtonProperties copyWith({
    List<ButtonSegmentModel>? segments,
    List<String>? selected,
    bool? multiSelectionEnabled,
    bool? emptySelectionAllowed,
    bool? showSelectedIcon,
    MultiSourceIconModel? selectedIcon,
    AxisC? direction,
    ColorRGBA? borderColor,
    double? borderWidth,
    ColorRGBA? selectedBackgroundColor,
    ColorRGBA? backgroundColor,
    ColorRGBA? selectedForegroundColor,
    ColorRGBA? foregroundColor,
    CornerRadius? cornerRadius,
  }) {
    return SegmentedButtonProperties(
      segments: segments ?? this.segments,
      selected: selected ?? this.selected,
      multiSelectionEnabled:
          multiSelectionEnabled ?? this.multiSelectionEnabled,
      emptySelectionAllowed:
          emptySelectionAllowed ?? this.emptySelectionAllowed,
      showSelectedIcon: showSelectedIcon ?? this.showSelectedIcon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      direction: direction ?? this.direction,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedForegroundColor:
          selectedForegroundColor ?? this.selectedForegroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      cornerRadius: cornerRadius ?? this.cornerRadius,
    );
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'segments': IterableFieldAccess<ButtonSegmentModel>(
      'Segments',
      'Segments of the button.',
      () => segments,
      (value) => segments = value,
      (item) => item.label.isEmpty ? item.value : item.label,
      requiresLayout: true,
    ),
    'selectedSegments': IterableFieldAccess<String>(
      'Selected Segments',
      'Values of the selected segments.',
      () => selected,
      (value) => selected = value,
      (item) => item,
    ),
    'multiSelectionEnabled': BoolFieldAccess(
      'Multi Selection',
      'Whether more than one segment can be selected.',
      () => multiSelectionEnabled,
      (value) => multiSelectionEnabled = value,
    ),
    'emptySelectionAllowed': BoolFieldAccess(
      'Allow Empty Selection',
      'Whether no segment may be selected.',
      () => emptySelectionAllowed,
      (value) => emptySelectionAllowed = value,
    ),
    'showSelectedIcon': BoolFieldAccess(
      'Show Selected Icon',
      'Whether selected segments show the selected icon.',
      () => showSelectedIcon,
      (value) => showSelectedIcon = value,
      requiresLayout: true,
    ),
    'selectedIcon': IconFieldAccess<MultiSourceIconModel?>(
      'Selected Icon',
      'Icon shown on selected segments.',
      () => selectedIcon,
      (value) => selectedIcon = value,
      requiresLayout: true,
      required: false,
    ),
    'direction': EnumFieldAccess<AxisC>(
      'Direction',
      'Whether the segments are laid out in a row or a column.',
      () => direction,
      (value) => direction = value,
      defaultValue: () => AxisC.horizontal,
      options: () => AxisC.values,
      requiresLayout: true,
    ),
    'borderColor': ColorFieldAccess<ColorRGBA?>(
      'Border Color',
      'Color of the segment borders.',
      () => borderColor,
      (value) => borderColor = value,
    ),
    'borderWidth': NumFieldAccess<double>(
      'Border Width',
      'Width of the segment borders.',
      () => borderWidth,
      (value) => borderWidth = value,
    ),
    'selectedColor': ColorFieldAccess<ColorRGBA?>(
      'Selected Color',
      'Background color of selected segments.',
      () => selectedBackgroundColor,
      (value) => selectedBackgroundColor = value,
    ),
    'unselectedColor': ColorFieldAccess<ColorRGBA?>(
      'Unselected Color',
      'Background color of unselected segments.',
      () => backgroundColor,
      (value) => backgroundColor = value,
    ),
    'selectedForegroundColor': ColorFieldAccess<ColorRGBA?>(
      'Selected Foreground Color',
      'Label and icon color of selected segments.',
      () => selectedForegroundColor,
      (value) => selectedForegroundColor = value,
    ),
    'foregroundColor': ColorFieldAccess<ColorRGBA?>(
      'Foreground Color',
      'Label and icon color of unselected segments.',
      () => foregroundColor,
      (value) => foregroundColor = value,
    ),
    'cornerRadius': RadiusFieldAccess(
      'Corner Radius',
      'Corner radius of the outer corners.',
      () => cornerRadius,
      (value) => cornerRadius = value,
    ),
  };

  @override
  List<Object?> get props => [
    segments,
    selected,
    multiSelectionEnabled,
    emptySelectionAllowed,
    showSelectedIcon,
    selectedIcon,
    direction,
    borderColor,
    borderWidth,
    selectedBackgroundColor,
    backgroundColor,
    selectedForegroundColor,
    foregroundColor,
    cornerRadius,
  ];

  /// Creates a [SegmentedButtonProperties] from a JSON data.
  factory SegmentedButtonProperties.fromJson(Map json) =>
      _$SegmentedButtonPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SegmentedButtonPropertiesOmitDefaults(
    this,
    _$SegmentedButtonPropertiesToJson(this),
  );
}
