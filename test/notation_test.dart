// The compact notation (docs/design/13-compact-notation.md): what an agent
// writes for levels 0 to 2 expands to an ordinary document that validates.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/src/core/levels.dart';
import 'package:codelessly_api/notation.dart';
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
    // Text with no variant is the body text: it has a colour.
    expect(((_node(r, 'text2')['props'] as Map)['style'] as Map)['color'], '#FF374151');
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
    expect(prompt.length, lessThan(6000), reason: 'about 1,500 tokens');
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
}
