// Track C: a desktop page written in one pass, with no rules for other
// widths, at a tablet's and a phone's width. Each case is a fault the
// one-pass builds showed at 834x1112 or 390x844 (docs reference
// responsive.md, "What reflow does").
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import '../notation_words.dart';

NotationResult _read(String text, {NotationOptions options = const NotationOptions(width: 1440)}) {
  final r = parseNotation(text, catalog: standardCatalog, options: withTestWords(options));
  expect(r.issues, isEmpty, reason: text);
  return r;
}

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

List<Object?> _media(NotationResult r, String id) => (_node(r, id)['media'] as List?) ?? const [];

/// The patch of [id]'s rule up to [max] wide, as JSON ('' when none).
String _at(NotationResult r, String id, int max) => jsonEncode([
      for (final m in _media(r, id))
        if ((m as Map)['maxWidth'] == max) m['patch'],
    ]);

void main() {
  group('a row of controls in an app that has no room on a phone', () {
    test('a filter bar (a search, two selects, a count) wraps there: its fields share the lines, its spacer goes', () {
      final r = _read('''
App
  Main
    Column#page gap=20 pad=32
      Row#filters gap=8
        Input#search "" "Search name or email" w=280
        Select#role items=["All roles","Admin"] w=140
        Select#status items=["All statuses","Active"] w=150
        Spacer#gap
        Text#count "12 of 50"
''');
      expect(_at(r, 'filters', 699), contains('"wrap":true'));
      expect(_at(r, 'search', 699), contains('"basis":240'));
      expect(_at(r, 'role', 699), contains('"basis":140'));
      expect(_at(r, 'gap', 699), contains('"visible":false'));
      // A tablet has room: as written.
      expect(_at(r, 'filters', 1023), '[]');
    });

    test('a field the writer narrowed at a tablet does not keep the row from wrapping on a phone', () {
      final r = _read('''
App
  Main
    Row#filters gap=8 middle
      Input#search "" "Search cards" w=260 tablet.w=200
      Select#who items=["Anyone","Maya"] w=160
      ChoiceChip "Any due"
      ChoiceChip "Late"
      ChoiceChip "Due this week"
      Spacer
      Button.ghost "Clear filters" icon="filter_alt_off"
''');
      expect(_at(r, 'filters', 699), contains('"wrap":true'));
      // The writer's own rule on the field is theirs.
      expect(_at(r, 'search', 699), '[]');
    });

    test("a top bar's title beside a search and a button: the bar takes a second line on a phone", () {
      final r = _read('''
App
  Sidebar
    NavItem "Board" icon="view_kanban"
  Main
    Nav
      Heading#title "Product board" level=1
      Row#actions gap=8 middle
        Input#search "Search cards" "Search" w=220 icon="search"
        Button "New card" icon="add"
''');
      final bar = _node(r, 'title');
      final row = (r.document['nodes'] as Map).entries.firstWhere((e) => ((e.value as Map)['children'] as List?)?.contains('title') ?? false).key;
      expect(_at(r, row, 699), contains('"wrap":true'));
      expect(bar, isNotNull);
    });

    test("a top bar of the title alone: on a phone the title sits beside the menu button, not at the bar's far end", () {
      final r = _read('''
App
  Sidebar
    NavItem "Inbox" icon="inbox"
  Main
    Nav
      Text#barTitle "Inbox"
''');
      expect(_at(r, 'barTitle', 699), contains('"flex":1'));
    });

    test("a list's row (a name, a subject that grows, a time) keeps its line", () {
      final r = _read('''
App
  Main
    Row#mailRow gap=12 pad=10
      Text "Maya Reyes" w=180
      Text "Q4 roadmap review moved to Thursday" grow
      Text "9:41 AM" w=80
''');
      expect(_media(r, 'mailRow'), isEmpty);
    });
  });

  group('a list written as Main of a fixed width beside the Pane that shows what it selects', () {
    const mail = '''
state mails:list=[{"id":"a","from":"Maya"}]
state openId="a"
App
  Sidebar
    NavItem "Inbox" icon="inbox"
  Main#list w=380
    each m in mails
      Row#mailRow pad=12 onTap={openId=m.id}
        Text "{m.from}"
  Pane#reader
    Text "{find(mails, 'id', openId).from}"
''';

    test('a phone shows one at a time: the list, then the reading pane with a back button (it kept 380, the reader 10 wide)', () {
      final r = _read(mail);
      // The list fills the window up to the width where both have room.
      expect(jsonEncode(_media(r, 'list')), contains('"flex":1'));
      expect(jsonEncode(_media(r, 'reader')), contains('"visible"'));
      expect(jsonEncode(r.document), contains('arrow_back'));
    });

    test('with no tap that selects, a phone shows the list alone, as wide as the window', () {
      final r = _read(mail.replaceAll(' onTap={openId=m.id}', ''));
      expect(_at(r, 'list', 699), contains('"flex":1'));
      expect(_at(r, 'reader', 699), contains('"visible":false'));
    });
  });

  group("a design system's rail (sizes.rail)", () {
    // (Which lines fold by themselves, and so leave the sidebar a rail:
    // sidebar_rail_test.dart.)
    const page = 'App\n  #SIDE\n#LINES  Main\n    Text "Hello"\n';
    Map<String, Object?> side(String sidebar, {double? rail = 64, String lines = '    Spacer\n    Divider\n'}) {
      final r = _read(page.replaceFirst('#SIDE', sidebar).replaceFirst('#LINES', lines), options: NotationOptions(width: 1440, sidebarRail: rail));
      final nodes = (r.document['nodes'] as Map).cast<String, Object?>();
      return (nodes.values.firstWhere((n) => (n as Map)['type'] == 'column' && jsonEncode(n['layout']).contains('"width":248')) as Map).cast<String, Object?>();
    }

    test('a sidebar written with no rule for other widths, with no line that needs its width, is a rail at a tablet', () {
      final s = side('Sidebar');
      expect(jsonEncode(s['media']), contains('{"maxWidth":1023,"patch":{"layout":{"width":64}}}'));
      // On a phone it is the drawer.
      expect(jsonEncode(s['media']), contains('{"maxWidth":699,"patch":{"visible":false'));
    });

    test('a sidebar whose items are rows written by hand (a defined word of an icon and a text) is as wide as written: at 64 its labels stood a letter a line', () {
      const items = '    NavItem "Inbox" icon="inbox"\n';
      final s = side('Sidebar', lines: items);
      expect(jsonEncode(s['media']), isNot(contains('"width":64')));
      expect(s['media'], side('Sidebar', rail: null, lines: items)['media']);
    });

    test("a sidebar with rules of the writer's, or a system with no rail, is as written", () {
      expect(jsonEncode(side('Sidebar hide=phone')['media']), isNot(contains('"width":64')));
      expect(jsonEncode(side('Sidebar', rail: null)['media']), isNot(contains('"width":64')));
    });
  });

  test('a Row written wrap with two eaches and other lines wraps them all: each list a group as wide as its copies (its chips stood in a column 96 wide)', () {
    final r = _read('''
state labels=["Bug","Feature"]
state people=["Maya","Dev"]
Column
  Row#chips gap=8 wrap middle
    each lb in labels
      FilterChip "{lb}"
    each p in people
      FilterChip "{p}"
    Spacer#push grow
    Text "12 cards"
''');
    // Narrower than a desktop; the desktop's picture is as it was.
    expect(_at(r, 'chips', 1023), contains('"wrap":true'));
    expect((_node(r, 'chips')['props'] as Map)['wrap'], isNull);
    final lists = [for (final k in (_node(r, 'chips')['children'] as List).cast<String>()) if (_node(r, k)['type'] == 'listView') k];
    expect(lists, hasLength(2));
    for (final l in lists) {
      expect(_at(r, l, 1023), allOf(contains('"width":{"fill":null,"hug":0}'), contains('"wrap":true')));
    }
    expect(_at(r, 'push', 1023), contains('"basis":0'));
    // A page written for a phone: at every width.
    final phone = _read('state labels=["Bug"]\nstate people=["Maya"]\nColumn\n  Row#chips gap=8 wrap\n    each lb in labels\n      FilterChip "{lb}"\n    each p in people\n      FilterChip "{p}"\n', options: const NotationOptions(width: 390));
    expect(_node(phone, 'chips')['props'], containsPair('wrap', true));
  });

  test('a Row written wrap over its one each: the list does the wrapping, as before', () {
    final r = _read('state days=["Mon","Tue"]\nColumn\n  Row#days gap=5 wrap\n    each d in days\n      ChoiceChip "{d}"\n');
    expect((_node(r, 'days')['props'] as Map)['wrap'], isNull);
  });

  test("a width rule on a line whose width is bound (a pane a splitter sizes) holds there: the binding is the desktop's", () {
    final r = _read('''
state listWidth=320
Row h=fill
  Column#list w={listWidth} tablet.w=275 phone.w=fill
    Text "Notes"
  Column grow
    Text "Note"
''');
    final phone = _at(r, 'list', 699);
    expect(phone, contains('"fill"'));
    expect(phone, contains('"layout.width":null'));
  });
}
