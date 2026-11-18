// What the notation has no word for, measured: prints each document of a
// corpus in the notation (printNotation) and counts what ends up in a line's
// `{…}` tail or on the last `document {…}` line instead of in words.
//
//   dart run tool/notation_coverage.dart <dir or file.json>... [--out <dir>] [--components] [--dump <dir>]
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
  final files = <String>[];
}

/// What stays in a tail, and why (docs/design/22, "What stays in a tail, and
/// why"): each kind of field the corpus holds that the notation does not say,
/// on purpose, with the reason. A tail path none of them names is a real gap.
const _stays = <String, String>{
  'schema 2': "A schema-2 document's old spelling, which the migration rewrites (a box's `props.path` is a path node's "
      '`props.data`, `layout.rotation` is `motion.rotate`, a state patch of `self` is the node\'s id, `transitions` as a '
      'map is a list): the notation says the current schema.',
  'no such field': 'A prop or key the type does not have, or a value its field does not take (a button\'s `size`, an '
      'empty prop name, a text\'s `props.decoration`, `keyboardType: "email"`, a top-level `margin`): no renderer reads '
      'it, and applyOps refuses it.',
  'not drawn': 'A decoration on a type that draws none (a text\'s fills, a page view\'s or a component call\'s radius, a '
      'button\'s bound radius): the renderer does not draw it; applyOps accepts it today.',
  'under a binding': 'A value beside a binding of the same field: the binding replaces it, and applyOps moves it into `bind`.',
  'children not taken': "Children a component's declaration does not take: the renderer shows only its slots.",
  'scope name': 'A variable named as a runtime scope (`theme`, `storage`): valid, and it shadows the scope on its page, '
      'but a state line refuses the name (34.0.0), so the document line keeps the variables.',
};

/// The kind of [_stays] that tail path [path] (`props.size`, on a line of
/// type [type]; a document line's path with `nodes.*.` before a node's) is,
/// in a document of schema 2 or not ([old]); null: a real gap.
String? _staysAs(String path, String? type, bool old) {
  final p = path.replaceFirst(RegExp(r'^nodes\.\*\.'), '');
  bool on(Set<String> types) => type == null || types.contains(type);
  const buttons = {'FilledButton', 'OutlinedButton', 'TextButton', 'Button', 'Button.outline', 'Button.ghost'};
  if (old && RegExp(r'^(props\.path|bind\.layout\.rotation|states\.[A-Za-z]+\.self\..+|transitions\.[A-Za-z]+\..+)$').hasMatch(p)) {
    return 'schema 2';
  }
  if ((p == 'props.size' || p == 'props.style') && on(buttons)) return 'no such field';
  if (p == 'props.' && on({...buttons, 'Icon'})) return 'no such field';
  if ((p == 'props.decoration' || p == 'props.style.decoration') && on({'Text', 'Text.mono'})) return 'no such field';
  if (p == 'props.keyboardType' && on({'Input'})) return 'no such field';
  if (p == 'margin[]' && type != null) return 'no such field';
  if (p == 'decoration.fills[].color' && on({'Text', 'Text.mono'})) return 'not drawn';
  if (p == 'decoration.radius' && on({'Media', 'Pages'})) return 'not drawn';
  if (p == 'bind.decoration.radius' && on(buttons)) return 'not drawn';
  if (p == 'props.icon' && on({'Icon'})) return 'under a binding';
  if ((p == 'children[]' || p == 'slots') && on({'Sidebar'})) return 'children not taken';
  if (type == null && path.startsWith('variables.')) return 'scope name';
  return null;
}

