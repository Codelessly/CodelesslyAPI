// A place along an SVG path (docs/design/03-motion.md §3.1): what a node's
// `motion.path` sits on, and what a drag track's path (doc 04) follows.
// Flutter: `PathMetric.getTangentForOffset`. A library of its own (the
// track's and the motion's models import it).
import 'dart:math' as math;

import 'package:meta/meta.dart';

import 'json.dart';

/// [m]'s numbers at [k] (a list), or none.
List<double> _doubles(Json m, String k) => [...?readList(m[k])?.map(readDouble).nonNulls];

/// How a node on a [PathFollow] turns with the path.
enum PathOrient {
  /// It keeps its own rotation.
  none,

  /// Turned with the path's direction (`Transform.rotate(angle:
  /// tangent.angle)`).
  tangent,

  /// The same, folded into −90…90 degrees so it is never upside down.
  upright,
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
final class PathFollow {
  const PathFollow({
    required this.path,
    this.viewBox = const [],
    this.progress = 0,
    this.orient = PathOrient.none,
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

  bool get hasPath => path.trim().isNotEmpty;

  /// [viewBox] when it is a usable size.
  /// The view box's width and height (`[w, h]`, or the last two of `[x, y,
  /// w, h]`), or null when it has none (or one not above 0).
  (double, double)? get viewBoxSize {
    if (viewBox.length < 2) return null;
    final (w, h) = viewBox.length >= 4 ? (viewBox[2], viewBox[3]) : (viewBox[0], viewBox[1]);
    return w > 0 && h > 0 ? (w, h) : null;
  }

  List<double>? get effectiveViewBox => viewBox.length >= 2 && viewBox[0] > 0 && viewBox[1] > 0 ? viewBox : null;


  PathFollow copyWith({double? progress}) => PathFollow(
        path: path,
        viewBox: viewBox,
        progress: progress ?? this.progress,
        orient: orient,
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

  static PathFollow? fromJson(Object? json) {
    if (json is String) return json.trim().isEmpty ? null : PathFollow(path: json);
    final m = readMap(json);
    if (m == null) return null;
    final box = _doubles(m, 'viewBox');
    return PathFollow(
      path: readString(m['path']) ?? '',
      viewBox: box,
      progress: readDouble(m['progress']) ?? 0,
      orient: readEnum(PathOrient.values, m['orient'], PathOrient.none),
    );
  }

  Json toJson() {
    final j = <String, Object?>{'path': path};
    if (viewBox.isNotEmpty) j['viewBox'] = viewBox.map(writeDouble).toList();
    if (progress != 0) j['progress'] = writeDouble(progress);
    if (orient != PathOrient.none) j['orient'] = orient.name;
    return j;
  }

  List<Object?> get _props => [path, viewBox, progress, orient];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PathFollow && jsonEquality.equals(other._props, _props);

  @override
  int get hashCode => jsonEquality.hash(_props);
}
