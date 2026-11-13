# 01 · CustomPaint as data

Status: proposal. Scope: `codelessly_api` model, SDK renderer, editor panel.
Line references are to this worktree (`lib/src/...`), `CodelesslySDK/lib/src/...`
and `CodelesslyEditor/references/<app>/...` as read on 2026-11-13.

## 1. Problem

Flutter apps draw with `CustomPaint`. The model has no equivalent, so every
reference app that draws had to find another way.

**How often Flutter draws.** `grep -rn "extends CustomPainter" references/*/lib`
gives **250 painters in 51 of the 67 reference apps**. It is the most used
Flutter facility the model lacks.

**The six workarounds in the model today.**

| Workaround | Where | Reference use (apps; text grep of `editor/` and `tool/` build sources, an upper bound) |
|---|---|---|
| `plotChart` stretched into a Cartesian canvas | `widgets/indicators.dart:402`, spec at `:539` (68 props; 23 of them make it a Cartesian graph, added for plotter_v2 per its blockers: `clip`, `series`, `gridAnchor`, `gridStepY`, `minorDivisions`, `minorGridColor`, `originAxes`, `axisWidth`, `axisArrows`, `xAxisTitle`, `yAxisTitle`, `axisTitleStyle`, `labelBackground`, `labelMargin`, `selectionY`, `selectionSeries`, `selectionGuides`, `selectionXLabel`, `selectionYLabel`, `selectionTagColor`, `selectionTagStyle`, `selectionHaloRadius`, `selectionHaloColor`) | `originAxes`, `gridAnchor`, `axisArrows`, `gridStepY`, `minorDivisions`, `xAxisTitle`, `selectionGuides`: **1** each (plotter_v2, `editor/gen/graph.mjs:11-37`; `plotter_v2/blockers.md` rows 1, 4, 18) |
| SVG strings built by formulas or generators, bound to a `path` node's `props.data` | `widgets/media.dart:41` | `"props.data"` bound in 8 apps; path strings generated in Python/JS in most (safecracker `editor/gen/parts.py:23-40` builds dial ticks as `M… L…` text; apiary `editor/gen/hive_comb.py:220-231` builds a comb with 18 function variables) |
| `box.path` | `widgets/stack.dart:31` | not separable from `path` by grep |
| `strokePath` behavior | `behaviors.dart:2482` (16 fields) | 8 (apiary, lantern, lantern_v2, lineworks, lineworks_v2, ninefold_v2, strata, strata_v2) |
| `gradientPerSubpath`, `subpathColors` | `values/paint.dart:151`, `widgets/media.dart:63` | 0 and 2 (apiary, northstar) |
| Thousands of bound box nodes | — | petri_v2: a 48 × 48 `gridView` over `${cells}`, 2,304 boxes each with `decoration.fills[0]: ${pal[item]}` (`editor/build/bench.py:83-93`; `petri_v2/blockers.md` rows 1, 2). Flutter uses one painter (`lib/widgets/board.dart:311`). apiary: 4,269 nodes and 2.3 MB for one page, which crashed the editor (`apiary/blockers.md` rows 12, 13, 15, 20) |

Each workaround added surface that serves one drawing. None of them can draw
the next one.

## 2. Flutter grounding

