# Responsive

A line's keys at other widths (media rules), the named sizes, breakpoints, and the looks of a line's states. Open
it when a page must work on a phone, a tablet and a desktop, or a line looks different while hovered or pressed.

## Keys at other widths

A key with a condition before it holds only where the condition does: `phone.pad=16`, `tablet.direction=vertical`,
`max899.hidden`, `minDesktop.visible=true`. The key after the condition is any key the line reads, its value as
the line writes it. Keys with the same condition are one rule; rules hold in the order written.

{{mediaSizes}}

The other conditions:

- `min700`, `max899`: a width in pixels (from, up to).
- `minTablet`, `maxMobile`: from a breakpoint's width, or up to the next one's.
- `portrait`, `landscape`: the orientation.
- Conditions combine: `min700.tablet.size=14` holds from 700 to the tablet's upper bound.

```notation
Column gap=24 pad=48 phone.pad=16
  Text "Wide" phone.size=14 hide=tablet
  Text "Narrow only" max899.hidden
  Text "From a tablet up" minTablet.size=20
  Text "Upright" portrait.size=12
```

`hide=phone` leaves a line out on a phone, `hide=tablet` on a tablet and a phone; `show=phone` shows it on a
phone only. `tablet.hidden=true` (or `tablet.hidden`) is `hide=tablet`. A Row that is a column at some width is
written `Row … phone.direction=vertical` (it is read as a `Flex`, which takes `scroll` and the alignment words too;
`phone.axis=vertical` and `phone.direction=column` are the same rule). A child of a Row written as wide as its place
at a width (`Column w=345 phone.w=fill`, `Select w=180 phone.w=fill`) says the same of its row: there the row is
laid out down the page, each such child and each child that grows on a line of its own, the buttons and labels
between them sharing a line.
A line shown only on a phone under a bar (`Row#phoneSearch show=phone` for the field the bar hides there) is a band of
its own: give it the bar's `fill=` and move the bar's `border-bottom` onto it, or write it inside the bar's column,
so the field sits in the bar and not on the page's background.

A tap that does different things at different widths reads the window in its action: `onTap={screen.width < 700 ?
open detail : picked=item.id}` opens a sheet on a phone and fills the pane beside the list on a desktop.

