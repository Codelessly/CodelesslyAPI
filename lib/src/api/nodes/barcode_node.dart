import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'barcode_node.g.dart';

/// Default width of a barcode node.
const double kBarcodeDefaultWidth = 160;

/// Default height of a barcode node.
const double kBarcodeDefaultHeight = 160;

/// The encoding a [BarcodeNode] draws its [BarcodeNode.data] with.
enum BarcodeSymbology {
  /// QR code: a square 2D matrix. Encodes any text.
  qrCode,

  /// PDF417: a stacked linear 2D code, e.g. the IATA boarding pass barcode.
  /// Encodes any text. Fills the node's box.
  pdf417,

  /// Code 128: a 1D code for ASCII text.
  code128,

  /// Aztec: a square 2D matrix with a bullseye finder. Encodes any text.
  aztec,

  /// Data Matrix: a square 2D matrix. Encodes any text.
  dataMatrix,

  /// EAN-13: a 1D retail code. Encodes 12 or 13 digits; the 13th is the
  /// check digit.
  ean13;

  /// Displayable label.
  String get prettify => switch (this) {
    BarcodeSymbology.qrCode => 'QR Code',
    BarcodeSymbology.pdf417 => 'PDF417',
    BarcodeSymbology.code128 => 'Code 128',
    BarcodeSymbology.aztec => 'Aztec',
    BarcodeSymbology.dataMatrix => 'Data Matrix',
    BarcodeSymbology.ean13 => 'EAN-13',
  };

  /// Whether this is a two-dimensional code. 2D codes never draw text.
  bool get is2D => switch (this) {
    BarcodeSymbology.qrCode ||
    BarcodeSymbology.pdf417 ||
    BarcodeSymbology.aztec ||
    BarcodeSymbology.dataMatrix => true,
    BarcodeSymbology.code128 || BarcodeSymbology.ean13 => false,
  };

  /// Whether the code's modules are square, so it keeps its aspect ratio and
  /// is centered in the node's box. PDF417 and 1D codes stretch to fill it.
  bool get hasSquareModules => switch (this) {
    BarcodeSymbology.qrCode ||
    BarcodeSymbology.aztec ||
    BarcodeSymbology.dataMatrix => true,
    _ => false,
  };
}

/// How much of a QR code can be damaged and still be read.
enum BarcodeErrorCorrection {
  /// About 7% of the code can be restored.
  low,

  /// About 15% of the code can be restored.
  medium,

  /// About 25% of the code can be restored.
  quartile,

  /// About 30% of the code can be restored.
  high;

  /// Displayable label.
  String get prettify => switch (this) {
    BarcodeErrorCorrection.low => 'Low (7%)',
    BarcodeErrorCorrection.medium => 'Medium (15%)',
    BarcodeErrorCorrection.quartile => 'Quartile (25%)',
    BarcodeErrorCorrection.high => 'High (30%)',
  };
}

/// A barcode or QR code that encodes [data] with
/// [BarcodeProperties.symbology], filling the node's box.
///
/// [data] may contain variable paths and formulas (`${pass.barcode}`,
/// `${= formula}`), or be bound as a whole through `variables['data']`.
/// Data the symbology can't encode (e.g. letters in an EAN-13) draws a
/// placeholder instead of the code.
@FlutterNode('CodelesslyBarcode', family: 'codelessly', nodeType: 'barcode')
@JsonSerializable()
class BarcodeNode extends SceneNode with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'barcode';

  @override
  bool get supportsPadding => false;

  /// Barcodes have no tap callback of their own, so click reactions are
  /// handled by the renderer like on any other node.
  @override
  bool get handlesDefaultReactionsInternally => false;

  /// The text the barcode encodes.
  @FlutterProp(
    'data',
    type: 'string',
    group: 'Barcode',
    control: 'text',
    field: 'data',
    required: true,
    bindable: true,
  )
  String data;

  /// Holds configurable properties of the barcode.
  @override
  covariant BarcodeProperties properties;

  /// Strictly used for previews. e.g in components panel.
  BarcodeNode.empty()
    : data = 'https://codelessly.com',
      properties = BarcodeProperties(),
      super(
        id: 'barcode',
        name: 'Barcode',
        basicBoxLocal: NodeBox(
          0,
          0,
          kBarcodeDefaultWidth,
          kBarcodeDefaultHeight,
        ),
      );

  /// Creates a [BarcodeNode] with the given data.
  BarcodeNode({
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
    // Custom properties.
    this.data = '',
    required this.properties,
    super.variables,
    super.multipleVariables,
  });

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'data': StringFieldAccess(
      'Data',
      'The text the barcode encodes.',
      () => data,
      (value) => data = value,
    ),
    'properties': ObjectFieldAccess<BarcodeProperties>(
      'Properties',
      'Properties of the barcode.',
      () => properties,
      (value) => properties = value,
    ),
  };

  @override
  List<TriggerType> get triggerTypes => [
    TriggerType.click,
    TriggerType.cursorEnter,
    TriggerType.cursorExit,
  ];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    StringValue(name: 'data', value: data),
    ColorValue(name: 'color', value: properties.color),
  ];

  @override
  List<Object?> get props => [
    ...super.props,
    data,
    properties,
    variables,
    multipleVariables,
  ];

  /// Keys of [BarcodeProperties] that hand-written JSON may put at the top
  /// level of the node instead of under `properties`.
  static const Set<String> _propertyKeys = {
    'symbology',
    'color',
    'backgroundColor',
    'errorCorrection',
    'drawText',
  };

  /// Creates a [BarcodeNode] from a JSON data.
  ///
  /// Lenient for hand-written JSON: `properties` may be left out, and its
  /// keys (e.g. `symbology`) may be given at the top level of the node.
  /// Keys under `properties` win over top-level ones.
  factory BarcodeNode.fromJson(Map json) {
    final Map? properties = json['properties'] as Map?;
    return _$BarcodeNodeFromJson({
      ...json,
      'properties': {
        for (final String key in _propertyKeys)
          if (json[key] != null) key: json[key],
        ...?properties,
      },
    });
  }

  @override
  Map toJson() => _$BarcodeNodeOmitDefaults(this, _$BarcodeNodeToJson(this));
}

