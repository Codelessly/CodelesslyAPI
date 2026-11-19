// Universal words (docs/design/21-universal-words.md): a parameter, flag or
// event that means the same on every line, read once where a line is read;
// the Input's words (section 7) and a bare number where the text goes
// (section 8).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

const _page = NotationOptions(width: 1280);
final _openPage = _page.open();

NotationResult _open(String text) => parseNotation(text, catalog: standardCatalog, options: _openPage);
NotationResult _closed(String text) => parseNotation(text, catalog: standardCatalog, options: _page);

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();
Map<String, Object?> _props(NotationResult r, String id) => ((_node(r, id)['props'] as Map?) ?? const {}).cast<String, Object?>();
Map<String, Object?> _bind(NotationResult r, String id) => ((_node(r, id)['bind'] as Map?) ?? const {}).cast<String, Object?>();
List<Map<String, Object?>> _actions(NotationResult r, String id) => [for (final a in (_node(r, id)['actions'] as List?) ?? const []) (a as Map).cast<String, Object?>()];

/// The universal uses recorded, as `On.word`.
Set<String> _universal(NotationResult r) => {for (final u in r.vocabulary) if (u.kind == 'universal') '${u.on}.${u.word}'};

/// The uses recorded as a word we do not have, as `kind On.word`.
Set<String> _unknown(NotationResult r) => {
      for (final u in r.vocabulary)
        if (const {'parameter', 'flag', 'event'}.contains(u.kind)) '${u.kind} ${u.on}.${u.word}',
    };

/// [text] read open and closed: no issue, the same both ways.
NotationResult _clean(String text) {
  final open = _open(text), closed = _closed(text);
  expect(open.issues.map((i) => '$i'), isEmpty, reason: text);
  expect(open.document, closed.document, reason: 'the open vocabulary changes no document: $text');
  return open;
}

