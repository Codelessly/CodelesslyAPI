// The compact notation (docs/design/13-compact-notation.md): the form an
// agent writes for levels 0 to 2. One node per line, nesting by indentation:
//
//   Column gap:12
//     Slider =volume
//     Input "Email" =email
//     Toggle "Notifications" =notify
//     Button "Save" -> emit save
//
// [parseNotation] expands it to an ordinary flat document; nothing after
// that (validation, rendering, editing) knows the notation was used.
import 'dart:convert';
import 'dart:math' as math;

import '../behaviors.dart' show mergePatch;
import '../catalog.dart';
import '../design_system.dart';
import '../layout.dart' show SizeFit;
import '../json.dart';
import '../props.dart';
import 'page_words.dart';
import 'reflow.dart';

/// A problem in the notation's text: where and what.
final class NotationIssue {
  const NotationIssue(this.line, this.column, this.message);

  /// 1-based.
  final int line, column;
  final String message;

  @override
  String toString() => 'line $line:$column: $message';
}

/// What [parseNotation] gives: the document and what it could not read.
/// A component an answer asked for because none fitted a part of its UI:
/// `Wanted "PollResults" "each option with its share of the votes"`, with the
/// part built from plain parts under it. The part shows as written; a host
/// may have the component designed and added for the answers that follow.
final class WantedBlock {
  const WantedBlock(this.name, this.purpose, this.node);

  /// The name the component would be called by.
  final String name;

  /// What it shows, in the answer's words.
  final String purpose;

  /// The id of the node that stands in for it (a column of plain parts).
  final String node;

  @override
  String toString() => 'WantedBlock($name: $purpose)';
}

final class NotationResult {
  const NotationResult(this.document, this.issues, {this.wanted = const []});

  /// The components the text asked for ([WantedBlock]).
  final List<WantedBlock> wanted;

  /// A schema-3 layout document.
  final Json document;
  final List<NotationIssue> issues;
}

/// How the notation expands.
final class NotationOptions {
  const NotationOptions({
    this.width = 390,
    this.screen = 'screen',
    this.textStyles = defaultTextVariants,
    this.card = defaultCard,
    this.badges = badgeVariants,
    this.surface = '#FFFFFFFF',
    this.accent = '#FF2563EB',
    this.track = '#FFE5E7EB',
    this.components = const {},
    this.badge = defaultBadge,
    this.cta,
    this.palette = const {},
    this.tile,
    this.sectionRadius,
    this.barChart = const {},
    this.progress = const {},
    this.cardGap,
    this.pageFill,
    this.ringStroke,
    this.height = 800,
    this.contentWidth = 1120,
    this.selectedFill = '#FFE5E7EB',
    this.line = '#FFE5E7EB',
    this.narrowWidth = 720,
    this.sidebarWidth = 248,
    this.sectionPad = 64,
    this.gutter = 24,
    this.band,
    this.siteFill,
    this.paneFill,
    this.iconTile,
    this.controlHeight,
    this.fieldLabel,
    this.fieldText,
    this.reflow = true,
    this.displaySizes = const {},
    this.projectVariables = const {},
    this.accentText,
  });

  /// The looks of [designSystem] ([NotationOptions.fromTheme] over its
  /// tokens) and the sizes of its components, so a component called by name
  /// (`StatusBadge "Paid"`, `Stepper =qty`) is as big as its own design says:
  /// as wide as its parent, as its content, or a size of its own.
  factory NotationOptions.fromDesignSystem(DesignSystem designSystem,
      {double width = 390, String screen = 'screen', bool named = false, bool reflow = true, Map<String, Json> projectVariables = const {}}) {
    final base = NotationOptions.fromTheme(designSystem.manifest.theme.toJson(), width: width, screen: screen, named: named, reflow: reflow);
    Object size(SizeFit fit, double value) => switch (fit) {
          SizeFit.fill || SizeFit.flexible => {'fill': 0},
          SizeFit.hug => {'hug': 0},
          _ => value,
        };
    return NotationOptions(
      width: base.width,
      screen: base.screen,
      textStyles: base.textStyles,
      card: base.card,
      badges: base.badges,
      surface: base.surface,
      accent: base.accent,
      track: base.track,
      badge: base.badge,
      cta: base.cta,
      palette: base.palette,
      tile: base.tile,
      sectionRadius: base.sectionRadius,
      barChart: base.barChart,
      progress: base.progress,
      cardGap: base.cardGap,
      pageFill: base.pageFill,
      ringStroke: base.ringStroke,
      contentWidth: base.contentWidth,
      line: base.line,
      selectedFill: base.selectedFill,
      narrowWidth: base.narrowWidth,
      sidebarWidth: base.sidebarWidth,
      sectionPad: base.sectionPad,
      gutter: base.gutter,
      band: base.band,
      siteFill: base.siteFill,
      paneFill: base.paneFill,
      iconTile: base.iconTile,
      controlHeight: base.controlHeight,
      fieldLabel: base.fieldLabel,
      fieldText: base.fieldText,
      reflow: base.reflow,
      displaySizes: base.displaySizes,
      projectVariables: projectVariables,
      accentText: base.accentText,
      components: {
        for (final c in designSystem.list)
          if (c.document.nodes[c.document.roots.firstOrNull] case final root?)
            c.type: (width: size(root.layout.width.fit, root.layout.width.value), height: size(root.layout.height.fit, root.layout.height.value)),
      },
    );
  }

  /// The looks of a design system's [theme] (its `theme` JSON: `colors`,
  /// `textStyles`, `radii`, the roles): its text styles by name with their
  /// colors written out, the short words mapped onto them, its card,
  /// badge tones, surface and accent. A UI written in the notation then
  /// looks like that design system with nothing else said.
  ///
  /// With [named], a look the theme has a name for is written as that name
  /// (a color `"primaryBorder"`, a text style `{"from": "pageTitle"}`), not
  /// its value: the document then follows whatever theme it is shown under
  /// (another design system with the same names, dark mode, an edited
  /// token) with nothing rewritten. It needs that theme to render; what the
  /// theme has no name for is still written as a value.
  factory NotationOptions.fromTheme(Json theme, {double width = 390, String screen = 'screen', bool named = false, bool reflow = true}) {
    final colors = readMap(theme['colors']) ?? const {};
    String color(String name, String fallback) {
      Object? c = colors[name] ?? theme[name];
      for (var i = 0; i < 8 && c is String && !c.startsWith('#'); i++) {
        c = colors[c] ?? theme[c];
      }
      if (c is! String || !c.startsWith('#')) return fallback;
      return named ? name : c;
    }

    final ink = color('primaryText', color('onSurface', '#FF111827'));
    final muted = color('secondaryText', ink), faint = color('tertiaryText', muted);
    final styles = <String, Object>{};
    for (final e in (readMap(theme['textStyles']) ?? const {}).entries) {
      final s = readMap(e.value);
      if (s == null) continue;
      styles[e.key] = named
          ? {'from': e.key, if (s['color'] == null) 'color': ink}
          : {
              for (final k in const ['fontSize', 'fontWeight', 'fontFamily', 'letterSpacing', 'height'])
                if (s[k] != null) k: s[k],
              'color': s['color'] is String ? color(s['color'] as String, ink) : ink,
            };
    }
    Object style(String name, Object fallback) => styles[name] ?? fallback;
    Json body() => {...(style('body', const {'fontSize': 13}) as Map).cast<String, Object?>()};
    styles
      ..putIfAbsent('title', () => style('pageTitle', defaultTextVariants['title']!))
      ..putIfAbsent('heading', () => style('sectionTitle', defaultTextVariants['heading']!))
      ..putIfAbsent('strong', () => body()..addAll({'fontWeight': 600, 'color': ink}))
      ..putIfAbsent('small', () => style('bodySecondary', defaultTextVariants['small']!))
      ..putIfAbsent('muted', () => body()..['color'] = muted)
      ..putIfAbsent('caption', () => {'fontSize': 11, 'color': faint})
      ..putIfAbsent('body', () => body()..['color'] = ink)
      ..putIfAbsent('danger', () => body()..addAll({'fontWeight': 600, 'color': color('error', '#FFDC2626')}))
      ..putIfAbsent('success', () => body()..addAll({'fontWeight': 600, 'color': color('success', '#FF16A34A')}));
    (String, String, String) tone(String role, String inkName) =>
        (color('${role}Tint', '#FFF3F4F6'), color('${role}TintBorder', '#FFE5E7EB'), color(inkName, ink));
    final error = tone('error', 'error');
    // A design system's own words for the look of plain parts, each read
    // only when the theme has it (SSUI has none of them): `radii.card`,
    // `shadows.card`, `spacing.card` and `colors.card` (a card), `colors
    // .page` (what the UI is drawn on), `radii.badge` and `sizes.badge` (a
    // badge), `sizes.cta` (a button alone on its line in a column, as wide
    // as the column).
    //
    // On a wide canvas (`sizes.wide` and up: a website page, an app window)
    // a name ending in `Wide` takes the place of the name before it:
    // `radii.cardWide` is the card's corner there, `textStyles.strongWide`
    // is `Text.strong`. One theme then serves a chat card and a page, and a
    // card keeps the card's looks wherever it is shown (it is written at
    // its own width).
    final wideFrom = readDouble(readMap(theme['sizes'])?['wide']);
    final isWide = wideFrom != null && width >= wideFrom;
    Json tier(String group) {
      final m = readMap(theme[group]) ?? const <String, Object?>{};
      if (!isWide) return m;
      return {
        ...m,
        for (final e in m.entries)
          if (e.key.length > 4 && e.key.endsWith('Wide')) e.key.substring(0, e.key.length - 4): e.value,
      };
    }

    final radii = tier('radii'), sizes = tier('sizes');
    final spacing = tier('spacing'), shadows = tier('shadows');
    final cardShadow = shadows['card'];
    final textStyles = readMap(theme['textStyles']) ?? const {};
    final badgeStyle = textStyles['badge'] != null && radii['badge'] != null ? styles['badge'] : null;
    final ctaHeight = switch (readDouble(sizes['cta'])) { final double h when h > 0 => h, _ => null };
    // On a wide canvas (`sizes.wide` and up) the title is the page's: the
    // theme's `titleWide` style, when it has both, for `Text.title` and
    // `Text.pageTitle` (a 20 px card title is small over a 1280 page).
    if (isWide) {
      for (final name in styles.keys.toList()) {
        if (name.length > 4 && name.endsWith('Wide')) styles[name.substring(0, name.length - 4)] = styles[name]!;
      }
      if (styles['titleWide'] != null && styles.containsKey('pageTitle')) styles['pageTitle'] = styles['titleWide']!;
    }
    return NotationOptions(
      width: width,
      screen: screen,
      textStyles: styles,
      card: {
        'decoration': {
          'fills': [
            {'color': color('card', color('primaryBackground', '#FFFFFFFF'))},
          ],
          'strokes': [
            {'color': color('primaryBorder', '#FFE5E7EB')},
          ],
          'radius': radii['card'] ?? radii['panel'] ?? theme['radius'] ?? 8,
          if (cardShadow is List && cardShadow.isNotEmpty) 'effects': jsonDecode(jsonEncode(cardShadow)),
        },
        'layout': {'padding': spacing['card'] ?? 12},
      },
      badge: {
        'radius': radii['badge'] ?? defaultBadge['radius'],
        'height': sizes['badge'] ?? defaultBadge['height'],
        'padding': switch (readDouble(spacing['badge'])) { final double x => [x, 0, x, 0], _ => defaultBadge['padding'] },
        'style': ?badgeStyle,
      },
      cta: ctaHeight == null ? null : {'width': {'fill': 0}, 'height': ctaHeight},
      palette: named ? _palette(colors, theme) : const {},
      progress: {
        if (radii['progress'] != null) 'borderRadius': radii['progress'],
        if (sizes['progress'] != null) 'height': sizes['progress'],
      },
      cardGap: spacing['cardGap'] is num ? spacing['cardGap'] as num : null,
      ringStroke: sizes['ring'] is num ? sizes['ring'] as num : null,
      contentWidth: readDouble(sizes['content']) ?? 1120,
      line: color('line', color('primaryBorder', '#FFE5E7EB')),
      selectedFill: color('activeTint', color('primaryTint', color('subtleFill', '#FFE5E7EB'))),
      narrowWidth: readDouble(sizes['narrow']) ?? 720,
      sidebarWidth: readDouble(sizes['sidebar']) ?? 248,
      sectionPad: readDouble(spacing['section']) ?? 64,
      gutter: readDouble(spacing['gutter']) ?? 24,
      band: colors['band'] != null ? color('band', '#FFF8FAFC') : null,
      siteFill: colors['pageFill'] != null ? color('pageFill', '#FFFFFFFF') : null,
      paneFill: colors['card'] != null ? color('card', '#FFFFFFFF') : null,
      iconTile: colors['iconTile'] != null ? color('iconTile', '#1A2563EB') : null,
      controlHeight: readDouble(sizes['control']),
      fieldLabel: isWide ? styles['fieldLabelWide'] : null,
      fieldText: isWide ? styles['inputTextWide'] : null,
      reflow: reflow,
      // A link in running text: the accent where it is read as text on a
      // light page (a bright accent is for fills).
      accentText: colors['accentText'] != null ? color('accentText', '#FF1D4ED8') : colors['accentDeep'] != null ? color('accentDeep', '#FF1D4ED8') : null,
      displaySizes: {
        for (final e in textStyles.entries)
          if (readMap(e.value)?['fontSize'] case final num size when size >= 32) e.key: size,
      },
      pageFill: named && colors['pageFill'] != null && colors['page'] != null ? (page: 'page', fill: 'pageFill') : null,
      barChart: radii['bar'] == null
          ? const {}
          : {
              'barRadius': radii['bar'],
              if (spacing['bar'] != null) 'barGap': spacing['bar'],
              if (sizes['bar'] != null) 'maxBarWidth': sizes['bar'],
              if (theme['fontFamily'] is String) 'labelFontFamily': theme['fontFamily'],
              'labelFontSize': 11,
              'labelColor': color('secondaryText', ink),
              'gridColor': color('primaryBorder', '#FFE5E7EB'),
            },
      sectionRadius: radii['card'] != null && radii['panel'] is num ? radii['panel'] as num : null,
      tile: radii['tile'] == null
          ? null
          : {
              'decoration': {
                'fills': [
                  {'color': color('card', color('primaryBackground', '#FFFFFFFF'))},
                ],
                'strokes': [
                  {'color': color('primaryBorder', '#FFE5E7EB')},
                ],
                'radius': radii['tile'],
              },
              'layout': {'padding': spacing['tile'] ?? 12},
            },
      badges: {
        'neutral': tone('neutral', 'secondaryText'),
        'primary': tone('primary', 'primary'),
        'info': tone('info', 'info'),
        'success': tone('success', 'success'),
        'warning': tone('warning', 'warning'),
        'error': error,
        'danger': error,
      },
      surface: color('page', color('surface', color('primaryBackground', '#FFFFFFFF'))),
      accent: color('primary', '#FF2563EB'),
      track: color('track', '#FFE5E7EB'),
    );
  }

  /// These looks for another canvas (an overlay's): its id and its width.
  NotationOptions sized({required double width, required String screen}) => NotationOptions(
        width: width,
        screen: screen,
        textStyles: textStyles,
        card: card,
        badges: badges,
        surface: surface,
        accent: accent,
        track: track,
        components: components,
        badge: badge,
        cta: cta,
        palette: palette,
        tile: tile,
        sectionRadius: sectionRadius,
        barChart: barChart,
        progress: progress,
        cardGap: cardGap,
        pageFill: pageFill,
        ringStroke: ringStroke,
        height: height,
        contentWidth: contentWidth,
        selectedFill: selectedFill,
        line: line,
        narrowWidth: narrowWidth,
        sidebarWidth: sidebarWidth,
        sectionPad: sectionPad,
        gutter: gutter,
        band: band,
        siteFill: siteFill,
        paneFill: paneFill,
        iconTile: iconTile,
        controlHeight: controlHeight,
        fieldLabel: fieldLabel,
        fieldText: fieldText,
        reflow: false,
        displaySizes: displaySizes,
      );

  /// The canvas's width.
  final double width;

  /// The canvas's id (its variables' scope).
  final String screen;

  /// `Text.<variant>`: a style object, or a theme text style's name.
  final Map<String, Object> textStyles;

  /// What `Card` adds to a column: decoration and padding.
  final Json card;

  /// `Badge.<tone>`: its fill, hairline and ink.
  final Map<String, (String, String, String)> badges;

  /// What the UI is drawn on when its root is not a card.
  final String surface;

  /// The color of what has none of its own (a chart's bars and line, a
  /// progress bar's fill).
  final String accent;

  /// What a progress bar's fill runs along.
  final String track;

  /// A design system's components by type, each with the width and height
  /// a call takes when it writes none (a number, `{fill: 0}` or `{hug: 0}`).
  final Map<String, ({Object width, Object height})> components;

  /// What a `BarChart` takes unless the line says (`barRadius`, `barGap`,
  /// `maxBarWidth`, its labels' font and colors): a theme's `radii.bar`,
  /// `spacing.bar` and `sizes.bar`. Empty: the chart's own defaults.
  final Json barChart;

  /// What a theme's looks give `Progress`: `borderRadius` (its
  /// `radii.progress`) and `height` (its `sizes.progress`). Empty: a 2 px
  /// corner at the bar's own height.
  final Json progress;

  /// The space between a `Card`'s children when it writes no `gap`: a
  /// theme's `spacing.cardGap`. Null: none.
  final num? cardGap;

  /// A neutral fill written on the page itself (not inside a card) that the
  /// theme reads as a color equal to the page's would not show: it is
  /// written as `fill` instead (a theme's `colors.pageFill`, with `page` the
  /// page color's name). Null: as read.
  final ({String page, String fill})? pageFill;

  /// How thick a `Ring` is drawn: a theme's `sizes.ring`. Null: the
  /// control's own.
  final num? ringStroke;

  /// The height of the window an app is drawn in (`App`, or a root written
  /// `h:fill`): the canvas's design height.
  final double height;

  /// The widest a page section's content gets (`Section`, `Nav`, `Footer`):
  /// a theme's `sizes.content`.
  final double contentWidth;

  /// The widths of a narrow section's content and of a sidebar, a
  /// section's padding above and below, and a page's side gutter: a
  /// theme's `sizes.narrow`, `sizes.sidebar`, `spacing.section` and
  /// `spacing.gutter`.
  final double narrowWidth, sidebarWidth, sectionPad, gutter;

  /// A tinted section's fill (`Section tint`), what a website page is drawn
  /// on, an app's sidebar and top bar, and the tile behind an icon: a
  /// theme's `colors.band`, `pageFill`, `card` and `iconTile`. Null: none.
  final String? band, siteFill, paneFill, iconTile;

  /// The styles of a field's label and of its text on a page: a theme's
  /// `fieldLabelWide` and `inputTextWide`. Null: the control's own.
  final Object? fieldLabel, fieldText;

  /// Whether a page (a canvas 700 wide or wider) is given the media rules
  /// that lay it out on a tablet and a phone ([PageReflow]): its rows wrap,
  /// its grids take fewer columns, its headlines shrink. False: the page is
  /// written for its one width only.
  final bool reflow;

  /// The variables of the whole site (site.json's `variables`), by name,
  /// each as the manifest has it (`name`, `type`, `value`): a page reads
  /// and sets them with no declaration and no copy of its own on the screen
  /// (which would hide the site's). `project name=value` on a page does the
  /// same for one name.
  final Map<String, Json> projectVariables;

  /// The accent as text on a light page (a link in running text): a theme's
  /// `colors.accentText`, else its `accentDeep`. Null: the accent.
  final String? accentText;

  /// The theme's text styles of a headline's size (32 and up), by name →
  /// font size: a text in one of them is smaller on a phone.
  final Map<String, num> displaySizes;

  /// The height of a button, a field and a select that write none: a
  /// theme's `sizes.control`. Null: the control's own (its compact step).
  final double? controlHeight;

  /// The fill of a selected `NavItem` and the hairline of a pane's edge and
  /// a bar's rule: a theme's `neutralFill` and `line`.
  final String selectedFill, line;

  /// What a `Card` inside a card adds (a row of options, a tile in a grid
  /// of cards): smaller corners, no shadow. Null: the same as [card].
  final Json? tile;

  /// The corner of a `Card` that is one section of a larger UI (a card on a
  /// page, beside others): a theme's `radii.panel` when it also has
  /// `radii.card`, which is then the corner of a card that is the whole UI
  /// (one card in a chat). Null: the same as [card].
  final num? sectionRadius;

  /// What `Badge` is: its `radius`, `height`, `padding` and, when given, the
  /// `style` of its text (else 11, medium, in the tone's ink).
  final Json badge;

  /// The layout of a button alone on its line in a column (not a ghost or
  /// icon button): as wide as the column at the design system's height for
  /// its one thing to do. Null: it is as big as its label, as any control.
  final Json? cta;

  /// The theme's colors a written color is read as, by name → `#AARRGGBB`
  /// ([NotationOptions.fromTheme] with `named`): `fill:#FFF5F5F5` on a
  /// panel is the theme's nearest neutral fill, and so follows dark mode and
  /// the theme. Empty: a written color stays as written.
  final Map<String, String> palette;

  /// The theme's name for [hex] written as a [kind] (`fill`, `stroke`,
  /// `text`), when one of the [palette] is close to it; else null.
  String? colorName(String hex, String kind) {
    if (palette.isEmpty) return null;
    final want = _argb(hex);
    if (want == null || want >> 24 != 0xFF) return null;
    final names = switch (kind) { 'text' => _textColors, 'stroke' => _strokeColors, _ => _fillColors };
    final base = _argb(palette['primaryBackground'] ?? palette['surface'] ?? '#FFFFFFFF') ?? 0xFFFFFFFF;
    String? best;
    var bestD = double.infinity;
    for (final n in names) {
      final v = palette[n] == null ? null : _argb(palette[n]!);
      if (v == null) continue;
      final d = _distance(want, _over(v, base));
      if (d < bestD - .5) {
        bestD = d;
        best = n;
      }
    }
    return bestD <= _snapDistance ? best : null;
  }
}

/// SSUI's badge: a 20-high pill-cornered row, 8 at its sides.
const Json defaultBadge = {
  'radius': 5,
  'height': 20,
  'padding': [8, 0, 8, 0],
};

/// The names a written color may be read as, by what it colors, in order of
/// preference when two are as near (SSUI's role and neutral names).
const _fillColors = [
  'primaryBackground', 'subtleFill', 'secondaryBackground', 'tertiaryBackground', 'neutralFill', 'track',
  'primaryTint', 'successTint', 'warningTint', 'errorTint', 'infoTint',
  'primary', 'success', 'warning', 'error', 'info', 'primaryText',
];
const _strokeColors = [
  'primaryBorder', 'secondaryBorder', 'primaryTintBorder', 'successTintBorder', 'warningTintBorder', 'errorTintBorder',
  'infoTintBorder', 'primary', 'success', 'warning', 'error', 'info',
];
const _textColors = [
  'primaryText', 'secondaryText', 'tertiaryText', 'onPrimary', 'primary', 'success', 'warning', 'error', 'info',
];

/// How far (redmean RGB) a written color may be from the theme's to be read
/// as it: a gray for a gray, a blue for the blue, not a brand's own hue.
const double _snapDistance = 40;

/// The theme's colors [_fillColors], [_strokeColors] and [_textColors] name,
/// resolved to values (a role or a name of another color followed).
Map<String, String> _palette(Json colors, Json theme) {
  final out = <String, String>{};
  for (final n in {..._fillColors, ..._strokeColors, ..._textColors, 'surface', 'page'}) {
    Object? c = colors[n] ?? theme[n];
    for (var i = 0; i < 8 && c is String && !c.startsWith('#'); i++) {
      c = colors[c] ?? theme[c];
    }
    if (c is String && _argb(c) != null) out[n] = c;
  }
  return out;
}

int? _argb(String hex) {
  if (!hex.startsWith('#')) return null;
  var h = hex.substring(1);
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  return int.tryParse(h, radix: 16);
}

/// [c] drawn over the opaque [base].
int _over(int c, int base) {
  final a = (c >> 24 & 0xFF) / 255;
  int ch(int s) => ((c >> s & 0xFF) * a + (base >> s & 0xFF) * (1 - a)).round();
  return 0xFF000000 | ch(16) << 16 | ch(8) << 8 | ch(0);
}

double _distance(int a, int b) {
  final r1 = a >> 16 & 0xFF, g1 = a >> 8 & 0xFF, b1 = a & 0xFF;
  final r2 = b >> 16 & 0xFF, g2 = b >> 8 & 0xFF, b2 = b & 0xFF;
  final rm = (r1 + r2) / 2, dr = r1 - r2, dg = g1 - g2, db = b1 - b2;
  // A tint is not a gray: near white, a light blue and a light gray are
  // close in value, so how colored each is weighs as well.
  final c1 = math.max(r1, math.max(g1, b1)) - math.min(r1, math.min(g1, b1));
  final c2 = math.max(r2, math.max(g2, b2)) - math.min(r2, math.min(g2, b2));
  return math.sqrt((2 + rm / 256) * dr * dr + 4 * dg * dg + (2 + (255 - rm) / 256) * db * db) / 3 + 1.5 * (c1 - c2).abs();
}

