// The edit operations: decoding (lenient, with typed diagnostics), applying
// with per-op validation and rejection, forward references while a stream
// builds a document, inverse ops, revisions, the trust profile, the outline
// and the tool schemas.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

LayoutDocument _page(String name) =>
    LayoutDocument.fromJson(jsonDecode(File('test/fixtures/edit/$name.json').readAsStringSync()), catalog: standardCatalog);

final _empty = LayoutDocument(catalog: Catalog.core);

Json _text(String text) => {
      'type': 'text',
      'layout': {'width': {'hug': 80}, 'height': {'hug': 20}},
      'props': {'text': text, 'style': {'fontSize': 14, 'color': '#FF111827'}},
    };

Json _column(List<String> children) => {
      'type': 'column',
      'children': children,
      'layout': {'width': {'fill': 390}, 'height': {'hug': 100}},
    };

const _canvas = {
  'type': 'canvas',
  'slots': {'body': 'page'},
  'layout': {'width': 390, 'height': 844},
};

/// A small UI: canvas → page column → two texts.
List<EditOp> _small() => [
      const RootsOp(['home']),
      const SetOp('home', _canvas),
      SetOp('page', _column(['a', 'b'])),
      SetOp('a', _text('One')),
      SetOp('b', _text('Two')),
    ];

