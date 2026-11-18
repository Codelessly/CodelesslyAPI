// Round 11b: writers who read the notation's reference before one write used
// more of it (decoration keys on controls, paint, more node types, keys after
// a size) and reached lines the grammar-only writers never wrote. Each test is
// one of those lines, as a build wrote it, and what it now expands to
// (codelessly_sdk docs/research/round-11b-reference-arm.md).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text, {NotationOptions options = const NotationOptions()}) =>
    parseNotation(text, catalog: standardCatalog, options: options);

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();
Map<String, Object?> _props(NotationResult r, String id) => ((_node(r, id)['props'] as Map?) ?? const {}).cast<String, Object?>();
Map<String, Object?> _layout(NotationResult r, String id) => ((_node(r, id)['layout'] as Map?) ?? const {}).cast<String, Object?>();
Map<String, Object?> _decoration(NotationResult r, String id) => ((_node(r, id)['decoration'] as Map?) ?? const {}).cast<String, Object?>();

void main() {
  group('a control that draws its own frame', () {
    test('a Select with a fill and a border: the line\'s box is its frame, no second frame inside it', () {
      // The docs site's version switcher (components/QuillHeader.txt:21).
      final r = _parse('''
state version="v2.4"
Row
  Select#v @version items=["v2.4","v2.3","v1.9"] w=83 h=36 pad=[8,0,5,0] fill=#FFFFFFFF border=#FFE2E3ED radius=7
  Select#p @version items=["v2.4"] h=44 w=300 border=#FFDCE2E3 radius=5
  Select#plain @version items=["v2.4"]
''');
      expect(r.issues, isEmpty);
      expect(_props(r, 'v'), containsPair('underline', false));
      expect(_decoration(r, 'v')['radius'], 7);
      expect(_decoration(r, 'v')['fills'], [
        {'color': '#FFFFFFFF'},
      ]);
      // Its own pad is kept; with none, the frame's side padding.
      expect(_layout(r, 'v')['padding'], [8, 0, 5, 0]);
      expect(_layout(r, 'p')['padding'], [10, 0, 10, 0]);
      // The box's line takes the accent while the Select has the focus.
      final focused = (((_node(r, 'p')['states'] as Map)['focused'] as Map)['p'] as Map)['decoration'] as Map;
      expect((focused['strokes'] as List).single, containsPair('color', const NotationOptions().accent));
      // A Select with no fill or border draws its own frame, as before.
      expect(_props(r, 'plain'), isNot(contains('underline')));
    });

    test('a Select of a document made before, a box around its own frame, prints underline=true and reads back the same', () {
      final doc = _parse('''
state segment="All"
Row
  Select#s @segment items=["All","SMB"] w=184 h=40 pad=[12,0,8,0] fill=#FFFFFFFF border=#FFE5E7EB radius=10
''').document;
      final node = ((doc['nodes'] as Map)['s'] as Map).cast<String, Object?>();
      (node['props'] as Map).remove('underline');
      node.remove('states');
      final printed = printNotation(doc, catalog: standardCatalog);
      expect(printed, contains('underline=true'));
      final again = _parse(printed);
      expect(_props(again, 's'), isNot(containsPair('underline', false)));
      expect(_layout(again, 's')['padding'], [12, 0, 8, 0]);
      expect(_node(again, 's')['states'], isNull);
    });

    test('a DatePicker and a TimePicker: fill, border and radius are the field\'s (radius was left out)', () {
      final r = _parse('''
state day="2026-11-18"
state at="09:30"
Column
  DatePicker#d @day w=200 h=40 fill=#FFFFFFFF border=#FFE2E3ED radius=10
  TimePicker#t @at w=200 h=40 fill=#FFFFF7E6 border=none
''');
      expect(r.issues, isEmpty);
      expect(_props(r, 'd')['decoration'], {
        'fillColor': '#FFFFFFFF',
        'filled': true,
        'border': {
          'type': 'outline',
          'borderSide': {'color': '#FFE2E3ED'},
          'borderRadius': 10,
        },
      });
      expect(_decoration(r, 'd'), isEmpty);
      expect((_props(r, 't')['decoration'] as Map)['border'], {'type': 'none'});
    });
  });

  test('a labelled Input of a fixed height: the height is its box, the label above it (the box drew about 22 of 44)', () {
    // property-listings (valuation.txt:30), restaurant, saas-landing,
    // calendar-app, clip-editor, meal-planner, kanban-board.
    final r = _parse('''
state a=""
Column
  Row gap=12 top
    Input#i "Street address" "e.g. 11 Canynge Road" @a h=44 w=300 required
    Select#s @a items=["1","2"] h=44
  Input#plain "Name" @a h=44 w=300
  Input#bare "" "Search" @a h=44 w=300
  Row gap=8 middle
    Input#bar "New marker" @a grow h=28
    IconButton "add"
''');
    expect(r.issues, isEmpty);
    for (final id in ['i', 'plain']) {
      expect(_layout(r, id)['height'], {'hug': 0}, reason: id);
      expect((_props(r, id)['decoration'] as Map)['constraints'], {'minHeight': 44, 'maxHeight': 44}, reason: id);
    }
    // No label above: the height is the box's already.
    expect(_layout(r, 'bare')['height'], 44);
    expect(_layout(r, 'bar')['height'], 28);
    // It prints back as written and reads back the same.
    final printed = printNotation(r.document, catalog: standardCatalog);
    final again = _parse(printed);
    expect(_layout(again, 'i'), _layout(r, 'i'), reason: printed);
    expect((_props(again, 'i')['decoration'] as Map)['constraints'], {'minHeight': 44, 'maxHeight': 44}, reason: printed);
  });

  test('a flag written as a key: scroll=false, phone.scroll=false, phone.stretch=true (they were refused)', () {
    // food-ordering (Main scroll=false), mail-client (Pane scroll=false),
    // kanban-board (tablet.scroll phone.scroll=false), admin-console and
    // money-tracker (phone.stretch=true).
    final r = _parse('''
App
  Main#main scroll=false
    Column#col scroll=true
      Row#row gap=12 top tablet.scroll phone.scroll=false
        Text "a"
      Row#flex gap=8 phone.direction=vertical phone.stretch=true
        Text "b"
''', options: const NotationOptions(width: 1280));
    expect(r.issues, isEmpty);
    expect(_props(r, 'main')['scrollable'], false);
    expect(_props(r, 'col')['scrollable'], true);
    final rules = _node(r, 'row')['media'] as List;
    expect(rules.last, {
      'maxWidth': 699,
      'patch': {
        'props': {'scrollable': false},
      },
    });
    final flex = (_node(r, 'flex')['media'] as List).single as Map;
    expect((flex['patch'] as Map)['props'], containsPair('crossAxisAlignment', 'stretch'));
  });

  test('an each in a row that turns down the page at a width turns with it (its copies stayed in a line across)', () {
    // travel-guide (journal.txt:12), conference (venue.txt:42), restaurant (private-dining.txt:18).
    final r = _parse('''
state cards=[1,2,3]
Column
  Row#row gap=12 phone.direction=vertical
    each c in cards
      Card#card w=365 tablet.w=248 phone.w=fill pad=18
        Text "{c}"
''');
    expect(r.issues, isEmpty);
    final nodes = r.document['nodes'] as Map;
    final listId = ((nodes['row'] as Map)['children'] as List).single as String;
    final list = (nodes[listId] as Map).cast<String, Object?>();
    expect((list['props'] as Map)['scrollDirection'], 'horizontal');
    expect(list['media'], [
      {
        'maxWidth': 699,
        'patch': {
          'props': {'scrollDirection': 'vertical'},
          'layout': {
            'width': {'fill': 0},
          },
        },
      },
    ]);
    final item = (nodes['${listId}Item'] as Map).cast<String, Object?>();
    expect(((item['media'] as List).single as Map)['patch'], containsPair('layout', {'width': {'fill': 0}, 'height': {'hug': 0}}));
  });

  test('a DateTimeInput keeps its value in the variable it is bound to (it "binds nothing")', () {
    // kanban-board (StackCardEditor.txt:20), money-tracker (EntryForm.txt:17).
    final r = _parse('''
state due=""
Column
  DateTimeInput#d @due mode=date format="MMM d, y"
''');
    expect(r.issues, isEmpty);
    expect((_node(r, 'd')['bind'] as Map)['props.value'], r'${due}');
    final actions = (_node(r, 'd')['actions'] as List).cast<Map>();
    expect(actions.first['trigger'], {'type': 'changed'});
  });

  test('a word of a field at a dotted key is that word, beside a variable of the same name', () {
    // photo-library (viewer.txt:24), team-chat: refused as "written in braces".
    final r = _parse('''
state zoom=1
Column
  box#b w=100 h=100 transformGesture.wheel=zoom transformGesture.scaleVariable=zoom
''');
    expect(r.issues, isEmpty);
    expect(_node(r, 'b')['transformGesture'], containsPair('wheel', 'zoom'));
  });

  test('a paint paragraph takes a quoted value at a dotted key (style.fontFamily="monospace")', () {
    // saas-landing (home.txt:28, 10 lines), seat-booking (ShowArtwork.txt:16, 5 lines).
    final r = _parse('''
Column
  box#b w=100 h=100
    customPaint viewBox=[100,100]
      paragraph "relay / incident desk" offset=[6,9] style.fontSize=12 style.fontFamily="monospace"
''');
    expect(r.issues, isEmpty);
    final op = (((_node(r, 'b')['customPaint'] as Map)['painter'] as List).single as Map);
    expect(op['text'], 'relay / incident desk');
    expect(op['style'], {'fontSize': 12, 'fontFamily': 'monospace'});
  });

  test('a Grid with a cell shape (childAspectRatio) has rows of that shape, not of their content', () {
    // photo-library (search.txt:38 and four screens more): photos 0 to 20 high;
    // music-player (library.txt:35): 126 render errors.
    final r = _parse('''
state items=[1,2,3]
Column
  Grid#g cols=6 phone.cols=2 gap=4 childAspectRatio=1.36
    each i in items
      box w=fill h=fill
  Grid#h cols=3 gap=4 mainAxisExtent=228
    each i in items
      box w=fill h=fill
''');
    expect(r.issues, isEmpty);
    final nodes = r.document['nodes'] as Map;
    Map props(String grid) => ((nodes[((nodes[grid] as Map)['children'] as List).single] as Map)['props'] as Map);
    expect(props('g')['childAspectRatio'], 1.36);
    expect(props('g'), isNot(contains('shrinkWrapRows')));
    // A height written is as before: the rows are their content's, at least.
    expect(props('h')['shrinkWrapRows'], true);
  });

  test('drag= and drop= with a dotted key after them on the line (the expand stopped with an exception)', () {
    // clip-editor (timeline.txt:94 and :144, both arms).
    final r = _parse('''
Column
  box#t w=fill h=40 drop=audioSource dropTarget.slot=none onDrop={x=1}
  Column#s w=230 drag=sourceClips(1) draggable.feedbackRotation=0
    Text "a"
''');
    expect(r.issues, isEmpty);
    expect(_node(r, 't')['dropTarget'], {'accepts': ['audioSource'], 'slot': 'none'});
    expect(_node(r, 's')['draggable'], containsPair('feedbackRotation', 0));
  });

  test('the columns of a Grid at a width worked out from the state (tablet.cols={…})', () {
    // photo-library (photos.txt:42): refused, the message quoting a valid value.
    final r = _parse('''
state gridColumns=6
state items=[1,2,3]
Column
  Grid#g cols={gridColumns} tablet.cols={max(2,gridColumns - 2)} phone.cols={max(1,gridColumns - 4)} gap=4
    each i in items
      box w=fill h=40
''');
    expect(r.issues, isEmpty);
    final nodes = r.document['nodes'] as Map;
    final grid = nodes[((nodes['g'] as Map)['children'] as List).single] as Map;
    final rules = (grid['media'] as List).cast<Map>();
    expect(rules.map((r) => r['maxWidth']), [1023, 699]);
    expect(((rules.last['patch'] as Map)['bind'] as Map)['props.crossAxisCount'], contains('gridColumns - 4'));
  });

  test('the strings of an ExpansionTile are its header (they were its first children, the header blank)', () {
    // conference (faq.txt:14): six question rows with only a chevron.
    final r = _parse('''
state qs=[{"q":"Q1","a":"A1"}]
Column
  each entry in qs
    ExpansionTile#t "{entry.q}" "More" w=fill
      Text#body "{entry.a}"
''');
    expect(r.issues, isEmpty);
    final tile = (_node(r, 't')['slots'] as Map)['tile'] as String;
    final slots = _node(r, tile)['slots'] as Map;
    expect(_node(r, tile)['type'], 'listTile');
    expect(_props(r, slots['title'] as String)['text'], r'${item.q}');
    expect(_props(r, slots['subtitle'] as String)['text'], 'More');
    expect(_node(r, 't')['children'], ['body']);
  });

  test('a child written to fill, in a row that wraps, takes the whole line there (a basis longer than any line)', () {
    // seat-booking (production.txt:10), smart-home, food-ordering: a column 0 wide, a card as narrow as its content.
    final r = _parse('''
Column
  Row#row gap=24 top phone.wrap=true
    Card#card w=392 tablet.w=290 phone.w=fill
      Text "Artwork"
    Column#col grow gap=20 phone.w=fill maxw=820
      Text "About"
  Row gap=8 wrap
    Column#always w=fill
      Text "a"
    Input#field "Email"
''');
    expect(r.issues, isEmpty);
    Map last(String id) => ((_node(r, id)['media'] as List).last as Map)['patch'] as Map;
    expect(last('card')['layout'], {'width': {'fill': 0}, 'basis': 100000});
    expect(last('col')['layout'], {'width': {'fill': 0}, 'basis': 100000});
    // Where the row is narrower than a phone only, the tablet's width is its own.
    expect(((_node(r, 'card')['media'] as List).first as Map)['patch'], {'layout': {'width': 290}});
    expect(_layout(r, 'always')['basis'], 100000);
    // A fill the line did not write is as it was.
    expect(_layout(r, 'field'), isNot(contains('basis')));
  });

  test('copies that grow, in a row that turns down the page on a phone, may say phone.grow=0 or phone.w=fill there', () {
    // restaurant (menu.txt:28, private-dining.txt:20), nonprofit (about.txt:17): refused, and rewritten by hand.
    final r = _parse('''
state sections=[1,2]
Column
  Row w=fill gap=24 phone.direction=vertical
    each section in sections
      Column w=fill grow phone.grow=0 phone.w=fill gap=12
        Text "{section}"
  Row w=fill gap=24
    each section in sections
      Column grow tablet.w=272
        Text "{section}"
''');
    // The first is read (the grid has one column there); the second is still said.
    expect(r.issues.map((i) => i.line), [9]);
  });

  test('a customPaint under a box in a Nav, a Section or an each is on the box (it went to the row holding it)', () {
    // seat-booking (HouseMasthead), nonprofit (CanopyNav), saas-landing
    // (the hero's console), travel-guide (the line at a glance), conference.
    final r = _parse('''
state stops=[1,2]
Nav w=fill
  Row#r1 gap=8 middle
    box#b1 w=32 h=32 radius=16 border=#FFAE8454
      customPaint viewBox=[32,32]
        circle c=[16,16] radius=8 fill=#FFFFFFFF
    Text "PROSCENIUM"
Section
  Row#r2 gap=8
    box#b2 w=200 h=100 tablet.h=80 radius=14
      customPaint viewBox=[200,100] fit=fill
        circle c=[100,50] radius=30 fill=#FFFFFFFF
    Text "Clear signal."
  Row#r3 w=fill stretch
    each s in stops
      Column#c3 grow gap=4 center
        box#b3 w=fill h=19
          customPaint viewBox=[100,19]
            circle c=[50,9] radius=6 fill=#FF8C5545
        Text "{s}"
''');
    expect(r.issues, isEmpty);
    for (final id in ['b1', 'b2', 'b3']) {
      expect(_node(r, id)['customPaint'], isNotNull, reason: id);
    }
    for (final id in ['r1', 'r2', 'c3']) {
      expect(_node(r, id)['customPaint'], isNull, reason: id);
    }
  });

  test('an animation as the first line under a Section belongs to the Section and keeps its lines in it', () {
    // studio-portfolio (project.txt:16): the lines after it went to the band, not the Section's column.
    final r = _parse('''
Section#s maxw=1000 gap=22
  animation#reveal duration=530 curve=easeOutCubic visibleFraction=0.22
    track path=opacity from=0 to=1
  Text#t "The brief"
  Row#row gap=30
    Text "a"
''');
    expect(r.issues, isEmpty);
    final nodes = r.document['nodes'] as Map;
    String parentOf(String id) => nodes.entries.firstWhere((e) => ((e.value as Map)['children'] as List?)?.contains(id) ?? false).key as String;
    expect(parentOf('t'), parentOf('row'));
    expect(parentOf('t'), isNot('s'), reason: 'under the column of the Section that holds its lines, not its band');
    final holder = nodes[parentOf('t')] as Map;
    expect(holder.toString(), contains('reveal'), reason: 'the animation is on the node holding the lines of the Section');
  });
}
