// The gesture behaviors every node can have: the physics a release runs on
// (shared by a drag, a drag source's return and a transform gesture), a
// two-sided card that turns over, a tilt toward the pointer, and pinch,
// pan and rotate with optional handles. Part of behaviors.dart, so they
// share its value helpers.
part of 'behaviors.dart';

// --- physics -------------------------------------------------------------------

/// What a gesture keeps a node inside of.
enum GestureBounds {
  /// Nothing: it can go anywhere.
  none,

  /// Inside its viewport (its parent, or its own box for
  /// [TransformTarget.content]); bigger than it on an axis, as [cover].
  contain,

  /// Always covers its viewport, so no gap shows (a zoomed photo, a map);
  /// smaller than it on an axis, centered.
  cover,
}

/// Where a [GestureSnap] settles a released node.
enum SnapKind {
  /// One of [GestureSnap.points].
  points,

  /// The nearest crossing of a grid [GestureSnap.gridX] by
  /// [GestureSnap.gridY] pixels, counted from rest.
  grid,

  /// Flush against one of the parent's edges or corners (a picture in
  /// picture window docking to a corner).
  edges,
}

/// The places a released node settles at ([GesturePhysics.snap]).
@immutable
final class GestureSnap extends _Value {
  const GestureSnap({
    this.kind = SnapKind.points,
    this.points = const [],
    this.gridX = 0,
    this.gridY = 0,
    this.projectVelocity = true,
  });

  final SnapKind kind;

  /// For [SnapKind.points]: offsets from rest (pixels). A drag locked to an
  /// axis reads only that coordinate.
  final List<Offset> points;

  /// For [SnapKind.grid]: the pitch per axis; 0 doesn't snap that axis.
  final double gridX, gridY;

  /// Picks the target nearest to where a fling would stop, not to where the
  /// pointer let go: a flick moves a sheet one stop.
  final bool projectVelocity;

  /// A point as `[x, y]`, `{"x", "y"}`, or a number on both axes.
  static Offset? _point(Object? j) {
    if (readDouble(j) case final double n) return Offset(n, n);
    if (readList(j)?.length == 2) return Offset.fromJson(j);
    if (readMap(j) case final Json m) {
      return Offset(readDouble(m['x']) ?? 0, readDouble(m['y']) ?? 0);
    }
    return null;
  }

  static GestureSnap? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return GestureSnap(
      kind: r.e(SnapKind.values, 'kind', SnapKind.points),
      points: [...?readList(m['points'])?.map(_point).nonNulls],
      gridX: r.d('gridX', 0),
      gridY: r.d('gridY', 0),
      projectVelocity: r.b('projectVelocity', true),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}..e('kind', kind, SnapKind.points);
    if (points.isNotEmpty) j['points'] = [for (final p in points) p.toJson()];
    return j
      ..d('gridX', gridX, 0)
      ..d('gridY', gridY, 0)
      ..b('projectVelocity', projectVelocity, true);
  }

  @override
  List<Object?> get props => [kind, points, gridX, gridY, projectVelocity];
}

/// How a node moves on its own once the pointer lets go, the same for a
/// [DragMotion], a [DragSource]'s return and a [TransformGesture]: a fling
/// that slows by [friction], a stretch of [overscroll] past the bounds, and
/// a spring ([stiffness], [damping], [mass]; or [bounce] and [duration], as
/// Flutter's `SpringDescription.withDurationAndBounce`) onto the [snap]
/// target nearest to where the fling would stop.
@immutable
final class GesturePhysics extends _Value {
  const GesturePhysics({
    this.stiffness = 380,
    this.damping = 32,
    this.mass = 1,
    this.bounce,
    this.duration,
    this.fling = true,
    this.friction = 0.865,
    this.minFlingVelocity = 50,
    this.maxFlingVelocity = 8000,
    this.overscroll = 0.5,
    this.snap,
  });

  static const GesturePhysics standard = GesturePhysics();

