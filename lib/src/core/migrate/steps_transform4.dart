// Schema 3 → 4: the node's `scale` (Flutter's `Transform.scale`) and
// `layout.rotation` (`Transform.rotate`; the SDK painted it, it never
// changed layout) fold into `motion`, the node's one `Transform`. Schema 3
// drew them as two more layers inside the motion: the scale about the
// node's center, then the rotation about its center moved by half its
// margin's difference (left − right, top − bottom). Folded, the motion's
// scale is the product and its rotate the sum, and the pivot's offset is a
// translation; both are the same picture when the motion turns about its
// center with no 3D turn and nothing sits between the layers (a shimmer, a
// flip, a tilt), which the step reports where it is not so.
import 'dart:math' as math;

import '../behaviors.dart';
import '../json.dart';
import 'legacy_read.dart';
import 'migrate.dart';

/// The binding paths schema 4 moved into `motion`, with the motion key each
/// is folded into.
const Map<String, String> foldedTransformPaths = {'scale': 'motion.scale', 'layout.rotation': 'motion.rotate'};

/// What changes a node's transform after it is drawn (bindings, state and
/// media patches, `setValue`, conditions), by node id: read from the
/// schema-3 document once.
final class _Changes {
  final Set<String> scale = {}, rotation = {}, motionScale = {}, motionRotate = {}, margin = {}, motionOther = {};

  void addPatch(String id, Json patch) {
    if (patch.containsKey('scale')) scale.add(id);
    final layout = readMap(patch['layout']);
    if (layout != null && layout.containsKey('rotation')) rotation.add(id);
    if (layout != null && layout.containsKey('margin')) margin.add(id);
    if (patch.containsKey('motion')) {
      final m = readMap(patch['motion']);
      if (m == null || m.containsKey('scale')) motionScale.add(id);
      if (m == null || m.containsKey('rotate')) motionRotate.add(id);
      if (m == null || m.keys.any((k) => k != 'scale' && k != 'rotate')) motionOther.add(id);
    }
  }

  void addPath(String id, String path) {
    switch (path) {
      case 'scale':
        scale.add(id);
      case 'layout.rotation':
        rotation.add(id);
      case 'layout.margin':
        margin.add(id);
      case 'motion':
        motionScale.add(id);
        motionRotate.add(id);
        motionOther.add(id);
      case 'motion.scale':
        motionScale.add(id);
      case 'motion.rotate':
        motionRotate.add(id);
      default:
        if (path.startsWith('motion.')) motionOther.add(id);
    }
  }
}

final Expando<_Changes> _changesCache = Expando('schema 4 transform changes');

_Changes _changesOf(Json? document) {
  if (document == null) return _Changes();
  return _changesCache[document] ??= _survey(document);
}

_Changes _survey(Json document) {
  final out = _Changes();
  final nodes = readMap(document['nodes']) ?? const <String, Object?>{};
  for (final e in nodes.entries) {
    final n = readMap(e.value);
    if (n == null) continue;
    for (final k in bindOf(n).keys) {
      out.addPath(e.key, k);
    }
    for (final rule in readList(n['media']) ?? const []) {
      if (readMap(readMap(rule)?['patch']) case final Json p) out.addPatch(e.key, p);
    }
    for (final per in (readMap(n['states']) ?? const <String, Object?>{}).values) {
      for (final t in (readMap(per) ?? const <String, Object?>{}).entries) {
        if (readMap(t.value) case final Json p) out.addPatch(t.key, p);
      }
    }
    eachMap(n['actions'], (m, _) {
      if (m['type'] != 'setValue') return;
      final target = readString(m['node']) ?? '';
      for (final v in readList(m['values']) ?? const []) {
        if (readString(readMap(v)?['path']) case final String p) out.addPath(target.isEmpty ? e.key : target, p);
      }
    });
  }
  eachMap(document['conditions'], (m, _) {
    final node = readString(m['node']), path = readString(m['path']);
    if (node != null && path != null && m.containsKey('value')) out.addPath(node, path);
  });
  return out;
}

