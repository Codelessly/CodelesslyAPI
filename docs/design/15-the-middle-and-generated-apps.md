# The middle: from generated cards to generated apps

Status: a plan (2026-11-14). Nothing here is built yet except where a section says "exists".

## 1. Where we are

Two ends are proven, and they do not yet meet.

| | The fast end | The full end |
|---|---|---|
| Written as | The compact notation (design 13) | The full document, through `ui_apply` |
| Instructions the model reads | About 2,400 tokens | About 26,000 tokens |
| Median card | 935 output tokens, 5.4 s | 3,300 output tokens, 15.1 s |
| What it reaches | Levels 0 and 1, the parts of level 2 a card needs, a design system's components by name | Everything: scripts, drag and drop, custom paint, motion, multi-screen apps |
| Proven by | 34 of 34 cards; ahead of A2UI v1.0 on every measure taken (design 13 §11) | A Sudoku, a kanban with drag and drop, whole app screens from one paragraph (design 12 §8) |

The owner's reading (2026-11-14): the full API is powerful and usable directly by a model for complex apps, and
the fast generative UI niche that A2UI aims at is filled. What is missing is the middle, and it matters for two
reasons:

1. **The escape hatch.** A UI that starts in the notation must be able to reach full features (a Sudoku, a
   drag-and-drop kanban, a form builder, a whole app) without starting again in the other form.
