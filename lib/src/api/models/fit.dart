/// Represents Image fits. Directly translates to Flutter's [BoxFit].
enum Fit {
  /// As large as possible while still containing the source entirely within the
  /// target box.
  contain,

  /// As small as possible while still covering the entire target box.
  cover,

  /// Fill the target box by distorting the source's aspect ratio.
  fill,

  /// Make sure the full height of the source is shown, regardless of
  /// whether this means the source overflows the target box horizontally.
  fitHeight,

  /// Make sure the full width of the source is shown, regardless of
  /// whether this means the source overflows the target box vertically.
  fitWidth,

  /// Align the source within the target box (by default, centering) and discard
  /// any portions of the source that lie outside the box.
  none,

  /// Align the source within the target box (by default, centering) and, if
  /// necessary, scale the source down to ensure that the source fits within the
  /// box.
  scaleDown;

  /// Whether this fit supports scaling.
  bool get isScalable => this == Fit.none;

  /// Whether this fit support image repeat (Tile mode).
  bool get isRepeatable =>
      this == Fit.contain || this == Fit.none || this == Fit.scaleDown;

  /// Whether this fit is fitting image on either width or height.
  bool get isFittingOnOneAxis => this == Fit.fitHeight || this == Fit.fitWidth;

  /// Fits that supports image alignment.
  static const Set<Fit> alignmentSupportedFits = {
    Fit.none,
    Fit.fitWidth,
    Fit.fitHeight,
    Fit.scaleDown,
  };

  /// Whether this fit supports image alignments.
  bool get supportsAlignment => alignmentSupportedFits.contains(this);

  /// Displayable string representation of this fit.
  String get prettify {
    switch (this) {
      case Fit.contain:
        return 'Contain';
      case Fit.cover:
        return 'Cover';
      case Fit.fill:
        return 'Fill';
      case Fit.fitHeight:
        return 'Fit Height';
      case Fit.fitWidth:
        return 'Fit Width';
      case Fit.none:
        return 'None';
      case Fit.scaleDown:
        return 'Scale Down';
    }
  }
}
