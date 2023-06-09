// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Represents the two cardinal directions in two dimensions.
enum AxisC {
  /// Left and right.
  horizontal,

  /// Up and down.
  vertical;

  /// Returns the opposite of the given [Axis].
  AxisC get opposite =>
      this == AxisC.horizontal ? AxisC.vertical : AxisC.horizontal;

  /// Whether this axis is horizontal.
  bool get isHorizontal => this == AxisC.horizontal;

  /// Whether this axis is vertical.
  bool get isVertical => this == AxisC.vertical;

  /// String representation of this axis.
  String get adjective {
    switch (this) {
      case AxisC.horizontal:
        return 'horizontally';
      case AxisC.vertical:
        return 'vertically';
    }
  }
}
