# Navigation and overlays

Page frames (Page, Section, Nav, App, Sidebar…), screens and going between them, dialogs, sheets, drawers, menus,
popovers, lightboxes, toasts, app bars and tabs. Open it when a UI has more than one screen, a frame, or anything
over the page.

## Page frames

A page is written once inside a frame that owns the widths, margins and scrolling. A website's bands stack in a
`Page`; an app window is an `App` of panes. The frame words: {{pageWords}}.

```notation width=1280 expands
Page
  Nav
    Brand "Tidewater" icon="waves"
    Link "Pricing"
  Section
    Heading "Fill every room" level=1
  Footer
    Text.muted "© 2026"
```

```notation width=1280 expands
state tab="orders"
App
  Sidebar
    NavItem "Orders" icon="receipt_long" selected={tab=="orders"} onTap={tab="orders"}
  Main
    Text "Orders"
```

### A sidebar

Write a sidebar with its own words and it is finished without styling: `Brand "Name" "line under it" icon="…"` at
its head; `NavSection "People & access"` over a group of items (small spaced capitals in a quiet ink, with room over
it); `NavItem "Members" icon="group"` for each item, with `selected={…}` for the chosen one (the accent and a tint
of it; the others share one ink and tint under the pointer), `badge="4"` for a count and `shortcut="Alt 1"` for a
key shown at its end; and `Footer` for what stays at the sidebar's end whatever is above it (the signed-in person,
help, shortcuts): the lines under it are pinned there, with a rule over them. In a column written by hand, a
`Spacer` (or an empty `box grow`) between two lines pushes the second to the end, as `margin-top: auto` does on the
web; the column needs a height (`h=fill`).

```notation width=1280 expands
state tab="members"
App
  Sidebar
    Brand "Tenant" "Admin console" icon="hub"
    NavSection "People & access"
    NavItem "Members" icon="group" selected={tab=="members"} onTap={tab="members"} shortcut="Alt 1"
    NavItem "Teams" icon="groups" badge="4" selected={tab=="teams"} onTap={tab="teams"}
    NavSection "Workspace"
    NavItem "Billing" icon="credit_card" selected={tab=="billing"} onTap={tab="billing"}
    Footer
      NavItem "Keyboard shortcuts" icon="keyboard" shortcut="?"
  Main
    Text "Members"
```

A desktop window of three panes: a rail, the content, an inspector. `Sidebar` is the rail (`w=72` for icons only),
`Main` takes the room left and scrolls, each `Pane` is a further column as tall as the window (`w=` its width, else
it shares the room). A key with a size before it changes a pane at that width ([responsive.md](responsive.md)):
here the inspector leaves at a tablet's width and the rail at a phone's.

```notation width=1280 expands
state tab="inbox"
App
  Sidebar w=72 hide=phone
    NavItem "Inbox" icon="inbox" selected={tab=="inbox"} onTap={tab="inbox"}
    NavItem "Sent" icon="send" selected={tab=="sent"} onTap={tab="sent"}
  Main
    Text.title "Inbox"
  Pane w=320 hide=tablet
    Text.heading "Details"
```

## Over the page

An overlay is written after the page, at the margin, with an id; its content is indented under it. `open id`
shows it, `close` closes it (so does a tap outside it). `Dialog` (centered, a title and a close button), `Sheet`
(from the bottom; `stops=[0.5,0.9]`), `Drawer` (a side panel; `right`), `Menu` (by the button that opened it;
`MenuItem` lines), `Popover` (a small panel; `preview=id` on a line opens it on hover), `Lightbox` (a picture or a
gallery over the page). A `MenuItem` is its label, `icon=`, `onTap={…}` and, to name it in a render step, an id
(`MenuItem#dup "Duplicate" icon=content_copy onTap={…}`).

```notation width=1280 expands
Column gap=12
  Button "Join" onTap={open signup}
Dialog#signup "Join the waitlist"
  Button "Close" onTap={close}
```

A Dialog, Sheet or Drawer that must not close while something is typed says so on its line: `guard={dirty}` (or
`blockBack={dirty}`) keeps Escape, a tap outside and back from closing it while it holds; `guardText="Discard the
draft?"` asks that first (a yes runs `onDiscard={…}` and closes); `onBackPressed={open keepDraft}` runs instead.
With no design system the panel is drawn in the theme's `surface` and its title in `onSurface`, so it follows the
site's theme and its dark mode; a `Drawer` has no rule at its side unless its line writes a `border`. For example
`Dialog#compose "New message" guard={draft != ""} guardText="Discard the draft?" onDiscard={draft=""}`.

## Screens

Another canvas of the document is a `Canvas#id` block at the margin after the page, its tree under it; `go id`
opens it. The page's own canvas is the `canvas` line ([document.md](document.md)).

```notation
Column
  Button "About" onTap={go about}
Canvas#about "About" path="about"
  Text "About us"
```

{{reference}}

{{examples}}
