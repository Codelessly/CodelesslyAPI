// Schema-2 binding paths outside a document's `bind` maps: a path an action
// names (`setValue`'s `values[].path`) is not rewritten by the migration
// (it is read against the node it targets when it runs, which may be in
// another document, a component or an instance), so it is recognised where
// it is used and refused with the schema-3 path to write instead.
import 'legacy_track.dart';

/// What to write in schema 3 instead of schema-2 binding path [path], or
/// null when [path] is not one of schema 2's. Paths whose schema-3 form
/// depends on the node (a loop's animation id, a drag's mode) name the
/// pattern.
String? schema2PathHint(String path) {
  final p = path.trim();
  final loop = RegExp(r'^loops(?:\[(\d+)\]|\.\*)?(?:\.(\w+))?').firstMatch(p);
  if (loop != null) {
    return '"animations.loop${loop[1] ?? '<i>'}.${loop[2] ?? '<key>'}" (a loop is the animation loop<i>; type → preset, reverse → repeat.reverse, its amounts → params.<key>)';
  }
  if (p.startsWith('effectAnimations')) {
    return '"animations.<the effect\'s name>.<key>" (an effect is the animation named after it; playOnAppear → autoplay)';
  }
  if (p == 'zoomable') return '"transformGesture" ({"target": "content", "pan": "whenZoomed"})';
  if (p.startsWith('drag.track.')) return '"track.${p.substring('drag.track.'.length)}"';
  if (p == 'drag.enabled') return '"track.enabled", "pan.enabled" or "dismissible.enabled" (the behavior the drag became)';
  if (p == 'drag' || p.startsWith('drag.')) return '"pan.<key>" or "dismissible.<key>" (the behavior the drag became)';
  if (p.endsWith('.naturalHeight') || p == 'naturalHeight') {
    return '"defaultTextStyle" set to {} on the node (the font\'s own line height)';
  }
  if (p.startsWith('motion.')) {
    final key = p.substring('motion.'.length).split('.').first;
    if (LegacyMotion.keys.contains(key)) return null;
    return switch (key) {
      'opacity' => '"opacity" (the node\'s; schema 2 multiplied the two)',
      'blur' => '"decoration.effects" (a layerBlur effect with id motionBlur)',
      'originX' || 'originY' => '"motion.alignment" ([x, y])',
      'pathProgress' => '"motion.path.progress"',
      'pathData' || 'pathViewBox' || 'orientToPath' || 'pathUpright' => '"motion.path.<key>" (path, viewBox, orient)',
      'pulseKey' => '"animations.pulse.playKey"',
      'duration' || 'delay' || 'curve' || 'spring' || 'springStiffness' || 'springDamping' =>
        'the motion\'s transition ("transitions": [{"property": "motion", ...}])',
      _ => '"animations.<preset>" (the entrance, loop, spin, keyframes or shimmer it became) or the motion\'s transition',
    };
  }
  return null;
}

/// What to write in schema 4 instead of schema-3 binding path [path], or
/// null when [path] is not one schema 4 moved: the node's `scale` and
/// `layout.rotation` are in `motion`, `flightKey` and `flight` in `hero`.
/// A path an action or a condition names in a schema-3 document is rewritten
/// by the migration; one that comes from elsewhere at run time (another
/// document, a script) is refused where it is used, with this.
String? schema3PathHint(String path) {
  final p = path.trim();
  return switch (p) {
    'scale' => '"motion.scale" (the node\'s Transform.scale is its motion; schema 3 multiplied the two)',
    'layout.rotation' => '"motion.rotate" (the node\'s Transform.rotate is its motion; schema 3 added the two)',
    'flightKey' => '"hero.tag" on a hero that flies "inPlace" ({"hero": {"tag": ..., "flies": "inPlace"}})',
    _ when p.startsWith('flight.') || p == 'flight' => '"hero.$p" (how the hero flies in place)',
    _ => null,
  };
}

/// [schema2PathHint], else [schema3PathHint]: what to write in the current
/// schema instead of an older schema's binding path [path].
String? olderSchemaPathHint(String path) => schema2PathHint(path) ?? schema3PathHint(path);
