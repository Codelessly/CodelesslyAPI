// The schema 2 → 3 migration's framework: what it does to any document, and
// the properties every step must keep (idempotent, total) over the
// repository's documents. Each step's own mappings are tested in
// test/migrate_steps_test.dart.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Json doc2(Map<String, Object?> nodes) => {
      'schema': 2,
      'roots': ['home'],
      'nodes': {
        'home': {'type': 'canvas', 'layout': {'width': 390, 'height': 844}, 'children': nodes.keys.toList()},
        ...nodes,
      },
    };

/// Every JSON file of the repository that holds a document.
Iterable<(String, Object?)> repositoryJson() sync* {
  for (final dir in ['test/fixtures', 'tool/reference/examples']) {
    for (final f in Directory(dir).listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.json')) continue;
      final json = jsonDecode(f.readAsStringSync());
      yield (f.path, json);
    }
  }
}

/// A random JSON value, nested up to [depth].
Object? randomJson(math.Random r, int depth) {
  const keys = ['schema', 'nodes', 'type', 'layout', 'drag', 'motion', 'track', 'actions', 'bind', 'states', 'x', 'loops'];
  switch (r.nextInt(depth <= 0 ? 5 : 8)) {
    case 0:
      return null;
    case 1:
      return r.nextBool();
    case 2:
      return r.nextInt(5) - 1;
    case 3:
      return r.nextDouble() * 100;
    case 4:
      return ['box', 'text', 'canvas', 'dismiss', 'reverse', '\${= x}', ''][r.nextInt(7)];
    case 5 || 6:
      return {for (var i = 0; i < r.nextInt(5); i++) keys[r.nextInt(keys.length)]: randomJson(r, depth - 1)};
    default:
      return [for (var i = 0; i < r.nextInt(4); i++) randomJson(r, depth - 1)];
  }
}

