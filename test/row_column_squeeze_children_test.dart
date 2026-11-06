import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// A row/column can let its content overflow instead of shrinking it to fit
/// (Safecracker's mobile vault column is 2 px taller than its screen, as the
/// code-built reference lays it out).
void main() {
  RowColumnNode column() => RowColumnNode(
        id: 'c',
        name: 'c',
        basicBoxLocal: NodeBox(0, 0, 100, 100),
        children: const [],
        rowColumnType: RowColumnType.column,
      );

  test('squeezeChildren defaults to true and is left out of the JSON', () {
    final RowColumnNode node = column();
    expect(node.squeezeChildren, isTrue);
    expect(node.toJson().containsKey('squeezeChildren'), isFalse);
  });

  test('false round-trips, through the column a row/column decodes as', () {
    final RowColumnNode node = column()..squeezeChildren = false;
    final Map json = node.toJson();
    expect(json['squeezeChildren'], isFalse);
    final BaseNode back = NodeJsonConverter().fromJson(json)!;
    expect(back, isA<RowColumnNode>());
    expect((back as RowColumnNode).squeezeChildren, isFalse);
  });
}