void main(List<String> args) {
  final outAt = args.indexOf('--out');
  final out = outAt >= 0 ? args[outAt + 1] : '.';
  // --components: the catalog also has every component the corpus declares
  // (a design system's component documents, by their `widget`), so a page
  // that calls one is printed with the catalog it was made with.
  final withComponents = args.contains('--components');
  // --dump <dir>: each print that has a tail or a document line, to read.
  final dumpAt = args.indexOf('--dump');
  final dump = dumpAt >= 0 ? args[dumpAt + 1] : null;
  // The arguments that are a flag or a flag's value; an absent flag (-1) names
  // none (`outAt + 1` would be 0, the first folder).
  final flags = {
    if (outAt >= 0) ...[outAt, outAt + 1],
    if (dumpAt >= 0) ...[dumpAt, dumpAt + 1],
  };
  final inputs = [
    for (var i = 0; i < args.length; i++)
      if (!flags.contains(i) && args[i] != '--components') args[i],
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
  // A document is read with the components of its own design system or site
  // (its home, [_homeOf]): the folder it is in or the nearest above it that
  // has a `components/` folder of component documents or a `site.json` naming
  // a `designSystem`. Over those, every other component the corpus declares
  // (the first declaration of a name found), so a document with no home, or
  // one calling a component its home does not declare, still reads it.
  final declared = <String, Object?>{}; // type → its first declaration
  final byHome = <String, Map<String, Object?>>{}; // home folder → type → declaration
  if (withComponents) {
    for (final file in files) {
      try {
        final json = jsonDecode(file.readAsStringSync());
        final widget = json is Map ? json['widget'] : null;
        if (widget is Map && widget['type'] is String) {
          declared.putIfAbsent(widget['type'] as String, () => widget);
          final home = _componentsHome(file.path);
          if (home != null) (byHome[home] ??= {}).putIfAbsent(widget['type'] as String, () => widget);
        }
      } on Object {
        continue;
      }
    }
  }
  final base = withComponents ? standardCatalog + Catalog.fromJson({'id': 'corpus', 'widgets': declared.values.toList()}) : standardCatalog;
  final catalogs = <String, Catalog>{};
  final homes = <String, int>{}; // home → documents read with it
  // A document that names no home (a folder of generated screens) is read
  // with the one home whose components take every call it makes: the most
  // nodes of a component type whose props are all that home's parameters of
  // it, and more than any other home. Else the first declarations.
  String? byFit(Map<String, Object?> json) {
    final nodes = json['nodes'];
    if (nodes is! Map) return null;
    String? best;
    var bestScore = 0, second = 0;
    for (final home in byHome.entries) {
      var score = 0;
      for (final node in nodes.values) {
        if (node is! Map) continue;
        final widget = home.value[node['type']];
        if (widget is! Map) continue;
        final params = {for (final p in (widget['props'] as List? ?? const [])) if (p is Map) p['key']};
        final props = node['props'];
        if (props is! Map || props.keys.every(params.contains)) score++;
      }
      if (score > bestScore) {
        second = bestScore;
        bestScore = score;
        best = home.key;
      } else if (score > second) {
        second = score;
      }
    }
    return bestScore > second ? best : null;
  }

  Catalog catalogFor(String path, Map<String, Object?> json) {
    if (!withComponents) return base;
    var home = _homeOf(path, byHome.keys.toSet());
    var how = '';
    if (home == null) {
      home = byFit(json);
      how = ' (by fit)';
    }
    final said = home == null ? '(none)' : '$home$how';
    homes[said] = (homes[said] ?? 0) + 1;
    if (home == null) return base;
    return catalogs[home] ??= base + Catalog.fromJson({'id': 'home', 'widgets': byHome[home]!.values.toList()});
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
  // A field said as JSON, by its shape (`w={"fill":#}`): how often, and one file.
  final jsonShapes = <String, int>{};
  final jsonShapeExample = <String, String>{};
  final keyCache = <String, String>{};
  // What stays in a tail ([_stays]), by kind ('' a real gap): the node lines
  // and the documents (their `document {…}` line) with one, the paths and
  // the files; and each real gap's path, by the line's word.
  final staysLines = <String, int>{};
  final staysDocuments = <String, Set<String>>{};
  final staysPaths = <String, Set<String>>{};
  final staysFiles = <String, Set<String>>{};
  final gapPaths = <String>{};

  for (final file in files) {
    final Object? json;
    try {
      json = jsonDecode(file.readAsStringSync());
    } on Object {
      continue;
    }
    if (json is! Map<String, Object?> || json['nodes'] is! Map || json['roots'] is! List) continue;
    // A document with no schema is of the oldest (schemaOf).
    final old = json['schema'] is! int || (json['schema']! as int) < 3;
    final String text;
    final catalog = catalogFor(file.path, json);
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
    if (dump != null && (text.contains(' {"') || text.startsWith('document {') || text.contains('\ndocument {'))) {
      final name = file.path.replaceAll(RegExp(r'[\\/:]+'), '_');
      File('$dump/${name.length > 150 ? name.substring(name.length - 150) : name}.txt')
        ..createSync(recursive: true)
        ..writeAsStringSync(text);
    }
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
      final m = RegExp(r'^(state|canvas|each|if|else|component|param|event|slot|preview|every|key|on)(?=\s+[^\s{]|$)|^(Canvas)#|^(document)\s+[a-z]+=').firstMatch(trimmed);
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
          final kinds = {for (final p in seen) _staysAs(p, null, old) ?? ''};
          for (final k in kinds) {
            (staysDocuments[k] ??= <String>{}).add(file.path);
          }
          for (final p in seen) {
            final kind = _staysAs(p, null, old) ?? '';
            (staysPaths[kind] ??= <String>{}).add('document $p');
            (staysFiles[kind] ??= <String>{}).add(file.path);
            if (kind.isEmpty) gapPaths.add('document: $p');
          }
        }
        continue;
      }
      nodes++;
      final word = RegExp(r'^[A-Za-z][A-Za-z0-9.]*').stringMatch(trimmed) ?? '?';
      if (word.isNotEmpty && word[0].toLowerCase() == word[0]) wordless[word] = (wordless[word] ?? 0) + 1;
      final at = _tailStart(trimmed);
      // How each field of the line is said.
      final said = _said(at < 0 ? trimmed : trimmed.substring(0, at), catalog, keyCache, (shape, written) {
        jsonShapes[shape] = (jsonShapes[shape] ?? 0) + 1;
        jsonShapeExample.putIfAbsent(shape, () => '$word $written  (${file.path})');
      });
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
        if (entry.files.length < 8 && !entry.files.contains(file.path)) entry.files.add(file.path);
        final kind = _staysAs(p, word, old) ?? '';
        (staysPaths[kind] ??= <String>{}).add(p);
        (staysFiles[kind] ??= <String>{}).add(file.path);
        if (kind.isEmpty) gapPaths.add('$word: $p');
      }
      for (final k in {for (final p in seen) _staysAs(p, word, old) ?? ''}) {
        staysLines[k] = (staysLines[k] ?? 0) + 1;
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
  if (jsonShapes.isNotEmpty) {
    final list = jsonShapes.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    md
      ..writeln('## JSON as a value: the most frequent shapes')
      ..writeln()
      ..writeln('| Shape | Fields | Example |')
      ..writeln('|---|---:|---|');
    for (final e in list.take(20)) {
      md.writeln('| `${e.key.replaceAll('|', r'\|')}` | ${e.value} | `${jsonShapeExample[e.key]!.replaceAll('|', r'\|')}` |');
    }
    md.writeln();
  }
  // What stays in a tail, and why: every tail path is of a kind of
  // [_stays], or a real gap.
  md
    ..writeln('## What stays in a tail, and why')
    ..writeln()
    ..writeln('| Kind | Node lines | Document lines | Paths | Why |')
    ..writeln('|---|---:|---:|---|---|');
  for (final k in _stays.keys) {
    final lines = staysLines[k] ?? 0, docs = staysDocuments[k]?.length ?? 0;
    if (lines == 0 && docs == 0) continue;
    md.writeln('| $k | $lines | $docs | ${(staysPaths[k] ?? const <String>{}).map((p) => '`$p`').join(', ')} | ${_stays[k]} |');
  }
  md
    ..writeln('| **real gaps** | ${staysLines[''] ?? 0} | ${staysDocuments['']?.length ?? 0} | ${gapPaths.map((p) => '`$p`').join(', ')} | What the notation should say and does not. |')
    ..writeln();
  if (homes.isNotEmpty) {
    final list = homes.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    md
      ..writeln('## Whose components a document is read with')
      ..writeln()
      ..writeln('Its home: the folder it is in or the nearest above it with a `components/` folder, or whose `site.json` '
          'names a `designSystem`; over them, the first declaration of every other component of the corpus.')
      ..writeln()
      ..writeln('| Home | Documents |')
      ..writeln('|---|---:|');
    for (final e in list) {
      // The home's last three folders are enough to name it.
      final how = e.key.endsWith(' (by fit)') ? ' (by fit)' : '';
      final segments = e.key.substring(0, e.key.length - how.length).split('/').where((s) => s.isNotEmpty).toList();
      final name = e.key == '(none)' ? '(none)' : '${segments.skip(segments.length < 3 ? 0 : segments.length - 3).join('/')}/$how';
      md.writeln('| `$name` | ${e.value} |');
    }
    md.writeln();
  }
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
    'jsonShapes': jsonShapes,
    'tailChars': tailChars,
    'chars': chars,
    'wordless': wordless,
    'wholeWhy': wholeWhy,
    'lines': shapes,
    'families': {
      for (final family in families)
        family: {
          for (final e in byFamily[family]!) e.key: {'nodes': e.value.nodes, 'types': e.value.types, 'example': e.value.example, 'files': e.value.files},
        },
    },
    'document': {for (final e in documentPaths.entries) e.key: e.value.nodes},
    'stays': {
      for (final k in {..._stays.keys, ''})
        if ((staysLines[k] ?? 0) > 0 || (staysDocuments[k]?.isNotEmpty ?? false))
          k.isEmpty ? 'real gaps' : k: {
            'nodeLines': staysLines[k] ?? 0,
            'documents': [...?staysDocuments[k]],
            'paths': [...?staysPaths[k]],
            'files': [...?staysFiles[k]],
          },
    },
    'realGaps': [...gapPaths],
  }));
  stdout.writeln('$documents documents, $nodes node lines, $tailed with a tail (${_pct(tailed, nodes)}), ${paths.length} distinct paths, '
      '$whole printed whole as data, $failed failed; real gaps: ${staysLines[''] ?? 0} node lines, '
      '${staysDocuments['']?.length ?? 0} document lines. Wrote $out/COVERAGE.md');
}