| Flutter | Mirrored as |
|---|---|
| `CustomPaint({painter, foregroundPainter, size, isComplex, willChange, child})` (`widgets/basic.dart:849`) | the `customPaint` value: `painter`, `foregroundPainter`, `isComplex`, `willChange`; `size` is the node's layout; `child` is the node's own content |
| `CustomPainter.paint(Canvas, Size)` | a draw list; `${size.width}`, `${size.height}` in scope |
| `CustomPainter.shouldRepaint`, `CustomPainter({Listenable? repaint})` (`rendering/custom_paint.dart:153, 271`) | repaint when a value an op reads changes (§6) |
| `CustomPainter.hitTest(Offset)` (`rendering/custom_paint.dart:286`) | `hit` on an op (§5) |
| `Canvas.drawPath/drawLine/drawRect/drawRRect/drawCircle/drawOval/drawArc/drawPoints/drawParagraph/drawImageRect` | one op each (§3.2) |
| `Canvas.save/restore/translate/scale/rotate/transform/clipRect/clipRRect/clipPath/saveLayer` | the `group` op: a balanced save…restore |
| `Paint` (`color`, `shader`, `style`, `strokeWidth`, `strokeCap`, `strokeJoin`, `strokeMiterLimit`, `blendMode`) | the model's `Paint` (`values/paint.dart:139`) for `fill`, and a new `Stroke` value |
| `PathMetric.extractPath` | `trim` on a path op (the path node's `trimStart`/`trimEnd`) |

`Canvas` is `dart:ui`; its method names were not checked against a source
file here (the Flutter tree under `/opt/flutter/packages/flutter/lib/src` does
not contain `dart:ui`). The `widgets`/`rendering` names above were.

## 3. Proposed model

### 3.1 Where it lives: a behavior on any node

`CustomPaint` is a single-child wrapper, like `Hero`, `Draggable` and
`IgnorePointer`, and the model already carries those as flat node behaviors
(`behaviors.dart:3022`). So `customPaint` is a **behavior key available on
every node**. A leaf canvas is a `box` carrying it; a node with content
gets a background and a foreground painter around that content.

This is a recommendation, not the only option; a separate node type is
decision D1 in §10. The behavior form is chosen because `strokePath`
(a behavior today) and `box.path` then migrate without inserting wrapper
nodes.

```dart
/// Flutter's `CustomPaint`: draw lists behind and over the node's content.
@immutable
final class CustomPaint {
  const CustomPaint({
    this.painter = const [],
    this.foregroundPainter = const [],
    this.viewBox,
    this.fit = BoxFit.fill,
    this.isComplex = false,
    this.willChange = false,
  });

  /// Drawn behind the node's content (`CustomPaint.painter`).
  final List<DrawOp> painter;

  /// Drawn over the node's content (`CustomPaint.foregroundPainter`).
  final List<DrawOp> foregroundPainter;

  /// The coordinate space of the ops: `[width, height]` or
  /// `[minX, minY, width, height]`, mapped onto the node's box by [fit].
  /// Null: the box's own pixels. Same meaning as `PathProps.viewBox`.
  final List<double>? viewBox;

  /// How [viewBox] maps to the box. `fill` stretches (what the path node does).
  final BoxFit fit;

  /// Raster cache hints, as `CustomPaint.isComplex` / `willChange`.
  final bool isComplex, willChange;
}

/// How a shape is stroked: Flutter's `Paint` in `PaintingStyle.stroke`.
@immutable
final class Stroke {
  const Stroke({
    required this.paint,
    this.width = 1,
    this.cap = StrokeCap.butt,
    this.join = StrokeJoin.miter,
    this.miterLimit = 4,
    this.dash = const [],
    this.dashOffset = 0,
    this.nonScaling = false,
  });
  final Paint paint;            // solid, gradient or image; has blendMode, opacity
  final Expr<double> width;     // Paint.strokeWidth
  final StrokeCap cap;          // Paint.strokeCap
  final StrokeJoin join;        // Paint.strokeJoin
  final double miterLimit;      // Paint.strokeMiterLimit
  final List<double> dash;      // dash, gap, ... (no Flutter counterpart; Decoration.dashPattern)
  final Expr<double> dashOffset;

  /// Width and dashes stay in box pixels under a scaling viewBox or group
  /// (the path node's `scaleStroke: false`). Flutter spelling:
  /// `canvas.drawPath(path.transform(m.storage), paint)` on the unscaled canvas.
  final bool nonScaling;
}
```

`Expr<T>` is a literal of type `T` or an expression string (`"${count}"`,
`"${= index * 6}"`). Actions already work this way ("Text fields of an
action are expressions", `actions.dart:5-8`). A draw list is a small
program, and its `repeat` introduces `item`/`index`, so expressions sit in
the ops themselves rather than in the node's `bind` map. `bind` still
replaces a whole list: `"customPaint.painter": "${script.plot(view)}"`.
This choice is decision D2.

### 3.2 The draw ops

Every op is `{"op": name, ...}` and may carry:

| Field | Type | Meaning | Flutter spelling |
|---|---|---|---|
| `id` | String | Stable name: editor selection, `bind` path (`customPaint.painter.<id>`) | — |
| `fill` | `Paint` or color | Fills the shape | `Paint()..style = PaintingStyle.fill..color/shader` |
| `stroke` | `Stroke`, or color (width 1) | Strokes it, after the fill | `Paint()..style = PaintingStyle.stroke` |
| `when` | `Expr<bool>` (default true) | Skips the op | `if (cond)` |
| `hit` | `Expr<String>` | Makes the shape a hit region with this id (§5) | `CustomPainter.hitTest` |

| `op` | Own fields (all `Expr`) | Flutter spelling |
|---|---|---|
| `path` | `d` (SVG path data) **or** `points` (`[[x, y], ...]` or flat numbers; `null` breaks the line) with `close` (false) and `smooth` (false: straight segments; true: Catmull-Rom); `trim` (`[start, end]`, 0–1, default `[0, 1]`); `fillType` (`nonZero`/`evenOdd`) | `canvas.drawPath(path, paint)`; `PathMetric.extractPath` |
| `line` | `p1`, `p2` | `canvas.drawLine(p1, p2, paint)` |
| `rect` | `rect` (`[left, top, width, height]`), `radius` (`BorderRadius`, default 0) | `canvas.drawRect` / `drawRRect` |
| `circle` | `center`, `radius` | `canvas.drawCircle(c, radius, paint)` |
| `oval` | `rect` | `canvas.drawOval(rect, paint)` |
| `arc` | `rect`, `startAngle`, `sweepAngle` (degrees, clockwise, 0 at 3 o'clock), `useCenter` (false) | `canvas.drawArc(rect, a, b, useCenter, paint)` (radians) |
| `points` | `points`, `pointMode` (`points`/`lines`/`polygon`) | `canvas.drawPoints(mode, points, paint)` |
| `text` | `text`, `style` (`TextStyle`), `offset`, `anchor` (`Alignment`, default top left: which point of the paragraph sits at `offset`), `maxWidth`, `textAlign` | `TextPainter(text: TextSpan(...))..layout(maxWidth:)..paint(canvas, offset)` |
| `image` | `url`, `rect`, `src` (source rect, optional), `fit` | `canvas.drawImageRect(image, src, dst, paint)` |
| `group` | `ops`; `translate` (`[dx, dy]`), `scale` (`n` or `[sx, sy]`), `rotate` (degrees), `transform` (16 numbers), applied in that order; `clipRect`, `clipRRect` (`{rect, radius}`), `clipPath` (SVG data); `opacity`, `blendMode` (either one makes it a layer) | `canvas.save(); canvas.translate/scale/rotate/transform(...); canvas.clipRect(...); ...; canvas.restore();` `canvas.saveLayer(null, Paint()..color/blendMode)` |
| `repeat` | `each` (a list expression) **or** `count`; `as` (default `item`); `ops` | `for (final (index, item) in list.indexed) { ... }` |

Decisions:

* **`group` instead of loose `save`/`restore`.** A data list cannot leave the
  canvas unbalanced, and the editor shows a tree.
* **Angles are degrees**, as everywhere in the model (`layout.rotation`,
  `motion.rotate`). The Flutter spelling converts.
* **`repeat` is the only control flow.** No variables, no arithmetic ops:
  those are formulas. Inside it `${item}`, `${index}` and `${count}` read
  like a list item's scope.
* **Scope.** Ops read the node's scope (screen variables, list item,
  `track`, `animation`...) plus `size` (`width`, `height`: the viewBox size
  when one is set, else the box's).

### 3.3 Worked examples

**safecracker's dial ticks** (today: Python writes three `M… L…` strings,
`editor/gen/parts.py:23-40`; Flutter: `_FacePainter`, `lib/widgets/dial.dart:390`).
One node, any number count, bound:

```json
{"type": "box", "name": "Dial face",
 "customPaint": {"viewBox": [200, 200], "painter": [
   {"op": "repeat", "count": "${numbers}", "ops": [
     {"op": "group", "translate": [100, 100], "rotate": "${= index * 360 / numbers}", "ops": [
       {"op": "line", "p1": [0, -92.5],
        "p2": [0, "${= index % 5 == 0 ? -81.5 : -87.5}"],
        "stroke": {"paint": "#FFE8ECEE", "width": "${= index % 5 == 0 ? 2 : 1}"}}]}]}]}}
```

**petri_v2's board** (today: 2,304 bound boxes; Flutter: `_CulturePainter`).
One node; a pointer reads the cell from `${result.x}`, `${result.y}`:

```json
{"type": "box", "name": "Agar",
 "customPaint": {"viewBox": [48, 48], "willChange": true, "painter": [
   {"op": "rect", "rect": [0, 0, 48, 48],
    "fill": {"type": "radial", "stops": [{"color": "#FFF3E7B8", "position": 0.35}, {"color": "#FFD9C27A", "position": 1}]}},
   {"op": "repeat", "each": "${cells}", "ops": [
     {"op": "rect", "when": "${= item != 0}",
      "rect": ["${= index % 48}", "${= floor(index / 48)}", 1, 1], "fill": "${pal[item]}"}]}]},
 "actions": [{"trigger": {"type": "pointerDown"}, "actions": [
   {"type": "runScript", "script": "paint", "arguments": {"cell": "${= floor(result.viewY) * 48 + floor(result.viewX)}"}}]}]}
```

**plotter_v2's graph** (today: `plotChart` with 23 Cartesian props and 15
bindings, `editor/gen/graph.mjs:11-37`; Flutter: `GraphPainter`,
`lib/ui/graph_view.dart:269`). The data-to-pixel mapping is one `group`;
curves keep their pixel line weight with `nonScaling`; labels are placed by
formula outside the group:

```json
{"type": "box", "name": "Graph sheet",
 "customPaint": {"painter": [
   {"op": "group", "clipRect": [0, 0, "${size.width}", "${size.height}"],
    "translate": ["${= -m.xMin * size.width / (m.xMax - m.xMin)}", "${= m.yMax * size.height / (m.yMax - m.yMin)}"],
    "scale": ["${= size.width / (m.xMax - m.xMin)}", "${= -size.height / (m.yMax - m.yMin)}"],
    "ops": [
      {"op": "repeat", "each": "${m.grid.lines}", "ops": [
        {"op": "line", "p1": "${item.p1}", "p2": "${item.p2}",
         "stroke": {"paint": "${= item.major ? '#FFC9CCBE' : '#FFE3E5DA'}", "nonScaling": true}}]},
      {"op": "line", "id": "xAxis", "p1": ["${m.xMin}", 0], "p2": ["${m.xMax}", 0],
       "stroke": {"paint": "#FF1D2B2F", "width": 1.5, "nonScaling": true}},
      {"op": "repeat", "each": "${m.series}", "ops": [
        {"op": "path", "points": "${item.points}", "hit": "${item.id}",
         "stroke": {"paint": "${item.color}", "width": 2.2, "join": "round", "nonScaling": true}}]}]},
   {"op": "repeat", "each": "${m.grid.labels}", "ops": [
     {"op": "text", "text": "${item.text}", "offset": ["${item.px}", "${item.py}"], "anchor": [0, -1],
      "style": {"fontFamily": "JetBrains Mono", "fontSize": 11, "color": "#FF5B6B70"}}]}]}}
```

Arrowheads, markers, trace guides and the selection tag are more ops of the
same kinds. `m` is what the app's `plotter` script already computes; it
adds grid line and label positions, which `plotChart` computed internally.

**apiary's comb** (today: 18 function variables emitting SVG text into 22
path nodes per frame card, `editor/gen/hive_comb.py`). One node per frame:

