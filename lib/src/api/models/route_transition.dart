import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'route_transition.g.dart';

/// A ready-made [RouteTransition]. [RouteTransition.resolved] turns it into
/// concrete [TransitionSide]s; sides given next to a preset override the
/// preset's.
enum RouteTransitionPreset {
  /// Material shared axis X: both screens slide 30 px sideways, the old one
  /// fading out over the first 30% while the new one fades in.
  sharedAxisX,

  /// Material shared axis Y: like [sharedAxisX], vertically.
  sharedAxisY,

  /// Material shared axis Z: the new screen grows in from 80% while the old
  /// one grows to 110% and fades.
  sharedAxisZ,

  /// Material fade through: the old screen fades out, then the new one
  /// fades in while it grows from 92%.
  fadeThrough,

  /// iOS push: the new screen slides in from the right edge over the old
  /// one, which moves a third of the way left. Swipe from the left edge to
  /// go back.
  iosPush,

  /// iOS modal sheet: the new screen slides up over the old one, which
  /// shrinks back a little like a card stack. Drag down to dismiss.
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
  flip;

  /// Displayable name.
  String get prettify => switch (this) {
    RouteTransitionPreset.sharedAxisX => 'Shared axis X',
    RouteTransitionPreset.sharedAxisY => 'Shared axis Y',
    RouteTransitionPreset.sharedAxisZ => 'Shared axis Z',
    RouteTransitionPreset.fadeThrough => 'Fade through',
    RouteTransitionPreset.iosPush => 'iOS push',
    RouteTransitionPreset.iosModal => 'iOS modal',
    RouteTransitionPreset.circularReveal => 'Circular reveal',
    RouteTransitionPreset.zoom => 'Zoom',
    RouteTransitionPreset.coverVertical => 'Cover vertical',
    RouteTransitionPreset.cube => 'Cube',
    RouteTransitionPreset.flip => 'Flip',
  };
}

/// The shape a [TransitionReveal] clips a screen to.
enum RevealShape {
  /// A circle growing until it covers the screen.
  circle,

  /// A rectangle growing from a point (or from the tapped node's box).
  rect;

  /// Displayable name.
  String get prettify => switch (this) {
    RevealShape.circle => 'Circle',
    RevealShape.rect => 'Rectangle',
  };
}

/// Where a [TransitionReveal] grows from.
enum RevealOrigin {
  /// The last place the screen was touched or clicked.
  tap,

  /// The node whose reaction navigated (the tapped node): its centre, or
  /// its box for [RevealShape.rect].
  node,

  /// The centre of the screen.
  center,

  /// [TransitionReveal.x], [TransitionReveal.y] as an alignment.
  point;

  /// Displayable name.
  String get prettify => switch (this) {
    RevealOrigin.tap => 'Tap point',
    RevealOrigin.node => 'Tapped node',
    RevealOrigin.center => 'Center',
    RevealOrigin.point => 'Point',
  };
}

/// When a route can be swiped back from its left edge (iOS style).
enum RouteSwipeBack {
  /// On iOS and macOS, as Flutter's Cupertino routes do.
  platform,

  /// On every platform.
  always,

  /// Never.
  never;

  /// Displayable name.
  String get prettify => switch (this) {
    RouteSwipeBack.platform => 'On iOS and macOS',
    RouteSwipeBack.always => 'Always',
    RouteSwipeBack.never => 'Never',
  };
}

/// A clip that reveals a screen as a transition plays: the screen is only
/// painted inside a circle or rectangle that grows from [origin] until it
/// covers the screen.
@JsonSerializable()
class TransitionReveal with Equatable, SerializableMixin {
  /// The shape of the clip.
  final RevealShape shape;

  /// Where the clip grows from.
  final RevealOrigin origin;

  /// For [RevealOrigin.point]: horizontal alignment, -1 left to 1 right.
  final double x;

  /// For [RevealOrigin.point]: vertical alignment, -1 top to 1 bottom.
  final double y;

  /// Radius (or half size, for a rect) the clip starts at, in logical
  /// pixels.
  final double startRadius;

  /// Creates a [TransitionReveal].
  const TransitionReveal({
    this.shape = RevealShape.circle,
    this.origin = RevealOrigin.tap,
    this.x = 0,
    this.y = 0,
    this.startRadius = 0,
  });

