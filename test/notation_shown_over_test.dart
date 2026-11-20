// docs/design/26-shown-over-and-in-sequence.md in the notation and the JSON:
// `after=` beside `animate=` (a sequence: this starts when that ends), an
// overlay that grows out of what opened it (`Menu#x enterScale=0.6`), and a
// modal that closes itself (`closeAfterMs`).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes']! as Map)[id]! as Map).cast<String, Object?>();

NotationResult _parse(String text) => parseNotation(text, catalog: standardCatalog);

void main() {
  test('after= beside animate= waits for that node, and prints back', () {
    final r = _parse('''
Column
  Column#bubble w=120 h=40
  Column#menu w=200 h=80 animate=scale duration=220 after=bubble
  Row#copy w=200 h=40 animate=fade duration=180 delay=80 after=bubble
''');
    expect(r.issues, isEmpty);
    final a = ((_node(r, 'menu')['animations']! as List).single as Map).cast<String, Object?>();
    expect(a, containsPair('after', 'bubble'));
    expect(a, containsPair('duration', 220));
    final b = ((_node(r, 'copy')['animations']! as List).single as Map).cast<String, Object?>();
    expect(b, allOf(containsPair('after', 'bubble'), containsPair('delay', 80)));
    final printed = printNotation(r.document, catalog: standardCatalog);
    expect(printed, contains('animate=scale duration=220 after=bubble'));
    expect(printed, contains('animate=fade duration=180 delay=80 after=bubble'));
    // Read again, the same.
    final again = _parse(printed);
    expect(again.issues, isEmpty);
    expect(((_node(again, 'menu')['animations']! as List).single as Map)['after'], 'bubble');
  });

  test('after= on an animation line, and without animate= it is said', () {
    final r = _parse('''
Column
  Column#bubble w=120 h=40
  Column#menu w=200 h=80
    animation#grow duration=220 after=bubble
      track path=opacity from=0 to=1
''');
    expect(r.issues, isEmpty);
    expect(((_node(r, 'menu')['animations']! as List).single as Map)['after'], 'bubble');
    final alone = _parse('Column\n  Column#menu w=200 h=80 after=bubble');
    expect(alone.issues.map((i) => i.message).join('\n'), contains('after= goes with animate='));
  });

  test('NodeAnimation.after reads and writes', () {
    final a = NodeAnimation.fromJson({'id': 'a', 'preset': 'enter', 'after': 'bubble'})!;
    expect(a.after, 'bubble');
    expect(a.expanded.after, 'bubble');
    expect(a.toJson()['after'], 'bubble');
    expect(NodeAnimation.fromJson({'id': 'a'})!.toJson().containsKey('after'), isFalse);
  });

  test('a menu grows out of its button with enterScale', () {
    final r = _parse('''
Column
  Button#more "More" onTap={open moreMenu}
Menu#moreMenu enterScale=0.6
  Row#dup gap=10 pad=8 onTap={toast "Duplicated"}
    Text "Duplicate"
''');
    expect(r.issues, isEmpty);
    final open = ((((_node(r, 'more')['actions']! as List).single as Map)['actions']! as List).single as Map).cast<String, Object?>();
    expect(open, allOf(containsPair('presentation', 'popover'), containsPair('enterScale', 0.6)));
    // Not written, none.
    final plain = _parse('Column\n  Button#more "More" onTap={open moreMenu}\nMenu#moreMenu\n  Text "Duplicate"');
    final o = ((((_node(plain, 'more')['actions']! as List).single as Map)['actions']! as List).single as Map);
    expect(o.containsKey('enterScale'), isFalse);
  });

  test('closeAfterMs: a banner (a toast) that goes by itself', () {
    final a = ActionDef.fromJson({'type': 'openModal', 'to': 'saved', 'presentation': 'banner', 'closeAfterMs': 3000})! as OpenModalAction;
    expect(a.presentation, ModalPresentation.banner);
    expect(a.closeAfterMs, 3000);
    expect(a.toJson(), containsPair('closeAfterMs', 3000));
    expect((ActionDef.fromJson({'type': 'openModal', 'to': 'd'})! as OpenModalAction).toJson().containsKey('closeAfterMs'), isFalse);
    final r = _parse('''
Column
  Button#save "Save" onTap={openModal to=saved presentation=banner closeAfterMs=3000}
Canvas#saved "saved" w=390
  Text "Saved"
''');
    expect(r.issues, isEmpty);
    final open = ((((_node(r, 'save')['actions']! as List).single as Map)['actions']! as List).single as Map).cast<String, Object?>();
    expect(open, allOf(containsPair('presentation', 'banner'), containsPair('closeAfterMs', 3000)));
  });
}
