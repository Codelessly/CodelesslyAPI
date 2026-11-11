import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';
void main() {
  test('open placement round trips and exposes authoring fields', () {
    const json = {'type': 'paywall', 'operation': 'openPaywall', 'placement': r'${entryPoint}', 'offer': r'${= trial ? "trial" : "standard"}'};
    final action = ActionDef.fromJson(json)! as PaywallAction;
    expect(action.operation, PaywallOperation.openPaywall);
    expect(action.placement, r'${entryPoint}'); expect(action.toJson(), json);
    expect(PaywallFields.all.map((field) => field.key), contains('placement'));
  });

  test('open placement takes a navigation\'s transition, kept through JSON', () {
    const json = {
      'type': 'paywall',
      'operation': 'openPaywall',
      'placement': 'upgrade',
      'routeTransition': {'preset': 'coverVertical', 'durationMs': 520},
    };
    final action = ActionDef.fromJson(json)! as PaywallAction;
    expect(action.routeTransition, RouteTransition.fromJson({'preset': 'coverVertical', 'durationMs': 520}));
    expect(action.routeTransition!.durationMs, 520);
    expect(action.toJson(), json);
    const page = {'type': 'paywall', 'operation': 'openPaywall', 'placement': 'upgrade', 'transition': 'slideUp', 'transitionMs': 300, 'reverseTransitionMs': 200};
    final paged = ActionDef.fromJson(page)! as PaywallAction;
    expect((paged.transition, paged.transitionMs, paged.reverseTransitionMs), (PageTransition.slideUp, 300, 200));
    expect(paged.toJson(), page);
    // Without them: as before.
    expect((ActionDef.fromJson({'type': 'paywall', 'operation': 'restore'})! as PaywallAction).toJson(), {'type': 'paywall', 'operation': 'restore'});
    expect(PaywallFields.all.map((field) => field.key), containsAll(['transition', 'transitionMs', 'reverseTransitionMs', 'routeTransition']));
  });
}
