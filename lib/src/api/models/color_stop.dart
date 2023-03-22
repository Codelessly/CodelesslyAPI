// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../serializable_mixin.dart';
import 'models.dart';

part 'color_stop.g.dart';

/// A position color pair representing a gradient stop.
@JsonSerializable()
class ColorStop extends Equatable with SerializableMixin {
  /// Value between 0 and 1 representing position along gradient axis
  final double position;

  /// Color attached to corresponding position
  final ColorRGBA color;

  /// Default constructor for creating a new instance.
  const ColorStop({required this.position, required this.color});

  @override
  List<Object> get props => [position, color];

  /// Duplicates this instance with the given fields replaced with the new values.
  ColorStop copyWith({double? position, ColorRGBA? color}) => ColorStop(
        position: position ?? this.position,
        color: color ?? this.color,
      );

  /// Factory constructor for creating a new [ColorStop] instance.
  factory ColorStop.fromJson(Map json) => _$ColorStopFromJson(json);

  @override
  Map toJson() => _$ColorStopToJson(this);
}
