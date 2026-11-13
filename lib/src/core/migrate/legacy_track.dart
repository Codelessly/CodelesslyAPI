// The schema-2 readers of a node's drag, track, draggable, gesture physics,
// motion pose and transitions keys, moved out of the model. Each builds the
// schema-3 value exactly as the schema-2 decoder did; the steps write its
// JSON.
import 'dart:math' as math;

import '../behavior_fields.dart';
import '../behaviors.dart';
import '../json.dart';
import '../path_follow.dart';
import '../values/geometry.dart';
import 'legacy_animations.dart' show legacySpring;
import 'legacy_read.dart';

List<double> _doubles(Json m, String k) => [...?readList(m[k])?.map(readDouble).nonNulls];

/// [out] with [extra]'s entries that aren't null added: the deprecated
/// fields the schema-2 shape still had, for the steps that drop them.
Json _with(Json out, Map<String, Object?> extra) => {
      ...out,
      for (final e in extra.entries)
        if (e.value != null) e.key: e.value,
    };

/// [out] (encoded from a value whose `physics` was read from [raw]) with
/// the raw snap's `projectVelocity` kept, for the step that drops it.
Json _keepSnap(Json out, Json? raw) {
  final v = readMap(readMap(raw?['physics'])?['snap'])?['projectVelocity'];
  final physics = readMap(out['physics']);
  final snap = readMap(physics?['snap']);
  if (v == null || physics == null || snap == null) return out;
  return {...out, 'physics': {...physics, 'snap': {...snap, 'projectVelocity': v}}};
}

/// The deprecated follow fields of a legacy `drag` [r] that differ from
/// their defaults.
Map<String, Object?> _followExtra(LegacyReader r) => {
      if (r.d('rotateFactor', 0) != 0) 'rotateFactor': writeDouble(r.d('rotateFactor', 0)),
      if (r.d('originX', 0) != 0) 'originX': writeDouble(r.d('originX', 0)),
      if (r.d('originY', 0) != 0) 'originY': writeDouble(r.d('originY', 0)),
      if (r.b('shakeWhenDisabled', false)) 'shakeWhenDisabled': true,
      if (r.d('disabledFollow', 0) != 0) 'disabledFollow': writeDouble(r.d('disabledFollow', 0)),
      if (r.s('shareAs').isNotEmpty) 'shareAs': r.s('shareAs'),
      if (!r.b('follow', true)) 'follow': false,
    };

/// The legacy `drag` object's split.
abstract final class LegacyDrag {
  /// The track of a legacy `drag` object [d] (its `track`, switched by its
  /// `enabled`), as track JSON still to be read by [LegacyTrack]; null when
  /// it has none.
  static Json? trackJson(Json? d) {
    if (d == null || readMap(d['track']) == null) return null;
    final t = <String, Object?>{...readMap(d['track'])!};
    if (!t.containsKey('enabled') && d.containsKey('enabled')) t['enabled'] = d['enabled'];
    return t;
  }

  /// Whether a legacy `drag` object [d] made its node a reorder handle
  /// (`reorder: true` without a track).
  static bool isReorderHandle(Json? d) => d != null && readMap(d['track']) == null && (readBool(d['reorder']) ?? false);

