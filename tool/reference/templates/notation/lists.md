# Lists and data

Lists over data, grids, tables, paged views, reordering and swipe actions. Open it when a UI repeats a row per
element, lays out a grid, shows a table or pages through items.

## A list over data

`each item in list` repeats the lines under it once per element: `{item.field}` reads it, `index` is its place
(there with nothing written: `each dot in range(count)`, not `each dot, i in …`, which is said and read without
its second name). An
each inside an each is best given names of its own (`each group in groups` / `each msg in group.items`): the inner
lines read `{group.name}` and `{msg.subject}`. An inner each that reuses the outer's name (`each item in item.items`)
hides it, as in any language: `{item}` under it is the inner element, and `parent.item` the outer. A name inside a
string literal (`'m-' + m.id`) is text, never the loop's. An `if` under an `each` hides what a copy shows, not the
copy: the copy keeps its place in the list and its cell in a Grid. To leave elements out, repeat over the ones to
show: `each d in filter(days, x => x.open)`.

```notation
state rows=[{"name":"Ada","total":3},{"name":"Lin","total":5}]
Column gap=8
  each item in rows
    Row between
      Text "{item.name}"
      Text "{item.total}"
```

Writers' words for a grid, a table, a list put in order by hand and swiped pages, and what each reads as:

- Flutter's names on a Grid: `crossAxisCount` is `cols`, `crossAxisSpacing` and `mainAxisSpacing` are `gap` (a Grid
  has one), `mainAxisExtent=30` is each cell's height and `childAspectRatio=2` its width over its height.
- `ListView reorder handle onReorder={…}` is a list whose rows a `Handle` drags into a new order (`reorder` alone: a
  long press anywhere on the row).

```notation expands
state photos=["a","b","c"]
Grid cols=3 gap=8
  each item in photos
    Text "{item}"
```

```notation width=1280 expands
state orders=[{"name":"Ada","total":3}]
Page
  Section
    Table o in orders columns=["Name",{"key":"total","label":"Total","align":"end"}]
```

```notation expands
state trip=[{"name":"Oslo"},{"name":"Rome"}]
Column
  each stop in trip reorder
    Row gap=8
      Handle
      Text "{stop.name}"
```

A handle of another look is any line with `reorderHandle=true` (a column of dots drawn with `box`es), and the row
while it is dragged is the row's `dragged.` state (`dragged.fill=…`) with the list's `reorder.proxyElevation=0` (no
shadow), `reorder.proxyScale` and `reorder.proxyOpacity`. A `Handle` is as big as its line says and where it is
written: the list adds no room around it. Unwritten it is a
44 px target on a phone and a 24 px grip on a page 700 wide or wider (a touch still lands on it in 44 × 44).

`reorder` on an `each` (or on the line it is under) lets its copies be dragged into a new order, and moved with Alt
and the arrows from the keyboard. The new order is written to the list the `each` runs over, so that list is a
variable declared with `state`; over a formula (`each c in colCards(col.id)`) write `reorder onReorder={…}` on the
line the `each` is under and store the
move yourself (`result.item`, `result.from`, `result.to`, `result.toList`). Moving between lists (a board's
columns) is a `ListView`'s: `ListView#lane reorder.group=board reorder.listKey={col.id} onReorder={…}` with the
`each` under it; the `reorder.*` keys (`group`, `listKey`, `start=press`) are a ListView's, not a Column's.

```notation expands
state page=0
Pages @page h=160
  Text "One"
  Text "Two"
```

A `PageView` (or `Pages`) reports the page it settles on with `onChange` (`result.index`), as a carousel's dots
read it; `onScroll` fires on every move of the drag.

```notation
state reviews=["Kind","Clear","Calm"]
state at=0
Column gap=8
  PageView h=120 onChange={at=result.index}
    each item in reviews
      Text "{item}"
  Row gap=6 center
    each item in reviews
      Column w=6 h=6 fill={index == at ? '#FF2563EB' : '#FFD1D5DB'} radius=3
```

A `ListView` is a list over data: the one line under its `each` is repeated, and what only a list does goes with
it (pull to refresh with `onRefresh` or `pullToRefresh`, `pagination`, swipe actions, `stickToEnd`). Lines of its
own beside the `each` make it a scrolling Column holding them and the each, which does none of those; the expand
says so. Headings among the items are the list's `sections` (`sections.groupBy`, its `sectionHeader` slot).

