import 'package:codelessly_api_v2/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('HttpApi', () {
    test('decodes, round-trips sparse and keeps unknown keys', () {
      final json = <String, Object?>{
        'id': 'tides',
        'name': 'Tides',
        'method': 'post',
        'url': r'https://api.example.com/tides?d=${day}',
        'headers': [
          {'key': 'Authorization', 'value': r'Bearer ${token}'},
          {'key': 'X-Off', 'value': '1', 'enabled': false},
        ],
        'query': [
          {'key': 'station', 'value': r'${station}'},
        ],
        'body': r'{"day": "${day}"}',
        'inputs': [
          {'name': 'station', 'default': '9414131'},
          {'name': 'day'},
        ],
        'future': 1,
      };
      final api = HttpApi.fromJson(json);
      expect(api.method, HttpMethod.post);
      expect(api.headers.last.isSent, isFalse);
      expect(api.input('station')!.defaultValue, '9414131');
      expect(api.contentType, HttpContentType.json);
      expect(api.extra, {'future': 1});
      expect(api.toJson(), json);
      expect(HttpApi.fromJson(api.toJson()), api);
      expect(const HttpApi().toJson(), isEmpty);
    });

    test('never throws on bad values', () {
      final api = HttpApi.fromJson({
        'method': 'teleport',
        'url': 3,
        'headers': 'x',
        'query': [1, null, {'key': 'a', 'value': 2}],
        'inputs': [{'name': ''}, 'x'],
      });
      expect(api.method, HttpMethod.get);
      expect(api.url, '');
      expect(api.headers, isEmpty);
      expect(api.query, [const HttpParam('a', '2')]);
      expect(api.inputs, isEmpty);
      expect(HttpApi.fromJson(null), const HttpApi());
    });
  });

  group('CloudQueryDef', () {
    test('reads the list query shape', () {
      final json = <String, Object?>{
        'enabled': true,
        'collectionPath': r'users/${auth.uid}/tasks',
        'limit': 20,
        'whereFilters': [
          {'field': 'done', 'operator': 'equal', 'value': 'false'},
          {'field': 'tags', 'operator': 'arrayContainsAny', 'value': '["a"]'},
        ],
        'orderByFilters': [
          {'field': 'due', 'sortOrder': 'descending'},
          {'field': 'name'},
        ],
        'paging': 'button',
        'loadRelated': ['author'],
        'statusVariable': {'name': 'status'},
      };
      final q = CloudQueryDef.fromJson(json);
      expect(q.where.last.operator.takesList, isTrue);
      expect(q.orderBy.first.descending, isTrue);
      expect(q.paging, QueryPaging.button);
      expect(q.extra.keys, ['statusVariable']);
      expect(q.toJson(), json);
      expect(CloudQueryDef.fromJson({'limit': 0}).limit, isNull);
    });

    test('operators classify like Firestore', () {
      expect(WhereOperator.notEqual.isInequality, isTrue);
      expect(WhereOperator.inArray.isEquality, isTrue);
      expect(WhereOperator.lessThan.symbol, '<');
    });
  });

  group('DataRules', () {
    final rules = DataRules.fromJson({
      'collections': {'tasks': 'owner', 'posts': 'publicReadOwnerWrite', 'bad': 'nope'},
      'schemas': {
        'tasks': {
          'fields': [
            {'name': 'title', 'required': true},
            {'name': 'due', 'type': 'date', 'defaultValue': 'now'},
            {'name': 'author', 'type': 'reference', 'referenceCollection': 'users'},
          ],
        },
      },
      'indexes': {
        'tasks': ['done:asc,due:desc'],
      },
      'roles': {'news': 'editor'},
    });

    test('decodes and round-trips', () {
      expect(rules.collections, {'tasks': DataRule.owner, 'posts': DataRule.publicReadOwnerWrite});
      expect(rules.schemas['tasks']!.field('due')!.type, SchemaFieldType.date);
      expect(DataRules.fromJson(rules.toJson()), rules);
    });

    test('names collections by path', () {
      expect(DataRules.collectionName('users/u1/tasks'), 'tasks');
      expect(DataRules.collectionName(r'users.${auth.uid}'), 'users');
      expect(DataRules.collectionName(''), isNull);
      expect(DataRules.topCollection(''), 'default');
      expect(rules.ruleFor('tasks/t1/notes'), DataRule.owner);
      expect(rules.ruleFor('other'), DataRule.app);
      expect(rules.schemaFor('users/u1/tasks')!.name, 'tasks');
      expect(rules.readyIndexesFor('tasks'), {'done:asc,due:desc'});
    });
  });

  group('paywall and service config', () {
    test('round-trip and look up', () {
      final json = <String, Object?>{
        'apis': {
          'tides': {'name': 'Tides', 'url': 'https://x.dev'},
        },
        'paywall': {
          'products': [
            {'id': 'monthly', 'iosProductId': 'm.ios', 'androidProductId': 'm.android'},
            {'id': 'annual', 'iosProductId': 'a.ios'},
          ],
          'placements': [
            {'id': 'onboarding', 'layoutId': 'L', 'productSlots': ['annual', 'monthly', 'gone']},
          ],
          'termsUrl': 'https://x.dev/terms',
        },
      };
      final config = ServiceConfig.fromJson(json);
      expect(config.apis['tides']!.id, 'tides');
      final paywall = config.paywall;
      expect(paywall.slotsOf(paywall.placement('onboarding')!).map((s) => s.id), ['annual', 'monthly']);
      expect(paywall.product('monthly')!.productIdFor('android'), 'm.android');
      expect(config.toJson(), json);
      expect(ServiceConfig.fromJson(config.toJson()), config);
      expect(ServiceConfig.fromJson('junk').toJson(), isEmpty);
    });
  });
}
