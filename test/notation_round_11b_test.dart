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
