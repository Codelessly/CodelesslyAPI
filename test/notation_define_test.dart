// Words defined in the notation itself (docs/design/20-defined-words.md): a
// definition's signature and lines, a use's values put in, its slots, state
// of its own, events out, several meanings of one name, a definition using
// another, its errors said against it; and the stand-in that shows what is
// missing (docs/design/19-open-vocabulary.md section 9).
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

const _sticky = '''
// A note stuck on a board.
StickyNote "text" fill=#FFFDE68A w=180 selected=false onTap
  Column w={w} pad=14 gap=6 fill={fill} radius=6 border={selected ? "#FF2563EB" : "#1A000000"} onTap={onTap}
    Text "{text}"
    Text.caption "{text} ({w} wide)"
''';

const _flip = '''
FlipCard @flipped h=240 onTap
  state flipped=false
  Stack w=fill h={h} onTap={flipped=!flipped; onTap}
    Column w=fill h=fill visible={!flipped}
      ...Front
    Column w=fill h=fill visible={flipped}
      ...Back
''';

const _picker = '''
ColorPicker @color swatches=["#FF111827","#FFDC2626"] onPick
  state color=""
  Row gap=8
    each swatch in swatches
      Swatch "{swatch}" selected={swatch == color} onTap={color=swatch; onPick(swatch)}
''';

const _swatch = '''
Swatch "color" selected=false onTap
  Box w=28 h=28 radius=999 fill={color} border={selected ? "#FF111827" : "#1F000000"} onTap={onTap}
''';

const _group = '''
Group "title"
  Column gap=2
    Text.caption "{title}"
    ...
''';

const _tile = '''
Tile "name" onDownload
  Row gap=8
    Text "{name}"
    if onDownload
      IconButton "download" onTap={onDownload}
''';

const _timeline = '''
// The tracks of a clip editor.
Timeline#tracks zoom=1 playhead=0 onZoom
  Column w=fill
    IconButton "zoom_in" onTap={onZoom(zoom * 2)}
    ...

// Dated events down a rail.
Timeline.vertical#events
  Column w=fill gap=12 border-left=#FFE5E7EB
    ...

// A route's stops.
Timeline.vertical#route @at position
  state at=0
  Column w=fill gap=10
    Text.caption "At {position}"
    ...
''';

const _reorder = '''
ReorderList
  Column w=fill gap=6
    ... each reorder
''';

final _defs = {
  'StickyNote.txt': _sticky,
  'FlipCard.txt': _flip,
  'ColorPicker.txt': _picker,
  'Swatch.txt': _swatch,
  'Group.txt': _group,
  'Tile.txt': _tile,
  'Timeline.txt': _timeline,
  'ReorderList.txt': _reorder,
};

final _closed = const NotationOptions().define(_defs);
final _open = _closed.open();

NotationResult _parse(String text, [NotationOptions? options]) => parseNotation(text, catalog: standardCatalog, options: options ?? _closed);

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

List<VocabularyUse> _uses(NotationResult r, String kind) => [for (final u in r.vocabulary) if (u.kind == kind) u];

Map<String, Object?> _vars(NotationResult r) => {
      for (final scope in ((r.document['variables'] as Map?) ?? const {}).values)
        for (final v in scope as List) (v as Map)['name'] as String: v['value'],
    };

