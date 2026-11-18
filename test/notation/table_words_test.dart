// The table word (`Table p in people columns=[…]`, lib/src/core/notation/table_words.dart) and the number field
// with its buttons (`NumberInput @seats`): a finished desktop table and stepper by default, written out as the plain
// nodes a careful hand would write.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

const _page = NotationOptions(width: 1280);

NotationResult _parse(String text, {NotationOptions options = _page}) =>
    parseNotation(text, catalog: standardCatalog, options: options);

Map<String, Map<String, Object?>> _nodes(NotationResult r) =>
    (r.document['nodes'] as Map).map((k, v) => MapEntry('$k', (v as Map).cast<String, Object?>()));

void main() {
  const people = '''
state people=[{"id":"a","name":"Ada","email":"ada@x.io","seats":3},{"id":"b","name":"Lin","email":"lin@x.io","seats":12}]
state sel=[]
state sortKey="name"
''';

  test('a Table is a framed column: a border on every side, rounded corners that clip, a header band and a rule under each row', () {
    final r = _parse('''
${people}Page
  Section
    Table#people p in people columns=["Name",{"key":"email","label":"Email","w":240},{"key":"seats","label":"Seats","align":"end"}]
''');
    expect(r.issues, isEmpty);
    final n = _nodes(r);
    final frame = n['people']!;
    expect(frame['type'], 'column');
    final d = frame['decoration']! as Map;
    expect(d['strokes'], isNotEmpty);
    expect(d.containsKey('strokeSides'), isFalse, reason: 'every side');
    expect(d['radius'], isNotNull);
    expect('$d', contains('clip'));
    final head = n['people-head']!;
    expect(head['type'], 'row');
    expect((head['decoration']! as Map)['strokeSides'], 'bottom');
    expect(head['behaviors'] ?? head, isNotNull);
    final row = n['people-row']!;
    expect((row['decoration']! as Map)['strokeSides'], 'bottom');
    expect((row['states']! as Map)['hovered'], isNotNull);
    // The header's labels, and a cell per column with its key's value; the number column at the end, its figures tabular.
    final texts = [for (final v in n.values) if (v['type'] == 'text') (v['props']! as Map)['text']];
    expect(texts, containsAll(['Name', 'Email', 'Seats', r'${item.name}', r'${item.email}', r'${item.seats}']));
    final seats = n.values.singleWhere((v) => v['type'] == 'text' && (v['props']! as Map)['text'] == r'${item.seats}');
    expect('${seats['props']}', contains('tabularFigures'));
    // The email column is 240 wide; Name, with no width, grows.
    final widths = [for (final v in n.values) if (v['type'] == 'row' && (v['layout'] as Map?)?['width'] == 240) v];
    expect(widths, hasLength(2), reason: 'its header cell and its body cell');
  });

  test('sort=@name: a header press sorts by its column, again the other way; the rows shown are sorted', () {
    final r = _parse('''
${people}Page
  Section
    Table#people p in people columns=["Name",{"key":"seats","label":"Seats","sort":false}] sort=@sortKey
''');
    expect(r.issues, isEmpty);
    final json = '${r.document}';
    expect(json, contains("sortBy(people, replace(sortKey, '-', ''), startsWith(sortKey, '-') ? 'desc' : 'asc')"));
    expect(json, contains('arrow_upward'));
    expect(json, contains('unfold_more'));
    // Only the sortable column takes a press.
    final pressed = [for (final v in _nodes(r).values) if ('${v['reactions'] ?? v['actions'] ?? ''}'.contains('sortKey')) v];
    expect(pressed, hasLength(1));
  });

  test('select=@name: a column of checkboxes leads, the header one picks all or none, the rows are a selectable list', () {
    final r = _parse('''
${people}Page
  Section
    Table#people p in people columns=["Name"] select=@sel
''');
    expect(r.issues, isEmpty);
    final n = _nodes(r);
    final boxes = [for (final v in n.values) if (v['type'] == 'checkbox') v];
    expect(boxes, hasLength(2));
    expect('${r.document}', contains('map(people, x => coalesce(x.id, x))'));
    final row = n['people-row']!;
    expect((row['states']! as Map)['selected'], isNotNull);
    expect('${row['bind']}', contains('contains(sel, coalesce(item.id, item))'));
  });

  test('the lines under a Table are its cells, in its columns\x27 order; compact rows are denser', () {
    final r = _parse('''
${people}Page
  Section
    Table p in people columns=["Name","Email"] compact
      Row gap=8
        Text "{p.name}" weight=600
''');
    expect(r.issues, isEmpty);
    final n = _nodes(r);
    final texts = [for (final v in n.values) if (v['type'] == 'text') (v['props']! as Map)['text']];
    expect(texts, containsAll([r'${item.name}', r'${item.email}']));
    final rows = [for (final v in n.values) if ((v['layout'] as Map?)?['constraints'] case {'minHeight': 36}) v];
    expect(rows, hasLength(1));
  });

  test('NumberInput is a number field with its minus and plus buttons inside its border', () {
    final r = _parse('state seats=48\nColumn\n  NumberInput @seats min=1 max=500');
    expect(r.issues, isEmpty);
    final field = _nodes(r).values.singleWhere((v) => v['type'] == 'textField');
    final props = field['props']! as Map;
    expect(props['steppers'], true);
    expect(props['keyboardType'], 'number');
    expect(props['textAlign'], 'center');
    expect(props['min'], 1);
    expect(props['max'], 500);
    expect((field['layout']! as Map)['width'], 112);
    // A design system's own NumberInput comes first.
    expect(TextFieldProps.steppers.defaultValue, false);
  });
}
