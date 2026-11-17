// Builds docs/reference/notation: the reference of the compact notation (the
// "DSL"), the same document as the JSON reference written in the notation's
// words. Everything here is generated:
//
// * the words of each node type, its quoted strings and its keys, from the
//   catalog (catalog.dart) and from the parser itself (keys.dart for the
//   shortest key of each path; a parse of `Word "…"` for what a string fills;
//   a print of the type alone for the word the printer writes);
// * the events from the trigger types (`notationEventName`), the actions from
//   the action specs, each verb from a parse of its sample;
// * the formulas, media conditions, animation words, variants and universal
//   words from their tables in the package;
// * every example of the JSON reference (tool/reference/examples and the
//   ```json blocks of its templates), printed with `printNotation`; what a
//   print leaves in a `{…}` tail is listed in `_tails.md`;
// * the prose from tool/reference/templates/notation, whose ```notation
//   blocks are each parsed and printed back here: a block that does not read
//   back as written stops the generator, with its file and line.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart' as api;
import 'package:codelessly_api/src/core/behavior_fields.dart' show AnimationTrackFields, NodeAnimationFields, TransitionFields;
import 'package:codelessly_api/src/core/custom_paint_fields.dart' show CustomPaintFields, DrawOpCommonFields, DrawOpSpecs;
import 'package:codelessly_api/src/core/levels.dart';
import 'package:codelessly_api/src/core/notation/keys.dart' show notationKeyFor, notationKeyPath, notationTextStyleProp;
import 'package:codelessly_api/src/core/notation/media_words.dart' show mediaHideWords, mediaSizes;
import 'package:codelessly_api/src/core/notation/notation.dart'
    show NotationOptions, badgeVariants, buttonVariants, defaultTextVariants, notationAnimations, notationEventName, notationTypes, parseNotation;
import 'package:codelessly_api/src/core/notation/page_words.dart' show PageWords;
import 'package:codelessly_api/src/core/notation/print.dart' show notationOptionsFor, printNotation;
import 'package:codelessly_api/src/core/notation/universal.dart' show UniversalKind, notationUniversal;

import 'areas.dart';
import 'catalog.dart';
import 'markdown.dart' show Renderer;

typedef Json = Map<String, dynamic>;

/// The folder the notation reference is written to, from the package root.
const String notationDir = 'docs/reference/notation';

/// The catalog every notation block is read and printed with.
api.Catalog get notationCatalog => api.standardCatalog;

/// [notationCatalog] with the components the examples declare (a page of a
/// site calls its `Header`): what a block marked `components` is read with.
api.Catalog notationComponentsCatalog(String root) => _components[root] ??= () {
      final declared = <String, Object?>{};
      for (final f in Directory('$root/tool/reference/examples').listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.json')) continue;
        final json = jsonDecode(readLf(f.path));
        final widget = json is Map ? json['widget'] : null;
        if (widget is Map && widget['type'] is String) declared.putIfAbsent('${widget['type']}', () => widget);
      }
      return notationCatalog + api.Catalog.fromJson({'id': 'examples', 'widgets': [...declared.values]});
    }();

final Map<String, api.Catalog> _components = {};

// --- the pages -----------------------------------------------------------------

/// A page of the notation reference: `<id>.md`, rendered from
/// `templates/notation/<id>.md`.
final class NotationPage {
  const NotationPage(this.id, this.title, {this.json = const [], this.layer = false});

  final String id, title;

  /// The JSON reference's pages (templates) whose items and examples are
  /// on this page (`base` is STARTER.md).
  final List<String> json;

  /// A feature layer (a library of its own): listed apart in the index.
  final bool layer;

  String get file => '$id.md';
}

/// The pages after NOTATION.md, in reading order. Every JSON page but
/// `edit-ops` (the `ui_apply` ops, which the notation does not use) has its
/// items and examples on the page of the same id, or on `document`.
const List<NotationPage> notationPages = [
  NotationPage('layout', 'Layout', json: ['layout']),
  NotationPage('theme', 'Text and theme', json: ['theme']),
  NotationPage('decoration', 'Decoration', json: ['decoration']),
  NotationPage('paint', 'Custom paint'),
  NotationPage('forms', 'Controls and forms', json: ['forms']),
  NotationPage('lists', 'Lists and data', json: ['lists']),
  NotationPage('state', 'State and formulas', json: ['state']),
  NotationPage('events', 'Events and actions'),
  NotationPage('interaction', 'Interaction', json: ['interaction']),
  NotationPage('animation', 'Motion', json: ['animation']),
  NotationPage('charts', 'Charts and indicators', json: ['charts']),
  NotationPage('responsive', 'Responsive'),
  NotationPage('navigation', 'Navigation and overlays', json: ['navigation']),
  NotationPage('components', 'Components', json: ['components']),
  NotationPage('design-systems', 'Design systems', json: ['design-systems']),
  NotationPage('document', 'The document', json: ['base', 'publish', 'render']),
  NotationPage('values', 'Values', json: ['values']),
  NotationPage('data', 'Data (feature layer)', json: ['data'], layer: true),
  NotationPage('auth', 'Accounts (feature layer)', json: ['auth'], layer: true),
  NotationPage('commerce', 'Commerce (feature layer)', json: ['commerce'], layer: true),
  NotationPage('media', 'Media (feature layer)', json: ['media'], layer: true),
  NotationPage('engage', 'Engagement (feature layer)', json: ['engage'], layer: true),
];

/// Behaviors (and their models) on another page than the JSON reference's.
const Map<String, String> _movedBehaviors = {'customPaint': 'paint'};

/// Examples no JSON page shows (the tests' own), and the page each goes on.
const Map<String, String> _unplacedExamples = {
  'image': 'decoration',
  'sections/site': 'components',
  'sections/pages/home': 'components',
  'sections/components/Chip': 'components',
  'theme/home': 'theme',
};

/// The verbs of an event's actions, each by a sample of it: the action
/// type each gives is read from a parse of the sample, so a verb is listed
/// beside the action it is.
const List<String> notationVerbSamples = [
  'count=count+1', 'emit save', 'toast "Saved"', 'open signup', 'close', 'go home', 'scroll pricing', //
  'link https://example.com', 'announce "3 results"', 'confirm "Remove it?" then {close}', 'focus email', 'blur',
  'copy "{link}"', 'ok ? close : toast "Fill it in"',
];

// --- reading and printing a block ------------------------------------------------

/// The options a ```notation block is read with: [width] its canvas, no
/// reflow (a printed document's media rules are its own).
NotationOptions notationBlockOptions({double width = 390}) => NotationOptions(width: width, reflow: false);

/// [text] without the ids written after a line's first word (`Text#title`
/// is `Text`): two prints of one document may name a node differently.
String withoutIds(String text) =>
    text.split('\n').map((l) => l.replaceFirstMapped(RegExp(r'^(\s*[A-Za-z][A-Za-z0-9.]*)#[A-Za-z_][A-Za-z0-9_-]*'), (m) => m[1]!)).join('\n');

/// What is wrong with the notation [block]: an issue of the parse (in the
/// closed vocabulary), or, unless [define], a print that is not [block]
/// (ids aside). Null: it reads, and prints back as written.
String? notationBlockProblem(String block, {double width = 390, bool define = false, api.Catalog? catalog}) {
  final cat = catalog ?? notationCatalog;
  final r = parseNotation(block, catalog: cat, options: notationBlockOptions(width: width));
  if (r.issues.isNotEmpty) return r.issues.map((i) => 'line ${i.line}: ${i.message}').join('; ');
  if (define) return null;
  final printed = printNotation(r.document, catalog: cat);
  if (withoutIds(printed) == withoutIds(block)) return null;
  return 'prints back as:\n$printed';
}

/// A fenced ```notation block of a page: its text, its info (`width=1280`,
/// `define`, `components`, `unchecked`: a print that does not read without
/// an issue, a printer bug listed in `_tails.md`) and the line it starts on.
typedef NotationBlock = ({String text, double width, bool define, bool components, bool unchecked, int line});

/// Every ```notation block of [page].
List<NotationBlock> notationBlocks(String page) {
  final out = <NotationBlock>[];
  for (final m in RegExp(r'^```notation([^\n]*)\n(.*?)\n```$', multiLine: true, dotAll: true).allMatches(page)) {
    final info = m[1]!;
    final width = double.tryParse(RegExp(r'width=(\d+)').firstMatch(info)?[1] ?? '') ?? 390;
    out.add((
      text: m[2]!,
      width: width,
      define: info.contains('define'),
      components: info.contains('components'),
      unchecked: info.contains('unchecked'),
      line: '\n'.allMatches(page.substring(0, m.start)).length + 1,
    ));
  }
  return out;
}

