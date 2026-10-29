## Unreleased

### PR48 additions

- `gauge` node (`GaugeNode`, `GaugeProperties`, `GaugeZone`): a dial with a
  bindable `value`, zone bands, LED segments, ticks and labels, a target
  notch, a needle and value animation.
- `chart` node (`ChartNode`, `ChartProperties`, `ChartSeries`,
  `ChartReferenceLine`): bar, line and timeline charts bound to a list
  through `variables.data`; bar, line, area and tick series with stacks,
  per-item colors, dashes, end dots and fill-between; reference lines;
  bindable `selectedIndex` and a `changed` trigger; a timeline's `nowColor`
  colors its now marker.
- `PaintModel.gradientTileMode` (clamp, repeated, mirror) for repeating
  gradients such as stripes.
- `BlendMixin.pulse` (`PulseModel`): a looping fade of a node's opacity.
- Rows can wrap: `RowColumnNode.wrap`, `spacing` and `runSpacing` lay a
  row's children out in lines like Flutter's `Wrap`.
- `ShowDialogAction.anchor` (`DialogAnchor.trigger`), `placement`,
  `anchorGap` and `anchorOffset`: a dialog can open as a popover next to
  the node that ran it. `copyWith` keeps `nonBlocking` and `enabled`.
- `ShowToastAction.accentColor` (a 4 px leading edge), `cornerRadius` and
  `maxWidth`.
- Slider thumbs can be rectangles: `SliderProperties.thumbShape`,
  `thumbWidth`, `thumbHeight`, `thumbCornerRadius`, `thumbBorderColor`,
  `thumbBorderWidth` and `thumbGripColor`.
- `MaterialIcon.fromJson` reads a Flutter-style name with a style suffix
  (`home_outlined`) as the base name in that style, so it draws.
- `VariableData.isComputed` and `isFormulaValue`: a variable whose value is
  a `${= ...}` formula is computed; `getValue()` returns null for it.
- Gauge and chart nodes read JSON without `properties`; grid delegates,
  scroll settings and placeholder type lists default when left out; a
  spacer reads JSON without its positioning mode, aspect lock and
  reactions.

### Motion

- `MotionModel` on every node (`BaseNode.motion`): offset, scale, opacity,
  rotation, 3D tilt with perspective and origin, an animated transition
  (duration and curve), continuous spin, `loop` (restart or back and forth),
  `enter`, `enterFrom`, `delayMs` and a bindable `replayKey`. Values bind as
  `motion.<name>` variables.

### Triggers

- `timer` (`TriggerModel.intervalMs`) and `keyPress` (`TriggerModel.key`) on
  canvases; `swipeLeft/Right/Up/Down` and `doubleTap` on frames, rectangles,
  buttons, icons and text, beside `cursorEnter` and `cursorExit`. Trigger
  JSON naming `hoverEnter` or `hoverExit` reads as `cursorEnter` and
  `cursorExit` (`TriggerType.aliases`).

### Lists and sliders

- `ListViewProperties.stacked` (items drawn on top of each other) and `wrap`
  with `wrapSpacing`, `wrapRunSpacing` and `wrapAlignment`.
- Sliders: `orientation` (vertical), `inverted`, thumb stroke, and a
  `roundedRect` thumb shape with width, height and corners.
- Row/column JSON with `itemSpacing` is read as `spacing`.

### Variables and JSON

- JSON with a separate `formula` for a computed variable is read into its
  value.
- Bindable `effectsVisible`, `strokeWeight`, `cornerRadius`, `fontWeight`
  and a slider's `min`/`max` as property variables.
- `variableSyntaxIdentifierPattern` matches a `${= ...}` formula whole,
  object literals included.
- `EdgeInsetsModel.fromJson` reads `{left, top, right, bottom}` and
  `{horizontal, vertical}`; placeholders and lists read JSON without their
  editor-only keys.

### New

- `SignatureNode` (`signature`), a draw-to-sign pad. Its value is the list
  of strokes drawn (each a list of `[x, y]` points), bindable through
  `variables.value` and settable with a set value action; `changed` fires
  when a stroke ends. Properties: ink color and width, background, border
  and error border, corner radius, placeholder, sign line, and bindable
  `error` and `enabled`.
