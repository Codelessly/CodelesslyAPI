import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a number is the same circular radius on every corner', () {
    expect(CornerRadius.fromJson(8), CornerRadius.all(RadiusModel.circular(8)));
  });

  test('four numbers are tl, tr, bl, br', () {
    final r = CornerRadius.fromJson([14, 14, 14, 0]);
    expect(r.tl, RadiusModel.circular(14));
    expect(r.br, RadiusModel.circular(0));
    expect(r.linked, isFalse);
  });

  test('x, y per corner without linked and type', () {
    final r = CornerRadius.fromJson([1, 2, 3, 4, 5, 6, 7, 8]);
    expect(r.tr, const RadiusModel(x: 3, y: 4));
    expect(r.br, const RadiusModel(x: 7, y: 8));
    expect(r.type, RadiusType.circular);
  });

  test('the stored formats still read back', () {
    final CornerRadius all = CornerRadius.all(RadiusModel.circular(6));
    expect(CornerRadius.fromJson(all.toJson()), all);
  });
}
