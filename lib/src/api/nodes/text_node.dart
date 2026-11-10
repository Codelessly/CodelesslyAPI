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

  /// The OpenType features of the font that every span of the text turns
  /// on or sets, e.g. `["lnum"]` for lining figures in a font whose digits
  /// are old-style by default, `["tnum", "smcp"]`, `["ss01"]` or
  /// `["liga=0"]`.
  ///
  /// Each entry is a four-character OpenType tag, alone to turn the feature
  /// on (value 1) or followed by `=` and a value (`"liga=0"` turns
  /// ligatures off, `"salt=2"` picks the second alternate). JSON may also
  /// give an entry as `{"tag": "salt", "value": 2}`, or the whole list as
  /// one string (`"lnum tnum"` or `"lnum,tnum"`); both are stored as the
  /// list of strings. A later entry for the same tag wins.
  ///
  /// [tabularFigures] means the same as `tnum` here; see
  /// [resolvedFontFeatures] for the features the text is drawn with.
  @FlutterProp(
    'fontFeatures',
    type: 'array',
    group: 'Text',
    control: 'list',
    flutterParam: false,
    a2ui: false,
    note:
        'Codelessly OpenType feature tags (e.g. "lnum", "liga=0") applied '
        'to every span; TextStyle.fontFeatures in Flutter.',
  )
  @JsonKey(fromJson: OpenTypeFeature.parseList)
  List<String> fontFeatures;

  /// The OpenType features the text is drawn and measured with: those of
  /// [fontFeatures], one per tag (the last entry for a tag wins), plus
  /// `tnum` when [tabularFigures] is on and [fontFeatures] doesn't set it.
  List<OpenTypeFeature> get resolvedFontFeatures {
    final Map<String, OpenTypeFeature> byTag = {
      for (final String entry in fontFeatures)
        if (OpenTypeFeature.tryParse(entry) case final OpenTypeFeature f)
          f.tag: f,
    };
    if (tabularFigures)
      byTag.putIfAbsent('tnum', () => OpenTypeFeature.on('tnum'));
    return byTag.values.toList();
  }

  /// Renders the text as Markdown with this style (bold, italic, code,
  /// links, mentions, lists, paragraphs); null shows it as plain text.
  MarkdownStyle? markdown;

  /// The language to highlight the text as, when it shows code: its
  /// keywords, strings, comments, numbers and so on take the colors of
  /// [codeTheme], drawn over the text's own style. [SyntaxLanguage.none]
  /// (the default) shows plain text. Can be bound through
  /// `variables['codeLanguage']` to a language name (or an alias such as
  /// `js`, `py` or `sh`), so one code block can follow a language tab.
  SyntaxLanguage codeLanguage;

  /// The colors of the highlighted tokens when [codeLanguage] is set. Null,
  /// or a color left null, takes [CodeThemeModel.defaults].
  CodeThemeModel? codeTheme;

  /// How inline code in the text is drawn. When set, the segments of the
  /// resolved text wrapped in backticks take this style and lose their
  /// backticks, on the design canvas and at runtime. Null (the default)
  /// shows backticks as typed.
  InlineCodeStyle? inlineCode;

  /// Makes the number in the text count from its old value to its new one
  /// when the resolved text changes, at runtime. Null (the default) shows
  /// the new text at once.
  CountUpModel? countUp;

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

  /// A text node has no padding, so a [padding] stored on it (written by hand
  /// or by a tool; the editor's panel hides the field) pads nothing: its
  /// inner box is its box. The published site never drew that padding, and
  /// the editor's canvas left room for it, so the two disagreed on the
  /// node's size. Space around text is [margin].
  @override
  EdgeInsetsModel resolvedPadding([EdgeInsetsModel? padding]) =>
      minimumPadding();

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
    List<String> fontFeatures = const [],
    this.markdown,
    this.codeLanguage = SyntaxLanguage.none,
    this.codeTheme,
    this.inlineCode,
    this.countUp,
  }) : fontFeatures = OpenTypeFeature.parseList(fontFeatures) {
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
    TriggerType.reorder,
    TriggerType.changed,
    TriggerType.wheel,
    TriggerType.pinch,
    TriggerType.pointerDown,
    TriggerType.pointerUp,
    ...TriggerType.viewport,
  ];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    StringValue(name: 'data', value: data),
    StringValue(name: 'codeLanguage', value: codeLanguage.name),
    // The style of every span, set by a binding, condition or set value
    // action (see the SDK's StyleBindings): a font size, letter spacing and
    // line height in pixels, a font family name, and an alignment name
    // (left, center, right, justified, start, end).
    DoubleValue(
      name: 'fontSize',
      value: textMixedProps.firstOrNull?.fontSize ?? 18,
    ),
    DoubleValue(
      name: 'letterSpacing',
      value: textMixedProps.firstOrNull?.letterSpacing.value ?? 0,
    ),
    DoubleValue(
      name: 'lineHeight',
      value: textMixedProps.firstOrNull?.lineHeight.value ?? 0,
    ),
    StringValue(
      name: 'fontFamily',
      value: textMixedProps.firstOrNull?.fontName.family ?? 'Roboto',
    ),
    StringValue(name: 'textAlign', value: textAlignHorizontal.name),
    // Overrides the color of every span; set by a binding or condition.
    const ColorValue(name: 'textColor', value: null),
    // Overrides the decoration of every span: `none`, `underline`,
    // `strikethrough` (or `lineThrough`) or `overline`.
    StringValue(
      name: 'textDecoration',
      value: textMixedProps.firstOrNull?.textDecoration.name ?? 'none',
    ),
  ];

  @override
  String toString() => 'TextNode';

  /// Creates a [TextNode] instance from a JSON object.
  factory TextNode.fromJson(Map json) {
    if (json.containsKey('characters')) {
      throw const FormatException(
        'Unsupported TextNode key: characters (the text is "data")',
      );
    }
    return _$TextNodeFromJson(json);
  }

  @override
  Map toJson() => _$TextNodeOmitDefaults(this, _$TextNodeToJson(this));
}

