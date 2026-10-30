import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('native MP4 wire round-trip and defaults', () {
    final node = VideoNode(
      id: 'v',
      name: 'Video',
      basicBoxLocal: NodeBox(0, 0, 320, 180),
      properties: VideoProperties(
        url: 'https://media.example.com/clip.MP4?token=a%2Fb',
        autoPlay: true,
        showControls: false,
      ),
    );
    final json = node.toJson();
    expect(json['type'], 'video');
    final decoded = NodeJsonConverter.instance.fromJson(json) as VideoNode;
    expect(decoded.properties.url, node.properties.url);
    expect(decoded.properties.autoPlay, isTrue);
    expect(decoded.properties.showControls, isFalse);
    expect(VideoNode.empty().properties.toJson(), isNot(contains('url')));
    expect(
      NodeJsonConverter.instance.fromJson(EmbeddedVideoNode.empty().toJson()),
      isA<EmbeddedVideoNode>(),
    );
  });

  test('rejects unsafe or non-MP4 source syntax on input and decode', () {
    for (final url in [
      'http://media.example.com/a.mp4',
      'file:///a.mp4',
      'https://user:pass@media.example.com/a.mp4',
      'https://localhost/a.mp4',
      'https://127.0.0.1/a.mp4',
      'https://192.168.1.1/a.mp4',
      'https://172.16.0.1/a.mp4',
      'https://media.example.com/a.mp4#fragment',
      'https://media.example.com/a.m3u8',
    ]) {
      expect(
        () => VideoProperties(url: url),
        throwsFormatException,
        reason: url,
      );
      expect(
        () => VideoProperties.fromJson({'url': url}),
        throwsFormatException,
        reason: url,
      );
    }
    expect(
      () => (VideoProperties()..url = 'javascript:alert(1)').toJson(),
      throwsFormatException,
    );
  });
}
