// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'dart:math';

import 'package:equatable/equatable.dart';

import '../serializable_mixin.dart';
import 'models.dart';

/// The [NodeBox] class is a utility class that represents a rectangle with a
/// position and a size.
///
/// It's purpose is to provide pre-computed values for various properties of the
/// rectangle such as its edges, centers, and aspect ratio.
///
/// The class has several fields that store these pre-computed values, such as
/// [left], [top], [right], [bottom], [centerX], [centerY], [center], [topLeft],
/// [topRight], [bottomLeft], [bottomRight], [leftCenter], [topCenter],
/// [bottomCenter], [rightCenter], [size], [rect], and [aspectRatio].
///
/// These values are computed using the passed in values of the rectangle's
/// position and size in the constructor, and can be accessed directly without
/// the need for additional calculations.
///
/// Additionally, the class provides several methods such as copyWith, fromJson,
/// and toJson which allow for easy manipulation and serialization of the
/// rectangle.
class NodeBox with EquatableMixin, SerializableMixin {
  /// The arbitrary x-coordinate of the rectangle's left corner.
  /// The position in space depends on the creator of this class.
  ///
  /// This does NOT define whether this is in global or local space, nor does
  /// it define whether this is the left corner from the margin box or
  /// the middle box or the padded box. It's arbitrary and depends on the actual
  /// creator of this class.
  late final double x;

  /// The arbitrary y-coordinate of the rectangle's top corner.
  /// The position in space depends on the creator of this class.
  ///
  /// This does NOT define whether this is in global or local space, nor does
  /// it define whether this is the top corner from the margin box or
  /// the middle box or the padded box. It's arbitrary and depends on the actual
  /// creator of this class.
  late final double y;

  /// The width is the distance between the left and right edges of the
  /// rectangle. It is always non-negative.
  ///
  /// This does NOT define whether this is the entire width of the margin box
  /// or the middle box or the padded box. It's arbitrary and depends on the
  /// actual creator of this class.
  late final double width;

  /// The height is the distance between the top and bottom edges of the
  /// rectangle. It is always non-negative.
  ///
  /// This does NOT define whether this is the entire height of the margin box
  /// or the middle box or the padded box. It's arbitrary and depends on the
  /// actual creator of this class.
  late final double height;

  /// The left edge of the rectangle. This is the same as the [x] value.
  late final double left;

  /// The top edge of the rectangle. This is the same as the [y] value.
  late final double top;

  /// The right edge of the rectangle. This is the same as the [x] value
  /// plus the [width] value.
  late final double right;

  /// The bottom edge of the rectangle. This is the same as the [y] value
  /// plus the [height] value.
  late final double bottom;

  /// The horizontal midpoint of the rectangle. This is the same as the [x]
  /// value plus half the [width] value.
  late final double centerX;

  /// The vertical midpoint of the rectangle. This is the same as the [y]
  /// value plus half the [height] value.
  late final double centerY;

  /// The point halfway between the left and right and the top and bottom edges
  /// of the rectangle. This is the same as the [centerX] and [centerY] values.
  late final Vec center;

  /// The point at the top left corner of the rectangle. This is the same as
  /// the [left] and [top] values.
  late final Vec topLeft;

  /// The point at the top right corner of the rectangle. This is the same as
  /// the [right] and [top] values.
  late final Vec topRight;

  /// The point at the bottom left corner of the rectangle. This is the same as
  /// the [left] and [bottom] values.
  late final Vec bottomLeft;

  /// The point at the bottom right corner of the rectangle. This is the same as
  /// the [right] and [bottom] values.
  late final Vec bottomRight;

  /// The point at the left edge and vertical center of the rectangle.
  /// This is the same as the [left] and [centerY] values.
  late final Vec leftCenter;

  /// The point at the top edge and horizontal center of the rectangle.
  /// This is the same as the [centerX] and [top] values.
  late final Vec topCenter;

  /// The point at the bottom edge and horizontal center of the rectangle.
  /// This is the same as the [centerX] and [bottom] values.
  late final Vec bottomCenter;

