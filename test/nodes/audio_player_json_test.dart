import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  final converter = NodeJsonConverter();
  final base = AudioPlayerNode.empty().toJson();

  test('audio player wire roundtrip preserves description and playback', () {
    for (final extension in ['mp3', 'm4a', 'wav']) {
      final wire = {
        ...base,
        'properties': {
          'url': 'https://media.example.com/song.$extension?token=abc',
          'description': 'Narrated introduction',
          'autoPlay': true,
          'showControls': false,
        },
      };
      final node = converter.fromJson(wire) as AudioPlayerNode;
      expect(node.type, 'audioPlayer');
      expect(node.properties.description, 'Narrated introduction');
      expect(node.properties.autoPlay, isTrue);
      expect(node.properties.showControls, isFalse);
      expect(
        (converter.fromJson(node.toJson()) as AudioPlayerNode).properties.url,
        'https://media.example.com/song.$extension?token=abc',
      );
    }
    expect(NodeJsonConverter.isNodeRegistered('audioPlayer'), isTrue);
  });

  test('constructor, decoder and encoder reject invalid audio URL', () {
    for (final url in [
      'http://media.example.com/song.mp3',
      'https://media.example.com/song.mp4',
      'https://localhost/song.wav',
      'https://127.0.0.1/song.mp3',
      'https://media.example.com/song.mp3#fragment',
      'https://user@media.example.com/song.mp3',
      'https://media.example.com/song.mp3 ',
    ]) {
      expect(() => AudioPlayerProperties(url: url), throwsFormatException);
      expect(
        () => converter.fromJson({
          ...base,
          'properties': {'url': url},
        }),
        throwsFormatException,
      );
    }
    final properties = AudioPlayerProperties()
      ..url = 'https://example.com/song.mp4';
    expect(() => properties.toJson(), throwsFormatException);
  });

  test('generated schema and BASIC mapping advertise verified bridge', () {
    final schema = jsonDecode(
      File('lib/src/api/nodes/audio_player_node.flutter_catalog.json')
          .readAsStringSync(),
    ) as Map;
    expect(schema, contains('AudioPlayerNode'));
    final catalog = jsonDecode(
      File('lib/src/schema/generated/codelessly_a2ui_catalog.json')
          .readAsStringSync(),
    ) as Map;
    expect((catalog['components'] as Map), contains('CodelesslyAudioPlayer'));
    final mapping = jsonDecode(
      File('lib/src/schema/generated/basic_node_mappings.json')
          .readAsStringSync(),
    ) as Map;
    expect((mapping['mappings'] as Map)['AudioPlayer'], {
      'nodeType': 'audioPlayer',
      'bridgeStatus': 'ready',
    });
  });
}
