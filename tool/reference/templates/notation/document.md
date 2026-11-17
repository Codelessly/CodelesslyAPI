# The document

What is not a node's line: the canvas line, variables of the screen and of the site, timers and shortcuts, other
canvases, the fields of every node, and the base's examples. Open it when a document needs a canvas name, path,
size or fill, a site's variables, or a field every node has.

## The order of a document

`state` lines, then the `canvas` line, then the tree, then the screen's `every` and `key` lines, then overlays
and other canvases (`Canvas#id`), each at the margin.

```notation
state count=0
canvas "Counter" path="/counter" h=844 fill=#FFF9FAFB
Column gap=12 pad=16
  Text "{count}"
every 1s onTick={count=count+1}
```

- **`canvas`** sets the screen: its name in quotes, `path`, `w`, `h`, `fill`, and any other field by its path from
  the canvas (`props.blockBack=true`). `canvas none`: the document has no canvas, its root is the first line.
- **`state`** declares a variable of the screen ([state.md](state.md)); `saved` keeps it on the device.
- **`project name=value`** reads and sets a variable of the whole site (declared in site.json) by name.
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

{{reference}}

{{examples}}
