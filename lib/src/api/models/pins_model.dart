// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../serializable_mixin.dart';
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

/// Edge pins are the edges of a node that are pinned to it's parent.
///
/// This model is meant to represent the behavior of the [Positioned] widget
/// in Flutter.
///
/// For example, if a node has left edge pin that is not null and set to zero,
/// its left edge will be pinned to its parent's left edge. If the left pin
/// is set to 10px, the node will be 10px away from its parent's left edge.
///
/// If both the left and right pins are set to zero, the node will be pinned
/// to its parent's left and right edges, taking up the entire width of its
/// parent.
///
/// If the left pin is set to null and the right pin is set to some value,
/// the node's relative positioning space will be calculated from its right
/// edge. IE: If the right pin is set to 10px, and the parent grows its width by
/// 100px, the node will MOVE 100px to the right, ALWAYS staying 10px away from
/// its parent's right edge. The node no longer follows its parent's left edge,
/// it follows its parent's right edge.
///
/// You can have a two pins on the same axis be not null, we call this a
/// symmetric chain, where the relevant axis is linked to both pins.
///
/// You CANNOT have two pins on the same axis BOTH be null, as this is a
/// physical impossibility. The left and top pins are ALWAYS not null by default
/// and when they are not null, they are ALWAYS equal to the X and Y values
/// of the node's position. If you change the left/top pins, the X and Y follow,
/// and vice versa; if you change the X or Y, the left/top pins follow. This is
/// of course only true if the left and top pins are NOT null.
///
/// Why is this behavior so weird? Well, in reality it is not, the top and left
/// pins literally define the position of the node. The node's position is very
/// literally computed based on these pins, left and top are simply the default
/// most of the time and never given a thought.
///
/// When computing the global positioning of a node, we always normally sum
/// the left and top corners of the parent-chain recursively to get a global
/// position. This defines the behavior of "left" and "top" pins; they are
/// always relative to the parent's left and top edges.
///
/// When the right and bottom pins are defined, the global positioning of the
/// node is computed based on those pins instead rather than the top and left
/// pins. This defines the behavior of "right" and "bottom" pins; they are
/// always relative to the parent's right and bottom edges.
///
/// The reason this sounds convoluted is because we are used to thinking of
/// relative positioning in terms of the top and left edge, but in reality
/// the top and left edge are just the default. You can set the relativity
/// of a node to any edge, and the node will follow that edge.
///
/// With all of that said, the reason it is physically impossible to have have
/// two pins on the same axis both be null is because then there is no
/// "position" or "positioning" anymore on that axis. If the left and right
/// pins are both null, then the node is not positioned on the X axis at all,
/// the node literally stops having an x axis which is a physical impossibility.
/// At least one pin on a given axis must always be not null for reality to
/// make sense, we don't want to create black holes now, do we?
///
/// In summary, if you want to change the relative positioning of a node, simply
/// change the nullability state of a pin. A null pin means the node is NOT
/// relative to that edge, and a non-null pin means the node IS relative to that
/// edge. A given axis must always have at least one non-null pin.
///
/// A note: If a pin is symmetrically-chained on an axis, it will be as if it's
/// [SizeFit] is set to [SizeFit.expanded], IE: the node will stretch on the
/// axis to occupy the entire space of its parent on that axis, with the value
/// of the pins as another kind of [margin]. It's not real margin from
/// [BaseNode.margin], but it technically the same thing.
///
/// Another note: the pins are all in terms of the [OuterNodeBox],
/// meaning that the edge engulfs the margin and stroke inside of it.
///
/// Please refer to the [OuterNodeBox] documentation for more information.
///
/// Again, also please refer to the [Positioned] widget in Flutter for more
/// information on how this model works. Its behavior is identical.
@JsonSerializable()
class EdgePinsModel with EquatableMixin, SerializableMixin {
  /// The amount of pixels from the left edge of the parent to the left edge
  /// of the node in terms of [OuterNodeBox].
  ///
  /// If NOT null, the node will be pinned to the left edge. If NULL, the node
  /// will NOT be pinned to the left edge.
  ///
  /// This is the default standard that we're used to, If this node is 10 pixels
  /// away from its parent's left edge and:
  ///
  /// - IF the parent grows its width IN THE RIGHT DIRECTION by 100 pixels, the
  ///   node will stay EXACTLY where it is in both the GLOBAL and LOCAL/RELATIVE
  ///   coordinate systems since the left edge of the parent did NOT move.
  ///   The node will be 10 pixels away from the left edge of the parent, and
  ///   none of its global or local boxes are affected.
  ///
  /// - IF the parent grows its width IN THE LEFT DIRECTION by 100 pixels, the
  ///   node will move to the LEFT by 100 pixels IN THE GLOBAL SPACE only, but
  ///   its LOCAL/RELATIVE x-coordinate will remain the same at 10 pixels.
  ///   The node will be 10 pixels away from the left edge of the parent, but
  ///   its global box will be moved to the left by 100 pixels, along with
  ///   any children inside of it.
  final double? left;

