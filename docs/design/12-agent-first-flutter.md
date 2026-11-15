# Agent-first Flutter: the vision and the plan

Written 2026-11-14. Section 1 is the owner's direction, verbatim. Everything after it is the plan drawn from it.
It supersedes the ordering in earlier plans where they disagree; [11-no-widgets.md](11-no-widgets.md) remains the
design for removing the widgets.

## 1. The direction (owner, verbatim)

> Going forward, please don't spawn subagents for the SDK final polish and rewrite pass to align with our new
> direction. You have all the context, so complete that work here.
>
> The competitive positioning for CodelesslySDK is now very clear, and our vision is clear too:
> We're building an Agent first Flutter, stripping out all of Flutter's widgets, and building our own API layer
> with an API that's the easier and most natural for agents to use to describe and build UI as data. We're
> replacing Flutter's widget layer and using Flutter for the rendering pipeline and ecosystem only!!
> We've already proven that what we build is much more performant than Flutter widgets. Our CodelesslyEditor canvas
> using renderobjects directly performs much better than before when we were using Flutter widgets.
> We've also solved many lists, scroll effects, scroll and parallax, pagination, etc by using our own list
> renderer.
> We've built web layout CSS Flexbox and grid and responsive reflow wrap that Flutter's layout engine doesn't
> support.
>
> The goal is to build an API that is natural for AI to describe layouts and features as data with.
> Please use the above to update our /goal
>
> To describe and clarify our thinking, let's walk through this exercise.
> We'll follow the A2UI pipeline to think through how best to optimize our API. To guide us along, we must define
> the Base API (Level 0 Core). Then, we'll add additional layers on top that allow us to support more and more app
> feature.
> Base -> Rows, Columns, Container etc. APIs needed to render any UI from the ground up.
> Widget Catalog -> Slider, Dropdown Menu, Popup Menu, etc.
> Essentially, we'll start with the core set to give to A2UI and our gen UI solution, that supports the fast DSL
> Column([Slider, Input, Toggle, Button]). And makes it competitive in performance against A2UI.
>
> The end goal and target, is a fully custom styled Sudoku, or Drag and Drop builder, and the entire app screen,
> described with natural language and generated. For this, we'll need to solve and integrate AI concepts such as
> DESIGN.md, PATTERNS.md, SSUI as a design system turned into a generic template, to allow others to drop in their
> design systems, etc.
>
> As a reminder, so far, we've proven both sides. The simple fast inline UI gen. And the full complex UI gen. For
> the complex, we have the template for how to expand our API surface - generate the complex app and then use our
> renderer to replicate. Now, we're giving it structure and a complete pathway from simple to complex, which
> allows the AI to work at all levels, depending on the need!
>
> Please write the above verbatim into a .md file for planning, and then create the full plan and TODOs. We now
> have a clear path to a truly agent first app and UI framework.

## 2. What this changes

- **Positioning.** Not "Flutter's API as data" but "an agent-first UI framework on Flutter's rendering pipeline".
  Flutter gives us the engine, text, compositing, platforms and packages. Its widget layer is replaced, not
  wrapped. Flutter's names stay where they are the name a model already expects; where the web's model is the
  more natural one (flex, grid, wrap, media) or we have our own (lists, scroll effects), ours wins.
- **The measure of a design choice** is now: is this the form an agent writes correctly on the first try, in the
  fewest tokens, and can still edit later as data? Conformance to Flutter is a means to that, not the goal.
- **One document model, several levels.** The same flat document serves a four-control inline card and a whole
  app. What changes with need is how much of the vocabulary the agent is given, not the format.
- **How the work is done.** The polish and rewrite pass that aligns the SDK to this is done in the main session,
  not by subagents. Workstreams already running for Milestone 3 finish and are merged; no new ones are started
  for the rewrite pass.

## 3. The levels

