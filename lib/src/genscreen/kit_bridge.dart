/// DESIGN.md kits to and from Codelessly projects: a kit's [ThemeTokens],
/// its project styles (color and text styles named after its tokens), and a
/// kit read back from a project's styles and nodes ([exportDesignKit]).
library;

import 'dart:math' as math;

import '../api/models/models.dart';
import 'design_kit.dart';
import 'screen_compiler.dart';

/// `onSurfaceVariant` → `On Surface Variant`: style labels the editor and
/// `themeTokensFrom` match tokens by (case and spaces ignored).
String styleLabel(String token) => token
    .replaceAllMapped(RegExp('(?<=[a-z0-9])([A-Z])'), (Match m) => ' ${m[1]}')
    .replaceFirstMapped(RegExp('^[a-z]'), (Match m) => m[0]!.toUpperCase());

/// The runtime theme of [kit]: dialogs, toasts and default fonts.
ThemeTokens kitThemeTokens(DesignKit kit) {
  ColorRGBA? c(String token) => kit.color(token)?.toColorRGBA();
  return ThemeTokens(
    primary: c('primary'),
    onPrimary: c('onPrimary'),
    surface: c('surface'),
    onSurface: c('onSurface'),
    error: c('error'),
    success: c('success'),
    warning: c('warning'),
    fontFamily: kit.typography['body']?.family,
    titleFontFamily: (kit.typography['title'] ?? kit.typography['headline'])?.family,
    radius: kit.corner(kit.components['card']?['radius'] ?? 'lg'),
    buttonRadius: kit.corner(kit.components['button']?['radius'] ?? 'md'),
  );
}

/// The project styles of [kit], as `styles.add` takes them: one color style
/// per color token and one text style per type role, labeled so the
/// editor's theme reads them (`Primary`, `On Surface`, `Body`, `Title`...).
List<Map<String, Object>> kitStyles(DesignKit kit) => <Map<String, Object>>[
  for (final KitColorToken t in kit.colors.values)
    <String, Object>{
      'kind': 'color',
      'label': styleLabel(t.name),
      'value': <String, Object>{
        'type': 'solid',
        'color': <String, double>{'r': t.light.r / 255, 'g': t.light.g / 255, 'b': t.light.b / 255, 'a': 1},
        'opacity': t.light.opacity,
      },
    },
  for (final KitTextStyle t in kit.typography.values)
    <String, Object>{
      'kind': 'text',
      'label': styleLabel(t.name),
      'value': <String, Object>{
        'fontSize': t.size,
        'fontName': <String, String>{'family': t.family, 'style': 'Regular', 'weight': 'w${t.weight}'},
        'lineHeight': <String, Object>{'unit': 'percent', 'value': (t.lineHeight * 100).round()},
        if (t.letterSpacing != 0) 'letterSpacing': <String, Object>{'value': t.letterSpacing},
        'fills': <Map<String, Object>>[
          <String, Object>{'type': 'solid', 'color': (kit.color('onSurface') ?? const KitColor(0, 0, 0)).rgbHex},
        ],
      },
    },
];

