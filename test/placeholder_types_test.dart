import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a list view without type filters reads them as empty and still '
      'writes them', () {
    final ListViewNode list = ListViewNode.fromJson({
      'id': 'list',
      'name': 'Date strip',
      'type': 'listView',
      'basicBoxLocal': [0, 0, 100, 40],
      'isScrollable': true,
      'useFlutterListView': true,
      'properties': <String, dynamic>{},
    });
    expect(list.allowedTypes, isEmpty);
    expect(list.deniedTypes, isEmpty);
    final Map json = list.toJson();
    expect(json['allowedTypes'], isEmpty);
    expect(json.containsKey('deniedTypes'), isTrue);
  });
}
