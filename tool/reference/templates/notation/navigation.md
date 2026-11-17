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

## Over the page

An overlay is written after the page, at the margin, with an id; its content is indented under it. `open id`
shows it, `close` closes it (so does a tap outside it). `Dialog` (centered, a title and a close button), `Sheet`
(from the bottom; `stops=[0.5,0.9]`), `Drawer` (a side panel; `right`), `Menu` (by the button that opened it;
`MenuItem` lines), `Popover` (a small panel; `preview=id` on a line opens it on hover), `Lightbox` (a picture or a
gallery over the page).

```notation width=1280 expands
Column gap=12
  Button "Join" onTap={open signup}
Dialog#signup "Join the waitlist"
  Button "Close" onTap={close}
```

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
