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
item nearest the platform's coast. The scroll now takes the same record: `snapPhysics` (a field of every collection's
scroll keys and of the page view). With it a release coasts by its speed, slowing by `friction`, over as many items
as it carries, and rests exactly on the item nearest `projectFling`'s end: the coast is aimed at that item (the drag
that stops it there) and handed to `spring` for its last stretch once slower than 60 px/s, so it lands on the row
boundary. A release slower than `minFlingVelocity` settles on the nearest item on the spring; with reduced motion
it goes to the same item on the spring with no coast. `snap` and `overscroll` are not read (the items are the snap
points; the scroll's own `physics` keeps its edges). Written `snapPhysics.friction=0.865` or `snapPhysics={…}`;
0.865 is a phone's deceleration. SDK: `FlingSnapPhysics` in `widgets/collections_page_runtime.dart`, used by the page view
(pages a `viewportDimension × viewportFraction` apart) and by a list's `itemSnapping` (its items' starts).

## Rows by angle: what a row is driven by, and one camera

A page of a page view already reads `pageOffset`: its signed distance from the page at rest, in pages, continuous as
it scrolls and not clamped (the two-page clamp is `pageMotion`'s, a one-record shortcut). A formula on any key of the
page's line reads it, so every motion key follows it: `motion.translateX`, `translateY`, `shiftX`, `shiftY`,
`scale`, `scaleX`, `scaleY`, `rotate` (z), `rotateX`, `rotateY`, `perspective`, `alignment`, `path` (a translate along
a path), and `opacity`. A writer bounds it with a formula (`clamp(pageOffset, -3, 3)`). That is the distance value:
nothing new was needed to drive a row by it.

A drum of radius R (half the wheel's height) with rows h apart puts a row d rows away at the angle θ = d·h/R: at
`R·sin θ` from the middle (the page view lays it at d·h, so `motion.translateY={R*sin(θ) - d*h}`) and turned by θ
(`motion.rotateX={-θ in degrees}`); seen from afar (no perspective) it is h·cos θ tall. The rows crowd and flatten
toward the top and bottom, and past 90° they are faded out. The same reading gives a cover flow (`rotateY` and
`translateX` by distance), a carousel that tilts, a stacked deck (`translateY` and `scale`).

What was missing is perspective said once for the list. A motion's own `perspective` sees each row from its own
middle, so rows on a drum or covers in a flow each have their own vanishing point. The page view's `perspective`
key is one camera at the view's middle for every page (the pages write `motion.perspective=0`): the SDK wraps each
page in the perspective about the view's middle, so a page's own turn is seen from there. 0 (the default) draws
the turns flat. The `Wheel` word draws its drum flat, as the cylinder's own geometry (the test pins rows 0 to 3 at
R·sin θ and h·cos θ); the camera is for a flow or a tilt that wants depth.

## What stays data

The controls themselves are words of the project dictionary (`vocabulary/words/`): `Wheel`, `TimeWheel`,
`SearchSheet`, `MultiSelect`, `PasscodePad`, and the names the parts asked for that the base says another way:
`Spinner` (`CircularProgressIndicator w= h=`), `TextArea` (`Input minLines= maxLines=0`), `Wrap` (`Row wrap=true`).
A switch of its own measure is the base `Toggle` line, written out in forms.md.

## Open

- There is no translate in depth (`translateZ`) among the motion keys, so a drum's rows do not recede as they turn;
  with a camera they are tilted in perspective but stay at the drum's front. A true 3D drum seen in perspective
  needs `translateZ` (R·cos θ − R) beside `rotateX`; not built.
- `pageOffset` is a page's; an item of a `ListView` with `itemSnapping` has no distance from its snap position to
  read. Not built (the wheel is a page view).
- The page view reports the page under the middle as the coast passes it (`@value` changes mid-spin), not only when
  it rests.
- A list's `snapPhysics` aims at the nearest start among the items it has built; a fling past them rests on the
  last built one.
- A wheel's adjustable screen-reader role: set aside by the owner.
