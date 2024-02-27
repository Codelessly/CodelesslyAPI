// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../codelessly_api.dart';

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
  EdgePin get opposite => switch (this) {
        EdgePin.left => EdgePin.right,
        EdgePin.top => EdgePin.bottom,
        EdgePin.right => EdgePin.left,
        EdgePin.bottom => EdgePin.top
      };

  /// Converts edge pin to [AxisC].
  AxisC get axis => switch (this) {
        EdgePin.left => AxisC.horizontal,
        EdgePin.right => AxisC.horizontal,
        EdgePin.top => AxisC.vertical,
        EdgePin.bottom => AxisC.vertical,
      };

  /// Converts edge pin to [AlignmentModel].
  AlignmentModel get alignment => switch (this) {
        EdgePin.left => AlignmentModel.centerLeft,
        EdgePin.top => AlignmentModel.topCenter,
        EdgePin.right => AlignmentModel.centerRight,
        EdgePin.bottom => AlignmentModel.bottomCenter,
      };
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

  /// Creates an invalid [EdgePinsModel] that has no non-null pins.
  /// An invalid pins model is one which has no pin on a given axis.
  static const EdgePinsModel invalid =
      EdgePinsModel(left: null, top: null, right: null, bottom: null);

  /// Creates an [EdgePinsModel] that fills the parent's entire space.
  static const EdgePinsModel fill =
      EdgePinsModel(left: 0, top: 0, right: 0, bottom: 0);

  /// Whether this [EdgePinsModel] follows the standard convention of pinning
  /// the node to parent's top-left corner.
  bool get isStandard =>
      left != null && top != null && right == null && bottom == null;

  /// Whether this [EdgePinsModel] has an invalid axis horizontally. An invalid
  /// pins model is one which has no pin on a given axis.
  bool get isInvalidHorizontally => left == null && right == null;

  /// Whether this [EdgePinsModel] has an invalid axis vertically. An invalid
  /// pins model is one which has no pin on a given axis.
  bool get isInvalidVertically => top == null && bottom == null;

  /// Whether this [EdgePinsModel] has any negative pins.
  bool get anyNegativePins =>
      (left != null && left! < 0) ||
      (top != null && top! < 0) ||
      (right != null && right! < 0) ||
      (bottom != null && bottom! < 0);

  /// Whether this [EdgePinsModel] is invalid on at least one axis.
  /// An invalid pins model is one which has no pin on a given axis.
  bool get isOneAxisInvalid => isInvalidHorizontally || isInvalidVertically;

  /// Whether this [EdgePinsModel] is invalid on both axes.
  /// An invalid pins model is one which has no pin on a given axis.
  bool get areBothAxesInvalid => isInvalidHorizontally && isInvalidVertically;

  /// Whether the node is symmetric-chained on both axes, i.e., none of the pins
  /// are null.
  bool get isBothExpanded => isHorizontallyExpanded && isVerticallyExpanded;

  /// Whether the node is symmetric-chained on at least one axis, i.e., at least
  /// one of the pins is not null.
  bool get isOneOrBothExpanded =>
      isHorizontallyExpanded || isVerticallyExpanded;

  /// Whether the node is symmetric-chained on the horizontal axis, i.e., left
  /// and right pins are not null.
  bool get isHorizontallyExpanded => left != null && right != null;

  /// Whether the node is symmetric-chained on the vertical axis, i.e., top and
  /// bottom pins are not null.
  bool get isVerticallyExpanded => top != null && bottom != null;

  /// Returns the sum of the horizontal pins.
  double sumHorizontalPins() => (left ?? 0) + (right ?? 0);

  /// Returns the sum of the vertical pins.
  double sumVerticalPins() => (top ?? 0) + (bottom ?? 0);

  /// Returns the sum of the pins on the given [axis].
  double sumPinsOnAxis(AxisC axis) => switch (axis) {
        AxisC.horizontal => sumHorizontalPins(),
        AxisC.vertical => sumVerticalPins(),
      };

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
  EdgePinsModel copyWithPin(EdgePin pin, double? value) => switch (pin) {
        EdgePin.left => copyWithLeft(value),
        EdgePin.top => copyWithTop(value),
        EdgePin.right => copyWithRight(value),
        EdgePin.bottom => copyWithBottom(value)
      };

  /// Returns a new [EdgePinsModel] with all negative pins clamped to zero.
  EdgePinsModel copyWithNoNegativePins() {
    double? newLeft = left;
    double? newTop = top;
    double? newRight = right;
    double? newBottom = bottom;

    if (newLeft != null && newLeft < 0) {
      newLeft = 0;
    }
    if (newTop != null && newTop < 0) {
      newTop = 0;
    }
    if (newRight != null && newRight < 0) {
      newRight = 0;
    }
    if (newBottom != null && newBottom < 0) {
      newBottom = 0;
    }

    return EdgePinsModel(
      left: newLeft,
      top: newTop,
      right: newRight,
      bottom: newBottom,
    );
  }

  /// Get a pin from this instance of [EdgePinsModel], given a [pin] enum.
  ///
  /// This is useful for abstraction and polymorphic behavior.
  double? getPin(EdgePin pin) => switch (pin) {
        EdgePin.left => left,
        EdgePin.top => top,
        EdgePin.right => right,
        EdgePin.bottom => bottom
      };

  /// Whether the given [pin] is null or not.
  bool containsPin(EdgePin pin) => switch (pin) {
        EdgePin.left => left != null,
        EdgePin.top => top != null,
        EdgePin.right => right != null,
        EdgePin.bottom => bottom != null
      };

  /// Whether this [EdgePinsModel] contains any of the given [pins].
  bool containsAnyPin(Iterable<EdgePin> pins) => pins.any(containsPin);

  /// Whether this [EdgePinsModel] contains all of the given [pins].
  bool containsEveryPin(Iterable<EdgePin> pins) => pins.every(containsPin);

  /// Whether this instance of [EdgePinsModel] contains symmetric
  /// chains on the given [axis]. IE: If both pins on the given [axis] are
  /// set to non-null values.
  bool expandedOnAxis(AxisC axis) => switch (axis) {
        AxisC.horizontal => isHorizontallyExpanded,
        AxisC.vertical => isVerticallyExpanded
      };

  /// [returns] a set of pins that are enabled on this instance of
  /// [EdgePinsModel]. An enabled pin is one that has a non-null value.
  Set<EdgePin> get enabledPins => {
        if (left != null) EdgePin.left,
        if (top != null) EdgePin.top,
        if (right != null) EdgePin.right,
        if (bottom != null) EdgePin.bottom,
      };

  @override
  List<Object?> get props => [left, top, right, bottom];

  @override
  Map toJson() => {
        if (left != null) 'left': left?.toPrettyPrecision(3),
        if (top != null) 'top': top?.toPrettyPrecision(3),
        if (right != null) 'right': right?.toPrettyPrecision(3),
        if (bottom != null) 'bottom': bottom?.toPrettyPrecision(3),
      };

  /// Creates a new instance of [EdgePinsModel] from a JSON map.
  @override
  factory EdgePinsModel.fromJson(Map<String, dynamic> json) =>
      _$EdgePinsModelFromJson(json);
}
