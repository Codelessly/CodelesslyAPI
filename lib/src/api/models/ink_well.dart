// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'ink_well.g.dart';

/// Represents properties that relate to the [InkWell] widget in Flutter.
@JsonSerializable()
class InkWellModel with EquatableMixin, SerializableMixin {

  /// The highlight color of the [InkWell] if [useInkWell] is true.
  final ColorRGBA? highlightColor;

  /// The splash color of the [InkWell] if [useInkWell] is true.
  final ColorRGBA? splashColor;

  /// The hover color of the [InkWell] if [useInkWell] is true.
  final ColorRGBA? hoverColor;

  /// The focus color of the [InkWell] if [useInkWell] is true.
  final ColorRGBA? focusColor;

  /// Creates an [InkWellModel] instance with the given data.
  const InkWellModel({
    this.highlightColor,
    this.splashColor,
    this.hoverColor,
    this.focusColor,
  });

  /// Duplicates this instance of [InkWellModel] with given useInkWell value.
  InkWellModel copyWithUseInkWell(bool value) => InkWellModel(
        highlightColor: highlightColor,
        splashColor: splashColor,
        hoverColor: hoverColor,
        focusColor: focusColor,
      );

  /// Duplicates this instance of [InkWellModel] with given highlight color.
  InkWellModel copyWithHighlightColor(ColorRGBA? color) => InkWellModel(
        highlightColor: color,
        splashColor: splashColor,
        hoverColor: hoverColor,
        focusColor: focusColor,
      );

  /// Duplicates this instance of [InkWellModel] with given splash color.
  InkWellModel copyWithSplashColor(ColorRGBA? color) => InkWellModel(
        highlightColor: highlightColor,
        splashColor: color,
        hoverColor: hoverColor,
        focusColor: focusColor,
      );

  /// Duplicates this instance of [InkWellModel] with given hover color.
  InkWellModel copyWithHoverColor(ColorRGBA? color) => InkWellModel(
        highlightColor: highlightColor,
        splashColor: splashColor,
        hoverColor: color,
        focusColor: focusColor,
      );

  /// Duplicates this instance of [InkWellModel] with given focus color.
  InkWellModel copyWithFocusColor(ColorRGBA? color) => InkWellModel(
        highlightColor: highlightColor,
        splashColor: splashColor,
        hoverColor: hoverColor,
        focusColor: color,
      );

  /// Factory constructor for creating a new [InkWellModel] instance
  /// from JSON data.
  factory InkWellModel.fromJson(Map<String, dynamic> json) =>
      _$InkWellModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$InkWellModelToJson(this);

  @override
  List<Object?> get props => [
        highlightColor,
        splashColor,
        hoverColor,
        focusColor,
      ];
}