```json
{"customPaint": {"viewBox": [1000, 560], "painter": [
  {"op": "repeat", "each": "${combCells(g)}", "ops": [
    {"op": "group", "translate": ["${combX(item, g)}", "${combY(item, g)}"], "ops": [
      {"op": "path", "d": "${g.hex}", "fill": "${cellFill(item, frame)}",
       "stroke": {"paint": "#33FFFFFF", "width": 1}}]}]}]}}
```

## 4. Editor panel

`CustomPaintFields`, `StrokeFields` and one `*Fields` class per op are
`PropDef`s like every other model (`behavior_fields.dart`). Two additions to
the declaration vocabulary are needed:

* `PropType.expression(inner)`: a value or an expression. The panel shows the
  inner control with a formula toggle. `ExprCodec<T>` wraps the inner codec.
* `PropType.union('DrawOp', discriminator: 'op', variants: {...})`: a list
  item whose fields depend on a discriminator. The panel shows an op list
  (a tree for `group`/`repeat`), an "add op" menu from the variants, and the
  selected op's generated fields. `ActionDef` panels already need this shape
  (`action_fields.dart`); doc 05 makes it one mechanism.

The panel is: Painter | Foreground tabs, the op tree, the selected op's
fields, View box and Fit, the two raster hints. The design canvas draws the
list with expressions at their design-time values, as it does bindings.

