import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a row or column made from type row/column keeps ignorePointer, keepAspect and floating', () {
    for (final String type in <String>['row', 'column']) {
      final BaseNode? node = NodeJsonConverter().fromJson(<String, dynamic>{
        'type': type,
        'id': 'n',
        'name': 'Layer',
        'basicBoxLocal': <double>[0, 0, 100, 100],
        'ignorePointer': true,
        'keepAspect': 1.5,
        'floating': true,
      });
      expect(node, isA<RowColumnNode>());
      expect(node!.ignorePointer, isTrue, reason: type);
      expect(node.keepAspect, 1.5, reason: type);
      expect(node.floating, isTrue, reason: type);
      expect(node.toJson()['ignorePointer'], isTrue, reason: type);
    }
  });
}
