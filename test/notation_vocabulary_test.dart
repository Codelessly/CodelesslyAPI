// The open vocabulary (docs/design/19-open-vocabulary.md): a word the
// notation does not have is recorded and stands in, a name for a word it
// has is read as that word, and with the vocabulary closed nothing changes.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/prompt.dart' show notationDefinePreface, notationOpenPreface, notationPrompt;
import 'package:test/test.dart';

const _page = NotationOptions(width: 1280);
final _openPage = _page.open();

NotationResult _open(String text, {NotationOptions? options}) => parseNotation(text, catalog: standardCatalog, options: options ?? _openPage);
NotationResult _closed(String text, {NotationOptions options = _page}) => parseNotation(text, catalog: standardCatalog, options: options);

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
state chosen=[]
App
  Main
    Column gap=8
      SeatMap#plan "Hall A" rows={seats} selectable multi selected=@chosen onTap={q="x"} onChange={q="y"; haptic}
        Text "Stage"
        if q!=""
          Legend "Chosen"
      Button "Go" tooltip2="x" wobble onFling={vibrate plan; q="z"} onTap={share q; toast "ok"}
      Button.danger "Delete"
''';
    late NotationResult r;
    setUp(() => r = _open(text));

    test('nothing is an issue', () {
      expect(r.issues.map((i) => '$i'), isEmpty);
    });

    test('a type: the word, its line and column, the words it is under, its strings, parameters, flags, events and the lines under it', () {
      final seat = _uses(r, 'type').firstWhere((u) => u.word == 'SeatMap');
      expect(seat.line, 6);
      expect(seat.column, 7);
      expect(seat.path, ['App', 'Main', 'Column']);
      expect(seat.node, 'plan');
      expect(seat.source, startsWith('SeatMap#plan "Hall A" rows={seats}'));
      expect(seat.texts, ['Hall A']);
      expect(seat.parameters, {'rows': '{seats}', 'selected': '@chosen'});
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
      expect((p.word, p.on, p.value, p.line), ('tooltip2', 'Button', '"x"', 10));
      final f = _uses(r, 'flag').single;
      expect((f.word, f.on, f.line), ('wobble', 'Button', 10));
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
      // `haptic` is an action of the catalog (design 22 section 2.3): read, not recorded.
      expect([for (final v in verbs) (v.word, v.on, v.value)], [('vibrate', 'Button', 'plan'), ('share', 'Button', 'q')]);
    });

    test('a variant: recorded, and the plain type is drawn', () {
      final v = _uses(r, 'variant').single;
      expect((v.word, v.on, v.line), ('Button.danger', 'Button', 11));
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
      final r = _open('state tint=""\nColumn\n  ColorPicker @tint\n  Text "{tint}"\n');
      expect(r.issues, isEmpty);
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
      final r = _open('state v=0\nColumn\n  Slider @v\n    Text "under a slider"\n  Text "last"\n');
      expect(r.issues, isEmpty);
      expect(_node(r, 'column1')['children'], ['slider1', 'text1', 'text2']);
      final use = _uses(r, 'children').single;
      expect((use.word, use.value), ('Slider', 'Text'));
    });

    test('a value of another kind than a parameter takes is left out and recorded', () {
      final r = _open('Column\n  Text "Saved" live=polite\n');
      expect(r.issues, isEmpty);
      final use = _uses(r, 'parameter').single;
      expect((use.word, use.on, use.value), ('live', 'Text', 'polite'));
    });

    test('an open of nothing over the page opens a placeholder sheet (recorded as a wanted overlay); a scroll to no line of it is left out and said', () {
      final r = _open('Page\n  Section\n    Button "A" onTap={open nothing; toast "x"}\n    Button "B" onTap={scroll nowhere}\n');
      expect(r.issues.map((i) => '$i'), [
        startsWith('line 4:1: No line of this page has the id "nowhere" for a scroll to go to'),
      ]);
      expect(_uses(r, 'overlay').single.word, 'nothing');
      final actions = ((_node(r, 'filledButton1')['actions'] as List).single as Map)['actions'] as List;
      expect([for (final a in actions) (a as Map)['type']], ['openModal', 'showToast']);
      expect(jsonEncode(r.document), contains('"text":"Nothing"'));
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
      const ours = 'state low=0\nstate high=100\nColumn\n  Slider @low @high min=0 max=100\n';
      _same('state low=0\nstate high=100\nColumn\n  RangeSlider @low @high min=0 max=100\n', ours, word: 'RangeSlider', to: 'Slider');
      _same('state low=0\nstate high=100\nColumn\n  RangeSlider low=@low high=@high min=0 max=100\n', ours, word: 'RangeSlider', to: 'Slider');
      final one = _open('state range=[0,10]\nColumn\n  RangeSlider @range min=0 max=100\n');
      expect(_uses(one, 'alias'), isEmpty);
      expect(_uses(one, 'type').single.word, 'RangeSlider');
      expect(_closed('state range=0\nColumn\n  RangeSlider @range\n').issues.single.message, contains('No node type "RangeSlider"'));
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
        _same('state day=""\nColumn\n  $name @day\n', 'state day=""\nColumn\n  Calendar @day\n', word: name, to: 'Calendar');
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
      _same('state name=""\nColumn\n  Input "Name" @name disabled\n', 'state name=""\nColumn\n  Input "Name" @name enabled=false\n', word: 'disabled');
      final r = _closed('state n=0\nColumn\n  Button "Send" disabled={n==0}\n');
      expect(_node(r, 'filledButton1')['bind'], {'props.enabled': r'${= !(n==0)}'});
    });

    test('a ListTile\'s subtitle (and title) are its strings', () {
      _same('Column\n  ListTile "Ada" subtitle="Engineer"\n', 'Column\n  ListTile "Ada" "Engineer"\n', word: 'subtitle', to: r'$text');
      _same('Column\n  ListTile title="Ada" subtitle="Engineer"\n', 'Column\n  ListTile "Ada" "Engineer"\n', word: 'title');
      _same('state r={"role":"Engineer"}\nColumn\n  ListTile "Ada" subtitle={r.role}\n', 'state r={"role":"Engineer"}\nColumn\n  ListTile "Ada" "{r.role}"\n', word: 'subtitle');
    });

    test('persist after a state is saved (it was read into the value)', () {
      _same('state draft="" persist\nColumn\n  Input "Note" @draft\n', 'state draft="" saved\nColumn\n  Input "Note" @draft\n', word: 'persist', to: 'saved');
      _same('state n=20 persisted\nColumn\n  Text "{n}"\n', 'state n=20 saved\nColumn\n  Text "{n}"\n', word: 'persisted');
      _same('state n=20 persistent\nColumn\n  Text "{n}"\n', 'state n=20 saved\nColumn\n  Text "{n}"\n', word: 'persistent');
      _same('project cart=[] persist\nColumn\n  Text "{length(cart)}"\n', 'project cart=[] saved\nColumn\n  Text "{length(cart)}"\n', word: 'persist');
      final r = _closed('state n=20 persist\nColumn\n  Text "{n}"\n');
      expect(((r.document['variables'] as Map)['screen'] as List).single, {'name': 'n', 'type': 'integer', 'value': 20, 'persist': true});
    });

    test('every alias of the built-in table is one of the above', () {
      const tested = {
        'Shortcut', 'shortcut', 'computed', 'ConfirmDialog', 'RangeSlider', 'Highlight', 'HighlightText', 'MiniCalendar', 'CalendarMonth', 'MonthGrid', //
        'StickyBar', 'StickyFooter', 'BottomBar', 'FooterBar', 'BottomDock', 'QRCode', 'QrCode',
      };
      expect(NotationVocabulary.core.types.keys.toSet(), tested);
      // Its ends by the names a range is written with (test 10: end=@hi).
      expect(NotationVocabulary.core.types['RangeSlider']!.parameters, {'start': 'low', 'end': 'high', 'rangeEnd': 'high'});
      expect(NotationVocabulary.core.types['RangeSlider']!.requires, ['low', 'high']);
      // The universal words' other names and an Input's (docs/design/21) are
      // tested in notation_universal_test.dart.
      expect(NotationVocabulary.core.parameters, {
        '*': {'disabled': '!enabled', 'readonly': 'readOnly'},
        'ListTile': {'subtitle': r'$text', 'title': r'$text'},
        'Input': {'maxlength': 'maxLength', 'maxChars': 'maxLength', 'rows': 'lines'},
        'Barcode': {'value': 'data', 'code': 'data', 'format': 'symbology', 'type': 'symbology'},
      });
      expect(NotationVocabulary.core.flags.keys.toSet(), {'*', 'Input', 'state', 'project'});
      expect(NotationVocabulary.core.flags['*'], {'disabled': 'enabled=false', 'readonly': 'readOnly', 'sortable': 'reorder', 'reorderable': 'reorder'});
      expect(NotationVocabulary.core.flags['state'], {'persist': 'saved', 'persisted': 'saved', 'persistent': 'saved'});
      expect(NotationVocabulary.core.events, {
        '*': {'onDelete': 'onRemove'},
        'Input': {'onEnter': 'onSubmit', 'onSubmitted': 'onSubmit', 'onSaved': 'onBlur'},
        'Calendar': {'onSelect': 'onChange'},
      });
      expect(NotationVocabulary.core.verbs, isEmpty);
    });

    test('a word the notation already has is never an alias', () {
      // FilterChip, Calendar and Slider are words of the catalog: a table that
      // names them changes nothing.
      final table = NotationVocabulary.fromJson({
        'types': {'Slider': 'Progress', 'Card': 'Column'},
        'parameters': {'Slider': {'min': 'max'}},
      });
      const text = 'state v=2\nCard\n  Slider @v min=2 max=9\n';
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

      same('state notes=""\nColumn\n  TextArea "Notes" @notes placeholder="Anything"\n', 'state notes=""\nColumn\n  Input "Notes" @notes hint="Anything" multiline\n');
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
      expect(again.types['RangeSlider']!.requires, ['low', 'high']);
      expect(again.types['Shortcut']!.line, 'shortcut');
      // With no table at all nothing is an alias.
      final none = _closed('Column\n  Button "Go" disabled\n', options: _page.open(openVocabulary: false, vocabulary: NotationVocabulary.none));
      expect(none.vocabulary, isEmpty);
      expect(none.issues.single.message, contains('Unknown word "disabled"'));
    });
  });

  group('aliases that say more: a variant, fixed parameters, renamed ones, the main string as a parameter (the vocabulary loop, Review 7, D38)', () {
    /// [alias] and [ours] are the same document with [table] (open and
    /// closed); the alias is recorded.
    void same(NotationVocabulary table, String alias, String ours, {Catalog? catalog, NotationOptions base = _page}) {
      for (final o in [base.open(openVocabulary: false, vocabulary: table), base.open(vocabulary: table)]) {
        final c = catalog ?? standardCatalog;
        final a = Catalog.run(c, () => parseNotation(alias, catalog: c, options: o)), b = Catalog.run(c, () => parseNotation(ours, catalog: c, options: o));
        expect(a.issues.map((i) => '$i'), isEmpty, reason: alias);
        expect(b.issues.map((i) => '$i'), isEmpty, reason: ours);
        expect(jsonEncode(a.document), jsonEncode(b.document), reason: '$alias is not $ours');
        expect(_uses(a, 'alias'), isNotEmpty, reason: alias);
      }
    }

    test('a type read as another with a variant and fixed parameters; what the line writes is its own', () {
      final table = NotationVocabulary.fromJson({
        'types': {
          'GoKey': {'to': 'Button.outline', 'add': 'size=large'},
          'StopKey': 'Button.ghost',
        },
      });
      same(table, 'Column\n  GoKey "Go" onTap={toast "go"}\n', 'Column\n  Button.outline "Go" onTap={toast "go"} size=large\n');
      // The line's own size and variant win.
      same(table, 'Column\n  GoKey "Go" size=small\n', 'Column\n  Button.outline "Go" size=small\n');
      same(table, 'Column\n  GoKey.ghost "Go"\n', 'Column\n  Button.ghost "Go" size=large\n');
      same(table, 'Column\n  StopKey "Stop"\n', 'Column\n  Button.ghost "Stop"\n');
      final r = _open('Column\n  GoKey "Go"\n', options: _page.open(vocabulary: table));
      expect(_uses(r, 'alias').single.to, 'Button.outline');
      // Written back as it was read.
      expect(table.types['GoKey']!.toJson(), {'to': 'Button.outline', 'add': 'size=large'});
      expect(table.types['StopKey']!.toJson(), 'Button.ghost');
    });

    test('a type alias renames the parameters of the word it is read as (as it always could)', () {
      final table = NotationVocabulary.fromJson({
        'types': {
          'Fader': {'to': 'Slider', 'parameters': {'level': 'value', 'top': 'max'}},
        },
      });
      same(table, 'state vol=3\nColumn\n  Fader level=@vol top=10\n', 'state vol=3\nColumn\n  Slider @vol max=10\n');
    });

    test('the main string read as a named parameter: on a defined word that takes none, and by a type alias of its own', () {
      const counter = 'Tally2 label="" max=8\n  Text "{label} of {max}"\n';
      final table = const NotationVocabulary().define({'Tally2.txt': counter}).merge(NotationVocabulary.fromJson({
        'types': {
          'Score': {'to': 'Tally2', 'parameters': {r'$text': 'label'}},
        },
        'parameters': {
          'Tally2': {r'$text': 'label'},
        },
      }));
      same(table, 'Column\n  Tally2 "Strokes" max=4\n', 'Column\n  Tally2 label="Strokes" max=4\n');
      same(table, 'Column\n  Score "Putts"\n', 'Column\n  Tally2 label="Putts"\n');
      // A label written as well is the line's: the string stays unread.
      final r = _open('Column\n  Tally2 "x" label="y"\n', options: _page.open(vocabulary: table));
      expect(jsonEncode(r.document), contains('y of 8'));
    });

    test('…and on a component that takes no string; never where the word takes one', () async {
      final files = {
        'design_system.json': jsonEncode({'id': 'm', 'name': 'M', 'components': ['components/Meter.json']}),
        'components/Meter.json': jsonEncode({
          'schema': 3,
          'id': 'Meter',
          'roots': ['row'],
          'widget': {
            'type': 'Meter',
            'doc': 'A figure with its unit.',
            'props': [
              {'key': 'value', 'type': {'kind': 'number', 'flutter': 'double'}, 'default': 0},
              {'key': 'unit', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': ''},
            ],
          },
          'nodes': {
            'row': {'type': 'row', 'children': ['text']},
            'text': {'type': 'text', 'props': {'text': r'${props.unit}'}},
          },
        }),
      };
      final ds = await DesignSystem.load((ref) async => files[ref]);
      final catalog = ds.catalogOver(standardCatalog);
      final table = NotationVocabulary.fromJson({
        'parameters': {
          'Meter': {r'$text': 'unit'},
          'Text': {r'$text': 'never'},
        },
      });
      final base = NotationOptions.fromDesignSystem(ds, width: 1280);
      same(table, 'Column\n  Meter "km/h" value=3\n', 'Column\n  Meter unit="km/h" value=3\n', catalog: catalog, base: base);
      final r = Catalog.run(catalog, () => parseNotation('Column\n  Text "plain"\n', catalog: catalog, options: base.open(vocabulary: table)));
      expect(r.vocabulary, isEmpty);
      expect(jsonEncode(r.document), contains('"text":"plain"'));
    });
  });

  group('what the corpus showed the grammar should read (docs/design/19, section 8)', () {
    test('Progress {done/total}: a share worked out, where its number goes', () {
      for (final options in [_page, _openPage]) {
        final r = parseNotation('state done=1\nColumn\n  Progress {done/4} grow\n  Ring {done/4}\n', catalog: standardCatalog, options: options);
        expect(r.issues.map((i) => '$i'), isEmpty);
        expect((_node(r, 'progressBar1')['bind'] as Map)['props.value'], r'${= done/4}');
        expect((_node(r, 'progressBar1')['layout'] as Map)['flex'], 1);
        expect(jsonEncode(r.document), jsonEncode(parseNotation('state done=1\nColumn\n  Progress value={done/4} grow\n  Ring value={done/4}\n', catalog: standardCatalog, options: options).document));
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
        expect((_node(r, 'textField1')['props'] as Map)['keyboardType'], keyboard);
      }
    });

    test('an overlay written inside the page is still over the page, and the page goes on after it', () {
      final r = _closed('''
