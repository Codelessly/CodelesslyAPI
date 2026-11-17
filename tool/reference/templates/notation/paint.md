# Custom paint

Drawing with paths, shapes, text and images on a node's canvas: a `customPaint` line and its op lines. Open it
when a UI needs an illustration, a chart of its own, a dial or any shape the boxes cannot make.

## The lines

A `customPaint` line under the node that paints carries the painter's own keys; each line under it is one draw op,
in order; a `foregroundPainter` line under it holds the ops drawn over the content. An op line is the op's name, a
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

## The painter's keys

{{customPaintFields}}

## The ops

Every op also takes these:

{{drawOpCommonFields}}

{{drawOps}}

{{reference}}

{{examples}}
