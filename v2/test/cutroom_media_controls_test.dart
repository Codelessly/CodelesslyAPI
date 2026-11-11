import 'package:codelessly_api_v2/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('media controls are optional and preserve legacy sparse documents', () {
    for (final type in ['video', 'audioPlayer']) {
      final n = Node.fromJson({'type': type})!;
      expect(n.toJson()['props'], isNull);
      if (type == 'video') {
        expect(n.prop(VideoProps.playing), isNull);
        expect(n.prop(VideoProps.positionSeconds), isNull);
      } else {
        expect(n.prop(AudioPlayerProps.playing), isNull);
        expect(n.prop(AudioPlayerProps.positionSeconds), isNull);
      }
    }
  });
  test('video and audio seek/play props round-trip and clamp source time and volume', () {
    for (final type in ['video', 'audioPlayer']) {
      final n = Node.fromJson({
        'type': type,
        'props': {'playing': false, 'positionSeconds': 2.375, 'volume': .4, 'loop': true},
      })!;
      expect(Node.fromJson(n.toJson()), n);
      expect((n.toJson()['props'] as Map)['positionSeconds'], 2.375);
      final invalid = Node.fromJson({
        'type': type,
        'props': {'positionSeconds': -5, 'volume': 4},
      })!;
      expect(
        type == 'video' ? invalid.prop(VideoProps.positionSeconds) : invalid.prop(AudioPlayerProps.positionSeconds),
        0,
      );
      expect(type == 'video' ? invalid.prop(VideoProps.volume) : invalid.prop(AudioPlayerProps.volume), 1);
    }
  });
}