  /// The presets `{"preset": "<name>"}` reads as (other keys override).
  static const Map<String, GesturePhysics> presets = {
    'gentle': GesturePhysics(bounce: 0, duration: 450),
    'snappy': GesturePhysics(bounce: 0.15, duration: 300),
    'bouncy': GesturePhysics(bounce: 0.4, duration: 600),
    'heavy': GesturePhysics(stiffness: 200, damping: 30, mass: 2),
  };

  final double stiffness, damping, mass;

  /// The spring as a bounce (0 none, up to 1 wobbly; negative sluggish)
  /// and a settle time (ms) instead of [stiffness] and [damping].
  final double? bounce;
  final int? duration;

  /// Whether a release keeps the pointer's velocity and coasts.
  final bool fling;

  /// The share of a fling's speed lost per second (0–1).
  final double friction;

  /// Pixels per second: slower releases don't fling; the fastest start.
  final double minFlingVelocity, maxFlingVelocity;

  /// How far it stretches past its bounds (0 a hard stop, 1 free).
  final double overscroll;
  final GestureSnap? snap;

  bool get usesBounce => bounce != null || duration != null;

  /// The spring's stiffness in effect.
  double get effectiveStiffness {
    if (!usesBounce) return stiffness;
    final seconds = math.max(1, duration ?? 500) / 1000;
    return math.pow(2 * math.pi / seconds, 2) * mass;
  }

  /// The spring's damping in effect.
  double get effectiveDamping {
    if (!usesBounce) return damping;
    final seconds = math.max(1, duration ?? 500) / 1000;
    final b = (bounce ?? 0).clamp(-0.95, 1.0);
    final ratio = b >= 0 ? 1 - b : 1 / (1 + b);
    return ratio * 4 * math.pi * mass / seconds;
  }

  /// The drag of Flutter's `FrictionSimulation`: the share of speed kept
  /// after a second.
  double get frictionDrag => (1 - friction).clamp(0.0001, 0.9999);

  /// Where a fling from [position] at [velocity] stops by friction alone.
  double projectFling(double position, double velocity) {
    if (!fling || velocity.abs() < minFlingVelocity) return position;
    final v = velocity.clamp(-maxFlingVelocity, maxFlingVelocity);
    return position - v / math.log(frictionDrag);
  }

  static GesturePhysics? fromJson(Object? json) {
    var m = readMap(json);
    if (m == null) return null;
    if (presets[m['preset']] case final GesturePhysics preset) {
      m = {...preset.toJson(), ...m}..remove('preset');
    }
    final r = _R(m);
    return GesturePhysics(
      stiffness: r.d('stiffness', 380),
      damping: r.d('damping', 32),
      mass: r.d('mass', 1),
      bounce: r.dn('bounce'),
      duration: readInt(m['duration'])?.let((d) => math.max(0, d)),
      fling: r.b('fling', true),
      friction: r.d('friction', 0.865),
      minFlingVelocity: r.d('minFlingVelocity', 50),
      maxFlingVelocity: r.d('maxFlingVelocity', 8000),
      overscroll: r.d('overscroll', 0.5),
      snap: GestureSnap.fromJson(m['snap']),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..d('stiffness', stiffness, 380)
      ..d('damping', damping, 32)
      ..d('mass', mass, 1)
      ..dn('bounce', bounce);
    if (duration != null) j['duration'] = duration;
    j
      ..b('fling', fling, true)
      ..d('friction', friction, 0.865)
      ..d('minFlingVelocity', minFlingVelocity, 50)
      ..d('maxFlingVelocity', maxFlingVelocity, 8000)
      ..d('overscroll', overscroll, 0.5);
    if (snap != null) j['snap'] = snap!.toJson();
    return j;
  }

  @override
  List<Object?> get props => [
    stiffness,
    damping,
    mass,
    bounce,
    duration,
    fling,
    friction,
    minFlingVelocity,
    maxFlingVelocity,
    overscroll, //
    snap,
  ];
}

// --- a card that turns over ----------------------------------------------------

/// The axis a [FlipCard] turns around.
enum FlipAxis {
  /// Left and right, like a playing card ([Motion.rotateY]).
  y,

