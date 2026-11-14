# Decoration, images, icons and drawing

## When to use

What a node's box paints beyond the base: gradients, pixel patterns and grain, borders on some sides, shadows and
blurs, scrims over children, images, icons, SVG-like paths and custom drawing.

## Minimal example

A card with a solid fill, a border, rounded corners and a shadow, and a gradient band:

{{example:decoration}}

## Reference

### Decoration fields

A node's `"decoration"`: what its box paints. Types without a box decoration keep only blur effects. Fills paint
bottom to top under the node's content; `foregroundFills` paint over it, children included. Every colour may be a
theme colour's name.

{{decorationFields}}

{{reference}}

## Patterns

### Gradients

As Flutter's `LinearGradient`, a linear gradient runs from `"begin"` to `"end"` (alignments; default left to
right; `[0, -1]` to `[0, 1]` is top to bottom). As `RadialGradient`, a radial one has a `"center"` and a `"radius"`
(a share of the box's shortest side); past the last stop it keeps that stop's colour, so end a glow on a transparent
stop. `transform` is the general form. A paint without `type` is an image if it has `image`, a linear gradient if it
has `stops`, else a solid colour.

### A pattern in pixels, a background grid, grain

**A pattern in pixels** (CSS `repeating-linear-gradient(to bottom, #E5E7EB 0 1px, transparent 1px 80px)`): a
linear gradient with `"length": 80` (px from `begin` toward `end`) and `"tileMode": "repeated"`; a background grid is
two of them, one `topCenter` → `bottomCenter`, one `centerLeft` → `centerRight`.

```json
"fills": [
  {"type": "linear", "begin": "topCenter", "end": "bottomCenter", "length": 80, "tileMode": "repeated",
   "stops": [{"position": 0, "color": "#14FFFFFF"}, {"position": 0.0125, "color": "#14FFFFFF"}, {"position": 0.0125, "color": "#00FFFFFF"}, {"position": 1, "color": "#00FFFFFF"}]},
  {"type": "linear", "begin": "centerLeft", "end": "centerRight", "length": 80, "tileMode": "repeated",
   "stops": [{"position": 0, "color": "#14FFFFFF"}, {"position": 0.0125, "color": "#14FFFFFF"}, {"position": 0.0125, "color": "#00FFFFFF"}, {"position": 1, "color": "#00FFFFFF"}]}
]
```

**Grain**: `{"type": "noise", "noise": {"baseFrequency": 0.8, "numOctaves": 3, "seed": 1}, "color": "#FF000000",
"opacity": 0.08}`, SVG's `feTurbulence` as a paint (a seamless tile repeated over the box; `blendMode` as CSS
`mix-blend-mode`).

### Borders, rules and shadows

A node's border is painted with its own box, **under its children**: a child with a fill covers an `inside` border
(the default). Give the parent padding of the border's width, set `"strokeAlign": "outside"`, or put the border (or
the rule) on the filled child. `strokes` with `strokeWidth` (default 1), `strokeAlign` (`inside`, `center`, `outside`), `strokeSides` (`all`,
`bottom`, `topBottom`...) and `dashPattern` (`[6, 4]`). A rule under a text: the text inside a `row` or `column`
with `"strokes": [{"color": ...}], "strokeSides": "bottom"`, or a `box` 1 high. `strokeWidth` without `strokes`
draws nothing. Effects: `dropShadow`, `innerShadow`, `layerBlur`, `backgroundBlur` (frosted glass), each with
`color`, `offset`, `blurRadius`, `spreadRadius`.

### A scrim over a photo

`foregroundFills` paint over the node **and its children**, as Flutter's `foregroundDecoration`: a scrim there
darkens a caption inside the node too. For a caption over a photo, paint the photo in `fills` and put the darkening
gradient on a child `box` before the caption (a stack: photo box, gradient box, caption text), or on the photo
box's `foregroundFills` when the caption is a sibling painted after it.

### Images

