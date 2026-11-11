import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('embedded playback controls are optional, sparse and bounded', () {
    final legacy = Node.fromJson({'type': 'embeddedVideo'})!;
    expect(legacy.prop(EmbeddedVideoProps.playing), isNull);
    expect(legacy.prop(EmbeddedVideoProps.positionSeconds), isNull);
    expect(legacy.prop(EmbeddedVideoProps.volume), isNull);
    expect(legacy.toJson()['props'], isNull);
    final n = Node.fromJson({
      'type': 'embeddedVideo',
      'props': {'playing': false, 'positionSeconds': 2.375, 'volume': .4},
    })!;
    expect(Node.fromJson(n.toJson()), n);
    expect(BindPaths.apply(n, 'props.playing', 'true').prop(EmbeddedVideoProps.playing), true);
    final bounded = Node.fromJson({
      'type': 'embeddedVideo',
      'props': {'positionSeconds': -1, 'volume': 4},
    })!;
    expect(bounded.prop(EmbeddedVideoProps.positionSeconds), 0);
    expect(bounded.prop(EmbeddedVideoProps.volume), 1);
  });
}
