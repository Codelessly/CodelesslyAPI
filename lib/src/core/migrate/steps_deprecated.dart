// Steps for the one-app fields schema 2 kept deprecated
// (docs/design/02–04, "Not yet migrated"). None has a generic schema-3
// construct that behaves the same (the design documents say why, field by
// field), so each is dropped: a value that did something is kept on the node
// as `legacy.<behavior>.<field>`, reported with what to write instead, and
// reported as a behavior change naming the reference apps that used it. A
// value that did nothing (a default, a fine-mode setting without a fine step)
// is dropped as a rewrite.
import '../json.dart';
import 'legacy_read.dart';
import 'migrate.dart';

/// One deprecated field: its default (a value equal to it, or absent, did
/// nothing), what to write instead, and the reference apps that used it.
final class _Field {
  const _Field(this.key, this.fallback, this.instead, this.apps, {this.inert});
  final String key;
  final Object? fallback;
  final String instead;
  final String apps;

  /// Whether the value did nothing in this object anyway (beside the default).
  final bool Function(Json owner)? inert;
}

bool _isDefault(Object? v, Object? fallback) =>
    v == null || jsonEquality.equals(v, fallback) || (fallback is num && readDouble(v) == fallback.toDouble());

/// Drops [fields] from the object at [key] of node [n] (and their bindings
/// `<key>.<field>`), reporting each as [_Field] says. [what] names the
/// behavior in messages.
void _drop(Json n, MigrationScope s, String key, String what, List<_Field> fields) {
  final owner = readMap(n[key]);
  final bind = bindOf(n);
  final bound = {for (final f in fields) if (bind.containsKey('$key.${f.key}')) f.key: bind['$key.${f.key}']};
  if (owner == null) {
    if (bound.isNotEmpty) putBind(n, {...bind}..removeWhere((k, _) => fields.any((f) => k == '$key.${f.key}')), s);
    return;
  }
  var changed = false;
  for (final f in fields) {
    if (!owner.containsKey(f.key) && !bound.containsKey(f.key)) continue;
    final v = owner.remove(f.key);
    changed = true;
    final inert = _isDefault(v, f.fallback) && !bound.containsKey(f.key) || (f.inert?.call({...owner, f.key: v}) ?? false);
    if (inert) {
      s.rewrite('/$key/${f.key}', v, null, '$what.${f.key} dropped: it did nothing here.');
      continue;
    }
    final name = '$key.${f.key}';
    s.unconvertible(n, name, bound.containsKey(f.key) ? {'value': v, 'bind': bound[f.key]} : v,
        path: '/$key/${f.key}',
        instead: f.instead,
        message: '`$name` (deprecated, one app) has no schema-3 form; kept as `legacy.$name`.');
    s.behaviorChange('`$name` no longer acts: ${f.instead}', path: '/$key/${f.key}', old: v, instead: 'Used by: ${f.apps}.');
  }
  if (changed) n[key] = owner;
  if (bound.isNotEmpty) putBind(n, {...bind}..removeWhere((k, _) => fields.any((f) => k == '$key.${f.key}')), s);
}

bool _noFine(Json t) => (readDouble(t['fineStep']) ?? 0) <= 0;

/// `track`: `defaultValue`, `doubleTapValues`, `parkedProgress`, the four
/// fine-mode fields, `smooth`, `gain` (round an arc followed by angle).
final trackOneAppStep = MigrationStep(
  id: 'track.oneApp',
  description: 'deprecated track fields dropped',
  node: (n, s) {
    _drop(n, s, 'track', 'track', [
    const _Field('defaultValue', null,
        'Give the variable that value (it placed the node while the variable had none, and on a canvas without values); to reset on a double tap, a doubleTap reaction: {"trigger": {"type": "doubleTap"}, "actions": [{"type": "controlTrack", "command": "animateTo", "value": "<value>"}]} (it takes part in the gesture arena with the drag).',
        'lamplight (double tap); set by up to 12 build sources as the rest value'),
    const _Field('doubleTapValues', [],
        'A doubleTap reaction whose controlTrack animateTo value cycles: "\${= v == a ? b : a}".', 'lamplight'),
    const _Field('parkedProgress', null,
        'Bind "track.value" to the value to draw at while the variable is empty or out of range.', 'apiary'),
    _Field('fineStep', 0,
        'A boolean variable set by keyDown/keyUp (Shift) and a hold reaction, bound into "track.step" and "track.pixelsPerRange".',
        'cutroom, cutroom_v2, darkroom'),
    _Field('finePixelsPerRange', 0, 'See fineStep.', 'cutroom_v2, darkroom', inert: _noFine),
    _Field('fineHold', 380, 'See fineStep.', 'cutroom_v2', inert: _noFine),
    _Field('fineVariable', '', 'See fineStep: the boolean variable is the one you set.', 'darkroom', inert: _noFine),
    const _Field('smooth', false, '"detent": 1 with a settle spring is the nearest (approximate).', 'safecracker'),
    _Field('gain', 1, 'Change "sweepAngle" (the turn for the whole range) instead.', 'safecracker',
        inert: (t) => t['shape'] != 'arc' || (t['input'] != null && t['input'] != 'follow')),
    ]);
  },
);

