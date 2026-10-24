import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a canvas path round-trips through JSON', () {
    final properties = CanvasProperties.fromJson({
      'bodyId': 'body',
      'path': 'guide/:id',
    });
    expect(properties.path, 'guide/:id');
    expect(properties.hasPath, isTrue);
    expect(properties.toJson()['path'], 'guide/:id');
    expect(CanvasProperties.fromJson(properties.toJson()), properties);
  });

  test('a canvas without a path writes none', () {
    final properties = CanvasProperties(bodyId: 'body');
    expect(properties.path, isNull);
    expect(properties.hasPath, isFalse);
    expect(properties.toJson().containsKey('path'), isFalse);
    expect(CanvasProperties(bodyId: 'body', path: '  ').hasPath, isFalse);
  });
}
