/// How a shared element (a node with a `heroTag`) flies between two screens.
enum HeroFlight {
  /// The node of the screen being shown flies from the old place to the new
  /// one, growing or shrinking on the way (Flutter's default hero flight).
  standard,

  /// Like [standard], but the node's corners also turn from the corner
  /// radius of the node on the screen below into the corner radius of the
  /// node on the screen on top (and back on the way back), so a rounded
  /// card can land squared off on a ticket, for example.
  ///
  /// The node on the top screen is drawn through the whole flight, in both
  /// directions, clipped to the in-between corners.
  morphCorners;

  /// Displayable name.
  String get prettify => switch (this) {
    HeroFlight.standard => 'Standard',
    HeroFlight.morphCorners => 'Morph corners',
  };
}
