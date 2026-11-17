// Paint, motion and charts in the notation (docs/design/22-notation-parity.md,
// 4.6): a node's custom paint and its animations are record lines under the
// node, one record a line. Each word below is written, expanded, checked in
// the document, printed, and printed back as the line it was.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text) => Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog));

Json _node(Json document, String id) => ((document['nodes'] as Map)[id] as Map).cast<String, Object?>();

/// [block] (record lines, two spaces a level) under `box#n w=120 h=80` in a
/// column: expanded with nothing said, node `n` returned; printed back, the
/// same lines are under the node, nothing is left in a `{…}` tail of its
/// records, and the print reads as the same document.
Json _roundTrip(String block, {String head = 'box#n w=120 h=80', String state = ''}) {
  final lines = const LineSplitter().convert(block.trimRight());
  final text = '${state}Column\n  $head\n${[for (final l in lines) '    $l'].join('\n')}';
  final r = _parse(text);
  expect(r.issues, isEmpty, reason: '${r.issues}');
  final printed = Catalog.run(standardCatalog, () => printNotation(r.document, catalog: standardCatalog));
  final out = const LineSplitter().convert(printed);
  final at = out.indexWhere((l) => l.trimLeft().startsWith(head.split(' ').first));
  expect(at, isNot(-1), reason: printed);
  expect(out.sublist(at + 1, at + 1 + lines.length), [for (final l in lines) '    $l'], reason: printed);
  for (final l in out) {
    expect(l.contains('"customPaint"') || l.contains('"animations"'), isFalse, reason: printed);
  }
  final back = _parse(printed);
  expect(back.issues, isEmpty, reason: '${back.issues}');
  expect(jsonEquality.equals(back.document, r.document), isTrue, reason: printed);
  return _node(r.document, 'n');
}

/// The ops of node [n]'s painter.
List<Object?> _painter(Json n) => (n['customPaint'] as Map)['painter'] as List;

/// A document of one box with [node]'s fields, printed: its lines.
String _print(Json node, {List<Object?> variables = const []}) {
  final doc = {
    'schema': 3,
    'roots': ['screen'],
    'nodes': {
      'screen': {'type': 'canvas', 'slots': {'body': 'n'}, 'layout': {'width': 390}},
      'n': node,
    },
    if (variables.isNotEmpty) 'variables': {'screen': variables},
  };
  final printed = Catalog.run(standardCatalog, () => printNotation(doc, catalog: standardCatalog));
  final back = _parse(printed);
  expect(back.issues, isEmpty, reason: '${back.issues}\n$printed');
  expect(jsonEquality.equals(_node(back.document, 'n'), node), isTrue, reason: printed);
  expect(printed.contains('"customPaint"') || printed.contains('"animations"'), isFalse, reason: printed);
  return printed;
}

