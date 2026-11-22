// A defined word's own design at a width (docs/design/24-a-design-at-a-
// width.md): `at phone` under a node line of a definition, read where the
// word is used; each use holds the part's own lines and the block's, hidden
// by media rules; `...` and `...#id` the part's own lines read again, the
// lines a use writes under the word among them.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/notation_site.dart';
import 'package:test/test.dart';

import '../notation_words.dart';

Object? _sorted(Object? v) => switch (v) {
      final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
      final List l => [for (final e in l) _sorted(e)],
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
    };

NotationResult _parse(String text, {double width = 390}) =>
    Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog, options: withTestWords(NotationOptions(width: width))));

NotationResult _with(Map<String, String> files, String text, {double width = 390}) => Catalog.run(
    standardCatalog,
    () => parseNotation(text,
        catalog: standardCatalog, options: NotationOptions(width: width).open(openVocabulary: false, vocabulary: const NotationVocabulary().define(files))));

Map<String, Object?> _nodes(NotationResult r) => {
      for (final c in [r.document, ...((r.document['canvases'] as Map?)?.values ?? const [])]) ...?((c as Map)['nodes'] as Map?)?.cast<String, Object?>(),
    };
Map<String, Object?> _node(NotationResult r, String id) => (_nodes(r)[id] as Map).cast<String, Object?>();
List<String> _kids(NotationResult r, String id) => [for (final k in (_node(r, id)['children'] as List? ?? const [])) k as String];
String? _text(NotationResult r, String id) => (_node(r, id)['props'] as Map?)?['text'] as String?;

/// Whether node [id] and every node it is under is shown on a window
/// [w] wide by its media rules (a rule's `visible`, the later winning).
bool _shown(NotationResult r, String id, num w, [num h = 900]) {
  final nodes = _nodes(r);
  String? parent(String id) {
    for (final e in nodes.entries) {
      final n = e.value as Map;
      if ((n['children'] as List? ?? const []).contains(id) || ((n['slots'] as Map?) ?? const {}).containsValue(id)) return e.key;
    }
    return null;
  }

  for (String? at = id; at != null; at = parent(at)) {
    final n = (nodes[at] as Map).cast<String, Object?>();
    var visible = n['visible'] != false;
    for (final rule in MediaRule.listFromJson(n['media'])) {
      if (!rule.holds(w.toDouble(), h.toDouble(), Breakpoints.defaults)) continue;
      if (rule.patch['visible'] case final bool v) visible = v;
    }
    if (!visible) return false;
  }
  return true;
}

/// The texts shown on a window [w] wide, in the order they are laid out.
List<String> _texts(NotationResult r, num w) {
  final out = <String>[];
  void walk(String id) {
    if (!_shown(r, id, w)) return;
    if (_text(r, id) case final String t) out.add(t);
    _kids(r, id).forEach(walk);
    for (final k in ((_node(r, id)['slots'] as Map?) ?? const {}).values) {
      walk(k as String);
    }
  }

  for (final root in (r.document['roots'] as List)) {
    walk(root as String);
  }
  return out;
}

List<String> _said(NotationResult r) => [for (final i in r.issues) i.message];

/// Prints [r]'s document and reads it back: the print, which must give the
/// same document with nothing said.
String _roundTrip(NotationResult r) {
  final text = Catalog.run(standardCatalog, () => printNotation(r.document, catalog: standardCatalog));
  final back = Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog, options: withTestWords(notationOptionsFor(r.document))));
  expect(back.issues, isEmpty, reason: text);
  expect(jsonEncode(_sorted(back.document)), jsonEncode(_sorted(r.document)), reason: text);
  return text;
}

const _tile = '''
define Tile "title"
  Column gap=4
    Text.strong#t "{title}"
    Text "wide"
    at phone
      Row gap=8
        ...#t
        Text "phone {title}"
''';

const _shelf = '''
define Shelf
  Row gap=16
    Text "head"
    ...
    at phone
      Column gap=8
        ...
''';

