import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  final layoutJson = <String, Object?>{
    'schema': 3,
    'id': 'home',
    'roots': ['m', 'd'],
    'nodes': {
      'm': {'type': 'canvas', 'name': 'Home · M', 'layout': {'width': 390, 'height': 844}},
      'd': {'type': 'canvas', 'name': 'Home · D', 'layout': {'width': 1440, 'height': 900}},
    },
    'pageId': 'page',
    'projectId': 'p',
    'breakpoints': [
      {'canvas': 'm', 'breakpoint': 'mobile'},
      {'canvas': 'd', 'breakpoint': 'desktop'},
    ],
    'paths': {'m': 'home'},
    'variables': {
      'm': [
        {'id': 'var1', 'name': 'count', 'type': 'integer', 'value': 3},
      ],
    },
    'fonts': ['inter'],
    'lastUpdated': 1700000000000,
    'future': {'kept': true},
  };

  group('a published layout', () {
    test('is a document with its publish keys beside it', () {
      final l = PublishLayout.fromJson(layoutJson);
      expect(l.id, 'home');
      expect(l.canvasIds, ['m', 'd']);
      expect(l.document['d']!.type, 'canvas');
      expect(l.document.extra, isEmpty);
      expect(l.pageId, 'page');
      expect(l.breakpoints, [const CanvasBreakpoint(canvasId: 'm', breakpointId: 'mobile'), const CanvasBreakpoint(canvasId: 'd', breakpointId: 'desktop')]);
      expect(l.paths, {'m': 'home'});
      expect(l.variablesOf('m').single.value, 3);
      expect(l.lastUpdated, DateTime.fromMillisecondsSinceEpoch(1700000000000, isUtc: true));
      expect(l.extra, {'future': {'kept': true}});
      // And decodes as a plain document.
      expect(LayoutDocument.fromJson(layoutJson).roots, ['m', 'd']);
    });

    test('keeps its scripts in the document', () {
      final l = PublishLayout.fromJson({
        ...layoutJson,
        'scripts': [
          {'id': 's1', 'name': 'pay', 'source': 'return 1'},
        ],
      });
      expect(l.document.scripts.single.name, 'pay');
      expect(l.extra, {'future': {'kept': true}});
      expect(PublishLayout.fromJson(l.toJson()).document.scripts, l.document.scripts);
    });

    test('round-trips through JSON', () {
      final l = PublishLayout.fromJson(layoutJson);
      final again = PublishLayout.fromJson(jsonDecode(jsonEncode(l.toJson())));
      expect(jsonEncode(again.toJson()), jsonEncode(l.toJson()));
      expect(l.toJson()['breakpoints'], layoutJson['breakpoints']);
    });

    test('picks the canvas for a width by its breakpoints', () {
      final l = PublishLayout.fromJson(layoutJson);
      expect(l.canvasForWidth(390), 'm');
      expect(l.canvasForWidth(1023), 'm');
      expect(l.canvasForWidth(1024), 'd');
      expect(l.canvasForWidth(3000), 'd');
      // Below every range: the narrowest.
      final shifted = l.copyWith(breakpoints: [
        const CanvasBreakpoint(canvasId: 'm', minWidth: 300),
        const CanvasBreakpoint(canvasId: 'd', minWidth: 1024),
      ]);
      expect(shifted.canvasForWidth(100), 'm');
      // By the project's breakpoints: desktop from 1200 here.
      final project = Breakpoints.defaults.update('desktop', (b) => b.copyWith(minWidth: 1200));
      expect(l.canvasForWidth(1100, project), 'm');
      expect(l.canvasForWidth(1200, project), 'd');
      // A canvas's own switch point wins over its breakpoint's.
      final own = l.copyWith(breakpoints: [
        const CanvasBreakpoint(canvasId: 'm', breakpointId: 'mobile'),
        const CanvasBreakpoint(canvasId: 'd', breakpointId: 'desktop', minWidth: 900),
      ]);
      expect(own.canvasForWidth(950), 'd');
      expect(own.toJson()['breakpoints'], [
        {'canvas': 'm', 'breakpoint': 'mobile'},
        {'canvas': 'd', 'breakpoint': 'desktop', 'minWidth': 900},
      ]);
      // Breakpoints without ids: ranges by min width.
      final unordered = PublishLayout.fromJson({...layoutJson, 'breakpoints': [
        {'canvas': 'm'},
        {'canvas': 'd', 'minWidth': 1024, 'maxWidth': 99999},
      ]});
      expect(unordered.canvasForWidth(1023), 'm');
      expect(unordered.canvasForWidth(1024), 'd');
      // A single canvas needs no breakpoints.
      final one = PublishLayout(document: LayoutDocument(id: 'x', roots: const ['c'], nodes: {'c': const Node(id: 'c', type: 'canvas')}));
      expect(one.canvasForWidth(9999), 'c');
    });

    test('still decodes from junk', () {
      final l = PublishLayout.fromJson({'breakpoints': [1, {'minWidth': 3}], 'fonts': 'x', 'lastUpdated': 'never'});
      expect(l.breakpoints, isEmpty);
      expect(l.fonts, isEmpty);
      expect(l.lastUpdated, isNull);
      expect(PublishLayout.fromJson(null).canvasIds, isEmpty);
    });
  });

  group('a published app', () {
    final modelJson = <String, Object?>{
      'schema': 3,
      'projectId': 'p',
      'entryLayoutId': 'home',
      'pages': ['page'],
      'layouts': {
        'home': {
          'pageId': 'page',
          'canvases': [
            {'id': 'm', 'name': 'Home · M', 'path': 'home'},
            {'id': 'd', 'name': 'Home · D'},
          ],
          'fonts': ['inter'],
          'lastUpdated': 1700000000000,
        },
        'form': {
          'canvases': [
            {'id': 'f', 'name': 'Record form'},
          ],
        },
        'off': {
          'canvases': [
            {'id': 'o', 'name': 'Old'},
          ],
        },
      },
      'layoutIDMap': {'welcome': 'home'},
      'disabledLayouts': ['off'],
      'theme': {'primary': '#FF3366FF', 'radius': 12},
      'fonts': {
        'inter': {'family': 'Inter'},
        'inter-b': {'family': 'Inter', 'weight': 700, 'url': 'https://x/inter-b.ttf'},
      },
      'apis': {'a': {'url': 'https://api'}},
      'owner': 'someone',
    };

    test('round-trips and keeps keys it does not know', () {
      final m = PublishModel.fromJson(modelJson);
      expect(m.toJson(), modelJson);
      expect(m.extra, {'owner': 'someone'});
      expect(m.theme.primary, const Color(0xFF3366FF));
      expect(m.theme.radius, 12);
      expect(m.fonts['inter-b']!.weight, 700);
      expect(m.fonts['inter']!.url, isNull);
    });

    test('finds a layout by its id, custom id or canvas id', () {
      final m = PublishModel.fromJson(modelJson);
      expect(m.resolveLayoutId('home'), 'home');
      expect(m.resolveLayoutId('welcome'), 'home');
      expect(m.resolveLayoutId('d'), 'home');
      expect(m.resolveLayoutId('f'), 'form');
      expect(m.resolveLayoutId('off'), isNull, reason: 'disabled');
      expect(m.resolveLayoutId('nope'), isNull);
      expect(m.resolveLayoutId(''), isNull);
      expect(m.resolveLayoutId(null), isNull);
      expect(m.canvas('m')!.path, 'home');
      expect(m.fontsOf('home').map((f) => f.family), ['Inter']);
    });

    test('finds a screen by its name, ignoring case and spacing', () {
      final m = PublishModel.fromJson(modelJson);
      expect(m.layoutIdForScreen('record-form'), 'form');
      expect(m.layoutIdForScreen('Record%20Form'), 'form');
      expect(m.layoutIdForScreen('f'), 'form');
      expect(m.layoutIdForScreen('old'), isNull, reason: 'disabled');
      expect(m.layoutIdForScreen('ledger'), isNull);
      expect(m.layoutIdForScreen(null), isNull);
    });

    test('lists a loaded layout\'s canvases', () {
      final info = PublishLayoutInfo.of(PublishLayout.fromJson(layoutJson));
      expect(info.toJson(), {
        'pageId': 'page',
        'canvases': [
          {'id': 'm', 'name': 'Home · M', 'path': 'home'},
          {'id': 'd', 'name': 'Home · D'},
        ],
        'fonts': ['inter'],
        'lastUpdated': 1700000000000,
      });
    });

    test('lists its overlay screens', () {
      final m = PublishModel.fromJson({...modelJson, 'overlayLayoutIds': ['form', 'off', 'gone']});
      expect(m.overlayLayoutIds, ['form', 'off', 'gone']);
      expect(m.extra, {'owner': 'someone'});
      // Published and not disabled.
      expect(m.overlays, ['form']);
      final again = PublishModel.fromJson(jsonDecode(jsonEncode(m.toJson())));
      expect(again.overlayLayoutIds, ['form', 'off', 'gone']);
      expect(m.copyWith(overlayLayoutIds: []).toJson().containsKey('overlayLayoutIds'), isFalse);
      expect(PublishModel.fromJson(modelJson).overlayLayoutIds, isEmpty);
      // A canvas is an overlay screen by its `overlay` prop.
      expect(CanvasProps.spec.props, contains(CanvasProps.overlay));
      final canvas = Node.fromJson({'id': 'c', 'type': 'canvas', 'props': {'overlay': true}})!;
      expect(canvas.prop(CanvasProps.overlay), isTrue);
      expect(Node.fromJson(canvas.toJson())!.prop(CanvasProps.overlay), isTrue);
      expect(const Node(id: 'c', type: 'canvas').prop(CanvasProps.overlay), isFalse);
    });

    test('lists its backdrop screens, and an overlay is not one', () {
      final m = PublishModel.fromJson({...modelJson, 'backdropLayoutIds': ['form', 'off', 'gone']});
      expect(m.backdropLayoutIds, ['form', 'off', 'gone']);
      expect(m.extra, {'owner': 'someone'});
      // Published and not disabled.
      expect(m.backdrops, ['form']);
      final again = PublishModel.fromJson(jsonDecode(jsonEncode(m.toJson())));
      expect(again.backdropLayoutIds, ['form', 'off', 'gone']);
      expect(again.backdrops, ['form']);
      expect(m.copyWith(backdropLayoutIds: []).toJson().containsKey('backdropLayoutIds'), isFalse);
      expect(m.copyWith(backdropLayoutIds: ['x']).backdropLayoutIds, ['x']);
      expect(PublishModel.fromJson(modelJson).backdropLayoutIds, isEmpty);
      // Overlay wins: a layout listed as both is drawn as an overlay only.
      expect(m.copyWith(overlayLayoutIds: ['form']).backdrops, isEmpty);
      // A canvas is a backdrop screen by its `backdrop` prop.
      expect(CanvasProps.spec.props, contains(CanvasProps.backdrop));
      final canvas = Node.fromJson({'id': 'c', 'type': 'canvas', 'props': {'backdrop': true}})!;
      expect(canvas.prop(CanvasProps.backdrop), isTrue);
      expect(Node.fromJson(canvas.toJson())!.prop(CanvasProps.backdrop), isTrue);
      expect(const Node(id: 'c', type: 'canvas').prop(CanvasProps.backdrop), isFalse);
    });

  });

  test('a bundle holds the app and its layouts', () {
    final bundle = PublishBundle.fromJson({
      'schema': 3,
      'model': {'projectId': 'p', 'layouts': {'home': {}}},
      'layouts': {'home': {...layoutJson}..remove('id')},
    });
    expect(bundle.model.projectId, 'p');
    expect(bundle.layouts['home']!.id, 'home', reason: 'the key names a layout without an id');
    final again = PublishBundle.fromJson(jsonDecode(jsonEncode(bundle.toJson())));
    expect(again.layouts['home']!.canvasIds, ['m', 'd']);
    expect(again.toJson()['schema'], kPublishSchemaVersion);
  });

  group('screens shown over other screens', () {
    test('a canvas keeps the screen it opens over and whether it is see-through', () {
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

    test('a canvas with neither has no route settings', () {
      expect(ScreenRoute.fromJson({'under': '  '}), isNull);
      expect(PublishCanvas.fromJson({'id': 'c', 'path': 'timeline'})!.route, ScreenRoute.none);
      expect(const PublishCanvas(id: 'c').toJson(), {'id': 'c'});
    });
  });
}
