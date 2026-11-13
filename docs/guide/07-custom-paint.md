# 7. Drawing with `customPaint`

[Guide](README.md) · Previous: [Chart data transitions](06-chart-data-transitions.md)

`customPaint` is Flutter's `CustomPaint` as data: a behavior any node can carry (`lib/src/custom_paint.dart`).
Its `painter` list is drawn behind the node's content (its decoration and children), its `foregroundPainter`
list over it. Each op is one `dart:ui` `Canvas` call, with the method's name and its parameters' names, and
each `paint` is Flutter's `Paint`, with its field names and defaults. What a Flutter developer would write in a
`CustomPainter` translates line by line:

```dart
canvas.drawCircle(const Offset(30, 30), 20, Paint()..color = const Color(0xFF1E88E5));
canvas.drawLine(a, b, Paint()..color = ink..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round);
```

```json
{"customPaint": {"painter": [
  {"op": "circle", "c": [30, 30], "radius": 20, "paint": "#FF1E88E5"},
  {"op": "line", "p1": [4, 50], "p2": [56, 50],
   "paint": {"color": "#FF212121", "style": "stroke", "strokeWidth": 2, "strokeCap": "round"}}]}}
```

## The behavior

| Key | Default | Flutter |
|---|---|---|
| `painter` | `[]` | `CustomPaint.painter`: drawn before the content |
| `foregroundPainter` | `[]` | `CustomPaint.foregroundPainter`: drawn after it |
| `viewBox` | none | The ops' coordinates, `[width, height]` or `[minX, minY, width, height]`; none: the box's pixels |
| `fit` | `fill` | How the view box maps onto the box (`BoxFit`; `fill` stretches, as the `path` node's view box does) |
| `isComplex`, `willChange` | `false` | `CustomPaint.isComplex`, `willChange`: raster cache hints |

`CustomPaint.size` is the node's layout; `child` is the node's own content. Neither list clips: use
`decoration.clip` or a group's `clipRect`.

## Ops

Every op is `{"op": name, ...}` and may carry `id` (a stable name: editor selection and binding paths) and
`when` (false skips it). The shape ops also take `paint` and `hit`.

| `op` | Fields | Flutter |
|---|---|---|
| `path` | `d` (SVG path data), or `commands` (`Path` builder calls, below), or `points` (`[[x, y], ...]`, a `null` breaks the line; `close`), `fillType` (`nonZero`, `evenOdd`), `trimStart`, `trimEnd` (0–1 of its length) | `canvas.drawPath`; `PathMetric.extractPath` |
| `line` | `p1`, `p2` | `canvas.drawLine(p1, p2, paint)` |
| `rect` | `rect` (`[left, top, width, height]`) | `canvas.drawRect(rect, paint)` |
| `rrect` | `rect`, `radius` (`8`, `[x, y]` or `[tl, tr, br, bl]`) | `canvas.drawRRect(rrect, paint)` |
| `circle` | `c` (the center), `radius` | `canvas.drawCircle(c, radius, paint)` |
| `oval` | `rect` | `canvas.drawOval(rect, paint)` |
| `arc` | `rect`, `startAngle`, `sweepAngle` (radians, clockwise from 3 o'clock), `useCenter` | `canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint)` |
| `points` | `pointMode` (`points`, `lines`, `polygon`), `points` | `canvas.drawPoints(pointMode, points, paint)` |
| `paragraph` | `text`, `style` (a `TextStyle`), `offset`, `anchor` (which point of the text sits at `offset`, default top left), `maxWidth`, `textAlign`, `maxLines` | `TextPainter(...)..layout(maxWidth:)..paint(canvas, offset)`; a `paint` is the text's `foreground` |
| `image` | `url`, `src` (source rect; none: the whole image), `dst` (none: the whole drawing) | `canvas.drawImageRect(image, src, dst, paint)` |
| `group` | `ops`; `translate` (`[dx, dy]`), `scale` (`s` or `[sx, sy]`), `rotate` (radians), `transform` (16 numbers, column-major like `Matrix4.storage`), applied in that order; then `clipRect`, `clipRRect` (`{rect, radius}`), `clipPath` (SVG data); `opacity` and `blendMode` (either makes it a layer) | `canvas.save()` (or `saveLayer`), the transforms and clips, its ops, `canvas.restore()` |
| `repeat` | `each` (an expression giving a list) or `count`; `as` (default `item`), `indexAs` (default `index`); `ops` | `for (final (index, item) in list.indexed) { ... }` |

The decoder also reads an op spelled as its `Canvas` method (`drawCircle`, `drawRRect`, `drawImageRect`),
`text` for `paragraph`, and `center` for a circle's `c`; it writes the names above. An op type it doesn't know
is kept whole and written back, and draws nothing.

`group` is the only way to save and restore: a list can't leave the canvas unbalanced. `repeat` is the only
control flow: arithmetic is a formula.

### A path built call by call

A path op's `commands` are the calls a `CustomPainter` makes to build its `Path`, each with its positional
arguments (each a number or a formula) and an optional `when` (`if (cond) path.lineTo(...)`): `moveTo` and
`lineTo` take `[x, y]`, `quadraticBezierTo` `[x1, y1, x2, y2]`, `cubicTo` `[x1, y1, x2, y2, x3, y3]`, and
`close` is `{"close": true}`. The numbers reach the `Path` as written, with no SVG text between, so a drawing
ported from Dart draws the same pixels:

```dart
final path = Path()
  ..moveTo(0, size.height)
  ..quadraticBezierTo(size.width / 2, 0, size.width, size.height);
canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 2);
```

```json
{"customPaint": {"painter": [
  {"op": "path", "commands": [
     {"moveTo": [0, "${size.height}"]},
     {"quadraticBezierTo": ["${= size.width / 2}", 0, "${size.width}", "${size.height}"]}],
   "paint": {"style": "stroke", "strokeWidth": 2}}]}}
```

### Schema 3's special-purpose paint, in these terms

Schema 4 rewrites three schema-3 features as ops (codelessly_api's `paintSteps4`; docs/design/01-paint-node.md,
"Schema 4"), and validation notes each where it is (`deprecated_key`):

- **`strokePath`** (a line through points) is a `path` op in `painter` (`foregroundPainter` for `inFront`):
  `points`, a share of the box as `"${= 0.25 * size.width}"`, `curve` as `commands`, `progress` as `trimEnd`,
  the line `{"style": "stroke", "strokeWidth": 4, "strokeCap": "round", "strokeJoin": "round"}`, `fillColor` a
  closed op under it. Its draw-on animation (`drawMs`) has no form here: an animation on a variable bound into
  `trimEnd` does it.
- **A path's `subpathColors`** is one `path` op per color, its `d` the shapes of that color; a gradient laid out
  in each shape (`gradientPerSubpath`) is one op per shape with the gradient as its paint's `shader`.
- **A box's `props.path`** is a `path` node (`"type": "path"`, the path as `props.data`), the decorated shape.

## Paint

| Field | Default | Flutter's `Paint` |
|---|---|---|
| `color` | `#FF000000` | `color` |
| `shader` | none | `shader`: a gradient or image in the model's `Paint` form, laid out in the shape's bounds (`Gradient.createShader(rect)`) |
| `style` | `fill` | `style` (`fill`, `stroke`) |
| `strokeWidth` | `0` (a hairline) | `strokeWidth` |
| `strokeCap`, `strokeJoin`, `strokeMiterLimit` | `butt`, `miter`, `4` | the same |
| `blendMode`, `isAntiAlias` | `srcOver`, `true` | the same |
| `dashPattern` | `[]` | (none: a decoration's dashes) |
| `scaleStroke` | `true` | (none) `false` keeps the width and dashes in box pixels under a scaling view box or group |
| `id` | none | a stable name for binding paths |

A paint that is only a color is written as the color (`"paint": "#FF1E88E5"`). `paint` may be a list: the shape
is drawn once per paint, in order, as consecutive Flutter calls would (a fill, then a stroke). An op with no
`paint` draws nothing; with `hit` it is an invisible target.

## Expressions

Any value may be an expression, as an action's text fields may: `"${count}"`, `"${= radians(index * 6)}"`, a
whole point `"${item.p1}"` or one of its numbers `[0, "${= index % 5 == 0 ? -76 : -84}"]`, a paint
`"${pal[item]}"` (a color, or a paint object). Text fields (`d`, `text`, `url`, `hit`) hold `${...}` the way a
text node does. Besides the node's own names (screen variables, its list item...), an expression reads `size`
(`width`, `height`: the view box's when there is one, else the box's) and, inside a `repeat`, `item`, `index`
and `count` (the names `as` and `indexAs` give). Expressions sit in the ops rather than in the node's `bind`
map because a `repeat` gives names the node doesn't have.

A dial: 60 ticks, every fifth longer, and a needle at a variable's value.

```json
{"viewBox": [200, 200], "painter": [
  {"op": "circle", "c": [100, 100], "radius": 96, "paint": ["#FF1C2833", {"color": "#FF5D6D7E", "style": "stroke", "strokeWidth": 3}]},
  {"op": "repeat", "count": "${ticks}", "ops": [
    {"op": "group", "translate": [100, 100], "rotate": "${= radians(index * 360 / count)}", "ops": [
      {"op": "line", "p1": [0, -90], "p2": [0, "${= index % 5 == 0 ? -76 : -84}"],
       "paint": {"color": "#FFE8ECEE", "style": "stroke", "strokeWidth": "${= index % 5 == 0 ? 3 : 1.5}", "strokeCap": "round"}}]}]}],
 "foregroundPainter": [
  {"op": "group", "id": "needle", "translate": [100, 100], "rotate": "${= radians(value * 6)}", "ops": [
    {"op": "line", "p1": [0, 14], "p2": [0, -80], "paint": {"color": "#FFE74C3C", "style": "stroke", "strokeWidth": 3, "strokeCap": "round"}}]}]}
```

A board of cells from one list, each a hit region: the node's pointer reactions read the cell from
`${result.index}` (or from `${result.viewX}`, `${result.viewY}`).

```json
{"viewBox": [48, 48], "willChange": true, "painter": [
  {"op": "rect", "rect": [0, 0, 48, 48],
   "paint": {"shader": {"type": "radial", "stops": [{"position": 0.35, "color": "#FFF3E7B8"}, {"position": 1, "color": "#FFD9C27A"}]}}},
  {"op": "repeat", "each": "${cells}", "ops": [
    {"op": "rect", "when": "${= item != 0}", "rect": ["${= index % 48}", "${= floor(index / 48)}", 1, 1],
     "paint": "${pal[item]}", "hit": "cell"}]}]}
```

A function plot: data coordinates mapped by one group, the curve from a bound list of points, its stroke in
box pixels.

```json
{"painter": [
  {"op": "group", "translate": [20, 100], "scale": [40, -60], "ops": [
    {"op": "line", "id": "xAxis", "p1": [0, 0], "p2": [7, 0],
     "paint": {"color": "#FF263238", "style": "stroke", "strokeWidth": 1.5, "scaleStroke": false}},
    {"op": "path", "id": "curve", "points": "${curve}",
     "paint": {"color": "#FF1E88E5", "style": "stroke", "strokeWidth": 2.5, "strokeJoin": "round", "scaleStroke": false}}]},
  {"op": "repeat", "count": 8, "ops": [
    {"op": "paragraph", "text": "${index}", "offset": ["${= 20 + index * 40}", 104], "anchor": [0, -1],
     "style": {"fontSize": 10, "color": "#FF607D8B"}}]}]}
```

## Hit regions

An op with `hit` is a region (Flutter's `CustomPainter.hitTest`). The node's pointer reactions (`click`,
`doubleTap`, `pointerDown`/`Up`, `hover`, `drag`...) then add to `${result}`:

| Key | Value |
|---|---|
| `region` | the `hit` of the topmost region under the pointer, else `""` |
| `x`, `y` | the point in the node |
| `viewX`, `viewY` | the same point in view box coordinates |
| `item`, `index` | the `repeat` item the region was drawn for, when any |

A stroked, unfilled shape hits within half its width, or 8 pixels.

## Binding paths

`customPaint` binds like any behavior (DESIGN.md §5.1): `customPaint` (the whole value),
`customPaint.painter` (a whole list), and an op by its `id`, through groups:
`customPaint.painter.needle.rotate`, `customPaint.painter.board.ops.cell.paint.color`.

## Declarations

`BehaviorFields.customPaint`, `CustomPaintFields`, `DrawPaintFields` and `DrawOpSpecs` (one `DrawOpSpec` per op:
its label, its Flutter spelling and its fields, beside `DrawOpCommonFields`) describe all of it, as
`ActionSpecs` describes actions. A field that takes an expression has an `ExprCodec`: its type is the literal's,
so a panel shows that control with a formula toggle.

```dart
final spec = DrawOpSpecs.of('circle')!;
assert(spec.flutter == 'Canvas.drawCircle');
assert(spec.fields.first.key == 'c');
assert(CircleOpFields.radius.codec is ExprCodec);
```
