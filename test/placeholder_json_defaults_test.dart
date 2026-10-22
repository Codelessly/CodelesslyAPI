import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('A list parses from hand-written JSON with only what it needs', () {
    for (final type in ['listView']) {
      final node = NodeJsonConverter().fromJson({
        'type': type,
        'id': 'x',
        'name': 'n',
        'basicBoxLocal': [0, 0, 100, 100],
        'children': ['item'],
        'properties': <String, dynamic>{},
      }) as SinglePlaceholderNode;
      expect(node.allowedTypes, isEmpty, reason: type);
      expect(node.deniedTypes, isEmpty, reason: type);
      expect((node as ListViewNode).isScrollable, isTrue);
      expect(node.useFlutterListView, isTrue);
    }
  });
}