  /// Creates a [TransitionReveal] from JSON.
  factory TransitionReveal.fromJson(Map json) =>
      _$TransitionRevealFromJson(json);

  @override
  Map toJson() =>
      _$TransitionRevealOmitDefaults(this, _$TransitionRevealToJson(this));

  @override
  List<Object?> get props => [shape, origin, x, y, startRadius];
}

/// How one screen moves during a [RouteTransition].
///
/// For an entering side the screen starts at [motion] and comes to rest
/// (no transform); for a leaving side it starts at rest and ends at
/// [motion]. Only the values of [motion] are used, and they include the
/// 3D ones ([MotionModel.rotateX], [MotionModel.rotateY],
/// [MotionModel.perspective], [MotionModel.originX], [MotionModel.originY]),
/// [MotionModel.shiftX]/[MotionModel.shiftY] in screen sizes,
/// [MotionModel.opacity] and [MotionModel.blur]. Its timing settings
/// ([MotionModel.durationMs], curve, loops) are ignored: this side's
/// [curve], [delayMs] and [durationMs] time it inside the route's duration.
@JsonSerializable()
class TransitionSide with Equatable, SerializableMixin {
  /// The values the screen moves from (entering) or to (leaving).
  final MotionModel motion;

  /// A clip that reveals the screen as it enters (or hides it as it
  /// leaves). Null for none.
  final TransitionReveal? reveal;

  /// The easing of this side.
  final MotionCurve curve;

  /// Milliseconds into the route's transition this side starts.
  final int delayMs;

  /// Milliseconds this side takes. Null runs until the transition ends.
  final int? durationMs;

  /// Creates a [TransitionSide].
  const TransitionSide({
    this.motion = MotionModel.none,
    this.reveal,
    this.curve = MotionCurve.fastOutSlowIn,
    this.delayMs = 0,
    this.durationMs,
  });

  /// A side that doesn't move.
  static const TransitionSide still = TransitionSide();

  /// Whether this side moves nothing.
  bool get isStill => reveal == null && motion == MotionModel.none;

  /// The share of a transition of [totalMs] this side starts at and ends
  /// at, each from 0 to 1, as for a Flutter `Interval`.
  (double, double) interval(int totalMs) {
    if (totalMs <= 0) return (0, 1);
    final double begin = (delayMs / totalMs).clamp(0.0, 1.0);
    final double end = durationMs == null
        ? 1
        : ((delayMs + durationMs!) / totalMs).clamp(begin, 1.0);
    return (begin, end);
  }

  /// Duplicates this with the given overrides.
  TransitionSide copyWith({
    MotionModel? motion,
    TransitionReveal? reveal,
    MotionCurve? curve,
    int? delayMs,
    int? durationMs,
  }) => TransitionSide(
    motion: motion ?? this.motion,
    reveal: reveal ?? this.reveal,
    curve: curve ?? this.curve,
    delayMs: delayMs ?? this.delayMs,
    durationMs: durationMs ?? this.durationMs,
  );

  /// Creates a [TransitionSide] from JSON.
  factory TransitionSide.fromJson(Map json) => _$TransitionSideFromJson(json);

  @override
  Map toJson() =>
      _$TransitionSideOmitDefaults(this, _$TransitionSideToJson(this));

  @override
  List<Object?> get props => [motion, reveal, curve, delayMs, durationMs];
}

/// PROVISIONAL INTERFACE: the spring a released interactive transition
/// settles with.
///
/// The Phase 3 Gestures project defines one shared physics model for drag,
/// transform gestures and draggables (`docs/gestures_api.md`). It wasn't
/// merged when transitions were built, so this stands in for it with the
/// same three numbers as Flutter's `SpringDescription`. When the shared
/// model lands, [TransitionSpring.fromJson] will read its JSON too and the
/// fields typed with this will move to it (see
/// `references/transition_lab/blockers.md`).
@JsonSerializable()
class TransitionSpring with Equatable, SerializableMixin {
  /// Stiffness: higher settles faster.
  final double stiffness;

  /// Damping: about 2 × √(stiffness × mass) stops without overshoot.
  final double damping;

  /// Mass.
  final double mass;

