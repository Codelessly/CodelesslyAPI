import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('paired stroke sides and a stretching table round-trip', () {
    final box = Node.fromJson({'type': 'box', 'decoration': {'strokes': [{'type': 'solid', 'color': 'FF000000'}], 'strokeSides': 'topBottom'}}, id: 'b')!;
    expect(box.decoration.strokeSides, StrokeSides.topBottom);
    expect(Node.fromJson(box.toJson(), id: 'b')!.decoration.strokeSides, StrokeSides.topBottom);
    expect(Node.fromJson({'type': 'box', 'decoration': {'strokeSides': 'leftRight'}}, id: 'c')!.decoration.strokeSides, StrokeSides.leftRight);
    final table = Node.fromJson({'type': 'tableView', 'props': {'stretchLastColumn': true}}, id: 't')!;
    expect(table.prop(TableViewProps.stretchLastColumn), isTrue);
    expect(Node.fromJson({'type': 'tableView'}, id: 'u')!.prop(TableViewProps.stretchLastColumn), isFalse);
  });
}