  /// Top over bottom, like a calendar page ([Motion.rotateX]).
  x,
}

/// A spring (mass, stiffness, damping), as Flutter's `SpringDescription`.
@immutable
final class FlipSpring extends _Value {
  const FlipSpring({this.stiffness = 380, this.damping = 36, this.mass = 1});

  final double stiffness, damping, mass;

  static FlipSpring? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return FlipSpring(stiffness: r.d('stiffness', 380), damping: r.d('damping', 36), mass: r.d('mass', 1));
  }

  Json toJson() => <String, Object?>{}
    ..d('stiffness', stiffness, 380)
    ..d('damping', damping, 36)
    ..d('mass', mass, 1);

  @override
  List<Object?> get props => [stiffness, damping, mass];
}

/// Makes the node a two-sided card (node key `flip`; a runtime 3D turn,
/// not a mirror): its first child is the front, its second the back,
/// turned 180° in advance; each hides while it faces away. The turn is the
/// node's own [Motion] (rotateY, or rotateX for [FlipAxis.x], 0 or 180),
/// with its perspective, duration (600 ms without one), curve and
/// keyframes. Inside the card `${flip.flipped}` and `${flip.progress}`
/// (0 front, 1 back) can be read.
@immutable
final class FlipCard extends _Value {
  const FlipCard({
    this.axis = FlipAxis.y,
    this.flipped = false,
    this.tapToFlip = true,
    this.dragToFlip = false,
    this.variable = '',
    this.spring = const FlipSpring(),
  });

  final FlipAxis axis;

  /// Whether the back shows. Bindable as `flip.flipped`.
  final bool flipped;

  /// A tap turns it over (and writes [variable]).
  final bool tapToFlip;

  /// A drag across turns it with the finger; it settles on the nearer face
  /// (or follows a fling) on release.
  final bool dragToFlip;

  /// A boolean variable the card follows and a tap or drag writes.
  final String variable;

  /// The spring it settles with after a drag.
  final FlipSpring spring;

  /// How long a turn takes (ms): [motion]'s duration, else 600.
  static int durationOf(Motion? motion) => (motion?.duration ?? 0) > 0 ? motion!.duration : 600;

  static FlipCard? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return FlipCard(
      axis: r.e(FlipAxis.values, 'axis', FlipAxis.y),
      flipped: _loose(m['flipped']) ?? false,
      tapToFlip: r.b('tapToFlip', true),
      dragToFlip: r.b('dragToFlip', false),
      variable: r.s('variable'),
      spring: FlipSpring.fromJson(m['spring']) ?? const FlipSpring(),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..e('axis', axis, FlipAxis.y)
      ..b('flipped', flipped, false)
      ..b('tapToFlip', tapToFlip, true)
      ..b('dragToFlip', dragToFlip, false)
      ..s('variable', variable);
    if (spring != const FlipSpring()) j['spring'] = spring.toJson();
    return j;
  }

  @override
  List<Object?> get props => [axis, flipped, tapToFlip, dragToFlip, variable, spring];
}

/// Tilts the node in 3D toward the pointer while it hovers or drags over
/// it. [max] holds the [Motion] values reached with the pointer at an
/// edge: the edge under it tips away (rotateX at the top and bottom,
/// rotateY at the sides, with its perspective); scale and translate are
/// reached while the pointer is over the node at all. Inside it
/// `${tilt.x}`, `${tilt.y}` (-1–1) can be read, for parallax.
@immutable
final class Tilt extends _Value {
  const Tilt({
    this.max = defaultMax,
    this.hover = true,
    this.drag = true,
    this.reset = 400,
    this.curve = AnimationCurve.easeOutCubic,
  });

  static const Motion defaultMax = Motion(rotateX: 10, rotateY: 10, scale: 1.03);

  final Motion max;

  /// Whether a hovering mouse tilts it, and a drag (or a held touch).
  final bool hover, drag;

