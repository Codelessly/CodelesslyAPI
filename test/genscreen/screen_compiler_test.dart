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
  brandTests();
  normalizeTests();
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

void brandTests() {
  for (final String k in ['aurora', 'kiosk', 'verdant']) {
    test('album plan compiles on-brand for $k', () {
      final DesignKit designKit = kit(k);
      final CompiledScreen screen = ScreenCompiler(designKit).compile(plan('album_details'));
      final BrandCheck check = checkOnBrand(screen, designKit);
      expect(check.offBrand, isEmpty);
      expect(check.checked['color'], greaterThan(50));
      expect(check.checked['type'], greaterThan(20));
      expect(screen.report.interactive, greaterThan(5));
      expect(screen.report.wired, screen.report.interactive);
    });
  }

  test('raw values sneaked into a plan are caught twice', () {
    final DesignKit designKit = kit('aurora');
    final Map<String, dynamic> bad = plan('album_details');
    ((bad['sections'] as List).first['children'] as List).add({'type': 'text', 'text': 'Hi', 'color': '#FF00FF'});
    final issues = ScreenPlanValidator(designKit).validate(bad);
    expect(issues.map((i) => '$i'), contains(contains('Raw color "#FF00FF"')));
    final CompiledScreen screen = ScreenCompiler(designKit).compile(bad);
    expect(screen.report.warnings, contains(contains('Color token "#FF00FF" is not in the kit')));
    expect(checkOnBrand(screen, designKit).passed, isTrue);
  });
}

void normalizeTests() {
  test('runtime names in a plan are renamed everywhere', () {
    final Map<String, dynamic> p = {
      'title': 'Product',
      'data': {'product': {'name': 'Arc', 'qty': 1}},
      'variables': [{'name': 'quantity', 'type': 'number', 'value': 1}],
      'sections': [
        {'children': [
          {'type': 'text', 'text': r'${product.name} x ${= quantity + product.qty}'},
          {'type': 'button', 'label': 'Add', 'action': {'type': 'set', 'variable': 'quantity', 'value': r'${= quantity + 1}'}},
        ]},
      ],
      'states': {'loading': {}, 'error': {'title': 'Oops'}},
    };
    final (out, renames) = normalizePlan(p);
    expect(renames, {'product': 'productInfo'});
    expect((out['data'] as Map).keys, ['productInfo']);
    expect(((out['sections'] as List)[0]['children'] as List)[0]['text'], r'${productInfo.name} x ${= quantity + productInfo.qty}');
    expect((out['variables'] as List)[0]['type'], 'integer');
    final issues = ScreenPlanValidator(kit('aurora')).validate(p);
    expect(issues.where((i) => i.severity == PlanSeverity.error), isEmpty);
    expect(issues.map((i) => '$i'), contains(contains('renamed to "productInfo"')));
  });
}
