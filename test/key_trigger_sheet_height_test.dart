import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a key down trigger round-trips with its key', () {
    final TriggerModel trigger = TriggerModel(
      type: TriggerType.keyDown,
      key: 'ArrowLeft',
    );
    final TriggerModel read = TriggerModel.fromJson(trigger.toJson());
    expect(read.type, TriggerType.keyDown);
    expect(read.key, 'ArrowLeft');
    expect(TriggerModel(type: TriggerType.keyDown).toJson()['key'], isNull);
    expect(TriggerType.keyDown.prettify, 'Key Down');
  });

  test('a full height sheet round-trips; the default is left out', () {
    final ShowDialogAction sheet = ShowDialogAction(
      destinationId: 'catalog',
      presentation: DialogPresentation.bottomSheet,
      fullHeight: true,
    );
    expect(ShowDialogAction.fromJson(sheet.toJson()).fullHeight, isTrue);
    expect(
      ShowDialogAction(destinationId: 'catalog').toJson()['fullHeight'],
      isNull,
    );
  });
}
