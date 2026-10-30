import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import '../node_json_converter.dart';
import 'nodes.dart';

part 'signature_node.g.dart';

/// Default width of a signature pad.
const double kSignatureDefaultWidth = 320;

/// Default height of a signature pad.
const double kSignatureDefaultHeight = 140;

/// Default color of the ink of a signature pad.
const ColorRGBA kSignatureDefaultInkColor = ColorRGBA(
  r: 0x13 / 255,
  g: 0x30 / 255,
  b: 0x6B / 255,
  a: 1,
);

/// Default background color of a signature pad.
const ColorRGBA kSignatureDefaultBackgroundColor = ColorRGBA(
  r: 0xF8 / 255,
  g: 0xF8 / 255,
  b: 0xF5 / 255,
  a: 1,
);

/// Default border, sign line and placeholder color of a signature pad.
const ColorRGBA kSignatureDefaultBorderColor = ColorRGBA(
  r: 0xA9 / 255,
  g: 0xAD / 255,
  b: 0xA5 / 255,
  a: 1,
);

/// Default border color of a signature pad that is in error.
const ColorRGBA kSignatureDefaultErrorColor = ColorRGBA(
  r: 0xD3 / 255,
  g: 0x30 / 255,
  b: 0x2F / 255,
  a: 1,
);

/// Default placeholder of a signature pad.
const String kSignatureDefaultPlaceholder = 'SIGN HERE';

/// A pad the user signs on by drawing with a finger, a pen or a mouse.
///
/// Its [value] is the list of strokes drawn, each a list of `[x, y]` points
/// in the pad's coordinates. An empty list means the pad is not signed.
///
/// Bind `variables['value']` to a list variable to read the signature
/// (`${signature.isEmpty}`, `${= length(signature) > 0}`) and to clear it
/// (set the variable to `[]`). [TriggerType.changed] fires when a stroke
/// ends, with the strokes as its value.
@FlutterNode('CodelesslySignature', family: 'codelessly', nodeType: 'signature', variant: 'strokes')
@JsonSerializable()
class SignatureNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'signature';

  /// Holds configurable properties of the signature pad.
  @override
  covariant SignatureProperties properties;

  /// The strokes drawn on the pad: each stroke is a list of `[x, y]` points.
  /// Empty when the pad is not signed.
  @JsonKey(fromJson: strokesFromJson)
  @FlutterProp('value', type: 'array', group: 'State', control: 'strokes', bindable: true)
  List<List<List<double>>> value;

  /// Strictly used for previews. e.g in components panel.
  SignatureNode.empty()
    : properties = SignatureProperties(),
      value = [],
      super(
        id: 'signature',
        name: 'Signature',
        basicBoxLocal: NodeBox(
          0,
          0,
          kSignatureDefaultWidth,
          kSignatureDefaultHeight,
        ),
      );

  /// Strictly used for previews. e.g in components panel.
  SignatureNode.fromProperties(this.properties)
    : value = [],
      super(
        id: 'signature',
        name: 'Signature',
        basicBoxLocal: NodeBox(
          0,
          0,
          kSignatureDefaultWidth,
          kSignatureDefaultHeight,
        ),
      );

  /// Creates a [SignatureNode] with the given data.
  SignatureNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    List<List<List<double>>>? value,
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
  }) : value = value ?? [];

  /// Whether the pad holds no strokes.
  bool get isEmpty => value.isEmpty;

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<SignatureProperties>(
      'Properties',
      'Holds configurable properties of the signature pad.',
      () => properties,
      (value) => properties = value,
    ),
  };

  /// [TriggerType.changed] fires with the strokes when a stroke ends.
  @override
  List<TriggerType> get triggerTypes => [TriggerType.changed];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    ObjectValue(name: 'value', value: value),
    BoolValue(name: 'error', value: properties.error),
    BoolValue(name: 'enabled', value: properties.enabled),
  ];

  @override
  List<Object?> get props => [
    ...super.props,
    properties,
    value,
    variables,
    multipleVariables,
  ];

  /// Creates a [SignatureNode] from a JSON data.
  factory SignatureNode.fromJson(Map json) {
    NodeJsonConverter.validateSignatureWire(json, expectedType: 'strokes');
    return _$SignatureNodeFromJson(json);
  }

  @override
  Map toJson() => {
    ..._$SignatureNodeOmitDefaults(this, _$SignatureNodeToJson(this)),
    'type': 'signature',
    'signatureKind': 'strokes',
  };
}

