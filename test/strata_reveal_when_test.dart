import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('reveal.when is bindable and preserves the appearance default', () {
    expect(Reveal.fromJson({})!.when, true);
    final node = Node.fromJson({
      'id': 'target',
      'type': 'box',
      'reveal': {'alignment': 0, 'duration': 100},
    })!;
    final hidden = BindPaths.apply(node, 'reveal.when', false);
    expect(hidden.behaviors.reveal!.when, false);
    expect(Reveal.fromJson(hidden.behaviors.reveal!.toJson()), hidden.behaviors.reveal);
  });
}
