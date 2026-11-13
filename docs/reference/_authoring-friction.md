# Authoring friction

Found while writing the guide's examples and a two-page responsive site (`examples/reference-site` in the SDK
repository) as JSON, with only the generated reference and the render command. Each item is a property of the API
or the SDK as they are, not of the reference; the reference states each one, and validation or the render
command reports most of them. Nothing here was changed in the API.

## Silent defaults that make things disappear

1. **A text without `style.color` is painted white.** `{"type": "text", "props": {"text": "Hi"}}` on a white page
   shows nothing. The base text style (`kTextBase` in the SDK) has no color and the engine's default is white. The
   render command reports `text_no_color`; validation cannot (the color may come from a binding).
2. **A node without `layout.width` / `layout.height` is fixed at 0 × 0.** `Layout` defaults to `AxisSize.fixed(0)`,
   so `{"type": "box", "decoration": {"fills": [{"color": "#FFFF0000"}]}}` draws nothing. Validation warns
   (`zero_size`). A default of `hug` would make most hand-written nodes right.
3. **An effect without `type` is dropped**, although `EffectFields.type` declares a default (`dropShadow`):
   `{"blurRadius": 16, "offset": [0, 4]}` is no shadow at all (`Effect.fromJson` returns null without a type).
   Validation reports it (`wrong_type`, "it needs \"type\"").
4. **`padding: [16, 8]` becomes 0 on every side.** `EdgeInsets.fromJson` reads a number or four numbers; a list of
   two is the zero fallback. A binding of `layout.padding` does read `[h, v]` (`BindValue.insets`), so the same
   value works in `bind` and silently fails in `layout`. Validation reports it.

## Names and numbers that suggest the wrong thing

5. **`{"fill": 760}` is not "fill, up to 760".** The number of `fill` and `hug` is only a fallback; a fill takes
   all the room. I wrote `{"fill": 760}` for the FAQ list and got a 1300 px list; the fix is
   `"constraints": {"maxWidth": 760}`. The guide says so twice now.
6. **Rows and columns center their children across by default** (`crossAxisAlignment: center`, Flutter's
   default). Nearly every block of a web page is start-aligned, so nearly every column needs
   `"crossAxisAlignment": "start"`.
7. **`{"start": a, "end": b}` in a stack stretches the node, unless its width hugs**: a hugging text keeps its own
   width and sits at `start`. Nothing reports it.
8. **`layout.align` makes the node's box span its slot** (its content is aligned inside). A text with
   `"align": [1, 0]` reports a 380 px box in a layout dump, though its glyphs are 70 px wide.
9. **`${screen.width}` prints `390.0`**, `${= screen.width}` prints `390`: a path is printed with Dart's
   `toString`, a formula with the formula printer.
10. **Two layers of escaping in formulas.** A formula's regular expression needs `\.` for a literal dot; in JSON
    that is written `"\\."`. I wrote `"\\\\."` (thinking of the formula's own string escapes), the formula saw
    `\\.` and the email check never passed; nothing reports it. I used `[.]` instead.

## Declared but not (fully) implemented

11. **`textField.validator` is declared and documented ("`{"type": "none"|"email"|"required"|...}`") but the SDK
    never reads it.** Forms have to be validated with variables and `visible` bindings (as the guide shows).
12. **`textField.inputFormatter` documents `{"type": "none"|"email"|"phone"|...}`** but the SDK only applies
    `{"type": "regex", "pattern": ...}`.
13. **Fields decoded but not declared**: `layout.widthFactor` / `heightFactor`, a paint's `begin` / `end` (a linear
    gradient's direction) and an image paint's settings written beside `image`. The generated tables cannot list
    them; the guide mentions `begin`/`end` in prose. `EffectFields.shape` is declared but left out of
    `EffectFields.all`.

## Structure

14. **A canvas per breakpoint duplicates the whole page.** The site's home page has three canvases (mobile, tablet,
    desktop) with separate node trees: `home.json` is 150 KB, and every change is made three times. A `variance`
    per section is the alternative, but variants list children by id, so the duplication moves into the variants.
    There is no way to share a node between canvases.
15. **Navigation names a canvas, not a screen.** To go "home" from the contact page I had to pick one of the home
    screen's three canvas ids (`m-home`); the canvas shown is still the one for the width, but the id reads as
    "the mobile one".
16. **Buttons are awkward to size and style.** A Material button's label is 12 px unless
    `style.textStyle.fontSize` is set, and a hugging button is only as wide as its label (no padding: 48 px for
    "Hug"). The site uses rows with a fill, padding, a text and `states` instead.
17. **A text field shows its own text, not its variable.** Setting `email` (an action, or `--set`) does not change
    the field: the field reports into the variable through `changed`, but nothing flows back.
18. **Equal declarations are one object.** `PropDef('color', Codecs.optionalColor, null)` declared in two classes
    is one const, so a tool cannot tell which class's comment belongs to which widget. The generator only uses a
    comment from the class it is documenting (or the only declaration); the first draft of the reference gave the
    icon's `color` the divider's description.

## Render command limits met

19. **Icons whose name comes from a binding draw nothing offline.** `bind: {"props.icon": "${= open ? 'close' :
    'menu'}"}` needs the icon's SVG from the network. The site uses two icons with `visible` bindings.
20. **Toasts, Material labels and text without a family are drawn in Roboto** (the test environment has no
    platform font); an app on iOS draws them in SF.
