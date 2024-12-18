import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'checkbox_node.g.dart';

/// The default radius of a circular material ink response in logical pixels.
/// This is copied from flutter/material/constants.dart to avoid dependency.
const double kRadialReactionRadius = 20.0;

/// Default size of the checkbox.
const double kCheckboxDefaultSize = 40;

/// A checkbox is a widget that permits the user to make a binary
/// choice, i.e. a choice between one of two possible mutually exclusive
/// options. For example, the user may have to answer 'yes' or 'no' on a
/// simple yes/no question. Checkboxes are shown as ☐ when unchecked, or
/// ☑ or ☒ when checked.
/// This is a material checkbox that has tristate support. So when [value] is
/// null, it shows a dash instead of a checkmark.
/// Refer to [Checkbox](https://api.flutter.dev/flutter/material/Checkbox-class.html)
/// in Flutter for more details.
@JsonSerializable()
class CheckboxNode extends SceneNode with CustomPropertiesMixin, ScalableMixin {
  @override
  final String type = 'checkbox';

  @override
  double get defaultWidth => kCheckboxDefaultSize;

  @override
  double get defaultHeight => kCheckboxDefaultSize;

  /// Holds configurable properties of the checkbox.
  @override
  covariant CheckboxProperties properties;

  /// Value of the checkbox.
  bool? value;

  /// Strictly used for previews. e.g in components panel.
  CheckboxNode.empty()
      : properties = CheckboxProperties(),
        super(
          id: 'checkBox',
          name: 'Checkbox',
          basicBoxLocal:
              NodeBox(0, 0, kCheckboxDefaultSize, kCheckboxDefaultSize),
        );

  /// Strictly used for previews. e.g in components panel.
  CheckboxNode.fromProperties(this.properties)
      : super(
          id: 'checkBox',
          name: 'Checkbox',
          basicBoxLocal:
              NodeBox(0, 0, kCheckboxDefaultSize, kCheckboxDefaultSize),
        );

  /// Creates a [CheckboxNode] with the given data.
  CheckboxNode({
    bool? value,
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.visible,
    super.enabled,
    super.rotationDegrees,
    super.alignment,
    super.margin,
    super.padding,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.positioningMode,
    super.parentID,
    super.reactions,
    // [BlendMixin] properties.
    double opacity = 1,
    bool isMask = false,
    List<Effect> effects = const [],
    BlendModeC blendMode = BlendModeC.srcOver,
    // Custom properties.
    required this.properties,
    super.variables,
  }) {
    this.value = properties.tristate ? value : (value ?? false);
    fields['properties'] = ObjectFieldAccess<CheckboxProperties>(
      () => 'Properties',
      () => 'Holds configurable properties of the checkbox.',
      () => properties,
      (value) => properties = value,
    );
  }

  @override
  List<TriggerType> get triggerTypes => [TriggerType.changed];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    BoolValue(name: 'value', value: value, nullable: true),
  ];

  /// Creates a [CheckboxNode] from a JSON object.
  factory CheckboxNode.fromJson(Map json) => _$CheckboxNodeFromJson(json);

  @override
  Map toJson() => _$CheckboxNodeToJson(this)..['value'] = value;

  @override
  double get scale => basicBoxLocal.width / kCheckboxDefaultSize;
}

/// Holds configurable properties of the checkbox.
@JsonSerializable()
class CheckboxProperties extends CustomProperties with FieldsHolder {
  /// Color of the tick mark.
  late ColorRGBA checkColor;

  /// Color of the tick/dash mark when active.
  late ColorRGBA activeColor;

  /// Border color of the checkbox when inactive.
  late ColorRGBA borderColor;

  /// Hover overlay color of the checkbox.
  late ColorRGBA hoverColor;

  /// Overlay color of the checkbox when focused.
  late ColorRGBA focusColor;

  /// Overlay radius.
  late double splashRadius;

  /// Whether to automatically focus the checkbox.
  late bool autofocus;

  /// Whether the checkbox is tristate.
  late bool tristate;

  /// Border width for the checkbox.
  late double borderWidth;

  /// Radius of the corners of the checkbox.
  late CornerRadius cornerRadius;

  /// Whether the checkbox is compact.
  late bool compact;