void main() {
  group('a block in a definition', () {
    test('each use holds the part\'s own lines and the block\'s, one of which shows', () {
      final r = _parse('${_tile}Row\n  Tile "A"\n  Tile "B"');
      expect(r.issues, isEmpty);
      for (final (use, title) in [('tile1', 'A'), ('tile2', 'B')]) {
        final kids = _kids(r, use);
        expect(kids, hasLength(3));
        expect(kids.first, 't_$use');
        expect(_node(r, kids.last)['name'], 'at phone');
        expect(_kids(r, kids.last).first, 't_${use}_phone');
        expect(_text(r, 't_${use}_phone'), title);
        expect(_shown(r, kids.first, 1440), isTrue);
        expect(_shown(r, kids.first, 390), isFalse);
        expect(_shown(r, kids.last, 1440), isFalse);
        expect(_shown(r, kids.last, 390), isTrue);
      }
      expect(_texts(r, 1440), ['A', 'wide', 'B', 'wide']);
      expect(_texts(r, 390), ['A', 'phone A', 'B', 'phone B']);
      final text = _roundTrip(r);
      expect(text, contains('    at phone\n      Row gap=8'));
      expect(text, contains('        ...#t_tile1'));
    });

    test('is the same whatever width the page is written at', () {
      final narrow = _parse('${_tile}Column\n  Tile "A"', width: 390), wide = _parse('${_tile}Column\n  Tile "A"', width: 1440);
      expect(narrow.issues, isEmpty);
      expect(wide.issues, isEmpty);
      for (final w in [390, 800, 1440]) {
        expect(_texts(narrow, w), _texts(wide, w), reason: '$w');
      }
    });

    test('a use with an id of its own names its lines after it', () {
      final r = _parse('${_tile}Row\n  Tile#mine "A"');
      expect(r.issues, isEmpty);
      expect(_kids(r, 'mine').first, 't_mine');
      expect(_nodes(r), contains('t_mine_phone'));
    });

    test('under the root line, ... brings the lines a use writes, with the part\'s own', () {
      final r = _parse('${_shelf}Shelf\n  Text#a "one"\n  Text "two"');
      expect(r.issues, isEmpty);
      expect(_texts(r, 1440), ['head', 'one', 'two']);
      expect(_texts(r, 390), ['head', 'one', 'two']);
      expect(_nodes(r), contains('a_phone'));
      expect(_shown(r, 'a', 390), isFalse);
      expect(_shown(r, 'a_phone', 390), isTrue);
      expect(_node(r, _kids(r, 'shelf1').last)['type'], 'column');
      expect(_roundTrip(r), contains('  at phone\n    Column gap=8\n      ...'));
    });

    test('...#id brings one line, the lines of a named slot under it', () {
      final r = _parse('''
define Split
  Row gap=16
    Column#side w=240
      ...Side
    Column#main grow
      ...
    at phone
      Column gap=8
        ...#main
        ...#side
Split
  Side
    Text "nav"
  Text#body "content"
''', width: 1440);
      expect(r.issues, isEmpty);
      expect(_texts(r, 1440), ['nav', 'content']);
      expect(_texts(r, 390), ['content', 'nav']);
      expect(_kids(r, 'main_split1_phone'), ['body_phone']);
      _roundTrip(r);
    });

    test('a block under a line inside the word, the wider first', () {
      final r = _parse('''
define Entry "title"
  Column gap=8
    Row#head gap=8
      Text#t "{title}"
      Text#m "meta"
      at tablet
        Column
          ...
      at phone
        ...#t
    Text "body"
Entry "A"
''', width: 1440);
      expect(r.issues, isEmpty);
      expect(_texts(r, 1440), ['A', 'meta', 'body']);
      expect(_texts(r, 800), ['A', 'meta', 'body']);
      expect(_texts(r, 390), ['A', 'body']);
      expect(_nodes(r), containsPair('t_entry1_tablet', anything));
      expect(_nodes(r), containsPair('t_entry1_phone', anything));
      _roundTrip(r);
    });

    test('in an each, and the word\'s own state is one for both designs', () {
      final r = _parse('''
define Flip "title"
  state open=false
  Column gap=4
    Button#b "{title}" onTap={open=!open}
    if open
      Text "more"
    at phone
      Row
        ...
state items=[{"n":"a"},{"n":"b"}]
Column
  each it in items
    Flip title={it.n}
''');
      expect(r.issues, isEmpty);
      final names = [for (final v in ((r.document['variables'] as Map)['screen'] as List)) (v as Map)['name']];
      expect(names, ['items', 'open_flip1']);
      expect(jsonEncode(_node(r, 'b_flip1_phone')['actions']), jsonEncode(_node(r, 'b_flip1')['actions']));
      expect(jsonEncode(_node(r, 'b_flip1')['actions']), contains('open_flip1'));
      _roundTrip(r);
    });

    test('a value the use binds is one for both, and an action naming a line reaches the one shown', () {
      final r = _parse('''
define Finder @value="" "hint"
  Column gap=8
    Row#bar gap=8
      Input#q "{hint}" @value
      Button "Go" onTap={focus q}
    at phone
      Column gap=4
        ...#bar
state search=""
Column
  Finder "Find" @search
  Finder "Other"
''');
      expect(r.issues, isEmpty);
      expect((_node(r, 'q_finder1_phone')['bind'] as Map)['props.initialValue'], r'${search}');
      expect((_node(r, 'q_finder2_phone')['bind'] as Map)['props.initialValue'], r'${value_finder2}');
      final go = jsonEncode(_node(r, _kids(r, 'bar_finder1').last)['actions']);
      expect(go, contains('"node":"q_finder1"'));
      expect(go, contains('"node":"q_finder1_phone"'));
      expect(go, isNot(contains('finder2')));
      _roundTrip(r);
    });

    test('of a word a design system or a site defines in a file', () {
      final r = _with({'Tile.txt': 'Tile "title"\n  Column gap=4\n    Text#t "{title}"\n    at phone\n      Row\n        ...#t\n        Icon "star"\n'}, 'Column\n  Tile "A"\n  Tile "B"');
      expect(r.issues, isEmpty);
      expect(_kids(r, _kids(r, 'tile2').last), ['t_tile2_phone', 'icon2']);
      final v = const NotationVocabulary().define({'Tile.txt': 'Tile "title"\n  Column gap=4\n    Text#t "{title}"\n    at phone\n      Row\n        ...#t\n'});
      expect(Catalog.run(standardCatalog, () => checkDefinitions(v, catalog: standardCatalog)), isEmpty);
      expect(definitionLines(v).single, 'Tile "title"');
    });

    test('of a site\'s component file, and what its block gets wrong is said of the file', () {
      final site = NotationSiteFiles({
        'pages/home.txt': 'Row\n  Tile "A"\n  Tile "B"\n',
        'components/Tile.txt': 'define Tile "title"\n  Column gap=4\n    Text#t "{title}"\n    at phone\n      Row\n        ...#t\n',
      }, catalog: standardCatalog);
      expect(site.problems, isEmpty);
      final page = NotationSiteExpander(site, catalog: standardCatalog).expandAll().pages.single;
      expect((page.document['nodes'] as Map).keys, containsAll(['t_tile1_phone', 't_tile2_phone']));
      final wrong = NotationSiteFiles({
        'pages/home.txt': 'Row\n  Tile "A"\n',
        'components/Tile.txt': 'define Tile "title"\n  Column gap=4\n    Text#t "{title}"\n    at phone\n      Row\n        ...#zz\n',
      }, catalog: standardCatalog);
      expect([for (final p in wrong.problems) (p.path, p.line, p.message)], [
        ('components/Tile.txt', 6, 'page:6: ...#zz: no line under Column (line 2) has the id "zz" (its lines with ids: t). A block names a line of the part by its id.'),
      ]);
    });

    test('in an overlay', () {
      final r = _parse('${_tile}Column\n  Button "Open" onTap={open d}\nDialog#d "T"\n  Tile "A"');
      expect(r.issues, isEmpty);
      expect(_nodes(r), contains('t_tile1_phone'));
      _roundTrip(r);
    });

    test('under a page word the definition writes', () {
      final r = _parse('''
define Band "title"
  Section
    Text.heading2#h "{title}"
    Row#cols gap=24
      ...
    at phone
      Column gap=12
        ...#h
        ...#cols
Page
  Band "Plans"
    Text "one"
    Text "two"
''', width: 1440);
      expect(r.issues, isEmpty);
      expect(_texts(r, 1440), ['Plans', 'one', 'two']);
      expect(_texts(r, 390), ['Plans', 'one', 'two']);
      expect(_shown(r, 'cols_band1', 390), isFalse);
      expect(_shown(r, 'cols_band1_phone', 390), isTrue);
      _roundTrip(r);
    });

    test('the reflow fits the part\'s own lines where no block holds, and leaves the block as written', () {
      final r = _parse('${_shelf}Shelf\n  Text#a "one"\n  Text "two"', width: 1200);
      expect(r.issues, isEmpty);
      final media = (_node(r, 'shelf1')['media'] as List).cast<Map>();
      // The row wraps on a tablet (the reflow's), and not where the block holds.
      expect(media.first, {'maxWidth': 1023, 'patch': {'props': {'wrap': true, 'runSpacing': 12}}});
      expect(media[1], {'maxWidth': 699, 'patch': {'props': {'wrap': null, 'runSpacing': null}}});
      expect(_node(r, _kids(r, 'shelf1').last)['media'], hasLength(1));
      _roundTrip(r);
    });

    test('read as it arrives, the operations build the same document', () {
      for (final text in ['${_tile}Column\n  Row\n    Tile "A"\n    Tile "B"\n  Text "after"', '${_shelf}Column\n  Shelf\n    Text#a "one"\n  Text "after"', '$_tile${_shelf}Shelf\n  Tile "A"', '${_shelf}Column\n  Shelf\n    Text "one"\n    at phone\n      Text "page phone"\n  Text "after"']) {
        final stream = Catalog.run(standardCatalog, () => NotationStream(catalog: standardCatalog, options: withTestWords(const NotationOptions(width: 1440))));
        var doc = LayoutDocument(catalog: standardCatalog);
        void apply(List<Json> ops) {
          if (ops.isEmpty) return;
          final a = applyOps(doc, {'ops': ops}, catalog: standardCatalog);
          expect(a.errors, isEmpty);
          doc = a.document;
        }

        for (final line in const LineSplitter().convert(text)) {
          apply(Catalog.run(standardCatalog, () => stream.add('$line\n')));
        }
        apply(Catalog.run(standardCatalog, stream.close));
        final whole = _parse(text, width: 1440).document;
        expect(jsonEncode(_sorted(LayoutDocument.fromJson(doc.toJson(), catalog: standardCatalog).toJson())),
            jsonEncode(_sorted(LayoutDocument.fromJson(whole, catalog: standardCatalog).toJson())), reason: text);
      }
    });
  });

  group('a word with a design at a width, in a block', () {
    test('written in a block of the page', () {
      final r = _parse('${_tile}Column#c\n  Text "wide page"\n  at phone\n    Tile "A"');
      expect(r.issues, isEmpty);
      expect(_texts(r, 1440), ['wide page']);
      expect(_texts(r, 390), ['A', 'phone A']);
      final text = _roundTrip(r);
      // The page's block is printed as one; the word's, inside it, as its lines are.
      expect(text, contains('\n  at phone\n    Column#tile1'));
      expect(text, isNot(contains('\n      at phone')));
    });

    test('read again by a block of the page', () {
      final r = _parse('${_tile}Row#shelf\n  Tile "A"\n  at phone\n    Column\n      ...');
      expect(r.issues, isEmpty);
      expect(_texts(r, 1440), ['A', 'wide']);
      expect(_texts(r, 390), ['A', 'phone A']);
      _roundTrip(r);
    });

    test('a word in a word, each with its own', () {
      final r = _parse('$_tile${_shelf}Shelf\n  Tile "A"\n  Tile "B"');
      expect(r.issues, isEmpty);
      expect(_texts(r, 1440), ['head', 'A', 'wide', 'B', 'wide']);
      expect(_texts(r, 390), ['head', 'A', 'phone A', 'B', 'phone B']);
      // The copy of a use is named after the use; the lines it reads again in turn after the copy.
      expect(_kids(r, 'tile1_phone').first, 't_tile1_phone_2');
      expect(_nodes(r), contains('t_tile1_phone_2_phone'));
      _roundTrip(r);
    });

    test('a block of the page among the lines a word reads again is said, and not read again', () {
      final r = _parse('${_shelf}Shelf\n  Column#inner\n    Text "wide"\n    at phone\n      Text "narrow"\n  Text "last"');
      expect(_said(r), [
        'page:7: ... brings the lines of this part again without the at phone block written among them (line 11): a block inside a block is not read. What the line that block is under shows at this width is its own lines.',
      ]);
      expect(_texts(r, 1440), ['head', 'wide', 'last']);
      expect(_texts(r, 390), ['head', 'wide', 'last']);
      _roundTrip(r);
    });

    test('a block the page writes under the use, in the part the word has its own for, is the one shown where it holds', () {
      final r = _parse('''
define Shelf
  Row gap=16
    Text "head"
    ...
    at tablet
      Column gap=8
        Text "word tablet"
    at phone
      Column gap=8
        Text "word phone"
Shelf
  Text "one"
  at phone
    Text "page phone"
''');
      expect(r.issues, isEmpty);
      expect(_texts(r, 1440), ['head', 'one']);
      expect(_texts(r, 800), ['word tablet']);
      expect(_texts(r, 390), ['page phone']);
      // Printed as its lines side by side (two blocks at one width under one part are no block's print), it reads back to the same document.
      final text = Catalog.run(standardCatalog, () => printNotation(r.document, catalog: standardCatalog));
      final back = Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog, options: withTestWords(notationOptionsFor(r.document))));
      expect(jsonEncode(_sorted(back.document)), jsonEncode(_sorted(r.document)), reason: text);
    });
  });

  group('what is said', () {
    List<String> defined(String body) => _said(_parse('define Tile "title"\n$body\nTile "A"'));

    test('where the definition is written, once: a block in a block, a slot in a block, an id no line has, a line after a block, a block under no line', () {
      expect(defined('  Column\n    Text#t "{title}"\n    at phone\n      Row\n        at tablet\n          Text "x"'), [
        'page:6: at tablet inside the at phone block is not read: write each block under the part itself, the wider first (where two hold, the later wins).',
      ]);
      expect(defined('  Column\n    Text#t "{title}"\n    at phone\n      ...Front'), [
        'page:5: In an at block, ... stands for the part\'s own lines (the lines under a use among them) and ...#id for one of them by its id: "...Front" is neither. A slot is written among the part\'s own lines, and a block brings them with ... .',
      ]);
      expect(defined('  Column\n    Text#t "{title}"\n    at phone\n      ...#t gap=4'), [
        'page:5: Nothing is written on a ... line (here "gap=4"): what differs at the width is written on the part\'s own line with a prefix (phone.gap=4), or the line is written out in the block.',
      ]);
      expect(defined('  Column\n    Text#t "{title}"\n    at phone\n      ...#zz'), [
        'page:5: ...#zz: no line under Column (line 2) has the id "zz" (its lines with ids: t). A block names a line of the part by its id.',
      ]);
      expect(defined('  Column\n    Text#t "{title}"\n    ...#t'), [
        'page:4: ...#t is read in an at block (one of the part\'s own lines, read again at that width). Among a definition\'s own lines, ... is where the lines under a use go.',
      ]);
      expect(defined('  Column\n    Text#t "{title}"\n    at phone\n      Text "p"\n    Text "after"'), [
        'page:6: This line comes after the at block of the line it is under, so it is read as a line of that part at every width. A part\'s own lines come first, then its at blocks: move it above "at phone".',
      ]);
      // Twice used, once said.
      final r = _parse('define Tile "title"\n  Column\n    Text#t "{title}"\n    at phone\n      ...#zz\nRow\n  Tile "A"\n  Tile "B"');
      expect(_said(r), hasLength(1));
      expect(r.issues.single.line, 5);
    });

    test('a block at the margin of the definition is not read, and the word still is', () {
      final r = _parse('define Tile "title"\n  Column\n    Text#t "{title}"\n  at phone\n    Text "p"\nTile "A"');
      expect(_said(r), ['page:4: at phone is under no line of the definition: write it under the line whose lines it changes (the first line, for the whole word), after that line\'s own lines.']);
      expect(_texts(r, 390), ['A']);
    });

    test('where the word is used: a width that is none, a part that takes no block', () {
      expect(defined('  Column\n    Text#t "{title}"\n    at wide\n      Text "x"'), [
        'page:4: at wide: "wide" is not a width. A block is written at phone, at tablet, at desktop, at max899, at min700.tablet or at portrait.',
      ]);
      expect(defined('  Column\n    each a in [1,2]\n      Text "z"\n      at phone\n        Text "y"').single,
          startsWith('page:5: at phone is under an each, which is not a part of its own'));
      expect(defined('  Column\n    Text#t "{title}"\n      at phone\n        Text "y"').single, startsWith('page:4: at phone: a Text takes no lines under it, so it has no design at a width'));
      expect(defined('  Column\n    Text "{title}"\n    at tablet\n      Text "t"\n    at phone\n      Text "p"\n    at tablet\n      Text "t2"'), [
        'page:8: at tablet is never shown: at tablet after it holds wherever it does. Write the wider first.',
        'page:8: at phone is never shown: at tablet after it holds wherever it does. Write the wider first.',
      ]);
      // Its lines are passed over: the part shows its own.
      final r = _parse('define Tile "title"\n  Column\n    Text#t "{title}"\n    at wide\n      Text "x"\nTile "A"');
      expect(_texts(r, 390), ['A']);
      expect(r.issues.single.line, 6);
    });

    test('a design system\'s definitions are checked with their blocks', () {
      final v = const NotationVocabulary().define({'Tile.txt': 'Tile "title"\n  Column gap=4\n    Text#t "{title}"\n    at wide\n      Text "x"\n'});
      expect(Catalog.run(standardCatalog, () => checkDefinitions(v, catalog: standardCatalog)), [
        'Tile.txt:4: at wide: "wide" is not a width. A block is written at phone, at tablet, at desktop, at max899, at min700.tablet or at portrait.',
      ]);
    });
  });
}