/// A folder as a normalized absolute URI ending in `/`, so two spellings of
/// one folder compare equal.
String _folder(String path) {
  final uri = Directory(path).absolute.uri.normalizePath().toString();
  return (uri.endsWith('/') ? uri : '$uri/').toLowerCase();
}

/// The home of a component document: the folder holding its `components/`
/// folder (a design system, a site), else the folder it is in (an example's
/// own component beside its page).
String? _componentsHome(String file) {
  var dir = File(file).absolute.parent;
  final name = dir.uri.pathSegments.where((s) => s.isNotEmpty).last;
  if (name == 'components') return _folder(dir.parent.path);
  // A file elsewhere under a design system (its repairs) is that system's.
  for (var d = dir; d.parent.path != d.path; d = d.parent) {
    if (File('${d.path}/design_system.json').existsSync()) return _folder(d.path);
  }
  return _folder(dir.path);
}

/// The home of a document (its design system or site): the folder it is in
/// or the nearest above it that is a home of components, or whose
/// `site.json` names a `designSystem` that is one. Null: none.
String? _homeOf(String file, Set<String> homes) {
  for (var d = File(file).absolute.parent; d.parent.path != d.path; d = d.parent) {
    final here = _folder(d.path);
    if (homes.contains(here)) return here;
    final site = File('${d.path}/site.json');
    if (site.existsSync()) {
      try {
        final json = jsonDecode(site.readAsStringSync());
        final ds = json is Map ? json['designSystem'] : null;
        if (ds is String) {
          final target = _folder(d.uri.resolve(ds).toFilePath());
          if (homes.contains(target)) return target;
        }
      } on Object {
        // not a site
      }
    }
  }
  return null;
}

