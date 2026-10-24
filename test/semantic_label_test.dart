import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  RectangleNode button() => RectangleNode(
    id: 'signIn',
    name: 'Sign in button',
    basicBoxLocal: NodeBox(0, 0, 120, 48),
  );

  test('semanticLabel is left out of the JSON when empty', () {
    final RectangleNode node = button();
    expect(node.semanticLabel, '');
    expect(node.toJson().containsKey('semanticLabel'), isFalse);
  });

  test('semanticLabel round-trips through the JSON', () {
    final RectangleNode node = button()..semanticLabel = r'Sign in ${name}';
    final Map json = node.toJson();
    expect(json['semanticLabel'], r'Sign in ${name}');
    final BaseNode back = NodeJsonConverter().fromJson(json)!;
    expect(back.semanticLabel, r'Sign in ${name}');
  });

  test('semanticLabel is read from node JSON of any type', () {
    final BaseNode? text = NodeJsonConverter().fromJson({
      ...TextNode(
        id: 'label',
        name: 'Label',
        basicBoxLocal: NodeBox(0, 0, 80, 20),
        characters: 'START PRE-TRIP',
        textMixedProps: [],
      ).toJson(),
      'semanticLabel': 'Start pre-trip',
    });
    expect(text!.semanticLabel, 'Start pre-trip');
  });

  test('semanticLabel is a bindable string field', () {
    final RectangleNode node = button();
    final FieldAccess<Object?>? field = node.fields['semanticLabel'];
    expect(field, isA<StringFieldAccess>());
    field!.setValue('Sign in');
    expect(node.semanticLabel, 'Sign in');
    expect(field.getValue(), 'Sign in');
  });
}
