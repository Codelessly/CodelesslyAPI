# 26. Snapping lists and controls of one's own

The NOCD rebuild (thirty parts of a production app, 2026-11) left a register of what writers could not say. Its
pickers and inputs were: an iOS wheel for times and numbers, a sheet that searches a long list to choose one, a
scrolling multiselect a keyboard can drive, a code field of N slots drawn to a design's measure, a passcode keypad,
and a switch drawn to its own track and thumb. Each was taken apart before anything was built; most were already
the base's, and what the base lacked is four small, generic things.

## What each control is made of

| control | made of | the base had it? |
|---|---|---|
| wheel | a list whose rows have one height, that snaps to a row, reports the row resting at its middle, and draws each row by its distance from the middle; keys that step it while it has the focus | yes: `Pages scrollDirection=vertical peek={1/rows} padEnds=true @value pageMotion={…}`. The keys: no (see 1) |
| searchable selection sheet | an overlay from the bottom, a field, the options narrowed by what is typed, a tap that sets the value and closes | yes: `Sheet`, `Input`, `fuzzy(…)`, `close`. A *word* for it: no, its query state broke the overlay (see 2) |
| scrollable multiselect | a box of its own height that scrolls, rows that toggle membership of a list, one Tab stop moved through with the arrows, the row reached scrolled into view | yes: `Column h=… scroll focusGroup.axis=vertical`, `selected=`, `onTap={… append / without …}` |
| code of N slots | one field drawn as N boxes | the field, yes (`otpLength`); its slots ignored the field's own fill, border and corners and were capped at 48 high (see 3) |
| passcode pad | dots, a grid of keys that append a digit, the keyboard's digits and Backspace | yes: `Grid`, `onKeyDown` reading `result.character`, `key Backspace` |
| switch of its own drawing | a track and a thumb, the value, the switch's role and keys | `Toggle` with `fillTrack`, `thumbInset`, `thumbShadows`, colors; a thumb longer than tall: no (see 4) |

## The four additions

**1. A key of a focused control: `Trigger.focused`.** A key reaction is the screen's wherever it is written, so two
wheels side by side both took ArrowDown. A trigger field, `focused: true` (`onKeyDown(key=ArrowDown,
focused=true)={…}`), makes a keyDown or keyUp reaction run only while the node, or a control inside it, has the
keyboard focus. It is a field of every trigger, so the notation reads and prints it with no word of its own; the
event's `result.focused` says whether the focus was in the node. Any control drawn of base parts uses it: a wheel, a
grid of cells, a slider or a canvas of one's own. The SDK checks the focused control's render object against the
node's box (`ControlFocusScope.focusedScope.focused.owner` is inside it) when the key arrives, and the runner skips
a focused reaction whose event says otherwise. Nothing changes for a reaction without the field.

**2. A word that is an overlay keeps state of its own.** `define SearchSheet … / state query="" / Sheet …` was read
as the sheet's lines drawn in the page: the definition's first line was the state line, so the reader did not see an
overlay. A defined word's overlay is now its first line after its own `state`, `key`, `every` and `on` lines, and
those lines go under the overlay's head, where an overlay's own state lines were already read. Each use's state is
its own (`query_countries`, `query_zones`).

**3. A code field's slots are the field's own box.** The slots took the field's fill, border, corners and height:
`CodeInput … w=300 h=60 radius=12 fill=… border=… focused.border=…` gives five 53.6 × 60 slots, rounded 12, in
those colors. The 48 px cap on a slot's height is gone: a field written taller has taller slots.

The focused look is the active slot's, one rule: while the field has the focus (a pointer's or the keyboard's), the
slot typed into next, and only it, is drawn in the field's focused look: its `focused.` keys (`focused.border=`,
twice as thick, `focused.fill=`), else its decoration's `focusedBorder`, else 2 px in the accent; every other slot
keeps the resting look. A code field's own `focused` state patch is therefore not applied to the whole field
(`NodeTree._patched` leaves it out for a text field with `otpLength`); the field reads the patch itself
(`focusedDecoration`) and draws it on the one slot. (Before: the patch recolored every slot, and with nothing
written the ring showed only when the keyboard brought the focus.)

