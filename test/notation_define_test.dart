// Words defined in the notation itself (docs/design/20-defined-words.md): a
// definition's signature and lines, a use's values put in, its slots, state
// of its own, events out, several meanings of one name, a definition using
// another, its errors said against it; and the stand-in that shows what is
// missing (docs/design/19-open-vocabulary.md section 9).
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

const _sticky = '''
// A note stuck on a board.
StickyNote "text" fill=#FFFDE68A w=180 selected=false onTap
  Column w={w} pad=14 gap=6 fill={fill} radius=6 border={selected ? "#FF2563EB" : "#1A000000"} onTap={onTap}
    Text "{text}"
    Text.caption "{text} ({w} wide)"
''';

const _flip = '''
FlipCard bind=flipped h=240 onTap
  state flipped=false
  Stack w=fill h={h} onTap={flipped=!flipped; onTap}
    Column w=fill h=fill visible={!flipped}
      ...Front
    Column w=fill h=fill visible={flipped}
      ...Back
''';

const _picker = '''
ColorPicker bind=color swatches=["#FF111827","#FFDC2626"] onPick
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
Timeline.vertical#route bind=at position
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

List<String> _problems(Map<String, Object?> doc) => [
      for (final d in Catalog.run(standardCatalog, () => validateDocument(doc)))
        if (d.severity == Severity.error) '${d.code.name} ${d.path}: ${d.message}',
    ];

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
      expect(read.words, isEmpty);
      expect(read.problems, [
        'Bad.txt:1: Bad stands for no lines: write them indented under its signature.',
        'Two.txt:3: Two stands for one line and the lines under it; this one is beside it (indent it under Text).',
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
      expect(_problems(r.document), isEmpty);
      final first = _node(r, 'stickyNote1');
      expect(first['type'], 'column');
      expect((first['decoration'] as Map)['fills'], [
        {'color': '#FFFDE68A'},
      ]);
      expect((first['layout'] as Map)['width'], 200);
      expect(jsonEncode(first['bind']), contains('true ?'));
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
  Column#stickyNote1 w=200 pad=14 gap=6 fill=#FFFDE68A radius=6 border={true ? "#FF2563EB" : "#1A000000"} onTap={toast "hi"}
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
        'A StickyNote has no "x". It takes: "text", fill, w, selected, onTap.',
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
      expect(_problems(r.document), isEmpty);
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
      expect(_parse(text).issues.map((i) => i.message), ['A StickyNote takes no lines under it: they are drawn at its end.']);
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
    test('its state is the use\'s own; bind= puts the page\'s variable there instead', () {
      final r = _parse('''
state shown=false
Column
  FlipCard
    Front
      Text "1"
  FlipCard#two
    Front
      Text "2"
  FlipCard bind=shown
    Front
      Text "3"
