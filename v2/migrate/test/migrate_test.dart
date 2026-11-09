import 'dart:convert';
import 'dart:io';

import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

/// Real project pages, when this repo sits next to the editor's.
final fixtures = Directory('../../../CodelesslyEditor/test/fixtures/legacy_pages');

void main() {
  test('a freeform child, a row and a text', () {
    final v2 = migrateDocument({
      'rootNode': {'children': ['c']},
      'c': {'id': 'c', 'type': 'canvas', 'name': 'Home', 'parentID': 'rootNode', 'basicBoxLocal': [0, 0, 400, 300],
            'properties': {'bodyId': 'f'}, 'children': ['f']},
      'f': {'id': 'f', 'name': 'f', 'parentID': 'c', 'type': 'frame', 'basicBoxLocal': [0, 0, 400, 300], 'children': ['r', 'p'],
            'padding': [10, 10, 10, 10]},
      'r': {'id': 'r', 'name': 'r', 'parentID': 'f', 'type': 'rowColumn', 'rowColumnType': 'row', 'basicBoxLocal': [30, 40, 200, 50],
            'horizontalFit': 'shrinkWrap', 'mainAxisAlignment': 'center', 'spacing': 8, 'children': ['t'],
            'fills': [{'type': 'solid', 'color': '#2FD17A', 'id': 'p1'}], 'cornerRadius': {'tl': {'x': 4, 'y': 4},
            'tr': {'x': 4, 'y': 4}, 'bl': {'x': 4, 'y': 4}, 'br': {'x': 4, 'y': 4}, 'type': 'circular'}},
      'p': {'id': 'p', 'name': 'p', 'parentID': 'f', 'type': 'rectangle', 'basicBoxLocal': [300, 200, 50, 50], 'edgePins': {'right': 40, 'bottom': 40},
            'positioningMode': 'pin'},
      't': {'id': 't', 'name': 't', 'parentID': 'r', 'type': 'text', 'basicBoxLocal': [0, 0, 40, 16], 'data': 'Hi',
            'textMixedProps': [{'start': 0, 'end': 2, 'fontSize': 13, 'fontName': {'family': 'Inter', 'weight': 'w700'},
              'lineHeight': {'value': 16}, 'fills': [{'type': 'solid', 'color': '#E9EBEE', 'id': 'x'}]}]},
    });
    final nodes = v2['nodes'] as Map;
    expect(v2['roots'], ['c']);
    expect(nodes['c']['slots'], {'body': 'f'});
    expect(nodes['f']['type'], 'stack');
    expect(nodes['f']['layout']['padding'], 10);
    final r = nodes['r'];
    expect(r['type'], 'row');
    // v1's default positioning keeps its share of the free space.
    expect(r['layout'], {'width': {'hug': 200}, 'height': 50, 'x': {'relative': 20}, 'y': {'relative': 30}});
    expect(r['props'], {'mainAxisAlignment': 'center', 'spacing': 8});
    expect(r['decoration']['radius'], 4);
    expect(r['decoration']['fills'], [{'id': 'p1', 'color': '#FF2FD17A'}]);
    expect(nodes['p']['layout']['x'], {'end': 30});
    expect(nodes['p']['layout']['y'], {'end': 30});
    final style = (nodes['t']['props']['runs'] as List).single['style'];
    expect(style['fontWeight'], 700);
    expect(style['height'], 16 / 13);
  });

  test('a child v1 can\'t decode is dropped from its parent too', () {
    final report = MigrationReport();
    final v2 = migrateDocument({
      'rootNode': {'children': ['c']},
      'c': {'id': 'c', 'type': 'canvas', 'name': 'Home', 'parentID': 'rootNode', 'basicBoxLocal': [0, 0, 400, 300],
            'properties': {'bodyId': 'f'}, 'children': ['f']},
      'f': {'id': 'f', 'name': 'f', 'parentID': 'c', 'type': 'frame', 'basicBoxLocal': [0, 0, 400, 300], 'children': ['p', 'bad']},
      'p': {'id': 'p', 'name': 'p', 'parentID': 'f', 'type': 'rectangle', 'basicBoxLocal': [0, 0, 50, 50]},
      // An icon with properties but no icon: v1 throws decoding it.
      'bad': {'id': 'bad', 'name': 'bad', 'parentID': 'f', 'type': 'icon', 'basicBoxLocal': [0, 0, 24, 24],
              'properties': <String, Object?>{}},
    }, report: report);
    final nodes = v2['nodes'] as Map;
    expect(report.undecodable.keys, contains('bad'));
    expect(nodes.containsKey('bad'), isFalse);
    expect(nodes['f']['children'], ['p']);
  });

  test('elliptical corners keep their x and y; a linked elliptical radius is the box ellipse', () {
    Map<String, Object?> rect(String id, Object radius, {double w = 80, double h = 40}) => {
          'id': id, 'name': id, 'parentID': 'f', 'type': 'rectangle', 'basicBoxLocal': [0, 0, w, h], 'cornerRadius': radius,
        };
    final v2 = migrateDocument({
      'rootNode': {'children': ['c']},
      'c': {'id': 'c', 'type': 'canvas', 'name': 'Home', 'parentID': 'rootNode', 'basicBoxLocal': [0, 0, 400, 300],
            'properties': {'bodyId': 'f'}, 'children': ['f']},
      'f': {'id': 'f', 'name': 'f', 'parentID': 'c', 'type': 'frame', 'basicBoxLocal': [0, 0, 400, 300],
            'children': ['all', 'one', 'oval', 'round']},
      // v1's compact forms: [x, y, linked, type] and [tl.x, tl.y, ... br.y, linked, type].
      'all': rect('all', [16, 8, false, 'elliptical']),
      'one': rect('one', [16, 8, 4, 4, 0, 0, 0, 0, false, 'circular']),
      'oval': rect('oval', [5, 5, true, 'elliptical']),
      'round': rect('round', [6, true, 'circular']),
    });
    Object? radius(String id) => ((v2['nodes'] as Map)[id]['decoration'] as Map?)?['radius'];
    expect(radius('all'), [16, 8]);
    expect(radius('one'), [[16, 8], 4, 0, 0]);
    expect(radius('oval'), [80, 40]);
    expect(radius('round'), 6);
  });

  test('every fixture page migrates; only editor metadata stays unmapped', () {
    if (!fixtures.existsSync()) return markTestSkipped('fixtures not checked out');
    final total = MigrationReport();
    for (final f in fixtures.listSync().whereType<File>().where((f) => f.path.endsWith('.json.gz'))) {
      final json = jsonDecode(utf8.decode(gzip.decode(f.readAsBytesSync()))) as Map<String, dynamic>;
      final v2 = migrateDocument(((json['document'] as Map?) ?? json).cast(), report: total);
      jsonEncode(v2);
    }
    expect(total.nodes, greaterThan(50000));
    const editorMetadata = {'aspectRatioLock', 'createdTimestamp'};
    final unexpected = total.unmapped.keys.where((k) => !editorMetadata.contains(k.split('.').last));
    expect(unexpected, isEmpty);
  });
}
