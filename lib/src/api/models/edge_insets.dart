// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../extensions.dart';
import '../mixins.dart';
import 'models.dart';

part 'edge_insets.g.dart';

/// Direction for the edge insets.
enum EdgeInsetsDirection {
  /// All directions.
  all,

  /// Left.
  L,

  /// Top.
  T,

  /// Right.
  R,

  /// Bottom.
  B,
}

/// Holds edge insets data for margin/padding.
@JsonSerializable(useDynamics: true)
class EdgeInsetsModel with EquatableMixin, DynamicSerializableMixin {
  /// Left spacing.
  final double l;

  /// Top spacing.
  final double t;

  /// Right spacing.
  final double r;

  /// Bottom spacing.
  final double b;

  /// Total spacing horizontally.
  double get horizontal => l + r;

  /// Total spacing vertically.
  double get vertical => t + b;

  /// Creates a new instance of [EdgeInsetsModel] with given data.
  const EdgeInsetsModel({this.l = 0, this.t = 0, this.r = 0, this.b = 0})
      : assert(l >= 0 && t >= 0 && r >= 0 && b >= 0, 'All values must be >= 0');

  /// Creates [EdgeInsetsModel] by taking all directional values.
  const EdgeInsetsModel.fromLTRB(this.l, this.t, this.r, this.b)
      : assert(l >= 0 && t >= 0 && r >= 0 && b >= 0, 'All values must be >= 0');

  /// Creates [EdgeInsetsModel] by taking any of the directional values.
  const EdgeInsetsModel.only(
      {double left = 0, double top = 0, double right = 0, double bottom = 0})
      : l = left,
        t = top,
        r = right,
        b = bottom,
        assert(left >= 0 && top >= 0 && right >= 0 && bottom >= 0,
            'All values must be >= 0');

  /// Creates [EdgeInsetsModel] with all directions set to the same value.
  const EdgeInsetsModel.all(double value)
      : l = value,
        t = value,
        r = value,
        b = value,
        assert(value >= 0, 'Value must be >= 0');

  /// Creates [EdgeInsetsModel] with parallel directions set to the same value.
  const EdgeInsetsModel.symmetric({double horizontal = 0, double vertical = 0})
      : l = horizontal,
        t = vertical,
        r = horizontal,
        b = vertical,
        assert(horizontal >= 0 && vertical >= 0, 'All values must be >= 0');

  /// Represents zero edge insets.
  static const EdgeInsetsModel zero = EdgeInsetsModel();

  /// Adds given [value] edge insets to this and returns the result.
  EdgeInsetsModel add(EdgeInsetsModel value) => EdgeInsetsModel(
        l: l + value.l,
        t: t + value.t,
        r: r + value.r,
        b: b + value.b,
      );

  /// Maxes this edge insets with given [value] and returns the result.
  EdgeInsetsModel max(EdgeInsetsModel value) => EdgeInsetsModel(
        l: l > value.l ? l : value.l,
        t: t > value.t ? t : value.t,
        r: r > value.r ? r : value.r,
        b: b > value.b ? b : value.b,
      );

  /// Returns true if the [other] model has any side that is larger than
  /// this model's respective side.
  bool hasSmallerSideThan(EdgeInsetsModel value) =>
      l < value.l || t < value.t || r < value.r || b < value.b;

  /// Returns true if the [other] model has any side that is smaller than
  /// this model's respective side.
  bool hasLargerSideThan(EdgeInsetsModel value) =>
      l > value.l || t > value.t || r > value.r || b > value.b;

  /// Adds given [value] edge insets to this and returns the result.
  operator +(EdgeInsetsModel value) => add(value);

  /// Duplicates this instance with given [axis] values intact but resetting
  /// other values to zero.
  EdgeInsetsModel onlyAxis(AxisC axis) => EdgeInsetsModel(
        l: axis == AxisC.horizontal ? l : 0,
        t: axis == AxisC.vertical ? t : 0,
        r: axis == AxisC.horizontal ? r : 0,
        b: axis == AxisC.vertical ? b : 0,
      );

  /// Duplicates this instance with given [direction] values intact but
  /// resetting other values to zero.
  EdgeInsetsModel only(EdgeInsetsDirection direction) {
    switch (direction) {
      case EdgeInsetsDirection.all:
        return this;
      case EdgeInsetsDirection.L:
        return EdgeInsetsModel(l: l);
      case EdgeInsetsDirection.T:
        return EdgeInsetsModel(t: t);
      case EdgeInsetsDirection.R:
        return EdgeInsetsModel(r: r);
      case EdgeInsetsDirection.B:
        return EdgeInsetsModel(b: b);
    }
  }

  /// Resolves edge insets based on given text direction.
  EdgeInsetsModel resolve(CTextDirection? direction) {
    assert(direction != null);
    switch (direction!) {
      case CTextDirection.rtl:
        return EdgeInsetsModel(l: r, t: t, r: l, b: b);
      case CTextDirection.ltr:
        return EdgeInsetsModel(l: l, t: t, r: r, b: b);
    }
  }

  /// Duplicates this instance of [EdgeInsetsModel] with given data overrides.
  EdgeInsetsModel copyWith({
    double? l,
    double? t,
    double? r,
    double? b,
  }) =>
      EdgeInsetsModel(
        l: l ?? this.l,
        t: t ?? this.t,
        r: r ?? this.r,
        b: b ?? this.b,
      );

  @override
  String toString() => 'EdgeInsets(l: $l, t: $t, r: $r, b: $b)';

  @override
  List<Object> get props => [l, t, r, b];

  /// Factory constructor for creating a new [EdgeInsetsModel] instance
  /// from JSON data.
  factory EdgeInsetsModel.fromJson(dynamic json) {
    return switch (json) {
      [num all] => EdgeInsetsModel.all(all.toDouble()),
      [num horizontal, num vertical] => EdgeInsetsModel.symmetric(
          horizontal: horizontal.toDouble(),
          vertical: vertical.toDouble(),
        ),
      [num left, num top, num right, num bottom] => EdgeInsetsModel.only(
          left: left.toDouble(),
          top: top.toDouble(),
          right: right.toDouble(),
          bottom: bottom.toDouble(),
        ),
      _ => _$EdgeInsetsModelFromJson(json),
    };
  }

  @override
  dynamic toJson() {
    if (l == t && t == r && r == b) return l.toPrettyPrecision(3);
    if (l == r && t == b) {
      return [
        l.toPrettyPrecision(3),
        t.toPrettyPrecision(3),
      ];
    }
    return [
      l.toPrettyPrecision(3),
      t.toPrettyPrecision(3),
      r.toPrettyPrecision(3),
      b.toPrettyPrecision(3)
    ];
  }
}
