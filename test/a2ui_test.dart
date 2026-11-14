// A2UI v1.0 messages in front of the notation (design 13 §7): the same
// renderer and defaults draw what an A2UI-tuned model writes.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/levels.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

const _stream = r'''
{"version":"1.0","createSurface":{"surfaceId":"settings","catalogId":"https://a2ui.org/specification/v1_0/catalogs/basic/catalog.json"}}
{"version":"1.0","updateComponents":{"surfaceId":"settings","components":[{"id":"root","component":"Card","child":"col"},{"id":"col","component":"Column","children":["title","name_field","volume","agree","plan","people","save_btn"]},{"id":"title","component":"Text","text":"Settings"},{"id":"name_field","component":"TextField","label":"Name","value":{"@path":"/user/name"}},{"id":"volume","component":"Slider","label":"Volume","value":{"@path":"/user/volume"},"min":0,"max":100},{"id":"agree","component":"CheckBox","label":"I agree","value":{"@path":"/user/agree"}},{"id":"plan","component":"ChoicePicker","label":"Plan","options":[{"label":"Free","value":"free"},{"label":"Pro","value":"pro"}],"value":{"@path":"/user/plan"}},{"id":"people","component":"List","children":{"path":"/people","componentId":"person"}},{"id":"person","component":"Row","justify":"spaceBetween","children":["pname","page"]},{"id":"pname","component":"Text","text":{"@path":"name"}},{"id":"page","component":"Text","variant":"caption","text":{"@path":"age"}},{"id":"save_label","component":"Text","text":"Save"},{"id":"save_btn","component":"Button","child":"save_label","variant":"primary","action":{"event":{"name":"saveSettings","context":{"name":{"@path":"/user/name"},"source":"card"}}}}]}}
{"version":"1.0","updateDataModel":{"surfaceId":"settings","path":"/user","value":{"name":"Ada","volume":50,"agree":false}}}
{"version":"1.0","updateDataModel":{"surfaceId":"settings","path":"/people","value":[{"name":"Ada","age":36},{"name":"Grace","age":45}]}}
''';

void main() {
  test('a card of A2UI controls bound to its data model becomes a document that validates at the state level', () {
    final r = parseA2ui(_stream, catalog: standardCatalog);
    printOnFailure(r.notation);
    expect(r.issues, isEmpty, reason: '${r.issues}');
    expect(r.notes, isEmpty);
    final problems = [
      for (final d in Catalog.run(standardCatalog, () => validateDocument(r.document, options: const ValidateOptions(level: Level.state))))
        if (d.severity == Severity.error) '${d.code.name} ${d.path}: ${d.message}',
    ];
    expect(problems, isEmpty);
    final nodes = (r.document['nodes'] as Map).cast<String, Map>();
    final types = {for (final n in nodes.values) n['type']};
    expect(types, containsAll(['textField', 'slider', 'checkbox', 'segmentedButton', 'listView', 'filledButton']));
    // The data model is state: a bound path is a variable with its value.
    final vars = {for (final v in (r.document['variables'] as Map)['screen'] as List) (v as Map)['name']: v['value']};
    expect(vars['user_name'], 'Ada');
    expect(vars['user_volume'], 50);
    expect(vars['people'], hasLength(2));
    // The field is bound two ways; the button tells the host with its context.
    final field = nodes.values.firstWhere((n) => n['type'] == 'textField');
    expect((field['bind'] as Map).values.single, r'${user_name}');
    final button = nodes.values.firstWhere((n) => n['type'] == 'filledButton');
    expect(((button['actions'] as List).single as Map)['actions'], [
      {'type': 'componentEvent', 'event': 'saveSettings', 'value': {'name': r'${user_name}', 'source': 'card'}},
    ]);
    // A template's relative path reads the item.
    expect(nodes.values.any((n) => (n['props'] as Map?)?['text'] == r'${item.name}'), isTrue);
  });

  test('what has no counterpart yet is laid out in place and said', () {
    final r = parseA2ui('''
{"version":"1.0","createSurface":{"surfaceId":"s","components":[{"id":"root","component":"Tabs","tabs":[{"title":"One","child":"a"},{"title":"Two","child":"b"}]},{"id":"a","component":"Text","text":"First"},{"id":"b","component":"Video","url":"https://example.com/v.mp4"}]}}
''', catalog: standardCatalog);
    expect(r.issues, isEmpty, reason: '${r.issues}\n${r.notation}');
    expect(r.notes, hasLength(2));
  });

  test('a choice whose options are sentences is a list of radios; short ones stay a segmented control', () {
    const long = r'''
{"version":"1.0","createSurface":{"surfaceId":"s","catalogId":"https://a2ui.org/specification/v1_0/catalogs/basic/catalog.json","components":[{"id":"root","component":"Column","children":["pick","size"]},{"id":"pick","component":"ChoicePicker","label":"Flight","variant":"mutuallyExclusive","value":{"@path":"/flight"},"options":[{"label":"06:45 to 09:10, TAP Air Portugal, direct","value":"f1"},{"label":"10:30 to 12:55, British Airways, direct","value":"f2"}]},{"id":"size","component":"ChoicePicker","variant":"mutuallyExclusive","value":{"@path":"/size"},"options":[{"label":"S","value":"s"},{"label":"M","value":"m"},{"label":"L","value":"l"}]}]}}
''';
    final r = parseA2ui(long, catalog: standardCatalog);
    expect(r.issues, isEmpty, reason: '${r.issues}');
    final nodes = (r.document['nodes'] as Map).cast<String, Map>();
    final radios = [for (final n in nodes.values) if (n['type'] == 'radio') n];
    expect([for (final n in radios) (n['props'] as Map)['value']], ['f1', 'f2']);
    expect([for (final n in radios) (n['layout'] as Map)['width']], everyElement({'fill': 0}));
    expect(nodes.values.where((n) => n['type'] == 'segmentedButton'), hasLength(1));
  });
}
