// The closure of the corpora (track B, step B2: docs/design/23-base-and-dictionary.md):
// of the words the writers reached for beyond the core, the share they defined
// themselves, the share that maps to a word we have, and the recurring words
// that have no definition that renders.
//
//   dart run tool/corpus_closure.dart --round10 <VOCABULARY-round-10.md>
//       --first <label>=<VOCABULARY.md>... --first-ds <label>=<VOCABULARY.md>...
//       [--out docs/design/base-inventory]
//
// --first-ds is a corpus whose writers were not asked to define their words:
// what resolved as a definition there is the design system's (Cards'
// vocabulary/*.txt), a word we have, not the writer's.
//
// Reads what the SDK's `tool/notation/notation.sh vocabulary` writes: for the
// first corpus, the VOCABULARY.md of a folder of answers (its table of every
// word by kind and how it resolved, its words we do not have, its primitives),
// run again at the release being measured; for round 10, the harvest across
// runs (its table of every word beyond the core, with how each resolved).
// Writes <out>/CORPUS.md.
import 'dart:io';

void main(List<String> args) {
  String? opt(String name) {
    final i = args.indexOf(name);
    return i < 0 || i + 1 >= args.length ? null : args[i + 1];
  }

  final firsts = <String, ({String path, bool ds})>{
    for (var i = 0; i < args.length - 1; i++)
      if (args[i] == '--first' || args[i] == '--first-ds')
        args[i + 1].split('=').first: (path: args[i + 1].substring(args[i + 1].indexOf('=') + 1), ds: args[i] == '--first-ds'),
  };
  final round10 = opt('--round10');
  final out = opt('--out') ?? 'docs/design/base-inventory';
  final md = StringBuffer()
    ..writeln('# The corpora against the base (generated)')
    ..writeln()
    ..writeln('Written by `tool/corpus_closure.dart` (track B, step B2; design note 23). Do not edit: run it again.')
    ..writeln()
    ..writeln('A word beyond the core is one a writer used that is not a core word of the notation. It is **defined by the '
        'writer** when its resolution is a definition (`define`, a page\'s or a site\'s) or a site\'s own component; it '
        '**maps to a word we have** when it is an alias, a design system\'s component or a universal word; it has **no '
        'definition that renders** when it is unknown (a placeholder, or left out), refused, a primitive (a labelled box '
        'stands in), or given and never read.');
  for (final e in firsts.entries) {
    _first(md, e.key, File(e.value.path).readAsStringSync().replaceAll('\r\n', '\n'), dsDefinitions: e.value.ds);
  }
  if (round10 != null) _round10(md, File(round10).readAsStringSync().replaceAll('\r\n', '\n'));
  Directory(out).createSync(recursive: true);
  File('$out/CORPUS.md').writeAsStringSync(md.toString());
  stdout.write(md);
}

List<List<String>> _table(String text, String heading) {
  final at = text.indexOf(heading);
  if (at < 0) return const [];
  final rows = <List<String>>[];
  var started = false;
  for (final line in text.substring(at + heading.length).split('\n')) {
    if (line.startsWith('## ')) break;
    if (!line.startsWith('|')) {
      if (started) break;
      continue;
    }
    started = true;
    final cells = line.split('|').map((c) => c.trim()).toList();
    if (cells.length < 3 || cells[1].startsWith('---')) continue;
    rows.add(cells.sublist(1, cells.length - 1));
  }
  return rows;
}

String _pct(num a, num b) => b == 0 ? '0%' : '${(100 * a / b).toStringAsFixed(1)}%';

void _first(StringBuffer md, String label, String text, {required bool dsDefinitions}) {
  final head = RegExp(r'^\d+ files, .*$', multiLine: true).firstMatch(text)?[0] ?? '';
  md
    ..writeln()
    ..writeln('## First corpus: $label')
    ..writeln()
    ..writeln(head)
    ..writeln()
    ..writeln(dsDefinitions
        ? "Its writers were not asked to define the words they used: what resolved as a definition is the design system's (Cards), counted as a word we have."
        : "Its writers were asked to define the words they used: what resolved as a definition is theirs, or the design system's (Cards; the table does not tell them apart), or a site's component.")
    ..writeln();
  final rows = _table(text, '## Every word used, by kind and how it resolved');
  if (rows.isEmpty) {
    md.writeln('(no table of words by kind)');
    return;
  }
  final header = rows.first;
  int col(String name) => header.indexOf(name);
  md
    ..writeln('| kind | words | core | beyond the core | defined by the writer | maps to a word we have | no definition that renders |')
    ..writeln('|---|---|---|---|---|---|---|');
  for (final r in rows.skip(1)) {
    int n(String c) => col(c) < 0 ? 0 : int.tryParse(r[col(c)]) ?? 0;
    final words = n('words'), core = n('core');
    final beyond = words - core;
    final defined = dsDefinitions ? n('site') : n('definition') + n('site');
    final maps = n('component') + n('alias') + n('universal') + (dsDefinitions ? n('definition') : 0);
    final none = n('primitive') + n('unread') + n('refused') + n('unknown');
    md.writeln('| ${r[0]} | $words | $core | $beyond | $defined (${_pct(defined, beyond)}) | $maps (${_pct(maps, beyond)}) | $none (${_pct(none, beyond)}) |');
  }
  final unknown = _table(text, '## Words we do not have, by how many files reached for them');
  if (unknown.length > 1) {
    md
      ..writeln()
      ..writeln('Types we do not have, by files (the first twenty): ')
      ..writeln()
      ..writeln(unknown.skip(1).take(20).map((r) => '`${r[2]}` (${r[0]} files, ${r[1]} uses)').join(', '));
  }
  final primitives = _table(text, '## Primitives declared');
  if (primitives.length > 1) {
    md
      ..writeln()
      ..writeln('Primitives the answers declared: ${primitives.length - 1}: ${primitives.skip(1).map((r) => '`${RegExp(r'[A-Z][A-Za-z0-9]*').stringMatch(r[1].replaceFirst('primitive', '')) ?? r[1]}`').toSet().join(', ')}.');
  }
}