/// A showcase plan of the kit's components (every button variant, a card,
/// list rows, an input, chips, a banner per tone...). Compiled, it is the
/// kit's component library on a canvas, ready to save as components.
Map<String, dynamic> kitShowcasePlan(DesignKit kit) {
  final List<String> variants = <String>[
    for (final Map<String, String> row in kit.components['button']?.table ?? const [])
      if (row.values.isNotEmpty) row.values.first,
  ];
  return <String, dynamic>{
    'title': '${kit.name} components',
    'pattern': 'custom',
    'appBar': <String, dynamic>{'title': '${kit.name} components'},
    'variables': <Map<String, dynamic>>[
      <String, dynamic>{'name': 'email', 'type': 'text', 'value': ''},
      <String, dynamic>{'name': 'notify', 'type': 'boolean', 'value': true},
      <String, dynamic>{'name': 'view', 'type': 'text', 'value': 'Week'},
      <String, dynamic>{'name': 'tab', 'type': 'text', 'value': 'Overview'},
    ],
    'sections': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'buttons',
        'title': 'Buttons',
        'children': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'group',
            'direction': 'row',
            'wrap': true,
            'children': <Map<String, dynamic>>[
              for (final String v in variants.isEmpty ? const ['primary', 'secondary', 'outline', 'ghost'] : variants)
                <String, dynamic>{
                  'type': 'button',
                  'label': '${v[0].toUpperCase()}${v.substring(1)}',
                  'variant': v,
                  'fullWidth': false,
                  'action': <String, dynamic>{'type': 'toast', 'message': v},
                },
            ],
          },
        ],
      },
      <String, dynamic>{
        'id': 'content',
        'title': 'Cards and rows',
        'layout': 'cards',
        'columns': <String, int>{'mobile': 1, 'desktop': 2},
        'children': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'card',
            'eyebrow': 'Card',
            'title': 'A card groups one subject',
            'body': 'Cards hold a title, supporting text and an action.',
            'button': <String, dynamic>{'label': 'Open', 'variant': 'primary', 'action': <String, dynamic>{'type': 'toast', 'message': 'Open'}},
          },
          <String, dynamic>{
            'type': 'group',
            'surface': true,
            'children': <Map<String, dynamic>>[
              <String, dynamic>{'type': 'listRow', 'title': 'List row', 'subtitle': 'With an icon and a chevron', 'leading': <String, dynamic>{'icon': 'person'}, 'action': <String, dynamic>{'type': 'toast', 'message': 'Row'}},
              <String, dynamic>{'type': 'switchRow', 'title': 'Switch row', 'bind': 'notify'},
              <String, dynamic>{'type': 'listRow', 'title': 'Row with a badge', 'trailing': <String, dynamic>{'badge': 'New'}},
            ],
          },
        ],
      },
      <String, dynamic>{
        'id': 'inputs',
        'title': 'Inputs and selection',
        'children': <Map<String, dynamic>>[
          <String, dynamic>{'type': 'input', 'label': 'Email', 'kind': 'email', 'hint': 'you@example.com', 'bind': 'email'},
          <String, dynamic>{'type': 'segmented', 'options': <String>['Day', 'Week', 'Month'], 'bind': 'view'},
          <String, dynamic>{'type': 'tabs', 'tabs': <String>['Overview', 'Activity', 'Settings'], 'bind': 'tab'},
          <String, dynamic>{'type': 'chips', 'items': <Object>[<String, dynamic>{'label': 'Selected', 'selected': true}, 'Chip', 'Another chip']},
        ],
      },
      <String, dynamic>{
        'id': 'feedback',
        'title': 'Feedback',
        'children': <Map<String, dynamic>>[
          for (final String tone in const ['info', 'success', 'warning', 'error'])
            <String, dynamic>{'type': 'banner', 'tone': tone, 'title': '${tone[0].toUpperCase()}${tone.substring(1)} banner', 'message': 'Short supporting text.'},
          <String, dynamic>{'type': 'progress', 'value': 0.6, 'label': 'Progress', 'caption': '60%'},
          <String, dynamic>{'type': 'stat', 'label': 'Stat', 'value': '1,240', 'delta': '+12%'},
        ],
      },
    ],
    'states': <String, dynamic>{
      'loading': <String, dynamic>{'style': 'skeleton'},
      'error': <String, dynamic>{'title': 'Something went wrong', 'message': 'Please try again.', 'action': <String, dynamic>{'label': 'Try again', 'action': <String, dynamic>{'type': 'retry'}}},
    },
  };
}

/// The kit's component library: the showcase compiled, per breakpoint.
CompiledScreen kitComponentLibrary(DesignKit kit) => ScreenCompiler(kit).compile(kitShowcasePlan(kit));

/// A color style or text style of a project, for [exportDesignKit].
class ProjectStyle {
  /// The style's name.
  final String label;

  /// A solid color, for color styles.
  final KitColor? color;

  /// Font, size, weight and line height (a multiple), for text styles.
  final String? family;
  final double? size, lineHeight, letterSpacing;
  final int? weight;

  /// A color style.
  const ProjectStyle.color(this.label, KitColor this.color)
    : family = null,
      size = null,
      lineHeight = null,
      letterSpacing = null,
      weight = null;

