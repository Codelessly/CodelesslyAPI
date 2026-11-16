// The compact notation (docs/design/13-compact-notation.md): what an agent
// writes for levels 0 to 2 expands to an ordinary document that validates.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/src/core/levels.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/prompt.dart' show notationFunctions, notationPrompt;
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

  test('a node written whole: its JSON as given, over several lines, with notation lines under it, and the same when read as it arrives', () {
    const text = '''
state open=true
Column gap:8
  Text "Above"
  if open
    node#board {
      "type": "stack",
      "layout": {"width": {"fill": 0}, "height": 120},
      "decoration": {"fills": [{"color": "#FF111827"}], "radius": 8}
    }
      Text "On the board" color:#FFFFFFFF
      node {"type": "icon", "props": {"icon": "star", "size": 20}}
      node#odd {"type": "text",
        "props": {"text": "braces in a string { [ stay text"}}
  Button "Below" -> open=!open
''';
    final r = _parse(text);
    expect(r.issues, isEmpty);
    final board = _node(r, 'board');
    expect(board['layout'], {'width': {'fill': 0}, 'height': 120});
    expect((board['decoration'] as Map)['radius'], 8);
    expect((board['bind'] as Map)['visible'], r'${= open}');
    expect(board['children'], ['text2', 'icon1', 'odd']);
    expect((_node(r, 'odd')['props'] as Map)['text'], 'braces in a string { [ stay text');
    expect(_node(r, 'icon1')['props'], {'icon': 'star', 'size': 20});
    expect(_node(r, 'column1')['children'], ['text1', 'board', 'filledButton1']);

    // As it arrives, eleven characters at a time.
    final stream = Catalog.run(standardCatalog, () => NotationStream(catalog: standardCatalog));
    var doc = LayoutDocument(catalog: standardCatalog);
    for (var i = 0; i < text.length; i += 11) {
      final ops = stream.add(text.substring(i, i + 11 > text.length ? text.length : i + 11));
      if (ops.isEmpty) continue;
      final a = applyOps(doc, {'ops': ops}, catalog: standardCatalog);
      expect(a.errors, isEmpty, reason: '${a.errors}');
      doc = a.document;
    }
    final last = stream.close();
    if (last.isNotEmpty) doc = applyOps(doc, {'ops': last}, catalog: standardCatalog).document;
    expect(stream.issues, isEmpty);
    expect(doc['board']!.toJson()['children'], ['text2', 'icon1', 'odd']);

    // What cannot be read is said, and the rest still parses.
    final bad = _parse('''
Column
  node {"layout": {}}
  node {"type": "noSuchThing"}
  node {"type": "icon",
''');
    expect(bad.issues.map((i) => i.message), [
      contains('the whole node as JSON with its type'),
      contains('No node type "noSuchThing"'),
      contains('never closed'),
    ]);
  });

  test('what the bridge experiments reached for: every, scroll, a control bound to a field of a repeated element, a label that reads it, ids kept under each', () {
    const text = '''
state seconds=30
state running=true
state fields=[{"label":"Name","required":false}]
state cells=[{"v":1},{"v":2}]
every 1s when running -> seconds=seconds-1
Column gap:8 scroll
  Text "{seconds}"
  Row gap:4
    each cell in cells
      Box#cell w:36 h:36 -> seconds=cell.v
  each field in fields
    Input "{field.label}" =field.label
    Toggle "Required" =field.required
''';
    final r = _parse(text);
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    // The timer is on the canvas.
    expect(_node(r, 'screen')['actions'], [
      {
        'trigger': {'type': 'timer', 'intervalMs': 1000, 'when': r'${= running}'},
        'actions': [
          {'type': 'setVariable', 'variable': 'seconds', 'value': r'${= seconds-1}'},
        ],
      },
    ]);
    expect((_node(r, 'column1')['props'] as Map)['scrollable'], isTrue);
    // The id written under an each is kept (the element's name is not put in its place).
    expect((r.document['nodes'] as Map).containsKey('cell'), isTrue);
    // A field of the element: shown, and written back into the list; no variable named after it.
    final input = _node(r, 'textField1');
    expect((input['bind'] as Map)['props.initialValue'], r'${item.label}');
    expect((input['bind'] as Map)['props.decoration.labelText'], r'${item.label}');
    expect(((input['actions'] as List).first as Map)['actions'], [
      {'type': 'setVariable', 'variable': 'fields', 'value': r'${= setAt(fields,index,with(item,"label",result))}'},
    ]);
    final names = [for (final v in ((r.document['variables'] as Map)['screen'] as List)) (v as Map)['name']];
    expect(names, ['seconds', 'running', 'fields', 'cells']);

    // The same as it arrives, the every line last.
    final stream = Catalog.run(standardCatalog, () => NotationStream(catalog: standardCatalog));
    var doc = LayoutDocument(catalog: standardCatalog);
    for (final chunk in ['state n=0\nColumn\n  Text "{n}"\n', 'every 500 -> n=n+1']) {
      final ops = stream.add(chunk);
      if (ops.isNotEmpty) doc = applyOps(doc, {'ops': ops}, catalog: standardCatalog).document;
    }
    final a = applyOps(doc, {'ops': stream.close()}, catalog: standardCatalog);
    expect(a.errors, isEmpty, reason: '${a.errors}');
    expect(stream.issues, isEmpty);
    expect(((a.document['screen']!.toJson()['actions'] as List).single as Map)['trigger'], {'type': 'timer', 'intervalMs': 500});

    // A string that reads data on a named parameter is bound; a stray colon before = is read.
    final c = _parse('''
state streak=4
state done=3
Column
  Button "Go" tooltip:"{streak} days"
  Progress :=done/5
''');
    expect(c.issues, isEmpty);
    expect((_node(c, 'filledButton1')['bind'] as Map)['props.tooltip'], r'${streak} days');
    expect((_node(c, 'progressBar1')['bind'] as Map)['props.value'], r'${= done/5}');

    // What cannot be meant is said.
    final bad = _parse('''
state rows=[{"n":1}]
every soon -> x=1
Column
  Input "A" =form.name
  each row in filter(rows, r => r.n>0)
    Input "B" =row.n
''');
    expect(bad.issues.map((i) => i.message), [
      contains('An "every" line is'),
      contains('"form.name" is neither'),
      contains('only when the each is over a variable'),
    ]);
  });

  test('drag and drop in words: a dragged node carries a value in a group, a drop target takes groups and its -> runs on a drop', () {
    final r = _parse('''
state todo=[{"id":"a","title":"Sketch"}]
state done=[]
Column gap:8
  each card in todo
    Card#card drag:todo(card.id)
      Text "{card.title}"
  Card#doneCol drop:todo,doing -> done=append(done,result.data)
    Text "Done {length(done)}"
''');
    expect(r.issues, isEmpty);
    expect(_node(r, 'card')['draggable'], {'group': 'todo', 'data': r'${item.id}'});
    final target = _node(r, 'doneCol');
    expect(target['dropTarget'], {'accepts': ['todo', 'doing']});
    expect(((target['actions'] as List).single as Map)['trigger'], {'type': 'drop'});
    expect((_node(_parse('Column\n  Input "Age" type:number\n'), 'textField1')['props'] as Map)['keyboardType'], 'number');
    // A state started from state already declared is that value, and its own.
    final started = _parse('state today={"work":40,"rest":20}\nstate left=today.work\nstate phase=work\nColumn\n  Text "{left}"\n');
    final vars = {for (final v in ((started.document['variables'] as Map)['screen'] as List)) (v as Map)['name']: v};
    expect(vars['left'], {'name': 'left', 'type': 'integer', 'value': 40});
    expect(vars['phase']!['value'], 'work');
    // Forms a model wrote for a block: a field of state as a bare value, and a text written as a binding.
    final lenient = _parse('state today={"minutes":8}\nstate n=3\nColumn\n  Button "Go" tooltip:today.minutes\n  Button "Go" tooltip:="{n} left"\n');
    expect(lenient.issues, isEmpty);
    expect((_node(lenient, 'filledButton1')['bind'] as Map)['props.tooltip'], r'${today.minutes}');
    expect((_node(lenient, 'filledButton2')['bind'] as Map)['props.tooltip'], r'${n} left');
    expect(_parse('state n=1\nColumn\n  Select items:["Round {n}","B"]\n').issues, isEmpty, reason: 'a text in a list reads values');
    final bad = _parse('Column\n  Card drag:"a b"\n  Card drop:1x -> x=1\n');
    expect(bad.issues.map((i) => i.message), [contains('drag is written'), contains('drop is written')]);
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
  test('a theme gives a progress bar its corner and height, and a card with no gap the theme\'s', () {
    final options = NotationOptions.fromTheme({
      'radii': {'progress': 999},
      'sizes': {'progress': 8},
      'spacing': {'cardGap': 12},
    });
    final r = parseNotation('Column\n  Card#a\n    Progress#p 0.4\n  Card#b gap:4\n    Text "x"', options: options, catalog: standardCatalog);
    expect((_node(r, 'p')['props'] as Map)['borderRadius'], 999);
    expect((_node(r, 'p')['layout'] as Map)['height'], 8);
    expect((_node(r, 'a')['props'] as Map)['spacing'], 12);
    expect((_node(r, 'b')['props'] as Map)['spacing'], 4);
    final plain = parseNotation('Card#a\n  Progress#p 0.4', catalog: standardCatalog);
    expect((_node(plain, 'p')['props'] as Map)['borderRadius'], 2);
    expect((_node(plain, 'a')['props'] as Map).containsKey('spacing'), isFalse);
  });

  test('a card\'s corner follows its place: the whole UI, a section of a page, a tile in a grid, a card in a card', () {
    final options = NotationOptions.fromTheme({
      'radii': {'card': 26, 'panel': 18, 'tile': 14},
    });
    final r = parseNotation('Card#solo\n  Card#inner\n    Text "a"', options: options, catalog: standardCatalog);
    num radius(NotationResult r, String id) => (_node(r, id)['decoration'] as Map)['radius'] as num;
    expect(radius(r, 'solo'), 26);
    expect(radius(r, 'inner'), 14);
    final page = parseNotation('Column\n  Card#section\n    Text "a"\n  Grid cols:2\n    Card#tile\n      Text "b"',
        options: options, catalog: standardCatalog);
    expect(radius(page, 'section'), 18);
    expect(radius(page, 'tile'), 14);
  });

  test('a theme may give plain parts a designed look: card, page, badge, a full-width button, colors read as its names', () {
    final theme = {
      'primary': '#FF2563EB',
      'colors': {
        'primaryText': '#FF111827', 'secondaryText': '#FF4B5563', 'primaryBackground': '#FFFFFFFF', 'subtleFill': '#FFF3F4F6',
        'primaryBorder': '#FFE5E7EB', 'primaryTint': '#1A2563EB', 'card': '#FFFFFFFF', 'page': '#FFF3F4F6',
      },
      'textStyles': {'body': {'fontSize': 13, 'color': 'primaryText'}, 'badge': {'fontSize': 11, 'fontWeight': 500}},
      'radii': {'panel': 18, 'card': 26, 'tile': 14, 'badge': 999, 'bar': 6},
      'sizes': {'cta': 46, 'badge': 22},
      'spacing': {'card': 18, 'badge': 9},
      'shadows': {
        'card': [{'type': 'dropShadow', 'color': '#14000000', 'offset': [0, 18], 'blurRadius': 40}],
      },
    };
    const text = '''
state on=false
Card gap:12
  Box fill:#FFF5F5F5 radius:8 pad:12
    Text "Folder" color:#FF6B7280
  Box fill:=on?"#FFEFF6FF":"#FFF5F5F5" border:#FF7C3AED
    Text "Brand purple stays"
  Badge.primary "New"
  Row gap:8
    Button.outline "Deny"
    Button "Approve"
  Button "Confirm"
  Button.ghost "Later"
  Card
    Text "A tile"
  BarChart values:[1,2]
  Text#big "12" size:24 weight:700
''';
    final r = parseNotation(text, catalog: standardCatalog, options: NotationOptions.fromTheme(theme, named: true));
    expect(r.issues, isEmpty);
    expect(validateDocument(r.document, options: ValidateOptions(theme: ThemeTokens.fromJson(theme))).where((d) => d.severity == Severity.error), isEmpty);
    expect((_node(r, 'screen')['decoration'] as Map)['fills'], [{'color': 'page'}]);
    final card = _node(r, 'column1');
    expect((card['decoration'] as Map)['radius'], 26);
    expect((card['decoration'] as Map)['fills'], [{'color': 'card'}]);
    expect(((card['decoration'] as Map)['effects'] as List).single, containsPair('blurRadius', 40));
    expect((card['layout'] as Map)['padding'], 18);
    // A written gray is the theme's neutral fill and its text ink; a color
    // the theme has nothing near (a brand purple) stays as written.
    expect((_node(r, 'column2')['decoration'] as Map)['fills'], [{'color': 'subtleFill'}]);
    expect(((_node(r, 'text1')['props'] as Map)['style'] as Map)['color'], 'secondaryText');
    expect((_node(r, 'column3')['bind'] as Map)['decoration.fills[0].color'], r'${= on?theme.colors.primaryTint:theme.colors.subtleFill}');
    expect((_node(r, 'column3')['decoration'] as Map)['strokes'], [{'color': '#FF7C3AED'}]);
    final badge = _node(r, 'row1');
    expect((badge['decoration'] as Map)['radius'], 999);
    expect((badge['layout'] as Map)['height'], 22);
    expect((badge['layout'] as Map)['padding'], [9, 0, 9, 0]);
    expect((_node(r, (badge['children'] as List).single as String)['props'] as Map)['style'], {'from': 'badge', 'color': 'primary'});
    // A button alone on its line in a column is as wide as it at the cta
    // height; in a row, and a ghost, it is as big as its label.
    expect(_node(r, 'filledButton2')['layout'], {'width': {'fill': 0}, 'height': 46});
    expect((_node(r, 'filledButton1')['layout'] as Map)['width'], {'hug': 0});
    expect((_node(r, 'textButton1')['layout'] as Map)['width'], {'hug': 0});
    // A card in a card is a tile of it: smaller corners, no shadow.
    expect((_node(r, 'column4')['decoration'] as Map)['radius'], 14);
    expect((_node(r, 'column4')['decoration'] as Map).containsKey('effects'), isFalse);
    expect((_node(r, 'barChart1')['props'] as Map)['barRadius'], 6);
    // A text sized on its line keeps the theme's body (its ink and font).
    expect((_node(r, 'big')['props'] as Map)['style'], {'from': 'body', 'fontSize': 24, 'fontWeight': 700});
    // Without `named` nothing is read as a name; without these tokens (no
    // design system) the look is the bundled one.
    final literal = parseNotation(text, catalog: standardCatalog, options: NotationOptions.fromTheme(theme));
    expect((_node(literal, 'column2')['decoration'] as Map)['fills'], [{'color': '#FFF5F5F5'}]);
    final plain = parseNotation(text, catalog: standardCatalog);
    expect((_node(plain, 'filledButton2')['layout'] as Map)['width'], {'hug': 0});
    expect((_node(plain, 'row1')['decoration'] as Map)['radius'], 5);
    expect((_node(plain, 'column1')['decoration'] as Map)['radius'], 8);
    expect((_node(plain, 'column4')['decoration'] as Map)['radius'], 8);
    expect((_node(plain, 'barChart1')['props'] as Map).containsKey('barRadius'), isFalse);
    expect((_node(plain, 'big')['props'] as Map)['style'], {'fontSize': 24, 'fontWeight': 700, 'color': '#FF111827'},
        reason: 'a sized text keeps the body ink: with no color it shows nothing');
  });


  test('the words a model reaches for: Gauge, Dial, Ring, Sparkline, animate, and a Stack that centers', () {
    const text = '''
state steps=7240
state rows=[{"t":"a"},{"t":"b"}]
Card
  Gauge#g 72 min:0 max:180 limit:100 unit:"km/h"
  Dial#d =steps
  Stack#s center middle w:96 h:96
    Ring#r =steps/10000 w:96
    Text#pct "72%"
  Sparkline#sp values:[3,4,3,6]
  Text#t "Hello" animate:fadeIn duration:0.4s delay:200
  each x in rows
    Row#row animate:slide-up stagger:80
      Text "{x.t}"
  Button#b "Record" animate:pulse
''';
    final r = parseNotation(text, catalog: standardCatalog);
    expect(r.issues, isEmpty);
    expect(validateDocument(r.document).where((d) => d.severity == Severity.error), isEmpty);
    // A gauge is a stack under its id: a clean arc and the figure inside it.
    expect(_node(r, 'g')['type'], 'stack');
    expect(_node(r, 'g')['layout'], {'width': {'fill': 0}, 'height': 164});
    expect(_node(r, 'g')['children'], ['gArc', 'gValue', 'gUnit']);
    final g = _node(r, 'gArc');
    expect(g['type'], 'radialGauge');
    expect(g['props'], containsPair('value', 72));
    expect(g['props'], containsPair('target', 100));
    expect(g['props'], containsPair('showNeedle', false));
    expect((_node(r, 'gValue')['props'] as Map)['text'], '72');
    expect((_node(r, 'gUnit')['props'] as Map)['text'], 'km/h');
    // A gauge with no limit shows no target mark; one that follows a variable shows its value.
    expect(_node(r, 'dArc')['props'], containsPair('showTarget', false));
    expect((_node(r, 'dArc')['bind'] as Map)['props.value'], r'${steps}');
    expect((_node(r, 'dValue')['bind'] as Map)['props.text'], r'${steps}');
    // What is in a centering stack is centered, as wide as it is.
    expect(_node(r, 'r')['type'], 'circularProgressIndicator');
    expect(_node(r, 'pct')['layout'], {'x': {'align': 0}, 'y': {'align': 0}, 'width': {'hug': 0}, 'height': {'hug': 0}});
    final sp = _node(r, 'sp');
    expect(sp['type'], 'lineChart');
    expect((sp['layout'] as Map)['height'], 32);
    expect((sp['props'] as Map)['data'], hasLength(4));
    expect(_node(r, 't')['animations'], [
      {'id': 'a', 'preset': 'enter', 'params': {'from': {'opacity': 0}}, 'duration': 400, 'delay': 200},
    ]);
    expect((_node(r, 'row')['bind'] as Map)['animations[0].delay'], r'${= index*80}');
    expect(((_node(r, 'b')['animations'] as List).single as Map)['preset'], 'pulse');
    // As models also write them: the timer's actions on the next line, a slider's step, a swipe, a stagger on the each.
    const more = '''
state n=0
state todos=[{"id":1,"t":"a"}]
every 1s when n<5
  -> n=n+1
Card
  Slider#tip =n min:0 max:30 step:5
  each t in todos stagger:60
    Row#todo swipe:left -> todos=removeWhere(todos,x=>x.id==t.id)
      Text "{t.t}"
''';
    final m = parseNotation(more, catalog: standardCatalog);
    expect(m.issues, isEmpty);
    expect(validateDocument(m.document).where((d) => d.severity == Severity.error), isEmpty);
    expect((((m.document['nodes'] as Map)['screen'] as Map)['actions'] as List).single, containsPair('trigger', {'type': 'timer', 'intervalMs': 1000, 'when': r'${= n<5}'}));
    expect(_node(m, 'tip')['props'], containsPair('divisions', 6));
    // A share of a row that follows a value grows (a segmented bar's parts).
    final bar = parseNotation('state a=3\nRow h:12\n  Box#seg grow:=a fill:#FF4285F4', catalog: standardCatalog);
    expect(bar.issues, isEmpty);
    expect(_node(bar, 'seg')['layout'], containsPair('flex', 1));
    expect((_node(bar, 'seg')['bind'] as Map)['layout.flex'], r'${a}');
    expect(((_node(m, 'todo')['actions'] as List).single as Map)['trigger'], {'type': 'swipeLeft'});
    expect((_node(m, 'todo')['bind'] as Map)['animations[0].delay'], r'${= index*60}');
    // A word it does not have is named with the ones it has; timing alone says where it goes.
    final bad = parseNotation('Text "x" animate:teleport\nText "y" duration:300', catalog: standardCatalog);
    expect(bad.issues.map((i) => i.message).join('\n'), allOf(contains('No animate:teleport'), contains('go with animate:')));
  });

  test('several lines, an area, a donut; a guessed prop in a JSON tail is read or named at its line', () {
    const text = '''
state room="Living Room"
Card
  LineChart#lines labels:["W1","W2","W3"] series:[{"name":"Signups","values":[40,52,61]},{"name":"Churn","values":[8,6,9],"color":"#FFDC2626"}]
  AreaChart#area values:[3,5,4] labels:["a","b","c"]
  Donut#d values:[60,25,15] labels:["Rent","Food","Other"]
  LineChart#plain values:[1,2,3]
  Box#b fill:#FFEEEEEE {"props": {"margin": [0, 8, 0, 0], "borderWidth": 2, "hexagon": true}}
  Input#msg "Message" {"props": {"multiline": true}}
  IconButton#star "star" color:#FFFFC107 size:28
  ChoiceChip#chip "Living Room" selected:=room=='Living Room' -> room="Living Room"
  Text.small.muted#tm "38:20"
  Box#hero h:120 gradient:["#FF7C3AED","#FFEC4899"]
  Image#img "assets/a.png" fit:contain
  IconButton#info "info" tooltip:"More"
''';
    final r = parseNotation(text, catalog: standardCatalog);
    // The one prop nothing reads is named where it was written; the rest are read.
    expect(r.issues.map((i) => i.message).toList(), [contains('has no "hexagon"')]);
    expect(validateDocument(r.document).where((d) => d.severity == Severity.error), isEmpty);
    final lines = _node(r, 'lines');
    expect(lines['type'], 'chart');
    expect(lines['props'], containsPair('chartType', 'line'));
    expect(((lines['props'] as Map)['data'] as List).first, {'label': 'W1', 's0': 40, 's1': 8});
    expect(((lines['props'] as Map)['series'] as List).map((s) => (s as Map)['name']), ['Signups', 'Churn']);
    expect((((_node(r, 'area')['props'] as Map)['series'] as List).single as Map)['kind'], 'area');
    final d = _node(r, 'd');
    expect(d['props'], containsPair('chartType', 'donut'));
    expect(((d['props'] as Map)['data'] as List).map((x) => (x as Map)['value']), [60, 25, 15]);
    expect(_node(r, 'plain')['type'], 'lineChart');
    expect((_node(r, 'b')['layout'] as Map)['margin'], [0, 8, 0, 0]);
    expect((_node(r, 'b')['decoration'] as Map)['strokeWidth'], 2);
    expect(_node(r, 'msg')['props'], containsPair('maxLines', 6));
    expect((_node(r, 'star')['props'] as Map)['style'], {'iconColor': '#FFFFC107', 'iconSize': 28});
    expect((_node(r, 'chip')['bind'] as Map)['props.selected'], contains('"Living Room"'));
    expect(_node(r, 'tm')['type'], 'text');
    expect((((_node(r, 'hero')['decoration'] as Map)['fills'] as List).single as Map)['stops'], hasLength(2));
    expect(((((_node(r, 'img')['decoration'] as Map)['fills'] as List).single as Map)['image'] as Map)['fit'], 'contain');
    expect(_node(r, 'info')['tooltip'], 'More');
  });

  test('a page written as several top-level sections stacks them in one column', () {
    const text = '''
state open=true
Row#header pad:16
  Text "Acme"
Column#main pad:24
  Text.title "Pricing"
if open
  Text#note "Shown"
Row#footer
  Text "Terms"
''';
    final r = parseNotation(text, catalog: standardCatalog);
    expect(r.issues, isEmpty);
    expect(validateDocument(r.document).where((d) => d.severity == Severity.error), isEmpty);
    expect(((r.document['nodes'] as Map)['screen'] as Map)['slots'], {'body': 'pageRoot'});
    expect(_node(r, 'pageRoot')['children'], ['header', 'main', 'note', 'footer']);
    // Streamed, the column takes the body and the first section moves into it.
    final stream = NotationStream(catalog: standardCatalog);
    final ops = [...stream.add(text), ...stream.close()];
    final at = ops.indexWhere((o) => o['op'] == 'set' && o['id'] == 'pageRoot');
    expect(at, greaterThan(0));
    expect(ops[at + 1], {'op': 'move', 'id': 'header', 'parent': 'pageRoot', 'index': 0});
    expect(ops.where((o) => o['op'] == 'set' && o['id'] == 'pageRoot'), hasLength(1));
    expect(ops.firstWhere((o) => o['id'] == 'main')['parent'], 'pageRoot');
  });

  test('the forms models write for placement, text, inputs and people', () {
    const text = '''
Column#page maxw:720
  Column#tab center
    Icon#ic "home"
    Text#lbl "Home"
  Column#mid middle h:200
    Text "x"
  Stack#st w:fill h:200 right bottom
    Button#fab "+"
  Text#t "Total" center
  Text#old "\$40" strike
  Input#pw "Password" type:password
  Input#pw2 "Confirm" password
  Input#note "Note" multiline
  Avatar#av "Maya Reyes" size:48
  Avatar#pic src:"assets/maya.png"
''';
    final r = parseNotation(text, catalog: standardCatalog);
    expect(r.issues, isEmpty);
    expect(validateDocument(r.document).where((d) => d.severity == Severity.error), isEmpty);
    expect((_node(r, 'page')['layout'] as Map)['constraints'], {'maxWidth': 720});
    // Column center: its children side by side centered, each as wide as it is (an icon over its label).
    expect(_node(r, 'tab')['props'], containsPair('crossAxisAlignment', 'center'));
    expect((_node(r, 'tab')['props'] as Map).containsKey('mainAxisAlignment'), isFalse);
    expect((_node(r, 'ic')['layout'] as Map)['width'], {'hug': 0});
    expect(_node(r, 'mid')['props'], containsPair('mainAxisAlignment', 'center'));
    expect(_node(r, 'fab')['layout'], containsPair('x', {'align': 1}));
    expect(_node(r, 'fab')['layout'], containsPair('y', {'align': 1}));
    expect(_node(r, 't')['props'], containsPair('textAlign', 'center'));
    expect(((_node(r, 'old')['props'] as Map)['style'] as Map)['decoration'], 'lineThrough');
    expect(_node(r, 'pw')['props'], containsPair('obscureText', true));
    expect((_node(r, 'pw')['props'] as Map).containsKey('keyboardType'), isFalse);
    expect(_node(r, 'pw2')['props'], containsPair('obscureText', true));
    expect(_node(r, 'note')['props'], containsPair('maxLines', 6));
    final av = _node(r, 'av');
    expect(av['layout'], containsPair('width', 48));
    expect((av['decoration'] as Map)['radius'], 24);
    expect((_node(r, 'avText')['props'] as Map)['text'], 'MR');
    expect((((_node(r, 'pic')['decoration'] as Map)['fills'] as List).single as Map)['image'], containsPair('url', 'assets/maya.png'));
  });

  test('a theme may say what a neutral fill written on the page becomes, where it would vanish into the page', () {
    final theme = {
      'colors': {
        'primaryText': '#FF111827', 'primaryBackground': '#FFFFFFFF', 'subtleFill': '#FFF3F4F6', 'page': '#FFF3F4F6',
        'card': '#FFFFFFFF', 'pageFill': '#FFFFFFFF', 'primaryBorder': '#FFE5E7EB',
      },
      'textStyles': {'body': {'fontSize': 13, 'color': 'primaryText'}},
    };
    const text = '''
Column
  Box#onPage w:44 h:44 radius:22 fill:#FFF1F5F9
  Card
    Box#inCard w:44 h:44 radius:22 fill:#FFF1F5F9
  Box#brand fill:#FF7C3AED
''';
    Object? fill(NotationResult r, String id) => ((_node(r, id)['decoration'] as Map)['fills'] as List).single;
    final r = parseNotation(text, catalog: standardCatalog, options: NotationOptions.fromTheme(theme, named: true));
    expect(r.issues, isEmpty);
    // On the page the gray would be the page's own color: the theme's fill for the page. In a card it is the neutral fill.
    expect(fill(r, 'onPage'), {'color': 'pageFill'});
    expect(fill(r, 'inCard'), {'color': 'subtleFill'});
    expect(fill(r, 'brand'), {'color': '#FF7C3AED'});
    // A theme without the name reads it as before.
    final plain = {...theme, 'colors': {...(theme['colors']! as Map)}..remove('pageFill')};
    expect(fill(parseNotation(text, catalog: standardCatalog, options: NotationOptions.fromTheme(plain, named: true)), 'onPage'), {'color': 'subtleFill'});
  });

  test('a theme may give the title a larger style on a wide page', () {
    final theme = {
      'colors': {'primaryText': '#FF111827'},
      'textStyles': {
        'body': {'fontSize': 13, 'color': 'primaryText'},
        'title': {'fontSize': 20, 'fontWeight': 700},
        'pageTitle': {'fontSize': 20, 'fontWeight': 600},
        'titleWide': {'fontSize': 28, 'fontWeight': 700},
      },
      'sizes': {'wide': 900},
    };
    const text = 'Column\n  Text.title "Inventory"\n  Text.pageTitle "Contacts"\n  Text.heading "Stock"';
    Object? style(NotationResult r, String id) => (_node(r, id)['props'] as Map)['style'];
    // At a phone's width the title is the title; from the theme's wide size up it is the wide title.
    final narrow = parseNotation(text, catalog: standardCatalog, options: NotationOptions.fromTheme(theme, named: true));
    expect(style(narrow, 'text1'), {'from': 'title', 'color': 'primaryText'});
    expect(style(narrow, 'text2'), {'from': 'pageTitle', 'color': 'primaryText'});
    final wide = parseNotation(text, catalog: standardCatalog, options: NotationOptions.fromTheme(theme, named: true, width: 1280));
    expect(wide.issues, isEmpty);
    expect(style(wide, 'text1'), {'from': 'titleWide', 'color': 'primaryText'});
    expect(style(wide, 'text2'), {'from': 'titleWide', 'color': 'primaryText'});
    expect(style(wide, 'text3'), style(narrow, 'text3'));
    // A theme without the two names (SSUI) is unchanged at any width.
    final plain = {...theme, 'sizes': <String, Object>{}};
    expect(style(parseNotation(text, catalog: standardCatalog, options: NotationOptions.fromTheme(plain, named: true, width: 1280)), 'text1'), {'from': 'title', 'color': 'primaryText'});
  });
  test('Pages: swiped pages bound to a variable, per element or per line, with a peek and dots', () {
    final r = _parse('''
state shoes=[{"name":"Aero"},{"name":"Trail"}]
Column gap:8
  Pages =i h:120 peek:0.86
    each s in shoes
      Text "{s.name}"
  Dots =i count:=length(shoes)
  Pages =j h:90
    Text "First"
    Text "Second"
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    final pages = _node(r, 'pageView1');
    expect(pages['props'], {'viewportFraction': 0.86, 'scrollDirection': 'horizontal', 'padEnds': false, 'edgeFade': 12});
    expect(pages['bind'], {'props.initialPage': r'${i}', 'data': r'${shoes}'});
    expect(((pages['actions'] as List).single as Map)['actions'], [
      {'type': 'setVariable', 'variable': 'i', 'value': r'${result.index}'},
    ]);
    expect((pages['layout'] as Map)['width'], {'fill': 0});
    expect((_node(r, 'pageView1Page')['layout'] as Map)['padding'], [0, 0, 8, 0]);
    // Lines under Pages are its pages: one per position, each shown at its own.
    final second = _node(r, 'pageView2');
    expect((second['props'] as Map)['itemCount'], 2);
    final texts = (_node(r, 'pageView2Page')['children'] as List).cast<String>();
    expect([for (final t in texts) (_node(r, t)['bind'] as Map)['visible']], [r'${= index == 0}', r'${= index == 1}']);
    // A list holding expressions is a formula, not broken JSON.
    final sums = _parse('state a=1\nColumn\n  BarChart values:[a+1,a*2,3]\n');
    expect(sums.issues, isEmpty);
    expect((_node(sums, 'barChart1')['bind'] as Map)['props.values'], r'${= [a+1,a*2,3]}');
    // A value word after := is the value, not a variable of that name.
    final off = _parse('Column\n  Button "Send" enabled:=false\n');
    expect(off.issues, isEmpty);
    expect(_problems(off.document), isEmpty);
    // A bare word that is a declared variable is the variable, not its name as text.
    final named = _parse('state pick="b"\nstate rows=[{"n":1}]\nColumn\n  Select items:["a","b"] value:pick\n  each r in rows\n    Progress value:r.n\n  Text "x" color:pick\n');
    expect(named.issues, isEmpty);
    expect((_node(named, 'dropdown1')['bind'] as Map)['props.value'], r'${pick}');
    // A value that follows state, written without a mark: braces, an expression, a call.
    final plain = _parse('state voted=false\nstate n=2\nColumn\n  Button "Vote" enabled:!voted\n  Progress value:{n}\n  Text "x" visible:n>1 && !voted\n  Text "y" hidden\n  Button "Go" enabled:n==2\n');
    expect(plain.issues, isEmpty, reason: '${plain.issues}');
    expect(_problems(plain.document), isEmpty);
    expect((_node(plain, 'filledButton1')['bind'] as Map)['props.enabled'], r'${= !voted}');
    expect((_node(plain, 'progressBar1')['bind'] as Map)['props.value'], r'${n}');
    expect((_node(plain, 'text1')['bind'] as Map)['visible'], r'${= n>1 && !voted}');
    // for … in, else, let: what three models wrote unprompted.
    final natural = _parse('state items = [{"n":1},{"n":0}]\nlet total = sum(items,i=>i.n)\nColumn\n  for it in items\n    if it.n > 0\n      Text "{it.n}"\n    else\n      Text "none"\n  Text "{total}"\n');
    expect(natural.issues, isEmpty, reason: '${natural.issues}');
    expect(_problems(natural.document), isEmpty);
    final shownIf = (natural.document['nodes']! as Map).values.cast<Map>().where((n) => n['type'] == 'text').map((n) => (n['bind'] as Map?)?['visible']).toList();
    expect(shownIf.take(2), [r'${= item.n > 0}', r'${= !(item.n > 0)}']);
    // A handler as a key, quoted, braced, or on a line of its own; `value` is the control's new value.
    final handled = _parse('state n = 0\nstate v = 3\nColumn\n  Button "Add" onPressed:{n = n + 1; v = 0}\n  Button "Sub" tap:"n = n - 1"\n  Slider onChanged:{v = value}\n  Button "Zero"\n    onPressed: n = 0\n');
    expect(handled.issues, isEmpty, reason: '${handled.issues}');
    expect(_problems(handled.document), isEmpty);
    Map react(String id) => (_node(handled, id)['actions'] as List).single as Map;
    expect(react('filledButton1')['trigger'], {'type': 'click'});
    expect((react('filledButton1')['actions'] as List).map((a) => (a as Map)['variable']), ['n', 'v']);
    expect(react('slider1')['trigger'], {'type': 'changed'});
    expect(((react('slider1')['actions'] as List).single as Map)['value'], r'${= result}');
    expect(((react('filledButton3')['actions'] as List).single as Map)['variable'], 'n');
    // A record of a list changed where it stands, and n += 1.
    final placed = _parse('state rows = [{"q":1},{"q":2}]\nstate n = 0\nColumn\n  for r in rows\n    Button "+" onPressed:{r.q += 1; n++}\n  Button "first" onPressed:{rows[0].q = 9}\n');
    expect(placed.issues, isEmpty, reason: '${placed.issues}');
    expect(_problems(placed.document), isEmpty);
    final acts = (placed.document['nodes']! as Map).values.cast<Map>().where((x) => x['actions'] != null).expand((x) => ((x['actions'] as List).single as Map)['actions'] as List).cast<Map>().toList();
    expect(acts[0], {'type': 'setVariable', 'variable': 'rows', 'value': r'${= setAt(rows,index,with(item,"q",item.q + (1)))}'});
    expect(acts[1], {'type': 'setVariable', 'variable': 'n', 'value': r'${= n + 1}'});
    expect(acts[2]['value'], r'${= setAt(rows,0,with(rows[0],"q",9))}');
    // Expressions with spaces and no mark, word operators, calls on a value, a guarded step, the timer as models write it.
    final spoken = _parse('state n = 2\nstate on = false\nstate rows = [{"q":1}]\nstate left = 5\nevery 1s while:{on} onTick:{left = left - 1; if (left == 0) { on = false }}\nColumn\n  Button "Go" enabled:n > 0 and not on onPressed:{rows.add({"q":2}); if (n > 1) { n = 0 }}\n  Text "{rows.length} rows, {rows.filter(r => r.q > 1).length} big"\n');
    expect(spoken.issues, isEmpty, reason: '${spoken.issues}');
    expect(_problems(spoken.document), isEmpty);
    expect((_node(spoken, 'filledButton1')['bind'] as Map)['props.enabled'], r'${= n > 0 && !on}');
    final go = (((_node(spoken, 'filledButton1')['actions'] as List).single as Map)['actions'] as List).cast<Map>();
    expect(go[0]['value'], r'${= append(rows,{"q":2})}');
    expect(go[1]['value'], r'${= (n > 1) ? (0) : n}');
    expect((_node(spoken, 'text1')['props'] as Map)['text'], r'${= length(rows)} rows, ${= length(filter(rows,r => r.q > 1))} big');
    // A row that scrolls goes sideways.
    final strip = _parse('Column\n  Row scroll gap:8\n    Box w:300 h:40\n    Box w:300 h:40\n');
    expect(_node(strip, 'row1')['props'], containsPair('scrollDirection', 'horizontal'));
    expect(_node(strip, 'row1')['props'], containsPair('edgeFade', 12));
    // The dots: one per page, the current one long, a tap goes to its page.
    final dot = (r.document['nodes']! as Map).values.cast<Map>().firstWhere((n) => (n['bind'] as Map?)?['layout.width'] != null);
    expect((dot['bind'] as Map)['layout.width'], r'${= index==i?16:6}');
    expect((((dot['actions'] as List).single as Map)['actions'] as List).single, containsPair('variable', 'i'));
  });

  test('named looks: the same lines name the theme\'s tokens, and resolve to each theme\'s own values', () {
    Json theme(String primary, String border, String text, double title) => {
          'primary': primary, 'surface': '#FFFFFCF7', 'success': '#FF15803D',
          'colors': {'primaryText': text, 'secondaryText': '#B81C1917', 'primaryBackground': '#FFFFFCF7', 'primaryBorder': border,
            'successTint': '#1A15803D', 'successTintBorder': '#4715803D'},
          'textStyles': {'sectionTitle': {'fontSize': title, 'fontWeight': 600, 'color': 'primaryText'}, 'body': {'fontSize': 13, 'color': 'primaryText'}},
          'radii': {'panel': 3},
        };
    final a = theme('#FF0F766E', '#FFE4E1DC', '#FF1C1917', 14), b = theme('#FFDB2777', '#FF334155', '#FFF8FAFC', 20);
    const text = '''
Card
  Text.sectionTitle "Billing"
  Text.muted "Next invoice on the 1st"
  Badge.success "Paid"
  Progress 0.4
  BarChart values:[1,2,3]
''';
    final r = parseNotation(text, catalog: standardCatalog, options: NotationOptions.fromTheme(a, named: true));
    expect(r.issues, isEmpty);
    expect((_node(r, 'text1')['props'] as Map)['style'], {'from': 'sectionTitle'});
    expect(((_node(r, 'column1')['decoration'] as Map)['strokes'] as List).single, {'color': 'primaryBorder'});
    expect((_node(r, 'barChart1')['props'] as Map)['color'], 'primary');
    expect(validateDocument(r.document, options: ValidateOptions(theme: ThemeTokens.fromJson(a))).where((d) => d.severity == Severity.error), isEmpty);
    // Written once, it is each theme's: the values are those the same lines
    // give when expanded with that theme's values written out.
    for (final t in [a, b]) {
      final resolved = resolveThemeRefs(LayoutDocument.fromJson(r.document, catalog: standardCatalog), ThemeTokens.fromJson(t)).toJson();
      final literal = parseNotation(text, catalog: standardCatalog, options: NotationOptions.fromTheme(t)).document;
      Object? at(Json d, String id, List<String> path) => path.fold<Object?>((d['nodes'] as Map)[id], (v, k) => v is Map ? v[k] : (v as List)[int.parse(k)]);
      for (final (id, path) in [
        ('column1', ['decoration', 'strokes', '0', 'color']),
        ('column1', ['decoration', 'fills', '0', 'color']),
        ('text1', ['props', 'style', 'color']),
        ('text1', ['props', 'style', 'fontSize']),
        ('text2', ['props', 'style', 'color']),
        ('row1', ['decoration', 'fills', '0', 'color']),
        ('barChart1', ['props', 'color']),
        ('progressBar1', ['props', 'color']),
      ]) {
        expect(at(resolved, id, path), at(literal, id, path), reason: '$id ${path.join('.')}');
      }
    }
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

  test('a size that follows data is a fixed size the binding fills in, so the box is not left to hug', () {
    final r = _parse('''
state levels=[6,14,22]
state live=true
Row gap:3 h:32
  each l in levels
    Box w:3 h:=live?l:4 fill:#FF2563EB
  Box w:=live?40:8 h:3 fill:#FF2563EB
''');
    expect(r.issues, isEmpty);
    expect(_problems(r.document), isEmpty);
    final bars = (r.document['nodes'] as Map).values.cast<Map>().where((n) => (n['bind'] as Map?)?.containsKey('layout.height') ?? false).toList();
    expect(bars, hasLength(1));
    expect((bars.single['layout'] as Map)['height'], 0);
    expect((bars.single['layout'] as Map)['width'], 3);
    expect((bars.single['bind'] as Map)['layout.height'], r'${= live?item:4}');
    final wide = (r.document['nodes'] as Map).values.cast<Map>().singleWhere((n) => (n['bind'] as Map?)?.containsKey('layout.width') ?? false);
    expect((wide['layout'] as Map)['width'], 0);
    expect((wide['layout'] as Map)['height'], 3);
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

  group('a design system\'s components', () {
    Map<String, Object?> component(String type, List<Object?> props, {List<Object?> events = const [], Object width = 100, String? children}) => {
          'schema': 3,
          'id': type,
          'roots': ['r'],
          'widget': {'type': type, 'doc': 'What a $type is for. More.', 'props': props, 'events': events, if (children != null) 'children': children},
          'nodes': {
            'r': {'type': 'column', 'layout': {'width': width, 'height': 28}, if (children != null) 'children': ['c']},
            if (children != null) 'c': {'type': 'slot'},
          },
        };
    const string = {'kind': 'string', 'flutter': 'String'};
    const number = {'kind': 'number', 'flutter': 'double'};
    final files = {
      'design_system.json': jsonEncode({
        'id': 'acme',
        'name': 'Acme',
        'theme': {'primary': '#FF2563EB', 'onSurface': '#FF111827'},
        'components': ['components/StatusPill.json', 'components/Counter.json', 'components/Frame.json', 'components/Button.json', 'components/Note.json', 'components/Pill.json', 'components/Question.json', 'components/Tabs.json'],
      }),
      'components/StatusPill.json': jsonEncode(component('StatusPill', [
        {'key': 'label', 'type': string, 'default': 'Status', 'required': true},
        {'key': 'tone', 'type': string, 'default': 'neutral'},
      ], events: [
        {'key': 'onPressed'},
      ], width: {'hug': 60})),
      'components/Counter.json': jsonEncode(component('Counter', [
        {'key': 'value', 'type': {'kind': 'variable', 'flutter': 'double', 'of': number}, 'default': ''},
        {'key': 'max', 'type': number, 'default': 10},
      ], events: [
        {'key': 'onChanged', 'payload': number},
      ], width: 120)),
      'components/Frame.json': jsonEncode(component('Frame', [
        {'key': 'title', 'type': string, 'default': ''},
      ], width: {'fill': 200}, children: 'list')),
      'components/Button.json': jsonEncode(component('Button', [
        {'key': 'label', 'type': string, 'default': 'Button'},
      ])),
      'components/Note.json': jsonEncode(component('Note', [
        {'key': 'title', 'type': string, 'default': ''},
        {'key': 'message', 'type': string, 'default': '', 'required': true},
        {'key': 'items', 'type': {'kind': 'list', 'flutter': 'List<String>', 'item': string}, 'default': <Object?>[]},
      ])),
      'components/Question.json': jsonEncode(component('Question', [
        {'key': 'question', 'type': string, 'default': '', 'required': true},
        {'key': 'open', 'type': {'kind': 'variable', 'flutter': 'bool', 'of': {'kind': 'boolean', 'flutter': 'bool'}}, 'default': false},
      ])),
    };
    files['components/Pill.json'] = jsonEncode(component('Pill', [
      {'key': 'label', 'type': string, 'default': '', 'required': true},
      {'key': 'note', 'type': string, 'default': ''},
      {'key': 'price', 'type': string, 'default': ''},
      {'key': 'tone', 'type': {'kind': 'enumeration', 'flutter': 'String', 'values': ['primary', 'quiet', 'danger']}, 'default': 'primary'},
      {'key': 'qty', 'type': number, 'default': 1},
    ]));
    files['components/Tabs.json'] = jsonEncode(component('Tabs', [
      {'key': 'tabs', 'type': {'kind': 'list', 'flutter': 'List<String>', 'item': string}, 'default': <Object?>[], 'required': true},
      {'key': 'value', 'type': {'kind': 'variable', 'flutter': 'String', 'of': string}, 'default': ''},
    ], events: [
      {'key': 'onChanged', 'payload': string},
    ], width: {'fill': 200}));
    late DesignSystem ds;
    late Catalog catalog;
    setUp(() async {
      final problems = <String>[];
      ds = await DesignSystem.load((ref) async => files[ref], problems: problems);
      expect(problems, isEmpty);
      catalog = ds.catalogOver(standardCatalog);
    });
    NotationResult parse(String text) =>
        Catalog.run(catalog, () => parseNotation(text, catalog: catalog, options: NotationOptions.fromDesignSystem(ds)));

    test('optional boolean state is independent for each component call', () {
      final r = parse('Question "First"\nQuestion "Second"');
      expect(r.issues, isEmpty);
      expect((_node(r, 'Question1')['props'] as Map)['open'], 'Question1_open');
      expect((_node(r, 'Question2')['props'] as Map)['open'], 'Question2_open');
      final names = [for (final v in ((r.document['variables']! as Map)['screen']! as List)) (v as Map)['name']];
      expect(names, containsAll(['Question1_open', 'Question2_open']));
    });

    test('what is written on a component line and can only mean one thing is read as that', () {
      final r = parse('''
state n=2
if n>0
  Pill "Bananas" "1 kg" "\$2.49" quiet qty=n
if n==0
  Text "Empty"
''');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      final nodes = r.document['nodes']! as Map;
      final node = nodes.values.cast<Map>().firstWhere((n) => n['type'] == 'Pill');
      // A bare word that one enumerated parameter has; a further string in
      // declared order; `=` where `:=` was meant.
      expect(node['props'], containsPair('tone', 'quiet'));
      expect(node['props'], containsPair('price', r'$2.49'));
      expect((node['bind'] as Map)['props.qty'], r'${n}');
      // Opening with `if`: the parts stack in a column of their own.
      expect((nodes['column1'] as Map)['children'], hasLength(2));
    });

    test('are called by name: the string is the label, =name the variable it keeps its value in, -> its first event', () {
      final r = parse('''
Column gap:8
  StatusPill "Paid" tone:success -> emit open
  Counter =seats max:5
  Frame "Billing"
    Text "Inside"
''');
      expect(r.issues, isEmpty);
      final pill = _node(r, 'StatusPill1');
      expect(pill['type'], 'StatusPill');
      expect(pill['props'], {'label': 'Paid', 'tone': 'success'});
      expect(((pill['actions'] as List).single as Map)['trigger'], {'type': 'event', 'event': 'onPressed'});
      // As big as its own design says: the pill hugs, the counter is 120 wide, the frame fills.
      expect(pill['layout'], {'width': {'hug': 0}, 'height': 28.0});
      final counter = _node(r, 'Counter1');
      expect(counter['props'], {'value': 'seats', 'max': 5});
      expect((counter['layout'] as Map)['width'], 120.0);
      expect(r.document['variables'], {
        'screen': [
          {'name': 'seats', 'type': 'decimal', 'value': 0},
        ],
      });
      final frame = _node(r, 'Frame1');
      expect((frame['layout'] as Map)['width'], {'fill': 0});
      expect(frame['children'], hasLength(1));
      expect(
        [
          for (final d in Catalog.run(catalog, () => validateDocument(r.document, options: ValidateOptions(components: ds.components, theme: ds.tokens))))
            if (d.severity == Severity.error) '${d.code.name} ${d.path}',
        ],
        isEmpty,
      );
    });

    test('a parameter a component does not have is named on its line, with what it takes', () {
      final r = parse('StatusPill "Paid" status:success');
      expect(r.issues.single.toString(), contains('A StatusPill has no "status". It takes: label, tone.'));
    });

    test('strings fill a component\'s text parameters in order; one alone goes to the one it needs', () {
      final two = parse('Note "Heads up" "The build is slow today."');
      expect(two.issues, isEmpty);
      expect(_node(two, 'Note1')['props'], {'title': 'Heads up', 'message': 'The build is slow today.'});
      final one = parse('Note "Saved."');
      expect(one.issues, isEmpty);
      expect(_node(one, 'Note1')['props'], {'message': 'Saved.'});
      final chosen = parse('state ok=true\nNote ok ? "Approved" : "Denied"');
      expect(chosen.issues, isEmpty);
      expect((_node(chosen, 'Note1')['bind'] as Map).keys, ['props.message']);
      final twice = parse('Note "Heads up" title:"Again" message:"m"');
      expect(twice.issues.single.toString(), contains("The string on this line is already the Note's title: write title once."));
      final none = parse('Note items:["a"]');
      expect(none.issues.single.toString(), contains('A Note needs message: write message:"…".'));
    });

    test('a name the notation already reads as a core type stays that type', () {
      final r = parse('Button "Save"');
      expect(_node(r, 'filledButton1')['type'], 'filledButton');
    });

    test('a Tabs line means the Tabs of a design system that has one, not the core tabs node; without one it is the core node', () {
      final r = parse('''
state tab="A"
Column
  Tabs =tab tabs:["A","B"]
  if tab=="A"
    Text "First"
''');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      final tabs = _node(r, 'Tabs1');
      expect(tabs['type'], 'Tabs');
      expect(tabs['props'], {'tabs': ['A', 'B'], 'value': 'tab'});
      final prompt = notationPrompt(catalog: catalog, options: NotationOptions.fromDesignSystem(ds), designSystem: ds);
      expect(prompt, contains('Tabs =value tabs! -> onChanged : What a Tabs is for.'));
      final core = parseNotation('Tabs titles:["A","B"]');
      expect((core.document['nodes']! as Map).values.cast<Map>().any((n) => n['type'] == 'tabs'), isTrue);
    });

    test('the prompt lists them as they are called, leaving out the names it reads as core types', () {
      final prompt = notationPrompt(catalog: catalog, options: NotationOptions.fromDesignSystem(ds), designSystem: ds);
      expect(prompt, contains('COMPONENTS (Acme'));
      expect(prompt, contains('StatusPill "label" tone -> onPressed : What a StatusPill is for.'));
      expect(prompt, contains('Counter =value max -> onChanged : What a Counter is for.'));
      expect(prompt, contains('Note "title" "message" items : What a Note is for.'));
      expect(prompt, contains('Frame "title" (children) : What a Frame is for.'));
      expect(prompt, isNot(contains('Button "label" :')));
      expect(notationPrompt(catalog: catalog, designSystem: ds, only: {'Counter'}), isNot(contains('StatusPill "label"')));
      expect(notationPrompt(), isNot(contains('COMPONENTS')));
    });
  });

  group('worked-out values as models write them', () {
    Map<String, Object?> nodesOf(String text) => (_parse(text).document['nodes']! as Map).cast<String, Object?>();
    String textOf(Map<String, Object?> nodes, String id) => ((nodes[id]! as Map)['props']! as Map)['text']! as String;

    test('a value that starts with quoted text is still a formula', () {
      final nodes = nodesOf('state n=2\nlet label = "Total " + n * 3\nCard\n  Text "{label}"\n');
      expect(textOf(nodes, 'text1'), r'${= ("Total " + n * 3)}');
    });

    test('quoted text holding an operator stays a value', () {
      final r = _parse('state note="a + b"\nCard\n  Text "{note}"\n');
      expect(jsonEncode(r.document['variables']), contains('"value":"a + b"'));
    });

    test('a call on a worked-out value', () {
      final nodes = nodesOf('state a=2\nlet sub = a * 1.5\nCard\n  Text "{sub.toFixed(2)}"\n');
      expect(textOf(nodes, 'text1'), r'${= fixed((a * 1.5),2)}');
    });

    test('a condition in braces with spaces, quotes and words', () {
      final nodes = nodesOf('state code=""\nstate n=1\nCard\n  Text visible:{n > 0 and not (code == "")} "Promo"\n');
      expect(jsonEncode(nodes['text1']), contains(jsonEncode(r'${= n > 0 && !(code == "")}')));
    });

  });

  group('a component wanted where none fits', () {
    test('the part is built as written and the request is recorded, not shown', () {
      final r = _parse('Card\n  Wanted "PollResults" "each option with its share"\n    Text "Ramen 9"\n  Wanted "Gauge"\n    Text "72"\n');
      expect(r.issues, isEmpty);
      expect([for (final w in r.wanted) '${w.name}|${w.purpose}'], ['PollResults|each option with its share', 'Gauge|']);
      final nodes = (r.document['nodes']! as Map).cast<String, Object?>();
      expect((nodes[r.wanted.first.node]! as Map)['type'], 'column');
      expect(jsonEncode(r.document), isNot(contains('each option with its share')));
      expect(jsonEncode(r.document), contains('Ramen 9'));
    });

    test('the prompt teaches it only when asked to', () {
      expect(notationPrompt(wanted: true), isNot(contains('Wanted "Name"')), reason: 'no design system, no components to want');
    });

  });

  group('values inside lists, and both marks at once', () {
    test('a text in a list that reads a value is its parts joined', () {
      final r = _parse('state n=4\nCard\n  Select =pick items:["Lemons, {2 * n}","\${fixed(n, 2)}","plain"]\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect(jsonEncode(r.document), contains(jsonEncode(r'${= [("Lemons, " + (2 * n)), ("$" + (fixed(n, 2))), "plain"]}')));
    });

    test('a list after := goes on past its spaces, quoted text included', () {
      final r = _parse('state pick=1\nstate total=3\nCard\n  Select =x items:=[["Price per person", pick==1 ? "£128" : "£84"],["Total", fixed(total, 2)]]\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect(jsonEncode(r.document), contains(jsonEncode(r'${= [["Price per person", pick==1 ? "£128" : "£84"],["Total", fixed(total, 2)]]}')));
    });

    test('a quoted text in a formula reads its values', () {
      final r = _parse('state n=4\nCard\n  Select =x items:=[["Serves","{n}"],["Each","\${fixed(n, 2)}"]]\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect(jsonEncode(r.document), contains(jsonEncode(r'${= [["Serves",("" + (n))],["Each",("$" + (fixed(n, 2)))]]}')));
    });

    test('a list left open at the end of a line goes on over the next lines', () {
      final r = _parse('state n=4\nCard\n  Select =x items:=[\n    "Chicken, "+round(800*n/4,0)+" g",\n    "Lemons, "+n\n  ]\n  Text "after"\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect(jsonEncode(r.document), contains(jsonEncode(r'${= [ "Chicken, "+round(800*n/4,0)+" g", "Lemons, "+n ]}')));
      expect(jsonEncode(r.document), contains('after'));
    });

    test('a value brace holds its own braces and quotes', () {
      final r = _parse('state pick="b"\nlet sel = find([{"id":"a","price":1},{"id":"b","price":2}], f => f.id == pick)\nCard\n  Text "Costs {sel.price}"\n  Select =x items:=[["Total","{money(sel.price,"\$",2)}"]]\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      final doc = jsonEncode(r.document);
      expect(doc, contains(jsonEncode(r'Costs ${= (find([{"id":"a","price":1},{"id":"b","price":2}], f => f.id == pick)).price}')));
      final inner = jsonEncode(r'("" + (money((find([{"id":"a","price":1},{"id":"b","price":2}], f => f.id == pick)).price,"$",2)))');
      expect(doc, contains(inner.substring(1, inner.length - 1)));
    });

    test('a property after the actions, a fence around the answer, and an action that sets a worked-out value', () {
      final r = _parse('```\nstate step=1\nstate ok=true\nstate tally=[1,2]\nstate total=sum(tally,x=>x)\nCard\n  Button "Go" -> step = 3 enabled:{ok}\n  Button "Vote" -> tally=append(tally,1); total=total+1; toast "Thanks"\n  Text "{total}"\n```\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      final nodes = (r.document['nodes']! as Map).cast<String, Object?>();
      final go = jsonEncode(nodes['filledButton1']), vote = jsonEncode(nodes['filledButton2']);
      expect(go, contains(r'"props.enabled":"${ok}"'));
      expect(go, contains(r'"value":"${= 3}"'));
      expect(vote, contains('append(tally,1)'));
      expect(vote, contains('Thanks'));
      expect(vote, isNot(contains('sum(tally')), reason: 'the total follows the tally; it is not set');
    });

    test('key:={expression}', () {
      final r = _parse('state running=false\nstate done=1\nCard\n  Button "Go" enabled:={!running && done < 6}\n');
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect(jsonEncode(r.document), contains(jsonEncode(r'${= !running && done < 6}')));
    });

  });
  group('the page words', () {
    Json nodes(NotationResult r) => (r.document['nodes']! as Map).cast<String, Object?>();
    Json node(NotationResult r, String id) => (nodes(r)[id]! as Map).cast<String, Object?>();

    test("a theme's page tier: on a wide canvas a name ending in Wide takes the place of the name before it", () {
      const theme = <String, Object?>{
        'colors': {'primaryText': '#FF111827', 'card': '#FFFFFFFF', 'pageFill': '#FFFFFFFF', 'page': '#FFF3F4F6', 'band': '#FFF8FAFC'},
        'textStyles': {
          'strong': {'fontSize': 14.5, 'fontWeight': 600},
          'strongWide': {'fontSize': 15, 'fontWeight': 600},
        },
        'radii': {'card': 26, 'cardWide': 16},
        'spacing': {'card': 18, 'cardWide': 24, 'section': 88},
        'sizes': {'wide': 900, 'cta': 46, 'ctaWide': 0, 'controlWide': 40},
      };
      final card = NotationOptions.fromTheme(theme), page = NotationOptions.fromTheme(theme, width: 1280);
      expect((card.textStyles['strong']! as Map)['fontSize'], 14.5);
      expect((page.textStyles['strong']! as Map)['fontSize'], 15);
      expect((card.card['decoration']! as Map)['radius'], 26);
      expect((page.card['decoration']! as Map)['radius'], 16);
      expect((page.card['layout']! as Map)['padding'], 24);
      // A card's one button is as wide as the card; a page's is as big as its label, at the page's height.
      expect(card.cta, isNotNull);
      expect(page.cta, isNull);
      expect(card.controlHeight, isNull);
      expect(page.controlHeight, 40);
      expect(page.sectionPad, 88);

      final r = parseNotation('''
Page
  Section#a tint
    Button#go "Start"
    Button#big "Start" size:large
    Row#cards gap:16
      Card grow
        Text "a"
      Card grow
        Text "b"
''', catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      expect((node(r, 'go')['layout']! as Map)['height'], 40);
      expect((node(r, 'big')['layout']! as Map)['height'], 44);
      expect((node(r, 'big')['props']! as Map).containsKey('size'), isFalse);
      // A tinted band is on the theme's band color; cards side by side are equally tall.
      expect(jsonEncode(node(r, 'a')['decoration']), contains('FFF8FAFC'));
      expect((node(r, 'cards')['props']! as Map)['crossAxisAlignment'], 'stretch');
    });

    test('a see-through fill on a card sits over the card, so its shadow does not show through', () {
      final r = parseNotation('''
Card#plan fill:#0F2563EB
  Text "Team"
''', catalog: standardCatalog);
      expect(r.issues, isEmpty);
      final fills = (node(r, 'plan')['decoration']! as Map)['fills']! as List;
      expect(fills, hasLength(2));
      expect((fills.last as Map)['color'], '#0F2563EB');
    });

    test('the small parts of a page: Brand, IconTile, a search field in a bar, a badge with a width, a text with a rule', () {
      final r = parseNotation('''
App
  Sidebar
    Brand "Harbor" icon:"anchor"
    NavItem#on "Orders" icon:"inbox" selected
  Main
    Nav
      Heading "Orders" level:1
      Input#q "Search orders" =q w:220
    Column pad:24
      IconTile#tile "sync"
      Row
        Badge.success#paid "Paid" w:120
      Text#toc "Install" border-left:#FFE5E7EB id:install
      Avatar#who src:"https://example.com/a.png" size:32
''', catalog: standardCatalog, options: const NotationOptions(width: 1280));
      expect(r.issues, isEmpty);
      // The field's label is its hint.
      final q = jsonEncode(node(r, 'q')['props']);
      expect(q, contains('Search orders'));
      expect(q, isNot(contains('labelText":"Search')));
      // The tile is a box with the icon in it.
      expect(node(r, 'tile')['children'], hasLength(1));
      // The badge keeps its size in a cell 120 wide.
      expect((node(r, 'paid')['layout']! as Map)['width'], isNot(120));
      // The text sits in a box that carries the rule.
      expect(node(r, 'toc')['decoration'], isNull);
    });

    test('a website page: sections are full-width bands with their content in a centered column', () {
      final r = parseNotation('''
Page
  Nav
    Text.strong "Tidewater"
    Button "Start free"
  Section#hero narrow
    Heading "Fill every room" level:1
  Footer
    Text "© 2026"
''', catalog: standardCatalog, options: const NotationOptions(width: 1280));
      expect(r.issues, isEmpty);
      final root = node(r, (node(r, 'screen')['slots']! as Map)['body'] as String);
      expect(root['type'], 'column');
      expect((root['props']! as Map)['scrollable'], true);
      // A page is as tall as its content.
      expect((node(r, 'screen')['layout']! as Map)['height'], {'hug': 0});
      final hero = node(r, 'hero');
      expect((hero['layout']! as Map)['width'], {'fill': 0});
      expect((hero['props']! as Map)['crossAxisAlignment'], 'center');
      final inner = node(r, (hero['children']! as List).single as String);
      expect(jsonEncode(inner['layout']), contains('720'));
      // The bar: one row, its ends apart, then a rule.
      final kids = (root['children']! as List).cast<String>();
      final bar = node(r, (node(r, kids[0])['children']! as List).single as String);
      expect((bar['props']! as Map)['mainAxisAlignment'], 'spaceBetween');
      expect(node(r, kids[1])['type'], 'divider');
    });

    test('an app window: panes as tall as the window, the canvas with the window\'s height', () {
      final r = parseNotation('''
state tab="orders"
App
  Sidebar#side
    NavItem#orders "Orders" icon:"inbox" badge:"12" selected:=tab=="orders" -> tab="orders"
    Spacer#push grow
  Main#main
    Nav#bar
      Heading "Orders"
    Row
      Pane#detail w:260
        Text "Details"
''', catalog: standardCatalog, options: const NotationOptions(width: 1280, height: 720));
      expect(r.issues, isEmpty);
      expect((node(r, 'screen')['layout']! as Map)['height'], {'fill': 720});
      expect((node(r, 'side')['layout']! as Map)['width'], 248);
      expect((node(r, 'side')['layout']! as Map)['height'], {'fill': 0});
      expect((node(r, 'side')['decoration']! as Map)['strokeSides'], 'right');
      expect((node(r, 'main')['layout']! as Map)['flex'], 1);
      expect((node(r, 'push')['layout']! as Map)['height'], {'fill': 0});
      final item = node(r, 'orders');
      expect(item['type'], 'row');
      expect((item['bind']! as Map)['decoration.fills[0].color'], contains('tab=="orders"'));
      expect((item['children']! as List).length, 3);
      // A pane further in is a column of its row, not a pane of the window.
      expect((node(r, 'detail')['layout']! as Map)['height'], {'hug': 0});
      // In a window a bar is one row with its padding, not a band.
      expect(node(r, 'bar')['type'], 'row');
    });

    test('a root written h:fill is a window too; a frame word inside a card is a plain row or column', () {
      final windowed = parseNotation('Row h:fill\n  Text "a"', catalog: standardCatalog);
      expect((node(windowed, 'screen')['layout']! as Map)['height'], {'fill': 800});
      final card = parseNotation('Card\n  Header#h\n    Text "Title"\n  Section#s\n    Text "Body"', catalog: standardCatalog);
      expect(card.issues, isEmpty);
      expect(node(card, 'h')['type'], 'row');
      expect((node(card, 's')['children']! as List).length, 1);
    });

    test('a spread row is level and as wide as its place; an icon keeps its size; a code sample\'s braces are text', () {
      final r = parseNotation('''
Column center
  Row#r between center
    Text "a"
    Text "b"
  Icon#i "sync"
  Text#t "import { Beacon } from 'sdk'; track('x', {\\n  plan: 'pro',\\n})"
  Text#u "Total: {total}"
''', catalog: standardCatalog);
      expect((node(r, 'r')['props']! as Map)['mainAxisAlignment'], 'spaceBetween');
      expect((node(r, 'r')['props']! as Map)['crossAxisAlignment'], 'center');
      expect((node(r, 'r')['layout']! as Map)['width'], {'fill': 0});
      expect((node(r, 'i')['layout']! as Map)['width'], {'hug': 0});
      expect((node(r, 't')['props']! as Map)['text'], contains('{ Beacon }'));
      expect(jsonEncode(node(r, 'u')), contains(r'${'));
    });

    test('the prompt teaches the page words from a desktop width on', () {
      expect(notationPrompt(catalog: standardCatalog), isNot(contains('PAGES')));
      final wide = notationPrompt(catalog: standardCatalog, options: const NotationOptions(width: 1280));
      expect(wide, contains('PAGES'));
      // Its two examples read without an issue.
      final examples = wide.substring(wide.lastIndexOf('\n  Page\n'));
      final page = examples.substring(0, examples.indexOf('\n  state tab')).split('\n').map((l) => l.startsWith('  ') ? l.substring(2) : l).join('\n');
      final app = examples.substring(examples.indexOf('\n  state tab')).split('\n').map((l) => l.startsWith('  ') ? l.substring(2) : l).join('\n');
      expect(parseNotation(page, catalog: standardCatalog, options: const NotationOptions(width: 1280)).issues, isEmpty);
      expect(parseNotation(app, catalog: standardCatalog, options: const NotationOptions(width: 1280)).issues, isEmpty);
    });
  });

  group('a page written once lays out on a tablet and a phone', () {
    const page = NotationOptions(width: 1280);
    Map<String, Object?> nodesOf(NotationResult r) => (r.document['nodes']! as Map).cast<String, Object?>();
    Map<String, Object?> node(NotationResult r, String id) => (nodesOf(r)[id]! as Map).cast<String, Object?>();
    // The patch a node takes at a width, its rules merged in order.
    Map<String, Object?> at(NotationResult r, String id, int width) {
      var out = <String, Object?>{};
      for (final rule in ((node(r, id)['media'] as List?) ?? const []).cast<Map>()) {
        final max = rule['maxWidth'] as num?, min = rule['minWidth'] as num?;
        if ((max == null || width <= max) && (min == null || width >= min)) {
          out = mergePatch(out, (rule['patch']! as Map).cast<String, Object?>(), keepNulls: true);
        }
      }
      return out;
    }

    test('a grid\'s rows wrap, each cell at a least width; nothing changes at the width it was written for', () {
      final r = parseNotation('''
Page
  Section
    Grid#plans cols:3 gap:24
      Card#a
        Text "One"
      Card#b
        Text "Two"
      Card#c
        Text "Three"
      Card#d
        Text "Four"
''', catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      expect(at(r, 'plansRow1', 834)['props'], {'wrap': true, 'runSpacing': 24});
      expect((at(r, 'a', 390)['layout']! as Map)['basis'], 220);
      // The empty cells that fill out the last row are gone on a phone.
      final filler = (node(r, 'plansRow2')['children']! as List).last as String;
      expect(node(r, filler)['type'], 'spacer');
      expect(at(r, filler, 390)['visible'], false);
      expect(at(r, filler, 834)['visible'], isNull);
      for (final id in nodesOf(r).keys) {
        expect(at(r, id, 1280), isEmpty, reason: id);
      }
    });

    test('a row of blocks wraps: the content keeps a column\'s width and a fixed rail takes the width on a phone', () {
      final r = parseNotation('''
Page
  Section
    Row#split gap:32 top
      Column#copy grow gap:12
        Heading "Reserve a table"
        Text "Open every day."
        Row gap:8
          Button "Book"
          Button.outline "Menu"
      Card#rail w:320
        Text "Tonight"
''', catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      expect((at(r, 'split', 834)['props']! as Map)['wrap'], true);
      expect((at(r, 'copy', 834)['layout']! as Map)['basis'], 360);
      expect(at(r, 'rail', 834), isEmpty);
      expect(at(r, 'rail', 390)['layout'], {'width': {'fill': 0}, 'basis': 280, 'flex': 1});
    });

    test('any other row wraps before it overflows; what grows in it keeps its share', () {
      final r = parseNotation('''
Page
  Section
    Row#bar gap:12 middle
      Input#q "Search" grow
      Spacer#gap grow
      Button "Export"
''', catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      expect((at(r, 'bar', 390)['props']! as Map)['wrap'], true);
      expect((at(r, 'q', 390)['layout']! as Map)['basis'], 180);
      expect((at(r, 'gap', 390)['layout']! as Map)['basis'], 0);
    });

    test('a table\'s row keeps the columns a phone has room for, from the first on', () {
      final r = parseNotation('''
Page
  Section
    Card pad:0
      Row#head gap:16 pad:[20,12,20,12]
        Text#name "Name" grow
        Text#company "Company" w:160
        Text#status "Status" w:90
        Text#plan "Plan" w:90
        Text#value "Value" w:110
        Text#seen "Last seen" w:110
''', catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      expect(node(r, 'head')['media'], isNull);
      expect(at(r, 'name', 390), isNot(contains('visible')));
      expect(at(r, 'company', 390), isNot(contains('visible')));
      expect(at(r, 'seen', 390)['visible'], false);
      // On a tablet its columns are shares of the row, and the last ones go.
      expect(at(r, 'company', 834)['visible'], isNull);
      expect(at(r, 'seen', 834)['visible'], false);
    });

    test('an app shows its main pane on a phone; a bar hides its links; a section and a headline are smaller', () {
      final app = parseNotation('''
App
  Sidebar#side
    NavItem "Inbox" icon:"inbox" selected
  Main#main
    Text "Hello"
  Pane#details w:300
    Text "Details"
''', catalog: standardCatalog, options: page);
      expect(app.issues, isEmpty);
      expect(at(app, 'side', 390)['visible'], false);
      expect(at(app, 'side', 834)['visible'], isNull);
      expect(at(app, 'details', 834)['visible'], false);
      expect(at(app, 'main', 390), isEmpty);

      final site = parseNotation('''
Page
  Nav
    Brand "Tidewater" icon:"waves"
    Row#links gap:4
      Link "Features"
      Link "Pricing"
    Button "Start free"
  Section#hero
    Text#big "Fill every room" size:56 weight:800
''', catalog: standardCatalog, options: page);
      expect(site.issues, isEmpty);
      expect(at(site, 'links', 390)['visible'], false);
      expect(at(site, 'links', 834)['visible'], isNull);
      expect(((at(site, 'big', 390)['props']! as Map)['style']! as Map)['fontSize'], 40);
      expect((at(site, 'hero', 390)['layout']! as Map)['padding'], [20, 40, 20, 40]);
    });

    test('a donut written with labels has its legend beside it, and under it where the two do not fit', () {
      const text = '''
Page
  Section
    Card
      Donut#mix values:[1370,560,380] labels:["Street trees","School shade","Pocket forests"] h:240
      Donut#bare values:[3,1] labels:["Yes","No"] legend:false
''';
      final r = parseNotation(text, catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      final mix = node(r, 'mix');
      expect(mix['type'], 'row');
      expect((mix['props']! as Map)['wrap'], true);
      expect(mix['children'], ['mixChart', 'mixLegend']);
      expect(node(r, 'mixChart')['layout'], {'height': 240, 'width': 240});
      expect((node(r, 'mixLegend')['layout']! as Map)['basis'], 160);
      expect((node(r, 'mixLabel0')['props']! as Map)['text'], 'Street trees');
      expect((node(r, 'mixShare0')['props']! as Map)['text'], '59%');
      expect(node(r, 'bare')['type'], 'chart');
      // A page that writes the legend itself keeps its own.
      final own = parseNotation('''
Page
  Section
    Donut#mix values:[52,48] labels:["Online","Retail"]
    Row between
      Text.muted "Online"
      Text.strong "52%"
    Row between
      Text.muted "Retail"
      Text.strong "48%"
''', catalog: standardCatalog, options: page);
      expect(node(own, 'mix')['type'], 'chart');
      expect(nodesOf(own).keys.where((k) => k.startsWith('mixLegend')), isEmpty);
      // On a card it is the chart alone, as before.
      final card = parseNotation('Column\n  Donut#mix values:[3,1] labels:["Yes","No"]\n', catalog: standardCatalog);
      expect(node(card, 'mix')['type'], 'chart');
    });

    test('what the twenty sites met: a size word under an if, short columns side by side, controls with choices, a site\x27s variable, a page worked out', () {
      final r = parseNotation('''
state menu=false
state kind="All"
project cart=[]
Page
  Section
    if menu
      Column#links show:phone
        Text "Docs"
    Row#pair gap:32
      Column#one grow
        Heading "Fast"
        Text "Builds in seconds."
      Column#two grow
        Heading "Small"
        Text "No dependencies."
    Row#who gap:12
      Avatar "Maya Reyes"
      Column#name grow
        Text.strong "Maya Reyes"
        Text.muted "Owner"
    Row#filters gap:12
      SegmentedButton#level =kind options:["All","Beginner","Intermediate","Advanced"] grow
      Button#add "Add" -> cart=append(cart,"x"); go replace(lower(kind)," ","_")
      Button#home "Home" -> go home
''', catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      // Hidden from a tablet up whatever the condition says; on a phone the condition decides.
      expect(at(r, 'links', 834), {'visible': false, 'bind': {'visible': null}});
      expect(at(r, 'links', 390), isEmpty);
      expect((node(r, 'links')['bind']! as Map)['visible'], isNotNull);
      // Two short columns are blocks; a name beside its picture is a label.
      expect((at(r, 'one', 390)['layout']! as Map)['basis'], 280);
      expect((at(r, 'name', 390)['layout']! as Map)['basis'], 96);
      // The site's variable is not declared on the screen, and is still read and set.
      final declared = [for (final v in ((r.document['variables']! as Map)['screen']! as List)) (v as Map)['name']];
      expect(declared, containsAll(['menu', 'kind']));
      expect(declared, isNot(contains('cart')));
      final add = jsonEncode(node(r, 'add')['actions']);
      expect(add, contains('"variable":"cart"'));
      expect(add, contains(r'"to":"${='));
      expect(jsonEncode(node(r, 'home')['actions']), contains('"to":"home"'));
    });

    test('a short each alias leaves layout keys intact', () {
      final r = parseNotation('''
state homes=[{"name":"One"}]
Page
  Section
    each h in homes
      Card
        Text#homeName "{h.name}" h:120
''', catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      expect(node(r, 'homeName')['layout'], containsPair('height', 120));
      expect((node(r, 'homeName')['props'] as Map).containsKey('item'), isFalse);
      expect(jsonEncode(node(r, 'homeName')), contains('item.name'));
    });

    test('a Nav opens its links from a menu on a phone; a link scrolls to an anchor; a header sticks', () {
      final r = parseNotation('''
Page
  Nav#bar sticky
    Brand "Tidewater" icon:"waves"
    Row#links gap:4
      Link "Features" href:"#features"
      Link "Pricing" -> scroll pricing
      Link "Docs" -> go docs
    Button "Start free"
  Section#features
    Heading "Features"
  Section
    Heading#price "Pricing" #pricing
''', catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      expect(node(r, 'bar')['sticky'], {'offset': 0});
      // The links go on a phone, and a menu button shows there only.
      expect(at(r, 'links', 390)['visible'], false);
      final button = nodesOf(r).entries.firstWhere((e) => (e.value! as Map)['type'] == 'iconButton');
      expect(at(r, button.key, 390), isEmpty);
      expect(at(r, button.key, 834)['visible'], false);
      expect(jsonEncode((button.value! as Map)['actions']), contains('"variable":"navMenu"'));
      final variables = ((r.document['variables']! as Map)['screen']! as List).cast<Map>();
      expect(variables.firstWhere((v) => v['name'] == 'navMenu'), {'name': 'navMenu', 'type': 'boolean', 'value': false});
      // Its menu repeats the links, each closing the menu and then doing what the link does.
      final rows = [
        for (final n in nodesOf(r).values.cast<Map>())
          if (n['type'] == 'row' && jsonEncode(n['actions'] ?? '').contains('"variable":"navMenu"')) jsonEncode(n['actions']),
      ];
      expect(rows, hasLength(3));
      expect(rows[0], contains('"type":"scrollTo","node":"features"'));
      expect(rows[1], contains('"type":"scrollTo","node":"price"'));
      expect(rows[2], contains('"type":"navigate","to":"docs"'));

      // A date field's string is its label; a site's value is bound by a control with no copy on the screen.
      final form = parseNotation('''
project guests=2
state when=""
Page
  Section
    DatePicker#d "Arrival" =when
    Select#g =guests items:[1,2,3]
''', catalog: standardCatalog, options: page);
      expect(form.issues, isEmpty);
      expect(((node(form, 'd')['props']! as Map)['decoration']! as Map)['labelText'], 'Arrival');
      expect(jsonEncode(node(form, 'g')['bind']), contains('guests'));
      expect(jsonEncode(form.document['variables']), isNot(contains('guests')));

      // A Nav that writes its own phone menu keeps it, and gets no second one.
      final own = parseNotation('''
Page
  Nav
    Row gap:4
      Link "Docs" -> go docs
    IconButton#mine "menu" show:phone -> open=!open
''', catalog: standardCatalog, options: page);
      expect(nodesOf(own).values.where((n) => (n! as Map)['type'] == 'iconButton'), hasLength(1));
      expect(jsonEncode(own.document), isNot(contains('navMenu')));
    });

    test('from the sites\' second round: the site\'s variables from its manifest, a size word beside a value of its name, a line that says where it shows, bleed, a compact band, a sticky bar\'s surface, a link\'s ink', () {
      final theme = NotationOptions.fromTheme(const {
        'colors': {'primary': '#FFFACC15', 'accentDeep': '#FF854D0E', 'pageFill': '#FFFFFFFF'},
        'sizes': {'wide': 900},
      }, width: 1280);
      final options = NotationOptions(
        width: 1280,
        accent: theme.accent,
        accentText: theme.accentText,
        siteFill: theme.siteFill,
        projectVariables: const {
          'cart': {'name': 'cart', 'type': 'integer', 'value': 0},
        },
      );
      final r = parseNotation('''
state phone=""
Page
  Nav#bar sticky
    Row gap:4
      Link#docs "Docs" -> go docs
      Link#call "Call us" show:phone -> go call
  Section#wide bleed
    Text "{cart} in the cart"
    Button#add "Add" -> cart=cart+1
    Input "Phone" =phone
    Link#more "Read more" -> go more
  Section#strip compact
    Text "Trusted by many"
''', catalog: standardCatalog, options: options);
      expect(r.issues, isEmpty);
      // The site's value is used by name and not declared on the screen.
      final declared = [for (final v in ((r.document['variables'] as Map?)?['screen'] as List? ?? const [])) (v as Map)['name']];
      expect(declared, contains('phone'));
      expect(declared, isNot(contains('cart')));
      expect(jsonEncode(node(r, 'add')['actions']), contains(r'${= cart+1}'));
      // show:phone is the screen's size here, not the page's value called phone;
      // and the link that says so shows on a phone, where the bar hides the others.
      expect(node(r, 'call')['bind'], isNull);
      expect(at(r, 'call', 390), isEmpty);
      expect(at(r, 'call', 834)['visible'], false);
      expect(at(r, 'docs', 390)['visible'], false);
      // A bleed section's content runs edge to edge; a compact band stays the shorter one on a phone.
      expect((node(r, 'wide')['layout']! as Map)['padding'], [0, 64, 0, 64]);
      expect((at(r, 'strip', 390)['layout']! as Map)['padding'], [20, 24, 20, 24]);
      // A sticky bar is drawn on the page's surface, and a link in text is in the accent's ink.
      expect(node(r, 'bar')['sticky'], {'offset': 0});
      expect(jsonEncode(node(r, 'bar')['decoration']), contains('#FFFFFFFF'));
      expect(jsonEncode(node(r, 'more')['props']), contains('#FF854D0E'));
    });

    test('from the sites\' third round: a page id with a hyphen, a destination already worked out, the links a Nav\'s menu repeats', () {
      final r = parseNotation('''
Page
  Nav
    Brand "Relay"
    Row gap:4
      Link "Customers" -> go case-study
      Link "Pricing" -> go pricing
    Row gap:8
      Link#search "Search" menu:false -> go search
      Link#login "Log in" -> go \${= lower("Login")}
      Button "Start" -> go replace(lower("Get Started")," ","-")
''', catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      final all = jsonEncode(r.document);
      expect(all, contains('"to":"case-study"'));
      expect(all, contains(r'"to":"${= lower(\"Login\")}"'));
      expect(all, contains(r'"to":"${= replace('));
      // The menu repeats the two links of the row the bar hides: not the one
      // kept out of it, nor the lone link beside the button.
      final rows = [
        for (final n in nodesOf(r).values.cast<Map>())
          if (n['type'] == 'row' && jsonEncode(n['actions'] ?? '').contains('"variable":"navMenu"')) jsonEncode(n['actions']),
      ];
      expect(rows, hasLength(2));
      expect(rows.join(), isNot(contains('"to":"search"')));
      final button = nodesOf(r).values.cast<Map>().firstWhere((n) => n['type'] == 'iconButton');
      expect((button['layout']! as Map)['width'], 40);
    });

    test('hide: and show: say where a node shows; a card, or a page with reflow off, takes no rules', () {
      final r = parseNotation('''
Page
  Section
    Button#menu "Menu" show:phone
    Text#long "The long version" hide:phone
    Text#wide "Desktop only" hide:tablet
''', catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      expect(at(r, 'menu', 390), isEmpty);
      expect(at(r, 'menu', 834)['visible'], false);
      expect(at(r, 'long', 390)['visible'], false);
      expect(at(r, 'long', 834), isEmpty);
      expect(at(r, 'wide', 834)['visible'], false);
      expect(at(r, 'wide', 1280), isEmpty);

      const text = '''
Column
  Grid cols:2
    Card
      Text "One"
    Card
      Text "Two"
''';
      for (final options in const [NotationOptions(), NotationOptions(width: 1280, reflow: false)]) {
        final plain = parseNotation(text, catalog: standardCatalog, options: options);
        expect(nodesOf(plain).values.where((n) => (n! as Map).containsKey('media')), isEmpty);
      }
    });
  });

  group('what is shown over a page', () {
    const page = NotationOptions(width: 1280);
    // Valid at any level: a page's media rules and a right click are past level 2.
    List<String> problems(Map<String, Object?> doc) => [
          for (final d in Catalog.run(standardCatalog, () => validateDocument(doc)))
            if (d.severity != Severity.info) '${d.code.name} ${d.path}: ${d.message}',
        ];
    Map<String, Object?> nodesOf(NotationResult r) => (r.document['nodes']! as Map).cast<String, Object?>();
    Map<String, Object?> node(NotationResult r, String id) => (nodesOf(r)[id]! as Map).cast<String, Object?>();
    Map<String, Object?> open(NotationResult r, String id) =>
        ((((node(r, id)['actions']! as List).first as Map)['actions']! as List).last as Map).cast<String, Object?>();
    List<String> kinds(NotationResult r, String id) => [
          for (final a in ((node(r, id)['actions']! as List).first as Map)['actions']! as List) (a as Map)['type']! as String,
        ];

    const text = '''
state email=""
state sort="Newest"
Page
  Section
    Button#join "Join" -> open signup
    Button#filter "Filters" -> open filters
    Button#sortBy "Sort" -> open sortMenu
    Button#what "What is this?" -> open tip
    Button#bag "Cart" -> open cart
    Text "Sorted by {sort}"

Dialog#signup "Join the waitlist" "We write once." w:420
  Input "Email" =email
  Button#go "Join" -> joined=true; close
  Button#again "More" -> open tip

Sheet#filters "Filters"
  Toggle "Only open rooms" =onlyOpen

Menu#sortMenu end
  MenuItem#newest "Newest" icon:"schedule" -> sort="Newest"
  MenuItem#price "Price" -> sort="Price"; close
  MenuItem#ask "Ask" -> open signup

Popover#tip above
  Text#tipText "Every room is cleaned between stays."
  Button#ok "Got it" -> close

Drawer#cart right w:340 "Your cart"
  NavItem#orders "Orders" -> tab="orders"
  Chip#gift "Gift wrap" -> gift=!gift
''';

    test('a Dialog, a Sheet, a Menu, a Popover and a Drawer are canvases of their own, opened as their kind says', () {
      final r = parseNotation(text, catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      expect(problems(r.document), isEmpty);
      expect(r.document['roots'], ['screen', 'signup', 'filters', 'sortMenu', 'tip', 'cart']);
      // The page is as it would be without them.
      expect(node(r, 'screen')['layout'], {'width': 1280, 'height': {'hug': 0}});

      // A dialog: a canvas its own width, as tall as its content, with its
      // title, a close button and the line under the title.
      final dialog = node(r, 'signup');
      expect(dialog['type'], 'canvas');
      expect(dialog['layout'], {'width': 420, 'height': {'hug': 0}});
      expect((dialog['decoration']! as Map)['radius'], 16);
      expect(open(r, 'join'), {'type': 'openModal', 'to': 'signup', 'presentation': 'dialog', 'insets': [16, 24, 16, 24]});
      final texts = [
        for (final n in nodesOf(r).values.cast<Map>())
          if (n['type'] == 'text') (n['props'] as Map)['text'],
      ];
      expect(texts, containsAll(['Join the waitlist', 'We write once.']));
      final closer = nodesOf(r).values.cast<Map>().firstWhere((n) => n['type'] == 'iconButton');
      expect(jsonEncode(closer['actions']), contains('closeModal'));
      // Its form sets a value of the page and closes: the values are the document's.
      expect(kinds(r, 'go'), ['setVariable', 'closeModal']);
      final variables = (r.document['variables']! as Map).cast<String, Object?>();
      expect(variables.keys, ['page_variables']);
      expect([for (final v in variables['page_variables']! as List) (v as Map)['name']], containsAll(['email', 'sort', 'joined', 'onlyOpen', 'tab']));

      // A sheet rises from the bottom, no wider than written.
      expect(open(r, 'filter'), {
        'type': 'openModal', 'to': 'filters', 'presentation': 'bottomSheet', 'sheetWidth': 560, 'sheetRadius': 20, 'showDragHandle': true, 'maxHeightFactor': 0.9, //
      });
      expect(node(r, 'filters')['layout'], {'width': 560, 'height': {'hug': 0}});

      // A menu sits by what opened it; each of its lines closes it after its actions.
      expect(open(r, 'sortBy'), {'type': 'openModal', 'to': 'sortMenu', 'presentation': 'popover', 'anchor': 'trigger', 'placement': 'belowEnd', 'anchorGap': 6});
      expect(node(r, 'sortMenu')['layout'], {'width': 220, 'height': {'hug': 0}});
      expect(kinds(r, 'newest'), ['setVariable', 'closeModal']);
      expect(kinds(r, 'price'), ['setVariable', 'closeModal']);
      expect(kinds(r, 'ask'), ['openModal', 'closeModal']);
      expect((((node(r, 'ask')['actions']! as List).first as Map)['actions']! as List).first, containsPair('presentation', 'dialog'));

      // A popover is one too, and closes only where it says; an overlay opens another.
      expect(open(r, 'what'), containsPair('placement', 'aboveStart'));
      expect(kinds(r, 'ok'), ['closeModal']);
      expect(open(r, 'again'), containsPair('presentation', 'popover'));

      // A drawer: a panel as tall as the window at its side, over the page;
      // a tap beside it closes it, and so does a NavItem (not a chip).
      expect(open(r, 'bag'), {'type': 'openModal', 'to': 'cart', 'presentation': 'dialog', 'cover': true});
      final drawer = node(r, 'cart');
      expect((drawer['layout']! as Map)['height'], {'fill': 800});
      final row = node(r, (drawer['slots']! as Map)['body']! as String);
      expect(row['type'], 'row');
      final sides = (row['children']! as List).cast<String>();
      expect(kinds(r, sides.first), ['closeModal']);
      expect((node(r, sides.last)['layout']! as Map)['width'], 340);
      expect(kinds(r, 'orders'), ['setVariable', 'closeModal']);
      expect(kinds(r, 'gift'), ['setVariable']);

      // No node of an overlay takes the page's media rules.
      expect(node(r, 'tipText').containsKey('media'), isFalse);
    });

    test('as it arrives: each overlay is a root, and what opened it is completed once it is written', () {
      final stream = Catalog.run(standardCatalog, () => NotationStream(catalog: standardCatalog, options: page));
      var doc = LayoutDocument(catalog: standardCatalog);
      for (var i = 0; i < text.length; i += 13) {
        final ops = stream.add(text.substring(i, i + 13 > text.length ? text.length : i + 13));
        if (ops.isEmpty) continue;
        final a = applyOps(doc, {'ops': ops}, catalog: standardCatalog);
        expect(a.errors, isEmpty, reason: '${a.errors}');
        doc = a.document;
      }
      final last = stream.close();
      if (last.isNotEmpty) doc = applyOps(doc, {'ops': last}, catalog: standardCatalog).document;
      expect(stream.issues, isEmpty);
      final whole = parseNotation(text, catalog: standardCatalog, options: page).document;
      final streamed = doc.toJson();
      expect(streamed['roots'], whole['roots']);
      final nodes = (streamed['nodes']! as Map).cast<String, Object?>();
      // (A document read back leaves out what is the default: a dialog's presentation.)
      expect(jsonEncode((nodes['join']! as Map)['actions']), contains('"to":"signup","insets":[16,24,16,24]'));
      expect(jsonEncode((nodes['filter']! as Map)['actions']), contains('"presentation":"bottomSheet"'));
      expect(jsonEncode((nodes['sortBy']! as Map)['actions']), contains('"placement":"belowEnd"'));
      expect((nodes['signup']! as Map)['layout'], {'width': 420, 'height': {'hug': 0}});
      // The values moved from the page's canvas to the document.
      final variables = (streamed['variables']! as Map).cast<String, Object?>();
      expect(variables.keys.where((k) => (variables[k]! as List).isNotEmpty), ['page_variables']);
      expect([for (final v in variables['page_variables']! as List) (v as Map)['name']], containsAll(['email', 'sort', 'joined']));
    });

    test('an overlay needs an id; a second of the same id is said; a card has them too', () {
      // Indented, or with no id, the word is what it was: here, no node type.
      final plain = parseNotation('Column\n  Dialog "Hello"\n', catalog: standardCatalog);
      expect(plain.issues.single.message, contains('No node type "Dialog"'));
      expect(plain.document['roots'], ['screen']);

      final twice = parseNotation('Column#a\n  Text "One"\nMenu#a\n  Text "Two"\nMenu#m\n  Text "Three"\nMenu#m\n  Text "Four"\n', catalog: standardCatalog);
      expect(twice.issues.map((i) => i.message), ['The id "a" is used twice.', 'The id "m" is used twice.']);
      expect(twice.document['roots'], ['screen', 'm']);

      final card = parseNotation('''
Card
  Button#more "More" -> open details
Dialog#details "Details"
  Text "The small print."
''', catalog: standardCatalog);
      expect(card.issues, isEmpty);
      expect(problems(card.document), isEmpty);
      expect(card.document['roots'], ['screen', 'details']);
      expect(open(card, 'more'), containsPair('presentation', 'dialog'));
      // With no overlay written, open names a canvas written elsewhere, as before.
      final other = parseNotation('Button#b "Go" -> open elsewhere\n', catalog: standardCatalog);
      expect(open(other, 'b'), {'type': 'openModal', 'to': 'elsewhere'});
      expect(other.document['roots'], ['screen']);
    });

    test('a design system\'s own Dialog and MenuPopover are the frames; its Dialog called in a line is still its component', () async {
      Map<String, Object?> component(String type, List<Object?> props, {List<Object?> events = const []}) => {
            'schema': 3,
            'id': type,
            'roots': ['r'],
            'widget': {'type': type, 'doc': 'What a $type is for. More.', 'props': props, 'events': events, 'children': 'list'},
            'nodes': {
              'r': {'type': 'column', 'layout': {'width': {'fill': 200}, 'height': {'hug': 28}}, 'children': ['c']},
              'c': {'type': 'slot'},
            },
          };
      const string = {'kind': 'string', 'flutter': 'String'};
      final files = {
        'design_system.json': jsonEncode({
          'id': 'acme',
          'name': 'Acme',
          'theme': {'primary': '#FF2563EB', 'onSurface': '#FF111827'},
          'components': ['components/Dialog.json', 'components/MenuPopover.json'],
        }),
        'components/Dialog.json': jsonEncode(component('Dialog', [
          {'key': 'title', 'type': string, 'default': '', 'required': true},
        ], events: [
          {'key': 'onClose'},
        ])),
        'components/MenuPopover.json': jsonEncode(component('MenuPopover', [
          {'key': 'heading', 'type': string, 'default': ''},
        ])),
      };
      final problems = <String>[];
      final ds = await DesignSystem.load((ref) async => files[ref], problems: problems);
      expect(problems, isEmpty);
      final catalog = ds.catalogOver(standardCatalog);
      final r = Catalog.run(catalog, () => parseNotation('''
Column
  Button#b "Delete" -> open sure
  Button#m "More" -> open more
  Dialog#inline "A frame in the page"
    Text "Body"
Dialog#sure "Delete it?"
  Button "Delete" -> close
Menu#more
  Text "Rename" -> toast "Renamed"
''', catalog: catalog, options: NotationOptions.fromDesignSystem(ds)));
      expect(r.issues, isEmpty);
      expect(r.document['roots'], ['screen', 'sure', 'more']);
      expect(node(r, 'inline')['type'], 'Dialog');
      // The canvas draws nothing: the component is the surface, and its close button closes.
      final frame = node(r, (node(r, 'sure')['slots']! as Map)['body']! as String);
      expect(frame['type'], 'Dialog');
      expect((frame['props']! as Map)['title'], 'Delete it?');
      expect(frame['actions'], [
        {
          'trigger': {'type': 'event', 'event': 'onClose'},
          'actions': [
            {'type': 'closeModal'},
          ],
        },
      ]);
      expect((node(r, 'sure')['decoration']! as Map)['fills'], [
        {'color': '#00FFFFFF'},
      ]);
      expect(node(r, (node(r, 'more')['slots']! as Map)['body']! as String)['type'], 'MenuPopover');
    });

    test('an App\'s sidebar opens as a drawer from its top bar where the window hides it', () {
      const app = '''
state tab="orders"
App
  Sidebar#side
    Brand "Harbor" icon:"anchor"
    NavItem#overview "Overview" icon:"dashboard" selected:=tab=="overview" -> tab="overview"
    NavItem#orders "Orders" selected:=tab=="orders" -> tab="orders"
  Main
    Nav#bar
      Heading#title "Orders" level:1
      Row#tools gap:8
        Button "New order"
    Column pad:24
      Text "Content"
''';
      final r = parseNotation(app, catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      expect(problems(r.document), isEmpty);
      expect(r.document['roots'], ['screen', 'screenMenu']);
      // A menu button first in the bar, on a phone only, opens the drawer.
      final bar = (node(r, 'bar')['children']! as List).cast<String>();
      expect(bar.sublist(1), ['title', 'tools']);
      final button = node(r, bar.first);
      expect(button['type'], 'iconButton');
      expect(button['media'], [
        {'minWidth': 700, 'patch': {'visible': false, 'bind': {'visible': null}}},
      ]);
      expect(open(r, bar.first), {'type': 'openModal', 'to': 'screenMenu', 'presentation': 'dialog', 'cover': true});
      // There the title takes the room beside it, so the two sit together.
      expect((node(r, 'title')['media']! as List).last, {
        'maxWidth': 699,
        'patch': {
          'layout': {'width': {'fill': 0}, 'flex': 1, 'basis': 96},
        },
      });
      // The drawer repeats the sidebar's lines, each closing it after its action.
      final drawer = nodesOf(r).keys.skipWhile((k) => k != 'screenMenu').toList();
      final items = [
        for (final id in drawer)
          if (jsonEncode(node(r, id)['actions'] ?? '').contains('"variable":"tab"')) kinds(r, id),
      ];
      expect(items, [
        ['setVariable', 'closeModal'],
        ['setVariable', 'closeModal'],
      ]);
      // The sidebar itself is as written.
      expect(kinds(r, 'overview'), ['setVariable']);
      expect((node(r, 'side')['layout']! as Map)['width'], 248);

      // Two panes before the main one, over 420 wide: a tablet hides the sidebar too.
      final two = parseNotation(app.replaceFirst('  Main', '  Pane w:320\n    Text "List"\n  Main'), catalog: standardCatalog, options: page);
      final twoBar = (node(two, 'bar')['children']! as List).cast<String>();
      expect((node(two, twoBar.first)['media']! as List).single, containsPair('minWidth', 1024));
      expect(((node(two, 'title')['media']! as List).last as Map)['maxWidth'], 1023);

      // A Main with no top bar gets a slim one for the button, where the sidebar is hidden.
      final bare = parseNotation(app.replaceFirst('    Nav#bar\n      Heading#title "Orders" level:1\n      Row#tools gap:8\n        Button "New order"\n', ''), catalog: standardCatalog, options: page);
      expect(bare.issues, isEmpty);
      expect(bare.document['roots'], ['screen', 'screenMenu']);
      final opener = nodesOf(bare).entries.firstWhere((e) => (e.value! as Map)['type'] == 'iconButton').key;
      final holder = nodesOf(bare).values.cast<Map>().firstWhere((n) => (n['children'] as List? ?? const []).contains(opener));
      expect((holder['media']! as List).last, {
        'minWidth': 700,
        'patch': {'visible': false, 'bind': {'visible': null}},
      });

      // With reflow off, or on a card, the app is as written.
      for (final (source, options) in [
        (app, const NotationOptions(width: 1280, reflow: false)),
        (app, const NotationOptions()),
      ]) {
        final plain = parseNotation(source, catalog: standardCatalog, options: options);
        expect(plain.document['roots'], ['screen']);
        expect(nodesOf(plain).values.where((n) => (n! as Map)['type'] == 'iconButton'), isEmpty);
        expect((plain.document['variables']! as Map).keys, ['screen']);
      }
    });

    test('a Lightbox shows a picture large; menu: opens a Menu on a right click or a long press, at the pointer', () {
      final r = parseNotation('''
state photo="a.png"
Column
  Image#thumb "a.png" w:120 h:80 -> open zoom
  Card#area menu:areaMenu
    Text "Right-click me"
  Row#file onRightClick:{sel="a"; open areaMenu} -> open areaMenu
    Text "a.txt"
Lightbox#zoom "{photo}" "The harbor at dusk"
Menu#areaMenu
  Text#refresh "Refresh" -> toast "Done"
''', catalog: standardCatalog, options: page);
      expect(r.issues, isEmpty);
      expect(problems(r.document), isEmpty);
      expect(open(r, 'thumb'), {'type': 'openModal', 'to': 'zoom', 'presentation': 'dialog', 'cover': true, 'barrierColor': '#E6000000'});
      final box = node(r, (node(r, 'zoom')['slots']! as Map)['body']! as String);
      expect(jsonEncode(box['actions']), contains('closeModal'));
      expect(jsonEncode(nodesOf(r)), contains(r'"url":"${photo}","fit":"contain"'));
      const menu = {'type': 'openModal', 'to': 'areaMenu', 'presentation': 'popover', 'anchor': 'pointer', 'placement': 'belowStart', 'anchorGap': 6};
      expect(node(r, 'area')['actions'], [
        {'trigger': {'type': 'secondaryClick'}, 'actions': [menu]},
        {'trigger': {'type': 'longPress'}, 'actions': [menu]},
      ]);
      // A handler written out does the same after its own actions; a tap opens it by the row.
      final file = (node(r, 'file')['actions']! as List).cast<Map>();
      expect(file.firstWhere((a) => (a['trigger'] as Map)['type'] == 'secondaryClick')['actions'], [
        {'type': 'setVariable', 'variable': 'sel', 'value': 'a'},
        menu,
      ]);
      expect(file.firstWhere((a) => (a['trigger'] as Map)['type'] == 'click')['actions'], [
        {...menu, 'anchor': 'trigger'},
      ]);
      expect(kinds(r, 'refresh'), ['showToast', 'closeModal']);
    });

    test('the prompt teaches them from a desktop width on', () {
      final wide = notationPrompt(catalog: standardCatalog, options: page);
      for (final word in ['Dialog#signup', 'Sheet#', 'Drawer#', 'Menu#', 'Popover#', 'Lightbox#', 'menu:rowMenu', '-> open signup']) {
        expect(wide, contains(word), reason: word);
      }
      final card = notationPrompt(catalog: standardCatalog);
      expect(card, isNot(contains('Dialog#')));
      expect(card, isNot(contains('OVER THE PAGE')));
    });
  });
}
