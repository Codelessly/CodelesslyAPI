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

  test('lines a writer gives a composer are kept; a multi-line field alone, or a form\'s last row, is as written', () {
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
    // One line with a label and a hint beside a text button, in the row that
    // ends a column of fields, is that form's last row: labelled.
    expect(_decoration(r, 'news'), {'labelText': 'Email address', 'hintText': 'you@example.com'});
    expect(_props(r, 'news'), isNot(contains('textInputAction')));
  });

  test('a field beside a text button is an inline entry: its label the placeholder, or spoken beside a hint, and no height for a label', () {
    const options = NotationOptions(width: 1280, controlHeight: 34);
    final r = _parse('''
state item=""
state comment=""
state code=""
state guest=""
state title=""
state note=""
Column gap=12
  Row gap=8 middle
    Input#item "Add a checklist item" @item grow
    Button.outline "Add"
  Row gap=8 middle
    Input#comment "Comment" "Write a comment" @comment grow
    Button "Post"
  Card gap=8
    Text.strong "Order"
    Row gap=8 middle
      Input#promo "Promo code" "Enter a code" @code grow
      Button.outline "Apply"
  Column gap=12
    Input#title "Title" "Team sync" @title
    Text "Guests"
    Row gap=8 middle
      Input#guest "Add guest" "Name or email" @guest grow
      Button.outline "Add"
    Input#note "Note" @note multiline
''', options: options);
    expect(r.issues, isEmpty);
    expect(_decoration(r, 'item'), {'hintText': 'Add a checklist item'});
    expect((_node(r, 'item')['layout'] as Map)['height'], 34);
    expect(_props(r, 'item'), isNot(contains('semanticLabel')));
    expect(_decoration(r, 'comment'), {'hintText': 'Write a comment'});
    expect(_props(r, 'comment')['semanticLabel'], 'Comment');
    expect(_decoration(r, 'promo'), {'hintText': 'Enter a code'});
    expect(_props(r, 'promo')['semanticLabel'], 'Promo code');
    // A row in the middle of a form (a field after it): its button adds to
    // the form, it does not send it; the field is an entry.
    expect(_decoration(r, 'guest'), {'hintText': 'Name or email'});
    expect(_props(r, 'guest')['semanticLabel'], 'Add guest');
    // The form's own fields keep their labels.
    expect(_decoration(r, 'title'), {'labelText': 'Title', 'hintText': 'Team sync'});
  });

  test('the row that ends a form keeps its labels: a labelled field with a hint before the submit button, two fields, fields with no button', () {
    final r = _parse('''
state name=""
state email=""
state first=""
state last=""
Column gap=12
  Column gap=12
    Input#name "Name" "Jane Doe" @name
    Row gap=8 bottom
      Input#email "Email" "you@example.com" @email grow
      Button "Sign up"
  Column gap=12
    Input#name2 "Name" "Jane Doe" @name
    Row gap=8 bottom
      Input#first "First name" "Jane" @first grow
      Input#last "Last name" "Doe" @last grow
      Button "Save"
  Row gap=12
    Input#first2 "First name" @first grow
    Input#last2 "Last name" @last grow
  Column gap=12
    Input#name3 "Name" @name
    Row gap=8 middle
      Input#code "Invite code" @email grow
      Button "Join"
''');
    expect(r.issues, isEmpty);
    expect(_decoration(r, 'email'), {'labelText': 'Email', 'hintText': 'you@example.com'});
    expect(_props(r, 'email'), isNot(contains('semanticLabel')));
    expect(_decoration(r, 'first'), {'labelText': 'First name', 'hintText': 'Jane'});
    expect(_decoration(r, 'last'), {'labelText': 'Last name', 'hintText': 'Doe'});
    expect(_decoration(r, 'first2'), {'labelText': 'First name'});
    expect(_decoration(r, 'last2'), {'labelText': 'Last name'});
    // The other side of the line: a form's last field with a label and no
    // hint shows its label inside, where it is still read.
    expect(_decoration(r, 'code'), {'hintText': 'Invite code'});
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

  test('a document\'s labelled field beside buttons prints its label by name, which keeps it above', () {
    final r = _parse('''
state q=""
Row gap=8 middle
  Input#entry label="Promo code" hint="Enter a code" @q grow
  Button "Apply"
''');
    expect(r.issues, isEmpty);
    expect(_decoration(r, 'entry'), {'labelText': 'Promo code', 'hintText': 'Enter a code'});
    final printed = printNotation(r.document, catalog: standardCatalog);
    expect(printed, contains('label="Promo code"'));
    final again = _parse(printed);
    expect(_decoration(again, 'entry'), {'labelText': 'Promo code', 'hintText': 'Enter a code'});
  });

  test('a search field shows the magnifier before its text, unless the line writes its own icon or icon=none', () {
    final r = _parse('''
state q=""
Column gap=8
  Input#plain "Search" @q
  Input#hinted "Search orders" "Order number or name" @q
  Input#find "Find a note" @q grow
  Input#named "Search" hint="Try coffee" @q
  Input#own "Search" icon="manage_search" @q
  Input#none "Search" icon=none @q
  Input#email "Email" "you@example.com" @q
''');
    expect(r.issues, isEmpty);
    for (final id in const ['plain', 'hinted', 'find', 'named']) {
      expect(_decoration(r, id)['prefixIcon'], {'icon': 'search', 'size': 18}, reason: id);
    }
    expect(_decoration(r, 'plain')['hintText'], 'Search');
    expect(_decoration(r, 'hinted')['hintText'], 'Order number or name');
    expect(_decoration(r, 'own')['prefixIcon'], {'icon': 'manage_search', 'size': 18});
    expect(_decoration(r, 'none'), isNot(contains('prefixIcon')));
    expect(_decoration(r, 'none')['hintText'], 'Search');
    // A field that is not a search has none.
    expect(_decoration(r, 'email'), isNot(contains('prefixIcon')));
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
