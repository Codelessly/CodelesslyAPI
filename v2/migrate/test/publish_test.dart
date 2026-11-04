import 'dart:convert';
import 'dart:io';

import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

/// A v1 canvas with a body frame and a button row navigating to [to].
Map<String, Object?> canvas(String id, double width, {String? to, String? path}) => {
      id: {
        'id': id, 'type': 'canvas', 'name': 'Screen $id', 'parentID': 'rootNode',
        'basicBoxLocal': [0, 0, width, 800], 'children': ['$id-body'],
        'properties': {'bodyId': '$id-body', 'path': ?path},
      },
      '$id-body': {
        'id': '$id-body', 'type': 'frame', 'name': 'Body', 'parentID': id,
        'basicBoxLocal': [0, 0, width, 800], 'children': ['$id-text'],
      },
      '$id-text': {
        'id': '$id-text', 'type': 'text', 'name': 'Title', 'parentID': '$id-body',
        'basicBoxLocal': [10, 10, 100, 20], 'data': 'Hi',
        'textMixedProps': [
          {'start': 0, 'end': 2, 'fontSize': 14, 'fontName': {'family': 'Inter', 'weight': 'w700'}},
        ],
        if (to != null)
          'reactions': [
            {
              'trigger': {'type': 'click'},
              'action': {'type': 'navigation', 'navigationType': 'push', 'destinationId': to, 'params': {}},
            },
          ],
      },
    };

