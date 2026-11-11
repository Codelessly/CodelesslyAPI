import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a layout keeps each canvas route; the model lists it on the canvas', () {
    final layout = PublishLayout.fromJson({
      'id': 'L',
      'roots': ['photo'],
      'nodes': {
        'photo': {'type': 'canvas', 'name': 'Photo'},
      },
      'paths': {'photo': 'specimen/:id/photo'},
      'routes': {
        'photo': {'under': 'specimen/:id', 'translucent': true},
        'ignored': {},
      },
    });
    expect(layout.routes, {'photo': const ScreenRoute(under: 'specimen/:id', translucent: true)});
    expect(PublishLayout.fromJson(layout.toJson()).routes, layout.routes);
    final canvas = PublishLayoutInfo.of(layout).canvases.single;
    expect(canvas.route, const ScreenRoute(under: 'specimen/:id', translucent: true));
    expect(canvas.toJson(), {'id': 'photo', 'name': 'Photo', 'path': 'specimen/:id/photo', 'under': 'specimen/:id', 'translucent': true});
    expect(PublishCanvas.fromJson(canvas.toJson()), canvas);
  });

  test('no under and not translucent: no route', () {
    expect(ScreenRoute.fromJson({'under': '  '}), isNull);
    expect(PublishCanvas.fromJson({'id': 'c', 'path': 'timeline'})!.route, ScreenRoute.none);
    expect(const PublishCanvas(id: 'c').toJson(), {'id': 'c'});
  });
}
