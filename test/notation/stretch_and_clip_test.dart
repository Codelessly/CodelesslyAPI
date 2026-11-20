// Images that stretch and shapes that clip (docs/design/26): an image's
// centerSlice (nine-slice), a decoration's clipPath in the box's unit square,
// a linear gradient's CSS angle and a drawn shape's blurRadius. Each decodes,
// round-trips, and is written and printed back in the notation.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text) => Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog));

String _printDoc(Json document) => Catalog.run(standardCatalog, () => printNotation(document, catalog: standardCatalog));

Json _node(Json document, String id) => ((document['nodes'] as Map)[id] as Map).cast<String, Object?>();

/// [line] under a Column: expanded with nothing said, printed back as the
/// same line, and the print read as the same document. Returns the node.
Json _roundTrip(String line, String id) {
  final r = _parse('Column\n  $line');
  expect(r.issues, isEmpty, reason: '${r.issues}');
  final printed = _printDoc(r.document);
  expect(const LineSplitter().convert(printed).map((l) => l.trim()), contains(line), reason: printed);
  final back = _parse(printed);
  expect(back.issues, isEmpty, reason: '${back.issues}');
  expect(jsonEquality.equals(back.document, r.document), isTrue, reason: printed);
  return _node(r.document, id);
}

void main() {
  group('an image paint with a centerSlice', () {
    test('reads, writes and compares the slice; a sliced paint keeps it beside the image', () {
      final i = ImagePaint.fromJson({'url': 'a.png', 'fit': 'fill', 'scale': 3, 'centerSlice': [14, 12, 28, 8]});
      expect(i.centerSlice, [14, 12, 28, 8]);
      expect(i.toJson()['centerSlice'], [14, 12, 28, 8]);
      expect(ImagePaint.fromJson(i.toJson()), i);
      expect(i == ImagePaint.fromJson({'url': 'a.png', 'fit': 'fill', 'scale': 3}), isFalse);
      // Beside the image, as fit and scale may be.
      final p = Paint.fromJson({'image': {'url': 'a.png'}, 'centerSlice': [1, 2, 3, 4]})!;
      expect(p.image!.centerSlice, [1, 2, 3, 4]);
      // Not a rectangle, or a negative side: none.
      expect(ImagePaint.fromJson({'centerSlice': [1, 2, 3]}).centerSlice, isNull);
      expect(ImagePaint.fromJson({'centerSlice': [1, 2, -3, 4]}).centerSlice, isNull);
      expect(ImagePaint.fromJson({'url': 'a.png'}).toJson().containsKey('centerSlice'), isFalse);
    });

    test('Image "…" scale= centerSlice= is a sliced fill, written back the same', () {
      final n = _roundTrip('Image#b "assets/bubble.png" scale=3 centerSlice=[14,12,28,8] w=120 h=70', 'b');
      expect(((n['decoration'] as Map)['fills'] as List).single, {
        'image': {'url': 'assets/bubble.png', 'fit': 'fill', 'scale': 3, 'centerSlice': [14, 12, 28, 8]},
      });
    });

    test('a sliced Image fills its box whatever fit says; a bad slice is said and left out', () {
      final r = _parse('Column\n  Image#b "a.png" fit=cover centerSlice=[1,1,1,1]');
      expect(r.issues, isEmpty);
      expect((((_node(r.document, 'b')['decoration'] as Map)['fills'] as List).single as Map)['image'], {
        'url': 'a.png',
        'fit': 'fill',
        'centerSlice': [1, 1, 1, 1],
      });
      final bad = _parse('Column\n  Image#b "a.png" centerSlice=[1,1,1] scale=0');
      expect(bad.issues.map((i) => i.message).join('\n'), allOf(contains('centerSlice'), contains('scale')));
      expect((((_node(bad.document, 'b')['decoration'] as Map)['fills'] as List).single as Map)['image'], {'url': 'a.png', 'fit': 'cover'});
    });

    test('Image "…" scale= alone keeps its fit', () {
      _roundTrip('Image#b "a.png" fit=contain scale=2 w=60 h=40', 'b');
    });
  });

  group('a decoration clipPath', () {
    test('reads, writes and compares; an empty path is none', () {
      final d = Decoration.fromJson({'clipPath': 'M0 0 H1 V0.8 Z'});
      expect(d.clipPath, 'M0 0 H1 V0.8 Z');
      expect(d.toJson(), {'clipPath': 'M0 0 H1 V0.8 Z'});
      expect(Decoration.fromJson(d.toJson()), d);
      expect(d == Decoration.none, isFalse);
      expect(Decoration.fromJson({'clipPath': '  '}).clipPath, isNull);
      expect(d.copyWith(radius: BorderRadius.circular(4)).clipPath, d.clipPath);
    });

    test('clipPath="…" on a line is the decoration\'s, written back the same', () {
      final n = _roundTrip('Column#h w=200 h=120 fill=#FF4F46E5 clipPath="M0 0 H1 V0.75 C0.75 1 0.25 0.55 0 0.85 Z"', 'h');
      expect((n['decoration'] as Map)['clipPath'], 'M0 0 H1 V0.75 C0.75 1 0.25 0.55 0 0.85 Z');
    });
  });

  group('a linear gradient angle', () {
    test('reads, writes and compares', () {
      final p = Paint.fromJson({'type': 'linear', 'angle': 103, 'stops': [
        {'position': 0, 'color': '#FF4F46E5'},
        {'position': 1, 'color': '#FF06B6D4'},
      ]})!;
      expect(p.angle, 103);
      expect(p.toJson()['angle'], 103);
      expect(Paint.fromJson(p.toJson()), p);

      expect(Paint.fromJson({'type': 'linear'})!.toJson().containsKey('angle'), isFalse);
    });

    test('kept in a written fill and in gradient={"colors":…,"angle":…}', () {
      final r = _parse('Column\n'
          '  Box#a w=100 h=40 fills=[{"type":"linear","angle":103,"colors":["#FF4F46E5","#FF06B6D4"]}]\n'
          '  Box#b w=100 h=40 gradient={"colors":["#FF4F46E5","#FF06B6D4"],"angle":103}\n');
      expect(r.issues, isEmpty);
      final nodes = r.document['nodes'] as Map;
      for (final id in ['a', 'b']) {
        final fill = (((nodes[id] as Map)['decoration'] as Map)['fills'] as List).single as Map;
        expect(fill['angle'], 103, reason: id);
        expect((fill['stops'] as List).length, 2, reason: id);
      }
    });
  });

  group('a drawn shape blurRadius', () {
    test('DrawPaint reads, writes and compares it; 0 and negative are sharp', () {
      final p = DrawPaint.fromJson({'color': '#80F59E0B', 'blurRadius': 18})!;
      expect(p.blurRadius, const Expr(18.0));
      expect(DrawPaint.fromJson(p.toJson()), p);
      expect(p == DrawPaint.fromJson('#80F59E0B'), isFalse);
      expect(DrawPaint.fromJson({'color': '#FF000000', 'blurRadius': -2})!.blurRadius, const Expr(0.0));
      expect(DrawPaint.fromJson({'color': '#FF000000', 'blurRadius': r'${glow}'})!.blurRadius.source, isNotNull);
    });

    test('blurRadius= beside fill= and stroke= softens each paint of the op, and is written once', () {
      final r = _parse('Column\n  box#n w=120 h=80\n    customPaint viewBox=[120,80]\n'
          '      circle c=[60,40] radius=20 fill=#80F59E0B blurRadius=18\n'
          '      rect rect=[10,10,100,60] fill=#FF111827 stroke=#FFF59E0B strokeWidth=2 blurRadius=4');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      final ops = ((_node(r.document, 'n')['customPaint'] as Map)['painter'] as List).cast<Map>();
      expect(ops[0]['paint'], {'color': '#80F59E0B', 'blurRadius': 18});
      expect(ops[1]['paint'], [
        {'color': '#FF111827', 'blurRadius': 4},
        {'color': '#FFF59E0B', 'style': 'stroke', 'strokeWidth': 2, 'blurRadius': 4},
      ]);
      final printed = _printDoc(r.document);
      expect(printed, contains('circle c=[60,40] radius=20 fill=#80F59E0B blurRadius=18'));
      expect(printed, contains('rect rect=[10,10,100,60] fill=#FF111827 stroke=#FFF59E0B strokeWidth=2 blurRadius=4'));
      final back = _parse(printed);
      expect(back.issues, isEmpty);
      expect(jsonEquality.equals(back.document, r.document), isTrue, reason: printed);
    });

    test('blurRadius= with no fill or stroke is said', () {
      final r = _parse('Column\n  box#n w=120 h=80\n    customPaint\n      circle c=[60,40] radius=20 blurRadius=18');
      expect(r.issues.map((i) => i.message).join(), contains('blurRadius goes with fill= or stroke='));
    });
  });
}
