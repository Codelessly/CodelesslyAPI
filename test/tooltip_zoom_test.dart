import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('tooltip and zoomable round-trip and are omitted by default', () {
    final RectangleNode node = RectangleNode(
      id: 'photo',
      name: 'Photo',
      basicBoxLocal: NodeBox(0, 0, 10, 10),
    );
    expect(node.toJson().containsKey('tooltip'), isFalse);
    expect(node.toJson().containsKey('zoomable'), isFalse);
    node
      ..tooltip = r'Taken by ${item.author}'
      ..zoomable = true;
    final BaseNode back = NodeJsonConverter().fromJson(node.toJson())!;
    expect(back.tooltip, r'Taken by ${item.author}');
    expect(back.zoomable, isTrue);
  });
}
