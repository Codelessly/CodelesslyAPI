/// The parsed form of a DESIGN.md design kit (see
/// `CodelesslyEditor/docs/design_md_spec.md`): a brand's tokens, component
/// recipes, layout, motion, imagery and accessibility rules, which the screen
/// generator reads to build on-brand Codelessly node trees.
library;

import 'dart:convert';
import 'dart:math' as math;

import 'package:collection/collection.dart';

import '../api/models/color_rgba.dart';

/// An sRGB color with opacity, written in DESIGN.md as `#RRGGBB` or
/// `#RRGGBB/60` (60% opacity).
class KitColor {
  /// Red, green and blue, 0-255.
  final int r, g, b;

  /// Opacity, 0-1.
  final double opacity;

  /// Creates a [KitColor].
  const KitColor(this.r, this.g, this.b, [this.opacity = 1]);

  /// Parses `#RGB`, `#RRGGBB`, `#RRGGBB/60` or `rgba(r, g, b, a)`; null when
  /// [text] is none of these.
  static KitColor? tryParse(String text) {
    final String value = text.trim();
    final Match? rgba = RegExp(
      r'^rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+)\s*)?\)$',
    ).firstMatch(value);
    if (rgba != null) {
      return KitColor(
        int.parse(rgba[1]!).clamp(0, 255),
        int.parse(rgba[2]!).clamp(0, 255),
        int.parse(rgba[3]!).clamp(0, 255),
        double.tryParse(rgba[4] ?? '1')?.clamp(0, 1).toDouble() ?? 1,
      );
    }
    final Match? hex = RegExp(
      r'^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})(?:\s*/\s*(\d{1,3})%?)?$',
    ).firstMatch(value);
    if (hex == null) return null;
    String digits = hex[1]!;
    if (digits.length == 3) {
      digits = digits.split('').map((String c) => '$c$c').join();
    }
    final int rgb = int.parse(digits, radix: 16);
    final int percent = int.tryParse(hex[2] ?? '100') ?? 100;
    return KitColor(
      (rgb >> 16) & 0xFF,
      (rgb >> 8) & 0xFF,
      rgb & 0xFF,
      percent.clamp(0, 100) / 100,
    );
  }

  /// `#RRGGBB` without opacity.
  String get rgbHex =>
      '#${[r, g, b].map((int c) => c.toRadixString(16).padLeft(2, '0')).join().toUpperCase()}';

  /// The DESIGN.md form: `#RRGGBB`, or `#RRGGBB/60` when translucent.
  String get designMd =>
      opacity >= 1 ? rgbHex : '$rgbHex/${(opacity * 100).round()}';

  /// Codelessly's node JSON form: `#RRGGBB`, or `#AARRGGBB` when translucent.
  String get nodeHex => opacity >= 1
      ? rgbHex
      : '#${(opacity * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}${rgbHex.substring(1)}';

  /// This color as the API's [ColorRGBA].
  ColorRGBA toColorRGBA() =>
      ColorRGBA(r: r / 255, g: g / 255, b: b / 255, a: opacity);

  /// Relative luminance (WCAG 2.x).
  double get luminance {
    double channel(int c) {
      final double v = c / 255;
      return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b);
  }

  /// WCAG contrast ratio between this color and [other] (opaque colors).
  double contrastWith(KitColor other) {
    final double a = luminance, b = other.luminance;
    final double hi = a > b ? a : b, lo = a > b ? b : a;
    return (hi + 0.05) / (lo + 0.05);
  }

  @override
  bool operator ==(Object other) =>
      other is KitColor &&
      other.r == r &&
      other.g == g &&
      other.b == b &&
      (other.opacity - opacity).abs() < 0.005;

  @override
  int get hashCode => Object.hash(r, g, b, (opacity * 100).round());

  @override
  String toString() => designMd;
}

/// A color token: its light value, optional dark value and usage note.
class KitColorToken {
  /// Token name, e.g. `primary`.
  final String name;

  /// The value in light mode.
  final KitColor light;

  /// The value in dark mode, when the kit defines one.
  final KitColor? dark;

  /// What the token is for.
  final String usage;

