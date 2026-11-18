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

A column with `form` holds fields that check themselves: an Input's `validator={…}` gives the message (empty when
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
