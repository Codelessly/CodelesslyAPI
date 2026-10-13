/// Represents the control affinity for a list tile, i.e., position of the
/// primary widget in list tile.
enum ListTileControlAffinityC {
  /// Position the control on the leading edge, and the secondary widget, if
  /// any, on the trailing edge.
  leading,

  /// Position the control on the trailing edge, and the secondary widget, if
  /// any, on the leading edge.
  trailing,

  /// Position the control relative to the text in the fashion that is typical
  /// for the current platform, and place the secondary widget on the opposite
  /// side.
  platform,
}

/// How a list tile aligns its leading and trailing widgets with its title.
/// Mirrors Flutter's `ListTileTitleAlignment`.
enum ListTileTitleAlignmentC {
  /// Top-aligned for three-line tiles, centered otherwise. The Material 3
  /// default.
  threeLine,

  /// Aligned relative to the title's height. The Material 2 default.
  titleHeight,

  /// Aligned to the top of the tile.
  top,

  /// Centered in the tile.
  center,

  /// Aligned to the bottom of the tile.
  bottom,
}