  /// The dismissible a legacy `drag` object [d] amounts to (`release:
  /// dismiss`, no track, not a reorder handle), its old defaults written
  /// out, as JSON; null for any other drag.
  static Json? dismissibleJson(Json? d) {
    if (d == null || readMap(d['track']) != null || readBool(d['reorder']) == true) return null;
    final r = LegacyReader(d);
    if (r.s('release', 'snapBack') != 'dismiss') return null;
    final distance = r.d('distanceThreshold', 0.35), vertical = r.dn('verticalThreshold') ?? distance;
    final physics = GesturePhysics.fromJson(LegacyPhysics.migrate(readMap(d['physics'])));
    final j = DismissibleBehavior(
      enabled: loose(d['enabled']) ?? true,
      directions: directionsOf(d['directions']) ?? DragDirection.values,
      axis: r.e(DragAxis.values, 'axis', DragAxis.free),
      dismissThresholds: {
        for (final dir in DragDirection.values)
          if ((dir == DragDirection.up || dir == DragDirection.down ? vertical : distance) case final t
              when t != DismissibleBehavior.defaultThreshold)
            dir: t,
      },
      flingVelocity: r.d('velocityThreshold', 800),
      resistance: r.d('resistance', 0),
      movementDuration: r.ms('flyOut', 320),
      curve: r.curve('flyOutCurve', AnimationCurve.easeIn),
      returnDuration: r.ms('snapBack', 450),
      returnCurve: r.curve('snapCurve', AnimationCurve.spring),
      returnSpring: physics?.spring,
    ).toJson();
    return _with(j, {
      if (r.d('restX', 0) != 0) 'restX': writeDouble(r.d('restX', 0)),
      if (r.d('restY', 0) != 0) 'restY': writeDouble(r.d('restY', 0)),
      if (r.s('xVariable').isNotEmpty) 'xVariable': r.s('xVariable'),
      if (r.s('yVariable').isNotEmpty) 'yVariable': r.s('yVariable'),
      if (r.d('flyOutRotate', 0) != 0) 'flyOutRotate': writeDouble(r.d('flyOutRotate', 0)),
      ..._followExtra(r),
    });
  }

  /// The [DragDirection]s of a list of names, or of a Flutter
  /// `DismissDirection` name; null when [v] is neither.
  static List<DragDirection>? directionsOf(Object? v) {
    if (v is String) {
      return switch (v) {
        'horizontal' => const [DragDirection.left, DragDirection.right],
        'vertical' => const [DragDirection.up, DragDirection.down],
        'endToStart' || 'left' => const [DragDirection.left],
        'startToEnd' || 'right' => const [DragDirection.right],
        'up' => const [DragDirection.up],
        'down' => const [DragDirection.down],
        'none' => const [],
        _ => null,
      };
    }
    final l = readList(jsonText(v));
    if (l == null) return null;
    return [
      for (final d in DragDirection.values)
        if (l.contains(d.name)) d,
    ];
  }

  /// The pan a legacy `drag` object [d] amounts to (not a track, a reorder
  /// handle or dismissing), as JSON; null for any other drag.
  static Json? panJson(Json? d) {
    if (d == null || readMap(d['track']) != null || readBool(d['reorder']) == true) return null;
    final r = LegacyReader(d);
    final release = r.s('release', 'snapBack');
    if (release == 'dismiss') return null;
    final m = <String, Object?>{
      ...d,
      'release': const ['snapBack', 'stay'].contains(release) ? release : 'snapBack',
      'returnDuration': ?d['snapBack'],
      'returnCurve': ?d['snapCurve'],
      'x': ?d['restX'],
      'y': ?d['restY'],
    };
    final mr = LegacyReader(m);
    final pan = Pan(
      enabled: loose(m['enabled']) ?? true,
      axis: mr.e(DragAxis.values, 'axis', DragAxis.free),
      release: mr.e(PanRelease.values, 'release', PanRelease.snapBack),
      returnDuration: mr.ms('returnDuration', 450),
      returnCurve: mr.curve('returnCurve', AnimationCurve.spring),
      x: mr.d('x', 0),
      y: mr.d('y', 0),
      xVariable: mr.s('xVariable'),
      yVariable: mr.s('yVariable'),
      physics: GesturePhysics.fromJson(LegacyPhysics.migrate(readMap(m['physics']))),
      bounds: mr.e(GestureBounds.values, 'bounds', GestureBounds.none),
      minX: mr.dn('minX'),
      maxX: mr.dn('maxX'),
      minY: mr.dn('minY'),
      maxY: mr.dn('maxY'),
    ).toJson();
    return _keepSnap(_with(pan, _followExtra(mr)), m);
  }
}

