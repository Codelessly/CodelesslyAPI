# No widgets: the renderer as render objects (Milestone 3)

Written 2026-11-14, at the start of Milestone 3. Paths are relative to `CodelesslySDK/` unless they start with
`lib/src/core` (this package). Status markers: **built** (in the SDK at the end of the first M3 task, with the test
that proves it), **planned** (owned by a workstream in section 6).

## 1. The rulings this follows

- "For Milestone 3, we need to completely remove all Flutter widgets. We'll provide the API for the render objects
  directly."
- "A root Material or Cupertino is actually a mistake." No `MaterialApp`, `CupertinoApp`, `WidgetsApp`, `Material`,
  `Scaffold`, `Theme`, `Navigator`, `Overlay`, nor any widget per node or per control. The renderer's product is a
  **render object tree** and the services around it. A host Flutter app places it with one thin optional adapter (a
  `RenderObjectWidget`) at the edge; a whole-app mode attaches the root render object to the view with no widget.
- **SSUI is the default look.** A control with nothing styled is the SSUI control (design_systems/ssui), still
  overridable by the document's theme and the node's props. Nothing is inherited from a host app.
- **The data keeps Flutter's names.** Prop names, enums and behaviors (`WidgetState`, `FocusNode` semantics,
  `TextInputType`, `ButtonStyle`) stay; only the widgets behind them go.
- Defaults must be good with zero props: the long-term notation `Column([Slider, Input, Toggle, Button])` renders
  the default controls.

Why: three rounds of independent builds traced every recurring control defect to a Material widget's own defaults
leaking through (seed colors, ripples, minimum heights pushing labels off center, floating and notched labels,
labels vanishing in the error state, a hard-coded error red, chip check marks resizing the chip, the dropdown's
arrow and menu card, the expansion tile's chevron and tap target, the slider thumb's shadow, Roboto beside a
declared font). Restyling from outside fixed each control partly; owning the render objects fixes the class.

## 2. Where the code is today

The node tree is already widget-free: `lib/src/render/node_tree.dart` turns each node into one `NodeBox` with a
chain of render objects (66 render-object classes: layout in `render/layout`, paint in `render/paint`, text in
`render/layout/text_box.dart`, scroll in `render/view_scroll.dart` and `render/layout/design_scroll.dart`, motion
and animation tickers in `render/behaviors.dart` and `render/animations.dart`, drag in `render/drag_track.dart`,
`runtime/gestures`). What is not: controls are Material widgets hosted as **islands** (`render/islands.dart`:
`IslandHost`, `IslandOwnerElement`, themed by `ControlTheme` in `render/control_theme.dart`), and the app shell is
widgets (`app/codelessly_widget.dart`, `app/presenter.dart`, `runtime/actions/{ui,toast,confirm_dialog,
hero_flights,route_transition,presentation_route}.dart`). At the start of M3, 61 files under `lib/` import
`package:flutter/material.dart`, `widgets.dart` or `cupertino.dart` (the ratchet in
`test/architecture_test.dart`, section 8).

## 3. The architecture in a page