/// SSUI's text styles (design_systems/ssui/design_system.json, `theme
/// .textStyles` with its colors), written out so a document needs no
/// theme: SSUI's own names, and the short words an agent reaches for.
const Map<String, Object> defaultTextVariants = {
  // SSUI's names.
  'pageTitle': {'fontSize': 20, 'fontWeight': 600, 'color': '#FF111827'},
  'heading1': {'fontSize': 30, 'fontWeight': 700, 'color': '#FF111827'},
  'heading2': {'fontSize': 24, 'fontWeight': 700, 'color': '#FF111827'},
  'heading3': {'fontSize': 18, 'fontWeight': 600, 'color': '#FF111827'},
  'sectionTitle': {'fontSize': 14, 'fontWeight': 600, 'color': '#FF111827'},
  'panelTitle': {'fontSize': 12, 'fontWeight': 600, 'color': '#FF111827'},
  'body': {'fontSize': 13, 'color': '#FF111827'},
  'bodySecondary': {'fontSize': 12, 'color': '#FF4B5563'},
  'fieldLabel': {'fontSize': 11.5, 'fontWeight': 600, 'color': '#FF4B5563'},
  'caption': {'fontSize': 11, 'color': '#FF9CA3AF'},
  'mono': {'fontSize': 12, 'fontFamily': 'monospace', 'color': '#FF111827'},
  // Short words: each is one of SSUI's styles or its body in a role color.
  'title': {'fontSize': 20, 'fontWeight': 600, 'color': '#FF111827'},
  'heading': {'fontSize': 14, 'fontWeight': 600, 'color': '#FF111827'},
  'strong': {'fontSize': 13, 'fontWeight': 600, 'color': '#FF111827'},
  'small': {'fontSize': 12, 'color': '#FF4B5563'},
  'muted': {'fontSize': 13, 'color': '#FF4B5563'},
  'danger': {'fontSize': 13, 'fontWeight': 600, 'color': '#FFDC2626'},
  'success': {'fontSize': 13, 'fontWeight': 600, 'color': '#FF16A34A'},
};

/// SSUI's card (components/Card.json): the panel's fill, hairline and
/// radius, its body's padding and gap.
const Json defaultCard = {
  'decoration': {
    'fills': [
      {'color': '#FFFFFFFF'},
    ],
    'strokes': [
      {'color': '#FFE5E7EB'},
    ],
    'radius': 8,
  },
  'layout': {'padding': 12},
};

/// The text parameters of a component that the strings on its line fill, in
/// order (at most two): its label, title or text first, then the next of
/// its message, description and the like; any other text parameter last.
List<String> notationStrings(WidgetSpec spec) {
  bool text(PropDef<Object?> p) => p.type.kind == PropKind.string && !p.type.isVariable;
  const order = ['label', 'title', 'text', 'name', 'message', 'description', 'subtitle', 'why', 'detail', 'code', 'fileName', 'operation', 'note', 'placeholder'];
  final keys = [
    for (final k in order)
      if (spec.props.any((p) => p.key == k && text(p))) k,
  ];
  if (keys.isEmpty) {
    keys.addAll([for (final p in spec.props) if (text(p) && p.required) p.key]);
  }
  return keys.take(2).toList();
}

/// Short names: what an agent writes → the node type and what it implies.
const Map<String, ({String type, Json node})> notationTypes = {
  'Input': (type: 'textField', node: {}),
  'Toggle': (type: 'switch', node: {}),
  'Select': (type: 'dropdown', node: {}),
  'Button': (type: 'filledButton', node: {}),
  'Progress': (type: 'progressBar', node: {}),
  // The words a model reaches for unprompted for a round meter, a round
  // share and a small trend line (design 16: asked with no vocabulary, it
  // writes gauge, dial, ring, sparkline).
  'Gauge': (type: 'radialGauge', node: {}),
  'Dial': (type: 'radialGauge', node: {}),
  'Ring': (type: 'circularProgressIndicator', node: {}),
  'Sparkline': (type: 'lineChart', node: {}),
  // Shares of a whole, and a line chart that fills under its line.
  'Donut': (type: 'chart', node: {}),
  'DonutChart': (type: 'chart', node: {}),
  'PieChart': (type: 'chart', node: {}),
  'Pie': (type: 'chart', node: {}),
  'AreaChart': (type: 'lineChart', node: {}),
  // A person as a round mark: their initials, or their picture.
  'Avatar': (type: 'column', node: {}),
  'List': (type: 'column', node: {}),
  'Badge': (type: 'row', node: {}),
  // A grid of the children written under it: rows of `cols` equal cells.
  'Grid': (type: 'column', node: {}),
  'GridView': (type: 'column', node: {}),
  'Image': (type: 'box', node: {}),
  'Box': (type: 'column', node: {}),
  'Card': (type: 'column', node: {}),
  // Pages swiped across, one at a time: the lines under it are its pages
  // (or, under an `each`, one page per element).
  'Pages': (type: 'pageView', node: {}),
  // A part no component fits, built from plain parts under it; the line
  // names the component wanted for it (see [WantedBlock]).
  'Wanted': (type: 'column', node: {}),
};

/// `Button.<variant>`: the button type and props it stands for.
const Map<String, ({String type, Json props})> buttonVariants = {
  'primary': (type: 'filledButton', props: {}),
  'secondary': (type: 'filledButton', props: {'tonal': true}),
  'tertiary': (type: 'filledButton', props: {'tonal': true}),
  'outline': (type: 'outlinedButton', props: {}),
  'ghost': (type: 'textButton', props: {}),
  'elevated': (type: 'elevatedButton', props: {}),
  'destructive': (
    type: 'filledButton',
    props: {
      'style': {'backgroundColor': '#FFDC2626', 'foregroundColor': '#FFFFFFFF'},
    },
  ),
};

/// The prop a control's value lives in, and the variable type it implies.
const Map<String, ({String prop, String type, Object? start})> _valueProps = {
  'slider': (prop: 'value', type: 'decimal', start: 0),
  'switch': (prop: 'value', type: 'boolean', start: false),
  'checkbox': (prop: 'value', type: 'boolean', start: false),
  'textField': (prop: 'initialValue', type: 'text', start: ''),
  'dropdown': (prop: 'value', type: 'text', start: ''),
  'radio': (prop: 'groupValue', type: 'text', start: ''),
  'segmentedButton': (prop: 'selected', type: 'text', start: ''),
  'datePicker': (prop: 'value', type: 'text', start: ''),
  'timePicker': (prop: 'value', type: 'text', start: ''),
  // The page shown, from 0: a swipe writes it, and setting it turns the page.
  'pageView': (prop: 'initialPage', type: 'decimal', start: 0),
};

const _shortKeys = {'gap': 'props.spacing', 'pad': 'layout.padding', 'w': 'layout.width', 'h': 'layout.height', 'grow': 'layout.flex'};
/// Keys a model reaches for that a type spells otherwise.
const Map<String, Map<String, List<String>>> _typeKeys = {
  'textField': {
    'hint': ['props.decoration.hintText'],
    'placeholder': ['props.decoration.hintText'],
    'label': ['props.decoration.labelText'],
    'helper': ['props.decoration.helperText'],
    'error': ['props.decoration.errorText'],
  },
  'dropdown': {
    'placeholder': ['props.hint'],
  },
  'gridView': {
    'cols': ['props.crossAxisCount'],
    'columns': ['props.crossAxisCount'],
    'gap': ['props.mainAxisSpacing', 'props.crossAxisSpacing'],
    'spacing': ['props.mainAxisSpacing', 'props.crossAxisSpacing'],
  },
  'pageView': {
    // The share of the width one page takes: under 1, the next page shows at the edge.
    'peek': ['props.viewportFraction'],
  },
};

/// What `=expr` binds on a type that shows a value but takes no input.
const Map<String, String> _shownValue = {'progressBar': 'value', 'circularProgressIndicator': 'value', 'radialGauge': 'value', 'text': 'text'};

/// The short names a design system's component of the same name replaces.
const _softNames = {'Gauge', 'Dial', 'Ring', 'Sparkline', 'Avatar', 'Donut', 'DonutChart', 'PieChart', 'Pie', 'AreaChart'};

/// The core types a design system's component of the same name replaces: a
/// design system's own `Tabs` (a row of labels that keeps the open one in a
/// variable, `Tabs =tab tabs:["Overview","Activity"]`) is what the line
/// means, not the core `tabs` node (titles over children, which the
/// notation does not teach).
const notationComponentFirst = {'Tabs'};

/// The colors of a chart's series or slices that write none, after the
/// accent.
const _chartColors = ['#FF0891B2', '#FF9333EA', '#FF16A34A', '#FFEA580C', '#FF9CA3AF', '#FFDB2777'];

/// `animate:<word>`: how a node arrives or keeps moving, as a model writes
/// it, by the animation preset and params it stands for. An entrance plays
/// once when the node appears (from a pose to the node's own); a loop keeps
/// going; an effect plays once.
const Map<String, Json> notationAnimations = {
  'fade': {'preset': 'enter', 'params': {'from': {'opacity': 0}}},
  'fade-up': {'preset': 'enter', 'params': {'from': {'opacity': 0, 'translateY': 16}}},
  'slide': {'preset': 'enter', 'params': {'from': {'opacity': 0, 'translateY': 16}}},
  'slide-up': {'preset': 'enter', 'params': {'from': {'opacity': 0, 'translateY': 16}}},
  'slide-down': {'preset': 'enter', 'params': {'from': {'opacity': 0, 'translateY': -16}}},
  'slide-left': {'preset': 'enter', 'params': {'from': {'opacity': 0, 'translateX': 24}}},
  'slide-right': {'preset': 'enter', 'params': {'from': {'opacity': 0, 'translateX': -24}}},
  'scale': {'preset': 'enter', 'params': {'from': {'opacity': 0, 'scale': 0.9}}},
  'zoom': {'preset': 'enter', 'params': {'from': {'opacity': 0, 'scale': 0.9}}},
  'pulse': {'preset': 'pulse', 'params': {'scaleFrom': 1, 'scaleTo': 1.06, 'opacityFrom': 1, 'opacityTo': 0.7}},
  'spin': {'preset': 'spin'},
  'bob': {'preset': 'bob'},
  'sway': {'preset': 'sway'},
  'pop': {'preset': 'pop', 'autoplay': true},
  'bounce': {'preset': 'bounce', 'autoplay': true},
  'shake': {'preset': 'shake', 'autoplay': true},
  'wiggle': {'preset': 'wiggle', 'autoplay': true},
  'flash': {'preset': 'flash', 'autoplay': true},
  'shimmer': {'preset': 'shimmer'},
};

/// A time as a model writes it (`600`, `600ms`, `0.6s`), in milliseconds.
int? _milliseconds(String raw) {
  final m = RegExp(r'^(\d+(?:\.\d+)?)(ms|s)?$').firstMatch(raw.trim());
  if (m == null) return null;
  final n = double.parse(m[1]!);
  return (m[2] == 's' ? n * 1000 : n).round();
}

/// `Badge.<tone>`: SSUI's badge tones (components/Badge.json) as fill,
/// hairline and ink: a 10 % tint of the tone, its 28 % border, the tone.
const Map<String, (String, String, String)> badgeVariants = {
  'neutral': ('#FFF3F4F6', '#FFE5E7EB', '#FF4B5563'),
  'primary': ('#1A2563EB', '#472563EB', '#FF2563EB'),
  'info': ('#1A0891B2', '#470891B2', '#FF0891B2'),
  'success': ('#1A16A34A', '#4716A34A', '#FF16A34A'),
  'warning': ('#1AEA580C', '#47EA580C', '#FFEA580C'),
  'error': ('#1ADC2626', '#47DC2626', '#FFDC2626'),
  'danger': ('#1ADC2626', '#47DC2626', '#FFDC2626'),
};

/// Keys written on a Text that belong to its style.
const _textStyleKeys = {
  'color': 'color', 'size': 'fontSize', 'fontSize': 'fontSize', 'weight': 'fontWeight', 'fontWeight': 'fontWeight',
  'bold': 'fontWeight', 'fontFamily': 'fontFamily', 'font': 'fontFamily', 'lineHeight': 'height',
};

const _layoutKeys = {'width', 'height', 'padding', 'margin', 'flex', 'aspectRatio', 'x', 'y', 'align', 'constraints', 'order', 'basis'};
const _decorationKeys = {'radius', 'strokeWidth', 'fills', 'strokes', 'effects', 'clip', 'shape'};
const _borderSides = {
  'border-bottom': 'bottom', 'border-top': 'top', 'border-left': 'left', 'border-right': 'right', //
  'borderBottom': 'bottom', 'borderTop': 'top', 'borderLeft': 'left', 'borderRight': 'right', 'border-b': 'bottom', 'border-t': 'top', 'border-l': 'left', 'border-r': 'right',
};
const _mainWords = {'start': 'start', 'center': 'center', 'end': 'end', 'between': 'spaceBetween', 'around': 'spaceAround', 'evenly': 'spaceEvenly'};
const _crossWords = {'top': 'start', 'left': 'start', 'middle': 'center', 'bottom': 'end', 'right': 'end', 'stretch': 'stretch'};

/// [text] in the compact notation as a layout document. Never throws: what
/// cannot be read is reported and skipped.
NotationResult parseNotation(String text, {Catalog? catalog, NotationOptions options = const NotationOptions()}) =>
    _Parser(catalog ?? Catalog.current, options).parse(text);

/// The notation read as it arrives: [add] takes text in any chunks and
/// returns the edit operations of the lines completed so far (a `set` per
/// node under its parent, `vars` for the state a line introduced), ready
/// for `applyOps`; [close] gives the last line's.
final class NotationStream {
  NotationStream({Catalog? catalog, NotationOptions options = const NotationOptions()})
      : _parser = _Parser(catalog ?? Catalog.current, options);

  final _Parser _parser;
  final _buffer = StringBuffer();

  /// What could not be read so far.
  List<NotationIssue> get issues => List.unmodifiable(_parser.issues);

  /// The components the answer asked for so far (`Wanted "Name" "what it shows"`).
  List<WantedBlock> get wanted => List.unmodifiable(_parser.wanted);

  List<Json> add(String chunk) {
    _buffer.write(chunk);
    final text = _buffer.toString();
    final end = text.lastIndexOf('\n');
    if (end < 0) return const [];
    _buffer
      ..clear()
      ..write(text.substring(end + 1));
    text.substring(0, end).split('\n').forEach(_parser.line);
    return _take();
  }

  List<Json> close() {
    final rest = _buffer.toString();
    _buffer.clear();
    if (rest.isNotEmpty) _parser.line(rest);
    _parser.finish();
    return _take();
  }

  List<Json> _take() {
    final out = [..._parser.ops];
    _parser.ops.clear();
    return out;
  }
}

/// A `Grid`'s rows as its children arrive.
class _Grid {
  _Grid(this.id);
  final String id;
  int cols = 2;
  num gap = 8;
  String? row;
  int inRow = 0;
  int rows = 0;
}

class _Open {
  _Open(this.indent, this.id, this.type, {this.condition, this.grid, this.each, this.list, this.pages});

  /// A `Pages` above: [id] is its page (one template drawn per page), and
  /// each line under it is a page of its own, shown at its position.
  final String? pages;

  /// The list an `each` above repeats over, as written.
  final String? list;

  /// An `each <name> in …` above: the name its lines call an item by.
  final String? each;

  /// A grid above (its own line, or an `if` inside it): children go in its
  /// rows.
  final _Grid? grid;
  final int indent;

  /// The node children are added to (a condition's: its parent's).
  final String id;
  final String type;

  /// An `if` above: its children are bound visible to it.
  final String? condition;
}

class _Parser {
  _Parser(this.catalog, this.options, [this._host, this._overlay])
      : variables = _host?.variables ?? {},
        issues = _host?.issues ?? [],
        wanted = _host?.wanted ?? [],
        _declared = _host?._declared ?? {},
        _counts = _host?._counts ?? {},
        _derived = _host?._derived ?? {},
        _projectVariables = _host?._projectVariables ?? {} {
    // The site's variables (its manifest's): known here, and never declared on the screen.
    if (_host == null) {
      for (final e in options.projectVariables.entries) {
        variables.putIfAbsent(e.key, () => {'name': e.key, 'type': e.value['type'] ?? 'text', 'value': e.value['value']});
        _projectVariables.add(e.key);
      }
    }
  }
  final Catalog catalog;
  final NotationOptions options;

  /// For an overlay's canvas (a `Dialog#id` block and the like): the
  /// parser of the page it is written after, whose state it shares (the
  /// variables, the ids), and the block it is.
  final _Parser? _host;
  final Overlay? _overlay;

  /// The overlays written so far, each a canvas of its own with its nodes,
  /// and the one whose lines are being read.
  final _overlays = <_Parser>[];
  _Parser? _block;

  /// Whether the block being read is left out (its id was taken).
  bool _blockSkipped = false;

  /// What `open <id>` adds for each overlay written (its presentation), and
  /// the open actions written, to complete once their overlay is.
  final _overlayActions = <String, Json>{};
  final _opens = <Json>[];

  /// The open actions a right click or a long press runs: a menu or a
  /// popover they open sits where the pointer is, not by the node.
  final _pointerOpens = Set<Json>.identity();

  void _atPointer(Json action) {
    if (action['type'] != 'openModal') return;
    _top._pointerOpens.add(action);
    if (action['presentation'] == 'popover') action['anchor'] = 'pointer';
  }

  _Parser get _top => _host ?? this;

  /// The document's canvases: the page, then its overlays.
  List<String> get _rootIds => [_top.options.screen, for (final o in _top._overlays) o.options.screen];

  /// Where the variables are declared: on the page's canvas, or, once the
  /// page has overlays, for every canvas of the document (an overlay reads
  /// and sets the page's values).
  String get _scope => _top._overlays.isEmpty ? options.screen : 'page_variables';

  bool _taken(String id) {
    final top = _top;
    return [top, ...top._overlays].any((p) => p.nodes.containsKey(id) || p.options.screen == id);
  }

  /// Whether a line is still open over the next ones.
  bool get _continues => _everyOpen != null || _pending != null || _open != null;

  /// The canvas of this parser's nodes.
  Json get _canvasNode {
    final o = _overlay;
    Json look() {
      if (o == null) return _surface;
      if (!o.surface) {
        return {
          'fills': [
            {'color': '#00FFFFFF'},
          ],
        };
      }
      return {
        'fills': _copyValue(readMap(options.card['decoration'])?['fills']) ?? _surface['fills'],
        if (o.radius > 0) 'radius': o.radius,
        if (o.outlined)
          'strokes': [
            {'color': options.line},
          ],
        'effects': [
          {'type': 'dropShadow', 'color': '#24000000', 'offset': [0, 12], 'blurRadius': 32, 'spreadRadius': -6},
        ],
      };
    }

    return {
      'type': 'canvas',
      if (o != null) 'name': o.id,
      if (_root != null) 'slots': {'body': _root},
      'layout': {'width': o?.width ?? options.width, 'height': _canvasHeight},
      'decoration': look(),
      if (_timers.isNotEmpty) 'actions': [..._timers],
    };
  }

  /// A top-level `Dialog#id`, `Sheet#id`, `Drawer#id`, `Menu#id`,
  /// `Popover#id` or `Lightbox#id` line: the lines under it are a canvas of
  /// their own, which `open <id>` shows over the page.
  void _openBlock(Overlay o) {
    if (_taken(o.id)) {
      _issue(1, 'The id "${o.id}" is used twice.');
      _blockSkipped = true;
      return;
    }
    final first = _overlays.isEmpty;
    // In it everything is laid out as on a card: a narrow canvas of its own.
    final sub = _Parser(catalog, options.sized(width: o.width < 640 ? o.width : 640, screen: o.id), this, o);
    _overlays.add(sub);
    _overlayActions[o.id] = o.action;
    for (final a in _opens) {
      if (a['to'] == o.id) {
        a.addAll(_copy(o.action));
        if (_pointerOpens.contains(a)) _atPointer(a);
      }
    }
    if (_canvas) {
      // The variables become the document's, so the overlay reads and sets them.
      final names = [
        for (final n in _declared)
          if (!_projectVariables.contains(n) && variables.containsKey(n)) n,
      ];
      if (first && names.isNotEmpty) {
        ops
          ..add({'op': 'vars', 'scope': options.screen, 'remove': names})
          ..add({
            'op': 'vars',
            'scope': 'page_variables',
            'set': {
              for (final n in names) n: {'type': variables[n]!['type'], 'value': variables[n]!['value']},
            },
          });
      }
      // What opens it, written before it: now with how it is shown.
      for (final p in [this, ..._overlays]) {
        for (final e in p.nodes.entries) {
          final actions = e.value['actions'];
          if (actions != null && jsonEncode(actions).contains('"to":"${o.id}"')) {
            ops.add({'op': 'patch', 'id': e.key, 'patch': {'actions': actions}});
          }
        }
      }
    }
    // What it keeps (a lightbox's zoom, the picture it shows).
    for (final e in o.variables.entries) {
      final value = switch (e.value) {
        final String s when s.startsWith('[') => _json(s) ?? const <Object?>[],
        final v => v,
      };
      variables.putIfAbsent(e.key, () => {'name': e.key, 'type': value is List ? 'list' : value is num ? 'decimal' : 'text', 'value': value});
    }
    _block = sub;
    _blockLines.clear();
    for (final l in o.head) {
      _feed(l.indent - o.shift, l.text, closes: 'none');
    }
  }

  /// The lines written under the block being read, each with its indent.
  final _blockLines = <PageLine>[];

  /// A line of the block being read, [indent] in from its head.
  void _feed(int indent, String text, {String? closes}) {
    final sub = _block;
    if (sub == null) return;
    final o = sub._overlay!;
    sub._line = _line - 1;
    sub.line('${' ' * (indent + o.shift)}${PageWords.closing(text, closes ?? o.closes)}');
    ops.addAll(sub.ops);
    sub.ops.clear();
  }

  void _closeBlock() {
    _blockSkipped = false;
    final sub = _block;
    if (sub == null) return;
    final o = sub._overlay!;
    // With nothing written under it, what it shows by itself.
    final written = _blockLines.isEmpty ? o.empty : [..._blockLines];
    if (_blockLines.isEmpty) {
      for (final l in o.empty) {
        _feed(l.indent, l.text, closes: 'none');
      }
    }
    for (final l in o.foot) {
      if (l.text == Overlay.lines) {
        // The lines written under it, read again here (without their ids;
        // a picture fills its thumbnail).
        final first = written.isEmpty ? 0 : written.map((w) => w.indent).reduce(math.min);
        for (final w in written) {
          _feed(l.indent - o.shift + w.indent - first, w.text.replaceFirstMapped(_idMark, (m) => m[1]!).replaceAll(' fit:contain', ' fit:cover'), closes: 'none');
        }
        continue;
      }
      _feed(l.indent - o.shift, l.text, closes: 'none');
    }
    _blockLines.clear();
    _block = null;
    sub.finish();
    ops.addAll(sub.ops);
    sub.ops.clear();
  }

  final nodes = <String, Json>{};
  final Map<String, Json> variables;
  final List<NotationIssue> issues;
  final List<WantedBlock> wanted;

  /// The edit operations of the lines read so far, not yet taken ([take]).
  final ops = <Json>[];
  final Set<String> _declared;
  final Map<String, int> _counts;
  final _stack = <_Open>[];
  String? _root;
  int _line = 0;

  /// Reads one line (without its newline).
  /// An `every …` line written with no `->`: its actions may follow on the
  /// next line (`  -> n=n+1`), which a model writes as readily.
  String? _everyOpen;

