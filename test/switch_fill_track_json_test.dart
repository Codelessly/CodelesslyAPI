import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// A switch's `fillTrack` (its track drawn to the node's bounds) defaults to
/// off, is omitted from JSON then, and round-trips when on.
void main() {
  SwitchNode toggle(SwitchProperties properties) => SwitchNode(
    id: 's',
    name: 'Toggle',
    basicBoxLocal: NodeBox(0, 0, 46, 28),
    properties: properties,
  );

  test('defaults to off and is omitted', () {
    final Map json = toggle(SwitchProperties()).toJson();
    expect((json['properties'] as Map).containsKey('fillTrack'), isFalse);
    expect(SwitchNode.fromJson(json).properties.fillTrack, isFalse);
  });

  test('round-trips, copies and is a field', () {
    final SwitchProperties on = SwitchProperties(
      fillTrack: true,
      uniformThumb: true,
    );
    final Map json = toggle(on).toJson();
    expect((json['properties'] as Map)['fillTrack'], isTrue);
    final SwitchProperties read = SwitchNode.fromJson(json).properties;
    expect(read.fillTrack, isTrue);
    expect(read.uniformThumb, isTrue);
    expect(on.copyWith().fillTrack, isTrue);
    expect(on.copyWith(fillTrack: false).fillTrack, isFalse);
    expect(on.copyWith(fillTrack: false), isNot(on));
    final field = SwitchProperties().fields['fillTrack']!;
    field.setValue(true);
    expect(field.getValue(), isTrue);
  });
}
