/// Represents different types of border shapes.
enum CShapeBorder {
  /// Rectangle shape with sharp and pointy corners.
  /// Usually passed as null in Flutter code.
  rectangle('Rectangle'),

  /// Circle shape.
  circle('Circle'),

  /// A border that fits a stadium-shaped border (a box with semicircles on the
  /// ends) within the rectangle of the widget it is applied to.
  stadium('Stadium'),

  /// A rectangle with circular corners.
  roundedRectangle('Rounded'),

  /// A rectangular border with smooth continuous transitions between the
  /// straight sides and the rounded corners.
  continuousRectangle('Continuous'),

  /// A rectangular border with flattened or "beveled" corners.
  beveledRectangle('Beveled');

  /// Creates a [CShapeBorder] with given [label].
  const CShapeBorder(this.label);

  /// Displayable string representation of this [CShapeBorder].
  final String label;

  /// Whether this [CShapeBorder] can have a radius.
  bool get canHaveRadius =>
      this != rectangle && this != circle && this != stadium;
}
