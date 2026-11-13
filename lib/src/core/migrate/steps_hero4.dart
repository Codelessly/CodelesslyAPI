// Schema 3 → 4: one shared-element concept, Flutter's `Hero`. Schema 3 had
// two: `hero` (a tag that flies between two screens while a navigation
// plays, Flutter's `Hero`) and `flightKey` with `flight` (a key that flies a
// node in from where the last node with the key was when it appears: a
// shared element without a navigation, which Flutter lacks). Both are a
// hero now: `flies` says when (`betweenScreens`, Flutter's; `inPlace`, the
// flight key's), `flightShuttle` is the navigation flight's look (schema 3's
// `hero.flight`), `flight` how an in-place flight moves (schema 3's node
// `flight`).
import '../json.dart';
import 'legacy_read.dart';
import 'migrate.dart';

/// `flightKey` and `flight` → `hero` (`flies: inPlace`, its `flight`);
/// `hero.flight` (a shuttle name) → `hero.flightShuttle`; the binding paths
/// that addressed them → where they went.
final heroFlightStep = MigrationStep(
  id: 'hero.flight',
  description: 'flightKey and flight → hero (flies: inPlace, flight); hero.flight → hero.flightShuttle',
  node: (n, s) {
    final bind = bindOf(n);
    final hero = n['hero'];
    final heroMap = readMap(hero);
    final hasKey = n.containsKey('flightKey') || bind.containsKey('flightKey');
    final hasFlight = n.containsKey('flight') || bind.keys.any((k) => k == 'flight' || k.startsWith('flight.'));
    // Schema 3's hero.flight is a shuttle's name; schema 4's an in-place
    // flight (an object), on a hero that says it flies in place.
    final schema4Hero = heroMap != null && (heroMap.containsKey('flies') || heroMap.containsKey('flightShuttle'));
    final shuttle = heroMap != null && heroMap['flight'] is String;
    final shuttleBound = bind.containsKey('hero.flight') && !schema4Hero;
    if (!hasKey && !hasFlight && !shuttle && !shuttleBound) return;

    final next = {...bind};
    // The navigation flight's look.
    var heroOut = heroMap == null ? hero : <String, Object?>{...heroMap};
    if (shuttle) {
      final m = heroOut as Json;
      m['flightShuttle'] = m.remove('flight');
      if (m['flightShuttle'] == 'standard') m.remove('flightShuttle');
    }
    if (shuttleBound) next['hero.flightShuttle'] = next.remove('hero.flight')!;

    final key = readString(n['flightKey']) ?? '';
    final keyBound = bind.containsKey('flightKey');
    final flies = key.trim().isNotEmpty || keyBound;
    final heroTag = heroMap != null ? readString(heroMap['tag']) ?? '' : readString(hero) ?? '';
    final isHero = heroTag.isNotEmpty || next.keys.any((k) => k == 'hero' || k.startsWith('hero.'));
    final flight = n['flight'];
    final flightBinds = {for (final k in bind.keys) if (k == 'flight' || k.startsWith('flight.')) k: bind[k]!};
    for (final k in flightBinds.keys) {
      next.remove(k);
    }
    next.remove('flightKey');

    if (flies && isHero) {
      // One node, two tags: it can fly one way only.
      s.unconvertible(n, 'flightKey', n['flightKey'],
          instead: 'Put the in-place flight on a node of its own (a wrapper) with {"hero": {"tag": ..., "flies": "inPlace"}}.',
          message: 'The node has a hero and a flight key: schema 4\'s one hero flies between screens or in place, not both; '
              'its flight key is kept as `legacy.flightKey`.');
      if (flight != null) n['legacy.flight'] = flight;
      if (keyBound) n['legacy.bind.flightKey'] = bind['flightKey'];
      s.behaviourChange('The node no longer flies in from where its flight key was (it keeps its hero).', path: '/flightKey', old: n['flightKey']);
    } else if (flies) {
      heroOut = <String, Object?>{
        'tag': key,
        'flies': 'inPlace',
        'flight': ?readMap(flight),
      };
      if (keyBound) next['hero.tag'] = bind['flightKey']!;
      for (final e in flightBinds.entries) {
        next['hero.${e.key}'] = e.value;
      }
      s.rewrite('/flightKey', n['flightKey'], null, 'flightKey → hero.tag (flies: inPlace)');
    } else {
      // An empty flight key, or a flight with no key, never flew: dropped.
      if (n.containsKey('flightKey')) s.rewrite('/flightKey', n['flightKey'], null, 'an empty flightKey (it never flew) dropped');
      if (flight != null || flightBinds.isNotEmpty) s.rewrite('/flight', flight, null, 'a flight with no flight key (it never flew) dropped');
    }
    n
      ..remove('flightKey')
      ..remove('flight');
    if (!jsonEquality.equals(heroOut, hero)) putKey(n, 'hero', heroOut, s);
    putBind(n, next, s);
  },
);