  /// Creates a [TransitionSpring].
  const TransitionSpring({
    this.stiffness = 380,
    this.damping = 36,
    this.mass = 1,
  });

  /// Creates a [TransitionSpring] from JSON.
  factory TransitionSpring.fromJson(Map json) =>
      _$TransitionSpringFromJson(json);

  @override
  Map toJson() =>
      _$TransitionSpringOmitDefaults(this, _$TransitionSpringToJson(this));

  @override
  List<Object?> get props => [stiffness, damping, mass];
}

/// A drag anywhere on a screen that closes it interactively: the drag
/// drives the route's transition backwards (shared elements follow), and on
/// release the pop completes or cancels with [spring].
@JsonSerializable()
class RouteDismiss with Equatable, SerializableMixin {
  /// The way the screen is dragged to close it.
  final DragDirection direction;

  /// The share of the screen's size along [direction] the drag must pass
  /// to close it when let go slowly.
  final double distance;

  /// A fling faster than this, in logical pixels per second, toward
  /// [direction] closes it however short it was.
  final double velocity;

  /// The spring the transition settles with after release.
  final TransitionSpring spring;

  /// Creates a [RouteDismiss].
  const RouteDismiss({
    this.direction = DragDirection.down,
    this.distance = 0.25,
    this.velocity = 700,
    this.spring = const TransitionSpring(),
  });

  /// Creates a [RouteDismiss] from JSON.
  factory RouteDismiss.fromJson(Map json) => _$RouteDismissFromJson(json);

  @override
  Map toJson() =>
      _$RouteDismissOmitDefaults(this, _$RouteDismissToJson(this));

  @override
  List<Object?> get props => [direction, distance, velocity, spring];
}

/// A composable route transition: how the incoming and the outgoing screen
/// move when a screen (or a modal) opens, and when it closes.
///
/// [enter] is where the incoming screen starts, [exit] where the outgoing
/// (covered) screen ends. Closing plays them in reverse unless [popEnter]
/// (where the screen revealed by the pop starts) or [popExit] (where the
/// closing screen goes) are given. A [preset] fills in any side left out.
@JsonSerializable()
class RouteTransition with Equatable, SerializableMixin {
  /// A ready-made transition whose sides fill in the ones left null.
  final RouteTransitionPreset? preset;

  /// Where the incoming screen starts.
  final TransitionSide? enter;

  /// Where the outgoing screen ends while it is covered.
  final TransitionSide? exit;

  /// Where the screen revealed by closing this one starts. Null reverses
  /// [exit].
  final TransitionSide? popEnter;

  /// Where this screen goes when it closes. Null reverses [enter].
  final TransitionSide? popExit;

  /// Milliseconds the transition takes. Null for the preset's (300 without
  /// a preset).
  final int? durationMs;

  /// Milliseconds closing takes. Null for [durationMs].
  final int? reverseDurationMs;

  /// The colour drawn behind a modal (or a see-through page) while it is
  /// open. Null for none on pages, and the dialog's own on modals.
  final ColorRGBA? barrierColor;

  /// Whether the screen hides the one below once it is open. Null for the
  /// preset's (true without one). A see-through route keeps the screen below
  /// painted, as an iOS modal sheet does.
  final bool? opaque;

  /// When the screen can be swiped back from its left edge. Null for the
  /// preset's ([RouteSwipeBack.platform] without one).
  final RouteSwipeBack? swipeBack;

  /// A drag that closes the screen interactively. Null for the preset's
  /// (none without one).
  final RouteDismiss? dismiss;

  /// Creates a [RouteTransition].
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

  /// [preset] on its own.
  const RouteTransition.preset(RouteTransitionPreset this.preset)
    : enter = null,
      exit = null,
      popEnter = null,
      popExit = null,
      durationMs = null,
      reverseDurationMs = null,
      barrierColor = null,
      opaque = null,
      swipeBack = null,
      dismiss = null;