  /// The amount of pixels from the top edge of the parent to the top edge
  /// of the node in terms of [OuterNodeBox].
  ///
  /// If NOT null, the node will be pinned to the top edge. If NULL, the node
  /// will NOT be pinned to the top edge.
  ///
  /// This is the default standard that we're used to, if this node is 10 pixels
  /// away from its parent's top edge and:
  ///
  /// - IF the parent grows its height IN THE BOTTOM DIRECTION by 100 pixels,
  ///   the node will stay EXACTLY where it is in both the GLOBAL and
  ///   LOCAL/RELATIVE coordinate systems since the top edge of the parent did
  ///   NOT move. The node will be 10 pixels away from the top edge of the
  ///   parent, and none of its global or local boxes are affected.
  ///
  /// - IF the parent grows its height IN THE TOP DIRECTION by 100 pixels, the
  ///   node will move to the TOP by 100 pixels IN THE GLOBAL SPACE only, but
  ///   its LOCAL/RELATIVE y-coordinate will remain the same at 10 pixels.
  ///   The node will be 10 pixels away from the top edge of the parent, but
  ///   its global box will be moved to the top by 100 pixels, along with
  ///   any children inside of it.
  final double? top;

  /// The amount of pixels from the right edge of the parent to the right edge
  /// of the node in terms of [OuterNodeBox].
  ///
  /// If NOT null, the node will be pinned to the right edge. If NULL, the node
  /// will NOT be pinned to the right edge.
  ///
  /// This is the none-standard behavior that we're not used to, if this node is
  /// 10 pixels away from its parent's right edge and:
  ///
  /// - IF the parent grows its width IN THE RIGHT DIRECTION by 100 pixels, the
  ///   node will move to the RIGHT by 100 pixels IN THE GLOBAL SPACE only, but
  ///   its LOCAL/RELATIVE x-coordinate will remain the same at 10 pixels.
  ///   The node will be 10 pixels away from the right edge of the parent, but
  ///   its global box will be moved to the right by 100 pixels, along with
  ///   any children inside of it.
  ///
  /// - IF the parent grows its width IN THE LEFT DIRECTION by 100 pixels, the
  ///   node will stay EXACTLY where it is in both the GLOBAL and LOCAL/RELATIVE
  ///   coordinate systems since the right edge of the parent did NOT move.
  ///   The node will be 10 pixels away from the right edge of the parent, and
  ///   none of its global or local boxes are affected.
  final double? right;

  /// The amount of pixels from the bottom edge of the parent to the bottom edge
  /// of the node in terms of [OuterNodeBox].
  ///
  /// If NOT null, the node will be pinned to the bottom edge. If NULL, the node
  /// will NOT be pinned to the bottom edge.
  ///
  /// This is the none-standard behavior that we're not used to, if this node is
  /// 10 pixels away from its parent's bottom edge and:
  ///
  /// - IF the parent grows its height IN THE BOTTOM DIRECTION by 100 pixels,
  ///   the node will move to the BOTTOM by 100 pixels IN THE GLOBAL SPACE only,
  ///   but its LOCAL/RELATIVE y-coordinate will remain the same at 10 pixels.
  ///   The node will be 10 pixels away from the bottom edge of the parent, but
  ///   its global box will be moved to the bottom by 100 pixels, along with
  ///   any children inside of it.
  ///
  /// - IF the parent grows its height IN THE TOP DIRECTION by 100 pixels, the
  ///   node will stay EXACTLY where it is in both the GLOBAL and LOCAL/RELATIVE
  ///   coordinate systems since the bottom edge of the parent did NOT move.
  ///   The node will be 10 pixels away from the bottom edge of the parent, and
  ///   none of its global or local boxes are affected.
  final double? bottom;

