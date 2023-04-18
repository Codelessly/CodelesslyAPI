// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Different types of box height for text. Directly translates to Flutter's
/// [BoxHeightStyle].
enum BoxHeightStyleEnum {
  /// Extends the bottom edge of the bounds to fully cover any line spacing.
  includeLineSpacingBottom,

  /// Extends the top and bottom edge of the bounds to fully cover any line
  /// spacing.
  includeLineSpacingMiddle,

  /// Extends the top edge of the bounds to fully cover any line spacing.
  includeLineSpacingTop,

  /// The height of the boxes will be the maximum height of all runs in the
  /// line. All boxes in the same line will be the same height.
  max,

  /// Calculate box heights based on the metrics of this paragraph's
  /// [StrutStyle].
  strut,

  /// Provide tight bounding boxes that fit heights per run. This style may
  /// result in uneven bounding boxes that do not nicely connect with adjacent
  /// boxes.
  tight;

  /// Displayable string representation of this class.
  String get prettify {
    late String text;
    switch (this) {
      case BoxHeightStyleEnum.includeLineSpacingBottom:
        text = 'Include line spacing bottom';
        break;
      case BoxHeightStyleEnum.includeLineSpacingMiddle:
        text = 'Include line spacing middle';
        break;
      case BoxHeightStyleEnum.includeLineSpacingTop:
        text = 'Include line spacing top';
        break;
      case BoxHeightStyleEnum.max:
        text = 'Maximum';
        break;
      case BoxHeightStyleEnum.strut:
        text = 'Strut';
        break;
      case BoxHeightStyleEnum.tight:
        text = 'Tight';
        break;
    }
    return text;
  }
}
