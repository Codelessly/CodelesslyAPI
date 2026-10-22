import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a spacer reads from minimal JSON and round-trips', () {
    final SpacerNode spacer = SpacerNode.fromJson({
      'type': 'spacer',
      'id': 'spacer',
      'name': 'Spacer',
      'basicBoxLocal': [0, 0, 1, 1],
      'flex': 2,
    });
    expect(spacer.positioningMode, PositioningMode.align);
    expect(spacer.aspectRatioLock, isFalse);
    expect(spacer.reactions, isEmpty);
    expect(spacer.flex, 2);

    // What toJson omits as defaults, fromJson must fill back in.
    final SpacerNode again = SpacerNode.fromJson(
      Map<String, dynamic>.from(spacer.toJson()),
    );
    expect(again.flex, 2);
    expect(again.positioningMode, PositioningMode.align);
  });
}
