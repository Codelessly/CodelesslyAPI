## Unreleased

### Behaviour changes (read before upgrading)

- **A stand-in with nothing to draw draws nothing** (round 11: 14 of 30 briefs lost a screen to one): a use of a
  primitive declared with no lines, or a word that stands in, written at the top of a page beside its `App` or
  `Page` with nothing under it, is not drawn and the frame stays the root (it was a bar above the app, which lost
  its window); one whose name is a behaviour with no picture (`KeyboardShortcut`, `LiveStatus`, `Clock`,
  `ThemePreference`, `MenuScroll`; the parts are listed in docs/design/20 section 12) and that gives no size and
  no text draws nothing and takes no room anywhere, and with lines under its use it is those lines with no
  labelled box. Everything else keeps its labelled box. The record keeps every use.
- **`Section bleed` with no ground of its own has no padding**: what is in it (a hero picture) meets the bar above
  it; it sat 64 px below on the page's white. A bleed band with a `fill` or a tint keeps its padding.
- **A website's headline is at a display size**: `Heading level=1`, `Text.pageTitle` and `Text.heading1` in a `Page`'s
  Section are 60 px (52 on a tablet, 43 on a phone, by the reflow), `level=2` 36 and `level=3` 22; they were 30, 24
  and 18, a section's title over a 1440 page (round 11: the web's were 48 to 150 px). A theme whose `heading1` or
  `pageTitle` has a size of 32 and up keeps it, a line's own `size=` wins, and an `App`'s titles are as they were.
- **A website's controls are a web page's size**: in a `Page`, a button, a field and a select that write no height
  are 40 px (28 before), their type to match (the renderer's step for 40), a chip 32 (24), the buttons of the
  Section that holds the page's headline (its hero) `size=large` (44), and an `IconButton` in a Section a 40 px square
  in a hairline (a bare glyph before). A theme's `sizes.control` wins; an `App` (Desk's 28 px density) is as it was.
- **A website's ground reaches the foot**: a `Page` is as tall as the window it is shown in (as tall as its content
  in a host that scrolls it: its canvas still hugs), its canvas is its ground (`Page fill=…`), and its `Footer` sits at
  the window's foot on a short page (a `Spacer` before it takes what is left); white showed under short pages. Two
  plain Sections one after the other have one section's space between them (96 px, was 128). An app's `Main` with no
  ground of its own takes its content column's (`Column pad=24 fill=canvas scroll`), so the ground reaches the
  pane's foot.
- **Charts with no look of the theme's are drawn as a designer would**: a `BarChart`'s bars are apart (at most 40
  wide, 8 between) and rounded (4) over a light grid with its figures on the left (written values: a nice top, `0`,
  `10`, `20`…); a `Donut`'s slices and a multi-series line's colors are steps of the theme's primary (they were a
  fixed palette no theme had); a `LineChart`'s axis is fitted to its data (it started at 0 and flattened it).

### Fixed

- **A definition of several lines side by side is read** (it was refused and its uses drew placeholders: round 11's
  admin console lost its sidebar), and **one that starts with an `if` or an `each` is its lines where the use is**,
  as design note 20 has a use stand for its body's lines: the copies an `each` makes are the cells of a `Grid`
  around the use (they were all in one cell) and take the gap of a `Column` around it. A use that gives the root
  words of its own (`#id`, `hide=phone`, `grow`) has a `Column` holding the lines, as before.
- **A Link is in the theme's accent** where the site names its colors: it drew a fixed blue (`#FF2563EB`) on every
  site whatever its primary (round 11: 11 briefs).
- **`Badge.success`, `.warning`, `.info`, `.primary`, `.error` under a theme with no tints of its own** (a site's
  theme) are a tint of the tone's color (the theme's, else SSUI's): they all drew as the neutral grey badge.
- **A theme text style changes only the keys it sets.** A style named as a text variant (`heading1: {fontFamily,
  fontWeight}` in site.json) keeps the variant's size, and a line's `style=serif` over a variant
  (`Text.heading2 "…" style=serif`) keeps the variant's size and ink where the style sets none: it replaced the
  variant (round 11: 12 to 13 px headings and page titles).
- **A box with the widest it gets in a centered column** (`Column maxw=720` under `Column center`) is as wide as its
  place up to that, centered: it hugged its content (a 270 px flashcard in a 1200 px pane).
- **A gauge's figure is sized to its shorter side**: a wide gauge `h=100` drew a 44 px figure over its arc.
- **Texts with widths in a row inside a row that scrolls keep their widths** (`Text "00:15" w=126` cells of a
  timeline's ruler): they were made shares of a row with all the width it asks for, and ran together. This is the
  condition behind round 11's "`w=126` on a Text in a Row becomes a flex weight" (a row of 2 or more such texts
  wider than half the window, under a scrolling row); a row not in a scroll is a table's, its columns shares as before.

## 36.0.0

The notation now writes everything a schema-3 document holds (parity: every corpus document prints back in words),
and takes the fixes found by tests 9 and 10, where standalone writers built 6 and then 116 apps and sites from the
reference alone. With CodelesslySDK 36.0.0 (the renderer, the tools and Desk, a desktop design system).

### Behaviour changes (read before upgrading)

- **A built-in word wins** over a text's own `define` or `primitive` of the same word, with an issue at its line.
- **A formula whose brackets do not match fails the line** (an issue), in every mode; it was kept and read as
  nothing.
- **A components file that cannot be loaded fails the expand** (exit 1), open vocabulary or not.
- **Overlays per page**: an overlay two pages of a site write with one id and draw differently is each page's own
  (`nav--board`); steps, the outline and `print` name it as the page wrote it.
- **Custom paint order**: a node's `painter` is drawn over its own fill and border, under its children.
- **Reflow**: a `Table` is left as written (a column says where it is left out); a Row of copies an `each` repeats
  wraps on a tablet and a phone; an app's window and the writer's own rules are left alone.
- **Chips chosen from show no check mark** unless written (`showCheckmark` defaults to false).
- **Sticky tops**: a table's header and a `…Head` / `Mast` / `Masthead` line stick at 0 (they sat 16 px down).
- **A key the writer wrote wins** over a page word's own; **a bare word on an `Icon` line is the icon's name**
  (a variable is braced: `Icon {glyph}`).
- **Ids may have hyphens** and are read as written (34.0.0 read a hyphen as `_`).
- **A Sidebar made narrow at a width is a rail there** (`Sidebar w=232 tablet.w=72`): an item with an icon shows the
  icon alone, and the section labels and the brand's text are left out (the rows overflowed).
- **A horizontal Flex lays its children out as a row's**; a text beside a Spacer keeps its own width.

### Added

- **Desktop apps in words**: `App`, `Sidebar` (with `Brand`, `NavSection`, `NavItem`, `Footer`), `Main`, `Pane`,
  `Splitter`, `Table`, `NumberInput`, `Dialog` and `Drawer` as a web desktop app draws them; a design system's own
  definition of one comes first; a site's `primary` re-accents them. See `docs/reference/notation/`.
- **The vocabulary record**: every expand records each word written and how it resolved (`notationBuiltInWord`,
  `notationBuiltInDefinition`); a word with no definition stands in as a placeholder and is said.
- **A site's definitions**: a `components/<Name>.txt` that begins with `define` or `primitive` is read by every page.
- **`notationBracketIssues`**, and a quoted text a line ends inside is said (the parser no longer throws).

- **Notation parity** (docs/design/22-notation-parity.md): anything a schema-3 document holds is written in the
  notation's words and `printNotation` prints it back in them. Over the corpus (the reference's examples and
  CodelesslySDK's design systems, examples and fixtures, 1,295 documents) no document prints whole as data (84%
  did), and 60 of 29,789 node lines keep a `{…}` tail, each a field no renderer reads in a schema-3 document or a
  schema-2 spelling the migration rewrites (design 22, section 5).
- **Keys by the catalog and dotted paths.** `key=value` is, in order, a word of the notation, a prop of the type, a
  field of its text style, a layout field, a decoration field (where the type is decorated), a field of the node or
  a behavior: `letterSpacing=0.4`, `squeezable=true`, `maxWidth=720`, `strokeSides=topBottom`, `ignorePointer=true`.
  A nested field is its dotted path (`pan.axis=horizontal`, `style.letterSpacing=0.4`, `fills[0].color=…`,
  `node.tooltip=…`); the full path always reads (`layout.x=10`, `props.style.height=1.2`) and by it a size is that
  size exactly (`layout.height=108`, `layout.width=170`). A value may be JSON (`w={"fill":342}`, `style={…}`).
  `key={expression}` binds any key; `key=null` takes out a field the line gives; `props=null`, `props={}`. A key
  that is none of these is said with the nearest name, never kept as a silent prop. `keys.dart` exports
  `notationKeyPath`, `notationKey`, `notationKeyFor`, `notationKeyNearest`, `notationKeyNames`,
  `notationTextStyleProp`.
- **Events and actions.** Every trigger of the catalog is `on` and its name (`onLongPress`, `onDragEnd`,
  `onEnterViewport`), its fields in parentheses (`onKeyDown(key=Shift+Enter, repeat=true)={…}`); the screen's other
  reactions are `on load={…}`, `on backPressed(when={step > 0})={…}` lines. Every action of the catalog is its type
  and its fields by name (`animate node=hero preset=fadeIn`, `runScript script=check onError={toast "Failed"}`),
  with `enabled`, `nonBlocking`, `when`. A quoted string in a field keeps a `${…}` as written.
- **States.** A node's states are rules with the state's name as the condition: `hovered.fill=accentDeep
  pressed.opacity=0.82 focused.border=focusBorder`, and on a line inside it `btn.selected.color=primaryText`.
  `name=` is the node's name; every behavior is written by its fields (`inkWell.hoverColor=…`, `motion.rotate=90`,
  `drag=card(item.id) draggable.start=auto`).
- **Media rules in words.** `tablet.direction=vertical tablet.gap=16`, `max900.size=40`, `max899.visible={menuOpen}`,
  `minDesktop.visible=true`: any key the line reads at a width (`phone`, `tablet`, `desktop`, `min<px>`, `max<px>`,
  a breakpoint, `portrait`, `landscape`, combined); `Grid cols=4 tablet.cols=2` changes a grid's columns at a width.
- **Records under a line.** A node's custom paint, animations and transitions are lines under it: `customPaint
  viewBox=[320,200]` with an op a line (`circle c=[236,62] radius=28 fill=#FFF4B740`, `group`, `repeat`,
  `foregroundPainter`), `animation#enter duration=520` with its `track path=opacity from=0 to=1` lines, `transition
  property=opacity duration=200`.
- **The document line.** `document id="checkout" schema=2 scope=page_variables conditions={…}`: the document's own
  id, schema, the scope its state lines are kept in and its conditions. `state count:decimal=2`, `state
  total:decimal={price*qty}`, `state clamp(v):decimal={…}` for a type the value does not say, a formula variable and
  a function; `canvas "Trip" path="/trip" h=844 fill=paper`, `canvas none`; `Canvas#about "About"` blocks for other
  canvases; `slot title` lines under a node; a `ListView`/`GridView`/`PageView` line with an `each` under it repeats
  its one child.
- **Components.** A design system's component document prints as `component StatusPill "…"` with `param`, `event`,
  `slot` and `preview` lines and its tree. A component a word of the notation shadows is `Button "Save"
  type=Button`, with its own events, marks and slots. `Pages` prints for a page view of pages.
- **printNotation and the coverage tool.** `printNotation(document, catalog:)` writes any document as notation that
  reads back (with `notationOptionsFor(document)`) to exactly that document: words where they read back, else a
  `{…}` tail or a `document {…}` line. Overlays print as their heads (`Dialog#confirm "Delete file?"`, opened with
  `open confirm`). `tool/notation_coverage.dart <dir>... --components --out <dir>` measures a corpus: what is said
  how, what stays in a tail and why, and the real gaps.
- **The notation reference** (`docs/reference/notation/`, `dart run tool/reference/generate.dart --notation`): a
  page per family of the notation with every word and an example that expands and prints back, generated from the
  catalog; `_tails.md` lists what an example still prints as JSON (nothing now).

### Changed

- **Notation**: a built-in word wins. A text's `define` or `primitive` of a word the notation already has (a type of
  the notation or the catalog, a page word, a name the alias table reads as one of those: `Card`, `Rail`,
  `Shortcut`) is not used, and is an issue at its line saying what the notation has (`notationBuiltInWord`). Before,
  one of a core word was ignored with no word, and one of an alias won over the alias (`primitive Shortcut` made every
  shortcut a labelled box). A design system's component may still be replaced by a page's own definition.
