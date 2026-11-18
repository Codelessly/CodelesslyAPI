# Components

Calling a component, and writing one: its head (`component`, `param`, `event`, `slot`, `preview` lines) and its
tree. Open it when a UI reuses a part, or you write a component for a site or a design system.

## Calling one

A component is written like any word: `Name "text" @name key=value onEvent={…}`. Its strings fill its text
parameters in order; `@name` is the variable it keeps its value in (its `value`, else its first variable
parameter), `key=@name` each further variable parameter (`direction=@dir`); its events are `on…` keys by their own
names.

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

- `param name[:Type]=default`: a parameter, its type in Flutter's names (`String`, `bool`, `double`, `int`,
  `List<…>`, `ValueNotifier<…>` for a variable parameter, an enum's values joined by `|`) where the default does
  not say it; `required` and `doc="…"` after it.
- `event name:Type`: an event and the type of its payload.
- `slot name`: a place the caller fills with lines.
- `preview "Name" 340x66 key=value …`: a preview, its size and the call's values.

A word defined in the text (`define`, [design-systems.md](design-systems.md)) is written out where it is used: it
is not a component of the document.

{{reference}}

{{examples}}
