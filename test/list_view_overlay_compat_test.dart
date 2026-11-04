import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a list saved with overlay reads as a positional stack', () {
    final ListViewProperties props = ListViewProperties.fromJson(
      <String, dynamic>{'overlay': true},
    );
    expect(props.layout, ListLayout.stack);
    expect(props.stacked, isFalse);
  });

  test('overlay does not override a layout or a centered deck', () {
    expect(
      ListViewProperties.fromJson(<String, dynamic>{
        'overlay': true,
        'layout': 'list',
      }).layout,
      ListLayout.list,
    );
    final ListViewProperties deck = ListViewProperties.fromJson(
      <String, dynamic>{'overlay': true, 'stacked': true},
    );
    expect(deck.layout, ListLayout.list);
    expect(deck.stacked, isTrue);
  });
}