- **Notation**: a formula whose brackets do not match is an issue of its line, open vocabulary or not, wherever it
  is written (an `each` list, an `if` condition, a `state` value, a `{…}` value or action, a text's `{…}`): a `)` or
  `]` that closes nothing (saying where the formula ends and what is not read), one that closes the other kind, and
  a `(` or `[` the line never closes (`notationBracketIssues`). Before, the formula was kept as written and the engine
  read nothing from it, with no word: test 10's kanban board wrote one `)` too many in its list and drew no cards.
- **Notation**: an id may have hyphens (the owner's decision: ids are written as JSON and HTML ids are). An id is
  letters, digits and `_`, its parts joined by single hyphens (`Text#m-title`, `Dialog#live-image`, `hero-cta-2`),
  read as written, with no issue, after `#`, after `open`, `scroll` and `focus`, and as the owner before a state
  (`m-nav.selected.color=…`). A variable named after a node (`<id>Selected`, `<id>_<param>`, a Lightbox's
  `<id>At`) takes the id's hyphens as `_`. `printNotation` writes such ids, so a document with them prints in
  lines, not whole on the `document {…}` line. (34.0.0 said a hyphen in an id and read it as `_`.)
- **Notation**: a bare word where an icon's name goes is that name: `Icon download`, and `icon=inbox` on a NavItem,
  MenuItem or Brand (whose Icon line was refused with `Unknown word "inbox" on a Icon`), whatever a variable is
  called, as `icon=` already was on a Button; an icon chosen by data is braced (test 10: 49 runs, the largest
  source of first-expand issues).
- **Notation**: a key the writer wrote wins over a page word's own (`Sidebar … h=fill`, `Table … radius=0
  border=rule w=1030`): the word's is left out, with no issue. Before, each was "written twice" though written once
  (test 10: 36 runs). A key written twice by the writer is still said.
- **Custom paint**: a node's `painter` is drawn over the node's own fill and border and under its children (the
  renderer, CodelesslySDK). Before, a filled node hid its painter whole, silently (test 10: 38 runs; 19 showcase
  documents drew only their fills). A `foregroundPainter` line may stand under the node beside `customPaint`.
- **Notation**: several `onKeyDown(key=…)` on one line are several reactions, with no issue (only the same key
  twice is said); `Avatar … initials="MR"` (or `initials={p.ini}`) shows those letters, and a one-word name read from
  the state keeps two letters; a state named `item` read inside an `each` (where `item` is the copy) is said; `App`
  below a page's header (or in a component) is a region of panes (`Row` of Sidebar, Main that scrolls, Pane) where
  it was "No node type"; `NavSection` is a section label outside a Sidebar too.
- **Notation**: a call of a component whose slot is `children` takes the lines under it as its children (what the
  slot shows); before, they went in a row in `slots.children` and showed nothing (test 10: two single-write sites
  lost their page bodies).
- **Notation reflow**: a Row of copies an `each` repeats wraps them on a tablet and a phone (media rules on its list
  and its item), on a page and in a narrow overlay over it (a dialog); before, the copies were one child to the
  reflow and overflowed (test 10: 29 runs). A page written for a phone is as written; `Row scroll` and `keep` are
  left as they are.
- **Notation, words writers expected** (test 10's vocabulary): `Image url="…"` (and `url={…}`, `src=`) is the
  picture; `Input prefixIcon="search"` is `icon=`; `RangeSlider @low end=@high` is `Slider @low @high`; a Grid's
  `crossAxisCount`, `crossAxisSpacing`, `mainAxisSpacing`, `mainAxisExtent` and `childAspectRatio` are its `cols`,
  `gap`, a cell's height and its aspect; `setThemeMode dark` and `setThemeMode {expr}`; `key +` and `key mod++`;
  `ListView reorder handle` (a bare `reorder` on a ListView was `true`, no reorder record: the list did not reorder,
  silently). Each alias is recorded as one in the vocabulary.
- **Widgets**: `semanticLabel` on `checkbox`, `switch`, `radio` and `slider`: the name a screen reader says, not
  shown (`textField` had it).
- **Notation parity**: a `Canvas#id` block's `blockBack={expr}` (and `guard={…}`) is bound, where the braces were
  kept as a literal string (test 10, kanban 4); `printNotation` writes a canvas's bound props as `key={expr}` on its
  line and its own reactions as `on …` lines under the block, and a design system's `Dialog` called in a canvas with
  its event (`onClose={close}`), where each was on the `document {…}` line or a `{…}` tail. Over the corpus (1,341
  documents) the real gaps are 0 (they were 4 node lines and 1 document line, all Desk's dialogs).
- **Notation**: `cond ? actions` with no else is a choice that does nothing when it does not hold (it was "Unknown
  action"); an `each` line takes `handle` (`each c in cats reorder handle`); a paint op's record field takes dotted
  keys (`paragraph … style.color=… style.fontSize=10`); a sticky line whose word ends in `Head`, `Mast` or `Masthead`
  (a site's top bar) sticks at 0, as a `Nav` does (it was 16 px below the top).
- **SiteManifest.pageRefs**: a manifest's `pages` may be records (`{"id": "home", "file": "home.json"}`); a reference
  page for `site.json` (`docs/reference/notation/site.md`).

## 35.0.0

Released with codelessly_sdk 35.0.0.

### Changed

- **Notation**: `NotationOptions.fromTheme`/`fromDesignSystem` take `nearestColors` (default false); with `named`
  a color the notation writes now stays as written unless `nearestColors: true` (before, `named` also read it as
  the theme's nearest color).

### Removed

- **The strict validator** (`package:codelessly_api/validate.dart`: `validateDocument`, `validateProject`,
  `strictEditCheck`, `Codes` and the rest of the library) is gone. `applyOps` checks ops with `catalogCheck`, as
  before by default; the reference no longer has the validation codes table, and `catalog.json` no `diagnostics`.

## 34.0.0

Released with codelessly_sdk 34.0.0.

### Breaking

- **Notation**: a variable is bound with `@` (design note 13, section 3.1). `@name` is the variable itself, read
  and written: bare on a line it is the control's value (`Slider @heat min=14 max=24`, `value=@heat` the same), any
  other property is named (`selected=@picked` on a selectable list, `direction=@dir` on a block, `low=@a high=@b`
  on a slider with two thumbs, written bare as `@a @b`). One bare mark a line, two on a range; a mark on a line that
  binds nothing, or a second one, is an issue that says what the line binds. A bound variable is declared (a
  `state` line, a site's variable, a loop's item, a definition's parameter): one nothing declares is an issue that
  gives the `state` line to add. `bind=`, `bind={…}`, `bindEnd=` are not read: each line that writes them is one
  issue that shows it in the new form (`notationBindForm`, `notationBindRewrite`). A block's variable parameter is
  always `key=@name`. A definition's signature declares the value a use binds as `@value` (`@value=1` with its
  start) and a further one as `name=@` (`name=@0.5` with its start); a use binds them with `@x`, `value=@x`, `name=@x`; a plain parameter a use
  binds (`value=1`, `Counter @n`) is that variable both ways. The prompts, the printer (`@name` on a control) and
  the A2UI front end write the new form. The `RangeSlider` alias takes `@low @high` or `low=@ high=@`; its other
  names for the ends are gone. CodelesslySDK's `tool/notation/notation.sh migrate` rewrites files.
  `notationBindRewrite` rewrites only what 33 read as a binding (a value in braces on any key but `bind=` is left:
  it was shown, one way), lists only the variables it turned into `@name`, and leaves a binding of a name no state
  line can declare (`notationRefusedState`: `theme`, `device`…) as written, in its `refused`.

### Added

- **Notation**: `confirm "Delete 2 clips?" "They cannot be restored." ok="Delete" cancel="Keep" danger then {…} else
  {…}`: a detail under the question, the buttons' words, a destructive yes, and what a no runs.
- **Notation**: `key j when={!editing} onPress={…}` acts only while its condition holds; a `key` line under a
  `Dialog#id` is that dialog's. Key names are the keyboard's or the plain ones (`left`, `del`, `pgup`); a name no key
  has is an issue. `Button "B" shortcut="mod+b"` presses the button.
- **Notation**: a menu opened from a row (`menu=rowMenu` under an `each`) reads the pressed row by its loop name;
  the row's own `onLongPress` or `onRightClick` runs first, wherever it is written.
- **Notation**: `fuzzy(list, q, x=>x.name, 3, "keep")` takes how many letters off a word may be and keeps the list's
  order; letters typed across words match (`adamens` finds "Ada Mensah").
- **Notation**: `Calendar @day` is one day (`range: false` on the calendar's props; `@a @b` is a range), and
  `marks` takes a list of days or of `{date, label}` records.
- **Notation**: `guardText="Discard changes?" onDiscard={…}` on a guarded `Dialog` or `Sheet` asks before closing;
  `each m in msgs follow grow` takes the room over a composer.
- **Notation**: a definition's `primitive Word …` declares what no line can express (counted as a stand-in, never as
  resolved); `definitionReads` reports a parameter or an event a definition names and never uses, and a variable
  it reads that is not its own.
- **Notation**: an alias carries a variant and fixed parameters (`{"to": "Button.primary", "add": "size=large"}`)
  and maps the first string to a parameter (`$text`); a page's own `define` replaces a design system's component
  of that name; `description`/`detail`/`note` and `placeholder`/`hint` are read for one another where a word has
  exactly one of them.
- **Notation**: the open prompt's glossary prints each word's signature (`notationGlossaryLines`); names alone
  with `signatures: false`.

### Changed

- **Notation**: a bare `go name` that names a screen is that screen, whatever variable shares the name
  (`NotationOptions.screens`, `notationScreen`); `go {expr}` is worked out.
- **Notation**: an id is one word of letters, digits and `_`: a hyphen is one issue at the id, which is read with
  `_` there and where it is opened.
- **Notation**: a whole-number state becomes a decimal once an action may give it a fraction (`zoom=zoom*1.25`) or
  a slider that writes fractions is bound to it; one bound to a slider between whole numbers stays whole.
- **Notation**: `state` lines and overlays written before the first `###` belong to every screen; a state named
  after a runtime scope (`theme`, `route`, `drag`…) is an issue; a key written twice on a line is an issue.
- **Notation**: `selectable` on a list whose rows take a tap of their own (a `TableRow`, a card with `onTap`)
  chooses the row first; on a line with no `each` under it it is an issue. `removable` and `action=` are read on
  a block with a slot; `disabled={cond}` on a block whose `disabled` is a list turns the whole block off.
- **Notation**: in a definition, a use's variable reaches the controls in its lines, a loop's item reaches
  `drag=group(item.id)`, an event forwards with its arguments, a body that starts with `if` or `each` is put in a
  Column, and an id written in the lines is the instance's in its actions.

### Fixed

- **Notation**: an `each` in a wrapping row had no width (a `ColorPicker` drew nothing); `Grid cols={n}` read a
  computed number as 2; a row that holds a reorder `Handle` wrapped it onto its own line on a phone.

## 33.1.1

Released with codelessly_sdk 33.1.1.

### Changed

- **Notation**: the buttons a `Dialog` or a `Sheet` ends with are its actions. On a phone they fill its width in
  equal shares; with room they sit at its right, each no wider than 240. Written as a row of buttons, or as
  buttons one under another (then they are put in one row). A row that says where its buttons go (`between`,
  `center`) keeps that with room.
- **Notation**: a list beside its detail shows one pane at a time on a phone (design note 13, section 14.4). An
  `App`'s `Pane` before `Main`, or a column of a fixed width beside one that grows in a `Row` (a `Splitter`
  between them goes), whose rows select what the other side shows (a tap under an `each` that sets a value from
  the row's item: `onTap={sel=m.id}`) is the list; a `Pane` before it whose rows choose what it lists is a level
  too (folders, messages, a message). The expander adds the state `<screen>_pane` (starting at the list), media
  rules that show the level it holds and fill the screen with it, the step to the next level after each
  selecting tap's own actions (Enter and Space run it too), a back button at the top left of each later level
  (in `Main`'s `Nav`, else in a row of its own), the sidebar's drawer button on each pane of an app, Escape and
  the system back (`backPressed`, a bound `blockBack`), and a fade (and the detail's slide) as a pane shows. A
  tablet keeps the panes side by side where they fit at their least; at the width the page was written for,
  nothing changes. A tap that only opens a menu, ticks a box or toggles a star does not count, and a pane
  written `hide=phone` or `show=…` is left as written.
- **Notation prompt**: the page prompt's "Tablets and phones" paragraph says that a list beside its detail shows
  one at a time on a phone, with a back button, and that its rows are an `each` whose tap selects
  (`onTap={sel=m.id}`).

## 33.1.0

Released with codelessly_sdk 33.1.0.

### Added

- **A component's word may take a second meaning from a definition** (docs/design/20-defined-words.md section 5;
  the vocabulary loop's Review 5, D25): a definition named `Stepper#steps` gives Cards' `Stepper` (the number
  control) the steps indicator the answers also meant by it. The component is the word's first meaning, scored like
  a definition whose signature is its props and events; a use is read as a named meaning only when it fits it
  better (a tie is the component). An unnamed definition of a component's word is still not read.
  `DefinedWords(component: …)`, `DefinedWords.meanings(word)`.
- **The open prompt names a design system's words: the glossary** (docs/design/19-open-vocabulary.md section 2;
  the vocabulary loop's Review 6, D29): `notationPrompt(open: true, designSystem: …)` adds, after the paragraph
  asking for definitions, one line with the names of the design system's components and defined words the
  prompt does not already teach, sorted, with no parameters, and the instruction to use a listed word as one would
  expect and define only what is in neither list (`notationGlossaryLead`, `notationGlossary`). Without a design
  system there is none; `glossary: false` leaves it out.
- **A board keeps its columns on a phone** (docs/design/13-compact-notation.md section 14; the vocabulary loop's
  Review 5, D26): a grid of one repeated cell, written on a page or in a defined word's lines, keeps its columns
  when the cell is a small key from three columns on (a keypad of 3 by 4 was one column on a phone) or, from five,
  a small cell or a square of at most 64 with no card or component in it (a crossword's 13 columns became two).
  The node the notation wraps each copy of an `each` in no longer counts against a small cell. A `Grid` takes up
  to 24 columns (it was 12: a 13 by 13 crossword had 12).
- **The shapes answers gave words we have, read** (the vocabulary loop's Review 6, D30): `Text strike=true` is
  the flag, `strike={done}` a line through the text while it holds (16 lines in the corpora; `underline=` the
  same); `Barcode "29034 00718 4421"` encodes its string (it was an issue), as bars by default (`code128`; a QR code
  is `symbology=qrCode`), 80 high when no height is given (160 square for a two-dimensional code); `value=`,
  `code=`, `format=` and `type=` are its `data` and `symbology`; `QRCode` is a `Barcode` as a QR code. A design
  system component's variant that is a value of one of its choices is that value: `Banner.warning` is `Banner
  tone=warning`.
- **A defined word used as the first corpus wrote it** (Review 5, D25): a use's `bind=x` of a variable the page
  never declared declares it with the word's default (it was left undeclared: `SignaturePad bind=signature`
  did not validate); a record written as JSON given to a parameter (`center={"lat":44.9,"lng":-93.1}`) is that
  record in the body's expressions (it was read as an expression in braces, and did not parse).
- **The alias table reaches a defined word**: a word's own entries in `parameters`, `events` and `flags`
  (`"Timeline": {"events": "items"}`) are read as the names its definitions take, before its meaning is chosen; a
  name one of its meanings takes is its own. Recorded as aliases.
- **A definition anywhere in a text holds for the whole text** (docs/design/20-defined-words.md section 7; the
  vocabulary loop's Review 4, D20): `define Word …` may come after its uses (models write their definitions after
  the last screen); `parseNotation` reads them all before the first line, the overlays after the page included. A
  `//` line directly above is its purpose. A page's own definition of a word the design system defines wins on
  that page, and the use's record says so (`VocabularyUse.of`: `page, over StickyNote.txt`).
  `parseNotation(…, definitions: text)` takes the definitions of more text (an answer's other screens);
  `readPageDefinitions(text)` reads them. `NotationStream` reads a definition from where it is written on, and
  says so when a use came before it.
- **The open prompt asks for every invented word to be defined** (the vocabulary loop's Review 4, D19):
  `notationPrompt(open: true)` carries a paragraph and three examples (`notationDefinePreface`) asking the model to
  define each word it uses that is not taught, after its last screen, in the notation itself. Each example is read,
  expands with its defaults and validates (a test). `define: false` gives the open prompt as the first corpus was
  written with. 19,804 characters for a page (18,388 without), 10,508 for a card (9,092); the taught prompts are
  unchanged.
- **What self-defining answers wrote, read** (Review 4, D21), open or closed:
  - an expression where the text or the icon goes is that value: `Icon {playing ? "pause" : "play_arrow"}`,
    `IconButton {…}`, `Text {…}`, as `"{…}"` would be (a JSON object there is still the tail it was); on a defined
    word, its first string (`Pill {status}`);
  - a Badge's tone worked out from the state: `Badge "Pass" variant={ok ? "success" : "error"}`, and `Badge.{…}`,
    bind its fill, hairline and ink;
  - a drag value written as a string or a record, `drag=part("battery")`, `drag=meal({"rid":r.id})`, and a group in
    quotes, `drag="battery"`;
  - `hide={cond}` and `show={cond}` are `visible` (`hide` the opposite); `hide=phone` and `show=tablet` are still the
    sizes. Models wrote them 26 times in the two corpora; until now `show={…}` was an error on purpose;
  - a definition whose body is `if cond` over its one node is that node shown while `cond` holds; state lines before
    the root are, as before, the word's own state.
- **What got in the definer's way** (Review 3, D16; the Sonnet agent that wrote thirty definitions named them):
  - a text in a block of a given height (`Column h=200 fill=…`, `Box w=28 h=28 radius=14` with a number in it) keeps
    that height: `{"hug": h}` gains `constraints.minHeight: h` (it still grows when the text takes more lines, as its
    comment always said). The hug value alone is a fallback, so such a block was drawn at its text's height. 131
    nodes of 19 example files change this way (in the ten showcase pages: site_docs's three step circles);
  - `Row gap=8 wrap` over an `each` wraps its copies (the list gets `wrap`, `wrapSpacing`, `runSpacing`);
  - `Word#{tr.id}` and `Word#lane-{tr.id}` on a defined word: an id from data is its fixed part, as on any line;
  - a path (`end=draft.end`) or a variable of the page (`bpm=bpm`) given to a definition's plain parameter is the
    value it reads, not the text "draft.end";
  - `every {60000/bpm} onTick={…}`: a timer whose interval is worked out (`intervalMs` a formula);
  - `each it in items reorder` in a definition, given a list worked out (`items={filter(…)}`): shown in order, with
    no variable to write the order to, instead of an issue;
  - a border's width and colour: `border=2` (the theme's line, 2 wide), `border="#FF2563EB 2"`, `border=2
    borderColor=…`, `border={on ? 2 : 0}` (a width worked out), and `border-width`, `borderWidth`, `strokeWidth`,
    `border-color`, `borderColor`, `strokeColor`, `stroke`. `border=2` wrote the number as a colour;
  - an Input's typed text styled: `font`, `fontFamily`, `fontSize`, `weight`, `fontWeight`, `letterSpacing`,
    `lineHeight`;
  - a choice between actions already took a use's events, given or not (`ok ? onOk : onError`): now tested.
- **An `open` of an overlay that was never written** (Review 3, D17; a third of the first corpus's grammar issues,
  256 of 766): with the open vocabulary it opens a quiet placeholder sheet titled with the id (`open addRecipe`: a
  Sheet "Add recipe" that says "Not written yet.") and is recorded as a wanted overlay (`VocabularyUse` kind
  `overlay`, its line the first `open`), not an issue. With the vocabulary closed nothing is made, as before. An id
  with a hyphen is not an overlay's, so `open add-recipe` is still the issue it was.
- The drawer an app's sidebar becomes on a narrow window, and a gallery's viewer, take the screen's id with its
  hyphens as underscores (`decks_and_mixer_sidebar`): a screen id with a hyphen gave an id no overlay can have, and
  the menu button's `open` was left out.
- A line read a second time (an overlay's foot, an app sidebar's copy in its drawer) no longer says its issues again.

- **Universal words** (docs/design/21-universal-words.md; the vocabulary loop's Review 2, D6 and D7): a parameter, flag
  or event that means the same on every line, in one table (`notationUniversal`, `universal.dart`: the grammar's own
  words and the new ones) and read once where a line is read, so core types, a design system's components (where the
  component has no word of that name) and defined words (without naming it) all have them. `color` is a text's or an
  icon's ink, a control's accent (a toggle's track, a slider's track and thumb, a radio's fill, a choice chip's
  selected tint), a plain chip's or a field's ink, a filled button's fill (its label's colour when the line gives a
  `fill=`), and on a container the ink of the texts and icons written in it that set none (nearer wins); `size=xs|
  small|medium|large|xl` is a step of the theme's scale on a text (caption, small, body, title), an icon, a Ring, an
  Avatar, a bar, a slider, a chip and a field (a number on an Input is its text's size); `icon=` is a chip's avatar
  and a ListTile's leading icon; `disabled` (`enabled={!…}`) on a line with no `enabled` of its own is its `disabled`
  binding (a box: `states.disabled` with no pointer and half strength); `readonly` on a control with no read-only of
  its own takes no input (`ignorePointer`); `required` marks a field's, a checkbox's or a toggle's label and makes an
  Input check it is not empty (`validator`, `autovalidateMode: onUnfocus`); a tooltip that reads data is the node's
  own on any line. On the line over an `each`: `reorder` (`sortable`, `reorderable`) reorders that list (by a long
  press, or its Handle with `handle`), `onReorder` has `result` the new order; `selectable` with `bind=list` and
  `onSelect` keeps a selection (a tap alone, Ctrl or Cmd adds, Shift a range, Space and Enter likewise, Ctrl or Cmd A
  all, the rows a focus group, each row selected and announced); `removable` with `onRemove` (`onDelete`) makes a
  chip an input chip and puts a Remove x at the end of a box. With the open vocabulary each use is recorded (kind
  `universal`, `of` its kind); a stand-in's words it honours are recorded so (D6), what it leaves out stays in its
  record.
- **Input's words** (docs/design/21 section 7, D8): `clearable` (a x that clears it), `maxlength`/`maxChars`
  (`maxLength`, the field taller for its counter), `caps` and `caps=words|sentences`, `autogrow`, `rows=` (`lines=`),
  `center` and `right`, `value=` beside `bind=`, `prefix=` and `suffix=` (always shown), `onEnter` (`onSubmit`),
  `onSaved` (`onBlur`), `onKeyDown` (a key in the field, `key` read as `result.key`); `fuzzy` on an Input is a
  recorded no-op with an issue that says fuzzy matching belongs to the filtered list. `Calendar onSelect` is
  `onChange`.
- **A bare number where the text goes** (D9): `Badge 3`, `Text 2026`, `CountUp 39` (a stand-in), a component's first
  text parameter (or its numeric `value`), before any key=value on the line; on a defined word the next string of
  its signature, else its parameter `value` (the number itself in the body's expressions), which closes note 20's
  grammar gap. A number after a key, and a bare word naming a value (`Text plan.name`), are what they were.
- **Words defined in the notation itself** (docs/design/20-defined-words.md): a word's signature (its strings,
  parameters with defaults, flags, `bind=name`, events) and the lines it stands for, written in the notation's own
  grammar, one file per word (`StickyNote.txt`) or `define Word …` in a page. A use is written out as those lines
  before it is read (a macro): the use's values where the body reads them by name in braces, its words of every
  line (`w`, `grow`, `visible`, `onTap`…) on the body's first line, its lines where the body has `...` (or
  `...Front` for the lines under a `Front` line; `... each reorder` adds `reorder` to an `each` in the slot), the
  body's state, loop items and ids made the use's own, its events where the body names them (`onPick(c)`: with
  `result` as `c`). One word may have several meanings (`Timeline#tracks`, `Timeline.vertical#route`): a use is read
  with the one that fits what it gives. A word that uses itself is refused. A core type, a catalog type, a page
  word or a component is never a definition's. Open or closed, a defined word is a word we have; each use is
  recorded (`VocabularyUse` kind `definition`, `to` the meaning, `node` its root id); what it gives that the
  definition does not take is recorded with the vocabulary open, an issue without. A definition's own errors are
  said against its file and line.
  - `NotationOptions.define(texts)`, `NotationVocabulary.define(texts)` and `.definitions`; `readDefinitions`,
    `checkDefinitions` (each definition expanded with its defaults, with an optional document validator),
    `definitionLines` (the signatures, for a taught prompt), `NotationDefinition`, `DefinedWords`.
- **A stand-in with nothing to draw shows what is missing**: with the open vocabulary, an unknown word with no text,
  no lines under it and no fill or border of its own is a quiet dashed box with its word (and its first string
  value), at least 40 high or as big as its `w` and `h` say, in the theme's line and caption colours. A page with a
  word we lack reads as unfinished, not broken. Nothing else changes; with the vocabulary closed nothing stands in.

## 33.0.0

Released with codelessly_sdk 33.0.0.

### Breaking

- **The compact notation has a new grammar, and reads only it** (docs/design/17-notation-grammar-audit.md).
  Everything after a node's text is `key=value`; a value worked out from the state is in braces, as inside a
  text; a control's variable is `bind=name`; what a node does is an event with its actions in braces, and there
  is no arrow.

  | Before (to 32.x) | Now |
  |---|---|
  | `Column gap:12 pad:16` | `Column gap=12 pad=16` |
  | `Input "Email" =email` | `Input "Email" bind=email` |
  | `selected:=tab=="a"`, `enabled:count > 0` | `selected={tab=="a"}`, `enabled={count > 0}` |
  | `Button "Save" -> saved=true; toast "Saved"` | `Button "Save" onTap={saved=true; toast "Saved"}` |
  | `Slider =volume -> emit volume result` | `Slider bind=volume onChange={emit volume result}` |
  | `SiteNav … -> go lower(result)` with `onCta: go signup` on a line under it | `SiteNav … onNavigate={go {lower(result)}} onCta={go signup}` |
  | `swipe:left -> …`, `drop:todo -> …`, `every 1s -> …` | `onSwipeLeft={…}`, `drop=todo onDrop={…}`, `every 1s onTick={…}` |
  | `show:menuOpen` | `visible={menuOpen}` (`show=phone` is a size) |
  | `Heading "Why" #why`, `id:why` | `Heading "Why" id=why` |

  It is a hard break: the old spellings are not read, and each is an error on its line that says what to write
  (`A value is written with =, not a colon: gap=12.`, `There is no arrow. What a node does is an event with its
  actions in braces: onTap={…}`). Also no longer read: an expression with no braces after a key or where the text
  goes, a declared variable written bare after a key (said, with `key={name}`), a list holding expressions with
  no braces, a block's enumerated value as a bare word, `tap:` / `press:` / `click:` / `change:` as events, an
  event's actions in quotes, `value` for `result`, `List =rows`. Still read, though not taught: `let`, a bare
  `name = value` line, `for x in`, `each list`, `else`, `+=`, `++`, `.add()`, `if (c) {…}` in actions, `$name`,
  single quotes, `sticky=true`, `onPressed` / `onClick` / `onChanged` for `onTap` / `onChange`, `onTap` on a block
  for its first event.

  **To migrate a file: `tool/notation/notation.sh migrate <file.txt> --design-system <folder>` in CodelesslySDK**
  (a one-off tool outside this package; docs/design/18-notation-grammar-migration.md is the note to hand to
  whoever has files). Every notation file of the SDK and every page of the twenty sites expands, rewritten, to the
  document it expanded to before.
- New on a plain node: `onHover`, `onFocus`, `onBlur`, `onSubmit` (the engine's `cursorEnter`, `focusGained`,
  `focusLost`, `submitted`); an `on…` it does not have is an error that lists the events. `id=name` on a line is
  an anchor. A plain node's unknown `on…` used to run on its tap or change.
- `notationPrompt` teaches the new grammar: 8,979 characters for a card (8,913 before), 17,736 for a page
  (17,644). A design system's component line lists its events by name (`Stepper "label" bind=value min max
  onChanged : …`). The printer writes `gap=12`, and the A2UI front end the new grammar.

### Added

- **The notation: a choice between actions.** Inside an event, `cond ? action(s) : action(s)` is an `if` action
  (`onTap={dirty ? open leave : go members}`, `onChanged={…; pendingRemove=="" ? close : open removeConfirm}`);
  each branch is one action or a braced list, either may be empty (`done ? close :`), and a branch may choose
  again. `if (c) { … } else { … }` in actions, read before as assignments guarded one by one (its other actions
  ran unguarded), is now the same `if` action. A value chosen (`step = valid ? 3 : 2`) is still a formula. The
  card prompt teaches it in one clause in place of "an action is never a condition".
- **The notation: binding to a field.** `bind=draft.title` on a control writes the field of the record variable
  (`draft = with(draft,"title",result)`); under an `each`, `bind=s.done` writes the element back also when its
  list is a field of the element around it (`each s in e.sets`), and when the list is worked out
  (`each d in filter(devices, …)`) and its records have an `id`. A design system's block (ToggleRow, NumberInput,
  TextArea…) takes the same: its variable parameter is given the field's path (`draft.title`,
  `"rows[" + index + "].done"`), where it said `A NumberInput keeps its value in a variable: write bind=name.`
  What cannot be written (a list worked out without ids, a record that is not declared) says what to write.
  The same holds for an action that sets a field where it stands (`d.pos=0` under an each over a list worked
  out, `draft.title=""`), and a control reads and writes `bind=colAll[r]` (an entry of a list or a map
  variable) and `bind=find(clips,c=>c.id==sel).name` (a field of the record a find picks).
- **The notation: lines under a block that takes none.** Under a design system's block with a slot and no
  children (`ListRow`'s trailing, `SectionHeader`, `PaneToolbar`, `EmptyState`'s actions) the indented lines go in
  the slot, side by side; the component's prompt line says `(lines: actions)`. Under one with neither, the line
  is an issue that says so and is drawn after it (the renderer reported `children_not_allowed` and the expander
  nothing). A line indented two levels past the one before it inside an overlay (a page's Card written after
  the overlays) says it went into that overlay.
- **The notation: ids.** The drawer an `App` makes of its sidebar on a tablet or phone is `<screen>_sidebar` (was
  `<screen>Menu`, which took `Menu#albumMenu` from the author on the album page, `Dialog#deckMenu` on deck…). An id
  given twice names the line that has it (`The id "save" is used twice: line 8 has it too.`); in the two branches
  of an `if`/`else` it says why a document cannot hold both and what to write; an overlay with the page's own id
  says to give it one of its own. An id written from the data (`Row#row-{row.id}`) is its fixed part (`row`): a
  node has one id however many copies an `each` makes of it.
- **A component's own variables reserve none of a site's names.** `validateProject` reported a project variable
  (site.json) named like a variable inside a design system's definition (`selected` in Cards' CommandPalette,
  `query` in its Combobox) as `duplicate_variable`, in sites that never used the component. A definition's
  variables are its instance's; only a page's are checked against the project's.
- **The notation: lines that were accepted and did nothing.** `project cart=[]` on a page expanded alone declares
  `cart` on the page (it declared nothing, and every read of it failed at render); beside site.json it is the
  site's as before, and a name the site's variables lack is said. `go result`, `go tab`, `go item.slug` (a name
  the state has) navigate to the page the value holds, as `go {result}` (`Tabs … onChanged={go result}` went to
  a page called "result"). With an open vocabulary, an `open` of no overlay of the page names the ones it has.
  `clip.length` of a record with a `length` field is the field, not the record's size. `state clips=[…]
  saved=true` (or `persist=true`) is the saved flag, where it was read into the value as text.
- **The notation infers a variable's kind from the state declared.** A variable an action makes takes the kind of
  what it reads (`x=c.start` under an each over clips whose `start` is a number is a decimal, `completed=c.done` a
  list), where it was text and the renderer said `wrong_type`; one that cannot be known takes the kind of a
  control bound to it later (a `NumberInput`, a `Slider`). A design system's parameter that is a list of texts
  given numbers (`ChoiceChips options=[1,2,3]`, `Tree depths=[0,1]`) takes them as texts.
- **A Grid whose columns mean something keeps them on a tablet and a phone.** `Grid cols=7` (a month, a streak,
  a timetable), a grid of five or more small cells (at most three nodes, no card or component), and a grid
  written `keep` (`Grid cols=4 keep`) keep their columns and shrink their cells, where a phone made two columns
  (a month became a 15-row list). Other grids wrap as before.
- **A bar pinned to the foot of an app window.** `Footer` as `Main`'s last line (or in `App`, or `Row sticky
  bottom`) is a bar at the bottom of `Main` that stays in view at every width while what is above it scrolls
  (a now-playing bar, a chat composer, a basket, sheet tabs); before, a Card written last in `Main` scrolled
  away. The alias table reads `StickyBar`, `StickyFooter`, `BottomBar`, `FooterBar` and `BottomDock` as it. The
  page prompt teaches it in one line, and that a Grid of 7 columns or written `keep` keeps them.
- **The notation: `selected`, `size`, `focus` and `copy`.** `selected={…}` on a line whose type has no selected
  value (a `Row` of a list, an `IconButton`, a `Button`) is the node's selected state (`bind.selected`); a row,
  column or box is drawn in the theme's selected fill while it holds. `size=small|medium|large` on an `IconButton`
  is its icon's size (a Button's was read already). Actions `focus search` (the caret in that field), `blur`, and
  `copy link` / `copy "{link}"` (to the clipboard, with a toast); the page prompt names them.
- **An open vocabulary for the notation** (docs/design/19-open-vocabulary.md): the prompt teaches the grammar and
  a small core, the model writes any word it expects, and the parser records the ones we do not have.
  - `NotationOptions.openVocabulary` (false by default: nothing changes without it). With it, an unknown type is
    not an error: it stands in as a column of its strings and of the lines under it, with its id, its layout words,
    `visible`, and what a pointer does to it; at the margin after the page, with an id, it stands in as a Dialog.
    An unknown parameter, flag, event, action verb or variant, and a value of another kind than a parameter takes,
    are left out of the document. A component called without something it needs is given an empty value; lines
    under a word that takes none are drawn after it; an `open` of nothing over the page and a `scroll` to no line
    of it are left out, with an issue. The grammar is not open: what does not follow it is still an issue.
  - `NotationResult.vocabulary` (and `NotationStream.vocabulary`): a `VocabularyUse` for each such word, with its
    kind (`type`, `parameter`, `flag`, `event`, `verb`, `variant`, `missing`, `children`, `alias`), the word, the
    type it is on, its value as written, the whole line, line and column, the words it is under, and for a type its
    strings, parameters, flags, events and the first words of the lines under it.
  - **Aliases**: `NotationOptions.vocabulary`, a `NotationVocabulary` (`fromJson`, `toJson`, `merge`;
    `NotationVocabulary.core` by default, `.none` for none). A name for a word we have is read as that word, with
    the vocabulary open or closed, and each use is recorded. A type (with its own names for the target's
    parameters, words to add, and the keys it requires), a parameter for one type or all (another key, the key
    negated, or a string of the line), a flag, an event, a verb, and three lines of another shape. Built in, from
    the first corpus: `Shortcut "ctrl+k" onPress={…}` and `shortcut key=t …` (the `key` line), `state x=1 persist`
    (`saved`), `disabled={x}` and `disabled` (`enabled`), `ListTile … subtitle="…"` (its second string),
    `computed x={…}`, `ConfirmDialog#id "…" onConfirm={…}`, `Highlight` / `HighlightText` with `match=` / `query=`
    (`Text … mark=`), `MiniCalendar` / `CalendarMonth` / `MonthGrid` (`Calendar`), `RangeSlider low=a high=b`
    (`Slider bind=a bindEnd=b`). A word the notation already has is never an alias.
  - `notationPrompt(open: true)`: the open preface, the grammar and the core; no component list, no behaviour
    words, no JSON escape. 18,151 characters for a page 1280 wide, where the taught page prompt is 20,651 (73,270
    with Cards' components). The taught prompts are unchanged (the card prompt is 8,979 characters).
  - `NotationOptions.open({openVocabulary, vocabulary})` gives the same options with these two set.
- **`key escape when editing onPress={…}`**: a shortcut that runs only while a condition holds (the trigger's
  `when`), as `every 1s when running` does.
- **`Progress {done/total}`** (also `Ring`, `Gauge`, `Slider`): an expression where the bare number goes is the
  value it follows, as `bind={…}` is. It was a "not valid JSON" error.
- **An overlay written inside the page** (`Dialog#edit` indented under a pane; also Sheet, Drawer, Menu, Popover,
  Lightbox) is over the page, its lines the ones under it, and the page goes on after it. It was an unknown type.
  With a design system that has its own Dialog, a `Dialog#id` in a line is still that component unless an `open`
  names its id.

- **Nineteen behaviours a page can now write** (folded from the `dsl5/*` branches, each in the 33.0.0 grammar; the
  page prompt teaches them, the card prompt is unchanged at 8,979 characters, the page prompt is 20,580):
  - `confirm "Remove it?" then {rows=[]; close}` in an event's actions: the document's `confirm`, its actions run
    only on a yes.
  - `state draft="" saved` declares the variable with `persist`; `project cart=[] saved` checks that site.json's
    variable says `"persist": true` and has the same type.
  - `CodeInput "Code" bind=code length=6 digits`: a text field's new `otpLength` and `otpDigitsOnly` (a one-time
    code: one field drawn as boxes).
  - `Slider bind=low bindEnd=high min=0 max=100`: a slider's new `rangeEnd`, a second thumb; a `changed` gives
    `result.low` and `result.high`.
  - `each line in lines follow h=180`: a list that scrolls in that height, opens at its end and follows what is
    added (`stickToEnd`). An each's trailing words (`stagger=`, `follow`, `h=`, `reorder`) are read in any order.
  - `Text "{r.title}" mark={q}` binds the text's runs to `matchRuns(text, q)`; the formula table gains `fuzzy`,
    `fuzzyScore`, `matchRanges`, `matchRuns`, `matchReason` (`each r in fuzzy(rows,q,x=>x.title)`).
  - A new action, `announce` (`onTap={announce "{n} results"}`: said to a screen reader, nothing shown), and a
    text's `live` (`Text "{n} results" live`).
  - `Dialog#edit "Edit" guard={name!=""}` binds the overlay canvas's `blockBack`; `Sheet#filters stops=[0.5,0.9]`
    writes `openModal`'s new `snapHeights`.
  - A new control, `splitter` (`Splitter bind=paneW min=200 max=640`, with `step`, `collapseAt`, `orientation`,
    `label`): a divider between two panes, its value the first pane's size (`Column w={paneW}`).
  - A slider's `trackShape: stars` and `readOnly`: a rating (Cards' block: `Rating "Your rating" bind=score half`,
    `Rating "Score" score=4.5 readOnly`).
  - The page prompt says to name an icon-only button with `tooltip="Clear filters"`.
  - `openModal` gains `hoverCard`, `hoverDelayMs` and `popoverArrow`: `Link "About Mara" preview=bio` opens that
    Popover as a hover card, `Popover#bio arrow` points at its opener.
  - `key mod+k onPress={open search}` on a line of its own is a canvas `keyDown` reaction; a text's new `shortcut`
    (`Text "Search" shortcut="mod+k"`) shows the combination as the platform writes it.
  - `each stop in trip reorder` (and `reorder=group` between lists) with `Handle`, a row's grip: the list's
    `reorder` by handle and keyboard, applied to its variable, its handles one `focusGroup`.
  - `SwipeAction "Book" side=end when={!row.full} onTap={picked=result.item.name}` under an each: the list's
    `swipeActions` and a `swipeAction` reaction (`removes` takes the row out of its variable).
  - `device.hover` and `device.pointer` are read-only values (`if !device.hover`); a variable named `device` is
    refused.
  - A text field's `min`, `max`, `step` (`Input "Qty" bind=qty type=number min=1 max=12 step=1`) and
    `semanticLabel`; a click trigger's `repeat`, `holdMs`, `intervalMs` also mean a click repeated while held.
  - A new control, `calendar` (`Calendar bind=arrival bindEnd=departure disabledDates=["2026-11-24"]
    marks={"2026-11-20":"£225"}`): a month in the page with a range, `firstDate`, `lastDate`, `dayPrices`,
    `label`; a `changed` gives `{start, end}`.
  - `tableView` gains `sortable`, `sortColumn`, `sortAscending` and a `sort` trigger; the notation's `DataTable
    rows={orders} columns=[{"key":"name","label":"Customer"}] bind=row onSort={…} onRowTap={…}` is that table
    with the theme's texts, the chosen row's place in `row`.
- **The keyboard**: `focusable` (default true; false takes a node with a `click` reaction out of the focus order),
  `focusGroup` (`{axis, wrap, typeAhead}` or `true`: what is focusable inside the node is one Tab stop the arrow
  keys move through) and a canvas's `semanticLabel` (its name for assistive technology when it opens as an
  overlay). The interaction and navigation references say what the keyboard does on press targets, groups and
  overlays.

- **Right to left**: padding and margin written `{"start", "top", "end", "bottom"}` are Flutter's
  `EdgeInsetsDirectional` (`EdgeInsets.fromSTEB`, `directional`, `resolve`); `strokeSides` gains `start`, `end`,
  `noStart`, `noEnd` (`BorderDirectional`). The layout reference has an RTL section (what `textDirection` mirrors).
- **Validation**: `widthFactor` in a row (`heightFactor` in a column) is reported as ignored (`layout_field_ignored`);
  an expression written into an animation field is reported (`loose_value`) with the binding to write instead.
- **Docs**: a binding of a field an active interaction state patches yields to the patch.
- **`dragEdgeScroll`** (scrolling containers, lists, grids; default true): whether the view scrolls while a drag and
  drop is held near its edges. Off for a strip that should stay put under a drag: sprint_kanban's phone column tabs,
  where the strip scrolled the tab out from under the card it had just switched columns for.
- **`DropTarget.slotWhenRefused`** is back in schema 3 (default false): the list opens its slot for a drag
  `acceptIf` refuses too, as Flutter's `DragTarget` hands its builder the rejected candidates (a kanban column at
  its WIP limit shows where the card would land, styled as blocked). The migration writes it out where schema 2
  left it at its default (true) with an `acceptIf` and a list slot, so such a document renders as before instead
  of reporting a behavior change (sprint_kanban's columns relied on it).
- **Notation, the page words**: the frames of a desktop page, written out as plain lines before they are read.
  A website is `Page` with `Nav`, `Section` (a full-width band, its content in a centered column; `narrow`,
  `fill:`, `center`) and `Footer`. An app window is `App` with `Sidebar`, `Main` and `Pane w=320`, each as tall as
  the window and scrolling by itself. Also `NavItem "Orders" icon="inbox" badge="12" selected={…} onTap={…}`,
  `Link "Docs"`, `Heading "…" level=1`. Inside a card the same words are a plain row or column.
- **Notation**: `border-bottom=#…` (`-top`, `-left`, `-right`) is a rule on one side; `sticky` keeps a node in
  view while the page scrolls; `Text … italic`.
- **`NotationOptions.height`, `contentWidth`, `selectedFill`, `line`**: the window an app is drawn in, the
  widest a section's content gets (a theme's `sizes.content`), and the looks of a selected `NavItem` and a rule.
- **Notation, a theme's page tier**: on a wide canvas (a theme's `sizes.wide` and up) a name ending in `Wide`
  takes the place of the name before it (`textStyles.strongWide` is `Text.strong`, `radii.cardWide` a card's
  corner, `spacing.cardWide` its padding, `shadows.cardWide`, `sizes.ctaWide`). One theme then serves a chat card
  and a page with nothing switched: a card is written at its own width and keeps the card's looks.
- **Notation**: a button's `size:` (`xs`, `compact`, `small`, `medium`, `large`) is its height; a theme's
  `sizes.control` is the height of a button, a field and a select that write none. `Section tint` (a band on
  the theme's `colors.band`) and `Section compact`; `IconTile "sync"`; `Brand "Harbor" icon="anchor"`. A
  selected `NavItem` has its label and icon in the accent. A website page is drawn on `colors.pageFill`, an
  app's sidebar and top bar on `colors.card`. `Heading` in an app is the page's title (`level=1`), a panel's
  (`level=3`).
- **`NotationOptions`**: `narrowWidth`, `sidebarWidth`, `sectionPad`, `gutter`, `band`, `siteFill`, `paneFill`,
  `iconTile`, `controlHeight` (a theme's `sizes.narrow`, `sizes.sidebar`, `spacing.section`, `spacing.gutter`,
  `colors.band`, `pageFill`, `card`, `iconTile`, `sizes.control`).
- **`notationPrompt`** teaches the page words when `options.width` is `notationPageWidth` (700) or more, and
  adds the design system's "Pages in brief" (a section of its patterns) when it has one.
- **Notation, a page at other widths**: a page written once for a desktop lays itself out on a tablet and a
  phone. From 700 wide on the expander adds media rules below 1024 and below 700 (`PageReflow`, `reflow.dart`): a
  `Grid`'s rows wrap, a `Row` of blocks wraps, any other row wraps before it overflows, a table's row keeps the
  columns it has room for, an `App` shows its main pane, a `Nav` hides its links, sections and headlines are
  smaller. The page at the width it was written for is unchanged. `NotationOptions.reflow` (default true) turns
  it off. Design note 13, section 14.
- **Notation**: `hide=phone`, `hide=tablet`, `show=phone`, `show=tablet` say where a line shows; they hold on a
  line under an `if`, and a line that carries one is left out of the reflow's own hiding.
- **Notation, overlays**: a dialog, a sheet, a drawer, a popup menu, a popover and a lightbox are written after
  the page (`Dialog#id`, `Sheet#id`, `Drawer#id`, `Menu#id`, `Popover#id`, `Lightbox#id`) and opened with
  ` onTap={open <id>}`, each a canvas of its own with the right presentation; their lines read and set the page's
  values. `menu=<id>` opens a menu on a right click or a long press. An `App`'s `Sidebar` opens as a drawer on
  a phone from a button added to `Main`'s top bar.
- **Notation**: a website's `Nav` builds its own phone menu from its links (each as written; `menu=false` keeps
  one out; a `Nav` with a `show=phone` line keeps its own); `Nav sticky` and `SiteNav … sticky` stay at the
  very top (`sticky=0`), a `Nav` on the page's surface.
- **Notation**: `scroll <id>` moves the page to a line, named by its id (`Section#pricing`) or by an anchor
  (`id=pricing` on it); `Link "Pricing" href="#pricing"` does the same. `go` takes a destination worked out
  (`go {replace(lower(result)," ","_")}`); a page id may have hyphens.
- **Notation, a viewer**: `Lightbox#zoom "{photo}" "Caption"` shows a picture large over the page: a pinch and the
  wheel zoom about the point, a double tap goes to 2x where it was tapped and back, a drag pans while zoomed, and
  it closes by its button, Escape, a tap on the scrim and a drag down. `Lightbox#shots photos={photos} bind=at` is
  a gallery: a page per picture opened at the one tapped, turned by a swipe, its arrows and the arrow keys, with a
  count, the caption and a strip of thumbnails; `ratio=` (or a record's `ratio`) gives the picture's box its
  proportions. On a page, a design system's gallery that takes `viewer="overlay"` (Cards' PhotoGallery) opens its
  photos in a viewer the expander writes once. The reference has the render command's `--double-tap`, `--wheel`
  and `--pinch` steps.
- **Notation, tabs**: `Tabs bind=tab tabs=[…]` is the design system's own Tabs where it has one; the prompt keeps
  a `SegmentedButton` to two to four short options, never a page's tabs.
- **Notation**: `Input "Search" icon="search"` puts the icon inside the field, before the text (it was written
  as a prop the field does not have, and lost).
- **Notation, a site's variables**: `NotationOptions.projectVariables` (a site manifest's `variables`) and
  `project name=value` on a page: read and set by name, with no copy declared on the screen to hide them.
- **Notation**: `Section bleed` runs its content from edge to edge; a `Donut` written with `labels` draws them
  as a legend beside it, under it where there is no room (`legend=false`: the chart alone; a page that writes
  the labels itself keeps its own); a date or time field's string is its label, and on a page the field is as
  tall as the fields beside it; `NotationOptions.accentText` (a theme's `accentText` or `accentDeep`) is a
  link's ink in running text.
- `validateSiteManifest`: a key of `site.json` that nothing reads is a `site_key_ignored` warning; a theme key
  written beside `"theme"` (`"primary"`, `"colors"`, `"dark"`…) says to write it inside `"theme"` (it was ignored
  without a word).

### Changed

- **Notation**: a root written `h=fill` (and `App`) gives the canvas the window's height, where it was as tall
  as its content. `Row between center` keeps its ends apart and levels its children (it was read as centered).
  A row that spreads its children is as wide as its place, in a centered column too. An icon keeps its size in
  a column. A `Spacer grow` in a column takes the height left. A design system's block in a row shares the
  row's width where it filled it; a `radius`, `fill` or `border` written on a block is left out.

### Fixed

- **Notation**: `Input "Email" type=email`, which the prompt teaches, wrote a keyboard the document does not have
  (`email`; it is `emailAddress`). Also read: `tel`, `numeric`, `decimal`, `search`, `date`, `time`, `address`.
- **Notation**: `state shown={filter(rows,r=>r.open)}` kept the braces in the formula, so every value that read
  `shown` failed to parse. A formula in braces is that formula (a map, `{"a": 1}`, is still a map).
- **Notation**: a color in a formula written as it is after a key (`fill={late ? #FFFECACA : #FFFFFFFF}`) is the
  text it is; the formula did not parse.
- **Notation**: `grow=true` wrote `true` where the document takes a number; it is `grow` (`grow=false`: nothing).
- **Notation**: ` onTap={open <id>}` wrote its canvas under a key the document does not read (`modal`; it is `to`).
- **Notation**: a short loop name no longer rewrites a layout key of the same letter (`each h in homes` with
  `h=120`); an unbound boolean state of a block gets a variable of its own.
- **Notation**: a donut's first slice and a chart's first series were written as a theme name where a value is
  read, and did not draw; a donut given a height is as wide as it is tall. On a page: cards side by side in a
  row are equally tall; a field in a bar (or labelled "Search…") has its label as its hint; a `Badge` with a
  width sits in a cell of that width; a `Text` with a rule, a fill or a corner is a box around the text; `id=x`,
  `sticky=true top=24` and an Avatar's `src:` are read as meant.
- **Notation**: a see-through `fill:` on a `Card` sits over the card's own color (alone it let the card's
  shadow show through); `'single-quoted'` text in a value ends at its closing quote; `Sparkline values={row.trend}`
  draws from a record's list; a `color:` on a checkbox, switch or radio is its color when on; a text in a box of
  a fixed height makes the box grow instead of overflowing.
- **Notation**: the braces of a code sample shown as text (`import { Beacon } from …`) are text, not a value
  read.
- A site manifest's `variables` is read in the forms it is written: the list of records, or an object by name
  (`{"cart": [], "plan": "pro", "draft": {"value": "", "persist": true}}`: a name and its value, or a record without
  its name; `Variable.declarationsFromJson`). A variable that names no `type`, in a manifest or a document, has its
  value's (`VariableType.of`: `[]` a list, `3` an integer, `true` a boolean); it was text, so a list started empty
  and numbers were joined as text, with no diagnostic. `validateSiteVariables` reports each record that cannot be
  read (`invalid_variable`, with the shape to write). The notation's page prompt and the reference's "The site
  manifest" show the shape.
- The notation: a variable declared with a whole number (`state amount=0`) and bound to a component's number
  parameter (`NumberInput bind=amount step=0.01`) is declared `decimal`, not `integer`: an integer variable rounds
  what is set, so typed cents and a 0.01 step were lost (25.50 was saved as 26, the arrows did nothing). A site's
  variable (site.json) keeps the type it is declared with there.
- A site's theme over a design system's tokens (`DesignSystem.themeUnder`, the new `ThemeTokens.withSiteTheme`):
  what the design system makes from its accent follows the site's. A site that gives its own `primary` (or
  `colors.accent` where the accent is the primary) gets every color that is the design system's primary at some
  opacity (a selected row's tint, the focus ring, tinted borders) at that opacity of its own, the `info` color and
  its tints, and each shade named after the accent (`accentDeep`, `accentBright`) in its hue; in dark, with no
  `dark.primary` of its own, a primary made from its light one (it stayed the design system's blue) and the same for
  the dark colors. A site's `fontFamily` re-families the design system's text styles of its default family. A color
  or style the site names itself stays the site's.

## 32.0.0

Released with codelessly_sdk 32.0.0. Stored documents and the JSON format are unchanged; the one breaking change
is in how the compact notation reads `Column center`.

### Breaking

- **Notation: `center` and `middle` on a `Column` swapped.** `center` now centers children side to side;
  `middle` gathers them at the column's middle. Notation that wrote `Column center` expands differently.

### Added

- **Notation, meters and charts**: `Gauge` / `Dial` (`limit:`, `unit:`), `Ring`, `Sparkline`,
  `LineChart labels:[…] series:[…]`, `AreaChart`, `Donut`.
- **Notation, motion**: `animate:<word>` (fade, slide-up, slide-left, scale, pop, bounce, shake, pulse, spin,
  shimmer) with `duration:`, `delay:`, `stagger:`; `swipe:left -> …`.
- **Notation, layout**: several top-level lines are a page's sections, stacked; a `Stack` placed with `left`,
  `right`, `top`, `bottom`, or centered with `center middle`; `maxw:`; `grow:=value`.
- **Notation, parts and props**: `Avatar`; `Input … password` / `multiline`; a slider's `step:`;
  `Text … center` / `strike`; an `IconButton`'s `color:` and `size:`; `gradient:[…]`; an `every` with its
  actions on the next line.
- **`TextProps.markdown`**: a text shown as Markdown (bold, italic, code, links, @mentions, lists) with the
  markers taken out. Same keys as `TextFieldProps.markdown`.
- **Two schema 2 → 3 migration steps** for projects made before the v2 SDK: `text.markdown` moves a text's
  Markdown look to `props.markdown`; `trigger.fieldResult` rewrites a text field reaction's `result.value`,
  `result.word`, `result.cursor`, `result.selectionStart` and `result.selectionEnd` to `field.*`.
- **Theme names the notation uses when present**: `sizes.wide` with a `titleWide` text style (wide page titles
  from `NotationOptions.fromTheme(width:)`), `sizes.ring`, text styles `gaugeValue` and `gaugeUnit`,
  `colors.pageFill`. A theme without them is unchanged.

### Changed

- **Notation is more forgiving**: props guessed in a JSON tail are read as the notation's own keys, or reported
  at their line; single quotes hold spaces in an expression; fixed text widths in a row become shares when they
  do not fit.

### Fixed

- **A required component parameter set to its default value is kept.** `Props` dropped it, and the call then
  reported `missing_prop`.

## 31.0.0

Released with codelessly_sdk 31.0.0. Nothing a document written for 30.1.0 uses has changed.

- **The compact notation** (`package:codelessly_api/notation.dart`): `Pages =page` (swiped pages bound both
  ways, `peek`), `Dots =page count:n`, `Row scroll` scrolls sideways, sideways scrollers fade at their edge, and a
  value that follows state is read as a model writes it: the name bare (`choice:pick`), in braces, or the
  expression with no mark (`enabled:!voted`); a list holding expressions is a formula; `true`, `false` and `null`
  after `:=` are values. On a block's line, a bare word one enumerated parameter has, `key=value` and a further
  string are read as the parameter they can only mean. `NotationOptions.fromTheme(named: true)` writes looks as the
  theme's names.
- **`notationPrompt`** carries a design system's composition brief (its PATTERNS.md "In brief").
- **More of what models write is read** (each from a recorded answer, each with a test): a handler as a key
  (`onPressed:{…}`, `tap:"…"`), statements after `->` as in code (`n += 1`, `row.done = !row.done`,
  `rows.add(x)`, `rows.remove(row)`, `if (c) { a = 1 }`), `let name = expression` for a worked-out value, `for x in
  list`, `else`, `and`/`or`/`not`, calls on a value (`total.toFixed(2)`, `rows.length`); a condition in braces
  with spaces and quotes; `key:={…}`; a text inside a list or inside a formula that reads a value
  (`items:["Lemons, {2 * n}"]`); a list written over several lines; a value in braces that holds its own braces;
  a property written after the actions; a code fence around the answer; a parameter named like a handler
  (`change:1.84`); `formatTime(seconds)` as `duration`. An action that sets a worked-out value is dropped (the
  value follows the state by itself) instead of corrupting the line.
- **`Wanted "Name" "what it shows"`**: a part no component fits, built from plain types under the line and shown
  as written; the request is in `NotationResult.wanted` and `NotationStream.wanted` (`WantedBlock`).
  `notationPrompt(wanted: true)` teaches it; `notationPrompt(natural: true)` is a variant that teaches values and
  actions in the forms above (not the default: it did not measure better).
- `duration(seconds)` and `concat(a, b)` are in the notation's list of functions.
- **`edgeFade`** on scrolling containers and page views.
- **Validation**: a project component replaces its design system's of the same type (it was reported as a
  duplicate).


- **The compact notation, first version** (`docs/design/13-compact-notation.md`): `parseNotation` in
  `lib/src/core/notation/notation.dart` (internal, not exported yet) expands one node per line, nested by
  indentation, to an ordinary document: short type names (`Input`, `Toggle`, `Button.ghost`, `Card`,
  `Text.title`), a main string, `key:value` props, `=name` two-way bindings that declare their variable, `->`
  actions, `state`, `if`, `{name}` in text and a `{…}` JSON tail. What it cannot read is reported by line.

- **`label` on `checkbox`, `radio` and `switch`**: text beside the control (SSUI's; Flutter has the
  `*ListTile` widgets for it). Tapping it toggles and it names the control to a screen reader.

- **An expression written where a plain value goes is bound, not rejected.** `"radius": "${theme.radii.panel}"`,
  `"visible": "${step > 0}"`, a non-text prop: `applyOps` moves it into the node's `bind` under the field's path
  and reports `expression_bound` (a note, with the binding written). A path already bound keeps its binding; text
  props read expressions as written and are left alone. `strictEditCheck` passes `ValidateOptions.level` through.

- **Levels of the vocabulary** (`docs/design/12-agent-first-flutter.md`). `lib/src/core/levels.dart` (internal,
  not exported) gives every node type, action, data source, behavior and trigger a level: core, widgets, state,
  design, full, features. `catalogAtLevel` cuts a catalog to a level, `levelOf` and `levelUses` read a document's,
  and `ValidateOptions.level` reports anything above the level given (`above_level`).


- Date and time pickers (Milestone 3, workstream G): the `datePicker`, `timePicker` and `dateTimeInput` docs describe
  the SDK's own pickers (SSUI's field, a calendar or hour/minute columns in a popover or bottom sheet; an empty value
  shows its hint), no longer Material's dialogs; `docs/design/11-no-widgets.md` marks workstream G built.
- Design 11: the text field as built (WS-A, section 3.2): field frame, editor and what is left (handles, toolbar).
- Milestone 3, kit follow-up and workstreams C and I: a control (`WidgetSpec.hugs`: buttons, chips, `badge`,
  `circularProgressIndicator`, `activityIndicator`) with no `layout.width`/`height` hugs its content instead of being
  0 × 0 (`zero_size` no longer reported for it); buttons take `loading` (SSUI's `isLoading`); `TriggerType.deleted`
  (an input chip's delete icon, Flutter's `onDeleted`); the chip, badge and spinner docs say what their default
  (SSUI) look is.
- Milestone 3 design: `docs/design/11-no-widgets.md` (the renderer as render objects with no `MaterialApp`,
  `Navigator`, `Overlay` or widget per control; the control kit; SSUI as the default look; the split of the remaining
  controls into parallel workstreams).
- Theme roles: `ThemeTokens.resolvedRoles()` gives the roles (`primary`, `onPrimary`, `surface`, `onSurface`,
  `error`, `success`, `warning`) as colors, a role that names a theme color (`"primary": "forest"`) resolved
  through any chain of names; such a role never reached controls before (they drew black or white). A role written
  inside `colors` is a second spelling and is reported, `theme_role_in_colors` (warning), with the key to move.
  `ThemeTokens.roleNames`. The STARTER's theme example declares `primary` and `onPrimary` by color name.
- Buttons (`filledButton`, `outlinedButton`, `textButton`, `elevatedButton`, `iconButton`, `floatingActionButton`)
  take `autofocus` (Flutter's), and draw `WidgetState.selected` themselves: a bound `selected` on a button no longer
  reports `state_no_effect`. `WidgetSpec.states` (catalog JSON `states`) lists the states a type's own look draws.
  Their docs say what the default (SSUI) button is.

**What ten sites built as data (brief 3) ran into.**

- Validation: a list's pagination controller (`props.pagination.name`) is a name its page may read
  (`${coastPages.page < coastPages.pageCount}` was `unknown_name`).
- `gridView.fillGaps`: CSS `grid-auto-flow: dense`, automatically placed items filling the holes earlier spans left.
- `navigate.to` may be an expression (`${item.to}`): documented on the action; the SDK now evaluates it.
- `fit_not_allowed` in a wrapping row gives the fix (`basis`, with an example); `decoration_ignored` on a text says
  how to make a filled, rounded label (a row around it) or a highlight (`style.backgroundColor`).
- Reference: a page gutter and max-width recipe that keeps every section on one left edge at 390, 834 and 1440, and
  hero sizing (layout); submitting a form with no backend and simulated loading and error states (forms); a
  `tableView` with bound data (lists); updating one list line at its `index` and UTC offsets instead of IANA time
  zones (state); counting a number up, and running several `animate` actions together (animation); explicit grid
  placement under a filter, `scrollTo`'s offset under a fixed header and scrolling to a heading on another page
  (layout); declaring a variable font once (theme); `step_skipped` and `page_not_written` (render).

**Valid but blank, explained.** Of 34 recorded SSUI generations, several final frames showed an empty card or a
card missing its content. Causes in this package, and what a model is now told:

- A `vars` op with one formula that does not parse (or reads an unknown name) is no longer rejected whole: its other
  variables are declared, and the formula's error stays an error at that op, saying the variable gives nothing until
  its formula is fixed. Rejecting it left every node that read the op's variables showing nothing (three recorded
  cards, reservation, checkout and itinerary by claude-sonnet-5-5, went blank once formulas were checked).
- `BindValue.color` reads a theme color's name (`Color.named`): a fill bound to
  `"${= selected ? 'primary' : 'primaryBackground'}"` was dropped.
- A `patch` op merges a node as its declarations read it (`mergeNodePatch`): `{"height": {"fill": 400}}` over
  `{"hug": 480}` gave a two-key size and the patch was rejected.
- A `set` that replaces the root canvas with another type is rejected (`wrong_type`, with how to set the canvas's
  body): a recorded retry turned its canvas into a column and the view showed nothing.
- `wrong_type` for a `${...}` expression written as a plain value (`"radius": "${theme.radii.panel}"`,
  `"visible": "${step > 0}"`) names the binding to write, `"bind": {"decoration.radius": "${theme.radii.panel}"}`.
  Five recorded base turns lost their whole card to one such rejected container.
- The design system section shows its spacing, radii and sizes as the binding to write ("bound, not written: ...")
  instead of the bare `${theme.radii.panel}` models wrote as a value.
- New codes for what a rendered UI shows wrong, reported by the SDK's `UiSession.shownDiagnostics`: `empty_view` and
  `list_empty` (errors), `empty_label`, `expression_not_evaluated`, `text_no_color`, `component_empty` (warnings).
- `dead_control` lint: a core button, or a component named `...Button` with an `onPressed` event, with no reaction,
  not disabled and not inside a tappable node (a recorded plan card was a static mock-up whose Start and Pause did
  nothing).

- A computed variable's `formula` is checked like a node's expressions (it was not checked at all): it must parse
  and read only declared names, its `parameters` included. The edit layer checks the formulas of the variables a
  `vars` op declares (`EditCheckInput.variables`, read by `strictEditCheck`; the diagnostic's message names the
  variable).
- An unknown name that is a field of a list variable's records (`filter(invoices, status == 'Paid')`, computed once
  outside the list and matching no item: a recorded data table showed "No results" over twelve defined invoices)
  gets a message that says so and the lambda to write (`filter(invoices, r => r.status == x)`), with
  `r => r.status` as its suggestion.
- `unresolvedReferences` (with `changedVariables`): once a stream has ended, the references accepted as warnings
  while it ran ("it must exist when the stream ends") that are still unresolved, as errors. `streamReferenceCodes`
  names the codes.
- Reference: lists "Filter, sort and page a list" (search, a status filter, sortable headers and pages from chained
  computed variables, with a validated example; the pitfalls: a condition without its item, "All" and an empty
  search, `sortBy`'s `'asc'`/`'desc'`, resetting the page), a pitfall line, a line in the base and a row in the task
  table. `{{example-as-written:path}}` puts an example in a page as its file is laid out (one node per line).
- `strictEditCheck` passes its options' `theme` on to the validator (it dropped it): a session with a design system
  checks each op against the design system's tokens, so a theme color or text style name (`primaryBackground`,
  `sectionTitle`) is no longer rejected as `unknown_theme_name`.
- `TrustProfile.withComponents(library)`: the profile with a component library's types allowed. A session given a
  design system checks ops with it (the SDK's `UiSession(designSystem:)`): `TrustProfile.agent` lists the core's node
  types only, so every call to a design system component was `capability_not_allowed`.
- A top-level `componentEvent` (in a document that is not a component: a generated UI's own events to its agent) is
  no longer `unknown_event` in document and site validation; it is an event to the document's host and needs only an
  `"event"` name. The strict edit check no longer filters the code out for this case.

## 30.1.0

**No special cases left: the last 21 one-look fields are general mechanisms.** Documents stay `"schema": 3`.
Each removed field is migrated by a one-way step at the end of `migrate2to3` (`steps_special.dart`); in a
schema-3 document each is an `unknown_prop` whose message names the form to write, and a `setValue` path into one
is rewritten where it has a place (`props.displayFormat`, `props.highlightStart`/`End`) or reported. No document in
the corpus or either repository used one. Name conformance (docs/design/name-conformance.md, regenerated): 853
fields, 62% Flutter's name and meaning, 77% of those with a Flutter counterpart, none (d).

| Removed | Instead | Step |
|---|---|---|
| text `countUp`, `countUpDuration`, `countUpCurve`, `countUpOnShow` | a transition of `props.text` with the timing, and (with `countUpOnShow`, the default) an animation `countUp` with a track on `props.text` from 0 | `text.countUp` |
| slider `rulerTicks`, `rulerMajorEvery`, `rulerTickColor`, `rulerMinorTickColor` | `customPaint.painter` ops: a baseline `line` and a `repeat` of tick `line`s (a `ruler` track's default 20 ticks too) | `slider.paint` |
| slider `markerValue`, `markerColor`, `markerWidth`, `markerHeight` | a `rect` op at the value along `slider.trackRect` | `slider.paint` |
| slider `activeTrackStartOpacity` | an `rrect` op over the active track: the inactive color fading out | `slider.paint` |
| slider `thumbGripColor` | a `rect` op in `foregroundPainter` at `slider.thumbCenter` | `slider.paint` |
| slider `deriveOverlayColorFromThumb` | nothing (no renderer read it) | `slider.paint` |
| text field `highlightStart`, `highlightEnd`, `highlightStyle` | `runs` (new on the text field: styled ranges of the typed text, as a text's; Flutter's `TextEditingController.buildTextSpan`) | `textField.runs` |
| table `selectedRowEdgeColor`, `selectedRowEdgeWidth` | the `cell` template's `selected` state style (a left stroke), `selected` bound to the cell being first in the selected row | `tableView.rowEdge` |
| date/time input `displayFormat` | `format` | `dateTimeInput.format` |

- **A number in a text counts.** `AnimationTrack.lerpValue(a, b, t, text: true)` (and `valueAt(..., text:)`,
  `sequenceAt`): a text that holds a number goes from `a`'s number to its own, written as the end writes it (the
  characters around it, decimals, thousands separators; a value a clock computes a hair under a half rounds as the
  half). `NumberInText` (`parse`, `format`). A transition or track on a text prop such as `props.text` counts.
- **A slider's custom paint** draws between its parts and reads `slider` (`value`, `min`, `max`, `trackRect`,
  `thumbCenter`): `SliderTrackShape.ruler` draws its strip and fill only; the ticks are ops.
- `TextFieldProps.runs`. `specialCaseProps` and `movedSpecialPath` (legacy_paths.dart): what each removed prop is
  now, for validation and `movedPathHint`.
- **Validation: a layout value written as it decodes is not an unknown key.** `"widthFactor": 0` (any
  `widthFactor`/`heightFactor`) was reported as `unknown_layout_key`, with a message listing `widthFactor` among
  the valid keys: `readsKey` took a value that encodes back unchanged for one kept verbatim in an extra map. It now
  probes the key with a value no reader takes.
- **Name conformance** (`tool/name_conformance.dart`): the 21 (d) verdicts go; `textField.runs` (b), the grid
  placement fields (c) and `itemSnapping` (b) are classified. docs/design/10-audit-verdict.md section 6 re-measured;
  docs/design/schema-3-migration-report.md's note after 30.1.0 regenerated over the corpus.

**A site looks like itself: theme mode, declared fonts, local images.** Additions only; documents stay

**Design systems as data; controls that are not Material-shaped.** Additions and default changes; documents stay
`"schema": 3`.

- **`DesignSystem`** (`design_system.json`: `DesignSystemManifest`): DESIGN.md (principles), the tokens (a theme),
  PATTERNS.md and component definitions by reference, plus `fonts`, `examples` and `replaces` (the base controls its
  components stand in for). `DesignSystem.load(read)` reads one from a folder or a publish; `fromJson`/`toJson` is
  one bundle. `themeUnder(site)`, `libraryUnder(site)`, `catalogOver(base)`, `list` (each component's purpose and
  minimal call).
- **`site.json`'s `designSystem`** names one (a folder relative to the manifest, or a publish id): its tokens are
  the site's base theme, its components callable by type.
- **Named theme scales**: `spacing`, `radii`, `sizes`, `shadows` (with `dark` shadows), `durations`, `curves`, read
  as `${theme.<scale>.<name>}`; `ThemeTokens.mergedWith`. `validateTheme` checks them; a binding naming a step the
  theme does not have is `unknown_theme_name`.
- **The prompt**: `runtimeStarter(designSystem:)` adds a section generated from it (principles and patterns in
  brief, tokens by name, each component with parameters, slots, events and a call) and drops the base controls it
  replaces; `docsTopic(designSystem:)` answers `design`, `patterns`, `tokens` and a component's name. A
  design-systems page joins the reference.
- **Colors that follow the theme**: `tabBar` (`indicatorColor`, `labelColor`, `unselectedLabelColor`,
  `dividerColor`), `pagination` (`textColor`, `activeColor`, `activeTextColor`, `borderColor`), the gauges', charts',
  barcode's and signature pad's palettes are now optional, unset meaning the theme's role (documented per prop):
  values and lines `primary`, tracks and grids `outlineVariant`, ticks and axes `outline`, labels
  `onSurfaceVariant`, needles, cursors and tooltips `onSurface`.
- `dropdown.underline` now means the field's border (the theme's outline), never Material's underline.

**Earlier in this release: a site looks like itself: theme mode, declared fonts, local images.** Additions only; documents stay
`"schema": 3`.

- **Theme mode** (Flutter's `ThemeMode`): `ThemeTokens.mode` (`"mode": "system" | "light" | "dark"` in a theme,
  default `system`) is the mode a site starts in, and the **`setThemeMode`** action (`{"type": "setThemeMode",
  "mode": "${= theme.isDark ? 'light' : 'dark'}"}`; `mode` is an expression, `persist` defaults to true) changes it.
  `ThemeMode.isDark(platformDark:)` and `ThemeMode.tryParse`. Validation reports a bad mode, or a `mode` inside
  `dark` or a media patch (`invalid_theme`).
- **Site fonts**: `SiteManifest.fonts`, a list of `FontFamily` (`family`, `fonts`: `FontAsset` with `asset`,
  `weight`, `style`) in the shape of a pubspec's `fonts:` section, the files beside `site.json`.
  `PublishFont.ofFamilies` publishes them one per file with `url` the path relative to the site
  (`PublishFont.isSiteFile`; ids `Family/weight/italic`, `PublishFont.idOf`). `validateSiteFonts` reports a bad shape
  (`invalid_fonts`) and a file that is not `.ttf`, `.otf` or `.woff` (`font_format`; WOFF2 is not read).
- **Site files**: `isRelativeAssetPath`, and `PublishSource.assetPath` (`publish/{slug}/files/{path}`), where a
  published site's fonts and images named by a relative path are served.
- **Reference**: theme mode, declared fonts and local images in the base (`STARTER.md`); theme.md's dark mode and
  fonts sections rewritten; decoration.md's images section (local files, `BoxFit`/`Alignment`) and a new
  illustration section, with three validated examples (a photo card with a gradient scrim, an SVG illustration and
  a `path` mark, a `customPaint` scene); render.md's `--theme` and `font_missing`.

- **Node ids are per document; only canvas ids are site-wide.** `duplicate_id` now reports a canvas id two
  documents of a project share (`navigate` and `openModal` name screens by it, so a link reaches one of them), and
  no longer every node id two pages share: a page's actions and conditions name its own nodes, a component's ids
  are its own. The base says so.
- **Did you mean, by meaning.** `nearest` (the `suggestion` of `unknown_action_key`, `invalid_enum` and the other
  name checks) falls back to the name an author usually means when none is spelled close: `target` → `node`,
  `content`/`value` → `text`, `append`/`push` → `add`, `if`/`predicate` → `condition`, `screen` → `to`. An `if`
  whose `condition` is a formula string is told the predicate to write (`{"left": "${= ...}", "op": "isTrue"}`).
- **Reference: a complete multi-page site** (components, "A complete multi-page site";
  `tool/reference/examples/site/`, validated as one project by the reference test): the manifest first with every
  page listed, a header and a footer shared by reference, route parameters with a default, storage restored on
  load, a list kept per route under a key built from `${route.id}`, and a modal opened from a component. The base
  says to list every page in `site.json` before writing pages that link to them.
- **Reference: the names authors guessed wrong, in short examples where they look**: `scrollTo.node` (layout),
  `downloadFile.fileName` and `text` (media), `copyToClipboard.text` (interaction), the `if` predicate (state),
  `setStorage` ops (`add` appends, `insert` at an `index`) and keys per route (data). New patterns: scroll progress
  (layout), entrances on scroll with `animations[].visibleFraction` versus the `reveal` behavior, which scrolls
  (animation), pinning `now()` with the render command's `--now` (animation), spacing and radius scales (theme:
  there are no such tokens; a project variable map). The render page covers `--drag`, `--navigate` with a query
  string, `--now`, `--compare-map`, what a run keeps, and full-page captures of sticky nodes, modals and navigation.

- **A stroke path's draw-on animation migrates to the general pieces.** `strokePath.drawMs` (with `drawDelayMs`,
  `drawCurve`) was kept as `legacy.strokePath.draw` and no longer drawn; `paint.strokePath` now writes an animation
  `strokePathDraw` whose track draws the line op's `trimEnd` from 0 to its own value (the fill's paint from
  transparent), played when the node appears, and a transition of that `trimEnd` with the same timing; a bound
  progress becomes a binding of `customPaint.<painter>.strokePath.trimEnd`. Frame for frame the old painter's
  drawing (codelessly_sdk's `stroke_draw_on_test.dart`), except a progress that changes while the line is still
  drawing on. A literal `drawKey` is dropped (it never changed). `legacy.strokePath.draw` is no longer written.
- **`BindPaths.declaredDefault(node, path)`**: the declared default at a binding path (`opacity`, `props.*`,
  `layout.*`, `decoration.*`, a custom paint op's field), the node's value there when its JSON omits the field. An
  animation track with no `from` or `to` uses it (codelessly_sdk), so a track can end at an op's default `trimEnd` 1.
- **Name conformance, re-measured** (`tool/name_conformance.dart`; docs/design/10-audit-verdict.md, section 6, and
  docs/design/name-conformance.md): 61% of the 863 declared fields of the Flutter-mirroring node types and shared
  groups are Flutter's name and meaning, 78% of those with a Flutter counterpart; 21 special-case fields are listed
  with a recommendation.
- **A time picker's `use24h` is `alwaysUse24HourFormat`** (Flutter's `MediaQueryData.alwaysUse24HourFormat`, which the
  picker reads). Step `props.renamed` (in `migrate2to3`'s one-way steps) renames the prop, its binding, state and media
  patches and `setValue`/condition paths in a schema-2 document; in a schema-3 document `use24h` is refused
  (`unknown_prop`) naming the new spelling, and `movedPathHint('props.use24h')` gives it. No document in the corpus or
  either repository used it.
- **State patches that targeted `self` or `@<key>` now run.** A state patch names the node it patches by id; generated
  schema-2 documents also wrote `self` and `@<key>` (the node's key), which matched no node, so those hover, press
  and selection styles never applied (1131 patches in 9 corpus documents, all naming the node their states are on).
  `migrate2to3`'s first step, `states.target`, rewrites them to the id they mean and reports a behavior change. In a
  schema-3 document validation refuses them (`unknown_target_node`) with the id to write as the suggestion.

Forms, grid placement and scroll control, in Flutter's shape (and CSS's where the responsive model follows the web);
documents written for 30.1.0 load unchanged.

- **Forms.** `textField.validator` is Flutter's `TextFormField.validator`: an expression that reads the typed text as
  `value` and gives the error to show (`""` when valid), checked by validation with `value` as a name. The object
  form older documents saved (`{"type": "required"}`, `{"type": "email"}`, never applied) reads as the expression it
  named. `AutovalidateMode` gains Flutter's `onUserInteractionIfError`.
- **`form` behavior** (Flutter's `Form`, with `autovalidateMode`): the fields inside validate together; its nodes
  read `${form.valid}` and `${form.errors}` (`{field, label, message}`, top to bottom). `form` is a runtime scope.
- **`validate` action** (`FormState.validate()`): every field of the form (`node`, else the form around the
  reaction's node) shows its error, the first invalid one takes the focus (`focusFirstError`), `${result}` is
  whether all are valid.
- **`radioGroup` behavior** (Flutter's `RadioGroup`): radios inside take its bindable `groupValue`; choosing one runs
  the group's `changed` reactions.
- **Grid placement.** `layout.columnSpan`, `rowSpan` (CSS `grid-column: span n`) and `columnStart`, `rowStart`
  (`grid-column-start`, 1 the first) are child fields a `gridView` reads; elsewhere `layout_field_ignored`.
- **Scroll control.** `itemSnapping` on scrolling rows, columns, lists and grids (`PageView.pageSnapping` for items;
  CSS `scroll-snap-align: start`); the `scroll` and `scrollEnd` triggers document `${result.index}` (the item at the
  start of the view) and `${result.count}`.
- **Validation.** `state_no_effect`: a bound `selected` with no `states.selected` patch changes nothing (a chip's
  selection is `props.selected`).
- **Reference.** Worked, validated examples: a complete contact form (per-field errors on blur and send, a summary,
  a radio group, a success state), an editorial page at 390/834/1440 (one column, a split with a sticky rail, a
  three-column river with a spanning lead), a timetable that is a list on a phone, and a carousel with arrows, dots,
  progress and snapping. The base says to use the width at tablet and desktop. Where node-given names are read
  (`pageOffset` is a page view's, not a page's scroll), and how runs that cut an expression count, are stated.

### Earlier in 30.1.0

**One spelling for each concept; the schema stays 3.** Documents are still `"schema": 3` (`kSchemaVersion`), and
schema-2 documents still load, migrated in memory by `migrate2to3`, whose last steps now give each concept that
30.0.0 could say two ways one spelling, under Flutter's name. **30.0.0's schema-3 documents keep loading** as
schema 3; but a schema-3 document is read as it is, not upgraded, so one written with the earlier spellings below
must be updated once (the migration does it to schema-2 documents; validation reports each earlier spelling in a
schema-3 document as an error naming the one to write). docs/guide/12-migrating-to-schema-3.md ("30.1.0") is the
authors' guide; docs/design/schema-3-migration-report.md the migration over the corpus (106 documents, 0 failures,
3502 rewrites of which 1020 by the new steps; 5 behavior changes by the new steps, all a box path's, in two m05
experiments).

| 30.0.0 (schema 3) | 30.1.0 (schema 3) |
|---|---|
| a node's `"scale": s` | `"motion": {"scale": s × the motion's own}` |
| `"layout": {"rotation": r}` | `"motion": {"rotate": r + the motion's own}` (an uneven margin's pivot offset as `motion.translateX/Y`) |
| `flightKey`, `flight` | `"hero": {"tag": ..., "flies": "inPlace", "flight": {...}}` |
| `"hero": {"flight": "<look>"}` | `"hero": {"flightShuttle": "<look>"}` |
| `"strokePath": {...}` | a `customPaint` `path` op (`points` or `commands`, `trimEnd` for the progress) |
| a box with `props.path`, `strokeJoin`, `strokeMiterLimit` | a `path` node, the path as `props.data` |
| a path's `subpathColors` | one `customPaint` `path` op per color |
| a paint's `gradientPerSubpath` | one `customPaint` `path` op per shape, the gradient as its paint's `shader` |
| binding, transition, track, `setValue` and condition paths `scale`, `layout.rotation`, `flightKey`, `flight.*`, `hero.flight` (a look), `strokePath.*`, `props.path`, `props.subpathColors` | `motion.scale`, `motion.rotate`, `hero.tag`, `hero.flight.*`, `hero.flightShuttle`, the custom paint op's fields, `props.data` |

- **Docs: controls take the theme, never Material's defaults.** The reference's base and its theme page say what
  controls take from the theme's roles (`primary` fills filled buttons and draws checks, thumbs and text-button
  labels where it reads on `surface`; `fontFamily` every control label; `buttonRadius` every button and chip), that
  without a theme they are neutral (ink on paper and the greys between), and that nothing comes from Material's
  defaults or from the host app's theme. No API change: the roles already cover it (outlines and tints are derived
  from `onSurface` over `surface`, so no `outline` role is added).
- **Breaking, Dart: fields removed.** `Behaviors.scale`, `Layout.rotation`, `BehaviorFields.scale`,
  `LayoutFields.rotation`, `BindPaths.scale`, `BindPaths.rotation`; `Behaviors.flightKey`, `Behaviors.flight`,
  `BehaviorFields.flightKey`, `BehaviorFields.flight` (`HeroTag` gains `flies`, `HeroFlies` and `flight`; its look
  is `flightShuttle`); `StrokePath`, `PathUnit`, `PathCurve`, `StrokePathFields`, `strokePathType`,
  `BehaviorFields.strokePath`, `Behaviors.strokePath`; `BoxProps.path`, `BoxProps.strokeJoin`,
  `BoxProps.strokeMiterLimit`; `PathProps.subpathColors`; `Paint.gradientPerSubpath`,
  `PaintFields.gradientPerSubpath`; the `deprecated_key` diagnostic. The catalog's declared fields go from 2121
  to 2099 for the paint fields alone.
- **Added:** a `customPaint` path op's `commands` (Flutter's `Path` calls `moveTo`, `lineTo`,
  `quadraticBezierTo`, `cubicTo`, `close`, each number a literal or a formula, each call with an optional `when`;
  `PathCommand`, `PathOpFields.commands`); `PathProps.strokeMiterLimit`; `migrateDocument`, `migrateNode` (any
  schema to 3) and `migrateJson`; `MigrationScope.document` (a node step reads the document it is in);
  `movedPathHint` and `olderSchemaPathHint` (what to write for a moved path set at run time).
- **The migration's new steps** (`steps_spellings.dart`, `steps_transform.dart`, `steps_hero.dart`,
  `steps_paint.dart`), after schema 2's: `transform.fold` (scale multiplied into `motion.scale`, rotation added to
  `motion.rotate`, the pivot kept, bindings, transitions, tracks and keyframes moved), `hero.flight`, `paths.moved`
  (`setValue` and condition paths), the paint steps (`paint.patches`, `paint.strokePath`, `paint.boxPath`,
  `paint.perShape`; what has no exact form is kept as `legacy.<name>` and reported, e.g. the draw-on animation as
  `legacy.strokePath.draw`), then `patches.moved` (state and media patches). Rendered before and after, every
  affected corpus node draws the same pixels except a box path's filled edge (at most 4/255) and a box path
  reaching outside its box, now filled there too (reported).
