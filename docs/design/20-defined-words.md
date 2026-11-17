# 20. Words defined in the notation

2026-11-16. Decided in the vocabulary loop's first review (SDK `tool/vocabulary/JOURNAL.md`, Review 1, D2). Built
in `lib/src/core/notation/define.dart` (read, check, expand) with a few hooks in `notation.dart`; tests in
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
| `Word` | the word (capitalised; never a core type, a short name, a page word or a component of the design system in use) |
| `Word.a.b` | the variants a use may write (`Timeline.vertical`); the body reads the one written as `{variant}` |
| `Word#name` | the name of this meaning, when one word has several (section 5) |
| `"text"` | a string, by its name; a use fills the strings in order, or by name (`text="…"`) |
| `key=value` | a parameter with its default |
| `key` | a parameter with no default (empty when not given) |
| `key!` | a parameter a use must give |
| `key=true`, `key=false` | a flag: a bare `key` on a use is `key=true` |
| `bind=name` | the variable the word keeps its value in: a use's `bind=x` names it; without one it is the word's own `state name` (section 4) |
| `onEvent` | an event the word gives (`onTap`, `onPick`) |

The body reads its parameters by name in braces, as a page reads a variable, and the use's values are put in
where they are read, as written:

- `key={p}` alone is the use's value as written (`fill=#FFFDE68A`, `fill={c.hex}`, `items=["a","b"]`); a parameter
  with no value and no default leaves the key out.
- `"… {p} …"` in a string: the use's string spliced in (`"Buy milk"`), its expression kept (`{item.name}`).
- `{… p …}` in an expression: the value as an expression (`{level*100}` is `{(p.water)*100}`, a string is
  `"…"`, a bare word is `"word"`, a variable name given to `bind` is the name).
- `onTap={onPick}` in an event: the use's actions; `onTap={onPick(c)}`: those actions with `result` as `c`. An
  event with nothing left is left out.
- `if p`, `each x in p`: the statement's expression, the same.
- A body written as `if visible` over its one node is that node with `visible={visible}`: models write a word that
  can be hidden that way (the journal, Review 4, D21). `state` lines before the root are the word's own state.
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
for that key; an event joins the root's own. Anything else is a word the definition does not have: with the open
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
FlipCard bind=flipped h=240 radius=16 onTap
  state flipped=false
  Stack w=fill h={h} onTap={flipped=!flipped; onTap}
    Column w=fill h=fill pad=20 center middle radius={radius} fill=surface border=1 visible={!flipped}
      ...Front
    Column w=fill h=fill pad=20 center middle radius={radius} fill=accentTint visible={flipped}
      ...Back
