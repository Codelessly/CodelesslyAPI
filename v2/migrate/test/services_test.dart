import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

/// A v1 `HttpApiData` as SDK 8.x stores it in a publish model.
Map<String, Object?> v1Api({bool deleted = false}) => {
      'owner': 'o',
      'users': <String>[],
      'roles': <String, String>{},
      'teams': <String>[],
      'public': false,
      'id': 'tides',
      'name': 'Tides',
      'project': 'p',
      'method': 'post',
      'url': r'https://api.example.com/data?format=json',
      'headers': [
        {'key': 'Authorization', 'value': r'Bearer ${token}', 'isUsed': true},
      ],
      'queryParams': [
        {'key': 'station', 'value': r'${station}', 'isUsed': true},
        {'key': 'unused', 'value': 'x', 'isUsed': false},
      ],
      'formFields': <Object?>[],
      'body': r'{"day": "${day}"}',
      'bodyType': 'text',
      'deleted': deleted,
      'lastUpdated': 1700000000000,
      'requestBodyContentType': 'json',
      'variables': [
        {'id': 'v1', 'name': 'station', 'type': 'text', 'value': '9414131'},
        {'id': 'v2', 'name': 'day', 'type': 'text', 'value': ''},
      ],
      'created': 1690000000000,
      'directory': 'weather',
    };

void main() {
  test('an HTTP API keeps its request and inputs, and drops privacy', () {
    expect(migrateHttpApi(v1Api()), {
      'id': 'tides',
      'name': 'Tides',
      'method': 'post',
      'url': r'https://api.example.com/data?format=json',
      'headers': [
        {'key': 'Authorization', 'value': r'Bearer ${token}'},
      ],
      'query': [
        {'key': 'station', 'value': r'${station}'},
        {'key': 'unused', 'value': 'x', 'enabled': false},
      ],
      'body': r'{"day": "${day}"}',
      'inputs': [
        {'name': 'station', 'default': '9414131'},
        {'name': 'day'},
      ],
      'v1': {'directory': 'weather', 'created': 1690000000000, 'lastUpdated': 1700000000000},
    });
  });

  test('a form API with a text content type', () {
    expect(
      migrateHttpApi({
        'name': 'Sign up',
        'method': 'put',
        'bodyType': 'form',
        'requestBodyContentType': 'xml',
        'formFields': [
          {'key': 'email', 'value': r'${email}'},
        ],
        'mystery': 1,
      }),
      {
        'name': 'Sign up',
        'method': 'put',
        'form': [
          {'key': 'email', 'value': r'${email}'},
        ],
        'bodyType': 'form',
        'contentType': 'xml',
        'mystery': 1,
      },
    );
  });

  test('a deleted API is dropped', () {
    expect(migrateHttpApi(v1Api(deleted: true)), isNull);
  });

  test('services of a publish model', () {
    final services = migrateServices({
      'projectId': 'p',
      'apis': {
        'tides': v1Api(),
        'old': v1Api(deleted: true),
        'junk': 3,
      },
      'paywall': {
        'slots': [
          {'id': 'monthly', 'iosProductId': 'm.ios', 'androidProductId': 'm.android'},
          {'id': '', 'iosProductId': 'x'},
        ],
        'placements': [
          {'id': 'onboarding', 'layoutId': 'L', 'productSlots': ['monthly']},
        ],
        'privacyUrl': 'https://x.dev/privacy',
      },
    });
    expect((services['apis'] as Map).keys, ['tides']);
    expect((services['apis'] as Map)['tides'], isNot(contains('id')));
    expect(services['paywall'], {
      'products': [
        {'id': 'monthly', 'iosProductId': 'm.ios', 'androidProductId': 'm.android'},
      ],
      'placements': [
        {'id': 'onboarding', 'layoutId': 'L', 'productSlots': ['monthly']},
      ],
      'privacyUrl': 'https://x.dev/privacy',
    });
    expect(migrateServices({'apis': {}}), isEmpty);
  });

  test('data rules', () {
    expect(
      migrateDataRules({
        'collections': {'tasks': 'owner', 'misc': 'app'},
        'schemas': {
          'tasks': {
            'name': 'tasks',
            'fields': [
              {'name': 'title', 'type': 'text', 'required': true},
              {'name': 'due', 'type': 'date', 'required': false, 'defaultValue': 'now'},
            ],
          },
        },
        'indexes': {'tasks': ['done:asc,due:desc'], 'empty': []},
        'roles': {'news': 'editor'},
      }),
      {
        'collections': {'tasks': 'owner'},
        'schemas': {
          'tasks': {
            'fields': [
              {'name': 'title', 'required': true},
              {'name': 'due', 'type': 'date', 'defaultValue': 'now'},
            ],
          },
        },
        'indexes': {'tasks': ['done:asc,due:desc']},
        'roles': {'news': 'editor'},
      },
    );
  });
}
