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
        'components': ['components/StatusPill.json', 'components/Counter.json', 'components/Frame.json', 'components/Button.json', 'components/Note.json', 'components/Pill.json'],
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
    };
    files['components/Pill.json'] = jsonEncode(component('Pill', [
      {'key': 'label', 'type': string, 'default': '', 'required': true},
      {'key': 'note', 'type': string, 'default': ''},
      {'key': 'price', 'type': string, 'default': ''},
      {'key': 'tone', 'type': {'kind': 'enumeration', 'flutter': 'String', 'values': ['primary', 'quiet', 'danger']}, 'default': 'primary'},
      {'key': 'qty', 'type': number, 'default': 1},
    ]));
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
}