| Flutter construct | Replaced by | Where | Status |
|---|---|---|---|
| `MaterialApp` / `WidgetsApp` / root `Material` | nothing at the root: a **root render object** (`RenderControlRoot`, the base of `RenderNodeView`) holding the services below | `render/controls/root.dart` | built |
| (host embedding) | `NodeView`, a `RenderObjectWidget`: creates the root, passes constraints, pointers, keys and lifecycle; nothing else | `render/node_view.dart` (moves to `lib/src/host/` in WS-K) | built (adapter) |
| `runApp` | `attachRoot(view, root)`: a `RenderView` for a `FlutterView` with the root as its child, no element tree | `render/controls/root.dart` | built (test view) |
| `Theme` / `ThemeData` | `ControlTokens`: SSUI's tokens bundled as data, under the document's theme, for a brightness and backdrop | `render/controls/tokens.dart`, `ssui_defaults.g.dart` | built |
| `MediaQuery` | the root's view metrics: size from constraints, `devicePixelRatio`, padding, text scale and platform brightness from the `FlutterView` / `PlatformDispatcher` | `RenderControlRoot.metrics` | planned (WS-K) |
| `Focus`, `FocusNode`, `FocusScope`, `FocusTraversalGroup` | `ControlFocusNode` and the root's `ControlFocusScope`: order, Tab and Shift-Tab, Enter and Space, autofocus, the focused `WidgetState` | `render/controls/focus.dart` | built |
| `Shortcuts` / `Actions` / `HardwareKeyboard` handlers | the root's `handleKeyEvent`; the adapter feeds it as a `FocusManager` early handler (so a handled key never reaches Flutter's traversal), whole-app mode as a `HardwareKeyboard` handler | `focus.dart`, `node_view.dart` | built |
| `Semantics` widgets | `describeSemanticsConfiguration` on each control's render object (button, label, enabled, focusable, focused, selected, tap and focus actions) | `render/controls/kit.dart` | built (buttons) |
| `GestureDetector`, `InkWell`, `MouseRegion` | the control's `handleEvent` with a `TapGestureRecognizer`, `MouseTrackerAnnotation` for hover and cursor; the tree already hit-tests without widgets (`NodeBox.hitTest`, `RenderReactions` in `runtime/actions/wiring.dart`, drag in `runtime/gestures`) | `kit.dart` | built |
| ink, ripple, `Material` elevation | the **state layer**: an overlay color per resolved `WidgetState`, a focus ring, shadows from tokens | `kit.dart` | built |
| `Overlay`, `OverlayEntry` | the root's **overlay layer**: entries are render boxes laid out against the root, painted after the content, hit-tested before it | `render/controls/overlay.dart` | built (tooltip) |
| `Tooltip` | the `tooltip` behavior (any node, declared since 30.0) shown in the overlay layer after `durations.tooltipDelay` | `overlay.dart` | built |
| `Navigator`, routes, `ModalRoute`, `PopScope` | a **screen stack** on the root: screens are root children with an enter/exit transition, modals are overlay entries with a barrier, back is a key/system-back handler on the root | `render/controls/screens.dart` | planned (WS-J) |
| `Hero` flights | `render/hero.dart` marks already exist; the flight becomes an overlay entry of the root that paints the mark's picture between two screens | `runtime/actions/hero_flights.dart` → `render/` | planned (WS-J) |
| tickers, `AnimationController` | already render-level: `Ticker` in `render/animations.dart`, `RenderMotion`; controls use the same (`ControlAnimation`) | `kit.dart` | exists |
| `Scrollable`, `ScrollController`, `ListView` | already render-level: `RenderDesignScroll`, `render/view_scroll.dart`, `widgets/collections_layout.dart`'s item layouts; what is still a widget is the list's `Scrollable` (drag physics, scrollbars) | `widgets/collections*.dart` | exists / WS-K for the last `Scrollable` |
| `EditableText` | a `RenderEditable` driven by a `TextInputClient` the control owns (section 3.2) | `render/controls/editable.dart` | built (WS-A; handles and toolbar planned) |
| platform views, video, web view | the **embed extension point**: an `EmbedFactory` registered by a feature layer; core never imports it (section 3.3) | `render/controls/embed.dart` | planned (WS-K) |

### 3.1 The root and its services

`RenderControlRoot` (`render/controls/root.dart`) is a `RenderProxyBox` whose child is the screen's `NodeBox`. It
owns:

- **the overlay layer**: `List<ControlOverlayEntry>`, each a render box adopted by the root, laid out with loose
  constraints of the root's size at an offset the entry computes from its anchor (`anchorRect` in the root's
  coordinates), painted after the child, hit-tested before it. Tooltips (built), menus, the dropdown's list, date
  and time pickers, toasts, drag avatars, modal sheets and dialogs (planned) are entries. An entry can carry a
  barrier (a full-size box that absorbs pointers and closes on tap).
- **the focus scope**: `ControlFocusScope`, the ordered set of `ControlFocusNode`s under the root.
- **key dispatch**: `handleKeyEvent(KeyEvent)`: Tab, Shift-Tab, Enter, Numpad Enter, Space, Escape go to the
  focus scope and the focused control. Fed by the adapter or the whole-app attach.
- **(planned) metrics, the screen stack, the text-input connection owner and back handling.**

The root is found from any render object by walking `parent` (`ControlRoot.of(renderObject)`), the way the tree
already finds its island owner. Every `NodeView` gets one, so old islands and new controls coexist in the same app
during the migration.

**The adapter.** `NodeView` stays a `RenderObjectWidget` and is the only widget the renderer needs. Today it is
also the island owner; when the last island goes (WS-K) its element shrinks to: create the root, `setRoot(tree,
rootId)`, register the root's key handler with `FocusManager.instance.addEarlyKeyEventHandler` while mounted, and
bridge focus (when a control takes focus it unfocuses the app's primary focus if that is a leaf; when the app focuses
one of its own widgets the root drops its focus). A host app that uses `MaterialApp` keeps working: it just has no
say in how the controls look.