  void line(String raw) {
    // The lines under an overlay's head are its canvas's; the next line at
    // the margin ends it.
    if (_host == null && !_continues) {
      final indent = raw.length - raw.trimLeft().length;
      final blank = raw.trim().isEmpty || raw.trimLeft().startsWith('//');
      if ((_block != null || _blockSkipped) && (indent > 0 || blank || (_block?._continues ?? false))) {
        _line++;
        if (!blank || (_block?._continues ?? false)) {
          if (_block != null && !blank) _blockLines.add((indent: indent, text: raw.trim()));
          _feed(indent, raw.trim());
        }
        return;
      }
      if (!blank && indent == 0) {
        _closeBlock();
        if (_pages.overlay(raw.trim()) case final Overlay o) {
          _line++;
          _openBlock(o);
          return;
        }
      }
    }
    if (_everyOpen case final String open) {
      _everyOpen = null;
      if (raw.trimLeft().startsWith('->')) {
        raw = '$open ${raw.trimLeft()}';
      } else {
        line('$open ->');
      }
    } else if (RegExp(r'^every\s+\S+').hasMatch(raw) && !raw.contains('->') && !raw.trimRight().endsWith(':') && !RegExp(r'\b(do|on[A-Z])').hasMatch(raw)) {
      _everyOpen = raw.trimRight();
      return;
    }
    _line++;
    // A `node {…}` or `document {…}` whose JSON is not closed goes on over
    // the next lines, until it is.
    if (_pending case final String open) {
      final all = '$open\n$raw';
      if (_jsonOpen(all)) {
        _pending = all;
        return;
      }
      _pending = null;
      raw = all;
    } else if (_wholeJsonLine.hasMatch(raw) && _jsonOpen(raw)) {
      _pending = raw;
      return;
    }
    // A list or a call left open at the end of a line goes on over the
    // next lines (items:=[ and one element a line), joined as one.
    if (_open case final String open) {
      final all = '$open ${raw.trim()}';
      _openLines++;
      if (_opened(all) > 0 && _openLines < 60) {
        _open = all;
        return;
      }
      _open = null;
      raw = all;
    } else if (RegExp(r'[\[(,]\s*$').hasMatch(raw) && _opened(raw) > 0 && !raw.trimLeft().startsWith('//')) {
      _open = raw.trimRight();
      _openLines = 0;
      return;
    }
    if (raw.trim().isEmpty || raw.trimLeft().startsWith('//')) return;
    // An answer wrapped in a code fence: the fence is not notation.
    if (raw.trimLeft().startsWith('```')) return;
    final indent = raw.length - raw.trimLeft().length;
    final before = nodes.length;
    // `Dots =page count:n`: a dot per page, the current one long and in the
    // accent; a tap on a dot goes to its page. Written out as the three
    // lines it stands for.
    // An answer that opens with `if` or `each` has several top-level parts
    // and no root to hold them: they stack in a column of their own.
    if (_root == null && indent == 0 && RegExp(r'^(if|each)\s').hasMatch(raw.trim())) {
      _lineAt(-1, 'Column gap:12', 0);
    }
    final dots = _dotsLine.firstMatch(raw.trim());
    if (dots != null) {
      String look(String c) => c.startsWith('#')
          ? '"$c"'
          : const {'primary', 'onPrimary', 'surface', 'onSurface', 'error', 'success', 'warning'}.contains(c)
              ? 'theme.$c'
              : 'theme.colors.$c';
      final page = dots[2]!, count = dots[3]!.startsWith('=') ? dots[3]!.substring(1) : dots[3]!;
      variables.putIfAbsent(page, () => {'name': page, 'type': 'decimal', 'value': 0});
      _lineAt(indent, 'Row${dots[1] ?? ''} gap:6 center middle h:16${dots[4] ?? ''}', indent + 1);
      _lineAt(indent + 2, 'each dot in range($count)', indent + 3);
      _lineAt(indent + 4, 'Box w:=index==$page?16:6 h:6 radius:3 fill:=index==$page?${look(options.accent)}:${look(options.track)} -> $page=index', indent + 5);
    } else {
      for (final l in _pages.rewrite(indent, raw.trim())) {
        // A frame's line says which frame it is (Row~nav): kept for the reflow.
        final role = _roleMark.firstMatch(l.text);
        // The menu a Nav opens on a phone keeps whether it is open.
        if (l.text.contains('navMenu')) variables.putIfAbsent('navMenu', () => {'name': 'navMenu', 'type': 'boolean', 'value': false});
        // What a gallery opens in the page's viewer: its photos and the one tapped.
        if (_pages.viewerUsed) {
          final viewer = _pages.viewer!;
          variables.putIfAbsent('${viewer}Photos', () => {'name': '${viewer}Photos', 'type': 'list', 'value': const <Object?>[]});
          variables.putIfAbsent('${viewer}At', () => {'name': '${viewer}At', 'type': 'decimal', 'value': 0});
          for (final e in _pages.viewerLists.entries) {
            variables.putIfAbsent(e.key, () => {'name': e.key, 'type': 'list', 'value': _json(e.value) ?? const <Object?>[]});
          }
        }
        _lastNode = null;
        _lineAt(l.indent, role == null ? l.text : '${role[1]}${l.text.substring(role.end)}', l.indent + 1);
        if (role != null && _lastNode != null) _roles[_lastNode!] = role[2]!;
      }
    }
    final added = nodes.keys.skip(before).toList();
    if (added.isEmpty) {
      _emit(null);
    } else {
      added.forEach(_emit);
    }
  }

  /// The page words (Page, Section, Nav, App, Sidebar, Main…), written out
  /// as the plain lines they stand for before a line is read.
  late final _pages = PageWords(
    contentWidth: options.contentWidth,
    narrowWidth: options.narrowWidth,
    sidebarWidth: options.sidebarWidth,
    sectionPad: options.sectionPad,
    gutter: options.gutter,
    band: options.band,
    siteFill: options.siteFill,
    paneFill: options.paneFill,
    iconTile: options.iconTile,
    accentName: options.accent,
    accentText: options.accentText,
    accent: options.accent.startsWith('#') ? options.accent : '#FF2563EB',
    selectedFill: options.selectedFill,
    line: options.line,
    textVariants: options.textStyles.keys.toSet(),
    isComponent: (name) => notationTypes[name] == null && catalog.widget(name) != null,
    isFrame: (name) => notationTypes[name] == null && catalog.widget(name)?.children == ChildModel.list,
    roles: true,
    menu: options.reflow && options.width >= 700,
    sidebarMenu: _host == null && options.reflow && options.width >= 700 ? '${options.screen}Menu' : null,
    surface: options.surface,
    viewer: _host == null && options.width >= 700 ? '${options.screen}Viewer' : null,
    takesViewer: (name) {
      if (notationTypes[name] != null) return false;
      final spec = catalog.widget(name);
      return spec != null &&
          spec.props.any((p) => p.key == 'photos') &&
          spec.props.any((p) => p.key == 'viewer' && p.type.kind == PropKind.enumeration && p.type.values.contains('overlay'));
    },
  );

  static final _roleMark = RegExp(r'^([A-Z][A-Za-z0-9]*)~([a-z]+)');

  /// The node the line just read made, and the frames among the nodes
  /// (`app`, `nav`, `section`, `sidebar`, `main`, `pane`), a grid's rows
  /// and the rows whose columns share their width: what [PageReflow] reads.
  String? _lastNode;
  final _roles = <String, String>{};
  final _gridRows = <String, _Grid>{};

  /// The anchors (`#why` after a line) by name → the node, and the scroll
  /// actions written, which name an anchor or an id.
  final _anchors = <String, String>{};
  final _scrolls = <Json>[];

  /// The names written `project name`: variables of the site, not of this screen.
  final Set<String> _projectVariables;
  final _tableRows = <String>{};

  /// On a page, the media rules that lay it out on a tablet and a phone.
  void _reflow() {
    if (!options.reflow || options.width < 700) return;
    final rules = PageReflow(
      nodes: nodes,
      roles: _roles,
      gridRows: {
        for (final e in _gridRows.entries) e.key: (cols: e.value.cols, gap: e.value.gap),
      },
      cards: _cards,
      tableRows: _tableRows,
      displaySizes: options.displaySizes,
      isComponent: (type) => type.isNotEmpty && type[0].toUpperCase() == type[0] && catalog.widget(type) != null,
      fillsItsPlace: (type) => switch (options.components[type]?.width) { final Map m => m.containsKey('fill'), _ => false },
    ).run();
    for (final e in rules.entries) {
      final node = nodes[e.key]!;
      // The line's own rules (hide:phone) come after, so they win.
      final media = [...e.value, ...?(node['media'] as List?)];
      node['media'] = media;
      if (_canvas) ops.add({'op': 'patch', 'id': e.key, 'patch': {'media': media}});
    }
  }

  /// Whether the UI is as tall as its window (an app's panes, a root
  /// written `h:fill`): the canvas then has the window's height, where a
  /// card or a website page is as tall as its content.
  bool _windowed = false;

  /// The accent as a value: a slice's or a series' color is data, where a
  /// theme's name is not read.
  String get _accentValue => options.accent.startsWith('#') ? options.accent : options.palette[options.accent] ?? '#FF2563EB';

  Object get _canvasHeight => _windowed ? {'fill': options.height} : {'hug': 0};

  /// A line begun and not yet closed (its JSON runs over several lines).
  String? _pending;

  /// A line whose list or call is still open, and how many lines it took.
  String? _open;
  int _openLines = 0;
  static final _wholeJsonLine = RegExp(r'^\s*(?:node(?:#[A-Za-z_][A-Za-z0-9_]*)?|document)\s*\{');

  /// Whether the JSON that starts at the first `{` of [s] is still open.
  static bool _jsonOpen(String s) {
    var depth = 0, quoted = false;
    for (var i = s.indexOf('{'); i >= 0 && i < s.length; i++) {
      final c = s[i];
      if (quoted) {
        if (c == r'\') {
          i++;
        } else if (c == '"') {
          quoted = false;
        }
      } else if (c == '"') {
        quoted = true;
      } else if (c == '{' || c == '[') {
        depth++;
      } else if (c == '}' || c == ']') {
        depth--;
      }
    }
    return depth > 0 || quoted;
  }

  /// The operations the line just read adds: the variables it introduced,
  /// then its node under its parent (the first node under a new canvas).
  void _emit(String? id) {
    if (id != null && _skipEmit.remove(id)) return;
    // The root as tall as what holds it: the window (an app's panes).
    if (id != null && _parentOf[id] == null && !_windowed && id != 'pageRoot') {
      final height = (nodes[id]?['layout'] as Map?)?['height'];
      if (_pages.app || (height is Map && height.containsKey('fill'))) {
        _windowed = true;
        // The canvas may be there already (a `state` line came first).
        if (_canvas) _patches.add({'op': 'patch', 'id': options.screen, 'patch': {'layout': {'height': _canvasHeight}}});
      }
    }
    final screen = options.screen;
    final fresh = {
      for (final v in variables.values)
        if (!_projectVariables.contains(v['name']) && _declared.add(v['name']! as String)) v['name']! as String: {'type': v['type'], 'value': v['value']},
    };
    if (id == null && fresh.isEmpty) return;
    if (!_canvas) {
      _canvas = true;
      ops
        ..add({'op': 'roots', 'roots': _rootIds})
        ..add({'op': 'set', 'id': screen, 'node': _canvasNode..remove('slots')});
    }
    if (fresh.isNotEmpty) ops.add({'op': 'vars', 'scope': _scope, 'set': fresh});
    ops.addAll(_patches);
    _patches.clear();
    if (id == null) return;
    final node = {...nodes[id]!}..remove('children');
    final parent = _parentOf[id];
    final slot = parent == null ? 'body' : _slotOf[id];
    ops.add({'op': 'set', 'id': id, 'parent': parent ?? screen, if (slot != null) 'slot': slot, 'node': node..remove('slots')});
  }

  bool _canvas = false;

  /// The nodes written as `Card`.
  final _cards = <String>{};

  /// A row whose children's written widths add up to more than the canvas
  /// is wide (a table's columns in a card): the widths become shares of the
  /// row, so the columns keep their proportions and fit. A row that scrolls
  /// keeps its widths.
  void _fitRow(_Open open) {
    final row = nodes[open.id];
    if (open.type != 'row' || row == null || (row['props'] as Map?)?['scrollable'] == true) return;
    final children = [
      for (final c in (row['children'] as List? ?? const []))
        if (nodes[c] case final Json n) (c as String, n),
    ];
    final fixed = [
      for (final (id, n) in children)
        if ((n['layout'] as Map?)?['width'] case final num w when w > 0 && n['type'] == 'text') (id, n, w),
    ];
    if (fixed.length < 2) return;
    final gap = (row['props'] as Map?)?['spacing'];
    num total = (gap is num ? gap : 0) * (children.length - 1);
    for (final (_, n) in children) {
      final w = (n['layout'] as Map?)?['width'];
      total += w is num ? w : 0;
    }
    // On a page a row of columns sits in a pane narrower than the window
    // (beside a sidebar, in a card): from half the window on it is a
    // table's row, and its columns are shares of the place it has.
    final limit = options.width >= 700 && fixed.length >= 3 ? options.width / 2 : options.width - 24;
    if (total <= limit) return;
    // …the cells that are rows or columns of their own (a name beside its
    // picture) with the texts.
    if (options.width >= 700) {
      for (final (id, n) in children) {
        final w = (n['layout'] as Map?)?['width'];
        if (w is num && w >= 80 && (n['type'] == 'row' || n['type'] == 'column')) fixed.add((id, n, w));
      }
    }
    // A cell that already grows (the name's column, written `grow`) is the
    // widest: its share is counted in the same unit as the others' widths.
    _tableRows.add(open.id);
    final widest = fixed.fold<num>(0, (m, f) => f.$3 > m ? f.$3 : m);
    for (final (id, n) in children) {
      final flex = (n['layout'] as Map?)?['flex'];
      if (flex is num && flex > 0 && flex < 20 && n['type'] != 'spacer' && !fixed.any((f) => f.$1 == id)) {
        final share = flex * widest * 1.5;
        n['layout'] = (n['layout']! as Map).cast<String, Object?>()..['flex'] = share;
        _patches.add({
          'op': 'patch',
          'id': id,
          'patch': {
            'layout': {'flex': share},
          },
        });
      }
    }
    for (final (id, n, w) in fixed) {
      final layout = (n['layout']! as Map).cast<String, Object?>()
        ..['width'] = {'fill': 0}
        ..['flex'] = w;
      n['layout'] = layout;
      _patches.add({
        'op': 'patch',
        'id': id,
        'patch': {
          'layout': {'width': {'fill': 0}, 'flex': w},
        },
      });
    }
  }

  /// The column that holds a page's top-level sections, once there is more
  /// than one: made on the second, with the first moved into it. Later
  /// top-level lines (an `if`, an `each`) find it as their parent.
  String _pageColumn() {
    const page = 'pageRoot';
    if (_root == page) return page;
    final first = _root!;
    nodes[page] = {
      'type': 'column',
      'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
      'props': {'crossAxisAlignment': 'stretch'},
      'children': <Object?>[first],
    };
    _parentOf[first] = page;
    _root = page;
    // Sent now, in this order: the column in the screen's body, then the
    // first section moved into it.
    final node = {...nodes[page]!}..remove('children');
    ops
      ..add({'op': 'set', 'id': page, 'parent': options.screen, 'slot': 'body', 'node': node})
      ..add({'op': 'move', 'id': first, 'parent': page, 'index': 0});
    _skipEmit.add(page);
    _stack.insert(0, _Open(-1, page, 'column'));
    return page;
  }

  final _skipEmit = <String>{};

  /// The stacks that center their children, by id: the words written
  /// (`center`, `middle`).
  final _stackAlign = <String, Set<String>>{};

  /// The `stagger:` an `each` line carried, for the row written under it.
  int? _eachStagger;

  /// The `every` lines: timers on the canvas.
  final _timers = <Json>[];
  final _parentOf = <String, String>{};
  final _slotOf = <String, String>{};

  /// The item of an `each` → its list, for one that may yet share a row's width.
  final _acrossLists = <String, String>{};

  /// Changes a line makes to a node already sent (a grid's row height).
  final _patches = <Json>[];

  /// Texts a line's strings stand for on a type whose text is a child: an
  /// accordion's header, a list tile's title and subtitle.
  final _texts = <String>[];

  /// The style of the line's own strings, when its type sets one (a badge).
  Json? _textStyle;

  /// A label that reads state (`Button "Step {n}"`): bound, since only a
  /// text node reads expressions as written.
  final _labelBinds = <String, String>{};

  Json? _documentPatch;

  NotationResult parse(String text) {
    const LineSplitter().convert(text).forEach(line);
    finish();
    final patch = _documentPatch;
    Json patched(Json d) => patch == null ? d : mergePatch(d, patch);
    return NotationResult(patched({
      'schema': 3,
      'roots': _rootIds,
      'nodes': {
        for (final p in [this, ..._overlays]) ...{
          p.options.screen: p._canvasNode,
          ...p.nodes,
        },
      },
      if (variables.values.any((v) => !_projectVariables.contains(v['name'])))
        'variables': {_scope: variables.values.where((v) => !_projectVariables.contains(v['name'])).toList()},
    }), issues, wanted: List.unmodifiable(wanted));
  }

  void _issue(int column, String message) => issues.add(NotationIssue(_line, column, message));

