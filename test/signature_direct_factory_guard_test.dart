import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> wire({
  String type = 'signature',
  Map<String, dynamic> properties = const {},
}) => {
  'id': 'sig',
  'name': 'Signature',
  'type': type,
  'basicBoxLocal': [0, 0, 320, 140],
  'properties': properties,
};

void rejects(
  Map<String, dynamic> input,
  Object? Function(Map) decode,
  String reason,
) {
  final original = {...input};
  try {
    decode(input);
    fail('Expected $reason for $input');
  } on UnresolvedNodeSchema catch (error) {
    expect(error.reason, reason);
    expect(error.raw, original);
  }
}

void main() {
  group('direct pixel factory', () {
    test('ambiguous shared-only and empty legacy signatures fail closed', () {
      for (final properties in [
        <String, dynamic>{},
        {'inkColor': '#000000'},
      ]) {
        final input = wire(properties: properties);
        rejects(input, SignatureNode.fromJson, 'ambiguous-signature-schema');
      }
    });

    test('normalized-exclusive legacy fields cannot become pixel nodes', () {
      for (final input in [
        {...wire(), 'strokes': []},
        wire(properties: {'readOnly': true}),
        wire(properties: {'strokeWidth': 3}),
        {...wire(), 'signatureKind': 'normalized'},
      ]) {
        rejects(input, SignatureNode.fromJson, 'conflicting-signature-schema');
      }
    });

    test('mixed fields and contradictory explicit tags fail closed', () {
      for (final input in [
        {...wire(), 'value': [], 'strokes': []},
        {...wire(), 'signatureKind': 'pixel', 'strokes': []},
        {...wire(type: 'signatureNormalized'), 'signatureKind': 'pixel'},
        {...wire(), 'signatureKind': 'future-kind', 'value': []},
      ]) {
        rejects(
          input,
          SignatureNode.fromJson,
          input['signatureKind'] == 'future-kind'
              ? 'unknown-signature-kind'
              : 'conflicting-signature-schema',
        );
      }
    });

    test('tagged and exclusive pixel payloads still decode', () {
      final value = [
        [
          [32, 70],
        ],
      ];
      for (final input in [
        {...wire(), 'signatureKind': 'pixel'},
        {...wire(), 'value': value},
        wire(properties: {'inkWidth': 3}),
        {
          ...wire(),
          'signatureKind': 'pixel',
          'futureFeature': {'version': 2},
        },
      ]) {
        final node = SignatureNode.fromJson(input);
        expect(node.type, 'signature');
        expect(node.value, input['value'] ?? []);
      }
    });
  });

  group('direct normalized factory', () {
    test('legacy normalized payload works only in normalized factory', () {
      final input = {
        ...wire(),
        'strokes': [
          [
            [0.1, 0.5],
          ],
        ],
      };
      final parsed = SignatureNormalizedNode.fromJson(input);
      expect(parsed.strokes, input['strokes']);
      expect(parsed.type, 'signatureNormalized');
      expect(parsed.toJson()['type'], 'signatureNormalized');
      rejects(input, SignatureNode.fromJson, 'conflicting-signature-schema');
    });

    test('explicit normalized rejects pixel-exclusive fields and tags', () {
      for (final input in [
        {...wire(type: 'signatureNormalized'), 'value': []},
        wire(type: 'signatureNormalized', properties: {'inkWidth': 2}),
        wire(
          type: 'signatureNormalized',
          properties: {'backgroundColor': '#FFFFFF'},
        ),
        {...wire(type: 'signatureNormalized'), 'signatureKind': 'pixel'},
        {...wire(type: 'signatureNormalized'), 'signatureKind': 'future-kind'},
      ]) {
        rejects(
          input,
          SignatureNormalizedNode.fromJson,
          input['signatureKind'] == 'future-kind'
              ? 'unknown-signature-kind'
              : 'conflicting-signature-schema',
        );
      }
    });

    test('tagged normalized and future extras remain decodable', () {
      final input = {
        ...wire(type: 'signatureNormalized', properties: {'readOnly': true}),
        'signatureKind': 'normalized',
        'futureFeature': {'version': 2},
      };
      final node = SignatureNormalizedNode.fromJson(input);
      expect(node.properties.readOnly, isTrue);
      expect(node.type, 'signatureNormalized');
      expect(
        SignatureNormalizedNode.fromJson(wire(type: 'signatureNormalized'))
            .strokes,
        isEmpty,
      );
    });
  });

  test('generated and converter caller paths remain valid', () {
    final pixel = SignatureNode.empty().toJson();
    final normalized = SignatureNormalizedNode.empty().toJson();
    final converter = NodeJsonConverter();
    expect(SignatureNode.fromJson(pixel), isA<SignatureNode>());
    expect(
      SignatureNormalizedNode.fromJson(normalized),
      isA<SignatureNormalizedNode>(),
    );
    expect(converter.fromJson(pixel), isA<SignatureNode>());
    expect(converter.fromJson(normalized), isA<SignatureNormalizedNode>());
    expect(
      NodesMapConverter.deserialize({'pixel': pixel, 'normalized': normalized})
          .values
          .toList(),
      [isA<SignatureNode>(), isA<SignatureNormalizedNode>()],
    );
  });
}
