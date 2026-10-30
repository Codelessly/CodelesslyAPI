import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// The path of the first list held directly in a list in [value], or null.
/// Pages are saved in Firestore, which rejects nested arrays.
String? nestedArrayAt(Object? value, [String path = r'$']) {
  if (value is Map) {
    for (final entry in value.entries) {
      final found = nestedArrayAt(entry.value, '$path.${entry.key}');
      if (found != null) return found;
    }
  } else if (value is List) {
    for (var i = 0; i < value.length; i++) {
      if (value[i] is List) return '$path[$i]';
      final found = nestedArrayAt(value[i], '$path[$i]');
      if (found != null) return found;
    }
  }
  return null;
}

void main() {
  test('a node with every motion and drag feature stores without nested '
      'arrays', () {
    final node = FrameNode.fromJson({
      'id': 'f',
      'name': 'F',
      'type': 'frame',
      'basicBoxLocal': {'x': 0, 'y': 0, 'width': 80, 'height': 80},
      'draggable': {'group': 'letters', 'whileDragging': 'ghost'},
      'dropTarget': {
        'groups': ['letters'],
        'acceptIf': r'${= drop.data != null}',
      },
      'effectAnimations': [
        {'name': 'shake', 'type': 'shake'},
      ],
      'particles': {
        'count': 20,
        'shapes': ['star', 'strip'],
        'colors': ['#FFD23F', '#FF5D8F'],
      },
      'flightKey': 'tile',
      'strokePath': {
        'points': [
          [0.5, 0],
          [0.2, 120],
          [0.8, 240],
        ],
        'dash': [12, 18],
      },
      'reveal': {'alignment': 0.45},
    });
    final json = node.toJson();
    expect(nestedArrayAt(json), isNull);
    expect(json['strokePath']['points'], [
      {'x': 0.5, 'y': 0.0},
      {'x': 0.2, 'y': 120.0},
      {'x': 0.8, 'y': 240.0},
    ]);
    // Stored maps and the older [x, y] pairs read back the same.
    expect(FrameNode.fromJson(json).strokePath, node.strokePath);
    expect(node.strokePath!.points[1], [0.2, 120.0]);
  });

  test('nestedArrayAt finds nested lists', () {
    expect(
      nestedArrayAt({
        'a': [1, 2],
      }),
      isNull,
    );
    expect(
      nestedArrayAt({
        'a': [
          {
            'b': [
              [1],
            ],
          },
        ],
      }),
      r'$.a[0].b[0]',
    );
  });
}