void main() {
  group('customPaint: the head', () {
    test('viewBox, fit and the raster hints, the ops under it', () {
      final n = _roundTrip('customPaint viewBox=[0,0,48,48] fit=contain isComplex willChange\n'
          '  circle c=[24,24] radius=20 fill=#FF1E88E5');
      expect(n['customPaint'], {
        'viewBox': [0, 0, 48, 48],
        'fit': 'contain',
        'isComplex': true,
        'willChange': true,
        'painter': [
          {'op': 'circle', 'c': [24, 24], 'radius': 20, 'paint': '#FF1E88E5'},
        ],
      });
    });

    test('foregroundPainter: the ops drawn over the content, after the painter\'s', () {
      final n = _roundTrip('customPaint viewBox=[200,200]\n'
          '  circle c=[100,100] radius=96 fill=#FF1C2833\n'
          '  foregroundPainter\n'
          '    line p1=[0,14] p2=[0,-80] stroke=#FFE74C3C strokeWidth=3');
      final paint = n['customPaint'] as Map;
      expect((paint['painter'] as List).single, {'op': 'circle', 'c': [100, 100], 'radius': 96, 'paint': '#FF1C2833'});
      expect(paint['foregroundPainter'], [
        {
          'op': 'line',
          'p1': [0, 14],
          'p2': [0, -80],
          'paint': {'color': '#FFE74C3C', 'style': 'stroke', 'strokeWidth': 3},
        },
      ]);
    });

    test('a foregroundPainter alone', () {
      final n = _roundTrip('customPaint\n'
          '  foregroundPainter\n'
          '    rect rect=[0,0,10,10] fill=#FF000000');
      expect(n['customPaint'], {
        'foregroundPainter': [
          {'op': 'rect', 'rect': [0, 0, 10, 10], 'paint': '#FF000000'},
        ],
      });
    });
  });

  group('customPaint: each op', () {
    test('path: d, fillType, trims', () {
      final n = _roundTrip('customPaint\n  path d="M0 0 L10 10 Z" fillType=evenOdd trimStart=0.1 trimEnd={progress} fill=#FF7FB685',
          state: 'state progress=0.5\n');
      expect(_painter(n).single, {'op': 'path', 'd': 'M0 0 L10 10 Z', 'fillType': 'evenOdd', 'trimStart': 0.1, 'trimEnd': r'${progress}', 'paint': '#FF7FB685'});
    });

    test('path: commands, and points that close', () {
      final n = _roundTrip('customPaint\n'
          '  path commands=[{"moveTo":[0,"\${size.height}"]},{"lineTo":[10,0]},{"close":true}] stroke=#FF000000 strokeWidth=2\n'
          '  path points=[[0,0],[10,0],null,[10,10]] close fill=#FF111111');
      expect(_painter(n)[0], {
        'op': 'path',
        'commands': [
          {'moveTo': [0, r'${size.height}']},
          {'lineTo': [10, 0]},
          {'close': true},
        ],
        'paint': {'color': '#FF000000', 'style': 'stroke', 'strokeWidth': 2},
      });
      expect(_painter(n)[1], {
        'op': 'path',
        'points': [
          [0, 0],
          [10, 0],
          null,
          [10, 10],
        ],
        'close': true,
        'paint': '#FF111111',
      });
    });

    test('line, rect, rrect, circle, oval', () {
      final n = _roundTrip('customPaint\n'
          '  line p1=[40,196] p2=[280,196] stroke=#33FFFFFF strokeWidth=2\n'
          '  rect rect=[0,0,320,200] fill=#FFE8F1F8\n'
          '  rrect rect=[0,0,28,28] radius=9 fill=#FF2563EB\n'
          '  rrect rect=[0,0,28,28] radius=[4,8] fill=#FF2563EB\n'
          '  circle c=[236,62] radius=28 fill=#FFF4B740\n'
          '  oval rect=[80,220,80,10] fill={theme.colors.artShadow}');
      expect([for (final o in _painter(n)) (o! as Map)['op']], ['line', 'rect', 'rrect', 'rrect', 'circle', 'oval']);
      expect((_painter(n)[3]! as Map)['radius'], [4, 8]);
      expect((_painter(n)[5]! as Map)['paint'], r'${theme.colors.artShadow}');
    });

    test('arc and points', () {
      final n = _roundTrip('customPaint\n'
          '  arc rect=[4,4,40,40] startAngle=-1.5708 sweepAngle={value * 6.2832} useCenter fill=#FF22C55E\n'
          '  points pointMode=polygon points=[[0,0],[5,5],[10,0]] stroke=#FF000000 strokeWidth=1',
          state: 'state value=0.25\n');
      expect(_painter(n)[0], {'op': 'arc', 'rect': [4, 4, 40, 40], 'startAngle': -1.5708, 'sweepAngle': r'${= value * 6.2832}', 'useCenter': true, 'paint': '#FF22C55E'});
      expect((_painter(n)[1]! as Map)['pointMode'], 'polygon');
    });

    test('paragraph: its text first, {name} in it read from the state', () {
      final n = _roundTrip('customPaint\n'
          '  paragraph "Day {day}" offset=[{20 + 4},104] anchor=[0,-1] maxWidth=80 textAlign=center maxLines=1 style={"fontSize":10,"color":"#FF607D8B"}',
          state: 'state day=3\n');
      expect(_painter(n).single, {
        'op': 'paragraph',
        'text': r'Day ${day}',
        'offset': [r'${= 20 + 4}', 104],
        'anchor': [0, -1],
        'maxWidth': 80,
        'textAlign': 'center',
        'maxLines': 1,
        'style': {'fontSize': 10, 'color': '#FF607D8B'},
      });
    });

    test('image: its url first', () {
      final n = _roundTrip('customPaint\n  image "https://example.com/a.png" src=[0,0,64,64] dst=[0,0,32,32]');
      expect(_painter(n).single, {'op': 'image', 'url': 'https://example.com/a.png', 'src': [0, 0, 64, 64], 'dst': [0, 0, 32, 32]});
    });

    test('group: transforms, clips and a layer, its ops under it', () {
      final n = _roundTrip('customPaint\n'
          '  group#needle translate=[100,100] scale=[2,1] rotate={radians(value * 6)} clipRect=[0,0,50,50] opacity=0.55 blendMode=multiply\n'
          '    line p1=[0,14] p2=[0,-80] stroke=#FFE74C3C strokeWidth=3 strokeCap=round\n'
          '  group transform=[1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1] clipRRect={"rect":[0,0,10,10],"radius":4} clipPath="M0 0 L5 5 Z"\n'
          '    rect rect=[0,0,10,10] fill=#FF000000',
          state: 'state value=10\n');
      final g = _painter(n)[0]! as Map;
      expect(g['id'], 'needle');
      expect(g['rotate'], r'${= radians(value * 6)}');
      expect(g['opacity'], 0.55);
      expect((g['ops'] as List).single, isA<Map>());
      expect((_painter(n)[1]! as Map)['clipRRect'], {'rect': [0, 0, 10, 10], 'radius': 4});
    });

    test('repeat: count or each, as and indexAs, its ops under it', () {
      final n = _roundTrip('customPaint viewBox=[320,200]\n'
          '  repeat count=3\n'
          '    circle c=[{60 + index * 34},{48 + index * 6}] radius=3 fill=#FF5D6D7E\n'
          '  repeat each={cells} as=cell indexAs=i\n'
          '    rect when={cell != 0} rect=[{i % 48},{floor(i / 48)},1,1] hit=cell fill={pal[cell]}',
          state: 'state cells=[0,1]\nstate pal=["#FF000000","#FFFFFFFF"]\n');
      expect(_painter(n)[0], {
        'op': 'repeat',
        'count': 3,
        'ops': [
          {'op': 'circle', 'c': [r'${= 60 + index * 34}', r'${= 48 + index * 6}'], 'radius': 3, 'paint': '#FF5D6D7E'},
        ],
      });
      expect(_painter(n)[1], {
        'op': 'repeat',
        'each': r'${cells}',
        'as': 'cell',
        'indexAs': 'i',
        'ops': [
          {'op': 'rect', 'when': r'${= cell != 0}', 'rect': [r'${= i % 48}', r'${= floor(i / 48)}', 1, 1], 'hit': 'cell', 'paint': r'${= pal[cell]}'},
        ],
      });
    });

    test('an op\'s id, when and hit', () {
      final n = _roundTrip('customPaint\n  circle#dot when={on} c=[12,12] radius=4 hit=dot fill={on ? "#FF22C55E" : "#FF9CA3AF"}', state: 'state on=true\n');
      expect(_painter(n).single, {'op': 'circle', 'id': 'dot', 'when': r'${on}', 'c': [12, 12], 'radius': 4, 'hit': 'dot', 'paint': r'${= on ? "#FF22C55E" : "#FF9CA3AF"}'});
    });

    test('a {…} at the end of an op\'s line is merged into it', () {
      final r = _parse('Column\n  box#n\n    customPaint\n      circle c=[1,1] radius=1 {"radius":2,"extra":true}');
      expect(r.issues, isEmpty);
      expect(_painter(_node(r.document, 'n')).single, {'op': 'circle', 'c': [1, 1], 'radius': 2, 'extra': true});
      // What the op does not declare is printed in its {…}.
      final printed = _print({'type': 'box', 'customPaint': {'painter': [{'op': 'circle', 'c': [1, 1], 'radius': 2, 'extra': true}]}});
      expect(printed, contains('    circle c=[1,1] radius=2 {"extra":true}'));
    });
  });

  group('customPaint: the paint', () {
    test('fill= is the paint as written; stroke= a stroking paint with its own fields', () {
      final n = _roundTrip('customPaint\n'
          '  circle c=[12,12] radius=4 fill={pal}\n'
          '  path d="M7 17 C 7 5, 21 5, 21 17" stroke={theme.colors.accent} strokeWidth=2.6 strokeCap=round strokeJoin=round strokeMiterLimit=2 dashPattern=[1,9] scaleStroke=false\n'
          '  circle c=[100,100] radius=96 fill=#FF1C2833 stroke=#FF5D6D7E strokeWidth=3',
          state: 'state pal="#FF000000"\n');
      expect((_painter(n)[0]! as Map)['paint'], r'${pal}');
      expect((_painter(n)[1]! as Map)['paint'], {
        'color': r'${theme.colors.accent}',
        'style': 'stroke',
        'strokeWidth': 2.6,
        'strokeCap': 'round',
        'strokeJoin': 'round',
        'strokeMiterLimit': 2,
        'dashPattern': [1, 9],
        'scaleStroke': false,
      });
      expect((_painter(n)[2]! as Map)['paint'], [
        '#FF1C2833',
        {'color': '#FF5D6D7E', 'style': 'stroke', 'strokeWidth': 3},
      ]);
    });

    test('paint= is what fill and stroke cannot say', () {
      final n = _roundTrip('customPaint\n'
          '  rect rect=[0,0,48,48] paint={"shader":{"type":"radial","stops":[{"position":0.35,"color":"#FFF3E7B8"},{"position":1,"color":"#FFD9C27A"}]}}\n'
          '  rect rect=[0,0,48,48] paint=[{"color":"#FF000000","style":"stroke","strokeWidth":1},"#FFFFFFFF"]\n'
          '  rect rect=[0,0,48,48] paint={"color":"#FF000000","blendMode":"multiply"}\n'
          '  rect rect=[0,0,48,48] paint={"id":"bg","color":"#FF000000","isAntiAlias":false,"style":"fill"}');
      expect((_painter(n)[0]! as Map)['paint'], isA<Map>());
      expect(((_painter(n)[1]! as Map)['paint'] as List).last, '#FFFFFFFF');
    });

    test('a paint worked out whole', () {
      final n = _roundTrip("customPaint\n  rrect rect=[0,0,28,28] radius=9 fill={{'shader': {'type': 'linear', 'stops': [{'position': 0, 'color': theme.colors.brand}]}}}");
      expect((_painter(n).single! as Map)['paint'], r"${= {'shader': {'type': 'linear', 'stops': [{'position': 0, 'color': theme.colors.brand}]}}}");
    });
  });

  group('animations', () {
    test('animate=<word> prints as the word, with its duration and delay', () {
      for (final word in ['fade', 'fade-up', 'slide-down', 'slide-left', 'slide-right', 'scale', 'pulse', 'spin', 'bob', 'sway', 'pop', 'bounce', 'shake', 'wiggle', 'flash', 'shimmer']) {
        final r = _parse('Column\n  Text#t "Hi" animate=$word duration=400 delay=200');
        expect(r.issues, isEmpty);
        final printed = Catalog.run(standardCatalog, () => printNotation(r.document, catalog: standardCatalog));
        expect(printed, contains('animate=$word duration=400 delay=200'), reason: printed);
        expect(printed, isNot(contains('"animations"')));
        expect(jsonEquality.equals(_parse(printed).document, r.document), isTrue);
      }
      // A word that stands for the same as another prints as the first.
      final r = _parse('Column\n  Text#t "Hi" animate=slide-up');
      expect(Catalog.run(standardCatalog, () => printNotation(r.document, catalog: standardCatalog)), contains('animate=fade-up'));
    });

    test('an animation and its tracks, every field by its own name', () {
      final n = _roundTrip('animation#enter duration=700 reverseDuration=300 delay=40 curve=easeOutCubic repeat={"reverse":true,"count":3} autoplay '
          'playKey={step} paused=false phase=0.25 spring={"duration":450,"bounce":0.3} alignment=center previewAt=0.5 ramp=100 visibleFraction=0.3 enabled={on} progress={view.progress}\n'
          '  track#drop path=motion.translateY from=-260 curve=easeOutCubic\n'
          '  track#fade path=opacity from=0 to=1 interval=[0,0.33] curve=easeOut blend=multiply\n'
          '  track node=label variable=x keyframes=[{"at":0,"value":0},{"at":1,"value":1,"curve":"easeIn"}] wave=[{"cycles":2}] interpolation=monotoneCubic',
          state: 'state step=0\nstate on=true\nstate x=0\n');
      final a = (n['animations'] as List).single as Map;
      expect(a['id'], 'enter');
      expect(a['repeat'], {'reverse': true, 'count': 3});
      expect(a['autoplay'], true);
      expect(a['playKey'], r'${step}');
      expect(a['enabled'], r'${on}');
      expect(a['tracks'], [
        {'id': 'drop', 'path': 'motion.translateY', 'from': -260, 'curve': 'easeOutCubic'},
        {'id': 'fade', 'path': 'opacity', 'from': 0, 'to': 1, 'interval': [0, 0.33], 'curve': 'easeOut', 'blend': 'multiply'},
        {
          'node': 'label',
          'variable': 'x',
          'keyframes': [
            {'at': 0, 'value': 0},
            {'at': 1, 'value': 1, 'curve': 'easeIn'},
          ],
          'wave': [
            {'cycles': 2},
          ],
          'interpolation': 'monotoneCubic',
        },
      ]);
    });

    test('a transition: how a change of a property animates, one a line', () {
      final n = _roundTrip('transition property=opacity duration=200 delay=50 curve=easeOut\n'
          'transition property=motion spring={"duration":450,"bounce":0.3}\n'
          'transition property=props.text duration=800 keyframes=[{"at":0.5,"value":0.2}] interpolation=monotoneCubic');
      expect(n['transitions'], [
        {'property': 'opacity', 'duration': 200, 'delay': 50, 'curve': 'easeOut'},
        {'property': 'motion', 'spring': {'duration': 450, 'bounce': 0.3}},
        {
          'property': 'props.text',
          'duration': 800,
          'keyframes': [
            {'at': 0.5, 'value': 0.2},
          ],
          'interpolation': 'monotoneCubic',
        },
      ]);
      expect([for (final i in _parse('Column\n  box\n    transition property=opacity\n      track path=x').issues) i.message], [contains('Nothing goes under this line')]);
    });

    test('a preset with its params, and an animation after animate=', () {
      final n = _roundTrip('animation#halo preset=pulse params={"scaleTo":1.4,"opacityTo":0} duration=1600\n'
          'animation#year duration=60000 repeat={}',
          head: 'box#n w=120 h=80 animate=fade');
      expect([for (final a in n['animations'] as List) (a as Map)['id']], ['a', 'halo', 'year']);
    });
  });

  group('from the corpus and the guide', () {
    test('tool/reference/examples/paint_illustration.json', () {
      final printed = _print({
        'type': 'box',
        'layout': {'width': {'fill': 342}, 'height': 212},
        'customPaint': {
          'viewBox': [320, 200],
          'fit': 'cover',
          'painter': [
            {'op': 'rect', 'rect': [0, 0, 320, 200], 'paint': '#FFE8F1F8'},
            {'op': 'circle', 'c': [236, 62], 'radius': 28, 'paint': '#FFF4B740'},
            {
              'op': 'repeat',
              'count': 3,
              'ops': [
                {'op': 'circle', 'c': [r'${= 60 + index * 34}', r'${= 48 + index * 6}'], 'radius': 3, 'paint': '#FF5D6D7E'},
              ],
            },
            {'op': 'path', 'd': 'M0 150 C60 100 120 110 170 140 C220 170 270 120 320 130 L320 200 L0 200 Z', 'paint': '#FF7FB685'},
            {'op': 'line', 'p1': [40, 196], 'p2': [280, 196], 'paint': {'color': '#33FFFFFF', 'style': 'stroke', 'strokeWidth': 2}},
          ],
        },
      });
      expect(
          printed,
          contains('  customPaint viewBox=[320,200] fit=cover\n'
              '    rect rect=[0,0,320,200] fill=#FFE8F1F8\n'
              '    circle c=[236,62] radius=28 fill=#FFF4B740\n'
              '    repeat count=3\n'
              '      circle c=[{60 + index * 34},{48 + index * 6}] radius=3 fill=#FF5D6D7E\n'
              '    path d="M0 150 C60 100 120 110 170 140 C220 170 270 120 320 130 L320 200 L0 200 Z" fill=#FF7FB685\n'
              '    line p1=[40,196] p2=[280,196] stroke=#33FFFFFF strokeWidth=2'));
    });

    test('CodelesslySDK examples/prompt_app/polish/bar/home.json: top_mark and the enter animation', () {
      final printed = _print({
        'type': 'box',
        'layout': {'width': 30, 'height': 30},
        'customPaint': {
          'viewBox': [28, 28],
          'painter': [
            {
              'op': 'rrect',
              'rect': [0, 0, 28, 28],
              'radius': 9,
              'paint':
                  r"${= {'shader': {'type': 'linear', 'begin': 'topLeft', 'end': 'bottomRight', 'stops': [{'position': 0, 'color': theme.colors.brandBright}, {'position': 1, 'color': theme.colors.brand}]}}}",
            },
            {
              'op': 'path',
              'd': 'M7 17 C 7 5, 21 5, 21 17',
              'paint': {'color': r'${theme.colors.accent}', 'style': 'stroke', 'strokeWidth': 2.6, 'strokeCap': 'round', 'strokeJoin': 'round'},
            },
            {'op': 'circle', 'c': [14, 18.5], 'radius': 2.6, 'paint': r'${theme.colors.onBrand}'},
          ],
        },
        'animations': [
          {
            'id': 'enter',
            'duration': 520,
            'delay': 0,
            'curve': 'easeOutCubic',
            'tracks': [
              {'path': 'opacity', 'from': 0, 'to': 1},
              {'path': 'motion.translateY', 'from': 14, 'to': 0},
            ],
          },
        ],
      });
      expect(
          printed,
          contains('  customPaint viewBox=[28,28]\n'
              "    rrect rect=[0,0,28,28] radius=9 fill={{'shader': {'type': 'linear', 'begin': 'topLeft', 'end': 'bottomRight', 'stops': [{'position': 0, 'color': theme.colors.brandBright}, {'position': 1, 'color': theme.colors.brand}]}}}\n"
              '    path d="M7 17 C 7 5, 21 5, 21 17" stroke={theme.colors.accent} strokeWidth=2.6 strokeCap=round strokeJoin=round\n'
              '    circle c=[14,18.5] radius=2.6 fill={theme.colors.onBrand}\n'
              '  animation#enter duration=520 delay=0 curve=easeOutCubic\n'
              '    track path=opacity from=0 to=1\n'
              '    track path=motion.translateY from=14 to=0'));
    });

    test('CodelesslySDK examples/showcase/desktop/native/site_landing.json: hero_figure, groups and dashes', () {
      final printed = _print({
        'type': 'box',
        'customPaint': {
          'viewBox': [240, 240],
          'fit': 'contain',
          'painter': [
            {
              'op': 'group',
              'ops': [
                {
                  'op': 'path',
                  'd': 'M48 122 C 18 176, 66 232, 120 232 C 174 232, 222 176, 192 122',
                  'paint': {'color': r'${theme.colors.artRope}', 'style': 'stroke', 'strokeWidth': 3, 'strokeCap': 'round', 'strokeJoin': 'round', 'dashPattern': [1, 9]},
                },
              ],
              'opacity': 0.55,
            },
            {'op': 'oval', 'rect': [80, 220, 80, 10], 'paint': r'${theme.colors.artShadow}'},
          ],
        },
        'animations': [
          {
            'id': 'bob',
            'duration': 640,
            'curve': 'easeInOutSine',
            'repeat': {'reverse': true},
            'tracks': [
              {'path': 'motion.translateY', 'from': 3, 'to': -5},
            ],
          },
        ],
      });
      expect(
          printed,
          contains('  customPaint viewBox=[240,240] fit=contain\n'
              '    group opacity=0.55\n'
              '      path d="M48 122 C 18 176, 66 232, 120 232 C 174 232, 222 176, 192 122" stroke={theme.colors.artRope} strokeWidth=3 strokeCap=round strokeJoin=round dashPattern=[1,9]\n'
              '    oval rect=[80,220,80,10] fill={theme.colors.artShadow}\n'
              '  animation#bob duration=640 curve=easeInOutSine repeat={"reverse":true}\n'
              '    track path=motion.translateY from=3 to=-5'));
    });

    test('the guide\'s dial (docs/guide/07-custom-paint.md)', () {
      final paint = {
        'viewBox': [200, 200],
        'painter': [
          {
            'op': 'circle',
            'c': [100, 100],
            'radius': 96,
            'paint': ['#FF1C2833', {'color': '#FF5D6D7E', 'style': 'stroke', 'strokeWidth': 3}],
          },
          {
            'op': 'repeat',
            'count': r'${ticks}',
            'ops': [
              {
                'op': 'group',
                'translate': [100, 100],
                'rotate': r'${= radians(index * 360 / count)}',
                'ops': [
                  {
                    'op': 'line',
                    'p1': [0, -90],
                    'p2': [0, r'${= index % 5 == 0 ? -76 : -84}'],
                    'paint': {'color': '#FFE8ECEE', 'style': 'stroke', 'strokeWidth': r'${= index % 5 == 0 ? 3 : 1.5}', 'strokeCap': 'round'},
                  },
                ],
              },
            ],
          },
        ],
        'foregroundPainter': [
          {
            'op': 'group',
            'id': 'needle',
            'translate': [100, 100],
            'rotate': r'${= radians(value * 6)}',
            'ops': [
              {'op': 'line', 'p1': [0, 14], 'p2': [0, -80], 'paint': {'color': '#FFE74C3C', 'style': 'stroke', 'strokeWidth': 3, 'strokeCap': 'round'}},
            ],
          },
        ],
      };
      final printed = _print({'type': 'box', 'layout': {'width': 200, 'height': 200}, 'customPaint': paint}, variables: [
        {'name': 'ticks', 'type': 'integer', 'value': 60},
        {'name': 'value', 'type': 'decimal', 'value': 0},
      ]);
      expect(
          printed,
          contains('  customPaint viewBox=[200,200]\n'
              '    circle c=[100,100] radius=96 fill=#FF1C2833 stroke=#FF5D6D7E strokeWidth=3\n'
              '    repeat count={ticks}\n'
              '      group translate=[100,100] rotate={radians(index * 360 / count)}\n'
              '        line p1=[0,-90] p2=[0,{index % 5 == 0 ? -76 : -84}] stroke=#FFE8ECEE strokeWidth={index % 5 == 0 ? 3 : 1.5} strokeCap=round\n'
              '    foregroundPainter\n'
              '      group#needle translate=[100,100] rotate={radians(value * 6)}\n'
              '        line p1=[0,14] p2=[0,-80] stroke=#FFE74C3C strokeWidth=3 strokeCap=round'));
    });

    test('the animation guide\'s samples (docs/guide/08-animation.md)', () {
      for (final a in [
        {
          'id': 'enter',
          'duration': 700,
          'tracks': [
            {'id': 'drop', 'path': 'motion.translateY', 'from': -260, 'curve': 'easeOutCubic'},
            {'id': 'fade', 'path': 'opacity', 'from': 0, 'interval': [0, 0.33], 'curve': 'easeOut'},
          ],
        },
        {'id': 'year', 'duration': 60000, 'repeat': {}},
        {'id': 'halo', 'preset': 'pulse', 'params': {'scaleTo': 1.4, 'opacityTo': 0}, 'duration': 1600},
        {'id': 'nudge', 'preset': 'shake', 'params': {'cycles': 3}},
        {
          'id': 'flip',
          'autoplay': false,
          'spring': {'duration': 450, 'bounce': 0.3},
          'tracks': [
            {'path': 'motion.rotateY', 'from': 0, 'to': 180},
          ],
        },
        {
          'id': 'enter',
          'duration': 600,
          'curve': 'easeOut',
          'visibleFraction': 0.3,
          'tracks': [
            {'path': 'opacity', 'from': 0, 'to': 1},
            {'path': 'motion.translateY', 'from': 24, 'to': 0},
          ],
        },
      ]) {
        final printed = _print({'type': 'box', 'animations': [a]});
        expect(printed, contains('  animation#${a['id']} '), reason: printed);
      }
    });
  });

  group('what is said', () {
    List<String> said(String text) => [for (final i in _parse(text).issues) i.message];

    test('an op the API does not have, with the nearest one', () {
      expect(said('Column\n  box\n    customPaint\n      circel c=[1,1] radius=1'), [contains('No op "circel": did you mean circle?')]);
    });

    test('a key the op does not take: said, and kept', () {
      final r = _parse('Column\n  box#n\n    customPaint\n      circle c=[1,1] radus=4');
      expect(r.issues.single.message, contains('A circle has no "radus": did you mean radius?'));
      expect(_painter(_node(r.document, 'n')).single, {'op': 'circle', 'c': [1, 1], 'radus': 4});
    });

    test('a stroke\'s field without stroke=', () {
      expect(said('Column\n  box\n    customPaint\n      circle c=[1,1] radius=1 strokeWidth=2'), [contains('strokeWidth goes with stroke=')]);
    });

    test('a line under an op that takes none, a track outside an animation, a head with no node', () {
      expect(said('Column\n  box\n    customPaint\n      circle c=[1,1] radius=1\n        rect rect=[0,0,1,1]'), [contains('A circle takes no ops under it')]);
      expect(said('Column\n  box\n    animation#a duration=300\n      circle c=[1,1]'), [contains('Under an animation each line is a track')]);
      expect(said('customPaint viewBox=[10,10]'), [contains('A customPaint line goes under the node')]);
      expect(said('Column\n  box\n    animation#a duraton=300'), [contains('did you mean duration?')]);
    });

    test('with the open vocabulary, a word a record does not take is recorded', () {
      final r = Catalog.run(
          standardCatalog,
          () => parseNotation('Column\n  box#n\n    customPaint\n      circel c=[1,1]\n      circle c=[1,1] radus=4\n    animation#a duraton=300',
              catalog: standardCatalog, options: const NotationOptions().open()));
      expect(r.issues, isEmpty);
      expect([for (final u in r.vocabulary) '${u.kind} ${u.word} ${u.on}'], ['type circel customPaint', 'parameter radus circle', 'parameter duraton animation']);
      expect(_painter(_node(r.document, 'n')), [
        {'op': 'circel', 'c': [1, 1]},
        {'op': 'circle', 'c': [1, 1], 'radus': 4},
      ]);
    });

    test('a line after the block is the node\'s child again; an op named like a node type is an op', () {
      final r = _parse('Column\n  Column#n\n    customPaint\n      path d="M0 0 L1 1" fill=#FF000000\n      paragraph "x"\n    Text "under the column"');
      expect(r.issues, isEmpty);
      expect([for (final o in _painter(_node(r.document, 'n'))) (o! as Map)['op']], ['path', 'paragraph']);
      expect((_node(r.document, 'n')['children'] as List).length, 1);
    });
  });

  test('as it arrives: the ops are sent as patches of their node', () {
    const text = 'Column\n  box#n w=40 h=40\n    customPaint viewBox=[40,40]\n      circle c=[20,20] radius=10 fill=#FF000000\n'
        '      group opacity=0.5\n        rect rect=[0,0,4,4] fill=#FFFFFFFF\n    animation#a duration=300\n      track path=opacity from=0 to=1\n  Text "after"\n';
    final stream = Catalog.run(standardCatalog, () => NotationStream(catalog: standardCatalog));
    var doc = LayoutDocument(catalog: standardCatalog);
    for (var i = 0; i < text.length; i += 7) {
      final ops = stream.add(text.substring(i, i + 7 > text.length ? text.length : i + 7));
      if (ops.isEmpty) continue;
      final a = applyOps(doc, {'ops': ops}, catalog: standardCatalog);
      expect(a.errors, isEmpty, reason: '${a.errors}');
      doc = a.document;
    }
    final last = stream.close();
    if (last.isNotEmpty) doc = applyOps(doc, {'ops': last}, catalog: standardCatalog).document;
    final whole = _node(_parse(text).document, 'n');
    final n = doc['n']!.toJson();
    expect(n['customPaint'], whole['customPaint']);
    expect(n['animations'], whole['animations']);
  });

  test('a customPaint block is the node\'s custom paint whole', () {
    final r = _parse('Column\n  box#n {"customPaint":{"fit":"cover","painter":[{"op":"rect"}]}}\n    customPaint viewBox=[4,4]\n      circle c=[2,2] radius=1');
    expect(r.issues, isEmpty);
    expect(_node(r.document, 'n')['customPaint'], {
      'viewBox': [4, 4],
      'painter': [
        {'op': 'circle', 'c': [2, 2], 'radius': 1},
      ],
    });
  });

  group('charts', () {
    /// [node] printed: its line, with none of [keys] in its `{…}` tail.
    String chartLine(Json node, List<String> keys, {List<Object?> variables = const []}) {
      final doc = {
        'schema': 3,
        'roots': ['screen'],
        'nodes': {
          'screen': {'type': 'canvas', 'slots': {'body': 'n'}, 'layout': {'width': 390}},
          'n': node,
        },
        if (variables.isNotEmpty) 'variables': {'screen': variables},
      };
      final printed = Catalog.run(standardCatalog, () => printNotation(doc, catalog: standardCatalog));
      expect(jsonEquality.equals(_node(_parse(printed).document, 'n'), node), isTrue, reason: printed);
      final line = const LineSplitter().convert(printed).firstWhere((l) => l.contains('#n'));
      final at = line.indexOf(' {"');
      final tail = at < 0 ? '' : line.substring(at);
      for (final k in keys) {
        expect(tail.contains('"$k"'), isFalse, reason: line);
      }
      return line;
    }

    test('a line chart\'s points are the values= they were written as', () {
      final r = _parse('Column\n  lineChart#n values=[1200,1650,1400] h=140');
      expect(_node(r.document, 'n')['props'], containsPair('data', [
        {'x': 0, 'y': 1200},
        {'x': 1, 'y': 1650},
        {'x': 2, 'y': 1400},
      ]));
      expect(chartLine(_node(r.document, 'n'), ['data', 'xField', 'yField']), contains('values=[1200,1650,1400]'));
      // From the state: the points worked out.
      final s = _parse('state ys=[1,2]\nColumn\n  lineChart#n values={ys}');
      expect((_node(s.document, 'n')['bind'] as Map)['props.data'], r'${= map(range(length(ys)), i => {"x": i, "y": (ys)[i]})}');
      expect(
          chartLine(_node(s.document, 'n'), ['data', 'xField', 'yField', 'props.data'], variables: [
            {'name': 'ys', 'type': 'list', 'value': [1, 2]},
          ]),
          contains('values={ys}'));
    });

    test('a chart\'s series, reference lines and axis labels (CodelesslySDK examples, revChart)', () {
      final node = {
        'type': 'chart',
        'layout': {'width': {'fill': 584}, 'height': {'fill': 236}},
        'props': {
          'chartType': 'line',
          'labelField': 'label',
          'series': [
            {'field': 'revenue', 'name': 'Revenue', 'kind': 'area', 'color': '#FF2563EB', 'curved': true, 'endDot': true, 'strokeWidth': 2.5, 'fillOpacity': 0.12},
          ],
          'referenceLines': [
            {'value': 30, 'label': 'Goal', 'dashed': true},
          ],
          'xLabels': [
            {'x': 0, 'label': 'Jan'},
          ],
          'minY': 20,
          'maxY': 45,
        },
        'bind': {'props.data': r'${months}'},
      };
      final line = chartLine(node, ['series', 'referenceLines', 'xLabels']);
      expect(line, contains('series=[{"field":"revenue","name":"Revenue","kind":"area","color":"#FF2563EB","curved":true,"endDot":true,"strokeWidth":2.5,"fillOpacity":0.12}]'));
      expect(line, contains('referenceLines=[{"value":30,"label":"Goal","dashed":true}]'));
      expect(line, contains('xLabels=[{"x":0,"label":"Jan"}]'));
    });

    test('a bar chart\'s values, labels, colors and grid labels', () {
      final r = _parse('Column\n  barChart#n values=[320,540] labels=["Wk 1","Wk 2"] colors=["#FF000000","#FF111111"] gridLabels=["0","500"]');
      expect(r.issues, isEmpty);
      final line = chartLine(_node(r.document, 'n'), ['values', 'labels', 'colors', 'gridLabels']);
      expect(line, contains('values=[320,540] labels=["Wk 1","Wk 2"] colors=["#FF000000","#FF111111"] gridLabels=["0","500"]'));
    });

    test('a plot chart\'s lists, a line chart\'s marks', () {
      final plot = {
        'type': 'plotChart',
        'props': {
          'points': [0, 1, 4, 9],
          'ranges': [
            {'from': 0, 'to': 1, 'label': 'low'},
          ],
          'markers': [
            {'x': 2, 'label': 'peak', 'shape': 'ring'},
          ],
          'yLines': [
            {'y': 5, 'dashed': true},
          ],
          'series': [
            {'points': [1, 2, 3, 4], 'color': '#FF000000'},
          ],
        },
      };
      expect(chartLine(plot, ['points', 'ranges', 'markers', 'yLines', 'series']), contains('ranges=[{"from":0,"to":1,"label":"low"}]'));
      final line = {
        'type': 'lineChart',
        'props': {
          'data': [
            {'t': 0, 'v': 1},
          ],
          'xField': 't',
          'yField': 'v',
          'bands': [
            {'from': 0, 'to': 1},
          ],
          'referenceLines': [
            {'y': 1},
          ],
          'markers': [
            {'x': 0, 'label': 'a'},
          ],
          'yTicks': [
            {'y': 0, 'label': '0'},
          ],
          'xTicks': [
            {'x': 0, 'label': 'Mon'},
          ],
          'areaBands': [
            {'from': 0, 'to': 1},
          ],
          'verticalLines': [
            {'x': 0},
          ],
        },
      };
      expect(chartLine(line, ['data', 'bands', 'referenceLines', 'markers', 'yTicks', 'xTicks', 'areaBands', 'verticalLines']), contains('data=[{"t":0,"v":1}]'));
    });

    test('radialGauge is the node as written; Gauge is the notation\'s gauge', () {
      final r = _parse('Column\n  radialGauge#n value=40 zones=[{"from":0,"to":50,"color":"#FF00FF00"}] labels=[0,50,100]\n  Gauge#g 72 unit="km/h"');
      expect(r.issues, isEmpty);
      final n = _node(r.document, 'n');
      expect(n['type'], 'radialGauge');
      expect(n['children'], isNull);
      expect(n['props'], {
        'value': 40,
        'zones': [
          {'from': 0, 'to': 50, 'color': '#FF00FF00'},
        ],
        'labels': [0, 50, 100],
      });
      expect(_node(r.document, 'g')['type'], 'stack');
      expect(chartLine(n, ['zones', 'labels']), contains('zones=[{"from":0,"to":50,"color":"#FF00FF00"}] labels=[0,50,100]'));
    });
  });
}
