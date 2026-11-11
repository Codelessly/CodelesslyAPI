import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a list index bar: keys, styles, bubble round trip; defaults stay sparse', () {
    final json = {
      'groupBy': r'${= upper(left(item.last, 1))}',
      'indexBar': true,
      'indexKeys': ['A', 'B', 'C'],
      'indexStyle': {'fontFamily': 'Archivo', 'fontSize': 13, 'fontWeight': 900, 'color': '#FFF7F5F0'},
      'indexActiveColor': '#FF19E57A',
      'indexMutedColor': '#FF63636D',
      'indexWidth': 30,
      'indexBubble': true,
      'indexBubbleColor': '#FFF7F5F0',
      'indexBubbleStyle': {'fontFamily': 'Anton', 'fontSize': 44},
    };
    final s = ListSections.fromJson(json)!;
    expect(s.indexKeys, ['A', 'B', 'C']);
    expect(s.indexStyle.fontSize, 13);
    expect(s.indexActiveColor, const Color(0xFF19E57A));
    expect(s.indexWidth, 30);
    expect(s.indexBubble, isTrue);
    expect(s.indexBubbleStyle.fontFamily, 'Anton');
    expect(ListSections.fromJson(s.toJson()), s);
    expect(ListSections.fromJson({'groupBy': 'g'})!.toJson(), {'groupBy': 'g'});
  });

  test('swipe actions: per-item when, label style, inline icon, radius, armed feedback', () {
    final s = SwipeActions.fromJson({
      'radius': 18,
      'armedScale': 1.12,
      'armHaptic': true,
      'startActions': [
        {
          'id': 'checkin',
          'label': 'CHECK IN',
          'when': r'${= item.checkedInAt == null}',
          'labelStyle': {'fontSize': 16, 'fontWeight': 900},
          'iconSize': 28,
          'inline': true,
          'removes': false,
        },
      ],
    })!;
    final a = s.startActions.single;
    expect(a.when, r'${= item.checkedInAt == null}');
    expect(a.labelStyle.fontSize, 16);
    expect(a.iconSize, 28);
    expect(a.inline, isTrue);
    expect(s.radius, BorderRadius.circular(18));
    expect(s.armedScale, 1.12);
    expect(s.armHaptic, isTrue);
    expect(SwipeActions.fromJson(s.toJson()), s);
    final plain = SwipeAction(id: 'x');
    expect(plain.when, '');
    expect(plain.inline, isFalse);
    expect(plain.toJson().containsKey('when'), isFalse);
  });
}