## 5. Hit regions

An op with `hit` is a region. The node's existing pointer triggers (`click`,
`doubleTap`, `longPress`, `hover`, `cursorEnter`/`Exit`, `pointerDown`/`Up`,
`drag`) then add to `${result}`:

| Key | Value |
|---|---|
| `region` | the `hit` id of the topmost region under the pointer, else `""` |
| `x`, `y` | local pixels in the node (already given for `click`, `triggers.dart:13-15`) |
| `viewX`, `viewY` | the same point in viewBox coordinates |
| `item`, `index` | the `repeat` scope the region was drawn in, when any |

A stroked, unfilled path hits within half its width or 8 px, whichever is
larger. A region needs no ink: an op with `hit` and neither `fill` nor
`stroke` is an invisible target. With no regions the node behaves as now.

## 6. Repaint, compilation and performance

* **Compiled once.** `NodeBindings` already compiles a node's bindings once
  and watches only the names each reads (DESIGN.md §5.1). The draw list
  compiles the same way into a `CompiledPainter`: literals become `ui.Path`,
  `ui.Paint` and `TextPainter` objects up front; each expression becomes a
  closure with its dependency names.
* **What repaints.** A change of a name an op reads, or of the node's
  `customPaint` value. Nothing else. There is no per-frame repaint; an
  animated drawing reads `${animation.<name>.value}` (doc 02) and repaints
  because that value changed. `shouldRepaint` is value equality of the
  compiled list's inputs.
