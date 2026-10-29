import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a dialog without placement retains the trigger-relative default', () {
    final action = ActionModel.fromJson({
      'type': 'showDialog',
      'destinationId': 'menu',
    }) as ShowDialogAction;
    expect(action.placement, DialogPlacement.belowStart);
    expect(action.anchorGap, 4);
  });

  test('placement and gap round-trip; defaults are omitted', () {
    final action = ShowDialogAction(
      destinationId: 'menu',
      placement: DialogPlacement.anchored,
      anchorGap: 4,
    );
    final json = action.toJson();
    expect(json.containsKey('placement'), isFalse);
    expect(json['anchor'], 'trigger');
    final decoded = ActionModel.fromJson(json) as ShowDialogAction;
    expect(decoded.anchor, DialogAnchor.trigger);
    expect(decoded.presentation, DialogPresentation.dialog);
    expect(
      ShowDialogAction(destinationId: 'x').toJson().containsKey('placement'),
      isFalse,
    );
    final legacy = ActionModel.fromJson({
      'type': 'showDialog',
      'destinationId': 'x',
      'placement': 'anchored',
    }) as ShowDialogAction;
    expect(legacy.anchor, DialogAnchor.trigger);
    expect(legacy.toJson()['anchor'], 'trigger');
  });
}
