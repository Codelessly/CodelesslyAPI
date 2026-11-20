import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('keyframes inside a track still run from its own ends', () {
    const inside = AnimationTrack(
      path: 'opacity',
      keyframes: [Keyframe(at: 0.5, value: 0)],
      interpolation: KeyframeInterpolation.monotoneCubic,
    );
    expect(inside.valueAt(0.5, own: 1) as double, closeTo(0, 1e-9));
  });

  test('a hover or pressed style merges into the node it styles', () {
    final n = Node.fromJson({
      'id': 't',
      'type': 'text',
      'props': {'text': 'A', 'maxLines': 2}
    })!;
    final p = n.patched({
      'props': {'text': 'B', 'maxLines': null}
    });
    expect(p.prop(TextProps.text), 'B');
    expect(p.toJson()['props'], {'text': 'B'});
    expect(diffPatch(n.toJson(), p.toJson()), {
      'props': {'text': 'B', 'maxLines': null}
    });
    expect(mergePatch({'a': 1}, {'a': null}, keepNulls: true), {'a': null});
  });

  test('a map merged over a value that is not one keeps none of its nulls (RFC 7386)', () {
    expect(mergePatch({'width': 310}, {'width': {'fill': 0, 'hug': null}}), {'width': {'fill': 0}});
    // Merging two patches keeps them.
    expect(mergePatch({'width': 310}, {'width': {'fill': 0, 'hug': null}}, keepNulls: true), {'width': {'fill': 0, 'hug': null}});
  });
}
