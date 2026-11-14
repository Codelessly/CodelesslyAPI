// The one-way steps of 30.1.0, the last steps of `migrate2to3`, in the
// order they run. Each is small, named and tested on its own
// (test/migrate_spellings_test.dart).
//
// They give each concept that 30.0.0's schema 3 could say two ways one
// spelling, under Flutter's name: the node's `scale` and `layout.rotation` are its
// `motion` (`Transform`), `flightKey` and `flight` are its `hero` (`Hero`);
// `strokePath`, a box's `path`, `subpathColors` and `gradientPerSubpath` are
// `customPaint` path ops and the path node (steps_paint.dart).
import '../json.dart';
import '../node_patch.dart' show mergeNodePatch;
import '../behaviors.dart' show diffPatch;
import 'legacy_paths.dart' show movedSpecialPath, movedPathHint;
import 'legacy_read.dart';
import 'migrate.dart';
import 'steps_hero.dart';
import 'steps_paint.dart';
import 'steps_special.dart';
import 'steps_transform.dart';

/// The node steps of 30.1.0, in order. A one-way step that rewrites
/// a node's own JSON goes here: `patches.moved` re-expresses the
/// interaction-state and media patches through every step of this list, so
/// a patch that sets what a step moved moves with it.
///
/// [paintSteps] come last, in their own order: `paint.patches` (a document
/// pass) first, because it re-expresses the patches that set a paint field
/// against the nodes as they are before the paint node steps rewrite them;
/// what it leaves in a patch the paint node steps no longer change.
final List<MigrationStep> spellingSteps = [
  ...specialCaseDocumentSteps,
  transformFoldStep,
  heroFlightStep,
  movedPathsStep,
  renamedPropsStep,
  ...specialCaseSteps,
  ...paintSteps,
];

/// Props renamed to Flutter's name, by node type: old key → new key.
const Map<String, Map<String, String>> renamedProps = {
  'timePicker': {'use24h': 'alwaysUse24HourFormat'},
};

/// A prop [renamedProps] renames, in a node's `props` and `bind`.
final renamedPropsStep = MigrationStep(
  id: 'props.renamed',
  description: 'props renamed to Flutter\'s names (timePicker use24h → alwaysUse24HourFormat)',
  node: (n, s) {
    // A patch (no type of its own) is of the node it patches.
    final type = n['type'] ?? readMap(readMap(s.document?['nodes'])?[s.nodeId])?['type'];
    final names = renamedProps[type];
    if (names == null) return;
    final props = readMap(n['props']);
    if (props != null && names.keys.any(props.containsKey)) {
      final out = <String, Object?>{
        for (final e in props.entries) names[e.key] ?? e.key: e.value,
      };
      for (final e in names.entries) {
        if (props.containsKey(e.key)) s.rewrite('/props/${e.key}', e.key, e.value, 'props.${e.key} → props.${e.value} (Flutter\'s name)');
      }
      n['props'] = out;
    }
    final bind = bindOf(n);
    if (names.keys.any((k) => bind.containsKey('props.$k'))) {
      final renamed = {for (final e in names.entries) 'props.${e.key}': 'props.${e.value}'};
      putBind(n, {for (final e in bind.entries) renamed[e.key] ?? e.key: e.value}, s);
    }
  },
);

/// The node paths [spellingSteps] move (30.0.0's spellings), and where to
/// (the current path, or the object they went into). A patch that sets one sets the new
/// path explicitly, at the value of the migrated patched node. A node step
/// that moves a field adds its paths here.
final Map<String, String> movedSpellings = {
  'scale': 'motion.scale',
  'layout.rotation': 'motion.rotate',
  'flightKey': 'hero',
  'flight': 'hero',
  'hero': 'hero',
  // paintSteps: a stroke path and per-shape colors are custom paint ops; a
  // box's path is a path node's data.
  'strokePath': 'customPaint',
  'props.subpathColors': 'customPaint',
  'props.path': 'props.data',
  // renamedPropsStep.
  'props.use24h': 'props.alwaysUse24HourFormat',
  // specialCaseSteps: the last special-case fields, said generally.
  for (final k in ['countUp', 'countUpDuration', 'countUpCurve', 'countUpOnShow']) 'props.$k': 'transitions',
  for (final k in [
    'rulerTicks', 'rulerMajorEvery', 'rulerTickColor', 'rulerMinorTickColor', 'markerValue', 'markerColor', //
    'markerWidth', 'markerHeight', 'activeTrackStartOpacity', 'thumbGripColor',
  ])
    'props.$k': 'customPaint',
  'props.deriveOverlayColorFromThumb': 'props.overlayColor',
  for (final k in ['highlightStart', 'highlightEnd', 'highlightStyle']) 'props.$k': 'props.runs',
  'props.displayFormat': 'props.format',
};

