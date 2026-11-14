# The audit's verdict

Written 2026-11-13, at the end of the audit that began with one question: after the features that made a
graphing calculator, a drag-and-drop kanban board, a piano keyboard, animation paths and games possible, do the
API and the SDK still follow their path, **Flutter SDK API → data model → SDK that renders it → feature layers
on top**, or had they become a pile of workarounds?

## 1. What the audit found

- **The data model had drifted from Flutter's names.** About a third of prop names matched Flutter's. The rest
  were renamed, merged or invented. (After the cleanup, by a recorded method: 61% of declared fields, 78% of those
  with a Flutter counterpart; section 6.)
- **The SDK was not a mirror of Flutter's widgets and never needed to be.** It lays out and paints nodes with its
  own render objects on Flutter's rendering pipeline; real Flutter widgets appear only as islands for Material
  controls. That is a sound design, and it is why flat, editable data works.
- **44% of the fields added to unblock a reference app were special cases for that one app.**
- **Three general primitives were missing**, and their absence is what produced the special cases: custom
  painting, a frame clock with animation, and an extension point for what the catalog lacks.
- **Feature layers were tangled into the renderer.** Auth, data, commerce, media and messaging code could not be
  separated from drawing.

## 2. What was changed

| Area | Before | After |
|---|---|---|
| Painting | one-off props (`strokePath`, a box's `path`, per-subpath colours, a dial, a plot's extras) | `customPaint`: draw ops that mirror Flutter's `Canvas`, `Path` and `Paint`; a `path` node |
| Animation | per-feature timers and tweens | `animations` with one `Spring`, an `animate` action, a `frame` trigger |
| Motion | 50 fields, plus a separate node `scale` and `layout.rotation` | `motion` with 14 fields (Flutter's `Transform`), a `PathFollow`; scale and rotation folded in |
| Dragging | one `drag` with modes | `track`, `dismissible`, `pan`, `reorderHandle` |
| Shared elements | `hero` and a separate `flightKey` | one `hero` under Flutter's name, with `flies` and `flight` for what Flutter lacks |
| Responsive layout | fixed canvases per breakpoint | the web's model: `flex`, `media` rules, `order`, `basis` |
| Reuse | none | components by reference with props, slots and events |
| Text | padding ignored; an opt-in flag for natural line height | padding applies; the font's own line height; `defaultTextStyle` as in Flutter |
| Extension | unknown types failed | a `Catalog` of widget and action specs; app-registered recipes and action handlers |
| Layers | one library | `core` plus `data`, `auth`, `commerce`, `media`, `engage`, `publish`, `managed`; an architecture test keeps the render layer free of them, and a core-only build proves it |
| Special-case fields | present across behaviors, props and paint | removed or made general in three passes: the schema 3 cleanup (one counted group went from 171 fields to 135), then the paint and transform folds (declared fields 2,122 → 2,099) |
| Stored format | schema 2 with legacy readers | schema 3; schema 2 migrates in memory through named steps; no legacy readers |

## 3. What deliberately has no Flutter counterpart, and why it stays

Charts and gauges, formulas and bindings, variables and conditions, actions and triggers, `media` rules,
components, edit operations for streaming, and `hero`'s in-place flight. Each is general (not tied to one app),
and each is what makes an app expressible as data rather than as code. The owner's rule was that such additions
are fine; special cases are not.

The plot chart keeps its 23 Cartesian props. They are the general parts of a line chart, and the chart computes
extents and ticks from data while it paints, so moving them to a draw list would move the special case into
every document.

## 4. Verdict

The path holds. After the cleanup, a feature is either Flutter's concept under Flutter's name, a general
primitive with a stated reason for existing, or a feature layer that the renderer does not know about. The
"hacks" were symptoms of three missing primitives, and with those in place the special cases could be expressed
generally or removed.

Evidence that it works as an API for building, not only on paper: independent agents given only the reference
built nine multi-page sites that validate clean and render at three sizes in 28 to 42 minutes each, and six of
the nine reported nothing the API could not express.

## 5. What is not finished

- **Control shapes are still Material's.** Colours and fonts no longer are (below), but stadium buttons,
  underline fields, the switch and chip proportions remain until house shapes come from a design-system pack.
- **Gaps the nine builds named that are still open:** pointer position on hover, a clip mask, page-transition
  overlays, focus management (trap, return, skip links), URL history and query state in the browser, Web Share and
  announcements. Each needs a design pass against Flutter's API.
- **The (b) fields of section 6**: the ranked list there says which to rename next.
- **The editor** still writes schema 2 and reads fields that have moved; its port follows the milestones.
- **Fidelity to the web builds** is roughly 30 to 45 percent by reviewers' eyes. The causes found are defaults,
  imagery, fonts, layout guidance and tooling rather than the model, but that claim is only tested by the next
  round.

Closed since this section was first written (codelessly_api "Unreleased"):

- **Name conformance re-measured**: section 6.
- **Material defaults in colour and font** (30.1.0): one theme source for every control and the runtime's own
  dialogs and toasts, from the document's theme or a neutral set; no ripple, tint or elevation; a guard test fails
  if a Material seed colour, ripple or default font appears. `useHostTheme` is removed: nothing is inherited from
  a host app.
- **Theme mode, site fonts, local images**: `theme.mode` and `setThemeMode` (Flutter's `ThemeMode`); fonts
  declared in `site.json`; image paths relative to the site.
- **Grid placement, forms, scroll control**: `columnSpan`/`rowSpan`/`columnStart`/`rowStart` on grid items (CSS
  grid, which Flutter lacks); `validator`, `autovalidateMode`, a `form` behavior and a `validate` action (Flutter's
  `Form`), `radioGroup`; `itemSnapping` and `${result.index}` on scroll reactions.
- **Reported bugs**: a bound button icon, an expression inside text runs, a focused field leaving the tree, and
  a silent `selected` binding are fixed or reported by validation; two reports did not reproduce (a repeating
  timer in a modal, a text button ignoring its foreground colour).
- **Inert state targets.** A state patch names its target by node id, and that is the general form: Flutter's
  `WidgetStateProperty` styles the widget it is given to, and the node's own id is that widget. The corpus has 1131
  patches (in 9 documents; the 330 the transform fold rewrote are among them) that wrote `self` or `@<key>`
  instead; every one names the node its states are on (the generators resolved `@key` where it was a value, never
  where it was a map key). They are migrated, not supported as a second spelling: the first step of `migrate2to3`,
  `states.target`, rewrites `self` to the node's id and `@<key>` to the id of the node with that key, and reports
  each as a behaviour change, so those press, hover and selection styles now apply when the documents load; in a
  schema-3 document validation refuses both (`unknown_target_node`) with the id to write as the suggestion. The
  corpus documents themselves are untouched.
- **A stroke's draw-on animation** (`drawMs`) migrates to the general pieces: an animation on the node whose
  track draws the path op's `trimEnd` from 0 to its own value, played when the node appears, and a transition of
  that `trimEnd` with the same timing (doc 01, "30.1.0"). Each frame equals the old painter's (the SDK's
  `stroke_draw_on_test.dart`); a progress that changes while the line is still drawing on carries on toward the
  new value instead of restarting from where it is. Making it exact took three general fixes in the SDK's player
  (an omitted track end reads the node's own value and its declared default, a transition watches the un-animated
  value, a patched node re-applies on a binding change) and `BindPaths.declaredDefault` in the model.

## 6. Name conformance, re-measured

**Method** (`dart run tool/name_conformance.dart`). Every declared field of each node type that names a Flutter
widget (47 types, each counted on its own) and of the shared groups (layout, decoration, text style, `motion` as
`Transform`, `hero` as `Hero`, `customPaint` as `CustomPaint`, its paint as `dart:ui` `Paint`, its draw ops as
`Canvas` and `Path` calls) is (a) when its name is a constructor parameter, field or getter of the Flutter classes
the group mirrors, read from the Flutter SDK's source, and otherwise carries a written verdict of (b) a Flutter
concept under another name, (c) no counterpart and general, or (d) no counterpart and a special case; a verdict can
also overrule a name match whose meaning differs (`stack.fit`). The audit's "about a third" was not recorded with a
method, so the two numbers are not like for like: a name match is generous (a slider's colors match
`SliderThemeData`'s), and the early figure counted fields that the cleanup has since removed.

**Result: 62% of the 853 fields are Flutter's name and meaning; 77% of those that have a Flutter counterpart
((a) / ((a) + (b))).** 166 fields (19%) have no counterpart and are general; none is a special case any more (the 21
that were are said with general mechanisms since 30.1.0, below). Re-measured after that change, the count also
classifies ten fields added since the first measurement: the grid placement fields (`layout.columnSpan`, `rowSpan`,
`columnStart`, `rowStart`, (c): CSS grid placement, which Flutter's grids lack) and `itemSnapping` on the six
scrolling types ((b): Flutter's name, on its `CarouselView`); a text field's `runs` is (b)
(`TextEditingController.buildTextSpan`).

| Group | Fields | (a) | (b) | (c) | (d) | unclassified | (a) of all | (a) of Flutter concepts, (a)/((a)+(b)) |
|---|---|---|---|---|---|---|---|---|
| **All** | 853 | 530 | 157 | 166 | 0 | 0 | 62% | 77% |
| Node types (47) | 678 | 446 | 127 | 105 | 0 | 0 | 66% | 78% |
| Shared groups | 175 | 84 | 30 | 61 | 0 | 0 | 48% | 74% |
| layout | 17 | 7 | 4 | 6 | 0 | 0 | 41% | 64% |
| decoration | 13 | 3 | 9 | 1 | 0 | 0 | 23% | 25% |
| textStyle | 18 | 16 | 2 | 0 | 0 | 0 | 89% | 89% |
| motion | 14 | 4 | 8 | 2 | 0 | 0 | 29% | 33% |
| hero | 5 | 1 | 2 | 2 | 0 | 0 | 20% | 33% |
| customPaint | 6 | 5 | 0 | 1 | 0 | 0 | 83% | 100% |
| drawPaint | 12 | 9 | 0 | 3 | 0 | 0 | 75% | 100% |
| draw ops (12) | 90 | 39 | 5 | 46 | 0 | 0 | 43% | 89% |

| Node type | Flutter | Fields | (a) | (b) | (c) | (d) | (a) of all |
|---|---|---|---|---|---|---|---|
| `canvas` | `Scaffold` | 7 | 0 | 1 | 6 | 0 | 0% |
| `stack` | `Stack` | 9 | 4 | 5 | 0 | 0 | 44% |
| `box` | `Container` | 0 | 0 | 0 | 0 | 0 | – |
| `row` | `Row` | 14 | 8 | 4 | 2 | 0 | 57% |
| `column` | `Column` | 14 | 8 | 4 | 2 | 0 | 57% |
| `flex` | `Flex` | 15 | 9 | 4 | 2 | 0 | 60% |
| `text` | `Text` | 9 | 6 | 3 | 0 | 0 | 67% |
| `icon` | `Icon` | 3 | 3 | 0 | 0 | 0 | 100% |
| `spacer` | `Spacer` | 0 | 0 | 0 | 0 | 0 | – |
| `listView` | `ListView` | 34 | 11 | 14 | 9 | 0 | 32% |
| `gridView` | `GridView` | 23 | 14 | 3 | 6 | 0 | 61% |
| `pageView` | `PageView` | 17 | 11 | 3 | 3 | 0 | 65% |
| `tabBar` | `TabBar` | 23 | 17 | 4 | 2 | 0 | 74% |
| `expansionTile` | `ExpansionTile` | 19 | 17 | 2 | 0 | 0 | 89% |
| `tableView` | `TableView` | 23 | 3 | 13 | 7 | 0 | 13% |
| `textField` | `TextField` | 37 | 30 | 6 | 1 | 0 | 81% |
| `checkbox` | `Checkbox` | 13 | 10 | 3 | 0 | 0 | 77% |
| `switch` | `Switch` | 25 | 10 | 5 | 10 | 0 | 40% |
| `radio` | `Radio` | 13 | 11 | 2 | 0 | 0 | 85% |
| `slider` | `Slider` | 43 | 23 | 5 | 15 | 0 | 53% |
| `dropdown` | `DropdownButton` | 30 | 21 | 4 | 5 | 0 | 70% |
| `datePicker` | `showDatePicker` | 9 | 5 | 3 | 1 | 0 | 56% |
| `timePicker` | `showTimePicker` | 8 | 4 | 3 | 1 | 0 | 50% |
| `dateTimeInput` | `InputDecorator` | 17 | 9 | 3 | 5 | 0 | 53% |
| `segmentedButton` | `SegmentedButton` | 23 | 13 | 8 | 2 | 0 | 57% |
| `elevatedButton` | `ElevatedButton` | 7 | 6 | 0 | 1 | 0 | 86% |
| `filledButton` | `FilledButton` | 8 | 6 | 1 | 1 | 0 | 75% |
| `textButton` | `TextButton` | 7 | 6 | 0 | 1 | 0 | 86% |
| `outlinedButton` | `OutlinedButton` | 7 | 6 | 0 | 1 | 0 | 86% |
| `iconButton` | `IconButton` | 3 | 2 | 1 | 0 | 0 | 67% |
| `floatingActionButton` | `FloatingActionButton` | 17 | 15 | 2 | 0 | 0 | 88% |
| `chip` | `Chip` | 15 | 11 | 1 | 3 | 0 | 73% |
| `actionChip` | `ActionChip` | 17 | 13 | 1 | 3 | 0 | 76% |
| `choiceChip` | `ChoiceChip` | 21 | 17 | 1 | 3 | 0 | 81% |
| `filterChip` | `FilterChip` | 21 | 17 | 1 | 3 | 0 | 81% |
| `inputChip` | `InputChip` | 24 | 19 | 2 | 3 | 0 | 79% |
| `badge` | `Badge` | 12 | 12 | 0 | 0 | 0 | 100% |
| `listTile` | `ListTile` | 21 | 21 | 0 | 0 | 0 | 100% |
| `appBar` | `AppBar` | 14 | 14 | 0 | 0 | 0 | 100% |
| `navigationBar` | `NavigationBar` | 14 | 8 | 6 | 0 | 0 | 57% |
| `bottomNavigationBar` | `BottomNavigationBar` | 15 | 6 | 9 | 0 | 0 | 40% |
| `divider` | `Divider` | 4 | 4 | 0 | 0 | 0 | 100% |
| `verticalDivider` | `VerticalDivider` | 4 | 4 | 0 | 0 | 0 | 100% |
| `modal` | `showDialog` | 0 | 0 | 0 | 0 | 0 | – |
| `circularProgressIndicator` | `CircularProgressIndicator` | 9 | 7 | 0 | 2 | 0 | 78% |
| `activityIndicator` | `CupertinoActivityIndicator` | 3 | 3 | 0 | 0 | 0 | 100% |
| `path` | `CustomPaint` | 7 | 2 | 0 | 5 | 0 | 29% |

Flutter classes named but not in the Flutter SDK read: `TableView`, `showDatePicker`, `showTimePicker`, `showDialog`.

Every field outside (a) with its verdict: [name-conformance.md](name-conformance.md) (generated by the script with
`--detail`).

**Renamed now.** A time picker's `use24h` is `alwaysUse24HourFormat` (Flutter's
`MediaQueryData.alwaysUse24HourFormat`, which the picker reads): no document in the corpus or either repository
used it, so the cost was a one-way migration step (`props.renamed`: the prop, its binding, patches and
`setValue`/condition paths) and a validation message for the old spelling, with no fixture to rewrite.

**The (b) fields, ranked** (by how often an author or a model writes the field, then by how mechanical a rename
would be; uses counted in the corpus and the two repositories' documents):

1. `decoration.radius` → `borderRadius` (2,630 uses in 28 corpus documents, 293 in 37 repository files). The
   field a model guesses first; left because every document, generator and the editor write it: a rename is a
   2→3 step plus a rewrite of 37 in-repository files, worth doing in one pass with item 2.
2. `decoration.clip` → `clipBehavior` (28 uses in 13 corpus documents, 26 in 13 repository files). Cheapest of
   the frequent ones; left only to do it in the same pass as `radius`.
3. `stack.fit` is Flutter's name for another thing (`Stack.fit` is a `StackFit`; ours is a `BoxFit` for the
   board, Flutter's `FittedBox(fit:)` around the stack), with `fitAlignment` (`FittedBox.alignment`). No document
   uses either. Recommended: `fit` as `StackFit`, the board's scaling under a name of its own; left because the
   new name is a design choice.
4. `bottomNavigationBar.selectedIndex`, `destinations`, `labelBehavior`, `labelTextStyle`, `iconColor`,
   `selectedIconColor`, `selectedIconSize` → `currentIndex`, `items`, `showSelectedLabels`/`showUnselectedLabels`,
   `selectedLabelStyle`/`unselectedLabelStyle`, `unselectedItemColor`, `selectedItemColor`, `selectedIconTheme`.
   No document uses them; left because the two bars share one props class (NavigationBar's names) and splitting
   it is renderer work.
5. `textField.keyboardDecimal`/`keyboardSigned` → `keyboardType: numberWithOptions(decimal:, signed:)`;
   `inputFormatter` → `inputFormatters`. No uses; left because each changes the value's shape, not only its name.
6. `layout.x`/`y`/`align`/`squeezable` → `Positioned`/`Align`/`Flexible(fit: loose)`. One field stands for a
   choice among widgets (start, end or alignment); kept as the model's placement, documented with the Flutter
   each one is.
7. `motion.translateX/Y`, `shiftX/Y`, `rotate`, `rotateX/Y`, `perspective` → `Transform.translate(offset:)`,
   `FractionalTranslation`, `Transform.rotate(angle:)` (radians), `Matrix4` entries. Deliberate (doc 03): scalar
   fields are what animation tracks and transitions address, and degrees are what authors write.
8. `decoration.fills`, `strokes`, `strokeWidth`, `strokeSides`, `effects`, `blendMode`, `foregroundFills`,
   `textStyle.from`, `tabularFigures`: the paint-stack model (several fills and strokes, shadows and blurs in one
   list) has no single Flutter field; kept, each documented with its Flutter spelling.
9. The `WidgetStateProperty` and component-shape unpackings (`selected*`, `active*`/`inactive*` colors, a
   slider's `thumbRadius`, `overlayRadius`, `tickMarkRadius`, `showThumb`, a segmented button's `ButtonStyle`
   parts, `checkbox`/`segmentedButton.borderRadius`, `compact`): flat, bindable fields for what Flutter nests in
   objects; kept.
10. The rest (named constructors such as `filledButton.tonal`, `enabled` for a null callback, list separators as
    `Divider` fields, a page view's `animateToPage` timing, `tableView`'s span builders, hero builders as named
    looks, `canvas.blockBack` as `PopScope`): Flutter's concept has no field of that name to take; kept.

**The (d) fields: none left.** The 21 that were special cases are each said with a mechanism the model already had,
by one-way migration steps after 30.1.0 (`steps_special.dart`: `text.countUp`, `slider.paint`, `textField.runs`,
`tableView.rowEdge`, `dateTimeInput.format`); a schema-3 document that still writes one is refused by validation,
naming the form to write (CHANGELOG, "Unreleased", has the table). No document in the corpus or either repository
used one (plotter_v2's editor trees set the ruler fields and a highlight style, hookline's a count-up, but those are
the editor's build inputs, not documents the migration reads); the SDK's test/migration/special_fields_test.dart
draws each migrated case against goldens taken with 30.1.0's renderer.

- `text.countUp` and its timing: a transition of `props.text` (a number in a text prop now counts in any track or
  transition, written as the text writes it) and, for the count from 0 when it shows, an animation of it. The same
  text in every frame.
- `slider` ruler, marker, `activeTrackStartOpacity`, `thumbGripColor`: the slider's `customPaint`, which a slider
  draws between its parts (the `painter` over the track and under the thumb, the `foregroundPainter` over the
  thumb, reading `slider.value`, `min`, `max`, `trackRect` and `thumbCenter`): the general hook a control needed.
  Identical, but the fade, drawn as the inactive colour laid over the active track, is within one level except at
  the anti-aliased pixels of the track's rounded end; a marker or fade that made the slider draw a plain track
  now leaves the track to its `trackShape` (reported).
- `slider.deriveOverlayColorFromThumb`: no renderer read it, so binding `overlayColor` to the thumb's colour (the
  proposal) would have changed what is drawn; it is dropped.
- `textField.highlightStart`/`End`/`Style`: the field's `runs`, as a text's (Flutter's
  `TextEditingController.buildTextSpan`).
- `tableView.selectedRowEdgeColor`/`Width`: the cell template's `selected` state style (a left stroke) with
  `selected` bound to the cell being first in the selected row: a row is not a node, so the style goes on the cell;
  the same pixels when the template fills its cell and the table has no horizontal padding (else reported).
- `dateTimeInput.displayFormat`: `format`.
