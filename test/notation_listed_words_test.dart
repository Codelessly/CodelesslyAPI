// Every look and word docs/reference/notation/NOTATION.md lists parses, with
// a site's theme and without one (test 9: `Text.pageTitle` was listed and
// refused under a site's theme; `FilterChip selected=@x` was refused though
// NOTATION.md writes `selected=@picked`).
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

final _doc = File('docs/reference/notation/NOTATION.md').readAsStringSync().replaceAll('\r\n', '\n');

/// A site's theme with styles of its own and none of SSUI's names.
final _site = NotationOptions.fromTheme({
  'primary': '#FF0D9488',
  'colors': {'ink': '#FF111827', 'muted': '#FF6B7280'},
  'textStyles': {
    'body': {'fontSize': 14, 'color': 'ink'},
    'title': {'fontSize': 22, 'fontWeight': 600, 'color': 'ink'},
  },
}, width: 1440, named: true);

void main() {
  final looks = [
    for (final line in _doc.split('\n'))
      if (RegExp(r'^- \w+ looks:').hasMatch(line))
        for (final m in RegExp(r'`([A-Z][A-Za-z]*\.[A-Za-z0-9]+)`').allMatches(line)) m[1]!,
  ];
  final words = [
    for (final line in _doc.split('\n'))
      if (RegExp(r'^- \*\*\d\. ').hasMatch(line))
        for (final m in RegExp(r'\[`([A-Za-z][A-Za-z0-9]*)`\]').allMatches(line)) m[1]!,
  ];

  test('the reference lists looks and words', () {
    expect(looks, containsAll(['Text.pageTitle', 'Text.heading1', 'Button.primary', 'Badge.success']));
    expect(words.length, greaterThan(40));
  });

  for (final (name, options) in [('without a theme', const NotationOptions(width: 1440)), ('with a site\'s theme', _site)]) {
    test('every look parses $name', () {
      final refused = <String>[];
      for (final look in looks) {
        final r = parseNotation('Column\n  $look "x"\n', catalog: standardCatalog, options: options);
        if (r.issues.isNotEmpty) refused.add('$look: ${r.issues.first.message}');
      }
      expect(refused, isEmpty);
    });

    test('every word is a word $name', () {
      final refused = <String>[];
      for (final word in words) {
        final r = parseNotation('Column\n  $word\n', catalog: standardCatalog, options: options);
        for (final i in r.issues) {
          if (RegExp(r'No node type|Unknown word|not a word', caseSensitive: false).hasMatch(i.message)) refused.add('$word: ${i.message}');
        }
      }
      expect(refused, isEmpty);
    });

    test('a control\'s value bound by its property\'s name, as NOTATION.md writes selected=@picked, $name', () {
      expect(_doc, contains('`selected=@picked`'));
      final r = parseNotation('state picked=false\nColumn\n  FilterChip#c "Unread" selected=@picked\n', catalog: standardCatalog, options: options);
      expect(r.issues, isEmpty);
      final bare = parseNotation('state picked=false\nColumn\n  FilterChip#c "Unread" @picked\n', catalog: standardCatalog, options: options);
      expect((r.document['nodes'] as Map)['c'], (bare.document['nodes'] as Map)['c']);
    });
  }
}
