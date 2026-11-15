# 16. The design pass: fast first, then designed

Status: proven on inline cards and on full mobile and desktop pages (2026-11-15). This document is the architecture
as it runs today, what each agent is given word for word, and three complete examples.

## 1. What it is

A UI is written twice over by two different agents with two different jobs.

1. **The composer** (a Sonnet-level model) answers the user. It writes the UI in the compact notation
   (design 13) from plain parts and whatever blocks fit. The UI is drawn line by line as it streams, so the
   user sees a working card within a few seconds. It is correct and it looks generic.
2. **The design agent** (a stronger model, or the same tier with a designer's brief) is then shown that UI, as
   a picture and as its nodes, and answers with **edit operations** that restyle it where it stands. The
   session applies them to the UI on screen. Nothing is written again.

The split is the point. The composer decides what the UI says and does and is never asked to design. The
design agent decides how it looks and is not allowed to change what it says or does. Each is checked for its
own job.

## 2. The four ways a UI gets made

| | Who writes | What they write | Time to first UI | Look | Use it when |
|---|---|---|---|---|---|
| 1. Plain parts | Composer | Notation: `Card`, `Row`, `Text`, `Button` | Seconds | Clean, generic | A draft, or the first frame of 4 |
| 2. Designed blocks | Composer | Notation calling a design system's blocks by name | Seconds | Designed, where a block exists | The request fits the blocks the system has |
| 3. Full vocabulary | Designer, offline | A whole document, every node and property | Minutes | Anything | Making a block (once), or a screen with no time limit |
| 4. **Design pass** | Composer, then design agent | Notation, then edit operations on it | Seconds, then restyled about half a minute later | Designed, for any request | The request fits no block, or blocks cover only part of it |

Two further links between them:

- **A block designed on demand** (design 15 §4.17) is path 3 run in the background for one missing piece and
  kept in the library, so path 2 covers more next time.
- **The design pass is what makes the rest safe to leave plain.** Without it every request the blocks do not
  cover falls back to path 1's look.

## 3. How one request runs

```
user request
   │
   ▼
composer ── notation, streamed ──► session ──► card on screen (plain)      t ≈ 3–9 s
                                      │
                                      │  nodes + render (light, dark, 320 wide)
                                      ▼
                               design agent
                                      │  {"ops": [patch, set, move, remove …]}
                                      ▼
                                   session.apply(ops) ──► same card, restyled     t ≈ +20–30 s
                                      │
                                      │  checks (§5); on a problem: one more round with
                                      │  the new render and what broke, or keep the plain card
                                      ▼
                                 kept or undone (one undo step)
```

- The composer's answer and the pass are two revisions of one session. The pass is one undo step:
  `UiSession.undo()` puts the plain card back.
- The pass patches nodes by id. State, variables, bindings and actions are not in the operations at all unless
  the design agent breaks its brief, and the checks catch that.
- A second user turn that changes the card (the composer patches it) lands on the restyled card: the ids are
  the same.

## 4. What the design agent is given

One system message and one user message. The system message is built by
`CodelesslySDK/examples/showcase/tool/style_pass.py` (`brief` prints it for any card without calling a
model). Its parts, in order:

| Part | Content | Why |
|---|---|---|
| Role | "You are the art director of the «name» design system: «its description». A fast model has just written a card from plain parts and it is on screen now. It is correct and it looks generic. You restyle it IN PLACE, by edit operations on its nodes." | Sets the job as restyling what exists |
| What must not change | Every text, number and label; every binding; every action, variable, node id and node type; the order of content unless layout needs it | The composer owns meaning and behavior |
| What may change | Layout (padding, spacing, alignment, sizes); decoration (fills, strokes, radius, shadows, the card's surface); text style; structure for looks (wrap nodes in a new row, column or box; add a divider, an icon, an accent bar, a tinted panel) | The design agent owns appearance |
| The aim | "One focal value or title, calm secondary detail, grouped rows on a quiet panel, generous and even spacing, the one main action clear… It must hold in dark mode and in a 320-wide column." | A rubric short enough to be followed |
| The system's principles | The design system's `DESIGN.md`, whole | The look is the system's, not the agent's taste |
| Theme names | Every color, text style, radius and shadow name the theme has, and how each is written (a color by name; a text style as `{"from": "name"}`; a radius or shadow bound: `"bind": {"decoration.radius": "${theme.radii.card}"}`) | Names follow light and dark and a later re-theme; literals do not |
| One block of the system, as written | The nodes of `StatTile` | Shows the shape of layout, decoration and text style in this system |
| The edit operations | Each operation's own description and example, printed from the API (`tool/notation/notation.sh apply --reference`): `set`, `patch`, `move`, `remove` | The answer format is the engine's own |
| The card now | Its nodes as JSON, and the canvas id | What the operations address |
| What the user asked for | The request text | So emphasis follows intent |
| Answer | "Two or three sentences on what you change and why. Then one ```json fence holding {"ops": [...]}… Patch what exists; set only what is new." | One parseable answer |

The user message is three pictures: the card as it is on screen in light, in dark, and in a 320-wide column.

After a round, when anything was reported, the agent gets the three pictures of its result and the list of
problems, and answers with the single word `SHIP` or with the whole list again, corrected (a round replaces
the last; it is applied to the card as it was before the pass).

### DESIGN.md

`DESIGN.md` is a design system's file of principles: about 600 words for Cards. It is the one document both
designers read, the block designer (design 15 §4.9) and the design agent. For Cards it holds:

- **In brief**: the look in a paragraph (a white rounded card, one accent, quiet tinted panels, large numbers).
- **Tokens**: the surfaces (`page`, `card`, `tile`, `line`), the ink scale, the accent and its tints, the
  semantic tones, radii (`card`, `tile`, `chip`, `cta`), shadows, the type scale by role.
- **Where the neutrals come from**: the exact gray and dark values, so nothing is invented.
- **Do and do not**: one primary action a card; never a literal color where a token exists; no borders where
  a tint separates; numbers lead, labels are quiet.

`PATTERNS.md` (about 1,000 words) is the composer's counterpart: which blocks go together for which request.
A design system that wants the design pass needs `DESIGN.md`, a theme with named colors, text styles, radii
and shadows, and at least one block to show as the shape of a node. It does not need any other block.

## 5. The checks, and what is kept

After the operations are applied, before the result is kept:

1. **Every operation applied.** A rejected operation (an unknown key, a node that does not exist) is a problem,
   quoted back with the engine's message.
2. **It renders with no new error or warning**, light and at 320 wide (an overflow, an unknown theme name, a
   text with no color).
3. **Every text the card showed is still shown.** The texts on screen before and after are compared; a missing
   one is reported as "A text the card showed is gone".
4. In a session: `UiSession.shownDiagnostics()` after the frame, which adds content that overflows its row or
   column, an empty component, and a value that was not worked out.

The round with the fewest problems is kept. With problems left after the last round the pass is refused and
the plain card stays. Not yet checked automatically: that the card still behaves (the values check of design
15 §4.15 can run on the result, and should before this is on by default).

## 6. Three examples, complete

Each folder under `CodelesslySDK/examples/showcase/style-pass/` holds the card before (`before.json`), the
operations kept (`ops.json`), the card after (`after.json`), the timings (`summary.json`) and the picture
(`compare.png`: before, after in light, after in dark). The composer was Sonnet; the design agent Opus; the
design system Cards.

| Card | Operations | First answer | Rounds | What the second round fixed |
|---|---|---|---|---|
| `flights`: three flights to choose from, a total, confirm | 23 (18 patch, 3 set, 1 move, 1 remove) | 29.0 s, 11,005 tokens in, 3,227 out | 2 | One rejected key: `decoration.shadows` does not exist (a shadow is bound to `decoration.effects`) |
| `approval`: delete 214 files, approve or deny | 36 | 27.5 s | 2 | Five problems from the first render |
| `carousel`: six shoes paged across, details in place | 27 | 21.7 s | 2 | Three problems from the first render |

What the operations did, on `flights`:

- **The surface**: the root column takes the `card` color, a `line` stroke, the card radius by name, 18 of
  padding and 14 between sections.
- **A header**: a new row holding a 40 by 40 tile in the accent tint with a flight icon, and the existing title
  and subtitle moved into it. Three `set` operations and one `move`.
- **The options**: each flight row becomes a panel (tile fill, tile radius, 14 of padding); the chosen one
  takes the accent stroke; the price takes the number style and the duration the quiet meta style.
- **The total**: a quiet panel with the label small and the amount in the large number style.
- **The action**: the button fills the width and takes the call-to-action radius.

The first operation and the header's first node, as written:

```json
{"op": "patch", "id": "column1", "patch": {
  "layout": {"width": {"fill": 0}, "padding": [18, 18, 18, 18]},
  "props": {"spacing": 14, "crossAxisAlignment": "stretch"},
  "decoration": {"fills": [{"color": "card"}], "strokes": [{"color": "line"}], "strokeWidth": 1, "radius": 26},
  "bind": {"decoration.radius": "${theme.radii.card}"}}}

{"op": "set", "id": "headMark", "parent": "head", "node": {
  "type": "row", "children": ["headIcon"],
  "props": {"mainAxisAlignment": "center", "crossAxisAlignment": "center"},
  "layout": {"width": 40, "height": 40},
  "decoration": {"fills": [{"color": "accentTint"}], "radius": 12}}}
```

No text, binding, variable or action appears in any of the 23 operations.

### All seventeen cards

The pass was then run on every card of the plain-parts recording set (17 requests, Sonnet composer, Opus
design agent, two rounds allowed). **17 of 17 passed the checks.** Eleven had nothing reported after the first
answer; six needed the second round (one, `itinerary`, had 63 reports in its first round and none in its
second). First answer: 18 to 53 seconds, median 29.6; 14 to 80 operations, median 38. The pass also removed
two faults the plain cards had: `itinerary` overflowed its column and `order_summary` had rows running
together. It does not repair what the composer got wrong in content: `dashboard`'s four figures are empty
before and after, and `image_gallery` shows only its title.

### Full pages

Three versions of each page were rendered and shown, unlabeled and in shuffled order, to two judges (Opus and
Sonnet): the bundled SSUI look, the Cards designed defaults (plain parts in the Cards look, no pass), and the
designed defaults with the design pass.

| Set | Pages | Pass kept by the checks | Judged order | Typical scores (SSUI, designed, pass) |
|---|---|---|---|---|
| Mobile, 420 wide | 6 (four written by hand, two real generated app screens) | 6 of 6 | pass, designed, SSUI in 12 of 12 judgments | 3–5, 6–7, 8–9 |
| Desktop, 1280 wide | 7 (five written by Sonnet from a one-paragraph brief, two by hand) | 4 of 7 | pass first in 14 of 14; designed second in 12 | 1–5, 5–7, 6–9 |

What the desktop set showed:

- **The three refusals were not the pass's faults.** Two were warnings at the 768-wide check, where a three-pane
  desktop layout does not fit whatever its style; one was the composer's own missing properties on two blocks,
  present before the pass. The check at a second width needs to be a width the layout is meant for.
- **The pass repaired a layout fault** (the support inbox's list overflowed its pane with designed defaults and
  does not after), which is why designed defaults ranked last on that page.
- **The SSUI column is not a fair measure on three desktop screens** (CRM, analytics, billing): the composer was
  given the Cards blocks and used them, and they do not exist without the design system, so those renders are
  mostly empty.
- **Content gaps stay**: the CRM's detail panel is empty in all three versions.
- Desktop scores are lower than mobile for every version: the composer's desktop layouts are weaker (panes of
  unequal height, a narrow sidebar's labels wrapping), and style does not fix structure.

## 7. What it costs

Measured on the three cards above: 22 to 29 seconds and about 11,000 tokens in and 2,200 to 3,300 out for the
first answer. In the tool a round also spends about 27 seconds rendering three pictures from a cold start; a
session has the card on screen and pays for a frame. Two things were learned that lower the second round's
rate: the brief now says how a shadow and a radius are written (the most common first-round rejection), and
the checks' messages are the engine's own, so the agent corrects in one step.

## 8. How to run it

```sh
# Any card as a document: a recording's .notation.json, or
tool/notation/notation.sh expand card.txt --out card.json

# The pass (reads ANTHROPIC_API_KEY from the environment)
python3 examples/showcase/tool/style_pass.py --card card.json --request request.txt --out out/ \
    --design-system design_systems/cards --model claude-opus-5-5 --rounds 2

# The agent's instructions for that card, word for word, with no model call
python3 examples/showcase/tool/style_pass.py brief --card card.json --out out/

# Applying operations by hand
tool/notation/notation.sh apply card.json ops.json --design-system design_systems/cards --out after.json
```

In an app the same thing is `UiSession.apply(ops, author: 'designer')` after `applyNotation` has finished,
with the session's document as the nodes and the view's render as the picture.

## 9. Open

- **Full pages.** Proven on inline cards; a page has more nodes (the brief grows with them) and more kinds of
  section. Being measured beside the next item.
- **Designed defaults.** The plain parts' default look is being ported to the Cards language, so path 1 starts
  closer to the bar and the pass has less to do. The comparison to settle: SSUI defaults, designed defaults,
  designed defaults plus the pass, and blocks, on inline cards and on full pages.
- **In the SDK.** The pass is a tool today. To come: the instructions built by the session
  (`UiSession` gives the nodes and the design system; the brief is assembled in Dart), the checks of §5 as one
  call, and the pass's result cached by request so a repeat costs nothing.
- **The design agent's tier.** Opus is measured. Sonnet as the design agent, and one round against two, are
  not yet.
- **Behavior after the pass.** The values check has not been run on restyled cards.
