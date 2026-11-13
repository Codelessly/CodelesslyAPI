// The streaming decoder on input that is not well-formed JSON, as real
// models send it with eager tool input streaming: a stray closing brace, an
// `ops` array closed early, trailing commas, an op begun before the previous
// one closed, a stream cut mid-op. Property tests: any chunking yields the
// same ops; one inserted or deleted brace, bracket or comma loses at most the
// op it lands in; the three recorded live generations decode whole.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

List<String> _chunks(String text, Random rnd, {int max = 12}) {
  final out = <String>[];
  var i = 0;
  while (i < text.length) {
    final n = 1 + rnd.nextInt(max);
    out.add(text.substring(i, min(text.length, i + n)));
    i += n;
  }
  return out;
}

/// The ops [deltas] decode to, as JSON text (partial nodes as their set).
(List<String>, OpStreamEnd) _decode(Iterable<String> deltas) {
  final d = OpStreamDecoder();
  final out = <String>[];
  for (final c in deltas) {
    for (final o in d.add(c)) {
      out.add(jsonEncode(o.op.toJson()));
    }
  }
  return (out, d.close());
}

String _live(String name) => File('test/fixtures/edit/live/$name.txt').readAsStringSync();

/// A valid tool input and, for each op its text spans, the ops it yields.
class _Corpus {
  _Corpus(this.name, this.text, this.spans);
  final String name;
  final String text;

  /// Per input op: [start, end) in [text] and the yielded ops' JSON.
  final List<(int, int, List<String>)> spans;

  static _Corpus of(String name, String text) {
    // The spans of the input's ops: the elements of its "ops" list.
    final spans = <(int, int, List<String>)>[];
    final listStart = text.indexOf('[');
    var depth = 0, start = -1;
    var inString = false, escape = false;
    for (var i = listStart + 1; i < text.length; i++) {
      final c = text[i];
      if (inString) {
        if (escape) {
          escape = false;
        } else if (c == '\\') {
          escape = true;
        } else if (c == '"') {
          inString = false;
        }
        continue;
      }
      if (c == '"') {
        inString = true;
      } else if (c == '{' || c == '[') {
        if (depth == 0) start = i;
        depth++;
      } else if (c == '}' || c == ']') {
        if (depth == 0) break;
        depth--;
        if (depth == 0) {
          final ops = decodeOps([jsonDecode(text.substring(start, i + 1))]).ops;
          spans.add((start, i + 1, [for (final (_, op) in ops) jsonEncode(op.toJson())]));
        }
      }
    }
    return _Corpus(name, text, spans);
  }

  List<String> get ops => [for (final s in spans) ...s.$3];
}

