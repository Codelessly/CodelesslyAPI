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
| 3. A block in the full form | A subtree written as full nodes inside the notation, for a part the notation has no words for (a custom-painted board, a draggable list) | Full cost for that part only | To build |
| 4. Ops on the same document | The notation draws the screen; `ui_apply` ops then add what is beyond it (scripts, drop reactions, motion), addressed by node id | A second call, small | Both halves exist; the handover (stable ids the model can name, the outline it is given) is to build |
| 5. The full form | `ui_apply` from the start | Highest | Exists |

### 2.2 Knowing what is up the ladder without paying for it

The 2,400 token prompt cannot hold level 4. The model needs to know it exists and fetch it:

- The notation prompt ends with an index: one line per capability beyond it (drag and drop, scripts, custom
  paint, charts, motion, navigation, data lists), each naming a reference page. About 200 tokens.
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

## 5. Order

1. Part A rungs 3 and 4, the capability index and `ui_reference`, measured on the four briefs (§2.4).
2. Prototype steps 1 and 2.
3. Prototype step 3, which is where the two parts meet.
4. The playground and the live shell (step 4).
5. The loop (step 5), after the owner's decisions of §3.6.
