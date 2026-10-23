import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a material indicator is a full circle from 12 by default', () {
    final MaterialLoadingIndicatorProperties props =
        MaterialLoadingIndicatorProperties.fromJson({
          'type': 'material',
          'color': '#FF3F6B4F',
        });
    expect(props.startAngle, -90);
    expect(props.sweepAngle, 360);
    expect(props.isArc, isFalse);
    expect(props.toJson().containsKey('startAngle'), isFalse);
    expect(props.toJson().containsKey('sweepAngle'), isFalse);
  });

  test('an arc keeps its start and sweep through JSON', () {
    final MaterialLoadingIndicatorProperties gauge =
        MaterialLoadingIndicatorProperties(
          color: ColorRGBA.white,
          value: 0.71,
          startAngle: 180,
          sweepAngle: 180,
        );
    expect(gauge.isArc, isTrue);
    final MaterialLoadingIndicatorProperties back =
        MaterialLoadingIndicatorProperties.fromJson(gauge.toJson());
    expect(back.startAngle, 180);
    expect(back.sweepAngle, 180);
    expect(back, gauge);
    expect(gauge.copyWith(sweepAngle: 90).sweepAngle, 90);
  });

  test('showDialog presentation defaults to dialog and round-trips', () {
    final ShowDialogAction plain = ShowDialogAction.fromJson({
      'type': 'showDialog',
      'destinationId': 'c',
    });
    expect(plain.presentation, DialogPresentation.dialog);
    expect(plain.toJson().containsKey('presentation'), isFalse);

    final ShowDialogAction sheet = ShowDialogAction(
      destinationId: 'c',
      presentation: DialogPresentation.adaptive,
    );
    final ActionModel back = ActionModel.fromJson(sheet.toJson());
    expect(
      (back as ShowDialogAction).presentation,
      DialogPresentation.adaptive,
    );
    expect(
      sheet.copyWith(presentation: DialogPresentation.popover).presentation,
      DialogPresentation.popover,
    );
  });

  test('a back navigation needs no destination', () {
    final ActionModel pop = ActionModel.fromJson({
      'type': 'navigation',
      'navigationType': 'pop',
    });
    expect(pop, isA<NavigationAction>());
    expect((pop as NavigationAction).destinationId, '');
    expect(pop.toJson().containsKey('destinationId'), isFalse);
  });
}