/// The steps of 30.1.0, in order: [spellingSteps], then the patches
/// re-expressed through them.
final List<MigrationStep> spellingMigrationSteps = [
  ...spellingSteps,
  spellingPatchesStep(spellingSteps, movedSpellings),
];

/// A binding path an action or a condition sets, and its value, as it is
/// spelled now: `scale` → `motion.scale` (times the target's own motion scale),
/// `layout.rotation` → `motion.rotate` (plus its own rotate), `flightKey` →
/// `hero.tag`, `flight.*` → `hero.flight.*`, `hero.flight` →
/// `hero.flightShuttle`. Null when [path] is not one 30.1.0 moved.
(String, Object?)? _movedPath(String path, Object? value, Json? target, String where, MigrationScope s, {bool hasValue = true}) {
  final motion = readMap(target?['motion']) ?? const <String, Object?>{};
  switch (path) {
    case 'scale' || 'layout.rotation':
      final scale = path == 'scale';
      final to = scale ? 'motion.scale' : 'motion.rotate';
      final own = readDouble(motion[scale ? 'scale' : 'rotate']) ?? (scale ? 1.0 : 0.0);
      final identity = scale ? 1.0 : 0.0;
      if (!scale) {
        final m = readMap(target?['layout'])?['margin'];
        final l = readList(m);
        if (l != null && l.length == 4 && (readDouble(l[0]) != readDouble(l[2]) || readDouble(l[1]) != readDouble(l[3]))) {
          s.behaviourChange('It sets the rotation of a node whose margin is uneven: schema 3 turned it about its center '
              'moved by half the margin\'s difference, now about its center.', path: where);
        }
      }
      if (!hasValue || own == identity) return (to, value);
      final op = scale ? '*' : '+';
      if (value is num) return (to, writeRatio(scale ? value * own : value + own));
      final f = value is String ? formulaOf(value) : null;
      if (f != null) return (to, '\${= ($f) $op ${writeRatio(own)}}');
      s.behaviourChange('It sets "$path" to a value the migration cannot combine with the target\'s own motion $op ${writeRatio(own)}.',
          path: where, old: value, instead: 'Set "$to" to the value $op ${writeRatio(own)}.');
      return (to, value);
    case 'flightKey':
      if (readString(target?['hero']) != null || readMap(target?['hero']) != null) {
        s.behaviourChange('It sets the flight key of a node that also has a hero: it now sets the hero\'s tag.', path: where);
      }
      return ('hero.tag', value);
    case 'hero.flight':
      return ('hero.flightShuttle', value);
    case 'props.use24h':
      return ('props.alwaysUse24HourFormat', value);
    case 'props.displayFormat':
      return ('props.format', value);
    case 'props.highlightStart' || 'props.highlightEnd':
      return ('props.runs[0].${path == 'props.highlightStart' ? 'start' : 'end'}', value);
    case _ when movedSpecialPath(path):
      s.behaviourChange('It sets "$path", which is gone: it now sets nothing.', path: where, old: value,
          instead: movedPathHint(path) ?? '');
      return null;
    case _ when path == 'flight' || path.startsWith('flight.'):
      return ('hero.$path', value);
  }
  return null;
}

/// The paths `setValue` actions (in a node's reactions) and conditions (the
/// document's) set: moved as [_movedPath] says.
final movedPathsStep = MigrationStep(
  id: 'paths.moved',
  description: 'setValue and condition paths scale, layout.rotation, flightKey, flight → motion and hero paths',
  node: (n, s) {
    final nodes = readMap(s.document?['nodes']);
    eachMap(n['actions'], (m, at) {
      if (m['type'] != 'setValue') return;
      final target = readMap(nodes?[readString(m['node']) ?? '']);
      final values = readList(m['values']);
      if (values == null) return;
      for (var i = 0; i < values.length; i++) {
        final v = readMap(values[i]);
        final path = readString(v?['path']);
        if (v == null || path == null) continue;
        final where = '/actions$at/values/$i';
        final set = (readString(v['mode']) ?? 'set') == 'set';
        final moved = _movedPath(path, v['value'], target, where, s, hasValue: set);
        if (moved == null) continue;
        final out = {...v, 'path': moved.$1, if (set) 'value': moved.$2};
        s.rewrite(where, v, out);
        values[i] = out;
      }
    }, '');
  },
  document: (d, s) {
    final nodes = readMap(d['nodes']);
    final original = readMap(s.document?['nodes']);
    eachMap(d['conditions'], (m, at) {
      final path = readString(m['path']), node = readString(m['node']);
      if (path == null || node == null || !m.containsKey('node')) return;
      final moved = _movedPath(path, m['value'], readMap(original?[node]) ?? readMap(nodes?[node]), '/conditions$at', s);
      if (moved == null) return;
      final old = {...m};
      m
        ..['path'] = moved.$1
        ..['value'] = moved.$2;
      s.rewrite('/conditions$at', old, {...m});
    }, '');
  },
);

