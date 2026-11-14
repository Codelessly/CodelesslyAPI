// What an agent is told to write the compact notation: the grammar, the
// types of levels 0 and 1 by the name to write, and three examples. Built
// from the catalog and the notation's own tables, so it cannot name a type
// or a variant that does not parse.
import '../catalog.dart';
import '../levels.dart';
import 'notation.dart';

/// The formula functions the prompt names (a subset of the engine's: the
/// ones a card needs). `test/notation_test.dart` checks each exists.
const List<String> notationFunctions = [
  'length(x)', 'upper(t)', 'lower(t)', 'trim(t)', 'contains(textOrList,v)', 'startsWith(t,p)', 'replace(t,a,b)', 'join(list,sep)', //
  'round(n,d)', 'floor(n)', 'ceil(n)', 'abs(n)', 'min(a,b)', 'max(a,b)', 'clamp(n,lo,hi)', 'fixed(n,d)', 'money(n,"\$",2)',
  'sum(list,x=>n)', 'count(list,x=>cond)', 'filter(list,x=>cond)', 'find(list,x=>cond)', 'any(list,x=>cond)', 'all(list,x=>cond)',
  'map(list,x=>v)', 'sortBy(list,x=>key)', 'sortByDesc(list,x=>key)', 'unique(list)', 'first(list)', 'last(list)', 'slice(list,a,b)',
  'take(list,n)', 'reverse(list)', 'range(n)', 'indexOf(list,v)', 'append(list,item)', 'without(list,item)', 'removeAt(list,i)',
  'setAt(list,i,item)', 'updateWhere(list,x=>cond,x=>new)', 'removeWhere(list,x=>cond)', 'with(map,key,v)', 'isEmpty(x)',
  'coalesce(v,fallback)', 'today()', 'formatDate(date,"MMM d")',
];

/// The prompt for the notation over [catalog] (its level 0 and 1 types).
String notationPrompt({Catalog? catalog, NotationOptions options = const NotationOptions()}) {
  final c = catalog ?? Catalog.current;
  final short = {
    for (final e in notationTypes.entries)
      if (e.key != 'Card' && e.key != 'Image') e.value.type: e.key,
  };
  String written(String type) => short[type] ?? '${type[0].toUpperCase()}${type.substring(1)}';
  // The types worth naming in a small prompt: the rest of levels 0 and 1
  // parse too, and are taught by the reference when a UI needs them.
  const taught = {
    'row', 'column', 'stack', 'text', 'icon', 'spacer', 'divider', 'listView', 'gridView', //
    'filledButton', 'iconButton', 'textField', 'switch', 'checkbox', 'radio', 'slider', 'dropdown', 'segmentedButton',
    'choiceChip', 'filterChip', 'chip', 'badge', 'progressBar', 'circularProgressIndicator', 'datePicker', 'timePicker',
    'accordion', 'listTile', 'barChart', 'lineChart',
  };
  List<String> ofLevel(Level l) => [
        for (final w in c.widgets)
          if (widgetLevels[w.type] == l && taught.contains(w.type)) written(w.type),
      ];
  final layout = [...ofLevel(Level.core), 'Box', 'Card', 'Image'];
  final controls = ofLevel(Level.widgets);
  return '''
You describe a UI by writing it in this notation, one node per line, children indented two spaces under their parent. Write only the notation: no JSON, no prose, no code fence.

LINE
  Type[.variant][#id] ["text"] [key:value ...] [=binding] [-> action; action]

- "text" is the node's main string: a Text's text, a Button's or Toggle's label, an Input's label (a second string is its hint), an Icon's name, an Image's URL. {name} inside a string shows a variable: "Total: {total}".
- key:value sets a prop by its name. Common keys: gap (space between children), pad (padding: one number or [left,top,right,bottom]), w, h (a number, fill or hug), fill (background color #AARRGGBB), radius. Quote a value with spaces: hint:"you@example.com". Lists are JSON: items:["S","M","L"].
- Words on a Row or Column: start, center, end, between (along it); top, middle, bottom, left, right, stretch (across it). grow on a child takes the remaining room. hidden hides a node.
- =name binds a control's value to a variable both ways (the variable is created for you): Slider =volume, Toggle "Wi-Fi" =wifi, Input "Email" =email, Select =size items:["S","M","L"]. On other keys write key:=expression with no spaces: visible:=count>0.
- -> runs on tap (on change, for a control): name=value sets a variable; emit eventName [value] tells the app (emit pick item.id); toast "Saved"; link https://…; open id / close for a modal. Separate several with ;
- state name=value on its own line (top level) declares a variable with a starting value.
- if expression on its own line shows the lines indented under it only while it holds.
- each row in rows on its own line repeats the lines indented under it once per element of a list variable (state rows=[{"name":"Ada","age":36}]); inside, {row.name} reads the element.
- #id only when something else needs to name the node.
- Sizes are worked out: in a Column a child is as wide as the column and as tall as its content; in a Row a child is as big as its content. Do not write sizes unless the design needs one.

TYPES
  Layout and content: ${layout.join(', ')}
  Controls: ${controls.join(', ')}
  Text variants: ${options.textStyles.keys.map((k) => 'Text.$k').join(', ')} (plain Text is body text)
  Button variants: ${buttonVariants.keys.map((k) => 'Button.$k').join(', ')} (plain Button is primary)
  Badge variants: ${badgeVariants.keys.map((k) => 'Badge.$k').join(', ')}
  Card is a padded, bordered Column; Box is a Column you style (fill, radius, pad). Every control already has the design system's look: write no colors or sizes on controls.
  Grid cols:3 gap:8 lays its children out in columns. Progress 0.6 (or Progress =done) shows a share from 0 to 1. Select and SegmentedButton take items:["A","B"]. Icon "name" uses Material icon names (check, close, star, chevron_right).
  BarChart values:[3,5,4] labels:["Mon","Tue","Wed"] and LineChart values:[10,12,11,14] draw charts: never link to a chart image.
  Only Row, Column, Stack, Box, Card, Grid, List, Accordion and ListTile take children.

FORMULAS (in {…}, after = and := and in -> name=…)
  Operators: + - * / % == != < <= > >= && || ! and cond ? a : b. Text in "double quotes" or 'single'. Lists [1,2], fields a.b, items list[0].
  Only these functions exist: ${notationFunctions.join(', ')}.
  Lists never change in place: set the variable to a new list (-> cart=append(cart,item); -> rows=updateWhere(rows,r=>r.id==row.id,r=>with(r,"qty",r.qty+1))).
  An action is one of the forms above, never a condition: to choose, set a variable to a formula (-> step=valid?3:2). Chips have selected:=expression and enabled:=expression.

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
    Text.strong "\$24"
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
