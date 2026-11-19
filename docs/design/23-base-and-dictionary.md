# 23. The base and the dictionary: the vocabulary trim

2026-11-18. A proposal: nothing here changes what the notation does. Track B of milestone 1, steps B1 (the
inventory) and B2 (the closure test), and the trim the owner asked for: "define the base words that enable the full
Codelessly API"; every other word a dictionary definition written in base words; the only exception what needs
code, traced back into the base. Notes 19 (the open vocabulary), 20 (defined words), 21 (universal words) and 22
(parity) are what it rests on.

What was made, all added files:

| what | where |
|---|---|
| the inventory tool and its table | `tool/vocabulary_inventory.dart`; `docs/design/base-inventory/INVENTORY.md`, `inventory.json` |
| 28 of the words the expander writes in Dart, written as definitions | `dictionary/*.txt` (one file a word, its meanings in it) |
| their uses: real screens and reference blocks | `dictionary/uses/<Word>.txt` (harvested), `<Word>.extra.txt` (written) |
| the closure test: both expansions, node by node | `tool/dictionary/closure.dart`, `tool/dictionary_closure.dart`; `CLOSURE.md`, `closure.json` |
| the same, as a test that runs | `test/notation_dictionary_test.dart` (33 tests) |
| the pictures compared | `tool/dictionary/render_compare.sh` (with the SDK's `tool/codelessly render --compare`); `RENDER.md` |
| the corpora against the base | `tool/corpus_closure.dart`; `CORPUS.md` |

The tools run from the package root of an LF copy, as the others do. `vocabulary_inventory.dart` and
`dictionary_closure.dart --harvest` read the SDK checkout beside it (`--sdk`); the test reads only this package.

## 1. The inventory (B1)

Every word the expander accepts, read from the code's own declarations: the catalog (`standardCatalog`: node types,
action types; `notationKeyNames` gives every key of every type), the trigger types, `notationVerbs`,
`notationFormulaFunctionNames`, `notationAnimations`, `buttonVariants`, `badgeVariants`, `defaultTextVariants`,
`mediaSizes`, `notationStateNames`, `DrawOpSpecs`, `notationUniversal`, `NotationVocabulary.core`, `notationTypes`,
`PageWords.words`, and, read from the source text where the code keeps them private, `PageWords._bars`, `_sides`,
`_items`, `_sections`, `_feet`, `keys.dart`'s `_words`, `_eventAliases`, `_borderSides` and `define.dart`'s
`_statements` (the tool stops if one of them is no longer declared). The design systems' components and defined words
are read from the SDK's `design_systems/*`. Hand-kept, and marked so: which branch of `PageWords._rewrite` reads each
page word (a word set does not say), the eight rewrites of base words in a context that have no word set (a Text with
a look, a Badge with a width, a Row turning at a width, an Input in a bar, a gallery opening the page viewer,
`sticky=true`, an Avatar's `src=`, `Row sticky bottom` in an App), and `define`, `primitive`, `component` beside
`_statements`.

### 1.1 Counts per kind

| kind | | rows | written somewhere | never written | taught |
|---|---|---|---|---|---|
| a | base: the renderer and the parser implement it | 1,290 | 520 | 770 | 283 |
| b | rewrite: written out into other lines by Dart code in the expander | 72 | 32 | 40 | 25 |
| c | alias or universal word | 144 | 105 | 39 | 53 |
| d | a design system's component or defined word (data already) | 347 | 143 | 204 | 21 |
| e | short name: a node type the parser finishes with code of its own | 28 | 23 | 5 | 23 |

1,881 rows, 1,715 distinct words: 86 words are declared in more than one kind (`Badge` is a node type and a short
name; `Dialog` a page word and a design system's component; `color` a universal word and a property). Kind a by
category: 70 node types, 788 properties, 53 events, 12 action verbs and 47 action types, 167 formula functions, 63
values (19 `animate=` words, 32 variants, 6 media conditions, 6 states), 12 draw ops and 5 record lines, 18
statements, 55 grammar words of the universal table. Kind b: 60 page words (26 frames and parts, 7 bars, 5 sidebars,
4 items, 6 group labels, 11 overlays, Table), 4 line rewrites (`Shortcut`, `shortcut`, `computed`, `ConfirmDialog`),
8 contextual rewrites. Kind e is a finding of the inventory: the four kinds of the plan miss it. `NumberInput`,
`CodeInput`, `Avatar`, `Grid`, `Image`, `Badge`, `Handle`, `Pages`, `Wanted` are node types the parser finishes in
`_Parser._lineAt` with code of their own (`NumberInput` is `Input keyboardType=number steppers=true
textAlign=center`, as `forms.md` prints it): definitions written as code too, one level down (JSON, not lines).

Counted (each a line that writes the word: a line's first word for a type, `key=` or a bare word for a property, `onX=`
for an event, `name(` for a function, a dotted condition for a media size or a state): the first corpus, 442 answers
of `tool/vocabulary/corpus*`; the round 10 harvest (its table of the words beyond the core, which does not list a core
word, and the notation it quotes; the 116 runs' own pages are not in reach); the notation reference's 152 ```notation
blocks. Taught is a token of the open prompt or the full prompt (1440 wide); documented a token of
`docs/reference/notation/*.md`.

### 1.2 Synonyms

Every type word of kinds b, c and e, and every node type, written `Word#probe "Label"` alone, in an App's Sidebar and
in a Page's Section, and the three expansions compared: 27 groups have the same three. The page words: `App AppShell
Window`; `Nav Navbar NavBar TopBar Topbar Header AppBar` (the page word shadows the catalog's `appBar`); `Sidebar
Aside SideNav Sidenav Rail`; `NavItem NavLink SidebarItem MenuItem`; `NavSection NavGroup NavLabel SidebarSection
SidebarLabel SidebarGroup`; `Main Content`; `Brand Logo`; `Section Hero`; `Heading Title H2`; `H3 H4`; `Popover
Popup`; `Sheet BottomSheet`; `SidebarFooter NavFooter`; `Footer` with its five aliases. The short names: `Input` is
`TextField`, `Toggle` `Switch`, `Progress` `ProgressBar`, `Button` `FilledButton`, `AreaChart` `LineChart`, `Grid`
`GridView`, `List` and `Box` `Column`, `Dial` `Gauge`, `DonutChart` `Donut`, `Pie` `PieChart`; and the aliases
`MiniCalendar CalendarMonth MonthGrid` (`Calendar`), `Highlight HighlightText` (`Text` with no match), `QRCode QrCode`.
`Modal` and `Dropdown` run the same branch as `Dialog` and `Menu` at the margin, where they open an overlay; the probe
separates them because inside a page they are the catalog's `modal` and `dropdown`. Three probes are not all uses: a
synonym here is a candidate, proven only by the closure harness over its uses (section 5).

### 1.3 Declared and never written

No answer of the first corpus, no line of the round 10 harvest and no example of the reference writes 770 rows of
kind a (578 of the 788 properties, 89 of 167 formula functions, 26 of 47 action types, 25 of 53 events, 27 of 70
node types: `TextField`, `FilledButton`, `Switch` among them, written under their short names), 40 of kind b (the
synonyms above, `H1` to `H4`, `SidebarFooter`), 39 of kind c and 5 of kind e. Of those the prompt teaches today:
`Content`, `Wanted`, `List`, the statements `for`, `let`, `node`, `primitive`, the draw ops `image` and `points`, the
state `dragged`, `padding` and `animation` (`INVENTORY.md`, "Declared and never written").

## 2. The closure test (B2)

### 2.1 Method

Each word of kind b the corpora write was written as a definition in base words (`dictionary/`): App, Page, Section,
Footer, Nav, Sidebar, Main, Pane, NavItem, NavSection, SidebarFooter, Brand, IconTile, Link, Heading, H1, H2, H3,
Dots, Table, Dialog, Sheet, Drawer, Menu, Popover, Lightbox, ConfirmDialog, Shortcut: 28 words, each in its own file
(a design system's `vocabulary/` is one file a word: the dictionary can be loaded as one, and a word's meanings sit
together). Each is written for the context most uses have, at the core's looks (no design system), and its `//` line
says what it does not say. The synonyms of section 1.2 are not written again: they are alias rows (section 5).

A built-in word wins over a definition of its name (the owner's decision, `notationBuiltInWord`), so a definition is
tested under a name of its own: `NavItem` is `NavItemDict` in its file and in the uses, renamed where a line starts
with it (`renameWords`), and nothing in the expander changes. Each use (99 in all: up to four screens of the first
corpus that write the word, the ones with the most shapes of it first, up to two blocks of the reference, and a few
written for shapes no answer has) is expanded at 1440, 834 and 390, with the open vocabulary, once as written and once
renamed with the dictionary loaded, and the two documents are compared node by node with every id replaced by its place
in the tree (`r0.body.2.1`; `canonical`), keys in order. "Up to spelling" also writes each expression without its spaces
and outer parentheses: the code writes `selected={(tab=="home")}`, a definition the use's `tab == "home"`. A use whose
definition side says an issue the code's does not is not the same. The frame words are also renamed together as one
family (App or Page and the thirteen words that read them).

### 2.2 Result

No word closes exactly over all its uses. Per word, the expansions that are the same of all (3 widths a use), and the
nodes the same:

| word | same | nodes the same | what differs (section 3) |
|---|---|---|---|
| Dots | 3 of 9 | 597 of 609 | the 2 other uses are a shape the code refuses (`Dots count=… filled=…`, no `@`): a placeholder there, dots by the definition |
| H1, H2, H3 | 3 of 6 each | 27 of 30; 24 of 27; 24 of 27 | on a website page the same; in an app another text style (frame) |
| Brand | 3 of 9 | 351 of 372 | in a website's bar: no padding, a larger name (frame) |
| NavSection | 3 of 9 | 257 of 272 | a written label in capitals (expansion-time value); same when written in capitals or worked out |
| Link | 3 of 12 | 724 of 736 | `href=` (expansion-time value); in a bar a quiet button that joins the phone menu (frame, other lines) |
| Main | 4 of 15 | 545 of 883 | the drawer's menu bar, the window's foot, Pane reading whether Main came first (frame, other lines) |
| Section | 3 of 15 | 697 of 717 | the role mark the reflow reads (the tablet and phone padding); `bleed`, `compact`; alignment words go inside |
| Sidebar | 2 of 12 | 599 of 769 | the phone drawer copied from it; the lines under it read it (Brand, NavItem's rail) |
| NavItem | 0 of 18; up to spelling 9 | 1,687 of 1,787 | spelling; a bare `selected` and an item with no icon (expansion-time choice); a hint |
| Pane | 0 of 18 | 1,741 of 1,765 | which side its rule is on (it counts whether Main came before it); outside an App |
| Heading | 0 of 15 | 877 of 907 | the text style by level and by frame |
| IconTile | 0 of 9 | 450 of 471 | `radius={size/4}` worked out at run time (the code writes 10); no `star` default |
| Footer, SidebarFooter | 0 of 9, 0 of 3 | 303 of 333, 39 of 69 | a Divider or a Spacer beside the band: a body is one line |
| Nav | 0 of 15 | 703 of 1,140 | three bars by frame; the Divider after it; the phone menu of its Links |
| Page, App | 0 of 9, 0 of 15 | 365 of 608, 175 of 501 | the lines under them read them (every frame word); App's drawer, the canvas's height |
| Table | 0 of 18 | 1,305 of 1,680 | a cell per column written out as the use is read; the n-th line under it the n-th column's cell |
| Dialog, Sheet, Drawer, Menu, Popover, Lightbox | 0 of 15, 12, 3, 6, 6, 6 | 123 of 676 … 7 of 174 | a block of its own: another canvas, and how `open` shows it |
| ConfirmDialog | 0 of 3 | 102 of 141 | the same (its Dialog), and `destructive` |
| Shortcut | 0 of 18 | 235 of 618 | refused: a body's first line is a node, `key` a statement |
| App family, Page family | 0 of 15 (1 up to spelling), 2 of 9 | 161 of 501, 311 of 608 | renamed together the frames no longer know each other |

So: **the words that close**, as definitions today: none over every use. `Dots` closes on every use the code reads
(and draws one shape more), `H1`, `H2`, `H3` on a website page, `Brand` in a sidebar, `NavSection` with a label written
as it shows, `Link` in running text with an action, `NavItem` in a sidebar up to spelling and pixel for pixel (2.3).
**The words that do not**: all 28 over all their uses, for the reasons of section 3; `computed` (a lowercase word: a
signature is capitalised), `SwipeAction` (a design system's list row's slot) and `Wanted` (a record for the host) were
not written.

### 2.3 The pictures

The 1440 expansions of 13 words (H1, H2, H3, Dots, NavItem, Brand, Heading, IconTile, Link, NavSection, Pane,
Section, Sidebar: 48 uses) were rendered both ways at 1440x900, 834x1112 and 390x844 (`tool/codelessly render`, then
`render --compare` a screen at a time: given a folder, `--compare` finds no reference on Windows, whose paths it
lists with `\`): 144 captures, 72 with no pixel different (`RENDER.md`).

- **The same picture where the documents differ in how a value is reached**: NavItem in 4 of its 6 uses at every size
  (among them the bare `selected`: a fixed fill in the code, a binding in the definition), IconTile in 2 of 3
  (`radius={40/4}` draws as `radius=10`), Pane in 4 of 6 (a rule on the other side, or a height its row gives it anyway), H1, H2
  and H3 on a page, Brand in a sidebar, Link in 2 of 4 (one of them without the `openLink` action of its `href`: a
  picture does not show what a tap does).
- **Close where a frame changes one text style or one line**: an app's H1 to H3 (99.5 to 99.9 % of pixels), Heading
  (93.8 to 99.8 %), Brand in a bar (98.3 to 99.6 %), a NavItem with no icon (99.2 to 99.5 %).
- **Far where the role mark is missing**: Section is the same at 1440 in 4 of 5 uses and 73.9 to 99.6 % at 834 and
  390 (the reflow's tablet and phone padding is not applied); a Sidebar at 390, 93.6 to 99.9 % (the code hides it on a phone and opens it as a drawer).
- Dots: the same where the code reads the use; 91.7 to 98.9 % where it draws a placeholder and the definition dots.

## 3. What the code does that a definition cannot say

Every difference of section 2 is one of ten things. Each is either a small extension of `define`, which would close
several words at once, or a true base item, which needs code.

| | what the code does | words | reading | cost |
|---|---|---|---|---|
| G1 | **reads the line it is under**: the frame it is in (a Sidebar's item, a website's or an app's bar, a heading in an app's top bar) | Page, App, Section, Footer, Nav, Sidebar, Main, Pane, NavItem, NavSection, Brand, Link, Heading, H1–H3 | `define` extension: a meaning chosen by the words it is under (`NavItem in Nav`), and a definition that is a frame for its slot's lines. The parser already records each line's `path` | medium |
| G2 | **works a value out as the use is read**: a line or a key only when a parameter is given; `size/4`; a label in capitals; `level` choosing a text style; `href` choosing `link` or `scroll`; a flag choosing a fixed look | NavItem, NavSection, IconTile, Heading, H1–H3, Section, Brand, Link, Table, ConfirmDialog | `define` extension: an expression whose names are all the use's written values is worked out at expansion; an `if` that comes out false drops its lines; a variant from an expression (`Text.{…}`). Today an `if` in a body is a run-time condition (`visible={null}`) and `{size/4}` a binding | small |
| G3 | **sends a use's words elsewhere than the root**: a Section's alignment words to its inner column, an IconTile's `color` to its icon; and keeps every key a use writes (`tablet.w=64`), where a definition passes the universal words only | Section, IconTile, Sidebar, every frame | `define` extension: a named place for what the use writes (`...rest` on a body line) | small |
| G4 | **writes two lines where one is written**: a Divider beside the bar or the band, a Spacer before the sidebar's foot | Footer, Nav, SidebarFooter | `define` extension: several lines at a body's margin | small |
| G5 | **marks the frame for the reflow** (`Row~app`, `~section`, `~sidebar`, `~main`, `~pane`, `~nav`, `~foot`, `~cell`, `~appmenu`): `PageReflow` lays a page out for a tablet and a phone by them | App, Section, Sidebar, Main, Pane, Nav, Footer, Table | base: the roles are base words (reflow.dart reads them). `define` refuses a role on a body's root (`LineParts` reads no `~`): a one-line extension | tiny (the define side) |
| G6 | **makes a block of its own**: another canvas, shown by `open` as a dialog, a sheet, a drawer, a menu or a popover, with what closes it, and `close` after the actions of its items | Dialog, Sheet, Drawer, Menu, Popover, Lightbox, ConfirmDialog | base: an overlay is a canvas and a presentation, written once after the page. Either the five overlay heads stay base statements, or the presentation becomes keys of `Canvas#id` and the overlay words are definitions over it | medium |
| G7 | **stands for a statement**, not a node: `Shortcut` is a `key` line, `computed` a `state` line | Shortcut, shortcut, computed | data: an alias row whose target is a line (`TypeAlias.line` is the code of one today; its template can be data) | small |
| G8 | **reads, counts or moves other lines**: a Table's n-th line into the n-th column and a header cell per column of a written list; a Pane's rule on the side away from Main; a Nav's Links collected for its phone menu; an App's first Sidebar copied into a drawer and a button put in Main; a window's foot moved to the end of Main | Table, Pane, Nav, App, Sidebar, Main, Footer, Link | split: a `for` over a written list at expansion and "the n-th line under the use" are `define` extensions (medium); the drawer, the phone menu and the window's foot are page layout, base behaviours with names of their own (large) | medium; large |
| G9 | **reads the theme**: the site's, a pane's and the sidebar's fill, the band, the tile, the accent's name, which text styles exist | Page, Section, Sidebar, Nav, IconTile, Heading, Dots, Table | `define` extension: a theme name with a fallback in a value. Not tested: every expansion here is at the core's looks | unknown |
| G10 | **writes outside its lines**: the canvas as tall as the window, the variables an overlay keeps, a wanted block for the host, a gallery's page viewer | App, Lightbox, Wanted, a gallery | base | |

Three things the test found besides:

- **A bug in the code it replaces.** `PageWords._expr` (page_words.dart) takes every space out of a selected
  expression, inside its strings too: `NavItem "Sent" selected={folder == "Sent items"}` compares with `"Sentitems"`
  and is never chosen. The definition reads the expression as written.
- **A shape the code refuses.** `Dots count=… filled=…` (no `@`) is a placeholder; the definition, its `@page` with a
  default, draws it.
- **The SDK's `render --compare <folder>`** finds no reference on Windows (above).

## 4. The corpora against the base

`CORPUS.md`, from the SDK's `notation.sh vocabulary` run again at 36.0.0 over the first corpus (with Cards, as it was
written) and from the round 10 harvest. A word beyond the core is **defined by the writer** when it resolved to a
definition or a site's component, **maps to a word we have** as an alias, a component, a universal word (and, in the
corpus not asked to define, a Cards definition), and has **no definition that renders** when unknown, refused, a
primitive, or given and never read.

| corpus | words beyond the core | defined by the writer | maps to a word we have | none that renders | types: defined / maps / none |
|---|---|---|---|---|---|
| first corpus, not asked to define (313 answers) | 4,052 | 0 | 1,053 (26.0 %) | 2,999 (74.0 %) | 0 / 111 / 416 of 527 |
| first corpus, asked to define (128 answers) | 2,090 | 1,708 (81.7 %) | 157 (7.5 %) | 225 (10.8 %) | 354 / 36 / 3 of 393 |
| round 10 (116 runs) | 1,859 | 1,660 (89.3 %) | 58 (3.1 %) | 141 (7.6 %) | 383 / 5 / 7 of 395 |

By uses in round 10: 13,375, of which 91.7 % defined, 4.5 % mapped, 3.8 % none. Whether a definition draws the
thing or a labelled box is not measured here (note 20 section 12 found a third hollow in twenty standalone runs).

The recurring words with uses that have no definition that renders, round 10, by runs: `Mast` (19 runs), `Masthead`
(18), `App` (12: written inside a site's component, where the page words are not read), `NavSection` (9, the same),
`Toggle.semanticLabel` (5), the key `e` (5), `Slider.semanticLabel` (4), `EntryForm` (4), `Image.url` (4),
`Grid.crossAxisSpacing` (4), `Grid.mainAxisSpacing` (4), `setThemeMode` (4, as a verb), `MethodCard` and its
`signature` (3), the key `n` (3), `Console` (3), `RangeSlider` with `end`, `max`, `min` (3). Types with no definition
that renders in most of their uses: `App`, `NavSection`, `RangeSlider`, `Navigation`, `LibraryLinks`, `FilePicker`.
In the first corpus not asked to define, the types no word has, by files: `Marker` (9), `SeatMap` (7), `FileDrop` (6),
`Ruler` (5), `Compass` (5), `Knob` (4), `MapMarker` (4), `Pin` (4), `Wheel` (4), `Flag`, `Clock`, `Hotspot`, `Lane`,
`Arrow`, `Confetti`, `Footer`, `LevelMeter`, `MapPin`, `Marquee`, `Minimap` (3 each).

### 4.1 The five primitives of the first corpus, at 36.0.0

| primitive (journal, D18) | in the base now? | evidence |
|---|---|---|
| a map, a surface with markers, a route, a position | no | no node type in the catalog; the open prompt tells writers to declare it `primitive` (`prompt.dart`, the define paragraph); Cards' `MapView` stands in |
| a positioned surface that drags, resizes and zooms | mostly | placed children: `x=`, `y=` in a Stack (`layout.md`); `pan` follows the pointer (`interaction.md`, `pan`); `transformGesture`: pinch, wheel, pan, rotate, bounds (`interaction.md`); `draggable`, `dropTarget`; `measure` writes a node's box (`behavior_fields.dart`). Not: resize handles, a marquee (note 21 section 10) |
| a drawn series: waveform, level meter, spark | yes | `customPaint` and its ops `path`, `points`, `repeat` over data (`paint.md`); `LineChart`, `PlotChart`, `BarChart` (`charts.md`) |
| scroll position as a value | yes | `onScroll` with `result.offset`, `max`, `fraction` (`events.md`); `viewProgress` writes the progress to a variable (`animation.md`); `onEnterViewport`, `onExitViewport` |
| capture: signature, file drop, camera frame | partly | `Signature` (`forms.md`); `captureScreenshot` (`media.md`). Not: a file dropped from the device, a camera frame |

## 5. The proposal

### 5.1 The base

| category | words | why it must be base |
|---|---|---|
| node types | 70 | each is a renderer widget |
| properties | 788 | each is a field of a node type's declaration; `keys.dart` derives them, so they cannot drift (taught: a few dozen) |
| events | 53 | each is a trigger type the runtime raises |
| actions | 59 (47 types, 12 verbs) | each is an action the runtime runs; a verb is its short form |
| formula functions | 167 | the engine's functions (`FormulaEvaluator`) |
| values | 63 (19 `animate=`, 32 variants, 6 media conditions, 6 states) | each is a table entry the parser reads into a node: presets, styles, conditions |
| draw ops and record lines | 17 | the painter's ops; `customPaint`, `animation`, `track`, `transition`, `foregroundPainter` |
| statements | 18 | the grammar: `state`, `each`, `if`, `key`, `every`, `define`, `primitive`, `component` … |
| grammar and universal words | 74 (55 + 19) | one table (note 21): what every line takes |
| frame roles | 9 (`app`, `nav`, `section`, `sidebar`, `main`, `pane`, `foot`, `cell`, `appmenu`) | the reflow reads them (G5); today written only by the code |
| overlay presentations | 6 (dialog, sheet, drawer, menu, popover, lightbox) | a canvas shown over the page in one of these ways needs the runtime (G6) |
| page behaviours | 3 (the first pane as a drawer on a phone, a bar's links as a menu on a phone, the window's foot kept in view) | layout over several lines, which the reflow does (G8) |

1,309 words today (kind a and the universal words), and 18 the closure says need code and have no word of their own
yet: **1,327**. Of them the prompts teach 283 of kind a (82 properties, 48 functions, 47 grammar words, 32 variants,
27 node types …) and 6 of the 19 universal words today; the trim of what is taught is 5.3.

### 5.2 What moves to the dictionary, in order

Each move takes a word out of Dart and puts its definition (or its alias row) in data. **Nothing changes for an
existing document**, and that is tested the way this note's test runs, with the rename taken away: every use the
dictionary has, and every screen of the first corpus and of round 11's records and every example of the reference that
writes the word, expanded before the move (the code) and after it (the definition) at 1440, 834 and 390, the two
documents equal node by node; then the API's tests, `notation_coverage` (real gaps 0) and the SDK's renders at the
three sizes compared pixel for pixel.

1. **The synonyms as alias rows** (no extension needed): the 29 page words the probe of section 1.2 groups with
   another (`AppShell`, `Window`, the six bars, the four sidebars, `NavLink`, `SidebarItem`, `MenuItem`, the five
   group labels, `Content`, `Logo`, `Hero`, `Title`, `H2`, `H4`, `Popup`, `BottomSheet`, `NavFooter`), and `Modal` and
   `Dropdown` as overlay heads only, become rows of `NotationVocabulary.core` pointing at their word. They already run the same branch of the code, so the move
   changes no document by construction; the test proves it over the corpora.
2. **Dots** (no extension needed): its definition closes on every use the code reads. It also draws `Dots count=…`
   without `@`, which is a placeholder today: a change of picture for those uses (question 6).
3. **After G2, G3, G4 and G5** (small, one release): IconTile, NavSection, SidebarFooter, and the parts of NavItem,
   Section, Footer, Brand, Link and Heading that are not about their frame.
4. **After G1** (medium): the frame family, Page, Section, Footer, Nav, Sidebar, Main, Pane, NavItem, NavSection,
   Brand, Link, Heading, H1 to H3, except what G8 keeps in the base.
5. **After the `for` and the n-th line of G8** (medium): Table.
6. **After the owner's answer on G6**: Dialog, Sheet, Drawer, Menu, Popover and ConfirmDialog over a canvas with its
   presentation; Lightbox's zoom and paging stay base until a definition can carry its gesture.
7. **Shortcut, shortcut, computed** as alias rows whose target is a line (G7).

What stays code, as the base items of 5.1: App's drawer and the button for it, Nav's phone menu, the window's foot,
the gallery's page viewer, `Wanted`, `SwipeAction`, and the short names' finishing code (kind e), until each is
closure-tested as section 2 did the page words.

### 5.3 What is taught

Taught and written by nobody (section 1.3): `Content`, `List`, `Wanted`, `for`, `let`, `node`, the draw ops `image` and
`points`, the state `dragged`, `padding`, `animation`. Proposed: stop teaching `Content`, `List` and `Wanted` (a word
with a written synonym, or a block a writer reaches for as `primitive` now) and keep accepting them; keep `primitive`,
the draw ops and `dragged`, which name capabilities the corpora asked for. No synonym of section 1.2 is taught today
but `Content`; none should be. The node types written under their short names (`TextField` as `Input`) stay taught
by the short name.

### 5.4 What `define` needs first

In the order of words closed for the cost: G2 (expansion-time values and choices) and G5 (a role on a body's root)
first, then G3 (where a use's other words go) and G4 (several lines at the margin), then G1 (a meaning by the frame
it is in), then the `for` and the n-th line of G8. G7 is a change to the alias table, not to `define`. Each gets a
design note before code, and each is done when the closure test of its words passes with the rename taken away.

## 6. Questions for the owner

1. **The synonyms** (31 page words, 1.2 and 5.2) become alias rows: no picture changes, but the alias table is data a design
   system can extend or override. Is that wanted for the page words?
2. **The roles** (`~app`, `~sidebar` …): base words a writer may write and the prompt teaches, or base words only
   definitions use?
3. **The overlays** (G6): keep `Dialog`, `Sheet`, `Drawer`, `Menu`, `Popover` as base statements, or make the
   presentation keys of `Canvas#id` and the overlays definitions over it?
4. **The page behaviours** (G8): name them as base properties (a pane that is a drawer on a phone, a bar whose links
   are a menu on a phone)? Naming them makes them something a writer can turn off: a picture can then change.
5. **Heading**: keep one text style per level and frame (needs G1 and G2), or one per level (the picture of an app's
   headings changes)?
6. **Dots without `@`**: a placeholder today, dots once the definition is the word.
7. **The `_expr` bug** (section 3): fixing it makes `selected={x == "Sent items"}` true where it should be; a document
   that relied on it shows a different item chosen.
8. **Teaching**: stop teaching `Content`, `List`, `Wanted`?
9. **Kind e** (`NumberInput`, `Avatar`, `Grid` …): closure-test them as definitions too, at the JSON level they are
   written at, or keep them base?

## 7. What is not verified

- The closure ran at the core's looks only: no design system's theme (G9 is untested), no `--named` colours.
- The uses are a sample: up to four screens and two reference blocks a word, the ones with the most shapes; Drawer,
  ConfirmDialog and SidebarFooter have one use each, Lightbox, Menu and Popover two.
- Kind e and the eight contextual rewrites were probed for synonyms only, not closure-tested.
- The round 10 counts come from its harvest (the table of words beyond the core and the notation it quotes); the 116
  runs' pages were not in reach, and round 11's records were not read.
- The pictures: 13 words, 48 uses, three sizes, compared by the share of matching pixels and the first row that differs;
  no state was driven (no tap, no hover, no open overlay).
- "Taught" is a token of the prompt's text, not a judgement of whether the prompt explains the word.

## 8. After the first extensions (2026-11-18, later)

`define` now says G2, G3, G4, G5 and G7 (note 20 section 13); G1 is designed and not built (note 20 section 14:
it needs the owner's choice of what names a frame). The dictionary was rewritten with them, `computed` was added
(a statement word), and uses were added for the shapes the code reads that a definition does not (`Shortcut space
onPress=…`, `Shortcut "F2" onKey=…`; a Brand in a sidebar's foot, a foot outside a sidebar). The closure, before
(37.0.0) and after, expansions the same of all and nodes the same:

| word | before | after | still differs |
|---|---|---|---|
| `computed` | not written | 12 of 12, 1,103 of 1,103: **closes** | moved to the built-in dictionary |
| `Shortcut` | 0 of 18, 588 of 618 | 18 of 21, 624 of 627 | closes on every corpus use; a chord written as a bare word and an event under another name (`onKey=`) the code reads |
| `SidebarFooter` | 0 of 3, 39 of 69 | 3 of 6, 127 of 146 | closes on its sidebar use; a Brand in the foot (the code opens a sidebar frame for the foot: G1), a foot outside a sidebar (no word there in the code); the theme's rule (G9) |
| `NavSection` | 3 of 9, 257 of 272 | 6 of 9, 267 of 272 | a label worked out from the state: the code shows it as written, the definition in capitals at run time (whether a value was written cannot be asked: note 20 13.6); the rail (G1); the theme's ink (G9) |
| `Link` | 3 of 12, 725 of 739 | 6 of 12, 728 of 739 | in a bar a quiet button that joins the phone menu (G1, G8); the theme's accent (G9) |
| `Section` | 2 of 15, 670 of 720 | 6 of 15, 681 of 720 | `compact`, `bleed`, `tint`; a plain Section after a plain one starts half down (G8); outside a Page (G1); the theme's band (G9) |
| `Nav` | 0 of 15, 703 of 1,143 | 4 of 15, 876 of 1,143 | a website's bar (G1), its phone menu (G8), the drawer's button (G8) |
| `Brand` | 3 of 9, 354 of 375 | 3 of 9, 369 of 375 | at the start of a bar: no padding, a 17 px name (G1); the accent (G9) |
| `IconTile` | 0 of 9, 450 of 471 | 0 of 9, 459 of 471 | the code draws a star for an icon written unquoted where the text goes (`IconTile {p.icon}`) and a text child for a bare word (`IconTile t.icon`), the definition reads the icon; `if name` reads a worked-out name at run time; the theme's accent and tile (G9) |
| `App`, `Main`, `Sidebar`, `Pane`, `Page` | 0/15 175, 4/15 545, 2/12 599, 0/18 1,741, 0/9 359 | 0/15 179, 4/15 548, 2/12 599, 0/18 1,741, 0/9 359 | the frame their lines read (G1); the drawer, the window's foot, the rule beside Main (G8); the canvas's height (G10); fills (G9) |
| `H1`, `H2`, `H3`, `Heading` | 3/6, 0/6, 0/6, 0/15 | the same | a text style by frame and level (G1, G9), a website's display size, and H1 marking its section a hero, which the section's buttons read (G8) |
| `NavItem` | 0 of 18 (9 up to spelling), 1,612 of 1,712 | the same | the bar and the rail (G1), the code's spelling of `selected` (and its `_expr` bug), the theme (G9) |
| `Dots` | 3 of 9 | the same | the shapes the code refuses (question 6); the accent and track (G9) |
| `Footer` | 0 of 9 | the same | an app's foot and a website's band (G1), the window's foot (G8) |
| `Table` | 0 of 18 | the same | the n-th line and the columns written out (G8) |
| `Dialog`, `Sheet`, `Drawer`, `Menu`, `Popover`, `Lightbox`, `ConfirmDialog` | 0 of all | the same | a block of its own (G6, the owner's decision: base) |

Three findings shape what moves next:

- **The theme (G9) blocks every page word.** The code reads the design system's accent, line, fills, inks and
  text styles for every page word, `Dots` and `IconTile` included; a definition writes the core's values. The
  closure runs at the core's looks, so it cannot see this, but the corpora's design systems would (Cards'
  `IconTile`, Desk's sidebars). No page word can move until a definition can name a theme value, which this note
  keeps as base (5.1).
- **The page words read each other.** A word moved out of `PageWords` is gone from its frame stack: `SidebarFooter`
  opens a sidebar frame its `Brand` reads, `H1` marks its section a hero for the buttons after it, a `Link` joins its
  bar's phone menu. A move has to keep what the other words read of it, which is G1 and G8.
- **The statement words move first.** `computed` reads neither the theme nor a frame: it closed exactly and moved
  (note 20 section 15). `Shortcut` would follow once the shapes above are read, or once the owner accepts that
  `Shortcut space …` and `onKey=` stop being read (they are corpus shapes).

The proof for `computed` (section 5.2's bar): every use the corpora have, 12 pages (its 4 harvested uses, and the
answer they come from read whole, in its 8 pages) at 1440, 834 and 390, open and closed (72 expansions), gave byte-identical
documents and identical issues before and after the move; the vocabulary record differs only in that each of its
84 uses is recorded as a definition of the dictionary where it was an alias of a line. The SDK's design systems,
examples and tests and the reference examples write no `computed`; the API's tests pass; the notation coverage is
byte-identical (1,356 documents, 30,954 node lines, real gaps 0); print never wrote `computed` (it prints the
`state` line, as before); the four documents that use it render byte-identical PNGs at the three sizes (12
captures).

## 9. With the theme read (G9)

The dictionary reads the theme where the code does (note 20 section 16), and the closure runs each use under Cards'
and Desk's themes as well as the core's looks (`dictionary/themes/`; their themes only, not their components). Per
word, the expansions the same at the core's looks / under Cards / under Desk, before the theme reads and after:

| word | before | after | still differs |
|---|---|---|---|
| Dots | 3/9, 3/9, 0/9 | 3/9, 3/9, 3/9 | the shapes the code refuses (question 6) |
| Brand | 3/9, 3/9, 0/9 | 3/9, 3/9, 1/9 | the bar (G1); under Desk the rail hides its name at a tablet's width (G1) |
| NavSection | 6/9, 6/9, 2/9 | 6/9, 6/9, 2/9 | a label worked out from the state; the rail (G1) |
| Link | 6/12, 0/12, 0/12 | 6/12, 6/12, 6/12 | the bar and its phone menu (G1, G8) |
| Section | 6/15, 0/15, 0/15 | 6/15, 6/15, 6/15 | compact, bleed, tint; plain after plain (G8); outside a Page (G1) |
| Nav | 4/15, 0/15, 0/15 | 4/15, 4/15, 4/15 | a website's bar (G1), its phone menu, the drawer's button (G8) |
| Sidebar | 2/12, 0/12, 0/12 | 2/12, 2/12, 2/12 | outside an App, the rail, the drawer (G1, G8) |
| SidebarFooter | 3/6, 3/6, 0/6 | 3/6, 3/6, 3/6 | a Brand in the foot, a foot outside a sidebar (G1) |
| H2, H3 | 0/6, 1/6, 0/6; 0/6 each | 3/6 under each | an app's heading (G1) |
| H1 | 3/6 each | the same | an app's title (G1); marks its section a hero for the buttons after it (G8) |
| Heading | 0/15 each | the same | the level by frame (G1), the hero (G8) |
| IconTile | 0/9 each | the same | the code's star and text child for an unquoted icon; a worked-out name read at run time |
| NavItem, Main, Pane, App, Page, Footer, Table, Shortcut | | each theme as at the core's looks | as section 8 |
| the overlays | 0 each | the same | G6 |

**No further word closes in every context**, so none moved: what is left is the frame (G1), what other lines read
of a word (G8), the shapes the code reads that a definition does not, and the overlays.

**With G1 built** (and the theme reads), these would close over their uses: `Brand` (its bar meaning, and the rail
read from the sidebar it is in), `H2` and `H3` (their app meaning), and `SidebarFooter` if a definition can also be
the frame its lines read (its Brand). `H1` and `Heading` need G8 besides (the hero mark the section's buttons read),
`NavSection` a way to ask whether a label was written, `Link`, `Nav`, `Section`, `Sidebar`, `Main`, `Pane`, `App`,
`Page`, `Footer` and `NavItem` G8 (the phone menu, the drawer, the window's foot, the rule beside Main, the
plain-after-plain spacing) and, for NavItem, the code's spelling of `selected`. So G1 alone moves three or four words.
