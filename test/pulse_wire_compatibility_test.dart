import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> nodeWithPulse(Map<String, dynamic> pulse) => {
  'id': 'r',
  'name': 'Rectangle',
  'type': 'rectangle',
  'basicBoxLocal': [0, 0, 40, 40],
  'pulse': pulse,
};

RectangleNode rectangle() => RectangleNode(
  id: 'r',
  name: 'Rectangle',
  basicBoxLocal: NodeBox(0, 0, 40, 40),
);

void main() {
  final converter = NodeJsonConverter();

  test('default relative pulse always writes explicit flavor', () {
    final node = rectangle()..pulse = const PulseModel();
    final json = node.toJson();
    expect((json['pulse'] as Map)['pulseKind'], 'relative');
    expect(
      (converter.fromJson(json)! as RectangleNode).pulse,
      const PulseModel(),
    );
  });

  test(
    'default motion pulse writes explicit kind, even with no other keys',
    () {
      final node = rectangle()..pulse = const MotionPulseModel();
      expect(node.toJson()['pulse'], {'pulseKind': 'motion'});
      expect(
        (converter.fromJson(node.toJson())! as RectangleNode).pulse,
        const MotionPulseModel(),
      );
    },
  );

  test('exclusive unmarked motion pulse is classified', () {
    final node =
        converter.fromJson(nodeWithPulse({'scaleTo': 1.4}))! as RectangleNode;
    expect(node.pulse, isA<MotionPulseModel>());
    expect((node.pulse! as MotionPulseModel).scaleTo, 1.4);
    expect((node.toJson()['pulse'] as Map)['pulseKind'], 'motion');
  });

  test('tagged contradictory and unknown pulses preserve raw node', () {
    for (final pulse in [
      {'pulseKind': 'relative', 'scaleTo': 1.4},
      {'pulseKind': 'motion', 'minOpacity': 0.3},
      {'pulseKind': 'future'},
    ]) {
      final raw = nodeWithPulse(pulse);
      try {
        converter.fromJson(raw);
        fail('contradictory or unknown pulse must remain unresolved');
      } on UnresolvedNodeSchema catch (error) {
        expect(
          error.reason,
          pulse['pulseKind'] == 'future'
              ? 'unknown-pulse-kind'
              : 'conflicting-pulse-schema',
        );
        expect(error.raw, raw);
      }
    }
  });

  test('non-blended nodes persist motion pulse without changing layout', () {
    final spacer = SpacerNode(
      id: 's',
      name: 'Spacer',
      basicBoxLocal: NodeBox(0, 0, 16, 16),
    )..pulse = const MotionPulseModel(scaleTo: 1.3);
    final wire = spacer.toJson();
    expect(wire['pulse'], {'pulseKind': 'motion', 'scaleTo': 1.3});
    final read = converter.fromJson(wire)! as SpacerNode;
    expect(read.pulse, spacer.pulse);
  });

  test('exclusive unmarked relative pulse is classified', () {
    final node =
        converter.fromJson(nodeWithPulse({'minOpacity': 0.25}))!
            as RectangleNode;
    expect(node.pulse?.minOpacity, 0.25);
    expect((node.toJson()['pulse'] as Map)['pulseKind'], 'relative');
  });

  test('unmarked empty and mixed pulse reject with deep original document', () {
    for (final pulse in [
      <String, dynamic>{},
      {'minOpacity': 0.25, 'scaleTo': 1.4},
    ]) {
      final input = <String, dynamic>{
        'first': rectangle().toJson(),
        'unresolved': nodeWithPulse(pulse),
      };
      try {
        NodesMapConverter.deserialize(input);
        fail('unmarked ambiguous or mixed pulse must not deserialize');
      } on UnresolvedDocumentSchema catch (error) {
        expect(error.nodeKey, 'unresolved');
        expect(
          error.reason,
          pulse.isEmpty ? 'ambiguous-pulse-schema' : 'conflicting-pulse-schema',
        );
        expect(error.raw, input);
        pulse['scaleTo'] = 5.0;
        expect((error.raw['unresolved'] as Map)['pulse'], isNot(pulse));
      }
    }
  });

  test('nested canvases cannot return a partial parsed tree', () {
    final input = <String, dynamic>{
      'a': <String, dynamic>{'safe': rectangle().toJson()},
      'b': <String, dynamic>{'unresolved': nodeWithPulse({})},
    };
    try {
      CanvasesMapConverter.deserialize(input);
      fail('ambiguous pulse must reject all canvases');
    } on UnresolvedDocumentSchema catch (error) {
      expect(error.reason, 'ambiguous-pulse-schema');
      expect(error.raw, input);
      ((input['b'] as Map)['unresolved'] as Map)['name'] = 'Changed';
      expect(
        ((error.raw['b'] as Map)['unresolved'] as Map)['name'],
        'Rectangle',
      );
    }
  });
}
