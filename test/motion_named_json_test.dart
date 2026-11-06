import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// Values named in an enterFrom come back as the values themselves, not as
/// a `named` list (a generated serializer once wrote one).
void main() {
  test('named values are written as values, with no named key', () {
    final MotionModel m = MotionModel.fromJson({'opacity': 0, 'enterFrom': {'opacity': 1, 'scale': 1}});
    expect(m.enterFrom!.named, {'opacity', 'scale'});
    expect(m.toJson()['enterFrom'], {'opacity': 1.0, 'scale': 1.0});
    expect(m.toJson().containsKey('named'), isFalse);
  });
}
