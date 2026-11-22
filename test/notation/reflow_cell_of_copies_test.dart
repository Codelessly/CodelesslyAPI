// A table written as rows of fixed cells shares its width where the row is
// wide for its place: a cell may then be narrower than it is written. A cell of copies an each
// repeats (a member's teams as tags) wraps them in its share; they reached
// past it, over the next cell (two tags of 130 in a cell of 150 given 115).
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import '../notation_words.dart';

const _members = '''
state vis=[{"name":"Ada Lovelace","email":"ada@example.com","role":"Admin","teams":["Platform","Design"],"status":"Active"}]
App
  Main
    Column gap=0
      each m in vis
        Row#line w=fill gap=10 middle pad=[12,6,12,6]
          Row#who w=150 gap=8 middle
            Text.strong "{m.name}" maxLines=1
          Text.muted "{m.email}" w=190 maxLines=1 hide=phone
          Text "{m.role}" w=80 hide=phone
          Row#teams w=150 gap=4 hide=phone
            each t in m.teams
              Text#tag "{t}" pad=[6,2,6,2] fill=#FFEEEEEE
          Text.muted "Today" w=90 hide=phone
          Text#status "{m.status}" w=100
''';

void main() {
  test('the cell is a share of the row, and its copies wrap in it where they do not fit', () {
    final r = parseNotation(_members, catalog: standardCatalog, options: withTestWords(const NotationOptions(width: 1440)));
    expect(r.issues, isEmpty, reason: '${r.issues}');
    final nodes = (r.document['nodes'] as Map).cast<String, Object?>();
    final teams = (nodes['teams'] as Map).cast<String, Object?>();
    expect(teams['layout'], {'width': {'fill': 0}, 'height': {'hug': 0}, 'flex': 150});
    final list = (nodes[(teams['children'] as List).single] as Map).cast<String, Object?>();
    expect(list['type'], 'listView');
    expect((list['layout'] as Map)['width'], {'fill': 0});
    expect(list['props'], containsPair('wrap', true));
    expect(list['props'], containsPair('wrapSpacing', 4));
    expect(list['props'], containsPair('runSpacing', 4));
    // A copy on a line of its own is as tall as it is.
    expect(((nodes[(list['children'] as List).single] as Map)['layout'] as Map)['height'], {'hug': 0});
  });

  test('a row that is a share of its place only up to a tablet: the copies wrap there, and are a line where it is written for', () {
    // Narrower than half the window as written: its cells keep their widths on a desktop.
    final page = _members.replaceFirst('Text.muted "{m.email}" w=190 maxLines=1 hide=phone', 'Spacer w=4').replaceAll(' hide=phone', '');
    final r = parseNotation(page, catalog: standardCatalog, options: withTestWords(const NotationOptions(width: 1440)));
    expect(r.issues, isEmpty, reason: '${r.issues}');
    final nodes = (r.document['nodes'] as Map).cast<String, Object?>();
    final teams = (nodes['teams'] as Map).cast<String, Object?>();
    expect((teams['layout'] as Map)['width'], 150);
    expect(jsonEncode(teams['media']), contains('"flex":150'));
    final list = (nodes[(teams['children'] as List).single] as Map).cast<String, Object?>();
    expect((list['props'] as Map)['wrap'], isNull);
    final rule = (list['media'] as List).cast<Map>().singleWhere((m) => m['maxWidth'] == 1023);
    expect((rule['patch'] as Map)['props'], {'wrap': true, 'wrapSpacing': 4, 'runSpacing': 4});
  });

  test('a cell of an exact width (w=150!), and one that scrolls, keep their copies on a line', () {
    for (final cell in ['Row#teams w=150! gap=4', 'Row#teams w=150 gap=4 scroll']) {
      final r = parseNotation(_members.replaceFirst('Row#teams w=150 gap=4 hide=phone', cell), catalog: standardCatalog, options: withTestWords(const NotationOptions(width: 1440)));
      expect(r.issues, isEmpty, reason: '${r.issues}');
      final nodes = (r.document['nodes'] as Map).cast<String, Object?>();
      final lists = [for (final n in nodes.values.cast<Map>()) if (n['type'] == 'listView' && '${(n['bind'] as Map?)?['data']}'.contains('teams')) n];
      expect(jsonEncode(lists), isNot(contains('"wrap":true')), reason: cell);
    }
  });
}
