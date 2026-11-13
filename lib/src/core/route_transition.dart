// Route transitions: how the incoming and the outgoing screen move when a
// navigate or open modal action opens a screen, and when it closes. Pure
// data; the SDK builds the route (DESIGN.md §5.2).
import 'package:meta/meta.dart';

import 'behaviors.dart' show AnimationCurve, DragDirection, Motion, Spring;
import 'json.dart';
import 'values/color.dart';

/// A ready-made [RouteTransition]; sides given next to it override its own.
enum RouteTransitionPreset {
  /// Material shared axis X: both screens slide 30 px sideways, the old one
  /// fading out over the first 30% while the new one fades in.
  sharedAxisX,

  /// Material shared axis Y: the same, vertically.
  sharedAxisY,

  /// Material shared axis Z: the new screen grows in from 80% while the old
  /// one grows to 110% and fades.
  sharedAxisZ,

  /// Material fade through: the old screen fades out, then the new one
  /// fades in while it grows from 92%.
  fadeThrough,

  /// iOS push: the new screen slides in from the right over the old one,
  /// which moves a third of the way left. Swipe from the left edge to go
  /// back.
  iosPush,

  /// iOS modal sheet: the new screen slides up over the old one, which
  /// shrinks back a little. Drag down to dismiss.
  iosModal,

  /// The new screen is revealed by a circle growing from the tapped node.
  circularReveal,

  /// The new screen zooms in from 85% while the old one zooms past and fades.
  zoom,

  /// The new screen slides up from the bottom and covers the old one.
  coverVertical,

  /// The screens turn like two faces of a cube.
  cube,

  /// The old screen turns over and the new one is its back face.
  flip,
}

/// The shape a [TransitionReveal] clips a screen to.
enum RevealShape { circle, rect }

/// Where a [TransitionReveal] grows from.
enum RevealOrigin {
  /// The last place the screen was touched or clicked.
  tap,

  /// The node whose reaction navigated: its center, or its box for a rect.
  node,

  /// The center of the screen.
  center,

  /// [TransitionReveal.x], [TransitionReveal.y] as an alignment.
  point,
}

/// When a route can be swiped back from its left edge (iOS style).
enum RouteSwipeBack {
  /// On iOS and macOS, as Flutter's Cupertino routes do.
  platform,
  always,
  never,
}

T? _enumOrNull<T extends Enum>(List<T> values, Object? v) {
  for (final e in values) {
    if (e.name == v) return e;
  }
  return null;
}

/// A clip that reveals a screen as a transition plays: a circle or
/// rectangle growing from [origin] until it covers the screen.
@immutable
final class TransitionReveal {
  const TransitionReveal({
    this.shape = RevealShape.circle,
    this.origin = RevealOrigin.tap,
    this.x = 0,
    this.y = 0,
    this.startRadius = 0,
  });

  final RevealShape shape;
  final RevealOrigin origin;

  /// [RevealOrigin.point]: the alignment, -1 to 1.
  final double x, y;

  /// The radius (half size, for a rect) it starts at.
  final double startRadius;

  static TransitionReveal? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return TransitionReveal(
      shape: readEnum(RevealShape.values, m['shape'], RevealShape.circle),
      origin: readEnum(RevealOrigin.values, m['origin'], RevealOrigin.tap),
      x: readDouble(m['x']) ?? 0,
      y: readDouble(m['y']) ?? 0,
      startRadius: readDouble(m['startRadius']) ?? 0,
    );
  }

  Json toJson() => {
        if (shape != RevealShape.circle) 'shape': shape.name,
        if (origin != RevealOrigin.tap) 'origin': origin.name,
        if (x != 0) 'x': writeDouble(x),
        if (y != 0) 'y': writeDouble(y),
        if (startRadius != 0) 'startRadius': writeDouble(startRadius),
      };

  @override
  bool operator ==(Object other) => other is TransitionReveal && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}