/// The deprecated follow fields `dismissible` and `pan` share.
const _followFields = [
  _Field('rotateFactor', 0, 'Bind "motion.rotate" to the drag offset: "\${= dismiss.dx * k}" (degrees).', 'flashcards'),
  _Field('originX', 0, 'Set "motion.alignment".', 'flashcards'),
  _Field('originY', 0, 'Set "motion.alignment".', 'flashcards'),
  _Field('shakeWhenDisabled', false,
      'A dragEnd reaction with "when" the drag is refused playing a `shake` animation preset.', 'flashcards'),
  _Field('disabledFollow', 0,
      'Stay enabled; bind "resistance" and unreachable "dismissThresholds" to the condition.', 'flashcards'),
  _Field('shareAs', '', 'Use xVariable/yVariable (pan), or a drag reaction writing the values you share.',
      'flashcards, gesture_lab'),
  _Field('follow', true, 'Remove the behavior and react to the plain drag and dragEnd triggers.', 'none counted'),
];

/// `dismissible`: the follow fields and `restX`, `restY`, `xVariable`,
/// `yVariable`, `flyOutRotate`.
final dismissibleOneAppStep = MigrationStep(
  id: 'dismissible.oneApp',
  description: 'deprecated dismissible fields dropped',
  node: (n, s) => _drop(n, s, 'dismissible', 'dismissible', [
    ..._followFields,
    const _Field('restX', 0, 'Bind "motion.translateX" for the rest offset.', 'none counted'),
    const _Field('restY', 0, 'Bind "motion.translateY" for the rest offset.', 'none counted'),
    const _Field('xVariable', '', 'A drag reaction writing "\${result.dx}".', 'none counted'),
    const _Field('yVariable', '', 'A drag reaction writing "\${result.dy}".', 'none counted'),
    const _Field('flyOutRotate', 0, 'An animation the dismissed reaction plays (motion.rotate track).', 'flashcards'),
  ]),
);

/// `pan`: the follow fields.
final panOneAppStep = MigrationStep(
  id: 'pan.oneApp',
  description: 'deprecated pan fields dropped',
  node: (n, s) => _drop(n, s, 'pan', 'pan', _followFields),
);

/// A path's `pacing` (`area`) and `focus` (motion and track paths), and the
/// `uprightFlip` orientation (now `upright`).
final pathOneAppStep = MigrationStep(
  id: 'path.oneApp',
  description: 'path pacing, focus and uprightFlip dropped',
  node: (n, s) {
    for (final owner in const ['motion', 'track']) {
      final o = readMap(n[owner]);
      final path = readMap(o?['path']);
      if (o == null || path == null) continue;
      final at = '/$owner/path';
      var changed = false;
      final pacing = path.remove('pacing'), focus = path.remove('focus');
      if (pacing != null || focus != null) {
        changed = true;
        if (pacing == 'area') {
          s.unconvertible(n, '$owner.path.pacing', {'pacing': pacing, 'focus': ?focus},
              path: '$at/pacing',
              instead: 'Bind "$owner.path.progress" to a formula of time that paces it (the orrery\'s Kepler function), or give its track a curve.');
          s.behaviorChange('`$owner.path.pacing: area` no longer acts: progress is paced by length.',
              path: '$at/pacing', instead: 'Used by: orrery.');
        } else {
          s.rewrite('$at/pacing', {'pacing': ?pacing, 'focus': ?focus}, null, 'pacing/focus dropped: length pacing, as before.');
        }
      }
      if (path['orient'] == 'uprightFlip') {
        changed = true;
        path['orient'] = 'upright';
        s.unconvertible(n, '$owner.path.orient', 'uprightFlip',
            path: '$at/orient', instead: 'Bind "motion.scaleX" to -1 while the path heads left.');
        s.behaviorChange('`orient: uprightFlip` is `upright`: the node no longer mirrors while the path heads left.',
            path: '$at/orient', instead: 'Used by: lineworks_v2 (as uprightMirror).');
      }
      if (changed) {
        o['path'] = path;
        n[owner] = o;
      }
    }
  },
);

/// A transition's `arc` (bending a position change).
final transitionArcStep = MigrationStep(
  id: 'transition.arc',
  description: 'transition arc dropped',
  node: (n, s) {
    final list = readList(n['transitions']);
    if (list == null) return;
    for (var i = 0; i < list.length; i++) {
      final t = readMap(list[i]);
      if (t == null || !t.containsKey('arc')) continue;
      final arc = t.remove('arc');
      list[i] = t;
      if (_isDefault(arc, 0)) {
        s.rewrite('/transitions/$i/arc', arc, null);
        continue;
      }
      s.unconvertible(n, 'transitions.${t['property']}.arc', arc,
          path: '/transitions/$i/arc',
          instead: 'Give "motion.translateX" and "motion.translateY" transitions different curves (easeOut, easeIn), or move it along a quadratic "motion.path".');
      s.behaviorChange('A transition\'s `arc` no longer bends the move: it goes straight.',
          path: '/transitions/$i/arc', instead: 'Used by: lineup.');
    }
    n['transitions'] = list;
  },
);