What the device covers is read the same way: `screen.insets.top` (and `.bottom`, `.left`, `.right`) is the safe
area (a status bar, a home indicator), `screen.keyboard` how much of the page the soft keyboard still covers (0
while it is closed), `screen.textScale` the device's text size setting. A full-screen page makes room for the
keyboard by itself (it lays out above it, as Flutter's Scaffold does, and keeps the focused field in view), so a bar
at its foot rests on the keyboard with nothing written, and there `screen.keyboard` reads 0 and the home indicator's
inset is 0 under it. Where the page does not make room (it is not full-screen, or the host handles the keyboard), the
keyboard's height is read. So a box under the bar of `screen.keyboard + screen.insets.bottom` clears the home
indicator while the keyboard is closed and rests the bar on the keyboard in both cases, never lifted twice.

```notation
state draft=""
Column h=fill
  Column h={screen.insets.top}
  Column scroll h=fill grow
    Text "The thread"
  Row gap=8 pad=[12,8,12,8] border-top=#FFE5E7EB
    Input "" hint=Message grow @draft
    IconButton "send"
  Column h={screen.keyboard + screen.insets.bottom}
```

## A design at a width

Where a part's lines differ at a width, and not only its values, write `at <width>` under the part, after its own
lines: the lines under it are the part's children where the width holds, and its own lines show everywhere else.
The part's own line (its id, its keys, its events) holds at every width; its values at a width stay keys on it. The
width is any condition a key's prefix takes: `at phone`, `at tablet`, `at desktop`, `at max899`, `at
min700.tablet`, `at portrait` (`at mobile` is `at phone`).

In a block, `...` is the part's own lines, in order, and `...#links` the one of them with that id, with the lines
under it: content written once and placed again. A bar whose links are a menu on a phone:

```notation width=1280 expands
state navMenu=false
Column#bar w=fill pad=[24,14,24,14]
  Row#top w=fill between middle
    Text#brand "Acme" size=18 weight=700
    Row#links gap=24 middle phone.direction=vertical phone.gap=4
      Button.ghost "Pricing" onTap={navMenu=false; scroll pricing}
      Button.ghost "Docs" onTap={navMenu=false; scroll docs}
    at phone
      Column w=fill gap=8
        Row w=fill between middle
          ...#brand
          IconButton "menu" tooltip="Menu" onTap={navMenu=!navMenu}
        if navMenu
          ...#links
  Column#pricing w=fill pad=48
    Text.title "Pricing"
  Column#docs w=fill pad=48
    Text.title "Docs"
```

A list beside its detail that a phone shows one at a time, with your own state and back button:

```notation width=1280 expands
state mails=[{"id":"a","from":"Maya","subject":"Roadmap"},{"id":"b","from":"Dev","subject":"Invoice"}]
state openId="a"
state reading=false
Row#window w=fill h=fill
  Column#list w=340 h=fill scroll phone.w=fill
    each m in mails
      Row w=fill pad=12 onTap={openId=m.id; reading=true}
        Text "{m.from}"
  Column#reader grow h=fill pad=24
    Text.title "{find(mails, 'id', openId).subject}"
  at phone
    if !reading
      ...#list
    else
      Column w=fill h=fill
        IconButton "arrow_back" tooltip="Back" onTap={reading=false}
        ...#reader
```

- Several blocks hold in the order written, the later winning where both hold, as rules do: write the wider first
  (`at tablet`, then `at phone`). A width no block holds shows the part's own lines, never another block's. A block
  a later one holds wherever it does is never shown, and is said.
- A line `...` brings is the line as written, with its keys at other widths: `phone.w=fill` on the list above
  holds where the block shows it. Nothing is written on a `...` line; what differs is written on the part's own
  line with a prefix, or the line is written out in the block.
- It is a second node: its id is `<id>_<width>` (`links_phone`, `search_min700_tablet`), and an action that names
  the id (`focus search`, `scroll pricing`) is written for each, so it reaches the one shown. A binding (`@q`) and a
  defined word's own state are shared by both: what is typed on a desktop is there on a phone. The focus, the caret
  and a scroll position are the node's: a window that crosses the width shows the other node, without them.
- Reflow leaves a block's lines as written. The part's own lines are still fitted where no block holds (a window's
  side pane dropped on a tablet), and what reflow gives the part for them (a row that wraps) is undone where a block
  holds. A rule of one of its own lines that holds only where a block does (`phone.w=fill`) is the copy's, not a
  rule that makes the line yours.
- Under a website's `Nav` a block that holds on a phone is the bar there: the Nav writes no menu of its own. Under
  a `Table` the block's lines go in the table's frame in place of its header and rows, and `...` is its cells (a
  list of cards on a phone: `each p in people` / `Column … ` / `...`). An app's `Sidebar` with a block is still its
  drawer on a phone, with its own lines.
- The part is laid out by its own line where a block holds too: a `Row`'s block lines are side by side, as its own
  are, and no longer wrap (reflow leaves them as written). For lines down the page there, write them in a `Column`
  in the block (as the bar above does), or give the part's line the direction at that width
  (`Row gap=12 phone.direction=vertical`).
- Not read, and said: `at` at the margin, under an `each` or an `if` (write it under the line the `each` repeats,
  each row's design at that width), inside another block, under `App` (write it under the pane whose lines
  change), under a `Grid` (its columns at a width are `phone.cols=1`), a breakpoint by its name (`at minTablet`:
  write the width in pixels), and a part's line written after its blocks.
- A document's block prints back as the block: its first lines are named for it (`at phone`, the layer's name in
  the editor), and a line that is one of the part's own read again prints as `...#id`. Lines written as twins
  (`hide=phone` beside `show=phone`) print as twins.

### A word's own design at a width

A definition (a page's `define`, a file of a site's `components`, of a dictionary or of a design system) writes
`at <width>` under any of its node lines (its first line, for the whole word), as a page does: every use of the
word then has that design at that width, with nothing written where it is used.