void main() {
  group('decode', () {
    test('each op from its JSON, and back', () {
      for (final spec in EditOp.specs) {
        final d = decodeOps({'ops': [spec.example]});
        expect(d.diagnostics.where((x) => x.error), isEmpty, reason: spec.op);
        expect(d.ops.single.$2.op, spec.op);
        expect(d.ops.single.$2.toJson(), spec.example, reason: spec.op);
      }
    });

    test('lenient: aliases, remove by id, a type-less op with a node, numbers as text, a node carrying its id', () {
      final d = decodeOps([
        {'op': 'delete', 'id': 'x'},
        {'op': 'Update', 'id': 'y', 'patch': {'visible': false}},
        {'id': 'z', 'node': _text('hi')},
        {'op': 'move', 'id': 'z', 'parent': 'p', 'index': '2'},
        {'op': 'set', 'node': {'id': 'w', ..._text('w')}},
      ]);
      expect(d.diagnostics, isEmpty);
      expect([for (final (_, o) in d.ops) o.op], ['remove', 'patch', 'set', 'move', 'set']);
      expect((d.ops[3].$2 as MoveOp).index, 2);
      expect((d.ops[4].$2 as SetOp).id, 'w');
      expect((d.ops[4].$2 as SetOp).node.containsKey('id'), isFalse);
    });

    test('malformed ops: typed diagnostics with the op index, the rest decode', () {
      final d = decodeOps({
        'ops': [
          'nope',
          {'op': 'sett', 'id': 'a'},
          {'op': 'patch', 'id': 'a'},
          {'op': 'set', 'id': 3.5, 'node': 'x'},
          {'op': 'remove', 'ids': ['a']},
          {'op': 'move', 'id': 'a', 'parnt': 'b'},
        ],
      });
      final codes = {for (final x in d.diagnostics) if (x.error) (x.op, x.code)};
      expect(codes, containsAll({(0, 'invalid_op'), (1, 'invalid_op'), (2, 'missing_field'), (3, 'wrong_type'), (5, 'missing_field')}));
      expect(d.diagnostics.firstWhere((x) => x.op == 1).suggestion, 'set');
      expect(d.diagnostics.firstWhere((x) => x.op == 5 && !x.error).suggestion, 'parent');
      expect([for (final (i, _) in d.ops) i], [4]);
    });

    test('a set with nodes is several sets with the same index', () {
      final d = decodeOps({
        'ops': [
          {'op': 'set', 'nodes': {'a': _text('A'), 'b': _text('B')}},
        ],
      });
      expect([for (final (i, o) in d.ops) '$i:${(o as SetOp).id}'], ['0:a', '0:b']);
    });
  });

  group('apply', () {
    test('a stream of sets builds the UI; children listed early are pending until they arrive', () {
      var doc = _empty;
      final pendings = <Set<String>>[];
      for (final op in _small()) {
        final r = applyOps(doc, [op], catalog: Catalog.core);
        expect(r.errors, isEmpty, reason: '$op');
        doc = r.document;
        pendings.add(r.pending);
      }
      expect(pendings, [
        {'home'},
        {'page'},
        {'a', 'b'},
        {'b'},
        <String>{},
      ]);
      expect(doc.parentOf('a'), 'page');
      expect(endOfStream(doc), isEmpty);
    });

    test('what never arrived is dangling at the end of the stream', () {
      final r = applyOps(_empty, _small().take(4).toList(), catalog: Catalog.core);
      expect(r.pending, {'b'});
      expect([for (final d in endOfStream(r.document)) d.code], ['dangling_child']);
    });

    test('a set placed under a parent, in a slot, at an index; a set of an existing id is a replace', () {
      var r = applyOps(_empty, _small(), catalog: Catalog.core);
      r = applyOps(r.document, [
        SetOp('c', _text('Zero'), parent: 'page', index: 0),
        SetOp('a', _text('One again')),
      ], catalog: Catalog.core);
      expect(r.errors, isEmpty);
      expect(r.created, {'c'});
      expect(r.document['page']!.children, ['c', 'a', 'b']);
      expect(r.changed, {'c', 'a', 'page'});
    });

    test('a rejected op leaves the document as it was; the others apply', () {
      final base = applyOps(_empty, [..._small(), SetOp('inner', _column([]), parent: 'page')], catalog: Catalog.core).document;
      final r = applyOps(base, [
        const PatchOp('a', {'props': {'text': 'Changed'}}),
        const PatchOp('nope', {'visible': false}),
        const PatchOp('a', {'children': ['b']}),
        const MoveOp('page', 'inner'),
        SetOp('page', _column(['a', 'inner'])),
        const MoveOp('a', 'b'),
        SetOp('d', _text('d'), parent: 'missing'),
        SetOp('e', _column(['b'])),
        const MoveOp('home', 'page'),
        SetOp('f', {..._text('f'), 'props': {'txt': 'typo'}}),
        SetOp('g', {..._text('g'), 'props': {'text': 'g', 'maxLines': 'two'}}),
      ], catalog: Catalog.core);
      expect(r.applied, [0]);
      final codes = {for (final d in r.errors) (d.op, d.code)};
      expect(codes, containsAll({
        (1, 'unknown_id'),
        (2, 'structural_key_in_patch'),
        (3, 'cycle'),
        (4, 'would_orphan'),
        (5, 'invalid_parent'),
        (6, 'unknown_id'),
        (7, 'multiple_parents'),
        (8, 'canvas_as_child'),
        (9, 'unknown_prop'),
        (10, 'wrong_type'),
      }));
      expect(r.errors.firstWhere((d) => d.code == 'unknown_prop').suggestion, 'text');
      // Only the one patch changed anything.
      expect(r.changed, {'a'});
      expect(r.document['page'], base['page']);
      expect(r.document['b'], base['b']);
    });

    test('atomic: one bad op rejects the batch', () {
      final base = applyOps(_empty, _small(), catalog: Catalog.core).document;
      final r = applyOps(base, {
        'atomic': true,
        'ops': [
          {'op': 'patch', 'id': 'a', 'patch': {'props': {'text': 'x'}}},
          {'op': 'patch', 'id': 'zz', 'patch': {'visible': false}},
        ],
      }, catalog: Catalog.core);
      expect(r.applied, isEmpty);
      expect(r.rejected, [0, 1]);
      expect(identical(r.document, base), isTrue);
    });

    test('remove takes the subtree and detaches it; move reorders', () {
      var doc = applyOps(_empty, [..._small(), SetOp('box', _column(['inner']), parent: 'page'), SetOp('inner', _text('in'))],
              catalog: Catalog.core)
          .document;
      var r = applyOps(doc, [const MoveOp('b', 'page', index: 0)], catalog: Catalog.core);
      expect(r.document['page']!.children, ['b', 'a', 'box']);
      r = applyOps(r.document, [
        const RemoveOp(['box', 'gone'])
      ], catalog: Catalog.core);
      expect(r.applied, [0]);
      expect(r.document['inner'], isNull);
      expect(r.document['page']!.children, ['b', 'a']);
      expect([for (final w in r.warnings) w.code], ['unknown_id']);
      doc = r.document;
    });

    test('vars: set a value, declare, remove; a value its type cannot hold is rejected', () {
      var r = applyOps(_empty, [
        ..._small(),
        const VarsOp('home', set: {
          'annual': {'type': 'boolean', 'value': false},
          'count': {'type': 'integer', 'value': 1},
        }),
      ], catalog: Catalog.core);
      expect(r.errors, isEmpty);
      r = applyOps(r.document, [
        const VarsOp('home', set: {'annual': true}),
        const VarsOp('home', set: {'count': 'many'}),
        const VarsOp('home', remove: ['count']),
        const VarsOp('nowhere', set: {'x': 1}),
      ], catalog: Catalog.core);
      expect(r.applied, [0, 2]);
      expect({for (final d in r.errors) (d.op, d.code)}, {(1, 'invalid_variable'), (3, 'unknown_id')});
      final vars = readList(readMap(r.document.extra['variables'])!['home'])!;
      expect(vars, [
        {'type': 'boolean', 'value': true, 'name': 'annual'}
      ]);
    });

    test('inverse ops undo a batch exactly, applied atomically', () {
      final page = _page('saas_pricing');
      final ids = page.nodes.keys.toList();
      final someText = page.nodes.values.firstWhere((n) => n.type == 'text').id;
      final someColumn = page.nodes.values.where((n) => n.type == 'column' && n.children.length > 1).last;
      final r = applyOps(page, [
        PatchOp(someText, const {'props': {'text': 'Changed'}}),
        MoveOp(someColumn.children.last, someColumn.id, index: 0),
        RemoveOp([someColumn.children.first]),
        SetOp('added', _text('New'), parent: someColumn.id, index: 1),
        const SetOp('addedBox', {'type': 'column', 'layout': {'width': 10, 'height': 10}}),
        MoveOp(ids.firstWhere((id) => page[id]!.type == 'text' && page.parentOf(id) != someColumn.id), 'addedBox'),
        const MoveOp('addedBox', 'added'),
      ], catalog: standardCatalog);
      // `added` is a text: it takes no children, so the last move is rejected.
      expect(r.rejected, [6]);
      expect(r.applied, [0, 1, 2, 3, 4, 5]);
      final back = applyOps(r.document, r.inverse, catalog: standardCatalog, atomic: true);
      expect(back.errors, isEmpty);
      expect(back.document.roots, page.roots);
      expect(back.document.nodes.keys.toSet(), page.nodes.keys.toSet());
      for (final id in page.nodes.keys) {
        expect(back.document[id], page[id], reason: id);
      }
      expect(back.document.extra, page.extra);
    });

    test('baseRev: a field another author changed since is stale_rev; disjoint fields merge', () {
      var r = applyOps(_empty, _small(), catalog: Catalog.core, author: 'agent');
      final readAt = r.rev;
      r = applyOps(r.document, [
        const PatchOp('a', {'props': {'text': 'person'}})
      ], catalog: Catalog.core, revisions: r.revisions, author: 'person');
      final mine = applyOps(r.document, [
        const PatchOp('a', {'props': {'text': 'agent'}}),
        const PatchOp('a', {'opacity': 0.5}),
      ], catalog: Catalog.core, revisions: r.revisions, baseRev: readAt, author: 'agent');
      expect(mine.applied, [1]);
      expect(mine.errors.single.code, 'stale_rev');
      expect(mine.errors.single.expected, ['person']);
      expect(mine.rev, r.rev + 1);
    });

    test('opsFromDocument rebuilds real pages exactly, top-down, with no rejected op', () {
      for (final name in ['restaurant_menu', 'saas_pricing']) {
        final page = _page(name);
        final ops = opsFromDocument(page);
        expect(ops.first, isA<RootsOp>());
        expect((ops[1] as SetOp).id, page.roots.first);
        var doc = LayoutDocument(catalog: standardCatalog);
        for (final op in ops) {
          final r = applyOps(doc, [op], catalog: standardCatalog, check: strictEditCheck(), incomplete: true);
          expect(r.errors, isEmpty, reason: '$name ${op.toJson()}');
          doc = r.document;
        }
        expect(endOfStream(doc), isEmpty, reason: name);
        expect(validateEdited(doc).where((d) => d.isError), isEmpty, reason: name);
        for (final id in page.nodes.keys) {
          expect(doc[id], page[id], reason: '$name $id');
        }
        // The same variables (a large one is declared where it is first read).
        Map<String, Object?> byName(LayoutDocument d) => {
              for (final e in (readMap(d.extra['variables']) ?? const {}).entries)
                e.key: {for (final v in readList(e.value)!) (v as Map)['name']: v},
            };
        expect(byName(doc), byName(page), reason: name);
      }
    });
  });

  group('strict check', () {
    test('the validator on what the op touched: its codes and suggestions', () {
      final base = applyOps(_empty, _small(), catalog: Catalog.core).document;
      final r = applyOps(base, [
        const PatchOp('a', {'decoration': {'fill': []}}),
        const PatchOp('a', {'props': {'style': {'fontWeight': 'heavy'}}}),
        const PatchOp('a', {'layout': {'x': 10}}),
      ], catalog: Catalog.core, check: strictEditCheck());
      expect(r.errors.map((d) => d.code), contains('unknown_decoration_key'));
      expect(r.errors.first.suggestion, 'fills');
      expect(r.rejected, containsAll([0, 1]));
      // A placement field its parent (a column) does not read: a warning.
      expect(r.applied, contains(2));
      expect(r.warnings.map((d) => d.code), contains('layout_field_ignored'));
    });
  });

  group('trust profile', () {
    test('the agent profile rejects scripts, links, feature types and navigation off the document', () {
      final base = applyOps(_empty, _small(), catalog: standardCatalog).document;
      Json tap(Json action) => {
            ..._text('t'),
            'actions': [
              {'trigger': {'type': 'click'}, 'actions': [action]},
            ],
          };
      final r = applyOps(base, [
        SetOp('s', tap({'type': 'runScript', 'script': 'x'}), parent: 'page'),
        SetOp('l', tap({'type': 'openLink', 'url': 'https://evil.example'}), parent: 'page'),
        SetOp('n', tap({'type': 'navigate', 'to': 'elsewhere'}), parent: 'page'),
        SetOp('ok', tap({'type': 'navigate', 'to': 'home'}), parent: 'page'),
        SetOp('ev', tap({'type': 'componentEvent', 'event': 'confirm', 'value': {'id': 1}}), parent: 'page'),
        const SetOp('v', {'type': 'video', 'layout': {'width': 100, 'height': 100}}, parent: 'page'),
        SetOp('big', {..._text('x' * 5000)}, parent: 'page'),
      ], catalog: standardCatalog, profile: TrustProfile.agent);
      expect({for (final d in r.errors) (d.op, d.code)}, {
        (0, 'capability_not_allowed'),
        (1, 'capability_not_allowed'),
        (2, 'capability_not_allowed'),
        (5, 'capability_not_allowed'),
        (6, 'limit_exceeded'),
      });
      expect(r.applied, [3, 4]);
      expect(TrustProfile.agent.restrict(standardCatalog).widget('video'), isNull);
      expect(TrustProfile.agent.restrict(standardCatalog).widget('column'), isNotNull);
      expect(TrustProfile.agent.restrict(standardCatalog).action('runScript'), isNull);
    });

    test('navigation may name a canvas that is still pending', () {
      final r = applyOps(_empty, [
        const RootsOp(['home', 'details']),
        const SetOp('home', _canvas),
        SetOp('page', {
          ..._column([]),
          'actions': [
            {
              'trigger': {'type': 'click'},
              'actions': [
                {'type': 'navigate', 'to': 'details'}
              ],
            }
          ],
        }),
      ], catalog: Catalog.core, profile: TrustProfile.agent);
      expect(r.errors, isEmpty);
    });
  });

  group('outline and tools', () {
    test('the outline is a fraction of the document', () {
      for (final name in ['restaurant_menu', 'saas_pricing']) {
        final page = _page(name);
        final o = outline(page, rev: 3);
        final rows = o['outline']! as List;
        expect(rows.length, page.nodes.length, reason: name);
        expect((rows.first as List).take(4), [page.roots.first, 'canvas', isA<String>(), 0]);
        final full = jsonEncode(page.toJson()).length, small = jsonEncode(o).length;
        expect(small / full, lessThan(0.4), reason: '$name: $small of $full bytes');
        // ignore: avoid_print
        print('outline $name: ${page.nodes.length} nodes, $small bytes vs $full (${(100 * small / full).toStringAsFixed(1)}%)');
      }
    });

    test('ui_read returns nodes, missing ids and the outline on request', () {
      final doc = applyOps(_empty, _small(), catalog: Catalog.core).document;
      final r = readUi(doc, {'ids': ['a', 'zz']}, rev: 2);
      expect((r['nodes']! as Map).keys, ['a']);
      expect(r['missing'], ['zz']);
      expect(r.containsKey('outline'), isFalse);
      expect(readUi(doc, const {})['outline'], isA<List>());
    });

    test('the tool schemas come from the declarations', () {
      final tools = uiTools(Catalog.core);
      expect([for (final t in tools) t['name']], ['ui_apply', 'ui_read']);
      final schema = tools.first['input_schema']! as Json;
      final items = ((schema['properties']! as Json)['ops']! as Json)['items']! as Json;
      final ops = [for (final s in items['anyOf']! as List) ((s as Json)['properties']! as Json)['op']];
      expect(ops, [for (final s in EditOp.specs) {'const': s.op}]);
      final node = (schema[r'$defs']! as Json)['Node']! as Json;
      final types = ((node['properties']! as Json)['type']! as Json)['enum']! as List;
      expect(types.toSet(), {for (final w in Catalog.core.widgets) w.type});
      expect(jsonEncode(tools).length, lessThan(12000));
    });

    test('the tool result a model reads', () {
      final r = applyOps(_empty, [..._small(), const PatchOp('zz', {'visible': false})], catalog: Catalog.core);
      final j = r.toModelJson();
      expect(j['applied'], [0, 1, 2, 3, 4]);
      expect(((j['rejected']! as List).single as Map)['code'], 'unknown_id');
    });
  });
}
