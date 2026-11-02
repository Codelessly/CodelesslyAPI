import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// [node] through its JSON and back.
BaseNode roundTrip(BaseNode node) =>
    NodeJsonConverter().fromJson(node.toJson())!;

List<String> propertyNames(PropertyVariableMixin node) => [
  for (final ValueModel value in node.propertyVariables) value.name,
];

void main() {
  group('icon color binding', () {
    test('an icon keeps its iconColor binding through JSON', () {
      final IconNode icon = IconNode(
        id: 'icon',
        name: 'Icon',
        basicBoxLocal: NodeBox(0, 0, 24, 24),
      )..variables['iconColor'] = r'${pass.accent}';
      final IconNode back = roundTrip(icon) as IconNode;
      expect(back.variables['iconColor'], r'${pass.accent}');
      expect(propertyNames(back), contains('iconColor'));
    });
  });

  group('switch', () {
    test('its colors are bindable and survive JSON', () {
      final SwitchNode node = SwitchNode.fromJson({
        'id': 'switch',
        'name': 'Switch',
        'type': 'switch',
        'basicBoxLocal': [0, 0, 59, 40],
        'value': true,
        'properties': {'activeTrackColor': '#1F2B2E'},
        'variables': {
          'activeTrackColor': r'${pal.ink}',
          'inactiveTrackColor': r'${pal.line}',
          'activeThumbColor': r'${pal.paper}',
          'inactiveThumbColor': r'${= on ? "#FFFFFF" : "#EEEEEE"}',
        },
      });
      expect(node.value, isTrue);
      expect(node.properties.activeTrackColor, ColorRGBA.fromHex('#1F2B2E'));
      final SwitchNode back = roundTrip(node) as SwitchNode;
      expect(back.value, isTrue);
      expect(back.variables['activeTrackColor'], r'${pal.ink}');
      expect(back.variables['inactiveThumbColor'], contains('on ?'));
      expect(
        propertyNames(back),
        containsAll(<String>[
          'value',
          'activeTrackColor',
          'inactiveTrackColor',
          'activeThumbColor',
          'inactiveThumbColor',
          'activeTrackBorderColor',
          'inactiveTrackBorderColor',
        ]),
      );
    });
  });

  group('text decoration', () {
    test('parses names and aliases', () {
      expect(
        TextDecorationEnum.parse('lineThrough'),
        TextDecorationEnum.strikethrough,
      );
      expect(
        TextDecorationEnum.parse('line-through'),
        TextDecorationEnum.strikethrough,
      );
      expect(
        TextDecorationEnum.parse('strikethrough'),
        TextDecorationEnum.strikethrough,
      );
      expect(TextDecorationEnum.parse('Underline'), TextDecorationEnum.underline);
      expect(TextDecorationEnum.parse('none'), TextDecorationEnum.none);
      expect(TextDecorationEnum.parse('wavy'), isNull);
      expect(TextDecorationEnum.parse(null), isNull);
    });

    test('lineThrough in JSON reads as strikethrough and writes back', () {
      final TextNode text = TextNode.fromJson({
        'id': 'text',
        'name': 'Text',
        'type': 'text',
        'basicBoxLocal': [0, 0, 80, 20],
        'data': 'LHR',
        'textMixedProps': [
          {'start': 0, 'end': 3, 'textDecoration': 'lineThrough'},
        ],
        'variables': {
          'textDecoration': r'${= pass.cancelled ? "lineThrough" : "none"}',
        },
      });
      expect(
        text.textMixedProps.single.textDecoration,
        TextDecorationEnum.strikethrough,
      );
      final Map json = text.toJson();
      expect(
        (json['textMixedProps'] as List).single['textDecoration'],
        'strikethrough',
      );
      final TextNode back = roundTrip(text) as TextNode;
      expect(back.variables['textDecoration'], contains('pass.cancelled'));
      expect(propertyNames(back), contains('textDecoration'));
      expect(
        TextProp.fromJson({'textDecoration': 'lineThrough'}).textDecoration,
        TextDecorationEnum.strikethrough,
      );
    });
  });

  group('notch offset bindings', () {
    test('a frame keeps per-notch and shared offset bindings', () {
      final BaseNode frame = NodeJsonConverter().fromJson({
        'type': 'frame',
        'id': 'ticket',
        'name': 'Ticket',
        'children': <String>[],
        'basicBoxLocal': [0, 0, 340, 420],
        'notches': [
          {'offset': 146, 'relative': false},
          {'offset': 120, 'relative': false, 'fromEnd': true},
        ],
        'variables': {
          'notch-offset-0': r'${146 * screen.width / 340}',
          'notchOffset': r'${= screen.width / 3}',
        },
      })!;
      final FrameNode back = roundTrip(frame) as FrameNode;
      expect(back.notches, hasLength(2));
      expect(back.variables['notch-offset-0'], r'${146 * screen.width / 340}');
      expect(back.variables['notchOffset'], r'${= screen.width / 3}');
    });
  });

  group('barcode', () {
    test('symbology names parse loosely', () {
      expect(BarcodeSymbology.parse('pdf417'), BarcodeSymbology.pdf417);
      expect(BarcodeSymbology.parse('PDF 417'), BarcodeSymbology.pdf417);
      expect(BarcodeSymbology.parse('qr'), BarcodeSymbology.qrCode);
      expect(BarcodeSymbology.parse('qr-code'), BarcodeSymbology.qrCode);
      expect(BarcodeSymbology.parse('data_matrix'), BarcodeSymbology.dataMatrix);
      expect(BarcodeSymbology.parse('EAN-13'), BarcodeSymbology.ean13);
      expect(BarcodeSymbology.parse('morse'), isNull);
    });

    test('a barcode has an opacity and a bindable symbology', () {
      final BarcodeNode node = BarcodeNode.fromJson({
        'id': 'code',
        'name': 'Code',
        'type': 'barcode',
        'basicBoxLocal': [0, 0, 300, 90],
        'data': 'M1DOE/JANE',
        'opacity': 0.4,
        'properties': {'symbology': 'pdf417'},
        'variables': {
          'symbology': r'${pass.codeType}',
          'opacity': r'${= pass.used ? 0.3 : 1}',
        },
      });
      expect(node, isA<BlendMixin>());
      expect(node.opacity, 0.4);
      final BarcodeNode back = roundTrip(node) as BarcodeNode;
      expect(back.opacity, 0.4);
      expect(back.properties.symbology, BarcodeSymbology.pdf417);
      expect(back.variables['symbology'], r'${pass.codeType}');
      expect(back.variables['opacity'], contains('pass.used'));
      expect(propertyNames(back), containsAll(<String>['opacity', 'symbology']));
    });

    test('an opaque barcode writes no blend keys', () {
      final Map json = BarcodeNode.empty().toJson();
      expect(json.containsKey('opacity'), isFalse);
      expect(json.containsKey('blendMode'), isFalse);
      expect(json.containsKey('effects'), isFalse);
    });
  });

  group('fractional rotation', () {
    test('a fractional rotation is kept through JSON', () {
      final BaseNode node = NodeJsonConverter().fromJson({
        'type': 'rectangle',
        'id': 'stamp',
        'name': 'Stamp',
        'basicBoxLocal': [0, 0, 120, 40],
        'rotation': -4.6,
      })!;
      expect(node.rotationDegrees, -4.6);
      expect(node.rotationRadians, closeTo(-4.6 * 3.141592653589793 / 180, 1e-12));
      expect(roundTrip(node).rotationDegrees, -4.6);
      expect(node.toJson()['rotation'], -4.6);
    });

    test('whole degrees stay whole numbers', () {
      expect(castRotation(12), 12);
      expect(castRotation(12.0), isA<int>());
      expect(castRotation(-3.4), -3.4);
      expect(castRotation('-4.6'), -4.6);
      expect(castRotation(null), 0);
      expect(castRotation(double.nan), 0);
      final BaseNode node = NodeJsonConverter().fromJson({
        'type': 'rectangle',
        'id': 'r',
        'name': 'R',
        'basicBoxLocal': [0, 0, 10, 10],
        'rotation': 90,
      })!;
      expect(node.toJson()['rotation'], 90);
      expect(node.toJson()['rotation'], isA<int>());
    });

    test('updating a node keeps a fractional rotation', () {
      final BaseNode node = NodeJsonConverter().fromJson({
        'type': 'rectangle',
        'id': 'r',
        'name': 'R',
        'basicBoxLocal': [0, 0, 10, 10],
      })!;
      node.setNodeRotation(-3.4);
      expect(node.rotationDegrees, -3.4);
      expect(node.toJson()['rotation'], -3.4);
    });
  });
}
