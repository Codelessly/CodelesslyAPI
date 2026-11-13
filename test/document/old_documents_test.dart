import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

import '../legacy_support.dart';

// Fields the SDK never read were removed (CHANGELOG, "Removed"). A document
// written before still carries their keys: it decodes, the rest of the
// object is intact, and the key is dropped on re-encode (triggers and
// actions keep no unknown keys).

void main() {
  group('fields that no longer exist', () {
    test('a trigger saved with a removed key still decodes, and the key is dropped', () {
      const json = {'type': 'clock', 'every': r'${60000 / bpm}', 'runWhen': r'${playing}', 'lookaheadMs': 120};
      final t = legacyTrigger(json);
      // The clock is a timer now: `every` its interval, `runWhen` its guard.
      expect(t.type, TriggerType.timer);
      expect(t.intervalMs, const Expr<int>.source(r'${60000 / bpm}'));
      expect(t.when, r'${playing}');
      expect(t.toJson(), {'type': 'timer', 'intervalMs': r'${60000 / bpm}', 'when': r'${playing}'});
      expect(t, Trigger.fromJson(t.toJson()));
      // Malformed: still no throw.
      expect(legacyTrigger({'type': 'clock', 'lookaheadMs': 'soon'}).type, TriggerType.timer);
      expect(TriggerFields.all.map((f) => f.key), isNot(contains('lookaheadMs')));
    });

    test('an action saved with a removed key still decodes, and the key is reported', () {
      const json = {
        'type': 'cloudData',
        'operation': 'delete',
        'collection': 'lists',
        'id': r'${item.id}',
        'deleteSubcollections': ['items'],
        'resultVariable': 'gone',
      };
      final a = ActionDef.fromJson(json, catalog: standardCatalog)! as CloudDataAction;
      expect(a.operation, CloudDataOperation.delete);
      expect(a.collection, 'lists');
      expect(a.id, r'${item.id}');
      expect(a.resultVariable, 'gone');
      expect(a.toJson(), {...json}..remove('deleteSubcollections'));
      expect(ActionDef.fromJson({...json, 'deleteSubcollections': 7}, catalog: standardCatalog), isA<CloudDataAction>());
      // Tools that refuse keys an action doesn't have now name it.
      expect(ActionSpecs.unknownKeys(json), ['deleteSubcollections']);
      expect(CloudDataFields.all.map((f) => f.key), isNot(contains('deleteSubcollections')));
    });
  });

  group('paints saved without a type', () {
    test('a paint without a type is an image when it has an image and a gradient when it has stops', () {
      final img = Paint.fromJson({'image': {'url': 'https://example.com/a.png', 'fit': 'fill'}})!;
      expect(img.type, PaintType.image);
      expect(img.image!.url, 'https://example.com/a.png');
      expect(img.image!.fit, BoxFit.fill);
      // The settings may sit beside the image (the form the editor API documents).
      final beside = Paint.fromJson({'image': {'url': 'u'}, 'fit': 'contain', 'repeat': 'repeat'})!;
      expect(beside.image!.fit, BoxFit.contain);
      expect(beside.image!.repeat, ImageRepeat.repeat);
      final grad = Paint.fromJson({
        'stops': [
          {'position': 0, 'color': '#FF000000'},
          {'position': 1, 'color': '#00000000'},
        ],
      })!;
      expect(grad.type, PaintType.linear);
      expect(Paint.fromJson({'color': '#FF112233'})!.type, PaintType.solid);
      // An explicit type still wins, and stored paints are unchanged.
      expect(Paint.fromJson({'type': 'radial', 'stops': grad.toJson()['stops']})!.type, PaintType.radial);
      expect(Paint.fromJson(img.toJson()), img);
    });
  });
}
