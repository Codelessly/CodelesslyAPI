import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('IconNode', () {
    test('leaves its click reactions to the renderer', () {
      final IconNode node = IconNode(
        id: 'gear',
        name: 'Settings',
        basicBoxLocal: NodeBox(0, 0, 16, 16),
      );
      // An icon has no tap callback of its own: the renderer must wrap it
      // with its reactions, as it does a rectangle.
      expect(node.handlesDefaultReactionsInternally, isFalse);
    });

    test('keeps its click reactions through JSON', () {
      final IconNode node = IconNode(
        id: 'gear',
        name: 'Settings',
        basicBoxLocal: NodeBox(0, 0, 16, 16),
        reactions: [
          Reaction(
            trigger: TriggerModel(type: TriggerType.click),
            action: SetVariableAction(
              variable: VariableData(id: 'toast', name: 'toast'),
              newValue: 'Settings',
            ),
          ),
        ],
      );
      final IconNode read =
          NodeJsonConverter.instance.fromJson(
                jsonDecode(jsonEncode(node.toJson())) as Map,
              )!
              as IconNode;
      expect(read.reactions, hasLength(1));
      expect(read.reactions.single.trigger.type, TriggerType.click);
    });
  });
}
