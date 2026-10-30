import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('list JSON keeps its item types', () {
    expect('["", "02134", "12", "true", 3, null]'.toList(), ['', '02134', '12', 'true', 3, null]);
    expect('["wK", "", "bQ"]'.toSet(), {'wK', '', 'bQ'});
  });

  test('a list variable of piece codes keeps its empty squares', () {
    final board = VariableData(id: 'b', name: 'board', type: VariableType.list, value: '["wK", "", "bQ"]');
    expect(board.getValue(), ['wK', '', 'bQ']);
  });

  test('typed list conversions still read text as numbers', () {
    expect('["1", "2"]'.toList<List<int?>>(), [1, 2]);
  });
}
