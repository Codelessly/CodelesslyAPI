import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// [NodeProcessor.resolveConstraints] must union the parent's
/// [BaseNode.relegatedConstraintsToChildren] into the child's resolved
/// constraints. It used to union the child's constraints with themselves,
/// so a ListTile's minimum leading width or a ListView's item extent never
/// reached the child.
void main() {
  final Map<String, BaseNode> nodes = <String, BaseNode>{};

  setUp(() {
    nodes.clear();
    NodeProcessor.registerNodeGetter((String id) => nodes[id]!);
  });

  RectangleNode child(String parentID, {BoxConstraintsModel? constraints}) {
    final RectangleNode node = RectangleNode(
      id: 'child',
      name: 'child',
      basicBoxLocal: NodeBox(0, 0, 10, 10),
      constraints: constraints ?? const BoxConstraintsModel(),
    );
    node.parentID = parentID;
    nodes[node.id] = node;
    return node;
  }

  test('a ListTile relegates its minLeadingWidth to the leading node', () {
    final RectangleNode leading = child('tile');
    nodes['tile'] = ListTileNode(
      id: 'tile',
      name: 'tile',
      basicBoxLocal: NodeBox(0, 0, 300, 65),
      leading: leading.id,
      properties: ListTileProperties(minLeadingWidth: 56),
      children: <String>[leading.id],
    );

    final BoxConstraintsModel resolved = NodeProcessor.resolveConstraints(
      leading,
    );
    expect(resolved.minWidth, 56);
  });

  test('a ListView caps its children at the item extent', () {
    final RectangleNode item = child(
      'list',
      constraints: const BoxConstraintsModel(maxHeight: 200),
    );
    nodes['list'] = ListViewNode(
      id: 'list',
      name: 'list',
      basicBoxLocal: NodeBox(0, 0, 300, 400),
      properties: ListViewProperties(itemExtent: 80),
      children: <String>[item.id],
    );

    final BoxConstraintsModel resolved = NodeProcessor.resolveConstraints(item);
    // The tighter of the child's own max (200) and the relegated one (80).
    expect(resolved.maxHeight, 80);
  });
}