/// The node's static transform as schema 3 drew it, read from its JSON.
final class _Pose {
  _Pose(Json n) : motion = readMap(n['motion']) ?? const {} {
    final s = readDouble(n['scale']) ?? 1;
    scale = s > 0 ? s : 1;
    final layout = readMap(n['layout']);
    rotation = readDouble(layout?['rotation']) ?? 0;
    final m = layout?['margin'];
    final all = readDouble(m);
    final l = readList(m);
    double side(int i) => all ?? (l != null && l.length == 4 ? readDouble(l[i]) ?? 0 : 0);
    // Where schema 3's rotation turned about, from the node's center.
    pivot = ((side(0) - side(2)) / 2, (side(1) - side(3)) / 2);
  }

  final Json motion;
  late final double scale, rotation;
  late final (double, double) pivot;

  double get motionScale => readDouble(motion['scale']) ?? 1;
  double get motionRotate => readDouble(motion['rotate']) ?? 0;
  bool get centered {
    final a = motion['alignment'];
    if (a == null || a == 'center') return true;
    final l = readList(a);
    return l != null && l.length == 2 && readDouble(l[0]) == 0 && readDouble(l[1]) == 0;
  }

  bool get turns3d => (readDouble(motion['rotateX']) ?? 0) != 0 || (readDouble(motion['rotateY']) ?? 0) != 0;
  bool get orientsOnPath {
    final p = readMap(motion['path']);
    return p != null && (readString(p['orient']) ?? 'none') != 'none';
  }

  bool get offCenterPivot => pivot.$1 != 0 || pivot.$2 != 0;
}

/// The node's `scale` and `layout.rotation` (and their bindings,
/// transitions and animation tracks) → `motion.scale` (multiplied in) and
/// `motion.rotate` (added), schema 3's rotation pivot (moved by half the
/// margin's difference) kept as a translation. The state and media patches
/// that set them are rewritten by `patches.schema4`, actions and conditions
/// by `paths.schema4`.
final transformFoldStep = MigrationStep(
  id: 'transform.fold',
  description: 'node scale and layout.rotation → motion.scale (multiplied) and motion.rotate (added)',
  node: (n, s) => foldTransform(n, s.nodeId, s),
);

