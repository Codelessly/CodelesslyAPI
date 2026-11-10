import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a line height unit reads in any case and as % or px', () {
    expect(LineHeight.fromJson({'value': 140, 'unit': 'Percent'}).unit,
        LineHeightUnitEnum.percent);
    expect(LineHeight.fromJson({'value': 140, 'unit': '%'}).unit,
        LineHeightUnitEnum.percent);
    expect(LineHeight.fromJson({'value': 20, 'unit': 'PX'}).unit,
        LineHeightUnitEnum.pixels);
    expect(LineHeight.fromJson({'value': 0, 'unit': 'Auto'}).unit,
        LineHeightUnitEnum.auto);
  });

  test('so does a letter spacing unit', () {
    expect(LetterSpacing.fromJson({'value': 2, 'unit': 'PERCENT'}).unit,
        LetterSpacingUnitEnum.percent);
    expect(LetterSpacing.fromJson({'value': 1.5, 'unit': 'px'}).unit,
        LetterSpacingUnitEnum.pixels);
  });
}
