import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {

  test('an error text bound to yes or no shows an error without a message, or none', () {
    const c = ErrorTextCodec();
    expect(c.decode(true), kErrorWithoutMessage);
    expect(c.decode(false), isNull);
    expect(c.decode('Give the card a title.'), 'Give the card a title.');
    expect(c.decode(''), '');
    expect(c.decode(null), isNull);
  });

  test('a text field round-trips its decoration and writes nothing at the defaults', () {
    final json = {
      'type': 'textField',
      'layout': {'width': 250, 'height': 48},
      'props': {
        'decoration': {
          'hintText': 'Search',
          'hintStyle': {'fontSize': 15, 'color': '#FF888888'},
          'isCollapsed': true,
          'contentPadding': [8, 4, 8, 4],
          'prefixIcon': {
            'icon': {'source': 'icon', 'codepoint': 59574, 'name': 'search'},
            'size': 20,
          },
          'enabledBorder': {
            'type': 'underline',
            'borderSide': {'color': '#FFCCCCCC', 'width': 2},
          },
          'border': {'borderRadius': 8},
          'isDense': 'nope',
          'custom': 1,
        },
        'maxLines': 0,
        'keyboardType': 'emailAddress',
        'cursorWidth': 2,
        'obscuringCharacter': '•',
      },
    };
    final n = Node.fromJson(json, id: 'f')!;
    final d = n.prop(TextFieldProps.decoration);
    expect(d.hintText, 'Search');
    expect(d.hintStyle.fontSize, 15);
    expect(d.isCollapsed, isTrue);
    // A bad value is its default.
    expect(d.isDense, isNull);
    expect(d.contentPadding, const EdgeInsets.fromLTRB(8, 4, 8, 4));
    expect(d.prefixIcon!.size, 20);
    expect(d.prefixIcon!.icon['name'], 'search');
    expect(d.enabledBorder!.type, InputBorderType.underline);
    expect(d.enabledBorder!.borderSide.width, 2);
    expect(d.enabledBorder!.borderSide.color, const Color(0xFFCCCCCC));
    expect(d.border!.type, InputBorderType.outline);
    expect(d.border!.borderRadius, const BorderRadius.circular(8));
    expect(d.border!.gapPadding, 4);
    expect(n.prop(TextFieldProps.maxLines), 0);
    expect(n.prop(TextFieldProps.keyboardType), TextInputType.emailAddress);

    final out = n.toJson()['props'] as Map;
    // Flutter's defaults are left out; unknown keys round-trip.
    expect(out.containsKey('cursorWidth'), isFalse);
    expect(out.containsKey('obscuringCharacter'), isFalse);
    final deco = out['decoration'] as Map;
    expect(deco['custom'], 1);
    expect(deco.containsKey('isDense'), isFalse);
    expect(deco['border'], {'borderRadius': 8});
    expect(Node.fromJson(n.toJson(), id: 'f'), n);
  });

  test('a dropdown keeps any JSON value as its selection', () {
    final n = Node.fromJson({
      'type': 'dropdown',
      'props': {
        'items': ['A', 'B'],
        'value': {'id': 2},
        'alignment': [0, 0],
      },
    }, id: 'd')!;
    expect(n.prop(DropdownProps.value), {'id': 2});
    expect(n.prop(DropdownProps.alignment), const Alignment(0, 0));
    expect(n.prop(DropdownProps.itemAlignment), const Alignment(-1, 0));
    expect(Node.fromJson(n.toJson(), id: 'd'), n);
  });

}