  /// Creates a [KitColorToken].
  const KitColorToken(this.name, this.light, {this.dark, this.usage = ''});

  @override
  bool operator ==(Object other) =>
      other is KitColorToken &&
      other.name == name &&
      other.light == light &&
      other.dark == dark &&
      other.usage == usage;

  @override
  int get hashCode => Object.hash(name, light, dark, usage);
}

/// A type token: one role of the type scale.
class KitTextStyle {
  /// Token name, e.g. `title`.
  final String name;

  /// Font family (a Google Fonts family name).
  final String family;

  /// Font size in logical pixels.
  final double size;

  /// Font weight, 100-900.
  final int weight;

  /// Line height as a multiple of the size.
  final double lineHeight;

  /// Letter spacing in pixels.
  final double letterSpacing;

  /// Whether the text is set in capitals.
  final bool uppercase;

  /// What the role is for.
  final String usage;

  /// Creates a [KitTextStyle].
  const KitTextStyle(
    this.name, {
    required this.family,
    required this.size,
    this.weight = 400,
    this.lineHeight = 1.3,
    this.letterSpacing = 0,
    this.uppercase = false,
    this.usage = '',
  });

  @override
  bool operator ==(Object other) =>
      other is KitTextStyle &&
      other.name == name &&
      other.family == family &&
      other.size == size &&
      other.weight == weight &&
      other.lineHeight == lineHeight &&
      other.letterSpacing == letterSpacing &&
      other.uppercase == uppercase &&
      other.usage == usage;

  @override
  int get hashCode => Object.hash(
    name,
    family,
    size,
    weight,
    lineHeight,
    letterSpacing,
    uppercase,
    usage,
  );
}

/// One drop shadow of an elevation token.
class KitShadow {
  /// Offset, blur and spread in pixels.
  final double x, y, blur, spread;

  /// Shadow color.
  final KitColor color;

  /// Creates a [KitShadow].
  const KitShadow(this.x, this.y, this.blur, this.spread, this.color);

  /// `x y blur spread color`.
  String get designMd =>
      '${_num(x)} ${_num(y)} ${_num(blur)} ${_num(spread)} ${color.designMd}';

  @override
  bool operator ==(Object other) =>
      other is KitShadow &&
      other.x == x &&
      other.y == y &&
      other.blur == blur &&
      other.spread == spread &&
      other.color == color;

  @override
  int get hashCode => Object.hash(x, y, blur, spread, color);
}

/// A motion token: a duration and a curve.
class KitMotion {
  /// Token name, e.g. `standard`.
  final String name;

  /// Duration in milliseconds.
  final int durationMs;

  /// A Codelessly motion curve name (`easeOut`, `spring`, ...).
  final String curve;

  /// What the token is for.
  final String usage;

  /// Creates a [KitMotion].
  const KitMotion(this.name, this.durationMs, this.curve, {this.usage = ''});

  @override
  bool operator ==(Object other) =>
      other is KitMotion &&
      other.name == name &&
      other.durationMs == durationMs &&
      other.curve == curve &&
      other.usage == usage;

  @override
  int get hashCode => Object.hash(name, durationMs, curve, usage);
}

/// One breakpoint of the layout grid.
class KitBreakpoint {
  /// `mobile`, `tablet` or `desktop`.
  final String name;

  /// The narrowest width this breakpoint applies to.
  final double minWidth;

  /// Grid columns.
  final int columns;

  /// Page margin: a spacing token name.
  final String margin;

  /// Gap between columns and sections: a spacing token name.
  final String gutter;

  /// The widest the content gets; wider screens center it.
  final double maxContent;

  /// Creates a [KitBreakpoint].
  const KitBreakpoint(
    this.name, {
    required this.minWidth,
    required this.columns,
    required this.margin,
    required this.gutter,
    required this.maxContent,
  });

  @override
  bool operator ==(Object other) =>
      other is KitBreakpoint &&
      other.name == name &&
      other.minWidth == minWidth &&
      other.columns == columns &&
      other.margin == margin &&
      other.gutter == gutter &&
      other.maxContent == maxContent;