/// A file's text with `\r\n` read as `\n`: the generator runs on a Windows
/// checkout as on any other.
String readLf(String path) => File(path).readAsStringSync().replaceAll('\r\n', '\n');

// --- examples --------------------------------------------------------------------

/// One example of the JSON reference, in the notation.
final class NotationExample {
  NotationExample(this.title, this.source, this.page, this.text, this.width, {this.note = '', this.components = false, this.issues = const []});

  /// What the parser says reading the print: a printer bug. Its block is
  /// marked `unchecked` and listed in `_tails.md`.
  final List<String> issues;

  /// Whether it calls a component the examples declare (read with
  /// [notationComponentsCatalog]).
  final bool components;

  /// What it is (`sizing.json`, `layout.md, line 188`).
  final String title, source;

  /// The notation page it is on.
  final String page;

  /// The print, and the width of its canvas.
  final String text;
  final double width;

  /// How it was made a document (a fragment wrapped), when it was.
  final String note;

  /// Its lines that keep part of the document as JSON: line (1-based),
  /// the line's start, the paths of its tail.
  final List<({int line, String head, List<String> paths})> tails = [];
}

/// A JSON block that is not a layout document (a site's manifest, an op
/// batch): shown as JSON in both references.
typedef KeptJson = ({String title, String source, String page, String json, String why});

// --- the reference ---------------------------------------------------------------

/// The files of the notation reference, by path from the package root.
Map<String, String> buildNotationReference(String root) => _NotationReference(root).build();

final class _NotationReference {
  _NotationReference(this.root);

  final String root;
  late final Catalog _catalog = Catalog(root);
  late final Json catalog = _catalog.json;
  late final Assignment assignment = assign(catalog);
  final api.Catalog c = notationCatalog;

  /// Every anchor of the folder, by the file that defines it.
  final Map<String, String> anchors = {};

  /// Items by kind and name → notation page id.
  late final Map<ItemKind, Map<String, String>> placed = _place();

  String get _templates => '$root/tool/reference/templates/notation';

  Map<String, String> build() {
    final examples = _examples();
    final pages = <String, String>{};
    for (final p in notationPages) {
      pages[p.file] = _page(p, examples.where((e) => e.page == p.id).toList(), _kept.where((k) => k.page == p.id).toList());
    }
    pages['levels.md'] = _levelsPage();
    final core = _core(pages);
    pages['NOTATION.md'] = core;
    for (final e in pages.entries) {
      _collect(e.key, e.value);
    }
    final resolved = {for (final e in pages.entries) e.key: _resolve(e.value, e.key)};
    resolved['_tails.md'] = _tailsReport(examples);
    resolved['index.md'] = _index(resolved);
    final out = <String, String>{for (final e in resolved.entries) '$notationDir/${e.key}': '${e.value.trimRight()}\n'};
    out['$notationDir/index.json'] = '${const JsonEncoder.withIndent('  ').convert(_indexJson(resolved))}\n';
    return out;
  }

  // --- where each item is -------------------------------------------------------

  Map<ItemKind, Map<String, String>> _place() {
    final ids = {for (final p in notationPages) for (final j in p.json) j: p.id};
    final out = <ItemKind, Map<String, String>>{};
    for (final kind in ItemKind.values) {
      out[kind] = {
        for (final e in assignment[kind]!.entries)
          e.key: switch (kind) {
            ItemKind.trigger || ItemKind.action => 'events',
            ItemKind.function => 'state',
            ItemKind.behavior => _movedBehaviors[e.key] ?? ids[e.value] ?? 'values',
            _ => ids[e.value] ?? 'values',
          },
      };
    }
    // A moved behavior's model goes with it.
    for (final f in (catalog['behaviors']['fields'] as List).cast<Json>()) {
      final to = _movedBehaviors[f['key']];
      final m = (f['object'] ?? f['item_object']) as String?;
      if (to != null && m != null) out[ItemKind.model]![m] = to;
    }
    return out;
  }

  String _link(ItemKind kind, String name, [String? text]) => '[${text ?? '`$name`'}](@${kind.anchor(name)})';

  // --- templates -------------------------------------------------------------------

  /// Template [name] with [fills] applied and its ```notation blocks checked.
  String _template(String name, Map<String, String Function()> fills) {
    final path = '$_templates/$name';
    var text = readLf(path).replaceAll(r'\{{', '\u0000');
    for (final b in notationBlocks(text)) {
      final problem = notationBlockProblem(b.text, width: b.width, define: b.define, catalog: b.components ? notationComponentsCatalog(root) : null);
      if (problem != null) {
        throw StateError('tool/reference/templates/notation/$name:${b.line}: this notation block does not read back as written: $problem');
      }
    }
    // A define block is followed by what it expands to.
    text = text.replaceAllMapped(RegExp(r'^```notation([^\n]*\bdefine\b[^\n]*)\n(.*?)\n```$', multiLine: true, dotAll: true), (m) {
      final width = double.tryParse(RegExp(r'width=(\d+)').firstMatch(m[1]!)?[1] ?? '') ?? 390;
      final doc = parseNotation(m[2]!, catalog: c, options: notationBlockOptions(width: width)).document;
      return '${m[0]}\n\nIt expands to:\n\n${_fence(printNotation(doc, catalog: c), width)}';
    });
    text = text.replaceAllMapped(RegExp(r'\{\{(\w+)\}\}'), (m) {
      final f = fills[m[1]];
      if (f == null) throw StateError('tool/reference/templates/notation/$name: no fill for {{${m[1]}}}');
      return f();
    });
    return text.replaceAll('\u0000', '{{').trimRight();
  }

  static String _fence(String text, double width, {bool components = false, bool unchecked = false}) =>
      '```notation${width == 390 ? '' : ' width=${_num(width)}'}${components ? ' components' : ''}${unchecked ? ' unchecked' : ''}\n$text\n```';

  static String _num(Object? n) => n is double && n == n.roundToDouble() ? '${n.toInt()}' : '$n';

  String _note() => '<!-- Generated by tool/reference/generate.dart --notation from the declarations of codelessly_api '
      '${catalog['version']} and tool/reference/templates/notation. Do not edit. -->';

  // --- anchors and links -----------------------------------------------------------

  void _collect(String file, String text) {
    for (final m in RegExp(r'<a id="([^"]+)"></a>').allMatches(text)) {
      final had = anchors[m[1]!];
      if (had != null && had != file) throw StateError('notation reference: anchor ${m[1]} in $had and $file');
      anchors[m[1]!] = file;
    }
  }

  String _resolve(String text, String self) {
    final unknown = <String>{};
    final out = text.replaceAllMapped(RegExp(r'\]\(@([\w.-]+)\)'), (m) {
      final file = anchors[m[1]!];
      if (file == null) {
        unknown.add(m[1]!);
        return m[0]!;
      }
      return file == self ? '](#${m[1]})' : ']($file#${m[1]})';
    });
    if (unknown.isNotEmpty) throw StateError('notation/$self: links to unknown anchors: ${unknown.join(', ')}');
    return out;
  }

  // --- values as the notation writes them ------------------------------------------

  /// A value as written after `key=`: a number, a bare word, a quoted
  /// string, JSON.
  static String literal(Object? v, {bool word = false}) {
    if (v == null) return 'null';
    if (v is num) return _num(v);
    if (v is bool) return '$v';
    if (v is String) {
      if (word || RegExp(r'^#[0-9A-Fa-f]{6,8}$').hasMatch(v)) return v;
      return jsonEncode(v);
    }
    return jsonEncode(v);
  }

  /// A field's type as a writer writes it, linked to where it is described.
  String _type(Json f) {
    String one(String name, String kind, List? values) => switch (kind) {
          'boolean' => '`true`/`false`',
          'integer' => 'whole number',
          'number' => 'number',
          'string' => 'text',
          'enumeration' => values != null && values.length <= 8 ? values.map((v) => '`$v`').join(' ') : _link(ItemKind.enumeration, name, name),
          'value' => _link(ItemKind.valueType, name, name),
          'object' => _link(ItemKind.model, name, name),
          'json' => 'JSON',
          _ => name,
        };
    if (f['kind'] == 'list') return 'list of ${one('${f['item']}', '${f['itemKind']}', f['item_values'] as List?)}';
    final enumName = f['enum'] as String?;
    return one(enumName ?? '${f['type']}', '${f['kind']}', f['values'] as List?);
  }

  /// A field's default as the notation writes it.
  String _default(Json f) {
    final d = f['default'];
    if (d == null) return '';
    if (d is List && d.isEmpty) return '`[]`';
    if (d is Map && d.isEmpty) return '`{}`';
    if (d is String && d.isEmpty) return '`""`';
    final s = literal(d, word: f['kind'] == 'enumeration');
    return '`${s.length > 40 ? '${s.substring(0, 37)}…' : s}`';
  }

