import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

// A gradient whose stops are bound to a palette map (`pal.bg`, `pal.bgAlt`)
// through its node's variables, `fill-<paint id>-stop-<index>`.

void main() {
  test('stop binding keys follow the paint binding key', () {
    expect(ColorStop.bindingKey('fill-g', 0), 'fill-g-stop-0');
    expect(ColorStop.bindingKey('stroke-paint-s', 2), 'stroke-paint-s-stop-2');
    expect(ColorStop.bindingKey('foreground-f', 1), 'foreground-f-stop-1');
  });

  test('a node with bound gradient stops round-trips through JSON', () {
    final Map<String, dynamic> json = {
      'id': 'bg',
      'name': 'Backdrop',
      'type': 'rectangle',
      'basicBoxLocal': [0, 0, 390, 844],
      'fills': [
        {
          'id': 'g',
          'type': 'gradientLinear',
          'gradientBeginX': 0,
          'gradientBeginY': -1,
          'gradientEndX': 0,
          'gradientEndY': 1,
          'gradientStops': [
            {
              'position': 0,
              'color': {'r': 0, 'g': 0, 'b': 0, 'a': 1},
            },
            {
              'position': 1,
              'color': {'r': 0, 'g': 0, 'b': 0, 'a': 1},
            },
          ],
        },
      ],
      'variables': {
        ColorStop.bindingKey('fill-g', 0): r'${pal.bg}',
        ColorStop.bindingKey('fill-g', 1): r'${= pal.bgAlt}',
      },
    };
    final RectangleNode node = RectangleNode.fromJson(json);
    expect(node.variables['fill-g-stop-0'], r'${pal.bg}');
    expect(node.variables['fill-g-stop-1'], r'${= pal.bgAlt}');
    expect(node.fills.single.gradientStops, hasLength(2));

    final RectangleNode back = RectangleNode.fromJson(node.toJson());
    expect(back.variables, node.variables);
    expect(back.fills, node.fills);
    expect(back.fills.single.id, 'g');
  });

  test('renaming a variable renames it in stop bindings', () {
    final RectangleNode node = RectangleNode.fromJson({
      'id': 'bg',
      'name': 'Backdrop',
      'type': 'rectangle',
      'basicBoxLocal': [0, 0, 10, 10],
      'variables': {'fill-g-stop-0': r'pal.bg'},
    });
    node.updateVariableName(oldName: 'pal', newName: 'palette');
    expect(node.variables['fill-g-stop-0'], 'palette.bg');
  });
}
