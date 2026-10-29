import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  final nodes = <ButtonNode>[
    ElevatedButtonNode.empty(),
    TextButtonNode.empty(),
    OutlinedButtonNode.empty(),
    IconButtonNode.empty(),
    FilledButtonNode.empty(),
    FilledButtonNode.tonal(
      id: 'tonal',
      name: 'Tonal',
      basicBoxLocal: NodeBox(0, 0, 40, 20),
    ),
  ];

  for (final node in nodes) {
    test('${node.runtimeType} has strict wire identity', () {
      final json = node.toJson();
      expect(json['type'], node.type);
      expect(json['properties']['buttonType'], node.properties.buttonType.name);
      final restored = ButtonNode.fromJson(json);
      expect(restored.runtimeType, node.runtimeType);
      expect(restored.toJson()['type'], node.type);
      expect(
        () => ButtonNode.fromJson({...json, 'type': 'button'}),
        throwsFormatException,
      );
      expect(
        () => ButtonNode.fromJson({...json, 'type': 'anotherButton'}),
        throwsFormatException,
      );
      expect(
        () => ButtonNode.fromJson({
          ...json,
          'properties': {...json['properties'], 'buttonType': 'incorrect'},
        }),
        throwsFormatException,
      );
    });
  }

  test('shape does not determine icon button identity', () {
    final node = ElevatedButtonNode(
      id: 'circle',
      name: 'Circle',
      basicBoxLocal: NodeBox(0, 0, 40, 40),
      properties: ButtonProperties(shape: CShapeBorder.circle),
    );
    expect(node.behavesLikeAnIconButton, isFalse);
    expect(ButtonNode.fromJson(node.toJson()), isA<ElevatedButtonNode>());
  });
}
