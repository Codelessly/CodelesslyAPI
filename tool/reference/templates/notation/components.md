# Components

Calling a component, and writing one: its head (`component`, `param`, `event`, `slot`, `preview` lines) and its
tree. Open it when a UI reuses a part, or you write a component for a site or a design system.

## Calling one

A component is written like any word: `Name "text" @name key=value onEvent={…}`. Its strings fill its text
parameters in order; `@name` is the variable it keeps its value in (its `value`, else its first variable
parameter), `key=@name` each further variable parameter (`direction=@dir`); its events are `on…` keys by their own
names. `onTap` on a component whose press event has another name (`onPressed`, `onClick`) is that event, as
`onChange` is its `onChanged` and `onSubmit` its `onSubmitted`; any other `on…` it has no event of is what that
name does on any line: `TaskCard … onTap={open card}` on a card whose only event is `onMenu` opens the card on a
press anywhere on it (its menu button keeps its own press).

A site's own components are known to the expander with nothing more said: a file in a site's folder (its
`pages/` or `components/`, or a folder with a `site.json` or an `app.txt` beside it or above it) calls every
component written in the notation in its `components/*.txt` and every expanded one `site.json` lists, reads the
site's shared state by name (`app.txt`'s, [site.md](site.md); a component that writes one does not make its own)
and takes the site's theme. `tool/notation/notation.sh expand
<site folder>` expands the whole site, each component after the ones it calls, then every page. A component named
like a word of the notation (`Footer`, `Sidebar`, `Card`) is not called where that word is read: the expander says
so; write `Footer type=Footer`, or give the component a name of its own (`SiteFooter`). A `components/<Name>.txt`
whose first line is `define Name …` (or `primitive`) is the site's definitions instead: every page and component
reads them, as a page reads a `define` after its last line; a file that is neither fails the expand, `--open` too,
saying what to write. A word the notation already has is the notation's, whoever defines it: a page's or a site's
`define`, `primitive` or component named like a core word or a page word (`Card`, `Rail`) is not used, and the
expand says so at the definition. A name the notation only reads as another of its words (`MonthGrid` as
`Calendar`, `DataTable` as `Table`) is yours to define: a `define` of it is the one read (a `primitive` of it,
which has no lines to draw, is not). A defined word whose lines are an overlay (`define SideMenu` over
`Drawer#menu â€¦`) is that overlay wherever its use is written, opened by the id its lines give (`open menu`). Every
expand saves the site's vocabulary record (`vocabulary.json` and `VOCABULARY.md` in the site's folder) and says
each word that stood in as a placeholder.

A dictionary is a folder of definitions kept apart from any one site: a `<Word>.txt` per word, each a `define` (or
a `primitive`). The expand, print, prompt and render commands read one named by `--dictionary <folder>` (written
again for each further folder), by the `CODELESSLY_DICTIONARY` environment variable when no `--dictionary` is
written (folders separated as in `PATH`), and by a site's `site.json` (`"dictionary": ["../words"]`, relative to
its folder). A word is read from the first that defines it: the page's own `define`, then the site's or the design
system's definitions, then the dictionaries in the order given, then the notation's own words. The vocabulary
record names the dictionary's folder as where its words came from, and the prompt lists its words, one line each
as a line uses it. The notation's shorthand words of earlier versions (`Heading`, `NavItem`, `Link`, `Brand` …) are
such definitions now: a dictionary that has them reads pages written with them.

<!-- shorthand -->
## The shorthand words of earlier versions

