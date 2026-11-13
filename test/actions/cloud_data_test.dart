// Cloud data bound to a layout: live aggregates, joins, bounded and
// reactive loads, batches over a list, impressions, pull to refresh.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('a cloud load saved by an older version decodes with the defaults and saves unchanged', () {
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

  test('a cloud load round-trips its aggregate, limit, refresh and live settings', () {
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

  test('a join by key or by field round-trips, and an incomplete one is dropped', () {
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

  test('a cloud batch over a list round-trips, and older batches are unchanged', () {
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

}