void main() {
  group('the table', () {
    test('holds the grammar\'s own words and the universal words, each with its kind', () {
      for (final w in ['w', 'h', 'fill', 'gap', 'radius', 'border', 'tooltip', 'selected', 'hidden', 'onTap', 'onLongPress', 'center']) {
        expect(notationUniversal[w]?.grammar, isTrue, reason: w);
      }
      expect(universalWords.toSet(), {
        'color', 'size', 'icon', 'enabled', 'disabled', 'readonly', 'readOnly', 'required', 'autofocus', //
        'reorder', 'sortable', 'reorderable', 'handle', 'onReorder', 'selectable', 'onSelect', 'removable', 'onRemove', 'onDelete',
      });
      expect(notationUniversal['onReorder']!.kind, UniversalKind.event);
      expect(notationUniversal['removable']!.kind, UniversalKind.flag);
      expect(notationUniversal['sortable']!.of, 'reorder');
      expect(isUniversal('items'), isFalse);
    });
  });

  group('color', () {
    test('on a container it inks the texts and icons written in it that set none; nearer wins', () {
      final r = _clean('''
Column
  Row color=#FFB91C1C
    Icon "warning"
    Text "Careful"
    Text "Own" color=#FF2563EB
    Column color=#FF16A34A
      Text "Inner"
  Text "Outside"
''');
      expect(_props(r, 'icon1')['color'], '#FFB91C1C');
      expect((_props(r, 'text1')['style'] as Map)['color'], '#FFB91C1C');
      expect((_props(r, 'text2')['style'] as Map)['color'], '#FF2563EB');
      expect((_props(r, 'text3')['style'] as Map)['color'], '#FF16A34A');
      expect((_props(r, 'text4')['style'] as Map)['color'], isNot('#FFB91C1C'));
      // The container itself keeps no colour of its own.
      expect(_props(r, 'row1').containsKey('color'), isFalse);
      expect(_universal(r), {'Row.color', 'Column.color'});
    });

    test('a container\'s ink that reads data is bound on what it inks', () {
      final r = _clean('state late=false\nColumn color={late ? "#FFDC2626" : "#FF111827"}\n  Text "Due"\n');
      expect(_bind(r, 'text1')['props.style.color'], contains('late'));
    });

    test('on a text and an icon it is their own ink (not recorded: the core\'s)', () {
      final r = _clean('Column\n  Text "a" color=#FF2563EB\n  Icon "star" color=#FF2563EB\n');
      expect((_props(r, 'text1')['style'] as Map)['color'], '#FF2563EB');
      expect(_props(r, 'icon1')['color'], '#FF2563EB');
      expect(_universal(r), isEmpty);
    });

    test('on a control it is its accent; on a chip its ink, on a choice its selected tint', () {
      final r = _clean('''
state on=false
state pick=""
state v=0
Column
  Toggle @on color=#FF16A34A
  Slider @v color=#FF16A34A
  Button "Go" color=#FF16A34A
  Button.outline "Go" color=#FF16A34A
  Button "Go" fill=#FFFACC15 color=#FF4C1D95
  Chip "Tag" color=#FF2563EB
  Chip "Pick" selected={pick=="a"} color=#FF2563EB
  Input "Name" color=#FF2563EB
''');
      expect(_props(r, 'switch1')['activeTrackColor'], '#FF16A34A');
      expect(_props(r, 'slider1'), containsPair('activeTrackColor', '#FF16A34A'));
      expect(_props(r, 'slider1'), containsPair('thumbColor', '#FF16A34A'));
      expect(_props(r, 'filledButton1')['style'], containsPair('backgroundColor', '#FF16A34A'));
      expect(_props(r, 'outlinedButton1')['style'], containsPair('foregroundColor', '#FF16A34A'));
      // A filled button given its fill: the colour is its label's.
      expect(_props(r, 'filledButton2')['style'], containsPair('foregroundColor', '#FF4C1D95'));
      expect(_props(r, 'chip1')['labelStyle'], {'color': '#FF2563EB'});
      expect(_props(r, 'chip1')['avatarColor'], '#FF2563EB');
      expect(_props(r, 'chip2')['selectedColor'], '#FF2563EB');
      expect(_props(r, 'textField1')['style'], containsPair('color', '#FF2563EB'));
      expect(_universal(r), {'Toggle.color', 'Slider.color', 'Button.color', 'Chip.color', 'Input.color'});
    });
  });

  group('size', () {
    test('a step of the theme\'s scale on a text, an icon, a ring, an avatar, a bar, a chip and a field', () {
      final r = _clean('''
Column
  Text "Big" size=large
  Text "Small" size=small
  Text "Px" size=18
  Icon "star" size=small
  Ring 0.6 size=large
  Ring 0.6 size=40
  Avatar "Maya Reyes" size=large
  Progress 0.4 size=large
  Chip "Tag" size=small
  Input "Name" size=large
  Input "Title" size=28
''');
      expect((_props(r, 'text1')['style'] as Map)['fontSize'], 20);
      expect((_props(r, 'text2')['style'] as Map)['fontSize'], 12);
      expect((_props(r, 'text3')['style'] as Map)['fontSize'], 18);
      expect(_props(r, 'icon1')['size'], 16);
      expect((_node(r, 'circularProgressIndicator1')['layout'] as Map)['width'], 96);
      expect((_node(r, 'circularProgressIndicator2')['layout'] as Map)['width'], 40);
      expect((_node(r, 'column2')['layout'] as Map)['width'], 56);
      expect((_node(r, 'progressBar1')['layout'] as Map)['height'], 12);
      expect((_node(r, 'chip1')['layout'] as Map)['height'], 24);
      expect((_node(r, 'textField1')['layout'] as Map)['height'], 44 + 20);
      expect(_props(r, 'textField2')['style'], containsPair('fontSize', 28));
      expect(_universal(r), {'Text.size', 'Icon.size', 'Ring.size', 'Avatar.size', 'Progress.size', 'Chip.size', 'Input.size'});
    });

    test('is not universal on a container or a toggle: left out and recorded', () {
      final r = _open('state on=false\nColumn size=large\n  Toggle @on size=large\n');
      expect(_unknown(r), {'parameter Column.size', 'parameter Toggle.size'});
    });
  });

  group('icon', () {
    test('a leading icon on a chip (its avatar) and a list tile (its leading slot); an input\'s and a button\'s are their own', () {
      final r = _clean('''
Column
  Chip "Seats" icon="timer"
  ListTile "Mail" "Inbox" icon="mail"
  Input "Search" icon="search"
  Button "Save" icon="save"
''');
      expect(_props(r, 'chip1')['avatar'], 'timer');
      final tile = _node(r, 'listTile1');
      expect((tile['slots'] as Map)['leading'], 'listTile1Icon');
      expect(_props(r, 'listTile1Icon')['icon'], 'mail');
      expect(((_props(r, 'textField1')['decoration'] as Map)['prefixIcon'] as Map)['icon'], 'search');
      expect(_props(r, 'filledButton1')['icon'], 'save');
      expect(_universal(r), {'Chip.icon', 'ListTile.icon'});
    });
  });

  group('disabled', () {
    test('on a box or a text: the disabled state, no pointer and half strength; on a control its own enabled', () {
      final r = _clean('''
state busy=true
state v=0
Column
  Card disabled
    Text "Off"
  Text "Dim" disabled={busy}
  Button "Save" disabled={busy}
  Slider @v disabled
''');
      expect(_bind(r, 'column2')['disabled'], r'${= true}');
      expect((_node(r, 'column2')['states'] as Map)['disabled'], {
        'column2': {'opacity': 0.5, 'ignorePointer': true},
      });
      expect(_bind(r, 'text2')['disabled'], contains('busy'));
      // A control with an enabled of its own takes it (the alias, as before).
      expect(_bind(r, 'filledButton1')['props.enabled'], contains('busy'));
      // A slider has no enabled: its disabled state, drawn by the slider.
      expect(_bind(r, 'slider1')['disabled'], r'${= true}');
      expect(_node(r, 'slider1')['states'], isNull);
      expect(_universal(r), {'Card.enabled', 'Text.enabled', 'Slider.enabled'});
    });
  });

  group('readonly, required, tooltip', () {
    test('readonly: an input\'s own; another control takes no input; not universal on a box', () {
      final r = _open('state on=false\nColumn\n  Input "Name" readonly\n  Toggle @on readonly\n  Column readonly\n');
      expect(_props(r, 'textField1')['readOnly'], isTrue);
      expect(_node(r, 'switch1')['ignorePointer'], isTrue);
      // (written readonly, read as readOnly: the alias table's other name)
      expect(_universal(r), {'Toggle.readOnly'});
      expect(_unknown(r), contains('flag Column.readOnly'));
    });

    test('required: the label marked; an input checks it is not empty', () {
      final r = _clean('state ok=false\nstate name=""\nColumn\n  Input "Name" @name required\n  Checkbox "Agree" @ok required\n');
      final field = _props(r, 'textField1');
      expect((field['decoration'] as Map)['labelText'], 'Name *');
      expect(field['validator'], contains('Required'));
      expect(field['autovalidateMode'], 'onUnfocus');
      expect(_props(r, 'checkbox1')['label'], 'Agree *');
      expect(_universal(r), {'Input.required', 'Checkbox.required'});
    });

    test('a tooltip that reads data is the node\'s own on any line', () {
      final r = _clean('state n=3\nColumn\n  Text "a" tooltip="{n} left"\n  Icon "info" tooltip={n}\n  Column tooltip="Fixed"\n');
      expect(_node(r, 'text1')['tooltip'], r'${n} left');
      expect(_node(r, 'icon1')['tooltip'], r'${n}');
      expect(_node(r, 'column2')['tooltip'], 'Fixed');
    });
  });

  group('on a list', () {
    const items = 'state items=[{"id":"a","name":"Alpha"},{"id":"b","name":"Beta"},{"id":"c","name":"Gamma"}]\n';

    test('reorder (sortable) on the line over an each is that each reordered: by a long press, written to the list', () {
      final r = _clean('${items}state q=""\nColumn sortable onReorder={q=result[0].name}\n  each it in items\n    Text "{it.name}"\n');
      final list = _node(r, 'listView1');
      expect((list['props'] as Map)['reorder'], {'start': 'longPress', 'keyboard': true, 'apply': 'variable'});
      expect(list['focusGroup'], {'axis': 'vertical', 'wrap': false});
      // onReorder's result is the list in its new order: the variable, written.
      final reorder = _actions(r, 'listView1').single;
      expect(reorder['trigger'], {'type': 'reorder'});
      expect(((reorder['actions'] as List).single as Map)['value'], r'${= (items)[0].name}');
      expect(_universal(r), {'Column.onReorder', 'Column.reorder'});
    });

    test('with handle, by the rows\' Handle; over a formula, stored by onReorder with result the moved list', () {
      final r = _clean('${items}state order=[]\nColumn reorder handle onReorder={order=result}\n  each it in filter(items, x => x.id != "c")\n    Row\n      Handle\n      Text "{it.name}"\n');
      final reorder = (_node(r, 'listView1')['props'] as Map)['reorder'] as Map;
      expect(reorder['start'], 'handle');
      expect(reorder['apply'], 'none');
      expect(((_actions(r, 'listView1').single['actions'] as List).single as Map)['value'], contains('move(filter(items'));
    });

    test('reorder where no list is reordered (a grid): left out and recorded, the list kept', () {
      final r = _open('${items}Grid cols=2 reorder\n  each it in items\n    Text "{it.name}"\n');
      expect(r.issues, isEmpty);
      expect((_node(r, 'gridView1')['props'] as Map).containsKey('reorder'), isFalse);
      expect(_unknown(r), {'flag Grid.reorder'});
    });

    test('selectable: a tap selects alone, Ctrl or Cmd adds, Shift takes a range, Ctrl or Cmd A all; kept in selected=@list', () {
      final r = _clean('state sel=[]\n${items}state q=""\nColumn selectable selected=@sel onSelect={q="n {length(result)}"}\n  each it in items\n    Text "{it.name}"\n');
      final vars = {for (final v in ((r.document['variables'] as Map)['screen'] as List)) (v as Map)['name']: v};
      expect(vars['sel'], {'name': 'sel', 'type': 'list', 'value': <Object?>[]});
      expect(vars['selAnchor']?['value'], -1);
      final item = _node(r, 'listView1Item');
      expect((item['bind'] as Map)['selected'], r'${= contains(sel, coalesce(item.id, item))}');
      expect(((item['states'] as Map)['selected'] as Map).keys, ['listView1Item']);
      final tap = _actions(r, 'listView1Item').single;
      expect(tap['trigger'], {'type': 'click'});
      final acts = (tap['actions'] as List).cast<Map>();
      expect(acts[0]['variable'], 'sel');
      expect(acts[0]['value'], allOf(contains('result.shift'), contains('result.meta'), contains('slice(items')));
      expect(acts[1]['variable'], 'selAnchor');
      expect(acts[2]['type'], 'announce');
      // onSelect after: its result is the selection.
      expect(acts[3], {'type': 'setVariable', 'variable': 'q', 'value': r'n ${= length(sel)}'});
      final all = _actions(r, 'listView1').single;
      expect(all['trigger'], {'type': 'keyDown', 'key': 'mod+a'});
      expect(_node(r, 'listView1')['focusGroup'], {'axis': 'vertical', 'wrap': false});
      expect(_universal(r), {'Column.selectable', 'Column.selected', 'Column.onSelect'});
    });

    test('a list word with no each under it is left out and recorded; its variable is still the page\'s', () {
      final r = _open('state sel=[]\nColumn selectable selected=@sel\n  Text "{length(sel)}"\n');
      expect(_unknown(r), {'flag Column.selectable', 'parameter Column.selected'});
    });

    test('removable: a chip is an input chip whose x fires onRemove (onDelete); a row gets an x at its end', () {
      final r = _clean('state tags=["a","b"]\nstate q=""\nColumn\n  Chip "a" onDelete={tags=without(tags,"a")}\n  Row removable onRemove={q="gone"}\n    Text "Row"\n');
      expect(_node(r, 'chip1')['type'], 'inputChip');
      expect(_actions(r, 'chip1').single['trigger'], {'type': 'deleted'});
      final row = _node(r, 'row1');
      expect((row['children'] as List).last, 'row1Remove');
      final x = _node(r, 'row1Remove');
      expect(x['type'], 'iconButton');
      expect(x['tooltip'], 'Remove');
      expect((_actions(r, 'row1Remove').single['actions'] as List).single, {'type': 'setVariable', 'variable': 'q', 'value': 'gone'});
      expect(_universal(r), {'Chip.onRemove', 'Row.removable', 'Row.onRemove'});
    });
  });

  group('the same word on four kinds of line', () {
    test('color, disabled and tooltip on a box, a text, an icon and a control', () {
      final r = _clean('''
state on=false
Column
  Row color=#FF2563EB disabled tooltip="Box"
    Text "in"
  Text "t" color=#FF2563EB disabled tooltip="Text"
  Icon "star" color=#FF2563EB disabled tooltip="Icon"
  Toggle @on color=#FF2563EB disabled tooltip="Toggle"
''');
      expect((_props(r, 'text1')['style'] as Map)['color'], '#FF2563EB');
      expect((_props(r, 'text2')['style'] as Map)['color'], '#FF2563EB');
      expect(_props(r, 'icon1')['color'], '#FF2563EB');
      expect(_props(r, 'switch1')['activeTrackColor'], '#FF2563EB');
      for (final id in ['row1', 'text2', 'icon1']) {
        expect(_bind(r, id)['disabled'], r'${= true}', reason: id);
      }
      expect(_props(r, 'switch1')['enabled'], isFalse);
      for (final (id, tip) in [('row1', 'Box'), ('text2', 'Text'), ('icon1', 'Icon'), ('switch1', 'Toggle')]) {
        expect(_node(r, id)['tooltip'], tip, reason: id);
      }
    });
  });

  group('a stand-in honours the universal words (D6)', () {
    test('what it applies is recorded universal; what it leaves out is in its record only', () {
      final r = _open('state on=false\nstate seat=""\nColumn\n  SeatMap "Hall" h=200 fill=#FFF3F4F6 color=#FF2563EB selected={on} onTap={on=!on} onChange={on=true} @seat zoom=2 x=4\n');
      expect(_universal(r), {'SeatMap.h', 'SeatMap.fill', 'SeatMap.color', 'SeatMap.selected', 'SeatMap.onTap'});
      // Its text takes its ink.
      expect((_props(r, 'text1')['style'] as Map)['color'], '#FF2563EB');
      expect(_unknown(r), isEmpty);
    });
  });

  group('a defined word gets the universal words without naming them', () {
    const define = '''
define Note "text" fill=#FFFDE68A
  Column pad=12 fill={fill}
    Text "{text}"
''';
    test('a use\'s universal word goes on the root, and is recorded universal', () {
      final r = _open('${define}Column\n  Note "Buy milk" color=#FFB91C1C removable onRemove={toast "x"}\n');
      expect(r.issues, isEmpty);
      expect((_props(r, 'text1')['style'] as Map)['color'], '#FFB91C1C');
      expect((_node(r, 'note1')['children'] as List).last, 'note1Remove');
      expect(_universal(r), {'Note.color', 'Note.removable', 'Note.onRemove'});
    });

    test('one the root is not a kind for is a word the definition does not have', () {
      final r = _open('${define}Column\n  Note "Buy milk" size=large handle\n');
      expect(r.issues, isEmpty);
      expect(_unknown(r), {'parameter Note.size', 'flag Note.handle'});
    });
  });

  group('Input (D8)', () {
    test('its words: clearable, maxlength, caps, autogrow, center, value beside bind, prefix and suffix', () {
      final r = _clean('''
state q=""
state draft=""
state code=""
state w=""
Column
  Input "Search" @q clearable
  Input "Code" @code maxlength=5 caps center
  Input "Note" @draft multiline autogrow
  Input "Title" @q value={draft}
  Input "Weight" @w prefix="~" suffix="kg"
''');
      final search = _props(r, 'textField1');
      final x = (search['decoration'] as Map)['suffixIcon'] as Map;
      expect(x['icon'], 'close');
      expect(((x['actions'] as List).single as Map)['actions'], [
        {'type': 'editText', 'node': 'textField1', 'operation': 'clear'},
      ]);
      expect(_props(r, 'textField2'), allOf(containsPair('maxLength', 5), containsPair('textCapitalization', 'characters'), containsPair('textAlign', 'center')));
      expect(_props(r, 'textField3'), allOf(containsPair('minLines', 1), containsPair('maxLines', 6)));
      expect(_bind(r, 'textField4')['props.initialValue'], r'${draft}');
      // …and a change still writes the variable it is bound to.
      expect(((_actions(r, 'textField4').first['actions'] as List).first as Map)['variable'], 'q');
      final weight = _props(r, 'textField5')['decoration'] as Map;
      expect(weight, allOf(containsPair('prefixText', '~'), containsPair('suffixText', 'kg'), containsPair('affixesAlwaysVisible', true)));
    });

    test('its events: onEnter is onSubmit, onSaved is onBlur, onKeyDown a key in the field (key is result.key)', () {
      final r = _clean('state q=""\nstate i=0\nColumn\n  Input "a" @q onEnter={i=1} onSaved={i=2} onKeyDown={i=key=="ArrowDown" ? 3 : 4}\n');
      final triggers = [for (final a in _actions(r, 'textField1')) (a['trigger'] as Map)['type']];
      expect(triggers, containsAll(['submitted', 'focusLost', 'keyDown']));
      final key = _actions(r, 'textField1').firstWhere((a) => (a['trigger'] as Map)['type'] == 'keyDown');
      expect(((key['actions'] as List).single as Map)['value'], contains('result.key'));
    });

    test('fuzzy is a recorded no-op that says where fuzzy matching goes', () {
      final r = _open('state q=""\nColumn\n  Input "Find" @q fuzzy\n');
      expect(r.issues.single.message, contains('filter(items, x => fuzzy(x.name, q))'));
      expect(_unknown(r), {'flag Input.fuzzy'});
    });
  });

  group('a bare number where the text goes (D9)', () {
    test('is the text on a core type and a stand-in, the value where the type\'s main thing is one', () {
      final r = _open('Column\n  Badge 3\n  Text 2026\n  Button 1\n  CountUp 39 suffix="%"\n  Progress 0.6\n');
      expect(r.issues, isEmpty);
      expect(_props(r, 'text1')['text'], '3');
      expect(_props(r, 'text2')['text'], '2026');
      expect(_props(r, 'filledButton1')['label'], '1');
      expect(_props(r, 'text3')['text'], '39');
      expect(_props(r, 'progressBar1')['value'], 0.6);
    });

    test('on a defined word: its next string, or its value; the number in an expression', () {
      final r = _clean('define Count "value" suffix=""\n  Row\n    Text "{value}{suffix}"\n    Text "{value * 2}"\nColumn\n  Count 39 suffix="%"\n');
      expect(_props(r, 'text1')['text'], '39%');
      // Read nothing at run time: worked out as the use is read (docs/design/20 section 13).
      expect(_props(r, 'text2')['text'], '78');
      final v = _clean('define Gauge2 value=0\n  Text "{value}"\nColumn\n  Gauge2 7\n');
      expect(_props(v, 'gauge21')['text'], '7');
    });

    test('a number after a key is not the text, and a bare word naming a value is still an issue', () {
      final r = _closed('Column\n  Text "a" italic 24\n');
      expect(r.issues.single.message, contains('Unknown word "24"'));
      expect(_closed('state plan={"name":"Pro"}\nColumn\n  Text plan.name\n').issues.single.message, contains('"{plan.name}"'));
      expect(_closed('Column\n  Grid 3\n').issues, isNotEmpty, reason: 'Grid 3 is no text');
    });
  });
}