/// How one screen moves during a [RouteTransition]: an entering screen
/// starts at [motion] and comes to rest; a leaving one starts at rest and
/// ends at [motion]. Only the motion's values are used (the 3D ones,
/// `shiftX`/`shiftY` in screen sizes, opacity, blur); this side's [curve],
/// [delayMs] and [durationMs] time it inside the route's duration.
@immutable
final class TransitionSide {
  const TransitionSide({
    this.motion = Motion.none,
    this.reveal,
    this.curve = AnimationCurve.fastOutSlowIn,
    this.delayMs = 0,
    this.durationMs,
  });

  /// A side that doesn't move.
  static const TransitionSide still = TransitionSide();

  final Motion motion;
  final TransitionReveal? reveal;
  final AnimationCurve curve;

  /// Milliseconds into the transition this side starts.
  final int delayMs;

  /// Milliseconds it takes; null runs until the transition ends.
  final int? durationMs;

  /// Whether it moves nothing.
  bool get isStill => reveal == null && motion == Motion.none;

  /// The share of a transition of [totalMs] this side starts and ends at,
  /// 0–1, as Flutter's `Interval`.
  (double, double) interval(int totalMs) {
    if (totalMs <= 0) return (0, 1);
    final begin = (delayMs / totalMs).clamp(0.0, 1.0);
    final end = durationMs == null ? 1.0 : ((delayMs + durationMs!) / totalMs).clamp(begin, 1.0);
    return (begin, end);
  }

  static TransitionSide? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return TransitionSide(
      motion: Motion.fromJson(m['motion']) ?? Motion.none,
      reveal: TransitionReveal.fromJson(m['reveal']),
      curve: AnimationCurve.parse(m['curve']) ?? AnimationCurve.fastOutSlowIn,
      delayMs: (readInt(m['delayMs']) ?? 0).clamp(0, 60000),
      durationMs: readInt(m['durationMs'])?.clamp(0, 60000),
    );
  }

  Json toJson() => {
        if (motion != Motion.none) 'motion': motion.toJson(),
        'reveal': ?reveal?.toJson(),
        if (curve != AnimationCurve.fastOutSlowIn) 'curve': curve.name,
        if (delayMs != 0) 'delayMs': delayMs,
        'durationMs': ?durationMs,
      };

  @override
  bool operator ==(Object other) => other is TransitionSide && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}

/// A drag anywhere on a screen that closes it interactively: the drag runs
/// the transition backwards, and on release the pop completes or cancels
/// with [spring].
@immutable
final class RouteDismiss {
  const RouteDismiss({
    this.direction = DragDirection.down,
    this.distance = 0.25,
    this.velocity = 700,
    this.spring = RouteDismiss.defaultSpring,
  });

  /// The way the screen is dragged to close it.
  final DragDirection direction;

  /// The share of the screen's size along [direction] a slow drag must pass.
  final double distance;

  /// A fling faster than this (px/s) toward [direction] closes it.
  final double velocity;
  final Spring spring;
  static const Spring defaultSpring = Spring.physical(stiffness: 380, damping: 36);

  static RouteDismiss? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return RouteDismiss(
      direction: readEnum(DragDirection.values, m['direction'], DragDirection.down),
      distance: readDouble(m['distance']) ?? 0.25,
      velocity: readDouble(m['velocity']) ?? 700,
      spring: Spring.fromJson(m['spring'], fallback: defaultSpring) ?? defaultSpring,
    );
  }

  Json toJson() => {
        if (direction != DragDirection.down) 'direction': direction.name,
        if (distance != 0.25) 'distance': writeDouble(distance),
        if (velocity != 700) 'velocity': writeDouble(velocity),
        if (spring != defaultSpring) 'spring': spring.toJsonOver(defaultSpring),
      };

  @override
  bool operator ==(Object other) => other is RouteDismiss && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}

/// A composable route transition. [enter] is where the incoming screen
/// starts, [exit] where the covered one ends; closing plays them in
/// reverse unless [popEnter] (where the screen revealed by the pop starts)
/// or [popExit] (where the closing screen goes) are given. A [preset]
/// fills in what's left null. JSON: an object, or a bare preset name.
@immutable
final class RouteTransition {
  const RouteTransition({
    this.preset,
    this.enter,
    this.exit,
    this.popEnter,
    this.popExit,
    this.durationMs,
    this.reverseDurationMs,
    this.barrierColor,
    this.opaque,
    this.swipeBack,
    this.dismiss,
  });