/// Holds configurable properties of a [BarcodeNode].
@JsonSerializable()
class BarcodeProperties extends CustomProperties with FieldsHolder {
  /// The encoding of the barcode.
  @FlutterProp(
    'symbology',
    type: 'string',
    group: 'Barcode',
    control: 'enum',
    field: 'properties.symbology',
  )
  @JsonKey(unknownEnumValue: BarcodeSymbology.qrCode)
  BarcodeSymbology symbology;

  /// Color of the bars or modules. Bindable as `color`.
  @FlutterProp(
    'color',
    type: 'object',
    group: 'Appearance',
    control: 'color',
    field: 'properties.color',
  )
  ColorRGBA color;

  /// Color behind the bars or modules. Transparent when null.
  @FlutterProp(
    'backgroundColor',
    type: 'object',
    group: 'Appearance',
    control: 'color',
    field: 'properties.backgroundColor',
  )
  ColorRGBA? backgroundColor;

  /// Error correction level of a QR code. Ignored by other symbologies.
  @FlutterProp(
    'errorCorrection',
    type: 'string',
    group: 'Barcode',
    control: 'enum',
    field: 'properties.errorCorrection',
  )
  @JsonKey(unknownEnumValue: BarcodeErrorCorrection.medium)
  BarcodeErrorCorrection errorCorrection;

  /// Whether a 1D code draws its data as text below the bars. Ignored by 2D
  /// codes.
  @FlutterProp(
    'drawText',
    type: 'boolean',
    group: 'Barcode',
    control: 'switch',
    field: 'properties.drawText',
  )
  bool drawText;

  /// Creates a [BarcodeProperties] with the given data.
  BarcodeProperties({
    this.symbology = BarcodeSymbology.qrCode,
    this.color = ColorRGBA.black,
    this.backgroundColor,
    this.errorCorrection = BarcodeErrorCorrection.medium,
    this.drawText = true,
  });

  /// Duplicates this [BarcodeProperties] with the given data overrides.
  /// [backgroundColor] can't be cleared this way; set it to null directly.
  BarcodeProperties copyWith({
    BarcodeSymbology? symbology,
    ColorRGBA? color,
    ColorRGBA? backgroundColor,
    BarcodeErrorCorrection? errorCorrection,
    bool? drawText,
  }) {
    return BarcodeProperties(
      symbology: symbology ?? this.symbology,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      errorCorrection: errorCorrection ?? this.errorCorrection,
      drawText: drawText ?? this.drawText,
    );
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'symbology': EnumFieldAccess<BarcodeSymbology>(
      'Symbology',
      'The encoding of the barcode.',
      () => symbology,
      (value) => symbology = value,
      defaultValue: () => BarcodeSymbology.qrCode,
      options: () => BarcodeSymbology.values,
    ),
    'color': ColorFieldAccess<ColorRGBA>(
      'Color',
      'Color of the bars or modules.',
      () => color,
      (value) => color = value,
    ),
    'backgroundColor': ColorFieldAccess<ColorRGBA?>(
      'Background Color',
      'Color behind the bars or modules.',
      () => backgroundColor,
      (value) => backgroundColor = value,
    ),
    'errorCorrection': EnumFieldAccess<BarcodeErrorCorrection>(
      'Error Correction',
      'Error correction level of a QR code.',
      () => errorCorrection,
      (value) => errorCorrection = value,
      defaultValue: () => BarcodeErrorCorrection.medium,
      options: () => BarcodeErrorCorrection.values,
    ),
    'drawText': BoolFieldAccess(
      'Draw Text',
      'Whether a 1D code draws its data as text below the bars.',
      () => drawText,
      (value) => drawText = value,
    ),
  };

  @override
  List<Object?> get props => [
    symbology,
    color,
    backgroundColor,
    errorCorrection,
    drawText,
  ];

  /// Creates a [BarcodeProperties] from a JSON data.
  factory BarcodeProperties.fromJson(Map json) =>
      _$BarcodePropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$BarcodePropertiesOmitDefaults(this, _$BarcodePropertiesToJson(this));
}
