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
4. **State is as short as layout.** A variable exists by being used. A binding is `bind=name`, a reaction is an
   event with its actions in braces (`onTap={…}`).
5. **Streams.** Every line is complete when its newline arrives, and can be drawn then: a parent is declared
   before its children, never closed before them.
6. **Round trips.** Any document within levels 0 to 2 prints back as the notation, and parsing the print gives
   the same document. That is the test, and it is what lets an agent read a UI in the form it writes.

## 3. The grammar

Rewritten 2026-11-16 to one rule per role, as the owner decided it after a test with two models
([17-notation-grammar-audit.md](17-notation-grammar-audit.md) has the audit and the reasons;
[18-notation-grammar-migration.md](18-notation-grammar-migration.md) what changed for a file written before).
Indentation is nesting (two spaces). One node per line:

```
Type[.variant][#id] ["text"] [key=value ...]
```

Everything after the text is `key=value`, and three things are said with it:

| Written | Says | Example |
|---|---|---|
| `key=value` | this node has this value | `gap=12 w=fill icon="waves" items=["A","B"]` |
| `key={expression}` | the value is worked out from the state (the braces a text uses: `"Total: {total}"`) | `visible={count > 0}` |
| `on…={actions}` | what happens: after an `on…` key the braces hold actions | `onTap={count=count+1; toast "Saved"}` |

`=` is one "is" everywhere: a parameter's value, a variable's start (`state qty=1`), what an action makes a
variable (`qty=qty+1`).

- **Type**: a node type, capitalised (`Column`, `Text`, `Slider`). A few natural short names are accepted and
  expand to the full type in the document (`Input` → `textField`, `Toggle` → `switch`, `Button` → `filledButton`,
  `Select` → `dropdown`, `Image` → `box` with an image fill, `Card` → `column` with the design system's card
  decoration and padding). The printer writes the short name where one exists.
- **`.variant`**: a named look of that type from the design system (`Button.ghost`, `Text.title`,
  `Text.caption`, `Badge.success`). For text it is the theme text style.
- **`#id`**: only when something refers to the node (`open id`, `scroll id`, an edit). Otherwise the expander
  generates one from the type and position (`text3`), stable for a given tree. `id=name` on a line is an anchor
  a `scroll name` goes to; the node keeps its own id. (`project name=value` is a variable of the site: beside
  site.json it is the site's, with no copy on the page; a page expanded alone declares it itself; a name the
  site's variables lack is said.) An id is a fixed name: one written from the data
  (`Row#row-{row.id}`) is its fixed part (`row`), since every copy an `each` makes is the one node. An id given
  twice names the line that has it; the two branches of an `if`/`else` cannot share one (the document holds
  one node per id), and that is said with what to write instead. What the expander names itself (an `App`'s
  sidebar drawer, `<screen>_sidebar`) takes no name an author would write. An id is one word of letters, digits
  and `_`, as a variable's name is (a list's selection, a drawer's state and the like are named after it):
  `Dialog#live-image` is said once, at the id, and read as `live_image` there and in the `open`, `scroll` and
  `focus` that name it, so one hyphen is one issue and not a page of them. (A screen's id, which only `go` and
  links name, may have hyphens: `go case-study`.)
- **`"text"`**: the node's main string: a text's text, a button's or toggle's `label`, a field's label, an
  image's source. `{name}` inside it reads a variable (`"Total: {total}"`).
- **`key=value`**: any prop, layout or decoration field by its own name, unquoted when it has no space
  (`gap=12 pad=16 width=200 fill=surface radius=8 min=0 max=100 hint="you@example.com"`). A list is JSON
  (`items=["S","M","L"]`). The short keys `gap` (`spacing`), `pad` (`padding`), `fill` (the first fill's color)
  and `w`/`h` are accepted; every other key is the document's own. A bare word after `=` is that word
  (`tone=quiet`), never a variable.
- **`key={expression}`**: a value worked out from the state is the expression in braces, spaces and quotes
  included (`visible={step > 0}`, `selected={tab == "all"}`, `fill={on ? "#FF2563EB" : "#FFE5E7EB"}`). A map as a
  value names a key first (`{"a": 1}`) and is the JSON it is; a list worked out is `values={[a+1, b]}`.
- **A bare word** is a flag (`sticky`, `scroll`, `hidden`, `password`: the key with the value true) or an
  alignment word: `start`, `center`, `end`, `between`, `stretch` on a row or column set its main-axis alignment;
  `top`, `middle`, `bottom` (row) or `left`, `right` (column) its cross axis. `grow` takes the room that is left.
- **`bind=name`**: the variable a control keeps its value in (`Slider bind=volume`, `Toggle "Wi-Fi" bind=wifi`,
  `Input "Email" bind=email`): a parameter like any other. It is two-way: the expander writes the binding and
  the `changed` reaction that stores it, and declares the variable from the control's type. On what only shows
  a value (`Progress`, `Gauge`, `Ring`) it follows the variable, or an expression: `Progress bind={done/total}`.
- **`on…={actions}`**: what a node does. `onTap` is a tap on anything; `onChange` a control's change (`result` is
  its new value); also `onLongPress`, `onDoubleTap`, `onRightClick`, `onSwipeLeft` (`Right`, `Up`, `Down`),
  `onHover`, `onFocus`, `onBlur`, `onSubmit`, `onDrop`. A design system's block has its own
  (`SiteNav … onNavigate={go {lower(result)}} onCta={go signup}`), and `onTap` on a block is its first one. An
  event a plain node does not have is said. `menu=id` opens that Menu on a right click or a long press.
- **Actions**, separated by `;`: `name=value` sets a variable, `emit name [value]` tells the host, `open id` /
  `close` a modal, `go page` navigates, `scroll id`, `toast "text"`, `link url`, `focus id` (the caret in that
  field; `blur` takes it away), `copy text` (`copy link`, `copy "{link}"`: to the clipboard). A verb's argument is the word
  written (`go pricing` is that page); one that is worked out is in braces (`go {lower(result)}`); a bare
  name the state has (`go result`, `go tab`, `go item.slug`) is the page it holds, as in braces, unless it names
  one of the app's screens (`NotationOptions.screens`, `notationScreen`: its id, written with `_` or capitals, or
  the one screen its words make, `go cook` for "Cook mode"): that is the screen, whatever a variable of the same
  name holds (`go recipes` beside a list called recipes). Any other
  action is written as its JSON. A choice between actions is `cond ? action(s) : action(s)` (`onTap={dirty ?
  open leave : go members}`): each branch one action or a braced list `{a; b}`, either may be empty (`done ?
  close :`), a branch may choose again; it is an `if` action. A value chosen is a formula: `step = valid ? 3 : 2`
  sets `step`.
