# Chart data transitions

When a chart's rows change in a running app, its marks move from the values
on screen to the new ones. The `graph` node does this, and the chart types
(`chart`, `barChart`, `lineChart`, `plotChart`) are drawn by it, so they move
the same way.

```json
{"type":"graph","props":{"rowKey":"month","animationDuration":300,"animateIn":true,
 "xAxis":{"label":"month","fit":"bars"},
 "marks":[{"type":"bar","y":"sales"}],
 "data":[{"month":"Jan","sales":12},{"month":"Feb","sales":28}]}}
```

## The controls

| Node | Props | Defaults |
|---|---|---|
| `graph` | `animationDuration`, `animateIn` | 300 ms, `false` |
| `chart`, `lineChart` | `animate`, `animationDuration`, `animateIn` | `true`, 700 ms, `false` |
| `barChart`, `plotChart` | `animate`, `animationDuration` | `true`, 700 ms |

- `animationDuration` is in milliseconds. Zero applies new rows at once, as
  `animate: false` does on a chart type.
- `animateIn` grows the marks from zero when the graph first shows. Without
  it the first rows are drawn at rest.
- The motion eases out: fast at first, slowing into the new values.
- Only a running app moves. A design-canvas preview and a rendered picture
  draw the new rows at rest.

Default values stay omitted in sparse serialization, so existing JSON needs no
change.

## Matching rows across updates

A row is told apart by one field, and a mark moves from the value its row had
to the value it has now.

- `graph`: the field named by `rowKey` (default `t`). Give each row a stable,
  unique value there (its month, its time, its id) when rows are filtered,
  reordered or added.
- `chart` and `barChart`: the row's position in the data. The third row moves
  from what the third row was, whatever its label.
- `lineChart`: the row's `xField` value. Rows whose x is not a number are not
  drawn.
- `plotChart`: the sample's x. Samples are spread evenly from `xMin` to
  `xMax`, so a different number of samples puts most of them at new x values.

Every field a mark draws moves: a bar's or line's `y`, an area's `fillTo`, a
candle's four fields, a slice's value.

## What happens to each row

- A row that was there before moves from its old value to its new one.
- A row that is new (its key was not on screen) grows from zero.
- A row that is gone disappears at once.
- A value that is missing or not a number stays absent; it is not drawn as
  zero. A value that was missing and is now a number grows from zero.
- The row order of the new data applies at once.
- Two rows with the same key share one starting value (the later row's).

The y scale is the new rows' scale from the first frame, so the axis does not
move while the marks do.

## Interrupted updates

New rows that arrive while marks are moving start a new move from the values
on screen at that moment, over the full duration. Nothing jumps to the
previous target first.

## What does not move

Colors, labels, the axes' bounds, guides, the selection and other styling
change at once, and changing them does not start or restart a move. Panning
and zooming are separate from it.

## Gauges and the progress bar

`radialGauge`, `gaugeMeter` and `progressBar` are not graphs. Each moves its
one `value` at a steady rate under its own `animate` and `animationDuration`
(`radialGauge`: `true`, 420 ms; `gaugeMeter`: `true`, 700 ms; `progressBar`:
`false`, 300 ms). An interrupted move starts again from the value on screen,
and a first value is drawn at rest.

Next: [Drawing with `customPaint`](07-custom-paint.md)
