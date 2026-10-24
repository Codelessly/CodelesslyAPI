import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('text fields submit on unfocus unless turned off', () {
    final TextFieldProperties props = TextFieldProperties();
    expect(props.submitOnUnfocus, isTrue);
    expect(props.toJson().containsKey('submitOnUnfocus'), isFalse);
    final TextFieldProperties enterOnly = TextFieldProperties.fromJson(
      props.copyWith(submitOnUnfocus: false).toJson(),
    );
    expect(enterOnly.submitOnUnfocus, isFalse);
  });
}
