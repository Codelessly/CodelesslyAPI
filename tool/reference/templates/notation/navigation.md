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
    Text.strong "Tidewater"
    Button.ghost "Pricing" onTap={scroll pricing}
  Section#pricing
    Text.heading1 "Fill every room"
  Footer
    Text.muted "© 2026"
```

A website's text is a website's size. Under a `Page`, outside its bar, a `Text` whose line says no size takes:
`heading1` and `pageTitle` 64, `heading2` 38, `heading3` 24, `title` 22, `heading` 18, running text (`Text`,
`bodySecondary`, `muted`, `strong`) 16, `small` and `mono` 14, `caption` 13; on a phone the headlines are smaller
(reflow) and `heading3` and `title` are 18. A style the site's theme gives a size keeps it, and a theme that sizes `body` sizes the styles drawn
from it. A theme that has a style for a page beside the one for an app, named `<look>Page` (`heading1Page` beside
`heading1`, `leadPage`, `bodyPage`: a design system made for an app's window says so what its headline, its lead
and its running text are on a website), gives a text under a `Page` that style whole, its size, line height and
spacing; the page's bar and its `Footer` keep the app's. What a site's theme says of a look (`"textStyles":
{"heading2": {"fontWeight": 400}}`) it says of the page's style too. An app's sizes are the theme's own
(`heading1` 30, body 13): nothing under an `App` changes. A quiet button in a bar
(`Button.ghost "Pricing" onTap={go pricing}`) is a link: 15 semibold on a website, and drawn selected (the
accent's tint and ink) on the page it goes to, unless the line says `selected=` itself. A `Section tint` stands
on the theme's `band`, or a step off the page's ground when the theme names none. A band takes a ground of its
own: `Section fill=primary`, `Section gradient=["#FF16222E","#FF2E4A62"]`, or a picture, `Section
image="assets/harbour.jpg"` (from edge to edge under a scrim its text reads on: `scrim=#99102030` says another,
`scrim=none` none; `image={cover}` reads it from the state). The texts written on a dark fill, a dark gradient, a
picture or the accent are in the ink that reads there (white, a lead and a muted line a little dimmer, a caption
dimmer still; on `fill=primary` the theme's `onPrimary`), unless a line says its `color` or stands on a ground of
its own (a `Card` on the band, a `Box fill=`). The first `Section` under the page's bar keeps a section's whole
space above it when it holds the page's headline (`Text.heading1`, `Text.pageTitle`, a text of `size=32` and up: a
hero) and starts half of it down when it does not (a list, a form: a page that is a tool). A `Nav` takes `maxw` for how
wide its items spread, in the middle of the bar. A Column (Row, Stack) written `maxw=` straight in the column
that scrolls the page (an app's `Main`, a `Column scroll`) is the page's content and stands in its middle, unless
the line or that column says a side.

```notation width=1280 expands
state tab="orders"
App
  Sidebar
    Row w=fill gap=10 middle pad=[10,7,10,7] radius=6 selected={tab=="orders"} selected.fill=#142563EB onTap={tab="orders"}
      Icon "receipt_long" size=18
      Text "Orders" grow
  Main
    Text "Orders"
```

### A sidebar

A sidebar is the lines written under it: the product's name at its head; a small label in spaced capitals over a
group of items; a `Row` for each item (an `Icon`, a `Text grow`, a count), whose `selected={…}` with a
`selected.fill=` draws the chosen one, and a `hovered.fill=` the tint under the pointer; and `Footer` for what stays
at the sidebar's end whatever is above it (the signed-in person, help, shortcuts): the lines under it are pinned
there, with a rule over them. In a column written by hand, a `Spacer` (or an empty `box grow`) between two lines
pushes the second to the end, as `margin-top: auto` does on the web; the column needs a height (`h=fill`). Words of
one's own for these lines (`NavItem "Members" icon="group"`) are definitions: a page's, a design system's, or a
dictionary's ([components.md](components.md)).

```notation width=1280 expands
state tab="members"
App
  Sidebar
    Text "Tenant" size=15 weight=700 pad=[8,6,8,10]
    Text "PEOPLE & ACCESS" size=11 weight=600 letterSpacing=0.6 color=#FF6B7280 pad=[10,16,10,6]
    Row w=fill gap=10 middle pad=[10,7,10,7] radius=6 selected={tab=="members"} selected.fill=#142563EB hovered.fill=#0F111827 onTap={tab="members"}
      Icon "group" size=18
      Text "Members" grow
    Row w=fill gap=10 middle pad=[10,7,10,7] radius=6 selected={tab=="teams"} selected.fill=#142563EB hovered.fill=#0F111827 onTap={tab="teams"}
      Icon "groups" size=18
      Text "Teams" grow
      Text.muted "4"
    Footer
      Row w=fill gap=10 middle pad=[10,7,10,7] radius=6 hovered.fill=#0F111827
        Icon "keyboard" size=18
        Text "Keyboard shortcuts" grow
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
    IconButton "inbox" selected={tab=="inbox"} onTap={tab="inbox"}
    IconButton "send" selected={tab=="sent"} onTap={tab="sent"}
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
(from the bottom; `stops=[0.5,0.9]`), `Drawer` (a side panel; `right`; a line tapped in it closes it, and a
control in it when it goes somewhere: `go`, `scroll`, `open`), `Menu` (by the button that opened it), `Popover` (a
small panel; `preview=id` on a line opens it on hover), `Lightbox` (a picture or a gallery over the page). A menu's lines
are rows with `onTap={…}` (an `Icon` and a `Text` under each) and, to name one in a render step, an id
(`Row#dup gap=10 pad=8 onTap={…}`). Each closes its menu after its actions (one that opens a dialog closes the menu
first); write no `close` in it.

