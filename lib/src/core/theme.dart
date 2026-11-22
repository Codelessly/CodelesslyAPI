import 'dart:math' as math;

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
    this.iconStyle,
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

  /// The style a Material icon written by its bare name is drawn in by a
  /// UI written in the notation (`outlined`, `rounded`, `sharp`); null:
  /// filled, as written.
  final String? iconStyle;

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

  /// These tokens (a design system's) with a site's theme over them
  /// ([mergedWith]), and what the design system makes from its accent made
  /// from the site's instead. A site that gives its own `primary` (or, where
  /// the design system's `accent` is its primary, its own `colors.accent`)
  /// and nothing else gets:
  ///
  /// * every color of the design system that is its primary at some opacity
  ///   (a selected row's tint, the focus ring, a tinted border) as the
  ///   site's primary at that opacity;
  /// * the `info` color and its tints (an information banner), which wear
  ///   the accent of a re-branded site;
  /// * each shade of the accent it does not name (a color of the accent's
  ///   hue named after it: `accentDeep`, `accentBright`) in the site's hue,
  ///   at the lightness the design system gives it;
  /// * in [dark], when the site gives no `dark.primary`, a primary made from
  ///   its light one (a little lighter, as an accent is on a dark surface),
  ///   and the same three for the dark colors.
  ///
  /// A color the site names itself, light or dark, is the site's. A site
  /// that gives its own `fontFamily` gets the design system's text styles
  /// of its default family in that family. Its `surface`, `onSurface`,
  /// `titleFontFamily` and `radius` reach what the design system draws
  /// under names of its own (its page ground, its ink, its headings, its
  /// scale of radii): [_withSiteRoles].
  ThemeTokens withSiteTheme(ThemeTokens site) => site.isEmpty || isEmpty ? mergedWith(site) : _withSiteRoles(_withSiteAccent(site), site);

  ThemeTokens _withSiteAccent(ThemeTokens site) {
    var merged = mergedWith(site);
    if (site.isEmpty || isEmpty) return merged;
    // The site's own font: every text style of the design system written in
    // its default family is in the site's (a style the site re-families
    // itself keeps what it says). The same for the title family.
    final families = {
      if (fontFamily != null && site.fontFamily != null && site.fontFamily != fontFamily) fontFamily!: site.fontFamily!,
      if (titleFontFamily != null && site.titleFontFamily != null && site.titleFontFamily != titleFontFamily)
        titleFontFamily!: site.titleFontFamily!,
    };
    if (families.isNotEmpty) {
      final styles = <String, Object?>{
        for (final e in textStyles.entries)
          if (families[e.value.fontFamily] case final String family when site.textStyles[e.key]?.fontFamily == null) e.key: {'fontFamily': family},
      };
      if (styles.isNotEmpty) merged = fromJson(mergePatch(merged.toJson(), {'textStyles': styles}));
    }
    final from = color('primary');
    final accentIsPrimary = from != null && color('accent')?.value == from.value;
    final named = site.primary != null ? 'primary' : (accentIsPrimary && site.colors.containsKey('accent') ? 'accent' : null);
    if (from == null || named == null) return merged;
    final to = merged.color(named);
    if (to == null || _rgb(to) == _rgb(from)) return merged;

    // The names of the accent: `primary`, and each color that is it
    // (`accent`). A color named after one (`accentDeep`, `accentBright`) is
    // a shade of it.
    final roots = {'primary', for (final e in colors.entries) if (e.value.name == null && e.value.value == from.value) e.key};
    // The roles a design system makes from its accent under names of their
    // own (Desk's focus ring, a chosen row's tint, a selection, the first
    // chart color) are shades of it too: a site that names its `primary`
    // re-accents them all (the focused border of an Input, a SearchField's).
    // A root itself is one where the design system's dark accent is not its
    // dark primary (Desk's dark `accent` is a lighter indigo than its dark
    // `primary`: it stayed indigo under a site's green, on the SideButton,
    // the brand tile, the chosen view; support desk, test 11).
    bool shadeName(String name) => roots.contains(name) || _accentRoles.contains(name) || roots.any((r) => name.length > r.length && name.startsWith(r));

    Map<String, Object?> follow(Map<String, Color> base, Color was, Color now, Set<String> given, {required bool dark}) {
      final info = given.contains('info') || site.colors.containsKey('info') ? null : base['info'];
      final out = <String, Object?>{};
      for (final e in base.entries) {
        final c = e.value;
        if (c.name != null || given.contains(e.key)) continue;
        if (_rgb(c) == _rgb(was) || (info != null && info.name == null && _rgb(c) == _rgb(info))) {
          out[e.key] = Color((c.alpha << 24) | _rgb(now)).toJson();
        } else if ((shadeName(e.key) || (dark && site.colors.containsKey(e.key))) && _sameFamily(c, was)) {
          out[e.key] = _rehued(c, now, was).toJson();
        }
      }
      return out;
    }

    final patch = <String, Object?>{
      if (site.primary == null) 'primary': to.toJson(),
      'colors': follow(colors, from, to, site.colors.keys.toSet(), dark: false),
    };
    final d = dark;
    if (d != null && !d.isEmpty) {
      final wasDark = forBrightness(dark: true).color('primary') ?? from;
      final siteDark = site.dark;
      final nowDark = siteDark?.primary != null
          ? (merged.forBrightness(dark: true).color('primary') ?? to)
          : Color(0xFF000000 | _mix(_rgb(to), 0xFFFFFF, .15));
      patch['dark'] = {
        if (siteDark?.primary == null) 'primary': nowDark.toJson(),
        'colors': follow(d.colors, wasDark, nowDark, {...?siteDark?.colors.keys}, dark: true),
      };
    }
    return fromJson(mergePatch(merged.toJson(), patch));
  }

  /// [merged] (these tokens, a design system's, with [site]'s over them)
  /// with what the design system draws under names of its own made from the
  /// site's roles, where the site gives the role and not the name:
  ///
  /// * `surface`, when it is not the design system's own: the ground a page
  ///   is drawn on ([groundNames]: Cards' `page`, `pageFill` and
  ///   `primaryBackground`), light, and dark from the site's `dark.surface`.
  ///   A card, a tile and a raised panel keep the design system's color;
  /// * `onSurface`: the ink ([inkNames]) where the design system's is its
  ///   own `onSurface`;
  /// * `titleFontFamily` (with none, `fontFamily`), where the design system
  ///   has no title family of its own: its title and heading styles (a
  ///   style named for one, whatever family it is written in) that the
  ///   site does not re-family;
  /// * `radius`: each radius of the design system's scale, in the
  ///   proportion the site's radius has to the design system's (a pill
  ///   stays one; `"radius": 0` squares every corner).
  ThemeTokens _withSiteRoles(ThemeTokens merged, ThemeTokens site) {
    final light = _sideOf(this, site, merged, other: dark == null ? null : forBrightness(dark: true), otherNow: merged.forBrightness(dark: true));
    final d = dark;
    final night = d == null
        ? const <String, Object?>{}
        : _sideOf(forBrightness(dark: true), site.dark ?? none, merged.forBrightness(dark: true), other: this, otherNow: merged);
    // A design system with no title family of its own may still write its
    // headings in a second one (Cards' Inter Display): they are the site's
    // title family, or with none given its one family.
    final title = site.titleFontFamily ?? site.fontFamily;
    final styles = <String, Object?>{
      if (title != null && titleFontFamily == null)
        for (final e in textStyles.entries)
          if (_titleStyle.hasMatch(e.key) && e.value.fontFamily != title && site.textStyles[e.key]?.fontFamily == null) e.key: {'fontFamily': title},
    };
    // A style the design system has for a website's page too (`heading1`
    // and `heading1Page`): what the site says of the style it says of both.
    for (final e in site.textStyles.entries) {
      for (final tier in const ['Page', 'Wide']) {
        final name = '${e.key}$tier';
        if (textStyles.containsKey(name) && !site.textStyles.containsKey(name)) {
          styles[name] = {...?(styles[name] as Map<String, Object?>?), ...e.value.toJson()..remove('from')};
        }
      }
    }
    final was = radius, to = site.radius;
    final corners = <String, Object?>{
      if (was != null && to != null && was > 0 && to != was)
        for (final e in radii.entries)
          if (e.value < 999 && !site.radii.containsKey(e.key)) e.key: (e.value * to / was * 10).round() / 10,
    };
    final patch = <String, Object?>{
      ...light,
      if (night.isNotEmpty) 'dark': night,
      if (styles.isNotEmpty) 'textStyles': styles,
      if (corners.isNotEmpty) 'radii': corners,
    };
    return patch.isEmpty ? merged : fromJson(mergePatch(merged.toJson(), patch));
  }

  /// One side (the light colors, or the dark) of a design system under a
  /// site's theme, as a patch of that side: [base] is the design system's
  /// side, [given] what the site says of it, [now] the side after the
  /// site's accent ([_withSiteAccent]). [other] and [otherNow] are the
  /// design system's opposite side, before and after.
  ///
  /// * A `surface` as dark as the opposite side's ground and unlike this
  ///   side's (a site that writes its near-black ground as its light
  ///   `surface`) starts from the opposite side's colors, roles and
  ///   shadows: the design system's dark tints, status inks and lines.
  /// * `surface` is the ground a page is drawn on ([groundNames]) and
  ///   `onSurface` the ink; every neutral of the design system (a color on
  ///   the line from its ground to its ink: a chrome, a band, a card, a
  ///   field, a hairline, a second and a third ink, a hover) keeps its
  ///   place between the two, on the site's ground and in the site's ink. A
  ///   color lighter than a light ground (a white card on a grey page)
  ///   stays as much lighter. Hues (a status tint, a label's) stay.
  /// * Contrast is kept: an ink for text in the accent (`accentText`, a
  ///   `link`) too close to the ground is moved toward the ink until it
  ///   reads, and the color on the accent (`onPrimary`, `onAccent`) is
  ///   dark on a light accent, light on a dark one.
  static Map<String, Object?> _sideOf(ThemeTokens base, ThemeTokens given, ThemeTokens now, {ThemeTokens? other, ThemeTokens? otherNow}) {
    final colors = <String, Object?>{};
    final roles = <String, Object?>{};
    Color? groundOf(ThemeTokens t) {
      for (final n in const ['page', 'pageFill', 'primaryBackground']) {
        if (t.colors.containsKey(n)) return t.color(n);
      }
      return t.color('surface') ?? t.ground;
    }

    Color? inkOf(ThemeTokens t) => t.color('onSurface') ?? t.color('primaryText') ?? t.color('ink');
    var ref = base, cur = now;
    final surface = given.surface == null ? null : now.color('surface');
    final regrounds = surface != null && surface.value != base.color('surface')?.value;
    if (regrounds && other != null && otherNow != null) {
      final own = groundOf(base), far = groundOf(other);
      if (own != null && far != null && _isDark(surface) != _isDark(own) && _isDark(far) == _isDark(surface)) {
        ref = other;
        cur = otherNow;
        // The accent the site gives this side is this side's accent, not
        // the one the opposite side made from it.
        final made = otherNow.color('primary'), own = given.primary == null ? null : now.color('primary');
        for (final e in otherNow.colors.entries) {
          if (given.colors.containsKey(e.key)) continue;
          final c = e.value;
          colors[e.key] = (made != null && own != null && c.name == null && _rgb(c) == _rgb(made) ? Color((c.alpha << 24) | _rgb(own)) : c).toJson();
        }
        // Where this side's accent is its primary, it is the site's here too.
        if (own != null && !given.colors.containsKey('accent') && base.colors.containsKey('accent') && base.color('accent')?.value == base.color('primary')?.value) {
          colors['accent'] = own.toJson();
        }
        for (final r in const ['primary', 'onPrimary', 'onSurface', 'error', 'success', 'warning']) {
          if (given._role(r) == null && otherNow._role(r) != null) roles[r] = otherNow._role(r)!.toJson();
        }
        if (otherNow.shadows.isNotEmpty && given.shadows.isEmpty) {
          roles['shadows'] = {for (final e in otherNow.shadows.entries) e.key: [for (final x in e.value) x.toJson()]};
        }
      }
    }
    final g = groundOf(ref);
    var i = inkOf(ref);
    // A side with no ink of its own that reads on its ground (a dark side
    // that names no `onSurface`): the light or the dark end.
    if (g != null && (i == null || _contrast(i, g) < 3)) i = _isDark(g) ? const Color(0xFFF4F4F5) : const Color(0xFF18181B);
    final toG = regrounds ? surface : g;
    var toI = given.onSurface == null ? i : (now.color('onSurface') ?? i);
    final says = regrounds || given.onSurface != null;
    if (g != null && i != null && toG != null && toI != null && (says || given.primary != null)) {
      // An ink the site does not give, unreadable on the ground it gives:
      // the lighter or the darker end, whichever reads.
      if (says && given.onSurface == null && _contrast(toI, toG) < 3) {
        toI = _isDark(toG) ? const Color(0xFFF4F4F5) : const Color(0xFF18181B);
        roles['onSurface'] = toI.toJson();
      }
      final moved = toG.value != g.value || _rgb(toI) != _rgb(i);
      if (!says) {
        // Only the accent is the site's: the ground and the ink stand.
      } else if (moved) {
        for (final e in cur.colors.entries) {
          final c = e.value;
          if (c.name != null || given.colors.containsKey(e.key) || _notOfTheGround(e.key)) continue;
          if (regrounds && groundNames.contains(e.key)) {
            colors[e.key] = toG.toJson();
          } else if (_neutral(c, g, i)) {
            colors[e.key] = _regrounded(c, g, i, toG, toI).toJson();
          }
        }
      } else if (regrounds) {
        for (final n in groundNames) {
          if (cur.colors.containsKey(n) && !given.colors.containsKey(n)) colors[n] = toG.toJson();
        }
      }
      // Text in the accent that does not read on the ground.
      Color? at(String name) => colors[name] != null ? Color.fromJson(colors[name]) : cur.color(name);
      for (final n in const ['accentText', 'link', 'linkHover']) {
        if (given.colors.containsKey(n)) continue;
        final c = at(n);
        if (c == null || c.alpha != 0xFF || _contrast(c, toG) >= 3) continue;
        var out = c;
        for (var t = .1; t <= 1.0001 && _contrast(out, toG) < 4.5; t += .1) {
          out = Color(0xFF000000 | _mix(_rgb(c), _rgb(toI), t));
        }
        colors[n] = out.toJson();
      }
    }
    // What is drawn on the accent reads on it.
    Color on(Color fill, Color was) {
      if (was.alpha != 0xFF || fill.alpha != 0xFF || _contrast(was, fill) >= 3) return was;
      const lightOn = Color(0xFFFFFFFF), darkOn = Color(0xFF111111);
      return _contrast(lightOn, fill) >= _contrast(darkOn, fill) ? lightOn : darkOn;
    }

    final primary = roles['primary'] != null ? Color.fromJson(roles['primary']) : cur.color('primary');
    if (primary != null && given.onPrimary == null) {
      if (cur.color('onPrimary') case final Color was) {
        final c = on(primary, was);
        if (c.value != was.value) roles['onPrimary'] = c.toJson();
      }
    }
    final accent = colors['accent'] != null ? Color.fromJson(colors['accent']) : cur.color('accent');
    if (accent != null && !given.colors.containsKey('onAccent') && cur.colors.containsKey('onAccent')) {
      final was = cur.color('onAccent');
      if (was != null) {
        final c = on(accent, was);
        if (c.value != was.value) colors['onAccent'] = c.toJson();
      }
    }
    return {...roles, if (colors.isNotEmpty) 'colors': colors};
  }

  /// A color that is not a tone of the ground whatever its value: what is
  /// drawn on a fill of its own (`onAccent`, `onPrimary`), a scrim, a shadow.
  static bool _notOfTheGround(String name) =>
      RegExp(r'^on[A-Z]').hasMatch(name) || name.toLowerCase().contains('scrim') || name.toLowerCase().contains('shadow');

  static double _luma(Color c) => (0.2126 * c.red + 0.7152 * c.green + 0.0722 * c.blue) / 255;

  static bool _isDark(Color c) => _luma(c) < 0.35;

  /// The WCAG contrast ratio of two opaque colors (1 to 21).
  static double contrastOf(Color a, Color b) => _contrast(a, b);

  static double _contrast(Color a, Color b) {
    double lin(int v) {
      final x = v / 255;
      return x <= 0.03928 ? x / 12.92 : math.pow((x + 0.055) / 1.055, 2.4).toDouble();
    }

    double l(Color c) => 0.2126 * lin(c.red) + 0.7152 * lin(c.green) + 0.0722 * lin(c.blue);
    final la = l(a), lb = l(b);
    return la > lb ? (la + 0.05) / (lb + 0.05) : (lb + 0.05) / (la + 0.05);
  }

  /// Whether [c] is a neutral of a design system whose ground is [g] and
  /// whose ink is [i]: a gray (or nearly: a cool or a warm one), or a color
  /// on the line from the ground to the ink (a cream paper's warm tones).
  static bool _neutral(Color c, Color g, Color i) {
    final (_, s, _) = _hsl(c);
    if (s < 0.2) return true;
    // The distance from the line through the ground and the ink.
    final d = [i.red - g.red, i.green - g.green, i.blue - g.blue], v = [c.red - g.red, c.green - g.green, c.blue - g.blue];
    final dd = d[0] * d[0] + d[1] * d[1] + d[2] * d[2];
    if (dd == 0) return false;
    final t = (v[0] * d[0] + v[1] * d[1] + v[2] * d[2]) / dd;
    var dist = 0.0;
    for (var k = 0; k < 3; k++) {
      final off = v[k] - d[k] * t;
      dist += off * off;
    }
    return dist < 36;
  }

  /// [c], a neutral between a ground [g] and an ink [i], at the same place
  /// between [toG] and [toI] (by its lightness), at its own opacity. Past
  /// the ink: the ink. Past the ground (lighter than a light one, darker
  /// than a dark one): as far toward white, or black, from the new ground.
  static Color _regrounded(Color c, Color g, Color i, Color toG, Color toI) {
    final l = _luma(c), lg = _luma(g), li = _luma(i);
    if (lg == li) return c;
    final t = (l - lg) / (li - lg);
    int rgb;
    if (t >= 1) {
      rgb = _rgb(toI);
    } else if (t >= 0) {
      rgb = _mix(_rgb(toG), _rgb(toI), t);
    } else {
      final end = lg > li ? 1.0 : 0.0;
      final u = end == lg ? 0.0 : ((l - lg) / (end - lg)).clamp(0.0, 1.0);
      rgb = _mix(_rgb(toG), _luma(toG) >= _luma(toI) ? 0xFFFFFF : 0x000000, u);
    }
    return Color((c.alpha << 24) | rgb);
  }

  /// The names a design system gives the ground a page is drawn on: a site's
  /// `surface` is each of them ([withSiteTheme]).
  static const groundNames = {'page', 'pageFill', 'primaryBackground', 'background', 'paper', 'bg', 'ground'};

  /// The names a design system gives its ink (the color of its text): a
  /// site's `onSurface` is each of them that was the design system's
  /// `onSurface` ([withSiteTheme]).
  static const inkNames = {'primaryText', 'ink', 'text', 'foreground', 'headingText'};

  /// A text style named for a title or a heading (`pageTitle`, `heading2`,
  /// `display`): what a site's `titleFontFamily` is the family of.
  static final _titleStyle = RegExp('title|heading|display|headline', caseSensitive: false);

  /// The color names that are the accent's by their role, whatever they are
  /// called next to it ([withSiteTheme]): each follows a site's accent when
  /// it is of the accent's hue.
  static const _accentRoles = {
    'focusBorder', 'focusRing', 'selection', 'selectedRow', 'activeTint', 'primaryTint', 'primaryTintBorder', //
    'iconTile', 'chart1', 'link', 'linkHover', 'brand',
  };

  static int _rgb(Color c) => c.value & 0xFFFFFF;

  static int _mix(int a, int b, double t) {
    int ch(int shift) => (((a >> shift) & 0xff) + (((b >> shift) & 0xff) - ((a >> shift) & 0xff)) * t).round().clamp(0, 255);
    return (ch(16) << 16) | (ch(8) << 8) | ch(0);
  }

  /// Hue (degrees), saturation and lightness of [c].
  static (double, double, double) _hsl(Color c) {
    final r = c.red / 255, g = c.green / 255, b = c.blue / 255;
    final max = [r, g, b].reduce((a, b) => a > b ? a : b), min = [r, g, b].reduce((a, b) => a < b ? a : b);
    final l = (max + min) / 2, delta = max - min;
    if (delta == 0) return (0, 0, l);
    final s = delta / (1 - (2 * l - 1).abs());
    final h = max == r ? ((g - b) / delta) % 6 : (max == g ? (b - r) / delta + 2 : (r - g) / delta + 4);
    return ((h * 60 + 360) % 360, s, l);
  }

  /// Whether [c] is a shade of [accent]: a color (not a gray) of its hue.
  static bool _sameFamily(Color c, Color accent) {
    final (h, s, _) = _hsl(c);
    final (ah, accentS, _) = _hsl(accent);
    if (s < .2 || accentS < .2) return false;
    final d = (h - ah).abs();
    return (d > 180 ? 360 - d : d) <= 20;
  }

  /// [c] (a shade of [was]) in [accent]'s hue and saturation, as much
  /// lighter or darker than [accent] as it was than [was], and at its own
  /// opacity: a design system's text shade of its indigo (a little darker)
  /// is a little darker than a site's dark teal, not a bright cyan at the
  /// indigo's lightness; its tint (near white) stays near white.
  static Color _rehued(Color c, Color accent, Color was) {
    final (_, _, own) = _hsl(c);
    final (_, _, from) = _hsl(was);
    final (h, s, to) = _hsl(accent);
    final l = own >= from
        ? (from >= 1 ? to : to + (own - from) * (1 - to) / (1 - from))
        : (from <= 0 ? to : to * own / from);
    final k = (1 - (2 * l - 1).abs()) * s, x = k * (1 - ((h / 60) % 2 - 1).abs()), m = l - k / 2;
    final (r, g, b) = switch (h ~/ 60) { 0 => (k, x, 0.0), 1 => (x, k, 0.0), 2 => (0.0, k, x), 3 => (0.0, x, k), 4 => (x, 0.0, k), _ => (k, 0.0, x) };
    int ch(double v) => ((v + m) * 255).round().clamp(0, 255);
    return Color.fromARGB(c.alpha, ch(r), ch(g), ch(b));
  }

  static const ThemeTokens none = ThemeTokens();

  /// The roles the notation draws its own parts in where a site names no
  /// design system (a hairline, a card, a table's header band, a sidebar's
  /// items at rest, a hover and a selected fill...), by name. Each has a
  /// light value, the one the notation always wrote, and a dark one made
  /// from the theme's ink and ground where the ground is dark (its
  /// luminance under 0.35): so a dark site draws them legibly, and a site
  /// with light and [dark] colors switches them with its mode. A color the
  /// theme names itself wins ([color]). Read through [ThemeRefs] (a
  /// document's color named `line`) and [notationRole].
  static const notationRoles = {
    'line': 0xFFE5E7EB, // a hairline: a pane's edge, a bar's rule, a card's and a table's line
    'subtleFill': 0xFFE5E7EB, // a neutral or selected fill, a progress bar's track, an avatar's disc
    'neutralTint': 0xFFF3F4F6, // a neutral badge's fill
    'card': 0xFFFFFFFF, // a card, a tile, a dialog's and a drawer's panel
    'band': 0xFFF8FAFC, // a table's header band and a row under the pointer
    'hoverFill': 0x0F111827, // a sidebar's item under the pointer
    'headingText': 0xFF111827, // a title and a heading the theme has no style for
    'quietText': 0xFF374151, // a sidebar's or a bar's item at rest
    'mutedText': 0xFF6B7280, // its icon, a group's label, a brand's line under it
    'faintText': 0xFF9CA3AF, // what is fainter still
    'surface': 0xFFFFFFFF, // a panel written in the theme's surface (with no theme of its own)
    'onSurface': 0xFF111111, // its title and close button
  };

  /// The ground the theme draws on: its `page`, `surface` or
  /// `primaryBackground`, else its `paper` (`background`, `bg`, `ground`).
  Color? get ground {
    for (final n in const ['page', 'surface', 'primaryBackground', 'paper', 'background', 'bg', 'ground']) {
      if (color(n) case final Color c) return c;
    }
    return null;
  }

  /// Whether [ground] is dark (its luminance under 0.35): the notation's
  /// roles take their dark values ([notationRoles]).
  bool get groundIsDark {
    final g = ground;
    if (g == null) return false;
    return 0.2126 * g.red / 255 + 0.7152 * g.green / 255 + 0.0722 * g.blue / 255 < 0.35;
  }

  /// The notation's role [name] ([notationRoles]) in this theme (already for
  /// its mode: [forBrightness]): its light value, or on a dark [ground] its
  /// value made from the theme's ink and ground. Null for another name.
  Color? notationRole(String name) {
    final light = notationRoles[name];
    if (light == null) return null;
    final g = ground;
    if (g == null || !groundIsDark) return Color(light);
    final ink = color('primaryText') ?? color('onSurface') ?? color('ink') ?? const Color(0xFFF3F4F6);
    Color tint(int alpha) => Color((alpha << 24) | (ink.value & 0xFFFFFF));
    Color lift(double t) => Color.fromARGB(255, (g.red + (255 - g.red) * t).round(), (g.green + (255 - g.green) * t).round(), (g.blue + (255 - g.blue) * t).round());
    return switch (name) {
      'line' => tint(0x29),
      'subtleFill' || 'neutralTint' => tint(0x1A),
      'card' || 'surface' => lift(0.06),
      'band' => lift(0.03),
      'hoverFill' => tint(0x0F),
      'quietText' => tint(0xCC),
      'mutedText' => tint(0x99),
      'faintText' => tint(0x66),
      _ => Color(0xFF000000 | (ink.value & 0xFFFFFF)),
    };
  }


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
  /// [surface], [onSurface], [error], and [success], [warning]) as colors:
  /// a role that names a theme color (`"primary": "forest"`) is that
  /// color, through any chain of names, as any color naming another is. A
  /// role whose name the theme does not have is null. Controls and the
  /// runtime read the roles through this. A role written inside [colors]
  /// (`"colors": {"primary": ...}`) is not a role: it is a
  /// color of that name.
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
      iconStyle: iconStyle,
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
      iconStyle: iconStyle,
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
      iconStyle: readString(m['iconStyle']),
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
    put(j, 'iconStyle', iconStyle);
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
      other.iconStyle == iconStyle &&
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
      titleFontFamily, radius, Object.hash(buttonRadius, iconStyle), jsonEquality.hash(colors), jsonEquality.hash(textStyles), dark, Object.hashAll(media), mode,
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