  /// A text style.
  const ProjectStyle.text(
    this.label, {
    required String this.family,
    required double this.size,
    this.weight = 400,
    this.lineHeight,
    this.letterSpacing,
  }) : color = null;
}

/// Reads a design kit back from an existing project: its color and text
/// styles (named after tokens or not) and what its nodes actually use —
/// the most used fills, fonts, paddings, gaps, corner radii and shadows —
/// so a project built without a kit gets one that matches it.
DesignKit exportDesignKit({
  required String name,
  List<ProjectStyle> styles = const <ProjectStyle>[],
  Iterable<Map<String, dynamic>> nodes = const <Map<String, dynamic>>[],
  ThemeTokens? theme,
  String version = '1.0.0',
}) {
  final Map<KitColor, int> fills = <KitColor, int>{};
  final Map<KitColor, int> textColors = <KitColor, int>{};
  final Map<String, int> fonts = <String, int>{};
  final Map<double, int> radii = <double, int>{};
  final Map<double, int> spaces = <double, int>{};
  final Map<String, int> shadows = <String, int>{};
  void count<T>(Map<T, int> map, T key) => map[key] = (map[key] ?? 0) + 1;
  KitColor? readColor(Object? value, [num opacity = 1]) {
    if (value is String) return KitColor.tryParse(value.length == 9 ? '#${value.substring(3)}' : value);
    if (value is Map && value['r'] is num) {
      int c(Object? v) => ((v as num) * 255).round().clamp(0, 255);
      return KitColor(c(value['r']), c(value['g']), c(value['b']), opacity.toDouble());
    }
    return null;
  }

  for (final Map<String, dynamic> node in nodes) {
    for (final Object? p in (node['fills'] as List?) ?? const []) {
      if (p is Map && (p['type'] == 'solid' || p['type'] == null)) {
        final KitColor? c = readColor(p['color']);
        if (c != null) count(fills, c);
      }
    }
    for (final Object? s in (node['textMixedProps'] as List?) ?? const []) {
      if (s is! Map) continue;
      final Object? font = s['fontName'];
      if (font is Map && s['fontSize'] is num) {
        final String weight = '${font['weight'] ?? 'w400'}'.replaceAll('w', '');
        count(fonts, '${font['family']}|${(s['fontSize'] as num).toDouble()}|$weight');
      }
      for (final Object? p in (s['fills'] as List?) ?? const []) {
        final KitColor? c = p is Map ? readColor(p['color']) : null;
        if (c != null) count(textColors, c);
      }
    }
    final Object? r = node['cornerRadius'];
    if (r is List && r.isNotEmpty && r.first is num) count(radii, (r.first as num).toDouble());
    if (r is num) count(radii, r.toDouble());
    final Object? gap = node['spacing'];
    if (gap is num && gap > 0) count(spaces, gap.toDouble());
    final Object? pad = node['padding'];
    if (pad is List) {
      for (final Object? v in pad) {
        if (v is num && v > 0) count(spaces, v.toDouble());
      }
    } else if (pad is num && pad > 0) {
      count(spaces, pad.toDouble());
    }
    for (final Object? e in (node['effects'] as List?) ?? const []) {
      if (e is Map && e['type'] == 'dropShadow') {
        final List<dynamic> o = (e['offset'] as List?) ?? const [0, 0];
        final KitColor? c = readColor(e['color']);
        if (c == null) continue;
        count(shadows, '${kitNum(o[0] as num)} ${kitNum(o[1] as num)} ${kitNum((e['radius'] ?? e['blur'] ?? 0) as num)} ${kitNum((e['spread'] ?? 0) as num)} ${c.designMd}');
      }
    }
  }

  List<K> top<K>(Map<K, int> map, [int n = 1 << 30]) =>
      (map.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(n).map((e) => e.key).toList();
  String token(String label) => label
      .replaceAll(RegExp('[^A-Za-z0-9 ]'), ' ')
      .trim()
      .split(RegExp(r'\s+'))
      .asMap()
      .entries
      .map((e) => e.key == 0 ? e.value.toLowerCase() : '${e.value[0].toUpperCase()}${e.value.substring(1).toLowerCase()}')
      .join();

  // Colors: named styles first, then the theme, then what nodes use most.
  final Map<String, KitColorToken> colors = <String, KitColorToken>{};
  for (final ProjectStyle s in styles.where((s) => s.color != null)) {
    final String t = token(s.label);
    if (t.isNotEmpty) colors.putIfAbsent(t, () => KitColorToken(t, s.color!, usage: 'From the "${s.label}" style'));
  }
  void themed(String t, ColorRGBA? c) {
    if (c == null || colors.containsKey(t)) return;
    colors[t] = KitColorToken(t, KitColor((c.r * 255).round(), (c.g * 255).round(), (c.b * 255).round(), c.a), usage: 'From the project theme');
  }

  themed('primary', theme?.primary);
  themed('onPrimary', theme?.onPrimary);
  themed('surface', theme?.surface);
  themed('onSurface', theme?.onSurface);
  themed('error', theme?.error);
  themed('success', theme?.success);
  themed('warning', theme?.warning);
  final List<KitColor> byUse = top(fills);
  final List<KitColor> inkByUse = top(textColors);
  KitColor? lightest(Iterable<KitColor> list) => list.isEmpty ? null : list.reduce((a, b) => a.luminance >= b.luminance ? a : b);
  final KitColor? background = byUse.isEmpty ? null : byUse.first;
  void derive(String t, KitColor? c, String usage) {
    if (c != null && !colors.containsKey(t)) colors[t] = KitColorToken(t, c, usage: usage);
  }

  derive('background', background, 'Most used fill');
  derive('surface', lightest(byUse.take(4)), 'Lightest common fill');
  derive('onSurface', inkByUse.isEmpty ? null : inkByUse.first, 'Most used text color');
  derive('onSurfaceVariant', inkByUse.length > 1 ? inkByUse[1] : null, 'Second most used text color');
  // The most saturated common fill is the brand color.
  final List<KitColor> saturated = byUse.take(12).where((c) {
    final int mx = math.max(c.r, math.max(c.g, c.b)), mn = math.min(c.r, math.min(c.g, c.b));
    return mx - mn > 60;
  }).toList();
  derive('primary', saturated.isEmpty ? null : saturated.first, 'Most used saturated fill');
  final KitColor? primary = colors['primary']?.light;
  if (primary != null) {
    const KitColor white = KitColor(255, 255, 255), black = KitColor(0, 0, 0);
    derive('onPrimary', primary.contrastWith(white) >= primary.contrastWith(black) ? white : black, 'Readable on primary');
  }
  if (background != null && !colors.containsKey('surfaceVariant') && byUse.length > 2) {
    derive('surfaceVariant', byUse.firstWhere((c) => c != background && c != colors['surface']?.light && c != primary, orElse: () => background), 'Quiet fill');
  }

  // Type: text styles named after roles, else the most used sizes ranked.
  final Map<String, KitTextStyle> typography = <String, KitTextStyle>{};
  for (final ProjectStyle s in styles.where((s) => s.family != null)) {
    final String t = token(s.label);
    if (t.isEmpty) continue;
    typography.putIfAbsent(
      t,
      () => KitTextStyle(t, family: s.family!, size: s.size!, weight: s.weight ?? 400, lineHeight: s.lineHeight ?? 1.3, letterSpacing: s.letterSpacing ?? 0, usage: 'From the "${s.label}" style'),
    );
  }
  if (!const ['title', 'body', 'label'].every(typography.containsKey) && fonts.isNotEmpty) {
    final List<(String, double, int)> used = <(String, double, int)>[
      for (final String key in top(fonts, 12))
        (key.split('|')[0], double.parse(key.split('|')[1]), int.tryParse(key.split('|')[2]) ?? 400),
    ];
    final (String, double, int) bodyFont = used.first;
    final List<(String, double, int)> bySize = <(String, double, int)>[...used]..sort((a, b) => b.$2.compareTo(a.$2));
    void role(String t, (String, double, int)? f, String usage) {
      if (f == null || typography.containsKey(t)) return;
      typography[t] = KitTextStyle(t, family: f.$1, size: f.$2, weight: f.$3, lineHeight: f.$2 >= 24 ? 1.2 : 1.4, usage: usage);
    }

    role('display', bySize.length > 3 && bySize.first.$2 >= 32 ? bySize.first : null, 'Largest text in the project');
    role('title', bySize.firstWhere((f) => f.$2 > bodyFont.$2 && f.$2 < 32, orElse: () => bySize.first), 'A common larger size');
    role('body', bodyFont, 'Most used text');
    role('label', used.firstWhere((f) => f.$3 >= 600 && f.$2 <= bodyFont.$2, orElse: () => bodyFont), 'Common bold small text');
    role('caption', bySize.lastWhere((f) => f.$2 < bodyFont.$2, orElse: () => bodyFont), 'Smallest common text');
  }

  // Spacing and radius: the most used values, named on a small scale.
  const List<String> spaceNames = <String>['xs', 'sm', 'md', 'lg', 'xl', 'xxl'];
  final List<double> spaceValues = (top(spaces, 6)..sort());
  final Map<String, double> spacing = <String, double>{
    for (int i = 0; i < spaceValues.length; i++) spaceNames[i]: spaceValues[i],
  };
  if (spacing.isEmpty) spacing.addAll(const {'xs': 4, 'sm': 8, 'md': 16, 'lg': 24, 'xl': 32});
  final List<double> radiusValues = top(radii, 4).where((r) => r > 0).toList()..sort();
  const List<String> radiusNames = <String>['sm', 'md', 'lg', 'xl'];
  final Map<String, double> radius = <String, double>{
    'none': 0,
    for (int i = 0; i < radiusValues.length; i++) radiusNames[i]: radiusValues[i],
    'pill': 999,
  };
  final Map<String, List<KitShadow>> elevation = <String, List<KitShadow>>{'flat': const <KitShadow>[]};
  final List<String> shadowNames = <String>['low', 'medium', 'high'];
  final List<String> topShadows = top(shadows, 3);
  for (int i = 0; i < topShadows.length; i++) {
    final List<String> bits = topShadows[i].split(' ');
    elevation[shadowNames[i]] = <KitShadow>[
      KitShadow(double.parse(bits[0]), double.parse(bits[1]), double.parse(bits[2]), double.parse(bits[3]), KitColor.tryParse(bits.skip(4).join(' '))!),
    ];
  }
  final String radiusOf = radius.containsKey('md') ? 'md' : radius.keys.elementAt(1);
  return DesignKit(
    name: name,
    version: version,
    description: 'Exported from the Codelessly project "$name".',
    brand: const KitGuide(notes: 'Exported from an existing project: review the voice and rules before generating.'),
    colors: colors,
    typography: typography,
    spacing: spacing,
    radius: radius,
    elevation: elevation,
    components: <String, KitGuide>{
      'button': KitGuide(props: <String, String>{'height': '48', 'radius': radiusOf, 'text': typography.containsKey('label') ? 'label' : 'body'}, table: const <Map<String, String>>[
        {'variant': 'primary', 'fill': 'primary', 'text': 'onPrimary', 'border': 'none'},
        {'variant': 'outline', 'fill': 'surface', 'text': 'onSurface', 'border': 'onSurfaceVariant'},
        {'variant': 'ghost', 'fill': 'none', 'text': 'primary', 'border': 'none'},
      ]),
      'card': KitGuide(props: <String, String>{'fill': 'surface', 'radius': radius.containsKey('lg') ? 'lg' : radiusOf, 'padding': 'md', 'shadow': elevation.containsKey('low') ? 'low' : 'flat'}),
      'listRow': const KitGuide(props: <String, String>{'minHeight': '56', 'title': 'body', 'subtitle': 'caption', 'divider': 'yes'}),
      'input': KitGuide(props: <String, String>{'height': '48', 'fill': 'surface', 'radius': radiusOf, 'text': 'body', 'label': 'label'}),
      'appBar': const KitGuide(props: <String, String>{'height': '64', 'fill': 'surface', 'title': 'title'}),
      'navBar': const KitGuide(props: <String, String>{'mobile': 'bottom', 'desktop': 'rail', 'active': 'primary', 'inactive': 'onSurfaceVariant'}),
    },
    accessibility: const KitGuide(props: <String, String>{'minContrast': '4.5', 'minTouchTarget': '48'}),
  );
}