  /// The point at the right edge and vertical center of the rectangle.
  /// This is the same as the [right] and [centerY] values.
  late final Vec rightCenter;

  /// The size of the rectangle. This is the same as the [width] and [height]
  /// values.
  late final SizeC size;

  /// The rectangle represented by this class.
  late final RectC rect;

  /// The aspect ratio of the rectangle. This is the same as the [width] divided
  /// by the [height].
  late final double aspectRatio;

  /// The constructor for the [NodeBox] class. It takes in the [x], [y],
  /// [width], and [height] values of the rectangle and computes all of the
  /// fields immediately.
  NodeBox(this.x, this.y, double width, double height) {
    assert(x.isFinite, 'x is not finite. Value: $x');
    assert(y.isFinite, 'y is not finite. Value: $y');
    assert(width.isFinite, 'width is not finite. Value: $width');
    assert(height.isFinite, 'height is not finite. Value: $height');

    this.width = max(0, width);
    this.height = max(0, height);
    left = x;
    top = y;
    right = left + width;
    bottom = top + height;

    centerX = left + width / 2;
    centerY = top + height / 2;

    topLeft = Vec(left, top);
    topRight = Vec(right, top);
    bottomLeft = Vec(left, bottom);
    bottomRight = Vec(right, bottom);

    leftCenter = Vec(left, centerY);
    rightCenter = Vec(right, centerY);
    bottomCenter = Vec(centerX, bottom);
    topCenter = Vec(centerX, top);
    center = Vec(centerX, centerY);

    size = SizeC(width, height);
    rect = RectC.fromLTWH(left, top, width, height);
    aspectRatio = width / height;
  }

  /// Creates a new [NodeBox] from a [RectC] object.
  NodeBox.fromRect(RectC rect)
      : this(rect.left, rect.top, rect.width, rect.height);

  /// Creates a new [NodeBox] using the current values of this [NodeBox], and
  /// optionally allows different values. The new [NodeBox] immediately
  /// pre-computes its values.
  NodeBox copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
  }) =>
      NodeBox(
        x ?? this.x,
        y ?? this.y,
        width ?? this.width,
        height ?? this.height,
      );

  /// Creates a new [NodeBox] from a [json] Map.
  factory NodeBox.fromJson(Map json) => NodeBox(
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
        (json['width'] as num).toDouble(),
        (json['height'] as num).toDouble(),
      );

  @override
  Map toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };

  @override
  String toString() {
    return 'NodeBox{x: $x, y: $y, width: $width, height: $height}';
  }

  @override
  List<Object?> get props => [x, y, width, height];
}

/// The [OuterNodeBox] is a [NodeBox] with additional fields that define the
/// outer padded space of the rectangle. This is useful for defining a rectangle
/// that has a margin and/or stroke.
///
/// You can think of this as the green overlay that renders around the
/// selection box of the node in the editor when margin is applied.
/// Alternatively, you can also think of this as wrapping a Flutter [Widget]
/// with a [Padding] widget, applying a safe-zone around your widget. The
/// [Padding] widget has a misleading name, however. A better-named
/// representation of this would be the [Container.margin] field inside
/// [Container] widgets.
///
/// In this type of [NodeBox], the [left], [top], [right], and [bottom] values
/// are the outer (green area) edges of the rectangle. The [width] and [height]
/// values define the distance between the outer edges. So the outer-most green
/// pixels from one end to the other.
///
/// The [centerX], [centerY], and [center] values are the center of the outer
/// edges, and these are NOT the same as the normal middle-box's center because
/// you might have asymmetrical margins applied to your rectangle.
class OuterNodeBox extends NodeBox {
  /// The distance between the bottom edge of the marginal space and the bottom
  /// edge of the base rectangle.
  ///
  /// This value is always non-negative as it is a DISTANCE and NOT a
  /// coordinate.
  ///
  /// This field is specifically the size of the bottom half of that green
  /// area.
  late final double edgeLeft;