/// The schema-2 reader of a `track` object.
abstract final class LegacyTrack {
  /// The keys a schema-3 track has.
  static final Set<String> keys = {for (final f in TrackFields.all) f.key};

  /// Whether the track JSON [m] holds the legacy `write: false` with a
  /// variable: the variable is dropped and, without a literal `value`, moves
  /// to a `track.value` binding ([readsOnly]).
  static bool dropsVariable(Json m) =>
      readBool(m['write']) == false && (readString(m['variable'])?.trim().isNotEmpty ?? false);

  /// [dropsVariable] with no literal `value`: the variable is then bound.
  static bool readsOnly(Json m) => dropsVariable(m) && m['value'] == null;

  /// The track JSON [m] as the schema-2 decoder read it (every legacy key:
  /// `endAngle`, `endless`, `jumpOnTap`, `wheel`/`keyboard: false`,
  /// `momentum`/`friction`, `gain`, the path string with
  /// `viewBoxWidth`/`viewBoxHeight` and `orientToPath`/`orientUpright`,
  /// `write: false`, `settleStiffness`/`settleDamping`).
  static Json read(Json m) {
    final r = LegacyReader(m);
    final path = _pathOf(m);
    final shape = readEnum(TrackShape.values, m['shape'], path != null ? TrackShape.path : TrackShape.line);
    final input = r.e(TrackInput.values, 'input', TrackInput.follow);
    final start = r.d('startAngle', -135);
    final gain = r.d('gain', 1);
    // A gain other than round an arc followed by angle is a pixel rate.
    final angular = shape == TrackShape.arc && input == TrackInput.follow;
    final ppr = r.d('pixelsPerRange', 200);
    final track = Track(
      enabled: loose(m['enabled']) ?? true,
      variable: dropsVariable(m) ? '' : r.s('variable'),
      value: r.dn('value'),
      min: r.d('min', 0),
      max: r.d('max', 1),
      step: math.max(0, r.d('step', 0)),
      clamp: readBool(m['clamp']) ?? !(r.b('endless', false) && shape == TrackShape.arc),
      input: input,
      allowedInteraction: readEnum(
        TrackInteraction.values,
        m['allowedInteraction'],
        r.b('jumpOnTap', false) ? TrackInteraction.tapAndSlide : TrackInteraction.slideThumb,
      ),
      hitArea: r.e(TrackHitArea.values, 'hitArea', TrackHitArea.self),
      pixelsPerRange: angular || gain <= 0 ? ppr : ppr / gain,
      wheelStep: r.b('wheel', true) ? r.dn('wheelStep') : 0,
      keyStep: r.b('keyboard', true) ? r.dn('keyStep') : 0,
      shape: shape,
      x1: r.d('x1', 0),
      y1: r.d('y1', 0),
      x2: r.d('x2', 0),
      y2: r.d('y2', -100),
      relative: r.b('relative', false),
      units: r.e(TrackUnits.values, 'units', TrackUnits.pixels),
      startAngle: start,
      sweepAngle: r.dn('sweepAngle') ?? (r.d('endAngle', 135) - start),
      pivotX: r.d('pivotX', 0),
      pivotY: r.d('pivotY', 0),
      rotate: r.b('rotate', true),
      path: path,
      detent: r.d('detent', 0),
      overscroll: r.d('overscroll', 0),
      physics: GesturePhysics.fromJson(LegacyPhysics.migrate(readMap(m['physics']))) ??
          ((loose(m['momentum']) ?? false) ? _momentum(r.d('friction', 2.6)) : null),
      settle: r.ms('settle', 0),
      settleCurve: r.curve('settleCurve', AnimationCurve.easeOutCubic),
      settleSpring: Spring.fromJson(m['settleSpring'], fallback: Track.defaultSettleSpring) ??
          legacySpring(m, 'settleStiffness', 'settleDamping', fallback: Track.defaultSettleSpring) ??
          Track.defaultSettleSpring,
      snap: r.ms('snap', 0),
      snapCurve: r.curve('snapCurve', AnimationCurve.easeOutBack),
    ).toJson();
    final fine = angular || gain <= 0 ? r.d('finePixelsPerRange', 0) : r.d('finePixelsPerRange', 0) / gain;
    final rawPath = readMap(m['path']);
    final out = _with(track, {
      'defaultValue': ?r.dn('defaultValue')?.let(writeDouble),
      if (r.doubles('doubleTapValues').isNotEmpty) 'doubleTapValues': r.doubles('doubleTapValues').map(writeDouble).toList(),
      'parkedProgress': ?r.dn('parkedProgress')?.let(writeDouble),
      if (r.d('fineStep', 0) != 0) 'fineStep': writeDouble(r.d('fineStep', 0)),
      if (fine != 0) 'finePixelsPerRange': writeDouble(fine),
      if (r.ms('fineHold', 380) != 380) 'fineHold': r.ms('fineHold', 380),
      if (r.s('fineVariable').isNotEmpty) 'fineVariable': r.s('fineVariable'),
      if (loose(m['smooth']) ?? false) 'smooth': true,
      if (angular && gain != 1) 'gain': writeDouble(gain),
    });
    // A path object's deprecated keys, for the step that drops them.
    final outPath = readMap(out['path']);
    if (rawPath != null && outPath != null) {
      out['path'] = <String, Object?>{
        ...outPath,
        for (final k in const ['pacing', 'focus']) k: ?rawPath[k],
        if (rawPath['orient'] == 'uprightFlip') 'orient': 'uprightFlip',
      };
    }
    return _keepSnap(out, m);
  }

