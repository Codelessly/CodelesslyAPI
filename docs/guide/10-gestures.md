# 10. Gestures: tracks, dismissibles, pans, drag and drop

[Guide](README.md) · Previous: [Catalogs, libraries and plugins](09-catalogs-and-plugins.md)

A node that is dragged is one of five behaviors, each named after the Flutter widget it is
(docs/design/04-drag-and-track.md):

| Behavior key | Flutter | What it does |
|---|---|---|
| `track` | `Slider`, generalised from a bar to a line, an arc or a path | The node is a thumb setting a value: a fader, a knob, a dial, a scrubber |
| `dismissible` | `Dismissible` | Swiped away past a threshold: a card deck, a row to delete |
| `pan` | `GestureDetector(onPanUpdate:)` + `Transform.translate` | Follows the pointer and springs back or stays: a bottom sheet, a puck |
| `draggable`, `dropTarget` | `Draggable` / `LongPressDraggable`, `DragTarget` | Picked up and dropped somewhere else |
| `transformGesture` | `InteractiveViewer` | Pinch, pan and rotate (unchanged; `zoomable: true` is its short form) |

A list's rows reorder by the list's own `reorder` prop (`ReorderableListView`); a node inside a row with
`"reorderHandle": true` is the handle they are dragged by (`ReorderableDragStartListener`). A node that only
needs to hear a drag uses the `drag` and `dragEnd` triggers and moves nothing.

Each sample below is checked by `test/drag_split_test.dart`: a block marked `json legacy` is the old shape,
read as the block after it, which is what the model writes.

## `track`: a value set by dragging

