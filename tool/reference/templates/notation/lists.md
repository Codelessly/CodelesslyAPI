# Lists and data

Lists over data, grids, tables, paged views, reordering and swipe actions. Open it when a UI repeats a row per
element, lays out a grid, shows a table or pages through items.

## A list over data

`each item in list` repeats the lines under it once per element: `{item.field}` reads it, `index` is its place. An
each inside an each is best given names of its own (`each group in groups` / `each msg in group.items`): the inner
lines read `{group.name}` and `{msg.subject}`. An inner each that reuses the outer's name (`each item in item.items`)
hides it, as in any language: `{item}` under it is the inner element, and `parent.item` the outer. A name inside a
string literal (`'m-' + m.id`) is text, never the loop's.

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

```notation expands
state orders=[{"name":"Ada","total":3}]
DataTable rows={orders} columns=[{"key":"name","label":"Customer"},{"key":"total","label":"Total"}]
```

```notation expands
state trip=[{"name":"Oslo"},{"name":"Rome"}]
Column
  each stop in trip reorder
    Row gap=8
      Handle
      Text "{stop.name}"
```

```notation expands
state page=0
Pages @page h=160
  Text "One"
  Text "Two"
```

## A table you sort and filter

The rows shown are a formula variable over the data: `filter` keeps the rows the search and the status let through,
`sortBy` puts them in the order of the column picked. The controls only set variables (`@search`, `@status`); a
header's tap picks its column, or turns the order round when it is picked already. `hovered.fill=` marks the row
under the pointer ([responsive.md](responsive.md#responsive-states)), and `if` says when nothing matches.

```notation expands
state orders=[{"name":"Ada","total":30,"status":"Paid"},{"name":"Lin","total":12,"status":"Due"}]
state search=""
state status="All"
state sortKey="name"
state desc=false
state shown:list={sortBy(filter(orders, r => (status == 'All' || r.status == status) && contains(lower(r.name), lower(search))), sortKey, desc ? 'desc' : 'asc')}
Column gap=12
  Row gap=8
    Input "Search" @search grow
    Select @status items=["All","Paid","Due"] w=140
  Row pad=[12,8,12,8]
    Text.strong "{sortKey == 'name' ? (desc ? 'Customer ↓' : 'Customer ↑') : 'Customer'}" grow onTap={desc={sortKey == 'name' && !desc}; sortKey="name"}
    Text.strong "{sortKey == 'total' ? (desc ? 'Total ↓' : 'Total ↑') : 'Total'}" w=80 onTap={desc={sortKey == 'total' && !desc}; sortKey="total"}
  each item in shown
    Row pad=[12,8,12,8] hovered.fill=#FFF3F4F6
      Text "{item.name}" grow
      Text "{item.total}" w=80
  if length(shown) == 0
    Text.muted "No orders match."
```

`TableView` (also written `DataTable`) draws a table from `data={rows}` and `columns=[…]` itself, with
`sortable=true` for headers that sort; the hand-made one above is for a table whose rows and headers are your own.

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