A level is a closed set: a document written with level N's vocabulary validates and renders with nothing from a
higher level, and each level's reference is complete on its own. Higher levels add; they never respell.

| Level | Name | What it adds | An agent reaches for it when |
|---|---|---|---|
| 0 | **Core** | Boxes and layout: `row`, `column`, `stack`, `wrap`, `gridView`, `container` (decoration, padding, clip), `text`, `icon`, `image`, `spacer`, `divider`, scrolling. Sizing (`fixed`, `hug`, `fill`, `flex`), alignment, spacing. Theme colors and text styles by name. One interaction: a tap that tells the host. | It needs to draw anything at all |
| 1 | **Widget catalog** | Controls that are SSUI by default and hug with zero props: buttons, `textField`, `switch`, `checkbox`, `radio`, `slider`, `dropdown`, `popupMenu`, chips, `segmentedButton`, `tabs`, date and time pickers, progress, `listTile`, accordion, app and navigation bars, dialog, sheet, toast, tooltip. Each holds its own value and reports `changed`. | It needs input from a person |
| 2 | **State and behavior** | Variables, bindings, expressions and formulas, actions, `states`, list templates over data, forms and validation, conditions, navigation between screens. | The UI must react without the host |
| 3 | **Design systems** | Theme scales, components by reference, a design system as data (tokens, components, DESIGN.md, PATTERNS.md), responsive `media` rules. | It must look like a specific product |
| 4 | **Full vocabulary** | Motion and animations, gestures, drag and drop, `customPaint`, scroll effects and parallax, hero, charts, timers, scripting, media and embeds. | It is building an app or a game, not a card |
| 5 | **Feature layers** | Multi-page sites, publishing, storage, paywall, hosted plugins. Product features built from levels 0–4, never new render primitives. | It is shipping a product |

Levels 0 to 2 are the surface compared with A2UI (section 7); levels 0 and 1, with the level 2 forms a card needs,
are the surface of the compact notation
`Column([Slider, Input, Toggle, Button])`. The end targets (a custom-styled Sudoku, a drag-and-drop builder, a
whole app screen from a description) are levels 3 and 4 on the same document.

**Rules that keep the levels honest**

1. Every type, prop, action and behavior in the catalog carries its level. The validator can be run at a level
   (a profile), and reports the first thing above it.
2. The reference is generated per level: a level's page teaches only that level, and the base an agent is given
   grows by one page per level it is granted.
3. Level 0 must be sufficient to draw any static UI. The test is redrawing each level 1 control from level 0
   parts (which is also how a design system defines its components).
4. A level 1 control with zero props is complete: it has a size, a look and a value.
5. Nothing at level 5 adds a render object.

### 3.1 Where the design comes in

