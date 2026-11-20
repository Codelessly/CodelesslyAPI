# 26. Images that stretch and shapes that clip

2026-11-20. Built: an image's `centerSlice` (nine-slice), a decoration's `clipPath` (a path in the box's unit
square), a linear gradient's `angle` (CSS's), and a drawn shape's `blurRadius`. Reference written for the bursts the
particle keys already drew and for a chart over a history that pages and pans.

The owner, on the NOCD rebuild's register section "The base lacks it": "These are all legitimate capabilities we
need!! … check and see if it can be decomposed or created with existing APIs." And: because we own the renderer, any
of it is solvable at the source. Each entry was first composed from what exists, in a scratch page rendered headless;
only what could not be said was built.

## 1. The entries, decomposed

| Entry (register) | What it is in general | Composes? | Outcome |
|---|---|---|---|
| Nine-slice for bitmap fills (11, 15), missing native nine-slice (06) | A picture stretched with fixed caps: Flutter's `centerSlice`, CSS `border-image-slice` | No. A drawing's `image` op takes source and destination rects, but nine of them need the box's size in the drawing's units, which a `customPaint` does not have (`fit=fill` stretches the caps). | Built: `centerSlice` on an image paint and on `Image` |
| Clipping contents to a normalized curve (05) | A box and its children cut to a path that scales with the box: CSS `clip-path: path()`, Flutter's `ClipPath` | No. `clip` cuts to the rounded rectangle or the circle; a drawing's `group clipPath` cuts only its own ops, never the node's children. | Built: `clipPath` on a decoration |
| Cutout and banner gradient geometry (02) | A gradient whose direction is fixed on the screen whatever the box's aspect; a gradient border | Half. A border takes gradient paints (`strokes=[{"type":"linear",…}]`) and the content's inset is its padding. `begin`/`end` are alignments in the box's unit square, so the angle they make changes with the aspect (a banner that grows as its text wraps turns its sheen). | Built: `angle` on a linear paint |
| Soft blur support in artwork (18) | A blurred shape: a glow, a soft shadow, a feathered blob | On a box, yes: `effects=[{"type":"layerBlur","blurRadius":40}]` (the part wrote `blur=`, a key that does not exist). Inside a drawing, no: a draw op's paint had no blur. | Built: `blurRadius` on a drawn shape's paint; the box form is a dictionary word (`Glow`) |
| Particle dynamics are approximated (29) | A burst with count, rate, force, spread, gravity, fade and fresh randomness | Yes: the `particles.*` keys say all of it (`count`, `emit`, `speed`, `spread`, `gravity`, `drag`, `lifetime`, `fadeOut`, `shapes=["star"]`; a fresh seed each burst). The behaviour's table had no sentence, no units and no cue, so the writer read it as absent. | Reference: a section in animation.md, units on every key; a dictionary word (`Confetti`) |
| The chart scrubber does not express a movable history domain (23) | A chart over a long history that a finger scrubs and that pages or pans back | Yes, with the `Graph` (the chart words scrub a fixed domain): its rows from a `slice` of the history by a page in the state, `selection.on=hover` for the scrub; or its own pan (no `fit`), `view={{"last":7}}` and a long-press crosshair, `onScroll` with `result.nearStart` for older rows. | Reference: a section in charts.md with both forms; a dictionary word (`HistoryChart`) |
| Media fallback and border (14) | A null fallback and a 1.5 px border | Yes: `coalesce(item.communityHandle, '')` and `strokeWidth=1.5` are base (the part wrote `??` and `decoration.strokes.0.width`). | Classified: the reference says it; no change |
| Native result artwork unavailable (21) | Result art drawn in a fixed 173×173 box | Yes: a `customPaint` (or an `Image` when the art is an asset); the part had no source art to copy. | Classified: composes; the art itself is missing, not a capability |

## 2. What was added, each the smallest generic piece

