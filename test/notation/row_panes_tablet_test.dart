// A window of panes written as a Row whose own width rules are a phone's
// only (`hide=phone`): on a tablet the pane that grows would be narrower than
// a readable width (320), so the first pane goes with its splitter, as an
// App's panes do, and the two nearest stay.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

const _page = NotationOptions(width: 1440);

NotationResult _read(String text) {
  final r = Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog, options: _page));
  expect(r.issues, isEmpty, reason: '${r.issues}');
  return r;
}

List<Object?> _media(NotationResult r, String id) => (((r.document['nodes'] as Map)[id] as Map)['media'] as List?) ?? const [];

bool _hiddenOnTablet(NotationResult r, String id) => _media(r, id).any((m) =>
    m is Map && m['maxWidth'] == 1023 && (m['patch'] as Map?)?['visible'] == false);

const _mail = '''
state paneA=232
state paneB=380
Column h=fill
  Row#window grow stretch hide=phone
    Column#folders w={paneA}
      Text "Inbox"
    Splitter#sa @paneA min=180 max=320
    Column#list w={paneB}
      Text "Messages"
    Splitter#sb @paneB min=280 max=560
    Column#read grow
      Text "Reading"
  Column#phone grow show=phone
    Text "One at a time"
''';

void main() {
  test('three panes that leave the growing one 156 of a tablet: the first and its splitter go there', () {
    final r = _read(_mail);
    expect(_hiddenOnTablet(r, 'folders'), isTrue, reason: '${_media(r, 'folders')}');
    expect(_hiddenOnTablet(r, 'sa'), isTrue, reason: '${_media(r, 'sa')}');
    // The two nearest stay: 768 - 380 leaves the reading pane 388.
    expect(_media(r, 'list'), isEmpty);
    expect(_media(r, 'sb'), isEmpty);
    expect(_media(r, 'read'), isEmpty);
  });

  test('panes that leave it a readable width are all kept', () {
    final r = _read(_mail.replaceFirst('paneA=232', 'paneA=180').replaceFirst('paneB=380', 'paneB=240'));
    for (final id in ['folders', 'sa', 'list', 'sb', 'read']) {
      expect(_media(r, id), isEmpty, reason: id);
    }
  });

  test('a pane that says its own width on a tablet: the window is the writer\'s there', () {
    final r = _read(_mail.replaceFirst('Column#folders w={paneA}', 'Column#folders w={paneA} tablet.w=64'));
    expect(_hiddenOnTablet(r, 'folders'), isFalse);
    expect(_media(r, 'list'), isEmpty);
  });

  test('written keep: as written', () {
    final r = _read(_mail.replaceFirst('Row#window grow stretch hide=phone', 'Row#window grow stretch hide=phone keep'));
    expect(_hiddenOnTablet(r, 'folders'), isFalse);
  });
}