  /// The legacy `momentum` coast slowing at [rate] per second
  /// (`v *= e^(−rate·dt)`): a fling losing `1 − e^(−rate)` of its speed a
  /// second (to 4 places).
  static GesturePhysics _momentum(double rate) =>
      GesturePhysics(friction: double.parse((1 - math.exp(-math.max(0, rate))).toStringAsFixed(4)));

  /// [m]'s path: `path` as an object or SVG data, with the legacy
  /// `viewBoxWidth`/`viewBoxHeight`, `orientToPath` and `orientUpright`.
  static PathFollow? _pathOf(Json m) {
    final p = PathFollow.fromJson(m['path']);
    if (p == null || m['path'] is! String) return p;
    final r = LegacyReader(m);
    final w = r.d('viewBoxWidth', 0), h = r.d('viewBoxHeight', 0);
    return PathFollow(
      path: p.path,
      viewBox: w > 0 && h > 0 ? [w, h] : const [],
      orient: !r.b('orientToPath', false)
          ? PathOrient.none
          : (r.b('orientUpright', false) ? PathOrient.upright : PathOrient.tangent),
    );
  }
}

/// The schema-2 reader of a `draggable` object.
abstract final class LegacyDragSource {
  static const _legacy = {'whileDragging', 'feedbackNodeId', 'feedbackAnchor', 'dragAnchorStrategy', 'spring', 'springStiffness', 'springDamping', 'physics'};

  /// Whether [m] has a key or value only schema 2 reads.
  static bool isLegacy(Json m) =>
      _legacy.any(m.containsKey) || m['returnSpring'] == true || m['dragAnchor'] == 'pointer';

  static Spring? _returnSpringOf(Json m) {
    final v = m['returnSpring'];
    if (Spring.fromJson(v, fallback: DragSource.defaultSpring) case final Spring s) return s;
    // The legacy `physics` overrode `returnSpring: false`.
    if (GesturePhysics.fromJson(LegacyPhysics.migrate(readMap(m['physics']))) case final GesturePhysics p) return p.spring;
    if (readBool(v) == false) return null;
    return Spring.fromJson(m['spring'], fallback: DragSource.defaultSpring) ??
        legacySpring(m, 'springStiffness', 'springDamping', fallback: DragSource.defaultSpring) ??
        DragSource.defaultSpring;
  }