''');
      expect(r.issues, isEmpty);
      expect(_problems(r.document), isEmpty);
      expect(_vars(r).keys, unorderedEquals(['shown', 'flipped_flipCard1', 'flipped_two']));
      expect(jsonEncode(_node(r, 'flipCard2')['actions']), contains('"variable":"shown"'));
    });

    test('an event out: the use\'s actions where the body names it, result as the body says; an event in an expression is whether it was given', () {
      final r = _parse('Column\n  ColorPicker onPick={toast "{result}"}\n  Tile "a.pdf" onDownload={toast "saved"}\n  Tile "b.pdf"\n');
      expect(r.issues, isEmpty);
      expect(_problems(r.document), isEmpty);
      final swatch = jsonEncode(_node(r, 'swatch1')['actions']);
      expect(swatch, contains('"variable":"color_colorPicker1"'));
      expect(swatch, contains(r'"message":"${= (item)}"'));
      final tiles = jsonEncode(r.document);
      expect(tiles, contains('"message":"saved"'));
      // b.pdf has no download button: its `if onDownload` is false.
      expect(tiles, contains('"visible":"\${= false}"'));
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
      expect(_problems(r.document), isEmpty);
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
Stepper#steps steps=[] bind=step current done=[] onPick
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
  Stepper#qty "Guests" bind=qty min=1 max=8 onChange={toast "{result}"}
  Stepper steps=["Cart","Pay","Done"] bind=at onPick={toast "{result}"}
  Stepper steps=["A","B"] current={at}
''', catalog: catalog, options: options));
      expect(r.issues, isEmpty);
      expect([for (final u in _uses(r, 'definition')) u.to], ['Stepper#steps', 'Stepper#steps']);
      // The first is the component, as it was.
      expect(_node(r, 'qty')['type'], 'Stepper');
      expect(jsonEncode(r.document), allOf(contains('Cart'), contains('coalesce((at), step_stepper2)')));
    });

    test('a definition of a component\'s word that names no meaning is not read', () async {
      final (catalog, options) = await stepper({'Stepper.txt': 'Stepper steps=[]\n  Text "never"\n'});
      final r = Catalog.run(catalog, () => parseNotation('Column\n  Stepper steps=["A"]\n', catalog: catalog, options: options));
      expect(_uses(r, 'definition'), isEmpty);
      expect(jsonEncode(r.document), isNot(contains('never')));
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
  Stepper items=["A","B"] bind=at onSelect={toast "{result}"}
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
    test('bind= to a variable the page never declared declares it, with the word\'s default', () {
      final r = _parse('Column\n  ColorPicker bind=tint\n', _open);
      expect(r.issues, isEmpty);
      expect(_vars(r), {'tint': ''});
      expect(_problems(r.document), isEmpty);
      // Declared by the page: the page's.
      final own = _parse('state tint="#FF2563EB"\nColumn\n  ColorPicker bind=tint\n', _open);
      expect(_vars(own), {'tint': '#FF2563EB'});
    });

    test('a record written as JSON given to a parameter is that record in an expression', () {
      final v = const NotationVocabulary().define({'Pin.txt': 'Pin at\n  Text "{at.lat}, {at.lng}"\n'});
      final r = parseNotation('Column\n  Pin at={"lat":44.9,"lng":-93.1}\n', catalog: standardCatalog, options: const NotationOptions().open(vocabulary: v));
      expect(r.issues, isEmpty);
      expect(jsonEncode(r.document), contains(r'{\"lat\":44.9,\"lng\":-93.1}.lat'));
      expect(_problems(r.document), isEmpty);
    });
  });

  group('a definition\'s errors are said against it', () {
    test('checkDefinitions expands each with its defaults: a line it gets wrong is its file and line', () {
      final v = const NotationVocabulary().define({
        'Good.txt': _group,
        'Broken.txt': 'Broken "label"\n  Column\n    Text "{label}" wobble=3\n    Bogus "x"\n',
      });
      expect(checkDefinitions(v, catalog: standardCatalog, validate: _problems), [
        'Broken.txt:4: No node type "Bogus". Write a type of the catalog (Column, Row, Text, Button, Input, Toggle, Slider…).',
        startsWith('Broken.txt:1: Broken: unknown_prop /nodes/text1/props/wobble'),
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
      expect(_problems(r.document), isEmpty);
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
      expect(_problems(r.document), isEmpty);
      final layout = _node(r, 'tile1')['layout'] as Map;
      expect(layout['height'], {'hug': 200});
      expect(layout['constraints'], {'minHeight': 200});
    });

    test('Row wrap over an each wraps its copies', () {
      final r = read('state tags=["a","b","c"]\nColumn w=200\n  Tags items={tags}\ndefine Tags items=[]\n  Row gap=8 wrap\n    each t in items\n      Chip "{t}"\n');
      expect(r.issues, isEmpty);
      expect(_problems(r.document), isEmpty);
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
      expect(_problems(r.document), isEmpty);
      expect(_node(r, 'span1')['props'], containsPair('text', r'${= (draft.end) - (draft.start)} days'));
      expect(_node(r, 'tempo1')['props'], containsPair('text', r'${bpm} bpm'));
      // A word that is no variable is the word.
      expect(_node(r, 'tempo2')['props'], containsPair('text', 'fast bpm'));
    });

    test('a choice between actions takes a use\'s events, given or not', () {
      final r = read('state ok=true\nColumn\n  Try onOk={toast "good"} onError={toast "bad"}\n  Try onError={toast "only bad"}\ndefine Try onError onOk\n  Button "Go" onTap={ok ? onOk : onError}\n');
      expect(r.issues, isEmpty);
      expect(_problems(r.document), isEmpty);
      final both = jsonEncode(_node(r, 'try1')['actions']), one = jsonEncode(_node(r, 'try2')['actions']);
      expect(both, allOf(contains('"good"'), contains('"bad"'), contains('"type":"if"')));
      expect(one, allOf(contains('"only bad"'), contains('"then":[]')));
    });

    test('every {expression}: a timer whose interval is worked out', () {
      final r = read('state bpm=120\nColumn\n  Metro bpm={bpm}\ndefine Metro bpm=120\n  state beat=0\n  every {60000/bpm} onTick={beat=beat+1}\n  Text "{beat}"\n');
      expect(r.issues, isEmpty);
      expect(_problems(r.document), isEmpty);
      expect(jsonEncode(r.document), contains(r'"intervalMs":"${= 60000/(bpm)}"'));
    });

    test('each … reorder over a list the use works out is shown in order (no variable to write the order to)', () {
      final r = read('state rows=[{"n":"a"},{"n":"b"}]\nColumn\n  Sortable items={filter(rows, r => r.n != "")}\n  Sortable items={rows}\ndefine Sortable items=[]\n  Column\n    each it in items reorder\n      Text "{it.n}"\n');
      expect(r.issues, isEmpty);
      expect(_problems(r.document), isEmpty);
      expect(jsonEncode(_node(r, 'listView1')['props']), isNot(contains('reorder')));
      expect(jsonEncode(_node(r, 'listView2')['props']), contains('reorder'));
    });

    test('a border\'s width and colour together, as models write them', () {
      final r = read('Column\n  Ring2 on=true\ndefine Ring2 on=false\n  Column gap=4\n    Box#a w=40 h=40 border=2 borderColor=#FF2563EB\n    Box#b w=40 h=40 border="#FF2563EB 2"\n    Box#c w=40 h=40 border-width=3 border=#FF2563EB\n    Box#d w=40 h=40 border={on ? 2 : 0} stroke=#FF2563EB\n    Box#e w=40 h=40 border=1\n');
      expect(r.issues, isEmpty);
      expect(_problems(r.document), isEmpty);
      Map<String, Object?> deco(String id) => (_node(r, '${id}_ring21')['decoration'] as Map).cast();
      for (final (id, w) in [('a', 2), ('b', 2), ('c', 3)]) {
        expect(deco(id), {'strokes': [{'color': '#FF2563EB'}], 'strokeWidth': w}, reason: id);
      }
      expect(deco('d')['strokes'], [{'color': '#FF2563EB'}]);
      expect((_node(r, 'd_ring21')['bind'] as Map)['decoration.strokeWidth'], r'${= true ? 2 : 0}');
      expect(deco('e'), {'strokes': [{'color': const NotationOptions().line}], 'strokeWidth': 1});
    });

    test('a font and a weight on an Input', () {
      final r = read('Column\n  Field2\ndefine Field2\n  Input "Code" font="JetBrains Mono" weight=600 fontSize=18\n');
      expect(r.issues, isEmpty);
      expect(_problems(r.document), isEmpty);
      expect((_node(r, 'field21')['props'] as Map)['style'], {'fontFamily': 'JetBrains Mono', 'fontWeight': 600, 'fontSize': 18});
    });
  });

  group('an open of an overlay that was never written (Review 3, D17)', () {
    const text = 'Column\n  Button "Add" onTap={open addRecipe}\n  Button "Again" onTap={open addRecipe}\n';
    test('with the vocabulary open: a quiet sheet titled with the id opens, recorded as a wanted overlay, not an issue', () {
      final r = parseNotation(text, catalog: standardCatalog, options: const NotationOptions(width: 1280).open());
      expect(r.issues, isEmpty);
      expect(_problems(r.document), isEmpty);
      expect(r.document['roots'], ['screen', 'addRecipe']);
      expect(jsonEncode(r.document), allOf(contains('"text":"Add recipe"'), contains('"text":"Not written yet."'), contains('"to":"addRecipe","presentation":"bottomSheet"')));
      final wanted = _uses(r, 'overlay').single;
      expect((wanted.word, wanted.line, wanted.node), ('addRecipe', 2, 'addRecipe'));
    });

    test('with it closed, nothing is made: the open is what does not validate, as before', () {
      final r = parseNotation(text, catalog: standardCatalog, options: const NotationOptions(width: 1280));
      expect(r.document['roots'], ['screen']);
      expect(_problems(r.document), everyElement(startsWith('unknown_screen')));
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
      expect(_problems(r.document), isEmpty);
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
}