  /// The settle back when the pointer leaves (ms) and its curve.
  final int reset;
  final AnimationCurve curve;

  static Tilt? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return Tilt(
      max: Motion.fromJson(m['max']) ?? defaultMax,
      hover: r.b('hover', true),
      drag: r.b('drag', true),
      reset: r.ms('reset', 400),
      curve: r.curve('curve', AnimationCurve.easeOutCubic),
    );
  }

  Json toJson() {
    final j = <String, Object?>{};
    if (max != defaultMax) j['max'] = max.toJson();
    return j
      ..b('hover', hover, true)
      ..b('drag', drag, true)
      ..i('reset', reset, 400)
      ..e('curve', curve, AnimationCurve.easeOutCubic);
  }

  @override
  List<Object?> get props => [max, hover, drag, reset, curve];
}

// --- pinch, pan and rotate ---------------------------------------------------------

/// What a [TransformGesture] moves.
enum TransformTarget {
  /// The node, over its parent (a sticker on a board); bounds are the
  /// parent's box.
  node,

  /// The node's content inside its own clipped box (a photo frame).
  content,
}

/// When one finger (or a mouse) pans a [TransformGesture].
enum TransformPan {
  always,

  /// Only while zoomed in past [TransformGesture.minScale]; at rest a drag
  /// goes to the parent (a pager).
  whenZoomed,

  /// Never (two fingers still move the focal point while pinching).
  never,

  /// Only with two or more fingers (pinching pans too); a one-finger drag
  /// goes to what's inside: painting on a board, drawing on a canvas.
  multiTouch,
}

/// What the mouse wheel does over a [TransformGesture].
enum WheelZoom {
  /// Nothing: the page scrolls.
  none,

  /// Control (Command) + wheel zooms around the pointer, as browsers send
  /// trackpad pinches.
  ctrlZoom,

  /// A plain wheel zooms.
  zoom,

  /// A plain wheel pans; Control + wheel zooms.
  pan,
}

/// On-canvas handles that make a node an editable object (a sticker, a
/// collage): corners scale it, edges stretch it, a knob rotates it.
@immutable
final class TransformHandles extends _Value {
  const TransformHandles({
    this.corners = true,
    this.edges = false,
    this.rotateKnob = true,
    this.snapAngle = 0,
    this.aspectLock = true,
    this.minWidth = 16,
    this.minHeight = 16,
    this.maxWidth = 0,
    this.maxHeight = 0,
    this.outline = true,
    this.color = defaultColor,
    this.handleSize = 12,
    this.selectionVariable = '',
    this.selectionKey = '',
  });

  static const Color defaultColor = Color(0xFF2F80ED);

  final bool corners;

  /// Edge handles stretch one axis ([TransformGesture.scaleXVariable]...);
  /// hidden with [aspectLock].
  final bool edges;
  final bool rotateKnob;

  /// Degrees the knob snaps to (0 free; Shift snaps to 15).
  final double snapAngle;

  /// Corner handles keep the aspect ratio.
  final bool aspectLock;

  /// The drawn size's limits (0 max: none).
  final double minWidth, minHeight, maxWidth, maxHeight;

  /// A selection outline around the box.
  final bool outline;
  final Color color;

  /// A handle's size; its touch target is at least 32.
  final double handleSize;

  /// A text variable holding the selected object's key: handles show only
  /// while it equals [selectionKey] (empty: the node's id), and a tap
  /// writes it. Empty: handles always show.
  final String selectionVariable, selectionKey;

