import 'package:json_annotation/json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'signature_node.g.dart';

/// Default width of a new [SignatureNode].
const double kSignatureDefaultWidth = 360;

/// Default height of a new [SignatureNode].
const double kSignatureDefaultHeight = 120;

/// A box the user signs in with a finger, pen or mouse.
///
/// The signature is a list of strokes, each a list of `[x, y]` points
/// normalized to the box (0 to 1), so it redraws at any size. Bind `value`
/// to a list variable to keep it: drawing writes the variable and fires
/// [TriggerType.changed] with the strokes, and setting the variable (to `[]`
/// to clear it, or to a saved signature to replay it) redraws the box.
///
/// The box paints only the ink: put it in a frame for a background and
/// border, with a watermark or signing line behind it.
@JsonSerializable()
class SignatureNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'signature';

  /// The strokes shown when `value` isn't bound.
  List<List<List<double>>> strokes;

  /// The ink and whether the box takes input.
  @override
  covariant SignatureProperties properties;

  /// Creates a [SignatureNode] with default values.
  SignatureNode.empty()
    : properties = SignatureProperties(),
      strokes = [],
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
    this.strokes = const [],
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
    super.aspectRatioLock,
    super.constraints,
    super.parentID,
    super.positioningMode,
    super.edgePins,
    required this.properties,
    super.variables,
    super.multipleVariables,
  });

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<SignatureProperties>(
      'Properties',
      'The ink and whether the box takes input.',
      () => properties,
      (value) => properties = value,
    ),
  };

  @override
  List<TriggerType> get triggerTypes => [TriggerType.changed];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    ObjectValue(name: 'value', value: strokes),
    BoolValue(name: 'readOnly', value: properties.readOnly),
    ColorValue(name: 'inkColor', value: properties.inkColor),
  ];

  /// Creates a [SignatureNode] from JSON.
  factory SignatureNode.fromJson(Map json) => _$SignatureNodeFromJson(json);

  @override
  Map toJson() =>
      _$SignatureNodeOmitDefaults(this, _$SignatureNodeToJson(this));
}

/// The ink of a [SignatureNode] and whether it takes input.
@JsonSerializable()
class SignatureProperties extends CustomProperties with FieldsHolder {
  /// The ink's color.
  ColorRGBA inkColor;

  /// The ink's width in logical pixels.
  double strokeWidth;

  /// Whether the signature only shows, for replaying a saved one.
  bool readOnly;

  /// Creates [SignatureProperties].
  SignatureProperties({
    this.inkColor = ColorRGBA.black,
    this.strokeWidth = 2.6,
    this.readOnly = false,
  });

  /// A copy with the given values replaced.
  SignatureProperties copyWith({
    ColorRGBA? inkColor,
    double? strokeWidth,
    bool? readOnly,
  }) => SignatureProperties(
    inkColor: inkColor ?? this.inkColor,
    strokeWidth: strokeWidth ?? this.strokeWidth,
    readOnly: readOnly ?? this.readOnly,
  );

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'inkColor': ColorFieldAccess<ColorRGBA>(
      'Ink color',
      'The color of the ink.',
      () => inkColor,
      (value) => inkColor = value,
    ),
    'strokeWidth': NumFieldAccess<double>(
      'Ink width',
      'The width of the ink in logical pixels.',
      () => strokeWidth,
      (double value) => strokeWidth = value,
    ),
    'readOnly': BoolFieldAccess(
      'Read only',
      'Whether the signature only shows, for replaying a saved one.',
      () => readOnly,
      (value) => readOnly = value,
    ),
  };

  @override
  List<Object?> get props => [inkColor, strokeWidth, readOnly];

  /// Creates [SignatureProperties] from JSON.
  factory SignatureProperties.fromJson(Map json) =>
      _$SignaturePropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SignaturePropertiesOmitDefaults(
    this,
    _$SignaturePropertiesToJson(this),
  );
}
