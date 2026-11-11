import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('naturalHeight round-trips, merges and is declared', () {
    final s = TextStyle.fromJson({'fontSize': 15, 'naturalHeight': true});
    expect(s.naturalHeight, isTrue);
    expect(s.toJson(), {'fontSize': 15.0, 'naturalHeight': true});
    expect(TextStyle.fromJson(s.toJson()), s);
    expect(const TextStyle(fontSize: 12).merge(s).naturalHeight, isTrue);
    expect(s.merge(const TextStyle(color: Color(0xFF000000))).naturalHeight, isTrue);
    expect(s.merge(const TextStyle(naturalHeight: false)).naturalHeight, isFalse);
    expect(s == const TextStyle(fontSize: 15), isFalse);
    expect(TextStyleFields.all.map((f) => f.key), contains('naturalHeight'));
  });
}