```notation expands
define Product "title" "price" photo
  Column gap=8
    Image#photo "{photo}" h=160 w=fill radius=8
    Column#words gap=2
      Text.strong "{title}"
      Text.muted "{price}"
    at phone
      Row gap=12 middle
        Image "{photo}" w=72 h=72 radius=8
        ...#words
Grid cols=3 gap=16 phone.cols=1
  Product "Kettle" "$48" photo="https://picsum.photos/seed/kettle/400"
  Product "Mug" "$14" photo="https://picsum.photos/seed/mug/400"
```

- In a block `...` and `...#id` mean what they mean on a page: the lines of the part the block is under, read
  again. The lines a use writes under the word are among them where the definition has its slot, so a block
  brings them again with `...` (or with `...#id` of the line the slot is under). A slot itself (`...` for the
  lines under a use, `...Name`) is written among a part's own lines, never in a block.

```notation expands
define Shelf "title"
  Column gap=12
    Text.heading3 "{title}"
    Row#items gap=16
      ...
    at phone
      Column gap=8
        ...#items
Shelf "New"
  Text "Kettle"
  Text "Mug"
```

- The word's parameters read in a block as in its other lines (`"{title}"`). A line read again is the same use:
  its state and the value it binds are the use's own, one for both designs, its id is the use's with the width
  after it (`words_product1_phone`), and an action of the word that names the line (`focus`, `scroll`) reaches the
  one shown.
- A word with a design at a width may be used in a block, of a page or of another word, and be read again by one:
  it has its own design there too. Printed, such a part inside a block is its lines side by side
  (`hide=phone` beside `show=phone`).
- What is wrong in a definition's block is said once, with the file and line of the definition: a block at the
  margin of the definition, a block inside a block, a slot or other words on a `...` line of a block, a `...#id`
  no line of the part has (or written outside a block), a line after the part's blocks. What depends on where the
  word is used (a width that is none, a part that takes no block) is said with each use, and the block's lines are
  passed over: the part shows its own.
- A block of the page written under a line that a word's block reads again (the lines a use gives a slot) is not
  read again with it, and that is said: a block is not written inside a block.
- A block the page writes under the use itself, where the word has a block of its own for the same part, is the
  page's design of that use: where it holds it is the one shown, and the word's own block is not.

## What reflow does

A page written for a desktop (expanded at 700 wide or more) is given rules of its own for a tablet (up to 1023)
and a phone (up to 699): reflow is on unless the expander is run with `--no-reflow`. It works like a website's
defaults:

- A band of blocks (cards beside cards, content beside a rail) wraps; a grid takes fewer columns (one whose
  columns are worked out, `Grid cols={zoom}`, at most three on a phone); a headline gets
  smaller; a box wider than a phone fits it; a table's columns share the row, and a phone keeps the ones it has
  room for. A Row of copies an `each` repeats (`Row gap=5` over `each d in
  days` / `ChoiceChip …`) wraps them onto further lines on a tablet or a phone, on the page and in a dialog over it
  (`Row scroll` keeps them on one line that scrolls; `keep` as written). A Row written `wrap` with an `each` and
  other lines (chips of labels, chips of people, a count) wraps them all there, each list a group of its copies.
- A row never squeezes what grows in it to nothing. On a phone a column of text that grows keeps the width its
  words need (up to 200; a text alone up to 160): two columns of paragraphs side by side take a line each, a
  heading beside a box of figures goes above it. Copies that grow from a least width in a row written `wrap`
  (`Row wrap` over an `each` of `Card basis=265 grow`) are as many equal columns as fit at that width, at every
  window; `phone.basis=300` on the copy is the least width there. The cells of a `Grid` that are as tall as their
  row are as tall as themselves where the grid wraps.