Up to 37.x the notation had shorthand words of its own (`Heading`, `NavItem`, `Link`, `Brand` …). They are plain
definitions now: put the ones a page uses in a dictionary folder (a file each, named after the word) or in the
site's `components/`, and the page reads them. Each has one meaning, the same wherever it is written; its comment
says what it is for (the prompt shows that when it lists a dictionary's words).

`Heading.txt`:

```
define Heading "text" level=2
  Text.{level == 1 ? "heading1" : level == 2 ? "heading2" : "heading3"} "{text}" ...
```
`H1.txt`:

```
define H1 "text"
  Text.heading1 "{text}" ...
```
`H2.txt`:

```
define H2 "text"
  Text.heading2 "{text}" ...
```
`H3.txt`:

```
define H3 "text"
  Text.heading3 "{text}" ...
```
`H4.txt`:

```
define H4 "text"
  Text.strong "{text}" ...
```
`Title.txt`:

```
define Title "text"
  Text.title "{text}" ...
```
`Brand.txt`:

```
define Brand "name" "under" icon
  Row gap=10 middle pad=[8,6,8,10] ...
    if icon
      Box w=28 h=28 radius=8 fill={theme.accent} center middle
        Icon "{icon}" size=16 color=#FFFFFFFF
    if under
      Column gap=0
        Text "{name}" size=15 weight=700
        Text "{under}" size=11 color={coalesce(theme.mutedInk, "#FF6B7280")}
    else
      Text "{name}" size=15 weight=700
```
`NavItem.txt`:

```
define NavItem "label" icon badge selected=false
  Row w=fill gap=10 middle pad=[10,7,10,7] radius=6 selected={selected} selected.fills=[{"color":"{theme.accent}","opacity":0.12}] hovered.fill={theme.hoverFill} ...
    if icon
      Icon "{icon}" size=18 color={coalesce(theme.mutedInk, "#FF6B7280")}
    Text "{label}" size=13 weight=500 color={coalesce(theme.quietInk, "#FF374151")} grow
    if badge
      Text.muted "{badge}"
```
`NavSection.txt`:

```
define NavSection "label"
  Text "{upper(label)}" size=11 weight=600 letterSpacing=0.6 color={coalesce(theme.mutedInk, "#FF6B7280")} w=fill pad=[10,16,10,6] ...
```
`SidebarFooter.txt`:

```
define SidebarFooter gap=2 pad=[0,8,0,0]
  Spacer
  Column w=fill gap={gap} pad={pad} border-top={theme.line} ...
    ...
```
`Link.txt`:

```
define Link "label" href
  if startsWith(coalesce(href, ""), "#")
    Text "{label}" color={coalesce(theme.accentText, theme.accent)} onTap={scroll {replace(href, "#", "")}} ...
  else if href
    Text "{label}" color={coalesce(theme.accentText, theme.accent)} onTap={link {href}} ...
  else
    Text "{label}" color={coalesce(theme.accentText, theme.accent)} ...
```
`IconTile.txt`:

```
define IconTile "name" size=40 color fill
  Box w={size} h={size} radius={round(size/4)} fill={coalesce(fill, theme.iconTile, theme.selectedFill)} center middle ...
    Icon "{coalesce(name, "star")}" size={round(size/2)} color={coalesce(color, theme.accent)}
```
`Dots.txt`:

```
define Dots @page=0 count=3
  Row gap=6 center middle h=16 ...
    each dot in range(count)
      Box w={index==page?16:6} h=6 radius=3 fill={index==page?theme.accent:theme.track} onTap={page=index}
```
`ConfirmDialog.txt`:

```
define ConfirmDialog "title" "message" confirm="Confirm" cancel="Cancel" danger=false onConfirm onCancel
  Dialog "{title}" "{message}" ...
    ...
    Row gap=8 end
      Button.ghost "{cancel}" onTap={onCancel; close}
      Button.{danger ? "destructive" : ""} "{confirm}" onTap={onConfirm; close}
```
`Shortcut.txt`:

```
define Shortcut "chord" key keys combo hint description label onPress
  key {replace(coalesce(chord, key, keys, combo), " ", "")} ... onPress={onPress}
```
`computed.txt`:

```
define computed
  state ...
```

The other names they had are a definition each over these: `Logo` (as `Brand`), `NavLink` (as `NavItem`), `SidebarItem` (as `NavItem`), `MenuItem` (as `NavItem`), `NavGroup` (as `NavSection`), `NavLabel` (as `NavSection`), `SidebarSection` (as `NavSection`), `SidebarLabel` (as `NavSection`), `SidebarGroup` (as `NavSection`), `NavFooter` (as `SidebarFooter`), written as `define Logo "name" "under" icon`
over `Brand "{name}" "{under}" icon={icon} ...`.
<!-- /shorthand -->

## Writing one

A component's document is its head, then its tree (no canvas):

```notation
component StatusPill "A short status, colored by its tone."
  param label="Active" required doc="What it says."
  param tone:neutral|success|danger="neutral"
  event onChanged:String doc="The new label."
  slot trailing
  preview "Default" 120x28 label="Active" tone="success"
Row#pill gap=4
  Text#pillLabel "Active"
```

- `param name[:Type]=default`: a parameter, its type in Flutter's names (`String`, `bool`, `double`, `int`, `Map`
  or `dynamic` for a record or anything, `List<…>` (`List<Map>`: records; `List` alone: anything), `ValueNotifier<…>` for a variable parameter, an enum's values joined by `|`) where the default does
  not say it; `required` and `doc="…"` after it. These are not a `state` line's type words (`boolean`, `decimal`,
  `text`: [state.md](state.md#state-variables)): `param open:bool=false`, `state open:boolean=false`. `param @selected=""` is a variable parameter of its default's type:
  the tree reads it as `props.selected` and sets it with `props.selected=…`, and the call keeps it in its own
  variable (`Picker @choice`); a control in the tree binds it both ways as `Input @selected` or `Input
  @props.selected` (a define's `@name=…` the same: `Input @name`). A parameter the call only gives cannot be set from inside.
- `event onName:Type`: an event, its name beginning `on` (`event onShare`, not `event share`; the call handles it
  as `onShare={…}`), and the type of its payload (`event onPick:void`, or no type: it passes nothing); `emit name value` sends it (`emit onRemove props.label`, `emit onNavigate "{result}"`: a text with values in it reads them).
- `slot name`: a place the caller fills with one line (several actions in a slot: a Row around them). The tree
  shows it with `Slot name=name`. The lines under a call go in its slot (`trailing`, `actions`, `action` or `end`
  when it has one, else its first), and a `Slot` with no name is that slot, unless the head says `children=list`
  (then a `Slot` with no name shows the call's children).
- `preview "Name" 340x66 key=value …`: a preview, its size and the call's values.

A component's `key`, `every` and `on load` lines, after its tree, are the screen's that shows it: each page that
calls it takes them once, however many calls (a sidebar's `key alt+1 onPress={go members}` written once in the
sidebar, not on every page). A page's own line for the same key is the page's. They run on that screen, so they
read and set the page's and the site's variables, not the component's own: the expander says so when one does.
So are the overlays it writes after its tree (`Drawer#basket "Your bag" right w=440`, `Sheet#info stops=[0.5,0.9]`):
each page that calls it has them, shown as written wherever `open basket` runs (a page's own overlay of that id is
the one it shows). Their lines read the page's and the site's variables, not the component's parameters.

A word defined in the text (`define`, [design-systems.md](design-systems.md)) is written out where it is used: it
is not a component of the document.

{{reference}}

{{examples}}
