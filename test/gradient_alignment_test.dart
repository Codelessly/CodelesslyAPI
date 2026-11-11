import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// Where a box point (unit square) lands on the gradient's axis: u (0 at
/// the start, 1 at the end) and v (0.5 on the axis).
(double, double) _map(List<double> t, double bx, double by) =>
    (t[0] * bx + t[1] * by + t[2], t[3] * bx + t[4] * by + t[5]);

void main() {
  test('a linear gradient reads begin and end as Flutter does', () {
    final p = Paint.fromJson({
      'type': 'linear',
      'begin': 'topCenter',
      'end': [0, 1],
      'stops': [
        {'position': 0, 'color': '#FF000000'},
        {'position': 1, 'color': '#FFFFFFFF'},
      ],
    })!;
    final t = p.transform!;
    expect(_map(t, .5, 0), (0.0, .5));
    expect(_map(t, .5, 1), (1.0, .5));
    // Isolines are horizontal: the left and right edges at the top start it.
    expect(_map(t, 0, 0).$1, 0);
    expect(_map(t, 1, 0).$1, 0);
    // Stored as a transform: it reads back the same.
    expect(Paint.fromJson(p.toJson()), p);
  });

  test('diagonal and named alignments', () {
    final t = Paint.linearTransform(Alignment.topLeft, Alignment.bottomRight)!;
    expect(_map(t, 0, 0).$1, closeTo(0, 1e-9));
    expect(_map(t, 1, 1).$1, closeTo(1, 1e-9));
    expect(_map(t, .5, .5).$1, closeTo(.5, 1e-9));
    expect(Alignment.fromJson('bottomRight'), Alignment.bottomRight);
    expect(Alignment.fromJson('nowhere'), isNull);
    expect(Paint.linearTransform(null, null), isNull);
    expect(Paint.fromJson({'type': 'linear', 'stops': []})!.transform, isNull, reason: 'no begin/end: the default axis');
  });
}
