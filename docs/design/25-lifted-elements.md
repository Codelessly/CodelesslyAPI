# 25. Lifted elements

2026-11-19. Built: `hero.flies=lift` and three keys of the long-press trigger (`holdMs`, `commitMs`, `haptic`).
The owner, on the NOCD chat's long-press menu: "we aren't limited to Flutter's Hero widget framework anymore, we
can reengineer the base behavior, and also because we use renderobjects directly, we can apply any animation to
any widget. So we can easily do the long press popout iOS iMessage behavior. Can you try with our current API? If
we can't do that, we need to take a look at our APIs and build a system in that lets us do so."

The behaviour, measured from the app (`experiments/nocd-chat/audit/02-items-and-visuals.md` section 4): hold a text
bubble 800 ms (a heavy haptic at about 400 ms, after which letting go no longer cancels; nothing scales); the
backdrop blurs (sigma 5) and tints `#04040F` at 40%; **the same bubble** travels from its row to a centred place
over the backdrop, 335 ms ease-out, drawn above the blur; a menu grows in under it and an emoji pill above it;
tapping the backdrop or dragging down sends the bubble back to its row (ease-in), where it shows again.

The essential capability is the middle one: a node drawn in one place of the tree (a row of a scrolling list) is
lifted out and animated to another place and size above everything, and back, as one continuous element.

## 1. What the notation could say before (tried, `experiments/nocd-chat/lift-try/`)

A list of twelve bubbles, one held, rendered headless with frames in flight (section 6 says how).

| Attempt | File | How far it got | What stopped it |
|---|---|---|---|
| `onLongPress={…}` | (build-1) | opens at Flutter's 500 ms | no duration, no commit point; the haptic is an action at the end |
| `onHold(holdMs=800)` | `t2-measure.txt` | fires at 800 | letting go always cancels (no commit point); the render driver held 700 ms, so it never fired there; a haptic at 400 cannot be said (`onPointerDown={delay ms=400; haptic …}` cannot be cancelled by a lift) |
| A copy at measured coordinates (`measure` on every bubble, the copy in the overlay at `x`, `y` bound, a number variable animated 0 to 1) | `t2-measure.txt` | the overlay opens; the copy is drawn | `measure.key` does not take a binding: every row writes the same key, so the box measured is the last row's. The copy is laid out at width 0 |
| The same, the place taken from the press (`onPointerDown={ox=result.globalX - result.x; …}`) | `t2b-pointer.txt` | the copy starts on the row and slides to the centre over the blur; the row is hidden by `opacity` | a copy, not the node: its size is guessed (no width), it is drawn inside the dialog (it fades in with it), the way back must close the overlay after the animation by hand and the copy's data clears as `pressedId` resets; a scroll is not followed; about 8 lines of plumbing per use |
| A `transition property=layout` on the copy's bound `y` | `t3-transition.txt` | the copy moves | the same, and the dialog's own coordinates (its safe area) are not the screen's: it lands off |
| `hero.flies=inPlace` on the row and on the overlay's copy, the row's tag cleared while pressed | `t1-hero.txt` | nothing flew | a bound `hero.tag` dropped the hero's record: the notation writes the tag as a binding and the record without it, and `HeroTag.fromJson` read a record with no tag as no hero (fixed, section 5). Even with that: an in-place hero flies only from a node no longer shown, is drawn inside its own (fading) overlay, and has no way back |
| `hero` between screens | — | | flies only while a navigation's route animates, from one screen to the next; a dialog over the same screen is not a navigation of a page route with its own tree |

The long press and the lift are separate findings: the first lacked three keys; the second lacked a way to say
"this node, lifted out of that place, above everything, and back", which every attempt rebuilt by hand and none
reached (the node is never the same element, never above the overlay's fade, never followed, never returned).

## 2. The capability

**A third way a hero flies: `lift`.** Two nodes with the same `hero.tag` are one element. Of those shown, the newest
is the one drawn; when that changes, the element flies between their places:

- **Out.** When a node with the tag comes on screen while another is shown (on the same screen, a screen under it,
  an overlay under it), the element flies from that node's place to its own, **drawn above everything** (above
  every route and an overlay's backdrop: in the navigator's overlay). The node it left keeps its place, hidden:
  a gap that keeps the list's layout, takes no taps.
- **Back.** When the node shown goes (its overlay closes and starts to fade, it is removed, its tag changes), the
  element flies back to the one under it, which shows again as it lands. Turned round mid-flight, it goes back
  from where it is drawn.
- **Both ends are followed** every frame: a list that scrolls under the flight is landed on where the row is now.
  If the place it flies to goes while it flies (its row removed), the flight ends there.
- **Timing** is the hero's existing `flight` record: `duration` and `curve` (default 300 ms ease-in-out); the way
  back plays the curve backward (an `easeOut` out is an `easeIn` back, as the app does). Its path is straight.
