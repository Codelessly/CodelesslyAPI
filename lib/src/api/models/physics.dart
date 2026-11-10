import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'physics.g.dart';

/// Where a [SnapModel] settles a released node.
enum SnapKind {
  /// One of [SnapModel.points].
  points,

  /// The nearest crossing of a grid [SnapModel.gridX] by [SnapModel.gridY]
  /// pixels apart, counted from rest.
  grid,

  /// Flush against one of the parent's edges or corners: a picture in
  /// picture window that docks to the nearest corner.
  edges;

  /// Displayable name.
  String get prettify => switch (this) {
    SnapKind.points => 'Points',
    SnapKind.grid => 'Grid',
    SnapKind.edges => 'Edges',
  };
}

/// One place a [SnapModel] can settle a node, in logical pixels from where
/// it rests.
@JsonSerializable()
class SnapPoint with Equatable, SerializableMixin {
  /// Horizontal offset from rest.
  final double x;

  /// Vertical offset from rest.
  final double y;

  /// Creates a [SnapPoint].
  const SnapPoint({this.x = 0, this.y = 0});

  @override
  List<Object?> get props => [x, y];

  /// Creates a [SnapPoint] from JSON. Also reads a bare number as a
  /// point on both axes (`[0, -300, -600]` for a vertical sheet) and a
  /// two-number list as `[x, y]`.
  factory SnapPoint.fromJson(Object? json) => switch (json) {
    num n => SnapPoint(x: n.toDouble(), y: n.toDouble()),
    [num x, num y] => SnapPoint(x: x.toDouble(), y: y.toDouble()),
    Map map => _$SnapPointFromJson(map),
    _ => const SnapPoint(),
  };

  @override
  Map toJson() => _$SnapPointOmitDefaults(this, _$SnapPointToJson(this));
}

/// The places a released node settles at. See [PhysicsModel.snap].
@JsonSerializable()
class SnapModel with Equatable, SerializableMixin {
  /// What the node snaps to.
  @JsonKey(unknownEnumValue: SnapKind.points)
  final SnapKind kind;

  /// For [SnapKind.points]: the places, in pixels from rest. A drag locked
  /// to one axis reads only that coordinate.
  @JsonKey(fromJson: _pointsFromJson)
  final List<SnapPoint> points;

  /// For [SnapKind.grid]: the horizontal pitch in pixels; 0 doesn't snap
  /// horizontally.
  final double gridX;

  /// For [SnapKind.grid]: the vertical pitch; 0 doesn't snap vertically.
  final double gridY;

  /// Picks the target nearest to where a fling at the release velocity
  /// would come to rest, instead of nearest to where the pointer let go: a
  /// flick moves a sheet one stop, a hard throw skips to the far one.
  final bool projectVelocity;

  /// Creates a [SnapModel].
  const SnapModel({
    this.kind = SnapKind.points,
    this.points = const [],
    this.gridX = 0,
    this.gridY = 0,
    this.projectVelocity = true,
  });

  static List<SnapPoint> _pointsFromJson(Object? json) => [
    if (json is List)
      for (final Object? point in json) SnapPoint.fromJson(point),
  ];

  /// Returns a copy with the given values replaced.
  SnapModel copyWith({
    SnapKind? kind,
    List<SnapPoint>? points,
    double? gridX,
    double? gridY,
    bool? projectVelocity,
  }) => SnapModel(
    kind: kind ?? this.kind,
    points: points ?? this.points,
    gridX: gridX ?? this.gridX,
    gridY: gridY ?? this.gridY,
    projectVelocity: projectVelocity ?? this.projectVelocity,
  );

  @override
  List<Object?> get props => [kind, points, gridX, gridY, projectVelocity];

  /// Creates a [SnapModel] from JSON.
  factory SnapModel.fromJson(Map json) => _$SnapModelFromJson(json);

  @override
  Map toJson() => _$SnapModelOmitDefaults(this, _$SnapModelToJson(this));
}

