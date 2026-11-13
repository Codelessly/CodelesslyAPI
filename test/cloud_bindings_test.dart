// Cloud data bound to a layout: live aggregates, joins, bounded and
// reactive loads, batches over a list, impressions, pull to refresh.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('an old loadCloudData decodes with the defaults and re-encodes unchanged', () {
    final old = {
      'type': 'loadCloudData',
      'variable': 'tasks',
      'single': false,
      'query': {'enabled': true, 'collectionPath': 'tasks', 'status': 'x'},
    };
    final a = ActionDef.fromJson(old, catalog: standardCatalog)! as LoadCloudDataAction;
    expect((a.limit, a.aggregate, a.aggregateField, a.refreshSeconds, a.reactive), ('', CloudLoadAggregate.none, '', 0, true));
    expect(a.query.joins, isEmpty);
    expect(a.toJson(), old);
  });

  test('aggregate, limit, refresh and reactive round-trip', () {
    final json = {
      'type': 'loadCloudData',
      'variable': 'unread',
      'single': false,
      'query': {'enabled': true, 'collectionPath': 'cards'},
      'limit': r'${shown}',
      'aggregate': 'sum',
      'aggregateField': 'amount',
      'refreshSeconds': 60,
      'reactive': false,
    };
    final a = ActionDef.fromJson(json, catalog: standardCatalog)! as LoadCloudDataAction;
    expect((a.limit, a.aggregate, a.aggregateField, a.refreshSeconds, a.reactive),
        (r'${shown}', CloudLoadAggregate.sum, 'amount', 60, false));
    expect(a.toJson(), json);
    expect(ActionDef.fromJson(jsonDecode(jsonEncode(a.toJson())), catalog: standardCatalog), a);
    expect((ActionDef.fromJson({...json, 'refreshSeconds': -5}, catalog: standardCatalog)! as LoadCloudDataAction).refreshSeconds, 0);
    expect(kDefaultCloudLoadLimit, 500);
  });

  test('joins: by a key template or by a field, round-trip; incomplete ones are dropped', () {
    final query = {
      'enabled': true,
      'collectionPath': 'cards',
      'joins': [
        {'collection': 'user_state', 'as': 'state', 'id': r'${auth.uid}_${item.id}'},
        {'collection': 'comments', 'as': 'comments', 'localField': 'postId', 'foreignField': 'post', 'many': true},
      ],
    };
    final def = CloudQueryDef.fromJson(query);
    expect(def.joins, [
      const CloudJoin(collection: 'user_state', as: 'state', id: r'${auth.uid}_${item.id}'),
      const CloudJoin(collection: 'comments', as: 'comments', localField: 'postId', foreignField: 'post', many: true),
    ]);
    expect(def.extra, isEmpty, reason: 'joins are modeled, not kept as unknown keys');
    expect(def.toJson(), query);
    expect(CloudQueryDef.fromJson({'joins': [{'collection': 'x'}, {'as': 'y'}, 3]}).joins, isEmpty);
    expect(const CloudJoin(collection: 'a', as: 'b').toJson(), {'collection': 'a', 'as': 'b'});
  });

  test('a cloud batch over a list round-trips; old batches are unchanged', () {
    final json = {
      'type': 'cloudBatch',
      'steps': [
        {
          'type': 'cloudData',
          'operation': 'update',
          'collection': 'user_state',
          'id': r'${auth.uid}_${loop.item.id}',
          'fields': [
            {'field': 'readAt', 'operation': 'serverTime'},
          ],
        },
      ],
      'forEach': r'${unread}',
    };
    final a = ActionDef.fromJson(json, catalog: standardCatalog)! as CloudBatchAction;
    expect(a.forEach, r'${unread}');
    expect(a.toJson(), json);
    final old = {'type': 'cloudBatch', 'steps': <Object?>[], 'transaction': true};
    expect(ActionDef.fromJson(old, catalog: standardCatalog)!.toJson(), old);
    expect(kMaxCloudBatchWrites, 500);
  });

  test('reloadCloudData names a variable', () {
    final a = ActionDef.fromJson({'type': 'reloadCloudData', 'variable': 'cards', 'nonBlocking': true}, catalog: standardCatalog)!;
    expect(a, const ReloadCloudDataAction(variable: 'cards', nonBlocking: true));
    expect(a.toJson(), {'type': 'reloadCloudData', 'variable': 'cards', 'nonBlocking': true});
  });

  test('a trigger can wait for a node to stay in view, and run once per key', () {
    final json = {'type': 'enterViewport', 'visibleFraction': 0.5, 'visibleMs': 1000, 'onceKey': r'${item.id}'};
    final t = Trigger.fromJson(json)!;
    expect((t.visibleFraction, t.visibleMs, t.onceKey), (0.5, 1000, r'${item.id}'));
    expect(t.toJson(), json);
    expect(Trigger.fromJson({'type': 'enterViewport'})!.toJson(), {'type': 'enterViewport'});
    expect(Trigger.fromJson({'type': 'enterViewport', 'visibleMs': -3})!.visibleMs, 0);
  });

  test('a list can be pulled to refresh without pagination', () {
    expect(ListViewProps.spec.props, contains(ListViewProps.pullToRefresh));
    final n = Node.fromJson({'type': 'listView', 'props': {'pullToRefresh': true}}, id: 'l', catalog: standardCatalog)!;
    expect(n.prop(ListViewProps.pullToRefresh), isTrue);
    expect(Node.fromJson({'type': 'listView'}, id: 'l', catalog: standardCatalog)!.prop(ListViewProps.pullToRefresh), isFalse);
  });

  test('the editor fields list every new key', () {
    expect(ActionSpecs.of('reloadCloudData')!.fields.map((f) => f.key), ['variable']);
    expect(LoadCloudDataFields.all.map((f) => f.key),
        containsAll(['limit', 'aggregate', 'aggregateField', 'refreshSeconds', 'reactive']));
    expect(CloudBatchFields.all.map((f) => f.key), contains('forEach'));
    expect(TriggerFields.all.map((f) => f.key), containsAll(['visibleMs', 'onceKey']));
  });
}