  /// The distance between the top edge of the marginal space and the top edge
  /// of the base rectangle.
  ///
  /// This value is always non-negative as it is a DISTANCE and NOT a
  /// coordinate.
  ///
  /// This field is specifically the size of the top half of that green
  /// area.
  late final double edgeTop;

  /// The distance between the right edge of the marginal space and the right
  /// edge of the base rectangle.
  ///
  /// This value is always non-negative as it is a DISTANCE and NOT a
  /// coordinate.
  ///
  /// This field is specifically the size of the right half of that green
  /// area.
  late final double edgeRight;

  /// The distance between the bottom edge of the marginal space and the bottom
  /// edge of the base rectangle.
  ///
  /// This value is always non-negative as it is a DISTANCE and NOT a
  /// coordinate.
  ///
  /// This field is specifically the size of the bottom half of that green
  /// area.
  late final double edgeBottom;

  /// The bottom right point of the marginal space, IE: the bottom
  /// right point of the green area. It's the same as [edgeBottom] and
  /// [edgeRight].
  late final Vec edgeBottomRight;

  /// The top left point of the marginal space, IE: the top
  /// left point of the green area. It's the same as [edgeTop] and [edgeLeft].
  late final Vec edgeTopLeft;

  /// The total horizontal marginal space. This is the sum of [edgeLeft] and
  /// [edgeRight], giving you the total width of the marginal space.
  late final double horizontalEdgeSpace;

  /// The total vertical marginal space. This is the sum of [edgeTop] and
  /// [edgeBottom], giving you the total height of the marginal space.
  late final double verticalEdgeSpace;

  /// A convenience field that is the same as [horizontalEdgeSpace] and
  /// [verticalEdgeSpace].
  late final SizeC edgeSize;

  /// The x-coordinate to the left edge of the INSIDE of the marginal space, IE:
  /// the left edge of the base rectangle.
  ///
  /// If you're looking for the left edge of the marginal space, use [x] or
  /// [left] directly since this [OuterNodeBox] tailors to the marginal space
  /// and provides precomputed fields about the base rectangle for convenience.
  late final double innerLeft;

  /// The y-coordinate to the top edge of the INSIDE of the marginal space, IE:
  /// the top edge of the base rectangle.
  ///
  /// If you're looking for the top edge of the marginal space, use [y] or [top]
  /// directly since this [OuterNodeBox] tailors to the marginal space and
  /// provides precomputed fields about the base rectangle for convenience.
  late final double innerTop;

  /// The y-coordinate to the bottom edge of the INSIDE of the marginal space,
  /// IE: the bottom edge of the base rectangle.
  ///
  /// If you're looking for the bottom edge of the marginal space, use [y] or
  /// [bottom] directly since this [OuterNodeBox] tailors to the marginal space
  /// and provides precomputed fields about the base rectangle for convenience.
  late final double innerBottom;

  /// The x-coordinate to the right edge of the INSIDE of the marginal space,
  /// IE: the right edge of the base rectangle.
  ///
  /// If you're looking for the right edge of the marginal space, use [x] or
  /// [right] directly since this [OuterNodeBox] tailors to the marginal space
  /// and provides precomputed fields about the base rectangle for convenience.
  late final double innerRight;

  /// Is the top left point of the base rectangle, IE: the top left point of the
  /// selection box. It's the same as [innerTop] and [innerLeft].
  late final Vec innerTopLeft;

  /// Is the bottom right point of the base rectangle, IE: the bottom right
  /// point of the selection box. It's the same as [innerBottom] and
  /// [innerRight].
  late final Vec innerBottomRight;

  /// The combined edge insets that make up the marginal space. You would
  /// normally assume this is the simple margin of the box, but this can be
  /// more complex if the box has strokes or some other type of margin on top
  /// of the normal one.
  late final EdgeInsetsModel edgeInsets;

  /// The inner rectangle represents the base rectangle, IE: the selection box
  /// in the editor. This is the same as [innerTopLeft] and [innerBottomRight].
  late final RectC innerRect;