/// How a node moves on its own once the pointer lets go: the one physics
/// model a [DragModel], a [TransformGestureModel] and a [DraggableModel]
/// share, so a fling, a settle and a return spring are set the same way
/// everywhere.
///
/// A release first flings ([fling]): the node keeps the pointer's velocity
/// and slows down by [friction]. Past the bounds it stretches by
/// [overscroll] and springs back. With [snap] it springs to the snap target
/// nearest to where the fling would stop. Every settle runs on one spring:
/// [stiffness], [damping] and [mass], or the friendlier [bounce] and
/// [durationMs].
@JsonSerializable()
class PhysicsModel with Equatable, SerializableMixin {
  /// Spring stiffness: higher is snappier.
  final double stiffness;

  /// Spring damping: about 2·√(stiffness·mass) stops without overshooting;
  /// lower wobbles.
  final double damping;

  /// Spring mass: heavier is slower and swings further.
  final double mass;

  /// The spring as a bounce instead of [stiffness] and [damping]: 0 settles
  /// without overshoot, 0.3 is lively, up to 1 wobbles a lot; negative is
  /// sluggish. Null uses [stiffness] and [damping] unless [durationMs] is
  /// set.
  final double? bounce;

  /// The spring as a settle time, with [bounce] (0 when unset). Null uses
  /// [stiffness] and [damping] unless [bounce] is set.
  final int? durationMs;

  /// Whether a release keeps the pointer's velocity and coasts to a stop.
  final bool fling;

  /// The share of a fling's speed lost per second, 0 to 1: 0.865 coasts
  /// like an iOS scroll view, 0.99 stops almost at once.
  final double friction;

  /// Releases slower than this, in pixels per second, don't fling.
  final double minFlingVelocity;

  /// The fastest a fling starts, in pixels per second.
  final double maxFlingVelocity;

  /// How far a gesture can stretch past its bounds, 0 (a hard stop) to 1
  /// (follows freely). It springs back on release.
  final double overscroll;

  /// Where a release settles. Null for wherever the fling stops.
  final SnapModel? snap;

  /// Creates a [PhysicsModel].
  const PhysicsModel({
    this.stiffness = 380,
    this.damping = 32,
    this.mass = 1,
    this.bounce,
    this.durationMs,
    this.fling = true,
    this.friction = 0.865,
    this.minFlingVelocity = 50,
    this.maxFlingVelocity = 8000,
    this.overscroll = 0.5,
    this.snap,
  });

  /// The default physics of a gesture that names none.
  static const PhysicsModel standard = PhysicsModel();

  /// Named presets the Editor offers and the MCP accepts as
  /// `{"preset": "<name>"}` in place of a physics object.
  static const Map<String, PhysicsModel> presets = {
    'gentle': PhysicsModel(bounce: 0, durationMs: 450),
    'snappy': PhysicsModel(bounce: 0.15, durationMs: 300),
    'bouncy': PhysicsModel(bounce: 0.4, durationMs: 600),
    'heavy': PhysicsModel(stiffness: 200, damping: 30, mass: 2),
  };

  /// Whether the spring is given by [bounce] and [durationMs].
  bool get usesBounce => bounce != null || durationMs != null;

  /// The bounce in effect: [bounce], or what [stiffness], [damping] and
  /// [mass] amount to.
  double get effectiveBounce {
    if (usesBounce) return (bounce ?? 0).clamp(-1.0, 1.0);
    final double critical = 2 * math.sqrt(stiffness * mass);
    if (critical <= 0) return 0;
    final double zeta = damping / critical;
    return zeta <= 1 ? 1 - zeta : 1 / zeta - 1;
  }

  /// Stiffness in effect (from [bounce] and [durationMs] when set), using
  /// the same formula as Flutter's `SpringDescription.withDurationAndBounce`.
  double get effectiveStiffness {
    if (!usesBounce) return stiffness;
    final double seconds = math.max(1, durationMs ?? 500) / 1000;
    return math.pow(2 * math.pi / seconds, 2) * mass.toDouble();
  }

