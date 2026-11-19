# The closure test (generated)

Written by `tool/dictionary_closure.dart` (track B, step B2; design note 23). Do not edit: run it again.

Each word below is written out in Dart by the expander today. `dictionary/<Word>.txt` writes it in the notation's `define` form, in base words only. Each use (`dictionary/uses/`) is expanded once through the code and once through the definition (the word renamed `<Word>Dict`, since a built-in word wins over a definition of its name), at 1440, 834 and 390 wide, with the open vocabulary and no design system, and the two documents are compared node by node, ids aside (`tool/dictionary/closure.dart`).

| word | | expansions the same | up to spelling | nodes the same | up to spelling |
|---|---|---|---|---|---|
| `App` | does not close | 0 of 15 | 0 | 179 of 501 | 179 |
| `Brand` | does not close | 3 of 9 | 3 | 369 of 375 | 369 |
| `ConfirmDialog` | does not close | 0 of 3 | 0 | 102 of 141 | 102 |
| `Dialog` | does not close | 0 of 15 | 0 | 123 of 676 | 123 |
| `Dots` | does not close | 3 of 9 | 3 | 597 of 609 | 597 |
| `Drawer` | does not close | 0 of 3 | 0 | 7 of 174 | 7 |
| `Footer` | does not close | 0 of 9 | 0 | 303 of 333 | 303 |
| `H1` | does not close | 3 of 6 | 3 | 27 of 30 | 27 |
| `H2` | does not close | 0 of 6 | 0 | 21 of 27 | 21 |
| `H3` | does not close | 0 of 6 | 0 | 21 of 27 | 21 |
| `Heading` | does not close | 0 of 15 | 0 | 877 of 910 | 877 |
| `IconTile` | does not close | 0 of 9 | 0 | 459 of 471 | 459 |
| `Lightbox` | does not close | 0 of 6 | 0 | 211 of 403 | 211 |
| `Link` | does not close | 6 of 12 | 6 | 728 of 739 | 728 |
| `Main` | does not close | 4 of 15 | 4 | 548 of 883 | 548 |
| `Menu` | does not close | 0 of 6 | 0 | 321 of 735 | 321 |
| `Nav` | does not close | 4 of 15 | 4 | 876 of 1143 | 876 |
| `NavItem` | does not close | 0 of 18 | 9 | 1612 of 1712 | 1647 |
| `NavSection` | does not close | 6 of 9 | 6 | 267 of 272 | 267 |
| `Page` | does not close | 0 of 9 | 0 | 359 of 608 | 359 |
| `Pane` | does not close | 0 of 18 | 0 | 1741 of 1765 | 1741 |
| `Popover` | does not close | 0 of 6 | 0 | 354 of 654 | 354 |
| `Section` | does not close | 6 of 15 | 6 | 681 of 720 | 681 |
| `Sheet` | does not close | 0 of 12 | 0 | 210 of 828 | 210 |
| `Shortcut` | does not close | 18 of 21 | 18 | 624 of 627 | 624 |
| `Sidebar` | does not close | 2 of 12 | 2 | 599 of 769 | 599 |
| `SidebarFooter` | does not close | 3 of 6 | 3 | 127 of 146 | 127 |
| `Table` | does not close | 0 of 18 | 0 | 1305 of 1680 | 1305 |
| `computed` | **closes** | 12 of 12 | 12 | 1103 of 1103 | 1103 |
| `App (family)` | does not close | 0 of 15 | 1 | 310 of 501 | 325 |
| `Page (family)` | does not close | 0 of 9 | 0 | 303 of 608 | 309 |

A use counts as the same when its two documents are equal and the definition's side has no issue the code's has not. "Nodes the same" counts the code's nodes that the definition's document has, equal, at the same place.

## By use

### App

- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @1440: 20 of 33 nodes the same; 4 differ, 9 only in the code's, 8 only in the definition's; issues: line 5:54: AppDict.txt:3: AppDict: "onEdgeSwipeRight" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop. / line 5:82: AppDict.txt:3: AppDict: "onEdgeSwipeLeft" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop.
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0; r0.body.0.props.crossAxisAlignment: "stretch" / "start"`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.flex: 1 / (none); r0.body.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.height: {"hug":0} / 0; r0.body.0.0.0.layout.padding: 16 / (none)`
- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @834: 20 of 33 nodes the same; 4 differ, 9 only in the code's, 8 only in the definition's; issues: line 5:54: AppDict.txt:3: AppDict: "onEdgeSwipeRight" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop. / line 5:82: AppDict.txt:3: AppDict: "onEdgeSwipeLeft" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop.
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0; r0.body.0.props.crossAxisAlignment: "stretch" / "start"`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.flex: 1 / (none); r0.body.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.height: {"hug":0} / 0; r0.body.0.0.0.layout.padding: 16 / (none)`
- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @390: 20 of 33 nodes the same; 4 differ, 9 only in the code's, 8 only in the definition's; issues: line 5:54: AppDict.txt:3: AppDict: "onEdgeSwipeRight" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop. / line 5:82: AppDict.txt:3: AppDict: "onEdgeSwipeLeft" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop.
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0; r0.body.0.props.crossAxisAlignment: "stretch" / "start"`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.flex: 1 / (none); r0.body.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.height: {"hug":0} / 0; r0.body.0.0.0.layout.padding: 16 / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @1440: 17 of 63 nodes the same; 7 differ, 39 only in the code's, 16 only in the definition's; document keys roots, variables
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.0.0.layout.padding: [8,6,8,10] / (none)`
  - `r0.body.0.0.1.props.style.fontSize: 15 / 17`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @834: 17 of 63 nodes the same; 7 differ, 39 only in the code's, 16 only in the definition's; document keys roots, variables
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.0.0.layout.padding: [8,6,8,10] / (none)`
  - `r0.body.0.0.1.props.style.fontSize: 15 / 17`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @390: 17 of 41 nodes the same; 7 differ, 17 only in the code's, 16 only in the definition's
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.0.0.layout.padding: [8,6,8,10] / (none)`
  - `r0.body.0.0.1.props.style.fontSize: 15 / 17`
- tool/vocabulary/corpus/b09/answers/tractor-guidance.txt ### Implement @1440: 5 of 41 nodes the same; 4 differ, 32 only in the code's, 31 only in the definition's; issues: line 7:36: AppDict.txt:3: AppDict: "theme" is not a parameter the notation has.
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.0.0.layout.padding: [24,14,24,14] / (none); r0.body.0.0.media: [{"maxWidth":699,"patch":{"props":{"spacing":12}}}] / (none); r0.body.0.0.props.spacing: 24 / 16`
  - `r0.body.0.0.0.1.props.style.fontSize: 13 / 18`
- tool/vocabulary/corpus/b09/answers/tractor-guidance.txt ### Implement @834: 5 of 41 nodes the same; 4 differ, 32 only in the code's, 31 only in the definition's; issues: line 7:36: AppDict.txt:3: AppDict: "theme" is not a parameter the notation has.
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.0.0.layout.padding: [24,14,24,14] / (none); r0.body.0.0.media: [{"maxWidth":699,"patch":{"props":{"spacing":12}}}] / (none); r0.body.0.0.props.spacing: 24 / 16`
  - `r0.body.0.0.0.1.props.style.fontSize: 13 / 18`
- tool/vocabulary/corpus/b09/answers/tractor-guidance.txt ### Implement @390: 5 of 41 nodes the same; 4 differ, 32 only in the code's, 31 only in the definition's; issues: line 7:36: AppDict.txt:3: AppDict: "theme" is not a parameter the notation has.
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.0.0.layout.padding: [24,14,24,14] / (none); r0.body.0.0.props.spacing: 24 / 16`
  - `r0.body.0.0.0.1.props.style.fontSize: 13 / 18`
- docs/reference/notation/NOTATION.md block 4 @1440: 12 of 26 nodes the same; 4 differ, 10 only in the code's, 0 only in the definition's; document keys roots
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]; r0.body.1.layout.height.fill: 0 / (none); r0.body.1.layout.height.hug: (none) / 0`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.layout.width.fill: 0 / (none)`
- docs/reference/notation/NOTATION.md block 4 @834: 12 of 26 nodes the same; 4 differ, 10 only in the code's, 0 only in the definition's; document keys roots
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]; r0.body.1.layout.height.fill: 0 / (none); r0.body.1.layout.height.hug: (none) / 0`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.layout.width.fill: 0 / (none)`
- docs/reference/notation/NOTATION.md block 4 @390: 13 of 16 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.1.layout.height.fill: 0 / (none); r0.body.1.layout.height.hug: (none) / 0; r0.body.1.props.scrollable: true / (none)`
  - `r0.body.2.decoration: {"strokeSides":"left","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.2.layout.height.fill: 0 / (none); r0.body.2.layout.height.hug: (none) / 0`
- docs/reference/notation/navigation.md block 3 @1440: 5 of 18 nodes the same; 3 differ, 10 only in the code's, 0 only in the definition's; document keys roots, variables
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]; r0.body.1.layout.height.fill: 0 / (none); r0.body.1.layout.height.hug: (none) / 0`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
- docs/reference/notation/navigation.md block 3 @834: 5 of 18 nodes the same; 3 differ, 10 only in the code's, 0 only in the definition's; document keys roots, variables
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]; r0.body.1.layout.height.fill: 0 / (none); r0.body.1.layout.height.hug: (none) / 0`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
- docs/reference/notation/navigation.md block 3 @390: 6 of 8 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.1.layout.height.fill: 0 / (none); r0.body.1.layout.height.hug: (none) / 0; r0.body.1.props.scrollable: true / (none)`

### Brand

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @1440: equal; issues: line 3:49: BrandDict.txt:3: BrandDict: "font" is not a parameter the notation has.
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @834: equal; issues: line 3:49: BrandDict.txt:3: BrandDict: "font" is not a parameter the notation has.
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @390: equal; issues: line 3:49: BrandDict.txt:3: BrandDict: "font" is not a parameter the notation has.
- docs/reference/notation/navigation.md block 1 @1440: 16 of 18 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.layout.padding: (none) / [8,6,8,10]`
  - `r0.body.0.0.0.1.props.style.fontSize: 17 / 15`
- docs/reference/notation/navigation.md block 1 @834: 16 of 18 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.layout.padding: (none) / [8,6,8,10]`
  - `r0.body.0.0.0.1.props.style.fontSize: 17 / 15`
- docs/reference/notation/navigation.md block 1 @390: 16 of 18 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.layout.padding: (none) / [8,6,8,10]`
  - `r0.body.0.0.0.1.props.style.fontSize: 17 / 15`
- docs/reference/notation/navigation.md block 5 @1440: equal
- docs/reference/notation/navigation.md block 5 @834: equal
- docs/reference/notation/navigation.md block 5 @390: equal

### ConfirmDialog

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/workout-tracker.txt ### Summary @1440: 34 of 47 nodes the same; 2 differ, 11 only in the code's, 10 only in the definition's; document keys roots, variables; issues: line 36:1: Nothing over this page has the id "discardAsk" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]`
  - `r0.body.0.2.4.actions: [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r1","type":"openModa... / [{"actions":[],"trigger":{"type":"click"}}]`
  - `roots: ["r0","r1"] / ["r0"]`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/workout-tracker.txt ### Summary @834: 34 of 47 nodes the same; 2 differ, 11 only in the code's, 10 only in the definition's; document keys roots, variables; issues: line 36:1: Nothing over this page has the id "discardAsk" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]`
  - `r0.body.0.2.4.actions: [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r1","type":"openModa... / [{"actions":[],"trigger":{"type":"click"}}]`
  - `roots: ["r0","r1"] / ["r0"]`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/workout-tracker.txt ### Summary @390: 34 of 47 nodes the same; 2 differ, 11 only in the code's, 10 only in the definition's; document keys roots, variables; issues: line 36:1: Nothing over this page has the id "discardAsk" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]`
  - `r0.body.0.2.4.actions: [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r1","type":"openModa... / [{"actions":[],"trigger":{"type":"click"}}]`
  - `roots: ["r0","r1"] / ["r0"]`

### Dialog

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/mail-client.txt ### Compose @1440: 0 of 33 nodes the same; 1 differ, 32 only in the code's, 32 only in the definition's; document keys roots, variables; issues: line 19:1: Nothing over this page has the id "keepDraft" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.slots: (none) / {"body":"r0.body"}`
  - `roots: ["r0","r1","r2"] / ["r0"]`
  - `variables.page_variables: [{"name":"to","type":"list","value":[]},{"name":"toText","type":"text","value":""},{"na... / (none); variables.r0: (none) / [{"name":"to","type":"list","value":[]},{"name":"toText","type":"text","value":""},{"na...`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/mail-client.txt ### Compose @834: 0 of 33 nodes the same; 1 differ, 32 only in the code's, 32 only in the definition's; document keys roots, variables; issues: line 19:1: Nothing over this page has the id "keepDraft" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.slots: (none) / {"body":"r0.body"}`
  - `roots: ["r0","r1","r2"] / ["r0"]`
  - `variables.page_variables: [{"name":"to","type":"list","value":[]},{"name":"toText","type":"text","value":""},{"na... / (none); variables.r0: (none) / [{"name":"to","type":"list","value":[]},{"name":"toText","type":"text","value":""},{"na...`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/mail-client.txt ### Compose @390: 0 of 33 nodes the same; 1 differ, 32 only in the code's, 32 only in the definition's; document keys roots, variables; issues: line 19:1: Nothing over this page has the id "keepDraft" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.slots: (none) / {"body":"r0.body"}`
  - `roots: ["r0","r1","r2"] / ["r0"]`
  - `variables.page_variables: [{"name":"to","type":"list","value":[]},{"name":"toText","type":"text","value":""},{"na... / (none); variables.r0: (none) / [{"name":"to","type":"list","value":[]},{"name":"toText","type":"text","value":""},{"na...`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Search @1440: 0 of 35 nodes the same; 1 differ, 34 only in the code's, 34 only in the definition's; document keys roots, variables
  - `r0.slots: (none) / {"body":"r0.body"}`
  - `roots: ["r0","r1"] / ["r0"]`
  - `variables.page_variables: [{"name":"pq","type":"text","value":""},{"name":"pcursor","type":"integer","value":0},{... / (none); variables.r0: (none) / [{"name":"pq","type":"text","value":""},{"name":"pcursor","type":"integer","value":0},{...`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Search @834: 0 of 35 nodes the same; 1 differ, 34 only in the code's, 34 only in the definition's; document keys roots, variables
  - `r0.slots: (none) / {"body":"r0.body"}`
  - `roots: ["r0","r1"] / ["r0"]`
  - `variables.page_variables: [{"name":"pq","type":"text","value":""},{"name":"pcursor","type":"integer","value":0},{... / (none); variables.r0: (none) / [{"name":"pq","type":"text","value":""},{"name":"pcursor","type":"integer","value":0},{...`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Search @390: 0 of 35 nodes the same; 1 differ, 34 only in the code's, 34 only in the definition's; document keys roots, variables
  - `r0.slots: (none) / {"body":"r0.body"}`
  - `roots: ["r0","r1"] / ["r0"]`
  - `variables.page_variables: [{"name":"pq","type":"text","value":""},{"name":"pcursor","type":"integer","value":0},{... / (none); variables.r0: (none) / [{"name":"pq","type":"text","value":""},{"name":"pcursor","type":"integer","value":0},{...`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/calendar-app.txt ### Month @1440: 39 of 127 nodes the same; 16 differ, 72 only in the code's, 70 only in the definition's; document keys roots, variables; issues: line 14:1: Nothing over this page has the id "event" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it. / line 25:1: Nothing over this page has the id "dayEvents" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.actions: [{"actions":[{"type":"setVariable","value":"${= today()}","variable":"cursor"},{"type":... / [{"actions":[{"type":"setVariable","value":"${= today()}","variable":"cursor"},{"type":...`
  - `r0.body.children: ["r0.body.0","r0.body.1"] / ["r0.body.0","r0.body.1","r0.body.2","r0.body.3","r0.body.4"]`
  - `r0.body.0.1.actions: [{"actions":[{"type":"setVariable","value":"${= with(with(draft,\"start\",(today())),\"... / [{"actions":[{"type":"setVariable","value":"${= with(with(draft,\"start\",(today())),\"...; r0.body.0.1.props.label: "New r2" / "New r0.body.3"`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/calendar-app.txt ### Month @834: 39 of 127 nodes the same; 16 differ, 72 only in the code's, 70 only in the definition's; document keys roots, variables; issues: line 14:1: Nothing over this page has the id "event" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it. / line 25:1: Nothing over this page has the id "dayEvents" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.actions: [{"actions":[{"type":"setVariable","value":"${= today()}","variable":"cursor"},{"type":... / [{"actions":[{"type":"setVariable","value":"${= today()}","variable":"cursor"},{"type":...`
  - `r0.body.children: ["r0.body.0","r0.body.1"] / ["r0.body.0","r0.body.1","r0.body.2","r0.body.3","r0.body.4"]`
  - `r0.body.0.1.actions: [{"actions":[{"type":"setVariable","value":"${= with(with(draft,\"start\",(today())),\"... / [{"actions":[{"type":"setVariable","value":"${= with(with(draft,\"start\",(today())),\"...; r0.body.0.1.props.label: "New r2" / "New r0.body.3"`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/calendar-app.txt ### Month @390: 39 of 102 nodes the same; 9 differ, 54 only in the code's, 52 only in the definition's; document keys roots, variables; issues: line 14:1: Nothing over this page has the id "event" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it. / line 25:1: Nothing over this page has the id "dayEvents" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.actions: [{"actions":[{"type":"setVariable","value":"${= today()}","variable":"cursor"},{"type":... / [{"actions":[{"type":"setVariable","value":"${= today()}","variable":"cursor"},{"type":...`
  - `r0.body.children: ["r0.body.0","r0.body.1"] / ["r0.body.0","r0.body.1","r0.body.2","r0.body.3","r0.body.4"]`
  - `r0.body.0.1.actions: [{"actions":[{"type":"setVariable","value":"${= with(with(draft,\"start\",(today())),\"... / [{"actions":[{"type":"setVariable","value":"${= with(with(draft,\"start\",(today())),\"...; r0.body.0.1.props.label: "New r2" / "New r0.body.3"`
