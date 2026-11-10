import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('ids generated in a tight loop are unique and strictly increasing', () {
    final List<String> ids = <String>[
      for (int i = 0; i < 20000; i++) generateId(),
    ];
    expect(ids.toSet(), hasLength(ids.length));
    for (int i = 1; i < ids.length; i++) {
      expect(
        ids[i].compareTo(ids[i - 1]),
        greaterThan(0),
        reason: '${ids[i]} should sort after ${ids[i - 1]}',
      );
    }
    expect(ids.every((String id) => id.length == 20), isTrue);
  });
}
