import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// Nodes built from hand-written JSON (the editor's insertTree command, AI
/// tools) may leave out fields that have constructor defaults.
void main() {
  const box = {
    'id': 'n',
    'name': 'n',
    'basicBoxLocal': [0, 0, 100, 100],
  };

  test('a grid view needs only its delegate', () {
    final node = GridViewNode.fromJson({
      ...box,
      'type': 'gridView',
      'properties': {
        'gridDelegate': {'type': 'fixedCrossAxisCount', 'crossAxisCount': 3},
      },
    });
    expect(node.isScrollable, isTrue);
    expect(node.useFlutterListView, isFalse);
  });

  test('a grid view keeps scrolling fields it is given', () {
    final node = GridViewNode.fromJson({
      ...box,
      'type': 'gridView',
      'isScrollable': false,
      'properties': {
        'gridDelegate': {'type': 'fixedCrossAxisCount', 'crossAxisCount': 3},
      },
    });
    expect(node.isScrollable, isFalse);
  });

  test('list, page and tab views and spacers parse from minimal JSON', () {
    expect(
      ListViewNode.fromJson({...box, 'type': 'listView', 'properties': {}})
          .useFlutterListView,
      isTrue,
    );
    expect(
      PageViewNode.fromJson({...box, 'type': 'pageView', 'properties': {}})
          .isScrollable,
      isTrue,
    );
    expect(
      SpacerNode.fromJson({...box, 'type': 'spacer'}).aspectRatioLock,
      isFalse,
    );
  });
}
