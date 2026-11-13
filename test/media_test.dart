import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('media widgets are declared with Flutter defaults', () {
    for (final type in const [
      'path', 'video', 'embeddedVideo', 'audioPlayer', 'webView', 'external', 'placeholder', 'singlePlaceholder', //
    ]) {
      expect(Widgets.of(type), isNotNull, reason: type);
    }
    final n = Node.fromJson({'type': 'path'}, catalog: standardCatalog)!;
    expect(n.prop(PathProps.strokeJoin), StrokeJoin.miter);
    expect(n.prop(PathProps.trimEnd), 1);
    expect(n.prop(PathProps.viewBox), isNull);
    expect(Node.fromJson({'type': 'video'}, catalog: standardCatalog)!.prop(VideoProps.showControls), isTrue);
    expect(Node.fromJson({'type': 'audioPlayer'}, catalog: standardCatalog)!.prop(AudioPlayerProps.volume), 1);
    expect(Node.fromJson({'type': 'webView'}, catalog: standardCatalog)!.prop(WebViewProps.mediaPlaybackRequiresUserAction), isTrue);
    expect(Node.fromJson({'type': 'singlePlaceholder'}, catalog: standardCatalog)!.spec!.children, ChildModel.list);
  });

  test('media props round-trip sparsely and decode totally', () {
    final json = {
      'id': 'w',
      'type': 'webView',
      'layout': <String, Object?>{},
      'props': {
        'sourceType': 'html',
        'source': '<b>x</b>',
        'embed': {'type': 'twitter', 'tweetURL': 'u'},
        'gestures': ['tap', 'nonsense', 'scale'],
        'backgroundColor': '#FF102030',
      },
    };
    final n = Node.fromJson(json, catalog: standardCatalog)!;
    expect(n.prop(WebViewProps.sourceType), WebViewSourceType.html);
    expect(n.prop(WebViewProps.gestures), [WebViewGesture.tap, WebViewGesture.scale]);
    expect(n.prop(WebViewProps.backgroundColor), const Color(0xFF102030));
    expect(Node.fromJson(n.toJson(), catalog: standardCatalog), n);

    final p = Node.fromJson({
      'type': 'path',
      'props': {'data': 'M0 0', 'viewBox': [24, 'x'], 'trimStart': 2, 'strokeJoin': 'bevel'},
    }, catalog: standardCatalog)!;
    expect(p.prop(PathProps.viewBox), isNull);
    expect(p.prop(PathProps.trimStart), 1);
    expect(p.toJson()['props'], {'data': 'M0 0', 'trimStart': 1, 'strokeJoin': 'bevel'});

    final s = Node.fromJson({'type': 'singlePlaceholder', 'props': {'maxAllowedSize': [10, 20], 'allowedTypes': ['box', null]}}, catalog: standardCatalog)!;
    expect(s.prop(SinglePlaceholderProps.maxAllowedSize), [10, 20]);
    expect(s.prop(SinglePlaceholderProps.allowedTypes), ['box']);
  });

  test('a box path takes a stroke join and miter limit', () {
    final b = Node.fromJson({'type': 'box', 'props': {'path': 'M0 0 H10', 'strokeJoin': 'round', 'strokeMiterLimit': 2}}, catalog: standardCatalog)!;
    expect(b.prop(BoxProps.strokeJoin), StrokeJoin.round);
    expect(b.prop(BoxProps.strokeMiterLimit), 2);
    expect(Node.fromJson(b.toJson(), catalog: standardCatalog), b);
  });

  test('image paints keep flips, saturation, a placed rect and editor settings', () {
    final json = {
      'url': 'https://x.com/a.png',
      'fit': 'none',
      'scale': 2,
      'flipX': true,
      'saturation': 0.5,
      'rect': [1, 2, 30, 40],
      'cropData': {'x': 1},
    };
    final img = ImagePaint.fromJson(json);
    expect(img.flipX, isTrue);
    expect(img.flipY, isFalse);
    expect(img.saturation, 0.5);
    expect(img.rect, [1, 2, 30, 40]);
    expect(img.extra, {'cropData': {'x': 1}});
    expect(img.toJson(), json);
    expect(ImagePaint.fromJson(img.toJson()), img);
    expect(ImagePaint.fromJson({'rect': [1, 2], 'saturation': -1}).rect, isNull);
    expect(ImagePaint.fromJson({'saturation': -1}).saturation, 0);
  });
}