/// One OpenType feature setting of a text: a four-character feature [tag]
/// such as `lnum` (lining figures), `tnum` (tabular figures), `smcp` (small
/// capitals) or `ss01` (stylistic set 1), and the [value] it is set to. 1
/// turns a feature on and 0 off; some features (`salt`, `cvXX`) pick an
/// alternate by number.
///
/// On the wire a setting is a string, `"lnum"` (value 1) or `"liga=0"`; see
/// [TextNode.fontFeatures].
class OpenTypeFeature with Equatable {
  /// The four-character OpenType feature tag, e.g. `lnum`.
  final String tag;

  /// The value the feature is set to: 1 turns it on, 0 off.
  final int value;

  /// Creates a setting of [tag] to [value]. Throws a [FormatException] if
  /// [tag] isn't four printable ASCII characters or [value] is negative.
  OpenTypeFeature(this.tag, [this.value = 1]) {
    if (!isValidTag(tag)) {
      throw FormatException(
        'An OpenType feature tag is four printable ASCII characters, '
        'like "lnum" or "ss01"',
        tag,
      );
    }
    if (value < 0) {
      throw FormatException('An OpenType feature value is 0 or more', value);
    }
  }

  /// Turns the feature [tag] on.
  factory OpenTypeFeature.on(String tag) => OpenTypeFeature(tag);

  static final RegExp _tag = RegExp(r'^[\x20-\x7E]{4}$');

  /// Whether [tag] is a valid OpenType feature tag: four printable ASCII
  /// characters.
  static bool isValidTag(String tag) => _tag.hasMatch(tag);

  /// Parses one setting: a string `"lnum"` or `"liga=0"` (spaces around the
  /// tag, `=` and value are ignored, so `"liga = 0"` works), or a map
  /// `{"tag": "liga", "value": 0}` (the value defaults to 1; `true` and
  /// `false` mean 1 and 0). Throws a [FormatException] for anything else.
  factory OpenTypeFeature.parse(Object? entry) {
    switch (entry) {
      case String():
        final String text = entry.trim();
        final int equals = text.indexOf('=');
        if (equals < 0) return OpenTypeFeature(text);
        final String tag = text.substring(0, equals).trim();
        final int? value = int.tryParse(text.substring(equals + 1).trim());
        if (value == null) {
          throw FormatException(
            'An OpenType feature is "tag" or "tag=<integer>", like "liga=0"',
            entry,
          );
        }
        return OpenTypeFeature(tag, value);
      case Map():
        final Object? tag = entry['tag'];
        final Object? value = entry['value'] ?? 1;
        if (tag is! String) {
          throw FormatException('An OpenType feature map needs a "tag"', entry);
        }
        return OpenTypeFeature(tag.trim(), switch (value) {
          true => 1,
          false => 0,
          num() when value == value.roundToDouble() => value.toInt(),
          String() when int.tryParse(value.trim()) != null => int.parse(
            value.trim(),
          ),
          _ => throw FormatException(
            'An OpenType feature value is an integer',
            entry,
          ),
        });
      default:
        throw FormatException(
          'An OpenType feature is a string like "lnum" or "liga=0"',
          entry,
        );
    }
  }

  /// [OpenTypeFeature.parse], or null for an entry it can't parse.
  static OpenTypeFeature? tryParse(Object? entry) {
    try {
      return OpenTypeFeature.parse(entry);
    } on FormatException {
      return null;
    }
  }

  /// Parses the JSON of [TextNode.fontFeatures] into its canonical list of
  /// strings (`"lnum"`, `"liga=0"`): a list of settings (strings or maps,
  /// see [OpenTypeFeature.parse]) or one string of settings separated by
  /// commas or spaces. Null is an empty list. Throws a [FormatException]
  /// for an invalid setting.
  static List<String> parseList(Object? json) {
    final Iterable<Object?> entries = switch (json) {
      null => const [],
      String() => json.split(RegExp(r'[,\s]+')).where((e) => e.isNotEmpty),
      List() => json,
      _ => throw FormatException(
        'fontFeatures is a list of OpenType features, like ["lnum"]',
        json,
      ),
    };
    return [
      for (final Object? entry in entries)
        OpenTypeFeature.parse(entry).toString(),
    ];
  }

  @override
  List<Object?> get props => [tag, value];

  /// The setting as it is stored: `"lnum"` when on, else `"liga=0"`.
  @override
  String toString() => value == 1 ? tag : '$tag=$value';
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
  ///
  /// A text that hugs its content inside a row is held to the row's width
  /// and wraps there, where a Flutter `Row` would leave a plain `Text`
  /// unbounded on one line (overflowing if it must). Set this to false for
  /// labels that must stay on one line: a button's label, a wordmark.
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
