// The committed reference (docs/reference) is what the generator makes of
// the declarations today; its links and anchors resolve; every declared
// item is documented on exactly one page; every page has the same six
// sections; every JSON example in it is valid; the base is within its size.
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

import '../tool/reference/src/areas.dart';
import '../tool/reference/src/reference.dart';

void main() {
  final root = Directory.current.path;
  final dir = '$root/docs/reference';
  String read(String f) => File('$dir/$f').readAsStringSync();
  final mdFiles = [
    for (final f in Directory(dir).listSync().whereType<File>())
      if (f.path.endsWith('.md')) f.uri.pathSegments.last,
  ]..sort();
  final pageFiles = [for (final p in featurePages) p.file, '$valuesPage.md'];

  test('docs/reference is up to date (dart run tool/reference/generate.dart)', () {
    final files = buildReference(root);
    final stale = [
      for (final e in files.entries)
        if (!File('$root/${e.key}').existsSync() || File('$root/${e.key}').readAsStringSync() != e.value) e.key,
    ];
    expect(stale, isEmpty, reason: 'Regenerate: dart run tool/reference/generate.dart');
    // Nothing generated earlier and no longer is lingers.
    final generated = {for (final k in files.keys) if (k.startsWith('docs/reference/')) k.substring('docs/reference/'.length)};
    final lingering = [
      for (final f in Directory(dir).listSync().whereType<File>())
        if (!generated.contains(f.uri.pathSegments.last) && f.uri.pathSegments.last != '_authoring-friction.md') f.uri.pathSegments.last,
    ];
    expect(lingering, isEmpty, reason: 'Files the generator no longer writes');
  });

  test('every example document is valid, without warnings', () {
    final docs = [
      for (final f in Directory('$root/tool/reference/examples').listSync(recursive: true).whereType<File>())
        if (f.path.endsWith('.json') && !f.path.contains('/sections/') && !f.path.contains('/theme/')) f,
    ];
    expect(docs.length, greaterThan(20));
    for (final f in docs) {
      final diagnostics = validateDocument(jsonDecode(f.readAsStringSync()));
      expect(diagnostics.map((d) => '$d'), isEmpty, reason: f.path);
    }
    // The theme example is a site: its page names the manifest's theme.
    Json t(String f) => jsonDecode(File('$root/tool/reference/examples/theme/$f').readAsStringSync()) as Json;
    final manifest = SiteManifest.fromJson(t('site.json'));
    expect(validateProject({'home.json': t('home.json')}, manifest: manifest).map((d) => '$d'), isEmpty);
  });

  test('every JSON block of every page parses, and every whole document in them is valid', () {
    var documents = 0, blocks = 0;
    for (final f in [...pageFiles, 'STARTER.md', 'RUNTIME_STARTER.md']) {
      for (final m in RegExp(r'```json\n(.*?)\n```', dotAll: true).allMatches(read(f))) {
        blocks++;
        Object? json;
        try {
          json = jsonDecode(m[1]!);
        } on FormatException {
          json = jsonDecode('{${m[1]}}'); // a fragment: one or more keys of an object
        }
        // A site manifest (site.json) is not a layout document.
        if (json is Map && json['schema'] == kSchemaVersion && !json.containsKey('pages')) {
          documents++;
          expect(validateDocument(json).map((d) => '$d'), isEmpty, reason: '$f: ${m[1]}');
        }
      }
    }
    expect(blocks, greaterThan(50));
    expect(documents, greaterThan(25));
  });

  test('every link and anchor resolves, in the folder and in API_REFERENCE.md', () {
    final anchorsOf = <String, Set<String>>{
      for (final f in mdFiles) f: {for (final m in RegExp(r'<a id="([^"]+)"></a>').allMatches(read(f))) m[1]!},
    };
    final broken = <String>[];
    for (final f in mdFiles) {
      final text = read(f).replaceAll(RegExp(r'```.*?```', dotAll: true), '').replaceAll(RegExp(r'`[^`\n]*`'), '');
      for (final m in RegExp(r'\]\(([^)\s]+)\)').allMatches(text)) {
        final target = m[1]!;
        if (target.startsWith('http')) continue;
        final hash = target.indexOf('#');
        final file = hash < 0 ? target : target.substring(0, hash);
        final anchor = hash < 0 ? null : target.substring(hash + 1);
        final resolved = file.isEmpty ? f : file;
        if (!File('$dir/$resolved').existsSync()) {
          broken.add('$f → $target (no file)');
        } else if (anchor != null && !(anchorsOf[resolved] ?? const {}).contains(anchor)) {
          broken.add('$f → $target (no anchor)');
        }
      }
    }
    expect(broken, isEmpty);
  });

  test('every declared item is documented on exactly one page, and the A–Z links to it', () {
    final catalog = jsonDecode(read('catalog.json')) as Map<String, dynamic>;
    final defined = <String, List<String>>{};
    for (final f in pageFiles) {
      for (final m in RegExp(r'<a id="([^"]+)"></a>').allMatches(read(f))) {
        (defined[m[1]!] ??= []).add(f);
      }
    }
    final expected = <String>[
      for (final t in (catalog['nodeTypes'] as Map).keys) 'node-$t',
      for (final b in catalog['behaviors']['fields'] as List) 'behavior-${b['key']}',
      for (final t in catalog['triggers']['types'] as List) 'trigger-${t['type']}',
      for (final a in (catalog['actions']['types'] as Map).keys) 'action-$a',
      for (final v in (catalog['valueTypes'] as Map).keys) 'type-$v',
      for (final m in (catalog['objectTypes'] as Map).keys) 'type-$m',
      for (final e in (catalog['enums'] as Map).keys) 'enum-$e',
      for (final fn in catalog['formulas']['functions'] as List) 'fn-${fn['name']}',
    ];
    final notOnce = [for (final a in expected.toSet()) if ((defined[a] ?? const []).length != 1) '$a: ${defined[a] ?? 'nowhere'}'];
    expect(notOnce, isEmpty);
    final az = read('index.md');
    final missing = [for (final a in expected.toSet()) if (!az.contains('.md#$a)')) a];
    expect(missing, isEmpty, reason: 'not in the A–Z');
    // Every catalog item names its page.
    for (final e in (catalog['nodeTypes'] as Map).entries) {
      expect(defined['node-${e.key}']!.single, (e.value['docs'] as String).split('#').first);
    }
    // ignore: avoid_print
    print('coverage: ${expected.toSet().length} items, each on exactly one of ${pageFiles.length} pages');
  });

  test('every page has the six sections, in order', () {
    const sections = ['When to use', 'Minimal example', 'Reference', 'Patterns', 'Pitfalls', 'See also'];
    for (final f in pageFiles) {
      final h2 = [for (final m in RegExp(r'^## (.+)$', multiLine: true).allMatches(read(f))) m[1]!];
      expect(h2, sections, reason: f);
    }
  });

  test('the base: one assembler, two forms, within ~6k words', () {
    final files = read('STARTER.md'), runtime = read('RUNTIME_STARTER.md');
    int words(String s) => RegExp(r'\S+').allMatches(s).length;
    // ignore: avoid_print
    print('base: files form ${words(files)} words, ${files.length} characters (≈ ${(files.length / 3.5).round()} tokens); '
        'runtime form ${words(runtime)} words, ${runtime.length} characters (≈ ${(runtime.length / 3.5).round()} tokens)');
    expect(words(files), lessThan(6200));
    expect(words(runtime), lessThan(6200));
    // The forms share every section but their envelopes.
    List<String> headings(String s) => [for (final m in RegExp(r'^## (.+)$', multiLine: true).allMatches(s)) m[1]!];
    final shared = headings(files).toSet().intersection(headings(runtime).toSet());
    expect(shared.length, greaterThanOrEqualTo(12));
    expect(headings(files).toSet().difference(shared), {'Checking your work', 'Sites and components as files'});
    expect(headings(runtime).toSet().difference(shared), {'Answering', 'Ops', 'Examples'});
    expect(runtime, isNot(contains('.md')));
  });

  test('ui_docs is the same map: every page, section and runtime link resolves, sized for a tool result', () {
    final runtime = read('RUNTIME_STARTER.md');
    final topics = {
      for (final m in RegExp(r'ui_docs "([\w.-]+)"').allMatches(runtime)) m[1]!,
      for (final m in RegExp(r'^\| [^|]+ \| "([\w.-]+)" \|$', multiLine: true).allMatches(runtime)) m[1]!,
      for (final p in docPages) ...[p.id, for (final s in p.sections) s.id],
    };
    expect(topics.length, greaterThan(150));
    for (final t in topics) {
      final answer = docsTopic(t, profile: TrustProfile.agentApps);
      expect(answer, isNot(startsWith('No topic')), reason: t);
      expect(answer.length, lessThan(4200), reason: '$t: ${answer.length} characters');
    }
    final index = jsonDecode(read('index.json')) as Map;
    for (final t in index['topics'] as List) {
      expect(File('$dir/${t['file']}').existsSync(), isTrue);
    }
  });

  test('the catalog lists every diagnostic code and every node type', () {
    final catalog = jsonDecode(read('catalog.json')) as Map;
    expect((catalog['diagnostics'] as List).length, Codes.all.length);
    expect((catalog['nodeTypes'] as Map).length, greaterThan(60));
  });
}
