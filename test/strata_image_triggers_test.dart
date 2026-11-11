import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('image lifecycle triggers round trip as distinct non-pointer reactions', () {
    for (final type in [TriggerType.imageLoading, TriggerType.imageLoaded, TriggerType.imageError]) {
      final trigger = Trigger.fromJson({'type': type.name})!;
      expect(trigger.type, type);
      expect(trigger.toJson()['type'], type.name);
      expect(TriggerType.pointer, isNot(contains(type)));
    }
  });
}
