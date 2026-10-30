import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import '../node_json_converter.dart';
import 'nodes.dart';

part 'signature_normalized_node.g.dart';

/// Default width of a new [SignatureNormalizedNode].
const double kSignatureNormalizedDefaultWidth = 360;

/// Default height of a new [SignatureNormalizedNode].
const double kSignatureNormalizedDefaultHeight = 120;

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
@FlutterNode(
  'CodelesslyNormalizedSignature',
  family: 'codelessly',
  nodeType: 'signature',
  variant: 'normalized',
)
@JsonSerializable()
class SignatureNormalizedNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'signature';

  /// The strokes shown when `value` isn't bound.
  @FlutterProp(
    'strokes',
    type: 'array',
    group: 'State',
    control: 'strokes',
    bindable: true,
  )
  List<List<List<double>>> strokes;

  /// The ink and whether the box takes input.
  @override
  covariant SignatureNormalizedProperties properties;

  /// Creates a [SignatureNormalizedNode] with default values.
  SignatureNormalizedNode.empty()
    : properties = SignatureNormalizedProperties(),
      strokes = [],
      super(
        id: 'signatureNormalized',
        name: 'Signature Normalized',
        basicBoxLocal: NodeBox(
          0,
          0,
          kSignatureNormalizedDefaultWidth,
          kSignatureNormalizedDefaultHeight,
        ),
      );

  /// Creates a [SignatureNormalizedNode] with the given data.
  SignatureNormalizedNode({
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
    'properties': ObjectFieldAccess<SignatureNormalizedProperties>(
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

  /// Creates a [SignatureNormalizedNode] from JSON.
  factory SignatureNormalizedNode.fromJson(Map json) {
    NodeJsonConverter.validateSignatureWire(json, expectedType: 'normalized');
    return _$SignatureNormalizedNodeFromJson(json);
  }

  @override
  Map toJson() => {
    ..._$SignatureNormalizedNodeOmitDefaults(
      this,
      _$SignatureNormalizedNodeToJson(this),
    ),
    'type': 'signature',
    'signatureKind': 'normalized',
  };
}

/// The ink of a [SignatureNormalizedNode] and whether it takes input.
@JsonSerializable()
class SignatureNormalizedProperties extends CustomProperties with FieldsHolder {
  /// The ink's color.
  ColorRGBA inkColor;

  /// The ink's width in logical pixels.
  @FlutterProp(
    'strokeWidth',
    type: 'number',
    group: 'Appearance',
    control: 'number',
    field: 'properties.strokeWidth',
  )
  double strokeWidth;

  /// Whether the signature only shows, for replaying a saved one.
  @FlutterProp(
    'readOnly',
    type: 'boolean',
    group: 'Interaction',
    control: 'switch',
    field: 'properties.readOnly',
  )
  bool readOnly;

  /// Creates [SignatureNormalizedProperties].
  SignatureNormalizedProperties({
    this.inkColor = ColorRGBA.black,
    this.strokeWidth = 2.6,
    this.readOnly = false,
  });

  /// A copy with the given values replaced.
  SignatureNormalizedProperties copyWith({
    ColorRGBA? inkColor,
    double? strokeWidth,
    bool? readOnly,
  }) => SignatureNormalizedProperties(
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

  /// Creates [SignatureNormalizedProperties] from JSON.
  factory SignatureNormalizedProperties.fromJson(Map json) =>
      _$SignatureNormalizedPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SignatureNormalizedPropertiesOmitDefaults(
    this,
    _$SignatureNormalizedPropertiesToJson(this),
  );
}
