import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// A scrolling row/column clips its content unless `clipsScrollContent` is
/// false, which round-trips through JSON (rows and columns alike).
void main() {
  RowColumnNode column() => RowColumnNode(
    id: 'col',
    name: 'Column',
    basicBoxLocal: NodeBox(0, 0, 200, 300),
    children: const [],
    rowColumnType: RowColumnType.column,
    isScrollable: true,
  );

  test('clipsScrollContent defaults to true and is omitted from JSON', () {
    final RowColumnNode node = column();
    expect(node.clipsScrollContent, isTrue);
    final Map json = node.toJson();
    expect(json.containsKey('clipsScrollContent'), isFalse);
    expect(
      RowColumnNode.fromJson(Map<String, dynamic>.from(json))
          .clipsScrollContent,
      isTrue,
    );
  });

  test('clipsScrollContent false round-trips for columns and rows', () {
    for (final String type in ['column', 'row']) {
      final Map json = {
        ...column().toJson(),
        'type': type,
        'rowColumnType': type,
        'clipsScrollContent': false,
      };
      final RowColumnNode node = RowColumnNode.fromJson(json);
      expect(node.clipsScrollContent, isFalse, reason: type);
      expect(node.toJson()['clipsScrollContent'], isFalse, reason: type);
      expect(
        node.withAxis(RowColumnType.row).clipsScrollContent,
        isFalse,
        reason: type,
      );
    }
  });

  test('clipsScrollContent is a field', () {
    final RowColumnNode node = column();
    final field = node.fields['clipsScrollContent']!;
    expect(field.getValue(), isTrue);
    field.setValue(false);
    expect(node.clipsScrollContent, isFalse);
  });
}
