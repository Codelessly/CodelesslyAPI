// v1 behaviours (BaseNode's motion, pulse, loopAnimation, transitions,
// inkWell, interactionStates, drag and drop...) → v2's flat behaviour keys
// (CodelesslyAPI/v2/lib/src/behaviours.dart). Values come off v1's decoded
// models, so v1's defaults and legacy formats are resolved by v1 itself.
import 'package:codelessly_api/codelessly_api.dart';

import 'migrate.dart';

/// The v1 BaseNode keys [migrateBehaviours] consumes.
const List<String> behaviourKeys = [
  'motion', 'drawScale', 'loopAnimation', 'pulse', 'transitionMs', 'transition', 'sizeTransition', 'inkWell', //
  'interactionStates', 'tooltip', 'ignorePointer', 'zoomable', 'floating', 'heroTag', 'heroFlight', 'flightKey',
  'draggable', 'dropTarget', 'drag', 'reveal', 'strokePath', 'effectAnimations', 'particles',
];

/// [j] with its keys renamed by [names] (others kept).
Json _renamed(Map j, Map<String, String> names) => {
  for (final e in j.entries)
    names['${e.key}'] ?? '${e.key}': e.value is Map ? Map<String, Object?>.from(e.value as Map) : e.value,
};

/// A v1 hex color (`#RRGGBB` or `#AARRGGBB`) as v2's `#AARRGGBB`.
String? _hex(Object? v) {
  if (v is! String) return null;
  var h = v.trim().replaceFirst('#', '').toUpperCase();
  if (h.length == 6) h = 'FF$h';
  return h.length == 8 && int.tryParse(h, radix: 16) != null ? '#$h' : null;
}

Json _motion(MotionModel m) {
  final j = _renamed(m.toJson(), const {'durationMs': 'duration', 'delayMs': 'delay', 'spinRampMs': 'spinRamp'});
  if (m.enterFrom case final MotionModel from) {
    final f = _motion(from);
    // On a path the entrance starts at its progress even when it's 0.
    if (m.hasPath) f['pathProgress'] = from.pathProgress;
    j['enterFrom'] = f;
  }
  return j;
}

Json _loop(LoopAnimation l) =>
    _renamed(l.toJson(), const {'durationMs': 'duration', 'delayMs': 'delay'})..['type'] = l.type.name;

/// A pulse is a loop: a motion pulse scales and fades back and forth, a
/// relative one fades the node's opacity down to a fraction and back, both
/// eased in and out.
Json _pulse(PulseModel p) => switch (p) {
  MotionPulseModel() => {
    'type': p.scaleFrom == p.scaleTo ? 'fade' : (p.opacityFrom == p.opacityTo ? 'scale' : 'pulse'),
    'duration': p.periodMs,
    if (p.reverse) 'reverse': true,
    'curve': 'easeInOut',
    if (p.scaleFrom != 1) 'scaleFrom': p.scaleFrom,
    if (p.scaleTo != 1) 'scaleTo': p.scaleTo,
    if (p.opacityFrom != 1) 'opacityFrom': p.opacityFrom,
    if (p.opacityTo != 1) 'opacityTo': p.opacityTo,
  },
  _ => {
    'type': 'fade',
    'duration': p.durationMillis,
    'reverse': true,
    'curve': 'easeInOut',
    'opacityFrom': p.minOpacity,
  },
};

Json _transition(NodeTransition t) => {'duration': t.durationMillis, 'curve': t.curve.name};

Json _strokePath(StrokePath p) {
  final j = _renamed(p.toJson(), const {'dash': 'dashPattern'});
  j['points'] = [
    for (final pt in p.points) [pt[0], pt[1]],
  ];
  final color = _hex(p.color);
  if (color == null || color == '#FFFFFFFF') {
    j.remove('color');
  } else {
    j['color'] = color;
  }
  return j;
}

Json _drag(DragModel d) {
  final j = _renamed(d.toJson(), const {'snapBackMs': 'snapBack', 'flyOutMs': 'flyOut'});
  if (d.track case final DragTrackModel t) j['track'] = Map<String, Object?>.from(t.toJson());
  return j;
}

Json _particles(ParticleEmitter p) {
  final j = _renamed(p.toJson(), const {'emitMs': 'emit', 'lifetimeMs': 'lifetime'});
  if (j['colors'] is List) j['colors'] = [...(j['colors'] as List).map(_hex).nonNulls];
  return j;
}