  @override
  int get hashCode =>
      Object.hash(name, minWidth, columns, margin, gutter, maxContent);
}

/// A section of free-form guidance: properties (`Key: value` lines), a table,
/// rules, dos and don'ts. Used for the brand, each component, layout, motion,
/// imagery, iconography and accessibility.
class KitGuide {
  /// `Key: value` lines, keys normalized to lowerCamelCase.
  final Map<String, String> props;

  /// Table rows keyed by the normalized column headers, in order.
  final List<Map<String, String>> table;

  /// Usage rules.
  final List<String> rules;

  /// Do list.
  final List<String> dos;

  /// Don't list.
  final List<String> donts;

  /// Free text paragraphs.
  final String notes;

  /// Creates a [KitGuide].
  const KitGuide({
    this.props = const {},
    this.table = const [],
    this.rules = const [],
    this.dos = const [],
    this.donts = const [],
    this.notes = '',
  });

  /// Whether the guide says nothing.
  bool get isEmpty =>
      props.isEmpty &&
      table.isEmpty &&
      rules.isEmpty &&
      dos.isEmpty &&
      donts.isEmpty &&
      notes.isEmpty;

  /// The property [key] (lowerCamelCase), or null.
  String? operator [](String key) => props[key];

  /// The table row whose first column is [key] (case-insensitive).
  Map<String, String>? row(String key) => table.firstWhereOrNull(
    (Map<String, String> row) =>
        row.values.isNotEmpty &&
        row.values.first.toLowerCase() == key.toLowerCase(),
  );

  static const DeepCollectionEquality _eq = DeepCollectionEquality();

  @override
  bool operator ==(Object other) =>
      other is KitGuide &&
      _eq.equals(other.props, props) &&
      _eq.equals(other.table, table) &&
      _eq.equals(other.rules, rules) &&
      _eq.equals(other.dos, dos) &&
      _eq.equals(other.donts, donts) &&
      other.notes == notes;

  @override
  int get hashCode =>
      Object.hash(_eq.hash(props), _eq.hash(table), _eq.hash(rules), notes);
}

/// A whole DESIGN.md design kit.
class DesignKit {
  /// Kit name, e.g. `Aurora`.
  final String name;

  /// Kit version; part of the generator's cache key.
  final String version;

  /// One-line description.
  final String description;

  /// Brand personality and voice (props `personality`, `voice`, `tone`).
  final KitGuide brand;

  /// Color tokens by name, in order.
  final Map<String, KitColorToken> colors;

  /// Type scale by role, in order.
  final Map<String, KitTextStyle> typography;

  /// Spacing scale, in pixels.
  final Map<String, double> spacing;

  /// Corner radii, in pixels (`999` for a pill).
  final Map<String, double> radius;

  /// Elevation tokens: shadows (empty for flat).
  final Map<String, List<KitShadow>> elevation;

  /// Component recipes by normalized name (`button`, `card`, `listRow`,
  /// `input`, `appBar`, `navBar`, `chip`, `badge`, `avatar`, `banner`, ...).
  final Map<String, KitGuide> components;

  /// Layout breakpoints, narrowest first.
  final List<KitBreakpoint> breakpoints;

  /// Layout patterns and rules.
  final KitGuide layout;

  /// Motion tokens by name.
  final Map<String, KitMotion> motion;

  /// Motion rules.
  final KitGuide motionGuide;

  /// Imagery rules.
  final KitGuide imagery;

  /// Iconography rules (props `set`, `style`, `size`, `color`).
  final KitGuide icons;

  /// Accessibility rules (props `minContrast`, `minTouchTarget`, ...).
  final KitGuide accessibility;

  /// Sections the format doesn't define, kept verbatim for round trips.
  final Map<String, String> extra;

  /// Creates a [DesignKit].
  const DesignKit({
    required this.name,
    this.version = '1.0.0',
    this.description = '',
    this.brand = const KitGuide(),
    this.colors = const {},
    this.typography = const {},
    this.spacing = const {},
    this.radius = const {},
    this.elevation = const {},
    this.components = const {},
    this.breakpoints = const [],
    this.layout = const KitGuide(),
    this.motion = const {},
    this.motionGuide = const KitGuide(),
    this.imagery = const KitGuide(),
    this.icons = const KitGuide(),
    this.accessibility = const KitGuide(),
    this.extra = const {},
  });

