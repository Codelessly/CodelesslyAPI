# 19. An open vocabulary: grammar and core taught, words not

2026-11-16. Built in `lib/src/core/notation/{notation,vocabulary,prompt}.dart`; tests in `test/notation_vocabulary_test.dart`; the tools and the first corpus are in the SDK (`tool/notation/vocabulary.dart`, `tool/vocabulary/corpus/2026-11-16-sonnet/`).

Extended 2026-11-17 after the loop's first review (SDK `tool/vocabulary/JOURNAL.md`, Review 1): the tool records
every word used, known or not (section 6.1, D1); a word can be defined in the notation itself, as data
([20-defined-words.md](20-defined-words.md), D2); a stand-in with nothing to draw shows what is missing (section 9,
D3). The numbers are in section 11.

## 1. Why

The prompt has been teaching every word: each component, each behaviour. That does not scale. The card prompt is at its 9,000-character budget, the page prompt is 20,650 characters, and with the Cards components listed it is 73,270.

The notation has two parts that age differently. The **grammar** (a line is `Type[.variant][#id] ["text"] [key=value ...]`, `{…}` is an expression or actions, indentation nests, `state`, `if`, `each`) is small and settled (note 13 section 3, notes 17 and 18). The **vocabulary** (which types, which parameters, which verbs) grows with every design system and every behaviour.

So the prompt teaches the grammar and a small **core**, and the model writes any word it expects to exist. We then look at which words models reach for:

- a word we already have under another name is **mapped** (an alias);
- a word we lack is **built** later, by an agent, from the record of how it was written.

For that to work an unknown word must never break a page and must never be lost.

## 2. Core and vocabulary

**Core** is what the open prompt (`notationPrompt(open: true)`) teaches: the line grammar; layout (Row, Column, Stack, Grid, Box, Card, Spacer, Divider); text, icon, image; the basic controls (Button, Input, Toggle, Checkbox, Radio, Slider, Select, SegmentedButton, the chips, Progress, the charts as the taught prompt has them); `bind`; events and the actions `name=value`, `emit`, `toast`, `link`, `open`, `close`, `go`, `scroll`; `state`, `every`, `if`, `each`; formulas; and, on a page, the frames (Page, Nav, Section, Footer, App, Sidebar, Main, Pane), their lines (NavItem, Link, Brand, Heading, IconTile), how a page lays itself out narrower, and what is shown over it (Dialog, Sheet, Drawer, Menu, Popover, Lightbox).

**Vocabulary** is everything else, in six kinds:

| kind | example | where it is written |
|---|---|---|
| type | `SeatMap`, `Waveform`, `Table` | a line's first word |
| parameter | `IconButton … selected={on}` | a key=value on a word we have |
| flag | `Input … clearable` | a bare word on a word we have |
| event | `Chip … onDelete={…}` | an on… key on a word we have |
| verb | `focus search`, `copy code` | an action's first word |
| variant | `Button.danger` | the word after a type's dot |

A design system's components and the behaviour words the taught prompt lists (`key`, `Calendar`, `DataTable`, `CodeInput`, `SwipeAction`, `reorder`, `follow`, `confirm`, `announce`) are vocabulary we have: the parser reads them, the open prompt does not teach them.

The grammar is not open. A colon for an equals sign, an arrow, an event without braces, a value shown without a string, a lower-case type: each is still an issue, with the open vocabulary as without it.

## 3. How a word resolves

For each line, in this order:

1. **A word we have** (a core type, a short name of `notationTypes`, a catalog type, a design system's component, a page word) is read as it always was. Nothing below can change what such a word means.
2. **An alias** (section 5): a name in the alias table for a word we have is rewritten to that word, in the text, before the line is read. This holds with the vocabulary open or closed, and is never an issue.
3. **A defined word** ([note 20](20-defined-words.md)): a word a definition gives (a design system's
   `vocabulary/*.txt`, `NotationOptions.define`, or `define` in the text) is written out as the lines it stands for,
   open or closed. An alias whose `requires` the line meets is read before it.
4. **Unknown**, with `NotationOptions.openVocabulary`: the word stands in or is left out (section 4), and is recorded (section 6). Without `openVocabulary` (the default) it is the issue it always was, and nothing about a document changes.

## 4. The stand-in

With `openVocabulary`:

- **An unknown type** becomes a plain `column` node holding its strings as Text nodes and the lines under it as its children. Its id is kept (`SeatMap#plan` is node `plan`). A height it is given (`h=360`) is the least it is (`constraints.minHeight`), so the room its word asked for is kept and it still grows with what is written in it. The layout and look words the grammar gives every line still work on it (`w`, `h`, `grow`, `pad`, `gap`, `fill`, `radius`, `center`, `scroll`, `sticky`, `animate`, `border`, `drag`, `drop`, `menu`, `id`), as do `visible`, `hide`, `show`, `hidden`, and the events of a pointer (`onTap`, `onLongPress`, `onDoubleTap`, `onRightClick`, the swipes, `onHover`, `onDrop`). What only its own meaning could give is left out: its other parameters, its flags, its other events (`onChange`, `onSeek`).
  - `bind=name` (and any `bind…=name`) declares the variable, as text starting empty, so that what reads it elsewhere on the page still validates.
  - A `{expression}` written where a value goes (`CountUp {n}`) is skipped.
  - At the margin, after the page, with an id (`CommandPalette#palette "Commands"`), it stands in as a **Dialog** with that id: what is written there is over the page, and `open palette` must have something to show.
  - A sentence around the UI (`Here is the card:`) is still not a word: at the margin an unknown word stands in only when its line has an id, a string or a key=value, at most two bare words, and does not end in punctuation.
- **An unknown parameter, flag or event on a word we have** is left out of the node. An unknown event's actions are still read, so the variables they set are declared and their verbs recorded.
- **A value of another kind than the parameter takes** (`Text … live=polite` where `live` is true or false; `IconButton size=large`) is left out and recorded as a parameter.
- **An unknown action verb** is left out of its event; the other actions of the event are kept. A call on a name counts (`grid.insertRow(2)` is the verb `grid.insertRow`).
- **An unknown variant** draws the plain type.
- **A component called without something it needs** (`Rating value=4.6` where Cards' Rating needs a label) is given an empty value of the right kind, so the page validates, and the gap is recorded (kind `missing`): the answer's idea of the word is not the component's.
- **Lines under a word we have that takes none** (`Stepper` with `Step` lines under it) are drawn after it, under the node around it (kind `children`).
- **`open <id>` of nothing over the page, and `scroll <id>` to no line of it** are left out, with an issue on the line that wrote them. These are not vocabulary; they are left out so that the page validates.

The document carries nothing private to this feature. The stand-in is an ordinary column; which node it is is said in the record (`node`), outside the document, exactly as a `Wanted` block is marked today (`WantedBlock.node`).

`Wanted` and `notationPrompt(wanted: true)` are left as they are. They are the opposite contract: the model is told the component list, and asks, in one fixed word, for the one that is missing, building its look from plain parts. An unknown type with an open vocabulary gives the same information without the model being asked for it (its name, what it was given, what was written under it), so `Wanted` can be folded into this once the open prompt is the one in use; until then both exist and neither changes the other.

How usable a page of stand-ins is, is in section 9.

## 5. Aliases

Many names, one meaning. The table is `NotationOptions.vocabulary` (a `NotationVocabulary`), `NotationVocabulary.core` by default; a design system adds its own in `vocabulary.json` beside its `design_system.json`, which the SDK tools merge over the built-in one (`merge`: the later table wins a name both have).

```json
{
  "types": {
    "RangeSlider": {"to": "Slider", "requires": ["bind", "bindEnd"], "parameters": {"low": "bind", "high": "bindEnd"}},
    "HighlightText": {"to": "Text", "parameters": {"query": "mark"}},
    "TextArea": {"to": "Input", "add": "multiline"},
    "Shortcut": {"line": "shortcut"}
  },
  "parameters": {"*": {"disabled": "!enabled"}, "ListTile": {"subtitle": "$text"}, "Tabs": {"items": "tabs"}},
  "flags": {"*": {"disabled": "enabled=false"}, "state": {"persist": "saved"}},
  "events": {"*": {"onActivate": "onTap"}},
  "verbs": {"navigate": "go"}
}
```

- **A type** is read as another (`to`), with its own names for that type's parameters, flags and events (`parameters`), words added to the line (`add`), and the keys the line must have for the alias to hold (`requires`).
- **A parameter**, for one type or for all (`*`), is read as another key (`enabled`), as that key with its value negated (`!enabled`: `disabled={x}` is `enabled={!(x)}`, `disabled=true` is `enabled=false`), or as a further string of the line (`$text`: `ListTile "Ada" subtitle="Engineer"` is `ListTile "Ada" "Engineer"`).
- **A flag** is read as the words given (`disabled` is `enabled=false`). The entries under `state` and `project` are the word after a state's value.
- **An event** is read as another event; **a verb** as another verb.
- **A line of another shape** names a rewrite in code (`lineRewrites` in `vocabulary.dart`). There are three: `shortcut` (`Shortcut "ctrl+k" onPress={…}`, `Shortcut key="?" …`, `shortcut key=t …`, with `when cond` or `when={cond}`, is the line `key ctrl+k onPress={…}`; `ctrl` is not rewritten to `mod` because `KeyCombo` already reads `ctrl`, `cmd`, `meta` and `mod` as the same modifier), `computed` (`computed total={a+b}` is `state total=a+b`), and `confirmDialog` (`ConfirmDialog#ask "Title" "Message" onConfirm={…}` is a `Dialog#ask` with a Cancel and a Confirm button after whatever is written under it).

A name is never an alias of a word we have: a table that names `Slider` or `Card` changes nothing, and a parameter alias is not applied where the type has a parameter or an event of that name. The exception is a type alias's own `parameters`, which hold whatever the target calls its own (that is what they are for).

Every alias used is recorded (kind `alias`, with `of` the kind of word and `to` what it was read as), so we see which names models prefer.

### The table seeded from the first corpus

Each line was checked against what the parser accepts, and `test/notation_vocabulary_test.dart` expands every one beside our own spelling to the same document.

| written | read as | apps (of 20), uses |
|---|---|---|
| `Shortcut "ctrl+k" onPress={…}`, `shortcut key=t onPress={…}` | `key ctrl+k onPress={…}` | 13, 124 |
| `state x=1 persist` (also `persisted`, `persistent`; on `project` too) | `state x=1 saved` | 12, 103 |
| `disabled={x}`, `disabled`, on any type | `enabled={!(x)}`, `enabled=false` | 13, 45 |
| `ListTile … subtitle="…"` (and `title="…"`) | its second (first) string | 10, 19 |
| `computed total={…}` | `state total=…` | 1, 7 |
| `ConfirmDialog#id "Title" "Message" onConfirm={…}` | `Dialog#id` with its two buttons | 1, 4 |
| `Highlight "…" match={q}`, `HighlightText "…" query={q}` | `Text "…" mark={q}` | 2, 4 |
| `MiniCalendar`, `CalendarMonth`, `MonthGrid` | `Calendar` | 2, 5 |
| `RangeSlider low=a high=b` (`lo`/`hi`, `bindLow`/`bindHigh`, `bindStart`, `start`/`end`) | `Slider bind=a bindEnd=b` | 1, 1 |

In Cards' `vocabulary.json`: `Tabs items=[…]` is `tabs=[…]` (2 apps, 5 uses) and `Rating … readonly` is `readOnly` (2, 3).

`persist` was the largest silent loss: `state perDay=20 persist` read `20 persist` as a text value.

What was looked at and not made an alias, because the shapes do not match:

- `RangeSlider bind=range` (3 of 4 apps): one variable holding a list. Ours takes a variable for each end. It stays unknown until `Slider` takes a list.
- `Table` (6 apps): written four ways (rows of lists with `columns=["Year",…]`; rows of records with `Column "Name" key=name` lines under it; rows written under it; `items=`). None is `DataTable`'s `columns=[{"key":…,"label":…}]`.
- `ReorderList`, `SortableList`, `ReorderableGrid` (ours is `each x in list reorder`), `SwipeRow` (ours is `SwipeAction` lines under an `each`): a different shape of line and children.
- `FilterChip`, `DatePicker`, `TimePicker`, `Calendar`, `Splitter`, `CodeInput`, `Rating`, `ListView`: already words we have. The earlier static tally counted them as unknown.

## 6. The record

`NotationResult.vocabulary` (and `NotationStream.vocabulary`) is a list of `VocabularyUse`:

| field | |
|---|---|
| `kind` | `type`, `parameter`, `flag`, `event`, `verb`, `variant`, `missing`, `children`, `alias`, or `definition` (a use of a defined word: `to` the meaning read, `node` its root; recorded open or closed) |
| `word` | as written (`SeatMap`, `tooltip`, `onSeek`, `haptic`, `Button.danger`) |
| `on` | the type whose line it is on (not for a type) |
| `value` | as written (`{row.name}`, `"Archive"`); a verb's argument |
| `source` | the whole line, without its indentation |
| `line`, `column` | 1-based |
| `path` | the words of the lines it is under, outermost first; `if` and `each` are not words |
| `node` | a stand-in's node id |
| `texts`, `parameters`, `flags`, `events`, `children` | a type only: its strings, its key=value pairs as written, its bare words, its events with their actions as written, and the first words of the lines directly under it (through an `if` or an `each`) |
| `of`, `to` | an alias only: the kind of word it is, and what it was read as |

Unknown words are recorded only with `openVocabulary`; aliases always. A stand-in's own parameters, flags and events are in its record, not recorded again one by one.

Formula functions we do not have (`fuzzyMatch`, `startOfWeek`, `moveItem`) are not recorded by the parser, which does not know the engine's functions. The SDK tool counts them from the formulas that do not parse.

### 6.1 Every word, known or not (the tool)

The parser records only what it did not know, so that recording costs nothing with the vocabulary closed and a
document is the same with it open. The corpus has to hold every word an answer used, with how it resolved, or it
cannot say what share we read nor how a known word is really used. So the SDK tool
(`tool/notation/vocabulary_words.dart`) reads each answer's own lines and resolves every word on them with the
parser's record of that line (unknown, alias, definition) and what it has (Cards' components, the formula engine's
functions):

| kind | each | resolved as |
|---|---|---|
| `type` | a line's first word | core, component, alias, definition, unknown |
| `text` | a string written on a type, by position (`Button.text1`) | as its type (unknown on an unknown type) |
| `parameter`, `flag`, `event` | a key=value, a bare word (layout words too), an `on…` key, per type | unknown when the parser recorded it, alias when it read it as another, else as its type |
| `variant` | the word after a type's dot, per type | unknown when recorded, else as its type |
| `verb` | an action's first word (`name=value` is `set`) | unknown when recorded, alias, else core |
| `function` | a name a formula calls | core when the engine has it, else unknown |
| `statement` | `state`, `if`, `each`, `key`, `every`, `project`… | core, or alias (`computed`, `shortcut`) |

`vocabulary.json` holds them as `words` (each with `files`, `uses`, and `how` when its uses resolved differently)
and `summary`; `VOCABULARY.md` opens with the table of kinds by resolution and lists, for each word we have, what
the answers gave it, with what it does not take marked and what a component or a defined word takes that no answer
wrote. Its other sections (the unknown types, parameters, flags, events, verbs, functions, variants, the grammar
issues, what does not validate) are as they were. `tool/vocabulary/count.py` counts `words`.

## 7. The loop

1. `notation.sh prompt --open` is the prompt: the open preface, the grammar, the core.
2. Briefs are run against it; the answers are a corpus (`tool/vocabulary/corpus/<date>-<model>/`).
3. `notation.sh vocabulary <corpus>` expands every screen with the vocabulary open and writes `vocabulary.json` and `VOCABULARY.md`: every word with how many files reached for it and how it resolved (core, component, alias, unknown), its parameters, events and example lines, names that share a part side by side, the parameters, flags, events, verbs and functions we do not have, the grammar issues by message, and what does not validate.
4. For each word many files reached for: if we have it under another name and the shapes match, a line in the alias table and a test; if we do not, it is built (its record says what to take and what goes under it); if models agree on a shape ours does not have, ours changes.
5. Run again. The unknown share should fall; the grammar issues say what the grammar or the core should accept or explain better.

## 8. The first corpus (2026-11-16, Sonnet, 20 app briefs)

105 screens, 4,657 lines that start with a word, expanded 1,280 wide with Cards.

| | core | component | alias | unknown (stand-in) | distinct unknown words |
|---|---|---|---|---|---|
| before any alias | 3,814 (81.9%) | 541 (11.6%) | 0 | 302 (6.5%) | 86 |
| with the seeded table | 3,784 (81.3%) | 541 (11.6%) | 145 (3.1%) | 187 (4.0%) | 80 |

326 alias uses in all (the lines above count only a line whose first word is an alias; `disabled`, `subtitle` and `persist` are on lines whose first word we have).

Left unknown: 80 types (191 uses; a few are words an alias reads in one shape and not in another, `RangeSlider`, `Shortcut` with several keys in one string), 158 parameters on words we have (306 uses), 50 flags (96), 28 events (40), 28 verbs (65), 8 variants (21), 15 formula functions (33).

What the corpus showed the grammar should read, fixed in the parser with tests (each holds with the vocabulary closed too; none changes a document that was valid):

- `Progress {done/total}`, `Ring {x}`: an expression where the bare number goes (about 40 lines, 8 apps) was a "not valid JSON" error. It is `bind={…}`.
- `Input "Email" type=email`, which the prompt teaches, wrote `keyboardType: "email"`, which does not validate. The names models write (`email`, `tel`, `numeric`, `search`…) are the document's.
- `state shown={filter(…)}`: a formula in braces kept its braces and broke every formula that read it.
- `fill={late ? #FFFECACA : #FFFFFFFF}`: a color in a formula, written as after a key, did not parse.
- `key escape when editing onPress={…}`: a shortcut that holds only while a condition does (as `every … when …`).
- A `Dialog#id` (Sheet, Drawer, Menu, Popover, Lightbox) written indented inside the page was an unknown type (or, with a design system that has a Dialog, drawn in the page with nothing to open it). It is over the page, its lines the ones under it, and the page goes on after it.
- `grow=true` wrote a boolean where a number goes.

Left as they are, for a decision (count of lines, apps):

- **An action chosen by a condition** (22, 5): `onTap={dirty ? open leave : go members}`. The grammar says an action is never a condition; models write it anyway, for `open` and `go`, which a formula cannot stand in for.
- **`bind=draft.title`** (26, 4): a control bound to a field of a record variable. Only a field of an `each`'s element is read today.
- **`bind=d.on` under an `each` over a formula** (12, 3).
- **A value shown without a string** (12, 2): `Text.body c.name`. The message says what to write.
- **`show={condition}`** (6, 3): refused on purpose (`show=` takes a size; note 18). Models still write it.
- **`open <id>` of an overlay written on another screen** (19, 12): models write an app's dialog once and open it from several screens. An overlay belongs to one page.
- **An id written from data** (`Row#row-{row.id}`), **`SegmentedButton "Label"`** (a string on a control that has none), **`drag=meal({…})`**, **`SwipeAction`** written with other parameters, and a handful of lines that are simply malformed.

Decided and built since (codelessly_api CHANGELOG, Unreleased; design 13 §3): an action chosen by a condition is
an `if` action (`cond ? action(s) : action(s)`, a branch braced, in parentheses or empty); `bind=draft.title`, a
field of an element of a nested list, and of a list worked out whose records have an `id`, are written back, as
are `bind=colAll[r]` and `bind=find(clips,…).name`, and an action that sets a field where it stands (`d.pos=0`);
what cannot be written says the line to write; an `open` of no overlay of the page names the ones it has; an id
from data is its fixed part; an overlay with the page's own id, or an id used twice, says what to write; the
foot of an app window is `Footer` in `Main` (aliases `StickyBar`, `StickyFooter`, `BottomBar`, `FooterBar`,
`BottomDock`); `focus id`, `blur` and `copy text` are verbs; `selected={…}` on any line is the node's selected
state; `size=small|large` on an IconButton; `state … saved=true` is the saved flag.

The corpus counted again with them (`notation.sh vocabulary …/answers --design-system design_systems/cards`):

| | grammar issues | unknown lines | distinct unknown words | alias lines | does not validate |
|---|---|---|---|---|---|
| with the seeded table, before | 184 | 187 | 80 | 145 | 70 |
| after | 117 | 185 | 79 | 147 | 76 |
| before any alias, before → after | 162 → 108 | 302 → 302 | 86 → 86 | 0 | 90 → 96 |

The six more that do not validate are lines that were dropped before and are read now: four actions whose
formulas call functions the engine does not have (`grid.copy(range)`, in branches of a choice that was an
unknown action), and a `focus quick-backlog` to an id the answer wrote from data (`Input#quick-{col.id}`).

## 9. How usable a page of stand-ins is

Rendered: all 105 screens at 1440x900 and 390x844 (242 pictures with their overlays). No screen failed to render. 4 of 20 apps have no error from the renderer; the others have 79 between them: 42 formulas that do not parse (33 of them an unknown function), 24 names a formula reads that nothing declares (most are the item a stand-in would have given its children: `day` under a `MonthGrid`), 11 layout overflows, 1 link to a screen the answer never wrote, 1 variable declared twice.

Looked at: a stand-in that carries text or wraps lines we have reads well. A food menu whose `Dish` art is a tinted box is a good page; a chat whose `ChatBubble`, `DateDivider` and `TypingIndicator` are plain lines of text is readable and looks like nothing. A stand-in that *is* the screen leaves a hole: the seat map of a booking page is an empty bar, a clip editor's timeline is a blank panel, a chat's `Composer` is not there at all. Nothing on the page says a part is missing.

So the stand-in keeps the loop running (every page expands, validates as a document, renders, and every word is counted), and it is not something to show a user.

**A stand-in with nothing to draw shows what is missing** (built 2026-11-17): an unknown word that ends with no text,
no lines under it and no fill or border of its own is drawn as a quiet dashed box (the theme's `line`, a radius of
6, a padding of 8) with its word in the caption style, centred, and its first string value after it when it has one
(`Map · Saffron & Salt`); at least 40 high, or as big as its `w` and `h` say. Its label is the node `<id>Label`. The
look uses only what the document has (a stroke with a `dashPattern`, a text), so it follows the theme as the rest of
the page does (named, in light and dark). One with a text, lines under it, or a fill of its own (`ScrollProgress h=3
fill=…`) is as it was. With the vocabulary closed nothing stands in.

## 10. Not done

- The parser does not record unknown formula functions (section 6).
- The stand-in is always a column, also where the word is clearly a row.
- A word several answers wrote as a composition of what we have is better defined than built: [note 20](20-defined-words.md).
- The lines under a stand-in cannot read what it would have given them (`item`, `day`): those formulas fail at render.
- The open prompt is the taught prompt with the behaviour words, the JSON escape and the component list taken out, 18,151 characters for a page against 20,651 (and against 73,270 with Cards' components listed). Its core is still wide (charts, gauges, motion, the lightbox); how small the core should be is the next thing to measure.
- One model, one run. The alias table should be read against a second model before it grows.

## 11. The second count (2026-11-17: every word, and the first definitions)

The first two batches (`corpus/2026-11-16-sonnet`, `corpus/b01`: 30 answers, 136 screens, 5,943 lines that start
with a word), expanded 1,280 wide with Cards and its aliases.

| | words | resolved | unknown types | lines that stand in | grammar issues | does not validate |
|---|---|---|---|---|---|---|
| the old count (unknown words only) | 517 | 117 (22.6%) | 99 | 222 (3.7%) | 199 | 76 |
| every word, no definitions | 1,580 | 723 (45.8%) | 96 | 222 (3.7%) | 199 | 76 |
| every word, with Cards' definitions | 1,580 | 900 (57.0%) | 54 | 99 (1.7%) | 199 | 77 |

Every word, with the definitions, by kind (core, component, alias, definition, unknown): types 187 (69, 16, 6, 42,
54), texts 88 (40, 12, 0, 22, 14), parameters 784 (254, 50, 11, 83, 386), flags 193 (83, 7, 3, 5, 95), events 173
(52, 15, 0, 24, 82), variants 36 (27, 0, 0, 1, 8), verbs 52 (24, 0, 0, 0, 28), functions 59 (46, 0, 0, 0, 13),
statements 8 (6, 0, 2, 0, 0).

What it says:

- *The corpus is three times the size the old count said*, and most of the growth is known words: 601 core and 100
  component words were used and never counted. The resolved share is 45.8% before any definition, not 22.6%.
- *Parameters are the unknown mass*: 386 of the 680 unknown words are a parameter, most on a word we have (`size=`,
  `selected=`, `leading=`) or on a stand-in. That is D4's order (parameters by reach first).
- *Definitions moved types and lines*: 45 of the 99 unknown types are now definitions; the lines that stand in fell
  from 222 to 99. The grammar issues are unchanged; one answer now fails to validate once more, because Cards'
  `WordCloud` reads the `words` variable the answer never declared (the stand-in read nothing).
- The 54 types left are listed by side in [note 20](20-defined-words.md) section 9: about 20 could be definitions,
  the rest need a gesture, a drawing primitive, a position or a scroll position.