/// Something of a theme's JSON that [ThemeTokens.fromJson] does not read:
/// where ([path]: the keys from the theme down, `colors.cream`,
/// `dark.primary`) and what is accepted there.
typedef ThemeProblem = ({List<String> path, String message});

/// The keys of a theme ([ThemeTokens.toJson]).
const themeKeys = [
  'primary', 'onPrimary', 'surface', 'onSurface', 'error', 'success', 'warning', //
  'fontFamily', 'titleFontFamily', 'radius', 'buttonRadius', 'iconStyle', 'colors', 'textStyles', 'dark', 'mode', //
  'spacing', 'radii', 'sizes', 'shadows', 'durations', 'curves', 'media',
];

/// What a writer calls a key of a theme, and the key it is.
const _themeKeyFor = {
  'background': 'surface', 'bg': 'surface', 'page': 'surface', 'ground': 'surface', 'paper': 'surface', 'backgroundColor': 'surface', //
  'accent': 'primary', 'brand': 'primary', 'primaryColor': 'primary', //
  'text': 'onSurface', 'textColor': 'onSurface', 'ink': 'onSurface', 'foreground': 'onSurface', 'onBackground': 'onSurface', //
  'font': 'fontFamily', 'bodyFont': 'fontFamily', 'bodyFontFamily': 'fontFamily', 'fontFamilyBody': 'fontFamily', //
  'headingFont': 'titleFontFamily', 'headingFontFamily': 'titleFontFamily', 'titleFont': 'titleFontFamily', 'displayFont': 'titleFontFamily',
  'fontFamilyHeading': 'titleFontFamily', 'headingFamily': 'titleFontFamily', //
  'borderRadius': 'radius', 'cornerRadius': 'radius', 'corner': 'radius', 'corners': 'radius', 'rounding': 'radius', //
  'fonts': 'textStyles', 'text_styles': 'textStyles', 'typography': 'textStyles', 'styles': 'textStyles', //
  'colours': 'colors', 'palette': 'colors', 'color': 'colors', 'themeMode': 'mode', 'brightness': 'mode',
};

