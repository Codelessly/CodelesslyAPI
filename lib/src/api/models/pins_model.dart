// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'pins_model.g.dart';

/// Represents the edges of a default 4-vertex object or a quad. (4 sides)
enum EdgePin {
  /// Pin on left edge.
  left,

  /// Pin on top edge.
  top,

  /// Pin on right edge.
  right,

  /// Pin on bottom edge.
  bottom;

  /// Returns opposite side edge pin of this edge pin.
  EdgePin opposite() {
    switch (this) {
      case EdgePin.left:
        return EdgePin.right;
      case EdgePin.top:
        return EdgePin.bottom;
      case EdgePin.right:
        return EdgePin.left;
      case EdgePin.bottom:
        return EdgePin.top;
    }
  }

  /// Converts edge pin to [AxisC].
  AxisC axis() {
    switch (this) {
      case EdgePin.left:
      case EdgePin.right:
        return AxisC.horizontal;
      case EdgePin.top:
      case EdgePin.bottom:
        return AxisC.vertical;
    }
  }

  /// Converts edge pin to [AlignmentModel].
  AlignmentModel alignment() {
    switch (this) {
      case EdgePin.left:
        return AlignmentModel.centerLeft;
      case EdgePin.top:
        return AlignmentModel.topCenter;
      case EdgePin.right:
        return AlignmentModel.centerRight;
      case EdgePin.bottom:
        return AlignmentModel.bottomCenter;
    }
  }
}

/// Edge pins are the edges of a node that are pinned to its parent. Edges refer
/// to the [OuterNodeBox]'s edges.
///
/// For example, if [left] set to zero, the node's left edge will be pinned to
/// its parent's left edge and if [left] is set to 10, the node will be 10px
/// away from its parent's left edge.
///
/// Similarly, if the node has [bottom] set to 50, the node will be pinned to
/// its parent's bottom edge at a distance of 50px.
///
/// If two opposite edge pins on an axis are set to be non-null, the node is
/// pinned to both the edges and stretches to take up the entire space of its
/// parent on that axis.
///
/// Setting two opposite edge pins to null is invalid because it breaks the
/// node's positioning in that axis. Both axes should have at least one non-null
/// edge pin for positioning to work.
///
/// By default, left and top pins are non-null and correspond to the X and Y
/// values of node's position. If left or top pins' values are changed, X or Y
/// change accordingly.
///
/// [EdgePinsModel] replicates the behavior of Flutter's [Positioned] widget.
@JsonSerializable()
class EdgePinsModel with EquatableMixin, SerializableMixin {
  /// Distance between node's left edge and its parent's left edge. Setting a
  /// non-null value pins the node to the left edge of its parent.
  final double? left;

  /// Distance between node's top edge and its parent's top edge. Setting a
  /// non-null value pins the node to the top edge of its parent.
  final double? top;

  /// Distance between node's right edge and its parent's right edge. Setting a
  /// non-null value pins the node to the right edge of its parent.
  final double? right;

  /// Distance between node's bottom edge and its parent's bottom edge. Setting a
  /// non-null value pins the node to the bottom edge of its parent.
  final double? bottom;