  static DragSource read(Json m) {
    final r = LegacyReader(m);
    return DragSource(
      group: r.s('group'),
      data: r.s('data'),
      start: r.e(DragStart.values, 'start', DragStart.auto),
      axis: r.e(DragAxis.values, 'axis', DragAxis.free),
      childWhenDragging: readEnum(DragSourceStyle.values, m['childWhenDragging'] ?? m['whileDragging'], DragSourceStyle.ghost),
      ghostOpacity: r.d('ghostOpacity', 0.35),
      feedback: readString(m['feedback']) ?? r.s('feedbackNodeId'),
      dragAnchor: switch (m['dragAnchor'] ?? m['dragAnchorStrategy'] ?? m['feedbackAnchor']) {
        'center' || 'pointer' => DragAnchor.center,
        _ => DragAnchor.child,
      },
      feedbackRotation: r.d('feedbackRotation', -2),
      feedbackScale: r.d('feedbackScale', 1),
      feedbackOpacity: r.d('feedbackOpacity', 1),
      feedbackElevation: r.d('feedbackElevation', 24),
      returnSpring: _returnSpringOf(m),
      enabled: loose(m['enabled']) ?? true,
    );
  }
}

/// The schema-2 reader of a `physics` object's flat spring keys.
abstract final class LegacyPhysics {
  static const _flat = ['stiffness', 'damping', 'mass', 'bounce', 'duration'];

  /// Whether [m] gives its spring as flat keys.
  static bool isLegacy(Json? m) => m != null && m['spring'] == null && _flat.any(m.containsKey);

  /// [m] with its flat spring keys as `spring` (`bounce`/`duration` over
  /// `stiffness`/`damping`, the preset's for what it leaves out); [m] as
  /// given when it has none.
  static Json? migrate(Json? m) {
    if (!isLegacy(m)) return m;
    final preset = GesturePhysics.presets[m!['preset']] ?? GesturePhysics.standard;
    final base = preset.spring;
    final r = LegacyReader(m);
    final mass = r.d('mass', base.mass);
    final Spring spring;
    if (readDouble(m['bounce']) != null || readInt(m['duration']) != null || !base.isPhysical) {
      spring = Spring(
        duration: math.max(1, readInt(m['duration']) ?? (base.isPhysical ? 500 : base.duration)),
        bounce: readDouble(m['bounce']) ?? (base.isPhysical ? 0 : base.bounce),
        mass: mass,
      );
    } else {
      spring = Spring(
        stiffness: r.d('stiffness', base.isPhysical ? base.stiffness! : 380),
        damping: r.d('damping', base.isPhysical ? base.damping! : 32),
        mass: mass,
      );
    }
    return {
      for (final e in m.entries)
        if (!_flat.contains(e.key)) e.key: e.value,
      'spring': spring.toJson(),
    };
  }
}

/// The schema-2 reader of a `motion` object's pose: `originX`/`originY` as
/// `alignment`, the flat path keys as `path`.
abstract final class LegacyMotion {
  /// The keys a schema-3 motion has.
  static const keys = {
    'translateX', 'translateY', 'shiftX', 'shiftY', 'scale', 'scaleX', 'scaleY', 'rotate', 'rotateX', 'rotateY', //
    'perspective', 'alignment', 'backfaceHidden', 'path',
  };

  /// The motion as schema 3 JSON, with its path's deprecated keys
  /// (`pacing`, `focus`, `orient: uprightFlip`, from the path object or the
  /// flat `pathPacing`, `pathFocusX/Y`, `uprightMirror`) kept for the step
  /// that drops them.
  static Json json(Json m) {
    final out = read(m).toJson();
    final path = readMap(out['path']);
    if (path == null) return out;
    final raw = readMap(m['path']) ?? const <String, Object?>{};
    final focus = [..._doubles(raw, 'focus'), 0.0, 0.0];
    final fx = readDouble(m['pathFocusX']) ?? focus[0], fy = readDouble(m['pathFocusY']) ?? focus[1];
    final pacing = m['pathPacing'] ?? raw['pacing'];
    final tangent = readBool(m['orientToPath']) ?? raw['orient'] != null && raw['orient'] != 'none';
    final upright = readBool(m['orientUpright']) ?? (raw['orient'] == 'upright' || raw['orient'] == 'uprightFlip');
    final flip = readBool(m['uprightMirror']) ?? raw['orient'] == 'uprightFlip';
    out['path'] = {
      ...path,
      if (pacing is String && pacing != 'length') 'pacing': pacing,
      if (fx != 0 || fy != 0) 'focus': [writeDouble(fx), writeDouble(fy)],
      if (tangent && upright && flip) 'orient': 'uprightFlip',
    };
    return out;
  }

