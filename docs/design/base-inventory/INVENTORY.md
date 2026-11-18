# The notation's words, by kind (generated)

Written by `tool/vocabulary_inventory.dart` (track B, step B1; design note 23). Do not edit: run it again.

Read from the code's declarations; hand-kept only where the code has nothing to read:

- **rewriteFunctions**: The function and file that rewrites each page word (kind b): read from the code by hand, since a word set does not say which branch of PageWords._rewrite reads it.
- **contextual**: The rewrites of base words in a context (a Text with a look, a Badge with a width, a Row that turns at a width, an Input in a bar, a gallery opening the page viewer, `sticky=true`, an Avatar's `src=`): branches of PageWords._rewrite and _plain with no word set of their own.
- **statements**: The statement words a line may start with that are no node (`state`, `each`, `if` …): define.dart's _statements, read from the source, with `define`, `primitive`, `component` and `project` added from the grammar.

Counted over the first corpus (442 answers: the SDK's `tool/vocabulary/corpus*/*/answers`), the round 10 harvest (`runs` and `uses` from its table of the words beyond the core: a word of the core is not listed there; `quoted`: lines in the notation the harvest quotes), and the notation reference's 152 ```notation blocks. A use is a line that writes the word (a line's first word for a type, `key=` or a bare word for a property, `onX=` for an event). Taught: named in the open prompt (`open`) or the full prompt (`full`), both 1440 wide; documented: named in `docs/reference/notation/*.md`.

## Counts per kind

| kind | | words | written somewhere | never written | taught (open or full) |
|---|---|---|---|---|---|
| a | base: implemented by the renderer and the parser | 1290 | 520 | 770 | 283 |
| b | rewrite: written out into other lines by Dart code in the expander | 72 | 32 | 40 | 25 |
| c | alias or universal word: another name, or a word every line takes | 144 | 105 | 39 | 53 |
| d | design system: a component or a defined word (data) | 347 | 143 | 204 | 21 |
| e | short name: a node type the parser finishes with code of its own | 28 | 23 | 5 | 23 |

1881 rows, 1715 distinct words: a word declared in two places is a row in each (86 words are in more than one kind: `AppBar`, `Avatar`, `Badge`, `Box`, `Brand`, `Button`, `Canvas`, `Card`, `Checkbox`, `Chip`, `Dialog`, `Dropdown`, `GridView`, `Hero`, `IconButton`, `MenuItem`, `Modal`, `NavItem`, `NavSection`, `NumberInput`, `Panel`, `ProgressBar`, `Radio`, `RangeSlider`, `Select`, `Sidebar`, `Signature`, `Slider`, `Switch`, `Table`, `Tabs`, `TopBar`, `Wanted`, `animate`, `animation`, `autofocus`, `border`, `border-bottom`, `border-left`, `border-right`, `border-top`, `borderColor`, `borderWidth`, `color`, `columns`, `computed`, `delay`, `description`, `disabled`, `drag`, `drop`, `duration`, `enabled`, `error`, `fill`, `fontFamily`, `fontSize`, `fontWeight`, `format`, `gap` …). Kind d counts a component once however many design systems have it.

By category:

| kind | category | words | never written |
|---|---|---|---|
| a | action type | 47 | 26 |
| a | action verb | 12 | 0 |
| a | draw op | 12 | 3 |
| a | event | 53 | 25 |
| a | formula function | 167 | 89 |
| a | grammar statement | 18 | 7 |
| a | grammar word (universal table) | 55 | 2 |
| a | node type | 70 | 27 |
| a | property | 788 | 578 |
| a | record line | 5 | 0 |
| a | value: animate= | 19 | 10 |
| a | value: media condition | 6 | 2 |
| a | value: state | 6 | 1 |
| a | value: variant | 32 | 0 |
| b | contextual rewrite | 8 | 8 |
| b | line rewrite | 4 | 0 |
| b | page word | 26 | 13 |
| b | page word: bar | 7 | 5 |
| b | page word: group label | 6 | 5 |
| b | page word: item | 4 | 2 |
| b | page word: overlay | 11 | 4 |
| b | page word: sidebar | 5 | 3 |
| b | page word: table | 1 | 0 |
| c | alias: event | 7 | 3 |
| c | alias: events | 5 | 0 |
| c | alias: flags | 9 | 3 |
| c | alias: parameter | 36 | 10 |
| c | alias: parameters | 11 | 1 |
| c | alias: type | 13 | 5 |
| c | alias: verb | 1 | 1 |
| c | parser word | 43 | 16 |
| c | universal word | 19 | 0 |
| d | alias of a design system | 5 | 2 |
| d | component | 264 | 202 |
| d | defined word | 78 | 0 |
| e | short name | 28 | 5 |

## Synonyms: different words with the same expansion

Each type word of kinds b, c and e, and each node type, written `Word#probe "Label"` alone, in an App's Sidebar and in a Page's Section, expanded at 1440; words whose three expansions are the same (ids aside) are one group.

- App (b), AppShell (b), Window (b)
- AppBar (a), Nav (b), Navbar (b), NavBar (b), TopBar (b), Topbar (b), Header (b), AppBar (b)
- Box (a), Column (a), List (e), Box (e)
- Brand (b), Logo (b)
- Calendar (a), MiniCalendar (c), CalendarMonth (c), MonthGrid (c)
- Donut (e), DonutChart (e)
- FilledButton (a), Button (e)
- Footer (b), StickyBar (c), StickyFooter (c), BottomBar (c), FooterBar (c), BottomDock (c)
- Gauge (e), Dial (e)
- GridView (a), Grid (e), GridView (e)
- H3 (b), H4 (b)
- Heading (b), Title (b), H2 (b)
- LineChart (a), AreaChart (e)
- Main (b), Content (b)
- NavItem (b), NavLink (b), SidebarItem (b), MenuItem (b)
- NavSection (b), NavGroup (b), NavLabel (b), SidebarSection (b), SidebarLabel (b), SidebarGroup (b)
- PieChart (e), Pie (e)
- Popover (b), Popup (b)
- ProgressBar (a), Progress (e)
- QRCode (c), QrCode (c)
- Section (b), Hero (b)
- Sheet (b), BottomSheet (b)
- Sidebar (b), Aside (b), SideNav (b), Sidenav (b), Rail (b)
- SidebarFooter (b), NavFooter (b)
- Switch (a), Toggle (e)
- Text (a), Highlight (c), HighlightText (c)
- TextField (a), Input (e)

## Kind a: base: implemented by the renderer and the parser

| word | category | declared | stands for | expands to | corpus uses (answers) | round 10 | reference uses | taught | documented |
|---|---|---|---|---|---|---|---|---|---|
| `animate` | action type | catalog action animate |  |  | 0 (0) |  | 3 | open full | yes |
| `announce` | action type | catalog action announce |  |  | 32 (4) |  q2 | 4 | full | yes |
| `auth` | action type | catalog action auth |  |  | 4 (2) |  | 1 |  | yes |
| `callApi` | action type | catalog action callApi |  |  | 0 (0) |  | 0 |  | yes |
| `callFunction` | action type | catalog action callFunction |  |  | 0 (0) |  | 0 |  | yes |
| `captureScreenshot` | action type | catalog action captureScreenshot |  |  | 0 (0) |  | 0 |  | yes |
| `closeModal` | action type | catalog action closeModal |  |  | 0 (0) |  | 0 |  | yes |
| `cloudBatch` | action type | catalog action cloudBatch |  |  | 0 (0) |  | 0 |  | yes |
| `cloudData` | action type | catalog action cloudData |  |  | 0 (0) |  | 0 |  | yes |
| `cloudDocuments` | action type | catalog action cloudDocuments |  |  | 0 (0) |  | 0 |  | yes |
| `cloudFiles` | action type | catalog action cloudFiles |  |  | 0 (0) |  | 0 |  | yes |
| `componentEvent` | action type | catalog action componentEvent |  |  | 0 (0) |  | 0 |  | yes |
| `confirm` | action type | catalog action confirm |  |  | 0 (0) |  q2 | 0 | full | yes |
| `controlDismissible` | action type | catalog action controlDismissible |  |  | 0 (0) |  | 0 |  | yes |
| `controlTrack` | action type | catalog action controlTrack |  |  | 0 (0) |  | 0 |  | yes |
| `controlTransform` | action type | catalog action controlTransform |  |  | 0 (0) |  | 0 |  | yes |
| `copyToClipboard` | action type | catalog action copyToClipboard |  |  | 0 (0) | 1 runs, 1 | 0 |  | yes |
| `delay` | action type | catalog action delay |  |  | 1 (1) |  | 1 | open full | yes |
| `downloadFile` | action type | catalog action downloadFile |  |  | 0 (0) |  | 0 |  | yes |
| `editText` | action type | catalog action editText |  |  | 0 (0) |  | 0 |  | yes |
| `emitEvent` | action type | catalog action emitEvent |  |  | 0 (0) |  | 2 |  | yes |
| `focus` | action type | catalog action focus |  |  | 22 (12) |  | 1 | open full | yes |
| `forEach` | action type | catalog action forEach |  |  | 0 (0) |  | 0 |  | yes |
| `haptic` | action type | catalog action haptic |  |  | 2 (2) |  | 0 |  | yes |
| `if` | action type | catalog action if |  |  | 3 (3) |  | 5 | open full | yes |
| `loadCloudData` | action type | catalog action loadCloudData |  |  | 0 (0) |  | 0 |  | yes |
| `navigate` | action type | catalog action navigate |  |  | 0 (0) |  q1 | 4 |  | yes |
| `openLink` | action type | catalog action openLink |  |  | 0 (0) |  | 0 |  | yes |
| `openModal` | action type | catalog action openModal |  |  | 0 (0) |  q8 | 2 |  | yes |
| `paginate` | action type | catalog action paginate |  |  | 0 (0) |  | 0 |  | yes |
| `paywall` | action type | catalog action paywall |  |  | 0 (0) |  | 2 |  | yes |
| `playSound` | action type | catalog action playSound |  |  | 0 (0) |  | 0 |  | yes |
| `preloadImages` | action type | catalog action preloadImages |  |  | 0 (0) |  | 0 |  | yes |
| `print` | action type | catalog action print |  |  | 3 (2) |  | 0 |  | yes |
| `reloadCloudData` | action type | catalog action reloadCloudData |  |  | 0 (0) |  | 0 |  | yes |
| `retryFailed` | action type | catalog action retryFailed |  |  | 0 (0) |  | 0 |  | yes |
| `runScript` | action type | catalog action runScript |  |  | 0 (0) |  | 0 |  | yes |
| `scrollTo` | action type | catalog action scrollTo |  |  | 0 (0) |  | 4 |  | yes |
| `setStorage` | action type | catalog action setStorage |  |  | 0 (0) |  | 5 |  | yes |
| `setThemeMode` | action type | catalog action setThemeMode |  |  | 0 (0) | 4 runs, 5 | 2 |  | yes |
| `setValue` | action type | catalog action setValue |  |  | 0 (0) |  | 0 |  | yes |
| `setVariable` | action type | catalog action setVariable |  |  | 0 (0) |  | 15 |  | yes |
| `setVariant` | action type | catalog action setVariant |  |  | 0 (0) |  | 0 |  | yes |
| `showToast` | action type | catalog action showToast |  |  | 0 (0) |  | 2 |  | yes |
| `speak` | action type | catalog action speak |  |  | 19 (7) |  | 1 |  | yes |
| `submitForm` | action type | catalog action submitForm |  |  | 0 (0) |  | 0 |  | yes |
| `validate` | action type | catalog action validate |  |  | 0 (0) |  | 5 |  | yes |
| `announce` | action verb | notation.dart notationVerbs |  |  | 32 (4) |  q2 | 4 | full | yes |
| `blur` | action verb | notation.dart notationVerbs |  |  | 0 (0) |  | 1 |  | yes |
| `close` | action verb | notation.dart notationVerbs |  |  | 1764 (423) |  q6 | 4 | open full | yes |
| `confirm` | action verb | notation.dart notationVerbs |  |  | 0 (0) |  q2 | 0 | full | yes |
| `copy` | action verb | notation.dart notationVerbs |  |  | 154 (109) |  q1 | 0 | open full | yes |
| `emit` | action verb | notation.dart notationVerbs |  |  | 1288 (329) |  q14 | 9 | open full | yes |
| `focus` | action verb | notation.dart notationVerbs |  |  | 22 (12) |  | 1 | open full | yes |
| `go` | action verb | notation.dart notationVerbs |  |  | 4567 (434) |  q203 | 5 | open full | yes |
| `link` | action verb | notation.dart notationVerbs |  |  | 42 (29) |  | 1 | open full | yes |
| `open` | action verb | notation.dart notationVerbs |  |  | 1704 (431) |  q17 | 6 | open full | yes |
| `scroll` | action verb | notation.dart notationVerbs |  |  | 42 (21) |  | 0 | open full | yes |
| `toast` | action verb | notation.dart notationVerbs |  |  | 2547 (437) |  q1 | 3 | open full | yes |
| `arc` | draw op | custom_paint_fields.dart DrawOpSpecs |  |  | 0 (0) |  | 0 |  | yes |
| `circle` | draw op | custom_paint_fields.dart DrawOpSpecs |  |  | 0 (0) |  q34 | 4 |  | yes |
| `group` | draw op | custom_paint_fields.dart DrawOpSpecs |  |  | 0 (0) |  q26 | 0 | open full | yes |
| `image` | draw op | custom_paint_fields.dart DrawOpSpecs |  |  | 0 (0) |  | 0 | open full | yes |
| `line` | draw op | custom_paint_fields.dart DrawOpSpecs |  |  | 0 (0) |  q37 | 3 | open full | yes |
| `oval` | draw op | custom_paint_fields.dart DrawOpSpecs |  |  | 0 (0) |  q10 | 0 |  | yes |
| `paragraph` | draw op | custom_paint_fields.dart DrawOpSpecs |  |  | 0 (0) |  q4 | 1 |  | yes |
| `path` | draw op | custom_paint_fields.dart DrawOpSpecs |  |  | 0 (0) |  q110 | 2 |  | yes |
| `points` | draw op | custom_paint_fields.dart DrawOpSpecs |  |  | 0 (0) |  | 0 | full | yes |
| `rect` | draw op | custom_paint_fields.dart DrawOpSpecs |  |  | 0 (0) |  q28 | 2 |  | yes |
| `repeat` | draw op | custom_paint_fields.dart DrawOpSpecs |  |  | 0 (0) |  q45 | 2 |  | yes |
| `rrect` | draw op | custom_paint_fields.dart DrawOpSpecs |  |  | 0 (0) |  q4 | 1 |  | yes |
| `onActionError` | event | triggers.dart TriggerType.actionError |  |  | 0 (0) |  | 0 |  | yes |
| `onBackPressed` | event | triggers.dart TriggerType.backPressed |  |  | 0 (0) |  | 0 |  | yes |
| `onBlur` | event | triggers.dart TriggerType.focusLost (notation_events.dart notationEventNames) |  |  | 2 (2) |  | 0 |  | yes |
| `onChange` | event | triggers.dart TriggerType.changed (notation_events.dart notationEventNames) |  |  | 310 (159) | 1 runs, 1 q5 | 5 | open full | yes |
| `onChangeEnd` | event | triggers.dart TriggerType.changeEnd |  |  | 1 (1) |  | 0 |  | yes |
| `onCursorExit` | event | triggers.dart TriggerType.cursorExit |  |  | 0 (0) |  | 0 |  | yes |
| `onDeleted` | event | triggers.dart TriggerType.deleted |  |  | 0 (0) |  | 0 |  | yes |
| `onDoubleTap` | event | triggers.dart TriggerType.doubleTap |  |  | 15 (8) |  | 0 |  | yes |
| `onDrag` | event | triggers.dart TriggerType.drag |  |  | 7 (6) | 1 runs, 1 | 0 |  | yes |
| `onDragCancel` | event | triggers.dart TriggerType.dragCancel |  |  | 0 (0) |  | 0 |  | yes |
| `onDragCompleted` | event | triggers.dart TriggerType.dragCompleted |  |  | 0 (0) |  | 0 |  | yes |
| `onDragEnd` | event | triggers.dart TriggerType.dragEnd |  |  | 3 (2) |  | 0 |  | yes |
| `onDragEnter` | event | triggers.dart TriggerType.dragEnter |  |  | 0 (0) |  | 0 |  | yes |
| `onDragExit` | event | triggers.dart TriggerType.dragExit |  |  | 0 (0) |  | 0 |  | yes |
| `onDragStart` | event | triggers.dart TriggerType.dragStart |  |  | 5 (2) |  | 0 |  | yes |
| `onDrop` | event | triggers.dart TriggerType.drop |  |  | 128 (85) |  | 1 | open full | yes |
| `onDropRejected` | event | triggers.dart TriggerType.dropRejected |  |  | 0 (0) |  | 0 |  | yes |
| `onEditingComplete` | event | triggers.dart TriggerType.editingComplete |  |  | 0 (0) |  | 0 |  | yes |
| `onEnterViewport` | event | triggers.dart TriggerType.enterViewport |  |  | 0 (0) |  | 0 |  | yes |
| `onEvent` | event | triggers.dart TriggerType.event |  |  | 0 (0) |  | 0 |  | yes |
| `onExitViewport` | event | triggers.dart TriggerType.exitViewport |  |  | 0 (0) |  | 0 |  | yes |
| `onFocus` | event | triggers.dart TriggerType.focusGained (notation_events.dart notationEventNames) |  |  | 3 (3) |  | 0 |  | yes |
| `onFrame` | event | triggers.dart TriggerType.frame |  |  | 0 (0) |  | 0 |  | yes |
| `onHold` | event | triggers.dart TriggerType.hold |  |  | 17 (7) |  | 0 |  | yes |
| `onHover` | event | triggers.dart TriggerType.cursorEnter (notation_events.dart notationEventNames) |  |  | 2 (2) |  | 0 | full | yes |
| `onHoverMove` | event | triggers.dart TriggerType.hover (notation_events.dart notationEventNames) |  |  | 0 (0) |  | 0 |  | yes |
| `onImageError` | event | triggers.dart TriggerType.imageError |  |  | 0 (0) |  | 0 |  | yes |
| `onImageLoaded` | event | triggers.dart TriggerType.imageLoaded |  |  | 0 (0) |  | 0 |  | yes |
| `onImageLoading` | event | triggers.dart TriggerType.imageLoading |  |  | 0 (0) |  | 0 |  | yes |
| `onKeyDown` | event | triggers.dart TriggerType.keyDown |  |  | 5 (4) |  | 0 |  | yes |
| `onKeyUp` | event | triggers.dart TriggerType.keyUp |  |  | 4 (2) |  | 0 |  | yes |
| `onLoad` | event | triggers.dart TriggerType.load |  |  | 0 (0) |  | 0 |  | yes |
| `onLongPress` | event | triggers.dart TriggerType.longPress |  |  | 22 (17) |  | 1 |  | yes |
| `onPinch` | event | triggers.dart TriggerType.pinch |  |  | 4 (4) |  | 0 |  | yes |
| `onPointerDown` | event | triggers.dart TriggerType.pointerDown |  |  | 0 (0) |  | 0 |  | yes |
| `onPointerUp` | event | triggers.dart TriggerType.pointerUp |  |  | 0 (0) |  | 0 |  | yes |
| `onRefresh` | event | triggers.dart TriggerType.refresh |  |  | 0 (0) |  | 0 |  | yes |
| `onReorder` | event | triggers.dart TriggerType.reorder |  |  | 15 (10) | 4 runs, 9 | 0 |  | yes |
| `onRightClick` | event | triggers.dart TriggerType.secondaryClick (notation_events.dart notationEventNames) |  |  | 2 (1) |  | 0 |  | yes |
| `onRowTap` | event | triggers.dart TriggerType.rowTap |  |  | 3 (3) |  | 0 | full | yes |
| `onScroll` | event | triggers.dart TriggerType.scroll |  |  | 3 (2) | 1 runs, 1 | 2 |  | yes |
| `onScrollEnd` | event | triggers.dart TriggerType.scrollEnd |  |  | 0 (0) |  | 0 |  | yes |
| `onSort` | event | triggers.dart TriggerType.sort |  |  | 13 (5) |  | 0 | full | yes |
| `onSubmit` | event | triggers.dart TriggerType.submitted (notation_events.dart notationEventNames) |  |  | 34 (23) |  q1 | 0 |  | yes |
| `onSwipeAction` | event | triggers.dart TriggerType.swipeAction |  |  | 0 (0) |  | 0 |  | yes |
| `onSwipeDown` | event | triggers.dart TriggerType.swipeDown |  |  | 3 (3) |  | 0 |  | yes |
| `onSwipeLeft` | event | triggers.dart TriggerType.swipeLeft |  |  | 24 (22) |  | 0 | open full | yes |
| `onSwipeRight` | event | triggers.dart TriggerType.swipeRight |  |  | 14 (14) |  | 0 |  | yes |
| `onSwipeUp` | event | triggers.dart TriggerType.swipeUp |  |  | 5 (4) |  q4 | 0 |  | yes |
| `onTap` | event | triggers.dart TriggerType.click (notation_events.dart notationEventNames) |  |  | 13333 (442) | 1 runs, 26 q256 | 86 | open full | yes |
| `onTimer` | event | triggers.dart TriggerType.timer |  |  | 1 (1) |  | 0 |  | yes |
| `onValueChanged` | event | triggers.dart TriggerType.valueChanged |  |  | 0 (0) |  | 0 |  | yes |
| `onWheel` | event | triggers.dart TriggerType.wheel |  |  | 1 (1) |  | 0 |  | yes |
| `abs` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 106 (54) |  q2 | 0 | open full | yes |
| `acos` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `addDays` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 24 (2) |  q2 | 0 |  | yes |
| `addHours` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `addMinutes` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `addMonths` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 1 (1) |  q2 | 0 |  | yes |
| `addSeconds` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `all` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 14 (10) |  | 0 | open full | yes |
| `alpha` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  q1 | 0 |  | yes |
| `any` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 100 (54) |  q1 | 0 | open full | yes |
| `append` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 1127 (341) |  q2 | 4 | open full | yes |
| `asin` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `at` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  q1 | 0 |  | yes |
| `atan` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `atan2` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `ceil` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 20 (12) |  | 1 | open full | yes |
| `charCode` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `clamp` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 108 (68) |  q1 | 0 | open full | yes |
| `coalesce` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 102 (57) |  q3 | 22 | open full | yes |
| `codeUnits` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `compact` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `concat` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 157 (78) |  q3 | 0 | open full | yes |
| `contains` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 951 (220) |  q6 | 16 | open full | yes |
| `cos` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  q3 | 0 |  | yes |
| `count` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 741 (228) |  q7 | 1 | open full | yes |
| `currency` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `currencyDecimals` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `currencySymbol` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `day` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `daysInMonth` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `degrees` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `diffDays` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `diffHours` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `diffMinutes` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `diffSeconds` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `distance` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 4 (3) |  | 0 |  | yes |
| `duration` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 286 (126) |  q4 | 0 | open full | yes |
| `endsWith` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `exp` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `feetInches` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `fill` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `filter` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 898 (281) |  q15 | 4 | open full | yes |
| `find` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 1028 (195) |  q8 | 1 | open full | yes |
| `findIndex` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 1 |  | yes |
| `first` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 126 (51) |  q3 | 1 | open full | yes |
| `fixed` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 370 (116) |  | 0 | open full | yes |
| `flatMap` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 4 (1) |  | 0 |  | yes |
| `flatten` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 6 (5) |  | 0 |  | yes |
| `floor` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 203 (58) |  q2 | 0 | open full | yes |
| `formatAmount` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `formatCurrency` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `formatDate` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 215 (114) |  q3 | 0 | open full | yes |
| `formatDuration` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 1 (1) |  q2 | 0 |  | yes |
| `formatNumber` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `formatPercent` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `formatRelative` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `fromCharCode` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `fuzzy` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 11 (4) |  | 0 | full | yes |
| `fuzzyScore` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `get` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 3 (1) |  q11 | 2 |  | yes |
| `groupBy` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 1 |  | yes |
| `hour` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 4 (1) |  | 0 |  | yes |
| `hypot` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `if` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `indexOf` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 111 (51) |  q1 | 0 | open full | yes |
| `insertAt` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `interpolate` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `isAfter` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `isBefore` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `isEmpty` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 207 (117) |  q2 | 0 | open full | yes |
| `isFuture` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `isNotEmpty` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `isPast` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `isSameDay` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `isToday` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `join` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 98 (59) |  | 0 | open full | yes |
| `keys` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 1 (1) |  | 0 |  | yes |
| `last` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 187 (56) |  q2 | 0 | open full | yes |
| `left` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `length` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 2075 (381) |  q26 | 30 | open full | yes |
| `lerpColor` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `ln` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `log` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `lower` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 605 (166) |  q15 | 8 | open full | yes |
| `luminance` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 2 (1) |  q5 | 0 |  | yes |
| `map` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 574 (211) |  q1 | 5 | open full | yes |
| `matchRanges` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `matchReason` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `matchRuns` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `matches` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 3 |  | yes |
| `max` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 492 (223) |  q2 | 5 | open full | yes |
| `maxBy` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `merge` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `min` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 307 (173) |  q2 | 4 | open full | yes |
| `minBy` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `minute` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `mix` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  q7 | 0 |  | yes |
| `money` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 562 (85) |  q4 | 2 | open full | yes |
| `month` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `move` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 8 (4) |  | 0 |  | yes |
| `moveItems` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `newId` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `now` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 5 (4) |  | 1 |  | yes |
| `nowMs` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `number` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `obj` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `object` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `pad` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `padLeft` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `padRight` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `parseAmount` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `parseDate` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `pi` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `pick` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `plural` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `pluralCategory` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `pow` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 2 (1) |  | 0 |  | yes |
| `prepend` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 1 (1) |  | 0 |  | yes |
| `radians` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `random` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 15 (8) |  | 0 |  | yes |
| `range` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 154 (73) |  | 0 | open full | yes |
| `regexReplace` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `removeAt` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 81 (53) |  q2 | 0 | open full | yes |
| `removeWhere` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 396 (224) |  | 0 | open full | yes |
| `replace` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 37 (12) |  q1 | 13 | open full | yes |
| `reverse` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 41 (35) |  | 1 | open full | yes |
| `right` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `round` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 305 (155) |  q1 | 3 | open full | yes |
| `runs` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `second` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `seconds` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `set` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 2 |  | yes |
| `setAt` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 127 (41) |  q1 | 2 | open full | yes |
| `sign` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `sin` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 2 (2) |  q5 | 0 |  | yes |
| `skip` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  q2 | 0 |  | yes |
| `slice` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 77 (48) |  | 3 | open full | yes |
| `slug` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `sortBy` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 178 (104) |  | 8 | open full | yes |
| `sortByDesc` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 100 (66) |  q1 | 0 | open full | yes |
| `split` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 5 (5) |  | 0 |  | yes |
| `sqrt` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 1 (1) |  q4 | 0 |  | yes |
| `startsWith` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 19 (11) |  | 7 | open full | yes |
| `substring` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 2 (1) |  | 0 |  | yes |
| `sum` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 813 (159) |  q1 | 0 | open full | yes |
| `take` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 78 (46) |  | 1 | open full | yes |
| `tan` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `text` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  q4 | 0 |  | yes |
| `textDirection` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `textDirectionOf` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `thousands` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `timeAgo` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `titleCase` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `toMap` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `today` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 153 (95) |  q1 | 1 | open full | yes |
| `trim` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 113 (51) |  q7 | 4 | open full | yes |
| `unique` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 44 (24) |  | 0 | open full | yes |
| `unset` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `updateWhere` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 820 (241) |  q1 | 0 | open full | yes |
| `upper` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 114 (52) |  q7 | 0 | open full | yes |
| `values` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `wallTime` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `weekday` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 1 |  | yes |
| `where` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `with` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 1372 (272) |  q12 | 0 | open full | yes |
| `without` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 312 (128) |  q1 | 4 | open full | yes |
| `year` | formula function | formula_names.dart notationFormulaFunctionNames |  |  | 0 (0) |  | 0 |  | yes |
| `component` | grammar statement | define.dart _statements |  |  | 0 (0) |  | 5 |  | yes |
| `computed` | grammar statement | define.dart _statements |  |  | 7 (1) |  | 0 |  | yes |
| `const` | grammar statement | define.dart _statements |  |  | 0 (0) |  | 0 |  |  |
| `define` | grammar statement | define.dart _statements |  |  | 458 (126) |  | 1 | open | yes |
| `derived` | grammar statement | define.dart _statements |  |  | 0 (0) |  | 0 |  |  |
| `document` | grammar statement | define.dart _statements |  |  | 0 (0) |  | 3 |  | yes |
| `each` | grammar statement | define.dart _statements |  |  | 2169 (431) |  q23 | 30 | open full | yes |
| `else` | grammar statement | define.dart _statements |  |  | 22 (13) |  q1 | 1 | open full | yes |
| `every` | grammar statement | define.dart _statements |  |  | 458 (260) |  | 3 | open full | yes |
| `for` | grammar statement | define.dart _statements |  |  | 0 (0) |  | 0 | open full | yes |
| `if` | grammar statement | define.dart _statements |  |  | 2548 (421) |  q19 | 1 | open full | yes |
| `key` | grammar statement | define.dart _statements |  |  | 0 (0) |  | 3 | open full | yes |
| `let` | grammar statement | define.dart _statements |  |  | 0 (0) |  | 0 | open full | yes |
| `node` | grammar statement | define.dart _statements |  |  | 0 (0) |  | 0 | open full | yes |
| `primitive` | grammar statement | define.dart _statements |  |  | 0 (0) |  | 0 | open | yes |
| `project` | grammar statement | define.dart _statements |  |  | 234 (33) |  | 1 | open full | yes |
| `state` | grammar statement | define.dart _statements |  |  | 9417 (442) |  | 144 | open full | yes |
| `var` | grammar statement | define.dart _statements |  |  | 0 (0) |  | 0 |  |  |
| `animate` | grammar word (universal table) | universal.dart notationUniversal | how it arrives or keeps moving |  | 416 (183) |  | 1 | open full | yes |
| `around` | grammar word (universal table) | universal.dart notationUniversal | spread with room around each |  | 1 (1) |  | 0 |  | yes |
| `between` | grammar word (universal table) | universal.dart notationUniversal | its ends apart |  | 2051 (421) |  q36 | 9 | open full | yes |
| `border` | grammar word (universal table) | universal.dart notationUniversal | a hairline round it |  | 163 (90) |  q20 | 16 | open full | yes |
| `border-bottom` | grammar word (universal table) | universal.dart notationUniversal | a hairline on that side |  | 158 (83) |  q13 | 6 | open full | yes |
| `border-left` | grammar word (universal table) | universal.dart notationUniversal | a hairline on that side |  | 25 (20) |  | 4 | open full | yes |
| `border-right` | grammar word (universal table) | universal.dart notationUniversal | a hairline on that side |  | 11 (6) |  q2 | 6 | open full | yes |
| `border-top` | grammar word (universal table) | universal.dart notationUniversal | a hairline on that side |  | 23 (21) |  q6 | 1 | open full | yes |
| `bottom` | grammar word (universal table) | universal.dart notationUniversal | at the bottom |  | 63 (48) |  | 0 | open full | yes |
| `center` | grammar word (universal table) | universal.dart notationUniversal | centred across |  | 1452 (322) |  q15 | 13 | open full | yes |
| `delay` | grammar word (universal table) | universal.dart notationUniversal | with animate: how long before |  | 18 (11) | 1 runs, 4 | 0 | open full | yes |
| `drag` | grammar word (universal table) | universal.dart notationUniversal | dragged, in a group, carrying a value |  | 176 (98) |  | 1 | open full | yes |
| `drop` | grammar word (universal table) | universal.dart notationUniversal | takes drops from those groups |  | 120 (83) |  | 1 | open full | yes |
| `duration` | grammar word (universal table) | universal.dart notationUniversal | with animate: how long |  | 77 (56) | 1 runs, 4 | 8 | open full | yes |
| `end` | grammar word (universal table) | universal.dart notationUniversal | at the end |  | 691 (303) | 3 runs, 5 | 7 | open full | yes |
| `evenly` | grammar word (universal table) | universal.dart notationUniversal | spread evenly |  | 0 (0) |  | 0 |  | yes |
| `fill` | grammar word (universal table) | universal.dart notationUniversal | its background colour (a bare fill: as wide as its place) |  | 1079 (298) | 1 runs, 2 q227 | 110 | open full | yes |
| `gap` | grammar word (universal table) | universal.dart notationUniversal | the room between what is in it |  | 12851 (442) | 1 runs, 2 q181 | 169 | open full | yes |
| `grow` | grammar word (universal table) | universal.dart notationUniversal | takes the room left along its row or column |  | 2819 (428) | 10 runs, 269 q56 | 29 | open full | yes |
| `h` | grammar word (universal table) | universal.dart notationUniversal | its height |  | 1583 (382) | 5 runs, 773 q147 | 412 | open full | yes |
| `height` | grammar word (universal table) | universal.dart notationUniversal | another name of h |  | 5 (5) |  | 3 | open full | yes |
| `hidden` | grammar word (universal table) | universal.dart notationUniversal | not shown (hidden={cond}: while it holds) |  | 272 (97) | 1 runs, 2 | 5 | open full | yes |
| `hide` | grammar word (universal table) | universal.dart notationUniversal | not shown at that size (hide=phone) |  | 163 (66) | 4 runs, 467 q47 | 10 | open full | yes |
| `id` | grammar word (universal table) | universal.dart notationUniversal | a name a scroll goes to |  | 67 (44) |  q1 | 2 | open full | yes |
| `left` | grammar word (universal table) | universal.dart notationUniversal | at the left |  | 93 (63) | 1 runs, 7 q5 | 0 | open full | yes |
| `maxw` | grammar word (universal table) | universal.dart notationUniversal | the widest it gets |  | 219 (141) | 1 runs, 22 q16 | 0 | open full | yes |
| `menu` | grammar word (universal table) | universal.dart notationUniversal | that Menu on a right click or a long press |  | 89 (78) |  | 0 | open full | yes |
| `middle` | grammar word (universal table) | universal.dart notationUniversal | centred down |  | 2367 (377) |  q61 | 5 | open full | yes |
| `onDoubleTap` | grammar word (universal table) | universal.dart notationUniversal | a double tap |  | 15 (8) |  | 0 |  | yes |
| `onDrop` | grammar word (universal table) | universal.dart notationUniversal | something dragged is dropped on it |  | 128 (85) |  | 1 | open full | yes |
| `onHover` | grammar word (universal table) | universal.dart notationUniversal | the pointer comes over it |  | 2 (2) |  | 0 | full | yes |
| `onLongPress` | grammar word (universal table) | universal.dart notationUniversal | a long press |  | 22 (17) |  | 1 |  | yes |
| `onRightClick` | grammar word (universal table) | universal.dart notationUniversal | a right click |  | 2 (1) |  | 0 |  | yes |
| `onSwipeDown` | grammar word (universal table) | universal.dart notationUniversal | a swipe |  | 3 (3) |  | 0 |  | yes |
| `onSwipeLeft` | grammar word (universal table) | universal.dart notationUniversal | a swipe |  | 24 (22) |  | 0 | open full | yes |
| `onSwipeRight` | grammar word (universal table) | universal.dart notationUniversal | a swipe |  | 14 (14) |  | 0 |  | yes |
| `onSwipeUp` | grammar word (universal table) | universal.dart notationUniversal | a swipe |  | 5 (4) |  q4 | 0 |  | yes |
| `onTap` | grammar word (universal table) | universal.dart notationUniversal | a tap or click (Enter or Space when focused) |  | 13333 (442) | 1 runs, 26 q256 | 86 | open full | yes |
| `pad` | grammar word (universal table) | universal.dart notationUniversal | the room inside its edge |  | 2181 (441) |  q76 | 112 | open full | yes |
| `padding` | grammar word (universal table) | universal.dart notationUniversal | another name of pad |  | 0 (0) |  | 0 | open full | yes |
| `preview` | grammar word (universal table) | universal.dart notationUniversal | that Popover as a hover card |  | 4 (3) |  | 0 | full | yes |
| `radius` | grammar word (universal table) | universal.dart notationUniversal | its corners |  | 878 (280) | 1 runs, 11 q83 | 69 | open full | yes |
| `right` | grammar word (universal table) | universal.dart notationUniversal | at the right |  | 71 (43) | 1 runs, 7 | 1 | open full | yes |
| `scroll` | grammar word (universal table) | universal.dart notationUniversal | scrolls what is in it |  | 705 (303) | 3 runs, 3 q8 | 23 | open full | yes |
| `selected` | grammar word (universal table) | universal.dart notationUniversal | its selected state: the theme's selected look, announced selected |  | 2796 (414) | 2 runs, 11 q91 | 26 | open full | yes |
| `show` | grammar word (universal table) | universal.dart notationUniversal | shown only at that size (show=phone) |  | 44 (20) | 4 runs, 85 q19 | 0 | open full | yes |
| `stagger` | grammar word (universal table) | universal.dart notationUniversal | with animate under an each: each copy that much later |  | 51 (42) |  | 0 | open full | yes |
| `start` | grammar word (universal table) | universal.dart notationUniversal | at the start |  | 35 (28) | 1 runs, 2 q1 | 0 | open full | yes |
| `sticky` | grammar word (universal table) | universal.dart notationUniversal | stays in view while the page scrolls under it |  | 69 (48) | 6 runs, 329 | 3 | open full | yes |
| `stretch` | grammar word (universal table) | universal.dart notationUniversal | what is in it as wide as it |  | 7 (6) |  q1 | 10 | open full | yes |
| `tooltip` | grammar word (universal table) | universal.dart notationUniversal | shown on hover, focus or a touch hold; names an icon-only button |  | 1458 (370) | 1 runs, 3 q57 | 2 | open full | yes |
| `top` | grammar word (universal table) | universal.dart notationUniversal | at the top |  | 437 (258) |  | 0 | open full | yes |
| `visible` | grammar word (universal table) | universal.dart notationUniversal | shown while it holds |  | 390 (95) | 2 runs, 83 q12 | 24 | open full | yes |
| `w` | grammar word (universal table) | universal.dart notationUniversal | its width: a number, fill or hug |  | 2942 (401) | 4 runs, 831 q120 | 369 | open full | yes |
| `width` | grammar word (universal table) | universal.dart notationUniversal | another name of w |  | 12 (9) |  | 0 | open full | yes |
| `Accordion` | node type | catalog core (accordion) |  |  | 41 (20) |  | 0 | open full | yes |
| `ActionChip` | node type | catalog core (actionChip) |  |  | 0 (0) |  | 0 |  | yes |
| `ActivityIndicator` | node type | catalog core (activityIndicator) |  |  | 0 (0) |  | 0 |  | yes |
| `AppBar` | node type | catalog core (appBar) |  |  | 0 (0) |  | 0 |  | yes |
| `AudioPlayer` | node type | catalog feature library (audioPlayer) |  |  | 1 (1) |  q1 | 0 |  | yes |
| `Badge` | node type | catalog core (badge) |  |  | 1754 (383) |  | 1 | open full | yes |
| `BarChart` | node type | catalog core (barChart) |  |  | 117 (100) |  | 1 | open full | yes |
| `Barcode` | node type | catalog core (barcode) |  |  | 12 (9) |  | 0 |  | yes |
| `BottomNavigationBar` | node type | catalog core (bottomNavigationBar) |  |  | 0 (0) |  | 0 |  | yes |
| `Box` | node type | catalog core (box) |  |  | 623 (227) |  q4 | 1 | open full | yes |
| `Calendar` | node type | catalog core (calendar) |  |  | 12 (11) |  q1 | 0 | open full | yes |
| `Canvas` | node type | catalog core (canvas) |  |  | 7 (5) |  | 5 |  | yes |
| `Chart` | node type | catalog core (chart) |  |  | 0 (0) |  | 1 |  | yes |
| `Checkbox` | node type | catalog core (checkbox) |  |  | 152 (98) |  | 4 | open full | yes |
| `Chip` | node type | catalog core (chip) |  |  | 231 (118) |  q1 | 4 | open full | yes |
| `ChoiceChip` | node type | catalog core (choiceChip) |  |  | 595 (166) |  q4 | 0 | open full | yes |
| `CircularProgressIndicator` | node type | catalog core (circularProgressIndicator) |  |  | 0 (0) |  | 1 |  | yes |
| `Column` | node type | catalog core (column) |  |  | 3434 (442) |  q79 | 170 | open full | yes |
| `DatePicker` | node type | catalog core (datePicker) |  |  | 75 (57) |  q2 | 0 | open full | yes |
| `DateTimeInput` | node type | catalog core (dateTimeInput) |  |  | 0 (0) |  | 0 |  | yes |
| `Divider` | node type | catalog core (divider) |  |  | 397 (213) |  q13 | 2 | open full | yes |
| `Dropdown` | node type | catalog core (dropdown) |  |  | 0 (0) |  | 0 |  | yes |
| `ElevatedButton` | node type | catalog core (elevatedButton) |  |  | 0 (0) |  | 0 |  | yes |
| `EmbeddedVideo` | node type | catalog feature library (embeddedVideo) |  |  | 0 (0) |  | 0 |  | yes |
| `ExpansionTile` | node type | catalog core (expansionTile) |  |  | 0 (0) |  | 0 |  | yes |
| `External` | node type | catalog core (external) |  |  | 0 (0) |  | 0 |  | yes |
| `FilledButton` | node type | catalog core (filledButton) |  |  | 0 (0) |  | 0 |  | yes |
| `FilterChip` | node type | catalog core (filterChip) |  |  | 185 (67) |  | 0 | open full | yes |
| `Flex` | node type | catalog core (flex) |  |  | 0 (0) |  | 4 |  | yes |
| `FloatingActionButton` | node type | catalog core (floatingActionButton) |  |  | 0 (0) |  | 0 |  | yes |
| `GaugeMeter` | node type | catalog core (gaugeMeter) |  |  | 0 (0) |  | 0 |  | yes |
| `GridView` | node type | catalog core (gridView) |  |  | 1 (1) |  | 0 | open full | yes |
| `Icon` | node type | catalog core (icon) |  |  | 972 (327) |  q68 | 24 | open full | yes |
| `IconButton` | node type | catalog core (iconButton) |  |  | 1629 (388) |  q46 | 3 | open full | yes |
| `InputChip` | node type | catalog core (inputChip) |  |  | 0 (0) |  | 0 |  | yes |
| `LineChart` | node type | catalog core (lineChart) |  |  | 82 (61) |  q1 | 1 | open full | yes |
| `ListTile` | node type | catalog core (listTile) |  |  | 410 (243) |  | 1 | open full | yes |
| `ListView` | node type | catalog core (listView) |  |  | 14 (11) |  | 17 | open full | yes |
| `Modal` | node type | catalog core (modal) |  |  | 0 (0) |  | 0 |  | yes |
| `NavigationBar` | node type | catalog core (navigationBar) |  |  | 0 (0) |  | 0 |  | yes |
| `OutlinedButton` | node type | catalog core (outlinedButton) |  |  | 0 (0) |  | 0 |  | yes |
| `PageView` | node type | catalog core (pageView) |  |  | 0 (0) |  | 0 |  | yes |
| `Pagination` | node type | catalog core (pagination) |  |  | 0 (0) |  | 0 |  | yes |
| `Path` | node type | catalog core (path) |  |  | 2 (2) |  | 1 |  | yes |
| `Placeholder` | node type | catalog core (placeholder) |  |  | 0 (0) |  | 0 |  | yes |
| `PlotChart` | node type | catalog core (plotChart) |  |  | 0 (0) |  | 0 |  | yes |
| `ProgressBar` | node type | catalog core (progressBar) |  |  | 2 (2) |  | 0 |  |  |
| `RadialGauge` | node type | catalog core (radialGauge) |  |  | 0 (0) |  | 1 |  | yes |
| `Radio` | node type | catalog core (radio) |  |  | 44 (19) |  | 2 | open full | yes |
| `Row` | node type | catalog core (row) |  |  | 7837 (442) |  q140 | 87 | open full | yes |
| `SegmentedButton` | node type | catalog core (segmentedButton) |  |  | 417 (279) |  q2 | 2 | open full | yes |
| `Signature` | node type | catalog core (signature) |  |  | 0 (0) |  | 0 |  | yes |
| `SinglePlaceholder` | node type | catalog core (singlePlaceholder) |  |  | 0 (0) |  | 0 |  | yes |
| `Slider` | node type | catalog core (slider) |  |  | 386 (180) |  q7 | 4 | open full | yes |
| `Slot` | node type | catalog core (slot) |  |  | 0 (0) |  | 4 |  | yes |
| `Spacer` | node type | catalog core (spacer) |  |  | 911 (393) |  q8 | 1 | open full | yes |
| `Splitter` | node type | catalog core (splitter) |  |  | 4 (3) |  | 4 | full | yes |
| `Stack` | node type | catalog core (stack) |  |  | 204 (144) |  q2 | 4 | open full | yes |
| `Switch` | node type | catalog core (switch) |  |  | 10 (6) |  | 0 |  | yes |
| `TabBar` | node type | catalog core (tabBar) |  |  | 1 (1) |  | 0 |  | yes |
| `TableView` | node type | catalog core (tableView) |  |  | 0 (0) |  | 1 |  | yes |
| `Tabs` | node type | catalog core (tabs) |  |  | 10 (5) |  | 0 |  | yes |
| `Text` | node type | catalog core (text) |  |  | 14169 (442) |  q367 | 223 | open full | yes |
| `TextButton` | node type | catalog core (textButton) |  |  | 0 (0) |  | 0 |  | yes |
| `TextField` | node type | catalog core (textField) |  |  | 0 (0) |  | 0 |  | yes |
| `TimePicker` | node type | catalog core (timePicker) |  |  | 75 (47) |  | 0 | open full | yes |
| `Variance` | node type | catalog core (variance) |  |  | 0 (0) |  | 1 |  | yes |
| `VerticalDivider` | node type | catalog core (verticalDivider) |  |  | 0 (0) |  | 0 |  | yes |
| `Video` | node type | catalog feature library (video) |  |  | 3 (3) |  | 1 |  | yes |
| `WebView` | node type | catalog feature library (webView) |  |  | 0 (0) |  | 0 |  | yes |
| `actions` | property | keys.dart notationKeyNames (1 types) |  |  | 1 (1) |  | 0 | open full | yes |
| `activeColor` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) | 1 runs, 2 | 0 |  | yes |
| `activeSide` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `activeTextColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `activeThumbBorderColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `activeThumbColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `activeTickMarkColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `activeTrackColor` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `activeTrackOutlineColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `align` | property | keys.dart notationKeyNames (70 types) |  |  | 13 (4) |  | 1 |  | yes |
| `alignment` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `allowImplicitScrolling` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `allowedTypes` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `allowsInlineMediaPlayback` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `alwaysScroll` | property | keys.dart notationKeyNames (7 types) |  |  | 0 (0) |  | 0 |  | yes |
| `alwaysUse24HourFormat` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `animate` | property | keys.dart notationKeyNames (7 types) |  |  | 416 (183) |  | 1 | open full | yes |
| `animateIn` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `animating` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `animationCurve` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `animationDuration` | property | keys.dart notationKeyNames (8 types) |  |  | 0 (0) |  | 0 |  | yes |
| `animations` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `arcFit` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `arcGlow` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `arcHeadDot` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `arcRoundCaps` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `arcStartAngle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `arcStrokeWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `arcSweepAngle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `areaBands` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `areaBottomColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `areaTopColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `aspectRatio` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) | 1 runs, 2 | 0 |  | yes |
| `autoPlay` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `autocorrect` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `autofillHints` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `autofocus` | property | keys.dart notationKeyNames (18 types) |  |  | 34 (17) |  q1 | 0 |  | yes |
| `automaticallyImplyLeading` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `autovalidateMode` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 2 |  | yes |
| `avatar` | property | keys.dart notationKeyNames (5 types) |  |  | 0 (0) |  | 0 |  | yes |
| `avatarColor` | property | keys.dart notationKeyNames (5 types) |  |  | 0 (0) |  | 0 |  | yes |
| `avatarSize` | property | keys.dart notationKeyNames (5 types) |  |  | 0 (0) |  | 0 |  | yes |
| `axisArrows` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `axisColor` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `axisFontFamily` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `axisFontSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `axisLabelColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `axisLabelStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `axisTitleStyle` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `axisWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `backdrop` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `background` | property | keys.dart notationKeyNames (1 types) |  |  | 1 (1) |  q1 | 0 | open full | yes |
| `backgroundColor` | property | keys.dart notationKeyNames (26 types) |  |  | 0 (0) |  | 1 |  | yes |
| `bands` | property | keys.dart notationKeyNames (2 types) |  |  | 6 (5) |  | 0 | open full | yes |
| `barGap` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `barHeadroom` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `barRadius` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `barWidthFraction` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `bare` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 | open full | yes |
| `baselineColor` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `basis` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 3 |  | yes |
| `blendMode` | property | keys.dart notationKeyNames (11 types) |  |  | 0 (0) |  | 0 |  | yes |
| `blockBack` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `borderColor` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `borderRadius` | property | keys.dart notationKeyNames (5 types) |  |  | 0 (0) |  | 1 |  | yes |
| `borderWidth` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `boundaryCount` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `breakpoint` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 2 |  | yes |
| `breakpointMinWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `builderId` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `buttonColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `buttonSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `cacheExtent` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `caption` | property | keys.dart notationKeyNames (1 types) |  |  | 9 (4) | 1 runs, 15 q1 | 0 | open full | yes |
| `captionAlign` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `captionGap` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `captionLanguage` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `captionStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `centerTitle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `chartType` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `checkColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `checkmarkColor` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `childAspectRatio` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) | 1 runs, 4 | 0 |  | yes |
| `childrenPadding` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `clip` | property | keys.dart notationKeyNames (13 types) |  |  | 9 (9) | 1 runs, 2 q2 | 5 |  | yes |
| `clipBehavior` | property | keys.dart notationKeyNames (8 types) |  |  | 0 (0) |  | 0 |  | yes |
| `clipFill` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `collapseAt` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `collapsedBackgroundColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `collapsedIconColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `collapsedShape` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `collapsedTextColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `color` | property | keys.dart notationKeyNames (25 types) |  |  | 1471 (298) | 15 runs, 226 q302 | 104 | open full | yes |
| `colorByZone` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `colors` | property | keys.dart notationKeyNames (1 types) |  |  | 23 (12) |  | 0 | open full | yes |
| `columnSpan` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 2 |  | yes |
| `columnStart` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 1 |  | yes |
| `columnWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `columns` | property | keys.dart notationKeyNames (1 types) |  |  | 31 (16) |  q1 | 3 | open full | yes |
| `compact` | property | keys.dart notationKeyNames (2 types) |  |  | 5 (4) | 1 runs, 1 | 2 | open full | yes |
| `constraints` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `content` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 | open full | yes |
| `contentPadding` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `controlAffinity` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `controlled` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `controller` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `cornerRadius` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `count` | property | keys.dart notationKeyNames (1 types) |  |  | 77 (53) | 1 runs, 4 q45 | 7 | open full | yes |
| `crossAxisAlignment` | property | keys.dart notationKeyNames (4 types) |  |  | 0 (0) |  q1 | 57 |  | yes |
| `crossAxisCount` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 4 |  | yes |
| `crossAxisSpacing` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) | 4 runs, 14 | 4 |  | yes |
| `current` | property | keys.dart notationKeyNames (1 types) |  |  | 86 (53) | 1 runs, 146 q7 | 1 |  | yes |
| `cursorColor` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `cursorHeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `cursorRadius` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `cursorRingFill` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `cursorWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `customPaint` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `dashEmpty` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `dashPattern` | property | keys.dart notationKeyNames (11 types) |  |  | 0 (0) |  q2 | 1 |  | yes |
| `data` | property | keys.dart notationKeyNames (4 types) |  |  | 4 (4) |  | 5 | open full | yes |
| `dayPrices` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `decoration` | property | keys.dart notationKeyNames (16 types) |  |  | 0 (0) |  q1 | 1 | full | yes |
| `decorationColor` | property | keys.dart notationKeyNames (16 types) |  |  | 0 (0) |  | 0 |  | yes |
| `decorationStyle` | property | keys.dart notationKeyNames (16 types) |  |  | 0 (0) |  | 0 |  | yes |
| `decorationThickness` | property | keys.dart notationKeyNames (16 types) |  |  | 0 (0) |  | 0 |  | yes |
| `defaultTextStyle` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `deleteIcon` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `deleteIconColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `deleteIconSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `deniedTypes` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `dense` | property | keys.dart notationKeyNames (1 types) |  |  | 3 (1) |  | 0 |  | yes |
| `description` | property | keys.dart notationKeyNames (1 types) |  |  | 10 (2) | 1 runs, 33 q2 | 0 |  | yes |
| `destinations` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `dimUnselected` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `dimmedOpacity` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `direction` | property | keys.dart notationKeyNames (3 types) |  |  | 7 (6) |  q5 | 8 |  | yes |
| `disabledDates` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 | full | yes |
| `disabledOpacity` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `dismissible` | property | keys.dart notationKeyNames (70 types) |  |  | 2 (2) |  | 0 |  | yes |
| `displayText` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `dividerColor` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `dividerEndIndent` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `dividerHeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `dividerIndent` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `dividerThickness` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `divisions` | property | keys.dart notationKeyNames (2 types) |  |  | 2 (1) |  q2 | 0 |  | yes |
| `domainMax` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `domainMin` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `donutThickness` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `dragEdgeScroll` | property | keys.dart notationKeyNames (6 types) |  |  | 0 (0) |  | 0 |  | yes |
| `draggable` | property | keys.dart notationKeyNames (70 types) |  |  | 13 (11) |  | 0 |  | yes |
| `drawText` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `dropTarget` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `dropdownColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `edgeColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `edgeFade` | property | keys.dart notationKeyNames (5 types) |  |  | 0 (0) |  | 0 |  | yes |
| `edgeWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `effects` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) | 1 runs, 3 | 2 |  | yes |
| `elevation` | property | keys.dart notationKeyNames (10 types) |  |  | 0 (0) |  | 0 |  | yes |
| `embed` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `emptyColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `emptyHeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `emptySelectionAllowed` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `enableFeedback` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `enableInteractiveSelection` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `enabled` | property | keys.dart notationKeyNames (16 types) |  |  | 3 (2) | 3 runs, 31 | 5 |  | yes |
| `end` | property | keys.dart notationKeyNames (1 types) |  |  | 691 (303) | 3 runs, 5 | 7 | open full | yes |
| `endAt` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `endDotRadius` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `endField` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `endIndent` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `endLabelDecimals` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `endLabelWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `ephemeral` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `error` | property | keys.dart notationKeyNames (1 types) |  |  | 9 (4) |  | 0 | open full | yes |
| `errorBorderColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `errorBorderWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `errorCorrection` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `exactFill` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `expanded` | property | keys.dart notationKeyNames (2 types) |  |  | 15 (7) |  | 0 | open full | yes |
| `expandedAlignment` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `expandedCrossAxisAlignment` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `expands` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `extendedIconLabelSpacing` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `extendedPadding` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `extendedTextStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `fillColor` | property | keys.dart notationKeyNames (2 types) |  |  | 2 (2) |  q1 | 0 |  | yes |
| `fillFromEnd` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `fillGaps` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `fillStartOpacity` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `fillTrack` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `fillViewport` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `fillWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `fills` | property | keys.dart notationKeyNames (11 types) |  |  | 1 (1) |  | 21 | open full | yes |
| `firstDate` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `firstLabel` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `fit` | property | keys.dart notationKeyNames (2 types) |  |  | 4 (3) |  q39 | 3 | open full | yes |
| `fitAlignment` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `fitMinY` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `flex` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `flip` | property | keys.dart notationKeyNames (70 types) |  |  | 3 (1) |  | 0 |  | yes |
| `floating` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `focusColor` | property | keys.dart notationKeyNames (6 types) |  |  | 0 (0) |  | 0 |  | yes |
| `focusElevation` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `focusGroup` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) | 1 runs, 1 | 0 |  | yes |
| `focusRingColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `focusRingWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `focusable` | property | keys.dart notationKeyNames (70 types) |  |  | 16 (2) |  | 1 |  | yes |
| `fontFamily` | property | keys.dart notationKeyNames (16 types) |  |  | 3 (2) |  q9 | 0 |  | yes |
| `fontFeatures` | property | keys.dart notationKeyNames (16 types) |  |  | 0 (0) |  | 0 |  | yes |
| `fontSize` | property | keys.dart notationKeyNames (17 types) |  |  | 7 (5) |  | 0 |  | yes |
| `fontStyle` | property | keys.dart notationKeyNames (16 types) |  |  | 0 (0) |  | 0 |  | yes |
| `fontWeight` | property | keys.dart notationKeyNames (17 types) |  |  | 0 (0) |  | 0 |  | yes |
| `foreground` | property | keys.dart notationKeyNames (16 types) |  |  | 0 (0) |  | 0 |  | yes |
| `foregroundColor` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  q2 | 1 |  | yes |
| `foregroundFills` | property | keys.dart notationKeyNames (11 types) |  |  | 0 (0) |  | 0 |  | yes |
| `form` | property | keys.dart notationKeyNames (70 types) |  |  | 4 (2) | 1 runs, 4 q1 | 3 | open full | yes |
| `format` | property | keys.dart notationKeyNames (3 types) |  |  | 40 (21) |  | 0 |  | yes |
| `from` | property | keys.dart notationKeyNames (16 types) |  |  | 102 (48) |  | 11 | open full | yes |
| `gap` | property | keys.dart notationKeyNames (15 types) |  |  | 12851 (442) | 1 runs, 2 q181 | 169 | open full | yes |
| `gestures` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `gridAnchor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `gridColor` | property | keys.dart notationKeyNames (4 types) |  |  | 0 (0) |  | 0 |  | yes |
| `gridLabelColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `gridLabelFontSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `gridLabelFontWeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `gridLabelWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `gridLabels` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `gridLabelsLeft` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `gridLineColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `gridLineMode` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `gridLineWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `gridLines` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 1 |  | yes |
| `gridStepX` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `gridStepY` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `groupValue` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 2 |  | yes |
| `grow` | property | keys.dart notationKeyNames (70 types) |  |  | 2819 (428) | 10 runs, 269 q56 | 29 | open full | yes |
| `h` | property | keys.dart notationKeyNames (70 types) |  |  | 1583 (382) | 5 runs, 773 q147 | 412 | open full | yes |
| `headerBorderColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `headerBorderWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `headerColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `headerHeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `height` | property | keys.dart notationKeyNames (70 types) |  |  | 5 (5) |  | 3 | open full | yes |
| `heightFactor` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `helpText` | property | keys.dart notationKeyNames (2 types) |  |  | 1 (1) |  | 0 |  | yes |
| `hero` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `highlight` | property | keys.dart notationKeyNames (1 types) |  |  | 14 (12) | 1 runs, 1 | 0 |  | yes |
| `highlightColor` | property | keys.dart notationKeyNames (1 types) |  |  | 5 (3) |  | 0 |  | yes |
| `highlightElevation` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `highlightIndex` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `highlightLabelColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `highlightLabels` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `hint` | property | keys.dart notationKeyNames (2 types) |  |  | 46 (26) |  | 5 | open full | yes |
| `hintStyle` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `horizontalPadding` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `horizontalTitleGap` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `hoverColor` | property | keys.dart notationKeyNames (6 types) |  |  | 0 (0) |  | 0 |  | yes |
| `hoverElevation` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `icon` | property | keys.dart notationKeyNames (9 types) |  |  | 7960 (439) | 1 runs, 11 q133 | 14 | open full | yes |
| `iconAlignment` | property | keys.dart notationKeyNames (4 types) |  |  | 0 (0) |  | 0 |  | yes |
| `iconColor` | property | keys.dart notationKeyNames (4 types) |  |  | 0 (0) |  | 0 |  | yes |
| `iconDirection` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `iconDisabledColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `iconEnabledColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `iconSize` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `ignorePointer` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `inactiveColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) | 1 runs, 2 | 0 |  | yes |
| `inactiveThumbBorderColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `inactiveThumbColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `inactiveTickMarkColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `inactiveTrackColor` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `inactiveTrackOutlineColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `indent` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `indicatorColor` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `indicatorPadding` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `indicatorRadius` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `indicatorShape` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `indicatorSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `indicatorStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `indicatorWeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `initialIndex` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `initialPage` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `initialValue` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 7 |  | yes |
| `initiallyExpanded` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `inkColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `inkWell` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `inkWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `innerRadius` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `inputFormatter` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `inset` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `inverted` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `isDense` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `isEnabled` | property | keys.dart notationKeyNames (4 types) |  |  | 0 (0) |  | 0 |  | yes |
| `isExpanded` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `isLabelVisible` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `isScrollable` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `isThreeLine` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `itemAlignment` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `itemCount` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `itemExtent` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `itemImage` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `itemImageRadius` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `itemImageSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `itemLabel` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `itemPosition` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `itemSnapping` | property | keys.dart notationKeyNames (6 types) |  |  | 0 (0) |  | 1 |  | yes |
| `items` | property | keys.dart notationKeyNames (1 types) |  |  | 1273 (391) | 1 runs, 2 q6 | 6 | open full | yes |
| `keepPage` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `keyboardDecimal` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `keyboardDismissBehavior` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `keyboardSigned` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `keyboardType` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 7 |  | yes |
| `label` | property | keys.dart notationKeyNames (17 types) |  |  | 105 (53) | 2 runs, 181 q21 | 9 | open full | yes |
| `labelAreaHeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelBackground` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelBehavior` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelColor` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelField` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelFontFamily` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 1 |  | yes |
| `labelFontSize` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelFontWeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelFractionDigits` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelGap` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelHeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelInset` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelLetterSpacing` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelMargin` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelPadding` | property | keys.dart notationKeyNames (6 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelStyle` | property | keys.dart notationKeyNames (7 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelText` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelTextStyle` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labelTicks` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `labels` | property | keys.dart notationKeyNames (2 types) |  |  | 295 (164) | 2 runs, 4 q2 | 5 | open full | yes |
| `landscapeLayout` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `largeSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `lastDate` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `lastLabel` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `layout` | property | keys.dart notationKeyNames (1 types) |  |  | 10 (6) |  | 0 | open | yes |
| `leading` | property | keys.dart notationKeyNames (1 types) |  |  | 27 (19) |  | 4 |  | yes |
| `leadingAsset` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `leadingDistribution` | property | keys.dart notationKeyNames (16 types) |  |  | 0 (0) |  | 0 |  | yes |
| `leadingWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `letterSpacing` | property | keys.dart notationKeyNames (16 types) |  |  | 3 (1) |  q32 | 4 |  | yes |
| `limit` | property | keys.dart notationKeyNames (1 types) |  |  | 65 (40) |  | 1 | open full | yes |
| `limitColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `limitPointer` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `limitStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `limitWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `lineColor` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 1 |  | yes |
| `lineEndX` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `lineWidth` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `live` | property | keys.dart notationKeyNames (1 types) |  |  | 26 (17) | 1 runs, 1 q1 | 0 | full | yes |
| `loading` | property | keys.dart notationKeyNames (5 types) |  |  | 3 (1) |  | 0 |  | yes |
| `location` | property | keys.dart notationKeyNames (1 types) |  |  | 1 (1) | 1 runs, 6 | 0 |  | yes |
| `loop` | property | keys.dart notationKeyNames (3 types) |  |  | 9 (8) |  q1 | 0 |  | yes |
| `mainAxisAlignment` | property | keys.dart notationKeyNames (4 types) |  |  | 0 (0) |  | 0 |  | yes |
| `mainAxisExtent` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) | 2 runs, 5 | 2 |  | yes |
| `mainAxisSpacing` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) | 4 runs, 14 | 3 |  | yes |
| `maintainState` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `majorTickEvery` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `majorTicks` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `margin` | property | keys.dart notationKeyNames (70 types) |  |  | 1 (1) | 1 runs, 3 | 2 | open full | yes |
| `markdown` | property | keys.dart notationKeyNames (2 types) |  |  | 2 (1) |  | 0 |  | yes |
| `markerHollow` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `markerHollowColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `markerLabelStyle` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `markerRadius` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `markers` | property | keys.dart notationKeyNames (2 types) |  |  | 16 (11) |  | 0 |  | yes |
| `marks` | property | keys.dart notationKeyNames (1 types) |  |  | 52 (23) |  q1 | 0 | full | yes |
| `masonry` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) | 1 runs, 1 | 0 |  | yes |
| `masonryPlacement` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) | 1 runs, 1 | 0 |  | yes |
| `max` | property | keys.dart notationKeyNames (8 types) |  |  | 593 (232) | 3 runs, 7 q9 | 12 | open full | yes |
| `maxAllowedSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `maxBarWidth` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `maxCount` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `maxCrossAxisExtent` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `maxHeight` | property | keys.dart notationKeyNames (70 types) |  |  | 2 (2) |  | 0 |  | yes |
| `maxLength` | property | keys.dart notationKeyNames (1 types) |  |  | 6 (5) |  | 0 |  | yes |
| `maxLines` | property | keys.dart notationKeyNames (2 types) |  |  | 5 (3) |  q6 | 12 |  | yes |
| `maxWidth` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  q3 | 17 |  | yes |
| `maxY` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `measure` | property | keys.dart notationKeyNames (70 types) |  |  | 8 (3) | 1 runs, 2 | 0 |  | yes |
| `mediaPlaybackRequiresUserAction` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `menuStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `metadata` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `min` | property | keys.dart notationKeyNames (6 types) |  |  | 533 (219) | 3 runs, 7 q10 | 11 | open full | yes |
| `minCrossAxisExtent` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `minHeight` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 2 |  | yes |
| `minLeadingWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `minLines` | property | keys.dart notationKeyNames (1 types) |  |  | 2 (1) |  | 2 |  | yes |
| `minTileHeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `minVerticalPadding` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `minWidth` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `minWidths` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `minY` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `minorDivisions` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `minorGridColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `minorTicks` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `mode` | property | keys.dart notationKeyNames (1 types) |  |  | 87 (41) | 1 runs, 10 q3 | 0 |  | yes |
| `motion` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 | full | yes |
| `multiSelectionEnabled` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `mute` | property | keys.dart notationKeyNames (1 types) |  |  | 2 (2) |  | 0 |  | yes |
| `name` | property | keys.dart notationKeyNames (1 types) |  |  | 88 (53) | 2 runs, 78 q9 | 6 | open full | yes |
| `needleClearance` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `needleColor` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `nextLabel` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `normalized` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `notchEvery` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `notchMargin` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `notched` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `nowColor` | property | keys.dart notationKeyNames (1 types) |  |  | 2 (1) |  | 0 |  | yes |
| `nowValue` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `obscureText` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `obscuringCharacter` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `offset` | property | keys.dart notationKeyNames (1 types) |  |  | 8 (6) |  q4 | 1 |  | yes |
| `opacity` | property | keys.dart notationKeyNames (70 types) |  |  | 14 (8) |  q8 | 10 |  | yes |
| `order` | property | keys.dart notationKeyNames (70 types) |  |  | 15 (9) |  | 1 | open full | yes |
| `orientation` | property | keys.dart notationKeyNames (2 types) |  |  | 10 (6) |  | 0 | full | yes |
| `originAxes` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `otpDigitsOnly` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `otpLength` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `overflow` | property | keys.dart notationKeyNames (1 types) |  |  | 1 (1) |  q4 | 5 |  | yes |
| `overlap` | property | keys.dart notationKeyNames (1 types) |  |  | 6 (3) |  | 0 |  | yes |
| `overlay` | property | keys.dart notationKeyNames (1 types) |  |  | 3 (2) |  | 0 |  | yes |
| `overlayColor` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `overlayRadius` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `pad` | property | keys.dart notationKeyNames (70 types) |  |  | 2181 (441) |  q76 | 112 | open full | yes |
| `padEnds` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `padding` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 | open full | yes |
| `pageMotion` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `pageMotionBefore` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `pageSizeLabel` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `pageSnapping` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `pagination` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 | open full | yes |
| `paintOrder` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `pan` | property | keys.dart notationKeyNames (70 types) |  |  | 8 (6) |  | 0 |  | yes |
| `pane` | property | keys.dart notationKeyNames (1 types) |  |  | 2 (2) |  | 2 | open full | yes |
| `particles` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `physics` | property | keys.dart notationKeyNames (8 types) |  |  | 0 (0) |  | 6 |  | yes |
| `picker` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 | open full | yes |
| `pickerTheme` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `pinHeaderColumn` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `pinHeaderRow` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `placeholder` | property | keys.dart notationKeyNames (1 types) |  |  | 2 (2) |  | 0 |  | yes |
| `placeholderAlignment` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `placeholderColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `placeholderFontSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `placeholderFontWeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `placeholderLetterSpacing` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `placeholderOffset` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `placeholderPosition` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `placeholderStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `playing` | property | keys.dart notationKeyNames (3 types) |  |  | 109 (43) |  q2 | 0 |  | yes |
| `plotInset` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `plotPadding` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `plotTopInset` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `points` | property | keys.dart notationKeyNames (1 types) |  |  | 43 (22) |  | 0 | full | yes |
| `positionSeconds` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  q1 | 0 |  | yes |
| `poster` | property | keys.dart notationKeyNames (1 types) |  |  | 1 (1) |  | 0 |  | yes |
| `previousLabel` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `primary` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 | open full | yes |
| `progressEndColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `pullToRefresh` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `query` | property | keys.dart notationKeyNames (2 types) |  |  | 18 (15) | 2 runs, 6 | 1 | full | yes |
| `radioGroup` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `radius` | property | keys.dart notationKeyNames (13 types) |  |  | 878 (280) | 1 runs, 11 q83 | 69 | open full | yes |
| `range` | property | keys.dart notationKeyNames (1 types) |  |  | 52 (46) |  q1 | 0 | open full | yes |
| `rangeEnd` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `ranges` | property | keys.dart notationKeyNames (1 types) |  |  | 2 (1) |  | 0 |  | yes |
| `readOnly` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 2 |  | yes |
| `referenceColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `referenceDashed` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `referenceLines` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `referenceWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `referenceX` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `reorder` | property | keys.dart notationKeyNames (2 types) |  |  | 7 (4) | 4 runs, 9 | 2 | full | yes |
| `reorderHandle` | property | keys.dart notationKeyNames (70 types) |  |  | 1 (1) |  | 1 |  | yes |
| `reportIntervalMs` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `reveal` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) | 1 runs, 1 | 0 |  | yes |
| `reverse` | property | keys.dart notationKeyNames (7 types) |  |  | 0 (0) |  | 0 | open full | yes |
| `reversePaintOrder` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `roundCaps` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `rowCount` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `rowHeaderWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `rowHeight` | property | keys.dart notationKeyNames (1 types) |  |  | 2 (2) |  | 1 |  | yes |
| `rowHeightKey` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `rowHoverColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `rowSpan` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 1 |  | yes |
| `rowStart` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 1 |  | yes |
| `runSpacing` | property | keys.dart notationKeyNames (4 types) |  |  | 0 (0) |  q1 | 3 |  | yes |
| `runs` | property | keys.dart notationKeyNames (2 types) |  |  | 11 (8) |  | 0 | open full | yes |
| `scaleDown` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `scaleMode` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `scaleStroke` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `screen` | property | keys.dart notationKeyNames (1 types) |  |  | 22 (20) |  | 2 | open full | yes |
| `scrollDirection` | property | keys.dart notationKeyNames (7 types) |  |  | 0 (0) |  | 5 |  | yes |
| `scrollable` | property | keys.dart notationKeyNames (5 types) |  |  | 0 (0) |  | 12 |  | yes |
| `scrolledUnderElevation` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `scrubEnabled` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `scrubStep` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `secondaryActiveTrackColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `secondaryTrackValue` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `sections` | property | keys.dart notationKeyNames (1 types) |  |  | 16 (6) |  | 0 | open full | yes |
| `segmentColorField` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `segmentGap` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `segmentHeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `segments` | property | keys.dart notationKeyNames (3 types) |  |  | 3 (3) |  | 2 |  | yes |
| `selectAllOnFocus` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectOnHover` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectable` | property | keys.dart notationKeyNames (2 types) |  |  | 6 (5) | 2 runs, 2 | 1 |  | yes |
| `selectableMax` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectableMin` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selected` | property | keys.dart notationKeyNames (5 types) |  |  | 2796 (414) | 2 runs, 11 q91 | 26 | open full | yes |
| `selectedBackgroundColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectedColor` | property | keys.dart notationKeyNames (4 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectedForegroundColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectedIcon` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectedIconColor` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectedIconSize` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectedIndex` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectedItemStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectedLabelTextStyle` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectedRow` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectedRowColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectedShadows` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectedTileColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectedX` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionColor` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionDotColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionDotRadius` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionDotStrokeColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionDotStrokeWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionGuides` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionHaloColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionHaloRadius` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionHeightStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionLineColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionLineWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionMax` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionMin` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionSeries` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionStep` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionTagColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionTagStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionWidthStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionXLabel` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionY` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `selectionYLabel` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `semanticLabel` | property | keys.dart notationKeyNames (7 types) |  |  | 0 (0) | 5 runs, 23 q2 | 2 |  | yes |
| `separator` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `series` | property | keys.dart notationKeyNames (2 types) |  |  | 47 (35) | 1 runs, 14 | 1 | open full | yes |
| `shadowColor` | property | keys.dart notationKeyNames (6 types) |  |  | 0 (0) |  | 0 |  | yes |
| `shadows` | property | keys.dart notationKeyNames (16 types) |  |  | 0 (0) |  | 0 |  | yes |
| `shape` | property | keys.dart notationKeyNames (21 types) |  |  | 15 (8) |  q1 | 3 |  | yes |
| `shimmer` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 | open full | yes |
| `shortcut` | property | keys.dart notationKeyNames (1 types) |  |  | 3 (2) |  q1 | 2 | full | yes |
| `showCaptions` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showCheckmark` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showControls` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  q1 | 1 |  | yes |
| `showCursor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showDividers` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showFirstLast` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showFullscreenButton` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showNeedle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `showPageNumbers` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showPageSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showPrevNext` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showSelectedIcon` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showSignLine` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showSignMark` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showSummary` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showTarget` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showThumb` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showTotals` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showTrailingIcon` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showValueIndicator` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showValues` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showVideoAnnotations` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `showXAxis` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `showYAxis` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `shrinkTapTarget` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `shrinkWrapRows` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) | 1 runs, 2 | 2 |  | yes |
| `siblingCount` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `side` | property | keys.dart notationKeyNames (8 types) |  |  | 41 (19) | 1 runs, 4 | 2 | open full | yes |
| `signLineBottom` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `signLineColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `signLineDash` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `signLineGap` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `signLineInset` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `signLineMark` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `signLineOffset` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `signLineStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `signLineWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `signMarkColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `signMarkGap` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `signMarkIcon` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `signMarkPlacement` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `signMarkSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `size` | property | keys.dart notationKeyNames (1 types) |  |  | 2182 (385) | 8 runs, 34 q271 | 95 | open full | yes |
| `sliceGap` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `slidingThumb` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `smallSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `smooth` | property | keys.dart notationKeyNames (3 types) |  |  | 2 (2) |  | 0 |  | yes |
| `sortAscending` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `sortColumn` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `sortable` | property | keys.dart notationKeyNames (1 types) |  |  | 14 (5) |  | 0 |  | yes |
| `source` | property | keys.dart notationKeyNames (2 types) |  |  | 20 (12) | 1 runs, 5 | 0 |  | yes |
| `sourceType` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `spacing` | property | keys.dart notationKeyNames (14 types) |  |  | 2 (2) |  | 0 |  | yes |
| `splashColor` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `splashRadius` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `squeezable` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 1 |  | yes |
| `squeezeChildren` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `stackGap` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `stackGapEdge` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `start` | property | keys.dart notationKeyNames (1 types) |  |  | 35 (28) | 1 runs, 2 q1 | 0 | open full | yes |
| `startAngle` | property | keys.dart notationKeyNames (4 types) |  |  | 0 (0) |  | 0 |  | yes |
| `startAt` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `startField` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `states` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `step` | property | keys.dart notationKeyNames (2 types) |  |  | 286 (114) |  q3 | 1 | open full | yes |
| `steppers` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `stickToEnd` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `sticky` | property | keys.dart notationKeyNames (70 types) |  |  | 69 (48) | 6 runs, 329 | 3 | open full | yes |
| `stretchItems` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `stretchLastColumn` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `stripeColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `strokeAlign` | property | keys.dart notationKeyNames (12 types) |  |  | 0 (0) |  | 0 |  | yes |
| `strokeCap` | property | keys.dart notationKeyNames (12 types) |  |  | 0 (0) |  q1 | 0 |  | yes |
| `strokeJoin` | property | keys.dart notationKeyNames (1 types) |  |  | 1 (1) |  q1 | 0 |  | yes |
| `strokeMiterLimit` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `strokeSides` | property | keys.dart notationKeyNames (11 types) |  |  | 0 (0) |  | 0 |  | yes |
| `strokeWidth` | property | keys.dart notationKeyNames (12 types) |  |  | 2 (2) |  q86 | 6 |  | yes |
| `strokes` | property | keys.dart notationKeyNames (11 types) |  |  | 5 (4) |  | 0 |  | yes |
| `style` | property | keys.dart notationKeyNames (11 types) |  |  | 16 (7) |  q142 | 16 | open full | yes |
| `summaryText` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `surfaceTintColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `sweepAngle` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `swipeActions` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 1 |  | yes |
| `symbology` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `syncTolerance` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tabAlignment` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tabs` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 | open full | yes |
| `tabularFigures` | property | keys.dart notationKeyNames (16 types) |  |  | 0 (0) |  | 2 |  | yes |
| `tagBackground` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tagTextStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `target` | property | keys.dart notationKeyNames (1 types) |  |  | 57 (39) | 1 runs, 8 | 1 |  | yes |
| `targetAcross` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `targetColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `text` | property | keys.dart notationKeyNames (2 types) |  |  | 27 (15) |  | 10 | open full | yes |
| `textAlign` | property | keys.dart notationKeyNames (6 types) |  |  | 0 (0) |  | 2 |  | yes |
| `textAlignVertical` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `textCapitalization` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `textColor` | property | keys.dart notationKeyNames (4 types) |  |  | 2 (1) |  | 0 |  | yes |
| `textDirection` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `textInputAction` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `textStyle` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thickness` | property | keys.dart notationKeyNames (4 types) |  |  | 4 (1) |  | 1 |  | yes |
| `thumbBorderColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thumbBorderWidth` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thumbColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thumbCornerRadius` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thumbGlowBlur` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thumbGlowColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thumbGlowSpread` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thumbInset` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thumbRadius` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thumbShadows` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thumbShape` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thumbSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thumbStrokeColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `thumbStrokeWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tickColor` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tickCount` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tickMarkRadius` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tickMarkStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `ticks` | property | keys.dart notationKeyNames (1 types) |  |  | 3 (3) |  | 0 |  | yes |
| `tileColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tilePadding` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tilt` | property | keys.dart notationKeyNames (70 types) |  |  | 2 (2) |  | 0 |  | yes |
| `title` | property | keys.dart notationKeyNames (1 types) |  |  | 47 (26) | 2 runs, 206 q15 | 1 | open full | yes |
| `titleAlignment` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `titleSpacing` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `titleTextStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `titles` | property | keys.dart notationKeyNames (1 types) |  |  | 1 (1) |  | 0 |  | yes |
| `toggleCurve` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `toggleDurationMs` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `toggleable` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tonal` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltip` | property | keys.dart notationKeyNames (70 types) |  |  | 1458 (370) | 1 runs, 3 q57 | 2 | open full | yes |
| `tooltipBackground` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltipColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltipLabelField` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltipLabelStyle` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltipShadowColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltipTextColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltipTitleField` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltipTitleStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltipTrend` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltipValueStyle` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltipXFormat` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltipYDecimals` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltipYScale` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tooltipYSuffix` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `totalsColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `totalsGap` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `totalsSelectedColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `track` | property | keys.dart notationKeyNames (70 types) |  |  | 3 (3) |  | 0 |  | yes |
| `trackColor` | property | keys.dart notationKeyNames (3 types) |  |  | 0 (0) |  | 0 |  | yes |
| `trackGap` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `trackHeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `trackOutlineWidth` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `trackPadding` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `trackRadius` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `trackShape` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `transformGesture` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `transitions` | property | keys.dart notationKeyNames (70 types) |  |  | 1 (1) |  | 0 |  | yes |
| `trimEnd` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `trimStart` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `tristate` | property | keys.dart notationKeyNames (1 types) |  |  | 2 (1) |  | 1 |  | yes |
| `type` | property | keys.dart notationKeyNames (2 types) |  |  | 456 (176) |  q2 | 8 | open full | yes |
| `typewriter` | property | keys.dart notationKeyNames (70 types) |  |  | 2 (1) |  | 0 |  | yes |
| `underline` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) | 1 runs, 1 | 0 |  | yes |
| `uniformThumb` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `unselectedLabelColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `unselectedLabelStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `url` | property | keys.dart notationKeyNames (3 types) |  |  | 2 (2) | 4 runs, 12 q1 | 1 | open full | yes |
| `useDataSource` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `validator` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 8 |  | yes |
| `value` | property | keys.dart notationKeyNames (14 types) |  |  | 286 (135) | 3 runs, 44 q4 | 9 | open full | yes |
| `valueColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `valueDecimals` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `valueFontSize` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `valueGap` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `valueIndicatorColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `valueIndicatorShape` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `valueIndicatorTextStyle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `valueSuffix` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `values` | property | keys.dart notationKeyNames (1 types) |  |  | 315 (167) | 1 runs, 2 q1 | 7 | open full | yes |
| `variant` | property | keys.dart notationKeyNames (6 types) |  |  | 4 (4) |  | 0 | open full | yes |
| `variants` | property | keys.dart notationKeyNames (1 types) |  |  | 4 (1) |  | 1 | open full | yes |
| `verticalLines` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `videoId` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `viewBox` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  q44 | 5 |  | yes |
| `viewProgress` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 0 |  | yes |
| `viewportFraction` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `visible` | property | keys.dart notationKeyNames (70 types) |  |  | 390 (95) | 2 runs, 83 q12 | 24 | open full | yes |
| `visualDensity` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `volume` | property | keys.dart notationKeyNames (3 types) |  |  | 15 (11) |  q1 | 1 | open full | yes |
| `w` | property | keys.dart notationKeyNames (70 types) |  |  | 2942 (401) | 4 runs, 831 q120 | 369 | open full | yes |
| `width` | property | keys.dart notationKeyNames (70 types) |  |  | 12 (9) |  | 0 | open full | yes |
| `widthFactor` | property | keys.dart notationKeyNames (70 types) |  |  | 0 (0) |  | 1 |  | yes |
| `wrap` | property | keys.dart notationKeyNames (4 types) |  |  | 70 (45) |  q1 | 5 |  | yes |
| `wrapAlignment` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `wrapCrossAlignment` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `wrapSpacing` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `x` | property | keys.dart notationKeyNames (70 types) |  |  | 233 (87) | 1 runs, 13 q1 | 8 | open full | yes |
| `xAxisHeight` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `xAxisLabelColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `xAxisTitle` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `xField` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `xLabelAnchor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `xLabelEvery` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `xLabelGap` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `xLabelOffset` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `xLabels` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `xMax` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `xMin` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `xSlots` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `xTicks` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `y` | property | keys.dart notationKeyNames (70 types) |  |  | 94 (31) | 1 runs, 13 q1 | 7 |  | yes |
| `yAxisFontFamily` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `yAxisTitle` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `yAxisWidth` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `yField` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `yLabelAffixTopOnly` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `yLabelAlign` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `yLabelPrefix` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `yLabelSuffix` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `yLines` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `yMax` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `yMin` | property | keys.dart notationKeyNames (2 types) |  |  | 0 (0) |  | 0 |  | yes |
| `yTicks` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `zeroLineColor` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `zoneOpacity` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `zoneThickness` | property | keys.dart notationKeyNames (1 types) |  |  | 0 (0) |  | 0 |  | yes |
| `zones` | property | keys.dart notationKeyNames (1 types) |  |  | 27 (9) |  | 0 |  | yes |
| `animation` | record line | paint_words.dart _paintHead |  |  | 0 (0) |  | 2 | full | yes |
| `customPaint` | record line | paint_words.dart _paintHead |  |  | 0 (0) |  q44 | 4 |  | yes |
| `foregroundPainter` | record line | paint_words.dart _paintHead |  |  | 0 (0) |  q1 | 0 |  | yes |
| `track` | record line | paint_words.dart _paintHead |  |  | 0 (0) |  | 4 |  | yes |
| `transition` | record line | paint_words.dart _paintHead |  |  | 0 (0) |  | 5 |  | yes |
| `bob` | value: animate= | notation.dart notationAnimations (bob) |  |  | 0 (0) |  | 0 |  | yes |
| `bounce` | value: animate= | notation.dart notationAnimations (bounce) |  |  | 0 (0) |  | 0 |  | yes |
| `fade` | value: animate= | notation.dart notationAnimations (enter) |  |  | 72 (55) |  | 1 | open full | yes |
| `fade-up` | value: animate= | notation.dart notationAnimations (enter) |  |  | 0 (0) |  | 0 |  | yes |
| `flash` | value: animate= | notation.dart notationAnimations (flash) |  |  | 0 (0) |  | 0 |  | yes |
| `pop` | value: animate= | notation.dart notationAnimations (pop) |  |  | 72 (61) |  | 0 |  | yes |
| `pulse` | value: animate= | notation.dart notationAnimations (pulse) |  |  | 98 (78) |  | 0 |  | yes |
| `scale` | value: animate= | notation.dart notationAnimations (enter) |  |  | 22 (21) |  | 0 |  | yes |
| `shake` | value: animate= | notation.dart notationAnimations (shake) |  |  | 18 (17) |  | 0 |  | yes |
| `shimmer` | value: animate= | notation.dart notationAnimations (shimmer) |  |  | 6 (4) |  | 0 |  | yes |
| `slide` | value: animate= | notation.dart notationAnimations (enter) |  |  | 0 (0) |  | 0 |  | yes |
| `slide-down` | value: animate= | notation.dart notationAnimations (enter) |  |  | 0 (0) |  | 0 |  | yes |
| `slide-left` | value: animate= | notation.dart notationAnimations (enter) |  |  | 4 (4) |  | 0 |  | yes |
| `slide-right` | value: animate= | notation.dart notationAnimations (enter) |  |  | 0 (0) |  | 0 |  | yes |
| `slide-up` | value: animate= | notation.dart notationAnimations (enter) |  |  | 71 (55) |  | 0 |  | yes |
| `spin` | value: animate= | notation.dart notationAnimations (spin) |  |  | 13 (11) |  | 0 |  | yes |
| `sway` | value: animate= | notation.dart notationAnimations (sway) |  |  | 0 (0) |  | 0 |  | yes |
| `wiggle` | value: animate= | notation.dart notationAnimations (wiggle) |  |  | 0 (0) |  | 0 |  | yes |
| `zoom` | value: animate= | notation.dart notationAnimations (enter) |  |  | 0 (0) |  | 0 |  | yes |
| `desktop` | value: media condition | media_words.dart mediaSizes |  |  | 1 (1) |  | 2 |  | yes |
| `landscape` | value: media condition | media_words.dart mediaSizes (read in mediaCondition) |  |  | 0 (0) |  | 0 |  | yes |
| `mobile` | value: media condition | media_words.dart mediaSizes (read in mediaCondition) |  |  | 0 (0) |  | 0 |  | yes |
| `phone` | value: media condition | media_words.dart mediaSizes |  |  | 124 (55) |  q122 | 10 | open full | yes |
| `portrait` | value: media condition | media_words.dart mediaSizes (read in mediaCondition) |  |  | 0 (0) |  | 1 |  | yes |
| `tablet` | value: media condition | media_words.dart mediaSizes |  |  | 38 (18) |  q31 | 12 | open full | yes |
| `disabled` | value: state | state_words.dart notationStateNames (WidgetState) |  |  | 0 (0) |  | 2 | full | yes |
| `dragged` | value: state | state_words.dart notationStateNames (WidgetState) |  |  | 0 (0) |  | 0 | open full | yes |
| `focused` | value: state | state_words.dart notationStateNames (WidgetState) |  |  | 0 (0) |  q14 | 4 |  | yes |
| `hovered` | value: state | state_words.dart notationStateNames (WidgetState) |  |  | 0 (0) |  q19 | 16 |  | yes |
| `pressed` | value: state | state_words.dart notationStateNames (WidgetState) |  |  | 0 (0) |  q7 | 4 |  | yes |
| `selected` | value: state | state_words.dart notationStateNames (WidgetState) |  |  | 0 (0) |  q8 | 16 | open full | yes |
| `Badge.danger` | value: variant | notation.dart badgeVariants |  |  | 28 (19) |  | 0 | open full | yes |
| `Badge.error` | value: variant | notation.dart badgeVariants |  |  | 204 (130) |  | 0 | open full | yes |
| `Badge.info` | value: variant | notation.dart badgeVariants |  |  | 241 (197) |  | 0 | open full | yes |
| `Badge.neutral` | value: variant | notation.dart badgeVariants |  |  | 337 (201) |  | 0 | open full | yes |
| `Badge.primary` | value: variant | notation.dart badgeVariants |  |  | 124 (99) |  | 0 | open full | yes |
| `Badge.success` | value: variant | notation.dart badgeVariants |  |  | 431 (253) |  | 0 | open full | yes |
| `Badge.warning` | value: variant | notation.dart badgeVariants |  |  | 370 (229) |  | 0 | open full | yes |
| `Button.destructive` | value: variant | notation.dart buttonVariants (filledButton) |  |  | 328 (188) |  | 0 | open full | yes |
| `Button.elevated` | value: variant | notation.dart buttonVariants (elevatedButton) |  |  | 6 (6) |  | 1 | open full | yes |
| `Button.ghost` | value: variant | notation.dart buttonVariants (textButton) |  |  | 827 (333) |  q18 | 9 | open full | yes |
| `Button.outline` | value: variant | notation.dart buttonVariants (outlinedButton) |  |  | 2099 (434) |  q2 | 2 | open full | yes |
| `Button.primary` | value: variant | notation.dart buttonVariants (filledButton) |  |  | 1 (1) |  | 0 | open full | yes |
| `Button.secondary` | value: variant | notation.dart buttonVariants (filledButton) |  |  | 62 (47) |  | 0 | open full | yes |
| `Button.tertiary` | value: variant | notation.dart buttonVariants (filledButton) |  |  | 15 (12) |  | 0 | open full | yes |
| `Text.body` | value: variant | notation.dart defaultTextVariants |  |  | 31 (14) |  | 0 | open full | yes |
| `Text.bodySecondary` | value: variant | notation.dart defaultTextVariants |  |  | 4 (3) |  q2 | 0 | open full | yes |
| `Text.caption` | value: variant | notation.dart defaultTextVariants |  |  | 2064 (330) |  q8 | 4 | open full | yes |
| `Text.danger` | value: variant | notation.dart defaultTextVariants |  |  | 112 (84) |  | 0 | open full | yes |
| `Text.fieldLabel` | value: variant | notation.dart defaultTextVariants |  |  | 397 (128) |  q9 | 0 | open full | yes |
| `Text.heading` | value: variant | notation.dart defaultTextVariants |  |  | 349 (129) |  q2 | 11 | open full | yes |
| `Text.heading1` | value: variant | notation.dart defaultTextVariants |  |  | 25 (10) |  q1 | 1 | open full | yes |
| `Text.heading2` | value: variant | notation.dart defaultTextVariants |  |  | 12 (9) |  q2 | 19 | open full | yes |
| `Text.heading3` | value: variant | notation.dart defaultTextVariants |  |  | 27 (13) |  q2 | 2 | open full | yes |
| `Text.mono` | value: variant | notation.dart defaultTextVariants |  |  | 379 (123) |  q17 | 0 | open full | yes |
| `Text.muted` | value: variant | notation.dart defaultTextVariants |  |  | 4231 (439) |  q2 | 9 | open full | yes |
| `Text.pageTitle` | value: variant | notation.dart defaultTextVariants |  |  | 7 (6) |  | 0 | open full | yes |
| `Text.panelTitle` | value: variant | notation.dart defaultTextVariants |  |  | 211 (55) |  | 5 | open full | yes |
| `Text.sectionTitle` | value: variant | notation.dart defaultTextVariants |  |  | 180 (62) |  | 0 | open full | yes |
| `Text.small` | value: variant | notation.dart defaultTextVariants |  |  | 295 (123) |  q20 | 3 | open full | yes |
| `Text.strong` | value: variant | notation.dart defaultTextVariants |  |  | 3443 (436) |  q18 | 9 | open full | yes |
| `Text.success` | value: variant | notation.dart defaultTextVariants |  |  | 98 (70) |  | 4 | open full | yes |
| `Text.title` | value: variant | notation.dart defaultTextVariants |  |  | 51 (21) |  | 12 | open full | yes |

## Kind b: rewrite: written out into other lines by Dart code in the expander

| word | category | declared | stands for | expands to | corpus uses (answers) | round 10 | reference uses | taught | documented |
|---|---|---|---|---|---|---|---|---|---|
| `Avatar src=` | contextual rewrite | hand-kept | read as image=: PageWords._plain (page_words.dart) |  | 0 (0) |  | 0 |  |  |
| `Badge (with w=)` | contextual rewrite | hand-kept | a Badge with a width is a Row of that width around the Badge; its bound color is dropped: PageWords._rewrite (page_words.dart) |  | 0 (0) |  | 0 |  |  |
| `Input (in a bar)` | contextual rewrite | hand-kept | an Input, Search or SearchField in a Nav, or labelled Search/Filter/Find: its label is its hint: PageWords._rewrite (page_words.dart) |  | 0 (0) |  | 0 |  |  |
| `Row sticky bottom (in App)` | contextual rewrite | hand-kept | the foot of an app's window, as Footer: PageWords._rewrite, the foot branch (page_words.dart) |  | 0 (0) |  | 0 |  |  |
| `Row/Column (turning at a width)` | contextual rewrite | hand-kept | a Row or Column with phone.direction= (any width) is a Flex: PageWords._rewrite (page_words.dart, _turns) |  | 0 (0) |  | 0 |  |  |
| `Text (with a look)` | contextual rewrite | hand-kept | a Text with fill, radius or a border is a Box around the Text: PageWords._rewrite and _textBox (page_words.dart) |  | 0 (0) |  | 0 |  |  |
| `a gallery (photos=)` | contextual rewrite | hand-kept | a design system's gallery with photos opens them in the page's lightbox: PageWords._gallery (page_words.dart) |  | 0 (0) |  | 0 |  |  |
| `sticky=true` | contextual rewrite | hand-kept | read as the flag sticky: PageWords._plain (page_words.dart) |  | 0 (0) |  | 0 |  |  |
| `ConfirmDialog` | line rewrite | vocabulary.dart NotationVocabulary.core.types (line: confirmDialog) | lineRewrites['confirmDialog'] (vocabulary.dart _confirmDialogLines) |  | 4 (1) |  | 0 |  | yes |
| `Shortcut` | line rewrite | vocabulary.dart NotationVocabulary.core.types (line: shortcut) | lineRewrites['shortcut'] (vocabulary.dart _shortcutLine) |  | 105 (13) |  | 0 |  | yes |
| `computed` | line rewrite | vocabulary.dart NotationVocabulary.core.types (line: computed) | lineRewrites['computed'] (vocabulary.dart _computedLine) |  | 7 (1) |  | 0 |  | yes |
| `shortcut` | line rewrite | vocabulary.dart NotationVocabulary.core.types (line: shortcut) | lineRewrites['shortcut'] (vocabulary.dart _shortcutLine) |  | 23 (2) |  | 0 | full | yes |
| `App` | page word | page_words.dart PageWords.words | PageWords._rewrite, the App branches (page_words.dart); the drawer and the reflow: _Parser._feet, PageReflow (reflow.dart) | row text | 1294 (436) | 12 runs, 35 | 5 | open full | yes |
| `AppShell` | page word | page_words.dart PageWords.words | PageWords._rewrite, the App branches (page_words.dart); the drawer and the reflow: _Parser._feet, PageReflow (reflow.dart) | row text | 0 (0) |  | 0 |  | yes |
| `Brand` | page word | page_words.dart PageWords.words | PageWords._rewrite, the Brand branch (page_words.dart) | row text | 1329 (430) |  q23 | 2 | open full | yes |
| `Content` | page word | page_words.dart PageWords.words | PageWords._rewrite, the Main branch (page_words.dart) | column text | 0 (0) |  | 0 | open full | yes |
| `Dots` | page word | page_words.dart PageWords.words | _Parser.line and _dotsOf (notation.dart) | column listView row | 35 (30) |  | 0 | open full | yes |
| `Footer` | page word | page_words.dart PageWords.words (_feet) | PageWords._rewrite: the Section branch on a page, the foot branch in an App, the sidebar foot (page_words.dart); _Parser._feet (notation.dart) | column divider text | 193 (147) |  q19 | 4 | open full | yes |
| `H1` | page word | page_words.dart (RegExp ^H[1-4]$) | PageWords._rewrite, the Heading branch (page_words.dart) | text | 0 (0) |  | 0 |  |  |
| `H2` | page word | page_words.dart (RegExp ^H[1-4]$) | PageWords._rewrite, the Heading branch (page_words.dart) | text | 0 (0) |  | 0 |  |  |
| `H3` | page word | page_words.dart (RegExp ^H[1-4]$) | PageWords._rewrite, the Heading branch (page_words.dart) | text | 0 (0) |  | 0 |  |  |
| `H4` | page word | page_words.dart (RegExp ^H[1-4]$) | PageWords._rewrite, the Heading branch (page_words.dart) | text | 0 (0) |  | 0 |  |  |
| `Heading` | page word | page_words.dart PageWords.words | PageWords._rewrite, the Heading branch (page_words.dart) | text | 1948 (434) |  | 1 | open full | yes |
| `Hero` | page word | page_words.dart PageWords.words | PageWords._rewrite, the Section branch (page_words.dart) | column text | 0 (0) |  | 0 |  | yes |
| `IconTile` | page word | page_words.dart PageWords.words | PageWords._rewrite, the IconTile branch (page_words.dart) | column icon | 109 (54) |  q1 | 0 | open full | yes |
| `Link` | page word | page_words.dart PageWords.words | PageWords._rewrite, the Link branch (page_words.dart) | text | 365 (118) |  q10 | 1 | open full | yes |
| `Logo` | page word | page_words.dart PageWords.words | PageWords._rewrite, the Brand branch (page_words.dart) | row text | 0 (0) |  | 0 |  | yes |
| `Main` | page word | page_words.dart PageWords.words | PageWords._rewrite, the Main branch (page_words.dart) | column text | 1294 (436) |  q2 | 5 | open full | yes |
| `NavFooter` | page word | page_words.dart PageWords.words (_feet) | PageWords._rewrite, the sidebar foot branch (page_words.dart) | column text | 0 (0) |  | 0 |  |  |
| `Page` | page word | page_words.dart PageWords.words | PageWords._rewrite, the Page branch (page_words.dart) | column text | 193 (139) | 1 runs, 13 | 3 | open full | yes |
| `Pane` | page word | page_words.dart PageWords.words | PageWords._rewrite, the Pane branch (page_words.dart) | column text | 149 (123) |  | 4 | open full | yes |
| `Panel` | page word | page_words.dart PageWords.words | PageWords._rewrite, the Pane branch (page_words.dart) | column text | 5 (1) |  | 0 |  | yes |
| `Section` | page word | page_words.dart PageWords.words | PageWords._rewrite, the Section branch (page_words.dart) | column text | 268 (139) |  | 3 | open full | yes |
| `SidebarFooter` | page word | page_words.dart PageWords.words (_feet) | PageWords._rewrite, the sidebar foot branch (page_words.dart) | column text | 0 (0) |  | 0 |  |  |
| `SwipeAction` | page word | page_words.dart PageWords.words | _Parser._lineAt (notation.dart): an action a ListRow reveals | column text | 2 (2) | 1 runs, 4 | 2 | full | yes |
| `Title` | page word | page_words.dart PageWords.words | PageWords._rewrite, the Heading branch (page_words.dart) | text | 0 (0) |  | 0 |  | yes |
| `Wanted` | page word | page_words.dart PageWords.words | _Parser._lineAt (notation.dart) and WantedBlock | column | 0 (0) |  | 0 | open full | yes |
| `Window` | page word | page_words.dart PageWords.words | PageWords._rewrite, the App branches (page_words.dart); the drawer and the reflow: _Parser._feet, PageReflow (reflow.dart) | row text | 0 (0) |  | 0 |  | yes |
| `AppBar` | page word: bar | page_words.dart PageWords.words (_bars) | PageWords._rewrite, the bar branch (page_words.dart): a website's Nav, an app's top bar, a row elsewhere | column divider row text | 0 (0) |  | 0 |  | yes |
| `Header` | page word: bar | page_words.dart PageWords.words (_bars) | PageWords._rewrite, the bar branch (page_words.dart): a website's Nav, an app's top bar, a row elsewhere | column divider row text | 0 (0) |  | 2 |  | yes |
| `Nav` | page word: bar | page_words.dart PageWords.words (_bars) | PageWords._rewrite, the bar branch (page_words.dart): a website's Nav, an app's top bar, a row elsewhere | column divider row text | 1451 (440) |  | 1 | open full | yes |
| `NavBar` | page word: bar | page_words.dart PageWords.words (_bars) | PageWords._rewrite, the bar branch (page_words.dart): a website's Nav, an app's top bar, a row elsewhere | column divider row text | 0 (0) |  | 0 |  | yes |
| `Navbar` | page word: bar | page_words.dart PageWords.words (_bars) | PageWords._rewrite, the bar branch (page_words.dart): a website's Nav, an app's top bar, a row elsewhere | column divider row text | 0 (0) |  | 0 |  | yes |
| `TopBar` | page word: bar | page_words.dart PageWords.words (_bars) | PageWords._rewrite, the bar branch (page_words.dart): a website's Nav, an app's top bar, a row elsewhere | column divider row text | 0 (0) |  | 0 |  | yes |
| `Topbar` | page word: bar | page_words.dart PageWords.words (_bars) | PageWords._rewrite, the bar branch (page_words.dart): a website's Nav, an app's top bar, a row elsewhere | column divider row text | 0 (0) |  | 0 |  | yes |
| `NavGroup` | page word: group label | page_words.dart PageWords.words (_sections) | PageWords._rewrite, the group label branch (page_words.dart) | text | 0 (0) |  | 0 |  |  |
| `NavLabel` | page word: group label | page_words.dart PageWords.words (_sections) | PageWords._rewrite, the group label branch (page_words.dart) | text | 0 (0) |  | 0 |  |  |
| `NavSection` | page word: group label | page_words.dart PageWords.words (_sections) | PageWords._rewrite, the group label branch (page_words.dart) | text | 0 (0) | 9 runs, 17 q36 | 2 |  | yes |
| `SidebarGroup` | page word: group label | page_words.dart PageWords.words (_sections) | PageWords._rewrite, the group label branch (page_words.dart) | text | 0 (0) |  | 0 |  |  |
| `SidebarLabel` | page word: group label | page_words.dart PageWords.words (_sections) | PageWords._rewrite, the group label branch (page_words.dart) | text | 0 (0) |  | 0 |  |  |
| `SidebarSection` | page word: group label | page_words.dart PageWords.words (_sections) | PageWords._rewrite, the group label branch (page_words.dart) | text | 0 (0) |  | 0 |  |  |
| `MenuItem` | page word: item | page_words.dart PageWords.words (_items) | PageWords._rewrite, the item branch (page_words.dart) | row text | 818 (209) |  | 0 | open full | yes |
| `NavItem` | page word: item | page_words.dart PageWords.words (_items) | PageWords._rewrite, the item branch (page_words.dart) | row text | 3827 (386) |  q103 | 8 | open full | yes |
| `NavLink` | page word: item | page_words.dart PageWords.words (_items) | PageWords._rewrite, the item branch (page_words.dart) | row text | 0 (0) |  | 0 |  | yes |
| `SidebarItem` | page word: item | page_words.dart PageWords.words (_items) | PageWords._rewrite, the item branch (page_words.dart) | row text | 0 (0) |  | 0 |  | yes |
| `BottomSheet` | page word: overlay | page_words.dart PageWords.words | PageWords.overlay (page_words.dart); _Parser._openBlock (notation.dart) | column iconButton row text | 0 (0) |  | 0 |  | yes |
| `Canvas` | page word: overlay | page_words.dart PageWords.overlay (Canvas#id) | PageWords.overlay (page_words.dart): another canvas |  | 7 (5) |  | 5 |  | yes |
| `Dialog` | page word: overlay | page_words.dart PageWords.words | PageWords.overlay (page_words.dart); _Parser._openBlock (notation.dart) | column iconButton row text | 906 (398) |  | 4 | open full | yes |
| `Drawer` | page word: overlay | page_words.dart PageWords.words | PageWords.overlay (page_words.dart); _Parser._openBlock (notation.dart) | column row text | 12 (11) |  | 0 | open full | yes |
| `Dropdown` | page word: overlay | page_words.dart PageWords.words | PageWords.overlay (page_words.dart); _Parser._openBlock (notation.dart) | column text | 0 (0) |  | 0 |  | yes |
| `Lightbox` | page word: overlay | page_words.dart PageWords.words | PageWords.overlay and _lightbox (page_words.dart); _Parser._openBlock (notation.dart) | box column icon row stack text | 34 (30) |  | 0 | open full | yes |
| `Menu` | page word: overlay | page_words.dart PageWords.words | PageWords.overlay (page_words.dart); _Parser._openBlock (notation.dart) | column text | 275 (209) |  | 0 | open full | yes |
| `Modal` | page word: overlay | page_words.dart PageWords.words | PageWords.overlay (page_words.dart); _Parser._openBlock (notation.dart) | column iconButton row text | 0 (0) |  | 0 |  | yes |
| `Popover` | page word: overlay | page_words.dart PageWords.words | PageWords.overlay (page_words.dart); _Parser._openBlock (notation.dart) | column text | 30 (26) |  | 0 | open full | yes |
| `Popup` | page word: overlay | page_words.dart PageWords.words | PageWords.overlay (page_words.dart); _Parser._openBlock (notation.dart) | column text | 0 (0) |  | 0 |  | yes |
| `Sheet` | page word: overlay | page_words.dart PageWords.words | PageWords.overlay (page_words.dart); _Parser._openBlock (notation.dart) | column iconButton row text | 221 (179) |  | 0 | open full | yes |
| `Aside` | page word: sidebar | page_words.dart PageWords.words (_sides) | PageWords._rewrite, the sidebar branch (page_words.dart); the phone drawer: _Parser (notation.dart) from PageWords.sidebar | column text | 0 (0) |  | 0 |  | yes |
| `Rail` | page word: sidebar | page_words.dart PageWords.words (_sides) | PageWords._rewrite, the sidebar branch (page_words.dart); the phone drawer: _Parser (notation.dart) from PageWords.sidebar | column text | 1 (1) | 3 runs, 17 | 0 |  | yes |
| `SideNav` | page word: sidebar | page_words.dart PageWords.words (_sides) | PageWords._rewrite, the sidebar branch (page_words.dart); the phone drawer: _Parser (notation.dart) from PageWords.sidebar | column text | 0 (0) |  | 0 |  | yes |
| `Sidebar` | page word: sidebar | page_words.dart PageWords.words (_sides) | PageWords._rewrite, the sidebar branch (page_words.dart); the phone drawer: _Parser (notation.dart) from PageWords.sidebar | column text | 1120 (392) |  q4 | 4 | open full | yes |
| `Sidenav` | page word: sidebar | page_words.dart PageWords.words (_sides) | PageWords._rewrite, the sidebar branch (page_words.dart); the phone drawer: _Parser (notation.dart) from PageWords.sidebar | column text | 0 (0) |  | 0 |  | yes |
| `Table` | page word: table | page_words.dart _rewrite (word == Table) and table_words.dart | PageWords._tableLines, _cellLine, _tableClose (table_words.dart) | column listView row text | 28 (22) | 2 runs, 12 q1 | 2 |  | yes |

## Kind c: alias or universal word: another name, or a word every line takes

| word | category | declared | stands for | expands to | corpus uses (answers) | round 10 | reference uses | taught | documented |
|---|---|---|---|---|---|---|---|---|---|
| `onChanged` | alias: event | notation_events.dart _blockEventFamilies | the first of its family a block has |  | 0 (0) |  | 0 |  | yes |
| `onClick` | alias: event | notation_events.dart _blockEventFamilies | the first of its family a block has |  | 2 (1) |  | 0 |  | yes |
| `onContextMenu` | alias: event | notation_events.dart _eventAliases | the trigger it names (secondaryClick) |  | 3 (3) |  | 0 |  |  |
| `onPress` | alias: event | notation_events.dart _eventAliases | the trigger it names (click) |  | 137 (18) |  | 3 | full | yes |
| `onPressed` | alias: event | notation_events.dart _eventAliases | the trigger it names (click) |  | 0 (0) |  | 0 |  | yes |
| `onSecondaryClick` | alias: event | notation_events.dart _blockEventFamilies | the first of its family a block has |  | 0 (0) |  | 0 |  |  |
| `onSubmitted` | alias: event | notation_events.dart _blockEventFamilies | the first of its family a block has |  | 0 (0) | 8 runs, 24 | 0 |  | yes |
| `onDelete` | alias: events | vocabulary.dart NotationVocabulary.core.events[*] | onRemove (on *) |  | 11 (11) |  | 0 |  | yes |
| `onEnter` | alias: events | vocabulary.dart NotationVocabulary.core.events[Input] | onSubmit (on Input) |  | 11 (5) |  | 0 |  | yes |
| `onSaved` | alias: events | vocabulary.dart NotationVocabulary.core.events[Input] | onBlur (on Input) |  | 2 (1) |  | 0 |  | yes |
| `onSelect` | alias: events | vocabulary.dart NotationVocabulary.core.events[Calendar] | onChange (on Calendar) |  | 98 (76) | 1 runs, 29 | 0 |  | yes |
| `onSubmitted` | alias: events | vocabulary.dart NotationVocabulary.core.events[Input] | onSubmit (on Input) |  | 0 (0) | 8 runs, 24 | 0 |  | yes |
| `allcaps` | alias: flags | vocabulary.dart NotationVocabulary.core.flags[Input] | caps (on Input) |  | 0 (0) |  | 0 |  | yes |
| `disabled` | alias: flags | vocabulary.dart NotationVocabulary.core.flags[*] | enabled=false (on *) |  | 4 (4) | 1 runs, 2 | 0 | full | yes |
| `persist` | alias: flags | vocabulary.dart NotationVocabulary.core.flags[state] | saved (on state) |  | 103 (12) |  | 0 | open full | yes |
| `persisted` | alias: flags | vocabulary.dart NotationVocabulary.core.flags[state] | saved (on state) |  | 0 (0) |  | 0 |  | yes |
| `persistent` | alias: flags | vocabulary.dart NotationVocabulary.core.flags[state] | saved (on state) |  | 1 (1) |  | 0 |  | yes |
| `readonly` | alias: flags | vocabulary.dart NotationVocabulary.core.flags[*] | readOnly (on *) |  | 22 (17) | 1 runs, 1 | 0 |  | yes |
| `reorderable` | alias: flags | vocabulary.dart NotationVocabulary.core.flags[*] | reorder (on *) |  | 1 (1) |  | 0 | full | yes |
| `sortable` | alias: flags | vocabulary.dart NotationVocabulary.core.flags[*] | reorder (on *) |  | 14 (5) |  | 0 |  | yes |
| `uppercase` | alias: flags | vocabulary.dart NotationVocabulary.core.flags[Input] | caps (on Input) |  | 0 (0) |  | 0 |  | yes |
| `bold` | alias: parameter | keys.dart notationTextStyleKeys | props.style.fontWeight (on text) |  | 1 (1) |  | 0 |  | yes |
| `border-b` | alias: parameter | notation.dart _borderSides | a hairline on one side |  | 0 (0) |  | 0 |  |  |
| `border-bottom` | alias: parameter | notation.dart _borderSides | a hairline on one side |  | 158 (83) |  q13 | 6 | open full | yes |
| `border-l` | alias: parameter | notation.dart _borderSides | a hairline on one side |  | 0 (0) |  | 0 |  |  |
| `border-left` | alias: parameter | notation.dart _borderSides | a hairline on one side |  | 25 (20) |  | 4 | open full | yes |
| `border-r` | alias: parameter | notation.dart _borderSides | a hairline on one side |  | 0 (0) |  | 0 |  |  |
| `border-right` | alias: parameter | notation.dart _borderSides | a hairline on one side |  | 11 (6) |  q2 | 6 | open full | yes |
| `border-t` | alias: parameter | notation.dart _borderSides | a hairline on one side |  | 0 (0) |  | 0 |  |  |
| `border-top` | alias: parameter | notation.dart _borderSides | a hairline on one side |  | 23 (21) |  q6 | 1 | open full | yes |
| `borderBottom` | alias: parameter | notation.dart _borderSides | a hairline on one side |  | 0 (0) |  | 0 |  |  |
| `borderLeft` | alias: parameter | notation.dart _borderSides | a hairline on one side |  | 0 (0) |  | 0 |  |  |
| `borderRight` | alias: parameter | notation.dart _borderSides | a hairline on one side |  | 0 (0) |  | 0 |  |  |
| `borderTop` | alias: parameter | notation.dart _borderSides | a hairline on one side |  | 0 (0) |  | 0 |  |  |
| `color` | alias: parameter | keys.dart notationTextStyleKeys | props.style.color (on text) |  | 1471 (298) | 15 runs, 226 q302 | 104 | open full | yes |
| `cols` | alias: parameter | keys.dart notationTypeKeys[gridView] | props.crossAxisCount (on gridView) |  | 579 (321) |  q1 | 8 | open full | yes |
| `columns` | alias: parameter | keys.dart notationTypeKeys[gridView] | props.crossAxisCount (on gridView) |  | 27 (16) |  q1 | 3 | open full | yes |
| `description` | alias: parameter | vocabulary.dart parameterSynonyms | the one of {description, detail, note} a word takes |  | 10 (2) | 1 runs, 33 q2 | 0 |  | yes |
| `detail` | alias: parameter | vocabulary.dart parameterSynonyms | the one of {description, detail, note} a word takes |  | 7 (5) | 1 runs, 116 q3 | 0 | open full | yes |
| `error` | alias: parameter | keys.dart notationTypeKeys[textField] | props.decoration.errorText (on textField) |  | 9 (4) |  | 0 | open full | yes |
| `font` | alias: parameter | keys.dart notationTextStyleKeys | props.style.fontFamily (on text) |  | 103 (10) |  | 0 |  | yes |
| `fontFamily` | alias: parameter | keys.dart notationTextStyleKeys | props.style.fontFamily (on text) |  | 3 (2) |  q9 | 0 |  | yes |
| `fontSize` | alias: parameter | keys.dart notationTextStyleKeys | props.style.fontSize (on text) |  | 7 (5) |  | 0 |  | yes |
| `fontWeight` | alias: parameter | keys.dart notationTextStyleKeys | props.style.fontWeight (on text) |  | 0 (0) |  | 0 |  | yes |
| `gap` | alias: parameter | keys.dart notationTypeKeys[gridView] | props.mainAxisSpacing, props.crossAxisSpacing (on gridView) |  | 12851 (442) | 1 runs, 2 q181 | 169 | open full | yes |
| `helper` | alias: parameter | keys.dart notationTypeKeys[textField] | props.decoration.helperText (on textField) |  | 0 (0) |  | 0 |  | yes |
| `hint` | alias: parameter | vocabulary.dart parameterSynonyms | the one of {placeholder, hint} a word takes |  | 44 (26) |  | 5 | open full | yes |
| `label` | alias: parameter | keys.dart notationTypeKeys[textField] | props.decoration.labelText (on textField) |  | 103 (51) | 2 runs, 181 q21 | 9 | open full | yes |
| `letterSpacing` | alias: parameter | keys.dart notationFieldStyleKeys | props.style.letterSpacing (on textField) |  | 3 (1) |  q32 | 4 |  | yes |
| `lineHeight` | alias: parameter | keys.dart notationTextStyleKeys | props.style.height (on text) |  | 12 (5) |  q1 | 8 |  | yes |
| `note` | alias: parameter | vocabulary.dart parameterSynonyms | the one of {description, detail, note} a word takes |  | 54 (50) | 1 runs, 33 q4 | 0 |  | yes |
| `peek` | alias: parameter | keys.dart notationTypeKeys[pageView] | props.viewportFraction (on pageView) |  | 13 (13) |  | 0 | open full | yes |
| `placeholder` | alias: parameter | vocabulary.dart parameterSynonyms | the one of {placeholder, hint} a word takes |  | 2 (2) |  | 0 |  | yes |
| `size` | alias: parameter | keys.dart notationTextStyleKeys | props.style.fontSize (on text) |  | 2182 (385) | 8 runs, 34 q271 | 95 | open full | yes |
| `spacing` | alias: parameter | keys.dart notationTypeKeys[gridView] | props.mainAxisSpacing, props.crossAxisSpacing (on gridView) |  | 2 (2) |  | 0 |  | yes |
| `textSize` | alias: parameter | keys.dart notationFieldStyleKeys | props.style.fontSize (on textField) |  | 2 (1) |  | 0 |  |  |
| `weight` | alias: parameter | keys.dart notationTextStyleKeys | props.style.fontWeight (on text) |  | 876 (246) | 1 runs, 1 q79 | 23 | open full | yes |
| `code` | alias: parameters | vocabulary.dart NotationVocabulary.core.parameters[Barcode] | data (on Barcode) |  | 36 (26) | 1 runs, 29 q2 | 2 | open full | yes |
| `disabled` | alias: parameters | vocabulary.dart NotationVocabulary.core.parameters[*] | !enabled (on *) |  | 193 (81) | 1 runs, 4 q1 | 0 | full | yes |
| `format` | alias: parameters | vocabulary.dart NotationVocabulary.core.parameters[Barcode] | symbology (on Barcode) |  | 40 (21) |  | 0 |  | yes |
| `maxChars` | alias: parameters | vocabulary.dart NotationVocabulary.core.parameters[Input] | maxLength (on Input) |  | 0 (0) |  | 0 |  | yes |
| `maxlength` | alias: parameters | vocabulary.dart NotationVocabulary.core.parameters[Input] | maxLength (on Input) |  | 13 (7) |  | 0 |  | yes |
| `readonly` | alias: parameters | vocabulary.dart NotationVocabulary.core.parameters[*] | readOnly (on *) |  | 23 (17) | 3 runs, 7 | 0 |  | yes |
| `rows` | alias: parameters | vocabulary.dart NotationVocabulary.core.parameters[Input] | lines (on Input) |  | 83 (47) | 1 runs, 12 q2 | 6 | open full | yes |
| `subtitle` | alias: parameters | vocabulary.dart NotationVocabulary.core.parameters[ListTile] | $text (on ListTile) |  | 210 (147) | 1 runs, 20 | 0 |  | yes |
| `title` | alias: parameters | vocabulary.dart NotationVocabulary.core.parameters[ListTile] | $text (on ListTile) |  | 47 (26) | 2 runs, 206 q15 | 1 | open full | yes |
| `type` | alias: parameters | vocabulary.dart NotationVocabulary.core.parameters[Barcode] | symbology (on Barcode) |  | 456 (176) |  q2 | 8 | open full | yes |
| `value` | alias: parameters | vocabulary.dart NotationVocabulary.core.parameters[Barcode] | data (on Barcode) |  | 286 (135) | 3 runs, 44 q4 | 9 | open full | yes |
| `BottomBar` | alias: type | vocabulary.dart NotationVocabulary.core.types | Footer | column divider text | 0 (0) |  | 0 |  | yes |
| `BottomDock` | alias: type | vocabulary.dart NotationVocabulary.core.types | Footer | column divider text | 0 (0) |  | 0 |  | yes |
| `CalendarMonth` | alias: type | vocabulary.dart NotationVocabulary.core.types | Calendar | calendar | 1 (1) |  | 0 |  | yes |
| `FooterBar` | alias: type | vocabulary.dart NotationVocabulary.core.types | Footer | column divider text | 0 (0) |  | 0 |  | yes |
| `Highlight` | alias: type | vocabulary.dart NotationVocabulary.core.types | Text {match: mark, query: mark} | text | 5 (2) |  | 0 |  | yes |
| `HighlightText` | alias: type | vocabulary.dart NotationVocabulary.core.types | Text {match: mark, query: mark} | text | 2 (1) | 2 runs, 6 | 0 |  | yes |
| `MiniCalendar` | alias: type | vocabulary.dart NotationVocabulary.core.types | Calendar | calendar | 3 (1) |  | 0 |  | yes |
| `MonthGrid` | alias: type | vocabulary.dart NotationVocabulary.core.types | Calendar | calendar | 1 (1) |  | 0 |  | yes |
| `QRCode` | alias: type | vocabulary.dart NotationVocabulary.core.types | Barcode symbology=qrCode | barcode | 8 (8) |  | 0 |  | yes |
| `QrCode` | alias: type | vocabulary.dart NotationVocabulary.core.types | Barcode symbology=qrCode | barcode | 0 (0) |  | 0 |  | yes |
| `RangeSlider` | alias: type | vocabulary.dart NotationVocabulary.core.types | Slider (with low, high) {start: low, end: high, rangeEnd: high} | slider | 8 (7) | 3 runs, 5 | 0 |  | yes |
| `StickyBar` | alias: type | vocabulary.dart NotationVocabulary.core.types | Footer | column divider text | 2 (1) |  | 0 |  | yes |
| `StickyFooter` | alias: type | vocabulary.dart NotationVocabulary.core.types | Footer | column divider text | 0 (0) |  | 0 |  | yes |
| `unfocus` | alias: verb | notation.dart notationVerbAliases | blur |  | 0 (0) |  | 0 |  | yes |
| `animate` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 416 (183) |  | 1 | open full | yes |
| `animation` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 | full | yes |
| `bind` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  | yes |
| `border` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 163 (90) |  q20 | 16 | open full | yes |
| `border-b` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  |  |
| `border-bottom` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 158 (83) |  q13 | 6 | open full | yes |
| `border-color` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 3 (3) |  | 0 |  |  |
| `border-l` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  |  |
| `border-left` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 25 (20) |  | 4 | open full | yes |
| `border-r` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  |  |
| `border-right` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 11 (6) |  q2 | 6 | open full | yes |
| `border-t` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  |  |
| `border-top` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 23 (21) |  q6 | 1 | open full | yes |
| `border-width` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 1 (1) |  | 0 |  |  |
| `borderBottom` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  |  |
| `borderColor` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  | yes |
| `borderLeft` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  |  |
| `borderRight` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  |  |
| `borderSize` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  |  |
| `borderTop` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  |  |
| `borderWidth` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  | yes |
| `delay` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 18 (11) | 1 runs, 4 | 0 | open full | yes |
| `drag` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 176 (98) |  | 1 | open full | yes |
| `drop` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 120 (83) |  | 1 | open full | yes |
| `duration` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 77 (56) | 1 runs, 4 | 8 | open full | yes |
| `enter` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  | yes |
| `fill` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 1079 (298) | 1 runs, 2 q227 | 110 | open full | yes |
| `gradient` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 1 (1) |  | 2 |  | yes |
| `hidden` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 272 (97) | 1 runs, 2 | 5 | open full | yes |
| `hide` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 163 (66) | 4 runs, 467 q47 | 10 | open full | yes |
| `id` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 67 (44) |  q1 | 2 | open full | yes |
| `max-width` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  |  |
| `maxw` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 219 (141) | 1 runs, 22 q16 | 0 | open full | yes |
| `maxwidth` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 0 (0) |  | 0 |  |  |
| `menu` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 89 (78) |  | 0 | open full | yes |
| `preview` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 4 (3) |  | 0 | full | yes |
| `selected` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 2796 (414) | 2 runs, 11 q91 | 26 | open full | yes |
| `show` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 44 (20) | 4 runs, 85 q19 | 0 | open full | yes |
| `stagger` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 51 (42) |  | 0 | open full | yes |
| `stroke` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 3 (3) |  q88 | 3 |  | yes |
| `strokeColor` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 3 (3) |  | 0 |  | yes |
| `strokeWidth` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 2 (2) |  q86 | 6 |  | yes |
| `swipe` | parser word | keys.dart _words | a key the parser reads itself on any type |  | 1 (1) |  | 0 | open full | yes |
| `autofocus` | universal word | universal.dart notationUniversal | has the keyboard's focus when the page opens |  | 34 (17) |  q1 | 0 |  | yes |
| `color` | universal word | universal.dart notationUniversal | its main ink: a text's or an icon's colour, a control's accent, on a container the ink of what is written in it |  | 1471 (298) | 15 runs, 226 q302 | 104 | open full | yes |
| `disabled` | universal word | universal.dart notationUniversal | another name of enabled |  | 193 (81) | 1 runs, 4 q1 | 0 | full | yes |
| `enabled` | universal word | universal.dart notationUniversal | false (or disabled): takes no input, drawn as disabled |  | 3 (2) | 3 runs, 31 | 5 |  | yes |
| `handle` | universal word | universal.dart notationUniversal | with reorder: its rows are dragged by their Handle |  | 11 (5) | 3 runs, 10 | 0 |  | yes |
| `icon` | universal word | universal.dart notationUniversal | a leading icon on what has a label |  | 7960 (439) | 1 runs, 11 q133 | 14 | open full | yes |
| `onDelete` | universal word | universal.dart notationUniversal | another name of onRemove |  | 11 (11) |  | 0 |  | yes |
| `onRemove` | universal word | universal.dart notationUniversal | its x was pressed (or Delete on a chip) |  | 10 (9) | 11 runs, 20 | 2 |  | yes |
| `onReorder` | universal word | universal.dart notationUniversal | after a move: result is the list in its new order |  | 15 (10) | 4 runs, 9 | 0 |  | yes |
| `onSelect` | universal word | universal.dart notationUniversal | after the selection changes: result is the selection |  | 98 (76) | 1 runs, 29 | 0 |  | yes |
| `readOnly` | universal word | universal.dart notationUniversal | another name of readonly |  | 0 (0) |  | 2 |  | yes |
| `readonly` | universal word | universal.dart notationUniversal | shows its value and takes no input |  | 23 (17) | 3 runs, 7 | 0 |  | yes |
| `removable` | universal word | universal.dart notationUniversal | a small x that fires onRemove |  | 6 (6) | 11 runs, 20 | 0 |  | yes |
| `reorder` | universal word | universal.dart notationUniversal | its rows are dragged (or moved by Alt and the arrows) into a new order, written to the list variable the each runs over (over a formula: onReorder); between lists: a ListView with reorder.group and reorder.listKey |  | 7 (4) | 4 runs, 9 | 2 | full | yes |
| `reorderable` | universal word | universal.dart notationUniversal | another name of reorder |  | 1 (1) |  | 0 | full | yes |
| `required` | universal word | universal.dart notationUniversal | its label marked, and an input checks it is not empty |  | 5 (3) | 24 runs, 118 | 3 |  | yes |
| `selectable` | universal word | universal.dart notationUniversal | its rows are chosen: a tap alone, Ctrl or Cmd adds, Shift takes a range, Ctrl or Cmd A all; kept in selected=@list |  | 6 (5) | 2 runs, 2 | 1 |  | yes |
| `size` | universal word | universal.dart notationUniversal | small, medium or large: a step of the theme's scale (a number where the type takes one) |  | 2182 (385) | 8 runs, 34 q271 | 95 | open full | yes |
| `sortable` | universal word | universal.dart notationUniversal | another name of reorder |  | 14 (5) |  | 0 |  | yes |

## Kind d: design system: a component or a defined word (data)

| word | category | declared | stands for | expands to | corpus uses (answers) | round 10 | reference uses | taught | documented |
|---|---|---|---|---|---|---|---|---|---|
| `Breadcrumbs` | alias of a design system | design_systems/cards/vocabulary.json | Breadcrumb |  | 0 (0) |  | 0 |  |  |
| `Camera` | alias of a design system | design_systems/cards/vocabulary.json | CameraView |  | 5 (5) |  | 0 |  |  |
| `Map` | alias of a design system | design_systems/cards/vocabulary.json | MapView |  | 31 (23) |  | 0 |  | yes |
| `Signature` | alias of a design system | design_systems/cards/vocabulary.json | SignaturePad |  | 0 (0) |  | 0 |  | yes |
| `StarRating` | alias of a design system | design_systems/cards/vocabulary.json | Rating |  | 6 (2) |  | 0 |  |  |
| `Account` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `ActionButton` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `ActionListItem` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Actions` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 | open full | yes |
| `AddButton` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `AddContextMenu` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `AgentChip` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ArticleHeader` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `AuthInput` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `AuthPromptBanner` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Avatar` | component | design_systems/{cards,desk,harbor,paper,skip,ssui}/components |  |  | 317 (147) |  q3 | 1 | open full | yes |
| `AvatarGroup` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `BackButton` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 4 (2) |  | 0 |  |  |
| `Badge` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 1754 (383) |  | 1 | open full | yes |
| `Banner` | component | design_systems/{cards,desk,harbor,paper,skip,ssui}/components |  |  | 28 (17) |  | 0 |  |  |
| `BatchProgressBar` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `BeforeAfter` | component | design_systems/{cards}/components |  |  | 5 (4) |  | 0 |  |  |
| `BigButton` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  |  |
| `BoardColumn` | component | design_systems/{cards,desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `Brand` | component | design_systems/{desk}/components |  |  | 1329 (430) |  q23 | 2 | open full | yes |
| `Breadcrumb` | component | design_systems/{cards,desk,harbor,paper,skip,ssui}/components |  |  | 3 (3) | 2 runs, 26 | 0 |  |  |
| `BrowserTabs` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `BulkBar` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `Button` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 5471 (442) |  q29 | 41 | open full | yes |
| `CallToAction` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `Callout` | component | design_systems/{cards}/components |  |  | 1 (1) |  | 0 |  |  |
| `CanvasShell` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Card` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 3560 (435) |  q2 | 1 | open full | yes |
| `CardActions` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Carousel` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `CartLine` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `ChartCard` | component | design_systems/{cards,skip}/components |  |  | 0 (0) |  | 0 |  |  |
| `ChatCard` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `Checkbox` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 152 (98) |  | 4 | open full | yes |
| `Checklist` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `Chip` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 231 (118) |  q1 | 4 | open full | yes |
| `ChipTabs` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 1 (1) |  | 0 |  |  |
| `ChoiceChips` | component | design_systems/{cards}/components |  |  | 1 (1) |  | 0 |  |  |
| `CloudSyncIndicator` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `CodeBlock` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 9 (6) | 1 runs, 10 | 0 |  |  |
| `CodePreview` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `CodeSample` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `CollapsibleSection` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ColorInput` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Combobox` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 1 (1) |  | 0 |  |  |
| `CommandPalette` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `CompactAppBar` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `CompactSuggestionReviewItem` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ComparisonTable` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `ConnectionStatus` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ContextMenu` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ConversationRow` | component | design_systems/{cards}/components |  |  | 1 (1) |  | 0 |  |  |
| `CopyButton` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `CountBadge` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 2 (2) |  | 0 |  |  |
| `Counter` | component | design_systems/{cards}/components |  |  | 1 (1) |  | 0 |  | yes |
| `DateTimelineAxis` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `DayHeader` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `DayPicker` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `Details` | component | design_systems/{cards}/components |  |  | 0 (0) | 1 runs, 4 | 0 |  | yes |
| `Dialog` | component | design_systems/{cards,desk,harbor,paper,skip,ssui}/components |  |  | 906 (398) |  | 4 | open full | yes |
| `DiffHunk` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `DiffStatsBadge` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `DiffViewer` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Disclosure` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `DocsNav` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `DocumentItem` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `DownloadButton` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 1 (1) |  | 0 |  |  |
| `DropdownMultiselect` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Empty` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  | yes |
| `EmptyState` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 27 (15) | 1 runs, 8 | 0 |  |  |
| `ErrorBar` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ExtensionChipsInput` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `FaqItem` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `FeatureBulletItem` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `FeatureCard` | component | design_systems/{cards}/components |  |  | 0 (0) | 1 runs, 6 | 0 |  |  |
| `Field` | component | design_systems/{cards,desk,harbor,paper,skip,ssui}/components |  |  | 14 (1) |  | 0 |  | yes |
| `FileListItem` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `FileMetadataCard` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 1 (1) |  | 0 |  |  |
| `FileTile` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `FileTree` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 1 (1) |  | 0 |  |  |
| `FileTreeContextMenu` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `FileUploader` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 2 (2) |  | 0 |  |  |
| `FilterBar` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  | yes |
| `FilterButton` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `FilterLegend` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `FlightOption` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `FolderCard` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `FormSection` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `FullWidthSearchInput` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `HeaderSearchInput` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Hero` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  | yes |
| `HeroSession` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  |  |
| `HierarchicalPicker` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `HistoryTimeline` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Hyperlink` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `IconBox` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `IconButton` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 1629 (388) |  q46 | 3 | open full | yes |
| `IconSegmentedControl` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `IconSelect` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Illustration` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  |  |
| `ImageGallery` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ImageUpload` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 1 (1) |  | 0 |  |  |
| `InlineStat` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 6 (2) |  | 0 |  |  |
| `InputField` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `ItineraryStop` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `KeyCap` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `ListGroup` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `ListRow` | component | design_systems/{cards,desk,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `LoadMore` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `LogoStrip` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `MapPanel` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `Media` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  | yes |
| `MenuButton` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `MenuItem` | component | design_systems/{cards,desk,harbor,paper,skip,ssui}/components |  |  | 818 (209) |  | 0 | open full | yes |
| `MenuPopover` | component | design_systems/{cards,desk,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `MetaInfo` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ModelAvatarStack` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ModelSelectMenu` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `MultiSelectDropdown` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `NavItem` | component | design_systems/{desk}/components |  |  | 3827 (386) |  q103 | 8 | open full | yes |
| `NavSection` | component | design_systems/{desk}/components |  |  | 0 (0) | 9 runs, 17 q36 | 2 |  | yes |
| `NavigationMenu` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `NestedTaskLedger` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `NotePopover` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `NotificationBadge` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `NumberInput` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) | 1 runs, 4 q3 | 1 |  | yes |
| `NumberPresetInput` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `OnboardingBanner` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `OptionIcon` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `OptionList` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `PageControl` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `PageDots` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `PageHeader` | component | design_systems/{cards,desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `Pager` | component | design_systems/{cards,desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `PaneHeader` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `PaneToolbar` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Panel` | component | design_systems/{cards,desk,harbor,paper,skip,ssui}/components |  |  | 5 (1) |  | 0 |  | yes |
| `Paragraph` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `PersonChip` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `PhotoGallery` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `PlaceRow` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `PlanStep` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `PostCard` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `PricingPlan` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `ProductTile` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `ProgressBar` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 2 (2) |  | 0 |  |  |
| `ProgressGoal` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  |  |
| `ProgressLine` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `ProjectSelector` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `PromptBanner` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `PromptInput` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `PromptInputWithBanner` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Property` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  | yes |
| `ProviderCard` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ProviderIcon` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ProviderPill` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `PulsingDots` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `RadialProgress` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Radio` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 44 (19) |  | 2 | open full | yes |
| `Rating` | component | design_systems/{cards}/components |  |  | 31 (22) |  | 0 |  |  |
| `Receipt` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `Recommendation` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `RecordCard` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  |  |
| `ReorderGhost` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ReorderableList` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 8 (7) |  | 0 |  |  |
| `ResizableRow` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ResourceCard` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ResourceChip` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `RichTextField` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `RichTextToolbar` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `RunHistoryList` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `RunRecordRow` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `RunningIndicator` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `SaveBar` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `Screen` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  | yes |
| `ScrollToBottomFAB` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `SearchBar` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 2 (2) |  | 0 |  |  |
| `SearchField` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `SectionCard` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `SectionCategoryHeaderFull` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `SectionHeader` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `SectionLabel` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `SectionTitle` | component | design_systems/{skip}/components |  |  | 0 (0) | 1 runs, 12 | 0 |  |  |
| `SectionToolbar` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `SegmentedControl` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 1 (1) |  | 0 |  |  |
| `Segments` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `Select` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 667 (290) |  q4 | 4 | open full | yes |
| `SelectableListRow` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Separator` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `SessionBar` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  |  |
| `SessionControls` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  |  |
| `SessionDial` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  |  |
| `SessionRow` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  |  |
| `SessionSummary` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  |  |
| `SettingRow` | component | design_systems/{cards}/components |  |  | 4 (1) |  | 0 |  |  |
| `SideButton` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 |  |  |
| `Sidebar` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 1120 (392) |  q4 | 4 | open full | yes |
| `SidebarTogglePattern` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `SiteFooter` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  | yes |
| `SiteNav` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 | open full |  |
| `Skeleton` | component | design_systems/{cards,desk,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Slider` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 386 (180) |  q7 | 4 | open full | yes |
| `SlidingPanel` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `SortMenu` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `SplitButton` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `SplitPaneTabs` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `StackedProgressBar` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Stat` | component | design_systems/{desk}/components |  |  | 0 (0) | 2 runs, 24 | 0 |  |  |
| `StatBand` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `StatCard` | component | design_systems/{cards}/components |  |  | 8 (3) |  | 0 |  |  |
| `StatTile` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 9 (1) |  | 0 |  |  |
| `StatTrio` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  |  |
| `StatsCarousel` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Status` | component | design_systems/{desk}/components |  |  | 0 (0) |  | 0 | open full | yes |
| `StatusBadge` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 9 (4) |  | 0 |  |  |
| `StatusCard` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `StatusCardList` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `StatusCategoryHeader` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `StatusDot` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 1 (1) |  | 0 |  |  |
| `StatusIndicator` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `StepIndicator` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 1 (1) |  | 0 |  |  |
| `Stepper` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 49 (25) |  | 0 |  | yes |
| `Steps` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `StreakFlame` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  |  |
| `SuggestionActionObject` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `SuggestionReviewItem` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Switch` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 10 (6) |  | 0 |  | yes |
| `TabBarWithBadges` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `TabOverflowScroll` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `TabToggle` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `TableHeader` | component | design_systems/{cards}/components |  |  | 1 (1) |  | 0 |  |  |
| `TableRow` | component | design_systems/{cards}/components |  |  | 1 (1) |  | 0 |  |  |
| `Tabs` | component | design_systems/{cards,desk,harbor,paper,skip,ssui}/components |  |  | 10 (5) |  | 0 |  | yes |
| `Tag` | component | design_systems/{desk}/components |  |  | 3 (1) |  | 0 |  |  |
| `TapPad` | component | design_systems/{skip}/components |  |  | 1 (1) |  | 0 |  |  |
| `TaskCard` | component | design_systems/{cards,desk}/components |  |  | 0 (0) |  | 0 |  | yes |
| `Terminal` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Testimonial` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `TextArea` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `TextExpandable` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `TextInput` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `TextInputLabel` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `TextItem` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ThemeToggle` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ToggleRow` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Toolbar` | component | design_systems/{cards,desk,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `Tooltip` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `TopBar` | component | design_systems/{skip}/components |  |  | 0 (0) |  | 0 |  | yes |
| `TotalBar` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `Tree` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 7 (6) |  | 0 |  |  |
| `TrialBanner` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `UpgradeButton` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `UserMenu` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `VariableContractHover` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `VariableContractList` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `ViewerDialog` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `WeatherDay` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `WeatherGlyph` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `WeatherHours` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `WeatherNow` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `WeekStrip` | component | design_systems/{skip}/components |  |  | 4 (3) |  | 0 |  |  |
| `WideScroll` | component | design_systems/{cards}/components |  |  | 0 (0) |  | 0 |  |  |
| `WindowToolbar` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `WorkspaceSwitcher` | component | design_systems/{cards,harbor,paper,skip,ssui}/components |  |  | 0 (0) |  | 0 |  |  |
| `AlbumCover` | defined word | design_systems/cards/vocabulary | AlbumCover |  | 9 (1) |  | 0 |  |  |
| `AttachmentTile` | defined word | design_systems/cards/vocabulary | AttachmentTile |  | 3 (2) |  | 0 |  |  |
| `Autocomplete` | defined word | design_systems/cards/vocabulary | Autocomplete |  | 2 (1) |  | 0 |  |  |
| `AvatarStack` | defined word | design_systems/cards/vocabulary | AvatarStack |  | 4 (3) |  | 0 |  |  |
| `CameraView` | defined word | design_systems/cards/vocabulary | CameraView |  | 9 (8) |  | 0 |  |  |
| `ChapterRail` | defined word | design_systems/cards/vocabulary | ChapterRail |  | 1 (1) |  | 0 |  |  |
| `ChapterRailItem` | defined word | design_systems/cards/vocabulary | ChapterRailItem |  | 7 (1) |  | 0 |  |  |
| `ChatBubble` | defined word | design_systems/cards/vocabulary | ChatBubble |  | 21 (13) |  | 0 |  |  |
| `CodeEditor` | defined word | design_systems/cards/vocabulary | CodeEditor |  | 4 (3) |  | 0 |  |  |
| `ColorPicker` | defined word | design_systems/cards/vocabulary | ColorPicker |  | 13 (7) |  | 0 | open |  |
| `ColorSwatch` | defined word | design_systems/cards/vocabulary | ColorSwatch |  | 6 (3) |  | 0 |  |  |
| `CommandItem` | defined word | design_systems/cards/vocabulary | CommandItem |  | 6 (1) |  | 0 |  |  |
| `CommandList` | defined word | design_systems/cards/vocabulary | CommandList |  | 1 (1) |  | 0 |  |  |
| `CommitGraph` | defined word | design_systems/cards/vocabulary | CommitGraph |  | 1 (1) |  | 0 |  |  |
| `Composer` | defined word | design_systems/cards/vocabulary | Composer |  | 1 (1) |  | 0 |  |  |
| `Countdown` | defined word | design_systems/cards/vocabulary | Countdown#timer, Countdown#seconds, Countdown#clock |  | 18 (11) |  | 0 |  |  |
| `DateDivider` | defined word | design_systems/cards/vocabulary | DateDivider |  | 2 (2) |  | 0 |  |  |
| `DateRangePicker` | defined word | design_systems/cards/vocabulary | DateRangePicker |  | 4 (3) |  | 0 |  |  |
| `Dish` | defined word | design_systems/cards/vocabulary | Dish |  | 7 (1) |  | 0 |  |  |
| `DishArt` | defined word | design_systems/cards/vocabulary | DishArt |  | 4 (1) | 2 runs, 11 q2 | 0 |  |  |
| `Dot` | defined word | design_systems/cards/vocabulary | Dot |  | 4 (4) |  | 0 |  |  |
| `Figure` | defined word | design_systems/cards/vocabulary | Figure |  | 1 (1) | 1 runs, 6 | 0 |  |  |
| `FlightProgress` | defined word | design_systems/cards/vocabulary | FlightProgress |  | 3 (3) |  | 0 |  |  |
| `FlipCard` | defined word | design_systems/cards/vocabulary | FlipCard |  | 2 (2) | 1 runs, 2 | 0 |  | yes |
| `FloorPlan` | defined word | design_systems/cards/vocabulary | FloorPlan |  | 9 (9) |  | 0 |  |  |
| `FuzzySearch` | defined word | design_systems/cards/vocabulary | FuzzySearch |  | 1 (1) | 1 runs, 2 | 0 |  |  |
| `GraphNode` | defined word | design_systems/cards/vocabulary | GraphNode |  | 1 (1) |  | 0 |  |  |
| `Group` | defined word | design_systems/cards/vocabulary | Group |  | 3 (1) |  | 0 | open | yes |
| `Head` | defined word | design_systems/cards/vocabulary | Head |  | 2 (1) |  | 0 |  |  |
| `Heatmap` | defined word | design_systems/cards/vocabulary | Heatmap |  | 1 (1) |  | 0 |  |  |
| `InfiniteList` | defined word | design_systems/cards/vocabulary | InfiniteList |  | 1 (1) |  | 0 |  |  |
| `JsonTree` | defined word | design_systems/cards/vocabulary | JsonTree |  | 1 (1) |  | 0 |  |  |
| `Kbd` | defined word | design_systems/cards/vocabulary | Kbd |  | 1 (1) |  | 0 |  |  |
| `Keyboard` | defined word | design_systems/cards/vocabulary | Keyboard |  | 4 (4) |  | 0 |  | yes |
| `Legend` | defined word | design_systems/cards/vocabulary | Legend#scale, Legend#entry |  | 5 (4) |  | 0 |  |  |
| `ListenBar` | defined word | design_systems/cards/vocabulary | ListenBar |  | 1 (1) | 1 runs, 4 | 0 |  |  |
| `LiveRegion` | defined word | design_systems/cards/vocabulary | LiveRegion |  | 1 (1) |  | 0 |  |  |
| `Lyrics` | defined word | design_systems/cards/vocabulary | Lyrics |  | 1 (1) |  | 0 |  |  |
| `MapView` | defined word | design_systems/cards/vocabulary | MapView |  | 10 (9) |  | 0 |  |  |
| `NowPlayingBar` | defined word | design_systems/cards/vocabulary | NowPlayingBar |  | 2 (1) |  | 0 |  |  |
| `PhotoGrid` | defined word | design_systems/cards/vocabulary | PhotoGrid |  | 5 (2) |  | 0 |  |  |
| `PhotoPicker` | defined word | design_systems/cards/vocabulary | PhotoPicker |  | 4 (4) |  | 0 |  |  |
| `PhotoStrip` | defined word | design_systems/cards/vocabulary | PhotoStrip |  | 1 (1) |  | 0 |  |  |
| `PianoKeyboard` | defined word | design_systems/cards/vocabulary | PianoKeyboard |  | 1 (1) |  | 0 |  |  |
| `Pill` | defined word | design_systems/cards/vocabulary | Pill |  | 1 (1) |  | 2 |  | yes |
| `Poster` | defined word | design_systems/cards/vocabulary | Poster |  | 2 (1) |  | 0 |  |  |
| `PullQuote` | defined word | design_systems/cards/vocabulary | PullQuote |  | 1 (1) | 1 runs, 2 | 0 |  |  |
| `QuoteBlock` | defined word | design_systems/cards/vocabulary | QuoteBlock |  | 2 (1) |  | 0 |  |  |
| `RangeSlider` | defined word | design_systems/cards/vocabulary | RangeSlider |  | 8 (7) | 3 runs, 5 | 0 |  | yes |
| `ReorderList` | defined word | design_systems/cards/vocabulary | ReorderList |  | 5 (3) |  | 0 |  |  |
| `RouteMap` | defined word | design_systems/cards/vocabulary | RouteMap |  | 7 (5) |  | 0 |  |  |
| `Scene` | defined word | design_systems/cards/vocabulary | Scene |  | 2 (1) |  | 0 |  |  |
| `SearchSelect` | defined word | design_systems/cards/vocabulary | SearchSelect |  | 1 (1) |  | 0 |  |  |
| `SelectionBar` | defined word | design_systems/cards/vocabulary | SelectionBar |  | 1 (1) |  | 0 |  |  |
| `SelectionToolbar` | defined word | design_systems/cards/vocabulary | SelectionToolbar |  | 1 (1) |  | 0 |  |  |
| `SignaturePad` | defined word | design_systems/cards/vocabulary | SignaturePad |  | 11 (11) |  | 0 |  |  |
| `SortableList` | defined word | design_systems/cards/vocabulary | SortableList |  | 2 (1) |  | 0 |  |  |
| `Spinner` | defined word | design_systems/cards/vocabulary | Spinner |  | 6 (2) |  | 0 |  |  |
| `SplitPane` | defined word | design_systems/cards/vocabulary | SplitPane |  | 2 (2) |  | 0 |  |  |
| `Step` | defined word | design_systems/cards/vocabulary | Step#story, Step#progress |  | 24 (2) | 1 runs, 28 | 0 |  | yes |
| `Stepper` | defined word | design_systems/cards/vocabulary | Stepper#steps |  | 49 (25) |  | 0 |  | yes |
| `StickyNote` | defined word | design_systems/cards/vocabulary | StickyNote |  | 1 (1) |  | 0 | open |  |
| `SwipeRow` | defined word | design_systems/cards/vocabulary | SwipeRow |  | 2 (2) |  | 0 |  |  |
| `Table` | defined word | design_systems/cards/vocabulary | Table#lists, Table#records, Table#rows |  | 28 (22) | 2 runs, 12 q1 | 2 |  | yes |
| `ThumbnailStrip` | defined word | design_systems/cards/vocabulary | ThumbnailStrip |  | 1 (1) |  | 0 |  |  |
| `Timeline` | defined word | design_systems/cards/vocabulary | Timeline#events, Timeline#tracks, Timeline#route |  | 54 (49) |  | 0 |  |  |
| `TimelineItem` | defined word | design_systems/cards/vocabulary | TimelineItem |  | 39 (22) |  | 0 |  |  |
| `TimelineStop` | defined word | design_systems/cards/vocabulary | TimelineStop |  | 3 (1) |  | 0 |  |  |
| `Toast` | defined word | design_systems/cards/vocabulary | Toast |  | 1 (1) |  | 0 |  |  |
| `ToggleButton` | defined word | design_systems/cards/vocabulary | ToggleButton |  | 1 (1) |  | 0 |  |  |
| `Track` | defined word | design_systems/cards/vocabulary | Track |  | 3 (2) |  | 0 |  | yes |
| `TypedAnswer` | defined word | design_systems/cards/vocabulary | TypedAnswer |  | 1 (1) |  | 0 |  |  |
| `TypingIndicator` | defined word | design_systems/cards/vocabulary | TypingIndicator |  | 5 (5) |  | 0 |  |  |
| `TypingText` | defined word | design_systems/cards/vocabulary | TypingText |  | 1 (1) |  | 0 |  |  |
| `WaterDrop` | defined word | design_systems/cards/vocabulary | WaterDrop |  | 2 (2) |  | 0 |  |  |
| `Waveform` | defined word | design_systems/cards/vocabulary | Waveform |  | 29 (20) | 1 runs, 2 | 0 |  |  |
| `WeekStrip` | defined word | design_systems/cards/vocabulary | WeekStrip |  | 4 (3) |  | 0 |  |  |
| `WordCloud` | defined word | design_systems/cards/vocabulary | WordCloud |  | 1 (1) |  | 0 |  |  |

## Kind e: short name: a node type the parser finishes with code of its own

| word | category | declared | stands for | expands to | corpus uses (answers) | round 10 | reference uses | taught | documented |
|---|---|---|---|---|---|---|---|---|---|
| `AreaChart` | short name | notation.dart notationTypes (lineChart) | lineChart | lineChart | 20 (19) |  | 0 | open full | yes |
| `Avatar` | short name | notation.dart notationTypes (column) | column | column text | 317 (147) |  q3 | 1 | open full | yes |
| `Badge` | short name | notation.dart notationTypes (row) | row | row text | 1754 (383) |  | 1 | open full | yes |
| `Box` | short name | notation.dart notationTypes (column) | column | column text | 623 (227) |  q4 | 1 | open full | yes |
| `Button` | short name | notation.dart notationTypes (filledButton) | filledButton | filledButton | 5471 (442) |  q29 | 41 | open full | yes |
| `Card` | short name | notation.dart notationTypes (column) | column | column text | 3560 (435) |  q2 | 1 | open full | yes |
| `CodeInput` | short name | notation.dart notationTypes (textField) | textField | textField | 4 (4) | 1 runs, 2 | 1 | full | yes |
| `DataTable` | short name | notation.dart notationTypes (tableView) | tableView | tableView text | 2 (2) |  | 0 | full | yes |
| `Dial` | short name | notation.dart notationTypes (radialGauge) | radialGauge | radialGauge stack text | 5 (3) |  | 0 |  | yes |
| `Donut` | short name | notation.dart notationTypes (chart) | chart | chart | 35 (34) |  | 1 | open full | yes |
| `DonutChart` | short name | notation.dart notationTypes (chart) | chart | chart | 0 (0) |  | 0 |  | yes |
| `Gauge` | short name | notation.dart notationTypes (radialGauge) | radialGauge | radialGauge stack text | 40 (27) |  | 1 | open full | yes |
| `Grid` | short name | notation.dart notationTypes (column) | column | column text | 541 (317) |  q1 | 4 | open full | yes |
| `GridView` | short name | notation.dart notationTypes (column) | column | column text | 1 (1) |  | 0 | open full | yes |
| `Handle` | short name | notation.dart notationTypes (iconButton) | iconButton | iconButton | 0 (0) |  | 1 | full | yes |
| `Image` | short name | notation.dart notationTypes (box) | box | box | 197 (98) |  q13 | 1 | open full | yes |
| `Input` | short name | notation.dart notationTypes (textField) | textField | textField | 1417 (368) |  q9 | 29 | open full | yes |
| `List` | short name | notation.dart notationTypes (column) | column | column text | 0 (0) |  | 0 | open full | yes |
| `NumberInput` | short name | notation.dart notationTypes (textField) | textField | textField | 0 (0) | 1 runs, 4 q3 | 1 |  | yes |
| `Pages` | short name | notation.dart notationTypes (pageView) | pageView | column pageView | 32 (28) |  | 2 | open full | yes |
| `Pie` | short name | notation.dart notationTypes (chart) | chart | chart | 0 (0) |  | 0 |  | yes |
| `PieChart` | short name | notation.dart notationTypes (chart) | chart | chart | 0 (0) |  | 0 |  | yes |
| `Progress` | short name | notation.dart notationTypes (progressBar) | progressBar | progressBar | 443 (276) |  | 3 | open full | yes |
| `Ring` | short name | notation.dart notationTypes (circularProgressIndicator) | circularProgressIndicator | circularProgressIndicator | 77 (65) |  | 0 | open full | yes |
| `Select` | short name | notation.dart notationTypes (dropdown) | dropdown | dropdown | 667 (290) |  q4 | 4 | open full | yes |
| `Sparkline` | short name | notation.dart notationTypes (lineChart) | lineChart | lineChart | 50 (42) |  | 0 | open full | yes |
| `Toggle` | short name | notation.dart notationTypes (switch) | switch | switch | 494 (232) |  q1 | 0 | open full | yes |
| `Wanted` | short name | notation.dart notationTypes (column) | column | column | 0 (0) |  | 0 | open full | yes |

## Declared and never written

Words of kinds a, b, c and e no answer of the first corpus, no line the round 10 harvest lists or quotes, and no example of the reference writes: candidates to drop from what is taught (a property here may still be printed by the printer).

- **a, action type** (26): `callApi`, `callFunction`, `captureScreenshot`, `closeModal`, `cloudBatch`, `cloudData`, `cloudDocuments`, `cloudFiles`, `componentEvent`, `controlDismissible`, `controlTrack`, `controlTransform`, `downloadFile`, `editText`, `forEach`, `loadCloudData`, `openLink`, `paginate`, `playSound`, `preloadImages`, `reloadCloudData`, `retryFailed`, `runScript`, `setValue`, `setVariant`, `submitForm`
- **a, draw op** (3): `arc`, `image` (taught), `points` (taught)
- **a, event** (25): `onActionError`, `onBackPressed`, `onCursorExit`, `onDeleted`, `onDragCancel`, `onDragCompleted`, `onDragEnter`, `onDragExit`, `onDropRejected`, `onEditingComplete`, `onEnterViewport`, `onEvent`, `onExitViewport`, `onFrame`, `onHoverMove`, `onImageError`, `onImageLoaded`, `onImageLoading`, `onLoad`, `onPointerDown`, `onPointerUp`, `onRefresh`, `onScrollEnd`, `onSwipeAction`, `onValueChanged`
- **a, formula function** (89): `acos`, `addHours`, `addMinutes`, `addSeconds`, `asin`, `atan`, `atan2`, `charCode`, `codeUnits`, `compact`, `currency`, `currencyDecimals`, `currencySymbol`, `day`, `daysInMonth`, `degrees`, `diffDays`, `diffHours`, `diffMinutes`, `diffSeconds`, `endsWith`, `exp`, `feetInches`, `fill`, `formatAmount`, `formatCurrency`, `formatNumber`, `formatPercent`, `formatRelative`, `fromCharCode`, `fuzzyScore`, `hypot`, `if`, `insertAt`, `interpolate`, `isAfter`, `isBefore`, `isFuture`, `isNotEmpty`, `isPast`, `isSameDay`, `isToday`, `left`, `lerpColor`, `ln`, `log`, `matchRanges`, `matchReason`, `matchRuns`, `maxBy`, `merge`, `minBy`, `minute`, `month`, `moveItems`, `newId`, `nowMs`, `number`, `obj`, `object`, `pad`, `padLeft`, `padRight`, `parseAmount`, `parseDate`, `pi`, `pick`, `plural`, `pluralCategory`, `radians`, `regexReplace`, `right`, `runs`, `second`, `seconds`, `sign`, `slug`, `tan`, `textDirection`, `textDirectionOf`, `thousands`, `timeAgo`, `titleCase`, `toMap`, `unset`, `values`, `wallTime`, `where`, `year`
- **a, grammar statement** (7): `const`, `derived`, `for` (taught), `let` (taught), `node` (taught), `primitive` (taught), `var`
- **a, grammar word (universal table)** (2): `evenly`, `padding` (taught)
- **a, node type** (27): `ActionChip`, `ActivityIndicator`, `AppBar`, `BottomNavigationBar`, `DateTimeInput`, `Dropdown`, `ElevatedButton`, `EmbeddedVideo`, `ExpansionTile`, `External`, `FilledButton`, `FloatingActionButton`, `GaugeMeter`, `InputChip`, `Modal`, `NavigationBar`, `OutlinedButton`, `PageView`, `Pagination`, `Placeholder`, `PlotChart`, `Signature`, `SinglePlaceholder`, `TextButton`, `TextField`, `VerticalDivider`, `WebView`
- **a, property** (578): `activeSide`, `activeTextColor`, `activeThumbBorderColor`, `activeThumbColor`, `activeTickMarkColor`, `activeTrackColor`, `activeTrackOutlineColor`, `alignment`, `allowImplicitScrolling`, `allowedTypes`, `allowsInlineMediaPlayback`, `alwaysScroll`, `alwaysUse24HourFormat`, `animateIn`, `animating`, `animationCurve`, `animationDuration`, `animations`, `arcFit`, `arcGlow`, `arcHeadDot`, `arcRoundCaps`, `arcStartAngle`, `arcStrokeWidth`, `arcSweepAngle`, `areaBands`, `areaBottomColor`, `areaTopColor`, `autoPlay`, `autocorrect`, `autofillHints`, `automaticallyImplyLeading`, `avatar`, `avatarColor`, `avatarSize`, `axisArrows`, `axisColor`, `axisFontFamily`, `axisFontSize`, `axisLabelColor`, `axisLabelStyle`, `axisTitleStyle`, `axisWidth`, `backdrop`, `barGap`, `barHeadroom`, `barRadius`, `barWidthFraction`, `bare` (taught), `baselineColor`, `blendMode`, `blockBack`, `borderColor`, `borderWidth`, `boundaryCount`, `breakpointMinWidth`, `builderId`, `buttonColor`, `buttonSize`, `cacheExtent`, `captionAlign`, `captionGap`, `captionLanguage`, `captionStyle`, `centerTitle`, `checkColor`, `checkmarkColor`, `childrenPadding`, `clipBehavior`, `clipFill`, `collapseAt`, `collapsedBackgroundColor`, `collapsedIconColor`, `collapsedShape`, `collapsedTextColor`, `columnWidth`, `constraints`, `content` (taught), `contentPadding`, `controlAffinity`, `controlled`, `controller`, `cornerRadius`, `cursorColor`, `cursorHeight`, `cursorRadius`, `cursorRingFill`, `cursorWidth`, `customPaint`, `dashEmpty`, `dayPrices`, `decorationColor`, `decorationStyle`, `decorationThickness`, `defaultTextStyle`, `deleteIcon`, `deleteIconColor`, `deleteIconSize`, `deniedTypes`, `destinations`, `dimUnselected`, `dimmedOpacity`, `disabledDates` (taught), `disabledOpacity`, `displayText`, `dividerColor`, `dividerEndIndent`, `dividerHeight`, `dividerIndent`, `dividerThickness`, `domainMax`, `domainMin`, `dragEdgeScroll`, `drawText`, `dropTarget`, `dropdownColor`, `edgeColor`, `edgeFade`, `edgeWidth`, `elevation`, `embed`, `emptyColor`, `emptyHeight`, `emptySelectionAllowed`, `enableFeedback`, `enableInteractiveSelection`, `endAt`, `endDotRadius`, `endField`, `endIndent`, `endLabelDecimals`, `endLabelWidth`, `ephemeral`, `errorBorderColor`, `errorBorderWidth`, `errorCorrection`, `exactFill`, `expandedAlignment`, `expandedCrossAxisAlignment`, `expands`, `extendedIconLabelSpacing`, `extendedPadding`, `extendedTextStyle`, `fillFromEnd`, `fillGaps`, `fillStartOpacity`, `fillTrack`, `fillViewport`, `firstDate`, `firstLabel`, `fitAlignment`, `fitMinY`, `flex`, `floating`, `focusColor`, `focusElevation`, `focusRingColor`, `focusRingWidth`, `fontFeatures`, `fontStyle`, `fontWeight`, `foreground`, `foregroundFills`, `gestures`, `gridAnchor`, `gridColor`, `gridLabelColor`, `gridLabelFontSize`, `gridLabelFontWeight`, `gridLabelWidth`, `gridLabels`, `gridLabelsLeft`, `gridLineColor`, `gridLineMode`, `gridLineWidth`, `gridStepX`, `gridStepY`, `headerBorderColor`, `headerBorderWidth`, `headerColor`, `heightFactor`, `hero`, `highlightElevation`, `highlightIndex`, `highlightLabelColor`, `highlightLabels`, `hintStyle`, `horizontalPadding`, `horizontalTitleGap`, `hoverColor`, `hoverElevation`, `iconAlignment`, `iconColor`, `iconDirection`, `iconDisabledColor`, `iconEnabledColor`, `iconSize`, `ignorePointer`, `inactiveThumbBorderColor`, `inactiveThumbColor`, `inactiveTickMarkColor`, `inactiveTrackColor`, `inactiveTrackOutlineColor`, `indent`, `indicatorColor`, `indicatorPadding`, `indicatorRadius`, `indicatorShape`, `indicatorSize`, `indicatorStyle`, `indicatorWeight`, `initialIndex`, `initialPage`, `initiallyExpanded`, `inkColor`, `inkWell`, `inkWidth`, `innerRadius`, `inputFormatter`, `inset`, `inverted`, `isDense`, `isEnabled`, `isLabelVisible`, `isScrollable`, `isThreeLine`, `itemAlignment`, `itemCount`, `itemExtent`, `itemImage`, `itemImageRadius`, `itemImageSize`, `itemLabel`, `itemPosition`, `keepPage`, `keyboardDecimal`, `keyboardDismissBehavior`, `keyboardSigned`, `labelAreaHeight`, `labelBackground`, `labelBehavior`, `labelColor`, `labelField`, `labelFontSize`, `labelFontWeight`, `labelFractionDigits`, `labelGap`, `labelHeight`, `labelInset`, `labelLetterSpacing`, `labelMargin`, `labelPadding`, `labelStyle`, `labelText`, `labelTextStyle`, `labelTicks`, `landscapeLayout`, `largeSize`, `lastDate`, `lastLabel`, `leadingAsset`, `leadingDistribution`, `leadingWidth`, `limitColor`, `limitPointer`, `limitStyle`, `limitWidth`, `lineEndX`, `lineWidth`, `mainAxisAlignment`, `maintainState`, `majorTickEvery`, `markerHollow`, `markerHollowColor`, `markerLabelStyle`, `markerRadius`, `maxAllowedSize`, `maxBarWidth`, `maxCount`, `maxCrossAxisExtent`, `maxY`, `mediaPlaybackRequiresUserAction`, `menuStyle`, `metadata`, `minLeadingWidth`, `minTileHeight`, `minVerticalPadding`, `minWidth`, `minWidths`, `minY`, `minorDivisions`, `minorGridColor`, `motion` (taught), `multiSelectionEnabled`, `needleClearance`, `needleColor`, `nextLabel`, `normalized`, `notchEvery`, `notchMargin`, `notched`, `nowValue`, `obscureText`, `obscuringCharacter`, `originAxes`, `overlayColor`, `overlayRadius`, `padEnds`, `padding` (taught), `pageMotion`, `pageMotionBefore`, `pageSizeLabel`, `pageSnapping`, `pagination` (taught), `paintOrder`, `particles`, `picker` (taught), `pickerTheme`, `pinHeaderRow`, `placeholderAlignment`, `placeholderColor`, `placeholderFontSize`, `placeholderFontWeight`, `placeholderLetterSpacing`, `placeholderOffset`, `placeholderPosition`, `placeholderStyle`, `plotInset`, `plotPadding`, `plotTopInset`, `previousLabel`, `primary` (taught), `progressEndColor`, `pullToRefresh`, `radioGroup`, `rangeEnd`, `referenceColor`, `referenceDashed`, `referenceLines`, `referenceWidth`, `referenceX`, `reportIntervalMs`, `reverse` (taught), `reversePaintOrder`, `rowCount`, `rowHeaderWidth`, `rowHeightKey`, `rowHoverColor`, `scaleDown`, `scaleMode`, `scaleStroke`, `scrolledUnderElevation`, `scrubEnabled`, `scrubStep`, `secondaryActiveTrackColor`, `secondaryTrackValue`, `segmentColorField`, `segmentGap`, `segmentHeight`, `selectAllOnFocus`, `selectOnHover`, `selectableMax`, `selectableMin`, `selectedBackgroundColor`, `selectedColor`, `selectedForegroundColor`, `selectedIcon`, `selectedIconColor`, `selectedIconSize`, `selectedIndex`, `selectedItemStyle`, `selectedLabelTextStyle`, `selectedRow`, `selectedRowColor`, `selectedShadows`, `selectedTileColor`, `selectedX`, `selectionColor`, `selectionDotColor`, `selectionDotRadius`, `selectionDotStrokeColor`, `selectionDotStrokeWidth`, `selectionGuides`, `selectionHaloColor`, `selectionHaloRadius`, `selectionHeightStyle`, `selectionLineColor`, `selectionLineWidth`, `selectionMax`, `selectionMin`, `selectionSeries`, `selectionStep`, `selectionTagColor`, `selectionTagStyle`, `selectionWidthStyle`, `selectionXLabel`, `selectionY`, `selectionYLabel`, `separator`, `shadowColor`, `shadows`, `shimmer` (taught), `showCaptions`, `showCheckmark`, `showCursor`, `showDividers`, `showFirstLast`, `showFullscreenButton`, `showPageNumbers`, `showPageSize`, `showPrevNext`, `showSelectedIcon`, `showSignLine`, `showSignMark`, `showSummary`, `showTarget`, `showThumb`, `showTotals`, `showTrailingIcon`, `showValueIndicator`, `showValues`, `showVideoAnnotations`, `shrinkTapTarget`, `siblingCount`, `signLineBottom`, `signLineColor`, `signLineDash`, `signLineGap`, `signLineInset`, `signLineMark`, `signLineOffset`, `signLineStyle`, `signLineWidth`, `signMarkColor`, `signMarkGap`, `signMarkIcon`, `signMarkPlacement`, `signMarkSize`, `sliceGap`, `slidingThumb`, `smallSize`, `sortAscending`, `sortColumn`, `sourceType`, `splashColor`, `splashRadius`, `squeezeChildren`, `stackGap`, `stackGapEdge`, `startAngle`, `startAt`, `startField`, `states`, `stickToEnd`, `stretchItems`, `stretchLastColumn`, `stripeColor`, `strokeAlign`, `strokeMiterLimit`, `strokeSides`, `summaryText`, `surfaceTintColor`, `sweepAngle`, `symbology`, `syncTolerance`, `tabAlignment`, `tabs` (taught), `tagBackground`, `tagTextStyle`, `targetAcross`, `targetColor`, `textAlignVertical`, `textCapitalization`, `textDirection`, `textInputAction`, `textStyle`, `thumbBorderColor`, `thumbBorderWidth`, `thumbColor`, `thumbCornerRadius`, `thumbGlowBlur`, `thumbGlowColor`, `thumbGlowSpread`, `thumbInset`, `thumbRadius`, `thumbShadows`, `thumbShape`, `thumbSize`, `thumbStrokeColor`, `thumbStrokeWidth`, `tickColor`, `tickCount`, `tickMarkRadius`, `tickMarkStyle`, `tileColor`, `tilePadding`, `titleAlignment`, `titleSpacing`, `titleTextStyle`, `toggleCurve`, `toggleDurationMs`, `toggleable`, `tonal`, `tooltipBackground`, `tooltipColor`, `tooltipLabelField`, `tooltipLabelStyle`, `tooltipShadowColor`, `tooltipTextColor`, `tooltipTitleField`, `tooltipTitleStyle`, `tooltipTrend`, `tooltipValueStyle`, `tooltipXFormat`, `tooltipYDecimals`, `tooltipYScale`, `tooltipYSuffix`, `totalsColor`, `totalsGap`, `totalsSelectedColor`, `trackColor`, `trackGap`, `trackHeight`, `trackOutlineWidth`, `trackPadding`, `trackRadius`, `trackShape`, `transformGesture`, `trimEnd`, `trimStart`, `uniformThumb`, `unselectedLabelColor`, `unselectedLabelStyle`, `useDataSource`, `valueColor`, `valueDecimals`, `valueFontSize`, `valueGap`, `valueIndicatorColor`, `valueIndicatorShape`, `valueIndicatorTextStyle`, `valueSuffix`, `verticalLines`, `videoId`, `viewProgress`, `viewportFraction`, `visualDensity`, `wrapAlignment`, `wrapCrossAlignment`, `wrapSpacing`, `xAxisHeight`, `xAxisLabelColor`, `xAxisTitle`, `xField`, `xLabelAnchor`, `xLabelEvery`, `xLabelGap`, `xLabelOffset`, `xLabels`, `xMax`, `xMin`, `xSlots`, `xTicks`, `yAxisFontFamily`, `yAxisTitle`, `yAxisWidth`, `yField`, `yLabelAffixTopOnly`, `yLabelAlign`, `yLabelPrefix`, `yLabelSuffix`, `yLines`, `yMax`, `yMin`, `yTicks`, `zeroLineColor`, `zoneOpacity`, `zoneThickness`
- **a, value: animate=** (10): `bob`, `bounce`, `fade-up`, `flash`, `slide`, `slide-down`, `slide-right`, `sway`, `wiggle`, `zoom`
- **a, value: media condition** (2): `landscape`, `mobile`
- **a, value: state** (1): `dragged` (taught)
- **b, page word** (13): `AppShell`, `Content` (taught), `H1`, `H2`, `H3`, `H4`, `Hero`, `Logo`, `NavFooter`, `SidebarFooter`, `Title`, `Wanted` (taught), `Window`
- **b, page word: bar** (5): `AppBar`, `NavBar`, `Navbar`, `TopBar`, `Topbar`
- **b, page word: group label** (5): `NavGroup`, `NavLabel`, `SidebarGroup`, `SidebarLabel`, `SidebarSection`
- **b, page word: item** (2): `NavLink`, `SidebarItem`
- **b, page word: overlay** (4): `BottomSheet`, `Dropdown`, `Modal`, `Popup`
- **b, page word: sidebar** (3): `Aside`, `SideNav`, `Sidenav`
- **c, alias: event** (3): `onChanged`, `onPressed`, `onSecondaryClick`
- **c, alias: flags** (3): `allcaps`, `persisted`, `uppercase`
- **c, alias: parameter** (10): `border-b`, `border-l`, `border-r`, `border-t`, `borderBottom`, `borderLeft`, `borderRight`, `borderTop`, `fontWeight`, `helper`
- **c, alias: parameters** (1): `maxChars`
- **c, alias: type** (5): `BottomBar`, `BottomDock`, `FooterBar`, `QrCode`, `StickyFooter`
- **c, alias: verb** (1): `unfocus`
- **c, parser word** (16): `animation` (taught), `bind`, `border-b`, `border-l`, `border-r`, `border-t`, `borderBottom`, `borderColor`, `borderLeft`, `borderRight`, `borderSize`, `borderTop`, `borderWidth`, `enter`, `max-width`, `maxwidth`
- **e, short name** (5): `DonutChart`, `List` (taught), `Pie`, `PieChart`, `Wanted` (taught)
