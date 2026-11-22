// What the NOCD rebuild (30 parts written from the reference alone) found
// the notation read wrongly, with no word: a Stack child's `align=` left
// unread, a Column centered along itself but not across, an `if` action's
// condition kept as text (its else ran), paints in other shapes that drew
// nothing, a pattern's count read as a value, and a nullable type refused
// with a message that said nothing of types.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

NotationResult _read(String text) => parseNotation(text, catalog: standardCatalog, options: const NotationOptions(width: 390));

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast();

Map<String, Object?> _layout(NotationResult r, String id) => ((_node(r, id)['layout'] as Map?) ?? const {}).cast();

List<Map<String, Object?>> _actions(NotationResult r, String id) =>
    [for (final a in ((_node(r, id)['actions'] as List).first as Map)['actions'] as List) (a as Map).cast<String, Object?>()];

void main() {
  group('align= on a child of a Stack places it on both axes', () {
    test('align=center is x and y aligned at 0, and a child with no width hugs', () {
      final r = _read('Stack w=fill h=fill\n  Box#b w=206 h=206 align=center\n  Text#t "Share" align=center\n');
      expect(r.issues, isEmpty);
      expect(_layout(r, 'b'), allOf(containsPair('x', {'align': 0.0}), containsPair('y', {'align': 0.0}), isNot(contains('align'))));
      expect(_layout(r, 't'), allOf(containsPair('x', {'align': 0.0}), containsPair('y', {'align': 0.0}), containsPair('width', {'hug': 0})));
    });

    test('a named corner is its two places, and a place written on an axis wins', () {
      final r = _read('Stack w=200 h=120\n  Box#b w=20 h=20 align=bottomRight\n  Box#c w=20 h=20 align=center y=8\n');
      expect(_layout(r, 'b'), allOf(containsPair('x', {'align': 1.0}), containsPair('y', {'align': 1.0})));
      expect(_layout(r, 'c')['x'], {'align': 0.0});
      expect(_layout(r, 'c')['y'], isNot({'align': 0.0}));
    });

    test('under a Column align= is still the child\'s own alignment in its slot', () {
      final r = _read('Column w=fill\n  Box#b w=20 h=20 align=center\n');
      expect(_layout(r, 'b')['align'], 'center');
      expect(_layout(r, 'b'), isNot(contains('x')));
    });
  });

  group('a Column centered along itself in the API\'s words centers across too', () {
    test('mainAxisAlignment=center with no cross alignment: center across, as a Row does', () {
      final r = _read('Stack w=fill h=fill\n  Column#c w=fill h=fill mainAxisAlignment=center\n    Box w=40 h=40\n');
      expect((_node(r, 'c')['props'] as Map)['crossAxisAlignment'], 'center');
    });

    test('a cross alignment written stays, and middle alone stays down only (as the reference says)', () {
      final r = _read('Column#a h=400 mainAxisAlignment=center crossAxisAlignment=end\n  Box w=4 h=4\nColumn#b h=400 middle\n  Box w=4 h=4\n');
      expect((_node(r, 'a')['props'] as Map)['crossAxisAlignment'], 'end');
      expect((_node(r, 'b')['props'] as Map)['crossAxisAlignment'], 'start');
    });
  });

  group('an if action\'s condition worked out is a predicate', () {
    test('condition={a || b} holds when the value is true; it was the bare text, and else ran', () {
      final r = _read('state a=true\nstate b=false\nstate r=""\nButton#go "Go" onTap={if condition={a || b} then={r="yes"} else={r="no"}}\n');
      expect(r.issues, isEmpty);
      final action = _actions(r, 'go').single;
      expect(action['type'], 'if');
      expect(action['condition'], {'left': r'${= a || b}', 'op': 'isTrue'});
      expect(Predicate.fromJson(action['condition']), isNotNull);
    });

    test('a predicate written as one stays as written, and when= on any action is read so too', () {
      final r = _read('state ok=true\nstate r=""\nButton#go "Go" onTap={if condition={"left":"\${ok}","op":"isTrue"} then={r="y"}; setVariable variable=r value=z when={ok}}\n');
      final actions = _actions(r, 'go');
      expect(actions.first['condition'], {'left': r'${ok}', 'op': 'isTrue'});
      expect(actions.last['when'], {'left': r'${ok}', 'op': 'isTrue'});
    });

    test('if written as in a language is an issue naming the form to write', () {
      for (final line in ['onTap={if details {r=1} else {r=2}}', 'onTap={if phase < 4 then {r=1} else {r=2}}', 'onTap={when(ok){r=1}}']) {
        final r = _read('state details=true\nstate phase=1\nstate ok=true\nstate r=0\nButton#go "Go" $line\n');
        expect(r.issues.single.message, allOf(contains('cond ? {actions} : {actions}'), contains('if condition={ready} then=')), reason: line);
        expect(r.issues.single.message, isNot(contains('Did you mean "if"')));
      }
    });
  });

  group('a paint in another shape draws', () {
    List<Object?> fills(NotationResult r, String id) => ((_node(r, id)['decoration'] as Map)['fills'] as List);

    test('"colors" with "stops" as numbers (Flutter\'s LinearGradient) is stops of the paint\'s shape', () {
      final r = _read('Box#b w=200 h=80 fills=[{"type":"linear","colors":["#FFFF0000","#FF00FF00","#FF0000FF"],"stops":[0,0.56,1]}]\n');
      expect(r.issues, isEmpty);
      final p = fills(r, 'b').single as Map;
      expect(p.containsKey('colors'), isFalse);
      expect(p['stops'], [
        {'position': 0.0, 'color': '#FFFF0000'},
        {'position': 0.56, 'color': '#FF00FF00'},
        {'position': 1.0, 'color': '#FF0000FF'},
      ]);
      expect(Paint.fromJson(p)!.stops, hasLength(3));
    });

    test('a whole paint in fill= is the fill (it was kept as a color, and drew nothing)', () {
      final r = _read('Box#b w=200 h=80 fill={"type":"linear","colors":["#FFFF0000","#FF0000FF"]}\nBox#i w=40 h=40 fill={"type":"image","image":{"url":"a.png"},"fit":"contain"}\n');
      expect(r.issues, isEmpty);
      final p = fills(r, 'b').single as Map;
      expect(p['type'], 'linear');
      expect(p['stops'], hasLength(2));
      expect((fills(r, 'i').single as Map)['type'], 'image');
    });

    test('stops as numbers with no colors are said; colors and stops that do not pair are spread and said', () {
      final r = _read('Box#b w=20 h=20 fills=[{"type":"linear","stops":[0,1]}]\n');
      expect(r.issues.single.message, contains('stops are records'));
      final r2 = _read('Box#b w=20 h=20 fills=[{"type":"linear","colors":["#FFFF0000","#FF0000FF"],"stops":[0]}]\n');
      expect(r2.issues.single.message, contains('spread evenly'));
      expect((fills(r2, 'b').single as Map)['stops'], hasLength(2));
    });

    test('paints already in their shape are left as they are', () {
      const fill = '[{"type":"linear","stops":[{"position":0,"color":"#FFFF0000"},{"position":1,"color":"#FF0000FF"}]}]';
      final r = _read('Box#b w=20 h=20 fills=$fill\n');
      expect(r.issues, isEmpty);
      expect(jsonEncode(fills(r, 'b')), contains('"position":0'));
    });
  });

  group('a pattern\'s count in quoted text is the pattern\'s', () {
    test('{2,} in a regex in an action\'s choice is kept; the formula parses', () {
      final r = _read('state email=""\nstate r=""\nButton#go "Go" onTap={matches(email, \'^[a-z]+@[a-z]+[.][a-z]{2,}\$\') ? r="ok" : r="no"}\n');
      expect(r.issues, isEmpty);
      final left = ((_actions(r, 'go').single['condition'] as Map)['left'] as String);
      expect(left, contains('[a-z]{2,}'));
      expect(left, isNot(contains('(2,)')));
    });

    test('{10} and {2,5} are kept too, and a value in braces in quoted text is still read', () {
      final r = _read('state phone=""\nstate n=3\nstate r=""\nButton#go "Go" onTap={matches(phone, \'^[0-9]{10}\$\') || matches(phone, \'^[0-9]{2,5}\$\') ? r="ok" : r="Only {n} left"}\n');
      final a = _actions(r, 'go').single;
      final left = (a['condition'] as Map)['left'] as String;
      expect(left, allOf(contains('{10}'), contains('{2,5}')));
      expect(jsonEncode(a['else']), contains(r'${n}'));
    });
  });

  group('a nullable type', () {
    test('state p:Map?=null is a map that starts as null', () {
      final r = _read('state deletePayload:Map?=null\nText "{deletePayload == null ? \'none\' : deletePayload.id}"\n');
      expect(r.issues, isEmpty);
      final v = ((r.document['variables'] as Map).values.expand((l) => l as List).cast<Map>()).firstWhere((v) => v['name'] == 'deletePayload');
      expect(v['type'], 'map');
      expect(v['value'], isNull);
    });

    test('a type that is not one of the notation\'s says the types and that any may be null', () {
      final r = _read('state flag:bool=true\nstate items:List<String>=[]\nText "x"\n');
      expect(r.issues, hasLength(2));
      expect(r.issues.first.message, allOf(contains('state flag:boolean=true'), contains('may start as null')));
      expect(r.issues.last.message, allOf(contains('state items:list=[]'), contains('"List<String>" is not one')));
    });
  });
}
