// What the notation has no word for, measured: prints each document of a
// corpus in the notation (printNotation) and counts what ends up in a line's
// `{…}` tail or on the last `document {…}` line instead of in words.
//
//   dart run tool/notation_coverage.dart <dir or file.json>... [--out <dir>]
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
  final inputs = [
    for (var i = 0; i < args.length; i++)
      if (i != outAt && i != outAt + 1) args[i],
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

  final paths = <String, _Path>{};
  final documentPaths = <String, _Path>{};
  final wordless = <String, int>{}; // node types printed under their catalog name
  var documents = 0, whole = 0, failed = 0, nodes = 0, tailed = 0, tailChars = 0, chars = 0;

  for (final file in files) {
    final Object? json;
    try {
      json = jsonDecode(file.readAsStringSync());
    } on Object {
      continue;
    }
    if (json is! Map<String, Object?> || json['nodes'] is! Map || json['roots'] is! List) continue;
    final String text;
    try {
      text = printNotation(json, catalog: standardCatalog);
    } on Object {
      failed++;
      continue;
    }
    documents++;
    chars += text.length;
    final all = text.split('\n');
    if (all.length == 1 && all.single.startsWith('document ')) whole++;
    for (final line in all) {
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('state ')) continue;
      if (trimmed.startsWith('document ')) {
        final rest = _tail(trimmed.substring('document '.length));
        if (rest != null) {
          tailChars += trimmed.length;
          final seen = <String>{};
          _flatten(rest, '', seen, <String, String>{});
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
    ..writeln();
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
    'tailChars': tailChars,
    'chars': chars,
    'wordless': wordless,
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