/// The v2 behaviour keys of [m]'s node, its v1 keys taken. [states]: also
/// convert its interaction states (off while converting a state's own
/// targets).
Json migrateBehaviours(V1Node m, {bool states = true}) {
  final n = m.n;
  final raw = m.raw;
  final out = <String, Object?>{};
  for (final k in behaviourKeys) {
    if (k != 'interactionStates' || states) m.take(k);
  }
  // The editor's resize-handle lock: `false` (the default some nodes still
  // write) carries nothing; `true` is editor state, left under `v1`.
  if (raw['aspectRatioLock'] == false) m.take('aspectRatioLock');

  if (n.motion case final MotionModel motion) out['motion'] = _motion(motion);
  if (n.drawScale != 1 && n.drawScale.isFinite && n.drawScale > 0) out['scale'] = roundNum(n.drawScale);
  final loops = [
    if (n.loopAnimation case final LoopAnimation l) _loop(l),
    if (n.pulse case final PulseModel p) _pulse(p),
  ];
  if (loops.isNotEmpty) out['loops'] = loops;
  final transitions = {
    if (n.transitionMs > 0) 'style': {'duration': n.transitionMs},
    if (n is BlendMixin && n.transition != null) 'opacity': _transition(n.transition!),
    if (n.sizeTransition case final NodeTransition t when t.durationMillis > 0) 'size': _transition(t),
  };
  if (transitions.isNotEmpty) out['transitions'] = transitions;
  if (n is BlendMixin && n.inkWell != null) {
    final ink = n.inkWell!;
    out['inkWell'] = {
      if (ink.overlayColor case final ColorRGBA c) 'overlayColor': V1Node.rgba(c),
      if (ink.splashColor case final ColorRGBA c) 'splashColor': V1Node.rgba(c),
      if (ink.highlightColor case final ColorRGBA c) 'highlightColor': V1Node.rgba(c),
      if (ink.hoverColor case final ColorRGBA c) 'hoverColor': V1Node.rgba(c),
      if (ink.focusColor case final ColorRGBA c) 'focusColor': V1Node.rgba(c),
    };
  }
  if (states && n.interactionStates.isNotEmpty) {
    final s = _states(m);
    if (s.isNotEmpty) out['states'] = s;
  }
  if (n.tooltip.trim().isNotEmpty) out['tooltip'] = n.tooltip;
  if (n.ignorePointer) out['ignorePointer'] = true;
  if (n.zoomable) out['zoomable'] = true;
  if (n.floating) out['floating'] = true;
  if (n.heroTag case final String tag when tag.isNotEmpty) {
    final flight = n.heroFlight ?? HeroFlight.standard;
    out['hero'] = flight == HeroFlight.standard ? tag : {'tag': tag, 'flight': flight.name};
  }
  if (n.flightKey.isNotEmpty) out['flightKey'] = n.flightKey;
  if (n.draggable case final DraggableModel d) out['draggable'] = Map<String, Object?>.from(d.toJson());
  if (n.dropTarget case final DropTargetModel d) {
    out['dropTarget'] = _renamed(d.toJson(), const {'hoverDelayMs': 'hoverDelay'});
  }
  if (n.drag case final DragModel d) out['drag'] = _drag(d);
  if (n.reveal case final RevealModel r) {
    out['reveal'] = _renamed(r.toJson(), const {'durationMs': 'duration', 'delayMs': 'delay'});
  }
  if (n.strokePath case final StrokePath p) out['strokePath'] = _strokePath(p);
  if (n.effectAnimations.isNotEmpty) {
    out['effectAnimations'] = [
      for (final e in n.effectAnimations) _renamed(e.toJson(), const {'durationMs': 'duration', 'delayMs': 'delay'}),
    ];
  }
  if (n.particles case final ParticleEmitter p) out['particles'] = _particles(p);
  return out;
}

/// v1's interaction states patch v1 node JSON; v2's patch v2 node JSON. Each
/// target is migrated as it is and as the state patches it, and the v2
/// patch is the difference.
Json _states(V1Node m) {
  final out = <String, Object?>{};
  m.n.interactionStates.forEach((state, overrides) {
    final perNode = <String, Object?>{};
    overrides.forEach((id, patch) {
      final target = m.nodes[id];
      if (target == null) return;
      final base = migrateNodeAlone(target, m);
      final targetJson = target.toJson();
      final patchedJson = PropertyOverridePatch.apply(
        targetJson,
        _withPaintIds(patch, targetJson, '$id-${state.name}'),
      );
      BaseNode? patched;
      try {
        patched = NodeJsonConverter().fromJson(patchedJson);
      } catch (_) {
        patched = null;
      }
      if (patched == null) {
        m.report.unmapped.update('${m.n.type}.interactionStates.$id', (v) => v + 1, ifAbsent: () => 1);
        return;
      }
      patched.parentID = target.parentID;
      final after = migrateNodeAlone(patched, m);
      final diff = _diff(base, after);
      if (diff != null) perNode[id] = diff;
    });
    if (perNode.isNotEmpty) out[state.name] = perNode;
  });
  return out;
}

/// [patch] with the ids of the paints it replaces: a patched paint without
/// one takes the id of the paint at its place, or one made from [prefix]
/// (v1 would make up a random one).
Map _withPaintIds(Map patch, Map target, String prefix) {
  List paints(String key, List patched) {
    final before = target[key] is List ? target[key] as List : const [];
    return [
      for (var i = 0; i < patched.length; i++)
        switch ((patched[i], i < before.length ? before[i] : null)) {
          (final Map p, final Map b) when p['id'] == null && b['id'] != null => {...p, 'id': b['id']},
          (final Map p, _) when p['id'] == null => {...p, 'id': '$prefix-$key-$i'},
          (final p, _) => p,
        },
    ];
  }

  return {
    for (final e in patch.entries)
      e.key: switch ((e.key, e.value)) {
        ('fills' || 'strokes' || 'foregroundFills', final List patched) => paints(e.key as String, patched),
        _ => e.value,
      },
  };
}

/// [n] migrated on its own (its place in [context]'s document), without its
/// interaction states and leftovers.
Json migrateNodeAlone(BaseNode n, V1Node context) {
  final j = V1Node(n, context.nodes[n.parentID], context.nodes, MigrationReport(), states: false).run();
  return j..remove('v1');
}

/// The merge patch from [a] to [b] (null when equal).
Json? _diff(Map a, Map b) {
  final out = <String, Object?>{};
  for (final e in b.entries) {
    final x = a[e.key], y = e.value;
    if (x is Map && y is Map) {
      final d = _diff(x, y);
      if (d != null) out['${e.key}'] = d;
    } else if (!a.containsKey(e.key) || !_eq(x, y)) {
      out['${e.key}'] = y;
    }
  }
  for (final k in a.keys) {
    if (!b.containsKey(k)) out['$k'] = null;
  }
  return out.isEmpty ? null : out;
}

bool _eq(Object? a, Object? b) {
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_eq(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Map && b is Map) return _diff(a, b) == null && a.length == b.length;
  return a == b;
}
