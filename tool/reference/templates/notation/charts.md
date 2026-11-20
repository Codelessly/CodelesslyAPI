# Charts and indicators

Progress bars and rings, spinners, badges, gauges, bar, line, donut and plotted charts, and barcodes. Open it when
a UI shows numbers as a picture.

## Writing a chart

A chart's fields are keys by their own names; its lists (`values`, `labels`, `series`, `data`, `zones`…) are
JSON, or `{expression}` to follow the state. Writers' words, and what they read as:

```notation expands
Column gap=12
  Progress 0.6
  BarChart values=[3,5,4] labels=["Mon","Tue","Wed"] h=160
  LineChart values=[10,12,11,14] h=120
  LineChart labels=["W1","W2","W3"] series=[{"name":"Signups","values":[40,52,48]},{"name":"Churn","values":[8,6,9]}] h=160
  BarChart stacked labels=["Q1","Q2"] series=[{"name":"Direct","values":[30,42]},{"name":"Organic","values":[16,15]}] h=160
  Donut values=[60,25,15] labels=["Rent","Food","Other"]
  Gauge 72 min=0 max=180 limit=100 unit="km/h"
```

Give a chart a height. The words above write their look on the chart they stand for, as its keys, so a key
written on the line wins (`legend=false`, `selectOnHover=false`, `dots=0`, `barRadius=0`, `roundScale=false`); a
`chart`, `barChart` or `lineChart` written by its type takes none of them and draws as its own defaults say.

- What is under the pointer or a finger is selected and says its value in a tooltip (`selectOnHover`, `tooltip`;
  a line of values: `scrubEnabled`), a line chart with a line up the plot through it (`cursorLine`).
- Round grid lines with their figures, the scale ending on a labeled line (`roundScale`; one series:
  `gridValues`): 2,500 with its separator, 20K for 20000.
- A legend under a chart with two or more named series, and for a `Donut` or a `Pie` its labels with their shares,
  beside the ring where its box has the room, else under it (`legend`).
- A `Donut`'s total in its hole (`total="Visitors"` names it, `total=false` leaves the hole empty; a `Pie` has no
  hole).
- A smooth line with a dot on each of up to 12 points (`dots`), and under an `AreaChart`'s line a fill that fades
  to the foot of the plot.
- Rounded bars no wider than 40 (`barRadius`, `maxBarWidth`); bars of several `series` side by side (`stacked`:
  one on another).

Every chart, however it is written: the labels under the plot never touch (every second, third… from the first is
written, evenly apart, and long ones are first cut to their room with an ellipsis); a series or a slice with no
color takes the theme's next series color (`chart1`, `chart2`… where the theme names them, else its accent and then
colors of other hues as light and as strong as it); a smooth line never rises above or dips below its values.

## A history: scrub it, page it, pan it

A chart over a long history that a finger scrubs and that goes back in time is a [`Graph`](#node-graph): its rows
are the data, its marks what is drawn of them, `selection` what a finger or the pointer picks (its row comes back
on `onChange` as `result.selection`), and the stretch of history shown is either the rows it is given or its
`view`.

Paged: the rows shown are worked out from a page in the state (`slice`), every row across the plot (`fit`), and
buttons move the page. A drag across the plot scrubs: the row under the finger is selected and says its value.

```notation
state page=0
state days=[{"t":"Nov 1","v":3},{"t":"Nov 2","v":5},{"t":"Nov 3","v":2},{"t":"Nov 4","v":6},{"t":"Nov 5","v":4},{"t":"Nov 6","v":7},{"t":"Nov 7","v":5},{"t":"Nov 8","v":8},{"t":"Nov 9","v":6},{"t":"Nov 10","v":9},{"t":"Nov 11","v":4},{"t":"Nov 12","v":7},{"t":"Nov 13","v":10},{"t":"Nov 14","v":8}]
state picked={}
Column gap=8
  Row between
    Button.ghost "Earlier" onTap={page=page + 1}
    Text "{picked.label == null ? 'This week' : picked.label + ': ' + picked.row.v}"
    Button.ghost "Later" onTap={page=max(0, page - 1)}
  Graph h=220 data={slice(days, max(0, length(days) - 7 * (page + 1)), length(days) - 7 * page)} rowKey=t xAxis={"label":"t","format":"","fit":"points","inset":8} marks=[{"type":"line","y":"v","width":2,"dots":3}] selection={"on":"hover","dot":5} interactions={"dragPan":false,"wheelZoom":false,"pinchZoom":false,"axisScale":false,"doubleTapReset":false} onChange={picked=result.selection}
```

Panned: with no `fit` the view is the reader's: a drag pans it back through the rows, `view={{"last":7}}` starts
it on the last seven, a long press (`crosshair.on`) scrubs, and `onScroll` with `result.nearStart` asks for older
rows while `xAxis.moreHistory` says there are some.

```notation
state days=[{"t":"Nov 1","v":3},{"t":"Nov 2","v":5},{"t":"Nov 3","v":2},{"t":"Nov 4","v":6},{"t":"Nov 5","v":4},{"t":"Nov 6","v":7},{"t":"Nov 7","v":5},{"t":"Nov 8","v":8},{"t":"Nov 9","v":6},{"t":"Nov 10","v":9}]
Graph h=220 data={days} view={{"last":7}} rowKey=t xAxis={"label":"t","format":"","moreHistory":false} marks=[{"type":"line","y":"v","width":2}] crosshair={"enabled":true,"on":"longPress","horizontal":false}
```

{{reference}}

{{examples}}
