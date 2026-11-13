import 'package:meta/meta.dart';

import 'json.dart';
import 'values/color.dart';
import 'values/text.dart';

/// A project's theme as published: what the runtime draws itself (dialogs,
/// toasts, the loading and error screens), what layouts read at run time
/// (`${theme.primary}`, `${theme.colors.brand}`, `${theme.text.title.fontSize}`,
/// `${theme.isDark}`) and what an app can read to match its own widgets to a
/// layout. Every token is optional.
///
/// [dark] holds the colors to use in dark mode where they differ: the
/// runtime reads [forBrightness] (`dark: true`), so a binding to
/// `${theme.surface}` shows the dark surface on a device in dark mode.
/// Older runtimes ignore [colors], [textStyles] and [dark].
@immutable
final class ThemeTokens {
  const ThemeTokens({
    this.primary,
    this.onPrimary,
    this.surface,
    this.onSurface,
    this.error,
    this.success,
    this.warning,
    this.fontFamily,
    this.titleFontFamily,
    this.radius,
    this.buttonRadius,
    this.colors = const {},
    this.textStyles = const {},
    this.dark,
    this.naturalLineHeight,
  });

  /// Primary buttons and info toasts.
  final Color? primary;

  /// Text on [primary].
  final Color? onPrimary;

  /// Dialog backgrounds.
  final Color? surface;

  /// Text on [surface].
  final Color? onSurface;

  /// Destructive buttons and error toasts.
  final Color? error;

  /// Success toasts.
  final Color? success;

  /// Warning toasts.
  final Color? warning;

  /// Font family of body text and buttons.
  final String? fontFamily;

  /// Font family of titles.
  final String? titleFontFamily;

  /// Corner radius of dialogs.
  final double? radius;

  /// Corner radius of buttons.
  final double? buttonRadius;

  /// Every named color of the project by key ([themeKey] of its name:
  /// "Brand Blue" is `brandBlue`), read as `${theme.colors.brandBlue}`.
  final Map<String, Color> colors;

  /// Every named text style by key, read as `${theme.text.title.fontSize}`.
  final Map<String, TextStyle> textStyles;

  /// The colors for dark mode: the tokens and [colors] that differ from the
  /// light ones (its other fields are not used).
  final ThemeTokens? dark;

  /// Whether text without a line height takes its font's own (Flutter's
  /// default) rather than the SDK's 1.33 ([StyleSheet.naturalLineHeight]).
  final bool? naturalLineHeight;

  static const ThemeTokens none = ThemeTokens();

  /// Whether [dark] gives any color.
  bool get hasDark => dark != null && !dark!.isEmpty;

  /// These tokens for a light or [dark] screen: in dark mode each color
  /// [dark] gives over the light one.
  ThemeTokens forBrightness({required bool dark}) {
    final d = this.dark;
    if (!dark || d == null) return this;
    return ThemeTokens(
      primary: d.primary ?? primary,
      onPrimary: d.onPrimary ?? onPrimary,
      surface: d.surface ?? surface,
      onSurface: d.onSurface ?? onSurface,
      error: d.error ?? error,
      success: d.success ?? success,
      warning: d.warning ?? warning,
      fontFamily: fontFamily,
      titleFontFamily: titleFontFamily,
      radius: radius,
      buttonRadius: buttonRadius,
      colors: {...colors, ...d.colors},
      textStyles: textStyles,
      naturalLineHeight: naturalLineHeight,
    );
  }

  /// The key a style named [name] has in [colors] and [textStyles]: its
  /// words in camel case ("On Primary" is `onPrimary`, "Title / Large" is
  /// `titleLarge`).
  static String themeKey(String name) {
    final words = name.split(RegExp('[^A-Za-z0-9]+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    return [
      _lowerFirst(words.first),
      for (final w in words.skip(1)) w[0].toUpperCase() + w.substring(1),
    ].join();
  }

  static String _lowerFirst(String w) =>
      w == w.toUpperCase() ? w.toLowerCase() : w[0].toLowerCase() + w.substring(1);

  /// Whether no token is set.
  bool get isEmpty => this == none;

  static ThemeTokens fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return none;
    return ThemeTokens(
      primary: Color.fromJson(m['primary']),
      onPrimary: Color.fromJson(m['onPrimary']),
      surface: Color.fromJson(m['surface']),
      onSurface: Color.fromJson(m['onSurface']),
      error: Color.fromJson(m['error']),
      success: Color.fromJson(m['success']),
      warning: Color.fromJson(m['warning']),
      fontFamily: readString(m['fontFamily']),
      titleFontFamily: readString(m['titleFontFamily']),
      radius: readDouble(m['radius']),
      buttonRadius: readDouble(m['buttonRadius']),
      colors: {
        for (final e in (readMap(m['colors']) ?? const {}).entries)
          if (Color.fromJson(e.value) case final Color c) e.key: c,
      },
      textStyles: {
        for (final e in (readMap(m['textStyles']) ?? const {}).entries)
          if (readMap(e.value) != null) e.key: TextStyle.fromJson(e.value),
      },
      dark: m['dark'] == null ? null : fromJson(m['dark']),
      naturalLineHeight: readBool(m['naturalLineHeight']),
    );
  }

  Json toJson() {
    final j = <String, Object?>{};
    put(j, 'primary', primary?.toJson());
    put(j, 'onPrimary', onPrimary?.toJson());
    put(j, 'surface', surface?.toJson());
    put(j, 'onSurface', onSurface?.toJson());
    put(j, 'error', error?.toJson());
    put(j, 'success', success?.toJson());
    put(j, 'warning', warning?.toJson());
    put(j, 'fontFamily', fontFamily);
    put(j, 'titleFontFamily', titleFontFamily);
    put(j, 'radius', radius?.let(writeDouble));
    put(j, 'buttonRadius', buttonRadius?.let(writeDouble));
    if (colors.isNotEmpty) j['colors'] = {for (final e in colors.entries) e.key: e.value.toJson()};
    if (textStyles.isNotEmpty) j['textStyles'] = {for (final e in textStyles.entries) e.key: e.value.toJson()};
    if (dark != null && !dark!.isEmpty) j['dark'] = dark!.toJson();
    put(j, 'naturalLineHeight', naturalLineHeight);
    return j;
  }

  @override
  bool operator ==(Object other) =>
      other is ThemeTokens &&
      other.primary == primary &&
      other.onPrimary == onPrimary &&
      other.surface == surface &&
      other.onSurface == onSurface &&
      other.error == error &&
      other.success == success &&
      other.warning == warning &&
      other.fontFamily == fontFamily &&
      other.titleFontFamily == titleFontFamily &&
      other.radius == radius &&
      other.buttonRadius == buttonRadius &&
      jsonEquality.equals(other.colors, colors) &&
      jsonEquality.equals(other.textStyles, textStyles) &&
      other.dark == dark &&
      other.naturalLineHeight == naturalLineHeight;

  @override
  int get hashCode => Object.hash(primary, onPrimary, surface, onSurface, error, success, warning, fontFamily,
      titleFontFamily, radius, buttonRadius, jsonEquality.hash(colors), jsonEquality.hash(textStyles), dark, naturalLineHeight);
}
