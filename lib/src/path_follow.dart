// A place along an SVG path (docs/design/03-motion.md §3.1): what a node's
// `motion.path` sits on, and what a drag track's path (doc 04) follows.
// Flutter: `PathMetric.getTangentForOffset`.
part of 'behaviors.dart';

/// How a node on a [PathFollow] turns with the path.
enum PathOrient {
  /// It keeps its own rotation.
  none,

  /// Turned with the path's direction (`Transform.rotate(angle:
  /// tangent.angle)`).
  tangent,

  /// The same, folded into −90…90 degrees so it is never upside down.
  upright,

  /// [upright], and mirrored (`Transform.flip(flipX: true)`) while the path
  /// heads left, so its front still leads: a train, a car, a fish.
  uprightFlip,
}

/// How [PathFollow.progress] maps to a place on the path.
/// Deprecated: kept for the documents that set `pathPacing: area` (one
/// app); pace a path with a curve or a formula on its progress instead.
enum PathPacing {
  /// The share of the path's length: even speed along the curve.
  length,

  /// The share of the area swept about [PathFollow.focus] (Kepler's second
  /// law: an orbit speeding up near its Sun).
  area,
}

/// A place along an SVG path: [progress] (0–1) of the way along [path]'s
/// length, turned with it as [orient] says. Shared by `motion.path` and a
/// drag track's path.
///
/// Values of [progress] outside 0–1 wrap round a closed path (one that ends
/// where it starts) and clamp to the ends of an open one.
///
/// JSON: `{"path": "M0 0 C 40 -60, 120 -60, 160 0", "progress": 0.5,
/// "orient": "tangent"}`; a bare string reads as [path].
@immutable
final class PathFollow extends _Value {
  const PathFollow({
    required this.path,
    this.viewBox = const [],
    this.progress = 0,
    this.orient = PathOrient.none,
    this.pacing = PathPacing.length,
    this.focus = const [0, 0],
  });

  /// SVG path data.
  final String path;

  /// The path's coordinate space `[width, height]`, stretched over the
  /// node's parent: its points are where the node goes, from the parent's
  /// origin (lay the node out at the origin, offset by half its size to
  /// centre it). Empty: the path is in pixels, as offsets from its first
  /// point, from the node's own place.
  final List<double> viewBox;

  /// Where along the path's length, 0–1. Bindable as `motion.path.progress`.
  final double progress;

  final PathOrient orient;

  /// Deprecated: how [progress] maps to a place (`area` pacing, one app).
  final PathPacing pacing;

  /// Deprecated: the focus `[x, y]` of `area` pacing, in the path's
  /// coordinates.
  final List<double> focus;

  bool get hasPath => path.trim().isNotEmpty;

  /// [viewBox] when it is a usable size.
  List<double>? get effectiveViewBox => viewBox.length >= 2 && viewBox[0] > 0 && viewBox[1] > 0 ? viewBox : null;

  bool get pacedByArea => pacing == PathPacing.area;

  PathFollow copyWith({double? progress}) => PathFollow(
        path: path,
        viewBox: viewBox,
        progress: progress ?? this.progress,
        orient: orient,
        pacing: pacing,
        focus: focus,
      );

  /// [progress] modulo 1 (1 stays the end): a closed path's place.
  static double wrap(double progress) {
    if (!progress.isFinite) return 0;
    if (progress >= 0 && progress <= 1) return progress;
    final r = progress % 1;
    return r < 0 ? r + 1 : r;
  }

  /// A path direction [radians] folded into −90…90 degrees (turned half
  /// round where it heads left), for [PathOrient.upright].
  static double uprightAngle(double radians) {
    var a = radians % (2 * math.pi);
    if (a > math.pi) a -= 2 * math.pi;
    if (a > math.pi / 2) return a - math.pi;
    if (a < -math.pi / 2) return a + math.pi;
    return a;
  }

  /// Whether a path direction [radians] heads left (what
  /// [PathOrient.uprightFlip] mirrors).
  static bool headsLeft(double radians) {
    var a = radians % (2 * math.pi);
    if (a > math.pi) a -= 2 * math.pi;
    return a > math.pi / 2 || a < -math.pi / 2;
  }

  static PathFollow? fromJson(Object? json) {
    if (json is String) return json.trim().isEmpty ? null : PathFollow(path: json);
    final m = readMap(json);
    if (m == null) return null;
    final r = _R(m);
    final box = r.doubles('viewBox');
    final focus = r.doubles('focus');
    return PathFollow(
      path: r.s('path'),
      viewBox: box,
      progress: r.d('progress', 0),
      orient: r.e(PathOrient.values, 'orient', PathOrient.none),
      pacing: r.e(PathPacing.values, 'pacing', PathPacing.length),
      focus: focus.isEmpty ? const [0, 0] : focus,
    );
  }

  /// The legacy flat path keys of motion JSON [m] (`path` text,
  /// `pathProgress`, `orientToPath`, `orientUpright`, `uprightMirror`,
  /// `pathViewBox`, `pathPacing`, `pathFocusX/Y`), over its `path` (text or
  /// object) when it has one; null when it names no path at all. `pathWrap`
  /// isn't read: a closed path wraps by definition.
  static PathFollow? fromLegacy(Json m) {
    final base = fromJson(m['path']);
    const keys = [
      'pathProgress', 'orientToPath', 'orientUpright', 'uprightMirror', 'pathViewBox', 'pathPacing', 'pathFocusX', //
      'pathFocusY',
    ];
    if (!keys.any(m.containsKey)) return base;
    final r = _R(m);
    final box = r.doubles('pathViewBox');
    final orient = base?.orient ?? PathOrient.none;
    final tangent = r.b('orientToPath', orient != PathOrient.none);
    final upright = r.b('orientUpright', orient == PathOrient.upright || orient == PathOrient.uprightFlip);
    final flip = r.b('uprightMirror', orient == PathOrient.uprightFlip);
    final focus = [...?base?.focus, 0.0, 0.0];
    return PathFollow(
      path: base?.path ?? '',
      viewBox: box.isNotEmpty ? box : base?.viewBox ?? const [],
      progress: r.d('pathProgress', base?.progress ?? 0),
      orient: !tangent
          ? PathOrient.none
          : !upright
              ? PathOrient.tangent
              : flip
                  ? PathOrient.uprightFlip
                  : PathOrient.upright,
      pacing: r.e(PathPacing.values, 'pathPacing', base?.pacing ?? PathPacing.length),
      focus: [r.d('pathFocusX', focus[0]), r.d('pathFocusY', focus[1])],
    );
  }

  Json toJson() {
    final j = <String, Object?>{'path': path};
    if (viewBox.isNotEmpty) j['viewBox'] = viewBox.map(writeDouble).toList();
    j
      ..d('progress', progress, 0)
      ..e('orient', orient, PathOrient.none)
      ..e('pacing', pacing, PathPacing.length);
    if (focus.any((v) => v != 0)) j['focus'] = focus.map(writeDouble).toList();
    return j;
  }

  @override
  List<Object?> get props => [path, viewBox, progress, orient, pacing, focus];
}
