import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('sheetBelowWidth round-trips and is omitted at its default', () {
    final ShowDialogAction action = ShowDialogAction(
      destinationId: 'menu',
      presentation: DialogPresentation.adaptive,
      sheetBelowWidth: 640,
    );
    final Map<String, dynamic> json = Map<String, dynamic>.from(action.toJson());
    expect(json['sheetBelowWidth'], 640);
    expect(ShowDialogAction.fromJson(json).sheetBelowWidth, 640);
    expect(
      ShowDialogAction(destinationId: 'menu').toJson(),
      isNot(contains('sheetBelowWidth')),
    );
    expect(ShowDialogAction.fromJson(<String, dynamic>{
      'type': 'showDialog',
      'destinationId': 'menu',
    }).sheetBelowWidth, 600);
  });
}