  /// The width of the base rectangle, IE: the selection box in the editor.
  /// This is the same as [innerRect.width].
  late final double innerWidth;

  /// The height of the base rectangle, IE: the selection box in the editor.
  /// This is the same as [innerRect.height].
  late final double innerHeight;

  /// The size of the base rectangle, IE: the selection box in the editor.
  /// This is the same as [innerRect.size].
  late final SizeC innerSize;

  /// The inner center X is the center of the base rectangle, IE: the center of
  /// the selection box in the editor. This is the same as [innerRect.centerX].
  late final double innerCenterX;

  /// The inner center Y is the center of the base rectangle, IE: the center of
  /// the selection box in the editor. This is the same as [innerRect.centerY].
  late final double innerCenterY;

  /// The center of the base rectangle, IE: the center of the selection box in
  /// the editor. This is the same as [innerRect.center].
  late final Vec innerCenter;

  /// The constructor for the [OuterNodeBox] class. This is the same as
  /// [NodeBox] except it also takes in an [edgeInsets] that represents the
  /// combined marginal space of the box.
  OuterNodeBox(
    super.x,
    super.y,
    super.width,
    super.height, {
    required this.edgeInsets,
  }) {
    assert(x.isFinite, 'x is not finite. Value: $x');
    assert(y.isFinite, 'y is not finite. Value: $y');
    assert(width.isFinite, 'width is not finite. Value: $width');
    assert(height.isFinite, 'height is not finite. Value: $height');
    assert(edgeInsets.l.isFinite,
        'edgeInsets.l is not finite. Value: ${edgeInsets.l}');
    assert(edgeInsets.t.isFinite,
        'edgeInsets.t is not finite. Value: ${edgeInsets.t}');
    assert(edgeInsets.r.isFinite,
        'edgeInsets.r is not finite. Value: ${edgeInsets.r}');
    assert(edgeInsets.b.isFinite,
        'edgeInsets.b is not finite. Value: ${edgeInsets.b}');

    edgeTop = edgeInsets.t;
    innerTop = rect.top + edgeTop;

    edgeLeft = edgeInsets.l;
    innerLeft = rect.left + edgeLeft;

    edgeTopLeft = Vec(edgeLeft, edgeTop);
    innerTopLeft = Vec(innerLeft, innerTop);

    edgeBottom = edgeInsets.b;
    innerBottom = rect.bottom - edgeBottom;

    edgeRight = edgeInsets.r;
    innerRight = rect.right - edgeRight;

    edgeBottomRight = Vec(edgeRight, edgeBottom);
    innerBottomRight = Vec(innerRight, innerBottom);

    horizontalEdgeSpace = edgeLeft + edgeRight;
    verticalEdgeSpace = edgeTop + edgeBottom;
    edgeSize = SizeC(horizontalEdgeSpace, verticalEdgeSpace);

    innerRect = RectC.fromLTRB(innerLeft, innerTop, innerRight, innerBottom);

    innerCenterX = innerRect.center.x;
    innerCenterY = innerRect.center.y;
    innerCenter = innerRect.center;
    innerWidth = innerRect.width;
    innerHeight = innerRect.height;
    innerSize = innerRect.size;
  }

  /// Creates an [OuterNodeBox] from a middle or base box and an [edgeInsets].
  OuterNodeBox.fromMiddleBox(NodeBox box, {required EdgeInsetsModel edgeInsets})
      : this(
          box.x - edgeInsets.l,
          box.y - edgeInsets.t,
          box.width + edgeInsets.l + edgeInsets.r,
          box.height + edgeInsets.t + edgeInsets.b,
          edgeInsets: edgeInsets,
        );

  /// Creates an [OuterNodeBox] from a json map.
  factory OuterNodeBox.fromJson(Map json) {
    final box = NodeBox.fromJson(json);
    return OuterNodeBox(
      box.x,
      box.y,
      box.width,
      box.height,
      edgeInsets: EdgeInsetsModel.fromJson(json['edgeInsets']),
    );
  }

