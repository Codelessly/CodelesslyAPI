import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

typedef J = Map<String, Object?>;

Map<String, Object?> _icon(int codepoint, {double? size, String? color}) => {
      'show': true,
      'icon': {'type': 'MATERIAL_ICON', 'codepoint': codepoint, 'name': 'x', 'style': 'filled', 'version': 1},
      'size': ?size,
      'color': ?color,
    };

/// Migrates [nodes] (v1 JSON by id, under one canvas body frame).
(J, MigrationReport) _migrate(Map<String, J> nodes) {
  final report = MigrationReport();
  final kids = [for (final e in nodes.entries) if (e.value['parentID'] == null) e.key];
  final v2 = migrateDocument({
    'rootNode': {'children': ['c']},
    'c': {'id': 'c', 'type': 'canvas', 'name': 'c', 'parentID': 'rootNode', 'basicBoxLocal': [0, 0, 400, 800],
          'properties': {'bodyId': 'b'}, 'children': ['b']},
    'b': {'id': 'b', 'type': 'frame', 'name': 'b', 'parentID': 'c', 'basicBoxLocal': [0, 0, 400, 800], 'children': kids},
    for (final e in nodes.entries) e.key: {'id': e.key, 'name': e.key, 'parentID': 'b', ...e.value},
  }, report: report);
  return ((v2['nodes'] as Map).cast<String, Object?>(), report);
}

J _props(J nodes, String id) => ((nodes[id] as Map)['props'] as Map? ?? const {}).cast<String, Object?>();

