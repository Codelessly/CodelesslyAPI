// The open vocabulary (docs/design/19-open-vocabulary.md): a word the
// notation does not have is recorded and stands in, a name for a word it
// has is read as that word, and with the vocabulary closed nothing changes.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/prompt.dart' show notationDefinePreface, notationOpenPreface, notationPrompt;
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

const _page = NotationOptions(width: 1280);
final _openPage = _page.open();

NotationResult _open(String text, {NotationOptions? options}) => parseNotation(text, catalog: standardCatalog, options: options ?? _openPage);
NotationResult _closed(String text, {NotationOptions options = _page}) => parseNotation(text, catalog: standardCatalog, options: options);

List<String> _problems(Map<String, Object?> doc) => [
      for (final d in Catalog.run(standardCatalog, () => validateDocument(doc)))
        if (d.severity == Severity.error) '${d.code.name} ${d.path}: ${d.message}',
    ];

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

List<VocabularyUse> _uses(NotationResult r, String kind) => [for (final u in r.vocabulary) if (u.kind == kind) u];

/// [alias] and [ours] expand to the same document, with nothing said, with
/// the vocabulary closed and open; the alias is recorded, ours is not.
void _same(String alias, String ours, {required String word, String? to}) {
  for (final options in [_page, _openPage, const NotationOptions(), const NotationOptions().open()]) {
    final a = parseNotation(alias, catalog: standardCatalog, options: options), b = parseNotation(ours, catalog: standardCatalog, options: options);
    final where = 'width ${options.width}, ${options.openVocabulary ? 'open' : 'closed'}';
    expect(a.issues.map((i) => '$i'), isEmpty, reason: '$alias ($where)');
    expect(b.issues.map((i) => '$i'), isEmpty, reason: '$ours ($where)');
    expect(jsonEncode(a.document), jsonEncode(b.document), reason: '$alias is not $ours ($where)');
    expect(_problems(a.document), isEmpty, reason: '$alias ($where)');
    final used = _uses(a, 'alias').where((u) => u.word == word).toList();
    expect(used, isNotEmpty, reason: '$alias: no alias use of $word recorded ($where)');
    if (to != null) expect(used.first.to, to, reason: alias);
    expect(b.vocabulary, isEmpty, reason: '$ours records ${b.vocabulary} ($where)');
  }
}

