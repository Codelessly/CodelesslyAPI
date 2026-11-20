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
those colors; the slot typed into next is drawn in the focused border twice as thick (or the decoration's own
`focusedBorder`). With nothing written the slots are as before (the theme's surface and border, 32 high where the
field hugs, the accent ring only when the keyboard brought the focus). The 48 px cap on a slot's height is gone: a
field written taller has taller slots. Open: `focused.border=` recolors every slot while the code is typed, not the
active one only (the state patch replaces the field's border; the resting border is not kept apart).

**4. A switch's thumb length: `thumbWidth`.** The thumb was a circle (or a rounded square) as tall as the track less
its inset. `thumbWidth` is its length along the track, kept between that height and the track's length: a 28 × 20
pill on a 48 × 24 track (iOS 26's thumb is such a pill). The thumb slides the rest of the track. Nothing changes for a
switch without it.

And one easing: **`curve=` beside `animate=`** is the preset's curve (`animate=fadeIn duration=200 curve=easeIn`),
read and printed; on a line with no `animate=` it is said.

## What stays data

The controls themselves are words of the project dictionary (`vocabulary/words/`): `Wheel`, `TimeWheel`,
`SearchSheet`, `MultiSelect`, `PasscodePad`, and the names the parts asked for that the base says another way:
`Spinner` (`CircularProgressIndicator w= h=`), `TextArea` (`Input minLines= maxLines=0`), `Wrap` (`Row wrap=true`).
A switch of its own measure is the base `Toggle` line, written out in forms.md.

## Open

- A wheel's drum is `pageMotion`, interpolated by distance and clamped at two rows: with seven rows the outer two are
  drawn as the two inside them. A true cylinder (rows spaced by the sine of their angle, not evenly) would need the
  page view to place pages by angle. Not built: the clamp could become a field of the page view if a design needs
  seven rows.
- A wheel reads to a screen reader as a button with its middle row's text, not as an adjustable control
  (VoiceOver's increment and decrement). An adjustable role (`semantics.adjustable` with increase and decrease
  actions running two reactions) is the generic addition; not built here.
- Fling physics are the page view's (Flutter's page physics): a fling comes to rest one row past where the finger
  let go, not with a wheel's momentum over many rows.