state name=""
Page
  Section
    Button "Edit" onTap={open edit}
  Dialog#edit "Edit"
    Input "Name" @name
  Section
    Text "After the dialog"
''');
      expect(r.issues.map((i) => '$i'), isEmpty);
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
      expect((_node(r, 'text1')['layout'] as Map)['flex'], 1);
      expect((_node(r, 'text2')['layout'] as Map).containsKey('flex'), isFalse);
    });
  });

  group('the shapes the glossary\'s answers wrote on core words (the vocabulary loop, Review 6, D30)', () {
    test('Text strike=true is the flag; strike={cond} a line through while it holds; strike=false nothing', () {
      for (final read in [_open, _closed]) {
        final r = read('state done=false\nColumn\n  Text#a "11:35" strike=true\n  Text#b "Milk" strike={done}\n  Text#c "Eggs" strike=false\n');
        expect(r.issues, isEmpty);
        expect(r.vocabulary.where((u) => u.kind != 'universal'), isEmpty);
        expect((_node(r, 'a')['props'] as Map)['style'], containsPair('decoration', 'lineThrough'));
        expect(_node(r, 'b')['bind'], {'props.style.decoration': r'${= (done) ? "lineThrough" : "none"}'});
        expect((_node(r, 'c')['props'] as Map)['style'], isNot(contains('decoration')));
      }
    });

    test('Barcode "…" encodes its text as bars; value=, code= and format= are its own words; QRCode is one as a QR code', () {
      for (final read in [_open, _closed]) {
        final r = read('Column\n  Barcode#a "29034 00718 4421" w=260\n  Barcode#b value="X1" format=ean13 h=96\n  QRCode#c value="https://example.com"\n');
        expect(r.issues, isEmpty);
        expect(_node(r, 'a')['props'], {'data': '29034 00718 4421', 'symbology': 'code128'});
        expect((_node(r, 'a')['layout'] as Map)['height'], 80);
        expect(_node(r, 'b')['props'], {'data': 'X1', 'symbology': 'ean13'});
        expect(_node(r, 'c')['props'], {'data': 'https://example.com', 'symbology': 'qrCode'});
        expect(_node(r, 'c')['layout'], {'height': 160, 'width': 160});
      }
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
      for (final kept in ['LINE\n  Type[.variant][#id] ["text"] [key=value ...]', '- @name is the variable itself', '- if expression on its own line', '- each row in rows', 'TYPES', 'FORMULAS', 'EXAMPLES', 'PAGES (this UI', 'OVER THE PAGE', 'Dialog#signup', 'Tablets and phones']) {
        expect(page, contains(kept), reason: kept);
        expect(taught(1280), contains(kept), reason: kept);
      }
      // No behaviour word, no escape to JSON, no reference pages.
      for (final left in ['Also, on a page', 'CodeInput', 'SwipeAction', 'DataTable', 'Splitter', 'Calendar @arrival', 'Slider @low @high', 'reorder', 'key mod+k', 'fuzzy(', 'BEYOND THESE WORDS', 'node {', 'ui_docs', 'confirm "', 'announce "']) {
        expect(page, isNot(contains(left)), reason: left);
        expect(taught(1280), contains(left), reason: 'the taught prompt has "$left"');
      }
    });

    test('is smaller than the taught page prompt; the taught prompts are as they were', () {
      expect(plain(1280).length, lessThan(taught(1280).length - 2000));
      expect(plain(1280).length, lessThan(19000), reason: 'about 4,700 tokens');
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

    test('each definition in it is read, expands with its defaults; a page using them has no issue', () {
      final blocks = [for (final b in notationDefinePreface.split(RegExp(r'\n\n+'))) if (b.startsWith('define ')) b];
      expect(blocks, hasLength(3));
      final read = readPageDefinitions(blocks.join('\n'));
      expect(read.problems, isEmpty);
      expect(read.words.keys, ['StickyNote', 'ColorPicker', 'Group']);
      expect(checkDefinitions(NotationVocabulary(definitions: read.words), catalog: standardCatalog), isEmpty);
      for (final o in [const NotationOptions(), const NotationOptions().open()]) {
        final r = parseNotation('''