/// [transformFoldStep] on node [n] (id [id]).
void foldTransform(Json n, String id, MigrationScope s) {
  final layout = readMap(n['layout']);
  final bind = bindOf(n);
  final hasScale = n.containsKey('scale'), hasRotation = layout != null && layout.containsKey('rotation');
  final transitions = readList(n['transitions']) ?? const [];
  final foldsTransition = transitions.any((t) => const {'scale', 'layout.rotation'}.contains(readMap(t)?['property']));
  final changes = _changesOf(s.document);
  final pose = _Pose(n);
  final hasTracks = _tracksTouch(n, pose.scale != 1 || pose.rotation != 0);
  if (!hasScale &&
      !hasRotation &&
      !bind.containsKey('scale') &&
      !bind.containsKey('layout.rotation') &&
      !foldsTransition &&
      !hasTracks &&
      !changes.scale.contains(id) &&
      !changes.rotation.contains(id)) {
    return;
  }
  final scaleBound = bind.containsKey('scale'), rotationBound = bind.containsKey('layout.rotation');
  final scaleMoves = scaleBound || changes.scale.contains(id);
  final rotationMoves = rotationBound || changes.rotation.contains(id);
  final motionScaleMoves = bind.containsKey('motion.scale') || bind.containsKey('motion') || changes.motionScale.contains(id);
  final motionRotateMoves = bind.containsKey('motion.rotate') || bind.containsKey('motion') || changes.motionRotate.contains(id);
  final folds = hasScale || hasRotation || scaleBound || rotationBound;

  // What sits between schema 3's motion and its scale and rotation layers,
  // or makes the two pivots differ: reported, folded all the same.
  if (folds || scaleMoves || rotationMoves) {
    final what = [
      if (!pose.centered) 'a motion alignment off its center',
      if (pose.turns3d || bind.containsKey('motion.rotateX') || bind.containsKey('motion.rotateY')) 'a 3D motion turn',
      if (n['shimmer'] != null) 'a shimmer',
      if (n['flip'] != null) 'a flip',
      if (n['tilt'] != null) 'a tilt',
    ];
    if (what.isNotEmpty) {
      s.behaviourChange(
          'Schema 3 drew the node\'s scale and rotation inside ${what.join(', ')}; schema 4 draws them in the motion, '
          'outside it, about the motion\'s alignment: the picture differs while either is not at rest.',
          path: '/motion',
          instead: 'Check the node; a separate wrapping node can carry the turn or the scale inside the effect.');
    }
  }

  final motion = <String, Object?>{...pose.motion};
  // The pose's static values.
  if (pose.scale != 1) {
    motion['scale'] = writeRatio(pose.motionScale * pose.scale);
    if (motion['scale'] == 1) motion.remove('scale');
  }
  if (pose.rotation != 0) {
    motion['rotate'] = writeRatio(pose.motionRotate + pose.rotation);
    if (motion['rotate'] == 0) motion.remove('rotate');
  }
  // Schema 3 turned the rotation about the node's center moved by half the
  // margin's difference: the same turn about the center, then the offset
  // e = d − R·d, carried through the motion's own scale and rotation.
  if ((pose.rotation != 0 || rotationMoves) && pose.offCenterPivot) {
    if (rotationMoves || changes.margin.contains(id) || bind.containsKey('layout.margin')) {
      s.behaviourChange(
          'The rotation is bound or changed while its margin is uneven: schema 3 turned it about its center moved by half '
          'the margin\'s difference, schema 4 about its center.',
          path: '/layout/rotation',
          instead: 'Bind "motion.translateX"/"motion.translateY" to the offset, or even out the margin.');
    } else if (motionScaleMoves || motionRotateMoves || pose.orientsOnPath || !pose.centered || pose.turns3d ||
        bind.keys.any((k) => const {'motion.scaleX', 'motion.scaleY'}.contains(k))) {
      s.behaviourChange(
          'The rotation\'s pivot (its center moved by half the margin\'s difference) is kept as a translation for the '
          'motion at rest; a motion that turns or scales by itself moves it.',
          path: '/layout/rotation');
    }
    if (!rotationMoves) {
      final (dx, dy) = pose.pivot;
      final a = pose.rotation * math.pi / 180;
      // e = d − R(rotation)·d, then the outer layers: the node's scale, the
      // motion's rotate and its scale (times scaleX/scaleY).
      var ex = (dx - (dx * math.cos(a) - dy * math.sin(a))) * pose.scale;
      var ey = (dy - (dx * math.sin(a) + dy * math.cos(a))) * pose.scale;
      final b = pose.motionRotate * math.pi / 180;
      (ex, ey) = (ex * math.cos(b) - ey * math.sin(b), ex * math.sin(b) + ey * math.cos(b));
      final ms = pose.motionScale;
      ex *= ms * (readDouble(pose.motion['scaleX']) ?? 1);
      ey *= ms * (readDouble(pose.motion['scaleY']) ?? 1);
      if (ex.abs() > 1e-9) motion['translateX'] = writeRatio((readDouble(motion['translateX']) ?? 0) + ex);
      if (ey.abs() > 1e-9) motion['translateY'] = writeRatio((readDouble(motion['translateY']) ?? 0) + ey);
    }
  }
  if (!jsonEquality.equals(motion, pose.motion)) putKey(n, 'motion', motion.isEmpty ? null : motion, s);
  if (hasScale) putKey(n, 'scale', null, s);
  if (hasRotation) {
    final l = <String, Object?>{...layout}..remove('rotation');
    putKey(n, 'layout', l, s);
  }

  // Bindings: the bound value replaces its static one; the other part stays
  // (multiplied, added) as a formula.
  final next = {...bind};
  void fold(String from, String to, String op, double ownFrom, double ownTo, double identity) {
    final f = next.remove(from), g = next[to];
    if (f == null && (g == null || ownFrom == identity)) return;
    if (f == null) {
      // The motion's own value bound: times (plus) the node's static one.
      final fg = formulaOf(g!);
      if (fg == null) {
        s.unconvertible(n, 'bind.$to', g,
            instead: 'Bind "$to" to a formula: the bound value $op ${writeRatio(ownFrom)} (the node\'s own).',
            message: '"$to" is bound to text the migration cannot combine with the node\'s own ${from == 'scale' ? 'scale' : 'rotation'}; kept as `legacy.bind.$to`.');
        next.remove(to);
        return;
      }
      next[to] = '\${= ($fg) $op ${writeRatio(ownFrom)}}';
      return;
    }
    final ff = formulaOf(f);
    if (g == null) {
      if (ownTo == identity) {
        next[to] = f;
      } else if (ff != null) {
        next[to] = '\${= ($ff) $op ${writeRatio(ownTo)}}';
      } else {
        s.unconvertible(n, 'bind.$from', f,
            instead: 'Bind "$to" to a formula: the value $op ${writeRatio(ownTo)} (the motion\'s own).',
            message: '"$from" is bound to text the migration cannot combine with the motion\'s own value; kept as `legacy.bind.$from`.');
      }
      return;
    }
    final fg = formulaOf(g);
    if (ff == null || fg == null) {
      s.unconvertible(n, 'bind.$from', f,
          instead: 'Bind "$to" to one formula: ($from) $op ($to).',
          message: '"$from" and "$to" are both bound and one is text the migration cannot combine; kept as `legacy.bind.$from`.');
      return;
    }
    next[to] = '\${= ($ff) $op ($fg)}';
  }

  fold('scale', 'motion.scale', '*', pose.scale, pose.motionScale, 1);
  fold('layout.rotation', 'motion.rotate', '+', pose.rotation, pose.motionRotate, 0);
  putBind(n, next, s);

  // Transitions: the node's own timing for its scale and rotation, kept
  // apart from the motion's.
  final list = [for (final t in transitions) readMap(t) == null ? t : <String, Object?>{...readMap(t)!}];
  var changed = false;
  void retime(String from, String to, bool moves, bool motionMoves, double Function(double) shift) {
    final i = list.indexWhere((t) => readMap(t)?['property'] == from);
    final j = list.indexWhere((t) => readMap(t)?['property'] == to);
    if (i >= 0) {
      final t = readMap(list[i])!;
      if (j >= 0) {
        // One key, one timing: the motion's own entry stays where it eases.
        if (moves && motionMoves) {
          s.behaviourChange('"$from" and "$to" both change and had their own transitions; "$to" keeps its own.',
              path: '/transitions', old: t);
        }
        if (motionMoves || !moves) {
          list.removeAt(i);
        } else {
          list[j] = {...t, 'property': to};
          list.removeAt(i);
        }
      } else {
        final prefix = Transition.of(Transition.listFromJson([...list]..removeAt(i)), to);
        final key = to.substring('motion.'.length);
        if (prefix != null && prefix.keyframes.any((k) => readMap(k.value)?.containsKey(key) ?? false)) {
          s.behaviourChange('The "${prefix.property}" transition\'s keyframes name "$key": they no longer run on "$to", which '
              'takes the node\'s own $from transition.', path: '/transitions');
        }
        list[i] = {...t, 'property': to, if (t['keyframes'] != null) 'keyframes': _shiftKeyframes(t['keyframes'], shift)};
      }
      changed = true;
      return;
    }
    if (!moves) return;
    final eased = Transition.of(Transition.listFromJson(list), to);
    if (eased == null) return;
    // It snapped in schema 3 while the motion eased: a transition of its
    // own that takes no time keeps it so.
    if (motionMoves) {
      s.behaviourChange('"$from" changes with no transition of its own and the motion\'s "${eased.property}" transition '
          'eases "$to": they are one value in schema 4, eased together.', path: '/transitions');
      return;
    }
    final key = to.substring('motion.'.length);
    if (eased.property != '*' && eased.keyframes.any((k) => readMap(k.value)?.containsKey(key) ?? false)) {
      s.behaviourChange('The "${eased.property}" transition\'s keyframes name "$key": they no longer run on "$to", which '
          'gets a transition of its own (none) for the node\'s $from.', path: '/transitions');
    }
    list.add({'property': to});
    changed = true;
  }

  // A motion transition's keyframes and a motion.scale (motion.rotate)
  // transition's keyframes are absolute: the node's own part joins them.
  if (pose.scale != 1 || pose.rotation != 0) {
    for (var k = 0; k < list.length; k++) {
      final t = readMap(list[k]);
      if (t == null || t['keyframes'] == null) continue;
      final p = t['property'];
      if (p == 'motion' || p == '*') {
        final frames = [
          for (final f in readList(t['keyframes']) ?? const [])
            if (readMap(f) case final Json fm when readMap(fm['value']) != null)
              {
                ...fm,
                'value': {
                  ...readMap(fm['value'])!,
                  if (pose.scale != 1 && readDouble(readMap(fm['value'])!['scale']) != null)
                    'scale': writeRatio(readDouble(readMap(fm['value'])!['scale'])! * pose.scale),
                  if (pose.rotation != 0 && readDouble(readMap(fm['value'])!['rotate']) != null)
                    'rotate': writeRatio(readDouble(readMap(fm['value'])!['rotate'])! + pose.rotation),
                },
              }
            else
              f,
        ];
        if (!jsonEquality.equals(frames, t['keyframes'])) {
          list[k] = {...t, 'keyframes': frames};
          changed = true;
        }
      } else if ((p == 'motion.scale' && pose.scale != 1) || (p == 'motion.rotate' && pose.rotation != 0)) {
        final shifted = _shiftKeyframes(t['keyframes'], (v) => p == 'motion.scale' ? v * pose.scale : v + pose.rotation);
        if (!jsonEquality.equals(shifted, t['keyframes'])) {
          list[k] = {...t, 'keyframes': shifted};
          changed = true;
        }
      }
    }
  }
  retime('scale', 'motion.scale', scaleMoves, motionScaleMoves, (v) => v * pose.motionScale);
  retime('layout.rotation', 'motion.rotate', rotationMoves, motionRotateMoves, (v) => v + pose.motionRotate);
  if (changed) putKey(n, 'transitions', list.isEmpty ? null : list, s);

  // Animation tracks on the moved paths, and replacing tracks on the motion
  // of a node with its own scale or rotation.
  _foldTracks(n, id, pose, s);
}