```notation
state posts=[{"id":"a","text":"First"},{"id":"b","text":"Second"}]
ListView h=300 onRefresh={posts=posts}
  each item in posts
    Text "{item.text}"
```

## A name for each copy

Under an `each`, `id={m.name}` (or a text with a value in it, `id="sec{m.n}"`) on the repeated line names each copy
by its item. A scroll to that name reaches the copy whose item gives it: `scroll {m.name}` from a row of a sidebar,
`scroll sec2`, `scroll {"sec" + tab}`; a copy its list has not built yet is built first. A name no copy has is a
line's own id, as before (`Section#pricing`, `id=pricing`). The name reads the item alone (not its `index`), and
the each is not inside another each: there, name the line (`Row#msg`) and write `scrollTo node=msg item={x}` (the
copy of the item whose `id` is `x`) or `scrollTo node=msg index={i}` (the copy at position `i`, from 0).

## A list put in order by hand

`each stop in trip reorder` lets its rows be dragged by their `Handle` (or moved with Alt and the arrows) and writes
the new order to `trip`. `Handle icon="menu"` is the grip with another glyph. Over a list that is worked out
(`each x in day.items reorder`), the each's line says how a move is stored: `each x in day.items reorder
onReorder={days=updateWhere(days,d=>d.id==day.id,d=>with(d,"items",result))}`; in it `result` is the list in its new
order, and `result.item`, `result.from` and `result.to` say what moved. Over a field of a record a `find` picks, or of
the item of an each around it, the order is written back into that record with nothing more to write.

## A table of records

A table's records may be written on its line: `DataTable rows=[{"n":"path","t":"string"},{"n":"depth","t":"number"}]
columns=[{"key":"n","label":"Name"},{"key":"t","label":"Type"}]`. `rows=orders`, the bare name of a list of the state,
is that list.


Rows of records with the same fields are a `Table`: `Table o in orders columns=[…]` writes a finished table, the
way a careful hand would: a frame on the theme's surface with a hairline on every side and rounded corners that
clip its rows, a header band (the labels in the caption's ink, a rule under it, kept in view while the page
scrolls), and a row per record with a rule under it and the band's fill under the pointer. Do not build a table
from a Column of Rows: write `Table`.

- `columns=[…]`: each column a label (`"Name"`: its key is `name`) or `{"key":…, "label":…, "w":120,
  "align":"end", "sort":false}`. A column with no `w` grows; `"align":"end"` puts its cells at the end in
  tabular figures (amounts, counts, dates in figures). `"hide":"phone"` leaves the column (its header and its
  cells) out on a phone, `"hide":"tablet"` on a tablet and a phone: one table serves every width. Reflow leaves a
  table as written; these are its rules at other widths.
- The lines under the Table are its cells, one per column in order, each reading the record by the Table's name
  (`{o.total}`, in every key: `color={o.status == 'Paid' ? … : …}`): a picture beside a name, a chip, a menu button.
  Columns left at the end with no line show their key's value.
- `sort=@sortKey` (a text variable, the key sorted by; `-key` the other way): a press on a header sorts by its
  column, again the other way; an arrow marks the column sorted, a quiet mark the others.
- `select=@chosen` (a list variable of the rows' `id`s): a column of checkboxes leads; the header's picks every row
  or none; a row is chosen by a press, Shift takes a range, Ctrl or Cmd adds, and is tinted with the accent. A
  design system that names a chosen row's fill (`colors.selectedRow` in its theme) has that instead, here, on a
  selectable list's row and on a line written `selected={…}`: one whose chosen things are neutral, the ticked box
  the accent's mark.
- What a row does is written on the Table's line: its events (`onTap={sel=o.id}`, `onDoubleTap={…}`,
  `onRightClick={…}`, `onHover={…}`) and `menu=rowMenu` are each row's, and read the record by the Table's name as
  the line under an `each` does. A control in a cell (a Button, an IconButton) keeps its own tap. (`onScroll={…}`
  stays the table's.)
- `slot caption` as the first line under the Table, with a line or more under it, is a row between the header and
  the rows, its lines side by side with a rule under them (what is sorted by, a count, a hint). The cells follow it.
- `compact` makes the rows denser (36 instead of 44), `comfortable` roomier (52); `h=400` gives the table a height
  its rows scroll in under the header; `empty="No orders match."` is said when there are no rows; `maxw=`, `w=`
  and the other keys of a Column are the frame's. A design system's own `Table` comes first.
- `flush` leaves the frame out (no border, corners or ground of its own; the header's band and the rules between
  the rows stay): for a place that is its frame already. A Table written directly under a design system's
  component that is itself written `flush` (a `Panel "Plans" flush`: its lines run to its edges) is flush with
  nothing written.

```notation width=1280 expands
state orders=[{"id":"o1","name":"Ada Byron","status":"Paid","total":30},{"id":"o2","name":"Lin Chen","status":"Due","total":12}]
state search=""
state status="All"
state sortKey="name"
state chosen=[]
state shown:list={filter(orders, r => (status == 'All' || r.status == status) && contains(lower(r.name), lower(search)))}
Page
  Section
    Row gap=8
      Input "" "Search" @search w=280
      Select @status items=["All","Paid","Due"] w=140
    Table#orders o in shown columns=[{"key":"name","label":"Customer"},{"key":"status","label":"Status","w":120},{"key":"total","label":"Total","w":100,"align":"end"}] sort=@sortKey select=@chosen empty="No orders match." onDoubleTap={search=o.name}
      slot caption
        Text.caption "Sorted by {sortKey}, {length(chosen)} chosen"
      Row gap=10
        Avatar "AB" size=28
        Text.strong "{o.name}"
      Badge "{o.status}"
