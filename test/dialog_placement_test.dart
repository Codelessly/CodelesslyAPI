import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('A dialog placement round-trips and defaults to center', () {
    final ShowDialogAction plain = ActionModel.fromJson({
      'type': 'showDialog',
      'destinationId': 'menu',
    }) as ShowDialogAction;
    expect(plain.placement, DialogPlacement.center);
    expect(plain.placementGap, 8);
    expect(plain.toJson().containsKey('placement'), isFalse);

    final ShowDialogAction beside = plain.copyWith(
      placement: DialogPlacement.beside,
      placementGap: 12,
    );
    expect(beside.toJson()['placement'], 'beside');
    expect(ActionModel.fromJson(beside.toJson()), beside);
  });

  test('An unknown placement opens centered', () {
    final ShowDialogAction action = ActionModel.fromJson({
      'type': 'showDialog',
      'destinationId': 'menu',
      'placement': 'somewhereNew',
    }) as ShowDialogAction;
    expect(action.placement, DialogPlacement.center);
  });
}