  @override
  OuterNodeBox copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    EdgeInsetsModel? edgeInsets,
  }) =>
      OuterNodeBox(
        x ?? this.x,
        y ?? this.y,
        width ?? this.width,
        height ?? this.height,
        edgeInsets: edgeInsets ?? this.edgeInsets,
      );

  @override
  Map toJson() => {...super.toJson(), 'edgeInsets': edgeInsets.toJson()};

  @override
  String toString() =>
      'OuterNodeBox{x: $x, y: $y, width: $width, height: $height, edgeInsets: $edgeInsets}';
}

/// The [InnerNodeBox] is a [NodeBox] with additional fields that define the
/// padded space inside of the rectangle. This is useful for defining a
/// rectangle that has padding and/or a stroke on the inside.
///
/// You can think of this as the orange overlay that renders inside the
/// selection box of the node in the editor when padding is applied. This is
/// similar to the [Container.padding] field inside [Container] widgets in
/// Flutter.
///
/// In this type of [NodeBox], the [left], [top], [right], and [bottom] values
/// are the inner (orange area) edges of the rectangle. The [width] and
/// [height] values define the distance between the inner edges, or the
/// inner-most orange pixels from one end to the other.
///
/// The [centerX], [centerY], and [center] values are the center of the inner
/// edges, and these may not be the same as the normal middle-box's center
/// because you might have asymmetrical padding applied to your rectangle.
class InnerNodeBox extends NodeBox {
  /// The distance between the left edge of the padded space and the left
  /// edge of the base rectangle.
  ///
  /// This value is always non-negative as it is a DISTANCE and NOT a
  /// coordinate.
  ///
  /// This field is specifically the size of the left half of that orange
  /// area.
  late final double edgeLeft;

  /// The distance between the top edge of the padded space and the top
  /// edge of the base rectangle.
  ///
  /// This value is always non-negative as it is a DISTANCE and NOT a
  /// coordinate.
  ///
  /// This field is specifically the size of the top half of that orange
  /// area.
  late final double edgeTop;

  /// The distance between the bottom edge of the padded space and the bottom
  /// edge of the base rectangle.
  ///
  /// This value is always non-negative as it is a DISTANCE and NOT a
  /// coordinate.
  ///
  /// This field is specifically the size of the bottom half of that orange
  /// area.
  late final double edgeBottom;

  /// The distance between the right edge of the padded space and the right
  /// edge of the base rectangle.
  ///
  /// This value is always non-negative as it is a DISTANCE and NOT a
  /// coordinate.
  ///
  /// This field is specifically the size of the right half of that orange
  /// area.
  late final double edgeRight;

  /// The bottom right point of the padded space, IE: the bottom
  /// right point of the orange area. It's the same as [edgeBottom] and
  /// [edgeRight].
  late final Vec edgeBottomRight;

  /// The top left point of the padded space, IE: the top
  /// left point of the orange area. It's the same as [edgeTop] and [edgeLeft].
  late final Vec edgeTopLeft;

  /// The total horizontal padded space. This is the sum of [edgeLeft] and
  /// [edgeRight], giving you the total width of the padded space.
  late final double horizontalEdgeSpace;

  /// The total vertical padded space. This is the sum of [edgeTop] and
  /// [edgeBottom], giving you the total height of the padded space.
  late final double verticalEdgeSpace;

  /// A convenience field that is the same as [horizontalEdgeSpace] and
  /// [verticalEdgeSpace].
  late final SizeC edgeSize;

  /// The x-coordinate to the left edge of the OUTSIDE of the padded space, IE:
  /// the left edge of the base rectangle.
  ///
  /// If you're looking for the left edge of the padded space, use [x] or
  /// [left] directly since this [InnerNodeBox] tailors to the padded space
  /// and provides precomputed fields about the base rectangle for convenience.
  late final double outerLeft;