2. **Apps described as prompts.** The other future of generative UI: a screen is a prompt ("Jump rope training
   app, home screen"), generated when it is needed and shaped to the person using it.

Part A is the first; Part B is the second, and it depends on the first.

## 2. Part A: the escape hatch

### 2.1 The principle

The levels already say it: higher levels add, they never respell (design 12 §3). The notation and the full
vocabulary are two ways of writing **one document**. So the hatch is not a second mode to switch into. It is a
ladder on the same document, and the model takes only the rungs a UI needs.

| Rung | What the model writes | Cost | State |
|---|---|---|---|
| 1. Words | Notation only | Lowest | Exists |
| 2. A key on a line | Notation, with a JSON object at the end of a line carrying any key of the full vocabulary for that node (`Icon "dns" {"props": {"size": 15}}`) | A few tokens where used | Exists |
| 3. A block in the full form | A subtree written as full nodes inside the notation, for a part the notation has no words for (a custom-painted board, a draggable list) | Full cost for that part only | Exists: `node {…}`, with notation lines under it (design 13 §3) |
| 4. Ops on the same document | The notation draws the screen; `ui_apply` ops then add what is beyond it (scripts, drop reactions, motion), addressed by node id | A second call, small | Both halves exist; the handover (stable ids the model can name, the outline it is given) is to build |
| 5. The full form | `ui_apply` from the start | Highest | Exists |

### 2.2 Knowing what is up the ladder without paying for it

The 2,400 token prompt cannot hold level 4. The model needs to know it exists and fetch it:

- The notation prompt ends with an index: one line per capability beyond it (drag and drop, scripts, custom
  paint, charts, motion, navigation, data lists), each naming a reference page. About 200 tokens. Built
  (2026-11-14) as its "BEYOND THESE WORDS" section, which names the page for each and the `ui_docs` tool.
- A tool, `ui_reference(page)`, returns that page. The per-level reference pages already exist (design 12, phase
  C); they need a short form sized for this (a page of a few hundred tokens with one worked example).
- So the cost of a full-featured UI is the base, plus only the pages it used.

### 2.3 Growing the notation from what the hatch is used for

The method that built the surface so far applies: build the hard thing, see what was awkward, give it a word.

- Record which rung-2 keys and rung-3 blocks models reach for across the targets.
- The ones that recur become words. Likely first candidates, to be confirmed by the recordings and not assumed:
  a `script` block, `drag` and `drop ->` on a line, `screen` blocks with `-> go <screen>`, a list over data with
  its row template.
- A word is added only when it removes a measured share of hatch use; otherwise the hatch is the right place
  for it.

### 2.4 How it is measured

The same briefs, three ways: the notation with the ladder, `ui_apply` alone, and (where it can express the
brief at all) A2UI. Briefs: Sudoku, kanban with drag and drop, a form builder, a multi-screen app.

Measured per brief: instruction tokens actually read (base plus fetched pages), output tokens, time to first
frame, time to complete, valid on the first answer, valid after one retry, and whether it works when driven
(numbers placed, a card dropped, a field added, a screen reached).

The bar: the ladder reaches what `ui_apply` reaches, the first frame arrives at notation speed, and the total
cost sits well under the full form's.

### 2.5 The first experiments (2026-11-14)

Eight standalone agents, none of which had seen this work, each built one of four briefs (Sudoku, kanban with
drag and drop, form builder, a three-screen jump rope app) one of two ways: starting in the notation and
climbing only when stuck, or as a full document by hand. Their reports and files are on the SDK's branches
`session/<brief>-ladder`, `session/<brief>-full` and `codex/jump-rope-app-full`, under `experiments/bridge/`.
They ran before `node {…}` existed, so rung 3 here means editing the expanded document by hand.

All eight worked when driven (numbers placed and conflicts shown, a card dragged between columns, fields added,
renamed, reordered and validated, a session finished and found in the history).

| Brief | Notation ladder: lines written | Highest rung needed | Full document: lines written |
|---|---|---|---|
| Sudoku | 35 of notation, 15 of JSON by hand | 3, for the timer only | 1,090 |
| Kanban | 38 | 2 (a JSON tail for drag and drop) | 241 |
| Form builder | 51 | 2 (tails to read a repeated item's fields, a number keyboard, scrolling) | 283 |
| Jump rope app | 58 | 2 (a tail for the countdown) | 247 |

What this says:

- **The middle is narrower than feared.** Nothing needed the full form, and no ladder agent needed a script:
  formulas over lists (`append`, `setAt`, `removeAt`, `count`, `with`) carried a Sudoku's conflict check and a
  form builder's reordering. The one script that was tried (the full Sudoku) failed for a missing engine in the
  render tool, and the agent did without.
- **The notation is four to thirty times shorter** than the full document for the same working UI. Lines are
  not tokens, and the agents could not measure their own time, so this is not yet the cost comparison of §2.4.
- **What pushed agents off rung 1 was a short list**, and most of it was missing words rather than missing
  power. Each is now fixed in the notation, or listed below.

| Found | By | Now |
|---|---|---|
| No word for a timer: a clock or a countdown needed a JSON tail or a hand edit | Sudoku, jump rope (and both said it was the one change that would have helped most) | `every 1s -> seconds=seconds-1`, with `when` |
| A timer was level 4, so a countdown card was "full vocabulary" | (the tests of this fix) | The `timer` trigger is level 2: state changing as time passes |
| `=field.label` under an `each` silently made a variable named `item.label`, which then failed validation | Form builder (its most-wanted change) | It binds the control to that field and writes the element back into its list; where that cannot be done, the line says so |
| `Input "{field.label}"` showed the raw `${item.label}` as its label, with no warning | Form builder | A label that reads data is bound |
| `Box#cell` under `each cell in …` lost its id (it became `item`), so two such blocks collided and `--tap cell` found nothing | Sudoku | An id is kept as written |
| No word for scrolling: a screen 6 px too tall needed a tail | Form builder | `Column scroll` |
| Nothing said a text can take a color: dark boards drew dark text | Sudoku | The prompt says `color:` on a text, `fill:` on a box, and to lighten text on a dark fill |
| Drag and drop needed JSON tails | Kanban (its second ask) | `drag:todo(card.id)` on a node, `drop:todo,doing -> …` on a target |
| One line, `"primary": "primary"`, in a site's theme gave 109 errors in SSUI's components | Sudoku, full | A role that names itself is reported once, where it is written |
| The render tool without its script engine said to add a package to an app | Sudoku, full | It also names the script that builds the engine for the tools |
| The published `codelessly_api` 30.1.0 has no notation, so the SDK's tools did not compile from a fresh checkout until the agent pointed them at the API's master | All four ladder agents | `tool/notation/notation.sh` sets it up, or says in one line what is missing |

Still open from the reports:

- **A validator on a dropdown** (the full form builder's ask). An input's keyboard is now `type:number`.
- **A raw `${…}` or a `0` drawn as text** is a visibly wrong screen the tool does not flag.
- **Setup.** The agents' checkouts started on an old branch and Flutter was not where the prompt said; that is
  the test's environment, not the product, but the tools should fail with one clear line when the API they
  compile against is too old.

## 3. Part B: apps described as prompts

### 3.1 The idea

An app is not a set of finished screens. It is a description that stays the same, and a memory of one person
that changes; a screen is generated from both when it is needed.

### 3.2 Constants and variables

| | Constant: the app | Variable: the person |
|---|---|---|
| Who writes it | The developer | The person, and the agent watching how it goes |
| Holds | The brief. The screens, each a prompt. How screens connect. **The data contract**: the variables and collections (sessions, streak, level, plan), and the actions a screen may call (start session, log result, purchase). The baseline design system. Rules a screen must keep (what must appear, where a paywall may go) | Stated preferences (goal, experience, look). Stage (beginner to pro). Style: theme tokens, illustration set, tone of copy. Which screens exist for them. What they stumbled on, complained about, ignored |
| Changes | With a release | Continuously |

**The data contract is the most important line in this table.** A generated screen is a view over data and
actions it did not invent. Because state lives outside the screen, a screen can be regenerated, restyled or
replaced without losing anything, and two people's very different home screens still write to the same history.

### 3.3 Personalizing in layers, cheapest first

Most of what "customized to the user" means does not need a model at render time.

| Layer | Example | Mechanism | Cost per person |
|---|---|---|---|
| 1. Theme | Pink or black; soft or sharp; larger type for a child | Theme tokens over the design system: a design system is data, and the document does not change (design 12 §3.1) | None |
| 2. Assets | Illustrations of a child for a child's app | A named illustration set chosen in memory; screens ask for an illustration by role ("hero", "streak") | None |
| 3. Copy and tone | Playful or clinical | Strings generated once per person and screen, cached | Small, once |
| 4. Layout | A beginner's home leads with "start your first session"; a competitor's leads with interval stats | The screen regenerated from its prompt plus memory, cached until memory changes in a way that matters | One generation |
| 5. Structure | A "double-unders program" page appears when the person is ready | A screen prompt added to that person's app | One generation |

The rule: use the lowest layer that does the job. Pink against black is layer 1 and costs nothing. A model is
called only for layers 3 to 5, and its output is cached.

### 3.4 The pieces

```
app spec (constants) ─┐
                      ├─► screen generator ─► validated document ─► cache ─► SDK renders
user memory (vars) ───┘          ▲                                              │
                                 │                                              ▼
                      review agent ◄──────────── events: taps, drop-offs, errors, feedback
```

| Piece | What it does | Built on |
|---|---|---|
| App spec | The constants of §3.2, as one file | New; the data contract is the document's variables and actions |
| User memory | The variables of §3.2: stated facts, style, stage, friction notes. Small, readable, editable by the person | New |
| Screen generator | Screen prompt + memory + data contract + design system → a document, in the notation first and up the ladder when the screen needs it | Part A, the notation prompt, `DesignSystem` |
| Validation and fallback | Every generated screen is checked (the validator, the shown-nothing check, the rules of the spec). A screen that fails is retried once, then the last good version or the default is shown. A person never sees a broken screen | `ValidateOptions`, `shownDiagnostics` |
| Cache and versions | A document per (screen, memory version), kept with its inputs so any screen a person saw can be shown again | New |
| The shell | Navigation between generated screens, streaming a screen in when it is not cached, generating the likely next one ahead | `UiSession`, `CodelesslyView`, the stream path |
| Review agent | Reads events on a schedule, not per frame. Finds friction (abandoned flows, repeated taps on nothing, validation errors typed and retyped), writes a note to memory or a change to one screen, and keeps the change only if the measure it was for improves | New; small edits go through `ui_apply` ops, not regeneration |

### 3.5 What can go wrong, and the answer built in

| Risk | Answer |
|---|---|
| The app moves under the person's hands | The constants do not regenerate. A screen changes only when memory changes in a way the spec says matters, and layers 1 and 2 never move anything |
| Latency and cost on every navigation | Cache; generate ahead; the notation's first frame; layers 1 and 2 are free |
| A generated screen is wrong or empty | Validation, one retry, fallback to the last good version |
| A generated screen does something it should not | It can only call the actions the contract declares, inside the agent trust profile |
| A bug cannot be reproduced | Every shown screen is a stored version with its inputs |
| Guessing who someone is | See §3.6 |
| "Optimizing retention" turns into manipulation | The review agent's goals are written in the spec and are about removing friction the person hit; what it changed and why is recorded in memory the person can read |

### 3.6 Decisions for the owner before this ships to people

These do not block the prototype, which uses invented personas, but they shape the product:

1. **Asked or inferred.** Styling by gender or age can be chosen by the person (a first-run question, a
   setting) or guessed from behavior. Guessing attributes like gender is the part most likely to misfire and to
   meet legal limits; the plan assumes the person chooses, and inference is limited to stage and friction.
2. **Children.** An app that adapts for children collects data about children, which is regulated (COPPA in the
   US, GDPR in Europe). The memory for a child profile likely has to stay on the device.
3. **Where memory lives**, and that the person can see and reset it.
4. **What the review agent may change by itself**, and what needs the developer's approval.

## 4. The prototype

The app: a jump rope training app. Screens as prompts: "Home screen", "Training history page", "Session
timer", "Plan", and one that only some people get, "Double-unders program".

| Step | What is built | What it shows |
|---|---|---|
| 1. Spec and personas | The app spec file with its data contract and sample data; three invented memories: an adult beginner, a child, a competitive athlete | The constants and variables, concretely |
| 2. Generate and render | Each screen generated per persona with the existing recorder and drawn with the render tool, side by side | Whether one prompt gives three right screens; how much is layer 1 and 2 (free) against 4 (generated) |
| 3. The ladder on a real screen | "Session timer" needs a running clock and a script; "Training history" needs a chart over the data | Part A, on screens that need it |
| 4. The live shell | An example app: type or pick a screen prompt, switch persona, watch the screen stream in; cached on return | The architecture running; this is also the playground |
| 5. The loop | A recorded session with friction in it, the review agent's note, the regenerated screen, the two compared | The improvement loop, once, by hand |

Steps 1 and 2 reuse what exists and come first; they will show whether the idea holds before the shell is
built. Step 4 and the notation playground are one piece of work: a page where a person types a prompt or the
notation and sees it render is the shell with one screen.

## 4.1 The playground, and the rule for every surface of this work

Built (2026-11-14): `CodelesslySDK/examples/playground`, designed from scratch as an Editor workspace page after a
first restyled version was rejected: a samples tree, the notation in a code field, the preview on a canvas, a
drawer of problems, events and the document, a status bar. Not yet: writing from a prompt, and living in the
Editor.

The rule (owner, 2026-11-14): the playground, and any other screen built around generated UI, is designed to be
integrated into CodelesslyEditor, in that exact style. So its own frame is `soft_saas_ui`, the package the Editor
is built with (its app, split view, pane toolbars, code field, selects, segmented controls), never Material
widgets, and it follows the Editor's layout conventions. What it shows inside the preview is whatever design
system is chosen; the frame around it is always SSUI's.

Added by the owner (2026-11-14): these surfaces also follow **the storyboard conventions** (the Storybook-like
framework in `OverlookV2/packages/soft_saas_ui/storyboard`, which CodelesslyEditor uses in `lib/storyboard`: a
sidebar of stories by category, phone-frame and flow viewers, its sync script and folder layout), and their
**controls are the dynamic properties panel** (`CodelesslyEditor/packages/dynamic_properties_panel`: a
schema-driven panel with a controller), not hand-made rows of toggles. A screen shown for a person is a story;
a run through several screens is a flow; what varies (the person, the token set, the audience, the store's
values) is a schema in the panel.

## 4.2 The polish gap, and the configuration to test (2026-11-14)

The first generated screens (`CodelesslySDK/examples/prompt_app`) are correct and fitted to the person, and
they look like a tidy dashboard, not a designed app (owner: "it's missing the illustrations, and design
polish"). Three reasons: the model composes from a SaaS system's generic parts; composition is invented at
generation time by a fast model; there are no assets.

The configuration: **polish is authored once, at the full API; the fast path only chooses and fills.**

| Piece | What it is | When it is paid for |
|---|---|---|
| A brand layer | The app's tokens over the base design system: palette, a display type scale, gradients, shadows, radii | Once; a palette change stays free |
| Screen blocks | Sections designed at full-API polish (a hero session card, a streak visual, a week strip, a chart card, a session row, an empty state) and kept as design-system components | Once, with no time limit, reviewed by rendering |
| Composition | The notation calls the blocks by name; the model decides order, emphasis, copy and which blocks a person gets | Per screen: about as today |
| Illustrations by role | A set per audience ("hero", "streak", "empty"), drawn as vectors in the document so they recolor with the theme | Once per set |
| A cached polish pass | The fast draft shows at once; a slower pass renders it, critiques it against a rubric and patches it with edit ops; the result is cached | Once per screen and memory version, after the first view |

It joins the two ends already proven: the full API builds the blocks; the notation uses them.

The test: Home for three people, five arms side by side (today's result; brand tokens; blocks; illustrations;
the cached pass), against a Home designed from scratch at the full API with no time limit. Recorded per arm:
tokens and seconds. The owner judges the images.

The rule from the playground applies here too (§4.1): a page was restyled and did not hold together, then
designed from scratch and did. Polish comes from designing the thing whole, not from fixing an average draft,
which is the reason to expect the blocks to matter more than the polish pass.

### 4.3 First results of the polish test (2026-11-14)

Built: `CodelesslySDK/design_systems/skip` (the brand layer, 13 screen blocks, illustrations drawn as vectors
and colored by tokens) and `examples/prompt_app/polish` (Home and History designed at the full API; the same two
in nine lines of notation each, with identical renders; one Home document under three token sets).

Then generated on the fly, by a model told only about the blocks (nine screens, one run each):

| | SSUI's generic parts | Skip's blocks |
|---|---|---|
| Instructions read per screen | about 11,400 tokens | about 5,000 |
| Output, median | about 540 tokens | 482 |
| Time, median | about 4 s | 3.7 s |
| Lines written for Home | 30 to 40 | 9 to 11 |

- **The configuration works where it was applied.** Home and History come out designed (hero, illustration,
  streak and goal tiles, week strip, chart card) for the cost of a plain screen, and still differ by person.
- **A screen is as designed as its blocks.** The session timer had no block, and came out as cards and big
  numbers. So the work for an app is its set of blocks: every screen kind needs its focal block.
- **Layout and style are not yet fully apart.** The notation's `Card` writes its fill as a literal color, so on
  the athlete's black page the timer's cards stayed white; the `Screen` block has to paint the page for the same
  reason. Left unfixed until the restyle experiment has measured it.
- **Not yet at a top consumer app**: the typeface is the platform's, the illustrations are clean but stiff, and
  motion is an entrance only. The designer's notes (`polish/NOTES.md`) list thirteen limits met in the model and
  renderer, among them a theme color name inside a custom paint drawing nothing with no error.
- **Not run yet**: the cached polish pass; standalone agents on new screens (do the blocks carry a newcomer to
  a designed screen?) and on a restyle (does a new look stay in the design layer?). Their prompts are written.

### 4.4 The session, and what the polish test taught (2026-11-14)

The owner judged the first generated session screens below the bar, and the session designed from scratch as six
blocks (a dial, a tap pad, a control bar, a big button, a summary, a top bar) at or above it. A model then
composed those blocks for three people in 4 to 9 seconds, and the screens ran when driven (start, countdown, tap
count, finish). `CodelesslySDK/examples/prompt_app/README.md` has the images and numbers.

What is now established, each from something built and looked at:

1. **Polish is authored, not generated.** Every screen that met the bar was built from blocks designed whole at
   the full API. The same model, the same prompt and the same speed gave a plain screen without them and a
   designed one with them.
2. **A screen is as designed as its blocks.** So an app's design work is its block set: one focal block per kind
   of screen, with its states. The session needed six.
3. **Fixing a draft does not get there.** The render, critique and rewrite pass improved hierarchy and broke
   contrast and a counter; a restyled playground was rejected and a redesigned one accepted. Design the part
   whole.
4. **Behavior that must be right is a constant.** A model asked to write the session's clock wrote one that
   looked right and ran wrong. The clock is now part of the screen's constants, put before the answer as the
   data contract is. The model composes the view; the host owns the data, the actions and the logic that cannot
   be wrong.
5. **Blocks should own their small interactions.** A block that takes a variable (`TapPad =count`,
   `SessionControls =paused`) writes it itself, so the model wires nothing and cannot wire it wrong.
6. **The cost goes down, not up.** Instructions fall from about 11,400 tokens to 5,000 to 6,200 (only the app's
   blocks are listed), and a screen is 9 to 31 lines.
7. **Some things are not layouts at all.** Diagrams, math, maps and a voice orb composed from boxes did not meet
   the bar and are dropped as card types (design 14).
8. **Where it still leaks.** The notation's `Card` writes a literal fill, so it stays white on a dark token set;
   a string inside a list literal is not interpolated; a block's first sentence is all the model reads of it,
   and wrong parameters on blocks caused most retries.

The configuration, restated: **the app's constants are its contract, its screens' prompts, its logic and its
block set; a person's variables are tokens, audience, tone and emphasis; the model composes blocks in the
notation.** What remains to prove is that someone who did not build the blocks can use them (the standalone
experiment), and that a new look stays in the design layer (the restyle experiment).

### 4.5 The six standalone runs (2026-11-14): newcomers with the blocks, and the restyle

Six fresh agents, none of which had seen this work. Their reports and files are on the SDK's branches
`codex/skip-beginner-default`, `session/kid-pink`, `session/athlete-athlete` (under `experiments/polish/`) and
`codex/calm-restyle-blocks`, `session/calm-full-restyle`, `experiment/calm-restyle-20261114` (under
`experiments/restyle/`). The owner reviewed the designs and passed them.

**Newcomers with the blocks** (five screens each, for one person and token set):

| | Result |
|---|---|
| Validation errors met, all three agents | 0 |
| Block parameters guessed wrong | 0, 0 and 1 (a `TimePicker` binding) |
| Reference pages opened | none: the notation's instructions, DESIGN.md and PATTERNS.md were enough |
| Lines of notation per screen | 14 to 44 |
| Session (blocks exist) | Designed, and ran when driven, in all three |
| First run, achievements (a block for the focal part) | Designed |
| Weekly plan (blocks for the top only) | Partly designed |
| Settings (no block) | Plain, in all three |

All three ranked their screens the same way and for the same reason: the screens with an illustrated focal block
were designed, the ones built from rows and fields were not. All three asked for the same two blocks: a planned
day (day, session, done, swap) and a settings panel. This is the rule of §4.4 found again by people who were not
told it.

**The restyle to "Calm"** (flat, sage, square, hairlines; the question was how much of it stays out of the
screens):

| Starting point | Screen lines changed | Token lines | Component lines | Why the screens changed |
|---|---|---|---|---|
| Notation with blocks | 2 (a brand label, as content) | 408 | 546 across 17 blocks | Nothing in layout: zero geometry or layout lines |
| Notation a model wrote (blocks plus plain notation) | 28 | 145 | 512 across 18 blocks | Plain `Card`, `Text.*` and the canvas were expanded to literal colors, radii and weights |
| Full documents, no components | 253 | 299 | none | Gradients, blur, borders and two weights are literals on the nodes |

What this establishes:

1. **Layout and style are apart at the screen, when the screen is made of blocks.** A new look changed no
   layout line. This is the separation the owner asked to see proven.
2. **Style is not yet apart from structure inside a block.** A token can recolor a gradient's stops; it cannot
   make it flat, remove a blur, add a border, or change a weight or a radius written as a number. So a restyle
   this different was a new set of 17 block files, not a token set. The agents' common proposal: a **surface
   style token**, one named decoration (paint kind, stroke, effects, radius) that a node binds whole, and text
   in custom paint that names a text style.
3. **Plain notation leaks the look into the screen.** `Card`, `Text.*`, `Progress` and the canvas write literal
   values at expansion, so they do not follow a token set or a new design system (a purple bar under the pink
   set; dark ink on the athlete's dark page; white cards). They should write the token's name.
4. **A hand-built full document carries half its restyle in the screen** (253 of 552 lines), which is the cost
   blocks remove.

Smaller findings: the reference says a site's component of the same type wins over the design system's, and the
validator rejects it as a duplicate (three agents); the render tool has no way to show what a screen emitted;
a sample list in the contract makes a first-run screen hard to show without `--set`; a week strip given every
past session marks last week's days.

### 4.6 The accurate head to head, and the pipeline it needs (2026-11-14)

The comparisons so far are not one experiment. The measured head to head (design 13 §11) is A2UI as it comes
against the notation with SSUI's generic parts, on 17 card briefs: it wins on cost, speed and behavior, and its
cards are plain. The Skip comparison (`examples/prompt_app/renders/vs-a2ui.png`) is A2UI as it comes against
the notation with a block set designed for that app, on three other briefs: it shows the look, and is not the
same test. The owner's point: the missing piece was never A2UI's side, it was ours, the step from "fast, with
pre-existing generic parts" to "fast, fully designed".

The accurate head to head, from our side, is three arms on the same 17 briefs, models and renderer settings:

| Arm | What it is | State |
|---|---|---|
| A2UI as it comes | Its schemas and basic catalog, on its own renderer | Recorded |
| The notation, generic parts | SSUI's components | Recorded |
| The notation, designed blocks | A card block set designed at the full API, composed by the model | The block set is being designed (`design_systems/cards`); then recorded |

The third arm against the second isolates what blocks add (design, and their effect on tokens, time and first-try
validity); the third against the first is the showcase.

The pipeline for the third arm, in the product and not only in the offline recorder: `UiSession.applyNotation`
now takes its design system's blocks by default, takes the host's prelude (the data contract's state, a
screen's clock), and `UiSession.notationInstructions(blocks: …)` gives the short instructions that list only an
app's blocks. Still to do on that path: the chat example's live generation uses `ui_apply`, not the notation;
and the generator that makes a screen for a person (`examples/prompt_app/tool/generate.py`) runs ahead of time
through the recorder, not through a session at first open.

### 4.7 Named looks: the notation's own parts follow the theme (2026-11-14)

The restyle runs (§4.5) found that what the notation itself draws (`Card`, `Text.title`, `Badge.success`,
`Progress`, a chart's color, the screen's surface) was written into the document as color values, so a new
look meant expanding the screen again. That half is closed:

- `NotationOptions.fromTheme(theme, named: true)` and `NotationOptions.fromDesignSystem(ds, named: true)` write a
  look the theme has a name for as that name (a color `"primaryBorder"`, a text style `{"from": "pageTitle"}`),
  using the document's existing theme names (resolved before rendering, live on a theme or mode change).
- A session's notation path (`UiSession.applyNotation`) writes names by default.
- Tested: a card written under SSUI holds no color value at all, and the same document shown under Paper has
  Paper's border and surface (SDK `test/session/notation_restyle_test.dart`); in the API, the named expansion
  resolved against two themes equals each theme's own literal expansion, for colors and text sizes
  (`test/notation_test.dart`, "named looks").
- The five design systems in the SDK share their token names, so this holds across all of them.

Still values, not names: a card's radius and padding, and anything an author writes as a number or a color on a
line. The surface style tokens (flat or raised, blur, border weight) that blocks need for a restyle with no new
component files are still open. The offline recorder and the render tool still write values (their outputs are
compared with earlier recordings); only the session path changed its default.

### 4.8 The third arm, the held-out briefs, and the gap that remains (2026-11-15)

**The third arm** (the 17 briefs composed from the Cards blocks; SDK `tool/stream/streams/live/2026-11-15-blocks-1`,
sheets in `examples/showcase/renders/head-to-head/`). Medians: Sonnet 7,822 tokens in, 1,003 out, 5.9 s, no
errors, 7 of 17 retried; Haiku 7,821 in, 849 out, 4.1 s, 3 with errors, 11 retried. Against A2UI (21,169 in,
2,592 out, 17.1 s on Sonnet) and the notation with generic parts (2,379 in, 1,427 out, 8.9 s). The cards are
designed; the caveat is that the blocks were designed for exactly these 17 briefs.

**Held out.** Eight briefs the blocks never saw (recipe, now playing, poll, subscription, tracking, run summary,
meeting slot, expenses; `examples/showcase/heldout/`), Sonnet, all three arms. With blocks: 7,978 in, 721 out,
5.0 s, no errors, 3 retried. What the pictures show:

- Where the blocks fit, the card is designed with nothing new built: run summary (21 block nodes, 3 generic),
  tracking (11, 0), meeting slot (9, 0), recipe (12, 8).
- Where none fits, the card is the generic one: poll used no block and now playing one (a picture), and both look
  like the generic arm.

So there are two modes that work (generic parts, fast and plain; designed blocks, fast and designed where a block
exists) and the full API (designed by a strong model with renders to look at, in minutes to hours). The owner's
reading stands: nothing yet lets a model produce a new good design at generation speed. Three candidates, none
tested: (1) a design kit below the blocks (the surfaces, type roles, depth, drawn media and layout patterns the
blocks are made of, as words the model composes freely); (2) a block designed on demand by a strong model when
none fits, checked against a render, then kept, so the wait is paid once per kind of card; (3) a look at the
render inside the fast path, with one revision. The test for each is these held-out briefs, starting with the two
that failed.

**First step on the gap (same day).** The model had been given the parts and nothing on how they go together; the
Cards set had that written down (`PATTERNS.md`) and the prompt did not carry it. `notationPrompt` now includes a
design system's "In brief" section and says to compose the general parts when none is named after the content.
On the same eight briefs (`2026-11-15-heldout-blocks-2`; 8,850 tokens in, 716 out, 4.9 s, no errors, 2 retried):
the poll went from 0 block nodes to 7 and is a designed card, now playing from 1 to 4, meeting slot from 9 to 13;
generic nodes fell on six of the eight. One regression seen: the recipe's scaled amounts read 0. This is
composition from general designed parts, not new design: a card with no fitting part still gets a designed frame,
labels, options and actions, but nothing drawn for it (a poll's result bars, a player's transport). Candidates
(1) to (3) above remain untested.

**Sideways content** (owner request): the notation has `Pages =page` (the engine's page view, swiped, bound both
ways, with `peek`), `Dots =page count:n`, and `Row scroll` now really scrolls sideways (it overflowed). A new
`edgeFade` prop on scrolling containers and page views fades content out at an edge it continues past, by scroll
position and on any background; the notation writes it by default for sideways scrollers, because inside a padded
card a strip cannot reach the card's edge and a hard cut looks wrong. Cards has a sliding `Carousel`, strip and
paged `PhotoGallery`, `PageDots`, `WideScroll`, and a `ComparisonTable` whose columns scroll under pinned labels.

### 4.9 A block designed on demand (2026-11-15)

Candidates (2) and (3) of §4.8 together, tried on the poll (SDK `examples/showcase/tool/design_block.py`,
results in `examples/showcase/on-demand/poll/`). A strong model (Opus) is given the design system's principles,
its theme names, three of its blocks as written and the notation, and asked for one new block at the full API
plus a card that uses it. Both are validated and rendered, light and dark, the block alone from its own preview
and the card; the pictures and every problem go back, and it revises.

| Round | Model | Check and render | Problems reported |
|---|---|---|---|
| 1 | 48.8 s | 34.9 s | 0 |
| 2 | 47.9 s | 35.3 s | 0 |
| 3 | 45.7 s | 38.7 s | 0 |

About 85 s to a first usable block, about 3 minutes for two rounds; roughly 27,000 tokens in and 5,900 out per
round. Round 2 was visibly better than round 1 (a footer unreadable in dark was fixed, the rows tightened); round
3 changed almost nothing. The block (`PollResults`: a share bar and percentage per option, the leader in the
accent, the voter's choice marked, the total) is correct in light and dark. With it added to the set, the fast
model (Sonnet, the same poll brief) wrote a four-line card that uses it in 2.3 s, and the card shows the results
after a vote.

What this shows, on one block: new design at the set's bar can be made without a person, in minutes, by a strong
model that sees its own render; paid once, it is then composed at generation speed. What it does not show: more
than one block; a judge other than me; a harder block (drawn media, a transport with motion); how often a round
is needed; what happens when two requests want different blocks of the same name. An earlier run of the same
harness showed the model only the card, where the block appears after a tap, so it revised something it had not
seen: the block's own preview has to be in the loop.

### 4.10 Formulas and variables: the grammar is not natural yet (owner's note, 2026-11-15)

The owner's observation, which the record supports: models trip on how values, variables and formulas are
written more than on anything else in the notation, and each time the answer has been to make the parser accept
one more spelling. This session alone: a `{…}` inside a list literal's strings; a stray `:=`; a bare dotted path
as a value; `key:="…{x}…"`; a number where a text parameter was wanted; a list holding expressions
(`votes:[a+1,b]`), read as broken JSON until today; a control bound to a field of a repeated element; the
recipe's scaled amounts reading 0. Tolerance has kept the error counts down, but it treats the symptom.

The cause, as far as it is understood: the same idea is written five ways depending on where it stands (`{x}` in
a string, `=name` on a control, `key:=expr` on a prop, `-> name=expr` in an action, `${…}` in a JSON tail), and a
value is JSON in one position and a formula in the next with nothing on the page to tell which. A model has to
know which mode it is in; a person would too.

Not decided, and not to be patched further without a design: one way to write a value that is the same
everywhere. The candidates worth testing against the recorded failures are (a) every value is an expression, with
JSON literals as the constant case, so `:` and `:=` are one thing; (b) one interpolation mark used in strings,
props and actions alike; (c) keep the forms and move all tolerance into one normalizing pass with a report of
what it rewrote, so the cost of each spelling is measured. The measure is the retry rate on the 17 and the eight
held-out briefs with the small model (11 of 17 retried with blocks today), not whether a parser test passes.

### 4.11 Standalone runs, second set (2026-11-15), and what they change

Five of six prompts ran (the carousel one started later). Branches on the SDK: `review/showcase-product-design`,
`codex/cards-inline-trials`, `poll-result-block`, `cards-warm`, `chat-cards`.

**The independent judge** (a product designer's scores of every cell of the head to head, 1 to 5 on "would you
ship this as is"). Means, A2UI / generic parts / designed blocks:

| Set | Rows | Ship | Blocks beat generic | Blocks at 4 or 5 |
|---|---|---|---|---|
| Sonnet, the 17 | 17 | 1.94 / 2.53 / 3.88 | 15 (2 ties) | 13 |
| Haiku, the 17 | 17 | 1.47 / 2.06 / 2.71 | 11 (4 ties, 2 worse) | 4 |
| Sonnet, held out | 8 | 2.50 / 2.88 / 3.38 | 4 (4 ties) | 5 |

The judge's findings that matter: with the small model the designed cards often carry a broken value (a raw
expression shown as a total, `$NaN`, an empty message body, overlapping forecast rows), so polish does not make
them shippable; some designed cards leave out a step the brief asked for (free slots, the annual saving, the later
steps of a checkout); a still picture cannot show that a control works. The held-out scores are from before the
composition brief (§4.8) and the on-demand block (§4.9).

**Five unseen cards written by hand from the blocks** (poll, music player, habit streak, split bill, support
ticket): all rendered with no errors in 9 to 15 lines each, composed from the general blocks; what was missing
was a poll results block and a player with album art, the same two the held-out run found. Dark captures show a
white page under the dark card.

**A block designed by a newcomer** (`PollResult`): done, at the set's bar, in light and dark, as 54 lines of the
set's own block code. Together with §4.9 that is the same missing block made twice, by an agent with the
repository and by a model with only a prompt and its renders.

**A restyle by tokens only** (`cards_warm`: cream, terracotta, a serif for titles): the block, kit and art files
are byte for byte the same as Cards; only the token and brand files changed, and all 22 cards took the look in
light and dark. This is the separation of layout and look asked for in §4.2, shown on a whole set.

**A chat app from the public API**: first card on screen 11 minutes 39 seconds after first reading the guide,
cards painting a block at a time, events arriving. Six gaps, all in the guide and one in the SDK: nothing on
`applyNotation` or `notationInstructions`; the answer's canvas is `screen` while the view defaults to `home`
(a blank card until found); nothing on giving a session a design system or bundling one; a component that gains
children while streaming did not repaint until the view was rebuilt (a bug to reproduce and fix); the guide's
chat example is the older edit-operation path; and the published API package is older than the SDK branch.

**What the retries were** (the first answers that needed a second try, across the blocks recordings, 106
reported problems): several top-level parts with no root, or an answer restarted halfway; a bare word where a
parameter was meant (`ActionButton "Cancel" quiet`); a third string on a block that names two; `key=value` for
`key:=value`. Formula spellings were a small share of what was *reported*. The parser now reads the unambiguous
ones as meant. But the judge's broken values are formula mistakes that were *not* reported, because they are
valid and wrong. So the owner's note (§4.10) stands, with a sharper statement of where it bites: not in what
fails to parse, but in what parses and computes the wrong thing.

**Carousels, galleries and wide content by a newcomer** (`cards-notation`, the sixth run): four cards in 2 to 10
lines each, 52 captures at 390 and 420 wide, light and dark, every render with no errors or warnings. Swipe,
dots and count stayed in step in the product carousel and in the gallery's large view; the five-plan comparison
scrolled its columns under fixed labels; the notation's own `Pages` with `PageDots` worked on one variable. What
it noted: the peeking next item shows cut-off text (inherent to a peek); the comparison has no dots or count;
dark captures show a white page under the dark card (the card's canvas is transparent and the capture's page is
white: right for a chat that has its own background, wrong-looking in a capture). No engine or notation defect
was found in this run.

**What this changes in the order of work**

1. Correctness of values with the small model comes first: it is what stands between a designed card and a
   shippable one. The formula redesign of §4.10, and a check the host can run before showing a card (a value
   that is `NaN`, empty, or still shows `{` or `$`), with one retry.
2. The showcase uses the larger model for the designed column, and says so; the small model's column is shown as
   it is.
3. On-demand blocks: repeat on the player and three more, with the owner judging, then decide whether it is a
   product path.
4. The guide's chapter on streaming gets the notation path, and the repaint bug is fixed.
5. Completeness against the brief: the composition brief should say that a card shows every step the request
   names, and the showcase should drive each card's main interaction, not show a still.

**Measured after the changes of §4.8 and §4.11** (SDK `2026-11-15-blocks-2`, the small model with blocks on the
17 briefs, one run, against the morning's one run): retried 6 of 17 (was 11), answers ending with an error 0 (was
3), 580 tokens out (was 849), 3.1 s (was 4.1 s), for about 1,060 more instruction tokens. What the six first
answers got wrong: reading a field of a list's records as if it were a variable (one card, six times), a bare
word on a block that no single parameter takes (three cards), a block's required title left out (two), and one
each of five others. One run each way, so the size of the change is indicative, not established; whether the
values on these cards are right has not been checked.

### 4.12 Standalone run 7: the on-demand path, tested by others (2026-11-15)

Branches on the SDK: `codex/on-demand-block-design-trial`, `on-demand-model-comparison`,
`codex/on-demand-poll-chat`; the judge and the run of the loop with a model reported to the owner.

**A designer with only the brief** (an agent in the model's seat: the brief's text, the check, the four pictures;
no source). Three blocks:

| Block | First clean render | Would ship at | Rounds | Verdict |
|---|---|---|---|---|
| Habit streak | about 83 s | about 138 s | 2 | Close |
| Bill split result | about 61 s | about 61 s | 1 | At the bar |
| Support ticket timeline | about 125 s | about 187 s | 3 | Close |

With §4.9 that is six blocks through the loop by two kinds of designer, each usable in one to three rounds and
one to three minutes. "Close" both times meant a fixed count (seven days, three milestones), not a look below
the set's. What the brief lacked: the brief said to write no sizes or radii of one's own while its three example
blocks do; build log lines leaked into it; nothing on what to assume when the request leaves a rule open (week
start, currency, how many steps).

**The fast path with the new blocks** (ten requests, five for each of two on-demand blocks, both models; the
card rendered, its main interaction driven, every value checked by the agent):

| Model | Used the new block | Values right after the interaction | Retried | Render errors |
|---|---|---|---|---|
| Sonnet | 10 of 10 | 8 of 10 | 1 | 0 |
| Haiku | 10 of 10 | 1 of 10 | 3 | 4 |

A new block is picked up every time: the on-demand path's second half works. What fails is the small model's
values, and the failures are the ones §4.10 names. The commonest: `choice:pick`, read as the text "pick" where
the variable was meant (two cards); a vote that changes a count the results do not read; a header that says
Paused after play; a function that does not exist (`formatTime`), `??`. None showed `NaN` or raw `${`: they are
valid and wrong, and no check caught them.

Changed on this evidence: a bare word that names a declared variable is that variable wherever a value is read
(it already was in an action), which makes both `choice:pick` cards right when their recorded answers are read
again. Not changed: a card's own logic being wrong.

**The loop in a chat app** was built against an older checkout, so its code does not test today's SDK, but its
finding was right at the time: nothing public let a running session gain a block. `UiSession.addBlock` now does
(the next instructions list the block, the next answer calls it, the view on screen draws it; tested with the
on-demand poll block).

**A model left to draw a chart** ran out of output: the brief never said the engine has chart nodes. The brief
now names every node type and carries the chart nodes in full; the same block then came out in 87 s on the
engine's line chart.

**Where the third way of working stands.** Shown by people other than its author: a missing block can be
designed in minutes from a brief and its own renders, and the fast path then uses it every time. Not yet true:
that the small model's cards are right; that a first request is served well while its block is made; that the
loop runs inside a product. The larger model with on-demand blocks is the configuration that works today.

**The same ten requests again, small model, after the changes** (SDK `2026-11-15-ondemand-haiku-2`, driven cards
in `examples/showcase/on-demand/haiku-after/`; one run, judged by the author from the pictures, where the first
count was an outside agent's, so the two are not the same measurement):

| | Outside run | After |
|---|---|---|
| Used the new block | 10 of 10 | 9 of 10 (one poll built its own results) |
| Retried | 3 | 2 |
| Render errors | 4 | 2 (one card) |
| Polls right after a vote (counts, shares, total, the voter's mark) | 0 of 5 | 4 of 5 |
| Players right after play | 1 of 5 | 2 of 5 |

The polls moved because the voter's choice is now the variable. What is still wrong is the card's own logic or
content, which no reading of the notation can repair: one poll does not add the vote; one player's header still
says Paused after play; one asked for sunset art and got a record; one added a progress line with a function
that does not exist. Two players came without a card frame.

### 4.13 What the small model writes when nothing tells it how (2026-11-15)

The elicitation of design 12 §12 (SDK `tool/values/elicit.py`, answers in `2026-11-15-elicit-haiku`): fourteen
briefs that need state, the notation's instructions with every rule and example about state, bindings, formulas,
actions, conditions and repetition taken out (the blocks' descriptions too, which quoted them), and one sentence
asking for those parts as reads most naturally. How many of the fourteen answers used each spelling:

| | Spelling | Answers |
|---|---|---|
| A value from state | `key:name`, bare | 13 |
| | `"…{expr}…"` inside a text | 11 |
| | `key:expression`, no mark (`enabled:choice!=null`, `hidden:!voted`) | 5 |
| | `key:{name}` | 4 |
| | `=name`, `key:=expr` (today's forms) | 1, 0 |
| State | declared at all | 2 (twelve simply use a name) |
| A change | `x = value`, `x = !x` | 9 |
| | in place (`n += 1`, `votes[i] += 1`) | 2 |
| Shown only sometimes | `cond ? a : b` inside a value | 6 |
| | a key (`hidden:`, `visible:`) | 4 |
| | an `if` line | 1 |
| Repeated | `each x in list` | 3 |

The owner's reading is right and the form of the answer is plain: to the model a value is a value. It writes
the name, or the expression, where the value goes, and reserves quotes for text; it does not declare state; it
changes state by assigning. Today's notation asks it to choose between `:`, `:=` and `=name` by a rule about
what kind of thing follows, which is the distinction it does not make. What it wrote for a tap had no pattern
(the stripped instructions showed an event as `onPressed(event)`, which steered it), so that part is not
evidence.

Taken up at once, as readings the parser now makes: a bare name that is a declared variable; `key:{name}`;
`key:expression` with no mark. Not yet: state that is never declared (a name used and never introduced), which
with a streamed answer means a name may be met before the line that gives it a value; `{expr}` inside the
strings of a list; changes in place. These are the design work of track 1, to be settled against the values
check (SDK `tool/values/check.py`: 7 of 10 with the small model before these readings, target 9).

### 4.14 The harder concepts, asked of three models (2026-11-15)

Eight briefs that need more than a value (a cart with a quantity a line, a to-do list, a three-step sign-up, a
countdown, a tip split, a quiz with a score, a filtered and sorted table, counters under one limit; SDK
`tool/values/advanced_briefs`), given to the small, the middle and the large model as subagents with the same
stripped instructions and nothing else to read (`tool/values/elicitation_instructions.txt`; answers and each
model's own notes in `2026-11-15-elicit-advanced/`). How many of each model's eight cards used a form:

| Concept | Form | Small | Middle | Large | Today's notation |
|---|---|---|---|---|---|
| Repeated | `for x in list` | 5 | 3 | 4 | `each x in list` |
| | `each x in list` | 0 | 0 | 0 | |
| Shown sometimes | an `if` line | 0 | 8 | 8 | `if` line |
| | `else` | 0 | 5 | 4 | none |
| | an `if:` key on the node | 7 | 0 | 0 | none |
| A tap | `onPressed: …` / `onChanged: …` | 0 | 8 | 8 | `-> …` |
| | `tap:"…"` / `change:"…"` | 8 | 0 | 0 | |
| The new value in a handler | `value` | 5 | 7 | 8 | `result` |
| One record of a list | assign to it in place (`item.qty = …`, `list[i].qty = …`) | 3 | 1 | 3 | `updateWhere`, `setAt`, `with` |
| | rebuild the list with map or filter | 2 | 2 | 2 | as written |

Every model declared what the card remembers on a line of its own (`state x = v`, `state x = v`, `$x = v`) and
what is worked out as another such line (`let`, `derived`, or the same `$x = expression`); every model wrote
time as `every 1s` with a condition and the steps; none wrote `each`, `->` or `result`.

What they agree on, against today's notation:

1. **A handler is statements on the control**: assignments separated by `;`, the control's new value called
   `value`. The three spell the key differently (`onPressed:`, `tap:`), which says the key should be the event's
   own name with the obvious short ones accepted, not a mark.
2. **`for … in`**, never `each`.
3. **A record of a list is changed where it stands** inside the loop. Rebuilding the list is what the engine
   needs; it is not what anyone writes first.
4. **`else`** exists.
5. **A worked-out value is a declaration**, with or without a word of its own.

Their own notes name what stayed unnatural: nothing tells an expression from text in a block's parameter (the
small model quoted expressions, the large braced them, the middle wrote them bare); two-way binding had to be a
value plus a handler; list helpers and money formatting had to be invented (`sum`, `.sum`, `toFixed`, `money`).

The design this points to, to be built as readings and then taught: `for` beside `each`; `else`; `let` and
`derived` beside a `state` that holds a formula; `onPressed:`, `onChanged:`, `tap:`, `change:` beside `->`, with
`value` beside `result`; assignment to a field of the loop's item, or of `list[i]`, rewritten to the list
rebuilt. Each is measured by the values check before it is taught in the prompt.

**Built as readings the same day, and measured on the three models' own unprompted cards** (the 24 answers of
this section, expanded with the Cards blocks; "unread" is a line or word the notation reported):

| | Small | Middle | Large |
|---|---|---|---|
| Unread lines, before | 97 | 46 | 9 |
| Unread lines, after | 12 | 14 | 4 |
| Cards read with nothing unread, after | 3 of 8 | 3 of 8 | 5 of 8 |

Read now: `for … in`; `else` and `else if`; `let`, `derived` and, before the card, a bare `name = value`;
`$name`; a handler as a key or on a line of its own (`onPressed:{…}`, `tap:"…"`, `onChanged: …`) with `value`
for the control's new value; `if:` as a key; a value with no mark, with or without spaces; `and`, `or`, `not`;
a call on a value (`rows.filter(…)`, `rows.length`, `n.toFixed(2)`, `tasks.add(x)`, `tasks.remove(x)`); a
record of a list changed where it stands; `n += 1`, `n++`; a guarded step (`if (c) { a = 1 }`) as the
assignment made while the condition holds; `every 1s while:{…} onTick:{…}`.

This measures what is read, not what is right: no card of these eight briefs has been driven and checked yet.
What is still unread is mostly an expression as a block's unnamed first value (`Progress (a - b) / c`), a second
card written beside the first, and parameters the blocks do not have. None of these forms is taught in the
prompt yet; the prompt still shows `=name`, `:=` and `->`. Whether to teach the natural forms in their place,
and which spelling of each, is decided by the values check on all 35 briefs with the small model.

### 4.15 Values with the small model, measured (2026-11-15)

The check (`CodelesslySDK/tool/values/check.py`) renders an answer, drives it, and reads what is on screen. On the
25 pinned briefs, with the Cards blocks:

| Model, prompt | Right of 25 |
|---|---|
| Haiku, today's prompt | 8 |
| Haiku, the natural variant (`notationPrompt(natural: true)`), before the parser reads below | 11 |
| Haiku, the natural variant, after them (a second recording) | 10 |
| Sonnet, today's prompt | 16 |

Read with care: the cases were written strictly, and several of Sonnet's misses are the check asking for a
wording ("3 lemons" where the card shows "Lemons, 3"). The cases are being audited so the number means values;
until then the figures compare prompts, they do not say how often a card is right. One run to the next moves by
a case or two on its own.

What the runs did settle is what the small model writes that was not read. Each is now read, with a test:
a worked-out value that starts with quoted text; a call on a worked-out name (`total.toFixed(2)`); a condition
in braces with spaces and words; `key:={…}`; a text in a list that reads a value (`items:["Lemons, {2 * n}"]`,
refused before); a list after `:=` with spaces in it; a parameter named `change` (read as a handler before);
`formatTime(seconds)` (now `duration`, which existed and was not taught). The natural variant teaches statements
after `->` (`qty += 1`, `row.done = !row.done`, `rows.remove(row)`), `let` for a worked-out value, and
`key:{expression}`. It is not the default yet: the target is 9 of 10 and neither prompt is near it.

### 4.16 Standalone run 8: nine outside trials of the on-demand path (2026-11-15)

Nine agents, 31 blocks designed. The owner's reading of the designs: the quality is good. In numbers: one block
takes two to four and a half minutes with Opus at up to three rounds, 65K to 145K tokens in; as designer Opus
was usable 3 of 3, Sonnet 2 of 3, Haiku 0 of 3; a card composed with a new block had its first values right 20
of 20. What was wrong, most hit first, and what became of it:

| Finding | State |
|---|---|
| The check looks only at the first state: six hard blocks all passed and one was fully usable (a signature that will not clear, a hue label that does not follow the drag) | Open. The card is now also checked at 320 wide; an interaction script in the designer's answer is the next step |
| The brief named every block `ChartSeries` | Fixed |
| A parameter named `change` was read as a handler (a quote showing +$0.00) | Fixed |
| The last round shipped though an earlier one was better | Fixed: the round with the fewest problems is kept, and a design with problems left exits as failed |
| Problems counted twice with build output in them | Fixed |
| A paint cannot read its node's size; an object-list parameter with no declared shape refuses every field | Open |
| Replacing a card in a live session failed (`would_orphan`) | Fixed: `applyNotation(replace: true)`; guide 18 says so |
| Generated blocks keep some fixed radii under a re-themed system | Open |

### 4.17 On-demand blocks in a session (2026-11-15)

The SDK has the loop: `notationInstructions(askForBlocks: true)` has the model name a block where none fits
(`Wanted "Name" "what it shows"`, the part built from plain types under it); `UiSession.wantedBlocks` holds the
requests; `OnDemandBlocks` takes each to a designer the host supplies, keeps a design only when it is a
component of that name with no validation errors and no cycle and passes the host's check, adds it, and tells
the host to store it; `applyNotation(replace: true)` swaps the card.

Measured on the eight held-out briefs with both models: with the first wording nobody asked for anything (0 of
16); with the instruction as a decision and an example, Sonnet asked once, rightly (the music player), and
nobody asked wrongly. So the model's own request is precise and rare, and cannot be the only trigger. The
second is the host's: `OnDemandBlocks.mostlyPlainParts` (at most a third of the card's parts are blocks, at
least five are plain), a rule one outside run fitted to sixteen answers and that agreed with the eye on all of
them; it is a starting point, not a measured rate.

## 5. Order

1. Part A rungs 3 and 4, the capability index and `ui_reference`, measured on the four briefs (§2.4).
2. Prototype steps 1 and 2.
3. Prototype step 3, which is where the two parts meet.
4. The playground and the live shell (step 4).
5. The loop (step 5), after the owner's decisions of §3.6.
