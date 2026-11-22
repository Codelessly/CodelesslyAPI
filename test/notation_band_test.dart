// A page's band with a ground of its own: a picture (`Section image=`), and
// the ink of the texts written on a dark fill, a dark gradient, a picture
// or the accent.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import 'notation_words.dart';

const _theme = <String, Object?>{
  'primary': '#FF1F3A5F',
  'onPrimary': '#FFFFFFFF',
  'surface': '#FFFFFFFF',
  'onSurface': '#FF18181B',
  'colors': {'primaryText': '#FF18181B', 'secondaryText': '#FF52525B', 'night': '#FF101418', 'sand': '#FFF4EDE0', 'accent': '#FF1F3A5F', 'onAccent': '#FFFFFFFF'},
  'textStyles': {
    'body': {'fontSize': 13, 'color': 'primaryText'},
    'lead': {'fontSize': 15, 'color': 'secondaryText'},
    'caption': {'fontSize': 12, 'color': 'secondaryText'},
    'heading1': {'fontSize': 30, 'color': 'primaryText'},
  },
};

NotationResult _parse(String text) {
  final r = parseNotation(text, catalog: standardCatalog, options: withTestWords(NotationOptions.fromTheme(_theme, named: true, width: 1440)));
  expect(r.issues, isEmpty, reason: text);
  return r;
}

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id]! as Map).cast<String, Object?>();

Object? _ink(NotationResult r, String id) => ((_node(r, id)['props']! as Map)['style']! as Map)['color'];

String _band(String ground) => '''
Page
  Section#band $ground
    Text.heading1#head "Head"
    Text.lead#lead "Lead"
    Text.caption#small "Small"
    Text#own "Own" color=#FF00FF00
    Card
      Text#carded "On a card"
    Box fill=#FFFFFFFF
      Text#boxed "On a white box"
  Section#plain
    Text#after "After"
''';

void main() {
  test('on a dark fill, a dark gradient and a picture: the texts are light, a second and a third ink dimmer', () {
    for (final ground in ['fill=#FF101418', 'fill=night', 'gradient=["#FF16222E","#FF2E4A62"]', 'image="assets/harbour.jpg"']) {
      final r = _parse(_band(ground));
      expect(_ink(r, 'head'), '#FFFFFFFF', reason: ground);
      expect(_ink(r, 'lead'), '#D9FFFFFF', reason: ground);
      expect(_ink(r, 'small'), '#B3FFFFFF', reason: ground);
      expect(_ink(r, 'own'), '#FF00FF00', reason: 'a color written on the line is the line\'s');
      expect(_ink(r, 'carded'), isNot('#FFFFFFFF'), reason: 'a card on the band has its own ground');
      expect(_ink(r, 'boxed'), isNot('#FFFFFFFF'));
      expect(_ink(r, 'after'), isNot('#FFFFFFFF'), reason: 'the next band is the page\'s');
    }
  });

  test('on the accent: what the theme draws on it, by its name (so it follows the theme)', () {
    final r = _parse(_band('fill=primary'));
    expect(_ink(r, 'head'), 'onPrimary');
    expect(_ink(r, 'lead'), 'onPrimary');
  });

  test('on a light ground, a tint, a wash, or none: the theme\'s inks', () {
    for (final ground in ['fill=#FFF4EDE0', 'fill=sand', 'tint', 'gradient=["#FFFFFFFF","#FFEFEFEF"]', 'fill=#14000000', '']) {
      final r = _parse(_band(ground));
      expect(_ink(r, 'head'), isNot('#FFFFFFFF'), reason: ground);
      expect(_ink(r, 'lead'), isNot('#D9FFFFFF'), reason: ground);
    }
  });

  test('Section image="…": the picture covers the band under a scrim; scrim= says another, or none', () {
    var r = _parse(_band('image="assets/harbour.jpg"'));
    expect(jsonEncode((_node(r, 'band')['decoration']! as Map)['fills']), '[{"image":{"url":"assets/harbour.jpg","fit":"cover"}},{"color":"#73000000"}]');
    // A band with a ground has a section's whole space above its text.
    expect((_node(r, 'band')['layout']! as Map)['padding'], [24, 64, 24, 64]);
    r = _parse(_band('image="assets/harbour.jpg" scrim=#99102030'));
    expect(jsonEncode((_node(r, 'band')['decoration']! as Map)['fills']), contains('{"color":"#99102030"}'));
    r = _parse(_band('image="assets/harbour.jpg" scrim=none'));
    expect(jsonEncode((_node(r, 'band')['decoration']! as Map)['fills']), '[{"image":{"url":"assets/harbour.jpg","fit":"cover"}}]');
    expect(_ink(r, 'head'), isNot('#FFFFFFFF'), reason: 'with no scrim the picture is the writer\'s to write on');
  });

  test('a picture read from the state', () {
    final r = _parse('state cover="assets/a.jpg"\n${_band('image={cover}')}');
    expect(jsonEncode(_node(r, 'band')['bind']), contains('decoration.fills[0].image.url'));
    expect(_ink(r, 'head'), '#FFFFFFFF');
  });
}
