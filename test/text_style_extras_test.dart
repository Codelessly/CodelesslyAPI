import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

TextNode textFromJson(Map<String, dynamic> extra) => TextNode.fromJson({
  'id': 'text',
  'name': 'Text',
  'type': 'text',
  'basicBoxLocal': [0, 0, 200, 20],
  'data': 'Retries honor `Retry-After`',
  'textMixedProps': [
    {'start': 0, 'end': 27, 'fontSize': 17},
  ],
  ...extra,
});

void main() {
  group('decoration color, thickness and style', () {
    test('round trip through a span', () {
      final StartEndProp prop = StartEndProp.fromJson({
        'start': 0,
        'end': 3,
        'textDecoration': 'strikethrough',
        'decorationColor': '#F87171',
        'decorationThickness': 2,
        'decorationStyle': 'wavy',
      });
      expect(prop.decorationColor, ColorRGBA.fromHex('#F87171'));
      expect(prop.decorationThickness, 2);
      expect(prop.decorationStyle, TextDecorationStyleEnum.wavy);
      final Map json = prop.toJson();
      expect(json['decorationColor'], '#FFF87171');
      expect(json['decorationThickness'], 2);
      expect(json['decorationStyle'], 'wavy');
      expect(StartEndProp.fromJson(json), prop);
    });

    test('are left out of the JSON when unset', () {
      final Map json = StartEndProp(start: 0, end: 1).toJson();
      expect(json.containsKey('decorationColor'), isFalse);
      expect(json.containsKey('decorationThickness'), isFalse);
      expect(json.containsKey('decorationStyle'), isFalse);
    });

    test('survive copyWith, fromTextProp and equivalence', () {
      final StartEndProp prop = StartEndProp(
        start: 0,
        end: 1,
        decorationColor: ColorRGBA.fromHex('#4ADE80'),
        decorationThickness: 1.5,
      );
      final StartEndProp moved = prop.copyWith(start: 1, end: 2);
      expect(moved.decorationColor, prop.decorationColor);
      expect(moved.decorationThickness, 1.5);
      final StartEndProp copied = StartEndProp.fromTextProp(
        start: 0,
        end: 1,
        prop: prop,
      );
      expect(copied, prop);
      expect(prop.isEquivalentTo(StartEndProp(start: 0, end: 1)), isFalse);
      final TextProp plain = TextProp(decorationThickness: 3);
      expect(plain.copyWith(fontSize: 12).decorationThickness, 3);
    });
  });

  group('inline code', () {
    test('round trips on a text node', () {
      final TextNode node = textFromJson({
        'inlineCode': {
          'fontFamily': 'JetBrains Mono',
          'color': '#4ADE80',
          'background': '#141C17',
          'fontSizeScale': 0.92,
        },
      });
      expect(node.inlineCode, isNotNull);
      expect(node.inlineCode!.fontFamily, 'JetBrains Mono');
      expect(node.inlineCode!.color, ColorRGBA.fromHex('#4ADE80'));
      expect(node.inlineCode!.background, ColorRGBA.fromHex('#141C17'));
      expect(node.inlineCode!.fontSizeScale, 0.92);
      final Map json = node.toJson();
      expect(json['inlineCode'], {
        'fontFamily': 'JetBrains Mono',
        'color': '#FF4ADE80',
        'background': '#FF141C17',
        'fontSizeScale': 0.92,
      });
      expect(TextNode.fromJson(json).inlineCode, node.inlineCode);
    });

    test('an empty style keeps its place and its defaults', () {
      final TextNode node = textFromJson({'inlineCode': <String, dynamic>{}});
      expect(node.inlineCode, const InlineCodeStyle());
      expect(node.inlineCode!.fontSizeScale, 1);
      expect(node.toJson()['inlineCode'], <String, dynamic>{});
    });

    test('is left out when unset', () {
      expect(textFromJson({}).toJson().containsKey('inlineCode'), isFalse);
    });
  });

  group('count up', () {
    test('round trips with its duration and curve', () {
      final TextNode node = textFromJson({
        'countUp': {'durationMs': 600, 'curve': 'easeInOut'},
      });
      expect(node.countUp!.durationMs, 600);
      expect(node.countUp!.curve, MotionCurve.easeInOut);
      expect(node.toJson()['countUp'], {
        'durationMs': 600,
        'curve': 'easeInOut',
      });
    });

    test('defaults to 450 ms, easeOutCubic', () {
      final TextNode node = textFromJson({'countUp': <String, dynamic>{}});
      expect(node.countUp, const CountUpModel());
      expect(node.countUp!.durationMs, 450);
      expect(node.countUp!.curve, MotionCurve.easeOutCubic);
      expect(textFromJson({}).countUp, isNull);
    });
  });

  test('a text offers its font size, letter spacing, line height, family '
      'and alignment to set value actions and conditions', () {
    final TextNode node = textFromJson({
      'textAlignHorizontal': 'center',
      'textMixedProps': [
        {
          'start': 0,
          'end': 27,
          'fontSize': 66,
          'letterSpacing': {'value': -1.5},
          'lineHeight': {'value': 70},
          'fontName': {'family': 'Inter', 'weight': 'w700'},
        },
      ],
    });
    final Map<String, Object?> values = {
      for (final ValueModel value in node.propertyVariables)
        value.name: value.value,
    };
    expect(values['fontSize'], 66);
    expect(values['letterSpacing'], -1.5);
    expect(values['lineHeight'], 70);
    expect(values['fontFamily'], 'Inter');
    expect(values['textAlign'], 'center');
  });

  group('edge insets from a binding', () {
    test('read a map of sides', () {
      expect(
        <String, dynamic>{'top': 44}.toEdgeInsetsModel(),
        const EdgeInsetsModel.only(top: 44),
      );
      expect(
        <String, dynamic>{'horizontal': 16, 'vertical': 8}.toEdgeInsetsModel(),
        const EdgeInsetsModel.symmetric(horizontal: 16, vertical: 8),
      );
      expect(
        <String, dynamic>{'l': 1, 't': 2, 'r': 3, 'b': 4}.toEdgeInsetsModel(),
        const EdgeInsetsModel.only(left: 1, top: 2, right: 3, bottom: 4),
      );
      expect(
        '{"bottom": 12}'.toEdgeInsetsModel(),
        const EdgeInsetsModel.only(bottom: 12),
      );
    });

    test('still read numbers and lists', () {
      expect(8.toEdgeInsetsModel(), const EdgeInsetsModel.all(8));
      expect(
        [16, 8].toEdgeInsetsModel(),
        const EdgeInsetsModel.symmetric(horizontal: 16, vertical: 8),
      );
      expect(
        [1, 2, 3, 4].toEdgeInsetsModel(),
        const EdgeInsetsModel.only(left: 1, top: 2, right: 3, bottom: 4),
      );
      expect(<String, dynamic>{'top': 'x'}.toEdgeInsetsModel(), isNull);
    });
  });
}
