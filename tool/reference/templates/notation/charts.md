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
  Donut values=[60,25,15] labels=["Rent","Food","Other"]
  Gauge 72 min=0 max=180 limit=100 unit="km/h"
```

Give a chart a height; its colors default to the accent and a set after it.

{{reference}}

{{examples}}