- A page's bar (its first `Nav`) is one line on a phone: the brand, the icon buttons, and a menu button that
  opens its links in a column under the bar. Its other labelled buttons stay in the bar where they fit beside the
  brand (a short name and one button); where they do not, they are in the menu too (a button keeps its kind
  there, as wide as the menu). A bar whose links are in its menu does not wrap. A bar with no links
  folds nothing and has no menu button. A button that says where it shows (`hide=tablet`) or stands under an `if`
  is left to that; a line written `show=phone` in the bar is your own menu, and none is made. A `Nav` written
  among the lines of a defined word is the page's bar all the same. A second `Nav` in a page is a strip of the
  page's own (an article's tabs): it keeps what is in it and scrolls sideways where that has no room.
- A `Table` leaves out, at a tablet's and at a phone's width, the columns its row has no room for, from the last
  back (beside the app's sidebar as wide as it is there); its first column, the row's checkbox and a narrow column
  with no label (a row's menu) stay; on a phone a wide column of data (150 or more) narrows to 90 before it is left out. A column
  you leave out yourself (`"hide":"phone"`) is out there, and the others are still fitted to the room left, so
  the column that grows always has its width. A row written in a cell with a part that grows (`Row` /
  `Column grow` / `Icon`) is as wide as the cell.
- An app's window stays a window. A Row that fills the height (`h=fill`, or `grow` in a column) with one pane that
  grows beside panes of a fixed width (a sidebar, a list, an inspector) is laid out as `App` is: a tablet drops
  the fixed panes after the one that grows, a phone shows that one alone. It is never wrapped or stacked. A list
  written as `Main w=380` beside the `Pane` that shows what its rows select is a list beside its detail: both
  where there is room, one at a time on a phone with a back button (with no tap that selects, the list alone).
  A `Sidebar` or `Pane` whose width is kept in a variable (`Sidebar w={sidebarWidth}`, sized by a `Splitter`) is
  a pane of a width of its own, hidden where one of a written width is. The button that opens the sidebar's
  drawer goes in Main's own bar wherever that is written under Main; where you write a button of your own for a
  narrow window (`IconButton "menu" show=phone onTap={open nav}`), no button, bar or drawer is made.
- A Row keeps its line when it has a height of its own (a toolbar, `h=56`), is a row of a list (under an `each`,
  in a `ListView`), sits in something of a fixed width a phone holds (a 232 sidebar, a 96 track head) or in a Row
  that scrolls sideways, or holds only labels and buttons inside an app's window. A row of an app's pane whose
  parts keep more width than a phone has (a filter bar of a search, selects and a count; a top bar's title
  beside a search and a button) wraps there: a field of a fixed width takes a line's share, a spacer goes.
- What you lay out by width is yours: a line with its own rules (`tablet.w=64`, `hide=phone`, `phone.pad=8`) gets
  none of reflow's over them, and a Row whose own line or a line right under it has such rules is not wrapped
  (but for the phone's wrap above, when its parts still have no room there). A width rule on a line whose width
  is bound (`w={listW} phone.w=fill`) holds where it says: the binding is the desktop's.
- A design system with a rail (`sizes.rail` in its theme, Desk's 64) makes an app's `Sidebar` written with no
  rule for other widths a rail that wide on a tablet, its words folded to their icons, and the drawer on a phone,
  when every line under it folds by itself there. A line folds when it is a component that declares a `rail`
  parameter (the design system's `NavItem`, `Brand`, `Account`; a site's own component with `param rail:bool=false`
  that shows its icon alone when `rail` is true), takes no width of its own (`Spacer`, `Divider`), or says what it is at
  that width itself (`hide=tablet`, `show=desktop`, `tablet.…`, `max899.…`: it and the lines under it are then
  yours). The sidebar's `Footer`, a plain `Column`, an `if`, an `each` and a defined word hold lines, and fold when
  their lines do; under an `at tablet` block, the block's lines are the ones read. A line written by hand that
  only shows something (a `Box` with a note in it, a `Text` group label, a `Row` of an `Avatar` and two texts:
  plain words with no event, no value held, no drag) is hidden where the sidebar is a rail, and shown again in
  the phone's drawer. With a line written by hand that does something (a `Row` of an `Icon` and a `Text` that is
  tapped, a field, a list of the writer's own rows, a defined word that is such a row, a component with no `rail`
  parameter) the sidebar is no rail: a label has no room in 64, and as wide as written it took a third of a
  tablet's window, so it is the drawer there, as on a phone, opened by the menu button in Main's bar. To make such
  a sidebar a rail, write its width there and what each line does (`Sidebar tablet.w=64 hide=phone`, the labels
  `hide=tablet`); to keep it as wide as written, write that (`Sidebar tablet.w=240 hide=phone`).
- A component that declares `rail` is told where its sidebar is a rail: wherever an app's `Sidebar` is narrower
  than 120 (the design system's rail, your own `tablet.w=64`, or a sidebar written `w=64`), each such component
  under it has `rail` true there, as if its line said `tablet.rail=true`. So a component folds on `props.rail`
  alone, never on the window's width: in a drawer (a phone's, or a tablet's where the sidebar is no rail) its
  words are whole. A line that says `rail` itself (a value,
  a binding such as `rail={folded}`, a rule) keeps what it says.
- `keep` on a line (`Row#window keep`) leaves it and everything in it as written at every width (a child written
  `phone.w=fill` still turns its row there: that is what the line says).
- A text never breaks inside a word. Where its box is narrower than its longest word the text is drawn smaller so
  that the word fits, down to 65 % of its size; a word still too long keeps its line and fades out at the box's
  edge. A text of one line with `overflow=ellipsis` ends in the ellipsis as before. The label of a button, a tab
  or a chip is one line and is never broken.
- An `App` whose first pane is a `Sidebar` and that has a `Main` gets a menu button at the start of Main's top bar
  (a slim bar of its own when it has none), shown where the sidebar is not, and a drawer that repeats the
  Sidebar's lines (its look, none of its rules for one width: `tablet.w=64 hide=phone` stay the rail's). With a
  pane between the sidebar and Main (a list beside its detail), or a design system's sidebar whose lines do not
  fold into its rail, a tablet drops the sidebar and shows the button too; a rail stays, and the button is the
  phone's only. A page that writes
  its own `Drawer` line, or `App keep`, gets neither.

Write the rules you want where reflow's default is not the one: they win, and they turn reflow off for that line.

A desktop page that changes at a tablet's width and again at a phone's: the side-by-side `Flex` turns into a
column and closes up, the side panel leaves, the title and the margins get smaller on a phone.

```notation width=1280 expands
state projects=["One","Two","Three"]
Flex direction=horizontal gap=32 pad=48 tablet.direction=vertical tablet.gap=16 phone.pad=16
  Column gap=8 grow
    Text.title "Projects" phone.size=22
    Grid cols=3 gap=16
      each item in projects
        Text "{item}"
  Column w=280 hide=tablet
    Text.heading "Filters"
```

## Breakpoints

{{breakpoints}}

## States

A line's look while it is hovered, pressed, focused, selected, disabled or dragged is written as a key at another
width is, the state's name before the key: `hovered.fill=#FFE5E7EB`, `pressed.opacity=0.8`,
`focused.border=#FF2563EB`, `disabled.opacity=0.4`. The key after the state is any key the line reads. `selected`
follows the line's `selected={…}`, `disabled` its `enabled={…}`; the others follow the pointer and the focus. A line
inside it follows its state by its id: `btn.selected.color=#FFFFFFFF` on the icon in `Row#btn` turns it white while
the row is selected. A state written replaces the look `selected=` gives a box by itself.

```notation expands
state on=false
Column gap=12
  Row#btn gap=8 pad=[16,10,16,10] fill=#FFF3F4F6 radius=8 selected={on} hovered.fill=#FFE5E7EB pressed.opacity=0.8 focused.border=#FF2563EB selected.fill=#FF2563EB onTap={on=!on}
    Icon "star" size=18 btn.selected.color=#FFFFFFFF
    Text "Favourite" btn.selected.color=#FFFFFFFF
  Input "Name" focused.fill=#FFEFF6FF
  Button "Save" enabled={on} disabled.opacity=0.4
```

`hovered` needs a mouse: on a touch screen it never holds, so hide nothing behind it. The states, each as the
parser reads it on a box (`states` is the record, [StateStyles](@type-StateStyles)):

{{states}}

{{reference}}

{{examples}}
