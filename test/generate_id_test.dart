import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('IDs generated in a tight loop are unique and strictly increasing', () {
    final List<String> ids = List<String>.generate(10000, (_) => generateId());

    expect(ids.toSet(), hasLength(ids.length));
    for (int i = 1; i < ids.length; i++) {
      expect(
        ids[i].compareTo(ids[i - 1]),
        greaterThan(0),
        reason: '${ids[i]} should sort after ${ids[i - 1]}',
      );
    }
  });

  test('IDs are 20 characters', () {
    expect(generateId(), hasLength(20));
  });
}
