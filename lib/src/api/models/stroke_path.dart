import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'stroke_path.g.dart';

/// How a [StrokePath]'s [StrokePath.points] are measured on one axis.
enum PathUnit {
  /// A fraction of the node's size: 0 is the left/top edge, 1 the
  /// right/bottom edge, so the path stretches with the node.
  fraction,

  /// Logical pixels from the node's left/top edge.
  pixels;

  /// Displayable name.
  String get prettify => switch (this) {
    PathUnit.fraction => 'Fraction',
    PathUnit.pixels => 'Pixels',
  };
}

/// How a [StrokePath] joins its points.
enum PathCurve {
  /// Straight lines from point to point.
  straight,

  /// Smooth S-curves that leave and arrive vertically (a winding path down
  /// a page): each segment is a cubic curve with both control points at
  /// the segment's middle height.
  vertical,

  /// Smooth S-curves that leave and arrive horizontally (a flow chart
  /// connector): control points at the segment's middle width.
  horizontal;

  /// Displayable name.
  String get prettify => switch (this) {
    PathCurve.straight => 'Straight',
    PathCurve.vertical => 'Vertical curves',
    PathCurve.horizontal => 'Horizontal curves',
  };
}

/// End caps of a [StrokePath]'s line and dashes.
enum PathCap {
  /// Flat at the end point.
  butt,

  /// Rounded past the end point.
  round,

  /// Square past the end point.
  square,
}

/// A line drawn through points inside a node's box: a dotted trail between
/// level nodes, a connector between cards, a sketch of a route.
///
/// [points] are `[x, y]` pairs measured as [xUnit] and [yUnit] say. They are
/// bindable through `strokePath.points` in [BaseNode.variables] (a list of
/// `[x, y]` lists, or of maps with `x` and `y`), so the path can follow
/// data, e.g. one point per level of a list item.
///
/// The line is drawn behind the node's children (or in front with
/// [inFront]) and doesn't take part in layout or taps.
@JsonSerializable()
class StrokePath with Equatable, SerializableMixin {
  /// The points, `[x, y]` each.
  final List<List<double>> points;

  /// How x is measured.
  final PathUnit xUnit;

  /// How y is measured.
  final PathUnit yUnit;

  /// How the points are joined.
  final PathCurve curve;

  /// The line's color, `#RRGGBB` or `#AARRGGBB`.
  final String color;

  /// The line's width in logical pixels.
  final double width;

  /// Dash pattern: lengths of dash and gap, repeated. Empty draws a solid
  /// line.
  final List<double> dash;

  /// End caps of the line and of every dash.
  final PathCap cap;

  /// Whether the line is drawn over the node's children instead of behind.
  final bool inFront;

  /// Creates a [StrokePath].
  const StrokePath({
    this.points = const [],
    this.xUnit = PathUnit.fraction,
    this.yUnit = PathUnit.pixels,
    this.curve = PathCurve.straight,
    this.color = '#FFFFFFFF',
    this.width = 4,
    this.dash = const [],
    this.cap = PathCap.round,
    this.inFront = false,
  });

  /// The key in [BaseNode.variables] that binds [points].
  static const String pointsVariable = 'strokePath.points';

  /// Returns a copy with the given values replaced.
  StrokePath copyWith({
    List<List<double>>? points,
    PathUnit? xUnit,
    PathUnit? yUnit,
    PathCurve? curve,
    String? color,
    double? width,
    List<double>? dash,
    PathCap? cap,
    bool? inFront,
  }) => StrokePath(
    points: points ?? this.points,
    xUnit: xUnit ?? this.xUnit,
    yUnit: yUnit ?? this.yUnit,
    curve: curve ?? this.curve,
    color: color ?? this.color,
    width: width ?? this.width,
    dash: dash ?? this.dash,
    cap: cap ?? this.cap,
    inFront: inFront ?? this.inFront,
  );

  @override
  List<Object?> get props => [
    points,
    xUnit,
    yUnit,
    curve,
    color,
    width,
    dash,
    cap,
    inFront,
  ];

  /// Creates a [StrokePath] from JSON.
  factory StrokePath.fromJson(Map json) => _$StrokePathFromJson(json);

  @override
  Map toJson() => _$StrokePathOmitDefaults(this, _$StrokePathToJson(this));
}

/// Scrolls the scroll views around a node so the node shows: when it
/// appears and, with a `reveal.when` binding in [BaseNode.variables], each
/// time that condition turns true. A level map opens at the current level;
/// a chat list keeps its newest message in view.
@JsonSerializable()
class RevealModel with Equatable, SerializableMixin {
  /// Where the node ends up in the scroll view: 0 at the start (top), 0.5
  /// centered, 1 at the end.
  final double alignment;

  /// How long the scroll takes, in milliseconds; 0 jumps.
  final int durationMs;

  /// Waits this long after the node appears, in milliseconds.
  final int delayMs;

  /// Creates a [RevealModel].
  const RevealModel({
    this.alignment = 0.5,
    this.durationMs = 600,
    this.delayMs = 0,
  });

  /// The key in [BaseNode.variables] whose truth reveals the node.
  static const String whenVariable = 'reveal.when';

  /// Returns a copy with the given values replaced.
  RevealModel copyWith({double? alignment, int? durationMs, int? delayMs}) =>
      RevealModel(
        alignment: alignment ?? this.alignment,
        durationMs: durationMs ?? this.durationMs,
        delayMs: delayMs ?? this.delayMs,
      );

  @override
  List<Object?> get props => [alignment, durationMs, delayMs];

  /// Creates a [RevealModel] from JSON.
  factory RevealModel.fromJson(Map json) => _$RevealModelFromJson(json);

  @override
  Map toJson() => _$RevealModelOmitDefaults(this, _$RevealModelToJson(this));
}
