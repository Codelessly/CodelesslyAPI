# Controls and forms

Buttons, inputs, toggles, choices, pickers, chips, and forms that validate. Open it when a UI takes input, or a
control needs a key beyond its text and its `@name`.

## A control and its value

`@name` keeps a control's value in a variable, both ways; declare it with `state`. `onChange={…}` runs when
the value changes (`result` is the new value). `enabled={…}` turns a control off.

```notation
state email=""
state agree=false
Column gap=12
  Input "Email" @email keyboardType=emailAddress
  Checkbox "I agree" @agree
  Button "Send" enabled={agree} onTap={emit send}
```

```notation
state size="M"
state volume=0
Column gap=12
  Select @size items=["S","M","L"]
  Slider @volume min=0 max=100
```

Words a writer reaches for, and what they read as:

- `RangeSlider @low end=@high min=0 max=90` is `Slider @low @high min=0 max=90`, a slider with two thumbs.
- `semanticLabel="Wi-Fi"` on a Toggle, Checkbox, Radio or Slider is the name a screen reader says, not shown (a
  `label` is drawn beside it). A Toggle, Checkbox or Radio in a Row that already shows its string as a text (a
  settings row: `Text "Single sign-on"` … `Toggle "Single sign-on"`) keeps the string as that spoken name and
  draws no second label.
- An `Input type=number` with no width in a Row is 96 wide (a stepper's field between its buttons); a field for
  words is 240.
- A field's label goes above it. Where it has no room there (beside buttons or chips in a row, in a row of a set
  height under 56) the label is its hint; `label="…"` by name keeps it above.
- `Button "Donate" h=44 radius=22` and `IconButton "play_arrow" radius=20`: `radius` is the corners of a
  button's shape. `fill=` on a Button or an IconButton is its own ground (its label reads on it unless the
  line gives `color=`).
- `Input "Search" prefixIcon="search"` is `icon="search"`: the icon inside the field.

```notation expands
state code=""
state low=20
state high=80
state plan="month"
Column gap=12
  Input "Password" password
  Input "Note" multiline
  CodeInput "Code" @code length=6 digits
  Slider @low @high min=0 max=100
  SegmentedButton @plan items=["month","year"]
```

## Tabs, segments and chips chosen from

What is chosen among a few takes the theme's accent with nothing styled, on a white page as on a cream one, in dark
as in light: a `TabBar`'s or `Tabs`' chosen label and its line are the accent (the ink where the accent does not
read on the page); a `SegmentedButton`'s chosen segment and a chosen `ChoiceChip` or `FilterChip` are filled with
the accent, their label in its ink (`onPrimary`). What is not chosen is a tint of the theme's ink over what it sits
on, never a fixed grey. Chips and segments are rounded rectangles (the theme's control radius, at every width), not
pills, and a chosen chip shows no check mark unless the line writes `showCheckmark=true`. A row of chips is the word
for filters and for tabs across a page: write `ChoiceChip "All stories" selected={section=="All"} onTap={…}` and do
not style it. The line's own colors (`selectedColor=`, `backgroundColor=`, the label's `labelStyle.color=`) and `shape=` win.

## A number with its buttons

`NumberInput @seats min=1 max=500` is a number field with a minus button before the number and a plus button after
it, all inside the field's one border, a rule between each part: a press steps the number by `step=` (1) within
`min=` and `max=`, and a button at its bound is drawn disabled and takes no press. Focused, Up and Down step it too,
Page Up and Page Down ten steps, Home and End go to the bounds. It is as high as the other inputs (a fixed `h=`
picks another step of the control scale) and 112 wide unless it says. `Input … keyboardType=number steppers=true`
is the same field; a design system's own `NumberInput` comes first.

```notation expands
state seats=48
Row gap=12
  NumberInput @seats min=45 max=500 semanticLabel="Seats"
  Text "{seats} seats"
```

A field of your own between two buttons looks whole when the border is the Row's: `Row border=… radius=6
clip=antiAlias` around `IconButton "remove" border-right=…`, `Input … decoration.border.type=none` and
`IconButton "add" border-left=…`. A box's border is drawn over what it holds, so the field's fill never covers it.

## Validation

A column with `form=true` holds fields that check themselves: an Input's `validator={…}` gives the message (empty when
the value is good), and the `validate` action checks every field of the form; `result` says whether all passed.

```notation expands
state email=""
Column#signup gap=12 form=true
  Input "Email" @email validator={email == "" ? "Required" : ""}
  Button "Send" onTap={validate node=signup}
```

A whole form: each field's rule, the messages shown once a field is left (`form.autovalidateMode=onUnfocus`, a
key of the form's record), a count of what is wrong read from `form.errors` (each error's `label` and `message`),
and a send that goes on only when every field passes (`result ? … : …`).

```notation
state name=""
state email=""
state sent=false
Column#signup gap=12 form.autovalidateMode=onUnfocus
  Input "Name" @name validator={trim(name) == '' ? 'Enter your name.' : ''}
  Input "Email" @email validator={matches(email, '^[^@ ]+@[^@ ]+$') ? '' : 'Enter an email like name@example.com.'} keyboardType=emailAddress
  Text "{length(form.errors)} fields need attention" color=#FFDC2626 visible={length(form.errors) > 0}
  Button "Send" onTap={validate node=signup; result ? sent=true : toast "Check the form"}
  Text "Thanks, {name}!" visible={sent}
```

{{reference}}

{{examples}}