void main() {
  final privacy = {'owner': 'o', 'teams': [], 'users': ['o'], 'roles': {'o': 'owner'}, 'public': true};
  final home = <String, Object?>{
    'id': 'home',
    'pageId': 'page',
    'projectId': 'p',
    'canvases': {
      'hd': canvas('hd', 1440, to: 'dm'),
      'hm': canvas('hm', 390, to: 'dm', path: '/home'),
    },
    'breakpoints': [
      {'nodeId': 'hd', 'lowerBound': 1024},
      {'nodeId': 'hm', 'lowerBound': 0, 'upperBound': 1023},
    ],
    'lastUpdated': 1700000000000,
    'canvasIds': ['hd', 'hm'],
    'theme': {
      'primary': {'r': 1, 'g': 0, 'b': 0, 'a': 1},
      'radius': 12,
    },
    'hidden': false,
    ...privacy,
  };
  final detail = <String, Object?>{
    'id': 'detail',
    'pageId': 'page',
    'projectId': 'p',
    'canvases': {
      'dm': canvas('dm', 390, path: 'guide/:id'),
    },
    'breakpoints': [
      {'nodeId': 'dm'},
    ],
    'lastUpdated': 1700000001000,
    ...privacy,
  };
  final v1Model = <String, Object?>{
    'projectId': 'p',
    'pages': ['page'],
    'entryLayoutId': 'home',
    'entryPageId': 'page',
    'entryCanvasId': null,
    'layoutIDMap': {'welcome': 'home'},
    'disabledLayouts': ['gone'],
    'lastUpdated': 1700000002000,
    'fonts': {
      'SW50ZXIgQm9sZA==': {'id': 'SW50ZXIgQm9sZA==', 'family': 'Inter', 'weight': 'w700', 'url': 'https://f/inter-700.ttf', ...privacy},
      'SW50ZXIgSXRhbGlj': {'id': 'SW50ZXIgSXRhbGlj', 'family': 'Inter', 'weight': 'w400', 'style': 'Italic', 'url': 'https://f/i.ttf'},
    },
    'apis': {
      'api1': {'id': 'api1', 'url': 'https://api', 'method': 'GET'},
    },
    'variables': {
      'home': {
        'id': 'home',
        'variables': {
          'hm': {
            'v1': {'id': 'v1', 'name': 'count', 'type': 'integer', 'value': '2'},
          },
        },
      },
    },
    'conditions': {
      'home': {'id': 'home', 'conditions': <String, Object?>{}},
    },
    'updates': {
      'layouts': {'home': 1700000000000, 'detail': 1700000001000, 'later': 1700000003000},
      'layoutFonts': {
        'home': ['SW50ZXIgQm9sZA=='],
      },
      'layoutApis': {
        'detail': ['api1'],
      },
      'layoutCanvases': {
        'home': ['hd', 'hm'],
        'detail': ['dm'],
        'later': ['lm'],
      },
      'canvasPaths': {'lm': 'later/:x', 'dm': 'stale'},
    },
    'layouts': {'home': home},
    ...privacy,
  };

  test('a v1 publish model migrates to a v2 bundle', () {
    final report = MigrationReport();
    final bundle = migratePublishModel(v1Model, layouts: {'detail': compressCanvases(detail)}, report: report);
    expect(bundle['schema'], 2);
    final model = bundle['model'] as Map;
    expect(model['schema'], 2);
    expect(model['projectId'], 'p');
    expect(model['entryLayoutId'], 'home');
    expect(model.containsKey('entryCanvasId'), isFalse);
    expect(model['layoutIDMap'], {'welcome': 'home'});
    expect(model['disabledLayouts'], ['gone']);
    expect(model['theme'], {'primary': '#FFFF0000', 'radius': 12});
    expect(model['fonts'], {
      'SW50ZXIgQm9sZA==': {'family': 'Inter', 'weight': 700, 'url': 'https://f/inter-700.ttf'},
      'SW50ZXIgSXRhbGlj': {'family': 'Inter', 'italic': true, 'url': 'https://f/i.ttf'},
    });
    expect(model['apis'], v1Model['apis']);
    expect(model['owner'], 'o');

    final entries = model['layouts'] as Map;
    expect(entries['home'], {
      'pageId': 'page',
      'canvases': [
        {'id': 'hm', 'name': 'Screen hm', 'path': '/home'},
        {'id': 'hd', 'name': 'Screen hd'},
      ],
      'fonts': ['SW50ZXIgQm9sZA=='],
      'lastUpdated': 1700000000000,
    });
    expect(entries['detail']['apis'], ['api1']);
    // The loaded layout's path wins over the model's stale one.
    expect((entries['detail']['canvases'] as List).single['path'], 'guide/:id');
    // Listed but not loaded: its entry, from the lookup maps.
    expect(entries['later'], {
      'canvases': [
        {'id': 'lm', 'path': 'later/:x'},
      ],
      'lastUpdated': 1700000003000,
    });

    final layouts = bundle['layouts'] as Map;
    expect(layouts.keys, unorderedEquals(['home', 'detail']));
    final h = layouts['home'] as Map;
    expect(h['schema'], 2);
    expect(h['id'], 'home');
    // Narrowest canvas first.
    expect(h['roots'], ['hm', 'hd']);
    expect(h['breakpoints'], [
      {'canvas': 'hm', 'maxWidth': 1023},
      {'canvas': 'hd', 'minWidth': 1024},
    ]);
    expect(h['paths'], {'hm': '/home'});
    expect((h['variables'] as Map)['hm'], isNotEmpty);
    expect(h.containsKey('conditions'), isFalse);
    expect(h['fonts'], ['SW50ZXIgQm9sZA==']);
    expect(h['theme'], {'primary': '#FFFF0000', 'radius': 12});
    expect(h['lastUpdated'], 1700000000000);
    expect(h.containsKey('hidden'), isFalse);
    expect(h['owner'], 'o');
    final nodes = h['nodes'] as Map;
    expect(nodes['hm']['type'], 'canvas');
    expect(nodes['hm']['slots'], {'body': 'hm-body'});
    expect(nodes['hm-text']['actions'], isNotEmpty);
    expect(nodes.length, 6);

    // The compressed layout expands; a single canvas needs no breakpoints.
    final d = layouts['detail'] as Map;
    expect(d['roots'], ['dm']);
    expect(d.containsKey('breakpoints'), isFalse);
    expect(d['apis'], ['api1']);
    expect(report.nodes, 9);
    expect(report.unportedTypes, isEmpty);
    jsonEncode(bundle);
  });

  test('compressed canvases round-trip', () {
    final c = compressCanvases(detail);
    expect(c.containsKey('canvases'), isFalse);
    expect(c[compressedCanvasesKey], isA<String>());
    expect(expandCompressedCanvases(c)['canvases'], detail['canvases']);
    expect(expandCompressedCanvases(detail), same(detail));
  });

  test('fonts and themes tolerate junk', () {
    expect(migrateFont({'weight': 'w700'}), isNull);
    expect(migrateFont({'family': 'X', 'weight': 'bold?'}), {'family': 'X'});
    expect(migrateFont({'family': 'X', 'weight': 300}), {'family': 'X', 'weight': 300});
    expect(migrateTheme(null), isNull);
    expect(migrateTheme({}), isNull);
  });

  test('a real project migrates: every page, grouped by breakpoint', () {
    final pages = Directory('/home/user/v2_static_pages');
    if (!pages.existsSync()) return markTestSkipped('fixture pages not available');
    final out = File('${Directory.systemTemp.createTempSync('publish').path}/rigcheck.json.gz');
    final files = pages.listSync().whereType<File>().where((f) => f.uri.pathSegments.last.startsWith('rigcheck__')).map((f) => f.path).toList();
    final result = Process.runSync(Platform.resolvedExecutable, ['run', 'bin/publish_fixture.dart', out.path, ...files]);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    final bundle = jsonDecode(utf8.decode(gzip.decode(out.readAsBytesSync()))) as Map;
    final layouts = bundle['layouts'] as Map;
    final today = layouts.values.firstWhere((l) => ((l['nodes'] as Map)[(l['roots'] as List).first] as Map)['name'] == 'Today · M') as Map;
    expect((today['breakpoints'] as List).map((b) => (b as Map)['minWidth'] ?? 0), [0, 600, 1024]);
    expect((bundle['model'] as Map)['entryLayoutId'], isNotNull);
  });
}
