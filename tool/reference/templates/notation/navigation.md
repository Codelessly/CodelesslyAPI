# Navigation and overlays

Page frames (Page, Section, Nav, App, Sidebar…), screens and going between them, dialogs, sheets, drawers, menus,
popovers, lightboxes, toasts, app bars and tabs. Open it when a UI has more than one screen, a frame, or anything
over the page.

## Page frames

A page is written once inside a frame that owns the widths, margins and scrolling. A website's bands stack in a
`Page`; an app window is an `App` of panes. Written under another line (`Page grow` under a site's own header, `App
grow` under a page's), each is that region of the page: its scrolling column of bands, or its panes side by side,
taking the room its column leaves. The frame words: {{pageWords}}.

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
it shares the room). Lines at the top of a `Main` or a `Pane` written `sticky` (its toolbar) are its head: they
stay above while the rest scrolls under them, never over it. A line in it that takes the room left (`grow`,
`h=fill`: a board's lanes, a list that scrolls itself) makes the pane a plain column that does not scroll. A key
with a size before it changes a pane at that width ([responsive.md](responsive.md)):
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

A `Splitter` between two panes lets the reader resize one. It keeps that pane's width in a variable (`@listW`) and
the pane reads it (`w={listW}`); with `pane=after` the variable is the width of the pane after it (an inspector at
the window's end), so dragging toward the end narrows that pane. It is as tall as the row it is in, a hairline in a
desktop window (8 px to grab, a grip under the pointer or the keyboard's focus); where the pane beside it draws its
own border on that side, that border is the line and the splitter draws none. Arrows, Home and End move it.

```notation width=1280 expands
state listW=360
state inspectorW=320
App
  Pane w={listW} border-right=line
    Text.heading "Messages"
  Splitter @listW min=280 max=520 label="Resize the list"
  Main
    Text.title "Reading"
  Splitter @inspectorW min=240 max=480 pane=after label="Resize the details"
  Pane w={inspectorW} border-left=line
    Text.heading "Details"
```

## Over the page

An overlay is written after the page, at the margin, with an id; its content is indented under it. `open id`
shows it, `close` closes it (so does a tap outside it). `Dialog` (centered, a title and a close button), `Sheet`
(from the bottom; `stops=[0.5,0.9]`), `Drawer` (a side panel; `right`), `Menu` (by the button that opened it;
`MenuItem` lines), `Popover` (a small panel; `preview=id` on a line opens it on hover), `Lightbox` (a picture or a
gallery over the page). A `MenuItem` is its label, `icon=`, `onTap={…}` and, to name it in a render step, an id
(`MenuItem#dup "Duplicate" icon=content_copy onTap={…}`). A MenuItem closes its menu after its actions (one that
opens a dialog closes the menu first); write no `close` in it.

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
site's theme and its dark mode; a `Drawer` has no rule at its side unless its line writes a `border`. A dialog that
asks before unsaved work is discarded:

```notation width=1280 expands
state draft=""
Column gap=12
  Button "Compose" onTap={open compose}
Dialog#compose "New message" guard={draft != ""} guardText="Discard the draft?" onDiscard={draft=""}
  Input "Message" @draft multiline
  Button "Send" onTap={draft=""; close}
```

In a site an overlay is a screen of the whole site. Two pages may each write one id (`Drawer#nav` on the board page
and on the list page): written alike on both, it is one overlay; drawn differently, `expand` gives each page its own,
`nav--board` and `nav--list` (`<id>--<page>`: no id a writer writes has `--`; a page file of that name is said, and
that overlay left one with the others), and every `open nav`, `go nav` and `confirm … dialog=nav` of that page opens
the page's own. A component's `open nav` opens the calling page's; a page that calls it and writes no `nav` while
other pages write differing ones is said, with what to write. A render step names the overlay as its page wrote it
(`--tap nav/close` on the board page), the outline shows `canvas nav--board (#nav as written on page board …)`, and
`print` gives the page back as written (`nav`).

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