/// Whether any of [n]'s animation tracks is on `scale` or `layout.rotation`,
/// or ([motionToo]) replaces `motion.scale` or `motion.rotate`.
bool _tracksTouch(Json n, bool motionToo) {
  for (final a in readList(n['animations']) ?? const []) {
    for (final t in readList(readMap(a)?['tracks']) ?? const []) {
      final p = readMap(t)?['path'];
      if (foldedTransformPaths.containsKey(p)) return true;
      if (motionToo && (p == 'motion.scale' || p == 'motion.rotate')) return true;
    }
    if (motionToo && readMap(a)?['preset'] != null) return true;
  }
  return false;
}

List<Object?> _shiftKeyframes(Object? frames, double Function(double) shift) => [
      for (final f in readList(frames) ?? const [])
        if (readMap(f) case final Json fm when readDouble(fm['value']) != null)
          {...fm, 'value': writeRatio(shift(readDouble(fm['value'])!))}
        else
          f,
    ];

/// A track value (a number, or an expression) moved by [op] [by].
Object? _shiftValue(Object? v, String op, double by) {
  if (v == null) return null;
  if (readDouble(v) case final double d when v is num) return writeRatio(op == '*' ? d * by : d + by);
  if (v is String) {
    final f = formulaOf(v);
    if (f != null) return '\${= ($f) $op ${writeRatio(by)}}';
  }
  return _unshifted;
}