  static TransformHandles? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return TransformHandles(
      corners: r.b('corners', true),
      edges: r.b('edges', false),
      rotateKnob: r.b('rotateKnob', true),
      snapAngle: r.d('snapAngle', 0),
      aspectLock: r.b('aspectLock', true),
      minWidth: r.d('minWidth', 16),
      minHeight: r.d('minHeight', 16),
      maxWidth: r.d('maxWidth', 0),
      maxHeight: r.d('maxHeight', 0),
      outline: r.b('outline', true),
      color: r.color('color') ?? defaultColor,
      handleSize: r.d('handleSize', 12),
      selectionVariable: r.s('selectionVariable'),
      selectionKey: r.s('selectionKey'),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..b('corners', corners, true)
      ..b('edges', edges, false)
      ..b('rotateKnob', rotateKnob, true)
      ..d('snapAngle', snapAngle, 0)
      ..b('aspectLock', aspectLock, true)
      ..d('minWidth', minWidth, 16)
      ..d('minHeight', minHeight, 16)
      ..d('maxWidth', maxWidth, 0)
      ..d('maxHeight', maxHeight, 0)
      ..b('outline', outline, true);
    if (color != defaultColor) j['color'] = color.toJson();
    return j
      ..d('handleSize', handleSize, 12)
      ..s('selectionVariable', selectionVariable)
      ..s('selectionKey', selectionKey);
  }

  @override
  List<Object?> get props => [
    corners,
    edges,
    rotateKnob,
    snapAngle,
    aspectLock,
    minWidth,
    minHeight,
    maxWidth,
    maxHeight,
    outline,
    color, //
    handleSize, selectionVariable, selectionKey,
  ];
}

/// Makes the node pannable, zoomable and rotatable by touch, mouse and
/// trackpad (Flutter's `InteractiveViewer`, and more): pinch and
/// ctrl+wheel zoom about the focal point, one finger pans, two rotate, a
/// double tap zooms to a point; a release flings and settles by [physics]
/// within [bounds] and [minScale]–[maxScale]. The pose binds two-way to
/// variables ([xVariable]...); inside it reads as `${transform.x}`,
/// `${transform.scale}`... Each change runs the node's `changed`
/// reactions, the end of a gesture its `changeEnd` ones.
///
/// [Behaviors.zoomable] is its first form: [zoomable].
@immutable
final class TransformGesture extends _Value {
  const TransformGesture({
    this.enabled = true,
    this.target = TransformTarget.node,
    this.pan = TransformPan.always,
    this.zoom = true,
    this.rotate = false,
    this.minScale = 1,
    this.maxScale = 4,
    this.bounds = GestureBounds.cover,
    this.doubleTapScale = 2.5,
    this.wheel = WheelZoom.ctrlZoom,
    this.rotationSnap = 0,
    this.physics,
    this.xVariable = '',
    this.yVariable = '',
    this.scaleVariable = '',
    this.rotationVariable = '',
    this.scaleXVariable = '',
    this.scaleYVariable = '',
    this.handles,
    this.x,
    this.y,
    this.scale,
    this.rotation,
    this.scaleX,
    this.scaleY,
  });

  /// What [Behaviors.zoomable] amounts to: the content zooms inside the
  /// node up to 4×, pans once zoomed, a double tap zooms 2.5×.
  static const TransformGesture zoomable = TransformGesture(
    target: TransformTarget.content,
    pan: TransformPan.whenZoomed,
  );

  /// Bindable as `transformGesture.enabled`.
  final bool enabled;
  final TransformTarget target;
  final TransformPan pan;

  /// Whether pinch, wheel and double tap zoom; two fingers rotate.
  final bool zoom, rotate;

  /// Past either, the scale rubber-bands and springs back.
  final double minScale, maxScale;
  final GestureBounds bounds;

  /// The scale a double tap zooms to (and back to [minScale]); 0 is off.
  final double doubleTapScale;
  final WheelZoom wheel;

  /// Degrees the rotation settles to a multiple of (0 free).
  final double rotationSnap;

  /// Null for [GesturePhysics.standard].
  final GesturePhysics? physics;

  /// Number variables holding the pose, two-way (a zoom slider).
  final String xVariable, yVariable, scaleVariable, rotationVariable, scaleXVariable, scaleYVariable;
  final TransformHandles? handles;

  /// The pose given from data (bound as `transformGesture.x`...), which the
  /// node springs to when it changes; null for the gesture's own.
  final double? x, y, scale, rotation, scaleX, scaleY;

