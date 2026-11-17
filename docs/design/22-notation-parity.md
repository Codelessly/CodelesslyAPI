# 22. Parity: every document is the notation

2026-11-17. The owner's goal: full Codelessly API parity in the notation. Anything a schema-3 document can hold
is written in the notation's words and prints back in them. The `{…}` tail and the `node {…}` line stay as
the escape hatch they were designed as, and the measure of parity is that nothing needs them.

## 1. Where it stands (measured)

`tool/notation_coverage.dart` prints every document of a corpus with `printNotation` and counts what falls
into a `{…}` tail. Over 1,287 documents (the reference's examples, CodelesslySDK's design systems, examples and
test fixtures), at `4b395b93`:

| | |
|---|---|
| Documents printed whole as data (`document {…}`, no tree in words) | 1,087 (84%) |
| Node lines with a `{…}` tail | 90.4% |
| Characters in tails | 92.5% |
| Distinct tail paths | 649 |

Two different gaps make that number:

- **The printer writes 13 words.** The parser reads hundreds. `Text "x" size=18 color=#FF111111` parses, and
  prints back as `Text "x" {"props":{"style":{…}}}`. Most of the 90% is this.
- **The parser has no word** for some of the API: any trigger but eleven, any action but twelve, media rules
  beyond `hide=`/`show=`, behaviors (`pan`, `draggable`'s options, `dropTarget`'s), custom paint, animations,
  typed variables, a component's declaration.

And one defect found while measuring: **a key the parser does not know is put in `props` without a word**
(`squeezable=false` lands in `props.squeezable`, where nothing reads it; `letterSpacing=0.4` on a Text lands in
`props.letterSpacing`, not in its style). With the strict validator gone, nothing says so.

## 2. The rules (the grammar does not change)

The grammar of design 13 section 3 stands: `Type[.variant][#id] ["text"] [key=value ...]`, `key={expression}`,
`on…={actions}`. Parity is reached inside it. Nothing here adds a second way to write what already has one.

### 2.1 A key is the document's own name, found by the catalog

`key=value` on a line of type T means, in this order, the first that has that name:

