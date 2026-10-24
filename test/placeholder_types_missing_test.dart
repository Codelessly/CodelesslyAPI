import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('placeholders read JSON that leaves out empty type lists', () {
    for (final String type in ['variance', 'listView', 'gridView']) {
      final Map<String, dynamic> json = {
        'type': type,
        'id': 'x',
        'name': 'n',
        'basicBoxLocal': [0, 0, 100, 100],
        'children': <String>[],
        'properties': <String, dynamic>{},
        if (type == 'variance') ...{
          'variants': [
            {'id': 'default', 'name': 'Default', 'children': <String>[]},
          ],
          'currentVariantId': 'default',
        },
        if (type == 'gridView')
          'properties': {
            'gridDelegate': {
              'type': 'fixedCrossAxisCount',
              'crossAxisCount': 2,
            },
          },
      };
      json.remove('allowedTypes');
      json.remove('deniedTypes');
      final node = NodeJsonConverter().fromJson(json) as SinglePlaceholderNode;
      expect(node.allowedTypes, isEmpty, reason: type);
      // A list keeps its own default; a variance reads it as empty.
      if (type == 'variance') expect(node.deniedTypes, isEmpty);
      if (type == 'listView') expect(node.deniedTypes, ['listView']);
    }
  });
}
