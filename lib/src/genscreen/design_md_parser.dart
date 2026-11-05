/// Reads a DESIGN.md design kit into a [DesignKit], with line-numbered
/// issues for whatever it couldn't read or finds off-brand-unsafe (a missing
/// token, an unreadable color, text that fails contrast).
library;

import 'design_kit.dart';

/// How serious a [DesignMdIssue] is.
enum DesignMdSeverity {
  /// The kit can't be used as written (a required token is missing).
  error,

  /// The kit works, but something is ignored or risky.
  warning,
}

/// A problem found while reading a DESIGN.md.
class DesignMdIssue {
  /// 1-based line, or 0 for the whole document.
  final int line;

  /// How serious it is.
  final DesignMdSeverity severity;

  /// What is wrong, in words a kit author can act on.
  final String message;

  /// Creates a [DesignMdIssue].
  const DesignMdIssue(this.line, this.severity, this.message);

  @override
  String toString() =>
      '${severity.name}${line > 0 ? ' (line $line)' : ''}: $message';
}

/// The result of [DesignMdParser.parse].
class DesignMdParseResult {
  /// The kit, with defaults wherever the document left something out.
  final DesignKit kit;

  /// Everything worth telling the author.
  final List<DesignMdIssue> issues;

  /// Creates a [DesignMdParseResult].
  const DesignMdParseResult(this.kit, this.issues);

  /// Whether no issue is an error.
  bool get isValid =>
      issues.every((DesignMdIssue i) => i.severity != DesignMdSeverity.error);
}

/// Color tokens every kit must define.
const List<String> requiredColorTokens = <String>[
  'primary',
  'onPrimary',
  'background',
  'surface',
  'onSurface',
];

/// Color tokens the generator uses when present (and derives otherwise).
const List<String> recommendedColorTokens = <String>[
  'secondary',
  'onSecondary',
  'surfaceVariant',
  'onSurfaceVariant',
  'outline',
  'error',
  'onError',
  'success',
  'warning',
];

/// Type roles every kit must define.
const List<String> requiredTextStyles = <String>['title', 'body', 'label'];

/// The type roles the generator knows, largest first.
const List<String> knownTextStyles = <String>[
  'display',
  'headline',
  'title',
  'subtitle',
  'body',
  'label',
  'caption',
];

/// Reads DESIGN.md text.
class DesignMdParser {
  /// Creates a [DesignMdParser].
  const DesignMdParser();

