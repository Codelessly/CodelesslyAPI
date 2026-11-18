// The closure test's report (track B, step B2: docs/design/23-base-and-dictionary.md).
//
//   dart run tool/dictionary_closure.dart [--out docs/design/base-inventory] [--dump <dir>] [--words A,B]
//   dart run tool/dictionary_closure.dart --harvest <CodelesslySDK folder>
//
// Each definition of dictionary/*.txt is a word the expander writes out in
// Dart today (kind b of the inventory), written in the notation's own
// `define` form. Its uses (dictionary/uses/<Word>.txt: real screens of the
// first corpus and blocks of the notation reference, each after a `### where`
// line, written by --harvest; and dictionary/uses/<Word>.extra.txt, uses
// written for a shape no answer has) are expanded through the code and
// through the definition (renamed: tool/dictionary/closure.dart) at 1440, 834
// and 390, and compared node by node. Writes <out>/CLOSURE.md and
// <out>/closure.json; --dump writes each pair's documents (1440 wide) for
// rendering: <dir>/code/<word><n>.json and <dir>/dict/<word><n>.json, one
// canvas each (its id the file name), and <dir>/uses.txt.
//
// Run from the package root of an LF copy.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/notation.dart';

import 'dictionary/closure.dart';

void main(List<String> args) {
  String? opt(String name) {
    final i = args.indexOf(name);
    return i < 0 || i + 1 >= args.length ? null : args[i + 1];
  }

  final files = readDictionary('dictionary');
  if (opt('--harvest') case final String sdk) {
    _harvest(sdk, files);
    return;
  }
  final out = opt('--out') ?? 'docs/design/base-inventory';
  final dump = opt('--dump');
  // --words A,B: only these words (and no family run).
  final only = opt('--words')?.split(',').toSet();
  final report = <Map<String, Object?>>[];
  final md = StringBuffer()
    ..writeln('# The closure test (generated)')
    ..writeln()
    ..writeln('Written by `tool/dictionary_closure.dart` (track B, step B2; design note 23). Do not edit: run it again.')
    ..writeln()
    ..writeln('Each word below is written out in Dart by the expander today. `dictionary/<Word>.txt` writes it in the '
        'notation\'s `define` form, in base words only. Each use (`dictionary/uses/`) is expanded once through the code '
        'and once through the definition (the word renamed `<Word>Dict`, since a built-in word wins over a definition '
        'of its name), at 1440, 834 and 390 wide, with the open vocabulary and no design system, and the two documents '
        'are compared node by node, ids aside (`tool/dictionary/closure.dart`).')
    ..writeln();
  final words = <String>{for (final f in files.values) ...f.words};
  final summary = <String>[];
  final details = StringBuffer();
  void run(String label, String usesFrom, Set<String> renamed) {
    final uses = usesOf(usesFrom);
    if (uses.isEmpty) {
      summary.add('| `$label` | no use | | | | |');
      return;
    }
    final c = closure(label, uses, files.values, renamed: renamed);
    final equal = c.results.where((r) => r.comparison.equal && r.issues.isEmpty).length;
    final spelt = c.results.where((r) => r.spelt.equal && r.issues.isEmpty).length;
    final nodes = c.results.fold<int>(0, (n, r) => n + r.comparison.nodesA);
    final same = c.results.fold<int>(0, (n, r) => n + r.comparison.same);
    final sameSpelt = c.results.fold<int>(0, (n, r) => n + r.spelt.same);
    final verdict = c.closes ? '**closes**' : c.closesUpToSpelling ? '**closes** up to spelling' : 'does not close';
    summary.add('| `$label` | $verdict | $equal of ${c.results.length} | $spelt | $same of $nodes | $sameSpelt |');
    report.add({
      'word': label,
      'renamed': renamed.toList()..sort(),
      'closes': c.closes,
      'closesUpToSpelling': c.closesUpToSpelling,
      'equal': equal,
      'equalUpToSpelling': spelt,
      'expansions': c.results.length,
      'nodes': nodes,
      'same': same,
      'results': [
        for (final r in c.results)
          {'from': r.from, 'width': r.width, 'equal': r.comparison.equal, 'equalUpToSpelling': r.spelt.equal, 'summary': r.spelt.summary, 'samples': r.spelt.samples, 'issues': r.issues},
      ],
    });
    details
      ..writeln()
      ..writeln('### $label${renamed.length > 1 ? ' (renamed together: ${(renamed.toList()..sort()).join(', ')})' : ''}')
      ..writeln();
    for (final r in c.results) {
      details.writeln('- ${r.from} @${r.width.round()}: ${r.comparison.equal ? 'equal' : r.spelt.equal ? 'equal up to spelling' : r.spelt.summary}${r.issues.isEmpty ? '' : '; issues: ${r.issues.take(2).join(' / ')}'}');
      for (final s in r.spelt.samples.take(r.spelt.equal ? 0 : 3)) {
        details.writeln('  - `${s.replaceAll('`', "'")}`');
      }
    }
    if (dump != null) {
      // One canvas per use, named after the word and the use, so that a
      // folder of them is one site of pages: code/ and dict/ hold the same
      // names, and a render of dict/ compares with one of code/.
      var n = 0;
      final defs = renamedDefinitions(files.values, words);
      for (final u in uses) {
        final id = '${label.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase()}_${n++}';
        final base = NotationOptions(width: 1440, screen: id);
        Directory('$dump/code').createSync(recursive: true);
        Directory('$dump/dict').createSync(recursive: true);
        File('$dump/code/$id.json').writeAsStringSync(jsonEncode(expandPage(u.text, base: base)));
        File('$dump/dict/$id.json').writeAsStringSync(jsonEncode(expandPage(renameWords(u.text, renamed), definitions: defs, base: base)));
        File('$dump/uses.txt').writeAsStringSync('$id ${u.from}\n', mode: FileMode.append);
      }
    }
  }

  for (final w in words.toList()..sort()) {
    if (only == null || only.contains(w)) run(w, w, {w});
  }
  // The frame family, renamed together, over the uses of its frames.
  for (final w in const ['App', 'Page']) {
    if (only == null) run('$w (family)', w, frameFamily.intersection(words));
  }
  md
    ..writeln('| word | | expansions the same | up to spelling | nodes the same | up to spelling |')
    ..writeln('|---|---|---|---|---|---|');
  summary.forEach(md.writeln);
  md
    ..writeln()
    ..writeln('A use counts as the same when its two documents are equal and the definition\'s side has no issue the code\'s has not. '
        '"Nodes the same" counts the code\'s nodes that the definition\'s document has, equal, at the same place.')
    ..writeln()
    ..writeln('## By use')
    ..write(details);
  final problems = readDefinitionsProblems(files.values);
  if (problems.isNotEmpty) {
    md
      ..writeln()
      ..writeln('## Problems in the definitions')
      ..writeln();
    for (final p in problems) {
      md.writeln('- $p');
    }
  }
  Directory(out).createSync(recursive: true);
  File('$out/CLOSURE.md').writeAsStringSync(md.toString());
  File('$out/closure.json').writeAsStringSync('${const JsonEncoder.withIndent(' ').convert(report)}\n');
  stdout.writeln(summary.join('\n'));
}

/// The uses of each dictionary word: up to [_screens] screens of the first
/// corpus that write it as a line's first word (the ones with the most shapes
/// of it not yet taken, then the shortest), and up to two ```notation blocks
/// of the reference that do.
const _screens = 4;

void _harvest(String sdk, Map<String, DictionaryFile> files) {
  final screens = <({String from, String text})>[];
  for (final top in const ['corpus', 'corpus-define']) {
    final dir = Directory('$sdk/tool/vocabulary/$top');
    if (!dir.existsSync()) continue;
    final answers = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.replaceAll(r'\', '/').contains('/answers/') && f.path.endsWith('.txt')).toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final f in answers) {
      final rel = f.path.replaceAll(r'\', '/').substring(sdk.length).replaceFirst(RegExp('^/'), '');
      String? name;
      final lines = <String>[];
      void flush() {
        // A screen: its lines up to the next `### `, without the answer's
        // definitions (a `define` at the margin ends it).
        final cut = lines.indexWhere((l) => RegExp(r'^(define|primitive)\s').hasMatch(l));
        final body = (cut < 0 ? lines : lines.sublist(0, cut)).join('\n').trimRight();
        if (body.trim().isNotEmpty) screens.add((from: '$rel${name == null ? '' : ' ### $name'}', text: '$body\n'));
        lines.clear();
      }

      for (final l in f.readAsStringSync().replaceAll('\r\n', '\n').split('\n')) {
        if (l.startsWith('### ')) {
          flush();
          name = l.substring(4).trim();
        } else {
          lines.add(l);
        }
      }
      flush();
    }
  }
  final blocks = <({String from, String text})>[];
  for (final f in Directory('docs/reference/notation').listSync().whereType<File>().where((f) => f.path.endsWith('.md')).toList()..sort((a, b) => a.path.compareTo(b.path))) {
    final text = f.readAsStringSync().replaceAll('\r\n', '\n');
    var n = 0;
    for (final m in RegExp(r'```notation[^\n]*\n([\s\S]*?)```').allMatches(text)) {
      n++;
      blocks.add((from: 'docs/reference/notation/${f.uri.pathSegments.last} block $n', text: m[1]!));
    }
  }
  Directory('dictionary/uses').createSync(recursive: true);
  for (final word in {for (final f in files.values) ...f.words}.toList()..sort()) {
    final head = RegExp('^\\s*${RegExp.escape(word)}(?=[\\s.#]|\$)', multiLine: true);
    Set<String> shapes(String text) => {
          for (final m in head.allMatches(text))
            for (final p in LineParts.of(text.substring(m.start).split('\n').first.trim())?.parts ?? const <LinePart>[])
              p.kind == 'pair' ? 'key:${p.key}' : p.kind == 'word' ? 'flag:${p.raw.startsWith('@') ? '@' : p.raw}' : p.kind,
        };
    final candidates = [for (final s in screens) if (head.hasMatch(s.text) && s.text.split('\n').length <= 160) s];
    final taken = <({String from, String text})>[];
    final covered = <String>{};
    while (taken.length < _screens && candidates.isNotEmpty) {
      candidates.sort((a, b) {
        final na = shapes(a.text).difference(covered).length, nb = shapes(b.text).difference(covered).length;
        if (na != nb) return nb.compareTo(na);
        final la = a.text.length, lb = b.text.length;
        return la != lb ? la.compareTo(lb) : a.from.compareTo(b.from);
      });
      final next = candidates.removeAt(0);
      if (taken.isNotEmpty && shapes(next.text).difference(covered).isEmpty) break;
      taken.add(next);
      covered.addAll(shapes(next.text));
    }
    taken.addAll([for (final b in blocks) if (head.hasMatch(b.text)) b].take(2));
    final out = StringBuffer()
      ..writeln('// Uses of $word: screens of the first corpus and blocks of the notation reference that write it,')
      ..writeln('// taken by tool/dictionary_closure.dart --harvest (the most shapes of it first). Do not edit: run it again.');
    for (final t in taken) {
      out
        ..writeln('### ${t.from}')
        ..write(t.text.endsWith('\n') ? t.text : '${t.text}\n');
    }
    File('dictionary/uses/$word.txt').writeAsStringSync(out.toString());
    stdout.writeln('$word: ${taken.length} uses');
  }
}