void _round10(StringBuffer md, String text) {
  final rows = _table(text, '## Every word beyond the core');
  final header = rows.first;
  int col(String name) => header.indexOf(name);
  final words = <({String kind, String word, int runs, int uses, Map<String, int> resolved})>[];
  for (final r in rows.skip(1)) {
    final resolved = <String, int>{};
    for (final p in r[col('resolved')].split(',')) {
      final m = RegExp(r'^\s*([a-z ]+?)\s+(\d+)\s*$').firstMatch(p);
      if (m != null) resolved[m[1]!] = (resolved[m[1]!] ?? 0) + int.parse(m[2]!);
    }
    words.add((kind: r[col('kind')], word: r[col('word')].replaceAll('`', ''), runs: int.tryParse(r[col('runs')]) ?? 0, uses: int.tryParse(r[col('uses')]) ?? 0, resolved: resolved));
  }
  const defined = {'site', 'definition'};
  const maps = {'core', 'alias', 'component', 'universal'};
  String classOf(Map<String, int> r) {
    final d = r.entries.where((e) => defined.contains(e.key)).fold<int>(0, (n, e) => n + e.value);
    final m = r.entries.where((e) => maps.contains(e.key)).fold<int>(0, (n, e) => n + e.value);
    final rest = r.entries.where((e) => !defined.contains(e.key) && !maps.contains(e.key)).fold<int>(0, (n, e) => n + e.value);
    if (d >= m && d >= rest && d > 0) return 'defined';
    if (m >= rest && m > 0) return 'maps';
    return 'none';
  }

  md
    ..writeln()
    ..writeln('## Round 10 (116 runs)')
    ..writeln()
    ..writeln('From the harvest\'s table of every word beyond the core (${words.length} rows: a word once per kind; a parameter, '
        'flag or event once per type it is on). A word is counted under what most of its uses resolved to; uses are '
        'counted under what each resolved to.')
    ..writeln()
    ..writeln('| kind | words | defined by the writer | maps to a word we have | no definition that renders | uses | uses defined | uses mapped | uses with none |')
    ..writeln('|---|---|---|---|---|---|---|---|---|');
  final kinds = [...{for (final w in words) w.kind}, 'all'];
  for (final k in kinds) {
    final ws = [for (final w in words) if (k == 'all' || w.kind == k) w];
    final c = {for (final x in const ['defined', 'maps', 'none']) x: ws.where((w) => classOf(w.resolved) == x).length};
    var ud = 0, um = 0, un = 0;
    for (final w in ws) {
      for (final e in w.resolved.entries) {
        if (defined.contains(e.key)) {
          ud += e.value;
        } else if (maps.contains(e.key)) {
          um += e.value;
        } else {
          un += e.value;
        }
      }
    }
    final all = ud + um + un;
    md.writeln('| $k | ${ws.length} | ${c['defined']} (${_pct(c['defined']!, ws.length)}) | ${c['maps']} (${_pct(c['maps']!, ws.length)}) | ${c['none']} (${_pct(c['none']!, ws.length)}) | '
        '$all | $ud (${_pct(ud, all)}) | $um (${_pct(um, all)}) | $un (${_pct(un, all)}) |');
  }
  final none = [for (final w in words) if (w.resolved.entries.any((e) => !defined.contains(e.key) && !maps.contains(e.key))) w]
    ..sort((a, b) => b.runs != a.runs ? b.runs.compareTo(a.runs) : b.uses.compareTo(a.uses));
  md
    ..writeln()
    ..writeln('### The recurring words some uses of which have no definition that renders (the first twenty, by runs)')
    ..writeln()
    ..writeln('| kind | word | runs | uses | resolved |')
    ..writeln('|---|---|---|---|---|');
  for (final w in none.take(20)) {
    md.writeln('| ${w.kind} | `${w.word}` | ${w.runs} | ${w.uses} | ${w.resolved.entries.map((e) => '${e.key} ${e.value}').join(', ')} |');
  }
  final typesNone = [for (final w in none) if (w.kind == 'type' && classOf(w.resolved) == 'none') w];
  md
    ..writeln()
    ..writeln('Types with no definition that renders in most of their uses: ${typesNone.length}: '
        '${typesNone.map((w) => '`${w.word}` (${w.runs})').join(', ')}.');
}