**4. A switch's thumb length: `thumbWidth`.** The thumb was a circle (or a rounded square) as tall as the track less
its inset. `thumbWidth` is its length along the track, kept between that height and the track's length: a 28 × 20
pill on a 48 × 24 track (iOS 26's thumb is such a pill). The thumb slides the rest of the track. Nothing changes for a
switch without it.

And one easing: **`curve=` beside `animate=`** is the preset's curve (`animate=fadeIn duration=200 curve=easeIn`),
read and printed; on a line with no `animate=` it is said.

## A fling that carries: `snapPhysics`

The model already had the words for a release's motion: `GesturePhysics` (a pan's, a drag source's return, a
transform gesture's): `fling`, `friction` (the share of speed lost a second, Flutter's `FrictionSimulation`),
`spring`, `minFlingVelocity`, `maxFlingVelocity`, and `projectFling`, where friction alone stops a fling. A scroll
that snaps had only Flutter's: a page view one page a fling (`PageScrollPhysics`), a list with `itemSnapping` the
item nearest the platform's coast among the items built. The scroll now takes the same record: `snapPhysics` (a
field of every collection's scroll keys and of the page view). Written `snapPhysics.friction=0.865` or
`snapPhysics={…}`; 0.865 is a phone's deceleration. `snap` and `overscroll` are not read (the items are the snap
points; the scroll's own `physics` keeps its edges).

The rule (SDK `FlingSnapPhysics`, `_FlingLanding`, in `widgets/collections_page_runtime.dart`):

1. **The momentum is the physical one.** The release coasts by its own speed and `friction` (Flutter's
   `FrictionSimulation`, drag 1 − friction), never re-aimed, over as many items as it carries, past items not built
   yet: the list builds them as it passes.
2. **Captured near the end.** Once slower than 60 px/s the coast is captured by the item nearest where it would stop
   (`projectFling` from there), asked at that moment, when the items around it are built and their real extents
   known; not an item behind it. It then comes to rest on that item at a constant deceleration (v²/2d over 2d/v):
   the speed keeps falling to zero with no jump (it is continuous at the capture; only the deceleration changes
   there), and it ends exactly on the
   item. A correction of the target, when real extents differ from the stride guessed earlier, is absorbed in this
   last stretch, which is at most half an item long either way.
3. **The end of the data is a wall.** A coast that would pass the last item stops there.
4. A release slower than `minFlingVelocity` settles on the nearest item on `spring`; with reduced motion it goes to
   the item nearest the projected end on `spring`, with no coast.

A list's stops past its built items are worked out from the stride of the built ones (exact for one item extent);
the capture reads real starts. A page view's stops are `viewportDimension × viewportFraction` apart.

## Rows by angle: what a row is driven by, depth, one camera

A page of a page view reads `pageOffset`: its signed distance from the page at rest, in pages, continuous as it
scrolls and not clamped (the two-page clamp is `pageMotion`'s, a one-record shortcut). A formula on any key of the
page's line reads it, so every motion key follows it: `motion.translateX`, `translateY`, `translateZ`, `shiftX`,
`shiftY`, `scale`, `scaleX`, `scaleY`, `rotate` (z), `rotateX`, `rotateY`, `perspective`, `alignment`, `path` (a
translate along a path), and `opacity`. A writer bounds it with a formula (`clamp(pageOffset, -3, 3)`).

**`translateZ` (added).** A motion's translate toward the viewer (positive) or away (negative), in pixels, as CSS's.
The motion's matrix is, outermost first: the perspective (the node's own `perspective`, applied when it turns in 3D
or moves in depth), the translation (x, y, z), the scale, then the rotations about z, x and y, about the node's
`alignment`. A page view's camera (`perspective` on the `Pages`) is outside every page's own matrix, about the view's
middle. So a node pushed away by z under a perspective p (0.0012 × `perspective` a pixel) is drawn smaller by
1 / (1 + p·z) toward its own middle (pinned by a test), and a drum's row is seen from the view's middle.