Images are image fills: `{"type": "image", "image": {"url": "...", "fit": "cover"}}` in `decoration.fills` of a box
(give the box the image's size or an `aspectRatio`), placed as Flutter's `DecorationImage` places them: `fit` is a
`BoxFit` (`cover`, `contain`, `fill`, `fitWidth`, `fitHeight`, `none`, `scaleDown`) and `alignment` an `Alignment`
(`[0, -0.3]` keeps a face in a cropped photo). The `url` is one of:

- **a file beside the site**, by its path relative to `site.json`'s folder (`"images/hero.jpg"`, as a Flutter app
  names an asset): PNG, JPEG, WebP, GIF, BMP or SVG. The render command reads it from the folder; a published site
  from its files. A path that names no file is `image_failed`, naming it. Use this for photos and illustrations.
- `https://...`: loaded by the app; the render command does not fetch it (`image_network`).
- `data:image/...` (an SVG may be written inline as `data:image/svg+xml;utf8,<svg ...>`, URL-encoded).

Fills stack, first at the bottom: a photo with a gradient scrim over it, so text reads on it, is two fills:

{{example:photo_card}}

<a id="decoration-illustration"></a>
### Illustration

Three ways to draw art without a photo, each scaled to its box:

- **An SVG file** (`images/hills.svg`) as an image fill: drawn as vectors at any size, `fit` and `alignment` as
  for a photo. For a single shape or mark, a `path` node with SVG path data and a `viewBox`.

{{example:vector_illustration}}

- **`customPaint`**: draw lists in a view box, Flutter's `Canvas` calls as data (`rect`, `circle`, `path` with SVG
  data, `line`, `repeat` over a count with `${index}`), behind (`painter`) or over (`foregroundPainter`) the node's
  content. Values may be expressions, so a drawing can follow data. It is not
  clipped by the box's `radius`: round a parent with `clip` for that.

{{example:paint_illustration}}

### Icons

An `icon` node with `props.icon` set to a Material icon name (`"check_circle"`, `"menu"`, `"north_east"`; any name
at fonts.google.com/icons; `_outlined`, `_rounded`, `_sharp` pick the style), `props.color` and `props.size` (the
glyph's size, centered in the node's box; without it the glyph fills the box). A text field's
`decoration.prefixIcon` is `{"icon": "search", "size": 18}`. A name the renderer does not know draws nothing
(`icon_not_drawn`).

### Small marks and shapes

A mark the font lacks (✦, ✳): an `icon` (`"auto_awesome"`, `"star"`), or a `path` node with SVG path data and a
`viewBox` so it scales to its box: the one decorated shape (fills, strokes and shadows from its `decoration`). Custom
drawing beyond one path (several shapes, a line through points, shapes in different colors, text on a canvas): the
`customPaint` behavior's draw lists, behind or over the node's content. A line through points is a `path` op with
`points` (a formula of `${size.width}` for a share of the box), or with `commands` (Flutter's `Path` calls:
`moveTo`, `lineTo`, `quadraticBezierTo`, `cubicTo`, `close`) for curves; shapes in different colors are one `path`
op per color.

## Pitfalls

- An effect needs its `type`; without it the effect is dropped.
- Colours are `"#AARRGGBB"`, `"#RRGGBB"` or a theme name; `"#FFF"`, `rgb()` and CSS names are not read.
- A `path` node without a `viewBox` is drawn in its box's own pixels from the top left and is not clipped to the
  box (as Flutter's `CustomPaint`): give it a `viewBox` to scale it, or clip an ancestor (`path_overflow`).
- Decoration on a type that draws no box (a `text`, a `listView`) is ignored (`decoration_ignored`): wrap it.
- `clip` is needed for children to follow rounded corners.
- A child's fill covers its parent's inside border: pad the parent, stroke outside, or move the border to the child.

## See also

[Theme](@page-theme) (named colours) · [animation](@page-animation) (shimmer, motion) · [values](@page-values)
(Alignment, BorderRadius and the enums).
