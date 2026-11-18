# Custom paint

Drawing with paths, shapes, text and images on a node's canvas: a `customPaint` line and its op lines. Open it
when a UI needs an illustration, a chart of its own, a dial or any shape the boxes cannot make.

## The lines

A `customPaint` line under the node that paints carries the painter's own keys; each line under it is one draw op,
in order, over the node's own fill and border and under its children; a `foregroundPainter` line (under the
`customPaint` line, or under the node beside it) holds the ops drawn over the children too. A rectangle with round
corners is `rrect rect=[left,top,width,height] radius=4` (not `rect x= y= w= h=`); a shape's opacity is its
colour's alpha (`fill=#80FF0000`). An op line is the op's name, a
quoted string first where it has one (a `paragraph`'s text, an `image`'s URL), and its fields by their own names.
Its paint is `fill=<color>` (fills the shape) and `stroke=<color>` with the stroke's keys beside it
(`strokeWidth`, `strokeCap`, `strokeJoin`, `dashPattern`); `paint={…}` for a paint they cannot say. A `group` or
a `repeat` holds the op lines under it; inside a `repeat`, `index` and `item` are the copy's.

```notation
box w=200 h=120
  customPaint viewBox=[200,120]
    rect rect=[0,0,200,120] fill=#FFE8F1F8
    circle c=[100,60] radius=28 fill=#FFF4B740
    line p1=[0,110] p2=[200,110] stroke=#FF5D6D7E strokeWidth=2
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

## The painter's keys

{{customPaintFields}}

## The ops

Every op also takes these:

{{drawOpCommonFields}}

{{drawOps}}

{{reference}}

{{examples}}
