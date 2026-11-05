import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> textJson({Object? padding, Object? margin}) => {
    'id': 't',
    'name': 'answer',
    'type': 'text',
    'data': 'A queue moves messages between services you own.',
    'basicBoxLocal': [0, 0, 748, 128],
    'padding': ?padding,
    'margin': ?margin,
  };

  test('a padding stored on a text node pads nothing', () {
    final TextNode node = TextNode.fromJson(textJson(padding: [48, 0, 64, 24]));
    // The stored value round-trips; it just has no effect on layout.
    expect(node.padding, isNot(EdgeInsetsModel.zero));
    expect(node.resolvedPadding(), EdgeInsetsModel.zero);
    expect(node.innerBoxLocal.horizontalEdgeSpace, 0);
    expect(node.innerBoxLocal.verticalEdgeSpace, 0);
    expect(node.innerBoxLocal.width, node.basicBoxLocal.width);
    expect(node.innerBoxLocal.height, node.basicBoxLocal.height);
  });

  test('margin still spaces a text node', () {
    final TextNode node = TextNode.fromJson(textJson(margin: [48, 0, 64, 24]));
    expect(node.outerBoxLocal.horizontalEdgeSpace, 112);
    expect(node.outerBoxLocal.verticalEdgeSpace, 24);
  });

  test('padding still pads a node that supports it', () {
    final RowColumnNode node = RowColumnNode.fromJson({
      'id': 'c',
      'name': 'column',
      'type': 'column',
      'basicBoxLocal': [0, 0, 200, 100],
      'padding': [10, 0, 10, 0],
      'children': <String>[],
    });
    expect(node.resolvedPadding().horizontal, 20);
    expect(node.innerBoxLocal.width, 180);
  });
}
