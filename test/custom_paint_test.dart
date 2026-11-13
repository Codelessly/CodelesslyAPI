// `customPaint` (custom_paint.dart): every declared field of every draw op,
// of the paint and of the behavior round-trips a sample through the models'
// real JSON, as a literal and as an expression; decoding is total; encoding
// is sparse; the proposal's worked examples read and write back unchanged;
// binding paths reach ops by id.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

import 'document/declared_fields_test.dart' show sample;

/// A non-default JSON sample for [def] (an expression field: its literal's).
Object? _sample(PropDef<Object?> def) {
  final codec = def.codec;
  return switch (def.key) {
    'paint' => {'color': '#FF112233', 'style': 'stroke', 'strokeWidth': 2},
    'ops' => [
      {'op': 'circle', 'c': [1, 2], 'radius': 3},
    ],
    'points' => [
      [1, 2],
      null,
      [3, 4],
    ],
    'scale' => [2, 3],
    'transform' => [for (var i = 0; i < 16; i++) i == 0 || i == 5 || i == 10 || i == 15 ? 2 : 0],
    'clipRRect' => {'rect': [0, 0, 10, 20], 'radius': 4},
    'as' || 'indexAs' => 'row',
    'radius' when codec is ExprCodec && codec.inner is! DoubleCodec => 6,
    _ when codec is ExprCodec => sample(def.type, PropDef(def.key, codec.inner, (def.defaultValue as Expr?)?.value)),
    _ => sample(def.type, def),
  };
}

/// [json] decoded as an op and written back.
Json _opRoundTrip(Json json) => DrawOp.fromJson(json)!.toJson();

