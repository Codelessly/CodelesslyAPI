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
| 0 | **Core** | Boxes and layout: `row`, `column`, `stack`, `wrap`, `gridView`, `container` (decoration, padding, clip), `text`, `icon`, `image`, `spacer`, `divider`, scrolling. Sizing (`fixed`, `hug`, `fill`, `flex`), alignment, spacing. Theme colours and text styles by name. One interaction: a tap that tells the host. | It needs to draw anything at all |
| 1 | **Widget catalog** | Controls that are SSUI by default and hug with zero props: buttons, `textField`, `switch`, `checkbox`, `radio`, `slider`, `dropdown`, `popupMenu`, chips, `segmentedButton`, `tabs`, date and time pickers, progress, `listTile`, accordion, app and navigation bars, dialog, sheet, toast, tooltip. Each holds its own value and reports `changed`. | It needs input from a person |
| 2 | **State and behaviour** | Variables, bindings, expressions and formulas, actions, `states`, list templates over data, forms and validation, conditions, navigation between screens. | The UI must react without the host |
| 3 | **Design systems** | Theme scales, components by reference, a design system as data (tokens, components, DESIGN.md, PATTERNS.md), responsive `media` rules. | It must look like a specific product |
| 4 | **Full vocabulary** | Motion and animations, gestures, drag and drop, `customPaint`, scroll effects and parallax, hero, charts, timers, scripting, media and embeds. | It is building an app or a game, not a card |
| 5 | **Feature layers** | Multi-page sites, publishing, storage, paywall, hosted plugins. Product features built from levels 0–4, never new render primitives. | It is shipping a product |

Levels 0 and 1 together are the surface compared with A2UI, and the surface of the compact notation
`Column([Slider, Input, Toggle, Button])`. The end targets (a custom-styled Sudoku, a drag-and-drop builder, a
whole app screen from a description) are levels 3 and 4 on the same document.

**Rules that keep the levels honest**

1. Every type, prop, action and behaviour in the catalog carries its level. The validator can be run at a level
   (a profile), and reports the first thing above it.
2. The reference is generated per level: a level's page teaches only that level, and the base an agent is given
   grows by one page per level it is granted.
3. Level 0 must be sufficient to draw any static UI. The test is redrawing each level 1 control from level 0
   parts (which is also how a design system defines its components).
4. A level 1 control with zero props is complete: it has a size, a look and a value.
5. Nothing at level 5 adds a render object.

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

## 7. Open questions for the owner

1. Is level 2 (state and behaviour) part of the A2UI comparison surface, or strictly 0–1 with the host holding
   state, as A2UI does?
2. Level names in the public API: numbers, or names (`core`, `widgets`, `state`, `design`, `full`)?
3. May the compact notation drop Flutter's type names where a shorter one is unambiguous (`Input` for
   `textField`, `Toggle` for `switch`), as in the owner's example, with the document keeping the full names?
4. Convert a whole-value `"${…}"` into a binding on apply (phase B)?