- **Lists**: `each item in items` as a line; its children are the template (`Text "{item.name}"`).
- **Conditions**: `if expr` as a line shows its children when the expression holds (it expands to `visible`
  bindings; no new node), `else` after it; `visible={expr}` on one line. `selected={expr}` on a line whose
  type has no selected value is the node's selected state (a box takes the theme's selected fill). `hide=phone` and `show=tablet` take a
  size, never a condition (section 14).
- **State**: a line `state name=value` at the top declares a variable with a starting value. A variable that
  is only bound to a control needs no declaration; its type and start come from the control. `state
  total=sum(cart,x=>x.price)` names a formula, written out where it is read. A whole number starts an integer,
  which rounds what it is given; once an action may give it a fraction (`zoom=zoom*1.25`, `share=done/total`, a
  decimal variable) or a control that writes decimals is bound to it (a Slider), it is declared a decimal. A
  state named as the runtime names what every expression of a screen reads (`script`, `route`, `data`, `drag`)
  would never be read as itself: that is said, with the name to write. A variable a line implies (`Select
  bind=moveTo`) that the site's variables already declare is the site's, never a second copy.
- **Escape hatch**: `{…}` at the end of a line is merged into the node as JSON, for anything the notation
  has no word for. Using it is allowed and counted; a key that needs it often gets a word.
- **Time**: `every 1s onTick={seconds=seconds-1}` on its own line runs as time passes (milliseconds, or `1s`);
  `every 1s when running onTick={…}` only while the condition holds. It is a timer on the canvas.
