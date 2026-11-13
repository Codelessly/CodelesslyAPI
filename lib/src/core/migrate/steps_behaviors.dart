// Steps for a node's legacy behavior keys: the temporal and flat keys of
// `motion`, `loops`, `effectAnimations`, `drag`, the legacy keys of `track`
// and `draggable`, `zoomable`, flat springs in `physics`, the legacy shapes
// of `transitions`, SVG's `gradientUnits`, and the interaction-state and
// media patches that hold any of them.
import 'dart:math' as math;

import '../behaviors.dart';
import '../json.dart';
import '../node.dart';
import '../node_patch.dart' show mergeNodePatch;
import '../values/paint.dart';
import 'legacy_animations.dart';
import 'legacy_read.dart';
import 'legacy_track.dart';
import 'migrate.dart';

List<NodeAnimation> _animationsOf(Json n) => [...?readList(jsonText(n['animations']))?.map(NodeAnimation.fromJson).nonNulls];

/// The motion's temporal keys (`duration`, `delay`, `curve`, `spring*`,
/// `enter*`, `replayKey`, `revealOnScroll`, `loop`, `repeat`, `phase`,
/// `paused`, `spin`, `spinRamp`, `keyframes`, `shimmer`, `rotateCurve`,
/// `fadeShare`, `pulseKey`), `loops` and `effectAnimations` → `animations`,
/// `transitions` and `shimmer`; its `opacity` and `blur` → the node's
/// opacity (multiplied in) and a `motionBlur` layer blur; `originX`/`originY`
/// → `alignment`; its flat path keys → `path`; the binding paths that
/// addressed any of them → where they went. One step: the old decoders read
/// these together, and the order of the resulting lists depends on all of
/// them.
final motionLegacyStep = MigrationStep(
  id: 'motion.legacy',
  description: 'legacy motion keys, loops and effectAnimations → animations, transitions, shimmer, motion, opacity',
  node: (n, s) {
    final motion = readMap(n['motion']);
    final hasLoops = n.containsKey('loops'), hasEffects = n.containsKey('effectAnimations');
    final rawBind = bindOf(n);
    final legacyBind = rawBind.keys.any((k) => k.startsWith('loops') || k.startsWith('effectAnimations') || k.startsWith('motion.'));
    final legacyMotion = motion != null && motion.keys.any((k) => !LegacyMotion.keys.contains(k));
    if (!hasLoops && !hasEffects && !legacyMotion && !legacyBind) return;

    // What the schema-2 decoders made of it.
    final fromMotion = LegacyAnimations.legacyMotion(n);
    final animations = LegacyAnimations.animations(n, fromMotion?.animations ?? const []);
    final transitions = LegacyAnimations.transitions(n, fromMotion?.transitions ?? const []);
    final shimmer = Shimmer.fromJson(n['shimmer']) ?? fromMotion?.shimmer;
    var bind = LegacyAnimations.migrateBind(rawBind, n);
    final motionOpacity = readDouble(motion?['opacity'])?.clamp(0.0, 1.0);
    final ownOpacity = readDouble(n['opacity']) ?? 1;
    bind = _migrateOpacityBind(bind, ownOpacity, motionOpacity ?? 1);
    // A bound legacy origin: one binding of the alignment.
    final ox = bind.remove('motion.originX'), oy = bind.remove('motion.originY');
    if (ox != null || oy != null) {
      final align = LegacyMotion.read(motion ?? const {}).alignment;
      final fx = ox == null ? '${writeDouble(align.x)}' : formulaOf(ox);
      final fy = oy == null ? '${writeDouble(align.y)}' : formulaOf(oy);
      if (fx == null || fy == null) {
        s.unconvertible(n, 'bind.motion.origin', {'motion.originX': ?ox, 'motion.originY': ?oy},
            instead: 'Bind "motion.alignment" to a formula giving [x, y].');
      } else {
        bind['motion.alignment'] = '\${= [$fx, $fy]}';
      }
    }
    final blur = motion != null && (motion.containsKey('blur') || rawBind.containsKey('motion.blur'));

    // Written where it differs from what the schema-3 decoders read.
    if (!jsonEquality.equals(animations, _animationsOf(n))) {
      putKey(n, 'animations', animations.isEmpty ? null : [for (final a in animations) a.toJson()], s);
    }
    // The deprecated `arc` (dropped by transition.arc): the own
    // transitions' and the motion's, on the transitions they are now.
    final arcs = <String, Object?>{
      for (final t in readList(n['transitions']) ?? const [])
        if (readMap(t) case final Json m when m['arc'] != null) '${m['property']}': m['arc'],
      if (fromMotion?.transitions.any((t) => t.property == 'motion') ?? false)
        if (readDouble(motion?['arc']) case final double a when a != 0) 'motion': jsonNum(a),
    };
    final transitionsJson = transitions.isEmpty
        ? null
        : [
            for (final t in transitions) {...t.toJson(), 'arc': ?arcs[t.property]},
          ];
    if (!jsonEquality.equals(transitions, Transition.listFromJson(n['transitions'])) || n['transitions'] is Map) {
      putKey(n, 'transitions', transitionsJson, s);
    }
    if (shimmer != Shimmer.fromJson(n['shimmer'])) putKey(n, 'shimmer', shimmer?.toJson(), s);
    putKey(n, 'loops', null, s);
    putKey(n, 'effectAnimations', null, s);
    if (motionOpacity != null) {
      final o = (ownOpacity.clamp(0.0, 1.0) * motionOpacity).toDouble();
      putKey(n, 'opacity', o == 1 ? null : writeDouble(o), s);
    }
    if (blur) {
      const id = AnimationPresets.motionBlurId;
      final radius = math.max(0.0, readDouble(motion['blur']) ?? 0);
      final decoration = <String, Object?>{...?readMap(n['decoration'])};
      decoration['effects'] = [
        ...?readList(decoration['effects'])?.where((e) => readMap(e)?['id'] != id),
        Effect(type: EffectType.layerBlur, id: id, blurRadius: radius).toJson(),
      ];
      putKey(n, 'decoration', decoration, s);
    }
    if (legacyMotion) putKey(n, 'motion', LegacyMotion.json(motion), s);
    putBind(n, bind, s);
  },
);

