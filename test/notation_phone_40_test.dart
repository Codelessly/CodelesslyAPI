// What a page written once draws on a phone and a tablet, and what a plain
// line draws by default (40.0.0).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import 'notation_words.dart';

NotationResult _parse(String text, [NotationOptions options = const NotationOptions(openVocabulary: true, width: 1440)]) =>
    parseNotation(text, catalog: standardCatalog, options: withTestWords(options));

Map<String, Object?> _nodes(NotationResult r) => (r.document['nodes'] as Map).cast<String, Object?>();

Map<String, Object?> _node(NotationResult r, String id) => (_nodes(r)[id]! as Map).cast<String, Object?>();

/// The node whose text or label is [text].
String _idOf(NotationResult r, String text, {bool last = false}) {
  final found = _nodes(r).entries.where((e) {
    final p = (e.value as Map)['props'];
    return p is Map && (p['text'] == text || p['label'] == text);
  });
  return (last ? found.last : found.first).key;
}

String _parentOf(NotationResult r, String id) =>
    _nodes(r).entries.firstWhere((e) => ((e.value as Map)['children'] as List?)?.contains(id) ?? false).key;

/// The patch a node's rules give it at a screen [width] wide, merged in order.
Map<String, Object?> _at(NotationResult r, String id, num width) {
  var out = <String, Object?>{};
  for (final rule in (_node(r, id)['media'] as List? ?? const [])) {
    final m = (rule as Map).cast<String, Object?>();
    final max = m['maxWidth'] as num?, min = m['minWidth'] as num?;
    if ((max == null || width <= max) && (min == null || width >= min)) out = mergePatch(out, (m['patch'] as Map).cast<String, Object?>());
  }
  return out;
}

