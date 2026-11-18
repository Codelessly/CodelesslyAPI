// A formula whose brackets do not match is said where it is written
// (lib/src/core/notation/brackets.dart): before, the parser kept it as
// written and the engine read nothing from it, with no word (test 10's kanban
// board drew no cards).
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

List<String> said(String text) => [for (final i in notationBracketIssues(text)) '${i.line}:${i.column}: ${i.message}'];

void main() {
  test('the kanban board: one ")" too many in an each list is said, where the list ends and what is not read', () {
    const line = 'each c in sortBy(filter(cards,x=>x.col==col.id && !x.archived)),x=>col.sort=="due" ? x.due : x.o)';
    expect(said('Column\n  $line\n'), [
      '2:65: the list\'s formula ends at column 65: the "(" at column 19 is closed there, so the rest ",x=>col.sort=="due" ? x.due : x.o)" is not read, '
          'and the ")" at column 99 closes nothing. One ")" too many at column 65 or before it, or one "(" too few.',
    ]);
    final r = parseNotation('state cards=[]\nColumn\n  $line\n    Text "{c.title}"\n');
    expect(r.issues.map((i) => '${i.line}:${i.column}'), contains('3:65'));
  });

  test('every place a formula is written: a condition, a value, a {…} value, an action, a text', () {
    expect(said('if (a && b'), [startsWith('1:4: the condition: "(" at column 4 is never closed on this line')]);
    expect(said('state n=max(1,2))'), [startsWith('1:17: the value ends at column 16: ")" at column 17 closes nothing')]);
    expect(said('Text "x" w={min(a,b}'), [startsWith('1:16: the formula in {…} at column 12: "(" at column 16 is not closed before its "}" at column 20')]);
    expect(said('Button "Go" onTap={n=append(list,1; toast "x"}'), [startsWith('1:28: the actions in {…} at column 19: "(" at column 28 is not closed before its "}"')]);
    expect(said('Text "Total {sum(map(items,i=>i.n)}"'), [startsWith('1:17: the formula in {…} at column 13: "(" at column 17 is not closed before its "}"')]);
    expect(said('Row items=[1,2)'), [startsWith('1:15: this line: ")" at column 15 closes the "[" at column 11')]);
  });

  test('what is valid raises nothing: texts, a text in a text\'s {…}, formula texts, chords, a list over several lines, JSON escapes', () {
    const valid = '''
key [ onPress={n=n-1}
key ] onPress={n=n+1}
Text "a (b) [c} {d}"
Text "{coalesce(target,\\"Brand (new)\\")} added"
state k=filter(items,i=>i.name != 'a(b')
Row items=[
  1,
  2]
node {"type": "text", "props": {"text": "("}}
document {"variables": [
  {"name": "x"}]}
Button "Go" onTap={a=f(x) ? g(y) : (h(z); toast "ok")}
// a comment (with an open bracket
''';
    expect(said(valid), isEmpty);
  });

  test('a stream says the same as a whole text', () {
    const text = 'state n=0\nColumn\n  Text "{max(n,1}"\n';
    final whole = parseNotation(text).issues.map((i) => '$i').toList();
    final stream = NotationStream();
    for (final l in text.split('\n')) {
      stream.add('$l\n');
    }
    stream.close();
    expect(whole, contains(startsWith('line 3:13:')));
    expect(stream.issues.map((i) => '$i'), whole);
  });
}