**Whole-app attach.** `attachRoot(FlutterView view, RenderControlRoot root)` makes a `RenderView` for the view with
the root as child, registers it with `RendererBinding.instance.addRenderView`, registers the root's key handler with
`HardwareKeyboard.instance.addHandler`, and schedules frames; `detach()` reverses it. Built and proven against the
test view (`test/controls/root_test.dart`); a `main()` that runs a site with no widget at all is WS-K, since the
loader (`app/codelessly.dart`) and the presenter (`app/presenter.dart`) are still widget-shaped.

### 3.2 Text input without `EditableText`

The SDK's text field (WS-A) keeps Flutter's `RenderEditable` for layout, painting, caret, selection painting and
hit-testing of positions, and owns everything `EditableText` did around it:

1. **The input connection**: implement `TextInputClient` (and `DeltaTextInputClient` on web);
   `TextInput.attach(client, TextInputConfiguration(inputType, inputAction, autofillHints, enableSuggestions,
   autocorrect, obscureText, textCapitalization, keyboardAppearance))`, `show()`, `setEditingState`,
   `setEditableSizeAndTransform`, `setComposingRect`, `setCaretRect`, `setStyle` (font for the web overlay), close
   on blur. `updateEditingValue` applies the platform's value (IME composition range included).
2. **Composition**: draw the composing range underlined (`RenderEditable` takes a `TextSpan` built with the
   composing region, as `TextEditingController.buildTextSpan` does).
3. **Selection gestures**: tap to place the caret, double tap for a word, long press and drag, shift-click; drag on
   desktop; `TextSelectionGestureDetectorBuilder` is a widget, so the recognizers are added in the control's
   `handleEvent` (`TapAndPanGestureRecognizer`, `LongPressGestureRecognizer` from `gestures`).
4. **Handles and the toolbar**: overlay entries of the root (section 3.1), positioned from
   `RenderEditable.getEndpointsForSelection`; the toolbar is SSUI's menu (cut, copy, paste, select all). The
   platform's context menu on web (`BrowserContextMenu`) stays enabled.
