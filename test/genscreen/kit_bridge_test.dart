import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/genscreen.dart';
import 'package:test/test.dart';

DesignKit kit(String name) => const DesignMdParser()
    .parse(File('test/genscreen/fixtures/$name.design.md').readAsStringSync())
    .kit;

void main() {
  test('theme tokens come from the kit', () {
    final ThemeTokens t = kitThemeTokens(kit('aurora'));
    expect(t.primary!.toHex(), '#FF4F46E5');
    expect(t.fontFamily, 'Inter');
    expect(t.titleFontFamily, 'Manrope');
    expect(t.radius, 16);
    expect(t.buttonRadius, 12);
  });

  test('styles are labeled for the editor theme and read as models', () {
    final List<Map<String, Object>> styles = kitStyles(kit('aurora'));
    expect(styles.where((s) => s['kind'] == 'color').map((s) => s['label']), containsAll(['Primary', 'On Primary', 'Surface Variant']));
    final Map<String, Object> body = styles.firstWhere((s) => s['label'] == 'Body');
    final TextProp prop = TextProp.fromJson(body['value'] as Map);
    expect(prop.fontSize, 15);
    expect(prop.fontName.family, 'Inter');
    final PaintModel paint = PaintModel.fromJson(styles.first['value'] as Map);
    expect(paint.color!.toHex(), '#4F46E5');
  });

  test('component library compiles on-brand for every kit', () {
    for (final String k in ['aurora', 'kiosk', 'verdant']) {
      final DesignKit designKit = kit(k);
      final CompiledScreen lib = kitComponentLibrary(designKit);
      expect(ScreenPlanValidator(designKit).validate(kitShowcasePlan(designKit)).where((i) => i.severity == PlanSeverity.error), isEmpty);
      expect(checkOnBrand(lib, designKit).passed, isTrue, reason: k);
    }
  });

  test('export reads a project built with a kit back to that kit', () {
    final DesignKit source = kit('aurora');
    final CompiledScreen screen = kitComponentLibrary(source);
    final List<Map<String, dynamic>> nodes = screen.toLayoutNodes().values.toList();
    final DesignKit exported = exportDesignKit(
      name: 'Aurora project',
      nodes: nodes,
      theme: kitThemeTokens(source),
      styles: [
        for (final t in source.typography.values)
          ProjectStyle.text(styleLabel(t.name), family: t.family, size: t.size, weight: t.weight, lineHeight: t.lineHeight),
      ],
    );
    expect(exported.color('primary'), source.color('primary'));
    expect(exported.color('surface'), source.color('surface'));
    expect(exported.typography['body']!.family, 'Inter');
    expect(exported.typography['title']!.size, 20);
    expect(exported.spacing.values, contains(16));
    expect(exported.radius.values, contains(12));
    // The exported kit is itself a valid DESIGN.md.
    final String md = const DesignMdWriter().write(exported);
    final DesignMdParseResult back = const DesignMdParser().parse(md);
    // Written, read and written again: the same text.
    expect(const DesignMdWriter().write(back.kit), md);
    expect(back.issues.where((i) => i.severity == DesignMdSeverity.error).map((i) => '$i'), isEmpty);
  });

  test('export infers type roles from nodes without styles', () {
    final DesignKit exported = exportDesignKit(name: 'Plain', nodes: [
      for (final (double size, String w, int n) in [(16.0, 'w400', 20), (24.0, 'w700', 4), (12.0, 'w500', 6), (14.0, 'w600', 8)])
        for (int i = 0; i < n; i++)
          {
            'textMixedProps': [
              {'fontSize': size, 'fontName': {'family': 'Inter', 'weight': w}, 'fills': [{'type': 'solid', 'color': '#111111'}]}
            ],
            'fills': [{'type': 'solid', 'color': i.isEven ? '#FFFFFF' : '#2255EE'}],
            'padding': [16, 8, 16, 8],
            'cornerRadius': [8, true, 'circular'],
          },
    ]);
    expect(exported.typography['body']!.size, 16);
    expect(exported.typography['title']!.size, 24);
    expect(exported.typography['caption']!.size, 12);
    expect(exported.typography['label']!.weight, 600);
    expect(exported.color('primary'), const KitColor(0x22, 0x55, 0xEE));
    expect(exported.color('onSurface'), const KitColor(0x11, 0x11, 0x11));
  });
}