```

A table that scrolls on both axes and builds only the cells in view (a timetable, a sheet of thousands of cells) is
`DataTable rows={orders} columns=[…]` (`TableView`): every cell is a text of its key's value.

A table of your own (a Column of Rows) gets the same frame from the keys: `border=… radius=8 clip=antiAlias` on
the Column, `border-bottom=…` on each Row. A box's border is drawn over what it holds, so the rows' own fills
never cover its sides, and `clip` keeps them inside its rounded corners.

## A list of its own line

A `ListView` or `GridView` line with an `each` as its only line under it repeats that one line over the data: the
list's own keys (its height, its direction, its spacing) are on its line.

```notation
state products=[{"name":"Lamp"},{"name":"Desk"}]
ListView h=120 scrollDirection=horizontal
  each item in products
    Text "{item.name}" w=100
```

## A wheel that snaps to its middle row

A wheel (an hour, a minute, a number chosen by turning) is a `Pages` that scrolls down, one page a row: `peek=` is a
row's share of its height (`0.2`: five rows show), `padEnds=true` lets the first and last rows reach the middle, and
`@hour` is the row resting in the middle, read and written (a drag settles on the nearest row and sets it; setting
it turns the wheel, over `animationDuration`). A band behind the middle row marks the choice; the keys of a wheel of
your own are `onKeyDown(key=ArrowDown, focused=true)` on its line ([interaction.md](interaction.md)).

**A spin.** `snapPhysics=` is how a fling carries: a [GesturePhysics](values.md#type-GesturePhysics), the
release a dragged node has. With it a fling coasts by its speed over as many rows as it carries, slowing by
`friction` (the share of its speed lost a second; 0.865 is a phone's), and rests on the row nearest where it would
stop, settling on its `spring`; a release slower than `minFlingVelocity` settles on the nearest row; with reduced
motion it goes to that row with no coast. Without it a fling turns one page. It is the same on a `ListView` with
`itemSnapping`.

**Rows by their distance.** Each page reads `pageOffset`, its distance from the middle in pages (0 the middle one,
1.5 halfway between the next two, negative before it; not clamped: `clamp(pageOffset, -3, 3)` bounds it), so any key
of a row can follow it: its `motion` (`translateX`, `translateY`, `translateZ`, `scale`, `rotate`, `rotateX`,
`rotateY`, `path`) and its `opacity`. A row of a `ListView` with `itemSnapping` reads the same `pageOffset`: its
distance from the list's snap point (the start of the view) in rows, so a list's rows can scale or fade by it too.

A drum of radius R (half the wheel's height) puts a row d rows away at the angle d·h/R: at `R·sin(angle)`
(`motion.translateY`, less the d·h the pages put it at), turned by the angle (`motion.rotateX`) and pushed back by
`R·(cos(angle) - 1)` (`motion.translateZ`: toward the viewer is positive, away negative), so the rows crowd, flatten
and shrink toward the top and bottom while the middle row is untouched. `perspective=` on the `Pages` is one camera at
the view's middle for every page (the pages' own `motion.perspective=0`): with it the drum is seen in depth; 0 draws
it flat. A cover flow turns its pages about y, a deck stacks them with `translateY`, `translateZ` and `scale`.
`pageMotion=` says the common case in one record, drawn by distance up to two pages.

```notation
state hour:decimal=8
Stack w=96 h=180
  Column w=fill h=36 y=72 fill=#FFF1F5F9 radius=8
  Pages h=fill @hour scrollDirection=vertical peek=0.2 padEnds=true edgeFade=0 allowImplicitScrolling=true snapPhysics={"friction":0.865} perspective=2
    each item in range(24)
      Text "{item}" size=20 center h=fill motion.translateY={90 * sin(pageOffset * 0.4) - pageOffset * 36} motion.translateZ={90 * (cos(pageOffset * 0.4) - 1)} motion.rotateX={-pageOffset * 0.4 * 180 / pi()} opacity={abs(pageOffset * 0.4) < pi() / 2 ? 1 - 0.7 * abs(pageOffset * 0.4) / (pi() / 2) : 0} motion.perspective=0