  /// Damping in effect (from [bounce] and [durationMs] when set).
  double get effectiveDamping {
    if (!usesBounce) return damping;
    final double seconds = math.max(1, durationMs ?? 500) / 1000;
    final double b = (bounce ?? 0).clamp(-0.95, 1.0);
    final double ratio = b >= 0 ? 1 - b : 1 / (1 + b);
    // 2·√(m·k) with k = (2π/t)²·m is 4π·m/t.
    return ratio * 4 * math.pi * mass / seconds;
  }

  /// The drag coefficient of a Flutter `FrictionSimulation`: the share of
  /// speed kept after one second.
  double get frictionDrag => (1 - friction).clamp(0.0001, 0.9999);

  /// Where a fling from [position] at [velocity] comes to rest, by
  /// friction alone: `x − v / ln(drag)`. Used to pick a snap target.
  double projectFling(double position, double velocity) {
    if (!fling || velocity.abs() < minFlingVelocity) return position;
    final double v = velocity.clamp(-maxFlingVelocity, maxFlingVelocity);
    return position - v / math.log(frictionDrag);
  }

  /// Returns a copy with the given values replaced.
  PhysicsModel copyWith({
    double? stiffness,
    double? damping,
    double? mass,
    double? bounce,
    bool clearBounce = false,
    int? durationMs,
    bool clearDuration = false,
    bool? fling,
    double? friction,
    double? minFlingVelocity,
    double? maxFlingVelocity,
    double? overscroll,
    SnapModel? snap,
    bool clearSnap = false,
  }) => PhysicsModel(
    stiffness: stiffness ?? this.stiffness,
    damping: damping ?? this.damping,
    mass: mass ?? this.mass,
    bounce: clearBounce ? null : bounce ?? this.bounce,
    durationMs: clearDuration ? null : durationMs ?? this.durationMs,
    fling: fling ?? this.fling,
    friction: friction ?? this.friction,
    minFlingVelocity: minFlingVelocity ?? this.minFlingVelocity,
    maxFlingVelocity: maxFlingVelocity ?? this.maxFlingVelocity,
    overscroll: overscroll ?? this.overscroll,
    snap: clearSnap ? null : snap ?? this.snap,
  );

  @override
  List<Object?> get props => [
    stiffness,
    damping,
    mass,
    bounce,
    durationMs,
    fling,
    friction,
    minFlingVelocity,
    maxFlingVelocity,
    overscroll,
    snap,
  ];

  /// Creates a [PhysicsModel] from JSON. `{"preset": "bouncy"}` reads as
  /// that preset from [presets], with any other keys given overriding it.
  factory PhysicsModel.fromJson(Map json) {
    final Object? preset = json['preset'];
    if (preset is String && presets[preset] != null) {
      final Map base = presets[preset]!.toJson();
      return _$PhysicsModelFromJson({...base, ...json}..remove('preset'));
    }
    return _$PhysicsModelFromJson(json);
  }

  @override
  Map toJson() => _$PhysicsModelOmitDefaults(this, _$PhysicsModelToJson(this));
}

/// What a gesture keeps a node inside of.
enum GestureBounds {
  /// Nothing: the node can go anywhere.
  none,

  /// Stays inside its viewport (its parent, or its own box for
  /// [TransformTarget.content]). Bigger than the viewport on an axis, it
  /// acts like [cover] there.
  contain,

  /// Always covers its viewport, so no gap shows: a zoomed photo or a map.
  /// Smaller than the viewport on an axis, it is centred there.
  cover;

  /// Displayable name.
  String get prettify => switch (this) {
    GestureBounds.none => 'None',
    GestureBounds.contain => 'Contain',
    GestureBounds.cover => 'Cover',
  };
}
