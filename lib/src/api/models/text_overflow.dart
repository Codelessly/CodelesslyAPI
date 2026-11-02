/// Describes how overflowing text gets clipped.
enum TextOverflowC {
  /// Clip the overflowing text to fix its container.
  clip,

  /// Fade the overflowing text to transparent.
  fade,

  /// Use an ellipsis to indicate that the text has overflowed.
  ellipsis,

  /// Render overflowing text outside of its container.
  visible,

  /// Shrink the text to fit its box when it is too wide, like Flutter's
  /// `FittedBox(fit: BoxFit.scaleDown)`: a countdown that keeps one line.
  scaleDown,
}
