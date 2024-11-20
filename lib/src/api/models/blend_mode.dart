/// Enum representing various blend modes for combining this layer with layers below.
///
/// Blend modes determine how pixels from this layer are combined with pixels from layers below.
/// They are used in drawing operations to create different visual effects by manipulating color and alpha values.
enum BlendModeC {
  /// Clear
  ///
  /// Completely clears the canvas, leaving it transparent.
  ///
  /// This mode removes this layer and all layers below it, resulting in a fully transparent canvas.
  clear(
    'Clear',
    'Completely clears the canvas, leaving it transparent.\n\n'
        'This mode removes this layer and all layers below it, resulting in a fully transparent canvas.',
  ),

  /// Source
  ///
  /// Shows only this layer and ignores everything else.
  ///
  /// This mode draws this layer and discards all the layers below it.
  src(
    'Source',
    'Shows only this layer and ignores everything else.\n\n'
        'This mode draws this layer and discards all the layers below it.',
  ),

  /// Destination
  ///
  /// Keeps everything as it was before and ignores this layer.
  ///
  /// This mode leaves the layers below untouched and does not draw this layer.
  dst(
    'Destination',
    'Keeps everything as it was before and ignores this layer.\n\n'
        'This mode leaves the layers below untouched and does not draw this layer.',
  ),

  /// Source Over
  ///
  /// Draws this layer on top of what was there before.
  ///
  /// This is the default mode where this layer is blended over the layers below.
  srcOver(
    'Source Over',
    'Draws this layer on top of what was there before.\n\n'
        'This is the default mode where this layer is blended over the layers below.',
  ),

  /// Destination Over
  ///
  /// Draws what was there before on top of this layer.
  ///
  /// This mode renders the layers below over this layer, effectively placing this layer underneath.
  dstOver(
    'Destination Over',
    'Draws what was there before on top of this layer.\n\n'
        'This mode renders the layers below over this layer, effectively placing this layer underneath.',
  ),

  /// Source In
  ///
  /// Shows this layer only where it overlaps with what was there before.
  ///
  /// This mode keeps the overlapping area of this layer and the layers below, discarding non-overlapping parts of this layer.
  srcIn(
    'Source In',
    'Shows this layer only where it overlaps with what was there before.\n\n'
        'This mode keeps the overlapping area of this layer and the layers below, discarding non-overlapping parts of this layer.',
  ),

  /// Destination In
  ///
  /// Shows the layers below only where they overlap with this layer.
  ///
  /// This mode keeps the overlapping area of the layers below and this layer, discarding non-overlapping parts of the layers below.
  dstIn(
    'Destination In',
    'Shows the layers below only where they overlap with this layer.\n\n'
        'This mode keeps the overlapping area of the layers below and this layer, discarding non-overlapping parts of the layers below.',
  ),

  /// Source Out
  ///
  /// Shows this layer only where it does NOT overlap with what was there before.
  ///
  /// This mode displays parts of this layer that are outside the bounds of the layers below.
  srcOut(
    'Source Out',
    'Shows this layer only where it does NOT overlap with what was there before.\n\n'
        'This mode displays parts of this layer that are outside the bounds of the layers below.',
  ),

  /// Destination Out
  ///
  /// Shows the layers below only where they do NOT overlap with this layer.
  ///
  /// This mode displays parts of the layers below that are outside the bounds of this layer.
  dstOut(
    'Destination Out',
    'Shows the layers below only where they do NOT overlap with this layer.\n\n'
        'This mode displays parts of the layers below that are outside the bounds of this layer.',
  ),

  /// Source Atop
  ///
  /// Draws this layer on top, but only where it overlaps with what was there before.
  ///
  /// This mode renders this layer over the layers below in the overlapping areas and shows the layers below elsewhere.
  srcATop(
    'Source Atop',
    'Draws this layer on top, but only where it overlaps with what was there before.\n\n'
        'This mode renders this layer over the layers below in the overlapping areas and shows the layers below elsewhere.',
  ),

