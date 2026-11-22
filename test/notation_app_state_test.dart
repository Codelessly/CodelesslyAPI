// An app's state file (app.txt): the state every page and component shares,
// as `state` lines in the notation's own grammar, and a site that needs no
// site.json.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/notation_site.dart';
import 'package:test/test.dart';

void main() {
  test('state lines as a page writes them: a value, a type, saved, a formula, a function, a list over lines', () {
    final app = readNotationAppState('''
// Shared.
state income=4800 saved
state plan="pro"
state note:text
state reply:map=null
state txns=[
  {"merchant":"A","amount":3},
  {"merchant":"B","amount":4},
]
state left={income-spent}
state spent=sum(txns,t=>t.amount)
state rate:decimal={left/12}
state clamp01(v):decimal={min(1, max(0, v))}
state count=2
''', catalog: standardCatalog);
    expect(app.issues, isEmpty, reason: '${app.issues.map((i) => i.message)}');
    expect(app.variables['income'], {'type': 'integer', 'value': 4800, 'persist': true});
    expect(app.variables['plan'], {'type': 'text', 'value': 'pro'});
    expect(app.variables['note'], {'type': 'text', 'value': null});
    expect(app.variables['reply'], {'type': 'map', 'value': null});
    expect((app.variables['txns']!['value']! as List).length, 2, reason: 'a comma after the last item is read');
    // A formula with no type is a name for the formula, whichever is written first.
    expect(app.variables['spent'], {notationInlineFormulaKey: 'sum(txns,t=>t.amount)'});
    expect(app.variables['left'], {notationInlineFormulaKey: 'income-(sum(txns,t=>t.amount))'});
    // A typed one is a variable of the document, with the formulas it names written out.
    expect(app.variables['rate'], {'type': 'decimal', 'formula': '(income-(sum(txns,t=>t.amount)))/12'});
    expect(app.variables['clamp01'], {'type': 'decimal', 'formula': 'min(1, max(0, v))', 'parameters': ['v']});
    expect(app.variables['count'], {'type': 'integer', 'value': 2});
    expect(app.lines, containsPair('txns', 9));
    expect(app.lines, containsPair('left', 10));
  });

  test('what is not state is an issue that says where it belongs, and is not read', () {
    final app = readNotationAppState('state a=1\nColumn\n  Text "x"\ndefine Row2 "t"\nevery 1s onTick={a=a+1}\nkey escape onPress={a=0}\nstate b=2\n', catalog: standardCatalog);
    expect(app.variables.keys, ['a', 'b']);
    expect([for (final i in app.issues) i.line], [2, 3, 4, 5, 6]);
    expect(app.issues[0].message, contains('pages/<screen>.txt'));
    expect(app.issues[1].message, contains('indented under nothing'));
    expect(app.issues[2].message, contains('components/<Word>.txt'));
    expect(app.issues[3].message, contains('runs on a page'));
    expect(app.issues[4].message, contains('runs on a page'));
    expect(app.lines['b'], 7, reason: 'the lines after keep their numbers');
  });

  test('a formula that reads itself, through another or not, is an issue', () {
    final app = readNotationAppState('state a={b+1}\nstate b={a+1}\nstate ok={n*2}\nstate n=1\n', catalog: standardCatalog);
    expect([for (final i in app.issues) (i.line, i.message.split(' ').take(4).join(' '))], [(1, 'state a reads itself'), (2, 'state b reads itself')]);
    expect(app.variables.keys, ['n', 'ok']);
  });

  test('a state written twice is said, as on a page', () {
    final app = readNotationAppState('state a=1\nstate a=2\n', catalog: standardCatalog);
    expect(app.issues.single.message, contains('written twice'));
  });

  test('half a file: a list is read as far as its items go, with no issue for its open bracket', () {
    final app = readNotationAppState('state a=1\nstate rows=[\n  {"n": 1},\n  {"n": 2},\n', catalog: standardCatalog, partial: true);
    expect(app.issues, isEmpty);
    expect(app.variables['rows']!['value'], [
      {'n': 1},
      {'n': 2},
    ]);
    // Whole, the same text says its bracket is not closed.
    expect(readNotationAppState('state rows=[\n  {"n": 1},\n', catalog: standardCatalog).issues, isNotEmpty);
  });

  test('a page reads a site formula by name, and its own state of a shared name does not replace it', () {
    final r = parseNotation(
      'state left=5\nstate income=9\nText "{left} {income}"',
      catalog: standardCatalog,
      options: const NotationOptions(projectVariables: {
        'income': {'type': 'integer', 'value': 1},
        'left': {notationInlineFormulaKey: 'income-2'},
      }),
    );
    expect(r.issues, isEmpty);
    expect(r.document['variables'], isNull);
    expect((r.document['nodes'] as Map)['text1']['props']['text'], r'${= (income-2)} ${income}');
  });

  test('a list with a comma after its last item is a list on a page too', () {
    final r = parseNotation('state rows=[1, 2, ]\nstate rec={"a": 1,}\nText "{length(rows)}"', catalog: standardCatalog);
    final vars = ((r.document['variables'] as Map).values.single as List).cast<Map>();
    expect(vars[0]['value'], [1, 2]);
    expect(vars[1]['value'], {'a': 1});
    expect(notationWithoutTrailingCommas('["a, ]", 1, ]'), '["a, ]", 1 ]');
  });

  test('a braced subtraction is a formula, not a text', () {
    final r = parseNotation('state a=5\nstate b=2\nstate left={a-b}\nstate slug=case-study\nText "{left} {slug}"', catalog: standardCatalog);
    expect((r.document['nodes'] as Map)['text1']['props']['text'], r'${= (a-b)} ${slug}');
  });

  test('a site with no manifest: home first, then by name; one that expand wrote whole is none', () {
    final site = NotationSiteFiles({
      'pages/zeta.txt': 'Text "z"',
      'pages/home.txt': 'Text "h"',
      'pages/about.txt': 'Text "a"',
      'app.txt': 'state n=1\n',
      'site/site.json': '{"pages": ["zeta.json"], "variables": {"n": 1, "old": 2}, "expand": {"all": true}}',
    }, catalog: standardCatalog);
    expect(site.hasManifest, isFalse);
    expect(site.screens, ['home', 'about', 'zeta']);
    expect(site.orderedPageSources, ['pages/home.txt', 'pages/about.txt', 'pages/zeta.txt']);
    expect(site.variables.keys, ['n']);
    expect(site.problems, isEmpty);
    expect(site.sharedDeclarations, [
      {'type': 'integer', 'name': 'n', 'value': 1},
    ]);
    expect(notationPageOrder(['b', 'home', 'a']), ['home', 'a', 'b']);
    // A manifest of the site's own lists first; the rest follow, home first.
    final listed = NotationSiteFiles({'pages/zeta.txt': '', 'pages/home.txt': '', 'pages/about.txt': '', 'site.json': '{"pages": ["zeta.json"]}'}, catalog: standardCatalog);
    expect(listed.screens, ['zeta', 'home', 'about']);
  });
}
