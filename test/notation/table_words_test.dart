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

  // A chosen row is the accent's tint, unless the theme names its own fill
  // for one (`selectedRow`: a design system whose chosen things are neutral,
  // the ticked box the accent's mark). The same for a selectable list's row
  // and a line written `selected={…}`.
  test("a chosen row's fill: the accent's tint, or the theme's selectedRow", () {
    const text = '''
${people}state open="a"
Page
  Section
    Table#people p in people columns=["Name"] select=@sel
    Column#list selectable selected=@sel
      each p in people
        Row#item pad=8
          Text "{p.name}"
    Row#line pad=8 selected={open == "a"}
      Text "Ada"
''';
    Map<String, Object?> theme({String? row}) => {
          'primary': '#FF2563EB',
          'surface': '#FFFFFFFF',
          'colors': {'activeTint': '#242563EB', 'selectedRow': ?row},
        };
    String? fill(NotationResult r, String id) {
      // (The selectable list's row is the list's item, whatever its id.)
      if (id == 'listItem') {
        var at = 'list';
        while (_nodes(r)[at]!['states'] == null) {
          at = (_nodes(r)[at]!['children']! as List).first as String;
        }
        id = at;
      }
      final states = _nodes(r)[id]!['states']! as Map;
      return ((((states['selected'] as Map)[id] as Map)['decoration'] as Map)['fills'] as List).single['color'] as String?;
    }

    for (final named in [false, true]) {
      final tinted = _parse(text, options: NotationOptions.fromTheme(theme(), width: 1280, named: named));
      final neutral = _parse(text, options: NotationOptions.fromTheme(theme(row: '#FFF3F4F6'), width: 1280, named: named));
      expect(tinted.issues, isEmpty);
      expect(neutral.issues, isEmpty);
      for (final id in ['people-row', 'listItem', 'line']) {
        expect(fill(neutral, id), named ? 'selectedRow' : '#FFF3F4F6', reason: '$id, named: $named');
        expect(fill(tinted, id), isNot(anyOf('selectedRow', '#FFF3F4F6')), reason: '$id, named: $named');
      }
      expect(fill(tinted, 'people-row'), named ? 'activeTint' : '#FFE9EFFD');
      expect(fill(tinted, 'listItem'), named ? 'activeTint' : '#242563EB');
      // Printed and read back, each keeps its fill.
      for (final r in [tinted, neutral]) {
        final printed = printNotation(r.document, catalog: standardCatalog);
        final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(r.document));
        for (final id in ['people-row', 'listItem', 'line']) {
          expect(fill(back, id), fill(r, id), reason: '$id, named: $named\n$printed');
        }
      }
    }
  });

  // A frame written `flush` (a design system's Panel: no padding round its
  // lines, a rule under its head) is the border of what is in it: a Table
  // under it draws no frame of its own. Its own border under the frame's rule
  // was two rules under the head, and two down each side.
  test('a Table under a frame written flush, or written flush itself, has no frame of its own', () async {
    final files = {
      'design_system.json': '{"id":"acme","name":"Acme","components":["components/Panel.json"]}',
      'components/Panel.json': '{"schema":3,"id":"Panel","roots":["p"],"widget":{"type":"Panel","doc":"A titled section.","children":"list",'
          '"props":[{"key":"title","type":{"kind":"string","flutter":"String"},"default":""},{"key":"flush","type":{"kind":"boolean","flutter":"bool"},"default":false}]},'
          '"nodes":{"p":{"type":"column","layout":{"width":{"fill":0},"height":{"hug":0}},"children":["s"]},"s":{"type":"slot"}}}',
    };
    final ds = await DesignSystem.load((ref) async => files[ref]);
    final catalog = ds.catalogOver(standardCatalog);
    final options = NotationOptions.fromDesignSystem(ds, width: 1280);
    Map<String, Object?> table(String lines) {
      final r = Catalog.run(catalog, () => parseNotation('${people}Page\n  Section\n$lines', catalog: catalog, options: options));
      expect(r.issues, isEmpty, reason: lines);
      return _nodes(r)['t']!;
    }

    const line = 'Table#t p in people columns=["Name"]';
    bool framed(Map<String, Object?> t) {
      final d = (t['decoration'] as Map?) ?? const {};
      return d['strokes'] != null && d['radius'] != null && d['fills'] != null;
    }

    expect(framed(table('    $line')), isTrue);
    expect(framed(table('    Panel "Plans"\n      $line')), isTrue, reason: 'a padded frame: the table keeps its own');
    expect(framed(table('    Panel "Plans" flush=false\n      $line')), isTrue);
    for (final flush in ['    Panel "Plans" flush\n      $line', '    Panel "Plans" flush=true\n      $line', '    $line flush']) {
      final t = table(flush);
      expect(t['decoration'], isNull, reason: flush);
      expect((t['props'] as Map?)?.containsKey('flush') ?? false, isFalse, reason: 'the word is the table\'s, not a key of its column');
      // Its header's band and the rule under it are still drawn.
      expect((_nodes(Catalog.run(catalog, () => parseNotation('${people}Page\n  Section\n$flush', catalog: catalog, options: options)))['t-head']!['decoration']! as Map)['strokeSides'], 'bottom');
    }
    // Only a table that is the frame's own line: one further in keeps its frame.
    expect(framed(table('    Panel "Plans" flush\n      Column pad=16\n        $line')), isTrue);
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
