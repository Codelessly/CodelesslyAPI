# The compact notation

Phase D of [12-agent-first-flutter.md](12-agent-first-flutter.md): the form an agent writes for levels 0 to 2, the
surface compared with A2UI. This is the design; nothing here is built yet.

## 1. Why, in numbers

Measured on the 34 SSUI cards recorded 2026-11-14 (`CodelesslySDK/tool/stream/streams/live/2026-11-14-ssui`), each
written as `ui_apply` edit operations:

| | Today |
|---|---|
| System prompt and tools | 26,033 tokens |
| Output per card, median (range) | 3,300 tokens (1,897 to 7,442) |
| Output per node | 137 tokens |
| Time to complete, median | 15.1 s |
| Nodes per card, median | 24 |

A card is slow because of what the agent must write per node, not because of what it draws. One line of the
approval card as recorded:

```json
{"op":"set","id":"s1","node":{"type":"text","layout":{"width":{"fill":358},"height":{"hug":20}},"props":{"text":"Folder: Shared Drive / Archive 2019","style":{"fontSize":13,"color":"#FF374151"}}}}
```

About 60 tokens, of which the content is 8. The rest is the envelope (op, id, node, layout, props), a size the
renderer could have worked out, and a style that has a name. The same line in the notation:

```
Text "Folder: Shared Drive / Archive 2019"
```

The whole approval card (17 nodes, 1,897 tokens as recorded) is about 230 tokens in the notation (section 4).
The targets: **output under 15 tokens per node, a prompt under 2,500 tokens for levels 0 to 2, first frame within
one second of the first token.**

## 2. Principles

1. **One document.** The notation is a front end. It expands to the same flat schema-3 document `ui_apply`
   edits, so everything after it (validation, rendering, diagnostics, editing as data) is unchanged, and a UI
   begun in the notation continues with `ui_apply` when it needs level 3 or 4.
2. **Write the content, not the envelope.** Structure is nesting. Ids are generated. A size is written only when
   it is not the default for that type in that parent.
3. **Defaults carry the look.** A control with nothing written is the design system's (SSUI's) control. Text
   takes a named style. Colors are theme names.
4. **State is as short as layout.** A variable exists by being used. A binding is `=`, a reaction is `->`.
5. **Streams.** Every line is complete when its newline arrives, and can be drawn then: a parent is declared
   before its children, never closed before them.
6. **Round trips.** Any document within levels 0 to 2 prints back as the notation, and parsing the print gives
   the same document. That is the test, and it is what lets an agent read a UI in the form it writes.

## 3. The grammar

Indentation is nesting (two spaces). One node per line:

```
Type[.variant][#id] ["text"] [key:value ...] [=binding] [-> action; action]
```

- **Type**: a node type, capitalised (`Column`, `Text`, `Slider`). A few natural short names are accepted and
  expand to the full type in the document (`Input` → `textField`, `Toggle` → `switch`, `Button` → `filledButton`,
  `Select` → `dropdown`, `Image` → `box` with an image fill, `Card` → `column` with the design system's card
  decoration and padding). The printer writes the short name where one exists.
- **`.variant`**: a named look of that type from the design system (`Button.ghost`, `Text.title`,
  `Text.caption`, `Badge.success`). For text it is the theme text style.
- **`#id`**: only when something refers to the node. Otherwise the expander generates one from the type and
  position (`text3`), stable for a given tree.
- **`"text"`**: the node's main string: a text's text, a button's or toggle's `label`, a field's label, an
  image's source. `{name}` inside it reads a variable (`"Total: {total}"`).