state tint=""
Column gap=12
  StickyNote "Buy milk" onTap={toast "note"}
  ColorPicker @tint onPick={toast "{result}"}
  Group "Notes"
    Text "Inside the panel"
${blocks.join('\n')}
''', catalog: standardCatalog, options: o);
        expect(r.issues, isEmpty);
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

    test('by default the glossary gives each word as a line uses it, in a last section (Review 7, D33)', () async {
      final files = {
        'design_system.json': jsonEncode({'id': 'acme', 'name': 'Acme', 'components': ['components/Counter.json']}),
        'components/Counter.json': jsonEncode({
          'schema': 3,
          'id': 'Counter',
          'roots': ['row'],
          'widget': {
            'type': 'Counter',
            'doc': 'A number raised and lowered with minus and plus (a party size, a count): Counter "Guests" value={party.}',
            'props': [
              {'key': 'label', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': '', 'required': true},
              {'key': 'value', 'type': {'kind': 'variable', 'of': {'kind': 'number', 'flutter': 'double'}}, 'default': ''},
              {'key': 'max', 'type': {'kind': 'number', 'flutter': 'double'}, 'default': 8},
              {'key': 'tone', 'type': {'kind': 'enumeration', 'flutter': 'String', 'values': ['quiet', 'loud']}, 'default': 'quiet'},
              {'key': 'compact', 'type': {'kind': 'boolean', 'flutter': 'bool'}, 'default': false},
              {'key': 'marks', 'type': {'kind': 'list', 'item': {'kind': 'string', 'flutter': 'String'}, 'flutter': 'List'}, 'default': <Object?>[]},
              {'key': 'hint', 'type': {'kind': 'string', 'flutter': 'String'}, 'default': ''},
              {'key': 'ink', 'type': {'kind': 'value', 'flutter': 'Color'}},
            ],
            'events': [
              {'key': 'onChanged', 'payload': {'kind': 'number', 'flutter': 'double'}},
            ],
          },
          'nodes': {
            'row': {'type': 'row'},
          },
        }),
      };
      final ds = await DesignSystem.load((ref) async => files[ref]);
      final catalog = ds.catalogOver(standardCatalog);
      final options = NotationOptions.fromDesignSystem(ds, width: 1280).define({
        'Timeline.txt': '// A list of dated entries down a rail: each a date, a title and a note.\nTimeline.vertical#events items=[] @at selected onPick\n  Column\n    ...\n'
            '// A clip editor\'s timeline.\nTimeline#tracks zoom=1 tracks=[] onZoom\n  Column\n    ...Head\n    ...\n',
      });
      String prompt({bool define = true, bool signatures = true}) =>
          Catalog.run(catalog, () => notationPrompt(catalog: catalog, options: options, designSystem: ds, open: true, define: define, signatures: signatures));
      final page = prompt();
      expect(page, contains('${notationSignaturesLead('Acme')}\n'
          '  Counter "label" @value max=8 tone=quiet|loud compact=false marks=[] hint ink=#… onChange : number raised and lowered\n'
          '  Timeline.vertical @at items=[] selected onPick ... : list of dated entries down a rail\n'
          '  Timeline zoom=1 tracks=[] onZoom ...Head ... : clip editor\'s timeline\n'));
      expect(page, endsWith('clip editor\'s timeline\n'));
      // It replaces the names on one line, which signatures: false gives.
      expect(page, isNot(contains(notationGlossaryLead())));
      expect(prompt(signatures: false), contains('${notationGlossaryLead()}\nCounter Timeline\n\n'));
      // Without definitions asked, it does not say how to replace one.
      expect(notationSignaturesLead('Acme'), contains('define your own word'));
      expect(prompt(define: false), contains(notationSignaturesLead('Acme', define: false)));
      expect(notationSignaturesLead('Acme', define: false), isNot(contains('define')));
    });

    test('with a design system it names the words it has beyond the core, on one line (Review 6, D29)', () async {
      Map<String, Object?> component(String type) => {
            'schema': 3,
            'id': type,
            'roots': ['root'],
            'widget': {'type': type, 'doc': 'A $type.', 'props': <Object?>[]},
            'nodes': {
              'root': {'type': 'column'},
            },
          };
      final files = {
        'design_system.json': jsonEncode({
          'id': 'acme',
          'name': 'Acme',
          'components': ['components/Stepper.json', 'components/Button.json', 'components/Breadcrumb.json'],
        }),
        'components/Stepper.json': jsonEncode(component('Stepper')),
        'components/Button.json': jsonEncode(component('Button')),
        'components/Breadcrumb.json': jsonEncode(component('Breadcrumb')),
      };
      final ds = await DesignSystem.load((ref) async => files[ref]);
      final catalog = ds.catalogOver(standardCatalog);
      final options = NotationOptions.fromDesignSystem(ds, width: 1280).define({
        'Timeline.txt': 'Timeline items=[]\n  Column\n    ...\n',
        'StickyNote.txt': 'StickyNote "text"\n  Text "{text}"\n',
      });
      String prompt({bool define = true, bool glossary = true, bool withDs = true}) => Catalog.run(
          catalog, () => notationPrompt(catalog: catalog, options: options, designSystem: withDs ? ds : null, open: true, define: define, glossary: glossary, signatures: false));
      final page = prompt();
      // Button and StickyNote are taught (StickyNote in the define example).
      expect(page, contains('${notationGlossaryLead()}\nBreadcrumb Stepper Timeline\n\n'));
      expect(page, startsWith('$notationOpenPreface$notationDefinePreface${notationGlossaryLead()}'));
      expect(page.length, prompt(glossary: false).length + notationGlossaryLead().length + 'Breadcrumb Stepper Timeline'.length + 3);
      // Without a design system, or with glossary: false, there is none.
      expect(prompt(withDs: false), isNot(contains(notationGlossaryLead())));
      expect(prompt(glossary: false), isNot(contains('Breadcrumb')));
      expect(prompt(glossary: false), prompt(withDs: false));
      // Without definitions asked, the lead does not ask to define.
      expect(prompt(define: false), contains('${notationGlossaryLead(define: false)}\nBreadcrumb Stepper StickyNote Timeline\n\n'));
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
