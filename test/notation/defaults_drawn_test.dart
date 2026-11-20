// Plain lines from a 30-part app rebuild that drew what their writer did not
// expect, each fixed where the line is read: a two-number pad, a side word
// along a column, a screen's fill that follows data, a composer beside a box
// of the app's own that sends, a frame with a spacer in it, and a place or an
// effect with a field nothing reads (said, not dropped in silence).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

NotationResult _expand(String text) =>
    Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog, options: const NotationOptions(reflow: false)));

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes']! as Map)[id]! as Map).cast<String, Object?>();

Map<String, Object?> _props(NotationResult r, String id) => ((_node(r, id)['props'] as Map?) ?? const {}).cast<String, Object?>();

void main() {
  group('pad=[x,y]', () {
    test('two numbers are left and right, then top and bottom', () {
      expect(EdgeInsets.fromJson([14, 12]), const EdgeInsets.fromLTRB(14, 12, 14, 12));
      // A card's pad=[14,12] put nothing between its border and its text.
      final r = _expand('Column\n  Row#card w=fill pad=[14,12] border=#FF000000\n    Text "Card"');
      final layout = Layout.fromJson(_node(r, 'card')['layout']);
      expect(layout.padding, const EdgeInsets.fromLTRB(14, 12, 14, 12));
    });
  });

  group('a side named along a row or column', () {
    test('a Column bottom gathers its children at its foot', () {
      // `Column minHeight=680 bottom` put its children at its right, at the top.
      final r = _expand('Column\n  Column#c w=fill minHeight=680 bottom\n    Text "Last"');
      expect(_props(r, 'c')['mainAxisAlignment'], 'end');
      expect(_props(r, 'c')['crossAxisAlignment'], isNot('end'));
    });

    test('a Column top, a Row right and left along; across as before', () {
      final r = _expand('Column\n  Column#t top\n    Text "a"\n  Row#r right\n    Text "b"\n  Row#l left\n    Text "c"\n'
          '  Row#rb bottom\n    Text "d"\n  Column#cr right\n    Text "e"');
      expect(_props(r, 't')['mainAxisAlignment'], 'start');
      expect(_props(r, 'r')['mainAxisAlignment'], 'end');
      expect(_props(r, 'l')['mainAxisAlignment'], 'start');
      expect(_props(r, 'rb')['crossAxisAlignment'], 'end', reason: 'a Row bottom is across it');
      expect(_props(r, 'cr')['crossAxisAlignment'], 'end', reason: 'a Column right is across it');
    });
  });

  test('a canvas fill that follows data is bound, not kept as text', () {
    final r = _expand("canvas \"Poll\" w=390 h=844 fill={step == 0 ? '#FFFF0000' : '#FF00FF00'}\nstate step=0\nColumn\n  Text \"Hi\"");
    final screen = _node(r, 'screen');
    expect((screen['bind']! as Map)['decoration.fills[0].color'], r"${= step == 0 ? '#FFFF0000' : '#FF00FF00'}");
    final fills = (screen['decoration']! as Map)['fills']! as List;
    expect((fills.single as Map)['color'], isNot(contains('{')));
  });

  test('a multi-line field beside a box that sends is a composer', () {
    // `Input "Hint" @draft multiline maxLines=4` beside a round send box
    // drew a label above and three lines.
    final r = _expand('state draft=""\nRow w=fill gap=8\n  Input#draft "Message" @draft multiline maxLines=4 grow\n'
        '  Box#send w=40 h=40 radius=20 fill=#FF545CEA onTap={draft=""}\n    Icon "arrow_upward" size=16');
    final p = _props(r, 'draft');
    expect(p['minLines'], 1);
    expect(p['maxLines'], 4);
    final d = (p['decoration']! as Map).cast<String, Object?>();
    expect(d['hintText'], 'Message');
    expect(d['labelText'], anyOf(isNull, ''));
  });

  test('a framed row with a spacer beside its button frames its field', () {
    final r = _expand('state draft=""\nRow#frame w=fill h=42 radius=20 border=#FFE9EEF4 middle\n'
        '  Input#reply "" "Add a reply..." @draft grow\n  if draft != ""\n    IconButton "arrow_upward" onTap={draft=""}\n'
        '  else\n    box w=12 h=1');
    final d = (_props(r, 'reply')['decoration']! as Map).cast<String, Object?>();
    expect(d['border'], {'type': 'none'});
    expect(d['filled'], false);
  });

  group('a field nothing reads is said', () {
    test('in a place', () {
      final r = _expand('Stack w=200 h=80\n  Box#orn w=20 h=20 x={"center":0}');
      expect(r.issues.map((i) => i.message), contains(allOf(contains('"center" is not read'), contains('{"align":0}'))));
    });

    test('in an effect', () {
      final r = _expand('Column\n  Box w=40 h=40 effects=[{"type":"layerBlur","radius":43.7}]');
      expect(r.issues.map((i) => i.message), contains(allOf(contains('"radius" is not read'), contains('blurRadius'))));
    });

    test('not when every field is one', () {
      final r = _expand('Stack w=200 h=80\n  Box w=20 h=20 x={"align":0} y={"end":8} effects=[{"type":"dropShadow","blurRadius":4,"offset":[0,2]}]');
      expect(r.issues, isEmpty);
    });
  });
}
