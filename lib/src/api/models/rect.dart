// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../mixins.dart';
import 'size.dart';
import 'vec.dart';

part 'rect.g.dart';

/// An immutable, 2D, axis-aligned, floating-point rectangle whose coordinates
/// are relative to a given origin.
@JsonSerializable()
class RectC with SerializableMixin, EquatableMixin {
  /// The offset of the left edge of this rectangle from the x-axis.
  final double left;

  /// The offset of the top edge of this rectangle from the y-axis.
  final double top;

  /// The offset of the right edge of this rectangle from the x-axis.
  final double right;

  /// The offset of the bottom edge of this rectangle from the y-axis.
  final double bottom;

  /// Creates new [RectC] with given data.
  const RectC({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  /// Construct the smallest rectangle that encloses the given offsets, treating
  /// them as vectors from the origin.
  const RectC.fromLTRB(this.left, this.top, this.right, this.bottom);

  /// Construct the smallest rectangle that encloses the given width and height,
  /// from [0,0] origin.
  const RectC.fromSize(double width, double height)
      : left = 0,
        top = 0,
        right = width,
        bottom = height;

  /// Construct a rectangle from its left and top edges, its width, and its
  /// height.
  const RectC.fromLTWH(double left, double top, double width, double height)
      : this.fromLTRB(left, top, left + width, top + height);

  /// Construct a rectangle that bounds the given circle.
  RectC.fromCircle({required Vec center, required double radius})
      : this.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * 2,
        );

  /// Constructs a rectangle from its center point, width, and height.
  RectC.fromCenter(
      {required Vec center, required double width, required double height})
      : this.fromLTRB(
          center.x - width / 2,
          center.y - height / 2,
          center.x + width / 2,
          center.y + height / 2,
        );

  /// Construct the smallest rectangle that encloses the given offsets, treating
  /// them as vectors from the origin.
  RectC.fromPoints(Vec a, Vec b)
      : this.fromLTRB(
          min(a.x, b.x),
          min(a.y, b.y),
          max(a.x, b.x),
          max(a.y, b.y),
        );

  /// A rectangle with left, top, right, and bottom edges all at zero.
  static const RectC zero = RectC.fromLTRB(0, 0, 0, 0);

  /// The distance between the left and right edges of this rectangle.
  double get width => right - left;

  /// The distance between the top and bottom edges of this rectangle.
  double get height => bottom - top;

  /// The distance between the upper-left corner and the lower-right corner of
  /// this rectangle.
  SizeC get size => SizeC(width, height);

  /// Whether any of the dimensions are `NaN`.
  bool get hasNan => left.isNaN || top.isNaN || right.isNaN || bottom.isNaN;

  /// The lesser of the magnitudes of the [width] and the [height] of this
  /// rectangle.
  double get shortestSide => min(width, height);

  /// The greater of the magnitudes of the [width] and the [height] of this
  /// rectangle.
  double get longestSide => max(width, height);

  /// The offset to the intersection of the top and left edges of this
  /// rectangle.
  Vec get topLeft => Vec(left, top);

  /// The offset to the intersection of the top and right edges of this
  /// rectangle.
  Vec get topRight => Vec(right, top);

  /// The offset to the intersection of the bottom and left edges of this
  /// rectangle.
  Vec get bottomLeft => Vec(left, bottom);

  /// The offset to the intersection of the bottom and right edges of this
  /// rectangle.
  Vec get bottomRight => Vec(right, bottom);

  /// The offset to the point halfway between the left and right and the top and
  /// bottom edges of this rectangle.
  Vec get center => Vec(left + width / 2, top + height / 2);

  /// The offset to the center of the left edge of this rectangle.
  Vec get centerLeft => Vec(left, top + height / 2);

  /// The offset to the center of the right edge of this rectangle.
  Vec get centerRight => Vec(right, top + height / 2);

  /// The offset to the center of the top edge of this rectangle.
  Vec get topCenter => Vec(left + width / 2, top);

  /// The offset to the center of the bottom edge of this rectangle.
  Vec get bottomCenter => Vec(left + width / 2, bottom);

  /// Whether the point specified by the given offset (which is assumed to be
  /// relative to the origin) lies between the left and right and the top and
  /// bottom edges of this rectangle.
  ///
  /// Rectangles include their top and left edges but exclude their bottom and
  /// right edges.
  bool contains(Vec point) {
    return point.x >= left &&
        point.x <= right &&
        point.y >= top &&
        point.y <= bottom;
  }

  /// Whether the point specified by the given [x] and [y] (which is assumed to
  /// be relative to the origin) lies between the left and right and the top
  /// and bottom edges of this rectangle.
  bool containsXY(double x, double y) {
    return x >= left && x <= right && y >= top && y <= bottom;
  }

  /// Expands this rect such that it includes all the points around with given
  /// distance [value]. Moves all edges outwards by given distance [value].
  RectC expand(double value) => RectC.fromLTRB(
        left - value,
        top - value,
        right + value,
        bottom + value,
      );

  /// Returns a new rectangle which is the bounding box containing this
  /// rectangle and the given rectangle.
  RectC expandToInclude(RectC rect) => RectC.fromLTRB(
        min(left, rect.left),
        min(top, rect.top),
        max(right, rect.right),
        max(bottom, rect.bottom),
      );

  /// Returns a new [v] translated by the given [vec].
  RectC translate(Vec vec) => RectC.fromLTRB(
        left + vec.x,
        top + vec.y,
        right + vec.x,
        bottom + vec.y,
      );

  /// Returns a new [RectC] with edges and radii moved outwards by the given
  /// delta.
  RectC inflate(double value) => RectC.fromLTRB(
        left - value,
        top - value,
        right + value,
        bottom + value,
      );

  /// Whether this rect intersects with given [rect].
  RectC intersect(RectC rect) {
    return RectC.fromLTRB(
      max(left, rect.left),
      max(top, rect.top),
      min(right, rect.right),
      min(bottom, rect.bottom),
    );
  }

  /// Returns a new rectangle with edges moved inwards by the given delta.
  RectC deflate(double value) => inflate(-value);

  /// Subtracts the given [other] rect from this rectangle.
  RectC operator -(RectC other) => RectC.fromLTRB(
        left - other.left,
        top - other.top,
        right - other.right,
        bottom - other.bottom,
      );

  /// Adds the given [other] rect to this rectangle.
  RectC operator +(RectC other) => RectC.fromLTRB(
        left + other.left,
        top + other.top,
        right + other.right,
        bottom + other.bottom,
      );

  @override
  List<Object?> get props => [left, top, right, bottom];

  /// Factory constructor to create [RectC] from JSON data.
  factory RectC.fromJson(Map json) => _$RectCFromJson(json);

  @override
  Map toJson() => _$RectCToJson(this);

  @override
  String toString() {
    return 'RectC{left: $left, top: $top, right: $right, bottom: $bottom, width: $width, height: $height}';
  }
}
