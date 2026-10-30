import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'notch.g.dart';

/// The edges of a shape a [NotchModel] cuts into.
enum NotchEdge {
  /// The left edge.
  left,

  /// The right edge.
  right,

  /// Both the left and right edges, at the same height: a ticket's tear line.
  leftRight,

  /// The top edge.
  top,

  /// The bottom edge.
  bottom,

  /// Both the top and bottom edges, at the same distance from the left.
  topBottom;

  /// Whether the notch runs along a vertical edge (left or right), so its
  /// offset is measured down from the top.
  bool get isVertical => this == left || this == right || this == leftRight;
}

/// A semicircular bite out of a shape's edge, like the notches on either side
/// of a paper ticket's tear line. Fills, strokes, shadows and clipped
/// children all follow the notched outline.
@JsonSerializable()
class NotchModel with Equatable, SerializableMixin {
  /// Which edge(s) the notch cuts.
  final NotchEdge edge;

  /// Where along the edge the notch's centre sits: from the top for left and
  /// right edges, from the left for top and bottom ones (or from the bottom
  /// or right when [fromEnd]). Pixels, or a fraction of the edge's length
  /// when [relative].
  final double offset;

  /// Measures [offset] from the far end of the edge (the bottom or the
  /// right), so a notch keeps its distance from the bottom as the shape
  /// grows.
  final bool fromEnd;

  /// Reads [offset] as a fraction (0–1) of the edge's length.
  final bool relative;

  /// The notch's radius in pixels.
  final double radius;

  /// Creates a [NotchModel].
  const NotchModel({
    this.edge = NotchEdge.leftRight,
    this.offset = 0.5,
    this.fromEnd = false,
    this.relative = true,
    this.radius = 10,
  });

  /// The centre of the notch along an edge of [length] pixels.
  double positionOn(double length) {
    final double at = relative ? offset * length : offset;
    return fromEnd ? length - at : at;
  }

  /// Duplicates this [NotchModel] with the given values replaced.
  NotchModel copyWith({
    NotchEdge? edge,
    double? offset,
    bool? fromEnd,
    bool? relative,
    double? radius,
  }) => NotchModel(
    edge: edge ?? this.edge,
    offset: offset ?? this.offset,
    fromEnd: fromEnd ?? this.fromEnd,
    relative: relative ?? this.relative,
    radius: radius ?? this.radius,
  );

  /// Creates a [NotchModel] from JSON. Every field is optional.
  factory NotchModel.fromJson(Map json) => _$NotchModelFromJson(json);

  @override
  Map toJson() => _$NotchModelToJson(this);

  @override
  List<Object?> get props => [edge, offset, fromEnd, relative, radius];
}
