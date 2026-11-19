// The compact notation (docs/design/13-compact-notation.md): the form an
// agent writes for levels 0 to 2. One node per line, nesting by indentation:
//
//   Column gap=12
//     Slider @volume
//     Input "Email" @email
//     Toggle "Notifications" @notify
//     Button "Save" onTap={emit save}
//
// [parseNotation] expands it to an ordinary flat document; nothing after
// that (rendering, editing) knows the notation was used.
import 'dart:convert';
import 'dart:math' as math;

import '../behaviors.dart' show WidgetState, diffPatch, mergePatch;
import '../catalog.dart';
import '../design_system.dart';
import '../layout.dart' show SizeFit;
import '../json.dart';
import '../props.dart';
import '../suggest.dart' show didYouMean;
import '../theme.dart' show ThemeTokens;
import '../triggers.dart' show KeyCombo;
import 'bind_form.dart';
import 'brackets.dart';
import 'declared.dart';
import 'define.dart';
import 'formula_names.dart';
import 'keys.dart';
import 'media_words.dart';
import 'page_words.dart';
import 'reflow.dart';
import 'universal.dart';
import 'vocabulary.dart';
// Events and actions (design 22 sections 2.2, 2.3).
import '../action_fields.dart' show ActionCommonFields, TriggerFields;
import '../triggers.dart' show TriggerType;

// Paint, motion and charts (design 22, 4.6): paint_words.dart.
import '../behavior_fields.dart' show AnimationTrackFields, NodeAnimationFields, TransitionFields;
import '../custom_paint.dart' show DrawOp;
import '../custom_paint_fields.dart' show CustomPaintFields, DrawOpCommonFields, DrawOpSpecs;
// A ListView with lines of its own is read as a scrolling Column (_listOfLines).
import '../widgets/flex.dart' show FlexProps;

part 'notation_events.dart';
part 'paint_words.dart';
part 'state_words.dart';

/// An id as a line writes it after `#` (design 13, section 3): letters,
/// digits and `_`, its parts joined by single hyphens, as a JSON or HTML id
/// is written (`m-title`, `hero-cta-2`). It starts with a letter or `_` and
/// does not end in a hyphen. A regular expression's source, no anchors.
const notationId = r'[A-Za-z_][A-Za-z0-9_]*(?:-[A-Za-z0-9_]+)*';

/// [id] as a word of an expression, for a variable named after a node (a
/// list's selection, a block's own state): its hyphens as `_`, since in an
/// expression `a-b` is a subtraction.
String notationIdWord(String id) => id.replaceAll('-', '_');

/// [expr] without braces around it all, where they are the expression's
/// (`{length(sel) > 0}` after `when`, `{n + 1}` after `n=` in an action),
/// as `key={expression}` reads everywhere else: one rule for an expression
/// wherever it is written. A map literal (`{a: 1}`, `{"id": x}`, `{}`) keeps
/// its braces.
String notationUnbraced(String expr) {
  var e = expr.trim();
  while (e.length >= 2 && e.startsWith('{') && e.endsWith('}') && _closes(e, 0) == e.length - 1) {
    final inner = e.substring(1, e.length - 1).trim();
    if (inner.isEmpty || RegExp(r'''^(?:[A-Za-z_][A-Za-z0-9_]*|"[^"]*"|'[^']*')\s*:''').hasMatch(inner)) break;
    e = inner;
  }
  return e == expr.trim() ? expr : e;
}

/// Where the brace that opens at [open] in [s] closes (quotes skipped); -1
/// when it does not.
int _closes(String s, int open) {
  var depth = 0;
  var quote = '';
  for (var i = open; i < s.length; i++) {
    final c = s[i];
    if (quote.isNotEmpty) {
      if (c == r'\') {
        i++;
      } else if (c == quote) {
        quote = '';
      }
      continue;
    }
    if (c == '"' || c == "'") {
      quote = c;
    } else if (c == '{') {
      depth++;
    } else if (c == '}') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return -1;
}

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

/// Where text field [id] sits among buttons, in a document's [nodes] (by
/// id, as a document holds them) with [parentOf] each node's parent: the
/// places where it has no room for a label above it (the text input pass of
/// round 11, codelessly_sdk docs/research/text-input-round-11.md):
/// - `composer`: a multi-line field in a row beside a button;
/// - `toolbar`: a field among icon buttons (a stepper's, a toolbar's);
/// - `entry`: one field beside a text button (add an item, a comment, a
///   promo code, a newsletter's email), except in the row that ends a form
///   (its column has fields before the row and none after it) where the
///   field writes a label and a hint: there the label is the form's;
/// - `frame`: the framed row (or the box holding that row alone) of a field
///   beside a button with nothing else beside it but icons and texts.
/// In each the expander drops the label above the field (its hint, or its
/// spoken name beside a hint); the printer writes such a label by name
/// (`label="…"`), which keeps it.
({bool composer, bool toolbar, bool entry, String? frame}) notationFieldPlace(Map<String, Object?> nodes, String? Function(String id) parentOf, String id) {
  const buttons = {'iconButton', 'filledButton', 'outlinedButton', 'textButton', 'elevatedButton', 'floatingActionButton'};
  const fields = {'textField', 'dropdown', 'datePicker', 'timePicker', 'dateTimeInput', 'checkbox', 'switch', 'slider', 'radio', 'segmentedButton'};
  const quiet = {'icon', 'text', 'spacer', 'row', 'column', 'stack', 'image', ...buttons};
  Json? node(String? id) => id == null ? null : readMap(nodes[id]);
  List<String> kids(String id) => [...?(node(id)?['children'] as List?)?.whereType<String>().where(nodes.containsKey)];
  Iterable<String> types(String id) sync* {
    yield '${node(id)?['type']}';
    for (final k in kids(id)) {
      yield* types(k);
    }
  }

  bool framed(String id) {
    final d = readMap(node(id)?['decoration']);
    final r = d?['radius'];
    final round = r is num ? r > 0 : r != null;
    return round && ((d!['strokes'] as List?)?.isNotEmpty == true || (d['fills'] as List?)?.isNotEmpty == true);
  }

  final n = node(id) ?? const <String, Object?>{};
  final props = readMap(n['props']) ?? const <String, Object?>{};
  final maxLines = props['maxLines'];
  final multiline = (maxLines is num && maxLines != 1) || (props['minLines'] is num && (props['minLines']! as num) > 1);
  // Its place: up through the wrappers holding it alone, to a row.
  var at = id;
  for (var p = parentOf(at); p != null && const {'column', 'stack', 'row'}.contains(node(p)?['type']) && kids(p).length == 1; p = parentOf(p)) {
    at = p;
  }
  final row = parentOf(at);
  final inRow = row != null && node(row)?['type'] == 'row';
  final beside = inRow ? [for (final k in kids(row)) if (k != at) ...types(k)] : const <String>[];
  final alone = inRow && !beside.any(fields.contains);
  final byButton = alone && beside.any(buttons.contains);
  final composer = byButton && multiline;
  final toolbar = byButton && beside.contains('iconButton');
  final d = readMap(props['decoration']) ?? const <String, Object?>{};
  final b = readMap(n['bind']) ?? const <String, Object?>{};
  final labelAndHint = ((d['labelText'] is String && (d['labelText']! as String).isNotEmpty) || b['props.decoration.labelText'] != null) &&
      ((d['hintText'] is String && (d['hintText']! as String).isNotEmpty) || b['props.decoration.hintText'] != null);
  bool endsForm() {
    final column = parentOf(row!);
    if (column == null || node(column)?['type'] != 'column') return false;
    final lines = kids(column);
    final i = lines.indexOf(row);
    return lines.take(i).any((k) => types(k).any(fields.contains)) && !lines.skip(i + 1).any((k) => types(k).any(fields.contains));
  }

  final entry = byButton && !multiline && beside.any((t) => t != 'iconButton' && buttons.contains(t)) && !(labelAndHint && endsForm());
  // The frame: the row's own, or a box's holding the row alone. (Beside a
  // button: a composer's frame. A framed row of an icon and a field alone,
  // a document's search pill, is as it was written.)
  String? frame;
  if (byButton && beside.every(quiet.contains)) {
    for (String? f = row; f != null; f = parentOf(f)) {
      if (framed(f)) {
        frame = f;
        break;
      }
      final up = parentOf(f);
      if (up == null || kids(up).length != 1 || !const {'column', 'stack', 'row'}.contains(node(up)?['type'])) break;
    }
  }
  return (composer: composer, toolbar: toolbar, entry: entry, frame: frame);
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
    this.componentRules = const {},
    this.componentScreenActions = const {},
    this.componentScreenOverlays = const {},
    this.componentPressEvents = const {},
    this.badge = defaultBadge,
    this.cta,
    this.palette = const {},
    this.nearestColors = false,
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
    this.sidebarRail,
    this.sectionPad = 64,
    this.gutter = 24,
    this.band,
    this.siteFill,
    this.paneFill,
    this.iconTile,
    this.sideFill,
    this.iconStyle,
    this.rowFrames = const {},
    this.controlHeight,
    this.fieldLabel,
    this.fieldText,
    this.reflow = true,
    this.displaySizes = const {},
    this.themeTextStyles = const {},
    this.quietInks,
    this.projectVariables = const {},
    this.accentText,
    this.openVocabulary = false,
    this.vocabulary = NotationVocabulary.core,
    this.screens = const {},
    this.ownComponents = const {},
    this.themeColors = const {},
    this.roles = false,
  });

  /// These options with an open vocabulary (or not), and with [vocabulary]
  /// as the alias table when given.
  NotationOptions open({bool openVocabulary = true, NotationVocabulary? vocabulary}) =>
      _copy(openVocabulary: openVocabulary, vocabulary: vocabulary ?? this.vocabulary);

  /// These options with the words defined in [texts] (each a file's text by
  /// its name, `StickyNote.txt`; docs/design/20-defined-words.md) added to
  /// [vocabulary]. A defined word is a word we have, open or not.
  NotationOptions define(Map<String, String> texts) => _copy(openVocabulary: openVocabulary, vocabulary: vocabulary.define(texts));

  /// These options with [screens] as the ids of the app's screens.
  NotationOptions withScreens(Iterable<String> screens) => _copy(openVocabulary: openVocabulary, vocabulary: vocabulary, screens: {...screens});

  /// These options with [names] as the components that are the app's own
  /// (a site's, not a design system's): a line that writes one of them
  /// where a word of the notation of the same name is read instead
  /// (`Footer`, `Sidebar`, `Card`) is an issue, not a silent frame.
  NotationOptions withOwnComponents(Iterable<String> names) =>
      _copy(openVocabulary: openVocabulary, vocabulary: vocabulary, ownComponents: {...names});

  /// Whether the notation's own parts are drawn in the theme's roles by
  /// name (ThemeTokens.notationRoles: `line`, `card`, `band`, `hoverFill`,
  /// `quietText`...), each light or dark as the site is shown: a site's
  /// theme with no design system ([NotationOptions.fromTheme] `roles`).
  final bool roles;

  /// The components that are the app's own ([withOwnComponents]).
  final Set<String> ownComponents;

  /// The names of the theme's colors (its `colors`, whatever they are
  /// called): a bare word of them after a color key is the theme's, even
  /// where a variable has the name.
  final Set<String> themeColors;

  /// The ids of the app's screens (a site's pages): a bare word after `go`
  /// that names one ([notationScreen]) is that screen, even where a variable
  /// has the same name. Empty when the page is expanded alone.
  final Set<String> screens;

  NotationOptions _copy({double? width, String? screen, bool? reflow, required bool openVocabulary, required NotationVocabulary vocabulary, Set<String>? screens, Set<String>? ownComponents}) => NotationOptions(
        width: width ?? this.width,
        screen: screen ?? this.screen,
        textStyles: textStyles,
        card: card,
        badges: badges,
        surface: surface,
        accent: accent,
        track: track,
        components: components,
        componentRules: componentRules,
        componentScreenActions: componentScreenActions,
        componentScreenOverlays: componentScreenOverlays,
        componentPressEvents: componentPressEvents,
        badge: badge,
        cta: cta,
        palette: palette,
        nearestColors: nearestColors,
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
        sidebarRail: sidebarRail,
        sectionPad: sectionPad,
        gutter: gutter,
        band: band,
        siteFill: siteFill,
        paneFill: paneFill,
        iconTile: iconTile,
        sideFill: sideFill,
        iconStyle: iconStyle,
        rowFrames: rowFrames,
        controlHeight: controlHeight,
        fieldLabel: fieldLabel,
        fieldText: fieldText,
        reflow: reflow ?? this.reflow,
        displaySizes: displaySizes,
        themeTextStyles: themeTextStyles,
        quietInks: quietInks,
        projectVariables: projectVariables,
        accentText: accentText,
        openVocabulary: openVocabulary,
        vocabulary: vocabulary,
        screens: screens ?? this.screens,
        ownComponents: ownComponents ?? this.ownComponents,
        themeColors: themeColors,
        roles: roles,
      );

  /// The looks of [designSystem] ([NotationOptions.fromTheme] over its
  /// tokens) and the sizes of its components, so a component called by name
  /// (`StatusBadge "Paid"`, `Stepper @qty`) is as big as its own design says:
  /// as wide as its parent, as its content, or a size of its own.
  factory NotationOptions.fromDesignSystem(DesignSystem designSystem,
      {double width = 390, String screen = 'screen', bool named = false, bool nearestColors = false, bool reflow = true, Map<String, Json> projectVariables = const {}, bool roles = false}) {
    final base = NotationOptions.fromTheme(designSystem.manifest.theme.toJson(), width: width, screen: screen, named: named, nearestColors: nearestColors, reflow: reflow, roles: roles);
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
      nearestColors: base.nearestColors,
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
      sidebarRail: base.sidebarRail,
      sectionPad: base.sectionPad,
      gutter: base.gutter,
      band: base.band,
      siteFill: base.siteFill,
      paneFill: base.paneFill,
      iconTile: base.iconTile,
      sideFill: base.sideFill,
      iconStyle: base.iconStyle,
      // A frame whose lines go into a row (a toolbar's, a dialog's footer)
      // lays them out as a row's: a text as wide as its words, not the row.
      rowFrames: {
        for (final c in designSystem.list)
          for (final n in c.document.nodes.values)
            if (n.type == 'row' && n.children.any((k) => c.document.nodes[k]?.type == 'slot')) c.type,
      },
      controlHeight: base.controlHeight,
      fieldLabel: base.fieldLabel,
      fieldText: base.fieldText,
      reflow: base.reflow,
      displaySizes: base.displaySizes,
      themeTextStyles: base.themeTextStyles,
      quietInks: base.quietInks,
      projectVariables: projectVariables,
      accentText: base.accentText,
      themeColors: base.themeColors,
      roles: base.roles,
      components: {
        for (final c in designSystem.list)
          if (c.document.nodes[c.document.roots.firstOrNull] case final root?)
            c.type: (width: size(root.layout.width.fit, root.layout.width.value), height: size(root.layout.height.fit, root.layout.height.value)),
      },
      componentRules: {
        for (final c in designSystem.list)
          if (c.document.nodes[c.document.roots.firstOrNull] case final root? when root.media.isNotEmpty) c.type: [for (final r in root.media) r.toJson()],
      },
      componentScreenActions: {
        for (final c in designSystem.list)
          if (c.document.extra['screenActions'] case final List actions when actions.isNotEmpty)
            c.type: [for (final a in actions) if (a is Map) a.cast<String, Object?>()],
      },
      componentScreenOverlays: {
        for (final c in designSystem.list)
          if (c.document.extra['screenOverlays'] case final List overlays when overlays.isNotEmpty)
            c.type: [for (final o in overlays) if (o is Map) o.cast<String, Object?>()],
      },
      componentPressEvents: {
        for (final c in designSystem.list)
          if (c.document.nodes[c.document.roots.firstOrNull] case final root?)
            for (final r in root.actions)
              if (r.trigger.type == TriggerType.click)
                for (final a in r.actions)
                  if (a.toJson() case {'type': 'componentEvent', 'event': final String event}) c.type: event,
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
  factory NotationOptions.fromTheme(Json theme, {double width = 390, String screen = 'screen', bool named = false, bool nearestColors = false, bool reflow = true, bool roles = false}) {
    final colors = readMap(theme['colors']) ?? const {};
    String color(String name, String fallback) {
      Object? c = colors[name] ?? theme[name];
      for (var i = 0; i < 8 && c is String && !c.startsWith('#'); i++) {
        c = colors[c] ?? theme[c];
      }
      if (c is! String || !c.startsWith('#')) return fallback;
      return named ? name : c;
    }

    // The theme's ground and ink by the names the notation's prompt teaches
    // (`paper`, `ink`), when it has no design system's names for them; a
    // dark ground's tones (its lines, fills, cards) derived from its ink and
    // its ground, not a light theme's (round 11: dark sites kept grey-on-white
    // dividers and white cards).
    String? hexOf(String name) {
      Object? c = colors[name] ?? theme[name];
      for (var i = 0; i < 8 && c is String && !c.startsWith('#'); i++) {
        c = colors[c] ?? theme[c];
      }
      return c is String && RegExp(r'^#[0-9A-Fa-f]{8}$').hasMatch(c) ? c : null;
    }

    final groundName = const ['paper', 'background', 'bg', 'ground'].where((n) => hexOf(n) != null).firstOrNull;
    final groundHex = hexOf('page') ?? hexOf('surface') ?? hexOf('primaryBackground') ?? (groundName == null ? null : hexOf(groundName));
    double lum(String hex) {
      final v = [for (var i = 3; i < 9; i += 2) int.parse(hex.substring(i, i + 2), radix: 16) / 255];
      return 0.2126 * v[0] + 0.7152 * v[1] + 0.0722 * v[2];
    }

    final dark = groundHex != null && lum(groundHex) < 0.35;
    // The tones the notation draws its own parts in are the theme's roles
    // (ThemeTokens.notationRoles): with [roles] (a site with no design
    // system) written by their names, so the renderer gives each its light
    // or dark value in the mode the site is shown in; else their values in
    // this theme (a dark ground's made from its ink and ground).
    final tokens = ThemeTokens.fromJson(theme);
    String roleOf(String name) => named && roles ? name : tokens.notationRole(name)!.toJson();
    final lineTone = roleOf('line');
    final fillTone = roleOf('subtleFill');
    final cardTone = roleOf('card');
    final groundTone = groundName == null ? '#FFFFFFFF' : color(groundName, '#FFFFFFFF');
    final ink = color('primaryText', color('onSurface', color('ink', dark ? '#FFF3F4F6' : '#FF111827')));
    final muted = color('secondaryText', ink), faint = color('tertiaryText', muted);
    final styles = <String, Object>{};
    for (final e in (readMap(theme['textStyles']) ?? const {}).entries) {
      final s = readMap(e.value);
      if (s == null) continue;
      // A style named as one of the notation's text variants changes only the
      // keys it sets: `heading1: {fontFamily, fontWeight}` keeps the
      // variant's size (round 11: 13 px page titles, a 12 px heading).
      final variant = (defaultTextVariants[e.key] as Map?)?.cast<String, Object?>() ?? const <String, Object?>{};
      final kept = {
        for (final k in [...const ['fontSize', 'fontWeight'], if (e.key == 'mono') 'fontFamily'])
          if (s[k] == null && variant[k] != null) k: variant[k],
      };
      styles[e.key] = named
          ? {'from': e.key, ...kept, if (s['color'] == null) 'color': ink}
          : {
              ...kept,
              for (final k in const ['fontSize', 'fontWeight', 'fontFamily', 'letterSpacing', 'height'])
                if (s[k] != null) k: s[k],
              'color': s['color'] is String ? color(s['color'] as String, ink) : ink,
            };
    }
    Object style(String name, Object fallback) => styles[name] ?? fallback;
    Json body() => {...(style('body', const {'fontSize': 13}) as Map).cast<String, Object?>()};
    styles
      ..putIfAbsent('title', () => style('pageTitle', {...(defaultTextVariants['title']! as Map).cast<String, Object?>(), 'color': roleOf('headingText')}))
      ..putIfAbsent('heading', () => style('sectionTitle', {...(defaultTextVariants['heading']! as Map).cast<String, Object?>(), 'color': roleOf('headingText')}))
      ..putIfAbsent('strong', () => body()..addAll({'fontWeight': 600, 'color': ink}))
      ..putIfAbsent('small', () => style('bodySecondary', defaultTextVariants['small']!))
      ..putIfAbsent('muted', () => body()..['color'] = muted)
      ..putIfAbsent('caption', () => {'fontSize': 11, 'color': faint})
      ..putIfAbsent('body', () => body()..['color'] = ink)
      ..putIfAbsent('danger', () => body()..addAll({'fontWeight': 600, 'color': color('error', '#FFDC2626')}))
      ..putIfAbsent('success', () => body()..addAll({'fontWeight': 600, 'color': color('success', '#FF16A34A')}))
      // NOTATION.md lists Text.mono with the others: a theme without its own
      // `mono` has the body's size and ink in a monospace face.
      ..putIfAbsent('mono', () => body()..addAll({'fontFamily': 'monospace', 'color': ink}));
    // NOTATION.md lists SSUI's names too (Text.pageTitle, Text.heading1…):
    // a theme that has none of its own has them in its body's face, at
    // SSUI's sizes and weights, in its ink (they were refused under a site's
    // theme: test 9, admin 8).
    for (final e in defaultTextVariants.entries) {
      final d = (e.value as Map).cast<String, Object?>();
      final secondary = d['color'] != null && d['color'] != '#FF111827';
      styles.putIfAbsent(e.key, () => body()..addAll({for (final k in const ['fontSize', 'fontWeight', 'fontFamily']) if (d[k] != null) k: d[k], 'color': secondary ? muted : ink}));
    }
    // A tone the theme has no tint for: a tenth of the tone's own color, a
    // hairline of it at 28 % (SSUI's), or SSUI's tone when the theme has
    // none of that name (a site's theme names a primary and its own colors:
    // Badge.success drew as the neutral grey, round 11).
    String? hex(String name) {
      Object? c = colors[name] ?? theme[name];
      for (var i = 0; i < 8 && c is String && !c.startsWith('#'); i++) {
        c = colors[c] ?? theme[c];
      }
      return c is String && RegExp(r'^#[0-9A-Fa-f]{8}$').hasMatch(c) ? c : null;
    }

    (String, String, String) tone(String role, String inkName) {
      if (role == 'neutral' || hex('${role}Tint') != null) {
        return (color('${role}Tint', roleOf('neutralTint')), color('${role}TintBorder', lineTone), color(inkName, ink));
      }
      if (hex(inkName) case final String base) {
        return ('#1A${base.substring(3)}', '#47${base.substring(3)}', color(inkName, ink));
      }
      return badgeVariants[role] ?? (color('${role}Tint', '#FFF3F4F6'), color('${role}TintBorder', '#FFE5E7EB'), color(inkName, ink));
    }
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
      themeColors: {...colors.keys, if (named && roles) ...ThemeTokens.notationRoles.keys},
      roles: named && roles,
      textStyles: styles,
      card: {
        'decoration': {
          'fills': [
            {'color': color('card', color('primaryBackground', cardTone))},
          ],
          'strokes': [
            {'color': color('primaryBorder', lineTone)},
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
      nearestColors: named && nearestColors,
      progress: {
        if (radii['progress'] != null) 'borderRadius': radii['progress'],
        if (sizes['progress'] != null) 'height': sizes['progress'],
      },
      cardGap: spacing['cardGap'] is num ? spacing['cardGap'] as num : null,
      ringStroke: sizes['ring'] is num ? sizes['ring'] as num : null,
      contentWidth: readDouble(sizes['content']) ?? 1120,
      line: color('line', color('primaryBorder', lineTone)),
      selectedFill: color('activeTint', color('primaryTint', color('subtleFill', fillTone))),
      narrowWidth: readDouble(sizes['narrow']) ?? 720,
      sidebarWidth: readDouble(sizes['sidebar']) ?? 248,
      sidebarRail: readDouble(sizes['rail']),
      sectionPad: readDouble(spacing['section']) ?? 64,
      gutter: readDouble(spacing['gutter']) ?? 24,
      band: colors['band'] != null ? color('band', '#FFF8FAFC') : null,
      siteFill: colors['pageFill'] != null ? color('pageFill', '#FFFFFFFF') : null,
      paneFill: colors['card'] != null ? color('card', '#FFFFFFFF') : null,
      iconTile: colors['iconTile'] != null ? color('iconTile', '#1A2563EB') : null,
      sideFill: colors['sidebar'] != null ? color('sidebar', '#FFFFFFFF') : null,
      iconStyle: switch (theme['iconStyle']) { final String s when const {'outlined', 'rounded', 'sharp'}.contains(s) => s, _ => null },
      controlHeight: readDouble(sizes['control']),
      fieldLabel: isWide ? styles['fieldLabelWide'] : null,
      fieldText: isWide ? styles['inputTextWide'] : null,
      reflow: reflow,
      // A link in running text: the accent where it is read as text on a
      // light page (a bright accent is for fills).
      accentText: colors['accentText'] != null ? color('accentText', '#FF1D4ED8') : colors['accentDeep'] != null ? color('accentDeep', '#FF1D4ED8') : null,
      quietInks: named && roles ? ('quietText', 'mutedText', 'faintText') : dark ? (roleOf('quietText'), roleOf('mutedText'), roleOf('faintText')) : null,
      themeTextStyles: {
        for (final e in textStyles.entries)
          if (readMap(e.value) case final Json s) e.key: s,
      },
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
              'gridColor': color('primaryBorder', lineTone),
            },
      sectionRadius: radii['card'] != null && radii['panel'] is num ? radii['panel'] as num : null,
      tile: radii['tile'] == null
          ? null
          : {
              'decoration': {
                'fills': [
                  {'color': color('card', color('primaryBackground', cardTone))},
                ],
                'strokes': [
                  {'color': color('primaryBorder', lineTone)},
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
      surface: color('page', color('surface', color('primaryBackground', groundTone))),
      // A theme calls its one strong color primary, accent or brand.
      accent: color('primary', color('accent', color('brand', '#FF2563EB'))),
      track: color('track', fillTone),
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
        componentRules: componentRules,
        componentScreenActions: componentScreenActions,
        componentScreenOverlays: componentScreenOverlays,
        componentPressEvents: componentPressEvents,
        badge: badge,
        cta: cta,
        palette: palette,
        nearestColors: nearestColors,
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
        sidebarRail: sidebarRail,
        sectionPad: sectionPad,
        gutter: gutter,
        band: band,
        siteFill: siteFill,
        paneFill: paneFill,
        iconTile: iconTile,
        sideFill: sideFill,
        iconStyle: iconStyle,
        rowFrames: rowFrames,
        controlHeight: controlHeight,
        fieldLabel: fieldLabel,
        fieldText: fieldText,
        // A narrow overlay wraps its rows of copies (PageReflow.runNarrow);
        // nothing else of it is laid out again.
        reflow: reflow && width < 700,
        displaySizes: displaySizes,
        themeTextStyles: themeTextStyles,
        quietInks: quietInks,
        openVocabulary: openVocabulary,
        vocabulary: vocabulary,
        ownComponents: ownComponents,
        themeColors: themeColors,
        roles: roles,
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

  /// A design system's components' own rules at other widths (their root's
  /// media rules), by type: what a call takes of them, its size and whether
  /// it shows (`w=232 tablet.w=64` on the root of a sidebar), unless the
  /// call says that itself.
  final Map<String, List<Json>> componentRules;

  /// What a component's `key`, `every` and `on load` lines do, by type (its
  /// document's `screenActions`): the screen that shows the component takes
  /// them (once, however many calls), as if written on it.
  final Map<String, List<Json>> componentScreenActions;

  /// The overlays a component writes after its tree (`Drawer#basket`,
  /// `Sheet#details stops=[0.5,1]`), by type (its document's
  /// `screenOverlays`: each `{"id", "nodes"}`, its canvas and its lines):
  /// the screen that shows the component takes them (once, unless it writes
  /// an overlay of that id itself), so what the component opens is there,
  /// shown as it was written (round 10, R28: they were left out, and the
  /// open showed nothing or a centred dialog).
  final Map<String, List<Json>> componentScreenOverlays;

  /// The event a component sends when it is pressed (its root's click
  /// emits it: a MenuItem's onSelected), by type: `onTap` on a call is that
  /// event, not a press on the call around the component's own.
  final Map<String, String> componentPressEvents;

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

  /// A design system's rail: how wide an app's sidebar written with no rule
  /// for other widths is at a tablet's (its words fold to their icons
  /// there): a theme's `sizes.rail`. Null: as wide as written.
  final double? sidebarRail;

  /// A tinted section's fill (`Section tint`), what a website page is drawn
  /// on, an app's sidebar and top bar, and the tile behind an icon: a
  /// theme's `colors.band`, `pageFill`, `card` and `iconTile`. Null: none.
  final String? band, siteFill, paneFill, iconTile;

  /// What an app's `Sidebar` (and a drawer's panel) is drawn on: a theme's
  /// `colors.sidebar`, so the chrome can be a step off the panes and the
  /// cards (`colors.card`). Null: [paneFill].
  final String? sideFill;

  /// The style a Material icon written by its bare name is drawn in: a
  /// theme's `iconStyle` (`outlined`, `rounded`, `sharp`), so every icon of
  /// the page shares the design system's look (`Icon "inbox"` is
  /// `inbox_outlined`). A name with a style of its own keeps it. Null: as
  /// written (filled).
  final String? iconStyle;

  /// A design system's components whose children (the lines written under a
  /// call) go into a row (their `Slot` is a row's child: a toolbar, a
  /// dialog's footer): those lines are sized as a row's children are.
  final Set<String> rowFrames;

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

  /// The inks of a sidebar's or a bar's items at rest, of their icons and of
  /// what is fainter still, on a dark ground: its ink at 80, 60 and 40 %.
  /// Null: a light theme's greys.
  final (String, String, String)? quietInks;

  /// The theme's text styles as it writes them, by name: a line's
  /// `style=serif` over a variant changes only the keys that style sets.
  final Map<String, Json> themeTextStyles;

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

  /// The theme's colors by name → `#AARRGGBB` ([NotationOptions.fromTheme]
  /// with `named`). Empty: the theme's looks are written as values.
  final Map<String, String> palette;

  /// Whether a color the notation writes is read as the theme's nearest
  /// color of the [palette] (`fill=#FFF5F5F5` on a panel is the theme's
  /// nearest neutral fill, and so follows dark mode and the theme). Off by
  /// default: a written color stays as written, so a design with a palette
  /// of its own (a dark workspace on a light theme) keeps its panels apart.
  /// The looks the notation itself adds are named either way, with `named`.
  final bool nearestColors;

  /// The theme's name for [hex] written as a [kind] (`fill`, `stroke`,
  /// `text`), when one of the [palette] is close to it; else null.
  String? colorName(String hex, String kind) {
    if (!nearestColors || palette.isEmpty) return null;
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

/// The screen of [screens] (ids, `cook-mode`) that [word] after a `go`
/// names: its id, its id written with underscores or capitals
/// (`go cook_mode`), or the one screen whose id starts with it or holds all
/// its words (`go cook`); null when none or several do.
String? notationScreen(String word, Iterable<String> screens) {
  if (screens.isEmpty || !RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(word)) return null;
  final ids = screens.toList();
  if (ids.contains(word)) return word;
  final t = word.replaceAll('_', '-').toLowerCase();
  if (ids.contains(t)) return t;
  final words = t.split('-');
  final near = ids.where((p) => p.startsWith('$t-') || words.every(p.split('-').contains)).toList();
  return near.length == 1 ? near.first : null;
}

/// The keys a key event names beyond a single character, as a shortcut's
/// key is compared with them ([KeyCombo.normalizeKey]: lower case, no
/// spaces; `esc`, `return` and `spacebar` are read as theirs).
const Set<String> _runtimeKeys = {
  'enter', 'return', 'escape', 'esc', 'space', 'spacebar', 'tab', 'backspace', 'delete', 'insert', 'home', 'end', 'pageup', 'pagedown', //
  'arrowup', 'arrowdown', 'arrowleft', 'arrowright',
  'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12',
};

/// The names a writer gives keys that no key event has, by the key's own
/// (`left` is ArrowLeft).
const Map<String, String> _keyNames = {
  'left': 'ArrowLeft', 'right': 'ArrowRight', 'up': 'ArrowUp', 'down': 'ArrowDown', //
  'del': 'Delete', 'bksp': 'Backspace', 'ins': 'Insert', 'pgup': 'PageUp', 'pgdn': 'PageDown',
  'plus': '+', 'minus': '-', 'equal': '=', 'comma': ',', 'period': '.', 'slash': '/', 'question': '?',
};

/// [combo] (`alt+right`, `mod+k`, `Esc`) with its key as a key event names
/// it (`alt+ArrowRight`; a key it names already is kept as written) and its
/// modifiers as written; null when its key is no key (one of
/// [_runtimeKeys], [_keyNames] or a single character) or a modifier is
/// unknown.
String? notationKeyName(String combo) {
  if (combo == '+' || KeyCombo.tryParse(combo) == null) return combo == '+' ? '+' : null;
  final plus = combo.endsWith('++');
  final at = plus ? combo.length - 1 : combo.lastIndexOf('+');
  final mods = at <= 0 ? '' : combo.substring(0, plus ? at : at + 1);
  final key = plus ? '+' : combo.substring(at + 1);
  final lower = key.replaceAll(' ', '').toLowerCase();
  if (_runtimeKeys.contains(lower) || key.runes.length == 1) return combo;
  final named = _keyNames[lower];
  return named == null ? null : '$mods$named';
}

/// [combo] (as [notationKeyName] gives it) as a tooltip says it: `mod+b` is
/// Ctrl+B, `cmd+k` ⌘K, `alt+ArrowRight` Alt+→. A tooltip is one text on
/// every platform, so mod is said as Ctrl.
String _keyHint(String combo) {
  final plus = combo.endsWith('++');
  final at = plus ? combo.length - 1 : combo.lastIndexOf('+');
  final key = plus ? '+' : combo.substring(at + 1);
  final mods = [
    for (final m in (at <= 0 ? '' : combo.substring(0, at)).split('+'))
      if (m.isNotEmpty)
        switch (m.toLowerCase()) {
          'cmd' || 'command' || 'meta' => '⌘',
          'mod' || 'ctrl' || 'control' => 'Ctrl',
          'alt' || 'option' => 'Alt',
          'shift' => 'Shift',
          final o => o,
        },
  ];
  final name = switch (key.toLowerCase()) {
    'arrowup' => '↑',
    'arrowdown' => '↓',
    'arrowleft' => '←',
    'arrowright' => '→',
    'esc' || 'escape' => 'Esc',
    final k when k.length == 1 => k.toUpperCase(),
    _ => '${key[0].toUpperCase()}${key.substring(1)}',
  };
  return [...mods, name].join(mods.contains('⌘') ? '' : '+');
}

/// Whether [expr], given where a block takes a list, reads as a condition
/// (true or false) and not as a list: a name of a variable that is no list,
/// a negation, or a comparison or a joining of conditions outside any
/// parentheses. A list written out, a call (`filter(…)`, also as a computed
/// state puts it, in parentheses) and a list variable are lists.
bool _readsAsCondition(String expr, Map<String, Json> variables) {
  var e = expr.trim();
  // The parentheses a computed state is read in.
  while (e.startsWith('(') && e.endsWith(')')) {
    var depth = 0, wraps = true;
    for (var i = 0; i < e.length - 1; i++) {
      if (e[i] == '(') depth++;
      if (e[i] == ')') depth--;
      if (depth == 0) {
        wraps = false;
        break;
      }
    }
    if (!wraps) break;
    e = e.substring(1, e.length - 1).trim();
  }
  if (e.startsWith('[')) return false;
  if (e == 'true' || e == 'false' || e.startsWith('!')) return true;
  if (RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(e)) return variables[e]?['type'] != 'list';
  var depth = 0;
  String? quote;
  for (var i = 0; i < e.length; i++) {
    final c = e[i];
    if (quote != null) {
      if (c == quote) quote = null;
      continue;
    }
    if (c == '"' || c == "'") {
      quote = c;
    } else if (c == '(' || c == '[' || c == '{') {
      depth++;
    } else if (c == ')' || c == ']' || c == '}') {
      depth--;
    } else if (depth == 0) {
      final two = i + 1 < e.length ? e.substring(i, i + 2) : '';
      if (two == '==' || two == '!=' || two == '&&' || two == '||' || two == '<=' || two == '>=') return true;
      if ((c == '<' || c == '>') && two != '=>') return true;
    }
  }
  return false;
}

/// What is said of a shortcut whose key is no key.
String _noKeyName(String combo) =>
    'No key "$combo". A shortcut names one key, after mod, ctrl, cmd, alt or shift joined by +: a letter, a digit or a character (?, /), '
    'or Enter, Escape (esc), Space, Tab, Backspace, Delete (del), left, right, up, down, Home, End, PageUp, PageDown, F1 to F12: key mod+k, key alt+left.';

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
  // A one-time code: one field drawn as boxes (CodeInput @code length=6 digits).
  'CodeInput': (type: 'textField', node: {}),
  // A number between a minus and a plus button, in one border (NumberInput @seats min=1 max=500).
  'NumberInput': (type: 'textField', node: {}),
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
  // A filter chip keeps whether it is on (forms.md: a tap toggles it,
  // written back through its binding).
  'filterChip': (prop: 'selected', type: 'boolean', start: false),
  'textField': (prop: 'initialValue', type: 'text', start: ''),
  'dropdown': (prop: 'value', type: 'text', start: ''),
  'radio': (prop: 'groupValue', type: 'text', start: ''),
  'segmentedButton': (prop: 'selected', type: 'text', start: ''),
  'datePicker': (prop: 'value', type: 'text', start: ''),
  'timePicker': (prop: 'value', type: 'text', start: ''),
  // A date (time) field of the form words: `DateTimeInput @due mode=date`
  // (round 11b: "binds nothing" in 2 builds).
  'dateTimeInput': (prop: 'value', type: 'text', start: ''),
  // The page shown, from 0: a swipe writes it, and setting it turns the page.
  'pageView': (prop: 'initialPage', type: 'decimal', start: 0),
};

const _shortKeys = notationShortKeys;
/// Keys a model reaches for that a type spells otherwise.
const _typeKeys = notationTypeKeys;

/// What a value worked out (`Progress {done/total}`) is shown as on a type
/// that shows a value but takes no input.
const Map<String, String> _shownValue = {'progressBar': 'value', 'circularProgressIndicator': 'value', 'radialGauge': 'value', 'text': 'text'};

/// The short names a design system's component of the same name replaces.
const _softNames = {'CodeInput', 'DataTable', 'Handle', 'NumberInput', 'Gauge', 'Dial', 'Ring', 'Sparkline', 'Avatar', 'Donut', 'DonutChart', 'PieChart', 'Pie', 'AreaChart'};

/// What a line starting with [written] is, as its bindings read it: the
/// node type, and the design system's component when it is one.
({String type, WidgetSpec? component}) notationLineType(String written, Catalog catalog) {
  final short = _softNames.contains(written) && catalog.widget(written) != null ? null : notationTypes[written];
  final type = short?.type ?? '${written[0].toLowerCase()}${written.substring(1)}';
  final component = short == null && (catalog.widget(type) == null || notationComponentFirst.contains(written)) && catalog.widget(written) != null;
  return component ? (type: written, component: catalog.widget(written)) : (type: type, component: null);
}

/// The value a variable bound to the value of a node of [type] starts at
/// (a slider's 0, a toggle's false, a field's ""), or null when that type
/// keeps no value.
Object? notationValueStart(String type) => _valueProps.containsKey(type) ? (_valueProps[type]!.start ?? '') : null;

/// Whether a `state` line naming [name] is refused: `device` (read-only
/// input) and the names the runtime gives every expression of a screen
/// (`theme`, `data`, `route`…).
bool notationRefusedState(String name) => name == 'device' || _Parser._screenScopes.contains(name);

/// Whether a node of [type] shows a value and keeps none (a progress bar, a
/// gauge, a text).
bool notationShowsValue(String type) => _shownValue.containsKey(type);

/// The core types a design system's component of the same name replaces: a
/// design system's own `Tabs` (a row of labels that keeps the open one in a
/// variable, `Tabs @tab tabs=["Overview","Activity"]`) is what the line
/// means, not the core `tabs` node (titles over children, which the
/// notation does not teach).
const notationComponentFirst = {'Tabs'};

/// What `resizable` on a pane is said with: the base has a Splitter, which
/// keeps the pane's width in a variable the pane reads (round 10, R50).
const _resizable = 'A pane is resized by a Splitter beside it, which keeps its width in a variable the pane reads: '
    'state listW=300, Pane w={listW}, then Splitter @listW min=240 max=480 after it (pane=after when the pane comes after the Splitter).';

/// The colors of a chart's series or slices that write none, after the
/// accent.
const _chartColors = ['#FF0891B2', '#FF9333EA', '#FF16A34A', '#FFEA580C', '#FF9CA3AF', '#FFDB2777'];

/// The colors of a chart's slices or series from the theme's [accent]: the
/// accent, then lighter steps of it toward white, then darker ones (round 11:
/// a donut drew in colors no theme had). A name that is no color value
/// gives the fixed palette after it.
List<String> notationChartShades(String accent) {
  final m = RegExp(r'^#([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})$').firstMatch(accent);
  if (m == null) return [accent, ..._chartColors];
  final rgb = [for (var i = 2; i <= 4; i++) int.parse(m[i]!, radix: 16)];
  String mix(double t, int to) => '#FF${[for (final c in rgb) (c + (to - c) * t).round().clamp(0, 255).toRadixString(16).padLeft(2, '0')].join().toUpperCase()}';
  return [accent, mix(0.35, 255), mix(0.6, 255), mix(0.78, 255), mix(0.3, 0), mix(0.5, 0), mix(0.88, 255)];
}

/// A step of a chart's axis for values up to [max] in [lines] steps: 1, 2,
/// 2.5 or 5 times a power of ten, the smallest that reaches [max].
num _axisStep(num max, int lines) {
  if (max <= 0) return 1;
  final raw = max / lines;
  var p = 1.0;
  while (p * 10 <= raw) {
    p *= 10;
  }
  while (p > raw) {
    p /= 10;
  }
  for (final f in const [1, 2, 2.5, 5, 10]) {
    if (p * f * lines >= max) return p * f;
  }
  return p * 10;
}

String _axisLabel(num v) => v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);

/// The verbs an action is written with (design 13 section 3), beside
/// `name=value` and `cond ? a : b`; every other action is its type and its
/// fields by name. The reference documents each (tool/reference).
const Set<String> notationVerbs = {..._Parser._verbs, 'blur', 'confirm'};

/// A verb's other spelling the parser reads, by the verb it is.
const Map<String, String> notationVerbAliases = {'unfocus': 'blur'};

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

/// [root] with [value] at [path] (`style.height`, `fills[0].color`): the maps
/// and lists on the way made, or copied where they were another value.
void _setPath(Json root, String path, Object? value) {
  final segments = [
    for (final s in path.split('.'))
      (name: RegExp(r'^[^\[]*').stringMatch(s)!, indices: [for (final m in RegExp(r'\[(\d+)\]').allMatches(s)) int.parse(m[1]!)]),
  ];
  Object? container = root;
  for (var i = 0; i < segments.length; i++) {
    final (:name, :indices) = segments[i];
    final last = i == segments.length - 1;
    // The steps of this segment: its name in a map, then its indices.
    final steps = <Object>[name, ...indices];
    for (var j = 0; j < steps.length; j++) {
      final step = steps[j];
      final end = last && j == steps.length - 1;
      final nextIsIndex = j + 1 < steps.length;
      Object? fresh() => nextIsIndex ? <Object?>[] : <String, Object?>{};
      if (step is String) {
        final m = container as Map;
        if (end) {
          m[step] = value;
          return;
        }
        var next = m[step];
        if (nextIsIndex ? next is! List : next is! Map) next = m[step] = fresh();
        if (next is Map && next is! Map<String, Object?>) next = m[step] = next.cast<String, Object?>();
        container = next;
      } else {
        final l = container as List;
        final at = step as int;
        while (l.length <= at) {
          l.add(<String, Object?>{});
        }
        if (end) {
          l[at] = value;
          return;
        }
        var next = l[at];
        if (nextIsIndex ? next is! List : next is! Map) next = l[at] = fresh();
        container = next;
      }
    }
  }
}

/// [root] without the field at [path] where it is null (`key=null`): the
/// maps it was in taken out with it when nothing else is left in them. A
/// path through a list's element is left as it is.
void _removePath(Json root, String path) {
  if (path.contains('[')) return;
  final parts = path.split('.');
  final maps = <Map>[root];
  for (final p in parts.take(parts.length - 1)) {
    final next = maps.last[p];
    if (next is! Map) return;
    maps.add(next);
  }
  if (!maps.last.containsKey(parts.last) || maps.last[parts.last] != null) return;
  maps.last.remove(parts.last);
  for (var i = maps.length - 1; i > 0 && maps[i].isEmpty; i--) {
    maps[i - 1].remove(parts[i - 1]);
  }
}

/// [s] without the double quotes around it, if it has them.
String _unquoted(String s) => s.length >= 2 && s.startsWith('"') && s.endsWith('"') ? s.substring(1, s.length - 1) : s;

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
const _textStyleKeys = notationTextStyleKeys;

/// Keys written on an Input that belong to the style of its typed text.
const _fieldStyleKeys = notationFieldStyleKeys;

const _layoutKeys = {'width', 'height', 'padding', 'margin', 'flex', 'aspectRatio', 'x', 'y', 'align', 'constraints', 'order', 'basis'};
const _borderSides = {
  'border-bottom': 'bottom', 'border-top': 'top', 'border-left': 'left', 'border-right': 'right', //
  'borderBottom': 'bottom', 'borderTop': 'top', 'borderLeft': 'left', 'borderRight': 'right', 'border-b': 'bottom', 'border-t': 'top', 'border-l': 'left', 'border-r': 'right',
};
const _mainWords = {'start': 'start', 'center': 'center', 'end': 'end', 'between': 'spaceBetween', 'around': 'spaceAround', 'evenly': 'spaceEvenly'};
/// A flag word written with `=true` or `=false` (after a size's condition or
/// not): the condition, the word, the value.
final _flagKey = RegExp(r'^((?:[a-z][A-Za-z0-9]*\.)+)?(scroll|stretch|top|bottom|middle|center|left|right|start|end|between|around|evenly)=(true|false)$');

const _crossWords = {'top': 'start', 'left': 'start', 'middle': 'center', 'bottom': 'end', 'right': 'end', 'stretch': 'stretch'};

/// What the notation already has under [word], in one line with its
/// signature, or null when it has nothing a writer's definition would hide:
/// a type of the notation or of the catalog (`Card`, `Text`), a page word
/// (`App`, `Rail`, `Footer`), a heading (`H2`), or a name [vocabulary]'s
/// alias table reads as one of those (`Shortcut`, a `key` line). A design
/// system's component (a page's definition may replace it, docs/design/20
/// section 6) and a word the design system defines are not.
///
/// The owner's decision (2026-11-18): a built-in word wins. A page's or a
/// site's `define`, `primitive` or component of such a name is not used,
/// and is said at the definition (before, `primitive Shortcut` turned every
/// shortcut of test 10's kanban board into a labelled box, and `define Card`
/// was not used, with no word).
String? notationBuiltInWord(String word, {Catalog? catalog, NotationVocabulary vocabulary = NotationVocabulary.core}) {
  if (word.isEmpty) return null;
  final c = catalog ?? Catalog.current;
  if (PageWords.words.contains(word)) return '$word, a word of the page (its frames and their lines: App, Sidebar, Rail, Main, Nav, Section, Footer, Dialog…): $word …';
  if (RegExp(r'^H[1-4]$').hasMatch(word)) return '$word, a heading: $word "text"';
  final lower = '${word[0].toLowerCase()}${word.substring(1)}';
  final type = notationTypes[word]?.type ?? (c.widget(lower) != null ? lower : null);
  if (type != null) return '$word, a word of the notation (a $type): $word "text" key=value …';
  if (vocabulary.types[word] case final a? when !vocabulary.definitions.containsKey(word)) {
    return switch (a.line) {
      'shortcut' => '$word, read as the notation\'s shortcut line: key mod+k onPress={…}',
      'computed' => '$word, read as a state line: state total={…}',
      'confirmDialog' => '$word, read as a Dialog with a Cancel and a Confirm button: $word#id "Title" "Message" onConfirm={…}',
      final String l => '$word, read as the notation\'s $l line',
      null => '$word, read as the notation\'s ${a.to}${a.variant == null ? '' : '.${a.variant}'}',
    };
  }
  return null;
}

/// What is said at a writer's definition of [word], which [builtIn]
/// ([notationBuiltInWord]) says the notation has: it is not used.
String notationBuiltInDefinition(String word, String builtIn, {String kind = 'definition'}) =>
    'The notation already has $builtIn. So this $kind of $word is not used: $word is the notation\'s. '
    'If it is meant to be something else, give it a name of its own (My$word).';

/// [text] in the compact notation as a layout document. Never throws: what
/// cannot be read is reported and skipped.
///
/// A word [text] defines (`define Word …` at the margin) holds for the whole
/// text, before or after its uses (docs/design/20-defined-words.md section
/// 7). [definitions] is more text whose `define` blocks hold here too, as the
/// text's own (an answer's other screens): what is wrong in them is said where
/// they are read, not here.
NotationResult parseNotation(String text, {Catalog? catalog, NotationOptions options = const NotationOptions(), String? definitions}) =>
    _Parser(catalog ?? Catalog.current, options).parse(text, definitions: definitions);

/// The notation read as it arrives: [add] takes text in any chunks and
/// returns the edit operations of the lines completed so far (a `set` per
/// node under its parent, `vars` for the state a line introduced), ready
/// for `applyOps`; [close] gives the last line's.
///
/// A line is sent once, so a word defined in the text (`define Word …`) holds
/// from where its definition is written on: a use above it was read without
/// it, and the definition says so. [parseNotation] reads a text's definitions
/// before its first line.
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
    text.substring(0, end).split('\n').forEach(_parser._readLine);
    return _take();
  }

  List<Json> close() {
    final rest = _buffer.toString();
    _buffer.clear();
    if (rest.isNotEmpty) _parser._readLine(rest);
    _parser.finish();
    // A text with no line of a node (a print that says its document on the
    // `document {…}` line): the screen is sent now, as its first line would.
    if (!_parser._canvas && _parser._widget == null && !_parser._noCanvas) {
      _parser._canvas = true;
      _parser.ops
        ..add({'op': 'roots', 'roots': _parser._rootIds})
        ..add({'op': 'set', 'id': _parser.options.screen, 'node': _parser._canvasNode..remove('slots')});
    }
    // What the end of the text does (design 22, 4.5): each line's tail merged
    // again over what later lines added, the nodes a tail took away, the
    // canvas lines' words; sent as patches and removals.
    final removed = <String>[];
    final patched = <String, Json>{};
    _result = _parser._end(changed: (p, id, before) {
      final now = p.nodes[id];
      if (now == null) {
        removed.add(id);
        return;
      }
      final d = diffPatch(before ?? const {}, now);
      if (d == null) return;
      for (final k in const ['children', 'slots', 'type', 'id']) {
        d.remove(k);
      }
      if (d.isNotEmpty) patched[id] = d;
    });
    for (final p in [_parser, ..._parser._overlays]) {
      final c = p._canvasPatch;
      if (c == null) continue;
      final d = {...c}..remove('slots')..remove('type');
      if (d.isNotEmpty) patched[p.options.screen] = mergePatch(patched[p.options.screen] ?? const {}, d, keepNulls: true);
    }
    // A `document {…}` line's nodes: patched, taken away, or new (a print
    // that says a whole document on that line: its nodes set, then placed
    // under their parents as its children and slots say).
    final known = {
      for (final p in [_parser, ..._parser._overlays]) ...p.nodes.keys,
    };
    final added = <String, Json>{};
    final placed = <Json>[];
    for (final e in (readMap(_parser._documentPatch?['nodes']) ?? const {}).entries) {
      if (e.value == null) {
        removed.add(e.key);
      } else if (readMap(e.value) case final Json d) {
        final fresh = !known.contains(e.key) && d['type'] is String;
        if (fresh) added[e.key] = {...d}..removeWhere((k, _) => k == 'children' || k == 'slots');
        if (d['children'] case final List c) {
          for (var i = 0; i < c.length; i++) {
            if (c[i] is String) placed.add({'op': 'move', 'id': c[i], 'parent': e.key, 'index': i});
          }
        }
        for (final s in (readMap(d['slots']) ?? const {}).entries) {
          if (s.value is String) placed.add({'op': 'move', 'id': s.value, 'parent': e.key, 'slot': s.key});
        }
        if (fresh) continue;
        final p = {...d}..removeWhere((k, _) => const {'children', 'slots', 'type', 'id'}.contains(k));
        if (p.isNotEmpty) patched[e.key] = mergePatch(patched[e.key] ?? const {}, p, keepNulls: true);
      }
    }
    for (final e in added.entries) {
      _parser.ops.add({'op': 'set', 'id': e.key, 'node': e.value});
    }
    for (final e in patched.entries) {
      _parser.ops.add({'op': 'patch', 'id': e.key, 'patch': e.value});
    }
    _parser.ops.addAll(placed);
    if (readList(_parser._documentPatch?['roots']) case final List r when r.every((x) => x is String)) {
      _parser.ops.add({'op': 'roots', 'roots': r});
    }
    // Its variables, declared in their scopes.
    for (final e in (readMap(_parser._documentPatch?['variables']) ?? const {}).entries) {
      final set = <String, Object?>{
        for (final v in readList(e.value) ?? const [])
          if (readMap(v) case final Json m when m['name'] is String) m['name']! as String: {...m}..remove('name'),
      };
      if (set.isNotEmpty) _parser.ops.add({'op': 'vars', 'scope': e.key, 'set': set});
    }
    if (removed.isNotEmpty) _parser.ops.add({'op': 'remove', 'ids': removed});
    return _take();
  }

  NotationResult? _result;

  /// After [close]: what parseNotation gives for the whole text, for what
  /// no operation carries (the document's `id`, `schema`, a component's
  /// declaration and previews, a `document {…}` line).
  NotationResult? get result => _result;

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

  /// `cols={…}`: the column count worked out from the state (a formula).
  String? colsFormula;
  num gap = 8;

  /// `mainAxisExtent=30`, `childAspectRatio=2` (Flutter's names): a cell's
  /// height, or its width over its height.
  final cellLayout = <String, num>{};
  String? row;
  int inRow = 0;
  int rows = 0;

  /// `tablet.cols=2`: the column count at other widths, the rules of the
  /// grid of an `each` (docs/design/22, 2.4), with the line and column they
  /// were written at (cells written one by one stay in their rows: said).
  final mediaCols = <Json>[];
  int mediaLine = 0, mediaColumn = 0;
  bool mediaSaid = false;
}

/// A line as written: its indentation, its first word (null for an `if` or
/// an `each`) and, when the word stands in, its record.
class _Src {
  _Src(this.indent, this.word);
  final int indent;
  final String? word;
  VocabularyUse? use;
}

/// A list's universal words (docs/design/21 section 4.1), written on the
/// line whose lines come from an `each`: each word with its value (an
/// event's actions) and column, and the line they are on, to record them by
/// once the `each` under it reads them (or does not).
class _ListWords {
  _ListWords(this.words, this.line, this.source, this.on, this.path, {this.standIn = false});
  final Map<String, ({String value, int column})> words;
  final int line;
  final String source, on;
  final List<String> path;

  /// Written on a stand-in: what it does not read stays in its record.
  final bool standIn;
  bool applied = false;
  String? value(String word) => words[word]?.value;
}

/// A stand-in or a primitive's use, as [_Parser._silence] reads it: its
/// word, whether it is a primitive's (its first child its label), at the top
/// of the page, and whether its line gives a text or a size.
typedef _Silent = ({String word, bool primitive, bool top, int said, bool sized});

class _Open {
  _Open(this.indent, this.id, this.type,
      {this.condition, this.grid, this.each, this.list, this.pages, this.leaf = false, this.slots = const [], this.written, this.slot, this.splice = false});

  /// The lines of a defined word written where its use is ([notationSplice]):
  /// they go in the node around it, [id].
  final bool splice;

  /// A `slot name` line under node [id]: the line under it goes in that slot.
  final String? slot;

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
  List<String> get _rootIds => [_top.options.screen, for (final o in _top._overlays) o.options.screen, ..._top._takenOverlays.keys];

  /// Where the variables are declared: on the page's canvas, or, once the
  /// page has overlays, for every canvas of the document (an overlay reads
  /// and sets the page's values).
  /// `document scope=page_variables` says which.
  String get _scope => _top._documentWords['scope'] as String? ?? (_top._overlays.isEmpty ? options.screen : 'page_variables');

  bool _taken(String id) {
    final top = _top;
    return [top, ...top._overlays].any((p) => p.nodes.containsKey(id) || p.options.screen == id) || top._takenOverlays.values.any((o) => o.containsKey(id));
  }

  /// Whether the notation reads with no theme of its own (no design
  /// system): what it draws by itself in an overlay (its panel, its title)
  /// then takes the site's theme's roles, `surface` and `onSurface`.
  bool get _themeless => identical(options.card, defaultCard) && options.surface == '#FFFFFFFF';

  /// Whether a line is still open over the next ones.
  bool get _continues => _pending != null || _open != null;

  /// The canvas of this parser's nodes.
  Json get _canvasNode {
    final o = _overlay;
    Json look() {
      // A website's canvas is its Page's ground, to the window's foot (white
      // showed under a short page, round 11).
      if (o == null && _root != null && _roles[_root] == 'page') {
        if (readList(readMap(nodes[_root]?['decoration'])?['fills']) case final List fills when fills.isNotEmpty) return {'fills': _copyValue(fills)};
      }
      if (o == null || o.kind == 'canvas') return _surface;
      if (!o.surface) {
        return {
          'fills': [
            {'color': '#00FFFFFF'},
          ],
        };
      }
      return {
        // With no theme of its own the notation draws an overlay in the
        // site's theme's surface (a role: dark in dark mode), not in white.
        'fills': _themeless
            ? [
                {'color': 'surface'},
              ]
            : _copyValue(readMap(options.card['decoration'])?['fills']) ?? _surface['fills'],
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
      if (o != null && o.kind != 'canvas') 'name': o.id,
      if (_root != null) 'slots': {'body': _root},
      'layout': {'width': o?.width ?? options.width, 'height': o?.action.containsKey('snapHeights') == true ? {'fill': 0} : _canvasHeight},
      if (o?.guard case final String guard)
        'bind': {'props.blockBack': _formula(guard)}
      else if (o == null && _blockBack != null)
        'bind': {'props.blockBack': _blockBack},
      'decoration': look(),
      if (_timers.isNotEmpty) 'actions': [..._timers],
    };
  }

  /// A top-level `Dialog#id`, `Sheet#id`, `Drawer#id`, `Menu#id`,
  /// `Popover#id` or `Lightbox#id` line: the lines under it are a canvas of
  /// their own, which `open <id>` shows over the page.
  void _openBlock(Overlay o) {
    // One a component this page calls wrote: the page's own is the one shown.
    if (_top._takenOverlays.remove(o.id) case final Json taken) {
      if (_top._canvas) {
        _top.ops
          ..add({'op': 'remove', 'ids': [...taken.keys]})
          ..add({'op': 'roots', 'roots': _rootIds});
      }
    }
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
    // A guarded overlay with a question: what would close it (blocked while
    // the guard holds, it runs the canvas's back reactions) asks it first.
    if (o.guard != null && o.onBack != null) {
      sub._timers.add({
        'trigger': {'type': 'backPressed'},
        'actions': sub._actions(o.onBack!, 1),
      });
    } else if (o.guard != null && o.guardText != null) {
      final discard = o.onDiscard == null || o.onDiscard!.isEmpty ? '' : '${o.onDiscard}; ';
      sub._timers.add({
        'trigger': {'type': 'backPressed'},
        'actions': sub._actions('confirm ${o.guardText} ok="Discard" cancel="Keep editing" danger then {${discard}close}', 1),
      });
    }
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
      // Its own (`shotsAt`, `shotsZoom`); a name the line gave is the page's.
      if (e.key.startsWith(notationIdWord(o.id))) _top._internal.add(e.key);
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

  /// The words defined in the notation (docs/design/20-defined-words.md),
  /// written out as the lines they stand for before a line is read; and,
  /// while those lines are read, where they are written (`StickyNote.txt:3`).
  late final DefinedWords _defined = DefinedWords(
    options.vocabulary.definitions,
    open: options.openVocabulary,
    record: (kind, word, on, value, column) => _use(kind, word, column, on: on, value: value),
    issue: _issue,
    ours: _ownType,
    component: _componentNames,
    // One count for the page and its overlays: a use's id is the page's.
    counts: identical(_top, this) ? null : _top._defined.counts,
    // The page's own words hold in its overlays too.
    page: identical(_top, this) ? null : _top._defined.page,
    variable: (name) => variables.containsKey(name) || _stack.any((o) => o.each == name),
    internal: (name) => _top._internal.add(name),
    builtIn: (word) => switch (_builtIn(word)) { final what? => notationBuiltInDefinition(word, what), _ => null },
    bindsVariable: (name, column, start) => _bindsVariable(name, column, () {
      if (start == null) return '';
      final v = _value(start.trim());
      return v is String && v.contains(r'${') ? '' : v;
    }),
    // A page's own definition of a word the design system defines too is
    // the one read there: the record says so (`of`).
    // A primitive's use (`primitive Word …`) is recorded as one: it stands
    // in, it is not a word we have. A page's own definition of a component's
    // word replaces the component there (docs/design/20 section 6).
    used: (d, parts, node, column) => _use(d.primitive ? 'primitive' : 'definition', parts.word, column,
        to: d.label,
        node: _bareRoot(d, parts, node),
        parts: parts,
        of: d.file != 'page'
            ? null
            : options.vocabulary.definitions[d.word] != null
                ? 'page, over ${options.vocabulary.definitions[d.word]!.first.file}'
                : _componentNames(d.word) != null && d.name == null
                    ? 'page, over the ${d.word} component'
                    : null),
    slot: (d, word, column) => _use(d.primitive ? 'primitive' : 'definition', word, column, to: '${d.label} slot'),
  );
  String? _from;

  /// The lines a line of the text stands for once the defined words are
  /// written out, each with where it is written.
  Iterable<(PageLine, String?)> _definedLines(int indent, String text) sync* {
    for (final d in _defined.rewrite(indent, text, line: _line)) {
      final lines = _pages.rewrite(d.indent, d.text);
      _shadowed(d.text, lines);
      for (final l in lines) {
        yield (l, d.from);
      }
    }
  }

  /// Says so when [text] calls a component by a name that is also a page
  /// word (`Footer`, `Sidebar`, `Header`) and the page words read it as
  /// theirs ([lines] is not the line as written): the component is not
  /// called.
  void _shadowed(String text, List<PageLine> lines) {
    final word = RegExp(r'^([A-Z][A-Za-z0-9]*)').firstMatch(text.trimLeft())?[1];
    if (word == null || !options.ownComponents.contains(word) || !PageWords.words.contains(word) || catalog.widget(word) == null) return;
    if (RegExp('(^|\\s)type=$word(\\s|\$)').hasMatch(text)) return;
    final head = RegExp(r'^([A-Z][A-Za-z0-9]*)').firstMatch(lines.firstOrNull?.text.trimLeft() ?? '')?[1];
    if (lines.length == 1 && head == word) return;
    _issue(
        1 + (text.length - text.trimLeft().length),
        '$word is a word of the notation here (a frame of the page), so the component $word is not called: '
        'call it as $word type=$word, or give the component a name of its own (Site$word).');
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
    _ListWords? at,
  }) {
    if (_top._quiet) return null;
    final line = at?.line ?? _line, source = at?.source ?? _src, path = at?.path ?? _srcPath;
    // A universal word (docs/design/21) is recorded only with the open
    // vocabulary, and in a defined word's lines by the use that gave it.
    if (kind == 'universal' && (!options.openVocabulary || (_from != null && at == null))) return null;
    // A definition is not an answer: a word in its lines we do not have is
    // an issue there, open or not.
    if (_from != null && at == null && kind != 'children' && kind != 'verb') {
      if (kind == 'event') {
        _issue(column, '${on == null ? '' : '$on: '}"$word" is not an event the notation has here. Events: $_eventsTaught.');
      } else if (kind != 'alias') {
        _issue(column, '${on == null ? '' : '$on: '}"$word" is not a ${kind == 'type' ? 'type' : kind} the notation has.');
      }
      return null;
    }
    if (!_useKeys.add('$line:$column:$kind:$word')) return null;
    final VocabularyUse use;
    if (kind == 'alias') {
      use = aliasUse(of: of ?? 'type', word: word, to: to ?? '', source: source, line: line, column: column, on: on, value: value, path: path);
    } else if (kind == 'universal') {
      use = universalUse(of: of ?? universalKindOf(word), word: word, source: source, line: line, column: column, on: on, value: value, path: path);
    } else {
      final all = parts?.parts ?? const <LinePart>[];
      use = VocabularyUse(
        kind: kind,
        word: word,
        source: source,
        line: line,
        column: column,
        on: on,
        value: value,
        to: to,
        of: of,
        node: node,
        path: path,
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

  /// Whether [word] is a type the notation, the catalog or the page words
  /// have, or a word defined in the notation.
  bool _knowsType(String word) => _ownType(word) || _defined.has(word);

  /// Whether [word] is a type of the notation itself, the catalog or the
  /// page words: no definition changes what such a word means.
  /// What the notation has under [word] that a writer's definition does not
  /// replace ([notationBuiltInWord]); null for a design system's component,
  /// which a page's own definition may replace.
  String? _builtIn(String word) =>
      _componentNames(word) != null ? null : notationBuiltInWord(word, catalog: catalog, vocabulary: options.vocabulary);

  bool _ownType(String word) =>
      notationTypes.containsKey(word) ||
      catalog.widget('${word[0].toLowerCase()}${word.substring(1)}') != null ||
      catalog.widget(word) != null ||
      PageWords.words.contains(word) ||
      RegExp(r'^H[1-4]$').hasMatch(word);

  /// The names the design system's component [word] takes (its props, its
  /// events, `@` when it keeps a value, `onChange` for its `onChanged`);
  /// null when [word] is no component, or is a type of the notation or the
  /// page words.
  Set<String>? _componentNames(String word) {
    if (notationTypes.containsKey(word) || PageWords.words.contains(word) || RegExp(r'^H[1-4]$').hasMatch(word)) return null;
    if (catalog.widget('${word[0].toLowerCase()}${word.substring(1)}') != null) return null;
    final spec = catalog.widget(word);
    if (spec == null) return null;
    return {
      for (final p in spec.props) p.key,
      for (final e in spec.events) e.key,
      if (spec.props.any((p) => p.type.isVariable)) '@',
      if (spec.events.any((e) => e.key == 'onChanged')) 'onChange',
    };
  }

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
    const statements = {'if', 'each', 'else', 'for', 'node', 'document', 'every', 'key', 'on', 'let', 'derived', 'const', 'var'};
    if (statements.contains(parts.word)) return [text];
    final written = parts.word;
    var changed = false;
    // A defined word (docs/design/20) reads its own parameters, unless an alias that names
    // what it requires reads this line as a word we have (RangeSlider with a
    // variable for each end is our Slider).
    if (_defined.has(written)) {
      final alias = table.types[written];
      final holds = alias != null && alias.to != null && alias.requires.isNotEmpty && alias.holdsOn(parts);
      if (!holds) return [_definedAliased(text, parts, column)];
    }
    if (!_ownType(written)) {
      final alias = table.types[written];
      if (alias == null) return [text];
      if (alias.line != null) {
        final lines = lineRewrites[alias.line]?.call(parts, text);
        if (lines == null || lines.isEmpty) return [text];
        _use('alias', written, column, of: 'line', to: lines.first);
        return lines;
      }
      if (alias.to == null || !_knowsType(alias.to!)) return [text];
      if (!alias.holdsOn(parts)) return [text];
      parts.word = alias.to!;
      // `"to": "Button.primary"`: its variant, unless the line writes one.
      if (alias.variant != null && parts.variant.isEmpty) parts.variant = '.${alias.variant}';
      changed = true;
      _use('alias', written, column, of: 'type', to: '${alias.to}${alias.variant == null ? '' : '.${alias.variant}'}');
      if (alias.add != null) {
        // Its words and fixed parameters, each unless the line writes it.
        for (final a in LineParts.of('X ${alias.add}')?.parts ?? const <LinePart>[]) {
          if (parts.parts.any((p) => p.kind == a.kind && (a.kind == 'pair' ? p.key == a.key : p.raw == a.raw))) continue;
          final tail = parts.parts.indexWhere((p) => p.kind == 'tail');
          parts.parts.insert(tail < 0 ? parts.parts.length : tail, a..at = -1);
        }
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
    // The line's first string read as a named parameter (`"$text": "label"`):
    // a type alias's own, or the table's for a component that takes no string.
    final firstString = parts.parts.indexWhere((p) => p.kind == 'string');
    if (firstString >= 0) {
      final component = _componentNames(type) != null && spec != null && notationStrings(spec).isEmpty;
      final named = table.parameters[type];
      final to = own[r'$text'] ?? (component && named != null ? named[r'$text'] : null);
      if (to != null && !parts.parts.any((p) => p.kind == 'pair' && p.key == to)) {
        final p = parts.parts[firstString];
        _use('alias', r'$text', column + (p.at < 0 ? 0 : p.at), of: 'parameter', to: to, on: type, value: p.raw);
        parts.parts[firstString] = LinePart.pair(to, p.raw);
        changed = true;
      }
    }
    for (var i = 0; i < parts.parts.length; i++) {
      final p = parts.parts[i];
      final col = column + (p.at < 0 ? 0 : p.at);
      if (p.kind == 'pair') {
        final key = p.key!;
        var to = own[key] ??
            (known(key) ? null : of(p.isEvent ? table.events : table.parameters, key) ?? (p.isEvent || spec == null ? null : parameterKin(key, known)));
        if (to == null || to == key) continue;
        // An alias to a choice (StatusBadge status → tone) holds for one of
        // its values; another, on a line with no string, is the line's text
        // (StatusBadge status="Open" is the badge that says Open).
        final choice = spec?.props.where((x) => x.key == to && x.type.kind == PropKind.enumeration).firstOrNull;
        final written = p.value!.startsWith('{') ? null : p.value!.replaceAll('"', '');
        if (choice != null && written != null && !choice.type.values.contains(written) && !parts.parts.any((x) => x.kind == 'string')) to = r'$text';
        // Never two of one name: the line's own is kept.
        if (!to.startsWith(r'$') && !to.startsWith('!') && parts.parts.any((x) => x.kind == 'pair' && x.key == to)) continue;
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

  /// [text], a use of a defined word, with the parameters, events and flags
  /// the alias table names for that word (`"parameters": {"Timeline":
  /// {"events": "items"}}`) read as the names its definitions take; a name
  /// one of its meanings takes is its own. Each is recorded. Only the word's
  /// own entries are read (`*` is for the words of the notation).
  String _definedAliased(String text, LineParts parts, int column) {
    final table = options.vocabulary;
    final word = parts.word;
    final params = table.parameters[word], events = table.events[word], flags = table.flags[word];
    final names = {
      for (final d in _defined.meanings(word)) ...[...d.parameters.keys, ...d.events, ...d.strings, if (d.bind != null) ...['@', d.bind!]],
    };
    var changed = false;
    // The line's first string read as a named parameter (`"$text": "title"`),
    // when no meaning of the word takes a string.
    final first = parts.parts.indexWhere((p) => p.kind == 'string');
    final textTo = params?[r'$text'];
    if (first >= 0 && textTo != null && _defined.meanings(word).every((d) => d.strings.isEmpty) && !parts.parts.any((p) => p.kind == 'pair' && p.key == textTo)) {
      final p = parts.parts[first];
      _use('alias', r'$text', column + (p.at < 0 ? 0 : p.at), of: 'parameter', to: textTo, on: word, value: p.raw);
      parts.parts[first] = LinePart.pair(textTo, p.raw);
      changed = true;
    }
    for (var i = 0; i < parts.parts.length; i++) {
      final p = parts.parts[i];
      final col = column + (p.at < 0 ? 0 : p.at);
      if (p.kind == 'pair' && !names.contains(p.key)) {
        final to = (p.isEvent ? events : params)?[p.key] ?? (p.isEvent ? null : parameterKin(p.key!, names.contains));
        if (to == null || to == p.key) continue;
        // Never two of one name: the line's own is kept.
        if (parts.parts.any((x) => x.kind == 'pair' && x.key == to)) continue;
        _use('alias', p.key!, col, of: p.isEvent ? 'event' : 'parameter', to: to, on: word, value: p.value);
        changed = true;
        parts.parts[i] = LinePart.pair(to, p.value!);
      } else if (p.kind == 'word' && !names.contains(p.raw)) {
        final to = flags?[p.raw];
        if (to == null || to == p.raw) continue;
        _use('alias', p.raw, col, of: 'flag', to: to, on: word);
        changed = true;
        parts.parts[i] = LinePart.word(to);
      }
    }
    return changed ? parts.toString() : text;
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

  /// In a design system's dialog frame with an `actions` slot (Desk's): the
  /// indent of its first lines, and of an `Actions` line among them moved
  /// into that slot (its band pinned under the body that scrolls), while
  /// the lines under it are read.
  int? _blockTop, _actionsAt;

  bool get _dialogTakesActions =>
      _blockHead.startsWith('Dialog') && _pages.isFrame('Dialog') && (catalog.widget('Dialog')?.slots.contains('actions') ?? false);

  /// While lines already read are read again (an overlay's, drawn again in
  /// its foot; a sidebar's, in its drawer): nothing is recorded twice.
  bool _quiet = false;

  /// A line read alone to work out its media rules' patches
  /// ([_mediaRules]): its own rules are not read again.
  bool _mediaLine = false;

  /// Whether a state named item read inside an each was said.
  bool _itemSaid = false;

  /// Line [base]'s media rules (docs/design/22 section 2.4): `hide=`/`show=`
  /// as they are, and each run of words with one condition (`phone.pad=16
  /// phone.gap=8`) a rule whose patch is what those words change on the line,
  /// read alone with and without them. A value written for a field [bound]
  /// binds is shown there: the binding is dropped where the rule holds.
  List<Json> _mediaRules(List<({Json condition, String? word, int column})> words, String base, String? parentType, String type, Iterable<String> bound) {
    final rules = <Json>[];
    final props = catalog.widget(type)?.props ?? const [];
    final reader = MediaLineReader(
      (text) => (_Parser(catalog, options._copy(reflow: false, openVocabulary: options.openVocabulary, vocabulary: options.vocabulary)).._mediaLine = true).parse(text),
      line: base,
      parentType: parentType,
      props: props,
      bound: bound,
    );
    for (var i = 0; i < words.length;) {
      final w = words[i];
      if (w.word == null) {
        rules.add(_copy(w.condition));
        i++;
        continue;
      }
      // A run: the words after it with the same condition are the same rule.
      final run = <String>[];
      while (i < words.length && words[i].word != null && jsonEquality.equals(words[i].condition, w.condition)) {
        run.add(words[i++].word!);
      }
      final read = reader.patch(run);
      for (final m in read.issues) {
        _issue(w.column, m);
      }
      if (read.patch case final Json patch) rules.add({...w.condition, 'patch': patch});
    }
    return rules;
  }

  /// Whether [text] (indented, with an id) is the head of an overlay: a
  /// word the page layer reads as one, itself or through an alias.
  bool _overlayInside(String text) {
    final word = RegExp(r'^[A-Za-z][A-Za-z0-9]*').stringMatch(text)!;
    const overlays = {'Dialog', 'Modal', 'Sheet', 'BottomSheet', 'Drawer', 'Menu', 'Popover', 'Popup', 'Lightbox'};
    // A design system's own Dialog called in a line is its component,
    // unless an `open` already names its id: then it is what that shows.
    if (overlays.contains(word)) {
      final id = RegExp('#($notationId)').firstMatch(text)?[1];
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
          var rel = indent - _blockIndent;
          if (!blank) {
            _blockTop ??= rel;
            if (_actionsAt != null && rel <= _actionsAt!) _actionsAt = null;
            // `Actions` among a dialog's own lines: into the frame's actions slot.
            if (_actionsAt == null && rel == _blockTop && RegExp(r'^Actions\b').hasMatch(raw.trim()) && _dialogTakesActions) {
              _feed(rel, 'slot actions');
              _actionsAt = rel;
            }
            if (_actionsAt != null) rel += 2;
          }
          _feed(rel, raw.trim());
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
          if (o.kind == 'canvas') _block?._canvasPatch = _canvasWords(head.replaceFirst(RegExp(r'^\S+'), ''));
          _blockIndent = indent;
          _blockHead = head.split(RegExp(r'\s')).first;
          _blockPrev = 0;
          _blockTop = _actionsAt = null;
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
    if (_componentLine(raw)) return;
    final indent = raw.length - raw.trimLeft().length;
    // (At the indent the page words move the node lines to: a box in a Nav
    // or a Section is two deeper than written.)
    if (_paintLine(indent + _pages.shiftAt(indent), raw.trim())) return _emit(null); // a node's custom paint or animation (paint_words.dart)
    var before = nodes.length;
    // `Badge.{ok ? "success" : "error"} "Pass"`: a variant worked out from
    // the state is the line's variant={…}.
    if (RegExp(r'^[A-Z][A-Za-z0-9]*\.\{').firstMatch(raw.trimLeft()) case final m?) {
      final t = raw.trim();
      final braced = (_Tokens(t)..at = m.end - 1).balanced();
      raw = '${' ' * indent}${t.substring(0, m.end - 2)} ${t.substring(m.end - 1 + braced.length).trim()} variant=$braced'.trimRight();
    }
    _track(indent, raw.trim());
    // A name read as a word the notation has (the alias table). A word that
    // is several lines is one only at the margin (an overlay's head, above).
    if (_aliased(raw.trim(), indent + 1) case [final String one] when one != raw.trim()) {
      raw = '${' ' * indent}$one';
    }
    // `Dots @page count=n`: a dot per page, the current one long and in the
    // accent; a tap on a dot goes to its page. Written out as the three
    // lines it stands for.
    // An answer that opens with `if` or `each` has several top-level parts
    // and no root to hold them: they stack in a column of their own.
    if (_root == null && indent == 0 && RegExp(r'^(if|each)\s').hasMatch(raw.trim())) {
      _lineAt(-1, 'Column gap=12', 0);
    }
    final dots = _dotsOf(raw.trim());
    if (dots == null && RegExp(r'^Dots(#[A-Za-z_][A-Za-z0-9_]*(?:-[A-Za-z0-9_]+)*)?\s.*\bbind=').hasMatch(raw.trim())) {
      _issue(indent + 1, 'A variable is bound with @: @name is the control\'s value, key=@name another property. Write: ${notationBindForm(raw.trim(), catalog: catalog)}');
    } else if (dots != null) {
      String look(String c) => c.startsWith('#')
          ? '"$c"'
          : const {'primary', 'onPrimary', 'surface', 'onSurface', 'error', 'success', 'warning'}.contains(c)
              ? 'theme.$c'
              : 'theme.colors.$c';
      final page = dots.page, count = dots.count.startsWith('{') ? dots.count.substring(1, dots.count.length - 1).trim() : dots.count;
      _bindsVariable(page, indent + 1 + raw.trim().indexOf('@'), () => 0);
      variables.putIfAbsent(page, () => {'name': page, 'type': 'decimal', 'value': 0});
      // Where the page's frames put the line (a Section moves its lines in):
      // read at the line's own place, the line after it was taken for one of
      // its dots' row (round 11: a carousel's next button 16 px high).
      final at = _pages.rewrite(indent, 'Row').first.indent;
      _lineAt(at, 'Row${dots.id} gap=6 center middle h=16${dots.rest}', indent + 1);
      _lineAt(at + 2, 'each dot in range($count)', indent + 3);
      _lineAt(at + 4, 'Box w={index==$page?16:6} h=6 radius=3 fill={index==$page?${look(options.accent)}:${look(options.track)}} onTap={$page=index}', indent + 5);
    } else {
      _from = null;
      for (var (l, from) in _definedLines(indent, raw.trim())) {
        _from = from;
        // A line a defined word stands for reads the alias table as the
        // page's lines do (`Input onSubmitted=` is onSubmit), unrecorded.
        if (from != null) {
          if (_aliased(l.text, l.indent + 1) case [final String one] when one != l.text) l = (indent: l.indent, text: one);
        }
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
        _lineAt(l.indent, role == null ? l.text : role[2] == 'splice' ? notationSplice : '${role[1]}${l.text.substring(role.end)}', l.indent + 1);
        if (role != null && _lastNode != null) _roles[_lastNode!] = role[2]!;
        // The lines a defined word stands for: each line's nodes are sent
        // before the next line's, which may patch them.
        if (from != null && nodes.length > before) {
          nodes.keys.skip(before).toList().forEach(_emit);
          before = nodes.length;
        }
      }
      _from = null;
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
    sidebarRail: options.reflow && options.width >= 700 ? options.sidebarRail : null,
    sectionPad: options.sectionPad,
    gutter: options.gutter,
    band: options.band,
    siteFill: options.siteFill,
    paneFill: options.paneFill,
    sideFill: options.sideFill,
    iconTile: options.iconTile,
    accentName: options.accent,
    accentText: options.accentText,
    accent: options.accent.startsWith('#') ? options.accent : '#FF2563EB',
    // A website's headline at a display size, unless the theme gives its
    // own headline one (a heading1 or pageTitle of 32 and up).
    siteHeadline: options.displaySizes['heading1'] != null || options.displaySizes['pageTitle'] != null ? null : 60,
    quietInks: options.quietInks,
    selectedFill: options.selectedFill,
    line: options.line,
    textVariants: options.textStyles.keys.toSet(),
    isComponent: (name) => notationTypes[name] == null && catalog.widget(name) != null,
    declares: (name) => catalog.widget(name) != null,
    isFrame: (name) => notationTypes[name] == null && catalog.widget(name)?.children == ChildModel.list,
    frameEvents: (name) => [for (final e in catalog.widget(name)?.events ?? const <EventSpec>[]) e.key],
    roles: true,
    menu: options.reflow && options.width >= 700,
    // Named so that no id an author writes (`Menu#albumMenu` on the album
    // page) is the drawer's.
    sidebarMenu: _host == null && options.reflow && options.width >= 700 ? '${options.screen.replaceAll('-', '_')}_sidebar' : null,
    surface: options.surface,
    themeRoles: options.roles,
    overlaySurface: identical(options.card, defaultCard) && options.surface == '#FFFFFFFF' ? 'surface' : null,
    viewer: _host == null && options.width >= 700 ? '${options.screen.replaceAll('-', '_')}Viewer' : null,
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

  /// The lines written `keep` that are not a Grid's: the reflow leaves each,
  /// and what is in it, as written.
  final _keep = <String>{};

  /// The anchors (`id=why` on a line) by name → the node, and the scroll
  /// actions written, which name an anchor or an id.
  final _anchors = <String, String>{};
  final _scrolls = <Json>[];

  /// The names written `project name`: variables of the site, not of this screen.
  final Set<String> _projectVariables;
  final _tableRows = <String>{};

  /// On a page, the media rules that lay it out on a tablet and a phone.
  /// The foot of an app's window (`Footer` in Main or App) and the head of
  /// a pane (its first lines written `sticky`: a list's toolbar): Main or
  /// the Pane stops scrolling as a whole; what else is in it scrolls in a
  /// column that takes the room between the head and the foot, which stay
  /// in view at every width. A foot written in App goes to the foot of its
  /// Main. (A sticky head inside the scrolling pane was pinned 16 px down
  /// over the first row: test 9, mail.)
  void _feet() {
    final feet = <String, String>{};
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
      feet[main] = foot;
    }
    for (final main in [
      for (final e in _roles.entries)
        if (e.value == 'main' || e.value == 'pane') e.key,
    ]) {
      final m = nodes[main];
      if (m == null) continue;
      final props = (m['props'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
      if (props['scrollable'] != true) continue;
      final kids = ((m['children'] as List?) ?? const []).whereType<String>().toList();
      final foot = feet[main];
      // A line in it that takes the room left (`grow`, `h=fill`: a board's
      // lanes, a list that scrolls itself) has a height only in a pane that
      // does not scroll: the pane is then a plain column (it was an
      // unbounded height and an error: test 9, kanban 7).
      bool takesRoom(String k) {
        final l = readMap(nodes[k]?['layout']);
        return (l?['flex'] is num && (l!['flex'] as num) > 0) || (l?['height'] is Map && (l!['height'] as Map).containsKey('fill'));
      }
      if (kids.any((k) => k != foot && takesRoom(k))) {
        props.remove('scrollable');
        m['props'] = props;
        if (_canvas) ops.add({'op': 'patch', 'id': main, 'patch': {'props': {'scrollable': null}}});
        continue;
      }
      // Its head: the lines at its top written sticky (pinned at the top).
      final heads = <String>[];
      for (final k in kids) {
        if (nodes[k]?['sticky'] is! Map) break;
        heads.add(k);
      }
      if (foot == null && heads.isEmpty) continue;
      for (final h in heads) {
        nodes[h]!.remove('sticky');
      }
      final rest = [for (final k in kids) if (k != foot && !heads.contains(k)) k];
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
      m['children'] = [...heads, scroll, ?foot];
      if (_canvas) {
        ops
          ..add({'op': 'set', 'id': scroll, 'parent': main, 'index': heads.length, 'node': {...nodes[scroll]!}..remove('children')})
          ..addAll([for (var i = 0; i < rest.length; i++) {'op': 'move', 'id': rest[i], 'parent': scroll, 'index': i}])
          ..addAll([for (final h in heads) {'op': 'patch', 'id': h, 'patch': {'sticky': null}}])
          ..addAll([if (foot != null) {'op': 'move', 'id': foot, 'parent': main, 'index': heads.length + 1}])
          ..add({'op': 'patch', 'id': main, 'patch': {'props': {'scrollable': null, 'crossAxisAlignment': 'stretch'}}});
      }
    }
  }

  /// A button a dialog or a sheet ends with, not an icon's.
  bool _actionButton(String id) {
    final type = nodes[id]?['type'];
    return type is String &&
        (type == 'ActionButton' || type.endsWith('Button') && type != 'iconButton' && type != 'segmentedButton' && type != 'floatingActionButton');
  }

  /// The buttons a dialog or a sheet ends with are its actions. On a phone
  /// they fill its width in equal shares; with room, they sit at its right,
  /// each no wider than [_actionMax]. Written as a row of buttons, or as
  /// buttons one under another (then they are put in a row).
  static const num _actionMax = 240;

  void _endButtons() {
    final kind = _overlay?.kind;
    if (kind != 'dialog' && kind != 'sheet') return;
    final body = _root == null ? null : nodes[_root];
    final kids = [...?(body?['children'] as List?)?.whereType<String>()];
    if (body == null || kids.isEmpty) return;
    String row;
    List<String> buttons;
    final last = nodes[kids.last];
    final lastKids = [...?(last?['children'] as List?)?.whereType<String>()];
    if (last?['type'] == 'row' && lastKids.isNotEmpty && lastKids.every(_actionButton)) {
      final props = readMap(last!['props']) ?? const {};
      if (props['scrollable'] == true || props['wrap'] == true) return;
      row = kids.last;
      buttons = lastKids;
    } else {
      // Buttons written one under another at the end.
      var from = kids.length;
      while (from > 0 && _actionButton(kids[from - 1])) {
        from--;
      }
      buttons = kids.sublist(from);
      if (buttons.isEmpty) return;
      row = '${_root}Actions';
      if (nodes.containsKey(row)) return;
      nodes[row] = {
        'type': 'row',
        'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
        'props': {'spacing': 8, 'crossAxisAlignment': 'center'},
        'children': [...buttons],
      };
      body['children'] = [...kids.sublist(0, from), row];
      for (final b in buttons) {
        _parentOf[b] = row;
      }
      _parentOf[row] = _root!;
      if (_canvas) {
        ops
          ..add({'op': 'set', 'id': row, 'parent': _root, 'index': from, 'node': {...nodes[row]!}..remove('children')})
          ..addAll([for (var i = 0; i < buttons.length; i++) {'op': 'move', 'id': buttons[i], 'parent': row, 'index': i}]);
      }
    }
    void patch(String id, Json change) {
      nodes[id] = mergePatch(nodes[id]!, change);
      if (_canvas) ops.add({'op': 'patch', 'id': id, 'patch': change});
    }

    // The row is as wide as the overlay.
    final rowProps = readMap(nodes[row]!['props']) ?? const {};
    final align = rowProps['mainAxisAlignment'];
    // As a patch: fill takes hug's place (a merge would keep both).
    const share = {'flex': 1, 'width': {'fill': 0, 'hug': null}};
    if (_top.options.width < 700) {
      // A phone's own canvas: equal shares at once.
      patch(row, {'layout': {'width': {'fill': 0}}});
      for (final b in buttons) {
        patch(b, {'layout': share});
      }
      return;
    }
    patch(row, {
      'layout': {'width': {'fill': 0}},
      // At the right, unless the line says where (between, center).
      if (align == null || align == 'start') 'props': {'mainAxisAlignment': 'end'},
    });
    for (final b in buttons) {
      final node = nodes[b]!;
      if (node['media'] != null) continue;
      final layout = readMap(node['layout']) ?? const {};
      final fixed = layout['width'] is num;
      patch(b, {
        if (!fixed && readMap(layout['constraints'])?['maxWidth'] == null) 'layout': {'constraints': {'maxWidth': _actionMax}},
        'media': [
          {
            // An overlay's rules are read at its own width: narrower than
            // it was written is a phone, where it gives way to the window.
            'maxWidth': math.min(reflowPhoneMax, _overlay!.width - 1),
            'patch': {'layout': {...share, 'constraints': {'maxWidth': null}}},
          },
        ],
      });
    }
  }

  /// A component's root row of parts of their own size, or with a part
  /// that takes the room left (a mail row: a dot, the text that grows, a
  /// time): it keeps its layout wherever it is called, as written (reflow
  /// wrapped it on a phone, the dot above the text: test 9, mail 7).
  String? _componentRootKept() {
    if (_widget == null || _root == null) return null;
    final root = nodes[_root];
    if (root == null || root['type'] != 'row') return null;
    final kids = [for (final k in (root['children'] as List?) ?? const []) nodes[k]].whereType<Json>().toList();
    bool fixed(Json n) => readMap(n['layout'])?['width'] is num;
    bool grows(Json n) => switch (readMap(n['layout'])?['flex']) { final num f => f > 0, _ => false };
    final kept = kids.isNotEmpty && (kids.any(grows) || kids.every((k) => fixed(k) || k['type'] == 'text' || k['type'] == 'icon' || k['type'] == 'spacer'));
    return kept ? _root : null;
  }

  /// The rows written `wrap` whose wrapping went to the list of their
  /// `each` (its copies wrap, the list as wide as the row), with the row's
  /// own run spacing.
  final _wrapsMoved = <String, Object?>{};

  /// A row written `wrap` with more than its `each` in it (chips of labels,
  /// a divider, chips of people, a count): the row wraps again, and each of
  /// its lists of copies is a group as wide as its copies that wraps them
  /// within a line. The first list took the row's wrapping and its width,
  /// and the second had none: on a tablet the first list's chips stood in
  /// a column 96 wide and the second's ran over them (track C, kanban). On
  /// a page written for a desktop this holds narrower than a desktop only
  /// (the desktop's picture is as it was); on one written for a phone, at
  /// every width.
  void _rejoinWraps() {
    final narrow = options.reflow && options.width >= 700;
    void change(String id, Json patch) {
      final Json p = narrow
          ? {
              'media': [
                ...?(nodes[id]!['media'] as List?),
                {'maxWidth': reflowTabletMax, 'patch': patch},
              ],
            }
          : patch;
      nodes[id] = mergePatch(nodes[id]!, p);
      _patches.add({'op': 'patch', 'id': id, 'patch': p});
    }

    for (final e in _wrapsMoved.entries) {
      final row = nodes[e.key];
      final kids = [for (final k in (row?['children'] as List?) ?? const []) if (nodes[k] case final Json n) (k as String, n)];
      if (row == null || kids.length < 2) continue;
      final spacing = (row['props'] as Map?)?['spacing'] ?? 0;
      change(e.key, {
        'props': {'wrap': true, 'runSpacing': e.value ?? spacing},
      });
      for (final (id, n) in kids) {
        final p = n['props'] as Map?;
        // A spacer takes what its line leaves (CSS flex-grow from 0), as
        // it did beside the row's children on one line.
        if (n['type'] == 'spacer') {
          change(id, {
            'layout': {'basis': 0},
          });
          continue;
        }
        if (n['type'] != 'listView' || p?['scrollDirection'] != 'horizontal' || p?['scrollable'] == true) continue;
        change(id, {
          'layout': {'width': {'fill': null, 'hug': 0}},
          'props': {'wrap': true, 'wrapSpacing': spacing, 'runSpacing': e.value ?? spacing},
        });
        // A copy as tall as the row's line is as tall as itself on lines of
        // its own.
        for (final item in (n['children'] as List?) ?? const []) {
          if ((nodes[item]?['layout'] as Map?)?['height'] case final Map h when h.containsKey('fill')) {
            change(item as String, {
              'layout': {'height': {'fill': null, 'hug': 0}},
            });
          }
        }
      }
    }
  }
  /// A Select whose line wrote a fill or a border (`Select @version
  /// items=[…] fill=paper border=rule radius=7`; round 11b, the docs site's
  /// version switcher): the line's box is its frame, as an Input's `fill`,
  /// `border` and `radius` are its field's. The Select draws no frame of its
  /// own inside it (`underline: false`), its value and chevron are inset from
  /// the box's sides as in its own frame (unless the line wrote a `pad`), and
  /// the box's line takes the accent while the Select has the focus (unless
  /// the line wrote its focused look). It drew two boxes, one in the other.
  /// A labelled field whose line wrote a fixed height (`Input "Street
  /// address" "e.g. 11 Canynge Road" @a h=44`; round 11b, 8 builds): the
  /// height is its box's, a step of the control scale as the reference
  /// says, with its label above it (and room for its error below), as a
  /// Select of `h=44` beside it is 44. It was the height of the label and
  /// the box together: the box drew about 22 high. A field whose label is
  /// gone (a composer's, a toolbar's) is as it was; a height that already
  /// adds the label's room to the control height (`h=48` at 28) is too.
  void _labelledFieldHeights() {
    final extra = options.fieldLabel == null ? 20 : 23;
    for (final MapEntry(key: id, value: h) in _fieldHeights.entries) {
      final n = nodes[id];
      if (n == null || n['type'] != 'textField') continue;
      final layout = readMap(n['layout']) ?? const <String, Object?>{};
      if (layout['height'] != h) continue;
      final props = readMap(n['props']) ?? const <String, Object?>{};
      final d = readMap(props['decoration']) ?? const <String, Object?>{};
      final label = d['labelText'];
      final labelled = (label is String && label.isNotEmpty) || readMap(n['bind'])?['props.decoration.labelText'] != null;
      if (!labelled) continue;
      if (options.controlHeight case final c? when h == c + extra || h == c + extra + 18) continue;
      if (readMap(d['constraints']) != null) continue;
      final change = <String, Object?>{
        'layout': {
          'height': {'hug': 0},
        },
        'props': {
          'decoration': {
            'constraints': {'minHeight': h, 'maxHeight': h},
          },
        },
      };
      nodes[id] = mergePatch(n, change);
      if (_canvas) ops.add({'op': 'patch', 'id': id, 'patch': change});
    }
  }

  /// A child that fills, written so, in a row that wraps (`Row gap=24 top
  /// phone.wrap=true` over `Card w=392 phone.w=fill` and `Column grow
  /// phone.w=fill`; round 11b, 4 builds): where the row wraps it takes the
  /// whole line, as CSS's `width: 100%` in a wrapping row does; a run gives
  /// no room to fill, so it was held to its design number (0: a column 0
  /// wide, a card as narrow as its content). It is said as a basis longer
  /// than any line (a line's basis is cut to the line), at the widths the
  /// fill and the wrap both hold. A fill the line did not write (a field's,
  /// a component's) is as it was.
  void _wrapFills() {
    const line = 100000;
    bool horizontal(Json n) => n['type'] == 'row' || (n['type'] == 'flex' && readMap(n['props'])?['direction'] != 'vertical');
    bool isFill(Object? w) => w is Map && w.containsKey('fill') && (w['fill'] is num) && (w['fill'] as num) <= 0;
    for (final id in [...nodes.keys]) {
      final row = nodes[id]!;
      if (!horizontal(row)) continue;
      final always = readMap(row['props'])?['wrap'] == true;
      final wraps = [
        for (final r in (row['media'] as List?) ?? const [])
          if (r is Map && readMap(readMap(r['patch'])?['props'])?['wrap'] == true) r,
      ];
      if (!always && wraps.isEmpty) continue;
      bool wrapsWhere(Map rule) {
        if (always) return true;
        if (rule.containsKey('minWidth')) return wraps.any((w) => w['minWidth'] == rule['minWidth'] && w['maxWidth'] == rule['maxWidth']);
        final at = rule['maxWidth'];
        return at is num && wraps.any((w) => !w.containsKey('minWidth') && w['maxWidth'] is num && (w['maxWidth'] as num) >= at);
      }

      for (final cid in readStrings(row['children'])) {
        final c = nodes[cid];
        if (c == null) continue;
        final layout = readMap(c['layout']) ?? const <String, Object?>{};
        if (layout.containsKey('basis')) continue;
        Json? change;
        if (always && _writtenFills.contains(cid) && isFill(layout['width'])) {
          change = {
            'layout': {'basis': line},
          };
        }
        final rules = [for (final r in (c['media'] as List?) ?? const []) r is Map ? {...r.cast<String, Object?>()} : r];
        var ruled = false;
        for (var i = 0; i < rules.length; i++) {
          final r = rules[i];
          if (r is! Map<String, Object?>) continue;
          final patch = readMap(r['patch']);
          final l = readMap(patch?['layout']);
          if (l == null || !isFill(l['width']) || l.containsKey('basis') || !wrapsWhere(r)) continue;
          rules[i] = {
            ...r,
            'patch': {
              ...patch!,
              'layout': {...l, 'basis': line},
            },
          };
          ruled = true;
        }
        if (ruled) (change ??= <String, Object?>{})['media'] = rules;
        if (change == null) continue;
        nodes[cid] = {...mergePatch(c, {...change}..remove('media')), if (ruled) 'media': rules};
        if (_canvas) ops.add({'op': 'patch', 'id': cid, 'patch': change});
      }
    }
  }

  void _framedSelectsBare() {
    for (final id in _framedSelects) {
      if (_ownFrameSaid.contains(id)) continue;
      final n = nodes[id];
      if (n == null || n['type'] != 'dropdown') continue;
      final props = readMap(n['props']) ?? const <String, Object?>{};
      if (props.containsKey('underline')) continue;
      final d = readMap(n['decoration']) ?? const <String, Object?>{};
      final strokes = (d['strokes'] as List?) ?? const [];
      final fills = (d['fills'] as List?) ?? const [];
      if (strokes.isEmpty && fills.isEmpty) continue;
      final change = <String, Object?>{
        'props': {'underline': false},
      };
      final layout = readMap(n['layout']) ?? const <String, Object?>{};
      if (!layout.containsKey('padding')) {
        // The field's side padding at its step (SSUI's: 8 compact, 10 at 32 and up).
        final h = layout['height'];
        final side = h is num && h >= 32 ? 10 : 8;
        change['layout'] = {
          'padding': [side, 0, side, 0],
        };
      }
      final states = readMap(n['states']) ?? const <String, Object?>{};
      if (strokes.isNotEmpty && !states.containsKey('focused')) {
        change['states'] = {
          'focused': {
            id: {
              'decoration': {
                'strokes': [
                  {...?readMap(strokes.first), 'color': options.accent},
                ],
              },
            },
          },
        };
      }
      nodes[id] = mergePatch(n, change);
      if (_canvas) ops.add({'op': 'patch', 'id': id, 'patch': change});
    }
  }


  /// A text field in a row of buttons (the text input pass of round 11,
  /// codelessly_sdk docs/research/text-input-round-11.md), as a writer
  /// means it and as a web page draws it:
  /// - beside a button, a multi-line field is a composer: it starts at one
  ///   line and grows to its most (`multiline` alone: three lines tall,
  ///   empty);
  /// - a composer, a field among icon buttons (a toolbar's, a stepper's),
  ///   one field beside a text button (an inline entry: add an item, a
  ///   comment, a promo code; not the row that ends a form, whose field
  ///   writes a label and a hint) and a field in a framed row have no room
  ///   for a label above: the label is the hint, or, beside a hint, the
  ///   field's spoken name;
  /// - in a row with its own frame (a radius and a border or a fill) that
  ///   holds the field and its buttons (and icons, texts) alone, the field is bare:
  ///   the frame is its box (a bordered field drawn inside a bordered box);
  /// - a multi-line field with onSubmit sends on Enter (Shift+Enter: a new
  ///   line), where Enter only broke the line and onSubmit never ran.
  void _fieldsBesideButtons() {
    void patch(String id, Json change) {
      nodes[id] = mergePatch(nodes[id]!, change);
      if (_canvas) ops.add({'op': 'patch', 'id': id, 'patch': change});
    }

    for (final id in [...nodes.keys]) {
      final n = nodes[id]!;
      if (n['type'] != 'textField') continue;
      final props = readMap(n['props']) ?? const <String, Object?>{};
      if (props['otpLength'] case final num o when o > 0) continue;
      final maxLines = props['maxLines'];
      final multiline = (maxLines is num && maxLines != 1) || (props['minLines'] is num && (props['minLines']! as num) > 1);
      final change = <String, Object?>{};
      final propsChange = <String, Object?>{};
      final bindChange = <String, Object?>{};
      // Enter sends, Shift+Enter breaks the line.
      final submits = ((n['actions'] as List?) ?? const []).any((a) => a is Map && (a['trigger'] as Map?)?['type'] == 'submitted');
      if (multiline && submits && !props.containsKey('textInputAction')) propsChange['textInputAction'] = 'send';
      final (:composer, :toolbar, :entry, :frame) = notationFieldPlace(nodes, (k) => _parentOf[k], id);
      if (composer && _multilineWord.contains(id)) propsChange['minLines'] = 1;
      if (composer || toolbar || entry || frame != null) {
        final d = readMap(props['decoration']) ?? const <String, Object?>{};
        final binds = readMap(n['bind']) ?? const <String, Object?>{};
        final label = d['labelText'];
        final boundLabel = binds['props.decoration.labelText'];
        final hasHint = (d['hintText'] is String && (d['hintText']! as String).isNotEmpty) || binds['props.decoration.hintText'] != null;
        final labelled = (label is String && label.isNotEmpty) || boundLabel != null;
        // A label written by name (`label="Email"`) stays above the field
        // wherever it is: the way a print keeps a field's label there.
        if (labelled && !_labelByName.contains(id)) {
          final decorationChange = <String, Object?>{'labelText': null, 'labelStyle': null};
          if (hasHint) {
            // Its name, spoken.
            if (label is String && label.isNotEmpty && !props.containsKey('semanticLabel')) propsChange['semanticLabel'] = label;
            if (boundLabel != null) {
              bindChange['props.decoration.labelText'] = null;
              if (!binds.containsKey('props.semanticLabel')) bindChange['props.semanticLabel'] = boundLabel;
            }
          } else if (boundLabel != null) {
            bindChange['props.decoration.labelText'] = null;
            bindChange['props.decoration.hintText'] = boundLabel;
          } else {
            decorationChange['hintText'] = label;
          }
          propsChange['decoration'] = decorationChange;
          // The height it was given for its label above.
          final layout = readMap(n['layout']);
          final h = layout?['height'];
          final extra = options.fieldLabel == null ? 20 : 23;
          if (h is num && options.controlHeight != null && !multiline && (h == options.controlHeight! + extra || h == options.controlHeight! + extra + 18)) {
            change['layout'] = {'height': h - extra};
          }
        }
        if (frame != null && !d.containsKey('border') && !d.containsKey('filled')) {
          final decorationChange = (propsChange['decoration'] as Map<String, Object?>?) ?? <String, Object?>{};
          decorationChange['border'] = {'type': 'none'};
          decorationChange['filled'] = false;
          propsChange['decoration'] = decorationChange;
          // The frame takes the focus ring the field no longer draws: its
          // line in the accent while the field has the focus (CSS's
          // :focus-within), unless the writer said its focused look.
          final frameNode = nodes[frame]!;
          final strokes = (readMap(frameNode['decoration'])?['strokes'] as List?) ?? const [];
          final states = readMap(frameNode['states']) ?? const <String, Object?>{};
          if (strokes.isNotEmpty && !states.containsKey('focused')) {
            patch(frame, {
              'states': {
                'focused': {
                  frame: {
                    'decoration': {
                      'strokes': [
                        {...?readMap(strokes.first), 'color': options.accent},
                      ],
                    },
                  },
                },
              },
            });
          }
        }
      }
      if (propsChange.isNotEmpty) change['props'] = propsChange;
      if (bindChange.isNotEmpty) change['bind'] = bindChange;
      if (change.isNotEmpty) patch(id, change);
    }
  }

  void _reflow() {
    _rejoinWraps();
    // A page laid out for a phone is as written; a narrow overlay of a page
    // (its _host) wraps its rows of copies only (PageReflow.runNarrow).
    if (!options.reflow || (options.width < 700 && _host == null)) return;
    final reflow = PageReflow(
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
          if (_keepColumns.contains(e.value) || _placesCells(e.key)) e.key,
      },
      cards: _cards,
      tableRows: _tableRows,
      displaySizes: options.displaySizes,
      isComponent: (type) => type.isNotEmpty && type[0].toUpperCase() == type[0] && catalog.widget(type) != null,
      fillsItsPlace: (type) => switch (options.components[type]?.width) { final Map m => m.containsKey('fill'), _ => false },
      listDetailState: _host == null ? _listDetailName : null,
      variableStart: (name) => variables[name]?['value'],
      kept: {..._keep, ?_componentRootKept()},
    );
    // A narrow canvas (a dialog, a sheet, a component) keeps its layout; only
    // its rows of copies wrap where the window is narrower still.
    final rules = options.width < 700 ? reflow.runNarrow() : reflow.run();
    for (final e in rules.entries) {
      final node = nodes[e.key]!;
      // The line's own rules (hide=phone) come after, so they win; one it
      // already says (a print read again) is not added twice.
      final own = (node['media'] as List?) ?? const [];
      final media = [...e.value.where((r) => !own.any((o) => jsonEquality.equals(o, r))), ...own];
      node['media'] = media;
      if (_canvas) ops.add({'op': 'patch', 'id': e.key, 'patch': {'media': media}});
    }
    if (reflow.listDetail case final ListDetail ld) _listDetail(ld);
  }

  /// The page's state that says which pane of a list beside its detail a
  /// phone shows ([ListDetail]): named after the screen, as its sidebar's
  /// drawer is, so that no name an author writes is it.
  late final String _listDetailName = () {
    var name = '${options.screen.replaceAll('-', '_')}_pane';
    while (variables.containsKey(name) || _projectVariables.contains(name)) {
      name = '${name}_';
    }
    return name;
  }();

  /// What a phone's back does where a list beside its detail shows its
  /// detail: the canvas's `blockBack`.
  String? _blockBack;

  /// A list beside its detail on a phone ([ListDetail], whose media rules
  /// [PageReflow] wrote): the state that says which pane shows, starting at
  /// the list; a tap that selects a row shows the next pane (after the row's
  /// own actions, the same reaction a key press on it runs); a back button at
  /// the top left of each later pane (in its top bar, else in a bar of its
  /// own), Escape and the system back show the one before. The panes of an
  /// app's window before Main also get the button that opens the sidebar's
  /// drawer, which Main's bar holds and the list hides.
  void _listDetail(ListDetail ld) {
    final state = _listDetailName;
    final below = ld.below;
    void patch(String id, Json change) {
      nodes[id] = mergePatch(nodes[id]!, change);
      if (_canvas) ops.add({'op': 'patch', 'id': id, 'patch': change});
    }

    void addRule(String id, Json rule) => patch(id, {'media': [...?(nodes[id]!['media'] as List?), rule]});

    void put(String id, Json node, String parent, int index) {
      nodes[id] = node;
      _parentOf[id] = parent;
      final kids = [...?(nodes[parent]!['children'] as List?)]..insert(index, id);
      nodes[parent]!['children'] = kids;
      if (_canvas) ops.add({'op': 'set', 'id': id, 'parent': parent, 'index': index, 'node': {...node}..remove('children')});
    }

    String fresh(String base, String type) => _taken(base) ? _id(type) : base;

    variables[state] = {'name': state, 'type': 'integer', 'value': ld.start};
    if (_canvas && _declared.add(state)) {
      ops.add({
        'op': 'vars',
        'scope': _scope,
        'set': {
          state: {'type': 'integer', 'value': ld.start},
        },
      });
    }
    // A selecting tap shows the next pane, after the row's own actions.
    for (final o in ld.opens) {
      final reactions = [...(nodes[o.node]!['actions'] as List)];
      final r = (reactions[o.reaction] as Map).cast<String, Object?>();
      reactions[o.reaction] = {
        ...r,
        'actions': [
          ...?(r['actions'] as List?),
          {'type': 'setVariable', 'variable': state, 'value': '\${= ${o.level}}'},
        ],
      };
      nodes[o.node]!['actions'] = reactions;
      if (_canvas) ops.add({'op': 'patch', 'id': o.node, 'patch': {'actions': reactions}});
    }
    // The button that opens the app's sidebar as a drawer, where it shows.
    final drawer = _pages.sidebarButton ? _pages.sidebarMenu : null;
    String? opener;
    for (final e in nodes.entries) {
      if (drawer != null && e.value['type'] == 'iconButton' && jsonEncode(e.value['actions'] ?? const []).contains('"to":"$drawer"')) {
        opener = e.key;
        break;
      }
    }
    final menuMax = switch ((opener == null ? null : nodes[opener]!['media'] as List?)?.whereType<Map>().map((r) => r['minWidth']).whereType<num>().firstOrNull) {
      final num from => from.toInt() - 1,
      _ => reflowPhoneMax,
    };
    final shown = {'visible': true};
    for (var i = 0; i < ld.levels.length; i++) {
      final level = ld.levels[i];
      final isMain = _roles[level] == 'main';
      // A pane that shows in another's place fades in (the detail also slides
      // in from the side it opens on), where one shows at a time: an enter
      // animation, off where the panes stand side by side, that plays again
      // as its key turns ([PageReflow] binds both).
      if (nodes[level]!['animations'] == null) {
        final last = i == ld.levels.length - 1;
        patch(level, {
          'animations': [
            {
              'id': 'pane',
              'preset': 'enter',
              'params': {
                'from': {'opacity': 0, if (last) 'translateX': 32},
              },
              'enabled': false,
              'duration': 220,
            },
          ],
        });
      }
      Json button(String icon, String tooltip, List<Object?> actions, int max) => {
            'type': 'iconButton',
            'layout': {'width': {'hug': 0}, 'height': {'hug': 0}},
            'props': {'icon': icon},
            'tooltip': tooltip,
            'visible': false,
            'media': [
              {'maxWidth': max, 'patch': shown},
            ],
            'actions': [
              {'trigger': {'type': 'click'}, 'actions': actions},
            ],
          };
      final back = i == 0
          ? null
          : button('arrow_back', 'Back', [
              {'type': 'setVariable', 'variable': state, 'value': '\${= ${i - 1}}'},
            ], below);
      final menu = ld.app && !isMain && opener != null
          ? button('menu', 'Menu', [...(readMap((nodes[opener]!['actions'] as List).first)!['actions'] as List)], math.min(below, menuMax))
          : null;
      // The pane's own top bar: Main's Nav, or the slim bar made for the
      // sidebar's button where Main has none.
      String? bar;
      if (isMain) {
        var holder = level;
        final first = (nodes[level]!['children'] as List?)?.firstOrNull;
        if (first == '${level}Scroll') holder = first as String;
        final top = (nodes[holder]!['children'] as List?)?.firstOrNull as String?;
        if (top != null && (_roles[top] == 'nav' || (opener != null && (nodes[top]!['children'] as List?)?.contains(opener) == true))) bar = top;
      }
      if (bar != null) {
        if (back != null) {
          put(fresh('${state}Back$i', 'iconButton'), back, bar, 0);
          // The title beside it takes the room there, as beside the sidebar's button.
          final kids = (nodes[bar]!['children'] as List).cast<String>();
          final title = kids.skip(1).where((k) => k != opener).firstOrNull;
          if (title != null) {
            final layout = readMap(nodes[title]!['layout']) ?? const {};
            if (layout['width'] is! num && layout['flex'] == null) {
              addRule(title, {
                'maxWidth': below,
                'patch': {'layout': {'width': {'fill': 0}, 'flex': 1, 'basis': 96}},
              });
            }
          }
          // The slim bar shows where the back button does.
          if (_roles[bar] != 'nav') addRule(bar, {'maxWidth': below, 'patch': shown});
        }
        // Where the detail is a pane of its own, its list opens the drawer.
        if (opener != null && (nodes[bar]!['children'] as List).contains(opener) && i > 0) addRule(opener, {'maxWidth': below, 'patch': {'visible': false}});
        continue;
      }
      if (back == null && menu == null) continue;
      final barId = fresh('${state}Bar$i', 'row');
      put(
          barId,
          {
            'type': 'row',
            'layout': {
              'width': {'fill': 0},
              'height': {'hug': 0},
              'padding': ld.app ? [8, 8, 8, 8] : [0, 0, 0, 8],
            },
            'props': {'spacing': 4, 'crossAxisAlignment': 'center'},
            if (ld.app)
              'decoration': {
                'strokes': [
                  {'color': options.line},
                ],
                'strokeSides': 'bottom',
              },
            'visible': false,
            'media': [
              {'maxWidth': back != null ? below : math.min(below, menuMax), 'patch': shown},
            ],
            'children': <Object?>[],
          },
          level,
          0);
      if (menu != null) put(fresh('${state}Menu$i', 'iconButton'), menu, barId, 0);
      if (back != null) put(fresh('${state}Back$i', 'iconButton'), back, barId, menu == null ? 0 : 1);
    }
    // Escape and the system back show the pane before, where one shows at a time.
    final when = '\${= $state>0 && screen.width<=$below}';
    final previous = [
      {'type': 'setVariable', 'variable': state, 'value': '\${= $state-1}'},
    ];
    _timers
      ..add({'trigger': {'type': 'keyDown', 'key': 'Escape', 'when': when}, 'actions': previous})
      ..add({'trigger': {'type': 'backPressed'}, 'actions': previous});
    _blockBack = when;
    if (_canvas) {
      _patches.add({
        'op': 'patch',
        'id': options.screen,
        'patch': {
          'actions': [..._timers],
          'bind': {'props.blockBack': when},
        },
      });
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
  static final _wholeJsonLine = RegExp(r'^\s*(?:node(?:#[A-Za-z_][A-Za-z0-9_-]*)?|document)\s*\{');

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
      // A website's page is as tall as the window it is shown in where it has
      // one, and as tall as its content in a host that scrolls it: its canvas
      // hugs (C3).
      if (_pages.app || (height is Map && height.containsKey('fill') && _roles[id] != 'page')) {
        _windowed = true;
        // The canvas may be there already (a `state` line came first).
        if (_canvas) _patches.add({'op': 'patch', 'id': options.screen, 'patch': {'layout': {'height': _canvasHeight}}});
      }
    }
    final screen = options.screen;
    // A component's tree (or one under `canvas none`) has no canvas: its
    // root is the document's root, and nothing is sent before it.
    final bare = _top._widget != null || _top._noCanvas;
    if (bare && !_canvas && (id == null || _parentOf[id] != null)) return;
    final fresh = {
      for (final v in variables.values)
        if (!_projectVariables.contains(v['name']) && _declared.add(v['name']! as String))
          v['name']! as String: {
            for (final e in v.entries)
              if (e.key != 'name') e.key: e.value,
          },
    };
    if (id == null && fresh.isEmpty) return;
    if (bare && !_canvas) {
      // The root, then the roots, then what is kept on it.
      _canvas = true;
      ops
        ..add({'op': 'set', 'id': id, 'node': {...nodes[id!]!}..remove('children')..remove('slots')})
        ..add({'op': 'roots', 'roots': [id]});
      if (fresh.isNotEmpty) ops.add({'op': 'vars', 'scope': _documentWords['scope'] as String? ?? id, 'set': fresh});
      ops.addAll(_patches);
      _patches.clear();
      return;
    }
    if (!_canvas) {
      _canvas = true;
      final canvas = _canvasNode..remove('slots');
      ops
        ..add({'op': 'roots', 'roots': _rootIds})
        ..add({'op': 'set', 'id': screen, 'node': _canvasPatch == null ? canvas : mergePatch(canvas, {..._canvasPatch!}..remove('slots'))});
    }
    if (fresh.isNotEmpty) ops.add({'op': 'vars', 'scope': bare ? _documentWords['scope'] as String? ?? _root ?? screen : _scope, 'set': fresh});
    ops.addAll(_patches);
    _patches.clear();
    if (id == null) return;
    final node = {...nodes[id]!}..remove('children');
    final parent = _parentOf[id];
    if (bare && parent == null) {
      ops.add({'op': 'set', 'id': id, 'node': node..remove('slots')});
      return;
    }
    final slot = parent == null ? 'body' : _slotOf[id];
    ops.add({'op': 'set', 'id': id, 'parent': parent ?? screen, if (slot != null) 'slot': slot, 'node': node..remove('slots')});
  }

  bool _canvas = false;

  /// The nodes written as `Card`.
  final _cards = <String>{};

  /// The height of a button, a field and a select that write none: the
  /// theme's (`sizes.control`); on a website (a `Page`) 40, a web page's
  /// control, where an app's are the desktop's compact 28 (round 11: a
  /// site's buttons, fields and selects were 28 px beside the web's 40 to 48).
  double? get _controlHeight => options.controlHeight ?? (_top._pages.site ? 40.0 : null);

  /// A row whose children's written widths add up to more than the canvas
  /// is wide (a table's columns in a card): the widths become shares of the
  /// row, so the columns keep their proportions and fit. A row that scrolls
  /// keeps its widths.
  void _fitRow(_Open open) {
    final row = nodes[open.id];
    if (open.type != 'row' || row == null || (row['props'] as Map?)?['scrollable'] == true) return;
    // Nor one in a row that scrolls (a timeline's ruler): there it has all
    // the width it asks for, and shares of it are nothing (round 11: a
    // ruler of `Text "00:15" w=126` cells ran together, `00:0000:15…`).
    for (String? at = _parentOf[open.id]; at != null; at = _parentOf[at]) {
      final n = nodes[at];
      if (n?['type'] == 'row' && (n?['props'] as Map?)?['scrollable'] == true) return;
    }
    final children = [
      for (final c in (row['children'] as List? ?? const []))
        if (nodes[c] case final Json n) (c as String, n),
    ];
    final fixed = [
      for (final (id, n) in children)
        if ((n['layout'] as Map?)?['width'] case final num w when w > 0 && n['type'] == 'text' && !_exactWidths.contains(id)) (id, n, w),
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
        if (w is num && w >= 80 && (n['type'] == 'row' || n['type'] == 'column') && !_exactWidths.contains(id)) fixed.add((id, n, w));
      }
    }
    // A cell that already grows (the name's column, written `grow`) is the
    // widest: its share is counted in the same unit as the others' widths.
    _tableRows.add(open.id);
    final widest = fixed.fold<num>(0, (m, f) => f.$3 > m ? f.$3 : m);
    for (final (id, n) in children) {
      final flex = (n['layout'] as Map?)?['flex'];
      if (flex is num && flex > 0 && flex < 20 && n['type'] != 'spacer' && !fixed.any((f) => f.$1 == id) && !_exactFlex.contains(id)) {
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

  /// The text fields whose lines (`minLines` 3) the word `multiline` gave,
  /// not the writer: a composer's starts at one ([_fieldsBesideButtons]).
  final _multilineWord = <String>{};

  /// The Selects whose lines wrote a fill or a border: the line's box is
  /// their frame ([_framedSelectsBare]).
  final _framedSelects = <String>{};

  /// The text fields whose lines wrote a fixed height ([_labelledFieldHeights]).
  final _fieldHeights = <String, num>{};

  /// The nodes whose lines wrote `w=fill` ([_wrapFills]).
  final _writtenFills = <String>{};

  /// The Selects whose lines said `underline=` (true: the frame inside the
  /// box is kept).
  final _ownFrameSaid = <String>{};

  /// The text fields whose label is written by name (`label="…"`), not as
  /// the line's string: their label stays above them beside buttons too
  /// ([_fieldsBesideButtons]).
  final _labelByName = <String>{};

  /// The item of an `each` → its list, for one that may yet share a row's width.
  final _acrossLists = <String, String>{};

  /// The nodes whose line wrote their height by its full path
  /// (`layout.height=108`): that height exactly, which a text under a column
  /// does not make a least height (design 22, 4.8).
  final _exactHeights = <String>{};

  /// The nodes whose line wrote their width or their flex by its full path
  /// (`layout.width=170`, `layout.flex=1`): a row of a table's columns does
  /// not make them shares of its width ([_fitRow], design 22, 4.8).
  final _exactWidths = <String>{}, _exactFlex = <String>{};

  /// Changes a line makes to a node already sent (a grid's row height).
  final _patches = <Json>[];

  /// Texts a line's strings stand for on a type whose text is a child: an
  /// accordion's header, a list tile's title and subtitle.
  final _texts = <String>[];

  /// The style of the line's own strings, when its type sets one (a badge).
  Json? _textStyle;

  /// A Badge's ink when its tone is worked out from the state (a formula).
  String? _textColor;

  /// A label that reads state (`Button "Step {n}"`): bound, since only a
  /// text node reads expressions as written.
  final _labelBinds = <String, String>{};

  Json? _documentPatch;

  /// What a `document id="checkout" schema=2 scope=page_variables` line
  /// says: the document's own `id` and `schema`, and the scope its `state`
  /// lines are kept in (docs/design/22 section 4.5).
  final _documentWords = <String, Object?>{};

  /// A design system's component (`component Name "doc"` above its tree,
  /// docs/design/22 section 4.5): its declaration (the document's `widget`)
  /// and its previews. The document is then the tree alone: its root is the
  /// first line, with no canvas around it.
  Json? _widget;
  final _previews = <Json>[];

  /// What a `canvas` line says of the screen, merged over its canvas; with
  /// `canvas none`, a document with no canvas (its root the first line).
  Json? _canvasPatch;
  bool _noCanvas = false;

  /// Each line's `{…}` tail by its node: merged again once the whole text
  /// is read ([parse]), so that what later lines add does not undo it.
  final _lineTails = <String, Json>{};

  /// [tail] without the values worked out (`${…}`), which the line binds
  /// rather than holds: what is merged again.
  static Json _settled(Json tail) => {
        for (final e in tail.entries)
          if (e.value is! String || !(e.value as String).contains(r'${')) e.key: e.value is Map ? _settled((e.value as Map).cast<String, Object?>()) : e.value,
      };

  static final _componentPart = RegExp(r'^(param|event|slot|preview)\s+(.*)$');

  /// Reads [raw] when it is a component's head or a line of it (a
  /// `param`, `event`, `slot` or `preview` indented under it).
  bool _componentLine(String raw) {
    if (_host != null || _root != null) return false;
    final indent = raw.length - raw.trimLeft().length, text = raw.trim();
    // `canvas "Trip" path="/trip" h=844 fill=paper`: the screen's own fields
    // (its name, path, size and fill; any other by its path from the canvas,
    // `props.blockBack=true`), above the tree.
    if (indent == 0 && RegExp(r'^canvas\s+none$').hasMatch(text)) {
      // `canvas none`: the document has no canvas; its root is the first line.
      _noCanvas = true;
      return true;
    }
    if (indent == 0 && RegExp(r'^canvas(\s|$)').hasMatch(text)) {
      _canvasPatch = mergePatch(_canvasPatch ?? const {}, _canvasWords(text.substring(6)), keepNulls: true);
      return true;
    }
    if (indent == 0 && RegExp(r'^component(\s|$)').hasMatch(text)) {
      final words = _headWords(text.substring(9));
      final name = words.isEmpty ? null : words.first;
      if (name == null || name.value != null || !RegExp(r'^[A-Z][A-Za-z0-9_]*$').hasMatch(name.key)) {
        _issue(1, 'A component is written: component Name "what it is", its parameters, events, slots and previews indented under it, then its tree.');
        return true;
      }
      _widget = {'type': name.key};
      for (final w in words.skip(1)) {
        if (w.key == '"' && _widget!['doc'] == null) {
          _widget!['doc'] = w.value;
        } else if (w.key == 'children' && w.value is String) {
          _widget!['children'] = w.value;
        } else {
          _issue(1, 'A component\x27s head takes its name, a string saying what it is, and children=list (or slots): not "${w.key}".');
        }
      }
      return true;
    }
    final m = _componentPart.firstMatch(text);
    if (indent == 0 || _widget == null || m == null) return false;
    final words = _headWords(m[2]!);
    final widget = _widget!;
    void add(String key, Object? value) => ((widget[key] as List<Object?>?) ?? (widget[key] = <Object?>[])).add(value);
    switch (m[1]) {
      case 'param':
        // `param title="Action" required doc="The title."`, `param size:small|medium|large=medium`.
        final first = words.firstOrNull;
        // `param @selected=""`: a variable parameter, as `@name` on a call
        // keeps a variable (round 10, R20); its type is its default's.
        final kept = first != null && first.key.startsWith('@') && !first.key.contains(':');
        final head = first == null ? null : RegExp(r'^@?([A-Za-z_][A-Za-z0-9_]*)(?::(.+))?$').firstMatch(first.key);
        if (head == null) {
          _issue(indent + 1, 'A parameter is written: param name=default, its type after a colon where the default does not say it (param count:int=3), then required and doc="…".');
          return true;
        }
        final type = kept
            ? notationTypeJson('ValueNotifier<${notationTypeOf(first.value)}>')
            : head[2] == null
                ? notationTypeJson(notationTypeOf(first!.value))
                : notationTypeJson(head[2]!);
        if (type == null) _issue(indent + 1, 'No type "${head[2]}": String, bool, double, int, Map or dynamic (a record, anything), List<…>, ValueNotifier<…>, or an enum\x27s values joined by | (small|medium|large).');
        final p = <String, Object?>{'key': head[1], 'type': type ?? notationTypeJson('String'), 'default': first!.value};
        for (final w in words.skip(1)) {
          if (w.key == 'required' && w.value == null) {
            p['required'] = true;
          } else if (w.key == 'doc' && w.value is String) {
            p['doc'] = w.value;
          } else {
            _issue(indent + 1, 'A parameter takes required and doc="…" after its default: not "${w.key}".');
          }
        }
        add('props', p);
      case 'event':
        final first = words.firstOrNull;
        final head = first == null || first.value != null ? null : RegExp(r'^(on[A-Z][A-Za-z0-9_]*)(?::(.+))?$').firstMatch(first.key);
        if (head == null) {
          _issue(indent + 1, 'An event is written: event onName, with what it passes after a colon (event onChanged:String) and doc="…".');
          return true;
        }
        final e = <String, Object?>{'key': head[1]};
        // `event onPick:void` (round 10, R20): an event that passes nothing.
        if (head[2] case final String t when t != 'void') {
          if (notationTypeJson(t) case final Json json) {
            e['payload'] = json;
          } else {
            _issue(indent + 1, 'No type "$t": String, bool, double, int, Map or dynamic, List<…>, or an enum\x27s values joined by |.');
          }
        }
        for (final w in words.skip(1)) {
          if (w.key == 'doc' && w.value is String) {
            e['doc'] = w.value;
          } else {
            _issue(indent + 1, 'An event takes doc="…" after its name: not "${w.key}".');
          }
        }
        add('events', e);
      case 'slot':
        for (final w in words) {
          if (w.value == null && RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(w.key)) {
            add('slots', w.key);
          } else {
            _issue(indent + 1, 'A slot is written: slot name.');
          }
        }
      case 'preview':
        // `preview "Default" 340x66 title="Summarize new tickets"`.
        final pv = <String, Object?>{'name': ''};
        final props = <String, Object?>{};
        for (final w in words) {
          final size = RegExp(r'^(\d+(?:\.\d+)?)x(\d+(?:\.\d+)?)$').firstMatch(w.key);
          if (w.key == '"' && pv['name'] == '') {
            pv['name'] = w.value;
          } else if (size != null && w.value == null) {
            pv['size'] = [num.parse(size[1]!), num.parse(size[2]!)];
          } else if (w.key != '"') {
            props[w.key] = w.value;
          }
        }
        pv['props'] = props;
        _previews.add(pv);
    }
    return true;
  }


  /// Node [id], written under `slot <name>` ([frame]), in that slot of the
  /// node above; a second line under it is said and drawn as a child.
  void _intoSlot(_Open frame, String id, int column) {
    final p = nodes[frame.id]!;
    final slots = (p['slots'] as Json?) ?? (p['slots'] = <String, Object?>{});
    final name = frame.slot!;
    if (frame.slotRow != null) {
      _issue(column, 'A slot holds one node: put the lines of "slot $name" in a Row or a Column.');
      ((p['children'] as List<Object?>?) ?? (p['children'] = <Object?>[])).add(id);
    } else {
      // What the node's own words put there (a ListTile's title text) gives
      // way to the line written.
      if (slots[name] case final String made when made != id && _parentOf[made] == frame.id) nodes.remove(made);
      slots[name] = id;
      _slotOf[id] = name;
      frame.slotRow = id;
    }
    _parentOf[id] = frame.id;
  }

  /// The nodes a line's words made under it (a Badge's text) that its
  /// `{…}` tail took out of its `children` or `slots`: no line holds them,
  /// so they are not in the document.
  void _dropOrphans() {
    final tailed = {
      for (final e in _lineTails.entries)
        if (e.value.containsKey('children') || e.value.containsKey('slots')) e.key,
    };
    if (tailed.isEmpty) return;
    final held = <String>{
      for (final n in nodes.values) ...[
        ...readStrings(n['children']),
        for (final s in (readMap(n['slots']) ?? const {}).values)
          if (s is String) s,
      ],
    };
    var gone = [
      for (final id in nodes.keys)
        if (!held.contains(id) && tailed.contains(_parentOf[id])) id,
    ];
    while (gone.isNotEmpty) {
      final next = <String>[];
      for (final id in gone) {
        if (held.contains(id)) continue;
        final n = nodes.remove(id);
        if (n == null) continue;
        next.addAll(readStrings(n['children']));
        next.addAll([
          for (final s in (readMap(n['slots']) ?? const {}).values)
            if (s is String) s,
        ]);
      }
      gone = next;
    }
  }

  /// The words of a `document` line (after `document`): `id="…"`,
  /// `schema=<n>`, `scope=<canvas id or page_variables>`, `conditions={…}`
  /// (the document's own conditions, as their JSON: design 22, 2.1). False
  /// when the line is not one (its first word is no key of it).
  bool _documentLine(String text, int column) {
    final words = _headWords(text);
    if (words.isEmpty || !const {'id', 'schema', 'scope', 'conditions'}.contains(words.first.key)) return false;
    for (final w in words) {
      final ok = switch (w.key) {
        'id' => w.value is String,
        'schema' => w.value is int,
        'scope' => w.value is String && RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(w.value! as String),
        'conditions' => w.value is Map || w.value is List,
        _ => false,
      };
      if (ok) {
        _top._documentWords[w.key] = w.value;
      } else {
        _issue(column, 'A document line takes the document\x27s id="…", schema=3, scope= (where its state is kept: a canvas id, or page_variables) and conditions={…} (their JSON): not "${w.key}${w.value == null ? '' : '=${w.value}'}".');
      }
    }
    return true;
  }

  /// What a canvas line's words (after `canvas`, or a `Canvas#id` block's
  /// head) say of its canvas, as a merge patch: its name in quotes, `w`,
  /// `h`, `fill`, any other field by its path from the canvas.
  Json _canvasWords(String text) {
    final patch = <String, Object?>{};
    for (final w in _headWords(text)) {
      // `onLoad={go home}`, `onBackPressed={…}`: what the screen does, a
      // reaction of the canvas, before its `every` and `key` lines.
      final trigger = w.key.startsWith('on') ? notationEventTrigger(w.key) : null;
      if (trigger != null && w.value is String && (w.value! as String).startsWith('{') && (w.value! as String).endsWith('}')) {
        final body = (w.value! as String);
        _timers.add({
          'trigger': {'type': trigger},
          'actions': _actions(body.substring(1, body.length - 1).trim(), 1),
        });
        if (_canvas) _patches.add({'op': 'patch', 'id': options.screen, 'patch': {'actions': [..._timers]}});
        continue;
      }
      // `blockBack={dirty}` (`guard={…}` the same): while it holds, back,
      // Escape and a tap outside do not close it; any prop of the canvas
      // worked out (`semanticLabel={…}`): bound. Before, the braces were
      // kept as a literal string (test 10, kanban 4).
      if (w.value case final String v when v.startsWith('{') && v.endsWith('}') && v.length > 2) {
        final key = w.key == 'guard' ? 'blockBack' : w.key;
        if (catalog.widget('canvas')?.props.any((p) => p.key == key) ?? false) {
          ((patch['bind'] as Json?) ?? (patch['bind'] = <String, Object?>{}))['props.$key'] = _formula(v.substring(1, v.length - 1).trim());
          continue;
        }
      }
      final path = switch (w.key) {
        '"' => 'name',
        'w' => 'layout.width',
        'h' => 'layout.height',
        'fill' => 'decoration.fills',
        final k => k,
      };
      final value = w.key == 'fill' && w.value is String
          ? [
              {'color': w.value},
            ]
          : w.value;
      if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*)*$').hasMatch(path)) {
        _issue(1, 'A canvas line takes its name in quotes and key=value: canvas "Home" path="/" h=844 fill=surface.');
        continue;
      }
      var at = patch;
      final keys = path.split('.');
      for (final k in keys.take(keys.length - 1)) {
        final next = at[k];
        at = next is Json ? next : (at[k] = <String, Object?>{});
      }
      at[keys.last] = value;
    }
    return patch;
  }
  /// The words of a component's head line: `key=value` (the value JSON, or
  /// a bare word as text), a bare `key` (value null) and a string (key `"`).
  static List<({String key, Object? value})> _headWords(String text) {
    final out = <({String key, Object? value})>[];
    var i = 0;
    int end(int from) {
      // A value: a string, a bracketed JSON value, or up to a space.
      if (from >= text.length) return from;
      if (text[from] == '"') {
        for (var k = from + 1; k < text.length; k++) {
          if (text[k] == r'\') {
            k++;
          } else if (text[k] == '"') {
            return k + 1;
          }
        }
        return text.length;
      }
      if (text[from] == '[' || text[from] == '{') {
        var depth = 0, quoted = false;
        for (var k = from; k < text.length; k++) {
          final c = text[k];
          if (quoted) {
            if (c == r'\') {
              k++;
            } else if (c == '"') {
              quoted = false;
            }
            continue;
          }
          if (c == '"') quoted = true;
          if (c == '[' || c == '{') depth++;
          if ((c == ']' || c == '}') && --depth == 0) return k + 1;
        }
        return text.length;
      }
      final space = text.indexOf(' ', from);
      return space < 0 ? text.length : space;
    }

    Object? decode(String raw) {
      try {
        return jsonDecode(raw);
      } on FormatException {
        return raw;
      }
    }

    while (i < text.length) {
      if (text[i] == ' ') {
        i++;
        continue;
      }
      if (text[i] == '"') {
        final e = end(i);
        out.add((key: '"', value: decode(text.substring(i, e))));
        i = e;
        continue;
      }
      // A key runs to `=` or a space (a type after its colon may hold `<…>`
      // and `|`, or be JSON: `count:{"kind": "number", "flutter": "int"}`).
      var k = i;
      while (k < text.length && text[k] != ' ' && text[k] != '=') {
        if (text[k] == '{' && k > i && text[k - 1] == ':') {
          k = end(k);
          continue;
        }
        k++;
      }
      final key = text.substring(i, k);
      if (k < text.length && text[k] == '=') {
        final e = end(k + 1);
        out.add((key: key, value: decode(text.substring(k + 1, e))));
        i = e;
      } else {
        out.add((key: key, value: null));
        i = k;
      }
    }
    return out;
  }

  /// The ids the whole text opens (`open edit`), known before its lines are
  /// read when it is read at once: a design system's Dialog#edit written
  /// inside the page is then what that open shows.
  final _openedIds = <String>{};

  NotationResult parse(String text, {String? definitions}) {
    // The words the text defines hold from its first line, wherever they are
    // written (an answer writes them after its last screen).
    final others = options.vocabulary.definitions;
    if (definitions != null) {
      final more = readPageDefinitions(definitions, others: others);
      // A word the notation has is the notation's (said where the more text
      // is read: a site's definition file).
      more.words.removeWhere((w, _) => _builtIn(w) != null);
      _defined.preread(more.words);
    }
    final own = readPageDefinitions(text, others: others);
    // A word the notation has is the notation's: the text's definition of it
    // is not used, and said where it is written.
    for (final w in own.words.keys.toList()) {
      if (_builtIn(w) case final what?) {
        for (final d in own.words.remove(w)!) {
          issues.add(NotationIssue(d.line, 1, notationBuiltInDefinition(w, what, kind: d.primitive ? 'primitive' : 'definition')));
        }
      }
    }
    _defined.preread(own.words, signatures: own.signatures);
    for (final p in own.problems) {
      issues.add(NotationIssue(p.line, 1, p.message));
    }
    _openedIds.addAll(RegExp(r'\bopen\s+([A-Za-z_][A-Za-z0-9_]*)').allMatches(text).map((m) => m[1]!));
    // A page that writes its own drawer gets none made from its sidebar.
    if (RegExp(r'^Drawer\b', multiLine: true).hasMatch(text)) _pages.ownDrawer = true;
    final rows = const LineSplitter().convert(text);
    _silentTopLines = _topLinesAlone(rows);
    rows.forEach(_readLine);
    finish();
    return _end();
  }

  /// The lines (1-based) of [rows] written at the top with nothing under
  /// them, other than the frame, when the top holds an `App` or a `Page`:
  /// where a stand-in draws nothing ([_silence]).
  static Set<int> _topLinesAlone(List<String> rows) {
    final frame = RegExp(r'^(App|Page)\b');
    if (!rows.any(frame.hasMatch)) return const {};
    bool skipped(String l) => l.trim().isEmpty || l.trimLeft().startsWith('//');
    bool under(String l) => l.startsWith(' ') || l.startsWith('\t');
    final out = <int>{};
    for (var i = 0; i < rows.length; i++) {
      final l = rows[i];
      if (skipped(l) || under(l) || !RegExp(r'^[A-Z]').hasMatch(l) || frame.hasMatch(l)) continue;
      var j = i + 1;
      while (j < rows.length && skipped(rows[j])) {
        j++;
      }
      if (j == rows.length || !under(rows[j])) out.add(i + 1);
    }
    return out;
  }

  /// The text read so far, for what its brackets say at [finish].
  final _rawText = StringBuffer();

  /// Reads [raw], a line of the text, kept for [finish] to say what its
  /// brackets leave unread (brackets.dart): a formula with a `)` that closes
  /// nothing was kept as written and read as nothing, with no word (test 10,
  /// kanban).
  void _readLine(String raw) {
    _rawText.writeln(raw);
    line(raw);
  }

  /// The end of the text, read whole or as it arrived ([NotationStream]):
  /// each line's tail merged again, the nodes a tail took away left out,
  /// and the document. [changed], when given, is told each node of a
  /// parser that this changed (its id, the node before, or null for one
  /// left out), so that a stream can send it.
  NotationResult _end({void Function(_Parser p, String id, Json? before)? changed}) {
    for (final p in [this, ..._overlays]) {
      final before = changed == null ? null : {for (final e in p.nodes.entries) e.key: _copy(e.value)};
      for (final e in p._lineTails.entries) {
        if (p.nodes[e.key] case final Json node) _merge(node, _settled(e.value));
      }
      p._dropped.forEach(p.nodes.remove);
      p._dropOrphans();
      if (before != null) {
        for (final e in before.entries) {
          final now = p.nodes[e.key];
          if (now == null || jsonEncode(now) != jsonEncode(e.value)) changed!(p, e.key, e.value);
        }
      }
    }
    final patch = _documentPatch;
    final words = {
      for (final k in const ['id', 'schema', 'conditions'])
        if (_documentWords.containsKey(k)) k: _documentWords[k],
    };
    Json patched(Json d) {
      final out = words.isEmpty ? d : mergePatch(d, words);
      return patch == null ? out : mergePatch(out, patch);
    }
    // A component's document (or a tree with `canvas none`): its declaration,
    // its previews and its tree, no canvas; its variables are its root's.
    if (_widget != null || _noCanvas) {
      final widget = _widget;
      final own = variables.values.where((v) => !_projectVariables.contains(v['name'])).toList();
      return NotationResult(patched({
        'schema': 3,
        'id': ?widget?['type'],
        'roots': [?_root],
        'widget': ?widget,
        if (_previews.isNotEmpty) 'previews': _previews,
        'nodes': {...nodes},
        // Its key, every and on load lines: the screen that shows it takes them.
        if (widget != null && _timers.isNotEmpty) 'screenActions': [..._timers],
        // Its overlays (a drawer it opens): the screen that shows it takes them.
        // (and those of the components it calls, which it took).
        if (widget != null && (_overlays.isNotEmpty || _takenOverlays.isNotEmpty))
          'screenOverlays': [
            for (final p in _overlays)
              {
                'id': p.options.screen,
                'nodes': {
                  p.options.screen: p._canvasPatch == null ? p._canvasNode : mergePatch(p._canvasNode, p._canvasPatch!),
                  ...p.nodes,
                },
              },
            for (final e in _takenOverlays.entries) {'id': e.key, 'nodes': e.value},
          ],
        if (own.isNotEmpty) 'variables': {_documentWords['scope'] as String? ?? _root ?? options.screen: own},
      }), issues, wanted: List.unmodifiable(wanted), vocabulary: List.unmodifiable(vocabulary));
    }
    return NotationResult(patched({
      'schema': 3,
      'roots': _rootIds,
      'nodes': {
        for (final p in [this, ..._overlays]) ...{
          p.options.screen: p._canvasPatch == null ? p._canvasNode : mergePatch(p._canvasNode, p._canvasPatch!),
          ...p.nodes,
        },
        for (final o in _takenOverlays.values) ...o,
      },
      if (variables.values.any((v) => !_projectVariables.contains(v['name'])))
        'variables': {_scope: variables.values.where((v) => !_projectVariables.contains(v['name'])).toList()},
    }), issues, wanted: List.unmodifiable(wanted), vocabulary: List.unmodifiable(vocabulary));
  }

  /// The slot of [block] the lines under it go in.
  static String _slotOfLines(_Open block) =>
      const ['trailing', 'actions', 'action', 'end'].firstWhere(block.slots.contains, orElse: () => block.slots.first);

  /// The row in [block]'s slot (a ListRow's trailing, a SectionHeader's
  /// actions) that the lines under it go in, side by side: made the first
  /// time.
  String _slotRow(_Open block) {
    final slot = _slotOfLines(block);
    return block.slotRow ??= () {
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
  }

  void _issue(int column, String message) {
    // A line read again (an overlay's foot, a sidebar's copy in its drawer) said what was wrong the first time.
    if (_top._quiet) return;
    issues.add(NotationIssue(_line, column, _from == null || message.startsWith('$_from:') ? message : '$_from: $message'));
  }

  void _lineAt(int indent, String source, int column) {
    if (_paintLine(indent, source)) return; // a defined word's custom paint or animation (paint_words.dart)
    var line = source;
    while (_stack.isNotEmpty && _stack.last.indent >= indent) {
      _close(_stack.removeLast());
    }
    // A defined word's lines written where its use is: they go in the node
    // around it (a Grid's cells, a Column's lines with its gap). At the top
    // of a page there is none: a Column holds them.
    if (line == notationSplice) {
      final around = _stack.reversed.where((o) => !o.leaf).firstOrNull;
      if (around != null) {
        _stack.add(_Open(indent, around.id, around.type, condition: around.condition, grid: around.grid, slot: around.slot, splice: true));
        return;
      }
      line = 'Column';
    }
    // Inside an `each x in …`, x is the document's `item`.
    // In an `each` inside an `each` (a board's cards in its columns), the
    // inner one's x is `item` and the outer one's is the item around it.
    final eaches = [
      for (final open in _stack)
        if (open.each != null) open.each!,
    ];
    // A state named `item` read inside an each is that each's copy (the
    // document's name for it): the state cannot be read there. Said once.
    if (eaches.isNotEmpty && !eaches.contains('item') && variables.containsKey('item') && !_itemSaid && _rename(line, 'item', 'item_') != line) {
      _itemSaid = true;
      _issue(indent + 1, 'item inside an each is the copy it repeats (each ${eaches.last} in … is item in the document), so the state item cannot be read here: name the state otherwise (state itemRecord=…).');
    }
    for (var k = 0; k < eaches.length; k++) {
      final around = eaches.length - 1 - k;
      final to = around == 0 ? 'item' : '${'parent.' * (around - 1)}parent.item';
      // An each inside that reuses the name (`each item in item.items`)
      // hides the outer one, as in any language: the name is the inner's.
      if (eaches.skip(k + 1).contains(eaches[k])) continue;
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
    // `every {60000/bpm} onTick={…}`: an interval worked out, in milliseconds
    // (a metronome at its tempo).
    // A component's key, every and on load lines run on the screen that
    // shows it: what they read and set are the screen's and the site's
    // variables, not the component's own.
    if (_widget != null && indent == 0 && RegExp(r'^(key|every|on)\s').hasMatch(line)) {
      final own = [
        for (final v in variables.keys)
          if (!_projectVariables.contains(v) && RegExp('(?<![A-Za-z0-9_.])${RegExp.escape(v)}(?![A-Za-z0-9_])').hasMatch(line)) v,
      ];
      if (own.isNotEmpty) {
        _issue(column, "A component's ${line.split(RegExp(r'\s')).first} line runs on the screen that shows it, which has no ${own.join(', ')} of this component: make ${own.length == 1 ? 'it a variable' : 'them variables'} of the site (site.json's variables, read here by name) or write the line on the page.");
      }
    }
    final everyExpr = RegExp(r'^every\s+\{([^{}]+)\}(?:\s+when\s+(.+?))?\s+onTick=\{(.+)\}\s*$').firstMatch(line);
    if (everyExpr != null) {
      _timers.add({
        'trigger': {'type': 'timer', 'intervalMs': _formula(everyExpr[1]!.trim()), if (everyExpr[2] != null) 'when': _formula(everyExpr[2]!.trim())},
        'actions': _actions(everyExpr[3]!.trim(), column),
      });
      if (_canvas) _patches.add({'op': 'patch', 'id': options.screen, 'patch': {'actions': [..._timers]}});
      return;
    }
    // `every 1m` and `every 1h` too (round 10, R22: `every 1m` was refused).
    final every = RegExp(r'^every\s+(\d+(?:\.\d+)?)(ms|s|m|min|h)?(?:\s+when\s+(.+?))?\s+onTick=\{(.+)\}\s*$').firstMatch(line);
    if (every != null) {
      final unit = switch (every[2]) { 's' => 1000, 'm' || 'min' => 60000, 'h' => 3600000, _ => 1 };
      final ms = (double.parse(every[1]!) * unit).round();
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
    // `when={expression}` (in either place, or `when expression` before
    // onPress) makes it act only while the expression holds.
    if (_shortcut(line, column) case final Json reaction) {
      if (reaction.isNotEmpty) {
        // The screen's own key replaces a component's for the same key.
        final trigger = readMap(reaction['trigger']);
        _timers.removeWhere((t) =>
            _fromComponents.any((c) => identical(c, t)) && readMap(t['trigger'])?['key'] == trigger?['key'] && readMap(t['trigger'])?['when'] == trigger?['when']);
        _timers.add(reaction);
      }
      if (_canvas) _patches.add({'op': 'patch', 'id': options.screen, 'patch': {'actions': [..._timers]}});
      return;
    }
    if (canvasEventLine(line, column)) return; // `on load={…}` (notation_events.dart)
    if (RegExp(r'^key[\s:]').hasMatch(line)) {
      return _issue(column, 'A shortcut is a line of its own: key mod+k onPress={open search} (mod, alt, shift and a key, joined by +).');
    }
    if (line.startsWith('every ')) {
      return _issue(column, 'An "every" line is: every 1000 onTick={name=value} (milliseconds, or 1s, 1m, 1h), optionally "every 1s when running onTick={…}".');
    }
    // `document {…}`: a merge patch over the whole document, for what is
    // not a node of the tree (the printer's last line).
    if (indent == 0 && line.startsWith('document {')) {
      final j = _json(line.substring(9));
      if (j is Map) _documentPatch = mergePatch(_documentPatch ?? const {}, j.cast<String, Object?>(), keepNulls: true);
      return;
    }
    // `document id="checkout" schema=2 scope=page_variables`: the document's
    // own id and schema, and where its state lines are kept (a canvas id, or
    // page_variables for every canvas of the page).
    if (indent == 0 && RegExp(r'^document\s+[A-Za-z]+=').hasMatch(line)) {
      if (_documentLine(line.substring(9), column + 9)) return;
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
    // `slot title` under a node: the line under it is the node's child in that
    // slot (a ListTile's title, a badge's child, a block's actions), as a
    // component's head names its slots with `slot name`.
    final slotLine = RegExp(r'^slot\s+([A-Za-z_][A-Za-z0-9_]*)$').firstMatch(line);
    if (slotLine != null && _stack.isNotEmpty && _stack.last.slot == null && nodes[_stack.last.id] != null) {
      final holder = _stack.last;
      final type = '${nodes[holder.id]!['type']}';
      final names = catalog.widget(type)?.slots ?? const <String>[];
      if (!names.contains(slotLine[1])) {
        return _issue(column, names.isEmpty ? 'A ${holder.written ?? type} has no slots.' : 'A ${holder.written ?? type} has no slot "${slotLine[1]}". Its slots: ${names.join(', ')}.');
      }
      _stack.add(_Open(indent, holder.id, holder.type, condition: holder.condition, slot: slotLine[1]));
      return;
    }
    var parent = _stack.isEmpty ? null : _stack.last;
    // Lines under a block that takes none but has a slot (a ListRow's
    // trailing, a SectionHeader's or an EmptyState's actions): they go in
    // the slot, side by side in a row of their own.
    // A block whose slot is `children` (`slot children`, a `Slot` with no
    // name in its body) takes them as its own children: that slot shows
    // the call's children. (In a row of a slot named children they showed
    // nothing, with no word: test 10, calendar 3 and storefront 3.)
    final ownChildren = parent != null && parent.slots.isNotEmpty && _slotOfLines(parent) == 'children';
    if (parent != null && parent.slots.isNotEmpty && nodes[parent.id] != null && !ownChildren) {
      final block = parent;
      parent = _Open(block.indent, _slotRow(block), 'row', condition: block.condition);
    } else if (ownChildren && nodes[parent.id] != null) {
      // Appended below, as any line under a node is.
    } else if (!options.openVocabulary && parent != null && parent.leaf && parent.written != null && catalog.widget(parent.written!) != null && nodes[parent.id] != null) {
      // A block that takes nothing under it: said, and the line is drawn
      // after it, where it would otherwise be lost.
      _issue(column, 'A ${parent.written} takes no lines under it (it has no children and no slot): write this line after it, at its own indent.');
      parent = _stack.reversed.where((o) => !o.leaf).firstOrNull;
    }
    if (options.openVocabulary && parent != null && parent.leaf && !ownChildren) {
      // Lines under a word that takes none: recorded, and drawn after it.
      _use('children', _srcPath.lastOrNull ?? parent.type, column, value: _srcWord);
      parent = _stack.reversed.where((o) => !o.leaf).firstOrNull;
    }
    // `SwipeAction "Book" side=end when={!row.full} onTap={…}` under an
    // each: an action behind the swiped row. It is written beside the row
    // and kept by the row's list (its swipeActions, and a swipeAction
    // reaction whose result has the row: result.item, result.index).
    if (RegExp(r'^SwipeAction(\s|$)').hasMatch(line) && catalog.widget('SwipeAction') == null) {
      const usage = 'A swipe action is written: SwipeAction "Book" side=end when={!row.full} onTap={picked=result.item.name} (side=start or end, id=name, icon="…", background=…, foreground=…, danger, removes).';
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
        if (word.isEmpty || (eq < 0 && !const {'removes', 'danger', 'destructive'}.contains(word))) return _issue(column + t.at, usage);
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
        } else if (const {'id', 'side', 'when', 'icon', 'removes', 'background', 'foreground', 'danger', 'destructive'}.contains(key)) {
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
      // A destructive action (written `danger`, or a delete by its icon or
      // label) is the theme's error color; any other the accent.
      final danger = words['danger'] == 'true' ||
          words['destructive'] == 'true' ||
          RegExp(r'^(delete|remove|trash|discard)', caseSensitive: false).hasMatch(words['icon'] ?? label);
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
          'background': words['background'] ?? (danger ? (options.accent.startsWith('#') ? '#FFDC2626' : 'error') : options.accent),
          'foreground': words['foreground'] ?? '#FFFFFFFF',
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
    // following what is added there until the reader scrolls away);
    // `follow grow`: as tall as the room its column leaves (a chat over its
    // composer).
    final eachWords = <String, String>{};
    if (line.startsWith('each ')) {
      line = line.trimRight();
      final trailing = RegExp(r'\s(stagger=\S+|h=\d+(?:\.\d+)?|follow|grow|handle|reorder(?:=[A-Za-z_][A-Za-z0-9_]*)?)$');
      for (var m = trailing.firstMatch(line); m != null; m = trailing.firstMatch(line)) {
        final word = m[1]!, eq = word.indexOf('=');
        eachWords[eq < 0 ? word : word.substring(0, eq)] = eq < 0 ? '' : word.substring(eq + 1);
        line = line.substring(0, m.start).trimRight();
      }
      // Words after the list that are none of its own (`each k in list
      // reorder gap=2 onReorder={…}`) were read as part of the list's
      // formula, with no word said (test 9, kanban 4): the list ends where
      // its expression does, its own words after it are read, the others said.
      final eachHead = RegExp(r'^each\s+[A-Za-z_][A-Za-z0-9_]*\s+in\s+').firstMatch(line);
      if (eachHead != null) {
        final list = line.substring(eachHead.end);
        final end = _expressionEnd(list);
        if (end < list.length) {
          final others = <String>[];
          for (final w in _topLevelWords(list.substring(end))) {
            final own = RegExp(r'^(stagger=\S+|h=\d+(?:\.\d+)?|follow|grow|handle|reorder(?:=[A-Za-z_][A-Za-z0-9_]*)?)$').firstMatch(w);
            if (own != null) {
              final eq = w.indexOf('=');
              eachWords[eq < 0 ? w : w.substring(0, eq)] = eq < 0 ? '' : w.substring(eq + 1);
            } else {
              others.add(w);
            }
          }
          line = line.substring(0, eachHead.end + end).trimRight();
          if (others.isNotEmpty) {
            final shown = others.map((w) => w.length > 40 ? '${w.substring(0, 37)}…' : w).join(' ');
            _issue(column + eachHead.end + end,
                'An each line takes its list and its own words (reorder, reorder=group, stagger=80, follow, h=180, grow): $shown ${others.length == 1 ? 'is' : 'are'} not read there. Write ${others.length == 1 ? 'it' : 'them'} on the line the each is under (Column gap=2 reorder onReorder={…} over each k in list), or on the line under the each.');
          }
        }
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
    final eachGrows = eachWords.containsKey('grow');
    if (follows != (eachHeight != null || eachGrows) || eachHeight != null && eachGrows) {
      return _issue(column, 'A list that follows its end has a height to scroll in: each line in lines follow h=180, or follow grow to take the room its column leaves (a chat over its composer).');
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
      // Under a ListView or GridView line of its own, the list is that one:
      // it repeats over the data, and the line under the `each` is its
      // template (its first child), as a page view's page is under Pages.
      final listNode = nodes[parent.id];
      if (parent.grid == null &&
          parent.condition == null &&
          parent.each == null &&
          parent.slot == null &&
          (parent.type == 'listView' || parent.type == 'gridView' || parent.type == 'pageView') &&
          listNode != null &&
          readStrings(listNode['children']).isEmpty &&
          readMap(listNode['bind'])?['data'] == null &&
          eachWords.keys.every((k) => k == 'stagger')) {
        final data = {'data': _read(each[2]!.trim())};
        listNode['bind'] = {...?readMap(listNode['bind']), ...data};
        _patches.add({'op': 'patch', 'id': parent.id, 'patch': {'bind': data}});
        _stack.add(_Open(indent, parent.id, parent.type, each: each[1], list: each[2]!.trim()));
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
      // (A horizontal Flex is a row too.)
      final across = g == null && (parent.type == 'row' || (parent.type == 'flex' && (nodes[parent.id]?['props'] as Map?)?['direction'] == 'horizontal'));
      if (follows && (g != null || across)) return _issue(column, 'A list that follows its end runs down a Column, a Card or a Section, not across a Row or in a Grid.');
      final listName = each[2]!.trim();
      if (reorders && (g != null || across)) return _issue(column, 'A list that is reordered runs down a Column, a Card or a Section, not across a Row or in a Grid.');
      final isVariable = _identifier.hasMatch(listName) && !listName.contains('.') && variables.containsKey(listName);
      if (reorders && !isVariable) {
        return _issue(column, 'reorder writes the new order to a list variable: declare it (state $listName=[…]) and repeat it by name (each row in $listName reorder), or write reorder onReorder={…} on the line the each is under and store the move yourself (result.item, result.to). Rows moved between lists (a board) are a ListView\x27s: ListView reorder.group=board reorder.listKey={…} onReorder={…}.');
      }
      // The universal words of the line the list is under (docs/design/21
      // section 4.1): reorder, selectable, their events, a handle.
      final lw = _listUniversal[parent.id];
      var listReorder = false, listSelect = false;
      if (lw != null && !lw.applied) {
        lw.applied = true;
        // A list is reordered down a column, written to its variable (or,
        // over a formula, stored by its onReorder).
        listReorder = !reorders && lw.words.containsKey('reorder') && g == null && !across && (isVariable || lw.words.containsKey('onReorder'));
        listSelect = lw.words.containsKey('selectable');
        for (final e in lw.words.entries) {
          final read = switch (e.key) {
            'reorder' || 'handle' || 'onReorder' => listReorder,
            'selectable' || 'onSelect' => listSelect,
            'selected' => listSelect || listReorder,
            _ => false,
          };
          final event = e.key.startsWith('on');
          final of = event ? 'event' : (e.key == 'selected' || e.value.value != 'true' ? 'parameter' : 'flag');
          if (read || !lw.standIn) _use(read ? 'universal' : of, e.key, e.value.column, on: lw.on, of: of, value: read ? null : (event ? '{${e.value.value}}' : null), at: lw);
        }
      }
      final reorderNow = reorders || listReorder;
      _acrossLists[itemId] = listId;
      if (g != null) _gridLists[listId] = g.id;
      // `Row gap=8 wrap` over an each: the copies wrap onto further lines,
      // as the row's own children would.
      final rowProps = nodes[parent.id]?['props'] as Map?;
      final wraps = across && rowProps?['wrap'] == true;
      // The list does the wrapping and fills the row's width: a wrapping row
      // keeps each child at its own size along a line, which leaves a list
      // that is to fill it no width at all.
      if (wraps) {
        _wrapsMoved[parent.id] = rowProps?['runSpacing'];
        const Json patch = {
          'props': {'wrap': null, 'runSpacing': null},
        };
        nodes[parent.id] = mergePatch(nodes[parent.id]!, patch);
        _patches.add({'op': 'patch', 'id': parent.id, 'patch': patch});
      }
      // Across a row of a height of its own (`Row h=102` over the days of a
      // week) the list is as tall as the row, so a copy that fills its
      // height (`Column h=fill`) reaches it; across a hugging row it hugs.
      final fillsRow = across && !wraps && readMap(nodes[parent.id]?['layout'])?['height'] is num;
      nodes[listId] = {
        'type': g != null ? 'gridView' : 'listView',
        'layout': {
          'width': across && !wraps ? {'hug': 0} : {'fill': 0},
          'height': eachGrows || fillsRow ? {'fill': 0} : follows ? eachHeight : {'hug': 0},
          if (eachGrows) 'flex': 1,
        },
        // Its handles are one stop of the page: arrows go from row to row
        // (and so are the rows of a list that is selected from).
        if (reorderNow || listSelect) 'focusGroup': {'axis': g != null ? 'both' : across ? 'horizontal' : 'vertical', 'wrap': false},
        // Under a Grid, the repeated lines are its cells.
        'props': g != null
            ? {'crossAxisCount': g.cols, 'mainAxisSpacing': g.gap, 'crossAxisSpacing': g.gap, if (!g.cellLayout.containsKey('childAspectRatio')) 'shrinkWrapRows': true, 'physics': 'never', ...g.cellLayout}
            : across
                ? {
                    'scrollable': false,
                    'scrollDirection': 'horizontal',
                    'spacing': rowProps?['spacing'] ?? 0,

                    if (wraps) ...{'wrap': true, 'wrapSpacing': rowProps?['spacing'] ?? 0, 'runSpacing': rowProps?['runSpacing'] ?? rowProps?['spacing'] ?? 0},
                  }
                : {
                    'scrollable': follows,
                    if (follows) 'stickToEnd': true,
                    'spacing': (nodes[parent.id]?['props'] as Map?)?['spacing'] ?? 0,
                    if (reorderNow)
                      'reorder': {
                        // A universal reorder with no handle: a long press
                        // anywhere on the row picks it up.
                        'start': listReorder && !lw!.words.containsKey('handle') ? 'longPress' : 'handle',
                        'keyboard': true,
                        'apply': isVariable ? 'variable' : 'none',
                        if (reorderGroup.isNotEmpty) ...{'group': reorderGroup, 'listKey': listName},
                      },
                  },
        'bind': {
          'data': _read(each[2]!.trim()),
          if (parent.condition != null) 'visible': parent.condition,
          if (g?.colsFormula case final String cols) 'props.crossAxisCount': cols,
        },
        // `tablet.cols=2` on the Grid: its column count at that width.
        if (g != null && g.mediaCols.isNotEmpty) 'media': [for (final r in g.mediaCols) _copy(r)],
        'children': <Object?>[itemId],
      };
      if (g != null) g.mediaSaid = true;
      final listActions = <Json>[];
      // onReorder={…}: after a move, `result` the list in its new order (the
      // variable, already written; else the formula's list moved), and
      // result.from, result.to, result.item as the list gives them.
      if ((listReorder ? lw!.value('onReorder') : null) case final String body) {
        final moved = isVariable ? listName : 'move($listName, result.from, result.to)';
        final read = body.replaceAllMapped(RegExp(r'(?<![A-Za-z0-9_.])result(?![A-Za-z0-9_])(?!\s*\.\s*(?:from|to|item|fromList|toList)\b)'), (_) => '($moved)');
        listActions.add({'trigger': {'type': 'reorder'}, 'actions': _actions(read, column)});
      }
      // selectable: the selection kept in a list variable, by each row's key
      // (its id, else the element itself).
      String? selection;
      if (listSelect) {
        final sel = selection = lw!.value('selected') ?? '${notationIdWord(parent.id)}Selected';
        if (lw.value('selected') == null) _top._internal.add(sel);
        variables.putIfAbsent(sel, () => {'name': sel, 'type': 'list', 'value': const <Object?>[]});
        final onSelect = lw.value('onSelect');
        final then = onSelect == null || onSelect.trim().isEmpty ? '' : '; ${_rename(onSelect, 'result', sel)}';
        listActions.add({
          'trigger': {'type': 'keyDown', 'key': 'mod+a'},
          'actions': _actions('$sel = map($listName, x => coalesce(x.id, x)); announce "{length($sel)} selected"$then', column),
        });
      }
      if (listActions.isNotEmpty) nodes[listId]!['actions'] = listActions;
      final p = nodes[parent.id]!;
      ((p['children'] as List<Object?>?) ?? (p['children'] = <Object?>[])).add(listId);
      _parentOf[listId] = parent.id;
      if (eachGrows) _growToPane(parent.id);
      nodes[itemId] = {
        'type': 'column',
        'layout': across ? {'width': {'hug': 0}, 'height': wraps ? {'hug': 0} : {'fill': 0}} : {'width': {'fill': 0}, 'height': {'hug': 0}},
        // Across a row each copy is as tall as the row and sits in it where
        // the row says (`top`: at the top; columns of different heights
        // were centered whatever the row said).
        'props': {
          'crossAxisAlignment': 'start',
          if (across) 'mainAxisAlignment': const {'start': 'start', 'end': 'end'}[rowProps?['crossAxisAlignment']] ?? 'center',
        },
      };
      // `Row gap=12 phone.direction=vertical` over an each of copies of a
      // width (`Card w=365 phone.w=fill`; round 11b, conference, restaurant,
      // travel-guide): where the row turns down the page its copies do too,
      // one under another across the row's width; the list stayed a line
      // across, wider than a phone (24 of travel-guide's 28 errors).
      if (across && !wraps && g == null) {
        for (final rule in (nodes[parent.id]?['media'] as List?) ?? const []) {
          if (rule is! Map || ((rule['patch'] as Map?)?['props'] as Map?)?['direction'] != 'vertical') continue;
          final when = {for (final e in rule.entries) if (e.key != 'patch') e.key as String: e.value};
          (nodes[listId]!['media'] ??= <Object?>[]) as List
            ..add({
              ...when,
              'patch': {
                'props': {'scrollDirection': 'vertical'},
                'layout': {'width': {'fill': 0}},
              },
            });
          (nodes[itemId]!['media'] ??= <Object?>[]) as List
            ..add({
              ...when,
              'patch': {
                'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
                'props': {'mainAxisAlignment': 'start'},
              },
            });
        }
      }
      if (selection case final String sel) {
        // A tap selects the row alone, Ctrl or Cmd adds or removes it, Shift
        // takes the range from the last row chosen (Space and Enter on a
        // focused row the same); each change is announced, then onSelect.
        final anchor = '${sel}Anchor';
        variables.putIfAbsent(anchor, () => {'name': anchor, 'type': 'decimal', 'value': -1});
        final rows = _rename(listName, 'item', 'parent.item');
        const key = 'coalesce(item.id, item)';
        final onSelect = lw!.value('onSelect');
        final then = onSelect == null || onSelect.trim().isEmpty ? '' : '; ${_rename(onSelect, 'result', sel)}';
        final choose = _selectTaps[itemId] = _actions(
            '$sel = (result.shift && $anchor >= 0 ? map(slice($rows, min($anchor, index), max($anchor, index) + 1), x => coalesce(x.id, x)) : '
            '(result.meta ? (contains($sel, $key) ? without($sel, $key) : append($sel, $key)) : [$key])); '
            '$anchor = (result.shift && $anchor >= 0 ? $anchor : index); announce "{length($sel)} selected"$then',
            column);
        nodes[itemId]!
          ..['actions'] = [
            {
              'trigger': {'type': 'click'},
              'actions': choose,
            },
          ]
          ..['bind'] = {'selected': _formula('contains($sel, $key)')}
          ..['states'] = {
            'selected': {
              itemId: {
                'decoration': {
                  'fills': [
                    {'color': options.selectedFill},
                  ],
                },
              },
            },
          };
      }
      _parentOf[itemId] = listId;
      _stack.add(_Open(indent, itemId, 'column', each: each[1], list: each[2]!.trim()));
      return;
    }
    // `node {…}`: a node written whole, as the document holds it, for what
    // the notation has no words for (a painted board, a draggable list).
    // Nothing is added to it but its place; the lines under it are its
    // children, in the notation or as nodes again.
    final whole = RegExp(r'^node(?:#([A-Za-z_][A-Za-z0-9_]*(?:-[A-Za-z0-9_]+)*))?\s*(\{[\s\S]*)$').firstMatch(line);
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
      } else if (parent.slot != null) {
        _intoSlot(parent, id, column);
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
    // A quoted text the line ends inside (a line break typed in it): said,
    // with how a break is written; the line is read up to its end.
    if (RegExp(r'(?<!\\)"').allMatches(line).length.isOdd) {
      _issue(column, 'A quoted text is not closed on its line: a text is one line, a line break in it is written \\n ("one\\ntwo", and in an expression \'\\n\').');
    }
    final t = _Tokens(line);
    final head = RegExp(r'^([A-Za-z][A-Za-z0-9]*)(?:\.([A-Za-z][A-Za-z0-9]*))?(?:#([A-Za-z_][A-Za-z0-9_]*(?:-[A-Za-z0-9_]+)*))?').firstMatch(line);
    if (head == null) return _issue(column, 'A line starts with a node type: Column, Text "…", Button "…".');
    t.at = head.end;
    final written = head[1]!, variant = head[2];
    // `Button "Save" type=Button`: the design system's component of a name a
    // word of the notation has too, the node's type said by its own name
    // (design 22, 4.2).
    final named = catalog.widget(written) != null &&
        written[0] != written[0].toLowerCase() &&
        (LineParts.of(line)?.parts.any((p) => p.kind == 'pair' && (p.key == 'type' || p.key == 'node.type') && _unquoted(p.value!) == written) ?? false);
    // A design system's own Gauge, Ring, Sparkline or Avatar comes before the
    // notation's.
    final short = named || (_softNames.contains(written) && catalog.widget(written) != null) ? null : notationTypes[written];
    var type = short?.type ?? '${written[0].toLowerCase()}${written.substring(1)}';
    // A design system's component, called by its own name (`StatusBadge`,
    // `Stepper`): a core type of that name, or a short name, comes first.
    final component =
        named || short == null && (catalog.widget(type) == null || notationComponentFirst.contains(written)) && catalog.widget(written) != null;
    // Whether the notation's own Gauge, Ring, Avatar… is what this line is
    // (not a design system's component of that name).
    final ours = short != null;
    // The app's own component of a name the notation has a word for: the
    // word is read, so the call is not made. Said, with the way to call it.
    if (!component && options.ownComponents.contains(written) && catalog.widget(written) != null) {
      _issue(column,
          '$written is a word of the notation, so the component $written is not called here: call it as $written type=$written, or give the component a name of its own (My$written).');
    }
    if (component) type = written;
    // The text parameters a component's strings fill, and the ones filled so.
    var strings = const <String>[];
    final positional = <String>[];
    final node = <String, Object?>{};
    final props = <String, Object?>{}, layout = <String, Object?>{}, decoration = <String, Object?>{}, bind = <String, Object?>{};
    final reactions = <Json>[];
    // The reactions `menu=` gave the line, by trigger: what the line's own
    // onRightClick or onLongPress does runs in the same reaction before the
    // menu opens, whichever is written first.
    final menuReactions = <String, Json>{};
    // `center` and `middle` on a Stack; `animate:` and its timing.
    Set<String>? stackAlign;
    Json? animation;
    Map<String, int>? timing;
    // `Text "{row.title}" mark={q}`: the text as written, and what to mark in it.
    String? markText, markQuery;
    var selectedState = false;
    num? sliderStep;
    // `Slider @low @high`: the variable of its second thumb (and
    // of the last day of a Calendar's range).
    String? sliderEnd;
    int sliderEndColumn = 0;
    String? textLine;
    num? avatarSize;
    // `Avatar "{p.name}" initials="MR"`: the letters it shows, as written.
    String? avatarInitials;
    String? imageFit;
    Json? buttonLook;
    String? gaugeUnit;
    List<({String label, Object? value, Object? color})>? donutKeys;
    // Universal words (docs/design/21-universal-words.md) this line applied
    // where its type has no word of that name (recorded once it is read),
    // and what a stand-in left out (the rest of its words it honours).
    final universal = <({String word, int column, String of})>[];
    final dropped = <String>{};
    // The line's media rules in the order written: `phone.pad=16` (a
    // condition and a word), `hide=phone` (a rule as it is, no word).
    final mediaWords = <({Json condition, String? word, int column})>[];
    // Its states' words (`hovered.fill=…`, `btn.selected.color=…`) and its name.
    final stateWords = <_StateWord>[];
    var wroteColor = false;
    // A Flex written `scroll`: it scrolls along its direction.
    var flexScroll = false;
    // On a component's call, the sizes the line writes (its own win over the
    // component's rules at other widths).
    Set<String>? callSizes;
    // The keys of a Text's style that came from the body's look, not from
    // the line: a named style (from=title) the line names later replaces them.
    var seededStyle = const <String>{};
    final wroteStyle = <String>{};
    String? chipColor, fieldInk, fieldSize, listIcon, inputValue, removeActions;
    var disabledBy = '', required = false, clearable = false;
    ({String combo, int column})? lineShortcut;
    // The variable a control that may write fractions is bound to.
    String? decimalBound;
    ({String? label, String? actions})? slotAction;

    // With an open vocabulary a word that is not a type stands in: a column
    // of its texts and of the lines under it, recorded with what it was
    // given. A sentence around the UI is not a word.
    final open = options.openVocabulary;
    final standIn = open &&
        catalog.widget(type) == null &&
        written[0] == written[0].toUpperCase() &&
        ((_root != null && indent > 0) || _nodeLike(line));
    if (written == 'Button' && !component && variant != null) {
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
    } else if (written == 'Badge' && !component) {
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
    } else if (variant != null &&
        component &&
        catalog.widget(written)!.props.where((p) => p.type.kind == PropKind.enumeration && p.type.values.contains(variant)).firstOrNull != null) {
      // `Banner.warning`: a component's variant that is a value of one of its
      // choices (its tone) is that value, as `tone=warning` would be.
      final p = catalog.widget(written)!.props.firstWhere((p) => p.type.kind == PropKind.enumeration && p.type.values.contains(variant));
      props[p.key] = variant;
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
    if ((written == 'Card' && !component)) {
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
    if ((written == 'Card' && !component)) _cards.add(id);
    if (grid != null) props['spacing'] = grid.gap;
    final under = _stack.reversed.where((o) => o.condition != null).firstOrNull?.condition;
    if (_taken(id)) {
      _issue(column, _twice(id, under));
      return;
    }
    if (head[3] != null) _top._idAt.putIfAbsent(id, () => (line: _line, condition: under));
    _lastNode = id;
    // A stand-in, or the root of a use of a primitive declared with no lines:
    // what it draws is settled when it closes ([_silence]).
    if (_bareUse.remove(id) case final bare?) {
      _silent[id] = bare;
    } else if (standIn) {
      _silent[id] = _silentOf(written, LineParts.of(_src.startsWith(written) ? _src : line));
    }
    if (standIn) {
      final parts = LineParts.of(_src.startsWith(written) ? _src : line);
      final use = _use('type', written, column, node: id, parts: parts);
      if (_srcStack.isNotEmpty && _srcWord == written) _srcStack.last.use = use;
      if (parts != null && parts.strings.isEmpty) {
        final named = parts.parts.where((p) => p.kind == 'pair' && !p.isEvent && p.value!.startsWith('"') && !p.value!.contains('{')).firstOrNull;
        _bareStandIns[id] = named == null ? written : '$written · ${named.value!.substring(1, named.value!.length - 1)}';
      }
    }
    // The kinds of line a universal word reads differently on (a box: a
    // container, a stand-in, a defined word's root; a control).
    final boxLine = !component && const {'column', 'row', 'stack'}.contains(type);
    final controlLine = !component &&
        (_valueProps.containsKey(type) || type.endsWith('Button') || type.endsWith('Chip') || type == 'chip' || type == 'progressBar' || type == 'circularProgressIndicator');
    // A design system's block with a slot and no x of its own (a ListRow's
    // trailing): removable and onRemove put one at the end of the slot.
    final slotted = component &&
        spec.children == ChildModel.none &&
        spec.slots.isNotEmpty &&
        !spec.props.any((p) => p.key == 'removable') &&
        !spec.events.any((e) => e.key == 'onRemove');
    // A list's universal words (reorder, selectable and their events, a
    // handle, the selection's variable), read by the `each` under the line.
    final pre = LineParts.of(line);
    final listLine = boxLine && pre != null && const ['reorder', 'sortable', 'reorderable', 'selectable'].any(pre.has);
    final listWords = <String, ({String value, int column})>{};

    // A path of the node (`props.style.height`, `layout.constraints.maxWidth`,
    // `pan.axis`, `decoration.fills[0].color`) given its value, the maps and
    // lists on the way made as needed.
    // The paths written `key=null`: the field is not there (design 22, 4.2),
    // whatever the line would give it, taken out once the line is read.
    final nulled = <String>[];
    // The sections written `props=null` (none) and `props={}` (empty).
    final noSections = <String>{}, emptySections = <String>{};
    void put(String path, Object? value) {
      if (value == null) nulled.add(path);
      final dot = path.indexOf('.');
      final where = dot < 0 ? '' : path.substring(0, dot);
      final Json root = switch (where) { 'props' => props, 'layout' => layout, 'decoration' => decoration, _ => node };
      _setPath(root, root == node ? path : path.substring(dot + 1), value);
    }

    // The key as the catalog reads it (docs/design/22 section 2.1, keys.dart):
    // the path it sets and what is declared there. A key that is none of the
    // type's names is `unknownKey` (said, or recorded, once the line is read).
    var unknownKey = false;
    PropType? keyType;
    PropDef<Object?>? keyDef;
    String pathOf(String key) {
      unknownKey = false;
      keyType = null;
      keyDef = null;
      // `gap` where there is no spacing (a Text) is no word of that line.
      final short = _shortKeys[key];
      if (short != null && notationKey(key, type, catalog: catalog) != null) return short;
      if (key == 'enabled' && spec.props.any((p) => p.key == 'isEnabled')) return 'props.isEnabled';
      if ((key == 'lines' || key == 'rows') && type == 'textField') return 'props.maxLines';
      // `Input "Age" type=number`: the keyboard it opens.
      if (key == 'type' && type == 'textField' && !spec.props.any((p) => p.key == 'type')) return 'props.keyboardType';
      if ((key == 'selected' || key == 'checked') && (type == 'checkbox' || type == 'switch')) return 'props.value';
      if (resolveNotationField(key, type, catalog: catalog)?.key case final found?) {
        keyType = found.type;
        keyDef = found.def;
        return found.path;
      }
      unknownKey = true;
      return 'props.$key';
    }

    // `@name`: the variable a control keeps its value in, both ways ([param]:
    // a design system's block's other variable, `direction=@dir`). A shown
    // value worked out (`Progress {done/total}`) is followed, one way.
    void bindTo(String expr, int col, [PropDef<Object?>? param]) {
      final value = _valueProps[type];
      // A component keeps its value in the variable its parameter names.
      final held = param ??
          (!component
              ? null
              : spec.props.where((p) => p.type.isVariable && p.key == 'value').firstOrNull ?? spec.props.where((p) => p.type.isVariable).firstOrNull);
      if (held != null) {
        if (_identifier.hasMatch(expr) && expr.contains('.')) {
          // A field (`@draft.title`, `@i.done` under an each): the
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
          _issue(col, 'A $written keeps its ${held.key} in a variable: write ${held.key == 'value' || param == null ? '@name' : '${held.key}=@name'} (or @record.field, @row.field under an each).');
        } else {
          props[held.key] = expr;
          final (kind, start) = switch (held.type.variableOf?.kind) {
            PropKind.number || PropKind.integer => ('decimal', 0 as Object),
            PropKind.boolean => ('boolean', false as Object),
            PropKind.list => ('list', const <Object?>[] as Object),
            _ => ('text', '' as Object),
          };
          _bindsVariable(expr, col, () => start);
          if (_top._guessed.remove(expr)) variables.remove(expr);
          variables.putIfAbsent(expr, () => {'name': expr, 'type': kind, 'value': start});
          // Declared with a whole number (`state amount=0`), it is a number
          // here, not an integer: a NumberInput step=0.01 gives it cents,
          // which an integer variable would round away.
          if (held.type.variableOf?.kind == PropKind.number && variables[expr]?['type'] == 'integer' && !_projectVariables.contains(expr) && !_top._typedStates.contains(expr)) {
            variables[expr] = {...variables[expr]!, 'type': 'decimal'};
            _declared.remove(expr); // declared again, as it is now
          }
        }
      } else if (value == null) {
        final shown = _shownValue[type] ?? _mainKey(type, spec);
        if (written == 'Badge') {
          _texts.add(_read(expr));
        } else if (shown == null) {
          _issue(col, 'A $written has no value to show. Give a prop its value: key={expression}.');
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
        // A list bound whole (`state modes=["Public reply"]`, `@modes`) is
        // the selection itself (round 11b, support-desk: wrapped again, no
        // segment showed chosen).
        final listVar = type == 'segmentedButton' && _identifier.hasMatch(expr) && !expr.contains('.') && (variables[expr]?['value'] is List || variables[expr]?['type'] == 'list');
        final list = type == 'segmentedButton' && !listVar;
        bind['props.${value.prop}'] = list ? _formula('[$expr]') : _read(expr);
        if (_identifier.hasMatch(expr) && expr.contains('.')) {
          // A control bound to a field: of a record variable
          // (`Input @draft.title`), or of the repeated element
          // (`Input @field.label` under `each field in fields`, also a
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
          // `@colAll[r]` (an entry of a list or a map variable) and
          // `@find(clips,c=>c.id==sel).name` (a field of the record a
          // find picks): shown as read, and a change writes it back.
          final next = list ? 'result[0]' : 'result';
          final entry = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\[(.+)\]$').firstMatch(expr);
          final found = RegExp(r'^find\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*,\s*([A-Za-z_][A-Za-z0-9_]*)\s*=>\s*(.+)\)\.([A-Za-z_][A-Za-z0-9_]*)$').firstMatch(expr);
          final String? write;
          if (entry != null && variables.containsKey(entry[1]) && _closing(expr, entry[1]!.length) == expr.length - 1) {
            final v = entry[1]!;
            write = variables[v]!['value'] is Map ? '$v = with($v,${entry[2]},$next)' : '$v = setAt($v,${entry[2]},$next)';
          } else if (found != null && variables[found[1]]?['value'] is! Map) {
            // (A list another page declares is the site's: written the same way.)
            final (l, x) = (found[1]!, found[2]!);
            write = '$l = updateWhere($l,$x=>${found[3]},$x=>with($x,"${found[4]}",$next))';
          } else {
            write = null;
          }
          if (write == null) {
            _issue(col, 'A control is bound to a variable by its name (@name), to a field of a record variable (@draft.title), or under an each to a field of its element (@row.name): "$expr" is none of these. '
                'Show it and write the change yourself: value={$expr} onChange={<list>=updateWhere(<list>,x=>x.id==…,x=>with(x,"<field>",result))}.');
          } else {
            final eq = write.indexOf(' = ');
            reactions.insert(0, {
              'trigger': {'type': 'changed'},
              'actions': [
                {'type': 'setVariable', 'variable': write.substring(0, eq), 'value': _formula(write.substring(eq + 3))},
              ],
            });
          }
        } else if (_identifier.hasMatch(expr)) {
          _bindsVariable(expr, col, () => type == 'slider' && props['min'] is num ? props['min'] : value.start);
          if (_top._guessed.remove(expr)) variables.remove(expr);
          variables.putIfAbsent(expr, () => {'name': expr, 'type': value.type, 'value': props[value.prop] ?? value.start});
          // Whether it writes fractions is known once its ends are read.
          if (value.type == 'decimal') decimalBound = expr;
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
                        : type == 'tableView'
                            ? r'${result.rowIndex}'
                            // (A Calendar with one variable is one day:
                            // its result is that day.)
                            : r'${result}',
              },
            ],
          });
        }
      }
    }

    // `@name`, the variable itself (read and written): bare, the line's
    // value; `key=@name`, the property it names (a range's ends, a list's
    // selection, a block's other variables). One bare mark a line, but for
    // a control with two ends (`Slider @low @high`, `Calendar @from @to`).
    final range = !component && (type == 'slider' || type == 'calendar');
    final ends = type == 'calendar' ? const ('start', 'end') : const ('low', 'high');
    final mainParam = !component
        ? null
        : spec.props.where((p) => p.type.isVariable && p.key == 'value').firstOrNull ?? spec.props.where((p) => p.type.isVariable).firstOrNull;
    var bareMarks = 0, legacySaid = false;
    String? valueMark;
    // What this line can bind, as it is written.
    String binds() {
      final can = <String>[
        if (_valueProps.containsKey(type) && !component) 'its value (@name)',
        if (range && type == 'slider') 'a range (@low @high, or low=@low high=@high)',
        if (range && type == 'calendar') 'a range of days (@start @end, or start=@start end=@end)',
        if (mainParam != null) 'its ${mainParam.key} (@name)',
        for (final p in spec.props)
          if (component && p.type.isVariable && !identical(p, mainParam)) '${p.key}=@name',
        if (listLine) 'the rows chosen (selected=@name)',
      ];
      return can.isEmpty ? 'binds nothing' : 'binds ${can.join(', ')}';
    }

    void mark(String? named, String expr, int col) {
      if (expr.isEmpty || expr.startsWith('{') || expr.startsWith('"')) {
        _issue(col, '@ is followed by the variable\'s name: @name (a field: @draft.title). A value worked out is shown with value={expression}.');
        return;
      }
      // Which property: the line's value, a range's other end, a list's
      // selection, or a block's variable of that name.
      final String role;
      if (named == null) {
        bareMarks++;
        if (bareMarks == 1) {
          role = 'value';
        } else if (bareMarks == 2 && range) {
          role = 'end';
        } else {
          _issue(col, 'One @name a line is its value${range ? ', two a range (@low @high)' : ''}: name any other (key=@name). A $written ${binds()}.');
          return;
        }
      } else if (named == 'value' ||
          (range && named == ends.$1) ||
          (mainParam != null && named == mainParam.key) ||
          // The property that is the control's value, by its name
          // (`FilterChip "Unread" selected=@unread`, as NOTATION.md writes
          // `selected=@picked`): its value (refused: test 9, mail).
          (!component && !range && _valueProps[type]?.prop == named)) {
        role = 'value';
      } else if (range && named == ends.$2) {
        role = 'end';
      } else if (listLine && named == 'selected') {
        role = 'selected';
      } else if (component && spec.props.any((p) => p.key == named && p.type.isVariable)) {
        role = named;
      } else if (standIn) {
        role = named;
      } else {
        _issue(col, 'A $written has no "$named" to bind: it ${binds()}.');
        return;
      }
      if (role == 'value') {
        if (valueMark != null) {
          _issue(col, 'The $written\'s value is bound once: it is @$valueMark already.');
          return;
        }
        valueMark = expr;
      }
      // A stand-in keeps nothing: the variable is still the page's, and what
      // reads it reads its starting value.
      if (standIn) {
        dropped.add(named ?? '@$expr');
        if (_identifier.hasMatch(expr) && !expr.contains('.')) {
          _bindsVariable(expr, col, () => '');
          variables.putIfAbsent(expr, () => {'name': expr, 'type': 'text', 'value': ''});
        }
        return;
      }
      switch (role) {
        case 'end':
          if (valueMark == null) {
            _issue(col, 'A range binds both ends: ${type == 'calendar' ? 'Calendar @arrival @departure' : 'Slider @low @high min=0 max=100'}.');
            return;
          }
          sliderEnd = expr;
          sliderEndColumn = col;
        case 'selected':
          if (!_identifier.hasMatch(expr) || expr.contains('.')) {
            _issue(col, 'The rows chosen are kept in a list variable: selected=@picked (state picked=[]).');
            return;
          }
          listWords['selected'] = (value: expr, column: col);
          _bindsVariable(expr, col, () => const <Object?>[]);
        case 'value' when _valueProps.containsKey(type) || mainParam != null:
          bindTo(expr, col);
        case 'value':
          // A line that only shows a value, or has none.
          if (open && _shownValue[type] == null && written != 'Badge') {
            _use('parameter', '@', col, on: _srcWord ?? written, value: '@$expr');
            if (_identifier.hasMatch(expr) && !expr.contains('.')) {
              _bindsVariable(expr, col, () => '');
              variables.putIfAbsent(expr, () => {'name': expr, 'type': 'text', 'value': ''});
            }
          } else if (_shownValue[type] != null || written == 'Badge') {
            _issue(col, 'A $written shows a value and keeps none: ${type == 'text' || written == 'Badge' ? '$written "{$expr}"' : 'value={$expr}'}.');
          } else {
            _issue(col, 'A $written ${binds()}${listLine || !boxLine ? '' : ' (selectable on it: selected=@name)'}.');
          }
        default:
          bindTo(expr, col, spec.props.firstWhere((p) => p.key == role));
      }
    }

    var given = 0;
    var afterKey = false;
    final keysWritten = <String>{};
    // The keys the line names (`label="Installation"`), with what it gives
    // each: a string on it is not one of those (test 10, R41: `GuideSection
    // "01" label="…"` put "01" in the label, then said label was written
    // twice), unless the line gives that key the string itself.
    late final namedValues = component
        ? <String, String>{
            for (final p in LineParts.of(line)?.parts ?? const <LinePart>[])
              if (p.kind == 'pair' && p.key != null)
                p.key!.startsWith('props.') ? p.key!.substring(6) : p.key!: RegExp(r'^"(.*)"$').firstMatch(p.value ?? '')?[1] ?? p.value ?? '',
          }
        : const <String, String>{};
    late final namedOnLine = namedValues.keys.toSet();
    // A component's strings fill its text parameters in order.
    void componentString(String raw, int col) {
      final text = _interpolate(raw);
      bool given(String k) => props.containsKey(k) || bind.containsKey('props.$k');
      bool free(String k) => !given(k) && (!namedValues.containsKey(k) || namedValues[k] == raw);
      // Past the strings it is known by, a further string goes to its next
      // text parameter not yet given, in the order they are declared
      // (CartLine "Bananas" "1 kg" "$2.49": the price). One every text
      // parameter of which the line names goes to the first (and the key
      // is then said written twice).
      final key = strings.where(free).firstOrNull ??
          spec.props.where((p) => p.type.kind == PropKind.string && free(p.key)).firstOrNull?.key ??
          strings.where((k) => !given(k)).firstOrNull ??
          spec.props.where((p) => p.type.kind == PropKind.string && !given(p.key)).firstOrNull?.key;
      if (key == null) {
        _issue(col, 'A $written takes ${strings.isEmpty ? 'no string' : 'no more strings (${strings.join(', ')})'}: write the rest as key="value".');
      } else if (text.contains(r'${')) {
        bind['props.$key'] = text;
        positional.add(key);
      } else {
        props[key] = text;
        positional.add(key);
      }
    }

    // A universal flag (docs/design/21) on a line whose type has no word of
    // that name, written bare or `=true` ([value]): whether it was read.
    // An Input's own words (section 7) are read here too.
    bool universalFlag(String word, int col, {String value = 'true', String of = 'flag'}) {
      final w = const {'sortable': 'reorder', 'reorderable': 'reorder', 'readonly': 'readOnly'}[word] ?? word;
      void used() => universal.add((word: word, column: col, of: of));
      switch (w) {
        case 'reorder' || 'selectable' when listLine:
          listWords[w] = (value: value, column: col);
          return true;
        case 'handle' when listLine:
          listWords['handle'] = (value: value, column: col);
          return true;
        case 'removable' when value == 'true' && (boxLine || type == 'listTile' || type.endsWith('Chip') || type == 'chip'):
          removeActions ??= '';
          used();
          return true;
        case 'readOnly' when controlLine && value == 'true':
          // A control with no read-only of its own shows its value and
          // takes no input: no pointer, no focus.
          node['ignorePointer'] = true;
          used();
          return true;
        case 'required' when value == 'true' && const {'textField', 'checkbox', 'switch'}.contains(type):
          required = true;
          used();
          return true;
      }
      if (type != 'textField' || value != 'true') return false;
      switch (w) {
        case 'clearable':
          clearable = true;
        case 'autogrow':
          // From one line to six (or to its lines=).
          props['minLines'] = 1;
          props.putIfAbsent('maxLines', () => 6);
        case 'caps':
          props['textCapitalization'] = 'characters';
        case 'center' || 'right':
          props['textAlign'] = w;
        case 'fuzzy':
          // Fuzzy matching is the filtered list's: on the field it is nothing.
          _issue(col, 'fuzzy belongs to the list that is filtered, not to the field: filter(items, x => fuzzy(x.name, q)). It does nothing on an Input.');
          if (open) _use(of == 'parameter' ? 'parameter' : 'flag', word, col, on: _srcWord ?? written, value: of == 'parameter' ? value : null);
        default:
          return false;
      }
      return true;
    }

    while (true) {
      t.skipSpace();
      if (t.done) break;
      final col = column + t.at;
      // `Icon {playing ? "pause" : "play_arrow"}`, `Badge {ok ? "Pass" :
      // "Fail"}`: an expression where the text goes (before any string, on a
      // word we have) is that value, as "{…}" would be.
      String? valued;
      if (t.peek == '{' && given == 0 && !standIn && _positional(t, type, standIn) == null) {
        final braced = (_Tokens(t.s)..at = t.at).balanced();
        if (braced.endsWith('}') && _bracedExpression(braced)) {
          valued = braced;
          t.at += braced.length;
        }
      }
      if (valued != null || t.peek == '"') given++;
      if ((valued != null || t.peek == '"') && component) {
        componentString(valued ?? t.string(), col);
      } else if (valued != null || t.peek == '"') {
        final text = valued ?? t.string();
        if (_stringProblem(type, written, given) case final problem?) {
          // Design 13 section 3: one main string; a second only where the
          // word gives it a place (an Input's hint, a container's next text,
          // a tile's subtitle). Said, and the first is kept.
          _issue(col, problem);
        } else {
          if (type == 'text') markText ??= text;
          _main(type, spec, text, props, decoration);
        }
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
            // A tail that gives the node another type gives its props too.
            final own = tail['type'] is String ? catalog.widget(tail['type']! as String) ?? spec : spec;
            for (final e in guessed.entries) {
              final k = e.key, v = e.value;
              // null takes away what the line's words gave.
              if (v == null || own.props.any((p) => p.key == k)) {
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
                if (v == true) {
                  kept.addAll({'minLines': 3, 'maxLines': 6});
                  _multilineWord.add(id);
                }
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
          // The tail is the last word on the node: merged again once the text
          // is read, over what later lines add (a parent's sizes, its alignment).
          (_lineTails[id] ??= <String, Object?>{}).addAll(_copy(tail));
        } else {
          _issue(col, 'The {…} tail is a JSON object merged into the node.');
        }
        break;
      } else {
        final from = t.at;
        // `onKeyDown(key=Enter)={…}`: an event with its trigger's fields.
        final withFields = _Events.withFields(t.s, t.at);
        var word = withFields == null ? t.word() : '${withFields.$1}=';
        if (withFields != null) t.at = withFields.$3;
        // A flag written as a key (`Main scroll=false`, `Row phone.stretch=true`,
        // `tablet.scroll=true`; round 11b, 6 builds): `=true` is the flag,
        // `scroll=false` the box that does not scroll (`scrollable=false`).
        // The reference shows flags given values (`hidden={…}`) and a key
        // after a condition as "any key the line reads".
        if ((withFields == null ? _flagKey.firstMatch(word) : null) case final f? when !spec.props.any((p) => p.key == f[2])) {
          if (f[3] == 'true') {
            word = '${f[1] ?? ''}${f[2]}';
          } else if (f[2] == 'scroll') {
            word = '${f[1] ?? ''}scrollable=false';
          }
        }
        // Where the strings go: before any key=value or bare word.
        final textPosition = !afterKey;
        afterKey = true;
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
        if (_stateWord(t, word, from, type, col, stateWords) || _nameWord(t, word, from, spec, node, col)) continue;
        final eq = word.indexOf('=');
        if (word.startsWith('@')) {
          mark(null, word.substring(1), col);
          continue;
        }
        // `phone.pad=16`, `max899.hidden`: the line's value at other widths
        // (docs/design/22 section 2.4), unless the type has a prop of that name.
        if (mediaCondition(eq < 0 ? word : word.substring(0, eq)) case final m? when !spec.props.any((p) => p.key == word.substring(0, m.length - 1).split('.').first)) {
          if (eq == word.length - 1 && t.peek == '"') t.string();
          if (eq == word.length - 1 && (t.peek == '{' || t.peek == '[')) t.balanced();
          final ruleWord = t.s.substring(from + m.length, t.at);
          if (m.problem != null) {
            _issue(col, m.problem!);
          } else if (grid != null && RegExp(r'^(cols|columns)=').hasMatch(ruleWord)) {
            // `tablet.cols=2`: the grid's column count at that width, a rule of
            // the grid its `each` makes.
            final value = ruleWord.substring(ruleWord.indexOf('=') + 1);
            final n = int.tryParse(value);
            // `tablet.cols={max(2, gridColumns - 2)}`: worked out at that
            // width, as `cols={…}` is (round 11b, photo-library: refused,
            // with a message that read as if 2 were out of range).
            final worked = n == null && value.startsWith('{') && value.endsWith('}') && value.length > 2 ? _formula('max(1, round(${value.substring(1, value.length - 1).trim()}))') : null;
            if (worked != null) {
              if (!_mediaLine) {
                if (grid.mediaCols.isEmpty) {
                  grid
                    ..mediaLine = _line
                    ..mediaColumn = col;
                }
                grid.mediaCols.add({
                  ...m.condition,
                  'patch': {
                    'bind': {'props.crossAxisCount': worked},
                  },
                });
                num widest(Json r) => (r['maxWidth'] as num?) ?? double.infinity;
                final order = [for (var i = 0; i < grid.mediaCols.length; i++) (i, grid.mediaCols[i])]
                  ..sort((a, b) => widest(b.$2).compareTo(widest(a.$2)) != 0 ? widest(b.$2).compareTo(widest(a.$2)) : a.$1.compareTo(b.$1));
                grid.mediaCols
                  ..clear()
                  ..addAll([for (final e in order) e.$2]);
              }
            } else if (n == null || n < 1 || n > 24) {
              _issue(col, "A Grid's columns at a width are a number from 1 to 24: ${t.s.substring(from, from + m.length - 1)}.cols=2.");
            } else if (!_mediaLine) {
              if (grid.mediaCols.isEmpty) {
                grid
                  ..mediaLine = _line
                  ..mediaColumn = col;
              }
              grid.mediaCols.add({...m.condition, 'patch': {'props': {'crossAxisCount': n}}});
              // The narrower width's rule after the wider's, so it wins where
              // both hold (`phone.cols=2 tablet.cols=3` gave a phone 3).
              num widest(Json r) => (r['maxWidth'] as num?) ?? double.infinity;
              final order = [for (var i = 0; i < grid.mediaCols.length; i++) (i, grid.mediaCols[i])]
                ..sort((a, b) => widest(b.$2).compareTo(widest(a.$2)) != 0 ? widest(b.$2).compareTo(widest(a.$2)) : a.$1.compareTo(b.$1));
              grid.mediaCols
                ..clear()
                ..addAll([for (final e in order) e.$2]);
            }
          } else if (!_mediaLine) {
            mediaWords.add((condition: m.condition, word: ruleWord, column: col));
          }
          continue;
        }
        if (eq == 0) {
          _issue(col, 'A value has a key: write @name for the variable a control keeps its value in, key={expression} for a value worked out.');
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
          // `Row#window keep`: the reflow leaves it, and what is in it, as
          // written at every width (the writer lays it out by width).
          if (word == 'keep' && !component && const {'row', 'column', 'flex', 'stack', 'listView', 'gridView', 'wrap'}.contains(type)) {
            _keep.add(id);
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
            if (!props.containsKey('minLines')) _multilineWord.add(id);
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
          } else if (_mainWords[word] case final String m when type == 'row' || type == 'column' || type == 'flex') {
            props['mainAxisAlignment'] = m;
          } else if (_crossWords[word] case final String c when type == 'row' || type == 'column' || type == 'flex') {
            props['crossAxisAlignment'] = c;
            _crossWritten.add(id);
          } else if (num.tryParse(word) != null && (_valueProps[type]?.type == 'decimal' || _shownValue[type] == 'value')) {
            // A bare number on a slider or a progress bar is its value.
            props['value'] = num.parse(word);
          } else if (textPosition && num.tryParse(word) != null && component && spec.props.any((p) => p.key == 'value' && !p.type.isVariable && (p.type.kind == PropKind.number || p.type.kind == PropKind.integer))) {
            // …and on a component whose value is a number (docs/design/21 §8).
            props['value'] = num.parse(word);
          } else if (textPosition && num.tryParse(word) != null && (component || standIn || _textAt(type, written))) {
            // A bare number where the text goes is the text (`Footnote 1`,
            // `CountUp 39`, `Badge 3`): docs/design/21 section 8.
            if (component) {
              componentString(word, col);
            } else {
              if (type == 'text') markText ??= word;
              _main(type, spec, word, props, decoration);
            }
          } else if (word == 'grow') {
            layout['flex'] = 1;
          } else if (word == 'scroll' && (type == 'column' || type == 'row' || type == 'flex')) {
            props['scrollable'] = true;
            flexScroll = type == 'flex';
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
            // A bar across the top (SiteNav, a TopBar, a Header, a site's
            // Masthead or Mast: test 10, a 16 px gap above it) stays at the
            // very top.
            node['sticky'] = {'offset': RegExp(r'(Nav|Bar|Header|Head|Mast|Masthead)$').hasMatch(written) ? 0 : 16};
          } else if (word == 'disabled' && component && spec.props.any((p) => p.key == 'disabled' && p.type.kind == PropKind.list)) {
            // `ChoiceChips disabled`: off as a whole (its own disabled lists the options that are off).
            bind['disabled'] = _formula('true');
            disabledBy = 'true';
          } else if ((word == 'reorder' || word == 'handle') && !component && (type == 'listView' || type == 'gridView')) {
            // `ListView reorder handle onReorder={…}`: its rows are dragged
            // into a new order, by a Handle with `handle` (else a long press
            // anywhere on the row). A bare `reorder` was `true`, which is no
            // reorder record: the list did not reorder, with no word.
            final before = readMap(props['reorder']) ?? const {};
            props['reorder'] = {...before, 'keyboard': true, 'start': word == 'handle' ? 'handle' : before['start'] ?? 'longPress'};
          } else if (spec.props.any((p) => p.key == word)) {
            props[word] = true;
          } else if (!component && universalFlag(word, col)) {
            // A universal word (docs/design/21), or an Input's own (section 7).
          } else if (type == 'icon' && !component && !standIn && given == 0 && textPosition && RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(word)) {
            // `Icon download` (and `icon=download` on a NavItem, which writes
            // that line): a bare word where the name goes is the icon's name,
            // as icon=download is on a Button, whatever a variable is called.
            // One chosen by data is braced: Icon {glyph}.
            given++;
            _main(type, spec, word, props, decoration);
          } else if (word == 'removable' && slotted) {
            // A block with a slot and no x of its own (a ListRow): one at the
            // end of its slot.
            removeActions ??= '';
            universal.add((word: word, column: col, of: 'flag'));
          } else if (word == 'clearable' && component && spec.events.any((e) => e.key == 'onClear')) {
            // A block with a clear of its own (a SearchBar's x) is clearable.
            universal.add((word: word, column: col, of: 'flag'));
          } else if (word == 'clip' && component && spec.prop('clip') == null) {
            _issue(col, 'A $written has no "clip". ${_callLookWhy(written)}');
          } else if (word == 'resizable' && !component && !standIn) {
            // Round 10, R50 (6 runs): accepted and ignored, or refused as an
            // unknown word. A Splitter says it (once: a pane's line is read
            // again as the lines it writes).
            if (!_quiet && _top._said.add('resizable')) _issue(col, _resizable);
          } else if (word == 'live' && !standIn) {
            // Read out as it changes: a Text's (and a block's that takes live).
            _issue(col, 'live is a Text\x27s: the Text whose words change is read out when they do. Put it on that Text (Text "{status}" live), or say the change with announce "…" in the action that makes it.');
          } else if (RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*)+$').hasMatch(word)) {
            // Text plan.name: a value shown as text is in a string.
            // The line's x was read as `item`: say it by the name written.
            final x = _stack.reversed.where((o) => o.each != null).firstOrNull?.each;
            final shown = x != null && word.startsWith('item.') ? '$x${word.substring(4)}' : word;
            _issue(col, 'A value shown as text is written in a string: "{$shown}".');
          } else if (standIn) {
            // Whatever a stand-in was given is in its record.
            dropped.add(word);
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
        // `type=Button` said which type the line is (above).
        if (named && (key == 'type' || key == 'node.type') && _unquoted(word.substring(eq + 1)) == written) continue;
        // A key written twice (`Progress value={x} value=0.5`): one of the
        // two is lost, whichever it is.
        // (A line read again with a rule's or a state's words after its own
        // has them over its own: `hovered.fill=…` is no second fill=.)
        // An event with its trigger's fields is one by those fields too:
        // `onKeyDown(key=ArrowDown)={…} onKeyDown(key=ArrowUp)={…}` are two.
        final written2 = withFields == null ? key : '$key(${withFields.$2.replaceAll(' ', '')})';
        if (!keysWritten.add(written2) && !_mediaLine) _issue(col, '$written2= is written twice on this line: one of them is lost. Write it once.');
        if (written == 'CodeInput' && (key == 'length' || key == 'digits')) key = key == 'length' ? 'otpLength' : 'otpDigitsOnly';
        // `Sidebar w={railWidth} resizable=@railWidth` (round 10, R50): a Splitter says it.
        if (key == 'resizable' && !component && !standIn && spec.prop('resizable') == null) {
          if (!_quiet && _top._said.add('resizable')) _issue(col, _resizable);
          if (word.length == eq + 1 && (t.peek == '{' || t.peek == '[')) t.balanced();
          continue;
        }
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
        // `hide={!running}`, `show={open}`: a condition, which is what
        // visible= says (hide the opposite). Models write them often.
        if ((key == 'show' || key == 'hide') && !sizeWord && !spec.props.any((p) => p.key == key) && word.length == eq + 1 && t.peek == '{') {
          final braced = t.balanced();
          final cond = braced.substring(1, braced.endsWith('}') ? braced.length - 1 : braced.length).trim();
          if (cond.isNotEmpty) {
            bind['visible'] = _formula(key == 'hide' ? '!($cond)' : cond);
            continue;
          }
        }
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
          if (withFields == null) t.at = from + eq + 1;
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
          // A list's events (docs/design/21): read by the each under it; a
          // removable line's (or chip's) x.
          if (!component && (key == 'onReorder' || key == 'onSelect') && listLine) {
            listWords[key] = (value: body, column: col);
            continue;
          }
          // `SectionHeader "Files" action="View all" onAction={go files}`: a
          // block with a slot and no action of its own: a quiet button in it.
          if (key == 'onAction' && slotted && !spec.events.any((e) => e.key == 'onAction')) {
            slotAction = (label: slotAction?.label, actions: body);
            continue;
          }
          if (key == 'onRemove' && (slotted || (!component && (boxLine || type == 'listTile' || type.endsWith('Chip') || type == 'chip')))) {
            removeActions = body;
            universal.add((word: key, column: col, of: 'event'));
            continue;
          }
          var trigger = _handlerTrigger(key, type, component ? spec : null, node);
          // A key pressed in the field (result.key, also read as a bare
          // `key`; Enter is onSubmit).
          var keyBody = body;
          if (key == 'onKeyDown' && type == 'textField') {
            trigger = {'type': 'keyDown'};
            keyBody = _rename(body, 'key', 'result.key');
          }
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
            if (standIn) dropped.add(key);
            continue;
          }
          if (trigger == null) {
            _issue(col, _Events.noEvent(written, key, component ? spec : null));
            continue;
          }
          if (withFields != null) triggerFields(trigger, withFields.$2, col);
          final actions = _actions(keyBody, col);
          // A menu opened by a right click or a long press sits where the pointer is.
          if (trigger['type'] == 'secondaryClick' || trigger['type'] == 'longPress') actions.forEach(_atPointer);
          if (menuReactions[trigger['type']] case final Json menu when trigger.length == 1) {
            menu['actions'] = [...actions, ...(menu['actions'] as List)];
            continue;
          }
          reactions.add({'trigger': trigger, 'actions': actions});
          continue;
        }
        var raw = word.substring(eq + 1);
        if (raw.startsWith('@')) {
          mark(key, raw.substring(1), col);
          continue;
        }
        // `bind=` is no key: a variable is `@name`. Said with the line in
        // the form the notation reads.
        if (RegExp(r'^bind([A-Z][A-Za-z]*)?$').hasMatch(key) && !spec.props.any((p) => p.key == key)) {
          if (raw.isEmpty && (t.peek == '{' || t.peek == '[')) t.balanced();
          if (raw.isEmpty && t.peek == '"') t.string();
          if (standIn) dropped.add(key);
          final shownLine = _src.contains('bind') ? _src : line.trim();
          if (!legacySaid) _issue(col, 'A variable is bound with @: @name is the control\'s value, key=@name another property. Write: ${notationBindForm(shownLine, catalog: catalog)}');
          legacySaid = true;
          continue;
        }
        // A block's variable is named with @ (`direction=@dir`): a bare name
        // there keeps nothing. A value, or one worked out in braces, is
        // shown, one way (`Rating value=4.6`).
        if (component && spec.props.any((p) => p.key == key && p.type.isVariable) && _variablePath.hasMatch(raw) && !const {'true', 'false', 'null'}.contains(raw)) {
          _issue(col, 'A $written keeps its $key in a variable: write $key=@$raw${identical(spec.props.firstWhere((p) => p.key == key), mainParam) ? ' (or @$raw)' : ''}; $key={$raw} shows its value, one way.');
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
        // Under an each, the menu's lines read the pressed row by the loop's
        // name (`MenuItem "Copy" onTap={copy "{c.name}"}` for `each c in
        // clips`): a page variable of that name is set to the row's item
        // before the menu opens (in the row its name is still the item).
        if (key == 'menu' && _identifier.hasMatch(raw) && !raw.contains('.') && !spec.props.any((p) => p.key == 'menu')) {
          final eaches = [for (final o in _stack) if (o.each != null) o.each!];
          final pressed = <Json>[
            for (var k = 0; k < eaches.length; k++)
              {'type': 'setVariable', 'variable': eaches[k], 'value': '\${= ${'parent.' * (eaches.length - 1 - k)}item}'},
          ];
          for (var k = 0; k < eaches.length; k++) {
            final name = eaches[k];
            if (variables.containsKey(name)) continue;
            final start = _sample('${'parent.' * (eaches.length - 1 - k)}item');
            variables[name] = {
              'name': name,
              'type': switch (start) { bool _ => 'boolean', int _ => 'integer', num _ => 'decimal', List _ => 'list', Map _ => 'map', _ => 'text' },
              'value': switch (start) { bool _ => false, num _ => 0, List _ => <Object?>[], Map _ => <String, Object?>{}, _ => '' },
            };
            if (start == null) _top._guessed.add(name);
          }
          for (final trigger in const ['secondaryClick', 'longPress']) {
            final actions = _actions('open $raw', col);
            actions.forEach(_atPointer);
            // An onRightClick or onLongPress written before it runs first.
            final own = reactions.where((r) => (r['trigger'] as Map).length == 1 && (r['trigger'] as Map)['type'] == trigger).firstOrNull;
            if (own != null) {
              own['actions'] = [...(own['actions'] as List), ...pressed, ...actions];
              menuReactions[trigger] = own;
            } else {
              final Json reaction = {'trigger': {'type': trigger}, 'actions': [...pressed, ...actions]};
              reactions.add(reaction);
              menuReactions[trigger] = reaction;
            }
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
          // (A field's own word at a dotted key too: `transformGesture.wheel=zoom`
          // beside a `zoom` variable; round 11b, 2 builds.)
          bool enumHas(PropType? t) => t != null && t.kind == PropKind.enumeration && t.values.contains(raw);
          final ownValue = spec.props.any((p) => p.key == key && enumHas(p.type)) ||
              (key.contains('.') && !component && enumHas(notationKey(key, type, catalog: catalog)?.type));
          // A key whose value is always a word (a field's type, an icon's
          // name) keeps it, whatever a variable is called:
          // Input "Email" type=email @email.
          const wordKeys = {'type', 'icon', 'align', 'weight', 'tone', 'variant'};
          // A key that names a variable (`measure.variable=pos`,
          // `pan.xVariable=panx`) takes the name, not its value.
          final namesVariable = key.endsWith('.variable') || key.endsWith('Variable') || key == 'variable';
          // A theme's color or text style of that name (`fill=panel`,
          // `style=tick` with a `panel` or `tick` variable too) is the theme's:
          // a bare word is a word, braces read the variable.
          final themeWord = options.palette.containsKey(raw) || options.themeColors.contains(raw) || (options.textStyles.containsKey(raw) && (key == 'style' || key == 'from'));
          if (known && !ownValue && !wordKeys.contains(key) && !namesVariable && !themeWord) {
            _issue(col, 'A value read from the state is written in braces: $key={$raw}.');
            continue;
          }
        }
        // Flutter's names for a Grid's words (test 10: Grid crossAxisCount=,
        // crossAxisSpacing=, mainAxisSpacing=, mainAxisExtent=): read as the
        // notation's, recorded as aliases. A Grid has one gap.
        // A field's fixed height, as the reference gives it: the box's (one
        // step of the control scale), its label above it ([_labelledFieldHeights]).
        if (type == 'textField' && !component && key == 'h' && num.tryParse(raw) != null) _fieldHeights[id] = num.parse(raw);
        if (key == 'w' && raw == 'fill') _writtenFills.add(id);
        // `Stack … clipBehavior=hardEdge`: what is in it is cut at its edge,
        // the decoration's clip (a stack's own clipBehavior is its scroll
        // view's, and `hardEdge`, its default, is not kept: it drew past its
        // edge; round 11b, clip-editor's timeline).
        if (type == 'stack' && !component && key == 'clipBehavior' && const {'hardEdge', 'antiAlias', 'antiAliasWithSaveLayer'}.contains(raw)) {
          decoration['clip'] = raw;
          continue;
        }
        if ((grid == null ? null : const {'crossAxisCount': 'cols', 'crossAxisSpacing': 'gap', 'mainAxisSpacing': 'gap'}[key]) case final String to) {
          _use('alias', key, col, of: 'parameter', to: to, on: written);
          key = to;
        }
        if (grid != null && (key == 'mainAxisExtent' || key == 'childAspectRatio') && num.tryParse(raw) != null) {
          // A cell's height (or its width over its height): the gridView's
          // own, for the cells an each repeats; a row's height for cells
          // written one by one.
          _use('alias', key, col, of: 'parameter', to: key == 'mainAxisExtent' ? 'h' : 'aspectRatio', on: written);
          grid.cellLayout[key] = num.parse(raw);
          continue;
        }
        if (grid != null && (key == 'cols' || key == 'columns')) {
          // `cols={gridSize}`: worked out, for the cells an each repeats (cells
          // written one by one are laid in rows here, at the default).
          if (raw.startsWith('=')) {
            grid.colsFormula = _formula('max(1, round(${raw.substring(1)}))');
          } else {
            grid.cols = (int.tryParse(raw) ?? 2).clamp(1, 24);
          }
          continue;
        }
        // `Image url="…"` (test 10: 6 runs), `Image src={…}`: the picture,
        // as the string after the word is.
        if ((key == 'url' || key == 'src') && written == 'Image' && !component && !spec.props.any((p) => p.key == key)) {
          if (key == 'url') _use('alias', key, col, of: 'parameter', to: 'src', on: written);
          given++;
          _main(type, spec, raw.startsWith('=') ? '{${raw.substring(1)}}' : _unquoted(raw), props, decoration);
          continue;
        }
        if (grid != null && (key == 'gap' || key == 'spacing')) {
          grid.gap = num.tryParse(raw) ?? 8;
          props['spacing'] = grid.gap;
          continue;
        }
        // `Input "" "Message" fill=#FFF3F4F6 border=none radius=20`: the
        // field's own box, its decoration's fill, border and corners (on the
        // node they drew nothing, and radius was left out). border=none with
        // no fill is a bare field: no border, no fill (the box around it is
        // its frame).
        // A state's or a media rule's word reads the same (`focused.fill=`
        // on an Input: its box's fill while it has the focus).
        if (const {'textField', 'datePicker', 'timePicker'}.contains(type) && !component && const {'fill', 'border', 'radius', 'borderColor', 'border-color'}.contains(key) && !(key == 'border' && raw.startsWith('='))) {
          final field = (props['decoration'] as Json?) ?? (props['decoration'] = <String, Object?>{});
          Json border() => (field['border'] as Json?) ?? (field['border'] = <String, Object?>{'type': 'outline'});
          final v = raw.startsWith('=') ? null : _value(raw);
          if (key == 'fill') {
            if (raw.startsWith('=')) {
              field['filled'] = true;
              bind['props.decoration.fillColor'] = _namedIn(_read(raw.substring(1)), 'fill');
            } else if (v == 'none' || v == 'transparent') {
              field['filled'] = false;
            } else {
              // (The color first: a state's print reads `fill=` from it.)
              field['fillColor'] = _named(v, 'fill');
              field['filled'] = true;
            }
          } else if (key == 'radius') {
            if (raw.startsWith('=')) {
              bind['props.decoration.border.borderRadius'] = _read(raw.substring(1));
            } else if (v is num) {
              border()['borderRadius'] = v;
            }
          } else if (v == 'none' || v == false || v == 0) {
            border()['type'] = 'none';
            if (!field.containsKey('fillColor') && !bind.containsKey('props.decoration.fillColor')) field['filled'] = false;
          } else if (v is num) {
            ((border()['borderSide'] as Json?) ?? (border()['borderSide'] = <String, Object?>{}))['width'] = v;
          } else if (v != null) {
            ((border()['borderSide'] as Json?) ?? (border()['borderSide'] = <String, Object?>{}))['color'] = _named(v, 'stroke');
          }
          continue;
        }
        // `Select … fill=paper border=rule radius=7`: the line's box is the
        // Select's frame, as an Input's are its field's; the Select draws
        // none of its own inside it ([_framedSelects]).
        if (type == 'dropdown' && !component && const {'fill', 'border', 'borderColor', 'border-color'}.contains(key)) {
          final v = raw.startsWith('=') ? null : _value(raw);
          if (v != 'none' && v != 'transparent' && v != false && v != 0) _framedSelects.add(id);
        }
        if (type == 'dropdown' && !component && key == 'underline') _ownFrameSaid.add(id);
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
            final tint = (written == 'Card' && !component) && raw8 is String && RegExp(r'^#[0-9A-Fa-f]{8}$').hasMatch(raw8) && !raw8.toUpperCase().startsWith('#FF');
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
        if ((key == 'unit' || key == 'label') && type == 'radialGauge' && ours) {
          gaugeUnit = _literal(raw).$2?.toString() ?? raw;
          continue;
        }
        if (key == 'color' && type == 'lineChart') key = 'lineColor';
        // A design system's Avatar that sizes by name: a number is the
        // nearest. One whose size is a number (Desk's diameter) takes the
        // number (a fresh build's `Avatar "…" size=32` drew no disc).
        if (key == 'size' &&
            component &&
            written == 'Avatar' &&
            num.tryParse(raw) != null &&
            !const {PropKind.number, PropKind.integer}.contains(spec.prop('size')?.type.kind)) {
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
        // `selected={…}` where the type has no selected value (a row of a
        // list, an IconButton, a Button): the node's selected state, which
        // its look follows as it does a hover (a box: the theme's selected
        // fill).
        if (key == 'selected' && !component && !const {'chip', 'checkbox', 'switch'}.contains(type) && !spec.props.any((p) => p.key == 'selected')) {
          final e = raw.startsWith('=') ? raw.substring(1).trim() : raw;
          // A quoted string is the binding as a string reads (design 22, 4.8):
          // `selected="${props.selected}"`, `selected="{on}"`.
          final quoted = e.startsWith('"') && _literal(e).$2 is String ? _interpolate(_literal(e).$2! as String) : null;
          bind['selected'] = quoted ?? _formula(e.startsWith('{') && e.endsWith('}') ? e.substring(1, e.length - 1) : e);
          selectedState = true;
          continue;
        }
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
          // `decoration={done ? 'lineThrough' : 'none'}`: the line follows the
          // data (it was kept as the text "=done ? …", which draws no line).
          if (raw.startsWith('=')) {
            props['style'] ??= switch (options.textStyles['body']) {
              final Map m => _copy(m.cast<String, Object?>()),
              final String name => <String, Object?>{'from': name},
              _ => <String, Object?>{},
            };
            bind['props.style.decoration'] = _read(raw.substring(1));
            continue;
          }
          textLine = _literal(raw).$2?.toString() ?? raw;
          continue;
        }
        // `strike=true`, `strike={done}` (16 lines in the corpora): the flag,
        // or a line through the text while the condition holds.
        if (type == 'text' && (key == 'strike' || key == 'strikethrough' || key == 'underline')) {
          final on = key == 'underline' ? 'underline' : 'lineThrough';
          if (raw.startsWith('=')) {
            props['style'] ??= switch (options.textStyles['body']) {
              final Map m => _copy(m.cast<String, Object?>()),
              final String name => <String, Object?>{'from': name},
              _ => <String, Object?>{},
            };
            final cond = raw.substring(1);
            bind['props.style.decoration'] = _formula('($cond) ? "$on" : "none"');
          } else if (_literal(raw).$2 == true) {
            textLine = on;
          }
          continue;
        }
        // An icon button's icon takes a color and a size through its style.
        if ((key == 'color' || key == 'size') && type == 'iconButton') {
          if (raw.startsWith('=')) {
            bind['props.style.${key == 'color' ? 'iconColor' : 'iconSize'}'] = key == 'color' ? _namedIn(_read(raw.substring(1)), 'text') : _read(raw.substring(1));
            (buttonLook ??= <String, Object?>{});
          } else {
            // size=small | medium | large: the icon's size by name.
            if (key == 'size') {
              final named = switch (_literal(raw).$2?.toString() ?? raw) { 'xs' => 14, 'small' || 'sm' => 16, 'medium' || 'md' => 20, 'large' || 'lg' => 28, _ => null };
              if (named != null) {
                (buttonLook ??= <String, Object?>{})['iconSize'] = named;
                continue;
              }
            }
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
          // A line under an `if` binds visible, and a binding shows over
          // a patched value: where the size hides the node, the binding is
          // dropped, so the condition holds only where the node shows.
          if (rule != null && !_mediaLine) mediaWords.add((condition: {...rule, 'patch': {'visible': false, 'bind': {'visible': null}}}, word: null, column: col));
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
        if (key == 'initials' && ours && written == 'Avatar') {
          avatarInitials = _interpolate(raw.startsWith('=') ? '{${raw.substring(1)}}' : _unquoted(raw));
          continue;
        }
        // A slider's step is how many equal steps its range has.
        if (key == 'step' && type == 'slider' && num.tryParse(raw) != null) {
          sliderStep = num.parse(raw);
          continue;
        }
        if (key == 'drag') {
          // `drag=part("battery")`, `drag=meal({"rid":r.id})`: the value is
          // a string or a record, read to its closing parenthesis.
          if (RegExp(r'^[A-Za-z_][A-Za-z0-9_]*\(').hasMatch(raw) && _opened(raw) > 0) {
            var depth = _opened(raw), quoted = false;
            final start = t.at;
            while (!t.done && depth > 0) {
              final c = t.s[t.at];
              if (c == '"' && t.s[t.at - 1] != r'\') quoted = !quoted;
              if (!quoted && '([{'.contains(c)) depth++;
              if (!quoted && ')]}'.contains(c)) depth--;
              t.at++;
            }
            raw += t.s.substring(start, t.at);
          }
          // `drag="battery"`: the group alone, quoted.
          if (raw.isEmpty && t.peek == '"') raw = t.string();
          if (RegExp(r'^"[A-Za-z_][A-Za-z0-9_]*"$').hasMatch(raw)) raw = raw.substring(1, raw.length - 1);
          final m = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)(?:\((.+)\))?$').firstMatch(raw);
          if (m == null) {
            _issue(col, 'drag is written drag=group or drag=group(value): drag=todo(card.id).');
          } else {
            // `drag=booking({r.id})`: what it carries, braced as an expression
            // is elsewhere, is that expression (a record `{"rid":…}` is kept).
            var data = m[2]?.trim();
            if (data != null && data.startsWith('{') && !data.startsWith('{"') && data.endsWith('}') && _opened(data.substring(0, data.length - 1)) == 1) data = data.substring(1, data.length - 1).trim();
            // (Typed so a dotted key after it sets a field of it: `draggable.feedbackRotation=0`.)
            node['draggable'] = <String, Object?>{'group': m[1], if (data != null) 'data': _read(data)};
          }
          continue;
        }
        if (key == 'drop') {
          final groups = raw.split(',').map((g) => g.trim()).where((g) => g.isNotEmpty).toList();
          if (groups.isEmpty || groups.any((g) => !_identifier.hasMatch(g))) {
            _issue(col, 'drop is written drop=group or drop=a,b with the groups it takes: drop=todo,doing onDrop={done=append(done,result.data)}.');
          } else {
            node['dropTarget'] = <String, Object?>{'accepts': groups};
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
        // …one that follows data: border-bottom={active ? accent : transparent}.
        if (_borderSides[key] case final String side when raw.startsWith('=')) {
          decoration['strokes'] = [
            {'color': '#00000000'},
          ];
          decoration['strokeSides'] = side;
          bind['decoration.strokes[0].color'] = _namedIn(_read(raw.substring(1)), 'stroke');
          continue;
        }
        // A border's width and colour, together or apart: `border=2` (the
        // theme's line, 2 wide), `border="#FF2563EB 2"`, `border=2
        // borderColor=accent`, `border={on ? 2 : 0}`, and the names models
        // write for each (border-width, strokeWidth, border-color, stroke).
        final borderPart = key == 'border'
            ? 'border'
            : const {'borderWidth', 'border-width', 'strokeWidth', 'borderSize'}.contains(key)
                ? 'width'
                : const {'borderColor', 'border-color', 'strokeColor', 'stroke'}.contains(key)
                    ? 'color'
                    : null;
        if (borderPart != null && !spec.props.any((p) => p.key == key)) {
          if (raw.isEmpty && t.peek == '"') raw = '"${t.string()}"';
          List<Object?> strokes() => (decoration['strokes'] as List<Object?>?) ?? (decoration['strokes'] = [<String, Object?>{'color': options.line}]);
          void width(String w) {
            strokes();
            if (w.startsWith('=')) {
              bind['decoration.strokeWidth'] = _read(w.substring(1));
            } else if (num.tryParse(w) case final num n) {
              decoration['strokeWidth'] = n;
            }
          }

          void color(String c) {
            final had = decoration['strokes'] != null;
            final s = strokes();
            if (c.startsWith('=')) {
              bind['decoration.strokes[0].color'] = _namedIn(_read(c.substring(1)), 'stroke');
              if (!had) s[0] = {'color': '#00000000'};
            } else {
              s[0] = {'color': _named(_value(c), 'stroke')};
            }
          }

          if (borderPart == 'width') {
            width(raw);
          } else if (borderPart == 'color') {
            color(raw);
          } else if (num.tryParse(raw) != null) {
            width(raw);
          } else if (raw.startsWith('=') && RegExp(r'^=\s*(-?\d+(\.\d+)?|.*\?\s*-?\d+(\.\d+)?\s*:\s*-?\d+(\.\d+)?)\s*$').hasMatch(raw)) {
            // `border={selected ? 2 : 0}`: a width worked out.
            width(raw);
          } else if (!raw.startsWith('=') && RegExp(r'^"?\s*\S+\s+\S+\s*"?$').hasMatch(raw.trim()) && raw.trim().split(RegExp(r'\s+')).any((w) => num.tryParse(w.replaceAll('"', '')) != null)) {
            // `border="#FF2563EB 2"`, `border="2 accent"`.
            final words = raw.replaceAll('"', '').trim().split(RegExp(r'\s+'));
            final w = words.firstWhere((w) => num.tryParse(w) != null);
            color(words.firstWhere((x) => x != w));
            width(w);
          } else {
            color(raw);
          }
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
        // …and its label (`action={…}`: what it does).
        if (key == 'action' && slotted && !spec.props.any((p) => p.key == 'action')) {
          if (raw.startsWith('=')) {
            slotAction = (label: slotAction?.label, actions: raw.substring(1).trim());
          } else {
            slotAction = (label: _literal(raw).$2?.toString() ?? raw, actions: slotAction?.actions);
          }
          continue;
        }
        // `Button "Bold" shortcut="mod+b" onTap={…}`: the key does what a tap
        // does (read when the line ends). A Text's own shortcut= is its hint.
        if (key == 'shortcut' && !spec.props.any((p) => p.key == 'shortcut')) {
          final written = _literal(raw).$2?.toString() ?? raw;
          final combo = raw.startsWith('=') ? null : notationKeyName(written.replaceAll(' ', ''));
          if (combo == null) {
            _issue(col, _noKeyName(written));
          } else {
            lineShortcut = (combo: combo, column: col);
          }
          continue;
        }
        // `props=null`, `props={}`: the node has no props at all, or an empty
        // record of them, whatever the line's words gave (design 22, 4.8);
        // the same for `layout` and `decoration`.
        if (const {'props', 'layout', 'decoration'}.contains(key) && (raw == 'null' || raw == '{}' || raw == '=' || raw == '={}')) {
          (raw == 'null' ? noSections : emptySections).add(key);
          continue;
        }
        // `node.disabled={…}`: the node's disabled state as it is bound, and
        // nothing more (design 22, 4.8), where `enabled=` is the type's own
        // prop (an Input's `enabled`, a block's `disabled` options).
        if (key == 'node.disabled') {
          final e = raw.startsWith('=') ? raw.substring(1).trim() : raw;
          if (e.startsWith('"') && _literal(e).$2 is String) {
            bind['disabled'] = _interpolate(_literal(e).$2! as String);
          } else if (raw.startsWith('=')) {
            bind['disabled'] = _read(e);
          } else {
            _issue(col, 'node.disabled is a condition: node.disabled={busy}.');
          }
          continue;
        }
        // `ChoiceChips disabled={full}`: a block whose own disabled is a list
        // (the options that are off), given a condition, is off as a whole:
        // the node's disabled state, as enabled={!full} is on a control.
        if (key == 'disabled' && component && spec.props.any((p) => p.key == 'disabled' && p.type.kind == PropKind.list)) {
          final cond = raw.startsWith('=') ? raw.substring(1).trim() : raw;
          if (_readsAsCondition(cond, variables)) {
            bind['disabled'] = _formula(cond);
            disabledBy = cond;
            continue;
          }
        }
        // `Input "Note" multiline size={fontSize}`: a size worked out is the
        // size of the field's text.
        if (type == 'textField' && key == 'size' && raw.startsWith('=') && !spec.props.any((p) => p.key == 'size')) {
          bind['props.style.fontSize'] = _read(raw.substring(1).trim());
          continue;
        }
        // `Input "Code" font="JetBrains Mono" weight=600 fontSize=18`: the
        // field's typed text, over the field's own style.
        if (type == 'textField' && _fieldStyleKeys[key] != null && !spec.props.any((p) => p.key == key)) {
          if (raw.startsWith('=')) {
            bind['props.style.${_fieldStyleKeys[key]!}'] = _read(raw.substring(1));
            continue;
          }
          final own = options.fieldText;
          final style = switch (props['style']) {
            final Map m => m.cast<String, Object?>(),
            _ => own is Map ? _copy(own.cast<String, Object?>()) : own is String ? <String, Object?>{'from': own} : <String, Object?>{},
          };
          style[_fieldStyleKeys[key]!] = _value(raw);
          props['style'] = style;
          continue;
        }
        // The universal words (docs/design/21) where the type has no word of
        // that name, and an Input's own (section 7).
        // The step of a scale a size word names (xs, small, medium, large, xl).
        final sizeStep = key == 'size' ? const {'xs': 0, 'small': 1, 'sm': 1, 'medium': 2, 'md': 2, 'large': 3, 'lg': 3, 'xl': 4}[_literal(raw).$2?.toString() ?? raw] : null;
        // A size word where the type's own size is a number is still the
        // universal step (Icon "star" size=small).
        final ownNumber = sizeStep != null && spec.props.any((p) => p.key == 'size' && (p.type.kind == PropKind.number || p.type.kind == PropKind.integer));
        if (!component && (!spec.props.any((p) => p.key == key) || ownNumber)) {
          final bound = raw.startsWith('=') ? raw.substring(1).trim() : null;
          final named = _literal(raw).$2?.toString() ?? raw;
          final step = sizeStep;
          void colorAt(List<String> paths, String kind) {
            for (final p in paths) {
              if (bound != null) {
                bind[p] = _namedIn(_read(bound), kind);
              } else {
                put(p, _named(_value(raw), kind));
              }
            }
          }

          // Whether the word was read here, and whether as a universal word
          // (recorded) rather than an Input's own or the grammar's.
          var handled = true, used = true;
          if (key == 'color') wroteColor = true;
          switch (key) {
            case 'reorder' || 'sortable' || 'reorderable' || 'selectable' || 'removable' || 'readOnly' || 'required' || 'clearable' || 'autogrow' || 'caps' || 'fuzzy' when raw == 'true':
              if (universalFlag(key, col, value: raw, of: 'parameter')) continue;
              handled = false;
            case 'handle' when listLine:
              listWords['handle'] = (value: named, column: col);
              continue;
            case 'color' when boxLine:
              // A container's colour is the ink of what is written in it.
              _ink[id] = raw;
            case 'color' when type == 'switch':
              colorAt(['props.activeTrackColor'], 'fill');
            case 'color' when type == 'radio':
              colorAt(['props.activeColor'], 'fill');
            case 'color' when type == 'slider':
              colorAt(['props.activeTrackColor', 'props.thumbColor'], 'fill');
            case 'color' when type.endsWith('Chip') || type == 'chip':
              chipColor = raw;
            case 'color' when type == 'textField' || type == 'dropdown':
              fieldInk = raw;
            case 'color' when const {'filledButton', 'elevatedButton', 'outlinedButton', 'textButton'}.contains(type):
              // A filled button's colour is its fill, unless the line gives
              // it one: then, as on an outline or ghost button, its label's.
              final filled = (type == 'filledButton' || type == 'elevatedButton') && !RegExp(r'(^|\s)fill=').hasMatch(line);
              final at = filled ? 'backgroundColor' : 'foregroundColor';
              if (bound != null) {
                bind['props.style.$at'] = _namedIn(_read(bound), filled ? 'fill' : 'text');
                (buttonLook ??= <String, Object?>{});
              } else {
                (buttonLook ??= <String, Object?>{})[at] = _named(_value(raw), filled ? 'fill' : 'text');
              }
            case 'size' when step != null && type == 'text':
              // The theme's text sizes: caption, small, body, title, and half again.
              num? of(String name) => readMap(options.textStyles[name])?['fontSize'] as num? ?? readMap(defaultTextVariants[name])?['fontSize'] as num?;
              final title = of('title') ?? 20;
              final size = [of('caption') ?? 11, of('small') ?? 12, of('body') ?? 13, title, (title * 1.5).round()][step];
              final body = options.textStyles['body'];
              final style = switch (props['style']) {
                final Map m => m.cast<String, Object?>(),
                _ => body is Map ? _copy(body.cast<String, Object?>()) : body is String ? <String, Object?>{'from': body} : <String, Object?>{},
              };
              props['style'] = style..['fontSize'] = size;
            case 'size' when step != null && type == 'icon':
              props['size'] = const [14, 16, 20, 28, 36][step];
            case 'size' when ours && written == 'Ring' && (step != null || num.tryParse(raw) != null):
              final across = step == null ? num.parse(raw) : const [32, 48, 64, 96, 128][step];
              layout['width'] = across;
              layout['height'] = across;
            case 'size' when step != null && ours && written == 'Avatar':
              avatarSize = const [24, 32, 40, 56, 72][step];
            case 'size' when step != null && type == 'progressBar':
              layout['height'] = const [3, 4, 8, 12, 16][step];
            case 'size' when step != null && type == 'slider':
              props['trackHeight'] = const [2, 2, 4, 6, 8][step];
              props['thumbRadius'] = const [5, 6, 8, 10, 12][step];
            case 'size' when step != null && (type.endsWith('Chip') || type == 'chip'):
              layout['height'] = const [20, 24, 28, 32, 36][step];
            case 'size' when (type == 'textField' || type == 'dropdown') && (step != null || named == 'compact' || (type == 'textField' && num.tryParse(raw) != null)):
              // A field's height is a step of the control scale; a number is
              // the size of its text.
              fieldSize = named;
            case 'icon' when type.endsWith('Chip') || type == 'chip':
              // A chip's leading icon is its avatar.
              if (bound != null) {
                bind['props.avatar'] = _read(bound);
                props['avatar'] = 'circle';
              } else {
                props['avatar'] = named;
              }
            case 'icon' when type == 'listTile':
              listIcon = raw;
            case 'enabled' when !spec.props.any((p) => p.key == 'isEnabled'):
              // No enabled of its own: the node's disabled state (it takes no
              // input; a box is drawn at half strength, below).
              // (`!name` for a name or a path, as a document writes it.)
              String not(String e) => RegExp(r'^[A-Za-z_][A-Za-z0-9_.]*$').hasMatch(e) && !const {'true', 'false', 'null'}.contains(e) ? '!$e' : '!($e)';
              final off = bound != null ? not(bound) : raw == 'false' ? 'true' : raw == 'true' ? null : not(raw);
              if (off != null) {
                bind['disabled'] = _formula(off);
                disabledBy = off;
              }
            case 'tooltip' when bound != null || (raw.startsWith('"') && raw.contains('{')):
              // A tooltip that reads data is the node's own, as written.
              node['tooltip'] = bound == null
                  ? _interpolate(_literal(raw).$2?.toString() ?? raw)
                  : bound.startsWith('"') && _literal(bound).$2 is String
                      ? _interpolate(_literal(bound).$2! as String)
                      : _read(bound);
              used = false;
            case 'value' when type == 'textField':
              inputValue = raw;
              used = false;
            case 'prefix' || 'suffix' when type == 'textField':
              final field = (props['decoration'] as Json?) ?? (props['decoration'] = <String, Object?>{});
              if (bound != null) {
                bind['props.decoration.${key}Text'] = _read(bound);
              } else {
                field['${key}Text'] = named;
              }
              field['affixesAlwaysVisible'] = true;
              used = false;
            case 'caps' when type == 'textField':
              final cap = switch (named) { 'words' => 'words', 'sentences' => 'sentences', 'none' || 'false' => 'none', _ => 'characters' };
              props['textCapitalization'] = cap;
              used = false;
            default:
              // Not universal on this line: read as before, below.
              handled = false;
          }
          if (handled) {
            if (used) universal.add((word: key, column: col, of: 'parameter'));
            continue;
          }
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
          // A named style written first (style=title, from=title) is the
          // style the key changes: `style=title size=13` is the title at 13.
          final named = props['style'] is String || key == 'from';
          final style = switch (props['style']) {
            final Map m => m.cast<String, Object?>(),
            final String name => <String, Object?>{'from': name},
            _ when key == 'from' => <String, Object?>{},
            _ => body is Map ? _copy(body.cast<String, Object?>()) : body is String ? <String, Object?>{'from': body} : <String, Object?>{},
          };
          if (props['style'] is! Map && !named && body is Map) seededStyle = {for (final k in body.keys) '$k'};
          final v = key == 'color' ? _named(_value(raw), 'text') : _value(raw);
          final field = _textStyleKeys[key]!;
          wroteStyle.add(field);
          // `size=34 from=title`: the body's look the size started from gives way to the title's.
          if (key == 'from') {
            style.removeWhere((k, _) => seededStyle.contains(k) && !wroteStyle.contains(k));
            seededStyle = const {};
          }
          style[field] = key == 'bold' ? 700 : v;
          props['style'] = style;
          if (v == null && key != 'bold') nulled.add('props.style.${_textStyleKeys[key]!}');
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
        // `Badge "Pass" variant={ok ? "success" : "error"}` (or `Badge.{…}`):
        // the tone worked out from the state; its fill, hairline and ink
        // follow it.
        if (key == 'variant' && written == 'Badge' && !component && raw.startsWith('=') && !spec.props.any((p) => p.key == 'variant')) {
          final e = raw.substring(1).trim();
          String tone(String Function((String, String, String) t) part) {
            var f = '"${part(options.badges['neutral'] ?? badgeVariants['neutral']!)}"';
            for (final v in options.badges.entries.toList().reversed) {
              f = '($e) == "${v.key}" ? "${part(v.value)}" : ($f)';
            }
            return _formula(f);
          }

          bind['decoration.fills[0].color'] = tone((t) => t.$1);
          bind['decoration.strokes[0].color'] = tone((t) => t.$2);
          _textColor = tone((t) => t.$3);
          continue;
        }
        if (key == 'hidden' && raw.startsWith('=')) {
          bind['visible'] = _formula('!(${raw.substring(1)})');
          continue;
        }
        // `hidden=true` is the bare `hidden` (and `tablet.hidden=true` its
        // rule at a width); `hidden=false` is shown.
        if (key == 'hidden' && (raw == 'true' || raw == 'false')) {
          node['visible'] = raw == 'false';
          continue;
        }
        // `label="Email"`: the field's label, kept above it beside buttons too.
        if (key == 'label' && type == 'textField') _labelByName.add(id);
        // Input "Search" icon="search": the icon inside the field, before
        // the text (its decoration's prefixIcon).
        // `prefixIcon="search"` (Flutter's name, test 10) is the same.
        if (key == 'prefixIcon' && type == 'textField' && !raw.startsWith('{')) {
          _use('alias', key, col, of: 'parameter', to: 'icon', on: written);
          key = 'icon';
        }
        if (key == 'icon' && type == 'textField') {
          final field = (props['decoration'] as Json?) ?? (props['decoration'] = <String, Object?>{});
          field['prefixIcon'] = {'icon': raw.startsWith('=') ? 'search' : _value(raw), 'size': 18};
          if (raw.startsWith('=')) bind['props.decoration.prefixIcon.icon'] = _read(raw.substring(1));
          continue;
        }
        if (_typeKeys[type]?[key] case final List<String> paths) {
          for (final path in paths) {
            final v = raw.startsWith('=') ? null : _value(raw);
            if (raw.startsWith('=')) {
              bind[path] = _read(raw.substring(1));
            } else if (v is String && v.contains(r'${') && !_holdsExpression(type, path)) {
              // A string that reads data is bound (`color="${= theme.colors.ink}"`).
              bind[path] = v;
            } else {
              put(path, v);
            }
          }
          continue;
        }
        if (key == 'color' && type == 'icon' && !raw.startsWith('=')) {
          props['color'] = _named(_value(raw), 'text');
          continue;
        }
        // `data={…}`: what a list shows, bound by the binding's own path
        // (design 22, 4.2) where the type has no prop of that name.
        if (key == 'data' && raw.startsWith('=') && spec.prop(key) == null) {
          bind[key] = _read(raw.substring(1).trim());
          continue;
        }
        final path = pathOf(key);
        if (unknownKey && !_identifier.hasMatch(key) || unknownKey && key.contains('.')) {
          // A path that is none of the type's (`pan.axs`, `props.colour`):
          // said, with the nearest, or recorded.
          if (open) {
            if (!standIn) _use('parameter', key, col, on: _srcWord ?? written, value: _written(word, eq, raw));
            if (standIn) dropped.add(key);
          } else {
            _issue(col, _noKey(written, key, type));
          }
          continue;
        }
        if (unknownKey) {
          unknownKeys.add((key: key, value: _written(word, eq, raw), column: col));
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
        } else if (bound != null && path == 'tooltip') {
          // A tooltip reads its data itself: one worked out is its own, as
          // `tooltip={…}` is (docs/design/21).
          node['tooltip'] = _read(bound);
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
          final declared = unknownKey ? null : keyType;
          if (open && declared != null && !(v is String && v.contains(r'${'))) {
            final wrong = !declared.isVariable &&
                switch (declared.kind) {
                  PropKind.boolean => v is! bool,
                  PropKind.number || PropKind.integer => v is! num,
                  PropKind.enumeration => v is String && !declared.values.contains(v),
                  PropKind.list => v is! List,
                  _ => false,
                };
            if (wrong) {
              if (!standIn) _use('parameter', key, col, on: _srcWord ?? written, value: _written(word, eq, raw));
              continue;
            }
          }
          // A word that is none of its enum's values: said, with the nearest
          // (docs/design/22 section 2.1).
          if (!open && declared != null && declared.kind == PropKind.enumeration && v is String && !v.contains(r'${') && !declared.values.contains(v)) {
            final near = didYouMean(v, declared.values);
            _issue(col, 'A $written\'s $key is one of ${declared.values.join(', ')}: not "$v"${near == null ? '' : ' (did you mean $key=$near?)'}.');
            continue;
          }
          // A record (a behavior, a style) given a word it cannot read as one
          // (`pan=horizontal`): said, with its fields.
          if (declared != null && declared.kind == PropKind.object && declared.fields.isNotEmpty && v is! Map && !(v is String && v.contains(r'${')) && keyDef?.decode(v) == null) {
            if (open) {
              if (!standIn) _use('parameter', key, col, on: _srcWord ?? written, value: _written(word, eq, raw));
            } else {
              final fields = declared.fields.map((f) => f.key);
              _issue(col, 'A $written\'s $key is a ${declared.name}: write its fields, $key.${fields.first}=… (${fields.join(', ')}), or $key={"${fields.first}": …}.');
            }
            continue;
          }
          // A field of the style of the text it shows starts from the style
          // its words start from (the body's, an Input's own).
          // `from=title` on a Text: the title's style, with only what the line
          // writes over it (not the body's look a size started from).
          if (type == 'text' && path == 'props.style.from') {
            if (props['style'] case final Map m) {
              props['style'] = {...m.cast<String, Object?>()}..removeWhere((k, _) => seededStyle.contains(k) && !wroteStyle.contains(k));
            } else {
              props['style'] = <String, Object?>{};
            }
            seededStyle = const {};
          }
          if (notationTextStyleProp(spec) case final style? when path.startsWith('props.${style.key}.') && props[style.key] is! Map) {
            final base = style.key != 'style'
                ? null
                : type == 'text'
                    ? options.textStyles['body']
                    : type == 'textField'
                        ? options.fieldText
                        : null;
            props[style.key] = switch (props[style.key]) {
              final String name => <String, Object?>{'from': name},
              _ => base is Map ? _copy(base.cast<String, Object?>()) : base is String ? <String, Object?>{'from': base} : <String, Object?>{},
            };
          }
          if (v is String && v.contains(r'${') && !_holdsExpression(type, path)) {
            // A string that reads data (value="{streak} days") is bound:
            // only a text node reads an expression as written.
            bind[path] = v;
          } else if (type == 'text' && path == 'props.style' && v is String && props['style'] is Map && options.themeTextStyles[v] != null) {
            // `Text.heading2 "…" style=serif`: the theme's style over the
            // variant, changing only the keys it sets (it replaced the
            // variant: a heading lost its size and its ink, round 11).
            final sets = options.themeTextStyles[v]!;
            final under = (props['style'] as Map).cast<String, Object?>();
            final from = under['from'];
            // What the variant draws: its theme style's keys, under its own.
            final base = {...?(from is String ? options.themeTextStyles[from] : null), ...under}..remove('from');
            final own = options.textStyles[v];
            props['style'] = {
              for (final e in base.entries)
                if (!sets.containsKey(e.key)) e.key: e.value,
              if (own is Map && own['from'] == v)
                'from': v
              else
                for (final k in sets.keys)
                  if ((own is Map ? own[k] : null) ?? sets[k] case final Object x) k: x,
            };
          } else {
            put(path, v);
          }
        }
      }
    }

    // A Handle is a grip, named for a screen reader, that its list is
    // reordered by: as big as the line says, else a 44 px target on a phone
    // and a 24 px grip on a desktop (a touch still lands on it in 44 × 44).
    if (ours && written == 'Handle') {
      props['icon'] = 'drag_indicator';
      final grip = options.width >= 700 ? 24 : 44;
      if (!layout.containsKey('flex')) layout.putIfAbsent('width', () => grip);
      layout.putIfAbsent('height', () => grip);
      // A small grip keeps a glyph that reads (the scale's would be 12).
      final h = layout['height'];
      if (h is num && h < 32) {
        final style = props['style'] is Map ? (props['style'] as Map).cast<String, Object?>() : <String, Object?>{};
        style.putIfAbsent('iconSize', () => 16);
        props['style'] = style;
      }
      node['tooltip'] = 'Reorder';
      node['reorderHandle'] = true;
    }
    // A NumberInput is a number field with its minus and plus buttons inside its
    // border: the number in the middle, as wide as three buttons.
    if (ours && written == 'NumberInput') {
      props['keyboardType'] = 'number';
      props['steppers'] = true;
      props.putIfAbsent('textAlign', () => 'center');
      if (!layout.containsKey('flex')) layout.putIfAbsent('width', () => 112);
    }
    // Sizes not written: in a column a child fills the width and hugs its
    // height; in a row it hugs both; a control hugs.
    final control = _valueProps.containsKey(type) || type.endsWith('Button') || type.endsWith('Chip');
    if (component) {
      // A parameter the line's `{…}` tail gives (a value, a binding, or none)
      // is given too.
      bool has(String k) =>
          props.containsKey(k) ||
          bind.containsKey('props.$k') ||
          readMap(node['props'])?.containsKey(k) == true ||
          readMap(node['bind'])?.containsKey('props.$k') == true;
      // A block with an optional boolean state should still toggle when its
      // author binds no variable to it. Give each call its own page variable.
      for (final p in spec.props) {
        if (p.required || has(p.key) || !p.type.isVariable || p.type.variableOf?.kind != PropKind.boolean) continue;
        final local = '${notationIdWord(id)}_${p.key}';
        props[p.key] = local;
        _top._internal.add(local);
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
            final local = '${notationIdWord(id)}_${p.key}';
            props[p.key] = local;
            _top._internal.add(local);
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
        _issue(column, 'A $written needs ${p.key}: write ${p.type.isVariable ? '${identical(p, mainParam) ? '@name, or ' : ''}${p.key}=@name (a variable, declared with state)' : '${p.key}=${p.type.kind == PropKind.list ? '["a","b"]' : p.type.kind == PropKind.string ? '"…"' : 'value'}'}.');
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
        // (A row of a width of its own, a table's cell of `w:87`, has that
        // width to share: round 11b, support-desk's StatusMark was 240 wide
        // in an 87 column, 49 overflow errors.)
        if (rowWidth is Map && rowWidth.containsKey('fill') || rowWidth is num || (row?['layout'] as Map?)?.containsKey('flex') == true) {
          layout['flex'] = 1;
        } else {
          layout['width'] = 240;
        }
      }
      // A call has no look of its own (its definition has): a radius, a
      // fill or a border written on it is left out, and said (round 10,
      // R31: it was left out with no word).
      // (A radius or a shadow is said as a key the call does not have.)
      const looks = {'fill', 'fills', 'border', 'border-top', 'border-bottom', 'border-left', 'border-right', 'strokes', 'strokeWidth', 'gradient'};
      final look = namedOnLine.where((k) => looks.contains(k) && spec.prop(k) == null).toList();
      if (look.isNotEmpty && !_quiet && !_mediaLine) _issue(column, _callLook(written, look));
      decoration.clear();
      bind.removeWhere((k, _) => k.startsWith('decoration.'));
      callSizes = {
        if (layout.containsKey('width') || layout.containsKey('flex')) 'width',
        if (layout.containsKey('height')) 'height',
      };
      layout.putIfAbsent('width', () => own?.width ?? {'hug': 0});
      layout.putIfAbsent('height', () => own?.height ?? {'hug': 0});
    }
    // The parts of a text that match a search are drawn marked: runs over
    // the text, which itself stays whole (and is read whole).
    if (markQuery != null && markText != null) {
      bind['props.runs'] = _formula('matchRuns(${_formulaSource(markText)}, $markQuery${_markTolerance(markQuery)})');
    }
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
      final palette = notationChartShades(_accentValue);
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
        final palette = notationChartShades(_accentValue);
        final rows = all.map((s) => s.values.length).reduce((a, b) => a > b ? a : b);
        // Its axis fitted to the data (from 0, a line of 812 to 851 was flat).
        props.putIfAbsent('fitMinY', () => true);
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
    // The type as the catalog spells it (`barChart`, `lineChart`, the
    // printer's word for a document's chart) is the node as written: only
    // the notation's words (BarChart, LineChart) add a height and colors.
    final asWritten = written == type;
    if (type == 'barChart' || type == 'lineChart') {
      if (!asWritten) layout.putIfAbsent('height', () => 140);
      // The design system's primary, unless a color is written.
      if (!asWritten) props.putIfAbsent(type == 'barChart' ? 'color' : 'lineColor', () => options.accent);
      if (type == 'barChart' && !asWritten) {
        for (final e in options.barChart.entries) {
          props.putIfAbsent(e.key, () => e.value);
        }
        // With no look of the theme's: bars apart, rounded, over a light
        // axis with its figures (round 11: bars touched, with no axis).
        if (options.barChart.isEmpty) {
          props
            ..putIfAbsent('barRadius', () => 4)
            ..putIfAbsent('maxBarWidth', () => 40)
            ..putIfAbsent('barGap', () => 8)
            ..putIfAbsent('gridColor', () => options.line)
            ..putIfAbsent('baselineColor', () => options.line);
          if (props['values'] case final List values when values.isNotEmpty && values.every((v) => v is num) && !props.containsKey('max') && !props.containsKey('gridLabels')) {
            final top = values.cast<num>().reduce((a, b) => a > b ? a : b);
            final lines = props['gridLines'] is int ? props['gridLines'] as int : 3;
            if (top > 0 && lines > 0) {
              final step = _axisStep(top, lines);
              props
                ..['max'] = step * lines
                ..['gridLabels'] = [for (var i = 0; i <= lines; i++) i == lines ? '' : _axisLabel(step * i)]
                ..putIfAbsent('gridLabelsLeft', () => true);
            }
          }
        }
      }
      if (type == 'lineChart' && props['values'] is List) {
        final values = props.remove('values')! as List;
        // Its axis fitted to the data, not from 0.
        if (values.isNotEmpty && values.every((v) => v is num) && !props.containsKey('yMin')) {
          final nums = values.cast<num>();
          final lo = nums.reduce((a, b) => a < b ? a : b), hi = nums.reduce((a, b) => a > b ? a : b);
          if (lo > 0 && hi > lo) {
            final step = _axisStep(hi - lo, 4);
            props['yMin'] = ((lo - (hi - lo) * 0.1) / step).floor() * step;
          }
        }
        props.remove('labels');
        props['data'] = [for (var i = 0; i < values.length; i++) {'x': i, 'y': values[i]}];
        props['xField'] = 'x';
        props['yField'] = 'y';
      }
    }
    // Universal words read once the line is (docs/design/21): a chip's
    // colour (a choice's selected tint, else its label's and icon's ink), a
    // removable chip (an input chip, its x the event), an icon's ink from
    // the container it is in.
    // A Barcode is the bars (a QR code is QRCode, or symbology=qrCode).
    if (type == 'barcode' && written == 'Barcode') props.putIfAbsent('symbology', () => 'code128');
    // It fills its box, so a box with no height of its own is given one: 80
    // for the bars, 160 square for a two-dimensional code.
    if (type == 'barcode' && !asWritten && (layout['height'] == null || layout['height'] is Map)) {
      final square = const {'qrCode', 'aztec', 'dataMatrix'}.contains(props['symbology'] ?? 'qrCode');
      layout['height'] = square ? 160 : 80;
      if (square && (layout['width'] == null || (layout['width'] is Map && (layout['width'] as Map).containsKey('fill')))) layout['width'] = 160;
    }
    final chip = type.endsWith('Chip') || type == 'chip';
    if (chip && chipColor != null) {
      final c = chipColor;
      final bound = c.startsWith('=') ? c.substring(1).trim() : null;
      final paths = type == 'choiceChip' || type == 'filterChip' ? const ['props.selectedColor'] : const ['props.labelStyle.color', 'props.avatarColor'];
      for (final p in paths) {
        if (bound != null) {
          bind[p] = _namedIn(_read(bound), 'text');
        } else {
          put(p, _named(_value(c), 'text'));
        }
      }
    }
    if (chip && removeActions != null) {
      type = 'inputChip';
      reactions.add({'trigger': {'type': 'deleted'}, 'actions': _actions(removeActions!, column)});
      removeActions = null;
    }
    if (!wroteColor && (type == 'icon' || type == 'iconButton')) {
      if (_inkAbove(parent?.id) case final String ink) {
        final path = type == 'icon' ? 'props.color' : 'props.style.iconColor';
        if (ink.startsWith('=')) {
          bind[path] = _namedIn(_read(ink.substring(1).trim()), 'text');
        } else if (type == 'icon') {
          props['color'] = _named(_value(ink), 'text');
        } else {
          (buttonLook ??= <String, Object?>{})['iconColor'] = _named(_value(ink), 'text');
        }
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
              {'color': options.roles ? 'subtleFill' : _named('#FFE5E7EB', 'fill')},
            ]);
        avatarName = shown is String ? shown : '';
        props.addAll({'mainAxisAlignment': 'center', 'crossAxisAlignment': 'center'});
      }
    }
    // A gauge: its scale's labels follow its range, a target shows only when
    // one is written (`target:` or `limit:`), and it has a size of its own.
    // The document's own radialGauge (the printer's word for one) is the
    // node as written (design 22, 4.6).
    if (type == 'radialGauge' && ours) {
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
    // A Calendar's range: its first @ is its first day, the second its
    // last, and one change gives both (result.start, result.end), as
    // yyyy-MM-dd. With one it picks one day, and its change gives that day.
    if (sliderEnd == null && type == 'calendar') props.putIfAbsent('range', () => false);
    if (sliderEnd != null && type == 'calendar') {
      final start = RegExp(r'^\$\{([A-Za-z_][A-Za-z0-9_]*)\}$').firstMatch('${bind['props.start']}')?.group(1);
      final end = sliderEnd!;
      if (start == null || !_identifier.hasMatch(end) || end.contains('.')) {
        _issue(sliderEndColumn, 'A range of days is a Calendar with a variable for each end: Calendar @arrival @departure.');
      } else {
        bind['props.end'] = _read(end);
        _bindsVariable(end, sliderEndColumn, () => '');
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
      final high = sliderEnd!;
      if (low == null || !_identifier.hasMatch(high) || high.contains('.')) {
        _issue(sliderEndColumn, 'A range is a slider with a variable for each end: Slider @low @high min=0 max=100.');
      } else {
        bind['props.rangeEnd'] = _read(high);
        _bindsVariable(high, sliderEndColumn, () => props['max'] is num ? props['max'] : 1);
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
    // A bare Spacer pushes what follows it to the end, as Flutter's does
    // (an Expanded): it takes the room left in its row or column.
    if (type == 'spacer' && !layout.containsKey('flex') && !layout.containsKey('width') && !layout.containsKey('height') && !bind.containsKey('layout.width') && !bind.containsKey('layout.height')) {
      layout['flex'] = 1;
    }
    // A Flex that scrolls scrolls along its direction (at every width: a rule
    // that turns it changes where it scrolls too).
    if (flexScroll && props['scrollable'] == true) props['scrollDirection'] = props['direction'] == 'vertical' ? 'vertical' : 'horizontal';
    if (type == 'progressBar' && options.progress['height'] != null) layout.putIfAbsent('height', () => options.progress['height']);
    // A card that writes no gap takes the theme's.
    if ((written == 'Card' && !component) && options.cardGap != null) props.putIfAbsent('spacing', () => options.cardGap);
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
    // A text that sets no colour takes the ink of the container it is in.
    if (type == 'text' && !wroteColor) {
      if (_inkAbove(parent?.id) case final String ink) {
        if (ink.startsWith('=')) {
          bind['props.style.color'] = _namedIn(_read(ink.substring(1).trim()), 'text');
        } else {
          final style = switch (props['style']) {
            final Map m => m.cast<String, Object?>(),
            final String name => <String, Object?>{'from': name},
            _ => <String, Object?>{},
          };
          props['style'] = style..['color'] = _named(_value(ink), 'text');
        }
      }
    }
    // In a grid a child is as wide as its cell and as tall as it says (its
    // row is as tall as its tallest child).
    if (parent?.type == 'gridView') {
      // (A fill with its design size, `w={"fill":140}`, is kept.)
      if (!(layout['width'] is Map && (layout['width'] as Map).containsKey('fill'))) layout['width'] = {'fill': 0};
      layout.putIfAbsent('height', () => {'hug': 0});
    }
    // A grid's rows are as tall as their content unless a height is given.
    // (A cell's shape or height written: its rows are that, not their content's;
    // round 11b, `Grid … childAspectRatio=1.36` drew its photos 0 to 20 high.)
    if (type == 'gridView' && !props.containsKey('mainAxisExtent') && !props.containsKey('childAspectRatio')) props.putIfAbsent('shrinkWrapRows', () => true);
    final cell = parent?.grid != null && !(grid != null && identical(parent!.grid, grid));
    if (cell) {
      layout['flex'] = 1;
      layout['width'] = {'fill': 0};
    }
    // A Flex laid out across (`direction=horizontal`) is a row: what is in
    // it is as wide as it is, and a Spacer or a `grow` takes the rest (each
    // took an equal share: a row of buttons half the bar, test 9 kanban).
    final acrossFlex = parent?.type == 'flex' && (nodes[parent!.id]?['props'] as Map?)?['direction'] == 'horizontal';
    final inRow = !cell && (parent?.type == 'row' || acrossFlex || options.rowFrames.contains(parent?.type));
    // A Splitter is as long as the panes it divides: as tall as its row (as
    // wide as its column when it divides one). It hugged, a 44 px stub at
    // the row's top beside the panes' own full-height borders (test 9, mail
    // and admin).
    if (type == 'splitter' && parent != null) {
      final vertical = props['orientation'] == 'vertical';
      final along = vertical ? 'width' : 'height';
      final across = (vertical && parent.type == 'column') || (!vertical && parent.type == 'row');
      if (across && (layout[along] == null || (layout[along] is Map && (layout[along] as Map).containsKey('hug')))) layout[along] = {'fill': 0};
    }
    // On a page, cards side by side are one row of panels: equally tall.
    if (inRow && (written == 'Card' && !component) && options.width >= 700) {
      final row = nodes[parent!.id];
      final cross = (row?['props'] as Map?)?['crossAxisAlignment'];
      // A row that says where its children sit (`top`) keeps it: the cards
      // stretched to the tallest beside them whatever the row said.
      if (row != null && !_crossWritten.contains(parent.id) && (cross == null || cross == 'center' || cross == 'start')) {
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
        _ => _controlHeight,
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
      // A field's universal words (docs/design/21): its ink and its size.
      Json style() => switch (props['style']) {
            final Map m => m.cast<String, Object?>(),
            final String name => <String, Object?>{'from': name},
            _ => <String, Object?>{},
          };
      if (fieldInk case final String ink) {
        if (ink.startsWith('=')) {
          bind['props.style.color'] = _namedIn(_read(ink.substring(1).trim()), 'text');
        } else {
          props['style'] = style()..['color'] = _named(_value(ink), 'text');
        }
      }
      if (fieldSize case final String size) {
        final n = num.tryParse(size);
        if (n != null) {
          props['style'] = style()..['fontSize'] = n;
        } else if (!layout.containsKey('height') && props['maxLines'] == null && props['minLines'] == null) {
          final h = const {'xs': 24, 'compact': 28, 'small': 32, 'sm': 32, 'medium': 36, 'md': 36, 'large': 44, 'lg': 44, 'xl': 52}[size]!;
          final label = type == 'textField' && switch ((props['decoration'] as Map?)?['labelText']) { final String l => l.isNotEmpty, _ => false };
          layout['height'] = h + (label ? (options.fieldLabel == null ? 20 : 23) : 0);
        }
      }
    }
    // An Input's own words (docs/design/21 section 7) and `required`.
    if (type == 'textField') {
      final d = (props['decoration'] as Json?) ?? <String, Object?>{};
      if (required) {
        // Its label is marked, and it checks it is not empty when the focus
        // leaves it (and with the rest of its form).
        if (d['labelText'] case final String l when l.isNotEmpty && !l.endsWith('*')) {
          d['labelText'] = '$l *';
        } else if (_labelBinds['props.decoration.labelText'] case final String l) {
          _labelBinds['props.decoration.labelText'] = '$l *';
        }
        props.putIfAbsent('validator', () => r'${= trim(value) == "" ? "Required" : ""}');
        props.putIfAbsent('autovalidateMode', () => 'onUnfocus');
      }
      if (clearable) {
        // A x after the text that clears it (its variable follows, as typing).
        d['suffixIcon'] = {
          'icon': 'close',
          'size': 16,
          'actions': [
            {
              'trigger': {'type': 'click'},
              'actions': [
                {'type': 'editText', 'node': id, 'operation': 'clear'},
              ],
            },
          ],
        };
      }
      if (d.isNotEmpty) props['decoration'] = d;
      // value="…" or value={…} beside @name: the text it starts with; the
      // variable it is bound to is still the one a change writes.
      if (inputValue case final String v) {
        if (v.startsWith('=') && !(v.substring(1).trim().startsWith('"') && _literal(v.substring(1).trim()).$2 is String)) {
          bind['props.initialValue'] = _read(v.substring(1).trim());
        } else {
          final written = v.startsWith('=') ? v.substring(1).trim() : v;
          final text = _literal(written).$2?.toString() ?? written;
          if (text.contains('{') && _interpolate(text).contains(r'${')) {
            bind['props.initialValue'] = _interpolate(text);
          } else {
            // A fixed text it starts with: shown over the variable's.
            bind.remove('props.initialValue');
            props['initialValue'] = text;
          }
        }
      }
    }
    // A required checkbox or toggle: its label is marked.
    if (required && (type == 'checkbox' || type == 'switch')) {
      if (props['label'] case final String l when l.isNotEmpty && !l.endsWith('*')) props['label'] = '$l *';
    }
    // A date or time field is a field: as tall as the text field and the select beside it.
    if (_controlHeight != null && const {'datePicker', 'timePicker', 'dateTimeInput'}.contains(type) && !layout.containsKey('height')) {
      layout['height'] = _controlHeight;
    }
    // A website's chip is a step under its controls (32): it was 24.
    if (_controlHeight != null && options.controlHeight == null && const {'chip', 'choiceChip', 'filterChip', 'actionChip', 'inputChip'}.contains(type) && !layout.containsKey('height')) {
      layout['height'] = 32;
    }
    if (_controlHeight != null && const {'textField', 'dropdown', 'segmentedButton'}.contains(type)) {
      // A field's label sits above its box, inside its height (11.5 px
      // text and 6 px under it).
      final label = type == 'textField' && switch ((props['decoration'] as Map?)?['labelText']) { final String l => l.isNotEmpty, _ => false };
      if (!layout.containsKey('height') && props['maxLines'] == null && props['minLines'] == null) {
        // A field that counts its characters (maxLength) has its counter under it.
        layout['height'] = _controlHeight! + (label ? (options.fieldLabel == null ? 20 : 23) : 0) + (type == 'textField' && props['maxLength'] is int ? 18 : 0);
      }
    }
    // (`squeezable=false` on the line keeps the text whole: it was set true
    // again here, so the word was dropped: test 9, kanban 3.)
    if (inRow && type == 'text' && !layout.containsKey('width') && !layout.containsKey('squeezable')) layout['squeezable'] = true;
    // On a page a column beside an icon or a picture gives way too (a name
    // and a note in a narrow tile), where it would push past the row's end.
    if (inRow && type == 'column' && !layout.containsKey('width') && !layout.containsKey('flex') && options.width >= 700 && written != 'Card') {
      layout['squeezable'] = true;
    }
    // A table's cell holds what is written for it inside the column's width:
    // a row of its own (a picture beside a name and an email) gives way too
    // (it ran past a narrow column: 202 wide, needing 206, an exception).
    if (inRow && type == 'row' && parent != null && _roles[parent.id] == 'cell' && !layout.containsKey('width') && !layout.containsKey('flex')) {
      layout['squeezable'] = true;
    }
    // A text in a box of a fixed height (an event's block, a tile): the
    // height is the least it is, and it grows when the text takes more lines.
    if (type == 'text' && parent != null && parent.type == 'column') {
      final box = nodes[parent.id];
      final h = (box?['layout'] as Map?)?['height'];
      if (box != null && h is num && h > 0 && (box['props'] as Map?)?['scrollable'] != true && !_exactHeights.contains(parent.id)) {
        // At least that high: a tinted block of a given height keeps it.
        final Json patch = {
          'layout': {
            'height': {'hug': h},
            'constraints': {'minHeight': h},
          },
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
      // A text or a row placed in a stack by its x or y (a label at a point,
      // a marker on a ruler) is as wide as its content, as a positioned box
      // is on the web: filling, it would run from its x across the stack (and
      // a text drew at 0,0 under the others).
      final placed = parent?.type == 'stack' &&
          const {'text', 'row', 'column'}.contains(type) &&
          (layout.containsKey('x') || layout.containsKey('y') || bind.containsKey('layout.x') || bind.containsKey('layout.y'));
      // A box with the widest it gets (`Column maxw=720` in a centered
      // column: a card of a page) is as wide as its place up to that, where
      // its parent centers it: it hugged its content (a 270 px flashcard in
      // a 1200 px pane, round 11).
      final capped = const {'column', 'row', 'stack'}.contains(type) &&
          readMap(layout['constraints'])?['maxWidth'] != null &&
          !inRow &&
          !(parentWidth is Map && parentWidth.containsKey('hug'));
      // An icon is as big as it is: it does not stretch across a column.
      final fills = !placed && layout.containsKey('flex') ||
          spread ||
          !placed && capped ||
          // Pages swiped across have no width of their own to hug: in a
          // centring column they were 0 wide and showed nothing (round 11b,
          // meal-planner's cooking steps).
          !placed && type == 'pageView' ||
          !placed && !inRow && !inTile && !inHug && type != 'icon' && (!control || type == 'textField' || type == 'slider' || type == 'dropdown' || type == 'pageView');
      layout['width'] = fills ? {'fill': 0} : {'hug': 0};
    } else {
      layout['width'] = _size(layout['width']);
    }
    // A box that grows in a column takes the height left there (Flutter's
    // Expanded): a list or a column that scrolls under a bar is bounded by
    // it, with no h=fill to add (`Column#body scroll grow`).
    final growsDown = !layout.containsKey('height') &&
        !bind.containsKey('layout.height') &&
        layout.containsKey('flex') &&
        parent?.type == 'column' &&
        !inRow &&
        // (A data table too: `TableView#sheetGrid grow` under a toolbar drew
        // 0 high, round 11b, spreadsheet.)
        const {'column', 'row', 'flex', 'stack', 'listView', 'gridView', 'tableView'}.contains(type);
    // An empty box that grows in a column is what pushes the lines after it
    // to the end (`box grow h=1` above a sidebar's foot, as `flex: 1` with a
    // height does on the web): it takes the room left, and never less than
    // the height written.
    final pushesDown = type == 'box' &&
        layout['height'] is num &&
        !bind.containsKey('layout.height') &&
        layout.containsKey('flex') &&
        parent?.type == 'column' &&
        !inRow;
    if (pushesDown) {
      layout['constraints'] = {...?readMap(layout['constraints']), 'minHeight': layout['height']};
      layout['height'] = {'fill': 0};
    }
    // A page is as tall as its page view.
    layout['height'] = growsDown
        ? {'fill': 0}
        : layout.containsKey('height') ? _size(layout['height']) : parent?.pages != null ? {'fill': 0} : {'hug': 0};
    // A height written by its full path (`layout.height=108`,
    // `layout.height=hug`) is that height exactly: no rule of the line or of
    // a line under it changes it (design 22, 4.8).
    final exactHeight = pre?.parts.any((p) => p.kind == 'pair' ? p.key == 'layout.height' : p.kind == 'word' && p.raw.startsWith('layout.height=')) ?? false;
    if (exactHeight) _exactHeights.add(id);
    bool exactly(String path) => pre?.parts.any((p) => p.kind == 'pair' ? p.key == path : p.kind == 'word' && p.raw.startsWith('$path=')) ?? false;
    if (exactly('layout.width')) _exactWidths.add(id);
    if (exactly('layout.flex')) _exactFlex.add(id);
    // A spacer that grows in a column takes the height left (what is under
    // it sits at the column's foot).
    if (type == 'spacer' && layout.containsKey('flex') && parent?.type == 'column' && !inRow && !exactHeight) layout['height'] = {'fill': 0};
    // A size that follows data (w={…}, h={…}) is a fixed one whose number the
    // binding gives: left to hug or fill, the number would change nothing
    // and an empty box would stay at no size.
    // A number written beside it is the size it starts at (`h=24 h={…}`).
    // (`layout.height=24`, a key with a dot, is a word of the line's parts.)
    bool fixed(Set<String> keys) =>
        pre?.parts.any((p) => switch (p.kind) {
              'pair' => keys.contains(p.key) && num.tryParse(p.value!) != null,
              'word' => keys.any((k) => p.raw.startsWith('$k=') && num.tryParse(p.raw.substring(k.length + 1)) != null),
              _ => false,
            }) ??
        false;
    // (A size written by its full path, `layout.width=fill`, is that size
    // under its binding too: design 22, 4.8.)
    bool exact(String k) => pre?.parts.any((p) => p.kind == 'word' && p.raw.startsWith('$k=')) ?? false;
    if (bind.containsKey('layout.width') && !fixed(const {'w', 'layout.width'}) && !exact('layout.width')) layout['width'] = 0;
    if (bind.containsKey('layout.height') && !fixed(const {'h', 'layout.height'}) && !exact('layout.height')) layout['height'] = 0;
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
        // The row's own rules at other widths: a row that is a column there
        // (`phone.direction=vertical`) has one copy a line there (it stayed
        // side by side: test 9, admin 11).
        final rowId = _parentOf[listId!];
        final rowMedia = rowId == null ? null : (nodes[rowId]?['media'] as List?);
        // A row of a height of its own (`Row h=102` over the days of a week):
        // its copies are as tall as it, at each width it gives a height
        // (the grid's rows hugged their cells, centred in the row).
        num? innerHeight(Object? layout) {
          final l = readMap(layout);
          final h = l?['height'];
          if (h is! num) return null;
          final pad = l?['padding'];
          final padV = pad is num ? 2 * pad : (pad is List && pad.length == 4 && pad[1] is num && pad[3] is num ? (pad[1] as num) + (pad[3] as num) : 0);
          return math.max<num>(0, h - padV);
        }

        final rowHeight = rowId == null ? null : innerHeight(nodes[rowId]?['layout']);
        final Json itemPatch = {
          'layout': {'width': {'hug': null, 'fill': 0}, 'height': rowHeight != null ? {'hug': null, 'fill': 0} : {'fill': null, 'hug': 0}},
          'props': {'mainAxisAlignment': null, 'crossAxisAlignment': 'stretch'},
        };
        if (rowHeight != null) {
          (listPatch['props']! as Json)
            ..['shrinkWrapRows'] = null
            ..['mainAxisExtent'] = rowHeight;
        }
        final gridMedia = <Json>[
          for (final rule in rowMedia ?? const [])
            if (rule is Map && (rule['patch'] as Map?)?['props'] is Map && ((rule['patch'] as Map)['props'] as Map)['direction'] == 'vertical')
              {
                for (final e in rule.entries)
                  if (e.key != 'patch') '${e.key}': e.value,
                'patch': {
                  'props': {'crossAxisCount': 1, 'mainAxisSpacing': (list['props'] as Map?)?['spacing'] ?? 0},
                  'bind': {'props.crossAxisCount': null},
                },
              },
          if (rowHeight != null)
            for (final rule in rowMedia ?? const [])
              if (rule is Map && readMap(readMap(rule['patch'])?['layout'])?['height'] is num)
                if (innerHeight({...?readMap(nodes[rowId]?['layout']), ...?readMap(readMap(rule['patch'])?['layout'])}) case final num h)
                {
                  for (final e in rule.entries)
                    if (e.key != 'patch') '${e.key}': e.value,
                  'patch': {
                    'props': {'mainAxisExtent': h},
                  },
                },
        ];
        if (gridMedia.isNotEmpty) listPatch['media'] = gridMedia;
        // A copy's own width or growth at another width (`tablet.w=272
        // tablet.grow=false`), or the row scrolling there, a grid's column
        // cannot follow: said, with what to write (it was dropped).
        // (Where the row turns down the page the grid has one column, each copy
        // its whole width: a copy's `phone.grow=0` or `phone.w=fill` there says
        // what it does, and is read; round 11b: restaurant, nonprofit.)
        bool saysOneColumn(LinePart p) {
          final word = p.kind == 'pair' ? '${p.key}=${p.value}' : p.raw;
          final m = mediaCondition(word.split('=').first);
          if (m == null || m.problem != null) return false;
          final rest = word.substring(m.length);
          if (!RegExp(r'^(grow=(0|false)|flex=0|w=fill|width=fill)$').hasMatch(rest)) return false;
          return gridMedia.any((g) => jsonEquality.equals({for (final e in g.entries) if (e.key != 'patch') e.key: e.value}, m.condition));
        }

        final ownMedia = pre?.parts.where((p) => RegExp(r'^[a-z]+\.(w|width|grow|flex)\b').hasMatch(p.kind == 'pair' ? p.key ?? '' : p.raw) && !saysOneColumn(p)).toList() ?? const [];
        final rowScrolls = (rowMedia ?? const []).any((r) => r is Map && ((r['patch'] as Map?)?['props'] as Map?)?['scrollable'] == true);
        if (ownMedia.isNotEmpty || rowScrolls) {
          _issue(column,
              'Copies that grow share their row as the columns of a grid, at every width: ${ownMedia.isNotEmpty ? 'a width of their own at another size (${ownMedia.map((p) => p.raw).join(' ')}) is not read' : 'the row does not scroll at another size'}. '
              'For lanes that are equal on a wide window and of their own width (scrolling sideways) on a narrow one, write the width without grow: '
              'Column w={max(272, (screen.width - 48) / length(list))} tablet.w=272 in a ListView scrollDirection=horizontal.');
        }
        nodes[listId] = mergePatch(list, listPatch);
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
    for (final path in nulled) {
      final dot = path.indexOf('.');
      final where = dot < 0 ? '' : path.substring(0, dot);
      final Json root = switch (where) { 'props' => props, 'layout' => layout, 'decoration' => decoration, _ => node };
      _removePath(root, root == node ? path : path.substring(dot + 1));
    }
    final emptied = nulled.any((p) => p.startsWith('layout.')) && layout.isEmpty;

    // `shortcut="mod+b"` on a line that is tapped: a key of the screen (as a
    // `key` line is) runs what its tap runs, and its tooltip names the key.
    // `state zoom=1` under `Slider @zoom min=0.5 max=3`, or under a Slider
    // with no ends of its own (0 to 1): the control writes fractions. One
    // between whole numbers in whole steps (`state volume=40`, `Slider
    // @volume min=0 max=100`) keeps the whole number its state began as, so
    // a text reading it shows 66.
    if (decimalBound case final String bound) {
      bool whole(Object? v) => v is num && v == v.roundToDouble();
      final lo = props['min'], hi = props['max'], step = props['step'], parts = props['divisions'];
      final wholeSteps = whole(lo) &&
          whole(hi) &&
          (step == null || whole(step)) &&
          (parts == null || (parts is num && parts > 0 && whole(((hi! as num) - (lo! as num)) / parts)));
      if (!wholeSteps) _widen(bound, null);
    }
    if (lineShortcut case (:final combo, :final column)) {
      final tap = component ? _handlerTrigger('onTap', type, spec, node) : const {'type': 'click'};
      final reaction = reactions.where((r) => jsonEncode(r['trigger']) == jsonEncode(tap)).firstOrNull;
      if (reaction == null || _stack.any((o) => o.each != null)) {
        _issue(column,
            'shortcut= presses a line that is tapped, once on the screen: give it onTap={…} (not under an each), or write the key as a line of its own: key $combo onPress={…}.');
      } else {
        _timers.add({
          'trigger': {'type': 'keyDown', 'key': combo},
          'actions': _copyValue(reaction['actions']),
        });
        if (_canvas) _patches.add({'op': 'patch', 'id': options.screen, 'patch': {'actions': [..._timers]}});
        node.putIfAbsent('tooltip', () => _keyHint(combo));
      }
    }

    // A string with `${…}` that the words put in a field reads data: the
    // field is bound to it, unless it works its expression out itself
    // (design 22, 4.8: `color="${= theme.colors.ink}"`).
    void bindReads(Object? m, String at) {
      if (m is Map) {
        for (final k in m.keys.toList()) {
          final v = m[k];
          if (v is String && v.contains(r'${') && !_holdsExpression(type, '$at.$k')) {
            bind.putIfAbsent('$at.$k', () => v);
            m.remove(k);
          } else {
            bindReads(v, '$at.$k');
          }
        }
      } else if (m is List) {
        for (var i = 0; i < m.length; i++) {
          bindReads(m[i], '$at[$i]');
        }
      }
    }

    if (options.iconStyle case final style?) _styleIcons(props, style);
    bindReads(props, 'props');
    bindReads(layout, 'layout');
    bindReads(decoration, 'decoration');
    for (final s in {...noSections, ...emptySections}) {
      (switch (s) { 'props' => props, 'layout' => layout, _ => decoration }).clear();
    }
    final out = <String, Object?>{
      'type': type,
      if (!emptied && !noSections.contains('layout')) 'layout': layout,
      if (props.isNotEmpty || emptySections.contains('props')) 'props': props,
      if (decoration.isNotEmpty || emptySections.contains('decoration')) 'decoration': decoration,
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
          } else if (v is String && v.contains(r'${') && !_holdsExpression(type, at)) {
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
    // With a closed one it is said, with the nearest name (docs/design/22
    // section 2.1): never a prop nothing reads.
    if (unknownKeys.isNotEmpty) {
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
        if (!open) {
          _issue(u.column, _noKey(written, u.key, '${out['type']}', component: component, takes: spec));
          continue;
        }
        if (!standIn) _use('parameter', u.key, u.column, on: _srcWord ?? written, value: u.value);
        if (standIn) dropped.add(u.key);
      }
    }
    // Selected (`Row … selected={…}`): a box is drawn in the theme's
    // selected fill while it holds, as a NavItem is, unless the line gives
    // its selected look itself (its tail, design 22 4.7).
    final givenStates = readMap(out['states']);
    if (selectedState && const {'row', 'column', 'stack'}.contains(type) && !(readMap(out['bind'])?.keys.any((k) => k.startsWith('decoration.fills')) ?? false) && givenStates?['selected'] == null) {
      out['states'] = <String, Object?>{
        ...?givenStates,
        'selected': <String, Object?>{
          id: <String, Object?>{
            'decoration': <String, Object?>{
              'fills': <Object?>[
                <String, Object?>{'color': options.selectedFill},
              ],
            },
          },
        },
      };
    }
    // Disabled where the type has no enabled of its own (docs/design/21): a
    // box, a text, an icon takes no pointer and no focus, and everything in
    // it with it, drawn at half strength while its disabled binding holds (a
    // control draws its own disabled look from the same binding), unless the
    // line gives its disabled look itself.
    if (disabledBy.isNotEmpty && !controlLine && givenStates?['disabled'] == null) {
      out['states'] = <String, Object?>{
        ...?readMap(out['states']),
        'disabled': <String, Object?>{
          id: <String, Object?>{'opacity': 0.5, 'ignorePointer': true},
        },
      };
    }
    _readStates(stateWords, t.s.substring(0, math.min(t.at, t.s.length)).trimRight(), id, parent?.id, parent?.type, type, out, node);
    // Its media rules, unless its {…} tail gave them (t.at: where the words end).
    if (mediaWords.isNotEmpty && !node.containsKey('media') && !t.rest.contains('"media"')) {
      final rules = _mediaRules(mediaWords, t.s.substring(0, math.min(t.at, t.s.length)).trimRight(), parent?.type, type, readMap(out['bind'])?.keys ?? const []);
      // `w=280 phone.grow`: where it grows its own length is the room it
      // takes there (it kept 280 and the row ran past a phone).
      final along = switch (parent?.type) { 'row' => 'width', 'column' => 'height', _ => null };
      if (along != null && readMap(out['layout'])?[along] is num) {
        for (final r in rules) {
          final l = readMap(readMap(r['patch'])?['layout']);
          if (l != null && l['flex'] is num && (l['flex'] as num) > 0 && !l.containsKey(along)) l[along] = {'fill': 0};
        }
      }
      if (rules.isNotEmpty) out['media'] = rules;
    }
    if (callSizes != null) _componentRules(type, callSizes, out);
    _componentScreen(type);
    nodes[id] = out;
    // A list tile's leading icon (icon= on a ListTile).
    if (listIcon case final String icon when type == 'listTile') {
      final slots = (out['slots'] as Json?) ?? (out['slots'] = <String, Object?>{});
      if (!slots.containsKey('leading')) {
        final iconId = _taken('${id}Icon') ? _id('icon') : '${id}Icon';
        nodes[iconId] = {
          'type': 'icon',
          'layout': {'width': {'hug': 0}, 'height': {'hug': 0}},
          'props': {'icon': icon.startsWith('=') ? 'circle' : _literal(icon).$2?.toString() ?? icon, 'size': 20},
          if (icon.startsWith('=')) 'bind': {'props.icon': _read(icon.substring(1).trim())},
        };
        slots['leading'] = iconId;
        _parentOf[iconId] = id;
        _slotOf[iconId] = 'leading';
      }
    }
    // A removable line that is not a chip: a small x at its end, added when
    // it closes.
    if (removeActions case final String actions) _removeAt[id] = actions.trim().isEmpty ? <Json>[] : _actions(actions, column);
    if (slotAction case (:final label, :final actions)) {
      _slotActions[id] = (label: label == null ? 'More' : _interpolate(label), actions: actions == null || actions.trim().isEmpty ? <Json>[] : _actions(actions, column));
    }
    // A list's universal words, read by the each under it.
    if (listWords.isNotEmpty) _listUniversal[id] = _ListWords(listWords, _line, _src, _srcWord ?? written, _srcPath, standIn: standIn);
    for (final u in universal) {
      _use('universal', u.word, u.column, on: _srcWord ?? written, of: u.of);
    }
    // A stand-in honours the words every line understands (docs/design/21
    // section 5): each it did not leave out is recorded as universal.
    if (standIn && open) {
      final parts = LineParts.of(_src.startsWith(written) ? _src : line);
      final at = {for (final i in issues) if (i.line == _line) i.column};
      for (final p in parts?.parts ?? const <LinePart>[]) {
        if (p.kind != 'pair' && p.kind != 'word') continue;
        final w = p.kind == 'pair' ? p.key! : p.raw;
        final c = column + (p.at < 0 ? 0 : p.at);
        if (dropped.contains(w) || at.contains(c) || num.tryParse(w) != null) continue;
        if (const {'duration', 'delay', 'stagger'}.contains(w) && animation == null) continue;
        if (listWords.containsKey(w)) continue;
        // Only a word every line understands, or one of the column it is.
        if (!isUniversal(w) && !spec.props.any((x) => x.key == w)) continue;
        _use('universal', w, c, on: written, of: p.kind == 'word' ? 'flag' : p.isEvent ? 'event' : 'parameter');
      }
    }
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
      // "Maya Reyes" is MR; a name read from state (`Avatar "{item.name}"`)
      // is its initials too, worked out as it shows (its first two words'
      // first letters); a text with more in it is shown as it is.
      final reads = avatarName.contains(r'${') || avatarName.contains('{');
      final words = avatarName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      final whole = RegExp(r'^\$?\{(?:=\s*)?([^{}]+)\}$').firstMatch(avatarName.trim());
      // One word read from the state ("MR", a name's initials worked out
      // before) keeps two letters, as a written one does.
      final initials = avatarInitials != null
          ? avatarInitials
          : whole != null
          ? _formula("upper(length(split(trim(text(${whole[1]!.trim()})), ' ')) == 1 ? left(trim(text(${whole[1]!.trim()})), 2) : join(map(take(split(trim(text(${whole[1]!.trim()})), ' '), 2), w => left(w, 1)), ''))")
          : reads || words.isEmpty
              ? avatarName
              : words.length == 1
                  ? words.first.substring(0, words.first.length.clamp(0, 2)).toUpperCase()
                  : '${words.first[0]}${words.last[0]}'.toUpperCase();
      final size = switch ((out['layout'] as Map)['width']) { final num w => w, _ => avatarSize ?? 40 };
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
    if (type == 'radialGauge' && ours) {
      // A gauge is its arc with the figure it shows inside: a stack under
      // the line's id, so the id still names the whole.
      final value = (out['props'] as Map?)?['value'], bound = (out['bind'] as Map?)?['props.value'];
      final body = options.textStyles['body'];
      Json figure(Object? base, Json over) => {...(base is Map ? _copy(base.cast<String, Object?>()) : const <String, Object?>{}), ...over};
      final arcLayout = (out['layout']! as Map).cast<String, Object?>();
      final gaugeSide = [
        for (final k in const ['width', 'height'])
          if (arcLayout[k] case final num v) v,
      ].fold<num?>(null, (a, b) => a == null || b < a ? b : a);
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
          // Its side is the shorter of its width and height: a wide gauge
          // 100 high drew a 44 px figure over its arc (round 11).
          'style': gaugeSide != null && gaugeSide < 200
              ? figure(body, {'fontSize': (gaugeSide / 6).clamp(18, 40).round(), 'fontWeight': 700})
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
    // A stand-in with nothing to draw at the top of a page beside its App or
    // Page (a key handler, a clock, a theme switch written before the frame):
    // not drawn, and the frame stays the page's root (it was a bar above the
    // app, and the app lost its window). Its use is recorded as before.
    final silentTop = parent == null && _silentTopLines.contains(_line) && (standIn || _silent.containsKey(id));
    if (silentTop) {
      final s = _silent[id]!;
      _silent[id] = (word: s.word, primitive: s.primitive, said: s.said, sized: s.sized, top: true);
      _skipEmit.add(id);
    } else if (parent == null) {
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
      if (parent.slot != null) {
        _intoSlot(parent, id, column);
      } else if (parent.type == 'listTile') {
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
    // `Pages`: a page view of one page, the lines under it. `PageView`
    // (`pageView`), the catalog's name, is the node as written (design 22,
    // 4.7): the lines under it are its children, as under any other line.
    if (type == 'pageView' && written == 'Pages') {
      // Its page: what the page view draws at each position.
      final pageId = '${id}Page';
      nodes[pageId] = {
        'type': 'column',
        'layout': {'width': {'fill': 0}, 'height': {'fill': 0}},
        'props': {'crossAxisAlignment': 'stretch'},
      };
      ((out['children'] as List<Object?>?) ?? (out['children'] = <Object?>[])).add(pageId);
      _parentOf[pageId] = id;
      // (`props=null`: none, design 22, 4.8.)
      if (!noSections.contains('props')) {
        props.putIfAbsent('scrollDirection', () => 'horizontal');
        // A line with no prop of its own has them now (what a {…} at its end
        // gave it are its props then).
        if (out['props'] case final Map<Object?, Object?> given) {
          given.putIfAbsent('scrollDirection', () => 'horizontal');
        } else {
          out['props'] = props;
        }
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
      if (type == 'listView' && !component) _listLines[id] = (line: _line, column: column);
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
      _textColor = null;
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

  /// A component's call takes the rules its definition's root has at other
  /// widths for what the call's box is (its width, its height, whether it
  /// shows: `Column#nav w=232 tablet.w=64 hide=phone` in AppNav), before the
  /// line's own rules; a size the call writes ([written]: `w=`, `grow`, `h=`)
  /// or a rule the line gives that key is the call's, and wins.
  /// The screen lines (key, every, on load) of the component [type], taken
  /// by this screen the first time it is called on it: a component's
  /// shortcuts were dropped with no word (test 9, admin 3: 42 lines of
  /// `key alt+N` repeated on every page). A reaction the screen writes
  /// itself for the same key is the screen's.
  void _componentScreen(String type) {
    final actions = options.componentScreenActions[type];
    final overlays = options.componentScreenOverlays[type];
    if ((actions == null && overlays == null) || !_top._screensOf.add(type)) return;
    final top = _top;
    for (final o in overlays ?? const <Json>[]) {
      _takeOverlay(top, o);
    }
    if (actions == null) return;
    for (final a in actions) {
      final trigger = readMap(a['trigger']);
      if (trigger?['type'] == 'keyDown' &&
          top._timers.any((t) => readMap(t['trigger'])?['type'] == 'keyDown' && readMap(t['trigger'])?['key'] == trigger?['key'] && readMap(t['trigger'])?['when'] == trigger?['when'])) {
        continue;
      }
      final copy = _copy(a);
      top._fromComponents.add(copy);
      top._timers.add(copy);
    }
    if (top._canvas) top._patches.add({'op': 'patch', 'id': top.options.screen, 'patch': {'actions': [...top._timers]}});
  }

  /// The components whose screen lines this screen has taken.
  final _screensOf = <String>{};

  /// The overlays this screen took from the components it calls, by id:
  /// each its canvas and its nodes ([_takeOverlay]).
  final _takenOverlays = <String, Json>{};

  /// Takes overlay [o] of a component this screen calls (its `{"id",
  /// "nodes"}`): its canvas a root of the screen's document, its nodes
  /// with ids of their own there (`basket-text1`: the component's ids are
  /// its document's), unless the screen has a node or an overlay of that id
  /// (the screen's own is the one shown).
  void _takeOverlay(_Parser top, Json o) {
    final id = o['id'];
    final nodes = readMap(o['nodes']);
    if (id is! String || nodes == null || nodes[id] == null || top._takenOverlays.containsKey(id) || top._taken(id) || top._overlayActions.containsKey(id)) return;
    final rename = <String, String>{
      for (final k in nodes.keys)
        if (k != id) k: top._taken('$id-$k') ? top._id('node') : '$id-$k',
    };
    Object? renamed(Object? v) => v is String ? (rename[v] ?? v) : v;
    final out = <String, Object?>{};
    for (final e in nodes.entries) {
      final n = _copy(readMap(e.value) ?? const {});
      if (n['children'] case final List kids) n['children'] = [for (final k in kids) renamed(k)];
      if (readMap(n['slots']) case final Json slots) n['slots'] = {for (final s in slots.entries) s.key: renamed(s.value)};
      out[rename[e.key] ?? e.key] = n;
    }
    top._takenOverlays[id] = out;
    if (!top._canvas) return;
    // As it would be sent: the roots, the canvas, then each node under its parent.
    top.ops
      ..add({'op': 'roots', 'roots': top._rootIds})
      ..add({'op': 'set', 'id': id, 'node': {...readMap(out[id])!}..remove('slots')..remove('children')});
    void send(String parent) {
      final p = readMap(out[parent])!;
      final slots = readMap(p['slots']) ?? const {};
      for (final s in slots.entries) {
        if (s.value case final String child when out[child] != null) {
          top.ops.add({'op': 'set', 'id': child, 'parent': parent, 'slot': s.key, 'node': {...readMap(out[child])!}..remove('slots')..remove('children')});
          send(child);
        }
      }
      for (final child in readStrings(p['children'])) {
        if (out[child] == null) continue;
        top.ops.add({'op': 'set', 'id': child, 'parent': parent, 'node': {...readMap(out[child])!}..remove('slots')..remove('children')});
        send(child);
      }
    }

    send(id);
  }

  /// What was said once (by its kind and line), where a line is read again
  /// as the lines a page word writes.
  final _said = <String>{};

  /// The reactions taken from components (a key the screen writes itself
  /// replaces the component's).
  final _fromComponents = <Json>[];

  void _componentRules(String type, Set<String> written, Json out) {
    final rules = options.componentRules[type];
    if (rules == null || rules.isEmpty) return;
    final own = [for (final r in (out['media'] as List? ?? const [])) ?readMap(r)];
    bool ownSays(bool Function(Json patch) says) => own.any((r) => says(readMap(r['patch']) ?? const {}));
    final boundVisible = readMap(out['bind'])?.containsKey('visible') ?? false;
    final taken = <Json>[];
    for (final r in rules) {
      final patch = readMap(r['patch']) ?? const {};
      final layout = readMap(patch['layout']) ?? const {};
      final keep = <String, Object?>{};
      final sizes = <String, Object?>{};
      for (final k in const ['width', 'height']) {
        if (!layout.containsKey(k) || written.contains(k)) continue;
        if (ownSays((p) => readMap(p['layout'])?.containsKey(k) ?? false)) continue;
        sizes[k] = _copyValue(layout[k]);
      }
      if (sizes.isNotEmpty) keep['layout'] = sizes;
      final rootBinds = readMap(patch['bind'])?.containsKey('visible') ?? false;
      if ((patch.containsKey('visible') || rootBinds) && !boundVisible && out['visible'] == null && !ownSays((p) => p.containsKey('visible'))) {
        if (patch.containsKey('visible')) keep['visible'] = patch['visible'];
        if (rootBinds) keep['bind'] = {'visible': readMap(patch['bind'])!['visible']};
      }
      if (keep.isEmpty) continue;
      taken.add({for (final e in r.entries) if (e.key != 'patch') e.key: e.value, 'patch': keep});
    }
    if (taken.isNotEmpty) out['media'] = [...taken, ...own];
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
    // `ExpansionTile "{entry.q}"`: its strings are its header's, the title
    // and subtitle of the list tile in its `tile` slot, as `ListTile "…"`
    // makes them; the lines under it are what it shows open. They were its
    // first children, and the header, drawn from the slot alone, was blank
    // (round 11b: conference's FAQ, docs-site's navigation groups).
    if (type == 'expansionTile' && texts.isNotEmpty && (out['slots'] as Map?)?['tile'] == null) {
      final tile = '${id}Tile';
      nodes[tile] = <String, Object?>{
        'type': 'listTile',
        'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
      };
      _parentOf[tile] = id;
      _slotOf[tile] = 'tile';
      ((out['slots'] as Json?) ?? (out['slots'] = <String, Object?>{}))['tile'] = tile;
      _strings(texts, 'listTile', tile, nodes[tile]!);
      return;
    }
    for (var i = 0; i < texts.length; i++) {
      final tid = _id('text');
      final container = type == 'column' || type == 'row' || type == 'stack';
      final style = _textStyle ?? options.textStyles[container ? 'body' : i == 0 ? 'strong' : 'muted'];
      // A container's ink (color=, docs/design/21) is its texts'.
      final ink = container ? _inkAbove(id) : null;
      final bound = ink != null && ink.startsWith('=');
      Object? styled = style is Map ? _copy(style.cast<String, Object?>()) : style;
      if (ink != null && !bound) {
        styled = {...switch (styled) { final Map m => m.cast<String, Object?>(), final String name => {'from': name}, _ => const <String, Object?>{} }, 'color': _named(_value(ink), 'text')};
      }
      nodes[tid] = {
        'type': 'text',
        // In a tile's slot a text is as wide as it is; an accordion's header fills it.
        'layout': {'width': type == 'listTile' || _textStyle != null ? {'hug': 0} : {'fill': 0}, 'height': {'hug': 0}},
        'props': {'text': texts[i], if (styled != null) 'style': styled},
        if (bound || _textColor != null) 'bind': {'props.style.color': _textColor ?? _namedIn(_read(ink!.substring(1).trim()), 'text')},
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

  /// Where the expression [s] begins ends: the first place, outside quotes
  /// and brackets, where a word follows the end of a value with only spaces
  /// between (`list reorder gap=2`: before `reorder`); [s]'s length when
  /// it is one expression.
  static int _expressionEnd(String s) {
    var depth = 0;
    String? quote;
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (quote != null) {
        if (c == quote && s[i - 1] != r'\') quote = null;
        continue;
      }
      if (c == '"' || c == "'") {
        quote = c;
      } else if (c == '(' || c == '[' || c == '{') {
        depth++;
      } else if ((c == ')' || c == ']' || c == '}') && depth > 0) {
        depth--;
      } else if (depth == 0 && c == ' ' && i > 0) {
        final before = s.substring(0, i).trimRight();
        final after = s.substring(i).trimLeft();
        if (before.isEmpty || after.isEmpty) continue;
        final last = before[before.length - 1];
        final ended = RegExp(r'''[A-Za-z0-9_)\]}"']''').hasMatch(last);
        final word = RegExp(r'^[A-Za-z_]').hasMatch(after) && !RegExp(r'^(and|or|not|in|is)\b').hasMatch(after);
        if (ended && word) return s.length - after.length;
      }
    }
    return s.length;
  }

  /// The words of [s] split at spaces outside quotes and brackets
  /// (`gap=2 onReorder={a; b}`: two words).
  static List<String> _topLevelWords(String s) {
    final out = <String>[];
    final b = StringBuffer();
    var depth = 0;
    String? quote;
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (quote != null) {
        if (c == quote && s[i - 1] != r'\') quote = null;
      } else if (c == '"' || c == "'") {
        quote = c;
      } else if (c == '(' || c == '[' || c == '{') {
        depth++;
      } else if ((c == ')' || c == ']' || c == '}') && depth > 0) {
        depth--;
      } else if (c == ' ' && depth == 0) {
        if (b.isNotEmpty) out.add(b.toString());
        b.clear();
        continue;
      }
      b.write(c);
    }
    if (b.isNotEmpty) out.add(b.toString());
    return out;
  }

  /// [line] with the word [name] read as `item`, outside quoted text and
  /// inside `{…}` within it.
  String _rename(String line, String name, [String to = 'item']) {
    // A short loop name may also be a layout key (`each h ... Text ... h=120`).
    // A key followed by ':' is notation, not a reference to the item.
    final word = RegExp('(?<![A-Za-z0-9_.#])${RegExp.escape(name)}(?![A-Za-z0-9_])');
    final out = StringBuffer();
    var quoted = false, inner = false, depth = 0, start = 0;
    // The words of code (no quoted text in it) with the name read as [to].
    String code(String part) => part.replaceAllMapped(word, (m) {
          // In `h=120` the `h` is a prop key. In `live ? h=4` it
          // is still the loop value, despite the following colon.
          final before = part.substring(0, m.start).trimRight();
          final key = m.end < part.length && part[m.end] == '=' && !(m.end + 1 < part.length && part[m.end + 1] == '=') &&
              (m.start == 0 || RegExp(r'\s').hasMatch(part[m.start - 1])) &&
              !before.endsWith('?');
          return key ? m[0]! : to;
        });
    void flush(int end, bool isCode) {
      final part = line.substring(start, end);
      // A string literal in an expression ('m-' + m.id) is text: the loop's
      // name is not renamed inside it. The pieces between the literals are
      // code as they stand: the part may begin with the quote that closed a
      // text before it (`"{x.id}" color={x.on ? 'a' : 'b'}`), which is not
      // a text opening (read again as one, every key after a quoted text
      // that holds a literal kept the loop's name: test 9, admin 1, kanban 2).
      if (isCode && part.contains("'")) {
        final pieces = part.split("'");
        if (pieces.length.isOdd) {
          for (var i = 0; i < pieces.length; i++) {
            if (i > 0) out.write("'");
            out.write(i.isOdd ? pieces[i] : code(pieces[i]));
          }
          start = end;
          return;
        }
      }
      out.write(isCode ? code(part) : part);
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
    // Cells written one by one with columns at other widths (`Grid cols=4
    // phone.cols=2`, round 10, R11: 22 runs) are laid out by the grid an
    // each makes ([_literalGrids]); not inside an each, whose copy that
    // grid's would hide.
    if (g.mediaCols.isNotEmpty && !g.mediaSaid && !_stack.any((o) => o.each != null)) {
      _literalCells.add(g);
      g.mediaSaid = true;
    }
    if (g.mediaCols.isNotEmpty && !g.mediaSaid) {
      g.mediaSaid = true;
      if (!_top._quiet) {
        issues.add(NotationIssue(g.mediaLine, g.mediaColumn,
            "A Grid's columns at another width (tablet.cols=…) are those of the cells an each repeats: cells written one by one stay in their rows. Repeat them with an each, or write the rows."));
      }
    }
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
      if (g.cellLayout['mainAxisExtent'] case final num h) nodes[rowId]!['layout'] = {'width': {'fill': 0}, 'height': h};
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

  /// The Grids of cells written one by one whose columns change at other
  /// widths ([_intoRow]).
  final _literalCells = <_Grid>[];

  /// Each Grid of [_literalCells], once its cells are all read, is the grid an
  /// `each k in range(n)` makes: one copy a cell, each copy showing its own
  /// (`visible={item == k}`), so `tablet.cols` and `phone.cols` are the
  /// grid's columns at those widths as they are over an each. What a
  /// writer could say with an each and an if, said for them.
  void _literalGrids() {
    for (final g in _literalCells) {
      final grid = nodes[g.id];
      if (grid == null) continue;
      final rows = [for (final k in (grid['children'] as List?) ?? const []) if (_gridRows[k] == g) k as String];
      final cells = [
        for (final r in rows) ...[for (final c in (nodes[r]?['children'] as List?) ?? const []) c as String],
      ];
      if (cells.isEmpty) continue;
      final list = _taken('${g.id}Cells') ? _id('gridView') : '${g.id}Cells';
      final item = '${list}Item';
      nodes[list] = {
        'type': 'gridView',
        'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
        'props': {'crossAxisCount': g.cols, 'mainAxisSpacing': g.gap, 'crossAxisSpacing': g.gap, if (!g.cellLayout.containsKey('childAspectRatio')) 'shrinkWrapRows': true, 'physics': 'never', ...g.cellLayout},
        'bind': {
          'data': _formula('range(${cells.length})'),
          if (g.colsFormula case final String cols) 'props.crossAxisCount': cols,
        },
        'media': [for (final r in g.mediaCols) _copy(r)],
        'children': <Object?>[item],
      };
      nodes[item] = {
        'type': 'column',
        'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
        'props': {'crossAxisAlignment': 'start'},
        'children': <Object?>[...cells],
      };
      _parentOf[list] = g.id;
      _parentOf[item] = list;
      _gridLists[list] = g.id;
      for (final r in rows) {
        nodes.remove(r);
        _gridRows.remove(r);
        _parentOf.remove(r);
      }
      grid['children'] = [for (final k in (grid['children'] as List?) ?? const []) if (!rows.contains(k)) k, list];
      for (var k = 0; k < cells.length; k++) {
        final cell = nodes[cells[k]]!;
        _parentOf[cells[k]] = item;
        // A cell takes its copy's width (a row's cell grew to share it).
        final layout = readMap(cell['layout']);
        if (layout != null) layout.remove('flex');
        // One written hidden stays hidden.
        if (cell['visible'] == false) continue;
        final bind = readMap(cell['bind']) ?? <String, Object?>{};
        final own = bind['visible'];
        final mine = _formula('item == $k');
        bind['visible'] = own is String ? _and(mine, own) : mine;
        cell['bind'] = bind;
      }
      if (_canvas) {
        ops
          ..add({'op': 'set', 'id': list, 'parent': g.id, 'index': (grid['children'] as List).length - 1, 'node': {...nodes[list]!}..remove('children')})
          ..add({'op': 'set', 'id': item, 'parent': list, 'index': 0, 'node': {...nodes[item]!}..remove('children')})
          ..addAll([
            for (var k = 0; k < cells.length; k++) ...[
              {'op': 'move', 'id': cells[k], 'parent': item, 'index': k},
              {'op': 'patch', 'id': cells[k], 'patch': {'bind': {'visible': readMap(nodes[cells[k]]!['bind'])?['visible']}, 'layout': {'flex': null}}},
            ],
          ])
          ..add({'op': 'remove', 'ids': rows});
      }
    }
    _literalCells.clear();
  }

  /// The stand-ins written so far that may have nothing to draw, by node id,
  /// each with its label (the word, and its first string value).
  final _bareStandIns = <String, String>{};

  /// The roots of uses of a primitive declared with no lines, by the id the
  /// use gives them, before their line is read ([_bareRoot]).
  final _bareUse = <String, _Silent>{};

  /// The stand-ins and the uses of a primitive declared with no lines, by
  /// node id: what [_silence] reads when each closes.
  final _silent = <String, _Silent>{};

  /// The lines (1-based) written at the top of the text with nothing under
  /// them, in a text whose top also holds an `App` or a `Page` ([parse]).
  Set<int> _silentTopLines = const {};

  /// The nodes [_silence] took out, left out of the document at its end.
  final _dropped = <String>{};

  /// [node], the root of a use of [d], noted when [d] is a primitive with no
  /// lines of its own.
  String _bareRoot(NotationDefinition d, LineParts parts, String node) {
    if (d.bare) _bareUse[node] = _silentOf(d.word, parts, primitive: true);
    return node;
  }

  /// What a stand-in's line (or a primitive's use) [p] gives: a text, a size.
  static _Silent _silentOf(String word, LineParts? p, {bool primitive = false}) => (
        word: word,
        primitive: primitive,
        top: false,
        said: p?.strings.length ?? 0,
        sized: p?.parts.any((x) =>
                (x.kind == 'pair' && const {'w', 'h', 'width', 'height', 'minh', 'minw', 'aspect', 'ratio'}.contains(x.key)) ||
                (x.kind == 'word' && const {'grow', 'expand'}.contains(x.raw))) ??
            false,
      );

  /// The parts of a word (split where a capital starts) that name a
  /// behaviour with no picture: a key or a shortcut, an announcement, a
  /// clock, a sound, a preference, a watch on the scroll, a guard, a focus,
  /// a copy (round 11: `KeyboardShortcut`, `LiveStatus`, `Clock`,
  /// `ReviewSound`, `ThemePreference`, `MenuScroll`, `DraftGuard`).
  static const _behaviourParts = {
    'keys', 'keyboard', 'shortcut', 'shortcuts', 'hotkey', 'hotkeys', 'bindings', 'listener', //
    'announce', 'announcer', 'announcement', 'announcements', 'live', //
    'clock', 'timer', 'ticker', 'sound', 'sounds', 'chime', 'haptic', 'haptics', //
    'preference', 'preferences', 'theme', 'motion', //
    'scroll', 'observer', 'monitor', 'watcher', 'spy', 'trigger', 'follow', 'following', //
    'guard', 'focus', 'clipboard', 'copy', 'transition', 'engine', 'runtime',
  };

  /// The parts that name something seen, which a behaviour's part does not
  /// outweigh (`ClipboardButton`, `ScrollMenu`, `ClockLine`).
  static const _pictureParts = {
    'button', 'bar', 'field', 'input', 'picker', 'chip', 'chips', 'row', 'card', 'panel', 'map', 'slider', 'dial', //
    'grid', 'canvas', 'list', 'tile', 'tab', 'tabs', 'menu', 'badge', 'label', 'text', 'icon', 'view', 'sheet', //
    'dialog', 'surface', 'lane', 'ruler', 'chart', 'scene', 'image', 'photo', 'avatar', 'cap', 'legend', 'hint', //
    'line', 'alert', 'action', 'toggle', 'switch', 'banner', 'toast', 'pill', 'indicator', 'meter', 'progress',
  };

  /// Whether [word] names a behaviour with no picture (its parts:
  /// `KeyboardShortcut` is keyboard, shortcut).
  static bool _behaviour(String word) {
    final parts = [for (final m in RegExp(r'[A-Z]+(?![a-z])|[A-Z]?[a-z0-9]+').allMatches(word)) m[0]!.toLowerCase()];
    return parts.any(_behaviourParts.contains) && !parts.any(_pictureParts.contains);
  }

  /// A stand-in, or the use of a primitive with no lines, that closes: it
  /// draws nothing and takes no room when nothing is written under it and it
  /// stands at the top of the page beside its App or Page, or it names a
  /// behaviour with no picture and gives no size (nor a text, unless it
  /// announces it). A use of such a behaviour with lines under it is those
  /// lines, with no labelled box round them. Its record is kept: the render
  /// says it. True when the node is gone.
  bool _silence(_Open open) {
    if (open.condition != null) return false;
    final s = _silent.remove(open.id);
    final node = nodes[open.id];
    if (s == null || node == null) return false;
    final kids = readStrings(node['children']);
    // A primitive's labelled box: its label first, the lines under the use
    // after it; a stand-in's: its strings' texts first.
    final first = s.primitive ? 1 : s.said;
    final own = kids.length > first ? kids.sublist(first) : const <String>[];
    final parts = [for (final m in RegExp(r'[A-Z]+(?![a-z])|[A-Z]?[a-z0-9]+').allMatches(s.word)) m[0]!.toLowerCase()];
    final announces = parts.any(const {'announce', 'announcer', 'announcement', 'announcements', 'live'}.contains);
    final behaviour = _behaviour(s.word) && !s.sized && (s.said == 0 || announces);
    if (own.isEmpty && (s.top || behaviour)) {
      _bareStandIns.remove(open.id);
      final gone = <String>[];
      void walk(String id) {
        gone.add(id);
        readStrings(nodes[id]?['children']).forEach(walk);
      }

      walk(open.id);
      if (_parentOf.remove(open.id) case final String parent) (nodes[parent]?['children'] as List?)?.remove(open.id);
      // Left out of the document at its end: the line being read counts
      // the nodes it adds from those there before it.
      _dropped.addAll(gone);
      if (_canvas && !s.top) ops.add({'op': 'remove', 'ids': gone});
      return true;
    }
    // A wrapper of what it holds is named after it (`CardKeys`): its
    // behaviour's part is enough.
    if (own.isNotEmpty && s.primitive && parts.any(_behaviourParts.contains)) {
      final label = kids.first;
      _dropped.add(label);
      (node['children'] as List).remove(label);
      node.remove('decoration');
      (node['layout'] as Map?)?.remove('padding');
      (node['props'] as Map?)
        ?..remove('mainAxisAlignment')
        ..['crossAxisAlignment'] = 'stretch';
      if (_canvas) {
        ops
          ..add({'op': 'remove', 'ids': [label]})
          ..add({'op': 'set', 'id': open.id, 'node': {...node}});
      }
    }
    return false;
  }

  /// An app's Main with no ground of its own whose content is a column with
  /// one (`Column pad=24 fill=canvas scroll`) takes it, so the ground reaches
  /// the pane's foot: it stopped where the content did (round 11).
  void _paneGround(_Open open) {
    if (open.condition != null || _roles[open.id] != 'main') return;
    final main = nodes[open.id];
    if (main == null || readMap(main['decoration'])?['fills'] != null) return;
    final kids = readStrings(main['children']);
    final content = kids.isEmpty ? null : nodes[kids.last];
    final fills = readList(readMap(content?['decoration'])?['fills']);
    // The content that scrolls or takes the pane's room, not a bar at its foot.
    final takesPane = readMap(content?['props'])?['scrollable'] == true || readMap(content?['layout'])?['flex'] != null;
    if (content == null || content['type'] != 'column' || !takesPane || fills == null || fills.isEmpty) return;
    final patch = {
      'decoration': {'fills': _copyValue(fills)},
    };
    nodes[open.id] = mergePatch(main, patch);
    _patches.add({'op': 'patch', 'id': open.id, 'patch': patch});
  }

  /// The ink a container's `color=` gives the texts and icons written in it
  /// that set none (docs/design/21), by node id, as written.
  final _ink = <String, String>{};

  /// The removable lines that are not chips, by node id: the actions their
  /// x runs (added at their end when they close).
  final _removeAt = <String, List<Json>>{};

  /// A list's universal words by the id of the line they are on (reorder,
  /// selectable, handle, selected, onReorder, onSelect, each with its column),
  /// with the line's place to record them by: read by the `each` under it.
  final _listUniversal = <String, _ListWords>{};

  /// The rows, columns and flexes whose line says where their children sit
  /// across (`top`, `middle`, `stretch`…).
  final _crossWritten = <String>{};

  /// The `ListView` lines by node id, with where each was written: read when
  /// the line closes ([_listOfLines]).
  final _listLines = <String, ({int line, int column})>{};

  /// A `ListView` whose lines are its own (a line beside an `each`, or no
  /// `each` at all) is no list over data: its first line would be repeated
  /// without end, and one hidden by its `if` drew nothing. Said where it is
  /// written, with the way to write it; read as that scrolling Column (a Row
  /// for a horizontal list). A list with words a Column does not take
  /// (`stickToEnd`, `reverse`, `separator`…) keeps them and has one item,
  /// a column of its lines.
  void _listOfLines(String id) {
    final at = _listLines.remove(id);
    final node = nodes[id];
    if (at == null || node == null || node['type'] != 'listView') return;
    final props = readMap(node['props']) ?? const <String, Object?>{};
    final kids = readStrings(node['children']);
    if (kids.isEmpty || readMap(node['bind'])?['data'] != null || props['itemCount'] != null || props['pagination'] != null) return;
    final across = props['scrollDirection'] == 'horizontal';
    final word = across ? 'Row' : 'Column';
    final flexKeys = {for (final p in FlexProps.all) p.key};
    final bound = [
      for (final k in (readMap(node['bind']) ?? const <String, Object?>{}).keys)
        if (k.startsWith('props.')) k.substring(6),
    ];
    final listOnly = [...props.keys, ...bound].where((k) => !flexKeys.contains(k)).toList();
    if (!_top._quiet) {
      final read = listOnly.isEmpty ? 'read so here' : 'read here as a list of one item, its lines, for ${listOnly.join(', ')}';
      issues.add(NotationIssue(at.line, at.column,
          '${_from == null ? '' : '$_from: '}A ListView repeats the one line under its each; lines of its own beside an each (or with none) are a scrolling $word: $word scroll with the lines and the each under it ($read).'));
    }
    if (listOnly.isEmpty) {
      final patch = <String, Object?>{
        'type': across ? 'row' : 'column',
        'props': {'scrollable': props['scrollable'] ?? true, if (!across) 'crossAxisAlignment': 'start'},
      };
      nodes[id] = mergePatch(node, patch);
      // Its type changes: the node is set again (a patch keeps the type).
      _patches.add({'op': 'set', 'id': id, 'node': nodes[id]});
      return;
    }
    final itemId = _id(across ? 'row' : 'column');
    nodes[itemId] = {
      'type': across ? 'row' : 'column',
      'layout': {
        'width': across ? {'hug': 0} : {'fill': 0},
        'height': across ? {'fill': 0} : {'hug': 0},
      },
      'props': {if (props['spacing'] case final num gap) 'spacing': gap, if (!across) 'crossAxisAlignment': 'start'},
      'children': kids,
    };
    for (final k in kids) {
      _parentOf[k] = itemId;
    }
    _parentOf[itemId] = id;
    final patch = <String, Object?>{
      'props': {'itemCount': 1},
      'children': [itemId],
    };
    nodes[id] = mergePatch(node, patch);
    _patches
      ..add({'op': 'set', 'id': id, 'node': nodes[id]})
      ..add({'op': 'set', 'id': itemId, 'node': nodes[itemId]});
  }

  /// The ink of the nearest container around [id] (itself included) that
  /// gave one with `color=`, as written.
  String? _inkAbove(String? id) {
    for (String? at = id; at != null; at = _parentOf[at]) {
      if (_ink[at] case final String ink) return ink;
    }
    return null;
  }

  /// A stand-in that ends with nothing to draw (no text, no lines under it,
  /// no fill or border of its own) shows a quiet dashed box with its label,
  /// as big as its w and h say: the page reads as unfinished, not broken
  /// (docs/design/19-open-vocabulary.md section 9).
  void _placeholder(_Open open) {
    final label = _bareStandIns.remove(open.id);
    final node = nodes[open.id];
    if (label == null || node == null || (node['children'] as List?)?.isNotEmpty == true) return;
    final deco = readMap(node['decoration']) ?? const {};
    if ((deco['fills'] as List?)?.isNotEmpty == true || (deco['strokes'] as List?)?.isNotEmpty == true) return;
    final layout = readMap(node['layout']) ?? const {};
    final patch = <String, Object?>{
      'decoration': {
        'strokes': [
          {'color': options.line},
        ],
        'dashPattern': [4, 3],
        if (deco['radius'] == null) 'radius': 6,
      },
      'layout': {
        if (layout['padding'] == null) 'padding': 8,
        if (layout['height'] is! num && readMap(layout['constraints'])?['minHeight'] == null) 'constraints': {...?readMap(layout['constraints']), 'minHeight': 40},
      },
      'props': {'mainAxisAlignment': 'center', 'crossAxisAlignment': 'center'},
    };
    nodes[open.id] = mergePatch(node, patch);
    _patches.add({'op': 'patch', 'id': open.id, 'patch': patch});
    final id = _taken('${open.id}Label') ? _id('text') : '${open.id}Label';
    final style = options.textStyles['caption'] ?? options.textStyles['muted'];
    nodes[id] = {
      'type': 'text',
      'layout': {'width': {'hug': 0}, 'height': {'hug': 0}},
      'props': {'text': label, 'maxLines': 1, 'overflow': 'ellipsis', if (style != null) 'style': _copyValue(style)},
    };
    ((nodes[open.id]!['children'] as List?) ?? (nodes[open.id]!['children'] = <Object?>[]) as List).add(id);
    _parentOf[id] = open.id;
  }

  /// A removable line that is not a chip (docs/design/21 section 4.1) ends:
  /// a small x button, named Remove, at its end (a tile's trailing), runs
  /// its onRemove.
  void _removable(_Open open) {
    if (open.each != null || open.condition != null) return;
    final actions = _removeAt.remove(open.id);
    final node = nodes[open.id];
    if (actions == null || node == null) return;
    final id = _taken('${open.id}Remove') ? _id('iconButton') : '${open.id}Remove';
    nodes[id] = {
      'type': 'iconButton',
      'layout': {'width': 28, 'height': 28},
      'props': {
        'icon': 'close',
        'style': {'iconSize': 16},
      },
      'tooltip': 'Remove',
      if (actions.isNotEmpty)
        'actions': [
          {'trigger': {'type': 'click'}, 'actions': actions},
        ],
    };
    _parentOf[id] = open.id;
    if (node['type'] == 'listTile') {
      final slots = (node['slots'] as Json?) ?? (node['slots'] = <String, Object?>{});
      if (slots.containsKey('trailing')) {
        nodes.remove(id);
        _parentOf.remove(id);
        return;
      }
      slots['trailing'] = id;
      _slotOf[id] = 'trailing';
    } else if (open.slots.isNotEmpty) {
      // A block with a slot (a ListRow's trailing): the x after what is in it.
      final row = _slotRow(open);
      (nodes[row]!['children'] as List).add(id);
      _parentOf[id] = row;
    } else {
      ((node['children'] as List?) ?? (node['children'] = <Object?>[]) as List).add(id);
    }
  }

  /// Where a cell of a grid goes (CSS grid's placement).
  static const _cellPlace = ['columnStart', 'rowStart', 'columnSpan', 'rowSpan'];

  /// The copies of an `each` under a Grid are its cells: a place written on
  /// the one line under the each (`columnStart=1 rowStart={index + 1}`) is
  /// the copy's, the grid's item (it was on the line inside the copy, which
  /// the grid does not read, and every copy took the next free cell).
  void _gridPlace(String itemId) {
    final listId = _parentOf[itemId];
    final item = nodes[itemId];
    if (listId == null || item == null || nodes[listId]?['type'] != 'gridView' || !_gridLists.containsKey(listId)) return;
    final kids = readStrings(item['children']);
    if (kids.length != 1) return;
    final line = nodes[kids.single]!;
    final layout = readMap(line['layout']), bind = readMap(line['bind']);
    final itemLayout = <String, Object?>{}, itemBind = <String, Object?>{};
    for (final k in _cellPlace) {
      if (layout?.remove(k) case final Object v) itemLayout[k] = v;
      if (bind?.remove('layout.$k') case final Object v) itemBind['layout.$k'] = v;
    }
    if (itemLayout.isEmpty && itemBind.isEmpty) return;
    if (bind != null && bind.isEmpty) line.remove('bind');
    final patch = <String, Object?>{
      if (itemLayout.isNotEmpty) 'layout': itemLayout,
      if (itemBind.isNotEmpty) 'bind': itemBind,
    };
    nodes[itemId] = mergePatch(item, patch);
    _patches
      ..add({'op': 'set', 'id': kids.single, 'node': {...line}..remove('children')})
      ..add({'op': 'patch', 'id': itemId, 'patch': patch});
  }

  /// Whether the copies of grid list [listId] say their column: the grid
  /// keeps its columns at every width (fewer would move them out of their
  /// tracks).
  bool _placesCells(String listId) {
    final item = nodes['${listId}Item'];
    return readMap(item?['layout'])?['columnStart'] != null || readMap(item?['bind'])?['layout.columnStart'] != null;
  }

  /// A Grid of more than one `each` whose copies each say their cell (a
  /// timetable: the times down its first column, the sessions in their
  /// tracks' columns and their slots' rows) is one grid: the lists the eaches
  /// make lie over each other in a stack, each placing its copies in the
  /// same columns and rows. (They were grids one under another, each placing
  /// its copies in rows of its own.)
  void _gridOverlay(_Grid g) {
    final grid = nodes[g.id];
    if (grid == null || grid['type'] != 'column') return;
    final kids = readStrings(grid['children']);
    if (kids.length < 2) return;
    for (final k in kids) {
      if (_gridLists[k] != g.id || nodes[k]?['type'] != 'gridView') return;
      final item = nodes['${k}Item'];
      final placed = readMap(item?['layout']) ?? const {}, bound = readMap(item?['bind']) ?? const {};
      bool says(String key) => placed[key] != null || bound['layout.$key'] != null;
      if (!says('columnStart') || !says('rowStart')) return;
    }
    // (A column's props, its gap among them, are not a stack's.)
    nodes[g.id] = ({...grid}..remove('props'))..['type'] = 'stack';
    _patches.add({'op': 'set', 'id': g.id, 'node': {...nodes[g.id]!}});
  }

  /// A grid ends: its last row is filled out with empty cells, so its cells
  /// are as wide as the rows above.
  static final _idMark = RegExp(r'^([A-Z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)?)#[A-Za-z_][A-Za-z0-9_]*(?:-[A-Za-z0-9_]+)*');

  /// The actions a tap on a selectable list's row runs (it chooses the row),
  /// by the id of the row's copy.
  final _selectTaps = <String, List<Json>>{};

  /// A selectable list's row that takes the tap itself (an onTap of its own;
  /// a block that fires an event when tapped: a TableRow, a ListRow) would
  /// never pass it to the copy around it: the row's own tap chooses it too,
  /// before what it does.
  void _selectThrough(String itemId) {
    final choose = _selectTaps.remove(itemId);
    final children = (nodes[itemId]?['children'] as List?) ?? const [];
    if (choose == null || children.length != 1) return;
    final childId = children.single as String;
    final child = nodes[childId];
    final type = child?['type'];
    if (child == null || type is! String || type.isEmpty) return;
    final spec = catalog.widget(type);
    final reactions = ((child['actions'] as List?) ?? const []).cast<Object?>();
    final Json? trigger = type[0] != type[0].toLowerCase() && spec != null && spec.events.isNotEmpty
        ? _handlerTrigger('onTap', type, spec, child)
        : reactions.any((r) => r is Map && r['trigger'] is Map && (r['trigger'] as Map)['type'] == 'click')
            ? const {'type': 'click'}
            : null;
    // A block's event is its tap only by name (not a Rating's onChanged).
    if (trigger == null || (trigger['type'] == 'event' && !RegExp(r'^on(Tap|Press|Pressed|Click|Select|Selected|Open)$').hasMatch('${trigger['event']}'))) return;
    final own = reactions.whereType<Map>().where((r) => jsonEncode(r['trigger']) == jsonEncode(trigger)).firstOrNull;
    final next = <Object?>[
      for (final r in reactions)
        if (r is Map && identical(r, own))
          <String, Object?>{...r.cast<String, Object?>(), 'actions': [..._copyValue(choose) as List, ...(r['actions'] as List? ?? const [])]}
        else
          r,
      if (own == null) <String, Object?>{'trigger': trigger, 'actions': _copyValue(choose)},
    ];
    child['actions'] = next;
    _patches.add({'op': 'patch', 'id': childId, 'patch': {'actions': next}});
  }

  /// The action of a block with a slot and no action of its own, by node id:
  /// its label and what it does (a quiet button put in the slot when the
  /// block closes).
  final _slotActions = <String, ({String label, List<Json> actions})>{};

  /// A block's action ([_slotActions]): a ghost button at the end of its
  /// slot, before a removable line's x.
  void _slotAction(_Open open) {
    final action = _slotActions.remove(open.id);
    if (action == null || open.slots.isEmpty || nodes[open.id] == null) return;
    final look = buttonVariants['ghost'] ?? buttonVariants.values.first;
    final id = _id(look.type);
    final label = action.label;
    nodes[id] = {
      'type': look.type,
      'layout': {'width': {'hug': 0}, 'height': {'hug': 0}},
      'props': {..._copy(look.props), if (!label.contains(r'${')) 'label': label},
      if (label.contains(r'${')) 'bind': {'props.label': label},
      if (action.actions.isNotEmpty)
        'actions': [
          {'trigger': {'type': 'click'}, 'actions': action.actions},
        ],
    };
    final row = _slotRow(open);
    (nodes[row]!['children'] as List).add(id);
    _parentOf[id] = row;
  }

  void _close(_Open open) {
    if (open.splice || _silence(open)) return;
    _paneGround(open);
    _placeholder(open);
    _slotAction(open);
    _removable(open);
    if (open.each != null) _selectThrough(open.id);
    if (open.each == null && open.condition == null) _listOfLines(open.id);
    if (open.each != null) _gridPlace(open.id);
    if (open.grid case final g? when open.id == g.id && open.condition == null) _gridOverlay(g);
    // A list's universal words no each under the line read: left out, and
    // recorded as unknown (docs/design/21 section 4.1).
    if ((open.each == null && open.condition == null ? _listUniversal.remove(open.id) : null) case final _ListWords lw when !lw.applied) {
      // The variable it names is still the page's (what reads it validates).
      if (lw.value('selected') case final String v) variables.putIfAbsent(v, () => {'name': v, 'type': 'list', 'value': const <Object?>[]});
      // selectable chooses among the copies an each makes, and there is none
      // here (a row of its own, a card under the each): said where it is.
      if (lw.words['selectable'] case (:final column, value: _) when !lw.standIn && !_top._quiet) {
        issues.add(NotationIssue(lw.line, column,
            'selectable chooses among the rows an each repeats: write it on the Column (Card, Section) the each is directly under, with selected=@name for the selection: Column selectable selected=@picked, then each m in members under it.'));
      }
      // A stand-in's words are in its own record.
      if (options.openVocabulary && !lw.standIn) {
        for (final e in lw.words.entries) {
          final event = e.key.startsWith('on');
          final of = event ? 'event' : (e.key == 'selected' || e.value.value != 'true' ? 'parameter' : 'flag');
          _use(of, e.key, e.value.column, on: lw.on, value: of == 'flag' ? null : (event ? '{${e.value.value}}' : e.value.value), at: lw);
        }
      }
    }
    _fitRow(open);
    final g = open.grid;
    if (g == null || open.id != g.id || open.condition != null || g.row == null) return;
    // A grid of cells that becomes a list's ([_literalGrids]) is filled by it.
    while (g.inRow < g.cols && !_literalCells.contains(g)) {
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
    // What the text's brackets leave unread (brackets.dart), once it is all
    // here: a line a list or a JSON escape carries over the next is read
    // joined, as [line] reads it.
    if (!_mediaLine && _rawText.isNotEmpty) {
      issues.addAll(notationBracketIssues(_rawText.toString()));
      _rawText.clear();
    }
    if (_host == null) {
      _closeBlock();
      // The viewer a gallery of the page opens its photos in, over the window.
      if (_pages.viewerUsed && !_continues && !_taken(_pages.viewer!)) {
        final viewer = _pages.viewer!;
        if (_pages.overlay('Lightbox#$viewer photos={${viewer}Photos} @${viewer}At') case final Overlay o) {
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
    // What a defined word still has to write (the rest of its lines), each
    // line's nodes sent before the next line's.
    _from = null;
    for (final d in _defined.finish()) {
      _from = d.from;
      for (final l in _pages.rewrite(d.indent, d.text)) {
        final role = _roleMark.firstMatch(l.text);
        _lastNode = null;
        final mark = nodes.length;
        _lineAt(l.indent, role == null ? l.text : '${role[1]}${l.text.substring(role.end)}', l.indent + 1);
        if (role != null && _lastNode != null) _roles[_lastNode!] = role[2]!;
        nodes.keys.skip(mark).toList().forEach(_emit);
      }
    }
    _from = null;
    final before = nodes.length;
    for (final l in _pages.finish()) {
      _lineAt(l.indent, l.text, l.indent + 1);
    }
    while (_stack.isNotEmpty) {
      _close(_stack.removeLast());
    }
    nodes.keys.skip(before).toList().forEach(_emit);
    for (final scroll in _scrolls) {
      if (_anchors[scroll['node']] case final String id) {
        scroll['node'] = id;
      }
    }
    // With an open vocabulary the page renders whatever it names: an
    // `open <id>` of nothing written over this page, and a `scroll <id>` to
    // no line of it, are left out, and said where they are written.
    if (_host == null && options.openVocabulary) {
      // An `open` of an overlay the answer never wrote (asked for a few
      // screens, models write the button and leave the dialog out): a quiet
      // sheet titled with its id opens, and it is recorded as a wanted
      // overlay (kind `overlay`), not an issue.
      final have = {for (final o in _overlays) o.options.screen};
      final unwritten = <String, int>{};
      for (final a in _opens) {
        final to = a['to'];
        if (to is String && RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(to) && !have.contains(to) && !_taken(to)) {
          unwritten.putIfAbsent(to, () => _actionLines[a] ?? _line);
        }
      }
      for (final e in unwritten.entries) {
        if (_pages.overlay('Sheet#${e.key} "${_humanised(e.key)}"') case final Overlay o) {
          _openBlock(o);
          _quiet = true;
          _feed(2, 'Text.muted "Not written yet."');
          _blockLines.add((indent: 2, text: 'Text.muted "Not written yet."'));
          _closeBlock();
          _quiet = false;
          if (_overlays.any((p) => p.options.screen == e.key)) {
            vocabulary.add(VocabularyUse(kind: 'overlay', word: e.key, source: 'open ${e.key}', line: e.value, column: 1, node: e.key));
          }
        }
      }
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
                    '${written.isEmpty ? 'This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.' : 'Over this page: ${written.map((w) => '"$w"').join(', ')}.'}'
                : 'No line of this page has the id "$id" for a scroll to go to (Section#$id, or id=$id on a line): the action is left out.'));
      }
    }
    // A variable bound with `@name` is declared: what no state line, site
    // variable or loop gave is said where it is first bound.
    if (_host == null) {
      for (final e in _unstated.entries) {
        issues.add(NotationIssue(e.value.line, e.value.column,
            '@${e.key} binds a variable nothing declares: add state ${e.key}=${jsonEncode(e.value.start())} at the top of the screen (a variable is declared before it is bound).'));
      }
      _unstated.clear();
    }
    _literalGrids();
    _ownLegends();
    _feet();
    _endButtons();
    _fieldsBesideButtons();
    _framedSelectsBare();
    _labelledFieldHeights();
    _wrapFills();
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

  /// Whether a line of [type] (written [written]) has a text where a bare
  /// number may stand for it (docs/design/21 section 8): a text, a box, a
  /// button, a chip, a tile; not a grid (`Grid 3` is no text), an icon or a
  /// field.
  static bool _textAt(String type, String written) =>
      type == 'text' ||
      (const {'column', 'row', 'stack', 'listTile', 'accordion', 'expansionTile'}.contains(type) && written != 'Grid' && written != 'GridView') ||
      (type.endsWith('Button') && type != 'iconButton') ||
      type.endsWith('Chip') ||
      type == 'chip';

  /// What is wrong with the [given]th quoted string (1-based) on a line of
  /// [type] written [written], or null: design 13 section 3 gives a line one
  /// main string; a second has a place only on an Input (its hint) and on a
  /// container, whose strings are texts in it (a tile's subtitle, a
  /// column's next text). A box (`box`, not `Image`) has no text at all.
  static String? _stringProblem(String type, String written, int given) {
    if (type == 'box' && written != 'Image') {
      return 'A box has no text of its own: write the text on a Text line, or `Image "url"` for a picture.';
    }
    if (given < 2 || const {'accordion', 'expansionTile', 'column', 'row', 'stack'}.contains(type)) return null;
    if (given == 2 && (type == 'textField' || type == 'listTile')) return null;
    final most = type == 'textField' || type == 'listTile' ? 'two quoted strings' : 'one quoted string';
    return '${'AEIOU'.contains(written[0]) ? 'An' : 'A'} $written takes $most: this one is left out. Write another value as key="value".';
  }

  String? _mainKey(String type, WidgetSpec spec) {
    if (type == 'box') return 'text';
    if (type == 'dropdown') return 'hint';
    // `Barcode "29034 00718 4421"`: what it encodes.
    if (type == 'barcode') return 'data';
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

  /// A whole-number variable (`state zoom=1`, an integer) that [expression]
  /// may set to a fraction (`zoom*1.25`, `done/total`, a decimal variable)
  /// is a decimal from here on: an integer would round what is written.
  /// A null [expression]: a control that writes decimals is bound to it.
  void _widen(String name, String? expression) {
    final v = variables[name];
    if (v == null || v['type'] != 'integer' || _projectVariables.contains(name) || _top._typedStates.contains(name)) return;
    final code = expression?.replaceAll(RegExp('"[^"]*"|\'[^\']*\''), '');
    final fraction = code == null ||
        RegExp(r'(?<![A-Za-z0-9_.])\d*\.\d+|/').hasMatch(code) ||
        RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(code).any((m) => variables[m[0]]?['type'] == 'decimal');
    if (!fraction) return;
    variables[name] = {...v, 'type': 'decimal'};
    _declared.remove(name); // declared again, as it is now
  }

  /// State written as a formula (`state total=sum(cart,x=>x.price)`): not a
  /// variable but a name for the formula, written out where it is read.
  final Map<String, String> _derived;

  /// The runtime's names every expression of a screen reads, wherever it is
  /// (of the validator's runtimeScopes, those no node gives).
  static const _screenScopes = {'data', 'route', 'storage', 'screen', 'theme', 'auth', 'drag', 'perf', 'script', 'speech'};

  void _state(String rest, int column) {
    // `state draft="" saved`: its value is kept on the device and is there
    // again after a reload (Variable.persist).
    // (`saved=true` and `persist=true` say the same as a key.)
    rest = rest.replaceFirst(RegExp(r'\s+(saved|persist|persisted)=true$'), ' saved');
    final saved = rest.endsWith(' saved');
    if (saved) rest = rest.substring(0, rest.length - 6).trimRight();
    // `state count:decimal=2`: a type the value does not say; `state
    // note:text` with no value; `state total:decimal={price*qty}` a formula
    // variable of the document (with no type, a formula is written out where
    // it is read); `state clamp01(v):decimal={min(1, max(0, v))}` a function
    // (docs/design/22 section 4.5).
    final typed = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)(?:\(([^()]*)\))?:([a-z]+)(?:\s*=\s*(.+))?$').firstMatch(rest);
    if (typed != null) {
      final name = typed[1]!, type = typed[3]!, value = typed[4]?.trim();
      final params = [for (final p in (typed[2] ?? '').split(',')) if (p.trim().isNotEmpty) p.trim()];
      if (!const {'integer', 'text', 'decimal', 'boolean', 'color', 'list', 'map', 'image', 'choice'}.contains(type)) {
        return _issue(column, 'A variable\x27s type is one of integer, text, decimal, boolean, color, list, map, image, choice: state $name:decimal=0.');
      }
      final formula = value != null && _bracedExpression(value);
      if (typed[2] != null && !formula) return _issue(column, 'A function is a formula in braces: state $name(${typed[2]}):$type={…}.');
      // A call reaches the engine's function of that name first: this one
      // would never run (formula_names.dart).
      if (typed[2] != null && notationFormulaFunctionNames.contains(name)) {
        final other = 'my${name[0].toUpperCase()}${name.substring(1)}';
        _issue(column, 'state $name(${typed[2]}): $name is one of the formula functions ($name(…) calls that one, never this): name it otherwise, as state $other(${typed[2]}):$type={…}, and call $other(…).');
      }
      // Declared: what binds it (`@name`) needs no other line.
      _top._stated.add(name);
      _top._typedStates.add(name);
      _top._unstated.remove(name);
      // (A name the runtime gives a scope is refused typed as untyped.)
      if (name == 'device') return _issue(column, 'device is read-only input capability; use device.hover or device.pointer in an if or binding.');
      if (_screenScopes.contains(name)) {
        return _issue(column, '$name is a name the runtime gives every expression (${_screenScopes.join(', ')}): name the state otherwise (state ${name}Text=…).');
      }
      variables[name] = {
        'name': name,
        'type': type,
        if (formula) 'formula': value.substring(1, value.length - 1).trim() else if (value != null) 'value': _value(value),
        if (params.isNotEmpty) 'parameters': params,
        if (saved) 'persist': true,
      };
      return;
    }
    final m = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)$').firstMatch(rest);
    if (m == null) return _issue(column, 'State is written: state name=value.');
    // Declared, even where it is refused below: what binds it is said once.
    _top._stated.add(m[1]!);
    _top._unstated.remove(m[1]);
    if (m[1] == 'device') return _issue(column, 'device is read-only input capability; use device.hover or device.pointer in an if or binding.');
    // A name the runtime gives every expression of the screen (`script`,
    // `route`, `data`): a state of that name would be read as the
    // runtime's, never as itself. (The names a node gives what is in it,
    // item, view, form…, are its own there only.)
    if (_screenScopes.contains(m[1])) {
      return _issue(column, '${m[1]} is a name the runtime gives every expression (${_screenScopes.join(', ')}): name the state otherwise (state ${m[1]}Text=…).');
    }
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
  /// event of that name or of its family (onTap a block's onPressed,
  /// [blockEventFor]); else, as on a plain node, the trigger the name says
  /// (onTap on a card whose only event is onMenu is a press on the card).
  /// Null when there is no such event.
  Json? _handlerTrigger(String key, String type, WidgetSpec? component, Json node) {
    if (key == 'onDrop') return {'type': 'drop'};
    // A table: a header pressed (result.column, result.ascending) and a row
    // chosen (result.row, result.rowIndex).
    if (type == 'tableView' && key == 'onSort') return {'type': 'sort'};
    if (type == 'tableView' && (key == 'onRowTap' || key == 'onTap')) return {'type': 'rowTap'};
    if (component != null) {
      final named = blockEventFor(key, [for (final e in component.events) e.key]) ??
          // onTap on a block its own press sends an event: that event.
          (const {'onTap', 'onPress', 'onPressed', 'onClick'}.contains(key) ? options.componentPressEvents[type] : null);
      if (named != null) return {'type': 'event', 'event': named};
    }
    // Every trigger of the catalog, by the notation's name for it
    // (notationEventNames) or its own with a capital (design 22 section 2.2).
    return switch (notationEventTrigger(key)) {
      final String type => {'type': type},
      _ => null,
    };
  }

  /// [line] without the assignments to [name] in its events' actions (and
  /// without an event left with none).
  String _withoutSets(String line, String name) {
    final k = RegExp.escape(name);
    final out = StringBuffer();
    var at = 0;
    for (final m in RegExp(r'(\s+)(on[A-Z][A-Za-z]*(?:\([^()]*\))?)=\{').allMatches(line)) {
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
    if (RegExp(r'^(emit|open|scroll|close|go|toast|announce|link|confirm|focus|copy)\b').hasMatch(a) || a.startsWith('{') || startsTyped(a)) return null;
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
    // `index>0 ? conditions=setAt(…)`: a choice with no else (test 10: 5
    // runs, refused as an unknown action): nothing when it does not hold.
    if (question > 0 && nested == 0) {
      final cond = a.substring(0, question).trim(), yes = unwrap(a.substring(question + 1));
      if (cond.isNotEmpty && yes.isNotEmpty) return (cond, yes, '');
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
  /// `item.done` (of the repeated element: `@i.done` under `each i in
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
        return '@$expr: "$root" is no variable of this page. Declare the record first (state $root={"${parts[1]}":""}), or bind a variable of its own (@${parts.last}).';
      }
      return (root, withAt(root, parts.sublist(1), value), jsonEncode(expr));
    }
    // A field of a repeated element: which each, counted from the innermost.
    var up = 0, at = 0;
    while (at < parts.length && parts[at] == 'parent') {
      up++;
      at++;
    }
    if (at >= parts.length || parts[at] != 'item' || at == parts.length - 1) return '@$expr names no field of an element.';
    final fields = parts.sublist(at + 1);
    final eaches = [for (final o in _stack) if (o.each != null) o];
    final n = eaches.length, target = n - 1 - up;
    if (target < 0) return '@$expr is written under no each.';
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
      return '@$written: the each repeats $shown, which is worked out, so a change has no list to be written to. '
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
    // A field of an element written where it stands (`d.pos = 0` under an
    // each over a list worked out, a nested list's element, a record
    // variable's field: `draft.title = ""`): the variable it is in, rebuilt.
    final path = RegExp(r'^((?:parent\.)*item(?:\.[A-Za-z_][A-Za-z0-9_]*)+|[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)+)\s*=(?!=)\s*(.+)$').firstMatch(a);
    if (path != null && (path[1]!.startsWith('item.') || path[1]!.startsWith('parent.') || variables.containsKey(path[1]!.split('.').first))) {
      if (_fieldWrite(path[1]!, '(${path[2]})') case (final String variable, final String next, _)) return '$variable = $next';
    }
    final at = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\[([^\]]+)\]\.([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=)\s*(.+)$').firstMatch(a);
    if (at != null) return '${at[1]} = setAt(${at[1]},${at[2]},with(${at[1]}[${at[2]}],"${at[3]}",${at[4]}))';
    return a;
  }

  /// A list that follows its end and grows (`each m in msgs follow grow`)
  /// scrolls itself in the room its column leaves: each column it is in,
  /// from [id] up, takes the height left to it, up to the first that
  /// scrolls (an App's Main), which then stops scrolling (one scroll, the
  /// list's, and what is beside the list, a composer, stays in view) or one
  /// of a fixed height.
  void _growToPane(String id) {
    void patch(String at, Json change) {
      nodes[at] = mergePatch(nodes[at]!, change);
      if (_canvas) ops.add({'op': 'patch', 'id': at, 'patch': change});
    }

    for (String? at = id; at != null; at = _parentOf[at]) {
      final node = nodes[at];
      if (node == null || node['type'] != 'column') return;
      final props = readMap(node['props']) ?? const {};
      final layout = readMap(node['layout']) ?? const {};
      if (props['scrollable'] == true) {
        patch(at, {'props': {'scrollable': false}});
        return;
      }
      if (layout['height'] is num) return;
      final up = _parentOf[at];
      if (up == null || nodes[up]?['type'] != 'column') return;
      if (readMap(layout['height'])?.containsKey('fill') != true) {
        patch(at, {'layout': {'height': {'fill': 0, 'hug': null}, 'flex': 1}});
      }
    }
  }

  /// `, 3` when the each around a `mark={q}` repeats `fuzzy(list, q, x =>
  /// text, 3)`: what is marked is what that search matched, with the
  /// misspelling it allowed; '' otherwise.
  String _markTolerance(String query) {
    for (final open in _stack.reversed) {
      final list = open.list;
      if (open.each == null || list == null) continue;
      final call = RegExp(r'^fuzzy\((.*)\)$').firstMatch(list.trim());
      if (call == null) return '';
      final args = _split(call[1]!, ',').map((a) => a.trim()).toList();
      if (args.length < 4 || args[1] != query.trim()) return '';
      final tolerance = args.skip(3).where((a) => num.tryParse(a) != null).firstOrNull;
      return tolerance == null ? '' : ', $tolerance';
    }
    return '';
  }

  /// `key mod+k onPress={open search}`, `key j when={!editing} onPress={…}`
  /// (`when={…}` before or after onPress, or `when expression` before it):
  /// the canvas's keyDown reaction; null when the line is not one.
  Json? _shortcut(String line, int column) {
    final head = RegExp(r'^key\s+"?([^"\s]+)"?\s+').firstMatch(line);
    var combo = head?[1];
    // `key +` and `key mod++` (test 10: the sign as itself): the key plus.
    if (combo == '+') combo = 'plus';
    if (combo != null && combo.length > 2 && combo.endsWith('++')) combo = '${combo.substring(0, combo.length - 1)}plus';
    if (head == null || KeyCombo.tryParse(combo) == null || combo!.endsWith('+')) return null;
    final tokens = _Tokens(line.substring(head.end));
    String? when, press;
    while (true) {
      tokens.skipSpace();
      if (tokens.done) break;
      final word = tokens.word();
      if ((word == 'when=' || word == 'onPress=') && tokens.peek == '{') {
        final braced = tokens.balanced();
        if (!braced.endsWith('}')) return null;
        final inner = braced.substring(1, braced.length - 1).trim();
        if (word == 'when=') {
          when = inner;
        } else {
          press = inner;
        }
      } else if (word == 'when' && when == null) {
        // `when running onPress={…}`: the expression up to onPress.
        when = tokens.until([' onPress={']).trim();
      } else {
        return null;
      }
    }
    if (press == null) return null;
    // The key by the name the keyboard gives it (`left` is ArrowLeft); a
    // name no key has would never fire: an issue, and no reaction.
    final key = notationKeyName(combo);
    if (key == null) {
      _issue(column + 4, _noKeyName(combo));
      return const {};
    }
    return {
      'trigger': {'type': 'keyDown', 'key': key, if (when != null && when.isNotEmpty) 'when': _formula(when)},
      'actions': _actions(press, column),
    };
  }

  /// `confirm "Delete 2 clips?" "They cannot be restored." ok="Delete" danger
  /// then {clips=[]} else {toast "Kept"}`: the actions after `then` run when
  /// the question is answered yes, those after `else` when it is not. Between
  /// the question and `then`: a second quoted text (the detail under it),
  /// `ok=` and `cancel=` (the buttons' words) and `danger` (the yes button in
  /// the error color, and the focus starting on Cancel).
  Json? _confirm(String a, int column) {
    const usage = 'A confirm is a quoted question and what a yes does: confirm "Remove it?" then {count=0; toast "Removed"} '
        '(confirm "Delete 2 clips?" "They cannot be restored." ok="Delete" cancel="Keep" danger then {clips=[]} else {toast "Kept"}).';
    final tokens = _Tokens(a.substring('confirm'.length))..skipSpace();
    // The question, quoted first (or as title="…", the confirm action's own
    // field names: title, message, confirmLabel, cancelLabel, destructive).
    var title = tokens.peek == '"' ? tokens.string() : null;
    String? message, ok, cancel;
    var danger = false;
    while (true) {
      tokens.skipSpace();
      if (tokens.done) break;
      if (tokens.peek == '"') {
        if (message != null) {
          _issue(column, 'A confirm has a question and one line of detail under it; name the buttons with ok="…" and cancel="…". $usage');
          return null;
        }
        message = tokens.string();
        continue;
      }
      if (tokens.rest.startsWith('then') && (tokens.rest.length == 4 || const {' ', '{'}.contains(tokens.rest[4]))) break;
      final word = tokens.word();
      final eq = word.indexOf('=');
      final key = eq < 0 ? word : word.substring(0, eq);
      String value() {
        if (eq + 1 < word.length) return word.substring(eq + 1);
        // A word worked out: ok={n > 1 ? "Delete all" : "Delete"}.
        return tokens.peek == '"' ? tokens.string() : tokens.peek == '{' ? tokens.balanced() : '';
      }

      switch (key) {
        case 'danger' || 'destructive' when eq < 0:
          danger = true;
        case 'danger' || 'destructive' when eq > 0:
          danger = value() == 'true';
        case 'ok' || 'yes' || 'confirmLabel' || 'confirm' when eq > 0:
          ok = value();
        case 'cancel' || 'no' || 'cancelLabel' when eq > 0:
          cancel = value();
        case 'message' || 'detail' when eq > 0 && message == null:
          message = value();
        case 'title' || 'question' when eq > 0 && title == null:
          title = value();
        default:
          _issue(column, 'A confirm takes a detail line (or message="…"), ok="…" (confirmLabel), cancel="…" (cancelLabel) and danger (destructive=true) before then; "$word" is not one of them. $usage');
          return null;
      }
    }
    if (title == null) {
      _issue(column, usage);
      return null;
    }
    var tail = tokens.rest.trim();
    if (!tail.startsWith('then') || tail.substring(4).trim().isEmpty) {
      _issue(column, usage);
      return null;
    }
    tail = tail.substring(4).trim();
    var yes = tail, no = '';
    if (tail.startsWith('{')) {
      final close = _Tokens(tail)._closeOf(0);
      if (close > 0) {
        yes = tail.substring(1, close).trim();
        final after = tail.substring(close + 1).trim();
        if (after.startsWith('else')) {
          no = after.substring(4).trim();
          if (no.startsWith('{') && no.endsWith('}')) no = no.substring(1, no.length - 1).trim();
        } else if (after.isNotEmpty) {
          _issue(column, 'After a confirm\'s then {…} comes else {…} (what a no does) or nothing; "$after" is neither.');
          return null;
        }
      }
    }
    final then = _actions(yes, column), orElse = no.isEmpty ? const <Json>[] : _actions(no, column);
    if (then.isEmpty && orElse.isEmpty) return null;
    return {
      'type': 'confirm',
      'title': _interpolate(title),
      if (message != null && message.isNotEmpty) 'message': _interpolate(message),
      if (ok != null && ok.isNotEmpty) 'confirmLabel': _interpolate(ok),
      if (cancel != null && cancel.isNotEmpty) 'cancelLabel': _interpolate(cancel),
      if (danger) 'destructive': true,
      'actions': then,
      if (orElse.isNotEmpty) 'cancelActions': orElse,
    };
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
      // `setThemeMode dark`, `setThemeMode {dark ? "dark" : "light"}`: its one
      // field written alone, as models write it (test 10: 4 runs).
      if (RegExp(r'^setThemeMode\s+(\{.*\}|"[^"]*"|[A-Za-z_][A-Za-z0-9_.]*)$').firstMatch(a) case final m?) {
        final v = m[1]!.trim();
        final braced = v.startsWith('{') && v.endsWith('}');
        out.add({'type': 'setThemeMode', 'mode': braced ? _formula(v.substring(1, v.length - 1).trim()) : _unquoted(v)});
        continue;
      }
      // An action of the catalog by its type and fields (design 22 section 2.3).
      if (typedAction(a, column) case final Json typed) {
        out.add(typed);
        continue;
      }
      if (a.startsWith('confirm ') || a == 'confirm') {
        if (_confirm(a, column) case final Json c) out.add(c);
        continue;
      }
      // `props.selected=m.id` in a component (round 10, R20: refused as an
      // unknown action): its variable parameter set, which the caller's
      // `@name` then holds (`setVariable variable=props.selected`).
      if (RegExp(r'^props\.([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=)\s*(.+)$').firstMatch(a) case final m? when _top._widget != null) {
        final param = [
          for (final p in (_top._widget!['props'] as List?) ?? const [])
            if (readMap(p) case final Json j when j['key'] == m[1]) j,
        ].firstOrNull;
        if (param == null || readMap(param['type'])?['kind'] != 'variable') {
          _issue(column,
              '${param == null ? 'The component has no parameter "${m[1]}"' : 'The parameter "${m[1]}" is given by the call, not kept'}: a parameter the component sets is a variable one, param @${m[1]}=… (or param ${m[1]}:ValueNotifier<String>=…), and the call binds it (@name).');
          continue;
        }
        final v = m[2]!.trim();
        final literal = _literal(v);
        out.add({'type': 'setVariable', 'variable': 'props.${m[1]}', 'value': literal.$1 && literal.$2 is String ? _interpolate(literal.$2! as String) : _formula(v)});
        continue;
      }
      final set = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=)\s*(.+)$').firstMatch(a);
      if (set != null) {
        final v = set[2]!.trim();
        final literal = _literal(v);
        // A bare word that names no variable is text (choice=basic).
        final word = !literal.$1 && _identifier.hasMatch(v) && !v.contains('.') && !variables.containsKey(v) && !const {'result', 'item', 'index'}.contains(v);
        if (!word) _widen(set[1]!, v);
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
              'value': RegExp(r'^[A-Za-z][A-Za-z0-9]*( [A-Za-z0-9]+)+$').hasMatch(value) ? value : _emitted(value),
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
          // A bare word that names one of the app's screens is that screen,
          // whatever the state holds under the same name (`go recipes` with
          // a list called recipes).
          final screen = braced || arg.startsWith('"') ? null : notationScreen(s, options.screens);
          if (screen != null) {
            out.add({'type': 'navigate', 'to': screen});
            continue;
          }
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
        case 'focus' || 'blur' || 'unfocus':
          // `focus search` puts the caret in that field (its id), `focus`
          // or `blur` alone takes it away.
          final target = s.replaceFirst(RegExp(r'^#'), '').trim();
          if (verb != 'focus' || target.isEmpty) {
            out.add({'type': 'focus', 'unfocus': true});
          } else if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*(?:/[A-Za-z_][A-Za-z0-9_-]*)*$').hasMatch(target)) {
            _issue(column, 'A focus names the field by its id: focus search (Input#search "Search" …), or a component\'s field by the call\'s id and its own: focus filters/search.');
          } else {
            out.add({'type': 'focus', 'node': target});
          }
        case 'copy':
          // `copy "{link}"`, `copy link`, `copy {code}`: that text to the clipboard.
          if (arg.isEmpty) {
            _issue(column, 'A copy says what to copy: copy "{link}" or copy link.');
          } else {
            final braced = arg.startsWith('{') && arg.endsWith('}');
            out.add({
              'type': 'copyToClipboard',
              'text': arg.startsWith('"') ? s : _read(braced ? arg.substring(1, arg.length - 1) : arg),
            });
            out.add({'type': 'showToast', 'message': 'Copied'});
          }
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
          _issue(column, 'Unknown action "$verb". Actions: name=value, emit <event>, toast "…", open <id>, close, go <screen>, scroll <id>, link <url>, announce "…", confirm "Question" then {actions}, focus <id>, copy "…", a choice cond ? actions : actions, '
              'any action of the catalog by its type and fields (animate node=hero command=forward), or JSON'
              '${switch (didYouMean(verb, [..._verbs, 'confirm', for (final s in catalog.actions) s.type])) { final String n => '. Did you mean "$n"?', _ => '.' }}');
      }
    }
    return out;
  }

  static const _verbs = {'emit', 'open', 'scroll', 'close', 'go', 'toast', 'announce', 'link', 'focus', 'copy'};

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

  /// The names a `state` (or `project`) line declares.
  final Set<String> _stated = {};

  /// The state declared with a type written (`state page:integer=0`): that
  /// type is the variable's, never widened to a decimal.
  final Set<String> _typedStates = {};

  /// The names the notation makes itself for a word it writes out (an
  /// overlay's own state, a block's own boolean, a list's own selection):
  /// bound without a state line of the writer's.
  final Set<String> _internal = {};

  /// The variables a line binds (`@name`) that nothing declares yet, each
  /// with where it is first bound and the value it would start at (worked
  /// out once its line is read): said at the end, when no state line came.
  final Map<String, ({int line, int column, Object? Function() start})> _unstated = {};

  /// [name], bound by `@name` at [column] of this line, is a variable the
  /// writer declares: a state line, the site's variable, a loop's item, or a
  /// name the notation made itself. [start] is the value a state line for it
  /// would give, what the control starts at.
  void _bindsVariable(String name, int column, Object? Function() start) {
    final top = _top;
    if (top._quiet || name == 'item' || name.startsWith('parent.')) return;
    if (top._stated.contains(name) || top._internal.contains(name) || _projectVariables.contains(name) || options.projectVariables.containsKey(name)) return;
    if (_stack.any((o) => o.each == name)) return;
    top._unstated.putIfAbsent(name, () => (line: _line, column: column, start: start));
  }

  /// Tells apart the unknown verbs of one event (they share its column).
  int _verbAt = 0;

  /// What a component call's [keys] of look (a fill, a border) are said with:
  /// a call has no look of its own, its definition has (round 10, R31).
  static String _callLook(String written, List<String> keys) =>
      '${keys.map((k) => '$k=').join(', ')} on a call of $written is left out. ${_callLookWhy(written)}';

  static String _callLookWhy(String written) =>
      'A component call has no look of its own: its size, place, margin and the widths it changes at are the call\'s (w=, maxw=, phone.w=), '
      'its look is its definition\'s. Give $written a parameter for it (param tone=…, read in its tree), or write the look on a line around the call.';

  /// A key a line of [written] (document type [type]) has no name for, said
  /// with the nearest name the catalog has there; a design system's
  /// component with what it takes.
  String _noKey(String written, String key, String type, {bool component = false, WidgetSpec? takes}) {
    if (component && takes != null) {
      final look = const {'radius', 'shadow', 'effects', 'clip', 'clipBehavior', 'opacity'}.contains(key) && key != 'opacity';
      return 'A $written has no "$key". It takes: ${takes.props.map((p) => p.key).join(', ')}.${look ? ' ${_callLookWhy(written)}' : ''}';
    }
    final near = notationKeyNearest(key, type, catalog: catalog);
    return 'A $written has no "$key"${near == null ? '' : ' (did you mean $near?)'}: left out.';
  }

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

  /// An emitted value: a quoted text with values in it (`"{result}"`,
  /// `"page-{id}"`) reads them, as a text does; else [_valueOrRead].
  Object? _emitted(String raw) {
    final l = _literal(raw);
    if (l.$1 && l.$2 is String && raw.trimLeft().startsWith('"') && (l.$2! as String).contains('{')) return _interpolate(l.$2! as String);
    return _valueOrRead(raw);
  }

  Object? _valueOrRead(String raw) {
    final l = _literal(raw);
    return l.$1 ? l.$2 : _read(raw);
  }

  /// An id as words for a title: `rowMenu`, `add-recipe`, `new_project` are
  /// "Row menu", "Add recipe", "New project".
  static String _humanised(String id) {
    final words = id
        .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .trim()
        .toLowerCase();
    return words.isEmpty ? id : '${words[0].toUpperCase()}${words.substring(1)}';
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

  /// `Dots @page count=n` (in any order, `value=@page` the same): its id,
  /// its page's variable, its count and the rest of the line, or null.
  static ({String id, String page, String count, String rest})? _dotsOf(String line) {
    final head = RegExp(r'^Dots(#[A-Za-z_][A-Za-z0-9_]*(?:-[A-Za-z0-9_]+)*)?(?=\s|$)').firstMatch(line);
    if (head == null) return null;
    var rest = line.substring(head.end);
    final page = RegExp(r'\s(?:value=)?@([A-Za-z_][A-Za-z0-9_]*)(?=\s|$)').firstMatch(rest);
    if (page == null) return null;
    rest = rest.replaceRange(page.start, page.end, '');
    final count = RegExp(r'\scount=(\{[^{}]*\}|\S+)').firstMatch(rest);
    if (count == null) return null;
    rest = rest.replaceRange(count.start, count.end, '');
    return (id: head[1] ?? '', page: page[1]!, count: count[1]!, rest: rest.trimRight());
  }
  static final _identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_.]*$');

  /// An expression as a binding reads it: a name, or a formula.
  String _read(String expr) {
    final e = expr.trim();
    // A word that is a value, not a name (enabled={false}): the value.
    if (const {'true', 'false', 'null'}.contains(e)) return _formula(e);
    // A name or a path is read as it is (`kpis[0].value`, an element of a
    // list by its index: design 22, 4.8); anything the formula language
    // spells otherwise (rows.length) is a formula.
    return (_identifier.hasMatch(e) || _indexedPath.hasMatch(e)) && _natural(e) == e ? '\${$e}' : _formula(e);
  }

  /// A path with an element of a list by its index in it: `kpis[0].value`.
  static final _indexedPath = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*|\[[0-9]+\])*$');

  String _formula(String expr) => '\${= ${_natural(_textsRead(_colors(notationUnbraced(expr))))}}';

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

  /// `{name}` in a string is a read: `${name}`. A string with the document's
  /// own formula, `${= …}`, written in it is kept as written, every `${…}`
  /// and `{…}` in it (design 22, 4.8): `"${= theme.colors.ink}"`,
  /// `"$${= price}"`. Elsewhere a `$` before a read is a dollar, as models
  /// write a price (`"Total ${qty*12}"` is `Total $${= qty*12}`).
  String _interpolate(String s) {
    if (_writtenRead.hasMatch(s)) return s;
    s = s.replaceAll(r'\$', r'$');
    final out = StringBuffer();
    var at = 0;
    for (final (start, end) in _spans(s)) {
      out
        ..write(s.substring(at, start))
        ..write(_read(_quotedBreaks(s.substring(start + 1, end - 1))));
      at = end;
    }
    out.write(s.substring(at));
    return out.toString();
  }

  /// Whether the field at [path] of a node of [type] holds an expression it
  /// works out itself, so a string with `${…}` in it is its value as written
  /// rather than a binding (design 22, 4.8): a text's own text, an Input's
  /// validator (it runs on the text typed, `value`), a drop target's key and
  /// condition (worked out for each drop), an image paint's URL (filled in
  /// from the scope, as a text's own text is).
  static bool _holdsExpression(String type, String path) =>
      (type == 'text' && path == 'props.text') ||
      (type == 'textField' && path == 'props.validator') ||
      path == 'dropTarget.key' ||
      path == 'dropTarget.acceptIf' ||
      _imageUrl.hasMatch(path);

  static final _imageUrl = RegExp(r'^decoration\.(fills|foregroundFills)\[\d+\]\.image\.url$');

  /// A `${=` written in a string (not `\${=`): the string is as written.
  static final _writtenRead = RegExp(r'(?<!\\)\$\{=');

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
        // A line break inside a string of the expression (`'\n'` in a quoted
        // text, which the text's own escapes made a break) is the
        // expression's: it was printed raw with no word (test 9, mail).
        final inner = _quotedBreaks(s.substring(i + 1, end - 1));
        final around = _quotedBreaks(inner, outside: true);
        final code = around.contains('\n') || around.contains(r'\n') || RegExp(r"^\s*[A-Za-z_]\w*\s*:\s|^\s+[A-Za-z_]\w*\s+$").hasMatch(inner);
        if (!code) out.add((i, end));
        i = end - 1;
      }
    }
    return out;
  }

  /// [expr] with each line break and tab inside a string literal of it
  /// written as its escape (`'\n'`); [outside]: [expr] with the insides of
  /// its string literals taken out (the code around them).
  static String _quotedBreaks(String expr, {bool outside = false}) {
    if (!outside && !expr.contains('\n') && !expr.contains('\t')) return expr;
    final out = StringBuffer();
    String? quote;
    for (var i = 0; i < expr.length; i++) {
      final c = expr[i];
      if (quote != null) {
        if (c == quote && expr[i - 1] != r'\') {
          quote = null;
          out.write(c);
        } else if (outside) {
          continue;
        } else if (c == '\n') {
          out.write(r'\n');
        } else if (c == '\t') {
          out.write(r'\t');
        } else {
          out.write(c);
        }
        continue;
      }
      if (c == "'" || c == '"') quote = c;
      out.write(c);
    }
    return out.toString();
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
  // Not a switch: dart2wasm (Flutter 3.50) traps with "illegal cast" on a
  // switch over string constants when the value is not a string (a number).
  Object? _size(Object? v) => v == 'fill' ? {'fill': 0} : v == 'hug' ? {'hug': 0} : v;

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
    if (!options.nearestColors || options.palette.isEmpty) return formula;
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
    // Past the closing quote; a text the line ends inside (no closing quote)
    // ends with the line (the cursor past it made the parser throw).
    at = at + 1 > s.length ? s.length : at + 1;
    final raw = s.substring(start, at);
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

/// The events a line may give, as an issue lists them.
const _eventsTaught = 'onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop';

/// [props] with every Material icon written by its bare name (`inbox`, at a
/// key named `icon` or ending in `Icon`, in the props or a record or list in
/// them: a tab's, a segment's, a menu item's) drawn in [style]
/// ([NotationOptions.iconStyle]). A name with a style of its own, an
/// expression and anything else are left as written.
void _styleIcons(Object? props, String style) {
  final suffix = '_$style';
  bool isIconKey(Object? k) => k is String && (k == 'icon' || k.endsWith('Icon'));
  if (props is Map) {
    for (final k in props.keys.toList()) {
      final v = props[k];
      if (isIconKey(k) && v is String && RegExp(r'^[a-z0-9_]+$').hasMatch(v) && !RegExp(r'_(outlined|outline|rounded|sharp|filled)$').hasMatch(v)) {
        props[k] = '$v$suffix';
      } else if (v is Map || v is List) {
        _styleIcons(v, style);
      }
    }
  } else if (props is List) {
    for (final e in props) {
      _styleIcons(e, style);
    }
  }
}
