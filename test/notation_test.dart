// The compact notation (docs/design/13-compact-notation.md): what an agent
// writes for levels 0 to 2 expands to an ordinary document that validates.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/src/core/levels.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/prompt.dart' show notationFunctions;
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

NotationResult _parse(String text) => parseNotation(text, catalog: standardCatalog);

List<String> _problems(Map<String, Object?> doc) => [
      for (final d in Catalog.run(standardCatalog, () => validateDocument(doc, options: const ValidateOptions(level: Level.state))))
        if (d.severity != Severity.info) '${d.code.name} ${d.path}: ${d.message}',
    ];

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

void main() {
  test('the four-control column: each control is its type with nothing styled, bound two ways to a variable it declares', () {
    final r = _parse('''
Column gap:12
  Slider =volume
  Input "Email" =email
  Toggle "Notifications" =notify
  Button "Save" -> emit save
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    expect(_node(r, 'screen')['slots'], {'body': 'column1'});
    final column = _node(r, 'column1');
    expect(column['children'], ['slider1', 'textField1', 'switch1', 'filledButton1']);
    expect(column['props'], {'spacing': 12, 'crossAxisAlignment': 'start'});
    final slider = _node(r, 'slider1');
    expect(slider['bind'], {'props.value': r'${volume}'});
    expect(slider['actions'], [
      {
        'trigger': {'type': 'changed'},
        'actions': [
          {'type': 'setVariable', 'variable': 'volume', 'value': r'${result}'},
        ],
      },
    ]);
    expect(((_node(r, 'textField1')['props'] as Map)['decoration'] as Map)['labelText'], 'Email');
    expect((_node(r, 'switch1')['props'] as Map)['label'], 'Notifications');
    expect((_node(r, 'filledButton1')['props'] as Map)['label'], 'Save');
    expect((_node(r, 'filledButton1')['actions'] as List).single, {
      'trigger': {'type': 'click'},
      'actions': [
        {'type': 'componentEvent', 'event': 'save'},
      ],
    });
    expect(r.document['variables'], {
      'screen': [
        {'name': 'volume', 'type': 'decimal', 'value': 0},
        {'name': 'email', 'type': 'text', 'value': ''},
        {'name': 'notify', 'type': 'boolean', 'value': false},
      ],
    });
  });

  test('the recorded approval card in the notation: about an eighth of the characters, the same structure, and it validates', () {
    const text = '''
state decision="pending"
Card gap:12
  Text.title "Approve deletion?"
  Column gap:4
    Text "Folder: Shared Drive / Archive 2019"
    Text "Files: 214 files, about 3.8 GB"
    Text.danger "These files will be permanently deleted. This cannot be undone."
  Text.caption "First files that will be deleted:"
  Column fill:#FFF9FAFB radius:6 gap:2 pad:8
    Text.small "budget_2019_q1.xlsx"
    Text.small "client_notes_old.docx"
    Text.small "site_photos_march.zip"
    Text.small "meeting_recording_04.mp4"
  if decision!="pending"
    Text.strong "Decision: {decision}"
  Row end gap:8
    Button.ghost "Deny" -> decision="denied"
    Button.destructive "Approve" -> decision="approved"; emit approved
''';
    final r = _parse(text);
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    final nodes = r.document['nodes'] as Map;
    expect(nodes.length, 17, reason: 'as many nodes as recorded');
    expect(text.length, lessThan(jsonEncode(r.document).length ~/ 4));
    final banner = _node(r, 'text10');
    expect(banner['bind'], {'visible': r'${= decision!="pending"}'});
    expect((banner['props'] as Map)['text'], r'Decision: ${decision}');
    expect(_node(r, 'textButton1')['type'], 'textButton');
    // Text with no variant is the body text: it has a color.
    expect(((_node(r, 'text2')['props'] as Map)['style'] as Map)['color'], '#FF111827', reason: 'SSUI\'s body ink');
    expect((_node(r, 'filledButton1')['actions'] as List).single['actions'], [
      {'type': 'setVariable', 'variable': 'decision', 'value': 'approved'},
      {'type': 'componentEvent', 'event': 'approved'},
    ]);
    expect((_node(r, 'row1')['props'] as Map)['mainAxisAlignment'], 'end');
  });

  test('what cannot be read is reported with its line, and the rest still parses', () {
    final r = _parse('''
Column
  Wibble "x"
  Text "kept"
  Button.sparkly "Go"
''');
    expect(r.issues.map((i) => i.line), [2, 4]);
    expect(r.issues.first.message, contains('No node type "Wibble"'));
    expect(_node(r, 'column1')['children'], ['text1', 'filledButton1']);
  });

  test('a {…} tail is merged into the node as JSON, an id is kept when written, and sizes can be written', () {
    final r = _parse('''
Row#bar between w:300 h:44
  Text#name "Ada" grow
  Icon "close" {"props": {"size": 18}}
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    expect(_node(r, 'bar')['layout'], {'width': 300, 'height': 44});
    expect((_node(r, 'name')['layout'] as Map)['flex'], 1);
    expect(_node(r, 'icon1')['props'], {'icon': 'close', 'size': 18});
  });

  test('read as it arrives: each completed line gives its operations, and applying them builds the same document', () {
    const text = '''
state decision="pending"
Card gap:12
  Text.title "Approve?"
  if decision!="pending"
    Text "Decision: {decision}"
  Row end gap:8
    Button.ghost "Deny" -> decision="denied"
    Button "Approve" -> decision="approved"
  Slider =volume
''';
    final stream = Catalog.run(standardCatalog, () => NotationStream(catalog: standardCatalog));
    final perChunk = <int>[];
    var doc = LayoutDocument(catalog: standardCatalog);
    // Seven characters at a time: lines complete mid-chunk.
    for (var i = 0; i < text.length; i += 7) {
      final ops = stream.add(text.substring(i, i + 7 > text.length ? text.length : i + 7));
      perChunk.add(ops.length);
      if (ops.isEmpty) continue;
      final r = applyOps(doc, {'ops': ops}, catalog: standardCatalog);
      expect(r.errors, isEmpty, reason: '${r.errors}');
      doc = r.document;
    }
    final last = stream.close();
    if (last.isNotEmpty) doc = applyOps(doc, {'ops': last}, catalog: standardCatalog).document;
    expect(stream.issues, isEmpty);
    expect(perChunk.where((n) => n > 0).length, greaterThan(5), reason: 'operations arrive line by line, not all at the end');
    // The same document as parsing it whole.
    final whole = _parse(text).document;
    final built = doc.toJson();
    expect((built['nodes'] as Map).keys.toSet(), (whole['nodes'] as Map).keys.toSet());
    for (final id in (whole['nodes'] as Map).keys) {
      expect(jsonDecode(jsonEncode(doc[id as String]!.toJson())), jsonDecode(jsonEncode(LayoutDocument.fromJson(whole, catalog: standardCatalog)[id]!.toJson())),
          reason: 'node $id');
    }
    expect(_problems(built), isEmpty);
  });

  test('the prompt is small, and every example in it parses and validates', () {
    final prompt = Catalog.run(standardCatalog, () => notationPrompt(catalog: standardCatalog));
    expect(prompt.length, lessThan(9000), reason: 'about 2,200 tokens');
    // Every function it names is one the engine has.
    final engine = {for (final f in (jsonDecode(File('tool/reference/data/formulas.json').readAsStringSync()) as Map)['functions'] as List) (f as Map)['name']};
    for (final f in notationFunctions) {
      expect(engine, contains(f.split('(').first), reason: f);
    }
    final examples = prompt.substring(prompt.indexOf('EXAMPLES') + 9).trim().split(RegExp(r'\n\n+'));
    expect(examples.length, 3);
    for (final e in examples) {
      final r = _parse(e);
      expect(r.issues, isEmpty, reason: e);
      expect(_problems(r.document), isEmpty, reason: e);
    }
    // Every type it names parses.
    final types = RegExp(r'(?:Layout and content|Controls): (.+)').allMatches(prompt).expand((m) => m[1]!.split(', '));
    for (final t in types) {
      final r = _parse('Column\n  $t');
      expect(r.issues, isEmpty, reason: t);
    }
  });

  test('forms models reach for: prices and formulas in text, a growing column, conditions with quotes, headers and tiles', () {
    final r = _parse('''
Here is the card:
state qty=2
state to=""
Card
  Text "Total \${qty*12} for {qty} items"
  Row
    Text "A long label that must be able to shrink"
    Column grow
      Text "x"
  Button "Send" enabled:=to!=""&&length(to)>3 -> emit send
  Accordion "Day 1"
    Text "Walk"
  ListTile "Bean There" "0.2 km"
    Icon "place"
  Grid cols:3 gap:8
    Box h:40 fill:#FFEEEEEE
  Progress 0.4
  Checkbox "Done" checked:=qty>1
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    expect((_node(r, 'text1')['props'] as Map)['text'], r'Total $${= qty*12} for ${qty} items');
    expect((_node(r, 'text2')['layout'] as Map)['squeezable'], true);
    expect((_node(r, 'column2')['layout'] as Map)['width'], {'fill': 0});
    final accordion = _node(r, 'accordion1');
    expect((accordion['children'] as List).length, 2, reason: 'its header text, then its content');
    final tile = _node(r, 'listTile1');
    expect((tile['slots'] as Map).keys.toSet(), {'leading', 'title', 'subtitle'});
    // A Grid of written children is rows of equal cells; the last row is filled out.
    final grid = _node(r, 'grid1');
    expect(grid['type'], 'column');
    expect(grid['children'], ['grid1Row1']);
    final row = _node(r, 'grid1Row1');
    expect((row['children'] as List).length, 3, reason: 'one cell written, two empty cells to keep its width');
    expect((_node(r, (row['children'] as List).first as String)['layout'] as Map)['flex'], 1);
    expect((_node(r, 'progressBar1')['props'] as Map)['value'], 0.4);
    expect((_node(r, 'checkbox1')['bind'] as Map)['props.value'], r'${= qty>1}');
  });

  test('each repeats the lines under it over a list: a list whose item is those lines, the element read as item', () {
    final r = _parse('''
state people=[{"name":"Ada","age":36},{"name":"Grace","age":45}]
Card
  each p in people
    Row between
      Text.strong "{p.name}"
      Text "{p.age} years, people: {length(people)}"
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    final list = _node(r, 'listView1');
    expect(list['bind'], {'data': r'${people}'});
    expect(list['children'], ['listView1Item']);
    expect(_node(r, 'listView1Item')['children'], ['row1']);
    expect((_node(r, 'text1')['props'] as Map)['text'], r'${item.name}');
    // Only the element's name is rewritten, not the word inside other names.
    expect((_node(r, 'text2')['props'] as Map)['text'], r'${item.age} years, people: ${= length(people)}');
  });
  test('forms from the fifth recording: quotes inside {…}, an expression with spaces, an expression where the string goes, a dropdown\'s hint', () {
    final r = _parse('''
state range="7 days"
state open=false
state to=""
state plan="Free"
Card
  Text "{range=="7 days" ? "\$18.4k" : "\$231k"} total"
  Button.ghost open ? "Hide" : "Show" -> open=!open
  Button "Send" enabled:=trim(to)!="" && length(to)>3 -> emit send
  Select "Plan" items:["Free","Pro"] =plan
  Input hint:"you@example.com" =to
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    expect((_node(r, 'text1')['props'] as Map)['text'], r'${= range=="7 days" ? "$18.4k" : "$231k"} total');
    expect((_node(r, 'textButton1')['bind'] as Map)['props.label'], r'${= open ? "Hide" : "Show"}');
    expect((_node(r, 'filledButton1')['bind'] as Map)['props.enabled'], r'${= trim(to)!="" && length(to)>3}');
    expect((_node(r, 'filledButton1')['actions'] as List).length, 1);
    expect((_node(r, 'dropdown1')['props'] as Map)['hint'], 'Plan');
    expect(((_node(r, 'textField1')['props'] as Map)['decoration'] as Map)['hintText'], 'you@example.com');
  });
  test('each in a row goes across with the row\'s gap, and GridView is read as Grid', () {
    final r = _parse('''
state i=0
Card
  Row center gap:8
    each n in range(6)
      Box w:10 h:10 radius:5 fill:=n==i?"#FF3366CC":"#FFCCCCCC" -> i=n
  GridView cols:3 gap:8
    each p in range(9)
      Box h:40 fill:#FFEEEEEE
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    final dots = _node(r, 'listView1');
    expect((dots['props'] as Map)['scrollDirection'], 'horizontal');
    expect((dots['props'] as Map)['spacing'], 8);
    expect((dots['layout'] as Map)['width'], {'hug': 0});
    expect(_node(r, 'gridView1')['type'], 'gridView');
  });
  test('a column in a row is as wide as its content and so are its children; an accordion starts closed unless it says open', () {
    final r = _parse('''
Card
  Row between
    Text "Acme" grow
    Column right
      Text.strong "\$1,200"
      Badge.neutral "Overdue"
  Accordion "Day 1"
    Text "Walk"
  Accordion "Day 2" open
    Text "Rest"
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    expect((_node(r, 'text2')['layout'] as Map)['width'], {'hug': 0});
    expect((_node(r, 'accordion1')['props'] as Map)['expanded'], false);
    expect((_node(r, 'accordion2')['props'] as Map)['expanded'], true);
  });
  test('a root that is not a card is on the surface; List holds an each; state written as a formula is read where it is used', () {
    final r = _parse('''
state cart=[{"name":"Beans","price":24,"qty":1}]
state subtotal=sum(cart,x=>x.price*x.qty)
state mode=fast
Column gap:8
  List gap:4
    each row in cart
      Text "{row.name}"
  Text "Total {subtotal}"
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    expect((_node(r, 'screen')['decoration'] as Map)['fills'], isNotEmpty);
    expect(_node(r, 'column2')['children'], ['listView1'], reason: 'the List is a column holding the repeated list');
    expect((_node(r, 'text2')['props'] as Map)['text'], r'Total ${= (sum(cart,x=>x.price*x.qty))}');
    final names = [for (final v in (r.document['variables'] as Map)['screen'] as List) (v as Map)['name']];
    expect(names, ['cart', 'mode'], reason: 'a formula is not a variable; a bare word is text');
  });
  group('printed back', () {
    Object? sorted(Object? v) => switch (v) {
          final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: sorted(m[k])},
          final List l => [for (final e in l) sorted(e)],
          // 390 and 390.0 are one number in JSON.
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
        };
    void roundTrips(Map<String, Object?> doc, {bool words = true}) {
      final text = printNotation(doc, catalog: standardCatalog);
      final back = parseNotation(text, catalog: standardCatalog, options: notationOptionsFor(doc));
      expect(back.issues, isEmpty, reason: text);
      expect(jsonEncode(sorted(back.document)), jsonEncode(sorted(doc)), reason: text);
      if (words) expect(text.split('\n').first, isNot(startsWith('document ')), reason: 'printed in the tree\'s words');
    }

    test('what the notation wrote prints back to the same document, one line a node', () {
      final doc = _parse('''
state decision="pending"
Card gap:12
  Text.title "Approve deletion?"
  Row end gap:8
    Button.ghost "Deny" -> decision="denied"
    Button "Approve" -> decision="approved"; emit approved
  Slider =volume
  Input "Email" =email
''').document;
      roundTrips(doc);
      final text = printNotation(doc, catalog: standardCatalog);
      expect(text, contains('Text.title#text1 "Approve deletion?"'));
      expect(text, contains('  Row#row1 gap:8 end'));
    });

    test('a document written by hand, with slots, another canvas id and a typed variable, round trips', () {
      roundTrips({
        'schema': 3,
        'roots': ['home'],
        'variables': {
          'home': [
            {'name': 'count', 'type': 'decimal', 'value': 2},
          ],
        },
        'nodes': {
          'home': {'type': 'canvas', 'slots': {'body': 'col'}, 'layout': {'width': 420, 'height': 800}, 'decoration': {'fills': [{'color': '#FF101010'}]}},
          'col': {'type': 'column', 'children': ['tile', 'note'], 'layout': {'width': {'fill': 420}, 'height': {'fill': 800}, 'padding': 24}, 'props': {'spacing': 16}},
          'tile': {'type': 'listTile', 'slots': {'title': 'tileTitle'}, 'layout': {'width': {'fill': 0}, 'height': {'hug': 0}}},
          'tileTitle': {'type': 'text', 'props': {'text': r'Count ${count}'}, 'layout': {'width': {'hug': 0}, 'height': {'hug': 0}}},
          'note': {'type': 'box', 'layout': {'width': 40, 'height': 40}, 'decoration': {'radius': 8}},
        },
      });
    });

    test('a document the words cannot carry is printed whole, and still round trips', () {
      roundTrips({
        'schema': 3,
        'roots': ['s'],
        'nodes': {
          's': {'type': 'canvas', 'slots': {'body': 'a-b'}, 'layout': {'width': 390, 'height': 100}},
          'a-b': {'type': 'text', 'props': {'text': 'dashed id'}, 'layout': {'width': {'hug': 0}, 'height': {'hug': 0}}},
        },
      }, words: false);
    });
  });
  test('the looks are SSUI\'s: its text styles by name, its card, and its badge as a tinted 20 px label', () {
    final r = _parse('''
state count=3
Card
  Text.sectionTitle "Billing"
  Text.caption "Updated today"
  Badge.success "Paid"
  Badge "{count} open"
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    expect((_node(r, 'text1')['props'] as Map)['style'], {'fontSize': 14, 'fontWeight': 600, 'color': '#FF111827'});
    expect((_node(r, 'text2')['props'] as Map)['style'], {'fontSize': 11, 'color': '#FF9CA3AF'});
    expect((_node(r, 'column1')['layout'] as Map)['padding'], 12);
    final badge = _node(r, 'row1');
    expect((badge['layout'] as Map)['height'], 20);
    expect(badge['decoration'], {
      'fills': [{'color': '#1A16A34A'}],
      'strokes': [{'color': '#4716A34A'}],
      'radius': 5,
    });
    final label = _node(r, (badge['children'] as List).single as String);
    expect((label['props'] as Map)['style'], {'fontSize': 11, 'fontWeight': 500, 'color': '#FF16A34A'});
    expect((_node(r, (_node(r, 'row2')['children'] as List).single as String)['props'] as Map)['text'], r'${count} open');
  });
  test('the looks come from a design system\'s theme: its text styles with their colors written out, its card, tones, surface and accent', () {
    final options = NotationOptions.fromTheme({
      'primary': '#FF0F766E', 'surface': '#FFFFFCF7', 'success': '#FF15803D',
      'colors': {'primaryText': '#FF1C1917', 'secondaryText': '#B81C1917', 'primaryBackground': '#FFFFFCF7', 'primaryBorder': '#FFE4E1DC',
        'successTint': '#1A15803D', 'successTintBorder': '#4715803D'},
      'textStyles': {'sectionTitle': {'fontSize': 14, 'fontWeight': 600, 'color': 'primaryText'}, 'body': {'fontSize': 13, 'color': 'primaryText'}},
      'radii': {'panel': 3},
    });
    final r = parseNotation('''
Card
  Text.sectionTitle "Billing"
  Text.muted "Next invoice on the 1st"
  Badge.success "Paid"
  BarChart values:[1,2,3]
''', catalog: standardCatalog, options: options);
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    expect((_node(r, 'screen')['decoration'] as Map)['fills'], [{'color': '#FFFFFCF7'}]);
    expect(((_node(r, 'column1')['decoration'] as Map)['strokes'] as List).single, {'color': '#FFE4E1DC'});
    expect((_node(r, 'column1')['decoration'] as Map)['radius'], 3);
    expect((_node(r, 'text1')['props'] as Map)['style'], {'fontSize': 14, 'fontWeight': 600, 'color': '#FF1C1917'});
    expect(((_node(r, 'text2')['props'] as Map)['style'] as Map)['color'], '#B81C1917');
    expect(((_node(r, 'row1')['decoration'] as Map)['fills'] as List).single, {'color': '#1A15803D'});
    expect((_node(r, 'barChart1')['props'] as Map)['color'], '#FF0F766E');
  });

  test('looks that follow data: a bound border and text color, an icon chosen by an expression, an expression in the tail', () {
    final r = _parse('''
state on=false
state score=72
Column gap:8
  Row pad:8 border:=on?"#FF2563EB":"#FFE5E7EB" -> on=!on
    Icon "{on ? "expand_less" : "expand_more"}"
    Text "{score}" color:=score>=80?"#FF16A34A":"#FFDC2626"
  Progress =score/100 {"props": {"color": "\${= score>=80 ? '#FF16A34A' : '#FFDC2626'}"}}
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    final row = _node(r, 'row1');
    expect((row['bind'] as Map)['decoration.strokes[0].color'], r'${= on?"#FF2563EB":"#FFE5E7EB"}');
    expect((row['decoration'] as Map)['strokes'], [{'color': '#00000000'}]);
    expect((_node(r, 'icon1')['bind'] as Map)['props.icon'], r'${= on ? "expand_less" : "expand_more"}');
    expect((_node(r, 'icon1')['props'] as Map?)?.containsKey('icon') ?? false, isFalse);
    expect((_node(r, 'text1')['bind'] as Map)['props.style.color'], r'${= score>=80?"#FF16A34A":"#FFDC2626"}');
    final bar = _node(r, 'progressBar1');
    expect((bar['bind'] as Map)['props.color'], r"${= score>=80 ? '#FF16A34A' : '#FFDC2626'}");
    expect((bar['props'] as Map).containsKey('color'), isFalse);
  });

  test('copies across a row that grow share its width: a grid with a column per item, rows as tall as their content', () {
    final r = _parse('''
state plans=[{"name":"Team"},{"name":"Pro"},{"name":"Enterprise"}]
Row gap:8
  each p in plans
    Column pad:10 grow
      Text "{p.name}"
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    final list = _node(r, 'listView1');
    expect(list['type'], 'gridView');
    expect(list['layout'], {'width': {'fill': 0}, 'height': {'hug': 0}});
    expect(list['props'], {'crossAxisCount': 1, 'crossAxisSpacing': 8, 'shrinkWrapRows': true, 'physics': 'never'});
    expect(list['bind'], {'data': r'${plans}', 'props.crossAxisCount': r'${= max(1, length(plans))}'});
    expect(_node(r, 'listView1Item')['layout'], {'width': {'fill': 0}, 'height': {'hug': 0}});
    expect((_node(r, 'column1')['layout'] as Map).containsKey('flex'), isFalse);
    // Without grow, the copies keep their own widths in a line.
    final plain = _parse('Row gap:8\n  each p in [1,2]\n    Text "{p}"\n');
    expect(_node(plain, 'listView1')['type'], 'listView');
    // Read as it arrives, the list sent as a line is patched into the grid.
    const text = 'state plans=[{"name":"Team"},{"name":"Pro"}]\nRow gap:8\n  each p in plans\n    Column pad:10 grow\n      Text "{p.name}"\n';
    final stream = Catalog.run(standardCatalog, () => NotationStream(catalog: standardCatalog));
    var doc = LayoutDocument(catalog: standardCatalog);
    for (final ops in [stream.add(text), stream.close()]) {
      if (ops.isEmpty) continue;
      final applied = applyOps(doc, {'ops': ops}, catalog: standardCatalog);
      expect(applied.errors, isEmpty, reason: '${applied.errors}');
      doc = applied.document;
    }
    final built = (doc.toJson()['nodes'] as Map)['listView1'] as Map;
    expect(built['type'], 'gridView');
    expect(built['layout'], {'width': {'fill': 0}, 'height': {'hug': 0}});
    expect((built['props'] as Map)['shrinkWrapRows'], true);
    expect(built['children'], ['listView1Item']);
    expect(((doc.toJson()['nodes'] as Map)['listView1Item'] as Map)['children'], ['column1']);
    expect(_problems(doc.toJson()), isEmpty);
  });

  test('a derived value is read inside a text that quotes other texts', () {
    final r = _parse('''
state a=3
state total=a*2
Text "{total>=5 ? "Ready" : "Not yet"} at {total}"
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    expect((_node(r, 'text1')['props'] as Map)['text'], contains('(a*2)>=5'));
    expect((_node(r, 'text1')['props'] as Map)['text'], isNot(contains('total')));
  });
}