- **Validation:** an earlier spelling in a schema-3 document is an error naming the one spelling
  (`unknown_node_key`, `unknown_layout_key`, `unknown_prop`, `unknown_field`, `unknown_bind_path` for a binding,
  transition, track, `setValue` or condition path, `wrong_type` for a look written as `hero.flight`). A custom
  paint's ops may read `size`, and its `viewBox` may be `[width, height]` (as the decoder reads and writes it). A
  `legacy.<name>` is `legacy_value` (a warning), held in `Node.extra`, never drawn.
- The plot chart's Cartesian props stay: they are the chart's general features (docs/design/01-paint-node.md,
  "30.1.0").
- **Reference:** regenerated; one spelling for each concept throughout.


**The reference for authors is one base plus links.** `docs/reference/STARTER.md` is the base an agent reads in
full (the document and the flat node map; layout, decoration, text with a theme; the base node types and which
types take children or slots; variables, bindings, reactions; media rules; the rules that are easy to get wrong;
an index); every other feature area is a page with the same six sections (When to use, Minimal example,
Reference, Patterns, Pitfalls, See also); `index.md` maps needs and every declared name to their section. Each
node type, behavior, trigger, action, model, enum, value type and formula function is on exactly one page
(`tool/reference/src/areas.dart`; a test checks it, and that every link and anchor resolves).

