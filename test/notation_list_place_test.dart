// A list's keys for where it holds its place, its jump-to-latest button and
// the look of its pull to refresh: read from a ListView line, kept in the
// document, and printed back as written.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _read(String text) => parseNotation(text, catalog: standardCatalog, options: const NotationOptions(width: 390));

void main() {
  const text = 'state msgs=[{"id":1,"text":"Hi"}]\n'
      'Column h=400\n'
      '  ListView#chat h=fill grow data={msgs} reverse=true stickToStart=false jumpToLatest=false pullToRefresh=true refreshStyle=spinner\n'
      '    Text#msg "{item.text}"\n';

  test('the keys read into the list\'s props, with no issue', () {
    final r = _read(text);
    expect(r.issues, isEmpty);
    final props = (((r.document['nodes'] as Map)['chat'] as Map)['props'] as Map).cast<String, Object?>();
    expect(props, allOf(containsPair('stickToStart', false), containsPair('jumpToLatest', false), containsPair('refreshStyle', 'spinner')));
    final list = Node.fromJson(((r.document['nodes'] as Map)['chat'] as Map).cast(), id: 'chat')!;
    expect(list.prop(ListViewProps.stickToStart), isFalse);
    expect(list.prop(ListViewProps.jumpToLatest), isFalse);
    expect(list.prop(ListViewProps.refreshStyle), RefreshStyle.spinner);
  });

  test('they print back as written, and the defaults are not written', () {
    final printed = printNotation(_read(text).document, catalog: standardCatalog);
    expect(printed, allOf(contains('stickToStart=false'), contains('jumpToLatest=false'), contains('refreshStyle=spinner')));
    final plain = printNotation(_read(text.replaceAll(' stickToStart=false jumpToLatest=false', '').replaceAll(' refreshStyle=spinner', '')).document,
        catalog: standardCatalog);
    expect(plain, isNot(anyOf(contains('stickToStart'), contains('jumpToLatest'), contains('refreshStyle'))));
  });
}
