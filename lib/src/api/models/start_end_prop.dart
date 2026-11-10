import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';
import '../../schema/flutter_prop.dart';
import 'models.dart';

part 'start_end_prop.g.dart';

/// Different types of text decoration.
enum TextDecorationEnum {
  /// No decoration.
  none,

  /// Text with underline.
  underline,

  /// Text with line above.
  overline,

  /// Text with line strike-through.
  strikethrough;

  /// The decoration [value] names: `none`, `underline`, `overline` or
  /// `strikethrough`, ignoring case, spaces, dashes and underscores, with
  /// `lineThrough` (Flutter's and CSS's name), `strike` and `crossed` as
  /// aliases of strikethrough. Null when it names none.
  static TextDecorationEnum? parse(Object? value) {
    if (value is TextDecorationEnum) return value;
    if (value == null) return null;
    final String key = value.toString().trim().toLowerCase().replaceAll(
      RegExp(r'[\s_-]'),
      '',
    );
    return switch (key) {
      'none' || '' => TextDecorationEnum.none,
      'underline' || 'underlined' => TextDecorationEnum.underline,
      'overline' => TextDecorationEnum.overline,
      'strikethrough' ||
      'linethrough' ||
      'strike' ||
      'crossed' => TextDecorationEnum.strikethrough,
      _ => null,
    };
  }

  /// Displayable string representation of this enum.
  String get prettify {
    switch (this) {
      case TextDecorationEnum.none:
        return 'None';
      case TextDecorationEnum.underline:
        return 'Underline';
      case TextDecorationEnum.overline:
        return 'Overline';
      case TextDecorationEnum.strikethrough:
        return 'Strikethrough';
    }
  }
}

/// Reads the `textDecoration` of text JSON [json], with its aliases (such as
/// `lineThrough`) read as the [TextDecorationEnum] names they stand for.
Object? readTextDecoration(Map json, String key) {
  final Object? value = json[key];
  if (value == null || value is! String) return value;
  return TextDecorationEnum.parse(value)?.name ?? value;
}

/// The line style of a text decoration. Mirrors Flutter's
/// `TextDecorationStyle`.
enum TextDecorationStyleEnum {
  /// A solid line.
  solid,

  /// Two parallel lines.
  double,

  /// A dotted line.
  dotted,

  /// A dashed line.
  dashed,

  /// A wavy line.
  wavy;

  /// Displayable string representation of this enum.
  String get prettify => switch (this) {
    TextDecorationStyleEnum.solid => 'Solid',
    TextDecorationStyleEnum.double => 'Double',
    TextDecorationStyleEnum.dotted => 'Dotted',
    TextDecorationStyleEnum.dashed => 'Dashed',
    TextDecorationStyleEnum.wavy => 'Wavy',
  };
}

/// Holds text properties in addition to start and end index of the characters
/// which the properties belong to.
@JsonSerializable()
final class StartEndProp extends TextProp {
  /// Index of the first character to which the properties belong.
  final int start;

  /// Index of the last character to which the properties belong.
  /// This is inclusive.
  final int end;

  /// This can be used if it is just meant to hold style data for text. It will
  /// ignore [start] and [end] properties.
  StartEndProp.general({
    List<PaintModel>? fills,
    super.textDecoration,
    super.decorationColor,
    super.decorationThickness,
    super.decorationStyle,
    super.letterSpacing,
    super.fontSize = 12,
    super.fontName,
    super.lineHeight,
    super.link,
    super.isJsonPath,
  }) : start = 0,
       end = 0,
       super(fills: fills ?? [PaintModel.whitePaint]);

  /// Creates a [StartEndProp] with the given data.
  StartEndProp({
    required this.start,
    required this.end,
    super.fills,
    super.textDecoration,
    super.decorationColor,
    super.decorationThickness,
    super.decorationStyle,
    super.letterSpacing,
    super.fontSize,
    super.fontName,
    super.lineHeight,
    super.link,
    super.isJsonPath,
  });

  /// Creates a [StartEndProp] with the given data from a [TextProp].
  StartEndProp.fromTextProp({
    required this.start,
    required this.end,
    required TextProp prop,
  }) : super(
         fills: prop.fills,
         textDecoration: prop.textDecoration,
         decorationColor: prop.decorationColor,
         decorationThickness: prop.decorationThickness,
         decorationStyle: prop.decorationStyle,
         letterSpacing: prop.letterSpacing,
         fontSize: prop.fontSize,
         fontName: prop.fontName,
         lineHeight: prop.lineHeight,
         link: prop.link,
         isJsonPath: prop.isJsonPath,
       );

