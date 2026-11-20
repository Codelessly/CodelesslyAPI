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

**A node cut to a shape** ([Decoration]: `clipPath`, `clipViewBox`, `clipFit`, `clipCuts`). The owner, on the first
version: "Whatever makes the clippath work as expected when used", and "Clip should work on text and icon right?
That's how Flutter's Clip widget works."

- `clipPath`: SVG path data, CSS `clip-path` and Flutter's `ClipPath`. Its units are `clipViewBox`'s, mapped onto the
  box by `clipFit`, exactly as a `customPaint`'s `viewBox` and `fit` are (same reader, same mapping, centered). With
  neither, the unit square stretched over the box (one wave for every width). `clipFit=none` with no view box: the
  box's own pixels from its top left (as a `customPaint` or a `Path` without a view box).
- `clipCuts`: shapes cut out in the node's own pixels at points of its box (`{"center": "centerLeft", "radius": 12}`
  a circle; `{"center": "topRight", "d": "…"}` path data with its origin there), from `clipPath` when there is one,
  else from the node's own shape (its `radius`, its circle). This is the smallest generic form for the case a single
  coordinate space cannot say: a body that stretches with notches that keep their size (a ticket that grows, a card
  with a bite). One path in one space either stretches the notches (unit space) or cannot follow the box's far edges
  (pixels); edge-relative path commands would be a second path grammar. A cut anchored at an alignment is how the base
  already places things (a radial gradient's `center`, a particle origin). `Path.combine(difference)` in the SDK.
- What is cut, uniformly for every node type: what it paints and its children; the hit test follows the shape (a tap
  in a notch passes through). Its **border** is drawn along the shape, inside it, at the border's width (the stroke
  doubled and clipped), over the content as a shell's inside border is; its **drop shadows** take the shape (the shape
  offset and blurred, a spread drawn as an outline that wide, in a layer of the shadow's alpha), painted outside the
  cut. The shell draws neither for such a node.
- **One common place.** The clip is applied in the node box's chain for every type alike (`_clipLayers` in
  `node_tree.dart`): inside the node's motion (it moves and scales with it), outside its reactions (so the tap test
  follows the cut), around its blurs, custom paint and content. A text, an icon, a picture, a control drawn by its
  recipe, a list, a component call, an external widget all get it without per-type code. `clip=` (to the corners or
  the circle) now also works on every type from the same place; a node its shell draws (rows, columns, stacks, boxes,
  inputs in a shell, the canvas) keeps the shell's `clip`, which leaves its BoxDecoration shadow outside the cut as
  before. The model keeps the clip keys (`clip`, `radius`, `shape`, `clipPath`, `clipViewBox`, `clipFit`,
  `clipCuts`) on an undecorated type's node; the notation takes them on any line (`DecorationFields.undecorated`).
  A platform view the host composites (a video, a web view) is cut where the host supports clipping platform views;
  it is not special-cased.

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
- The clip follow-up, same files. API: `clipViewBox`/`clipFit`/`clipCuts` decode, round-trip and compare; written on a
  line and printed back (`Stack … clipCuts=[…]`, `clipViewBox=[300,120] clipFit=contain`); a `Text` and an `Icon` line
  take `clipPath=` and `clipCuts=`; a text node read from JSON keeps its clip, radius and clip path but no fill. SDK, by
  pixels and taps: a ticket's 12 px notches are round circles at 160×80 and at 320×200 (transparent 1, 6 and 10 px in
  on the middle line and 9 px above it 3 px in; filled 14 px in and 14 px above); a red 3 px border runs along the
  notch inside it and along the top edge, the fill inside it; a shadow with no fill over it fills the body and not the
  notch; a tap in a notch passes through and one on the body counts; a text, an icon and a picture cut to their left
  half draw in it and nothing in the right; a button cut so counts a tap in its left half only; `clipFit=none` cuts
  at 50 px, and `clipViewBox=[100,100]` stretched over 200 px cuts at 100.
- The reference's new blocks (decoration.md, paint.md, animation.md, charts.md) are read and printed back by the
  generator.

## 4. Open

- Nine-slicing an SVG picture (the owner: leave it).
- A border along the shape is always inside it (`strokeAlign` center and outside would draw past the cut) and solid
  (`dashPattern` is not read along a shape yet).
- A text's or an icon's drop shadow (`effects`) is kept only with a clip shape (it then takes the shape); before,
  shadows on undecorated types were dropped, and still are without one.
- Changed, pinned by a test: `keys_test` said `Text shape=circle` is "no shape"; a text now takes `shape` (and
  `radius`, `clip`) for its clip. The test now pins a box-only key (`strokeSides`) instead.
