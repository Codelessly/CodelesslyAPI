import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map encodeDecode(Map json) => jsonDecode(jsonEncode(json)) as Map;

void main() {
  group('LoopAnimation', () {
    test('a pulsing halo round-trips through JSON on any node', () {
      final Map<String, Object?> json = {
        'type': 'rectangle',
        'id': 'halo',
        'name': 'Halo',
        'basicBoxLocal': NodeBox(0, 0, 58, 58).toJson(),
        'loopAnimation': {
          'type': 'pulse',
          'durationMs': 1400,
          'scaleFrom': 0.655,
          'scaleTo': 1.0,
          'opacityFrom': 0.35,
          'opacityTo': 0.0,
          'curve': 'easeOut',
        },
        'variables': {'loopAnimationEnabled': r'${selectedZone == "cab"}'},
      };
      final BaseNode node = NodeJsonConverter().fromJson(json)!;
      expect(
        node.loopAnimation,
        const LoopAnimation(
          type: LoopAnimationType.pulse,
          durationMs: 1400,
          scaleFrom: 0.655,
          scaleTo: 1,
          opacityFrom: 0.35,
          opacityTo: 0,
          curve: LoopAnimationCurve.easeOut,
        ),
      );

      final Map written = encodeDecode(node.toJson());
      expect(written['loopAnimation'], {
        'type': 'pulse',
        'durationMs': 1400,
        'curve': 'easeOut',
        'scaleFrom': 0.655,
        'opacityFrom': 0.35,
        'opacityTo': 0.0,
      });
      final BaseNode read = NodeJsonConverter().fromJson(written)!;
      expect(read.loopAnimation, node.loopAnimation);
      expect(read.variables['loopAnimationEnabled'], isNotNull);
    });

    test('nodes without an animation write no key', () {
      for (final BaseNode node in [
        RectangleNode(id: 'r', name: 'R', basicBoxLocal: NodeBox(0, 0, 1, 1)),
        RowColumnNode(
          id: 'c',
          name: 'C',
          basicBoxLocal: NodeBox(0, 0, 1, 1),
          rowColumnType: RowColumnType.column,
          children: [],
        ),
        IconNode(id: 'i', name: 'I', basicBoxLocal: NodeBox(0, 0, 24, 24)),
      ]) {
        expect(node.toJson().containsKey('loopAnimation'), isFalse);
        final BaseNode read = NodeJsonConverter().fromJson(
          encodeDecode(node.toJson()),
        )!;
        expect(read.loopAnimation, isNull);
      }
    });

    test('every type and its preset round-trip', () {
      for (final LoopAnimationType type in LoopAnimationType.values) {
        final LoopAnimation animation = LoopAnimation.preset(type)
            .copyWith(delayMs: 200, enabled: false, turns: -2);
        expect(
          LoopAnimation.fromJson(encodeDecode(animation.toJson())),
          animation,
        );
      }
      // Defaults are left out.
      expect(const LoopAnimation(type: LoopAnimationType.spin).toJson(), {
        'type': 'spin',
      });
    });

    test('unknown values fall back instead of throwing', () {
      expect(
        LoopAnimation.fromJson({'type': 'wobble', 'curve': 'bounce'}),
        const LoopAnimation(type: LoopAnimationType.pulse),
      );
    });

    test('loopAnimationEnabled is a bindable field', () {
      final RectangleNode node = RectangleNode(
        id: 'r',
        name: 'R',
        basicBoxLocal: NodeBox(0, 0, 1, 1),
      )..loopAnimation = LoopAnimation.preset(LoopAnimationType.fade);
      final field = node.fields['loopAnimationEnabled']!;
      expect(field.getValue(), isTrue);
      field.setValue(false);
      expect(node.loopAnimation!.enabled, isFalse);
    });
  });

  group('Cursor triggers', () {
    test('nodes with a click trigger offer cursor enter and exit', () {
      final List<ReactionMixin> nodes = [
        RectangleNode(id: 'r', name: 'R', basicBoxLocal: NodeBox(0, 0, 1, 1)),
        FrameNode(
          id: 'f',
          name: 'F',
          basicBoxLocal: NodeBox(0, 0, 1, 1),
          children: [],
        ),
        TextNode(
          id: 't',
          name: 'T',
          basicBoxLocal: NodeBox(0, 0, 1, 1),
          characters: 'Hi',
        ),
      ];
      for (final ReactionMixin node in nodes) {
        expect(node.triggerTypes.first, TriggerType.click);
        expect(
          node.triggerTypes,
          containsAll([TriggerType.cursorEnter, TriggerType.cursorExit]),
        );
      }
    });

    test('cursor reactions round-trip', () {
      final RectangleNode node =
          RectangleNode(id: 'r', name: 'R', basicBoxLocal: NodeBox(0, 0, 1, 1))
            ..reactions = [
              Reaction(
                trigger: TriggerModel(type: TriggerType.cursorEnter),
                action: SetVariableAction(
                  variable: VariableData(id: 'h', name: 'hoveredId'),
                  newValue: r'${item.id}',
                ),
              ),
            ];
      final BaseNode read = NodeJsonConverter().fromJson(
        encodeDecode(node.toJson()),
      )!;
      expect(
        (read as ReactionMixin).reactions.single.trigger.type,
        TriggerType.cursorEnter,
      );
    });
  });
}
