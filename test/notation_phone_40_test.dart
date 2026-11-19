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
String _idOf(NotationResult r, String text) => _nodes(r).entries.firstWhere((e) {
      final p = (e.value as Map)['props'];
      return p is Map && (p['text'] == text || p['label'] == text);
    }).key;

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
}
