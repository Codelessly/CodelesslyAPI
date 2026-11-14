// The compact notation (docs/design/13-compact-notation.md): what an agent
// writes for levels 0 to 2 expands to an ordinary document that validates.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/src/core/levels.dart';
import 'package:codelessly_api/src/core/notation/notation.dart';
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
    expect((column['props'] as Map)['spacing'], 12);
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
        {'type': 'emitEvent', 'event': 'save'},
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
    expect((_node(r, 'filledButton1')['actions'] as List).single['actions'], [
      {'type': 'setVariable', 'variable': 'decision', 'value': 'approved'},
      {'type': 'emitEvent', 'event': 'approved'},
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
}
