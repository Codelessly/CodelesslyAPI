// BindPaths.declaredDefault: the value a node has at a binding path when its
// JSON omits the field (encoders omit defaults), which an animation track
// with no `from` or `to` starts or ends at.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  final node = Node.fromJson({
    'type': 'box',
    'layout': <String, Object?>{},
    'customPaint': {
      'painter': [
        {'op': 'path', 'id': 'line', 'points': [[0, 0], [10, 10]], 'paint': '#FF000000'},
        {'op': 'circle', 'c': [5, 5], 'radius': 3},
      ],
    },
  }, id: 'n')!;

  test('a path op\'s trimEnd defaults to 1 and trimStart to 0, by op id or index', () {
    expect(BindPaths.declaredDefault(node, 'customPaint.painter.line.trimEnd'), 1);
    expect(BindPaths.declaredDefault(node, 'customPaint.painter[0].trimStart'), 0);
  });

  test('a field another op type does not have, or an op that is not there, has none', () {
    expect(BindPaths.declaredDefault(node, 'customPaint.painter[1].trimEnd'), isNull);
    expect(BindPaths.declaredDefault(node, 'customPaint.painter.missing.trimEnd'), isNull);
  });

  test('opacity, layout, decoration and widget props have their declared defaults', () {
    expect(BindPaths.declaredDefault(node, 'opacity'), 1);
    expect(BindPaths.declaredDefault(node, 'decoration.strokeWidth'), isNotNull);
    final slider = Node.fromJson({'type': 'slider', 'layout': <String, Object?>{}}, id: 's')!;
    expect(BindPaths.declaredDefault(slider, 'props.max'), 1);
    expect(BindPaths.declaredDefault(slider, 'props.nothing'), isNull);
  });
}
