// A loop's name (`each x in …`, `Table#t x in …`) is the document's item
// wherever a line reads it: in every key's expression, after a quoted text,
// beside string literals, inside a lambda. Test 9 (second cycle): a Text's
// color={…} and decoration={…} kept the loop's name after a quoted text, and
// a lambda in runs={…} kept it too; nothing said so.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/keys.dart' show notationTextStyleKeys;
import 'package:test/test.dart';

NotationResult _parse(String text) => parseNotation(text, catalog: standardCatalog);

/// The loop's own name, read anywhere in the document (not inside a word).
final _kept = RegExp(r'(?<![A-Za-z0-9_.])x\.on');

/// The words a line of [type] takes with a value: its own and the
/// universal ones.
Set<String> _keys(String type) => {
      for (final p in standardCatalog.widget(type)?.props ?? const []) p.key,
      for (final e in notationUniversal.entries)
        if (e.value.kind == UniversalKind.parameter) e.key,
      if (type == 'text') ...notationTextStyleKeys.keys,
    };

void main() {
  const lines = {
    'text': 'Text "{x.name}"',
    'row': 'Row',
    'icon': 'Icon "star"',
    'filledButton': 'Button "{x.name}"',
    'checkbox': 'Checkbox "{x.name}"',
  };

  for (final where in ['each', 'table']) {
    for (final e in lines.entries) {
      test('$where: every key of a ${e.key} line reads the item', () {
        final kept = <String>[];
        for (final key in _keys(e.key)) {
          if (const {'id', 'text', 'label', 'value', 'children'}.contains(key)) continue;
          final head = where == 'each' ? '  each x in rows' : '  Table#t x in rows columns=[{"key":"a","label":"A"}]';
          final text = '''
state rows:list=[{"name":"a","on":true}]
Column
$head
    ${e.value} $key={x.on ? 'a' : 'b'}
''';
          final r = _parse(text);
          if (_kept.hasMatch(jsonEncode(r.document))) kept.add(key);
        }
        expect(kept, isEmpty, reason: 'keys whose expression kept the loop\'s name');
      });
    }
  }

  test('inside a lambda, beside literals, after a quoted text', () {
    final r = _parse('''
state rows:list=[{"name":"a","on":true}]
Column
  each x in rows
    Text#t "{x.name}" runs={map(matchRuns(x.name, 'a'), r => with(r, 'style', object('color', x.on ? '#FF00FF00' : '#FF000000')))}
''');
    final doc = jsonEncode(r.document);
    expect(RegExp(r'(?<![A-Za-z0-9_.])x\.(on|name)').hasMatch(doc), isFalse, reason: doc);
  });

  test('a Text decoration={…} follows the data', () {
    final r = _parse('''
state rows:list=[{"name":"a","on":true}]
Column
  each x in rows
    Text#t "{x.name}" decoration={x.on ? 'lineThrough' : 'none'}
''');
    final t = ((r.document['nodes'] as Map)['t'] as Map).cast<String, Object?>();
    expect((t['bind'] as Map)['props.style.decoration'], r"${= item.on ? 'lineThrough' : 'none'}");
    expect(((t['props'] as Map)['style'] as Map)['decoration'], isNull);
  });

  test('a string literal keeps the name as text', () {
    final r = _parse('''
state rows:list=[{"name":"a","on":true}]
Column
  each x in rows
    Text#t "{x.name}" tooltip={'x.on ' + x.name}
''');
    expect(jsonEncode(r.document), contains("'x.on ' + item.name"));
  });
}