  /// The y-coordinate to the top edge of the OUTSIDE of the padded space, IE:
  /// the top edge of the base rectangle.
  ///
  /// If you're looking for the top edge of the padded space, use [y] or
  /// [top] directly since this [InnerNodeBox] tailors to the padded space
  /// and provides precomputed fields about the base rectangle for convenience.
  late final double outerTop;

  /// The x-coordinate to the right edge of the OUTSIDE of the padded space, IE:
  /// the right edge of the base rectangle.
  ///
  /// If you're looking for the right edge of the padded space, use [right] or
  /// [right] directly since this [InnerNodeBox] tailors to the padded space
  /// and provides precomputed fields about the base rectangle for convenience.
  late final double outerRight;

  /// The y-coordinate to the bottom edge of the OUTSIDE of the padded space, IE:
  /// the bottom edge of the base rectangle.
  ///
  /// If you're looking for the bottom edge of the padded space, use [bottom] or
  /// [bottom] directly since this [InnerNodeBox] tailors to the padded space
  /// and provides precomputed fields about the base rectangle for convenience.
  late final double outerBottom;

  /// Is the top left point of the base rectangle, IE: the top left point of the
  /// selection box. It's the same as [outerTop] and [outerLeft].
  late final Vec outerTopLeft;

  /// The bottom right point of the base rectangle, IE: the bottom right point of the
  /// selection box. It's the same as [outerBottom] and [outerRight].
  late final Vec outerBottomRight;

  /// The combined edge insets that make up the padded space. You would
  /// normally assume this is the simple padding of the box, but this can be
  /// more complex if the box has strokes or some other type of padding on top
  /// of the normal one.
  late final EdgeInsetsModel edgeInsets;

  /// The outer rectangle represents the base rectangle, IE: the selection box
  /// in the editor. This is the same as [outerTopLeft] and [outerBottomRight].
  late final RectC outerRect;

  /// The width of the base rectangle, IE: the selection box in the editor.
  /// This is the same as [outerRect.width].
  late final double outerWidth;

  /// The height of the base rectangle, IE: the selection box in the editor.
  /// This is the same as [outerRect.height].
  late final double outerHeight;

  /// The size of the base rectangle, IE: the selection box in the editor.
  /// This is the same as [outerRect.size].
  late final SizeC outerSize;

  /// The outer center X is the center of the base rectangle, IE: the center of
  /// the selection box in the editor. This is the same as [outerRect.centerX].
  late final double outerCenterX;

  /// The outer center Y is the center of the base rectangle, IE: the center of
  /// the selection box in the editor. This is the same as [outerRect.centerY].
  late final double outerCenterY;

  /// The center of the base rectangle, IE: the center of the selection box in
  /// the editor. This is the same as [outerRect.center].
  late final Vec outerCenter;

  /// [x], [y], [width], [height] are of inner box (basic box).
  InnerNodeBox(super.x, super.y, super.width, super.height,
      {required this.edgeInsets}) {
    assert(x.isFinite, 'x is not finite. Value: $x');
    assert(y.isFinite, 'y is not finite. Value: $y');
    assert(width.isFinite, 'width is not finite. Value: $width');
    assert(height.isFinite, 'height is not finite. Value: $height');
    assert(edgeInsets.l.isFinite,
        'edgeInsets.l is not finite. Value: ${edgeInsets.l}');
    assert(edgeInsets.t.isFinite,
        'edgeInsets.t is not finite. Value: ${edgeInsets.t}');
    assert(edgeInsets.r.isFinite,
        'edgeInsets.r is not finite. Value: ${edgeInsets.r}');
    assert(edgeInsets.b.isFinite,
        'edgeInsets.b is not finite. Value: ${edgeInsets.b}');

    edgeTop = edgeInsets.t;
    outerTop = y - edgeTop;

    edgeLeft = edgeInsets.l;
    outerLeft = x - edgeLeft;

    edgeTopLeft = Vec(edgeLeft, edgeTop);
    outerTopLeft = Vec(outerLeft, outerTop);

    edgeBottom = edgeInsets.b;
    outerBottom = y + height + edgeBottom;

    edgeRight = edgeInsets.r;
    outerRight = x + width + edgeRight;

    edgeBottomRight = Vec(edgeRight, edgeBottom);
    outerBottomRight = Vec(outerRight, outerBottom);

    horizontalEdgeSpace = edgeLeft + edgeRight;
    verticalEdgeSpace = edgeTop + edgeBottom;
    edgeSize = SizeC(horizontalEdgeSpace, verticalEdgeSpace);

    outerRect = RectC.fromLTRB(outerLeft, outerTop, outerRight, outerBottom);

    outerCenterX = outerRect.center.x;
    outerCenterY = outerRect.center.y;
    outerCenter = outerRect.center;
    outerWidth = outerRect.width;
    outerHeight = outerRect.height;
    outerSize = outerRect.size;
  }

