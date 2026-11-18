# The closure test (generated)

Written by `tool/dictionary_closure.dart` (track B, step B2; design note 23). Do not edit: run it again.

Each word below is written out in Dart by the expander today. `dictionary/<Word>.txt` writes it in the notation's `define` form, in base words only. Each use (`dictionary/uses/`) is expanded once through the code and once through the definition (the word renamed `<Word>Dict`, since a built-in word wins over a definition of its name), at 1440, 834 and 390 wide, with the open vocabulary and no design system, and the two documents are compared node by node, ids aside (`tool/dictionary/closure.dart`).

| word | | expansions the same | up to spelling | nodes the same | up to spelling |
|---|---|---|---|---|---|
| `App` | does not close | 0 of 15 | 0 | 175 of 501 | 175 |
| `Brand` | does not close | 3 of 9 | 3 | 351 of 372 | 351 |
| `ConfirmDialog` | does not close | 0 of 3 | 0 | 102 of 141 | 102 |
| `Dialog` | does not close | 0 of 15 | 0 | 123 of 676 | 123 |
| `Dots` | does not close | 3 of 9 | 3 | 597 of 609 | 597 |
| `Drawer` | does not close | 0 of 3 | 0 | 7 of 174 | 7 |
| `Footer` | does not close | 0 of 9 | 0 | 303 of 333 | 303 |
| `H1` | does not close | 3 of 6 | 3 | 27 of 30 | 27 |
| `H2` | does not close | 3 of 6 | 3 | 24 of 27 | 24 |
| `H3` | does not close | 3 of 6 | 3 | 24 of 27 | 24 |
| `Heading` | does not close | 0 of 15 | 0 | 877 of 907 | 877 |
| `IconTile` | does not close | 0 of 9 | 0 | 450 of 471 | 450 |
| `Lightbox` | does not close | 0 of 6 | 0 | 211 of 403 | 211 |
| `Link` | does not close | 3 of 12 | 3 | 724 of 736 | 724 |
| `Main` | does not close | 4 of 15 | 4 | 545 of 883 | 545 |
| `Menu` | does not close | 0 of 6 | 0 | 321 of 735 | 321 |
| `Nav` | does not close | 0 of 15 | 0 | 703 of 1140 | 703 |
| `NavItem` | does not close | 0 of 18 | 9 | 1687 of 1787 | 1722 |
| `NavSection` | does not close | 3 of 9 | 3 | 257 of 272 | 257 |
| `Page` | does not close | 0 of 9 | 0 | 365 of 608 | 365 |
| `Pane` | does not close | 0 of 18 | 0 | 1741 of 1765 | 1741 |
| `Popover` | does not close | 0 of 6 | 0 | 354 of 654 | 354 |
| `Section` | does not close | 3 of 15 | 3 | 697 of 717 | 697 |
| `Sheet` | does not close | 0 of 12 | 0 | 210 of 828 | 210 |
| `Shortcut` | does not close | 0 of 18 | 0 | 235 of 618 | 235 |
| `Sidebar` | does not close | 2 of 12 | 2 | 599 of 769 | 599 |
| `SidebarFooter` | does not close | 0 of 3 | 0 | 39 of 69 | 39 |
| `Table` | does not close | 0 of 18 | 0 | 1305 of 1680 | 1305 |
| `App (family)` | does not close | 0 of 15 | 1 | 161 of 501 | 176 |
| `Page (family)` | does not close | 2 of 9 | 2 | 311 of 608 | 317 |

A use counts as the same when its two documents are equal and the definition's side has no issue the code's has not. "Nodes the same" counts the code's nodes that the definition's document has, equal, at the same place.

## By use

### App

- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @1440: 19 of 33 nodes the same; 5 differ, 9 only in the code's, 8 only in the definition's
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0; r0.body.0.props.crossAxisAlignment: "stretch" / "start"`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.flex: 1 / (none); r0.body.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.height: {"hug":0} / 0; r0.body.0.0.0.layout.padding: 16 / (none)`
- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @834: 19 of 33 nodes the same; 5 differ, 9 only in the code's, 8 only in the definition's
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0; r0.body.0.props.crossAxisAlignment: "stretch" / "start"`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.flex: 1 / (none); r0.body.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.height: {"hug":0} / 0; r0.body.0.0.0.layout.padding: 16 / (none)`
- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @390: 20 of 33 nodes the same; 4 differ, 9 only in the code's, 8 only in the definition's
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
- tool/vocabulary/corpus/b09/answers/tractor-guidance.txt ### Implement @1440: 4 of 41 nodes the same; 5 differ, 32 only in the code's, 31 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.0.0.layout.padding: [24,14,24,14] / (none); r0.body.0.0.media: [{"maxWidth":699,"patch":{"props":{"spacing":12}}}] / [{"maxWidth":1023,"patch":{"props":{"runSpacing":12,"wrap":true}}}]; r0.body.0.0.props.spacing: 24 / 16`
  - `r0.body.0.0.0.media: (none) / [{"maxWidth":1023,"patch":{"props":{"runSpacing":8,"wrap":true}}}]`
- tool/vocabulary/corpus/b09/answers/tractor-guidance.txt ### Implement @834: 4 of 41 nodes the same; 5 differ, 32 only in the code's, 31 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.0.0.layout.padding: [24,14,24,14] / (none); r0.body.0.0.media: [{"maxWidth":699,"patch":{"props":{"spacing":12}}}] / [{"maxWidth":1023,"patch":{"props":{"runSpacing":12,"wrap":true}}}]; r0.body.0.0.props.spacing: 24 / 16`
  - `r0.body.0.0.0.media: (none) / [{"maxWidth":1023,"patch":{"props":{"runSpacing":8,"wrap":true}}}]`
- tool/vocabulary/corpus/b09/answers/tractor-guidance.txt ### Implement @390: 5 of 41 nodes the same; 4 differ, 32 only in the code's, 31 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0`
  - `r0.body.0.0.layout.padding: [24,14,24,14] / (none); r0.body.0.0.props.spacing: 24 / 16`
  - `r0.body.0.0.0.1.props.style.fontSize: 13 / 18`
- docs/reference/notation/NOTATION.md block 4 @1440: 12 of 26 nodes the same; 4 differ, 10 only in the code's, 0 only in the definition's; document keys roots
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0; r0.body.0.media: [{"maxWidth":699,"patch":{"visible":false}}] / (none)`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]; r0.body.1.layout.height.fill: 0 / (none); r0.body.1.layout.height.hug: (none) / 0`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.layout.width.fill: 0 / (none)`
- docs/reference/notation/NOTATION.md block 4 @834: 12 of 26 nodes the same; 4 differ, 10 only in the code's, 0 only in the definition's; document keys roots
  - `r0.body.0.layout.height.fill: 0 / (none); r0.body.0.layout.height.hug: (none) / 0; r0.body.0.media: [{"maxWidth":699,"patch":{"visible":false}}] / (none)`
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

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @1440: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @834: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @390: equal
- docs/reference/notation/navigation.md block 1 @1440: 15 of 17 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.layout.padding: (none) / [8,6,8,10]`
  - `r0.body.0.0.0.1.props.style.fontSize: 17 / 15`
- docs/reference/notation/navigation.md block 1 @834: 15 of 17 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.layout.padding: (none) / [8,6,8,10]`
  - `r0.body.0.0.0.1.props.style.fontSize: 17 / 15`
- docs/reference/notation/navigation.md block 1 @390: 15 of 17 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.layout.padding: (none) / [8,6,8,10]`
  - `r0.body.0.0.0.1.props.style.fontSize: 17 / 15`
- docs/reference/notation/navigation.md block 5 @1440: 56 of 62 nodes the same; 2 differ, 4 only in the code's, 0 only in the definition's
  - `r0.body.0.0.1.children: ["r0.body.0.0.1.0","r0.body.0.0.1.1"] / (none); r0.body.0.0.1.props.crossAxisAlignment: "start" / (none); r0.body.0.0.1.props.spacing: 0 / (none)`
  - `r1.body.0.0.1.children: ["r1.body.0.0.1.0","r1.body.0.0.1.1"] / (none); r1.body.0.0.1.layout.squeezable: (none) / true; r1.body.0.0.1.props.crossAxisAlignment: "start" / (none)`
  - `only in the code's: r0.body.0.0.1.0 text, r0.body.0.0.1.1 text, r1.body.0.0.1.0 text, r1.body.0.0.1.1 text`
- docs/reference/notation/navigation.md block 5 @834: 56 of 62 nodes the same; 2 differ, 4 only in the code's, 0 only in the definition's
  - `r0.body.0.0.1.children: ["r0.body.0.0.1.0","r0.body.0.0.1.1"] / (none); r0.body.0.0.1.props.crossAxisAlignment: "start" / (none); r0.body.0.0.1.props.spacing: 0 / (none)`
  - `r1.body.0.0.1.children: ["r1.body.0.0.1.0","r1.body.0.0.1.1"] / (none); r1.body.0.0.1.layout.squeezable: (none) / true; r1.body.0.0.1.props.crossAxisAlignment: "start" / (none)`
  - `only in the code's: r0.body.0.0.1.0 text, r0.body.0.0.1.1 text, r1.body.0.0.1.0 text, r1.body.0.0.1.1 text`
- docs/reference/notation/navigation.md block 5 @390: 27 of 30 nodes the same; 1 differ, 2 only in the code's, 0 only in the definition's
  - `r0.body.0.0.1.children: ["r0.body.0.0.1.0","r0.body.0.0.1.1"] / (none); r0.body.0.0.1.layout.squeezable: (none) / true; r0.body.0.0.1.props.crossAxisAlignment: "start" / (none)`
  - `only in the code's: r0.body.0.0.1.0 text, r0.body.0.0.1.1 text`

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