/// The first word of a block of record lines (design 22, 4.6).
final _recordHead = RegExp(r'^(customPaint|animation|transition)(?=[\s#{]|$)');

final _mediaKey = RegExp(r'^(phone|mobile|tablet|desktop|portrait|landscape|(min|max)([0-9]+|[A-Z][A-Za-z0-9]*))\.');

/// How each field of a node line (its words, without its tail) is said:
/// `word` (a word of the notation: `gap=`, `fill=`, a flag, an alignment),
/// `name` (the field's own name, `letterSpacing=`), `path` (a dotted path,
/// `props.style.height=`), `json` (a record or a list of records written as
/// JSON), `event` (an `on…=`), `media` (a rule, `phone.pad=`).
List<String> _said(String line, Catalog catalog, Map<String, String> cache, [void Function(String shape, String written)? json]) {
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
      if (json != null) {
        final written = '$key=$value';
        json('$key=${_shape(value)}', written.length > 120 ? '${written.substring(0, 117)}…' : written);
      }
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

/// A JSON value's shape: its maps' keys in order, a number `#`, a string
/// `"…"`, a list by its first element (`[{"color":"…"}…]` for several).
String _shape(String text) {
  Object? value;
  try {
    value = jsonDecode(text);
  } on Object {
    return text.length > 40 ? '${text.substring(0, 37)}…' : text;
  }
  String of(Object? v) => switch (v) {
        Map() => '{${v.entries.map((e) => '"${e.key}":${of(e.value)}').join(',')}}',
        List() => v.isEmpty ? '[]' : '[${of(v.first)}${v.length > 1 ? '…' : ''}]',
        num() => '#',
        String() => '"…"',
        bool() => 'b',
        _ => 'null',
      };
  return of(value);
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
