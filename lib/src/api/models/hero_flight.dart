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
  morphCorners,

  /// The node flies along a curve instead of a straight line (bowed to the
  /// side, like Material's arc), turning from a slight tilt to upright as it
  /// lands and glowing on the way: the swell and fade of a halo in the colour
  /// of the node's first drop shadow (soft white without one). A planet
  /// lifting off its orbit onto its page.
  arc,

  /// Both nodes fly, each fitted to the in-between box: the one leaving
  /// fades out while the one arriving fades in, and the corners turn from
  /// one to the other. A title whose size, weight or colour differs between
  /// the screens, or a chip that changes colour, morphs smoothly.
  morph,

  /// Like [morph], but the node leaving fades out over the first 35% of the
  /// flight and the arriving one fades in after it (Material fade through).
  fadeThrough,

  /// Material container transform: a card grows into a whole screen. Give
  /// the card and the destination screen's root frame the same tag. The box
  /// grows from the card to the screen, its corners turn from the card's to
  /// the screen's, the card fades out over the first 30% and the screen fades
  /// in over the rest. Pair it with a route transition that doesn't move the
  /// screen (none or fade through).
  containerTransform;

  /// Displayable name.
  String get prettify => switch (this) {
    HeroFlight.standard => 'Standard',
    HeroFlight.morphCorners => 'Morph corners',
    HeroFlight.arc => 'Arc and glow',
    HeroFlight.morph => 'Morph (style, colour)',
    HeroFlight.fadeThrough => 'Fade through',
    HeroFlight.containerTransform => 'Container transform',
  };

  /// Whether both nodes are drawn during the flight, cross-fading.
  bool get crossFades =>
      this == HeroFlight.morph ||
      this == HeroFlight.fadeThrough ||
      this == HeroFlight.containerTransform;
}

/// What a shared element's destination shows while its own drawing isn't
/// ready yet (a network image that hasn't loaded).
enum HeroPlaceholder {
  /// Nothing extra: the destination draws as soon as it can.
  none,

  /// The source node's drawing stays under the destination's at the end of
  /// the flight until the destination's image has loaded, so a thumbnail
  /// holds the place of the full image instead of a blank box.
  source;

  /// Displayable name.
  String get prettify => switch (this) {
    HeroPlaceholder.none => 'None',
    HeroPlaceholder.source => 'Keep source until loaded',
  };
}
