// A page's function named as one of the formula engine's own is never
// called (the engine's is reached first): test 9, kanban 1, where
// `state matches(c):boolean={…}` was the engine's text match, true for
// every card, with no word said.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/formula_names.dart';
import 'package:test/test.dart';

void main() {
  test('the names are the engine\'s, as tool/reference/data/formulas.json lists them', () {
    final data = jsonDecode(File('tool/reference/data/formulas.json').readAsStringSync()) as Map;
    final names = {for (final f in data['functions'] as List) (f as Map)['name'] as String};
    expect(notationFormulaFunctionNames, names);
  });

  test('a function named as one of them is said, with a name to write', () {
    final r = parseNotation('''
state cards:list=[]
state matches(c):boolean={!c.archived}
Column
  Text "{count(cards, c => matches(c))}"
''', catalog: standardCatalog);
    expect(r.issues.map((i) => i.message).join('\n'), contains('state myMatches(c):boolean={…}'));
    expect(r.issues.single.line, 2);
  });

  test('a function of another name, and a plain variable named as one, are not', () {
    final r = parseNotation('''
state count=0
state isLate(c):boolean={c.due != ''}
Column
  Text "{count}"
''', catalog: standardCatalog);
    expect(r.issues, isEmpty);
  });
}