/// Reads strokes from JSON: a list of strokes, each a list of `[x, y]`
/// points. Malformed points are skipped.
List<List<List<double>>> strokesFromJson(Object? json) {
  if (json is! List) return [];
  return [
    for (final stroke in json)
      if (stroke is List)
        [
          for (final point in stroke)
            if (point is List &&
                point.length >= 2 &&
                point[0] is num &&
                point[1] is num)
              [(point[0] as num).toDouble(), (point[1] as num).toDouble()],
        ],
  ];
}

/// Holds configurable properties of a [SignatureNode].
@JsonSerializable()
class SignatureProperties extends CustomProperties with FieldsHolder {
  /// Color of the ink.
  ColorRGBA inkColor;

  /// Width of the ink line.
  @FlutterProp('inkWidth', type: 'number', group: 'Appearance', control: 'number', field: 'properties.inkWidth')
  double inkWidth;

  /// Background color of the pad.
  ColorRGBA backgroundColor;

  /// Color of the border of the pad.
  ColorRGBA borderColor;

  /// Width of the border of the pad.
  double borderWidth;

  /// Color of the border when the pad is in [error].
  ColorRGBA errorBorderColor;

  /// Width of the border when the pad is in [error].
  double errorBorderWidth;

  /// Radius of the corners of the pad.
  CornerRadius cornerRadius;

  /// Text shown on the pad while it is empty. Empty shows nothing.
  String placeholder;

  /// Color of the [placeholder].
  ColorRGBA placeholderColor;

  /// Font size of the [placeholder].
  double placeholderFontSize;

  /// Whether to draw a sign line with an "×" near the bottom of the pad.
  bool showSignLine;

  /// Color of the sign line and its "×".
  ColorRGBA signLineColor;

  /// Whether the pad shows its error border. Bind `variables['error']` to
  /// show it from a validation rule.
  bool error;

  /// Whether the user can draw on the pad. A pad that is not enabled still
  /// shows its strokes. Bind `variables['enabled']` to lock it, e.g. once
  /// the form is submitted.
  bool enabled;

  /// Creates a [SignatureProperties] with the given data.
  SignatureProperties({
    this.inkColor = kSignatureDefaultInkColor,
    this.inkWidth = 2.6,
    this.backgroundColor = kSignatureDefaultBackgroundColor,
    this.borderColor = kSignatureDefaultBorderColor,
    this.borderWidth = 1.5,
    this.errorBorderColor = kSignatureDefaultErrorColor,
    this.errorBorderWidth = 2,
    this.cornerRadius = const CornerRadius.all(RadiusModel.circular(4)),
    this.placeholder = kSignatureDefaultPlaceholder,
    this.placeholderColor = kSignatureDefaultBorderColor,
    this.placeholderFontSize = 12,
    this.showSignLine = true,
    this.signLineColor = kSignatureDefaultBorderColor,
    this.error = false,
    this.enabled = true,
  });

