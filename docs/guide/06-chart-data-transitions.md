# Chart data transitions

`chart`, `lineChart` and `plotChart` accept the same data-change controls as
`barChart`, `radialGauge` and `gaugeMeter`:

```json
{"type":"lineChart","props":{"animate":true,"animationDuration":700,
 "data":[{"x":0,"y":12},{"x":1,"y":28}]}}
```

`animate` defaults to `true`; `animationDuration` defaults to 700 milliseconds.
`false` or a zero duration applies new data immediately. Existing JSON needs no
migration, and default values remain omitted in sparse serialization. Initial
values and design-canvas previews are drawn at rest. A running SDK interpolates
numeric values when data changes, retargeting an interrupted transition from the
values currently painted.

## Matching data across updates

- `chart`: rows match by `labelField` (default `label`), then occurrence order for
  duplicate category labels. Without that field they match by row position.
  The declared series fields and area `fillTo` fields interpolate. Donuts use
  their first series field, or `value` without a series. Timelines interpolate
  their configured interval endpoints.
- `lineChart`: rows match by `xField`, then occurrence order for duplicate x
  values. Equivalent numeric strings/numbers and ISO timestamps share identity.
  Only `yField` values interpolate; x positions stay at their target values.
- `plotChart`: its samples are evenly spaced between `xMin` and `xMax`. The
  SDK samples the previous curve at each new sample's x before interpolating y,
  rather than pairing unrelated array indices when sample counts change.
- Explicit marker y values on line and plot charts match by marker x. A marker
  with no explicit y continues to follow its curve on `plotChart`; missing line
  marker y values remain absent.

The target row order and topology apply immediately. Entering values start at
zero, including plot samples outside the previous domain; removed rows disappear
immediately. Null/missing values stay absent rather than turning into other
categories' values. Empty data clears immediately and stops any old timeline.
Use stable, unique category labels or x values when the dataset is filtered or
reordered.

Colours, text labels, axis bounds, ranges, selection and other styling are not
interpolated and do not start or restart data motion. A domain edit during a
running plot transition changes the domain immediately while keeping its
current numeric progression. A change of chart kind or identity-field
configuration snaps the new model rather than morphing unrelated datasets.

Next: [Drawing with `customPaint`](07-custom-paint.md)
