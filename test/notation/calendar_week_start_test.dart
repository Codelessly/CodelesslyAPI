// A calendar's weeks start on the day its weekStart names; with none said,
// on the locale's first day (the renderer's choice, as before).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text) => Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog));

Map _props(NotationResult r, String id) => (((r.document['nodes'] as Map)[id] as Map)['props'] as Map?) ?? const {};

void main() {
  test('weekStart is a calendar prop, empty unless said', () {
    expect(CalendarProps.weekStart.defaultValue, '');
    expect(CalendarProps.spec.props, contains(CalendarProps.weekStart));
  });

  test('Calendar weekStart=monday is read; a calendar that says none has none', () {
    final r = _parse('state day=""\nColumn\n  Calendar#a @day weekStart=monday\n  Calendar#b @day\n');
    expect(r.issues, isEmpty, reason: '${r.issues}');
    expect(_props(r, 'a')['weekStart'], 'monday');
    expect(_props(r, 'b').containsKey('weekStart'), isFalse);
  });

  test('the words read as a calendar take it too', () {
    final r = _parse('state day=""\nColumn\n  MiniCalendar#a @day weekStart=monday\n');
    expect(r.issues, isEmpty, reason: '${r.issues}');
    expect(_props(r, 'a')['weekStart'], 'monday');
  });
}
