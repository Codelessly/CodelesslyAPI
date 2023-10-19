// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';
import 'models.dart';

part 'border_side.g.dart';

/// Represents the style of the border.
enum BorderStyleEnum {
  /// Solid border.
  solid,

  /// No border.
  none;
}

/// Holds data needed to decorate the border side.
@JsonSerializable()
class BorderSideModel with EquatableMixin, SerializableMixin {
  /// Color of the border side.
  final ColorRGBA color;

  /// Style of the border side.
  final BorderStyleEnum style;

  /// Thickness of the border side.
  final double width;

  /// Default constructor for creating a border side.
  const BorderSideModel({
    this.color = ColorRGBA.black,
    this.style = BorderStyleEnum.solid,
    this.width = 1,
  });

  /// Duplicates an instance of [BorderSideModel] with the given values as
  /// overrides.
  BorderSideModel copyWith({
    ColorRGBA? color,
    BorderStyleEnum? style,
    double? width,
  }) =>
      BorderSideModel(
        color: color ?? this.color,
        style: style ?? this.style,
        width: width ?? this.width,
      );

  @override
  List<Object?> get props => [color, style, width];

  /// Creates a new instance of this class from a JSON object.
  factory BorderSideModel.fromJson(Map json) => _$BorderSideModelFromJson(json);

  @override
  Map toJson() => _$BorderSideModelToJson(this);
}