  /// The color token [name]; falls back through common aliases.
  KitColor? color(String name) => colors[name]?.light;

  /// The spacing token [name] in pixels, or a number given as text.
  double? space(String name) => spacing[name] ?? double.tryParse(name);

  /// The radius token [name] in pixels, or a number given as text.
  double? corner(String name) => radius[name] ?? double.tryParse(name);

  /// The breakpoint named [name], else the nearest defined one.
  KitBreakpoint breakpoint(String name) {
    final KitBreakpoint? exact = breakpoints.firstWhereOrNull(
      (KitBreakpoint b) => b.name == name,
    );
    if (exact != null) return exact;
    const Map<String, KitBreakpoint> defaults = {
      'mobile': KitBreakpoint(
        'mobile',
        minWidth: 0,
        columns: 4,
        margin: 'md',
        gutter: 'md',
        maxContent: 600,
      ),
      'tablet': KitBreakpoint(
        'tablet',
        minWidth: 600,
        columns: 8,
        margin: 'lg',
        gutter: 'md',
        maxContent: 840,
      ),
      'desktop': KitBreakpoint(
        'desktop',
        minWidth: 1024,
        columns: 12,
        margin: 'xl',
        gutter: 'lg',
        maxContent: 1200,
      ),
    };
    return breakpoints.isEmpty
        ? defaults[name] ?? defaults['mobile']!
        : breakpoints.last;
  }

  /// A stable fingerprint of the kit's content: its version plus a hash of
  /// everything the generator reads. Part of the generator's cache key, so
  /// editing a token invalidates cached screens even without a version bump.
  String get fingerprint {
    final String content = jsonEncode(<String, Object?>{
      'v': version,
      'c': {for (final t in colors.values) t.name: t.light.designMd},
      't': {
        for (final t in typography.values)
          t.name: '${t.family}/${t.size}/${t.weight}/${t.lineHeight}',
      },
      's': spacing,
      'r': radius,
      'e': {
        for (final e in elevation.entries)
          e.key: e.value.map((KitShadow s) => s.designMd).join(','),
      },
      'p': {for (final c in components.entries) c.key: c.value.props},
    });
    return '$version+${_fnv1a(content).toRadixString(16).padLeft(8, '0')}';
  }

  /// Every color value the kit defines (light mode), for on-brand checks.
  Set<KitColor> get palette => {
    for (final KitColorToken t in colors.values) t.light,
    for (final List<KitShadow> shadows in elevation.values)
      for (final KitShadow s in shadows) s.color,
  };

  static const DeepCollectionEquality _eq = DeepCollectionEquality();

  @override
  bool operator ==(Object other) =>
      other is DesignKit &&
      other.name == name &&
      other.version == version &&
      other.description == description &&
      other.brand == brand &&
      _eq.equals(other.colors, colors) &&
      _eq.equals(other.typography, typography) &&
      _eq.equals(other.spacing, spacing) &&
      _eq.equals(other.radius, radius) &&
      _eq.equals(other.elevation, elevation) &&
      _eq.equals(other.components, components) &&
      _eq.equals(other.breakpoints, breakpoints) &&
      other.layout == layout &&
      _eq.equals(other.motion, motion) &&
      other.motionGuide == motionGuide &&
      other.imagery == imagery &&
      other.icons == icons &&
      other.accessibility == accessibility &&
      _eq.equals(other.extra, extra);

  @override
  int get hashCode => Object.hash(name, version, fingerprint);
}

/// 32-bit FNV-1a of [text]'s UTF-8 bytes.
int _fnv1a(String text) {
  int hash = 0x811c9dc5;
  for (final int byte in utf8.encode(text)) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}

/// 32-bit FNV-1a hash of [text] as 8 hex digits (cache keys).
String fnvHex(String text) => _fnv1a(text).toRadixString(16).padLeft(8, '0');

String _num(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';

/// Formats [value] without a trailing `.0`.
String kitNum(num value) => _num(value.toDouble());
