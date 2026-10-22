import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a spacer reads from minimal JSON and round-trips', () {
    final SpacerNode spacer = SpacerNode.fromJson({
      'id': 's',
      'name': 'spacer',
      'type': 'spacer',
      'basicBoxLocal': [0, 0, 0, 0],
      'flex': 2,
    });
    expect(spacer.positioningMode, PositioningMode.align);
    expect(spacer.aspectRatioLock, isFalse);
    expect(spacer.reactions, isEmpty);
    expect(spacer.flex, 2);

    final SpacerNode again = SpacerNode.fromJson(spacer.toJson());
    expect(again.flex, 2);
    expect(again.positioningMode, PositioningMode.align);
  });
}