void main() {
  group('declared fields', () {
    test('every drawing operation field round-trips a value and a formula', () {
      for (final spec in DrawOpSpecs.all) {
        for (final f in [...DrawOpCommonFields.all, ...spec.fields]) {
          final s = _sample(f);
          final back = _opRoundTrip({'op': spec.op, f.key: s})[f.key];
          expect(f.decode(back), f.decode(s), reason: '${spec.op}.${f.key}: $s came back as $back');
          expect(f.decode(s), isNot(f.defaultValue), reason: '${spec.op}.${f.key}: the sample is the default');
          if (f.codec is ExprCodec) {
            const e = r'${= 1 + 1}';
            expect(_opRoundTrip({'op': spec.op, f.key: e})[f.key], e, reason: '${spec.op}.${f.key} as an expression');
          }
        }
      }
    });

    test('every key a drawing operation writes is declared', () {
      final samples = <String, Json>{
        for (final spec in DrawOpSpecs.all) spec.op: {'op': spec.op, for (final f in spec.fields) f.key: _sample(f)},
      };
      for (final spec in DrawOpSpecs.all) {
        final keys = _opRoundTrip({...samples[spec.op]!, 'id': 'a', 'when': r'${on}'}).keys.toSet();
        final declared = {'op', for (final f in [...DrawOpCommonFields.all, ...spec.fields]) f.key};
        expect(declared.containsAll(keys), isTrue, reason: '${spec.op}: ${keys.difference(declared)}');
      }
      expect({for (final s in DrawOpSpecs.all) s.op}, DrawOp.names.keys.toSet());
    });

    test('a drawing paint has Flutter Paint\'s fields, and they round-trip', () {
      for (final f in DrawPaintFields.all) {
        final s = f.key == 'shader'
            ? {'type': 'linear', 'stops': [{'position': 0, 'color': '#FFFF0000'}, {'position': 1, 'color': '#FF0000FF'}]}
            : _sample(f);
        final back = DrawPaint.fromJson({'style': 'stroke', f.key: s})!.toJson() as Json;
        expect(f.decode(back[f.key]), f.decode(s), reason: 'paint.${f.key}');
      }
      expect({for (final f in DrawPaintFields.all) f.key}, DrawPaint.keys);
      expect(DrawPaint.fromJson(const {}), const DrawPaint(), reason: 'Paint(): black, fill, hairline');
    });

    test('every custom paint field round-trips on a node', () {
      for (final f in CustomPaintFields.all) {
        final s = f.key == 'painter' || f.key == 'foregroundPainter'
            ? [
                {'op': 'rect', 'rect': [0, 0, 4, 4]},
              ]
            : (f.key == 'viewBox' ? [10, 20] : _sample(f));
        final n = Node.fromJson({'id': 'a', 'type': 'box', 'customPaint': {f.key: s}})!;
        expect((n.toJson()['customPaint'] as Map)[f.key], s, reason: 'customPaint.${f.key}');
      }
      expect({for (final f in CustomPaintFields.all) f.key}, CustomPaint.keys);
      expect(BehaviorFields.customPaint.type.name, 'CustomPaint');
      expect(BehaviorFields.customPaint.type.fields, CustomPaintFields.all);
    });
  });

  group('writing and reading', () {
    test('values left at their defaults are not written', () {
      expect(const CustomPaint().toJson(), isEmpty);
      expect(const CircleOp().toJson(), {'op': 'circle'});
      expect(const GroupOp().toJson(), {'op': 'group'});
      expect(const DrawPaint(color: Expr(Color.white)).toJson(), '#FFFFFFFF', reason: 'only a color: the color');
      expect(Node.fromJson({'id': 'a', 'type': 'box', 'customPaint': {}})!.toJson()['customPaint'], isEmpty);
      expect(Node.fromJson({'id': 'a', 'type': 'box'})!.behaviors.customPaint, isNull);
    });

    test('every drawing operation reads as Flutter would call the canvas and writes back unchanged', () {
      final ops = [
        {'op': 'path', 'd': 'M0 0 L10 10 Z', 'fillType': 'evenOdd', 'trimEnd': 0.5, 'paint': '#FF000000'},
        {'op': 'path', 'points': [[0, 0], [10, 5], null, [3, 3], [4, 4]], 'close': true, 'paint': {'style': 'stroke', 'strokeWidth': 2}},
        {'op': 'line', 'p1': [0, 0], 'p2': [10, r'${y}'], 'paint': {'style': 'stroke', 'strokeCap': 'round'}},
        {'op': 'rect', 'rect': [1, 2, 3, 4], 'paint': '#FFFF0000'},
        {'op': 'rrect', 'rect': [1, 2, 3, 4], 'radius': [2, 1], 'paint': '#FFFF0000'},
        {'op': 'circle', 'c': [5, 5], 'radius': 4, 'paint': ['#FF00FF00', {'style': 'stroke'}]},
        {'op': 'oval', 'rect': [0, 0, 8, 4], 'paint': '#FF0000FF'},
        {'op': 'arc', 'rect': [0, 0, 8, 8], 'startAngle': 1, 'sweepAngle': 3.1416, 'useCenter': true, 'paint': '#FF0000FF'},
        {'op': 'points', 'pointMode': 'polygon', 'points': [[0, 0], [1, 1]], 'paint': {'style': 'stroke', 'strokeWidth': 3}},
        {'op': 'paragraph', 'text': r'Hi ${name}', 'style': {'fontSize': 12}, 'offset': [4, 4], 'anchor': [0, 0], 'maxWidth': 40, 'textAlign': 'center', 'maxLines': 1},
        {'op': 'image', 'url': 'https://example.com/a.png', 'src': [0, 0, 10, 10], 'dst': [0, 0, 20, 20]},
        {
          'op': 'group', 'translate': [10, 10], 'scale': 2, 'rotate': 0.5, 'clipRect': [0, 0, 5, 5], 'clipPath': 'M0 0 L5 0 L0 5 Z',
          'clipRRect': {'rect': [0, 0, 5, 5], 'radius': 1}, 'opacity': 0.5, 'blendMode': 'multiply',
          'ops': [{'op': 'rect', 'rect': [0, 0, 1, 1], 'paint': '#FF000000'}],
        },
        {'op': 'repeat', 'each': r'${cells}', 'as': 'cell', 'indexAs': 'i', 'ops': [{'op': 'circle', 'c': [r'${i}', 0], 'radius': 1}]},
        {'op': 'repeat', 'count': 3, 'ops': [{'op': 'line', 'p1': [r'${index}', 0], 'p2': [r'${index}', 1]}]},
      ];
      final paint = CustomPaint.fromJson({'painter': ops, 'foregroundPainter': ops.take(2).toList(), 'viewBox': [100, 50]})!;
      expect(paint.painter.map((o) => o.runtimeType), [
        PathOp, PathOp, LineOp, RectOp, RRectOp, CircleOp, OvalOp, ArcOp, PointsOp, ParagraphOp, ImageOp, GroupOp, RepeatOp, RepeatOp,
      ]);
      expect(paint.toJson()['painter'], ops);
      expect(paint.viewBox, [0, 0, 100, 50]);
      expect(CustomPaint.fromJson(paint.toJson()), paint);
      expect(paint.allOps.length, ops.length + 2 + 3);
    });

    test('Flutter canvas method names read as the drawing operation', () {
      expect(DrawOp.fromJson({'op': 'drawCircle', 'center': [1, 2], 'radius': 3})!.toJson(), {'op': 'circle', 'c': [1, 2], 'radius': 3});
      expect(DrawOp.fromJson({'op': 'drawRRect'}), isA<RRectOp>());
      expect(DrawOp.fromJson({'op': 'drawImageRect'}), isA<ImageOp>());
      expect(DrawOp.fromJson({'op': 'text', 'text': 'a'}), isA<ParagraphOp>());
      expect(DrawOp.fromJson({'op': 'drawParagraph'}), isA<ParagraphOp>());
    });

    test('nested groups and repeats keep their tree', () {
      final json = {
        'op': 'repeat', 'each': r'${rows}', 'as': 'row', 'indexAs': 'r', 'ops': [
          {'op': 'repeat', 'each': r'${row.cells}', 'ops': [
            {'op': 'group', 'translate': [r'${index}', r'${r}'], 'ops': [
              {'op': 'group', 'rotate': r'${= radians(45)}', 'ops': [
                {'op': 'rect', 'id': 'cell', 'rect': [0, 0, 1, 1], 'paint': r'${item.color}', 'hit': r'cell-${r}-${index}'},
              ]},
            ]},
          ]},
        ],
      };
      final op = DrawOp.fromJson(json)! as RepeatOp;
      final inner = ((op.ops.single as RepeatOp).ops.single as GroupOp).ops.single as GroupOp;
      expect(inner.rotate, const Expr<double>.source(r'${= radians(45)}'));
      final rect = inner.ops.single as RectOp;
      expect(rect.paint.single.source, r'${item.color}');
      expect(rect.hit, r'cell-${r}-${index}');
      expect(op.toJson(), json);
    });
  });

  group('bad input', () {
    test('bad input never throws: bad operations are dropped, bad values defaulted and unknown keys kept', () {
      final paint = CustomPaint.fromJson({
        'painter': [
          'not an op',
          42,
          null,
          {'no': 'op'},
          {'op': 7},
          {'op': 'circle', 'c': 'nope', 'radius': 'big', 'paint': [3.5, '#zz', null, {'style': 'wiggly', 'strokeWidth': -2}]},
          {'op': 'rect', 'rect': [1, 2, 3], 'when': 'maybe'},
          {'op': 'group', 'ops': 'x', 'scale': [1, 2, 3], 'opacity': 7, 'translate': {'x': 1}},
          {'op': 'repeat', 'as': '1bad name', 'count': 'many', 'ops': [{'op': 'hologram', 'depth': 3}]},
          {'op': 'hologram', 'depth': 3},
          {'op': 'path', 'points': [[1, 2], 'x', [3], {'x': 4, 'y': 5}], 'future': true},
        ],
        'foregroundPainter': {'op': 'rect'},
        'viewBox': [0, 0, -1, 10],
        'fit': 'sideways',
        'isComplex': 'yes',
      })!;
      expect(paint.painter.length, 6);
      final circle = paint.painter[0] as CircleOp;
      expect(circle.c, isNull);
      expect(circle.radius, const Expr(0.0));
      expect(circle.paint.single.value, const DrawPaint(), reason: 'the readable paint, its bad values defaulted');
      final rect = paint.painter[1] as RectOp;
      expect(rect.rect, isNull);
      expect(rect.when, isNull);
      final g = paint.painter[2] as GroupOp;
      expect(g.ops, isEmpty);
      expect(g.scale, isNull);
      expect(g.translate, isNull);
      expect(g.opacity, const Expr(1.0));
      final r = paint.painter[3] as RepeatOp;
      expect(r.as, 'item');
      expect(r.count, isNull);
      expect(r.ops.single, isA<UnknownDrawOp>());
      expect(paint.painter[4].toJson(), {'op': 'hologram', 'depth': 3}, reason: 'an unknown op round-trips');
      final p = paint.painter[5] as PathOp;
      expect(p.points!.value!.length, 2);
      expect(p.toJson()['future'], true, reason: 'unknown keys are kept');
      expect(paint.foregroundPainter, isEmpty);
      expect(paint.viewBox, isNull);
      expect(paint.fit, BoxFit.fill);
      expect(paint.isComplex, isFalse);
      expect(CustomPaint.fromJson('nope'), isNull);
      expect(Node.fromJson({'id': 'a', 'type': 'box', 'customPaint': 'nope'})!.behaviors.customPaint, isNull);
    });

    test('points read from pairs, flat numbers or x and y maps', () {
      List<Object?> pts(Object json) => (DrawOp.fromJson({'op': 'points', 'points': json})! as PointsOp).toJson()['points'] as List<Object?>;
      expect(pts([0, 1, 2, 3]), [[0, 1], [2, 3]]);
      expect(pts([{'x': 1, 'y': 2}]), [[1, 2]]);
      expect(pts([[1, r'${y}']]), [[1, r'${y}']]);
      expect((DrawOp.fromJson({'op': 'points', 'points': r'${pts}'})! as PointsOp).points!.source, r'${pts}');
    });
  });

  group('the proposal\'s worked examples', () {
    final examples = <String, Json>{
      'dial ticks': {'viewBox': [200, 200], 'painter': [
        {'op': 'repeat', 'count': r'${numbers}', 'ops': [
          {'op': 'group', 'translate': [100, 100], 'rotate': r'${= index * 2 * pi / numbers}', 'ops': [
            {'op': 'line', 'p1': [0, -92.5], 'p2': [0, r'${= index % 5 == 0 ? -81.5 : -87.5}'],
             'paint': {'color': '#FFE8ECEE', 'style': 'stroke', 'strokeWidth': r'${= index % 5 == 0 ? 2 : 1}'}}]}]}]},
      'petri board': {'viewBox': [48, 48], 'willChange': true, 'painter': [
        {'op': 'rect', 'rect': [0, 0, 48, 48],
         'paint': {'shader': {'type': 'radial', 'stops': [{'position': 0.35, 'color': '#FFF3E7B8'}, {'position': 1, 'color': '#FFD9C27A'}]}}},
        {'op': 'repeat', 'each': r'${cells}', 'ops': [
          {'op': 'rect', 'when': r'${= item != 0}', 'rect': [r'${= index % 48}', r'${= floor(index / 48)}', 1, 1], 'paint': r'${pal[item]}'}]}]},
      'graph': {'painter': [
        {'op': 'group', 'clipRect': [0, 0, r'${size.width}', r'${size.height}'],
         'translate': [r'${= -m.xMin * size.width / (m.xMax - m.xMin)}', r'${= m.yMax * size.height / (m.yMax - m.yMin)}'],
         'scale': [r'${= size.width / (m.xMax - m.xMin)}', r'${= -size.height / (m.yMax - m.yMin)}'],
         'ops': [
           {'op': 'line', 'id': 'xAxis', 'p1': [r'${m.xMin}', 0], 'p2': [r'${m.xMax}', 0],
            'paint': {'color': '#FF1D2B2F', 'style': 'stroke', 'strokeWidth': 1.5, 'scaleStroke': false}},
           {'op': 'repeat', 'each': r'${m.series}', 'ops': [
             {'op': 'path', 'points': r'${item.points}', 'hit': r'${item.id}',
              'paint': {'color': r'${item.color}', 'style': 'stroke', 'strokeWidth': 2.2, 'strokeJoin': 'round', 'scaleStroke': false}}]}]},
        {'op': 'repeat', 'each': r'${m.grid.labels}', 'ops': [
          {'op': 'paragraph', 'text': r'${item.text}', 'offset': [r'${item.px}', r'${item.py}'], 'anchor': [0, -1],
           'style': {'fontFamily': 'JetBrains Mono', 'fontSize': 11, 'color': '#FF5B6B70'}}]}]},
      'comb': {'viewBox': [1000, 560], 'painter': [
        {'op': 'repeat', 'each': r'${combCells(g)}', 'ops': [
          {'op': 'group', 'translate': [r'${combX(item, g)}', r'${combY(item, g)}'], 'ops': [
            {'op': 'path', 'd': r'${g.hex}', 'paint': [r'${cellFill(item, frame)}', {'color': '#33FFFFFF', 'style': 'stroke', 'strokeWidth': 1}]}]}]}]},
    };
    for (final e in examples.entries) {
      test('${e.key} reads and writes back unchanged', () {
        final node = Node.fromJson({'id': 'n', 'type': 'box', 'customPaint': e.value})!;
        expect(node.behaviors.customPaint, isNotNull);
        expect(node.toJson()['customPaint'], e.value);
        expect(node.behaviors.customPaint!.allOps.whereType<UnknownDrawOp>(), isEmpty);
      });
    }
  });

  group('binding into a custom paint', () {
    final node = Node.fromJson({
      'id': 'n',
      'type': 'box',
      'customPaint': {
        'painter': [
          {'op': 'circle', 'id': 'dot', 'c': [5, 5], 'radius': 2, 'paint': {'id': 'ink', 'color': '#FF000000'}},
          {'op': 'group', 'id': 'g', 'ops': [
            {'op': 'rect', 'id': 'bar', 'rect': [0, 0, 1, 1]},
          ]},
        ],
      },
    })!;

    test('a binding can replace an operation by id, a field of it, or an operation inside a group', () {
      final a = BindPaths.apply(node, 'customPaint.painter.dot.radius', 9);
      expect((a.behaviors.customPaint!.painter.first as CircleOp).radius, const Expr(9.0));
      final b = BindPaths.apply(node, 'customPaint.painter.dot.paint.color', '#FFFF0000');
      expect((b.behaviors.customPaint!.painter.first as CircleOp).paint.single.value!.color, const Expr(Color(0xFFFF0000)));
      final c = BindPaths.apply(node, 'customPaint.painter.g.ops.bar.rect', [1, 2, 3, 4]);
      final bar = (c.behaviors.customPaint!.painter[1] as GroupOp).ops.single as RectOp;
      expect(bar.rect!.value!.map((e) => e.value), [1, 2, 3, 4]);
    });

    test('a binding can replace a whole list of operations or the whole custom paint', () {
      final a = BindPaths.apply(node, 'customPaint.painter', [
        {'op': 'oval', 'rect': [0, 0, 2, 2]},
      ]);
      expect(a.behaviors.customPaint!.painter.single, isA<OvalOp>());
      final b = BindPaths.apply(node, 'customPaint', {'viewBox': [10, 10]});
      expect(b.behaviors.customPaint, const CustomPaint(viewBox: [0, 0, 10, 10]));
      expect(BindPaths.apply(node, 'customPaint.painter.missing.radius', 3), node, reason: 'no such op: unchanged');
    });
  });

  test('the guide\'s JSON samples read and write back unchanged', () {
    final text = File('docs/guide/07-custom-paint.md').readAsStringSync();
    final blocks = RegExp(r'```json\n([\s\S]*?)```').allMatches(text).map((m) => m[1]!).toList();
    expect(blocks.length, greaterThanOrEqualTo(4));
    for (final b in blocks) {
      var json = jsonDecode(b) as Json;
      if (json['customPaint'] case final Json inner) json = inner;
      final paint = CustomPaint.fromJson(json)!;
      expect(paint.toJson(), json, reason: b);
      expect(paint.allOps.whereType<UnknownDrawOp>(), isEmpty, reason: b);
    }
    final spec = DrawOpSpecs.of('circle')!;
    expect(spec.flutter, 'Canvas.drawCircle');
    expect(spec.fields.first.key, 'c');
    expect(CircleOpFields.radius.codec, isA<ExprCodec>());
  });
}
