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
}