  /// The transition with [preset]'s values filled in where this leaves
  /// them null, so every side but the pop sides is set. The preset itself
  /// is kept.
  RouteTransition get resolved {
    final RouteTransition? base = preset == null
        ? null
        : presetTransition(preset!);
    return RouteTransition(
      preset: preset,
      enter: enter ?? base?.enter ?? TransitionSide.still,
      exit: exit ?? base?.exit ?? TransitionSide.still,
      popEnter: popEnter ?? base?.popEnter,
      popExit: popExit ?? base?.popExit,
      durationMs: durationMs ?? base?.durationMs ?? 300,
      reverseDurationMs:
          reverseDurationMs ?? base?.reverseDurationMs ?? durationMs,
      barrierColor: barrierColor ?? base?.barrierColor,
      opaque: opaque ?? base?.opaque ?? true,
      swipeBack: swipeBack ?? base?.swipeBack ?? RouteSwipeBack.platform,
      dismiss: dismiss ?? base?.dismiss,
    );
  }

  /// Milliseconds the transition takes, resolved.
  int get resolvedDurationMs =>
      (durationMs ??
              (preset == null ? null : presetTransition(preset!).durationMs) ??
              300)
          .clamp(0, 60000);

  /// Milliseconds closing takes, resolved.
  int get resolvedReverseDurationMs =>
      (reverseDurationMs ??
              durationMs ??
              (preset == null
                  ? null
                  : presetTransition(preset!).reverseDurationMs) ??
              resolvedDurationMs)
          .clamp(0, 60000);

  /// The concrete transition of [preset].
  static RouteTransition presetTransition(RouteTransitionPreset preset) =>
      switch (preset) {
        // Material 3 shared axis: 30 dp slide; the outgoing screen fades out
        // over the first 30%, the incoming one fades in over the rest.
        RouteTransitionPreset.sharedAxisX => const RouteTransition(
          durationMs: 300,
          enter: TransitionSide(
            motion: MotionModel(translateX: 30, opacity: 0),
          ),
          exit: TransitionSide(
            motion: MotionModel(translateX: -30, opacity: 0),
            durationMs: 90,
          ),
          popEnter: TransitionSide(
            motion: MotionModel(translateX: -30, opacity: 0),
          ),
          popExit: TransitionSide(
            motion: MotionModel(translateX: 30, opacity: 0),
            durationMs: 90,
          ),
        ),
        RouteTransitionPreset.sharedAxisY => const RouteTransition(
          durationMs: 300,
          enter: TransitionSide(
            motion: MotionModel(translateY: 30, opacity: 0),
          ),
          exit: TransitionSide(
            motion: MotionModel(translateY: -30, opacity: 0),
            durationMs: 90,
          ),
          popEnter: TransitionSide(
            motion: MotionModel(translateY: -30, opacity: 0),
          ),
          popExit: TransitionSide(
            motion: MotionModel(translateY: 30, opacity: 0),
            durationMs: 90,
          ),
        ),
        RouteTransitionPreset.sharedAxisZ => const RouteTransition(
          durationMs: 300,
          enter: TransitionSide(motion: MotionModel(scale: 0.8, opacity: 0)),
          exit: TransitionSide(
            motion: MotionModel(scale: 1.1, opacity: 0),
            durationMs: 90,
          ),
          popEnter: TransitionSide(
            motion: MotionModel(scale: 1.1, opacity: 0),
          ),
          popExit: TransitionSide(
            motion: MotionModel(scale: 0.8, opacity: 0),
            durationMs: 90,
          ),
        ),
        RouteTransitionPreset.fadeThrough => const RouteTransition(
          durationMs: 300,
          enter: TransitionSide(
            motion: MotionModel(scale: 0.92, opacity: 0),
            delayMs: 105,
          ),
          exit: TransitionSide(
            motion: MotionModel(opacity: 0),
            curve: MotionCurve.easeIn,
            durationMs: 105,
          ),
        ),
        RouteTransitionPreset.iosPush => const RouteTransition(
          durationMs: 400,
          enter: TransitionSide(
            motion: MotionModel(shiftX: 1),
            curve: MotionCurve.easeOutCubic,
          ),
          exit: TransitionSide(
            motion: MotionModel(shiftX: -1 / 3),
            curve: MotionCurve.easeOutCubic,
          ),
          swipeBack: RouteSwipeBack.always,
        ),
        RouteTransitionPreset.iosModal => const RouteTransition(
          durationMs: 400,
          opaque: false,
          barrierColor: ColorRGBA(r: 0, g: 0, b: 0, a: 0.2),
          enter: TransitionSide(
            motion: MotionModel(shiftY: 1),
            curve: MotionCurve.easeOutCubic,
          ),
          exit: TransitionSide(
            motion: MotionModel(scale: 0.93, translateY: 12),
            curve: MotionCurve.easeOutCubic,
          ),
          dismiss: RouteDismiss(direction: DragDirection.down),
        ),
        RouteTransitionPreset.circularReveal => const RouteTransition(
          durationMs: 450,
          enter: TransitionSide(
            reveal: TransitionReveal(origin: RevealOrigin.node),
            curve: MotionCurve.easeInOut,
          ),
        ),
        RouteTransitionPreset.zoom => const RouteTransition(
          durationMs: 300,
          enter: TransitionSide(motion: MotionModel(scale: 0.85, opacity: 0)),
          exit: TransitionSide(motion: MotionModel(scale: 1.05, opacity: 0)),
        ),
        RouteTransitionPreset.coverVertical => const RouteTransition(
          durationMs: 350,
          enter: TransitionSide(
            motion: MotionModel(shiftY: 1),
            curve: MotionCurve.easeOutCubic,
          ),
          dismiss: RouteDismiss(direction: DragDirection.down),
        ),
        // Each screen turns around the edge it shares with the other, like
        // two faces of a cube seen from outside.
        RouteTransitionPreset.cube => const RouteTransition(
          durationMs: 600,
          enter: TransitionSide(
            motion: MotionModel(
              shiftX: 1,
              rotateY: 90,
              originX: -1,
              perspective: 1.5,
            ),
            curve: MotionCurve.easeInOutCubic,
          ),
          exit: TransitionSide(
            motion: MotionModel(
              shiftX: -1,
              rotateY: -90,
              originX: 1,
              perspective: 1.5,
            ),
            curve: MotionCurve.easeInOutCubic,
          ),
        ),
        // The old screen turns away over the first half, the new one turns
        // in from edge-on over the second, as two faces of one card.
        RouteTransitionPreset.flip => const RouteTransition(
          durationMs: 600,
          enter: TransitionSide(
            motion: MotionModel(rotateY: 90, perspective: 1.5),
            curve: MotionCurve.easeOutCubic,
            delayMs: 300,
          ),
          exit: TransitionSide(
            motion: MotionModel(rotateY: -90, perspective: 1.5),
            curve: MotionCurve.easeIn,
            durationMs: 300,
          ),
        ),
      };

