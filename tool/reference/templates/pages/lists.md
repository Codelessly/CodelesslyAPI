# Lists, grids, tables and repeated data

## When to use

Anything repeated from data: lists and grids from one item template, nested lists (`item`, `index`, `parent`),
equal-height card grids, tables, carousels (`pageView`), list tiles, pagination, pull to refresh, swipe actions and
reordering.

## Minimal example

A `listView` repeats its first child once per item of its `data` binding; inside, `${item}` is the item and
`${index}` its position:

{{example:list}}

## Reference

{{reference}}

## Patterns

### One template from data

A `listView` (or `gridView`, `pageView`) repeats its **first child** once per item of its `data` binding:
`"bind": {"data": "${questions}"}`. Inside the repeated child, `${item}` is the item (`${item.title}`) and
`${index}` its position from 0. A list in a scrolling page sets `"scrollable": false` so it lays out every item at
its full height; `spacing` separates items. Items fill the list's width. The item template can carry reactions: a
click on an item runs with that item's `item` and `index`. When the item is more than about five nodes, or appears
elsewhere too, make it one call of a [component](@page-components) (`"bind": {"props.plan": "${item}"}`).

### A grid of cards

For cards in columns from one list inside a scrolling page, use a `gridView` with `minCrossAxisExtent` (CSS
`repeat(auto-fit, minmax(280px, 1fr))`: as many equal columns as fit), `"shrinkWrapRows": true` and
`"physics": "never"` (it lays out every item and the page scrolls). A fixed number of columns: `crossAxisCount`. A
`listView` with `"wrap": true` lays its items out at their own sizes in runs along its `scrollDirection`: set
`"scrollDirection": "horizontal"` for chips or nav links side by side. In wrap mode the gap between items is
`wrapSpacing` and between runs `runSpacing`; `spacing` does not apply.

### Equal-height cards

In a `gridView` with `"shrinkWrapRows": true` (CSS grid's auto rows) each row is as tall as its tallest item, and
every item is stretched to it, whether it hugs or fills its height. Make the item the card (the box with the
decoration): a card *inside* a hugging item column keeps its own height, and a card that fills the item's height
there takes its design number (`fill_fallback`). A banner above one card goes inside the card, with a top margin on
the others to line them up. A card's button pinned to its bottom: a `spacer` (or a `fill` height child) between the
content and the button inside the stretched card. `shrinkWrapRows` wins over `mainAxisExtent` (`prop_ignored`); for
rows at least n tall, give the item `"constraints": {"minHeight": n}`.

### Nested lists

A list inside a list's item repeats per item of its own `data`, usually a field of the outer item. Inside the inner
template `item` and `index` are the innermost list's; `parent` is the item around it (`${parent.item}`,
`${parent.index}`, and its fields directly: `${parent.name}`). Two levels:

```json
"sections": {"type": "listView", "children": ["section"], "bind": {"data": "${= groupBy(dishes, 'section')}"},
             "props": {"scrollable": false, "spacing": 24}, "layout": {"width": {"fill": 600}, "height": {"hug": 400}}},
"section":  {"type": "column", "children": ["sectionTitle", "dishList"], "props": {"crossAxisAlignment": "start"},
             "layout": {"width": {"fill": 600}, "height": {"hug": 200}}},
"sectionTitle": {"type": "text", "props": {"text": "${item.key} (${item.count})", "style": {"fontSize": 20, "color": "#FF111827"}},
             "layout": {"width": {"hug": 200}, "height": {"hug": 24}}},
"dishList": {"type": "listView", "children": ["dish"], "bind": {"data": "${item.items}"}, "props": {"scrollable": false},
             "layout": {"width": {"fill": 600}, "height": {"hug": 120}}},
"dish":     {"type": "text", "props": {"text": "${parent.key} ${parent.index}: ${item.name} (#${index})", "style": {"color": "#FF374151"}},
             "layout": {"width": {"fill": 600}, "height": {"hug": 20}}}
```

A third level reads the second's item as `parent`; to reach further out, carry the value down in the data.

### A table from one template