  void _lineAt(int indent, String source, int column) {
    var line = source;
    while (_stack.isNotEmpty && _stack.last.indent >= indent) {
      _close(_stack.removeLast());
    }
    // Inside an `each x in …`, x is the document's `item`.
    // In an `each` inside an `each` (a board's cards in its columns), the
    // inner one's x is `item` and the outer one's is the item around it.
    final eaches = [
      for (final open in _stack)
        if (open.each != null) open.each!,
    ];
    for (var k = 0; k < eaches.length; k++) {
      final around = eaches.length - 1 - k;
      final to = around == 0 ? 'item' : '${'parent.' * (around - 1)}parent.item';
      if (eaches[k] != to) line = _rename(line, eaches[k], to);
    }
    // The small model marks a name with `$` (`$total`, `"{money($total)}"`):
    // the name is the same without it. A price ("$24") and an interpolation
    // already written (`${…}`) keep their sign.
    if (line.contains(r'$')) line = line.replaceAllMapped(RegExp(r'(?<!\\)\$(?=[A-Za-z_])'), (_) => '');
    // …and declares what the card remembers as `name = value` on a line of
    // its own, before the card.
    if (_root == null && indent == 0) {
      final bare = RegExp(r'^([a-z_][A-Za-z0-9_]*)\s*=(?!=)\s*(.+)$').firstMatch(line);
      if (bare != null && !const {'state', 'let', 'derived', 'const', 'var'}.contains(bare[1])) line = 'state ${bare[1]}=${bare[2]}';
    }
    // What models write unprompted for these (SDK tool/values, three models):
    // `let` or `derived` for a worked-out value, `for x in list`, `else`.
    final declared = RegExp(r'^(?:let|derived|const|var)\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)$').firstMatch(line);
    if (declared != null) line = 'state ${declared[1]}=${declared[2]}';
    final loop = RegExp(r'^for\s+(?:[A-Za-z_][A-Za-z0-9_]*\s*,\s*)?([A-Za-z_][A-Za-z0-9_]*)\s+in\s+(.+)$').firstMatch(line);
    if (loop != null) line = 'each ${loop[1]} in ${loop[2]}';
    // `project cart=[]` (or `project cart`): a variable of the whole site
    // (site.json's `variables`), read and set here as any other, with no
    // copy of its own on this screen to hide it.
    if (line.startsWith('project ') && _root == null) {
      final rest = line.substring(8).trim();
      final name = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)s*(=|$)').firstMatch(rest)?.group(1);
      if (name == null) return _issue(column, 'A site\x27s variable is written: project name=value (the same name as in site.json\x27s variables).');
      _projectVariables.add(name);
      return _state(rest.contains('=') ? rest : '$name=""', column + 8);
    }
    if (line.startsWith('state ')) return _state(line.substring(6).trim(), column + 6);
    // `every 1000 -> elapsed=elapsed+1`, `every 1s when running -> …`: what
    // the screen does as time passes (a timer on the canvas).
    // As models write it: every 1s while:{running} onTick:{…}, every 1s when running: …
    final tick = RegExp(r'^every\s+(\d+(?:\.\d+)?(?:ms|s)?)\s+(?:when|while)\s*:?\s*\{?(.+?)\}?\s*(?:->|on[A-Z][A-Za-z]*\s*:|do\s*:|:)\s*\{?(.+?)\}?$').firstMatch(line);
    if (tick != null && !line.contains('->')) line = 'every ${tick[1]} when ${tick[2]} -> ${_statements(tick[3]!)}';
    final every = RegExp(r'^every\s+(\d+(?:\.\d+)?)(ms|s)?(?:\s+when\s+(.+?))?\s*->\s*(.+)$').firstMatch(line);
    if (every != null) {
      final ms = (double.parse(every[1]!) * (every[2] == 's' ? 1000 : 1)).round();
      if (ms < 16) return _issue(column, 'An "every" runs at most once a frame: every 16 or more (milliseconds), or every 1s.');
      _timers.add({
        'trigger': {'type': 'timer', 'intervalMs': ms, if (every[3] != null) 'when': _formula(every[3]!.trim())},
        'actions': _actions(every[4]!.trim(), column),
      });
      if (_canvas) _patches.add({'op': 'patch', 'id': options.screen, 'patch': {'actions': [..._timers]}});
      return;
    }
    if (line.startsWith('every ')) {
      return _issue(column, 'An "every" line is: every 1000 -> name=value (milliseconds, or 1s), optionally "every 1s when running -> …".');
    }
    // `document {…}`: a merge patch over the whole document, for what is
    // not a node of the tree (the printer's last line).
    if (indent == 0 && line.startsWith('document {')) {
      final j = _json(line.substring(9));
      if (j is Map) _documentPatch = mergePatch(_documentPatch ?? const {}, j.cast<String, Object?>(), keepNulls: true);
      return;
    }
    // A property written after the actions (`-> step = 3 enabled:{valid}`)
    // belongs to the node: it is read before the arrow.
    final late = RegExp(r'^(.*?)(\s->\s.*?)((?:\s+(?:enabled|visible|selected|disabled|tone|icon):(?:=?\{[^{}]*\}|=\S+|"[^"]*"|[A-Za-z_][A-Za-z0-9_.]*))+)\s*$').firstMatch(line);
    if (late != null) line = '${late[1]}${late[3]}${late[2]}';
    for (final d in _derived.entries) {
      if (!line.contains(d.key)) continue;
      // A worked-out value follows the state by itself: an action that sets
      // it too (`-> votes=…; total=total+1`) is dropped, not rewritten.
      final arrow = line.indexOf(' -> ');
      if (arrow >= 0) {
        final k = RegExp.escape(d.key);
        final actions = line.substring(arrow + 4).replaceAll(RegExp('(^|;)\\s*$k\\s*(?:[-+*/])?=(?!=)[^;]*'), '').replaceFirst(RegExp(r'^\s*;\s*'), '');
        line = actions.trim().isEmpty ? line.substring(0, arrow) : '${line.substring(0, arrow)} -> $actions';
        if (!line.contains(d.key)) continue;
      }
      // A call on the name (`total.toFixed(2)`) is rewritten while it is
      // still a name: written out, it is a formula no call pattern follows.
      if (line.contains('${d.key}.')) {
        final k = RegExp.escape(d.key);
        line = line
            .replaceAllMapped(RegExp('(?<![A-Za-z0-9_.])$k\\.toFixed\\((\\d+)\\)'), (m) => 'fixed(${d.key},${m[1]})')
            .replaceAllMapped(RegExp('(?<![A-Za-z0-9_.])$k\\.length\\b(?!\\()'), (m) => 'length(${d.key})')
            .replaceAllMapped(RegExp('(?<![A-Za-z0-9_.])$k\\.([a-zA-Z]+)\\((\\)?)'), (m) {
          if (!_methods.contains(m[1])) return m[0]!;
          return m[2] == ')' ? '${m[1]}(${d.key})' : '${m[1]}(${d.key},';
        });
      }
      line = _rename(line, d.key, '(${d.value})');
    }
    final parent = _stack.isEmpty ? null : _stack.last;
    // A handler on a line of its own under its control (`onPressed: a = 1`).
    final handler = RegExp(r'^(on[A-Z][A-Za-z]*|tap|press|click|change)\s*:\s*(.+)$').firstMatch(line);
    if (handler != null && parent != null && nodes[parent.id] != null && !(catalog.widget(nodes[parent.id]!['type']! as String)?.props.any((p) => p.key == handler[1]) ?? false)) {
      final target = nodes[parent.id]!;
      final type = target['type']! as String;
      final spec = catalog.widget(type);
      final isComponent = spec != null && type[0].toUpperCase() == type[0];
      var body = handler[2]!.trim();
      if (body.startsWith('{') && body.endsWith('}')) body = body.substring(1, body.length - 1);
      final reaction = {'trigger': _handlerTrigger(handler[1]!, type, isComponent ? spec : null, target), 'actions': _actions(_statements(body), column)};
      final actions = [...?(target['actions'] as List?), reaction];
      target['actions'] = actions;
      _patches.add({'op': 'patch', 'id': parent.id, 'patch': {'actions': actions}});
      return;
    }
    // `else` and `else if …` after an `if` at the same depth: shown while
    // none of the conditions before it holds.
    final otherwise = RegExp(r'^else(?:\s+if\s+(.+))?$').firstMatch(line);
    if (otherwise != null) {
      final before = _ifAt[indent];
      if (parent == null || before == null) return _issue(column, 'An "else" follows an "if" at the same depth.');
      String inner(String f) => f.substring(4, f.length - 1);
      final not = _formula('!(${inner(before)})');
      final own = otherwise[1] == null ? not : _and(not, _formula(otherwise[1]!.trim()));
      if (otherwise[1] == null) {
        _ifAt.remove(indent);
      } else {
        _ifAt[indent] = _formula('(${inner(before)}) || (${otherwise[1]!.trim()})');
      }
      _stack.add(_Open(indent, parent.id, parent.type, condition: _and(parent.condition, own), grid: parent.grid));
      return;
    }
    if (line.startsWith('if ')) {
      if (parent == null && _root != null) {
        _pageColumn();
        return _lineAt(indent, source, column);
      }
      if (parent == null) return _issue(column, 'An "if" needs a parent: indent it under a node.');
      final own = _formula(line.substring(3).trim());
      _ifAt[indent] = own;
      _stack.add(_Open(indent, parent.id, parent.type, condition: _and(parent.condition, own), grid: parent.grid));
      return;
    }
    // Anything else at this depth ends the chance of an `else`.
    _ifAt.removeWhere((depth, _) => depth >= indent);
    // `each rows` and `List =rows` are `each row in rows`: the element is
    // read as `row` (or `item`).
    final bare = RegExp(r'^each\s+(\S+)$').firstMatch(line) ?? RegExp(r'^List\s+=(\S+)$').firstMatch(line);
    if (bare != null) line = 'each row in ${bare[1]}';
    // `each a in list stagger:80`: the row under it arrives that much after
    // the one before (its own animate:, or a fade up).
    if (RegExp(r'^each\s.*\s(stagger:\S+)$').firstMatch(line.trimRight()) case final RegExpMatch m) {
      line = line.trimRight();
      _eachStagger = _milliseconds(m[1]!.substring(8));
      line = line.substring(0, line.length - m[1]!.length).trimRight();
    }
    final each = RegExp(r'^each\s+([A-Za-z_][A-Za-z0-9_]*)\s+in\s+(.+)$').firstMatch(line);
    if (each != null) {
      if (parent == null && _root != null) {
        _pageColumn();
        return _lineAt(indent, source, column);
      }
      if (parent == null) return _issue(column, 'An "each" needs a parent: indent it under a node.');
      // Under Pages, one page per element: the page view repeats its page.
      if (parent.pages case final String pagesId) {
        final data = {'data': _read(each[2]!.trim())};
        final view = nodes[pagesId]!;
        view['bind'] = {...?(view['bind'] as Map?)?.cast<String, Object?>(), ...data};
        (view['props'] as Map?)?.remove('itemCount');
        _patches.add({'op': 'patch', 'id': pagesId, 'patch': {'bind': data, 'props': {'itemCount': null}}});
        _stack.add(_Open(indent, parent.id, 'column', each: each[1], list: each[2]!.trim(), pages: pagesId));
        return;
      }
      // A list over the data, its item a column of the lines under it.
      final g = parent.grid;
      final listId = _id(g != null ? 'gridView' : 'listView'), itemId = '${listId}Item';
      // In a stack the copies are layered, each where its own x and y say:
      // the line under the `each` is the item itself.
      if (g == null && parent.type == 'stack') {
        final id = _id('listView');
        nodes[id] = {
          'type': 'listView',
          'layout': {'width': {'fill': 0}, 'height': {'fill': 0}, 'x': 0, 'y': 0},
          'props': {'layout': 'stack'},
          'bind': {'data': _read(each[2]!.trim()), if (parent.condition != null) 'visible': parent.condition},
          'children': <Object?>[],
        };
        final p = nodes[parent.id]!;
        ((p['children'] as List<Object?>?) ?? (p['children'] = <Object?>[])).add(id);
        _parentOf[id] = parent.id;
        _stack.add(_Open(indent, id, 'stack', each: each[1], list: each[2]!.trim()));
        return;
      }
      // In a row the copies go across, each at its own width.
      final across = g == null && parent.type == 'row';
      _acrossLists[itemId] = listId;
      nodes[listId] = {
        'type': g != null ? 'gridView' : 'listView',
        'layout': {'width': across ? {'hug': 0} : {'fill': 0}, 'height': {'hug': 0}},
        // Under a Grid, the repeated lines are its cells.
        'props': g != null
            ? {'crossAxisCount': g.cols, 'mainAxisSpacing': g.gap, 'crossAxisSpacing': g.gap, 'shrinkWrapRows': true, 'physics': 'never'}
            : across
                ? {'scrollable': false, 'scrollDirection': 'horizontal', 'spacing': (nodes[parent.id]?['props'] as Map?)?['spacing'] ?? 0}
                : {'scrollable': false, 'spacing': (nodes[parent.id]?['props'] as Map?)?['spacing'] ?? 0},
        'bind': {'data': _read(each[2]!.trim()), if (parent.condition != null) 'visible': parent.condition},
        'children': <Object?>[itemId],
      };
      final p = nodes[parent.id]!;
      ((p['children'] as List<Object?>?) ?? (p['children'] = <Object?>[])).add(listId);
      _parentOf[listId] = parent.id;
      nodes[itemId] = {
        'type': 'column',
        'layout': across ? {'width': {'hug': 0}, 'height': {'fill': 0}} : {'width': {'fill': 0}, 'height': {'hug': 0}},
        'props': {'crossAxisAlignment': 'start', if (across) 'mainAxisAlignment': 'center'},
      };
      _parentOf[itemId] = listId;
      _stack.add(_Open(indent, itemId, 'column', each: each[1], list: each[2]!.trim()));
      return;
    }
    // Props written after the action (`-> size="7" selected:=size=="7"`)
    // belong before it.
    final arrow = _outside(line, ' -> ');
    if (arrow >= 0) {
      final after = line.substring(arrow + 4);
      final late = RegExp(r' [a-z][A-Za-z]*:=').allMatches(after).where((m) => _outside(after.substring(0, m.start + 1), '"') < 0 || '"'.allMatches(after.substring(0, m.start)).length.isEven).firstOrNull;
      if (late != null) line = '${line.substring(0, arrow)}${after.substring(late.start)} -> ${after.substring(0, late.start)}';
    }
    // `node {…}`: a node written whole, as the document holds it, for what
    // the notation has no words for (a painted board, a draggable list).
    // Nothing is added to it but its place; the lines under it are its
    // children, in the notation or as nodes again.
    final whole = RegExp(r'^node(?:#([A-Za-z_][A-Za-z0-9_]*))?\s*(\{[\s\S]*)$').firstMatch(line);
    if (whole != null) {
      final j = _json(whole[2]!);
      if (j == null) return;
      final type = j is Map ? j['type'] : null;
      if (j is! Map || type is! String) {
        return _issue(column, 'A node line is: node {"type": "…", …}, the whole node as JSON with its type.');
      }
      if (catalog.widget(type) == null) {
        return _issue(column, 'No node type "$type". A node line takes the document\'s own type names (column, row, stack, text, icon, customPaint…): see the reference\'s nodes page.');
      }
      if (type == 'canvas') return _issue(column, 'A canvas cannot be written as a node line: the screen is made for you.');
      final out = _copy(j.cast<String, Object?>());
      final written = out.remove('id');
      final id = whole[1] ?? (written is String ? written : _id(type));
      if (_taken(id)) return _issue(column, 'There is already a node "$id": ids are unique.');
      if (parent?.condition case final String c) {
        final bind = (out['bind'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
        final own = bind['visible'];
        bind['visible'] = own is String ? _and(c, own) : c;
        out['bind'] = bind;
      }
      if (parent == null) {
        if (_root != null) return _issue(column, 'A second root: the first line is the root, everything else is indented under it.');
        _root = id;
      } else {
        final p = nodes[parent.id]!;
        ((p['children'] as List<Object?>?) ?? (p['children'] = <Object?>[])).add(id);
        _parentOf[id] = parent.id;
      }
      nodes[id] = out;
      _stack.add(_Open(indent, id, type));
      return;
    }
    // `Text.small.muted`: one variant is read, the first.
    line = line.replaceFirstMapped(RegExp(r'^([A-Za-z][A-Za-z0-9]*\.[A-Za-z][A-Za-z0-9]*)(?:\.[A-Za-z][A-Za-z0-9]*)+'), (m) => m[1]!);
    final t = _Tokens(line);
    final head = RegExp(r'^([A-Za-z][A-Za-z0-9]*)(?:\.([A-Za-z][A-Za-z0-9]*))?(?:#([A-Za-z_][A-Za-z0-9_]*))?').firstMatch(line);
    if (head == null) return _issue(column, 'A line starts with a node type: Column, Text "…", Button "…".');
    t.at = head.end;
    final written = head[1]!, variant = head[2];
    // A design system's own Gauge, Ring, Sparkline or Avatar comes before the
    // notation's.
    final short = _softNames.contains(written) && catalog.widget(written) != null ? null : notationTypes[written];
    var type = short?.type ?? '${written[0].toLowerCase()}${written.substring(1)}';
    // A design system's component, called by its own name (`StatusBadge`,
    // `Stepper`): a core type of that name, or a short name, comes first.
    final component =
        short == null && (catalog.widget(type) == null || notationComponentFirst.contains(written)) && catalog.widget(written) != null;
    // Whether the notation's own Gauge, Ring, Avatar… is what this line is
    // (not a design system's component of that name).
    final ours = short != null;
    if (component) type = written;
    // The text parameters a component's strings fill, and the ones filled so.
    var strings = const <String>[];
    final positional = <String>[];
    final node = <String, Object?>{};
    final props = <String, Object?>{}, layout = <String, Object?>{}, decoration = <String, Object?>{}, bind = <String, Object?>{};
    final reactions = <Json>[];
    // `center` and `middle` on a Stack; `animate:` and its timing.
    Set<String>? stackAlign;
    Json? animation;
    Map<String, int>? timing;
    num? sliderStep;
    String? swipe;
    String? textLine;
    num? avatarSize;
    String? imageFit;
    Json? buttonLook;
    String? gaugeUnit;
    List<({String label, Object? value, Object? color})>? donutKeys;

    if (written == 'Button' && variant != null) {
      final v = buttonVariants[variant];
      if (v == null) {
        _issue(column + written.length + 1, 'No Button.$variant. Variants: ${buttonVariants.keys.join(', ')}.');
      } else {
        type = v.type;
        props.addAll(_copy(v.props));
      }
    } else if (type == 'text' && variant != null) {
      final style = options.textStyles[variant];
      if (style == null) {
        _issue(column + written.length + 1, 'No Text.$variant. Variants: ${options.textStyles.keys.join(', ')}.');
      } else {
        props['style'] = style is Map ? _copy(style.cast<String, Object?>()) : style;
      }
    } else if (written == 'Badge') {
      // SSUI's badge: a tinted pill-cornered row 20 high around its text.
      final v = options.badges[variant ?? 'neutral'];
      if (v == null) {
        _issue(column + written.length + 1, 'No Badge.$variant. Variants: ${options.badges.keys.join(', ')}.');
      }
      final tone = v ?? options.badges['neutral'] ?? badgeVariants['neutral']!;
      final look = options.badge;
      decoration.addAll({
        'fills': [
          {'color': tone.$1},
        ],
        'strokes': [
          {'color': tone.$2},
        ],
        'radius': look['radius'] ?? 5,
      });
      layout.addAll({'width': {'hug': 0}, 'height': look['height'] ?? 20, 'padding': _copyValue(look['padding'] ?? const [8, 0, 8, 0])});
      props.addAll({'mainAxisAlignment': 'center', 'crossAxisAlignment': 'center'});
      _textStyle = switch (look['style']) {
        final Map m => {...m.cast<String, Object?>(), 'color': tone.$3},
        final String name => {'from': name, 'color': tone.$3},
        _ => {'fontSize': 11, 'fontWeight': 500, 'color': tone.$3},
      };
    } else if (variant != null) {
      _issue(column + written.length + 1, 'A $written has no variants: write $written, with props as key:value.');
    }
    final spec = catalog.widget(type);
    if (spec == null) {
      // A sentence before the UI ("Here is the card:") is not a node.
      // Nor is one after it ("Two limits remain: …").
      if ((_root == null || indent == 0) && line.contains(' ')) return;
      _issue(column, 'No node type "$written". Write a type of the catalog (Column, Row, Text, Button, Input, Toggle, Slider…).');
      return;
    }
    if (component) strings = notationStrings(spec);
    if (written == 'Card') {
      // In a card, a card is a tile of it.
      var inCard = false;
      for (String? at = parent?.id; at != null && !inCard; at = _parentOf[at]) {
        inCard = _cards.contains(at);
      }
      final look = inCard ? options.tile ?? options.card : options.card;
      decoration.addAll(_copy(readMap(look['decoration']) ?? const {}));
      layout.addAll(_copy(readMap(look['layout']) ?? const {}));
      // A card that is one section of a larger UI (not the UI itself, not
      // in a card) takes the smaller section corner where the theme has one.
      if (!inCard && parent != null && options.sectionRadius != null) {
        // In a grid it is a tile among tiles: the tile's corner.
        final tile = parent.grid == null ? null : readMap(options.tile?['decoration'])?['radius'];
        decoration['radius'] = tile ?? options.sectionRadius;
      }
    }
    final id = head[3] ?? _id((written == 'Grid' || written == 'GridView') ? 'grid' : type);
    final grid = (written == 'Grid' || written == 'GridView') ? _Grid(id) : null;
    if (written == 'Card') _cards.add(id);
    if (grid != null) props['spacing'] = grid.gap;
    if (_taken(id)) {
      _issue(column, 'The id "$id" is used twice.');
      return;
    }
    _lastNode = id;

    void put(String path, Object? value) {
      final dot = path.indexOf('.');
      final where = dot < 0 ? '' : path.substring(0, dot), key = dot < 0 ? path : path.substring(dot + 1);
      switch (where) {
        case 'props':
          final sub = key.indexOf('.');
          if (sub < 0) {
            props[key] = value;
          } else {
            final inner = (props[key.substring(0, sub)] as Json?) ?? (props[key.substring(0, sub)] = <String, Object?>{});
            inner[key.substring(sub + 1)] = value;
          }
        case 'layout':
          layout[key] = value;
        case 'decoration':
          decoration[key] = value;
        default:
          node[key] = value;
      }
    }

    String pathOf(String key) {
      final short = _shortKeys[key];
      if (short != null) return short;
      if (key == 'visible' || key == 'opacity') return key;
      if (spec.props.any((p) => p.key == key)) return 'props.$key';
      if (key == 'enabled' && spec.props.any((p) => p.key == 'isEnabled')) return 'props.isEnabled';
      if ((key == 'lines' || key == 'rows') && type == 'textField') return 'props.maxLines';
      // `Input "Age" type:number`: the keyboard it opens.
      if (key == 'type' && type == 'textField') return 'props.keyboardType';
      if ((key == 'selected' || key == 'checked') && (type == 'checkbox' || type == 'switch')) return 'props.value';
      if (_layoutKeys.contains(key)) return 'layout.$key';
      if (_decorationKeys.contains(key)) return 'decoration.$key';
      // A component takes only what it declares: say so here, where the
      // line is, with what it does take.
      if (component) {
        _issue(column, 'A $written has no "$key". It takes: ${spec.props.map((p) => p.key).join(', ')}.');
      }
      return 'props.$key';
    }

    while (true) {
      t.skipSpace();
      if (t.done) break;
      final col = column + t.at;
      // `Progress :=done/total`: a value binding written with a stray colon.
      if (t.rest.startsWith(':=')) t.at++;
      if (t.peek == '"' && component) {
        // A component's strings fill its text parameters in order.
        final text = _interpolate(t.string());
        // Past the strings it is known by, a further string goes to its next
        // text parameter not yet given, in the order they are declared
        // (CartLine "Bananas" "1 kg" "$2.49": the price).
        final key = strings.where((k) => !props.containsKey(k) && !bind.containsKey('props.$k')).firstOrNull ??
            spec.props
                .where((p) => p.type.kind == PropKind.string && !props.containsKey(p.key) && !bind.containsKey('props.${p.key}'))
                .firstOrNull
                ?.key;
        if (key == null) {
          _issue(col, 'A $written takes ${strings.isEmpty ? 'no string' : 'no more strings (${strings.join(', ')})'}: write the rest as key:"value".');
        } else if (text.contains(r'${')) {
          bind['props.$key'] = text;
          positional.add(key);
        } else {
          props[key] = text;
          positional.add(key);
        }
      } else if (t.peek == '"') {
        _main(type, spec, t.string(), props, decoration);
      } else if (t.rest.startsWith('->')) {
        t.at += 2;
        final tail = _tail(t);
        // A component's action runs on its first event (onPressed,
        // onChanged): what it fires when it is used.
        final event = component ? spec.events.firstOrNull : null;
        reactions.add({
          'trigger': node.containsKey('dropTarget')
              ? {'type': 'drop'}
              : event != null
                  ? {'type': 'event', 'event': event.key}
                  : {'type': swipe ?? (_valueProps.containsKey(type) ? 'changed' : 'click')},
          'actions': _actions(t.rest.substring(0, tail).trim(), col),
        });
        t.at += tail;
      } else if (t.peek == '{') {
        final j = _json(t.rest);
        if (j is Map) {
          final tail = _copy(j.cast<String, Object?>());
          // A guessed prop in the tail: read as the key it is in the
          // notation (a layout or decoration key, a word), or dropped here
          // with a note, where the line is, not at render.
          if (readMap(tail['props']) case final Json guessed) {
            final kept = <String, Object?>{};
            for (final e in guessed.entries) {
              final k = e.key, v = e.value;
              if (spec.props.any((p) => p.key == k)) {
                kept[k] = v;
              } else if (_layoutKeys.contains(k) || k == 'top' || k == 'left') {
                if (k == 'top' || k == 'left') {
                  layout[k == 'top' ? 'y' : 'x'] = v;
                } else {
                  layout[k] = v;
                }
              } else if (k == 'radius' || k == 'opacity') {
                if (k == 'radius') decoration['radius'] = v;
                if (k == 'opacity') node['opacity'] = v;
              } else if (k == 'fill' && v is String) {
                decoration['fills'] = [
                  {'color': _named(v, 'fill')},
                ];
              } else if (k == 'gradient' && _gradient(v) != null) {
                decoration['fills'] = [_gradient(v)];
              } else if (k == 'borderWidth' && v is num) {
                decoration['strokeWidth'] = v;
              } else if (type == 'lineChart' && const {'series', 'labels', 'values', 'area', 'fill'}.contains(k)) {
                // Read below, with the line's own values and labels.
                props[k] = v;
              } else if (k == 'multiline' && type == 'textField') {
                if (v == true) kept.addAll({'minLines': 3, 'maxLines': 6});
              } else if (k == 'decoration' && type == 'text' && v is String) {
                textLine = v;
              } else if ((k == 'color' || k == 'size') && type.endsWith('Button')) {
                (buttonLook ??= <String, Object?>{})[k == 'color' ? 'iconColor' : 'iconSize'] = k == 'color' ? _named(v, 'text') : v;
              } else {
                _issue(col, 'A $written has no "$k": left out. Its props are written key:value on the line.');
              }
            }
            tail['props'] = kept;
          }
          _merge(node, tail);
        } else {
          _issue(col, 'The {…} tail is a JSON object merged into the node.');
        }
        break;
      } else if (t.peek == '=') {
        t.at++;
        final expr = t.expression().trim();
        final value = _valueProps[type];
        // A component keeps its value in the variable its parameter names.
        final held = !component
            ? null
            : spec.props.where((p) => p.type.isVariable && p.key == 'value').firstOrNull ?? spec.props.where((p) => p.type.isVariable).firstOrNull;
        if (held != null) {
          if (!_identifier.hasMatch(expr) || expr.contains('.')) {
            _issue(col, 'A $written keeps its ${held.key} in a variable: write =name.');
          } else {
            props[held.key] = expr;
            final (kind, start) = switch (held.type.variableOf?.kind) {
              PropKind.number || PropKind.integer => ('decimal', 0 as Object),
              PropKind.boolean => ('boolean', false as Object),
              PropKind.list => ('list', const <Object?>[] as Object),
              _ => ('text', '' as Object),
            };
            variables.putIfAbsent(expr, () => {'name': expr, 'type': kind, 'value': start});
          }
        } else if (value == null) {
          final shown = _shownValue[type] ?? _mainKey(type, spec);
          if (written == 'Badge') {
            _texts.add(_read(expr));
          } else if (shown == null) {
            _issue(col, 'A $written has no value to bind with =. Bind a prop: key:=expression.');
          } else {
            bind['props.$shown'] = _read(expr);
            // A share shown from a name not declared yet starts at 0.
            if (shown == 'value' && _identifier.hasMatch(expr) && !expr.contains('.')) {
              variables.putIfAbsent(expr, () => {'name': expr, 'type': 'decimal', 'value': 0});
            }
          }
        } else {
          // A segmented button's selection is a list: one name bound to it
          // is its single choice.
          final list = type == 'segmentedButton';
          bind['props.${value.prop}'] = list ? _formula('[$expr]') : _read(expr);
          final field = RegExp(r'^item\.([A-Za-z_][A-Za-z0-9_]*)$').firstMatch(expr);
          final over = _stack.reversed.where((o) => o.each != null).firstOrNull?.list;
          if (field != null) {
            // A control bound to a field of the repeated element
            // (`Input =field.label` under `each field in fields`): it shows
            // the field, and a change writes the element back into its list.
            if (over != null && _identifier.hasMatch(over) && !over.contains('.')) {
              final next = list ? 'result[0]' : 'result';
              reactions.insert(0, {
                'trigger': {'type': 'changed'},
                'actions': [
                  {'type': 'setVariable', 'variable': over, 'value': _formula('setAt($over,index,with(item,"${field[1]}",$next))')},
                ],
              });
            } else {
              _issue(col, 'A control can be bound to a field of a repeated element only when the each is over a variable (each row in rows).');
            }
          } else if (expr.contains('.')) {
            _issue(col, 'A control is bound to a variable by its name (=name), or under an each to a field of its element (=row.name): "$expr" is neither.');
          } else if (_identifier.hasMatch(expr)) {
            variables.putIfAbsent(expr, () => {'name': expr, 'type': value.type, 'value': props[value.prop] ?? value.start});
            reactions.insert(0, {
              'trigger': {'type': 'changed'},
              'actions': [
                {'type': 'setVariable', 'variable': expr, 'value': list ? r'${result[0]}' : type == 'pageView' ? r'${result.index}' : r'${result}'},
              ],
            });
          }
        }
      } else {
        // An expression where the string goes (`Button open ? "Hide" : "Show"`).
        final from = t.at;
        final bare = t.expression();
        final shownKey = component
            ? strings.where((k) => !props.containsKey(k) && !bind.containsKey('props.$k')).firstOrNull
            : _shownValue[type] ?? _mainKey(type, spec);
        if (component && shownKey != null && bare.contains(' ') && bare.contains('?') && !RegExp(r'^[A-Za-z]+:').hasMatch(bare)) {
          positional.add(shownKey);
        }
        if (shownKey != null && bare.contains(' ') && bare.contains('?') && !RegExp(r'^[A-Za-z]+:').hasMatch(bare)) {
          bind['props.$shownKey'] = _read(bare.trim());
          continue;
        }
        t.at = from;
        final word = t.word();
        if (word.isEmpty) {
          _issue(col, 'Unexpected "${t.peek}".');
          t.at++;
          continue;
        }
        final colon = word.indexOf(':');
        if (colon < 0) {
          if (written == 'Box' && (word == 'center' || word == 'middle')) {
            // A box centers what is in it: across with `center`, down with
            // `middle` (or with `center` alone).
            if (word == 'center') props['crossAxisAlignment'] = 'center';
            if (word == 'middle' || !line.contains(' middle')) props['mainAxisAlignment'] = 'center';
          } else if (type == 'stack' && const {'center', 'middle', 'left', 'right', 'top', 'bottom', 'start', 'end'}.contains(word)) {
            // A stack places what is in it: across with `center`, `left`,
            // `right`; down with `middle`, `top`, `bottom` (each child that
            // says no place of its own).
            (stackAlign ??= <String>{}).add(word);
          } else if (word == 'clip' && (type == 'column' || type == 'row' || type == 'stack')) {
            // What is in it is cut at its (rounded) edge.
            if (spec.props.any((p) => p.key == 'clipBehavior')) props['clipBehavior'] = 'antiAlias';
          } else if (type == 'column' && (word == 'center' || word == 'middle')) {
            // On every container `center` is across the page and `middle`
            // down it, as models write them: a column's children centered
            // side to side, or gathered at its middle.
            if (word == 'center') props['crossAxisAlignment'] = 'center';
            if (word == 'middle') props['mainAxisAlignment'] = 'center';
          } else if (type == 'text' && const {'center', 'right', 'left'}.contains(word)) {
            props['textAlign'] = word;
          } else if (type == 'text' && (word == 'strike' || word == 'strikethrough' || word == 'underline')) {
            textLine = word == 'underline' ? 'underline' : 'lineThrough';
          } else if (type == 'textField' && word == 'password') {
            props['obscureText'] = true;
          } else if (type == 'textField' && word == 'multiline') {
            props.putIfAbsent('minLines', () => 3);
            props.putIfAbsent('maxLines', () => 6);
          } else if (type == 'row' && word == 'center' && const {'spaceBetween', 'spaceAround', 'spaceEvenly'}.contains(props['mainAxisAlignment'])) {
            // `Row between center`: its ends apart, and what is in it level
            // (the row is already spread: center can only be across it).
            props['crossAxisAlignment'] = 'center';
          } else if (type == 'row' && const {'between', 'around', 'evenly'}.contains(word) && props['mainAxisAlignment'] == 'center' && !props.containsKey('crossAxisAlignment')) {
            // …and `Row center between`, the same.
            props['mainAxisAlignment'] = _mainWords[word];
            props['crossAxisAlignment'] = 'center';
          } else if (type == 'text' && word == 'italic') {
            final body = options.textStyles['body'];
            final style = switch (props['style']) {
              final Map m => m.cast<String, Object?>(),
              _ => body is Map ? _copy(body.cast<String, Object?>()) : body is String ? <String, Object?>{'from': body} : <String, Object?>{},
            };
            props['style'] = style..['fontStyle'] = 'italic';
          } else if (_mainWords[word] case final String m when type == 'row' || type == 'column') {
            props['mainAxisAlignment'] = m;
          } else if (_crossWords[word] case final String c when type == 'row' || type == 'column') {
            props['crossAxisAlignment'] = c;
          } else if (num.tryParse(word) != null && (_valueProps[type]?.type == 'decimal' || _shownValue[type] == 'value')) {
            // A bare number on a slider or a progress bar is its value.
            props['value'] = num.parse(word);
          } else if (word == 'grow') {
            layout['flex'] = 1;
          } else if (word == 'scroll' && (type == 'column' || type == 'row')) {
            props['scrollable'] = true;
            // A row scrolls along itself: sideways.
            if (type == 'row') props['scrollDirection'] = 'horizontal';
          } else if (word == 'fill') {
            layout['width'] = {'fill': 0};
          } else if (word == 'open' && (type == 'accordion' || type == 'expansionTile')) {
            props[type == 'accordion' ? 'expanded' : 'initiallyExpanded'] = true;
          } else if (word.startsWith('#') && RegExp(r'^#[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(word)) {
            // An anchor written after the text (`Heading "Why" #why`): a name
            // for a `scroll why` to go to.
            _anchors[word.substring(1)] = id;
          } else if (word == 'hidden') {
            node['visible'] = false;
          } else if (word == 'sticky') {
            // Stays in view while the page scrolls under it (a table of
            // contents beside an article, an order summary).
            // A bar across the top (SiteNav, a TopBar, a Header) stays at the very top.
            node['sticky'] = {'offset': RegExp(r'(Nav|Bar|Header)$').hasMatch(written) ? 0 : 16};
          } else if (spec.props.any((p) => p.key == word)) {
            props[word] = true;
          } else if (component && _componentWord(word, spec, props, bind)) {
            // Read as the parameter it can only be.
          } else {
            _issue(col, 'Unknown word "$word" on a $written. Props are written key:value.');
          }
          continue;
        }
        var key = word.substring(0, colon);
        // `if:cond` on a node is the node shown while it holds.
        // …but `show:phone` is where it shows (a screen's size), even on a
        // page with a value of that name (a form's phone field).
        final sizeWord = (key == 'show' || key == 'hide') && const {'phone', 'mobile', 'tablet', 'desktop'}.contains(word.substring(colon + 1));
        if (key == 'if' || key == 'when' || (key == 'show' && !sizeWord)) key = 'visible';
        // A handler written as a key, as models write one unprompted:
        // onPressed:{a = 1; b = 2}, tap:"n = n + 1", onChanged: qty = value.
        // …unless the node has a parameter of that name (a quote's `change:1.84`).
        if (_handlerKey.hasMatch(key) && !spec.props.any((p) => p.key == key)) {
          t.at = from + colon + 1;
          t.skipSpace();
          final String body;
          if (t.peek == '{') {
            final braced = t.balanced();
            body = braced.substring(1, braced.length - 1);
          } else if (t.peek == '"') {
            body = t.string();
          } else {
            body = t.rest;
            t.at += t.rest.length;
          }
          final trigger = _handlerTrigger(key, type, component ? spec : null, node);
          final actions = _actions(_statements(body), col);
          // A menu opened by a right click or a long press sits where the pointer is.
          if (trigger['type'] == 'secondaryClick' || trigger['type'] == 'longPress') actions.forEach(_atPointer);
          reactions.add({'trigger': trigger, 'actions': actions});
          continue;
        }
        var raw = word.substring(colon + 1);
        // `menu:rowMenu`: a right click, or a long press on a touch screen,
        // opens that Menu where the pointer is (a context menu).
        if (key == 'menu' && _identifier.hasMatch(raw) && !raw.contains('.') && !spec.props.any((p) => p.key == 'menu')) {
          for (final trigger in const ['secondaryClick', 'longPress']) {
            final actions = _actions('open $raw', col);
            actions.forEach(_atPointer);
            reactions.add({'trigger': {'type': trigger}, 'actions': actions});
          }
          continue;
        }
        if (raw.startsWith('=')) raw = '$raw${t.expression(opened: _opened(raw), quoted: '"'.allMatches(raw).length.isOdd, single: RegExp(r"(?<![A-Za-z0-9])'").allMatches(raw).length.isOdd)}';
        if (raw.isEmpty && t.peek == '"') raw = jsonEncode(t.string());
        if (raw.isEmpty && (t.peek == '[' || t.peek == '{')) raw = t.balanced();
        // What models write for a value that follows state when nothing tells
        // them how (tool/values in the SDK, fourteen answers): the name bare,
        // the name or an expression in braces, or the expression as it is.
        // None of them is text, which is written in quotes.
        if (!raw.startsWith('=') && !raw.startsWith('"') && raw.isNotEmpty && _operatorAhead.matchAsPrefix(t.s, t.at) != null) {
          // key:count > 0, max:standing + (6 - count): the expression goes on past the space.
          raw = '=$raw${t.expression(opened: _opened(raw), quoted: '"'.allMatches(raw).length.isOdd, single: RegExp(r"(?<![A-Za-z0-9])'").allMatches(raw).length.isOdd)}';
        } else if (!raw.startsWith('=') && raw.startsWith('(') && !_literal(raw).$1) {
          raw = '=$raw${t.expression(opened: _opened(raw), quoted: '"'.allMatches(raw).length.isOdd, single: RegExp(r"(?<![A-Za-z0-9])'").allMatches(raw).length.isOdd)}';
        }
        // key:={running}: both marks at once.
        if (raw.startsWith('={') && _bracedExpression(raw.substring(1))) raw = raw.substring(1);
        if (_bracedValue.hasMatch(raw) || _bracedExpression(raw)) {
          raw = '=${raw.substring(1, raw.length - 1).trim()}';
        } else if (!raw.startsWith('=') && key != 'drag' && key != 'drop' && _expressionStart.hasMatch(raw) && !_literal(raw).$1) {
          raw = '=$raw${t.expression(opened: _opened(raw), quoted: '"'.allMatches(raw).length.isOdd, single: RegExp(r"(?<![A-Za-z0-9])'").allMatches(raw).length.isOdd)}';
        }
        // A list or map that is not plain JSON holds expressions
        // (votes:[a+1,b]): it is read as the formula it is.
        if (raw.startsWith('[') || raw.startsWith('{')) {
          try {
            // …and so is one whose texts read values
            // (items:["Lemons, {2 * servings}"]): each such text is its
            // parts joined.
            final decoded = jsonDecode(raw);
            if (_readsValues(decoded)) raw = '=${_formulaSource(decoded)}';
          } catch (_) {
            raw = '=$raw';
          }
        }
        // A bare word that is a variable the answer declared (choice:pick),
        // or a field read through the name an `each` gave (price:x.price),
        // is that variable: text is written in quotes. A word that is one of
        // the parameter's own values (tone:quiet) stays the word.
        if (!raw.startsWith('=') && raw != 'fill' && raw != 'hug' && !sizeWord && _variablePath.hasMatch(raw) && !_literal(raw).$1) {
          final head = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*').stringMatch(raw)!;
          final known = variables.containsKey(head) || _derived.containsKey(head) || _stack.any((o) => o.each == head);
          final ownValue = spec.props.any((p) => p.key == key && p.type.kind == PropKind.enumeration && p.type.values.contains(raw));
          if (known && !ownValue) raw = '=$raw';
        }
        if (grid != null && (key == 'cols' || key == 'columns')) {
          grid.cols = (int.tryParse(raw) ?? 2).clamp(1, 12);
          continue;
        }
        if (grid != null && (key == 'gap' || key == 'spacing')) {
          grid.gap = num.tryParse(raw) ?? 8;
          props['spacing'] = grid.gap;
          continue;
        }
        if (key == 'fill') {
          if (raw.startsWith('=')) {
            bind['decoration.fills[0].color'] = _namedIn(_read(raw.substring(1)), 'fill');
            decoration.putIfAbsent('fills', () => [
                  {'color': '#00000000'},
                ]);
          } else {
            var fill = _named(_value(raw), 'fill');
            // On the page, a fill the theme reads as the page's own color
            // would vanish: the theme's fill for the page instead.
            if (options.pageFill case final look? when fill is String && written != 'Card') {
              var inCard = false;
              for (String? at = parent?.id; at != null && !inCard; at = _parentOf[at]) {
                inCard = _cards.contains(at);
              }
              final value = options.palette[fill], pageValue = options.palette['page'];
              if (!inCard && value != null && pageValue != null && value.toUpperCase() == pageValue.toUpperCase()) fill = look.fill;
            }
            // A see-through tint on a card sits over the card's own color:
            // alone it would let the card's shadow show through it.
            final raw8 = _value(raw);
            final tint = written == 'Card' && raw8 is String && RegExp(r'^#[0-9A-Fa-f]{8}$').hasMatch(raw8) && !raw8.toUpperCase().startsWith('#FF');
            final under = ((options.card['decoration'] as Map?)?['fills'] as List?)?.firstOrNull;
            decoration['fills'] = [
              if (tint && under is Map) {...under.cast<String, Object?>()},
              {'color': fill},
            ];
          }
          continue;
        }
        // `drag:todo(card.id)`: the node can be dragged, in a group, carrying
        // a value. `drop:todo,doing -> …`: it takes drops from those groups,
        // and the line's -> runs on a drop ({result.data} is what was carried).
        // `animate:fade` (slide-up, scale, pulse, spin, pop, shake, shimmer…)
        // with `duration:` and `delay:` beside it, and `stagger:` under an
        // `each` (each copy that much later than the one before).
        if (key == 'animate' || key == 'animation' || key == 'enter') {
          final name = _literal(raw).$2?.toString() ?? raw;
          // fadeIn, fade-in, "fade in" and fade are one word.
          final word = name.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}-${m[2]}').toLowerCase().replaceAll(RegExp(r'[ _]'), '-');
          final look = notationAnimations[word] ?? notationAnimations[word.replaceAll(RegExp(r'-(in|once|loop)$'), '')];
          if (look == null) {
            _issue(col, 'No animate:$raw. Written animate:${notationAnimations.keys.join(', ')}.');
          } else {
            animation = {'id': 'a', ..._copy(look)};
          }
          continue;
        }
        if ((key == 'duration' || key == 'delay' || key == 'stagger') && _milliseconds(raw) != null) {
          (timing ??= <String, int>{})[key] = _milliseconds(raw)!;
          continue;
        }
        if (key == 'limit' && type == 'radialGauge') key = 'target';
        // What a gauge measures in, under its figure: unit:"km/h".
        if ((key == 'unit' || key == 'label') && type == 'radialGauge') {
          gaugeUnit = _literal(raw).$2?.toString() ?? raw;
          continue;
        }
        if (key == 'color' && type == 'lineChart') key = 'lineColor';
        // A design system's Avatar sizes by name: a number is the nearest.
        if (key == 'size' && component && written == 'Avatar' && num.tryParse(raw) != null) {
          final n = num.parse(raw);
          props['size'] = n <= 24 ? 'xs' : n <= 32 ? 'small' : n <= 44 ? 'medium' : 'large';
          continue;
        }
        // gradient:["#FF7C3AED","#FFEC4899"]: a fill from the first color to the last, corner to corner.
        if (key == 'gradient' && _gradient(_value(raw)) != null) {
          decoration['fills'] = [_gradient(_value(raw))];
          continue;
        }
        if (key == 'fit' && written == 'Image') {
          imageFit = _literal(raw).$2?.toString() ?? raw;
          continue;
        }
        if (key == 'password' && type == 'textField') key = 'obscureText';
        // A fixed tooltip is the node's own; one that reads data is bound as before.
        if (key == 'tooltip' && !spec.props.any((p) => p.key == 'tooltip') && raw.startsWith('"') && !raw.contains('{')) {
          node['tooltip'] = _literal(raw).$2?.toString() ?? raw;
          continue;
        }
        if (key == 'decoration' && type == 'text') {
          textLine = _literal(raw).$2?.toString() ?? raw;
          continue;
        }
        // An icon button's icon takes a color and a size through its style.
        if ((key == 'color' || key == 'size') && type == 'iconButton') {
          if (raw.startsWith('=')) {
            bind['props.style.${key == 'color' ? 'iconColor' : 'iconSize'}'] = key == 'color' ? _namedIn(_read(raw.substring(1)), 'text') : _read(raw.substring(1));
            (buttonLook ??= <String, Object?>{});
          } else {
            (buttonLook ??= <String, Object?>{})[key == 'color' ? 'iconColor' : 'iconSize'] = key == 'color' ? _named(_value(raw), 'text') : _value(raw);
          }
          continue;
        }
        if (type == 'datePicker' && (key == 'min' || key == 'max')) key = key == 'min' ? 'firstDate' : 'lastDate';
        // A password field hides what is typed; it is not a keyboard.
        if (key == 'type' && type == 'textField' && (raw == 'password' || raw == '"password"')) {
          props['obscureText'] = true;
          continue;
        }
        // Where a node shows, by the screen's width: hide:phone (not on a
        // phone), hide:tablet (not on a tablet or a phone), show:phone
        // (on a phone only), show:tablet (on a tablet and a phone only).
        // sticky:0 stays at the very top (a header); the word alone keeps 16 above it.
        if (key == 'sticky' && num.tryParse(raw) != null) {
          node['sticky'] = {'offset': num.parse(raw)};
          continue;
        }
        if ((key == 'hide' || key == 'show') && sizeWord) {
          final Json? rule = switch ((key, raw)) {
            ('hide', 'phone' || 'mobile') => {'maxWidth': reflowPhoneMax},
            ('hide', 'tablet') || ('show', 'desktop') => {'maxWidth': reflowTabletMax},
            ('show', 'phone' || 'mobile') => {'minWidth': reflowPhoneMax + 1},
            ('show', 'tablet') || ('hide', 'desktop') => {'minWidth': reflowTabletMax + 1},
            _ => null,
          };
          if (rule != null) {
            node['media'] = [
              ...?(node['media'] as List?),
              // A line under an `if` binds visible, and a binding shows over
              // a patched value: where the size hides the node, the binding is
              // dropped, so the condition holds only where the node shows.
              {...rule, 'patch': {'visible': false, 'bind': {'visible': null}}},
            ];
          }
          continue;
        }
        // The widest a node gets (a page's column of content): maxw:720.
        if (const {'maxw', 'maxWidth', 'max-width', 'maxwidth'}.contains(key) && num.tryParse(raw) != null) {
          layout['constraints'] = {...?readMap(layout['constraints']), 'maxWidth': num.parse(raw)};
          continue;
        }
        if (key == 'size' && ours && written == 'Avatar' && num.tryParse(raw) != null) {
          avatarSize = num.parse(raw);
          continue;
        }
        // A slider's step is how many equal steps its range has.
        if (key == 'step' && type == 'slider' && num.tryParse(raw) != null) {
          sliderStep = num.parse(raw);
          continue;
        }
        // `swipe:left -> …` runs the line's actions on that swipe.
        if (key == 'swipe' && const {'left', 'right', 'up', 'down'}.contains(raw)) {
          swipe = 'swipe${raw[0].toUpperCase()}${raw.substring(1)}';
          for (final r in reactions) {
            if (readMap(r['trigger'])?['type'] == 'click') r['trigger'] = {'type': swipe};
          }
          continue;
        }
        if (key == 'drag') {
          final m = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)(?:\((.+)\))?$').firstMatch(raw);
          if (m == null) {
            _issue(col, 'drag is written drag:group or drag:group(value): drag:todo(card.id).');
          } else {
            node['draggable'] = {'group': m[1], if (m[2] != null) 'data': _read(m[2]!.trim())};
          }
          continue;
        }
        if (key == 'drop') {
          final groups = raw.split(',').map((g) => g.trim()).where((g) => g.isNotEmpty).toList();
          if (groups.isEmpty || groups.any((g) => !_identifier.hasMatch(g))) {
            _issue(col, 'drop is written drop:group or drop:a,b with the groups it takes: drop:todo,doing -> done=append(done,result.data).');
          } else {
            node['dropTarget'] = {'accepts': groups};
          }
          continue;
        }
        // A hairline round it: `border:#FFE5E7EB`, or one that follows data: `border:=on?"#FF2563EB":"#FFE5E7EB"`.
        // A hairline on one side: border-bottom:#FFE5E7EB (a bar's rule, a pane's edge).
        if (_borderSides[key] case final String side when !raw.startsWith('=')) {
          decoration['strokes'] = [
            {'color': _named(_value(raw), 'stroke')},
          ];
          decoration['strokeSides'] = side;
          continue;
        }
        if (key == 'border') {
          if (raw.startsWith('=')) {
            bind['decoration.strokes[0].color'] = _namedIn(_read(raw.substring(1)), 'stroke');
            decoration.putIfAbsent('strokes', () => [
                  {'color': '#00000000'},
                ]);
          } else {
            decoration['strokes'] = [
              {'color': _named(_value(raw), 'stroke')},
            ];
          }
          continue;
        }
        if (type == 'text' && _textStyleKeys.containsKey(key)) {
          // A style that follows data: `color:=due?"#FFDC2626":"#FF111827"`.
          if (raw.startsWith('=') && key != 'bold') {
            final read = _read(raw.substring(1));
            bind['props.style.${_textStyleKeys[key]!}'] = key == 'color' ? _namedIn(read, 'text') : read;
            continue;
          }
          // A text sized or weighted on its line starts from the body style,
          // so it keeps the ink and font (with none it would have no color
          // and show nothing).
          final body = options.textStyles['body'];
          final style = switch (props['style']) {
            final Map m => m.cast<String, Object?>(),
            _ => body is Map ? _copy(body.cast<String, Object?>()) : body is String ? <String, Object?>{'from': body} : <String, Object?>{},
          };
          final v = key == 'color' ? _named(_value(raw), 'text') : _value(raw);
          style[_textStyleKeys[key]!] = key == 'bold' ? 700 : v;
          props['style'] = style;
          continue;
        }
        if (type == 'segmentedButton' && key == 'items') {
          final items = _value(raw);
          if (items is List) {
            props['segments'] = [for (final i in items) {'value': '$i', 'label': '$i'}];
            continue;
          }
        }
        if (key == 'selected' && type == 'chip') type = 'choiceChip';
        if (key == 'hidden' && raw.startsWith('=')) {
          bind['visible'] = _formula('!(${raw.substring(1)})');
          continue;
        }
        if (_typeKeys[type]?[key] case final List<String> paths) {
          for (final path in paths) {
            if (raw.startsWith('=')) {
              bind[path] = _read(raw.substring(1));
            } else {
              put(path, _value(raw));
            }
          }
          continue;
        }
        if (key == 'color' && type == 'icon' && !raw.startsWith('=')) {
          props['color'] = _named(_value(raw), 'text');
          continue;
        }
        final path = pathOf(key);
        // A string on the line already went to this parameter: saying it
        // twice would silently drop one.
        if (component && positional.contains(key)) {
          _issue(col, 'The string on this line is already the $written\'s $key: write $key once.');
        }
        final bound = raw.startsWith('=') ? raw.substring(1).trim() : null;
        final dotted = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)(\.[A-Za-z_][A-Za-z0-9_]*)+$').firstMatch(raw);
        if (bound != null && bound.startsWith('"') && _literal(bound).$1 && _literal(bound).$2 is String) {
          // value:="{s.jumps}": a text with a value in it, written as a binding.
          final text = _interpolate(_literal(bound).$2! as String);
          if (text.contains(r'${')) {
            bind[path] = text;
          } else {
            put(path, text);
          }
        } else if (bound != null) {
          bind[path] = _read(bound);
        } else if (dotted != null && (variables.containsKey(dotted[1]) || dotted[1] == 'item')) {
          // minutes:today.minutes: a field of declared state where a value
          // goes is that value, not the words.
          bind[path] = _read(raw);
        } else {
          var v = _value(raw);
          // A text parameter given a number (count:4) takes it as text.
          if (v is num && component && spec.props.any((p) => p.key == key && p.type.kind == PropKind.string)) v = '$v';
          if (v is String && v.contains(r'${') && !(type == 'text' && path == 'props.text')) {
            // A string that reads data (value:"{streak} days") is bound:
            // only a text node reads an expression as written.
            bind[path] = v;
          } else {
            put(path, v);
          }
        }
      }
    }

