/// Represents the alignment of a row/column along the main axis which is
/// horizontal for rows and vertical for columns.
/// Directly related to [MainAxisAlignment] in Flutter.
enum MainAxisAlignmentC {
  /// Place the children as close to the start of the main axis as possible.
  start,

  /// Place the children as close to the middle of the main axis as possible.
  center,

  /// Place the children as close to the end of the main axis as possible.
  end,

  /// Place the free space evenly between the children.
  spaceBetween,

  /// Place the free space evenly between the children as well as half of that
  /// space before and after the first and last child.
  spaceAround,

  /// Place the free space evenly between the children as well as before and
  /// after the first and last child.
  spaceEvenly;

  /// String representation of [MainAxisAlignmentC].
  String get prettify {
    switch (this) {
      case MainAxisAlignmentC.start:
        return 'Start';
      case MainAxisAlignmentC.end:
        return 'End';
      case MainAxisAlignmentC.center:
        return 'Center';
      case MainAxisAlignmentC.spaceBetween:
        return 'Space Between';
      case MainAxisAlignmentC.spaceAround:
        return 'Space Around';
      case MainAxisAlignmentC.spaceEvenly:
        return 'Space Evenly';
    }
  }
}

/// Represents the alignment of a row/column along the cross axis which is
/// horizontal for columns and vertical for rows.
/// Directly related to [CrossAxisAlignment] in Flutter.
enum CrossAxisAlignmentC {
  /// Place the children with their start edge aligned with the start side of
  /// the cross axis.
  start,

  /// Place the children so that their centers align with the middle of the
  /// cross axis.
  center,

  /// Place the children as close to the end of the cross axis as possible.
  end,

  /// Require the children to fill the cross axis.
  stretch,

  /// Place the children along the cross axis such that their baselines match.
  ///
  /// Because baselines are always horizontal, this alignment is intended for
  /// horizontal main axes. If the main axis is vertical, then this value is
  /// treated like [start].
  ///
  /// For horizontal main axes, if the minimum height constraint passed to the
  /// flex layout exceeds the intrinsic height of the cross axis, children will
  /// be aligned as close to the top as they can be while honoring the baseline
  /// alignment. In other words, the extra space will be below all the children.
  ///
  /// Children who report no baseline will be top-aligned.
  baseline;

  /// String representation of [CrossAxisAlignmentC].
  String get prettify {
    switch (this) {
      case CrossAxisAlignmentC.start:
        return 'Start';
      case CrossAxisAlignmentC.end:
        return 'End';
      case CrossAxisAlignmentC.center:
        return 'Center';
      case CrossAxisAlignmentC.stretch:
        return 'Stretch';
      case CrossAxisAlignmentC.baseline:
        return 'Base Line';
    }
  }
}
