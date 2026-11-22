# Custom paint

Drawing with paths, shapes, text and images on a node's canvas: a `customPaint` line and its op lines. Open it
when a UI needs an illustration, a chart of its own, a dial or any shape the boxes cannot make.

## The lines

A `customPaint` line under the node that paints carries the painter's own keys; each line under it is one draw op,
in order, over the node's own fill and border and under its children; a `foregroundPainter` line (under the
`customPaint` line, or under the node beside it) holds the ops drawn over the children too. A rectangle with round
corners is `rrect rect=[left,top,width,height] radius=4` (not `rect x= y= w= h=`); every `rect=` (a `rect`'s, an
`oval`'s, an `arc`'s) is its left, top, width and height, never its right and bottom: `rect=[0,100,240,60]` starts
100 down and is 60 high. A point is one key too (`c=[x,y]`, not `cx=` and `cy=`). A shape's opacity is its
colour's alpha (`fill=#80FF0000`). An op line is the op's name, a
quoted string first where it has one (a `paragraph`'s text, an `image`'s URL), and its fields by their own names.
Its paint is `fill=<color>` (fills the shape) and `stroke=<color>` with the stroke's keys beside it
(`strokeWidth`, `strokeCap`, `strokeJoin`, `dashPattern`); `paint={…}` for a paint they cannot say. A field of a record
field is its dotted path, as on a node's line: `paragraph "Q3" style.fontSize=11 style.color=#FF6B7280`. A `group` or
a `repeat` holds the op lines under it; inside a `repeat`, `index` and `item` are the copy's.

```notation
box w=200 h=120
  customPaint viewBox=[200,120]
    rect rect=[0,0,200,120] fill=#FFE8F1F8
    circle c=[100,60] radius=28 fill=#FFF4B740
    line p1=[0,110] p2=[200,110] stroke=#FF5D6D7E strokeWidth=2
```

`paint=[…]` is the op's list of paints, each drawing the shape once, in order: `color`, `style` (`fill` or
`stroke`), `strokeWidth`, `strokeCap`, `strokeJoin`, `dashPattern`, `blendMode`, and `shader`, a gradient or an
image ([Paint](decoration.md#type-Paint)) laid over the shape's bounds in place of `color`: a stroke in a gradient.

```notation
box w=40 h=40
  customPaint viewBox=[40,40]
    path d="M4 36 L36 4" paint=[{"style":"stroke","strokeWidth":4,"strokeCap":"round","shader":{"type":"linear","stops":[{"position":0,"color":"#FF2563EB"},{"position":1,"color":"#FFDB2777"}]}}]
```

A value is a number, a word, a quoted string, JSON, or `{expression}`; a list may hold expressions among its
numbers: `c=[{60 + index * 34},48]`.

A chart of your own, drawn from the state: a `repeat` over the data, each copy a bar and its label placed by
`index`. The `viewBox` is the drawing's own units; `fit=fill` stretches it to the box.

```notation
state sales=[40,72,55,90,64]
box h=160
  customPaint viewBox=[250,120] fit=fill
    line p1=[0,119] p2=[250,119] stroke=#FFD1D5DB strokeWidth=1
    repeat count={length(sales)}
      rrect rect=[{index * 50 + 10},{120 - sales[index]},30,{sales[index]}] radius=4 fill={index == length(sales) - 1 ? '#FF2563EB' : '#FF93C5FD'}
      paragraph "{sales[index]}" offset=[{index * 50 + 10},{104 - sales[index]}] maxWidth=30 textAlign=center
```

For a bar, line or donut chart with axes and a legend, the chart words (`BarChart`, `LineChart`, `Donut`) on
[charts.md](charts.md) are shorter.

## Conditions and lists in a drawing

`if`, `else if`, `else` and `each` are written among a drawing's lines as on a page, with the op lines they hold
indented under them. The shapes under an `if kind=="pie"` are drawn while the condition holds (it is a `group` with
that `when`); those under `each b in bars` are drawn once for each item of the list, which they read by its name
(`rect=[{index*10},0,6,{b.v}]`), with `index` its position from 0.

`repeat count=50` draws its lines 50 times: in them `index` is the position (from 0) and `item` the same number;
`indexAs=i` names the position `i` (`as=` names the item). A repeat whose lines read neither draws the same shapes
every time, which is said on its line with the names they read that nothing declares. A drawing under an `each` of
the page reads that each's item by its name under a `repeat` too.

A drawing is as big as the line it is under: its size is written on that line (`Box w=240 h=160`, the `customPaint`
under it), never on the `customPaint` line, whose `viewBox` and `fit` say how its units map onto that box.

## Glows, soft shadows and gradients in a drawing

`blurRadius=` beside `fill=` or `stroke=` softens the shape's edge (Flutter's `MaskFilter.blur`, the same softness as
an effect's `blurRadius` on a box): a glow behind a sun, a soft shadow under a drawn card, a feathered blob. It is in
the drawing's units and scales with it. A paint a colour cannot say is `paint={…}`: a gradient laid out in the
shape's bounds is its `shader` (a [Paint](decoration.md#type-Paint), with an `angle` as on a box).

```notation
box w=200 h=120 fill=#FF111827 radius=12
  customPaint viewBox=[200,120]
    circle c=[100,60] radius=34 fill=#B3F59E0B blurRadius=28
    circle c=[100,60] radius=16 fill=#FFFDE68A
    rrect rect=[24,92,152,10] radius=5 fill=#66000000 blurRadius=8
```

## The painter's keys

{{customPaintFields}}

## The ops

Every op also takes these:

{{drawOpCommonFields}}

{{drawOps}}

{{reference}}

{{examples}}