  /// Destination Atop
  ///
  /// Draws what was there before on top, but only where it overlaps with this layer.
  ///
  /// This mode renders the layers below over this layer in the overlapping areas and shows this layer elsewhere.
  dstATop(
    'Destination Atop',
    'Draws what was there before on top, but only where it overlaps with this layer.\n\n'
        'This mode renders the layers below over this layer in the overlapping areas and shows this layer elsewhere.',
  ),

  /// XOR
  ///
  /// Combines this layer and the layers below but makes overlapping areas transparent.
  ///
  /// This mode displays non-overlapping regions of both this layer and the layers below, making overlapping regions transparent.
  xor(
    'XOR',
    'Combines this layer and the layers below but makes overlapping areas transparent.\n\n'
        'This mode displays non-overlapping regions of both this layer and the layers below, making overlapping regions transparent.',
  ),

  /// Add
  ///
  /// Makes the result brighter by adding the colors of this layer and the layers below.
  ///
  /// This mode sums the color values of this layer and the layers below, which can result in brighter colors or white if values exceed the maximum.
  plus(
    'Add',
    'Makes the result brighter by adding the colors of this layer and the layers below.\n\n'
        'This mode sums the color values of this layer and the layers below, which can result in brighter colors or white if values exceed the maximum.',
  ),

  /// Multiply
  ///
  /// Darkens the result by multiplying the colors of this layer and the layers below.
  ///
  /// This mode multiplies the color values of this layer with those of the layers below, resulting in darker colors.
  modulate(
    'Multiply',
    'Darkens the result by multiplying the colors of this layer and the layers below.\n\n'
        'This mode multiplies the color values of this layer with those of the layers below, resulting in darker colors.',
  ),

  /// Screen
  ///
  /// Lightens the result by inverting, multiplying, and inverting the colors again.
  ///
  /// This mode creates a lighter effect by combining this layer and the layers below in a way that preserves light areas.
  screen(
    'Screen',
    'Lightens the result by inverting, multiplying, and inverting the colors again.\n\n'
        'This mode creates a lighter effect by combining this layer and the layers below in a way that preserves light areas.',
  ),

  /// Overlay
  ///
  /// Enhances contrast by combining Multiply and Screen modes.
  ///
  /// This mode applies Multiply blending on dark areas and Screen blending on light areas, using this layer to affect the layers below.
  overlay(
    'Overlay',
    'Enhances contrast by combining Multiply and Screen modes.\n\n'
        'This mode applies Multiply blending on dark areas and Screen blending on light areas, using this layer to affect the layers below.',
  ),

  /// Darken
  ///
  /// Keeps only the darkest parts of this layer and the layers below.
  ///
  /// This mode compares each pixel and retains the lowest color values from this layer and the layers below.
  darken(
    'Darken',
    'Keeps only the darkest parts of this layer and the layers below.\n\n'
        'This mode compares each pixel and retains the lowest color values from this layer and the layers below.',
  ),

  /// Lighten
  ///
  /// Keeps only the lightest parts of this layer and the layers below.
  ///
  /// This mode compares each pixel and retains the highest color values from this layer and the layers below.
  lighten(
    'Lighten',
    'Keeps only the lightest parts of this layer and the layers below.\n\n'
        'This mode compares each pixel and retains the highest color values from this layer and the layers below.',
  ),

  /// Color Dodge
  ///
  /// Brightens the layers below to reflect the colors of this layer.
  ///
  /// This mode divides the color values of the layers below by the inverse of this layer, resulting in a brighter composite.
  colorDodge(
    'Color Dodge',
    'Brightens the layers below to reflect the colors of this layer.\n\n'
        'This mode divides the color values of the layers below by the inverse of this layer, resulting in a brighter composite.',
  ),

  /// Color Burn
  ///
  /// Darkens the layers below to reflect the colors of this layer.
  ///
  /// This mode inverts the color values of this layer and divides them by the layers below, then inverts the result to create a darker effect.
  colorBurn(
    'Color Burn',
    'Darkens the layers below to reflect the colors of this layer.\n\n'
        'This mode inverts the color values of this layer and divides them by the layers below, then inverts the result to create a darker effect.',
  ),

