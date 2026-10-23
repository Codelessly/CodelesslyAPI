import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('padding reads spelled-out sides', () {
    expect(
      EdgeInsetsModel.fromJson({'left': 1, 'top': 2, 'right': 3, 'bottom': 4}),
      EdgeInsetsModel.only(left: 1, top: 2, right: 3, bottom: 4),
    );
    expect(
      EdgeInsetsModel.fromJson({'horizontal': 16, 'vertical': 8}),
      EdgeInsetsModel.symmetric(horizontal: 16, vertical: 8),
    );
    expect(
      EdgeInsetsModel.fromJson({'top': 12}),
      EdgeInsetsModel.only(top: 12),
    );
  });

  test('the stored forms still read', () {
    expect(EdgeInsetsModel.fromJson(8), EdgeInsetsModel.all(8));
    expect(
      EdgeInsetsModel.fromJson([1, 2, 3, 4]),
      EdgeInsetsModel.only(left: 1, top: 2, right: 3, bottom: 4),
    );
    expect(
      EdgeInsetsModel.fromJson({'l': 1, 't': 2, 'r': 3, 'b': 4}),
      EdgeInsetsModel.only(left: 1, top: 2, right: 3, bottom: 4),
    );
  });
}