void main() {
  final page = LayoutDocument.fromJson(jsonDecode(File('test/fixtures/edit/saas_pricing.json').readAsStringSync()), catalog: standardCatalog);
  final menu = LayoutDocument.fromJson(jsonDecode(File('test/fixtures/edit/restaurant_menu.json').readAsStringSync()), catalog: standardCatalog);
  final pageOps = opsFromDocument(page);

  // Valid inputs: compact, pretty-printed, a bulk set, and the two live
  // generations that were well formed.
  final bulk = jsonEncode({
    'ops': [
      pageOps[0].toJson(),
      {
        'op': 'set',
        'nodes': {
          for (final o in pageOps.skip(1).take(12))
            if (o is SetOp && o.parent == null) o.id: o.node,
        },
      },
      for (final o in pageOps.skip(13).take(20)) o.toJson(),
    ],
  });
  final corpus = [
    _Corpus.of('saas_pricing', toolInputText(pageOps.take(60).toList())),
    _Corpus.of('restaurant_menu pretty', const JsonEncoder.withIndent(' ').convert({'ops': [for (final o in opsFromDocument(menu).take(40)) o.toJson()]})),
    _Corpus.of('bulk set', bulk),
    _Corpus.of('weather@haiku (live)', _live('weather@claude-haiku-5-5')),
    _Corpus.of('flights@sonnet (live)', _live('flights@claude-sonnet-5-5')),
  ];

  test('the corpus decodes exactly as written', () {
    for (final c in corpus) {
      final (ops, end) = _decode([c.text]);
      expect(ops, c.ops, reason: c.name);
      expect(end.repairs, 0, reason: c.name);
      expect(end.complete, isTrue, reason: c.name);
    }
  });

  group('the recorded live generations decode to their full op lists', () {
    test('flights@claude-haiku-5-5: one closing brace too many, three times', () {
      final text = _live('flights@claude-haiku-5-5');
      // The model's text is not valid JSON.
      expect(() => jsonDecode(text), throwsFormatException);
      final (ops, end) = _decode([text]);
      expect(ops, hasLength(24));
      final ids = [for (final o in ops) jsonDecode(o)['id']];
      expect(ids.last, 'confirmTxt');
      expect(ids, containsAll(['opt1', 'opt2', 'foot', 'totalTxt', 'confirm']));
      // The bind it wrote after closing the node early is moved back in.
      final opt0 = jsonDecode(ops.firstWhere((o) => jsonDecode(o)['id'] == 'opt0'));
      expect(opt0['node']['bind'], isNotNull);
      final malformed = [for (final d in end.diagnostics) if (d.code == 'malformed_input') d];
      expect(malformed, hasLength(3));
      expect(malformed.first.message, contains('character 1477'));
      expect(malformed.every((d) => !d.error), isTrue);
      expect(end.repairs, 3);
      expect(end.recovered, 18);
      expect([for (final d in end.diagnostics) if (d.error) d], isEmpty);
    });
    test('weather@claude-haiku-5-5 and flights@claude-sonnet-5-5: well formed', () {
      expect(_decode([_live('weather@claude-haiku-5-5')]).$1, hasLength(50));
      expect(_decode([_live('flights@claude-sonnet-5-5')]).$1, hasLength(34));
    });
  });

  test('property: any chunking of any input (valid, malformed or live) yields the same ops and diagnostics', () {
    final rnd = Random(21);
    final inputs = [
      for (final c in corpus) c.text,
      _live('flights@claude-haiku-5-5'),
      // Mutated ones.
      for (var i = 0; i < 30; i++) _mutate(corpus[i % corpus.length].text, rnd).$1,
    ];
    for (final text in inputs) {
      final (whole, end) = _decode([text]);
      final diags = [for (final d in end.diagnostics) '$d'];
      for (var run = 0; run < 12; run++) {
        final (ops, e) = _decode(_chunks(text, rnd, max: 1 + run * 5));
        expect(ops, whole);
        expect([for (final d in e.diagnostics) '$d'], diags);
      }
    }
  });

  test('property: one inserted or deleted brace, bracket or comma loses at most the op it lands in', () {
    final rnd = Random(1477);
    var runs = 0, intact = 0, altered = 0, lost = 0, between = 0, repaired = 0;
    for (final c in corpus) {
      for (var run = 0; run < 400; run++) {
        final (text, at) = _mutate(c.text, rnd);
        final (ops, end) = _decode([text]);
        if (end.repairs > 0) repaired++;
        // The op the change is in (none: between ops).
        final landed = [for (final s in c.spans) if (at >= s.$1 && at < s.$2) s].firstOrNull;
        final expected = [
          for (final s in c.spans)
            if (!identical(s, landed)) ...s.$3,
        ];
        // Every other op, in order.
        var j = 0;
        for (final o in ops) {
          if (j < expected.length && o == expected[j]) j++;
        }
        expect(j, expected.length,
            reason: '${c.name}: change at $at (${landed == null ? 'between ops' : 'in the op at ${landed.$1}'}): '
                'lost ${expected[min(j, expected.length - 1)].substring(0, 80)}\n${text.substring(max(0, at - 60), min(text.length, at + 60))}');
        if (landed == null) {
          between++;
        } else if (landed.$3.every(ops.contains)) {
          intact++;
        } else {
          final ids = {for (final o in ops) (jsonDecode(o) as Map)['id']};
          if (landed.$3.every((o) => ids.contains((jsonDecode(o) as Map)['id']))) {
            altered++;
          } else {
            lost++;
          }
        }
        runs++;
      }
    }
    // ignore: avoid_print
    print('$runs single-character changes ($repaired needed a repair): no other op lost; the op it landed in: $intact intact, '
        '$altered read with a changed value, $lost lost; $between between ops (nothing lost)');
  });

  test('a prematurely closed ops array, trailing commas, text around, a missing comma', () {
    const input = 'Here is the UI:\n{"ops": [{"op":"roots","roots":["home",]},], {"op":"set","id":"home","node":{"type":"canvas",}}'
        '{"op":"remove","ids":["x"]}], "baseRev": 3}\nDone.';
    final (ops, end) = _decode([input]);
    expect(ops, [
      '{"op":"roots","roots":["home"]}',
      '{"op":"set","id":"home","node":{"type":"canvas"}}',
      '{"op":"remove","ids":["x"]}',
    ]);
    expect(end.repairs, greaterThanOrEqualTo(3));
    expect(end.diagnostics.where((d) => d.code == 'malformed_input').every((d) => d.message.contains('character')), isTrue);
  });

  test('an op begun before the previous one closed: both are read', () {
    const input = '{"ops":[{"op":"set","id":"a","node":{"type":"text","props":{"text":"A"}},'
        '{"op":"set","id":"b","node":{"type":"text","props":{"text":"B"}}}]}';
    final (ops, end) = _decode([input]);
    expect(ops, [
      '{"op":"set","id":"a","node":{"type":"text","props":{"text":"A"}}}',
      '{"op":"set","id":"b","node":{"type":"text","props":{"text":"B"}}}',
    ]);
    expect(end.diagnostics.single.code, 'malformed_input');
    // An action's "op" is not an op.
    const action = '{"ops":[{"op":"set","id":"a","node":{"type":"box","actions":[{"trigger":{"type":"click"},'
        '"actions":[{"op":"set","variable":"x","value":"1","type":"setVariable"}]}]}}]}';
    expect(_decode([action]).$1, hasLength(1));
    expect(_decode([action]).$2.repairs, 0);
  });

  test('an op split across set.nodes, cut mid-op: the nodes that arrived are kept, the tail reported', () {
    const input = '{"ops":[{"op":"set","nodes":{"a":{"type":"box"},"b":{"type":"box"},"c":{"type":"te';
    final (ops, end) = _decode(_chunks(input, Random(2), max: 3));
    expect(ops, ['{"op":"set","id":"a","node":{"type":"box"}}', '{"op":"set","id":"b","node":{"type":"box"}}']);
    expect(end.diagnostics.single.code, 'truncated_op');
    expect(end.truncated, startsWith('{"op":"set","nodes"'));
    expect(end.complete, isFalse);
  });

  test('an op outside any list, a typeless set, nested ops in a wrapper of another name', () {
    final (ops, _) = _decode(['{"operations":[{"op":"roots","roots":["c"]},{"id":"c","node":{"type":"canvas"}}]}']);
    expect(ops, ['{"op":"roots","roots":["c"]}', '{"op":"set","id":"c","node":{"type":"canvas"}}']);
  });

  test('each irregularity is reported once; many are summarised', () {
    final text = '{"ops":[${List.filled(30, '{"op":"remove","ids":["x"]}}').join(',')}]}';
    final (ops, end) = _decode([text]);
    expect(ops, hasLength(30));
    expect(end.repairs, 30);
    expect(end.diagnostics.where((d) => d.code == 'malformed_input'), hasLength(21));
  });
}

const _marks = ['{', '}', '[', ']', ','];

/// [text] with one brace, bracket or comma inserted at, or deleted from, a
/// random position (outside strings for deletions, anywhere for
/// insertions); and that position.
(String, int) _mutate(String text, Random rnd) {
  if (rnd.nextBool()) {
    final at = rnd.nextInt(text.length);
    return ('${text.substring(0, at)}${_marks[rnd.nextInt(_marks.length)]}${text.substring(at)}', at);
  }
  final structural = <int>[];
  var inString = false, escape = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (inString) {
      if (escape) {
        escape = false;
      } else if (c == '\\') {
        escape = true;
      } else if (c == '"') {
        inString = false;
      }
      continue;
    }
    if (c == '"') {
      inString = true;
    } else if (_marks.contains(c)) {
      structural.add(i);
    }
  }
  final at = structural[rnd.nextInt(structural.length)];
  return ('${text.substring(0, at)}${text.substring(at + 1)}', at);
}
