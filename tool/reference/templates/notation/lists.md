# Lists and data

Lists over data, grids, tables, paged views, reordering and swipe actions. Open it when a UI repeats a row per
element, lays out a grid, shows a table or pages through items.

## A list over data

`each item in list` repeats the lines under it once per element: `{item.field}` reads it, `index` is its place. An
each inside an each reads the outer one as `parent.item`.

```notation
state rows=[{"name":"Ada","total":3},{"name":"Lin","total":5}]
Column gap=8
  each item in rows
    Row between
      Text "{item.name}"
      Text "{item.total}"
```

Writers' words for a grid, a table, a list put in order by hand and swiped pages, and what each reads as:

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

```notation expands
state page=0
Pages @page h=160
  Text "One"
  Text "Two"
```

## A table of records

Rows of records with the same fields are a `Table`: `Table o in orders columns=[…]` writes a finished table, the
way a careful hand would: a frame on the theme's surface with a hairline on every side and rounded corners that
clip its rows, a header band (the labels in the caption's ink, a rule under it, kept in view while the page
scrolls), and a row per record with a rule under it and the band's fill under the pointer. Do not build a table
from a Column of Rows: write `Table`.

- `columns=[…]`: each column a label (`"Name"`: its key is `name`) or `{"key":…, "label":…, "w":120,
  "align":"end", "sort":false}`. A column with no `w` grows; `"align":"end"` puts its cells at the end in
  tabular figures (amounts, counts, dates in figures).
- The lines under the Table are its cells, one per column in order, each reading the record by the Table's name
  (`{o.total}`): a picture beside a name, a chip, a menu button. Columns left at the end with no line show their
  key's value.
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

{{reference}}

{{examples}}
