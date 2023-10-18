// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../mixins.dart';
import 'vec.dart';

part 'visual_density.g.dart';

/// Represents the visual density of material UI components. Corresponds to
/// Flutter's [VisualDensity].
enum VisualDensityType {
  /// The default profile for [VisualDensity] in [ThemeData].
  ///
  /// This default value represents a visual density that is less dense than
  /// either [comfortable] or [compact], and corresponds to density values of
  /// zero in both axes.
  standard('Standard'),

  /// The profile for a "comfortable" interpretation of [VisualDensity].
  ///
  /// Individual components will interpret the density value independently,
  /// making themselves more visually dense than [standard] and less dense than
  /// [compact] to different degrees based on the Material Design specification
  /// of the "comfortable" setting for their particular use case.
  ///
  /// It corresponds to a density value of -1 in both axes.
  comfortable('Comfortable'),

  /// The profile for a "compact" interpretation of [VisualDensity].
  ///
  /// Individual components will interpret the density value independently,
  /// making themselves more visually dense than [standard] and [comfortable] to
  /// different degrees based on the Material Design specification of the
  /// "comfortable" setting for their particular use case.
  ///
  /// It corresponds to a density value of -2 in both axes.
  compact('Compact'),

  /// Returns a visual density that is adaptive based on the
  /// [defaultTargetPlatform].
  ///
  /// For desktop platforms, this returns [compact], and for other platforms, it
  /// returns a default-constructed [VisualDensity].
  adaptivePlatformDensity('Adaptive'),

  /// The minimum allowed density.
  minimum('Minimum'),

  /// The maximum allowed density.
  maximum('Maximum'),

  /// Configurable custom density.
  custom('Custom');

  /// Default constructor for the enum.
  const VisualDensityType(this.label);

  /// String representation of the enum.
  final String label;
}

/// Holds visual density data.
@JsonSerializable()
class VisualDensityModel with EquatableMixin, SerializableMixin {
  /// Density value for horizontal axis.
  final double horizontal;

  /// Density value for vertical axis.
  final double vertical;

  /// Type of the density.
  final VisualDensityType type;

  /// Creates a [VisualDensityModel] instance with the given data.
  const VisualDensityModel({
    this.horizontal = 0.0,
    this.vertical = 0.0,
    this.type = VisualDensityType.standard,
  });

  /// A standard visual density.
  static const VisualDensityModel standard =
      VisualDensityModel(type: VisualDensityType.standard);

  /// A comfortable visual density.
  static const VisualDensityModel comfortable = VisualDensityModel(
    horizontal: -1.0,
    vertical: -1.0,
    type: VisualDensityType.comfortable,
  );

  /// A compact visual density.
  static const VisualDensityModel compact = VisualDensityModel(
    horizontal: -2.0,
    vertical: -2.0,
    type: VisualDensityType.compact,
  );

  /// The base adjustment in logical pixels of the visual density of UI
  /// components.
  ///
  /// The input density values are multiplied by a constant to arrive at a base
  /// size adjustment that fits material design guidelines.
  ///
  /// Individual components may adjust this value based upon their own
  /// individual interpretation of density.
  Vec get baseSizeAdjustment {
    // The number of logical pixels represented by an increase or decrease in
    // density by one. According to the Material Design guidelines, size should
    // be incremented or decremented by 4 pixels.
    const double interval = 4.0;

    return Vec(horizontal, vertical) * interval;
  }

  /// Duplicates this instance with given value overrides.
  VisualDensityModel copyWith({
    double? horizontal,
    double? vertical,
    VisualDensityType? type,
  }) {
    return VisualDensityModel(
      type: type ?? this.type,
      horizontal: horizontal ?? this.horizontal,
      vertical: vertical ?? this.vertical,
    );
  }

  @override
  List<Object?> get props => [horizontal, vertical];

  /// Factory constructor for creating a new [VisualDensityModel] instance
  /// from JSON data.
  factory VisualDensityModel.fromJson(Map<String, dynamic> json) =>
      _$VisualDensityModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VisualDensityModelToJson(this);
}
