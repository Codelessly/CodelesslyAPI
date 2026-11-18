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

A site's own components are known to the expander with nothing more said: a file in a site's folder (a
`site.json` beside it or above it, as `site.json` or `site/site.json`) calls every component written in the
notation in its `components/*.txt` and every expanded one `site.json` lists, reads the site's variables by name
(a component that writes one does not make its own) and takes the site's theme. `tool/notation/notation.sh expand
<site folder>` expands the whole site, each component after the ones it calls, then every page. A component named
like a word of the notation (`Footer`, `Sidebar`, `Card`) is not called where that word is read: the expander says
so; write `Footer type=Footer`, or give the component a name of its own (`SiteFooter`). A `components/<Name>.txt`
whose first line is `define Name …` (or `primitive`) is the site's definitions instead: every page and component
reads them, as a page reads a `define` after its last line; a file that is neither fails the expand, `--open` too,
saying what to write. A word the notation already has is the notation's, whoever defines it: a page's or a site's
`define`, `primitive` or component named like a core word, a page word or a name the notation reads as one of its
own (`Card`, `Rail`, `Shortcut`) is not used, and the expand says so at the definition. Every
expand saves the site's vocabulary record (`vocabulary.json` and `VOCABULARY.md` in the site's folder) and says
each word that stood in as a placeholder.

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
  not say it; `required` and `doc="…"` after it. `param @selected=""` is a variable parameter of its default's type:
  the tree reads it as `props.selected` and sets it with `props.selected=…`, and the call keeps it in its own
  variable (`Picker @choice`). A parameter the call only gives cannot be set from inside.
- `event name:Type`: an event and the type of its payload (`event onPick:void`, or no type: it passes nothing); `emit name value` sends it (`emit onRemove props.label`, `emit onNavigate "{result}"`: a text with values in it reads them).
- `slot name`: a place the caller fills with one line (several actions in a slot: a Row around them).
- `preview "Name" 340x66 key=value …`: a preview, its size and the call's values.

A component's `key`, `every` and `on load` lines, after its tree, are the screen's that shows it: each page that
calls it takes them once, however many calls (a sidebar's `key alt+1 onPress={go members}` written once in the
sidebar, not on every page). A page's own line for the same key is the page's. They run on that screen, so they
read and set the page's and the site's variables, not the component's own: the expander says so when one does.

A word defined in the text (`define`, [design-systems.md](design-systems.md)) is written out where it is used: it
is not a component of the document.

{{reference}}

{{examples}}
