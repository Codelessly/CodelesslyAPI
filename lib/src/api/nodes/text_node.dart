import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../schema/flutter_prop.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'text_node.g.dart';

/// Helper class to communicate text computations to the internal layout engine
/// in the Codelessly editor.
/// [WidthRange] is the range of values of width for which the text node's
/// height remains constant.
/// Beyond this range, the height of text node changes.
@JsonSerializable()
class WidthRange with SerializableMixin implements Equatable {
  /// Minimum width for which the height remains constant.
  final int from;

  /// Maximum width for which the height remains constant.
  final int to;

  /// Creates a [WidthRange] instance with the given data.
  WidthRange({required this.from, required this.to});

  @override
  List<Object> get props => [from, to];

  @override
  bool get stringify => true;

  /// Creates a [WidthRange] instance from a JSON object.
  factory WidthRange.fromJson(Map<String, dynamic> json) =>
      _$WidthRangeFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$WidthRangeOmitDefaults(this, _$WidthRangeToJson(this));
}

/// A run of text with a single style. The Text widget displays a string of text
/// with single style. The string might break across multiple lines or might all
/// be displayed on the same line depending on the layout constraints.
/// Refer to [Text](https://api.flutter.dev/flutter/widgets/Text-class.html) in
/// Flutter for more details.
@FlutterNode('Text', family: 'widgets', nodeType: 'text')
@JsonSerializable()
class TextNode extends SceneNode with BlendMixin, TextMixin, FontMixin {
  @override
  final String type = 'text';

  /// Whether every digit takes the same width (tabular figures), so a
  /// clock, counter or column of numbers doesn't shift as its digits change.
  @FlutterProp(
    'tabularFigures',
    type: 'boolean',
    group: 'Text',
    control: 'switch',
    flutterParam: false,
    a2ui: false,
    note: 'Codelessly text digit-width option on the serialized text node.',
  )
  bool tabularFigures;

  /// Minimum width the text node can have.
  /// Calculated at runtime using Flutter TextPainter.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double minTextWidth = double.infinity;

  /// Minimum height the text node can have.
  /// Calculated at runtime using Flutter TextPainter.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double minTextHeight = double.infinity;

  /// Maximum width the text node can have.
  /// Calculated at runtime using Flutter TextPainter.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double maxTextWidth = double.infinity;

  /// Maximum height the text node can have.
  /// Calculated at runtime using Flutter TextPainter.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double maxTextHeight = double.infinity;

  /// A map of height to the range of width values for which the height remains
  /// constant.
  /// Calculated at runtime using Flutter TextPainter.
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, WidthRange> precalculatedSizes = {};

  @override
  List<FontName> get fonts => textMixedProps.map((e) => e.fontName).toList();

  @override
  bool get supportsPadding => false;

  /// Creates a [TextNode] instance with the given data.
  TextNode({
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
    // [TextMixin] properties.
    required String data,
    List<StartEndProp> textMixedProps = const [],
    double paragraphIndent = 0,
    double paragraphSpacing = 0,
    TextAlignHorizontalEnum textAlignHorizontal = TextAlignHorizontalEnum.left,
    TextAlignVerticalEnum textAlignVertical = TextAlignVerticalEnum.top,
    int? maxLines,
    TextOverflowC overflow = TextOverflowC.clip,
    bool softWrap = true,
    double? textScaleFactor,
    // [BlendMixin] properties.
    double opacity = 1.0,
    bool isMask = false,
    List<Effect> effects = const [],
    BlendModeC blendMode = BlendModeC.srcOver,
    super.variables,
    super.multipleVariables,
    InkWellModel? inkWell,
    this.tabularFigures = false,
  }) {
    setTextMixin(
      data: data,
      textMixedProps: textMixedProps,
      textAlignHorizontal: textAlignHorizontal,
      textAlignVertical: textAlignVertical,
      paragraphIndent: paragraphIndent,
      paragraphSpacing: paragraphSpacing,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
    );

    setBlendMixin(
      opacity: opacity,
      isMask: isMask,
      effects: effects,
      blendMode: blendMode,
      inkWell: inkWell,
    );
  }

