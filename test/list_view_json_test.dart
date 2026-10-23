import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a list view reads from JSON without allowed/denied types', () {
    final ListViewNode list = ListViewNode.fromJson({
      'type': 'listView',
      'id': 'list',
      'name': 'List',
      'basicBoxLocal': [0, 0, 300, 200],
      'children': ['row'],
      'properties': {},
    });
    expect(list.allowedTypes, isEmpty);
    expect(list.deniedTypes, isEmpty);
    expect(list.children, ['row']);
  });
}
