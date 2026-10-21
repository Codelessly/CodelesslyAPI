import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// [NodeProcessor.updateNode] rewrites a node's set pins from its box only
/// where the pins position the node: a freeform child with no alignment.
/// A row or column places its children, and an aligned child is placed by
/// its alignment, so a box change must not write pins for them (a column's
/// children got `top: 890` and `top: 1780` that way, and margins gave
/// `top: -6`).
void main() {
  final Map<String, BaseNode> nodes = <String, BaseNode>{};

  setUp(() {
    nodes.clear();
    NodeProcessor.registerNodeGetter((String id) => nodes[id]!);
  });

  T add<T extends BaseNode>(T node, String parentID) {
    node.parentID = parentID;
    nodes[node.id] = node;
    final BaseNode? parent = nodes[parentID];
    if (parent is ChildrenMixin) parent.children.add(node.id);
    return node;
  }

  RootNode root() {
    final RootNode root = RootNode(children: <String>[]);
    nodes[root.id] = root;
    NodeProcessor.updateNode(node: root);
    return root;
  }

  RectangleNode rect(
    String id, {
    EdgePinsModel pins = EdgePinsModel.standard,
    AlignmentModel alignment = AlignmentModel.none,
    EdgeInsetsModel margin = EdgeInsetsModel.zero,
  }) => RectangleNode(
    id: id,
    name: id,
    basicBoxLocal: NodeBox(0, 0, 100, 40),
    edgePins: pins,
    alignment: alignment,
    margin: margin,
  );

  test('a column child keeps its pins when its box moves', () {
    root();
    final RowColumnNode column = add(
      RowColumnNode(
        id: 'column',
        name: 'column',
        basicBoxLocal: NodeBox(0, 0, 400, 2670),
        rowColumnType: RowColumnType.column,
        children: <String>[],
      ),
      kRootNode,
    );
    NodeProcessor.updateNode(node: nodes.values.last);
    final RectangleNode child = add(
      rect('child', margin: const EdgeInsetsModel.only(top: 6)),
      column.id,
    );
    NodeProcessor.updateNode(node: nodes.values.last);
    expect(child.edgePins, EdgePinsModel.standard);

    NodeProcessor.updateNode(
      node: child,
      basicBoxLocal: NodeBox(24, 890, 342, 40),
    );
    expect(child.edgePins, EdgePinsModel.standard);
    NodeProcessor.updateNode(
      node: child,
      margin: const EdgeInsetsModel.only(top: 16),
    );
    expect(child.edgePins, EdgePinsModel.standard);
  });

  test('an aligned child in a frame keeps its pins when its box moves', () {
    root();
    final FrameNode frame = add(
      FrameNode(
        id: 'frame',
        name: 'frame',
        basicBoxLocal: NodeBox(0, 0, 400, 800),
        children: <String>[],
      ),
      kRootNode,
    );
    NodeProcessor.updateNode(node: nodes.values.last);
    final RectangleNode child = add(
      rect('child', alignment: AlignmentModel.center),
      frame.id,
    );
    NodeProcessor.updateNode(node: nodes.values.last);

    NodeProcessor.updateNode(
      node: child,
      basicBoxLocal: NodeBox(150, 380, 100, 40),
    );
    expect(child.edgePins, EdgePinsModel.standard);
  });

  test('a freeform child still has its pins follow its box', () {
    root();
    final FrameNode frame = add(
      FrameNode(
        id: 'frame',
        name: 'frame',
        basicBoxLocal: NodeBox(0, 0, 400, 800),
        children: <String>[],
      ),
      kRootNode,
    );
    NodeProcessor.updateNode(node: nodes.values.last);
    final RectangleNode child = add(
      rect(
        'child',
        pins: const EdgePinsModel(left: 0, top: 0, right: 0, bottom: null),
      ),
      frame.id,
    );
    NodeProcessor.updateNode(node: nodes.values.last);

    NodeProcessor.updateNode(
      node: child,
      basicBoxLocal: NodeBox(20, 30, 300, 40),
    );
    expect(
      child.edgePins,
      const EdgePinsModel(left: 20, top: 30, right: 80, bottom: null),
    );
    expect(NodeProcessor.edgePinsPosition(child, frame), isTrue);
  });
}
