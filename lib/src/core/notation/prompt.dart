// What an agent is told to write the compact notation: the grammar, the
// types of levels 0 and 1 by the name to write, and three examples. Built
// from the catalog and the notation's own tables, so it cannot name a type
// or a variant that does not parse.
import '../catalog.dart';
import '../levels.dart';
import 'notation.dart';

/// The prompt for the notation over [catalog] (its level 0 and 1 types).
String notationPrompt({Catalog? catalog, NotationOptions options = const NotationOptions()}) {
  final c = catalog ?? Catalog.current;
  final short = {
    for (final e in notationTypes.entries)
      if (e.key != 'Card' && e.key != 'Image') e.value.type: e.key,
  };
  String written(String type) => short[type] ?? '${type[0].toUpperCase()}${type.substring(1)}';
  List<String> ofLevel(Level l) => [
        for (final w in c.widgets)
          if (widgetLevels[w.type] == l && w.type != 'canvas' && !const {'placeholder', 'singlePlaceholder', 'flex'}.contains(w.type))
            written(w.type),
      ];
  final layout = [...ofLevel(Level.core), 'Card', 'Image'];
  final controls = ofLevel(Level.widgets).where((t) => !t.endsWith('Button') || t == 'Button' || t == 'IconButton' || t == 'SegmentedButton').toList();
  return '''
You describe a UI by writing it in this notation, one node per line, children indented two spaces under their parent. Write only the notation: no JSON, no prose, no code fence.

LINE
  Type[.variant][#id] ["text"] [key:value ...] [=binding] [-> action; action]

- "text" is the node's main string: a Text's text, a Button's or Toggle's label, an Input's label (a second string is its hint), an Icon's name, an Image's URL. {name} inside a string shows a variable: "Total: {total}".
- key:value sets a prop by its name. Common keys: gap (space between children), pad (padding: one number or [left,top,right,bottom]), w, h (a number, fill or hug), fill (background colour #AARRGGBB), radius. Quote a value with spaces: hint:"you@example.com". Lists are JSON: items:["S","M","L"].
- Words on a Row or Column: start, center, end, between (along it); top, middle, bottom, left, right, stretch (across it). grow on a child takes the remaining room. hidden hides a node.
- =name binds a control's value to a variable both ways (the variable is created for you): Slider =volume, Toggle "Wi-Fi" =wifi, Input "Email" =email, Select =size items:["S","M","L"]. On other keys write key:=expression with no spaces: visible:=count>0.
- -> runs on tap (on change, for a control): name=value sets a variable; emit eventName tells the app; toast "Saved"; link https://…; open id / close for a modal. Separate several with ;
- state name=value on its own line (top level) declares a variable with a starting value.
- if expression on its own line shows the lines indented under it only while it holds.
- #id only when something else needs to name the node.
- Sizes are worked out: in a Column a child is as wide as the column and as tall as its content; in a Row a child is as big as its content. Do not write sizes unless the design needs one.

TYPES
  Layout and content: ${layout.join(', ')}
  Controls: ${controls.join(', ')}
  Text variants: ${options.textStyles.keys.map((k) => 'Text.$k').join(', ')} (plain Text is body text)
  Button variants: ${buttonVariants.keys.map((k) => 'Button.$k').join(', ')} (plain Button is primary)
  Card is a padded, bordered Column. Every control already has the design system's look: write no colours or sizes on controls.

EXAMPLES
Column gap:12 pad:16
  Slider =volume min:0 max:100
  Input "Email" "you@example.com" =email
  Toggle "Notifications" =notify
  Button "Save" -> emit save

state qty=1
Card gap:12
  Row between
    Text.heading "Espresso beans, 1 kg"
    Text.strong "\\\$24"
  Row gap:8
    Button.outline "-" -> qty=max(1,qty-1)
    Text.strong "{qty}"
    Button.outline "+" -> qty=qty+1
    Spacer grow
    Button "Add to cart" -> emit add; toast "Added"

state choice=""
Card gap:8
  Text.title "How was your stay?"
  Row gap:8
    ChoiceChip "Great" -> choice="great"
    ChoiceChip "Okay" -> choice="okay"
    ChoiceChip "Poor" -> choice="poor"
  if choice!=""
    Text.muted "Thanks, you chose {choice}."
''';
}