/// [bind] with a legacy `motion.opacity` binding as the node's `opacity`:
/// the two multiplied ([own] and [motion] are the static values), or the
/// motion's alone when the node's is 1 and unbound.
Map<String, String> _migrateOpacityBind(Map<String, String> bind, double own, double motion) {
  final m = bind['motion.opacity'];
  final node = bind['opacity'];
  if (m == null) {
    // The node's bound opacity times the motion's static one.
    final f = node == null || motion == 1 ? null : formulaOf(node);
    return f == null ? bind : {...bind, 'opacity': '\${= ($f) * ${writeDouble(motion)}}'};
  }
  final out = {...bind}..remove('motion.opacity');
  if (node == null && own == 1) {
    out['opacity'] = m;
    return out;
  }
  final a = node == null ? writeDouble(own).toString() : formulaOf(node);
  final b = formulaOf(m);
  out['opacity'] = a == null || b == null ? m : '\${= ($a) * ($b)}';
  return out;
}

/// `drag` → `track` (its `track`), `dismissible` (`release: dismiss`),
/// `reorderHandle` (`reorder: true`) or `pan` (any other), each with its
/// old defaults written out; `drag.*` binding paths → the new behavior's.
/// A node's own `track`, `dismissible` or `pan` wins over the one its
/// `drag` gives.
final dragSplitStep = MigrationStep(
  id: 'drag.split',
  description: 'drag → track / dismissible / pan / reorderHandle',
  node: (n, s) {
    final bind = bindOf(n);
    if (!n.containsKey('drag') && !bind.keys.any((k) => k.startsWith('drag.'))) return;
    final d = readMap(n['drag']);
    if (readMap(n['track']) == null) {
      if (LegacyDrag.trackJson(d) case final Json t) putKey(n, 'track', t, s);
    }
    if (DismissibleBehavior.fromJson(n['dismissible']) == null) {
      if (LegacyDrag.dismissibleJson(d) case final Json j) putKey(n, 'dismissible', j, s);
    }
    if (Pan.fromJson(n['pan']) == null) {
      if (LegacyDrag.panJson(d) case final Json j) putKey(n, 'pan', j, s);
    }
    if (!(readBool(n['reorderHandle']) ?? false) && LegacyDrag.isReorderHandle(d)) putKey(n, 'reorderHandle', true, s);
    putKey(n, 'drag', null, s);
    putBind(n, LegacyAnimations.migrateDragBind(bind, {...n, 'drag': ?d}), s);
  },
);

