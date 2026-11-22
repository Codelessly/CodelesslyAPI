// What a formula reads, wherever it is written: a definition's parameter in
// braces inside a formula, a function's own parameter beside a state of the
// same name, a state written in braces, and a worked-out state that is set.
// And what the reader says of a line it does not take: the line to write.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/notation_site.dart';
import 'package:test/test.dart';

import 'notation_words.dart';

const _theme = <String, Object?>{'primary': '#FF1F3A5F', 'surface': '#FFFFFFFF', 'onSurface': '#FF18181B'};

NotationResult _parse(String text, {bool open = false, Map<String, Object?> theme = _theme}) =>
    parseNotation(text, catalog: standardCatalog, options: withTestWords(NotationOptions.fromTheme(theme, named: true, width: 1440).open(openVocabulary: open)));

String _doc(NotationResult r) => jsonEncode(r.document);

List<String> _said(NotationResult r) => [for (final i in r.issues) i.message];

/// What the open vocabulary says of [word] (a stand-in's `say`).
String? _say(NotationResult r, String word) => r.vocabulary.where((u) => u.word == word && u.say != null).firstOrNull?.say;

void main() {
  group('a definition\'s parameter inside a formula', () {
    const page = '''
state listings=[{"id":"a","name":"A"},{"id":"b","name":"B"}]
Page
  each it in listings
    ListingCard "{it.id}"
  ListingCard "a"
''';

    for (final written in ['{id}', 'id', '{ id }']) {
      test('written $written: the value the use gives, in the formula', () {
        final r = _parse('define ListingCard "id"\n  Column gap=4\n    each l in filter(listings,x=>x.id==$written)\n      Text "{l.name}"\n$page');
        expect(r.issues, isEmpty);
        final doc = _doc(r);
        expect(doc, contains(r'${= filter(listings,x=>x.id==(item.id))}'));
        expect(doc, contains(r'${= filter(listings,x=>x.id==\"a\")}'));
        expect(doc, isNot(contains('=={')));
      });
    }

    test('a state in braces inside a formula of a page is that state; a record stays a record', () {
      final r = _parse('''
state rows=[{"id":"a"}]
state sel="a"
state n=2
Page
  each l in filter(rows,x=>x.id=={sel})
    Text "{l.id}"
  Text#sum "{sum(map(rows, x => {n + 1} * 2))}"
  Text#rec "{length(map(rows, x => {"id": x.id, "on": x.id=={sel}}))}"
''');
      expect(r.issues, isEmpty);
      final doc = _doc(r);
      expect(doc, contains(r'${= filter(rows,x=>x.id==sel)}'));
      expect(doc, contains('(n + 1) * 2'));
      expect(doc, contains(r'{\"id\": x.id, \"on\": x.id==sel}'));
    });
  });

  group('a function\'s own parameter', () {
    test('named like a worked-out state is the function\'s, and the state is written out beside it', () {
      final r = _parse('''
state xs=[{"a":1},{"a":2}]
state n=2
state top={n*2}
Page
  Text#a "{join(map(xs, top=>top.a), ',')}"
  Text#b "{top}"
  each v in map(xs, top=>top.a)
    Text "{v}"
  Text#c "{sum(map(xs, top=>top.a)) + top}"
''');
      expect(r.issues, isEmpty);
      final doc = _doc(r);
      expect(doc, contains(r"${= join(map(xs, top=>top.a), ',')}"));
      expect(doc, contains(r'"data":"${= map(xs, top=>top.a)}"'));
      expect(doc, contains(r'${= (n*2)}'));
      expect(doc, contains('sum(map(xs, top=>top.a)) + (n*2)'));
    });

    test('named like the item of the each around it is the function\'s', () {
      final r = _parse('''
state xs=[{"a":1}]
Page
  each top in xs
    Text "{join(map(xs, (top, i)=>top.a + i), ',')} {top.a}"
''');
      expect(r.issues, isEmpty);
      expect(_doc(r), contains(r"${= join(map(xs, (top, i)=>top.a + i), ',')} ${item.a}"));
    });
  });

  group('a name that is called', () {
    test('is the formulas\' own function, beside a worked-out state of that name', () {
      final r = _parse('''
state cart=[{"qty":2}]
state cats=["a","b"]
state count={sum(cart,l=>l.qty)}
state active={cats[max(0,count(range(2),i=>i<1)-1)]}
Page
  Text#a "{count(cart,l=>l.qty>1)} of {count}"
  Text#b "{active}"
''');
      expect(r.issues, isEmpty);
      final doc = _doc(r);
      expect(doc, contains('count(cart,l=>l.qty>1)'));
      expect(doc, contains('(sum(cart,l=>l.qty))'));
      expect(doc, contains('count(range(2),i=>i<1)'));
      expect(doc, isNot(contains('(sum(cart,l=>l.qty))(')));
    });

    test('is the function under an each whose item has its name', () {
      final r = _parse('state rows=[[1,2],[3]]\nPage\n  each count in rows\n    Text "{count(count,x=>x>1)} {length(count)}"\n');
      expect(r.issues, isEmpty);
      expect(_doc(r), contains('count(item,x=>x>1)'));
    });
  });

  group('a choice whose first branch is several actions with no braces', () {
    List<Object?> actionsOf(NotationResult r, String id) => ((((r.document['nodes'] as Map)[id] as Map)['actions'] as List).single as Map)['actions'] as List;

    test('is that choice: the actions before the colon are its branch', () {
      final r = _parse('state draft=""\nstate items=[]\nstate n=0\nPage\n'
          '  Button#b "Add" onTap={draft!="" ? items=append(items,draft); n=n+1; draft="" : toast "Type an item first"}\n'
          '  Button#c "Add" onTap={draft!="" ? {items=append(items,draft); n=n+1; draft=""} : toast "Type an item first"}\n');
      expect(r.issues, isEmpty);
      final written = actionsOf(r, 'b'), braced = actionsOf(r, 'c');
      expect(jsonEncode(written), jsonEncode(braced));
      expect(written, hasLength(1));
      final choice = written.single as Map;
      expect(choice['type'], 'if');
      expect((choice['then'] as List).map((a) => (a as Map)['variable']), ['items', 'n', 'draft']);
      expect(((choice['else'] as List).single as Map)['type'], 'showToast');
    });

    test('a choice with no else, a link\'s colon, and a value chosen stay as they are', () {
      final r = _parse('state ok=true\nstate n=0\nstate m=0\nPage\n'
          '  Button#a "A" onTap={ok ? n=1; m=2}\n'
          '  Button#b "B" onTap={ok ? n=1; link https://example.com/a}\n'
          '  Button#c "C" onTap={n = ok ? 1 : 2; m=3}\n');
      expect(r.issues, isEmpty);
      expect(actionsOf(r, 'a').map((a) => (a as Map)['type']), ['if', 'setVariable']);
      expect(actionsOf(r, 'b'), hasLength(2));
      expect(actionsOf(r, 'c').map((a) => (a as Map)['type']), ['setVariable', 'setVariable']);
    });
  });

  group('a state written in braces is worked out', () {
    const formulas = {
      'cur%12': '(cur%12)',
      'a': 'a',
      'cur-1': '(cur-1)',
      'cur>3': '(cur>3)',
      'cur<=3': '(cur<=3)',
      'cur!=3': '(cur!=3)',
      'cur==3': '(cur==3)',
      'cur/2': '(cur/2)',
      'cur*2': '(cur*2)',
      'cur+1': '(cur+1)',
      '-a': '-a',
      '!on': '!on',
      'cur==3&&a>1': '(cur==3&&a>1)',
      'on||cur>1': '(on||cur>1)',
      'a?1:2': '(a?1:2)',
      'rec.b': 'rec.b',
      'xs[0]': 'xs[0]',
    };
    for (final e in formulas.entries) {
      test('state v={${e.key}}', () {
        final r = _parse('state cur=14\nstate a=3\nstate on=true\nstate rec={"b":1}\nstate xs=[1,2]\nstate v={${e.key}}\nPage\n  Text#t "{v}"\n  Button "Up" onTap={cur=cur+1; a=a+1}\n');
        expect(r.issues, isEmpty);
        // Not a variable that holds the text: the formula where it is read.
        final names = [for (final v in ((r.document['variables'] as Map)['screen'] as List)) (v as Map)['name']];
        expect(names, isNot(contains('v')));
        final text = (((r.document['nodes'] as Map)['t'] as Map)['props'] as Map)['text'] as String;
        expect(text.replaceAll(' ', ''), contains(e.value.replaceAll(' ', '')), reason: text);
        expect(text, isNot(contains('"${e.key}"')));
      });
    }

    test('a value in braces stays a value', () {
      final r = _parse('state rec={"b":1}\nstate none={}\nstate n={3}\nstate t={"x"}\nPage\n  Text "{rec.b} {n} {t}"\n');
      expect(r.issues, isEmpty);
      final vars = {for (final v in ((r.document['variables'] as Map)['screen'] as List)) (v as Map)['name']: v['value']};
      expect(vars['rec'], {'b': 1});
      expect(vars.containsKey('none'), isTrue);
    });
  });

  group('a worked-out state that reads no state', () {
    test('set by an action: said, with the start value and the on load line to write', () {
      final r = _parse('state day={today()}\nPage\n  Text "{day}"\n  Button "Next" onTap={day=addDays(day,1)}\n');
      expect(_said(r), hasLength(1));
      expect(_said(r).single, allOf(contains('day is worked out'), contains('state day=""'), contains('on load={day=today()}')));
      expect(r.issues.single.line, 4);
    });

    test('a number: its start is 0', () {
      final r = _parse('state roll={floor(random()*6)}\nPage\n  Button "Roll" onTap={roll=floor(random()*6)}\n');
      expect(_said(r).single, allOf(contains('state roll=0'), contains('on load={roll=floor(random()*6)}')));
    });

    test('only read: nothing is said, and it follows the clock', () {
      final r = _parse('state day={today()}\nPage\n  Text#t "{formatDate(day, "MMM d")}"\n');
      expect(r.issues, isEmpty);
      expect(_doc(r), contains('today()'));
    });

    test('one that reads a state and is set too keeps following the state, with nothing said', () {
      final r = _parse('state n=1\nstate twice={n*2}\nPage\n  Text "{twice}"\n  Button "Up" onTap={n=n+1; twice=n*2}\n');
      expect(r.issues, isEmpty);
    });

    test('the start value and the on load line it says expand with no issue', () {
      final r = _parse('state day=""\non load={day=today()}\nPage\n  Text "{day}"\n  Button "Next" onTap={day=addDays(day,1)}\n');
      expect(r.issues, isEmpty);
    });
  });

  group('a line under a word that takes none', () {
    const text = 'Page\n  Handle\n    Icon "grip"\n  Divider\n    Text "x"\n';

    test('with the open vocabulary: what stands in says where the line goes, and the key that names it', () {
      final r = _parse(text, open: true);
      expect(r.issues, isEmpty);
      expect(_say(r, 'Handle'), allOf(contains('A Handle takes no lines under it'), contains('Handle icon="grip"')));
      expect(_say(r, 'Divider'), allOf(contains('A Divider takes no lines under it'), isNot(contains('='))));
    });

    test('with the closed vocabulary: the same words as an issue', () {
      final r = _parse(text);
      expect(_said(r), [
        allOf(contains('A Handle takes no lines under it'), contains('Handle icon="grip"')),
        contains('A Divider takes no lines under it'),
      ]);
    });

    test('a defined word with no Slot line says to give it one', () {
      final r = _parse('define Pill "label"\n  Badge "{label}"\nPage\n  Pill "a"\n    Text "under"\n', open: true);
      expect(_say(r, 'Pill'), allOf(contains('takes no lines under it'), contains('Slot line')));
    });

    test('what is recorded of a line carries that line and the lines it is under', () {
      final r = _parse('Page\n  Box w=40 h=40\n    customPaint\n      circle c=[1,2] cy=3 radius=4 fill=#FF000000\n', open: true);
      final use = r.vocabulary.singleWhere((u) => u.word == 'cy');
      expect(use.source, 'circle c=[1,2] cy=3 radius=4 fill=#FF000000');
      expect(use.path, ['Page', 'Box', 'customPaint']);
      expect((use.line, use.column), (4, 22));
    });
  });

  group('what is said of a key a word does not take says the line to write', () {
    test('a list given to a word whose lines are what it shows: the each to write', () {
      final r = _parse('state routes=[{"t":"a"}]\nstate slide=0\nPage\n  Pages @slide h=230 items=routes\n    Text "x"\n  Column data={routes}\n    Text "y"\n', open: true);
      expect(_say(r, 'items'), allOf(contains('Under the Pages write: each r in routes'), contains('{r.')));
    });

    test('a place in the Tab order: a tapped line has one', () {
      final open = _parse('Page\n  Text "Note 1" tabIndex=0\n', open: true);
      expect(_say(open, 'tabIndex'), allOf(contains('Tab stop already'), contains('onTap={')));
      final closed = _parse('Page\n  Text "Note 1" tabIndex=0\n');
      expect(_said(closed).single, contains('Tab stop already'));
    });

    test('a circle\'s cy: its center is one key', () {
      final open = _parse('Page\n  Box w=40 h=40\n    customPaint\n      circle c=[1,2] cy=3 radius=4 fill=#FF000000\n', open: true);
      expect(_say(open, 'cy'), allOf(contains('did you mean c?'), contains('c=[x,y]')));
      final closed = _parse('Page\n  Box w=40 h=40\n    customPaint\n      circle c=[1,2] cy=3 radius=4 fill=#FF000000\n');
      expect(_said(closed).single, contains('c=[x,y]'));
    });

    test('an action the notation does not have: what an action is, and that it is written out', () {
      final open = _parse('state n=0\nPage\n  Button "Start" onTap={startConvo; close}\n', open: true);
      expect(open.issues, isEmpty);
      expect(_say(open, 'startConvo'), allOf(startsWith('Unknown action "startConvo". Actions: name=value'), contains('write the actions it stands for here')));
      final closed = _parse('state n=0\nPage\n  Button "Start" onTap={startConvo; close}\n');
      expect(_said(closed).single, startsWith('Unknown action "startConvo". Actions: name=value'));
    });

    test('a text a definition of the page does not name: the first line to write', () {
      final none = _parse('define CasaNav\n  Row\n    Text "Casa"\nPage\n  CasaNav "home"\n', open: true);
      expect(_say(none, 'string1'), allOf(startsWith('A CasaNav takes no text: its definition names no parameter, so "home" is left out.'), contains('define CasaNav "text"'), contains('{text}')));
      final one = _parse('define CasaNav "current"\n  Row\n    Text "{current}"\nPage\n  CasaNav "home" "more"\n', open: true);
      expect(_say(one, 'string2'), allOf(startsWith('A CasaNav takes one text. It takes: "current", so "more" is left out.'), contains('define CasaNav "current" "text2"')));
      // The line it says is one the reader takes.
      final fixed = _parse('define CasaNav "text"\n  Row\n    Text "{text}"\nPage\n  CasaNav "home"\n', open: true);
      expect(fixed.issues, isEmpty);
      expect(fixed.vocabulary.where((u) => u.kind == 'parameter'), isEmpty);
    });

    test('an overlay at the margin of a word\'s file: indent it under the word\'s define', () {
      final site = NotationSiteFiles(
        {
          'pages/home.txt': 'Column\n  PlayerBar\n',
          'components/PlayerBar.txt': 'define PlayerBar\n  Row\n    Button "Open" onTap={open player}\nSheet#player "Now playing" stops=[0.5,0.95]\n  Text "Song"\nstray words\n',
        },
        catalog: standardCatalog,
      );
      final said = [for (final p in site.problems) '${p.path}:${p.line} ${p.message}'];
      expect(said, [
        allOf(startsWith('components/PlayerBar.txt:4 `Sheet#player "Now playing" stops=[0.5,0.95]` is in no definition'),
            contains('For PlayerBar to write Sheet#player'), contains('indent this line and the lines under it by two spaces')),
        allOf(startsWith('components/PlayerBar.txt:6 `stray words` is in no definition'), isNot(contains('indent this line'))),
      ]);
      // Written as it says, it is the word's.
      final fixed = NotationSiteFiles(
        {
          'pages/home.txt': 'Column\n  PlayerBar\n',
          'components/PlayerBar.txt': 'define PlayerBar\n  Row\n    Button "Open" onTap={open player}\n  Sheet#player "Now playing" stops=[0.5,0.95]\n    Text "Song"\n',
        },
        catalog: standardCatalog,
      );
      expect(fixed.problems, isEmpty);
    });

    test('a parameter a definition of the page does not name: the first line to write', () {
      final none = _parse('define ProductCard\n  Card\n    Text "x"\nstate ps=[{"n":1}]\nPage\n  each p in ps\n    ProductCard p={p}\n', open: true);
      expect(_say(none, 'p'), allOf(contains('its definition names no parameter'), contains('define ProductCard p={}')));
      final some = _parse('define ProductCard "title"\n  Card\n    Text "{title}"\nstate ps=[{"n":1}]\nPage\n  each p in ps\n    ProductCard "a" p={p}\n', open: true);
      expect(_say(some, 'p'), allOf(contains('It takes: "title"'), contains('define ProductCard "title" p={}')));
      // The line it says is one the reader takes.
      final fixed = _parse('define ProductCard "title" p={}\n  Card\n    Text "{title} {p.n}"\nstate ps=[{"n":1}]\nPage\n  each p in ps\n    ProductCard "a" p={p}\n', open: true);
      expect(fixed.issues, isEmpty);
      expect(fixed.vocabulary.where((u) => u.kind == 'parameter'), isEmpty);
    });
  });
}
