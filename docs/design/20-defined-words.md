# 20. Words defined in the notation

2026-11-16. Decided in the vocabulary loop's first review (SDK `tool/vocabulary/JOURNAL.md`, Review 1, D2). Built
in `lib/src/core/notation/define.dart` (read, check, expand) with a few hooks in `notation.dart`, and
`define_reads.dart` (what a definition leaves unused, section 12); tests in
`test/notation_define_test.dart`; the first definitions are Cards' `design_systems/cards/vocabulary/*.txt` in the
SDK. Note 19 is the open vocabulary this extends.

## 1. Why

The corpus (note 19 section 8, the journal) showed that the words models reach for and we lack are a long tail:
of the 22 types the second batch added, 20 were written by one answer (`StickyNote "text" color=…`, `WaterDrop
level=0.6`, `WordCloud words={…}`, `Heatmap days={…}`). Nearly each is a composition of core parts with a few
parameters. Building each in Dart does not scale: there will be thousands, and each needs a reviewer, a release
and a renderer change.

So a word can be defined as **data, in the notation itself**: its strings and parameters with their defaults, its
events, where the lines written under it go, and the core lines it stands for. A fixer adds a word by writing a few
lines; a design system ships a folder of them; a host can add one at run time for an answer that needed it.

## 2. What a definition looks like

A file `vocabulary/StickyNote.txt`:

```
// A note stuck on a board: a tinted square with its text, slightly lifted.
StickyNote "text" fill=#FFFDE68A w=180 h=140 selected=false onTap onDoubleTap
  Column w={w} h={h} pad=14 gap=6 fill={fill} radius=4 border={selected ? 2 : 0} onTap={onTap} onDoubleTap={onDoubleTap}
    Text "{text}"
```

The first line (after `//` comments, which are the word's purpose) is the **signature**: the line as a use writes
it, with each value a default. The lines indented under it are what a use stands for. It is a page's grammar and
nothing else: a model that writes a page writes a definition.

The signature reads:

| written | is |
|---|---|
| `Word` | the word (capitalised; never a core type, a short name or a page word; a component of the design system in use only as a named meaning, `Stepper#steps`: section 5) |
| `Word.a.b` | the variants a use may write (`Timeline.vertical`); the body reads the one written as `{variant}` |
| `Word#name` | the name of this meaning, when one word has several (section 5) |
| `"text"` | a string, by its name; a use fills the strings in order, or by name (`text="…"`) |
| `key=value` | a parameter with its default |
| `key` | a parameter with no default (empty when not given) |
| `key!` | a parameter a use must give |
| `key=true`, `key=false` | a flag: a bare `key` on a use is `key=true` |
| `@value`, `@value=1`, `@value="text"` | the value the word keeps, which a use's bare `@x` (or `value=@x`) binds, both ways; the default is what a use that binds none starts at (it then keeps its own). Any name: `@color` |
| `open=@` | a further variable the word keeps, which a use binds by name (`open=@shown`); a use that binds none keeps its own, started by the body's `state open=false` |
| `x=@0.5`, `label=@"text"`, `range=@[0, 100]` | the same, with its default after the `@`: a use that binds none keeps its own, started there; a page variable a use binds and nothing declares is said with that start (`add state cx=0.5`). What follows the `@` is a value as written (a number, `true`, `false`, `null`, a string in quotes, a list, a map), never a name: `x=@other` is an issue. 33's `bindX=0.5` is this (the migrate tool writes `x=@0.5`, and the body's `bindX` as `x`) |
| `onEvent` | an event the word gives (`onTap`, `onPick`); an event the body forwards (`onTap={onPick(c)}`) is one too when the signature leaves it out |

The body reads its parameters by name in braces, as a page reads a variable, and the use's values are put in
where they are read, as written:

- `key={p}` alone is the use's value as written (`fill=#FFFDE68A`, `fill={c.hex}`, `items=["a","b"]`); a parameter
  with no value and no default leaves the key out.
- `"… {p} …"` in a string: the use's string spliced in (`"Buy milk"`), its expression kept (`{item.name}`).
- `{… p …}` in an expression: the value as an expression (`{level*100}` is `{(p.water)*100}`, a string is
  `"…"`, a bare word is `"word"`).
- `onTap={onPick}` in an event: the use's actions; `onTap={onPick(c)}`: those actions with `result` as `c`. An
  event with nothing left is left out. `onDrop={onDrop(result.data)}` with a use's `got=result.data` is
  `got=(result.data)`: the use read the value as the body passes it, not its `.data` again. An event in a branch of
  a choice (`{on ? onA : onB}`) is that branch: braced when its actions are several, `{}` when the use gave none.
- `@value`, `open=@open`, `@row.done`: the variable the use bound (a name or a path: `email`, `s.weight`), else the
  use's own. In the body `{value}` reads it and an action writes it (`value=value+1`), as for any variable.
- A plain parameter a use binds (`value=1` in the signature, `Counter @n` or `value=@n` on the use) is that
  variable both ways: the body's `{value}` reads `n` and `value=value+1` writes it. A plain parameter the body binds
  (`Slider @level`) is the use's own variable when the use binds none, started at the value the use gave or the
  default. A bare `@x` on a use of a word that keeps no value, a `key=@x` it does not take, and a second bare mark
  are issues that say what it binds.
- `drag=group(x)` (and `drag=group({x})`): what it carries is an expression of the body, so a loop item of the body
  is the use's.
- `if p`, `each x in p`: the statement's expression, the same.
- A body written as `if visible` over its one node is that node with `visible={visible}`: models write a word that
  can be hidden that way (the journal, Review 4, D21). A body whose first line is any other `if` (with its `else`)
  or an `each`, or that is several lines side by side, is its lines written where the use is (section 4: a macro):
  in the node around the use, so that the copies an `each` makes are the cells of a `Grid` around it and take the
  gap of a `Column` around it, and a sidebar's brand and items written as a word are the sidebar's lines (round
  11: these were one cell holding every photo, lines with no gap, and a refused word drawn as a placeholder). A use
  that gives the root words of its own (`#id`, `hide=phone`, `grow`) has a `Column` holding the lines, with those
  words. `state` lines before the root are the word's own state.
- A use's `{expr}` where its first string goes (`Pill {status}`) is that string, `"{status}"`.
- A use's value that is a path (`end=draft.end`) or a variable of the page or of an `each` around it (`bpm=bpm`) is
  read as `{draft.end}`, `{bpm}`: the value, not the word. Any other bare word is the word (`tone=quiet`).
- A use's id from data (`Track#{tr.id}`, `Track#lane-{tr.id}`) is its fixed part (`lane`), or none.
- `each x in p reorder` in a body, with `p` given as a list worked out (not a variable), is shown in order: there is
  no variable to write a new order to.

