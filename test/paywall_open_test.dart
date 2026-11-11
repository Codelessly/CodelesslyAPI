import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';
void main() {
  test('open placement round trips and exposes authoring fields', () {
    const json = {'type': 'paywall', 'operation': 'openPaywall', 'placement': r'${entryPoint}'};
    final action = ActionDef.fromJson(json)! as PaywallAction;
    expect(action.operation, PaywallOperation.openPaywall);
    expect(action.placement, r'${entryPoint}'); expect(action.toJson(), json);
    expect(PaywallFields.all.map((field) => field.key), contains('placement'));
  });
}
