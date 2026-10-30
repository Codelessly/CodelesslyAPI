import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

BaseNode roundTrip(BaseNode node) => NodeJsonConverter.instance.fromJson(
  jsonDecode(jsonEncode(node.toJson())) as Map,
)!;

void main() {
  group('BarcodeNode', () {
    test('a default barcode stores only its identity and box', () {
      final node = BarcodeNode(
        id: 'b',
        name: 'Barcode',
        basicBoxLocal: NodeBox(0, 0, 160, 160),
        properties: BarcodeProperties(),
      );
      final json = node.toJson();
      expect(json['type'], 'barcode');
      expect(json['properties'], isEmpty);
      expect(json.containsKey('data'), isFalse);
      expect(roundTrip(node), node);
    });

    test('every property round-trips', () {
      final node = BarcodeNode(
        id: 'pass',
        name: 'Boarding pass code',
        basicBoxLocal: NodeBox(0, 0, 300, 90),
        data: r'M1DOE/JOHN ${pass.pnr}',
        variables: {'data': r'${= pass.barcode}'},
        properties: BarcodeProperties(
          symbology: BarcodeSymbology.pdf417,
          color: ColorRGBA.white,
          backgroundColor: ColorRGBA.black,
          errorCorrection: BarcodeErrorCorrection.high,
          drawText: false,
        ),
      );
      final back = roundTrip(node) as BarcodeNode;
      expect(back, node);
      expect(back.data, r'M1DOE/JOHN ${pass.pnr}');
      expect(back.variables['data'], r'${= pass.barcode}');
      expect(back.properties.symbology, BarcodeSymbology.pdf417);
      expect(back.properties.backgroundColor, ColorRGBA.black);
      expect(back.properties.errorCorrection, BarcodeErrorCorrection.high);
      expect(back.properties.drawText, isFalse);
    });

    test('hand-written JSON with top-level properties parses', () {
      final node = NodeJsonConverter.instance.fromJson({
        'type': 'barcode',
        'id': 'qr',
        'name': 'QR',
        'basicBoxLocal': [0, 0, 120, 120],
        'data': r'${pass.barcode}',
        'symbology': 'aztec',
      }) as BarcodeNode;
      expect(node.data, r'${pass.barcode}');
      expect(node.properties.symbology, BarcodeSymbology.aztec);
      expect(node.properties.color, ColorRGBA.black);
      expect(node.properties.backgroundColor, isNull);
      expect(node.properties.errorCorrection, BarcodeErrorCorrection.medium);
      expect(node.properties.drawText, isTrue);
      // Written back under `properties`.
      final json = node.toJson();
      expect(json.containsKey('symbology'), isFalse);
      expect((json['properties'] as Map)['symbology'], 'aztec');
      expect(roundTrip(node), node);
    });

    test('keys under properties win over top-level ones', () {
      final node = NodeJsonConverter.instance.fromJson({
        'type': 'barcode',
        'id': 'qr',
        'name': 'QR',
        'basicBoxLocal': [0, 0, 120, 120],
        'symbology': 'aztec',
        'properties': {'symbology': 'code128'},
      }) as BarcodeNode;
      expect(node.properties.symbology, BarcodeSymbology.code128);
      expect(node.data, '');
    });

    test('an unknown symbology falls back to QR', () {
      final node = NodeJsonConverter.instance.fromJson({
        'type': 'barcode',
        'id': 'qr',
        'name': 'QR',
        'basicBoxLocal': [0, 0, 120, 120],
        'properties': {'symbology': 'maxiCode', 'errorCorrection': 'ultra'},
      }) as BarcodeNode;
      expect(node.properties.symbology, BarcodeSymbology.qrCode);
      expect(node.properties.errorCorrection, BarcodeErrorCorrection.medium);
    });
  });
}