void main() {
  group('a definition is read from its text', () {
    test('its signature: strings, parameters with defaults, flags, events, the lines under it, its purpose', () {
      final read = readDefinitions({'StickyNote.txt': _sticky});
      expect(read.problems, isEmpty);
      final d = read.words['StickyNote']!.single;
      expect(d.strings, ['text']);
      expect(d.parameters, {'fill': '#FFFDE68A', 'w': '180', 'selected': 'false'});
      expect(d.isFlag('selected'), isTrue);
      expect(d.events, ['onTap']);
      expect(d.doc, 'A note stuck on a board.');
      expect((d.file, d.line), ('StickyNote.txt', 2));
      expect(d.body.first, (indent: 0, text: d.body.first.text, line: 3));
      expect(definitionLines(const NotationVocabulary().define({'StickyNote.txt': _sticky})).single, startsWith('StickyNote "text" fill=#FFFDE68A'));
    });

    test('what cannot be read is said with its file and line', () {
      final read = readDefinitions({
        'Bad.txt': 'Bad "text"\n',
        'Two.txt': 'Two\n  Text "a"\n  Text "b"\n',
        'lower.txt': 'lower x=1\n  Text "a"\n',
      });
      // Two lines side by side are read: written where the use is (round 11).
      expect(read.words.keys, ['Two']);
      expect(read.problems, [
        'Bad.txt:1: Bad stands for no lines: write them indented under its signature.',
        'lower.txt:1: a signature starts with the word it defines, capitalised (StickyNote "text" fill=#FFFDE68A).',
      ]);
    });

    test('a word that uses itself, directly or through another, is refused', () {
      final read = readDefinitions({
        'A.txt': 'A\n  Column\n    B\n',
        'B.txt': 'B\n  Row\n    A\n',
        'C.txt': 'C\n  Column\n    C\n',
        'D.txt': 'D\n  Column\n    Text "fine"\n',
      });
      expect(read.words.keys, ['D']);
      expect(read.problems, containsAll(['A.txt:1: A uses itself (A > B > A): it is not read.', 'C.txt:1: C uses itself (C > C): it is not read.']));
    });
  });

  group('a use is the lines it stands for', () {
    const page = '''
state notes=[{"text":"Milk","color":"#FFFFE4E6"}]
Column gap=12
  StickyNote "Hello" selected=true onTap={toast "hi"} w=200
  each n in notes
    StickyNote "{n.text}" fill={n.color}
''';

    test('the values put in where the body reads them: alone, in a string, in an expression; the root takes the use\'s id', () {
      final r = _parse(page);
      expect(r.issues, isEmpty);
      final first = _node(r, 'stickyNote1');
      expect(first['type'], 'column');
      expect((first['decoration'] as Map)['fills'], [
        {'color': '#FFFDE68A'},
      ]);
      expect((first['layout'] as Map)['width'], 200);
      // `{selected ? … : …}` with selected=true written reads nothing at run
      // time: worked out as the use is read (docs/design/20 section 13).
      expect(first['bind'], isNull);
      expect((first['decoration'] as Map)['strokes'], [
        {'color': '#FF2563EB'},
      ]);
      expect(jsonEncode(first['actions']), contains('"message":"hi"'));
      expect(_node(r, 'text1')['props'], containsPair('text', 'Hello'));
      expect(_node(r, 'text2')['props'], containsPair('text', 'Hello (200 wide)'));
      // In a row of an each: the row's values.
      final second = _node(r, 'stickyNote2');
      expect((second['bind'] as Map)['decoration.fills[0].color'], r'${item.color}');
      expect(_node(r, 'text3')['props'], containsPair('text', r'${item.text}'));
    });

    test('the same with the vocabulary open: the same document, and each use recorded as a definition with its node', () {
      final closed = _parse(page), open = _parse(page, _open);
      expect(open.issues, isEmpty);
      expect(jsonEncode(open.document), jsonEncode(closed.document));
      final uses = _uses(open, 'definition');
      expect([for (final u in uses) (u.word, u.to, u.node, u.line)], [('StickyNote', 'StickyNote', 'stickyNote1', 3), ('StickyNote', 'StickyNote', 'stickyNote2', 5)]);
      expect(uses.first.texts, ['Hello']);
      expect(uses.first.parameters, {'selected': 'true', 'w': '200'});
      // Closed, a use is recorded too: a defined word is a word we have.
      expect(_uses(closed, 'definition'), hasLength(2));
    });

    test('a use expands to the same document as its lines written out by hand', () {
      final byHand = parseNotation('''
Column gap=12
  Column#stickyNote1 w=200 pad=14 gap=6 fill=#FFFDE68A radius=6 border=#FF2563EB onTap={toast "hi"}
    Text "Hello"
    Text.caption "Hello (200 wide)"
''', catalog: standardCatalog, options: const NotationOptions(width: 1280));
      final used = _parse('''
Column gap=12
  StickyNote "Hello" selected=true onTap={toast "hi"} w=200
''', const NotationOptions(width: 1280).define(_defs));
      expect(jsonEncode(used.document), jsonEncode(byHand.document));
    });

    test('a word it does not have: recorded with the vocabulary open, said without it', () {
      const text = 'Column\n  StickyNote "x" x=12 resizable onMove={toast "m"}\n';
      final open = _parse(text, _open);
      expect(open.issues, isEmpty);
      expect([for (final u in open.vocabulary.where((u) => u.kind != 'definition')) (u.kind, u.word, u.on)], [('parameter', 'x', 'StickyNote'), ('flag', 'resizable', 'StickyNote'), ('event', 'onMove', 'StickyNote')]);
      final closed = _parse(text);
      expect(closed.issues.map((i) => i.message), [
        'A StickyNote has no "x". It takes: "text", fill, w, selected, onTap. For its lines to read {x}, name it on the definition\'s first line: '
            'StickyNote "text" fill=#FFFDE68A w=180 selected=false onTap x={} (or leave x= out here).',
        'A StickyNote has no "resizable". It takes: "text", fill, w, selected, onTap.',
        'A StickyNote has no "onMove". It takes: "text", fill, w, selected, onTap.',
      ]);
    });

    test('a core word is never a definition\'s: one named Card changes nothing', () {
      final options = const NotationOptions().define({'Card.txt': 'Card\n  Text "not a card"\n'});
      final r = parseNotation('Card\n  Text "a"\n', catalog: standardCatalog, options: options);
      expect(jsonEncode(r.document), jsonEncode(parseNotation('Card\n  Text "a"\n', catalog: standardCatalog).document));
      expect(r.vocabulary, isEmpty);
    });
  });

  group('lines under a use', () {
    test('the default slot: the lines go where the body has ...', () {
      final r = _parse('Column\n  Group "Notes"\n    Text "one"\n    Text "two"\n  Text "after"\n');
      expect(r.issues, isEmpty);
      expect(_node(r, 'group1')['children'], ['text1', 'text2', 'text3']);
      expect(_node(r, 'text3')['props'], containsPair('text', 'two'));
      expect(_node(r, 'column1')['children'], ['group1', 'text4']);
    });

    test('named slots: the lines under Front and Back go to their places, a slot line\'s own words hold them', () {
      final r = _parse('''
Column
  FlipCard onTap={toast "turned"}
    Front fill=#FF6D28D9
      Text "Q"
    Back
      Text "A"
''');
      expect(r.issues, isEmpty);
      final faces = _node(r, 'flipCard1')['children'] as List;
      expect(faces, hasLength(2));
      final front = _node(r, faces[0] as String)['children'] as List;
      expect(_node(r, front.single as String)['type'], 'column');
      expect((_node(r, front.single as String)['decoration'] as Map)['fills'], [
        {'color': '#FF6D28D9'},
      ]);
      expect(_node(r, (_node(r, faces[1] as String)['children'] as List).single as String)['props'], containsPair('text', 'A'));
    });

    test('lines under a word with no slot: drawn at its end, and said', () {
      const text = 'Column\n  StickyNote "x"\n    Text "under"\n';
      expect(_parse(text).issues.map((i) => i.message), ['A StickyNote takes no lines under it (its definition has no Slot line to put them at): they are drawn at its end.']);
      final open = _parse(text, _open);
      expect(open.issues, isEmpty);
      expect(_uses(open, 'children').single.word, 'StickyNote');
      expect(_node(open, 'stickyNote1')['children'], hasLength(3));
    });

    test('... each reorder: an each over a variable written in the slot is put in order by hand', () {
      final r = _parse('state items=["a","b"]\nColumn\n  ReorderList\n    each it in items\n      Text "{it}"\n');
      expect(r.issues, isEmpty);
      expect(jsonEncode(r.document), contains('reorder'));
    });
  });

  group('state, events and ids of a word', () {
    test('its state is the use\'s own; @name puts the page\'s variable there instead', () {
      final r = _parse('''
state shown=false
Column
  FlipCard
    Front
      Text "1"
  FlipCard#two
    Front
      Text "2"
  FlipCard @shown
    Front
      Text "3"
''');
      expect(r.issues, isEmpty);
      expect(_vars(r).keys, unorderedEquals(['shown', 'flipped_flipCard1', 'flipped_two']));
      expect(jsonEncode(_node(r, 'flipCard2')['actions']), contains('"variable":"shown"'));
    });

    test('an event out: the use\'s actions where the body names it, result as the body says; an event in an expression is whether it was given', () {
      final r = _parse('Column\n  ColorPicker onPick={toast "{result}"}\n  Tile "a.pdf" onDownload={toast "saved"}\n  Tile "b.pdf"\n');
      expect(r.issues, isEmpty);
      final swatch = jsonEncode(_node(r, 'swatch1')['actions']);
      expect(swatch, contains('"variable":"color_colorPicker1"'));
      expect(swatch, contains(r'"message":"${= (item)}"'));
      final tiles = jsonEncode(r.document);
      expect(tiles, contains('"message":"saved"'));
      // b.pdf has no download button: its `if onDownload` is false, decided
      // as the use is read (docs/design/20 section 13).
      expect(tiles, isNot(contains('"visible":"\${= false}"')));
      expect('"type":"iconButton"'.allMatches(tiles), hasLength(1));
    });
  });

  group('one name, several meanings', () {
    test('a use is read with the meaning that fits what it gives, and the record says which', () {
      final r = _parse('''
state z=1
state bus=1.5
Column
  Timeline zoom={z} onZoom={z=result}
    Text "tracks"
  Timeline.vertical
    Text "an event"
  Timeline.vertical position={bus}
    Text "a stop"
  Timeline
    Text "a bare one is the plainest"
''', _open);
      expect(r.issues, isEmpty);
      expect([for (final u in _uses(r, 'definition')) u.to], ['Timeline#tracks', 'Timeline#events', 'Timeline#route', 'Timeline#events']);
      expect(jsonEncode(r.document), contains(r'"value":"${= ((z) * 2)}"'));
    });
  });

  group('a component\'s word with a meaning defined (the vocabulary loop, Review 5, D25)', () {
    // A design system with one component, Stepper: the number control.
    Future<(Catalog, NotationOptions)> stepper(Map<String, String> defs, {NotationVocabulary aliases = NotationVocabulary.none}) async {
      final files = <String, String>{
        'design_system.json': jsonEncode({'id': 'steppers', 'name': 'Steppers', 'components': ['components/Stepper.json']}),
        'components/Stepper.json': jsonEncode({
          'schema': 3,
          'id': 'Stepper',
          'roots': ['row'],
          'widget': {
            'type': 'Stepper',
            'doc': 'A number changed one step at a time.',
            'props': [
              {'key': 'value', 'type': {'kind': 'variable', 'of': {'kind': 'number', 'flutter': 'double'}}, 'default': ''},
              {'key': 'min', 'type': {'kind': 'number', 'flutter': 'double'}, 'default': 0},
              {'key': 'max', 'type': {'kind': 'number', 'flutter': 'double'}, 'default': 100},
              {'key': 'step', 'type': {'kind': 'number', 'flutter': 'double'}, 'default': 1},
              {'key': 'label', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': ''},
            ],
            'events': [
              {'key': 'onChanged', 'payload': {'kind': 'number', 'flutter': 'double'}},
            ],
          },
          'nodes': {
            'row': {'type': 'row', 'children': ['text']},
            'text': {'type': 'text', 'props': {'text': r'${props.label}'}},
          },
        }),
      };
      final problems = <String>[];
      final ds = await DesignSystem.load((ref) async => files[ref], problems: problems);
      expect(problems, isEmpty);
      final base = NotationOptions.fromDesignSystem(ds);
      return (ds.catalogOver(standardCatalog), base.open(openVocabulary: false, vocabulary: aliases.merge(NotationVocabulary(definitions: readDefinitions(defs).words))));
    }

    const steps = '''
// Where one is in named steps: the steps, the current one lit; a tap picks one.
Stepper#steps steps=[] @step current done=[] onPick
  state step=0
  Row gap=8
    each s in steps
      Text "{s}" weight={index == coalesce(current, step) ? 700 : 400} onTap={step=index; onPick(index)}
''';

    test('the component is the word; a use that fits the named meaning better is that meaning', () async {
      final (catalog, options) = await stepper({'Stepper.txt': steps});
      final r = Catalog.run(catalog, () => parseNotation('''
state qty=1
state at=0
Column
  Stepper#qty "Guests" @qty min=1 max=8 onChange={toast "{result}"}
  Stepper steps=["Cart","Pay","Done"] @at onPick={toast "{result}"}
  Stepper steps=["A","B"] current={at}
''', catalog: catalog, options: options));
      expect(r.issues, isEmpty);
      expect([for (final u in _uses(r, 'definition')) u.to], ['Stepper#steps', 'Stepper#steps']);
      // The first is the component, as it was.
      expect(_node(r, 'qty')['type'], 'Stepper');
      expect(jsonEncode(r.document), allOf(contains('Cart'), contains('coalesce((at), step_stepper2)')));
    });

    test('a design system\'s definition of a component\'s word that names no meaning is not read', () async {
      final (catalog, options) = await stepper({'Stepper.txt': 'Stepper steps=[]\n  Text "never"\n'});
      final r = Catalog.run(catalog, () => parseNotation('Column\n  Stepper steps=["A"]\n', catalog: catalog, options: options));
      expect(_uses(r, 'definition'), isEmpty);
      expect(jsonEncode(r.document), isNot(contains('never')));
    });

    test('a page\'s own definition of a component\'s word replaces it on that page (the vocabulary loop, Review 7, D38)', () async {
      // An answer that needs the word in another shape defines it rather than
      // renaming every line; the design system's named meanings go with it.
      final (catalog, options) = await stepper({'Stepper.txt': steps});
      final p = Catalog.run(
          catalog, () => parseNotation('state at=0\nColumn\n  Stepper steps=["A","B"] @at\ndefine Stepper steps=[] @step\n  Text "the page\'s {length(steps)}"\n', catalog: catalog, options: options));
      expect(p.issues, isEmpty);
      final uses = _uses(p, 'definition');
      expect([for (final u in uses) u.to], ['Stepper']);
      expect(uses.single.of, 'page, over Stepper.txt');
      expect(jsonEncode(p.document), contains("the page's"));
      // Over a component no definition names: the record says so.
      final (catalog2, options2) = await stepper(const {});
      final q = Catalog.run(catalog2, () => parseNotation('Column\n  Stepper "Guests" max=4\ndefine Stepper "label" max=8\n  Text "{label} up to {max}"\n', catalog: catalog2, options: options2));
      expect(q.issues, isEmpty);
      expect(_uses(q, 'definition').single.of, 'page, over the Stepper component');
      expect(jsonEncode(q.document), contains('Guests up to 4'));
      // The core's words are never replaced: a page's Button is the Button.
      final b = Catalog.run(catalog2, () => parseNotation('Column\n  Button "Go"\ndefine Button "label"\n  Text "not a button"\n', catalog: catalog2, options: options2));
      expect(_uses(b, 'definition'), isEmpty);
      expect(jsonEncode(b.document), isNot(contains('not a button')));
    });

    test('the alias table names a defined word\'s parameters and events under the names answers wrote', () async {
      final aliases = NotationVocabulary.fromJson({
        'parameters': {
          'Stepper': {'items': 'steps'},
          'Timeline': {'events': 'items', 'steps': 'items', 'zoom': 'never'},
        },
        'events': {
          'Stepper': {'onSelect': 'onPick'},
        },
      });
      final (catalog, options) = await stepper({'Stepper.txt': steps}, aliases: aliases);
      final r = Catalog.run(catalog, () => parseNotation('''
state at=0
Column
  Stepper items=["A","B"] @at onSelect={toast "{result}"}
''', catalog: catalog, options: options));
      expect(r.issues, isEmpty);
      expect([for (final u in _uses(r, 'definition')) u.to], ['Stepper#steps']);
      expect([for (final u in r.vocabulary) if (u.kind == 'alias') '${u.word}>${u.to}'], ['items>steps', 'onSelect>onPick']);
      expect(jsonEncode(r.document), contains('showToast'));
      // A defined word: the name one of its meanings takes is its own (zoom).
      final t = parseNotation('state z=1\nColumn\n  Timeline zoom={z}\n  Timeline.vertical events=[1]\n',
          catalog: standardCatalog, options: _closed.open(openVocabulary: false, vocabulary: _closed.vocabulary.merge(aliases)));
      expect([for (final u in t.vocabulary) if (u.kind == 'alias') '${u.word}>${u.to}'], ['events>items']);
      expect([for (final u in _uses(t, 'definition')) u.to], ['Timeline#tracks', 'Timeline#events']);
    });
  });

  group('what the first corpus wrote with words Cards now defines (Review 5, D25)', () {
    test('a use binds the page\'s variable; one the page never declared is said, with the state line to add', () {
      final r = _parse('state tint=""\nColumn\n  ColorPicker @tint\n', _open);
      expect(r.issues, isEmpty);
      expect(_vars(r), {'tint': ''});
      // Declared by the page: the page's.
      final own = _parse('state tint="#FF2563EB"\nColumn\n  ColorPicker @tint\n', _open);
      expect(_vars(own), {'tint': '#FF2563EB'});
      final none = _parse('Column\n  ColorPicker @tint\n', _open);
      expect(none.issues.single.message, contains('add state tint='));
    });

    test('a record written as JSON given to a parameter is that record in an expression', () {
      final v = const NotationVocabulary().define({'Pin.txt': 'Pin at\n  Text "{at.lat}, {at.lng}"\n'});
      final r = parseNotation('Column\n  Pin at={"lat":44.9,"lng":-93.1}\n', catalog: standardCatalog, options: const NotationOptions().open(vocabulary: v));
      expect(r.issues, isEmpty);
      expect(jsonEncode(r.document), contains(r'{\"lat\":44.9,\"lng\":-93.1}.lat'));
    });
  });

  group('a definition\'s errors are said against it', () {
    test('checkDefinitions expands each with its defaults: a line it gets wrong is its file and line', () {
      final v = const NotationVocabulary().define({
        'Good.txt': _group,
        'Broken.txt': 'Broken "label"\n  Column\n    Text "{label}" wobble=3\n    Bogus "x"\n',
      });
      expect(checkDefinitions(v, catalog: standardCatalog), [
        // A key the type has no name for is said (docs/design/22 section 2.1).
        'Broken.txt:3: A Text has no "wobble": left out.',
        'Broken.txt:4: No node type "Bogus". Write a type of the catalog (Column, Row, Text, Button, Input, Toggle, Slider…).',
      ]);
    });

    test('used on a page, the same error is on the use\'s line, its message starting with the definition\'s file and line, open or not', () {
      final options = const NotationOptions().define({'Broken.txt': 'Broken "label"\n  Column\n    Bogus "x"\n'});
      for (final o in [options, options.open()]) {
        final r = parseNotation('Column\n  Broken "a"\n', catalog: standardCatalog, options: o);
        expect(r.issues.map((i) => '${i.line}: ${i.message}').single, startsWith('2: Broken.txt:3: '));
        expect(r.vocabulary.where((u) => u.kind == 'type'), isEmpty);
      }
    });
  });

  test('define in a page: the word is read for the rest of the text', () {
    final r = parseNotation('''
define Badge2 "label" tone="#FFDCFCE7"
  Row pad=[8,2,8,2] radius=999 fill={tone}
    Text.caption "{label}"
Column
  Badge2 "New"
''', catalog: standardCatalog);
    expect(r.issues, isEmpty);
    expect(_node(r, 'badge21')['type'], 'row');
    expect(_node(r, 'text1')['props'], containsPair('text', 'New'));
  });

  group('what self-defining answers wrote (the vocabulary loop, Review 4, D21)', () {
    test('state lines before the root are the word\'s own state; an if over the one node it stands for shows it while it holds', () {
      final r = parseNotation('''
Column
  Meter level=40
  Guide steer=3 visible=false
define Meter level=0
  state peak=0
  state held=false
  Column gap=4 onTap={peak=level; held=!held}
    Box w={level} h=6
define Guide visible=true steer=0
  if visible
    Column gap=4
      Box w={steer} h=4
''', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      expect(_vars(r).keys, unorderedEquals(['peak_meter1', 'held_meter1']));
      expect(_node(r, 'guide1')['visible'], isFalse);
      expect(_node(r, 'guide1')['type'], 'column');
    });

    test('an expression where a use\'s first string goes is that string', () {
      final r = parseNotation('state s="ok"\nColumn\n  Pill {s} color=#FF000000\ndefine Pill "text" color=#FF111111\n  Row pad=4 fill={color}\n    Text "{text}"\n', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      expect(_node(r, 'text1')['props'], containsPair('text', r'${s}'));
      expect((_node(r, 'pill1')['decoration'] as Map)['fills'], [
        {'color': '#FF000000'},
      ]);
    });
  });

  group('what got in the definer\'s way (the vocabulary loop, Review 3, D16)', () {
    NotationResult read(String text) => parseNotation(text, catalog: standardCatalog, options: const NotationOptions().open());

    test('a tinted block of a given height keeps it with a text in it; a fixed-height Box, Row and Column are that high', () {
      final r = read('Column\n  Tile\ndefine Tile "label"\n  Column w=120 h=200 fill=#FFEEEEEE\n    Text "{label}"\n');
      expect(r.issues, isEmpty);
      final layout = _node(r, 'tile1')['layout'] as Map;
      expect(layout['height'], {'hug': 200});
      expect(layout['constraints'], {'minHeight': 200});
    });

    test('Row wrap over an each wraps its copies', () {
      final r = read('state tags=["a","b","c"]\nColumn w=200\n  Tags items={tags}\ndefine Tags items=[]\n  Row gap=8 wrap\n    each t in items\n      Chip "{t}"\n');
      expect(r.issues, isEmpty);
      final list = _node(r, 'listView1');
      expect(list['props'], containsPair('wrap', true));
      expect(list['props'], containsPair('runSpacing', 8));
      expect((list['layout'] as Map)['width'], {'fill': 0});
    });

    test('Word#{expr}: an id from data is its fixed part, as on any line', () {
      final r = read('state tracks=[{"id":"t1","name":"Kick"}]\nColumn\n  each tr in tracks\n    Track#{tr.id} name="{tr.name}"\n    Track#lane-{tr.id} name="{tr.name}"\ndefine Track name=""\n  Row\n    Text "{name}"\n');
      expect(r.issues, isEmpty);
      expect(r.vocabulary.where((u) => u.kind == 'type'), isEmpty);
      expect(_uses(r, 'definition').map((u) => u.node), ['track1', 'lane']);
    });

    test('a path, or a variable of the page, given to a plain parameter is the value it reads', () {
      final r = read('state draft={"start":1,"end":5}\nstate bpm=90\nColumn\n  Span start=draft.start end=draft.end\n  Tempo bpm=bpm\n  Tempo bpm=fast\ndefine Span start=0 end=0\n  Text "{end - start} days"\ndefine Tempo bpm=120\n  Text "{bpm} bpm"\n');
      expect(r.issues, isEmpty);
      expect(_node(r, 'span1')['props'], containsPair('text', r'${= (draft.end) - (draft.start)} days'));
      expect(_node(r, 'tempo1')['props'], containsPair('text', r'${bpm} bpm'));
      // A word that is no variable is the word.
      expect(_node(r, 'tempo2')['props'], containsPair('text', 'fast bpm'));
    });

    test('a choice between actions takes a use\'s events, given or not', () {
      final r = read('state ok=true\nColumn\n  Try onOk={toast "good"} onError={toast "bad"}\n  Try onError={toast "only bad"}\ndefine Try onError onOk\n  Button "Go" onTap={ok ? onOk : onError}\n');
      expect(r.issues, isEmpty);
      final both = jsonEncode(_node(r, 'try1')['actions']), one = jsonEncode(_node(r, 'try2')['actions']);
      expect(both, allOf(contains('"good"'), contains('"bad"'), contains('"type":"if"')));
      expect(one, allOf(contains('"only bad"'), contains('"then":[]')));
    });

    test('every {expression}: a timer whose interval is worked out', () {
      final r = read('state bpm=120\nColumn\n  Metro bpm={bpm}\ndefine Metro bpm=120\n  state beat=0\n  every {60000/bpm} onTick={beat=beat+1}\n  Text "{beat}"\n');
      expect(r.issues, isEmpty);
      expect(jsonEncode(r.document), contains(r'"intervalMs":"${= 60000/(bpm)}"'));
    });

    test('each … reorder over a list the use works out is shown in order (no variable to write the order to)', () {
      final r = read('state rows=[{"n":"a"},{"n":"b"}]\nColumn\n  Sortable items={filter(rows, r => r.n != "")}\n  Sortable items={rows}\ndefine Sortable items=[]\n  Column\n    each it in items reorder\n      Text "{it.n}"\n');
      expect(r.issues, isEmpty);
      expect(jsonEncode(_node(r, 'listView1')['props']), isNot(contains('reorder')));
      expect(jsonEncode(_node(r, 'listView2')['props']), contains('reorder'));
    });

    test('a border\'s width and colour together, as models write them', () {
      final r = read('Column\n  Ring2 on=true\ndefine Ring2 on=false\n  Column gap=4\n    Box#a w=40 h=40 border=#FF2563EB strokeWidth=2\n    Box#c w=40 h=40 strokeWidth=3 border=#FF2563EB\n    Box#d w=40 h=40 border=#FF2563EB strokeWidth={on ? 2 : 0}\n    Box#e w=40 h=40 strokeWidth=1\n');
      expect(r.issues, isEmpty);
      Map<String, Object?> deco(String id) => (_node(r, '${id}_ring21')['decoration'] as Map).cast();
      for (final (id, w) in [('a', 2), ('c', 3)]) {
        expect(deco(id), {'strokes': [{'color': '#FF2563EB'}], 'strokeWidth': w}, reason: id);
      }
      // `{on ? 2 : 0}` with on=true written: worked out as the use is read.
      expect(deco('d'), {'strokes': [{'color': '#FF2563EB'}], 'strokeWidth': 2});
      expect(_node(r, 'd_ring21')['bind'], isNull);
      expect(deco('e'), {'strokes': [{'color': const NotationOptions().line}], 'strokeWidth': 1});
    });

    test('a border\'s width has one key: written in border= it is said with strokeWidth=', () {
      String said(String line) => read('Column\n  $line\n').issues.single.message;
      const head = 'A border\'s colour is border=, its width strokeWidth= (alone: the theme\'s line at that width): ';
      expect(said('Box w=40 h=40 border="#FF2563EB 2"'), '${head}border=#FF2563EB strokeWidth=2.');
      expect(said('Box w=40 h=40 border=1'), '${head}strokeWidth=1.');
    });

    test('a font and a weight on an Input, by the names a Text has them', () {
      for (final (written, line) in [('font="Georgia"', 'fontFamily="Georgia"'), ('textSize=18', 'size=18'), ('fontSize=18', 'size=18'), ('fontWeight=600', 'weight=600')]) {
        final key = written.split('=').first;
        expect(read('Column\n  Input "Code" $written\n').issues.single.message, 'An Input\'s $key is written ${line.split('=').first}: $line.');
      }
      final r = read('Column\n  Field2\ndefine Field2\n  Input "Code" fontFamily="JetBrains Mono" weight=600 size=18\n');
      expect(r.issues, isEmpty);
      expect((_node(r, 'field21')['props'] as Map)['style'], {'fontFamily': 'JetBrains Mono', 'fontWeight': 600, 'fontSize': 18});
    });
  });

  group('an open of an overlay that was never written (Review 3, D17)', () {
    const text = 'Column\n  Button "Add" onTap={open addRecipe}\n  Button "Again" onTap={open addRecipe}\n';
    test('with the vocabulary open: a quiet sheet titled with the id opens, recorded as a wanted overlay, not an issue', () {
      final r = parseNotation(text, catalog: standardCatalog, options: const NotationOptions(width: 1280).open());
      expect(r.issues, isEmpty);
      expect(r.document['roots'], ['screen', 'addRecipe']);
      expect(jsonEncode(r.document), allOf(contains('"text":"Add recipe"'), contains('"text":"Not written yet."'), contains('"to":"addRecipe","presentation":"bottomSheet"')));
      final wanted = _uses(r, 'overlay').single;
      expect((wanted.word, wanted.line, wanted.node), ('addRecipe', 2, 'addRecipe'));
    });

    test('with it closed, nothing is made', () {
      final r = parseNotation(text, catalog: standardCatalog, options: const NotationOptions(width: 1280));
      expect(r.document['roots'], ['screen']);
      expect(r.vocabulary, isEmpty);
    });
  });

  group('a definition anywhere in a text holds for the whole text', () {
    const before = '''
// A small rounded label.
define Badge2 "label" tone="#FFDCFCE7"
  Row pad=[8,2,8,2] radius=999 fill={tone}
    Text.caption "{label}"
Column
  Badge2 "New"
''';
    const after = '''
Column
  Badge2 "New"

// A small rounded label.
define Badge2 "label" tone="#FFDCFCE7"
  Row pad=[8,2,8,2] radius=999 fill={tone}
    Text.caption "{label}"
''';

    test('written after its use, it is read as if written before, open or closed', () {
      for (final o in [const NotationOptions(), const NotationOptions().open()]) {
        final a = parseNotation(after, catalog: standardCatalog, options: o), b = parseNotation(before, catalog: standardCatalog, options: o);
        expect(a.issues, isEmpty);
        expect(jsonEncode(a.document), jsonEncode(b.document));
        expect(_uses(a, 'definition').single.line, 2);
        expect(a.vocabulary.where((u) => u.kind == 'type'), isEmpty);
      }
    });

    test('its purpose is the // line above it; what is wrong is said on its own line, once', () {
      expect(readPageDefinitions(after).words['Badge2']!.single.doc, 'A small rounded label.');
      final r = parseNotation('Column\n  Text "a"\ndefine Broken\nText "b"\n', catalog: standardCatalog);
      expect(r.issues.map((i) => '${i.line}: ${i.message}'), ['3: page:3: Broken stands for no lines: write them indented under its signature.']);
    });

    test('an overlay written after the page reads the page\'s words, and an answer\'s other screens can give them', () {
      final r = parseNotation('Column\n  Button "Open" onTap={open d}\nDialog#d\n  Badge2 "In the dialog"\n$after', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      expect(jsonEncode(r.document), contains('In the dialog'));
      final other = parseNotation('Column\n  Badge2 "On another screen"\n', catalog: standardCatalog, definitions: after);
      expect(other.issues, isEmpty);
      expect(_uses(other, 'definition').single.to, 'Badge2');
    });

    test('a page\'s own definition of a word the design system defines wins there, and the record says so', () {
      final r = parseNotation('Column\n  StickyNote "mine"\ndefine StickyNote "text"\n  Row\n    Text "page: {text}"\n', catalog: standardCatalog, options: _open);
      expect(r.issues, isEmpty);
      expect(jsonEncode(r.document), contains('page: mine'));
      expect(_uses(r, 'definition').single.of, 'page, over StickyNote.txt');
      // Without one, the design system's, and no `of`.
      expect(_uses(_parse('Column\n  StickyNote "x"\n', _open), 'definition').single.of, isNull);
    });

    test('read as it arrives, a definition holds from where it is written, and a use above it is said', () {
      final s = NotationStream(catalog: standardCatalog);
      s.add(after);
      s.close();
      expect(s.issues.map((i) => i.message), [
        'No node type "Badge2". Write a type of the catalog (Column, Row, Text, Button, Input, Toggle, Slider…).',
        startsWith('page:5: Badge2 is used on line 2, before this definition. Read as it arrives'),
      ]);
      final t = NotationStream(catalog: standardCatalog);
      t.add(before);
      t.close();
      expect(t.issues, isEmpty);
    });
  });

  group('a stand-in with nothing to draw shows what is missing', () {
    const page = NotationOptions(width: 1280);
    test('a quiet dashed box with its word (and its first string value), as big as its w and h say', () {
      final r = parseNotation('Column\n  Minimap value={code} size=120\n  Map h=260 start="Saffron"\n', catalog: standardCatalog, options: page.open());
      final qr = _node(r, 'column2');
      expect((qr['decoration'] as Map)['dashPattern'], [4, 3]);
      expect((qr['decoration'] as Map)['strokes'], [
        {'color': page.line},
      ]);
      expect(((qr['layout'] as Map)['constraints'] as Map)['minHeight'], 40);
      expect(_node(r, 'column2Label')['props'], containsPair('text', 'Minimap'));
      expect(_node(r, 'column3Label')['props'], containsPair('text', 'Map · Saffron'));
      expect(((_node(r, 'column3')['layout'] as Map)['constraints'] as Map)['minHeight'], 260);
    });

    test('one with a text, lines under it or a fill of its own is as it was', () {
      final r = parseNotation('Column\n  SeatMap "Hall A"\n  Composer\n    Text "x"\n  ScrollProgress h=3 fill=#FFE8782A\n', catalog: standardCatalog, options: page.open());
      for (final id in ['column2', 'column3', 'column4']) {
        expect((_node(r, id)['decoration'] as Map?)?['dashPattern'], isNull, reason: id);
      }
    });

    test('its look is the theme\'s: named, the line follows the theme in light and dark', () {
      final named = NotationOptions.fromTheme(const {
        'colors': {'line': '#FFE5E7EB', 'secondaryText': '#FF6B7280'},
      }, width: 1280, named: true)
          .open();
      final r = parseNotation('Column\n  Waveform seed=3\n', catalog: standardCatalog, options: named);
      expect(((_node(r, 'column2')['decoration'] as Map)['strokes'] as List).single, {'color': 'line'});
    });

    test('with the vocabulary closed nothing stands in', () {
      final r = parseNotation('Column\n  Minimap value={code}\n', catalog: standardCatalog, options: page);
      expect(r.issues, isNotEmpty);
      expect(jsonEncode(r.document), isNot(contains('dashPattern')));
    });
  });

  group('what passed the tools and was wrong at run time (the vocabulary loop, Review 7, D31)', () {
    String actions(NotationResult r, String id) => jsonEncode(_node(r, id)['actions']);

    test('a body\'s own lines bind a control\'s value by @name alone, as a page\'s do', () {
      final r = parseNotation('state email=""\nColumn\n  Field "Name" @email\ndefine Field "label" @value\n  Input "{label}" value=@value\n', catalog: standardCatalog);
      expect(r.issues.single.message, endsWith('The value of an Input is bound by @name alone, with no key before it: @email.'));
      final range = parseNotation('state lo=1\nstate hi=9\nColumn\n  Range @lo end=@hi\ndefine Range @low end=@\n  Slider low=@low high=@end min=0 max=100\n', catalog: standardCatalog);
      expect([for (final i in range.issues) i.message.replaceFirst(RegExp(r'^page:\d+: '), '')], [
        'The value of a Slider is bound by @name alone, with no key before it: @lo.',
        'The other end of a range is the second @name of the line, with no key before it: @hi.',
      ]);
    });

    test('@value and a path bind the variable the use names; name=@ a further one; a use that binds none keeps its own', () {
      final r = parseNotation('''
state email=""
state s={"weight":"1"}
state lo=10
state hi=90
Column
  Field "Name" @email
  Field2 "Weight" @s.weight
  Field "Code" value=@email
  Field
  Range @lo end=@hi
define Field "label" @value
  Input "{label}" @value grow
define Field2 "label" @value
  Column
    Input#a "{label}" @value
    Input#b "{label}" @value
define Range @low end=@
  Slider @low @end min=0 max=100
''', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      expect(_node(r, 'field1')['bind'], {'props.initialValue': r'${email}'});
      expect(actions(r, 'field1'), contains('"variable":"email"'));
      for (final id in ['a_field21', 'b_field21']) {
        expect(_node(r, id)['bind'], {'props.initialValue': r'${s.weight}'}, reason: id);
        expect(actions(r, id), contains(r'with(s,\"weight\",result)'), reason: id);
      }
      expect(_node(r, 'field2')['bind'], {'props.initialValue': r'${email}'});
      // A use that binds none keeps its own.
      expect(_node(r, 'field3')['bind'], {'props.initialValue': r'${value_field3}'});
      expect(_node(r, 'range1')['bind'], {'props.value': r'${lo}', 'props.rangeEnd': r'${hi}'});
      expect(_vars(r).keys, unorderedEquals(['email', 's', 'lo', 'hi', 'value_field3']));
    });

    test('bind= in a body is said against the definition, with the line as it is written now', () {
      final r = parseNotation('state a=1\nColumn\n  Calc @a\ndefine Calc @value\n  Input "c" bind={value + 1}\n', catalog: standardCatalog, options: const NotationOptions().open());
      final said = r.issues.map((i) => i.message).toList();
      expect(said, contains(allOf(startsWith('page:5: a variable is bound with @'), endsWith('Write: Input "c" value={value + 1}'))));
    });

    test('a loop item of the body in drag=group(…) is the use\'s, braced or not', () {
      final r = parseNotation('''
state units=[{"id":"a"},{"id":"b"}]
Column
  Board items={units}
define Board items=[]
  Column gap=8
    each unit in items
      Card#u drag=dispatch(unit.id) pad=8
        Text "{unit.id}"
    each r in items
      Card#v drag=booking({r.id}) pad=8
        Text "{r.id}"
''', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      expect(_node(r, 'u_board1')['draggable'], {'group': 'dispatch', 'data': r'${item.id}'});
      expect(_node(r, 'v_board1')['draggable'], {'group': 'booking', 'data': r'${item.id}'});
    });

    test('an event forwarded with its result, a result path read once, a choice of events with a branch not given', () {
      final r = parseNotation('''
state got=""
state on=true
Column
  Search onSubmit={got=result}
  Drop onDrop={got=result.data}
  Pick on={on} onA={got="a"; on=false}
  Pick on={on} onB={got="b"}
define Search onSubmit
  Input "Find" onSubmit={onSubmit(result)}
define Drop onDrop
  Box h=40 drop=x onDrop={onDrop(result.data)}
define Pick on=false onA onB
  Button "Go" onTap={on ? onA : onB}
''', catalog: standardCatalog, options: const NotationOptions().open());
      expect(r.issues, isEmpty);
      expect(actions(r, 'search1'), contains('{"trigger":{"type":"submitted"},"actions":[{"type":"setVariable","variable":"got","value":"\${= (result)}"}]}'));
      expect(actions(r, 'drop1'), contains(r'"value":"${= (result.data)}"'));
      final a = (_node(r, 'pick1')['actions'] as List).single['actions'].single as Map;
      expect(a['type'], 'if');
      expect(a['then'], hasLength(2));
      expect(a['else'], anyOf(isNull, isEmpty));
      final b = (_node(r, 'pick2')['actions'] as List).single['actions'].single as Map;
      expect(b['then'], isEmpty);
      expect((b['else'] as List).single, containsPair('variable', 'got'));
    });

    test('an event the body forwards and its signature does not name is the word\'s event', () {
      final r = parseNotation('state got=""\nColumn\n  Pick onSelect={got=result}\ndefine Pick\n  Button "Go" onTap={onSelect("x")}\n', catalog: standardCatalog, options: const NotationOptions().open());
      expect(r.issues, isEmpty);
      expect(r.vocabulary.where((u) => u.kind == 'verb' || u.kind == 'event'), isEmpty);
      expect(actions(r, 'pick1'), contains('"variable":"got"'));
    });

    test('an event a line does not have, in a body, is an issue that lists the events', () {
      final r = parseNotation('Column\n  Search onSubmit={toast "x"}\ndefine Search onSubmit\n  Input "Find" onWobble={onSubmit}\n', catalog: standardCatalog, options: const NotationOptions().open());
      expect(r.issues.map((i) => i.message).single, allOf(contains('"onWobble" is not an event the notation has here'), contains('onSubmit')));
    });

    test('a body that starts with if (and its else) or each is its lines where the use is (round 11)', () {
      final r = parseNotation('''
state done=false
Column
  Status done={done}
  Status
define Status done=false
  if done
    Text "Done"
  else
    Text "Open"
''', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      final root = (r.document['nodes'] as Map).values.cast<Map>().firstWhere((n) => n['type'] == 'column');
      // The first reads the page's done at run time (both texts); the
      // second's done is its default, false, decided as it is read: "Open".
      expect([for (final c in root['children'] as List) _node(r, c as String)['type']], ['text', 'text', 'text']);
      expect([for (final c in (root['children'] as List).skip(2)) (_node(r, c as String)['props'] as Map)['text']], ['Open']);
      expect((r.document['nodes'] as Map).containsKey('status1'), isFalse);
      expect(readPageDefinitions('define Status\n  else\n    Text "x"\n').problems.single.message, endsWith('write the lines indented under a Column.'));
    });

    test('an action in a body naming an id the body writes names the use\'s, written bare, #id or quoted, the root\'s too', () {
      final r = parseNotation('''
Column
  Cell#cell
  Cell
define Cell
  Column#box gap=4
    Input#cellInput "x" onSubmit={focus #cellInput; scroll box}
    Button "Edit" onTap={focus cellInput}
    Button "Again" onTap={focus "cellInput"}
''', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      for (final (use, button) in [('cell', 'filledButton1'), ('cell1', 'filledButton3')]) {
        final field = actions(r, 'cellInput_$use');
        expect(field, contains('"node":"cellInput_$use"'));
        expect(field, contains('"node":"$use"'));
        expect(actions(r, button), contains('"node":"cellInput_$use"'));
      }
      expect(actions(r, 'filledButton2'), contains('"node":"cellInput_cell"'));
    });
  });

  group('primitive: a word declared for what no line can express (the vocabulary loop, Review 7, D32)', () {
    const text = '''
state at="kitchen"
Column
  FloorPlan "Level 2" rooms=["kitchen","hall"] h=240 onPick={at=result}
    Text "under it"
  Scope trace=[1,2,3] onCursor={toast "c"}

// A plan drawn from rooms and placed items, dragged: no line draws one.
primitive FloorPlan "name" rooms=[] h=360 onPick onPlace
// A trace of samples on a grid.
primitive Scope trace=[] onCursor
  Box w=fill h=120 fill=#FF0B1220 radius=8
    Text.caption "Scope · {length(trace)} samples" color=#FF34D399
''';

    test('its uses stand in, recorded as primitive: with no lines its own, a labelled box holding the lines under a use', () {
      for (final o in [const NotationOptions(width: 1280), const NotationOptions(width: 1280).open()]) {
        final r = parseNotation(text, catalog: standardCatalog, options: o);
        expect(r.issues, isEmpty);
        expect([for (final u in r.vocabulary) '${u.kind} ${u.word} ${u.to}'], ['primitive FloorPlan FloorPlan', 'primitive Scope Scope']);
        final plan = _node(r, 'floorPlan1');
        expect(plan['type'], 'column');
        expect((plan['layout'] as Map)['height'], {'hug': 240});
        expect(jsonEncode(r.document), allOf(contains('"text":"FloorPlan: Level 2"'), contains('"text":"under it"'), contains('Scope · ')));
      }
      final d = readPageDefinitions(text).words;
      expect(d['FloorPlan']!.single.primitive, isTrue);
      expect(d['FloorPlan']!.single.doc, 'A plan drawn from rooms and placed items, dragged: no line draws one.');
      expect(d['Scope']!.single.body.first.text, startsWith('Box w=fill h=120'));
      // A file of a design system may declare one too.
      expect(readDefinitions({'Map.txt': 'primitive MapView center=[0,0] onSelect\n'}).words['MapView']!.single.primitive, isTrue);
    });

    test('read as it arrives, a declaration\'s lines are its own, as a define\'s are', () {
      final s = NotationStream(catalog: standardCatalog, options: const NotationOptions().open());
      s.add('primitive Gauge2 value=0\nColumn\n  Gauge2 value=3\n');
      s.close();
      expect(s.issues, isEmpty);
      expect([for (final u in s.vocabulary) u.kind], ['primitive']);
    });
  });

  group('what a definition\'s lines leave unused and read from outside (the vocabulary loop, Review 7, D32)', () {
    DefinitionReads reads(String text) => definitionReads(readPageDefinitions(text).words.values.single.single);

    test('a parameter never read, an event never run: the cases the standalone runs wrote', () {
      // lighting-cue-stack's GoKey, tv-streaming-remote's RemoteFrame, comic-layout's SpeechBubble.
      final go = reads('define GoKey "label" shortcut="space" onTap\n  Button "{label}" onTap={onTap}\n');
      expect([go.unread, go.unfired, go.outside], [['shortcut'], <String>[], <String>[]]);
      expect(go.warnings.single, 'page:1: GoKey names shortcut and never reads it: a use\'s shortcut= does nothing.');
      final frame = reads('define RemoteFrame gap=16 onArrowUp onArrowDown onEnter\n  Column gap={gap}\n    ...\n');
      expect(frame.unfired, ['onArrowUp', 'onArrowDown', 'onEnter']);
      expect(frame.warnings.first, 'page:1: RemoteFrame names onArrowUp and never runs it: a use\'s onArrowUp={…} never runs.');
      final bubble = reads('define SpeechBubble "text" tail="left" onTailDrag\n  Box pad=8\n    Text "{text}"\n');
      expect([bubble.unread, bubble.unfired], [['tail'], ['onTailDrag']]);
      // A string never read.
      expect(reads('define Tag "label" "note"\n  Text "{label}"\n').warnings.single, contains('names "note" and never reads it: a use\'s string does nothing.'));
    });

    test('a name read from outside: a variable of the page, and @ of a name that is not the word\'s own', () {
      // periodic-table's PeriodicTable reads the page's elements.
      final table = reads('define PeriodicTable selected="H" onSelect\n  Grid cols=18\n    each e in elements\n      Button "{e.symbol}" selected={e.symbol == selected} onTap={onSelect(e.symbol)}\n');
      expect([table.unread, table.unfired, table.outside], [<String>[], <String>[], ['elements']]);
      expect(table.warnings.single, 'page:1: PeriodicTable reads elements, which is neither its own nor declared in it: it works only on a page that has that variable.');
      // @red where red is a parameter binds the use's variable (its own, or
      // the one the use binds); {bind} reads a variable called bind.
      final mixer = reads('define Mixer red=0 onRed\n  Slider @red onChange={onRed(result)}\n');
      expect([mixer.unread, mixer.outside], [<String>[], <String>[]]);
      final fader = reads('define Fader onLevel\n  Slider @level onChange={onLevel(result)}\n');
      expect(fader.outside, ['level']);
      final picker = reads('define ClubPicker @club clubs=[] onChange\n  Row\n    each item in clubs\n      Chip "{item}" selected={item==bind} onTap={bind=item; onChange(item)}\n');
      expect([picker.unread, picker.outside], [['club'], ['bind']]);
    });

    test('what is read: braces, strings, lists, statements, a value where the text goes, slots, choices, actions with arguments', () {
      final d = reads('''
define Everything "title" @value items=[] max=10 size=4 tint=#FFFFFFFF on=true label="" step=1 note="" onPick onClear onDone
  state open=false
  every 1s when on onTick={value=value+step}
  Column gap={size} fill={tint}
    Text "{title}"
    Ring {value / max} w=40
    each it in items
      Chip "{it}" onTap={open ? onPick(it) : onClear}
    Slider @value
    Row pad=[size,0,size,0]
    ...Foot w={size}
    Button "Go" onTap={confirm "Done with {label}?" then {onDone; toast "{note}"}}
''');
      expect([d.unread, d.unfired, d.outside], [<String>[], <String>[], <String>[]]);
      // Ids, pages and keys named by actions are not variables.
      expect(reads('define Nav2 onGo\n  Button "x" onTap={open sheet; go home; focus search; emit picked 3; onGo}\n').isEmpty, isTrue);
      // A primitive leaves its signature unused by design.
      expect(reads('primitive Map2 center=[0,0] onSelect\n').isEmpty, isTrue);
    });
  });
}
