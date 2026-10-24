import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// Encodes [node] to JSON text and reads it back through the registry, the
/// way a stored layout is loaded.
BaseNode roundTrip(BaseNode node) => NodeJsonConverter.instance.fromJson(
  jsonDecode(jsonEncode(node.toJson())) as Map,
)!;

void main() {
  test('a default signature pad writes only what it needs', () {
    final json = SignatureNode.empty().toJson();
    expect(json['type'], 'signature');
    expect(json.containsKey('value'), isFalse);
    expect(json['properties'], isEmpty);

    final read = roundTrip(SignatureNode.empty()) as SignatureNode;
    expect(read.value, isEmpty);
    expect(read.properties, SignatureProperties());
    expect(read.basicBoxLocal.width, kSignatureDefaultWidth);
    expect(read.basicBoxLocal.height, kSignatureDefaultHeight);
  });

  test('a signature pad keeps its strokes, properties and bindings', () {
    final node = SignatureNode(
      id: 'sig',
      name: 'Signature',
      basicBoxLocal: NodeBox(0, 0, 320, 140),
      value: [
        [
          [10, 20],
          [30.5, 40],
        ],
        [
          [50, 60],
        ],
      ],
      variables: {'value': r'${signature}', 'error': r'${signatureError}'},
      reactions: [
        Reaction(
          trigger: TriggerModel(type: TriggerType.changed),
          action: SetVariableAction(
            variable: VariableData(id: 'signed', name: 'signed'),
            newValue: 'true',
          ),
        ),
      ],
      properties: SignatureProperties(
        inkColor: ColorRGBA.black,
        inkWidth: 3,
        placeholder: 'Sign',
        showSignLine: false,
        error: true,
        enabled: false,
      ),
    );

    final read = roundTrip(node) as SignatureNode;
    expect(read.value, node.value);
    expect(read.properties, node.properties);
    expect(read.variables, node.variables);
    expect(read.reactions.single.trigger.type, TriggerType.changed);
    expect(read.triggerTypes, [TriggerType.changed]);
    expect(read.toJson(), node.toJson());
    expect(
      read.propertyVariables.map((value) => value.name),
      containsAll(['value', 'error', 'enabled']),
    );
  });

  test('strokes skip malformed points', () {
    expect(
      strokesFromJson([
        [
          [1, 2],
          ['x', 3],
          [4],
        ],
        'nope',
      ]),
      [
        [
          [1.0, 2.0],
        ],
      ],
    );
    expect(strokesFromJson(null), isEmpty);
  });
}