The line between level 0 and level 1 is the line between structure and design (owner, 2026-11-14: "the natural
division point where the design comes in").

| | Level 0, core | Level 1 and up, controls |
|---|---|---|
| What it is | Boxes, layout, text, icons, images | Buttons, fields, switches, sliders, menus, tabs, pickers, dialogs, sheets, toasts |
| Look with nothing written | None. A box has no fill, border or shadow; a layout has no look. Text is 12 px, regular weight, in the platform's font, with no color of a design system | SSUI's: its colors, radii, sizes and type, light or dark |
| Where the look comes from | Only from what the document writes on the node, or a theme color or text style it names | The bundled SSUI tokens, with the document's theme over them, and the node's own style over that |
| Changing the design system changes it | No | Yes, every control, with no change to the document |

What follows from it:

- A control must have a look to exist, so there is always a default, and it is SSUI. There is no Material
  default anywhere in what a control draws.
- The default is one order everywhere, whichever way the UI was written (a full document, `ui_apply`, the compact
  notation): node style, over the document's theme, over the design system's tokens (SSUI's when none is given).
- Level 0 is safe to hand to any host or design system: it carries no opinion to fight. A design system is
  exactly the set of answers to "what does a level 1 control look like", plus named colors and text styles that
  level 0 may refer to.
- The model package holds no look. The defaults live in the renderer
  (`codelessly_sdk`: `lib/src/render/controls/ssui_defaults.g.dart`, generated from
  `design_systems/ssui/design_system.json`); the one place this package names SSUI is the notation's options
  (`NotationOptions`, replaced by `NotationOptions.fromDesignSystem`).

## 4. The pipeline, simple to complex

Following the A2UI pipeline (a description, a compact structured answer, a catalog the client trusts, rendering
as the answer streams), with our additions at each step:

1. **Brief.** Natural language, plus the level granted and, from level 3, a design system.
2. **Notation.** For levels 0–1 the agent writes the compact notation; it expands, as it streams, to the same flat
   document everything else uses. From level 2 the agent writes edit operations (`ui_apply`) on the document.
   The compact notation and A2UI's format are two front ends of one expander, not two renderers.
3. **Check.** The validator at the granted level, formulas included, with messages that say what to write.
4. **Render.** Render objects directly; frames as operations arrive.
5. **Look.** What shows is checked after the frame (empty view, empty list, dead control) and told to the agent.
6. **Escalate.** When the brief needs more, the agent asks for the next level's page (`ui_docs`) and continues on
   the same document. Nothing is rewritten when the level rises.
7. **Edit.** The result is data: a person or an agent changes it in place.

## 5. The plan

Phases are in dependency order. A and B are in flight; C onward is the new structure.

### A. No widgets (Milestone 3, in flight)

Buttons, the control kit, focus, overlay and the root are merged. Running: text field, dropdown and menus, chips
and progress with the kit follow-up, tiles, toggles and slider, bars, pickers. Then, in the main session:
dialogs, sheets and toasts; the app shell (screens, routes, hero flights) with no Navigator; final removal of
every widget import; a whole site running from `attachRoot` with no widget. Done when the import ratchet is empty
outside the one host adapter.

### B. Generation reliability (in flight)

Merged: post-frame diagnostics, formula checks, bound theme names. Left: convert a whole-value `"${…}"` into a
binding on apply (awaiting the owner's yes); re-record the 34 SSUI cells and recount; the 0.07 px overflow stripe.

### C. Define the levels in the API

1. Tag every catalog entry with its level; `Catalog.level(n)` returns the closed set; the validator takes a level.
2. Audit level 0 for sufficiency and for surplus: list every level 1 control with the level 0 parts that draw it,
   and every level 0 prop no control or example uses.
3. Audit level 1 for zero-prop completeness: each control alone in a column, no props, rendered light and dark.
4. Generate the reference per level, with a word budget per page; the level 0 + 1 page is the A2UI-comparison
   prompt and must be the smallest complete one we can write.
5. A test that each level's examples validate at that level and no lower-level page names a higher-level thing.

### D. The compact notation (levels 0–1)

1. Grammar: `Type(props?, [children])`, positional children, named props only when not default, ids generated,
   values bound by name. Designed from the token counts of real level 0–1 cards, not from taste.
2. A streaming parser in `codelessly_api` that emits edit operations as tokens arrive, and a printer back from a
   document (round trip is a test).
3. Wire it into the session and the chat example beside `ui_apply`.

### E. Head to head with A2UI

1. Same briefs, same models, three arms: A2UI on its own renderer, our compact notation, our `ui_apply`.
   Measured: output tokens, time to first frame, time to complete, valid-first-try rate, usable-card rate by eye,
   and what each cannot express.
2. Then the A2UI format as a third front end of the expander, so an A2UI-tuned model drives our renderer with SSUI
   defaults.
3. Publish the numbers in [09-genui-use-cases.md](09-genui-use-cases.md) and the demo page.

### F. Design systems as a template (level 3)

1. Turn SSUI's folder into the generic template: what a design system must provide (tokens, the level 1 controls'
   defaults, components as level 0 compositions, DESIGN.md, PATTERNS.md), each file's role and size budget, and a
   checker that says what is missing.
2. SSUI's components collapse onto the core level 1 types as presets (workstream L of design 11), so a design
   system restyles `Button` rather than adding `SsuiButton`.
3. Prove it by dropping in a second, visibly different design system with no SDK change, and generating the same
   cards under both.
4. How DESIGN.md and PATTERNS.md reach the agent: what goes in the base prompt, what is fetched on demand.

### G. The complex end (levels 3–4)

1. Three target briefs generated from natural language alone under a custom design system: a styled Sudoku, a
   drag-and-drop builder, a whole app screen. Each run records which level pages the agent pulled and where it
   stalled.
2. Keep the method that built the surface so far: when a target cannot be expressed, build it natively first,
   find the smallest general addition, add it at the right level, and rerun.
3. Standalone-agent test #4 (control-heavy briefs: settings page, dashboard with filters, multi-step form) on the
   widget-free renderer.

### H. The SDK alignment pass (main session, no subagents)

1. Package layout follows the levels: `core/` (level 0 render objects and layout), `controls/` (level 1),
   `runtime/` (level 2), `design/` (level 3), `effects/` (level 4), `features/` (level 5), `host/` (the adapter
   and embeds). An architecture test enforces that a level imports only lower ones.
2. Delete what the direction makes dead: island hosts, Material theme plumbing, legacy fallbacks, names kept only
   for Flutter-widget parity that agents get wrong.
3. Public API: `attachRoot`, the host adapter, sessions, design systems, the embed extension point. Everything
   else is `src/`.
4. Rename the story in README, the reference base and the design index to this document's positioning.
5. Performance numbers we can state: frame times and memory against the same UI in Flutter widgets, list scroll,
   and time from first token to first frame.
6. Production checks: semantics, keyboard and IME on every platform we claim, web and mobile smoke runs, error
   surfaces, versioning and the migration story for 30.x documents.

### I. After the direction settles

Port CodelesslyEditor in one pass; the generative UI demo page; marketing drop-ins; merge CodelesslySite; release.

## 6. Order and gates

| Gate | Opens when |
|---|---|
| C starts | Now (API-only; does not touch files the Milestone 3 workstreams own) |
| D starts | C1 and C4 are done |
| E starts | D works end to end and A's level 1 controls are merged |
| F starts | A's controls are merged (F2 needs them) |
| G starts | F3 passes |
| H starts | A's workstreams are merged (H1 moves their files) |
| I starts | H is done and E's numbers hold |

## 7. Decisions (owner, 2026-11-14)

1. **The A2UI comparison surface is levels 0–2.** A2UI's own cases need forms, sliders and values that react, so
   state is part of the comparison, not something we add after it. The compact notation therefore also covers
   the level 2 forms a card needs (a bound value, a reaction).
2. **Levels have names (`core`, `widgets`, `state`, `design`, `full`, `features`) and are internal
   categorization, not public API.** They live in `lib/src/core/levels.dart`, are not exported, and are used by
   our validator profile, the reference generator and the tools.
3. **The compact notation may use shorter names where they are natural** (`Input`, `Toggle`); the document keeps
   the full type names.
4. **A whole-value `"${…}"` written where a plain value goes is converted to a binding on apply**, with a note to
   the author; it is not rejected.

## 8. Status (2026-11-14, evening)

Measured, not planned. Recordings are in `CodelesslySDK/tool/stream/streams/live/`.

| Phase | State |
|---|---|
| A. No widgets | Postponed by the owner (2026-11-14): the Flutter widgets still in use work and stay; one is ported only when it causes a problem. A render-object paging list was built and parked in history (SDK `71f41ea2`, taken out again by `7ca2cce3`). 16 core files still import Flutter's widget libraries (51 files in all this morning; the host adapter, where widgets belong, is counted apart). Every control and every input is a render object, the signature pad and the pagination controls included; the indicators and the typewriter no longer touch a widget library. What is left hangs on three seams: the app shell (Navigator, routes, modals, toasts, confirm), lists on `Scrollable`, and embeds (media, web view). Toasts and confirms were scoped and wait for the screen stack (design 11 §12). |
| C. Levels | Tagged and validated at a level. Level 1 is audited by a test: every widget-catalog type has a size and draws with only its type written, except a page view and a table, which need a height. |
| D. Compact notation | Built: parser, stream, prompt, printer with an exact round trip. 34 of 34 recorded cards expand cleanly with the current parser; 26 of 34 were valid on the model's first answer. |
| E. Head to head with A2UI | Measured against A2UI v1.0 on the same briefs, models and renderer (design 13 §11), and the same A2UI answers drawn by A2UI's own Lit renderer (§11.1): it draws 20 of 34 as written and 29 after two keys are renamed; `parseA2ui` draws 34. Not compared: its Angular and Flutter GenUI renderers. |
| F. Design systems | SSUI's looks are the notation's defaults, and `NotationOptions.fromDesignSystem` takes them, and its components, from any design system. All 164 SSUI components are rebuilt in the SDK as 160 documents (`design_systems/ssui/PARITY.md`, which also lists where a rebuilt one is less than its source); a generated catalog page shows every one. The notation calls them by name (design 13 §12): `Stepper =seats`, `Panel "Billing"` with lines under it. The template is `design_systems/tool/new_design_system.py`; `paper` and `harbor` are regenerated from it with every batch. |
| G. The complex end | All three produced by Claude Sonnet 5.5 from one paragraph each, with SSUI, and used through the render tool: |
| | **Sudoku**: 27 s, one retry. A number is placed, conflicts are highlighted, the timer runs. |
| | **Kanban with drag and drop**: a card dragged from To do is dropped on Done and the counts follow. |
| | **A whole app screen** (sidebar, top bar, stat tiles, chart, filterable table, activity, a New task dialog): 40 s, 66 nodes, one retry. Navigation, the tabs and the dialog work. |
| H. SDK alignment pass | In progress, in the main session. **Done**: the layers of `lib/src` are ordered and a test names every import that goes up (the one runtime-to-widgets import is gone); performance numbers for one screen against Flutter's Material widgets (`CodelesslySDK/benchmark/README.md`: slower on the first frame's own build, level or faster on updates and scrolling, web release build, software rendering); both test suites on and green (851 and 1,907); the README says what the repository has for UI written by an agent. **Audited, not changed** (2026-11-14): `codelessly_sdk.dart` has 69 export lines, 38 of them whole files of `src`; of about 200 exported types, 20 are used by CodelesslySite, 53 by the examples and tools, 67 only by the SDK's own tests and 76 by nothing outside `lib` (the Editor, not yet ported, was not checked). Trimming them is a breaking change to a released package, so it waits for the owner; the proposal is to move what only tests and internals use to a second library, not to delete it. **Not done by decision**: deleting the island hosts and Material theme plumbing (the remaining Flutter widgets stay, owner 2026-11-14). **Open**: the directory layout by level (the test enforces the order without moving 263 files), the README's opening, production checks on devices. |

What the complex targets found and fixed on the way, each a thing an agent hits:

- A script written with `variables.get` or calling another script bare failed only when run: said at validation
  and at the end of a generation stream now.
- `runScript` with `args` was rejected by the validator though the runtime reads it; a script's declared
  parameters must now be passed.
- A click reaction written on a design-system component ran in the component's scope and could not see the page's
  variables: it runs in the caller's scope.
- The guide said a drop reaction reads its data as `${result}`; it is `${result.data}`.
- The render and replay tools did not find the built script engine, did not hold before a touch drag, and striped
  a 0.2 px overflow.

Known gaps in what was generated: the Sudoku's first answer needed its retry each time (script API names); the
kanban used arrows until asked for dragging by name. The app screen's table was cut short inside its card (a list
that fills a card whose body hugged fell back to its design height): fixed in the card, and the recording replays
with every row.

