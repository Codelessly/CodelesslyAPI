/// Defines the type of grid delegate to use for a [GridViewNode].
enum GridDelegateType {
  /// Represents a delegate that makes grid layouts with a fixed number of tiles
  /// in the cross axis.
  fixedCrossAxisCount,

  /// Represents a delegate that makes grid layouts with tiles that each have a
  /// maximum cross-axis extent.
  maxCrossAxisExtent;

  /// Pretty name of the enum value.
  String get label => switch (this) {
        fixedCrossAxisCount => 'Fixed Cross Axis Count',
        maxCrossAxisExtent => 'Max Cross Axis Extent',
      };
}
