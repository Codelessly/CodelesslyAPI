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

## 5. Order

1. Part A rungs 3 and 4, the capability index and `ui_reference`, measured on the four briefs (§2.4).
2. Prototype steps 1 and 2.
3. Prototype step 3, which is where the two parts meet.
4. The playground and the live shell (step 4).
5. The loop (step 5), after the owner's decisions of §3.6.