**The drum.** On a drum of radius R (half the wheel's height), rows h apart, a row d rows away is at θ = d·h/R:
`motion.translateY={R*sin(θ) - d*h}` (the page view lays it at d·h), `motion.translateZ={R*(cos(θ) - 1)}` (it
recedes), `motion.rotateX={-θ in degrees}`, faded out by 90°. Seen through the view's camera (`perspective=2` on the
`Pages`, the rows' own `motion.perspective=0`), a point c from a row's middle is drawn at (R·sin θ + c·cos θ) /
(1 + p·(R(1 − cos θ) − c·sin θ)) from the view's middle (pinned for rows 0 to ±3 within half a pixel); the row at rest
is not moved, exactly the band's size. Flat (`perspective=0`) the rows are at R·sin θ and h·cos θ tall (pinned too).
Looked at side by side, the camera reads as a drum (rows shrink and crowd toward the edges, as a phone's wheel) where
flat reads as a band of squeezed rows; the `Wheel` word draws through the camera (`depth=2`) and keeps flat as
`depth=0`. The same reading gives a cover flow (`rotateY`, `translateX`, `translateZ` by distance), a tilting
carousel, a stacked deck (`translateY`, `translateZ`, `scale`).

## The value while it turns

The bound page (`@value`) changes as each row passes the middle (the page view's `onPageChanged`), so a text bound to
a wheel's value follows a spin row by row: kept as it was, by the owner's decision. Added beside it: the page view's
`scroll` reaction gives `result.page` (a decimal: the position between rows, as it moves; it was there) and now
`result.index`, and the page view reports where it comes to rest on `scrollEnd` (`result.page`, `result.index`,
`result.offset`; it had none). Each is fired once a frame while it moves. Pinned: during one fling a bound text takes
more than eight values, and a variable set from `result.page` only moves on, through decimals.

## A list item's distance (a stand-in)

A row of a `ListView` (or an `each` list) with `itemSnapping` reads `pageOffset` too: its signed distance from the
list's snap point (the start of the view, where it rests a row), in rows: 0 at rest, a fraction mid-scroll. The same
word as a page's, because it is the same meaning (distance from where the scroll rests an item, in items).

**This is a compatibility layer, the stand-in until the SDK has its own list.** The list is still Flutter's
`ListView`, so the distance is worked out from outside it (SDK `collections_data_list.dart`, "an item's distance from
the snap point", marked STAND-IN): the built rows' starts as the viewport reports them, each row's extent from its
laid-out box, set on each row's item scope as the list scrolls (the controller's listener) and after each frame. What
a list of our own would give that this cannot:

- **Unbuilt items.** Only built rows have a distance; a row is given an estimate from the built rows' stride when it is
  first built, made exact after its layout.
- **Extents known ahead.** A row's extent is known only once laid out, so a new row's first frame may read an
  estimate, and the fling's stops past the built rows are a stride guess (the capture rule above absorbs it).
- **Per-item rebuild cost.** Every changed distance notifies the row's scope and every box reading it re-applies,
  per row per frame while the list moves; a list of our own would pose its rows in its own layout pass.

This is a plain example of why the SDK needs its full API set: its own list, laying out and posing its items.

## What stays data

The controls themselves are words of the project dictionary (`vocabulary/words/`): `Wheel`, `TimeWheel`,
`SearchSheet`, `MultiSelect`, `PasscodePad`, and the names the parts asked for that the base says another way:
`Spinner` (`CircularProgressIndicator w= h=`), `TextArea` (`Input minLines= maxLines=0`), `Wrap` (`Row wrap=true`).
A switch of its own measure is the base `Toggle` line, written out in forms.md.

## Open

- A list item's distance and a list's fling stops past its built rows are the stand-in described above, until the
  SDK's own list.
- A wheel's adjustable screen-reader role: set aside by the owner.