- **Reduced motion** (the platform's): it does not fly; the ends switch at once.
- **What flies** is the drawing of the node it flies to, fitted to the box in between (the overlay's bubble on the
  way out, the row's on the way back), so a node that differs at its two ends lands as itself.
- Lifted heroes find each other only, as in-place heroes do.

A writer's lines for the bubble (the component's bubble, called once in the row and once in the overlay):

```notation
Column#bubble … hero.tag="m{props.m.id}" hero.flies=lift hero.flight.duration=335 hero.flight.curve=easeOut onLongPress(holdMs=800, commitMs=400, haptic=heavy)={pressedId=props.m.id; open press}
Dialog#press …
  MessageBubble m={held} lifted=true
```

A photo to its viewer (the same two lines, nothing else):

```notation
Image "{p.url}" w=280 h=210 radius=10 hero.tag="photo{p.id}" hero.flies=lift onTap={viewer=p; open viewer}
Lightbox#viewer
  Image "{viewer.url}" w=fill h=fill fit=contain hero.tag="photo{viewer.id}" hero.flies=lift
```

A card to its detail screen, a row to a sheet, an avatar to a profile header: the tag on both, `flies=lift`. It
composes with what exists: the overlay is still a `Dialog`, `Sheet`, `Menu`, `Popover` or a screen; its backdrop,
`animate=` entrances on the menu and the pill, `transition` lines and tracks all run as before; the lift only
decides where the shared node is drawn while it moves.

**The long press**, as fields of the trigger it already is (`onLongPress(…)`, `onHold(…)`), each generic:

| Key | Meaning |
|---|---|
| `holdMs` | a long press held this long (it was the hold trigger's only); unset, the platform's 500 ms |
| `commitMs` | from this many ms the press is the node's: letting go no longer cancels it, a scroll can no longer take it (a long press wins the gesture arena), and it still fires at `holdMs` |
| `haptic` | a buzz (`selection`, `light`, `medium`, `heavy`, `vibrate`) as the gesture becomes sure: at `commitMs`, else as it fires; any pointer trigger takes it (`onTap(haptic=selection)`) |

## 3. Why this form

| | What pairs the two | When it moves | Where it is drawn | Back |
|---|---|---|---|---|
| Flutter `Hero` | a tag on two routes | while a navigation animates | the navigator's overlay | on pop |
| FLIP (web) | the same element measured before and after a change | after any change, by hand | in place (a transform) | by hand |
| CSS view transitions | `view-transition-name` on old and new | around a DOM update | a top-layer pseudo tree of snapshots | another transition |
| SwiftUI `matchedGeometryEffect` | an id in a namespace, `isSource` | any state change | in place, each view in its own tree | the reverse change |
| **`hero.flies=lift`** | a tag on two nodes (any trees) | when the shown one changes | above everything (the navigator's overlay) | when the top one goes |

It is the view-transition idea (a name on two things, a flight drawn on top) with the hero's existing key, so no
new word: a node already says it is a shared element by `hero.tag`; `flies` already says *when* it flies, and
`lift` is one more answer that a writer reads as what it does. Rejected:

- **A `lift=` key or a `Lift` word** naming the iMessage behaviour: a named presentation whose meaning is hidden,
  and a second key for one concept (note 04 merged `flightKey` into `hero` for that reason).
- **Making `lift` the default of `hero`** (the owner's "reengineer the base behavior"): it changes what every
  existing hero does (a between-screens hero would hide its source while the next screen shows, which a page
  under a page never sees anyway, but in-place flights and their tests would change). Section 7 asks.
- **One node drawn in two places** (the overlay showing the row's own render object): the row's node would be
  painted by two parents, and hit-tested, laid out and disposed by one; two nodes with one tag keep each tree
  whole and let the two ends differ (the overlay's bubble is centred, without its time label).
- **An action** (`lift node=bubble to=slot`): imperative, and the way back would be a second action every close
  path must remember (barrier, swipe, back key, a menu row).

## 4. What it is built from (SDK)

`render/hero.dart`: a lifted hero gets the same `RenderHeroMark` a between-screens one has, now with its `flies`,
its `flight`, its order of arrival and `liftShown` (drawn only when it is the shown one and not flying; else it
keeps its size and draws nothing, takes no hit). `app/ui/hero_flights.dart`: `HeroLifts` looks at the lifted marks
after each frame (a closing route changes no mark, so it looks every frame while lifted marks exist), and on a
change flies a `_Lift` in the navigator's overlay on its own ticker, both ends read each tick; between-screen
flights ignore lifted marks. `runtime/actions/wiring.dart`: a long press with `holdMs` set uses Flutter's
recognizer with that duration; with `commitMs`, a recognizer that wins the arena at the commit point and fires at
`holdMs` (a hold's timer is no longer cancelled after it; a hold is not in the arena, so a scroll can still take
it); `haptic` buzzes at the commit point or as the trigger fires.

## 5. Also fixed

`HeroTag.fromJson` read a record without a `tag` as no hero, so any hero whose tag is bound (`hero.tag="m{id}"`,
the notation writes the tag as a binding) lost its `flies`, `flightShuttle` and `flight` and became a plain
between-screens hero. A record with other fields now reads with an empty tag (the binding fills it), and writes
no `tag` while it is empty.

## 6. The render tool

`--long-press <id>=<ms>` holds that long (default 700 as before, now pumped frame by frame); `--frames
0,100,200,335` captures what the step before started, one PNG at each time after it (that step does not settle
first), named `-f<n>-<ms>ms.png` for the n-th burst of the run.

## 7. Open

1. `lift` beside `betweenScreens` and `inPlace`, or `lift` as the base behaviour of every hero?
2. The word: `lift` sits beside the Flight record's `lift` (the arc's rise in px). `fromShown` or `over` would avoid it.
3. The drag-down dismissal follows the finger in the app (scale 0.8 to 1, damped sideways); here `onSwipeDown={close}`
   closes on a swipe and the bubble flies back. A lifted node that follows a drag is the next step (it is the
   `pan`/`dismissible` gesture applied to the overlay's node; the lift already lands from wherever it is drawn).
4. The menu "grows from the bubble's corner": an `animate=scale` with an alignment is close; its origin moving
   with the bubble is not said.
