import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

void main() {
  test('an icon saved with a bare icon (beside its properties, before icon sources) converts', () {
    final report = MigrationReport();
    final v2 = migrateDocument({
      'rootNode': {'children': ['c']},
      'c': {
        'id': 'c', 'type': 'canvas', 'name': 'C', 'parentID': 'root', 'basicBoxLocal': [0, 0, 100, 100], //
        'properties': {'bodyId': 'b'}, 'children': ['b'],
      },
      'b': {
        'id': 'b', 'type': 'frame', 'name': 'B', 'parentID': 'c', 'basicBoxLocal': [0, 0, 100, 100], 'children': ['i'], //
      },
      'i': {
        'id': 'i', 'type': 'icon', 'name': 'Icon done', 'parentID': 'b', //
        'basicBoxLocal': {'x': 0, 'y': 0, 'width': 18, 'height': 24},
        'color': {'r': 1, 'g': 1, 'b': 1, 'a': 1},
        'properties': {},
        'properties': {},
        'icon': {'codepoint': 59510, 'fontFamily': 'MaterialIcons', 'type': 'MATERIAL_ICON', 'style': 'rounded', 'name': 'done', 'version': 1},
      },
    }, report: report);
    expect(report.undecodable, isEmpty);
    final icon = (v2['nodes'] as Map)['i'] as Map;
    expect('$icon', contains('done'));
  });

  test('an icon saved with a bare icon and no properties converts', () {
    final report = MigrationReport();
    migrateDocument({
      'rootNode': {'children': ['i']},
      'i': {
        'id': 'i', 'type': 'icon', 'name': 'Icon done', 'parentID': 'root', //
        'basicBoxLocal': {'x': 0, 'y': 0, 'width': 18, 'height': 24},
        'icon': {'codepoint': 59510, 'fontFamily': 'MaterialIcons', 'type': 'MATERIAL_ICON', 'style': 'rounded', 'name': 'done', 'version': 1},
      },
    }, report: report);
    expect(report.undecodable, isEmpty);
  });
}