  static String _bounds(Json f) {
    final lo = f['min'], hi = f['max'];
    if (lo == null && hi == null) return '';
    return ' (${lo == null ? '' : '≥ ${_num(lo)}'}${lo != null && hi != null ? ', ' : ''}${hi == null ? '' : '≤ ${_num(hi)}'})';
  }

  /// A table of fields whose keys are [key] of each (dotted, or the
  /// shortest key keys.dart gives).
  String _fieldTable(List<Json> fields, String Function(Json f) key, {String? level, String Function(Json f)? levelOf}) {
    if (fields.isEmpty) return '_No fields._';
    final withLevel = level != null || levelOf != null;
    return Renderer.table(['Key', 'Type', 'Default', if (withLevel) 'Level', 'Description'], [
      for (final f in fields)
        [
          key(f),
          '${_type(f)}${_bounds(f)}',
          _default(f),
          if (withLevel) levelOf?.call(f) ?? level!,
          '${f['doc']}',
        ],
    ]);
  }

  static String _levelName(Level l) => '${l.index}';

  // --- a node type -------------------------------------------------------------------

  late final Map<String, String> _words = _typeWords();

  /// The word the printer writes for each type: a print of the type alone.
  Map<String, String> _typeWords() {
    final out = <String, String>{};
    for (final w in c.widgets) {
      if (w.type == 'canvas') continue;
      final doc = parseNotation('node ${jsonEncode({'type': w.type})}', catalog: c).document;
      final printed = printNotation(doc, catalog: c);
      final line = printed.split('\n').firstWhere((l) => !l.startsWith('state ') && !l.startsWith('canvas'), orElse: () => '');
      final word = RegExp(r'^[A-Za-z][A-Za-z0-9.]*').stringMatch(line.trim());
      if (word == null || word == 'node' || word == 'document') throw StateError('notation: no word prints for type ${w.type}: $printed');
      out[w.type] = word;
    }
    return out;
  }

  /// Where the quoted strings of a [word] line go (the first, the second).
  (String?, String?) _strings(String word) {
    String? find(Object? v, String s, String at) {
      if (v == s) return at;
      if (v is Map) {
        for (final e in v.entries) {
          final r = find(e.value, s, at.isEmpty ? '${e.key}' : '$at.${e.key}');
          if (r != null) return r;
        }
      }
      if (v is List) {
        for (var i = 0; i < v.length; i++) {
          final r = find(v[i], s, '$at[$i]');
          if (r != null) return r;
        }
      }
      return null;
    }

    String? at(String text, String marker) {
      final r = parseNotation(text, catalog: c);
      if (r.issues.isNotEmpty) return null;
      for (final e in (r.document['nodes'] as Map).entries) {
        final n = e.value as Map;
        if (n['type'] == 'canvas') continue;
        final p = find(n, marker, '');
        if (p != null) return n == (r.document['nodes'] as Map).values.firstWhere((v) => (v as Map)['type'] != 'canvas') ? p : 'a node under it (`${n['type']}`, `$p`)';
      }
      return null;
    }

    final first = at('$word "Qqq1"', 'Qqq1');
    final second = first == null ? null : at('$word "Qqq1" "Qqq2"', 'Qqq2');
    final firstKept = first == null ? null : at('$word "Qqq1" "Qqq2"', 'Qqq1');
    return (first, firstKept == null ? null : second);
  }

  /// The words that make [type], beside the one the printer writes.
  List<String> _otherWords(String type) => [
        for (final e in notationTypes.entries)
          if (e.value.type == type && e.key != _words[type]) e.key,
      ];

  /// A key of [type] for [path]: the shortest, and the field's own name
  /// when that reads too.
  String _keyCell(String path, String type) {
    final short = notationKeyFor(path, type, catalog: c);
    final own = path.split('.').last;
    final both = own != short && notationKeyPath(own, type, catalog: c) == path;
    return both ? '`$short` (or `$own`)' : '`$short`';
  }

