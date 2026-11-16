import 'package:codelessly_api/core.dart';
import 'package:codelessly_api/codelessly_api.dart' show standardCatalog;
import 'package:test/test.dart';

void main() {
  test(
    'announce action and live text round trip through the document model',
    () {
      final action = ActionDef.fromJson({
        'type': 'announce',
        'message': r'${count} results',
      });
      expect(action, isA<AnnounceAction>());
      expect(action!.toJson(), {
        'type': 'announce',
        'message': r'${count} results',
      });
      final node = Node.fromJson({
        'id': 'results',
        'type': 'text',
        'props': {'text': '3 results', 'live': true},
      })!;
      expect(node.prop(TextProps.live), isTrue);
      expect(Node.fromJson(node.toJson())!.prop(TextProps.live), isTrue);
    },
  );

  test('notation writes announce and live without JSON escape', () {
    final parsed = parseNotation('''
state count=3
Column
  Text "{count} results" live:true
  Button "Filter" -> announce "{count} results"
''', catalog: standardCatalog);
    expect(parsed.issues, isEmpty);
    final nodes = parsed.document['nodes'] as Map;
    final text = nodes.values.cast<Map>().firstWhere(
      (n) => n['type'] == 'text',
    );
    expect((text['props'] as Map)['live'], isTrue);
    final button = nodes.values.cast<Map>().firstWhere((n) => n['actions'] != null);
    final actions =
        ((button['actions'] as List).single as Map)['actions'] as List;
    expect(actions.single, {
      'type': 'announce',
      'message': r'${count} results',
    });
  });
}
