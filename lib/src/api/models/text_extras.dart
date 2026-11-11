import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'text_extras.g.dart';

/// How a [TextNode] draws inline code: the segments of its resolved text
/// wrapped in backticks (`` `npm i` ``) are drawn with this style, and the
/// backticks are removed. Works with bound text, e.g. a changelog bullet
/// `${item.text}` reading "Retries honor `Retry-After`".
///
/// JSON: `{"fontFamily": "JetBrains Mono", "color": "#4ADE80",
/// "background": "#141C17", "fontSizeScale": 0.92, "paddingSpaces": 1}`.
/// Everything is optional; a property left null keeps the text's own.
@JsonSerializable()
class InlineCodeStyle with Equatable, SerializableMixin {
  /// The family of the code font, a Google Fonts family name such as
  /// `JetBrains Mono` or `Fira Code`. Null keeps the text's font.
  final String? fontFamily;

  /// The weight of the code, 100 to 900. Null keeps the text's weight.
  final int? fontWeight;

  /// The color of the code. Null keeps the text's color.
  final ColorRGBA? color;

  /// The color drawn behind the code. Null draws nothing behind it.
  final ColorRGBA? background;

  /// The code's font size as a multiple of the text's, e.g. 0.92 for code
  /// a little smaller than the prose around it.
  final double fontSizeScale;

  /// How many spaces, in the code's font and on its [background], pad each
  /// side of a code segment, so the chip has room around its text: 1 draws
  /// `` `npm i` `` as " npm i " (about 0.6 em each side in a monospace
  /// font), as code chips usually are. The spaces wrap like any other, so
  /// a line can break at a chip's edge. 0, the default, adds none.
  final int paddingSpaces;

  /// Creates an [InlineCodeStyle].
  const InlineCodeStyle({
    this.fontFamily,
    this.fontWeight,
    this.color,
    this.background,
    this.fontSizeScale = 1,
    this.paddingSpaces = 0,
  });

  /// Returns a copy with the given values replaced.
  InlineCodeStyle copyWith({
    String? fontFamily,
    int? fontWeight,
    ColorRGBA? color,
    ColorRGBA? background,
    double? fontSizeScale,
    int? paddingSpaces,
  }) => InlineCodeStyle(
    fontFamily: fontFamily ?? this.fontFamily,
    fontWeight: fontWeight ?? this.fontWeight,
    color: color ?? this.color,
    background: background ?? this.background,
    fontSizeScale: fontSizeScale ?? this.fontSizeScale,
    paddingSpaces: paddingSpaces ?? this.paddingSpaces,
  );

  @override
  List<Object?> get props => [
    fontFamily,
    fontWeight,
    color,
    background,
    fontSizeScale,
    paddingSpaces,
  ];

  /// Creates an [InlineCodeStyle] from JSON.
  factory InlineCodeStyle.fromJson(Map json) => _$InlineCodeStyleFromJson(json);

  @override
  Map toJson() =>
      _$InlineCodeStyleOmitDefaults(this, _$InlineCodeStyleToJson(this));
}

/// Makes a [TextNode] count to its new number: when the number in its
/// resolved text changes (a bound price going from `$29` to `$23`), the
/// number runs from the old value to the new one over [durationMs], eased by
/// [curve]. The text around the number (`$`, `/mo`) stays, and the number
/// keeps the new value's formatting (decimals, thousands separators).
///
/// JSON: `{"durationMs": 450, "curve": "easeOutCubic"}`. Applies at runtime
/// only; the design canvas shows the final text.
@JsonSerializable()
class CountUpModel with Equatable, SerializableMixin {
  /// How long the count takes, in milliseconds.
  final int durationMs;

  /// The easing of the count.
  final MotionCurve curve;

  /// Creates a [CountUpModel].
  const CountUpModel({
    this.durationMs = 450,
    this.curve = MotionCurve.easeOutCubic,
  });

  /// Returns a copy with the given values replaced.
  CountUpModel copyWith({int? durationMs, MotionCurve? curve}) => CountUpModel(
    durationMs: durationMs ?? this.durationMs,
    curve: curve ?? this.curve,
  );

  @override
  List<Object?> get props => [durationMs, curve];

  /// Creates a [CountUpModel] from JSON.
  factory CountUpModel.fromJson(Map json) => _$CountUpModelFromJson(json);

  @override
  Map toJson() => _$CountUpModelOmitDefaults(this, _$CountUpModelToJson(this));
}
