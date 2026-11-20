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

Give a chart a height. What its line does not say, the chart supplies:

- round grid lines with their figures, and under the plot the labels that fit: where they would touch, every
  second, third… is written, the first and the last always;
- its colors: the theme's series colors (`chart1`, `chart2`… where the theme names them), else its accent and then
  colors of other hues as light and as strong as it, so two series are never two shades of one color;
- a legend under a chart with two or more named series, and for a `Donut` its labels with their shares, beside it
  where it has the room (on a page, under it where it has not);
- a `Donut`'s total in its hole (`total="Visitors"` names it, `total=false` leaves the hole empty; a `Pie` has no
  hole);
- a smooth line that never rises above or dips below its values, with a dot on each of up to 12 points, and under an
  `AreaChart`'s line a fill that fades to the foot of the plot;
- rounded bars no wider than 40 (`maxBarWidth=`), bars of several `series` side by side (`stacked`: one on
  another);
- a tooltip for what is under the pointer or a finger.

A key written on the line wins: `legend=false`, `tooltip=false`, `barRadius=0`, a series' own `"color"`.

{{reference}}

{{examples}}
