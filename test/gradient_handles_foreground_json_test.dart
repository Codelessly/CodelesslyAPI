import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a linear gradient keeps its begin and end handles', () {
    final PaintModel paint = PaintModel.fromJson({
      'type': 'gradientLinear',
      'gradientStops': [
        {
          'color': {'r': 1, 'g': 0, 'b': 0, 'a': 1},
          'position': 0,
        },
        {
          'color': {'r': 0, 'g': 0, 'b': 1, 'a': 1},
          'position': 1,
        },
      ],
      'gradientBeginX': -1,
      'gradientBeginY': -1,
      'gradientEndX': 1,
      'gradientEndY': 1,
    });
    expect(paint.hasGradientHandles, isTrue);
    expect(paint.gradientBeginX, -1);
    expect(paint.gradientEndY, 1);
    final Map json = paint.toJson();
    expect(json['gradientBeginX'], -1);
    expect(json['gradientEndX'], 1);
    final PaintModel back = PaintModel.fromJson(json);
    expect(back, paint);
    expect(back.sanitize().gradientBeginY, -1);
    expect(
      back.copyWith(clearGradientGeometry: true).hasGradientHandles,
      isFalse,
    );
  });

  test('a gradient without handles writes none', () {
    final PaintModel paint = PaintModel.linearGradient(id: 'g');
    expect(paint.hasGradientHandles, isFalse);
    expect(
      paint.toJson().keys.where((k) => '$k'.contains('gradientBegin')),
      isEmpty,
    );
  });

  test('frames, rows and rectangles keep foreground fills', () {
    for (final Map<String, dynamic> json in [
      FrameNode(
        id: 'f',
        name: 'f',
        basicBoxLocal: NodeBox(0, 0, 10, 10),
        children: [],
      ).toJson().cast<String, dynamic>(),
      RowColumnNode(
        id: 'r',
        name: 'r',
        basicBoxLocal: NodeBox(0, 0, 10, 10),
        rowColumnType: RowColumnType.row,
        children: [],
      ).toJson().cast<String, dynamic>(),
      RectangleNode(
        id: 'x',
        name: 'x',
        basicBoxLocal: NodeBox(0, 0, 10, 10),
      ).toJson().cast<String, dynamic>(),
    ]) {
      expect(json.containsKey('foregroundFills'), isFalse);
      final DefaultShapeNode node = NodeJsonConverter().fromJson({
        ...json,
        'foregroundFills': [
          {
            'id': 'dim',
            'type': 'solid',
            'color': {'r': 0, 'g': 0, 'b': 0},
            'opacity': 0.4,
          },
        ],
      }) as DefaultShapeNode;
      expect(node.foregroundFills.single.opacity, 0.4);
      final Map back = node.toJson();
      expect((back['foregroundFills'] as List).single['id'], 'dim');
    }
  });
}
