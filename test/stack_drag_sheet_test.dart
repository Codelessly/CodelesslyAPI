import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('list layout round-trips and is omitted when default', () {
    final stacked = ListViewProperties(layout: ListLayout.stack);
    expect(stacked.toJson()['layout'], 'stack');
    expect(
      ListViewProperties.fromJson(stacked.toJson()).layout,
      ListLayout.stack,
    );
    expect(ListViewProperties().toJson().containsKey('layout'), isFalse);
    expect(ListViewProperties.fromJson({}).layout, ListLayout.list);
  });

  test('drag end trigger round-trips', () {
    final t = TriggerModel(type: TriggerType.dragEnd);
    expect(TriggerModel.fromJson(t.toJson()).type, TriggerType.dragEnd);
    expect(TriggerType.dragEnd.prettify, 'Drag End');
  });

  test('dialog presentation round-trips, dialog by default', () {
    final sheet = ShowDialogAction(
      destinationId: 'c',
      presentation: DialogPresentation.bottomSheet,
    );
    expect(
      ShowDialogAction.fromJson(sheet.toJson()).presentation,
      DialogPresentation.bottomSheet,
    );
    expect(
      ShowDialogAction.fromJson(ShowDialogAction(destinationId: 'c').toJson())
          .presentation,
      DialogPresentation.dialog,
    );
  });
}
