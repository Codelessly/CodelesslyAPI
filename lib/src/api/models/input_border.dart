// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../serializable_mixin.dart';
import 'border_side.dart';
import 'corner_radius.dart';

part 'input_border.g.dart';

/// Represents the type of input border.
enum BorderTypeEnum {
  /// No border.
  none,

  /// Border around the input field.
  outline,

  /// Border under the input field.
  underline,
}

/// Represents decoration for an input border.
@JsonSerializable()
class InputBorderModel with EquatableMixin, SerializableMixin {
  /// The type of input border.
  final BorderTypeEnum borderType;

  /// Border side decoration data for the input border.
  final BorderSideModel borderSide;

  /// Border radius for input border.
  final CornerRadius cornerRadius;

  /// Horizontal padding on either side of the border's
  /// [InputDecoration.labelText] width gap.
  final double gapPadding;

  /// Creates an instance of input border model.
  const InputBorderModel({
    this.borderType = BorderTypeEnum.outline,
    this.borderSide = const BorderSideModel(),
    this.cornerRadius = const CornerRadius.all(RadiusModel.circular(4)),
    this.gapPadding = 4,
  });

  /// Creates an instance of input border model with no border.
  factory InputBorderModel.none() => const InputBorderModel(
        borderType: BorderTypeEnum.none,
        borderSide: BorderSideModel(width: 0.0, style: BorderStyleEnum.none),
      );

  /// Creates an instance of input border model with outline border.
  factory InputBorderModel.outline({
    BorderSideModel borderSide = const BorderSideModel(),
    CornerRadius cornerRadius = const CornerRadius.all(RadiusModel.circular(4)),
    double gapPadding = 4,
  }) =>
      InputBorderModel(
        borderType: BorderTypeEnum.outline,
        borderSide: borderSide,
        cornerRadius: cornerRadius,
        gapPadding: gapPadding,
      );

  /// Creates an instance of input border model with underline border.
  factory InputBorderModel.underline({
    BorderSideModel borderSide = const BorderSideModel(),
    CornerRadius cornerRadius = const CornerRadius(
      tl: RadiusModel.circular(4),
      tr: RadiusModel.circular(4),
      bl: RadiusModel.circular(4),
      br: RadiusModel.circular(4),
    ),
  }) =>
      InputBorderModel(
        borderType: BorderTypeEnum.underline,
        borderSide: borderSide,
        cornerRadius: cornerRadius,
      );

  /// Duplicates this instance with the given data overrides.
  InputBorderModel copyWith({
    BorderTypeEnum? borderType,
    BorderSideModel? borderSide,
    CornerRadius? cornerRadius,
    double? gapPadding,
  }) =>
      InputBorderModel(
        borderType: borderType ?? this.borderType,
        borderSide: borderSide ?? this.borderSide,
        cornerRadius: cornerRadius ?? this.cornerRadius,
        gapPadding: gapPadding ?? this.gapPadding,
      );

  @override
  List<Object?> get props => [borderType, borderSide, cornerRadius, gapPadding];

  /// Factory constructor for creating a new [InputBorderModel] instance from
  /// JSON data.
  factory InputBorderModel.fromJson(Map json) =>
      _$InputBorderModelFromJson(json);

  @override
  Map toJson() => _$InputBorderModelToJson(this);
}
