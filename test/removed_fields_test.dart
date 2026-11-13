// Fields the SDK never read were removed (CHANGELOG, "Removed"). A document
// written before still carries their keys: it decodes, the rest of the
// object is intact, and the key is dropped on re-encode (triggers and
// actions keep no unknown keys).
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a trigger with lookaheadMs decodes; the key is dropped', () {
    const json = {'type': 'clock', 'every': r'${60000 / bpm}', 'runWhen': r'${playing}', 'lookaheadMs': 120};
    final t = Trigger.fromJson(json)!;
    expect(t.type, TriggerType.clock);
    expect(t.every, r'${60000 / bpm}');
    expect(t.runWhen, r'${playing}');
    expect(t.toJson(), {'type': 'clock', 'every': r'${60000 / bpm}', 'runWhen': r'${playing}'});
    expect(t, Trigger.fromJson(t.toJson()));
    // Malformed: still no throw.
    expect(Trigger.fromJson({'type': 'clock', 'lookaheadMs': 'soon'})!.type, TriggerType.clock);
    expect(TriggerFields.all.map((f) => f.key), isNot(contains('lookaheadMs')));
  });

  test('a cloudData action with deleteSubcollections decodes; the key is dropped and reported', () {
    const json = {
      'type': 'cloudData',
      'operation': 'delete',
      'collection': 'lists',
      'id': r'${item.id}',
      'deleteSubcollections': ['items'],
      'resultVariable': 'gone',
    };
    final a = ActionDef.fromJson(json)! as CloudDataAction;
    expect(a.operation, CloudDataOperation.delete);
    expect(a.collection, 'lists');
    expect(a.id, r'${item.id}');
    expect(a.resultVariable, 'gone');
    expect(a.toJson(), {...json}..remove('deleteSubcollections'));
    expect(ActionDef.fromJson({...json, 'deleteSubcollections': 7}), isA<CloudDataAction>());
    // Tools that refuse keys an action doesn't have now name it.
    expect(ActionSpecs.unknownKeys(json), ['deleteSubcollections']);
    expect(CloudDataFields.all.map((f) => f.key), isNot(contains('deleteSubcollections')));
  });
}