    // Sizes not written: in a column a child fills the width and hugs its
    // height; in a row it hugs both; a control hugs.
    final control = _valueProps.containsKey(type) || type.endsWith('Button') || type.endsWith('Chip');
    if (component) {
      bool has(String k) => props.containsKey(k) || bind.containsKey('props.$k');
      // A block with an optional boolean state should still toggle when its
      // author leaves off =name. Give each call its own page variable.
      for (final p in spec.props) {
        if (p.required || has(p.key) || !p.type.isVariable || p.type.variableOf?.kind != PropKind.boolean) continue;
        final local = '${id}_${p.key}';
        props[p.key] = local;
        variables.putIfAbsent(local, () => {'name': local, 'type': 'boolean', 'value': p.defaultValue is bool ? p.defaultValue : false});
      }
      for (final p in spec.props) {
        if (!p.required || has(p.key)) continue;
        // One string, and the component needs another text than the one it
        // went to (`Banner "Saved"`: its message, not its title): it is that.
        final moved = positional.where((k) => !(spec.prop(k)?.required ?? false)).firstOrNull;
        if (moved != null && strings.contains(p.key)) {
          if (props.containsKey(moved)) props[p.key] = props.remove(moved);
          if (bind.containsKey('props.$moved')) bind['props.${p.key}'] = bind.remove('props.$moved');
          positional.remove(moved);
          continue;
        }
        _issue(column, 'A $written needs ${p.key}: write ${p.key}:${p.type.isVariable ? 'name (a variable), or =name' : p.type.kind == PropKind.list ? '["a","b"]' : p.type.kind == PropKind.string ? '"…"' : 'value'}.');
      }
    }
    // A component is as big as its own design says, unless the line does.
    if (component) {
      final own = options.components[type];
      // In a row a component that is as wide as its place (a segmented
      // choice in a toolbar) has no width to take: it shares the row.
      final ownWidth = own?.width;
      if (parent?.type == 'row' && parent?.grid == null && !layout.containsKey('width') && !layout.containsKey('flex') && ownWidth is Map && ownWidth.containsKey('fill')) {
        final row = nodes[parent!.id];
        final rowWidth = (row?['layout'] as Map?)?['width'];
        // A row that is itself only as wide as its content gives it a width.
        if (rowWidth is Map && rowWidth.containsKey('fill') || (row?['layout'] as Map?)?.containsKey('flex') == true) {
          layout['flex'] = 1;
        } else {
          layout['width'] = 240;
        }
      }
      // A call has no look of its own (its definition has): a radius, a
      // fill or a border written on it is left out.
      decoration.clear();
      bind.removeWhere((k, _) => k.startsWith('decoration.'));
      layout.putIfAbsent('width', () => own?.width ?? {'hug': 0});
      layout.putIfAbsent('height', () => own?.height ?? {'hug': 0});
    }
    if (written == 'Image') {
      final url = props.remove('text');
      decoration['fills'] = [
        {
          'image': {'url': url ?? '', 'fit': const {'cover', 'contain', 'fill', 'fitWidth', 'fitHeight', 'none', 'scaleDown'}.contains(imageFit) ? imageFit : 'cover'},
        },
      ];
      layout.putIfAbsent('height', () => 160);
    }
    // Shares of a whole: values:[…] labels:[…] colors:[…] as a donut (a pie
    // is a thick one).
    if (ours && const {'Donut', 'DonutChart', 'PieChart', 'Pie'}.contains(written)) {
      final values = props.remove('values'), labels = props.remove('labels'), colors = props.remove('colors');
      final palette = [_accentValue, ..._chartColors];
      props['chartType'] = 'donut';
      if (values is List) {
        props['data'] = [
          for (var i = 0; i < values.length; i++)
            {
              'label': labels is List && i < labels.length ? '${labels[i]}' : '',
              'value': values[i],
              'color': colors is List && i < colors.length ? _named(colors[i], 'fill') : palette[i % palette.length],
            },
        ];
      }
      props['series'] = [
        {'field': 'value', 'colorField': 'color'},
      ];
      // On a page its labels are its legend, beside it (under it on a phone).
      final legend = props.remove('legend');
      if (options.width >= 700 && legend != false && values is List && labels is List && labels.any((l) => '$l'.isNotEmpty)) {
        final data = (props['data']! as List).cast<Map>();
        donutKeys = [
          for (final d in data) (label: '${d['label']}', value: d['value'], color: d['color']),
        ];
      }
      props.putIfAbsent('donutThickness', () => written.startsWith('Pie') && props['donut'] != true ? 0.5 : 0.22);
      props.remove('donut');
      props.addAll({'showYAxis': false, 'showXAxis': false, 'gridLines': 0});
      layout.putIfAbsent('width', () => layout['height'] is num ? layout['height'] : 160);
      layout.putIfAbsent('height', () => layout['width'] is num ? layout['width'] : 160);
    }
    // A line chart with named series, labels under it or a filled area is
    // the series chart: one data row per label, one field per series.
    final area = written == 'AreaChart' || props.remove('area') == true || props['fill'] == true && type == 'lineChart';
    if (type == 'lineChart') props.remove('fill');
    if (type == 'lineChart' && written != 'Sparkline' && (props['series'] is List || area || props['labels'] is List && props['values'] is List)) {
      final labels = props.remove('labels');
      final written0 = props.remove('series'), plain = props.remove('values');
      final all = [
        if (written0 is List)
          for (final s in written0.map(readMap).nonNulls)
            if (s['values'] ?? s['data'] case final List v) (name: '${s['name'] ?? s['label'] ?? ''}', values: v, color: s['color']),
        if (written0 is! List && plain is List) (name: '', values: plain, color: props.remove('lineColor')),
      ];
      if (all.isNotEmpty) {
        final palette = [_accentValue, ..._chartColors];
        final rows = all.map((s) => s.values.length).reduce((a, b) => a > b ? a : b);
        type = 'chart';
        props
          ..remove('lineColor')
          ..addAll({
            'chartType': 'line',
            'data': [
              for (var i = 0; i < rows; i++)
                {
                  'label': labels is List && i < labels.length ? '${labels[i]}' : '',
                  for (var k = 0; k < all.length; k++)
                    if (i < all[k].values.length) 's$k': all[k].values[i],
                },
            ],
            'series': [
              for (var k = 0; k < all.length; k++)
                {
                  'field': 's$k',
                  if (all[k].name.isNotEmpty) 'name': all[k].name,
                  'kind': area ? 'area' : 'line',
                  'color': all[k].color is String ? _named(all[k].color, 'fill') : palette[k % palette.length],
                  'curved': true,
                },
            ],
          });
        layout.putIfAbsent('height', () => 160);
      }
    }
    // Charts: a height of their own, and a line chart's plain values as its
    // data points.
    if (type == 'barChart' || type == 'lineChart') {
      layout.putIfAbsent('height', () => 140);
      // The design system's primary, unless a color is written.
      props.putIfAbsent(type == 'barChart' ? 'color' : 'lineColor', () => options.accent);
      if (type == 'barChart') {
        for (final e in options.barChart.entries) {
          props.putIfAbsent(e.key, () => e.value);
        }
      }
      if (type == 'lineChart' && props['values'] is List) {
        final values = props.remove('values')! as List;
        props.remove('labels');
        props['data'] = [for (var i = 0; i < values.length; i++) {'x': i, 'y': values[i]}];
        props['xField'] = 'x';
        props['yField'] = 'y';
      }
    }
    if (buttonLook != null && buttonLook.isNotEmpty) {
      props['style'] = {...?readMap(props['style']), ...buttonLook};
    }
    if (textLine != null && props['style'] is Map) {
      props['style'] = {...(props['style']! as Map).cast<String, Object?>(), 'decoration': textLine};
    } else if (textLine != null) {
      props['style'] = {...?(options.textStyles['body'] is Map ? _copy((options.textStyles['body']! as Map).cast<String, Object?>()) : null), 'decoration': textLine};
    }
    // An avatar: a round mark, 40 across unless sized, its picture when its
    // string is one, else the name's initials (added once it is stored).
    String? avatarName;
    if (ours && written == 'Avatar') {
      final size = avatarSize ?? (layout['width'] is num ? layout['width']! as num : 40);
      layout['width'] = size;
      layout['height'] = size;
      decoration.putIfAbsent('radius', () => size / 2);
      // A container's string is held for a text under it: here it is the name.
      final Object? shown = _texts.isNotEmpty ? '${_texts.first}' : props.remove('text');
      _texts.clear();
      final src = props.remove('src') ?? props.remove('url') ?? props.remove('image');
      final picture = src ?? (shown is String && RegExp(r'^(https?:|assets/|data:|/)|\.(png|jpe?g|webp|svg)$').hasMatch(shown) ? shown : null);
      if (picture != null) {
        decoration['fills'] = [
          {
            'image': {'url': picture, 'fit': 'cover'},
          },
        ];
      } else {
        decoration.putIfAbsent('fills', () => [
              {'color': _named('#FFE5E7EB', 'fill')},
            ]);
        avatarName = shown is String ? shown : '';
        props.addAll({'mainAxisAlignment': 'center', 'crossAxisAlignment': 'center'});
      }
    }
    // A gauge: its scale's labels follow its range, a target shows only when
    // one is written (`target:` or `limit:`), and it has a size of its own.
    if (type == 'radialGauge') {
      // One clean arc with the figure inside it: no scale numbers, ticks or
      // needle unless written, the value arc in the accent.
      props.putIfAbsent('labels', () => const <Object>[]);
      if (!props.containsKey('zones')) props.putIfAbsent('colorByZone', () => false);
      for (final e in const {'segments': 0, 'roundCaps': true, 'thickness': 16, 'majorTicks': 0, 'minorTicks': 0, 'showNeedle': false}.entries) {
        props.putIfAbsent(e.key, () => e.value);
      }
      if (!props.containsKey('target') && !bind.containsKey('props.target')) props.putIfAbsent('showTarget', () => false);
      // As wide as what it is in, its arc centered; the arc leaves the
      // bottom third of its circle open.
      layout.putIfAbsent('width', () => {'fill': 0});
      layout.putIfAbsent('height', () => layout['width'] is num ? ((layout['width']! as num) * 0.68).round() : 164);
    }
    if (sliderStep != null && sliderStep > 0) {
      final min = props['min'] is num ? props['min'] as num : 0, max = props['max'] is num ? props['max'] as num : 1;
      final steps = ((max - min) / sliderStep).round();
      if (steps > 0 && steps <= 1000) props['divisions'] = steps;
    }
    // A ring is a round share, 64 across unless sized.
    if (ours && written == 'Ring') {
      layout.putIfAbsent('width', () => 64);
      layout.putIfAbsent('height', () => layout['width']);
      // The rest of the circle shows as a quiet track.
      props.putIfAbsent('backgroundColor', () => options.track);
      props.putIfAbsent('strokeCap', () => 'round');
      if (options.ringStroke case final num w) props.putIfAbsent('strokeWidth', () => w);
    }
    // A sparkline is a line chart with no axes, grid or room around it.
    if (ours && written == 'Sparkline') {
      layout['height'] = layout['height'] == 140 ? 32 : layout['height'];
      layout.putIfAbsent('width', () => 96);
      props.addAll({
        'plotPadding': [2, 4, 2, 4],
        'smooth': true,
        'gridColor': '#00000000',
        'axisColor': '#00000000',
        'zeroLineColor': '#00000000',
        'axisLabelStyle': {'fontSize': 1, 'color': '#00000000'},
      });
    }
    if (_eachStagger case final int step when type != 'listView') {
      _eachStagger = null;
      animation ??= {'id': 'a', ..._copy(notationAnimations['fade-up']!)};
      (timing ??= <String, int>{}).putIfAbsent('stagger', () => step);
    }
    if (animation != null) {
      if (timing?['duration'] case final int d) animation['duration'] = d;
      if (timing?['delay'] case final int d) animation['delay'] = d;
      node['animations'] = [animation];
      // Under an `each`, each copy starts that much after the one before.
      if (timing?['stagger'] case final int step) {
        bind['animations[0].delay'] = '\${= index*$step${timing?['delay'] == null ? '' : '+${timing!['delay']}'}}';
      }
    } else if (timing != null) {
      _issue(column, 'duration:, delay: and stagger: go with animate: on the same line (animate:fade duration:400).');
    }
    // `grow:=share` follows a value: it grows, by 1 until the value is read
    // (a bar's segments sized by their amounts).
    if (bind.containsKey('layout.flex')) layout.putIfAbsent('flex', () => 1);
    if (stackAlign != null) _stackAlign[id] = stackAlign;
    // In a stack that centers, a child with no place of its own is centered.
    if (parent != null && _stackAlign[parent.id] != null) {
      final words = _stackAlign[parent.id]!;
      final across = words.contains('center') ? 0 : words.contains('right') || words.contains('end') ? 1 : words.contains('left') || words.contains('start') ? -1 : null;
      final down = words.contains('middle') ? 0 : words.contains('bottom') ? 1 : words.contains('top') ? -1 : words.length == 1 && across == 0 ? 0 : null;
      if (across != null) {
        layout.putIfAbsent('x', () => {'align': across});
        // As wide as it is, or it would fill the stack and sit at its start.
        layout.putIfAbsent('width', () => {'hug': 0});
      }
      if (down != null) layout.putIfAbsent('y', () => {'align': down});
    }
    // A column starts its children at the leading edge and a row centers
    // them on its line (what a form and a toolbar want), unless written.
    if (type == 'column') props.putIfAbsent('crossAxisAlignment', () => 'start');
    if (type == 'row') props.putIfAbsent('crossAxisAlignment', () => 'center');
    // Progress is written as a share (`Progress 0.4`, `Progress =step/3`):
    // the bar is full at 1, unless a larger number or a max is written.
    if (type == 'progressBar' && !props.containsKey('max')) {
      final v = props['value'];
      if (v is! num || v <= 1) props['max'] = 1;
      props.putIfAbsent('borderRadius', () => options.progress['borderRadius'] ?? 2);
    }
    if (type == 'progressBar' && options.progress['height'] != null) layout.putIfAbsent('height', () => options.progress['height']);
    // A card that writes no gap takes the theme's.
    if (written == 'Card' && options.cardGap != null) props.putIfAbsent('spacing', () => options.cardGap);
    if (type == 'progressBar') {
      props.putIfAbsent('color', () => options.accent);
      props.putIfAbsent('backgroundColor', () => options.track);
    }
    // An accordion starts closed unless it says `open`.
    if (type == 'accordion' && !bind.containsKey('props.expanded')) props.putIfAbsent('expanded', () => false);
    // Text with no variant is the body text, so it always has a color.
    if (type == 'text' && !props.containsKey('style')) {
      if (options.textStyles['body'] case final Object body) props['style'] = body is Map ? _copy(body.cast<String, Object?>()) : body;
    }
    // In a grid a child is as wide as its cell and as tall as it says (its
    // row is as tall as its tallest child).
    if (parent?.type == 'gridView') {
      layout['width'] = {'fill': 0};
      layout.putIfAbsent('height', () => {'hug': 0});
    }
    // A grid's rows are as tall as their content unless a height is given.
    if (type == 'gridView' && !props.containsKey('mainAxisExtent')) props.putIfAbsent('shrinkWrapRows', () => true);
    final cell = parent?.grid != null && !(grid != null && identical(parent!.grid, grid));
    if (cell) {
      layout['flex'] = 1;
      layout['width'] = {'fill': 0};
    }
    final inRow = !cell && parent?.type == 'row';
    // On a page, cards side by side are one row of panels: equally tall.
    if (inRow && written == 'Card' && options.width >= 700) {
      final row = nodes[parent!.id];
      final cross = (row?['props'] as Map?)?['crossAxisAlignment'];
      if (row != null && (cross == null || cross == 'center' || cross == 'start')) {
        const Json patch = {
          'props': {'crossAxisAlignment': 'stretch'},
        };
        nodes[parent.id] = mergePatch(row, patch);
        _patches.add({'op': 'patch', 'id': parent.id, 'patch': patch});
      }
    }
    // A button alone on its line in a column is the card's one thing to
    // do: as wide as the column, at the design system's height for it.
    if (options.cta case final Json cta when parent != null && parent.type == 'column' && parent.grid == null && !cell) {
      final p = nodes[parent.id];
      final pw = (p?['layout'] as Map?)?['width'], pc = (p?['props'] as Map?)?['crossAxisAlignment'];
      final hugs = pw is Map && pw.containsKey('hug') || pc == 'center' || pc == 'end';
      final w = layout['width'];
      final wide = w == null || w == 'fill' || w is Map && w.containsKey('fill');
      if (!hugs && wide && !layout.containsKey('height') && const {'filledButton', 'outlinedButton', 'elevatedButton'}.contains(type)) {
        for (final e in cta.entries) {
          layout.putIfAbsent(e.key, () => _copyValue(e.value));
        }
      }
    }
    // A control's step is its height (28 compact, 32 small, 36 medium, 44
    // large): `size:large` on a button, else the design system's height
    // for a control on this canvas (a theme's `sizes.control`; on a page
    // its `sizes.controlWide`).
    if (const {'filledButton', 'outlinedButton', 'elevatedButton', 'textButton'}.contains(type)) {
      final step = switch (props.remove('size')) {
        'xs' => 24.0,
        'compact' => 28.0,
        'small' || 'sm' => 32.0,
        'medium' || 'md' => 36.0,
        'large' || 'lg' => 44.0,
        _ => options.controlHeight,
      };
      if (step != null && !layout.containsKey('height')) layout['height'] = step;
    }
    if (type == 'textField' || type == 'dropdown') {
      Object? copy(Object? v) => v is Map ? _copy(v.cast<String, Object?>()) : v;
      if (options.fieldText != null) props.putIfAbsent('style', () => copy(options.fieldText));
      if (options.fieldLabel != null && type == 'textField' && props['decoration'] is Map) {
        final d = (props['decoration']! as Map).cast<String, Object?>();
        if (d['labelText'] is String && (d['labelText']! as String).isNotEmpty) d.putIfAbsent('labelStyle', () => copy(options.fieldLabel));
        props['decoration'] = d;
      }
    }
    // A date or time field is a field: as tall as the text field and the select beside it.
    if (options.controlHeight != null && const {'datePicker', 'timePicker', 'dateTimeInput'}.contains(type) && !layout.containsKey('height')) {
      layout['height'] = options.controlHeight;
    }
    if (options.controlHeight != null && const {'textField', 'dropdown', 'segmentedButton'}.contains(type)) {
      // A field's label sits above its box, inside its height (11.5 px
      // text and 6 px under it).
      final label = type == 'textField' && switch ((props['decoration'] as Map?)?['labelText']) { final String l => l.isNotEmpty, _ => false };
      if (!layout.containsKey('height') && props['maxLines'] == null && props['minLines'] == null) {
        layout['height'] = options.controlHeight! + (label ? (options.fieldLabel == null ? 20 : 23) : 0);
      }
    }
    if (inRow && type == 'text' && !layout.containsKey('width')) layout['squeezable'] = true;
    // On a page a column beside an icon or a picture gives way too (a name
    // and a note in a narrow tile), where it would push past the row's end.
    if (inRow && type == 'column' && !layout.containsKey('width') && !layout.containsKey('flex') && options.width >= 700 && written != 'Card') {
      layout['squeezable'] = true;
    }
    // A text in a box of a fixed height (an event's block, a tile): the
    // height is the least it is, and it grows when the text takes more lines.
    if (type == 'text' && parent != null && parent.type == 'column') {
      final box = nodes[parent.id];
      final h = (box?['layout'] as Map?)?['height'];
      if (box != null && h is num && h > 0 && (box['props'] as Map?)?['scrollable'] != true) {
        final Json patch = {
          'layout': {'height': {'hug': h}},
        };
        nodes[parent.id] = mergePatch(box, patch);
        _patches.add({'op': 'patch', 'id': parent.id, 'patch': patch});
      }
    }
    // A line chart's values that follow the state are its points worked out.
    if (type == 'lineChart' && bind['props.values'] is String) {
      var e = (bind.remove('props.values')! as String).trim();
      if (e.startsWith(r'${') && e.endsWith('}')) e = e.substring(2, e.length - 1).trim();
      if (e.startsWith('=')) e = e.substring(1).trim();
      bind['props.data'] = '\${= map(range(length($e)), i => {"x": i, "y": ($e)[i]})}';
      props.addAll({'xField': 'x', 'yField': 'y'});
    }
    // A toggle's color is the color it has when on.
    if (const {'checkbox', 'switch', 'radio'}.contains(type) && props.containsKey('color')) {
      props['activeColor'] = props.remove('color');
    }
    if (!layout.containsKey('width')) {
      // In a tile's slot (leading, trailing) a child is as wide as it is.
      final inTile = parent?.type == 'listTile';
      // In a column that is only as wide as its content (a column in a
      // row), so is each child.
      final parentWidth = parent == null ? null : (nodes[parent.id]?['layout'] as Map?)?['width'];
      // Nor in one that centers or ends its children: a child that filled
      // it would have nowhere to move.
      final parentCross = parent == null ? null : (nodes[parent.id]?['props'] as Map?)?['crossAxisAlignment'];
      final inHug = parent?.type == 'column' &&
          parent?.grid == null &&
          (parentWidth is Map && parentWidth.containsKey('hug') || parentCross == 'center' || parentCross == 'end');
      // A row that spreads its children (between, around, evenly) has to be
      // as wide as its place to spread them over: in a centered column too.
      final spread = type == 'row' && !inRow && !inTile && const {'spaceBetween', 'spaceAround', 'spaceEvenly'}.contains(props['mainAxisAlignment']);
      // An icon is as big as it is: it does not stretch across a column.
      final fills = layout.containsKey('flex') ||
          spread ||
          !inRow && !inTile && !inHug && type != 'icon' && (!control || type == 'textField' || type == 'slider' || type == 'dropdown' || type == 'pageView');
      layout['width'] = fills ? {'fill': 0} : {'hug': 0};
    } else {
      layout['width'] = _size(layout['width']);
    }
    // A page is as tall as its page view.
    layout['height'] = layout.containsKey('height') ? _size(layout['height']) : parent?.pages != null ? {'fill': 0} : {'hug': 0};
    // A spacer that grows in a column takes the height left (what is under
    // it sits at the column's foot).
    if (type == 'spacer' && layout.containsKey('flex') && parent?.type == 'column' && !inRow) layout['height'] = {'fill': 0};
    // A size that follows data (w:=…, h:=…) is a fixed one whose number the
    // binding gives: left to hug or fill, the number would change nothing
    // and an empty box would stay at no size.
    if (bind.containsKey('layout.width')) layout['width'] = 0;
    if (bind.containsKey('layout.height')) layout['height'] = 0;
    // Copies across a row that `grow` share its width: a grid with a column
    // per item, each row as tall as its tallest cell.
    if (parent != null && layout.containsKey('flex')) {
      final listId = _acrossLists[parent.id], list = listId == null ? null : nodes[listId];
      if (list != null && list['type'] == 'listView' && (list['props'] as Map?)?['scrollDirection'] == 'horizontal') {
        final data = '${(list['bind'] as Map?)?['data'] ?? ''}';
        final inner = data.startsWith(r'${=')
            ? data.substring(3, data.length - 1).trim()
            : data.startsWith(r'${')
                ? data.substring(2, data.length - 1).trim()
                : '[]';
        final Json listPatch = {
          'type': 'gridView',
          'layout': {'width': {'hug': null, 'fill': 0}},
          'props': {
            'scrollable': null,
            'scrollDirection': null,
            'spacing': null,
            'crossAxisCount': 1,
            'crossAxisSpacing': (list['props'] as Map?)?['spacing'] ?? 0,
            'shrinkWrapRows': true,
            'physics': 'never',
          },
          'bind': {'props.crossAxisCount': '\${= max(1, length($inner))}'},
        };
        const Json itemPatch = {
          'layout': {'width': {'hug': null, 'fill': 0}, 'height': {'fill': null, 'hug': 0}},
          'props': {'mainAxisAlignment': null, 'crossAxisAlignment': 'stretch'},
        };
        nodes[listId!] = mergePatch(list, listPatch);
        nodes[parent.id] = mergePatch(nodes[parent.id]!, itemPatch);
        // A patch cannot change a type: the list is set again, keeping its item.
        _patches
          ..add({'op': 'set', 'id': listId, 'node': {...nodes[listId]!}})
          ..add({'op': 'patch', 'id': parent.id, 'patch': itemPatch});
        layout
          ..remove('flex')
          ..['width'] = {'fill': 0};
      }
    }
    bind.addAll(_labelBinds);
    _labelBinds.clear();
    if (parent?.condition case final String c) {
      final own = bind['visible'];
      bind['visible'] = own is String ? _and(c, own) : c;
    }
    // A line under Pages is the page at its position: the page view draws
    // its one page per position, and each line shows only at its own.
    if (parent != null && parent.pages != null && parent.each == null && parent.condition == null) {
      final at = (nodes[parent.id]?['children'] as List?)?.length ?? 0;
      final shown = _formula('index == $at'), own = bind['visible'];
      bind['visible'] = own is String ? _and(shown, own) : shown;
      final view = nodes[parent.pages]!;
      (view['props'] as Json? ?? (view['props'] = <String, Object?>{}))['itemCount'] = at + 1;
      _patches.add({'op': 'patch', 'id': parent.pages, 'patch': {'props': {'itemCount': at + 1}}});
    }