void main() {
  group('an unknown word is recorded, each kind with where it is and what it was given', () {
    const text = '''
state q=""
App
  Main
    Column gap=8
      SeatMap#plan "Hall A" rows={seats} selectable multi bind=chosen onTap={q="x"} onChange={q="y"; haptic}
        Text "Stage"
        if q!=""
          Legend "Chosen"
      Button "Go" tooltip2="x" wobble onFling={vibrate plan; q="z"} onTap={share q; toast "ok"}
      Button.danger "Delete"
''';
    late NotationResult r;
    setUp(() => r = _open(text));

    test('nothing is an issue, and the document validates', () {
      expect(r.issues.map((i) => '$i'), isEmpty);
      expect(_problems(r.document), isEmpty);
    });

    test('a type: the word, its line and column, the words it is under, its strings, parameters, flags, events and the lines under it', () {
      final seat = _uses(r, 'type').firstWhere((u) => u.word == 'SeatMap');
      expect(seat.line, 5);
      expect(seat.column, 7);
      expect(seat.path, ['App', 'Main', 'Column']);
      expect(seat.node, 'plan');
      expect(seat.source, startsWith('SeatMap#plan "Hall A" rows={seats}'));
      expect(seat.texts, ['Hall A']);
      expect(seat.parameters, {'rows': '{seats}', 'bind': 'chosen'});
      expect(seat.flags, ['selectable', 'multi']);
      expect(seat.events.keys, ['onTap', 'onChange']);
      expect(seat.events['onChange'], '{q="y"; haptic}');
      // The lines directly under it, through an `if`.
      expect(seat.children, ['Text', 'Legend']);
      final legend = _uses(r, 'type').firstWhere((u) => u.word == 'Legend');
      expect(legend.path, ['App', 'Main', 'Column', 'SeatMap']);
      expect(legend.texts, ['Chosen']);
      expect(seat.toJson(), containsPair('kind', 'type'));
      expect(seat.toJson()['children'], ['Text', 'Legend']);
    });

    test('a parameter, a flag and an event on a word we have: left out of the document, recorded with the type and the value', () {
      final p = _uses(r, 'parameter').single;
      expect((p.word, p.on, p.value, p.line), ('tooltip2', 'Button', '"x"', 9));
      final f = _uses(r, 'flag').single;
      expect((f.word, f.on, f.line), ('wobble', 'Button', 9));
      final e = _uses(r, 'event').single;
      expect((e.word, e.on, e.value), ('onFling', 'Button', '{vibrate plan; q="z"}'));
      expect(e.path, ['App', 'Main', 'Column']);
      final button = _node(r, 'filledButton1');
      expect(button['props'], {'label': 'Go'});
      // The event we have is kept, without the verb we do not have.
      expect(button['actions'], [
        {
          'trigger': {'type': 'click'},
          'actions': [
            {'type': 'showToast', 'message': 'ok'},
          ],
        },
      ]);
    });

    test('an action verb: recorded with its argument and the type whose event it is in', () {
      final verbs = _uses(r, 'verb');
      expect([for (final v in verbs) (v.word, v.on, v.value)], [('haptic', 'SeatMap', ''), ('vibrate', 'Button', 'plan'), ('share', 'Button', 'q')]);
    });

    test('a variant: recorded, and the plain type is drawn', () {
      final v = _uses(r, 'variant').single;
      expect((v.word, v.on, v.line), ('Button.danger', 'Button', 10));
      expect(_node(r, 'filledButton2')['props'], {'label': 'Delete'});
    });

    test('the same text with the vocabulary closed: each is an error, and nothing is recorded', () {
      final c = _closed(text);
      expect(c.vocabulary, isEmpty);
      final said = c.issues.map((i) => i.message).join('\n');
      expect(said, contains('No node type "SeatMap"'));
      expect(said, contains('Unknown word "wobble" on a Button'));
      expect(said, contains('A Button has no event "onFling"'));
      expect(said, contains('Unknown action "share"'));
      expect(said, contains('No Button.danger'));
    });
  });

  group('the stand-in', () {
    test('is a column of its texts and of the lines under it, with its id, its sizes and what it does when tapped', () {
      final r = _open('''
state n=0
Column gap=12
  Waveform#wave "Intro" "0:42" samples={peaks} w=320 h=80 pad=8 gap=4 fill=#FFEEF2FF radius=8 onTap={n=n+1} onSeek={n=result} visible={n<3}
    Text "under it"
  Text "after {n}"
''');
      expect(r.issues.map((i) => '$i'), isEmpty);
      expect(_problems(r.document), isEmpty);
      final wave = _node(r, 'wave');
      expect(wave['type'], 'column');
      expect((wave['layout'] as Map)['width'], 320);
      // Its height is the least it is: it grows with what is written in it.
      expect((wave['layout'] as Map)['height'], {'hug': 0});
      expect((wave['layout'] as Map)['constraints'], {'minHeight': 80});
      expect((wave['layout'] as Map)['padding'], 8);
      expect((wave['props'] as Map)['spacing'], 4);
      expect((wave['decoration'] as Map)['radius'], 8);
      expect((wave['bind'] as Map)['visible'], r'${= n<3}');
      // Its own parameter and its own event are not in the document.
      expect((wave['props'] as Map).containsKey('samples'), isFalse);
      expect((wave['actions'] as List).map((a) => ((a as Map)['trigger'] as Map)['type']), ['click']);
      final children = [for (final id in wave['children'] as List) _node(r, id as String)];
      expect([for (final c in children) (c['props'] as Map)['text']], ['Intro', '0:42', 'under it']);
      // What comes after it is where it was written.
      expect(_node(r, 'column1')['children'], ['wave', 'text4']);
    });

    test('what it would keep a value in is still a variable of the page', () {
      final r = _open('Column\n  ColorPicker bind=tint\n  Text "{tint}"\n');
      expect(r.issues, isEmpty);
      expect(_problems(r.document), isEmpty);
      expect(jsonEncode(r.document['variables']), contains('"name":"tint"'));
    });

    test('at the margin after the page, with an id, it is over the page: a dialog an open shows', () {
      final r = _open('''
Page
  Section
    Button "Ask" onTap={open palette}
CommandPalette#palette "Commands" placeholder="Type a command"
  Text "Rename"
''');
      expect(r.issues.map((i) => '$i'), isEmpty);
      expect(_problems(r.document), isEmpty);
      expect(r.document['roots'], ['screen', 'palette']);
      final use = _uses(r, 'type').single;
      expect((use.word, use.node), ('CommandPalette', 'palette'));
      expect(use.texts, ['Commands']);
      expect(use.parameters, {'placeholder': '"Type a command"'});
      expect(use.children, ['Text']);
      expect(jsonEncode(r.document), contains('"type":"openModal","to":"palette","presentation":"dialog"'));
    });

    test('a sentence around the UI is still not a word', () {
      final r = _open('Here is the card you asked for:\nColumn\n  Text "Hi"\nLet me know if it works.\n');
      expect(r.vocabulary, isEmpty);
      expect(r.issues, isEmpty);
    });

    test('lines under a word we have that takes none are drawn after it, and recorded', () {
      final r = _open('Column\n  Slider bind=v\n    Text "under a slider"\n  Text "last"\n');
      expect(r.issues, isEmpty);
      expect(_problems(r.document), isEmpty);
      expect(_node(r, 'column1')['children'], ['slider1', 'text1', 'text2']);
      final use = _uses(r, 'children').single;
      expect((use.word, use.value), ('Slider', 'Text'));
    });

    test('a value of another kind than a parameter takes is left out and recorded', () {
      final r = _open('Column\n  Text "Saved" live=polite\n');
      expect(r.issues, isEmpty);
      expect(_problems(r.document), isEmpty);
      final use = _uses(r, 'parameter').single;
      expect((use.word, use.on, use.value), ('live', 'Text', 'polite'));
    });

    test('an open of nothing over the page, and a scroll to no line of it, are left out and said on their line', () {
      final r = _open('Page\n  Section\n    Button "A" onTap={open nothing; toast "x"}\n    Button "B" onTap={scroll nowhere}\n');
      expect(_problems(r.document), isEmpty);
      expect(r.issues.map((i) => '$i'), [
        startsWith('line 3:1: Nothing over this page has the id "nothing" for an open to show'),
        startsWith('line 4:1: No line of this page has the id "nowhere" for a scroll to go to'),
      ]);
      expect((_node(r, 'filledButton1')['actions'] as List).single, {
        'trigger': {'type': 'click'},
        'actions': [
          {'type': 'showToast', 'message': 'x'},
        ],
      });
    });
  });

  test('the grammar is not open: what does not follow it is still an error', () {
    for (final (line, said) in [
      ('Text "Total" color:red', 'A value is written with =, not a colon'),
      ('Button "Save" -> saved', 'There is no arrow'),
      ('Button "Save" onTap="saved"', "An event's actions are written in braces"),
      ('Text row.name', 'A value shown as text is written in a string'),
      ('seatMap rows={seats}', 'No node type "seatMap"'),
    ]) {
      final r = _open('state row={"name":"a"}\nColumn\n  $line\n');
      expect(r.issues.map((i) => i.message).join('\n'), contains(said), reason: line);
    }
  });

  group('aliases: a name for a word we have is read as that word, open or closed', () {
    test('Shortcut is the key line (ctrl is mod already); a condition is its when', () {
      _same('Shortcut "ctrl+k" onPress={open find}\nPage\n  Section\n    Text "x"\nDialog#find "Find"\n  Text "y"\n',
          'key ctrl+k onPress={open find}\nPage\n  Section\n    Text "x"\nDialog#find "Find"\n  Text "y"\n',
          word: 'Shortcut', to: 'key ctrl+k onPress={open find}');
      final r = _closed('Shortcut "ctrl+k" onPress={n=1}\nColumn\n  Text "x"\n');
      expect((_node(r, 'screen')['actions'] as List).single, {
        'trigger': {'type': 'keyDown', 'key': 'ctrl+k'},
        'actions': [
          {'type': 'setVariable', 'variable': 'n', 'value': r'${= 1}'},
        ],
      });
      _same('state n=0\nShortcut key="?" onPress={n=1}\nColumn\n  Text "x"\n', 'state n=0\nkey ? onPress={n=1}\nColumn\n  Text "x"\n', word: 'Shortcut');
      _same('state n=0\nShortcut keys="Space" description="Play" hint="Space" onPress={n=1}\nColumn\n  Text "x"\n', 'state n=0\nkey Space onPress={n=1}\nColumn\n  Text "x"\n', word: 'Shortcut');
      _same('state n=0\nshortcut key=ArrowRight onPress={n=n+1}\nColumn\n  Text "x"\n', 'state n=0\nkey ArrowRight onPress={n=n+1}\nColumn\n  Text "x"\n', word: 'shortcut');
      _same('state n=0\nshortcut space onPress={n=n+1}\nColumn\n  Text "x"\n', 'state n=0\nkey space onPress={n=n+1}\nColumn\n  Text "x"\n', word: 'shortcut');
      _same('state n=0\nShortcut "r" when n>0 onPress={n=0}\nColumn\n  Text "x"\n', 'state n=0\nkey r when n>0 onPress={n=0}\nColumn\n  Text "x"\n', word: 'Shortcut');
      _same('state n=0\nShortcut keys="r" when={n>0} onPress={n=0}\nColumn\n  Text "x"\n', 'state n=0\nkey r when n>0 onPress={n=0}\nColumn\n  Text "x"\n', word: 'Shortcut');
    });

    test('key … when …: a shortcut that runs only while a condition holds', () {
      final r = _closed('state n=0\nkey escape when n>0 onPress={n=0}\nColumn\n  Text "x"\n');
      expect(r.issues, isEmpty);
      expect(((_node(r, 'screen')['actions'] as List).single as Map)['trigger'], {'type': 'keyDown', 'key': 'escape', 'when': r'${= n>0}'});
    });

    test('computed is a state written as its formula', () {
      _same('state a=1\nstate b=2\ncomputed total={a+b}\nColumn\n  Text "{total}"\n', 'state a=1\nstate b=2\nstate total=a+b\nColumn\n  Text "{total}"\n', word: 'computed');
    });

    test('ConfirmDialog is a Dialog with its two buttons, at the margin or written inside the page', () {
      const ours = '''
state n=0
Page
  Section
    Button "Reset" onTap={open ask}
Dialog#ask "Reset the count?" "This cannot be undone."
  Row gap=8 end
    Button.ghost "Cancel" onTap={close}
    Button "Confirm" onTap={n=0; close}
''';
      _same('''
state n=0
Page
  Section
    Button "Reset" onTap={open ask}
ConfirmDialog#ask "Reset the count?" "This cannot be undone." onConfirm={n=0}
''', ours, word: 'ConfirmDialog');
      _same('''
state n=0
Page
  Section
    Button "Reset" onTap={open ask}
  ConfirmDialog#ask "Reset the count?" "This cannot be undone." onConfirm={n=0}
''', ours, word: 'ConfirmDialog');
      // Its own labels, and a yes that deletes.
      _same('''
state n=0
Page
  Section
    Button "Reset" onTap={open ask}
ConfirmDialog#ask title="Reset?" message="Really." confirm="Reset" cancel="Keep" destructive onConfirm={n=0} onCancel={n=1}
''', '''
state n=0
Page
  Section
    Button "Reset" onTap={open ask}
Dialog#ask "Reset?" "Really."
  Row gap=8 end
    Button.ghost "Keep" onTap={n=1; close}
    Button.destructive "Reset" onTap={n=0; close}
''', word: 'ConfirmDialog');
    });

    test('RangeSlider is a Slider when it names a variable for each end; bound to one list it is not ours', () {
      const ours = 'Column\n  Slider bind=low bindEnd=high min=0 max=100\n';
      _same('Column\n  RangeSlider bind=low bindEnd=high min=0 max=100\n', ours, word: 'RangeSlider', to: 'Slider');
      _same('Column\n  RangeSlider low=low high=high min=0 max=100\n', ours, word: 'RangeSlider');
      _same('Column\n  RangeSlider lo=low hi=high min=0 max=100\n', ours, word: 'lo', to: 'bind');
      _same('Column\n  RangeSlider bindStart=low bindEnd=high min=0 max=100\n', ours, word: 'bindStart');
      _same('Column\n  RangeSlider start=low end=high min=0 max=100\n', ours, word: 'end', to: 'bindEnd');
      _same('Column\n  RangeSlider bindLow=low bindHigh=high min=0 max=100\n', ours, word: 'bindHigh');
      final one = _open('state range=[0,10]\nColumn\n  RangeSlider bind=range min=0 max=100\n');
      expect(_uses(one, 'alias'), isEmpty);
      expect(_uses(one, 'type').single.word, 'RangeSlider');
      expect(_closed('Column\n  RangeSlider bind=range\n').issues.single.message, contains('No node type "RangeSlider"'));
    });

    test('Highlight and HighlightText are a Text with what matched marked', () {
      const ours = 'state q="a"\nColumn\n  Text "Ada Lovelace" mark={q} weight=600\n';
      _same('state q="a"\nColumn\n  Highlight "Ada Lovelace" match={q} weight=600\n', ours, word: 'Highlight', to: 'Text');
      _same('state q="a"\nColumn\n  HighlightText "Ada Lovelace" query={q} weight=600\n', ours, word: 'HighlightText', to: 'Text');
      _same('state q="a"\nColumn\n  Highlight "Ada Lovelace" query={q} weight=600\n', ours, word: 'query', to: 'mark');
      _same('state q="a"\nColumn\n  HighlightText "Ada Lovelace" match={q} weight=600\n', ours, word: 'match', to: 'mark');
    });

    test('MiniCalendar, CalendarMonth and MonthGrid are a Calendar', () {
      for (final name in ['MiniCalendar', 'CalendarMonth', 'MonthGrid']) {
        _same('Column\n  $name bind=day\n', 'Column\n  Calendar bind=day\n', word: name, to: 'Calendar');
      }
    });

    test('StickyBar, StickyFooter, BottomBar, FooterBar and BottomDock are the Footer of an app\'s Main', () {
      const page = 'App\n  Main\n    Column pad=24\n      Text "Albums"\n    {foot}\n      Text.strong "Night Drive"\n';
      final ours = page.replaceFirst('{foot}', 'Footer');
      for (final name in ['StickyBar', 'StickyFooter', 'BottomBar', 'FooterBar', 'BottomDock']) {
        _same(page.replaceFirst('{foot}', name), ours, word: name, to: 'Footer');
      }
    });

    test('disabled is enabled, the other way round', () {
      _same('state n=0\nColumn\n  Button "Send" disabled={n==0} onTap={n=1}\n', 'state n=0\nColumn\n  Button "Send" enabled={!(n==0)} onTap={n=1}\n', word: 'disabled', to: '!enabled');
      _same('Column\n  IconButton "send" disabled=true\n', 'Column\n  IconButton "send" enabled=false\n', word: 'disabled');
      _same('Column\n  Button "Send" disabled\n', 'Column\n  Button "Send" enabled=false\n', word: 'disabled', to: 'enabled=false');
      _same('Column\n  Input "Name" bind=name disabled\n', 'Column\n  Input "Name" bind=name enabled=false\n', word: 'disabled');
      final r = _closed('state n=0\nColumn\n  Button "Send" disabled={n==0}\n');
      expect(_node(r, 'filledButton1')['bind'], {'props.enabled': r'${= !(n==0)}'});
    });

    test('a ListTile\'s subtitle (and title) are its strings', () {
      _same('Column\n  ListTile "Ada" subtitle="Engineer"\n', 'Column\n  ListTile "Ada" "Engineer"\n', word: 'subtitle', to: r'$text');
      _same('Column\n  ListTile title="Ada" subtitle="Engineer"\n', 'Column\n  ListTile "Ada" "Engineer"\n', word: 'title');
      _same('state r={"role":"Engineer"}\nColumn\n  ListTile "Ada" subtitle={r.role}\n', 'state r={"role":"Engineer"}\nColumn\n  ListTile "Ada" "{r.role}"\n', word: 'subtitle');
    });

    test('persist after a state is saved (it was read into the value)', () {
      _same('state draft="" persist\nColumn\n  Input "Note" bind=draft\n', 'state draft="" saved\nColumn\n  Input "Note" bind=draft\n', word: 'persist', to: 'saved');
      _same('state n=20 persisted\nColumn\n  Text "{n}"\n', 'state n=20 saved\nColumn\n  Text "{n}"\n', word: 'persisted');
      _same('state n=20 persistent\nColumn\n  Text "{n}"\n', 'state n=20 saved\nColumn\n  Text "{n}"\n', word: 'persistent');
      _same('project cart=[] persist\nColumn\n  Text "{length(cart)}"\n', 'project cart=[] saved\nColumn\n  Text "{length(cart)}"\n', word: 'persist');
      final r = _closed('state n=20 persist\nColumn\n  Text "{n}"\n');
      expect(((r.document['variables'] as Map)['screen'] as List).single, {'name': 'n', 'type': 'integer', 'value': 20, 'persist': true});
    });

    test('every alias of the built-in table is one of the above', () {
      const tested = {
        'Shortcut', 'shortcut', 'computed', 'ConfirmDialog', 'RangeSlider', 'Highlight', 'HighlightText', 'MiniCalendar', 'CalendarMonth', 'MonthGrid', //
        'StickyBar', 'StickyFooter', 'BottomBar', 'FooterBar', 'BottomDock',
      };
      expect(NotationVocabulary.core.types.keys.toSet(), tested);
      expect(NotationVocabulary.core.types['RangeSlider']!.parameters.keys.toSet(), {'low', 'lo', 'bindLow', 'bindStart', 'start', 'high', 'hi', 'bindHigh', 'end'});
      expect(NotationVocabulary.core.parameters, {
        '*': {'disabled': '!enabled'},
        'ListTile': {'subtitle': r'$text', 'title': r'$text'},
      });
      expect(NotationVocabulary.core.flags.keys.toSet(), {'*', 'state', 'project'});
      expect(NotationVocabulary.core.flags['*'], {'disabled': 'enabled=false'});
      expect(NotationVocabulary.core.flags['state'], {'persist': 'saved', 'persisted': 'saved', 'persistent': 'saved'});
      expect(NotationVocabulary.core.events, isEmpty);
      expect(NotationVocabulary.core.verbs, isEmpty);
    });

    test('a word the notation already has is never an alias', () {
      // FilterChip, Calendar and Slider are words of the catalog: a table that
      // names them changes nothing.
      final table = NotationVocabulary.fromJson({
        'types': {'Slider': 'Progress', 'Card': 'Column'},
        'parameters': {'Slider': {'min': 'max'}},
      });
      const text = 'Card\n  Slider bind=v min=2 max=9\n';
      final a = _closed(text, options: _page.open(openVocabulary: false, vocabulary: table)), b = _closed(text);
      expect(jsonEncode(a.document), jsonEncode(b.document));
      expect(a.vocabulary, isEmpty);
    });

    test('a table of one\'s own: types with their parameters and added words, parameters, flags, events and verbs; a later table wins', () {
      final table = NotationVocabulary.core.merge(NotationVocabulary.fromJson({
        'types': {
          'TextArea': {'to': 'Input', 'add': 'multiline', 'parameters': {'placeholder': 'hint'}},
          'Tag': 'Chip',
        },
        'parameters': {
          'Text': {'tint': 'color'},
          '*': {'invisible': '!visible'},
        },
        'flags': {
          'Text': {'crossed': 'strike'},
        },
        'events': {
          '*': {'onActivate': 'onTap'},
        },
        'verbs': {'navigate': 'go', 'notify': 'toast'},
      }));
      final options = _page.open(openVocabulary: false, vocabulary: table);
      NotationResult parse(String t) => parseNotation(t, catalog: standardCatalog, options: options);
      void same(String alias, String ours) {
        final a = parse(alias), b = parse(ours);
        expect(a.issues.map((i) => '$i'), isEmpty, reason: alias);
        expect(jsonEncode(a.document), jsonEncode(b.document), reason: alias);
        expect(_uses(a, 'alias'), isNotEmpty, reason: alias);
      }

      same('Column\n  TextArea "Notes" bind=notes placeholder="Anything"\n', 'Column\n  Input "Notes" bind=notes hint="Anything" multiline\n');
      same('Column\n  Tag "New"\n', 'Column\n  Chip "New"\n');
      same('Column\n  Text "Hi" tint=#FF112233 crossed\n', 'Column\n  Text "Hi" color=#FF112233 strike\n');
      same('state n=0\nColumn\n  Text "Hi" invisible={n>0}\n', 'state n=0\nColumn\n  Text "Hi" visible={!(n>0)}\n');
      same('state n=0\nColumn\n  Box onActivate={n=1}\n', 'state n=0\nColumn\n  Box onTap={n=1}\n');
      same('Column\n  Button "Go" onTap={navigate pricing; notify "On our way"}\n', 'Column\n  Button "Go" onTap={go pricing; toast "On our way"}\n');
      final verb = _uses(parse('Column\n  Button "Go" onTap={navigate pricing}\n'), 'alias').single;
      expect((verb.of, verb.word, verb.to, verb.on, verb.value), ('verb', 'navigate', 'go', 'Button', 'pricing'));
      // The built-in table still holds under it, and the table reads back.
      same('Column\n  Button "Go" disabled\n', 'Column\n  Button "Go" enabled=false\n');
      final again = NotationVocabulary.fromJson((jsonDecode(jsonEncode(table.toJson())) as Map).cast<String, Object?>());
      expect(jsonEncode(again.toJson()), jsonEncode(table.toJson()));
      expect(again.types['RangeSlider']!.requires, ['bind', 'bindEnd']);
      expect(again.types['Shortcut']!.line, 'shortcut');
      // With no table at all nothing is an alias.
      final none = _closed('Column\n  Button "Go" disabled\n', options: _page.open(openVocabulary: false, vocabulary: NotationVocabulary.none));
      expect(none.vocabulary, isEmpty);
      expect(none.issues.single.message, contains('Unknown word "disabled"'));
    });
  });

  group('what the corpus showed the grammar should read (docs/design/19, section 8)', () {
    test('Progress {done/total}: a share worked out, where its number goes', () {
      for (final options in [_page, _openPage]) {
        final r = parseNotation('state done=1\nColumn\n  Progress {done/4} grow\n  Ring {done/4}\n', catalog: standardCatalog, options: options);
        expect(r.issues.map((i) => '$i'), isEmpty);
        expect((_node(r, 'progressBar1')['bind'] as Map)['props.value'], r'${= done/4}');
        expect((_node(r, 'progressBar1')['layout'] as Map)['flex'], 1);
        expect(jsonEncode(r.document), jsonEncode(parseNotation('state done=1\nColumn\n  Progress bind={done/4} grow\n  Ring bind={done/4}\n', catalog: standardCatalog, options: options).document));
      }
      // A JSON tail is still a JSON tail.
      final tail = _closed('Column\n  Progress 0.5 {"opacity": 0.5}\n');
      expect(tail.issues, isEmpty);
      expect(_node(tail, 'progressBar1')['opacity'], 0.5);
      expect((_node(tail, 'progressBar1')['props'] as Map)['value'], 0.5);
    });

    test('Input type=email: the keyboard by the name the prompt teaches', () {
      for (final (written, keyboard) in [('email', 'emailAddress'), ('phone', 'phone'), ('tel', 'phone'), ('number', 'number'), ('url', 'url')]) {
        final r = _closed('Column\n  Input "Field" type=$written\n');
        expect(r.issues, isEmpty);
        expect(_problems(r.document), isEmpty, reason: written);
        expect((_node(r, 'textField1')['props'] as Map)['keyboardType'], keyboard);
      }
    });

    test('an overlay written inside the page is still over the page, and the page goes on after it', () {
      final r = _closed('''
Page
  Section
    Button "Edit" onTap={open edit}
  Dialog#edit "Edit"
    Input "Name" bind=name
  Section
    Text "After the dialog"
''');
      expect(r.issues.map((i) => '$i'), isEmpty);
      expect(_problems(r.document), isEmpty);
      expect(r.document['roots'], ['screen', 'edit']);
      // The page has its two sections, the second after the dialog's lines;
      // the dialog has its field; the button opens it as a dialog.
      final page = _node(r, _node(r, 'screen')['slots'] is Map ? ((_node(r, 'screen')['slots'] as Map)['body'] as String) : '');
      expect(page['children'], hasLength(2));
      final text = jsonEncode(r.document);
      expect(text, contains('"type":"openModal","to":"edit","presentation":"dialog"'));
      expect(text, contains('After the dialog'));
      final nodes = r.document['nodes'] as Map;
      bool under(String id, String root) {
        final n = nodes[root] as Map;
        final kids = [...?(n['children'] as List?), ...?(n['slots'] as Map?)?.values];
        return kids.contains(id) || kids.any((k) => under(id, k as String));
      }

      expect(under('textField1', 'edit'), isTrue);
      expect(under('textField1', 'screen'), isFalse);
    });

    test('state name={formula}: a formula in braces is that formula', () {
      final a = _closed('state rows=[1,2,3]\nstate big={filter(rows,r=>r>1)}\nColumn\n  Text "{length(big)}"\n');
      final b = _closed('state rows=[1,2,3]\nstate big=filter(rows,r=>r>1)\nColumn\n  Text "{length(big)}"\n');
      expect(a.issues, isEmpty);
      expect(jsonEncode(a.document), jsonEncode(b.document));
      expect(jsonEncode(a.document), isNot(contains('{filter')));
      // A map is still a map.
      final map = _closed('state row={"name":"Ada"}\nColumn\n  Text "{row.name}"\n');
      expect(((map.document['variables'] as Map)['screen'] as List).single, {'name': 'row', 'type': 'map', 'value': {'name': 'Ada'}});
    });

    test('a color in a formula is written as after a key', () {
      final a = _closed('state late=true\nColumn\n  Box fill={late ? #FFFECACA : #FFFFFFFF}\n  Text "x" color={late?#B42318:"#111827"}\n');
      final b = _closed('state late=true\nColumn\n  Box fill={late ? "#FFFECACA" : "#FFFFFFFF"}\n  Text "x" color={late?"#B42318":"#111827"}\n');
      expect(a.issues, isEmpty);
      expect(jsonEncode(a.document), jsonEncode(b.document));
      expect(jsonEncode(a.document), contains(r'late ? \"#FFFECACA\" : \"#FFFFFFFF\"'));
      // In a text it is the text.
      final text = _closed('Column\n  Text "{"Issue #123456"}"\n');
      expect(jsonEncode(text.document), contains('Issue #123456'));
      expect(jsonEncode(text.document), isNot(contains(r'\"#123456\"')));
    });

    test('grow=true is grow', () {
      final r = _closed('Row\n  Text "a" grow=true\n  Text "b" grow=false\n');
      expect(_problems(r.document), isEmpty);
      expect((_node(r, 'text1')['layout'] as Map)['flex'], 1);
      expect((_node(r, 'text2')['layout'] as Map).containsKey('flex'), isFalse);
    });
  });

  group('the open prompt', () {
    String taught(double width) => notationPrompt(catalog: standardCatalog, options: NotationOptions(width: width));
    String open(double width) => notationPrompt(catalog: standardCatalog, options: NotationOptions(width: width), open: true);
    String plain(double width) => notationPrompt(catalog: standardCatalog, options: NotationOptions(width: width), open: true, define: false);

    test('says the vocabulary is open and the grammar is not, and teaches the grammar and the core only', () {
      final page = open(1280);
      expect(page, startsWith(notationOpenPreface));
      expect(page, contains('The vocabulary is open.'));
      expect(page, contains('The grammar is not open: every line follows it exactly.'));
      // The grammar and the core are as the taught prompt has them.
      for (final kept in ['LINE\n  Type[.variant][#id] ["text"] [key=value ...]', '- bind=name keeps', '- if expression on its own line', '- each row in rows', 'TYPES', 'FORMULAS', 'EXAMPLES', 'PAGES (this UI', 'OVER THE PAGE', 'Dialog#signup', 'Tablets and phones']) {
        expect(page, contains(kept), reason: kept);
        expect(taught(1280), contains(kept), reason: kept);
      }
      // No behaviour word, no escape to JSON, no reference pages.
      for (final left in ['Also, on a page', 'CodeInput', 'SwipeAction', 'DataTable', 'Splitter', 'Calendar bind', 'bindEnd', 'reorder', 'key mod+k', 'fuzzy(', 'BEYOND THESE WORDS', 'node {', 'ui_docs', 'confirm "', 'announce "']) {
        expect(page, isNot(contains(left)), reason: left);
        expect(taught(1280), contains(left), reason: 'the taught prompt has "$left"');
      }
    });

    test('is smaller than the taught page prompt; the taught prompts are as they were', () {
      expect(plain(1280).length, lessThan(taught(1280).length - 2000));
      expect(plain(1280).length, lessThan(18500), reason: 'about 4,500 tokens');
      expect(open(1280).length, plain(1280).length + notationDefinePreface.length);
      expect(taught(390).length, lessThan(9000));
      expect(plain(390).length, lessThan(taught(390).length + notationOpenPreface.length));
    });

    test('asks for a definition of every word it invents, after the last screen; without define, as the first corpus was asked', () {
      final page = open(1280);
      expect(page, startsWith('$notationOpenPreface$notationDefinePreface'));
      expect(page, contains('define after the last screen'));
      expect(plain(1280), startsWith(notationOpenPreface));
      expect(plain(1280), isNot(contains('define')));
      expect(page.substring(notationOpenPreface.length + notationDefinePreface.length), plain(1280).substring(notationOpenPreface.length));
    });

    test('each definition in it is read, expands with its defaults and validates; a page using them has no issue', () {
      final blocks = [for (final b in notationDefinePreface.split(RegExp(r'\n\n+'))) if (b.startsWith('define ')) b];
      expect(blocks, hasLength(3));
      final read = readPageDefinitions(blocks.join('\n'));
      expect(read.problems, isEmpty);
      expect(read.words.keys, ['StickyNote', 'ColorPicker', 'Group']);
      expect(checkDefinitions(NotationVocabulary(definitions: read.words), catalog: standardCatalog, validate: _problems), isEmpty);
      for (final o in [const NotationOptions(), const NotationOptions().open()]) {
        final r = parseNotation('''
state tint=""
Column gap=12
  StickyNote "Buy milk" onTap={toast "note"}
  ColorPicker bind=tint onPick={toast "{result}"}
  Group "Notes"
    Text "Inside the panel"
${blocks.join('\n')}
''', catalog: standardCatalog, options: o);
        expect(r.issues, isEmpty);
        expect(_problems(r.document), isEmpty);
        expect(r.vocabulary.where((u) => u.kind != 'definition'), isEmpty);
      }
    });

    test('lists no component of a design system', () async {
      final ds = await DesignSystem.load((ref) async => switch (ref) {
            'design_system.json' => jsonEncode({
                'schema': 1,
                'name': 'Acme',
                'theme': <String, Object?>{},
                'components': <Object?>[],
              }),
            _ => null,
          });
      final catalog = ds.catalogOver(standardCatalog);
      final prompt = notationPrompt(catalog: catalog, options: NotationOptions.fromDesignSystem(ds, width: 1280), designSystem: ds, open: true);
      expect(prompt, isNot(contains('COMPONENTS')));
      expect(prompt, isNot(contains('PUTTING THEM TOGETHER')));
    });

    test('every example in it parses with nothing recorded: the core is all it uses', () {
      final prompt = open(390);
      final examples = prompt.substring(prompt.indexOf('EXAMPLES') + 9).trim().split(RegExp(r'\n\n+'));
      expect(examples, hasLength(3));
      for (final e in examples) {
        final r = parseNotation(e, catalog: standardCatalog, options: const NotationOptions().open());
        expect(r.issues, isEmpty, reason: e);
        expect(r.vocabulary, isEmpty, reason: e);
      }
    });
  });

  test('NotationStream gives the record as it reads', () {
    final stream = NotationStream(catalog: standardCatalog, options: const NotationOptions().open());
    stream.add('Column\n  Waveform "a"\n  Button "x" disabled\n');
    stream.close();
    expect(stream.issues, isEmpty);
    expect([for (final u in stream.vocabulary) (u.kind, u.word)], [('type', 'Waveform'), ('alias', 'disabled')]);
  });
}