What a use writes that the signature does not name: the words the grammar gives every line (`#id`, `w`, `h`,
`grow`, `pad`, `gap`, `fill`, `radius`, `border`, `center`, `scroll`, `sticky`, `animate`, `drag`, `drop`, `menu`,
`visible`, `hide`, `show`, `hidden`, `maxw`, `tooltip`, the `border-…` sides, `duration`, `delay` and `stagger`
with an `animate`, the alignment words, and the pointer events `onTap`, `onLongPress`, `onDoubleTap`,
`onRightClick`, `onHover`, `onDrop`, the swipes) go on the body's first line (the root), replacing what it writes
for that key; an event joins the root's own. Since note 21 these are the words of `notationUniversal`, and the
universal words (`color`, `size`, `icon`, `disabled`, `removable` with `onRemove`, and on a container root whose use
says `reorder` or `selectable` the list's words) go on the root too when the root is a kind of line that takes them
(recorded `universal`). Anything else is a word the definition does not have: with the open
vocabulary recorded as a parameter, flag or event of that word, left out; without it an issue that says what the
word takes (`A StickyNote has no "x". It takes: text, fill, w, h, selected, onTap, onDoubleTap.`).

## 3. Lines under a use: slots

A body line `...` is where the lines written under a use go (the default slot). `...Front` is a named slot: the
lines a use writes under a line `Front` go there, and the `Front` line itself is not drawn. A slot line may carry
the words of a column that holds its lines (`...Front w=fill h=fill pad=20 center middle`), and what a use writes on
the slot's own line joins them (`Front fill=#FF6D28D9`). `... each reorder` instead adds `reorder` to an `each` over
a variable written directly in the slot: `ReorderList` with `each row in items` under it is our `each row in items
reorder`.

```
// A card that turns over: its front, and its back when flipped.
FlipCard @flipped h=240 radius=16 onTap
  state flipped=false
  Stack w=fill h={h} onTap={flipped=!flipped; onTap}
    Column w=fill h=fill pad=20 center middle radius={radius} fill=surface border=1 visible={!flipped}
      ...Front
    Column w=fill h=fill pad=20 center middle radius={radius} fill=accentTint visible={flipped}
      ...Back
```

(Cards' own `FlipCard.txt` gives its slots their padding on the slot lines, so a use's `Front fill=…` fills the face.)

```
FlipCard @flipped onTap={toast "turned"}
  Front
    Text.title "{q.word}"
  Back
    Text "{q.meaning}"
```

The parser reads a text one line at a time (a stream). A use's expansion is written out as its lines arrive: the
body down to its first slot when the use's line is read, each slot's lines as they come, moved to the slot's place,
and the rest of the body when the use closes (the next line no further in). Named slots are therefore filled in
the order the body has them; a slot written after one that comes later in the body is put where the expansion
is, with an issue. A use with lines under it and no slot in its body has them drawn at the end of its root, and
says so (recorded as `children` with the open vocabulary, an issue without).

## 4. Expanded where it is used: a macro, not a component

Two ways were weighed.

**A component of the document.** The definition compiles once into a component (a document with `props`, events
and slots, as Cards' `components/*.json` are and as `notationComponentLine` lists them); each use is an instance.
The document stays small, and an editor shows one instance to edit. But a component is its own scope: it reads
its `props.x`, not the page's state; what it changes reaches the page only through a `variable` parameter or an
event; an `each` over a parameter needs the component's list support; the page's reflow does not reach into it;
and every value a use passes must be typed to a prop. Most of what models write under these words reads the
page's state directly (`StickyNote "{it.text}" selected={contains(selected,it.id)}`), and would have to be
rewritten into props and events. It is also a second compiler: the notation's expansion into a document already
exists, and a component compiler would duplicate it for the subset a component can hold.

**A macro (chosen).** A use is replaced by its body's lines, with the use's values put in, before the line is
read, exactly as a page word (`Section`, `Nav`) is replaced by the plain lines it stands for. Everything the
notation does then holds for it with nothing added: `each` and `if` inside it, `@name` of a page variable, a
use's expressions reading the page's state and the row of an `each` around it, reflow on a phone, validation,
rendering, the stand-in for what is unknown inside a use's lines. The document carries nothing private to it:
the record says which node a use became (`node`), as it does for a stand-in.

What it costs, and the answers:

- **The document holds the expansion.** It is the source (the notation, with its definitions) that is kept and
  edited, by a model or a person; the document is what it expands to, as for every other word. A definition is
  edited as data (its file), and every page that uses it expands anew. Compiling a definition that reads no page
  state into a component is a later optimisation, not a different design.
- **State inside a word.** `state open=false` in a body is the use's own: its name is made the use's
  (`open_stickyNote1`, from the use's `#id` or a counter), in the body's `state` lines, expressions, actions and
  marks (`@open`). Two uses do not share it. Under an `each` the use is written once, so its state is shared by the
  rows (the notation's variables are the page's; a row's own state belongs in the row's item). `@name` in the
  signature (and `key=@`) names a variable the word keeps: a use's `@x` (`key=@x`) puts the page's `x` there (the
  body's own `state name` line is dropped, and `x` is declared on the page like any variable a line binds); without
  it the word keeps its own (`@value=1` gives its start; else the body's `state` line).
- **Ids.** A use's root is the use's `#id` (`ColorPicker#tint`), else `<word><n>` (`stickyNote1`); an id written in
  a body (`Dialog#picker`, `scroll top`) is made the use's (`picker_colorPicker1`), and an action of the body that
  names it (`focus picker`, `focus #picker`, `focus "picker"`) names the use's; an action that names the root's own
  id names the use's root. The loop variables of a body's `each` are made the use's too, so a use's `{item.name}`
  reads the page's row, not the body's. A use's own actions are the page's: the ids they name are the page's.
- **Events out.** A use's event is actions; the body says when they run (`onTap={onPick}`) and what `result` is
  (`onPick(c)`). A line of a body reads the alias table as a page's line does (`Input onSubmitted=` is
  `onSubmit`); an event a line does not have is an issue that lists the events, open or not.
- **A definition using another.** Its body is expanded with the same definitions, its slots passing through the
  inner word's slot. A word that uses itself, directly or through others, is refused when the definitions are read
  (`StickyNote.txt:2: StickyNote uses itself (StickyNote > Pin > StickyNote): it is not read.`), and an expansion
  deeper than 8 stops with an issue.

## 5. One name, several meanings

`Timeline` is, in four answers, a clip editor's tracks (`Timeline zoom={zoom} playhead={playhead}`), a vertical
list of dated events (`Timeline` with `TimelineItem` lines), and a bus route's stops (`Timeline.vertical @at
position={bus}` with `TimelineStop` lines). A file may hold several definitions of its word, each a signature at the
margin, each named with `#name`:

```
Timeline#tracks zoom=1 playhead=0 heads onZoom onScrubTo
  …
Timeline.vertical#events
  …
Timeline.vertical#route @at position marker="directions_bus"
  …
```

A use is read with the definition that fits it best: one whose required parameters it gives; of those, the one
whose signature names the most of what the line gives (parameters, flags, events, the variant), less what it does
not name; then the one that names the fewest things the line does not give (the plainest); on a tie, the first. So `Timeline zoom={z}` is the tracks, `Timeline.vertical position={bus}` the route,
and a bare `Timeline` the events. Whether a use has lines under it is not used: the parser does not know it when
the use's line is read (section 3). The record says which meaning was read (`to: Timeline#route`).

An alias whose `requires` a line meets is still read before a definition of the same name: `RangeSlider @a
@b` (`low=@a high=@b`) is our `Slider @a @b` (the built-in alias), `RangeSlider @range` is Cards' definition.

**A component's word with a second meaning.** `Stepper` is, in eight self-defining answers, two things: the number
control (five answers: `@value min= max= step= onChange`), which Cards' `Stepper` component already is, and a
steps indicator (three: `steps=[] @step`, `current=`, `done=[]`, `onPick`/`onSelect`). A component cannot be
redefined (its word is the design system's, section 6), and the second meaning is not a reason to rename the first.
So a definition may give a component's word a further meaning when it names that meaning:

```
Stepper#steps steps=[] @step current done=[] orientation="horizontal" onPick
  …
```

The component is the word's first meaning, scored as a definition whose signature is the component's props and
events (with `@` when it keeps a value, and `onChange` for its `onChanged`). A use is read as the named meaning
that fits it best only when that meaning fits it better than the component; on a tie it is the component. So
`Stepper @qty min=1 max=8 onChange={…}` is the component, as it was, and `Stepper steps=["Cart","Pay"]
current={at}` is `Stepper#steps`. A design system's definition of a component's word that names no meaning is not
read: the unnamed meaning of a component's word is the component. A page's own is (section 6). The core's words and
the page words take no second meaning (a `Text#strike` would change what every page means by `Text`).

The alias table reaches a defined word too: the parameters, events and flags it lists for that word (`"parameters":
{"Timeline": {"events": "items", "steps": "items", "current": "selected"}}`) are read as the names its definitions
take, before its meaning is chosen. A name one of its meanings takes is its own (`zoom` on `Timeline#tracks` is not
aliased), and only the word's own entry is read: `*` is for the words of the notation. This is how a harvested
signature (the journal, Review 5) takes the other names writers gave the same parameter.

## 6. Resolved as a word we have

A defined word is a word we have. It resolves after the core, the catalog, the page words and the design system's
components (none of which a design system's definition can change: such a definition is not read, and said), and
before an alias.

A page's own definition (`define Word …` in the text) may replace a design system's word: a word the design system
defines, as before, and since the loop's Review 7 (D38) a component too, when the definition names no meaning of its
own (`define Counter "label" max=8`, not `define Counter#steps`). On that page the definition is the word, with every
meaning the design system gave it, and the use's record says what it replaced (`of: "page, over the Counter
component"`, or `"page, over Counter.txt"`). Ten of the twenty standalone runs renamed every line of a word they needed
in another shape (`FloorPlan`, `CanvasShell`, `Track`, `StatusBadge`, `Poster`); now they define it under its name. The
core's words, the catalog's and the page words are never replaced (a page's `define Button` is not read), and a
replacing definition cannot use the word it replaces (it would use itself).
With the vocabulary open or closed it reads the same; its use is recorded always, as an alias is (kind
`definition`, `to` the definition's name, `node` the use's root id), and the tool counts it as `resolved:
definition`. A slot's line under a use (`Front`) is recorded the same way, with `to` `FlipCard slot`: it is a word
of the definition, not a type.

A definition's own errors are said against the definition: a line of a body the notation cannot read is an issue
on the use's line whose message starts with the definition's file and line (`StickyNote.txt:3: …`), and
`checkDefinitions` expands each definition once with its defaults, so a design system's folder is checked before a
page uses it. In a body, a word the notation does not have is always an issue: a definition is not an answer and
is not open.

## 7. Loading

- `NotationOptions.define({'StickyNote.txt': text, …})` (and `NotationVocabulary.define`): definitions by file
  name, read and kept on the options' vocabulary. `readDefinitions` gives them with their problems.
- In a page: `define Word …` at the margin, with the body under it, defines the word for the whole text (the same
  form as a file's signature, with `define` before it), written before or after its uses: models asked to define
  the words they invent write the definitions after the last screen (the journal, Review 4, D20). A `//` line
  directly above it is its purpose. `parseNotation` reads every `define` of the text before its first line, so a
  definition holds from the top, in the overlays written after the page too; what is wrong in one is an issue on
  its own line, once. A word defined twice is the later definition, unless both name their meaning (`#name`). A
  page's own definition of a word the design system also defines is the one read on that page, and its use's
  record says so (`of: "page, over StickyNote.txt"`). `parseNotation(…, definitions: text)` reads the `define`
  blocks of more text as the page's own (an answer's other screens: the SDK's `notation.sh vocabulary` gives each
  screen its whole answer), their problems said where they are written. `readPageDefinitions` gives them.
- Read as it arrives (`NotationStream`), a text cannot apply a definition to a line already sent: a definition
  holds from where it is written on, a use above it was read without it (it stands in with the open vocabulary,
  is an issue without), and the definition says so (`page:40: Knob is used on line 12, before this definition.
  …`). A stream that wants its words whole writes its definitions first, or is read again whole at its end.
- A design system's folder may hold `vocabulary/*.txt`; the SDK's `notation.sh expand`, `vocabulary` and `prompt`
  load them with the design system.
- The prompt with the open vocabulary does not teach them: the model writes the word it expects, and a definition
  gives it a meaning. Since the loop's Review 6 (D29) it names them, with the design system's components, on one
  line and with no parameters (the glossary, [note 19](19-open-vocabulary.md) section 2), so a writer uses ours
  rather than defining its own; a name promises only the shape the name suggests, which is why the named words
  took the harvested shapes first (section 10). `notation.sh prompt` in the taught mode lists their signature
  lines and purposes, as it lists components.

## 8. What a definition cannot do

A definition composes what the notation has. What needs something the notation does not have stays unknown, and
is the list to build in Dart:

- **a gesture** the grammar has no event for: resizing with handles (`StickyNote resizable handles=8`), a marquee
  selection, pinch and wheel zoom, scrubbing a ruler, trimming a clip, drawing an arrow between two shapes;
- **a drawing primitive**: a waveform from samples, a QR code, a drawn map or glacier, a heatmap of a keyboard, a
  water drop's curved fill (a rounded box can stand in), a word cloud's packed layout;
- **a layout algorithm**: a time grid placing blocks by hour, a packed word cloud, positions on a canvas by `x`
  and `y` (the notation has no absolute position on a line), a minimap scaled from a board;
- **device or platform**: a camera frame, a sound, a live region announced as it changes (the notation has
  `announce` as an action, not a word that watches a value);
- **behaviour over time** the timer cannot give: an infinite list asking for more as it scrolls, a scroll spy,
  parallax by scroll position, a collapsing header.

Section 9 lists, for the corpus, which side each unknown word falls on.

## 9. The corpus's unknown words, by side

The first definitions are Cards' (`design_systems/cards/vocabulary/`, 40 files, 46 meanings), written as data
only, for the words the first two batches reached for (30 answers, 136 screens): `StickyNote`, `ColorSwatch`,
`ColorPicker` (which uses `ColorSwatch`), `AttachmentTile`, `QuoteBlock`, `Kbd`, `PullQuote`, `Pill`, `Toast`,
`Dot`, `Poster`, `AlbumCover`, `WaterDrop`, `LiveRegion`, `DateDivider`, `TypingIndicator`, `ChatBubble`,
`Composer`, `CommandItem` (which uses `Kbd`), `Group`, `SelectionBar`, `NowPlayingBar`, `Figure`,
`ChapterRail`, `ChapterRailItem`, `SwipeRow`, `FlipCard` (`Front`, `Back`), `AvatarStack`, `Legend`, `WordCloud`,
`Heatmap`, `Countdown` (`#seconds`, `#clock`), `ToggleButton`, `RangeSlider @range` (over `Slider @low @high`),
`ReorderList` (over `each … reorder`), `Table` (`#lists`, `#records`, `#rows`), `Timeline` (`#tracks`, `#events`,
`#route`), `TimelineItem`, `TimelineStop`, `Step` (`#story`, `#progress`).

Of the 98 types no word resolved before (with 33.0.0's parser and aliases; `StickyBar` is now an alias of
`Footer`, so it is not defined here), 44 are now definitions and 54 are not. Of those 54:

**Could be definitions, not written yet** (compositions of what the notation has): `PhotoGrid` (a Grid of Images;
not its drag selection), `Autocomplete`, `CommandList`, `FuzzySearch` (an Input and `fuzzy`), `DateRangePicker`
(over `Calendar @start @end`), `SortableList` (`each … reorder=group`), `SplitPane` (`Row` and `Splitter`),
`ThumbnailStrip`, `SelectionToolbar`, `ListenBar`, `Head`, `Track`, `TypedAnswer`, `Keyboard` (rows of keys),
`Lyrics` (lines marked by time; not scrolled to), `Dish`, `DishArt`, `Scene` (as a tinted tile with an icon),
`CompareSlider` (Cards has `BeforeAfter`: an alias, if the shapes match).

**Cannot be definitions** (the list to build, or to decide against):

- *A gesture*: `Selection` (a marquee), `Zoomable` (pinch, wheel), `SwipeCard` (a card that follows the finger to a
  threshold), `Playhead` and `Ruler` (dragged and scrubbed along a time axis), `Shape` and `StickyNote`'s
  `resizable handles=8` (resizing; `StickyNote` itself is defined and its resize is recorded as unknown).
- *A drawing primitive*: `QRCode`, `Waveform`, `Map`, `MapDrawing`, `GlacierDrawing`, `KeyHeatmap`, `Arrow` (a line
  between two shapes).
- *A layout algorithm or a position*: `TimeGrid` and `TimeBlock` (blocks placed by hour), `Cursor` and `Pin` (`x`/`y`,
  `lat`/`lng`: the notation has no position on a line), `Minimap` and `BoardThumbnail` (a board scaled down),
  `SeatMap` (rows on a curve; a grid of seats would be a definition), `DataGrid` (a spreadsheet),
  `ReorderableGrid` (reorder is a list's, not a grid's).
- *Scroll position*: `Scrolly`, `Sticky`, `ParallaxScene`, `ParallaxLayer`, `ScrollProgress`, `ScrollTabs` (a scroll
  spy), `CollapsingHeader`, `InfiniteList` (more on reaching the end; a "load more" button would be a definition).
- *Device or time*: `CameraFrame`, `Sound`, `Announce` (said when a value changes; ours is an action), `TypingText`
  (each character marked as it is typed).
- *The grammar*: `Footnote 1` and `CountUp 39` give a bare number where the text goes; a signature names strings
  only, so the number is an unknown flag. Closed since (note 21 section 8): a bare number fills the next string of
  the signature, else its parameter `value`, and is the number itself in the body's expressions.

## 10. Promoted from the harvest (the loop's Reviews 5 and 6, D25 and D30)

The self-defining corpora (`corpus-define/d01`, `d02`: 111 answers) defined the same words again and again, and
mostly agreed. Where three or more answers defined a word, or a word Cards or the core already had, ours took the
shape the writers agreed on, and the other names they used are aliases (`vocabulary.json`, which reaches a
defined word since this review, section 5):

| word | signature now | aliases |
|---|---|---|
| `Timeline#events` (first: a bare `Timeline` is it) | `Timeline.vertical#events items=[] @at selected onPick`: records with a date or time, a title, a note | `events`, `steps`, `entries` → `items`; `current` → `selected`; `onSelect` → `onPick` |
| `Timeline#tracks`, `#route` | as they were, with `tracks=[]` and `stops=[]` named in the signature | |
| `Stepper` | the component (the number control: `@value min max step label onChanged`, `onChange`) and `Stepper#steps steps=[] @step current done=[] orientation="horizontal" onPick` | `items` → `steps`; `onSelect` → `onPick` |
| `Countdown#timer` (new meaning) | `"label" seconds=0 warnAt=0 format="m:ss" onWarn onEnd` | `warnBelow`, `warn` → `warnAt`; `onDone`, `onFinish`, `onComplete` → `onEnd` |
| `Rating` (component, repaired) | `"label" @value score max=5 half readOnly onChanged`; the label optional | `readonly`; `StarRating` is `Rating` |
| `ChatBubble` | `"text" mine=false role sender time grouped=false` (role="user" is mine) | `from`, `author` → `sender` |
| `Barcode` (core) | `Barcode "text"`, bars by default, 80 high | `value`, `code` → `data`; `format`, `type` → `symbology`; `QRCode` |
| `Banner` (component, repaired) | `"title" "message" tone icon action dismissible onDismiss onAction`; `Banner.warning` is `tone=warning` | `actionLabel` → `action`; `text` → `message` |
| `Breadcrumb` (component) | `items! showHomeIcon onNavigate` | `crumbs`, `path` → `items`; `onPick`, `onSelect` → `onNavigate`; `Breadcrumbs` |

And where the writers' own definitions were labelled boxes because the thing needs a primitive (section 8), Cards
has a stand-in in the agreed signature: a quiet placeholder that shows its label and what it was given, with its
events declared so an answer's actions are read, and a `//` line that says what it does not do. When the primitive
is built, the word is already agreed:

| word | signature | what it shows | aliases |
|---|---|---|---|
| `MapView` | `center=[0,0] zoom=12 pins=[] @picked h=320 onSelect` | centre, zoom, the pins as chips | `markers`, `places`, `locations`, `apps` → `pins`; `onPick`, `onPin` → `onSelect`; `Map` |
| `RouteMap` | `stops=[] current progress=0 h=240 onPick` | how far along, the stops numbered | `points`, `route` → `stops`; `onPin`, `onSelect` → `onPick` |
| `FloorPlan` | `"name" rooms=[] pins=[] @picked selected placing=false h=360 onPick onPlace` | rooms as tiles, pins as chips | `items`, `markers` → `pins`; `onSelect` → `onPick` |
| `SignaturePad` | `"hint" @signature h=160 onChange` | a framed area; a tap marks it signed | `onSign` → `onChange`; `Signature` |
| `CameraView` | `"hint" source="camera" h=320 onCapture` | a dark frame, its source, a shutter | `onShutter`, `onTake` → `onCapture`; `Camera` |
| `PhotoPicker` | `"label" @photo onPick` | a framed area; "Photo attached" once bound | |
| `Waveform` | `values=[] position=0 cues=[] h=48 onSeek` | a bar per value, coloured to the position | `peaks`, `samples`, `bars` → `values`; `progress` → `position`; `marks`, `markers` → `cues` |

Review 6's glossary experiment (`corpus-define/d03`) showed the other side: a name given without a signature is
used in the shape the writer expects. Those shapes were taken too (D30): `TimelineItem date= done= current=`,
`AttachmentTile "name" "size" progress=` (and its close button with `onRemove` alone), `FlightProgress value=`, a
`FileUploader`'s `accept=` (a text or a list, said in its hint) and `multiple`, and aliases for a component's list
under the name answers gave it (`ChipTabs items=`, `ChoiceChips`, `SegmentedControl`, `Combobox`,
`StepIndicator items=`, `StatusBadge status=`, `StatCard caption=`, `ImageUpload accept=`, `CodeBlock lang= copy`).
The SDK's vocabulary tool lists what is left under "Named words used in a shape we do not take".

## 11. What is not done, and what it costs

- **Whether a use has lines under it** does not choose a meaning (section 5).
- **State under an `each`** is one variable for every row (section 4).
- **A definition's own words are not checked against its parameters' kinds**: `fill={color}` with a use's
  `color=quiet` writes `fill=quiet`, which the line then reads as it would.
- **Declared and unread**: a parameter a signature names and its body never reads is accepted and does nothing.
  The SDK's vocabulary tool says so and does not count it as resolved (section 12); the parser does not refuse it.
  Three of Cards' definitions do it (`PhotoGrid` never runs `onTapPhoto`, `Table#rows` never reads `dense`,
  `WordCloud` never reads `h`).
- **The document holds the expansion**, not the use: an editor shows the lines a word stands for (section 4).
- **Recorded words inside a use's actions** (an unknown verb in a use's `onPick={…}`) are the answer's, recorded as
  any; a word the body itself gets wrong (other than an action verb) is an issue against the definition, open or
  not.
- **An event a body line does not have** is said only when a use gives that event: a use that does not leaves the
  key out, and `checkDefinitions` gives none.
- **`each` directly under `Row between`** is one list, so `between` spaces nothing; this is the parser's for any
  row, not a definition's.
- **`checkDefinitions` leaves strings out** of the use it checks (a string may be a colour or an icon name, which no
  sample text is): a body that reads a string as an icon must give one when it is empty (`Icon "{icon == null ?
  "circle" : icon}"`).

## 12. What a definition leaves unused, and primitives (the loop's Review 7, D32)

Twenty standalone runs reached "100% resolved" with 146 definitions, and about a third of them were hollow: a
signature that names `shortcut=` or six key events its lines never use, a map that is a tinted box. A definition
resolves its word whatever its lines do, so the count could not tell. Two things say it now.

**What a definition's lines leave unused** (`definitionReads`, `define_reads.dart`). Read from the lines as the
expansion reads them: a name is read where the expansion would put the use's value in (in braces, in a string's
braces, in a list, in a statement's expression, in the `{…}` where the text goes), a variable is bound by `@` (`@value`, `open=@open`) and named by
`menu=`, an event is run where an action names it (`onTap={onPick}`, `onPick(x)`, a branch of a choice, inside
`confirm … then {…}`). `DefinitionReads` gives:

- `unread`: the strings, parameters and `@value` its lines neither read nor bind (`define GoKey "label" shortcut="" onTap` with
  `Button "{label}" onTap={onTap}` under it: `shortcut`);
- `unfired`: the events no action runs (tv-streaming-remote's `RemoteFrame … onArrowUp onArrowDown onArrowLeft
  onArrowRight onEnter onEscape` over `Column gap={gap} pad={pad}`);
- `outside`: the names its lines read, set or bind that are neither its own nor declared in it (periodic-table's
  `each e in elements`, a variable of the page; `Slider @gain` where `gain` is no parameter, which binds the page's
  `gain`; `selected={item==bind}`, which reads a variable called `bind`). A parameter a line binds (`Slider @red`) is
  read: it is the use's variable, or the one the use binds. Ids, pages and keys an action names (`open sheet`,
  `go home`) are not variables.

Each comes with its message (`page:64: PeriodicTable reads elements, which is neither its own nor declared in it: it
works only on a page that has that variable.`). The parser does not refuse any of them: a definition that does less
than it says still draws. The SDK's vocabulary tool lists them ("Definitions that do less than they say", and
`definitionWarnings` in its JSON), and a word given to a use that its definition never reads or runs resolves as
`unread`, which is not resolved.

**A primitive** is what no line can express, declared as such: `primitive Word "main" key=default onEvent`, the same
signature as `define`, with a `//` line above it that says what it would do.

```
// A plan of rooms that placed items are dragged about on: no line draws one.
primitive FloorPlan "name" rooms=[] pins=[] h=360 onPick onPlace

// A trace of samples on a grid, with a cursor.
primitive Scope trace=[] onCursor
  Box w=fill h=120 fill=#FF0B1220 radius=8
    Text.caption "Scope · {length(trace)} samples" color=#FF34D399
```

With no lines under it, a use is the standard labelled box (a quiet bordered column with the word and its first
string, `h={h}` when the signature has an `h`, the lines written under the use in it); with lines, it is those, as a
definition's are. Its use is read exactly as a definition's (its parameters and events are its own, nothing is
unknown on it) and recorded as kind `primitive` (`to` the word), never as `definition`; what it leaves unused is
expected and not warned on. A design system's file may declare one too (`primitive MapView center=[0,0] …`).

**A stand-in with nothing to draw** (round 11: fourteen of thirty briefs lost a screen to one). A writer names
behaviours with no picture as primitives, or leaves them undefined: `KeyboardShortcut keys="Ctrl+K" onPress={…}`,
`LiveStatus @notice`, `Clock onTick`, `ThemePreference mode={appearance}`, `ReviewSound`, `MenuScroll @category`.
Their labelled box spanned the window, took an App's pane, or, written before the `App`, became a second root that
pushed the app down and took its window. Now, for a use of a primitive declared with no lines and for a word that
stands in (open vocabulary):

- **beside the frame**: written at the top of a page whose top holds an `App` or a `Page`, with nothing under it,
  it draws nothing and takes no room, and the frame stays the page's root (with its window);
- **a behaviour with no picture**: when the word's parts (split where a capital starts) name one (keys, keyboard,
  shortcut, bindings, listener, announce, announcement, live, clock, timer, sound, preference, theme, motion,
  scroll, observer, monitor, watcher, spy, trigger, follow, guard, focus, clipboard, copy, transition, engine,
  runtime) and none names something seen (button, bar, field, input, picker, chip, row, card, panel, map, slider,
  dial, grid, canvas, list, tile, tab, menu, badge, label, text, icon, view, sheet, dialog, surface, lane, ruler,
  chart, scene, image, photo, line, alert, toggle, banner, toast, progress…), and the use gives no size (`w`, `h`,
  `grow`) and no text (an announcement's text is what it says, not what it shows), it draws nothing and takes no
  room wherever it is; with lines under its use, it is those lines with no labelled box round them
  (`CardKeys … / TaskCard …`);
- anything else keeps its labelled box (`SeatMap h=200`, `SectionPreference "Show weather"`, `PropertyScene`): a
  picture the notation cannot draw stays visible as missing.

Its use is recorded as before (kind `primitive` or `type`), and the render says it, as drawing nothing (no node) or
as its lines with no box. The parts are a list read from the round's words, not a rule of the grammar: a word it
misses still draws its box, which is what it did before.

The
SDK tool counts a primitive and every word its uses were given as **stand-in**, apart from resolved and unknown,
and lists the declarations ("Primitives declared"): that list is the work, written by the writers in the shape they
need. The open prompt teaches it in one sentence of the define paragraph.

Cards' own stand-ins (`MapView`, `RouteMap`, `FloorPlan`, `SignaturePad`, `CameraView`, `PhotoPicker`, `Waveform`:
section 10) are still `define`d, so their uses still count as resolved; declaring them `primitive` is a change of
its own.

The twenty standalone runs' final answers (each with all the runs' aliases), counted again:

| | words | resolved | stand-in | never read | unknown | definitions that do less than they say |
|---|---|---|---|---|---|---|
| before (resolved: all but unknown) | 1,069 | 1,069 (100%) | | | 0 | |
| after, as written | 1,069 | 914 (85.5%) | 0 | 155 | 0 | 78 of 146 |
| after, the 49 definitions whose `//` line says they stand in declared `primitive` | 1,069 | 707 (66.1%) | 309 (49 declared, 61 uses) | 53 | 0 | 38 of 97 |

So two thirds of the "100%" is words that mean what they say; a seventh were named and never read, and the rest stands
in for a primitive the writers already described.

## 13. What a body says beyond fixed lines (the dictionary's needs, note 23)

Note 23 wrote 28 words the expander writes in Dart as definitions and found ten things the code does that a
definition could not say (its section 3, G1 to G10). Five of them are said now, each in the grammar a page already
has. Nothing a body wrote before means anything else, and no picture changes: where the document changes, it is a
value written where a binding of the same value was.

### 13.1 Values worked out as the use is read (G2)

```
IconTile "name" size=40
  Box w={size} h={size} radius={round(size/4)} center middle
    Icon "{coalesce(name, "star")}" size={round(size/2)}
```

An expression of a body that, once the use's values are put in, **names nothing** (no variable of the page, no row
of an `each`, no state of the word's own, no value the use gave as `{…}`) reads nothing at run time, so it is worked
out as the use is read, as the formula engine would: `IconTile size=48` is `radius=12`, `size=24`, `Icon "star"`.
An expression that still names something is left to the engine, as before (`IconTile size={n}` is a binding of
`(n)/4`). It holds wherever a body reads its values:

| written in a body | worked out to |
|---|---|
| `key={…}` | the value (`radius=10`, `fill=#FF2563EB`, `label="Save"`); nothing leaves the key out; `visible` true is left out, false is `visible=false` |
| `"… {…} …"` | the text spliced in (`"{upper(label)}"` with `"People"` is `"PEOPLE"`) |
| `if …`, `else if …`, `else` | the branch taken is its lines, moved out to where the `if` was; the others are not written (`if badge` with no badge given writes nothing) |
| `Word.{…}` | the variant (`Text.{level == 1 ? "heading1" : "heading3"}` with `level=1` is `Text.heading1`) |
| `key {…}` (a statement, 13.4) | the chord, written bare |

What it works out: numbers, texts in quotes, `true`, `false`, `null`, a colour (`#FF2563EB`, a text); `+ - * / %`,
`== != < <= > >=`, `&& || !`, `?:` and parentheses; and `upper`, `lower`, `trim`, `replace`, `round`, `floor`,
`ceil`, `abs`, `min`, `max`, `coalesce`, `if`, with the engine's meanings (`coalesce` skips empty texts; truth is the
engine's: `""`, `0`, `null`, `false` are false). Anything else (a list, another function, a text compared with a
number) is left to the engine.

Why no mark of its own (a `{= …}` for "now", say): the writers of the corpora wrote `{size/4}`, `if badge` and
`"{upper(label)}"` meaning exactly this, and no one wrote a second kind of brace. The two readings cannot disagree
on what is shown: an expression that names nothing has the same value at run time as now. A body that means "at
run time" reads something that changes (a variable, a row), and such an expression is never worked out early. What
changes is the document: a fixed value where a binding of it was, and no hidden node where an `if` was false (Cards'
`AttachmentTile` with no `onDownload` has no download button, where it had one hidden), which an editor shows as
what it is.

### 13.2 The line that takes a use's other words (G3)

```
Section gap=32
  Column~section w=fill center pad=[24,64,24,64]
    Column w=fill maxw=1120 gap={gap} ...
      ...
```

A body line may carry `...` as a word of its own (after its head, outside its strings and braces): **the use's
words go there**, not on the root. Those are the universal words (section 2), as before, and with the mark every
other word the use writes that the signature does not name: a key (`tablet.w=64`, `id=pricing`), a flag, an event.
They are then read as a page's line reads them (a word that line does not have is recorded or said there, as on any
line), where without the mark they are recorded as words the definition does not have (open) or an issue (closed).
The words go where the mark is, and a key the line writes too is the use's (`Box2 pad=4` over `Column pad=24 ...`
is `pad=4`). The root keeps the use's id; with several lines at the margin (13.3) the id goes on the marked line too.
A word's own parameters still go where the body reads them: `IconTile`'s `color` on its icon, with `color={color}`
there.

`...` at the start of a line is still a slot (section 3): a slot holds the lines under a use, `...` after a head
the words on the use's line.

### 13.3 Several lines at the margin (G4)

```
SidebarFooter gap=2 pad=[0,8,0,0]
  Spacer
  Column w=fill gap={gap} pad={pad} border-top=#FFE5E7EB ...
    ...
```

A body of several lines side by side was already its lines written where the use is (section 2). What was missing
is where a use's words go: a Column holding the lines took them. With the mark of 13.2 they go on the marked line,
and the lines stay where the use is (`SidebarFooter` is a Spacer and a ruled column in its sidebar, not a column
holding both).

### 13.4 A role on the root (G5)

`Row~app`, `Column~section`, `Column~sidebar`, `Column~main`, `Column~pane`, `Row~nav`, `Column~foot`: a body's
lines may say which frame they are, after the type, as the page words' lines do. The reflow lays them out at a
tablet's and a phone's width by it (a section's padding, a sidebar folded to a rail), and the role is taken off
before the line is read. Before, a body's root with a role was refused ("the first line … is a node"): a role is
read on any line of a body, root or not.

### 13.5 A word that stands for a statement (G7)

```
// A keyboard shortcut of the screen.
Shortcut "keys" key keys combo hint description label onPress
  key {replace(coalesce(keys, key, combo), " ", "")} ... onPress={onPress}

// A value worked out from the state.
computed
  state ...
```

A body of statement lines alone (`key`, `state`, `every`, with no node) is **those lines, written where the use
is**: `Shortcut "v" hint="V" onPress={go board}` is `key v onPress={go board}`, `computed total={sum(cart)}` is `state
total={sum(cart)}`. Such a word may be lowercase, as a statement is (`computed`); every other word is still
capitalised. The statement reads the use's values as any line does: `{…}` worked out (13.1) is the chord, written
bare, and `...` takes the use's other words where it is written (`Shortcut "enter" when trim(draft)!="" onPress=…`
is `key enter when trim(draft)!="" onPress=…`; `when={…}` the same, braced). A `state` line with a name of its own
(`state open=false`) is still the word's own state, renamed to the use's (section 4); `state ...` is the use's.

### 13.6 What is still not said

- **G1, the frame a use is under** (a `NavItem` in a bar or a sidebar, a heading in an app or on a website):
  section 14.
- **G9, the theme**: section 16.
- **G6, G8 and G10** are the base: overlays, lines that read or move other lines, what is written outside a use's
  lines (note 23 section 5.1).
- **Whether a value was written** cannot be asked apart from its value: `if name` with a name `"{row.icon}"` is read
  at run time (the text may be empty), where the code tests only that a name was written.

## 14. A meaning chosen by the frame a use is under (G1): the options, not built

Most page words mean one thing in a sidebar and another in a bar, on a website and in an app: `NavItem` takes the
width in a sidebar and sits beside the others in a bar; `Brand` has padding and a 15 px name in a sidebar, none and
17 px at the start of a bar; `H1` is `Text.heading1` at 60 px in a website's section and `Text.title` in an app;
`Link` is a quiet button in a bar and accent text elsewhere. Section 5 chooses a meaning by what a use gives, never by
where it is. This is the most widely needed extension (note 23 table G1: sixteen words), and it needs a decision
first, because what a "frame" is changes as the frames themselves move to the dictionary.

**What the code reads.** `PageWords` keeps the lines open above the one being read, each with the frame it opened
(`Page`, `App`, `Section`, `Nav`, `Sidebar`, `Main`, `Pane`, `Foot`, `Table`; a plain line opens none, an `if` or an
`each` passes its parent's on). A word asks either its parent's frame (`NavItem`: is the line directly above a
`Nav`?) or whether a frame is anywhere above it (`Link`: any `Nav`; `Heading`: an `App` at the top, or a `Section` of
a `Page` and no `Nav` or `Foot` between). The frames are named by the code, not by the words written: `Header`,
`TopBar` and `AppBar` open `Nav`; `Aside` and `Rail` open `Sidebar`; a website's `Footer` opens `Section` and an
app's opens `Foot`.

**The form, in every option.** A meaning names the frames it is for before its word, as a CSS selector does, `>`
for "directly under":

```
NavItem "label" icon!                      // anywhere else (the sidebar's look)
Nav > NavItem "label" icon!                // a line written directly in a bar
  Row gap=10 middle pad=[10,7,10,7] radius=6 ...
    …
Section H1 "text"                          // in a website's section
  Text.heading1 "{text}" size=60 ...
App H1 "text"                              // in an app
  Text.title "{text}" ...
App Nav Heading "text" level=1             // in an app's top bar
  Text.heading3 "{text}" ...
```

A use is read with the meanings whose frames it is under; of those, the one that names the most frames (the most
specific), then as section 5 says. A meaning that names no frame is for anywhere. The question is what the names
before the word mean.

**Option A: the code's frames.** The names are `PageWords`' frames, asked of `PageWords` as the use's line is read
(it has read every line above). It is exact for every word in note 23 today (the closure test can take H1, Brand,
Link, NavItem and Heading to their frames), and it costs a callback from the parser to `DefinedWords`. But the names
are the code's, not the writer's (`Nav` stands for `Header` too; a website's `Footer` is a `Section`), and they last
only as long as the frames are code: once `Sidebar` is a definition, nothing opens a `Sidebar` frame.

**Option B: the words written above.** The names are the lines' first words as written (`Sidebar > NavItem`,
`Header > NavItem`). A writer reads it at once and a definition can name its own frame words (`Pane > ListRow`). But
each meaning lists every other name of its frame (`Nav, Header, TopBar > NavItem`), which puts the synonyms back in
the package that the owner wants in the project's vocabulary; and a frame's synonym added to the vocabulary does not
reach the meanings.

**Option C: the roles.** The names are the roles the frame lines carry (section 13.4): `~nav > NavItem`, `~sidebar
Brand`, `~section H1`, `~app Heading`. A frame is whatever line says it is one, written by a page word in code today
and by a definition's root tomorrow (`Sidebar` as `Column~sidebar …`), so it survives the frames' own move and needs
no synonyms: `Header` is a `~nav` because its expansion says so. The reflow already reads the same marks. What it
costs: the parser must keep each open line's role (it does, after the line is read: `_roles`), a page word's root
must carry its role even where it carries none today (a website's `Footer` band is `~section`, its `Nav` row `~nav`;
`Foot` is `~foot`), and a role that differs from the code's frame changes which meaning is chosen (a website's
`Footer` is a `Section` frame to the code and is `~section` too, so they agree; a `Nav` outside any frame opens no
frame and carries no role, so they agree).

**The recommendation is C**, with the code's frames (A) as the way to check it: during the move, a use's chosen
meaning by role and by the code's frame are compared over the corpora, and a difference is a role missing on a line.
It is medium-sized in code (the selector in the signature, the role stack, the choice) but it decides the names a
dictionary's frame words are written with, which is the owner's to settle. It is not built: no word can move by it
until the frame words carry the roles the dictionary would read, and the words that would close by it also read the
theme (13.6), so none of them moves yet.

## 15. The built-in dictionary

A word the notation has may be a definition in its base words instead of Dart code (note 23 section 5.2). Such a word
is a file of the package's `dictionary/` folder, named in `builtInWords` of `tool/dictionary/generate.dart`, which
writes the files' texts into `lib/src/core/notation/dictionary.g.dart` (`notationDictionaryTexts`): the notation
runs in apps and on the web and reads no files. `notationDictionary` reads them once; the parser reads them under the
design system's definitions, so:

- a design system's definition of the word, or its component of that name, is the word, as either is over a page
  word;
- a page's own `define` of it is not used and is said (`notationBuiltInWord`), as for every word the notation has;
- a use is recorded as kind `definition`, `of: dictionary`, `to` the meaning read (the SDK's vocabulary record:
  `resolved: definition`, `definedBy: dictionary`, `origin: dictionary`);
- `notationWordOrigin(word)` says where the notation's meaning of a word is written: `base` (a node type, a
  statement), `dictionary`, or `code` (a page word, a heading, a line the alias table rewrites).

