import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> _json(Map<String, dynamic> extra) => <String, dynamic>{
  'id': 'r',
  'name': 'Row',
  'type': 'rowColumn',
  'rowColumnType': 'row',
  'basicBoxLocal': <num>[0, 0, 100, 40],
  'children': <String>[],
  ...extra,
};

void main() {
  test('itemSpacing, an earlier name for spacing, is read as spacing', () {
    final RowColumnNode node = RowColumnNode.fromJson(
      _json(<String, dynamic>{'itemSpacing': 12}),
    );
    expect(node.spacing, 12);
    expect(node.toJson()['spacing'], 12);
    expect(node.toJson().containsKey('itemSpacing'), isFalse);
  });

  test('spacing wins over itemSpacing', () {
    final RowColumnNode node = RowColumnNode.fromJson(
      _json(<String, dynamic>{'itemSpacing': 12, 'spacing': 4}),
    );
    expect(node.spacing, 4);
  });
}