* **Picture caching.** Consecutive ops with no dependencies, or whose
  dependencies did not change this frame, are recorded once into a
  `ui.Picture` and replayed. plotter_v2's grid does not re-record while the
  trace moves. `isComplex`/`willChange` pass to the layer as in Flutter.
* **`repeat` batching.** A `repeat` whose body is one `rect`, `circle` or
  `line` with a solid paint is drawn as one `Path` per distinct paint
  (petri_v2: at most one path per palette entry, not 2,304 draw calls).
  Expressions in a repeat body are evaluated in a tight loop with one
  reused scope object, not through the binder.
* **Cost stated honestly.** petri_v2 evaluates about 3 formulas × 2,304
  items per generation. That is one pass in one render object; today it is
  2,304 node scopes (`petri_v2/blockers.md` row 2). Not measured yet; the
  rollout's first step is a benchmark with this board.
* **Painter vs foreground.** `painter` paints before the node's decoration
  content and children, `foregroundPainter` after, both inside the node's
  transform and opacity. Neither clips; use `decoration.clip` or a
  `group.clipRect`.

## 7. SDK implementation

| Piece | Reuses / replaces | LOC (estimate) |
|---|---|---|
| `RenderCustomPaintList` (one render object, two compiled lists) | new; SVG parsing from `render/paint/svg_path.dart`, fills from `render/paint/node_paint.dart` and `image_fill.dart`, dashes and trim from `render/paint/path_paint.dart` | +700 |
| Compiler and repeat evaluator | new, over `runtime/expressions` | +400 |
| `RenderStrokePath` + `StrokePathPainter` (`render/behaviors.dart:179, 1314`) | removed, about −300 |
| `plotChart` Cartesian branch in `widgets/indicators_charts.dart` (1,890 lines) and `indicators_paint.dart` (972) | removed, about −600 (not measured line by line) |

