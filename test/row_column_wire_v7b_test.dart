import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  for (final node in <RowColumnNode>[
    RowNode(
      id: 'r', name: 'Row', basicBoxLocal: NodeBox(0, 0, 120, 50),
      children: ['child'], spacing: 12, wrap: true, runSpacing: 6,
      padding: const EdgeInsetsModel.all(4),
    ),
    ColumnNode(
      id: 'c', name: 'Column', basicBoxLocal: NodeBox(0, 0, 50, 120),
      children: ['child'], spacing: 8, mainAxisAlignment: MainAxisAlignmentC.end,
      padding: const EdgeInsetsModel.all(5),
    ),
  ]) {
    test('${node.runtimeType} is the canonical Flutter class', () {
      final json = node.toJson();
      expect(json['type'], node is RowNode ? 'row' : 'column');
      final decoded = NodeJsonConverter.instance.fromJson(json);
      expect(decoded.runtimeType, node.runtimeType);
      expect((decoded as RowColumnNode).spacing, node.spacing);
      expect(decoded.childrenOrEmpty, node.childrenOrEmpty);
      expect(decoded.padding, node.padding);
      expect(decoded.toJson(), json);
      expect(() => NodeJsonConverter.instance.fromJson({...json, 'type': 'rowColumn'}),
          throwsUnsupportedError);
      expect(() => NodeJsonConverter.instance.fromJson({
        ...json, 'rowColumnType': node is RowNode ? 'column' : 'row',
      }), throwsFormatException);
    });
  }
}
