## Unreleased

### Breaking (33.0.0)

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