  /// Creates a new [EdgePinsModel] with the given [left], [top], [right], and
  /// [bottom] pins.
  const EdgePinsModel({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  /// Creates a standard [EdgePinsModel] that pins the node to the parent's
  /// top-left corner.
  static const EdgePinsModel standard =
      EdgePinsModel(left: 0, top: 0, right: null, bottom: null);

  /// Whether this [EdgePinsModel] follows the standard convention of pinning
  /// the node to parent's top-left corner.
  bool get isStandard =>
      left != null && top != null && right == null && bottom == null;

  /// Whether the node is symmetric-chained on both axes, i.e., none of the pins
  /// is null.
  bool get isDoubleChained => isHorizontalChained && isVerticalChained;

  /// Whether the node is symmetric-chained on the horizontal axis, i.e., left
  /// and right pins are not null.
  bool get isHorizontalChained => left != null && right != null;

  /// Whether the node is symmetric-chained on the vertical axis, i.e., top and
  /// bottom pins are not null.
  bool get isVerticalChained => top != null && bottom != null;

  /// Due to the null-pattern of the pins, default copyWith method does not
  /// work. So, there's a separate copyWith method for each pin.
  ///
  /// Returns A new [EdgePinsModel] with the given [left] pin.
  /// If [value] is left null, the [left] pin will be set to null.
  EdgePinsModel copyWithLeft(double? value) =>
      EdgePinsModel(left: value, top: top, right: right, bottom: bottom);

  /// Due to the null-pattern of the pins, default copyWith method does not
  /// work. So, there's a separate copyWith method for each pin.
  ///
  /// Returns A new [EdgePinsModel] with the given [top] pin.
  /// If [value] is left null, the [top] pin will be set to null.
  EdgePinsModel copyWithTop(double? value) =>
      EdgePinsModel(left: left, top: value, right: right, bottom: bottom);

  /// Due to the null-pattern of the pins, default copyWith method does not
  /// work. So, there's a separate copyWith method for each pin.
  ///
  /// Returns A new [EdgePinsModel] with the given [right] pin.
  /// If [value] is left null, the [right] pin will be set to null.
  EdgePinsModel copyWithRight(double? value) =>
      EdgePinsModel(left: left, top: top, right: value, bottom: bottom);

  /// Due to the null-pattern of the pins, default copyWith method does not
  /// work. So, there's a separate copyWith method for each pin.
  ///
  /// Returns A new [EdgePinsModel] with the given [bottom] pin.
  /// If [value] is left null, the [bottom] pin will be set to null.
  EdgePinsModel copyWithBottom(double? value) =>
      EdgePinsModel(left: left, top: top, right: right, bottom: value);

  /// Due to the null-pattern of the pins, default copyWith method does not
  /// work. So, there's a separate copyWith method for each pin.
  ///
  /// This is a null-friendly wrapper around the copyWith functions in this
  /// class.
  ///
  /// Takes a [pin] and a [value] and returns the new [EdgePinesModel].
  EdgePinsModel copyWithPin(EdgePin pin, double? value) {
    switch (pin) {
      case EdgePin.left:
        return copyWithLeft(value);
      case EdgePin.top:
        return copyWithTop(value);
      case EdgePin.right:
        return copyWithRight(value);
      case EdgePin.bottom:
        return copyWithBottom(value);
    }
  }

  /// Get a pin from this instance of [EdgePinsModel], given a [pin] enum.
  ///
  /// This is useful for abstraction and polymorphic behavior.
  double? getPin(EdgePin pin) {
    switch (pin) {
      case EdgePin.left:
        return left;
      case EdgePin.top:
        return top;
      case EdgePin.right:
        return right;
      case EdgePin.bottom:
        return bottom;
    }
  }

  /// Whether the given [pin] is null or not.
  bool containsPin(EdgePin? pin) {
    if (pin == null) return false;
    switch (pin) {
      case EdgePin.left:
        return left != null;
      case EdgePin.top:
        return top != null;
      case EdgePin.right:
        return right != null;
      case EdgePin.bottom:
        return bottom != null;
    }
  }

  /// Whether this instance of [EdgePinsModel] contains symmetric
  /// chains on the given [axis]. IE: If both pins on the given [axis] are
  /// set to non-null values.
  bool chainedOnAxis(AxisC axis) {
    switch (axis) {
      case AxisC.horizontal:
        return isHorizontalChained;
      case AxisC.vertical:
        return isVerticalChained;
    }
  }

  @override
  List<Object?> get props => [left, top, right, bottom];

  @override
  Map toJson() => _$EdgePinsModelToJson(this);

  /// Creates a new instance of [EdgePinsModel] from a JSON map.
  @override
  factory EdgePinsModel.fromJson(Map<String, dynamic> json) =>
      _$EdgePinsModelFromJson(json);
}
