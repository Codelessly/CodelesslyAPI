// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Type of paint as a string enum
enum PaintType {
  /// Solid color paint
  solid,

  /// A linear gradient.
  gradientLinear,

  /// A radial gradient.
  gradientRadial,

  /// A sweep gradient.
  gradientAngular,

  /// A diamond gradient.
  gradientDiamond,

  /// Image fill
  image,

  /// Emoji as fill.
  emoji;

  /// Displayable string representation of this enum.
  String get prettify {
    switch (this) {
      case PaintType.solid:
        return 'Solid';
      case PaintType.gradientLinear:
        return 'Linear';
      case PaintType.gradientRadial:
        return 'Radial';
      case PaintType.gradientAngular:
        return 'Angular';
      case PaintType.gradientDiamond:
        return 'Diamond';
      case PaintType.image:
        return 'Image';
      case PaintType.emoji:
        return 'Emoji';
      default:
        return 'Unknown';
    }
  }

  /// Whether this paint type is an image type.
  bool get isImage => this == PaintType.image;

  /// Whether this paint type is a gradient type.
  bool get isGradient =>
      this == PaintType.gradientLinear ||
      this == PaintType.gradientRadial ||
      this == PaintType.gradientAngular ||
      this == PaintType.gradientDiamond;

  /// Whether this paint type is a solid color.
  bool get isSolid => this == PaintType.solid;
}
