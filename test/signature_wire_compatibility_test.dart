import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> signatureJson({
  String type = 'signature',
  Map<String, dynamic> properties = const {},
}) => {
  'id': 'sig',
  'name': 'Signature',
  'type': type,
  'basicBoxLocal': [0, 0, 320, 140],
  'properties': properties,
};

void main() {
  final converter = NodeJsonConverter();

  test('new pixel writes are tagged and preserve pixel coordinates', () {
    final node = SignatureNode(
      id: 'pixel',
      name: 'Pixel',
      basicBoxLocal: NodeBox(0, 0, 320, 140),
      properties: SignatureProperties(),
      value: [
        [
          [32, 70],
        ],
      ],
    );
    final json = node.toJson();
    expect(json['type'], 'signature');
    expect(json['signatureKind'], 'pixel');
    expect((converter.fromJson(json)! as SignatureNode).value, node.value);
    expect(SignatureNode.empty().toJson()['signatureKind'], 'pixel');
  });

  test('new normalized writes are tagged even with omitted defaults', () {
    final json = SignatureNormalizedNode.empty().toJson();
    expect(json['type'], 'signatureNormalized');
    expect(json['signatureKind'], 'normalized');
    expect(converter.fromJson(json), isA<SignatureNormalizedNode>());
    final node = SignatureNormalizedNode(
      id: 'normalized',
      name: 'Normalized',
      basicBoxLocal: NodeBox(0, 0, 320, 140),
      properties: SignatureNormalizedProperties(readOnly: true),
      strokes: [
        [
          [0.1, 0.5],
        ],
      ],
    );
    expect(
      (converter.fromJson(node.toJson())! as SignatureNormalizedNode).strokes,
      node.strokes,
    );
  });

  test('exclusive untagged legacy keys classify without scaling points', () {
    final pixel = {
      ...signatureJson(),
      'value': [
        [
          [32, 70],
        ],
      ],
    };
    expect((converter.fromJson(pixel)! as SignatureNode).value, [
      [
        [32, 70],
      ],
    ]);
    final normalized = {
      ...signatureJson(),
      'strokes': [
        [
          [0.1, 0.5],
        ],
      ],
    };
    final parsed = converter.fromJson(normalized)! as SignatureNormalizedNode;
    expect(parsed.strokes, [
      [
        [0.1, 0.5],
      ],
    ]);
    expect(parsed.toJson()['type'], 'signatureNormalized');
  });

  test('shared-only and empty legacy records fail with untouched raw', () {
    for (final properties in [
      <String, dynamic>{},
      {'inkColor': '#000000'},
    ]) {
      final input = signatureJson(properties: properties);
      try {
        converter.fromJson(input);
        fail('ambiguous signature must not be decoded');
      } on UnresolvedNodeSchema catch (error) {
        expect(error.reason, 'ambiguous-signature-schema');
        expect(error.raw, input);
        if (properties.isNotEmpty) {
          (input['properties'] as Map)['inkColor'] = '#FFFFFF';
          expect((error.raw['properties'] as Map)['inkColor'], '#000000');
        }
      }
    }
  });

  test('mixed keys and contradictory tags fail with untouched raw', () {
    for (final input in [
      {...signatureJson(), 'value': [], 'strokes': []},
      {...signatureJson(), 'signatureKind': 'pixel', 'strokes': []},
      {...signatureJson(type: 'signatureNormalized'), 'signatureKind': 'pixel'},
    ]) {
      try {
        converter.fromJson(input);
        fail('mixed signature must not be decoded');
      } on UnresolvedNodeSchema catch (error) {
        expect(error.reason, 'conflicting-signature-schema');
        expect(error.raw, input);
      }
    }
  });
}