  /// Duplicates this with the given overrides.
  RouteTransition copyWith({
    RouteTransitionPreset? preset,
    TransitionSide? enter,
    TransitionSide? exit,
    TransitionSide? popEnter,
    TransitionSide? popExit,
    int? durationMs,
    int? reverseDurationMs,
    ColorRGBA? barrierColor,
    bool? opaque,
    RouteSwipeBack? swipeBack,
    RouteDismiss? dismiss,
  }) => RouteTransition(
    preset: preset ?? this.preset,
    enter: enter ?? this.enter,
    exit: exit ?? this.exit,
    popEnter: popEnter ?? this.popEnter,
    popExit: popExit ?? this.popExit,
    durationMs: durationMs ?? this.durationMs,
    reverseDurationMs: reverseDurationMs ?? this.reverseDurationMs,
    barrierColor: barrierColor ?? this.barrierColor,
    opaque: opaque ?? this.opaque,
    swipeBack: swipeBack ?? this.swipeBack,
    dismiss: dismiss ?? this.dismiss,
  );

  /// Creates a [RouteTransition] from JSON. A bare preset name (a string)
  /// reads as that preset.
  factory RouteTransition.fromJson(Object json) {
    if (json is String) {
      return RouteTransition(
        preset: $enumDecode(_$RouteTransitionPresetEnumMap, json),
      );
    }
    return _$RouteTransitionFromJson(json as Map);
  }

  @override
  Map toJson() =>
      _$RouteTransitionOmitDefaults(this, _$RouteTransitionToJson(this));

  @override
  List<Object?> get props => [
    preset,
    enter,
    exit,
    popEnter,
    popExit,
    durationMs,
    reverseDurationMs,
    barrierColor,
    opaque,
    swipeBack,
    dismiss,
  ];
}
