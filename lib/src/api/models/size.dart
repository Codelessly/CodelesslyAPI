// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'vec.dart';

part 'size.g.dart';

/// Represents a size in 2D space.
///
/// The reason it is called [SizeC] instead of [Size] is because [Size] is a
/// built-in class in Flutter and can cause conflicts.
///
/// The C stands for Codelessly.
@JsonSerializable()
class SizeC with SerializableMixin, EquatableMixin {
  /// Width value: Typically distance on x axis from the origin point (0,0).
  final double width;

  /// Height value: Typically distance on y axis from the origin point (0,0).
  final double height;

  /// An empty size, one with a zero width and a zero height.
  static SizeC zero = const SizeC(0, 0);

  /// Creates a [SizeC] with the given [width] and [height].
  const SizeC(this.width, this.height);

  /// Creates a [SizeC] instance from given [vec].
  SizeC.fromVector(Vec vec) : this(vec.x, vec.y);

  /// Creates a [SizeC] instance with the same width and height as [size].
  SizeC.square(double size) : this(size, size);

  /// Converts a [SizeC] to a [Vec].
  Vec toVector() => Vec(width, height);

  /// Returns the shortest side value.
  double get shortestSide => min(width, height);

  /// Returns the longest side value.
  double get longestSide => max(width, height);

  /// Rectangular area that is covered by this SizeC.
  double get area => width * height;

  /// Returns circumference of the rectangle created with this size.
  double get circumference => 2 * (width + height);

  /// Returns scaled size by given [scale].
  SizeC scale(double scale) => SizeC(width * scale, height * scale);

  /// Returns fractional difference between this size and [other] size.
  SizeC scaleTo(SizeC size) => SizeC(width / size.width, height / size.height);

  /// Adds given [size] to this size and returns the result.
  operator +(SizeC size) => SizeC(width + size.width, height + size.height);

  /// Subtracts given [size] from this size and returns the result.
  operator -(SizeC size) => SizeC(width - size.width, height - size.height);

  /// Returns scaled up size by given [scale].
  operator *(double scale) => SizeC(width * scale, height * scale);

  /// Returns scaled down size by given [scale].
  operator /(double scale) => SizeC(width / scale, height / scale);

  /// Max of two sizes operator.
  operator |(SizeC size) =>
      SizeC(max(width, size.width), max(height, size.height));

  /// Adds given [size] to this size and returns the result.
  SizeC add(SizeC size) => SizeC(width + size.width, height + size.height);

  /// Subtracts given [size] from this size and returns the result.
  SizeC subtract(SizeC size) => SizeC(width - size.width, height - size.height);

  /// Subtracts given [x] & [y] from this size and returns the result.
  SizeC subtractVec(double x, double y) => SizeC(width - x, height - y);

  /// Returns scaled up size by given [scale].
  SizeC multiply(double scale) => SizeC(width * scale, height * scale);

  /// Returns scaled down size by given [scale].
  SizeC divide(double scale) => SizeC(width / scale, height / scale);

  @override
  List<Object?> get props => [width, height];

  @override
  String toString() {
    return 'Size{width: $width, height: $height}';
  }

  /// Factory constructor for creating a new [SizeC] instance from JSON data.
  factory SizeC.fromJson(Map json) => _$SizeCFromJson(json);

  @override
  Map toJson() => _$SizeCToJson(this);
}