  /// Parses [source].
  DesignMdParseResult parse(String source) {
    final List<DesignMdIssue> issues = <DesignMdIssue>[];
    final List<String> lines = source.replaceAll('\r\n', '\n').split('\n');
    final Map<String, String> front = <String, String>{};
    int start = 0;
    if (lines.isNotEmpty && lines.first.trim() == '---') {
      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim() == '---') {
          start = i + 1;
          break;
        }
        final Match? m = RegExp(r'^([\w-]+)\s*:\s*(.*)$').firstMatch(lines[i]);
        if (m != null) front[m[1]!.toLowerCase()] = _unquote(m[2]!.trim());
      }
    }

    String title = '';
    final List<_Section> sections = <_Section>[];
    _Section? section;
    _Section? sub;
    for (int i = start; i < lines.length; i++) {
      final String line = lines[i];
      if (line.startsWith('# ')) {
        title = line.substring(2).trim();
        continue;
      }
      if (line.startsWith('## ')) {
        section = _Section(line.substring(3).trim(), i + 1);
        sections.add(section);
        sub = null;
        continue;
      }
      if (line.startsWith('### ') && section != null) {
        sub = _Section(line.substring(4).trim(), i + 1);
        section.subsections.add(sub);
        continue;
      }
      (sub ?? section)?.lines.add(_Line(i + 1, line));
    }

    final String name =
        front['name'] ??
        title.replaceAll(RegExp(r'\s*(design\s*kit|design\.md)\s*$', caseSensitive: false), '').trim();
    if (name.isEmpty) {
      issues.add(
        const DesignMdIssue(
          0,
          DesignMdSeverity.warning,
          'No kit name: add "name:" to the front matter.',
        ),
      );
    }

    KitGuide brand = const KitGuide();
    final Map<String, KitColorToken> colors = <String, KitColorToken>{};
    final Map<String, KitTextStyle> typography = <String, KitTextStyle>{};
    final Map<String, double> spacing = <String, double>{};
    final Map<String, double> radius = <String, double>{};
    final Map<String, List<KitShadow>> elevation = <String, List<KitShadow>>{};
    final Map<String, KitGuide> components = <String, KitGuide>{};
    final List<KitBreakpoint> breakpoints = <KitBreakpoint>[];
    KitGuide layout = const KitGuide();
    final Map<String, KitMotion> motion = <String, KitMotion>{};
    KitGuide motionGuide = const KitGuide();
    KitGuide imagery = const KitGuide();
    KitGuide icons = const KitGuide();
    KitGuide accessibility = const KitGuide();
    final Map<String, String> extra = <String, String>{};

    for (final _Section s in sections) {
      final KitGuide guide = _guide(s.lines, issues);
      switch (sectionKey(s.title)) {
        case 'brand':
          brand = guide;
        case 'colors':
          for (final _Row row in _rows(s.lines)) {
            final String token = lowerCamel(row.first);
            final String lightText = row.get('light') ?? row.get('value') ?? '';
            final KitColor? light = KitColor.tryParse(lightText);
            if (token.isEmpty) continue;
            if (light == null) {
              issues.add(
                DesignMdIssue(
                  row.line,
                  DesignMdSeverity.error,
                  'Color "$token" has no readable value ("$lightText"); '
                  'use #RRGGBB or #RRGGBB/60.',
                ),
              );
              continue;
            }
            final String darkText = row.get('dark') ?? '';
            final KitColor? dark = darkText.isEmpty || darkText == '-'
                ? null
                : KitColor.tryParse(darkText);
            if (darkText.isNotEmpty && darkText != '-' && dark == null) {
              issues.add(
                DesignMdIssue(
                  row.line,
                  DesignMdSeverity.warning,
                  'Dark value of "$token" ("$darkText") is unreadable; ignored.',
                ),
              );
            }
            colors[token] = KitColorToken(
              token,
              light,
              dark: dark,
              usage: row.get('usage') ?? '',
            );
          }
        case 'typography':
          for (final _Row row in _rows(s.lines)) {
            final String token = lowerCamel(row.first);
            final String family = row.get('family') ?? row.get('font') ?? '';
            final double? size = _number(row.get('size'));
            if (token.isEmpty) continue;
            if (family.isEmpty || size == null) {
              issues.add(
                DesignMdIssue(
                  row.line,
                  DesignMdSeverity.error,
                  'Text style "$token" needs a family and a size.',
                ),
              );
              continue;
            }
            typography[token] = KitTextStyle(
              token,
              family: family,
              size: size,
              weight: _weight(row.get('weight')),
              lineHeight: _number(row.get('lineHeight')) ?? 1.3,
              letterSpacing: _number(row.get('letterSpacing')) ?? 0,
              uppercase: (row.get('case') ?? '').toLowerCase().startsWith(
                'upper',
              ),
              usage: row.get('usage') ?? '',
            );
          }
        case 'spacing':
        case 'radius':
          final Map<String, double> target = sectionKey(s.title) == 'spacing'
              ? spacing
              : radius;
          for (final _Row row in _rows(s.lines)) {
            final double? value = _number(row.get('value') ?? row.at(1));
            final String token = lowerCamel(row.first);
            if (token.isEmpty) continue;
            if (value == null) {
              issues.add(
                DesignMdIssue(
                  row.line,
                  DesignMdSeverity.error,
                  '"$token" needs a number of pixels.',
                ),
              );
              continue;
            }
            target[token] = value;
          }
        case 'elevation':
          for (final _Row row in _rows(s.lines)) {
            final String token = lowerCamel(row.first);
            if (token.isEmpty) continue;
            final List<KitShadow>? shadows = parseShadows(
              row.get('shadow') ?? row.at(1) ?? '',
            );
            if (shadows == null) {
              issues.add(
                DesignMdIssue(
                  row.line,
                  DesignMdSeverity.error,
                  'Elevation "$token" should be "none" or '
                  '"x y blur spread #color" (comma-separated for several).',
                ),
              );
              continue;
            }
            elevation[token] = shadows;
          }
        case 'components':
          for (final _Section c in s.subsections) {
            components[componentKey(c.title)] = _guide(c.lines, issues);
          }
        case 'layout':
          layout = guide;
          for (final _Row row in _rows(s.lines)) {
            final String bp = row.first.toLowerCase();
            if (!const ['mobile', 'tablet', 'desktop'].contains(bp)) continue;
            breakpoints.add(
              KitBreakpoint(
                bp,
                minWidth: _number(row.get('minWidth')) ?? 0,
                columns: _number(row.get('columns'))?.round() ?? 4,
                margin: row.get('margin') ?? 'md',
                gutter: row.get('gutter') ?? 'md',
                maxContent: _number(row.get('maxContent')) ?? 1200,
              ),
            );
          }
          breakpoints.sort(
            (KitBreakpoint a, KitBreakpoint b) =>
                a.minWidth.compareTo(b.minWidth),
          );
          layout = KitGuide(
            props: guide.props,
            rules: guide.rules,
            dos: guide.dos,
            donts: guide.donts,
            notes: guide.notes,
          );
        case 'motion':
          for (final _Row row in _rows(s.lines)) {
            final String token = lowerCamel(row.first);
            final double? ms = _number(row.get('duration'));
            if (token.isEmpty) continue;
            if (ms == null) {
              issues.add(
                DesignMdIssue(
                  row.line,
                  DesignMdSeverity.warning,
                  'Motion "$token" needs a duration in ms; ignored.',
                ),
              );
              continue;
            }
            motion[token] = KitMotion(
              token,
              ms.round(),
              row.get('curve') ?? 'easeInOut',
              usage: row.get('usage') ?? '',
            );
          }
          motionGuide = KitGuide(
            props: guide.props,
            rules: guide.rules,
            dos: guide.dos,
            donts: guide.donts,
            notes: guide.notes,
          );
        case 'imagery':
          imagery = guide;
        case 'iconography':
          icons = guide;
        case 'accessibility':
          accessibility = guide;
        default:
          extra[s.title] = s.lines.map((_Line l) => l.text).join('\n').trim();
          issues.add(
            DesignMdIssue(
              s.line,
              DesignMdSeverity.warning,
              'Section "${s.title}" is not part of the format; kept as is '
              'but the generator does not read it.',
            ),
          );
      }
    }

    for (final String token in requiredColorTokens) {
      if (!colors.containsKey(token)) {
        issues.add(
          DesignMdIssue(
            0,
            DesignMdSeverity.error,
            'Missing required color token "$token".',
          ),
        );
      }
    }
    for (final String token in requiredTextStyles) {
      if (!typography.containsKey(token)) {
        issues.add(
          DesignMdIssue(
            0,
            DesignMdSeverity.error,
            'Missing required text style "$token".',
          ),
        );
      }
    }
    if (spacing.isEmpty) {
      issues.add(
        const DesignMdIssue(
          0,
          DesignMdSeverity.error,
          'No spacing scale: add a Spacing table (xs, sm, md, lg, xl).',
        ),
      );
    }
    _checkContrast(colors, accessibility, issues);

    final DesignKit kit = DesignKit(
      name: name.isEmpty ? 'Untitled kit' : name,
      version: front['version'] ?? '1.0.0',
      description: front['description'] ?? '',
      brand: brand,
      colors: colors,
      typography: typography,
      spacing: spacing,
      radius: radius,
      elevation: elevation,
      components: components,
      breakpoints: breakpoints,
      layout: layout,
      motion: motion,
      motionGuide: motionGuide,
      imagery: imagery,
      icons: icons,
      accessibility: accessibility,
      extra: extra,
    );
    return DesignMdParseResult(kit, issues);
  }

  /// Text pairs the generator puts on each other, checked against the kit's
  /// minimum contrast (4.5 unless Accessibility says otherwise).
  static const List<List<String>> contrastPairs = <List<String>>[
    ['onPrimary', 'primary'],
    ['onSurface', 'surface'],
    ['onSurface', 'background'],
    ['onSecondary', 'secondary'],
    ['onError', 'error'],
    ['onSurfaceVariant', 'surface'],
  ];

  void _checkContrast(
    Map<String, KitColorToken> colors,
    KitGuide accessibility,
    List<DesignMdIssue> issues,
  ) {
    final double minimum =
        _number(accessibility['minContrast']?.split(':').first) ?? 4.5;
    for (final List<String> pair in contrastPairs) {
      final KitColor? fg = colors[pair[0]]?.light;
      final KitColor? bg = colors[pair[1]]?.light;
      if (fg == null || bg == null) continue;
      final double ratio = fg.contrastWith(bg);
      // Muted text gets the large-text allowance of 3:1.
      final double needed = pair[0] == 'onSurfaceVariant' ? 3 : minimum;
      if (ratio < needed) {
        issues.add(
          DesignMdIssue(
            0,
            DesignMdSeverity.warning,
            '${pair[0]} on ${pair[1]} has contrast '
            '${ratio.toStringAsFixed(2)}:1, below $needed:1.',
          ),
        );
      }
    }
  }
}