- `BaseNode.loopAnimation` (`LoopAnimation`: pulse, fade, scale or spin,
  with duration, delay, reverse, curve and from/to scale, opacity or
  turns), on every node type and left out of the JSON when null.
  `loopAnimationEnabled` can be bound to turn it on and off.
- Nodes with a click trigger also offer `cursorEnter` and `cursorExit`;
  the trigger docs say what `hover`, `cursorEnter` and `cursorExit` mean.
- `DialogPresentation.sideSheet`, and `ShowDialogAction.sheetWidth`,
  `maxHeightFactor` (1: no cap) and `showDragHandle` (false) for sheets,
  so saved bottom sheets look as before.
  `copyWith` keeps `nonBlocking` and `enabled`.
- `ConfirmAction.presentation`, `sheetWidth`, `maxHeightFactor` and
  `showDragHandle`, as on `ShowDialogAction`.
- `ShowToastAction.accentColor`, `accentWidth` (4), `iconColor`,
  `fontFamily` and `cornerRadius`.
- `FrameNode.contentFit` (a `Fit`, null for none) and `contentAlignment`
  (center).
- `TextFieldNode.propertyVariables` lists `errorText` and `error`.
- All new fields are left out of the JSON at their defaults.
- `GridDelegateProperties.shrinkWrapRows`: each row of a grid is as tall
  as its tallest item (like a `Row` in an `IntrinsicHeight`) instead of a
  fixed `mainAxisExtent` or `childAspectRatio`. Default false, left out of
  the JSON.
- `CornerRadius.fromJson` accepts a bare number (a circular radius on every
  corner), like `EdgeInsetsModel` does.
- `ApiCallAction.onSuccess` and `onError`: actions to run after the call
  answers with a 2xx status, or after it fails or answers with another.
- `ActionModel.childActions` and `selfAndNestedActions` walk actions nested
  in conditionals, for-each loops and API call handlers.
- `NavigationAction.destinationId` defaults to `''`: a pop needs none, and
  for a pop it names where to go when there is nothing to go back to. It is
  still always written, for SDKs that require it.
- `PaintModel.saturation` (default 1, left out of the JSON when 1): an image
  fill's color saturation; 0 is greyscale.
- `CanvasProperties.path`: an optional URL path for a screen, such as
  `journal` or `guide/:id`, for links that open it with its parameters.
- Styling for the runtime's own UI, all optional and left out of the JSON
  when unset, so saved designs keep their look:
  - `ShowToastAction`: `actionColor`, `showClose`, `closeColor`,
    `border` (`BorderSideModel`), `shadows` (drop shadow
    `Effect`s), `padding`, `maxWidth`, `messageStyle`, `actionStyle`,
    `iconSize`, and `bottomOffsets` (per `ScreenBreakpoint`, e.g.
    `{"mobile": 84}`, see `bottomOffsetFor`).
  - `ConfirmAction`: `border`, `shadows`, `titleStyle`, `messageStyle`,
    `buttonStyle`, `buttonRadius`, `buttonBorder`, `buttonShadows`,
    `confirmTextColor`, `cancelColor`, `cancelTextColor`.
  - `DropdownProperties`: `menuStyle` (`DropdownMenuStyleModel`: an anchored
    menu card's color, border, radius, shadows, offset, sizes, paddings,
    selected and hover row colors, selected text style and check mark) and
    `itemImage` (a URL or item template such as `${item.image}`),
    `itemImageSize`, `itemImageRadius`.
  - `TextStyleModel`: a partial text style (font family, weight, italic,
    size, line height, letter spacing, color).
- `LineChartNode` (`lineChart`) and `LineChartProperties`: a data-driven
  line chart. The series, domain, bands, grid lines, area bands, reference
  lines, x ticks, markers and vertical lines are bound through `variables`
  (see the class docs for their JSON shapes); colors, insets, curve style,
  text styles and the scrub readout are properties.
- `BaseNode.squeezable` (`"squeezable": true`, default `false` and left out
  of the JSON): a node that wraps its content (`SizeFit.shrinkWrap`) on its
  Row/Column's main axis may shrink below it when the Row/Column runs out of
  space, like `Flexible(fit: FlexFit.loose)` around a shrink-wrapped child.

### Fixes

- `SpacerNode.fromJson` defaults `positioningMode` (align),
  `aspectRatioLock` (false) and `reactions` ([]) like every other node, and
  `GridViewNode.fromJson` defaults `isScrollable` (true) and
  `useFlutterListView` (false). Both still write those keys for older
  readers.