| Key | Default | Flutter / meaning |
|---|---|---|
| `enabled` | `true` | Off, no pointer, wheel or keys move it |
| `variable` | | The number variable read and written (`Slider.value` / `onChanged`) |
| `value` | | Usually bound (`track.value`): drawn at it instead of reading `variable` |
| `min`, `max`, `step` | 0, 1, 0 | `Slider.min`, `max`; `divisions` = (max − min) / step, 0 continuous |
| `clamp` | `true` | Off, an arc keeps turning past its ends and the value counts on (a combination dial) |
| `input` | `follow` | `follow` (along the line or path, round the arc), `vertical`, `horizontal`, `both` (dx − dy) |
| `allowedInteraction` | `slideThumb` | `SliderInteraction`: `slideThumb`, or `tapAndSlide` (pressing the track moves the thumb there) |
| `hitArea` | `self` | `parent`: anywhere in the node's parent takes the pointer too |
| `pixelsPerRange` | 200 | Pixels of `vertical`/`horizontal`/`both` drag for the whole range |
| `wheelStep`, `keyStep` | step, else 1% | One wheel notch, one arrow key; 0 turns the wheel or the keys off |
| `shape` | `line` | `line` (`x1`, `y1`, `x2`, `y2` from the node's place; `relative`, `units`), `arc` (`startAngle`, `sweepAngle`, `pivotX`, `pivotY`, `rotate`), `path` |
| `path` | | `{path, viewBox, orient}`, the shared `PathFollow`: SVG data in pixels from the node's place, or in a view box stretched over the parent; `orient` `tangent` or `upright` turns the node with it |
| `detent`, `overscroll` | 0 | How magnetic steps are while dragging; how far past an end it stretches |
| `physics` | | A release coasts: `{"fling": true, "friction": 0.9}` (`FrictionSimulation`), then settles on a step |
| `settle`, `settleCurve`, `settleSpring`, `snap`, `snapCurve` | | How the thumb moves to a value set from elsewhere |

Inside it `${track.value}`, `${track.progress}`, `${track.dragging}`, `${track.focused}` can be read. It fires
`changed` (`${result.value}`, `from`, `direction`, `crossed`: every step passed), `dragEnd` and `changeEnd`.

A knob that turns in place (an arc about its own center) by angle, the wheel off:

```json legacy
{"drag": {"track": {"shape": "arc", "variable": "bpm", "min": 30, "max": 250, "step": 1, "endAngle": 135, "wheel": false, "jumpOnTap": true}}}
```

```json
{"track": {"variable": "bpm", "min": 30, "max": 250, "step": 1, "allowedInteraction": "tapAndSlide", "wheelStep": 0, "shape": "arc"}}
```

A combination dial: unclamped, coasting when flicked (the legacy `friction` 2.6 was a rate per second; the
same coast loses 0.9257 of its speed a second):

```json legacy
{"drag": {"track": {"shape": "arc", "variable": "dialTurns", "max": 100, "step": 1, "startAngle": 0, "endAngle": 360, "endless": true, "momentum": true}}}
```

```json
{"track": {"variable": "dialTurns", "max": 100, "step": 1, "clamp": false, "shape": "arc", "startAngle": 0, "sweepAngle": 360, "physics": {"friction": 0.9257}}}
```

Schema 3 dropped the one-app track fields (`smooth`, `gain` round an arc, `parkedProgress`, the fine mode,
`defaultValue`/`doubleTapValues`): the migration keeps such a value as `legacy.track.<field>`, unread, and its
report says what to write instead (docs/guide/12-migrating-to-schema-3.md).

A playhead that only shows its variable (its reactions seek): `write: false` became a bound value.

```json legacy
{"drag": {"track": {"variable": "playhead", "write": false, "x2": 300, "y2": 0, "jumpOnTap": true, "keyboard": false}}}
```

```json
{"bind": {"track.value": "${playhead}"}, "track": {"allowedInteraction": "tapAndSlide", "keyStep": 0, "x2": 300, "y2": 0}}
```

A thumb on an arc drawn in a view box over its parent, upright:

```json
{"track": {"variable": "rating", "min": 1, "max": 5, "step": 1, "path": {"path": "M80 300 A220 220 0 0 1 520 300", "viewBox": [600, 320], "orient": "upright"}}}
```

`controlTrack` turns a track from elsewhere: `step` by `steps` (`"-1"`, or an expression), as a drag would,
or `animateTo` a `value`, reported as one change:

```json
{"type": "controlTrack", "node": "dial", "command": "animateTo", "value": "${= target}"}
```

## `dismissible`: swiped away

| Key | Default | Flutter |
|---|---|---|
| `enabled` | `true` | |
| `directions` | `["left", "right"]` | `Dismissible.direction`; its names `horizontal`, `vertical`, `endToStart`, `startToEnd`, `up`, `down`, `none` read too |
| `axis` | `free` | `free` moves both ways, the other ways held back by `resistance` |
| `dismissThresholds` | 0.4 each | `{"up": 0.25}`: the share of its size a drag must travel |
| `flingVelocity` | 700 | px/s along a direction past which a release dismisses however short |
| `resistance` | 0 | 0–1 of the travel toward a direction it can't go that is ignored |
| `movementDuration`, `curve` | 200, `linear` | The fly-off |
| `returnDuration`, `returnCurve`, `returnSpring` | the fly-off's | The return when let go short; a `Spring` carries the release's speed |

Let go past a threshold it flies off and fires the swipe of that direction (`swipeLeft`...), then shows its next
content at rest. Inside it `${dismiss.dx}`, `dy`, `progress` (0–1 toward the threshold), `direction`,
`dragging` can be read; it fires `drag` and `dragEnd`. The legacy `drag` with `release: dismiss` reads as it
with its old defaults written out:

```json legacy
{"drag": {"release": "dismiss", "directions": ["left", "right", "up"], "verticalThreshold": 0.25, "resistance": 0.6}}
```

```json
{"dismissible": {"directions": ["left", "right", "up"], "dismissThresholds": {"left": 0.35, "right": 0.35, "up": 0.25, "down": 0.25}, "flingVelocity": 800, "resistance": 0.6, "movementDuration": 320, "curve": "easeIn", "returnDuration": 450, "returnCurve": "spring"}}
```

A new deck with Flutter's defaults, an upward swipe at a quarter of the height:

```json
{"dismissible": {"directions": ["left", "right", "up"], "dismissThresholds": {"up": 0.25}, "returnSpring": {"duration": 450, "bounce": 0.25}}}
```

`controlDismissible` flies it off (`dismiss`, a button "Nope"), brings it back from a side (`returnFrom`, an
undo: a card built in the next frame starts off-screen there) or springs it home (`reset`):

```json legacy
{"type": "controlDrag", "node": "card", "command": "fling", "direction": "left"}
```

```json
{"type": "controlDismissible", "node": "card", "direction": "left"}
```

## `pan`: following the pointer

`axis`, `release` (`snapBack` or `stay`), `returnDuration`/`returnCurve` (450, `spring`), the rest offset `x`,
`y` (bindable), `xVariable`/`yVariable` (written as it moves), `physics` (fling, spring, `snap` points),
`bounds` and the limits `minX`...`maxY` (offsets from rest). `${pan.dx}`, `dy`, `dragging`, `settling`,
`snapIndex` read inside it. A bottom sheet:

```json legacy
{"drag": {"axis": "vertical", "release": "stay", "minY": -560, "maxY": 0, "yVariable": "sheetY", "physics": {"snap": {"points": [[0, 0], [0, -560]]}}}}
```

```json
{"pan": {"axis": "vertical", "release": "stay", "yVariable": "sheetY", "physics": {"snap": {"points": [[0, 0], [0, -560]]}}, "minY": -560, "maxY": 0}}
```

## Drag and drop

`draggable` is Flutter's `Draggable`: `group`, `data`, `start` (`press`, `longPress` as `LongPressDraggable`,
`auto`), `axis`, `childWhenDragging` (`ghost` at `ghostOpacity`, `hidden`, `keep`), `feedback` (a node id drawn
under the pointer), `dragAnchor` (`child`: where grabbed; `center`), the feedback's `feedbackRotation`,
`feedbackScale`, `feedbackOpacity`, `feedbackElevation`, and `returnSpring` (a `Spring`, default
`{"stiffness": 260, "damping": 14}`; `false`: none). `dropTarget` is `DragTarget`: `accepts`, `acceptIf`, a list
to insert into (`listNodeId`, `slot`, `slotNodeId`, `slotSize`; the slot opens for drags it accepts). `${drag.*}` reads the session.

```json legacy
{"draggable": {"group": "cards", "whileDragging": "hidden", "feedbackNodeId": "ghost", "feedbackAnchor": "center", "returnSpring": false}}
```

```json
{"draggable": {"group": "cards", "childWhenDragging": "hidden", "feedback": "ghost", "dragAnchor": "center", "returnSpring": false}}
```

A row's reorder handle:

```json legacy
{"drag": {"reorder": true}}
```

```json
{"reorderHandle": true}
```

## `transformGesture`

Unchanged (DESIGN.md §4.1). `controlTransform` resets it, scales it (`scaleBy`) or springs it to a pose
(`animateTo`, `{x, y, scale, rotation}`); a `reset` on a node without one resets its dismissible or pan.

```json legacy
{"type": "controlDrag", "node": "map", "command": "zoom", "value": "1.5"}
```

```json
{"type": "controlTransform", "node": "map", "command": "scaleBy", "value": "1.5"}
```

```json legacy
{"zoomable": true}
```

```json
{"transformGesture": {"target": "content", "pan": "whenZoomed"}}
```