/// What of [theme] (a theme's JSON: a site manifest's `"theme"`) the theme
/// does not read, each with the path of its key and what is accepted there:
/// a key a theme does not have, a color that is neither a value
/// (`"#AARRGGBB"`, `"#RRGGBB"`) nor a name the theme's `colors` define
/// (`"surface": "cream"` with no `"cream"` in `colors`), a family that is
/// not a text, a radius that is not a number, a mode that is not one.
///
/// [colors]: the color names the theme is laid over (a design system's), each
/// a name a color may give too. Empty for a theme that is `null`.
List<ThemeProblem> themeProblems(Object? theme, {Iterable<String> colors = const []}) {
  final out = <ThemeProblem>[];
  if (theme == null) return out;
  final top = readMap(theme);
  if (top == null) {
    return [(path: const [], message: 'not read: it is an object, {"primary": "#FF2563EB", "surface": "#FFFFFFFF", "colors": {"ink": "#FF111827"}}.')];
  }
  String show(Object? v) {
    final s = v is String ? '"$v"' : '$v';
    return s.length > 40 ? '${s.substring(0, 40)}…' : s;
  }

  void read(Map<String, Object?> m, List<String> at, Set<String> outer) {
    final own = readMap(m['colors']) ?? const <String, Object?>{};
    final names = {...outer, ...own.keys, for (final r in ThemeTokens.roleNames) if (m[r] != null || outer.contains(r)) r};
    void color(List<String> path, Object? v) {
      if (v == null || Color.fromHex(v) != null) return;
      final defined = [...own.keys, ...{...outer}..removeAll(own.keys)..removeAll(ThemeTokens.roleNames)];
      final has = defined.isEmpty ? 'this theme\'s "colors" define none' : 'here: ${defined.take(12).join(', ')}${defined.length > 12 ? '…' : ''}';
      if (v is String && Color.isName(v)) {
        // A name: one the colors define, or a role that is given.
        if (names.contains(v) && v != path.last) return;
        out.add((
          path: path,
          message: 'no color of the theme is named ${show(v)}, so it is not read. '
              'Write its value, "#AARRGGBB" (or "#RRGGBB"), or define it: "colors": {"$v": "#AARRGGBB"} ($has).',
        ));
        return;
      }
      out.add((
        path: path,
        message: '${show(v)} is not a color, so it is not read. '
            'Write "#AARRGGBB" (or "#RRGGBB"), or the name of a color the theme\'s "colors" define ($has).',
      ));
    }

    for (final e in m.entries) {
      final key = e.key, v = e.value, path = [...at, key];
      if (v == null) continue;
      if (!themeKeys.contains(key) || (key == 'dark' && at.isNotEmpty)) {
        final to = _themeKeyFor[key];
        final what = switch (to) {
          'surface' => ' (the ground a page is drawn on)',
          'primary' => ' (the accent)',
          'onSurface' => ' (the color of the text)',
          'titleFontFamily' => ' (the family of titles and headings)',
          _ => '',
        };
        final instead = to != null
            ? ' Write "$to"$what.'
            : Color.fromJson(v) != null
                ? ' A color of the site\'s own goes in "colors": {"$key": ${show(v)}}.'
                : '';
        out.add((
          path: path,
          message: 'a theme has no "$key", so it is not read.$instead '
              'A theme\'s keys: ${themeKeys.where((k) => k != 'media' && (at.isEmpty || k != 'dark')).join(', ')}.',
        ));
        continue;
      }
      switch (key) {
        case 'primary' || 'onPrimary' || 'surface' || 'onSurface' || 'error' || 'success' || 'warning':
          color(path, v);
        case 'fontFamily' || 'titleFontFamily' || 'iconStyle':
          if (v is! String || v.trim().isEmpty) {
            out.add((path: path, message: '${show(v)} is not read: write ${key == 'iconStyle' ? 'outlined, rounded or sharp' : 'a font family\'s name'} as a text ("${key == 'iconStyle' ? 'rounded' : 'Georgia'}").'));
          }
        case 'radius' || 'buttonRadius':
          if (v is! num) out.add((path: path, message: '${show(v)} is not read: write a number (8).'));
        case 'mode':
          if (ThemeMode.tryParse(v) == null) out.add((path: path, message: '${show(v)} is not a mode: write "system", "light" or "dark".'));
        case 'colors':
          if (readMap(v) == null) {
            out.add((path: path, message: 'not read: it is an object of names and colors, {"ink": "#FF111827"}.'));
          } else {
            for (final c in own.entries) {
              color([...path, c.key], c.value);
            }
          }
        case 'textStyles':
          final styles = readMap(v);
          if (styles == null) {
            out.add((path: path, message: 'not read: it is an object of names and text styles, {"heading1": {"fontFamily": "Georgia", "fontSize": 40, "fontWeight": 700}}.'));
          } else {
            for (final s in styles.entries) {
              final style = readMap(s.value);
              if (style == null) {
                out.add((path: [...path, s.key], message: '${show(s.value)} is not a text style, so it is not read: write {"fontFamily": "Georgia", "fontSize": 40, "fontWeight": 700, "color": "#FF111827"}.'));
                continue;
              }
              for (final k in const ['color', 'decorationColor', 'backgroundColor']) {
                color([...path, s.key, k], style[k]);
              }
            }
          }
        case 'spacing' || 'radii' || 'sizes':
          final scale = readMap(v);
          if (scale == null) {
            out.add((path: path, message: 'not read: it is an object of names and numbers, {"card": 12}.'));
          } else {
            for (final n in scale.entries) {
              if (n.value is! num) out.add((path: [...path, n.key], message: '${show(n.value)} is not read: write a number.'));
            }
          }
        case 'dark':
          final d = readMap(v);
          if (d == null) {
            out.add((path: path, message: 'not read: it is an object of the colors that differ in dark mode, {"surface": "#FF111111", "colors": {"ink": "#FFF3F4F6"}}.'));
          } else {
            read(d, path, names);
          }
      }
    }
  }

  // A design system has every role.
  read(top, const [], {...colors, if (colors.isNotEmpty) ...ThemeTokens.roleNames});
  return out;
}

/// The line (from 1) of [text] (a manifest's JSON as written) on which the
/// key at [path] under `"theme"` is written; the `"theme"` key's when one of
/// [path] is not found, null when that is not.
int? themeKeyLine(String text, List<String> path) {
  var at = 0;
  int? found;
  for (final key in ['theme', ...path]) {
    final m = RegExp('"${RegExp.escape(key)}"\\s*:').allMatches(text, at).firstOrNull;
    if (m == null) break;
    found = m.start;
    at = m.end;
  }
  return found == null ? null : '\n'.allMatches(text.substring(0, found)).length + 1;
}