## 9. Verified by rendering and driving (2026-11-14, late)

The full test suite is off at the owner's request, and runs of whole test folders are refused while it is. What
follows was checked the other way: real documents put through the render tool, driven where they act, and looked at.

| What | How | Result |
|---|---|---|
| Custom output with no design system | The 26 reference examples (decoration, custom paint, vectors, tables, stacks, forms, a carousel) and 6 example sites at phone and desktop sizes | 0 errors, 0 warnings on the examples; 0 errors on the sites |
| Reactions and state | Counter tapped three times, a validated form typed into and sent (both ways), a carousel stepped, page navigation, a modal opened, a condition toggled, an accordion list opened | Each ends in the state it should |
| Every node group | The 40 fixture samples (inputs, pickers, sliders, toggles, buttons, chips, tiles, charts, gauges, progress, paths, images, lists, grids, pages, ink and states) | All draw. Their reported errors are the fixtures' own extra keys; the one runtime error is the audio plugin, which the tool does not have |
| Lists | A list paged by scrolling (12 a page, to its 42nd row), sticky section headers, a swipe that deletes with its reaction, a press-and-drag reorder | All four work |
| Drag and drop | The generated kanban: a card dragged from To do to Doing | It moves; the counts follow |
| Scripts and the complex end | The generated Sudoku (a cell chosen, a number placed, the conflict marked) and the form builder (two fields added) | Work as when first recorded |
| A design system | Every SSUI component at each of its previews (225 tiles), and two screens generated in the notation with SSUI's components listed | 0 errors; both generations valid on the first answer |
| The whole app screen, again | The screen generated on 2026-11-14 morning, rendered on today's code and driven | A section is switched and the New task dialog opens |
| A whole app screen, new | A support inbox asked for in one paragraph (sidebar, top bar, four figures, a ticket table filtered by tabs, a side panel with a reply box, a New ticket dialog), Claude Sonnet 5.5 with all 160 SSUI components on offer | 62 nodes, 27 of them SSUI components (`NavigationMenu`, `StatTile`, `Tabs`, `Badge`, `Dialog`, `Field`, `HeaderSearchInput`...), no errors or lints left after one retry; renders with 0 errors and 0 warnings; a ticket is picked and the dialog opens. Recording: `CodelesslySDK/tool/stream/streams/live/2026-11-14/support_inbox@claude-sonnet-5-5.compact.ssui.*` |

