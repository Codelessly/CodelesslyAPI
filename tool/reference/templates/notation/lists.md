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

A `Handle` is as big as its line says and where it is written: the list adds no room around it. Unwritten it is a
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

## A table of records

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
  or none; a row is chosen by a press, Shift takes a range, Ctrl or Cmd adds, and is tinted with the accent.
- `compact` makes the rows denser (36 instead of 44), `comfortable` roomier (52); `h=400` gives the table a height
  its rows scroll in under the header; `empty="No orders match."` is said when there are no rows; `maxw=`, `w=`
  and the other keys of a Column are the frame's. A design system's own `Table` comes first.

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
    Table#orders o in shown columns=[{"key":"name","label":"Customer"},{"key":"status","label":"Status","w":120},{"key":"total","label":"Total","w":100,"align":"end"}] sort=@sortKey select=@chosen empty="No orders match."
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
`@hour` is the row resting in the middle, read and written (a drag or a fling settles on a row and sets it; setting
it turns the wheel, over `animationDuration`). `pageMotion=` is how a row one away from the middle is drawn (turned
away with `rotateX`, faded, smaller), a row two away twice that: the drum. A band behind the middle row marks the
choice; the keys of a wheel of your own are `onKeyDown(key=ArrowDown, focused=true)` on its line
([interaction.md](interaction.md)).

```notation
state hour:decimal=8
Stack w=96 h=180
  Column w=fill h=36 y=72 fill=#FFF1F5F9 radius=8
  Pages h=fill @hour scrollDirection=vertical peek=0.2 padEnds=true edgeFade=0 animationDuration=200 pageMotion={"rotateX":-28,"perspective":0.003,"opacity":0.55,"scale":0.94}
    each item in range(24)
      Text "{item}" size=20 center h=fill
```

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
`count`), `onScrollEnd={…}`. Once the reader scrolls up it draws its own jump-to-latest button at its bottom end. A
pill of your own that counts what arrived meanwhile reads the scroll: `away` while the reader is up from the end,
the count kept while away and cleared at the end, and the pill (in a `Stack` over the list) going back to the
last item with `scrollTo node=… item={…}`.

```notation expands
state msgs=[{"id":"m1","text":"Morning"},{"id":"m2","text":"Lunch today?"},{"id":"m3","text":"Yes, 12:30"},{"id":"m4","text":"Same place?"},{"id":"m5","text":"By the river"},{"id":"m6","text":"Perfect"},{"id":"m7","text":"See you there"},{"id":"m8","text":"Five late"},{"id":"m9","text":"No rush"},{"id":"m10","text":"Here now"},{"id":"m11","text":"Table by the window"},{"id":"m12","text":"On my way up"}]
state away=false
state unread=0
Column h=360 gap=8
  Stack w=fill grow
    Column w=fill h=fill
      each m in msgs follow grow onScroll={away = result.max - result.offset > 80; unread = away ? unread : 0}
        Text#msg "{m.text}" pad=12
    Row#latest visible={away and unread > 0} x={"align":0} y={"end":12} pad=[12,6,12,6] radius=16 fill=#FF2563EB onTap={scrollTo node=msg item={length(msgs) - 1}; unread=0}
      Text "{unread} new" color=#FFFFFFFF
  Button "Receive" onTap={msgs=append(msgs, {"id": "m" + (length(msgs) + 1), "text": "New message"}); unread = away ? unread + 1 : 0}
```

### Scrolling to one copy

A line under an each is one line repeated, so it has one name: `Row#msg`, not an id worked out per copy (`id={m.id}`
is said and left out). A copy is reached by its item: `scrollTo node=msg item={key}` scrolls to the copy of the item
whose `id` is `key` (`item={3}`: the fourth item). A pinned message, a quote that goes to the message it quotes, a
search result: each names the item. A list that follows its end builds only the messages near its view; one not
built yet is built and scrolled to. An item no copy is of is said when the action runs, and nothing scrolls.

```notation expands
state msgs=[{"id":"m1","text":"We land on Thursday"},{"id":"m2","text":"Book the train"},{"id":"m3","text":"Done"}]
state pinId="m1"
Column h=300
  Row pad=12 fill=#FFF3F4F6 onTap={scrollTo node=msg item={pinId}}
    Text "Pinned: We land on Thursday"
  each m in msgs follow grow
    Text#msg "{m.text}" pad=12
```

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
