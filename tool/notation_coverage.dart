// What the notation has no word for, measured: prints each document of a
// corpus in the notation (printNotation) and counts what ends up in a line's
// `{…}` tail or on the last `document {…}` line instead of in words.
//
//   dart run tool/notation_coverage.dart <dir or file.json>... [--out <dir>] [--components]
//
// The print round-trips by construction, so a tail is exactly what the words
// did not say. Each tail key is counted as a path with list indices folded
// (`decoration.fills[].color`), under the family its first segment belongs
// to. Writes <out>/coverage.json and <out>/COVERAGE.md (default: the current
// directory): per family, the paths by how many nodes carry them, with the
// node types that do and one example value.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/keys.dart' show notationKeyPath;

const _families = {
  'props': 'props',
  'layout': 'layout',
  'decoration': 'decoration',
  'bind': 'bindings',
  'actions': 'actions and triggers',
  'media': 'media rules',
  'animation': 'animation',
  'animations': 'animation',
  'slots': 'structure',
  'children': 'structure',
  'type': 'structure',
};

class _Path {
  int nodes = 0;
  final types = <String, int>{};
  String? example;
}

void main(List<String> args) {
  final outAt = args.indexOf('--out');
  final out = outAt >= 0 ? args[outAt + 1] : '.';
  // --components: the catalog also has every component the corpus declares
  // (a design system's component documents, by their `widget`), so a page
  // that calls one is printed with the catalog it was made with.
  final withComponents = args.contains('--components');
  final inputs = [
    for (var i = 0; i < args.length; i++)
      if (i != outAt && i != outAt + 1 && args[i] != '--components') args[i],
  ];
  if (inputs.isEmpty) {
    stderr.writeln('usage: notation_coverage.dart <dir or file.json>... [--out <dir>]');
    exit(2);
  }
  final files = <File>[];
  for (final input in inputs) {
    if (FileSystemEntity.isDirectorySync(input)) {
      files.addAll(Directory(input).listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.json')));
    } else {
      files.add(File(input));
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  // A component declared differently in two design systems (a ChartCard of
  // each) is, for a document, the declaration nearest to it on disk: the
  // one of its own design system.
  final declared = <String, Map<String, String>>{}; // type → declaration's JSON → its file
  if (withComponents) {
    for (final file in files) {
      try {
        final json = jsonDecode(file.readAsStringSync());
        final widget = json is Map ? json['widget'] : null;
        if (widget is Map && widget['type'] is String) {
          (declared[widget['type'] as String] ??= {}).putIfAbsent(jsonEncode(widget), () => file.path);
        }
      } on Object {
        continue;
      }
    }
  }
  final shared = [
    for (final e in declared.entries) jsonDecode(e.value.keys.first),
  ];
  final base = withComponents ? standardCatalog + Catalog.fromJson({'id': 'corpus', 'widgets': shared}) : standardCatalog;
  final catalogs = <String, Catalog>{};
  Catalog catalogFor(String path) {
    final own = <Object?>[];
    final key = StringBuffer();
    for (final e in declared.entries) {
      if (e.value.length < 2) continue;
      int common(String a) {
        var i = 0;
        while (i < a.length && i < path.length && a[i] == path[i]) {
          i++;
        }
        return i;
      }

      final nearest = e.value.entries.reduce((a, b) => common(b.value) > common(a.value) ? b : a);
      if (nearest.key == e.value.keys.first) continue;
      own.add(jsonDecode(nearest.key));
      key.write('${nearest.value};');
    }
    if (own.isEmpty) return base;
    return catalogs['$key'] ??= base + Catalog.fromJson({'id': 'nearest', 'widgets': own});
  }

  final paths = <String, _Path>{};
  final documentPaths = <String, _Path>{};
  final wordless = <String, int>{}; // node types printed under their catalog name
  final wholeWhy = <String, int>{}; // why a document printed whole, by reason
  final wholeExample = <String, String>{};
  final shapes = <String, int>{}; // what the walk wrote: each, if, else, component, state lines
  var documents = 0, whole = 0, failed = 0, nodes = 0, tailed = 0, tailChars = 0, chars = 0;
  // Record lines (paint ops, animations and their tracks, transitions);
  // node lines with no tail, no JSON value and no dotted path.
  var records = 0, inWords = 0;
  final saidAs = <String, int>{}; // a node line's fields, by how each is said
  final keyCache = <String, String>{};

  for (final file in files) {
    final Object? json;
    try {
      json = jsonDecode(file.readAsStringSync());
    } on Object {
      continue;
    }
    if (json is! Map<String, Object?> || json['nodes'] is! Map || json['roots'] is! List) continue;
    final String text;
    final catalog = catalogFor(file.path);
    try {
      final doc = json;
      text = Catalog.run(catalog, () => printNotation(doc, catalog: catalog, whole: (said) {
            // The reason, without the line it was found on.
            final why = said.split(' — ').first;
            wholeWhy[why] = (wholeWhy[why] ?? 0) + 1;
            wholeExample.putIfAbsent(why, () => file.path);
          }));
    } on Object {
      failed++;
      continue;
    }
    documents++;
    chars += text.length;
    final all = text.split('\n');
    if (all.length == 1 && all.single.startsWith('document ')) whole++;
    // The indent of an open block of record lines (a customPaint, an
    // animation, a transition): the lines under it are its records.
    int? recordAt;
    for (final line in all) {
      final trimmed = line.trimLeft();
      final indent = line.length - trimmed.length;
      if (recordAt != null && indent > recordAt) {
        records++;
        continue;
      }
      recordAt = null;
      if (_recordHead.hasMatch(trimmed)) {
        recordAt = indent;
        records++;
        continue;
      }
      // The walk's own lines (design 22, the document family): counted by
      // their word, not as nodes.
      // (A node of type slot, `slot {…}`, is a node.)
      final m = RegExp(r'^(state|canvas|each|if|else|component|param|event|slot|preview|every|key)(?=\s+[^\s{]|$)|^(Canvas)#|^(document)\s+[a-z]+=').firstMatch(trimmed);
      final statement = m == null ? null : m[1] ?? m[2] ?? m[3];
      if (statement != null) {
        shapes[statement] = (shapes[statement] ?? 0) + 1;
        continue;
      }
      if (trimmed.startsWith('document ')) {
        final rest = _tail(trimmed.substring('document '.length));
        if (rest != null) {
          tailChars += trimmed.length;
          final flat = <String>{};
          _flatten(rest, '', flat, <String, String>{});
          // A node or a variables' scope by its id is one path for every id.
          final seen = {for (final p in flat) p.replaceFirstMapped(RegExp(r'^(nodes|variables)\.[^.\[]+'), (m) => '${m[1]}.*')};
          for (final p in seen) {
            (documentPaths[p] ??= _Path()).nodes++;
          }
        }
        continue;
      }
      nodes++;
      final word = RegExp(r'^[A-Za-z][A-Za-z0-9.]*').stringMatch(trimmed) ?? '?';
      if (word.isNotEmpty && word[0].toLowerCase() == word[0]) wordless[word] = (wordless[word] ?? 0) + 1;
      final at = _tailStart(trimmed);
      // How each field of the line is said.
      final said = _said(at < 0 ? trimmed : trimmed.substring(0, at), catalog, keyCache);
      for (final s in said) {
        saidAs[s] = (saidAs[s] ?? 0) + 1;
      }
      if (at < 0 && !said.contains('json') && !said.contains('path')) inWords++;
      if (at < 0) continue;
      final tail = _tail(trimmed.substring(at));
      if (tail == null) continue;
      tailed++;
      tailChars += trimmed.length - at;
      final seen = <String>{};
      final examples = <String, String>{};
      _flatten(tail, '', seen, examples);
      for (final p in seen) {
        final entry = paths[p] ??= _Path();
        entry.nodes++;
        entry.types[word] = (entry.types[word] ?? 0) + 1;
        entry.example ??= examples[p];
      }
    }
  }

  final byFamily = <String, List<MapEntry<String, _Path>>>{};
  for (final e in paths.entries) {
    final first = e.key.split(RegExp(r'[.\[]')).first;
    (byFamily[_families[first] ?? 'behaviors and other node keys'] ??= []).add(e);
  }
  for (final list in byFamily.values) {
    list.sort((a, b) => b.value.nodes.compareTo(a.value.nodes));
  }
  final families = byFamily.keys.toList()
    ..sort((a, b) => byFamily[b]!.fold<int>(0, (s, e) => s + e.value.nodes).compareTo(byFamily[a]!.fold<int>(0, (s, e) => s + e.value.nodes)));

  final md = StringBuffer()
    ..writeln('# Notation coverage')
    ..writeln()
    ..writeln('What `printNotation` could not say in words, over ${inputs.join(', ')}.')
    ..writeln()
    ..writeln('| | |')
    ..writeln('|---|---|')
    ..writeln('| Documents printed | $documents (failed to print: $failed) |')
    ..writeln('| Printed whole as data (no tree in words) | $whole |')
    ..writeln('| Node lines | $nodes |')
    ..writeln('| Node lines with a `{…}` tail | $tailed (${_pct(tailed, nodes)}) |')
    ..writeln('| Characters in tails | $tailChars of $chars (${_pct(tailChars, chars)}) |')
    ..writeln('| Distinct tail paths | ${paths.length} |')
    ..writeln('| Node lines in words (no tail, no JSON value, no dotted path) | $inWords (${_pct(inWords, nodes)}) |')
    ..writeln('| Record lines (paint ops, animations, tracks, transitions), not counted as nodes | $records |')
    ..writeln();
  final saidTotal = saidAs.values.fold<int>(0, (a, b) => a + b);
  md
    ..writeln('## How a node line says its fields')
    ..writeln()
    ..writeln('| Said as | Fields | Share |')
    ..writeln('|---|---:|---:|');
  for (final k in const ['word', 'name', 'path', 'json', 'event', 'media']) {
    final what = switch (k) {
      'word' => 'a word of the notation (`gap=`, `fill=`, a flag)',
      'name' => "the field's own name (`letterSpacing=`)",
      'path' => 'a dotted path (`props.style.height=`)',
      'json' => 'JSON as a value (`style={…}`, `effects=[{…}]`)',
      'event' => 'an event (`onTap={…}`)',
      _ => 'a media rule (`phone.pad=`)',
    };
    md.writeln('| $what | ${saidAs[k] ?? 0} | ${_pct(saidAs[k] ?? 0, saidTotal)} |');
  }
  md.writeln();
  if (wholeWhy.isNotEmpty) {
    final list = wholeWhy.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    md
      ..writeln('## Why a document printed whole')
      ..writeln()
      ..writeln('| Reason | Documents | Example |')
      ..writeln('|---|---:|---|');
    for (final e in list) {
      md.writeln('| ${e.key} | ${e.value} | `${wholeExample[e.key]}` |');
    }
    md.writeln();
  }
  if (shapes.isNotEmpty) {
    final list = shapes.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    md
      ..writeln("## The walk's own lines (state, each, if, a component's head…)")
      ..writeln()
      ..writeln(list.map((e) => '`${e.key}` ${e.value}').join(', '))
      ..writeln();
  }
  if (wordless.isNotEmpty) {
    final list = wordless.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    md
      ..writeln('## Node types printed under their catalog name (no word of their own)')
      ..writeln()
      ..writeln(list.map((e) => '`${e.key}` ${e.value}').join(', '))
      ..writeln();
  }
  for (final family in families) {
    final list = byFamily[family]!;
    md
      ..writeln('## $family (${list.length} paths)')
      ..writeln()
      ..writeln('| Path | Nodes | On | Example |')
      ..writeln('|---|---:|---|---|');
    for (final e in list.take(60)) {
      final types = (e.value.types.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(4).map((t) => t.key).join(', ');
      md.writeln('| `${e.key}` | ${e.value.nodes} | $types | `${(e.value.example ?? '').replaceAll('|', r'\|')}` |');
    }
    if (list.length > 60) md.writeln('| … ${list.length - 60} more | | | |');
    md.writeln();
  }
  if (documentPaths.isNotEmpty) {
    final list = documentPaths.entries.toList()..sort((a, b) => b.value.nodes.compareTo(a.value.nodes));
    md
      ..writeln('## the `document {…}` line (${list.length} paths)')
      ..writeln()
      ..writeln('| Path | Documents |')
      ..writeln('|---|---:|');
    for (final e in list.take(40)) {
      md.writeln('| `${e.key}` | ${e.value.nodes} |');
    }
    md.writeln();
  }

  Directory(out).createSync(recursive: true);
  File('$out/COVERAGE.md').writeAsStringSync(md.toString());
  File('$out/coverage.json').writeAsStringSync(const JsonEncoder.withIndent(' ').convert({
    'documents': documents,
    'failed': failed,
    'whole': whole,
    'nodes': nodes,
    'tailed': tailed,
    'inWords': inWords,
    'records': records,
    'said': saidAs,
    'tailChars': tailChars,
    'chars': chars,
    'wordless': wordless,
    'wholeWhy': wholeWhy,
    'lines': shapes,
    'families': {
      for (final family in families)
        family: {
          for (final e in byFamily[family]!) e.key: {'nodes': e.value.nodes, 'types': e.value.types, 'example': e.value.example},
        },
    },
    'document': {for (final e in documentPaths.entries) e.key: e.value.nodes},
  }));
  stdout.writeln('$documents documents, $nodes node lines, $tailed with a tail (${_pct(tailed, nodes)}), ${paths.length} distinct paths, '
      '$whole printed whole as data, $failed failed. Wrote $out/COVERAGE.md');
}

/// The first word of a block of record lines (design 22, 4.6).
final _recordHead = RegExp(r'^(customPaint|animation|transition)(?=[\s#{]|$)');

final _mediaKey = RegExp(r'^(phone|mobile|tablet|desktop|portrait|landscape|(min|max)([0-9]+|[A-Z][A-Za-z0-9]*))\.');

/// How each field of a node line (its words, without its tail) is said:
/// `word` (a word of the notation: `gap=`, `fill=`, a flag, an alignment),
/// `name` (the field's own name, `letterSpacing=`), `path` (a dotted path,
/// `props.style.height=`), `json` (a record or a list of records written as
/// JSON), `event` (an `on…=`), `media` (a rule, `phone.pad=`).
List<String> _said(String line, Catalog catalog, Map<String, String> cache) {
  final head = RegExp(r'^([A-Za-z][A-Za-z0-9]*)(\.[A-Za-z0-9]+)?(#[A-Za-z0-9_-]+)?').firstMatch(line);
  if (head == null) return const [];
  final written = head[1]!;
  var type = notationTypes[written]?.type ?? '${written[0].toLowerCase()}${written.substring(1)}';
  if (catalog.widget(type) == null) type = written;
  final out = <String>[];
  var i = head.end;
  int skip(int from) {
    // A value or a string: quoted, bracketed (balanced, quotes inside), or to a space.
    if (from >= line.length) return from;
    final open = line[from];
    if (open == '"') {
      for (var k = from + 1; k < line.length; k++) {
        if (line[k] == r'\') {
          k++;
        } else if (line[k] == '"') {
          return k + 1;
        }
      }
      return line.length;
    }
    if (open == '{' || open == '[' || open == '(') {
      var depth = 0;
      var quoted = false;
      for (var k = from; k < line.length; k++) {
        final c = line[k];
        if (quoted) {
          if (c == r'\') {
            k++;
          } else if (c == '"') {
            quoted = false;
          }
          continue;
        }
        if (c == '"') quoted = true;
        if (c == '{' || c == '[' || c == '(') depth++;
        if ((c == '}' || c == ']' || c == ')') && --depth == 0) return k + 1;
      }
      return line.length;
    }
    final space = line.indexOf(' ', from);
    return space < 0 ? line.length : space;
  }

  while (i < line.length) {
    if (line[i] == ' ') {
      i++;
      continue;
    }
    if (line[i] == '"' || line[i] == '{') {
      i = skip(i); // the main text, or a value where the text goes
      continue;
    }
    var k = i;
    while (k < line.length && line[k] != ' ' && line[k] != '=' && line[k] != '(') {
      k++;
    }
    final key = line.substring(i, k);
    if (k < line.length && line[k] == '(') k = skip(k);
    if (k >= line.length || line[k] != '=') {
      out.add('word');
      i = k;
      continue;
    }
    final valueEnd = skip(k + 1);
    final value = line.substring(k + 1, valueEnd);
    i = valueEnd;
    if (RegExp(r'^on[A-Z]').hasMatch(key)) {
      out.add('event');
    } else if (_mediaKey.hasMatch(key)) {
      out.add('media');
    } else if (value.startsWith('{"') || (value.startsWith('[') && value.contains('{"'))) {
      out.add('json');
    } else if (key.contains('.')) {
      out.add('path');
    } else {
      out.add(cache['$type $key'] ??= () {
        final path = notationKeyPath(key, type, catalog: catalog);
        return path != null && path.split('.').last == key ? 'name' : 'word';
      }());
    }
  }
  return out;
}

String _pct(int a, int b) => b == 0 ? '0%' : '${(100 * a / b).toStringAsFixed(1)}%';

/// Where a line's `{…}` tail starts: the last top-level ` {"` whose braces
/// close at the end of the line. -1: none.
int _tailStart(String line) {
  if (!line.endsWith('}')) return -1;
  var at = line.indexOf(' {"');
  while (at >= 0) {
    if (_tail(line.substring(at + 1)) != null) return at + 1;
    at = line.indexOf(' {"', at + 1);
  }
  return -1;
}

Map<String, Object?>? _tail(String text) {
  try {
    final v = jsonDecode(text);
    return v is Map<String, Object?> ? v : null;
  } on Object {
    return null;
  }
}

/// Every leaf of [value] as a path, list indices folded to `[]`, map keys
/// that are data (a variable's or node's name) left as they are.
void _flatten(Object? value, String at, Set<String> seen, Map<String, String> examples) {
  if (value is Map) {
    if (value.isEmpty && at.isNotEmpty) seen.add(at);
    for (final e in value.entries) {
      _flatten(e.value, at.isEmpty ? '${e.key}' : '$at.${e.key}', seen, examples);
    }
  } else if (value is List) {
    if (value.isEmpty) seen.add('$at[]');
    for (final v in value) {
      _flatten(v, '$at[]', seen, examples);
    }
  } else if (at.isNotEmpty) {
    seen.add(at);
    final text = jsonEncode(value);
    examples.putIfAbsent(at, () => text.length > 48 ? '${text.substring(0, 45)}…' : text);
  }
}
