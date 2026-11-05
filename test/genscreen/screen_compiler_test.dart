import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/genscreen.dart';
import 'package:test/test.dart';

DesignKit kit(String name) => const DesignMdParser()
    .parse(File('test/genscreen/fixtures/$name.design.md').readAsStringSync())
    .kit;

Map<String, dynamic> plan(String name) =>
    jsonDecode(File('test/genscreen/plans/$name.json').readAsStringSync())
        as Map<String, dynamic>;

/// Keys a node's JSON had that its model dropped on the way back.
Set<String> droppedKeys(Map<String, dynamic> json) {
  final BaseNode node = NodeJsonConverter().fromJson(json)!;
  final Map out = node.toJson();
  return json.keys.where((k) => !out.containsKey(k)).toSet();
}

void main() {
  test('album plan is valid for aurora', () {
    final issues = ScreenPlanValidator(kit('aurora')).validate(plan('album_details'));
    expect(issues.where((i) => i.severity == PlanSeverity.error), isEmpty, reason: issues.join('\n'));
  });

  for (final String k in ['aurora', 'kiosk', 'verdant']) {
    test('album plan compiles for $k and every node reads back', () {
      final CompiledScreen screen = ScreenCompiler(kit(k)).compile(plan('album_details'));
      final nodes = screen.toLayoutNodes();
      final Set<String> dropped = {};
      for (final MapEntry<String, Map<String, dynamic>> e in nodes.entries) {
        final Set<String> lost = droppedKeys(e.value)
          ..removeAll(['parentID', 'name', 'rowColumnType', 'basicBoxLocal', 'id', 'type', 'children']);
        for (final k in lost) {
          dropped.add('${e.value['type']}.$k=${jsonEncode(e.value[k])}');
        }
      }
      // Values equal to the model's defaults are omitted by toJson.
      const Set<String> defaults = {
        'crossAxisAlignment="center"', 'mainAxisAlignment="center"',
        'flex=1', 'strokeAlign="inside"', 'horizontalFit="fixed"',
        'verticalFit="fixed"', 'clipsContent=true',
      };
      expect(
        dropped.where((d) => !defaults.contains(d.substring(d.indexOf('.') + 1))),
        isEmpty,
      );
      expect(nodes.length, greaterThan(50));
    });
  }
}
