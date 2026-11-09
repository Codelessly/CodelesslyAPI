import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

void main() {
  test('a v1 style sheet: text styles and paints as v2, privacy kept', () {
    final out = migrateStyleSheet({
      'id': 'p1',
      'name': 'P1',
      'owner': 'u',
      'defaultTextStyleID': 't1',
      'textStyles': [
        {
          'id': 't1',
          'label': 'Body',
          'value': TextProp.general(
            fontSize: 16,
            fontName: const FontName(family: 'Inter', weight: FontWeightNumeric.w400),
            fills: [PaintModel.blackPaint],
          ).toJson(),
        },
      ],
      'paintStyles': [
        {'id': 'c1', 'label': 'Primary', 'value': PaintModel.solid(id: 'x', color: const ColorRGB(r: 0, g: 0, b: 1)).toJson()},
      ],
    });
    expect(out['schema'], 2);
    expect(out['owner'], 'u');
    expect(out['defaultTextStyle'], 't1');
    expect(out.containsKey('textStyles'), isTrue);
    final t = (out['textStyles'] as List).single as Map;
    expect(t['name'], 'Body');
    expect((t['style'] as Map)['fontFamily'], 'Inter');
    expect((t['style'] as Map)['fontSize'], 16);
    final c = (out['colorStyles'] as List).single as Map;
    expect(c['name'], 'Primary');
    expect((c['paint'] as Map)['color'], '#FF0000FF');
  });
}
