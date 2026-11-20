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

A spinner is `CircularProgressIndicator w=32 h=32` (also `Ring`: an arc going round) or `ActivityIndicator
radius=16` (Cupertino ticks, twice `radius` across). `ProgressRing` and `ProgressIndicator` are not words, and
neither takes `size=`.

```notation
Row gap=12
  CircularProgressIndicator w=32 h=32
  ActivityIndicator radius=16
```

Every chart, however it is written: the labels under the plot never touch (every second, third… from the first is
written, evenly apart, and long ones are first cut to their room with an ellipsis); a series or a slice with no
color takes the theme's next series color (`chart1`, `chart2`… where the theme names them, else its accent and then
colors of other hues as light and as strong as it); a smooth line never rises above or dips below its values.

{{reference}}

{{examples}}
