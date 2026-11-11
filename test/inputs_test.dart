import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('every input type is declared', () {
    for (final t in [
      'textField', 'checkbox', 'switch', 'radio', 'slider', 'dropdown', 'datePicker', 'timePicker', //
      'dateTimeInput', 'segmentedButton', 'signature',
    ]) {
      expect(Widgets.of(t), isNotNull, reason: t);
    }
  });

  test('a text field decodes its decoration and encodes sparsely', () {
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

  test('value types compare by value and build with Flutter defaults', () {
    expect(InputBorder(), InputBorder.outline);
    expect(InputBorder().toJson(), isEmpty);
    expect(const BorderSide(width: 2), isNot(BorderSide.standard));
    expect(const BorderSide(width: 2).toJson(), {'width': 2});
    final d = InputDecoration.empty.set(InputDecorationFields.hintText, 'x');
    expect(d, InputDecoration.fromJson({'hintText': 'x'}));
    expect(d.set(InputDecorationFields.hintText, null), InputDecoration.empty);
    expect(ButtonSegment(value: 'a', label: 'A').toJson(), {'value': 'a', 'label': 'A'});
    expect(InputIcon.fromJson('bad'), isNull);
  });

  test('a slider, a segmented button and a signature decode their values', () {
    final slider = Node.fromJson({
      'type': 'slider',
      'props': {'value': 30, 'max': 100, 'thumbShape': 'rectangle', 'thumbSize': [28, 16], 'showValueIndicator': 'never'},
    }, id: 's')!;
    expect(slider.prop(SliderProps.max), 100);
    expect(slider.prop(SliderProps.min), 0);
    expect(slider.prop(SliderProps.thumbShape), SliderThumbShape.rectangle);
    expect(slider.prop(SliderProps.thumbSize), const Offset(28, 16));
    expect(slider.prop(SliderProps.showValueIndicator), ShowValueIndicator.never);

    final seg = Node.fromJson({
      'type': 'segmentedButton',
      'props': {
        'segments': [
          {'value': 'day', 'label': 'Day'},
          {'value': 'week', 'enabled': false},
          'junk',
        ],
        'selected': ['day'],
      },
    }, id: 'b')!;
    final segments = seg.prop(SegmentedButtonProps.segments);
    expect(segments.map((s) => s.value), ['day', 'week']);
    expect(segments[1].enabled, isFalse);
    expect(seg.prop(SegmentedButtonProps.selected), ['day']);

    final sig = Node.fromJson({
      'type': 'signature',
      'props': {
        'value': [
          [
            [1, 2],
            [3, 4.5],
            ['x'],
          ],
        ],
        'normalized': true,
      },
    }, id: 'g')!;
    expect(sig.prop(SignatureProps.value), [
      [const Offset(1, 2), const Offset(3, 4.5)],
    ]);
    expect(sig.prop(SignatureProps.normalized), isTrue);
    expect(sig.prop(SignatureProps.placeholder), 'SIGN HERE');
    expect((sig.toJson()['props'] as Map)['value'], [
      [
        [1, 2],
        [3, 4.5],
      ],
    ]);
  });

  test('a signature decodes its sign line, mark, placeholder and caption and encodes sparsely', () {
    final plain = Node.fromJson({'type': 'signature'}, id: 'p')!;
    expect(plain.prop(SignatureProps.signLineStyle), SignLineStyle.solid);
    expect(plain.prop(SignatureProps.signLineOffset), isNull);
    expect(plain.prop(SignatureProps.signLineInset), 20);
    expect(plain.prop(SignatureProps.signLineWidth), 1);
    expect(plain.prop(SignatureProps.signMarkIcon), isNull);
    expect(plain.prop(SignatureProps.signMarkSize), 16);
    expect(plain.prop(SignatureProps.signMarkPlacement), SignMarkPlacement.above);
    expect(plain.prop(SignatureProps.placeholderStyle), TextStyle.empty);
    expect(plain.prop(SignatureProps.placeholderAlignment), Alignment.center);
    expect(plain.prop(SignatureProps.caption), '');
    expect(plain.toJson()['props'], anyOf(isNull, isEmpty));

    final json = {
      'type': 'signature',
      'props': {
        'signLineStyle': 'dashed',
        'signLineDash': 6,
        'signLineGap': 6,
        'signLineWidth': 2,
        'signLineOffset': 56,
        'signLineInset': 24,
        'signMarkIcon': {'type': 'MATERIAL_ICON', 'name': 'close', 'style': 'rounded'},
        'signMarkSize': 22,
        'signMarkColor': '#FF5E5E66',
        'signMarkPlacement': 'leading',
        'signMarkGap': 8,
        'placeholderStyle': {'fontFamily': 'Archivo', 'fontWeight': 600, 'fontSize': 20, 'letterSpacing': 0, 'color': '#FFB4B4BA'},
        'placeholderAlignment': [0, 0],
        'placeholderOffset': [0, -15],
        'caption': 'SIGN ABOVE THE LINE',
        'captionStyle': {'fontWeight': 800, 'fontSize': 11, 'letterSpacing': 1.4},
        'captionGap': 27,
        'captionAlign': 'center',
      },
    };
    final n = Node.fromJson(json, id: 's')!;
    expect(n.prop(SignatureProps.signLineStyle), SignLineStyle.dashed);
    expect(n.prop(SignatureProps.signLineOffset), 56);
    expect(n.prop(SignatureProps.signLineInset), 24);
    expect(n.prop(SignatureProps.signLineWidth), 2);
    expect(n.prop(SignatureProps.signMarkIcon)!['name'], 'close');
    expect(n.prop(SignatureProps.signMarkSize), 22);
    expect(n.prop(SignatureProps.signMarkColor), const Color(0xFF5E5E66));
    expect(n.prop(SignatureProps.signMarkPlacement), SignMarkPlacement.leading);
    expect(n.prop(SignatureProps.placeholderStyle).fontSize, 20);
    expect(n.prop(SignatureProps.placeholderStyle).letterSpacing, 0);
    expect(n.prop(SignatureProps.placeholderOffset), const Offset(0, -15));
    expect(n.prop(SignatureProps.caption), 'SIGN ABOVE THE LINE');
    expect(n.prop(SignatureProps.captionStyle).fontWeight, 800);
    expect(n.prop(SignatureProps.captionGap), 27);
    expect(n.prop(SignatureProps.captionAlign), TextAlign.center);
    expect(Node.fromJson(n.toJson(), id: 's'), n);
  });

  test('a checkbox decodes its unchecked fill and checked side', () {
    final n = Node.fromJson({
      'type': 'checkbox',
      'props': {
        'fillColor': '#FF1C1C21',
        'side': {'color': '#FF2E2E34', 'width': 2},
        'activeSide': {'color': '#FF1FE07A', 'width': 2},
        'compact': true,
      },
    }, id: 'c')!;
    expect(n.prop(CheckboxProps.fillColor), const Color(0xFF1C1C21));
    expect(n.prop(CheckboxProps.activeSide)!.color, const Color(0xFF1FE07A));
    expect(n.prop(CheckboxProps.activeSide)!.width, 2);
    expect(Node.fromJson({'type': 'checkbox'}, id: 'd')!.prop(CheckboxProps.fillColor), isNull);
    expect(Node.fromJson(n.toJson(), id: 'c'), n);
    expect((n.toJson()['props'] as Map)['fillColor'], isNotNull);
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
