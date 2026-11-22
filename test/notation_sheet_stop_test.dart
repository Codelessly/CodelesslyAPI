// The stop an overlay sheet rests at, bound to a variable: `Sheet#id
// stops=[0.5,1] stop=@name` is the open action's `stopVariable`; picking a
// file and sharing are actions written by their type and fields; and each
// prints and reads back.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/levels.dart' show actionLevels;
import 'package:test/test.dart';

NotationResult _parse(String text) => parseNotation(text, catalog: standardCatalog);

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

List<Map<String, Object?>> _run(NotationResult r, String id) => [
      for (final reaction in (_node(r, id)['actions'] as List?) ?? const [])
        for (final a in (reaction as Map)['actions'] as List) (a as Map).cast<String, Object?>(),
    ];

/// [text] printed, and the print read and printed again.
(String, String) _twice(String text) {
  final first = _parse(text);
  expect(first.issues, isEmpty, reason: '${first.issues.map((i) => i.message)}');
  final printed = printNotation(first.document, catalog: standardCatalog);
  final second = _parse(printed);
  expect(second.issues, isEmpty, reason: '$printed\n${second.issues.map((i) => i.message)}');
  return (printed, printNotation(second.document, catalog: standardCatalog));
}

const _sheet = 'state sheetStop=0\n'
    'Column\n'
    '  Button#open "Read" onTap={open story}\n'
    '  Button#full "All" onTap={sheetStop=1}\n'
    'Sheet#story "The tide tables" stops=[0.5,1] stop=@sheetStop\n'
    '  Text "A summary" visible={sheetStop < 1}\n';

void main() {
  group('the stop a sheet rests at', () {
    test('stop=@name on a Sheet with stops is its open action\'s stopVariable', () {
      final r = _parse(_sheet);
      expect(r.issues, isEmpty, reason: '${r.issues.map((i) => i.message)}');
      final open = _run(r, 'open').single;
      expect(open['type'], 'openModal');
      expect(open['to'], 'story');
      expect(open['snapHeights'], [0.5, 1.0]);
      expect(open['stopVariable'], 'sheetStop');
      final action = ActionDef.fromJson(open, catalog: standardCatalog)! as OpenModalAction;
      expect(action.stopVariable, 'sheetStop');
      expect(action.toJson()['stopVariable'], 'sheetStop');
      expect(ActionDef.fromJson(action.toJson(), catalog: standardCatalog), action);
      expect(const OpenModalAction().toJson().containsKey('stopVariable'), isFalse);
      expect(OpenModalFields.all.map((f) => f.key), contains('stopVariable'));
    });

    test('a sheet whose highest stop is over nine tenths is as tall as that stop', () {
      expect(_run(_parse(_sheet), 'open').single['maxHeightFactor'], 1.0);
      final low = _parse('Column\n  Button#open "Read" onTap={open story}\nSheet#story stops=[0.4,0.8]\n  Text "x"\n');
      expect(_run(low, 'open').single['maxHeightFactor'], 0.9);
    });

    test('an open written after the sheet, and one in the sheet\'s own lines, carry it too', () {
      final r = _parse('state s=0\nSheet#more stops=[0.5,1] stop=@s\n  Text "x"\nColumn\n  Button#open "More" onTap={open more}\n');
      expect(_run(r, 'open').single['stopVariable'], 's');
    });

    test('the bound variable is declared', () {
      final r = _parse('Column\n  Button "Read" onTap={open story}\nSheet#story stops=[0.5,1] stop=@sheetStop\n  Text "x"\n');
      expect(r.issues.map((i) => i.message).single, contains('add state sheetStop=0'));
    });

    test('a stop that is no variable, or on a sheet without stops, says what to write', () {
      final value = _parse('Column\n  Button#open "Read" onTap={open story}\nSheet#story stops=[0.5,1] stop=0.5\n  Text "x"\n');
      expect(value.issues.map((i) => i.message).single, contains('stop=@name'));
      expect(_run(value, 'open').single.containsKey('stopVariable'), isFalse);
      final none = _parse('state s=0\nColumn\n  Button#open "Read" onTap={open story}\nSheet#story stop=@s\n  Text "x"\n');
      expect(none.issues.map((i) => i.message).single, contains('stops=[0.5,1]'));
      expect(_run(none, 'open').single.containsKey('stopVariable'), isFalse);
    });

    test('prints and reads back', () {
      final (first, second) = _twice(_sheet);
      expect(first, contains('stopVariable=sheetStop'));
      expect(second, first);
    });
  });

  group('picking a file and sharing', () {
    const page = 'state files=[]\n'
        'Column\n'
        '  Button#pick "Attach" onTap={pickFile accept="image/*,.pdf" multiple=true content=none maxSizeMB=25; files=result}\n'
        '  Button#one "Photo" onTap={pickFile; files=append(files, result)}\n'
        '  Button#share "Share" onTap={share title="Trip notes" text={length(files) + " files"} url={screen.url}; result.copied ? toast "Link copied"}\n';

    test('are written by their type and fields', () {
      final r = _parse(page);
      expect(r.issues, isEmpty, reason: '${r.issues.map((i) => i.message)}');
      expect(_run(r, 'pick').first, {'type': 'pickFile', 'accept': 'image/*,.pdf', 'multiple': true, 'content': 'none', 'maxSizeMB': 25});
      expect(_run(r, 'one').first, {'type': 'pickFile'});
      final share = _run(r, 'share').first;
      expect(share['type'], 'share');
      expect(share['title'], 'Trip notes');
      expect(share['url'], r'${screen.url}');
      expect(share['text'], r'${= length(files) + " files"}');
      final pick = ActionDef.fromJson(_run(r, 'pick').first, catalog: standardCatalog)! as PickFileAction;
      expect((pick.accept, pick.multiple, pick.content, pick.maxSizeMB), ('image/*,.pdf', true, PickedFileContent.none, 25));
      expect(ActionDef.fromJson(share, catalog: standardCatalog), isA<ShareAction>());
    });

    test('print and read back', () {
      final (first, second) = _twice(page);
      expect(first, contains('pickFile accept="image/*,.pdf" multiple=true content=none maxSizeMB=25'));
      expect(first, contains('share '));
      expect(second, first);
    });

    test('are in the media library, at the level of a download', () {
      expect(mediaCatalog.action('pickFile'), isNotNull);
      expect(mediaCatalog.action('share'), isNotNull);
      expect(coreCatalog.action('pickFile'), isNull);
      expect(actionLevels['pickFile'], actionLevels['downloadFile']);
      expect(actionLevels['share'], actionLevels['downloadFile']);
    });
  });
}
