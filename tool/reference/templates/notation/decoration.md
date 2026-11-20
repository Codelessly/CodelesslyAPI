# Decoration

Fills, gradients, borders, corners, shadows, blurs, clipping and pictures. Open it when a box needs more than
`fill`, `border` and `radius`: a shadow, a gradient, a picture placed in its box.

## Fills, borders and corners

`fill` is one color; `gradient=["#FF2563EB","#FF7C3AED"]` a linear gradient with even stops; `fills=[…]` any list
of paints ([Paint](@type-Paint): colors, gradients, images, noise). `border` is a hairline, `strokeWidth` its
width, `border-bottom` one side (bound too: `border-bottom={active ? accent : transparent}`); `radius` one number or `[topLeft,topRight,bottomRight,bottomLeft]`.

```notation
Column gap=8
  Column w=120 h=80 gradient=["#FF2563EB","#FF7C3AED"]
  Column w=120 h=80 border=#FFE5E7EB strokeWidth=2 radius=12
  Column w=48 h=48 fill=#FF2563EB shape=circle
```

A gradient worked out from data is the list of its colors in braces, each color an expression:
`gradient={[m.c1, m.c2]}` (an avatar's two colors from its record), `gradient={[hot ? #FFFF6F61 : #FF4F8EF7,
#FF8B6CFA]}`.

```notation
state people=[{"c1":"#FFFF9A6C","c2":"#FFE5484D"},{"c1":"#FF6EC1FF","c2":"#FF4F8EF7"}]
Row gap=8
  each item in people
    box w=40 h=40 gradient={[item.c1, item.c2]} shape=circle
```

Shadows and blurs are `effects=[…]` ([Effect](@type-Effect)); `clip=true` clips the content to the corners. A
shadow is written only so: there is no `shadow=` or `shadows=` key. Its numbers are pixels: `offset` `[x, y]`,
`blurRadius`, `spreadRadius` (CSS `box-shadow: 0 4px 16px` is `"offset":[0,4],"blurRadius":16`).

```notation
Column w=120 h=80 fill=#FFFFFFFF effects=[{"type":"dropShadow","color":"#33000000","offset":[0,4],"blurRadius":16}]
```

## Pictures and icons

`Image "url"` is a picture (an image fill on a box; `Image url="…"` and `url={…}` the same; a path is read from
the document's folder, in a site the site's: `Image "assets/card.png"`); `fit=` is how it fills its box (`cover`, `contain`…). Its paint's other
fields ([ImagePaint](@type-ImagePaint): `alignment`, `tint`, `repeat`) are written on a box's fill:
`box w=fill h=180 fills=[{"image":{"url":"…","fit":"cover","alignment":"topCenter"}}]`. `Icon "name"` is a
Material icon.

```notation
Row gap=8
  Image "https://example.com/a.png" w=120 h=80 radius=8
  Icon "star" size=24 color=#FFF59E0B
```

```notation
box w=200 h=120 fills=[{"image":{"url":"https://example.com/a.png","fit":"cover","alignment":"topCenter"}}] radius=8
```

Drawing your own shapes is [paint.md](paint.md).

## Pictures that stretch: nine-slice

A picture made to stretch (a chat bubble with its tail, a pill, a framed panel) keeps its corners at their own size
when its middle is named: `centerSlice=[left,top,width,height]`, in the picture's logical pixels (its pixels divided
by `scale`), as Flutter's `centerSlice` and CSS `border-image-slice`. The corners are drawn as they are, the edges
stretch along their side, the middle both ways; a sliced picture fills its box. A bubble drawn at 3x (159×121 pixels,
53×40.3 logical) with its tail under the left corner:

```notation
Row gap=8 bottom
  Image "https://example.com/bubble_left.png" scale=3 centerSlice=[14,12,28,8] w=60 h=46
  Image "https://example.com/bubble_left.png" scale=3 centerSlice=[14,12,28,8] w=220 h=90
```

Behind text, the picture is the box's fill (`"centerSlice"` in its [ImagePaint](@type-ImagePaint)); the padding
keeps the text off the corners and the tail:

```notation
Column pad=[16,12,16,24] w=240 fills=[{"type":"image","image":{"url":"https://example.com/bubble_left.png","fit":"fill","scale":3,"centerSlice":[14,12,28,8]}}]
  Text "Great work. Let us use the same plan for the next practice step tonight."
```