A word is added only when its closure is exact over every use (`CLOSURE.md` marks it built in) and the expansions of
its uses are the same documents before and after its code is removed. The first is `computed` (section 13.5's
`computed` over `state ...`).

## 16. The theme read in a body (G9)

The owner's decision: a definition reads the theme as `{theme.<name>}`. The names are the looks the page words read
(`notationThemeReads`, from `NotationOptions`, which the design system's or the site's theme fills, or the core's
looks with none), and each is what the page words write:

| name | the page words' value | read by (today, in code) |
|---|---|---|
| `accent` | the accent, as the theme names it (`primary`) or its value | NavItem, Brand, IconTile, Link, Dots |
| `accentText` | the accent as text on a light page; nothing when the theme has none | Link |
| `line` | the rule colour | Sidebar, Pane, Footer, SidebarFooter, the foot |
| `selectedFill` | the chosen item's fill | NavItem, IconTile |
| `surface`, `overlaySurface` | what a drawer's panel and an app's foot are drawn on; the role an overlay is drawn in with no theme (`surface`), else nothing | Drawer, the foot |
| `track` | a progress's track | Dots |
| `band`, `siteFill`, `paneFill`, `sideFill`, `iconTile` | a tinted section's fill, a website's ground, a pane's, a sidebar's, an icon's tile; nothing when the theme names none | Section, Page, Nav, Sidebar, IconTile |
| `hoverFill` | an item's tint under the pointer: the theme's role `hoverFill` when the document names its colours, else `#0F111827` | NavItem |
| `quietInk`, `mutedInk`, `faintInk` | a dark theme's inks for items at rest; nothing in a light theme | NavItem, NavSection, Brand |
| `contentWidth`, `narrowWidth`, `sidebarWidth`, `sidebarRail`, `sectionPad`, `gutter` | the theme's sizes (`sidebarRail` only where the page reflows, 700 wide and up) | Section, Nav, Sidebar |
| `siteHeadline` | a website's headline size, 60, or nothing when the theme's `heading1` or `pageTitle` has a display size | Heading, H1–H3 |
| `style.<name>` | the text style's name when the theme has it, else nothing | every heading, the overlays' titles, NavItem's count |