  String _nodeSection(String type) {
    final t = (catalog['nodeTypes'] as Map)[type] as Json;
    final spec = c.widget(type);
    final word = _words[type] ?? type;
    final level = widgetLevels[type] ?? Level.features;
    final b = StringBuffer()
      ..writeln('<a id="${ItemKind.node.anchor(type)}"></a>')
      ..writeln('### `$word` (`$type`)')
      ..writeln();
    final doc = '${t['doc']}'.split('\n\n').first;
    if (doc.isNotEmpty) b..writeln(doc)..writeln();
    final words = <String>[
      if (type == 'text') ...[for (final v in defaultTextVariants.keys) 'Text.$v'],
      for (final e in buttonVariants.entries)
        if (e.value.type == type && !word.endsWith('.${e.key}')) 'Button.${e.key}',
      ..._otherWords(type),
    ];
    final bareWord = word.split('.').first;
    final (first, second) = spec == null ? (null, null) : _strings(word);
    b.writeln('- Written `$word`${words.isEmpty ? '' : '; also ${words.map((w) => '`$w`').join(', ')}'}. Level ${level.index} (${level.title}).');
    b.writeln(first == null
        ? '- Takes no quoted string.'
        : '- `$bareWord "…"` sets `$first`${second == null ? '' : '; a second string sets `$second`'}.');
    b.writeln('- ${switch (t['children']) {
      'list' => 'The lines under it are its children.',
      'slots' => 'Its children are slots: ${[for (final s in t['slots'] as List) '`$s`'].join(', ')}.',
      _ => 'Takes no lines under it.',
    }}${t['children'] == 'list' && (t['slots'] as List).isNotEmpty ? ' Slots: ${[for (final s in t['slots'] as List) '`$s`'].join(', ')}.' : ''}');
    b.writeln('- Decoration keys (`fill`, `border`, `radius`, `effects`…): ${t['decorated'] == true ? 'yes' : 'only `effects` (blurs)'}.');
    final style = spec == null ? null : notationTextStyleProp(spec);
    if (style != null) {
      b.writeln('- The fields of its text style ([TextStyle](@type-TextStyle)) are keys by their own names: `letterSpacing=0.4`, `fontFamily="Inter"`.');
    }
    b.writeln();
    final props = (t['props'] as List).cast<Json>();
    b
      ..writeln(props.isEmpty
          ? '_No keys of its own._'
          : _fieldTable(props, (f) => _keyCell('props.${f['key']}', type), level: _levelName(level)))
      ..writeln();
    return b.toString();
  }

  // --- behaviors --------------------------------------------------------------------

  String _behaviorSection(String key) {
    final f = (catalog['behaviors']['fields'] as List).cast<Json>().firstWhere((f) => f['key'] == key);
    final level = behaviorLevels[key] ?? Level.full;
    final b = StringBuffer()
      ..writeln('<a id="${ItemKind.behavior.anchor(key)}"></a>')
      ..writeln('### `$key` (behavior)')
      ..writeln();
    if ('${f['doc']}'.isNotEmpty) b..writeln('${f['doc']}'.split('\n\n').first)..writeln();
    final model = (f['object'] ?? f['item_object']) as String?;
    final shortKey = notationKeyFor(key, 'column', catalog: c);
    b.writeln('Written `$shortKey=${f['kind'] == 'list' ? '[…]' : f['kind'] == 'object' ? '{…}' : '…'}` on any line '
        '(${_type(f)}${_default(f).isEmpty ? '' : ', default ${_default(f)}'}). Level ${level.index}.');
    if (model != null && f['kind'] == 'object') {
      final m = (catalog['objectTypes'] as Map)[model] as Json?;
      final fields = ((m?['fields'] as List?) ?? const []).cast<Json>();
      if (fields.isNotEmpty && _shownModels.add(model)) {
        b
          ..writeln(' Each field of its record ($model) is a key of its own, dotted: `$key.${fields.first['key']}=…`.')
          ..writeln()
          ..writeln('<a id="${ItemKind.model.anchor(model)}"></a>')
          ..writeln(_fieldTable(fields, (x) => '`$key.${x['key']}`'));
      }
    } else if (model != null) {
      b.writeln(' Each element is a [$model](@type-$model) record, as JSON.');
    }
    b.writeln();
    return b.toString();
  }

  final Set<String> _shownModels = {};

  String _modelSection(String name) {
    final m = (catalog['objectTypes'] as Map)[name] as Json?;
    if (m == null) return '';
    final b = StringBuffer()
      ..writeln('<a id="${ItemKind.model.anchor(name)}"></a>')
      ..writeln('### $name')
      ..writeln();
    if ('${m['doc']}'.isNotEmpty) b..writeln('${m['doc']}'.split('\n\n').first)..writeln();
    b
      ..writeln('A record: written whole as JSON (`key={…}`), or field by field as dotted keys under the key that holds it (`key.field=…`).')
      ..writeln()
      ..writeln(_fieldTable((m['fields'] as List).cast<Json>(), (f) => '`${f['key']}`'))
      ..writeln();
    return b.toString();
  }

  // --- a page ----------------------------------------------------------------------

  List<String> _items(ItemKind kind, String page) => [for (final e in placed[kind]!.entries) if (e.value == page) e.key];

  /// The Reference of [p]: its node types, behaviors, the events and
  /// actions of its JSON page (as links) and its models.
  String _reference(NotationPage p) {
    final b = StringBuffer();
    // Node types in the JSON page's order.
    final nodes = [
      for (final def in featurePages)
        if (p.json.contains(def.id)) ...[...def.nodes, if (def.library case final lib?) for (final w in lib.widgets) w.type],
    ].where((n) => placed[ItemKind.node]![n] == p.id).toList();
    if (nodes.isNotEmpty) {
      b
        ..writeln('<a id="${p.id}-words"></a>')
        ..writeln('## Words')
        ..writeln();
      for (final n in nodes) {
        b.write(_nodeSection(n));
      }
    }
    final behaviors = _items(ItemKind.behavior, p.id);
    if (behaviors.isNotEmpty) {
      b
        ..writeln('<a id="${p.id}-behaviors"></a>')
        ..writeln('## Keys any line takes here')
        ..writeln();
      for (final k in behaviors) {
        b.write(_behaviorSection(k));
      }
    }
    final triggers = [
      for (final def in featurePages)
        if (p.json.contains(def.id)) ...def.triggers,
    ];
    final actions = [
      for (final def in featurePages)
        if (p.json.contains(def.id)) ...[...def.actions, if (def.library case final lib?) for (final a in lib.actions) a.type],
    ];
    if (triggers.isNotEmpty || actions.isNotEmpty) {
      b
        ..writeln('<a id="${p.id}-events-and-actions"></a>')
        ..writeln('## Events and actions')
        ..writeln()
        ..writeln('Each is on [events.md](events.md), with its fields.')
        ..writeln();
      if (triggers.isNotEmpty) b.writeln('- Events: ${triggers.map((t) => _link(ItemKind.trigger, t, '`${notationEventName(t)}`')).join(', ')}.');
      if (actions.isNotEmpty) b.writeln('- Actions: ${actions.map((a) => _link(ItemKind.action, a)).join(', ')}.');
      b.writeln();
    }
    final models = [
      for (final m in _items(ItemKind.model, p.id))
        if (!_shownModels.contains(m)) m,
    ];
    if (models.isNotEmpty) {
      b
        ..writeln('<a id="${p.id}-records"></a>')
        ..writeln('## Records')
        ..writeln();
      for (final m in models) {
        b.write(_modelSection(m));
      }
    }
    return b.toString().trimRight();
  }

  String _page(NotationPage p, List<NotationExample> examples, List<KeptJson> kept) {
    final fills = <String, String Function()>{
      'reference': () => _reference(p),
      'examples': () => _examplesSection(p, examples, kept),
      ..._pageFills,
    };
    final text = _template('${p.id}.md', fills);
    if (examples.isNotEmpty && !text.contains('<a id="${p.id}-examples"></a>')) {
      throw StateError('notation/${p.id}.md has examples but its template has no {{examples}}');
    }
    for (final kind in [ItemKind.node, ItemKind.behavior]) {
      for (final n in _items(kind, p.id)) {
        if (!text.contains('<a id="${kind.anchor(n)}"></a>')) throw StateError('notation/${p.id}.md: ${kind.name} $n is not on the page (no {{reference}}?)');
      }
    }
    return '${_note()}\n${Renderer.anchorHeadings(text, p.id)}\n';
  }

  String _examplesSection(NotationPage p, List<NotationExample> examples, List<KeptJson> kept) {
    if (examples.isEmpty && kept.isEmpty) return '';
    final b = StringBuffer()
      ..writeln('<a id="${p.id}-examples"></a>')
      ..writeln('## Examples')
      ..writeln()
      ..writeln('The JSON reference\'s examples for this page, printed in the notation. '
          'A `{…}` at the end of a line is what the notation has no words for yet ([_tails.md](_tails.md)).')
      ..writeln();
    for (final e in examples) {
      b
        ..writeln('<a id="${p.id}-example-${Renderer.slug(e.title)}"></a>')
        ..writeln('### ${e.title}')
        ..writeln()
        ..writeln('From ${e.source}${e.note.isEmpty ? '' : '; ${e.note}'}.')
        ..writeln()
        ..writeln(_fence(e.text, e.width, components: e.components, unchecked: e.issues.isNotEmpty))
        ..writeln();
    }
    for (final k in kept) {
      b
        ..writeln('<a id="${p.id}-example-${Renderer.slug(k.title)}"></a>')
        ..writeln('### ${k.title}')
        ..writeln()
        ..writeln('From ${k.source}. ${k.why} It is written as JSON:')
        ..writeln()
        ..writeln('```json\n${k.json}\n```')
        ..writeln();
    }
    return b.toString().trimRight();
  }

  // --- examples --------------------------------------------------------------------

  final List<KeptJson> _kept = [];

  /// Examples whose print printed again is another text: printer bugs.
  final List<({String title, String first, String then})> _unsettled = [];

  List<NotationExample> _examples() {
    final out = <NotationExample>[];
    final pageOf = {for (final p in notationPages) for (final j in p.json) j: p.id};
    final seen = <String>{};
    void file(String name, String page, String jsonPage) {
      if (!seen.add(name)) return;
      final raw = jsonDecode(readLf('$root/tool/reference/examples/$name.json'));
      final source = '[`$name.json`](../${jsonPage == 'base' ? 'STARTER' : jsonPage}.md)';
      if (raw is! Map<String, dynamic> || raw['nodes'] is! Map) {
        _kept.add((title: '$name.json', source: source, page: page, json: const JsonEncoder.withIndent('  ').convert(raw), why: _whyNotDocument(raw)));
        return;
      }
      out.add(_example('$name.json', source, page, raw));
    }

    final templates = {
      'base': 'base.md',
      for (final p in featurePages) p.id: 'pages/${p.id}.md',
      'values': 'pages/values.md',
    };
    for (final e in templates.entries) {
      final page = pageOf[e.key];
      if (page == null) continue;
      final text = readLf('$root/tool/reference/templates/${e.value}');
      for (final m in RegExp(r'\{\{example(?:-as-written)?:([\w/-]+)\}\}').allMatches(text)) {
        file(m[1]!, page, e.key);
      }
      final jsonFile = e.key == 'base' ? 'STARTER.md' : '${e.key}.md';
      for (final m in RegExp(r'^```json\n(.*?)\n```$', multiLine: true, dotAll: true).allMatches(text)) {
        final line = '\n'.allMatches(text.substring(0, m.start)).length + 1;
        final title = '$jsonFile, line $line';
        final source = '[$jsonFile](../$jsonFile) (its template, line $line)';
        Object? value;
        try {
          value = jsonDecode(m[1]!);
        } on FormatException {
          value = jsonDecode('{${m[1]}}');
        }
        final wrapped = _wrap(value);
        if (wrapped == null) {
          _kept.add((title: title, source: source, page: page, json: m[1]!, why: _whyNotDocument(value)));
          continue;
        }
        out.add(_example(title, source, page, wrapped.doc, note: wrapped.note));
      }
    }
    for (final e in _unplacedExamples.entries) {
      file(e.key, e.value, 'tests');
    }
    // Every example file is on a page.
    final all = Directory('$root/tool/reference/examples').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.json'));
    for (final f in all) {
      final name = f.path.replaceAll(r'\', '/').split('tool/reference/examples/').last.replaceAll(RegExp(r'\.json$'), '');
      if (!seen.contains(name)) throw StateError('notation reference: example $name.json is on no page (add it to _unplacedExamples)');
    }
    return out;
  }

  static String _whyNotDocument(Object? v) {
    if (v is Map && v.containsKey('ops')) return 'It is a batch of `ui_apply` ops, not a document.';
    if (v is Map && v.containsKey('pages')) return 'It is a site\'s manifest (`site.json`), not a page.';
    if (v is Map && (v.containsKey('components') || v.containsKey('theme'))) return 'It is a design system\'s manifest, not a page.';
    return 'It is a map of values, not a document.';
  }

  NotationExample _example(String title, String source, String page, Json doc, {String note = ''}) {
    final components = (doc['nodes'] as Map).values.any((n) => n is Map && c.widget('${n['type']}') == null);
    final cat = components ? notationComponentsCatalog(root) : c;
    final canvas = (doc['nodes'] as Map)[(doc['roots'] as List?)?.firstOrNull];
    final width = canvas is Map && canvas['type'] == 'canvas' ? notationOptionsFor(doc).width : 390.0;
    // The print, read back as a block is and printed again until it is
    // what it prints as (a print that is not is listed in _tails.md).
    var text = printNotation(doc, catalog: cat);
    var settled = false;
    for (var i = 0; i < 4 && !settled; i++) {
      final again = printNotation(parseNotation(text, catalog: cat, options: notationBlockOptions(width: width)).document, catalog: cat);
      settled = withoutIds(again) == withoutIds(text);
      if (!settled) {
        _unsettled.add((title: title, first: text, then: again));
        text = again;
      }
    }
    final issues = parseNotation(text, catalog: cat, options: notationBlockOptions(width: width)).issues;
    final e = NotationExample(title, source, page, text, width, note: note, components: components,
        issues: [for (final i in issues) 'line ${i.line}: ${i.message}']);
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i].trimLeft();
      final head = l.length > 40 ? '${l.substring(0, 40)}…' : l;
      Object? tail;
      if (l.startsWith('document {')) {
        tail = jsonDecode(l.substring('document '.length));
      } else if (l.startsWith('node {')) {
        tail = jsonDecode(l.substring('node '.length));
      } else {
        final at = _tailStart(l);
        if (at >= 0) tail = jsonDecode(l.substring(at));
      }
      if (tail == null) continue;
      final paths = <String>{};
      _flatten(tail, '', paths);
      e.tails.add((line: i + 1, head: head.split(' {"').first, paths: paths.toList()..sort()));
    }
    return e;
  }

  /// A fragment of a JSON page made a document: a node map, a node's keys
  /// on a node, an action on a button, document keys around a column.
  ({Json doc, String note})? _wrap(Object? v) {
    if (v is! Map) return null;
    final m = v.cast<String, dynamic>();
    if (m['nodes'] is Map && m['roots'] is List) return (doc: m, note: '');
    if (m.containsKey('ops') || m.containsKey('pages') || m.containsKey('designSystem')) return null;
    if (m['type'] is String && c.action('${m['type']}') != null && c.widget('${m['type']}') == null) {
      return (doc: _document({'run': _node('filledButton', {'props': {'label': 'Run'}, 'actions': [
        {'trigger': {'type': 'click'}, 'actions': [m]},
      ]})}, 'run'), note: 'the action on a button\'s tap');
    }
    if (m.isNotEmpty && m.values.every((x) => x is Map && x['type'] is String && c.widget('${x['type']}') != null)) {
      final nodes = {for (final e in m.entries) e.key: _node('${(e.value as Map)['type']}', (e.value as Map).cast<String, dynamic>())};
      final referenced = <String>{};
      var dropped = false;
      for (final n in nodes.values) {
        final kids = (n['children'] as List?)?.cast<String>();
        if (kids != null) {
          final kept = [for (final k in kids) if (nodes.containsKey(k)) k];
          if (kept.length != kids.length) dropped = true;
          n['children'] = kept;
          referenced.addAll(kept);
        }
        final slots = (n['slots'] as Map?)?.cast<String, dynamic>();
        if (slots != null) {
          slots.removeWhere((_, id) {
            final missing = !nodes.containsKey(id);
            dropped = dropped || missing;
            return missing;
          });
          referenced.addAll(slots.values.cast<String>());
        }
      }
      final roots = [for (final id in nodes.keys) if (!referenced.contains(id)) id];
      String root;
      if (roots.length == 1) {
        root = roots.single;
      } else {
        root = 'example';
        nodes[root] = _node('column', {'children': roots});
      }
      return (
        doc: _document(nodes, root),
        note: [if (roots.length > 1) 'its nodes in a column', if (dropped) 'children the fragment does not show left out'].join(', '),
      );
    }
    const documentKeys = {'variables', 'conditions', 'scripts', 'breakpoints'};
    if (m.keys.any(documentKeys.contains)) {
      final doc = _document({'body': _node('column', {})}, 'body');
      final screen = (doc['roots'] as List).first as String;
      for (final k in m.keys.where(documentKeys.contains)) {
        final value = m[k];
        doc[k] = k == 'variables' && value is Map && value.length == 1 ? {screen: value.values.single} : value;
      }
      final rest = {for (final e in m.entries) if (!documentKeys.contains(e.key)) e.key: e.value};
      if (rest.isNotEmpty) (doc['nodes'] as Map)[screen] = <String, dynamic>{...((doc['nodes'] as Map)[screen] as Map).cast<String, dynamic>(), ...rest};
      return (doc: doc, note: rest.isEmpty ? 'its document keys around an empty column' : 'its document keys, and its other keys on the screen');
    }
    // A node's keys: on whichever node prints them in the fewest characters
    // of JSON. Anything else (a manifest, a map of values) is no document.
    final nodeKeys = {
      for (final k in catalog['node']['structural'] as List) '${k['key']}',
      for (final k in catalog['node']['fields'] as List) '${k['key']}',
      for (final k in catalog['behaviors']['fields'] as List) '${k['key']}',
      for (final k in catalog['layout']['fields'] as List) '${k['key']}',
      for (final k in catalog['decoration']['fields'] as List) '${k['key']}',
    };
    if (!m.keys.every(nodeKeys.contains)) return null;
    ({Json doc, String note})? best;
    var bestTail = 1 << 30;
    for (final type in const ['box', 'text', 'filledButton', 'column', 'textField']) {
      final fields = <String, dynamic>{};
      for (final e in m.entries) {
        if (api.DecorationFields.all.any((f) => f.key == e.key)) {
          (fields['decoration'] ??= <String, dynamic>{})[e.key] = e.value;
        } else if (api.LayoutFields.all.any((f) => f.key == e.key)) {
          (fields['layout'] ??= <String, dynamic>{})[e.key] = e.value;
        } else {
          fields[e.key] = e.value;
        }
      }
      final doc = _document({'example': _node(type, fields)}, 'example');
      final printed = printNotation(doc, catalog: c);
      final tail = printed.split('\n').fold<int>(0, (s, l) => s + (_tailStart(l.trimLeft()) >= 0 ? l.length : 0)) +
          (printed.contains('document {') ? 10000 : 0);
      if (tail < bestTail) {
        bestTail = tail;
        best = (doc: doc, note: 'its keys on a `${_words[type]}`');
      }
    }
    return best;
  }

  /// A node of [type] as a line of its word gives it, with [fields] over it.
  Json _node(String type, Json fields) {
    final word = _words[type] ?? type;
    final parsed = parseNotation(word.contains('.') || word[0] == word[0].toUpperCase() ? word : 'node {"type":"$type"}', catalog: c);
    final nodes = (parsed.document['nodes'] as Map).values.where((n) => (n as Map)['type'] == type).toList();
    final base = nodes.isEmpty ? <String, dynamic>{'type': type} : jsonDecode(jsonEncode(nodes.first)) as Json;
    base.remove('children');
    return _merge(base, jsonDecode(jsonEncode(fields)) as Json);
  }

  static Json _merge(Json a, Json b) {
    final out = {...a};
    for (final e in b.entries) {
      final av = out[e.key];
      out[e.key] = av is Map && e.value is Map ? _merge(av.cast<String, dynamic>(), (e.value as Map).cast<String, dynamic>()) : e.value;
    }
    return out;
  }

  /// A document whose screen shows [root] of [nodes].
  Json _document(Map<String, Json> nodes, String root) {
    final empty = parseNotation('Column', catalog: c).document;
    final screen = (empty['roots'] as List).first as String;
    final canvas = jsonDecode(jsonEncode((empty['nodes'] as Map)[screen])) as Json;
    (canvas['slots'] as Map)['body'] = root;
    return {
      'schema': empty['schema'],
      'roots': [screen],
      'nodes': {screen: canvas, ...nodes},
    };
  }

  /// Where a line's `{…}` tail starts: the last top-level ` {"` whose braces
  /// close at the end of the line; -1 for none.
  static int _tailStart(String line) {
    if (!line.endsWith('}')) return -1;
    var at = line.indexOf(' {"');
    while (at >= 0) {
      try {
        if (jsonDecode(line.substring(at + 1)) is Map) return at + 1;
      } on FormatException {
        // Not this one.
      }
      at = line.indexOf(' {"', at + 1);
    }
    return -1;
  }

  static String _clip(String s) => s.length > 120 ? '${s.substring(0, 117)}…' : s;

  static void _flatten(Object? v, String at, Set<String> out) {
    if (v is Map && v.isNotEmpty) {
      for (final e in v.entries) {
        _flatten(e.value, at.isEmpty ? '${e.key}' : '$at.${e.key}', out);
      }
    } else if (v is List && v.isNotEmpty && v.any((x) => x is Map)) {
      for (final x in v) {
        _flatten(x, '$at[]', out);
      }
    } else if (at.isNotEmpty) {
      out.add(at.replaceFirstMapped(RegExp(r'^(nodes|variables)\.[^.\[]+'), (m) => '${m[1]}.*'));
    }
  }

  String _tailsReport(List<NotationExample> examples) {
    final tailed = examples.where((e) => e.tails.isNotEmpty).toList();
    final counts = <String, int>{};
    for (final e in tailed) {
      for (final t in e.tails) {
        for (final p in t.paths) {
          counts[p] = (counts[p] ?? 0) + 1;
        }
      }
    }
    final b = StringBuffer()
      ..writeln(_note())
      ..writeln('# What the notation prints as JSON')
      ..writeln()
      ..writeln('The work list for notation parity (docs/design/22-notation-parity.md). Each example of the JSON reference is '
          'printed with `printNotation`; a line that keeps part of its node in a `{…}` tail, a `node {…}` line and a '
          '`document {…}` line are listed here, with the paths the JSON holds. The reference is complete when this list '
          'is empty.')
      ..writeln()
      ..writeln('${examples.length} examples; ${tailed.length} with a tail; ${tailed.fold<int>(0, (s, e) => s + e.tails.length)} lines with one; '
          '${counts.length} distinct paths; ${examples.where((e) => e.issues.isNotEmpty).length} prints that do not read without an issue; '
          '${_unsettled.length} that print again differently.')
      ..writeln();
    if (counts.isNotEmpty) {
      final top = counts.entries.toList()..sort((a, b) => b.value != a.value ? b.value - a.value : a.key.compareTo(b.key));
      b
        ..writeln('## Paths, most lines first')
        ..writeln()
        ..writeln(Renderer.table(['Path', 'Lines'], [for (final e in top) ['`${e.key}`', '${e.value}']]))
        ..writeln();
    }
    if (tailed.isNotEmpty) {
      b
        ..writeln('## By example')
        ..writeln();
      for (final e in tailed) {
        b
          ..writeln('### ${e.title} ([${e.page}.md](${e.page}.md#${e.page}-example-${Renderer.slug(e.title)}))')
          ..writeln()
          ..writeln(Renderer.table(['Line', 'Starts', 'Paths'], [
            for (final t in e.tails) ['${t.line}', '`${t.head}`', t.paths.map((p) => '`$p`').join(', ')],
          ]))
          ..writeln();
      }
    }
    final unread = examples.where((e) => e.issues.isNotEmpty).toList();
    if (unread.isNotEmpty) {
      b
        ..writeln('## Prints that do not read without an issue')
        ..writeln()
        ..writeln('Printer bugs: the print gives the document back, but the parser says something reading it. Each block is '
            'marked `unchecked` on its page.')
        ..writeln();
      for (final e in unread) {
        b.writeln('- **${e.title}** ([${e.page}.md](${e.page}.md#${e.page}-example-${Renderer.slug(e.title)})): ${e.issues.map((i) => '`$i`').join('; ')}');
      }
      b.writeln();
    }
    if (_unsettled.isNotEmpty) {
      b
        ..writeln('## Prints that print again differently')
        ..writeln()
        ..writeln('Each example is shown as its print printed again (the same document): the printer should give that the first time.')
        ..writeln();
      for (final u in _unsettled) {
        final a = u.first.split('\n'), z = u.then.split('\n');
        b.writeln('- **${u.title}**');
        for (var i = 0; i < a.length || i < z.length; i++) {
          final x = i < a.length ? a[i].trim() : '', y = i < z.length ? z[i].trim() : '';
          if (withoutIds(x) != withoutIds(y)) b.writeln('  - line ${i + 1}: `${_clip(x)}` then `${_clip(y)}`');
        }
      }
      b.writeln();
    }
    if (_kept.isNotEmpty) {
      b
        ..writeln('## Kept as JSON (not a layout document)')
        ..writeln()
        ..writeln('These blocks are JSON in both references; they are not part of the work list.')
        ..writeln()
        ..writeln(Renderer.table(['Block', 'Page', 'Why'], [for (final k in _kept) [k.title, '${k.page}.md', k.why]]))
        ..writeln();
    }
    return b.toString();
  }

  // --- the fills every template may use ----------------------------------------------

  late final Map<String, String Function()> _pageFills = {
    'layoutKeys': () => _fieldTable((catalog['layout']['fields'] as List).cast<Json>(), (f) => _keyCell('layout.${f['key']}', 'column'), level: '0'),
    'constraintKeys': () => const ['minWidth', 'maxWidth', 'minHeight', 'maxHeight'].map((k) => '`$k`').join(', '),
    'decorationKeys': () => _fieldTable((catalog['decoration']['fields'] as List).cast<Json>(), (f) => _keyCell('decoration.${f['key']}', 'box'), level: '0'),
    'nodeKeys': () => _fieldTable((catalog['node']['fields'] as List).cast<Json>(), (f) => _keyCell('${f['key']}', 'box'), level: '0'),
    'universal': _universal,
    'textVariants': () => Renderer.table(['Word', 'Size', 'Weight', 'Color'], [
          for (final e in defaultTextVariants.entries)
            ['`Text.${e.key}`', '${(e.value as Map)['fontSize'] ?? ''}', '${(e.value as Map)['fontWeight'] ?? ''}', '`${(e.value as Map)['color'] ?? ''}`'],
        ]),
    'buttonVariants': () => [for (final e in buttonVariants.entries) '`Button.${e.key}` (`${e.value.type}`${e.value.props.isEmpty ? '' : ', ${jsonEncode(e.value.props)}'})'].join(', '),
    'badgeVariants': () => [for (final k in badgeVariants.keys) '`Badge.$k`'].join(', '),
    'typeWords': _typeWordsByLevel,
    'pageWords': () => (PageWords.words.toList()..sort()).map((w) => '`$w`').join(', '),
    'verbs': _verbs,
    'coreEvents': _coreEvents,
    'triggers': _triggers,
    'triggerFields': () => _fieldTable([
          for (final f in (catalog['triggers']['fields'] as List).cast<Json>())
            if (f['key'] != 'type') f,
        ], (f) => '`${f['key']}`'),
    'actions': _actions,
    'actionCommonFields': () => _fieldTable((catalog['actions']['common'] as List).cast<Json>(), (f) => '`${f['key']}`'),
    'chainKeys': () => [for (final k in catalog['actions']['nestedChainKeys'] as List) '`$k`'].join(', '),
    'functionNames': _functionNames,
    'functions': _functions,
    'variableTypes': () => [for (final v in (catalog['enums'] as Map)['VariableType'] as List) '`${v['value']}`'].join(', '),
    'mediaSizes': _mediaSizes,
    'breakpoints': () => Renderer.table(['Breakpoint', 'From', 'Design size', 'Condition word'], [
          for (final b in (catalog['breakpoints']['defaults'] as List).cast<Json>())
            ['`${b['id']}`', '${b['minWidth'] ?? 0}', '${b['width']} × ${b['height']}', b['minWidth'] == null ? '' : '`min${_capital('${b['id']}')}`'],
        ]),
    'states': _states,
    'animateWords': () => Renderer.table(['`animate=`', 'Preset', 'Params'], [
          for (final e in notationAnimations.entries)
            ['`${e.key}`', '`${e.value['preset']}`', e.value.keys.any((k) => k != 'preset') ? '`${jsonEncode({for (final x in e.value.entries) if (x.key != 'preset') x.key: x.value})}`' : ''],
        ]),
    'animationFields': () => _fieldTable(_catalog.fieldsOf(NodeAnimationFields.all, area: 'animation', prefer: const ['NodeAnimation']), (f) => '`${f['key']}`'),
    'trackFields': () => _fieldTable(_catalog.fieldsOf(AnimationTrackFields.all, area: 'track', prefer: const ['AnimationTrack']), (f) => '`${f['key']}`'),
    'transitionFields': () => _fieldTable(_catalog.fieldsOf(TransitionFields.all, area: 'transition', prefer: const ['Transition']), (f) => '`${f['key']}`'),
    'customPaintFields': () => _fieldTable([
          for (final f in _catalog.fieldsOf(CustomPaintFields.all, area: 'customPaint', prefer: const ['CustomPaint']))
            if (f['key'] != 'painter' && f['key'] != 'foregroundPainter') f,
        ], (f) => '`${f['key']}`'),
    'drawOps': _drawOps,
    'drawOpCommonFields': () => _fieldTable(_catalog.fieldsOf(DrawOpCommonFields.all, area: 'draw op', prefer: const ['DrawOp']), (f) => '`${f['key']}`'),
    'valueTypes': _valueTypes,
    'enums': _enums,
    'trust': _trust,
  };

  static String _capital(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _universal() => Renderer.table(['Word', 'Written', 'Means'], [
        for (final e in notationUniversal.entries)
          if (e.value.of == null)
            [
              '`${e.key}`',
              switch (e.value.kind) {
                UniversalKind.flag => 'bare',
                UniversalKind.event => '`${e.key}={…}`',
                UniversalKind.parameter => '`${e.key}=…`',
              },
              '${e.value.meaning}${e.value.on.isEmpty ? '' : ' (on ${e.value.on.join(', ')})'}',
            ],
      ]);

  String _typeWordsByLevel() {
    final b = StringBuffer();
    for (final level in Level.values) {
      final words = [
        for (final w in c.widgets)
          if ((widgetLevels[w.type] ?? Level.features) == level && _words[w.type] != null) _link(ItemKind.node, w.type, '`${_words[w.type]}`'),
      ];
      if (words.isNotEmpty) b.writeln('- **${level.index}. ${level.title}:** ${words.join(', ')}');
    }
    return b.toString().trimRight();
  }

  /// Each verb sample, and the action types it gives.
  late final List<(String, List<String>)> _verbTypes = [
    for (final s in notationVerbSamples)
      () {
        final r = parseNotation('state count=0\nstate ok=false\nBox#p onTap={$s}', catalog: c);
        if (r.issues.isNotEmpty) throw StateError('notation verb sample "$s": ${r.issues.join('; ')}');
        final reactions = ((r.document['nodes'] as Map)['p'] as Map)['actions'] as List;
        final actions = (reactions.single as Map)['actions'] as List;
        return (s, [for (final a in actions) '${(a as Map)['type']}']);
      }(),
  ];

  String _verbs() => Renderer.table(['Write', 'Action'], [
        for (final (s, types) in _verbTypes) ['`$s`', types.map((t) => _link(ItemKind.action, t)).join(' then ')],
      ]);

  String _coreEvents() {
    final triggers = [for (final t in (catalog['triggers']['types'] as List).cast<Json>()) if (triggerLevels[t['type']] == Level.core || triggerLevels[t['type']] == Level.widgets) t];
    return Renderer.table(['Event', 'Fires'], [
      for (final t in triggers) [_link(ItemKind.trigger, '${t['type']}', '`${notationEventName('${t['type']}')}`'), '${t['doc']}'.split('\n\n').first],
    ]);
  }

  String _triggers() => Renderer.table(['Event', 'Trigger', 'Level', 'Fires'], [
        for (final t in (catalog['triggers']['types'] as List).cast<Json>())
          [
            '<a id="${ItemKind.trigger.anchor('${t['type']}')}"></a>`${notationEventName('${t['type']}')}`',
            '`${t['type']}`',
            '${(triggerLevels[t['type']] ?? Level.full).index}',
            '${t['doc']}',
          ],
      ]);

  String _actions() {
    final verbs = <String, List<String>>{};
    for (final (s, types) in _verbTypes) {
      if (types.length == 1) (verbs[types.single] ??= []).add('`$s`');
    }
    final b = StringBuffer();
    for (final e in (catalog['actions']['types'] as Map).entries) {
      final type = e.key as String;
      final a = e.value as Json;
      final fields = (a['fields'] as List).cast<Json>();
      b
        ..writeln('<a id="${ItemKind.action.anchor(type)}"></a>')
        ..writeln('### `$type`: ${a['label']}')
        ..writeln();
      if ('${a['doc']}'.isNotEmpty) b..writeln('${a['doc']}'.split('\n\n').first)..writeln();
      final level = actionLevels[type] ?? Level.features;
      b.writeln('Written `$type${fields.take(2).map((f) => ' ${f['key']}=…').join()}`'
          '${verbs[type] == null ? '' : '; the verb: ${verbs[type]!.join(', ')}'}. Level ${level.index}.');
      b
        ..writeln()
        ..writeln(_fieldTable(fields, (f) => '`${f['key']}`'))
        ..writeln();
    }
    return b.toString().trimRight();
  }

  String _functionNames() {
    final fns = {for (final f in (catalog['formulas']['functions'] as List).cast<Json>()) '${f['name']}'};
    return [
      for (final g in formulaGroups.entries)
        '- **${g.key}:** ${[for (final n in g.value) if (fns.contains(n)) '`$n`'].join(' ')}',
    ].join('\n');
  }

  String _functions() {
    final fns = (catalog['formulas']['functions'] as List).cast<Json>();
    final b = StringBuffer();
    final anchored = <String>{};
    for (final g in formulaGroups.entries) {
      b
        ..writeln('### ${g.key}')
        ..writeln()
        ..writeln(Renderer.table(['Function', 'Signature', 'Example'], [
          for (final name in g.value)
            for (final fn in fns.where((f) => f['name'] == name))
              ['${anchored.add(name) ? '<a id="${ItemKind.function.anchor(name)}"></a>' : ''}`$name`', '`${fn['signature']}`', '`${fn['example']}`'],
        ]))
        ..writeln();
    }
    return b.toString().trimRight();
  }

  String _mediaSizes() => Renderer.table(['Condition', 'Holds', 'Also written'], [
        for (final e in mediaSizes.entries)
          [
            '`${e.key}`',
            e.value.entries.map((x) => '${x.key == 'maxWidth' ? 'up to' : 'from'} ${x.value} px').join(', '),
            [for (final h in mediaHideWords.entries) if (jsonEncode(h.value) == jsonEncode(e.value) && h.key.endsWith('=${e.key}')) '`${h.key}`'].join(', '),
          ],
      ]);

  /// The node states the parser reads as `state.key=value` (`hovered.fill`):
  /// each state the catalog declares, probed on a box. Empty while the
  /// parser has none.
  String _states() {
    final model = (catalog['objectTypes'] as Map)['StateStyles'] as Json?;
    final names = [for (final f in ((model?['fields'] as List?) ?? const []).cast<Json>()) '${f['key']}'];
    final rows = <List<String>>[];
    for (final s in names) {
      final r = parseNotation('Box#p w=40 h=40 $s.fill=#FF2563EB', catalog: c);
      final node = (r.document['nodes'] as Map)['p'] as Map?;
      if (r.issues.isNotEmpty || node == null || !jsonEncode(node['states'] ?? '').contains(s)) continue;
      rows.add(['`$s.fill=#FF2563EB`', '`$s`', '`${jsonEncode(node['states'])}`']);
    }
    if (rows.isEmpty) return '_The parser reads no node state words yet (`hovered.fill=…`): write `states={…}` as JSON ([StateStyles](@type-StateStyles))._';
    return Renderer.table(['Write', 'State', 'Gives `states`'], rows);
  }

  String _drawOps() {
    final b = StringBuffer();
    for (final s in DrawOpSpecs.all) {
      b
        ..writeln('<a id="paint-op-${s.op}"></a>')
        ..writeln('### `${s.op}`: ${s.label}')
        ..writeln()
        ..writeln('Flutter `${s.flutter}`.${s.doc.isEmpty ? '' : ' ${s.doc}'}')
        ..writeln()
        ..writeln(_fieldTable(_catalog.fieldsOf(s.fields, area: 'draw op ${s.op}', prefer: [_capital('${s.op}OpFields')]), (f) => '`${f['key']}`'))
        ..writeln();
    }
    return b.toString().trimRight();
  }

  String _valueTypes() => [
        for (final e in (catalog['valueTypes'] as Map).entries)
          '<a id="${ItemKind.valueType.anchor('${e.key}')}"></a>\n### ${e.key}\n\nWritten: ${e.value['forms']}.'
              '${'${e.value['doc']}'.isEmpty ? '' : '\n\n${'${e.value['doc']}'.split('\n\n').first}'}\n',
      ].join('\n');

  String _enums() => [
        for (final e in (catalog['enums'] as Map).entries)
          '<a id="${ItemKind.enumeration.anchor('${e.key}')}"></a>\n### ${e.key}\n\n'
              '${(e.value as List).any((v) => '${v['doc']}'.isNotEmpty) ? Renderer.table(['Word', 'Meaning'], [for (final v in e.value as List) ['`${v['value']}`', '${v['doc']}']]) : (e.value as List).map((v) => '`${v['value']}`').join(' ')}\n',
      ].join('\n');

  String _trust() {
    final agent = api.TrustProfile.agent;
    final allActions = (catalog['actions']['types'] as Map).keys.cast<String>().toList();
    final allowed = agent.actions ?? allActions.toSet();
    return Renderer.table(['', '`TrustProfile.agent` (the default for agent-written UI)'], [
      ['Words (node types)', 'The core catalog\'s: every type of levels 0 to 4 but the feature layers\' (${agent.widgets?.length ?? 'all'} types).'],
      ['Actions', [for (final a in allActions) if (allowed.contains(a)) _link(ItemKind.action, a)].join(', ')],
      ['Not allowed', [for (final a in allActions) if (!allowed.contains(a)) '`$a`'].join(', ')],
      ['Scripts', agent.scripts ? 'yes' : 'no (`runScript`, `script.x(…)`); `TrustProfile.agentApps` allows a document\'s own sandboxed scripts'],
      ['Links', agent.linkHosts == null ? 'any' : agent.linkHosts!.isEmpty ? 'none' : agent.linkHosts!.join(', ')],
      ['Navigation', '`${agent.navigation.name}`'],
      ['Limits', 'nodes ${agent.maxNodes}, depth ${agent.maxDepth}, text ${agent.maxTextLength} characters'],
    ]);
  }

  // --- the core, the levels and the index ------------------------------------------------

  String _core(Map<String, String> pages) {
    final text = _template('NOTATION.md', {
      ..._pageFills,
      'references': () => Renderer.table(['Page', 'What is in it', 'Open it when', 'Words'], [
            for (final p in notationPages)
              ['[${p.file}](${p.file})', _summary(pages[p.file]!), _when(pages[p.file]!), '${_wordCount(pages[p.file]!)}'],
            ['[levels.md](levels.md)', _summary(pages['levels.md']!), _when(pages['levels.md']!), '${_wordCount(pages['levels.md']!)}'],
            ['[index.md](index.md)', 'Every word, event, action and function, A to Z, and the page it is on.', 'you look a name up.', ''],
          ]),
    });
    return '${_note()}\n${Renderer.anchorHeadings(text, 'notation')}\n';
  }

  /// The first paragraph of a page (its summary).
  static String _summary(String page) {
    final m = RegExp(r'^# [^\n]*\n+(?:<a id="[^"]+"></a>\n)?([^\n#<|`][^\n]*(?:\n[^\n#<|`][^\n]*)*)', multiLine: true).firstMatch(page);
    if (m == null) return '';
    final para = m[1]!.replaceAll('\n', ' ').replaceAll(RegExp(r'\[([^\]]+)\]\([^)]*\)'), r'$1');
    final end = RegExp(r'\.(\s|$)').firstMatch(para);
    return end == null ? para : para.substring(0, end.start + 1);
  }

  /// A page's "Open it when" line (`Open it when …` in its template).
  static String _when(String page) => RegExp(r'Open it when ([^\n]*)').firstMatch(page)?[1] ?? '';

  static int _wordCount(String text) => RegExp(r'\S+').allMatches(text).length;

  String _levelsPage() {
    final b = StringBuffer()
      ..writeln(_note())
      ..writeln('<a id="page-levels"></a>')
      ..writeln('# Levels and trust')
      ..writeln()
      ..writeln('The words by feature level (`lib/src/core/levels.dart`, the same table as the JSON reference\'s levels.md). '
          'A level is a closed set: a document that uses one level\'s words uses nothing from a higher one. Open it when '
          'you are given a level, or a trust profile, to write within.')
      ..writeln();
    for (final level in Level.values) {
      b
        ..writeln('<a id="level-${level.name}"></a>')
        ..writeln('## ${level.index}. ${level.title} (`${level.name}`)')
        ..writeln();
      void row(String what, List<String> items) {
        if (items.isNotEmpty) b.writeln('- **$what:** ${items.join(', ')}');
      }

      row('Words', [
        for (final w in c.widgets)
          if ((widgetLevels[w.type] ?? Level.features) == level && placed[ItemKind.node]![w.type] != null) _link(ItemKind.node, w.type, '`${_words[w.type] ?? w.type}`'),
      ]);
      row('Events', [for (final e in triggerLevels.entries) if (e.value == level && placed[ItemKind.trigger]![e.key] != null) _link(ItemKind.trigger, e.key, '`${notationEventName(e.key)}`')]);
      row('Actions', [for (final e in actionLevels.entries) if (e.value == level && placed[ItemKind.action]![e.key] != null) _link(ItemKind.action, e.key)]);
      row('Keys any line takes', [for (final e in behaviorLevels.entries) if (e.value == level && placed[ItemKind.behavior]![e.key] != null) _link(ItemKind.behavior, e.key)]);
      row('Forms', [
        if (level == Level.state) ...['`key={expression}`', '`bind=name`', '`state` lines', '`each`', '`if`/`else`'],
        if (level == Level.design) ...['media rules (`phone.pad=8`, `hide=phone`)', 'a component call', '`component` blocks'],
        if (level == Level.full) ...['`customPaint` lines', '`animation` and `transition` lines'],
      ]);
      b.writeln();
    }
    b
      ..writeln('<a id="levels-trust"></a>')
      ..writeln('## Trust')
      ..writeln()
      ..writeln('A host checks what an agent writes against a trust profile (`lib/src/core/edit/trust.dart`). '
          'What it refuses is reported, not drawn: write within it.')
      ..writeln()
      ..writeln(_trust())
      ..writeln();
    return b.toString();
  }

  String _index(Map<String, String> pages) {
    final entries = <(String, String)>[];
    void add(ItemKind kind, String label, String Function(String) shown) {
      for (final e in placed[kind]!.entries) {
        final anchor = kind.anchor(e.key);
        final file = anchors[anchor];
        if (file == null) continue;
        entries.add((shown(e.key), '[`${shown(e.key)}`]($file#$anchor) $label'));
      }
    }

    add(ItemKind.node, 'word', (t) => _words[t] ?? t);
    add(ItemKind.behavior, 'key', (k) => k);
    add(ItemKind.trigger, 'event', notationEventName);
    add(ItemKind.action, 'action', (a) => a);
    add(ItemKind.function, 'function', (f) => f);
    add(ItemKind.valueType, 'value', (v) => v);
    add(ItemKind.model, 'record', (m) => m);
    add(ItemKind.enumeration, 'enum', (e) => e);
    entries.sort((a, b) {
      final x = a.$1.toLowerCase().compareTo(b.$1.toLowerCase());
      return x != 0 ? x : a.$2.compareTo(b.$2);
    });
    final az = StringBuffer();
    String? letter;
    final line = <String>[];
    void flush() {
      if (letter != null) az.writeln('**$letter** · ${line.join(' · ')}\n');
      line.clear();
    }

    for (final (name, link) in entries) {
      final l = name[0].toUpperCase();
      if (l != letter) {
        flush();
        letter = l;
      }
      line.add(link);
    }
    flush();
    return '${_note()}\n<a id="page-index"></a>\n# The notation reference: index\n\n'
        'Every page, then every name A to Z with the page it is on. [NOTATION.md](NOTATION.md) is the core: read it first.\n\n'
        '<a id="index-pages"></a>\n## Pages\n\n${Renderer.table(['Page', 'What is in it', 'Words'], [
          ['[NOTATION.md](NOTATION.md)', _summary(pages['NOTATION.md']!), '${_wordCount(pages['NOTATION.md']!)}'],
          for (final p in [...notationPages.map((p) => p.file), 'levels.md'])
            ['[$p]($p)', _summary(pages[p]!), '${_wordCount(pages[p]!)}'],
          ['[_tails.md](_tails.md)', 'What the notation still prints as JSON: the parity work list.', '${_wordCount(pages['_tails.md']!)}'],
        ])}\n\n<a id="index-a-z"></a>\n## A to Z\n\n${az.toString().trimRight()}\n';
  }

  Json _indexJson(Map<String, String> pages) {
    final topics = <Json>[];
    for (final file in ['NOTATION.md', ...notationPages.map((p) => p.file), 'levels.md']) {
      final page = pages[file]!;
      final id = file.replaceAll('.md', '');
      final title = RegExp(r'^# (.+)$', multiLine: true).firstMatch(page)?[1] ?? id;
      topics.add({'topic': id, 'file': file, 'anchor': 'page-${id == 'NOTATION' ? 'notation' : id}', 'title': title, 'summary': _summary(page), 'words': _wordCount(page)});
      final hs = RegExp(r'^<a id="([^"]+)"></a>\n## (.+)$', multiLine: true).allMatches(page).toList();
      for (var i = 0; i < hs.length; i++) {
        final end = i + 1 < hs.length ? hs[i + 1].start : page.length;
        final body = page.substring(hs[i].end, end);
        topics.add({'topic': hs[i][1], 'file': file, 'anchor': hs[i][1], 'title': hs[i][2]!.replaceAll('`', ''), 'words': _wordCount(body)});
      }
    }
    return {
      'version': catalog['version'],
      'base': {'file': 'NOTATION.md', 'words': _wordCount(pages['NOTATION.md']!)},
      'topics': topics,
      'items': {
        for (final kind in ItemKind.values)
          kind.name: {
            for (final e in placed[kind]!.entries)
              if (anchors[kind.anchor(e.key)] case final String file) e.key: '$file#${kind.anchor(e.key)}',
          },
      },
    };
  }
}
