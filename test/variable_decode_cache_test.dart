import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a list variable decodes once and reads the same list after', () {
    final VariableData tickets = VariableData(
      id: 't',
      name: 'tickets',
      type: VariableType.list,
      value: '[{"id":1},{"id":2}]',
    );
    final Object? first = tickets.getValue();
    expect(first, [
      {'id': 1},
      {'id': 2},
    ]);
    expect(identical(tickets.getValue(), first), isTrue);
  });

  test('a changed variable decodes its new value', () {
    final VariableData before = VariableData(
      id: 'd',
      name: 'drafts',
      type: VariableType.map,
      value: '{"1":{"text":"a"}}',
    );
    final VariableData after = before.copyWith(value: '{"1":{"text":"b"}}');
    expect(before.getValue(), {
      '1': {'text': 'a'},
    });
    expect(after.getValue(), {
      '1': {'text': 'b'},
    });
    expect(before.getValue(), {
      '1': {'text': 'a'},
    });
  });
}
