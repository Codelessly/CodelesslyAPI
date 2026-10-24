import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a delay keeps its duration formula through JSON', () {
    final DelayAction action = DelayAction(
      milliseconds: 900,
      duration: r"${= networkMode == 'slow' ? 4000 : 900}",
    );
    final DelayAction read =
        ActionModel.fromJson(action.toJson()) as DelayAction;
    expect(read.duration, action.duration);
    expect(read.milliseconds, 900);
  });

  test('a delay without a formula leaves duration out of its JSON', () {
    expect(
      DelayAction(milliseconds: 300).toJson().containsKey('duration'),
      isFalse,
    );
    expect(
      DelayAction(duration: 'x').copyWith(clearDuration: true).duration,
      isNull,
    );
  });
}
