# Controls and forms

Buttons, inputs, toggles, choices, pickers, chips, and forms that validate. Open it when a UI takes input, or a
control needs a key beyond its text and `bind`.

## A control and its value

`bind=name` keeps a control's value in a variable, both ways; declare it with `state`. `onChange={…}` runs when
the value changes (`result` is the new value). `enabled={…}` turns a control off.

```notation
state email=""
state agree=false
Column gap=12
  Input "Email" keyboardType=emailAddress bind=email
  Checkbox "I agree" bind=agree
  Button "Send" enabled={agree} onTap={emit send}
```

```notation
state size="M"
state volume=0
Column gap=12
  Select items=["S","M","L"] bind=size
  Slider min=0 max=100 bind=volume
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
  CodeInput "Code" bind=code length=6 digits
  Slider bind=low bindEnd=high min=0 max=100
  SegmentedButton bind=plan items=["month","year"]
```

## Validation

A column with `form` holds fields that check themselves: an Input's `validator={…}` gives the message (empty when
the value is good), and the `validate` action checks every field of the form; `result` says whether all passed.

```notation expands
state email=""
Column#signup gap=12 form=true
  Input "Email" validator={email == "" ? "Required" : ""} bind=email
  Button "Send" onTap={validate node=signup}
```

{{reference}}

{{examples}}
