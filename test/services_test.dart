import 'package:codelessly_api/codelessly_api.dart';
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

    test('server-written presets, owner fields and expiry', () {
      final json = {
        'collections': {'notes': 'ownerRead', 'news': 'audience', 'future': 'notYetKnown'},
        'roles': {'notes': 'support'},
        'ownerFields': {
          'notes': ['read', 'readAt', 3],
          'bad': 'read',
        },
        'expiry': {'news': ' endsAt ', 'blank': '', 'bad': 1},
      };
      final rules = DataRules.fromJson(json);
      expect(rules.collections, {'notes': DataRule.ownerRead, 'news': DataRule.audience});
      expect(rules.ownerFields, {
        'notes': ['read', 'readAt'],
      });
      expect(rules.expiry, {'news': 'endsAt'});
      expect(rules.ownerFieldsFor('notes/n1'), ['read', 'readAt']);
      expect(rules.ownerFieldsFor('news'), isEmpty);
      expect(rules.expiryFieldFor('news/n1/replies'), 'endsAt');
      expect(rules.expiryFieldFor('notes'), isNull);
      expect(DataRules.fromJson(rules.toJson()), rules);
      expect(rules.toJson()['expiry'], {'news': 'endsAt'});
      // Older JSON without the new keys writes none of them back.
      expect(const DataRules().toJson(), isEmpty);
    });

    test('rule traits', () {
      expect(DataRule.ownerRead.readsOwnOnly, isTrue);
      expect(DataRule.ownerRead.stampsOwner, isFalse);
      expect(DataRule.ownerRead.writtenByRole, isTrue);
      expect(DataRule.audience.readsAudience, isTrue);
      expect(DataRule.audience.readsOwnOnly, isFalse);
      expect(DataRule.audience.writeNeedsSignIn, isTrue);
      expect(DataRule.owner.writtenByRole, isFalse);
      expect(DataRule.roleWrite.writtenByRole, isTrue);
    });

    test('audience entries', () {
      expect(DataRules.audienceOf('u1'), ['*', 'user:u1']);
      expect(DataRules.audienceOf('u1', role: 'pro', signedIn: true), ['*', 'user:u1', 'role:pro', 'signedIn']);
      expect(DataRules.roleAudience('admin'), 'role:admin');
      expect(DataRules.neverExpires.compareTo('2999-01-01T00:00:00.000Z'), greaterThan(0));
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
