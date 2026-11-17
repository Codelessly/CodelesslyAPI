// The compact notation (docs/design/13-compact-notation.md): the form an
// agent writes for levels 0 to 2. One node per line, nesting by indentation:
//
//   Column gap=12
//     Slider bind=volume
//     Input "Email" bind=email
//     Toggle "Notifications" bind=notify
//     Button "Save" onTap={emit save}
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
import '../triggers.dart' show KeyCombo;
import 'page_words.dart';
import 'reflow.dart';
import 'vocabulary.dart';

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
  const NotationResult(this.document, this.issues, {this.wanted = const [], this.vocabulary = const []});

  /// The words the text used that the notation has no meaning for, and the
  /// aliases it used ([VocabularyUse]; docs/design/19-open-vocabulary.md).
  /// Unknown words are here only with [NotationOptions.openVocabulary]
  /// (without it each is an issue); aliases always.
  final List<VocabularyUse> vocabulary;

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
    this.openVocabulary = false,
    this.vocabulary = NotationVocabulary.core,
  });

  /// These options with an open vocabulary (or not), and with [vocabulary]
  /// as the alias table when given.
  NotationOptions open({bool openVocabulary = true, NotationVocabulary? vocabulary}) =>
      _copy(openVocabulary: openVocabulary, vocabulary: vocabulary ?? this.vocabulary);

  NotationOptions _copy({double? width, String? screen, bool? reflow, required bool openVocabulary, required NotationVocabulary vocabulary}) => NotationOptions(
        width: width ?? this.width,
        screen: screen ?? this.screen,
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
        reflow: reflow ?? this.reflow,
        displaySizes: displaySizes,
        projectVariables: projectVariables,
        accentText: accentText,
        openVocabulary: openVocabulary,
        vocabulary: vocabulary,
      );

  /// The looks of [designSystem] ([NotationOptions.fromTheme] over its
  /// tokens) and the sizes of its components, so a component called by name
  /// (`StatusBadge "Paid"`, `Stepper bind=qty`) is as big as its own design says:
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
        openVocabulary: openVocabulary,
        vocabulary: vocabulary,
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
  /// `h=fill`): the canvas's design height.
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

  /// Whether a word the notation does not have is recorded and stands in
  /// (a type as a column of its texts and children; a parameter, a flag, an
  /// event or an action verb left out of the document), not refused. The
  /// grammar is not open: a line that does not follow it is still an issue.
  final bool openVocabulary;

  /// The names read as a word the notation has (the alias table). It holds
  /// with or without [openVocabulary].
  final NotationVocabulary vocabulary;

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
  /// ([NotationOptions.fromTheme] with `named`): `fill=#FFF5F5F5` on a
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
  // A table of records: rows={list} and columns=[{"key":…,"label":…}], sorted
  // from its headers, a row chosen by a tap or by keys.
  'DataTable': (type: 'tableView', node: {}),
  // What a row of a reordered list is dragged by (each row in rows reorder).
  'Handle': (type: 'iconButton', node: {}),
  // A one-time code: one field drawn as boxes (CodeInput bind=code length=6 digits).
  'CodeInput': (type: 'textField', node: {}),
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
  'calendar': (prop: 'start', type: 'text', start: ''),
  // A table's chosen row, by its place in the rows shown (-1: none).
  'tableView': (prop: 'selectedRow', type: 'integer', start: -1),
  'splitter': (prop: 'value', type: 'decimal', start: 240),
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

/// What `bind=expr` binds on a type that shows a value but takes no input.
const Map<String, String> _shownValue = {'progressBar': 'value', 'circularProgressIndicator': 'value', 'radialGauge': 'value', 'text': 'text'};

/// The short names a design system's component of the same name replaces.
const _softNames = {'CodeInput', 'DataTable', 'Handle', 'Gauge', 'Dial', 'Ring', 'Sparkline', 'Avatar', 'Donut', 'DonutChart', 'PieChart', 'Pie', 'AreaChart'};

/// The core types a design system's component of the same name replaces: a
/// design system's own `Tabs` (a row of labels that keeps the open one in a
/// variable, `Tabs bind=tab tabs=["Overview","Activity"]`) is what the line
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

  /// The words outside the notation used so far, and the aliases ([NotationResult.vocabulary]).
  List<VocabularyUse> get vocabulary => List.unmodifiable(_parser.vocabulary);

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

/// A line as written: its indentation, its first word (null for an `if` or
/// an `each`) and, when the word stands in, its record.
class _Src {
  _Src(this.indent, this.word);
  final int indent;
  final String? word;
  VocabularyUse? use;
}

class _Open {
  _Open(this.indent, this.id, this.type, {this.condition, this.grid, this.each, this.list, this.pages, this.leaf = false, this.slots = const [], this.written});

  /// A design system's block that takes no children but has slots (a
  /// ListRow's trailing, a SectionHeader's actions): the lines under it go
  /// in the first, side by side.
  final List<String> slots;

  /// The type as the line wrote it (a block's name), for what is said.
  final String? written;

  /// The row a slot's lines go in, once the first of them is written.
  String? slotRow;

  /// A node that takes no lines under it (a Slider, a component without
  /// children): with an open vocabulary what is written under it goes to
  /// the node around it.
  final bool leaf;

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
        vocabulary = _host?.vocabulary ?? [],
        _useKeys = _host?._useKeys ?? {},
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

  /// Where each id was first given (its line, and the condition of the
  /// `if` it is under, if any), to say both lines when it is given again.
  final Map<String, ({int line, String? condition})> _idAt = {};

