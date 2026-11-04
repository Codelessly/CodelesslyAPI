// Flutter's enums, by Flutter's names. Defaults are Flutter's.

enum Axis { horizontal, vertical }

enum MainAxisAlignment { start, end, center, spaceBetween, spaceAround, spaceEvenly }

enum CrossAxisAlignment { start, end, center, stretch, baseline }

enum MainAxisSize { min, max }

enum Clip { none, hardEdge, antiAlias, antiAliasWithSaveLayer }

enum TextAlign { left, right, center, justify, start, end }

/// Vertical placement of text inside its box (Flutter's `TextAlignVertical`).
enum TextAlignVertical { top, center, bottom }

enum TextOverflow { clip, fade, ellipsis, visible }

enum FontStyle { normal, italic }

enum TextDecoration { none, underline, overline, lineThrough }

enum TextDecorationStyle { solid, double, dotted, dashed, wavy }

/// Where a stroke sits relative to the box edge (Flutter's
/// `BorderSide.strokeAlign`: inside -1, center 0, outside 1).
enum StrokeAlign {
  inside(-1),
  center(0),
  outside(1);

  const StrokeAlign(this.value);
  final double value;
}

enum StrokeCap { butt, round, square }

enum BoxFit { fill, contain, cover, fitWidth, fitHeight, none, scaleDown }

enum ImageRepeat { noRepeat, repeat, repeatX, repeatY }

enum TileMode { clamp, repeated, mirror, decal }

enum BlendMode {
  clear,
  src,
  dst,
  srcOver,
  dstOver,
  srcIn,
  dstIn,
  srcOut,
  dstOut,
  srcATop,
  dstATop,
  xor,
  plus,
  modulate,
  screen,
  overlay,
  darken,
  lighten,
  colorDodge,
  colorBurn,
  hardLight,
  softLight,
  difference,
  exclusion,
  multiply,
  hue,
  saturation,
  color,
  luminosity,
}

enum VerticalDirection { up, down }

enum ScrollPhysicsType { platform, bouncing, clamping, never, rangeMaintaining }
