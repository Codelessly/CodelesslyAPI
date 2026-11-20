// What six builders hit writing apps and sites in the notation (test 9),
// each fixed at its cause: a site's own component named like a
// word of the notation is said; braces after `when` and on an action's value
// mean the expression; a nested `each` that reuses a name reads its own
// element and never touches a string literal.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _expand(String text, {NotationOptions options = const NotationOptions(reflow: false), Catalog? catalog}) {
  final c = catalog ?? standardCatalog;
  return Catalog.run(c, () => parseNotation(text, catalog: c, options: options));
}

Map<String, Object?> _nodes(NotationResult r) => (r.document['nodes']! as Map).cast<String, Object?>();

List<Map<String, Object?>> _of(NotationResult r, String type) => [
      for (final n in _nodes(r).values)
        if ((n! as Map)['type'] == type) (n as Map).cast<String, Object?>(),
    ];

void main() {
  group('the app\'s own component named like a word of the notation', () {
    final footer = LayoutDocument.fromJson({
      'schema': 3,
      'id': 'Footer',
      'roots': ['f'],
      'widget': {'type': 'Footer', 'doc': 'The foot.'},
      'nodes': {
        'f': {'type': 'column', 'children': <Object?>[]},
      },
    });
    final card = LayoutDocument.fromJson({
      'schema': 3,
      'id': 'Card',
      'roots': ['c'],
      'widget': {
        'type': 'Card',
        'doc': 'A card.',
        'props': [
          {'key': 'title', 'type': {'kind': 'string'}, 'default': ''},
        ],
      },
      'nodes': {
        'c': {'type': 'column', 'children': <Object?>[]},
      },
    });
    final catalog = standardCatalog + ComponentLibrary.of([footer, card]).catalog;
    const own = NotationOptions(width: 1280, reflow: false);

    test('is said, with how to call it, where the notation reads its word instead', () {
      final r = _expand('Page\n  Section\n    Card title="x"\n  Footer\n', catalog: catalog, options: own.withOwnComponents(['Footer', 'Card']));
      final said = r.issues.map((i) => i.message).toList();
      expect(said, contains(contains('the component Footer is not called')));
      expect(said, contains(contains('the component Card is not called')));
    });

    test('is called when the line says its type', () {
      final r = _expand('Page\n  Section\n    Card type=Card title="x"\n  Footer type=Footer\n', catalog: catalog, options: own.withOwnComponents(['Footer', 'Card']));
      expect(r.issues, isEmpty);
      expect({for (final n in _nodes(r).values) (n! as Map)['type']}, containsAll(['Footer', 'Card']));
    });

    test('a design system\'s component of such a name is not the app\'s own: no issue', () {
      final r = _expand('Page\n  Section\n    Text "x"\n  Footer\n', catalog: catalog, options: own);
      expect(r.issues, isEmpty);
    });
  });

  group('braces around an expression in a trigger or an action mean the expression', () {
    String all(NotationResult r) => jsonEncode(r.document);

    test('key … when {cond} holds as key … when cond does', () {
      final braced = _expand('state sel:list=[]\nstate n=0\nkey escape when {length(sel) > 0} onPress={n=1}\nColumn\n  Text "a"\n');
      final bare = _expand('state sel:list=[]\nstate n=0\nkey escape when length(sel) > 0 onPress={n=1}\nColumn\n  Text "a"\n');
      expect(braced.issues, isEmpty);
      expect(all(braced), all(bare));
      expect(all(braced), contains(r'"when":"${= length(sel) > 0}"'));
    });

    test('every … when {cond}, on backPressed(when={cond})', () {
      final r = _expand('state n=0\nevery 1s when {n < 3} onTick={n=n+1}\non backPressed(when={n > 0})={n=0}\nColumn\n  Text "a"\n');
      expect(r.issues, isEmpty);
      expect(all(r), contains(r'"when":"${= n < 3}"'));
      expect(all(r), contains(r'"when":"${= n > 0}"'));
      expect(all(r), isNot(contains(r'${= {')));
    });

    test('x={expr} in an action list, in a choice, after then, in a timer', () {
      final r = _expand('state n=0\nstate p=false\nevery 1s onTick={p={n < 2}}\nColumn\n'
          '  Button "a" onTap={n={n + 1}; p={!p}}\n'
          '  Button "b" onTap={n > 2 ? {n=0} : {n={n * 2}}}\n'
          '  Button "c" onTap={confirm "Sure?" then {n={n - 1}}}\n');
      expect(r.issues, isEmpty);
      for (final f in [r'${= n + 1}', r'${= !p}', r'${= n * 2}', r'${= n - 1}', r'${= n < 2}']) {
        expect(all(r), contains('"$f"'));
      }
      expect(all(r), isNot(contains(r'${= {')));
    });

    test('a map literal keeps its braces', () {
      final r = _expand('state m:map={}\nColumn\n  Button "a" onTap={m={a: 1}}\n  Button "b" onTap={m={}}\n  Button "c" onTap={m={"id": 2}}\n');
      expect(r.issues, isEmpty);
      expect(all(r), contains(r'"${= {a: 1}}"'));
      expect(all(r), contains(r'"${= {}}"'));
    });

    test('notationUnbraced', () {
      expect(notationUnbraced('{a > 0}'), 'a > 0');
      expect(notationUnbraced('{{a}}'), 'a');
      expect(notationUnbraced('{a ? {b: 1} : {}}'), 'a ? {b: 1} : {}');
      expect(notationUnbraced('{a: 1}'), '{a: 1}');
      expect(notationUnbraced("{'k': 1}"), "{'k': 1}");
      expect(notationUnbraced('{a} + {b}'), '{a} + {b}');
      expect(notationUnbraced('{"}"}'), '"}"');
    });
  });

  group('a nested each', () {
    test('an inner each that reuses the name reads its own element', () {
      final r = _expand('state groups:list=[{"key":"a","items":["x","y"]}]\nColumn\n  each item in groups\n    Text "{item.key}"\n    each item in item.items\n      Text "{item}"\n');
      expect(r.issues, isEmpty);
      final texts = [for (final t in _of(r, 'text')) (t['props']! as Map)['text']];
      expect(texts, [r'${item.key}', r'${item}']);
      expect(jsonEncode(r.document), contains(r'"data":"${item.items}"'));
    });

    test('an inner each with its own name reads the outer as parent.item', () {
      final r = _expand('state groups:list=[]\nColumn\n  each g in groups\n    each m in g.items\n      Text "{g.key} {m}"\n');
      expect(r.issues, isEmpty);
      expect((_of(r, 'text').single['props']! as Map)['text'], r'${parent.item.key} ${item}');
    });

    test('a loop name inside a string literal is left alone', () {
      final r = _expand("state ms:list=[]\nColumn\n  each m in ms\n    Text \"{'m-' + m.id}\"\n");
      expect(r.issues, isEmpty);
      expect((_of(r, 'text').single['props']! as Map)['text'], r"${= 'm-' + item.id}");
    });
  });

  test('focus names a component\'s field by the call\'s id and its own', () {
    final r = _expand('state n=0\nkey k onPress={focus filters/search}\nColumn\n  Text "a"\n');
    expect(r.issues, isEmpty);
    expect(jsonEncode(r.document), contains('"node":"filters/search"'));
  });

  group('components', () {
    test('emit "…{result}…" sends the value, not the braces', () {
      final r = _expand('component Nav "x"\n  event onNavigate:String\nColumn#n\n  Button "a" onTap={emit onNavigate "{result}"}\n  Button "b" onTap={emit onNavigate "page-{result}"}\n');
      expect(r.issues, isEmpty);
      expect(jsonEncode(r.document), contains(r'"value":"${result}"'));
      expect(jsonEncode(r.document), contains(r'"value":"page-${result}"'));
    });

    test('a parameter of records: List<Map>, Map, dynamic, and a default list of maps', () {
      final r = _expand('component Code "x"\n  param snippets:List<Map>=[]\n  param opts:Map={}\n  param any:dynamic=null\n  param rows=[{"a":1}]\nColumn#c\n  Text "x"\n');
      expect(r.issues, isEmpty);
      final props = {for (final p in ((r.document['widget']! as Map)['props']! as List).cast<Map>()) p['key']: p['type']};
      expect(props['snippets'], {'kind': 'list', 'flutter': 'List<Map>', 'item': {'kind': 'json', 'flutter': 'Map'}});
      expect(props['opts'], {'kind': 'json', 'flutter': 'Map'});
      expect((props['rows']! as Map)['item'], {'kind': 'json', 'flutter': 'dynamic'});
      final printed = printNotation(r.document, catalog: standardCatalog);
      expect(printed, contains('param snippets:List<Map>'));
    });

    test('an Avatar of a name read from state shows its initials', () {
      final r = _expand('state name="Ada Lovelace"\nColumn\n  Avatar "{name}"\n  Avatar "Maya Reyes"\n');
      expect(r.issues, isEmpty);
      final texts = [for (final t in _of(r, 'text')) (t['props']! as Map)['text']];
      expect(texts.first, contains('left(w, 1)'));
      expect(texts.first, contains('name'));
      expect(texts.last, 'MR');
    });
  });

  group('lists and placing', () {
    test('each in a horizontal Flex runs across, as in a Row', () {
      final r = _expand('state ps:list=[]\nColumn\n  Flex direction=horizontal gap=12\n    each p in ps\n      Column w=200\n        Text "{p}"\n');
      expect(r.issues, isEmpty);
      expect((_of(r, 'listView').single['props']! as Map)['scrollDirection'], 'horizontal');
    });

    test('a text or a row placed in a stack by x or y hugs; one under an each too', () {
      final r = _expand('state ms:list=[]\nStack w=600 h=40\n  Text#t x=100 y=20 "label"\n  each m in ms\n    Row#flag x={m.t * 5} y=0 h=14\n      Text "B"\n  box#bg x=0 y=0 h=4\n');
      expect(r.issues, isEmpty);
      Object? w(String id) => ((_nodes(r)[id]! as Map)['layout']! as Map)['width'];
      expect(w('t'), {'hug': 0});
      expect(w('flag'), {'hug': 0});
      expect(w('bg'), {'fill': 0}, reason: 'a box with nothing in it still fills');
    });
  });

  test('confirm with the action\'s own field names before then', () {
    final words = _expand('state n=0\nColumn\n  Button "x" onTap={confirm "Delete this message?" message="It goes to the bin." confirmLabel="Delete" destructive=true then {n=1}}\n');
    final short = _expand('state n=0\nColumn\n  Button "x" onTap={confirm "Delete this message?" "It goes to the bin." ok="Delete" danger then {n=1}}\n');
    final titled = _expand('state n=0\nColumn\n  Button "x" onTap={confirm title="Delete this message?" message="It goes to the bin." confirmLabel="Delete" destructive=true then {n=1}}\n');
    expect(words.issues, isEmpty);
    expect(titled.issues, isEmpty);
    expect(jsonEncode(words.document), jsonEncode(short.document));
    expect(jsonEncode(titled.document), jsonEncode(short.document));
  });

  test('a side border follows data: border-bottom={…}', () {
    final r = _expand('state on=true\nColumn\n  Column#c border-bottom={on ? accent : transparent}\n    Text "a"\n');
    expect(r.issues, isEmpty);
    final c = _nodes(r)['c']! as Map;
    expect((c['decoration']! as Map)['strokeSides'], 'bottom');
    expect((c['bind']! as Map)['decoration.strokes[0].color'], isNotNull);
  });

  test('a bare word that is the theme\'s colour or style, or a variable\'s name after a key that names one, is a word', () {
    final theme = NotationOptions.fromTheme(const {
      'colors': {'panel': '#FF222222'},
      'textStyles': {
        'tick': {'fontSize': 11},
      },
    }, reflow: false);
    final r = _expand('state panel="x"\nstate tick=1\nstate pos:map={}\nColumn fill=panel\n  Text "a" style=tick\n  Column measure.variable=pos\n    Text "b"\n', options: theme);
    expect(r.issues, isEmpty);
    final braced = _expand('state panel="x"\nColumn fill=panel\n  Text "a"\n');
    expect(braced.issues.single.message, contains('fill={panel}'), reason: 'with no theme of that name it is still said');
  });

  test('FilterChip @name keeps whether it is on', () {
    final r = _expand('state fUnread=false\nColumn\n  FilterChip "Unread" @fUnread\n');
    expect(r.issues, isEmpty);
    final chip = _of(r, 'filterChip').single;
    expect((chip['bind']! as Map)['props.selected'], r'${fUnread}');
    expect(jsonEncode(chip['actions']), contains('"variable":"fUnread"'));
  });

  // A chat written in one pass (nocd chat): every message bubble, and every
  // photo, drew nothing, with no word.
  group('a component\'s slot, a box with a picture, a place outside a Stack', () {
    test('a Slot with no name, in a component that declares a slot and takes no children, is that slot', () {
      final r = _expand('component Side "A row."\n  param own=false\n  slot content\nColumn w=fill\n  if props.own\n    Row w=fill\n      Spacer\n      Slot\n  else\n    Row w=fill\n      Slot\n      Spacer\n');
      expect(r.issues, isEmpty);
      expect([for (final s in _of(r, 'slot')) (s['props']! as Map)['name']], ['content', 'content']);
    });

    test('a Slot with no name stays the call\'s children where the head takes children', () {
      final r = _expand('component Chip "A chip." children=list\n  slot leading\nRow\n  Slot name=leading\n  Slot\n');
      expect(r.issues, isEmpty);
      expect([for (final s in _of(r, 'slot')) (s['props'] as Map?)?['name']], ['leading', null]);
    });

    test('a Slot naming a slot the head does not declare is said', () {
      final r = _expand('component Side "A row."\n  slot content\nRow\n  Slot name=body\n');
      expect(r.issues.single.message, contains('declares no slot "body"'));
      expect(r.issues.single.message, contains('Its slots: content'));
    });

    test('a box of a fixed height keeps it with a picture that fills it and a text, in either order', () {
      for (final text in [
        'Column\n  Box w=280 h=210\n    Box w=fill h=fill fill=#FF9AD1F5\n    Text "GIPHY"\n',
        'Column\n  Box w=280 h=210\n    Text "GIPHY"\n    Box w=fill h=fill fill=#FF9AD1F5\n',
      ]) {
        final r = _expand(text);
        expect(r.issues, isEmpty, reason: text);
        final box = _of(r, 'column').firstWhere((n) => (n['layout']! as Map)['width'] == 280);
        expect((box['layout']! as Map)['height'], 210, reason: text);
        expect(((box['layout']! as Map)['constraints'] as Map?)?['minHeight'], isNull, reason: text);
      }
      // With no picture that fills it, a text still makes the height a least one.
      final grows = _expand('Column\n  Box w=280 h=60\n    Text "A long caption"\n');
      final box = _of(grows, 'column').firstWhere((n) => (n['layout']! as Map)['width'] == 280);
      expect((box['layout']! as Map)['height'], {'hug': 60});
    });

    test('x and y under a Column or a Row are said; in a Stack they place', () {
      final r = _expand('Column\n  Box w=280 h=210\n    Text "GIPHY" x=8 y=8\n');
      expect(r.issues.single.message, startsWith('x places a line only in a Stack'));
      expect(r.issues.single.line, 3);
      expect(r.issues.single.column, 18);
      expect(_expand('Column\n  Stack w=280 h=210\n    Text "GIPHY" x=8 y=8\n').issues, isEmpty);
    });
  });
}
