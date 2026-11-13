// A place along an SVG path (docs/design/03-motion.md §3.1): shared by a
// node that follows a path (`motion.path`) and a track's thumb
// (`track.path`, docs/design/04-drag-and-track.md).
import 'package:meta/meta.dart';

import 'json.dart';

/// How a node on a [PathFollow] turns with the path.
enum PathOrient {
  /// It doesn't.
  none,

  /// With the path's direction.
  tangent,

  /// With the path's direction, folded into −90…90 degrees so it is never
  /// upside down.
  upright,
}

/// A place along an SVG path. Shared by `motion.path` and `track.path`.
@immutable
final class PathFollow {
  const PathFollow({required this.path, this.viewBox, this.progress = 0, this.orient = PathOrient.none});

  /// SVG path data.
  final String path;

  /// The path's coordinate space `[width, height]`, stretched over the
  /// node's parent; its points are where the node's center goes. Null: the
  /// path is in pixels, as offsets from its first point, from the node's place.
  final List<double>? viewBox;

  /// Where along the path's length, 0–1. Values outside wrap on a closed
  /// path and clamp on an open one.
  final double progress;

  /// `none`; `tangent`: turned with the path's direction; `upright`: the
  /// same, folded into −90…90 degrees so it is never upside down.
  final PathOrient orient;

  /// The view box's width and height, or null when it has none (or one not
  /// above 0).
  (double, double)? get viewBoxSize {
    final v = viewBox;
    if (v == null || v.length < 2) return null;
    final (w, h) = v.length >= 4 ? (v[2], v[3]) : (v[0], v[1]);
    return w > 0 && h > 0 ? (w, h) : null;
  }

  /// A path given as `{"path", "viewBox", "progress", "orient"}`, or as its
  /// SVG data alone; null for anything else.
  static PathFollow? fromJson(Object? json) {
    if (json is String) return json.trim().isEmpty ? null : PathFollow(path: json);
    final m = readMap(json);
    if (m == null) return null;
    final path = readString(m['path']);
    if (path == null) return null;
    final box = readList(m['viewBox'])?.map(readDouble).nonNulls.toList();
    return PathFollow(
      path: path,
      viewBox: box == null || box.isEmpty ? null : box,
      progress: readDouble(m['progress']) ?? 0,
      orient: readEnum(PathOrient.values, m['orient'], PathOrient.none),
    );
  }

  Json toJson() => {
    'path': path,
    if (viewBox != null) 'viewBox': [for (final v in viewBox!) writeDouble(v)],
    if (progress != 0) 'progress': writeDouble(progress),
    if (orient != PathOrient.none) 'orient': orient.name,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathFollow &&
          other.path == path &&
          jsonEquality.equals(other.viewBox, viewBox) &&
          other.progress == progress &&
          other.orient == orient;

  @override
  int get hashCode => Object.hash(path, jsonEquality.hash(viewBox), progress, orient);
}