  @override
  StartEndProp copyWith({
    int? start,
    int? end,
    List<PaintModel>? fills,
    TextDecorationEnum? textDecoration,
    ColorRGBA? decorationColor,
    double? decorationThickness,
    TextDecorationStyleEnum? decorationStyle,
    double? fontSize,
    LetterSpacing? letterSpacing,
    FontName? fontName,
    LineHeight? lineHeight,
    String? link,
    bool? isJsonPath,
  }) => StartEndProp(
    start: start ?? this.start,
    end: end ?? this.end,
    fills: fills ?? this.fills,
    textDecoration: textDecoration ?? this.textDecoration,
    decorationColor: decorationColor ?? this.decorationColor,
    decorationThickness: decorationThickness ?? this.decorationThickness,
    decorationStyle: decorationStyle ?? this.decorationStyle,
    fontSize: fontSize ?? this.fontSize,
    letterSpacing: letterSpacing ?? this.letterSpacing,
    fontName: fontName ?? this.fontName,
    lineHeight: lineHeight ?? this.lineHeight,
    link: link ?? this.link,
    isJsonPath: isJsonPath ?? this.isJsonPath,
  );

  @override
  List<Object?> get props => [
    start,
    end,
    fills,
    textDecoration,
    decorationColor,
    decorationThickness,
    decorationStyle,
    fontSize,
    letterSpacing,
    fontName,
    lineHeight,
    link,
    isJsonPath,
  ];

  /// Factory constructor for creating a new [StartEndProp] instance from
  /// JSON data.
  factory StartEndProp.fromJson(Map json) => _$StartEndPropFromJson(json);

  @override
  Map toJson() => _$StartEndPropOmitDefaults(this, _$StartEndPropToJson(this));
}

/// Represents text styling for whole text. All the values/properties are
/// applied to the whole text unlike [StartEndProp] which can be used for
/// rich text.
@JsonSerializable()
class TextProp extends Equatable with SerializableMixin {
  /// Fills of the text.
  @FlutterProp(
    'fills',
    type: 'array',
    group: 'Typography',
    control: 'list',
    flutterParam: false,
    a2ui: false,
    note: 'Persisted text-run paint list; color is nested in each paint.',
  )
  final List<PaintModel> fills;

  /// Decoration of the text. JSON may spell strikethrough `lineThrough`, as
  /// Flutter and CSS do (see [TextDecorationEnum.parse]).
  @FlutterProp(
    'textDecoration',
    type: 'string',
    group: 'Typography',
    control: 'select',
    flutterParam: false,
    a2ui: false,
    note: 'Persisted text-run underline/overline/strikethrough choice.',
  )
  @JsonKey(readValue: readTextDecoration)
  final TextDecorationEnum textDecoration;

  /// The color of the [textDecoration] line (an underline or strikethrough).
  /// Null draws it in the text's color.
  final ColorRGBA? decorationColor;

  /// The thickness of the [textDecoration] line, as a multiple of the
  /// font's default thickness (Flutter's `TextStyle.decorationThickness`).
  /// Null keeps the font's default.
  final double? decorationThickness;

  /// The line style of the [textDecoration].
  final TextDecorationStyleEnum decorationStyle;

  /// Size of the text.
  @FlutterProp(
    'fontSize',
    type: 'number',
    group: 'Typography',
    control: 'number',
    flutterParam: false,
    a2ui: false,
    note: 'Persisted size for this text run, not a TextNode top-level field.',
  )
  final double fontSize;

  /// Space between letters in text.
  @FlutterProp(
    'letterSpacing',
    type: 'object',
    group: 'Typography',
    control: 'number',
    flutterParam: false,
    a2ui: false,
    note: 'Persisted letter-spacing model for this text run.',
  )
  final LetterSpacing letterSpacing;

  /// Font family.
  @FlutterProp(
    'fontName',
    type: 'object',
    group: 'Typography',
    control: 'font',
    flutterParam: false,
    a2ui: false,
    note: 'Persisted family/style/weight object for this text run.',
  )
  final FontName fontName;

