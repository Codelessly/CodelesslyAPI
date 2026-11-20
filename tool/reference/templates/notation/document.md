# The document

What is not a node's line: the canvas line, variables of the screen and of the site, timers and shortcuts, other
canvases, the fields of every node, and the base's examples. Open it when a document needs a canvas name, path,
size or fill, a site's variables, or a field every node has.

## The order of a document

`state` lines, then the `canvas` line, then the tree, then the screen's `every`, `key` and `on` lines, then overlays
and other canvases (`Canvas#id`), each at the margin.

```notation
state count=0
canvas "Counter" path="/counter" h=844 fill=#FFF9FAFB
Column gap=12 pad=16
  Text "{count}"
every 1s onTick={count=count+1}
```

- **`canvas`** sets the screen: its name in quotes, `path`, `w`, `h`, `fill`, and any other field by its path from
  the canvas (`props.blockBack=true`). `canvas none`: the document has no canvas, its root is the first line. The
  canvas's id is not written on it (`canvas#menu` is not a canvas line): a site's page is named by its file
  (`pages/chat-menu.txt` is `chat-menu`), a lone file by `expand --id chat-menu`.
- **Ids**: a document holds one node per id, the page's canvas, its overlays and both branches of an `if`
  included: an `if` and its `else` that each draw a close button give them two ids, or write one line whose
  values are worked out (`label={open ? "Hide" : "Show"}`).
- **`state`** declares a variable of the screen ([state.md](state.md)); `saved` keeps it on the device.
- **`project name=value`** reads and sets a variable of the whole site (declared in site.json) by name. The whole
  manifest (pages, variables kept with `persist`, the theme's colors, styles, spacing and radii) is on
  [site.md](site.md).
- **`every <interval> [when cond] onTick={…}`** and **`key <keys> [when cond] onPress={…}`**: a timer and a
  shortcut of the screen (`mod` is Ctrl, or ⌘ on a Mac).

```notation expands
project cart=[]
Text "{length(cart)} in the cart"
```

## Fields of every node

Beside its word's keys, every line takes these (and the keys any line takes on the feature pages: `sticky`,
`motion`, `states`…):

{{nodeKeys}}

A line's `#id` is the node's id; `node {…}` writes a whole node as JSON and a `{…}` tail adds JSON to a line:
both read, and a print uses them only where the notation has no word yet ([_tails.md](_tails.md)).

## Forms a print uses

Three forms say what the shorter words cannot; a writer rarely needs them, and a print of a document has them:

- **`key=null`**: the node has no such field, though the line would give it one (a Row's cross-axis alignment, a
  text's size from its look): `Row crossAxisAlignment=null`.
- **`slot name`** under a line: the line under it fills that slot of the node (a ListTile's `title`, `leading`,
  `trailing`), where the lines under a node would not land there by themselves.
- **`type=Name`**: the line is a design system's component a word of the notation shadows (`Button "Save"
  type=Button variant=ghost` is the design system's Button, not the notation's) ([components.md](components.md)).

```notation
Column
  ListTile
    slot title
      Text "Hello"
    slot trailing
      Icon "chevron_right"
  Row crossAxisAlignment=null
    Text "a"
```

The screen's other reactions (`on load={…}`) are lines of their own after the tree ([events.md](events.md)).

{{reference}}

{{examples}}