**Read as the use is expanded**, not left for the renderer: the page words write the value (or the theme's name for
it) into the line as they read it, so a definition that writes the same gives the same document under every theme,
named or not, light or dark (the dark inks are in the options). `fill={theme.paneFill}` alone after a key is the
value as the page words write it (`fill=card` named, `fill=#FFFFFFFF` not), and nothing leaves the key out, as `if
paneFill != null` does in the code. In an expression a colour is written as the page words write one there: its
value in quotes, a role as `theme.primary`, a colour the theme names as `theme.colors.<name>` (read at run time, as
`Dots` reads it); a size is its number; a style its name in quotes, so `Text.{coalesce(theme.style.caption,
"muted")}` and `{coalesce(theme.mutedInk, "#FF6B7280")}` work out as the use is read (section 13.1, which now also
works out a call such as `coalesce(…)` inside an expression that still reads the state). Any other `theme.` name is
the theme the app runs with (`theme.colors.ink`, `theme.isDark`), left as written; a name that is neither is an issue
on the use that lists the names. A page's own `define` and a design system's definitions read it the same way.

With it the dictionary's words differ from the code's under Cards' and Desk's themes exactly where they differ at
the core's looks (note 23 section 9): the theme is no longer a reason a word does not close. `NavSection` and `Brand`
still differ under Desk, where its sidebar is a rail at a tablet's width and the code hides their labels there: that
is the frame (section 14).

