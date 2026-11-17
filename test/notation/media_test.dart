// A node's media rules in the notation (docs/design/22 section 2.4, "Media
// rules: the form"): `phone.pad=16`, `max899.hidden`, `minTablet.gap=32`,
// read into the document's rules and printed back in the same words.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Object? _sorted(Object? v) => switch (v) {
      final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
      final List l => [for (final e in l) _sorted(e)],
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
    };

Map<String, Object?> _nodeOf(Map<String, Object?> doc, String id) => ((doc['nodes'] as Map)[id] as Map).cast<String, Object?>();

/// Node [id]'s line in [text], without its indent.
String _lineOf(String text, String id) => text.split('\n').map((l) => l.trim()).firstWhere((l) => RegExp('^[A-Za-z][A-Za-z0-9.]*#$id(\\s|\$)').hasMatch(l));

final _ruleWord = RegExp(r'^((phone|mobile|tablet|desktop|portrait|landscape|(min|max)([0-9]+|[A-Z][A-Za-z0-9]*))\.|(hide|show)=)');

/// The words of [line] that are its rules, in order.
List<String> _ruleWords(String line) => line.split(' ').where(_ruleWord.hasMatch).toList();

/// [line] under a column: expands, its node's rules are [media], and the
/// document prints the line's rules back in the same words, with none in
/// its `{…}` tail (the print reads back as the document). The line's other
/// words are the fields family's to print.
void _word(String line, List<Object?> media, {double width = 390}) {
  final id = RegExp(r'#([A-Za-z_][A-Za-z0-9_]*)').firstMatch(line)![1]!;
  final r = parseNotation('Column#root\n  $line', catalog: standardCatalog, options: NotationOptions(width: width));
  expect(r.issues, isEmpty, reason: line);
  expect(jsonEncode(_sorted(_nodeOf(r.document, id)['media'])), jsonEncode(_sorted(media)), reason: line);
  final text = printNotation(r.document, catalog: standardCatalog);
  final printed = _lineOf(text, id);
  expect(_ruleWords(printed), _ruleWords(line), reason: text);
  expect(printed, isNot(contains('"media"')), reason: text);
  final back = parseNotation(text, catalog: standardCatalog, options: notationOptionsFor(r.document));
  expect(jsonEncode(_sorted(back.document)), jsonEncode(_sorted(r.document)), reason: text);
}

/// A page [width] wide whose root column holds [nodes] (their JSON as a
/// document has them), each printed with its rules in words.
void _corpus(Map<String, Map<String, Object?>> nodes, {double width = 1280}) {
  final doc = <String, Object?>{
    'schema': 3,
    'roots': ['page'],
    'nodes': {
      'page': {'type': 'canvas', 'slots': {'body': 'root'}, 'layout': {'width': width, 'height': 900}},
      'root': {
        'type': 'column',
        'children': nodes.keys.toList(),
        'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
        'props': {'crossAxisAlignment': 'start'},
      },
      ...nodes,
    },
  };
  final text = printNotation(doc, catalog: standardCatalog);
  final back = parseNotation(text, catalog: standardCatalog, options: notationOptionsFor(doc));
  expect(jsonEncode(_sorted(back.document)), jsonEncode(_sorted(doc)), reason: text);
  for (final id in nodes.keys) {
    expect(_lineOf(text, id), isNot(contains('"media"')), reason: 'the rules of $id are said in words:\n$text');
  }
}