/// The format's name for a section heading (aliases allowed), or the
/// heading itself, lowercased, when it isn't one.
String sectionKey(String heading) {
  final String key = heading.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
  const Map<String, String> aliases = <String, String>{
    'brand': 'brand',
    'brandandvoice': 'brand',
    'voice': 'brand',
    'colors': 'colors',
    'color': 'colors',
    'colours': 'colors',
    'colour': 'colors',
    'palette': 'colors',
    'typography': 'typography',
    'type': 'typography',
    'spacing': 'spacing',
    'space': 'spacing',
    'radius': 'radius',
    'radii': 'radius',
    'corners': 'radius',
    'shape': 'radius',
    'elevation': 'elevation',
    'shadows': 'elevation',
    'components': 'components',
    'componentinventory': 'components',
    'layout': 'layout',
    'layoutpatterns': 'layout',
    'grid': 'layout',
    'motion': 'motion',
    'motionandtransitions': 'motion',
    'animation': 'motion',
    'imagery': 'imagery',
    'images': 'imagery',
    'iconography': 'iconography',
    'icons': 'iconography',
    'accessibility': 'accessibility',
    'ay': 'accessibility',
  };
  return aliases[key] ?? key;
}

/// The normalized name of a component heading: `List row` → `listRow`,
/// `Buttons` → `button`, `Text field` → `input`.
String componentKey(String heading) {
  final String key = lowerCamel(heading);
  const Map<String, String> aliases = <String, String>{
    'buttons': 'button',
    'cards': 'card',
    'listRows': 'listRow',
    'listItem': 'listRow',
    'listItems': 'listRow',
    'row': 'listRow',
    'inputs': 'input',
    'textField': 'input',
    'textFields': 'input',
    'field': 'input',
    'fields': 'input',
    'navigation': 'navBar',
    'nav': 'navBar',
    'navigationBar': 'navBar',
    'bottomNav': 'navBar',
    'topBar': 'appBar',
    'header': 'appBar',
    'chips': 'chip',
    'tag': 'chip',
    'tags': 'chip',
    'badges': 'badge',
    'avatars': 'avatar',
    'alert': 'banner',
    'alerts': 'banner',
    'banners': 'banner',
    'toggle': 'switch',
    'toggles': 'switch',
    'switches': 'switch',
    'tab': 'tabs',
    'divider': 'divider',
    'dividers': 'divider',
  };
  return aliases[key] ?? key;
}