**`centerSlice`** on [ImagePaint] (`[left, top, width, height]` in the picture's logical pixels, its pixels divided
by `scale`), Flutter's name and Flutter's meaning (`paintImage(centerSlice:)`): the corners at their own size, the
edges stretched along their side, the middle both ways. A sliced picture fills its box: `fit` is not read (Flutter
asserts that a slice is used with a fit that shows the whole picture; `fill` is its default with a slice). A slice
past the picture's edge is cut to it; one with no area is no slice. An SVG picture is drawn whole (a vector stretches
without losing its corners only if it is drawn so; nine-slicing a picture is left for when one is asked for). The
notation: `Image "…" scale=3 centerSlice=[14,12,28,8]`, and `"centerSlice"` in any image paint (`fills=[…]` behind
text). `scale` on an `Image` line is new with it (it was a field of the paint the line could not say).

**`clipPath`** on [Decoration]: SVG path data in the box's unit square (0 to 1 across and down). CSS's
`clip-path` semantics: everything the node draws is cut (its fills, border, shadows and children), and the hit test
follows the path, so a tap outside it goes to what is under. In the SDK it is a `RenderClipPath` (anti-aliased) at the
top of the node's shell, outside its decoration, its clipper the path scaled to the box. Unit space was chosen so one
path fits every width (a header's wave across a phone and a desktop). The cost: a shape that must keep pixel sizes
at any aspect (a round notch on a ticket that grows) is written for one aspect (an arc's radii are shares of the width
and of the height). A path in pixels, or one that mixes units, would need a view box on the clip (`Path`'s `viewBox`
already is that idea): left open (section 4).

**`angle`** on a linear [Paint]: CSS's `linear-gradient(<angle>, …)`: 0 runs up, 90 to the right, clockwise; the
gradient line crosses the box's middle and is `|w sin a| + |h cos a|` long, so the far corners are its ends. In
place of `begin`/`end`/`transform` when set; `length` still sets a period in pixels along it. A drawn shape's
`shader` takes it too.

**`blurRadius`** on a drawn shape's paint ([DrawPaint]): Flutter's `MaskFilter.blur(BlurStyle.normal, sigma)`, the
sigma worked out as a `BoxShadow` works it out from a blur radius, so a drawing's glow is as soft as a box's shadow of
the same radius. In the drawing's units (it scales with the view box, as a stroke does). The notation writes it beside
`fill=` and `stroke=`, once, and it softens every paint of the op: `circle c=[75,48] radius=28 fill=#CCF59E0B
blurRadius=26`. It may be bound.

Defaults are unchanged everywhere: a document without the new keys reads, draws and prints as before.

## 3. Tests

- codelessly_api `test/notation/stretch_and_clip_test.dart`: each field decodes, round-trips and compares; the
  notation reads `Image … scale= centerSlice=`, `clipPath="…"` and an op's `blurRadius=` and prints them back as
  written; a bad slice or scale, and a `blurRadius` with no paint, are said. The declared-fields walk covers the new
  fields (`test/document/declared_fields_test.dart`).
- codelessly_sdk `test/paint/stretch_and_clip_test.dart`, by pixels and taps: a 30×30 picture with a 10 px frame,
  sliced `[10,10,10,10]`, keeps a 10 px frame at 120×60 and at 240×140 (stretched whole it is 40 px), and at scale 2
  a `[5,5,5,5]` slice is 5 px; a `clipPath` cuts a stack's fill and its child (transparent under the line) and a tap
  under the line passes through while one above reaches the child; a blurred circle is grey on both sides of its
  edge where a sharp one is black and white; an angled gradient runs left to right at 90, down at 180, and corner to
  corner at 45 on boxes of two aspects.
- The reference's new blocks (decoration.md, paint.md, animation.md, charts.md) are read and printed back by the
  generator.

## 4. Open

- A clip in pixels or mixed units (a ticket whose notches stay round at any aspect): a `viewBox` beside `clipPath`,
  as `Path` has, or units in the path.
- Strokes along the clip path: the border is cut by the path, not drawn along it. A shape whose outline is the path
  (fill and border both following it) is the `Path` node; a box with children and a border along a curve is not said.
- Nine-slicing an SVG picture.
- `clipPath` is read where the node's decoration is drawn by its shell: rows, columns, stacks, boxes (an `Image`)
  and inputs with a shell. A text, an icon or a widget drawn by its own recipe does not read it; it is clipped by a
  box around it. Whether the expander should say so is open.