Net about +200 lines in the SDK for a general facility; about −350 in the
API package (`StrokePath`, 23 chart props, `subpathColors`,
`gradientPerSubpath`).

## 8. Migration

| Today | New location | How | Apps |
|---|---|---|---|
| `strokePath.points`, `xUnit`, `yUnit`, `curve` | `customPaint.painter[0]` = `{op: path, points, smooth}`; fraction units become a viewBox `[1, 1]` axis scale in a `group` | mechanical, in the `Behaviors` decoder | 8 |
| `strokePath.color`, `width`, `cap`, `dashPattern` | that op's `stroke` (`nonScaling: true`) | mechanical | 8 |
| `strokePath.progress` (and its binding) | the op's `trim: [0, progress]`; `bind` key `strokePath.progress` → an `Expr` in `trim` | mechanical | strata, strata_v2 |
| `strokePath.inFront` | the op goes in `foregroundPainter` | mechanical | lineworks, ninefold_v2 |
| `strokePath.fillColor` | the op's `fill`, with `close: true` | mechanical (the "alpha times progress" fade becomes an explicit expression) | — |
| `strokePath.untilWidth` | removed; `when: "${= size.width >= n}"` | by hand (1 app: lantern_v2) | 1 |
| `strokePath.drawMs`, `drawDelayMs`, `drawCurve`, `drawKey` | an animation with one track on the op's `trim` (doc 02 preset `draw`) | mechanical | 0 in build sources, 1 blocker |
| `path` node (`data`, `viewBox`, `scaleStroke`, `trimStart`, `trimEnd`, `strokeJoin`) | **kept.** It is the decorated shape (fills, strokes, shadows from `decoration`); `customPaint` is the general canvas | none | 61 |
| `path.subpathColors` | removed → a `repeat` over the subpaths' data with `fill: ${colors[index]}` | by hand | apiary, northstar |
| `Paint.gradientPerSubpath` (`gradientUnits: "subpath"`) | removed → one op per shape; each op's gradient is laid out in its own bounds | by hand | 0 in build sources |
| `box.path`, `box.strokeJoin`, `box.strokeMiterLimit` | removed → the node decodes as a `path` node with `data` = the path (both are decorated leaves) | mechanical, in `Node.fromJson` | not counted |
| `plotChart` props added for the Cartesian graph (the 23 listed in §1) | removed → `customPaint` | **by hand**: the graph's grid, axes, labels and trace become ops fed by the app's script | plotter_v2 |
| `plotChart` (remaining 45 props: points, ranges, markers, selection, yLines...) | kept for now; candidate hosted plugin (doc 05) | none | petri_v2, tally, tally_v2 |
| Bound-box grids | one `customPaint` | by hand | petri_v2, apiary |

