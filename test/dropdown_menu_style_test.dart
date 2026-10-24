import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('A dropdown round-trips its menu style and item image', () {
    final DropdownProperties props = DropdownProperties.fromJson({
      'items': ['Ochre sea star', 'Giant green anemone'],
      'useDataSource': true,
      'itemLabel': r'${item.name}',
      'itemImage': r'${item.image}',
      'itemImageSize': 32,
      'itemImageRadius': 4,
      'menuStyle': {
        'color': '#FBF7EE',
        'border': {'color': '#1F2B2E', 'width': 1.5},
        'radius': 4,
        'shadows': [
          {
            'id': 'stamp',
            'type': 'dropShadow',
            'radius': 0,
            'spread': 0,
            'color': '#1F2B2E',
            'offset': {'x': 4, 'y': 4},
          },
        ],
        'itemHeight': 44,
        'itemPadding': [14, 0],
        'selectedItemColor': '#D4E7DF',
        'hoverItemColor': '#E9DFCB',
        'selectedTextStyle': {'fontWeight': 'w600'},
        'showCheck': true,
        'checkColor': '#1F6F78',
        'minWidth': 240,
      },
    });
    final DropdownMenuStyleModel style = props.menuStyle!;
    expect(style.radius, 4);
    expect(style.border!.width, 1.5);
    expect(style.shadows!.single.offset, const Vec(4, 4));
    expect(style.itemHeight, 44);
    expect(style.itemPadding, const EdgeInsetsModel.symmetric(horizontal: 14));
    expect(style.selectedItemColor, ColorRGBA.fromHex('#D4E7DF'));
    expect(style.selectedTextStyle!.fontWeight, FontWeightNumeric.w600);
    expect(style.showCheck, isTrue);
    expect(style.offset, 6);
    expect(style.maxHeight, 320);
    expect(props.itemImage, r'${item.image}');
    expect(props.itemImageSize, 32);

    final Map json = props.toJson();
    expect((json['menuStyle'] as Map).containsKey('offset'), isFalse);
    final DropdownProperties decoded = DropdownProperties.fromJson(json);
    expect(decoded, props);
    expect(decoded.menuStyle, style);

    // A dropdown saved before keeps the platform menu and writes none of it.
    final DropdownProperties plain = DropdownProperties(items: ['a']);
    expect(plain.menuStyle, isNull);
    expect(plain.itemImage, isEmpty);
    final Map plainJson = plain.toJson();
    expect(plainJson.containsKey('menuStyle'), isFalse);
    expect(plainJson.containsKey('itemImage'), isFalse);
    expect(plainJson.containsKey('itemImageSize'), isFalse);
    expect(
      plain.copyWith(menuStyle: style).copyWith(clearMenuStyle: true).menuStyle,
      isNull,
    );
  });
}
