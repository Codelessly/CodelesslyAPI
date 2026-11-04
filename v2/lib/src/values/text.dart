import 'package:meta/meta.dart';

import '../json.dart';
import 'color.dart';
import 'enums.dart';
import 'paint.dart';

/// Flutter's `TextStyle`. Every field is optional: a span's style is merged
/// over its text's base style, as in `Text.rich`.
@immutable
final class TextStyle {
  const TextStyle({
    this.fontFamily,
    this.fontWeight,
    this.fontStyle,
    this.fontSize,
    this.color,
    this.foreground,
    this.letterSpacing,
    this.height,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.tabularFigures,
    this.shadows = const [],
  });

  static const TextStyle empty = TextStyle();

  final String? fontFamily;

  /// 100–900.
  final int? fontWeight;
  final FontStyle? fontStyle;
  final double? fontSize;

  /// Solid text color.
  final Color? color;

  /// A gradient or image paint for the glyphs, used instead of [color].
  final Paint? foreground;

  /// Logical pixels between letters.
  final double? letterSpacing;

  /// Line height as a multiple of the font size (Flutter's `height`); null
  /// is the font's own line height.
  final double? height;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;

  /// Fixed-width digits (`FontFeature.tabularFigures`).
  final bool? tabularFigures;

  /// Text shadows (drop shadows only).
  final List<Effect> shadows;

  bool get isEmpty => this == empty;

  /// [other]'s non-null fields over this style's.
  TextStyle merge(TextStyle? other) {
    if (other == null) return this;
    return TextStyle(
      fontFamily: other.fontFamily ?? fontFamily,
      fontWeight: other.fontWeight ?? fontWeight,
      fontStyle: other.fontStyle ?? fontStyle,
      fontSize: other.fontSize ?? fontSize,
      color: other.color ?? (other.foreground != null ? null : color),
      foreground: other.foreground ?? (other.color != null ? null : foreground),
      letterSpacing: other.letterSpacing ?? letterSpacing,
      height: other.height ?? height,
      decoration: other.decoration ?? decoration,
      decorationColor: other.decorationColor ?? decorationColor,
      decorationStyle: other.decorationStyle ?? decorationStyle,
      decorationThickness: other.decorationThickness ?? decorationThickness,
      tabularFigures: other.tabularFigures ?? tabularFigures,
      shadows: other.shadows.isNotEmpty ? other.shadows : shadows,
    );
  }

  static TextStyle fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return empty;
    final weight = readInt(m['fontWeight']);
    return TextStyle(
      fontFamily: readString(m['fontFamily']),
      fontWeight: weight == null ? null : ((weight / 100).round().clamp(1, 9) * 100),
      fontStyle: m['fontStyle'] == null ? null : readEnum(FontStyle.values, m['fontStyle'], FontStyle.normal),
      fontSize: readDouble(m['fontSize']).let((v) => v != null && v > 0 ? v : null),
      color: Color.fromJson(m['color']),
      foreground: Paint.fromJson(m['foreground']),
      letterSpacing: readDouble(m['letterSpacing']),
      height: readDouble(m['height']).let((v) => v != null && v > 0 ? v : null),
      decoration:
          m['decoration'] == null ? null : readEnum(TextDecoration.values, m['decoration'], TextDecoration.none),
      decorationColor: Color.fromJson(m['decorationColor']),
      decorationStyle: m['decorationStyle'] == null
          ? null
          : readEnum(TextDecorationStyle.values, m['decorationStyle'], TextDecorationStyle.solid),
      decorationThickness: readDouble(m['decorationThickness']),
      tabularFigures: readBool(m['tabularFigures']),
      shadows: Effect.listFromJson(m['shadows']),
    );
  }

  Json toJson() => {
        if (fontFamily != null) 'fontFamily': fontFamily,
        if (fontWeight != null) 'fontWeight': fontWeight,
        if (fontStyle != null) 'fontStyle': fontStyle!.name,
        if (fontSize != null) 'fontSize': writeDouble(fontSize!),
        if (color != null) 'color': color!.toJson(),
        if (foreground != null) 'foreground': foreground!.toJson(),
        if (letterSpacing != null) 'letterSpacing': writeDouble(letterSpacing!),
        // Full precision: a pixel line height over the font size.
        if (height != null) 'height': height,
        if (decoration != null) 'decoration': decoration!.name,
        if (decorationColor != null) 'decorationColor': decorationColor!.toJson(),
        if (decorationStyle != null) 'decorationStyle': decorationStyle!.name,
        if (decorationThickness != null) 'decorationThickness': writeDouble(decorationThickness!),
        if (tabularFigures != null) 'tabularFigures': tabularFigures,
        if (shadows.isNotEmpty) 'shadows': [for (final e in shadows) e.toJson()],
      };

  @override
  bool operator ==(Object other) =>
      other is TextStyle &&
      other.fontFamily == fontFamily &&
      other.fontWeight == fontWeight &&
      other.fontStyle == fontStyle &&
      other.fontSize == fontSize &&
      other.color == color &&
      other.foreground == foreground &&
      other.letterSpacing == letterSpacing &&
      other.height == height &&
      other.decoration == decoration &&
      other.decorationColor == decorationColor &&
      other.decorationStyle == decorationStyle &&
      other.decorationThickness == decorationThickness &&
      other.tabularFigures == tabularFigures &&
      listEquals(other.shadows, shadows);

  @override
  int get hashCode => Object.hash(fontFamily, fontWeight, fontStyle, fontSize, color, foreground, letterSpacing,
      height, decoration, decorationColor, decorationStyle, decorationThickness, tabularFigures);

  @override
  String toString() => 'TextStyle(${toJson()})';
}

/// A styled range of a text's characters, `[start, end)`.
@immutable
final class TextRun {
  const TextRun(this.start, this.end, this.style, {this.link});

  final int start, end;
  final TextStyle style;

  /// A URL the run opens when tapped.
  final String? link;

  static TextRun? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final start = readInt(m['start']) ?? 0, end = readInt(m['end']) ?? 0;
    if (end < start) return null;
    return TextRun(start, end, TextStyle.fromJson(m['style']), link: readString(m['link']));
  }

  Json toJson() => {
        'start': start,
        'end': end,
        if (!style.isEmpty) 'style': style.toJson(),
        if (link != null && link!.isNotEmpty) 'link': link,
      };

  @override
  bool operator ==(Object other) =>
      other is TextRun && other.start == start && other.end == end && other.style == style && other.link == link;

  @override
  int get hashCode => Object.hash(start, end, style, link);
}