void main() {
  group('a row whose child is as wide as its place at a width is laid out down the page there', () {
    test('a fixed column written phone.w=fill beside one that grows', () {
      final r = _parse('''
Column pad=24 gap=12
  Row gap=14 tablet.gap=12 stretch
    Column w=345 tablet.w=248 phone.w=fill gap=10
      Text "Routines"
    Column grow phone.w=fill pad=18
      Text "Detail"
''');
      expect(r.issues, isEmpty);
      final list = _parentOf(r, _idOf(r, 'Routines')), detail = _parentOf(r, _idOf(r, 'Detail'));
      final row = _parentOf(r, list);
      expect((_at(r, row, 390)['props'] as Map)['wrap'], true);
      expect((_at(r, row, 390)['props'] as Map)['runSpacing'], 12);
      expect(_at(r, row, 834)['props'], {'spacing': 12}, reason: 'a tablet keeps the row');
      for (final k in [list, detail]) {
        final l = (_at(r, k, 390)['layout'] as Map);
        expect(l['width'], {'fill': 0});
        expect(l['basis'], 699, reason: 'a line of its own');
      }
    });

    test('fields written phone.w=fill in a row of controls each take a line; the buttons share one', () {
      final r = _parse('''
Column pad=24 gap=12
  Row gap=8 middle
    Select "Actor" items=["All","Ada"] w=180 phone.w=fill
    Select "Action" items=["All","Edit"] w=196 phone.w=fill
    Button.outline "Date range"
    Spacer
    Text.caption "80 events"
''');
      final button = _idOf(r, 'Date range');
      final row = _parentOf(r, button);
      expect((_at(r, row, 390)['props'] as Map)['wrap'], true);
      final kids = (_node(r, row)['children'] as List).cast<String>();
      expect((_at(r, kids[0], 390)['layout'] as Map)['basis'], 699);
      expect((_at(r, kids[1], 390)['layout'] as Map)['basis'], 699);
      expect(_at(r, button, 390)['layout'], isNull);
      expect(_at(r, kids[3], 390)['visible'], false, reason: 'a spacer has nothing to push apart down the page');
    });

    test('a row that says what it does there, or two children that share it, is left as written', () {
      final own = _parse('''
Column pad=24
  Row gap=8 phone.wrap=false
    Column w=300 phone.w=fill
      Text "One"
    Column grow
      Text "Two"
''');
      final row = _parentOf(own, _parentOf(own, _idOf(own, 'One')));
      expect((_at(own, row, 390)['props'] as Map)['wrap'], false);
      final shared = _parse('''
Column pad=24
  Row gap=8
    Button "Cancel" phone.grow
    Button "Save" phone.grow
''');
      final actions = _parentOf(shared, _idOf(shared, 'Save'));
      expect((_at(shared, actions, 390)['props'] as Map?)?['wrap'], isNot(true));
    });
  });

  group('a row of text beside text keeps a width its words can be read at', () {
    test('two columns of paragraphs take a line each on a phone', () {
      final r = _parse('''
Column pad=24
  Row gap=32 top
    Column grow
      Text "We are a four-person motion and brand studio in London. We make identities with a sense of timing." size=22
    Column grow
      Text "You will work directly with the people making the work, from first scribble to the last export." size=22
''');
      final first = _parentOf(r, _nodes(r).entries.firstWhere((e) => '${((e.value as Map)['props'] as Map?)?['text']}'.startsWith('We are')).key);
      final row = _parentOf(r, first);
      expect((_at(r, row, 390)['props'] as Map)['wrap'], true);
      expect((_at(r, first, 390)['layout'] as Map)['basis'], 200);
      expect((_at(r, first, 834)['layout'] as Map)['basis'], 96, reason: 'a tablet has room for both');
    });

    test('a label of two short lines beside a button keeps its line', () {
      final r = _parse('''
Column pad=24
  Row gap=12 middle
    Column grow
      Text "Plan"
      Text "Pro"
    Button "Change"
''');
      final label = _parentOf(r, _idOf(r, 'Plan'));
      expect((_at(r, label, 390)['layout'] as Map)['basis'], 96);
    });

    test('in an app, a heading beside a box of figures that leaves it no room goes above it', () {
      final r = _parse('''
App
  Main
    Column pad=22 gap=15
      Row between middle gap=10
        Column gap=3 grow
          Text.heading1 "This week"
          Text "A little planning makes a good meal easier."
        Box fill=#FFE8EDDA radius=14 pad=10
          Row gap=13 middle
            Text.strong "{n} meals"
            Text.caption "{k} kcal / serving"
            Text.caption "{m} min cooking"
''');
      final heading = _parentOf(r, _idOf(r, 'This week'));
      final row = _parentOf(r, heading);
      expect((_at(r, row, 390)['props'] as Map)['wrap'], true);
      expect(((_at(r, heading, 390)['layout'] as Map)['basis'] as num) > 200, true);
    });
  });

  group('copies that grow from a least width in a row that wraps', () {
    test('are as many equal columns as fit, the least width a phone is given there', () {
      final r = _parse('''
state decks=[{"name":"A"},{"name":"B"},{"name":"C"}]
Column pad=24
  Row w=fill gap=14 wrap=true runSpacing=10
    each d in decks
      Card w=fill basis=265 grow phone.basis=300 h=195
        Text "{d.name}"
''');
      expect(r.issues, isEmpty);
      final grid = _nodes(r).entries.firstWhere((e) => (e.value as Map)['type'] == 'gridView');
      final props = ((grid.value as Map)['props'] as Map);
      expect(props['minCrossAxisExtent'], 265);
      expect(props['crossAxisSpacing'], 14);
      expect(props['mainAxisSpacing'], 10);
      expect(props.containsKey('wrap'), false);
      expect((_at(r, grid.key, 390)['props'] as Map)['minCrossAxisExtent'], 300);
    });
  });

  group('words a writer reaches for', () {
    test('a Button and an IconButton take radius: the corners of their shape', () {
      final r = _parse('''
Column
  Button "Donate" h=44 radius=22
  IconButton "play_arrow" radius=20
''');
      expect(r.issues, isEmpty);
      expect(((_node(r, _idOf(r, 'Donate'))['props'] as Map)['style'] as Map)['shape'], {'type': 'roundedRectangle', 'borderRadius': 22});
      final icon = _nodes(r).entries.firstWhere((e) => (e.value as Map)['type'] == 'iconButton').value as Map;
      expect(((icon['props'] as Map)['style'] as Map)['shape'], {'type': 'roundedRectangle', 'borderRadius': 20});
    });

    test('phone.axis=vertical and phone.direction=column are phone.direction=vertical', () {
      for (final word in ['phone.axis=vertical', 'phone.direction=column', 'phone.direction=vertical']) {
        final r = _parse('''
Column
  Row gap=8 $word
    Text "a"
    Text "b"
''');
        expect(r.issues, isEmpty, reason: word);
        final row = _parentOf(r, _idOf(r, 'a'));
        expect(_node(r, row)['type'], 'flex');
        expect((_at(r, row, 390)['props'] as Map)['direction'], 'vertical', reason: word);
      }
    });
  });

  group('a bar on a phone is one line', () {
    test('a page bar keeps its brand and the menu button: its links and labelled buttons are in the menu', () {
      final r = _parse('''
Page
  Nav sticky
    Text.title "Harbour & Hill"
    Row gap=5 middle
      Button.ghost "Buy" onTap={go results}
      Button.ghost "Agents" onTap={go agents}
    Button.outline "Get a valuation" onTap={go valuation}
    IconButton "favorite_border" onTap={go saved}
  Section
    Text.heading1 "Find your place"
''');
      expect(r.issues, isEmpty);
      final cta = _nodes(r).entries.where((e) => (e.value as Map)['type'] == 'outlinedButton').map((e) => e.key).toList();
      expect(cta.length, 2, reason: 'the bar\'s and the menu\'s');
      expect(_at(r, cta.first, 390)['visible'], false);
      expect(_at(r, cta.first, 834)['visible'], isNull);
      final heart = _nodes(r).entries.firstWhere((e) => (e.value as Map)['type'] == 'iconButton' && ((e.value as Map)['props'] as Map)['icon'] == 'favorite_border').key;
      expect(_at(r, heart, 390)['visible'], isNull, reason: 'an icon button stays');
      final bar = _parentOf(r, _idOf(r, 'Harbour & Hill'));
      expect((_at(r, bar, 390)['props'] as Map?)?['wrap'], false, reason: 'one line');
      // The menu's button of the same kind, as wide as the menu.
      expect((_node(r, _parentOf(r, cta.last))['layout'] as Map)['width'], {'fill': 0});
    });

    test('a bar with no links folds nothing and has no menu button', () {
      final r = _parse('''
Page
  Nav
    Text.title "Relay"
    Button.outline "Sign in" onTap={go signin}
    Button "Get started" onTap={go start}
  Section
    Text "Hello"
''');
      expect(_nodes(r).values.any((n) => (n as Map)['type'] == 'iconButton'), false);
      expect(_at(r, _idOf(r, 'Sign in'), 390)['visible'], isNull);
    });

    test('a button that says where it shows, or stands under a condition, is left to that', () {
      final r = _parse('''
state signedIn=false
Page
  Nav
    Text.title "Relay"
    Button.ghost "Docs" onTap={go docs}
    Button.ghost "Pricing" onTap={go pricing}
    Button.outline "Basket" hide=tablet onTap={go basket}
    if signedIn
      Button "Account" onTap={go account}
  Section
    Text "Hello"
''');
      expect(_nodes(r).values.where((n) => (n as Map)['type'] == 'outlinedButton').length, 1);
      expect(_nodes(r).values.where((n) => (n as Map)['type'] == 'filledButton').length, 1);
      expect(_at(r, _idOf(r, 'Account'), 390)['visible'], isNull);
    });

    test('the menu of a bar that is the last thing written starts closed', () {
      final r = _parse('''
Page
  Nav
    Text.title "Proscenium"
    Button.ghost "What's on" onTap={go home}
    Button.ghost "My tickets" onTap={go tickets}
''');
      final scopes = (r.document['variables'] as Map).values.expand((v) => v as List).toList();
      expect(scopes.firstWhere((v) => (v as Map)['name'] == 'navMenu'), containsPair('value', false));
    });

    test('a second Nav in a page is a strip: it keeps its items and scrolls sideways on a phone', () {
      final r = _parse('''
state tab="see"
Page
  Nav
    Text.title "Slow Atlas"
    Button.ghost "Routes" onTap={go routes}
    Button.ghost "Cities" onTap={go cities}
  Section
    Text.heading1 "A day in Chur"
  Nav sticky
    Row gap=8 middle
      Button.ghost "See" selected={tab=="see"} onTap={tab="see"}
      Button.ghost "Eat" selected={tab=="eat"} onTap={tab="eat"}
  Section
    Text "Lanes"
''');
      expect(r.issues, isEmpty);
      final see = _idOf(r, 'See');
      expect(_at(r, see, 390)['visible'], isNull);
      final strip = _parentOf(r, _parentOf(r, see));
      expect((_at(r, strip, 390)['props'] as Map)['scrollable'], true);
      expect(_nodes(r).values.where((n) => (n as Map)['type'] == 'iconButton').length, 1, reason: 'one menu button: the page bar\'s');
    });
  });

  group('the button made for an app\'s sidebar', () {
    bool hiddenEverywhere(Map<String, Object?> n) => (n['media'] as List? ?? const []).any((m) => (m as Map)['minWidth'] == 0 && (m['patch'] as Map)['visible'] == false);

    test('goes in Main\'s bar when a line that draws nothing is written before it: one bar, not two', () {
      final r = _parse('''
App
  Sidebar
    Text "Inbox"
  Main
    Box hidden
    Nav
      Text.strong "Inbox"
    Column pad=24
      Text "All tickets"
''');
      final menus = _nodes(r).entries.where((e) => (e.value as Map)['type'] == 'iconButton' && ((e.value as Map)['props'] as Map)['icon'] == 'menu').toList();
      expect(menus.length, 2);
      // The slim bar made before the Nav was read takes no room at any width.
      final slim = _parentOf(r, menus.first.key);
      expect(hiddenEverywhere(_node(r, slim)), true);
      final bar = (_node(r, _parentOf(r, menus.last.key))['children'] as List).cast<String>();
      expect(bar.any((k) => (_node(r, k)['props'] as Map?)?['text'] == 'Inbox'), true, reason: 'beside its title');
    });

    test('is not made where the writer wrote one for a narrow window', () {
      final r = _parse('''
App
  Sidebar hide=phone
    Text "Scenes"
  Main
    Row w=fill gap=6 middle
      IconButton "menu" show=phone onTap={open houseNav}
      Text "SCENES" grow
    Text "Set the mood"
Drawer#houseNav "Cedar House"
  Text "Scenes"
''');
      final menus = _nodes(r).entries.where((e) => (e.value as Map)['type'] == 'iconButton' && ((e.value as Map)['props'] as Map)['icon'] == 'menu').toList();
      final shown = menus.where((e) => !hiddenEverywhere(_node(r, _parentOf(r, e.key)))).toList();
      expect(shown.length, 1, reason: 'the writer\'s');
    });
  });

  group('panes, tables and grids on a narrower window', () {
    test('a Sidebar whose width is kept in a variable is hidden on a phone, as one of a written width is', () {
      final r = _parse('''
state sidebarWidth=220
App
  Sidebar w={sidebarWidth}
    Text "Folders"
  Main
    Nav
      Text.strong "Inbox"
    Text "Messages"
''');
      final side = _parentOf(r, _idOf(r, 'Folders'));
      expect(_at(r, side, 390)['visible'], false);
      expect(_at(r, side, 834)['visible'], isNull);
    });

    test('a Table leaves out the columns that have no room beside the one that grows, also where the writer left one out', () {
      final r = _parse('''
state cards=[{"word":"cuaderno","meaning":"notebook","known":"Learning","due":"Today"}]
state picked=[]
Column pad=16
  Table c in cards columns=[{"key":"word","label":"Spanish"},{"key":"meaning","label":"English","w":150},{"key":"known","label":"Status","w":104},{"key":"due","label":"Next review","w":120,"hide":"phone"},{"key":"actions","label":"","w":40}] select=@picked
    Text.strong "{c.word}"
    Text "{c.meaning}"
    Text "{c.known}"
    Text "{c.due}"
    IconButton "edit"
''');
      final meaning = _parentOf(r, _nodes(r).entries.firstWhere((e) => ((e.value as Map)['props'] as Map?)?['text'] == r'${item.meaning}').key);
      final known = _parentOf(r, _nodes(r).entries.firstWhere((e) => ((e.value as Map)['props'] as Map?)?['text'] == r'${item.known}').key);
      // English narrows to keep its place; Status has none.
      expect(((_at(r, meaning, 390)['layout'] as Map)['width'] as num) >= 90, true);
      expect(((_at(r, meaning, 390)['layout'] as Map)['width'] as num) < 150, true);
      expect(_at(r, known, 390)['visible'], false);
      expect(_at(r, known, 1440), isEmpty);
    });

    test('a row with a part that grows, written in a Table cell, is as wide as the cell', () {
      final r = _parse('''
state tickets=[{"subject":"Password reset","status":"Open"}]
Column pad=16
  Table t in tickets columns=[{"key":"subject","label":"Ticket"},{"key":"status","label":"Status","w":110}]
    Row middle gap=9
      Column grow gap=2
        Text.strong "{t.subject}"
      Icon "chevron_right"
    Text "{t.status}"
''');
      final icon = _nodes(r).entries.firstWhere((e) => (e.value as Map)['type'] == 'icon').key;
      final layout = _node(r, _parentOf(r, icon))['layout'] as Map;
      expect(layout['width'], {'fill': 0});
      expect(layout['flex'], 1);
    });

    test('the cells of a Grid that are as tall as their row are as tall as themselves where the grid wraps', () {
      final r = _parse('''
App
  Main
    Grid cols=4 gap=12
      Lane "Backlog"
        Text "One"
      Lane "Ready"
        Text "Two"
      Lane "Doing"
        Text "Three"
      Lane "Done"
        Text "Four"
define Lane "title"
  Column gap=8 pad=8 fill=#FFE6EBF2
    Text.strong "{title}"
    ...
''');
      final lane = _parentOf(r, _idOf(r, 'One'));
      expect((_node(r, lane)['layout'] as Map)['height'], {'fill': 0});
      expect((_at(r, lane, 834)['layout'] as Map)['height'], {'fill': null, 'hug': 0});
    });

    test('a Grid whose columns are worked out shows at most three on a phone', () {
      final r = _parse('''
state zoom=5
state photos=[{"id":1},{"id":2}]
Column
  Grid cols={zoom} gap=4
    each p in photos
      Box h=80 fill=#FF88AA99
''');
      final grid = _nodes(r).entries.firstWhere((e) => (e.value as Map)['type'] == 'gridView').key;
      expect('${(_at(r, grid, 390)['bind'] as Map)['props.crossAxisCount']}', startsWith(r'${= min(3, '));
      expect(_at(r, grid, 834), isEmpty);
    });
  });

  group('a website\'s type', () {
    num? sizeOf(NotationResult r, String text) => ((_node(r, _idOf(r, text))['props'] as Map)['style'] as Map?)?['fontSize'] as num?;

    test('under a Page, in a Section or not: a display headline, headings in proportion, running text at 16', () {
      final r = _parse('''
Page
  Nav
    Text.title "Brand"
  Column maxw=960 pad=24
    Text.heading1 "Hero"
    Text.bodySecondary "Lead"
  Section
    Text.heading2 "Two"
    Text.heading3 "Three"
    Text "Body"
    Text.small "Small"
    Text.caption "Caption"
    Card
      Text.strong "Strong"
    Text "Own" size=13
''');
      expect([for (final t in ['Hero', 'Lead', 'Two', 'Three', 'Body', 'Small', 'Caption', 'Strong', 'Own']) sizeOf(r, t)], [64, 16, 38, 24, 16, 14, 13, 16, 13]);
      expect(sizeOf(r, 'Brand'), 20, reason: 'a bar\'s text is the bar\'s');
      expect(((_at(r, _idOf(r, 'Three'), 390)['props'] as Map)['style'] as Map)['fontSize'], 18, reason: 'a small heading is a phone\'s size on a phone');
      expect(((_at(r, _idOf(r, 'Two'), 390)['props'] as Map)['style'] as Map)['fontSize'], 27);
      expect(_at(r, _idOf(r, 'Body'), 390), isEmpty);
    });

    test('an app\'s text is an app\'s', () {
      final r = _parse('''
App
  Main
    Text.heading1 "Title"
    Text "Body"
''');
      expect(sizeOf(r, 'Title'), 30);
      expect(sizeOf(r, 'Body'), anyOf(isNull, 13));
    });

    test('a theme that sizes its body sizes what is drawn from it; its headings still take a website\'s sizes', () {
      final r = _parse('''
Page
  Section
    Text.heading2 "Two"
    Text "Body"
    Text.small "Small"
''', NotationOptions.fromTheme(const {
        'textStyles': {
          'body': {'fontSize': 15},
        },
      }, width: 1440));
      expect(sizeOf(r, 'Two'), 38);
      expect(sizeOf(r, 'Body'), 15);
      expect(sizeOf(r, 'Small'), isNot(14));
    });
  });

  group('bars and sections', () {
    test('a quiet button in a bar that goes to the page shown is drawn selected; on a website it is a link\'s size', () {
      final r = _parse('''
Page
  Nav
    Text.title "Northlight"
    Button.ghost "Schedule" onTap={go schedule}
    Button.ghost "Speakers" onTap={go speakers}
  Section
    Text "Hello"
''', const NotationOptions(openVocabulary: true, width: 1440, screen: 'speakers'));
      final here = _node(r, _idOf(r, 'Speakers')), other = _node(r, _idOf(r, 'Schedule'));
      expect((here['bind'] as Map)['selected'], isNotNull);
      expect((other['bind'] as Map?)?['selected'], isNull);
      expect((((other['props'] as Map)['style'] as Map)['textStyle'] as Map)['fontSize'], 15);
    });

    test('a bar written among the lines of a defined word is the page\'s bar', () {
      final r = _parse('''
Page
  ShopHeader
  Section
    Text "Hello"
define ShopHeader
  Box fill=#FF233E32 pad=8
    Text.caption "Free shipping"
  Nav
    Text.title "Fennel & Rye"
    Button.ghost "Shop" onTap={go shop}
    Button.ghost "Journal" onTap={go journal}
''');
      final bar = _parentOf(r, _idOf(r, 'Fennel & Rye'));
      final band = _node(r, _parentOf(r, bar));
      expect((band['layout'] as Map)['padding'], [24, 14, 24, 14], reason: 'the page\'s gutter');
      expect(((_node(r, bar)['layout'] as Map)['constraints'] as Map)['maxWidth'], isNotNull);
      expect(_at(r, _idOf(r, 'Shop'), 390)['visible'], false, reason: 'its links fold into its menu');
    });

    test('a component bar\'s maxw is its items\' width in the middle of the bar, not the bar\'s', () {
      final r = _parse('''
Column w=fill
  Nav fill=#FFFAF5EA pad=[42,13,42,13] maxw=1320
    Text.title "Fennel & Rye"
    IconButton "search"
''');
      final row = _parentOf(r, _idOf(r, 'Fennel & Rye'));
      expect(((_node(r, row)['layout'] as Map)['constraints'] as Map)['maxWidth'], 1320);
      final band = _node(r, _parentOf(r, row));
      expect((band['layout'] as Map)['constraints'], isNull);
      expect((band['props'] as Map)['crossAxisAlignment'], 'center');
      expect(band['decoration'], isNotNull, reason: 'the fill is the band\'s');
    });

    test('a tinted Section has a ground when the theme names none', () {
      final r = _parse('''
Page
  Section
    Text "One"
  Section tint
    Text "Two"
''');
      final section = _parentOf(r, _parentOf(r, _idOf(r, 'Two')));
      expect(((_node(r, section)['decoration'] as Map)['fills'] as List).single, {'color': '#14808080'});
    });

    test('a Column with maxw written in the column that scrolls the page stands in its middle', () {
      final r = _parse('''
App
  Main
    Column scroll grow
      Column maxw=960 pad=20
        Text "Story"
      Column maxw=600 pad=20 w=300
        Text "Fixed"
''');
      expect((_node(r, _parentOf(r, _idOf(r, 'Story')))['layout'] as Map)['align'], 'topCenter');
      expect((_node(r, _parentOf(r, _idOf(r, 'Fixed')))['layout'] as Map)['align'], isNull);
    });
  });

  group('controls in a row', () {
    test('a Toggle beside a text that already says its label keeps the string as its spoken name', () {
      final r = _parse('''
state sso=false
Column
  Row gap=12 middle
    Column grow gap=3
      Text.strong "Single sign-on"
      Text.muted "Require members to sign in."
    Toggle "Single sign-on" @sso
  Row gap=12 middle
    Text "Notifications"
    Toggle "Email me" @sso
  Toggle "Dark mode" @sso
''');
      final toggles = _nodes(r).values.where((n) => (n as Map)['type'] == 'switch').map((n) => ((n as Map)['props'] as Map)).toList();
      expect(toggles[0]['label'], isNull);
      expect(toggles[0]['semanticLabel'], 'Single sign-on');
      expect(toggles[1]['label'], 'Email me');
      expect(toggles[2]['label'], 'Dark mode');
    });

    test('a number field with no width in a row is 96 wide', () {
      final r = _parse('''
state reps=5
Row middle gap=2
  IconButton "remove" onTap={reps=reps-1}
  Input "Reps" value={reps} type=number onChange={reps=result}
  IconButton "add" onTap={reps=reps+1}
''');
      final field = _nodes(r).values.firstWhere((n) => (n as Map)['type'] == 'textField') as Map;
      expect((field['layout'] as Map)['width'], 96);
    });

    test('a field beside chips, or in a row of a set height with no room above it, has its label as its hint', () {
      final r = _parse('''
state tag=""
state f=""
Column
  Row gap=6 middle
    Chip "fieldwork"
    Input "Add tag" @tag
  Row h=40 middle gap=8
    Text.mono "B4"
    Input "Formula" @f grow
''');
      for (final n in _nodes(r).values.where((n) => (n as Map)['type'] == 'textField')) {
        final d = (((n as Map)['props'] as Map)['decoration'] as Map);
        expect(d['labelText'], isNull);
        expect(d['hintText'], anyOf('Add tag', 'Formula'));
      }
    });
  });

  test('a short brand and its one button have room on a phone: the button stays in the bar, the menu has the links', () {
    final r = _parse('''
Page
  Nav
    Text.strong "Canopy"
    Button.ghost "About" onTap={go about}
    Button.ghost "Stories" onTap={go stories}
    Button "Donate" onTap={go donate}
  Section
    Text "Hello"
''');
    final donate = _nodes(r).entries.where((e) => (e.value as Map)['type'] == 'filledButton').map((e) => e.key).toList();
    expect(donate.length, 2);
    expect(_at(r, donate.first, 390)['visible'], isNull, reason: 'in the bar');
    expect(_at(r, _parentOf(r, donate.last), 390)['visible'], false, reason: 'not said twice in the menu');
    expect(_at(r, _idOf(r, 'About'), 390)['visible'], false);
  });
}