  /// Hard Light
  ///
  /// Adds contrast by emphasizing this layer over the layers below.
  ///
  /// This mode uses this layer to determine whether to multiply or screen the colors, intensifying highlights and shadows.
  hardLight(
    'Hard Light',
    'Adds contrast by emphasizing this layer over the layers below.\n\n'
        'This mode uses this layer to determine whether to multiply or screen the colors, intensifying highlights and shadows.',
  ),

  /// Soft Light
  ///
  /// Softly illuminates the layers below using this layer.
  ///
  /// This mode gently lightens or darkens the colors of the layers below based on this layer, similar to shining a diffused spotlight.
  softLight(
    'Soft Light',
    'Softly illuminates the layers below using this layer.\n\n'
        'This mode gently lightens or darkens the colors of the layers below based on this layer, similar to shining a diffused spotlight.',
  ),

  /// Difference
  ///
  /// Creates an inverted effect by subtracting colors.
  ///
  /// This mode subtracts the color values of this layer and the layers below from each other, resulting in high contrast and inverted colors.
  difference(
    'Difference',
    'Creates an inverted effect by subtracting colors.\n\n'
        'This mode subtracts the color values of this layer and the layers below from each other, resulting in high contrast and inverted colors.',
  ),

  /// Exclusion
  ///
  /// Creates a muted, low-contrast blend of this layer and the layers below.
  ///
  /// This mode produces an effect similar to Difference but with less contrast, resulting in a more subtle blend.
  exclusion(
    'Exclusion',
    'Creates a muted, low-contrast blend of this layer and the layers below.\n\n'
        'This mode produces an effect similar to Difference but with less contrast, resulting in a more subtle blend.',
  ),

  /// Alpha Multiply
  ///
  /// Darkens the image by multiplying colors and transparency.
  ///
  /// This mode multiplies both the color and alpha (transparency) values of this layer with those of the layers below.
  multiply(
    'Alpha Multiply',
    'Darkens the image by multiplying colors and transparency.\n\n'
        'This mode multiplies both the color and alpha (transparency) values of this layer with those of the layers below.',
  ),

  /// Hue
  ///
  /// Applies the color tint of this layer to the layers below.
  ///
  /// This mode combines the hue (color) of this layer with the luminosity and saturation of the layers below.
  hue(
    'Hue',
    'Applies the color tint of this layer to the layers below.\n\n'
        'This mode combines the hue (color) of this layer with the luminosity and saturation of the layers below.',
  ),

  /// Saturation
  ///
  /// Applies the color intensity of this layer to the layers below.
  ///
  /// This mode uses the saturation of this layer with the hue and luminosity of the layers below to adjust color vividness.
  saturation(
    'Saturation',
    'Applies the color intensity of this layer to the layers below.\n\n'
        'This mode uses the saturation of this layer with the hue and luminosity of the layers below to adjust color vividness.',
  ),

  /// Color
  ///
  /// Blends the hue and saturation of this layer with the brightness of the layers below.
  ///
  /// This mode applies the color aspects (hue and saturation) of this layer to the layers below while preserving their luminosity.
  color(
    'Color',
    'Blends the hue and saturation of this layer with the brightness of the layers below.\n\n'
        'This mode applies the color aspects (hue and saturation) of this layer to the layers below while preserving their luminosity.',
  ),

  /// Luminosity
  ///
  /// Applies the brightness of this layer to the color of the layers below.
  ///
  /// This mode combines the luminosity of this layer with the hue and saturation of the layers below, affecting overall lightness.
  luminosity(
    'Luminosity',
    'Applies the brightness of this layer to the color of the layers below.\n\n'
        'This mode combines the luminosity of this layer with the hue and saturation of the layers below, affecting overall lightness.',
  );

  /// The user-friendly label for this blend mode.
  final String label;

  /// The user-friendly description for this blend mode.
  final String description;

  /// Creates a blend mode with the given label and description.
  const BlendModeC(this.label, this.description);
}