```notation width=1280 expands
Column gap=12
  Button "Join" onTap={open signup}
Dialog#signup "Join the waitlist"
  Button "Close" onTap={close}
```

An overlay's id is one of the page's ids, so the line that opens it has another (`IconButton#openFilters …
onTap={open filters}` and `Sheet#filters`). The actions after `open id` in the same chain run once the overlay has
closed, however it closed (its `close`, a tap outside, a drag down, Escape, back): that is where a page reacts to a
sheet going away, and `result` there is what `closeModal result=…` gave; an overlay line has no `onClose`. A
Sheet's own corners are 20 at its top; `radius=` on its line rounds the content under it, not the sheet. A key of
the `openModal` that shows it, written on the overlay's line, is what every `open` of it says: `Sheet#options
"Options" sheetRadius=10 showDragHandle=false`, `Dialog#confirm barrierDismissible=false`.

```notation width=390 expands
state rating=0
state rated=false
Column gap=12
  Button "Rate" onTap={open rate; rated=rating > 0}
Sheet#rate "Rate your anxiety"
  Slider @rating min=0 max=10
  Button "Done" onTap={close}
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

A Dialog's content has a 24 px inset and a Sheet's `[20,8,20,24]`, under a grip, with 20 px top corners: `pad=0`
leaves the inset to the content. The fields of the route that shows it are written on its line too, as on an
`openModal`: `Sheet#live maxHeightFactor=0.95 showDragHandle=false sheetRadius=10 barrierColor=#8A000000`, or
`Dialog#d insets=[24,48,24,48]`.

A Sheet with stops keeps the stop it rests at in a variable: `stop=@name`, read and written. It holds the stop as
`stops=` writes it (`0.5`, `1`), and `0` while the sheet is closed. The sheet writes it as it opens and when it is
dragged (or moved by its handle or the keyboard) to another stop; setting it (`sheetStop=1`) moves the open sheet to
the nearest stop, and a sheet opened while it holds one of its stops opens there. A summary at the low stop and the
whole article at the high one:

```notation width=390 expands
state sheetStop=0
Column gap=12
  Button "Read" onTap={open story}
Sheet#story "The tide tables" stops=[0.5,1] stop=@sheetStop
  Text.muted "A summary" visible={sheetStop < 1}
  Button.ghost "Read it all" visible={sheetStop < 1} onTap={sheetStop=1}
  Text "The whole article" visible={sheetStop == 1}
```

### By the node that opened it

A `Menu` or `Popover` sits by the node whose tap opened it: below it at its start unless its line says `above`,
`end` or `center` (or `placement=aboveEnd`, `rightCenter`…: [PopoverPlacement](values.md#enum-PopoverPlacement)).
Where that side has no room it flips to the other, and it is moved along to stay on the screen; `arrow` points at
what opened it. `enterScale=0.6` makes it grow out of the node that opened it, from that size, as it comes in. A
time-zone picker on a button at the screen's bottom end (it opens above, its arrow pointing down at the button):

```notation width=390 expands
Stack w=fill h=844
  Button "Time zone" x={"end":12} y={"end":40} onTap={open zones}
Popover#zones w=240 arrow enterScale=0.6
  Text "Eastern" pad=8
  Text "Pacific" pad=8
```

### Over everything: a banner

`presentation=banner` shows a screen over everything, a dialog and its barrier included, with no barrier of its own:
the page behind stays usable. It comes in along the top edge (`alignment=[0,1]`: the bottom), inside the safe area;
a swipe toward its edge dismisses it, following the finger; `closeAfterMs=3000` closes it 3 s after it has come in,
the clock held while it is pressed or dragged. Banners show one at a time, in the order they were opened. Its
`routeTransition` says how it comes and goes (its `enter` side, and its `popExit` when it leaves another way) and
which way a swipe dismisses it (its `dismiss.direction`). The chain that opened it goes on when it has gone, with
`${result}` what its own `close result=…` gave, empty when it went by itself or was swiped away. A toast is this: any
screen, shown so. `closeAfterMs` closes a dialog or a sheet by itself too.

```notation width=390 expands
Column gap=12
  Button "Save" onTap={openModal to=saved presentation=banner closeAfterMs=3000}
Canvas#saved "saved" w=390 fill=#00000000
  Row w=fill center pad=12
    Row gap=8 pad=[16,8,16,8] radius=32 fill=#FFFFFFFF middle
      Icon "check_circle_outline" size=22 color=#FF00A3AD
      Text "Saved to your journal"
      Text "Undo" weight=700 onTap={closeModal result=undo}
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

`screen.url` is the address of the page as shown: in a browser the page's URL, in an app the location a link opens
the screen with (`/trip/coast`), and empty where the screen has none. `copy "{screen.url}"` copies it, and a `share`
action ([media.md](media.md)) passes it to the device's share panel.

```notation
Column
  Button "About" onTap={go about}
Canvas#about "About" path="about"
  Text "About us"
```

{{reference}}

{{examples}}