  final RouteTransitionPreset? preset;
  final TransitionSide? enter, exit, popEnter, popExit;

  /// Null: the preset's (300 without one).
  final int? durationMs;

  /// Null: [durationMs].
  final int? reverseDurationMs;

  /// Drawn behind a modal (or a see-through page) while it's open. Null:
  /// none on pages, the dialog's own on modals.
  final Color? barrierColor;

  /// Whether the screen hides the one below once open. Null: the preset's
  /// (true without one).
  final bool? opaque;

  /// Null: the preset's ([RouteSwipeBack.platform] without one).
  final RouteSwipeBack? swipeBack;

  /// Null: the preset's (none without one).
  final RouteDismiss? dismiss;

  /// This with [preset]'s values filled in where it leaves them null: every
  /// side but the pop sides is set.
  RouteTransition get resolved {
    final base = preset == null ? null : presetTransition(preset!);
    return RouteTransition(
      preset: preset,
      enter: enter ?? base?.enter ?? TransitionSide.still,
      exit: exit ?? base?.exit ?? TransitionSide.still,
      popEnter: popEnter ?? base?.popEnter,
      popExit: popExit ?? base?.popExit,
      durationMs: durationMs ?? base?.durationMs ?? 300,
      reverseDurationMs: reverseDurationMs ?? base?.reverseDurationMs ?? durationMs,
      barrierColor: barrierColor ?? base?.barrierColor,
      opaque: opaque ?? base?.opaque ?? true,
      swipeBack: swipeBack ?? base?.swipeBack ?? RouteSwipeBack.platform,
      dismiss: dismiss ?? base?.dismiss,
    );
  }

  /// Milliseconds it takes, resolved.
  int get resolvedDurationMs =>
      (durationMs ?? (preset == null ? null : presetTransition(preset!).durationMs) ?? 300).clamp(0, 60000);

  /// Milliseconds closing takes, resolved.
  int get resolvedReverseDurationMs => (reverseDurationMs ??
          durationMs ??
          (preset == null ? null : presetTransition(preset!).reverseDurationMs) ??
          resolvedDurationMs)
      .clamp(0, 60000);

