import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// A row or column is decoded as a RowColumnNode and copied into its Row or
/// Column class: every BaseNode field must survive the copy. ignorePointer
/// (accepted on texts, frames and rectangles) was dropped on rows and
/// columns, so insertTree refused it as a property they don't have.
void main() {
  for (final String type in <String>['row', 'column']) {
    test('$type keeps ignorePointer, keepAspect and floating', () {
      final BaseNode node = NodeJsonConverter().fromJson(<String, dynamic>{
        'type': type,
        'id': 'n',
        'name': 'N',
        'basicBoxLocal': <num>[0, 0, 10, 10],
        'children': <String>[],
        'ignorePointer': true,
        'keepAspect': 1.5,
        'floating': true,
      })!;
      expect(node.ignorePointer, isTrue);
      expect(node.keepAspect, 1.5);
      expect(node.floating, isTrue);
      final Map json = node.toJson();
      expect(json['ignorePointer'], isTrue);
      expect(json['keepAspect'], 1.5);
      expect(json['floating'], isTrue);
      // And through a change of axis.
      final RowColumnNode turned = (node as RowColumnNode).withAxis(
        type == 'row' ? RowColumnType.column : RowColumnType.row,
      );
      expect(turned.ignorePointer, isTrue);
    });
  }
}
