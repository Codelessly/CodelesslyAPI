// The parts a picker or an input of one's own is made of (docs/design/26):
// a key reaction that is a focused control's, a word that is an overlay with
// state of its own, a switch's pill thumb and an entrance's easing.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import 'notation_words.dart';

NotationResult _parse(String text) => parseNotation(text, catalog: standardCatalog, options: withTestWords(const NotationOptions(width: 390)));

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();
List<String> _roots(NotationResult r) => (r.document['roots'] as List).cast<String>();
List<Map> _variables(NotationResult r) => [
      for (final scope in (r.document['variables'] as Map? ?? const {}).values)
        for (final v in scope as List) v as Map,
    ];

void main() {
  group('a key of a focused control', () {
    test('focused=true is a key trigger\'s field, read and written, false by default', () {
      final t = Trigger.fromJson({'type': 'keyDown', 'key': 'Arrow Down', 'focused': true})!;
      expect(t.focused, isTrue);
      expect(t.toJson(), {'type': 'keyDown', 'key': 'Arrow Down', 'focused': true});
      expect(Trigger.fromJson({'type': 'keyDown'})!.focused, isFalse);
      expect(Trigger.fromJson({'type': 'keyDown'})!.toJson().containsKey('focused'), isFalse);
      expect(TriggerFields.all.map((f) => f.key), contains('focused'));
    });

    test('onKeyDown(key=ArrowDown, focused=true) reads into the trigger and prints back', () {
      const page = '''
state hour=8
Column#wheel onTap={} onKeyDown(key=ArrowDown, focused=true)={hour=hour + 1}
  Text "{hour}"
''';
      final r = _parse(page);
      expect(r.issues, isEmpty);
      final trigger = ((_node(r, 'wheel')['actions'] as List)[1] as Map)['trigger'] as Map;
      expect(trigger['focused'], isTrue);
      expect(printNotation(r.document, catalog: standardCatalog), contains('onKeyDown(key=ArrowDown, focused=true)={hour=hour + 1}'));
    });
  });

  group('a word that is an overlay with state of its own', () {
    const sheet = '''
define PickSheet "title" @value="" items=[]
  state query=""
  Sheet "{title}" ...
    Input#field "" "Search" @query
    each option in fuzzy(items, query, o => o)
      Row#option h=44 onTap={value=option; close}
        Text "{option}"
''';

    test('after the page at the margin: the overlay, its state the use\'s own, its value the page\'s', () {
      final r = _parse('''
state country="Chile"
${sheet}Column#page
  Button#opener "Country" onTap={open countries}
  Text "{country}"
PickSheet#countries "Country" @country items=["Chile","China"]
''');
      expect(r.issues, isEmpty);
      expect(_roots(r), ['screen', 'countries']);
      expect((_node(r, 'page')['children'] as List), hasLength(2), reason: 'nothing of the sheet is drawn in the page');
      expect(_variables(r).map((v) => v['name']), containsAll(['country', 'query_countries']));
      final field = _node(r, 'field_countries');
      expect((field['bind'] as Map)['props.initialValue'], r'${query_countries}');
    });

    test('two uses keep two queries', () {
      final r = _parse('''
state a=""
state b=""
${sheet}Column
  Button "A" onTap={open first}
  Button "B" onTap={open second}
PickSheet#first "A" @a items=["x"]
PickSheet#second "B" @b items=["y"]
''');
      expect(r.issues, isEmpty);
      expect(_roots(r), ['screen', 'first', 'second']);
      expect(_variables(r).map((v) => v['name']), containsAll(['query_first', 'query_second']));
    });
  });

  test('a switch\'s thumb takes a length of its own (a pill)', () {
    final r = _parse('''
state on=true
Toggle#sw w=48 h=24 @on fillTrack=true thumbInset=2 thumbWidth=28
''');
    expect(r.issues, isEmpty);
    expect((_node(r, 'sw')['props'] as Map)['thumbWidth'], 28);
    expect(printNotation(r.document, catalog: standardCatalog), contains('thumbWidth=28'));
  });

  group('an entrance\'s easing', () {
    test('curve= beside animate= is the animation\'s curve, and prints back', () {
      final r = _parse('Text#t "Sent" animate=fadeIn duration=200 curve=easeIn\n');
      expect(r.issues, isEmpty);
      final a = (_node(r, 't')['animations'] as List).single as Map;
      expect(a['curve'], 'easeIn');
      expect(a['duration'], 200);
      expect(printNotation(r.document, catalog: standardCatalog), contains('animate=fade duration=200 curve=easeIn'));
    });

    test('a curve with no animate, or one that is no curve, is said', () {
      expect(_parse('Text "Sent" curve=easeIn\n').issues.map((i) => i.message), contains(contains('curve= goes with animate=')));
      expect(_parse('Text "Sent" animate=fade curve=wobbly\n').issues.map((i) => i.message), contains(contains('No curve=wobbly')));
    });
  });

  group('a snapping scroll\'s fling and its camera', () {
    test('snapPhysics is a GesturePhysics on a page view and a list, read by field and printed back', () {
      final r = _parse('''
state n=0
Column
  Pages#reel @n h=180 scrollDirection=vertical peek=0.2 snapPhysics.friction=0.9 perspective=1
    each i in range(60)
      Text "{i}"
  ListView#cards h=200 itemSnapping=true snapPhysics={"friction":0.8}
    each i in range(9)
      Text "{i}"
''');
      expect(r.issues, isEmpty);
      final props = _node(r, 'reel')['props'] as Map;
      expect(props['snapPhysics'], {'friction': 0.9});
      expect(props['perspective'], 1);
      expect(GesturePhysics.fromJson(props['snapPhysics'])!.friction, 0.9);
      expect((_node(r, 'cards')['props'] as Map)['snapPhysics'], {'friction': 0.8});
      final printed = printNotation(r.document, catalog: standardCatalog);
      expect(printed, contains('perspective=1'));
      expect(printed, contains('snapPhysics'));
      expect(_parse(printed).document['nodes'], r.document['nodes']);
    });

    test('a fling projects where friction stops it: 1500 px/s at 0.865 coasts 749 px', () {
      expect(GesturePhysics.standard.projectFling(0, 1500), closeTo(1500 / 2.0025, 1));
      expect(GesturePhysics.standard.projectFling(100, 20), 100, reason: 'slower than minFlingVelocity: no coast');
    });
  });
}