- tool/vocabulary/corpus/b03/answers/gym-class-booking.txt ### Schedule @1440: 110 of 112 nodes the same; 2 differ, 0 only in the code's, 2 only in the definition's; document keys variables
  - `r0.body.1.2.2.0.0.0.1.0.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.2.2.0.0.0.1.0.layout.constraints: {"minHeight":40} / (none); r0.body.1.2.2.0.0.0.1.0.layout.height: {"hug":0} / 16`
  - `r0.body.1.2.2.0.0.0.1.0.0.props.maxLines: 1 / (none); r0.body.1.2.2.0.0.0.1.0.0.props.overflow: "ellipsis" / (none); r0.body.1.2.2.0.0.0.1.0.0.props.style: {"color":"#FF9CA3AF","fontSize":11} / (none)`
  - `variables.page_variables: [{"name":"tab","type":"text","value":"schedule"},{"name":"day","type":"integer","value"... / [{"name":"tab","type":"text","value":"schedule"},{"name":"day","type":"integer","value"...`
- tool/vocabulary/corpus/b03/answers/gym-class-booking.txt ### Schedule @834: 110 of 112 nodes the same; 2 differ, 0 only in the code's, 2 only in the definition's; document keys variables
  - `r0.body.1.2.2.0.0.0.1.0.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.2.2.0.0.0.1.0.layout.constraints: {"minHeight":40} / (none); r0.body.1.2.2.0.0.0.1.0.layout.height: {"hug":0} / 16`
  - `r0.body.1.2.2.0.0.0.1.0.0.props.maxLines: 1 / (none); r0.body.1.2.2.0.0.0.1.0.0.props.overflow: "ellipsis" / (none); r0.body.1.2.2.0.0.0.1.0.0.props.style: {"color":"#FF9CA3AF","fontSize":11} / (none)`
  - `variables.page_variables: [{"name":"tab","type":"text","value":"schedule"},{"name":"day","type":"integer","value"... / [{"name":"tab","type":"text","value":"schedule"},{"name":"day","type":"integer","value"...`
- tool/vocabulary/corpus/b03/answers/gym-class-booking.txt ### Schedule @390: 86 of 88 nodes the same; 2 differ, 0 only in the code's, 2 only in the definition's; document keys variables
  - `r0.body.1.2.2.0.0.0.1.0.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.2.2.0.0.0.1.0.layout.constraints: {"minHeight":40} / (none); r0.body.1.2.2.0.0.0.1.0.layout.height: {"hug":0} / 16`
  - `r0.body.1.2.2.0.0.0.1.0.0.props.maxLines: 1 / (none); r0.body.1.2.2.0.0.0.1.0.0.props.overflow: "ellipsis" / (none); r0.body.1.2.2.0.0.0.1.0.0.props.style: {"color":"#FF9CA3AF","fontSize":11} / (none)`
  - `variables.page_variables: [{"name":"tab","type":"text","value":"schedule"},{"name":"day","type":"integer","value"... / [{"name":"tab","type":"text","value":"schedule"},{"name":"day","type":"integer","value"...`
- tool/vocabulary/corpus/b08/answers/watch-face-complications.txt ### Face gallery @1440: equal
- tool/vocabulary/corpus/b08/answers/watch-face-complications.txt ### Face gallery @834: equal
- tool/vocabulary/corpus/b08/answers/watch-face-complications.txt ### Face gallery @390: equal
- tool/vocabulary/corpus-define/d02/answers/signup-sheet.txt ### Organiser @1440: 80 of 82 nodes the same; 2 differ, 0 only in the code's, 2 only in the definition's; document keys variables
  - `r0.body.1.2.2.1.0.0.1.0.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.2.2.1.0.0.1.0.layout.constraints: {"minHeight":40} / (none); r0.body.1.2.2.1.0.0.1.0.layout.height: {"hug":0} / 16`
  - `r0.body.1.2.2.1.0.0.1.0.0.props.maxLines: 1 / (none); r0.body.1.2.2.1.0.0.1.0.0.props.overflow: "ellipsis" / (none); r0.body.1.2.2.1.0.0.1.0.0.props.style: {"color":"#FF9CA3AF","fontSize":11} / (none)`
  - `variables.page_variables: [{"name":"shifts","type":"list","value":[{"day":"Mon","filled":4,"id":"mon-am","needed"... / [{"name":"shifts","type":"list","value":[{"day":"Mon","filled":4,"id":"mon-am","needed"...`
- tool/vocabulary/corpus-define/d02/answers/signup-sheet.txt ### Organiser @834: 80 of 82 nodes the same; 2 differ, 0 only in the code's, 2 only in the definition's; document keys variables
  - `r0.body.1.2.2.1.0.0.1.0.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.2.2.1.0.0.1.0.layout.constraints: {"minHeight":40} / (none); r0.body.1.2.2.1.0.0.1.0.layout.height: {"hug":0} / 16`
  - `r0.body.1.2.2.1.0.0.1.0.0.props.maxLines: 1 / (none); r0.body.1.2.2.1.0.0.1.0.0.props.overflow: "ellipsis" / (none); r0.body.1.2.2.1.0.0.1.0.0.props.style: {"color":"#FF9CA3AF","fontSize":11} / (none)`
  - `variables.page_variables: [{"name":"shifts","type":"list","value":[{"day":"Mon","filled":4,"id":"mon-am","needed"... / [{"name":"shifts","type":"list","value":[{"day":"Mon","filled":4,"id":"mon-am","needed"...`
- tool/vocabulary/corpus-define/d02/answers/signup-sheet.txt ### Organiser @390: 62 of 64 nodes the same; 2 differ, 0 only in the code's, 2 only in the definition's; document keys variables
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

- written: a website section's title @1440: equal
- written: a website section's title @834: equal
- written: a website section's title @390: equal
- written: a panel's heading in an app @1440: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 14 / 24; r0.body.0.0.props.style.fontWeight: 600 / 700`
- written: a panel's heading in an app @834: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 14 / 24; r0.body.0.0.props.style.fontWeight: 600 / 700`
- written: a panel's heading in an app @390: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 14 / 24; r0.body.0.0.props.style.fontWeight: 600 / 700`

### H3

- written: a small title on a website @1440: equal
- written: a small title on a website @834: equal
- written: a small title on a website @390: equal
- written: a strong line in an app @1440: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 13 / 18`
- written: a strong line in an app @834: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 13 / 18`
- written: a strong line in an app @390: 3 of 4 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.style.fontSize: 13 / 18`

### Heading

- tool/vocabulary/corpus-define/d02/answers/kiosk-museum-touch.txt ### Attract @1440: 12 of 13 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.1.0.props.style.fontSize: 30 / 18; r0.body.0.0.0.1.0.props.style.fontWeight: 700 / 600`
- tool/vocabulary/corpus-define/d02/answers/kiosk-museum-touch.txt ### Attract @834: 12 of 13 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.1.0.props.style.fontSize: 30 / 18; r0.body.0.0.0.1.0.props.style.fontWeight: 700 / 600`
- tool/vocabulary/corpus-define/d02/answers/kiosk-museum-touch.txt ### Attract @390: 12 of 13 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.0.1.0.props.style.fontSize: 30 / 18; r0.body.0.0.0.1.0.props.style.fontWeight: 700 / 600`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/seat-booking.txt ### Sold-out performance @1440: 25 of 26 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.1.props.style.fontFamily: "serif" / (none); r0.body.2.0.0.1.props.style.fontSize: 30 / 18; r0.body.2.0.0.1.props.style.fontWeight: 700 / 600`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/seat-booking.txt ### Sold-out performance @834: 25 of 26 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.1.props.style.fontFamily: "serif" / (none); r0.body.2.0.0.1.props.style.fontSize: 30 / 18; r0.body.2.0.0.1.props.style.fontWeight: 700 / 600`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/seat-booking.txt ### Sold-out performance @390: 25 of 26 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.1.props.style.fontFamily: "serif" / (none); r0.body.2.0.0.1.props.style.fontSize: 30 / 18; r0.body.2.0.0.1.props.style.fontWeight: 700 / 600`
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
- docs/reference/notation/navigation.md block 1 @1440: 16 of 17 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.props.style.fontSize: 30 / 18; r0.body.2.0.0.props.style.fontWeight: 700 / 600`
- docs/reference/notation/navigation.md block 1 @834: 16 of 17 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.props.style.fontSize: 30 / 18; r0.body.2.0.0.props.style.fontWeight: 700 / 600`
- docs/reference/notation/navigation.md block 1 @390: 16 of 17 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.props.style.fontSize: 30 / 18; r0.body.2.0.0.props.style.fontWeight: 700 / 600`

### IconTile

- tool/vocabulary/corpus/b01/answers/habit-tracker.txt ### New habit @1440: 40 of 42 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.5.0.0.decoration.radius: 10 / (none); r0.body.2.0.0.5.0.0.bind: (none) / {"decoration.radius":"${= 40/4}"}`
  - `r0.body.2.0.0.5.0.0.0.bind.props.size: (none) / "${= 40/2}"; r0.body.2.0.0.5.0.0.0.props: {"size":20} / (none)`
- tool/vocabulary/corpus/b01/answers/habit-tracker.txt ### New habit @834: 40 of 42 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.5.0.0.decoration.radius: 10 / (none); r0.body.2.0.0.5.0.0.bind: (none) / {"decoration.radius":"${= 40/4}"}`
  - `r0.body.2.0.0.5.0.0.0.bind.props.size: (none) / "${= 40/2}"; r0.body.2.0.0.5.0.0.0.props: {"size":20} / (none)`
- tool/vocabulary/corpus/b01/answers/habit-tracker.txt ### New habit @390: 40 of 42 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.5.0.0.decoration.radius: 10 / (none); r0.body.2.0.0.5.0.0.bind: (none) / {"decoration.radius":"${= 40/4}"}`
  - `r0.body.2.0.0.5.0.0.0.bind.props.size: (none) / "${= 40/2}"; r0.body.2.0.0.5.0.0.0.props: {"size":20} / (none)`
- tool/vocabulary/corpus/b07/answers/tower-defense-map.txt ### Wave Summary @1440: 33 of 36 nodes the same; 2 differ, 1 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.4.0.0.0.0.children: ["r0.body.2.0.0.4.0.0.0.0.0","r0.body.2.0.0.4.0.0.0.0.1"] / ["r0.body.2.0.0.4.0.0.0.0.0"]; r0.body.2.0.0.4.0.0.0.0.decoration.radius: 10 / (none); r0.body.2.0.0.4.0.0.0.0.bind: (none) / {"decoration.radius":"${= 40/4}"}`
  - `r0.body.2.0.0.4.0.0.0.0.0.layout.width.fill: 0 / (none); r0.body.2.0.0.4.0.0.0.0.0.layout.width.hug: (none) / 0; r0.body.2.0.0.4.0.0.0.0.0.props.style: {"color":"#FF111827","fontSize":13} / (none)`
  - `only in the code's: r0.body.2.0.0.4.0.0.0.0.1 icon`
