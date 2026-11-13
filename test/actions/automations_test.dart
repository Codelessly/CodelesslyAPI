import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('an automation', () {
    test('round-trips every field and writes nothing at the defaults', () {
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

    test('with bad values still decodes, and one without an id is left out', () {
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

    test('is kept by the publish model, and a model without any is unchanged', () {
      final plain = {'schema': 3, 'projectId': 'p', 'layouts': <String, Object?>{}};
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

  });

}