void main() {
  group('framework', () {
    test('a schema-2 document is migrated to schema 3 and says so', () {
      final report = MigrationReport(document: 'a.json');
      final out = migrate2to3(doc2({'box': {'type': 'box', 'layout': {}}}), report: report);
      expect(out['schema'], 3);
      expect(report.documents, ['a.json']);
    });

    test('a document without a schema is read as schema 2', () {
      expect(schemaOf({'nodes': {}}), 2);
      expect(migrate2to3({'roots': [], 'nodes': {}})['schema'], 3);
    });

    test('migrating a schema-3 document is a no-op (the same object)', () {
      final d = {'schema': 3, 'roots': <String>[], 'nodes': <String, Object?>{}};
      expect(identical(migrate2to3(d), d), isTrue);
    });

    test('the input is never changed', () {
      final d = doc2({'box': {'type': 'box', 'layout': {}}});
      final before = jsonEncode(d);
      migrate2to3(d);
      expect(jsonEncode(d), before);
    });

    test('a step that throws leaves the node as before the step, and is reported', () {
      final report = MigrationReport();
      final steps = [
        MigrationStep(id: 'test.half', description: 'writes, then throws', node: (n, s) {
          n['half'] = true;
          if (n['type'] == 'box') throw StateError('no');
        }),
      ];
      final out = migrate2to3(doc2({'box': {'type': 'box', 'layout': {}}}), report: report, steps: steps);
      final nodes = out['nodes'] as Map;
      expect((nodes['box'] as Map).containsKey('half'), isFalse);
      expect((nodes['home'] as Map)['half'], true);
      expect(report.unconvertible.single.step, 'test.half');
      expect(report.unconvertible.single.node, 'box');
    });

    test('unconvertible values are kept as legacy.<name> on the node and reported with what to write', () {
      final report = MigrationReport(document: 'd');
      final steps = [
        MigrationStep(id: 'test.drop', description: 'drops x', node: (n, s) {
          if (n.remove('x') case final Object v) s.unconvertible(n, 'x', v, instead: 'write y');
        }),
      ];
      final out = migrate2to3(doc2({'box': {'type': 'box', 'layout': {}, 'x': 4}}), report: report, steps: steps);
      expect(((out['nodes'] as Map)['box'] as Map)['legacy.x'], 4);
      final e = report.unconvertible.single;
      expect([e.document, e.node, e.path, e.old, e.instead], ['d', 'box', '/x', 4, 'write y']);
      // The node decodes and keeps it (in extra).
      final node = LayoutDocument.fromJson(out)['box']!;
      expect(node.extra['legacy.x'], 4);
    });

    test('a node alone migrates as a document node does', () {
      final n = migrateNode2to3({'type': 'box', 'layout': {}});
      expect(n, {'type': 'box', 'layout': {}});
    });

    test('the report round-trips and renders as Markdown', () {
      final report = MigrationReport(document: 'd')
        ..documents.add('d')
        ..add(const MigrationEntry(kind: MigrationEntryKind.behaviourChange, step: 's', document: 'd', node: 'n', message: 'm'));
      expect(MigrationReport.fromJson(jsonDecode(jsonEncode(report.toJson()))).toJson(), report.toJson());
      expect(migrationReportMarkdown(report), contains('| `s` | 0 | 0 | 1 | 1 |'));
    });
  });

  group('carriers', () {
    test('a publish bundle: model and layouts to schema 3; decoding migrates the same', () {
      final bundle = {
        'schema': 2,
        'model': {'schema': 2, 'projectId': 'p', 'layouts': {}},
        'layouts': {'l': doc2({})},
      };
      final report = MigrationReport(document: 'bundle');
      final out = migratePublish2to3(bundle, report: report);
      expect(out['schema'], 3);
      expect((out['model'] as Map)['schema'], 3);
      expect(((out['layouts'] as Map)['l'] as Map)['schema'], 3);
      expect(report.documents, ['bundle/l']);
      expect(PublishBundle.fromJson(bundle).toJson(), PublishBundle.fromJson(out).toJson());
      expect(PublishBundle.fromJson(bundle).toJson()['schema'], 3);
    });

    test('migrateJson2to3 finds documents anywhere and sets carriers to 3, leaving text payloads', () {
      final payload = jsonEncode({'definition': {'document': doc2({})}});
      final json = {
        'schema': 2,
        'id': 'Chip',
        'document': doc2({}),
        'versions': [
          {'schema': 2, 'payload': payload},
        ],
      };
      final out = migrateJson2to3(json) as Map;
      expect(out['schema'], 3);
      expect((out['document'] as Map)['schema'], 3);
      expect(((out['versions'] as List).single as Map)['schema'], 3);
      expect(((out['versions'] as List).single as Map)['payload'], payload);
    });
  });

  group('properties', () {
    test('total: never throws, on random JSON', () {
      final r = math.Random(7);
      for (var i = 0; i < 3000; i++) {
        final v = randomJson(r, 5);
        final doc = {'schema': 2, 'roots': ['a'], 'nodes': {'a': v, 'b': randomJson(r, 4)}};
        migrate2to3(doc);
        if (v is Map<String, Object?>) migrateNode2to3(v);
        migrateJson2to3(v);
        LayoutDocument.fromJson(doc);
      }
    });

    test('idempotent over the repository: migrating twice is migrating once, and re-encoding is a fixed point', () {
      var documents = 0;
      for (final (path, json) in repositoryJson()) {
        final once = migrateJson2to3(json);
        expect(jsonEncode(migrateJson2to3(once)), jsonEncode(once), reason: path);
        void each(Object? v) {
          if (isLayoutDocumentJson(v)) {
            documents++;
            final m = readMap(v)!;
            // The steps run again on a migrated document change nothing. A
            // document written in schema 3 is not run through the steps that
            // re-read a field the Flutter way (text.padding,
            // text.lineHeight): they write out what schema 2 did with it.
            final native = identical(json, once) || schemaOf(readMap(json)) >= 3 && path.contains('reference/examples');
            final steps = native ? schema3Steps.where((s) => !s.id.startsWith('text.')).toList() : null;
            final again = migrate2to3({...m, 'schema': 2}, steps: steps);
            expect(jsonEncode({...again, 'schema': m['schema']}), jsonEncode(m), reason: path);
            final encoded = LayoutDocument.fromJson(m, catalog: standardCatalog).toJson();
            expect(jsonEncode(LayoutDocument.fromJson(encoded, catalog: standardCatalog).toJson()), jsonEncode(encoded), reason: path);
            return;
          }
          if (v is Map) v.values.forEach(each);
          if (v is List) v.forEach(each);
        }

        each(once);
      }
      expect(documents, greaterThan(20));
    });
  });
}
