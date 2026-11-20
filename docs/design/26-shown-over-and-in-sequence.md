# 26. Shown over everything, and in sequence

2026-11-20. Built: a banner a document can show (`presentation=banner`, over everything, one at a time,
`closeAfterMs`), `after=` on an animation (this starts when that ends), `transition property=layout` (a box that eases
to its content's size), `transition property=decoration` on a text field's frame, `enterScale` on an anchored
popover, play keys that read values, and `${result.cancelled}` on a drag's end.

The NOCD rebuild's register ("The base lacks it") listed overlay, motion and gesture capabilities writers could not
say: a branded toast, a popup anchored to its button, a box whose height animates, input transitions per state, a
wizard's directional steps, a cancel at pointer level, a toast's outward swipe and timer, and from the chat pilot an
overlay's content that starts when the lift lands, a menu that grows out of its opener and a drag-down dismissal that
follows the finger. The owner: "the actual toast is a behavior: the show anything over everything else + animation".
Each was decomposed first; what composed is a dictionary entry (`vocabulary/behaviours/`), and only what could not be
said is built here.

## 1. What composed (nothing built)

| Wanted | The lines |
|---|---|
| A popup by its button, flipping at the screen's edge, with an arrow | `Popover#zones arrow` (or `Menu#x above end`, `placement=`): the anchored layout already flips and keeps it on screen |
| A drag-down dismissal that follows the finger, shrinking, returning or closing | `pan.axis=vertical pan.minY=0 pan.yVariable=pullY pan.y={restY} motion.scale={1 - min(max(pullY,0),400)/2000} onPointerUp={pullY > 80 ? {restY=pullY; close} : {}}` on the overlay's content; the lift flies back from where it is drawn |
| A wizard's steps by direction (screens) | `go step2 transition=slideLeft`, back `navigate mode=pop` (a pop reverses the push) |
| A close target bigger than its glyph | a 36x32 `Column center middle onTap={close}` around an `Icon "close" size=12` |
| Independent guards | `barrierDismissible=false`, `guard={…}`/`blockBack`, `onBackPressed={…}`, `showDragHandle`: each its own key |

## 2. What is added, and why this form

**`presentation=banner` in a document.** The API declared it (no barrier, the app usable, a swipe away) but only
`Codelessly.present` drew it; inside a document it was a centred dialog. Now any screen opened so is shown in the
root overlay, above every route and barrier, without one of its own; it slides in along its edge (or as its
`routeTransition`'s `enter` side says: the record every route already has), follows the finger on a swipe toward
its edge (`routeTransition.dismiss.direction` to choose another), and banners show one at a time in the order they
were opened (a queue per overlay). The chain that opened it reads what closed it (`${result}`), so dismissal reasons
and "queue callbacks" are the chain itself. No `Toast#id` word: a toast is a screen shown this way, and its look is a
dictionary word (`BrandedToast`) the writer puts in that screen.

**`closeAfterMs` on `openModal`.** "A stay": closes itself, with no result, that long after it came in; the clock
holds while it is pressed or dragged (the register's "per-pointer-state timer"). On every presentation (a dialog
that confirms and goes by itself), not a toast key. Rejected: `delay ms=3000; close` in the screen's `on load` (the
old way): it cannot hold while pressed, and it repeats a number the opener owns.

**`after=<id>` on an animation.** "A sequence: this starts when that ends." An autoplaying animation waits at its
start until node `<id>` has settled: its own entrances and the animations inside it ended, and a lifted node in it
(`hero.flies=lift`) landed; then its `delay` counts. It replaces repeating the flight's 335 ms as `delay=335` on
every menu line, and composes with any entrance (a card after a header, a pill after a bubble). Rejected: a hero
value the overlay reads (`landed`), which would serve the lift only, and cross-node expressions.

**`transition property=layout`** (`layout.width`, `layout.height` for one side). Note 03 had reserved it ("animates
size like `AnimatedSize`") and nothing drew it. The box eases from its drawn size to its content's new size and lays
its content out at the size drawn, so its own fill, border and corners follow (as a CSS height transition); what
doesn't fit yet is clipped (the flex's overflow report is quiet while it eases). `*` does not ease size: a page that
eased "every path" keeps what it drew. Rejected: `animateSize anchor=…` (a second key family for one concept the
transition list already has).

**`transition property=decoration` on a text field.** The field frame's border and fill switch between enabled,
hovered, focused, error and disabled looks; it now eases between them over that transition (none: at once, as
before). The decoration is the field's own key (`decoration.focusedBorder…`), so the transition names it.

**`enterScale` on an anchored popover.** The key existed for dialogs (`showScreenModal`); an anchored popover grows
from it about the middle of the node that opened it, so a menu grows out of its button wherever the flip put it.
Unset (1), it comes as before.

**Play keys that read values, and `${result.cancelled}`.** An `animation` line's `playKey={step}` was written into
the field as `${…}` and never worked out: now it is, and the animation plays when the values it reads change (the
in-page wizard: `playKey="s{step}"` with `track from={dir * 342}`). A drag's end carries `cancelled` as a pointer's
up already did (`onPointerUp={result.cancelled ? close : commit}`, documented now).

## 3. What composes with it

A branded toast over a dialog: `openModal to=saved presentation=banner closeAfterMs=3000` and a `Canvas#saved` whose
line is `BrandedToast`. A queue: open several; they show in turn. The chat's press overlay: `animate=scale after=
liftedBubble` on the pill and the menu, `stagger=15` on the emoji, `pan` and `onPointerUp` for the drag. An
accordion: `transition property=layout` on the box, `if open` under it.

## 4. Open

1. Should a banner shown before a dialog stay above that dialog's barrier (it does: it is over everything), or go
   under it as a toast does today (`ToastBelowRoute`)?
2. `after=` names one node; a sequence of three is three lines each naming the one before. An `after` that names
   an animation of a node (`after=card.enter`) was not needed.
3. The drag-down dismissal composes with variables (`pullY`, `restY`); a `dismissible` record on an overlay's content
   that drives the route's own fade with the finger would say it in one key.
4. System insets (`screen.safeTop`, the keyboard's height) are not values yet; overlays apply them themselves.
