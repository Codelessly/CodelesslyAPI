// The pages of one notation text (lib/src/core/notation/pages.dart): each
// `### Name` line starts a page; what is before the first is the app's; a
// page's text keeps every line at its number; definitions and shared state
// hold on every page; `go page` names another page; and the prompt's rule
// that teaches it.
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

const _app = '''
state user="Ada"
define Stat "label" value="0"
  Column gap=2
    Text.caption "{label}"
    Text.strong "{value}"

### Home
state count=1
Column gap=8
  Text "Hello {user}"
  Stat "Count" value="{count}"
  Button "Budgets" onTap={go budgets}

### Budgets
Column gap=8
  Stat "Spent" value="12"
  Text "{count} of them"
  Button "Back" onTap={go home}
''';

NotationResult _read(NotationPages pages, NotationPage page) => parseNotation(
      page.text,
      options: NotationOptions(width: 390, screen: page.id).withScreens(pages.ids),
      definitions: pages.definitions,
    );

List<Map<String, Object?>> _actions(Object? v, [List<Map<String, Object?>>? out]) {
  out ??= [];
  if (v is Map) {
    if (v['type'] == 'navigate') out.add(v.cast<String, Object?>());
    for (final c in v.values) {
      _actions(c, out);
    }
  } else if (v is List) {
    for (final c in v) {
      _actions(c, out);
    }
  }
  return out;
}

