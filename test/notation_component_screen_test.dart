// A component's key, every and on load lines are the screen's that shows
// it. They parsed and were dropped with no word (test 9, admin 3: the
// sidebar's Alt 1-7 written again on all seven pages, 42 lines).
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

/// The keyDown reactions of [r]'s screen, by key.
Map<String, Object?> _keys(NotationResult r) => {
      for (final a in (((r.document['nodes'] as Map)['screen'] as Map)['actions'] as List?) ?? const [])
        if (((a as Map)['trigger'] as Map)['type'] == 'keyDown') (a['trigger'] as Map)['key'] as String: a['actions'],
    };

void main() {
  const nav = '''
component ConsoleNav "The console's sidebar"
Column
  Text "Members"
key alt+1 onPress={go members}
key alt+2 onPress={go roles}
''';

  Future<(NotationOptions, Catalog)> site() async {
    final doc = parseNotation(nav, catalog: standardCatalog);
    expect(doc.issues, isEmpty);
    expect(doc.document['screenActions'], hasLength(2));
    final files = {
      'design_system.json': jsonEncode({'id': 'site', 'name': 'Site', 'components': ['components/ConsoleNav.json']}),
      'components/ConsoleNav.json': jsonEncode(doc.document),
    };
    final ds = await DesignSystem.load((ref) async => files[ref]);
    return (NotationOptions.fromDesignSystem(ds, width: 1440, reflow: false).withScreens(['members', 'roles']), ds.catalogOver(standardCatalog));
  }

  test('a page that calls the component takes its shortcuts, once', () async {
    final (options, catalog) = await site();
    final r = Catalog.run(catalog, () => parseNotation('Row\n  ConsoleNav\n  ConsoleNav\n  Text "Page"', catalog: catalog, options: options));
    expect(r.issues, isEmpty);
    final keys = _keys(r);
    expect(keys.keys, ['alt+1', 'alt+2']);
    expect(jsonEncode(keys['alt+1']), contains('"to":"members"'));
  });

  test("the page's own line for the same key is the page's", () async {
    final (options, catalog) = await site();
    final r = Catalog.run(catalog, () => parseNotation('Row\n  ConsoleNav\nkey alt+1 onPress={go roles}', catalog: catalog, options: options));
    expect(r.issues, isEmpty);
    final keys = _keys(r);
    expect(keys.keys.toSet(), {'alt+1', 'alt+2'});
    expect(jsonEncode(keys['alt+1']), contains('"to":"roles"'));
  });

  test('the component prints its key lines back after its tree', () {
    final doc = parseNotation(nav, catalog: standardCatalog);
    expect(printNotation(doc.document, catalog: standardCatalog).trim(), nav.trim());
  });

  test("a component's key line that reads the component's own variable is said", () {
    final r = parseNotation('''
component Pad "A pad"
state open=false
Column
  Text "x"
key alt+o onPress={open=!open}
''', catalog: standardCatalog);
    expect(r.issues.single.message, contains('which has no open of this component'));
  });
}
