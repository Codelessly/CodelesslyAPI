import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('every combination of sides reads back, with its sides', () {
    for (final s in StrokeSides.values) {
      final d = Decoration.fromJson({'strokeSides': s.name, 'strokes': [{'color': '#FF000000'}]});
      expect(d.strokeSides, s);
      expect(Decoration.fromJson(d.toJson()).strokeSides, s);
    }
    expect(StrokeSides.bottomRight.sides, {'right', 'bottom'});
    expect(StrokeSides.noTop.sides, {'right', 'bottom', 'left'});
    expect({for (final s in StrokeSides.values) (s.sides.toList()..sort()).join(',')}.length, 16);
    expect(StrokeSides.none.sides, isEmpty, reason: 'a stroke bound or patched off: Flutter\'s Border()');
  });
}