Found on the way, and fixed: a text field with `obscureText` drew its text in plain (Flutter's `RenderEditable` hides
it only from screen readers; the field now draws the obscuring character).

**Not verified here**, because they need a service or a device the render tool does not have, and their test files
have not been run since the widget-removal work: cloud data and its paging, sign-in, payments and the paywall, audio
and video players, web views, file pickers, and screen capture. They need either the test suite turned back on for
`test/services`, `test/session`, `test/paywall`, `test/media` and `test/app`, or a run on a device.

## 10. The road to standalone test #5 (2026-11-14)

A standalone test gives agents that have seen none of this work only what a newcomer gets (the published
reference, the guides, the tools) and a brief, and records where they stall. Four rounds have run; each found
friction that was then fixed. Round 5 is the first on the finished pathway: it tests each level from the
notation to a whole app, including the bridge between them, and re-checks the round 4 findings. The owner
starts it.

What has to be true before it is worth running, in order:

| # | Work | State |
|---|---|---|
| 1 | Both test suites on and green | Done: 847 and 1,907 tests |
| 2 | assistant-ui parity: every listed element as a target | Done: 74 of 74. Seven were dropped as card types and are not supported, by the owner's decision (Mermaid diagram, diagram, flow graph, math, two maps, voice orb): domains with their own renderers elsewhere |
| 3 | The bridge (design 15, part A): a block in the full form inside the notation, ops on the notation's document, the capability index and `ui_reference`; measured on Sudoku, kanban, form builder and a multi-screen app | Planned |
| 4 | The playground: type the notation or a prompt, see it render, switch design system | Planned |
| 5 | Apps described as prompts (design 15, part B): spec, personas, generated and rendered side by side (steps 1 to 3 of the prototype) | Planned |
| 6 | The alignment pass's remainder: layer order checked (done), performance numbers (running), public API audit, production checks, README opening (the owner's call) | In progress |
| 7 | The briefs for round 5: one set per level, plus bridge briefs that start in the notation and must reach level 4, plus the round 4 findings to re-verify | To write |