  /// Creates a [CheckboxProperties] with the given data.
  CheckboxProperties({
    this.checkColor = ColorRGBA.white,
    this.activeColor = ColorRGBA.black,
    this.hoverColor = ColorRGBA.grey10,
    this.focusColor = ColorRGBA.grey10,
    this.tristate = false,
    this.borderColor = ColorRGBA.grey,
    this.borderWidth = 1.5,
    this.cornerRadius = const CornerRadius.all(RadiusModel.circular(3)),
    this.splashRadius = kRadialReactionRadius,
    this.autofocus = false,
    this.compact = false,
  });

  /// Duplicates this [CheckboxProperties] instance with the given data
  /// overrides.
  CheckboxProperties copyWith({
    ColorRGBA? checkColor,
    ColorRGBA? activeColor,
    ColorRGBA? hoverColor,
    ColorRGBA? focusColor,
    bool? tristate,
    ColorRGBA? borderColor,
    double? borderWidth,
    CornerRadius? cornerRadius,
    double? splashRadius,
    bool? autofocus,
    bool? compact,
  }) {
    return CheckboxProperties(
      checkColor: checkColor ?? this.checkColor,
      activeColor: activeColor ?? this.activeColor,
      tristate: tristate ?? this.tristate,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      hoverColor: hoverColor ?? this.hoverColor,
      focusColor: focusColor ?? this.focusColor,
      splashRadius: splashRadius ?? this.splashRadius,
      autofocus: autofocus ?? this.autofocus,
      compact: compact ?? this.compact,
    );
  }

  @override
  late final Map<String, FieldAccess<Object?>> fields = {
    'checkColor': ColorFieldAccess<ColorRGBA>(
        () => 'Check Color', () => 'Color of the tick mark.', () => checkColor,
        (ColorRGBA? value) {
      if (value != null) checkColor = value;
    }),
    'activeColor': ColorFieldAccess<ColorRGBA>(
        () => 'Active Color',
        () => 'Color of the tick/dash mark when active.',
        () => activeColor, (ColorRGBA? value) {
      if (value != null) activeColor = value;
    }),
    'borderColor': ColorFieldAccess<ColorRGBA>(
        () => 'Border Color',
        () => 'Border color of the checkbox when inactive.',
        () => borderColor, (ColorRGBA? value) {
      if (value != null) borderColor = value;
    }),
    'hoverColor': ColorFieldAccess<ColorRGBA>(
        () => 'Hover Color',
        () => 'Hover overlay color of the checkbox.',
        () => hoverColor, (ColorRGBA? value) {
      if (value != null) hoverColor = value;
    }),
    'focusColor': ColorFieldAccess<ColorRGBA>(
        () => 'Focus Color',
        () => 'Overlay color of the checkbox when focused.',
        () => focusColor, (ColorRGBA? value) {
      if (value != null) focusColor = value;
    }),
    'splashRadius': NumFieldAccess<double>(
        () => 'Splash Radius',
        () => 'Overlay radius.',
        () => splashRadius,
        (double value) => splashRadius = value),
    'autofocus': BoolFieldAccess(
        () => 'Autofocus',
        () => 'Whether to automatically focus the checkbox.',
        () => autofocus,
        (bool value) => autofocus = value),
    'tristate': BoolFieldAccess(
        () => 'Tristate',
        () => 'Whether the checkbox is tristate.',
        () => tristate,
        (bool value) => tristate = value),
    'borderWidth': NumFieldAccess<double>(
        () => 'Border Width',
        () => 'Border width for the checkbox.',
        () => borderWidth,
        (double value) => borderWidth = value),
    'cornerRadius': RadiusFieldAccess(
        () => 'Corner Radius',
        () => 'Radius of the corners of the checkbox.',
        () => cornerRadius,
        (CornerRadius value) => cornerRadius = value),
    'compact': BoolFieldAccess(
        () => 'Compact',
        () => 'Whether the checkbox is compact.',
        () => compact,
        (bool value) => compact = value),
  };

  @override
  List<Object?> get props => [
        checkColor,
        activeColor,
        tristate,
        borderColor,
        borderWidth,
        cornerRadius,
        hoverColor,
        focusColor,
        splashRadius,
        autofocus,
        compact,
      ];

  /// Creates a [CheckboxProperties] from a JSON object.
  factory CheckboxProperties.fromJson(Map json) =>
      _$CheckboxPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CheckboxPropertiesToJson(this);
}