    // What scrolls sideways inside a padded card cannot reach the card's
    // edge, so it would end in a hard cut: it fades out there instead.
    if ((type == 'row' && props['scrollable'] == true && props['scrollDirection'] == 'horizontal') ||
        (type == 'pageView' && props['viewportFraction'] != null)) {
      props.putIfAbsent('edgeFade', () => 12);
    }

    final out = <String, Object?>{
      'type': type,
      'layout': layout,
      if (props.isNotEmpty) 'props': props,
      if (decoration.isNotEmpty) 'decoration': decoration,
      if (bind.isNotEmpty) 'bind': bind,
      if (reactions.isNotEmpty) 'actions': reactions,
    };
    _merge(out, node);
    // An expression written as a value in the tail ({"props": {"color": "${= …}"}})
    // is a binding: only a text's own text reads one as written.
    if (node.isNotEmpty) {
      final moved = <String, Object?>{};
      void lift(Json m, String path) {
        for (final key in m.keys.toList()) {
          final v = m[key];
          final at = '$path.$key';
          if (v is Map) {
            final inner = v.cast<String, Object?>();
            lift(inner, at);
            m[key] = inner;
          } else if (v is String && v.contains(r'${') && !(type == 'text' && at == 'props.text')) {
            moved[at] = v;
            m.remove(key);
          }
        }
      }

      for (final section in const ['props', 'layout', 'decoration']) {
        if (node[section] is Map && out[section] is Map) {
          final m = (out[section]! as Map).cast<String, Object?>();
          lift(m, section);
          out[section] = m;
        }
      }
      if (moved.isNotEmpty) out['bind'] = {...?(out['bind'] as Map?)?.cast<String, Object?>(), ...moved};
    }
    nodes[id] = out;
    if (donutKeys != null) _donutLegend(id, out, donutKeys, inRow: parent?.type == 'row');
    if (avatarName != null) {
      // "Maya Reyes" is MR; a value read from state is shown as it is.
      final reads = avatarName.contains(r'${') || avatarName.contains('{');
      final words = avatarName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      final initials = reads || words.isEmpty ? avatarName : words.length == 1 ? words.first.substring(0, words.first.length.clamp(0, 2)).toUpperCase() : '${words.first[0]}${words.last[0]}'.toUpperCase();
      final size = (out['layout'] as Map)['width'] as num;
      final base = options.textStyles['strong'] ?? options.textStyles['body'];
      nodes['${id}Text'] = {
        'type': 'text',
        'layout': {'width': {'hug': 0}, 'height': {'hug': 0}},
        'props': {
          'text': initials,
          'style': {...(base is Map ? _copy(base.cast<String, Object?>()) : const <String, Object?>{}), 'fontSize': (size * 0.38).roundToDouble(), 'fontWeight': 600},
        },
      };
      out['children'] = ['${id}Text'];
      _parentOf['${id}Text'] = id;
    }
    if (type == 'radialGauge') {
      // A gauge is its arc with the figure it shows inside: a stack under
      // the line's id, so the id still names the whole.
      final value = (out['props'] as Map?)?['value'], bound = (out['bind'] as Map?)?['props.value'];
      final body = options.textStyles['body'];
      Json figure(Object? base, Json over) => {...(base is Map ? _copy(base.cast<String, Object?>()) : const <String, Object?>{}), ...over};
      final arcLayout = (out['layout']! as Map).cast<String, Object?>();
      nodes[id] = {
        'type': 'stack',
        'layout': {...arcLayout},
        if (out['visible'] != null) 'visible': out.remove('visible'),
        'children': ['${id}Arc', '${id}Value', if (gaugeUnit != null) '${id}Unit'],
      };
      nodes['${id}Arc'] = out..['layout'] = {'width': {'fill': 0}, 'height': {'fill': 0}, 'x': 0, 'y': 0};
      nodes['${id}Value'] = {
        'type': 'text',
        'layout': {'width': {'hug': 0}, 'height': {'hug': 0}, 'x': {'align': 0}, 'y': {'align': gaugeUnit == null ? 0.15 : 0.05}},
        // The figure is sized to its gauge.
        'props': {
          'text': value is num ? (value == value.roundToDouble() ? '${value.round()}' : '$value') : '',
          // The theme's style for a gauge's figure (`gaugeValue`), else a
          // heavy 44; smaller in a small gauge.
          'style': arcLayout['width'] is num && (arcLayout['width']! as num) < 200
              ? figure(body, {'fontSize': ((arcLayout['width']! as num) / 6).clamp(18, 40).round(), 'fontWeight': 700})
              : options.textStyles['gaugeValue'] ?? figure(body, {'fontSize': 44, 'fontWeight': 700}),
        },
        if (bound != null) 'bind': {'props.text': bound},
      };
      if (gaugeUnit != null) {
        nodes['${id}Unit'] = {
          'type': 'text',
          'layout': {'width': {'hug': 0}, 'height': {'hug': 0}, 'x': {'align': 0}, 'y': {'align': 0.5}},
          'props': {'text': gaugeUnit, 'style': options.textStyles['gaugeUnit'] ?? figure(options.textStyles['muted'] ?? body, const {})},
        };
      }
      for (final child in ['${id}Arc', '${id}Value', '${id}Unit']) {
        _parentOf[child] = id;
      }
    }
    if (parent == null) {
      if (_root != null) {
        // A page written as several top-level sections (a header, the
        // content, a footer): they stack in a column that becomes the root.
        nodes.remove(id);
        final page = _pageColumn();
        nodes[id] = out;
        (nodes[page]!['children']! as List<Object?>).add(id);
        _parentOf[id] = page;
        _stack.add(_Open(indent, id, type, condition: null, grid: grid));
      } else {
        _root = id;
      }
    } else {
      final p = nodes[parent.id]!;
      if (spec.type == 'canvas') return _issue(column, 'A canvas cannot be a child.');
      if (parent.type == 'listTile') {
        final slots = (p['slots'] as Json?) ?? (p['slots'] = <String, Object?>{});
        final slot = type == 'icon' && !slots.containsKey('leading') ? 'leading' : 'trailing';
        slots[slot] = id;
        _slotOf[id] = slot;
        // A block of text beside a tile's title leaves the title room.
        if (slot == 'trailing' && (type == 'column' || type == 'row')) {
          (out['layout']! as Json)['constraints'] = {'maxWidth': 150};
        }
      } else {
        ((p['children'] as List<Object?>?) ?? (p['children'] = <Object?>[])).add(id);
      }
      _parentOf[id] = parent.id;
      if (cell) _intoRow(parent.grid!, id);
    }
    if (type == 'pageView') {
      // Its page: what the page view draws at each position.
      final pageId = '${id}Page';
      nodes[pageId] = {
        'type': 'column',
        'layout': {'width': {'fill': 0}, 'height': {'fill': 0}},
        'props': {'crossAxisAlignment': 'stretch'},
      };
      ((out['children'] as List<Object?>?) ?? (out['children'] = <Object?>[])).add(pageId);
      _parentOf[pageId] = id;
      props.putIfAbsent('scrollDirection', () => 'horizontal');
      // A line with no prop of its own has them now (what a {…} at its end
      // gave it are its props then).
      if (out['props'] case final Map<Object?, Object?> given) {
        given.putIfAbsent('scrollDirection', () => 'horizontal');
      } else {
        out['props'] = props;
      }
      // With the next page showing at the edge, the first sits at the start
      // and the pages stand apart (gap, 8 unless written).
      final gap = props.remove('spacing');
      if (props['viewportFraction'] != null) {
        props.putIfAbsent('padEnds', () => false);
        nodes[pageId]!['layout'] = <String, Object?>{'width': {'fill': 0}, 'height': {'fill': 0}, 'padding': [0, 0, gap is num ? gap : 8, 0]};
      }
      _stack.add(_Open(indent, pageId, 'column', pages: id));
    } else {
      _stack.add(_Open(indent, id, type, condition: null, grid: grid));
    }
    // Its strings as text nodes: an accordion's header is its first child, a
    // list tile's are its title and subtitle.
    final texts = [..._texts];
    _texts.clear();
    if (written == 'Wanted') {
      // Its strings are the request, not text to show.
      if (texts.isNotEmpty) wanted.add(WantedBlock(texts.first, texts.length > 1 ? texts[1] : '', id));
      texts.clear();
    }
    try {
      _strings(texts, type, id, out);
    } finally {
      _textStyle = null;
    }
  }

  /// The donuts given a legend: each as it was written, and its labels.
  final _donuts = <String, ({Json chart, List<String> labels})>{};

  /// A page that writes a donut's legend itself (its labels are texts
  /// elsewhere on the page) keeps its own: the chart is as it was written.
  void _ownLegends() {
    for (final e in _donuts.entries) {
      final id = e.key;
      final own = nodes.keys.where((k) => k != id && k.startsWith(id) && _under(k, id)).toSet();
      final labels = {for (final l in e.value.labels) if (l.trim().isNotEmpty) l.trim().toLowerCase()};
      final written = <String>{};
      for (final n in nodes.entries) {
        if (own.contains(n.key) || n.value['type'] != 'text') continue;
        final text = (n.value['props'] as Map?)?['text'];
        if (text is String && labels.contains(text.trim().toLowerCase())) written.add(text.trim().toLowerCase());
      }
      if (written.length < (labels.length < 2 ? labels.length : 2) || written.isEmpty) continue;
      own
        ..forEach(nodes.remove)
        ..forEach(_parentOf.remove);
      nodes[id]!
        ..clear()
        ..addAll(e.value.chart);
      if (_canvas) {
        ops
          ..add({'op': 'remove', 'ids': ['${id}Chart', '${id}Legend']})
          ..add({'op': 'set', 'id': id, 'node': {...nodes[id]!}});
      }
    }
    _donuts.clear();
  }

  bool _under(String id, String ancestor) {
    for (String? at = _parentOf[id]; at != null; at = _parentOf[at]) {
      if (at == ancestor) return true;
    }
    return false;
  }

  /// A donut with its legend: the line's node becomes a row that wraps, of
  /// the chart and a line per share (its color, its label, its part of the
  /// whole). Where the two do not fit side by side the legend goes under.
  void _donutLegend(String id, Json out, List<({String label, Object? value, Object? color})> keys, {required bool inRow}) {
    final chart = <String, Object?>{...out};
    _donuts[id] = (chart: {...out}, labels: [for (final k in keys) k.label]);
    final layout = (chart['layout']! as Map).cast<String, Object?>();
    final flex = layout.remove('flex');
    final side = switch ((layout['width'], layout['height'])) { (final num w, _) => w, (_, final num h) => h, _ => 160 };
    chart['layout'] = {...layout, 'width': side, 'height': layout['height'] is num ? layout['height'] : side};
    final visible = (chart['bind'] as Map?)?['visible'];
    if (visible != null) chart['bind'] = {...(chart['bind']! as Map).cast<String, Object?>()}..remove('visible');
    out
      ..clear()
      ..addAll({
        'type': 'row',
        'layout': {'width': flex != null || !inRow ? {'fill': 0} : {'hug': 0}, 'height': {'hug': 0}, 'flex': ?flex},
        'props': {'spacing': 24, 'runSpacing': 16, 'wrap': true, 'crossAxisAlignment': 'center'},
        if (visible != null) 'bind': {'visible': visible},
        'children': <Object?>['${id}Chart', '${id}Legend'],
      });
    Object? style(String name) => switch (options.textStyles[name] ?? options.textStyles['body']) { final Map m => _copy(m.cast<String, Object?>()), final other => other };
    num total = 0;
    for (final k in keys) {
      total += k.value is num ? k.value! as num : 0;
    }
    nodes['${id}Chart'] = chart;
    nodes['${id}Legend'] = {
      'type': 'column',
      'layout': {'width': {'fill': 0}, 'height': {'hug': 0}, 'basis': 160, 'flex': 1, 'constraints': {'maxWidth': 320}},
      'props': {'spacing': 10, 'crossAxisAlignment': 'stretch'},
      'children': <Object?>[for (var i = 0; i < keys.length; i++) '${id}Key$i'],
    };
    _parentOf['${id}Chart'] = id;
    _parentOf['${id}Legend'] = id;
    for (var i = 0; i < keys.length; i++) {
      final k = keys[i];
      final share = total > 0 && k.value is num ? '${((k.value! as num) / total * 100).round()}%' : null;
      nodes['${id}Key$i'] = {
        'type': 'row',
        'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
        'props': {'spacing': 10, 'crossAxisAlignment': 'center'},
        'children': <Object?>['${id}Dot$i', '${id}Label$i', if (share != null) '${id}Share$i'],
      };
      nodes['${id}Dot$i'] = {
        'type': 'column',
        'layout': {'width': 10, 'height': 10},
        'decoration': {
          'fills': [
            {'color': k.color},
          ],
          'radius': 5,
        },
      };
      nodes['${id}Label$i'] = {
        'type': 'text',
        'layout': {'width': {'fill': 0}, 'height': {'hug': 0}, 'flex': 1},
        'props': {'text': k.label, 'style': ?style('muted')},
      };
      if (share != null) {
        nodes['${id}Share$i'] = {
          'type': 'text',
          'layout': {'width': {'hug': 0}, 'height': {'hug': 0}},
          'props': {'text': share, 'style': ?style('strong')},
        };
      }
      _parentOf['${id}Key$i'] = '${id}Legend';
      for (final part in ['Dot', 'Label', if (share != null) 'Share']) {
        _parentOf['${id}$part$i'] = '${id}Key$i';
      }
    }
  }

  void _strings(List<String> texts, String type, String id, Json out) {
    for (var i = 0; i < texts.length; i++) {
      final tid = _id('text');
      final container = type == 'column' || type == 'row' || type == 'stack';
      final style = _textStyle ?? options.textStyles[container ? 'body' : i == 0 ? 'strong' : 'muted'];
      nodes[tid] = {
        'type': 'text',
        // In a tile's slot a text is as wide as it is; an accordion's header fills it.
        'layout': {'width': type == 'listTile' || _textStyle != null ? {'hug': 0} : {'fill': 0}, 'height': {'hug': 0}},
        'props': {'text': texts[i], if (style != null) 'style': style is Map ? _copy(style.cast<String, Object?>()) : style},
      };
      _parentOf[tid] = id;
      if (type == 'listTile') {
        final slot = i == 0 ? 'title' : 'subtitle';
        ((out['slots'] as Json?) ?? (out['slots'] = <String, Object?>{}))[slot] = tid;
        _slotOf[tid] = slot;
      } else {
        ((out['children'] as List<Object?>?) ?? (out['children'] = <Object?>[])).add(tid);
      }
    }
  }

  /// [line] with the word [name] read as `item`, outside quoted text and
  /// inside `{…}` within it.
  String _rename(String line, String name, [String to = 'item']) {
    // A short loop name may also be a layout key (`each h ... Text ... h:120`).
    // A key followed by ':' is notation, not a reference to the item.
    final word = RegExp('(?<![A-Za-z0-9_.#])${RegExp.escape(name)}(?![A-Za-z0-9_])');
    final out = StringBuffer();
    var quoted = false, inner = false, depth = 0, start = 0;
    void flush(int end, bool code) {
      final part = line.substring(start, end);
      out.write(code
          ? part.replaceAllMapped(word, (m) {
              // In `h:120` the `h` is a prop key. In `live ? h:4` it
              // is still the loop value, despite the following colon.
              final before = part.substring(0, m.start).trimRight();
              final key = m.end < part.length && part[m.end] == ':' &&
                  (m.start == 0 || RegExp(r'\s').hasMatch(part[m.start - 1])) &&
                  !before.endsWith('?');
              return key ? m[0]! : to;
            })
          : part);
      start = end;
    }

    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"' && quoted && depth > 0) {
        // A text inside an expression inside a text: "{late ? "Late" : name}".
        flush(i, !inner);
        inner = !inner;
      } else if (inner) {
        continue;
      } else if (c == '"' && (i == 0 || line[i - 1] != r'\')) {
        flush(i, !quoted || depth > 0);
        quoted = !quoted;
        depth = 0;
      } else if (quoted && c == '{') {
        if (depth == 0) flush(i, false);
        depth++;
      } else if (quoted && c == '}' && depth > 0) {
        depth--;
        if (depth == 0) flush(i, true);
      }
    }
    flush(line.length, !quoted);
    return out.toString();
  }

  /// Moves [id], just added under a grid, into the grid's current row (a
  /// new row every `cols` cells).
  void _intoRow(_Grid g, String id) {
    final gridNode = nodes[g.id]!;
    (gridNode['children'] as List<Object?>).remove(id);
    if (g.row == null || g.inRow >= g.cols) {
      final rowId = '${g.id}Row${++g.rows}';
      // Before the cell, so it is sent first.
      final cellNode = nodes.remove(id)!;
      nodes[rowId] = {
        'type': 'row',
        'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
        'props': {'spacing': g.gap, 'crossAxisAlignment': 'stretch'},
        'children': <Object?>[],
      };
      nodes[id] = cellNode;
      (gridNode['children'] as List<Object?>).add(rowId);
      _parentOf[rowId] = g.id;
      _gridRows[rowId] = g;
      g
        ..row = rowId
        ..inRow = 0;
    }
    (nodes[g.row]!['children'] as List<Object?>).add(id);
    _parentOf[id] = g.row!;
    g.inRow++;
  }

  /// A grid ends: its last row is filled out with empty cells, so its cells
  /// are as wide as the rows above.
  static final _idMark = RegExp(r'^([A-Z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)?)#[A-Za-z_][A-Za-z0-9_]*');

  void _close(_Open open) {
    _fitRow(open);
    final g = open.grid;
    if (g == null || open.id != g.id || open.condition != null || g.row == null) return;
    while (g.inRow < g.cols) {
      final sid = _id('spacer');
      nodes[sid] = {'type': 'spacer', 'layout': {'flex': 1, 'width': {'fill': 0}, 'height': {'hug': 0}}};
      (nodes[g.row]!['children'] as List<Object?>).add(sid);
      _parentOf[sid] = g.row!;
      g.inRow++;
    }
    g.row = null;
  }

  /// The end of the text: what is still open closes.
  void finish() {
    if (_host == null) {
      _closeBlock();
      // The viewer a gallery of the page opens its photos in, over the window.
      if (_pages.viewerUsed && !_continues && !_taken(_pages.viewer!)) {
        final viewer = _pages.viewer!;
        if (_pages.overlay('Lightbox#$viewer photos:=${viewer}Photos =${viewer}At') case final Overlay o) {
          _openBlock(o);
          _closeBlock();
        }
      }
      // An app's sidebar, where the window has no room for it: a drawer the
      // top bar's menu button opens, each of its lines closing it as it is used.
      if (_pages.sidebarButton && _pages.sidebar.isNotEmpty && !_continues) {
        if (_pages.overlay('Drawer#${_pages.sidebarMenu}${_pages.sidebarRest}') case final Overlay o) {
          _openBlock(o);
          for (final l in _pages.sidebar) {
            // Its ids are the sidebar's own: the copy has none.
            _feed(l.indent, l.text.replaceFirstMapped(_idMark, (m) => m[1]!), closes: 'all');
          }
          _closeBlock();
        }
      }
    }
    if (_everyOpen case final String open) {
      _everyOpen = null;
      line('$open ->');
    }
    if (_open case final String open) {
      // Read as far as it goes: the line says what is wrong with it.
      _open = null;
      line(open);
    }
    if (_pending != null) {
      _issue(1, 'The JSON of a node or document line was never closed: one closing brace per opening brace.');
      _pending = null;
    }
    final before = nodes.length;
    for (final l in _pages.finish()) {
      _lineAt(l.indent, l.text, l.indent + 1);
    }
    while (_stack.isNotEmpty) {
      _close(_stack.removeLast());
    }
    nodes.keys.skip(before).toList().forEach(_emit);
    for (final scroll in _scrolls) {
      if (_anchors[scroll['node']] case final String id) scroll['node'] = id;
    }
    _ownLegends();
    _reflow();
    // What a last line changed on a node already sent (an `every`).
    if (_canvas && _patches.isNotEmpty) {
      ops.addAll(_patches);
      _patches.clear();
    }
  }

  /// The node's main string: a text's text, a button's label, a field's label.
  void _main(String type, WidgetSpec spec, String s, Json props, Json decoration) {
    final text = _interpolate(s);
    // A date or time field's string is its label, as a text field's is.
    if (const {'datePicker', 'timePicker', 'dateTimeInput'}.contains(type) && spec.props.any((p) => p.key == 'decoration')) {
      final d = (props['decoration'] as Json?) ?? (props['decoration'] = <String, Object?>{});
      if (text.contains(r'${')) {
        _labelBinds['props.decoration.labelText'] = text;
      } else {
        d.putIfAbsent('labelText', () => text);
      }
      return;
    }
    if (type == 'textField') {
      final d = (props['decoration'] as Json?) ?? (props['decoration'] = <String, Object?>{});
      final key = d.containsKey('labelText') || _labelBinds.containsKey('props.decoration.labelText') ? 'hintText' : 'labelText';
      // A label that reads data (`Input "{field.label}"`) is bound: only a
      // text node reads an expression as written.
      if (text.contains(r'${')) {
        _labelBinds['props.decoration.$key'] = text;
      } else {
        d[key] = text;
      }
      return;
    }
    // A string on a container is a text inside it.
    if (const {'accordion', 'expansionTile', 'listTile', 'column', 'row', 'stack'}.contains(type)) {
      _texts.add(text);
      return;
    }
    final key = _mainKey(type, spec);
    if (key == null) {
      _issue(1, 'A $type has no text of its own.');
      return;
    }
    if (key != 'icon' && type != 'text' && type != 'box' && text.contains(r'${')) {
      _labelBinds['props.$key'] = text;
      return;
    }
    // An icon chosen by data: `Icon "{open ? "expand_less" : "expand_more"}"`.
    if (key == 'icon' && text.contains(r'${')) {
      _labelBinds['props.icon'] = text;
      return;
    }
    props[key] = key == 'icon' ? s : text;
  }

  String? _mainKey(String type, WidgetSpec spec) {
    if (type == 'box') return 'text';
    if (type == 'dropdown') return 'hint';
    // A component's main string: its label, title or text, else its first
    // text parameter.
    if (type[0].toUpperCase() == type[0]) return notationStrings(spec).firstOrNull;
    for (final k in const ['text', 'label', 'title', 'icon', 'hint']) {
      if (spec.props.any((p) => p.key == k)) return k;
    }
    return null;
  }

  /// Where [what] first is in [line] outside quotes (-1: nowhere).
  int _outside(String line, String what) {
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      if (line[i] == '"' && (i == 0 || line[i - 1] != r'\')) quoted = !quoted;
      if (!quoted && line.startsWith(what, i)) return i;
    }
    return -1;
  }

  /// What the UI is drawn on when its root is not a card: the surface, so
  /// its dark text is never on nothing.
  Json get _surface => {
        'fills': [
          {'color': options.surface},
        ],
      };

  /// State written as a formula (`state total=sum(cart,x=>x.price)`): not a
  /// variable but a name for the formula, written out where it is read.
  final Map<String, String> _derived;

  void _state(String rest, int column) {
    final m = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)$').firstMatch(rest);
    if (m == null) return _issue(column, 'State is written: state name=value.');
    var written = m[2]!.trim();
    // One formula may read another (`state total=subtotal-discount`).
    for (final d in _derived.entries) {
      if (written.contains(d.key)) written = _rename('x:=$written', d.key, '(${d.value})').substring(3);
    }
    // Text in quotes is not an operator: `"a + b"` is a value, `"Total " + n` a formula.
    final code = written.replaceAll(RegExp('"[^"]*"|\'[^\']*\''), '');
    if (!_literal(written).$1 && RegExp(r'[(+*/?<>&|]').hasMatch(code)) {
      _derived[m[1]!] = written;
      return;
    }
    var value = _value(written);
    // A start taken from state already declared (`state left=today.work`):
    // the value it has there, so the new state is its own and can change.
    if (value is String && RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*)*$').hasMatch(written)) {
      final parts = written.split('.');
      Object? from = variables[parts.first]?['value'];
      for (final key in parts.skip(1)) {
        from = from is Map ? from[key] : null;
      }
      if (from != null && variables.containsKey(parts.first)) value = jsonDecode(jsonEncode(from));
    }
    variables[m[1]!] = {
      'name': m[1],
      'type': switch (value) { bool _ => 'boolean', int _ => 'integer', num _ => 'decimal', List _ => 'list', Map _ => 'map', _ => 'text' },
      'value': value,
    };
  }

  /// A bare word on a component's line that can only mean one thing: the
  /// value of its one enumerated parameter that has it (`ActionButton
  /// "Cancel" quiet`: tone), or a parameter set with `=` where `:=` was
  /// meant (`qty=count`).
  bool _componentWord(String word, WidgetSpec spec, Json props, Json bind) {
    final eq = word.indexOf('=');
    if (eq > 0) {
      final key = word.substring(0, eq);
      if (!spec.props.any((p) => p.key == key)) return false;
      final l = _literal(word.substring(eq + 1));
      if (l.$1) {
        props[key] = l.$2;
      } else {
        bind['props.$key'] = _read(word.substring(eq + 1));
      }
      return true;
    }
    final takers = spec.props
        .where((p) => p.type.kind == PropKind.enumeration && p.type.values.contains(word) && !props.containsKey(p.key) && !bind.containsKey('props.${p.key}'))
        .toList();
    if (takers.length != 1) return false;
    props[takers.single.key] = word;
    return true;
  }

  static final _handlerKey = RegExp(r'^(on[A-Z][A-Za-z]*|tap|press|click|change)$');

  /// What fires a handler named [key] on a node of [type]: a component's
  /// event of that name (else its first), a control's change, a tap.
  Json _handlerTrigger(String key, String type, WidgetSpec? component, Json node) {
    if (node.containsKey('dropTarget')) return {'type': 'drop'};
    if (component != null) {
      final named = component.events.where((e) => e.key == key).firstOrNull ??
          (key == 'change' || key == 'onChange' ? component.events.where((e) => e.key == 'onChanged').firstOrNull : null) ??
          component.events.firstOrNull;
      if (named != null) return {'type': 'event', 'event': named.key};
    }
    final bare = key.startsWith('on') && key.length > 2 ? '${key[2].toLowerCase()}${key.substring(3)}' : key;
    if (const {'swipeLeft', 'swipeRight', 'swipeUp', 'swipeDown', 'longPress', 'doubleTap'}.contains(bare)) return {'type': bare};
    if (const {'rightClick', 'secondaryClick', 'contextMenu'}.contains(bare)) return {'type': 'secondaryClick'};
    final changes = key == 'change' || key == 'onChange' || key == 'onChanged';
    return {'type': changes || _valueProps.containsKey(type) && !key.contains('ress') && key != 'tap' && key != 'click' ? 'changed' : 'click'};
  }

  /// A handler's statements as the notation's actions: the control's new
  /// value is `value` to a model and `result` to the engine.
  String _statements(String body) => variables.containsKey('value') ? body : _rename(body, 'value', 'result');

  /// `if (cond) { a = 1; b = 2 }` in a handler, as the assignments it stands
  /// for: each made only while the condition holds (`a = cond ? 1 : a`).
  /// Actions that are not assignments are left as they are, unguarded.
  String _guarded(String text) {
    final m = RegExp(r'if\s*\((.+?)\)\s*\{([^{}]*)\}').firstMatch(text);
    if (m == null) return text;
    final cond = m[1]!.trim();
    final steps = [
      for (final step in _split(m[2]!, ';'))
        if (step.trim().isNotEmpty)
          switch (RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=)\s*(.+)$').firstMatch(_inPlace(step.trim()))) {
            final RegExpMatch set => '${set[1]} = ($cond) ? (${set[2]}) : ${set[1]}',
            _ => step.trim(),
          },
    ];
    return _guarded('${text.substring(0, m.start)}${steps.join('; ')}${text.substring(m.end)}');
  }

  /// A change written where the value stands, as the list rebuilt that the
  /// engine needs: `n += 1`, `n++`, a field of the repeated item
  /// (`item.qty = 2` under an each over a list variable) and a field of an
  /// element by its place (`rows[i].qty = 2`).
  String _inPlace(String a) {
    // tasks.add(x), tasks.push(x), tasks.remove(x): the list with it, the list without it.
    final call = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\.(add|push|append|remove)\((.+)\)$').firstMatch(a);
    if (call != null) return '${call[1]} = ${call[2] == 'remove' ? 'without' : 'append'}(${call[1]},${call[3]})';
    var m = RegExp(r'^([A-Za-z_][A-Za-z0-9_.\[\]]*)\s*(\+\+|--)$').firstMatch(a);
    if (m != null) a = '${m[1]} = ${m[1]} ${m[2] == '++' ? '+' : '-'} 1';
    m = RegExp(r'^([A-Za-z_][A-Za-z0-9_.\[\]]*)\s*([-+*/])=\s*(.+)$').firstMatch(a);
    if (m != null) a = '${m[1]} = ${m[1]} ${m[2]} (${m[3]})';
    final field = RegExp(r'^item\.([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=)\s*(.+)$').firstMatch(a);
    if (field != null) {
      final over = _stack.reversed.where((o) => o.each != null).firstOrNull?.list;
      if (over != null && _identifier.hasMatch(over) && !over.contains('.')) {
        return '$over = setAt($over,index,with(item,"${field[1]}",${field[2]}))';
      }
    }
    final at = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\[([^\]]+)\]\.([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=)\s*(.+)$').firstMatch(a);
    if (at != null) return '${at[1]} = setAt(${at[1]},${at[2]},with(${at[1]}[${at[2]}],"${at[3]}",${at[4]}))';
    return a;
  }

  List<Json> _actions(String text, int column) {
    final out = <Json>[];
    for (final part in _split(_guarded(text), ';')) {
      final a = _inPlace(part.trim());
      if (a.isEmpty) continue;
      if (a.startsWith('{')) {
        final j = _json(a);
        if (j is Map) out.add(j.cast<String, Object?>());
        continue;
      }
      final set = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=)\s*(.+)$').firstMatch(a);
      if (set != null) {
        final v = set[2]!.trim();
        final literal = _literal(v);
        // A bare word that names no variable is text (choice=basic).
        final word = !literal.$1 && _identifier.hasMatch(v) && !v.contains('.') && !variables.containsKey(v) && !const {'result', 'item', 'index'}.contains(v);
        out.add({
          'type': 'setVariable',
          'variable': set[1],
          'value': word
              ? v
              : literal.$1 && literal.$2 is String
                  ? _interpolate(literal.$2! as String)
                  : _formula(v),
        });
        if (!variables.containsKey(set[1])) {
          final start = literal.$1 ? literal.$2 : null;
          variables[set[1]!] = {
            'name': set[1],
            'type': switch (start) { bool _ => 'boolean', int _ => 'integer', num _ => 'decimal', _ => 'text' },
            'value': switch (start) { bool _ => false, num _ => 0, _ => '' },
          };
        }
        continue;
      }
      final space = a.indexOf(' ');
      final verb = space < 0 ? a : a.substring(0, space), arg = space < 0 ? '' : a.substring(space + 1).trim();
      final s = arg.startsWith('"') ? _interpolate(_Tokens(arg).string()) : arg;
      switch (verb) {
        case 'emit':
          // The core's "tell the host": outside a component it reaches the
          // session's events (and the app's), with an optional value.
          final sp = s.indexOf(' ');
          final value = sp < 0 ? null : s.substring(sp + 1).trim();
          out.add({
            'type': 'componentEvent',
            'event': sp < 0 ? s : s.substring(0, sp),
            // Plain words after the event are its value as text
            // (`emit choose plan A`); anything else is read as a value.
            if (value != null && value.isNotEmpty)
              'value': RegExp(r'^[A-Za-z][A-Za-z0-9]*( [A-Za-z0-9]+)+$').hasMatch(value) ? value : _valueOrRead(value),
          });
        case 'open':
          // An overlay written in this text (Dialog#id, Menu#id…) opens as
          // its kind says; one written further down completes this then.
          final Json action = {'type': 'openModal', 'to': s, ...?switch (_top._overlayActions[s]) { final Json a => _copy(a), _ => null }};
          _top._opens.add(action);
          out.add(action);
        case 'scroll':
          // `scroll pricing`, `scroll to pricing`, `scroll #pricing`: the page
          // moves to that part, named by its id or by an anchor (`#pricing`
          // after a line, or id:pricing on it).
          final target = s.replaceFirst(RegExp(r'^to\s+'), '').replaceFirst(RegExp(r'^#'), '').trim();
          if (target.isEmpty) {
            _issue(column, 'A scroll names where to: scroll pricing (the id of a line, or an anchor written #pricing after a line).');
          } else {
            final Json action = {'type': 'scrollTo', 'node': target, 'durationMs': 400, 'offset': 72};
            _scrolls.add(action);
            out.add(action);
          }
        case 'close':
          out.add({'type': 'closeModal'});
        case 'go':
          // A destination may be worked out (a SiteNav's link name as a
          // screen id: go replace(lower(result)," ","_")); a bare id is the id.
          // A page's id may have hyphens (go get-started is that page, not a
          // subtraction), and a destination already written ${= …} is whole.
          final fixed = arg.startsWith('"') || _identifier.hasMatch(s) || RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(s) || (s.startsWith(r'${') && s.endsWith('}'));
          out.add({'type': 'navigate', 'to': fixed ? s : _formula(s)});
        case 'toast':
          out.add({'type': 'showToast', 'message': s});
        case 'announce':
          out.add({'type': 'announce', 'message': s});
        case 'link':
          out.add({'type': 'openLink', 'url': s});
        default:
          _issue(column, 'Unknown action "$verb". Actions: name=value, emit <event>, toast "…", announce "…", open <id>, close, go <screen>, scroll <id>, link <url>, or JSON.');
      }
    }
    return out;
  }

  Object? _valueOrRead(String raw) {
    final l = _literal(raw);
    return l.$1 ? l.$2 : _read(raw);
  }

  String _id(String type) {
    final n = _counts[type] = (_counts[type] ?? 0) + 1;
    return '$type$n';
  }

  static final _operatorAhead = RegExp(r' +(==|!=|>=|<=|&&|\|\||[<>?+*/]|-(?!>)|and\b|or\b) *[A-Za-z0-9_("!\x27-]');
  static final _bracedValue = RegExp(r'^\{[^{}":,]+\}$');

  /// How many brackets [raw] leaves open (text in quotes aside): the value
  /// goes on past a space until they close (`rows:=[["Total", money(n)]]`).
  static int _opened(String raw) {
    var depth = 0, quoted = false;
    for (var i = 0; i < raw.length; i++) {
      final c = raw[i];
      if (c == '"' && (i == 0 || raw[i - 1] != r'\')) quoted = !quoted;
      if (quoted) continue;
      if (c == '(' || c == '[' || c == '{') depth++;
      if (c == ')' || c == ']' || c == '}') depth--;
    }
    return depth;
  }

  static bool _readsValues(Object? json) => switch (json) {
        String s => _spans(s).isNotEmpty,
        List l => l.any(_readsValues),
        Map m => m.values.any(_readsValues),
        _ => false,
      };

  /// [json] as a formula, each text that reads values (`"{n} left"`) as its
  /// parts joined (`(n) + " left"`).
  String _formulaSource(Object? json) {
    switch (json) {
      case final String s when _spans(s).isNotEmpty:
        final parts = <String>[];
        var at = 0;
        for (final (start, end) in _spans(s)) {
          if (start > at) parts.add(jsonEncode(s.substring(at, start)));
          parts.add('(${_natural(s.substring(start + 1, end - 1).trim())})');
          at = end;
        }
        if (at < s.length) parts.add(jsonEncode(s.substring(at)));
        // Text first, so the parts join as text whatever the values are.
        if (!parts.first.startsWith('"')) parts.insert(0, '""');
        return '(${parts.join(' + ')})';
      case final List l:
        return '[${l.map(_formulaSource).join(', ')}]';
      case final Map m:
        return '{${m.entries.map((e) => '${jsonEncode(e.key)}: ${_formulaSource(e.value)}').join(', ')}}';
      default:
        return jsonEncode(json);
    }
  }

  /// `{count > 0 and not done}` after a key: an expression in braces, not a
  /// map (`{"a": 1}`, `{a: 1}`), which names a key first.
  static bool _bracedExpression(String raw) {
    if (!raw.startsWith('{') || !raw.endsWith('}') || raw.length < 3) return false;
    if (RegExp(r'^\{\s*("[^"]*"|[A-Za-z_][A-Za-z0-9_]*)\s*:').hasMatch(raw)) return false;
    try {
      jsonDecode(raw);
      return false;
    } catch (_) {
      return true;
    }
  }
  static final _expressionStart = RegExp(r'^(![A-Za-z_(]|[A-Za-z_][A-Za-z0-9_.\[\]]*(\(|==|!=|>=|<=|>|<|&&|\|\||\?|\+|\*))');
  static final _variablePath = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*|\[[^\]\s]*\])*$');
  /// The condition of the last `if` (and its `else if`s) at each depth, for an `else`.
  final Map<int, String> _ifAt = {};

  static final _dotsLine = RegExp(r'^Dots(#[A-Za-z_][A-Za-z0-9_]*)?\s+=([A-Za-z_][A-Za-z0-9_]*)\s+count:(\S+)(\s.*)?$');
  static final _identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_.]*$');

  /// An expression as a binding reads it: a name, or a formula.
  String _read(String expr) {
    final e = expr.trim();
    // A word that is a value, not a name (enabled:=false): the value.
    if (const {'true', 'false', 'null'}.contains(e)) return _formula(e);
    // A name is read as it is; anything the formula language spells otherwise (rows.length) is a formula.
    return _identifier.hasMatch(e) && _natural(e) == e ? '\${$e}' : _formula(e);
  }

  String _formula(String expr) => '\${= ${_natural(_textsRead(expr))}}';

  /// A quoted text inside a formula that reads a value (`["Serves", "{n}"]`)
  /// is its parts joined, as it is in a list that is not a formula. A
  /// `fill` template keeps its braces.
  String _textsRead(String expr) {
    if (!expr.contains('{') || expr.contains('fill(')) return expr;
    final out = StringBuffer();
    var i = 0;
    while (i < expr.length) {
      if (expr[i] != '"') {
        out.write(expr[i++]);
        continue;
      }
      // To the closing quote; a quote inside a {…} of the text is the formula's own.
      var j = i + 1, depth = 0;
      while (j < expr.length && (expr[j] != '"' || depth > 0)) {
        if (expr[j] == '{') depth++;
        if (expr[j] == '}' && depth > 0) depth--;
        if (expr[j] == r'\') j++;
        j++;
      }
      if (j >= expr.length) {
        out.write(expr.substring(i));
        break;
      }
      final text = expr.substring(i + 1, j);
      out.write(_spans(text).isEmpty ? expr.substring(i, j + 1) : _formulaSource(text));
      i = j + 1;
    }
    return out.toString();
  }

  static const _methods = {'filter', 'map', 'sum', 'count', 'find', 'any', 'all', 'sortBy', 'trim', 'upper', 'lower', 'contains', 'startsWith', 'join', 'reverse', 'first', 'last', 'slice', 'take', 'unique', 'indexOf'};

  /// An expression as models write one, as the formula language has it:
  /// `and`, `or`, `not`; a call on a value (`rows.filter(…)`, `n.toFixed(2)`,
  /// `name.trim()`, `rows.length`) as the function of that name. Text in
  /// quotes is left as it is.
  String _natural(String expr) {
    // Minutes and seconds from seconds, under the names models reach for.
    if (expr.contains('formatTime(') || expr.contains('formatSeconds(')) {
      expr = expr.replaceAll(RegExp(r'\bformat(Time|Seconds)\('), 'duration(');
    }
    if (!expr.contains(RegExp(r'\b(and|or|not)\b|\.[a-zA-Z]+\(|\.length\b'))) return expr;
    final out = StringBuffer();
    final parts = expr.split(RegExp(r'''(?=["'])|(?<=["'])'''));
    var quote = '';
    for (final part in parts) {
      if (part == '"' || part == "'") {
        if (quote.isEmpty) {
          quote = part;
        } else if (quote == part) {
          quote = '';
        }
        out.write(part);
        continue;
      }
      if (quote.isNotEmpty) {
        out.write(part);
        continue;
      }
      var code = part
          .replaceAllMapped(RegExp(r'\band\b'), (_) => '&&')
          .replaceAllMapped(RegExp(r'\bor\b'), (_) => '||')
          .replaceAllMapped(RegExp(r'\bnot\s+'), (_) => '!');
      code = code.replaceAllMapped(RegExp(r'([A-Za-z_][A-Za-z0-9_.\[\]]*?)\.length\b(?!\()'), (m) => 'length(${m[1]})');
      code = code.replaceAllMapped(RegExp(r'([A-Za-z_][A-Za-z0-9_.\[\]]*?)\.toFixed\((\d+)\)'), (m) => 'fixed(${m[1]},${m[2]})');
      code = code.replaceAllMapped(RegExp(r'([A-Za-z_][A-Za-z0-9_.\[\]]*?)\.([a-zA-Z]+)\((\)?)'), (m) {
        if (!_methods.contains(m[2])) return m[0]!;
        return m[3] == ')' ? '${m[2]}(${m[1]})' : '${m[2]}(${m[1]},';
      });
      code = code.replaceAllMapped(RegExp(r'([A-Za-z_][A-Za-z0-9_]*\([^()]*\))\.length\b'), (m) => 'length(${m[1]})');
      out.write(code);
    }
    return out.toString();
  }

  String _and(String? a, String b) {
    if (a == null) return b;
    String inner(String f) => f.startsWith(r'${= ') ? f.substring(4, f.length - 1) : f.substring(2, f.length - 1);
    return _formula('(${inner(a)}) && (${inner(b)})');
  }

  /// `{name}` in a string is a read: `${name}`.
  String _interpolate(String s) {
    s = s.replaceAll(r'\$', r'$');
    final out = StringBuffer();
    var at = 0;
    for (final (start, end) in _spans(s)) {
      out
        ..write(s.substring(at, start))
        ..write(_read(s.substring(start + 1, end - 1)));
      at = end;
    }
    out.write(s.substring(at));
    return out.toString();
  }

  /// The `{…}` of [s] that read a value, outermost only: a brace inside one
  /// (a map written in a formula, `{find([{"id": 1}], …).name}`) belongs to
  /// it. An empty or unclosed brace is text.
  static List<(int, int)> _spans(String s) {
    final out = <(int, int)>[];
    for (var i = 0; i < s.length; i++) {
      if (s[i] != '{') continue;
      var depth = 0, quoted = false, end = -1;
      for (var j = i; j < s.length; j++) {
        final c = s[j];
        if (c == '"' && s[j - 1] != r'\') quoted = !quoted;
        if (quoted) continue;
        if (c == '{') depth++;
        if (c == '}' && --depth == 0) {
          end = j + 1;
          break;
        }
      }
      if (end > i + 2) {
        // A brace of a code sample shown as text (`import { Beacon } from …`,
        // `track('x', {\n  plan: 'pro',\n})`) reads nothing: it runs over
        // lines, or is a record written key: value.
        final inner = s.substring(i + 1, end - 1);
        final code = inner.contains('\n') || inner.contains(r'\n') || RegExp(r"^\s*[A-Za-z_]\w*\s*:\s|^\s+[A-Za-z_]\w*\s+$").hasMatch(inner);
        if (!code) out.add((i, end));
        i = end - 1;
      }
    }
    return out;
  }

  (bool, Object?) _literal(String raw) {
    if (raw == 'true') return (true, true);
    if (raw == 'false') return (true, false);
    if (raw == 'null') return (true, null);
    final n = num.tryParse(raw);
    if (n != null) return (true, n);
    if (raw.startsWith('"') && raw.endsWith('"') && raw.length >= 2) {
      try {
        return (true, jsonDecode(raw));
      } catch (_) {}
    }
    if (raw.startsWith('[') || raw.startsWith('{')) {
      // Not plain JSON: a list holding expressions, read as a formula.
      try {
        return (true, jsonDecode(raw));
      } catch (_) {}
    }
    return (false, null);
  }

  Object? _value(String raw) {
    final l = _literal(raw);
    if (l.$1) return l.$2 is String ? _interpolate(l.$2! as String) : l.$2;
    return raw;
  }

  /// A size as the document writes it: a number is fixed; `fill` and `hug`
  /// are fits.
  Object? _size(Object? v) => switch (v) { 'fill' => {'fill': 0}, 'hug' => {'hug': 0}, _ => v };

  Object? _json(String s) {
    try {
      return jsonDecode(s);
    } catch (_) {
      _issue(1, 'Not valid JSON: $s');
      return null;
    }
  }

  /// Where a `{…}` tail starts in what is left ([t.rest].length when none).
  int _tail(_Tokens t) {
    final rest = t.rest;
    var quoted = false;
    for (var i = 0; i < rest.length; i++) {
      final c = rest[i];
      if (c == '"' && (i == 0 || rest[i - 1] != r'\')) quoted = !quoted;
      if (!quoted && c == '{' && i > 0 && rest[i - 1] == ' ' && _trailingJson(rest.substring(i))) return i;
    }
    return rest.length;
  }

  /// A gradient as models write it (a list of colors, or `{"colors": […],
  /// "begin": "topLeft", "end": "bottomRight"}`), as a linear fill.
  Json? _gradient(Object? v) {
    final colors = v is List ? v : v is Map ? v['colors'] : null;
    if (colors is! List || colors.length < 2 || colors.any((c) => c is! String)) return null;
    const places = {'topLeft', 'topCenter', 'topRight', 'centerLeft', 'center', 'centerRight', 'bottomLeft', 'bottomCenter', 'bottomRight'};
    final begin = v is Map && places.contains(v['begin']) ? v['begin'] : 'topLeft', end = v is Map && places.contains(v['end']) ? v['end'] : 'bottomRight';
    return {
      'type': 'linear',
      'begin': begin,
      'end': end,
      'stops': [
        for (var i = 0; i < colors.length; i++) {'position': i / (colors.length - 1), 'color': colors[i]},
      ],
    };
  }

  bool _trailingJson(String s) {
    if (!s.trimRight().endsWith('}')) return false;
    try {
      return jsonDecode(s) is Map;
    } catch (_) {
      return false;
    }
  }

  List<String> _split(String s, String sep) {
    final out = <String>[];
    var depth = 0, quoted = false, start = 0;
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '"' && (i == 0 || s[i - 1] != r'\')) quoted = !quoted;
      if (quoted) continue;
      if (c == '{' || c == '[' || c == '(') depth++;
      if (c == '}' || c == ']' || c == ')') depth--;
      if (c == sep && depth == 0) {
        out.add(s.substring(start, i));
        start = i + 1;
      }
    }
    out.add(s.substring(start));
    return out;
  }

  Json _copy(Json m) => (jsonDecode(jsonEncode(m)) as Map).cast<String, Object?>();

  Object? _copyValue(Object? v) => v == null ? null : jsonDecode(jsonEncode(v));

  /// A color written as a value, as the theme's name for it when the
  /// options read written colors so ([NotationOptions.palette]).
  Object? _named(Object? v, String kind) => v is String && v.startsWith('#') ? (options.colorName(v, kind) ?? v) : v;

  /// [formula] with each quoted color in it (`"#FF2563EB"`) read as the
  /// theme's color of that name, when it has one near it.
  String _namedIn(String formula, String kind) {
    if (options.palette.isEmpty) return formula;
    return formula.replaceAllMapped(RegExp(r'''(["'])(#[0-9A-Fa-f]{6}(?:[0-9A-Fa-f]{2})?)\1'''), (m) {
      final n = options.colorName(m[2]!, kind);
      if (n == null) return m[0]!;
      return const {'primary', 'onPrimary', 'surface', 'onSurface', 'error', 'success', 'warning'}.contains(n) ? 'theme.$n' : 'theme.colors.$n';
    });
  }

  void _merge(Json into, Json from) {
    for (final e in from.entries) {
      final a = into[e.key], b = e.value;
      if (a is Map && b is Map) {
        final m = a.cast<String, Object?>();
        _merge(m, b.cast<String, Object?>());
        into[e.key] = m;
      } else if (b == null) {
        // As a merge patch: null takes the key away (a default not wanted).
        into.remove(e.key);
      } else {
        into[e.key] = b;
      }
    }
  }
}

class _Tokens {
  _Tokens(this.s);
  final String s;
  int at = 0;

  bool get done => at >= s.length;
  String get peek => done ? '' : s[at];
  String get rest => done ? '' : s.substring(at);

  void skipSpace() {
    while (!done && s[at] == ' ') {
      at++;
    }
  }

  /// A quoted string at the cursor (JSON escapes).
  String string() {
    final start = at;
    at++;
    var braced = false;
    while (!done && !(s[at] == '"' && s[at - 1] != r'\')) {
      // {an expression} may hold quotes of its own ("{plan=="pro" ? "$9" : "$0"}").
      if (s[at] == '{') {
        final close = _closeOf(at);
        if (close > at) {
          braced = braced || s.substring(at, close).contains('"');
          at = close;
        }
      }
      at++;
    }
    at++;
    final raw = s.substring(start, at > s.length ? s.length : at);
    if (braced) {
      return raw.substring(1, raw.endsWith('"') && raw.length > 1 ? raw.length - 1 : raw.length).replaceAll(r'\"', '"').replaceAll(r'\\', r'\');
    }
    try {
      return jsonDecode(raw.endsWith('"') && raw.length > 1 ? raw : '$raw"') as String;
    } catch (_) {
      return raw.replaceAll('"', '');
    }
  }

  /// Where the `{` at [open] closes on this line (quotes inside it paired),
  /// or -1.
  int _closeOf(int open) {
    var depth = 0, quoted = false;
    for (var i = open; i < s.length; i++) {
      final c = s[i];
      if (c == '"' && s[i - 1] != r'\\') quoted = !quoted;
      if (quoted) continue;
      if (c == '{') depth++;
      if (c == '}' && --depth == 0) return quoted ? -1 : i;
    }
    return -1;
  }

  static final _opAhead = RegExp(r' +(&&|\|\||\?|:(?![=A-Za-z])|==|!=|>=|<=|[<>+*/%]|-(?!>)|(?:and|or)(?= ))');
  static final _opBehind = RegExp(r'(&&|\|\||\?|[^A-Za-z0-9_"\])]:|==|!=|>=|<=|[<>+*/%]|(?:^| )(?:and|or|not))$');

  /// Up to the next space (a `key:"quoted value"` stops before its quote).
  String word() {
    final start = at;
    while (!done && s[at] != ' ') {
      if (s[at] == '"' || ((s[at] == '[' || s[at] == '{') && at > start && s[at - 1] == ':')) break;
      at++;
    }
    return s.substring(start, at);
  }

  /// The rest of an expression: to the next space outside quotes and
  /// brackets (`to!=""&&len(subject)>0`).
  String expression({int opened = 0, bool quoted = false, bool single = false}) {
    final start = at;
    var depth = opened;
    while (!done) {
      final c = s[at];
      if (c == '"' && !single && (at == 0 || s[at - 1] != r'\')) quoted = !quoted;
      // 'Living Room' in an expression is one value, its space included
      // (an apostrophe inside a word, don't, is not a quote).
      if (c == "'" && !quoted && (single || at == start || !RegExp(r'[A-Za-z0-9]').hasMatch(s[at - 1]))) single = !single;
      if (!quoted && !single) {
        if (c == '(' || c == '[' || c == '{') depth++;
        if (c == ')' || c == ']' || c == '}') depth--;
        if (c == ' ' && depth <= 0) {
          // An operator on either side of the space carries on
          // (`a!="" && b!=""`, `open ? "Hide" : "Show"`).
          final ahead = _opAhead.matchAsPrefix(s, at);
          if (ahead != null) {
            at = ahead.end;
            continue;
          }
          if (at > start && (_opBehind.hasMatch(s.substring(start, at)) || s[at - 1] == ':' && s.substring(start, at).contains('?'))) {
            while (!done && s[at] == ' ') {
              at++;
            }
            continue;
          }
          break;
        }
      }
      at++;
    }
    return s.substring(start, at);
  }

  /// A bracketed value at the cursor, to its matching close.
  String balanced() {
    final start = at;
    var depth = 0, quoted = false;
    while (!done) {
      final c = s[at];
      if (c == '"' && s[at - 1] != r'\') quoted = !quoted;
      if (!quoted) {
        if (c == '[' || c == '{') depth++;
        if (c == ']' || c == '}') depth--;
      }
      at++;
      if (depth == 0) break;
    }
    return s.substring(start, at);
  }

  /// Up to the first of [stops] outside quotes (or the end).
  String until(List<String> stops) {
    final start = at;
    var quoted = false;
    while (!done) {
      if (s[at] == '"') quoted = !quoted;
      if (!quoted && stops.any((x) => s.startsWith(x, at))) break;
      at++;
    }
    return s.substring(start, at);
  }
}
