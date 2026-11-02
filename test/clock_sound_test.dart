import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a play sound action round-trips and omits defaults', () {
    final action = PlaySoundAction(
      sound: r'${voice}',
      volume: r'${= beat == 0 ? 1 : 0.6}',
      at: r'${result.at}',
    );
    final json = action.toJson();
    expect(json['type'], 'playSound');
    expect(json.containsKey('pitch'), isFalse);
    final back = ActionModel.fromJson(json);
    expect(back, isA<PlaySoundAction>());
    expect(back, action);
    expect(SoundVoice.values.map((v) => v.name), ['wood', 'beep', 'bell', 'rim', 'hat']);
  });

  test('a beat clock trigger keeps its interval, condition and lookahead', () {
    final trigger = TriggerModel(
      type: TriggerType.clock,
      every: r'${= 60000 / bpm}',
      runWhen: r'${playing}',
      lookaheadMs: 120,
    );
    final json = trigger.toJson();
    expect(json, {
      'type': 'clock',
      'every': r'${= 60000 / bpm}',
      'runWhen': r'${playing}',
      'lookaheadMs': 120,
    });
    expect(TriggerModel.fromJson(json), trigger);
    expect(TriggerModel.fromJson({'type': 'clock'}).lookaheadMs, 100);
    expect(TriggerType.clock.prettify, 'Beat Clock');
  });
}
