// The step for a pose's legacy keys: a pose (a page view's page, a route
// transition's side) is a motion with an opacity and a blur.
import '../json.dart';
import 'legacy_read.dart';
import 'legacy_track.dart';
import 'migrate.dart';

/// A pose's legacy keys (a page view's `pageMotion`/`pageMotionBefore`, a
/// route transition side's `motion`): `originX`/`originY` → `alignment`,
/// the flat path keys → `path`, as the schema-2 [Motion] reader read them;
/// its `opacity` and `blur` stay (a pose has them).
final poseLegacyStep = MigrationStep(
  id: 'pose.legacy',
  description: 'pose originX/Y and flat path keys → alignment, path',
  node: (n, s) {
    for (final e in n.entries) {
      // Poses are in props (a page view's, a canvas's route transition) and
      // actions (a navigation's transition); keys a node doesn't model are
      // kept as they are.
      if (e.key != 'props' && e.key != 'actions') continue;
      eachMap(e.value, (m, at) {
        for (final k in const ['pageMotion', 'pageMotionBefore', 'motion']) {
          final pose = readMap(m[k]);
          if (pose == null || !pose.keys.any((x) => !LegacyMotion.keys.contains(x) && x != 'opacity' && x != 'blur')) continue;
          final out = {
            ...LegacyMotion.read({...pose}..remove('opacity')..remove('blur')).toJson(),
            'opacity': ?pose['opacity'],
            'blur': ?pose['blur'],
          };
          s.rewrite('/${e.key}$at/$k', pose, out);
          m[k] = out;
        }
      }, '');
    }
  },
);