## 17. A definition that reacts to its parameter changing: the options, not built

`ThemeMode mode={appearance}`, `FollowingLog request={req}`: the word should run its actions each time the value its
use gives changes. A body has `on load={…}` (once) and `on valueChanged(variable=x)={…}`, which names a variable, not
an expression; the use gave an expression (`(appearance)`, or `(prefs.mode)`), so the body has nothing to name.

- **A. A reaction on a parameter**: a body line `on mode changed={setThemeMode mode={mode}}` (or `on change(mode)`).
  As the use is expanded, a use's value that is a variable (`{appearance}`) becomes `on
  valueChanged(variable=appearance)`; any other expression gets a derived state of the use's own (`state
  mode_themeMode1={prefs.mode}`) and the reaction names it. A written value (`mode="dark"`) never changes, so the line
  is left out. Small in `define.dart`; it needs the engine to raise `valueChanged` for a derived state, which is
  not checked.
- **B. A parameter bound both ways**: the signature says `mode=@` and the body reacts to its own variable (`on
  valueChanged(variable=mode)`). A use that binds its variable (`mode=@appearance`) gets the reaction; a use that
  gives an expression does not. No new grammar, but the writer must bind, which the corpus writers did not.
- **C. Leave it to the use**: the word applies its value on load, and the page's control runs the action on change
  (today's workaround in `ThemeMode`).

A is the form writers wrote; it is left for a decision because it adds a statement form to a body.
