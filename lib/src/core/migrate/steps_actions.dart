// Steps for the legacy action and trigger types: `playAnimation`,
// `animateVariable`, `setVariable.animateMs`, `controlDrag` and the `clock`
// trigger. They rewrite every action and trigger object anywhere in a node
// (reactions, nested chains, props holding reactions).
import '../actions.dart';
import '../behaviors.dart' show AnimationCurve;
import '../custom_paint.dart' show Expr;
import '../catalog.dart';
import '../json.dart';
import '../triggers.dart';
import 'legacy_read.dart';
import 'migrate.dart';

/// The keys every action has ([ActionCommon]).
Json _common(Json m) => {
      for (final k in const ['enabled', 'nonBlocking', 'when'])
        if (m.containsKey(k)) k: m[k],
    };

/// [json] as the core catalog decodes and encodes it.
Json _canonical(Json json) => ActionDef.fromJson(json, catalog: Catalog.core)?.toJson() ?? json;

String _s(Json m, String k, [String fallback = '']) => switch (m[k]) {
      final String s => s,
      final num n => '$n',
      final bool b => '$b',
      _ => fallback,
    };

/// Replaces the contents of [target] with [value]'s.
void _replace(Json target, Json value) {
  target
    ..clear()
    ..addAll(value);
}

/// The keys of a node that hold actions and triggers: its reactions, its
/// props (a prop may hold reactions) and the patches of its states and
/// media rules. Keys a node doesn't model are kept as they are.
const _actionKeys = ['actions', 'props', 'states', 'media'];

/// Calls [visit] with every map under a node's [_actionKeys].
void _eachActionMap(Json node, void Function(Json map, String at) visit) {
  for (final k in _actionKeys) {
    if (node.containsKey(k)) eachMap(node[k], visit, '/$k');
  }
}

/// Rewrites every action object in a node with [rewrite] (null leaves it).
void _eachAction(Json node, MigrationScope s, String type, Json? Function(Json action, MigrationScope s, String at) rewrite) {
  _eachActionMap(node, (m, at) {
    if (m['type'] != type || at.endsWith('/trigger')) return;
    final old = {...m};
    final out = rewrite(m, s, at);
    if (out == null) return;
    _replace(m, out);
    s.rewrite(at, old, out);
  });
}

/// `playAnimation {node, animation}` → `animate {node, animation, from: 0}`
/// (`controller.forward(from: 0)`).
final playAnimationStep = MigrationStep(
  id: 'action.playAnimation',
  description: 'playAnimation → animate (forward from 0)',
  node: (node, s) => _eachAction(node, s, 'playAnimation', (m, s, at) => _canonical({
        'type': AnimateAction.typeName,
        'node': _s(m, 'node'),
        'animation': _s(m, 'animation'),
        'from': '0',
        ..._common(m),
      })),
);

/// `animateVariable` (`mode` play / pause / resume / stop / seek) →
/// `animate {variable}` (`animateTo` / `stop` / `forward` / `stop` / `set`).
final animateVariableStep = MigrationStep(
  id: 'action.animateVariable',
  description: 'animateVariable → animate {variable}',
  node: (node, s) => _eachAction(node, s, 'animateVariable', (m, s, at) {
    final mode = _s(m, 'mode', 'play');
    final ms = readInt(m['durationMs']) ?? 1000;
    final bound = _s(m, 'duration');
    return _canonical({
      'type': AnimateAction.typeName,
      'variable': _s(m, 'variable'),
      'command': switch (mode) {
        'pause' || 'stop' => AnimateCommand.stop.name,
        'resume' => AnimateCommand.forward.name,
        'seek' => AnimateCommand.set.name,
        _ => AnimateCommand.animateTo.name,
      },
      'from': _s(m, 'from'),
      'target': _s(m, 'to', '1'),
      'duration': bound.trim().isEmpty ? '$ms' : bound,
      'curve': ?m['curve'],
      ..._common(m),
    });
  }),
);