- **One base, two forms.** `baseDocument({form, catalog, profile, kind, docsTool})` assembles the base from the
  generated segments of `tool/reference/templates/base.md`: `BaseForm.files` is `STARTER.md` (with checking your
  work and sites as files), `BaseForm.runtime` is `runtimeStarter()` and `RUNTIME_STARTER.md` (with the
  answering rules, the ops and two examples). The runtime base is about three times the earlier one (≈ 43k
  characters against 15k): it now carries the theme, layout patterns, the children table and the index.
- **`ui_docs` serves the pages.** `docsTopic` answers a page (When to use, minimal example, pitfalls, its
  sections), any section by its anchor, or any node type, action, trigger or behavior by name; `docsIndex` is the
  index the base ends with; `docPages`, `docTasks` are the generated data; `toRuntimeLinks` turns the files'
  links into `ui_docs` topics. Earlier topic names (`responsive`, `reactions`, `gestures`, `scripts`...) still
  answer. `starterProps`, `behaviorAreas` and `guideTopics` are gone (`baseProps`, `docPages`).
- **Machine forms.** `catalog.json` names each node type's, action's, behavior's and trigger's page and anchor
  (`docs`); `index.json` lists every topic with its file, anchor, summary and size.
- **Retired.** `nodes.md`, `behaviors.md`, `triggers.md`, `actions.md`, `bindings.md`, `formulas.md` and
  `variables-conditions-scripts.md` are stubs that keep their anchors and say where each item went; the old
  guide's `index.md#guide-...` anchors land on a table of where each section went; `API_REFERENCE.compact.md` is
  gone (the base's runtime form replaces it); `API_REFERENCE.md` is the base, the index and the pages in order.
- **Docs at the declarations** for the props and fields the base shows.

## 30.0.0

**Schema 3: the one planned format break.** Documents are `"schema": 3`. Schema 2 documents load and are
migrated in memory; write schema 3. `LayoutDocument.fromJson` (and `PublishModel`, `PublishBundle`,
`PublishLayout`, `PublishComponent`, `ComponentDefinition`, the site manifest and plugin packages, through
the documents they hold) migrates a schema-2 document (or one with no `schema`) before decoding it; encoders
write `"schema": 3`. The guide's new chapter, docs/guide/12-migrating-to-schema-3.md, is the authors' migration
guide; docs/design/schema-3-migration-report.md is the migration over the reference apps and experiments.

- **The migration:** `migrate2to3(Json document, {MigrationReport? report})` (pure, total, idempotent),
  `migrateNode2to3`, `migratePublish2to3`, `migrateJson2to3` (any file that carries documents; a stored
  payload or a stored published component, whose digest covers what was stored, is migrated when read),
  `schemaOf`, `kSchemaVersion` = 3, `kPublishSchemaVersion` = 3, `schema3Steps` (named `MigrationStep`s).
  `MigrationReport` lists every rewrite, every value with no schema-3 form (kept on the node as
  `legacy.<name>`, unread, with what to write instead) and every behavior change; `migrationReportMarkdown`.
  Commands: `dart run tool/migrate.dart <file|dir> [--write] [--report out.json]`,
  `dart run tool/migration_corpus.dart` (corpus checks and the aggregated report).
- **Validation:** `validateDocument` reads 2 and 3: a schema-2 document gets the `schema_outdated` note
  (`Severity.info`) and is validated as migrated; `legacy_value` (warning) flags a kept value; an expression
  is accepted where a field takes one inline (`ExprCodec`: a timer's `intervalMs`).
- **Breaking (Dart): the legacy readers are gone from the model**; the migration has them. `Behaviors.migrateBind`,
  `Behaviors.legacyKeys`, `Behaviors.effectiveTransformGesture` (use `transformGesture`),
  `TransformGesture.zoomable`, `DragRelease`, `Spring.legacy`, `PathFollow.fromLegacy`, `Track.fromLegacyDrag`,
  `Track.readsOnly`, `DismissibleBehavior.fromLegacyDrag`, `Pan.fromLegacyDrag`, `AnimationPresets.fromLoop`,
  `fromEffect`, `fromMotion`, `fromPulseKey`, `legacyLoopMode`, `loopTypes`, `effectTypes`,
  `legacyMotionSpring`; `SetVariableAction.animateMs` and `curve` (`SetVariableFields.animateMs`, `curve`).
  Decoders no longer read `loops`, `effectAnimations`, motion's temporal keys, `opacity`, `blur`, `originX/Y`
  and flat path keys, `drag`, `zoomable`, a track's `endAngle`/`endless`/`jumpOnTap`/`wheel`/`keyboard`/
  `momentum`/`friction`/`write`/`settleStiffness`/path string, a draggable's `whileDragging`/`feedbackNodeId`/
  `feedbackAnchor`/`dragAnchorStrategy`/`spring*`/`physics`, flat physics springs, the `transitions` object and
  map, `gradientUnits`, `playAnimation`, `animateVariable`, `setVariable.animateMs`, `controlDrag`, the `clock`
  trigger: in a schema-3 document they are unknown keys (kept, unread).
- **Breaking (Dart and JSON): the deprecated one-app fields are removed** (the migration keeps a value that
  did something as `legacy.<behavior>.<field>` and reports what to write instead): `Track.defaultValue`,
  `doubleTapValues`, `parkedProgress`, `fineStep`, `finePixelsPerRange`, `fineHold`, `fineVariable`, `smooth`,
  `gain` (and `hasFine`, `isParked`, `doubleTapTarget`, `effectiveFinePixelsPerRange`, `${track.fine}`);
  `DismissibleBehavior.restX`, `restY`, `xVariable`, `yVariable`, `flyOutRotate`; on `DismissibleBehavior` and
  `Pan`: `rotateFactor`, `originX`, `originY`, `shakeWhenDisabled`, `disabledFollow`, `shareAs`, `follow`;
  `PathFollow.pacing`, `focus`, `pacedByArea`, `headsLeft`, `PathPacing`, `PathOrient.uprightFlip` (now
  `upright`); `Transition.arc`; `DropTarget.fullIf`, `slotWhenRefused` (the slot opens for accepted drags
  only), `hoverDelay`, and the `dropFull` and `dragHover` triggers; `GestureSnap.projectVelocity` (a snap
  always projects the fling); `TransformGesture.rotationSnap`; `OpenModalAction.showCloseButton`,
  `fullHeight` (never read). Their `*Fields` declarations go with them.
- **Flutter's reading where schema 2 had its own** (the migration writes out what schema 2 did, so migrated
  documents render the same): a text's `layout.padding` is applied (`Padding(child: Text)`, counted in a hugging
  size); schema 2 ignored it and the migration drops it from schema-2 texts (step `text.padding`, with the
  bindings and state and media patches that set it). The `layout_field_ignored` warning for a text's padding is
  gone. A text style without a `height` takes the inherited `defaultTextStyle` (new behavior on any node,
  Flutter's `DefaultTextStyle`: the nearest one wins, `{}` gives Flutter's defaults back), else the font's own
  line height (Flutter's `height: null`), not 1.33; the migration keeps 1.33 for schema-2 documents with one
  `"defaultTextStyle": {"height": 1.33}` per top-level node (step `text.lineHeight`; +0.08% bytes over the
  corpus). **Breaking (Dart and JSON):** `TextStyle.naturalHeight` (`TextStyleFields.naturalHeight`),
  `ThemeTokens.naturalLineHeight` and `StyleSheet.naturalLineHeight` are removed; the migration turns a natural
  style into its node's `"defaultTextStyle": {}`, and drops (reporting) a theme's flags, which a document
  migrated on its own cannot see. `migrateJson2to3` and `migratePublish2to3` drop them from carriers;
  `dropNaturalLineHeightFlags`. `tool/migration_corpus.dart` reports the encoded size before and after.
- **Paths an action names** (`setValue`'s `values[].path`) are not migrated: `schema2PathHint(path)` gives the
  schema-3 path for a schema-2 one, and `unknown_bind_path` says it (`motion.originX` → `motion.alignment`,
  `loops[i].<key>` → `animations.loop<i>.<key>`, `drag.track.<key>` → `track.<key>`...).
- **Behavior changes** (all reported by the migration, per document): a track with no value is drawn at
  its minimum, not at `defaultValue`, and a double tap resets nothing; the fine mode, `smooth`, a dismissible's
  tilt and fly-off spin, disabled follow and shake, `shareAs`, area pacing, the upright flip, a transition's
  arc, `fullIf`/`dropFull` and a hover delay no longer act; a refused drag opens no list slot; a
  `setVariable` glide that is not a set, add or subtract by one formula sets at once. Over the corpus:
  cutroom's fine step and safecracker's `smooth` (docs/design/schema-3-migration-report.md).


**Streaming generative UI, hardened against real model output**

- `OpStreamDecoder` recovers every well-formed op from tool input that is not valid JSON (eager tool input
  streaming does not promise it; a recorded live generation closed one brace too many three times): a repaired copy
  of the text (stray closers dropped, missing ones inferred, trailing commas removed, missing commas inserted), op
  objects read at any depth outside another op, re-synchronisation when an op begins before the previous one
  closed. Each repair is one `malformed_input` warning with the character offset; `OpStreamEnd.repairs` and
  `.recovered`; `StreamedOp.recovered`. A set op's node fields written beside `"node"` move into it
  (`misplaced_field`). Property tests: any chunking yields the same ops; 2,000 single brace, bracket or comma
  edits lose no op but the one they land in; the three recorded live generations decode whole (24, 50, 34 ops).
- The retry protocol: `EditResult.toModelJson()` says what the document holds (ids set, patched, moved, removed;
  roots, node count, pending) and, when anything is rejected or pending, `next` (fix by patching, same ids, never
  start over); `fixInstruction`; `EditResult.withDiagnostics`. `applyOps(protectRoots: true)` answers a batch
  that would replace the roots or add a canvas with `start_over`. `explainDiagnostic` spells out the fix for the
  codes models hit (`unknown_layout_key hug`, `children_not_allowed` and `invalid_parent` with the types that take
  children, a button's `text`, `would_orphan`, `canvas_as_child`); `atOp` moves the op path with the index.
- `uiLints`: `empty_button`, `low_contrast` and, with a `GlyphCoverage`, `missing_glyph` (with the icon to use);
  codes `no_size` for renderers; `fontCodepoints` reads a font's cmap.
- The runtime docs: `runtimeStarter` is the base set a chat card or small screen needs (layout, decoration and text
  essentials; one table of the base node types with what takes children and their key props, the button family and
  the inputs and lists included; state, bindings, reactions; two examples that apply cleanly), generated from the
  declarations; `docsTopic` answers the `ui_docs` tool for any node type, action type, trigger, behavior or
  feature area (the guide's sections, `guide_topics.g.dart` written by the reference generator); `docsIndex` is the
  base's index. `uiTools(catalog, compact: true, docs: true)`: the op envelope strictly plus `ui_docs`; `ui_read`
  takes `types` (`describeTypes`). Generated: `docs/reference/RUNTIME_STARTER.md`, `ui_tools.compact.json`.
- `TrustProfile.agentApps`: `agent` plus the document's sandboxed scripts (capabilities `variables.read`,
  `variables.write`, `clock`; `TrustProfile.scriptCapabilities`). The `scripts` op sets and removes them by name
  (`ScriptsOp`, `invalid_script`), with an inverse for undo.

**Components in published apps, hosted plugins as components (sections and components, phase 2)**

- `PublishModel.components` (`{type: {version, digest, lastUpdated, fonts}}`, `PublishComponentInfo`),
  `PublishLayoutInfo.components` (the closure a layout calls), `PublishComponent` (stored at
  `PublishSource.componentPath`: `publish/{p}/components/{type}`, `{"schema": 2, "id", "version", "digest",
  "document"}`; a document decoded from a store is written back as stored), `PublishBundle.components` and
  `PublishBundle.extra`. `PublishModel.fontsOf` adds the fonts of the components a layout calls. `canonicalJson`:
  what a component's digest (sha256, computed by the publisher) is over.
- Hosted plugins on the components' path: `PluginWidget.definitionJson` and `PluginPackage.definitions` turn a
  plugin node type into a component definition (its catalog declaration as `widget`, its slots as `slot` nodes,
  its events declared, its formula functions as the root's variables). `PublishBundlePlugins`
  (`pluginVersions`, `withPluginVersions`): plugin payloads embedded in a bundle.
- Validation: `repeated_subtree`, a new `Severity.info`: a subtree of three or more nodes written several times
  over, node for node (ids and names aside), with the copies' ids: "consider a component or a list template".
  Only exact repeats; a repeat inside a reported one is not reported again.
- Docs: DESIGN.md §2.1, §4.2, §4.3, §5.4; docs/design/06 and 05 "Done" / "Not done"; the guide's components
  section (published sites, per-instance rules, slots inside lists, plugins as hosted components,
  `--components-all`, `repeated_subtree`).

**Authoring fixes from the third direct-authoring experiment (cycle 3)**

- Named colors and text styles. The site manifest declares the project's theme (`SiteManifest.theme`: colors,
  text styles, roles, `dark`, and `ThemeTokens.media`, rules that patch the theme by screen size); a color field
  may name one of its colors (`"color": "ember"`, kept through decode and encode as `Color.named`) and a text
  style may start from a named one (`"style": "title"`, or `{"from": "title", ...}`: `TextStyle.from`, merged as
  `TextStyle.merge`). `ThemeTokens.color`, `textStyle` (resolved: `from` chains, colors by name, aliases),
  `atScreen`; `ThemeRefs` / `resolveThemeRefs` resolve a node or a document by its declarations (props,
  decoration, behaviors, media and state patches), leaving the nodes that name nothing the same objects.
  `Color.fromHex` reads values only (the old `fromJson`). A media or state patch that names another style
  replaces the style; one that changes fields merges over the named style. New diagnostics `unknown_theme_name`
  (with the nearest name) and `invalid_theme`; `validateTheme`; `ValidateOptions.theme` (the manifest's by
  default). **Behavior change (documents that validated stay the same):** a color string that is neither a hex
  color nor anything else (`"blue"`) decoded to null and now decodes as an unresolved theme name (transparent);
  validation reported it before and reports it now.
- `IconProps.size` (Flutter's `Icon.size`).
- A media rule's patch may set `bind` (bindings at its sizes only; `null` drops one of the node's) and `motion`
  (a paint-only transform). `media_overridden` says how to combine a rule and a binding.
- `layout_clamped` points to the overlap patterns (motion translate, a stack).
- Docs: the guide and the starter lead with the theme; overlapping a neighbor, bleeding past the gutter, a
  verified full-width band with capped content and a table from one cell template, form control styling,
  `foregroundFills` over children, a literal `$` before an expression, superscripts, arrow keys through
  `keyDown`, component parameter kinds; the allowed-modes table marks fill with `basis` in a wrapping row;
  `bindings.md` lists what each path expects.

**Authoring fixes from the second direct-authoring experiment (cycle 2)**
