// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../serializable_mixin.dart';

part 'corner_radius.g.dart';

/// Represents a corner of a rect.
enum RadiusDirection {
  /// All corners.
  all,

  /// Top-left corner.
  tl,

  /// Top-right corner.
  tr,

  /// Bottom-left corner.
  bl,

  /// Bottom-right corner.
  br,
}

/// Type of radius.
enum RadiusType {
  /// A corner shape controlled by a radius value.
  circular,

  /// A corner shape controlled by an elliptical shape formula.
  elliptical;
}

/// Holds corner radius values for a rect. Similar to Flutter's [BorderRadius].
@JsonSerializable()
class CornerRadius extends Equatable with SerializableMixin {
  /// Radius for the top-left corner.
  final RadiusModel tl;

  /// Radius for the top-right corner.
  final RadiusModel tr;

  /// Radius for the bottom-left corner.
  final RadiusModel bl;

  /// Radius for the bottom-right corner.
  final RadiusModel br;

  /// Type of the radius.
  final RadiusType type;

  /// Whether all the corners has the same radius values.
  final bool linked;

  /// Creates a [CornerRadius] instance with given data.
  const CornerRadius({
    this.type = RadiusType.circular,
    required this.tl,
    required this.tr,
    required this.bl,
    required this.br,
    this.linked = false,
  });

  /// Represents no corner radius.
  static const CornerRadius zero = CornerRadius.all(RadiusModel.zero);

  /// Creates a [CornerRadius] with all the corners having the same radius.
  const CornerRadius.all(
    RadiusModel radius, {
    RadiusType type = RadiusType.circular,
    bool linked = false,
  }) : this.only(
          type: type,
          tl: radius,
          tr: radius,
          bl: radius,
          br: radius,
          linked: linked,
        );

  /// Creates a [CornerRadius] with individual corner radius values.
  const CornerRadius.only({
    this.type = RadiusType.circular,
    this.tl = RadiusModel.zero,
    this.tr = RadiusModel.zero,
    this.bl = RadiusModel.zero,
    this.br = RadiusModel.zero,
    this.linked = false,
  });

  /// Whether all the corners have the same values.
  bool get isUniform => tr == tl && tl == bl && bl == br;

  @override
  String toString() => 'Radius(tl: $tl, tr: $tr, bl: $bl, br: $br)';

  @override
  List<Object> get props => [tl, tr, bl, br, linked, type];

  /// Duplicates this instance of [CornerRadius] with given data overrides.
  CornerRadius copyWith({
    RadiusType? type,
    RadiusModel? tl,
    RadiusModel? tr,
    RadiusModel? bl,
    RadiusModel? br,
    bool? linked,
  }) =>
      CornerRadius(
        type: type ?? this.type,
        linked: linked ?? this.linked,
        tl: tl ?? this.tl,
        tr: tr ?? this.tr,
        bl: bl ?? this.bl,
        br: br ?? this.br,
      );

  /// Factory constructor for creating a new [CornerRadius] instance from
  /// JSON data.
  factory CornerRadius.fromJson(Map json) {
    // compatibility with old versions for renderer
    if (json['tl'] is num) {
      return CornerRadius.only(
        tl: RadiusModel.circular(json['tl'].toDouble()),
        tr: RadiusModel.circular(json['tr'].toDouble()),
        bl: RadiusModel.circular(json['bl'].toDouble()),
        br: RadiusModel.circular(json['br'].toDouble()),
      );
    }
    return _$CornerRadiusFromJson(json);
  }

  @override
  Map toJson() => _$CornerRadiusToJson(this);
}

/// A radius for either circular or elliptical shapes.
@JsonSerializable()
class RadiusModel extends Equatable with SerializableMixin {
  /// The radius value on the horizontal axis.
  final double x;

  /// The radius value on the vertical axis.
  final double y;

  /// Creates [RadiusModel] with given values.
  const RadiusModel({required this.x, required this.y});

  /// Constructs an elliptical radius with the given radii.
  const RadiusModel.elliptical(this.x, this.y);

  /// Constructs a circular radius. [x] and [y] will have the same radius value.
  const RadiusModel.circular(double value) : this(x: value, y: value);

  /// Whether this radius is circular.
  bool get isCircular => x == y;

  /// Represents no radius.
  static const RadiusModel zero = RadiusModel.circular(0);

  @override
  String toString() => 'Radius(x: $x, y: $y)';

  @override
  List<Object> get props => [x, y];

  /// Duplicates this instance with given value overrides.
  RadiusModel copyWith({double? x, double? y}) =>
      RadiusModel(x: x ?? this.x, y: y ?? this.y);

  /// Factory constructor for creating a new [RadiusModel] instance from
  /// JSON data.
  factory RadiusModel.fromJson(Map json) => _$RadiusModelFromJson(json);

  @override
  Map toJson() => _$RadiusModelToJson(this);
}
