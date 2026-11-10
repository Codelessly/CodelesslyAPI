import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// [NodeProcessor.resolveConstraints] applies the constraints a parent hands
/// its children ([BaseNode.relegatedConstraintsToChildren]), e.g. a
/// ListTile's minimum leading width.
void main() {
  final Map<String, BaseNode> nodes = <String, BaseNode>{};

  setUp(() {
    nodes.clear();
    NodeProcessor.registerNodeGetter((String id) => nodes[id]!);
  });

  RectangleNode rect(String id, String parentID, {BoxConstraintsModel? c}) =>
      RectangleNode(
        id: id,
        name: id,
        basicBoxLocal: NodeBox(0, 0, 24, 24),
        constraints: c ?? const BoxConstraintsModel(),
      )..parentID = parentID;

  test('a ListTile\'s minLeadingWidth reaches its leading node', () {
    final ListTileNode tile = ListTileNode(
      id: 'tile',
      name: 'tile',
      basicBoxLocal: NodeBox(0, 0, 300, 56),
      leading: 'leading',
      properties: ListTileProperties(minLeadingWidth: 40),
      children: <String>['leading'],
    )..parentID = kRootNode;
    nodes['tile'] = tile;
    nodes['leading'] = rect('leading', 'tile');

    final BoxConstraintsModel resolved = NodeProcessor.resolveConstraints(
      nodes['leading']!,
    );
    expect(resolved.minWidth, 40);
  });

  test('relegated and own constraints combine to the tighter of each', () {
    final ListTileNode tile = ListTileNode(
      id: 'tile',
      name: 'tile',
      basicBoxLocal: NodeBox(0, 0, 300, 56),
      leading: 'leading',
      properties: ListTileProperties(minLeadingWidth: 40),
      children: <String>['leading'],
    )..parentID = kRootNode;
    nodes['tile'] = tile;
    nodes['leading'] = rect(
      'leading',
      'tile',
      c: const BoxConstraintsModel(minWidth: 56, maxWidth: 80),
    );

    final BoxConstraintsModel resolved = NodeProcessor.resolveConstraints(
      nodes['leading']!,
    );
    expect(resolved.minWidth, 56);
    expect(resolved.maxWidth, 80);
  });
}
