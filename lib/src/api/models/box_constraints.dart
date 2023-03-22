// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'box_constraints.g.dart';

/// Holds sizing constraints for a node.
@JsonSerializable()
class BoxConstraintsModel with EquatableMixin, SerializableMixin {
  /// Represents the minimum width a node can have. Must not be less than zero.
  final double? minWidth;

  /// Represents the maximum width a node can have.
  final double? maxWidth;

  /// Represents the minimum height a node can have. Must not be less than zero.
  final double? minHeight;

  /// Represents the maximum height a node can have.
  final double? maxHeight;

  /// Default constructor for creating new instances.
  const BoxConstraintsModel({
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
  });

  // This will set all of them to null because every value is nullable.
  // BoxConstraintsModel copyWith({
  //   double? minWidth,
  //   double? maxWidth,
  //   double? minHeight,
  //   double? maxHeight,
  // }) =>
  //     BoxConstraintsModel(
  //       minWidth: minWidth ?? this.minWidth,
  //       maxWidth: maxWidth ?? this.maxWidth,
  //       minHeight: minHeight ?? this.minHeight,
  //       maxHeight: maxHeight ?? this.maxHeight,
  //     );

  /// Duplicates instance of this class with given [minWidth] value override.
  BoxConstraintsModel updateMinWidth(double? value) => BoxConstraintsModel(
        minWidth: value,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
      );

  /// Duplicates instance of this class with given [maxWidth] value override.
  BoxConstraintsModel updateMaxWidth(double? value) => BoxConstraintsModel(
        minWidth: minWidth,
        maxWidth: value,
        minHeight: minHeight,
        maxHeight: maxHeight,
      );

  /// Duplicates instance of this class with given [minHeight] value override.
  BoxConstraintsModel updateMinHeight(double? value) => BoxConstraintsModel(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: value,
        maxHeight: maxHeight,
      );

  /// Duplicates instance of this class with given [maxHeight] value override.
  BoxConstraintsModel updateMaxHeight(double? value) => BoxConstraintsModel(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: value,
      );

  /// Returns new box constraints that remove the minimum width and height requirements.
  BoxConstraintsModel loosen() {
    return BoxConstraintsModel(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  /// Returns new box constraints that respect the given constraints while being
  /// as close as possible to the original constraints.
  BoxConstraintsModel enforce(BoxConstraintsModel constraints) {
    final bool doesConstrainWidth =
        constraints.minWidth != null && constraints.maxWidth != null;
    final bool doesConstrainHeight =
        constraints.minHeight != null && constraints.maxHeight != null;

    return BoxConstraintsModel(
      minWidth: !doesConstrainWidth
          ? minWidth
          : minWidth?.clamp(constraints.minWidth!, constraints.maxWidth!),
      maxWidth: !doesConstrainWidth
          ? maxWidth
          : maxWidth?.clamp(constraints.minWidth!, constraints.maxWidth!),
      minHeight: !doesConstrainHeight
          ? minHeight
          : minHeight?.clamp(constraints.minHeight!, constraints.maxHeight!),
      maxHeight: !doesConstrainHeight
          ? maxHeight
          : maxHeight?.clamp(constraints.minHeight!, constraints.maxHeight!),
    );
  }

  /// Returns new box constraints with a tight width and/or height as close to
  /// the given width and height as possible while still respecting the original
  /// box constraints.
  BoxConstraintsModel tighten({double? width, double? height}) {
    return BoxConstraintsModel(
      minWidth: width == null
          ? minWidth
          : width.clamp(minWidth ?? 0, maxWidth ?? double.infinity),
      maxWidth: width == null
          ? maxWidth
          : width.clamp(minWidth ?? 0, maxWidth ?? double.infinity),
      minHeight: height == null
          ? minHeight
          : height.clamp(minHeight ?? 0, maxHeight ?? double.infinity),
      maxHeight: height == null
          ? maxHeight
          : height.clamp(minHeight ?? 0, maxHeight ?? double.infinity),
    );
  }

  /// Returns the size that both satisfies the constraints and is as close as
  /// possible to the given size.
  SizeC constrain(SizeC size) {
    final SizeC result =
        SizeC(constrainWidth(size.width), constrainHeight(size.height));
    return result;
  }

  /// Returns the width that both satisfies the constraints and is as close as
  /// possible to the given width.
  double constrainWidth([double width = double.infinity]) {
    return width.clamp(minWidth ?? 0, maxWidth ?? double.infinity);
  }

  /// Returns the height that both satisfies the constraints and is as close as
  /// possible to the given height.
  double constrainHeight([double height = double.infinity]) {
    return height.clamp(minHeight ?? 0, maxHeight ?? double.infinity);
  }

  /// Merges this constraint with the provided [size].
  /// The minimum will be at least [size], and the maximum cannot be less than
  /// [size].
  BoxConstraintsModel merge(SizeC size) {
    return BoxConstraintsModel(
      minWidth: (minWidth == null)
          ? (size.width <= 0 ? null : size.width)
          : max(minWidth!, size.width),
      minHeight: (minHeight == null)
          ? (size.height <= 0 ? null : size.height)
          : max(minHeight!, size.height),
      maxWidth: (maxWidth == null) ? null : max(maxWidth!, size.width),
      maxHeight: (maxHeight == null) ? null : max(maxHeight!, size.height),
    );
  }

  /// Adds a [size] to the current box constraints model's minWidth and minHeight
  /// and returns a new box constraints model.
  BoxConstraintsModel add(SizeC size) {
    return BoxConstraintsModel(
      minWidth: size.width <= 0
          ? minWidth
          : min((minWidth ?? 0) + size.width, maxWidth ?? double.infinity),
      minHeight: size.height <= 0
          ? minHeight
          : min((minHeight ?? 0) + size.height, maxHeight ?? double.infinity),
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  /// Whether this constraints is the same as no constraints which is the
  /// default value.
  bool get isDefault =>
      (minWidth == null || minWidth == 0.0) &&
      maxWidth == null &&
      (minHeight == null || minHeight == 0.0) &&
      maxHeight == null;

  /// Whether there's no value set for any of the constraints.
  bool get isEmpty =>
      minWidth == null &&
      maxWidth == null &&
      minHeight == null &&
      maxHeight == null;

  @override
  List<Object?> get props => [minWidth, maxWidth, minHeight, maxHeight];

  /// Factory constructor for creating a new [BoxConstraintsModel] instance
  /// from JSON data.
  factory BoxConstraintsModel.fromJson(Map json) =>
      _$BoxConstraintsModelFromJson(json);

  @override
  Map toJson() => _$BoxConstraintsModelToJson(this);
}