```

**While it turns.** `@hour` changes as each row passes the middle, not only at rest, so anything bound to it follows
the spin. The position between rows is the `onScroll` reaction's `result.page` (a decimal: 8.4 is four tenths of the
way from 8 to 9; `result.index` the row nearest, `result.offset` the pixels), stored in a variable another part reads
(`onScroll={turn=result.page}`, `state turn:decimal=8`). Where it comes to rest is `onScrollEnd` (`result.index`).

## A list that follows its newest entry

`follow` on an each, with the height it scrolls in, is a log or a chat: `each line in lines follow h=180` opens at
its end and stays there as entries are added (the list's `stickToEnd`). `follow grow` takes the room its column
leaves instead of a height (a chat over its composer).

```notation
state lines=["Connected","Ready"]
Column gap=8
  each item in lines follow h=180
    Text "{item}"
  Button "Add" onTap={lines=append(lines,"Synced")}
```

The list the `each … follow` makes is a `ListView` of its own, so its events are written on the each line:
`onScroll={…}` (its `result`: `offset`, `max`, `viewport`, `fraction`, `index` the item at the start of the view,
`count`), `onScrollEnd={…}`; so are its keys `jumpToLatest=`, `stickToStart=` and `refreshStyle=`. Once the reader
scrolls up it draws its own jump-to-latest button at its bottom end; `jumpToLatest=false` on the each line draws
none. A pill of your own counts what arrived meanwhile and reads the scroll: `away` while the reader is up from the end, the count kept while away and cleared
at the end, and the pill (in a `Stack` over the list) going back to the last item with `scrollTo node=… item={…}`.

```notation expands
state msgs=[{"id":"m1","text":"Morning"},{"id":"m2","text":"Lunch today?"},{"id":"m3","text":"Yes, 12:30"},{"id":"m4","text":"Same place?"},{"id":"m5","text":"By the river"},{"id":"m6","text":"Perfect"},{"id":"m7","text":"See you there"},{"id":"m8","text":"Five late"},{"id":"m9","text":"No rush"},{"id":"m10","text":"Here now"},{"id":"m11","text":"Table by the window"},{"id":"m12","text":"On my way up"}]
state away=false
state unread=0
Column h=360 gap=8
  Stack w=fill grow
    Column w=fill h=fill
      each m in msgs follow grow onScroll={away = result.max - result.offset > 80; unread = away ? unread : 0}
        Text#msg "{m.text}" pad=12
    Row#latest visible={away && unread > 0} x={"align":0} y={"end":12} pad=[12,6,12,6] radius=16 fill=#FF2563EB onTap={scrollTo node=msg item={length(msgs) - 1}; unread=0}
      Text "{unread} new" color=#FFFFFFFF
  Button "Receive" onTap={msgs=append(msgs, {"id": "m" + (length(msgs) + 1), "text": "New message"}); unread = away ? unread + 1 : 0}
