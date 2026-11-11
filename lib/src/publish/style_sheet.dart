// A project's style sheet: named text styles and color styles the editor
// applies to nodes (presets: a node keeps the values, not a link), and the
// app's theme ([ThemeTokens]) read from them by name.
import '../json.dart';
import '../values/color.dart';
import '../values/paint.dart';
import '../values/text.dart';
import 'theme.dart';

/// A named text style.
final class NamedTextStyle {
  const NamedTextStyle({required this.id, required this.name, this.style = TextStyle.empty});

  final String id;
  final String name;
  final TextStyle style;

  static NamedTextStyle? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id']);
    if (m == null || id == null || id.isEmpty) return null;
    return NamedTextStyle(id: id, name: readString(m['name']) ?? '', style: TextStyle.fromJson(m['style']));
  }

  Json toJson() => {'id': id, 'name': name, 'style': style.toJson()};

  @override
  bool operator ==(Object other) => other is NamedTextStyle && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}

/// A named color style: a paint (a solid color or a gradient), and
/// optionally the [dark] paint it has in dark mode.
///
/// ```json
/// {"id": "c1", "name": "Surface", "paint": {"color": "#FFFFFFFF"}, "dark": {"color": "#FF121212"}}
/// ```
///
/// A node the style is applied to keeps the light values; one whose color
/// binds to the theme (`${theme.surface}`, `${theme.colors.brandBlue}`)
/// follows the device's mode at run time ([StyleSheet.theme]).
final class NamedColorStyle {
  const NamedColorStyle({required this.id, required this.name, required this.paint, this.dark});

  final String id;
  final String name;
  final Paint paint;

  /// The paint in dark mode; null: [paint] in both modes.
  final Paint? dark;

  /// The paint's color with its opacity, for a solid paint.
  Color? get color => _solid(paint);

  /// The dark paint's color with its opacity, for a solid dark paint.
  Color? get darkColor => dark == null ? null : _solid(dark!);

  static Color? _solid(Paint paint) {
    final c = paint.color;
    if (c == null) return null;
    return paint.opacity >= 1 ? c : c.withAlpha((c.alpha * paint.opacity).round());
  }

  static NamedColorStyle? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id']);
    final paint = Paint.fromJson(m?['paint']);
    if (m == null || id == null || id.isEmpty || paint == null) return null;
    return NamedColorStyle(id: id, name: readString(m['name']) ?? '', paint: paint, dark: Paint.fromJson(m['dark']));
  }

  Json toJson() => {'id': id, 'name': name, 'paint': paint.toJson(), if (dark != null) 'dark': dark!.toJson()};

  @override
  bool operator ==(Object other) => other is NamedColorStyle && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}

/// A project's style sheet (`style_sheets/{projectId}`, `schema: 2`).
final class StyleSheet {
  const StyleSheet({
    this.textStyles = const [],
    this.colorStyles = const [],
    this.defaultTextStyle,
    this.defaultColorStyle,
    this.extra = const {},
  });

  static const int schema = 2;

  final List<NamedTextStyle> textStyles;
  final List<NamedColorStyle> colorStyles;

  /// The ids of the styles new text and new fills start from.
  final String? defaultTextStyle, defaultColorStyle;

  /// Keys this version doesn't model (privacy, timestamps), round-tripped.
  final Json extra;

  static const _keys = {'schema', 'textStyles', 'colorStyles', 'defaultTextStyle', 'defaultColorStyle'};

  static StyleSheet fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    return StyleSheet(
      textStyles: [...?readList(m['textStyles'])?.map(NamedTextStyle.fromJson).nonNulls],
      colorStyles: [...?readList(m['colorStyles'])?.map(NamedColorStyle.fromJson).nonNulls],
      defaultTextStyle: readString(m['defaultTextStyle']),
      defaultColorStyle: readString(m['defaultColorStyle']),
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  /// Whether [json] is a style sheet in the current format.
  static bool isCurrentSchema(Object? json) => readMap(json)?['schema'] == schema;

  Json toJson() => {
        ...extra,
        'schema': schema,
        'textStyles': [for (final s in textStyles) s.toJson()],
        'colorStyles': [for (final s in colorStyles) s.toJson()],
        'defaultTextStyle': ?defaultTextStyle,
        'defaultColorStyle': ?defaultColorStyle,
      };

  StyleSheet copyWith({List<NamedTextStyle>? textStyles, List<NamedColorStyle>? colorStyles}) => StyleSheet(
        textStyles: textStyles ?? this.textStyles,
        colorStyles: colorStyles ?? this.colorStyles,
        defaultTextStyle: defaultTextStyle,
        defaultColorStyle: defaultColorStyle,
        extra: extra,
      );

  /// The app's theme, from the styles by name: color styles named Primary,
  /// On Primary, Surface, On Surface, Error, Success and Warning, and text
  /// styles named Body and Title (or Heading) for the fonts; every solid
  /// color style and every text style by key ([ThemeTokens.colors],
  /// [ThemeTokens.textStyles]); and the dark colors of the styles that
  /// have one ([ThemeTokens.dark]).
  ThemeTokens get theme {
    String key(String label) => label.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
    NamedColorStyle? named(String name) => colorStyles.where((s) => key(s.name) == name).firstOrNull;
    Color? color(String name) => named(name)?.color;
    Color? darkColor(String name) => named(name)?.darkColor;
    String? font(List<String> names) =>
        textStyles.where((s) => names.contains(key(s.name))).firstOrNull?.style.fontFamily;
    Map<String, Color> byKey(Color? Function(NamedColorStyle) of) => {
          for (final s in colorStyles)
            if ((ThemeTokens.themeKey(s.name), of(s)) case (final k, final Color c) when k.isNotEmpty) k: c,
        };
    final dark = ThemeTokens(
      primary: darkColor('primary'),
      onPrimary: darkColor('onprimary'),
      surface: darkColor('surface'),
      onSurface: darkColor('onsurface'),
      error: darkColor('error'),
      success: darkColor('success'),
      warning: darkColor('warning'),
      colors: byKey((s) => s.darkColor),
    );
    return ThemeTokens(
      primary: color('primary'),
      onPrimary: color('onprimary'),
      surface: color('surface'),
      onSurface: color('onsurface'),
      error: color('error'),
      success: color('success'),
      warning: color('warning'),
      fontFamily: font(const ['body', 'text']),
      titleFontFamily: font(const ['title', 'heading']),
      colors: byKey((s) => s.color),
      textStyles: {
        for (final s in textStyles)
          if (ThemeTokens.themeKey(s.name) case final k when k.isNotEmpty) k: s.style,
      },
      dark: dark.isEmpty ? null : dark,
    );
  }
}