void main() {
  test('a text with no ### line is one page, its text as written', () {
    const text = 'state n=1\nColumn\n  Text "{n}"\n';
    final pages = notationPages(text);
    expect(pages.headed, isFalse);
    expect(pages.pages, hasLength(1));
    expect(pages.pages.single.text, text);
    expect(pages.pages.single.id, 'screen');
    expect(pages.pages.single.heading, isNull);
    expect(pages.definitions, isNull);
    expect(notationPages('').pages.single.text, '');
  });

  test('each ### line starts a page; names, ids and lines', () {
    final pages = notationPages(_app);
    expect(pages.headed, isTrue);
    expect([for (final p in pages.pages) p.name], ['Home', 'Budgets']);
    expect(pages.ids, ['home', 'budgets']);
    expect(pages.shared, 6);
    final home = pages.pages[0], budgets = pages.pages[1];
    expect(home.heading, 7);
    expect(home.from, 8);
    expect(home.to, 13);
    expect(budgets.heading, 14);
    expect(pages.at(1), isNull, reason: 'the app\'s lines are no page\'s');
    expect(pages.at(7), same(home));
    expect(pages.at(11), same(home));
    expect(pages.at(16), same(budgets));
    expect(pages.named('BUDGETS'), same(budgets));
    expect(pages.named('home'), same(home));
    expect(pages.named('nope'), isNull);
  });

  test('a page\'s text keeps every line at its number and blanks the others', () {
    final pages = notationPages(_app);
    final all = _app.split('\n');
    for (final page in pages.pages) {
      final lines = page.text.split('\n');
      expect(lines, hasLength(all.length));
      for (var i = 0; i < lines.length; i++) {
        expect(lines[i].isEmpty || lines[i] == all[i], isTrue, reason: 'line ${i + 1} of ${page.name}');
      }
      expect(lines[0], 'state user="Ada"', reason: 'the app\'s state is every page\'s');
      expect(lines.any((l) => l.startsWith('###')), isFalse);
    }
    expect(pages.pages[0].text, isNot(contains('Spent')));
    expect(pages.pages[1].text, isNot(contains('Hello')));
  });

  test('ids are unique, and a name that starts with a digit gets a letter', () {
    final pages = notationPages('### Cook mode\nColumn\n### Cook mode\nColumn\n### 404\nColumn\n### What\'s on\nColumn\n');
    expect(pages.ids, ['cook-mode', 'cook-mode-2', 's-404', 'whats-on']);
  });

  test('lines of a page before the first ### are a page of their own', () {
    final pages = notationPages('Column\n  Text "home"\n### Other\nColumn\n', fallback: 'Start');
    expect([for (final p in pages.pages) p.name], ['Start', 'Other']);
    expect(pages.shared, 0);
    expect(pages.pages[0].heading, isNull);
    expect(pages.pages[0].from, 1);
    expect(pages.pages[0].to, 2);
  });

  test('a page with no line yet is a page (a stream that just crossed its heading)', () {
    final pages = notationPages('### Home\nColumn\n### Budgets\n');
    expect([for (final p in pages.pages) p.name], ['Home', 'Budgets']);
    expect(pages.pages[1].text.trim(), isEmpty);
  });

  test('every page reads the app\'s definitions and state, with no issue', () {
    final pages = notationPages(_app);
    for (final page in pages.pages) {
      final r = _read(pages, page);
      expect(r.issues, isEmpty, reason: '${page.name}: ${r.issues.map((i) => '${i.line}: ${i.message}').join('; ')}');
      expect(r.document['roots'], [page.id]);
      final names = [
        for (final scope in (r.document['variables'] as Map).values)
          for (final v in scope as List) (v as Map)['name'],
      ];
      expect(names, contains('user'));
      // Stat is written out as its definition's lines on both pages.
      expect(r.vocabulary.where((u) => u.kind == 'definition' && u.word == 'Stat'), isNotEmpty, reason: page.name);
    }
  });

  test('a definition written after the last page holds on the first', () {
    final pages = notationPages('### One\nColumn\n  Chip2 "a"\n### Two\nColumn\n  Chip2 "b"\n\ndefine Chip2 "text"\n  Text "{text}"\n');
    for (final page in pages.pages) {
      final r = _read(pages, page);
      expect(r.issues, isEmpty, reason: page.name);
      expect(r.vocabulary.where((u) => u.kind == 'definition' && u.word == 'Chip2'), isNotEmpty, reason: page.name);
    }
    expect(pages.definitions!.split('\n')[7], 'define Chip2 "text"');
    expect(pages.definitions, isNot(contains('Column')));
  });

  test('a state one page declares is another\'s when it uses it', () {
    final pages = notationPages(_app);
    final budgets = pages.pages[1];
    expect(budgets.text.split('\n')[7], 'state count=1');
    final r = _read(pages, budgets);
    final names = [
      for (final scope in (r.document['variables'] as Map).values)
        for (final v in scope as List) (v as Map)['name'],
    ];
    expect(names, containsAll(['user', 'count']));
  });

  test('go names another page by its id', () {
    final pages = notationPages(_app);
    final home = _read(pages, pages.pages[0]);
    final budgets = _read(pages, pages.pages[1]);
    expect(_actions(home.document).single['to'], 'budgets');
    expect(_actions(budgets.document).single['to'], 'home');
  });

  test('an issue of a page is at its line of the whole text', () {
    const text = '### One\nColumn\n  Text "a"\n### Two\nColumn\n  Text "b" nope=\n';
    final pages = notationPages(text);
    expect(_read(pages, pages.pages[0]).issues, isEmpty);
    final issues = _read(pages, pages.pages[1]).issues;
    expect(issues, isNotEmpty);
    expect(issues.first.line, 6);
    expect(pages.at(issues.first.line)!.name, 'Two');
  });

  test('the prompt teaches pages only when asked', () {
    final plain = notationPrompt(options: const NotationOptions(width: 1280));
    final paged = notationPrompt(options: const NotationOptions(width: 1280), pages: true);
    expect(plain, isNot(contains('### Home')));
    expect(paged, contains(notationPagesRule));
    expect(paged.replaceFirst('\n$notationPagesRule', ''), plain);
    // In the open prompt the rule takes the place of its line on screens.
    final open = notationPrompt(options: const NotationOptions(width: 1280), open: true, pages: true);
    expect(open, contains(notationPagesRule));
    expect(open, isNot(contains('- Several screens: each starts at a ### line')));
  });

  test('the rule\'s own example reads with no issue', () {
    const text = '### Home\nColumn gap=8\n  BudgetRow "Groceries" spent=320 limit=400\n\ndefine BudgetRow "name" spent=0 limit=100\n  Row gap=6\n    Text "{name}"\n    Text "{spent} of {limit}"\n';
    final pages = notationPages(text);
    expect(_read(pages, pages.pages.single).issues, isEmpty);
  });
}
