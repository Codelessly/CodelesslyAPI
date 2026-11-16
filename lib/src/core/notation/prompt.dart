// What an agent is told to write the compact notation: the grammar, the
// types of levels 0 and 1 by the name to write, and three examples. Built
// from the catalog and the notation's own tables, so it cannot name a type
// or a variant that does not parse.
import '../catalog.dart';
import '../design_system.dart';
import '../props.dart';
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
  'coalesce(v,fallback)', 'today()', 'formatDate(date,"MMM d")', 'duration(seconds)', 'concat(listA,listB)',
];

/// From this canvas width on the prompt teaches the page words (`Page`,
/// `Section`, `App`, `Sidebar`…): a window, not a card.
const double notationPageWidth = 700;

/// The prompt for the notation over [catalog] (its level 0 and 1 types).
///
/// With a [designSystem], the prompt also lists its components, one line
/// each, as they are called: the main string when it has one, `=name` when
/// it keeps a value, its other parameters and what it is for. [only]
/// narrows the list to those types (a chat that needs a dozen, not all).
String notationPrompt({
  Catalog? catalog,
  NotationOptions options = const NotationOptions(),
  DesignSystem? designSystem,
  Set<String>? only,
  bool natural = false,
  bool wanted = false,
}) {
  final c = catalog ?? Catalog.current;
  final componentLines = designSystem == null
      ? const <String>[]
      : [
          for (final component in designSystem.list)
            // A name the notation already reads as a core type (Button,
            // Card, Slider) stays that: listing the component of the same
            // name would teach parameters the line does not take.
            if (!notationTypes.containsKey(component.type) &&
                c.widget('${component.type[0].toLowerCase()}${component.type.substring(1)}') == null)
              if (only == null || only.contains(component.type)) notationComponentLine(component),
        ];
  // How the design system says its pieces go together: the "In brief"
  // section of its patterns (PATTERNS.md), when it has one. Without it a
  // model is given parts and no way of putting them together, and falls
  // back to plain boxes for anything no part is named after.
  String? brief;
  if (designSystem != null) {
    final from = RegExp(r'^## In brief[ \t]*$', multiLine: true).firstMatch(designSystem.patterns);
    if (from != null) {
      final rest = designSystem.patterns.substring(from.end);
      final next = RegExp(r'^## ', multiLine: true).firstMatch(rest);
      brief = (next == null ? rest : rest.substring(0, next.start)).trim();
    }
  }
  final composing = brief == null || brief.isEmpty
      ? ''
      : '''

PUTTING THEM TOGETHER (${designSystem!.name})
  Build the whole answer from the components above; plain Row, Column, Text and Box are only the glue between them. When no component is named after what you are showing, compose it from the general ones (a frame, a section label, rows of details, options, a progress line, a stat, a picture, a callout, a closing action) rather than from boxes.
${brief.split('\n').map((l) => '  $l').join('\n')}
''';
  final components = componentLines.isEmpty
      ? ''
      : '''

COMPONENTS (${designSystem!.name}: ready-made, already styled; prefer one of these to building its look from boxes)
  Written like any node: Name "text" key:value =variable -> action. The quoted names are filled, in order, by the strings you write; a name ending in ! must be given (key:value). =variable is where the component keeps its value (created for you); -> runs when it is used (its first event). Lists are written ["a","b"]. A component with (children) takes lines indented under it.
${componentLines.map((l) => '  $l').join('\n')}${wanted ? '''

  A MISSING COMPONENT: before writing, name the main reusable unit of the request (a poll's results, a voice note, a boarding pass, a month calendar, a quiz question with its grading). If a listed component represents that unit's data and its distinctive look or interaction, use it. If none does, write exactly one line Wanted \"PascalCaseName\" \"what it shows, the data it takes, what it does\" inside the card, and build the unit under it from the general parts (rows, texts, badges, options, charts, progress lines) as a stand-in:
    ChatCard \"Team lunch\" \"Friday\"
      Wanted \"PollResults\" \"each option with its share of the votes as a bar, the leader and my choice marked\"
        each o in options
          ProgressLine \"{o.name}\" value:{o.share}
  That the general parts can draw it is not a reason to stay silent: the stand-in is shown now and a designed component of that name is made for later answers. Never ask for a unit a listed component already represents.''' : ''}
''';
  // A window, not a card: the frames of a page, and how the design system
  // says its pages go together (the "Pages in brief" of its patterns).
  final lead = options.textStyles.containsKey('lead') ? '.lead' : '.muted';
  final eyebrow = options.textStyles.containsKey('eyebrow') ? 'Text.eyebrow "FEATURES"\n        ' : '';
  String? pagesBrief;
  if (designSystem != null) {
    final from = RegExp(r'^## Pages in brief[ \t]*$', multiLine: true).firstMatch(designSystem.patterns);
    if (from != null) {
      final rest = designSystem.patterns.substring(from.end);
      final next = RegExp(r'^## ', multiLine: true).firstMatch(rest);
      pagesBrief = (next == null ? rest : rest.substring(0, next.start)).trim();
    }
  }
  final w = options.width.round();
  final pages = options.width < notationPageWidth
      ? ''
      : '''

PAGES (this UI is a whole window $w wide, not a card in a chat)
  Start with a frame. It owns the widths, the margins and the scrolling, so write no window sizes (no w:$w, no h:fill on the root) and no page margins.
  A website page scrolls, and its bands stack:
    Modal                   a narrow, scrolling page opened over another canvas by -> open <id>; -> open <id> drawer opens it as a side sheet at the design system's sidebar width plus gutters
    Page
      Nav                    the bar across the top; its children are spread end to end (the logo, a Row of links, a Row of actions)
      Section                a full-width band; what is under it sits in a centered column ${options.contentWidth.round()} wide. Section narrow for reading text, Section tint for a tinted band (alternate plain and tinted bands down a page), Section compact for a short band (logos, a strip of figures), Section center to center what is in it
      Footer
  An app window is as tall as the window, and each pane scrolls by itself:
    App
      Sidebar                a fixed pane at the side (w:240): the name, NavItem lines, Spacer grow, then what sits at its foot
      Main                   the pane that takes the rest: a Nav (its top bar: the title, then a Row of actions) and under it a Column pad:24 gap:16 of content
      Pane w:320             a further pane (a list beside its details, a details panel): Pane w:320 pad:16 gap:12
  NavItem "Orders" icon:"inbox" badge:"12" selected:=tab=="orders" -> tab="orders" is a line of a sidebar (or of a Nav). Link "Docs" is a link (href:"https://…", or -> an action). Brand "Harbor" icon:"anchor" is the product's mark and name (first in a Sidebar or a Nav). Heading "…" heads a section (level:1 a landing page's headline or an app's page title, level:3 the title of a card or a panel; the title of an article or a docs page is a plain Heading). Link is in the accent; a quiet link (a table of contents, a footer) is Text.muted "…" -> an action. IconTile "sync" is an icon on a small tinted tile (the mark of a feature, a stat, a row).
  A heading with #id is an anchor: Link "Install" -> scroll install scrolls it into view. Heading#install "Install" onEnterViewport:heading="Install" updates the active outline as the reader scrolls.
  Side by side: Row gap:32 with grow on each child that shares the width (Column grow gap:12), or Grid cols:3 gap:24 for equal cells; Cards side by side are equally tall by themselves; write top on a Row of other things that differ in height. Row between spreads its children end to end. A rule on one side is border-bottom:#… (border-top, border-left, border-right).
  Inside a frame everything is written as on a card: the components, Card, Text, the controls. A Card in a Grid is a tile of the page.${options.reflow ? '''

  Tablets and phones: write the page once, for this width. It lays itself out narrower: a Grid takes fewer columns, a Row of cards or of content beside a rail stacks, any other row wraps before it overflows, a table keeps the columns it has room for (the first ones: put what matters first), an App shows its Main pane (a tablet also the panes before it), a Nav hides its links, sections and headlines get smaller. So that it can:
    Share a width with grow, or give the one fixed part a width (a rail: Column w:320) and let the rest grow. Do not give every child of a row a fixed width, and write no fixed width over 320 on anything but a rail or a picture.
    Equal cells are a Grid, not a Row of fixed-width boxes. A table's row is a Row whose cells have widths (Text "Status" w:90) and one cell that grows, its header written the same way.
    hide:phone leaves a node out on a phone, hide:tablet on a tablet and a phone; show:phone shows it on a phone only, show:tablet on a tablet and a phone only (a menu button for the links a Nav hides: IconButton "menu" show:phone -> menu=!menu, then if menu a Column show:phone of the links).''' : ''}${pagesBrief == null || pagesBrief.isEmpty ? '' : '\n${pagesBrief.split('\n').map((l) => '  $l').join('\n')}'}

  Page
    Nav
      Brand "Tidewater" icon:"waves"
      Row gap:4
        Link "Features"
        Link "Pricing"
      Button "Start free" -> emit start
    Section
      Row gap:48
        Column grow gap:20
          Heading "Fill every room" level:1
          Text$lead "Calendar, channels and pricing in one place."
          Row gap:12
            Button "Start free" size:large -> emit start
            Button.outline "See how it works" size:large -> emit tour
        Card grow
          BarChart values:[14,18,16,21] labels:["Thu","Fri","Sat","Sun"] h:200
    Section tint
      Column gap:12
        ${eyebrow}Heading "Everything a small hotel needs"
      Grid cols:3 gap:24
        Card gap:12
          IconTile "sync"
          Heading "Channel sync" level:3
          Text.muted "Availability stays in step."
    Footer
      Row between
        Text.strong "Tidewater"
        Text.muted "© 2026 Tidewater"

  state tab="orders"
  App
    Sidebar
      Brand "Harbor" icon:"anchor"
      NavItem "Overview" icon:"dashboard" selected:=tab=="overview" -> tab="overview"
      NavItem "Orders" icon:"receipt_long" badge:"12" selected:=tab=="orders" -> tab="orders"
      Spacer grow
      Text.muted "Sam Patel"
    Main
      Nav
        Heading "Orders"
        Row gap:8
          Input "Search" =q w:220
          Button "New order" -> emit newOrder
      Column pad:24 gap:16
        Card gap:8
          Text.strong "Latest orders"
''';
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
- Words on a Row, Column or Stack: center is across the page and middle down it, on all three (Column center centers its children side to side). Also start, end, between (along a Row or Column); top, bottom, left, right, stretch (across it). grow on a child takes the remaining room. hidden hides a node.
${natural ? '''- =name binds a control's value to a variable both ways (the variable is created for you): Slider =volume, Toggle "Wi-Fi" =wifi, Input "Email" =email, Select =size items:["S","M","L"]. On other keys a value that follows the state is an expression in braces: visible:{count > 0}, enabled:{name != "" and agreed}, selected:{tab == "all"}.''' : '''- =name binds a control's value to a variable both ways (the variable is created for you): Slider =volume, Toggle "Wi-Fi" =wifi, Input "Email" =email, Select =size items:["S","M","L"]. On other keys write key:=expression with no spaces: visible:=count>0.'''}
${natural ? '''- -> runs on tap (on change, for a control) and holds statements as you would write them in code: count += 1; liked = !liked; step = valid ? 3 : 2; if (qty > 0) { qty -= 1 }. Also: emit eventName [value] tells the app (emit pick item.id); toast "Saved"; link https://…; open id / close for a modal. Separate several with ;''' : '''- -> runs on tap (on change, for a control): name=value sets a variable; emit eventName [value] tells the app (emit pick item.id); toast "Saved"; link https://…; open id / close for a modal. Separate several with ;'''}
- drag:group(value) on a node lets it be dragged carrying a value; drop:groupA,groupB -> … on a node takes those drops, and its -> runs on a drop with result.data the value carried: Card drag:todo(card.id), then Column drop:todo -> done=append(done,result.data).
${natural ? '''- state name=value on its own line (top level, before the card) declares a variable with a starting value: state qty=1, state liked=false, state lines=[{"name":"Milk","price":3.2,"qty":2}]. let name = expression on its own line names a value worked out from the state, kept up to date as the state changes: let subtotal = sum(map(lines, l => l.qty * l.price)); let total = subtotal + 4.99. Never work a total out yourself and write it as text: write the expression, so it follows the state.''' : '''- state name=value on its own line (top level) declares a variable with a starting value.'''}
- project name binds site.json state across pages; open id [narrow] opens a canvas as a modal, close dismisses it.
- every 1000 -> name=value on its own line (top level) runs as time passes (milliseconds, or 1s): a clock, a countdown. every 1s when running -> … runs only while the condition holds.
- if expression on its own line shows the lines indented under it only while it holds.
${natural ? '''- each row in rows on its own line repeats the lines indented under it once per element of a list variable; inside, {row.name} reads the element, a control bound to one of its fields (Input =row.name, Toggle =row.done) changes that element, and so does an action: -> row.qty += 1; -> row.done = !row.done; -> rows.remove(row). Outside it, -> rows.add({"name":"Eggs","qty":1}) adds one.''' : '''- each row in rows on its own line repeats the lines indented under it once per element of a list variable (state rows=[{"name":"Ada","age":36}]); inside, {row.name} reads the element, and a control bound to one of its fields (Input =row.name, Toggle =row.done) changes that element in the list.'''}
- #id only when something else needs to name the node.
- Beyond these words: a {…} at the end of a line is merged into that node as JSON ({"props": {"size": 18}}). A whole node the notation has no word for is written as node {"type": "…", …} on its own line (its JSON may run over several lines); lines indented under it are its children, written as usual.
- Sizes are worked out: in a Column a child is as wide as the column and as tall as its content; in a Row a child is as big as its content. Do not write sizes unless the design needs one.

TYPES
  Layout and content: ${layout.join(', ')}
  Controls: ${controls.join(', ')}
  Text variants: ${options.textStyles.keys.map((k) => 'Text.$k').join(', ')} (plain Text is body text)
  Button variants: ${buttonVariants.keys.map((k) => 'Button.$k').join(', ')} (plain Button is primary)
  Badge variants: ${badgeVariants.keys.map((k) => 'Badge.$k').join(', ')}
  Card is a padded, bordered Column; Box is a Column you style (fill, radius, pad). Every control already has the design system's look: write no colors or sizes on controls. A Text takes color:#FF…, size:32 and weight:700 (a big number is Text "{n}" size:64); a Box or Card takes fill:#FF… (on a dark fill, give its texts a light color). A look can follow data: fill:=, border:= and color:= take an expression. Column scroll lets a tall screen scroll.
  Grid cols:3 gap:8 lays its children out in columns. Progress 0.6 (or Progress =done) shows a share from 0 to 1. Select and SegmentedButton take items:["A","B"]. Input takes type:number (or email, phone) for its keyboard. Icon "name" uses Material icon names (check, close, star, chevron_right).
  Pages =page h:160 shows the lines under it one at a time, swiped across (under it, each item in items gives one page per element); =page is the page shown, from 0, and setting it turns the page. peek:0.86 shows the edge of the next page (a carousel, a gallery). Dots =page count:4 draws its pagination dots (a tap goes to that page); "{page+1} of {length(items)}" is its count. Content wider than the card (a wide table, a strip of tiles) goes in Row scroll, which scrolls sideways.
  BarChart values:[3,5,4] labels:["Mon","Tue","Wed"] and LineChart values:[10,12,11,14] draw charts: never link to a chart image.
  LineChart labels:["W1","W2"] series:[{"name":"Signups","values":[40,52]},{"name":"Churn","values":[8,6]}] draws several lines (AreaChart fills under them); Donut values:[60,25,15] labels:["Rent","Food","Other"] shares of a whole.${options.width >= notationPageWidth ? ' On a page a Donut draws its labels as a legend beside it (under it where there is no room), each with its share: write no legend of your own (legend:false leaves it out).' : ''}
  Gauge 72 min:0 max:180 limit:100 unit:"km/h" is a round meter with its figure inside (Gauge =speed follows a variable); Ring 0.72 a round share (in a Stack center middle with a Text over it for the number inside); Sparkline values:[3,4,3,6] a small trend line.
  Motion is a word on any line: animate:fade (slide-up, slide-left, scale, pop, shake, pulse, spin, shimmer) with duration:400 delay:200; under an each, stagger:80. swipe:left -> … runs on that swipe. Avatar "Maya Reyes" size:40 is a round mark with initials (Avatar src:"…" a picture). Input "Password" password hides it; Input "Note" multiline is a text area. Text "…" center aligns it, strike crosses it out. maxw:720 keeps a page's content from stretching.
  Only Row, Column, Stack, Box, Card, Grid, List, Accordion and ListTile take children.

FORMULAS (in {…}, after = and := and in -> name=…)
  Operators: + - * / % == != < <= > >= && || ! and cond ? a : b. Text in "double quotes" or 'single'. Lists [1,2], fields a.b, items list[0].
  Only these functions exist: ${notationFunctions.join(', ')}.
${natural ? '''  A list or a record changes as in code (rows.add(x), rows.remove(row), row.qty += 1); for anything else set the variable to a new list (rows = filter(rows, r => r.qty > 0)). Money is "{fixed(total,2)}"; a count is "{length(rows)} items"; minutes and seconds are "{duration(elapsed)}" (74 gives 1:14).''' : '''  Lists never change in place: set the variable to a new list (-> cart=append(cart,item); -> rows=updateWhere(rows,r=>r.id==row.id,r=>with(r,"qty",r.qty+1))).'''}
${natural ? '''  Every value shown that depends on the state is written as an expression in {…} (or a let name), never as a number you worked out: after a tap it must show the new value. Chips have selected:{expression} and enabled:{expression}.''' : '''  An action is one of the forms above, never a condition: to choose, set a variable to a formula (-> step=valid?3:2). Chips have selected:=expression and enabled:=expression.'''}

BEYOND THESE WORDS
  The full vocabulary has more. Write that part as a node {…} line or a {…} tail; its reference page says how (ask for the page with ui_docs when you have that tool):
  custom drawing and shapes: decoration · motion and entrance animation: animation · swipe, long press, hover: interaction · several screens: navigation · tables, paged and reorderable lists: lists · validation: forms · scripts: state · video, audio, embeds: media · chart options: charts

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
$components$composing$pages''';
}

/// How [component] is called in the notation, on one line, with what it is
/// for: `Stepper =value min max step label enabled -> onChanged : A number
/// changed one step at a time.`
String notationComponentLine(DesignSystemComponent component) {
  final spec = component.spec;
  final strings = notationStrings(spec);
  final held = spec.props.where((p) => p.type.isVariable && p.key == 'value').firstOrNull ??
      spec.props.where((p) => p.type.isVariable).firstOrNull;
  final rest = [
    for (final p in spec.props)
      if (!strings.contains(p.key) && p.key != held?.key) p.required ? '${p.key}!' : p.key,
  ];
  final parts = [
    spec.type,
    for (final k in strings) '"$k"',
    if (held != null) '=${held.key}',
    ...rest,
    if (spec.events.isNotEmpty) '-> ${spec.events.first.key}',
    if (spec.children == ChildModel.list) '(children)',
  ];
  return '${parts.join(' ')} : ${component.purpose}';
}
