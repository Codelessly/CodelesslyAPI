import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> signature({
  Map<String, dynamic> properties = const {},
  Object? value,
  Object? strokes,
}) => {
  'id': 'signature',
  'name': 'Signature',
  'type': 'signature',
  'basicBoxLocal': [0, 0, 320, 140],
  'properties': properties,
  'value': ?value,
  'strokes': ?strokes,
};

void main() {
  test('nodes map fails closed and retains all original nodes', () {
    final input = <String, dynamic>{
      'first': signature(
        value: [
          [
            [10, 20],
          ],
        ],
      ),
      'unresolved': signature(properties: {'inkColor': '#000000'}),
      'last': {'type': 'text', 'id': 'last', 'name': 'Last'},
    };
    try {
      NodesMapConverter.deserialize(input);
      fail('ambiguous signature must reject the complete nodes map');
    } on UnresolvedDocumentSchema catch (error) {
      expect(error.reason, 'ambiguous-signature-schema');
      expect(error.nodeKey, 'unresolved');
      expect(error.raw, input);
      expect(error.raw.keys, ['first', 'unresolved', 'last']);
      ((input['unresolved'] as Map)['properties'] as Map)['inkColor'] =
          '#FFFFFF';
      expect(
        ((error.raw['unresolved'] as Map)['properties'] as Map)['inkColor'],
        '#000000',
      );
    }
  });

  test('canvases map fails closed and retains other canvases and metadata', () {
    final input = <String, dynamic>{
      'canvas-a': <String, dynamic>{'unresolved': signature()},
      'canvas-b': <String, dynamic>{
        'other': signature(
          value: [
            [
              [32, 70],
            ],
          ],
        ),
      },
    };
    try {
      CanvasesMapConverter.deserialize(input);
      fail('ambiguous signature must reject the entire canvases map');
    } on UnresolvedDocumentSchema catch (error) {
      expect(error.reason, 'ambiguous-signature-schema');
      expect(error.nodeKey, 'unresolved');
      expect(error.raw, input);
      expect(error.raw.keys, ['canvas-a', 'canvas-b']);
    }
  });

  test('mixed legacy keys reject the whole document, no partial save', () {
    final input = <String, dynamic>{
      'mixed': signature(value: [], strokes: []),
      'pixel': signature(
        value: [
          [
            [32, 70],
          ],
        ],
      ),
    };
    expect(
      () => NodesMapConverter.deserialize(input),
      throwsA(
        isA<UnresolvedDocumentSchema>().having(
          (e) => e.reason,
          'reason',
          'conflicting-signature-schema',
        ),
      ),
    );
  });

  test('exclusive legacy signatures can be loaded and reserialized', () {
    final input = <String, dynamic>{
      'pixel': signature(
        value: [
          [
            [32, 70],
          ],
        ],
      ),
      'normalized': signature(
        strokes: [
          [
            [0.1, 0.5],
          ],
        ],
      ),
    };
    final parsed = NodesMapConverter.deserialize(input);
    expect(parsed['pixel'], isA<SignatureNode>());
    expect(parsed['normalized'], isA<SignatureNormalizedNode>());
    final output = NodesMapConverter.serialize(parsed);
    expect((output['pixel'] as Map)['signatureKind'], 'pixel');
    expect((output['normalized'] as Map)['signatureKind'], 'normalized');
    expect((output['normalized'] as Map)['type'], 'signatureNormalized');
  });
}