/// `Line height` → `lineHeight`, `on-primary` → `onPrimary`.
String lowerCamel(String text) {
  final List<String> words = text
      .replaceAll(RegExp(r'[*`_]'), '')
      .replaceAll("'", '')
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .where((String w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '';
  // Already camelCase (`onPrimary`) stays as written.
  if (words.length == 1) {
    final String w = words.first;
    return w[0].toLowerCase() + w.substring(1);
  }
  return words.first.toLowerCase() +
      words
          .skip(1)
          .map((String w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
          .join();
}

/// Reads `none` or `x y blur spread color[, ...]`; null when unreadable.
List<KitShadow>? parseShadows(String text) {
  final String value = text.trim();
  if (value.isEmpty || value.toLowerCase() == 'none' || value == '-') {
    return <KitShadow>[];
  }
  final List<KitShadow> shadows = <KitShadow>[];
  for (final String part in value.split(RegExp(r',\s*(?=-?\d)'))) {
    final List<String> bits = part.trim().split(RegExp(r'\s+'));
    if (bits.length < 5) return null;
    final List<double?> numbers = bits.take(4).map(double.tryParse).toList();
    final KitColor? color = KitColor.tryParse(bits.skip(4).join(' '));
    if (numbers.contains(null) || color == null) return null;
    shadows.add(
      KitShadow(numbers[0]!, numbers[1]!, numbers[2]!, numbers[3]!, color),
    );
  }
  return shadows;
}

double? _number(String? text) {
  if (text == null) return null;
  final Match? m = RegExp(r'-?\d+(\.\d+)?').firstMatch(text);
  return m == null ? null : double.parse(m[0]!);
}

int _weight(String? text) {
  if (text == null || text.trim().isEmpty) return 400;
  final double? n = _number(text);
  if (n != null) return (n / 100).round().clamp(1, 9) * 100;
  const Map<String, int> names = <String, int>{
    'thin': 100,
    'extralight': 200,
    'light': 300,
    'regular': 400,
    'normal': 400,
    'medium': 500,
    'semibold': 600,
    'bold': 700,
    'extrabold': 800,
    'black': 900,
  };
  return names[text.toLowerCase().replaceAll(RegExp('[^a-z]'), '')] ?? 400;
}

String _unquote(String text) =>
    text.length >= 2 &&
        (text.startsWith('"') && text.endsWith('"') ||
            text.startsWith("'") && text.endsWith("'"))
    ? text.substring(1, text.length - 1)
    : text;

class _Line {
  final int number;
  final String text;
  const _Line(this.number, this.text);
}

class _Section {
  final String title;
  final int line;
  final List<_Line> lines = <_Line>[];
  final List<_Section> subsections = <_Section>[];
  _Section(this.title, this.line);
}

class _Row {
  final int line;
  final List<String> headers;
  final List<String> cells;
  const _Row(this.line, this.headers, this.cells);

  String get first => cells.isEmpty ? '' : cells.first;

  String? at(int i) => i < cells.length ? cells[i] : null;

  String? get(String header) {
    final int i = headers.indexOf(header);
    if (i < 0 || i >= cells.length) return null;
    final String v = cells[i].trim();
    return v.isEmpty ? null : v;
  }
}

List<String> _cells(String line) {
  String t = line.trim();
  if (t.startsWith('|')) t = t.substring(1);
  if (t.endsWith('|')) t = t.substring(0, t.length - 1);
  return t.split('|').map((String c) => c.trim().replaceAll('`', '')).toList();
}

bool _isSeparator(String line) =>
    RegExp(r'^\s*\|?\s*:?-{2,}').hasMatch(line) &&
    !RegExp('[A-Za-z0-9]').hasMatch(line);

/// The rows of the first table in [lines], with headers in lowerCamelCase.
List<_Row> _rows(List<_Line> lines) {
  final List<_Row> rows = <_Row>[];
  List<String>? headers;
  for (final _Line l in lines) {
    final String t = l.text.trim();
    if (!t.startsWith('|')) {
      if (headers != null && rows.isNotEmpty) break;
      continue;
    }
    if (_isSeparator(t)) continue;
    if (headers == null) {
      headers = _cells(t).map(lowerCamel).toList();
      continue;
    }
    rows.add(_Row(l.number, headers, _cells(t)));
  }
  return rows;
}

KitGuide _guide(List<_Line> lines, List<DesignMdIssue> issues) {
  final Map<String, String> props = <String, String>{};
  final List<Map<String, String>> table = <Map<String, String>>[];
  final List<String> rules = <String>[], dos = <String>[], donts = <String>[];
  final List<String> paragraphs = <String>[];
  List<String> current = rules;
  StringBuffer paragraph = StringBuffer();

  void endParagraph() {
    if (paragraph.isNotEmpty) paragraphs.add(paragraph.toString().trim());
    paragraph = StringBuffer();
  }

  for (final _Row row in _rows(lines)) {
    table.add(<String, String>{
      for (int i = 0; i < row.headers.length; i++)
        row.headers[i]: i < row.cells.length ? row.cells[i] : '',
    });
  }

  for (final _Line l in lines) {
    final String t = l.text.trim();
    if (t.isEmpty) {
      endParagraph();
      continue;
    }
    if (t.startsWith('|') || t.startsWith('<!--')) {
      endParagraph();
      continue;
    }
    final Match? label = RegExp(
      r"^\**(rules|usage rules|do|dos|don'?t|donts|don'?ts)\**\s*:\s*\**\s*(.*)$",
      caseSensitive: false,
    ).firstMatch(t);
    if (label != null) {
      endParagraph();
      final String which = label[1]!.toLowerCase().replaceAll("'", '');
      current = which.startsWith('rule') || which.startsWith('usage')
          ? rules
          : which.startsWith('dont')
          ? donts
          : dos;
      if (label[2]!.trim().isNotEmpty) current.add(label[2]!.trim());
      continue;
    }
    final Match? item = RegExp(r'^[-*+]\s+(.*)$').firstMatch(t);
    if (item != null) {
      endParagraph();
      current.add(item[1]!.trim());
      continue;
    }
    final Match? prop = RegExp(
      r"^\**([A-Za-z][A-Za-z0-9 /'()-]{0,40}?)\**\s*:\s+(.+)$",
    ).firstMatch(t);
    if (prop != null && paragraph.isEmpty) {
      props[lowerCamel(prop[1]!)] = prop[2]!.trim();
      continue;
    }
    if (paragraph.isNotEmpty) paragraph.write(' ');
    paragraph.write(t);
  }
  endParagraph();
  return KitGuide(
    props: props,
    table: table,
    rules: rules,
    dos: dos,
    donts: donts,
    notes: paragraphs.join('\n\n'),
  );
}
