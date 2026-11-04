import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Node _node(String type, Json props, {Json slots = const {}}) =>
    Node.fromJson({'type': type, 'props': props, 'slots': slots, 'layout': {'width': 100, 'height': 40}}, id: 'n')!;

void main() {
  test('every material widget is declared', () {
    for (final t in const [
      'elevatedButton', 'filledButton', 'textButton', 'outlinedButton', 'iconButton', 'floatingActionButton', //
      'chip', 'actionChip', 'choiceChip', 'filterChip', 'inputChip', 'badge', 'listTile', 'appBar', 'navigationBar',
      'bottomNavigationBar', 'divider', 'verticalDivider', 'modal',
    ]) {
      expect(Widgets.of(t), isNotNull, reason: t);
    }
  });

  test('a button: Flutter defaults, a ButtonStyle, sparse round trip', () {
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

  test('bad values fall back to defaults', () {
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

  test('a badge: label, count and its child slot', () {
    final n = _node('badge', {'count': 120, 'maxCount': 99, 'alignment': [-1, 1], 'offset': [2, -2]}, slots: {'child': 'icon'});
    expect(n.prop(BadgeProps.label), isNull);
    expect(n.prop(BadgeProps.count), 120);
    expect(n.prop(BadgeProps.alignment), const Alignment(-1, 1));
    expect(n.prop(BadgeProps.offset), const Offset(2, -2));
    expect(n.prop(BadgeProps.padding), const EdgeInsets.symmetric(horizontal: 4));
    expect(n.childIds, ['icon']);
    expect(Node.fromJson(n.toJson()), n);
  });

  test('navigation destinations and app bar actions', () {
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

  test('list tile and divider props', () {
    final tile = _node('listTile', {
      'dense': true,
      'visualDensity': {'horizontal': -2, 'vertical': -9},
      'contentPadding': [16, 0, 24, 0],
      'titleAlignment': 'center',
    }, slots: {'title': 't', 'leading': 'l'});
    expect(tile.prop(ListTileProps.visualDensity), const VisualDensity(horizontal: -2, vertical: -4));
    expect(tile.prop(ListTileProps.contentPadding), const EdgeInsets.fromLTRB(16, 0, 24, 0));
    expect(tile.prop(ListTileProps.titleAlignment), ListTileTitleAlignment.center);
    expect(Node.fromJson(tile.toJson()), tile);

    final divider = _node('verticalDivider', {'thickness': 2, 'color': '#FF000000'});
    expect(divider.prop(DividerProps.thickness), 2);
    expect(divider.prop(DividerProps.indent), 0);
    expect(divider.toJson()['props'], {'thickness': 2, 'color': '#FF000000'});
  });
}
