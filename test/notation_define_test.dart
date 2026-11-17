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

  group('a stand-in with nothing to draw shows what is missing', () {
    const page = NotationOptions(width: 1280);
    test('a quiet dashed box with its word (and its first string value), as big as its w and h say', () {
      final r = parseNotation('Column\n  QRCode value={code} size=120\n  Map h=260 start="Saffron"\n', catalog: standardCatalog, options: page.open());
      expect(_problems(r.document), isEmpty);
      final qr = _node(r, 'column2');
      expect((qr['decoration'] as Map)['dashPattern'], [4, 3]);
      expect((qr['decoration'] as Map)['strokes'], [
        {'color': page.line},
      ]);
      expect(((qr['layout'] as Map)['constraints'] as Map)['minHeight'], 40);
      expect(_node(r, 'column2Label')['props'], containsPair('text', 'QRCode'));
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
      final r = parseNotation('Column\n  QRCode value={code}\n', catalog: standardCatalog, options: page);
      expect(r.issues, isNotEmpty);
      expect(jsonEncode(r.document), isNot(contains('dashPattern')));
    });
  });
}
