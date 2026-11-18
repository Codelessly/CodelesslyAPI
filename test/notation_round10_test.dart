// Lines the writers of test 10 wrote (docs/projects FRICTION-dsl-api-10.md,
// in the editor repository) that the notation refused or took wrongly: each
// is read as meant, or said where it is written.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text, [NotationOptions options = const NotationOptions()]) => parseNotation(text, catalog: standardCatalog, options: options);

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

Iterable<Map<String, Object?>> _nodes(NotationResult r) => (r.document['nodes'] as Map).values.map((n) => (n as Map).cast<String, Object?>());

void main() {
  group('R1: a bare word where an icon name goes is the icon\'s name', () {
    test('Icon download, and icon=inbox on a NavItem and a MenuItem', () {
      final r = _parse('''
Column
  Icon#a download size=18
  NavItem#n "Inbox" icon=inbox
  MenuItem#m "Delete" icon=delete
''');
      expect(r.issues, isEmpty);
      expect((_node(r, 'a')['props'] as Map)['icon'], 'download');
      final icons = [for (final n in _nodes(r)) if (n['type'] == 'icon') (n['props'] as Map)['icon']];
      expect(icons, containsAll(['download', 'inbox', 'delete']));
    });

    test('a variable of that name does not take it: braces read the variable', () {
      final r = _parse('''
state inbox=1
state glyph="home"
Column
  Icon#a inbox
  Icon#b {glyph}
  NavItem "Inbox" icon=inbox
''');
      expect(r.issues, isEmpty);
      expect((_node(r, 'a')['props'] as Map)['icon'], 'inbox');
      expect(jsonEncode(_node(r, 'b')), contains(r'"props.icon":"${glyph}"'));
    });

    test('the words an Icon has keep their meaning', () {
      final r = _parse('''
Column
  Icon#a "home" hidden
''');
      expect(r.issues, isEmpty);
      expect(_node(r, 'a')['visible'], false);
    });
  });

  group('R3: the writer\'s key wins over the page word\'s own', () {
    test('Sidebar … h=fill, Table … radius=0 border=… w=…: no issue, the writer\'s values', () {
      final r = _parse('''
App
  Sidebar#side w=210 pad=[14,24,14,14] fill=#FFEEEEEE border-right=#FF000000 h=fill
    NavItem "A"
  Main
    Table#t r in rows columns=[{"key":"a","label":"A"}] radius=0 border=#FF111111 w=600
''');
      expect(r.issues, isEmpty);
      final table = _node(r, 't');
      expect((table['layout'] as Map)['width'], 600);
      expect((table['decoration'] as Map)['radius'], 0);
    });

    test('a key the writer wrote twice is still said', () {
      final r = _parse('''
App
  Main
    Table#u r in rows columns=[{"key":"a","label":"A"}] radius=0 radius=4
''');
      expect(r.issues.map((i) => i.message), [contains('radius= is written twice')]);
    });
  });

  group('R2: foregroundPainter is written under the node, as customPaint is', () {
    test('alone, and beside a customPaint written after it', () {
      final r = _parse('''
Column
  Box#c h=100 fill=#FFEEEEEE
    foregroundPainter
      circle c=[50,50] radius=20 fill=#FF000000
  Box#d h=100
    foregroundPainter
      circle c=[50,50] radius=20 fill=#FF000000
    customPaint viewBox=[100,100]
      rect rect=[0,0,10,10] fill=#FFFF0000
''');
      expect(r.issues, isEmpty);
      final c = _node(r, 'c')['customPaint'] as Map;
      expect((c['foregroundPainter'] as List).single, containsPair('op', 'circle'));
      expect(c['painter'], isNull);
      final d = _node(r, 'd')['customPaint'] as Map;
      expect((d['foregroundPainter'] as List).single, containsPair('op', 'circle'));
      expect((d['painter'] as List).single, containsPair('op', 'rect'));
      expect(d['viewBox'], [100, 100]);
      // It prints back, and reads as the same document.
      final printed = printNotation(r.document, catalog: standardCatalog);
      expect(printed, isNot(contains('{"')));
      final again = _parse(printed);
      expect(again.issues, isEmpty);
      expect(_node(again, 'd')['customPaint'], d);
    });
  });

  group('R64: several onKeyDown(key=…) on one line are several reactions', () {
    test('both run, no issue; the same key twice is still said', () {
      final r = _parse('''
state q=""
Column
  Input#query "Find" @q onKeyDown(key=ArrowDown)={q="d"} onKeyDown(key=ArrowUp)={q="u"}
''');
      expect(r.issues, isEmpty);
      final keys = [
        for (final a in _node(r, 'query')['actions'] as List)
          if (((a as Map)['trigger'] as Map)['type'] == 'keyDown') (a['trigger'] as Map)['key'],
      ];
      expect(keys, ['ArrowDown', 'ArrowUp']);
      final twice = _parse('''
state q=""
Column
  Input#query "Find" @q onKeyDown(key=Enter)={q="a"} onKeyDown(key=Enter)={q="b"}
''');
      expect(twice.issues.map((i) => i.message), [contains('written twice')]);
    });
  });

  group('Avatar: initials= as written; one word read from the state keeps two letters', () {
    test('initials="XY", initials={p.ini}, and "{p.ini}" alone', () {
      final r = _parse('''
state p={"name":"Maya Reyes","ini":"MR"}
Column
  Avatar#a "Maya Reyes" initials="XY"
  Avatar#b "{p.ini}"
  Avatar#c "{p.name}" initials={p.ini}
''');
      expect(r.issues, isEmpty);
      String text(String id) => ((_node(r, '${id}Text')['props'] as Map)['text']) as String;
      expect(text('a'), 'XY');
      expect(text('b'), contains('left(trim(text(p.ini)), 2)'));
      expect(text('c'), r'${p.ini}');
    });
  });

  group('R68: a state named item read inside an each is said', () {
    test('the each\'s copy is item in the document', () {
      final r = _parse('''
state item={"mood":""}
state feelings=["ok","sad"]
Column
  each feeling in feelings
    Button "{feeling}" onTap={item=with(item,"mood",feeling)}
''');
      expect(r.issues.map((i) => i.message), [contains('state item cannot be read here')]);
      // Outside an each, or not read, nothing is said.
      expect(_parse('''
state item={"mood":""}
state feelings=["ok","sad"]
Column
  Text "{item.mood}"
  each feeling in feelings
    Text "{feeling}"
''').issues, isEmpty);
    });
  });

  group('R16: App under a page header is a region of panes; NavSection outside a Sidebar', () {
    test('App grow under a header row: a row of panes, Main scrolls', () {
      final r = _parse('''
Column
  Row
    Icon menu_book
    Text "Docs" grow
  App#region grow
    Sidebar w=200
      NavSection "Guide"
      NavItem "Intro"
    Main#main
      Text "Body"
''');
      expect(r.issues, isEmpty);
      expect(_node(r, 'region')['type'], 'row');
      expect((_node(r, 'main')['props'] as Map)['scrollable'], true);
    });

    test('NavSection in a column of navigation', () {
      final r = _parse('''
Column
  NavSection "Mailbox"
  NavItem "Inbox" icon=inbox
''');
      expect(r.issues, isEmpty);
      expect(jsonEncode(r.document), contains('MAILBOX'));
    });
  });
}
