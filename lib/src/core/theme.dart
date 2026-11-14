import 'package:meta/meta.dart';

import 'behaviors.dart' show mergePatch;
import 'breakpoints.dart';
import 'json.dart';
import 'media.dart';
import 'theme_refs.dart';
import 'values/paint.dart' show Effect, listEquals;
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
/// [mode] is the site's light or dark choice (Flutter's `MaterialApp.themeMode`):
/// `system` follows the device; a `setThemeMode` action changes it at run
/// time. Older runtimes ignore [colors], [textStyles], [dark] and [mode].
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
    this.media = const [],
    this.mode = ThemeMode.system,
    this.spacing = const {},
    this.radii = const {},
    this.sizes = const {},
    this.shadows = const {},
    this.durations = const {},
    this.curves = const {},
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

  /// Every named text style by key, read as `${theme.text.title.fontSize}`
  /// and named by a text's style (`"style": "title"`, or `{"from": "title",
  /// ...}` to change some of its fields). A style may itself start `from`
  /// another and name [colors]; [textStyle] gives it resolved.
  final Map<String, TextStyle> textStyles;

  /// The theme by screen size, as CSS media queries over custom properties:
  /// each rule's `patch` is a theme's JSON (`{"textStyles": {"display":
  /// {"fontSize": 40}}, "colors": {...}}`) merged over this one while the
  /// screen meets its conditions ([atScreen]). A type scale that changes at
  /// a breakpoint is written once here, not on every text.
  final List<MediaRule> media;

  /// The colors for dark mode: the tokens and [colors] that differ from the
  /// light ones (its other fields are not used).
  final ThemeTokens? dark;

  /// Which of the light and [dark] colors a site starts in (Flutter's
  /// `ThemeMode`): `system` follows the device, `light` and `dark` are fixed.
  /// A `setThemeMode` action changes it while the site runs; `${theme.mode}`
  /// reads it and `${theme.isDark}` whether the screen is dark.
  final ThemeMode mode;

  /// The spacing scale: gaps and paddings by name (`{"1": 4, "2": 8, "3":
  /// 12}` or `{"sm": 8, "md": 16}`), read as `${theme.spacing.md}`.
  /// Flutter has no spacing token; a design system names its steps here.
  final Map<String, double> spacing;

  /// Corner radii by name (`{"control": 7, "panel": 8, "dialog": 12}`;
  /// Flutter's `Radius.circular`), read as `${theme.radii.panel}`.
  final Map<String, double> radii;

  /// Other lengths by name: a control scale's heights (`{"compact": 28,
  /// "large": 44}`), icon sizes, a panel's width; read as
  /// `${theme.sizes.compact}`.
  final Map<String, double> sizes;

  /// Shadows by name (Flutter's `BoxShadow` lists, as `kElevationToShadow`
  /// gives one per elevation): each a list of drop shadows as
  /// `decoration.effects` takes them, read as `${theme.shadows.level3}`.
  /// [dark] may give other shadows for dark mode.
  final Map<String, List<Effect>> shadows;

  /// Durations in milliseconds by name (Flutter's `Durations`: `short2`,
  /// `medium1`...; a design system's own names), read as
  /// `${theme.durations.medium}`.
  final Map<String, int> durations;

  /// Easing curves by name (Flutter's `Curves`: `easeOut`, `easeInOut`...),
  /// read as `${theme.curves.standard}`.
  final Map<String, String> curves;

  /// The keys of the named scales ([spacing], [radii], [sizes], [shadows],
  /// [durations], [curves]) with their names: what `${theme.<scale>.<name>}`
  /// may read.
  Map<String, Iterable<String>> get scaleNames => {
        'spacing': spacing.keys,
        'radii': radii.keys,
        'sizes': sizes.keys,
        'shadows': shadows.keys,
        'durations': durations.keys,
        'curves': curves.keys,
      };

  /// These tokens with [over]'s over them, field by field (a JSON merge
  /// patch of the theme): a site's theme over its design system's tokens.
  ThemeTokens mergedWith(ThemeTokens over) {
    if (over.isEmpty) return this;
    if (isEmpty) return over;
    return fromJson(mergePatch(toJson(), over.toJson()));
  }

  static const ThemeTokens none = ThemeTokens();

  /// The color named [name]: a key of [colors], else a role (`primary`,
  /// `onSurface`...). A color may name another (`"accent": "ember"`).
  Color? color(String name) {
    var c = colors[name] ?? _role(name);
    for (var i = 0; i < 8 && c != null && c.name != null; i++) {
      c = colors[c.name!] ?? _role(c.name!);
    }
    return c?.name == null ? c : null;
  }

  Color? _role(String name) => switch (name) {
        'primary' => primary,
        'onPrimary' => onPrimary,
        'surface' => surface,
        'onSurface' => onSurface,
        'error' => error,
        'success' => success,
        'warning' => warning,
        _ => null,
      };

  /// The roles (Flutter's `ColorScheme` names: [primary], [onPrimary],
  /// [surface], [onSurface], [error], and [success], [warning]) as colours:
  /// a role that names a theme colour (`"primary": "forest"`) is that
  /// colour, through any chain of names, as any colour naming another is. A
  /// role whose name the theme does not have is null. Controls and the
  /// runtime read the roles through this. A role written inside [colors]
  /// (`"colors": {"primary": ...}`) is not a role: validation reports it
  /// (`theme_role_in_colors`).
  ThemeTokens resolvedRoles() {
    Color? r(Color? c) {
      if (c == null || c.name == null) return c;
      var at = c;
      for (var i = 0; i < 8 && at.name != null; i++) {
        final next = colors[at.name!] ?? _role(at.name!);
        if (next == null) return null;
        at = next;
      }
      return at.name == null ? at : null;
    }

    final roles = [primary, onPrimary, surface, onSurface, error, success, warning];
    if (roles.every((c) => c == null || c.name == null)) return this;
    return ThemeTokens(
      primary: r(primary),
      onPrimary: r(onPrimary),
      surface: r(surface),
      onSurface: r(onSurface),
      error: r(error),
      success: r(success),
      warning: r(warning),
      fontFamily: fontFamily,
      titleFontFamily: titleFontFamily,
      radius: radius,
      buttonRadius: buttonRadius,
      colors: colors,
      textStyles: textStyles,
      dark: dark,
      media: media,
      mode: mode,
      spacing: spacing,
      radii: radii,
      sizes: sizes,
      shadows: shadows,
      durations: durations,
      curves: curves,
    );
  }

  /// The role names ([resolvedRoles]).
  static const roleNames = ['primary', 'onPrimary', 'surface', 'onSurface', 'error', 'success', 'warning'];

  /// Every name [color] reads.
  Iterable<String> get colorNames => {
        ...colors.keys,
        for (final r in const ['primary', 'onPrimary', 'surface', 'onSurface', 'error', 'success', 'warning'])
          if (_role(r) != null) r,
      };

  /// The text style named [name], resolved: the styles it starts [from]
  /// merged in order (`TextStyle.merge`), its color names read from
  /// [colors]. Null when there is no such style (or it starts from itself).
  TextStyle? textStyle(String name) => _resolved(name, const {});

  TextStyle? _resolved(String name, Set<String> seen) {
    final own = textStyles[name];
    if (own == null || seen.contains(name)) return null;
    final from = own.from;
    final base = from == null ? TextStyle.empty : _resolved(from, {...seen, name});
    if (base == null) return null;
    return base.merge(resolveStyleColors(own, color)).withoutFrom();
  }

  /// These tokens on a screen [width] × [height]: [media] rules that hold
  /// merged over them in order (a JSON merge patch of the theme). Itself
  /// when none holds.
  ThemeTokens atScreen(double width, double? height, Breakpoints breakpoints) {
    if (media.isEmpty) return this;
    Json? merged;
    for (final r in media) {
      if (!r.holds(width, height, breakpoints)) continue;
      merged = mergePatch(merged ?? (toJson()..remove('media')), r.patch);
    }
    if (merged == null) return this;
    return fromJson(merged);
  }

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
      media: media,
      mode: mode,
      spacing: spacing,
      radii: radii,
      sizes: sizes,
      shadows: {...shadows, ...d.shadows},
      durations: durations,
      curves: curves,
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
      media: MediaRule.listFromJson(m['media']),
      mode: readEnum(ThemeMode.values, m['mode'], ThemeMode.system),
      spacing: _numbers(m['spacing']),
      radii: _numbers(m['radii']),
      sizes: _numbers(m['sizes']),
      shadows: {
        for (final e in (readMap(m['shadows']) ?? const {}).entries)
          if (readList(e.value) != null) e.key: Effect.listFromJson(e.value),
      },
      durations: {
        for (final e in (readMap(m['durations']) ?? const {}).entries)
          if (readDouble(e.value) case final double v) e.key: v.round(),
      },
      curves: {
        for (final e in (readMap(m['curves']) ?? const {}).entries)
          if (readString(e.value) case final String v) e.key: v,
      },
    );
  }

  static Map<String, double> _numbers(Object? json) => {
        for (final e in (readMap(json) ?? const {}).entries)
          if (readDouble(e.value) case final double v) e.key: v,
      };

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
    if (media.isNotEmpty) j['media'] = [for (final r in media) r.toJson()];
    if (mode != ThemeMode.system) j['mode'] = mode.name;
    if (spacing.isNotEmpty) j['spacing'] = {for (final e in spacing.entries) e.key: writeDouble(e.value)};
    if (radii.isNotEmpty) j['radii'] = {for (final e in radii.entries) e.key: writeDouble(e.value)};
    if (sizes.isNotEmpty) j['sizes'] = {for (final e in sizes.entries) e.key: writeDouble(e.value)};
    if (shadows.isNotEmpty) j['shadows'] = {for (final e in shadows.entries) e.key: [for (final x in e.value) x.toJson()]};
    if (durations.isNotEmpty) j['durations'] = durations;
    if (curves.isNotEmpty) j['curves'] = curves;
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
      listEquals(other.media, media) &&
      other.mode == mode &&
      jsonEquality.equals(other.spacing, spacing) &&
      jsonEquality.equals(other.radii, radii) &&
      jsonEquality.equals(other.sizes, sizes) &&
      jsonEquality.equals(other.shadows, shadows) &&
      jsonEquality.equals(other.durations, durations) &&
      jsonEquality.equals(other.curves, curves);

  @override
  int get hashCode => Object.hash(primary, onPrimary, surface, onSurface, error, success, warning, fontFamily,
      titleFontFamily, radius, buttonRadius, jsonEquality.hash(colors), jsonEquality.hash(textStyles), dark, Object.hashAll(media), mode,
      Object.hash(jsonEquality.hash(spacing), jsonEquality.hash(radii), jsonEquality.hash(sizes), jsonEquality.hash(shadows),
          jsonEquality.hash(durations), jsonEquality.hash(curves)));
}

/// Whether a site shows its light or dark colors (Flutter's `ThemeMode`,
/// as `MaterialApp.themeMode` takes it).
enum ThemeMode {
  /// The device's setting (`MediaQuery.platformBrightnessOf`).
  system,

  /// Always the light colors.
  light,

  /// Always the [ThemeTokens.dark] colors.
  dark;

  /// Whether a screen is dark in this mode on a device whose own setting is
  /// [platformDark].
  bool isDark({required bool platformDark}) => this == dark || (this == system && platformDark);

  /// The mode [json] names (`"system"`, `"light"`, `"dark"`, any case), else
  /// null.
  static ThemeMode? tryParse(Object? json) {
    final s = json is String ? json.trim().toLowerCase() : null;
    for (final m in values) {
      if (m.name == s) return m;
    }
    return null;
  }
}
