import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('stroke progress defaults to full and round trips with clamping', () {
    expect(StrokePath.fromJson({})!.progress, 1);
    expect(StrokePath.fromJson({'progress': -2})!.progress, 0);
    expect(StrokePath.fromJson({'progress': 2})!.progress, 1);
    final path = StrokePath.fromJson({
      'points': [
        [0, 0],
        [1, 1],
      ],
      'progress': .35,
    })!;
    expect(StrokePath.fromJson(path.toJson()), path);
  });
  test(
    'bound progress updates the typed stroke without changing its points',
    () {
      final n = Node.fromJson({
        'id': 'line',
        'type': 'box',
        'strokePath': {
          'points': [
            [0, 0],
            [1, 1],
          ],
        },
      })!;
      final next = BindPaths.apply(n, 'strokePath.progress', .4);
      expect(next.behaviors.strokePath!.progress, .4);
      expect(
        next.behaviors.strokePath!.points,
        n.behaviors.strokePath!.points,
      );
    },
  );
}