## 6.2.0

### Layout

- Row/column `spacing`: a gap between children along the main axis, taken
  out before expanded children share the free space.
- Row/column `wrap` and `runSpacing`: children wrap onto further runs, like
  Flutter's `Wrap`.

### Paint and widgets

- `PaintModel.gradientRepeatEvery`: a linear gradient repeats every N px
  instead of stretching across the box (hazard stripes, tick patterns).
- Progress bars take `shape: arc`: a gauge with start and sweep angles,
  stroke width, tick count and color, a needle and colored zone `bands`
  (`ProgressBand`).

### Actions

- `ShowDialogAction.presentation` (dialog, bottom sheet, or adaptive: a
  sheet below 600 px) and `alignment` for where a dialog opens.
- `DelayAction.duration`: a variable or formula for the wait, used instead
  of `milliseconds` when it gives a number.

### Data

- A variable whose value is a `${= ...}` formula keeps it for every type
  (computed variables).

### Nodes

- `SignatureNode` (`signature`): a box to sign in. Its `value` is a list of
  strokes, each a list of `[x, y]` points normalized to the box; `inkColor`,
  `strokeWidth` and `readOnly` are in `SignatureProperties`.
- `SpacerNode` parses JSON without `positioningMode`, `aspectRatioLock` or
  `reactions`, like other nodes. Its constructor didn't take them, so the
  generated `fromJson` required them.

### Triggers and actions

- `TriggerType.hold` fires once the target has been held for the trigger's
  `duration` (milliseconds, 1200 by default). Frames, rectangles, rows and
  columns offer it.
- Rows and columns declare the click and long-press triggers they already
  ran, so the actions panel offers them.
- `DialogPresentation.fullScreen`: a show dialog action can cover the
  whole screen, like a photo viewer.
- A navigate-back (`pop`) action reads from JSON without `destinationId`,
  which it has no use for. It is still written, as `''`, for readers that
  require it.

### Bindings

- `strokeWeight` is a bindable style property of every node with strokes.
- `flex` is one of the properties every node can bind, set by a condition
  or change with an action.
- `IconNode` declares `iconColor` and `iconName` as properties that can be
  bound, set by conditions or changed by actions; `iconName` names the
  Material Symbol to show.

### JSON

- List, grid, page and tab views and spacers parse from minimal node JSON:
  fields with constructor defaults (`isScrollable`, `useFlutterListView`,
  `allowedTypes`, `deniedTypes`, ...) may be left out.

## 6.1.0

### States and conditions

- `InteractionState` (hover, focus, pressed, selected, disabled) and
  `BaseNode.interactionStates`: sparse property overrides per state.
- `Variant.overrides` for property-override states; `PropertyOverridePatch`
  applies, diffs and merges them.
- Query-status variants (loading, empty, error) with an optional skeleton.

### Data

- `CollectionSchema` and `SchemaField` for typed collections.
- `CloudDataAction` (create, update, delete, get, query, count, sum,
  average) and `CloudBatchAction` built from schemas, without JSON.
- `QueryableMixin.paging` (scroll or a Show more button) and
  `QueryableMixin.loadRelated` for reference fields.
- `CloudFilesAction.access`: uploads are private to the uploader by default.

### Auth, actions and variables

- `AuthOperation` adds Google, Apple and email-link sign-in and
  `updatePhoto`.
- `TriggerModel.debounceMs` and the `valueChanged` trigger.
- `BaseNode.tooltip` and `BaseNode.zoomable`.
- `VariableType.choice` with named options.
- `ThemeTokens` for what the runtime draws itself.
- A value read as a paint turns an image link into an image paint.

## 6.0.0

### Breaking changes

- `ButtonProperties.buttonColor` is nullable and defaults to `null`,
  the button type's default colour. It was black, and black was left out of
  the JSON, so a missing key now reads as `null` and an explicit black is
  written and read back as black.