## 9. Compatibility

Documents stay `"schema": 2`. Decoders read `strokePath` and `box.path` and
produce the new values; encoders write only the new shape. Bind keys under
`strokePath.` are rewritten by the same decoder. What cannot be migrated
mechanically: `plotChart`'s Cartesian props (the chart computed grid and
label positions that a draw list must be given), `subpathColors`,
`gradientPerSubpath`, `untilWidth`. Until plotter_v2 is rebuilt the SDK
keeps reading those chart props for one release, marked deprecated; they
are removed in the release after.

## 10. Open questions for the owner

1. **D1. Behavior or node type?** Recommended: behavior key `customPaint` on
   any node (matches `CustomPaint(child:)`, migrates `strokePath` without
   wrapper nodes). Alternative: a `customPaint` node type with one `child`
   slot (one more type in the catalog; `strokePath` migration then inserts
   nodes).
2. **D2. Inline expressions in ops**, as actions have them (recommended), or
   every bound value in the node's `bind` map under `customPaint.painter.<id>.<field>`.
3. **Stroke width default.** `Stroke.width` defaults to 1 like
   `Decoration.strokeWidth` (`decoration.dart:68`). Flutter's
   `Paint.strokeWidth` default is 0 (hairline). Keep 1?
4. **How long `plotChart`'s Cartesian props stay readable** (one release
   proposed).

## 11. Rollout

1. API: `CustomPaint`, `Stroke`, `DrawOp` union, `Expr`, the two `PropType`
   additions, `*Fields`, round-trip tests in `value_fields_test.dart`.
2. SDK: compiler, render object, hit regions; benchmark with petri_v2's
   board (target: a generation step under 4 ms on the reference laptop,
   to be confirmed by measurement).
3. Decoder migration for `strokePath` and `box.path`; goldens for the 8
   `strokePath` apps must not change.
4. Editor: generated op-list panel.
5. Rebuild plotter_v2's graph, petri_v2's board, apiary's comb and
   safecracker's ticks on it; then delete the Cartesian chart props,
   `subpathColors` and `gradientPerSubpath`.

## Deviations from the proposal

Implemented in `lib/src/custom_paint.dart` and `custom_paint_fields.dart` (SDK:
`lib/src/render/custom_paint.dart`). Decided by the owner: a behavior on any node (D1), expressions inline in
the ops (D2), `group` instead of loose save/restore. Where the proposal and "Flutter's name and shape first"
disagreed, Flutter won. Every `Canvas` and `Paint` name below was checked against
`/opt/flutter/bin/cache/pkg/sky_engine/lib/ui/painting.dart`.

