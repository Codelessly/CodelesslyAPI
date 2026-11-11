import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a table view keeps its decoration', () {
    expect(TableViewProps.spec.decorated, isTrue);
    final n = Node.fromJson({
      'type': 'tableView',
      'decoration': {
        'radius': 14,
        'strokes': [{'color': '#FFD3CDC0'}],
      },
    }, id: 't')!;
    expect(n.decoration.radius.isZero, isFalse);
    expect(n.decoration.strokes, hasLength(1));
  });
}
