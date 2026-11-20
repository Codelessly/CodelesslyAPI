# Decoration

Fills, gradients, borders, corners, shadows, blurs, clipping and pictures. Open it when a box needs more than
`fill`, `border` and `radius`.

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

Shadows and blurs are `effects=[…]` ([Effect](@type-Effect)); `clip=true` clips the content to the corners.

```notation
Column w=120 h=80 fill=#FFFFFFFF effects=[{"type":"dropShadow","color":"#33000000","offset":[0,4],"blurRadius":16}]
```

## Pictures and icons

`Image "url"` is a picture (an image fill on a box; `Image url="…"` and `url={…}` the same); `Icon "name"` a Material
icon.

```notation
Row gap=8
  Image "https://example.com/a.png" w=120 h=80 radius=8
  Icon "star" size=24 color=#FFF59E0B
```

Drawing your own shapes is [paint.md](paint.md).

## Keys every decorated line takes

A line takes these where its word is decorated (a Column, Row, Stack, box, Card…); elsewhere only `effects`. The
short words: `fill`, `gradient`, `border`, `radius`.

{{decorationKeys}}

{{reference}}

{{examples}}
