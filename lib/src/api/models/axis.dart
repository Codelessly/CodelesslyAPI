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

  /// String representation of this axis as an adjective.
  String get adjective => switch (this) {
        AxisC.horizontal => 'horizontally',
        AxisC.vertical => 'vertically'
      };

  /// String representation of this axis's dimension.
  String get dimension =>
      switch (this) { AxisC.horizontal => 'width', AxisC.vertical => 'height' };
}