/// `setVariable` with `animateMs` (a glide): `animate {variable, command:
/// animateTo, target, duration, curve}` for a `set`, `add` or `subtract` of
/// a whole variable by a value read as a formula; any other glide sets at
/// once (a behavior change).
final setVariableGlideStep = MigrationStep(
  id: 'action.setVariable.animateMs',
  description: 'setVariable glide (animateMs) → animate animateTo',
  node: (node, s) => _eachAction(node, s, 'setVariable', (m, s, at) {
    if (!m.containsKey('animateMs') && !m.containsKey('curve')) return null;
    final ms = _s(m, 'animateMs').trim();
    final plain = {...m}
      ..remove('animateMs')
      ..remove('curve');
    if (ms.isEmpty || ms == '0') return plain;
    final name = _s(m, 'variable').trim();
    final write = ValueWrite.fromJson(m);
    final value = formulaOf(write.value);
    final whole = name.isNotEmpty && RegExp(r'^[A-Za-z_]\w*$').hasMatch(name) && write.index.isEmpty && write.mapKey.isEmpty;
    final target = !whole || value == null
        ? null
        : switch (write.op) {
            WriteOp.set => write.value,
            WriteOp.add => '\${= $name + ($value)}',
            WriteOp.subtract => '\${= $name - ($value)}',
            _ => null,
          };
    if (target == null) {
      // Only a number variable set whole ever glided: a set, add or subtract
      // whose value isn't one formula.
      final glided = whole && const [WriteOp.set, WriteOp.add, WriteOp.subtract].contains(write.op);
      if (glided) {
        s.behaviorChange(
            'A setVariable glide (animateMs: $ms) whose value is not one formula now sets the number at once.',
            path: at,
            old: {'animateMs': m['animateMs'], 'curve': ?m['curve']},
            instead: 'Glide a number variable with {"type": "animate", "variable": "$name", "command": "animateTo", "target": "<formula>", "duration": "$ms"}.');
      }
      return plain;
    }
    return _canonical({
      'type': AnimateAction.typeName,
      'variable': name,
      'command': AnimateCommand.animateTo.name,
      'target': target,
      'duration': ms,
      'curve': (AnimationCurve.parse(m['curve']) ?? AnimationCurve.linear).name,
      ..._common(m),
    });
  }),
);

/// `controlDrag` (one action over three render objects) → the typed action
/// of its command: `step` → `controlTrack`; `fling` (as `dismiss`),
/// `returnFrom`, `shake` → `controlDismissible`; `reset`, `zoom` (as
/// `scaleBy`), `pose` (as `animateTo`) → `controlTransform`.
final controlDragStep = MigrationStep(
  id: 'action.controlDrag',
  description: 'controlDrag → controlTrack / controlDismissible / controlTransform',
  node: (node, s) => _eachAction(node, s, 'controlDrag', (m, s, at) {
    final command = readString(m['command']) ?? 'fling';
    final mapped = switch (command) {
      'fling' => 'dismiss',
      'returnFrom' || 'shake' || 'reset' || 'step' => command,
      'zoom' => 'scaleBy',
      'pose' => 'animateTo',
      _ => null,
    };
    final type = switch (command) {
      'step' => ControlTrackAction.typeName,
      'reset' || 'zoom' || 'pose' => ControlTransformAction.typeName,
      _ => ControlDismissibleAction.typeName,
    };
    return _canonical({...m, 'type': type, 'command': ?mapped});
  }),
);

/// The `clock` trigger → `timer`: `every` is `intervalMs` (a bare formula as
/// `${= formula}`; none: 0), `runWhen` the `when`; `lookaheadMs` was never
/// read.
final clockTriggerStep = MigrationStep(
  id: 'trigger.clock',
  description: 'clock trigger → timer (every → intervalMs, runWhen → when)',
  node: (node, s) => _eachActionMap(node, (m, at) {
    if (!at.endsWith('/trigger') || m['type'] != 'clock') return;
    final old = {...m};
    final when = readString(m['when']) ?? '';
    final every = m['every'];
    final json = <String, Object?>{
      for (final e in m.entries)
        if (!const {'type', 'every', 'runWhen', 'lookaheadMs', 'intervalMs', 'when'}.contains(e.key)) e.key: e.value,
      'type': TriggerType.timer.name,
      'intervalMs': switch (every) {
        final num n => n.round(),
        final String t when t.trim().isNotEmpty =>
          Expr.isSource(t.trim()) ? t.trim() : (num.tryParse(t.trim())?.round() ?? '\${= ${t.trim()}}'),
        _ => 0,
      },
      'when': when.isEmpty ? (readString(m['runWhen']) ?? '') : when,
    };
    _replace(m, Trigger.fromJson(json)?.toJson() ?? json);
    s.rewrite(at, old, m);
  }),
);
