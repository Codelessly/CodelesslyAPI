import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// A switch's thumb shadows and thumb inset (Lamplight's power toggle: a
/// 24 px white knob in a 50×30 track, 3 px from its edges, with a
/// `0x33000000` shadow blurred 4 px, 1 px down) default to none, are
/// omitted from JSON then, and round-trip when set.
void main() {
  SwitchNode toggle(SwitchProperties properties) => SwitchNode(
    id: 's',
    name: 'Power',
    basicBoxLocal: NodeBox(0, 0, 50, 30),
    properties: properties,
  );

  final Effect shadow = Effect.dropShadow(
    id: 'thumb',
    color: ColorRGBA.fromHex('#33000000')!,
    offset: const Vec(0, 1),
    radius: 4,
    spread: 0,
  );

  test('default to none and are omitted', () {
    final Map json = toggle(SwitchProperties()).toJson();
    final Map properties = json['properties'] as Map;
    expect(properties.containsKey('thumbShadows'), isFalse);
    expect(properties.containsKey('thumbInset'), isFalse);
    final SwitchProperties read = SwitchNode.fromJson(json).properties;
    expect(read.thumbShadows, isEmpty);
    expect(read.thumbInset, isNull);
    expect(read.drawsPlainToggle, isFalse);
  });

  test('round-trip, copy and compare', () {
    final SwitchProperties set = SwitchProperties(
      fillTrack: true,
      uniformThumb: true,
      thumbShadows: [shadow],
      thumbInset: 3,
    );
    final Map json = toggle(set).toJson();
    final Map properties = json['properties'] as Map;
    expect(properties['thumbInset'], 3);
    expect(properties['thumbShadows'], hasLength(1));
    final SwitchProperties read = SwitchNode.fromJson(json).properties;
    expect(read.thumbInset, 3);
    expect(read.thumbShadows.single.color, shadow.color);
    expect(read.thumbShadows.single.radius, 4);
    expect(read.thumbShadows.single.offset, const Vec(0, 1));
    expect(read, set);
    expect(read.drawsPlainToggle, isTrue);
    expect(set.copyWith(), set);
    expect(set.copyWith(clearThumbInset: true).thumbInset, isNull);
    expect(set.copyWith(thumbShadows: []), isNot(set));
    // Not without a track that fills the node.
    expect(set.copyWith(fillTrack: false).drawsPlainToggle, isFalse);
    final field = SwitchProperties().fields['thumbInset']!;
    field.setValue(2.5);
    expect(field.getValue(), 2.5);
  });

  test('a shadow alone draws the plain toggle too', () {
    expect(
      SwitchProperties(fillTrack: true, thumbShadows: [shadow]).drawsPlainToggle,
      isTrue,
    );
  });
}