  /// Creates an [InnerNodeBox] from a middle or base box and an [edgeInsets].
  InnerNodeBox.fromMiddleBox(NodeBox box, {required EdgeInsetsModel edgeInsets})
      : this(
          box.x + edgeInsets.l,
          box.y + edgeInsets.t,
          box.width - edgeInsets.horizontal,
          box.height - edgeInsets.vertical,
          edgeInsets: edgeInsets,
        );

  /// Creates an [InnerNodeBox] from a json map.
  factory InnerNodeBox.fromJson(Map json) {
    final box = NodeBox.fromJson(json);
    return InnerNodeBox(
      box.x,
      box.y,
      box.width,
      box.height,
      edgeInsets: EdgeInsetsModel.fromJson(json['edgeInsets']),
    );
  }

  @override
  InnerNodeBox copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    EdgeInsetsModel? edgeInsets,
  }) {
    return InnerNodeBox(
      x ?? this.x,
      y ?? this.y,
      width ?? this.width,
      height ?? this.height,
      edgeInsets: edgeInsets ?? this.edgeInsets,
    );
  }

  @override
  Map toJson() => {...super.toJson(), 'edgeInsets': edgeInsets.toJson()};

  @override
  String toString() =>
      'InnerNodeBox{x: $x, y: $y, width: $width, height: $height, edgeInsets: $edgeInsets}';
}

/// A simple [NodeBox] that holds a [rotationDegrees] only. Supplementary
/// fields are not provided to reduce verbosity and complexity. This class
/// does not do any additional computations.
///
/// The fields can be outer, inner, or middle. It purely depends on the creator
/// of this class.
class RotatedNodeBox extends NodeBox {
  /// The rotation of the box in degrees.
  late final int rotationDegrees;

  /// The constructor for [RotatedNodeBox]. It takes the same parameters as
  /// [NodeBox] with the addition of [rotationDegrees].
  RotatedNodeBox(super.x, super.y, super.width, super.height,
      {required this.rotationDegrees}) {
    assert(x.isFinite, 'x is not finite. Value: $x');
    assert(y.isFinite, 'y is not finite. Value: $y');
    assert(width.isFinite, 'width is not finite. Value: $width');
    assert(height.isFinite, 'height is not finite. Value: $height');
  }

  /// Creates a [RotatedNodeBox] from a json map.
  factory RotatedNodeBox.fromJson(Map json) {
    final box = NodeBox.fromJson(json);
    return RotatedNodeBox(
      box.x,
      box.y,
      box.width,
      box.height,
      rotationDegrees: json['rotationDegrees'],
    );
  }

  @override
  RotatedNodeBox copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    int? rotationDegrees,
  }) {
    return RotatedNodeBox(
      x ?? this.x,
      y ?? this.y,
      width ?? this.width,
      height ?? this.height,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
    );
  }

  @override
  Map toJson() => {...super.toJson(), 'rotationDegrees': rotationDegrees};

  @override
  String toString() =>
      'MiddleRotationBox{x: $x, y: $y, width: $width, height: $height, rotation: $rotationDegrees}';
}