  /// Creates a new [EdgePinsModel] with the given [left], [top], [right], and
  /// [bottom] pins.
  const EdgePinsModel({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  /// Creates a standard [EdgePinsModel] that defines the left and top corners
  /// as non-null zero values (so the top left corner of this node is pinned to
  /// the top left corner of the parent), while the right and bottom pins are
  /// null.
  static const EdgePinsModel standard =
      EdgePinsModel(left: 0, top: 0, right: null, bottom: null);

  /// Standard is defined by the standard we are used to where the
  /// local/relative coordinate system is defined by the top and left pins.
  ///
  /// When a node has non-null pins on the top and left pins and null pins on
  /// the right and bottom pins, it is considered to be in standard.
  bool get isStandard =>
      left != null && top != null && right == null && bottom == null;

  /// [returns] True if non of the pins are null, IE: the node is double-chained
  /// on both axes.
  bool get isDoubleChained => isHorizontalChained && isVerticalChained;

  /// [returns] True if the node is symmetrically-chained on the horizontal
  /// axis, IE: the left and right pins are not null.
  bool get isHorizontalChained => left != null && right != null;

  /// [returns] True if the node is symmetrically-chained on the vertical
  /// axis, IE: the top and bottom pins are not null.
  bool get isVerticalChained => top != null && bottom != null;

  /// Due to the null-pattern of the pins, we can't use the default copyWith
  /// modal, so we have to define a copyWith for each pin separately.
  ///
  /// [returns] A new [EdgePinsModel] with the given [left] pin.
  /// If [value] is left null, the [left] pin will be set to null.
  EdgePinsModel copyWithLeft(double? value) =>
      EdgePinsModel(left: value, top: top, right: right, bottom: bottom);

  /// Due to the null-pattern of the pins, we can't use the default copyWith
  /// modal, so we have to define a copyWith for each pin separately.
  ///
  /// [returns] A new [EdgePinsModel] with the given [top] pin.
  /// If [value] is left null, the [top] pin will be set to null.
  EdgePinsModel copyWithTop(double? value) =>
      EdgePinsModel(left: left, top: value, right: right, bottom: bottom);

  /// Due to the null-pattern of the pins, we can't use the default copyWith
  /// modal, so we have to define a copyWith for each pin separately.
  ///
  /// [returns] A new [EdgePinsModel] with the given [right] pin.
  /// If [value] is left null, the [right] pin will be set to null.
  EdgePinsModel copyWithRight(double? value) =>
      EdgePinsModel(left: left, top: top, right: value, bottom: bottom);

  /// Due to the null-pattern of the pins, we can't use the default copyWith
  /// modal, so we have to define a copyWith for each pin separately.
  ///
  /// [returns] A new [EdgePinsModel] with the given [bottom] pin.
  /// If [value] is left null, the [bottom] pin will be set to null.
  EdgePinsModel copyWithBottom(double? value) =>
      EdgePinsModel(left: left, top: top, right: right, bottom: value);

  /// Due to the null-pattern of the pins, we can't use the default copyWith
  /// modal, so we have to define a copyWith for each pin separately.
  ///
  /// This is a null-friendly generalized version of the copyWith functions in
  /// this class.
  ///
  /// Requires a [pin] to be defined, along with the [value] it should be set
  /// to, null or otherwise.
  /// This function calls the copy with functions for each pin, and returns
  /// the result.
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

  /// [returns] whether a given [pin] is null or not.
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

  /// [returns] whether this instance of [EdgePinsModel] contains symmetric
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

  /// Creates a new instance of [EdgePinsModel] from a [json] map.
  @override
  factory EdgePinsModel.fromJson(Map<String, dynamic> json) =>
      _$EdgePinsModelFromJson(json);
}