  /// The id [id] is given again on this line: what to say, naming the line
  /// that has it.
  String _twice(String id, String? condition) {
    final first = _top._idAt[id];
    if (first == null) return 'The id "$id" is used twice. Give this line an id of its own.';
    if (first.condition != null && condition != null && first.condition != condition) {
      return 'The id "$id" is used twice: line ${first.line} has it too, in the other branch of the if. A document holds one node per id, so both branches '
          'cannot have it: give this one an id of its own (${id}2), or write one line whose values are worked out (label={cond ? "a" : "b"}).';
    }
    return 'The id "$id" is used twice: line ${first.line} has it too. Give this line an id of its own.';
  }

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
  bool get _continues => _pending != null || _open != null;

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
      'layout': {'width': o?.width ?? options.width, 'height': o?.action.containsKey('snapHeights') == true ? {'fill': 0} : _canvasHeight},
      if (o?.guard case final String guard) 'bind': {'props.blockBack': _formula(guard)},
      'decoration': look(),
      if (_timers.isNotEmpty) 'actions': [..._timers],
    };
  }

  /// A top-level `Dialog#id`, `Sheet#id`, `Drawer#id`, `Menu#id`,
  /// `Popover#id` or `Lightbox#id` line: the lines under it are a canvas of
  /// their own, which `open <id>` shows over the page.
  void _openBlock(Overlay o) {
    if (_taken(o.id)) {
      _issue(
          1,
          o.id == options.screen
              ? 'The id "${o.id}" is this page\x27s own (its canvas): an overlay over the page needs an id of its own (${o.id}Overlay, opened with open ${o.id}Overlay). An overlay is opened from the page it is written on; one that other pages open is written on each of them, after the page.'
              : _twice(o.id, null));
      _blockSkipped = true;
      return;
    }
    _top._idAt.putIfAbsent(o.id, () => (line: _line, condition: null));
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
    for (final l in _blockFoot) {
      final t = l.trimLeft();
      _feed(l.length - t.length, t);
    }
    _blockFoot.clear();
    _blockIndent = 0;
    _quiet = true;
    for (final l in o.foot) {
      if (l.text == Overlay.lines) {
        // The lines written under it, read again here (without their ids;
        // a picture fills its thumbnail).
        final first = written.isEmpty ? 0 : written.map((w) => w.indent).reduce(math.min);
        for (final w in written) {
          _feed(l.indent - o.shift + w.indent - first, w.text.replaceFirstMapped(_idMark, (m) => m[1]!).replaceAll(' fit=contain', ' fit=cover'), closes: 'none');
        }
        continue;
      }
      _feed(l.indent - o.shift, l.text, closes: 'none');
    }
    _quiet = false;
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

  /// The words outside the notation, and the aliases, used so far
  /// ([NotationResult.vocabulary]); [_useKeys] keeps a line read twice (an
  /// overlay's, drawn again in its foot) from being recorded twice.
  final List<VocabularyUse> vocabulary;
  final Set<String> _useKeys;

  /// The line being read, as written (without its indentation) and its
  /// first word; the lines it is under, by their indentation.
  String _src = '';
  String? _srcWord;
  final _srcStack = <_Src>[];

  /// The words of the lines the one being read is under, outermost first.
  List<String> get _srcPath => [
        for (final e in _srcStack)
          if (e.word != null && !identical(e, _srcStack.last)) e.word!,
      ];

  void _track(int indent, String text) {
    while (_srcStack.isNotEmpty && _srcStack.last.indent >= indent) {
      _srcStack.removeLast();
    }
    final word = RegExp(r'^[A-Za-z][A-Za-z0-9]*').stringMatch(text);
    final plain = word == null || const {'if', 'each', 'else', 'for'}.contains(word);
    final above = _srcStack.reversed.where((e) => e.word != null).firstOrNull;
    if (!plain && above?.use != null && _useKeys.add('child:$_line:${above!.use!.line}:$word')) above.use!.children.add(word);
    _srcStack.add(_Src(indent, plain ? null : word));
    _src = text;
    _srcWord = plain ? null : word;
  }

  /// Records a use of a word outside the notation (once for a place).
  VocabularyUse? _use(
    String kind,
    String word,
    int column, {
    String? on,
    String? value,
    String? to,
    String? of,
    String? node,
    LineParts? parts,
  }) {
    if (_top._quiet) return null;
    if (!_useKeys.add('$_line:$column:$kind:$word')) return null;
    final VocabularyUse use;
    if (kind == 'alias') {
      use = aliasUse(of: of ?? 'type', word: word, to: to ?? '', source: _src, line: _line, column: column, on: on, value: value, path: _srcPath);
    } else {
      final all = parts?.parts ?? const <LinePart>[];
      use = VocabularyUse(
        kind: kind,
        word: word,
        source: _src,
        line: _line,
        column: column,
        on: on,
        value: value,
        node: node,
        path: _srcPath,
        texts: [
          for (final p in all)
            if (p.kind == 'string') p.raw.length > 1 ? p.raw.substring(1, p.raw.endsWith('"') ? p.raw.length - 1 : p.raw.length) : '',
        ],
        parameters: {
          for (final p in all)
            if (p.kind == 'pair' && !p.isEvent) p.key!: p.value!,
        },
        flags: [
          for (final p in all)
            if (p.kind == 'word') p.raw,
        ],
        events: {
          for (final p in all)
            if (p.isEvent) p.key!: p.value!,
        },
      );
    }
    vocabulary.add(use);
    return use;
  }

  /// Whether [word] is a type the notation, the catalog or the page words have.
  bool _knowsType(String word) =>
      notationTypes.containsKey(word) ||
      catalog.widget('${word[0].toLowerCase()}${word.substring(1)}') != null ||
      catalog.widget(word) != null ||
      PageWords.words.contains(word) ||
      RegExp(r'^H[1-4]$').hasMatch(word);

  /// The spec a line starting with [written] is read with (null: a page
  /// word, or none).
  WidgetSpec? _specOf(String written) {
    final short = _softNames.contains(written) && catalog.widget(written) != null ? null : notationTypes[written];
    final type = short?.type ?? '${written[0].toLowerCase()}${written.substring(1)}';
    final component = short == null && (catalog.widget(type) == null || notationComponentFirst.contains(written)) && catalog.widget(written) != null;
    return catalog.widget(component ? written : type);
  }

  /// [text] (one line, no indentation) with the aliases in it read as what
  /// they stand for ([NotationOptions.vocabulary]); each is recorded. A
  /// word the notation already has is never an alias. Several lines when
  /// the word is a line of another shape that takes more than one.
  List<String> _aliased(String text, int column) {
    final table = options.vocabulary;
    if (table.isEmpty) return [text];
    final parts = LineParts.of(text);
    if (parts == null) return [text];
    // `state draft="" persist`: a word after a state's value that is ours
    // under another name (saved).
    if (parts.word == 'state' || parts.word == 'project') {
      final last = RegExp(r'\s([A-Za-z][A-Za-z0-9]*)$').firstMatch(text);
      final to = last == null ? null : table.flags[parts.word]?[last[1]];
      if (to == null || !text.contains('=')) return [text];
      _use('alias', last![1]!, column + last.start + 1, of: 'flag', to: to, on: parts.word);
      return ['${text.substring(0, last.start)} $to'];
    }
    const statements = {'if', 'each', 'else', 'for', 'node', 'document', 'every', 'key', 'let', 'derived', 'const', 'var'};
    if (statements.contains(parts.word)) return [text];
    final written = parts.word;
    var changed = false;
    if (!_knowsType(written)) {
      final alias = table.types[written];
      if (alias == null) return [text];
      if (alias.line != null) {
        final lines = lineRewrites[alias.line]?.call(parts, text);
        if (lines == null || lines.isEmpty) return [text];
        _use('alias', written, column, of: 'line', to: lines.first);
        return lines;
      }
      if (alias.to == null || !_knowsType(alias.to!)) return [text];
      if (alias.requires.any((k) => !parts.parts.any((p) => p.kind == 'pair' && (alias.parameters[p.key] ?? p.key) == k))) return [text];
      parts.word = alias.to!;
      changed = true;
      _use('alias', written, column, of: 'type', to: alias.to);
      if (alias.add != null) {
        final tail = parts.parts.indexWhere((p) => p.kind == 'tail');
        parts.parts.insert(tail < 0 ? parts.parts.length : tail, LinePart.word(alias.add!));
      }
    } else if (written[0] != written[0].toUpperCase()) {
      return [text];
    }
    final type = parts.word;
    final own = changed ? table.types[written]!.parameters : const <String, String>{};
    final spec = _specOf(type);
    bool known(String key) => spec != null && (spec.props.any((p) => p.key == key) || spec.events.any((e) => e.key == key));
    String? of(Map<String, Map<String, String>> names, String key) {
      final own = names[type], all = names['*'];
      return (own == null ? null : own[key]) ?? (all == null ? null : all[key]);
    }
    for (var i = 0; i < parts.parts.length; i++) {
      final p = parts.parts[i];
      final col = column + (p.at < 0 ? 0 : p.at);
      if (p.kind == 'pair') {
        final key = p.key!;
        final to = own[key] ?? (known(key) ? null : of(p.isEvent ? table.events : table.parameters, key));
        if (to == null || to == key) continue;
        _use('alias', key, col, of: p.isEvent ? 'event' : 'parameter', to: to, on: type, value: p.value);
        changed = true;
        if (to == r'$text') {
          final at = parts.parts.lastIndexWhere((x) => x.kind == 'string');
          parts.parts.removeAt(i);
          parts.parts.insert(at < 0 ? 0 : (at < i ? at + 1 : at), LinePart.string(asLineString(p.value!)));
        } else if (to.startsWith('!')) {
          parts.parts[i] = LinePart.pair(to.substring(1), negatedValue(p.value!));
        } else {
          parts.parts[i] = LinePart.pair(to, p.value!);
        }
      } else if (p.kind == 'word') {
        final to = own[p.raw] ?? (known(p.raw) ? null : of(table.flags, p.raw));
        if (to == null || to == p.raw) continue;
        _use('alias', p.raw, col, of: 'flag', to: to, on: type);
        changed = true;
        parts.parts[i] = LinePart.word(to);
      }
    }
    return [changed ? parts.toString() : text];
  }

  /// The line each `open` and `scroll` action was written on.
  final _actionLines = Map<Json, int>.identity();

  /// The lines an alias adds after an overlay's own (a ConfirmDialog's buttons).
  final _blockFoot = <String>[];

  /// How far in the head of the overlay being read is written (0: at the
  /// margin): its lines are the ones further in.
  int _blockIndent = 0;

  /// The overlay being read (`Menu#albumMenu`) and the indent of its last
  /// line, to say where a line indented past it went.
  String _blockHead = '';
  int _blockPrev = 0;

  /// While lines already read are read again (an overlay's, drawn again in
  /// its foot; a sidebar's, in its drawer): nothing is recorded twice.
  bool _quiet = false;

  /// Whether [text] (indented, with an id) is the head of an overlay: a
  /// word the page layer reads as one, itself or through an alias.
  bool _overlayInside(String text) {
    final word = RegExp(r'^[A-Za-z][A-Za-z0-9]*').stringMatch(text)!;
    const overlays = {'Dialog', 'Modal', 'Sheet', 'BottomSheet', 'Drawer', 'Menu', 'Popover', 'Popup', 'Lightbox'};
    // A design system's own Dialog called in a line is its component,
    // unless an `open` already names its id: then it is what that shows.
    if (overlays.contains(word)) {
      final id = RegExp(r'#([A-Za-z_][A-Za-z0-9_]*)').firstMatch(text)?[1];
      final ours = catalog.widget(word) == null && catalog.widget('${word[0].toLowerCase()}${word.substring(1)}') == null;
      return ours || _opens.any((a) => a['to'] == id) || _openedIds.contains(id);
    }
    if (_knowsType(word)) return false;
    final alias = options.vocabulary.types[word];
    if (alias == null) return false;
    if (alias.to != null) return overlays.contains(alias.to);
    final parts = LineParts.of(text);
    final lines = parts == null ? null : lineRewrites[alias.line]?.call(parts, text);
    return lines != null && lines.isNotEmpty && overlays.contains(RegExp(r'^[A-Za-z][A-Za-z0-9]*').stringMatch(lines.first));
  }

  /// The edit operations of the lines read so far, not yet taken ([take]).
  final ops = <Json>[];
  final Set<String> _declared;
  final Map<String, int> _counts;
  final _stack = <_Open>[];
  String? _root;
  int _line = 0;

  /// Reads one line (without its newline).
  void line(String raw) {
    // The lines under an overlay's head are its canvas's; the next line at
    // the margin ends it.
    if (_host == null && !_continues) {
      final indent = raw.length - raw.trimLeft().length;
      final blank = raw.trim().isEmpty || raw.trimLeft().startsWith('//');
      if ((_block != null || _blockSkipped) && (indent > _blockIndent || blank || (_block?._continues ?? false))) {
        _line++;
        if (!blank || (_block?._continues ?? false)) {
          // A line indented two levels past the one before it, in an
          // overlay, was most likely meant for the page above (a Card for
          // Main, written after the overlays): it goes in the overlay, and
          // where it went is said.
          if (_block != null && !blank && !(_block?._continues ?? false)) {
            final rel = indent - _blockIndent;
            if (rel > _blockPrev + 2 && _blockPrev > 0) {
              _issue(rel + _blockIndent + 1,
                  'This line is indented $rel inside $_blockHead, two levels past the line before it ($_blockPrev), so it went into $_blockHead, under that line. A line meant for the page is written before the overlays, at its place in the page.');
            }
            _blockPrev = rel;
          }
          if (_block != null && !blank) _blockLines.add((indent: indent - _blockIndent, text: raw.trim()));
          _feed(indent - _blockIndent, raw.trim());
        }
        return;
      }
      // An overlay written inside the page (a Dialog#id indented under a
      // pane): it is still over the page, its lines the ones indented under
      // it, and the page goes on after them.
      if (!blank && (_block != null || _blockSkipped)) _closeBlock();
      final inside = !blank && indent > 0 && _root != null && RegExp(r'^[A-Za-z][A-Za-z0-9]*#[A-Za-z_]').hasMatch(raw.trimLeft()) && _overlayInside(raw.trim());
      if (!blank && (indent == 0 || inside)) {
        _closeBlock();
        _line++;
        final above = [..._srcStack];
        _track(indent, raw.trim());
        var head = raw.trim();
        final lines = _aliased(head, indent + 1);
        // An unknown word at the margin with an id, after the page: what is
        // written there is over the page, so it stands in as a dialog.
        VocabularyUse? standIn;
        if (options.openVocabulary && _root != null && lines.length == 1 && lines.first == head) {
          final parts = LineParts.of(head);
          if (parts != null && parts.id.isNotEmpty && parts.word[0] == parts.word[0].toUpperCase() && !_knowsType(parts.word)) {
            standIn = _use('type', parts.word, 1, node: parts.id.substring(1), parts: parts);
            _srcStack.last.use = standIn;
            head = ['Dialog${parts.id}', ...parts.strings.take(2).map((s) => s.raw)].join(' ');
          }
        }
        if (standIn == null) head = lines.first;
        if (_pages.overlay(head) case final Overlay o) {
          final word = _srcWord;
          _openBlock(o);
          _blockIndent = indent;
          _blockHead = head.split(RegExp(r'\s')).first;
          _blockPrev = 0;
          _block?._srcStack.add(_Src(-1000, word)..use = standIn);
          if (_block != null) _blockFoot.addAll(lines.skip(1));
          // The page's own lines go on after it, under what they were under.
          if (inside) {
            _srcStack
              ..clear()
              ..addAll(above);
          }
          return;
        }
        _srcStack.removeLast();
        _line--;
      }
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
    // next lines (items=[ and one element a line), joined as one.
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
    _track(indent, raw.trim());
    // A name read as a word the notation has (the alias table). A word that
    // is several lines is one only at the margin (an overlay's head, above).
    if (_aliased(raw.trim(), indent + 1) case [final String one] when one != raw.trim()) {
      raw = '${' ' * indent}$one';
    }
    // `Dots bind=page count=n`: a dot per page, the current one long and in the
    // accent; a tap on a dot goes to its page. Written out as the three
    // lines it stands for.
    // An answer that opens with `if` or `each` has several top-level parts
    // and no root to hold them: they stack in a column of their own.
    if (_root == null && indent == 0 && RegExp(r'^(if|each)\s').hasMatch(raw.trim())) {
      _lineAt(-1, 'Column gap=12', 0);
    }
    final dots = _dotsLine.firstMatch(raw.trim());
    if (dots != null) {
      String look(String c) => c.startsWith('#')
          ? '"$c"'
          : const {'primary', 'onPrimary', 'surface', 'onSurface', 'error', 'success', 'warning'}.contains(c)
              ? 'theme.$c'
              : 'theme.colors.$c';
      final page = dots[2]!, count = dots[3]!.startsWith('{') ? dots[3]!.substring(1, dots[3]!.length - 1).trim() : dots[3]!;
      variables.putIfAbsent(page, () => {'name': page, 'type': 'decimal', 'value': 0});
      _lineAt(indent, 'Row${dots[1] ?? ''} gap=6 center middle h=16${dots[4] ?? ''}', indent + 1);
      _lineAt(indent + 2, 'each dot in range($count)', indent + 3);
      _lineAt(indent + 4, 'Box w={index==$page?16:6} h=6 radius=3 fill={index==$page?${look(options.accent)}:${look(options.track)}} onTap={$page=index}', indent + 5);
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
    // Named so that no id an author writes (`Menu#albumMenu` on the album
    // page) is the drawer's.
    sidebarMenu: _host == null && options.reflow && options.width >= 700 ? '${options.screen}_sidebar' : null,
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

  /// The Grids written `keep`, and the list each `each` under a Grid became
  /// (its id → the grid's).
  final _keepColumns = <String>{};
  final _gridLists = <String, String>{};

  /// The anchors (`id=why` on a line) by name → the node, and the scroll
  /// actions written, which name an anchor or an id.
  final _anchors = <String, String>{};
  final _scrolls = <Json>[];

  /// The names written `project name`: variables of the site, not of this screen.
  final Set<String> _projectVariables;
  final _tableRows = <String>{};

  /// On a page, the media rules that lay it out on a tablet and a phone.
  /// The foot of an app's window (`Footer` in Main or App): Main stops
  /// scrolling as a whole; what else is in it scrolls in a column that takes
  /// the room above the foot, which stays in view at the bottom at every
  /// width. A foot written in App goes to the foot of its Main.
  void _feet() {
    for (final foot in [
      for (final e in _roles.entries)
        if (e.value == 'foot') e.key,
    ]) {
      var main = _parentOf[foot];
      if (main == null || nodes[foot] == null) continue;
      if (_roles[main] == 'app') {
        final app = main;
        final into = ((nodes[app]!['children'] as List?) ?? const []).whereType<String>().where((k) => _roles[k] == 'main').firstOrNull;
        if (into == null) continue;
        (nodes[app]!['children'] as List).remove(foot);
        ((nodes[into]!['children'] as List<Object?>?) ?? (nodes[into]!['children'] = <Object?>[])).add(foot);
        _parentOf[foot] = into;
        main = into;
      }
      if (_roles[main] != 'main' && _roles[main] != 'pane') continue;
      final m = nodes[main]!;
      final props = (m['props'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
      if (props['scrollable'] != true) continue;
      final kids = ((m['children'] as List?) ?? const []).whereType<String>().toList();
      final rest = [for (final k in kids) if (k != foot) k];
      final scroll = '${main}Scroll';
      nodes[scroll] = {
        'type': 'column',
        'layout': {'width': {'fill': 0}, 'height': {'fill': 0}, 'flex': 1},
        'props': {...props},
        'children': rest,
      };
      for (final k in rest) {
        _parentOf[k] = scroll;
      }
      _parentOf[scroll] = main;
      props.remove('scrollable');
      props['crossAxisAlignment'] = 'stretch';
      m['props'] = props;
      m['children'] = [scroll, foot];
      if (_canvas) {
        ops
          ..add({'op': 'set', 'id': scroll, 'parent': main, 'index': 0, 'node': {...nodes[scroll]!}..remove('children')})
          ..addAll([for (var i = 0; i < rest.length; i++) {'op': 'move', 'id': rest[i], 'parent': scroll, 'index': i}])
          ..add({'op': 'move', 'id': foot, 'parent': main, 'index': 1})
          ..add({'op': 'patch', 'id': main, 'patch': {'props': {'scrollable': null, 'crossAxisAlignment': 'stretch'}}});
      }
    }
  }

  void _reflow() {
    if (!options.reflow || options.width < 700) return;
    final rules = PageReflow(
      nodes: nodes,
      roles: _roles,
      gridRows: {
        for (final e in _gridRows.entries) e.key: (cols: e.value.cols, gap: e.value.gap),
      },
      // A Grid written `keep`: its rows (lines under it) and its list (an each).
      keepColumns: {
        for (final e in _gridRows.entries)
          if (_keepColumns.contains(e.value.id)) e.key,
        for (final e in _gridLists.entries)
          if (_keepColumns.contains(e.value)) e.key,
      },
      cards: _cards,
      tableRows: _tableRows,
      displaySizes: options.displaySizes,
      isComponent: (type) => type.isNotEmpty && type[0].toUpperCase() == type[0] && catalog.widget(type) != null,
      fillsItsPlace: (type) => switch (options.components[type]?.width) { final Map m => m.containsKey('fill'), _ => false },
    ).run();
    for (final e in rules.entries) {
      final node = nodes[e.key]!;
      // The line's own rules (hide=phone) come after, so they win.
      final media = [...e.value, ...?(node['media'] as List?)];
      node['media'] = media;
      if (_canvas) ops.add({'op': 'patch', 'id': e.key, 'patch': {'media': media}});
    }
  }

  /// Whether the UI is as tall as its window (an app's panes, a root
  /// written `h=fill`): the canvas then has the window's height, where a
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
        if (!_projectVariables.contains(v['name']) && _declared.add(v['name']! as String)) v['name']! as String: {'type': v['type'], 'value': v['value'], if (v['persist'] == true) 'persist': true},
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

  /// The ids the whole text opens (`open edit`), known before its lines are
  /// read when it is read at once: a design system's Dialog#edit written
  /// inside the page is then what that open shows.
  final _openedIds = <String>{};

  NotationResult parse(String text) {
    _openedIds.addAll(RegExp(r'\bopen\s+([A-Za-z_][A-Za-z0-9_]*)').allMatches(text).map((m) => m[1]!));
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
    }), issues, wanted: List.unmodifiable(wanted), vocabulary: List.unmodifiable(vocabulary));
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
      final name = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*(=|$)').firstMatch(rest)?.group(1);
      if (name == null) return _issue(column, 'A site\x27s variable is written: project name=value (the same name as in site.json\x27s variables).');
      // Expanded with the site's variables, a name they lack is said; alone,
      // the page declares it itself, so that what reads it works.
      if (options.projectVariables.containsKey(name)) {
        _projectVariables.add(name);
      } else if (options.projectVariables.isNotEmpty) {
        _issue(column, 'project $name: site.json\x27s variables have no "$name": add it there ({"name": "$name", "type": …, "value": …}). Until then it is this page\x27s own.');
      }
      _state(rest.contains('=') ? rest : '$name=""', column + 8);
      // `project cart=[] saved`: kept on the device. The site's manifest is
      // where a site's variable is declared, so it has to say so too.
      if (rest.endsWith(' saved') && options.projectVariables[name] != null) {
        final declared = options.projectVariables[name]!;
        if (declared['persist'] != true) {
          _issue(column, 'project $name saved: site.json\x27s variable "$name" has to say "persist": true for it to be kept.');
        } else if (variables[name] != null && declared['type'] != variables[name]!['type']) {
          _issue(column, 'project $name saved: site.json declares "$name" as ${declared['type']}, this line as ${variables[name]!['type']}.');
        }
      }
      return;
    }
    if (line.startsWith('state ')) return _state(line.substring(6).trim(), column + 6);
    // `every 1000 onTick={elapsed=elapsed+1}`, `every 1s when running
    // onTick={…}`: what the screen does as time passes (a timer on the canvas).
    final every = RegExp(r'^every\s+(\d+(?:\.\d+)?)(ms|s)?(?:\s+when\s+(.+?))?\s+onTick=\{(.+)\}\s*$').firstMatch(line);
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
    // `key mod+k onPress={open search}`: a shortcut of the whole screen (a
    // keyDown reaction on the canvas). mod is Ctrl, or ⌘ on a Mac; a
    // combination with it or with alt runs while a field is typed in too.
    final shortcut = RegExp(r'^key\s+"?([^"\s]+)"?(?:\s+when\s+(.+?))?\s+onPress=\{(.+)\}\s*$').firstMatch(line);
    if (shortcut != null && KeyCombo.tryParse(shortcut[1]) != null && !shortcut[1]!.endsWith('+')) {
      _timers.add({
        'trigger': {'type': 'keyDown', 'key': shortcut[1], if (shortcut[2] != null) 'when': _formula(shortcut[2]!.trim())},
        'actions': _actions(shortcut[3]!.trim(), column),
      });
      if (_canvas) _patches.add({'op': 'patch', 'id': options.screen, 'patch': {'actions': [..._timers]}});
      return;
    }
    if (RegExp(r'^key[\s:]').hasMatch(line)) {
      return _issue(column, 'A shortcut is a line of its own: key mod+k onPress={open search} (mod, alt, shift and a key, joined by +).');
    }
    if (line.startsWith('every ')) {
      return _issue(column, 'An "every" line is: every 1000 onTick={name=value} (milliseconds, or 1s), optionally "every 1s when running onTick={…}".');
    }
    // `document {…}`: a merge patch over the whole document, for what is
    // not a node of the tree (the printer's last line).
    if (indent == 0 && line.startsWith('document {')) {
      final j = _json(line.substring(9));
      if (j is Map) _documentPatch = mergePatch(_documentPatch ?? const {}, j.cast<String, Object?>(), keepNulls: true);
      return;
    }
    for (final d in _derived.entries) {
      if (!line.contains(d.key)) continue;
      // A worked-out value follows the state by itself: an action that sets
      // it too (`onTap={votes=…; total=total+1}`) is dropped, not rewritten.
      line = _withoutSets(line, d.key);
      if (!line.contains(d.key)) continue;
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
    var parent = _stack.isEmpty ? null : _stack.last;
    // Lines under a block that takes none but has a slot (a ListRow's
    // trailing, a SectionHeader's or an EmptyState's actions): they go in
    // the slot, side by side in a row of their own.
    if (parent != null && parent.slots.isNotEmpty && nodes[parent.id] != null) {
      final block = parent;
      final slot = const ['trailing', 'actions', 'action', 'end'].firstWhere(block.slots.contains, orElse: () => block.slots.first);
      final row = block.slotRow ??= () {
        final id = '${block.id}${slot[0].toUpperCase()}${slot.substring(1)}';
        nodes[id] = {
          'type': 'row',
          'layout': {'width': {'hug': 0}, 'height': {'hug': 0}},
          'props': {'spacing': 8, 'crossAxisAlignment': 'center'},
          'children': <Object?>[],
        };
        ((nodes[block.id]!['slots'] as Json?) ?? (nodes[block.id]!['slots'] = <String, Object?>{}))[slot] = id;
        _parentOf[id] = block.id;
        _slotOf[id] = slot;
        return id;
      }();
      parent = _Open(block.indent, row, 'row', condition: block.condition);
    } else if (!options.openVocabulary && parent != null && parent.leaf && parent.written != null && catalog.widget(parent.written!) != null && nodes[parent.id] != null) {
      // A block that takes nothing under it: said, and the line is drawn
      // after it, where it would otherwise be lost.
      _issue(column, 'A ${parent.written} takes no lines under it (it has no children and no slot): write this line after it, at its own indent.');
      parent = _stack.reversed.where((o) => !o.leaf).firstOrNull;
    }
    if (options.openVocabulary && parent != null && parent.leaf) {
      // Lines under a word that takes none: recorded, and drawn after it.
      _use('children', _srcPath.lastOrNull ?? parent.type, column, value: _srcWord);
      parent = _stack.reversed.where((o) => !o.leaf).firstOrNull;
    }
    // `SwipeAction "Book" side=end when={!row.full} onTap={…}` under an
    // each: an action behind the swiped row. It is written beside the row
    // and kept by the row's list (its swipeActions, and a swipeAction
    // reaction whose result has the row: result.item, result.index).
    if (RegExp(r'^SwipeAction(\s|$)').hasMatch(line) && catalog.widget('SwipeAction') == null) {
      const usage = 'A swipe action is written: SwipeAction "Book" side=end when={!row.full} onTap={picked=result.item.name} (side=start or end, id=name, icon="…", removes).';
      final each = _stack.reversed.where((o) => o.each != null).firstOrNull;
      final listId = each == null ? null : _parentOf[each.id];
      final list = listId == null ? null : nodes[listId];
      if (list == null || list['type'] != 'listView' || (list['props'] as Map?)?['scrollDirection'] == 'horizontal') {
        return _issue(column, 'A SwipeAction goes under an each that runs down a Column: the rows of that list are swiped.');
      }
      final t = _Tokens(line)..at = 'SwipeAction'.length;
      t.skipSpace();
      if (t.peek != '"') return _issue(column, usage);
      final label = _interpolate(t.string());
      final words = <String, String>{};
      String? body;
      while (true) {
        t.skipSpace();
        if (t.done) break;
        final word = t.word();
        final eq = word.indexOf('=');
        if (word.isEmpty || (eq < 0 && word != 'removes')) return _issue(column + t.at, usage);
        final key = eq < 0 ? word : word.substring(0, eq);
        var value = eq < 0 ? 'true' : word.substring(eq + 1);
        if (value.isEmpty && t.peek == '"') value = t.string();
        if (value.isEmpty && t.peek == '{') {
          final braced = t.balanced();
          value = '{${braced.substring(1, braced.endsWith('}') ? braced.length - 1 : braced.length).trim()}}';
        }
        if (key == 'onTap' || key == 'onSwipe') {
          if (!value.startsWith('{')) return _issue(column, usage);
          body = value.substring(1, value.length - 1);
        } else if (const {'id', 'side', 'when', 'icon', 'removes'}.contains(key)) {
          words[key] = value;
        } else {
          return _issue(column, usage);
        }
      }
      final side = words['side'] ?? 'end';
      final id = words['id'] ?? label.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
      if ((side != 'start' && side != 'end') || !_identifier.hasMatch(id)) return _issue(column, usage);
      final when = words['when'];
      if (when != null && !when.startsWith('{')) return _issue(column, 'A condition is worked out, so it is in braces: when={!row.full}.');
      final removes = words['removes'] == 'true';
      final props = (list['props'] as Map).cast<String, Object?>();
      final swipes = (props['swipeActions'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
      final key = side == 'start' ? 'startActions' : 'endActions';
      swipes[key] = [
        ...?(swipes[key] as List?),
        <String, Object?>{
          'id': id,
          'label': label,
          if (words['icon'] case final String icon) 'icon': icon,
          'removes': removes,
          'background': options.accent,
          'foreground': '#FFFFFFFF',
          if (when != null) 'when': _formula(when.substring(1, when.length - 1)),
        },
      ];
      // An action that removes its row takes it out of the list's variable.
      if (removes) swipes['apply'] = 'variable';
      props['swipeActions'] = swipes;
      list['props'] = props;
      if (body != null) {
        final reactions = (list['actions'] as List?) ?? <Object?>[];
        reactions.add({
          'trigger': {'type': 'swipeAction', 'when': _formula('result.action=="$id"')},
          'actions': _actions(body, column),
        });
        list['actions'] = reactions;
      }
      _patches.add({
        'op': 'patch',
        'id': listId,
        'patch': {
          'props': {'swipeActions': swipes},
          if (list['actions'] != null) 'actions': list['actions'],
        },
      });
      return;
    }
    // A handler is a key of its node, on the node's line.
    if (RegExp(r'^on[A-Z][A-Za-z]*\s*[:=]').hasMatch(line)) {
      return _issue(column, 'A handler is written on the line of its node, its actions in braces: Button "Save" onTap={saved=true}.');
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
    // `each rows` is `each row in rows`: the element is read as `row` (or
    // `item`).
    final bare = RegExp(r'^each\s+(\S+)$').firstMatch(line);
    if (bare != null) line = 'each row in ${bare[1]}';
    // `each a in list stagger=80`: the row under it arrives that much after
    // the one before (its own animate=, or a fade up).
    // …and the other words an each takes after its list, in any order:
    // `follow h=180` (a log or a chat: as tall as h, open at its end and
    // following what is added there until the reader scrolls away).
    final eachWords = <String, String>{};
    if (line.startsWith('each ')) {
      line = line.trimRight();
      final trailing = RegExp(r'\s(stagger=\S+|h=\d+(?:\.\d+)?|follow|reorder(?:=[A-Za-z_][A-Za-z0-9_]*)?)$');
      for (var m = trailing.firstMatch(line); m != null; m = trailing.firstMatch(line)) {
        final word = m[1]!, eq = word.indexOf('=');
        eachWords[eq < 0 ? word : word.substring(0, eq)] = eq < 0 ? '' : word.substring(eq + 1);
        line = line.substring(0, m.start).trimRight();
      }
      if (eachWords['stagger'] case final String s) _eachStagger = _milliseconds(s);
    }
    // `reorder`: the rows are dragged by their Handle (or moved by keys from
    // it) and the new order is written to the list's variable; lists that
    // say the same `reorder=group` also pass rows to each other.
    final reorders = eachWords.containsKey('reorder');
    final reorderGroup = eachWords['reorder'] ?? '';
    final follows = eachWords.containsKey('follow');
    final eachHeight = num.tryParse(eachWords['h'] ?? '');
    if (follows != (eachHeight != null)) {
      return _issue(column, 'A list that follows its end has a height to scroll in: each line in lines follow h=180.');
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
      if (follows && (g != null || across)) return _issue(column, 'A list that follows its end runs down a Column, a Card or a Section, not across a Row or in a Grid.');
      final listName = each[2]!.trim();
      if (reorders && (g != null || across)) return _issue(column, 'A list that is reordered runs down a Column, a Card or a Section, not across a Row or in a Grid.');
      if (reorders && !(_identifier.hasMatch(listName) && !listName.contains('.') && variables.containsKey(listName))) {
        return _issue(column, 'reorder writes the new order to a list variable: declare it (state $listName=[…]) and repeat it by name (each row in $listName reorder).');
      }
      _acrossLists[itemId] = listId;
      if (g != null) _gridLists[listId] = g.id;
      nodes[listId] = {
        'type': g != null ? 'gridView' : 'listView',
        'layout': {'width': across ? {'hug': 0} : {'fill': 0}, 'height': follows ? eachHeight : {'hug': 0}},
        // Its handles are one stop of the page: arrows go from row to row.
        if (reorders) 'focusGroup': {'axis': 'vertical', 'wrap': false},
        // Under a Grid, the repeated lines are its cells.
        'props': g != null
            ? {'crossAxisCount': g.cols, 'mainAxisSpacing': g.gap, 'crossAxisSpacing': g.gap, 'shrinkWrapRows': true, 'physics': 'never'}
            : across
                ? {'scrollable': false, 'scrollDirection': 'horizontal', 'spacing': (nodes[parent.id]?['props'] as Map?)?['spacing'] ?? 0}
                : {
                    'scrollable': follows,
                    if (follows) 'stickToEnd': true,
                    'spacing': (nodes[parent.id]?['props'] as Map?)?['spacing'] ?? 0,
                    if (reorders)
                      'reorder': {
                        'start': 'handle',
                        'keyboard': true,
                        'apply': 'variable',
                        if (reorderGroup.isNotEmpty) ...{'group': reorderGroup, 'listKey': listName},
                      },
                  },
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
    // An id written from the data (`Row#row-{row.id}`, `Input#quick-{col.id}`):
    // a node has one id however many copies an each makes of it (each copy
    // is told apart by its element), so the id is the fixed part.
    line = line.replaceFirstMapped(RegExp(r'^([A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)?)#([A-Za-z_][A-Za-z0-9_]*)?[-_]*\{[^{}]*\}[A-Za-z0-9_{}.-]*(?=\s|$)'), (m) {
      final fixed = m[2];
      return fixed == null || _taken(fixed) ? m[1]! : '${m[1]}#$fixed';
    });
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
    // `Text "{row.title}" mark={q}`: the text as written, and what to mark in it.
    String? markText, markQuery;
    num? sliderStep;
    // `Slider bind=low bindEnd=high`: the variable of its second thumb (and
    // of the last day of a Calendar's range).
    String? sliderEnd;
    int sliderEndColumn = 0;
    String? textLine;
    num? avatarSize;
    String? imageFit;
    Json? buttonLook;
    String? gaugeUnit;
    List<({String label, Object? value, Object? color})>? donutKeys;

    // With an open vocabulary a word that is not a type stands in: a column
    // of its texts and of the lines under it, recorded with what it was
    // given. A sentence around the UI is not a word.
    final open = options.openVocabulary;
    final standIn = open &&
        catalog.widget(type) == null &&
        written[0] == written[0].toUpperCase() &&
        ((_root != null && indent > 0) || _nodeLike(line));
    if (written == 'Button' && variant != null) {
      final v = buttonVariants[variant];
      if (v == null && open) {
        _use('variant', 'Button.$variant', column + written.length + 1, on: written);
      } else if (v == null) {
        _issue(column + written.length + 1, 'No Button.$variant. Variants: ${buttonVariants.keys.join(', ')}.');
      } else {
        type = v.type;
        props.addAll(_copy(v.props));
      }
    } else if (type == 'text' && variant != null) {
      final style = options.textStyles[variant];
      if (style == null && open) {
        _use('variant', 'Text.$variant', column + written.length + 1, on: written);
      } else if (style == null) {
        _issue(column + written.length + 1, 'No Text.$variant. Variants: ${options.textStyles.keys.join(', ')}.');
      } else {
        props['style'] = style is Map ? _copy(style.cast<String, Object?>()) : style;
      }
    } else if (written == 'Badge') {
      // SSUI's badge: a tinted pill-cornered row 20 high around its text.
      final v = options.badges[variant ?? 'neutral'];
      if (v == null && open) {
        _use('variant', 'Badge.$variant', column + written.length + 1, on: written);
      } else if (v == null) {
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
    } else if (variant != null && open) {
      // A stand-in's variant is part of its own record (its line).
      if (!standIn) _use('variant', '$written.$variant', column + written.length + 1, on: written);
    } else if (variant != null) {
      _issue(column + written.length + 1, 'A $written has no variants: write $written, with props as key=value.');
    }
    if (standIn) type = 'column';
    final found = catalog.widget(type);
    if (found == null) {
      // A sentence before the UI ("Here is the card=") is not a node.
      // Nor is one after it ("Two limits remain: …").
      if ((_root == null || indent == 0) && line.contains(' ')) return;
      _issue(column, 'No node type "$written". Write a type of the catalog (Column, Row, Text, Button, Input, Toggle, Slider…).');
      return;
    }
    final spec = found;
    // The keys of this line that are not the type's, each with its value as
    // written: left out of the document once the line is read, and recorded.
    final unknownKeys = <({String key, String value, int column})>[];
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
    final under = _stack.reversed.where((o) => o.condition != null).firstOrNull?.condition;
    if (_taken(id)) {
      _issue(column, _twice(id, under));
      return;
    }
    if (head[3] != null) _top._idAt.putIfAbsent(id, () => (line: _line, condition: under));
    _lastNode = id;
    if (standIn) {
      final use = _use('type', written, column, node: id, parts: LineParts.of(_src.startsWith(written) ? _src : line));
      if (_srcStack.isNotEmpty && _srcWord == written) _srcStack.last.use = use;
    }

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

    var unknownKey = false;
    String pathOf(String key) {
      unknownKey = false;
      final short = _shortKeys[key];
      if (short != null) return short;
      if (key == 'visible' || key == 'opacity') return key;
      if (spec.props.any((p) => p.key == key)) return 'props.$key';
      if (key == 'enabled' && spec.props.any((p) => p.key == 'isEnabled')) return 'props.isEnabled';
      if ((key == 'lines' || key == 'rows') && type == 'textField') return 'props.maxLines';
      // `Input "Age" type=number`: the keyboard it opens.
      if (key == 'type' && type == 'textField' && !spec.props.any((p) => p.key == 'type')) return 'props.keyboardType';
      if ((key == 'selected' || key == 'checked') && (type == 'checkbox' || type == 'switch')) return 'props.value';
      if (_layoutKeys.contains(key)) return 'layout.$key';
      if (_decorationKeys.contains(key)) return 'decoration.$key';
      // A component takes only what it declares: say so here, where the
      // line is, with what it does take.
      if (component && !open) {
        _issue(column, 'A $written has no "$key". It takes: ${spec.props.map((p) => p.key).join(', ')}.');
      }
      unknownKey = true;
      return 'props.$key';
    }

    // `bind=name`: the variable a control keeps its value in, both ways;
    // on what only shows a value, the variable (or `bind={expression}`) it
    // follows.
    void bindTo(String expr, int col) {
      final value = _valueProps[type];
      // A component keeps its value in the variable its parameter names.
      final held = !component
          ? null
          : spec.props.where((p) => p.type.isVariable && p.key == 'value').firstOrNull ?? spec.props.where((p) => p.type.isVariable).firstOrNull;
      if (held != null) {
        if (_identifier.hasMatch(expr) && expr.contains('.')) {
          // A field (`bind=draft.title`, `bind=i.done` under an each): the
          // component's variable parameter is the field's path, which it
          // reads and writes as it would a variable.
          switch (_fieldWrite(expr, 'result')) {
            case final String say:
              _issue(col, say);
            case (_, _, final String path):
              if (path.startsWith('"') && !path.contains(' + ')) {
                props[held.key] = jsonDecode(path);
              } else {
                bind['props.${held.key}'] = _formula(path);
              }
          }
        } else if (!_identifier.hasMatch(expr)) {
          _issue(col, 'A $written keeps its ${held.key} in a variable: write bind=name (or bind=record.field, bind=row.field under an each).');
        } else {
          props[held.key] = expr;
          final (kind, start) = switch (held.type.variableOf?.kind) {
            PropKind.number || PropKind.integer => ('decimal', 0 as Object),
            PropKind.boolean => ('boolean', false as Object),
            PropKind.list => ('list', const <Object?>[] as Object),
            _ => ('text', '' as Object),
          };
          if (_top._guessed.remove(expr)) variables.remove(expr);
          variables.putIfAbsent(expr, () => {'name': expr, 'type': kind, 'value': start});
        }
      } else if (standIn) {
        // What a stand-in would keep its value in is still a variable of the
        // page: what reads it elsewhere reads its starting value.
        if (_identifier.hasMatch(expr) && !expr.contains('.')) {
          variables.putIfAbsent(expr, () => {'name': expr, 'type': 'text', 'value': ''});
        }
      } else if (value == null) {
        final shown = _shownValue[type] ?? _mainKey(type, spec);
        if (written == 'Badge') {
          _texts.add(_read(expr));
        } else if (shown == null && open) {
          // A value this type does not keep: recorded, and the variable is
          // still the page's (what reads it reads its starting value).
          _use('parameter', 'bind', col, on: _srcWord ?? written, value: expr);
          if (_identifier.hasMatch(expr) && !expr.contains('.')) {
            variables.putIfAbsent(expr, () => {'name': expr, 'type': 'text', 'value': ''});
          }
        } else if (shown == null) {
          _issue(col, 'A $written has no value to bind. Give a prop its value: key={expression}.');
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
        if (_identifier.hasMatch(expr) && expr.contains('.')) {
          // A control bound to a field: of a record variable
          // (`Input bind=draft.title`), or of the repeated element
          // (`Input bind=field.label` under `each field in fields`, also a
          // list in the element around it): it shows the field, and a change
          // writes the record, or the element back into its list.
          switch (_fieldWrite(expr, list ? 'result[0]' : 'result')) {
            case final String say:
              _issue(col, say);
            case (final String variable, final String next, _):
              reactions.insert(0, {
                'trigger': {'type': 'changed'},
                'actions': [
                  {'type': 'setVariable', 'variable': variable, 'value': _formula(next)},
                ],
              });
          }
        } else if (expr.contains('.') || expr.contains('[')) {
          _issue(col, 'A control is bound to a variable by its name (bind=name), to a field of a record variable (bind=draft.title), or under an each to a field of its element (bind=row.name): "$expr" is none of these.');
        } else if (_identifier.hasMatch(expr)) {
          if (_top._guessed.remove(expr)) variables.remove(expr);
          variables.putIfAbsent(expr, () => {'name': expr, 'type': value.type, 'value': props[value.prop] ?? value.start});
          reactions.insert(0, {
            'trigger': {'type': 'changed'},
            'actions': [
              {
                'type': 'setVariable',
                'variable': expr,
                'value': list
                    ? r'${result[0]}'
                    : type == 'pageView'
                        ? r'${result.index}'
                        : type == 'calendar'
                            ? r'${result.start}'
                            : type == 'tableView'
                                ? r'${result.rowIndex}'
                                : r'${result}',
              },
            ],
          });
        }
      }
    }

    while (true) {
      t.skipSpace();
      if (t.done) break;
      final col = column + t.at;
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
          _issue(col, 'A $written takes ${strings.isEmpty ? 'no string' : 'no more strings (${strings.join(', ')})'}: write the rest as key="value".');
        } else if (text.contains(r'${')) {
          bind['props.$key'] = text;
          positional.add(key);
        } else {
          props[key] = text;
          positional.add(key);
        }
      } else if (t.peek == '"') {
        final text = t.string();
        if (type == 'text') markText ??= text;
        _main(type, spec, text, props, decoration);
      } else if (t.peek == '{' && _positional(t, type, standIn) != null) {
        // `Progress {done/total}`: a share worked out, written where its
        // number goes (Progress 0.6). On a stand-in it is in its record.
        final braced = _positional(t, type, standIn)!;
        if (!standIn) bindTo(braced.substring(1, braced.length - 1).trim(), col);
        t.at += braced.length;
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
                _issue(col, 'A $written has no "$k": left out. Its props are written key=value on the line.');
              }
            }
            tail['props'] = kept;
          }
          _merge(node, tail);
        } else {
          _issue(col, 'The {…} tail is a JSON object merged into the node.');
        }
        break;
      } else {
        final from = t.at;
        final word = t.word();
        if (word.isEmpty) {
          _issue(col, 'Unexpected "${t.peek}".');
          t.at++;
          continue;
        }
        // What the grammar does not have, said with what to write.
        if (word.startsWith('->')) {
          _issue(col, 'There is no arrow. What a node does is an event with its actions in braces: onTap={count=count+1} (onChange={…} on a control).');
          break;
        }
        final eq = word.indexOf('=');
        if (eq == 0) {
          _issue(col, 'A value has a key: write bind=name for the variable a control keeps its value in, key={expression} for a value worked out.');
          continue;
        }
        if (eq < 0) {
          final colon = word.indexOf(':');
          if (colon > 0 && RegExp(r'^[A-Za-z][A-Za-z0-9_-]*$').hasMatch(word.substring(0, colon))) {
            _issue(col, 'A value is written with =, not a colon: ${word.substring(0, colon)}=${colon + 1 < word.length ? word.substring(colon + 1) : '…'}.');
            if (word.endsWith(':') && t.peek == '"') t.string();
            if (word.endsWith(':') && (t.peek == '[' || t.peek == '{')) t.balanced();
            continue;
          }
          // `Grid cols=7 keep`: its columns hold at every width (a phone
          // shrinks the cells, it does not stack them).
          if (grid != null && word == 'keep') {
            _keepColumns.add(grid.id);
            continue;
          }
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
          } else if (written == 'CodeInput' && word == 'digits') {
            props['otpDigitsOnly'] = true;
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
          } else if (word == 'hidden') {
            node['visible'] = false;
          } else if (word == 'sticky') {
            // Stays in view while the page scrolls under it (a table of
            // contents beside an article, an order summary).
            // A bar across the top (SiteNav, a TopBar, a Header) stays at the very top.
            node['sticky'] = {'offset': RegExp(r'(Nav|Bar|Header)$').hasMatch(written) ? 0 : 16};
          } else if (spec.props.any((p) => p.key == word)) {
            props[word] = true;
          } else if (RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*)+$').hasMatch(word)) {
            // Text plan.name: a value shown as text is in a string.
            // The line's x was read as `item`: say it by the name written.
            final x = _stack.reversed.where((o) => o.each != null).firstOrNull?.each;
            final shown = x != null && word.startsWith('item.') ? '$x${word.substring(4)}' : word;
            _issue(col, 'A value shown as text is written in a string: "{$shown}".');
          } else if (standIn) {
            // Whatever a stand-in was given is in its record.
          } else if (open && RegExp(r'^[A-Za-z][A-Za-z0-9_-]*$').hasMatch(word)) {
            // A flag the type does not have: left out, and recorded (a
            // stand-in's are in its own record).
            if (!standIn) _use('flag', word, col, on: _srcWord ?? written);
          } else {
            _issue(col, 'Unknown word "$word" on a $written. Props are written key=value.');
          }
          continue;
        }
        var key = word.substring(0, eq);
        if (written == 'CodeInput' && (key == 'length' || key == 'digits')) key = key == 'length' ? 'otpLength' : 'otpDigitsOnly';
        // key={expression}, onTap={…}: the colon is not the grammar's.
        if (key.contains(':')) {
          final name = key.substring(0, key.indexOf(':'));
          _issue(col, 'A value is written with =, not a colon: $name=… (a value worked out: $name={expression}).');
          if (t.peek == '{' || t.peek == '[') t.balanced();
          if (t.peek == '"') t.string();
          continue;
        }
        if (key == 'swipe' && !spec.props.any((p) => p.key == 'swipe')) {
          _issue(col, 'A swipe is an event: onSwipeLeft={…} (Right, Up, Down).');
          continue;
        }
        // `show=phone` is where a node shows (a screen's size), never a
        // condition, which is visible={…}.
        final sizeWord = (key == 'show' || key == 'hide') && const {'phone', 'mobile', 'tablet', 'desktop'}.contains(word.substring(eq + 1));
        if ((key == 'show' || key == 'hide') && !sizeWord && !spec.props.any((p) => p.key == key)) {
          _issue(col, '$key= takes a size (phone, tablet): a condition is written visible={condition}.');
          if (t.peek == '{' || t.peek == '[') t.balanced();
          if (t.peek == '"') t.string();
          continue;
        }
        // What a node does: an event with its actions in braces
        // (onTap={a=1; toast "Saved"}), unless the node has a parameter of
        // that name.
        if (_handlerKey.hasMatch(key) && !spec.props.any((p) => p.key == key)) {
          t.at = from + eq + 1;
          if (t.peek != '{') {
            _issue(col, 'An event\x27s actions are written in braces: $key={name=value; toast "Saved"}.');
            if (t.peek == '"') {
              t.string();
            } else {
              t.word();
            }
            continue;
          }
          final braced = t.balanced();
          final body = braced.substring(1, braced.endsWith('}') ? braced.length - 1 : braced.length);
          var trigger = _handlerTrigger(key, type, component ? spec : null, node);
          // A stand-in is tapped, pressed, swiped and dropped on: what it
          // would say of its own value (onChange, onSubmit) it cannot.
          if (standIn && !const {'click', 'longPress', 'doubleTap', 'secondaryClick', 'swipeLeft', 'swipeRight', 'swipeUp', 'swipeDown', 'cursorEnter', 'drop'}.contains(trigger?['type'])) {
            trigger = null;
          }
          if (trigger == null && open) {
            // An event the type does not have: its actions are read (the
            // variables they set are the page's, their verbs recorded) and
            // left out.
            _actions(body, col);
            if (!standIn) _use('event', key, col, on: _srcWord ?? written, value: braced);
            continue;
          }
          if (trigger == null) {
            _issue(col, 'A $written has no event "$key". Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop.');
            continue;
          }
          final actions = _actions(body, col);
          // A menu opened by a right click or a long press sits where the pointer is.
          if (trigger['type'] == 'secondaryClick' || trigger['type'] == 'longPress') actions.forEach(_atPointer);
          reactions.add({'trigger': trigger, 'actions': actions});
          continue;
        }
        var raw = word.substring(eq + 1);
        if (key == 'bindEnd' && (type == 'slider' || type == 'calendar')) {
          sliderEnd = raw;
          sliderEndColumn = col;
          continue;
        }
        if (key == 'bind' && !spec.props.any((p) => p.key == 'bind')) {
          if (raw.isEmpty && t.peek == '{') {
            final braced = t.balanced();
            raw = braced.substring(1, braced.endsWith('}') ? braced.length - 1 : braced.length).trim();
          }
          if (raw.isEmpty) {
            _issue(col, 'bind= names a variable: bind=name.');
          } else {
            bindTo(raw, col);
          }
          continue;
        }
        // `id=why`: a name a `scroll why` goes to (the node's own id is the
        // one after its type, `Heading#why`).
        if (key == 'id' && RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(raw) && !spec.props.any((p) => p.key == 'id')) {
          _anchors[raw] = id;
          continue;
        }
        // `menu=rowMenu`: a right click, or a long press on a touch screen,
        // opens that Menu where the pointer is (a context menu).
        if (key == 'menu' && _identifier.hasMatch(raw) && !raw.contains('.') && !spec.props.any((p) => p.key == 'menu')) {
          for (final trigger in const ['secondaryClick', 'longPress']) {
            final actions = _actions('open $raw', col);
            actions.forEach(_atPointer);
            reactions.add({'trigger': {'type': trigger}, 'actions': actions});
          }
          continue;
        }
        // `preview=bio`: that Popover as a hover card by this line. It opens
        // after the pointer rests on the line or the keyboard's focus comes
        // to it, at once on a press, and stays while the pointer is on it.
        if (key == 'preview' && _identifier.hasMatch(raw) && !raw.contains('.') && !spec.props.any((p) => p.key == 'preview')) {
          Json opening(int delay) {
            final Json action = {
              'type': 'openModal',
              'to': raw,
              ...?switch (_top._overlayActions[raw]) { final Json a => _copy(a), _ => null },
              'hoverCard': true,
              if (delay > 0) 'hoverDelayMs': delay,
            };
            _top._opens.add(action);
            return action;
          }

          reactions.add({'trigger': {'type': 'hover'}, 'actions': [opening(350)]});
          reactions.add({'trigger': {'type': 'click'}, 'actions': [opening(0)]});
          reactions.add({'trigger': {'type': 'cursorExit'}, 'actions': <Object?>[]});
          continue;
        }
        if (raw.isEmpty && t.peek == '"') raw = jsonEncode(t.string());
        if (raw.isEmpty && (t.peek == '[' || t.peek == '{')) raw = t.balanced();
        // key={expression}: a value worked out from the state (from here on
        // it is marked with a leading =). A map names a key first ({"a": 1})
        // and is the JSON it is.
        if (_bracedValue.hasMatch(raw) || _bracedExpression(raw)) {
          raw = '=${raw.substring(1, raw.length - 1).trim()}';
        } else if (raw.startsWith('[') || raw.startsWith('{')) {
          try {
            // A list whose texts read values (items=["Lemons, {2 * n}"]):
            // each such text is its parts joined.
            final decoded = jsonDecode(raw);
            if (_readsValues(decoded)) raw = '=${_formulaSource(decoded)}';
          } catch (_) {
            _issue(col, 'Not a list of values. One that is worked out is written in braces: $key={$raw}.');
            continue;
          }
        } else if (raw != 'fill' && raw != 'hug' && !sizeWord && key != 'drag' && key != 'drop' && _variablePath.hasMatch(raw) && !_literal(raw).$1) {
          // A bare word is the word itself (tone=quiet). One that names a
          // variable was meant as its value: said, not guessed.
          final head = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*').stringMatch(raw)!;
          final known = variables.containsKey(head) || _derived.containsKey(head) || head == 'item' && _stack.any((o) => o.each != null);
          final ownValue = spec.props.any((p) => p.key == key && p.type.kind == PropKind.enumeration && p.type.values.contains(raw));
          // A key whose value is always a word (a field's type, an icon's
          // name) keeps it, whatever a variable is called:
          // Input "Email" type=email bind=email.
          const wordKeys = {'type', 'icon', 'align', 'weight', 'tone', 'variant'};
          if (known && !ownValue && !wordKeys.contains(key)) {
            _issue(col, 'A value read from the state is written in braces: $key={$raw}.');
            continue;
          }
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
        // `drag=todo(card.id)`: the node can be dragged, in a group, carrying
        // a value. `drop=todo,doing onTap={…}`: it takes drops from those groups,
        // and the line's -> runs on a drop ({result.data} is what was carried).
        // `animate=fade` (slide-up, scale, pulse, spin, pop, shake, shimmer…)
        // with `duration:` and `delay:` beside it, and `stagger:` under an
        // `each` (each copy that much later than the one before).
        if (key == 'animate' || key == 'animation' || key == 'enter') {
          final name = _literal(raw).$2?.toString() ?? raw;
          // fadeIn, fade-in, "fade in" and fade are one word.
          final word = name.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}-${m[2]}').toLowerCase().replaceAll(RegExp(r'[ _]'), '-');
          final look = notationAnimations[word] ?? notationAnimations[word.replaceAll(RegExp(r'-(in|once|loop)$'), '')];
          if (look == null) {
            _issue(col, 'No animate=$raw. Written animate=${notationAnimations.keys.join(', ')}.');
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
        // What a gauge measures in, under its figure: unit="km/h".
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
        // gradient=["#FF7C3AED","#FFEC4899"]: a fill from the first color to the last, corner to corner.
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
        if (key == 'mark' && type == 'text') {
          markQuery = raw.startsWith('=') ? raw.substring(1) : raw;
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
            if (open && key == 'size' && _value(raw) is! num) {
              // size=large: a size that is not a number is not ours.
              _use('parameter', key, col, on: _srcWord ?? written, value: raw);
              continue;
            }
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
        // Where a node shows, by the screen's width: hide=phone (not on a
        // phone), hide=tablet (not on a tablet or a phone), show=phone
        // (on a phone only), show=tablet (on a tablet and a phone only).
        // sticky=0 stays at the very top (a header); the word alone keeps 16 above it.
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
        // The widest a node gets (a page's column of content): maxw=720.
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
        if (key == 'drag') {
          final m = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)(?:\((.+)\))?$').firstMatch(raw);
          if (m == null) {
            _issue(col, 'drag is written drag=group or drag=group(value): drag=todo(card.id).');
          } else {
            node['draggable'] = {'group': m[1], if (m[2] != null) 'data': _read(m[2]!.trim())};
          }
          continue;
        }
        if (key == 'drop') {
          final groups = raw.split(',').map((g) => g.trim()).where((g) => g.isNotEmpty).toList();
          if (groups.isEmpty || groups.any((g) => !_identifier.hasMatch(g))) {
            _issue(col, 'drop is written drop=group or drop=a,b with the groups it takes: drop=todo,doing onDrop={done=append(done,result.data)}.');
          } else {
            node['dropTarget'] = {'accepts': groups};
          }
          continue;
        }
        // A hairline round it: `border=#FFE5E7EB`, or one that follows data: `border={on?"#FF2563EB":"#FFE5E7EB"}`.
        // A hairline on one side: border-bottom=#FFE5E7EB (a bar's rule, a pane's edge).
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
          // A style that follows data: `color={due?"#FFDC2626":"#FF111827"}`.
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
        // A DataTable's records: rows={list}.
        if (ours && written == 'DataTable' && key == 'rows') {
          if (!raw.startsWith('=')) {
            _issue(col, 'The rows of a table are read from the state, so they are in braces: rows={orders}.');
          } else {
            bind['data'] = _identifier.hasMatch(raw.substring(1)) ? _read(raw.substring(1)) : _formula(raw.substring(1));
          }
          continue;
        }
        if (key == 'hidden' && raw.startsWith('=')) {
          bind['visible'] = _formula('!(${raw.substring(1)})');
          continue;
        }
        // Input "Search" icon="search": the icon inside the field, before
        // the text (its decoration's prefixIcon).
        if (key == 'icon' && type == 'textField') {
          final field = (props['decoration'] as Json?) ?? (props['decoration'] = <String, Object?>{});
          field['prefixIcon'] = {'icon': raw.startsWith('=') ? 'search' : _value(raw), 'size': 18};
          if (raw.startsWith('=')) bind['props.decoration.prefixIcon.icon'] = _read(raw.substring(1));
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
        if (unknownKey) {
          unknownKeys.add((key: key, value: _written(word, eq, raw), column: col));
          // What a stand-in would keep a value in (bindStart=from) is still
          // a variable of the page.
          if (standIn && key.startsWith('bind') && _identifier.hasMatch(raw) && !raw.contains('.')) {
            variables.putIfAbsent(raw, () => {'name': raw, 'type': 'text', 'value': ''});
          }
        }
        // A string on the line already went to this parameter: saying it
        // twice would silently drop one.
        if (component && positional.contains(key)) {
          _issue(col, 'The string on this line is already the $written\'s $key: write $key once.');
        }
        final bound = raw.startsWith('=') ? raw.substring(1).trim() : null;
        final dotted = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)(\.[A-Za-z_][A-Za-z0-9_]*)+$').firstMatch(raw);
        if (bound != null && bound.startsWith('"') && _literal(bound).$1 && _literal(bound).$2 is String) {
          // value={"{s.jumps}"}: a text with a value in it, written in braces.
          final text = _interpolate(_literal(bound).$2! as String);
          if (text.contains(r'${')) {
            bind[path] = text;
          } else {
            put(path, text);
          }
        } else if (bound != null) {
          bind[path] = _read(bound);
        } else if (dotted != null && (variables.containsKey(dotted[1]) || dotted[1] == 'item')) {
          // minutes=today.minutes: a field of declared state where a value
          // goes is that value, not the words.
          bind[path] = _read(raw);
        } else {
          var v = _value(raw);
          // `Input "Email" type=email`: the keyboards by the names a model
          // writes for them (the document's are Flutter's).
          if (path == 'props.keyboardType' && v is String) v = _keyboards[v.toLowerCase()] ?? v;
          // grow=true is grow.
          if (path == 'layout.flex' && v is bool) {
            if (v) layout['flex'] = 1;
            continue;
          }
          // A text parameter given a number (count=4) takes it as text.
          if (v is num && component && spec.props.any((p) => p.key == key && p.type.kind == PropKind.string)) v = '$v';
          // …and a list of texts given numbers (options=[1,2,3], depths=[0,1]) takes them as texts.
          if (v is List && component && spec.props.any((p) => p.key == key && p.type.kind == PropKind.list && p.type.item?.kind == PropKind.string)) {
            v = [for (final e in v) e is num || e is bool ? '$e' : e];
          }
          // With an open vocabulary a value of another kind than the
          // parameter takes (live=polite where it is true or false,
          // size=large where it is a number) is not ours: left out, recorded.
          if (open && path == 'props.$key' && !(v is String && v.contains(r'${'))) {
            final def = spec.props.where((p) => p.key == key).firstOrNull;
            final wrong = def != null &&
                !def.type.isVariable &&
                switch (def.type.kind) {
                  PropKind.boolean => v is! bool,
                  PropKind.number || PropKind.integer => v is! num,
                  PropKind.enumeration => v is String && !def.type.values.contains(v),
                  PropKind.list => v is! List,
                  _ => false,
                };
            if (wrong) {
              if (!standIn) _use('parameter', key, col, on: _srcWord ?? written, value: _written(word, eq, raw));
              continue;
            }
          }
          if (v is String && v.contains(r'${') && !(type == 'text' && path == 'props.text')) {
            // A string that reads data (value="{streak} days") is bound:
            // only a text node reads an expression as written.
            bind[path] = v;
          } else {
            put(path, v);
          }
        }
      }
    }

    // A Handle is a 44 px grip, named for a screen reader, that its list is
    // reordered by.
    if (ours && written == 'Handle') {
      props['icon'] = 'drag_indicator';
      layout.addAll({'width': 44, 'height': 44});
      node['tooltip'] = 'Reorder';
      node['reorderHandle'] = true;
    }
    // Sizes not written: in a column a child fills the width and hugs its
    // height; in a row it hugs both; a control hugs.
    final control = _valueProps.containsKey(type) || type.endsWith('Button') || type.endsWith('Chip');
    if (component) {
      bool has(String k) => props.containsKey(k) || bind.containsKey('props.$k');
      // A block with an optional boolean state should still toggle when its
      // author leaves off bind=name. Give each call its own page variable.
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
        if (open) {
          // The line calls the component without something it needs: it is
          // given an empty one, so the page still renders, and recorded
          // (the answer's idea of this word is not the component's).
          final kind = p.type.isVariable ? p.type.variableOf?.kind : p.type.kind;
          final Object empty = switch (kind) {
            PropKind.number || PropKind.integer => 0,
            PropKind.boolean => false,
            PropKind.list => const <Object?>[],

            _ => '',
          };
          if (p.type.isVariable) {
            final local = '${id}_${p.key}';
            props[p.key] = local;
            variables.putIfAbsent(local, () => {
                  'name': local,
                  'type': switch (kind) { PropKind.number || PropKind.integer => 'decimal', PropKind.boolean => 'boolean', PropKind.list => 'list', _ => 'text' },
                  'value': empty,
                });
          } else {
            props[p.key] = empty;
          }
          _use('missing', p.key, column, on: _srcWord ?? written);
          continue;
        }
        _issue(column, 'A $written needs ${p.key}: write ${p.key}=${p.type.isVariable ? 'name (a variable), or bind=name' : p.type.kind == PropKind.list ? '["a","b"]' : p.type.kind == PropKind.string ? '"…"' : 'value'}.');
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
    // The parts of a text that match a search are drawn marked: runs over
    // the text, which itself stays whole (and is read whole).
    if (markQuery != null && markText != null) bind['props.runs'] = _formula('matchRuns(${_formulaSource(markText)}, $markQuery)');
    // A code field with no length written has six boxes.
    if (ours && written == 'CodeInput' && !bind.containsKey('props.otpLength')) props.putIfAbsent('otpLength', () => 6);
    if (written == 'Image') {
      final url = props.remove('text');
      decoration['fills'] = [
        {
          'image': {'url': url ?? '', 'fit': const {'cover', 'contain', 'fill', 'fitWidth', 'fitHeight', 'none', 'scaleDown'}.contains(imageFit) ? imageFit : 'cover'},
        },
      ];
      layout.putIfAbsent('height', () => 160);
    }
    // Shares of a whole: values=[…] labels=[…] colors=[…] as a donut (a pie
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
    // A Calendar's range: bind= is its first day, bindEnd= its last, and one
    // change gives both (result.start, result.end), as yyyy-MM-dd.
    if (sliderEnd != null && type == 'calendar') {
      final start = RegExp(r'^\$\{([A-Za-z_][A-Za-z0-9_]*)\}$').firstMatch('${bind['props.start']}')?.group(1);
      final end = sliderEnd;
      if (start == null || !_identifier.hasMatch(end) || end.contains('.')) {
        _issue(sliderEndColumn, 'A range of days is a Calendar with a variable for each end: Calendar bind=arrival bindEnd=departure.');
      } else {
        bind['props.end'] = _read(end);
        variables.putIfAbsent(end, () => {'name': end, 'type': 'text', 'value': ''});
        reactions.removeWhere((r) =>
            readMap(r['trigger'])?['type'] == 'changed' &&
            (r['actions'] as List?)?.any((a) => readMap(a)?['type'] == 'setVariable' && readMap(a)?['variable'] == start) == true);
        reactions.insert(0, {
          'trigger': {'type': 'changed'},
          'actions': [
            {'type': 'setVariable', 'variable': start, 'value': r'${result.start}'},
            {'type': 'setVariable', 'variable': end, 'value': r'${result.end}'},
          ],
        });
      }
      sliderEnd = null;
    }
    // A slider with two thumbs is one control: its value is the lower end,
    // rangeEnd the upper, and one change gives both (result.low, result.high).
    if (sliderEnd != null) {
      final low = RegExp(r'^\$\{([A-Za-z_][A-Za-z0-9_]*)\}$').firstMatch('${bind['props.value']}')?.group(1);
      final high = sliderEnd;
      if (low == null || !_identifier.hasMatch(high) || high.contains('.')) {
        _issue(sliderEndColumn, 'A range is a slider with a variable for each end: Slider bind=low bindEnd=high min=0 max=100.');
      } else {
        bind['props.rangeEnd'] = _read(high);
        variables.putIfAbsent(high, () => {'name': high, 'type': 'decimal', 'value': props['max'] is num ? props['max'] : 1});
        reactions.removeWhere((r) =>
            readMap(r['trigger'])?['type'] == 'changed' &&
            (r['actions'] as List?)?.any((a) => readMap(a)?['type'] == 'setVariable' && readMap(a)?['variable'] == low) == true);
        reactions.insert(0, {
          'trigger': {'type': 'changed'},
          'actions': [
            {'type': 'setVariable', 'variable': low, 'value': r'${result.low}'},
            {'type': 'setVariable', 'variable': high, 'value': r'${result.high}'},
          ],
        });
      }
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
    if (standIn && animation == null) timing = null;
    // A stand-in's height is the room its word asked for (a map, a
    // waveform): the least it is, and it grows with what is written in it.
    if (standIn && layout['height'] is num && props['scrollable'] != true) {
      layout['constraints'] = {...?readMap(layout['constraints']), 'minHeight': layout['height']};
      layout['height'] = {'hug': 0};
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
      _issue(column, 'duration=, delay= and stagger= go with animate= on the same line (animate=fade duration=400).');
    }
    // `grow={share}` follows a value: it grows, by 1 until the value is read
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
    // A DataTable is a table of the theme: rows and headers a finger can
    // press, as wide as its place, sorted from its headers, 320 tall unless
    // it says (it scrolls in that).
    if (ours && written == 'DataTable') {
      props.putIfAbsent('rowHeight', () => 48);
      props.putIfAbsent('headerHeight', () => 48);
      props.putIfAbsent('fillWidth', () => true);
      props.putIfAbsent('sortable', () => true);
      props.putIfAbsent('gridLineColor', () => options.track);
      layout.putIfAbsent('height', () => 320);
      if (!bind.containsKey('data') || (!props.containsKey('columns') && !bind.containsKey('props.columns'))) {
        _issue(column, 'A DataTable shows records in columns: DataTable rows={orders} columns=[{"key":"name","label":"Name"},{"key":"total","label":"Total"}].');
      }
      // A row chosen is a place in the order shown: a new order clears it.
      for (final r in reactions.toList()) {
        final sets = readMap(r['trigger'])?['type'] == 'changed'
            ? (r['actions'] as List?)?.map(readMap).nonNulls.where((a) => a['type'] == 'setVariable' && a['value'] == r'${result.rowIndex}').firstOrNull
            : null;
        if (sets == null) continue;
        r['trigger'] = {'type': 'rowTap'};
        reactions.add({
          'trigger': {'type': 'sort'},
          'actions': [
            {'type': 'setVariable', 'variable': sets['variable'], 'value': _formula('-1')},
          ],
        });
      }
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
    // large): `size=large` on a button, else the design system's height
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
    // A size that follows data (w={…}, h={…}) is a fixed one whose number the
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
    // With an open vocabulary, what the line gave that its type does not
    // take is left out of the document and recorded (what a word of the
    // notation read for itself, a Donut's legend, is no longer here).
    if (open && unknownKeys.isNotEmpty) {
      final takes = catalog.widget('${out['type']}');
      for (final u in unknownKeys) {
        if (takes != null && takes.props.any((p) => p.key == u.key)) continue;
        final p = out['props'], b = out['bind'];
        final given = (p is Map && p.containsKey(u.key)) || (b is Map && b.containsKey('props.${u.key}'));
        if (!given) continue;
        if (p is Map) p.remove(u.key);
        if (b is Map) b.remove('props.${u.key}');
        if (p is Map && p.isEmpty) out.remove('props');
        if (b is Map && b.isEmpty) out.remove('bind');
        if (!standIn) _use('parameter', u.key, u.column, on: _srcWord ?? written, value: u.value);
      }
    }
    nodes[id] = out;
    // A DataTable's cell and header are texts of the theme (item.value, item.label).
    if (ours && written == 'DataTable') {
      final body = options.textStyles['body'], strong = options.textStyles['strong'] ?? body;
      Json text(String read, Object? style) => {
            'type': 'text',
            'layout': {'width': {'fill': 0}, 'height': {'hug': 0}, 'padding': [12, 0, 12, 0]},
            'props': {'text': read, if (style != null) 'style': _copyValue(style)},
          };
      final slots = (out['slots'] as Json?) ?? (out['slots'] = <String, Object?>{});
      for (final (slot, child, node) in [('cell', '${id}Cell', text(r'${item.value}', body)), ('columnHeader', '${id}Header', text(r'${item.label}', strong))]) {
        if (slots.containsKey(slot)) continue;
        nodes[child] = node;
        slots[slot] = child;
        _parentOf[child] = id;
        _slotOf[child] = slot;
      }
    }
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
      _stack.add(_Open(indent, id, type,
          condition: null,
          grid: grid,
          leaf: spec.children == ChildModel.none && parent != null,
          slots: component && spec.children == ChildModel.none ? spec.slots : const [],
          written: written));
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
    // A short loop name may also be a layout key (`each h ... Text ... h=120`).
    // A key followed by ':' is notation, not a reference to the item.
    final word = RegExp('(?<![A-Za-z0-9_.#])${RegExp.escape(name)}(?![A-Za-z0-9_])');
    final out = StringBuffer();
    var quoted = false, inner = false, depth = 0, start = 0;
    void flush(int end, bool code) {
      final part = line.substring(start, end);
      out.write(code
          ? part.replaceAllMapped(word, (m) {
              // In `h=120` the `h` is a prop key. In `live ? h=4` it
              // is still the loop value, despite the following colon.
              final before = part.substring(0, m.start).trimRight();
              final key = m.end < part.length && part[m.end] == '=' && !(m.end + 1 < part.length && part[m.end + 1] == '=') &&
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
        if (_pages.overlay('Lightbox#$viewer photos={${viewer}Photos} bind=${viewer}At') case final Overlay o) {
          _openBlock(o);
          _closeBlock();
        }
      }
      // An app's sidebar, where the window has no room for it: a drawer the
      // top bar's menu button opens, each of its lines closing it as it is used.
      if (_pages.sidebarButton && _pages.sidebar.isNotEmpty && !_continues) {
        if (_pages.overlay('Drawer#${_pages.sidebarMenu}${_pages.sidebarRest}') case final Overlay o) {
          _openBlock(o);
          _quiet = true;
          for (final l in _pages.sidebar) {
            // Its ids are the sidebar's own: the copy has none.
            _feed(l.indent, l.text.replaceFirstMapped(_idMark, (m) => m[1]!), closes: 'all');
          }
          _closeBlock();
          _quiet = false;
        }
      }
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
    // With an open vocabulary the page renders whatever it names: an
    // `open <id>` of nothing written over this page, and a `scroll <id>` to
    // no line of it, are left out, and said where they are written.
    if (_host == null && options.openVocabulary) {
      final canvases = {for (final o in _overlays) o.options.screen};
      // What the author wrote over the page (not the drawer or viewer made for it).
      final written = [
        for (final c in canvases)
          if (c != _pages.sidebarMenu && c != _pages.viewer) c,
      ];
      final missing = <String, int>{};
      bool orphan(Object? a) {
        if (a is! Map) return false;
        final to = switch (a['type']) { 'openModal' => a['to'], 'scrollTo' => a['node'], _ => null };
        if (to is! String || to.contains(r'${')) return false;
        if (a['type'] == 'openModal' ? canvases.contains(to) : _taken(to)) return false;
        missing.putIfAbsent('${a['type'] == 'openModal' ? 'open' : 'scroll'} $to', () => _actionLines[a] ?? _line);
        return true;
      }

      void prune(Object? actions) {
        if (actions is! List) return;
        actions.removeWhere(orphan);
        for (final a in actions) {
          if (a is Map) {
            prune(a['actions']);
            prune(a['then']);
            prune(a['else']);
          }
        }
      }

      for (final p in [this, ..._overlays]) {
        prune(p._timers);
        for (final n in p.nodes.values) {
          prune(n['actions']);
        }
      }
      for (final e in missing.entries) {
        final id = e.key.substring(e.key.indexOf(' ') + 1);
        issues.add(NotationIssue(
            e.value,
            1,
            e.key.startsWith('open')
                ? 'Nothing over this page has the id "$id" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. '
                    '${written.isEmpty ? 'This page has none: write Dialog#$id "…" after the page, at the margin, with its lines under it.' : 'Over this page: ${written.join(', ')}.'}'
                : 'No line of this page has the id "$id" for a scroll to go to (Section#$id, or id=$id on a line): the action is left out.'));
      }
    }
    _ownLegends();
    _feet();
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
    // `state draft="" saved`: its value is kept on the device and is there
    // again after a reload (Variable.persist).
    final saved = rest.endsWith(' saved');
    if (saved) rest = rest.substring(0, rest.length - 6).trimRight();
    final m = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)$').firstMatch(rest);
    if (m == null) return _issue(column, 'State is written: state name=value.');
    if (m[1] == 'device') return _issue(column, 'device is read-only input capability; use device.hover or device.pointer in an if or binding.');
    var written = m[2]!.trim();
    // `state shown={filter(rows,r=>r.open)}`: a formula in braces, as an
    // expression is written everywhere else, is that formula (a map names
    // a key first: {"a": 1}).
    if (_bracedExpression(written)) written = written.substring(1, written.length - 1).trim();
    // One formula may read another (`state total=subtotal-discount`).
    for (final d in _derived.entries) {
      if (written.contains(d.key)) written = _rename(' $written', d.key, '(${d.value})').substring(1);
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
      if (saved) 'persist': true,
    };
  }

  static final _handlerKey = RegExp(r'^on[A-Z][A-Za-z]*$');

  /// What fires a handler named [key] on a node of [type]: a component's
  /// event of that name (else its first: onTap on a block is what it does
  /// when it is used); on a plain node, the event the name says. Null when
  /// a plain node has no such event.
  Json? _handlerTrigger(String key, String type, WidgetSpec? component, Json node) {
    if (key == 'onDrop') return {'type': 'drop'};
    // A table: a header pressed (result.column, result.ascending) and a row
    // chosen (result.row, result.rowIndex).
    if (type == 'tableView' && key == 'onSort') return {'type': 'sort'};
    if (type == 'tableView' && (key == 'onRowTap' || key == 'onTap')) return {'type': 'rowTap'};
    if (component != null) {
      final named = component.events.where((e) => e.key == key).firstOrNull ??
          (key == 'onChange' ? component.events.where((e) => e.key == 'onChanged').firstOrNull : null) ??
          component.events.firstOrNull;
      if (named != null) return {'type': 'event', 'event': named.key};
    }
    return switch (key) {
      'onTap' || 'onPress' || 'onPressed' || 'onClick' => {'type': 'click'},
      'onChange' || 'onChanged' => {'type': 'changed'},
      'onLongPress' => {'type': 'longPress'},
      'onDoubleTap' => {'type': 'doubleTap'},
      'onRightClick' || 'onSecondaryClick' || 'onContextMenu' => {'type': 'secondaryClick'},
      'onSwipeLeft' => {'type': 'swipeLeft'},
      'onSwipeRight' => {'type': 'swipeRight'},
      'onSwipeUp' => {'type': 'swipeUp'},
      'onSwipeDown' => {'type': 'swipeDown'},
      'onHover' => {'type': 'cursorEnter'},
      'onFocus' => {'type': 'focusGained'},
      'onBlur' => {'type': 'focusLost'},
      'onSubmit' => {'type': 'submitted'},
      _ => null,
    };
  }

  /// [line] without the assignments to [name] in its events' actions (and
  /// without an event left with none).
  String _withoutSets(String line, String name) {
    final k = RegExp.escape(name);
    final out = StringBuffer();
    var at = 0;
    for (final m in RegExp(r'(\s+)(on[A-Z][A-Za-z]*)=\{').allMatches(line)) {
      if (m.start < at || _outside(line.substring(0, m.end), '"') >= 0 && '"'.allMatches(line.substring(0, m.start)).length.isOdd) continue;
      final t = _Tokens(line)..at = m.end - 1;
      final braced = t.balanced();
      if (!braced.endsWith('}')) continue;
      final actions = braced.substring(1, braced.length - 1).replaceAll(RegExp('(^|;)\\s*$k\\s*(?:[-+*/])?=(?!=)[^;]*'), '').replaceFirst(RegExp(r'^\s*;\s*'), '');
      out.write(line.substring(at, m.start));
      if (actions.trim().isNotEmpty) out.write('${m[1]}${m[2]}={$actions}');
      at = t.at;
    }
    out.write(line.substring(at));
    return out.toString();
  }

  /// A choice between actions, as its condition and its two branches (each
  /// the text of its actions, a braced list unwrapped, either may be empty):
  /// `dirty ? open leave : go members`, `done ? close :`,
  /// `ok ? {saved=true; close} : toast "Fix the form"`, and the same written
  /// as code, `if (c) { … } else { … }` (an `else if` is the else branch).
  /// Null when [a] is no choice: an assignment whose value is a formula
  /// (`step = valid ? 3 : 2`), a verb's argument (`toast a ? "x" : "y"`), a
  /// `?` inside quotes or brackets.
  (String, String, String)? _choice(String a) {
    String unwrap(String s) {
      s = s.trim();
      // `{a; b}`, `(a; b)` as code writes it; `null` is no action.
      if ((s.startsWith('{') && s.endsWith('}') || s.startsWith('(') && s.endsWith(')')) && _closing(s, 0) == s.length - 1) {
        return s.substring(1, s.length - 1).trim();
      }
      return s == 'null' ? '' : s;
    }

    // if (cond) { … } [else { … } | else if …]
    final code = RegExp(r'^if\s*\(').firstMatch(a);
    if (code != null) {
      final close = _closing(a, code.end - 1);
      if (close < 0) return null;
      final cond = a.substring(code.end, close).trim();
      final rest = a.substring(close + 1).trim();
      if (!rest.startsWith('{')) return null;
      final end = _closing(rest, 0);
      if (end < 0) return null;
      final yes = rest.substring(1, end).trim();
      final tail = rest.substring(end + 1).trim();
      if (tail.isEmpty) return (cond, yes, '');
      final orElse = RegExp(r'^else\b\s*').firstMatch(tail);
      if (orElse == null) return null;
      return (cond, yes, unwrap(tail.substring(orElse.end)));
    }
    if (RegExp(r'^([A-Za-z_][A-Za-z0-9_.\[\]]*)\s*([-+*/])?=(?!=)').hasMatch(a)) return null;
    if (RegExp(r'^(emit|open|scroll|close|go|toast|announce|link|confirm)\b').hasMatch(a) || a.startsWith('{')) return null;
    // The first ? at the top level (not ?. or ??), then the : that closes it
    // (a ? inside the branch opens a choice of its own).
    var depth = 0, quoted = false, question = -1, nested = 0;
    for (var i = 0; i < a.length; i++) {
      final c = a[i];
      if (c == '"' && (i == 0 || a[i - 1] != r'\')) quoted = !quoted;
      if (quoted) continue;
      if (c == '{' || c == '[' || c == '(') depth++;
      if (c == '}' || c == ']' || c == ')') depth--;
      if (depth != 0) continue;
      if (c == '?') {
        final next = i + 1 < a.length ? a[i + 1] : '', before = i > 0 ? a[i - 1] : '';
        if (next == '.' || next == '?' || before == '?') continue;
        if (question < 0) {
          question = i;
        } else {
          nested++;
        }
      } else if (c == ':' && question >= 0) {
        if (nested > 0) {
          nested--;
          continue;
        }
        final cond = a.substring(0, question).trim();
        if (cond.isEmpty) return null;
        return (cond, unwrap(a.substring(question + 1, i)), unwrap(a.substring(i + 1)));
      }
    }
    return null;
  }

  /// Where the bracket at [open] of [s] closes (text in quotes aside); -1
  /// when it does not.
  static int _closing(String s, int open) {
    var depth = 0, quoted = false;
    for (var i = open; i < s.length; i++) {
      final c = s[i];
      if (c == '"' && (i == 0 || s[i - 1] != r'\')) quoted = !quoted;
      if (quoted) continue;
      if (c == '{' || c == '[' || c == '(') depth++;
      if (c == '}' || c == ']' || c == ')') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return -1;
  }

  /// Where a field a control is bound to lives, so that a change can be
  /// written there: `draft.title` (a field of a record variable),
  /// `item.done` (of the repeated element: `bind=i.done` under `each i in
  /// items`), `parent.item.on` (of the element of the each around it), and
  /// a field of an element of a list that is itself a field of the element
  /// around it (`each s in e.sets` under `each e in workouts`). A list worked
  /// out (`each d in filter(devices, …)`) is written through its variable
  /// when its records have an `id`. Returns the variable written, the
  /// formula of its new value with [value] at the field, and the path of
  /// the field as a formula giving text (`"rows[" + index + "].done"`: what
  /// a component's `variable` parameter is given). A String instead when
  /// the field cannot be written: what to say.
  Object _fieldWrite(String expr, String value) {
    String withAt(String base, List<String> fields, String v) =>
        fields.isEmpty ? v : 'with($base,"${fields.first}",${withAt('$base.${fields.first}', fields.sublist(1), v)})';
    final parts = expr.split('.');
    // A field of a record variable.
    if (parts.first != 'item' && parts.first != 'parent') {
      final root = parts.first;
      if (!variables.containsKey(root) || _derived.containsKey(root)) {
        return 'bind=$expr: "$root" is no variable of this page. Declare the record first (state $root={"${parts[1]}":""}), or bind a variable of its own (bind=${parts.last}).';
      }
      return (root, withAt(root, parts.sublist(1), value), jsonEncode(expr));
    }
    // A field of a repeated element: which each, counted from the innermost.
    var up = 0, at = 0;
    while (at < parts.length && parts[at] == 'parent') {
      up++;
      at++;
    }
    if (at >= parts.length || parts[at] != 'item' || at == parts.length - 1) return 'bind=$expr names no field of an element.';
    final fields = parts.sublist(at + 1);
    final eaches = [for (final o in _stack) if (o.each != null) o];
    final n = eaches.length, target = n - 1 - up;
    if (target < 0) return 'bind=$expr is written under no each.';
    String elem(int k) => '${'parent.' * (n - 1 - k)}item';
    String idx(int k) => '${'parent.' * (n - 1 - k)}index';
    final written = '${eaches[target].each}.${fields.join('.')}';
    // Down from the element to the list variable it is in.
    final lists = <String>[]; // the field of the element around that holds the list, from the target outwards
    var k = target;
    String? root, rootIndex;
    while (k >= 0) {
      final list = eaches[k].list ?? '';
      if (list.startsWith('item.') && k > 0 && RegExp(r'^item(\.[A-Za-z_][A-Za-z0-9_]*)+$').hasMatch(list)) {
        lists.add(list.substring(5));
        k--;
        continue;
      }
      if (_identifier.hasMatch(list) && !list.contains('.') && variables.containsKey(list) && !_derived.containsKey(list)) {
        root = list;
        rootIndex = idx(k);
        break;
      }
      // Worked out: written through the variable it reads, by the record's id.
      final reads = [
        for (final m in RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(list.replaceAll(RegExp(r'"[^"]*"'), '')))
          if (variables[m[0]]?['value'] case final List<Object?> rows when rows.isNotEmpty && rows.every((r) => r is Map && r.containsKey('id'))) m[0]!,
      ].toSet();
      if (reads.length == 1) {
        root = reads.single;
        rootIndex = 'indexOf(map($root,x=>x.id),${elem(k)}.id)';
        break;
      }
      final shown = eaches[target].list ?? '';
      final read = [
        for (final m in RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(list.replaceAll(RegExp(r'"[^"]*"'), '')))
          if (variables[m[0]]?['value'] is List) m[0]!,
      ].toSet();
      final l = read.length == 1 ? read.single : '<list>', e = eaches[target].each;
      return 'bind=$written: the each repeats $shown, which is worked out, so a change has no list to be written to. '
          'Repeat the list variable itself (each $e in $l, with an if for the ones to show), give its records an "id" field, '
          'or write the change: value={$written} onChange={$l=updateWhere($l,x=>x.id==$e.id,x=>with(x,"${fields.first}",result))}.';
    }
    // The new element at each level, from the field outwards.
    var next = withAt(elem(target), fields, value);
    for (var j = 0; j < lists.length; j++) {
      final level = target - j, around = level - 1;
      final f = lists[j].split('.');
      next = withAt(elem(around), f, 'setAt(${elem(around)}.${lists[j]},${idx(level)},$next)');
    }
    final base = target - lists.length;
    final path = StringBuffer('"$root[" + $rootIndex + "]');
    for (var j = lists.length - 1; j >= 0; j--) {
      path.write('.${lists[j]}[" + ${idx(target - j)} + "]');
    }
    path.write('.${fields.join('.')}"');
    assert(base >= 0);
    return (root!, 'setAt($root,$rootIndex,$next)', path.toString());
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
    for (final part in _split(text, ';')) {
      // A choice between actions: an `if` action, its branches read as
      // actions are (`dirty ? open leave : go members`).
      if (_choice(part.trim()) case (final cond, final yes, final no)) {
        final then = _actions(yes, column), orElse = _actions(no, column);
        if (then.isEmpty && orElse.isEmpty) continue;
        out.add({
          'type': 'if',
          'condition': {'left': _formula(cond), 'op': 'isTrue'},
          'then': then,
          if (orElse.isNotEmpty) 'else': orElse,
        });
        continue;
      }
      final a = _inPlace(part.trim());
      if (a.isEmpty) continue;
      if (a.startsWith('{')) {
        final j = _json(a);
        if (j is Map) out.add(j.cast<String, Object?>());
        continue;
      }
      // `confirm "Remove it?" then {rows=[]; toast "Removed"}`: the actions
      // after `then` run only when the question is answered yes.
      if (a.startsWith('confirm ') || a == 'confirm') {
        final tokens = _Tokens(a.substring('confirm'.length))..skipSpace();
        final title = tokens.peek == '"' ? tokens.string() : null;
        final tail = tokens.rest.trim();
        if (title == null || !tail.startsWith('then') || tail.substring(4).trim().isEmpty) {
          _issue(column, 'A confirm is a quoted question and what a yes does: confirm "Remove it?" then {count=0; toast "Removed"}.');
          continue;
        }
        var yes = tail.substring(4).trim();
        if (yes.startsWith('{') && yes.endsWith('}')) yes = yes.substring(1, yes.length - 1).trim();
        final nested = _actions(yes, column);
        if (nested.isNotEmpty) out.add({'type': 'confirm', 'title': _interpolate(title), 'actions': nested});
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
          // Its kind from the value: written (n=1), or read from the state
          // declared (`start=c.start` under an each over clips whose start
          // is a number, `completed=c.done` a list).
          var start = literal.$1 ? literal.$2 : null;
          final known = start != null || (!word && _variablePath.hasMatch(v) && (start = _sample(v)) != null);
          variables[set[1]!] = {
            'name': set[1],
            'type': switch (start) { bool _ => 'boolean', int _ => 'integer', num _ => 'decimal', List _ => 'list', Map _ => 'map', _ => 'text' },
            'value': switch (start) { bool _ => false, num _ => 0, List _ => <Object?>[], Map _ => <String, Object?>{}, _ => '' },
          };
          // Unknown: a control bound to it later gives it its kind.
          if (!known) _top._guessed.add(set[1]!);
        }
        continue;
      }
      final space = a.indexOf(' ');
      final verb = space < 0 ? a : a.substring(0, space), arg = space < 0 ? '' : a.substring(space + 1).trim();
      var s = arg.startsWith('"') ? _interpolate(_Tokens(arg).string()) : arg;
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
          _top._actionLines[action] = _line;
          out.add(action);
        case 'scroll':
          // `scroll pricing`, `scroll to pricing`, `scroll #pricing`: the page
          // moves to that part, named by its id (`Section#pricing`) or by an
          // anchor (`id=pricing` on a line).
          final target = s.replaceFirst(RegExp(r'^to\s+'), '').replaceFirst(RegExp(r'^#'), '').trim();
          if (target.isEmpty) {
            _issue(column, 'A scroll names where to: scroll pricing (the id of a line: Section#pricing, or id=pricing on it).');
          } else {
            final Json action = {'type': 'scrollTo', 'node': target, 'durationMs': 400, 'offset': 72};
            _scrolls.add(action);
            _top._actionLines[action] = _line;
            out.add(action);
          }
        case 'close':
          out.add({'type': 'closeModal'});
        case 'go':
          // A destination may be worked out (a SiteNav's link name as a
          // screen id: go replace(lower(result)," ","_")); a bare id is the id.
          // A page's id may have hyphens (go get-started is that page, not a
          // subtraction), and a destination already written ${= …} is whole.
          var braced = s.startsWith('{') && s.endsWith('}') && s.length > 2;
          // `go result` (a Tabs' or a SiteNav's choice), `go tab`, `go item.slug`:
          // a name the state has is the page it holds, as go {result} says.
          final root = s.split('.').first;
          if (!braced && _identifier.hasMatch(s) && (const {'result', 'item', 'parent', 'index'}.contains(root) || variables.containsKey(root))) {
            s = '{$s}';
            braced = true;
          }
          final fixed = arg.startsWith('"') || _identifier.hasMatch(s) || RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(s) || (s.startsWith(r'${') && s.endsWith('}'));
          if (!braced && !fixed) {
            _issue(column, 'A page that is worked out is written in braces: go {$s}. A bare word after go is the id of the page.');
          } else {
            out.add({'type': 'navigate', 'to': braced ? _formula(s.substring(1, s.length - 1).trim()) : s});
          }
        case 'toast':
          out.add({'type': 'showToast', 'message': s});
        case 'announce':
          // Said to a screen reader; nothing is shown and the focus stays.
          if (s.isEmpty) {
            _issue(column, 'An announce says a text to a screen reader: announce "3 results".');
          } else {
            out.add({'type': 'announce', 'message': s});
          }
        case 'link':
          out.add({'type': 'openLink', 'url': s});
        default:
          // A verb under another name (the alias table), then, with an open
          // vocabulary, a verb the notation does not have: left out, recorded.
          final name = RegExp(r'^[a-z][A-Za-z0-9]*(\.[A-Za-z][A-Za-z0-9]*)*(?=[\s(]|$)').stringMatch(a);
          if (name != null) {
            final rest = a.substring(name.length).trim();
            if (options.vocabulary.verbs[name] case final String to when _verbs.contains(to)) {
              _use('alias', name, column, of: 'verb', to: to, on: _srcWord, value: rest);
              final inner = rest.startsWith('(') && rest.endsWith(')') ? rest.substring(1, rest.length - 1) : rest;
              out.addAll(_actions('$to $inner'.trim(), column));
              continue;
            }
            if (options.openVocabulary) {
              _use('verb', name, column + (_verbAt++), on: _srcWord, value: rest);
              continue;
            }
          }
          _issue(column, 'Unknown action "$verb". Actions: name=value, emit <event>, toast "…", open <id>, close, go <screen>, scroll <id>, link <url>, announce "…", confirm "Question" then {actions}, or JSON.');
      }
    }
    return out;
  }

  static const _verbs = {'emit', 'open', 'scroll', 'close', 'go', 'toast', 'announce', 'link'};

  /// `type=` on an Input, as written → the keyboard the document names.
  static const _keyboards = {
    'email': 'emailAddress',
    'tel': 'phone',
    'telephone': 'phone',
    'numeric': 'number',
    'decimal': 'number',
    'integer': 'number',
    'int': 'number',
    'search': 'webSearch',
    'date': 'datetime',
    'time': 'datetime',
    'address': 'streetAddress',
    'textarea': 'multiline',
  };

  /// Variables an action made before anything said their kind (`x=c.start`
  /// with nothing declared to read it from): taken as text, until a control
  /// bound to them says otherwise.
  final Set<String> _guessed = {};

  /// Tells apart the unknown verbs of one event (they share its column).
  int _verbAt = 0;

  /// A key's value as it was written: the word's own, or what followed it
  /// (a string, a list, an expression: [read] has those marked with `=`).
  String _written(String word, int eq, String read) {
    final own = word.substring(eq + 1);
    if (own.isNotEmpty) return own;
    return read.startsWith('=') ? '{${read.substring(1)}}' : read;
  }

  /// Whether [line], at the margin, reads as a node of an unknown word and
  /// not as a sentence: it has an id, a string or a key=value, and ends as a
  /// line does.
  bool _nodeLike(String line) {
    final parts = LineParts.of(line);
    if (parts == null) return false;
    if (RegExp(r'[.:;!?,]$').hasMatch(line.trimRight()) && !line.trimRight().endsWith('"')) return false;
    final words = parts.parts.where((p) => p.kind == 'word').length;
    if (parts.parts.isEmpty) return parts.id.isNotEmpty || _root != null;
    return words < 3 && (parts.id.isNotEmpty || parts.parts.any((p) => p.kind != 'word'));
  }

  /// The `{expression}` at the cursor of a line whose type shows a number
  /// (Progress, Ring, Gauge, Slider), or of a stand-in: a value where the
  /// number goes, not the JSON merged into a node. Null otherwise.
  String? _positional(_Tokens t, String type, bool standIn) {
    if (!standIn && _valueProps[type]?.type != 'decimal' && _shownValue[type] != 'value') return null;
    final braced = (_Tokens(t.s)..at = t.at).balanced();
    if (braced.length < 3 || !braced.endsWith('}')) return null;
    return _bracedValue.hasMatch(braced) || _bracedExpression(braced) ? braced : null;
  }

  Object? _valueOrRead(String raw) {
    final l = _literal(raw);
    return l.$1 ? l.$2 : _read(raw);
  }

  String _id(String type) {
    final n = _counts[type] = (_counts[type] ?? 0) + 1;
    return '$type$n';
  }

  static final _bracedValue = RegExp(r'^\{[^{}":,]+\}$');

  /// How many brackets [raw] leaves open (text in quotes aside): the value
  /// goes on past a space until they close (`rows={[["Total", money(n)]]}`).
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
  static final _variablePath = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*|\[[^\]\s]*\])*$');
  /// The condition of the last `if` (and its `else if`s) at each depth, for an `else`.
  final Map<int, String> _ifAt = {};

  static final _dotsLine = RegExp(r'^Dots(#[A-Za-z_][A-Za-z0-9_]*)?\s+bind=([A-Za-z_][A-Za-z0-9_]*)\s+count=(\{[^{}]*\}|\S+)(\s.*)?$');
  static final _identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_.]*$');

  /// An expression as a binding reads it: a name, or a formula.
  String _read(String expr) {
    final e = expr.trim();
    // A word that is a value, not a name (enabled={false}): the value.
    if (const {'true', 'false', 'null'}.contains(e)) return _formula(e);
    // A name is read as it is; anything the formula language spells otherwise (rows.length) is a formula.
    return _identifier.hasMatch(e) && _natural(e) == e ? '\${$e}' : _formula(e);
  }

  String _formula(String expr) => '\${= ${_natural(_textsRead(_colors(expr)))}}';

  /// A color written in a formula as it is written after a key
  /// (`fill={late ? #FFFECACA : #FFFFFFFF}`): the text it is.
  String _colors(String expr) {
    if (!expr.contains('#')) return expr;
    final color = RegExp(r'#(?:[0-9A-Fa-f]{8}|[0-9A-Fa-f]{6})(?![0-9A-Za-z_])');
    final out = StringBuffer();
    var quote = '';
    for (var i = 0; i < expr.length; i++) {
      final c = expr[i];
      if (quote.isNotEmpty) {
        out.write(c);
        if (c == quote && expr[i - 1] != r'\') quote = '';
        continue;
      }
      if (c == '"' || c == "'") {
        quote = c;
      } else if (c == '#') {
        final m = color.matchAsPrefix(expr, i);
        if (m != null) {
          out.write('"${m[0]}"');
          i = m.end - 1;
          continue;
        }
      }
      out.write(c);
    }
    return out.toString();
  }

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
      // `clip.length` of a record that has a length field is the field.
      code = code.replaceAllMapped(RegExp(r'([A-Za-z_][A-Za-z0-9_.\[\]]*?)\.length\b(?!\()'),
          (m) => switch (_sample(m[1]!)) { final Map<Object?, Object?> r when r.containsKey('length') => m[0]!, _ => 'length(${m[1]})' });
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

  /// A value like the one [path] reads, from the state declared: a
  /// variable's start, the first element of the list an `each` repeats
  /// (`item`, `parent.item`), and fields of those. Null when it is not
  /// known.
  Object? _sample(String path) {
    final parts = path.replaceAll(RegExp(r'\[[^\]]*\]'), '.0').split('.').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    Object? first(Object? v) => v is List ? (v.isEmpty ? null : v.first) : v;
    Object? element(int up) {
      final eaches = [for (final o in _stack) if (o.each != null) o];
      final k = eaches.length - 1 - up;
      if (k < 0) return null;
      final list = eaches[k].list ?? '';
      if (variables[list]?['value'] case final List<Object?> rows) return first(rows);
      if (list.startsWith('item.')) return first(_sampleIn(element(up + 1), list.substring(5).split('.')));
      // Worked out from one list (filtered, sorted): its elements.
      final lists = {
        for (final m in RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(list.replaceAll(RegExp(r'"[^"]*"'), '')))
          if (variables[m[0]]?['value'] is List) m[0]!,
      };
      return lists.length == 1 ? first(variables[lists.single]!['value']) : null;
    }

    var up = 0, at = 0;
    while (at < parts.length && parts[at] == 'parent') {
      up++;
      at++;
    }
    if (at < parts.length && parts[at] == 'item') return _sampleIn(element(up), parts.sublist(at + 1));
    if (up > 0) return null;
    return _sampleIn(variables[parts.first]?['value'], parts.sublist(1));
  }

  static Object? _sampleIn(Object? v, List<String> keys) {
    for (final k in keys) {
      if (v is List) v = v.isEmpty ? null : v.first;
      if (int.tryParse(k) != null) continue;
      v = v is Map ? v[k] : null;
    }
    return v;
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

  /// Up to the next space (a `key="quoted value"` stops before its quote).
  String word() {
    final start = at;
    while (!done && s[at] != ' ') {
      if (s[at] == '"' || ((s[at] == '[' || s[at] == '{') && at > start && s[at - 1] == '=')) break;
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