/// A track's legacy keys (`endAngle`, `endless`, `jumpOnTap`, `wheel`,
/// `keyboard`, `momentum`, `friction`, `gain`, a path string with
/// `viewBoxWidth`/`viewBoxHeight` and `orientToPath`/`orientUpright`,
/// `write: false`, `settleStiffness`/`settleDamping`) → the schema-3 track;
/// `write: false` binds `track.value` to the variable.
final trackLegacyStep = MigrationStep(
  id: 'track.legacy',
  description: 'legacy track keys → the schema-3 track',
  node: (n, s) {
    final t = readMap(n['track']);
    if (t == null) return;
    final legacy = t.keys.any((k) => !LegacyTrack.keys.contains(k)) || t['path'] is String || LegacyPhysics.isLegacy(readMap(t['physics']));
    if (!legacy) return;
    final bind = bindOf(n);
    if (LegacyTrack.readsOnly(t) && !bind.containsKey('track.value')) {
      putBind(n, {...bind, 'track.value': '\${${readString(t['variable'])!.trim()}}'}, s);
    }
    putKey(n, 'track', LegacyTrack.read(t), s);
  },
);

/// `zoomable: true` → `transformGesture: {target: content, pan: whenZoomed}`
/// when the node has none.
final zoomableStep = MigrationStep(
  id: 'zoomable',
  description: 'zoomable: true → transformGesture (content, pan when zoomed)',
  node: (n, s) {
    if (!n.containsKey('zoomable')) return;
    final on = readBool(n['zoomable']) ?? false;
    if (on && readMap(n['transformGesture']) == null) {
      putKey(n, 'transformGesture', const {'target': 'content', 'pan': 'whenZoomed'}, s);
    }
    putKey(n, 'zoomable', null, s);
  },
);

/// A draggable's old names: `whileDragging` → `childWhenDragging`,
/// `feedbackNodeId` → `feedback`, `feedbackAnchor`/`dragAnchorStrategy`
/// (`grab`, `pointer`) → `dragAnchor` (`child`, `center`), and its return
/// spring (`returnSpring: true` with `spring`, `springStiffness`/
/// `springDamping` or `physics`) → `returnSpring`.
final draggableLegacyStep = MigrationStep(
  id: 'draggable.legacy',
  description: 'draggable old names and return spring shapes → the schema-3 draggable',
  node: (n, s) {
    final d = readMap(n['draggable']);
    if (d == null || !LegacyDragSource.isLegacy(d)) return;
    putKey(n, 'draggable', LegacyDragSource.read(d).toJson(), s);
  },
);

/// A `physics` object's flat spring keys (`stiffness`, `damping`, `mass`,
/// `bounce`, `duration`) → its `spring`, wherever in the node.
final physicsSpringStep = MigrationStep(
  id: 'physics.flatSpring',
  description: 'physics flat spring keys → physics.spring',
  node: (n, s) => eachMap(n, (m, at) {
    for (final e in [...m.entries]) {
      if (e.key != 'physics' || !LegacyPhysics.isLegacy(readMap(e.value))) continue;
      final out = LegacyPhysics.migrate(readMap(e.value));
      s.rewrite('$at/physics', e.value, out);
      m['physics'] = out;
    }
  }),
);

/// The legacy `transitions` object (`{style, opacity, size}`) and a
/// property → timing map → the list of transitions.
final transitionsLegacyStep = MigrationStep(
  id: 'transitions.legacy',
  description: 'transitions object → list',
  node: (n, s) {
    final list = LegacyTransitions.read(n['transitions']);
    if (list == null) return;
    // A map entry's deprecated `arc` stays on its transition (transition.arc
    // drops it).
    final raw = readMap(n['transitions']) ?? const <String, Object?>{};
    putKey(n, 'transitions', list.isEmpty ? null : [for (final t in list) {...t.toJson(), 'arc': ?readMap(raw[t.property])?['arc']}], s);
  },
);

