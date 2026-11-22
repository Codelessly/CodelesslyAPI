// The parser and printer bugs the notation reference exposed (wave 3, the
// reference family; docs/design/22-notation-parity.md, section 4.10): a
// line's strings, a box's text, the order a line's words and its JSON are
// written in, keys once, a variable's type, the words that print as written,
// and the verbs the reference documents.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

final _ids = RegExp(r'^(\s*[A-Za-z][A-Za-z0-9.]*)#[A-Za-z_][A-Za-z0-9_]*', multiLine: true);

NotationResult _read(String text) => parseNotation(text, catalog: standardCatalog, options: const NotationOptions(reflow: false));

String _print(Json doc) => printNotation(doc, catalog: standardCatalog);

/// [text] read with no issue, printed: the print, ids aside.
String _round(String text) {
  final r = _read(text);
  expect(r.issues, isEmpty, reason: text);
  return _print(r.document).replaceAllMapped(_ids, (m) => m[1]!);
}

/// [text] prints back as written, and its print prints as itself.
void _same(String text) {
  final once = _round(text);
  expect(once, text);
  expect(_round(once), once, reason: 'the print printed again');
}

Iterable<Json> _nodes(Json doc, String type) => readMap(doc['nodes'])!.values.map(readMap).nonNulls.where((n) => n['type'] == type);

