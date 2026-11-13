// The library split, checked on the import graph (pure Dart: it reads the
// import, export and part directives under lib/; no analyzer):
//
//   lib/src/core/            the model: nodes, layout, values, widgets,
//                            behaviors, triggers, core actions, Catalog
//   lib/src/features/<x>/    data, auth, commerce, media, engage, publish,
//                            managed: each over the core
//   lib/src/*.dart           the umbrella (standardCatalog, ServiceConfig)
//
// (1) a core file imports only core files, `dart:` and package:meta and
//     package:collection; (2) a feature file imports the core, its own
//     directory and the features [_dependsOn] lists for it, nothing else;
//     (3) each entry library's import closure stays inside what it may
//     reach, so `package:codelessly_api/core.dart` compiles no feature;
//     (4) decoding with the core catalog keeps feature types whole.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

final _directive = RegExp(r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''', multiLine: true);

/// lib-relative path → what it imports, exports or includes.
final Map<String, List<String>> _uris = {
  for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')))
    f.path.replaceAll(r'\', '/'): [for (final m in _directive.allMatches(f.readAsStringSync())) m[1]!],
};

/// The lib file [uri] names from [file], or the URI itself for `dart:` and
/// other packages.
String _resolve(String file, String uri) {
  const self = 'package:codelessly_api/';
  if (uri.startsWith(self)) return 'lib/${uri.substring(self.length)}';
  if (uri.contains(':')) return uri;
  return File(file).parent.uri.resolve(uri).path.replaceFirst(RegExp(r'^.*?(?=lib/)'), '');
}

Iterable<String> _targets(String file) => [for (final u in _uris[file] ?? const <String>[]) _resolve(file, u)];

String? _featureOf(String file) => RegExp(r'^lib/src/features/([^/]+)/').firstMatch(file)?[1];
bool _isCore(String file) => file.startsWith('lib/src/core/');

/// Which other features a feature may import (the proposal's table: a
/// managed component's payload is a published layout; automations are kept
/// in the publish model).
const Map<String, Set<String>> _dependsOn = {
  'managed': {'publish'},
  'engage': {'publish'},
};

/// Imports the rules refuse, kept until removed: file → target → why. Empty.
const Map<String, Map<String, String>> _exceptions = {};

const _packagesAllowed = {'package:meta/', 'package:collection/'};

bool _external(String target) => target.startsWith('dart:') || target.startsWith('package:');

Set<String> _closure(String entry) {
  final seen = <String>{};
  final queue = [entry];
  while (queue.isNotEmpty) {
    final f = queue.removeLast();
    if (!seen.add(f) || _external(f)) continue;
    queue.addAll(_targets(f));
  }
  return seen;
}

void main() {
  test('the import graph was read', () {
    expect(_uris.keys.where(_isCore).length, greaterThan(40));
    expect(_uris.keys.where((f) => _featureOf(f) != null).map(_featureOf).toSet(),
        {'data', 'auth', 'commerce', 'media', 'engage', 'publish', 'managed'});
  });

  test('(1) the core imports nothing but the core', () {
    final bad = [
      for (final file in _uris.keys.where(_isCore))
        for (final to in _targets(file))
          if (!(_external(to) ? (to.startsWith('dart:') || _packagesAllowed.any(to.startsWith)) : _isCore(to)))
            if (!(_exceptions[file]?.containsKey(to) ?? false)) '$file -> $to',
    ];
    expect(bad, isEmpty);
  });

  test('(2) a feature imports the core, itself and its listed dependencies', () {
    final bad = [
      for (final file in _uris.keys)
        if (_featureOf(file) case final String feature)
          for (final to in _targets(file))
            if (!_external(to) && !_isCore(to) && _featureOf(to) != feature && !(_dependsOn[feature] ?? const {}).contains(_featureOf(to)))
              if (!(_exceptions[file]?.containsKey(to) ?? false)) '$file -> $to',
    ];
    expect(bad, isEmpty);
    // Package imports in features: the same two as the core.
    final packages = [
      for (final file in _uris.keys.where((f) => _featureOf(f) != null))
        for (final to in _targets(file))
          if (to.startsWith('package:') && !_packagesAllowed.any(to.startsWith)) '$file -> $to',
    ];
    expect(packages, isEmpty);
  });

  test('(3) core.dart compiles no feature; each feature library only itself and its dependencies', () {
    final core = _closure('lib/core.dart');
    expect(core.where((f) => !_external(f) && !_isCore(f) && f != 'lib/core.dart'), isEmpty);
    for (final feature in ['data', 'auth', 'commerce', 'media', 'engage', 'publish', 'managed']) {
      final reach = _closure('lib/$feature.dart');
      final allowed = {feature, ...?_dependsOn[feature]};
      final bad = [
        for (final f in reach)
          if (_featureOf(f) case final String other when !allowed.contains(other)) f,
      ];
      expect(bad, isEmpty, reason: feature);
      expect(reach, isNot(contains('lib/src/standard_catalog.dart')), reason: feature);
    }
    // The umbrella is everything.
    final all = _closure('lib/codelessly_api.dart');
    expect(all, containsAll(['lib/src/standard_catalog.dart', 'lib/src/features/managed/managed_components.dart']));
    expect(_exceptions, isEmpty);
  });

  test('(4) with the core catalog, feature types decode whole and re-encode byte for byte', () {
    final json = {
      'schema': 2,
      'roots': ['c'],
      'nodes': {
        'c': {'type': 'canvas', 'children': ['v'], 'layout': {}},
        'v': {
          'type': 'video',
          'layout': {'width': {'fixed': 320}},
          'props': {'url': 'https://example.com/a.mp4', 'loop': true, 'fit': 'cover'},
          'actions': [
            {'trigger': {'type': 'click'}, 'actions': [{'type': 'auth', 'operation': 'signIn', 'email': r'${email}'}]},
          ],
        },
      },
    };
    final core = LayoutDocument.fromJson(json, catalog: Catalog.core);
    final video = core['v']!;
    expect(video.spec, isNull);
    final action = video.actions.single.actions.single;
    expect(action, isA<UnknownAction>());
    expect(jsonEncode(core.toJson()), jsonEncode(LayoutDocument.fromJson(core.toJson(), catalog: Catalog.core).toJson()));
    final standard = LayoutDocument.fromJson(json, catalog: standardCatalog);
    expect(jsonEncode(core['v']!.toJson()), jsonEncode(standard['v']!.toJson()));
    // Code that knows the type still reads its props, and the action
    // becomes typed in a catalog that declares it.
    expect(video.prop(VideoProps.url), 'https://example.com/a.mp4');
    expect(video.prop(VideoProps.loop), isTrue);
    expect(standardCatalog.upgrade(action), isA<AuthAction>());
  });
}
