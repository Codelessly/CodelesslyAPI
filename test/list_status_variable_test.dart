import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a list keeps its status variable through JSON', () {
    final ListViewNode node = ListViewNode(
      id: 'list',
      name: 'Tasks',
      basicBoxLocal: NodeBox(0, 0, 300, 400),
      properties: ListViewProperties(),
      children: const [],
      useCloudDatabase: true,
      collectionPath: 'tasks',
      statusVariable: VariableData(id: 'v1', name: 'tasksStatus'),
    );
    final ListViewNode copy = ListViewNode.fromJson(node.toJson());
    expect(copy.statusVariable?.name, 'tasksStatus');
    expect(
      ListViewNode.fromJson({...node.toJson()..remove('statusVariable')})
          .statusVariable,
      isNull,
    );
  });
}