void main() {
  group('a line\'s quoted strings (design 13, section 3)', () {
    test('a second string where the word has no place for one is said, and the first kept', () {
      final r = _read('Column\n  Text "a" "b"');
      expect(r.issues.map((i) => i.message), [contains('A Text takes one quoted string')]);
      expect(readMap(_nodes(r.document, 'text').single['props'])!['text'], 'a');
      final b = _read('Column\n  Button "Save" "Now"');
      expect(b.issues.single.message, contains('A Button takes one quoted string'));
      expect(readMap(_nodes(b.document, 'filledButton').single['props'])!['label'], 'Save');
    });

    test('an Input takes a label and a hint, a tile a title and a subtitle; a third is said', () {
      final r = _read('Column\n  Input "Email" "you@example.com" "x"');
      expect(r.issues.single.message, contains('An Input takes two quoted strings'));
      final d = readMap(readMap(_nodes(r.document, 'textField').single['props'])!['decoration'])!;
      expect((d['labelText'], d['hintText']), ('Email', 'you@example.com'));
      expect(_read('Column\n  ListTile "Title" "Sub"').issues, isEmpty);
      expect(_read('Column\n  ListTile "Title" "Sub" "More"').issues.single.message, contains('two quoted strings'));
    });

    test('a container\'s strings are texts in it, as many as written', () {
      final r = _read('Column "One" "Two" "Three"');
      expect(r.issues, isEmpty);
      expect([for (final t in _nodes(r.document, 'text')) readMap(t['props'])!['text']], ['One', 'Two', 'Three']);
    });
  });

  group('a box has no text', () {
    test('box "x" is said and sets nothing; Image "url" is its picture', () {
      final r = _read('Column\n  box "x" w=40 h=40');
      expect(r.issues.single.message, contains('A box has no text of its own'));
      expect(_nodes(r.document, 'box').single['props'], isNull);
      final i = _read('Column\n  Image "https://example.com/a.png" h=120');
      expect(i.issues, isEmpty);
      expect(jsonEncode(_nodes(i.document, 'box').single['decoration']), contains('https://example.com/a.png'));
    });

    test('a box holding a text the catalog does not have is not printed as box "…"', () {
      final r = _read('Column\n  box w=40 h=40');
      final doc = jsonDecode(jsonEncode(r.document)) as Json;
      final box = readMap(doc['nodes'])!.entries.firstWhere((e) => readMap(e.value)!['type'] == 'box');
      (box.value as Map)['props'] = {'text': 'x'};
      final printed = _print(doc);
      expect(printed, isNot(contains('box "x"')));
      // A value the catalog does not have stays JSON, said where it is read
      // (design 22, section 5), and the document reads back.
      final back = _read(printed);
      expect(back.issues.map((i) => i.message), everyElement(contains('A box has no "text"')));
      expect(readMap(_nodes(back.document, 'box').single['props']), {'text': 'x'});
    });
  });

  group('one order for a line\'s words and its JSON (design 22, 4.10)', () {
    test('a text style\'s words are written in one order, whatever the JSON\'s key order', () {
      for (final written in [
        'Text "t" weight=700 lineHeight=1.3 color=#FFFFFFFF',
        'Text "t" color=#FFFFFFFF lineHeight=1.3 weight=700',
        'Text "t" lineHeight=1.3 weight=700 color=#FFFFFFFF',
      ]) {
        expect(_round('Column\n  $written'), 'Column\n  Text "t" weight=700 color=#FFFFFFFF lineHeight=1.3', reason: written);
      }
      _same('Column\n  Text "u" weight=700 color=#FF000000 fontFamily=Inter lineHeight=1.4 letterSpacing=1 italic');
      _same('Column\n  Input "Code" size=15 weight=600 color=#FF111827');
    });

    test('a tail\'s and the document line\'s JSON keys are in order', () {
      final r = _read('Column\n  Text "a"');
      final doc = jsonDecode(jsonEncode(r.document)) as Json;
      final text = readMap(doc['nodes'])!.entries.firstWhere((e) => readMap(e.value)!['type'] == 'text');
      (text.value as Map)['zeta'] = 1;
      (text.value as Map)['alpha'] = {'z': 1, 'a': 2};
      final printed = _print(doc);
      final tail = RegExp(r'\{"[^\n]*\}$', multiLine: true).firstMatch(printed)![0]!;
      expect(tail.indexOf('"alpha"'), lessThan(tail.indexOf('"zeta"')), reason: printed);
      expect(tail, contains('{"a":2,"z":1}'));
    });
  });

  group('a chart\'s keys once a line', () {
    test('BarChart, LineChart, Donut and Gauge print each key once, and as themselves again', () {
      for (final line in [
        'BarChart values=[3,5,4] labels=["a","b","c"]',
        'LineChart values=[1,2,3]',
        'Donut values=[1,2] labels=["x","y"]',
        'Gauge value=0.5',
      ]) {
        final printed = _round('Column\n  $line');
        for (final l in printed.split('\n')) {
          final keys = [for (final m in RegExp(r'(?:^|\s)([A-Za-z][\w.]*)=').allMatches(l.replaceAll(RegExp(r'"[^"]*"|\[[^\]]*\]'), '""'))) m[1]!];
          expect(keys.toSet().length, keys.length, reason: '$line → $l');
        }
        expect(_round(printed), printed, reason: line);
      }
    });
  });

  group('a variable\'s type', () {
    test('a declared type that is none of VariableType\'s is said, with the type meant', () {
      final empty = LayoutDocument(catalog: Catalog.core);
      final r = applyOps(empty, [
        const RootsOp(['home']),
        const SetOp('home', {'type': 'canvas', 'layout': {'width': 390, 'height': 844}}),
        const VarsOp('home', set: {
          'price': {'type': 'number', 'formula': 'qty * 2'},
          'qty': {'type': 'decimal', 'value': 1},
        }),
      ], catalog: Catalog.core);
      final d = r.errors.single;
      expect((d.code, d.suggestion), ('invalid_variable', 'decimal'));
      expect(d.message, contains('not "number"'));
    });

    test('state x:number is a decimal in the notation; a type that is no type is refused', () {
      expect(_read('state price:number=0\nColumn').issues, isEmpty);
      expect(_read('state price:money=0\nColumn').issues.single.message, contains("A variable's type is one of"));
    });
  });

  group('words that print as they were written', () {
    test('Grid cols=3 with an each prints as a Grid, not as its column and gridView', () {
      _same('state items=[{"n":"a"},{"n":"b"}]\nColumn\n  Grid cols=3\n    each item in items\n      Text "{item.n}"');
      _same('state items=[{"n":"a"},{"n":"b"}]\nColumn\n  Grid cols=2 gap=12 pad=8 fill=#FFEEEEEE\n    each item in items\n      Text "{item.n}"');
    });

    test('project on a page read alone is its state', () {
      expect(_read('project cart=[]\nColumn').document, _read('state cart=[]\nColumn').document);
      expect(_round('project cart=[]\nColumn'), 'state cart=[]\nColumn');
    });

    test('form, pan, motion, reorderHandle and a text style field by name print as written', () {
      _same('Column\n  Column form=true\n    Input "A"');
      _same('Column\n  box w=40 h=40 pan.axis=horizontal');
      _same('Column\n  box w=40 h=40 scale=1.2');
      _same('Column\n  box w=40 h=40 motion.shiftX=0.5');
      _same('Column\n  Row reorderHandle=true\n    Text "x"');
      _same('Column\n  Text "t" letterSpacing=0.4');
      // A text style field by its path prints as its word.
      expect(_round('Column\n  Text "u" style.letterSpacing=0.5 style.fontStyle=italic'), 'Column\n  Text "u" letterSpacing=0.5 italic');
    });
  });

  group('the verbs', () {
    test('every verb the reference lists reads as an action; an alias reads as its verb', () {
      for (final v in notationVerbs) {
        final sample = switch (v) {
          'confirm' => 'confirm "Sure?" then {close}',
          'close' || 'blur' => v,
          'toast' || 'announce' || 'copy' => '$v "x"',
          'link' => 'link https://example.com',
          _ => '$v a',
        };
        final r = _read('Column#a onTap={$sample}');
        expect(r.issues, isEmpty, reason: sample);
        expect(jsonEncode(readMap(readMap(r.document['nodes'])!['a'])!['actions']), contains('"type"'), reason: sample);
      }
      for (final e in notationVerbAliases.entries) {
        String actions(String verb) => jsonEncode(readMap(readMap(_read('Column#a onTap={$verb}').document['nodes'])!['a'])!['actions']);
        expect(actions(e.key), actions(e.value));
      }
      expect(_read('Column#a onTap={launch x}').issues.single.message, contains('Unknown action'));
    });
  });
}
