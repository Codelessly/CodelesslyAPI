// Top-level canvases go where the v1 editor puts them: by their left and
// top pins (no pins: 0, 0), the box only for a side that isn't pinned.
import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

Map<String, Object?> canvas(String id, List<num> box, [Map<String, Object?>? pins]) => {
      'id': id, 'type': 'canvas', 'name': id, 'parentID': 'rootNode', 'basicBoxLocal': box,
      'properties': {'bodyId': '$id-b'}, 'children': ['$id-b'],
      'edgePins': ?pins,
    };

Map<String, Object?> body(String id) =>
    {'id': '$id-b', 'name': 'b', 'parentID': id, 'type': 'frame', 'basicBoxLocal': [0, 0, 100, 100], 'children': <String>[]};

void main() {
  test('top-level canvases are placed by their pins', () {
    final v2 = migrateDocument({
      'rootNode': {'children': ['a', 'b', 'c', 'd']},
      // Pins and box agree.
      'a': canvas('a', [1600, 1200, 400, 300], {'left': 1600, 'top': 1200}),
      // A stale top pin: the v1 editor shows it at y 0.
      'b': canvas('b', [800, 2400, 400, 300], {'left': 800, 'top': 0}),
      // No pins: the v1 editor pins it at 0, 0.
      'c': canvas('c', [0, 3600, 400, 300]),
      // Only the right side pinned: the box's left and top pin.
      'd': canvas('d', [500, 700, 400, 300], {'right': 10, 'top': 700}),
      for (final id in ['a', 'b', 'c', 'd']) '$id-b': body(id),
    });
    Map layout(String id) => ((v2['nodes'] as Map)[id] as Map)['layout'] as Map? ?? {};
    expect(layout('a')['x'], {'start': 1600});
    expect(layout('a')['y'], {'start': 1200});
    expect(layout('b')['x'], {'start': 800});
    expect(layout('b').containsKey('y'), isFalse);
    expect(layout('c').containsKey('x'), isFalse);
    expect(layout('c').containsKey('y'), isFalse);
    expect(layout('d')['x'], {'start': 500});
    expect(layout('d')['y'], {'start': 700});
  });
}
