// Lines the writers of test 10 wrote (docs/projects FRICTION-dsl-api-10.md,
// in the editor repository) that the notation refused or took wrongly: each
// is read as meant, or said where it is written.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/catalog_json.dart' show catalogFromJson;
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

  group('R66: a call of a component whose slot is children', () {
    test('its lines are the call\'s children (what the slot shows), not a row in slots.children', () {
      final band = catalogFromJson({
        'widgets': [
          {'type': 'Band', 'slots': ['children']},
        ],
      });
      final catalog = standardCatalog + band;
      final r = Catalog.run(catalog, () => parseNotation('''
Column
  Band#b
    Text#t "Body"
''', catalog: catalog));
      expect(r.issues, isEmpty);
      expect(_node(r, 'b')['children'], ['t']);
      expect(_node(r, 'b')['slots'], isNull);
    });
  });

  group('R6: a Row of copies an each repeats wraps where the window is narrow', () {
    Map<String, Object?> media(NotationResult r, String id) => {
          for (final m in (_node(r, id)['media'] as List?) ?? const []) '${(m as Map)['maxWidth']}': m['patch'],
        };
    test('on a page, and in a dialog over it; not with scroll', () {
      final r = _parse('''
state days=[]
state week=["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
Page
  Section
    Row#r gap=5
      each day in week
        ChoiceChip#day "{day}" selected={contains(days,day)}
    Row#s gap=5 scroll
      each d in week
        ChoiceChip#day2 "{d}"
    Button "Add" onTap={open add}
Dialog#add "Add"
  Row#q gap=5
    each e in week
      ChoiceChip#day3 "{e}"
''', const NotationOptions(width: 1440));
      expect(r.issues, isEmpty);
      final list = (_node(r, 'r')['children'] as List).single as String;
      expect(media(r, list)['1023'], {
        'layout': {'width': {'hug': null, 'fill': 0}},
        'props': {'wrap': true, 'wrapSpacing': 5, 'runSpacing': 5},
      });
      expect(media(r, '${list}Item')['1023'], {
        'layout': {'height': {'fill': null, 'hug': 0}},
      });
      expect(_node(r, (_node(r, 's')['children'] as List).single as String)['media'], isNull);
      final inDialog = jsonEncode(r.document);
      expect(RegExp('"wrapSpacing":5').allMatches(inDialog).length, 2, reason: 'the page row and the dialog row');
    });

    test('a page written for a phone is as written', () {
      final r = _parse('''
state week=["Monday","Tuesday"]
Column
  Row#r gap=5
    each day in week
      ChoiceChip "{day}"
''');
      expect(jsonEncode(r.document), isNot(contains('wrapSpacing')));
    });
  });

  group('B: words writers expected, read as the notation\'s (recorded as aliases)', () {
    List<String> aliases(NotationResult r) => [for (final v in r.vocabulary) if (v.kind == 'alias') v.word];

    test('Image url=, Input prefixIcon=, RangeSlider, Grid\'s Flutter names', () {
      final r = _parse('''
state images=["a.png"]
state frame=0
state lo=1
state hi=9
state items=[1,2]
Column
  Image#i url="https://x/y.png" w=100 h=100
  Image#j url={images[frame]} h=300
  Input#q "Search" prefixIcon="search"
  RangeSlider#rs @lo end=@hi min=0 max=10
  Grid#g crossAxisCount=3 crossAxisSpacing=12 mainAxisExtent=30
    each i in items
      Text "{i}"
''');
      expect(r.issues, isEmpty);
      String url(String id) => ((((_node(r, id)['decoration'] as Map)['fills'] as List).first as Map)['image'] as Map)['url'] as String;
      expect(url('i'), 'https://x/y.png');
      expect(url('j'), r'${= images[frame]}');
      expect((((_node(r, 'q')['props'] as Map)['decoration'] as Map)['prefixIcon'] as Map)['icon'], 'search');
      expect(_node(r, 'rs')['type'], 'slider');
      expect((_node(r, 'rs')['bind'] as Map)['props.rangeEnd'], r'${hi}');
      final grid = _nodes(r).firstWhere((n) => n['type'] == 'gridView');
      expect(grid['props'], containsPair('crossAxisCount', 3));
      expect(grid['props'], containsPair('crossAxisSpacing', 12));
      expect(grid['props'], containsPair('mainAxisExtent', 30));
      expect(aliases(r), containsAll(['url', 'prefixIcon', 'RangeSlider', 'crossAxisCount', 'crossAxisSpacing', 'mainAxisExtent']));
    });

    test('semanticLabel on a Toggle, a Slider, a Checkbox: the name a screen reader says', () {
      final r = _parse('''
state on=false
state level=5
state milk=false
Column
  Toggle#t @on semanticLabel="Wi-Fi"
  Slider#s @level semanticLabel="Light"
  Checkbox#c @milk semanticLabel="Milk"
''');
      expect(r.issues, isEmpty);
      expect((_node(r, 't')['props'] as Map)['semanticLabel'], 'Wi-Fi');
      expect((_node(r, 's')['props'] as Map)['semanticLabel'], 'Light');
      expect((_node(r, 'c')['props'] as Map)['semanticLabel'], 'Milk');
    });

    test('setThemeMode with its one value written alone', () {
      final r = _parse('''
state dark=false
Column
  Button#a "Theme" onTap={setThemeMode {dark ? "dark" : "light"}}
  Button#b "Dark" onTap={setThemeMode dark}
''');
      expect(r.issues, isEmpty);
      Map first(String id) => ((_node(r, id)['actions'] as List).first as Map)['actions'].first as Map;
      expect(first('a'), {'type': 'setThemeMode', 'mode': r'${= dark ? "dark" : "light"}'});
      expect(first('b'), {'type': 'setThemeMode', 'mode': 'dark'});
    });

    test('key + and key mod++: the plus key', () {
      final r = _parse('''
state z=1
Column
  Text "x"
key + onPress={z=z+1}
key mod++ onPress={z=1}
''');
      expect(r.issues, isEmpty);
      final keys = [
        for (final a in (_node(r, 'screen')['actions'] as List?) ?? const [])
          if (((a as Map)['trigger'] as Map)['type'] == 'keyDown') (a['trigger'] as Map)['key'],
      ];
      expect(keys, ['+', 'mod++']);
    });

    test('ListView reorder handle: a reorder record, by its handles (a bare reorder was true, no reorder)', () {
      final r = _parse('''
state cats=["a","b"]
Column
  ListView#lv reorder handle onReorder={cats=result}
    each c in cats
      Row
        Handle
        Text "{c}"
  ListView#lp reorder onReorder={cats=result}
    each d in cats
      Text "{d}"
''');
      expect(r.issues, isEmpty);
      expect((_node(r, 'lv')['props'] as Map)['reorder'], {'keyboard': true, 'start': 'handle'});
      expect((_node(r, 'lp')['props'] as Map)['reorder'], {'keyboard': true, 'start': 'longPress'});
    });
  });

  group('R46 and parity: a Canvas block\'s blockBack and its own reactions', () {
    test('blockBack={…} is bound (was a literal string), and both print back under the block', () {
      const text = '''
state t=""
Column
  Text "x"
Canvas#card "card" w=780 blockBack={t != "a"}
  Text "y"
  on backPressed={confirm "Discard?" ok="Discard" cancel="Keep editing" danger then {close}}
''';
      final r = _parse(text);
      expect(r.issues, isEmpty);
      final card = _node(r, 'card');
      expect(card['bind'], {'props.blockBack': r'${= t != "a"}'});
      expect(card['blockBack'], isNull);
      expect((card['actions'] as List).single, containsPair('trigger', {'type': 'backPressed'}));
      final printed = printNotation(r.document, catalog: standardCatalog);
      expect(printed, isNot(contains('document {')));
      expect(printed, contains('blockBack={t != "a"}'));
      final again = _parse(printed);
      expect(again.issues, isEmpty);
      expect(_node(again, 'card'), card);
    });

    test('a design system\'s Dialog called in a canvas prints its event (onClose={close}), not a tail', () {
      final dialog = catalogFromJson({
        'widgets': [
          {
            'type': 'Dialog',
            'children': 'list',
            'props': [
              {'key': 'title', 'type': {'kind': 'string'}, 'default': ''},
            ],
            'events': [
              {'key': 'onClose'},
            ],
          },
        ],
      });
      final catalog = standardCatalog + dialog;
      final r = Catalog.run(catalog, () => parseNotation('''
Column
  Text "x"
Canvas#compose "compose" w=640
  Dialog "New message" onClose={close}
    Text "body"
''', catalog: catalog));
      expect(r.issues, isEmpty);
      final printed = Catalog.run(catalog, () => printNotation(r.document, catalog: catalog));
      expect(printed, contains('onClose={close}'));
      expect(printed, isNot(contains('{"actions"')));
    });
  });

  group('Top 25, 22 and 23: one-armed choices, handle on the each line, dotted paint keys, a sticky masthead', () {
    test('cond ? actions with no else; each … reorder handle; paragraph style.color=…', () {
      final r = _parse('''
state index=1
state c=[1]
state cats=["a"]
Column
  Button#b "x" onTap={index>0 ? c=[]}
  Column
    each k in cats reorder handle
      Row
        Handle
        Text "{k}"
  Box#p w=100 h=50
    customPaint
      paragraph "hi" offset=[0,0] style.color=#FFADB8AD style.fontSize=10
''');
      expect(r.issues, isEmpty);
      final choice = (((_node(r, 'b')['actions'] as List).first as Map)['actions'] as List).single as Map;
      expect(choice['type'], 'if');
      expect(choice.containsKey('else'), isFalse);
      final op = ((_node(r, 'p')['customPaint'] as Map)['painter'] as List).single as Map;
      expect(op['style'], {'color': '#FFADB8AD', 'fontSize': 10});
    });

    test('a component call named Masthead or Mast that is sticky stays at the very top', () {
      final mast = catalogFromJson({
        'widgets': [
          {'type': 'Masthead'},
        ],
      });
      final catalog = standardCatalog + mast;
      final r = Catalog.run(catalog, () => parseNotation('Column scroll\n  Masthead#m sticky\n  Column#toc sticky\n', catalog: catalog));
      expect(r.issues, isEmpty);
      expect(_node(r, 'm')['sticky'], {'offset': 0});
      expect(_node(r, 'toc')['sticky'], {'offset': 16});
    });
  });

  group('a Nav whose writer wrote its own phone menu', () {
    String nav(String phoneRow) {
      final r = _parse('''
Page
  Nav
    Brand "Harbour"
    Row gap=18 hide=phone
      Link "Buy" onTap={go results}
      Link "Agents" onTap={go agents}
$phoneRow
  Section
    Text "Hello"
''', const NotationOptions(width: 1280));
      expect(r.issues, isEmpty);
      return jsonEncode(r.document);
    }

    test('gets no second menu button and no menu of its links (round 11b: two menu buttons on a phone)', () {
      final own = nav('    Row gap=5 show=phone\n      IconButton "menu" onTap={open sitenav}');
      expect(RegExp('navMenu').hasMatch(own), isFalse);
      // The same bar with no phone line of the writer's gets the bar's own menu.
      expect(RegExp('navMenu').hasMatch(nav('')), isTrue);
    });
  });

  group('a Sidebar the writer makes a rail at a width', () {
    String rail(String sidebar) {
      final r = _parse('''
App
  $sidebar
    Brand "Stack" "Board" icon="home"
    NavSection "Work"
    NavItem "Board" icon="home" shortcut="V"
    NavItem "Plain"
  Main
    Text "Hello"
''');
      expect(r.issues, isEmpty);
      return jsonEncode(r.document);
    }

    test('its items show their icons alone there: label, shortcut, section and brand text are hidden', () {
      final plain = rail('Sidebar'), railed = rail('Sidebar w=232 tablet.w=72');
      int hidden(String s) => RegExp('"visible":false').allMatches(s).length;
      // The label and shortcut of the item with an icon, the section, the brand's text; not the item with no icon.
      expect(hidden(railed) - hidden(plain), 4);
    });

    test('a width with room for labels is no rail', () {
      expect(rail('Sidebar w=232 tablet.w=200'), isNot(contains('"visible":false')));
    });
  });
}
