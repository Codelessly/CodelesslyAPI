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
   takes a named style. Colours are theme names.
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
  (`spacing`), `pad` (`padding`), `fill` (the first fill's colour) and `w`/`h` are accepted; every other key is
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
- **Escape hatch**: `{...}` at the end of a line is merged into the node as JSON, for anything the notation
  has no word for. Using it is allowed and counted; a key that needs it often gets a word.

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

## 11. Open points

- Whether `Card` and the text variants are fixed words or come only from the design system (a design system
  without a card would then have no `Card`). Proposed: from the design system, with SSUI's as the built-in.
- Positional alignment words against `align:end`. Proposed: both parse, the printer writes the words.
- Whether the root is always a column. Proposed: the first line is the root, whatever it is; the canvas around it
  is implied.