  static Motion read(Json m) {
    final r = LegacyReader(m);
    final legacyOrigin = m.containsKey('originX') || m.containsKey('originY');
    final alignment = Alignment.fromJson(m['alignment']) ?? Alignment.center;
    return Motion(
      translateX: r.d('translateX', 0),
      translateY: r.d('translateY', 0),
      shiftX: r.d('shiftX', 0),
      shiftY: r.d('shiftY', 0),
      scale: r.d('scale', 1),
      scaleX: r.d('scaleX', 1),
      scaleY: r.d('scaleY', 1),
      rotate: r.d('rotate', 0),
      rotateX: r.d('rotateX', 0),
      rotateY: r.d('rotateY', 0),
      perspective: r.d('perspective', 1),
      alignment: legacyOrigin ? Alignment(r.d('originX', alignment.x), r.d('originY', alignment.y)) : alignment,
      backfaceHidden: r.b('backfaceHidden', false),
      path: _path(m),
    );
  }

  /// The flat path keys of motion JSON [m] over its `path`.
  static PathFollow? _path(Json m) {
    final base = PathFollow.fromJson(m['path']);
    const keys = [
      'pathProgress', 'orientToPath', 'orientUpright', 'uprightMirror', 'pathViewBox', 'pathPacing', 'pathFocusX', //
      'pathFocusY',
    ];
    if (!keys.any(m.containsKey)) return base;
    double d(String k, double fallback) => readDouble(m[k]) ?? fallback;
    bool b(String k, bool fallback) => readBool(m[k]) ?? fallback;
    final box = _doubles(m, 'pathViewBox');
    final orient = base?.orient ?? PathOrient.none;
    final tangent = b('orientToPath', orient != PathOrient.none);
    final upright = b('orientUpright', orient == PathOrient.upright || readMap(m['path'])?['orient'] == 'uprightFlip');
    return PathFollow(
      path: base?.path ?? '',
      viewBox: box.isNotEmpty ? box : base?.viewBox ?? const [],
      progress: d('pathProgress', base?.progress ?? 0),
      orient: !tangent
          ? PathOrient.none
          : !upright
              ? PathOrient.tangent
              : PathOrient.upright,
    );
  }
}

/// The schema-2 reader of a node's `transitions`: the legacy `{style,
/// opacity, size}` object and a property → timing map, as a list.
abstract final class LegacyTransitions {
  static List<Transition>? read(Object? json) {
    if (readList(jsonText(json)) != null) return null;
    final m = readMap(json);
    if (m == null) return null;
    if (m.keys.every((k) => k == 'style' || k == 'opacity' || k == 'size')) {
      final style = m['style'], opacity = m['opacity'], size = m['size'];
      return [
        if (Transition.fromJson(opacity ?? style, property: 'opacity') case final Transition t) t,
        if (Transition.fromJson(style, property: 'scale') case final Transition t) t,
        if (Transition.fromJson(style, property: 'decoration.fills') case final Transition t) t,
        if (Transition.fromJson(style, property: 'visible') case final Transition t) t,
        if (Transition.fromJson(size, property: 'layout') case final Transition t) t,
      ];
    }
    return [
      for (final e in m.entries)
        if (Transition.fromJson(e.value, property: e.key) case final Transition t) t,
    ];
  }
}