- tool/vocabulary/corpus/b07/answers/tower-defense-map.txt ### Wave Summary @834: 33 of 36 nodes the same; 2 differ, 1 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.4.0.0.0.0.children: ["r0.body.2.0.0.4.0.0.0.0.0","r0.body.2.0.0.4.0.0.0.0.1"] / ["r0.body.2.0.0.4.0.0.0.0.0"]; r0.body.2.0.0.4.0.0.0.0.decoration.radius: 10 / (none); r0.body.2.0.0.4.0.0.0.0.bind: (none) / {"decoration.radius":"${= 40/4}"}`
  - `r0.body.2.0.0.4.0.0.0.0.0.layout.width.fill: 0 / (none); r0.body.2.0.0.4.0.0.0.0.0.layout.width.hug: (none) / 0; r0.body.2.0.0.4.0.0.0.0.0.props.style: {"color":"#FF111827","fontSize":13} / (none)`
  - `only in the code's: r0.body.2.0.0.4.0.0.0.0.1 icon`
- tool/vocabulary/corpus/b07/answers/tower-defense-map.txt ### Wave Summary @390: 33 of 36 nodes the same; 2 differ, 1 only in the code's, 0 only in the definition's
  - `r0.body.2.0.0.4.0.0.0.0.children: ["r0.body.2.0.0.4.0.0.0.0.0","r0.body.2.0.0.4.0.0.0.0.1"] / ["r0.body.2.0.0.4.0.0.0.0.0"]; r0.body.2.0.0.4.0.0.0.0.decoration.radius: 10 / (none); r0.body.2.0.0.4.0.0.0.0.bind: (none) / {"decoration.radius":"${= 40/4}"}`
  - `r0.body.2.0.0.4.0.0.0.0.0.layout.width.fill: 0 / (none); r0.body.2.0.0.4.0.0.0.0.0.layout.width.hug: (none) / 0; r0.body.2.0.0.4.0.0.0.0.0.props.style: {"color":"#FF111827","fontSize":13} / (none)`
  - `only in the code's: r0.body.2.0.0.4.0.0.0.0.1 icon`
- tool/vocabulary/corpus-define/d02/answers/tower-defense-map.txt ### Battle @1440: 77 of 79 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r1.body.1.0.0.0.0.decoration.radius: 10 / (none); r1.body.1.0.0.0.0.bind: (none) / {"decoration.radius":"${= 40/4}"}`
  - `r1.body.1.0.0.0.0.0.props.icon: "star" / ""; r1.body.1.0.0.0.0.0.props.size: 20 / (none); r1.body.1.0.0.0.0.0.bind: (none) / {"props.size":"${= 40/2}"}`
- tool/vocabulary/corpus-define/d02/answers/tower-defense-map.txt ### Battle @834: 77 of 79 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r1.body.1.0.0.0.0.decoration.radius: 10 / (none); r1.body.1.0.0.0.0.bind: (none) / {"decoration.radius":"${= 40/4}"}`
  - `r1.body.1.0.0.0.0.0.props.icon: "star" / ""; r1.body.1.0.0.0.0.0.props.size: 20 / (none); r1.body.1.0.0.0.0.0.bind: (none) / {"props.size":"${= 40/2}"}`
- tool/vocabulary/corpus-define/d02/answers/tower-defense-map.txt ### Battle @390: 77 of 79 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r1.body.1.0.0.0.0.decoration.radius: 10 / (none); r1.body.1.0.0.0.0.bind: (none) / {"decoration.radius":"${= 40/4}"}`
  - `r1.body.1.0.0.0.0.0.props.icon: "star" / ""; r1.body.1.0.0.0.0.0.props.size: 20 / (none); r1.body.1.0.0.0.0.0.bind: (none) / {"props.size":"${= 40/2}"}`

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
- tool/vocabulary/corpus/b09/answers/company-timeline.txt ### Event story @1440: 67 of 68 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.2.1.0.4.actions: [{"actions":[{"type":"openLink","url":"https://chronicle.example/news/series-a"}],"trig... / (none)`
- tool/vocabulary/corpus/b09/answers/company-timeline.txt ### Event story @834: 67 of 68 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.2.1.0.4.actions: [{"actions":[{"type":"openLink","url":"https://chronicle.example/news/series-a"}],"trig... / (none)`
- tool/vocabulary/corpus/b09/answers/company-timeline.txt ### Event story @390: 51 of 52 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.2.1.0.4.actions: [{"actions":[{"type":"openLink","url":"https://chronicle.example/news/series-a"}],"trig... / (none)`
- tool/vocabulary/corpus/b07/answers/outliner-notes.txt ### Outline @1440: 134 of 136 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.0.1.0.layout.squeezable: (none) / true; r0.body.1.0.1.0.media: [{"maxWidth":699,"patch":{"visible":false}}] / (none); r0.body.1.0.1.0.props.label: "Home" / (none)`
  - `r0.body.1.0.1.2.layout.squeezable: (none) / true; r0.body.1.0.1.2.media: [{"maxWidth":699,"patch":{"bind":{"visible":null},"visible":false}}] / (none); r0.body.1.0.1.2.props.label: "Q4 planning" / (none)`
- tool/vocabulary/corpus/b07/answers/outliner-notes.txt ### Outline @834: 134 of 136 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.0.1.0.layout.squeezable: (none) / true; r0.body.1.0.1.0.media: [{"maxWidth":699,"patch":{"visible":false}}] / (none); r0.body.1.0.1.0.props.label: "Home" / (none)`
  - `r0.body.1.0.1.2.layout.squeezable: (none) / true; r0.body.1.0.1.2.media: [{"maxWidth":699,"patch":{"bind":{"visible":null},"visible":false}}] / (none); r0.body.1.0.1.2.props.label: "Q4 planning" / (none)`
- tool/vocabulary/corpus/b07/answers/outliner-notes.txt ### Outline @390: 100 of 102 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.1.0.0.0.layout.squeezable: (none) / true; r0.body.1.0.0.0.props.label: "Home" / (none); r0.body.1.0.0.0.props.style: (none) / {"color":"#FF2563EB","fontSize":13}`
  - `r0.body.1.0.0.2.layout.squeezable: (none) / true; r0.body.1.0.0.2.props.label: "Q4 planning" / (none); r0.body.1.0.0.2.props.style: (none) / {"color":"#FF2563EB","fontSize":13}`