## Cutting a line to a shape

Any line can be cut: a box, a picture, a text, an icon, a control, a list, a component. What it paints and its
children are cut, and a tap in the cut part goes to what is under. The common shapes need no path data:

- rounded corners, each its own: `radius=[24,24,0,0] clip=antiAlias`; a circle: `shape=circle clip=antiAlias`;
- notches and bites that keep their size as the line grows: `clipCuts=[…]`, each a circle (`"radius"`) or SVG path
  data (`"d"`, its origin at the point) in pixels, at a point of the box (`"center"`: an alignment). They are cut
  from the line's own corners (or from `clipPath`).

A ticket at two sizes: its notches stay round 12 px circles. A border is drawn along the cut, inside it, and a shadow
takes its shape:

```notation
Row gap=12 bottom
  Stack w=160 h=80 fill=#FF4F46E5 radius=12 clipCuts=[{"center":"centerLeft","radius":12},{"center":"centerRight","radius":12}]
    Text "Admit one" color=#FFFFFFFF x=24 y=12
  Stack w=200 h=140 fill=#FF4F46E5 border=#FFF59E0B strokeWidth=3 radius=12 effects=[{"type":"dropShadow","color":"#66000000","offset":[0,6],"blurRadius":12}] clipCuts=[{"center":"centerLeft","radius":12},{"center":"centerRight","radius":12}]
    Text "Admit one" color=#FFFFFFFF x=24 y=20
```

A card with a bite out of its top right corner:

```notation
Column pad=16 fill=#FFFFFFFF border=#FFE5E7EB strokeWidth=2 radius=16 clipCuts=[{"center":"topRight","radius":28}]
  Text "A card with a bite out of its corner, its border along the bite."
```

Any other shape is `clipPath="…"`: SVG path data, as CSS `clip-path` and Flutter's `ClipPath`. It is written in the
box's unit square (0 to 1 across and down, stretched over the box: one curve for every width), or in units of your
own with `clipViewBox=[width,height]`, mapped onto the box by `clipFit` as a `customPaint`'s `viewBox` and `fit` are
(`fill` stretches, `contain` keeps the aspect, `none` keeps the units pixels; `clipFit=none` with no view box: the
box's own pixels from its top left). A header whose foot is a wave, over a picture:

```notation
Stack w=390 h=180 fills=[{"type":"image","image":{"url":"https://example.com/sky.png"}}] clipPath="M0 0 H1 V0.78 C0.72 1 0.3 0.6 0 0.86 Z"
  Text.heading2 "Good morning" color=#FFFFFFFF x=24 y=24
```

A text or an icon cut as a box is (a reveal, a half-filled rating star):

```notation
Row gap=16
  Text "Half" size=40 clipPath="M0 0 H0.5 V1 H0 Z"
  Icon "star" clipPath="M0 0 H0.5 V1 H0 Z" size=48 color=#FFF59E0B
```

## Gradients at an angle

A linear paint's `angle` is CSS's `linear-gradient(103deg, …)`: 0 runs up, 90 to the right, 180 down. Its line
crosses the middle and reaches the far corners, so the gradient keeps its direction on the screen when the box
changes shape (a banner that grows as its text wraps). A border is painted with paints too: `strokes=[…]` takes a
gradient as `fills` does.

```notation
Column pad=16 fills=[{"type":"linear","angle":103,"stops":[{"position":0,"color":"#FF4F46E5"},{"position":1,"color":"#FF06B6D4"}]}] strokes=[{"type":"linear","angle":90,"stops":[{"position":0,"color":"#FFFFFFFF"},{"position":1,"color":"#33FFFFFF"}]}] strokeWidth=2 radius=12
  Text "New: plan your week" color=#FFFFFFFF
```

## Soft glows

A blurred shape is a box with a `layerBlur` effect (a glowing orb behind a card, a soft spot of colour); inside a
drawing, an op's `blurRadius` ([paint.md](paint.md)).

```notation
Stack w=200 h=160
  box w=120 h=120 x=40 y=20 fill=#99F59E0B effects=[{"type":"layerBlur","blurRadius":40}] shape=circle
```

## Keys every decorated line takes

A line takes these where its word is decorated (a Column, Row, Stack, box, Card…); elsewhere only `effects`. The
short words: `fill`, `gradient`, `border`, `radius`.

{{decorationKeys}}

{{reference}}

{{examples}}