1. a word of the notation (`gap`, `pad`, `fill`, `w`, `h`, `border`, `radius`, `size`, `weight`, `color`,
   `grow`, the alignment words, a universal word of design 21, a design system component's parameter);
2. a prop of T in the catalog;
3. a field of T's text style, where T shows text (`letterSpacing`, `fontFamily`, `height` on a Text is its line
   height: the catalog's prop wins over a layout field of the same name);
4. a layout field (`x`, `y`, `squeezable`, `flex`, `margin`, `minWidth`, `maxWidth`, `minHeight`, `maxHeight`,
   every other the catalog's layout declares);
5. a decoration field (`shape`, `strokeWidth`, `strokeSides`, `clip`, `effects`, `fills`, `strokes`, …);
6. a field of the node itself (`tooltip`, `opacity`, `visible`, `semantics`, …) and a behavior
   (`draggable`, `dropTarget`, `pan`, `dismissible`, …).

A nested field is the path from there, dotted: `pan.axis=horizontal`, `style.letterSpacing=0.4`,
`constraints.maxWidth=720`, `dropTarget.accepts=["clips"]`. The full path from the node always reads
(`layout.x=10`, `props.style.height=1.2`, `decoration.shape=circle`), and is what the printer writes when a
shorter name would be read as something else.

A value is a number, a bare word (an enum's name, `true`, `false`), a quoted string, or JSON for a list or a
map (`effects=[{"type":"dropShadow","blurRadius":8}]`). `key={expression}` binds that path
(`x={clip.start*px}` is `bind: {"layout.x": "${= clip.start*px}"}`); it already does for the keys the parser
knows, and now does for every key.

**A key that is none of these is said**, on its line, with the nearest name (`suggest.dart`): in the closed
vocabulary an issue, in the open one a recorded word (design 19), never a silent prop.

### 2.2 An event is the trigger's own name

`on<Trigger>={actions}` for every trigger type of the catalog, in the catalog's name with a capital
(`onDragEnd`, `onPanUpdate`, `onScroll`, `onEnterViewport`, `onLongPress`): the eleven the parser has keep their
names (`onTap` is `click`). A trigger's own fields are written in parentheses before the `=`, by name:
`onKey(key=enter, shift=true)={…}`, `onScroll(threshold=120)={…}`. `result` is the trigger's payload, as now.

### 2.3 An action is the action's own name

The verbs the notation has stay (`name=value`, `emit`, `toast`, `open`, `close`, `go`, `scroll`, `link`,
`announce`, `confirm`, `focus`, `copy`, `cond ? a : b`). Every other action type of the catalog is its type
name and its fields by name: `animate node=hero preset=fadeIn durationMs=300`, `setFocus node=email`. A field's
value follows 2.1 (a bare word, a number, a quoted string, braces for an expression, JSON for a list or map).
An action written as JSON still reads; the printer never writes one where this form says it.

### 2.4 What is not a node

- **Variables.** `state name=value` with the type read from the value, as now; a type the value does not say
  is `state name:type=value` … to be settled by the document family (section 4) from what the corpus holds.
- **Media rules.** A line's value at another width, in the notation's words, not a patch in JSON. The media
  family settles the form from the 41 paths the corpus uses (`hide=`/`show=` stay as they are).
- **A list, a condition.** `each x in list` and `if`/`else` already parse; the printer writes them from
  `bind.data` and from `visible` bindings shared by siblings.
- **A component.** A design system's component document (`widget`, `previews`) prints as a `define` (design
  20) where a definition can say it, and otherwise as a `component Name(params)` head with its tree under it.
- **Overlays and more canvases.** `Dialog#id`, `Sheet#id`, `Menu#id` blocks, and one block per canvas.

### 2.5 The printer

`printNotation` stays exact by construction: it writes words, parses them back, and whatever differs goes in
the tail. So a printer word can never corrupt a document; a wrong word only fails to shrink the tail. The
printer writes, for each field of a node that differs from what the parser would give that line with nothing
written: the notation's short word when there is one, else the field's own name (2.1), else its full path. It
writes nothing for a value the parser already gives.

The printer is split by family so the work does not collide:

| File | Holds |
|---|---|
| `print.dart` | The walk: state lines, `each`/`if`/`else`, overlays, canvases, components, ids. |
| `print_fields.dart` | A node's line: type, text, props, style, layout, decoration, node fields, bindings. |
| `print_events.dart` | Events and actions. |
| `print_media.dart` | Media rules. |
| `print_paint.dart` | Custom paint, animations, charts. |

## 3. Done

For the corpus of section 1 and for a generated document that sets every catalog field once:

- no document prints whole as data;
- no node line has a tail, and there is no `document {…}` line, other than for a field the catalog marks as
  opaque data (a script's source, an embedded document);
- every catalog node type, prop, layout field, decoration field, behavior, trigger and action has a test that
  writes it in the notation, expands it, prints it and gets the same line back;
- an unknown key or action is said, in both vocabularies.

## 4. Families

Each family owns its part of the parser and its printer file, measures itself with
`tool/notation_coverage.dart` before and after, and adds its tests to a file of its own under `test/notation/`.

| Family | Parser | Printer |
|---|---|---|
| Keys | 2.1: catalog resolution, dotted paths, binding any key, the unknown-key issue | none |
| Fields | none (reports what the parser cannot read back) | `print_fields.dart` |
| Events and actions | 2.2, 2.3 | `print_events.dart` |
| Media | 2.4 media rules | `print_media.dart` |
| Document | typed variables, component heads, canvases | `print.dart` |
| Paint, motion, charts | words for custom paint ops, animations, chart options | `print_paint.dart` |

### 4.6 Paint, motion and charts: the forms

Settled 2026-11-17 by that family. Custom paint and animations are ordered lists of records, so they are lines:
each record one line, in the grammar's own shape (`word[#id] ["text"] key=value … [{…}]`), indented under the
line that holds it. The parser reads these lines before any other reading of a line (an alias, a defined word,
a node type), so an op named `text`, `path` or `image` is never a node.

**Custom paint.** A `customPaint` line indented under the node that paints carries the behavior's own fields
(`viewBox`, `fit`, `isComplex`, `willChange`; a true boolean is its bare word). The lines under it are the
`painter`'s ops, in order, one op a line; a `foregroundPainter` line under it holds the ops drawn over the
content, under it again. An op line is:

- the op's API name (`path`, `line`, `rect`, `rrect`, `circle`, `oval`, `arc`, `points`, `paragraph`, `image`,
  `group`, `repeat`: `DrawOpSpecs`), `#id` for its `id`;
- a quoted string first: a `paragraph`'s `text`, an `image`'s `url`;
- its fields by their own names (`DrawOpSpecs`' fields and `id`, `when`, `paint`, `hit`): `c=[12,12]`,
  `radius=4`, `d="M0 0 L10 10"`, `when={item != 0}`;
- its paint in two words: `fill=<color>` paints the shape, `stroke=<color>` strokes it, with the stroke's own
  fields beside it by Flutter's names (`strokeWidth`, `strokeCap`, `strokeJoin`, `strokeMiterLimit`,
  `dashPattern`, `scaleStroke`). `fill` alone is the paint as written (`fill=#FF22C55E` is `"paint": "#FF22C55E"`,
  as the API writes a paint that is a color; `fill={pal[item]}` a paint worked out), `stroke` alone a stroking
  paint, both the two paints in that order. `paint=` (the field's own name) is what they cannot say: a paint
  object with a shader or a blend mode, paints in another order;
- a `group`'s and a `repeat`'s `ops` are the lines under it;
- a `{…}` tail at its end, merged into the op, as on a node's line.

A value is written as on a node's line (2.1): a number, a bare word (an enum's name, a color, a theme color's
name), a quoted string (`{name}` in it reads the state; `${…}` written in it stays as written), `{expression}`
(`${name}` for a name, `${= …}` otherwise), JSON for a map, and a list as JSON or with expressions among its
numbers (`c=[{60 + index * 34},48]`). An op the API does not have, a key its op does not take and a line under an
op that takes none are said (a closed vocabulary): the op is kept as written.

From the corpus (tool/reference/examples/paint_illustration.json; CodelesslySDK examples/prompt_app/polish/bar/
home.json, `top_mark`; examples/showcase/desktop/native/site_landing.json, `hero_figure_hero_adult`):

```
box#scene w=fill h=212
  customPaint viewBox=[320,200] fit=cover
    rect rect=[0,0,320,200] fill=#FFE8F1F8
    circle c=[236,62] radius=28 fill=#FFF4B740
    repeat count=3
      circle c=[{60 + index * 34},{48 + index * 6}] radius=3 fill=#FF5D6D7E
    path d="M0 150 C60 100 120 110 170 140 C220 170 270 120 320 130 L320 200 L0 200 Z" fill=#FF7FB685
    line p1=[40,196] p2=[280,196] stroke=#33FFFFFF strokeWidth=2

box#top_mark w=30 h=30
  customPaint viewBox=[28,28]
    rrect rect=[0,0,28,28] radius=9 fill={{'shader': {'type': 'linear', 'begin': 'topLeft', 'end': 'bottomRight', 'stops': [{'position': 0, 'color': theme.colors.brandBright}, {'position': 1, 'color': theme.colors.brand}]}}}
    path d="M7 17 C 7 5, 21 5, 21 17" stroke={theme.colors.accent} strokeWidth=2.6 strokeCap=round strokeJoin=round
    circle c=[14,18.5] radius=2.6 fill={theme.colors.onBrand}

box#hero_figure_hero_adult
  customPaint viewBox=[240,240] fit=contain
    group opacity=0.55
      path d="M48 122 C 18 176, 66 232, 120 232 C 174 232, 222 176, 192 122" stroke={theme.colors.artRope} strokeWidth=3 strokeCap=round strokeJoin=round dashPattern=[1,9]
    oval rect=[80,220,80,10] fill={theme.colors.artShadow}
```

And the guide's dial (docs/guide/07-custom-paint.md), with a foreground painter:

```
box w=200 h=200
  customPaint viewBox=[200,200]
    circle c=[100,100] radius=96 fill=#FF1C2833 stroke=#FF5D6D7E strokeWidth=3
    repeat count={ticks}
      group translate=[100,100] rotate={radians(index * 360 / count)}
        line p1=[0,-90] p2=[0,{index % 5 == 0 ? -76 : -84}] stroke=#FFE8ECEE strokeWidth={index % 5 == 0 ? 3 : 1.5} strokeCap=round
    foregroundPainter
      group#needle translate=[100,100] rotate={radians(value * 6)}
        line p1=[0,14] p2=[0,-80] stroke=#FFE74C3C strokeWidth=3 strokeCap=round
```

**Animations.** `animate=<word> duration=… delay=…` stays the way to write an animation one of its words
stands for, and the printer writes it for a node whose `animations` are exactly that (`id` `a`). Every other
animation is an `animation#<id>` line indented under its node, with `NodeAnimation`'s fields by their own names
(`duration`, `delay`, `curve`, `repeat`, `autoplay`, `preset`, `params`, `spring`, `progress`, …), and its
tracks the `track[#id]` lines under it with `AnimationTrack`'s fields by theirs (`path`, `node`, `variable`,
`from`, `to`, `keyframes`, `wave`, `interval`, `curve`, `blend`, `interpolation`). Values as above
(`repeat={"reverse": true}`, `from={start}`). The animations are in the order their lines are written, after
the one `animate=` gives. From CodelesslySDK examples/prompt_app/polish/bar/home.json:

```
Column#top gap=16
  animation#enter duration=520 delay=0 curve=easeOutCubic
    track path=opacity from=0 to=1
    track path=motion.translateY from=14 to=0
```

**Charts.** A chart's fields are props, read and written by their own names (2.1): lists of records
(`series`, `referenceLines`, `zones`, `markers`, `yLines`, `xLabels`) as JSON. What the notation says shorter
is printed so: a `lineChart` whose `data` are the points `values=[…]` gives (`{"x": i, "y": v}` under `xField`
`x` and `yField` `y`) prints as `values=[…]`; a donut the `Donut` word made prints as `Donut values=[…]
labels=[…] colors=[…]`.

## 5. What does not change

The prompt teaches the grammar and the core (design 19). Parity is what the parser reads and the printer
writes; it is not a longer prompt. A key the catalog has is read whether or not the prompt names it, and the
reference page of its type is where a writer finds it.