```

(Cards' own `FlipCard.txt` gives its slots their padding on the slot lines, so a use's `Front fill=…` fills the face.)

```
FlipCard bind=flipped onTap={toast "turned"}
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
notation does then holds for it with nothing added: `each` and `if` inside it, `bind=` to a page variable, a
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
  `bind=`. Two uses do not share it. Under an `each` the use is written once, so its state is shared by the rows
  (the notation's variables are the page's; a row's own state belongs in the row's item). `bind=name` in the
  signature names the variable the word keeps its value in: a use's `bind=x` puts the page's `x` there (and the
  body's own `state name` line is dropped); without it the word keeps its own.
- **Ids.** A use's root is the use's `#id` (`ColorPicker#tint`), else `<word><n>` (`stickyNote1`); an id written in
  a body (`Dialog#picker`, `scroll top`) is made the use's (`picker_colorPicker1`). The loop variables of a body's
  `each` are made the use's too, so a use's `{item.name}` reads the page's row, not the body's.
- **Events out.** A use's event is actions; the body says when they run (`onTap={onPick}`) and what `result` is
  (`onPick(c)`).
- **A definition using another.** Its body is expanded with the same definitions, its slots passing through the
  inner word's slot. A word that uses itself, directly or through others, is refused when the definitions are read
  (`StickyNote.txt:2: StickyNote uses itself (StickyNote > Pin > StickyNote): it is not read.`), and an expansion
  deeper than 8 stops with an issue.

## 5. One name, several meanings

`Timeline` is, in four answers, a clip editor's tracks (`Timeline zoom={zoom} playhead={playhead}`), a vertical
list of dated events (`Timeline` with `TimelineItem` lines), and a bus route's stops (`Timeline.vertical bind=at
position={bus}` with `TimelineStop` lines). A file may hold several definitions of its word, each a signature at the
margin, each named with `#name`:

```
Timeline#tracks zoom=1 playhead=0 heads onZoom onScrubTo
  …
Timeline.vertical#events
  …
Timeline.vertical#route bind=at position marker="directions_bus"
  …
```

A use is read with the definition that fits it best: one whose required parameters it gives; of those, the one
whose signature names the most of what the line gives (parameters, flags, events, the variant), less what it does
not name; then the one that names the fewest things the line does not give (the plainest); on a tie, the first. So `Timeline zoom={z}` is the tracks, `Timeline.vertical position={bus}` the route,
and a bare `Timeline` the events. Whether a use has lines under it is not used: the parser does not know it when
the use's line is read (section 3). The record says which meaning was read (`to: Timeline#route`).

An alias whose `requires` a line meets is still read before a definition of the same name: `RangeSlider low=a
high=b` is our `Slider bind=a bindEnd=b` (the built-in alias), `RangeSlider bind=range` is Cards' definition.

## 6. Resolved as a word we have

A defined word is a word we have. It resolves after the core, the catalog, the page words and the design system's
components (none of which a definition can change: such a definition is not read, and said), and before an alias.
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
- The prompt with the open vocabulary does not list them: that is the point (the model writes the word it expects,
  and a definition gives it a meaning). `notation.sh prompt` in the taught mode lists their signature lines and
  purposes, as it lists components.

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
`Heatmap`, `Countdown` (`#seconds`, `#clock`), `ToggleButton`, `RangeSlider bind=range` (over `Slider bind bindEnd`),
`ReorderList` (over `each … reorder`), `Table` (`#lists`, `#records`, `#rows`), `Timeline` (`#tracks`, `#events`,
`#route`), `TimelineItem`, `TimelineStop`, `Step` (`#story`, `#progress`).

Of the 98 types no word resolved before (with 33.0.0's parser and aliases; `StickyBar` is now an alias of
`Footer`, so it is not defined here), 44 are now definitions and 54 are not. Of those 54:

**Could be definitions, not written yet** (compositions of what the notation has): `PhotoGrid` (a Grid of Images;
not its drag selection), `Autocomplete`, `CommandList`, `FuzzySearch` (an Input and `fuzzy`), `DateRangePicker`
(over `Calendar bind bindEnd`), `SortableList` (`each … reorder=group`), `SplitPane` (`Row` and `Splitter`),
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
  only, so the number is an unknown flag. A signature could name one positional value; not done.

## 10. What is not done, and what it costs

- **Whether a use has lines under it** does not choose a meaning (section 5).
- **State under an `each`** is one variable for every row (section 4).
- **A definition's own words are not checked against its parameters' kinds**: `fill={color}` with a use's
  `color=quiet` writes `fill=quiet`, which the line then reads as it would.
- **Declared and unread**: a parameter a signature names and its body never reads is accepted and does nothing.
  Cards' definitions name only what they read.
- **The document holds the expansion**, not the use: an editor shows the lines a word stands for (section 4).
- **Recorded words inside a use's actions** (an unknown verb in a use's `onPick={…}`) are the answer's, recorded as
  any; a word the body itself gets wrong (other than an action verb) is an issue against the definition, open or
  not.
- **`checkDefinitions` leaves strings out** of the use it checks (a string may be a colour or an icon name, which no
  sample text is): a body that reads a string as an icon must give one when it is empty (`Icon "{icon == null ?
  "circle" : icon}"`).