/// SVG's `gradientUnits: "subpath"` on a paint → `gradientPerSubpath: true`.
final gradientUnitsStep = MigrationStep(
  id: 'paint.gradientUnits',
  description: 'gradientUnits → gradientPerSubpath',
  node: (n, s) => eachMap(n, (m, at) {
    if (!m.containsKey('gradientUnits') || m.containsKey('nodes')) return;
    final old = m.remove('gradientUnits');
    final sub = old is String && old.toLowerCase() == 'subpath';
    if (sub && readBool(m['gradientPerSubpath']) == null) m['gradientPerSubpath'] = true;
    s.rewrite('$at/gradientUnits', old, sub ? true : null, sub ? 'gradientUnits: subpath → gradientPerSubpath: true' : 'gradientUnits dropped (not subpath)');
  }),
);

/// The patches of the interaction states (`states.<state>.<node id>`) and
/// media rules (`media[i].patch`) that hold legacy keys: each re-expressed
/// as the patch of the migrated node that gives the same node as the
/// schema-2 decoder gave the patched one (its old reading of
/// `motion.opacity` in a state patch, the patch's opacity times it,
/// included).
MigrationStep patchesStep(List<MigrationStep> nodeSteps) => MigrationStep(
      id: 'patches.legacy',
      description: 'state and media patches with legacy keys → schema-3 patches',
      document: (doc, s) {
        final nodes = readMap(doc['nodes']) ?? const <String, Object?>{};
        Json migrate(Json node) {
          final out = copyJson(node) as Json;
          for (final step in nodeSteps) {
            step.node!(out, _silent(step));
          }
          return out;
        }

        Json? repatch(Json? target, Json patch) {
          if (target == null) return null;
          final base = {...target}
            ..remove('states')
            ..remove('media');
          final after = migrate(mergeNodePatch(base, patch));
          final same = migrate(mergeNodePatch(base, const {}));
          return _prune(same, diffPatch(same, after) ?? const {});
        }

        bool hasLegacy(Json patch) {
          final probe = migrate(patch);
          return !jsonEquality.equals(probe, patch);
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
                var patch = readMap(p.value);
                if (patch == null) continue;
                patch = _statePatchOpacity(patch);
                if (!hasLegacy(patch) && jsonEquality.equals(patch, p.value)) continue;
                final out = repatch(readMap(nodes[p.key]), patch);
                if (out == null) continue;
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
              if (rule == null || patch == null || !hasLegacy(patch)) continue;
              final out = repatch(node, patch);
              if (out == null) continue;
              s.rewrite('/nodes/${e.key}/media/$i/patch', patch, out);
              rule['patch'] = out;
            }
          }
        }
      },
    );

/// [patch] (over node JSON [base]) without the removals (`null`s) that don't
/// change the node it gives: a default the migrated value no longer spells
/// out.
Json _prune(Json base, Json patch) {
  Node? node(Json p) => Node.fromJson(mergeNodePatch(base, p), id: 'n');
  final want = node(patch);
  var out = patch;
  void visit(List<String> path, Json at) {
    for (final e in [...at.entries]) {
      final here = [...path, e.key];
      if (e.value is Map) {
        visit(here, readMap(e.value)!);
      } else if (e.value == null) {
        final without = _removeAt(out, here);
        if (node(without) == want) out = without;
      }
    }
  }

  visit(const [], patch);
  return out;
}

Json _removeAt(Json m, List<String> path) {
  final out = <String, Object?>{...m};
  if (path.length == 1) {
    out.remove(path.first);
    return out;
  }
  final child = readMap(out[path.first]);
  if (child == null) return out;
  final next = _removeAt(child, path.sublist(1));
  if (next.isEmpty) {
    out.remove(path.first);
  } else {
    out[path.first] = next;
  }
  return out;
}

/// A state patch's legacy `motion.opacity` as the node's `opacity` (times
/// the patch's own), as the schema-2 state decoder read it.
Json _statePatchOpacity(Json patch) {
  final motion = readMap(patch['motion']);
  final o = readDouble(motion?['opacity']);
  if (motion == null || o == null) return patch;
  final own = readDouble(patch['opacity']);
  return {
    ...patch,
    'motion': {...motion}..remove('opacity'),
    'opacity': writeDouble((o * (own ?? 1)).clamp(0.0, 1.0)),
  };
}

final _silentReport = <MigrationStep, MigrationScope>{};
MigrationScope _silent(MigrationStep step) => _silentReport[step] ??= MigrationScope.silent(step);