5. **Keyboard editing**: arrows, word and line moves, Home/End, Backspace/Delete by grapheme and word, select all,
   copy/cut/paste (`Clipboard`), undo/redo (`UndoHistory`'s logic: a bounded stack of values coalesced by time),
   Enter for `submitted` and `textInputAction`, Tab leaving the field, Escape.
6. **Caret blink** with a `Ticker`; **cursor** `SystemMouseCursors.text`; **scroll** of a long single line and of
   multi-line text inside the field (`RenderEditable.offset` with a `ViewportOffset`).
7. **Autofill**: `AutofillClient` and an `AutofillScope` per form (`form` behavior) so a username and password field
   fill together; `TextInput.finishAutofillContext` on submit.
8. **Formatting and limits**: `maxLength`, `inputFormatters` equivalents the model has (`TextInputType`,
   `textCapitalization`), obscuring with the last character briefly shown on mobile.
9. **Semantics**: `isTextField`, `value`, `textSelection`, `onSetText`, `onSetSelection`, `onCopy/Cut/Paste`,
   `isObscured`, `maxValueLength`, `currentValueLength`, `isMultiline`, `isReadOnly`.
10. **Spell check** is deferred (section 9).

**As built (WS-A).** `render/controls/field_frame.dart` (`RenderFieldFrame`, `FieldDecoration`: the SSUI field box
that the dropdown shares), `editable.dart` (`FieldEditor`: items 1, 2, 5, 6, 7 and 8 above, with undo/redo as
`FieldUndoHistory`) and `text_field.dart` (`RenderTextField`, the recipe; items 3 and 9). The runtime reaches a field
through `TextFieldServices` (the `focus`/`editText` actions, forms). Not built yet: selection handles and the
toolbar as overlay entries (item 4), showing the last obscured character on mobile, the floating cursor, and
`DeltaTextInputClient` on web. Space and Enter are typed by the field itself (the focus scope would otherwise take
them as activation and the platform would never see them), which an IME composing with those keys on desktop may
notice.

### 3.3 What truly needs a widget or a texture

Video (`video_player` gives a texture id: a `TextureLayer` in a render object needs no widget), web view and
`HtmlElementView` (platform views: `PlatformViewRenderBox` / `RenderAndroidView` need a controller, created without
widgets but plugin APIs hand out widgets), maps and anything a plugin only ships as a widget. These go behind one
extension point, `EmbedFactory` (`render/controls/embed.dart`): a feature layer registers a factory by node type that
returns a render box. A factory that can only make a widget gets the **one remaining island host**, which moves from
`render/islands.dart` into `lib/src/host/embed_island.dart` and is used by nothing in the core. The architecture
test then asserts that no file under `lib/src/render` or `lib/src/runtime` imports `widgets.dart`.

## 4. The control kit

Every control is assembled from one small set of render-layer pieces (`render/controls/kit.dart`, **built**):

| Piece | What it does | Flutter counterpart |
|---|---|---|
| `RenderControl` | Base render box of a control: its `WidgetState` set (hovered, focused, pressed, selected, disabled), pointer handling (`TapGestureRecognizer`; press on down, release on up/cancel), hover via `MouseTrackerAnnotation` with a cursor, `enabled`, a `ControlFocusNode`, `onActivate` (tap, Enter, Space), semantics, min tap target | `ButtonStyleButton`'s `InkWell` + `FocusableActionDetector` + `Semantics` |
| `ControlStates` | the resolved state set, also written to the tree (`RenderTree.setState`) so the node's `states` patches apply as they did | `WidgetStatesController` |
| state layer | an overlay color per state from the tokens (`hoverOverlay`, `pressedOverlay`, filled-surface variants), drawn inside the shape, eased over `durations.control` | `ButtonStyle.overlayColor` |
| focus ring | a `focusBorder`-colored ring (1.5 px, SSUI's `controlFocusBorderWidth`) outside the shape when keyboard-focused | none in Material (SSUI's) |
| `ControlLabel` | a `TextPainter` of one line, ellipsised, **optically centered** (laid out with `TextHeightBehavior` even leading and centered on the glyph box, measured by the guard test) | `Text` in `DefaultTextStyle` |
| `ControlIcon` | a glyph from `render/paint/icon_glyph.dart` at a size and color | `Icon` |
| min tap target | `hitTest` grows to 44 × 44 (SSUI touch target; 48 for `MaterialTapTargetSize.padded`) around the visual box **without changing layout** | `MaterialTapTargetSize` (which Material does by layout) |
| semantics role | `describeSemanticsConfiguration`: `isButton`, `label`, `isEnabled`, `isFocusable`, `isFocused`, `isSelected`/`isToggled`, `onTap`, `onFocus`, tooltip | `Semantics(button: true, ...)` |

Controls are leaves: a button paints its surface, label and icon itself rather than composing node boxes, so
nothing about Flutter's `Row`/`Text` intrinsic quirks can push a label off center. A control that holds node
children (a list tile's slots, a card) uses the tree's own layout for them and the kit only for its chrome.

## 5. Defaults = SSUI

**Tokens as data.** `design_systems/ssui/design_system.json` stays the source. `tool/controls/bundle_ssui.dart`
writes its `theme` into `lib/src/render/controls/ssui_defaults.g.dart` (a `const` JSON map); a test fails when the
two differ. `ControlTokens.of(tree, backdrop)` reads, for the screen's brightness: SSUI's theme
(`forBrightness`), with the document's theme merged over it (`ThemeTokens.merge`), roles resolved
(`ThemeTokens.resolvedRoles`, section 7). So a document that sets only `primary` gets SSUI's geometry, overlays and
neutrals with its own primary; a document with a full theme gets its own look in SSUI's geometry.

**Geometry from the control scale.** SSUI's controls are 24/28/32/36/44 high (28 the default). A hugging control
takes the default (28); a node whose height is fixed or filled takes the box, and the metrics (horizontal padding,
font size, icon size, radius) come from the nearest step of the scale. There is no `size` prop: Flutter's buttons
have none (their size is `minimumSize`/`fixedSize`/`visualDensity`), and the node's `layout.height` already says
it. A theme's `sizes` (`xs`...`large`), `radii.control`, `radii.inner`, `buttonRadius` and `durations.control`
override the scale.

**One way: core types are the controls, SSUI components are presets.** The SSUI component documents
(`components/Button.json`, `TextInput.json`...) were written as node compositions because the core controls had a
Material look. Now the core types **are** SSUI-looking, so:

| SSUI component | Core type it collapses to | How the SSUI parameter maps |
|---|---|---|
| `Button` variant primary / secondary / outline / ghost / destructive | `filledButton` / `filledButton` + `style.backgroundColor: neutralFill` / `outlinedButton` / `textButton` / `filledButton` + `style.backgroundColor: error` | size → `layout.height` 24/28/32/36/44 |
| `Button` variant tertiary / elevated (in the Flutter package) | `filledButton` `tonal: true` / `elevatedButton` | |
| `IconButton` ghost / elevated | `iconButton` / `iconButton` + `style.side` | size → height |
| `TextInput`, `TextArea`, `Field` | `textField` (`maxLines`), `decoration.labelText` / `helperText` / `errorText` | WS-A |
| `Select` | `dropdown` | WS-B |
| `Checkbox`, `Radio`, `Switch`, `Slider`, `SegmentedControl` | `checkbox`, `radio`, `switch`, `slider`, `segmentedButton` | WS-E |
| `Tabs` | `tabBar` | WS-F |
| `Chip`, `Badge` | `chip`/`filterChip`..., `badge` | WS-C |
| `Tooltip` | the `tooltip` behavior | built |
| `ListRow`, `Card`, `SectionHeader`, `Banner`, `EmptyState`, `Avatar`, `Dialog` | stay components (compositions with no Flutter control counterpart; `Dialog` → WS-H's dialog) | |

The design system keeps its component files as **presets**: a call `{"type": "Button", "props": {"variant":
"outline"}}` expands to the core node (`outlinedButton`) instead of a composition, so one look and one behavior
exist per control. The `replaces` list in design_system.json already names the core types each component stands
for; WS-L rewrites the component files as expansions and the gallery renders both spellings identically.

## 6. The order and split for the remaining controls

**How the work avoids conflicts.** No workstream edits another's files. The shared touchpoints are pre-made:

- `lib/src/widgets/controls.dart` holds one map per family (`buttonRecipes` today; each family adds one line and a
  map of its recipes, which live in `render/controls/<family>.dart`); `widgets/registry.dart` spreads
  `controlRecipes` **after** the island maps, so a family's render-object recipe replaces the island recipe for its types by being added, not by editing
  `inputs.dart` or `material.dart`. The dead island code is deleted by the owner in a final commit that touches only
  their own functions (or by WS-K).
- The kit (`kit.dart`), focus (`focus.dart`), overlay (`overlay.dart`) and tokens (`tokens.dart`) are owned by
  **WS-0** (this task). A family that needs more from them adds it in a **new** file
  (`kit_<family>.dart`) or asks WS-0; changes to the four shared files go in small separate commits first.
- Tests: each family adds `test/controls/<family>_test.dart` and its own section of the guard
  (`test/app/no_material_look_test.dart` keeps a per-family list, `_renderControls`); the import ratchet's list
  shrinks by the family's own lines.

| WS | Controls | Owns (new unless marked) | Size | Acceptance tests |
|---|---|---|---|---|
| 0 | kit, focus, overlay, tokens, root, **buttons** | `render/controls/{kit,focus,overlay,tokens,ssui_defaults.g,root,buttons}.dart`, `widgets/controls.dart`, `tool/controls/bundle_ssui.dart`, `test/controls/{root,direct_attach,buttons,ssui_reference,tokens}_test.dart` | done | section 10 |
| A | `textField` (+ `signature` stays an island until A ends) | `render/controls/{editable,text_field,field_frame}.dart`, `test/controls/text_field_test.dart`; deletes `_TextFieldIsland` and its helpers in `widgets/inputs.dart` | XL (3–4 weeks) | typing, IME composition (a fake `TextInput` channel), selection by tap/drag/keys, handles and toolbar as overlay entries, clipboard, undo/redo, autofill group, obscure, `maxLength`, `submitted`/`changed`, `focus`/`editText` actions, label above (never floating), error text and red from tokens, label centered (guard), semantics, SSUI reference match |
| B | `dropdown`, menus (`popupMenu` and the select list), the field frame shared with A | `render/controls/{dropdown,menu}.dart`; deletes `_DropdownIsland` | L | opens an overlay menu anchored under the field; keyboard (arrows, type-ahead, Enter, Escape); the value's label centered; no Material arrow or card; SSUI Select reference |
| C | `chip`, `actionChip`, `choiceChip`, `filterChip`, `inputChip`, `badge` | `render/controls/chips.dart`; deletes `_chip`, `_ChipIsland`, `_ContentWidth` in `widgets/material.dart` | M | the check mark never resizes the chip (reserved), delete icon, selected via prop, label centered, SSUI Chip/Badge |
| D | `accordion`, `expansionTile`, `listTile` | `render/controls/{tile,expansion}.dart`; deletes `ExpansionTile` use in `widgets/collections_islands.dart`, `_listTile` in `widgets/material.dart` | M | the whole header is the tap target, chevron from tokens, slots laid out by the tree, keyboard, expand animation on the tree's ticker, semantics `isExpanded` |
| E | `switch`, `checkbox`, `radio`, `slider` (+ range), `segmentedButton` | `render/controls/{toggles,slider,segmented}.dart`; deletes the islands in `widgets/inputs.dart`, `widgets/inputs_toggle.dart`, `widgets/slider_paint.dart` | L | value write-back (`changed`), drag and keys for the slider (arrows, Page, Home/End), no thumb shadow, `radioGroup`, toggled/checked semantics, SSUI Switch/Checkbox/Radio/Slider/SegmentedControl references |
| F | `tabBar`, `tabs`, `navigationBar`, `bottomNavigationBar`, `appBar` | `render/controls/{tab_bar,navigation_bar,app_bar}.dart`; deletes `TabBar` in `collections_islands.dart`, `_navigationBar`, `_appBar`, the `Scaffold` in `widgets/material.dart` | M | selected indicator, keyboard arrows, labels centered, app bar slots via `render/layout/scaffold_slots.dart` |
| G | `datePicker`, `timePicker`, `dateTimeInput` | `render/controls/{calendar,time_dial,pickers,kit_pickers}.dart`, `widgets/picker_locale.dart` (intl names and the runtime clock, which render may not import); deletes `showDatePicker`/`showTimePicker` use in `widgets/inputs.dart` | built (`test/controls/pickers_test.dart`, `pickers_reference_test.dart`) | picker as an overlay entry (popover on wide, sheet on narrow), keyboard navigation of the grid, locale first weekday, value write-back |
| H | dialogs, drawers, bottom sheets, toasts, tooltips beyond the behavior, `confirm` | `render/controls/{dialog,sheet,toast}.dart`; rewrites `runtime/actions/{ui,toast,confirm_dialog,feedback_theme}.dart` on overlay entries | L | barrier and dismiss, focus trapped in the dialog and returned on close, Escape, toast stacking and timing, SSUI Dialog reference |
| I | `circularProgressIndicator`, `activityIndicator`, progress bars | `widgets/indicators.dart` (`_circularProgressIndicator`, `_activityIndicator`) to painters; drops `cupertino.dart` | S | spinner on the tree's ticker, indeterminate animation, no Cupertino import |
| J | the app shell: screens, routes, modals, back, hero flights, page transitions | `render/controls/screens.dart`; rewrites `app/{codelessly_widget,presenter,page_transitions,overlay_screens,backdrop_screens,back_guard}.dart`, `runtime/actions/{hero_flights,route_transition,presentation_route,presentation_scope}.dart` | XL | navigate push/replace/pop/reset, URL sync on web (host-provided), modal over screen, system back, hero flight between screens, route transitions as before, all existing `test/actions/navigation_test.dart`, `modals_test.dart`, `app/routing_test.dart` green |
| K | final removal: lists' `Scrollable`, `media.dart`/players behind `EmbedFactory`, `IslandHost` to `host/embed_island.dart`, `NodeView` to `host/`, the whole-app `main`, metrics | everything left in the ratchet | L | the ratchet list is empty for `render/`, `runtime/`, `widgets/`; `app/` keeps only `host/`; a site runs with `attachRoot` and no widget |
| L | design system collapse | `design_systems/ssui/components/*.json` as presets, `lib/src/core/design_system*.dart` (API) | M | each SSUI component renders identically to its core type; gallery |

Order: A first (hardest, longest, and B reuses its field frame: B starts when A's `field_frame.dart` lands, in about
a week); C, D, E, F, G, I in parallel from now; H after B's menu (it shares the overlay's barrier); J after H; K
last; L any time after E.

## 7. Theme roles

Roles are top-level keys of the theme, by Flutter's `ColorScheme` names (`primary`, `onPrimary`, `surface`,
`onSurface`, `error`, plus the SDK's `success`, `warning`). Two spellings the builds used never reached controls:

- **`"primary": "forest"`** (a role naming a theme color). It is the theme's general rule ("a color may name
  another"), so it **works**: `ThemeTokens.resolvedRoles()` (in this package) replaces each role that names a color
  with that color, through any chain, in light and dark; every consumer (the SDK's `ControlTokens`, the island
  `ThemeData`, `themeValues`) reads roles through it.
- **`"colors": {"primary": ...}`** (a role written inside `colors`). That is a second spelling of the role, so per
  the one-way rule it is a **validation warning**, `theme_role_in_colors`, with the fix: move it to the top level
  (or name it: `"primary": "<that color's name>"`). It is not applied to controls.

The generated STARTER's theme example now declares `primary` and `onPrimary` as names of its palette.

## 8. The public Dart API without widgets

What an app developer uses today and what it becomes:

| Today | After M3 |
|---|---|
| `CodelesslyWidget(codelessly:, controller:, layoutId:)` in a `MaterialApp` | `CodelesslyWidget` stays as the **adapter** (a widget that hosts a `RenderControlRoot`), usable in any widget tree with no `MaterialApp` above it; `CodelesslyView.attach(view, codelessly)` for whole-app mode (WS-K) |
| `NodeTree(source, recipes:)` + `NodeView(tree:, rootId:)` | unchanged names; `NodeView` is the adapter; `RenderControlRoot(tree, rootId)` for render-level embedding |
| `WidgetRecipe = void Function(NodeBuilder b, Node n, List<RenderBox> chain)` | unchanged: it has always appended **render objects**. Its `NodeBuilder.island(key, WidgetBuilder)` remains only for embeds (`EmbedFactory`); a recipe gets the kit through `NodeBuilder` (`b.tree`, `ControlTokens.of`, `ControlRoot.of`) |
| `CodelesslyConfig.recipes` | unchanged |
| `CodelesslyConfig.actionHandlers` / `ActionHandler` taking a `BuildContext` | the handler takes an `ActionContext` that exposes the root's services (`overlay`, `focus`, `screens`, `metrics`) instead of a `BuildContext`; a host that needs its own widgets (its own dialog) gets the adapter's `BuildContext` as an optional field, null in whole-app mode |
| `CodelesslyWidget.onGenerateRoute`, `CodelesslyWidget.route`, `CodelesslyPageRoute` | kept for hosts that keep a `Navigator` (adapter mode). The SDK's own navigation uses the root's screen stack and calls `onNavigate` first, as today |

**CodelesslySite** (read, not changed) embeds with `MaterialApp(onGenerateRoute:)` + `CodelesslyWidget.route`,
`CodelesslyPageRoute.of`, and an `onNavigate` handler that pushes routes on its `Navigator`, plus
`CodelesslyAppIdentityUpdater`. Migration: nothing changes until WS-J. After WS-J it either keeps that shape
(adapter mode, still supported) or drops `MaterialApp` for `CodelesslyView.attach` with a `UrlStrategy` passed to
the screen stack, which replaces its `navigate` handler (about 120 lines in `lib/project_view.dart` go). The visible
difference for the site: controls look SSUI by default instead of the neutral Material-derived look; sites that set a
theme keep their colors.

## 9. Risks and what is deferred

- **Text input is the largest risk** (WS-A): IME on web and Android, autofill and accessibility are where
  `EditableText` holds years of fixes. Mitigation: keep `RenderEditable`; port behaviors with tests from
  Flutter's `editable_text_test.dart` cases we rely on; ship the island as a fallback behind a config flag until A's
  test list is green on web.
- **Focus across islands and render controls** during the migration: Tab moves within render controls of a root and
  Flutter's traversal moves within islands; a Tab from the last render control does not reach an island text field.
  Resolved when A lands.
- **Accessibility parity**: semantics written by hand can miss what widgets added implicitly (`SemanticsService`
  announcements, `liveRegion`). Each workstream's tests include a `SemanticsTester` assertion.
- **Platform views** keep one island host forever (section 3.3). Accepted.
- **Deferred**: spell check, `SelectableRegion` (selecting static text across nodes), `Scrollbar` theming, right-to-left
  audit of every control, `CupertinoApp`-style adaptive controls (one look: SSUI), a `loading` state for buttons
  (no prop exists; SSUI has one: add as `ButtonProps.loading` later if wanted).
- **Parity goldens** record node rectangles; SSUI sizes differ from Material's for hugging controls. Each workstream
  lists its size changes (section 10 for buttons).

## 10. Buttons (WS-0), as built

| Core type | SSUI variant | Fill / label | Border | Notes |
|---|---|---|---|---|
| `filledButton` | primary | `primary` / `onPrimary` | none | `tonal: true` → SSUI tertiary: `tertiaryBackground` / `onSurface` |
| `elevatedButton` | elevated | `raisedBackground` / `onSurface` | 1 px `primaryBorder` (`secondaryBorder` hovered) | `style.elevation` adds a shadow |
| `outlinedButton` | outline | transparent / `onSurface` | 1 px `primaryBorder` (`secondaryBorder` hovered) | |
| `textButton` | ghost | transparent / `onSurface` | none | |
| `iconButton` | IconButton ghost | transparent / `secondaryText` (`onSurface` hovered) | none | square of the height; icon 14 at 28 |
| `floatingActionButton` | (none in SSUI) primary, floating | `primary` / `onPrimary` | none | `shadows.level3`; radius `radii.dialog` (12; small `radii.panel` 8; large 18); icon 24 (large 36); its box is its design size as before |

States: hover and press are SSUI's overlays (`hoverOverlay`, `pressedOverlay`; on filled surfaces black 8 %/16 % in
light, white 12 %/20 % in dark, as SSUI's buttons), focus is the 1.5 px `focusBorder` ring drawn as a stroke outside
the shape (SSUI's widget paints it as a spread shadow, which also tints a ghost button's inside), disabled is 50 %
opacity, **selected** (a bound `selected`, as Flutter's `statesController`) is `activeTint` with `primary` ink on the
non-filled kinds. Every `style` field and the node's `states` patches still apply over these; a node's own padding
sets the horizontal padding and, when its vertical padding is larger than the step, the hugging height. Proof:
`test/controls/ssui_reference_test.dart` rebuilds SSUI's reference page from zero-prop core nodes and matches it to
0.06 % (light) and 0.04 % (dark) of the pixels; before/after renders are in
`design_systems/ssui/examples/renders/m3`. Size changes in the parity goldens are listed in the SDK's CHANGELOG.

**Where the first task stopped.** Built: the doc; the kit, focus scope and keyboard, semantics for buttons, the
overlay layer with the tooltip, SSUI's tokens as data, the root with the adapter and the whole-app attach proven
against the test view; all six button types; the ratchet (60 files). Not built: state transitions are instant (no
150 ms ease yet), a Tab from the last render control does not reach an island (section 9), the root's metrics and
screen stack, a `main()` with no widget. The button path's own files import no widget library, but
`render/node_tree.dart` (which every recipe imports) still imports `widgets.dart` for the island hook
(`NodeBuilder.island`); that goes with WS-K.

## 12. Status after the control workstreams (2026-11-14)

Merged: the kit (with the 150 ms ease, `ControlTransition`, key pass-through and `busy`), focus, overlay, root,
buttons (with `loading`), text field, dropdown and menu (`ControlPopup`, `AnchoredPlacement`, `CenteredPlacement`),
chips and badge, tiles and accordions, toggles (with `label`), slider, segmented button, tab bars, navigation bars,
app bar, date and time pickers, spinners. A control with no layout hugs (`WidgetSpec.hugs`). The SDK suite passes
(1,885 tests). The import ratchet is at 51 files (from 60); no file imports Cupertino.

What is left was measured by swapping each remaining file's widget imports for the rendering library and counting
what breaks: about 2,300 uses in 51 files. By size: `app/codelessly_widget.dart` 238, `widgets/collections_data_list.dart`
233, `features/media/players.dart` 166, `widgets/collections_reorder.dart` 160, `render/control_theme.dart` 134,
`runtime/actions/toast.dart` 126, `widgets/inputs.dart` 110 (the signature pad and shared helpers), then about forty
files under 90 each.

The remainder, done in the main session, in this order:

1. **Feedback as documents.** `ActionUi` is already the seam between actions and what shows them. A new
   implementation on the root's overlay layer replaces `NavigatorActionUi`. A toast and a confirm dialog are built
   as small node trees (a column, texts, buttons) from the request and shown in a `ControlPopup`, so they take the
   theme, the controls and the design system like any other UI, and the bespoke widget views
   (`toast.dart`, `confirm_dialog.dart`, `feedback_theme.dart`, `feedback_icon.dart`) are deleted. Focus is
   trapped in a dialog and returned on close; popups open and close on `ControlTransition`.
2. **Screens.** `render/controls/screens.dart`: a stack of screens as render objects with the route transitions
   and hero flights on tickers, modals and sheets as popups, the system back button and URL sync from the host.
   It replaces the Navigator, the routes and `app/codelessly_widget.dart`'s widget tree.
3. **Lists.** The collections runtime (data list, reorder, swipe, pagination, table, page view) on the SDK's own
   scroll render objects instead of `Scrollable`; `ScrollPosition` leaves `reveal`, `view_scroll`, `handlers`.
4. **Embeds.** Islands, media players and web views behind `EmbedFactory` in `host/`; `control_theme.dart` and
   `indicator_theme.dart` deleted with the last island control (the signature pad becomes a render object).
5. **The whole-app entry.** A site runs from `attachRoot` with no widget; the adapter in `host/` is the only file
   on the ratchet.

Since then (same day): the ratchet is at 47. The indicators (charts, gauges, barcode, progress) take their color
roles from `render/surface_roles.dart`, a widget-free file the Material theme is now also made from, so
`indicator_theme.dart` imports no widget library; the typewriter's caret room is a painting-layer placeholder span
instead of a `WidgetSpan`. Measured again by the same swap: about 2,270 uses in 47 files. Step 1 (feedback as
documents) was scoped and found to depend on step 2: a toast outlives the screen it was shown on and sits under a
modal's barrier, both of which are the Navigator's doing today, so the screen stack comes first and toasts,
confirms and modals move onto its overlay with it.

Gaps the workstreams left, folded into the steps above: a `popupMenu` node type on the menu; tile text and icon
color props; write-back of a bound `expanded`; app-bar and navigation item reactions; the implied back button;
selection handles and the copy and paste toolbar; an icon size written at its catalog default.