const Object _unshifted = Object();

void _foldTracks(Json n, String id, _Pose own, MigrationScope s) {
  final animations = readList(n['animations']);
  if (animations == null) return;
  final nodes = readMap(s.document?['nodes']);
  var changed = false;
  final out = <Object?>[];
  for (var ai = 0; ai < animations.length; ai++) {
    final a = readMap(animations[ai]);
    if (a == null) {
      out.add(animations[ai]);
      continue;
    }
    final tracks = readList(a['tracks']);
    final na = <String, Object?>{...a};
    if (a['preset'] != null && (own.scale != 1 || own.rotation != 0)) {
      // A preset's tracks come from its params: those that replace the
      // motion's scale or rotation from a given value start from it, not
      // from it times the node's own.
      final expanded = NodeAnimation.fromJson(a)?.expanded.tracks ?? const <AnimationTrack>[];
      final hits = expanded.where((t) =>
          t.node.isEmpty &&
          t.blend == TrackBlend.replace &&
          ((t.path == 'motion.scale' && own.scale != 1) || (t.path == 'motion.rotate' && own.rotation != 0)) &&
          (t.from != null || t.to != null || t.keyframes.isNotEmpty));
      if (hits.isNotEmpty) {
        s.behaviourChange(
            'The "${a['preset']}" animation replaces ${hits.map((t) => '"${t.path}"').toSet().join(' and ')} with values of its own; '
            'schema 3 drew the node\'s own ${own.scale != 1 ? 'scale' : 'rotation'} on top of them, schema 4 does not.',
            path: '/animations/$ai',
            instead: 'Give the preset\'s params times (plus) the node\'s own, or write its tracks.');
      }
    }
    if (tracks != null) {
      final nt = <Object?>[];
      for (var ti = 0; ti < tracks.length; ti++) {
        final t = readMap(tracks[ti]);
        final path = t?['path'];
        if (t == null || path is! String) {
          nt.add(tracks[ti]);
          continue;
        }
        final targetId = readString(t['node']) ?? '';
        final target = targetId.isEmpty ? own : _Pose(readMap(nodes?[targetId]) ?? const {});
        final moved = foldedTransformPaths[path];
        final to = moved ?? path;
        final replace = (readString(t['blend']) ?? 'replace') == 'replace';
        // What the track's values must be moved by to land where they did.
        final (op, by) = switch (to) {
          'motion.scale' => ('*', moved != null ? target.motionScale : target.scale),
          'motion.rotate' => ('+', moved != null ? target.motionRotate : target.rotation),
          _ => ('', 0.0),
        };
        final identity = op == '*' ? 1.0 : 0.0;
        if (moved == null && (op.isEmpty || by == identity)) {
          nt.add(t);
          continue;
        }
        final m = <String, Object?>{...t, 'path': to};
        if (replace && by != identity) {
          var lost = false;
          for (final k in const ['from', 'to']) {
            if (!t.containsKey(k)) continue;
            final v = _shiftValue(t[k], op, by);
            if (identical(v, _unshifted)) {
              lost = true;
            } else {
              m[k] = v;
            }
          }
          if (t['keyframes'] != null) m['keyframes'] = _shiftKeyframes(t['keyframes'], (v) => op == '*' ? v * by : v + by);
          if (lost) {
            s.behaviourChange('A track on "$path" has a value the migration cannot move by the node\'s own $op ${writeRatio(by)}.',
                path: '/animations/$ai/tracks/$ti', old: t, instead: 'Write the track\'s values $op ${writeRatio(by)}.');
          }
        }
        if (moved == 'motion.rotate' && target.offCenterPivot) {
          s.behaviourChange('A track turns a node whose margin is uneven: schema 3 turned it about its center moved by half '
              'the margin\'s difference, schema 4 about its center.', path: '/animations/$ai/tracks/$ti');
        }
        if (!jsonEquality.equals(m, t)) {
          s.rewrite('/animations/$ai/tracks/$ti', t, m);
          changed = true;
        }
        nt.add(m);
      }
      na['tracks'] = nt;
    }
    out.add(na);
  }
  if (changed) n['animations'] = out;
}
