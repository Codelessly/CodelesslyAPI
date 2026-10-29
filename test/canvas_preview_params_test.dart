import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a canvas keeps the sample route params it previews with', () {
    final CanvasProperties properties = CanvasProperties(
      bodyId: 'body',
      previewParams: const <String, dynamic>{
        'title': 'Log black tank dump?',
        'danger': true,
      },
    );
    final Map<String, dynamic> json = properties.toJson();
    expect(json['previewParams'], <String, dynamic>{
      'title': 'Log black tank dump?',
      'danger': true,
    });
    expect(
      CanvasProperties.fromJson(json).previewParams,
      properties.previewParams,
    );
  });

  test('a canvas without preview params writes none', () {
    final Map<String, dynamic> json = CanvasProperties(bodyId: 'body').toJson();
    expect(json.containsKey('previewParams'), isFalse);
    expect(CanvasProperties.fromJson(json).previewParams, isEmpty);
  });
}