  GesturePhysics get effectivePhysics => physics ?? GesturePhysics.standard;

  /// Whether one finger may pan at [scale].
  /// (Two fingers pan with [TransformPan.always], [TransformPan.whenZoomed]
  /// and [TransformPan.multiTouch].)
  bool pansAt(double scale) => switch (pan) {
    TransformPan.always => true,
    TransformPan.whenZoomed => scale > minScale + 0.001,
    TransformPan.never || TransformPan.multiTouch => false,
  };

  static TransformGesture? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    return TransformGesture(
      enabled: _loose(m['enabled']) ?? true,
      target: r.e(TransformTarget.values, 'target', TransformTarget.node),
      pan: r.e(TransformPan.values, 'pan', TransformPan.always),
      zoom: r.b('zoom', true),
      rotate: r.b('rotate', false),
      minScale: r.d('minScale', 1),
      maxScale: r.d('maxScale', 4),
      bounds: r.e(GestureBounds.values, 'bounds', GestureBounds.cover),
      doubleTapScale: r.d('doubleTapScale', 2.5),
      wheel: r.e(WheelZoom.values, 'wheel', WheelZoom.ctrlZoom),
      rotationSnap: r.d('rotationSnap', 0),
      physics: GesturePhysics.fromJson(m['physics']),
      xVariable: r.s('xVariable'),
      yVariable: r.s('yVariable'),
      scaleVariable: r.s('scaleVariable'),
      rotationVariable: r.s('rotationVariable'),
      scaleXVariable: r.s('scaleXVariable'),
      scaleYVariable: r.s('scaleYVariable'),
      handles: TransformHandles.fromJson(m['handles']),
      x: r.dn('x'),
      y: r.dn('y'),
      scale: r.dn('scale'),
      rotation: r.dn('rotation'),
      scaleX: r.dn('scaleX'),
      scaleY: r.dn('scaleY'),
    );
  }

  Json toJson() {
    final j = <String, Object?>{}
      ..b('enabled', enabled, true)
      ..e('target', target, TransformTarget.node)
      ..e('pan', pan, TransformPan.always)
      ..b('zoom', zoom, true)
      ..b('rotate', rotate, false)
      ..d('minScale', minScale, 1)
      ..d('maxScale', maxScale, 4)
      ..e('bounds', bounds, GestureBounds.cover)
      ..d('doubleTapScale', doubleTapScale, 2.5)
      ..e('wheel', wheel, WheelZoom.ctrlZoom)
      ..d('rotationSnap', rotationSnap, 0);
    if (physics != null) j['physics'] = physics!.toJson();
    j
      ..s('xVariable', xVariable)
      ..s('yVariable', yVariable)
      ..s('scaleVariable', scaleVariable)
      ..s('rotationVariable', rotationVariable)
      ..s('scaleXVariable', scaleXVariable)
      ..s('scaleYVariable', scaleYVariable);
    if (handles != null) j['handles'] = handles!.toJson();
    return j
      ..dn('x', x)
      ..dn('y', y)
      ..dn('scale', scale)
      ..dn('rotation', rotation)
      ..dn('scaleX', scaleX)
      ..dn('scaleY', scaleY);
  }

  @override
  List<Object?> get props => [
    enabled,
    target,
    pan,
    zoom,
    rotate,
    minScale,
    maxScale,
    bounds,
    doubleTapScale,
    wheel,
    rotationSnap,
    physics, //
    xVariable,
    yVariable,
    scaleVariable,
    rotationVariable,
    scaleXVariable,
    scaleYVariable,
    handles,
    x,
    y,
    scale,
    rotation, scaleX, scaleY,
  ];
}

// --- shared elements ---------------------------------------------------------------

/// What a shared element's destination shows while its own drawing isn't
/// ready (a network image still loading).
enum HeroPlaceholder {
  /// Nothing extra.
  none,

  /// The source's drawing stays under the destination's until its image
  /// has loaded (a thumbnail holds the place of the full image).
  source,
}
