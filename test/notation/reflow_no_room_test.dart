// A desktop page at a tablet's and a phone's width: what a row has no room
// for is given a line of its own, not squeezed to a sliver or dropped. Each
// case is a row the pictures of a one-pass build showed wrong.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import '../notation_words.dart';

NotationResult _read(String text, {NotationOptions options = const NotationOptions(width: 1440)}) {
  final r = parseNotation(text, catalog: standardCatalog, options: withTestWords(options));
  expect(r.issues, isEmpty, reason: '$text\n${r.issues}');
  return r;
}

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

/// The patch of [id]'s rule up to [max] wide, as JSON ('[]' when none).
String _at(NotationResult r, String id, int max) => jsonEncode([
      for (final m in (_node(r, id)['media'] as List?) ?? const [])
        if ((m as Map)['maxWidth'] == max) m['patch'],
    ]);

const _stories = 'state stories=[{"title":"The last salt marsh","dek":"For three hundred years the village farmed the tide.","c":"#FF336699"}]\n';

void main() {
  group('a row of a list that has no room on a phone', () {
    test('a picture of a fixed width beside a column of a record\'s text: the row wraps, the picture a line, the text under it', () {
      final r = _read('''
${_stories}Page
  Section
    Column gap=16
      each s in stories
        Row#story gap=24 top
          Column#pic w=240
            Box h=140 fill=#FF336699
          Column#words grow gap=6
            Text "{s.title}"
            Text "{s.dek}"
''');
      expect(_at(r, 'story', 699), contains('"wrap":true'));
      expect(_at(r, 'pic', 699), allOf(contains('"fill":0'), contains('"flex":1')));
      expect(_at(r, 'words', 699), contains('"flex":1'));
      // Wider than a phone it is as written.
      expect(_at(r, 'story', 1023), '[]');
    });

    test('a field that grows beside two fields and three buttons: the row wraps, the field keeps a line\'s share', () {
      final r = _read('''
state items=[{"n":"Flour","q":1,"u":"g"}]
Page
  Section
    Column gap=8
      each i in items
        Row#line gap=8 middle
          Input#name "Ingredient" "Flour" @i.n grow
          Input#qty "Qty" @i.q w=90
          Select#unit @i.u items=["g","ml"] w=100
          IconButton "arrow_upward"
          IconButton "arrow_downward"
          IconButton "close"
''');
      expect(_at(r, 'line', 699), contains('"wrap":true'));
      expect(_at(r, 'name', 699), allOf(contains('"basis"'), contains('"flex":1')));
    });

    test('a name that grows beside an avatar and a time keeps its line', () {
      final r = _read('''
state people=[{"name":"Aiko","last":"09:42"}]
Page
  Section
    Column gap=8
      each p in people
        Row#person gap=12 middle
          Box#face w=32 h=32 radius=16 fill=#FF336699
          Text#name "{p.name}" grow
          Text#last "{p.last}"
''');
      expect(_at(r, 'person', 699), '[]');
      expect(_at(r, 'person', 1023), '[]');
    });

    test('a price beside two buttons, nothing growing: the row wraps where its place is narrower than it', () {
      final r = _read('''
state routes=[{"fare":210}]
Page
  Section
    Grid cols=3 gap=24
      each t in routes
        Card
          Row#foot between middle
            Text#fare "{t.fare}" size=24
            Row#acts gap=8
              Button.outline "Open"
              Button "Add to trip"
''');
      expect(_at(r, 'foot', 1023), contains('"wrap":true'));
    });

    test('a heading beside a badge and one small button narrows to further lines, as before', () {
      final r = _read('''
state places=[{"name":"Umi Omakase Box","rating":4.9}]
Page
  Section
    Grid cols=3 gap=24
      each p in places
        Card
          Row#head between middle
            Text#name "{p.name}"
            Row gap=6 middle
              Badge "★ {p.rating}"
              IconButton "favorite_border"
''');
      expect(_at(r, 'head', 1023), '[]');
      expect(_at(r, 'head', 699), '[]');
    });
  });

  test('a badge\'s label is one line', () {
    final r = _read('Column\n  Badge#b "★ 4.8"\n');
    final label = _node(r, (_node(r, 'b')['children'] as List).single as String);
    expect((label['props'] as Map)['maxLines'], 1);
  });

  group('a table written as rows of cells of fixed widths', () {
    const table = '''
state people=[{"name":"Aiko Tanaka","email":"aiko@northwind.io","role":"Owner","last":"2 h ago","status":"Active"}]
Page
  Section
    Column gap=0
      Row#head gap=12 middle pad=[12,8,12,8]
        Text#hName "Name" w=190
        Text#hEmail "Email" grow
        Text#hRole "Role" w=80
        Text#hLast "Last active" w=110
        Text#hStatus "Status" w=90
        Spacer w=40
      each r in people
        Row#line gap=12 middle pad=[12,6,12,6]
          Row#cName gap=8 middle w=190
            Box w=24 h=24 radius=12 fill=#FF336699
            Text "{r.name}"
          Text#cEmail "{r.email}" grow
          Text#cRole "{r.role}" w=80
          Text#cLast "{r.last}" w=110
          Text#cStatus "{r.status}" w=90
          IconButton "more_vert"
''';

    test('a phone keeps the first column of the head and of the rows, and hides the same ones in both', () {
      final r = _read(table);
      for (final id in ['hName', 'cName']) {
        expect(_at(r, id, 699), isNot(contains('"visible":false')), reason: id);
      }
      for (final (h, c) in [('hRole', 'cRole'), ('hLast', 'cLast'), ('hStatus', 'cStatus')]) {
        expect(_at(r, h, 699).contains('"visible":false'), _at(r, c, 699).contains('"visible":false'), reason: '$h and $c');
      }
    });
  });
}
