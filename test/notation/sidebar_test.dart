// A sidebar as the web draws one: quiet labels over its groups, items of one
// ink with the chosen one in the accent, a foot that stays at its end.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

typedef Json = Map<String, Object?>;

void main() {
  NotationResult parse(String text) =>
      parseNotation(text, catalog: standardCatalog, options: const NotationOptions(width: 1440, height: 900));
  Json node(NotationResult r, String id) => ((r.document['nodes']! as Map)[id]! as Map).cast<String, Object?>();
  Json layout(NotationResult r, String id) => (node(r, id)['layout']! as Map).cast<String, Object?>();
  Json style(NotationResult r, String id) => (((node(r, id)['props']! as Map)['style']) as Map).cast<String, Object?>();

  const page = '''
state tab="members"
App
  Sidebar#side
    Brand#brand "Tenant" "Admin console" icon="hub"
    NavSection#people "People & access"
    NavItem#members "Members" icon="group" selected={tab == "members"} onTap={tab="members"} shortcut="Alt 1"
    NavItem#teams "Teams" icon="groups" badge="4"
    Footer#foot
      NavItem#keys "Keyboard shortcuts" icon="keyboard"
  Main#main
    Text "Members"
''';

  test('a section label is small spaced capitals in a quiet ink, with room over it', () {
    final r = parse(page);
    expect(r.issues, isEmpty);
    final label = node(r, 'people');
    expect((label['props']! as Map)['text'], 'PEOPLE & ACCESS');
    expect(style(r, 'people')['fontSize'], 11);
    expect(style(r, 'people')['letterSpacing'], 0.6);
    expect(style(r, 'people')['color'], '#FF6B7280');
  });

  test('items at rest share one ink and tint under the pointer; the chosen one is a state in the accent', () {
    final r = parse(page);
    final rest = node(r, 'teams');
    final teamsText = [for (final c in rest['children']! as List) node(r, '$c')].firstWhere((n) => n['type'] == 'text');
    expect(((teamsText['props']! as Map)['style']! as Map)['color'], '#FF374151');
    expect(((teamsText['props']! as Map)['style']! as Map)['fontSize'], 13);
    expect(((rest['states']! as Map)['hovered']! as Map)['teams'], isNotNull);
    final chosen = node(r, 'members');
    expect((chosen['bind']! as Map)['selected'], contains('tab=="members"'));
    expect((((chosen['states']! as Map)['selected']! as Map)['members']! as Map)['decoration'], {
      'fills': [
        {'color': '#1F2563EB'},
      ],
    });
    // Its shortcut is a faint text at its end.
    final texts = [for (final c in chosen['children']! as List) node(r, '$c')].where((n) => n['type'] == 'text').toList();
    expect((texts.last['props']! as Map)['text'], 'Alt 1');
  });

  test('the foot is pinned at the sidebar\'s end by a spacer, with a rule over it', () {
    final r = parse(page);
    final kids = [for (final c in node(r, 'side')['children']! as List) '$c'];
    final at = kids.indexOf('foot');
    expect(at, kids.length - 1);
    final spacer = node(r, kids[at - 1]);
    expect(spacer['type'], 'spacer');
    expect((spacer['layout']! as Map)['flex'], 1);
    expect((node(r, 'foot')['decoration']! as Map)['strokeSides'], 'top');
    expect(node(r, 'foot')['children'], ['keys']);
  });

  test('a brand\'s second string is the line under its name', () {
    final r = parse(page);
    final texts = <String>[];
    void walk(String id) {
      final n = node(r, id);
      if (n['type'] == 'text') texts.add('${(n['props']! as Map)['text']}');
      for (final c in (n['children'] as List?) ?? const []) {
        walk('$c');
      }
    }

    walk('brand');
    expect(texts, ['Tenant', 'Admin console']);
  });

  test('an empty box that grows in a column pushes what follows to the end, never under the height written', () {
    final r = parse('Column#c h=400\n  Text "a"\n  box#push grow h=1\n  Text "b"');
    expect(r.issues, isEmpty);
    expect(layout(r, 'push')['height'], {'fill': 0});
    expect(layout(r, 'push')['flex'], 1);
    expect((layout(r, 'push')['constraints']! as Map)['minHeight'], 1);
    // Beside others in a row it is a width, as written.
    final row = parse('Row\n  Text "a"\n  box#gap grow h=1\n  Text "b"');
    expect(layout(row, 'gap')['height'], 1);
  });
}
