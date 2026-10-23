import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  TextNode text({bool tabular = false}) => TextNode(
    id: 't',
    name: 'Clock',
    basicBoxLocal: NodeBox(0, 0, 100, 40),
    characters: '1:48:00',
    tabularFigures: tabular,
  );

  test('tabular figures survive JSON and are left out when off', () {
    final Map json = text(tabular: true).toJson();
    expect(json['tabularFigures'], isTrue);
    expect(TextNode.fromJson(json).tabularFigures, isTrue);

    expect(text().toJson().containsKey('tabularFigures'), isFalse);
    final Map old = text().toJson()..remove('tabularFigures');
    expect(TextNode.fromJson(old).tabularFigures, isFalse);
  });
}
