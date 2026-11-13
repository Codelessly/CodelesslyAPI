import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Node _node(String type, Json props, {Json slots = const {}}) =>
    Node.fromJson({'type': type, 'props': props, 'slots': slots, 'layout': {'width': 100, 'height': 40}}, id: 'n')!;

void main() {

  test('a button round-trips its style and writes nothing at Flutter\'s defaults', () {
    final n = _node('filledButton', {
      'label': 'Save',
      'icon': {'source': 'icon', 'codepoint': 57669, 'name': 'add'},
      'iconAlignment': 'end',
      'tonal': true,
      'style': {
        'backgroundColor': '#FF515B92',
        'elevation': 0,
        'textStyle': {'fontSize': 14, 'fontWeight': 500},
        'shape': {'type': 'stadium', 'side': {'color': '#FF767680', 'width': 2}},
        'iconSize': 18,
      },
    });
    expect(n.prop(ButtonProps.label), 'Save');
    expect(n.prop(ButtonProps.spacing), 8);
    expect(n.prop(ButtonProps.enabled), isTrue);
    expect(n.prop(ButtonProps.textAlign), TextAlign.start);
    expect(n.prop(ButtonProps.iconAlignment), IconAlignment.end);
    expect(n.prop(ButtonProps.tonal), isTrue);
    final style = n.prop(ButtonProps.style);
    expect(style.backgroundColor, const Color(0xFF515B92));
    expect(style.foregroundColor, isNull);
    expect(style.elevation, 0);
    expect(style.textStyle.fontWeight, 500);
    expect(style.shape!.type, ShapeBorderType.stadium);
    expect(style.shape!.side, const BorderSide(color: Color(0xFF767680), width: 2));
    final again = Node.fromJson(n.toJson())!;
    expect(again, n);
    // Defaults aren't stored.
    expect(_node('textButton', {'spacing': 8, 'enabled': true, 'style': {}}).toJson().containsKey('props'), isFalse);
  });

  test('a material widget with bad prop values falls back to its defaults', () {
    final n = _node('chip', {
      'label': 3,
      'side': 'oops',
      'shape': {'type': 'hexagon', 'borderRadius': 'x'},
      'padding': [1, 2],
      'elevation': 'high',
    });
    expect(n.prop(ChipProps.label), '3');
    expect(n.prop(ChipProps.side), isNull);
    expect(n.prop(ChipProps.shape), const ShapeBorder());
    expect(n.prop(ChipProps.padding), EdgeInsets.zero);
    expect(n.prop(ChipProps.elevation), isNull);
  });

  test('navigation destinations and app bar actions round-trip', () {
    final bar = _node('navigationBar', {
      'destinations': [
        {'label': 'Home', 'icon': {'codepoint': 1}, 'selectedIcon': {'codepoint': 2}, 'selectedIconColor': '#FF000000'},
        'not a destination',
        {'label': 'Me'},
      ],
      'selectedIndex': 1,
      'labelBehavior': 'onlyShowSelected',
    });
    final d = bar.prop(NavigationBarProps.destinations);
    expect(d.map((e) => e.label), ['Home', 'Me']);
    expect(d.first.selectedIcon, {'codepoint': 2});
    expect(d.first.selectedIconColor, const Color(0xFF000000));
    expect(bar.prop(NavigationBarProps.labelBehavior), NavigationDestinationLabelBehavior.onlyShowSelected);
    expect(Node.fromJson(bar.toJson()), bar);

    final appBar = _node('appBar', {
      'title': 'Albums',
      'centerTitle': true,
      'leading': {'icon': {'codepoint': 3}, 'size': 24},
      'actions': [
        {'icon': {'codepoint': 4}, 'tooltip': 'Search', 'actions': [{'trigger': {'type': 'click'}}]},
      ],
    });
    expect(appBar.prop(AppBarProps.centerTitle), isTrue);
    expect(appBar.prop(AppBarProps.leading)!.size, 24);
    expect(appBar.prop(AppBarProps.actions).single.tooltip, 'Search');
    expect(appBar.prop(AppBarProps.actions).single.actions, hasLength(1));
    expect(Node.fromJson(appBar.toJson()), appBar);
  });

}