void main() {
  test('buttons resolve v1 defaults into a ButtonStyle', () {
    final (nodes, report) = _migrate({
      'f': {'type': 'filledButton', 'basicBoxLocal': [0, 0, 128, 40], 'padding': [16, 0], 'horizontalFit': 'shrinkWrap',
            'properties': {'variant': 'filled', 'label': 'New', 'shape': 'stadium', 'icon': _icon(57669, size: 18, color: '#FFFFFFFF'),
                           'labelStyle': {'fills': [{'type': 'solid', 'color': 'FFFFFF', 'id': 'p'}], 'fontSize': 14}}},
      'e': {'type': 'elevatedButton', 'basicBoxLocal': [0, 0, 100, 30],
            'properties': {'label': 'Go', 'placement': 'end', 'gap': 4, 'enabled': false}},
      'o': {'type': 'outlinedButton', 'basicBoxLocal': [0, 0, 100, 30], 'properties': {'label': 'Out', 'buttonColor': '#FF515B92'}},
      't': {'type': 'filledButton', 'basicBoxLocal': [0, 0, 100, 30], 'properties': {'variant': 'tonal', 'label': 'Tonal'}},
      'i': {'type': 'iconButton', 'basicBoxLocal': [0, 0, 48, 48], 'properties': {'label': 'b', 'icon': _icon(1, size: 20), 'buttonColor': '#00000000'}},
    });
    expect(report.unmapped.keys.where((k) => !k.startsWith('canvas.')), isEmpty);
    expect(report.undecodable, isEmpty);
    expect(report.unportedTypes, isEmpty);
    final f = _props(nodes, 'f');
    expect(f['label'], 'New');
    expect(f['textAlign'], 'center');
    expect((f['icon'] as Map)['codepoint'], 57669);
    final fs = f['style'] as Map;
    // A filled button without a color is the theme's primary.
    expect(fs.containsKey('backgroundColor'), isFalse);
    expect(fs['foregroundColor'], '#FFFFFFFF');
    expect(fs['shape'], {'type': 'stadium'});
    expect(fs['iconSize'], 18);
    expect((fs['textStyle'] as Map).containsKey('color'), isFalse);
    expect((nodes['f'] as Map)['layout']['padding'], [16, 0, 16, 0]);

    final e = _props(nodes, 'e');
    expect(e['iconAlignment'], 'end');
    expect(e['spacing'], 4);
    expect(e['enabled'], false);
    expect((e['style'] as Map)['backgroundColor'], '#FF000000');
    // The icon (v1's default) is sized to the button: min(20, 30).
    expect((e['style'] as Map)['iconSize'], 20);

    final o = _props(nodes, 'o')['style'] as Map;
    expect(o['backgroundColor'], '#00000000');
    expect(o['side'], {'color': '#FF515B92'});

    expect(_props(nodes, 't')['tonal'], true);
    expect((nodes['i'] as Map)['type'], 'iconButton');
    expect((_props(nodes, 'i')['style'] as Map)['foregroundColor'], isNull);
  });

  test('chips by kind, FABs, badges and dividers', () {
    final (nodes, report) = _migrate({
      'ch': {'type': 'chip', 'basicBoxLocal': [0, 0, 100, 30], 'properties': {'chipType': 'filter', 'label': 'Mine', 'selected': true,
             'borderColor': '#FFC7C5D0', 'padding': [8, 6]}},
      'in': {'type': 'chip', 'basicBoxLocal': [0, 0, 100, 30], 'properties': {'chipType': 'input', 'label': 'X', 'deleteIcon': _icon(2)}},
      'fab': {'type': 'floatingActionButton', 'basicBoxLocal': [0, 0, 150, 56],
              'properties': {'type': 'extended', 'label': 'Compose', 'icon': _icon(3), 'shape': 'stadium'}},
      'bd': {'type': 'badge', 'basicBoxLocal': [0, 0, 20, 16], 'childID': 'txt', 'properties': {'badgeType': 'count', 'label': '12', 'maxCount': 9}},
      'txt': {'type': 'text', 'parentID': 'bd', 'basicBoxLocal': [0, 0, 20, 16], 'data': 'Hi'},
      'dv': {'type': 'divider', 'basicBoxLocal': [0, 0, 20, 100], 'properties': {'isVertical': true, 'thickness': 2}},
    });
    expect(report.unmapped.keys.where((k) => !k.startsWith('canvas.')), isEmpty);
    expect(report.undecodable, isEmpty);
    expect((nodes['ch'] as Map)['type'], 'filterChip');
    final ch = _props(nodes, 'ch');
    expect(ch['selected'], true);
    expect(ch['side'], {'color': '#FFC7C5D0'});
    expect(ch['padding'], [8, 6, 8, 6]);
    expect(ch['shape'], {'borderRadius': 8});
    expect((nodes['in'] as Map)['type'], 'inputChip');
    expect((_props(nodes, 'in')['deleteIcon'] as Map)['codepoint'], 2);

    final fab = _props(nodes, 'fab');
    expect(fab['type'], 'extended');
    expect(fab['shape'], {'type': 'stadium'});
    expect(fab['elevation'], 0);

    expect((nodes['bd'] as Map)['slots'], {'child': 'txt'});
    expect(_props(nodes, 'bd'), {'count': 12, 'maxCount': 9, 'textStyle': isA<Map>()});

    expect((nodes['dv'] as Map)['type'], 'verticalDivider');
    expect(_props(nodes, 'dv'), {'thickness': 2, 'color': '#FF000000'});
  });

  test('list tiles, app bars, navigation bars and modals', () {
    final (nodes, report) = _migrate({
      'lt': {'type': 'listTile', 'basicBoxLocal': [0, 0, 390, 72], 'children': ['lead', 'title', 'sub'], 'leading': 'lead', 'title': 'title',
             'subtitle': 'sub', 'properties': {'showSubtitle': false, 'dense': true, 'visualDensity': {'type': 'compact'}}},
      'lead': {'type': 'rectangle', 'parentID': 'lt', 'basicBoxLocal': [0, 0, 24, 24]},
      'title': {'type': 'text', 'parentID': 'lt', 'basicBoxLocal': [0, 0, 100, 20], 'data': 'T'},
      'sub': {'type': 'text', 'parentID': 'lt', 'basicBoxLocal': [0, 0, 100, 20], 'data': 'S'},
      'ab': {'type': 'appBar', 'basicBoxLocal': [0, 0, 390, 56], 'properties': {'title': 'Hi', 'backgroundColor': '#FFFFFFFF',
             'automaticallyImplyLeading': false, 'leading': {'id': 'l', 'type': 'icon', 'icon': _icon(4, size: 24)},
             'actions': [{'id': 'a', 'type': 'icon', 'icon': _icon(5), 'tooltip': 'Search'}]}},
      'nav': {'type': 'navigationBar', 'basicBoxLocal': [0, 0, 390, 80], 'selectedIndex': 1, 'properties': {'styleDefinition': 'material_2',
              'navigationBarType': 'shifting', 'items': [
                {'id': 'n0', 'label': 'A', 'icon': _icon(6), 'reactions': []},
                {'id': 'n1', 'label': 'B', 'icon': _icon(7), 'reactions': [], 'differSelectedIcon': true, 'selectedIcon': _icon(8, color: '#FF000000')},
              ]}},
      'md': {'type': 'modal', 'basicBoxLocal': [0, 0, 100, 40], 'trigger': 'btn', 'content': 'body', 'children': ['btn', 'body']},
      'btn': {'type': 'textButton', 'parentID': 'md', 'basicBoxLocal': [0, 0, 100, 40], 'properties': {'label': 'Open'}},
      'body': {'type': 'frame', 'parentID': 'md', 'basicBoxLocal': [0, 0, 200, 100], 'children': []},
    });
    expect(report.unmapped.keys.where((k) => !k.startsWith('canvas.')), isEmpty);
    expect(report.undecodable, isEmpty);
    final lt = nodes['lt'] as Map;
    expect(lt['slots'], {'leading': 'lead', 'title': 'title'});
    expect(lt['props']['visualDensity'], {'horizontal': -2, 'vertical': -2});
    expect(lt['props']['contentPadding'], isNotNull);

    final ab = _props(nodes, 'ab');
    expect(ab['title'], 'Hi');
    expect(ab['automaticallyImplyLeading'], false);
    expect((ab['leading'] as Map)['size'], 24);
    expect((ab['actions'] as List).single['tooltip'], 'Search');

    expect((nodes['nav'] as Map)['type'], 'bottomNavigationBar');
    final nav = _props(nodes, 'nav');
    expect(nav['selectedIndex'], 1);
    expect(nav['type'], 'shifting');
    final dest = nav['destinations'] as List;
    expect(dest.map((d) => d['label']), ['A', 'B']);
    expect(dest.last['selectedIconColor'], '#FF000000');

    expect((nodes['md'] as Map)['slots'], {'trigger': 'btn', 'content': 'body'});
  });
}
