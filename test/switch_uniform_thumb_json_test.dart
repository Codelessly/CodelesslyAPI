import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// A switch's `uniformThumb` (full-size thumb when off) defaults to off,
/// is omitted from JSON then, and round-trips when on.
void main() {
  SwitchNode toggle(SwitchProperties properties) => SwitchNode(
    id: 's',
    name: 'Toggle',
    basicBoxLocal: NodeBox(0, 0, 46, 28),
    properties: properties,
  );

  test('defaults to off and is omitted', () {
    final Map json = toggle(SwitchProperties()).toJson();
    expect((json['properties'] as Map).containsKey('uniformThumb'), isFalse);
    expect(
      SwitchNode.fromJson(json).properties.uniformThumb,
      isFalse,
    );
  });

  test('round-trips, copies and is a field', () {
    final SwitchProperties on = SwitchProperties(uniformThumb: true);
    final Map json = toggle(on).toJson();
    expect((json['properties'] as Map)['uniformThumb'], isTrue);
    expect(SwitchNode.fromJson(json).properties.uniformThumb, isTrue);
    expect(on.copyWith().uniformThumb, isTrue);
    expect(on.copyWith(uniformThumb: false).uniformThumb, isFalse);
    expect(on, isNot(SwitchProperties()));
    final field = SwitchProperties().fields['uniformThumb']!;
    field.setValue(true);
    expect(field.getValue(), isTrue);
  });
}