  /// line height for the text.
  @FlutterProp(
    'lineHeight',
    type: 'object',
    group: 'Typography',
    control: 'number',
    flutterParam: false,
    a2ui: false,
    note: 'Persisted line-height model for this text run.',
  )
  final LineHeight lineHeight;

  /// URL to launch when text span is tapped.
  @FlutterProp(
    'link',
    type: 'string',
    group: 'Typography',
    control: 'text',
    flutterParam: false,
    a2ui: false,
    note: 'Persisted hyperlink destination on this text run.',
  )
  final String link;

  /// Whether the text is recognized as a variable.
  final bool isJsonPath;

  /// Creates a [TextProp] with the given data.
  TextProp({
    List<PaintModel>? fills,
    this.textDecoration = TextDecorationEnum.none,
    this.decorationColor,
    this.decorationThickness,
    this.decorationStyle = TextDecorationStyleEnum.solid,
    this.letterSpacing = LetterSpacing.zero,
    this.fontSize = 18,
    this.fontName = FontName.robotoRegular,
    this.lineHeight = LineHeight.auto,
    this.link = '',
    this.isJsonPath = false,
  }) : fills = fills ?? [PaintModel.blackPaint];

  /// Creates a [TextProp] with the given data with white text.
  TextProp.general({
    List<PaintModel>? fills,
    this.textDecoration = TextDecorationEnum.none,
    this.decorationColor,
    this.decorationThickness,
    this.decorationStyle = TextDecorationStyleEnum.solid,
    this.letterSpacing = LetterSpacing.zero,
    this.fontSize = 12,
    this.fontName = FontName.robotoRegular,
    this.lineHeight = LineHeight.auto,
    this.link = '',
    this.isJsonPath = false,
  }) : fills = fills ?? [PaintModel.whitePaint];

  /// Duplicates this instance with given data overrides.
  TextProp copyWith({
    List<PaintModel>? fills,
    TextDecorationEnum? textDecoration,
    ColorRGBA? decorationColor,
    double? decorationThickness,
    TextDecorationStyleEnum? decorationStyle,
    double? fontSize,
    LetterSpacing? letterSpacing,
    FontName? fontName,
    LineHeight? lineHeight,
    String? link,
    bool? isJsonPath,
  }) => TextProp(
    fills: fills ?? this.fills,
    textDecoration: textDecoration ?? this.textDecoration,
    decorationColor: decorationColor ?? this.decorationColor,
    decorationThickness: decorationThickness ?? this.decorationThickness,
    decorationStyle: decorationStyle ?? this.decorationStyle,
    fontSize: fontSize ?? this.fontSize,
    letterSpacing: letterSpacing ?? this.letterSpacing,
    fontName: fontName ?? this.fontName,
    lineHeight: lineHeight ?? this.lineHeight,
    link: link ?? this.link,
    isJsonPath: isJsonPath ?? this.isJsonPath,
  );

  /// Returns true if this instance is equivalent to the [other].
  /// The reason this comparison is not done in [Equatable] is because
  /// [fills] is a list of [PaintModel]s which each has their own
  /// id, differentiating them from each other. So, we need to compare
  /// each [PaintModel] in the list.
  bool isEquivalentTo(TextProp? other) {
    return other != null &&
        fills.length == other.fills.length &&
        fills.every((a) => other.fills.any((b) => a.isEquivalentTo(b))) &&
        textDecoration == other.textDecoration &&
        decorationColor == other.decorationColor &&
        decorationThickness == other.decorationThickness &&
        decorationStyle == other.decorationStyle &&
        fontSize == other.fontSize &&
        letterSpacing == other.letterSpacing &&
        fontName == other.fontName &&
        lineHeight == other.lineHeight &&
        link == other.link &&
        isJsonPath == other.isJsonPath;
  }

  @override
  List<Object?> get props => [
    fills,
    textDecoration,
    decorationColor,
    decorationThickness,
    decorationStyle,
    fontSize,
    letterSpacing,
    fontName,
    lineHeight,
    link,
    isJsonPath,
  ];

  /// Factory constructor for creating a new [TextProp] instance from JSON data.
  factory TextProp.fromJson(Map json) => _$TextPropFromJson(json);

  @override
  Map toJson() => _$TextPropOmitDefaults(this, _$TextPropToJson(this));
}