/// The patches of the interaction states (`states.<state>.<node id>`) and
/// media rules (`media[i].patch`) that set what [nodeSteps] moved: each
/// re-expressed so its node is the node the schema-3 patch gave, migrated.
/// What a patch sets is set again, explicitly, where it went ([moved]: a
/// pressed `{"scale": 1}` still wins over a hovered `{"scale": 1.05}`), at
/// the value the migrated patched node has (`motion.scale`: the patch's
/// scale times the node's own motion scale). A patch whose node is not in
/// the document is migrated alone.
MigrationStep spellingPatchesStep(List<MigrationStep> nodeSteps, Map<String, String> moved) => MigrationStep(
      id: 'patches.moved',
      description: 'state and media patches that set moved fields → patches of the moved fields',
      document: (doc, s) {
        final nodes = readMap(doc['nodes']) ?? const <String, Object?>{};
        final original = readMap(s.document?['nodes']) ?? const <String, Object?>{};
        Json run(Json node, String id) {
          final out = copyJson(node) as Json;
          for (final step in nodeSteps) {
            step.node?.call(out, MigrationScope.silent(step, nodeId: id, document: s.document));
          }
          return out;
        }

        Json? repatch(String target, Json patch, {Json? base}) {
          final alone = run(patch, target);
          if (jsonEquality.equals(alone, patch)) return null;
          final b = base ?? readMap(original[target]);
          if (b == null) return alone;
          final plain = <String, Object?>{...b}
            ..remove('states')
            ..remove('media');
          final same = run(plain, target), after = run(mergeNodePatch(plain, patch), target);
          final touched = {
            for (final k in {...patch.keys, ...alone.keys})
              if (!jsonEquality.equals(patch[k], alone[k])) k,
          };
          // Where the patch's own leaves went.
          final movedTo = <List<String>>[
            for (final p in _leaves(patch, const []))
              for (final e in moved.entries)
                if (p.join('.') == e.key || p.join('.').startsWith('${e.key}.')) e.value.split('.'),
          ];
          final leaves = <List<String>>[
            ..._leaves(alone, const []).where((p) => touched.contains(p.first)),
            ...movedTo,
            ..._leaves(diffPatch(same, after) ?? const {}, const []).where((p) => touched.contains(p.first)),
          ];
          final out = <String, Object?>{
            for (final e in patch.entries)
              if (!touched.contains(e.key)) e.key: e.value,
          };
          for (final p in leaves) {
            _setAt(out, p, _valueAt(after, p));
          }
          return out;
        }

        for (final e in nodes.entries) {
          final node = readMap(e.value);
          if (node == null) continue;
          final states = readMap(node['states']);
          if (states != null) {
            for (final st in states.entries) {
              final per = readMap(st.value);
              if (per == null) continue;
              for (final p in per.entries) {
                final patch = readMap(p.value);
                if (patch == null) continue;
                final out = repatch(p.key, patch);
                if (out == null || jsonEquality.equals(out, patch)) continue;
                s.rewrite('/nodes/${e.key}/states/${st.key}/${p.key}', p.value, out);
                per[p.key] = out;
              }
            }
          }
          final media = readList(node['media']);
          if (media != null) {
            for (var i = 0; i < media.length; i++) {
              final rule = readMap(media[i]);
              final patch = readMap(rule?['patch']);
              if (rule == null || patch == null) continue;
              final out = repatch(e.key, patch, base: readMap(original[e.key]));
              if (out == null || jsonEquality.equals(out, patch)) continue;
              s.rewrite('/nodes/${e.key}/media/$i/patch', patch, out);
              rule['patch'] = out;
            }
          }
        }
      },
    );

/// The key paths to the leaves of [m]: maps are walked (an empty one has
/// none), anything else (a list, a scalar, null) is a leaf.
Iterable<List<String>> _leaves(Json m, List<String> at) sync* {
  for (final e in m.entries) {
    final here = [...at, e.key];
    final child = e.value is Map ? readMap(e.value) : null;
    if (child != null) {
      yield* _leaves(child, here);
    } else {
      yield here;
    }
  }
}

Object? _valueAt(Json m, List<String> path) {
  Object? at = m;
  for (final k in path) {
    at = readMap(at)?[k];
  }
  return at;
}

void _setAt(Json m, List<String> path, Object? value) {
  var at = m;
  for (final k in path.take(path.length - 1)) {
    final next = readMap(at[k]);
    final copy = next == null ? <String, Object?>{} : <String, Object?>{...next};
    at[k] = copy;
    at = copy;
  }
  at[path.last] = value;
}
