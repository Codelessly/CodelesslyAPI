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

  group('a row of a Table', () {
    test('does what the Table\'s line says: its events and its menu are the row\'s, reading the record by the Table\'s name', () {
      final r = _parse('''
${people}state at=""
Page
  Section
    Table#people p in people columns=["Name",{"key":"seats","label":"Seats"},{"key":"more","label":"","w":40}] onTap={at=p.id} onDoubleTap={at=""} menu=rowMenu w=600
      Text "{p.name}"
      Text "{p.seats}"
      IconButton#more "more_vert" tooltip="More" onTap={at=p.id; open rowMenu}
Menu#rowMenu
  Row onTap={at=p.id}
    Text "Remove {p.name}"
''');
      expect(r.issues, isEmpty);
      final n = _nodes(r);
      List<Object?> triggers(String id) => [for (final a in (n[id]!['actions'] as List? ?? const [])) ((a as Map)['trigger'] as Map)['type']];
      expect(triggers('people-row'), containsAll(['click', 'doubleTap', 'secondaryClick', 'longPress']));
      expect(triggers('people'), isEmpty, reason: 'the frame does nothing');
      final tap = (n['people-row']!['actions'] as List).cast<Map>().firstWhere((a) => (a['trigger'] as Map)['type'] == 'click');
      expect(tap['actions'], [
        {'type': 'setVariable', 'variable': 'at', 'value': r'${= item.id}'},
      ]);
      // A cell's own control keeps its tap; the frame keeps its own keys.
      expect(triggers('more'), ['click']);
      expect((n['people']!['layout'] as Map)['width'], 600);
    });

    test('with select too: the row is chosen and does what its line says', () {
      final r = _parse('''
${people}state at=""
Page
  Section
    Table#people p in people columns=["Name"] select=@sel onTap={at=p.id}
''');
      expect(r.issues, isEmpty);
      final row = _nodes(r)['people-row']!;
      expect('${row['actions']}', contains('at'));
      expect('${row['bind']}', contains('contains(sel'));
    });
  });

  group('slot caption under a Table', () {
    test('is a row between the header and the rows, its lines side by side; the cells follow as they did', () {
      final r = _parse('''
${people}Page
  Section
    Table#people p in people columns=["Name","Email"] sort=@sortKey
      slot caption
        Text.caption#by "Sorted by {sortKey}"
        Text.caption#n "{length(people)} people"
      Row gap=8
        Text.strong#name "{p.name}"
''');
      expect(r.issues, isEmpty);
      final n = _nodes(r);
      expect(n['people']!['children'], ['people-head', 'people-caption', 'people-body']);
      final caption = n['people-caption']!;
      expect(caption['type'], 'row');
      expect(caption['children'], ['by', 'n']);
      expect((caption['decoration']! as Map)['strokeSides'], 'bottom');
      // The cell written is the first column's; the second shows its key's value.
      String? up(String id) => n.entries.where((e) => (e.value['children'] as List?)?.contains(id) ?? false).firstOrNull?.key;
      var at = 'name';
      while (up(at) != null && up(at) != 'people-row') {
        at = up(at)!;
      }
      expect(up(at), 'people-row');
      expect([for (final v in n.values) if (v['type'] == 'text') (v['props']! as Map)['text']], contains(r'${item.email}'));
    });

    test('with no cells written, and with none of it: the table is as it was', () {
      final r = _parse('''
${people}Page
  Section
    Table#people p in people columns=["Name"] empty="Nobody"
      slot caption
        Text.caption "All people"
''');
      expect(r.issues, isEmpty);
      expect(_nodes(r)['people']!['children']!.toString(), startsWith('[people-head, people-caption, people-body'));
      final plain = _parse('${people}Page\n  Section\n    Table#people p in people columns=["Name"]\n');
      expect(_nodes(plain)['people']!['children'], ['people-head', 'people-body']);
    });
  });
}