/// A drop target's `fullIf` (and the `dropFull` reactions it fired),
/// `slotWhenRefused`, `hoverDelay` (and the `dragHover` reactions it timed).
final dropTargetOneAppStep = MigrationStep(
  id: 'dropTarget.oneApp',
  description: 'drop target fullIf, slotWhenRefused, hoverDelay dropped',
  node: (n, s) {
    final d = readMap(n['dropTarget']);
    final hovered = (readDouble(d?['hoverDelay']) ?? 0) > 0;
    if (d != null) {
      final acceptIf = readString(d['acceptIf'])?.trim() ?? '';
      final refusedSlot = !d.containsKey('slotWhenRefused') || readBool(d['slotWhenRefused']) != false;
      final hasSlot = (readString(d['listNodeId'])?.trim().isNotEmpty ?? false) && d['slot'] != 'none';
      if (d.containsKey('slotWhenRefused')) s.rewrite('/dropTarget/slotWhenRefused', d.remove('slotWhenRefused'), null);
      if (refusedSlot && acceptIf.isNotEmpty && hasSlot) {
        s.behaviorChange('A drag acceptIf refuses no longer opens a slot in the list (the slot opens for accepted drags only).',
            path: '/dropTarget/acceptIf', instead: 'Used by: mixtape (set it); any drop target with acceptIf and a list slot.');
      }
      n['dropTarget'] = d;
    }
    _drop(n, s, 'dropTarget', 'dropTarget', const [
      _Field('fullIf', '', 'Fold the condition into "acceptIf"; react to the refusal with dropRejected.',
          'lamplight, seedbox'),
      _Field('hoverDelay', 0, 'None (no reference app set it).', 'none'),
    ]);
    // Reactions to dropFull and dragHover: nothing fires them now (fullIf
    // and hoverDelay are gone; dragHover fired only after a hoverDelay).
    final actions = readList(n['actions']);
    if (actions == null) return;
    for (var i = actions.length - 1; i >= 0; i--) {
      final r = readMap(actions[i]);
      final t = r?['trigger'];
      final type = t is String ? t : readMap(t)?['type'];
      if (type != 'dropFull' && type != 'dragHover') continue;
      actions.removeAt(i);
      final kept = [...?readList(n['legacy.actions.$type']), r];
      s.unconvertible(n, 'actions.$type', kept,
          path: '/actions/$i',
          instead: type == 'dropFull'
              ? 'React to the refused drop (dropRejected) where acceptIf refuses it.'
              : 'React to dragEnter (with a timer reaction for a delay).');
      if (type == 'dropFull' || hovered) {
        s.behaviorChange('A `$type` reaction no longer fires.', path: '/actions/$i',
            instead: type == 'dropFull' ? 'Used by: seedbox.' : 'No reference app (sprint_kanban set hoverDelayMs, which was never read).');
      }
    }
    if (actions.isEmpty) {
      n.remove('actions');
    } else {
      n['actions'] = actions;
    }
  },
);

/// A snap's `projectVelocity` (any `physics.snap`) and a transform gesture's
/// `rotationSnap`.
final gestureOneAppStep = MigrationStep(
  id: 'gesture.oneApp',
  description: 'snap projectVelocity and transformGesture rotationSnap dropped',
  node: (n, s) {
    eachMap(n, (m, at) {
      if (!m.containsKey('projectVelocity') || !at.endsWith('/snap')) return;
      final v = m.remove('projectVelocity');
      if (readBool(v) == false) {
        s.unconvertible(n, '${at.substring(1).replaceAll('/', '.')}.projectVelocity', v,
            path: '$at/projectVelocity', instead: 'None: a snap now always picks the target nearest where the fling would stop.');
        s.behaviorChange('A snap without projectVelocity now projects the fling (as Flutter\'s sheets do).', path: at);
      } else {
        s.rewrite('$at/projectVelocity', v, null);
      }
    });
    _drop(n, s, 'transformGesture', 'transformGesture', const [
      _Field('rotationSnap', 0, 'Snap the bound "rotationVariable" with a formula (round to the step).', 'none'),
    ]);
  },
);

/// `openModal`'s `showCloseButton` and `fullHeight`: never read by the SDK.
final openModalOneAppStep = MigrationStep(
  id: 'openModal.unread',
  description: 'openModal showCloseButton and fullHeight dropped (never read)',
  node: (n, s) {
    for (final k in const ['actions', 'props', 'states', 'media']) {
      if (!n.containsKey(k)) continue;
      eachMap(n[k], (m, at) {
        if (m['type'] != 'openModal') return;
        for (final f in const ['showCloseButton', 'fullHeight']) {
          if (m.containsKey(f)) s.rewrite('/$k$at/$f', m.remove(f), null, 'openModal.$f dropped: the SDK never read it.');
        }
      }, '');
    }
  },
);