  /// Duplicates this [SignatureProperties] with the given data overrides.
  SignatureProperties copyWith({
    ColorRGBA? inkColor,
    double? inkWidth,
    ColorRGBA? backgroundColor,
    ColorRGBA? borderColor,
    double? borderWidth,
    ColorRGBA? errorBorderColor,
    double? errorBorderWidth,
    CornerRadius? cornerRadius,
    String? placeholder,
    ColorRGBA? placeholderColor,
    double? placeholderFontSize,
    bool? showSignLine,
    ColorRGBA? signLineColor,
    bool? error,
    bool? enabled,
  }) => SignatureProperties(
    inkColor: inkColor ?? this.inkColor,
    inkWidth: inkWidth ?? this.inkWidth,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    errorBorderColor: errorBorderColor ?? this.errorBorderColor,
    errorBorderWidth: errorBorderWidth ?? this.errorBorderWidth,
    cornerRadius: cornerRadius ?? this.cornerRadius,
    placeholder: placeholder ?? this.placeholder,
    placeholderColor: placeholderColor ?? this.placeholderColor,
    placeholderFontSize: placeholderFontSize ?? this.placeholderFontSize,
    showSignLine: showSignLine ?? this.showSignLine,
    signLineColor: signLineColor ?? this.signLineColor,
    error: error ?? this.error,
    enabled: enabled ?? this.enabled,
  );

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'inkColor': ColorFieldAccess<ColorRGBA>(
      'Ink Color',
      'Color of the ink.',
      () => inkColor,
      (ColorRGBA? value) {
        if (value != null) inkColor = value;
      },
    ),
    'inkWidth': NumFieldAccess<double>(
      'Ink Width',
      'Width of the ink line.',
      () => inkWidth,
      (double value) => inkWidth = value,
    ),
    'backgroundColor': ColorFieldAccess<ColorRGBA>(
      'Background Color',
      'Background color of the pad.',
      () => backgroundColor,
      (ColorRGBA? value) {
        if (value != null) backgroundColor = value;
      },
    ),
    'borderColor': ColorFieldAccess<ColorRGBA>(
      'Border Color',
      'Color of the border of the pad.',
      () => borderColor,
      (ColorRGBA? value) {
        if (value != null) borderColor = value;
      },
    ),
    'borderWidth': NumFieldAccess<double>(
      'Border Width',
      'Width of the border of the pad.',
      () => borderWidth,
      (double value) => borderWidth = value,
    ),
    'errorBorderColor': ColorFieldAccess<ColorRGBA>(
      'Error Border Color',
      'Color of the border when the pad is in error.',
      () => errorBorderColor,
      (ColorRGBA? value) {
        if (value != null) errorBorderColor = value;
      },
    ),
    'errorBorderWidth': NumFieldAccess<double>(
      'Error Border Width',
      'Width of the border when the pad is in error.',
      () => errorBorderWidth,
      (double value) => errorBorderWidth = value,
    ),
    'cornerRadius': RadiusFieldAccess(
      'Corner Radius',
      'Radius of the corners of the pad.',
      () => cornerRadius,
      (CornerRadius value) => cornerRadius = value,
    ),
    'placeholder': StringFieldAccess(
      'Placeholder',
      'Text shown on the pad while it is empty.',
      () => placeholder,
      (String value) => placeholder = value,
    ),
    'placeholderColor': ColorFieldAccess<ColorRGBA>(
      'Placeholder Color',
      'Color of the placeholder.',
      () => placeholderColor,
      (ColorRGBA? value) {
        if (value != null) placeholderColor = value;
      },
    ),
    'placeholderFontSize': NumFieldAccess<double>(
      'Placeholder Font Size',
      'Font size of the placeholder.',
      () => placeholderFontSize,
      (double value) => placeholderFontSize = value,
    ),
    'showSignLine': BoolFieldAccess(
      'Show Sign Line',
      'Whether to draw a sign line with an "×" near the bottom of the pad.',
      () => showSignLine,
      (bool value) => showSignLine = value,
    ),
    'signLineColor': ColorFieldAccess<ColorRGBA>(
      'Sign Line Color',
      'Color of the sign line and its "×".',
      () => signLineColor,
      (ColorRGBA? value) {
        if (value != null) signLineColor = value;
      },
    ),
    'error': BoolFieldAccess(
      'Error',
      'Whether the pad shows its error border.',
      () => error,
      (bool value) => error = value,
    ),
    'enabled': BoolFieldAccess(
      'Enabled',
      'Whether the user can draw on the pad.',
      () => enabled,
      (bool value) => enabled = value,
    ),
  };

  @override
  List<Object?> get props => [
    inkColor,
    inkWidth,
    backgroundColor,
    borderColor,
    borderWidth,
    errorBorderColor,
    errorBorderWidth,
    cornerRadius,
    placeholder,
    placeholderColor,
    placeholderFontSize,
    showSignLine,
    signLineColor,
    error,
    enabled,
  ];

  /// Creates a [SignatureProperties] from a JSON data.
  factory SignatureProperties.fromJson(Map json) =>
      _$SignaturePropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SignaturePropertiesOmitDefaults(
    this,
    _$SignaturePropertiesToJson(this),
  );
}