Rows 2 to 5 are what round 5 will exercise that no earlier round could; row 7 is written last, from what they
turn out to be.

## 11. Status against the goal (2026-11-15)

Each part of the direction in §1, as it stands. Evidence is in the section named.

| Part | State | Where |
|---|---|---|
| The levels (0 Core to 5 Feature Layers) | Defined, tagged in the catalog, checked by the validator at a level, with a reference page and a test | §3, §8 C; `lib/src/core/levels.dart`, `docs/reference/levels.md`, `test/levels_test.dart` |
| Removing Flutter's widgets | Stopped by the owner's decision: every control and input is a render object; the widgets still used (lists on `Scrollable`, the app shell, embeds) stay because they work | §8 A |
| The compact notation with SSUI defaults | Shipped. Since §8: whole-node lines, timers, drag and drop, `Pages`, `Dots`, sideways scrolling with an edge fade, looks written as token names, a design system's composition brief in the prompt, readings of what a model writes on a block's line | design 13; design 15 §4.7, §4.8, §4.11 |
| Head to head with A2UI | Run three ways on the same 17 briefs, and on eight held-out ones, and scored by an outside judge: ship score 1.94 for A2UI, 2.53 for generic parts, 3.88 for designed blocks with the larger model | design 15 §4.6, §4.8, §4.11 |
| SSUI as a generic design-system template | The template builds Paper, Harbor, Skip and Cards from SSUI; a whole set was restyled by its token files alone, the block files unchanged | §8 F; design 15 §4.11 |
| A custom-styled Sudoku, a drag-and-drop builder, a whole app screen from natural language | Each generated from one paragraph and driven | §8 G, §9 |
| The SDK polish pass | Layer order enforced by a test, both suites green (855 and 1,914), benchmark recorded. Open: the public API trim and the README's opening (owner's decisions), device checks | §8 H |
| New design at generation speed | Not reached. What exists: a block designed on demand by a strong model in minutes and then composed in seconds, shown on two blocks with no outside judge yet | design 15 §4.9 |

The three end targets were checked again on 2026-11-15, after this session's changes to the notation, the
renderer and sessions, by replaying their recorded final answers on today's code and driving them with the render
tool: the Sudoku takes a number in an empty cell, marks its row, column and box, and its clock runs; the kanban's
first To do card dragged onto Done moves and both counts follow; the app screen's scripted interaction changes it
as before. No render exceptions in any of the four replays (the form builder too). The replay tool's generic
script, which drags a fixed distance and taps the first key, reported the Sudoku and the kanban as unused: it
missed, the UIs were not broken.

What stands between this and "production ready", in order:

1. Values with the small model: cards that are designed and wrong. A session now reports a value that came out as
   nothing; a value that is merely the wrong number is not caught. The grammar for values and formulas is to be
   redesigned, not patched (design 15 §4.10).
2. Decisions only the owner can make: the public API trim (a breaking change to a released package), the README's
   opening, whether the on-demand path becomes a product path, the Editor port.
3. What cannot be checked here: devices, cloud data, sign-in, payments, media.
4. Outside results still to come: standalone run 7 (the on-demand path), and runs 4 and 5 of the earlier set.