- **`key:value`**: any prop, layout or decoration field by its own name, unquoted when it has no space
  (`gap:12 pad:16 width:200 fill:surface radius:8 min:0 max:100 hint:"you@example.com"`). The short keys `gap`
  (`spacing`), `pad` (`padding`), `fill` (the first fill's color) and `w`/`h` are accepted; every other key is
  the document's own.
- **Alignment words** stand alone: `start`, `center`, `end`, `between`, `stretch` on a row or column set its
  main-axis alignment; `top`, `middle`, `bottom` (row) or `left`, `right` (column) its cross axis.
- **`=expr`**: binds the node's value (`Slider =volume`, `Toggle "Wi-Fi" =wifi`, `Input "Email" =email`).
  For a control this is two-way: the expander writes the binding and the `changed` reaction that stores it. A
  key can be bound too: `visible:=step>0`, `text:=name`.
- **`-> action`**: what a tap (or `changed`, for a control) does. `name=value` sets a variable,
  `emit name` tells the host, `open id` / `close` a modal, `go screen` navigates, `toast "text"`. Several are
  separated by `;`. Any other action is written as its JSON.
- **Lists**: `each item in items` as a line; its children are the template (`Text "{item.name}"`).
- **Conditions**: `if expr` as a line shows its children when the expression holds (it expands to `visible`
  bindings; no new node).
- **State**: a line `state name=value` at the top declares a variable with a starting value. A variable that
  is only bound to a control needs no declaration; its type and start come from the control.
- **Project state**: `project name=value` reads a variable declared with the same name and starting value in
  `site.json`; it emits no page variable, so actions and controls use the shared value across pages.
- **Escape hatch**: `{...}` at the end of a line is merged into the node as JSON, for anything the notation
  has no word for. Using it is allowed and counted; a key that needs it often gets a word.
- **Time**: `every 1s -> seconds=seconds-1` on its own line runs as time passes (milliseconds, or `1s`);
  `every 1s when running -> …` only while the condition holds. It is a timer on the canvas.
- **A field of a repeated element**: under `each row in rows`, `Input =row.name` shows that field and writes the
  element back into `rows` on a change. `Column scroll` scrolls.
- **A node written whole**: `node {"type": "…", …}` on its own line is a node exactly as the document holds
  it, for what the notation has no word for (a painted board, a positioned shape, a draggable list). Its JSON may
  run over several lines; `node#id {…}` names it. Nothing is added to it but its place in the tree and the
  condition of an `if` above it, and the lines indented under it are its children, in the notation or as nodes
  again. This is rung 3 of the ladder in [design 15](15-the-middle-and-generated-apps.md).

Sizes not written follow one rule per parent: in a column a child fills the width and hugs its height; in a row
a child hugs both, and `grow` makes it take the rest; a control hugs; the root fills the surface it is given.

## 4. The approval card, both ways

As recorded: 19 operations, 1,897 output tokens. In the notation:

```
state decision="pending"
Card gap:12
  Text.title "Approve deletion?"
  Column gap:4
    Text "Folder: Shared Drive / Archive 2019"
    Text "Files: 214 files, about 3.8 GB"
    Text.danger "These files will be permanently deleted. This cannot be undone."
  Text.caption "First files that will be deleted:"
  Column fill:surface radius:6 gap:2 pad:8
    Text.small "budget_2019_q1.xlsx"
    Text.small "client_notes_old.docx"
    Text.small "site_photos_march.zip"
    Text.small "meeting_recording_04.mp4"
  if decision!="pending"
    Text.strong "Decision: {decision}"
  Row end gap:8
    Button.ghost "Deny" -> decision="denied"
    Button.destructive "Approve" -> decision="approved"; emit approved
```

And the owner's example, complete: `Column` with four zero-prop controls.

```
Column gap:12
  Slider =volume
  Input "Email" =email
  Toggle "Notifications" =notify
  Button "Save" -> emit save
```

## 5. How it runs

1. **Parse by line.** A streaming parser in `codelessly_api` (`lib/src/core/notation/`) takes text chunks and,
   at each newline, emits the edit operations for that line: a `set` for the node under its parent (with a
   placeholder size for children still to come, as `ui_apply` streams today), and `vars` for state it
   introduced. The first line produces the root and its canvas, so there is a frame after one line.
2. **Expand with the catalog and the design system.** Short names, variants, default sizes and the two-way
   binding come from tables generated from the catalog (level 1's types and their value props) and from the
   design system (variants, text styles, the card preset). No table is written by hand twice.
3. **Check as today.** The operations go through `applyOps` with the strict check at level `state`. A
   diagnostic is reported against the notation's line and column as well as the node.
4. **Print.** `printNotation(document)` writes any level 0 to 2 document back; what it cannot say in words
   goes in the `{...}` tail. The round trip is tested on every reference example within those levels and on the
   34 recorded cards' final documents.
5. **Hand over.** The session's tools are unchanged: `ui_apply` patches the same document by the generated ids,
   which `ui_read` shows in the notation.

## 6. What the agent is told

The prompt for levels 0 to 2 is generated, like the reference: the grammar above (about 400 words), one line
per type with its main string and the keys worth knowing, the design system's variants and text styles, and
three examples. The budget is 2,500 tokens, against 26,033 today. Higher levels are fetched with `ui_docs` when a
brief needs them.

## 7. The A2UI front end

A2UI's message format (a component list with ids and children, a data model, and actions) maps onto the same
expander: its components to level 1 types, its data model to variables, its actions to `emit`. It is a second
parser in front of step 2, not a second renderer, so an A2UI-tuned model drives this renderer with SSUI
defaults. It follows the head to head (design 12, phase E).

## 8. Measures for the head to head

Same briefs and models, three arms (A2UI on its renderer, the notation, `ui_apply`): prompt tokens, output
tokens, output tokens per node, time to first frame, time to complete, share valid on the first try, share usable
by eye, and the share of lines that needed the `{...}` tail.

## 9. Build order

1. The parser and expander for levels 0 and 1 with fixed defaults; the owner's four-control example renders.
2. State: `=`, `->`, `state`, `{name}`, `if`, `each`.
3. The printer and the round-trip tests.
4. The generated prompt, the session and chat-example wiring, line-and-column diagnostics.
5. Record the 34 briefs in the notation and compare with the table in section 1.

## 10. Measured (2026-11-14)

The first version is built (`lib/src/core/notation/`, `package:codelessly_api/notation.dart`): the parser, the
line-by-line stream, the generated prompt, `UiSession.applyNotation` in the SDK and a recorder in the chat example
(`tool/record_notation.dart`). The 17 card briefs were recorded on Claude Haiku 5.5 and Sonnet 5.5 with the same
settings as the `ui_apply` recordings (low effort, thinking off where the model allows it).

| | `ui_apply` | Notation |
|---|---|---|
| Prompt | 26,033 tokens | about 1,700 |
| Output per card, median | 3,300 tokens | 905 |
| Time to complete, median | 15.1 s | 4.75 s |
| Time to first token, median | 0.96 s | 0.63 s |
| Output per node | 137 tokens | 20.7 |
| Nodes per card, median | 24 | 44.5 |

The models write about twice as many nodes in under a third of the tokens and time. The per-node target of 15
tokens is not met yet (20.7): the remainder is mostly long state expressions, which are content, not envelope.

Validity went up by accepting what the models wrote, not by telling them more:

| Run | Valid on the first answer | After one retry |
|---|---|---|
| 1 (first parser) | 8 of 20 | 13 of 20 |
| 2 (`Grid cols`, `Progress 0.5`, `Box` with children, `Badge` variants, `enabled`) | 17 of 34 | 24 of 34 |
| 3 (headers and tiles from strings, growing children, expressions with quotes, prices) | 28 of 34 | 31 of 34 |
| Run 3's answers expanded again by the current parser (labels that read state, text style keys, segmented items, grid rows, parenthesised expressions) | | 33 of 34 |
| 5 (the prompt lists the formula functions that exist: about 2,380 prompt tokens, median output 935, 5.4 s) | 26 of 34 | 31 of 34 |
| Run 5's answers expanded again by the current parser (quotes inside `{…}`, expressions with spaces, an expression where the string goes, `List =rows`, `each rows`, a sentence after the UI) | | 34 of 34 |

The rule that came out of it: when two models independently write the same form and its meaning is not in
doubt, the notation takes that form. `tool/reexpand_notation.dart` expands recorded answers again with the
current parser, so a parser change is measured on real answers without calling a model.

Listing the functions did not raise first-answer validity (26 against 28) and cost about 700 prompt tokens; what
raised it was again accepting the forms written. Rendering the answers found layout rules the grammar needed: `each`
in a row goes across, `GridView` is `Grid`, a column in a row and its children are as wide as their content, an
accordion starts closed. Open: an `each` under a `Stack` cannot place its copies by `x`/`y` (a map's pins).

Not built yet: the printer and its round trip, diagnostics by line in the tool result, the
notation in the chat example's live path, and the A2UI front end.

## 11. Head to head with A2UI (2026-11-14)

The same 17 card briefs, the same two models and settings, three forms of answer. A2UI is v1.0 with its published
message schema, common types and basic catalog as the instructions (`examples/stream_chat/tool/a2ui_v1`, 64,046
characters), read by `parseA2ui` and drawn by this renderer with SSUI's defaults. Recordings:
`tool/stream/streams/live/2026-11-14-a2ui-1`.

| Median of 34 | `ui_apply` | Notation | A2UI v1.0 |
|---|---|---|---|
| Instructions | 26,033 tokens | 2,379 | 21,169 |
| Output | 3,300 tokens | 935 | 1,612 |
| Output per node | 137 tokens | 27.7 | 84.5 |
| Time to complete | 15.1 s | 5.4 s | 7.8 s |
| Time to first token | 0.96 s | 0.70 s | 0.80 s |
| Nodes drawn | 24 | 34.5 | 20 |
| Valid on the first answer | not measured this way | 26 of 34 | 23 of 34 |
| Valid after one retry | | 31 of 34 | 27 of 34 |
| Taps that change the card itself | | 158 | 0 |

By model: on Haiku 5.5 the notation takes 3.2 s for 29 nodes and A2UI 4.7 s for 11; on Sonnet 5.5, 8.4 s for 36
nodes against 15.5 s for 23, and A2UI's first token comes after 8.1 s (0.8 s for the notation).

What the numbers do not show, seen in the rendered sheets:

- **A2UI has no behavior in the card.** Every button tells the host; nothing is shown, hidden, counted or
  stepped locally. A checkout draws its four steps at once; a filter, a quantity stepper or "show file names" needs
  the agent to send a new surface. The notation's cards carry 158 local reactions between them.
- **A2UI's failures are structural.** Four of Haiku's answers were not valid JSON (a brace too many or too few in a
  5,000 character line), and two were refusals for want of data. The notation's failures were single lines, and
  the rest of the card still drew.
- **A2UI has nine layout words** and no charts, badges, progress or grids: a dashboard's chart came back as a row
  of block characters.
- Read with later versions of the parsers (the forms each model wrote, accepted): notation 34 of 34, A2UI 34 of
  34 of the answers that were JSON.

### 11.1 The same A2UI answers on A2UI's own renderer

The 34 recorded A2UI answers (the retry's where there was one) were then drawn by A2UI's own web renderer:
`@a2ui/web_core` 0.15.0's v1.0 message processor and basic catalog under `@a2ui/lit`'s `<a2ui-surface>`, with
its default styles, in Chromium at 390 wide. The harness is `examples/stream_chat/tool/a2ui_own_renderer`.

| Of 34 A2UI answers | A2UI's own renderer | CodelesslySDK through `parseA2ui` |
|---|---|---|
| Drawn as written | 20 | 34 |
| Drawn after renaming `@checks` and `@accessibility` | 29 | not needed |
| No surface at all | 3 (no valid `createSurface`) | 0: drawn from what was valid |
| Refused for another reason | 2 (an id with a hyphen; a `variant` given as an object) | 0 |

- **The published schemas and the renderer release disagree.** The v1.0 schemas a model is given spell a
  component's `@checks` and `@accessibility` with an `@`; release 0.15.0 validates each component strictly and
  reads them without, so 9 answers that follow the schemas are refused whole. A strict renderer in front of a
  model drops a card for one key.
- **Where both draw, they draw the same structure.** Their default look is plain (a gray card, large type); ours
  is SSUI. Their renderer shows Markdown in a text as written (`**Folder:**`) unless the host installs a Markdown
  renderer; `parseA2ui` reads the bold and heading marks.
- **Drawing theirs beside ours found four faults on our side**, now fixed: an icon with no size drew nothing; a
  row of repeated columns collapsed to no height in a card that hugs; a choice between sentences was a segmented
  control with its labels cut (it is a list of radios, as theirs); a card's body did not fill a height its call
  gave. Still different from theirs: a radio's label is one line (theirs wraps), a single choice starts unselected
  when the data model holds it as a list, and the render tool's bundled font has no arrow glyph.

Not compared: A2UI's Angular and Flutter GenUI renderers, or its renderer with a host's own styles and Markdown.

## 12. A design system's components

With a design system, the notation calls its components by their own names. The parser is given the design system's
catalog and options (`ds.catalogOver(catalog)`, `NotationOptions.fromDesignSystem(ds)`), the prompt its list
(`notationPrompt(designSystem: ds)`, narrowed with `only` when a chat needs a dozen and not all 160):

```
state seats=2
state plan="Pro"
Column gap:12 pad:16
  Row gap:8 middle
    Avatar name:"Ada Lovelace"
    StatusBadge "Active" tone:success
  Stepper =seats min:1 max:9
  TabToggle options:["Free","Pro"] =plan
  Panel "Billing" subtitle:"Plan and invoices"
    Text.muted "You are on the {plan} plan with {seats} seats."
  TrialBanner "7 days left in your trial" -> emit upgrade
```

- **The name.** A short name or a core type of that name comes first (`Button`, `Card`, `Slider`, `Badge` stay what
  they were); any other name the catalog holds is the component. The prompt leaves the shadowed ones out of its list.
- **Strings** fill the component's text parameters in order, at most two: its `label`, `title` or `text`, then its
  `message`, `description` or the like. One string alone goes to the parameter the component requires
  (`Banner "Saved."` is its message). A choice in place of a string (`ok ? "Approved" : "Denied"`) binds the same one.
- **`=name`** is the variable the component keeps its value in (its `value` parameter, else its first variable
  parameter); the variable is declared with the parameter's type.
- **`->`** runs on the component's first event (`onPressed`, `onChanged`, `onSelected`).
- **Size.** A call that writes none takes the component's own: as wide as its parent, as its content, or fixed, as
  its definition's root says.
- **What it does not take is said on the line**: `A StatusBadge has no "status". It takes: label, tone.`, and a
  required parameter left out: `A ContextMenu needs items: write items:["a","b"].`

In the prompt each component is one line, as it is called, with its purpose:
`Stepper "label" =value min max step enabled -> onChanged : A number changed one step at a time.` A name ending in
`!` must be given. SSUI's full list adds about 17,000 characters to the prompt.

Measured on two briefs with Haiku and SSUI's full list (2026-11-14): both read with no notation issue and no
validation error on the first turn; the approval card used `Dialog` and `Banner`, the dashboard `StatTile` and
`SegmentedControl`, at 21 to 24 output tokens a node.

## 13. The words a model reaches for (2026-11-15)

The notation's names were chosen from what models write. That was checked again above level 2: sixteen requests
needing a gauge, a dial, a ring, a sparkline or motion were given to Sonnet with no vocabulary at all, then with
the notation prompt (CodelesslySDK `examples/showcase/natural-words/`).

| Asked for | Written with no vocabulary | Written with the notation as it stood | Now |
|---|---|---|---|
| A speedometer, a load, a score | `gauge … needle value:72`, `arc from:0 to:100`, `marker at:100` | Boxes in a row, or the bare number | `Gauge 72 min:0 max:180 limit:100 unit:"km/h"` (a clean arc, the figure inside; `Dial` is the same) |
| A round share | `Ring value:7240 max:10000` | `CircularProgressIndicator` in a `Stack center middle` (rejected: a Stack took no such words) | `Ring 0.72`, and a `Stack` centers with `center middle` |
| A small trend line | `Sparkline data:[…]` | `LineChart` at full height with axes | `Sparkline values:[…]` |
| Fade, slide, pulse, shimmer | `animate:…`, `Animation type:fade-up trigger:on-appear duration:0.3s delay:0.2s` | Left out, or a timer changing a number | `animate:fade` (slide-up, slide-left, scale, pop, bounce, shake, pulse, spin, shimmer) with `duration:`, `delay:` |
| Rows arriving one after another | `delay` rising per row | Left out | `stagger:80` on the row or on its `each` |
| Swipe to delete | `swipe:left`, `onSwipe` | A guessed `{"interaction": …}` JSON, rejected at render | `swipe:left -> …` (also `onSwipeLeft`, `longPress`, `doubleTap` handlers) |
| A slider in steps | `step:1` | `step:1`, rejected at render | `step:` is the slider's `divisions` |
| A timer | `every 1s when running` with `->` on the next line | The same, rejected | Accepted |

Each is one more line of the parser onto a part the catalog already had (`radialGauge`, the animation presets,
the swipe triggers), and one line in the prompt (7,800 to 8,700 characters). With it, 16 of 16 answers expand
and use the words where the request calls for them. Judged blind against the old answers: above in 20 of 32
(6.47 against 5.81); the first look of `Gauge` (the catalog's segmented default with a needle) was worse than
the number the model used to draw by hand, and was changed to an arc with the figure inside before that
judging. 52 existing notation files expand byte-identically.

Not covered yet, in the order the model asked for them: a number that counts up; a card that flips; a list
reordered by drag; a sparkline bound to state. Not checked: that the animations play as written (the render is
a still), and levels 4 and 5 beyond these parts (custom paint, scripts, several pages, publishing), where the
notation hands over to `ui_apply`.

**Seven more areas, the same way** (forms, charts and tables, navigation, lists and gestures, media, full phone
pages, full desktop pages; ten requests each; `natural-words/areas/`). The forms the model wrote that the
notation or the renderer rejected were each given a reading: `center` across and `middle` down on every
container (a `Column center` was read as its middle, 105 lines in the recorded answers); a page of several
top-level sections; `Avatar`; `password` and `multiline` on an `Input`; `LineChart` with `series` and `labels`,
`AreaChart`, `Donut`; guessed props in a JSON tail read as the key they are, or named at their line; a `Stack`
placed with left, right, top, bottom; a `Text` aligned or struck through; an `IconButton`'s color and size;
`gradient:`; single quotes holding spaces; a row's fixed widths as shares when they do not fit; `maxw:`. Over
the 70 requests the notation's issues went from 15 to 9 and the renderer's errors from 51 to 18.

One of these changes how existing notation expands, with or without a design system: `Column center` now centers
the column's children side to side, where it gathered them at the column's middle. It is what every one of the
105 recorded uses meant (an icon over its label, a centered figure), and the prompt's line was rewritten to say
it. `Column middle` gathers them at the middle.

Still asked for and not read: links and hover; a dialog, sheet or drawer as an element; a table as an element;
chart legends and axes; a chart bound to state; reorder with a handle; pull to refresh; a map; shapes.

## 14. A page at other widths (2026-11-15)

A page is written once, for a desktop (`--width 1280`). The twenty sites of test 5 showed what that does on a
phone: three cards squeezed across 390 px, a table's fixed columns past the edge, a sidebar beside its content,
and a layout error for each. Over ten showcase pages, written with no thought for a phone: 74 render errors at
390 wide and 52 at 834, none at 1440.

The expander now adds the media rules that make a page fit (`reflow.dart`, `PageReflow`), from 700 wide on
(`NotationOptions.reflow`, on by default; `expand --no-reflow` leaves the page as written). Every rule holds
below a width (`maxWidth` 1023: a tablet and narrower; 699: a phone), so the page at the width it was written for
is the same document as before plus rules that do not apply there.

| Written | Narrower |
|---|---|
| `Grid cols:n` | its rows wrap; a cell takes a least width (300, 220, 260, 150 for 2, 3, 4, more columns), so three stay three on a tablet and four become two by two; one a line on a phone. A grid over data takes fewer columns (`crossAxisCount`) |
| a `Row` of two or more blocks (a card, a column of content, a picture, a component that fills, a fixed column 200 or wider) | wraps: a block that grows takes a least width (360 for the one beside fixed rails, else 280, 240 among three), a fixed one keeps its width on a tablet and takes the line on a phone |
| any other `Row` | wraps before it overflows; what grows in it keeps its share of the line from a least width (a field 180, a component 160, a text 96) |
| a table's row (three or more cells with widths) | its cells are shares of the row; it keeps the columns it has room for, from the first on (600 px on a tablet, 342 on a phone), and what is not a column (a checkbox, a menu button) |
| `App` | a phone shows `Main`; a tablet also the panes before it, less the first when two take over 420 |
| `Nav` | a phone hides its links (a tablet too, from six on) |
| `Section`, `Footer` | 48 above and below on a tablet; 40, and a 20 gutter, on a phone |
| a text 32 or larger | 0.86 of its size on a tablet (from 44), 0.72 on a phone (26 at least) |
| a fixed width over 300 in a column | as wide as its place on a phone, at most its width |
| `Donut` with `labels` | on a page it is a wrapping row of the chart and its legend (a line per share: its color, its label, its part of the whole): the legend sits beside the chart and goes under it where the two do not fit (`legend:false`: the chart alone; a page that writes the labels as texts of its own keeps its own legend) |

`hide:phone`, `hide:tablet`, `show:phone` and `show:tablet` on a line say where it shows; they are written after
the rules above, so they win.

Rows wrap (`wrap` with `basis` on the children: CSS `flex-wrap` and `flex-basis`) where they could have turned
into columns at a width: a wrapping row follows the room it has, so a row in a narrow pane stacks sooner than
one across the page, and a child keeps its place in the tree. The rules are by the window's width only so that
the desktop page cannot change.

With the rules, the same ten pages: 0 errors at 390, 0 at 834, 0 at 1440. Seven of the test 5 sites (50 pages), re-expanded with no change to their notation: 130 errors at 390 down to 2, 8 at 834 down to 0, and 49 of the 50 desktop captures identical to the byte (the other gained its donut's legend). A design system's own blocks carry
their rules themselves (Cards' `SiteNav` hides its links and its second action on a phone).

Not done: a `Nav`'s hidden links and an `App`'s hidden sidebar have no menu to open them on a phone unless the
page writes one (`show:phone`); a table drops columns where a designer might have made each row a card.

## 15. Open points

- Whether `Card` and the text variants are fixed words or come only from the design system (a design system
  without a card would then have no `Card`). Proposed: from the design system, with SSUI's as the built-in.
- Positional alignment words against `align:end`. Proposed: both parse, the printer writes the words.
- Whether the root is always a column. Proposed: the first line is the root, whatever it is; the canvas around it
  is implied.
