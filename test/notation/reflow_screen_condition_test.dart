// A pane under a condition that reads the screen (`if screen.width>700 ||
// !showNote`) is the writer's to show at other widths: reflow does not hide
// it on a phone over that. A list beside its note, each under such a
// condition, was hidden on a phone by the rule for a pane of a fixed width
// while the note was hidden by its own condition: nothing under the bar.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

import '../notation_words.dart';

const _notes = '''
state showNote=false
state listW=340
state notes=[{"id":"a","title":"First"}]
App
  Sidebar
    NavItem "Notes" icon="notes"
  Main
    Row grow top
      CONDITION
        Column#list w={listW} border-right=#FFE2D6BD
          each n in notes
            Text "{n.title}" onTap={showNote=true}
      if screen.width>700 || showNote
        Column#note grow pad=16
          Text "Body"
''';

Map<String, Object?> _node(String page, String id) {
  final r = parseNotation(page, catalog: standardCatalog, options: withTestWords(const NotationOptions(width: 1440)));
  expect(r.issues, isEmpty, reason: '${r.issues}');
  return ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();
}

void main() {
  test('under a condition that reads the screen, the pane gets no rule that hides it', () {
    final list = _node(_notes.replaceFirst('CONDITION', 'if screen.width>700 || !showNote'), 'list');
    expect((list['bind'] as Map)['visible'], contains('screen.width'));
    expect(jsonEncode(list['media'] ?? []), isNot(contains('"visible":false')));
  });

  test('under a condition of the state alone it is hidden on a phone as before', () {
    final list = _node(_notes.replaceFirst('CONDITION', 'if !showNote'), 'list');
    expect(jsonEncode(list['media']), contains('{"maxWidth":699,"patch":{"visible":false,"bind":{"visible":null}}}'));
  });
}
