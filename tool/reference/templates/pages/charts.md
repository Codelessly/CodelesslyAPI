# Charts, gauges and indicators

## When to use

Showing numbers as pictures: progress bars and rings, activity spinners, badges, gauges, bar, line and series
charts, scatter plots and barcodes.

## Minimal example

A goal's progress as a bar bound to a variable, and a week as a bar chart:

{{example:pages/charts}}

## Reference

{{reference}}

## Patterns

### Progress from state

Bind the value (`"bind": {"props.value": "${done}"}`) with `max` the goal; `"animate": true` eases changes. A ring:
`progressBar` with `"shape": "arc"` (`arcSweepAngle` 360 for a full circle) or `circularProgressIndicator`.

### Charts from data

`barChart` and `lineChart` take plain lists (`values`, `labels`); bind them to computed variables
(`${= map(week, d => d.count)}`). `chart` draws series over data rows (`data`, `series`, `labelField`) as bars,
lines, areas, a timeline or a donut, with a selected index; `plotChart` plots x/y series with markers, ranges and
reference lines.

## Pitfalls

- Chart colours default to a dark theme's; set `color`, `gridColor` and the label colours on a light page.
- A chart's size is its node's layout: give it a fixed height.
- `value` above `max` is clamped.

## See also

[State](@page-state) (computing the numbers) · [lists](@page-lists) (a table of the same data) ·
[animation](@page-animation).
