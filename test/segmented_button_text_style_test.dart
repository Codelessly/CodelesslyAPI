import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('segmented labels preserve typography through JSON', () {
    final node = Node.fromJson({
      'type': 'segmentedButton',
      'props': {
        'textStyle': {
          'fontFamily': 'Alegreya',
          'fontSize': 13,
          'fontWeight': 700,
          'fontFeatures': ['tnum'],
        },
      },
    }, id: 'tabs')!;
    final restored = Node.fromJson(node.toJson(), id: 'tabs')!;
    final style = restored.prop(SegmentedButtonProps.textStyle);
    expect(style.fontFamily, 'Alegreya');
    expect(style.fontSize, 13);
    expect(style.fontWeight, 700);
    expect(style.fontFeatures, ['tnum']);
  });
  test('default text style stays sparse and inherits the theme', () {
    final node = Node.fromJson({'type': 'segmentedButton'}, id: 'tabs')!;
    expect(node.prop(SegmentedButtonProps.textStyle).isEmpty, isTrue);
    expect(
      (node.toJson()['props'] as Map?)?.containsKey('textStyle') ?? false,
      isFalse,
    );
  });
}