  @override
  List<TriggerType> get triggerTypes => [
    TriggerType.click,
    TriggerType.longPress,
    TriggerType.doubleTap,
    TriggerType.cursorEnter,
    TriggerType.cursorExit,
    TriggerType.drag,
    TriggerType.dragEnd,
    TriggerType.pointerDown,
    TriggerType.pointerUp,
  ];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    StringValue(name: 'data', value: data),
    // Overrides the color of every span; set by a binding or condition.
    const ColorValue(name: 'textColor', value: null),
  ];

  @override
  String toString() => 'TextNode';

  /// Creates a [TextNode] instance from a JSON object.
  factory TextNode.fromJson(Map json) {
    if (json.containsKey('characters')) {
      throw const FormatException('Unsupported TextNode key: characters');
    }
    return _$TextNodeFromJson(json);
  }

  @override
  Map toJson() => _$TextNodeOmitDefaults(this, _$TextNodeToJson(this));
}

/// [TextNode] specific properties.
mixin TextMixin {
  /// Text data.
  @FlutterProp(
    'data',
    type: 'string',
    group: 'Text',
    control: 'text',
    field: 'data',
    required: true,
    bindable: true,
  )
  late String data;

  /// List of mixed text properties.
  /// Each [StartEndProp] has a [start] and [end] point that defines the index
  /// of data for which the properties should be applied to.
  @FlutterProp(
    'textMixedProps',
    type: 'array',
    group: 'Typography',
    control: 'list',
    flutterParam: false,
    a2ui: false,
    note: 'Serialized rich-text runs; font size, family, weight, color and links are nested in each run.',
  )
  late List<StartEndProp> textMixedProps;

  /// Horizontal alignment applied to text.
  @FlutterProp(
    'textAlignHorizontal',
    type: 'string',
    group: 'Typography',
    control: 'select',
    flutterParam: false,
    a2ui: false,
    note:
        'Codelessly persisted horizontal text alignment, not textAlign alias.',
  )
  late TextAlignHorizontalEnum textAlignHorizontal;

  /// Vertical alignment applied to text.
  late TextAlignVerticalEnum textAlignVertical;

  /// Indents for each paragraph.
  late double paragraphIndent;

  /// Spacing between paragraphs.
  late double paragraphSpacing;

  /// Maximum number of lines that the text can spread across when wrapped.
  @FlutterProp('maxLines', type: 'integer', group: 'Text', control: 'number')
  late int? maxLines;

  /// Defines how the text would clip when it overflows the available space.
  @FlutterProp(
    'overflow',
    type: 'string',
    group: 'Text',
    control: 'select',
    flutterParam: false,
    a2ui: false,
    note: 'Codelessly TextOverflowC persisted choice; not a string alias.',
  )
  late TextOverflowC overflow;

  /// Whether the text breaks at soft line breaks. When false, it is laid out
  /// as if there were unlimited horizontal space. Mirrors `Text.softWrap`.
  @FlutterProp(
    'softWrap',
    type: 'boolean',
    group: 'Text',
    control: 'switch',
    defaultSource: 'true',
  )
  late bool softWrap;

  /// Factor by which to scale the font size, on top of the platform's text
  /// scaling. Mirrors `Text.textScaler` as `TextScaler.linear`.
  late double? textScaleFactor;

  /// Set text properties.
  void setTextMixin({
    required String data,
    required List<StartEndProp> textMixedProps,
    required TextAlignHorizontalEnum textAlignHorizontal,
    required TextAlignVerticalEnum textAlignVertical,
    required double paragraphIndent,
    required double paragraphSpacing,
    required TextOverflowC overflow,
    int? maxLines,
    bool softWrap = true,
    double? textScaleFactor,
  }) {
    this.data = data;
    this.textMixedProps = textMixedProps;
    this.textAlignHorizontal = textAlignHorizontal;
    this.textAlignVertical = textAlignVertical;
    this.paragraphIndent = paragraphIndent;
    this.paragraphSpacing = paragraphSpacing;
    this.maxLines = maxLines;
    this.overflow = overflow;
    this.softWrap = softWrap;
    this.textScaleFactor = textScaleFactor;
  }
}

/// A mixin that stores the fonts used in a [TextNode].
mixin FontMixin {
  /// List of fonts.
  List<FontName> get fonts;
}