```

### A list pulled to refresh

`pullToRefresh=true` on a list (or a `refresh` reaction) refreshes it when it is pulled past its start: a disc drops
in over the list. `refreshStyle=spinner` draws iOS's control instead: the ticked spinner alone, coming in as the
pull opens room for it, turning while the list refreshes (a list with `physics=bouncing` opens that room as on
iOS).

### A list keeps its place

A running list over data keeps what is in view where it is when items are put before it or taken out before it,
as a browser keeps a page in place (scroll anchoring): a newer message added to a reversed chat (`ListView
reverse=true`, newest first) the reader has scrolled up in, a page of older messages put at its far end, a message
taken out above. Nothing is written for it; the items need an `id` (or the list's key path) to be told apart. At
its very start the list shows what is put there, as a page at its top does: a reversed chat at its newest message
shows a new one. `stickToStart=false` keeps what is in view there too, once the items fill the list: the new
message waits below until the reader scrolls to it, and nothing on screen moves (`ListView#chat reverse=true
stickToStart=false`). A list that follows its end (`follow`, `stickToEnd`) keeps its place at its start either
way. A list paged a page at a time (`pagination` with `"mode": "pages"`), a grid and a list in sections show
their items from where they are, as before.

### Scrolling to one copy

A line under an each is one line repeated, so it has one name: `Row#msg`, not an id worked out per copy (`id={m.id}`
is said and left out). A copy is reached by its item: `scrollTo node=msg item={key}` scrolls to the copy of the item
whose `id` is `key` (`item={3}`: the fourth item). A pinned message, a quote that goes to the message it quotes, a
search result: each names the item. A list that follows its end builds only the messages near its view; one not
built yet is built and scrolled to. An item no copy is of is said when the action runs, and nothing scrolls. A key
that reads as a number (`id: 2`) names the item with that id, built or not, before the copy at that index. A quoted
message not loaded yet is loaded first, then scrolled to: grow the data (`shown=…`, or the next pages) and
`scrollTo node=msg item={quoteId}` after it; the pages put at the far end move nothing in view.

```notation expands
state msgs=[{"id":"m1","text":"We land on Thursday"},{"id":"m2","text":"Book the train"},{"id":"m3","text":"Done"}]
state pinId="m1"
Column h=300
  Row pad=12 fill=#FFF3F4F6 onTap={scrollTo node=msg item={pinId}}
    Text "Pinned: We land on Thursday"
  each m in msgs follow grow
    Text#msg "{m.text}" pad=12
```

On the line of an each that follows its end, `pad=` and `gap=` are the room around the rows of the list it makes and
the gap between them: `each m in messages follow grow pad=[24,16] gap=6`. `follow` is a word of the each's line
only; on a Column it is said, with the line to write.

## A list chosen from and swiped

`selectable selected=@chosen` on the line an each is under makes its rows chosen as a desktop list's are (a press
alone, Ctrl or Cmd adds, Shift takes a range, Ctrl or Cmd A all), and `SwipeAction` lines under the each (an each
that runs down a Column, as below; not under a ListView) put actions behind a swiped row: one list takes both (a mailbox: choose many with the keyboard and the pointer, swipe one on a
phone). `removes` takes the row out of the list's variable; `result.item` is the row swiped. An action is drawn in
the accent, a destructive one (`danger`, or a delete, remove or trash by its icon or label) in the theme's error
color; `background=` and `foreground=` give it colors of its own (`background=warning`). A row's own menu
(`menu=rowMenu onRightClick={menuId=m.id}` on the row) opens on a right-click or a long press, and a press still
chooses the row; `menu=` on the list's line instead acts on the rows chosen.

```notation expands
state msgs=[{"id":"m1","subject":"Q4 review"},{"id":"m2","subject":"Lunch?"}]
state chosen=[]
Column selectable selected=@chosen
  each m in msgs
    Row h=56 pad=[16,0,16,0]
      Text "{m.subject}"
    SwipeAction "Archive" side=end icon="archive" onTap={msgs=without(msgs, result.item)}
    SwipeAction "Delete" side=end icon="delete" removes
```

{{reference}}

{{examples}}