- `ShowToastAction.backgroundColor` and `textColor` are nullable and default
  to `null` (the app's theme). Saved toasts, which omitted the old defaults,
  now take the theme's colours. `copyWith` gains `clearBackgroundColor` and
  `clearTextColor`.

### New

- Responsive variances: `ScreenBreakpoint` (mobile, tablet, desktop; widths
  600 and 1024, design widths 390/834/1440), an optional `Variant.breakpoint`
  (omitted from JSON when unset), and `VarianceNode.isResponsive`,
  `variantForBreakpoint` and `variantForWidth`.
- `ShowToastAction`: a button (`actionLabel` and `actions`, e.g. Undo), a
  `ToastStyle` and a `ToastPosition` (top or bottom).
- `ConfirmAction` can show a canvas as its dialog (`dialogId`, `params`),
  which answers through a Navigate back action whose params hold
  `confirmed`, and has optional colour, radius and barrier overrides for the
  built-in dialog.
- `TextFieldProperties.maxLines`: `null` (unlimited lines) is written as an
  explicit `null` and reads back as `null`; a missing key still reads as 1.
- `VariableData.getValue()` returns an empty text variable as `''` instead of
  `null`, and a `null` value is stored as `''` instead of `'null'`.
- `AuthOperation.sendEmailVerification`, `updatePassword` and
  `deleteAccount`.
- `DelayAction` (`ActionType.delay`): waits `milliseconds` before the next
  action runs.
- `CanvasProperties.signInRedirectId`: a screen that needs a signed-in user
  sends signed-out users to that canvas (`requiresSignIn`).
- `ListViewNode.statusVariable` and `GridViewNode.statusVariable`: a text
  variable a cloud list writes its query status into (`kQueryStatusLoading`,
  `kQueryStatusEmpty`, `kQueryStatusError`, `kQueryStatusLoaded`), for
  loading, empty and error states.
- `ConfirmAction` (`ActionType.confirm`): asks the user to confirm with a
  title, message and button labels (optionally destructive), then runs
  `actions` on confirm or `cancelActions` on cancel.

### Fixes

- Web view nodes always write their `webviewType`, `mapMode` and
  `embedType` discriminators, so they read back from JSON.
- Empty action lists, maps and sets are left out of JSON (conditional,
  for-each and cloud files actions, API call parameters, call function
  params, else conditions, condition groups, variable extras, text field
  autofill hints and variance properties); 5.2.0 and 5.3.0 read the shorter
  JSON back to equal objects.
- `NodeProcessor.updateNode` rewrites edge pins from the node's box only for
  freeform children with no alignment (`NodeProcessor.edgePinsPosition`);
  children of rows and columns and aligned children keep their pins.

## 5.3.0

- `ShowToastAction` (`ActionType.showToast`): shows a short message at the
  bottom of the screen, with an optional icon, colors, duration and offset.
- Every node with fills, strokes or opacity now lists `fill`, `stroke` and
  `opacity` in its property variables, and every node lists `width` and
  `height`, so conditions, bound variables and set value actions can change
  them at runtime.

## 5.2.0

### New actions

- `AuthAction` (`ActionType.auth`): sign up, sign in, sign out, update the
  profile and send a password reset email (`AuthOperation`), with an
  optional error variable.
- `ConditionalAction` (`ActionType.conditional`): an expression with
  then/else action lists, so action chains can branch.
- `ForEachAction` (`ActionType.forEach`): runs actions for each item of a
  list variable.
- `CloudFilesAction` (`ActionType.cloudFiles`): picks and uploads images to
  the project's storage, or deletes a file, running nested actions per file.

### Changes

- `RowColumnNode` has a corner radius.
- 8-digit `#AARRGGBB` colors set the paint's opacity when none is given.
- Dates in list and map variables encode as ISO 8601 strings
  (`encodeJsonValue`), and `VariableType.fromObjectType` maps `DateTime` to
  text.

## 5.1.0

### New nodes

- `BadgeNode` (`'badge'`): Material 3 `Badge` as a dot, label or count
  (`BadgeType`), optionally anchored to another node through `childID`.
  `BadgeProperties` mirrors Flutter's `backgroundColor`, `textColor`,
  `textStyle`, `smallSize`, `largeSize`, `padding`, `isLabelVisible` and
  `Badge.count`'s `maxCount`, plus `BadgeAlignment` and an `offsetX`/
  `offsetY` offset (Flutter's default `Offset(4, -4)`).
- `ChipNode` (`'chip'`): Material 3 `Chip`, `ActionChip`, `ChoiceChip`,
  `FilterChip` and `InputChip` (`ChipType`). `ChipProperties` covers the
  label and its style, an icon or image avatar, the delete icon and its
  color, selection with `showCheckmark`/`checkmarkColor`, colors, border,
  corner radius, elevation, paddings (Material 3 defaults: 8 px padding,
  8 px horizontal label padding), `tooltip` and `autofocus`. Choice and
  filter chips expose a `selected` property variable.
- `SegmentedButtonNode` (`'segmentedButton'`): Material 3
  `SegmentedButton<String>` built from `ButtonSegmentModel`s, with
  `selected`, `multiSelectionEnabled`, `emptySelectionAllowed`,
  `showSelectedIcon`, `selectedIcon`, `direction`, border, foreground and
  background colors for both states and a stadium-shaped default corner
  radius. The selection is exposed as the `selected` property variable.
- All three are registered with `NodeJsonConverter`.

### JSON

- These nodes first appeared on the unreleased `migrate-json-serializable`
  branch. JSON written with it still loads: keys are unchanged where a
  field was renamed to its Flutter name (`dotSize` holds
  `BadgeProperties.smallSize`, `labelStyle` holds
  `BadgeProperties.textStyle`, `selectedSegments` holds
  `SegmentedButtonProperties.selected`, `selectedColor`/`unselectedColor`
  hold `selectedBackgroundColor`/`backgroundColor`), and field access uses
  the same keys.
- As with every other node, fields that equal their defaults are omitted.

## 5.0.0

### Breaking changes

- Require Dart 3.13.
- Replace the forked `codelessly_json_annotation` and
  `codelessly_json_serializable` with the standard `json_annotation` and
  `json_serializable`. Custom nodes should import
  `package:json_annotation/json_annotation.dart`. `DateTimeConverter` is
  now exported by this package.
- Upgrade to equatable 3, which removes `EquatableMixin`; models mix in
  `Equatable` instead.
- Remove the unused blend and `value` constructor parameters of
  `LoadingIndicatorNode`, `ProgressBarNode` and `DividerNode`, which were
  silently discarded.
- Remove the unused `automaticChevron` parameter of
  `ExpansionTileProperties.copyWith`.

### JSON

- Serialized JSON is unchanged: fields that equal their defaults are still
  omitted, now by a small build step in `tool/json_defaults_builder`.
  Golden tests pin the output against 4.4.0.
- Cloud database query `whereFilters`/`orderByFilters` are omitted when
  empty; they read back as empty lists.

### Flutter parity

- Mirror new Flutter values: `TextAlignHorizontalEnum.start`/`end`,
  `ButtonTypeEnum.filled`/`filledTonal`, `FABLocation.endContained`,
  `TextInputTypeEnum.webSearch`/`twitter`,
  `AutovalidateModeC.onUnfocus`/`onUserInteractionIfError`,
  `SliderTrackShapeEnum.gapped`, `SliderValueIndicatorShape.drop`/
  `roundedRectangle` and `CShapeBorder.roundedSuperellipse`.
- Add Flutter parameters that were missing:
  - `AppBarProperties.foregroundColor`, `scrolledUnderElevation`
  - `TabBarProperties.tabAlignment` (new `TabAlignmentC`), `dividerHeight`
  - `RadioProperties.side`, `innerRadius`, `backgroundColor`
  - `SliderProperties.showValueIndicator` (new `ShowValueIndicatorC`),
    `secondaryTrackValue`, `secondaryActiveTrackColor`, `padding`
  - `ListTileProperties.minTileHeight`, `titleAlignment` (new
    `ListTileTitleAlignmentC`)
  - `MaterialLoadingIndicatorProperties.strokeAlign`, `trackGap`
  - `ExpansionTileProperties.showTrailingIcon`, `shape`, `collapsedShape`,
    `cornerRadius`
  - `TextMixin.softWrap`, `textScaleFactor`
  - `MultiSourceIconModel.fill`, `weight`, `grade`, `opticalSize` (the
    Material Symbols variable-font axes)
  - `PageViewProperties.allowImplicitScrolling`
- Document the Flutter replacements for deprecated `cacheExtent`
  (`scrollCacheExtent`) and `Radio.groupValue` (`RadioGroup`).
- New nodes use Material 3 defaults: switches use Material 3, buttons are
  stadium-shaped with 24 px horizontal padding, FABs are rounded rectangles
  (radius 16) with Material 3 elevations, a 56 px extended height and 8 px
  icon spacing, list and expansion tiles use 16/24 px content padding, tab
  indicators size to the label, and navigation bars use elevation 3 (M3)
  and 8 (M2).
- Designs saved before 5.0.0 keep their look: a missing key still reads as
  the old default, and re-saving them writes the same JSON. The new
  `JsonLegacyDefault` annotation supports this for non-literal defaults.

### Fixes

- Register `PlaceholderNode` with `NodeJsonConverter`; layouts containing
  one failed to deserialize.
- `ListTileNode.empty`/`fromProperties` and `ExpansionTileNode.empty`
  no longer leave late fields uninitialized.
- `FloatingActionButtonNode.empty` and `EmbeddedVideoNode.empty` use their
  own sizes.
- `copyWith` keeps Divider `thickness`, Dropdown `enabled`/`dense`/
  `expanded`/`autoFocus`/`enableFeedback`, FAB `location`, M2 navigation
  bar notch settings.
- Remove the `contentPadding` parameter of `InputDecorationModel.copyWith`,
  which was ignored; a text field's content padding is its node padding.
- Equality includes previously ignored fields of ExpansionTile, grid
  delegates, Dropdown, Divider, FAB, ListTile, TabBar, icons, web views,
  submit actions, Vimeo videos, condition groups and visual density.
- `TypedValue.toEdgeInsetsModel` converts numbers and lists again.
- Add field access for `TextFieldProperties` and the navigation bar
  properties.

## 4.4.0

- Add CornerRadius typedValue.
- Fix icon props deserialization for backwards compatibility.

## 4.3.0

- Create new Placeholders node.
- Add enable and disable node feature.
- Add new BlendModes support.
- Enable RenderedLayoutModel for buttons and dropdowns.
- Fix dropdown onChanged callback value.

## 4.2.1

- Fix lint issues.

## 4.2.0

- Add `NodeBox.fromCenter` method.
- Use TextProp instead of StartEndProp.

## 4.1.0

- Fix AppBar constraints.
- Add `Brightness` property for Codelessly emulator support.

## 4.0.0

- Update codelessly_json_serializable to v4.9.0.
- Require Dart SDK v3.5 or higher.

## 3.0.0

- Owner field & admin Role migration.
- Create `where` query API.
- Add new `VariableType.image`.
- Add Date decoder.

## 2.1.0

- New TextInputField features! This is the first batch of improvements to the TextInput component and includes the following:
    - Added Autofill Hints support.
    - Added Text Input Validator.
    - Added Text Input Formatter.
    - Added Submit Keyboard Action selector.

## 2.0.2

- Update external components with reactions.
- Add click and long click reactions to rectangle node.

## 2.0.0

- Update Checkbox shrinkwrap and padding sizing.
- Change default Stroke cap to none.
- Optimize node sorting algorithm.

## 1.8.0

- Custom Layout IDs support! Now you can give your CloudUIs a name which makes identifying them much easier.

## 1.7.0

- Teams v1 support.

## 1.6.0

- Initial CloudUI support for Layout Groups.
    - Display different layouts for different screen sizes.

## 1.5.0

- Fix text node not allowing actions.

## 1.4.0

- New StyleSheets support! Define common color and text styles.
- Update GridView `childAlignment` property. Minor refactor.
- Improve Edge Pins.
    - Fix edge pins not being saved.
    - Clamp edge pins to positive values in wrapping parent layouts.

## 1.3.0

- Remove Montserrat font.

## 1.2.0

- Implement isTrue and isFalse operators for conditions.
- Refactor operator filtering to use index if available.

## 1.1.0

- New AutoComplete support for Variables.
- Fix disable automatic padding from Frames with strokes.

## 1.0.0

- Official v1 release!
- Update triggers types.
- Fix integer functions crashing with NaN and infinite values.

## 0.8.0

- Codelessly Data support. Save and write data to Codelessly Cloud.
- New GridView widget.
- Codelessly Data Query Filters support. Sort and filter data.
- Variable improvements.
    - Include 'set' and 'replace' operations for list operations.
    - Add new ${value} predefined variable to expose internal node data. TextFields only for now.
    - Track internal value with new NodeProvider InheritedWidget per-widget.
- TextField improvements.
    - Add support for actions on prefix and suffix icons on text fields.
    - Fix set operation on map not showing input field.
    - Implement proper TextFieldModel minimum size computation.
    - Add support for TextInputType.numberWithOptions.
- JSON improvements.
    - Fix json variable controller highlighting.
    - Fix json syntax highlighting for storage operations.
    - Fix focus nodes for json variable input fields.
- List improvements.
    - Add insertAll option for list operations
    - Refactor insert list operation to use json input field.
- Add copy-paste and shortcuts support for actions.
- Add support for non-blocking actions.
- Implement option to enable/disable action.
- Add firebase queries support for grid view.
- Add support for number operations.

## 0.7.5

- Fix drag and drop insert to the edge of Accordion, Expansion Tile, ListView, and PageView.

## 0.7.3

- Migrate Variables and Conditions to use permissions model.
- TextField Improvements
    - Fix shrink-wrapping conflict with expands property.
    - Fix text field model not calculating text field height properly for shrink-wrapping.
    - Allow min lines and max lines input fields to clear.
    - Fix shrink-wrap height calculation being affected by isDense property.

## 0.7.1

- Implement safe area for canvases.
- Fix scroll physics and always scrollable option.

## 0.7.0

- New Dialogs feature! 100% customizable dialogs with customizable close button, background, and padding.
    - New show dialog action.
    - New show dialog settings panel.
- Fix Edge Pins not syncing with server.
- Fix PageView triggers not executing.

## 0.6.0

- Embedded Canvases V1.
    - Embed canvases into layouts.
- Local Storage V1.
    - Store and persist data locally.
- Optimize JSON data to reduce data usage and storage by 80%.

## 0.5.2

- Remove dependency on Flutter.

## 0.5.1

- New shrink-wrap support for Buttons. Buttons can now resize based on the content inside them.
- New shrink-wrapping support for Slider, Switch, and Radio Button components.
- Fix ListView and PageView reverse scroll direction not enabled.
- Add `resolvedConstraint` override.

## 0.5.0

- Load APIs V1.
- Fix ExpansionTiles layout and functionality issues.
- Fix reactions not being modified.

## 0.4.1

- Add hover and splash color to dropdown node.
- Miscellaneous fixes.

## 0.4.0

- New `SetMapVariableAction` support for map variables.
- Support more conditions.
    - `isEmpty`, `isNotEmpty`, `contains`
    - `isOdd`, `isEven`, `isNull`
- Add `remove` for list type variable.
- Remove deprecations and update formatting and documentation.

## 0.3.0

- Scrolling V1. Enable scrolling for Columns, Frames, and Canvases.
- Create list operations and index for List `SetVariableAction`.

## 0.2.0

- New simplified variables system. Variables passed into the CodelesslyWidget can now be referenced by name in the
  Codelessly Editor.

```
CodelesslyWidget(
  data: {
    'title': 'My Title',
    'productData': { // JSON Data
      'nested': {
        'json': {
          'path': 'Hey there!',
        }
      }
    }
  }
)

// Now you can access the variable directly in the Codelessly Editor.
${title} - 'My Title'

// Or, using the `data` object.
${data.title} - 'My Title'
${data.productData.nested.json.path} - 'Hey there!'
```

- Add `>=`, `<=`, and `== null` operators.
- Add data and variable support for dropdown component.
- Add Material 3 Switch UI component.
- Add Rounded Circular Progress Indicator component.
- Improve InkWell behavior. Show Inkwell effect on top of other widgets.
- Prototype implementation of custom widget embedding feature.

## 0.1.0

- Optimize SDK size by 90% by switching to SVG icons.
- Enable variables copy and paste.
- Enable conditions copy and paste.
- Fix canvas fill condition not working when there's only 1 fill.

## 0.0.8

- Text field and code-gen improvements.
- Add `showCounter` for input decoration.
- Fix text field counter text not working properly.
- Fix text field with incorrect sizing in codegen.

## 0.0.7

- Add support for Tabs.
- Add TextField support for variables.
- Add FAB support for variables.

## 0.0.6

- Update type support to support null values.

## 0.0.5

- Add improved Variables type support.

## 0.0.4

- Add Variables and Conditions support.

## 0.0.3

- Update SDK constraints.
- Update ReadMe.

## 0.0.2

- Upgrade to Flutter 3.10 and Dart 3.
- Add support for Listview and Pageview.
- Add support for API call action.
- Remove `ScrollLinkableMixin`.
- Add method to compare two font weights.
- Add method to generate a random ID.
- Update example.md.
- Update documentation.

## 0.0.1

- Initial Release.