A `listView` of rows bound to the records, each row a label and a `gridView` of cells bound to `${item.values}` with
`crossAxisCount` the number of columns: one cell node for every column (the example in
[a capped band](@layout-a-capped-band)). Four columns written by hand, or four lists side by side, are the same
table written four times. For a column that stays while the others scroll sideways, keep the label column a
`listView` of its own beside one horizontally scrolling block of the cell grids, rows the same height in both. A
`tableView` is a data table with columns declared once (sorting, row taps).

### Filter, sort and page a list

Search, a status filter, sortable columns and pages are computed variables over the records, chained: `shown`
filters and sorts them, `paged` is one page of it, and the list binds `${paged}`.

- Inside `filter`, `sortBy`, `map` and `count` an item's field is read through the item, a lambda's parameter:
  `filter(invoices, r => r.status == x)`. Written without it (`filter(invoices, status == x)`) the condition is
  computed once, outside the list, and matches no item: the list is empty (`unknown_name` names the field).
- "All" and an empty search match everything inside the lambda: `statusFilter == 'All' || r.status ==
  statusFilter`; `contains(lower(r.cust), lower(search))` is true while `search` is empty.
- `sortBy(list, key, 'desc')`: the key is a field name (a variable holding one works) or a lambda; the direction
  is `'asc'` or `'desc'`, not 1 or -1.
- Page after filtering and sorting; set `page` back to 0 when the search or filter changes. Counts read `shown`.

{{example-as-written:pages/table_filter}}

### A weekly grid

Seven columns of days from data: a `gridView` with `"crossAxisCount": 7` bound to the days (`${= range(7)}`, or a
computed list of `{day, done}` records), each cell a box whose fill is bound to the item. Rows of habits × days: a
`listView` of habits whose item holds a label and that 7-column grid bound to `${item.days}`; in a cell, `${parent}`
is the habit and `${index}` the day. A grid sizes its cells: set the cell height with `mainAxisExtent` and give
the cell `fill` on both axes (a fixed size is `fit_not_allowed`).

A tap on a day flips it in the habit's record (`setAt` and `set` build the new list); the label counts the checks:

{{example:pages/weekly}}

### A carousel, pages and pagination

A `pageView` shows one item (or child) per page and swipes between them (`viewportFraction` below 1 shows the
neighbours' edges; `initialPage`). Long lists that load in pages: the list's `pagination` settings, with a
`pagination` control or the `paginate` action to move between pages.

A rail of cards with arrows, dots and a progress bar is a horizontal `listView` (or scrolling `row`):

- `"itemSnapping": true` makes a drag or fling come to rest with a card at the start of the view (CSS
  `scroll-snap-align: start`; Flutter's `PageView.pageSnapping`, for items).
- Its `scroll` reaction gives `${result.index}` (the card at the start; the last at the end), `${result.count}`,
  `${result.offset}` and `${result.fraction}` (0–1): store them in variables the controls bind.
- An arrow is `{"type": "scrollTo", "node": "<item template>", "item": "${= current + 1}"}`: `item` is the key or
  the index of the card to bring to the start (`alignment` 0; 0.5 centres it). A dot scrolls to its own `${index}`.
  For a scrolling `row` of fixed children, name the child: `"node": "card${= current + 1}"`.

The same pattern moves a horizontal timeline from its year buttons, or a featured-routes carousel from its dots:

{{example:carousel}}

## Pitfalls

- Only the first child is the template; other children are ignored.
- A list function's condition reads the item through a lambda (`r => r.status == x`); written without one it is
  computed once and the list comes out empty.
- `item` and `index` are the innermost list's; the outer one is `parent`.
- A list inside a scrolling page needs `"scrollable": false` (or `"physics": "never"`, which a `gridView` needs:
  it has no `scrollable`), or it takes its design height and scrolls inside itself.
- A wrapping `listView` runs along its `scrollDirection`: with the default `vertical` it flows top to bottom into
  columns (`vertical_wrap`).
- Decoration on a `listView` or `gridView` is ignored (`decoration_ignored`): put the list inside a column that has
  it.
- A `fill` height inside a hugging grid item is its design number (`fill_fallback`).
- A slot inside a list of a component shows what the call passes in every item, built in the caller's scope: it
  reads the caller's variables, not the item.

## See also

[State](@page-state) (list formulas: `filter`, `groupBy`, `sortBy`, `append`) · [forms](@forms-add-and-remove-items-a-list-editor)
(add and remove items) · [components](@page-components) · [responsive layout](@layout-cards-that-wrap).
