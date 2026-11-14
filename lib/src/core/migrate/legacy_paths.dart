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

/// What to write now instead of a binding path [path] 30.1.0 moved (as
/// 30.0.0 spelled it), or null when it is not one: in 30.1.0 the node's `scale` and
/// `layout.rotation` are in `motion`, `flightKey` and `flight` in `hero`;
/// `strokePath` and `props.subpathColors` are `customPaint` path ops, a
/// box's `props.path` a path node's `props.data`.
/// A path an action or a condition names in a schema-2 document is rewritten
/// by the migration; one that comes from elsewhere at run time (another
/// document, a script) is refused where it is used, with this.
String? movedPathHint(String path) {
  final p = path.trim();
  return switch (p) {
    'scale' => '"motion.scale" (the node\'s Transform.scale is its motion; 30.0.0 multiplied the two)',
    'layout.rotation' => '"motion.rotate" (the node\'s Transform.rotate is its motion; 30.0.0 added the two)',
    'flightKey' => '"hero.tag" on a hero that flies "inPlace" ({"hero": {"tag": ..., "flies": "inPlace"}})',
    _ when p.startsWith('flight.') || p == 'flight' => '"hero.$p" (how the hero flies in place)',
    _ when p == 'strokePath' || p.startsWith('strokePath.') =>
      'a variable bound into the "customPaint" path op that draws the line ("points", "trimEnd" for the progress, "paint.color")',
    'props.path' => '"props.data" (a box drawn as a path is a path node)',
    'props.subpathColors' => 'a variable bound into the paint of each "customPaint" path op (one op per color)',
    'props.use24h' => '"props.alwaysUse24HourFormat" (a time picker\'s 24-hour dial, Flutter\'s name)',
    _ => specialPathHint(p),
  };
}

/// The props of the last special cases (a text's countUp, a slider's ruler,
/// marker, track fade, grip and overlay rule, a text field's highlight, a
/// table's row edge, a date/time input's displayFormat), by name, and what
/// to write instead.
const Map<String, String> specialCaseProps = {
  'countUp': 'a transition of "props.text" (its number counts to each new value) and, to count from 0 when it shows, '
      'an animation with a track on "props.text" from 0',
  'countUpDuration': 'the "duration" of the transition and the animation of "props.text"',
  'countUpCurve': 'the "curve" of the transition and the animation of "props.text"',
  'countUpOnShow': 'an animation with a track on "props.text" from 0 (none: no count when it shows)',
  'rulerTicks': 'a "customPaint" "repeat" of "line" ops over the ruler track (the painter draws over a slider\'s track)',
  'rulerMajorEvery': 'a "when" on the long ticks\' "line" op in the "customPaint" repeat ("\${= index % 5 == 0}")',
  'rulerTickColor': 'the paint color of the ticks\' "customPaint" "line" ops',
  'rulerMinorTickColor': 'the paint color of the short ticks\' "customPaint" "line" op',
  'markerValue': 'a "customPaint" "rect" op at "\${= slider.trackRect.left + slider.trackRect.width * (value - slider.min) / '
      '(slider.max - slider.min)}"',
  'markerColor': 'the paint color of the marker\'s "customPaint" "rect" op',
  'markerWidth': 'the width in the marker\'s "customPaint" "rect" op',
  'markerHeight': 'the height in the marker\'s "customPaint" "rect" op',
  'activeTrackStartOpacity': 'a "customPaint" "rrect" op over the active track ("slider.trackRect" to '
      '"slider.thumbCenter.x") with a gradient of the inactive track\'s color',
  'thumbGripColor': 'a "customPaint" "rect" op in "foregroundPainter" at "slider.thumbCenter"',
  'deriveOverlayColorFromThumb': '"overlayColor" (no renderer read it)',
  'highlightStart': '"runs": [{"start": ..., "end": ..., "style": {...}}] (styled ranges of the typed text, as a text\'s)',
  'highlightEnd': 'the "end" of a run in "runs"',
  'highlightStyle': 'the "style" of a run in "runs"',
  'selectedRowEdgeColor': 'the cell template\'s "selected" state style (a left stroke), with "selected" bound to '
      '"\${= item.rowIndex == <the selected row> && item.columnIndex == 0}"',
  'selectedRowEdgeWidth': 'the "strokeWidth" of the cell template\'s "selected" state style',
  'displayFormat': '"format" (one spelling)',
};

/// Whether binding path [path] is a prop of [specialCaseProps].
bool movedSpecialPath(String path) {
  final p = path.trim();
  if (!p.startsWith('props.')) return false;
  return specialCaseProps.containsKey(p.substring(6).split(RegExp(r'[.\[]')).first);
}

/// [movedPathHint] for the props of [specialCaseProps].
String? specialPathHint(String path) {
  if (!movedSpecialPath(path)) return null;
  final key = path.trim().substring(6).split(RegExp(r'[.\[]')).first;
  return '${specialCaseProps[key]} (the "$key" prop is gone)';
}

/// [schema2PathHint], else [movedPathHint]: what to write in the current
/// schema instead of an older schema's binding path [path].
String? olderSchemaPathHint(String path) => schema2PathHint(path) ?? movedPathHint(path);