1. **One `paint` per call, Flutter's `Paint`, instead of `fill` plus a `Stroke` value.** Flutter draws a shape
   with one `Paint` whose `style` is `fill` or `stroke`; the proposal's `Stroke` renamed its fields (`width`,
   `cap`, `join`, `miterLimit`). An op has `paint`: a `DrawPaint` with `Paint`'s names and defaults (`color`,
   `style`, `strokeWidth`, `strokeCap`, `strokeJoin`, `strokeMiterLimit`, `blendMode`, `isAntiAlias`), a
   gradient or image as `shader` (the model's `Paint` JSON, laid out in the shape's bounds as
   `createShader(rect)`), plus `dashPattern` (the decoration's name) and `scaleStroke` (the `path` node's name
   for the proposal's `nonScaling`, inverted). `paint` may be a list, drawn in order, which is a fill then a
   stroke written as two Flutter calls would be, without repeating the geometry. A paint that is only a color is
   written as the color.
2. **`strokeWidth` defaults to 0, a hairline, as Flutter's** (open question 3). `{"style": "stroke"}` is then
   exactly `Paint()..style = PaintingStyle.stroke`; the conformance tests rely on it.
3. **Angles are radians** (`arc.startAngle`, `sweepAngle`, `group.rotate`). With Flutter's parameter names,
   degrees would be a trap for a mechanical translation from `CustomPainter` code. Formulas have `pi` and
   `radians()`: `"${= radians(index * 6)}"`.
4. **Op and parameter names are the `Canvas` method's.** `circle.c` (`drawCircle(Offset c, ...)`; `center` is
   read too). `rect` and `rrect` are two ops (`drawRect`, `drawRRect`), not a `rect` with a `radius`. The text op
   is `paragraph` (`drawParagraph`; `text` is read too). `image` takes `src` and `dst` (`drawImageRect`), not
   `rect` and `fit`. The decoder reads every op spelled as its method (`drawCircle`, `drawRRect`,
   `drawImageRect`) and writes the short name.
5. **Path:** `trim: [start, end]` became `trimStart`, `trimEnd` (the `path` node's names); `smooth`
   (Catmull-Rom) is not built: it is no Flutter call, and the curves `strokePath` needs are decided in its
   migration wave.
6. **No new `PropKind`s.** `PropType.expression` and `PropType.union` would add values to `PropKind`, and the
   editor's properties package switches over it exhaustively, so this additive wave would break its build.
   Instead: a field that takes an expression has an `ExprCodec` whose type is the literal's (a panel checks
   `codec is ExprCodec` to offer the formula toggle), and ops are declared as `DrawOpSpecs`, one `DrawOpSpec`
   per op with its fields beside `DrawOpCommonFields`, exactly as `ActionSpecs` declares actions; a list of ops
   is typed `PropType.json('DrawOp')`. Doc 05's single union mechanism can take both over. Until the editor has
   an op-list panel, its coverage test should list `DrawOp` among the types shown as JSON by design.
7. **`repeat.indexAs`** was added beside `as`: a 2D list needs the outer index inside the inner repeat.
8. **View box** is held as `[minX, minY, width, height]`; `[width, height]` reads, and is written when the origin
   is 0. Other fits than `fill` center the view box (`Alignment.center`) and clip to the box.
9. **Caching is per top-level op**, each its own `ui.Picture` replayed until a name it reads changes, the box
   resizes or an image it waits for arrives. Consecutive static ops are not merged into one picture and a
   `repeat` of one rect is not batched into one path per color: measured, a 48 × 48 board (2,304 rects, three
   expressions each) records in about 60 ms in a debug test run, once per change of its data.
10. **Values come through a render-owned contract.** The render core imports no runtime code, so it reads
    expressions through `ExpressionValues` (render/contracts.dart), which the runtime's values implement. A
    tree without bindings draws the literals only; a design canvas draws expressions at the values its binder
    gives (the variables' defaults).
11. **Hit regions** report `region`, `x`, `y`, `viewX`, `viewY`, `item`, `index`, added to `${result}` of the
    node's pointer triggers only when the node has a `customPaint`. A paragraph's region is its laid-out box,
    an image's its `dst`.
12. **Not migrated in this wave:** `strokePath`, `box.path`, `subpathColors`, `gradientPerSubpath` and
    `plotChart`'s props are unchanged; their decoders still read and write them as before.

## Done in schema 3

`gradientUnits: "subpath"` is migrated to `gradientPerSubpath: true` (`paint.gradientUnits`). **Not done:**
moving `strokePath`, `box.path`, `gradientPerSubpath`/`subpathColors` and the plot chart's canvas props onto
`customPaint` (schema-3 step 4): each needs a synthesized draw list proven pixel-equal against the goldens of
its users (strata, lineworks, ninefold_v2, apiary, northstar, plotter_v2); not started.
