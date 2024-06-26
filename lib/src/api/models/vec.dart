// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.
import 'dart:math';

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';
import 'rect.dart';
import 'size.dart';

part 'vec.g.dart';

/// Represents a vector in 2D space.
@JsonSerializable(useDynamics: true)
class Vec with DynamicSerializableMixin, EquatableMixin {
  /// X value: Typically the position on the horizontal x axis in 2D space.
  final double x;

  /// Y value: Typically the position on the vertical y axis in 2D space.
  final double y;

  /// A helper constant for a zero vector.
  static Vec zero = const Vec(0, 0);

  /// Creates a [Vec] with the given [x] and [y].
  const Vec(this.x, this.y);

  /// Creates a [Vec] from the given [size].
  Vec.fromSize(SizeC size) : this(size.width, size.height);

  /// Converts this instance of [Vec] into a [SizeC] for convenience.
  SizeC toSize() => SizeC(x, y);

  /// Returns the summation of this [Vec] instance with the given [other].
  /// Each axis is summed separately.
  Vec operator +(Vec other) => Vec(x + other.x, y + other.y);

  /// Returns the subtraction of the given [other] from this [Vec] instance.
  /// Each axis is subtracted separately.
  Vec operator -(Vec other) => Vec(x - other.x, y - other.y);

  /// Returns the multiplication of this [Vec] instance with the given [scalar].
  /// Both axes are multiplied by the [scalar].
  Vec operator *(double scalar) => Vec(x * scalar, y * scalar);

  /// Returns the division of this [Vec] instance with the given [scalar].
  /// Both axes are divided by the [scalar].
  Vec operator /(double scalar) => Vec(x / scalar, y / scalar);

  /// Returns the summation of this [Vec] instance with the given [other].
  Vec add(Vec other) => this + other;

  /// Returns the summation of this [Vec] instance with the given [other]
  /// [SizeC] for convenience.
  Vec addSize(SizeC other) => Vec(x + other.width, y + other.height);

  /// Returns the subtraction of this [Vec] instance with the given [other].
  Vec subtract(Vec other) => this - other;

  /// Returns the subtraction of this [Vec] instance with the given [other].
  /// [SizeC] for convenience.
  Vec subtractSize(SizeC other) => Vec(x - other.width, y - other.height);

  /// Returns the multiplication of this [Vec] instance with the given [scalar].
  /// Both axes are multiplied by the [scalar].
  Vec multiply(double scalar) => this * scalar;

  /// Returns the multiplication of this [Vec] instance with the given [other].
  /// Each axis is multiplied separately.
  Vec multiplyVec(Vec other) => Vec(x * other.x, y * other.y);

  /// Returns the division of this [Vec] instance with the given [scalar].
  /// Both axes are divided by the [scalar].
  Vec divide(double scalar) => this / scalar;

  /// Returns the dot-product of this [Vec] instance with the given [other].
  double dot(Vec other) => x * other.x + y * other.y;

  /// Returns the translation of this [Vec] instance by the given [x] and [y].
  /// The [x] and [y] values are added to the existing values respectively.
  Vec translate(double x, double y) => Vec(this.x + x, this.y + y);

  /// Returns the distance to [other].
  /// Note that this is an expensive function call due to the use of [sqrt].
  /// To compare distances efficiently, use [distanceToSq].
  double distanceTo(Vec other) =>
      sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));

  /// Returns the squared distance to [other].
  ///
  /// This is a cheaper function call than [distanceTo] since it avoids the
  /// use of [sqrt].
  ///
  /// The difference between the two in terms of produced values is that
  /// [distanceToSq] returns the squared distance, while [distanceTo] returns
  /// the actual distance.
  ///
  /// To do a cheap but identical comparison, use this function but compare it
  /// to the squared value of the distance. For example, to check if the
  /// distance is less than 10, compare against 10 * 10 = (100) instead.
  ///
  /// if (vec.distanceToSq(other) < 10 * 10) {
  ///    ...
  /// }
  double distanceToSq(Vec other) =>
      pow(x - other.x, 2) + pow(y - other.y, 2).toDouble();

  /// Combines this [Vec] with the provided [size] to create a [RectC] with
  /// the same origin as this [Vec] and the size of [size].
  RectC operator &(SizeC size) =>
      RectC.fromLTRB(x, y, x + size.width, y + size.height);

  /// The length is the distance from the origin to this [Vec].
  ///
  /// It is equivalent to [distanceTo] but as if you had passed [Vec.zero] as
  /// the argument.
  ///
  /// This is also an expensive function call due to the use of [sqrt].
  double get length => sqrt(x * x + y * y);

  /// The normalized vector is a vector with the same direction as this [Vec]
  /// but with a length of 1.
  ///
  /// This is an expensive function call due to the use of [sqrt].
  Vec get normalized => this / length;

  /// A vector that is perpendicular to this [Vec].
  Vec get perpendicular => Vec(-y, x);

  /// A negated vector that inverts the direction of this [Vec].
  Vec get negated => Vec(-x, -y);

  @override
  List<Object?> get props => [x, y];

  @override
  String toString() => 'Vec{x: $x, y: $y}';

  /// Creates a [Vec] from the given [json] map.
  factory Vec.fromJson(dynamic json) {
    if (json case [num x, num y]) {
      return Vec(x.toDouble(), y.toDouble());
    }
    return _$VecFromJson(json);
  }

  @override
  dynamic toJson() => [x, y];
}
