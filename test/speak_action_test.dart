import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a speak action round-trips through JSON', () {
    final SpeakAction action = SpeakAction(
      text: r'${route.phrase.text}',
      language: r'${route.phrase.lang}',
      rate: r'${= slow ? 0.6 : 1}',
      pitch: '1.2',
    );
    final Map json = action.toJson();
    expect(json['type'], 'speak');
    final ActionModel read = ActionModel.fromJson(json);
    expect(read, isA<SpeakAction>());
    expect(read, action);
    expect(read.type, ActionType.speak);
  });

  test('defaults are omitted and restored', () {
    final Map json = SpeakAction().toJson();
    expect(json, {'type': 'speak'});
    final SpeakAction read = ActionModel.fromJson(json) as SpeakAction;
    expect(read.text, '');
    expect(read.language, '');
    expect(read.rate, '1');
    expect(read.pitch, isNull);
    expect(read.stop, isFalse);
  });

  test('numeric rate and pitch are read as strings', () {
    final SpeakAction read =
        ActionModel.fromJson({
              'type': 'speak',
              'text': 'شكرا',
              'language': 'ar-EG',
              'rate': 0.6,
              'pitch': 1,
            })
            as SpeakAction;
    expect(read.rate, '0.6');
    expect(read.pitch, '1');
    expect(read.language, 'ar-EG');
  });

  test('a stop action keeps its flag', () {
    final ActionModel read = ActionModel.fromJson(
      SpeakAction(stop: true).toJson(),
    );
    expect((read as SpeakAction).stop, isTrue);
  });
}