- docs/reference/notation/NOTATION.md block 4 @1440: 1 of 26 nodes the same; 14 differ, 11 only in the code's, 12 only in the definition's; document keys roots; issues: line 7:1: Nothing over this page has the id "create" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2"] / ["r0.body.0","r0.body.1"]; r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1","r0.body.0.2"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.actions: [{"actions":[{"type":"setVariable","value":"home","variable":"tab"}],"trigger":{"type":... / (none); r0.body.0.0.bind: {"selected":"${= tab==\"home\"}"} / (none); r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0"]`
- docs/reference/notation/NOTATION.md block 4 @834: 1 of 26 nodes the same; 14 differ, 11 only in the code's, 12 only in the definition's; document keys roots; issues: line 7:1: Nothing over this page has the id "create" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2"] / ["r0.body.0","r0.body.1"]; r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1","r0.body.0.2"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.actions: [{"actions":[{"type":"setVariable","value":"home","variable":"tab"}],"trigger":{"type":... / (none); r0.body.0.0.bind: {"selected":"${= tab==\"home\"}"} / (none); r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0"]`
- docs/reference/notation/NOTATION.md block 4 @390: 1 of 16 nodes the same; 6 differ, 9 only in the code's, 10 only in the definition's; document keys roots, variables; issues: line 7:1: Nothing over this page has the id "create" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2"] / ["r0.body.0","r0.body.1"]; r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1","r0.body.0.2"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.actions: [{"actions":[{"type":"setVariable","value":"home","variable":"tab"}],"trigger":{"type":... / (none); r0.body.0.0.bind: {"selected":"${= tab==\"home\"}"} / (none); r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0"]`
- docs/reference/notation/NOTATION.md block 5 @1440: 1 of 16 nodes the same; 6 differ, 9 only in the code's, 10 only in the definition's; document keys roots, variables; issues: line 9:1: Nothing over this page has the id "create" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2"] / ["r0.body.0","r0.body.1"]; r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1","r0.body.0.2"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.actions: [{"actions":[{"type":"setVariable","value":"home","variable":"tab"}],"trigger":{"type":... / (none); r0.body.0.0.bind: {"selected":"${= tab==\"home\"}"} / (none); r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0"]`
- docs/reference/notation/NOTATION.md block 5 @834: 1 of 16 nodes the same; 6 differ, 9 only in the code's, 10 only in the definition's; document keys roots, variables; issues: line 9:1: Nothing over this page has the id "create" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2"] / ["r0.body.0","r0.body.1"]; r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1","r0.body.0.2"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.actions: [{"actions":[{"type":"setVariable","value":"home","variable":"tab"}],"trigger":{"type":... / (none); r0.body.0.0.bind: {"selected":"${= tab==\"home\"}"} / (none); r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0"]`
- docs/reference/notation/NOTATION.md block 5 @390: 1 of 16 nodes the same; 6 differ, 9 only in the code's, 10 only in the definition's; document keys roots, variables; issues: line 9:1: Nothing over this page has the id "create" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2"] / ["r0.body.0","r0.body.1"]; r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1","r0.body.0.2"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.actions: [{"actions":[{"type":"setVariable","value":"home","variable":"tab"}],"trigger":{"type":... / (none); r0.body.0.0.bind: {"selected":"${= tab==\"home\"}"} / (none); r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0"]`

### Dots

- tool/vocabulary/corpus/b03/answers/gym-class-booking.txt ### Schedule @1440: 110 of 112 nodes the same; 2 differ, 0 only in the code's, 2 only in the definition's; document keys variables; issues: line 56:54: DotsDict.txt:3: DotsDict: "filled" is not a parameter the notation has. / line 56:83: DotsDict.txt:3: DotsDict: "size" is not a parameter the notation has.
  - `r0.body.1.2.2.0.0.0.1.0.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.2.2.0.0.0.1.0.layout.constraints: {"minHeight":40} / (none); r0.body.1.2.2.0.0.0.1.0.layout.height: {"hug":0} / 16`
  - `r0.body.1.2.2.0.0.0.1.0.0.props.maxLines: 1 / (none); r0.body.1.2.2.0.0.0.1.0.0.props.overflow: "ellipsis" / (none); r0.body.1.2.2.0.0.0.1.0.0.props.style: {"color":"#FF9CA3AF","fontSize":11} / (none)`
  - `variables.page_variables: [{"name":"tab","type":"text","value":"schedule"},{"name":"day","type":"integer","value"... / [{"name":"tab","type":"text","value":"schedule"},{"name":"day","type":"integer","value"...`
- tool/vocabulary/corpus/b03/answers/gym-class-booking.txt ### Schedule @834: 110 of 112 nodes the same; 2 differ, 0 only in the code's, 2 only in the definition's; document keys variables; issues: line 56:54: DotsDict.txt:3: DotsDict: "filled" is not a parameter the notation has. / line 56:83: DotsDict.txt:3: DotsDict: "size" is not a parameter the notation has.
  - `r0.body.1.2.2.0.0.0.1.0.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.2.2.0.0.0.1.0.layout.constraints: {"minHeight":40} / (none); r0.body.1.2.2.0.0.0.1.0.layout.height: {"hug":0} / 16`
  - `r0.body.1.2.2.0.0.0.1.0.0.props.maxLines: 1 / (none); r0.body.1.2.2.0.0.0.1.0.0.props.overflow: "ellipsis" / (none); r0.body.1.2.2.0.0.0.1.0.0.props.style: {"color":"#FF9CA3AF","fontSize":11} / (none)`
  - `variables.page_variables: [{"name":"tab","type":"text","value":"schedule"},{"name":"day","type":"integer","value"... / [{"name":"tab","type":"text","value":"schedule"},{"name":"day","type":"integer","value"...`
- tool/vocabulary/corpus/b03/answers/gym-class-booking.txt ### Schedule @390: 86 of 88 nodes the same; 2 differ, 0 only in the code's, 2 only in the definition's; document keys variables; issues: line 56:54: DotsDict.txt:3: DotsDict: "filled" is not a parameter the notation has. / line 56:83: DotsDict.txt:3: DotsDict: "size" is not a parameter the notation has.
  - `r0.body.1.2.2.0.0.0.1.0.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.2.2.0.0.0.1.0.layout.constraints: {"minHeight":40} / (none); r0.body.1.2.2.0.0.0.1.0.layout.height: {"hug":0} / 16`
  - `r0.body.1.2.2.0.0.0.1.0.0.props.maxLines: 1 / (none); r0.body.1.2.2.0.0.0.1.0.0.props.overflow: "ellipsis" / (none); r0.body.1.2.2.0.0.0.1.0.0.props.style: {"color":"#FF9CA3AF","fontSize":11} / (none)`
  - `variables.page_variables: [{"name":"tab","type":"text","value":"schedule"},{"name":"day","type":"integer","value"... / [{"name":"tab","type":"text","value":"schedule"},{"name":"day","type":"integer","value"...`
- tool/vocabulary/corpus/b08/answers/watch-face-complications.txt ### Face gallery @1440: equal
- tool/vocabulary/corpus/b08/answers/watch-face-complications.txt ### Face gallery @834: equal
- tool/vocabulary/corpus/b08/answers/watch-face-complications.txt ### Face gallery @390: equal
- tool/vocabulary/corpus-define/d02/answers/signup-sheet.txt ### Organiser @1440: 80 of 82 nodes the same; 2 differ, 0 only in the code's, 2 only in the definition's; document keys variables; issues: line 42:54: DotsDict.txt:3: DotsDict: "needed" is not a parameter the notation has. / line 42:75: DotsDict.txt:3: DotsDict: "filled" is not a parameter the notation has.
  - `r0.body.1.2.2.1.0.0.1.0.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.2.2.1.0.0.1.0.layout.constraints: {"minHeight":40} / (none); r0.body.1.2.2.1.0.0.1.0.layout.height: {"hug":0} / 16`
  - `r0.body.1.2.2.1.0.0.1.0.0.props.maxLines: 1 / (none); r0.body.1.2.2.1.0.0.1.0.0.props.overflow: "ellipsis" / (none); r0.body.1.2.2.1.0.0.1.0.0.props.style: {"color":"#FF9CA3AF","fontSize":11} / (none)`
  - `variables.page_variables: [{"name":"shifts","type":"list","value":[{"day":"Mon","filled":4,"id":"mon-am","needed"... / [{"name":"shifts","type":"list","value":[{"day":"Mon","filled":4,"id":"mon-am","needed"...`
- tool/vocabulary/corpus-define/d02/answers/signup-sheet.txt ### Organiser @834: 80 of 82 nodes the same; 2 differ, 0 only in the code's, 2 only in the definition's; document keys variables; issues: line 42:54: DotsDict.txt:3: DotsDict: "needed" is not a parameter the notation has. / line 42:75: DotsDict.txt:3: DotsDict: "filled" is not a parameter the notation has.
  - `r0.body.1.2.2.1.0.0.1.0.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.2.2.1.0.0.1.0.layout.constraints: {"minHeight":40} / (none); r0.body.1.2.2.1.0.0.1.0.layout.height: {"hug":0} / 16`
  - `r0.body.1.2.2.1.0.0.1.0.0.props.maxLines: 1 / (none); r0.body.1.2.2.1.0.0.1.0.0.props.overflow: "ellipsis" / (none); r0.body.1.2.2.1.0.0.1.0.0.props.style: {"color":"#FF9CA3AF","fontSize":11} / (none)`
  - `variables.page_variables: [{"name":"shifts","type":"list","value":[{"day":"Mon","filled":4,"id":"mon-am","needed"... / [{"name":"shifts","type":"list","value":[{"day":"Mon","filled":4,"id":"mon-am","needed"...`
- tool/vocabulary/corpus-define/d02/answers/signup-sheet.txt ### Organiser @390: 62 of 64 nodes the same; 2 differ, 0 only in the code's, 2 only in the definition's; document keys variables; issues: line 42:54: DotsDict.txt:3: DotsDict: "needed" is not a parameter the notation has. / line 42:75: DotsDict.txt:3: DotsDict: "filled" is not a parameter the notation has.
  - `r0.body.1.2.2.1.0.0.1.0.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.2.2.1.0.0.1.0.layout.constraints: {"minHeight":40} / (none); r0.body.1.2.2.1.0.0.1.0.layout.height: {"hug":0} / 16`
  - `r0.body.1.2.2.1.0.0.1.0.0.props.maxLines: 1 / (none); r0.body.1.2.2.1.0.0.1.0.0.props.overflow: "ellipsis" / (none); r0.body.1.2.2.1.0.0.1.0.0.props.style: {"color":"#FF9CA3AF","fontSize":11} / (none)`
  - `variables.page_variables: [{"name":"shifts","type":"list","value":[{"day":"Mon","filled":4,"id":"mon-am","needed"... / [{"name":"shifts","type":"list","value":[{"day":"Mon","filled":4,"id":"mon-am","needed"...`

### Drawer

- tool/vocabulary/corpus/b09/answers/emergency-call-taker.txt ### Call log @1440: 3 of 58 nodes the same; 16 differ, 39 only in the code's, 59 only in the definition's; issues: line 26:1: Nothing over this page has the id "callDetail" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0; r0.body.type: "row" / "column"`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3","r0.body.0.4","r0.body.0.5"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0","r0.body.0.0.1","r0.body.0.0.2","r0.body.0.0.3","r0.body.0.0.4","r0.bo...; r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0`
- tool/vocabulary/corpus/b09/answers/emergency-call-taker.txt ### Call log @834: 3 of 58 nodes the same; 16 differ, 39 only in the code's, 59 only in the definition's; issues: line 26:1: Nothing over this page has the id "callDetail" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0; r0.body.type: "row" / "column"`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3","r0.body.0.4","r0.body.0.5"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0","r0.body.0.0.1","r0.body.0.0.2","r0.body.0.0.3","r0.body.0.0.4","r0.bo...; r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0`
- tool/vocabulary/corpus/b09/answers/emergency-call-taker.txt ### Call log @390: 1 of 58 nodes the same; 14 differ, 43 only in the code's, 43 only in the definition's; document keys roots, variables; issues: line 26:1: Nothing over this page has the id "callDetail" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0; r0.body.type: "row" / "column"`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3","r0.body.0.4","r0.body.0.5"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0","r0.body.0.0.1","r0.body.0.0.2","r0.body.0.0.3","r0.body.0.0.4","r0.bo...; r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0`

### Footer

- tool/vocabulary/corpus/b05/answers/news-reader.txt ### Article @1440: 76 of 84 nodes the same; 2 differ, 6 only in the code's, 7 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]`
  - `r0.body.0.1.children: ["r0.body.0.1.0","r0.body.0.1.1"] / ["r0.body.0.1.0","r0.body.0.1.1","r0.body.0.1.2"]`
  - `only in the code's: r0.body.0.2 column, r0.body.0.2.0 row, r0.body.0.2.0.0 row, r0.body.0.2.0.0.0 outlinedButton`
- tool/vocabulary/corpus/b05/answers/news-reader.txt ### Article @834: 76 of 84 nodes the same; 2 differ, 6 only in the code's, 7 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]`
  - `r0.body.0.1.children: ["r0.body.0.1.0","r0.body.0.1.1"] / ["r0.body.0.1.0","r0.body.0.1.1","r0.body.0.1.2"]`
  - `only in the code's: r0.body.0.2 column, r0.body.0.2.0 row, r0.body.0.2.0.0 row, r0.body.0.2.0.0.0 outlinedButton`
- tool/vocabulary/corpus/b05/answers/news-reader.txt ### Article @390: 76 of 84 nodes the same; 2 differ, 6 only in the code's, 7 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]`
  - `r0.body.0.1.children: ["r0.body.0.1.0","r0.body.0.1.1"] / ["r0.body.0.1.0","r0.body.0.1.1","r0.body.0.1.2"]`
  - `only in the code's: r0.body.0.2 column, r0.body.0.2.0 row, r0.body.0.2.0.0 row, r0.body.0.2.0.0.0 outlinedButton`
- docs/reference/notation/components.md block 4 @1440: 13 of 14 nodes the same; 1 differ, 0 only in the code's, 1 only in the definition's
  - `r0.body.2.layout.padding: (none) / [24,40,24,40]; r0.body.2.props.crossAxisAlignment: "start" / "center"; r0.body.2.props.spacing: 16 / (none)`
  - `only in the definition's: r0.body.2.0 column`
- docs/reference/notation/components.md block 4 @834: 13 of 14 nodes the same; 1 differ, 0 only in the code's, 1 only in the definition's
  - `r0.body.2.layout.padding: (none) / [24,40,24,40]; r0.body.2.props.crossAxisAlignment: "start" / "center"; r0.body.2.props.spacing: 16 / (none)`
  - `only in the definition's: r0.body.2.0 column`
- docs/reference/notation/components.md block 4 @390: 13 of 14 nodes the same; 1 differ, 0 only in the code's, 1 only in the definition's
  - `r0.body.2.layout.padding: (none) / [24,40,24,40]; r0.body.2.props.crossAxisAlignment: "start" / "center"; r0.body.2.props.spacing: 16 / (none)`
  - `only in the definition's: r0.body.2.0 column`
- docs/reference/notation/components.md block 5 @1440: 12 of 13 nodes the same; 1 differ, 0 only in the code's, 1 only in the definition's
  - `r0.body.2.layout.padding: (none) / [24,40,24,40]; r0.body.2.props.crossAxisAlignment: "start" / "center"; r0.body.2.props.spacing: 16 / (none)`
  - `only in the definition's: r0.body.2.0 column`
- docs/reference/notation/components.md block 5 @834: 12 of 13 nodes the same; 1 differ, 0 only in the code's, 1 only in the definition's
  - `r0.body.2.layout.padding: (none) / [24,40,24,40]; r0.body.2.props.crossAxisAlignment: "start" / "center"; r0.body.2.props.spacing: 16 / (none)`
  - `only in the definition's: r0.body.2.0 column`
- docs/reference/notation/components.md block 5 @390: 12 of 13 nodes the same; 1 differ, 0 only in the code's, 1 only in the definition's
  - `r0.body.2.layout.padding: (none) / [24,40,24,40]; r0.body.2.props.crossAxisAlignment: "start" / "center"; r0.body.2.props.spacing: 16 / (none)`
  - `only in the definition's: r0.body.2.0 column`

### H1

- written: a website's headline @1440: equal
- written: a website's headline @834: equal
- written: a website's headline @390: equal
- written: an app's page title @1440: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 20 / 30; r0.body.0.0.props.style.fontWeight: 600 / 700`
- written: an app's page title @834: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 20 / 30; r0.body.0.0.props.style.fontWeight: 600 / 700`
- written: an app's page title @390: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 20 / 30; r0.body.0.0.props.style.fontWeight: 600 / 700`

### H2

- written: a website section's title @1440: 4 of 5 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.media: [{"maxWidth":699,"patch":{"props":{"style":{"fontSize":26}}}}] / (none); r0.body.0.0.0.props.style.fontSize: 36 / 24`
- written: a website section's title @834: 4 of 5 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.media: [{"maxWidth":699,"patch":{"props":{"style":{"fontSize":26}}}}] / (none); r0.body.0.0.0.props.style.fontSize: 36 / 24`
- written: a website section's title @390: 4 of 5 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.props.style.fontSize: 36 / 24`
- written: a panel's heading in an app @1440: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 14 / 24; r0.body.0.0.props.style.fontWeight: 600 / 700`
- written: a panel's heading in an app @834: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 14 / 24; r0.body.0.0.props.style.fontWeight: 600 / 700`
- written: a panel's heading in an app @390: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 14 / 24; r0.body.0.0.props.style.fontWeight: 600 / 700`

### H3

- written: a small title on a website @1440: 4 of 5 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.props.style.fontSize: 22 / 18`
- written: a small title on a website @834: 4 of 5 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.props.style.fontSize: 22 / 18`
- written: a small title on a website @390: 4 of 5 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.props.style.fontSize: 22 / 18`
- written: a strong line in an app @1440: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 13 / 18`
- written: a strong line in an app @834: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 13 / 18`
- written: a strong line in an app @390: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 13 / 18`

### Heading

- tool/vocabulary/corpus-define/d02/answers/kiosk-museum-touch.txt ### Attract @1440: 12 of 13 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.1.0.media: [{"maxWidth":1023,"patch":{"props":{"style":{"fontSize":52}}}},{"maxWidth":699,"patch":... / (none); r0.body.0.0.0.1.0.props.style.fontSize: 60 / 18; r0.body.0.0.0.1.0.props.style.fontWeight: 700 / 600`
- tool/vocabulary/corpus-define/d02/answers/kiosk-museum-touch.txt ### Attract @834: 12 of 13 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.1.0.media: [{"maxWidth":1023,"patch":{"props":{"style":{"fontSize":52}}}},{"maxWidth":699,"patch":... / (none); r0.body.0.0.0.1.0.props.style.fontSize: 60 / 18; r0.body.0.0.0.1.0.props.style.fontWeight: 700 / 600`
- tool/vocabulary/corpus-define/d02/answers/kiosk-museum-touch.txt ### Attract @390: 12 of 13 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.1.0.props.style.fontSize: 60 / 18; r0.body.0.0.0.1.0.props.style.fontWeight: 700 / 600`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/seat-booking.txt ### Sold-out performance @1440: 24 of 26 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.1.media: [{"maxWidth":1023,"patch":{"props":{"style":{"fontSize":52}}}},{"maxWidth":699,"patch":... / (none); r0.body.2.0.0.1.props.style.fontFamily: "serif" / (none); r0.body.2.0.0.1.props.style.fontSize: 60 / 18`
  - `r0.body.2.0.0.5.layout.height: 44.0 / 40.0`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/seat-booking.txt ### Sold-out performance @834: 24 of 26 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.1.media: [{"maxWidth":1023,"patch":{"props":{"style":{"fontSize":52}}}},{"maxWidth":699,"patch":... / (none); r0.body.2.0.0.1.props.style.fontFamily: "serif" / (none); r0.body.2.0.0.1.props.style.fontSize: 60 / 18`
  - `r0.body.2.0.0.5.layout.height: 44.0 / 40.0`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/seat-booking.txt ### Sold-out performance @390: 24 of 26 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.1.props.style.fontFamily: "serif" / (none); r0.body.2.0.0.1.props.style.fontSize: 60 / 18; r0.body.2.0.0.1.props.style.fontWeight: 700 / 600`
  - `r0.body.2.0.0.5.layout.height: 44.0 / 40.0`
- tool/vocabulary/corpus/b04/answers/exam-quiz.txt ### Result @1440: 83 of 85 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.2.1.0.props.style.fontSize: 13 / 18`
  - `r0.body.1.2.2.props.style.fontSize: 14 / 18`
- tool/vocabulary/corpus/b04/answers/exam-quiz.txt ### Result @834: 83 of 85 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.2.1.0.props.style.fontSize: 13 / 18`
  - `r0.body.1.2.2.props.style.fontSize: 14 / 18`
- tool/vocabulary/corpus/b04/answers/exam-quiz.txt ### Result @390: 66 of 68 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.2.1.0.props.style.fontSize: 13 / 18`
  - `r0.body.1.2.2.props.style.fontSize: 14 / 18`
- tool/vocabulary/corpus/b09/answers/memory-book.txt ### Scrapbook @1440: 171 of 176 nodes the same; 5 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.2.0.1.0.0.props.style.fontSize: 13 / 18`
  - `r0.body.1.2.0.1.1.0.props.style.fontSize: 13 / 18`
  - `r0.body.1.2.1.0.props.style.fontSize: 13 / 18`
- tool/vocabulary/corpus/b09/answers/memory-book.txt ### Scrapbook @834: 171 of 176 nodes the same; 5 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.2.0.1.0.0.props.style.fontSize: 13 / 18`
  - `r0.body.1.2.0.1.1.0.props.style.fontSize: 13 / 18`
  - `r0.body.1.2.1.0.props.style.fontSize: 13 / 18`
- tool/vocabulary/corpus/b09/answers/memory-book.txt ### Scrapbook @390: 144 of 149 nodes the same; 5 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.2.0.1.0.0.props.style.fontSize: 13 / 18`
  - `r0.body.1.2.0.1.1.0.props.style.fontSize: 13 / 18`
  - `r0.body.1.2.1.0.props.style.fontSize: 13 / 18`
- docs/reference/notation/navigation.md block 1 @1440: 17 of 18 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.media: [{"maxWidth":1023,"patch":{"props":{"style":{"fontSize":52}}}},{"maxWidth":699,"patch":... / (none); r0.body.2.0.0.props.style.fontSize: 60 / 18; r0.body.2.0.0.props.style.fontWeight: 700 / 600`
- docs/reference/notation/navigation.md block 1 @834: 17 of 18 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.media: [{"maxWidth":1023,"patch":{"props":{"style":{"fontSize":52}}}},{"maxWidth":699,"patch":... / (none); r0.body.2.0.0.props.style.fontSize: 60 / 18; r0.body.2.0.0.props.style.fontWeight: 700 / 600`
- docs/reference/notation/navigation.md block 1 @390: 17 of 18 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.props.style.fontSize: 60 / 18; r0.body.2.0.0.props.style.fontWeight: 700 / 600`

### IconTile

- tool/vocabulary/corpus/b01/answers/habit-tracker.txt ### New habit @1440: 41 of 42 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.5.0.0.0.bind.props.icon: "${icon}" / "${= coalesce((icon),\"star\")}"`
- tool/vocabulary/corpus/b01/answers/habit-tracker.txt ### New habit @834: 41 of 42 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.5.0.0.0.bind.props.icon: "${icon}" / "${= coalesce((icon),\"star\")}"`
- tool/vocabulary/corpus/b01/answers/habit-tracker.txt ### New habit @390: 41 of 42 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.5.0.0.0.bind.props.icon: "${icon}" / "${= coalesce((icon),\"star\")}"`
- tool/vocabulary/corpus/b07/answers/tower-defense-map.txt ### Wave Summary @1440: 33 of 36 nodes the same; 2 differ, 1 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.4.0.0.0.0.children: ["r0.body.2.0.0.4.0.0.0.0.0","r0.body.2.0.0.4.0.0.0.0.1"] / ["r0.body.2.0.0.4.0.0.0.0.0"]`
  - `r0.body.2.0.0.4.0.0.0.0.0.layout.width.fill: 0 / (none); r0.body.2.0.0.4.0.0.0.0.0.layout.width.hug: (none) / 0; r0.body.2.0.0.4.0.0.0.0.0.props.style: {"color":"#FF111827","fontSize":13} / (none)`
  - `only in the code's: r0.body.2.0.0.4.0.0.0.0.1 icon`
- tool/vocabulary/corpus/b07/answers/tower-defense-map.txt ### Wave Summary @834: 33 of 36 nodes the same; 2 differ, 1 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.4.0.0.0.0.children: ["r0.body.2.0.0.4.0.0.0.0.0","r0.body.2.0.0.4.0.0.0.0.1"] / ["r0.body.2.0.0.4.0.0.0.0.0"]`
  - `r0.body.2.0.0.4.0.0.0.0.0.layout.width.fill: 0 / (none); r0.body.2.0.0.4.0.0.0.0.0.layout.width.hug: (none) / 0; r0.body.2.0.0.4.0.0.0.0.0.props.style: {"color":"#FF111827","fontSize":13} / (none)`
  - `only in the code's: r0.body.2.0.0.4.0.0.0.0.1 icon`
- tool/vocabulary/corpus/b07/answers/tower-defense-map.txt ### Wave Summary @390: 33 of 36 nodes the same; 2 differ, 1 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.4.0.0.0.0.children: ["r0.body.2.0.0.4.0.0.0.0.0","r0.body.2.0.0.4.0.0.0.0.1"] / ["r0.body.2.0.0.4.0.0.0.0.0"]`
  - `r0.body.2.0.0.4.0.0.0.0.0.layout.width.fill: 0 / (none); r0.body.2.0.0.4.0.0.0.0.0.layout.width.hug: (none) / 0; r0.body.2.0.0.4.0.0.0.0.0.props.style: {"color":"#FF111827","fontSize":13} / (none)`
  - `only in the code's: r0.body.2.0.0.4.0.0.0.0.1 icon`
- tool/vocabulary/corpus-define/d02/answers/tower-defense-map.txt ### Battle @1440: equal; issues: line 48:76: IconTileDict.txt:3: A value shown as text is written in a string: "{t.icon}".
- tool/vocabulary/corpus-define/d02/answers/tower-defense-map.txt ### Battle @834: equal; issues: line 48:76: IconTileDict.txt:3: A value shown as text is written in a string: "{t.icon}".
- tool/vocabulary/corpus-define/d02/answers/tower-defense-map.txt ### Battle @390: equal; issues: line 48:76: IconTileDict.txt:3: A value shown as text is written in a string: "{t.icon}".

### Lightbox

- tool/vocabulary/corpus/b09/answers/scope-trace.txt ### Saved traces @1440: 32 of 78 nodes the same; 14 differ, 32 only in the code's, 10 only in the definition's; document keys roots, variables; issues: line 17:1: Nothing over this page has the id "zoom" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0","r0.body.1"] / ["r0.body.0","r0.body.1","r0.body.2"]`
  - `r0.body.1.0.0.actions: [{"actions":[{"cover":true,"presentation":"dialog","to":"r2","type":"openModal"}],"trig... / [{"actions":[{"cover":true,"presentation":"dialog","to":"r1","type":"openModal"}],"trig...`
  - `r0.body.1.2.0.0.0.0.0.actions: [{"actions":[{"type":"setVariable","value":"${= index}","variable":"sel"},{"barrierColo... / [{"actions":[{"type":"setVariable","value":"${= index}","variable":"sel"}],"trigger":{"...`
- tool/vocabulary/corpus/b09/answers/scope-trace.txt ### Saved traces @834: 32 of 78 nodes the same; 14 differ, 32 only in the code's, 10 only in the definition's; document keys roots, variables; issues: line 17:1: Nothing over this page has the id "zoom" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0","r0.body.1"] / ["r0.body.0","r0.body.1","r0.body.2"]`
  - `r0.body.1.0.0.actions: [{"actions":[{"cover":true,"presentation":"dialog","to":"r2","type":"openModal"}],"trig... / [{"actions":[{"cover":true,"presentation":"dialog","to":"r1","type":"openModal"}],"trig...`
  - `r0.body.1.2.0.0.0.0.0.actions: [{"actions":[{"type":"setVariable","value":"${= index}","variable":"sel"},{"barrierColo... / [{"actions":[{"type":"setVariable","value":"${= index}","variable":"sel"}],"trigger":{"...`
- tool/vocabulary/corpus/b09/answers/scope-trace.txt ### Saved traces @390: 31 of 59 nodes the same; 2 differ, 26 only in the code's, 4 only in the definition's; document keys roots, variables; issues: line 17:1: Nothing over this page has the id "zoom" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0","r0.body.1"] / ["r0.body.0","r0.body.1","r0.body.2"]`
  - `r0.body.1.2.0.0.0.0.0.actions: [{"actions":[{"type":"setVariable","value":"${= index}","variable":"sel"},{"barrierColo... / [{"actions":[{"type":"setVariable","value":"${= index}","variable":"sel"}],"trigger":{"...`
  - `roots: ["r0","r1"] / ["r0"]`
- tool/vocabulary/corpus/b09/answers/company-timeline.txt ### Event story @1440: 39 of 68 nodes the same; 13 differ, 16 only in the code's, 8 only in the definition's; document keys roots, variables; issues: line 16:1: Nothing over this page has the id "zoom" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0","r0.body.1"] / ["r0.body.0","r0.body.1","r0.body.2"]`
  - `r0.body.1.0.0.actions: [{"actions":[{"cover":true,"presentation":"dialog","to":"r2","type":"openModal"}],"trig... / [{"actions":[{"cover":true,"presentation":"dialog","to":"r1","type":"openModal"}],"trig...`
  - `r0.body.1.2.0.actions: [{"actions":[{"barrierColor":"#F2000000","cover":true,"presentation":"dialog","routeTra... / [{"actions":[],"trigger":{"type":"click"}}]`
- tool/vocabulary/corpus/b09/answers/company-timeline.txt ### Event story @834: 39 of 68 nodes the same; 13 differ, 16 only in the code's, 8 only in the definition's; document keys roots, variables; issues: line 16:1: Nothing over this page has the id "zoom" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0","r0.body.1"] / ["r0.body.0","r0.body.1","r0.body.2"]`
  - `r0.body.1.0.0.actions: [{"actions":[{"cover":true,"presentation":"dialog","to":"r2","type":"openModal"}],"trig... / [{"actions":[{"cover":true,"presentation":"dialog","to":"r1","type":"openModal"}],"trig...`
  - `r0.body.1.2.0.actions: [{"actions":[{"barrierColor":"#F2000000","cover":true,"presentation":"dialog","routeTra... / [{"actions":[],"trigger":{"type":"click"}}]`
- tool/vocabulary/corpus/b09/answers/company-timeline.txt ### Event story @390: 38 of 52 nodes the same; 2 differ, 12 only in the code's, 4 only in the definition's; document keys roots, variables; issues: line 16:1: Nothing over this page has the id "zoom" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0","r0.body.1"] / ["r0.body.0","r0.body.1","r0.body.2"]`
  - `r0.body.1.2.0.actions: [{"actions":[{"barrierColor":"#F2000000","cover":true,"presentation":"dialog","routeTra... / [{"actions":[],"trigger":{"type":"click"}}]`
  - `roots: ["r0","r1"] / ["r0"]`

### Link

- tool/vocabulary/corpus/b08/answers/census-form.txt ### Review and Submit @1440: equal
- tool/vocabulary/corpus/b08/answers/census-form.txt ### Review and Submit @834: equal
- tool/vocabulary/corpus/b08/answers/census-form.txt ### Review and Submit @390: equal
- tool/vocabulary/corpus/b09/answers/company-timeline.txt ### Event story @1440: equal
- tool/vocabulary/corpus/b09/answers/company-timeline.txt ### Event story @834: equal
- tool/vocabulary/corpus/b09/answers/company-timeline.txt ### Event story @390: equal
- tool/vocabulary/corpus/b07/answers/outliner-notes.txt ### Outline @1440: 133 of 136 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.0.1.media: [{"maxWidth":699,"patch":{"layout":{"basis":124,"flex":1,"width":{"fill":0}}}}] / [{"maxWidth":699,"patch":{"layout":{"basis":231.25,"flex":1,"width":{"fill":0}}}}]`
  - `r0.body.1.0.1.0.layout.squeezable: (none) / true; r0.body.1.0.1.0.media: [{"maxWidth":699,"patch":{"visible":false}}] / (none); r0.body.1.0.1.0.props.label: "Home" / (none)`
  - `r0.body.1.0.1.2.layout.squeezable: (none) / true; r0.body.1.0.1.2.media: [{"maxWidth":699,"patch":{"bind":{"visible":null},"visible":false}}] / (none); r0.body.1.0.1.2.props.label: "Q4 planning" / (none)`
- tool/vocabulary/corpus/b07/answers/outliner-notes.txt ### Outline @834: 133 of 136 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.0.1.media: [{"maxWidth":699,"patch":{"layout":{"basis":124,"flex":1,"width":{"fill":0}}}}] / [{"maxWidth":699,"patch":{"layout":{"basis":231.25,"flex":1,"width":{"fill":0}}}}]`
  - `r0.body.1.0.1.0.layout.squeezable: (none) / true; r0.body.1.0.1.0.media: [{"maxWidth":699,"patch":{"visible":false}}] / (none); r0.body.1.0.1.0.props.label: "Home" / (none)`
  - `r0.body.1.0.1.2.layout.squeezable: (none) / true; r0.body.1.0.1.2.media: [{"maxWidth":699,"patch":{"bind":{"visible":null},"visible":false}}] / (none); r0.body.1.0.1.2.props.label: "Q4 planning" / (none)`
- tool/vocabulary/corpus/b07/answers/outliner-notes.txt ### Outline @390: 100 of 102 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.0.0.0.layout.squeezable: (none) / true; r0.body.1.0.0.0.props.label: "Home" / (none); r0.body.1.0.0.0.props.style: (none) / {"color":"#FF2563EB","fontSize":13}`
  - `r0.body.1.0.0.2.layout.squeezable: (none) / true; r0.body.1.0.0.2.props.label: "Q4 planning" / (none); r0.body.1.0.0.2.props.style: (none) / {"color":"#FF2563EB","fontSize":13}`
- docs/reference/notation/navigation.md block 1 @1440: 17 of 18 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.1.layout.height: 40.0 / {"hug":0}; r0.body.0.0.1.layout.squeezable: (none) / true; r0.body.0.0.1.media: [{"maxWidth":699,"patch":{"visible":false}}] / (none)`
- docs/reference/notation/navigation.md block 1 @834: 17 of 18 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.1.layout.height: 40.0 / {"hug":0}; r0.body.0.0.1.layout.squeezable: (none) / true; r0.body.0.0.1.media: [{"maxWidth":699,"patch":{"visible":false}}] / (none)`
- docs/reference/notation/navigation.md block 1 @390: 17 of 18 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.1.layout.height: 40.0 / {"hug":0}; r0.body.0.0.1.layout.squeezable: (none) / true; r0.body.0.0.1.props.label: "Pricing" / (none)`

### Main

- tool/vocabulary/corpus/b09/answers/pedometer-band.txt ### Band Pages @1440: equal; issues: line 20:39: MainDict.txt:3: MainDict: "onWake" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop.
- tool/vocabulary/corpus/b09/answers/pedometer-band.txt ### Band Pages @834: equal; issues: line 20:39: MainDict.txt:3: MainDict: "onWake" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop.
- tool/vocabulary/corpus/b09/answers/pedometer-band.txt ### Band Pages @390: equal; issues: line 20:39: MainDict.txt:3: MainDict: "onWake" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop.
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @1440: 87 of 195 nodes the same; 28 differ, 80 only in the code's, 52 only in the definition's; document keys roots
  - `r0.actions: [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee... / [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee...`
  - `r0.body.0.2.actions: [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee... / [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee...`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4"]`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @834: 87 of 195 nodes the same; 28 differ, 80 only in the code's, 52 only in the definition's; document keys roots
  - `r0.actions: [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee... / [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee...`
  - `r0.body.0.2.actions: [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee... / [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee...`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4"]`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @390: 100 of 168 nodes the same; 17 differ, 51 only in the code's, 50 only in the definition's
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4"]`
  - `r0.body.1.0.layout.padding: [24,14,24,14] / (none); r0.body.1.0.props.spacing: 24 / 16`
  - `r0.body.1.1.layout.width.fill: 0 / (none); r0.body.1.1.layout.width.hug: (none) / 0; r0.body.1.1.type: "divider" / "splitter"`
- tool/vocabulary/corpus/b07/answers/smart-speaker-display.txt ### Night Clock @1440: equal
- tool/vocabulary/corpus/b07/answers/smart-speaker-display.txt ### Night Clock @834: equal
- tool/vocabulary/corpus/b07/answers/smart-speaker-display.txt ### Night Clock @390: equal
- docs/reference/notation/NOTATION.md block 4 @1440: 13 of 26 nodes the same; 3 differ, 10 only in the code's, 0 only in the definition's; document keys roots
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.layout.width.fill: 0 / (none)`
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- docs/reference/notation/NOTATION.md block 4 @834: 13 of 26 nodes the same; 3 differ, 10 only in the code's, 0 only in the definition's; document keys roots
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.layout.width.fill: 0 / (none)`
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- docs/reference/notation/NOTATION.md block 4 @390: 15 of 16 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- docs/reference/notation/navigation.md block 3 @1440: 6 of 18 nodes the same; 2 differ, 10 only in the code's, 0 only in the definition's; document keys roots, variables
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
  - `roots: ["r0","r1"] / ["r0"]`
- docs/reference/notation/navigation.md block 3 @834: 6 of 18 nodes the same; 2 differ, 10 only in the code's, 0 only in the definition's; document keys roots, variables
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
  - `roots: ["r0","r1"] / ["r0"]`
- docs/reference/notation/navigation.md block 3 @390: equal

### Menu

- tool/vocabulary/corpus-define/d01/answers/whiteboard.txt ### Board @1440: 54 of 90 nodes the same; 13 differ, 23 only in the code's, 21 only in the definition's; document keys roots; issues: line 27:1: Nothing over this page has the id "canvasMenu" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "share". / line 62:1: Nothing over this page has the id "zoomMenu" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "share".
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1","r0.body.2"]`
  - `r0.body.0.0.1.1.actions: [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r3","type":"openModa... / [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r1","type":"openModa...`
  - `r0.body.0.2.5.0.0.1.actions: [{"actions":[{"anchor":"trigger","anchorGap":6,"placement":"aboveEnd","presentation":"p... / [{"actions":[],"trigger":{"type":"click"}}]`
- tool/vocabulary/corpus-define/d01/answers/whiteboard.txt ### Board @834: 54 of 90 nodes the same; 13 differ, 23 only in the code's, 21 only in the definition's; document keys roots; issues: line 27:1: Nothing over this page has the id "canvasMenu" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "share". / line 62:1: Nothing over this page has the id "zoomMenu" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "share".
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1","r0.body.2"]`
  - `r0.body.0.0.1.1.actions: [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r3","type":"openModa... / [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r1","type":"openModa...`
  - `r0.body.0.2.5.0.0.1.actions: [{"actions":[{"anchor":"trigger","anchorGap":6,"placement":"aboveEnd","presentation":"p... / [{"actions":[],"trigger":{"type":"click"}}]`
- tool/vocabulary/corpus-define/d01/answers/whiteboard.txt ### Board @390: 54 of 90 nodes the same; 13 differ, 23 only in the code's, 21 only in the definition's; document keys roots; issues: line 27:1: Nothing over this page has the id "canvasMenu" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "share". / line 62:1: Nothing over this page has the id "zoomMenu" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "share".
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1","r0.body.2"]`
  - `r0.body.0.0.1.1.actions: [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r3","type":"openModa... / [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r1","type":"openModa...`
  - `r0.body.0.2.5.0.0.1.actions: [{"actions":[{"anchor":"trigger","anchorGap":6,"placement":"aboveEnd","presentation":"p... / [{"actions":[],"trigger":{"type":"click"}}]`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/story-reader.txt ### Today @1440: 53 of 163 nodes the same; 24 differ, 86 only in the code's, 86 only in the definition's; document keys roots; issues: line 42:1: Nothing over this page has the id "reactMenu" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "story".
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0; r0.body.type: "row" / "column"`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3","r0.body.0.4","r0.body.0.5","r... / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0","r0.body.0.0.1","r0.body.0.0.2","r0.body.0.0.3","r0.body.0.0.4","r0.bo...; r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/story-reader.txt ### Today @834: 53 of 163 nodes the same; 24 differ, 86 only in the code's, 86 only in the definition's; document keys roots; issues: line 42:1: Nothing over this page has the id "reactMenu" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "story".
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0; r0.body.type: "row" / "column"`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3","r0.body.0.4","r0.body.0.5","r... / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0","r0.body.0.0.1","r0.body.0.0.2","r0.body.0.0.3","r0.body.0.0.4","r0.bo...; r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/story-reader.txt ### Today @390: 53 of 139 nodes the same; 18 differ, 68 only in the code's, 68 only in the definition's; document keys roots; issues: line 42:1: Nothing over this page has the id "reactMenu" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "story".
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0; r0.body.type: "row" / "column"`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3","r0.body.0.4","r0.body.0.5","r... / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0","r0.body.0.0.1","r0.body.0.0.2","r0.body.0.0.3","r0.body.0.0.4","r0.bo...; r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0`

### Nav

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/seat-booking.txt ### Sold-out performance @1440: 19 of 26 nodes the same; 5 differ, 2 only in the code's, 1 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.media: [{"maxWidth":699,"patch":{"layout":{"padding":[16,14,16,14]}}}] / [{"maxWidth":1023,"patch":{"props":{"runSpacing":12,"wrap":true}}},{"maxWidth":699,"pat...; r0.body.0.props.mainAxisAlignment: (none) / "spaceBetween"`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.layout.width.fill: 0 / (none); r0.body.0.0.layout.width.hug: (none) / 0`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / ["r0.body.0.0.0.0"]; r0.body.0.0.0.layout.height: {"hug":0} / 28; r0.body.0.0.0.layout.width: {"hug":0} / 28`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/seat-booking.txt ### Sold-out performance @834: 19 of 26 nodes the same; 5 differ, 2 only in the code's, 1 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.media: [{"maxWidth":699,"patch":{"layout":{"padding":[16,14,16,14]}}}] / [{"maxWidth":1023,"patch":{"props":{"runSpacing":12,"wrap":true}}},{"maxWidth":699,"pat...; r0.body.0.props.mainAxisAlignment: (none) / "spaceBetween"`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.layout.width.fill: 0 / (none); r0.body.0.0.layout.width.hug: (none) / 0`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / ["r0.body.0.0.0.0"]; r0.body.0.0.0.layout.height: {"hug":0} / 28; r0.body.0.0.0.layout.width: {"hug":0} / 28`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/seat-booking.txt ### Sold-out performance @390: 19 of 26 nodes the same; 5 differ, 2 only in the code's, 1 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.props.mainAxisAlignment: (none) / "spaceBetween"; r0.body.0.props.spacing: (none) / 24`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.layout.width.fill: 0 / (none); r0.body.0.0.layout.width.hug: (none) / 0`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / ["r0.body.0.0.0.0"]; r0.body.0.0.0.layout.height: {"hug":0} / 28; r0.body.0.0.0.layout.width: {"hug":0} / 28`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/calendar-app.txt ### Calendars @1440: 21 of 37 nodes the same; 6 differ, 10 only in the code's, 12 only in the definition's
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1"] / ["r0.body.1.0.0"]; r0.body.1.0.decoration: {"strokeSides":"bottom","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.0.layout.padding: [24,14,24,14] / [12,8,12,8]`
  - `r0.body.1.0.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/calendar-app.txt ### Calendars @834: 21 of 37 nodes the same; 6 differ, 10 only in the code's, 12 only in the definition's
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1"] / ["r0.body.1.0.0"]; r0.body.1.0.decoration: {"strokeSides":"bottom","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.0.layout.padding: [24,14,24,14] / [12,8,12,8]`
  - `r0.body.1.0.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/calendar-app.txt ### Calendars @390: equal
- tool/vocabulary/corpus/b08/answers/ereader-shelf.txt ### Reader @1440: equal
- tool/vocabulary/corpus/b08/answers/ereader-shelf.txt ### Reader @834: equal
- tool/vocabulary/corpus/b08/answers/ereader-shelf.txt ### Reader @390: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @1440: 121 of 195 nodes the same; 12 differ, 62 only in the code's, 66 only in the definition's
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5","r...`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1","r0.body.1.0.2","r0.body.1.0.3"] / ["r0.body.1.0.0"]; r0.body.1.0.layout.padding: [24,14,24,14] / [12,8,12,8]; r0.body.1.0.props.mainAxisAlignment: "spaceBetween" / (none)`
  - `r0.body.1.0.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @834: 121 of 195 nodes the same; 12 differ, 62 only in the code's, 66 only in the definition's
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5","r...`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1","r0.body.1.0.2","r0.body.1.0.3"] / ["r0.body.1.0.0"]; r0.body.1.0.layout.padding: [24,14,24,14] / [12,8,12,8]; r0.body.1.0.props.mainAxisAlignment: "spaceBetween" / (none)`
  - `r0.body.1.0.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @390: 123 of 168 nodes the same; 12 differ, 33 only in the code's, 35 only in the definition's
  - `r0.body.1.3.children: ["r0.body.1.3.0","r0.body.1.3.1","r0.body.1.3.2","r0.body.1.3.3"] / ["r0.body.1.3.0","r0.body.1.3.1","r0.body.1.3.2","r0.body.1.3.3","r0.body.1.3.4"]`
  - `r0.body.1.3.0.layout.padding: (none) / [24,14,24,14]; r0.body.1.3.0.props.spacing: 16 / 24`
  - `r0.body.1.3.1.bind: {"visible":"${= selecting}"} / (none); r0.body.1.3.1.children: ["r0.body.1.3.1.0","r0.body.1.3.1.1","r0.body.1.3.1.2","r0.body.1.3.1.3","r0.body.1.3.1... / (none); r0.body.1.3.1.decoration: {"fills":[{"color":"#FFEFE4CC"}]} / (none)`
- docs/reference/notation/navigation.md block 1 @1440: 11 of 18 nodes the same; 5 differ, 2 only in the code's, 1 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.media: [{"maxWidth":699,"patch":{"layout":{"padding":[16,14,16,14]}}}] / [{"maxWidth":1023,"patch":{"props":{"runSpacing":12,"wrap":true}}},{"maxWidth":699,"pat...; r0.body.0.props.mainAxisAlignment: (none) / "spaceBetween"`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.layout.width.fill: 0 / (none); r0.body.0.0.layout.width.hug: (none) / 0`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / ["r0.body.0.0.0.0"]; r0.body.0.0.0.layout.height: {"hug":0} / 28; r0.body.0.0.0.layout.width: {"hug":0} / 28`
- docs/reference/notation/navigation.md block 1 @834: 11 of 18 nodes the same; 5 differ, 2 only in the code's, 1 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.media: [{"maxWidth":699,"patch":{"layout":{"padding":[16,14,16,14]}}}] / [{"maxWidth":1023,"patch":{"props":{"runSpacing":12,"wrap":true}}},{"maxWidth":699,"pat...; r0.body.0.props.mainAxisAlignment: (none) / "spaceBetween"`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.layout.width.fill: 0 / (none); r0.body.0.0.layout.width.hug: (none) / 0`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / ["r0.body.0.0.0.0"]; r0.body.0.0.0.layout.height: {"hug":0} / 28; r0.body.0.0.0.layout.width: {"hug":0} / 28`
- docs/reference/notation/navigation.md block 1 @390: 11 of 18 nodes the same; 5 differ, 2 only in the code's, 1 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.props.mainAxisAlignment: (none) / "spaceBetween"; r0.body.0.props.spacing: (none) / 24`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.layout.width.fill: 0 / (none); r0.body.0.0.layout.width.hug: (none) / 0`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / ["r0.body.0.0.0.0"]; r0.body.0.0.0.layout.height: {"hug":0} / 28; r0.body.0.0.0.layout.width: {"hug":0} / 28`

### NavItem

- tool/vocabulary/corpus/b03/answers/typing-chat-bot.txt ### Chat @1440: equal up to spelling
- tool/vocabulary/corpus/b03/answers/typing-chat-bot.txt ### Chat @834: equal up to spelling
- tool/vocabulary/corpus/b03/answers/typing-chat-bot.txt ### Chat @390: equal up to spelling
- tool/vocabulary/corpus-define/d02/answers/flight-tracker.txt ### Alerts @1440: 58 of 60 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.4.decoration.fills: [{"color":"#FF2563EB","opacity":0.12}] / (none); r0.body.0.4.bind: (none) / {"selected":"${= true}"}; r0.body.0.4.states: (none) / {"hovered":{"r0.body.0.4":{"decoration":{"fills":[{"color":"#0F111827"}]}}},"selected":...`
  - `r1.body.0.4.decoration.fills: [{"color":"#FF2563EB","opacity":0.12}] / (none); r1.body.0.4.bind: (none) / {"selected":"${= true}"}; r1.body.0.4.states: (none) / {"hovered":{"r1.body.0.4":{"decoration":{"fills":[{"color":"#0F111827"}]}}},"selected":...`
- tool/vocabulary/corpus-define/d02/answers/flight-tracker.txt ### Alerts @834: 58 of 60 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.4.decoration.fills: [{"color":"#FF2563EB","opacity":0.12}] / (none); r0.body.0.4.bind: (none) / {"selected":"${= true}"}; r0.body.0.4.states: (none) / {"hovered":{"r0.body.0.4":{"decoration":{"fills":[{"color":"#0F111827"}]}}},"selected":...`
  - `r1.body.0.4.decoration.fills: [{"color":"#FF2563EB","opacity":0.12}] / (none); r1.body.0.4.bind: (none) / {"selected":"${= true}"}; r1.body.0.4.states: (none) / {"hovered":{"r1.body.0.4":{"decoration":{"fills":[{"color":"#0F111827"}]}}},"selected":...`
- tool/vocabulary/corpus-define/d02/answers/flight-tracker.txt ### Alerts @390: 37 of 38 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.4.decoration.fills: [{"color":"#FF2563EB","opacity":0.12}] / (none); r0.body.0.4.bind: (none) / {"selected":"${= true}"}; r0.body.0.4.states: (none) / {"hovered":{"r0.body.0.4":{"decoration":{"fills":[{"color":"#0F111827"}]}}},"selected":...`
- tool/vocabulary/corpus-define/d02/answers/typing-chat-bot.txt ### Chat @1440: 134 of 138 nodes the same; 4 differ, 0 only in the code's, 2 only in the definition's
  - `r0.body.0.3.0.0.1.0.0.0.children: ["r0.body.0.3.0.0.1.0.0.0.0"] / ["r0.body.0.3.0.0.1.0.0.0.0","r0.body.0.3.0.0.1.0.0.0.1"]`
  - `r0.body.0.3.0.0.1.0.0.0.0.bind.props.style.color: "${= (current==item.id)?\"#FF2563EB\":\"#FF374151\"}" / (none); r0.body.0.3.0.0.1.0.0.0.0.bind.props.style.fontWeight: "${= (current==item.id)?600:500}" / (none); r0.body.0.3.0.0.1.0.0.0.0.bind.props.color: (none) / "${= (current==item.id)?\"#FF2563EB\":\"#FF6B7280\"}"`
  - `r5.body.0.3.0.0.1.0.0.0.children: ["r5.body.0.3.0.0.1.0.0.0.0"] / ["r5.body.0.3.0.0.1.0.0.0.0","r5.body.0.3.0.0.1.0.0.0.1"]`
- tool/vocabulary/corpus-define/d02/answers/typing-chat-bot.txt ### Chat @834: 134 of 138 nodes the same; 4 differ, 0 only in the code's, 2 only in the definition's
  - `r0.body.0.3.0.0.1.0.0.0.children: ["r0.body.0.3.0.0.1.0.0.0.0"] / ["r0.body.0.3.0.0.1.0.0.0.0","r0.body.0.3.0.0.1.0.0.0.1"]`
  - `r0.body.0.3.0.0.1.0.0.0.0.bind.props.style.color: "${= (current==item.id)?\"#FF2563EB\":\"#FF374151\"}" / (none); r0.body.0.3.0.0.1.0.0.0.0.bind.props.style.fontWeight: "${= (current==item.id)?600:500}" / (none); r0.body.0.3.0.0.1.0.0.0.0.bind.props.color: (none) / "${= (current==item.id)?\"#FF2563EB\":\"#FF6B7280\"}"`
  - `r5.body.0.3.0.0.1.0.0.0.children: ["r5.body.0.3.0.0.1.0.0.0.0"] / ["r5.body.0.3.0.0.1.0.0.0.0","r5.body.0.3.0.0.1.0.0.0.1"]`
- tool/vocabulary/corpus-define/d02/answers/typing-chat-bot.txt ### Chat @390: 114 of 116 nodes the same; 2 differ, 0 only in the code's, 1 only in the definition's
  - `r0.body.0.3.0.0.1.0.0.0.children: ["r0.body.0.3.0.0.1.0.0.0.0"] / ["r0.body.0.3.0.0.1.0.0.0.0","r0.body.0.3.0.0.1.0.0.0.1"]`
  - `r0.body.0.3.0.0.1.0.0.0.0.bind.props.style.color: "${= (current==item.id)?\"#FF2563EB\":\"#FF374151\"}" / (none); r0.body.0.3.0.0.1.0.0.0.0.bind.props.style.fontWeight: "${= (current==item.id)?600:500}" / (none); r0.body.0.3.0.0.1.0.0.0.0.bind.props.color: (none) / "${= (current==item.id)?\"#FF2563EB\":\"#FF6B7280\"}"`
  - `only in the definition's: r0.body.0.3.0.0.1.0.0.0.1 text`
- tool/vocabulary/corpus/b08/answers/keyboard-only-mail.txt ### Inbox @1440: 189 of 209 nodes the same; 12 differ, 8 only in the code's, 0 only in the definition's
  - `r0.body.0.1.children: ["r0.body.0.1.0","r0.body.0.1.1","r0.body.0.1.2","r0.body.0.1.3"] / ["r0.body.0.1.0","r0.body.0.1.1","r0.body.0.1.2"]`
  - `r0.body.0.1.0.bind: {"props.color":"${= (true)?\"#FF2563EB\":\"#FF6B7280\"}"} / (none); r0.body.0.1.0.props.color: (none) / "#FF2563EB"`
  - `r0.body.0.1.1.bind: {"props.style.color":"${= (true)?\"#FF2563EB\":\"#FF374151\"}","props.style.fontWeight"... / (none); r0.body.0.1.1.props.style.color: "#FF111827" / "#FF2563EB"; r0.body.0.1.1.props.style.fontWeight: (none) / 600`
- tool/vocabulary/corpus/b08/answers/keyboard-only-mail.txt ### Inbox @834: 189 of 209 nodes the same; 12 differ, 8 only in the code's, 0 only in the definition's
  - `r0.body.0.1.children: ["r0.body.0.1.0","r0.body.0.1.1","r0.body.0.1.2","r0.body.0.1.3"] / ["r0.body.0.1.0","r0.body.0.1.1","r0.body.0.1.2"]`
  - `r0.body.0.1.0.bind: {"props.color":"${= (true)?\"#FF2563EB\":\"#FF6B7280\"}"} / (none); r0.body.0.1.0.props.color: (none) / "#FF2563EB"`
  - `r0.body.0.1.1.bind: {"props.style.color":"${= (true)?\"#FF2563EB\":\"#FF374151\"}","props.style.fontWeight"... / (none); r0.body.0.1.1.props.style.color: "#FF111827" / "#FF2563EB"; r0.body.0.1.1.props.style.fontWeight: (none) / 600`
- tool/vocabulary/corpus/b08/answers/keyboard-only-mail.txt ### Inbox @390: 165 of 175 nodes the same; 6 differ, 4 only in the code's, 0 only in the definition's
  - `r0.body.0.1.children: ["r0.body.0.1.0","r0.body.0.1.1","r0.body.0.1.2","r0.body.0.1.3"] / ["r0.body.0.1.0","r0.body.0.1.1","r0.body.0.1.2"]`
  - `r0.body.0.1.0.bind: {"props.color":"${= (true)?\"#FF2563EB\":\"#FF6B7280\"}"} / (none); r0.body.0.1.0.props.color: (none) / "#FF2563EB"`
  - `r0.body.0.1.1.bind: {"props.style.color":"${= (true)?\"#FF2563EB\":\"#FF374151\"}","props.style.fontWeight"... / (none); r0.body.0.1.1.props.style.color: "#FF111827" / "#FF2563EB"; r0.body.0.1.1.props.style.fontWeight: (none) / 600`
- docs/reference/notation/NOTATION.md block 4 @1440: equal up to spelling
- docs/reference/notation/NOTATION.md block 4 @834: equal up to spelling
- docs/reference/notation/NOTATION.md block 4 @390: equal up to spelling
- docs/reference/notation/navigation.md block 3 @1440: equal up to spelling
- docs/reference/notation/navigation.md block 3 @834: equal up to spelling
- docs/reference/notation/navigation.md block 3 @390: equal up to spelling

### NavSection

- docs/reference/notation/navigation.md block 5 @1440: equal
- docs/reference/notation/navigation.md block 5 @834: equal
- docs/reference/notation/navigation.md block 5 @390: equal
- written: a group label in capitals, and one worked out @1440: 26 of 28 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.2.props.text: "${team.name}" / "${= upper((team.name))}"`
  - `r1.body.0.2.props.text: "${team.name}" / "${= upper((team.name))}"`
- written: a group label in capitals, and one worked out @834: 26 of 28 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.2.props.text: "${team.name}" / "${= upper((team.name))}"`
  - `r1.body.0.2.props.text: "${team.name}" / "${= upper((team.name))}"`
- written: a group label in capitals, and one worked out @390: 12 of 13 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.2.props.text: "${team.name}" / "${= upper((team.name))}"`
- written: a group label as most labels are written @1440: equal
- written: a group label as most labels are written @834: equal
- written: a group label as most labels are written @390: equal

### Page

- tool/vocabulary/corpus/b08/answers/typesetter-pages.txt ### Spread @1440: 127 of 153 nodes the same; 21 differ, 5 only in the code's, 3 only in the definition's; document keys variables
  - `r0.body.1.0.2.0.0.0.children: ["r0.body.1.0.2.0.0.0.0","r0.body.1.0.2.0.0.0.1","r0.body.1.0.2.0.0.0.2","r0.body.1.0.2... / ["r0.body.1.0.2.0.0.0.0","r0.body.1.0.2.0.0.0.1","r0.body.1.0.2.0.0.0.2","r0.body.1.0.2...; r0.body.1.0.2.0.0.0.layout.flex: 1 / (none); r0.body.1.0.2.0.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.1.0.2.0.0.0.0.layout.constraints: (none) / {"minHeight":40}; r0.body.1.0.2.0.0.0.0.layout.padding: (none) / 8; r0.body.1.0.2.0.0.0.0.props.style: {"color":"#FF111827","fontSize":13} / (none)`
  - `r0.body.1.0.2.0.0.0.1.children: ["r0.body.1.0.2.0.0.0.1.0"] / ["r0.body.1.0.2.0.0.0.1.0","r0.body.1.0.2.0.0.0.1.1"]; r0.body.1.0.2.0.0.0.1.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.0.2.0.0.0.1.layout.constraints.minHeight: 40 / 300`
- tool/vocabulary/corpus/b08/answers/typesetter-pages.txt ### Spread @834: 127 of 153 nodes the same; 21 differ, 5 only in the code's, 3 only in the definition's; document keys variables
  - `r0.body.1.0.2.0.0.0.children: ["r0.body.1.0.2.0.0.0.0","r0.body.1.0.2.0.0.0.1","r0.body.1.0.2.0.0.0.2","r0.body.1.0.2... / ["r0.body.1.0.2.0.0.0.0","r0.body.1.0.2.0.0.0.1","r0.body.1.0.2.0.0.0.2","r0.body.1.0.2...; r0.body.1.0.2.0.0.0.layout.flex: 1 / (none); r0.body.1.0.2.0.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.1.0.2.0.0.0.0.layout.constraints: (none) / {"minHeight":40}; r0.body.1.0.2.0.0.0.0.layout.padding: (none) / 8; r0.body.1.0.2.0.0.0.0.props.style: {"color":"#FF111827","fontSize":13} / (none)`
  - `r0.body.1.0.2.0.0.0.1.children: ["r0.body.1.0.2.0.0.0.1.0"] / ["r0.body.1.0.2.0.0.0.1.0","r0.body.1.0.2.0.0.0.1.1"]; r0.body.1.0.2.0.0.0.1.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.0.2.0.0.0.1.layout.constraints.minHeight: 40 / 300`
- tool/vocabulary/corpus/b08/answers/typesetter-pages.txt ### Spread @390: 99 of 125 nodes the same; 21 differ, 5 only in the code's, 3 only in the definition's; document keys variables
  - `r0.body.1.0.2.0.0.0.children: ["r0.body.1.0.2.0.0.0.0","r0.body.1.0.2.0.0.0.1","r0.body.1.0.2.0.0.0.2","r0.body.1.0.2... / ["r0.body.1.0.2.0.0.0.0","r0.body.1.0.2.0.0.0.1","r0.body.1.0.2.0.0.0.2","r0.body.1.0.2...; r0.body.1.0.2.0.0.0.layout.flex: 1 / (none); r0.body.1.0.2.0.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.1.0.2.0.0.0.0.layout.constraints: (none) / {"minHeight":40}; r0.body.1.0.2.0.0.0.0.layout.padding: (none) / 8; r0.body.1.0.2.0.0.0.0.props.style: {"color":"#FF111827","fontSize":13} / (none)`
  - `r0.body.1.0.2.0.0.0.1.children: ["r0.body.1.0.2.0.0.0.1.0"] / ["r0.body.1.0.2.0.0.0.1.0","r0.body.1.0.2.0.0.0.1.1"]; r0.body.1.0.2.0.0.0.1.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.0.2.0.0.0.1.layout.constraints.minHeight: 40 / 300`
- docs/reference/notation/lists.md block 4 @1440: 1 of 18 nodes the same; 8 differ, 9 only in the code's, 8 only in the definition's
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.layout.padding: [24,64,24,64] / (none); r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none); r0.body.0.props.crossAxisAlignment: "center" / "start"`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.props.spacing: 32 / (none)`
- docs/reference/notation/lists.md block 4 @834: 1 of 18 nodes the same; 8 differ, 9 only in the code's, 8 only in the definition's
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.layout.padding: [24,64,24,64] / (none); r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none); r0.body.0.props.crossAxisAlignment: "center" / "start"`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.props.spacing: 32 / (none)`
- docs/reference/notation/lists.md block 4 @390: 1 of 18 nodes the same; 8 differ, 9 only in the code's, 8 only in the definition's
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.layout.padding: [24,64,24,64] / (none); r0.body.0.props.crossAxisAlignment: "center" / "start"; r0.body.0.props.spacing: (none) / 16`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.props.spacing: 32 / (none)`
- docs/reference/notation/lists.md block 10 @1440: 1 of 41 nodes the same; 5 differ, 35 only in the code's, 34 only in the definition's; document keys variables
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.layout.padding: [24,64,24,64] / (none); r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.props.crossAxisAlignment: "start" / "center"; r0.body.0.0.props.spacing: 32 / 8`
- docs/reference/notation/lists.md block 10 @834: 1 of 41 nodes the same; 5 differ, 35 only in the code's, 34 only in the definition's; document keys variables
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.layout.padding: [24,64,24,64] / (none); r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.props.crossAxisAlignment: "start" / "center"; r0.body.0.0.props.spacing: 32 / 8`
- docs/reference/notation/lists.md block 10 @390: 1 of 41 nodes the same; 5 differ, 35 only in the code's, 34 only in the definition's; document keys variables
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.layout.padding: [24,64,24,64] / (none); r0.body.0.props.crossAxisAlignment: "center" / "start"`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.props.crossAxisAlignment: "start" / "center"; r0.body.0.0.props.spacing: 32 / 8`

### Pane

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/support-desk.txt ### Ticket @1440: 121 of 122 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's; issues: line 55:65: PaneDict.txt:7: A pane is resized by a Splitter beside it, which keeps its width in a variable the pane reads: state listW=300, Pane w={listW}, then Splitter @listW min=240 max=480 after it (pane=after when the pane comes after the Splitter). / line 55:75: PaneDict.txt:7: PaneDict: "min" is not a parameter the notation has.
  - `r0.body.0.2.1.decoration.strokeSides: (none) / "right"; r0.body.0.2.1.decoration.strokes: (none) / [{"color":"#FFE5E7EB"}]; r0.body.0.2.1.layout.height.hug: 0 / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/support-desk.txt ### Ticket @834: 121 of 122 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's; issues: line 55:65: PaneDict.txt:7: A pane is resized by a Splitter beside it, which keeps its width in a variable the pane reads: state listW=300, Pane w={listW}, then Splitter @listW min=240 max=480 after it (pane=after when the pane comes after the Splitter). / line 55:75: PaneDict.txt:7: PaneDict: "min" is not a parameter the notation has.
  - `r0.body.0.2.1.decoration.strokeSides: (none) / "right"; r0.body.0.2.1.decoration.strokes: (none) / [{"color":"#FFE5E7EB"}]; r0.body.0.2.1.layout.height.hug: 0 / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/support-desk.txt ### Ticket @390: 121 of 122 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's; issues: line 55:65: PaneDict.txt:7: A pane is resized by a Splitter beside it, which keeps its width in a variable the pane reads: state listW=300, Pane w={listW}, then Splitter @listW min=240 max=480 after it (pane=after when the pane comes after the Splitter). / line 55:75: PaneDict.txt:7: PaneDict: "min" is not a parameter the notation has.
  - `r0.body.0.2.1.decoration.strokeSides: (none) / "right"; r0.body.0.2.1.decoration.strokes: (none) / [{"color":"#FFE5E7EB"}]; r0.body.0.2.1.layout.height.hug: 0 / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/mail-client.txt ### Mailbox @1440: 176 of 179 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's; issues: line 32:63: PaneDict.txt:7: PaneDict: "min" is not a parameter the notation has. / line 32:71: PaneDict.txt:7: PaneDict: "max" is not a parameter the notation has.
  - `r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0; r0.body.0.0.props.scrollable: (none) / true`
  - `r0.body.0.2.layout.height.hug: 0 / (none); r0.body.0.2.layout.height.fill: (none) / 0; r0.body.0.2.props.scrollable: (none) / true`
  - `r0.body.0.4.props.scrollable: (none) / true; r0.body.0.4.decoration: (none) / {"strokeSides":"left","strokes":[{"color":"#FFE5E7EB"}]}`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/mail-client.txt ### Mailbox @834: 176 of 179 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's; issues: line 32:63: PaneDict.txt:7: PaneDict: "min" is not a parameter the notation has. / line 32:71: PaneDict.txt:7: PaneDict: "max" is not a parameter the notation has.
  - `r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0; r0.body.0.0.props.scrollable: (none) / true`
  - `r0.body.0.2.layout.height.hug: 0 / (none); r0.body.0.2.layout.height.fill: (none) / 0; r0.body.0.2.props.scrollable: (none) / true`
  - `r0.body.0.4.props.scrollable: (none) / true; r0.body.0.4.decoration: (none) / {"strokeSides":"left","strokes":[{"color":"#FFE5E7EB"}]}`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/mail-client.txt ### Mailbox @390: 176 of 179 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's; issues: line 32:63: PaneDict.txt:7: PaneDict: "min" is not a parameter the notation has. / line 32:71: PaneDict.txt:7: PaneDict: "max" is not a parameter the notation has.
  - `r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0; r0.body.0.0.props.scrollable: (none) / true`
  - `r0.body.0.2.layout.height.hug: 0 / (none); r0.body.0.2.layout.height.fill: (none) / 0; r0.body.0.2.props.scrollable: (none) / true`
  - `r0.body.0.4.props.scrollable: (none) / true; r0.body.0.4.decoration: (none) / {"strokeSides":"left","strokes":[{"color":"#FFE5E7EB"}]}`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/team-chat.txt ### Thread @1440: 137 of 138 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/team-chat.txt ### Thread @834: 137 of 138 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/team-chat.txt ### Thread @390: 117 of 118 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- tool/vocabulary/corpus/b06/answers/document-diff.txt ### Compare @1440: 118 of 119 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.2.1.layout.height.hug: 0 / (none); r0.body.1.2.1.layout.height.fill: (none) / 0; r0.body.1.2.1.props.scrollable: (none) / true`
- tool/vocabulary/corpus/b06/answers/document-diff.txt ### Compare @834: 118 of 119 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.2.1.layout.height.hug: 0 / (none); r0.body.1.2.1.layout.height.fill: (none) / 0; r0.body.1.2.1.props.scrollable: (none) / true`
- tool/vocabulary/corpus/b06/answers/document-diff.txt ### Compare @390: 96 of 97 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.2.1.layout.height.hug: 0 / (none); r0.body.1.2.1.layout.height.fill: (none) / 0; r0.body.1.2.1.props.scrollable: (none) / true`
- docs/reference/notation/NOTATION.md block 4 @1440: 25 of 26 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- docs/reference/notation/NOTATION.md block 4 @834: 25 of 26 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- docs/reference/notation/NOTATION.md block 4 @390: 15 of 16 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- docs/reference/notation/navigation.md block 7 @1440: 25 of 26 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- docs/reference/notation/navigation.md block 7 @834: 25 of 26 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- docs/reference/notation/navigation.md block 7 @390: 12 of 13 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.decoration.strokeSides: "left" / "right"`

### Popover

- tool/vocabulary/corpus/b07/answers/tower-defense-map.txt ### Battle @1440: 50 of 105 nodes the same; 31 differ, 24 only in the code's, 22 only in the definition's; document keys roots; issues: line 47:1: Nothing over this page has the id "towerRing" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "towerPanel", "pauseMenu", "victory", "defeat".
  - `r0.actions: [{"actions":[{"type":"setVariable","value":"${= max(0,countdown-1)}","variable":"countd... / [{"actions":[{"type":"setVariable","value":"${= max(0,countdown-1)}","variable":"countd...`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]`
  - `r0.body.0.0.0.1.1.actions: [{"actions":[{"type":"setVariable","value":"${= true}","variable":"paused"},{"insets":[... / [{"actions":[{"type":"setVariable","value":"${= true}","variable":"paused"},{"insets":[...`
- tool/vocabulary/corpus/b07/answers/tower-defense-map.txt ### Battle @834: 50 of 105 nodes the same; 31 differ, 24 only in the code's, 22 only in the definition's; document keys roots; issues: line 47:1: Nothing over this page has the id "towerRing" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "towerPanel", "pauseMenu", "victory", "defeat".
  - `r0.actions: [{"actions":[{"type":"setVariable","value":"${= max(0,countdown-1)}","variable":"countd... / [{"actions":[{"type":"setVariable","value":"${= max(0,countdown-1)}","variable":"countd...`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]`
  - `r0.body.0.0.0.1.1.actions: [{"actions":[{"type":"setVariable","value":"${= true}","variable":"paused"},{"insets":[... / [{"actions":[{"type":"setVariable","value":"${= true}","variable":"paused"},{"insets":[...`
- tool/vocabulary/corpus/b07/answers/tower-defense-map.txt ### Battle @390: 50 of 105 nodes the same; 31 differ, 24 only in the code's, 22 only in the definition's; document keys roots; issues: line 47:1: Nothing over this page has the id "towerRing" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "towerPanel", "pauseMenu", "victory", "defeat".
  - `r0.actions: [{"actions":[{"type":"setVariable","value":"${= max(0,countdown-1)}","variable":"countd... / [{"actions":[{"type":"setVariable","value":"${= max(0,countdown-1)}","variable":"countd...`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]`
  - `r0.body.0.0.0.1.1.actions: [{"actions":[{"type":"setVariable","value":"${= true}","variable":"paused"},{"insets":[... / [{"actions":[{"type":"setVariable","value":"${= true}","variable":"paused"},{"insets":[...`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/spreadsheet.txt ### Sheet @1440: 68 of 113 nodes the same; 17 differ, 28 only in the code's, 25 only in the definition's; document keys roots; issues: line 67:1: Nothing over this page has the id "find" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "colMenu", "rowMenu", "confirmDelete", "confirmSheet". / line 34:1: Nothing over this page has the id "textColor" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "colMenu", "rowMenu", "confirmDelete", "confirmSheet".
  - `r0.actions: [{"actions":[],"trigger":{"key":"Tab","type":"keyDown"}},{"actions":[],"trigger":{"key"... / [{"actions":[],"trigger":{"key":"Tab","type":"keyDown"}},{"actions":[],"trigger":{"key"...`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1","r0.body.2","r0.body.3"]`
  - `r0.body.0.0.1.2.actions: [{"actions":[{"anchor":"trigger","anchorGap":6,"placement":"belowEnd","presentation":"p... / [{"actions":[],"trigger":{"type":"click"}}]`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/spreadsheet.txt ### Sheet @834: 68 of 113 nodes the same; 17 differ, 28 only in the code's, 25 only in the definition's; document keys roots; issues: line 67:1: Nothing over this page has the id "find" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "colMenu", "rowMenu", "confirmDelete", "confirmSheet". / line 34:1: Nothing over this page has the id "textColor" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "colMenu", "rowMenu", "confirmDelete", "confirmSheet".
  - `r0.actions: [{"actions":[],"trigger":{"key":"Tab","type":"keyDown"}},{"actions":[],"trigger":{"key"... / [{"actions":[],"trigger":{"key":"Tab","type":"keyDown"}},{"actions":[],"trigger":{"key"...`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1","r0.body.2","r0.body.3"]`
  - `r0.body.0.0.1.2.actions: [{"actions":[{"anchor":"trigger","anchorGap":6,"placement":"belowEnd","presentation":"p... / [{"actions":[],"trigger":{"type":"click"}}]`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/spreadsheet.txt ### Sheet @390: 68 of 113 nodes the same; 17 differ, 28 only in the code's, 25 only in the definition's; document keys roots; issues: line 67:1: Nothing over this page has the id "find" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "colMenu", "rowMenu", "confirmDelete", "confirmSheet". / line 34:1: Nothing over this page has the id "textColor" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "colMenu", "rowMenu", "confirmDelete", "confirmSheet".
  - `r0.actions: [{"actions":[],"trigger":{"key":"Tab","type":"keyDown"}},{"actions":[],"trigger":{"key"... / [{"actions":[],"trigger":{"key":"Tab","type":"keyDown"}},{"actions":[],"trigger":{"key"...`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1","r0.body.2","r0.body.3"]`
  - `r0.body.0.0.1.2.actions: [{"actions":[{"anchor":"trigger","anchorGap":6,"placement":"belowEnd","presentation":"p... / [{"actions":[],"trigger":{"type":"click"}}]`

### Section

- tool/vocabulary/corpus-define/d02/answers/weighbridge-ticket.txt ### Ticket @1440: 66 of 68 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's; issues: line 35:55: SectionDict.txt:3: SectionDict: "tint" is not a flag the notation has. / line 35:60: SectionDict.txt:3: SectionDict: "compact" is not a flag the notation has.
  - `r0.body.2.0.0.0.0.media: [{"maxWidth":699,"patch":{"props":{"style":{"fontSize":26}}}}] / (none); r0.body.2.0.0.0.0.props.style.fontSize: 36 / 24`
  - `r0.body.3.layout.padding: [24,32,24,32] / [24,64,24,64]; r0.body.3.media: [{"maxWidth":699,"patch":{"layout":{"padding":[20,24,20,24]}}}] / [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"...`
- tool/vocabulary/corpus-define/d02/answers/weighbridge-ticket.txt ### Ticket @834: 66 of 68 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's; issues: line 35:55: SectionDict.txt:3: SectionDict: "tint" is not a flag the notation has. / line 35:60: SectionDict.txt:3: SectionDict: "compact" is not a flag the notation has.
  - `r0.body.2.0.0.0.0.media: [{"maxWidth":699,"patch":{"props":{"style":{"fontSize":26}}}}] / (none); r0.body.2.0.0.0.0.props.style.fontSize: 36 / 24`
  - `r0.body.3.layout.padding: [24,32,24,32] / [24,64,24,64]; r0.body.3.media: [{"maxWidth":699,"patch":{"layout":{"padding":[20,24,20,24]}}}] / [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"...`
- tool/vocabulary/corpus-define/d02/answers/weighbridge-ticket.txt ### Ticket @390: 60 of 62 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's; issues: line 35:55: SectionDict.txt:3: SectionDict: "tint" is not a flag the notation has. / line 35:60: SectionDict.txt:3: SectionDict: "compact" is not a flag the notation has.
  - `r0.body.2.0.0.0.0.props.style.fontSize: 36 / 24`
  - `r0.body.3.layout.padding: [24,32,24,32] / [24,64,24,64]`
- tool/vocabulary/corpus-define/d02/answers/kiosk-museum-touch.txt ### Attract @1440: 10 of 13 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's; issues: line 5:55: SectionDict.txt:3: SectionDict: "bleed" is not a flag the notation has.
  - `r0.body.0.layout.padding: 0 / [24,64,24,64]; r0.body.0.media: (none) / [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"...`
  - `r0.body.0.0.layout.constraints: (none) / {"maxWidth":1120}`
  - `r0.body.0.0.0.1.0.media: [{"maxWidth":1023,"patch":{"props":{"style":{"fontSize":52}}}},{"maxWidth":699,"patch":... / (none); r0.body.0.0.0.1.0.props.style.fontSize: 60 / 30`
- tool/vocabulary/corpus-define/d02/answers/kiosk-museum-touch.txt ### Attract @834: 10 of 13 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's; issues: line 5:55: SectionDict.txt:3: SectionDict: "bleed" is not a flag the notation has.
  - `r0.body.0.layout.padding: 0 / [24,64,24,64]; r0.body.0.media: (none) / [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"...`
  - `r0.body.0.0.layout.constraints: (none) / {"maxWidth":1120}`
  - `r0.body.0.0.0.1.0.media: [{"maxWidth":1023,"patch":{"props":{"style":{"fontSize":52}}}},{"maxWidth":699,"patch":... / (none); r0.body.0.0.0.1.0.props.style.fontSize: 60 / 30`
- tool/vocabulary/corpus-define/d02/answers/kiosk-museum-touch.txt ### Attract @390: 10 of 13 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's; issues: line 5:55: SectionDict.txt:3: SectionDict: "bleed" is not a flag the notation has.
  - `r0.body.0.layout.padding: 0 / [24,64,24,64]`
  - `r0.body.0.0.layout.constraints: (none) / {"maxWidth":1120}`
  - `r0.body.0.0.0.1.0.props.style.fontSize: 60 / 30`
- tool/vocabulary/corpus/b08/answers/neighbour-noticeboard.txt ### Post detail @1440: 94 of 102 nodes the same; 8 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.0.0.1.media: [{"maxWidth":1023,"patch":{"props":{"style":{"fontSize":52}}}},{"maxWidth":699,"patch":... / (none); r0.body.2.0.0.0.0.1.props.style.fontSize: 60 / 30`
  - `r0.body.2.0.0.0.0.5.0.layout.height: 44.0 / 40.0`
  - `r0.body.2.0.0.0.0.5.1.layout.height: 44.0 / 40.0`
- tool/vocabulary/corpus/b08/answers/neighbour-noticeboard.txt ### Post detail @834: 94 of 102 nodes the same; 8 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.0.0.1.media: [{"maxWidth":1023,"patch":{"props":{"style":{"fontSize":52}}}},{"maxWidth":699,"patch":... / (none); r0.body.2.0.0.0.0.1.props.style.fontSize: 60 / 30`
  - `r0.body.2.0.0.0.0.5.0.layout.height: 44.0 / 40.0`
  - `r0.body.2.0.0.0.0.5.1.layout.height: 44.0 / 40.0`
- tool/vocabulary/corpus/b08/answers/neighbour-noticeboard.txt ### Post detail @390: 94 of 102 nodes the same; 8 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.0.0.1.props.style.fontSize: 60 / 30`
  - `r0.body.2.0.0.0.0.5.0.layout.height: 44.0 / 40.0`
  - `r0.body.2.0.0.0.0.5.1.layout.height: 44.0 / 40.0`
- docs/reference/notation/lists.md block 4 @1440: equal
- docs/reference/notation/lists.md block 4 @834: equal
- docs/reference/notation/lists.md block 4 @390: equal
- docs/reference/notation/lists.md block 10 @1440: equal
- docs/reference/notation/lists.md block 10 @834: equal
- docs/reference/notation/lists.md block 10 @390: equal

### Sheet

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/story-reader.txt ### Today @1440: 1 of 163 nodes the same; 26 differ, 136 only in the code's, 136 only in the definition's; document keys roots; issues: line 42:1: Nothing over this page has the id "story" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "reactMenu".
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0; r0.body.type: "row" / "column"`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3","r0.body.0.4","r0.body.0.5","r... / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0","r0.body.0.0.1","r0.body.0.0.2","r0.body.0.0.3","r0.body.0.0.4","r0.bo...; r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/story-reader.txt ### Today @834: 1 of 163 nodes the same; 26 differ, 136 only in the code's, 136 only in the definition's; document keys roots; issues: line 42:1: Nothing over this page has the id "story" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "reactMenu".
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0; r0.body.type: "row" / "column"`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3","r0.body.0.4","r0.body.0.5","r... / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0","r0.body.0.0.1","r0.body.0.0.2","r0.body.0.0.3","r0.body.0.0.4","r0.bo...; r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/story-reader.txt ### Today @390: 1 of 139 nodes the same; 19 differ, 119 only in the code's, 119 only in the definition's; document keys roots; issues: line 42:1: Nothing over this page has the id "story" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "reactMenu".
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0; r0.body.type: "row" / "column"`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3","r0.body.0.4","r0.body.0.5","r... / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.decoration: {"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.padding: [12,16,12,12] / (none)`
  - `r0.body.0.0.children: ["r0.body.0.0.0","r0.body.0.0.1"] / ["r0.body.0.0.0","r0.body.0.0.1","r0.body.0.0.2","r0.body.0.0.3","r0.body.0.0.4","r0.bo...; r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/music-player.txt ### Player @1440: 34 of 45 nodes the same; 1 differ, 10 only in the code's, 9 only in the definition's; document keys roots, variables
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3"]`
  - `roots: ["r0","r1"] / ["r0"]`
  - `variables.page_variables: [{"name":"current","persist":true,"type":"text","value":"t1"},{"name":"pos","persist":t... / (none); variables.r0: (none) / [{"name":"current","persist":true,"type":"text","value":"t1"},{"name":"pos","persist":t...`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/music-player.txt ### Player @834: 34 of 45 nodes the same; 1 differ, 10 only in the code's, 9 only in the definition's; document keys roots, variables
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3"]`
  - `roots: ["r0","r1"] / ["r0"]`
  - `variables.page_variables: [{"name":"current","persist":true,"type":"text","value":"t1"},{"name":"pos","persist":t... / (none); variables.r0: (none) / [{"name":"current","persist":true,"type":"text","value":"t1"},{"name":"pos","persist":t...`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/music-player.txt ### Player @390: 34 of 45 nodes the same; 1 differ, 10 only in the code's, 9 only in the definition's; document keys roots, variables
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3"]`
  - `roots: ["r0","r1"] / ["r0"]`
  - `variables.page_variables: [{"name":"current","persist":true,"type":"text","value":"t1"},{"name":"pos","persist":t... / (none); variables.r0: (none) / [{"name":"current","persist":true,"type":"text","value":"t1"},{"name":"pos","persist":t...`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/photo-library.txt ### Viewer @1440: 16 of 43 nodes the same; 7 differ, 20 only in the code's, 19 only in the definition's; document keys roots; issues: line 13:1: Nothing over this page has the id "infoSheet" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "confirmOne".
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]`
  - `r0.body.0.1.2.0.actions: [{"actions":[{"type":"setVariable","value":"${= !info}","variable":"info"},{"maxHeightF... / [{"actions":[{"type":"setVariable","value":"${= !info}","variable":"info"}],"trigger":{...`
  - `r0.body.0.1.2.3.actions: [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r2","type":"openModa... / [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r1","type":"openModa...`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/photo-library.txt ### Viewer @834: 16 of 43 nodes the same; 7 differ, 20 only in the code's, 19 only in the definition's; document keys roots; issues: line 13:1: Nothing over this page has the id "infoSheet" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "confirmOne".
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]`
  - `r0.body.0.1.2.0.actions: [{"actions":[{"type":"setVariable","value":"${= !info}","variable":"info"},{"maxHeightF... / [{"actions":[{"type":"setVariable","value":"${= !info}","variable":"info"}],"trigger":{...`
  - `r0.body.0.1.2.3.actions: [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r2","type":"openModa... / [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r1","type":"openModa...`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/photo-library.txt ### Viewer @390: 16 of 43 nodes the same; 7 differ, 20 only in the code's, 19 only in the definition's; document keys roots; issues: line 13:1: Nothing over this page has the id "infoSheet" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. Over this page: "confirmOne".
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]`
  - `r0.body.0.1.2.0.actions: [{"actions":[{"type":"setVariable","value":"${= !info}","variable":"info"},{"maxHeightF... / [{"actions":[{"type":"setVariable","value":"${= !info}","variable":"info"}],"trigger":{...`
  - `r0.body.0.1.2.3.actions: [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r2","type":"openModa... / [{"actions":[{"insets":[16,24,16,24],"presentation":"dialog","to":"r1","type":"openModa...`
- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @1440: 19 of 33 nodes the same; 2 differ, 12 only in the code's, 13 only in the definition's; document keys roots, variables; issues: line 19:1: Nothing over this page has the id "searchSheet" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1","r0.body.2"]`
  - `r0.body.0.1.0.0.actions: [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee... / [{"actions":[],"trigger":{"type":"click"}}]`
  - `roots: ["r0","r1","r2"] / ["r0"]`
- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @834: 19 of 33 nodes the same; 2 differ, 12 only in the code's, 13 only in the definition's; document keys roots, variables; issues: line 19:1: Nothing over this page has the id "searchSheet" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1","r0.body.2"]`
  - `r0.body.0.1.0.0.actions: [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee... / [{"actions":[],"trigger":{"type":"click"}}]`
  - `roots: ["r0","r1","r2"] / ["r0"]`
- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @390: 19 of 33 nodes the same; 2 differ, 12 only in the code's, 13 only in the definition's; document keys roots, variables; issues: line 19:1: Nothing over this page has the id "searchSheet" for an open to show (a Dialog, Sheet, Drawer, Menu or Popover with that id, written after the page at the margin): the action is left out. This page has none: write a Dialog with that id after the page, at the margin, with its lines under it.
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1","r0.body.2"]`
  - `r0.body.0.1.0.0.actions: [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee... / [{"actions":[],"trigger":{"type":"click"}}]`
  - `roots: ["r0","r1","r2"] / ["r0"]`

### Shortcut

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/kanban-board.txt ### Archive @1440: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/kanban-board.txt ### Archive @834: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/kanban-board.txt ### Archive @390: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/team-chat.txt ### Composer @1440: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/team-chat.txt ### Composer @834: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/team-chat.txt ### Composer @390: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/flashcards.txt ### Study @1440: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/flashcards.txt ### Study @834: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/flashcards.txt ### Study @390: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/support-desk.txt ### Shortcuts @1440: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/support-desk.txt ### Shortcuts @834: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/support-desk.txt ### Shortcuts @390: equal
- written: a shortcut with its keys as a string @1440: equal
- written: a shortcut with its keys as a string @834: equal
- written: a shortcut with its keys as a string @390: equal
- written: a shortcut with keys= @1440: equal
- written: a shortcut with keys= @834: equal
- written: a shortcut with keys= @390: equal
- written: a chord written as a bare word, and an event under another name (as corpus answers write them) @1440: 2 of 3 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's; issues: line 4:1: ShortcutDict.txt:3: A shortcut is a line of its own: key mod+k onPress={open search} (mod, alt, shift and a key, joined by +).
  - `r0.actions: [{"actions":[{"message":"play","type":"showToast"}],"trigger":{"key":"space","type":"ke... / [{"actions":[{"message":"play","type":"showToast"}],"trigger":{"key":"space","type":"ke...`
- written: a chord written as a bare word, and an event under another name (as corpus answers write them) @834: 2 of 3 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's; issues: line 4:1: ShortcutDict.txt:3: A shortcut is a line of its own: key mod+k onPress={open search} (mod, alt, shift and a key, joined by +).
  - `r0.actions: [{"actions":[{"message":"play","type":"showToast"}],"trigger":{"key":"space","type":"ke... / [{"actions":[{"message":"play","type":"showToast"}],"trigger":{"key":"space","type":"ke...`
- written: a chord written as a bare word, and an event under another name (as corpus answers write them) @390: 2 of 3 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's; issues: line 4:1: ShortcutDict.txt:3: A shortcut is a line of its own: key mod+k onPress={open search} (mod, alt, shift and a key, joined by +).
  - `r0.actions: [{"actions":[{"message":"play","type":"showToast"}],"trigger":{"key":"space","type":"ke... / [{"actions":[{"message":"play","type":"showToast"}],"trigger":{"key":"space","type":"ke...`

### Sidebar

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @1440: 152 of 195 nodes the same; 14 differ, 29 only in the code's, 2 only in the definition's; document keys roots
  - `r0.actions: [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee... / [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee...`
  - `r0.body.0.0.layout.padding: [8,6,8,10] / (none)`
  - `r0.body.0.0.1.props.style.fontSize: 15 / 17`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @834: 152 of 195 nodes the same; 14 differ, 29 only in the code's, 2 only in the definition's; document keys roots
  - `r0.actions: [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee... / [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee...`
  - `r0.body.0.0.layout.padding: [8,6,8,10] / (none)`
  - `r0.body.0.0.1.props.style.fontSize: 15 / 17`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @390: 166 of 168 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.layout.padding: [8,6,8,10] / (none)`
  - `r0.body.0.0.1.props.style.fontSize: 15 / 17`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/calendar-app.txt ### Calendars @1440: 21 of 37 nodes the same; 4 differ, 12 only in the code's, 0 only in the definition's; document keys roots, variables
  - `r0.body.0.0.layout.padding: [8,6,8,10] / (none)`
  - `r0.body.0.0.1.props.style.fontSize: 15 / 17`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1"] / ["r0.body.1.0.0"]`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/calendar-app.txt ### Calendars @834: 21 of 37 nodes the same; 4 differ, 12 only in the code's, 0 only in the definition's; document keys roots, variables
  - `r0.body.0.0.layout.padding: [8,6,8,10] / (none)`
  - `r0.body.0.0.1.props.style.fontSize: 15 / 17`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1"] / ["r0.body.1.0.0"]`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/calendar-app.txt ### Calendars @390: 23 of 25 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.layout.padding: [8,6,8,10] / (none)`
  - `r0.body.0.0.1.props.style.fontSize: 15 / 17`
- docs/reference/notation/NOTATION.md block 4 @1440: 14 of 26 nodes the same; 2 differ, 10 only in the code's, 0 only in the definition's; document keys roots
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.layout.width.fill: 0 / (none)`
  - `roots: ["r0","r1","r2"] / ["r0","r1"]`
- docs/reference/notation/NOTATION.md block 4 @834: 14 of 26 nodes the same; 2 differ, 10 only in the code's, 0 only in the definition's; document keys roots
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.layout.width.fill: 0 / (none)`
  - `roots: ["r0","r1","r2"] / ["r0","r1"]`
- docs/reference/notation/NOTATION.md block 4 @390: equal
- docs/reference/notation/navigation.md block 3 @1440: 6 of 18 nodes the same; 2 differ, 10 only in the code's, 0 only in the definition's; document keys roots, variables
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
  - `roots: ["r0","r1"] / ["r0"]`
- docs/reference/notation/navigation.md block 3 @834: 6 of 18 nodes the same; 2 differ, 10 only in the code's, 0 only in the definition's; document keys roots, variables
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
  - `roots: ["r0","r1"] / ["r0"]`
- docs/reference/notation/navigation.md block 3 @390: equal

### SidebarFooter

- written: a sidebar's foot @1440: equal
- written: a sidebar's foot @834: equal
- written: a sidebar's foot @390: equal
- written: a brand in a sidebar's foot, and a foot outside a sidebar @1440: 24 of 31 nodes the same; 6 differ, 1 only in the code's, 2 only in the definition's
  - `r0.body.0.2.0.layout.padding: [8,6,8,10] / (none)`
  - `r0.body.0.2.0.1.props.style.fontSize: 15 / 17`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3"]; r0.body.1.props.scrollable: true / (none)`
- written: a brand in a sidebar's foot, and a foot outside a sidebar @834: 24 of 31 nodes the same; 6 differ, 1 only in the code's, 2 only in the definition's
  - `r0.body.0.2.0.layout.padding: [8,6,8,10] / (none)`
  - `r0.body.0.2.0.1.props.style.fontSize: 15 / 17`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3"]; r0.body.1.props.scrollable: true / (none)`
- written: a brand in a sidebar's foot, and a foot outside a sidebar @390: 10 of 15 nodes the same; 4 differ, 1 only in the code's, 2 only in the definition's
  - `r0.body.0.2.0.layout.padding: [8,6,8,10] / (none)`
  - `r0.body.0.2.0.1.props.style.fontSize: 15 / 17`
  - `r0.body.1.children: ["r0.body.1.0"] / ["r0.body.1.0","r0.body.1.1"]; r0.body.1.props.scrollable: true / (none)`

### Table

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/admin-console.txt ### Members @1440: 176 of 206 nodes the same; 21 differ, 9 only in the code's, 2 only in the definition's; document keys variables
  - `r0.body.1.2.0.2.actions: [{"actions":[{"type":"setVariable","value":"${= result.id}","variable":"panelId"}],"tri... / (none)`
  - `r0.body.1.2.0.2.0.layout.height: 32 / 40`
  - `r0.body.1.2.0.2.0.0.layout.width: 16 / {"fill":0}; r0.body.1.2.0.2.0.0.props.crossAxisAlignment: "center" / (none); r0.body.1.2.0.2.0.0.props.crossAxisCount: (none) / 1`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/admin-console.txt ### Members @834: 176 of 206 nodes the same; 21 differ, 9 only in the code's, 2 only in the definition's; document keys variables
  - `r0.body.1.2.0.2.actions: [{"actions":[{"type":"setVariable","value":"${= result.id}","variable":"panelId"}],"tri... / (none)`
  - `r0.body.1.2.0.2.0.layout.height: 32 / 40`
  - `r0.body.1.2.0.2.0.0.layout.width: 16 / {"fill":0}; r0.body.1.2.0.2.0.0.props.crossAxisAlignment: "center" / (none); r0.body.1.2.0.2.0.0.props.crossAxisCount: (none) / 1`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/admin-console.txt ### Members @390: 140 of 170 nodes the same; 21 differ, 9 only in the code's, 2 only in the definition's; document keys variables
  - `r0.body.1.2.0.2.actions: [{"actions":[{"type":"setVariable","value":"${= result.id}","variable":"panelId"}],"tri... / (none)`
  - `r0.body.1.2.0.2.0.layout.height: 32 / 40`
  - `r0.body.1.2.0.2.0.0.layout.width: 16 / {"fill":0}; r0.body.1.2.0.2.0.0.props.crossAxisAlignment: "center" / (none); r0.body.1.2.0.2.0.0.props.crossAxisCount: (none) / 1`
- tool/vocabulary/corpus/b08/answers/glucose-log.txt ### Insights @1440: 98 of 128 nodes the same; 4 differ, 26 only in the code's, 2 only in the definition's
  - `r0.body.1.2.1.2.0.0.children: ["r0.body.1.2.1.2.0.0.0","r0.body.1.2.1.2.0.0.1","r0.body.1.2.1.2.0.0.2","r0.body.1.2.1... / ["r0.body.1.2.1.2.0.0.0"]`
  - `r0.body.1.2.1.2.0.0.0.layout.flex: 1 / (none); r0.body.1.2.1.2.0.0.0.props.crossAxisAlignment: "center" / (none); r0.body.1.2.1.2.0.0.0.props.spacing: 4 / (none)`
  - `r0.body.1.2.1.2.0.0.0.0.layout.squeezable: true / (none); r0.body.1.2.1.2.0.0.0.0.layout.width.hug: 0 / (none); r0.body.1.2.1.2.0.0.0.0.layout.width.fill: (none) / 0`
- tool/vocabulary/corpus/b08/answers/glucose-log.txt ### Insights @834: 98 of 128 nodes the same; 4 differ, 26 only in the code's, 2 only in the definition's
  - `r0.body.1.2.1.2.0.0.children: ["r0.body.1.2.1.2.0.0.0","r0.body.1.2.1.2.0.0.1","r0.body.1.2.1.2.0.0.2","r0.body.1.2.1... / ["r0.body.1.2.1.2.0.0.0"]`
  - `r0.body.1.2.1.2.0.0.0.layout.flex: 1 / (none); r0.body.1.2.1.2.0.0.0.props.crossAxisAlignment: "center" / (none); r0.body.1.2.1.2.0.0.0.props.spacing: 4 / (none)`
  - `r0.body.1.2.1.2.0.0.0.0.layout.squeezable: true / (none); r0.body.1.2.1.2.0.0.0.0.layout.width.hug: 0 / (none); r0.body.1.2.1.2.0.0.0.0.layout.width.fill: (none) / 0`
- tool/vocabulary/corpus/b08/answers/glucose-log.txt ### Insights @390: 60 of 90 nodes the same; 4 differ, 26 only in the code's, 2 only in the definition's
  - `r0.body.1.2.1.2.0.0.children: ["r0.body.1.2.1.2.0.0.0","r0.body.1.2.1.2.0.0.1","r0.body.1.2.1.2.0.0.2","r0.body.1.2.1... / ["r0.body.1.2.1.2.0.0.0"]`
  - `r0.body.1.2.1.2.0.0.0.layout.flex: 1 / (none); r0.body.1.2.1.2.0.0.0.props.crossAxisAlignment: "center" / (none); r0.body.1.2.1.2.0.0.0.props.spacing: 4 / (none)`
  - `r0.body.1.2.1.2.0.0.0.0.layout.squeezable: true / (none); r0.body.1.2.1.2.0.0.0.0.layout.width.hug: 0 / (none); r0.body.1.2.1.2.0.0.0.0.layout.width.fill: (none) / 0`
- tool/vocabulary/corpus/b08/answers/lab-instrument.txt ### Samples @1440: 83 of 85 nodes the same; 2 differ, 0 only in the code's, 8 only in the definition's
  - `r0.body.1.2.0.1.6.children: ["r0.body.1.2.0.1.6.0"] / ["r0.body.1.2.0.1.6.0","r0.body.1.2.0.1.6.1"]; r0.body.1.2.0.1.6.decoration.dashPattern: [4,3] / (none); r0.body.1.2.0.1.6.decoration.radius: 6 / 8`
  - `r0.body.1.2.0.1.6.0.layout.height: {"hug":0} / 40; r0.body.1.2.0.1.6.0.layout.width.hug: 0 / (none); r0.body.1.2.0.1.6.0.layout.width.fill: (none) / 0`
  - `only in the definition's: r0.body.1.2.0.1.6.0.0 gridView, r0.body.1.2.0.1.6.0.0.0 column, r0.body.1.2.0.1.6.0.0.0.0 row, r0.body.1.2.0.1.6.0.0.0.0.0 text`
- tool/vocabulary/corpus/b08/answers/lab-instrument.txt ### Samples @834: 83 of 85 nodes the same; 2 differ, 0 only in the code's, 8 only in the definition's
  - `r0.body.1.2.0.1.6.children: ["r0.body.1.2.0.1.6.0"] / ["r0.body.1.2.0.1.6.0","r0.body.1.2.0.1.6.1"]; r0.body.1.2.0.1.6.decoration.dashPattern: [4,3] / (none); r0.body.1.2.0.1.6.decoration.radius: 6 / 8`
  - `r0.body.1.2.0.1.6.0.layout.height: {"hug":0} / 40; r0.body.1.2.0.1.6.0.layout.width.hug: 0 / (none); r0.body.1.2.0.1.6.0.layout.width.fill: (none) / 0`
  - `only in the definition's: r0.body.1.2.0.1.6.0.0 gridView, r0.body.1.2.0.1.6.0.0.0 column, r0.body.1.2.0.1.6.0.0.0.0 row, r0.body.1.2.0.1.6.0.0.0.0.0 text`
- tool/vocabulary/corpus/b08/answers/lab-instrument.txt ### Samples @390: 63 of 65 nodes the same; 2 differ, 0 only in the code's, 8 only in the definition's
  - `r0.body.1.2.0.1.6.children: ["r0.body.1.2.0.1.6.0"] / ["r0.body.1.2.0.1.6.0","r0.body.1.2.0.1.6.1"]; r0.body.1.2.0.1.6.decoration.dashPattern: [4,3] / (none); r0.body.1.2.0.1.6.decoration.radius: 6 / 8`
  - `r0.body.1.2.0.1.6.0.layout.height: {"hug":0} / 40; r0.body.1.2.0.1.6.0.layout.width.hug: 0 / (none); r0.body.1.2.0.1.6.0.layout.width.fill: (none) / 0`
  - `only in the definition's: r0.body.1.2.0.1.6.0.0 gridView, r0.body.1.2.0.1.6.0.0.0 column, r0.body.1.2.0.1.6.0.0.0.0 row, r0.body.1.2.0.1.6.0.0.0.0.0 text`
- tool/vocabulary/corpus/b09/answers/census-explorer.txt ### Place profile @1440: 101 of 120 nodes the same; 11 differ, 8 only in the code's, 8 only in the definition's
  - `r0.body.1.2.3.1.actions: [{"actions":[{"type":"setVariable","value":"${= result.column}","variable":"sortCol"},{... / (none)`
  - `r0.body.1.2.3.1.0.children: (none) / ["r0.body.1.2.3.1.0.0"]`
  - `r0.body.1.2.3.1.1.0.bind.data: "${= sortBy(sortDir==\"asc\"?sortBy(ages,r=>r[sortCol]):sortByDesc(ages,r=>r[sortCol]),... / "${= sortDir==\"asc\"?sortBy(ages,r=>r[sortCol]):sortByDesc(ages,r=>r[sortCol])}"`
- tool/vocabulary/corpus/b09/answers/census-explorer.txt ### Place profile @834: 101 of 120 nodes the same; 11 differ, 8 only in the code's, 8 only in the definition's
  - `r0.body.1.2.3.1.actions: [{"actions":[{"type":"setVariable","value":"${= result.column}","variable":"sortCol"},{... / (none)`
  - `r0.body.1.2.3.1.0.children: (none) / ["r0.body.1.2.3.1.0.0"]`
  - `r0.body.1.2.3.1.1.0.bind.data: "${= sortBy(sortDir==\"asc\"?sortBy(ages,r=>r[sortCol]):sortByDesc(ages,r=>r[sortCol]),... / "${= sortDir==\"asc\"?sortBy(ages,r=>r[sortCol]):sortByDesc(ages,r=>r[sortCol])}"`
- tool/vocabulary/corpus/b09/answers/census-explorer.txt ### Place profile @390: 81 of 100 nodes the same; 11 differ, 8 only in the code's, 8 only in the definition's
  - `r0.body.1.2.3.1.actions: [{"actions":[{"type":"setVariable","value":"${= result.column}","variable":"sortCol"},{... / (none)`
  - `r0.body.1.2.3.1.0.children: (none) / ["r0.body.1.2.3.1.0.0"]`
  - `r0.body.1.2.3.1.1.0.bind.data: "${= sortBy(sortDir==\"asc\"?sortBy(ages,r=>r[sortCol]):sortByDesc(ages,r=>r[sortCol]),... / "${= sortDir==\"asc\"?sortBy(ages,r=>r[sortCol]):sortByDesc(ages,r=>r[sortCol])}"`
- docs/reference/notation/lists.md block 4 @1440: 7 of 18 nodes the same; 5 differ, 6 only in the code's, 2 only in the definition's
  - `r0.body.0.0.0.0.children: ["r0.body.0.0.0.0.0","r0.body.0.0.0.0.1"] / ["r0.body.0.0.0.0.0"]`
  - `r0.body.0.0.0.0.0.layout.flex: 1 / (none); r0.body.0.0.0.0.0.props.crossAxisAlignment: "center" / (none); r0.body.0.0.0.0.0.props.spacing: 4 / (none)`
  - `r0.body.0.0.0.0.0.0.layout.squeezable: true / (none); r0.body.0.0.0.0.0.0.layout.width.hug: 0 / (none); r0.body.0.0.0.0.0.0.layout.width.fill: (none) / 0`
- docs/reference/notation/lists.md block 4 @834: 7 of 18 nodes the same; 5 differ, 6 only in the code's, 2 only in the definition's
  - `r0.body.0.0.0.0.children: ["r0.body.0.0.0.0.0","r0.body.0.0.0.0.1"] / ["r0.body.0.0.0.0.0"]`
  - `r0.body.0.0.0.0.0.layout.flex: 1 / (none); r0.body.0.0.0.0.0.props.crossAxisAlignment: "center" / (none); r0.body.0.0.0.0.0.props.spacing: 4 / (none)`
  - `r0.body.0.0.0.0.0.0.layout.squeezable: true / (none); r0.body.0.0.0.0.0.0.layout.width.hug: 0 / (none); r0.body.0.0.0.0.0.0.layout.width.fill: (none) / 0`
- docs/reference/notation/lists.md block 4 @390: 7 of 18 nodes the same; 5 differ, 6 only in the code's, 2 only in the definition's
  - `r0.body.0.0.0.0.children: ["r0.body.0.0.0.0.0","r0.body.0.0.0.0.1"] / ["r0.body.0.0.0.0.0"]`
  - `r0.body.0.0.0.0.0.layout.flex: 1 / (none); r0.body.0.0.0.0.0.props.crossAxisAlignment: "center" / (none); r0.body.0.0.0.0.0.props.spacing: 4 / (none)`
  - `r0.body.0.0.0.0.0.0.layout.squeezable: true / (none); r0.body.0.0.0.0.0.0.layout.width.hug: 0 / (none); r0.body.0.0.0.0.0.0.layout.width.fill: (none) / 0`
- docs/reference/notation/lists.md block 10 @1440: 8 of 41 nodes the same; 11 differ, 22 only in the code's, 4 only in the definition's; document keys variables
  - `r0.body.0.0.1.children: ["r0.body.0.0.1.0","r0.body.0.0.1.1","r0.body.0.0.1.2"] / ["r0.body.0.0.1.0","r0.body.0.0.1.1"]`
  - `r0.body.0.0.1.0.children: ["r0.body.0.0.1.0.0","r0.body.0.0.1.0.1","r0.body.0.0.1.0.2","r0.body.0.0.1.0.3"] / ["r0.body.0.0.1.0.0"]`
  - `r0.body.0.0.1.0.0.layout.width: 16 / {"fill":0}; r0.body.0.0.1.0.0.props.crossAxisAlignment: "center" / (none); r0.body.0.0.1.0.0.props.crossAxisCount: (none) / 1`
- docs/reference/notation/lists.md block 10 @834: 8 of 41 nodes the same; 11 differ, 22 only in the code's, 4 only in the definition's; document keys variables
  - `r0.body.0.0.1.children: ["r0.body.0.0.1.0","r0.body.0.0.1.1","r0.body.0.0.1.2"] / ["r0.body.0.0.1.0","r0.body.0.0.1.1"]`
  - `r0.body.0.0.1.0.children: ["r0.body.0.0.1.0.0","r0.body.0.0.1.0.1","r0.body.0.0.1.0.2","r0.body.0.0.1.0.3"] / ["r0.body.0.0.1.0.0"]`
  - `r0.body.0.0.1.0.0.layout.width: 16 / {"fill":0}; r0.body.0.0.1.0.0.props.crossAxisAlignment: "center" / (none); r0.body.0.0.1.0.0.props.crossAxisCount: (none) / 1`
- docs/reference/notation/lists.md block 10 @390: 8 of 41 nodes the same; 11 differ, 22 only in the code's, 4 only in the definition's; document keys variables
  - `r0.body.0.0.1.children: ["r0.body.0.0.1.0","r0.body.0.0.1.1","r0.body.0.0.1.2"] / ["r0.body.0.0.1.0","r0.body.0.0.1.1"]`
  - `r0.body.0.0.1.0.children: ["r0.body.0.0.1.0.0","r0.body.0.0.1.0.1","r0.body.0.0.1.0.2","r0.body.0.0.1.0.3"] / ["r0.body.0.0.1.0.0"]`
  - `r0.body.0.0.1.0.0.layout.width: 16 / {"fill":0}; r0.body.0.0.1.0.0.props.crossAxisAlignment: "center" / (none); r0.body.0.0.1.0.0.props.crossAxisCount: (none) / 1`

### computed

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Shopping list @1440: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Shopping list @834: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Shopping list @390: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Week @1440: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Week @834: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Week @390: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Add a recipe @1440: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Add a recipe @834: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Add a recipe @390: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Recipes @1440: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Recipes @834: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Recipes @390: equal

### App (family) (renamed together: App, Brand, Footer, Heading, IconTile, Link, Main, Nav, NavItem, NavSection, Page, Pane, Section, Sidebar)

- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @1440: 14 of 33 nodes the same; 6 differ, 13 only in the code's, 13 only in the definition's; issues: line 5:54: AppDict.txt:3: AppDict: "onEdgeSwipeRight" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop. / line 5:82: AppDict.txt:3: AppDict: "onEdgeSwipeLeft" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop.
  - `r0.body.0.props.crossAxisAlignment: "stretch" / "start"; r0.body.0.props.scrollable: (none) / true`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.flex: 1 / (none); r0.body.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.height: {"hug":0} / 0; r0.body.0.0.0.layout.padding: 16 / (none)`
- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @834: 14 of 33 nodes the same; 6 differ, 13 only in the code's, 13 only in the definition's; issues: line 5:54: AppDict.txt:3: AppDict: "onEdgeSwipeRight" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop. / line 5:82: AppDict.txt:3: AppDict: "onEdgeSwipeLeft" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop.
  - `r0.body.0.props.crossAxisAlignment: "stretch" / "start"; r0.body.0.props.scrollable: (none) / true`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.flex: 1 / (none); r0.body.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.height: {"hug":0} / 0; r0.body.0.0.0.layout.padding: 16 / (none)`
- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @390: 14 of 33 nodes the same; 6 differ, 13 only in the code's, 13 only in the definition's; issues: line 5:54: AppDict.txt:3: AppDict: "onEdgeSwipeRight" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop. / line 5:82: AppDict.txt:3: AppDict: "onEdgeSwipeLeft" is not an event the notation has here. Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), onHover, onFocus, onBlur, onSubmit, onDrop.
  - `r0.body.0.props.crossAxisAlignment: "stretch" / "start"; r0.body.0.props.scrollable: (none) / true`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.flex: 1 / (none); r0.body.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.height: {"hug":0} / 0; r0.body.0.0.0.layout.padding: 16 / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @1440: 35 of 63 nodes the same; 6 differ, 22 only in the code's, 0 only in the definition's; document keys roots, variables; issues: line 3:49: BrandDict.txt:3: BrandDict: "font" is not a parameter the notation has.
  - `r0.body.0.4.0.bind: {"props.color":"${= (true)?\"#FF2563EB\":\"#FF6B7280\"}"} / (none); r0.body.0.4.0.props.color: (none) / "#FF2563EB"`
  - `r0.body.0.4.1.bind: {"props.style.color":"${= (true)?\"#FF2563EB\":\"#FF374151\"}","props.style.fontWeight"... / (none); r0.body.0.4.1.props.style.color: "#FF111827" / "#FF2563EB"; r0.body.0.4.1.props.style.fontWeight: (none) / 600`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1"] / ["r0.body.1.0.0"]`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @834: 35 of 63 nodes the same; 6 differ, 22 only in the code's, 0 only in the definition's; document keys roots, variables; issues: line 3:49: BrandDict.txt:3: BrandDict: "font" is not a parameter the notation has.
  - `r0.body.0.4.0.bind: {"props.color":"${= (true)?\"#FF2563EB\":\"#FF6B7280\"}"} / (none); r0.body.0.4.0.props.color: (none) / "#FF2563EB"`
  - `r0.body.0.4.1.bind: {"props.style.color":"${= (true)?\"#FF2563EB\":\"#FF374151\"}","props.style.fontWeight"... / (none); r0.body.0.4.1.props.style.color: "#FF111827" / "#FF2563EB"; r0.body.0.4.1.props.style.fontWeight: (none) / 600`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1"] / ["r0.body.1.0.0"]`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @390: 36 of 41 nodes the same; 5 differ, 0 only in the code's, 0 only in the definition's; issues: line 3:49: BrandDict.txt:3: BrandDict: "font" is not a parameter the notation has.
  - `r0.body.0.4.0.bind: {"props.color":"${= (true)?\"#FF2563EB\":\"#FF6B7280\"}"} / (none); r0.body.0.4.0.props.color: (none) / "#FF2563EB"`
  - `r0.body.0.4.1.bind: {"props.style.color":"${= (true)?\"#FF2563EB\":\"#FF374151\"}","props.style.fontWeight"... / (none); r0.body.0.4.1.props.style.color: "#FF111827" / "#FF2563EB"; r0.body.0.4.1.props.style.fontWeight: (none) / 600`
  - `r0.body.1.0.0.props.style.fontFamily: "serif" / (none)`
- tool/vocabulary/corpus/b09/answers/tractor-guidance.txt ### Implement @1440: 38 of 41 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's; issues: line 7:36: AppDict.txt:3: AppDict: "theme" is not a parameter the notation has.
  - `r0.body.0.0.media: [{"maxWidth":699,"patch":{"props":{"spacing":12}}}] / [{"maxWidth":699,"patch":{"props":{"runSpacing":12,"spacing":12,"wrap":true}}}]`
  - `r0.body.0.0.0.media: (none) / [{"maxWidth":699,"patch":{"layout":{"basis":247.9,"flex":1,"width":{"fill":0}}}}]`
  - `r0.body.0.0.0.1.props.style.fontSize: 13 / 18`
- tool/vocabulary/corpus/b09/answers/tractor-guidance.txt ### Implement @834: 38 of 41 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's; issues: line 7:36: AppDict.txt:3: AppDict: "theme" is not a parameter the notation has.
  - `r0.body.0.0.media: [{"maxWidth":699,"patch":{"props":{"spacing":12}}}] / [{"maxWidth":699,"patch":{"props":{"runSpacing":12,"spacing":12,"wrap":true}}}]`
  - `r0.body.0.0.0.media: (none) / [{"maxWidth":699,"patch":{"layout":{"basis":247.9,"flex":1,"width":{"fill":0}}}}]`
  - `r0.body.0.0.0.1.props.style.fontSize: 13 / 18`
- tool/vocabulary/corpus/b09/answers/tractor-guidance.txt ### Implement @390: 40 of 41 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's; issues: line 7:36: AppDict.txt:3: AppDict: "theme" is not a parameter the notation has.
  - `r0.body.0.0.0.1.props.style.fontSize: 13 / 18`
- docs/reference/notation/NOTATION.md block 4 @1440: 13 of 26 nodes the same; 3 differ, 10 only in the code's, 0 only in the definition's; document keys roots
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.layout.width.fill: 0 / (none)`
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- docs/reference/notation/NOTATION.md block 4 @834: 13 of 26 nodes the same; 3 differ, 10 only in the code's, 0 only in the definition's; document keys roots
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.layout.width.fill: 0 / (none)`
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- docs/reference/notation/NOTATION.md block 4 @390: 15 of 16 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.decoration.strokeSides: "left" / "right"`
- docs/reference/notation/navigation.md block 3 @1440: 6 of 18 nodes the same; 2 differ, 10 only in the code's, 0 only in the definition's; document keys roots, variables
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
  - `roots: ["r0","r1"] / ["r0"]`
- docs/reference/notation/navigation.md block 3 @834: 6 of 18 nodes the same; 2 differ, 10 only in the code's, 0 only in the definition's; document keys roots, variables
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
  - `roots: ["r0","r1"] / ["r0"]`
- docs/reference/notation/navigation.md block 3 @390: equal up to spelling

### Page (family) (renamed together: App, Brand, Footer, Heading, IconTile, Link, Main, Nav, NavItem, NavSection, Page, Pane, Section, Sidebar)

- tool/vocabulary/corpus/b08/answers/typesetter-pages.txt ### Spread @1440: 48 of 153 nodes the same; 6 differ, 99 only in the code's, 69 only in the definition's; document keys roots, variables
  - `r0.body.0.decoration.strokeSides: "r0.body.1.0.2.0.0.1" / "r0.body.1.2.0.0.1"`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3"]; r0.body.1.props.crossAxisAlignment: "stretch" / "start"; r0.body.1.props.scrollable: (none) / true`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1","r0.body.1.0.2"] / ["r0.body.1.0.0","r0.body.1.0.1"]; r0.body.1.0.layout.flex: 1 / (none); r0.body.1.0.layout.height.fill: 0 / (none)`
- tool/vocabulary/corpus/b08/answers/typesetter-pages.txt ### Spread @834: 48 of 153 nodes the same; 6 differ, 99 only in the code's, 69 only in the definition's; document keys roots, variables
  - `r0.body.0.decoration.strokeSides: "r0.body.1.0.2.0.0.1" / "r0.body.1.2.0.0.1"`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3"]; r0.body.1.props.crossAxisAlignment: "stretch" / "start"; r0.body.1.props.scrollable: (none) / true`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1","r0.body.1.0.2"] / ["r0.body.1.0.0","r0.body.1.0.1"]; r0.body.1.0.layout.flex: 1 / (none); r0.body.1.0.layout.height.fill: 0 / (none)`
- tool/vocabulary/corpus/b08/answers/typesetter-pages.txt ### Spread @390: 48 of 125 nodes the same; 6 differ, 71 only in the code's, 69 only in the definition's; document keys variables
  - `r0.body.0.decoration.strokeSides: "r0.body.1.0.2.0.0.1" / "r0.body.1.2.0.0.1"`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3"]; r0.body.1.props.crossAxisAlignment: "stretch" / "start"; r0.body.1.props.scrollable: (none) / true`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1","r0.body.1.0.2"] / ["r0.body.1.0.0","r0.body.1.0.1"]; r0.body.1.0.layout.flex: 1 / (none); r0.body.1.0.layout.height.fill: 0 / (none)`
- docs/reference/notation/lists.md block 4 @1440: 17 of 18 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
- docs/reference/notation/lists.md block 4 @834: 17 of 18 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
- docs/reference/notation/lists.md block 4 @390: 17 of 18 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
- docs/reference/notation/lists.md block 10 @1440: 38 of 41 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.0.0.0.layout.height: 40.0 / {"hug":0}`
  - `r0.body.0.0.0.1.layout.height: 40.0 / {"hug":0}`
- docs/reference/notation/lists.md block 10 @834: 38 of 41 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.0.0.0.layout.height: 40.0 / {"hug":0}`
  - `r0.body.0.0.0.1.layout.height: 40.0 / {"hug":0}`
- docs/reference/notation/lists.md block 10 @390: 38 of 41 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.0.0.0.layout.height: 40.0 / {"hug":0}`
  - `r0.body.0.0.0.1.layout.height: 40.0 / {"hug":0}`
