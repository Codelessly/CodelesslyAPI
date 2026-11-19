# 24. A design at a width

2026-11-18. A proposal: nothing here changes what the notation does. It rests on note 13 (the notation, section 14
on widths), note 20 (defined words and their `...` slot), note 22 (media rules in the notation's words) and note 23
(the base and the dictionary, whose section 3 found that three "phone behaviours" are done by code that reads and
moves other lines).

The owner's direction on note 23: "They come with 'changes'. We have to introduce a new grammar concept if we want
the concept of x design at x breakpoint / layout. Let's explore this, because it's quite fundamental to a lot of
what we're building, and can be used to further decompose and describe these behaviors. Keep them as base for now,
until we have this new system. Even then, they're still base enough to have a vocab word for."

Of the three forms put to the owner (A: a block per width under a part; B: a presentation key, `Sidebar
phone.as=drawer`; C: a named layout on the frame), the owner chose A. Four decisions are fixed and not reopened here:

1. A first. B is refused for now: a named presentation hides its meaning ("what does as menu and as pinned
   mean?"). A presentation word may come later only as a dictionary word defined by an A block.
2. The condition is the **window's** width, not the container's.
3. A drawer's trigger (the button that opens it, elsewhere in the tree) is placed by a default rule; the writer
   does not name the place.
4. The three phone behaviours stay base until this system exists, and keep a vocabulary word afterwards.

What was made, all added files:

| what | where |
|---|---|
| this note | `docs/design/24-a-design-at-a-width.md` |
| the count of what round 11's writers and the web arm wrote at widths, and the script that counted it | `docs/design/a-design-at-a-width/count_widths.py`; its output `COUNTS.md` |
| the experiments' inputs (section 11 gives their results) | `docs/design/a-design-at-a-width/experiments/*` |

## 1. What exists today

**Values at a width.** A key with a condition before it holds only where the condition does: `phone.pad=16`,
`tablet.gap=8`, `max899.hidden`, `min700.tablet.size=14`, `portrait.size=12` (`docs/reference/notation/responsive.md`,
"Keys at other widths"). `hide=phone` and `show=phone` are the same rule on `visible`. The widths: `phone` up to
699, `tablet` up to 1023 (a tablet **and a phone**), `desktop` from 1024 (`mediaSizes`,
`lib/src/core/notation/media_words.dart`; the bounds are `reflowPhoneMax` and `reflowTabletMax`, `reflow.dart`).
States take the same prefix (`hovered.fill=…`). Every such key becomes a media rule on the node.

**Structure at a width** is done only by code, with nowhere to write it: the reflow (`reflow.dart`) gives a page
expanded at a desktop's width rules for a tablet and a phone, and the page words (`page_words.dart`) write lines the
writer did not: the drawer an App's first Sidebar opens in, the menu a Nav's Links go into, the slim bar that holds
the drawer's button, the back button of a list beside its detail (`notation.dart`, `_listDetail`).

**In `define`**, a body line `...` is where the lines written under a use go (note 20 section 3); `...Front` a
named slot. A body is expanded where it is used (a macro), so its lines are a page's lines.

**In the document** (schema 3), three things speak of widths:

| | what it is | where | can it change a part's children? |
|---|---|---|---|
| a node's `media` rules | `[{"maxWidth": 699, "patch": {…}}]`: a JSON merge patch over the node while the window meets the condition, later rules winning | `lib/src/core/media.dart` (`MediaRule`), `Node.atScreen` (`node.dart`) | no: `MediaRule.patchKeys` is `props`, `layout`, `decoration`, `visible`, `opacity`, `motion`, `bind`. A rule can hide a node (`visible: false`), not give it other children |
| a responsive `variance` node | one node whose `variants` each name their `children` and a project `breakpoint`; it shows the variant for the window's width, by the project's breakpoints or its own switch points (`minWidths`) | `VarianceProps` and `VarianceBreakpoints` (`lib/src/core/widgets/canvas.dart`), `Breakpoints.governing` (`breakpoints.dart`); drawn by the SDK's `lib/src/render/node_tree.dart` (the variance case: the variant for the width, its first child) | yes: this is a part's design per breakpoint, already in the base |
| a canvas per breakpoint | canvases with the same `props.screen`, each `props.breakpoint`; the window shows the one whose breakpoint holds | `CanvasProps.screen`, `CanvasProps.breakpoint` (`canvas.dart`); `docs/reference/layout.md`, "A canvas per breakpoint" | yes, for a whole screen |

Two facts of the document matter below. A node has one parent (`LayoutDocument._parents`, `document.dart`): the
same node cannot be a child of two designs, so a child that shows in two designs is two nodes. And the reference's
own friction list says so of variances (`docs/reference/_authoring-friction.md`, item 14: "variants list children
by id, so the duplication moves into the variants. There is no way to share a node between canvases.").

The project's default breakpoints put `tablet` at 600 (`responsive.md`, "Breakpoints"), the notation's `phone` ends
at 699. A variance keyed by breakpoints therefore switches at 600 unless it says `minWidths: {"tablet": 700}`
(section 11, experiment 4: with it, 699 shows the phone variant and 700 the wide one).

## 2. What writers do at widths

Round 11 (`dsl-api-11`, 30 briefs) built each brief in notation three ways (1-write, 2-write-repair, 3-write-desk)
and once as a React and CSS site (4-web). `count_widths.py` read the notation of the first three (pages and
components, 699 files, 31,770 lines that are not blank or comments) and the web arm's `src/`. All of `COUNTS.md`
comes from it; the quoted lines below are from it.

### 2.1 The notation

| what was written | 1-write | 2-write-repair | 3-write-desk | all |
|---|---:|---:|---:|---:|
| a key at a width (`phone.pad=16`) | 0 | 75 | 0 | 75 |
| `hide=<width>` | 257 | 205 | 151 | 613 |
| … on a line with lines under it | 59 | 67 | 50 | 176 |
| `show=<width>` | 120 | 107 | 58 | 285 |
| … on a line with lines under it | 30 | 39 | 29 | 98 |
| **twins**: a line `show=W` beside a sibling `hide=W` | 93 | 75 | 33 | **201** |
| … value twins: the same word and the same lines under (a `phone.key=` would say it) | 73 | 38 | 8 | 119 |
| … structure twins: another word, or other lines under | 20 | 37 | 25 | 82 |
| … … the same word, other lines under | 11 | 14 | 7 | 32 |
| … … a Row and a Column (`phone.direction=` would say it) | 2 | 3 | 3 | 8 |
| … … a Grid and a Column or Row (`phone.cols=` would say most) | 3 | 2 | 2 | 7 |
| … … another word (an IconButton for a Button, a menu button for a row of links) | 4 | 18 | 13 | 35 |
| … … of which a menu button shown where a row of links is hidden | 0 | 6 | 0 | 6 |
| lines under a shown twin; of them also under its hidden twin, the same up to width words | | | | 251; 69 |
| `if` over a state named for a width (`if phonePane=="list"`) | 3 | 0 | 3 | 6 |
| `show=W` together with `visible={…}` (a pane chosen by a state, on a phone only) | 1 | 0 | 3 | 4 |
| `screen.width` in an expression | 0 | 4 | 0 | 4 |
| a word named for a width (`PhoneNotebooks`) | 0 | 0 | 2 | 2 |
| a comment about a width | 1 | 1 | 3 | 5 |
| `if phone`, `at phone`, `when phone`, `phone:` as a line | 0 | 0 | 0 | 0 |

Builds that write a width at all: 30 of 30 (1-write), 29 (2-write-repair), 20 (3-write-desk).

What writers reach for, in order:

- **The line written again for the other width** (201 twins in 30 builds). Most are value twins: the same line
  with another size, `Text "Notes from the line" size=38 … show=phone` beside `… size=50 … hide=phone`
  (`travel-guide/1-write/pages/journal.txt:15`). A first write never used a key at a width; only the repair arm
  did (75 keys, after seeing its renders).
- **A different structure as a twin**: `Column gap=28 show=phone` beside `Row gap=24 top hide=phone`
  (`studio-portfolio/1-write/pages/work.txt:33`); `Column gap=7 show=phone` beside `Grid cols=5 gap=5 hide=phone`
  (`photo-library/2-write-repair/pages/search.txt:41`); `IconButton "search" … show=phone` beside
  `Button.ghost "Search  ⌘ K" hide=phone` (`notes-app/2-write-repair/pages/workspace.txt:51`).
- **The phone menu written by hand**: `IconButton "menu" tooltip="Open navigation" show=phone onTap={open
  savedNav}` beside `Row gap=10 hide=phone` (`story-reader/2-write-repair/pages/saved.txt:12`, and four more
  pages of that build; `food-ordering/2-write-repair/pages/restaurant.txt:21` with `more_horiz`). The button goes
  where the row of links was.
- **One pane at a time, by hand**: a state and `if` twins of the panes, the content written twice
  (`mail-client/3-write-desk/pages/mailbox.txt:34-52`): `Column w={listWidth} hide=phone` holding `MailList …`,
  and, under `if phonePane=="list"`, `Column grow show=phone` holding a back bar and the same `MailList …` again.
  `notes-app/1-write` and `3-write-desk` did the same with `mobilePane`.

Nobody wrote a line that opens a block for a width. What every writer did write is the width word itself, as the
value of `show=` and `hide=` (898 lines) and as a key's prefix. The twins also measure what form A saves: of 251
lines under shown twins, 69 are the hidden twin's lines again.

The pairing is a heuristic: a line `show=W` is paired with the first sibling `hide=W` under the same parent. Where
several shown lines stand beside one hidden one (`story-reader/3-write-desk/components/Dispatch.txt:7-10`, four
IconButtons beside one row of Links) each is paired with that one.

### 2.2 The web arm

| | count |
|---|---:|
| builds with a `@media` about width | 30 of 30 |
| `@media` blocks about width | 231 |
| declarations in them: a value (size, padding, font, gap, colour) | 2,867 |
| … an arrangement (`grid-template-columns` 235, `position` 47, `flex-direction` 35, `flex-wrap` 28, `grid-column` 27, `order` 5 …) | 557 |
| … `display` other than `none` (a part shown, or laid out otherwise) | 129 |
| … `display: none` | 96 |
| elements with a class named for a width (`mobile-nav`, `phone-only`, `desktop-crumb`) | 37 |
| a component named for a width (`MobileNav`) | 0 |
| Tailwind width prefixes in the markup (`md:hidden`) | 1 |
| a width read in script (`innerWidth <`) | 1 |

The commonest conditions are `max-width` 600, 1050, 680, 700, 1000 and 640: a phone near 600 to 700 and a tablet
near 1000 to 1060, as the notation's bounds.

The web writes **one tree** and changes it at a width in CSS: mostly values, then arrangement (the same children
placed on other grid columns), then twins in the markup shown and hidden by class (`.phone-only, .phone-compose {
display: block; }`, `mail-client/4-web/src/styles.css:71`). A pane chosen at a width by a state is a class
selector: `.workspace.show-list .message-list { display: flex; }` inside `@media (max-width:680px)`
(`mail-client/4-web/src/mailbox.css:69`). No build wrote a separate component tree per width. Tailwind was installed
in all 30 and its width prefixes used once.

What it suggests: most of a design at a width is values, which the notation has. Structure at a width is the same
content arranged otherwise (CSS's grid placement), or a twin. A form whose lines refer to content written once, and
place it, is nearer to what the web does than a second copy of the content.

## 3. Form A: the line

### 3.1 The spelling: `at phone`

| spelling | for | against |
|---|---|---|
| **`at phone`** (chosen) | reads as a statement, beside `each` and `if`; the condition after it is the one a key's prefix takes (`at max899`, `at min700.tablet`, `at portrait`), read by the same `mediaCondition`; a line `at …` is refused today ("No node type "at""), so no text that expands cleanly today means anything else by it | a word to teach: nobody wrote it unprompted (nobody wrote any block spelling) |
| `if phone` | the nearest English; writers write `if` over states named for widths (6 lines) | `if` is a run-time condition over the page's variables, and `phone` is a variable in 3 briefs, 6 builds (`Input "Phone number" @phone`); a width is not a variable |
| `when phone` | reads well | `when` already means a run-time condition in the grammar (`every 1s when …`, a key's `when`) |
| `phone:` | short; CSS- and YAML-like | the grammar has no line ending in a colon; a writer would also write `phone: Column …` on one line |
| `phone` alone | the width word writers already write (898 times) | a bare lowercase line reads as nothing; `max899` alone reads worse |

`at phone`: the width word writers already use, in the statement form the grammar already has. `at mobile` is read as
`at phone`, as `mobile.pad` is today.

### 3.2 Where it may appear

| place | |
|---|---|
| under a node line (a part), after the part's other lines | yes: the block is that part's design at that width |
| under a node line, before or among its other lines | an issue: `...` would name lines not read yet (the parser reads a stream, note 20 section 3), and the default lines read first are the clearest |
| under `each` or `if` | an issue: an `each` or `if` is not a place of its own (the page words treat it so). Write it under the line the `each` repeats: each row's design at a width |
| at the margin (under no line) | an issue in the first stages: write it under the root line. Later it could be a screen's canvas for that breakpoint (the base has canvases per breakpoint) |
| inside a `define` body, under any of its lines | yes (stage 2): a word's own design at a width, its `...` the use's lines (3.4) |
| inside another `at` block | an issue in the first stages; the inner condition could later hold where both do |
| with nothing under it | the part has no children at that width (its own line, its fill and padding, stay). Not `hide=phone`, which leaves out the part |

### 3.3 What the lines under it mean

**The lines under `at W` are the part's children at width W.** They replace the part's other lines (its default
children) where W holds; the default children show where no block holds. The part's own line holds at every width:
its id, its type, its frame (a page word's padding, fill, divider and role), its events and its binding. Its own
values at a width stay keys with a prefix on that line (`Row#bar gap=16 phone.gap=8`).

So form A is for a part whose tree differs; a part whose values differ keeps its prefix keys; a line that is
another word on a phone (an IconButton for a Button) stays a twin pair, `show=phone` beside `hide=phone`, one level
up. The children replaced, not the part, because the parts that differ most at a width are frames (App, Nav,
Sidebar, a pane, a Table) whose own line carries what the rest of the page and the reflow read: the id an `open` or
a `scroll` names, the role, the bar's fill. The other reading (the block is the part itself) is question 1.

A consequence: the part lays out the block's lines as it lays out its own. A `Grid cols=7` whose phone block is a
Column puts that Column in one of seven cells; the writer writes `phone.cols=1` on the Grid, or the twins one level
up.

### 3.4 Content written once: `...` and `...#id`

In a block, `...` is the part's default children, in order, as written; `...#id` is the one default line with that
id, with the lines under it. A default line may be named this way at any depth under the part. A block that uses
neither writes its own lines only.

```notation
Row#bar w=fill between middle pad=[24,14,24,14]
  Text#brand "Acme" size=18 weight=700
  Row#links gap=24 phone.direction=vertical phone.gap=2
    Button.ghost "Pricing" onTap={navMenu=false; scroll pricing}
    Button.ghost "Docs" onTap={navMenu=false; scroll docs}
  at phone
    Column w=fill gap=4
      Row w=fill between middle
        ...#brand
        IconButton "menu" onTap={navMenu=!navMenu}
      if navMenu
        ...#links
```

This is the meaning `...` has in a `define` body (note 20 section 3), extended: there it is "the lines written under
the use", here "the lines written under the part". In a body's block (stage 2) it is the use's lines again, so a
word can present what it is given otherwise at a width: `...` in the body's default lines and again in its block is
the same content presented twice, of which one shows.

A line brought by `...` is the line as written, with its keys at widths: `Row#links … phone.direction=vertical`
is a column where the phone block shows it. Nothing in a block may be written on a line brought by `...`; what
differs at the width is written on the default line with a prefix, or the line is written out in the block.

### 3.5 One child, two designs

Where a block brings a default line with `...`, the document holds two nodes (a node has one parent, section 1), of
which one shows at any width.

| | what happens |
|---|---|
| **ids** | the default line keeps its id; the copy is `<id>_<width>` (`links_phone`; the condition's words joined by `_` for `min700.tablet`). A line with no id gets the next free id as today. Experiment 2 shows why: the same id twice is an issue ("The id "title" is used twice") |
| **actions that name an id** (`focus search`, `scroll pricing`, `open`) | the expander writes the action once per copy; the hidden copy's is assumed to do nothing (not verified, section 12). A runtime "the shown node of this id" is a base item to add only if that fails (question 5) |
| **bindings** (`@q`, `{item.name}`) | the copies read and write the same page variables: what is typed on a desktop is there on a phone. Experiment 1: both copies of `Input @q` bind `${q}` |
| **a word's own state** (a defined word's `state open=false`, renamed per use, note 20 section 4) | the copy is the same use, so it keeps the same names: a FlipCard turned over on a desktop is turned over on a phone. This is a rule the expander must keep (a second use would get names of its own) |
| **`each`** | a line under an `each`, or an `each` brought by `...`, repeats in each copy, over the same list |
| **focus, caret, scroll position, a playing animation** | belong to the node shown; crossing a bound shows another node, which starts from the page's state. A phone turned sideways (390 to 844) crosses the 699 bound: the text typed survives (it is a variable), the focus and the caret do not |
| **the vocabulary record** | the copy is recorded as the use's (`node` the default line's), as a slot's line is |

### 3.6 Several widths, and what falls through

Blocks hold in the order written, the later winning where two hold, as rules do (`responsive.md`: "rules hold in
the order written"). Since `tablet` holds on a phone too, the wider is written first:

```notation
Row#window w=fill h=fill
  …
  at tablet
    …
  at phone
    …
```

At 390 the phone block shows, at 800 the tablet block, at 1440 the default lines. A width no block holds at falls
through to the default lines, never to another block. A block written after one it covers entirely (`at tablet`
after `at phone`) is never shown, and that is an issue ("at phone is never shown: at tablet after it holds wherever
it does. Write the wider first."). Conditions may be any a key's prefix takes; an orientation (`at landscape`)
holds with the widths.

### 3.7 Beside the reflow

A block is the writer's own design at its width, so the reflow gives the part, and every line of its blocks, none of
its rules (as it leaves a line with rules of its own, `responsive.md`, "What reflow does"). The default lines keep
the reflow where no block holds: with only `at phone` written, the reflow still fits the default lines to a tablet.
That needs one change: the expander's own hide rules on the default lines must not count as the writer's (today
any media rule makes a line the writer's, `PageReflow._own`). Experiment 6 shows the cost of not doing so: written
as twins, a list beside its detail keeps its 380 list at 834 and leaves the reading pane 214 wide, because every
pane has `hide=phone` and the reflow leaves it.

### 3.8 What the expanded document holds

**Form A needs no new node and no new property.** It expands to what the base renders today, in either of two ways:

| | twins (proposed first) | a responsive variance (later, question 2) |
|---|---|---|
| shape | the part's children are its default lines, each with a rule `visible: false` where a block holds, and each block's lines, with `visible: false` outside its range (a range between two blocks is two rules) | the part's children become one `variance` whose variants are the default lines and each block, by breakpoint, with `minWidths` for the notation's bounds |
| conditions it can say | every one a key's prefix takes (widths in pixels, breakpoints, orientation) | breakpoints only (with `minWidths`, one switch point per breakpoint); no orientation |
| the part's layout | the part lays its children out (hidden ones take no room: experiment 5) | a variant shows its first child, freely placed: the part's row or column must move into a node under the variance, splitting the part in two |
| renders today | yes: twins are what `hide=` and `show=` write (experiments 1, 5, 6) | yes: experiments 3 and 4 (`Variance` written by hand with its variants; the phone variant to 699, the wide from 700) |
| prints today | as twins, which expand to the same document (`print --check`: experiments 1, 5, 6) | as `Variance#bar … variants=[{…}]`, its variants as JSON |
| the editor | two layers with media rules | the editor's own notion of a part's responsive variants (DESIGN.md §5.3) |

What needs code is in the notation (the parser, the expander, the printer), not in the renderer: the base it goes
back to is the notation's grammar, one statement (`at`) and the meaning of `...` outside a definition. The only
renderer item the design might need is "the shown node of an id" for actions (3.5), and it is not needed to start.

## 4. The structural behaviours, in form A

Each behaviour the code does today at a width, and those `track-c` adds (its CHANGELOG's top entry, its
`reflow.dart` and `test/notation/reflow_track_c_test.dart`, and Desk's `TO-MOBILE.md` there), written in form A or
in today's words where values suffice. "Completely" means the fragment gives the same layout at every width; what
the code infers by itself (which lines, when) is listed beside.

| | behaviour | done today by | in form A | what is left to code |
|---|---|---|---|---|
| 1 | an App's first Sidebar is a drawer on a phone, opened from a menu button put in Main's bar | `page_words.dart` (the button, `sidebarMenu`, `_menuSize`), `notation.dart` (the `Drawer#<screen>_sidebar` overlay that repeats the Sidebar's lines) | **partly**: the window's phone design (Main alone, and the sidebar as a panel over it while a state is true) | the drawer as an overlay of its own (a canvas, focus held in it, the system back closing it: G6); every item closing it (the copied lines' actions rewritten); the button placed in another part's bar (decision 3) |
| 2 | a Nav's Links go into a menu on a phone | `page_words.dart` `_closing` (an `IconButton show=phone`, `if navMenu`, a Column of a row per Link) | **completely**, when the links are one line the writer names (`Row#links`) and their taps close the menu | finding the Links wherever they are in the bar (`menu=false` keeps one out): collecting lines |
| 3 | a window's foot is kept in view | `notation.dart` `_feet` (Main split into its sticky head, a scrolling column, the foot; a Footer written in App moved into Main) | **not at all**: it is not a width; it holds at every width | moving a line written in App into Main. The split itself is base lines a definition could write with a named slot (`...Foot`, note 23 G3, G4) |
| 4 | a row of controls with no room on a phone wraps (track-c) | `reflow.dart` | not needed: values (`phone.wrap=true`, `phone.w=fill` on the search, `hide=phone` on the spacer; experiment 7) | deciding that it has no room: a measurement |
| 5 | a Table leaves out the columns with no room (track-c) | the Table word and `reflow.dart` | **partly**: a fixed choice per width is a value on a column (`"hide":"phone"`); the table as a list on a phone is a block, **completely** | which columns fit beside a sidebar at 834: a measurement |
| 6 | a Sidebar is a rail on a tablet (track-c's `sizes.rail`) | `page_words.dart` (`railWidths`, `_railHide`), `reflow.dart` | **partly**: its width is a value (`tablet.w=64`) | each item showing its icon alone and a group label becoming a rule there: the item must know its sidebar is a rail at that width (G1, the frame it is in) |
| 7 | a list beside its detail is one at a time on a phone, with a back button (track-c for `Main w=380` beside a Pane) | `reflow.dart` (`ListDetail`), `notation.dart` `_listDetail` | **completely**, with the state and the row's tap the writer writes (as mail-client and notes-app did by hand) | finding the tap that selects a row and adding the step to it; the back button in the pane's own bar (a default placement); Escape and the system back (`blockBack`); the pane's enter animation |
| 8 | a page header's actions go under its title (Desk's PageHeader) | Desk's component | not needed: values (`phone.direction=vertical phone.gap=12`, experiment 7) | none |
| 9 | a bulk bar's actions go to a second line (Desk's BulkBar) | Desk's component | not needed: values (`phone.wrap=true`, or the direction) | none |
| 10 | a breadcrumb shows its last step (Desk's Breadcrumb, a tablet) | Desk's component | not needed: a bound value at a width (`tablet.visible={index == length(steps) - 1}`, experiment 7) | none |
| 11 | the reflow's value rules (a grid takes fewer columns, a headline smaller, a wide box fits, a Section's padding, an App drops its side panes, a Nav hides its links) | `reflow.dart` | not needed: values (`tablet.cols=2`, `phone.size=22`, `phone.w=fill`, `phone.pad=…`, `hide=tablet`) | choosing them for a page that says none: measurements and defaults |

Desk's track-c components (rows 8 to 10) were not read; their behaviour is taken from `TO-MOBILE.md`.

### 4.1 The fragments

**1. The App's drawer**, its window's phone design, the sidebar a panel over Main (the trigger placed by the
default rule, 4.2):

```notation
state appDrawer=false
App
  Sidebar#side
    NavItem "Inbox" icon="inbox"
    NavItem "Sent" icon="send"
  Main#main
    Nav
      Heading "Inbox"
    …
  at phone
    Stack w=fill h=fill
      ...#main
      if appDrawer
        Box w=fill h=fill fill=#66000000 onTap={appDrawer=false}
        ...#side
```

As a Stack in the page it is not the modal `Drawer` the code opens: no focus held inside it, no system back. The
code's version (an overlay canvas repeating the Sidebar's lines, each closing it) stays base.

**2. A Nav's phone menu**: the fragment of 3.4. Experiment 5 renders its expansion at 1440, 834 and 390.

**3. The window's foot**: no block. A definition of Main can write the split with base lines and a named slot for
the foot; the move of a Footer written in App stays code.

**4. A row of controls**, in values:

```notation
Row#filters gap=8 middle phone.wrap=true
  Input "" "Search name or email" w=280 phone.w=fill
  Select items=["All roles","Admin"] w=140
  Spacer hide=phone
  Text "12 of 50"
```

**5. A Table as a list on a phone**, its cells written once (Table's own code must pass the block by, section 7):

```notation
Table p in shown columns=["Name","Email","Role"]
  Text "{p.name}"
  Text "{p.email}"
  Text "{p.role}"
  at phone
    Column w=fill
      each p in shown
        Column w=fill pad=12 gap=2 border-bottom=#FFE5E7EB
          ...
```

**6. The rail**: the width only.

```notation
Sidebar tablet.w=64
  NavItem "Inbox" icon="inbox"
```

**7. A list beside its detail** (experiment 6 renders its expansion):

```notation
state reading=false
Row#window w=fill h=fill
  Column#side w=240 h=fill
    …
  Column#list w=380 h=fill scroll
    each m in mails
      Row pad=12 onTap={openId=m.id; reading=true}
        Text "{m.from}"
  Column#reader grow h=fill pad=24
    Text "{find(mails, 'id', openId).subject}"
  at phone
    if !reading
      ...#list
    else
      Column w=fill h=fill
        Row pad=8
          IconButton "arrow_back" tooltip="Back" onTap={reading=false}
        ...#reader
```

The `if` here is under the block, not over it: it is a state's condition inside a width's design, which is allowed.

**8 to 10** (values):

```notation
Row#header w=fill between middle phone.direction=vertical phone.gap=12
  Text "Members" size=28
  Button "Invite"
Row#crumbs gap=6
  each s in steps
    Text "{s}" tablet.visible={index == length(steps) - 1}
```

### 4.2 The default rule for a trigger (decision 3)

Today, an App whose first pane is a Sidebar and that has a Main gets one `IconButton "menu"` (role `appmenu`) at
the start of Main's first top bar (`Nav`, `TopBar`, `Header`, `AppBar` and their synonyms, `PageWords._bars`) when
that bar is Main's first line; else a slim `Row w=fill middle pad=[12,8,12,8]` holding the button, and a `Divider`,
put at Main's top (`page_words.dart`, the lines writing `IconButton … "menu" … onTap={open $sidebarMenu}`). It shows
where the sidebar does not: on a phone, or on a tablet too when two panes stand before Main and take more than 420
(`_menuSize`). A list beside its detail gives the panes before Main a copy of that button (`notation.dart`,
`_listDetail`). A page that writes its own `Drawer` line, or `App keep`, gets neither.

The note keeps this rule as it is. Form A writes the window's design at a width; where that design leaves the first
Sidebar out, the drawer and its button come by the rule, and the writer names no place. Whether a block that shows
the sidebar itself (fragment 1) still gets them is question 4.

The writers of round 11 who wrote their own menu put the button where the row it replaces was (section 2.1). For a
Nav that is the rule the code has (the button at the bar's end, in place of the links); for an App's sidebar the
button goes to another part, which is why it needs a rule.

## 5. What stays base, and its word

With form A, what remains code is what no design at a width can say, because it is not a design: it measures, it
collects or rewrites other lines, it places a line in another part, or it is a presentation.

| behaviour | why it stays code | its word |
|---|---|---|
| the App's drawer: the copy of the Sidebar in an overlay, its items closing it, the button in Main's bar | a copy into another canvas, a rewrite of the copied lines' actions, a placement in another part (decision 3); the overlay itself is G6 | `App` (and `Sidebar`): "the first Sidebar of an App is a drawer where it does not fit" |
| the Nav's menu built from its Links wherever they are | collecting lines (and leaving out `menu=false`) | `Nav`: "a Nav's Links are a menu on a phone" |
| the window's foot | moving a line written in App into Main | `Footer` in an App: "kept in view" |
| a row with no room wraps; a table keeps the columns that fit; a grid takes fewer columns; a headline smaller | measurements of a page that says nothing at that width | the reflow's own (no word: it is the default) |
| a list beside its detail, wired | finding the tap that selects and adding to it; Escape and back | `Main` beside a `Pane` |
| a sidebar's items as a rail | an item knowing the frame it is in (G1) | `Sidebar` at a width |

Each keeps its word, as decision 4 says: the word is what a writer writes to get the behaviour without writing it.
What form A adds is that each word's meaning can now be written down as the design it gives (sections 4.1 and 8),
so the word's documentation is a block, and a writer who wants another design writes their own block under the
part. A block of the writer's turns the word's own behaviour off for that part, as a writer's rule turns the reflow
off today (question 4 asks how far).

## 6. A bug the experiments found

**A Nav that writes its own menu button gets the code's too.** The reference (`responsive.md`) and the prompt
(`prompt.dart`: "a Nav with a show=phone line of its own keeps yours instead") say a Nav that writes a `show=phone`
line keeps its own menu. The code tests `RegExp(r'\sshow:(phone|tablet|mobile)(\s|$)')` (`page_words.dart`, where
it sets `ownMenu`), with a colon; the notation writes `show=phone`. Experiment 8: a Nav with three Links and
`IconButton "menu" show=phone onTap={open navSheet}` expands to two menu buttons that show on a phone (the
writer's and the code's) and the code's `navMenu` column. Fixing it changes the picture of every page that wrote its
own menu button in a Nav (one button where there were two): question 8.

## 7. What it does to note 23's plan

| | note 23's reason | with form A |
|---|---|---|
| G1 | reads the line it is under (the frame) | unchanged. The rail (row 6) shows G1 meeting a width: an item's look depends on its sidebar being a rail at that width |
| G2 | works a value out as the use is read | unchanged |
| G3 | sends a use's words elsewhere than the root | unchanged; `...#id` is a named place for a *line* under the use, not for a word |
| G4 | writes two lines where one is written | unchanged |
| G5 | marks the frame for the reflow (roles) | **shrinks**: a definition that writes its own widths (values, or a block) needs no role for them, and the reflow leaves it. The roles stay for parts that say nothing at a width |
| G6 | a block of its own (overlays) | unchanged; form A offers an in-page panel (fragment 1) beside the overlay, not in its place |
| G7 | stands for a statement | unchanged |
| G8 | reads, counts or moves other lines | **splits**: the Nav's phone menu and the list beside its detail become designs at a width (data) once the lines they use are named; the drawer's window design too. What collects (the Links wherever written, the selecting tap), copies into another canvas (the drawer), or moves (the foot) stays base. "The n-th line under the use" (G8's other half, for Table) gets a neighbour: `...#id`, a line under the part by its id |
| G9 | reads the theme | unchanged |
| G10 | writes outside its lines | unchanged |

**Words that could move to the dictionary sooner**, once `at` is in `define` (stage 2):

- **Nav**, its phone menu as a block, if the owner accepts that the menu shows the links as written (quiet buttons
  in a column) and not the rows the code writes (`Row pad=[12,10,12,10]` with `Text.strong`): the closure test of
  note 23 compares documents, and these differ.
- **Section**: its tablet and phone padding as values in its definition (`tablet.pad=… phone.pad=…`) instead of the
  role mark the reflow reads. This needs no form A and could be tried now; it was not tested.
- **Table**'s phone list (fragment 5) as an optional design, beside the columns that fit, which stay code.
- Desk's **PageHeader**, **BulkBar** and **Breadcrumb** narrow forms are values (rows 8 to 10): as notation
  definitions they need no form A.

## 8. Cost and order

### 8.1 What each part needs

| part | what it needs | size |
|---|---|---|
| parser (`notation.dart`) | the statement `at <condition>` under a node line (its condition read by `mediaCondition` of `media_words.dart`, as `<condition>.x`); the block's lines kept with the part; `...` and `...#id` outside a definition, as copies of the part's lines already read (the drawer already feeds a part's kept lines again, ids taken off: `_pages.sidebar`); the issues of 3.2 and 3.6 | medium |
| expander | the rules of 3.8 (default lines hidden where a block holds, a block's lines hidden outside its range); copies' ids (`<id>_<width>`) and actions per copy; a definition's state names kept in its copies; the block kept from the reflow and the expander's own hide rules not counted as the writer's (`PageReflow._own`, `kept`); in a canvas stream, the default lines' rules sent as patch ops when the block arrives (as the reflow sends its rules) | medium |
| page words (`page_words.dart`, `table_words.dart`) | each word that reads its lines passes a block by or reads it: a Table's cells, a Nav's Links, the Sidebar kept for the drawer, a Pane counting whether Main came first | small to medium |
| `define` (`define.dart`) | `at` in `_statements`, so a body passes it through; `...` in a body's block is the use's lines again (today a slot is filled once, as the lines arrive: a second `...` replays them after the use closes) | medium |
| printer (`print.dart`, `print_media.dart`) | stage 1 none: it prints twins, which expand to the same document. To print the block back: a mark on the block's root (proposed: its `name`, `at phone`, which the editor shows as the layer's name; question 6), and a copy recognised as `...#id` when it equals its default line up to ids and width rules | medium |
| reference (`tool/reference/templates/notation/responsive.md`, `NOTATION.md`) | a section "A design at a width" with examples written ```` ```notation expands ```` (the generator checks they expand), one sentence in "Pages at other widths" | small |
| prompt (`prompt.dart`) | one sentence and one example in the widths paragraph: the twins writers write (201) become a block | small |

### 8.2 In stages

1. **On a page.** `at <condition>` under a node line, the children at that width; `...` and `...#id`; the twins
   expansion; the reflow leaves the block; the issues; the reference section and the prompt's sentence. The printer
   prints twins. Useful at once: the 82 structure twins and the hand-written panes of round 11 become one part each.
2. **In `define`.** A body's block; `...` the use's lines again; the page words that read their lines pass a block by.
3. **Printed back.** The mark and the copy recognition; `print --check` over every corpus.
4. **The words' designs as definitions.** Nav's menu, Table's phone list, a list beside its detail, each closure
   tested as note 23 did; the phone behaviours keep their names, their code reduced to what section 5 lists.
5. **A variance, if wanted** (question 2): the same blocks expanded to a responsive `variance`, for the editor.

### 8.3 What proves no existing document changes

- `at` is refused today (experiment 9: "No node type "at""), and `...` outside a definition is not a line: a text
  that expands with no issue today has neither, and its document is the same. A test reads every text of the
  corpora with the old and the new parser and compares the documents node by node, at 1440, 834 and 390 (the
  harness of note 23, `tool/corpus_closure.dart` and `tool/dictionary/closure.dart`, with no rename): the first
  corpus, round 10's quoted notation, round 11's pages and components (699 files), the reference's examples, Desk's
  and Cards' examples and definitions.
- The API's tests, `notation_coverage` (real gaps 0) and `print --check` over the same corpora.
- For stage 2, every definition of the design systems expanded before and after (`checkDefinitions`).
- The SDK's renders of the corpora at the three sizes, compared pixel for pixel.
- New tests for the new lines: each issue of 3.2 and 3.6; the rules of 3.8 at 390, 699, 700, 834, 1023, 1024, 1440;
  ids of copies; a binding shared; a definition's state shared by its copy; the reflow leaving a block and
  fitting the default lines.

## 9. Questions for the owner

1. **What a block replaces.** (a) The part's children, its own line holding at every width (proposed, 3.3); (b) the
   part itself, as the writers' twins do (a Grid that is a Column on a phone in one block). Recommendation: (a). The
   parts that differ most are frames whose own line other lines and the reflow read; (b) loses their padding, role
   and id at a width, and 15 of the 82 structure twins of round 11 are a Row or a Grid against a Column, which a
   value says.
2. **The document form.** (a) Twins with media visibility (proposed first: every condition, renders and prints
   today); (b) a responsive `variance` (the editor's own form, breakpoints only, the part split in two).
   Recommendation: (a) now, (b) when the editor should show a part's designs as its variants.
3. **How a block names a default line.** (a) `...` and `...#id` only (proposed); (b) also by word (`...Link`, every
   Link under the part). Recommendation: (a). (b) is collecting lines, which is what the Nav's code does and what
   stays base.
4. **A writer's block under App or Nav.** Does it turn the word's own phone behaviour off? Recommendation: it turns
   the reflow and the word's own layout at that width off for the part, as a writer's rule does today; the drawer and
   its button stay unless the block shows the Sidebar itself (`...#side`) or the page writes its own `Drawer`.
5. **An action naming a copied id** (`focus`, `scroll`). (a) Written once per copy (proposed for stage 1); (b) a
   runtime "the shown node of this id" (base code). Recommendation: (a), and (b) only if the hidden copy's action
   is found to do something.
6. **The mark that prints a block back.** (a) The block root's `name` (`at phone`), shown in the editor as the
   layer's name (proposed); (b) no mark: documents print as twins, and the block form is lost on a round trip
   through the document. Recommendation: (a).
7. **Teaching.** Teach `at` in the prompt from stage 1, or after the printer (stage 3)? Recommendation: from stage 1,
   one sentence and one example, and measure in the next round whether the 201 twins become blocks.
8. **The Nav menu bug** (section 6). Fixing it gives one menu button where pages that wrote their own show two.
   Recommendation: fix it.

## 10. What is not verified

- Nothing of form A is implemented. Its expansions were written by hand in today's words (experiments 5 and 6) and
  expanded, printed back and rendered; the parser's, the expander's and the printer's costs are estimates from
  reading the code.
- Whether a hidden twin keeps its widget's state (a text field's caret, a scroll position) was not checked: the
  renderer draws nothing for an invisible node (`node_tree.dart`, `drawn`), whether it keeps its subtree was not
  read. What an action does to a hidden copy (3.5) was not tested.
- The renders are of small pages (three, at 1440x900, 834x1112 and 390x844, and the variance at 650, 699 and 700
  wide), read from their outlines; no pixel comparison, no state driven (no tap opened the menu or the detail).
- The variance was tested with text children only: no `each`, no state, no actions inside it, not under the reflow.
- The counts are of round 11's final pages and components (not `drafts/`); the twin pairing is a heuristic (2.1).
  The web counts read CSS declarations by name inside `@media` blocks about width; markup twins are counted by class
  names containing a width word.
- `track-c`'s Desk components were not read; rows 8 to 10 of section 4 take their behaviour from its `TO-MOBILE.md`.
- `if phone` was rejected partly on six builds that bind a variable named `phone`; whether a model taught `at` writes
  it is not known until a round measures it.

## 11. Appendix: the experiments

Run from `CodelesslySDK` (36.0.0, `b2cccb8b`, its API the `track-b` checkout) with `tool/notation/notation.sh expand
<file> --width 1440 [--open] --out <json>`, `notation.sh print <json> [--check]` and `tool/codelessly render <folder>
--outline --sizes …`. Inputs in `docs/design/a-design-at-a-width/experiments/`.

| | input | what it showed |
|---|---|---|
| 1 | `twins.txt`: a bar as a Row (`hide=phone`) and as a Column (`show=phone`) under one parent, both binding `@q` | the default line gets `{"maxWidth": 699, "patch": {"visible": false, "bind": {"visible": null}}}`, the phone line `{"minWidth": 700, …}`; both inputs bind `${q}`; `print` gives the twins back and `--check` reads back the same (12 lines) |
| 2 | `sameid.txt`: the same `#title` in both twins | an issue: "The id "title" is used twice: line 3 has it too. Give this line an id of its own." |
| 3 | `variance_document.json`, printed | `Variance#bar w=… minWidths={"tablet":700} variants=[{…}]` with its children under it: the printer writes a variance's variants as JSON |
| 4 | `variance_hand.txt`: a `Variance` line written by hand, expanded and rendered | expands to a `variance` node with its variants and children; renders the phone variant at 390, 650 and 699, the wide one at 700 and 834 |
| 5 | `nav_menu.txt`: fragment 3.4 expanded by hand (twins, copies `_phone`) | no issue; `--check` reads back the same (21 lines); at 1440 and 834 the brand and the links, the phone column 0x0; at 390 the links and brand 0x0 and the phone bar 342 wide: hidden twins take no room in a `between` row |
| 6 | `list_detail.txt`: fragment 7 expanded by hand | no issue; `--check` the same (22 lines); at 390 the list alone, 390 wide; at 834 the reader is 214 wide: the panes' `hide=phone` rules made them the writer's, and the reflow left them (3.7) |
| 7 | `values.txt`: `phone.wrap=true`, `tablet.visible={index == length(steps) - 1}` under an `each`, `phone.direction=vertical` on a Row | each becomes a media rule (`{"props": {"wrap": true}}`, `{"bind": {"visible": "${= index == length(steps) - 1}"}}`, the Row read as a `flex` with `{"direction": "vertical", "spacing": 12}`); `--check` the same |
| 8 | `navplain.txt`, `navown.txt`: a Nav with three Links, without and with `IconButton "menu" show=phone` | without: one menu button (`minWidth: 700` hidden) and the `navMenu` column; with: two menu buttons shown on a phone, and the `navMenu` column (section 6) |
| 9 | `atnow.txt`: `at phone` and `...` under a Row, today | "No node type "at"" and "A line starts with a node type" (the `...`): refused, so no clean text today holds either |

`COUNTS.md` is `python count_widths.py <dsl-api-11 folder>`, over round 11 at `wt-r11/x/experiments/dsl-api-11`.
It lists every twin, the structure twins, the `if` lines over width states, the `screen.width` lines and the web
counts behind section 2.

## 12. As built (stage 1, and stage 3's printer)

Questions 1, 3 and 7 as recommended: a block replaces the part's children, a default line is named by its id only,
and the prompt teaches `at` (one sentence where widths are taught). Where the build differs from the sections above:

- **Conditions.** Widths in pixels, the size words and orientations. A breakpoint by its name (`at minTablet`) is
  an issue for now: a block's lines are hidden outside its range by the complement of each bound (`at
  min700.tablet` is hidden at `max699` and at `min1024`), which a breakpoint's name cannot say.
- **The reflow and the part (3.7).** The block's lines are kept (none of the reflow's rules), the expander's hide
  rules on the default lines do not count, and neither does a rule of a default line (or of a line under it) that
  holds only where a block holds (`phone.w=fill` on a line a phone shows by `...#list`): with it, a window written
  as experiment 6's drops its first pane at 834, and the list and the reading pane share the rest. The part itself is not left alone: what the
  reflow gives it to fit its default lines (a row that wraps on a tablet) stays, and a rule after it undoes it where
  a block holds. A window's pane (`Sidebar`, `Main`, `Pane`) keeps the reflow's rules whole, so a Sidebar with a
  block is still hidden on a phone, where its drawer is.
- **Page words (section 7's "pass a block by", done for stage 1).** A website's `Nav` (`Header`, `TopBar`) with a
  block writes no menu of its own; a block there that does not hold on a phone is an issue (the phone is where the
  Nav's menu is). A `Table`'s block goes in its frame, its header and rows being its default lines, and `...` is
  its cells as written (fragment 5 renders). An app's first `Sidebar` with a block keeps its drawer, which repeats
  its own lines, not the block's. `App` with a block is an issue (question 4 is not built: its panes, drawer and
  button are code that copies and places lines), as are `Grid` (its lines are cells), `Pages` and a line with
  slots.
- **Copies.** A defined word's use read again keeps its state: its copy is named after the use (`<use id>_<width>`,
  or the use's own made-up id when it has none) and the state its copy declares is renamed back to the use's.
  The vocabulary record is the line's own: the copy is not recorded again, and what a copied line has wrong is said
  once, on its own line. A `...#id` whose line has a block of its own is said (that block is not read again: a
  block inside a block).
- **Actions per copy (question 5).** `focus` and `scroll` naming a copied id are written once per copy, after the
  original; an action already followed by its copies (a print read back) is not doubled. Rendered: `key mod+k
  onPress={focus search}` focuses `search` at 1440 and 834 and `search_phone` at 390; the hidden copy's focus
  does nothing.
- **Focus, caret and scroll across a bound** (a widget test resizing one session: CodelesslySDK
  `test/notation/at_width_test.dart`). The text typed is kept (both copies bind it). Narrowed to a phone, the shown
  copy has no focus, its caret is at the end of the text and its list at the top; the hidden field loses the focus.
  Widened again, the desktop's field has no focus but keeps its own caret where it was left, and its list keeps
  its scroll position (a hidden node keeps its state).
- **Printing (stage 3).** The mark is the block's first lines' `name` (`at phone`), set only on a line with no name
  of its own. A copy prints as `...#id` (or a run of them as `...`) when it equals its default line up to its ids
  and its own size (a row placed in a column fills it), and the print, read back, gives the document; otherwise
  the copy is written out, and a part whose blocks do not read back prints as twins.
- **Streams.** A block is read when the next line not indented past it arrives: its rules and the default lines'
  are sent then as patches.
- **Section 6's bug** was fixed before this build (37.0.0): experiment 8's Nav with its own `show=phone` menu
  button expands to that one button and no `navMenu` column.