void main() {
  group('the conditions', () {
    test('the named sizes are the bounds hide= hides at', () {
      _word('Column#a gap=8 phone.pad=12', [
        {'maxWidth': 699, 'patch': {'layout': {'padding': 12}}},
      ]);
      _word('Column#a tablet.pad=12', [
        {'maxWidth': 1023, 'patch': {'layout': {'padding': 12}}},
      ]);
      _word('Column#a desktop.pad=32', [
        {'minWidth': 1024, 'patch': {'layout': {'padding': 32}}},
      ]);
    });

    test('a width in px, either bound', () {
      _word('Row#a gap=24 max899.direction=vertical', [
        {'maxWidth': 899, 'patch': {'props': {'direction': 'vertical'}}},
      ]);
      _word('Column#a min1100.pad=40', [
        {'minWidth': 1100, 'patch': {'layout': {'padding': 40}}},
      ]);
    });

    test('a breakpoint by its id, either bound', () {
      _word('Column#a minTablet.gap=32', [
        {'minWidth': 'tablet', 'patch': {'props': {'spacing': 32}}},
      ]);
      _word('Column#a maxMobile.gap=4', [
        {'maxWidth': 'mobile', 'patch': {'props': {'spacing': 4}}},
      ]);
      _word('Row#a hidden minDesktop.visible=true', [
        {'minWidth': 'desktop', 'patch': {'visible': true}},
      ]);
    });

    test('the orientation', () {
      _word('Column#a portrait.pad=8', [
        {'orientation': 'portrait', 'patch': {'layout': {'padding': 8}}},
      ]);
      _word('Column#a landscape.gap=4', [
        {'orientation': 'landscape', 'patch': {'props': {'spacing': 4}}},
      ]);
    });

    test('segments combine; a named size is written where a bound is one', () {
      _word('Column#a min700.tablet.hidden', [
        {'minWidth': 700, 'maxWidth': 1023, 'patch': {'visible': false}},
      ]);
      _word('Column#a min600.max899.landscape.pad=8', [
        {'minWidth': 600, 'maxWidth': 899, 'orientation': 'landscape', 'patch': {'layout': {'padding': 8}}},
      ]);
    });

    test('a bound said twice is said', () {
      final r = parseNotation('Column\n  Column phone.max899.pad=3', catalog: standardCatalog);
      expect(r.issues.single.message, contains('maxWidth'));
      expect((r.document['nodes'] as Map).values.any((n) => (n as Map).containsKey('media')), isFalse);
    });
  });

  group('the fields: the keys the line reads', () {
    test('words with one condition are one rule, in the order written; hide= is a rule of its own', () {
      _word('Column#a pad=24 phone.gap=8 phone.pad=12 tablet.pad=16 hide=desktop', [
        {'maxWidth': 699, 'patch': {'layout': {'padding': 12}, 'props': {'spacing': 8}}},
        {'maxWidth': 1023, 'patch': {'layout': {'padding': 16}}},
        {'minWidth': 1024, 'patch': {'visible': false, 'bind': {'visible': null}}},
      ]);
    });

    test('hide= and show= stay what they were, and print as they were', () {
      _word('Column#a hide=phone', [
        {'maxWidth': 699, 'patch': {'visible': false, 'bind': {'visible': null}}},
      ]);
      _word('Column#a hide=tablet', [
        {'maxWidth': 1023, 'patch': {'visible': false, 'bind': {'visible': null}}},
      ]);
      _word('Column#a show=phone', [
        {'minWidth': 700, 'patch': {'visible': false, 'bind': {'visible': null}}},
      ]);
      // A rule that only hides is the field's word, not hide=.
      _word('Column#a phone.hidden', [
        {'maxWidth': 699, 'patch': {'visible': false}},
      ]);
    });

    test('a text: its size, weight, color and text', () {
      _word('Text#t "Hi" phone.size=34 phone.weight=600', [
        {'maxWidth': 699, 'patch': {'props': {'style': {'fontSize': 34, 'fontWeight': 600}}}},
      ]);
      _word('Text#t "Sprint" tablet.text="Sprint 12 · {length(tasks)} tasks"', [
        {'maxWidth': 1023, 'patch': {'props': {'text': r'Sprint 12 · ${= length(tasks)} tasks'}}},
      ]);
    });

    test('props by their own names, and a main axis by its word', () {
      _word('flex#f direction=horizontal tablet.direction=vertical tablet.gap=14 tablet.crossAxisAlignment=stretch', [
        {'maxWidth': 1023, 'patch': {'props': {'direction': 'vertical', 'spacing': 14, 'crossAxisAlignment': 'stretch'}}},
      ]);
      _word('Row#a phone.center', [
        {'maxWidth': 699, 'patch': {'props': {'mainAxisAlignment': 'center'}}},
      ]);
      _word('Button#b "Go" phone.label=New', [
        {'maxWidth': 699, 'patch': {'props': {'label': 'New'}}},
      ]);
    });

    test('layout: sizes, padding, margin, the widest, a share', () {
      _word('Column#a w=1200 phone.w=72 phone.h=44', [
        {'maxWidth': 699, 'patch': {'layout': {'width': 72, 'height': 44}}},
      ]);
      _word('Column#a pad=[24,0,24,0] phone.pad=[12,0,12,0] phone.margin=[0,8,0,8]', [
        {'maxWidth': 699, 'patch': {'layout': {'padding': [12, 0, 12, 0], 'margin': [0, 8, 0, 8]}}},
      ]);
      _word('Column#a phone.maxw=460', [
        {'maxWidth': 699, 'patch': {'layout': {'constraints': {'maxWidth': 460}}}},
      ]);
      _word('Column#a phone.grow', [
        {'maxWidth': 699, 'patch': {'layout': {'flex': 1}}},
      ]);
    });

    test('decoration and opacity', () {
      _word('Column#a phone.fill=#FF000000 phone.radius=8', [
        {'maxWidth': 699, 'patch': {'decoration': {'fills': [{'color': '#FF000000'}], 'radius': 8}}},
      ]);
      _word('Column#a phone.opacity=0.5', [
        {'maxWidth': 699, 'patch': {'opacity': 0.5}},
      ]);
    });

    test('a binding at a width', () {
      _word('Column#a max899.visible={menuOpen}', [
        {'maxWidth': 899, 'patch': {'bind': {'visible': r'${menuOpen}'}}},
      ]);
      _word('Column#a hidden max899.hidden max899.visible={menuOpen}', [
        {'maxWidth': 899, 'patch': {'visible': false, 'bind': {'visible': r'${menuOpen}'}}},
      ]);
      _word('Column#a w=238 desktop.w={(screen.width - 328) / 4}', [
        {'minWidth': 1024, 'patch': {'bind': {'layout.width': r'${= (screen.width - 328) / 4}'}}},
      ]);
    });

    test('a value for a field the line binds drops the binding where the rule holds', () {
      final r = parseNotation('Column\n  Row#up w={size} h={size} phone.w=44 phone.h=44', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      expect(_nodeOf(r.document, 'up')['media'], [
        {
          'maxWidth': 699,
          'patch': {
            'layout': {'width': 44, 'height': 44},
            'bind': {'layout.width': null, 'layout.height': null},
          },
        },
      ]);
      // Printed in these words once the line's bindings are (the fields
      // family): the corpus test below.
    });

    test('what a rule cannot hold, and a word the line does not know, are said', () {
      final r = parseNotation('Column\n  Column phone.onTap={x=1}', catalog: standardCatalog);
      expect(r.issues.map((i) => i.message).join('\n'), contains('A media rule changes'));
      final s = parseNotation('Column\n  Column phone.flavor', catalog: standardCatalog);
      expect(s.issues, isNotEmpty);
    });

    test('motion, a field of the node', () {
      _word('Column#a phone.motion={"x":10}', [
        {'maxWidth': 699, 'patch': {'motion': {'x': 10}}},
      ]);
    }, skip: 'needs the keys family (design 22 section 2.1): motion= is read as a prop today');

    test('a layout field by its own name', () {
      _word('Text#t "x" max899.constraints.minHeight=0', [
        {'maxWidth': 899, 'patch': {'layout': {'constraints': {'minHeight': 0}}}},
      ]);
    }, skip: 'needs the keys family (design 22 section 2.1): a layout field by its name');
  });

  group('rules from the corpus print in words', () {
    test('CodelesslySDK showcase pages: a blog, a settings page, a docs site', () {
      _corpus({
        // site_blog round1
        'navLinks': {'type': 'row', 'layout': {'width': {'hug': 360}, 'height': {'hug': 20}}, 'props': {'spacing': 28}, 'media': [{'maxWidth': 900, 'patch': {'visible': false}}]},
        'bodyRail': {
          'type': 'flex',
          'layout': {'width': {'fill': 1152}, 'height': {'hug': 2000}, 'constraints': {'maxWidth': 1152}},
          'props': {'direction': 'horizontal', 'mainAxisAlignment': 'spaceBetween', 'crossAxisAlignment': 'stretch', 'spacing': 64},
          'media': [{'maxWidth': 900, 'patch': {'props': {'direction': 'vertical', 'spacing': 48}}}],
        },
        'coverArt': {'type': 'box', 'layout': {'width': {'fill': 1152}, 'height': 440}, 'media': [{'maxWidth': 900, 'patch': {'layout': {'height': 280}}}]},
        'title': {
          'type': 'text',
          'layout': {'width': {'fill': 920}, 'height': {'hug': 120}, 'constraints': {'maxWidth': 920}},
          'props': {'text': 'What we learned moving 40 services to one queue', 'style': {'fontFamily': 'Inter Display', 'fontSize': 52, 'fontWeight': 700, 'height': 1.08, 'letterSpacing': -1.04, 'color': '#FF0F172A'}},
          'media': [{'maxWidth': 900, 'patch': {'props': {'style': {'fontSize': 40, 'letterSpacing': -0.8}}}}],
        },
        // app_settings round1
        'grpProfile': {
          'type': 'flex',
          'layout': {'width': {'fill': 936}, 'height': {'hug': 600}},
          'props': {'direction': 'horizontal', 'spacing': 32, 'crossAxisAlignment': 'start'},
          'media': [{'maxWidth': 1023, 'patch': {'props': {'direction': 'vertical', 'spacing': 16, 'crossAxisAlignment': 'stretch'}}}],
        },
        // site_docs round2 and round1
        'sidebar': {
          'type': 'column',
          'layout': {'width': 256, 'height': {'fill': 736}},
          'props': {'crossAxisAlignment': 'stretch'},
          'decoration': {'fills': [{'color': '#FFFFFFFF'}], 'strokes': [{'color': '#FFE5E7EB'}], 'strokeSides': 'right'},
          'media': [{'maxWidth': 899, 'patch': {'bind': {'visible': r'${menuOpen}'}}}],
        },
        'sidebar1': {
          'type': 'column',
          'layout': {'width': 256, 'height': {'fill': 736}, 'padding': [16, 24, 16, 24]},
          'props': {'scrollable': true, 'crossAxisAlignment': 'stretch'},
          'media': [{'maxWidth': 899, 'patch': {'visible': false, 'bind': {'visible': r'${menuOpen}'}}}],
        },
      });
    });

    test('the reference\'s responsive_web example: breakpoints by name, two rules on a line', () {
      _corpus({
        'header': {
          'type': 'row',
          'layout': {'width': {'fill': 1440}, 'height': 64, 'padding': [16, 0, 16, 0]},
          'props': {'mainAxisAlignment': 'spaceBetween'},
          'decoration': {'fills': [{'color': '#FF111827'}]},
          'media': [{'minWidth': 'desktop', 'patch': {'layout': {'padding': [32, 0, 32, 0]}}}],
        },
        'nav': {'type': 'row', 'visible': false, 'layout': {'width': {'hug': 300}, 'height': {'hug': 20}}, 'props': {'spacing': 32}, 'media': [{'minWidth': 'desktop', 'patch': {'visible': true}}]},
        'content': {
          'type': 'column',
          'layout': {'width': {'fill': 1440}, 'height': {'hug': 800}, 'padding': [16, 24, 16, 24], 'constraints': {'maxWidth': 1200}},
          'props': {'crossAxisAlignment': 'stretch', 'spacing': 24},
          'media': [{'minWidth': 'tablet', 'patch': {'layout': {'padding': [32, 48, 32, 48]}, 'props': {'spacing': 32}}}],
        },
        'title': {
          'type': 'text',
          'layout': {'width': {'fill': 1136}, 'height': {'hug': 64}},
          'props': {'text': 'Plans that scale with your team', 'style': {'fontSize': 32, 'fontWeight': 700, 'height': 1.1, 'color': '#FF111827'}},
          'media': [
            {'minWidth': 'tablet', 'patch': {'props': {'style': {'fontSize': 40}}}},
            {'minWidth': 'desktop', 'patch': {'props': {'style': {'fontSize': 56}}}},
          ],
        },
      }, width: 1440);
    });

    test('a fixed value over a bound one (Cards NumberInput)', () {
      _corpus({
        'up': {
          'type': 'row',
          'props': {'crossAxisAlignment': 'center', 'mainAxisAlignment': 'center'},
          'layout': {'width': 15, 'height': 9},
          'bind': {'layout.width': r'${= props.size == "small" ? 14 : 15}', 'layout.height': r'${= props.size == "small" ? 9 : 11}'},
          'media': [
            {'maxWidth': 699, 'patch': {'layout': {'width': 44, 'height': 44}, 'bind': {'layout.width': null, 'layout.height': null}}},
          ],
        },
      });
    }, skip: 'needs the fields family: the line\'s bindings printed in words (a binding in the {…} tail is not there when print.dart reads the words alone)');
  });

  group('reflow', () {
    test('a page the reflow laid out prints its rules; read with the reflow on, it keeps them, once', () {
      final page = parseNotation('''
Section
  Text "A title for a large page" size=48
  Row gap=24
    Card
      Text "One"
    Card
      Text "Two"
''', catalog: standardCatalog, options: const NotationOptions(width: 1280));
      final doc = page.document;
      expect(notationOptionsFor(doc).reflow, isFalse, reason: 'the print is read back as written');
      final text = printNotation(doc, catalog: standardCatalog);
      expect(text, isNot(contains('"media"')), reason: text);
      // Read with the reflow on, each line keeps the rules it says, once;
      // the reflow adds before them what it makes of the lines as printed.
      final back = parseNotation(text, catalog: standardCatalog, options: NotationOptions(screen: notationOptionsFor(doc).screen, width: 1280));
      for (final e in (doc['nodes'] as Map).entries) {
        final own = ((e.value as Map)['media'] as List?) ?? const [];
        final got = (_nodeOf(back.document, '${e.key}')['media'] as List?) ?? const [];
        expect(jsonEncode(got.sublist(got.length - own.length)), jsonEncode(own), reason: '${e.key}');
        for (final r in own) {
          expect(got.where((g) => jsonEncode(g) == jsonEncode(r)), hasLength(1), reason: '${e.key}');
        }
      }
    });

    test('a rule the reflow makes that the line already says is not added twice', () {
      const line = 'Text#t "Big" size=48 tablet.size=41 phone.size=35';
      final on = parseNotation('Column\n  $line', catalog: standardCatalog, options: const NotationOptions(width: 1280));
      final off = parseNotation('Column\n  $line', catalog: standardCatalog, options: const NotationOptions(width: 1280, reflow: false));
      expect(jsonEncode(_nodeOf(on.document, 't')['media']), jsonEncode(_nodeOf(off.document, 't')['media']));
      expect((_nodeOf(on.document, 't')['media'] as List).length, 2);
    });
  });
}
