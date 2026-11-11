import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('note, duration and instrument waveforms round-trip, sparse', () {
    const a = PlaySoundAction(operation: 'start', voiceId: 'k60', waveform: 'felt', note: r'${item.midi}', duration: '1600');
    final json = a.toJson();
    expect(json['note'], r'${item.midi}');
    expect(json['duration'], '1600');
    expect(json['waveform'], 'felt');
    final back = ActionDef.fromJson(json) as PlaySoundAction;
    expect(back, a);
    expect(back.note, r'${item.midi}');
    expect(back.duration, '1600');
    expect(const PlaySoundAction().toJson().keys, isNot(containsAll(['note', 'duration'])));
  });

  test('the action panel lists waveform, note and duration', () {
    final names = PlaySoundFields.all.map((f) => f.key).toList();
    expect(names, containsAll(['waveform', 'note', 'duration']));
  });
}
