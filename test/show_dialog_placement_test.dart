import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a dialog from before placements reads as centered', () {
    final action = ActionModel.fromJson({
      'type': 'showDialog',
      'destinationId': 'menu',
    }) as ShowDialogAction;
    expect(action.placement, DialogPlacement.center);
    expect(action.anchorGap, 6);
  });

  test('placement and gap round-trip; defaults are omitted', () {
    final action = ShowDialogAction(
      destinationId: 'menu',
      placement: DialogPlacement.anchored,
      anchorGap: 4,
    );
    final json = action.toJson();
    expect(json['placement'], 'anchored');
    expect(ActionModel.fromJson(json), action);
    expect(
      ShowDialogAction(destinationId: 'x').toJson().containsKey('placement'),
      isFalse,
    );
  });
}
