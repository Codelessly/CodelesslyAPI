// The streaming decoder: ops out of a tool input's text deltas as soon as
// each is complete, the same ops whatever the chunking, nodes of a bulk set
// one by one, and a truncated stream keeping what completed.
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

List<String> _decodeAll(Iterable<String> deltas, {bool partialSets = true}) {
  final d = OpStreamDecoder(partialSets: partialSets);
  final out = <String>[];
  for (final c in deltas) {
    for (final o in d.add(c)) {
      out.add('${o.index}${o.partial ? 'p' : ''}:${jsonEncode(o.op.toJson())}');
    }
  }
  d.close();
  return out;
}

void main() {
  final page = LayoutDocument.fromJson(jsonDecode(File('test/fixtures/edit/saas_pricing.json').readAsStringSync()), catalog: standardCatalog);
  final ops = opsFromDocument(page);
  final text = toolInputText(ops);

  test('every op is yielded as soon as its closing brace arrives', () {
    final d = OpStreamDecoder();
    var yielded = 0;
    // One character at a time: op i appears exactly when its text is complete.
    final first = jsonEncode(ops.first.toJson());
    final end = text.indexOf(first) + first.length;
    for (var i = 0; i < text.length; i++) {
      final got = d.add(text[i]);
      if (i == end - 1) expect(got, hasLength(1));
      if (i < end - 1) expect(got, isEmpty);
      yielded += got.length;
    }
    final close = d.close();
    expect(yielded, ops.length);
    expect(close.complete, isTrue);
    expect(close.truncated, isNull);
    expect(close.diagnostics, isEmpty);
    expect(close.opCount, ops.length);
  });

  test('any chunking of the same text yields the same op sequence', () {
    final whole = _decodeAll([text]);
    expect(whole.length, ops.length);
    expect(whole, [for (var i = 0; i < ops.length; i++) '$i:${jsonEncode(ops[i].toJson())}']);
    final rnd = Random(7);
    for (var run = 0; run < 40; run++) {
      expect(_decodeAll(_chunks(text, rnd, max: 1 + run * 3)), whole, reason: 'run $run');
    }
  });

  test('pretty-printed, keys in any order, escapes and unicode, text before the JSON', () {
    final input = const JsonEncoder.withIndent('  ').convert({
      'baseRev': 4,
      'ops': [
        {'id': 'q', 'node': {'type': 'text', 'props': {'text': 'Say "hi" \\ {not a brace} é \u{1F600}'}}, 'op': 'set'},
        {'op': 'patch', 'patch': {'opacity': 0.5}, 'id': 'q'},
      ],
      'atomic': true,
    });
    final rnd = Random(3);
    for (var run = 0; run < 30; run++) {
      final d = OpStreamDecoder();
      final got = [for (final c in ['Sure, here it is: ', ..._chunks(input, rnd, max: 5)]) ...d.add(c)];
      final end = d.close();
      expect([for (final o in got) o.op.toJson()], [
        {'op': 'set', 'id': 'q', 'node': {'type': 'text', 'props': {'text': 'Say "hi" \\ {not a brace} é \u{1F600}'}}},
        {'op': 'patch', 'id': 'q', 'patch': {'opacity': 0.5}},
      ]);
      expect(end.baseRev, 4);
      expect(end.atomic, isTrue);
    }
  });

  test('a set with nodes yields each node as it completes, then nothing twice', () {
    final input = jsonEncode({
      'ops': [
        {
          'op': 'set',
          'nodes': {
            'a': {'type': 'text', 'props': {'text': 'A'}},
            'b': {'type': 'text', 'props': {'text': 'B'}},
            'c': {'type': 'text', 'props': {'text': 'C'}},
          },
        },
        {'op': 'remove', 'ids': ['a']},
      ],
    });
    final d = OpStreamDecoder();
    final afterB = input.indexOf('"c"');
    final first = d.add(input.substring(0, afterB));
    expect([for (final o in first) '${(o.op as SetOp).id}${o.partial}'], ['atrue', 'btrue']);
    final rest = d.add(input.substring(afterB));
    expect([for (final o in rest) o.op.op], ['set', 'remove']);
    expect(rest.first.partial, isTrue);
    expect((rest.first.op as SetOp).id, 'c');
    // The op key after the nodes: they wait for it.
    final late = jsonEncode({
      'ops': [
        {
          'nodes': {'x': {'type': 'box'}},
          'op': 'set',
        },
      ],
    });
    expect(_decodeAll([late]), ['0p:{"op":"set","id":"x","node":{"type":"box"}}']);
    expect(_decodeAll([late], partialSets: false), ['0:{"op":"set","id":"x","node":{"type":"box"}}']);
  });

  test('a stream cut mid-op keeps every complete op and reports the tail', () {
    final rnd = Random(11);
    for (var run = 0; run < 25; run++) {
      final cut = 1 + rnd.nextInt(text.length - 2);
      final d = OpStreamDecoder();
      final got = [for (final c in _chunks(text.substring(0, cut), rnd)) ...d.add(c)];
      final end = d.close();
      // Exactly the ops whose text is complete before the cut.
      var complete = 0;
      var at = text.indexOf('[') + 1;
      for (final op in ops) {
        final s = jsonEncode(op.toJson());
        final i = text.indexOf(s, at);
        if (i + s.length <= cut) complete++;
        at = i + s.length;
      }
      expect(got.length, complete, reason: 'cut at $cut');
      expect(end.complete, isFalse);
      if (end.truncated != null) {
        expect(end.diagnostics.single.code, 'truncated_op');
        expect(end.diagnostics.single.op, complete);
      }
    }
  });

  test('an op that is not JSON, or not an op, is reported; the stream goes on', () {
    final d = OpStreamDecoder();
    final got = d.add('{"ops":[{"op":"nope"},{"op":"remove","ids":["a"]}, 7, {"op":"remove","ids":["b"]}]}');
    final end = d.close();
    expect([for (final o in got) o.index], [1, 3]);
    expect({for (final x in end.diagnostics) (x.op, x.code)}, {(0, 'invalid_op'), (2, 'invalid_op')});
    expect(OpStreamDecoder().close().diagnostics.single.code, 'missing_field');
  });

  test('decodeOpStream over a Stream', () async {
    final got = await decodeOpStream(Stream.fromIterable(_chunks(text, Random(1)))).toList();
    expect(got.length, ops.length);
  });

  test('applying the streamed ops one by one builds the page', () {
    final d = OpStreamDecoder();
    var doc = LayoutDocument(catalog: standardCatalog);
    for (final c in _chunks(text, Random(5), max: 40)) {
      for (final o in d.add(c)) {
        final r = applyOps(doc, [o.op], catalog: standardCatalog, incomplete: true);
        expect(r.errors, isEmpty);
        doc = r.document;
      }
    }
    expect(endOfStream(doc), isEmpty);
    expect(doc.nodes.length, page.nodes.length);
  });
}
