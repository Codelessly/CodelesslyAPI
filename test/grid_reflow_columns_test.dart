import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a fixed column count grid reflows by default and can opt out', () {
    final FixedCrossAxisCountGridDelegateProperties grid =
        FixedCrossAxisCountGridDelegateProperties(crossAxisCount: 7);
    expect(grid.reflowColumns, isTrue);
    expect(grid.toJson().containsKey('reflowColumns'), isFalse);

    final GridDelegateProperties calendar = GridDelegateProperties.fromJson(
      grid.copyWith(reflowColumns: false).toJson(),
    );
    expect(calendar, isA<FixedCrossAxisCountGridDelegateProperties>());
    expect(
      (calendar as FixedCrossAxisCountGridDelegateProperties).reflowColumns,
      isFalse,
    );
    expect(calendar.crossAxisCount, 7);
  });
}
