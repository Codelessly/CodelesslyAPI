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
    this.fontFeatures = const [],
    this.leadingDistribution,
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

  /// Fixed-width digits (`OpenTypeFeature.tabularFigures`).
  final bool? tabularFigures;

  /// OpenType feature settings (`TextStyle.fontFeatures`): a four-character
  /// tag alone turns it on (`"lnum"`, `"ss01"`), `tag=value` sets it
  /// (`"liga=0"` turns ligatures off, `"salt=2"`). A later entry for a tag
  /// wins; `tnum` is the same as [tabularFigures].
  final List<String> fontFeatures;

  /// Where a line's extra (or missing) height goes (`TextStyle
  /// .leadingDistribution`); null is Flutter's default, proportional.
  final TextLeadingDistribution? leadingDistribution;

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
      fontFeatures: other.fontFeatures.isNotEmpty ? other.fontFeatures : fontFeatures,
      leadingDistribution: other.leadingDistribution ?? leadingDistribution,
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
      fontFeatures: readFontFeatures(m['fontFeatures']),
      leadingDistribution: m['leadingDistribution'] == null
          ? null
          : readEnum(TextLeadingDistribution.values, m['leadingDistribution'], TextLeadingDistribution.proportional),
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
        if (fontFeatures.isNotEmpty) 'fontFeatures': fontFeatures,
        if (leadingDistribution != null) 'leadingDistribution': leadingDistribution!.name,
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
      listEquals(other.fontFeatures, fontFeatures) &&
      other.leadingDistribution == leadingDistribution &&
      listEquals(other.shadows, shadows);

  @override
  int get hashCode => Object.hash(fontFamily, fontWeight, fontStyle, fontSize, color, foreground, letterSpacing,
      height, decoration, decorationColor, decorationStyle, decorationThickness, tabularFigures, Object.hashAll(fontFeatures), leadingDistribution);

  @override
  String toString() => 'TextStyle(${toJson()})';
}

/// An OpenType feature setting: a four-character [tag] and its [value]
/// (1 on, 0 off, n an alternate). JSON is a string, `"lnum"` or `"liga=0"`.
@immutable
final class OpenTypeFeature {
  const OpenTypeFeature(this.tag, [this.value = 1]);

  final String tag;
  final int value;

  static final RegExp _tag = RegExp(r'^[\x20-\x7E]{4}$');

  /// One setting from `"lnum"`, `"liga = 0"` or `{"tag": "liga", "value":
  /// 0}` (`true`/`false` are 1/0), or null when it isn't one.
  static OpenTypeFeature? tryParse(Object? entry) {
    String? tag;
    int? value;
    switch (entry) {
      case final String text:
        final t = text.trim(), eq = t.indexOf('=');
        tag = eq < 0 ? t : t.substring(0, eq).trim();
        value = eq < 0 ? 1 : int.tryParse(t.substring(eq + 1).trim());
      case final Map m:
        tag = (m['tag'] as Object?) is String ? (m['tag'] as String).trim() : null;
        final v = m['value'] ?? 1;
        value = switch (v) {
          true => 1,
          false => 0,
          final num n when n == n.roundToDouble() => n.toInt(),
          final String s => int.tryParse(s.trim()),
          _ => null,
        };
    }
    if (tag == null || value == null || value < 0 || !_tag.hasMatch(tag)) return null;
    return OpenTypeFeature(tag, value);
  }

  /// The settings a style's [TextStyle.fontFeatures] list holds, one per
  /// tag (the last wins), in order of first appearance.
  static List<OpenTypeFeature> resolve(Iterable<String> entries) {
    final byTag = <String, OpenTypeFeature>{};
    for (final e in entries) {
      if (tryParse(e) case final OpenTypeFeature f) byTag[f.tag] = f;
    }
    return byTag.values.toList();
  }

  @override
  bool operator ==(Object other) => other is OpenTypeFeature && other.tag == tag && other.value == value;

  @override
  int get hashCode => Object.hash(tag, value);

  /// As stored: `"lnum"` when on, else `"liga=0"`.
  @override
  String toString() => value == 1 ? tag : '$tag=$value';
}

/// A `fontFeatures` list read loosely: a list of settings (strings or
/// `{tag, value}` maps) or one string of them separated by commas or spaces,
/// as canonical strings; settings that aren't valid are dropped.
List<String> readFontFeatures(Object? json) {
  final Iterable<Object?> entries = switch (json) {
    final String s => s.split(RegExp(r'[,\s]+')).where((e) => e.isNotEmpty),
    final List l => l,
    _ => const [],
  };
  return [
    for (final e in entries)
      if (OpenTypeFeature.tryParse(e) case final OpenTypeFeature f) f.toString(),
  ];
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
