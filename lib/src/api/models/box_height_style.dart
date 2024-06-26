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
      case BoxHeightStyleEnum.includeLineSpacingMiddle:
        text = 'Include line spacing middle';
      case BoxHeightStyleEnum.includeLineSpacingTop:
        text = 'Include line spacing top';
      case BoxHeightStyleEnum.max:
        text = 'Maximum';
      case BoxHeightStyleEnum.strut:
        text = 'Strut';
      case BoxHeightStyleEnum.tight:
        text = 'Tight';
    }
    return text;
  }
}