- docs/reference/notation/navigation.md block 1 @1440: 16 of 17 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.1.layout.squeezable: (none) / true; r0.body.0.0.1.media: [{"maxWidth":699,"patch":{"visible":false}}] / (none); r0.body.0.0.1.props.label: "Pricing" / (none)`
- docs/reference/notation/navigation.md block 1 @834: 16 of 17 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.1.layout.squeezable: (none) / true; r0.body.0.0.1.media: [{"maxWidth":699,"patch":{"visible":false}}] / (none); r0.body.0.0.1.props.label: "Pricing" / (none)`
- docs/reference/notation/navigation.md block 1 @390: 16 of 17 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.1.layout.squeezable: (none) / true; r0.body.0.0.1.props.label: "Pricing" / (none); r0.body.0.0.1.props.style: (none) / {"color":"#FF2563EB","fontSize":13}`

### Main

- tool/vocabulary/corpus/b09/answers/pedometer-band.txt ### Band Pages @1440: equal
- tool/vocabulary/corpus/b09/answers/pedometer-band.txt ### Band Pages @834: equal
- tool/vocabulary/corpus/b09/answers/pedometer-band.txt ### Band Pages @390: equal
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @1440: 87 of 195 nodes the same; 28 differ, 80 only in the code's, 52 only in the definition's; document keys roots
  - `r0.actions: [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee... / [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee...`
  - `r0.body.0.2.actions: [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee... / [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee...`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4"]; r0.body.1.props.scrollable: (none) / true`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @834: 87 of 195 nodes the same; 28 differ, 80 only in the code's, 52 only in the definition's; document keys roots
  - `r0.actions: [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee... / [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee...`
  - `r0.body.0.2.actions: [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee... / [{"actions":[{"maxHeightFactor":0.9,"presentation":"bottomSheet","sheetRadius":20,"shee...`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4"]; r0.body.1.props.scrollable: (none) / true`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @390: 100 of 168 nodes the same; 17 differ, 51 only in the code's, 50 only in the definition's
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4"]; r0.body.1.props.scrollable: (none) / true`
  - `r0.body.1.0.layout.padding: [24,14,24,14] / (none); r0.body.1.0.props.spacing: 24 / 16`
  - `r0.body.1.1.layout.width.fill: 0 / (none); r0.body.1.1.layout.width.hug: (none) / 0; r0.body.1.1.type: "divider" / "splitter"`
- tool/vocabulary/corpus/b07/answers/smart-speaker-display.txt ### Night Clock @1440: 14 of 15 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.props.scrollable: (none) / true`
- tool/vocabulary/corpus/b07/answers/smart-speaker-display.txt ### Night Clock @834: 14 of 15 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.props.scrollable: (none) / true`
- tool/vocabulary/corpus/b07/answers/smart-speaker-display.txt ### Night Clock @390: 14 of 15 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.props.scrollable: (none) / true`
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

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/seat-booking.txt ### Sold-out performance @1440: 1 of 26 nodes the same; 7 differ, 18 only in the code's, 16 only in the definition's
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2"] / ["r0.body.0","r0.body.1"]`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.media: [{"maxWidth":699,"patch":{"layout":{"padding":[16,14,16,14]}}}] / [{"maxWidth":1023,"patch":{"props":{"runSpacing":12,"wrap":true}}}]; r0.body.0.props.mainAxisAlignment: (none) / "spaceBetween"`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.layout.width.fill: 0 / (none); r0.body.0.0.layout.width.hug: (none) / 0`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/seat-booking.txt ### Sold-out performance @834: 1 of 26 nodes the same; 7 differ, 18 only in the code's, 16 only in the definition's
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2"] / ["r0.body.0","r0.body.1"]`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.media: [{"maxWidth":699,"patch":{"layout":{"padding":[16,14,16,14]}}}] / [{"maxWidth":1023,"patch":{"props":{"runSpacing":12,"wrap":true}}}]; r0.body.0.props.mainAxisAlignment: (none) / "spaceBetween"`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.layout.width.fill: 0 / (none); r0.body.0.0.layout.width.hug: (none) / 0`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/seat-booking.txt ### Sold-out performance @390: 1 of 26 nodes the same; 7 differ, 18 only in the code's, 16 only in the definition's
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2"] / ["r0.body.0","r0.body.1"]`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.props.mainAxisAlignment: (none) / "spaceBetween"; r0.body.0.props.spacing: (none) / 24`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.layout.width.fill: 0 / (none); r0.body.0.0.layout.width.hug: (none) / 0`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/calendar-app.txt ### Calendars @1440: 21 of 37 nodes the same; 6 differ, 10 only in the code's, 11 only in the definition's
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1"] / ["r0.body.1.0.0"]; r0.body.1.0.decoration: {"strokeSides":"bottom","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.0.layout.padding: [24,14,24,14] / [12,8,12,8]`
  - `r0.body.1.0.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/calendar-app.txt ### Calendars @834: 21 of 37 nodes the same; 6 differ, 10 only in the code's, 11 only in the definition's
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1"] / ["r0.body.1.0.0"]; r0.body.1.0.decoration: {"strokeSides":"bottom","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.0.layout.padding: [24,14,24,14] / [12,8,12,8]`
  - `r0.body.1.0.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/calendar-app.txt ### Calendars @390: 12 of 25 nodes the same; 2 differ, 11 only in the code's, 10 only in the definition's
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0","r0.body.1.1"]`
  - `r0.body.1.1.layout.constraints: (none) / {"maxWidth":560}; r0.body.1.1.layout.padding: (none) / 24; r0.body.1.1.type: "divider" / "column"`
  - `only in the code's: r0.body.1.2 column, r0.body.1.2.0 text, r0.body.1.2.1 listView, r0.body.1.2.1.0 column`
- tool/vocabulary/corpus/b08/answers/ereader-shelf.txt ### Reader @1440: 100 of 118 nodes the same; 5 differ, 13 only in the code's, 12 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3"] / ["r0.body.0.0","r0.body.0.1","r0.body.0.2"]`
  - `r0.body.0.1.layout.height.hug: 0 / (none); r0.body.0.1.layout.height.fill: (none) / 0; r0.body.0.1.layout.flex: (none) / 1`
  - `r0.body.0.2.children: ["r0.body.0.2.0","r0.body.0.2.1"] / ["r0.body.0.2.0"]; r0.body.0.2.layout.flex: 1 / (none); r0.body.0.2.layout.height.fill: 0 / (none)`
- tool/vocabulary/corpus/b08/answers/ereader-shelf.txt ### Reader @834: 100 of 118 nodes the same; 5 differ, 13 only in the code's, 12 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3"] / ["r0.body.0.0","r0.body.0.1","r0.body.0.2"]`
  - `r0.body.0.1.layout.height.hug: 0 / (none); r0.body.0.1.layout.height.fill: (none) / 0; r0.body.0.1.layout.flex: (none) / 1`
  - `r0.body.0.2.children: ["r0.body.0.2.0","r0.body.0.2.1"] / ["r0.body.0.2.0"]; r0.body.0.2.layout.flex: 1 / (none); r0.body.0.2.layout.height.fill: 0 / (none)`
- tool/vocabulary/corpus/b08/answers/ereader-shelf.txt ### Reader @390: 100 of 118 nodes the same; 5 differ, 13 only in the code's, 12 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3"] / ["r0.body.0.0","r0.body.0.1","r0.body.0.2"]`
  - `r0.body.0.1.layout.height.hug: 0 / (none); r0.body.0.1.layout.height.fill: (none) / 0; r0.body.0.1.layout.flex: (none) / 1`
  - `r0.body.0.2.children: ["r0.body.0.2.0","r0.body.0.2.1"] / ["r0.body.0.2.0"]; r0.body.0.2.layout.flex: 1 / (none); r0.body.0.2.layout.height.fill: 0 / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @1440: 121 of 195 nodes the same; 19 differ, 55 only in the code's, 56 only in the definition's
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5","r...`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1","r0.body.1.0.2","r0.body.1.0.3"] / ["r0.body.1.0.0"]; r0.body.1.0.layout.padding: [24,14,24,14] / [12,8,12,8]; r0.body.1.0.props.mainAxisAlignment: "spaceBetween" / (none)`
  - `r0.body.1.0.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @834: 121 of 195 nodes the same; 19 differ, 55 only in the code's, 56 only in the definition's
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5","r...`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1","r0.body.1.0.2","r0.body.1.0.3"] / ["r0.body.1.0.0"]; r0.body.1.0.layout.padding: [24,14,24,14] / [12,8,12,8]; r0.body.1.0.props.mainAxisAlignment: "spaceBetween" / (none)`
  - `r0.body.1.0.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/notes-app.txt ### Workspace @390: 101 of 168 nodes the same; 16 differ, 51 only in the code's, 50 only in the definition's
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4"]`
  - `r0.body.1.1.layout.width.fill: 0 / (none); r0.body.1.1.layout.width.hug: (none) / 0; r0.body.1.1.type: "divider" / "splitter"`
  - `r0.body.1.2.layout.width: {"hug":0} / 340; r0.body.1.2.type: "splitter" / "column"; r0.body.1.2.bind: (none) / {"visible":"${= view==\"workspace\"&&(pane==\"list\"||!phone)}"}`
- docs/reference/notation/navigation.md block 1 @1440: 1 of 17 nodes the same; 9 differ, 7 only in the code's, 5 only in the definition's
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2","r0.body.3","r0.body.4"] / ["r0.body.0","r0.body.1","r0.body.2","r0.body.3"]`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.media: [{"maxWidth":699,"patch":{"layout":{"padding":[16,14,16,14]}}}] / [{"maxWidth":1023,"patch":{"props":{"runSpacing":12,"wrap":true}}}]; r0.body.0.props.mainAxisAlignment: (none) / "spaceBetween"`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.layout.width.fill: 0 / (none); r0.body.0.0.layout.width.hug: (none) / 0`
- docs/reference/notation/navigation.md block 1 @834: 1 of 17 nodes the same; 9 differ, 7 only in the code's, 5 only in the definition's
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2","r0.body.3","r0.body.4"] / ["r0.body.0","r0.body.1","r0.body.2","r0.body.3"]`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.media: [{"maxWidth":699,"patch":{"layout":{"padding":[16,14,16,14]}}}] / [{"maxWidth":1023,"patch":{"props":{"runSpacing":12,"wrap":true}}}]; r0.body.0.props.mainAxisAlignment: (none) / "spaceBetween"`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.layout.width.fill: 0 / (none); r0.body.0.0.layout.width.hug: (none) / 0`
- docs/reference/notation/navigation.md block 1 @390: 1 of 17 nodes the same; 9 differ, 7 only in the code's, 5 only in the definition's
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2","r0.body.3","r0.body.4"] / ["r0.body.0","r0.body.1","r0.body.2","r0.body.3"]`
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.props.mainAxisAlignment: (none) / "spaceBetween"; r0.body.0.props.spacing: (none) / 24`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.layout.width.fill: 0 / (none); r0.body.0.0.layout.width.hug: (none) / 0`

### NavItem

- tool/vocabulary/corpus/b03/answers/typing-chat-bot.txt ### Chat @1440: equal up to spelling
- tool/vocabulary/corpus/b03/answers/typing-chat-bot.txt ### Chat @834: equal up to spelling
- tool/vocabulary/corpus/b03/answers/typing-chat-bot.txt ### Chat @390: equal up to spelling
- tool/vocabulary/corpus-define/d02/answers/flight-tracker.txt ### Alerts @1440: 54 of 60 nodes the same; 6 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.4.decoration.fills: [{"color":"#FF2563EB","opacity":0.12}] / (none); r0.body.0.4.bind: (none) / {"selected":"${= true}"}; r0.body.0.4.states: (none) / {"hovered":{"r0.body.0.4":{"decoration":{"fills":[{"color":"#0F111827"}]}}},"selected":...`
  - `r0.body.0.4.0.props.color: "#FF2563EB" / (none); r0.body.0.4.0.bind: (none) / {"props.color":"${= true?\"#FF2563EB\":\"#FF6B7280\"}"}`
  - `r0.body.0.4.1.props.style.color: "#FF2563EB" / "#FF111827"; r0.body.0.4.1.props.style.fontWeight: 600 / (none); r0.body.0.4.1.bind: (none) / {"props.style.color":"${= true?\"#FF2563EB\":\"#FF374151\"}","props.style.fontWeight":"...`
- tool/vocabulary/corpus-define/d02/answers/flight-tracker.txt ### Alerts @834: 54 of 60 nodes the same; 6 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.4.decoration.fills: [{"color":"#FF2563EB","opacity":0.12}] / (none); r0.body.0.4.bind: (none) / {"selected":"${= true}"}; r0.body.0.4.states: (none) / {"hovered":{"r0.body.0.4":{"decoration":{"fills":[{"color":"#0F111827"}]}}},"selected":...`
  - `r0.body.0.4.0.props.color: "#FF2563EB" / (none); r0.body.0.4.0.bind: (none) / {"props.color":"${= true?\"#FF2563EB\":\"#FF6B7280\"}"}`
  - `r0.body.0.4.1.props.style.color: "#FF2563EB" / "#FF111827"; r0.body.0.4.1.props.style.fontWeight: 600 / (none); r0.body.0.4.1.bind: (none) / {"props.style.color":"${= true?\"#FF2563EB\":\"#FF374151\"}","props.style.fontWeight":"...`
- tool/vocabulary/corpus-define/d02/answers/flight-tracker.txt ### Alerts @390: 35 of 38 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.4.decoration.fills: [{"color":"#FF2563EB","opacity":0.12}] / (none); r0.body.0.4.bind: (none) / {"selected":"${= true}"}; r0.body.0.4.states: (none) / {"hovered":{"r0.body.0.4":{"decoration":{"fills":[{"color":"#0F111827"}]}}},"selected":...`
  - `r0.body.0.4.0.props.color: "#FF2563EB" / (none); r0.body.0.4.0.bind: (none) / {"props.color":"${= true?\"#FF2563EB\":\"#FF6B7280\"}"}`
  - `r0.body.0.4.1.props.style.color: "#FF2563EB" / "#FF111827"; r0.body.0.4.1.props.style.fontWeight: 600 / (none); r0.body.0.4.1.bind: (none) / {"props.style.color":"${= true?\"#FF2563EB\":\"#FF374151\"}","props.style.fontWeight":"...`
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
- tool/vocabulary/corpus/b08/answers/keyboard-only-mail.txt ### Inbox @1440: 218 of 234 nodes the same; 8 differ, 8 only in the code's, 0 only in the definition's
  - `r0.body.12.0.1.children: ["r0.body.12.0.1.0","r0.body.12.0.1.1","r0.body.12.0.1.2","r0.body.12.0.1.3"] / ["r0.body.12.0.1.0","r0.body.12.0.1.1","r0.body.12.0.1.2"]`
  - `r0.body.12.0.2.children: ["r0.body.12.0.2.0","r0.body.12.0.2.1","r0.body.12.0.2.2"] / ["r0.body.12.0.2.0","r0.body.12.0.2.1"]`
  - `r0.body.12.0.3.children: ["r0.body.12.0.3.0","r0.body.12.0.3.1","r0.body.12.0.3.2"] / ["r0.body.12.0.3.0","r0.body.12.0.3.1"]`
- tool/vocabulary/corpus/b08/answers/keyboard-only-mail.txt ### Inbox @834: 218 of 234 nodes the same; 8 differ, 8 only in the code's, 0 only in the definition's
  - `r0.body.12.0.1.children: ["r0.body.12.0.1.0","r0.body.12.0.1.1","r0.body.12.0.1.2","r0.body.12.0.1.3"] / ["r0.body.12.0.1.0","r0.body.12.0.1.1","r0.body.12.0.1.2"]`
  - `r0.body.12.0.2.children: ["r0.body.12.0.2.0","r0.body.12.0.2.1","r0.body.12.0.2.2"] / ["r0.body.12.0.2.0","r0.body.12.0.2.1"]`
  - `r0.body.12.0.3.children: ["r0.body.12.0.3.0","r0.body.12.0.3.1","r0.body.12.0.3.2"] / ["r0.body.12.0.3.0","r0.body.12.0.3.1"]`
- tool/vocabulary/corpus/b08/answers/keyboard-only-mail.txt ### Inbox @390: 192 of 200 nodes the same; 4 differ, 4 only in the code's, 0 only in the definition's
  - `r0.body.12.0.1.children: ["r0.body.12.0.1.0","r0.body.12.0.1.1","r0.body.12.0.1.2","r0.body.12.0.1.3"] / ["r0.body.12.0.1.0","r0.body.12.0.1.1","r0.body.12.0.1.2"]`
  - `r0.body.12.0.2.children: ["r0.body.12.0.2.0","r0.body.12.0.2.1","r0.body.12.0.2.2"] / ["r0.body.12.0.2.0","r0.body.12.0.2.1"]`
  - `r0.body.12.0.3.children: ["r0.body.12.0.3.0","r0.body.12.0.3.1","r0.body.12.0.3.2"] / ["r0.body.12.0.3.0","r0.body.12.0.3.1"]`
- docs/reference/notation/NOTATION.md block 4 @1440: equal up to spelling
- docs/reference/notation/NOTATION.md block 4 @834: equal up to spelling
- docs/reference/notation/NOTATION.md block 4 @390: equal up to spelling
- docs/reference/notation/navigation.md block 3 @1440: equal up to spelling
- docs/reference/notation/navigation.md block 3 @834: equal up to spelling
- docs/reference/notation/navigation.md block 3 @390: equal up to spelling

### NavSection

- docs/reference/notation/navigation.md block 5 @1440: 58 of 62 nodes the same; 4 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.1.props.text: "PEOPLE & ACCESS" / "People & access"`
  - `r0.body.0.4.props.text: "WORKSPACE" / "Workspace"`
  - `r1.body.0.1.props.text: "PEOPLE & ACCESS" / "People & access"`
- docs/reference/notation/navigation.md block 5 @834: 58 of 62 nodes the same; 4 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.1.props.text: "PEOPLE & ACCESS" / "People & access"`
  - `r0.body.0.4.props.text: "WORKSPACE" / "Workspace"`
  - `r1.body.0.1.props.text: "PEOPLE & ACCESS" / "People & access"`
- docs/reference/notation/navigation.md block 5 @390: 28 of 30 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.1.props.text: "PEOPLE & ACCESS" / "People & access"`
  - `r0.body.0.4.props.text: "WORKSPACE" / "Workspace"`
- written: a group label in capitals, and one worked out @1440: equal
- written: a group label in capitals, and one worked out @834: equal
- written: a group label in capitals, and one worked out @390: equal
- written: a group label as most labels are written @1440: 18 of 20 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.text: "LIBRARY" / "Library"`
  - `r1.body.0.0.props.text: "LIBRARY" / "Library"`
- written: a group label as most labels are written @834: 18 of 20 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.text: "LIBRARY" / "Library"`
  - `r1.body.0.0.props.text: "LIBRARY" / "Library"`
- written: a group label as most labels are written @390: 8 of 9 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.props.text: "LIBRARY" / "Library"`

### Page

- tool/vocabulary/corpus/b08/answers/typesetter-pages.txt ### Spread @1440: 127 of 153 nodes the same; 21 differ, 5 only in the code's, 3 only in the definition's; document keys variables
  - `r0.body.1.0.2.0.0.0.children: ["r0.body.1.0.2.0.0.0.0","r0.body.1.0.2.0.0.0.1","r0.body.1.0.2.0.0.0.2","r0.body.1.0.2... / ["r0.body.1.0.2.0.0.0.0","r0.body.1.0.2.0.0.0.1","r0.body.1.0.2.0.0.0.2","r0.body.1.0.2...; r0.body.1.0.2.0.0.0.layout.width.hug: 0 / (none); r0.body.1.0.2.0.0.0.layout.width.fill: (none) / 0`
  - `r0.body.1.0.2.0.0.0.0.layout.constraints: (none) / {"minHeight":40}; r0.body.1.0.2.0.0.0.0.layout.padding: (none) / 8; r0.body.1.0.2.0.0.0.0.props.style: {"color":"#FF111827","fontSize":13} / (none)`
  - `r0.body.1.0.2.0.0.0.1.children: ["r0.body.1.0.2.0.0.0.1.0"] / ["r0.body.1.0.2.0.0.0.1.0","r0.body.1.0.2.0.0.0.1.1"]; r0.body.1.0.2.0.0.0.1.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.0.2.0.0.0.1.layout.constraints.minHeight: 40 / 300`
- tool/vocabulary/corpus/b08/answers/typesetter-pages.txt ### Spread @834: 127 of 153 nodes the same; 21 differ, 5 only in the code's, 3 only in the definition's; document keys variables
  - `r0.body.1.0.2.0.0.0.children: ["r0.body.1.0.2.0.0.0.0","r0.body.1.0.2.0.0.0.1","r0.body.1.0.2.0.0.0.2","r0.body.1.0.2... / ["r0.body.1.0.2.0.0.0.0","r0.body.1.0.2.0.0.0.1","r0.body.1.0.2.0.0.0.2","r0.body.1.0.2...; r0.body.1.0.2.0.0.0.layout.width.hug: 0 / (none); r0.body.1.0.2.0.0.0.layout.width.fill: (none) / 0`
  - `r0.body.1.0.2.0.0.0.0.layout.constraints: (none) / {"minHeight":40}; r0.body.1.0.2.0.0.0.0.layout.padding: (none) / 8; r0.body.1.0.2.0.0.0.0.props.style: {"color":"#FF111827","fontSize":13} / (none)`
  - `r0.body.1.0.2.0.0.0.1.children: ["r0.body.1.0.2.0.0.0.1.0"] / ["r0.body.1.0.2.0.0.0.1.0","r0.body.1.0.2.0.0.0.1.1"]; r0.body.1.0.2.0.0.0.1.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.0.2.0.0.0.1.layout.constraints.minHeight: 40 / 300`
- tool/vocabulary/corpus/b08/answers/typesetter-pages.txt ### Spread @390: 99 of 125 nodes the same; 21 differ, 5 only in the code's, 3 only in the definition's; document keys variables
  - `r0.body.1.0.2.0.0.0.children: ["r0.body.1.0.2.0.0.0.0","r0.body.1.0.2.0.0.0.1","r0.body.1.0.2.0.0.0.2","r0.body.1.0.2... / ["r0.body.1.0.2.0.0.0.0","r0.body.1.0.2.0.0.0.1","r0.body.1.0.2.0.0.0.2","r0.body.1.0.2...; r0.body.1.0.2.0.0.0.layout.width.hug: 0 / (none); r0.body.1.0.2.0.0.0.layout.width.fill: (none) / 0`
  - `r0.body.1.0.2.0.0.0.0.layout.constraints: (none) / {"minHeight":40}; r0.body.1.0.2.0.0.0.0.layout.padding: (none) / 8; r0.body.1.0.2.0.0.0.0.props.style: {"color":"#FF111827","fontSize":13} / (none)`
  - `r0.body.1.0.2.0.0.0.1.children: ["r0.body.1.0.2.0.0.0.1.0"] / ["r0.body.1.0.2.0.0.0.1.0","r0.body.1.0.2.0.0.0.1.1"]; r0.body.1.0.2.0.0.0.1.decoration: {"dashPattern":[4,3],"radius":6,"strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.1.0.2.0.0.0.1.layout.constraints.minHeight: 40 / 300`
- docs/reference/notation/lists.md block 4 @1440: 2 of 18 nodes the same; 7 differ, 9 only in the code's, 8 only in the definition's
  - `r0.body.0.layout.padding: [24,64,24,64] / (none); r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none); r0.body.0.props.crossAxisAlignment: "center" / "start"`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.props.spacing: 32 / (none)`
  - `r0.body.0.0.0.decoration.clip: "antiAlias" / (none); r0.body.0.0.0.decoration.fills: [{"color":"#FFFFFFFF"}] / [{"color":"#FFF8FAFC"}]; r0.body.0.0.0.decoration.radius: 8 / (none)`
- docs/reference/notation/lists.md block 4 @834: 2 of 18 nodes the same; 7 differ, 9 only in the code's, 8 only in the definition's
  - `r0.body.0.layout.padding: [24,64,24,64] / (none); r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none); r0.body.0.props.crossAxisAlignment: "center" / "start"`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.props.spacing: 32 / (none)`
  - `r0.body.0.0.0.decoration.clip: "antiAlias" / (none); r0.body.0.0.0.decoration.fills: [{"color":"#FFFFFFFF"}] / [{"color":"#FFF8FAFC"}]; r0.body.0.0.0.decoration.radius: 8 / (none)`
- docs/reference/notation/lists.md block 4 @390: 2 of 18 nodes the same; 7 differ, 9 only in the code's, 8 only in the definition's
  - `r0.body.0.layout.padding: [24,64,24,64] / (none); r0.body.0.props.crossAxisAlignment: "center" / "start"; r0.body.0.props.spacing: (none) / 16`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.props.spacing: 32 / (none)`
  - `r0.body.0.0.0.decoration.clip: "antiAlias" / (none); r0.body.0.0.0.decoration.fills: [{"color":"#FFFFFFFF"}] / [{"color":"#FFF8FAFC"}]; r0.body.0.0.0.decoration.radius: 8 / (none)`
- docs/reference/notation/lists.md block 10 @1440: 2 of 41 nodes the same; 4 differ, 35 only in the code's, 34 only in the definition's; document keys variables
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.layout.padding: [24,64,24,64] / (none); r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.props.crossAxisAlignment: "start" / "center"; r0.body.0.0.props.spacing: 32 / 8`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.width: {"fill":0} / 280; r0.body.0.0.0.media: [{"maxWidth":1023,"patch":{"props":{"runSpacing":8,"wrap":true}}}] / (none)`
- docs/reference/notation/lists.md block 10 @834: 2 of 41 nodes the same; 4 differ, 35 only in the code's, 34 only in the definition's; document keys variables
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.layout.padding: [24,64,24,64] / (none); r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.props.crossAxisAlignment: "start" / "center"; r0.body.0.0.props.spacing: 32 / 8`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.width: {"fill":0} / 280; r0.body.0.0.0.media: [{"maxWidth":1023,"patch":{"props":{"runSpacing":8,"wrap":true}}}] / (none)`
- docs/reference/notation/lists.md block 10 @390: 2 of 41 nodes the same; 4 differ, 35 only in the code's, 34 only in the definition's; document keys variables
  - `r0.body.0.children: ["r0.body.0.0"] / ["r0.body.0.0","r0.body.0.1"]; r0.body.0.layout.padding: [24,64,24,64] / (none); r0.body.0.props.crossAxisAlignment: "center" / "start"`
  - `r0.body.0.0.layout.constraints: {"maxWidth":1120} / (none); r0.body.0.0.props.crossAxisAlignment: "start" / "center"; r0.body.0.0.props.spacing: 32 / 8`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.width: {"fill":0} / 280; r0.body.0.0.0.props.crossAxisAlignment: "center" / (none)`

### Pane

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/support-desk.txt ### Ticket @1440: 121 of 122 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.2.1.decoration.strokeSides: (none) / "right"; r0.body.0.2.1.decoration.strokes: (none) / [{"color":"#FFE5E7EB"}]; r0.body.0.2.1.layout.height.hug: 0 / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/support-desk.txt ### Ticket @834: 121 of 122 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.2.1.decoration.strokeSides: (none) / "right"; r0.body.0.2.1.decoration.strokes: (none) / [{"color":"#FFE5E7EB"}]; r0.body.0.2.1.layout.height.hug: 0 / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/support-desk.txt ### Ticket @390: 121 of 122 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.2.1.decoration.strokeSides: (none) / "right"; r0.body.0.2.1.decoration.strokes: (none) / [{"color":"#FFE5E7EB"}]; r0.body.0.2.1.layout.height.hug: 0 / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/mail-client.txt ### Mailbox @1440: 176 of 179 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0; r0.body.0.0.props.scrollable: (none) / true`
  - `r0.body.0.2.layout.height.hug: 0 / (none); r0.body.0.2.layout.height.fill: (none) / 0; r0.body.0.2.props.scrollable: (none) / true`
  - `r0.body.0.4.props.scrollable: (none) / true; r0.body.0.4.decoration: (none) / {"strokeSides":"left","strokes":[{"color":"#FFE5E7EB"}]}`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/mail-client.txt ### Mailbox @834: 176 of 179 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.0.layout.height.hug: 0 / (none); r0.body.0.0.layout.height.fill: (none) / 0; r0.body.0.0.props.scrollable: (none) / true`
  - `r0.body.0.2.layout.height.hug: 0 / (none); r0.body.0.2.layout.height.fill: (none) / 0; r0.body.0.2.props.scrollable: (none) / true`
  - `r0.body.0.4.props.scrollable: (none) / true; r0.body.0.4.decoration: (none) / {"strokeSides":"left","strokes":[{"color":"#FFE5E7EB"}]}`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/mail-client.txt ### Mailbox @390: 176 of 179 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's
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

- tool/vocabulary/corpus-define/d02/answers/weighbridge-ticket.txt ### Ticket @1440: 65 of 67 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
  - `r0.body.3.layout.padding: [24,32,24,32] / [24,64,24,64]; r0.body.3.media: [{"maxWidth":699,"patch":{"layout":{"padding":[20,24,20,24]}}}] / (none)`
- tool/vocabulary/corpus-define/d02/answers/weighbridge-ticket.txt ### Ticket @834: 65 of 67 nodes the same; 2 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
  - `r0.body.3.layout.padding: [24,32,24,32] / [24,64,24,64]; r0.body.3.media: [{"maxWidth":699,"patch":{"layout":{"padding":[20,24,20,24]}}}] / (none)`
- tool/vocabulary/corpus-define/d02/answers/weighbridge-ticket.txt ### Ticket @390: 60 of 61 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.3.layout.padding: [24,32,24,32] / [24,64,24,64]`
- tool/vocabulary/corpus-define/d02/answers/kiosk-museum-touch.txt ### Attract @1440: 10 of 13 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.layout.padding: [0,64,0,64] / [24,64,24,64]; r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[0,48,0,48]}}},{"maxWidth":699,"patch":{... / (none)`
  - `r0.body.0.0.layout.constraints: (none) / {"maxWidth":1120}; r0.body.0.0.props.crossAxisAlignment: "center" / "start"`
  - `r0.body.0.0.0.layout.width.hug: 0 / (none); r0.body.0.0.0.layout.width.fill: (none) / 0`
- tool/vocabulary/corpus-define/d02/answers/kiosk-museum-touch.txt ### Attract @834: 10 of 13 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.layout.padding: [0,64,0,64] / [24,64,24,64]; r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[0,48,0,48]}}},{"maxWidth":699,"patch":{... / (none)`
  - `r0.body.0.0.layout.constraints: (none) / {"maxWidth":1120}; r0.body.0.0.props.crossAxisAlignment: "center" / "start"`
  - `r0.body.0.0.0.layout.width.hug: 0 / (none); r0.body.0.0.0.layout.width.fill: (none) / 0`
- tool/vocabulary/corpus-define/d02/answers/kiosk-museum-touch.txt ### Attract @390: 10 of 13 nodes the same; 3 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.layout.padding: [0,64,0,64] / [24,64,24,64]`
  - `r0.body.0.0.layout.constraints: (none) / {"maxWidth":1120}; r0.body.0.0.props.crossAxisAlignment: "center" / "start"`
  - `r0.body.0.0.0.layout.width.hug: 0 / (none); r0.body.0.0.0.layout.width.fill: (none) / 0`
- tool/vocabulary/corpus/b08/answers/neighbour-noticeboard.txt ### Post detail @1440: 101 of 102 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
- tool/vocabulary/corpus/b08/answers/neighbour-noticeboard.txt ### Post detail @834: 101 of 102 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.2.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
- tool/vocabulary/corpus/b08/answers/neighbour-noticeboard.txt ### Post detail @390: equal
- docs/reference/notation/lists.md block 4 @1440: 17 of 18 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
- docs/reference/notation/lists.md block 4 @834: 17 of 18 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
- docs/reference/notation/lists.md block 4 @390: equal
- docs/reference/notation/lists.md block 10 @1440: 40 of 41 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
- docs/reference/notation/lists.md block 10 @834: 40 of 41 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
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

- tool/vocabulary/corpus/2026-11-16-sonnet/answers/kanban-board.txt ### Archive @1440: 18 of 56 nodes the same; 10 differ, 28 only in the code's, 31 only in the definition's
  - `r0.actions: [{"actions":[{"to":"board","type":"navigate"}],"trigger":{"key":"v","type":"keyDown"}}] / (none); r0.layout.height.fill: 800.0 / (none); r0.layout.height.hug: (none) / 0`
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0; r0.body.type: "row" / "column"`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3"] / ["r0.body.0.0"]; r0.body.0.decoration: {"fills":[{"color":"#FFF1F3F6"}],"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.height.fill: 0 / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/kanban-board.txt ### Archive @834: 18 of 56 nodes the same; 10 differ, 28 only in the code's, 31 only in the definition's
  - `r0.actions: [{"actions":[{"to":"board","type":"navigate"}],"trigger":{"key":"v","type":"keyDown"}}] / (none); r0.layout.height.fill: 800.0 / (none); r0.layout.height.hug: (none) / 0`
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0; r0.body.type: "row" / "column"`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3"] / ["r0.body.0.0"]; r0.body.0.decoration: {"fills":[{"color":"#FFF1F3F6"}],"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.height.fill: 0 / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/kanban-board.txt ### Archive @390: 0 of 37 nodes the same; 9 differ, 28 only in the code's, 31 only in the definition's
  - `r0.actions: [{"actions":[{"to":"board","type":"navigate"}],"trigger":{"key":"v","type":"keyDown"}}] / (none); r0.layout.height.fill: 800.0 / (none); r0.layout.height.hug: (none) / 0`
  - `r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0; r0.body.type: "row" / "column"`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2","r0.body.0.3"] / ["r0.body.0.0"]; r0.body.0.decoration: {"fills":[{"color":"#FFF1F3F6"}],"strokeSides":"right","strokes":[{"color":"#FFE5E7EB"}]} / (none); r0.body.0.layout.height.fill: 0 / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/team-chat.txt ### Composer @1440: 17 of 37 nodes the same; 5 differ, 15 only in the code's, 18 only in the definition's
  - `r0.actions: [{"actions":[{"type":"setVariable","value":"${= append(msgs,{\"id\":(\"m\"+(length(msgs... / (none)`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]; r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1"] / ["r0.body.0.0"]; r0.body.0.layout.flex: 1 / (none); r0.body.0.props.crossAxisAlignment: "start" / "stretch"`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/team-chat.txt ### Composer @834: 17 of 37 nodes the same; 5 differ, 15 only in the code's, 18 only in the definition's
  - `r0.actions: [{"actions":[{"type":"setVariable","value":"${= append(msgs,{\"id\":(\"m\"+(length(msgs... / (none)`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]; r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1"] / ["r0.body.0.0"]; r0.body.0.layout.flex: 1 / (none); r0.body.0.props.crossAxisAlignment: "start" / "stretch"`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/team-chat.txt ### Composer @390: 17 of 37 nodes the same; 5 differ, 15 only in the code's, 18 only in the definition's
  - `r0.actions: [{"actions":[{"type":"setVariable","value":"${= append(msgs,{\"id\":(\"m\"+(length(msgs... / (none)`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]; r0.body.layout.height.fill: 0 / (none); r0.body.layout.height.hug: (none) / 0`
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1"] / ["r0.body.0.0"]; r0.body.0.layout.flex: 1 / (none); r0.body.0.props.crossAxisAlignment: "start" / "stretch"`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/flashcards.txt ### Study @1440: 59 of 98 nodes the same; 4 differ, 35 only in the code's, 43 only in the definition's
  - `r0.actions: [{"actions":[{"type":"setVariable","value":"${= !flipped}","variable":"flipped"}],"trig... / [{"actions":[{"type":"setVariable","value":"${= streak}","variable":"streak"}],"trigger...`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5","r...`
  - `r0.body.1.2.children: ["r0.body.1.2.0","r0.body.1.2.1","r0.body.1.2.2","r0.body.1.2.3","r0.body.1.2.4","r0.bo... / ["r0.body.1.2.0"]; r0.body.1.2.layout.constraints.maxWidth: 640 / (none); r0.body.1.2.layout.constraints.minHeight: (none) / 40`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/flashcards.txt ### Study @834: 59 of 98 nodes the same; 4 differ, 35 only in the code's, 43 only in the definition's
  - `r0.actions: [{"actions":[{"type":"setVariable","value":"${= !flipped}","variable":"flipped"}],"trig... / [{"actions":[{"type":"setVariable","value":"${= streak}","variable":"streak"}],"trigger...`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5","r...`
  - `r0.body.1.2.children: ["r0.body.1.2.0","r0.body.1.2.1","r0.body.1.2.2","r0.body.1.2.3","r0.body.1.2.4","r0.bo... / ["r0.body.1.2.0"]; r0.body.1.2.layout.constraints.maxWidth: 640 / (none); r0.body.1.2.layout.constraints.minHeight: (none) / 40`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/flashcards.txt ### Study @390: 30 of 69 nodes the same; 4 differ, 35 only in the code's, 43 only in the definition's
  - `r0.actions: [{"actions":[{"type":"setVariable","value":"${= !flipped}","variable":"flipped"}],"trig... / [{"actions":[{"type":"setVariable","value":"${= streak}","variable":"streak"}],"trigger...`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2","r0.body.1.3","r0.body.1.4","r0.body.1.5","r...`
  - `r0.body.1.2.children: ["r0.body.1.2.0","r0.body.1.2.1","r0.body.1.2.2","r0.body.1.2.3","r0.body.1.2.4","r0.bo... / ["r0.body.1.2.0"]; r0.body.1.2.layout.constraints.maxWidth: 640 / (none); r0.body.1.2.layout.constraints.minHeight: (none) / 40`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/support-desk.txt ### Shortcuts @1440: 0 of 25 nodes the same; 5 differ, 20 only in the code's, 23 only in the definition's
  - `r0.actions: [{"actions":[{"to":"inbox","type":"navigate"}],"trigger":{"key":"Escape","type":"keyDow... / (none)`
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2"] / ["r0.body.0","r0.body.1"]; r0.body.props.scrollable: true / (none)`
  - `r0.body.0.layout.padding: [24,14,24,14] / 8; r0.body.0.layout.constraints: (none) / {"minHeight":40}; r0.body.0.media: [{"maxWidth":699,"patch":{"layout":{"padding":[16,14,16,14]}}}] / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/support-desk.txt ### Shortcuts @834: 0 of 25 nodes the same; 5 differ, 20 only in the code's, 23 only in the definition's
  - `r0.actions: [{"actions":[{"to":"inbox","type":"navigate"}],"trigger":{"key":"Escape","type":"keyDow... / (none)`
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2"] / ["r0.body.0","r0.body.1"]; r0.body.props.scrollable: true / (none)`
  - `r0.body.0.layout.padding: [24,14,24,14] / 8; r0.body.0.layout.constraints: (none) / {"minHeight":40}; r0.body.0.media: [{"maxWidth":699,"patch":{"layout":{"padding":[16,14,16,14]}}}] / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/support-desk.txt ### Shortcuts @390: 0 of 25 nodes the same; 5 differ, 20 only in the code's, 23 only in the definition's
  - `r0.actions: [{"actions":[{"to":"inbox","type":"navigate"}],"trigger":{"key":"Escape","type":"keyDow... / (none)`
  - `r0.body.children: ["r0.body.0","r0.body.1","r0.body.2"] / ["r0.body.0","r0.body.1"]; r0.body.props.scrollable: true / (none)`
  - `r0.body.0.layout.padding: [24,14,24,14] / 8; r0.body.0.layout.constraints: (none) / {"minHeight":40}; r0.body.0.props.mainAxisAlignment: (none) / "center"`
- written: a shortcut with its keys as a string @1440: 0 of 3 nodes the same; 3 differ, 0 only in the code's, 3 only in the definition's
  - `r0.actions: [{"actions":[{"node":"search","type":"focus"}],"trigger":{"key":"ctrl+k","type":"keyDow... / (none)`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]; r0.body.props.crossAxisAlignment: "start" / "stretch"`
  - `r0.body.0.props.style: {"color":"#FF111827","fontSize":13} / (none); r0.body.0.props.text: "Search" / (none); r0.body.0.props.crossAxisAlignment: (none) / "start"`
- written: a shortcut with its keys as a string @834: 0 of 3 nodes the same; 3 differ, 0 only in the code's, 3 only in the definition's
  - `r0.actions: [{"actions":[{"node":"search","type":"focus"}],"trigger":{"key":"ctrl+k","type":"keyDow... / (none)`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]; r0.body.props.crossAxisAlignment: "start" / "stretch"`
  - `r0.body.0.props.style: {"color":"#FF111827","fontSize":13} / (none); r0.body.0.props.text: "Search" / (none); r0.body.0.props.crossAxisAlignment: (none) / "start"`
- written: a shortcut with its keys as a string @390: 0 of 3 nodes the same; 3 differ, 0 only in the code's, 3 only in the definition's
  - `r0.actions: [{"actions":[{"node":"search","type":"focus"}],"trigger":{"key":"ctrl+k","type":"keyDow... / (none)`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]; r0.body.props.crossAxisAlignment: "start" / "stretch"`
  - `r0.body.0.props.style: {"color":"#FF111827","fontSize":13} / (none); r0.body.0.props.text: "Search" / (none); r0.body.0.props.crossAxisAlignment: (none) / "start"`
- written: a shortcut with keys= @1440: 0 of 3 nodes the same; 3 differ, 0 only in the code's, 3 only in the definition's
  - `r0.actions: [{"actions":[{"node":"search","type":"focus"}],"trigger":{"key":"/","type":"keyDown"}}] / (none)`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]; r0.body.props.crossAxisAlignment: "start" / "stretch"`
  - `r0.body.0.props.style: {"color":"#FF111827","fontSize":13} / (none); r0.body.0.props.text: "Members" / (none); r0.body.0.props.crossAxisAlignment: (none) / "start"`
- written: a shortcut with keys= @834: 0 of 3 nodes the same; 3 differ, 0 only in the code's, 3 only in the definition's
  - `r0.actions: [{"actions":[{"node":"search","type":"focus"}],"trigger":{"key":"/","type":"keyDown"}}] / (none)`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]; r0.body.props.crossAxisAlignment: "start" / "stretch"`
  - `r0.body.0.props.style: {"color":"#FF111827","fontSize":13} / (none); r0.body.0.props.text: "Members" / (none); r0.body.0.props.crossAxisAlignment: (none) / "start"`
- written: a shortcut with keys= @390: 0 of 3 nodes the same; 3 differ, 0 only in the code's, 3 only in the definition's
  - `r0.actions: [{"actions":[{"node":"search","type":"focus"}],"trigger":{"key":"/","type":"keyDown"}}] / (none)`
  - `r0.body.children: ["r0.body.0"] / ["r0.body.0","r0.body.1"]; r0.body.props.crossAxisAlignment: "start" / "stretch"`
  - `r0.body.0.props.style: {"color":"#FF111827","fontSize":13} / (none); r0.body.0.props.text: "Members" / (none); r0.body.0.props.crossAxisAlignment: (none) / "start"`

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

- written: a sidebar's foot @1440: 16 of 28 nodes the same; 4 differ, 8 only in the code's, 6 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]`
  - `r0.body.0.1.layout.flex: 1 / (none); r0.body.0.1.layout.height.fill: 0 / (none); r0.body.0.1.layout.height.hug: (none) / 0`
  - `r1.body.0.children: ["r1.body.0.0","r1.body.0.1","r1.body.0.2"] / ["r1.body.0.0","r1.body.0.1"]`
- written: a sidebar's foot @834: 16 of 28 nodes the same; 4 differ, 8 only in the code's, 6 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]`
  - `r0.body.0.1.layout.flex: 1 / (none); r0.body.0.1.layout.height.fill: 0 / (none); r0.body.0.1.layout.height.hug: (none) / 0`
  - `r1.body.0.children: ["r1.body.0.0","r1.body.0.1","r1.body.0.2"] / ["r1.body.0.0","r1.body.0.1"]`
- written: a sidebar's foot @390: 7 of 13 nodes the same; 2 differ, 4 only in the code's, 3 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]`
  - `r0.body.0.1.layout.flex: 1 / (none); r0.body.0.1.layout.height.fill: 0 / (none); r0.body.0.1.layout.height.hug: (none) / 0`
  - `only in the code's: r0.body.0.2 column, r0.body.0.2.0 row, r0.body.0.2.0.0 icon, r0.body.0.2.0.1 text`

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

### App (family) (renamed together: App, Brand, Footer, Heading, IconTile, Link, Main, Nav, NavItem, NavSection, Page, Pane, Section, Sidebar)

- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @1440: 14 of 33 nodes the same; 6 differ, 13 only in the code's, 13 only in the definition's
  - `r0.body.0.props.crossAxisAlignment: "stretch" / "start"; r0.body.0.props.scrollable: (none) / true`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.flex: 1 / (none); r0.body.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.height: {"hug":0} / 0; r0.body.0.0.0.layout.padding: 16 / (none)`
- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @834: 14 of 33 nodes the same; 6 differ, 13 only in the code's, 13 only in the definition's
  - `r0.body.0.props.crossAxisAlignment: "stretch" / "start"; r0.body.0.props.scrollable: (none) / true`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.flex: 1 / (none); r0.body.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.height: {"hug":0} / 0; r0.body.0.0.0.layout.padding: 16 / (none)`
- tool/vocabulary/corpus/b07/answers/one-handed-reach.txt ### Notes @390: 14 of 33 nodes the same; 6 differ, 13 only in the code's, 13 only in the definition's
  - `r0.body.0.props.crossAxisAlignment: "stretch" / "start"; r0.body.0.props.scrollable: (none) / true`
  - `r0.body.0.0.children: ["r0.body.0.0.0"] / ["r0.body.0.0.0","r0.body.0.0.1"]; r0.body.0.0.layout.flex: 1 / (none); r0.body.0.0.layout.height.fill: 0 / (none)`
  - `r0.body.0.0.0.children: ["r0.body.0.0.0.0","r0.body.0.0.0.1"] / (none); r0.body.0.0.0.layout.height: {"hug":0} / 0; r0.body.0.0.0.layout.padding: 16 / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @1440: 20 of 63 nodes the same; 4 differ, 39 only in the code's, 16 only in the definition's; document keys roots, variables
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0","r0.body.1.1"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1"] / ["r0.body.1.0.0"]; r0.body.1.0.media: [{"maxWidth":699,"patch":{"props":{"spacing":12}}}] / (none)`
  - `r0.body.1.0.0.actions: [{"actions":[{"cover":true,"presentation":"dialog","to":"r1","type":"openModal"}],"trig... / (none); r0.body.1.0.0.layout.squeezable: (none) / true; r0.body.1.0.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @834: 20 of 63 nodes the same; 4 differ, 39 only in the code's, 16 only in the definition's; document keys roots, variables
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0","r0.body.1.1"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1"] / ["r0.body.1.0.0"]; r0.body.1.0.media: [{"maxWidth":699,"patch":{"props":{"spacing":12}}}] / (none)`
  - `r0.body.1.0.0.actions: [{"actions":[{"cover":true,"presentation":"dialog","to":"r1","type":"openModal"}],"trig... / (none); r0.body.1.0.0.layout.squeezable: (none) / true; r0.body.1.0.0.media: [{"minWidth":700,"patch":{"bind":{"visible":null},"visible":false}}] / (none)`
- tool/vocabulary/corpus/2026-11-16-sonnet/answers/meal-planner.txt ### Favourites @390: 21 of 41 nodes the same; 3 differ, 17 only in the code's, 16 only in the definition's
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0","r0.body.1.1"]`
  - `r0.body.1.0.0.props.style.fontFamily: "serif" / (none)`
  - `r0.body.1.1.layout.padding: (none) / 24; r0.body.1.1.type: "divider" / "column"; r0.body.1.1.children: (none) / ["r0.body.1.1.0","r0.body.1.1.1"]`
- tool/vocabulary/corpus/b09/answers/tractor-guidance.txt ### Implement @1440: 4 of 41 nodes the same; 5 differ, 32 only in the code's, 31 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]`
  - `r0.body.0.0.media: [{"maxWidth":699,"patch":{"props":{"spacing":12}}}] / [{"maxWidth":1023,"patch":{"props":{"runSpacing":12,"wrap":true}}}]`
  - `r0.body.0.0.0.media: (none) / [{"maxWidth":1023,"patch":{"props":{"runSpacing":8,"wrap":true}}}]`
- tool/vocabulary/corpus/b09/answers/tractor-guidance.txt ### Implement @834: 4 of 41 nodes the same; 5 differ, 32 only in the code's, 31 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]`
  - `r0.body.0.0.media: [{"maxWidth":699,"patch":{"props":{"spacing":12}}}] / [{"maxWidth":1023,"patch":{"props":{"runSpacing":12,"wrap":true}}}]`
  - `r0.body.0.0.0.media: (none) / [{"maxWidth":1023,"patch":{"props":{"runSpacing":8,"wrap":true}}}]`
- tool/vocabulary/corpus/b09/answers/tractor-guidance.txt ### Implement @390: 6 of 41 nodes the same; 3 differ, 32 only in the code's, 31 only in the definition's
  - `r0.body.0.children: ["r0.body.0.0","r0.body.0.1","r0.body.0.2"] / ["r0.body.0.0","r0.body.0.1"]`
  - `r0.body.0.0.0.1.props.style.fontSize: 13 / 18`
  - `r0.body.0.1.layout.padding: (none) / 16; r0.body.0.1.type: "divider" / "column"; r0.body.0.1.children: (none) / ["r0.body.0.1.0","r0.body.0.1.1","r0.body.0.1.2","r0.body.0.1.3"]`
- docs/reference/notation/NOTATION.md block 4 @1440: 12 of 26 nodes the same; 4 differ, 10 only in the code's, 0 only in the definition's; document keys roots
  - `r0.body.0.media: [{"maxWidth":699,"patch":{"visible":false}}] / (none)`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.layout.width.fill: 0 / (none)`
- docs/reference/notation/NOTATION.md block 4 @834: 12 of 26 nodes the same; 4 differ, 10 only in the code's, 0 only in the definition's; document keys roots
  - `r0.body.0.media: [{"maxWidth":699,"patch":{"visible":false}}] / (none)`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1","r0.body.1.2"] / ["r0.body.1.0"]`
  - `r0.body.1.0.children: ["r0.body.1.0.0"] / (none); r0.body.1.0.layout.padding: [12,8,12,8] / (none); r0.body.1.0.layout.width.fill: 0 / (none)`
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

- tool/vocabulary/corpus/b08/answers/typesetter-pages.txt ### Spread @1440: 48 of 153 nodes the same; 12 differ, 93 only in the code's, 62 only in the definition's; document keys roots, variables
  - `r0.body.0.decoration.strokeSides: "r0.body.1.0.2.0.0.1" / "r0.body.1.1.0.0.1"`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2"]; r0.body.1.props.crossAxisAlignment: "stretch" / "start"; r0.body.1.props.scrollable: (none) / true`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1","r0.body.1.0.2"] / ["r0.body.1.0.0","r0.body.1.0.1"]; r0.body.1.0.layout.flex: 1 / (none); r0.body.1.0.layout.height.fill: 0 / (none)`
- tool/vocabulary/corpus/b08/answers/typesetter-pages.txt ### Spread @834: 48 of 153 nodes the same; 12 differ, 93 only in the code's, 62 only in the definition's; document keys roots, variables
  - `r0.body.0.decoration.strokeSides: "r0.body.1.0.2.0.0.1" / "r0.body.1.1.0.0.1"`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2"]; r0.body.1.props.crossAxisAlignment: "stretch" / "start"; r0.body.1.props.scrollable: (none) / true`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1","r0.body.1.0.2"] / ["r0.body.1.0.0","r0.body.1.0.1"]; r0.body.1.0.layout.flex: 1 / (none); r0.body.1.0.layout.height.fill: 0 / (none)`
- tool/vocabulary/corpus/b08/answers/typesetter-pages.txt ### Spread @390: 48 of 125 nodes the same; 12 differ, 65 only in the code's, 62 only in the definition's; document keys variables
  - `r0.body.0.decoration.strokeSides: "r0.body.1.0.2.0.0.1" / "r0.body.1.1.0.0.1"`
  - `r0.body.1.children: ["r0.body.1.0","r0.body.1.1"] / ["r0.body.1.0","r0.body.1.1","r0.body.1.2"]; r0.body.1.props.crossAxisAlignment: "stretch" / "start"; r0.body.1.props.scrollable: (none) / true`
  - `r0.body.1.0.children: ["r0.body.1.0.0","r0.body.1.0.1","r0.body.1.0.2"] / ["r0.body.1.0.0","r0.body.1.0.1"]; r0.body.1.0.layout.flex: 1 / (none); r0.body.1.0.layout.height.fill: 0 / (none)`
- docs/reference/notation/lists.md block 4 @1440: 17 of 18 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
- docs/reference/notation/lists.md block 4 @834: 17 of 18 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
- docs/reference/notation/lists.md block 4 @390: equal
- docs/reference/notation/lists.md block 10 @1440: 40 of 41 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
- docs/reference/notation/lists.md block 10 @834: 40 of 41 nodes the same; 1 differ, 0 only in the code's, 0 only in the definition's
  - `r0.body.0.media: [{"maxWidth":1023,"patch":{"layout":{"padding":[24,48,24,48]}}},{"maxWidth":699,"patch"... / (none)`
- docs/reference/notation/lists.md block 10 @390: equal

## Problems in the definitions

- Shortcut.txt:2: the first line Shortcut stands for is a node (Column, Row, Card…), with the others under it: write the lines indented under a Column.