- **Keys**: `key mod+k onPress={…}` on its own line is a shortcut of the screen (a `keyDown` reaction on the
  canvas). Its key is named as a key event names it: a character, or Enter, Escape, Space, Tab, Backspace,
  Delete, Home, End, PageUp, PageDown, an arrow, F1 to F12; the names writers give them are read as those keys
  (`left` is ArrowLeft, `alt+right` alt+ArrowRight, `del` Delete), and a name no key has (`key foo`) is said,
  since it would never fire. `shortcut="mod+b"` on a line that is tapped (`Button "Bold" shortcut="mod+b"
  onTap={…}`, a block's tap event) is that key line with the line's tap actions, and the line's tooltip names
  the key (`Ctrl+B`; one text on every platform, so mod is said as Ctrl, where a Text's own `shortcut=` hint
  follows the platform). On a line with no tap, or under an `each` (one key cannot press every copy), it is
  said, pointing to `key`.
- **A field of a repeated element**: under `each row in rows`, `Input bind=row.name` shows that field and writes
  the element back into `rows` on a change. `Column scroll` scrolls. So does a field of a record variable
  (`Input bind=draft.title` sets `draft`), a field of an element of a list held by the element around it
  (`Checkbox bind=s.done` under `each s in e.sets` under `each e in workouts`), and a field of an element of a
  list worked out (`each d in filter(devices, …)`) when its records have an `id` (written into `devices` by it).
  A design system's control is given the field's path for its variable parameter (`"rows[" + index +
  "].done"`), which it reads and writes as a variable. A list worked out with no `id` is said, with the line
  to write instead.
- **A node written whole**: `node {"type": "…", …}` on its own line is a node exactly as the document holds
  it, for what the notation has no word for (a painted board, a positioned shape, a draggable list). Its JSON may
  run over several lines; `node#id {…}` names it. Nothing is added to it but its place in the tree and the
  condition of an `if` above it, and the lines indented under it are its children, in the notation or as nodes
  again. This is rung 3 of the ladder in [design 15](15-the-middle-and-generated-apps.md).

Sizes not written follow one rule per parent: in a column a child fills the width and hugs its height; in a row
a child hugs both, and `grow` makes it take the rest; a control hugs; the root fills the surface it is given.

**The grammar before (to 32.x) is not read.** `key:value`, `=name`, `key:=expression`, `-> actions`, a handler on
a line of its own, `swipe:left ->`, an expression written bare after a key or where the text goes, a block's
enumerated value written as a bare word: each is an error on its line that says what to write (`A value is
written with =, not a colon: gap=12.`). CodelesslySDK's `tool/notation/notation.sh migrate <file>` rewrites a file.
**Read, though not taught** (what a model writes unprompted that is no second way to write a parameter, a
binding, a computed value or a handler): `let` / `const` / `var name = …` and a bare `name = value` line for
state, `for x in list` and `each list`, `else`, `n += 1`, `n++`, `rows.add(x)`, `if (c) { … } else { … }` inside actions (the same `if` action as `c ? … : …`),
`$name`, single quotes in an expression, `"${…}"` in a text, `sticky=true`, a code fence around the answer, a
guessed prop in a `{…}` tail, `onTap` on a block for its first event.

## 4. The approval card, both ways

As recorded: 19 operations, 1,897 output tokens. In the notation:

```
state decision="pending"
Card gap=12
  Text.title "Approve deletion?"
  Column gap=4
    Text "Folder: Shared Drive / Archive 2019"
    Text "Files: 214 files, about 3.8 GB"
    Text.danger "These files will be permanently deleted. This cannot be undone."
  Text.caption "First files that will be deleted:"
  Column fill=surface radius=6 gap=2 pad=8
    Text.small "budget_2019_q1.xlsx"
    Text.small "client_notes_old.docx"
    Text.small "site_photos_march.zip"
    Text.small "meeting_recording_04.mp4"
  if decision!="pending"
    Text.strong "Decision: {decision}"
  Row end gap=8
    Button.ghost "Deny" onTap={decision="denied"}
    Button.destructive "Approve" onTap={decision="approved"; emit approved}
```

And the owner's example, complete: `Column` with four zero-prop controls.

```
Column gap=12
  Slider bind=volume
  Input "Email" bind=email
  Toggle "Notifications" bind=notify
  Button "Save" onTap={emit save}
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
2. State: `=` and `->` (now `bind=name` and `onTap={…}`), `state`, `{name}`, `if`, `each`.
3. The printer and the round-trip tests.
4. The generated prompt, the session and chat-example wiring, line-and-column diagnostics.
5. Record the 34 briefs in the notation and compare with the table in section 1.

## 10. Measured (2026-11-14)

The first version is built (`lib/src/core/notation/`, `package=codelessly_api/notation.dart`): the parser, the
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
| Run 5's answers expanded again by the current parser (quotes inside `{…}`, expressions with spaces, an expression where the string goes, `each row in rows`, `each rows`, a sentence after the UI) | | 34 of 34 |

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
Column gap=12 pad=16
  Row gap=8 middle
    Avatar name="Ada Lovelace"
    StatusBadge "Active" tone=success
  Stepper bind=seats min=1 max=9
  TabToggle options=["Free","Pro"] bind=plan
  Panel "Billing" subtitle="Plan and invoices"
    Text.muted "You are on the {plan} plan with {seats} seats."
  TrialBanner "7 days left in your trial" onUpgrade={emit upgrade}
```

- **The name.** A short name or a core type of that name comes first (`Button`, `Card`, `Slider`, `Badge` stay what
  they were); any other name the catalog holds is the component. The prompt leaves the shadowed ones out of its list.
- **Strings** fill the component's text parameters in order, at most two: its `label`, `title` or `text`, then its
  `message`, `description` or the like. One string alone goes to the parameter the component requires
  (`Banner "Saved."` is its message). A choice in place of a string (`ok ? "Approved" : "Denied"`) binds the same one.
- **`bind=name`** is the variable the component keeps its value in (its `value` parameter, else its first variable
  parameter); the variable is declared with the parameter's type.
- **Events** are written by their own names (`onPressed={…}`, `onChanged={…}`, `onSelected={…}`); `onTap={…}` is the
  component's first.
- **Size.** A call that writes none takes the component's own: as wide as its parent, as its content, or fixed, as
  its definition's root says.
- **What it does not take is said on the line**: `A StatusBadge has no "status". It takes: label, tone.`, and a
  required parameter left out: `A ContextMenu needs items= write items=["a","b"].`
- **Lines under it.** A component with children takes them. One that takes none but has slots (a `ListRow`'s
  `trailing`, a `SectionHeader`'s or an `EmptyState`'s `actions`) puts the lines indented under it in its slot
  (`trailing`, else `actions`, else the first), side by side in a row of their own; its prompt line says
  `(lines: actions)`. Under any other, a line is said (`A StatusBadge takes no lines under it (it has no children
  and no slot): write this line after it, at its own indent.`) and drawn after it.

In the prompt each component is one line, as it is called, with its purpose:
`Stepper "label" bind=value min max step enabled onChanged : A number changed one step at a time.` A name ending in
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
| A speedometer, a load, a score | `gauge … needle value:72`, `arc from:0 to:100`, `marker at:100` | Boxes in a row, or the bare number | `Gauge 72 min=0 max=180 limit=100 unit="km/h"` (a clean arc, the figure inside; `Dial` is the same) |
| A round share | `Ring value:7240 max:10000` | `CircularProgressIndicator` in a `Stack center middle` (rejected: a Stack took no such words) | `Ring 0.72`, and a `Stack` centers with `center middle` |
| A small trend line | `Sparkline data:[…]` | `LineChart` at full height with axes | `Sparkline values=[…]` |
| Fade, slide, pulse, shimmer | `animate:…`, `Animation type:fade-up trigger:on-appear duration:0.3s delay:0.2s` | Left out, or a timer changing a number | `animate=fade` (slide-up, slide-left, scale, pop, bounce, shake, pulse, spin, shimmer) with `duration=`, `delay=` |
| Rows arriving one after another | `delay` rising per row | Left out | `stagger=80` on the row or on its `each` |
| Swipe to delete | `swipe:left`, `onSwipe` | A guessed `{"interaction": …}` JSON, rejected at render | `onSwipeLeft={…}` (also `onLongPress`, `onDoubleTap`) |
| A slider in steps | `step:1` | `step:1`, rejected at render | `step=` is the slider's `divisions` |
| A timer | `every 1s when running` with `->` on the next line | The same, rejected | `every 1s when running onTick={…}`, on one line |

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
| `Grid cols=n` | its rows wrap; a cell takes a least width (300, 220, 260, 150 for 2, 3, 4, more columns), so three stay three on a tablet and four become two by two; one a line on a phone. A grid over data takes fewer columns (`crossAxisCount`). A grid whose columns mean something keeps them at every width and its cells shrink: seven columns (the days of a week: a month, a streak, a timetable), five or more cells that are small (at most three nodes each, no card or component: a number, a dot), or a grid written `keep` (`Grid cols=4 keep`). A grid of one cell repeated (`each`, on a page or in a defined word's lines) is a board and keeps its columns when its cell is a key (a button, or what has a tap) and small, from three columns on (a keypad, 3 by 4), or, from five on, small or of a fixed side of at most 64 with no card or component in it (a crossword's square, a seat); the node the notation wraps each copy in is not counted. A grid takes up to 24 columns (a 13 by 13 crossword) |
| a `Row` of two or more blocks (a card, a column of content, a picture, a component that fills, a fixed column 200 or wider) | wraps: a block that grows takes a least width (360 for the one beside fixed rails, else 280, 240 among three), a fixed one keeps its width on a tablet and takes the line on a phone |
| any other `Row` | wraps before it overflows; what grows in it keeps its share of the line from a least width (a field 180, a component 160, a text 96) |
| a table's row (three or more cells with widths) | its cells are shares of the row; it keeps the columns it has room for, from the first on (600 px on a tablet, 342 on a phone), and what is not a column (a checkbox, a menu button) |
| `App` | a phone shows `Main`; a tablet also the panes before it, less the first when two take over 420. The `Sidebar` it hides opens as a drawer (14.2); a list beside its detail shows one at a time (14.4) |
| `Footer` in `Main` (or in `App`, or `Row sticky bottom`; also read: `StickyBar`, `StickyFooter`, `BottomBar`, `FooterBar`, `BottomDock`) | a bar at the foot of `Main` at every width (a now-playing bar, a composer, a basket): `Main` stops scrolling as a whole, what else is in it scrolls in a column that takes the room above the bar. A `Footer` written in `App` goes to the foot of its `Main` |
| `Nav` | a phone hides its links (a tablet too, from six on) and shows a menu button the bar adds itself, which opens the links in a column under the bar, each as written and closing the menu as it goes; a `Nav` with a `show=phone` line of its own keeps its own |
| `Section`, `Footer` | 48 above and below on a tablet; 40, and a 20 gutter, on a phone |
| a text 32 or larger | 0.86 of its size on a tablet (from 44), 0.72 on a phone (26 at least) |
| a fixed width over 300 in a column | as wide as its place on a phone, at most its width |
| `Donut` with `labels` | on a page it is a wrapping row of the chart and its legend (a line per share: its color, its label, its part of the whole): the legend sits beside the chart and goes under it where the two do not fit (`legend=false`: the chart alone; a page that writes the labels as texts of its own keeps its own legend) |

`hide=phone`, `hide=tablet`, `show=phone` and `show=tablet` on a line say where it shows; they are written after
the rules above, so they win.

Rows wrap (`wrap` with `basis` on the children: CSS `flex-wrap` and `flex-basis`) where they could have turned
into columns at a width: a wrapping row follows the room it has, so a row in a narrow pane stacks sooner than
one across the page, and a child keeps its place in the tree. The rules are by the window's width only so that
the desktop page cannot change.

With the rules, the same ten pages: 0 errors at 390, 0 at 834, 0 at 1440. Seven of the test 5 sites (50 pages), re-expanded with no change to their notation: 130 errors at 390 down to 2, 8 at 834 down to 0, and 49 of the 50 desktop captures identical to the byte (the other gained its donut's legend). A design system's own blocks carry
their rules themselves (Cards' `SiteNav` hides its links and its second action on a phone).

From the twenty sites' follow-up runs (each on its own `dsl5/<site>` branch), what several met was folded in
once: a size word holds on a line under an `if` (five agents fixed it separately); `Nav` builds its own phone
menu (nearly every agent had written one by hand on every page); `Nav sticky`; `scroll <id>` and anchors
(`#pricing` after a line, `id=pricing`, `href="#pricing"`); `go` to a page worked out; `project name=value`
for a variable of the site; two short columns side by side as blocks; a control with choices keeps room for
them.

Not done: a table drops columns where a designer might have made each row a card.

### 14.1 What is shown over a page: Dialog, Sheet, Drawer, Menu, Popover, Lightbox

The document has modals (`openModal` shows another canvas as a dialog, a sheet, a popover), and the notation had
` onTap={open <id>}` for them, but a text was one canvas, so there was nothing to open. An overlay is now written in
the same text, after the page, at the margin, with an id; the lines indented under it are its content:

```
state email=""
Page
  Section
    Button "Join" onTap={open signup}
    IconButton "more_horiz" onTap={open more}

Dialog#signup "Join the waitlist" "We write once."
  Input "Email" bind=email
  Button "Join" onTap={joined=true; close}

Menu#more end
  MenuItem "Share" icon="share" onTap={toast "Shared"}
```

Each block is a canvas of its own in the document (a root after the page's, named by its id), and `open <id>`
takes how it is shown from the kind of block, wherever the `open` is written (before the block, after it, in
another overlay):

| Written | Canvas | `open` adds |
|---|---|---|
| `Dialog#id "Title" "Line under it"` (`Modal`) | 480 wide (`w:`), as tall as its content; a column `pad=24 gap=16` headed by the title and a close button | `presentation: dialog`, `insets: [16,24,16,24]` (it narrows to a phone) |
| `Sheet#id "Title"` (`BottomSheet`) | 560 wide, headed the same | `presentation: bottomSheet`, `sheetWidth`, `sheetRadius: 20`, `showDragHandle`, `maxHeightFactor: 0.9`: across a phone's bottom edge, a centered 560 on a desktop |
| `Drawer#id "Title"` (`right`, `w=300`) | the window's size, see-through: an `App` row of a `Sidebar` panel and a box beside it that closes on a tap | `presentation: dialog`, `cover: true` |
| `Menu#id` (`Dropdown`; `end`, `above`, `center`, or `placement:`) | 220 wide, `pad=6 gap=2`, outlined | `presentation: popover`, `anchor: trigger`, `placement: belowStart`, `anchorGap: 6` |
| `Popover#id` (`Popup`) | 320 wide, `pad=16 gap=12`, outlined | as a menu |
| `Lightbox#id "{photo}" "Caption"` | the window's size, see-through: the picture contained in it, zoomed and panned; a list of them is a gallery (14.3) | `presentation: dialog`, `cover: true`, `barrierColor: #F2000000`, a `routeTransition` a drag down reverses |

- **Closing.** `close` closes the overlay it is written in; a tap outside closes any of them. Every line of a
  `Menu` closes it after its own actions (`MenuItem "Price" onTap={sort="Price"}` is `sort="Price"; close`), and so
  does a `NavItem` or a `Link` in a `Drawer`; nothing else closes by itself. `open` waits for what it opened, so
  a menu line that opens a dialog closes the menu when the dialog closes.
- **Values.** A canvas's variables are its own (`variables` under its id), so a modal could not read the page's.
  A text with an overlay declares its variables under `page_variables` instead (every canvas of the document):
  the dialog's form sets the page's value and the page shows it. As it streams, the variables sent so far move
  there when the first overlay arrives (`vars` remove, then set). A text with no overlay is as before.
- **A design system's own frames.** Top level with an id is the only place a block is read; `Dialog` anywhere
  else is still the design system's component. Where the design system has a `Dialog` or a `MenuPopover`, the
  block's root is that component (its title, its close button, which closes) and the canvas draws nothing; else
  the canvas is the surface (the card's fill, a corner, a shadow). `MenuItem` is the design system's, or the
  plain row `NavItem` is.
- **Laid out as a card.** An overlay is expanded as a narrow canvas of its own (its width, 640 at most for the
  sizing rules), so a child is as wide as its column and nothing of the page's reflow touches it.
- **A menu for one of many.** ` onTap={sel=row.id; open rowMenu}` on the row's button, and the menu's lines read `sel`.
  `menu=rowMenu` on any line opens that menu on a right click and on a long press, where the pointer is
  (`anchor: pointer`); `onRightClick={sel=row.id; open rowMenu}` does the same after setting what was clicked.
- An id is the canvas's, so it is one of a kind in the site, as a page's is.

### 14.2 An App's sidebar on a phone

`App` hid its `Sidebar` on a phone and left no way to it. Where reflow is on, the first pane of an `App`, when it
is a `Sidebar`, is kept as written, and at the end of the text it is written again as `Drawer#<screen>Menu`: the
same lines with their ids left off and `close` after every action, so a tap on a `NavItem` picks the place and
closes the drawer. The `Nav` of `Main` gets `IconButton "menu" show=phone onTap={open <screen>Menu}` as its first
child (`show=tablet` where a tablet hides the sidebar too: two panes before `Main`, over 420 wide), and where
the button shows, what follows it (the title) takes the room beside it, so the button and the title sit
together and the actions stay at the end. A `Main` with no `Nav` gets a slim bar holding the button, shown at
those widths only. At the width it was written for the page has one more node, hidden, and its captures are
the same to the byte.

Not done: a drawer fades in as a dialog does (the document's `sideSheet` slides, but only from the right); an
`open` cannot pass a value (`params`), so a row's menu goes through a variable; a `Sidebar` written after
`Main`, or a component called with `items:`, gets no drawer.

### 14.3 A picture large, and a gallery: what a Lightbox does

A `Lightbox` was a picture contained in the window that a tap closed. It is now a viewer, built from what the
document already has (`transformGesture`, `pageView`, `keyDown`, a route's `dismiss`), so every design system gets
it and nothing is drawn by a control of its own:

```
state photos=[{"url":"a.jpg","caption":"The quay","ratio":1.5},{"url":"b.jpg","caption":"The tower","ratio":0.66}]
Page
  Section
    Grid cols=4 gap=12
      each p in photos
        Image "{p.url}" h=160 radius=12 onTap={at=index; open shots}
    Image "{cover}" onTap={open zoom}

Lightbox#shots photos={photos} bind=at
Lightbox#zoom "{cover}" "The harbor at dusk" ratio=1.5
```

| Written | What it is |
|---|---|
| `Lightbox#id "{photo}" "Caption"` | one picture, its caption in a pill at the foot |
| `Lightbox#id photos={list} bind=at` (`images:`, `items:`) | a gallery: a page per element, opened at `at` (from 0, as `Pages bind=page`; without `bind=name` it keeps `<id>At`). An element is a URL, or a record with `url` (`src`, `image`), `caption` (`title`) and `ratio`. A list written out (`photos=["a.jpg","b.jpg"]`) is kept in `<id>Photos` |
| `ratio=1.5` (or a record's `ratio`) | the picture's width over its height |
| `thumbs=false`, `max=6` | no strip of thumbnails; the largest zoom (4) |
| lines under a gallery | draw one picture (`photo` is the element) in place of the `Image`: a drawn scene, a chart. They are read again for the thumbnail |

- **Zoom.** The picture's box has `transformGesture: {target: node, pan: whenZoomed, minScale: 1, maxScale: 4,
  doubleTapScale: 2, wheel: zoom, bounds: cover}`: a pinch and the wheel (a trackpad's pinch) zoom about the point
  under them, a double tap goes to 2x where it was tapped and back to 1x, a drag pans while it is zoomed, and the
  picture is kept over its place: no gap shows where it is larger, and it stays centered where it is smaller. The
  zoom is written to `<id>Zoom`, which shows as `2×` at the top and hides the caption, the arrows and the
  thumbnails while it is over 1.
- **Closing.** The close button, Escape, a tap on the scrim (only while the picture is at rest), and a drag down:
  the open action carries `routeTransition: {enter: {motion: {opacity: 0, shiftY: 0.12}}, durationMs: 220, dismiss:
  {direction: down, distance: 0.2}}`, so it fades in rising a little and a drag takes it back the same way under
  the finger. While zoomed a drag pans instead (the zoom claims it first).
- **A gallery.** A `pageView` bound to `at`: a swipe turns the page while the picture is at rest (zoomed, the
  drag is the picture's), the round arrows at the sides (not on a phone) and the arrow keys step it within the
  list, a thumbnail goes to its picture, and the count reads `3 / 8`. As the page turns the picture left behind
  is reset (`controlTransform reset`) and `<id>Zoom` is 1 again.
- **The picture's box.** A box with an image fill does not take its picture's proportions, and the document
  cannot read them. With a `ratio` the box that zooms is the picture exactly: a tap on it leaves the viewer
  open, and it cannot be panned out of view. Without one the box is the whole place between the bars and the
  picture is contained in it: a tap there closes (it may be the scrim), and at a high zoom the bars beside a
  narrow picture can be panned into view. A design system's drawn `Media` scene is 3:2.
- **A design system's gallery.** A component with `photos` and `viewer="overlay"` among its parameters (Cards'
  `PhotoGallery`) is given `viewer="overlay"` on a page, and after its own actions its first event sets
  `<screen>ViewerPhotos` and `<screen>ViewerAt` and opens `Lightbox#<screen>Viewer`, written once at the end of
  the text as an App's drawer is: one viewer for every gallery of the page, also for one under an `each`. Its own
  variable is 0 again once the viewer closes. On a card, with `layout="pages"`, or with `viewer:` written, the
  line is as written.

Not done: the strip of thumbnails does not scroll to the picture in view; the arrows do not wrap round; a
picture's proportions are not read from the picture.

### 14.4 A list beside its detail on a phone (2026-11-17)

An agent's mail app ("Postbox": a sidebar, a message list 290 wide, a `Splitter`, the open message) showed at
390 wide the list at the top, still 290 wide with the splitter's grip beside it, and the message under it on the
same scrolling screen; a notes app with `Sidebar`, two `Pane`s and `Main` showed only `Main`, with no way to
either pane. Written as the page words have it, the three shapes did worse: `App` > `Sidebar`, `Pane` (the list),
`Main` (the message) showed `Main` alone at 390; a `Row` in `Main` of a list column (`w={listW}` with a
`Splitter`, or `w=300`) beside a column that grows showed nothing but the grip at 834 and 390 (the row wrapped,
and its columns are as tall as a scrolling pane). A phone shows such panes one at a time: the list, the detail a
tap on a row opens, a way back to the list where it was. The expander now writes that, as data the document has
(a variable, bindings in media rules, reactions), with no widget of its own.

**Which pane is which** (`PageReflow._findListDetail`, reflow on, 700 wide or more, the page only):

- In an `App`: the detail is `Main`; the list is the `Pane` of a fixed width just before it, when a row in it
  selects (below). Before that, another `Pane` whose rows select what the list shows is a level too (folders, a
  folder's messages, a message): a chain of every such `Pane` between the `Sidebar` and `Main`. A `Sidebar` is
  never a level: it is the drawer (14.2). Panes after `Main` are hidden on a tablet and a phone as before.
- Else, in an `App` page, a `Row` of a container of a fixed width (at least 200, or bound: `w={listW}`, read at the
  variable's start) and one that grows, with only a `Splitter` or a `Divider` between, when a row of the first
  selects what the second shows.
- One chain a page: the app's panes first, else the first such row. A level that says itself where it shows
  (`show=phone`, `hide=phone`, a bound `visible`) leaves the panes as written: that is how a writer refuses it.
  No new word: the rule below was reliable on every shape tried, and `hide=phone` already says "not this".

**A row that selects** (`_selects`): a tap reaction (`click`, or a component's `onTap`, `onPressed`, `onSelect`…)
on a node in the pane that is not a button nor a control of its own (a checkbox, a switch, a field, a chip),
which opens nothing over the page and goes to no other (`open`, `go`, a link), and sets a page value that is not
one the pane's lists are drawn from (a star a tap toggles in `msgs`) and does not read itself (a toggle, a
selection a tap adds to). Under an `each`, the value is read from the row's item or index (`sel=m.id`), and the
next pane or the list itself reads it (the open row marked: the showcase inbox's detail is written out and reads
nothing, but its rows are marked `selected={open==c.id}`). A line not under an `each` (a `NavItem` written line
by line) selects with a text or a number the next pane reads (`folder="inbox"`, not `editing=true`).

**What is written**:

- The state `<screen>_pane` (an integer, not saved; named after the screen as its drawer is; `_` added until no
  page or project variable has the name), starting at the list: the last level before the detail.
- Each level, up to a width (`below`): `bind.visible` `${= <screen>_pane==i}`; a pane before the detail fills
  its place (`width: {fill: 0}, flex: 1`, a bound width dropped, its rule at the side dropped). A `Splitter` or
  `Divider` between them is hidden; the row does not wrap. `below` is 699, or, when a tablet keeps the two side
  by side only from a wider screen, that width less one (at most 1023): the fixed panes a tablet keeps beside
  them (a sidebar where there is room for it), the list's width, what stands between, the padding around and
  360 for the detail. The row shapes in an app with a 248 sidebar: 907; the `Pane` shape and the showcase inbox:
  699 and 719, so a tablet keeps both side by side.
- Each selecting reaction ends with `setVariable <screen>_pane = <next level>`, after the row's own actions; Enter
  and Space on the focused row run the same reaction.
- A back button (`IconButton "arrow_back"`, `tooltip: Back`, which names it, shown up to `below`) first in each
  later level's top bar: `Main`'s `Nav` (the sidebar's menu button there is hidden up to `below`, and the
  title takes the room beside it), else a row of its own first in the level. It sets the state to the level
  before.
- Each `Pane` level of an app gets, in that row, the button that opens the sidebar's drawer (`tooltip: Menu`,
  the same action as `Main`'s), shown where the sidebar is hidden and one pane shows at a time: the list is
  the whole screen, so `Main`'s bar is not there to hold it.
- On the canvas: `keyDown` `Escape` and `backPressed`, each `<screen>_pane = <screen>_pane - 1`, the first
  `when`, and the canvas's `blockBack` bound, to `${= <screen>_pane>0 && screen.width<=below}`: the system back
  of a published app shows the level before while there is one, and leaves the screen from the first. (A
  `UiSession` has no system back; Escape works there.)
- A motion: each level with no animation of its own gets an `enter` animation (a fade; the detail also from 32
  to the right), `enabled: false`, bound on (`animations[0].enabled`) and replayed (`animations[0].playKey`
  `${= <screen>_pane==i ? "shown" : ""}`) up to `below` only. Off at the width it was written for, so that page
  draws as before. (`autoplay: false` would have held the pane at its first pose, invisible, on a desktop.)

Desktop is unchanged: the rules hold up to `below`, the new nodes are hidden there, and the ten showcase pages
draw the same to the byte at 1440x900 (their documents are the same too, but the inbox's). The streamed
operations write the same document (the variable, nodes inserted with `set`, the reactions and the canvas
patched). The hidden list keeps its box (a media rule collapses it), so it is where it was left on the way back.

Not done, and wrong: a list whose rows select with a button (`Button "Open" onTap={sel=m.id}`) is not found, nor
a detail written before its list, nor two chains on one page (a folder `Pane` and a message list in a row in
`Main`: the app's panes win). A detail with nothing selected opens anyway (no empty state is written). A row
whose tap both selects and opens a dialog is refused whole. A tablet between 700 and `below` shows one pane at a
time with the sidebar beside it, rather than giving the sidebar up for the two panes. The two corpus apps of
this shape (`mail-client`, `notes-app`, 2026-11-16) wrote their own phone logic (a `pane` variable, `show=` on
each pane, a `phone` name the notation does not have) and are left as written.

### 14.5 The words' next parameters (2026-11-17)

Nineteen apps written with the words of 33.1.0 each reached for a parameter the word did not have. Each is a
parameter of the word as it is already written, read where the word is read.

**`confirm`** (16 apps). Between the question and `then`: a second quoted text, the detail under the question;
`ok="Delete"` and `cancel="Keep"`, the buttons' words (a word worked out in braces: `ok={n > 1 ? "Delete all" :
"Delete"}`); `danger` (or `destructive`), the yes button in the error color. After `then {…}`, `else {…}` is
what a no does (Cancel, Escape, a tap outside). They are the confirm action's `message`, `confirmLabel`,
`cancelLabel`, `destructive` and `cancelActions`, which the document already had.

```
Button "Delete" onTap={confirm "Delete 2 clips?" "They cannot be restored." ok="Delete" danger then {clips=[]} else {toast "Kept"}}
```

A word between the question and `then` that is none of these, a third quoted text, or anything after `then {…}`
but `else {…}` is an issue that shows the whole form. The built-in dialog the action shows:

- **The keyboard, one rule.** The focus starts on the yes, so Enter answers what was asked; when it is `danger`
  it starts on Cancel, so Enter does no harm. Enter and Space press the focused button, Tab moves between the
  two, Escape cancels. (It started on Cancel always; four apps read Enter as "did nothing" or "cancelled".)
- **Its buttons** are as a `Dialog`'s end buttons in the notation (`_endButtons`): on a phone (below the
  breakpoint an adaptive modal turns into a sheet at) they share the dialog's width equally; with room they sit
  at its end, each no wider than 240 (a long word wraps). A look that places them (`expandButtons`,
  `stackButtons`, `buttonsAlignment`) is kept.
- **Asked from a menu's line** (a `Menu`, or a menu opened by `menu=`), the menu is out of sight while the
  question is (its route offstage, not closed: the line's chain, the actions after `then` and the `close` the
  menu adds run in it), then closes as the line says. It stayed painted behind the dialog in four apps.
- **For the render command** the two buttons are `confirmOk` and `confirmCancel`: `--tap confirmOk`, in
  `--dump-layout` with their text, and named in "Where the focus is".

**`key … when={…}`** (9 apps). `key j when={!editing} onPress={…}`: the shortcut acts only while the expression
holds (the keyDown reaction's `when`). `when={…}` stands before or after `onPress`; `when expression` before it
reads as before. A plain key (no `mod`, no `alt`) never acts while a text field has the focus: checked with the
render command, `--focus field --key j` leaves the page's `j` alone. A `key` line under a `Dialog#id` (or any
overlay) is that overlay's canvas's reaction: it acts only while the overlay is open. A page's own shortcut
still acts while a dialog is open over it (left as it is).

**A row's menu reads the row** (4 apps). Under `each c in clips`, `menu=rowMenu` on a line sets a page value of
the loop's name to the row's item before the menu opens (`c = item`, and the outer loops' names to theirs), so
the menu's lines read the row that was pressed as they would in the row: `MenuItem "Copy" onTap={copy
"{c.name}"}`. In the row `c` is still its item; the page value is declared from the list's first element.
`onRightClick` and `onLongPress` on the same line run in the same reaction before the menu opens, whichever is
written first (`menu=headerMenu onLongPress={header=c}` left `header` empty: the reaction that opened the menu
ran first and waited for it). An `IconButton … onTap={open rowMenu}` is unchanged (`sel=row.id` before it).

**`fuzzy(list, query, item => text, tolerance, "keep")`** (6 apps). A number after the text is how many letters a
word of the query may be off by (by default 1 for a word of 3 or 4 letters, 2 for a longer one; 0 none); `"keep"`
keeps the list's own order instead of the best first; either or both, in either order. A word of the query also
matches across the text's words written together (`adamens` in "Ada Mensah", each word's part marked).
`fuzzyScore`, `matchRanges`, `matchRuns` and `matchReason` take the tolerance as a third argument. `mark={q}`
marks what `fuzzy` matched: both read the same matcher (`matchRuns` is `FuzzyMatch.find`, as `fuzzy` is), so a
close spelling is marked whole and a phrase found as written is marked alone; under an `each` over
`fuzzy(list, q, …, 3)` a `mark={q}` takes the 3 as well. Cards' `ListRow` (title, subtitle), `ConversationRow`
(name, subject, preview), `PostCard` (title, excerpt) and `CommandPalette` (each command) take `mark=` and draw
their texts' runs with it.

**`Calendar`** (2 apps). With `bind` alone it picks one day: each pick replaces the last, its change gives the
day (`result`, yyyy-MM-dd) and the variable holds it; the calendar's `range` prop is false. With `bind` and
`bindEnd` it is a range as before. Its words for a screen reader are neutral: "start", "end", "choose the
start" (they said check-in and check-out). `marks` takes a list worked out (`marks={events}`): a day (a dot
under it), or a record with `date` (`day`) and `label` (`title`, `text`); a map as before. A list was refused
as the wrong type.

**`guardText`** (4 apps). `Dialog#edit "Edit" guard={dirty} guardText="Discard changes?" onDiscard={draft=""}`:
while the guard holds, what would close the overlay (Escape, a tap outside, back), which the guard blocks and
which then runs the canvas's `backPressed` reactions, asks that question (`ok="Discard"`, `cancel="Keep
editing"`, `danger`), and a yes runs `onDiscard` and closes. On a `Sheet` too. Without `guardText` a guard is
as before. Four apps had written a Discard button and its reset by hand.

**`follow grow`** (2 apps). `each m in msgs follow grow`: the list takes the room its column leaves (a chat over
its composer) instead of a fixed `h=`. Each column it is in takes the height left to it, up to the first that
scrolls (an `App`'s `Main`), which then no longer scrolls: one scroll, the list's, and the composer beside the
list stays in view. `follow h=180 grow`, or `grow` without `follow`, is an issue.

Not done: `mark=` on a block does not take a `fuzzy`'s tolerance; a menu opened by `onTap={open rowMenu}` from a
row's button does not set the loop's name (it goes through `sel=row.id` as before).

## 15. Open points

- Whether `Card` and the text variants are fixed words or come only from the design system (a design system
  without a card would then have no `Card`). Proposed: from the design system, with SSUI's as the built-in.
- Positional alignment words against `align=end`. Proposed: both parse, the printer writes the words.
- Whether the root is always a column. Proposed: the first line is the root, whatever it is; the canvas around it
  is implied.
