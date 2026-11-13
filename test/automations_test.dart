import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('Automation', () {
    test('round-trips every field, sparse at the defaults', () {
      final json = {
        'id': 'rate-us',
        'name': 'Ask for a review',
        'enabled': false,
        'trigger': 'event',
        'event': 'order_completed',
        'screen': 'home',
        'intervalMs': 5000,
        'when': 'usage.events.order_completed.count >= 3',
        'maxRuns': 1,
        'maxPerSession': 1,
        'everyDays': 7,
        'delayMs': 1500,
        'priority': 2,
        'actions': [
          {'type': 'openModal', 'to': 'rate-us', 'presentation': 'banner'},
        ],
        'future': {'kept': true},
      };
      final a = Automation.fromJson(json)!;
      expect(a.trigger, AutomationTrigger.event);
      expect(a.everyDays, 7);
      expect(a.actions.single, isA<OpenModalAction>());
      expect((a.actions.single as OpenModalAction).presentation, ModalPresentation.banner);
      expect(a.toJson(), json);
      expect(const Automation(id: 'x').toJson(), {'id': 'x', 'trigger': 'event'});
      expect(Automation.fromJson({'id': 'x'}), const Automation(id: 'x'));
    });

    test('never throws; entries without an id are left out', () {
      expect(Automation.fromJson(null), isNull);
      expect(Automation.fromJson({'trigger': 'appStart'}), isNull);
      expect(Automation.fromJson({'id': ''}), isNull);
      final odd = Automation.fromJson({
        'id': 'a',
        'trigger': 'later',
        'intervalMs': 1,
        'maxRuns': -3,
        'everyDays': 'x',
      })!;
      expect(odd.trigger, AutomationTrigger.event);
      expect(odd.intervalMs, 1000);
      expect(odd.maxRuns, 0);
      expect(odd.everyDays, 0);
      expect(
        Automation.listFromJson([
          {'id': 'a'},
          3,
          {'no': 'id'},
          {'id': 'b', 'trigger': 'appStart'},
        ]).map((a) => a.id),
        ['a', 'b'],
      );
    });

    test('a publish model keeps them in extra: a model without any is unchanged', () {
      final plain = {'schema': 2, 'projectId': 'p', 'layouts': <String, Object?>{}};
      final model = PublishModel.fromJson(plain);
      expect(model.automations, isEmpty);
      expect(model.toJson(), plain);
      final withOne = model.withAutomations([const Automation(id: 'hello', trigger: AutomationTrigger.appStart)]);
      expect(withOne.toJson()['automations'], [
        {'id': 'hello', 'trigger': 'appStart'},
      ]);
      final decoded = PublishModel.fromJson(withOne.toJson());
      expect(decoded.automations.single.trigger, AutomationTrigger.appStart);
      expect(decoded.toJson(), withOne.toJson());
      expect(decoded.withAutomations(const []).toJson(), plain);
    });

    test('fields declare every key with its default', () {
      final keys = {for (final f in AutomationFields.all) f.key};
      expect(
        keys,
        containsAll(
          const Automation(
            id: 'x',
            name: 'n',
            event: 'e',
            screen: 's',
            when: 'w',
            maxRuns: 1,
            maxPerSession: 1,
            everyDays: 1,
            delayMs: 1,
            priority: 1,
            intervalMs: 2000,
            enabled: false,
            actions: [DelayAction()],
          ).toJson().keys,
        ),
      );
      for (final f in AutomationFields.all) {
        if (f.defaultValue == null || f.key == 'id' || f.key == 'trigger') continue;
        final defaults = Automation.fromJson({'id': 'x'})!.toJson();
        expect(defaults.containsKey(f.key), isFalse, reason: f.key);
      }
    });
  });

  group('app event and capture actions', () {
    test('emitEvent round-trips', () {
      final json = {
        'type': 'emitEvent',
        'event': 'signed_up',
        'props': {'plan': r'${plan}'},
      };
      final a = ActionDef.fromJson(json, catalog: standardCatalog)! as EmitEventAction;
      expect(a.event, 'signed_up');
      expect(a.toJson(), json);
      expect(const EmitEventAction(event: 'x').toJson(), {'type': 'emitEvent', 'event': 'x'});
    });

    test('captureScreenshot round-trips, sparse at the defaults', () {
      expect(const CaptureScreenshotAction().toJson(), {'type': 'captureScreenshot'});
      final json = {'type': 'captureScreenshot', 'target': 'node', 'node': 'card', 'pixelRatio': 2};
      final a = ActionDef.fromJson(json, catalog: standardCatalog)! as CaptureScreenshotAction;
      expect(a.target, CaptureTarget.node);
      expect(a.toJson(), json);
      expect(
        (ActionDef.fromJson({'type': 'captureScreenshot', 'target': 'moon'}, catalog: standardCatalog)! as CaptureScreenshotAction).target,
        CaptureTarget.layout,
      );
    });

    test('callFunction optional and cloudFiles source are sparse', () {
      const plain = {'type': 'callFunction', 'name': 'share'};
      expect(ActionDef.fromJson(plain, catalog: standardCatalog)!.toJson(), plain);
      final optional = {...plain, 'optional': true};
      expect((ActionDef.fromJson(optional, catalog: standardCatalog)! as CallFunctionAction).optional, isTrue);
      expect(ActionDef.fromJson(optional, catalog: standardCatalog)!.toJson(), optional);

      const upload = {'type': 'cloudFiles', 'path': 'shots'};
      expect(ActionDef.fromJson(upload, catalog: standardCatalog)!.toJson(), upload);
      final fromSource = {...upload, 'source': r'${shot}', 'fileName': 'bug.png'};
      final a = ActionDef.fromJson(fromSource, catalog: standardCatalog)! as CloudFilesAction;
      expect(a.source, r'${shot}');
      expect(a.toJson(), fromSource);
    });

    test('a banner modal round-trips; an unknown presentation is a dialog', () {
      final json = {
        'type': 'openModal',
        'to': 'promo',
        'presentation': 'banner',
        'alignment': [0, 1],
      };
      expect(ActionDef.fromJson(json, catalog: standardCatalog)!.toJson(), json);
      final unknown =
          ActionDef.fromJson({'type': 'openModal', 'to': 'x', 'presentation': 'hologram'}, catalog: standardCatalog)! as OpenModalAction;
      expect(unknown.presentation, ModalPresentation.dialog);
    });
  });
}
