// Text input as writers write it (the text input pass of round 11,
// codelessly_sdk docs/research/text-input-round-11.md): a composer in a row
// of buttons starts at one line with its string as the placeholder and
// sends on Enter; a field among icon buttons has no label above it; a field
// in its own framed row is bare; fill, border and radius on an Input are
// its box's. A form's labelled field is as it was.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text, {NotationOptions options = const NotationOptions()}) =>
    parseNotation(text, catalog: standardCatalog, options: options);

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();
Map<String, Object?> _props(NotationResult r, String id) => ((_node(r, id)['props'] as Map?) ?? const {}).cast<String, Object?>();
Map<String, Object?> _decoration(NotationResult r, String id) => ((_props(r, id)['decoration'] as Map?) ?? const {}).cast<String, Object?>();
Map<String, Object?> _bind(NotationResult r, String id) => ((_node(r, id)['bind'] as Map?) ?? const {}).cast<String, Object?>();

void main() {
  test('a form keeps its fields: a label above, its hint inside, a note three lines tall', () {
    final r = _parse('''
state email=""
state note=""
Column gap=16
  Input#email "Email" "you@example.com" @email
  Input#note "Note" @note multiline
  Row gap=12
    Input#first "First name" @email grow
    Input#last "Last name" @email grow
''');
    expect(r.issues, isEmpty);
    expect(_decoration(r, 'email'), {'labelText': 'Email', 'hintText': 'you@example.com'});
    expect(_props(r, 'note'), containsPair('minLines', 3));
    expect(_decoration(r, 'note'), {'labelText': 'Note'});
    // Two fields side by side are a form's row: labelled.
    expect(_decoration(r, 'first'), {'labelText': 'First name'});
  });

  test('a multi-line field in a row of buttons is a composer: one line that grows, its string the placeholder, Enter sends', () {
    final r = _parse('''
state draft=""
state sent=0
Row gap=6 middle
  IconButton "add_circle_outline" tooltip="Attach"
  Input#composer "Message #design-studio" @draft multiline grow onSubmit={sent=sent+1}
  IconButton "send" tooltip="Send"
''');
    expect(r.issues, isEmpty);
    final p = _props(r, 'composer');
    expect(p['minLines'], 1);
    expect(p['maxLines'], 6);
    expect(p['textInputAction'], 'send');
    expect(_decoration(r, 'composer'), {'hintText': 'Message #design-studio'});
  });

  test('a composer written with a label and a hint keeps the hint and speaks the label; a bound label is its hint', () {
    final r = _parse('''
state draft=""
state room="general"
Column
  Row gap=6 middle
    IconButton "add" tooltip="Attach"
    Input#both "Message" "Write a message…" @draft multiline grow
    Button "Send"
  Row gap=6 bottom
    Input#bound "Message {room}" @draft multiline grow
    IconButton "send" tooltip="Send"
''');
    expect(r.issues, isEmpty);
    expect(_decoration(r, 'both'), {'hintText': 'Write a message…'});
    expect(_props(r, 'both')['semanticLabel'], 'Message');
    expect(_bind(r, 'bound'), isNot(contains('props.decoration.labelText')));
    expect(_bind(r, 'bound')['props.decoration.hintText'], r'Message ${room}');
    expect(_props(r, 'bound')['minLines'], 1);
  });

  test('a composer a writer defines over Input, used in a row of buttons, is one too (team chat, round 11)', () {
    final r = _parse('''
state draft=""
Row gap=6 middle
  IconButton "add_circle_outline" tooltip="Attach"
  ComposerField @draft hint="Write a message…"
  IconButton "sentiment_satisfied_alt" tooltip="Emoji"
  Button "Send"
define ComposerField @value hint=""
  Input#chatEntry "Message" "{hint}" @value multiline maxLines=5
''');
    // The definition's root is the field: the call's node.
    const field = 'composerField1';
    expect(_node(r, field)['type'], 'textField');
    expect(_props(r, field)['minLines'], 1);
    expect(_props(r, field)['maxLines'], 5);
    expect(_decoration(r, field), isNot(contains('labelText')));
    expect(_props(r, field)['semanticLabel'], 'Message');
  });

  test('lines a writer gives a composer are kept; a multi-line field alone or one line beside a text button is as written', () {
    final r = _parse('''
state draft=""
state email=""
Column
  Row gap=6
    Input#own "Reply" @draft minLines=3 maxLines=8 grow
    IconButton "send" tooltip="Send"
  Input#notes "Notes" @draft multiline onSubmit={draft=""}
  Row gap=8 middle
    Input#news "Email address" "you@example.com" @email grow
    Button "Subscribe"
''');
    expect(_props(r, 'own')['minLines'], 3);
    expect(_decoration(r, 'own'), {'hintText': 'Reply'});
    // Alone, a multi-line field is a text area; its onSubmit runs on Enter.
    expect(_props(r, 'notes')['minLines'], 3);
    expect(_props(r, 'notes')['textInputAction'], 'send');
    expect(_decoration(r, 'notes'), {'labelText': 'Notes'});
    // One line beside a text button keeps its label (the owner's decision).
    expect(_decoration(r, 'news'), {'labelText': 'Email address', 'hintText': 'you@example.com'});
    expect(_props(r, 'news'), isNot(contains('textInputAction')));
  });

  test('a field among icon buttons (a stepper, a toolbar) has no label above it, nor the height for one', () {
    const options = NotationOptions(width: 1280, controlHeight: 34);
    final r = _parse('''
state reps=8
Row gap=4 middle
  IconButton "remove" tooltip="Fewer"
  Input#reps "Reps" @reps type=number
  IconButton "add" tooltip="More"
''', options: options);
    expect(_decoration(r, 'reps'), {'hintText': 'Reps'});
    expect((_node(r, 'reps')['layout'] as Map)['height'], 34);
    // The same field in a form is labelled, its height the label's too.
    final form = _parse('''
state reps=8
Column
  Input#reps "Reps" @reps type=number
''', options: options);
    expect(_decoration(form, 'reps'), containsPair('labelText', 'Reps'));
    expect((_node(form, 'reps')['layout'] as Map)['height'], greaterThan(34));
  });

  test('a field in its own framed row is bare: the frame is its box', () {
    final r = _parse('''
state draft=""
state q=""
Column
  Box#frame radius=12 border=#FFDDD6E3 pad=7
    Row gap=6 bottom
      IconButton "add" tooltip="Attach"
      Input#composer "Message #design-studio" @draft multiline grow
      IconButton "send" tooltip="Send"
  Row#search gap=8 middle radius=8 fill=#FFF3F4F6 pad=[10,0,10,0]
    Icon "search"
    Input#q "" "Search" @q grow
    IconButton "close" tooltip="Clear"
  Row#pill gap=8 middle radius=8 fill=#FFFFFFFF
    Icon "mail"
    Input#mail "" "you@example.com" @q grow
  Card pad=16 gap=8
    Text "Newsletter"
    Input#email "Email" "you@example.com" @q
''');
    expect(_decoration(r, 'composer'), {'hintText': 'Message #design-studio', 'border': {'type': 'none'}, 'filled': false});
    // The frame takes the focus ring: its line in the accent while the field has the focus.
    expect(_node(r, 'frame')['states'], {
      'focused': {
        'frame': {
          'decoration': {
            'strokes': [
              {'color': '#FF2563EB'},
            ],
          },
        },
      },
    });
    // A frame of a fill alone has no line to color.
    expect(_node(r, 'search')['states'], isNull);
    expect(_decoration(r, 'q'), containsPair('border', {'type': 'none'}));
    expect(_decoration(r, 'q'), containsPair('filled', false));
    // A framed row of an icon and a field alone (no button) is as written:
    // a document's pill (examples/showcase/desktop/native/site_landing.json)
    // prints back as it was.
    expect(_decoration(r, 'mail'), {'labelText': '', 'hintText': 'you@example.com'});
    // A card's form field keeps its box.
    expect(_decoration(r, 'email'), {'labelText': 'Email', 'hintText': 'you@example.com'});
  });

  test('fill, border and radius on an Input are its box: a filled pill, a bare field', () {
    final r = _parse('''
state q=""
Column
  Input#pill "" "Search" @q fill=#FFF3F4F6 border=none radius=20
  Input#bare "" "Message" @q border=none
  Input#line "" "Title" @q border=#FF7C3AED radius=4
''');
    expect(r.issues, isEmpty);
    expect(_decoration(r, 'pill'), {
      'labelText': '',
      'hintText': 'Search',
      'filled': true,
      'fillColor': '#FFF3F4F6',
      'border': {'type': 'none', 'borderRadius': 20},
    });
    expect(_node(r, 'pill')['decoration'], isNull);
    expect(_decoration(r, 'bare'), containsPair('filled', false));
    expect(_decoration(r, 'bare'), containsPair('border', {'type': 'none'}));
    expect(_decoration(r, 'line')['border'], {
      'type': 'outline',
      'borderSide': {'color': '#FF7C3AED'},
      'borderRadius': 4,
    });
  });

  test('a field\'s box prints back in the words that wrote it, a state\'s too', () {
    const text = '''
state q=""
Column
  Input#pill "" "Search" @q fill=#FFF3F4F6 border=none radius=20
  Input#bare "" "Message" @q border=none
  Input#line "" "Title" @q border=#FF7C3AED radius=4
  Input#name "Name" @q focused.fill=#FFEFF6FF''';
    final r = _parse(text);
    expect(r.issues, isEmpty);
    expect(((_node(r, 'name')['states'] as Map)['focused'] as Map)['name'], {
      'props': {
        'decoration': {'filled': true, 'fillColor': '#FFEFF6FF'},
      },
    });
    final printed = printNotation(r.document, catalog: standardCatalog);
    for (final line in text.split('\n').skip(2)) {
      expect(printed, contains(line.trim().replaceFirst(RegExp(r'#\w+ '), ' ').split(' @q').last.trim()), reason: '$line\n$printed');
    }
  });
}
