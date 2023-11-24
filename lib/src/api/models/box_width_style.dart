// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Different types of box height for text. Directly translates to Flutter's
/// [BoxWidthStyle].
enum BoxWidthStyleEnum {
  /// Provide tight bounding boxes that fit widths to the runs of each line
  /// independently.
  max,

  /// Adds up to two additional boxes as needed at the beginning and/or end
  /// of each line so that the widths of the boxes in line are the same width
  /// as the widest line in the paragraph.
  tight;

  /// Displayable string representation of [BoxWidthStyleEnum].
  String get prettify {
    late String text;
    switch (this) {
      case BoxWidthStyleEnum.max:
        text = 'Maximum';
      case BoxWidthStyleEnum.tight:
        text = 'Tight';
    }
    return text;
  }
}
