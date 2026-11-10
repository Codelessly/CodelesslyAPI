import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

/// [nodes] (v1 JSON by id) as children of a 400×800 frame body.
Map<String, Object?> _page(Map<String, Map<String, Object?>> nodes) => {
      'rootNode': {'children': ['c']},
      'c': {'id': 'c', 'type': 'canvas', 'name': 'c', 'parentID': 'rootNode', 'basicBoxLocal': [0, 0, 400, 800],
            'properties': {'bodyId': 'f'}, 'children': ['f']},
      'f': {'id': 'f', 'name': 'f', 'parentID': 'c', 'type': 'frame', 'basicBoxLocal': [0, 0, 400, 800],
            'children': [for (final e in nodes.entries) if (e.value['parentID'] == null) e.key]},
      for (final e in nodes.entries)
        e.key: {'id': e.key, 'name': e.key, 'parentID': 'f', ...e.value},
    };

void main() {
  test('media nodes migrate to their v2 types, with nothing left unmapped', () {
    final report = MigrationReport();
    final v2 = migrateDocument(
        _page({
          'path': {'type': 'path', 'basicBoxLocal': [0, 0, 48, 48], 'pathData': 'M0 0 L10 10', 'viewBoxWidth': 24,
                   'viewBoxHeight': 24, 'trimEnd': 0.5, 'strokes': [{'type': 'solid', 'color': '#000000', 'id': 's'}],
                   'strokeMiterLimit': 8},
          'video': {'type': 'video', 'basicBoxLocal': [0, 50, 320, 180],
                    'properties': {'url': 'https://cdn.example.com/a.mp4', 'showControls': false}},
          'yt': {'type': 'embeddedVideo', 'basicBoxLocal': [0, 240, 320, 180],
                 'properties': {'source': 'youtube', 'videoId': 'abc', 'mute': true, 'startAt': 3, 'endAt': 9}},
          'vimeo': {'type': 'embeddedVideo', 'basicBoxLocal': [0, 240, 320, 180],
                    'properties': {'source': 'vimeo', 'videoId': '1', 'loop': true}},
          'audio': {'type': 'audioPlayer', 'basicBoxLocal': [0, 430, 320, 64],
                    'properties': {'url': 'https://cdn.example.com/a.mp3', 'volume': 0.25, 'background': true}},
          'web': {'type': 'webView', 'basicBoxLocal': [0, 500, 300, 200],
                  'properties': {'webviewType': 'webpage', 'pageSourceType': 'html', 'input': '<b>x</b>',
                                 'controlTapGesture': true, 'mediaAutoPlaybackPolicy': 'alwaysPlayAllMedia'}},
          'ext': {'type': 'external', 'basicBoxLocal': [0, 0, 10, 10], 'properties': {'builderID': 'chart'}},
          'ph': {'type': 'placeholder', 'basicBoxLocal': [0, 0, 10, 10], 'text': 'Drop'},
          'sp': {'type': 'singlePlaceholder', 'basicBoxLocal': [0, 0, 100, 100], 'allowedTypes': ['text'],
                 'deniedTypes': [], 'maxAllowedSize': {'width': 50, 'height': 60}, 'children': ['kid']},
          'kid': {'type': 'rectangle', 'basicBoxLocal': [0, 0, 100, 100], 'parentID': 'sp'},
        }),
        report: report);
    final n = (v2['nodes'] as Map).cast<String, Map>();
    expect(report.unportedTypes, isEmpty);
    expect(report.unmapped.keys.where((k) => !k.startsWith('canvas.')), isEmpty);

    expect(n['path']!['type'], 'path');
    expect(n['path']!['props'], {'data': 'M0 0 L10 10', 'viewBox': [24, 24], 'trimEnd': 0.5, 'strokeJoin': 'round'});
    expect(n['path']!['decoration'], containsPair('strokeWidth', 2.0));
    expect(n['path']!['decoration'], containsPair('strokeCap', 'round'));

    expect(n['video']!['props'], {'url': 'https://cdn.example.com/a.mp4', 'showControls': false});
    expect(n['yt']!['props'], {'videoId': 'abc', 'mute': true, 'startAt': 3, 'endAt': 9});
    expect(n['vimeo']!['props'], {'source': 'vimeo', 'videoId': '1', 'loop': true});
    expect(n['audio']!['props'], {'url': 'https://cdn.example.com/a.mp3', 'volume': 0.25, 'background': true});
    expect(n['web']!['props'], {
      'sourceType': 'html', 'source': '<b>x</b>', 'gestures': ['tap'], 'mediaPlaybackRequiresUserAction': false, //
    });
    expect(n['ext']!['props'], {'builderId': 'chart'});
    expect(n['ph']!['props'], {'text': 'Drop'});
    expect(n['sp']!['type'], 'singlePlaceholder');
    expect(n['sp']!['children'], ['kid']);
    expect(n['sp']!['props'], {'allowedTypes': ['text'], 'maxAllowedSize': [50, 60]});
    // A slot's child isn't placed freeform.
    expect((n['kid']!['layout'] as Map).containsKey('x'), isFalse);
  });

  test('image fills keep what SDK 8.x drew them with', () {
    final v2 = migrateDocument(_page({
      'img': {
        'type': 'rectangle',
        'basicBoxLocal': [0, 0, 200, 100],
        'fills': [
          {'type': 'image', 'id': 'i', 'downloadUrl': 'https://x.com/a.png', 'croppedImageURL': 'https://x.com/c.png',
           'fit': 'none', 'scaleX': -2, 'scaleY': 2, 'imageRepeat': 'repeatX', 'saturation': 0.5,
           'imageTint': {'r': 1, 'g': 0, 'b': 0, 'a': 1}, 'imageName': 'a.png',
           'alignment': {'data': {'x': 0.5, 'y': -0.5}}, 'sourceWidth': 400, 'sourceHeight': 200},
        ],
      },
      'box': {'type': 'rectangle', 'basicBoxLocal': [0, 0, 100, 100], 'path': 'M0 0 H10', 'strokeJoin': 'bevel',
              'strokeMiterLimit': 2},
    }));
    final n = (v2['nodes'] as Map).cast<String, Map>();
    final image = ((n['img']!['decoration']['fills'] as List).single as Map)['image'] as Map;
    expect(image['url'], 'https://x.com/c.png');
    expect(image['fit'], 'none');
    expect(image['repeat'], 'repeatX');
    expect(image['scale'], 2);
    expect(image['flipX'], true);
    expect(image.containsKey('flipY'), isFalse);
    expect(image['saturation'], 0.5);
    expect(image['tint'], '#FFFF0000');
    expect(image['imageName'], 'a.png');
    // Its source (400×200) at scale 2 is the box's size: SDK 8.x placed it
    // by hand (convertAlignmentToPosition) for alignment (0.5, -0.5).
    expect(image['rect'], [50, -25, 200, 100]);
    expect(n['box']!['props'], {'path': 'M0 0 H10', 'strokeJoin': 'bevel', 'strokeMiterLimit': 2});
  });
}