  /// The concrete transition of [preset].
  static RouteTransition presetTransition(RouteTransitionPreset preset) => switch (preset) {
        RouteTransitionPreset.sharedAxisX => const RouteTransition(
            durationMs: 300,
            enter: TransitionSide(motion: Motion(translateX: 30, opacity: 0)),
            exit: TransitionSide(motion: Motion(translateX: -30, opacity: 0), durationMs: 90),
            popEnter: TransitionSide(motion: Motion(translateX: -30, opacity: 0)),
            popExit: TransitionSide(motion: Motion(translateX: 30, opacity: 0), durationMs: 90),
          ),
        RouteTransitionPreset.sharedAxisY => const RouteTransition(
            durationMs: 300,
            enter: TransitionSide(motion: Motion(translateY: 30, opacity: 0)),
            exit: TransitionSide(motion: Motion(translateY: -30, opacity: 0), durationMs: 90),
            popEnter: TransitionSide(motion: Motion(translateY: -30, opacity: 0)),
            popExit: TransitionSide(motion: Motion(translateY: 30, opacity: 0), durationMs: 90),
          ),
        RouteTransitionPreset.sharedAxisZ => const RouteTransition(
            durationMs: 300,
            enter: TransitionSide(motion: Motion(scale: 0.8, opacity: 0)),
            exit: TransitionSide(motion: Motion(scale: 1.1, opacity: 0), durationMs: 90),
            popEnter: TransitionSide(motion: Motion(scale: 1.1, opacity: 0)),
            popExit: TransitionSide(motion: Motion(scale: 0.8, opacity: 0), durationMs: 90),
          ),
        RouteTransitionPreset.fadeThrough => const RouteTransition(
            durationMs: 300,
            enter: TransitionSide(motion: Motion(scale: 0.92, opacity: 0), delayMs: 105),
            exit: TransitionSide(motion: Motion(opacity: 0), curve: AnimationCurve.easeIn, durationMs: 105),
          ),
        RouteTransitionPreset.iosPush => const RouteTransition(
            durationMs: 400,
            enter: TransitionSide(motion: Motion(shiftX: 1), curve: AnimationCurve.easeOutCubic),
            exit: TransitionSide(motion: Motion(shiftX: -1 / 3), curve: AnimationCurve.easeOutCubic),
            swipeBack: RouteSwipeBack.always,
          ),
        RouteTransitionPreset.iosModal => const RouteTransition(
            durationMs: 400,
            opaque: false,
            barrierColor: Color(0x33000000),
            enter: TransitionSide(motion: Motion(shiftY: 1), curve: AnimationCurve.easeOutCubic),
            exit: TransitionSide(motion: Motion(scale: 0.93, translateY: 12), curve: AnimationCurve.easeOutCubic),
            dismiss: RouteDismiss(),
          ),
        RouteTransitionPreset.circularReveal => const RouteTransition(
            durationMs: 450,
            enter: TransitionSide(reveal: TransitionReveal(origin: RevealOrigin.node), curve: AnimationCurve.easeInOut),
          ),
        RouteTransitionPreset.zoom => const RouteTransition(
            durationMs: 300,
            enter: TransitionSide(motion: Motion(scale: 0.85, opacity: 0)),
            exit: TransitionSide(motion: Motion(scale: 1.05, opacity: 0)),
          ),
        RouteTransitionPreset.coverVertical => const RouteTransition(
            durationMs: 350,
            enter: TransitionSide(motion: Motion(shiftY: 1), curve: AnimationCurve.easeOutCubic),
            dismiss: RouteDismiss(),
          ),
        RouteTransitionPreset.cube => const RouteTransition(
            durationMs: 600,
            enter: TransitionSide(
                motion: Motion(shiftX: 1, rotateY: 90, originX: -1, perspective: 1.5),
                curve: AnimationCurve.easeInOutCubic),
            exit: TransitionSide(
                motion: Motion(shiftX: -1, rotateY: -90, originX: 1, perspective: 1.5),
                curve: AnimationCurve.easeInOutCubic),
          ),
        RouteTransitionPreset.flip => const RouteTransition(
            durationMs: 600,
            enter: TransitionSide(
                motion: Motion(rotateY: 90, perspective: 1.5), curve: AnimationCurve.easeOutCubic, delayMs: 300),
            exit: TransitionSide(motion: Motion(rotateY: -90, perspective: 1.5), curve: AnimationCurve.easeIn, durationMs: 300),
          ),
      };

  /// Decodes a transition: an object, or a bare preset name. Null for
  /// anything else.
  static RouteTransition? fromJson(Object? json) {
    if (json is String) {
      final p = _enumOrNull(RouteTransitionPreset.values, json);
      return p == null ? null : RouteTransition(preset: p);
    }
    final m = readMap(json);
    if (m == null) return null;
    return RouteTransition(
      preset: _enumOrNull(RouteTransitionPreset.values, m['preset']),
      enter: TransitionSide.fromJson(m['enter']),
      exit: TransitionSide.fromJson(m['exit']),
      popEnter: TransitionSide.fromJson(m['popEnter']),
      popExit: TransitionSide.fromJson(m['popExit']),
      durationMs: readInt(m['durationMs'])?.clamp(0, 60000),
      reverseDurationMs: readInt(m['reverseDurationMs'])?.clamp(0, 60000),
      barrierColor: Color.fromJson(m['barrierColor']),
      opaque: readBool(m['opaque']),
      swipeBack: _enumOrNull(RouteSwipeBack.values, m['swipeBack']),
      dismiss: RouteDismiss.fromJson(m['dismiss']),
    );
  }

  Json toJson() => {
        'preset': ?preset?.name,
        'enter': ?enter?.toJson(),
        'exit': ?exit?.toJson(),
        'popEnter': ?popEnter?.toJson(),
        'popExit': ?popExit?.toJson(),
        'durationMs': ?durationMs,
        'reverseDurationMs': ?reverseDurationMs,
        'barrierColor': ?barrierColor?.toJson(),
        'opaque': ?opaque,
        'swipeBack': ?swipeBack?.name,
        'dismiss': ?dismiss?.toJson(),
      };

  @override
  bool operator ==(Object other) => other is RouteTransition && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}
