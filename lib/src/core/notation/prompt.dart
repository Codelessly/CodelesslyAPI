// What an agent is told to write the compact notation: the grammar, the
// types of levels 0 and 1 by the name to write, and three examples. Built
// from the catalog and the notation's own tables, so it cannot name a type
// or a variant that does not parse.
import '../catalog.dart';
import '../design_system.dart';
import '../props.dart';
import '../levels.dart';
import 'define.dart' show NotationDefinition;
import 'notation.dart';
import 'page_words.dart' show PageWords;
import 'vocabulary.dart' show NotationVocabulary;

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

/// The functions only the page prompt names (the card prompt has no room):
/// a search over a list.
const List<String> notationPageFunctions = ['fuzzy(list,query,x=>text)'];

/// From this canvas width on the prompt teaches the page words (`Page`,
/// `Section`, `App`, `Sidebar`…): a window, not a card.
const double notationPageWidth = 700;

/// The prompt for the notation over [catalog] (its level 0 and 1 types).
///
/// With a [designSystem], the prompt also lists its components, one line
/// each, as they are called: the main string when it has one, `@value` when
/// it keeps a value (`key=@` for a further variable), its other parameters
/// and what it is for. [only]
/// narrows the list to those types (a chat that needs a dozen, not all).
///
/// The words of the dictionaries [options] has (folders of definitions a
/// caller gave: [NotationOptions.dictionary]) are listed after it, one line
/// each as a line uses it, as a design system's words are.
String notationPrompt({
  Catalog? catalog,
  NotationOptions options = const NotationOptions(),
  DesignSystem? designSystem,
  Set<String>? only,
  bool natural = false,
  bool wanted = false,
  bool open = false,
  bool define = true,
  bool glossary = true,
  bool signatures = true,
}) {
  final text = _prompt(
      catalog: catalog, options: options, designSystem: designSystem, only: only, natural: natural, wanted: wanted, open: open, define: define, glossary: glossary, signatures: signatures);
  final words = notationDictionaryLines(options.vocabulary, prompt: text);
  if (words.isEmpty) return text;
  final names = {
    for (final defs in options.vocabulary.dictionary.values)
      for (final d in defs) ?d.dictionary,
  }.toList()
    ..sort();
  return '${text.trimRight()}\n${notationSignaturesLead(names.join(', '), define: open && define)}\n${words.map((l) => '  $l').join('\n')}\n';
}

/// The lines of the words [vocabulary]'s dictionaries define that [prompt]
/// does not already list (a design system's component or word of that name
/// is the one read) and no definition of a page, a site or a design system
/// replaces: one line each as a line uses it, with what it is for.
List<String> notationDictionaryLines(NotationVocabulary vocabulary, {required String prompt}) => [
      for (final w in vocabulary.dictionary.keys.toList()..sort())
        if (!vocabulary.definitions.containsKey(w) && !RegExp('^  ${RegExp.escape(w)}[ .(]', multiLine: true).hasMatch(prompt))
          for (final d in vocabulary.dictionary[w]!) notationGlossaryDefinitionLine(d),
    ];

String _prompt({
  Catalog? catalog,
  NotationOptions options = const NotationOptions(),
  DesignSystem? designSystem,
  Set<String>? only,
  bool natural = false,
  bool wanted = false,
  bool open = false,
  bool define = true,
  bool glossary = true,
  bool signatures = true,
}) {
  // The open vocabulary (docs/design/19): the grammar and the core only.
  // No component is listed and no behaviour word taught; the model writes
  // the word it expects, and defines it after the last screen
  // ([notationDefinePreface]; docs/design/20). With [define] false, the
  // open prompt as the first corpus was written with: no definitions asked.
  // With a design system, the open prompt lists the words it has beyond the
  // core (its components and the words it defines in the notation), a
  // writer uses them rather than defining its own (the vocabulary loop's
  // Review 6, D29): with [signatures], one line each as a line uses it, in
  // a last section (Review 7, D33: a writer maps to no word whose shape it
  // cannot see); without, their names on one line after the define
  // paragraph, as the glossary experiment's answers were written.
  // [glossary] false leaves it out.
  if (open) {
    final text = _openPrompt(_prompt(catalog: catalog, options: options, natural: natural), define: define);
    if (glossary && signatures && designSystem != null) {
      final lines = notationGlossaryLines(designSystem, options.vocabulary, prompt: text);
      if (lines.isEmpty) return text;
      return '${text.trimRight()}\n${notationSignaturesLead(designSystem.name, define: define)}\n${lines.map((l) => '  $l').join('\n')}\n';
    }
    final names = glossary && designSystem != null ? notationGlossary(designSystem, options.vocabulary, prompt: text) : const <String>[];
    if (names.isEmpty) return text;
    final at = define ? notationOpenPreface.length + notationDefinePreface.length : notationOpenPreface.length;
    return '${text.substring(0, at)}${notationGlossaryLead(define: define)}\n${names.join(' ')}\n\n${text.substring(at)}';
  }
  final c = catalog ?? Catalog.current;
  final componentLines = designSystem == null
      ? const <String>[]
      : [
          for (final component in designSystem.list)
            // A name the notation already reads as a core type (Button,
            // Card, Slider) stays that: listing the component of the same
            // name would teach parameters the line does not take.
            if (!notationTypes.containsKey(component.type) &&
                (c.widget('${component.type[0].toLowerCase()}${component.type.substring(1)}') == null ||
                    notationComponentFirst.contains(component.type)))
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
  Written like any node: Name "text" key=value @variable onEvent={actions}. The quoted names are filled, in order, by the strings you write; a name ending in ! must be given (key=value). @variable is where the component keeps its value (key=@variable for a further one; declare each with state); an optional boolean value also works without it, kept separately for each call. A name starting with on is an event of its own (onPressed={…}); onTap={…} is what it does when it is used. Lists are written ["a","b"]. A component with (children) takes lines indented under it; one with (lines: actions) puts the lines indented under it in that slot, side by side (a badge, a button); any other takes none.
${componentLines.map((l) => '  $l').join('\n')}${wanted ? '''

  A MISSING COMPONENT: before writing, name the main reusable unit of the request (a poll's results, a voice note, a boarding pass, a month calendar, a quiz question with its grading). If a listed component represents that unit's data and its distinctive look or interaction, use it. If none does, write exactly one line Wanted \"PascalCaseName\" \"what it shows, the data it takes, what it does\" inside the card, and build the unit under it from the general parts (rows, texts, badges, options, charts, progress lines) as a stand-in:
    ChatCard \"Team lunch\" \"Friday\"
      Wanted \"PollResults\" \"each option with its share of the votes as a bar, the leader and my choice marked\"
        each o in options
          ProgressLine \"{o.name}\" value={o.share}
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
  Start with a frame. It owns the widths, the margins and the scrolling, so write no window sizes (no w=$w, no h=fill on the root) and no page margins.
  A website page scrolls, and its bands stack:
    Page
      Nav                    the bar across the top; its children are spread end to end (the logo, a Row of links, a Row of actions)
      Section                a full-width band; what is under it sits in a centered column ${options.contentWidth.round()} wide. Section narrow for reading text, Section tint for a tinted band (alternate plain and tinted bands down a page), Section compact for a short band (logos, a strip of figures), Section center to center what is in it
      Footer
  An app window is as tall as the window, and each pane scrolls by itself:
    App
      Sidebar                a fixed pane at the side (w=240): the name, a Row per item, Spacer grow, then what sits at its foot
      Main                   the pane that takes the rest: a Nav (its top bar: the title, then a Row of actions) and under it a Column pad=24 gap=16 of content
      Pane w=320             a further pane (a list beside its details, a details panel): Pane w=320 pad=16 gap=12
    Footer directly under Main, as its last line, is a bar at its foot that stays in view while Main scrolls (a player, a composer, a basket).
  A sidebar's item: Row w=fill gap=10 middle pad=[10,7,10,7] radius=6 selected={tab=="orders"} selected.fill=#142563EB onTap={tab="orders"}, an Icon and a Text grow under it. A link: Text "Docs" color=#FF2563EB onTap={an action}; in a bar, Button.ghost "Docs" onTap={…}; a quiet one, Text.muted. A heading: Text.heading1 (a landing page's headline, at a display size in a Page's Section), Text.heading2, Text.heading3 (a card's or a panel's title). An icon-only button is named by its tooltip: IconButton "filter_alt_off" tooltip="Clear filters" (shown on hover, focus or a touch hold).
  Side by side: Row gap=32 with grow on each child that shares the width (Column grow gap=12), or Grid cols=3 gap=24 for equal cells; Cards side by side are equally tall by themselves; write top on a Row of other things that differ in height. Row between spreads its children end to end. Section bleed runs what is in it from edge to edge (a wide picture, a map). Nav sticky keeps the bar at the top while the page scrolls; sticky on a rail (Column w=320 sticky) keeps an enrol panel or a table of contents in view while the page scrolls. A rule on one side is border-bottom=#… (border-top, border-left, border-right).
  A block's events are on its line, each by its name: SiteNav … onNavigate={go {replace(lower(result)," ","_")}} onCta={go signup} onSecondary={go login}. SiteNav … sticky keeps it at the top.
  key mod+k onPress={open search} on its own line (top level) is a shortcut of the page (mod: Ctrl, ⌘ on a Mac; also alt, shift), key j when={!editing} onPress={…} acts only while its condition holds (a plain key never acts while a field is typed in; under a Dialog#id, only while that dialog is open); Text "Search" shortcut="mod+k" shows it as Ctrl K or ⌘K; Button "B" shortcut="mod+b" presses it.
  A value every page of the site shares (a cart, the signed-in name) is declared once, in site.json's variables, a name and its starting value ("variables": {"cart": [], "plan": "pro", "draft": {"value": "", "persist": true}}); a page expanded beside that site.json reads and sets it by name with no declaration (project cart=[] before the page says so on the page itself): it is read and set like any other (Select @cart, onTap={cart=append(cart,item)}) and keeps its value from page to page. state draft="" saved keeps a value across reloads (project cart=[] saved, with "persist": true in site.json).
  device.hover is true where a pointer can hover (device.pointer is "fine" there, else "coarse"), whatever the width: under if !device.hover, give what onHover={…} shows a button that does the same.
  Inside a frame everything is written as on a card: the components, Card, Text, the controls. A Card in a Grid is a tile of the page.
  Also, on a page:
    Input "Qty" @qty type=number min=1 max=12 step=1: a number the Up and Down keys step, within its bounds.
    CodeInput "Code" @code length=6 digits: a one-time code, one field drawn as boxes.
    Slider @low @high min=0 max=100: a range, one slider with two thumbs.
    Calendar @arrival @departure disabledDates=["2026-11-24"] marks={"2026-11-20":"£225"}: a month in the page for a range of days (yyyy-MM-dd; one @: one day, its value that day); a disabled day is not picked or crossed, a mark is a short text under its day (or marks={list}: days, or records of date and label).
    DataTable rows={orders} columns=[{"key":"name","label":"Customer"},{"key":"total","label":"Total"}] @row: a table whose headers sort and whose rows are chosen (row: the chosen one's place, -1 none); onSort={…} reads result.column, onRowTap={…} result.row.
    Splitter @paneW min=200 max=640: a divider dragged between two panes of a Row, the first Column w={paneW} (orientation=vertical: of a Column, its height).
    each r in fuzzy(rows,q,x=>x.title): a search, the rows whose text matches q, best first (fuzzy(rows,q,x=>x.title,3,"keep"): 3 letters off a word, in list order); Text "{r.title}" mark={q} marks what matched (a block's mark={q} too).
    each stop in trip reorder: a list put in order by hand; a Handle in each row is its grip (dragged, or Alt+arrows) and trip holds the order. Lists with one reorder=group pass rows between them.
    each line in lines follow h=180: a log or a chat; it scrolls in that height, opens at its end and follows what is added (follow grow: it takes the room its column leaves, over a composer).
    SwipeAction "Book" side=end when={!row.full} onTap={picked=result.item.name}, under an each: an action behind the swiped row (side=start: the other side; removes takes the row out). Give the row a menu button for the same.${options.reflow ? '''

  Tablets and phones: write the page once, for this width. It lays itself out narrower: a Grid takes fewer columns (one of 7, or written Grid cols=4 keep, keeps them), a Row of cards or of content beside a rail stacks, any other row wraps before it overflows, a table keeps the columns it has room for (the first ones: put what matters first), an App shows its Main pane (a tablet also the panes before it) and opens its Sidebar as a drawer from a menu button it adds to Main's Nav, a list beside its detail shows one at a time on a phone, with a back button (each row: onTap={sel=m.id}), a Nav hides its quiet buttons (Button.ghost) and opens them from a menu button it adds itself, sections and headlines get smaller. So that it can:
    Share a width with grow, or give the one fixed part a width (a rail: Column w=320) and let the rest grow. Do not give every child of a row a fixed width, and write no fixed width over 320 on anything but a rail or a picture.
    Equal cells are a Grid, not a Row of fixed-width boxes. A table's row is a Row whose cells have widths (Text "Status" w=90) and one cell that grows, its header written the same way.
    hide=phone leaves a node out on a phone, hide=tablet on a tablet and a phone; show=phone shows it on a phone only, show=tablet on a tablet and a phone only. Write no menu button for a Nav's links: it has one, for the quiet buttons it hides (a Nav with a show=phone line of its own keeps yours instead). They hold on a line under an if too: the condition counts only where the size shows the line.
    A part's lines on a phone go in a block after its own: at phone, with ...#brand under it placing the part's Text#brand line again.
    A Row of two Columns that grow, each a heading and its text, stacks where they no longer fit; a Row of controls with choices (filters) wraps whole controls onto the next line.''' : ''}

  OVER THE PAGE (a dialog, a sheet, a drawer, a menu): write each after the page, at the margin, with an id, its content indented under it as on a card. onTap={open signup} shows it, close closes it (so does a tap outside it). It reads and sets the page's values: a form in a dialog sets them and closes (onTap={saved=true; close}).
    Dialog#signup "Join the waitlist" "A line under the title"    a centered dialog with its title and a close button (w=480)
    Sheet#filters "Filters"          rises from the bottom of the window: filters, options, a share sheet (stops=[0.5,0.9]: heights it rests at; stop=@at: the one it is at)
    Dialog#edit "Edit" guard={name!=""}    while guard holds (on a Sheet too) a tap outside and Escape do not close it: give it a Discard button, or guardText="Discard changes?" onDiscard={name=""} asks then and closes on a yes
    Drawer#cart "Your cart" right    a panel as tall as the window at its side (the left unless right; w=300); a line tapped in it closes it
    Menu#more                        a menu by the button that opened it (Menu#more end lines up their right edges; above opens upwards); its lines are Row gap=10 pad=8 onTap={an action} (an Icon, a Text), and each closes the menu after it
    Popover#tip                      a small panel by what opened it (a hint, a picker); Popover#bio arrow points at it
    Text "About Mara" preview=bio    that Popover as a hover card: it opens when the pointer rests on the line or the focus comes, at once on a tap
    Lightbox#zoom "{photo}" "Caption"    a picture large over the page, which a pinch, the wheel or a double tap zooms: Image "{p.url}" onTap={photo=p.url; open zoom}
    Lightbox#shots photos={photos} @at    a gallery of them (each a URL, or a record with url and caption): swiped or stepped with its arrows, with a count and thumbnails, opened at the one tapped (under each p in photos: Image "{p.url}" onTap={at=index; open shots})
  A row's menu: IconButton "more_vert" onTap={sel=row.id; open rowMenu}, its lines read sel. menu=rowMenu on a line opens it at the pointer on a right click or a long press (under each row, its lines read row). Write no modal as a Stack or an if over the page, and no drawer for an App's Sidebar.${pagesBrief == null || pagesBrief.isEmpty ? '' : '\n${pagesBrief.split('\n').map((l) => '  $l').join('\n')}'}

  state email=""
  Page
    Nav
      Text.strong "Tidewater"
      Row gap=4
        Button.ghost "Features"
        Button.ghost "Pricing"
      Button "Start free" onTap={open signup}
    Section
      Row gap=48
        Column grow gap=20
          Text.heading1 "Fill every room"
          Text$lead "Calendar, channels and pricing in one place."
          Row gap=12
            Button "Start free" size=large onTap={emit start}
            Button.outline "See how it works" size=large onTap={emit tour}
        Card grow
          BarChart values=[14,18,16,21] labels=["Thu","Fri","Sat","Sun"] h=200
    Section tint
      Column gap=12
        ${eyebrow}Text.heading2 "Everything a small hotel needs"
      Grid cols=3 gap=24
        Card gap=12
          Icon "sync" color=#FF2563EB
          Text.heading3 "Channel sync"
          Text.muted "Availability stays in step."
    Footer
      Row between
        Text.strong "Tidewater"
        Text.muted "© 2026 Tidewater"
  Dialog#signup "Start free"
    Input "Work email" @email
    Button "Create account" onTap={emit start; close}

  state tab="orders"
  state q=""
  App
    Sidebar
      Text.strong "Harbor"
      Row w=fill gap=10 middle pad=[10,7,10,7] radius=6 selected={tab=="orders"} selected.fill=#142563EB onTap={tab="orders"}
        Icon "receipt_long"
        Text "Orders" grow
      Spacer grow
      Text.muted "Sam Patel"
    Main
      Nav
        Text.heading3 "Orders"
        Row gap=8
          Input "Search" @q w=220
          Button "New order" onTap={emit newOrder}
      Column pad=24 gap=16
        Card gap=8
          Text.strong "Latest orders"
''';
  final short = {
    for (final e in notationTypes.entries)
      // (Words that are a Column or a Row underneath name them by their own
      // name: the list said Badge and Wanted for Row and Column.)
      if (!const {'Card', 'Image', 'CodeInput', 'Handle', 'DataTable', 'NumberInput', 'Avatar', 'List', 'Badge', 'Grid', 'GridView', 'Box', 'Wanted'}.contains(e.key))
        e.value.type: e.key,
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
  Type[.variant][#id] ["text"] [key=value ...]
  After the text everything is key=value. {…} holds an expression, or, after an on… key, actions.

- "text" is the node's main string: a Text's text, a Button's or Toggle's label, an Input's label (a second string is its hint), an Icon's name, an Image's URL. {name} inside a string shows a variable: "Total: {total}".
- key=value sets a prop by its name. Common keys: gap (space between children), pad (padding: one number or [left,top,right,bottom]), w, h (a number, fill or hug), fill (background color #AARRGGBB), radius. Quote a value with spaces: hint="you@example.com". Lists are JSON: items=["S","M","L"]. A value that follows the state is an expression in braces: visible={count > 0}, selected={tab == "all"}.
- Words on a Row, Column or Stack: center is across the page and middle down it, on all three (Column center centers its children side to side). Also start, end, between (along a Row or Column); top, bottom, left, right, stretch (across it). grow on a child takes the remaining room. hidden hides a node.
- @name is the variable itself, both ways: bare, the control's value; selected=@picked binds another property. Declare it with state.
- What a node does is an event, its actions in braces: onTap={…}, or onChange={…} on a control (result is its new value). ${natural ? '''Actions are statements as you would write them in code: count += 1; liked = !liked; step = valid ? 3 : 2; if (qty > 0) { qty -= 1 }. Also''' : '''Actions: name=value sets a variable;'''} emit eventName [value] tells the app (emit pick item.id); toast "Saved"; link https://…; open id / close for a modal${options.width >= notationPageWidth ? r'''; go screen opens a page of the site (go case-study: an id may have hyphens; go {replace(lower(result)," ","_")} works the page out, in braces, as from a SiteNav's link); scroll pricing moves the page to the line with that id (Section#pricing, or id=pricing on a line); confirm "Delete 2 clips?" "They cannot be restored." ok="Delete" danger then {clips=[]} else {toast "Kept"} asks first (a line of detail under it, the word on its yes button, danger for a red one; else: what a no does); announce "{n} results" tells a screen reader (Text "{n} results" live: each change); focus search puts the caret in Input#search; copy "{link}" copies a text''' : ''''''}. Separate several with ;
- drag=group(value) on a node lets it be dragged carrying a value; drop=groupA,groupB on a node takes those drops, and its onDrop={…} runs on a drop with result.data the value carried: Card drag=todo(card.id), then Column drop=todo onDrop={done=append(done,result.data)}.
${natural ? '''- state name=value on its own line (top level, before the card) declares a variable with a starting value: state qty=1, state liked=false, state lines=[{"name":"Milk","price":3.2,"qty":2}]. let name = expression on its own line names a value worked out from the state, kept up to date as the state changes: let subtotal = sum(map(lines, l => l.qty * l.price)); let total = subtotal + 4.99. Never work a total out yourself and write it as text: write the expression, so it follows the state.''' : '''- state name=value on its own line (top level) declares a variable with a starting value.'''}
- every 1000 onTick={name=value} on its own line (top level) runs as time passes (milliseconds, or 1s): a clock, a countdown. every 1s when running onTick={…} runs only while the condition holds.
- if expression on its own line shows the lines indented under it only while it holds.
${natural ? '''- each row in rows on its own line repeats the lines indented under it once per element of a list variable; inside, {row.name} reads the element, a control bound to one of its fields (Input @row.name, Toggle @row.done) changes that element, and so does an action: row.qty += 1; row.done = !row.done; rows.remove(row). Outside it, rows.add({"name":"Eggs","qty":1}) adds one.''' : '''- each row in rows on its own line repeats the lines indented under it once per element of a list variable (state rows=[{"name":"Ada","age":36}]); inside, {row.name} reads the element, and a control bound to one of its fields (Input @row.name, Toggle @row.done) changes that element in the list.'''}
- #id only when something else names the node.
- Beyond these words: a {…} at the end of a line is merged into that node as JSON ({"props": {"size": 18}}). A whole node the notation has no word for is written as node {"type": "…", …} on its own line (its JSON may run over several lines); lines indented under it are its children, written as usual.
- Sizes are worked out: in a Column a child is as wide as the column and as tall as its content; in a Row a child is as big as its content. Do not write sizes unless the design needs one.

TYPES
  Layout and content: ${layout.join(', ')}
  Controls: ${controls.join(', ')}
  Text variants: ${options.textStyles.keys.map((k) => 'Text.$k').join(', ')} (plain Text is body text)
  Button variants: ${buttonVariants.keys.map((k) => 'Button.$k').join(', ')} (plain Button is primary)
  Badge variants: ${badgeVariants.keys.map((k) => 'Badge.$k').join(', ')}
  Card is a padded, bordered Column; Box is a Column you style (fill, radius, pad). Every control already has the design system's look: write no colors or sizes on controls. A Text takes color=#FF…, size=32 and weight=700 (a big number is Text "{n}" size=64); a Box or Card takes fill=#FF… (on a dark fill, give its texts a light color). Column scroll lets a tall screen scroll.
  Grid cols=3 gap=8 lays its children out in columns. Progress 0.6 (or Progress {done}) shows a share from 0 to 1. Select and SegmentedButton take items=["A","B"] (a SegmentedButton: two to four short options, never a page's tabs). Input takes type=number (or email, phone) for its keyboard. Icon "name" uses Material icon names (check, close, star, chevron_right).
  Pages @page h=160 shows the lines under it one at a time, swiped across (under it, each item in items gives one page per element); page is the page shown, from 0, and setting it turns the page. peek=0.86 shows the edge of the next page (a carousel, a gallery). "{page+1} of {length(items)}" says which page it is. What is wider than the card (a wide table, a strip of tiles) goes in Row scroll, which scrolls sideways.
  BarChart values=[3,5,4] labels=["Mon","Tue","Wed"] and LineChart values=[10,12,11,14] draw charts: never link to a chart image.
  LineChart labels=["W1","W2"] series=[{"name":"Signups","values":[40,52]},{"name":"Churn","values":[8,6]}] draws several lines (AreaChart fills under them); Donut values=[60,25,15] labels=["Rent","Food","Other"] shares of a whole.${options.width >= notationPageWidth ? ' On a page a Donut draws its labels as a legend beside it (under it where there is no room), each with its share: write no legend of your own (legend=false leaves it out).' : ''}
  Gauge 72 min=0 max=180 limit=100 unit="km/h" is a round meter with its figure inside (Gauge {speed} follows a variable); Ring 0.72 a round share (in a Stack center middle with a Text over it for the number inside); Sparkline values=[3,4,3,6] a small trend line.
  Motion is a word on any line: animate=fade (slide-up, slide-left, scale, pop, shake, pulse, spin, shimmer) with duration=400 delay=200; under an each, stagger=80. onSwipeLeft={…} runs on that swipe. Avatar "Maya Reyes" size=40 is a round mark with initials (Avatar src="…" a picture). Input "Password" password hides it; Input "Note" multiline is a text area.${options.width >= notationPageWidth ? ' In a Row beside buttons, Input "Message #general" @draft multiline grow onSubmit={…} is a composer: its string the placeholder, one line growing as it fills, Enter sends and Shift+Enter breaks the line.' : ''} Text "…" center aligns it, strike crosses it out. maxw=720 keeps a page's content from stretching.
  Only Row, Column, Stack, Box, Card, Grid, Pages, Accordion and ListTile take children.

FORMULAS (in {…} and in an action's name=…)
  Operators: + - * / % == != < <= > >= && || ! and cond ? a : b. Text in "double quotes" or 'single'. Lists [1,2], fields a.b, items list[0].
  Only these functions exist: ${[...notationFunctions, if (options.width >= notationPageWidth) ...notationPageFunctions].join(', ')}.
${natural ? '''  A list or a record changes as in code (rows.add(x), rows.remove(row), row.qty += 1); for anything else set the variable to a new list (rows = filter(rows, r => r.qty > 0)). Money is "{fixed(total,2)}"; a count is "{length(rows)} items"; minutes and seconds are "{duration(elapsed)}" (74 gives 1:14).''' : '''  Lists never change in place: set the variable to a new list (cart=append(cart,item); rows=updateWhere(rows,r=>r.id==row.id,r=>with(r,"qty",r.qty+1))).'''}
${natural ? '''  Every value shown that depends on the state is written as an expression in {…} (or a let name), never as a number you worked out: after a tap it must show the new value.''' : '''  To choose between actions: onTap={ok ? close : toast "Fill it in"} (a branch may be {a; b}, or empty).'''}

BEYOND THESE WORDS
  The full vocabulary has more. Write that part as a node {…} line or a {…} tail; its reference page says how (ask for the page with ui_docs when you have that tool):
  custom drawing and shapes: decoration · motion and entrance animation: animation · swipe, long press, hover: interaction · several screens: navigation · tables, paged and reorderable lists: lists · validation: forms · scripts: state · video, audio, embeds: media · chart options: charts

EXAMPLES
state volume=50
state email=""
state notify=true
Column gap=12 pad=16
  Slider @volume min=0 max=100
  Input "Email" "you@example.com" @email
  Toggle "Notifications" @notify
  Button "Save" onTap={emit save}

state qty=1
Card gap=12
  Row between
    Text.heading "Espresso beans, 1 kg"
    Text.strong "\$24"
  Row gap=8
    Button.outline "-" onTap={qty=max(1,qty-1)}
    Text.strong "{qty}"
    Button.outline "+" onTap={qty=qty+1}
    Spacer grow
    Button "Add to cart" onTap={emit add; toast "Added"}

state choice=""
Card gap=8
  Text.title "How was your stay?"
  Row gap=8
    ChoiceChip "Great" onTap={choice="great"}
    ChoiceChip "Okay" onTap={choice="okay"}
    ChoiceChip "Poor" onTap={choice="poor"}
  if choice!=""
    Text.muted "Thanks, you chose {choice}."
$components$composing$pages''';
}

/// What opens the open-vocabulary prompt: the vocabulary is open, the
/// grammar is not.
const String notationOpenPreface = '''
You write a user interface in a compact notation. What follows teaches its GRAMMAR and its CORE words (layout, text, the basic controls, state, events, conditions, loops, pages and overlays). The core is small on purpose.

The vocabulary is open. Whenever the UI needs a part or a behaviour the core has no word for, write the word you would expect to exist, as if it existed: a capitalised type with the text, key=value parameters, on… events and children you would expect it to take (a chat bubble, a seat map, a timeline, a waveform, a table, a rating), or the action you would expect in an event (copy, focus). Choose the name and the parameters that read most naturally and that another model would most likely choose too. Do not build such a part out of boxes and do not explain it; do not hold back from a word because it is not listed. The grammar is not open: every line follows it exactly.

''';

/// What the open prompt asks after [notationOpenPreface]: every word the
/// answer invents, defined in the notation after its last screen
/// (docs/design/20-defined-words.md; the vocabulary loop's Review 4, D19).
/// Each example expands with no issue (a test reads them from here).
const String notationDefinePreface = '''
Every word you use that is not taught below, define after the last screen, so the answer is complete in itself. A definition is written in this notation: at the margin, `define` and the word as a line would use it, each value its default; under it, indented, the lines it stands for, built from the words taught below and your other defined words. Those lines read the word's strings and parameters by name in braces. @color in the signature is the value a use binds (@picked): a control in the lines keeps it with @color, the lines read it as {color}, an action sets it (color=swatch); open=@ names a further one. An event the word gives is the actions of the line that fires it: onTap={onPick}, or onTap={onPick(value)} to pass value as result. `...` on a line of its own is where the lines written under a use go. For example:

define StickyNote "text" fill=#FFFDE68A w=180 h=140 onTap
  Column w={w} h={h} pad=14 gap=6 fill={fill} radius=4 onTap={onTap}
    Text "{text}"

define ColorPicker @color swatches=["#FF111827","#FFDC2626","#FF2563EB"] size=28 onPick
  state color=""
  Row gap=8 middle
    each swatch in swatches
      Box w={size} h={size} radius={size/2} fill={swatch} border={swatch == color ? 2 : 0} onTap={color=swatch; onPick(swatch)}

define Group "title"
  Card gap=8 pad=16
    Text.strong "{title}"
    ...

Define each word once, however many screens use it, and none of the words taught below. A definition draws and does what the words taught below can, and reads every parameter and runs every event it names. What they cannot express (a camera, a real map, sound, a surface things are dragged about on), declare with `primitive` in place of `define`: the same signature, a // line above it saying what it does, and under it nothing (a labelled box stands in) or the lines of how it looks meanwhile.

''';

/// What the glossary of the open prompt says before the names (the wording
/// of the glossary experiment, the vocabulary loop's Review 6).
String notationGlossaryLead({bool define = true}) => define
    ? 'These words already exist, beyond the ones taught below. Use one as you would expect it to work (its text, the parameters and events its name suggests) and do not define it; define only a word that is in neither list:'
    : 'These words already exist, beyond the ones taught below. Use one as you would expect it to work (its text, the parameters and events its name suggests):';

/// The names [designSystem] has beyond what the open [prompt] teaches: its
/// components and the words [vocabulary] defines in the notation, sorted,
/// leaving out a type of the notation, a page word and any name the prompt
/// already writes (`Button`, `Card`, and the define examples' `StickyNote`).
List<String> notationGlossary(DesignSystem designSystem, NotationVocabulary vocabulary, {required String prompt}) {
  final names = {for (final c in designSystem.list) c.type, ...vocabulary.definitions.keys};
  bool taught(String n) =>
      notationTypes.containsKey(n) ||
      PageWords.words.contains(n) ||
      RegExp('(?<![A-Za-z0-9_])${RegExp.escape(n)}(?![A-Za-z0-9_])').hasMatch(prompt);
  return [for (final n in names) if (n.isNotEmpty && n[0] == n[0].toUpperCase() && !taught(n)) n]..sort();
}

/// What the glossary of signatures says before its lines (the open prompt's
/// last section, [notationPrompt] with `signatures`).
String notationSignaturesLead(String name, {bool define = true}) => '''

WORDS THAT ALREADY EXIST ($name, beyond the ones taught above)
  One line each, as a line uses it: its strings in quotes, @value when it keeps a value (a use binds it: @name), key=@ for a further variable, its parameters (=a default where it tells the kind: a number, true or false, a list [], a record {}, a colour #…, one of a|b; ! must be given), its events, ... when it takes lines under it (...Front: under a Front line), and after the colon what it is. Use one as it is written here${define ? ' and do not define it. When you need one in another shape, define your own word under its name or another rather than bend the line: your definition replaces it in your answer (the words taught above cannot be replaced)' : ''}.''';

/// The lines of the open prompt's glossary of signatures: for each word
/// [designSystem] has beyond what the open [prompt] teaches (the names
/// [notationGlossary] gives), one line as a line uses it, with what it is for
/// in a few words ([notationGlossaryComponentLine],
/// [notationGlossaryDefinitionLine]). A word defined with several meanings has
/// a line for each; a component's word, a line for the component and one for
/// each meaning a definition names (`Stepper#steps`).
List<String> notationGlossaryLines(DesignSystem designSystem, NotationVocabulary vocabulary, {required String prompt}) {
  final components = {for (final c in designSystem.list) c.type: c};
  return [
    for (final n in notationGlossary(designSystem, vocabulary, prompt: prompt)) ...[
      if (components[n] case final c?) notationGlossaryComponentLine(c),
      for (final d in vocabulary.definitions[n] ?? const <NotationDefinition>[])
        if (!components.containsKey(n) || d.name != null) notationGlossaryDefinitionLine(d),
    ],
  ];
}

/// [component] as the glossary of signatures lists it: `Counter "label"
/// "detail" @value min max step=1 icon onChange : number raised and lowered
/// with minus and plus`.
String notationGlossaryComponentLine(DesignSystemComponent component) {
  final spec = component.spec;
  final strings = notationStrings(spec);
  final held = spec.props.where((p) => p.type.isVariable && p.key == 'value').firstOrNull ?? spec.props.where((p) => p.type.isVariable).firstOrNull;
  String kind(PropDef<Object?> p) {
    final v = p.defaultValue;
    switch (p.type.kind) {
      case PropKind.boolean:
        return '=${v == true}';
      case PropKind.integer || PropKind.number:
        return v is num ? '=${v == v.roundToDouble() ? v.round() : v}' : '';
      case PropKind.enumeration:
        final values = p.type.values;
        return values.length <= 4 && values.join('|').length <= 30 ? '=${values.join('|')}' : (v is String && v.isNotEmpty ? '=$v' : '');
      case PropKind.list:
        return '=[]';
      case PropKind.object || PropKind.json:
        return v is List ? '=[]' : (v is Map ? '={}' : '');
      case PropKind.value:
        return p.type.name == 'Color' ? '=#…' : '';
      case PropKind.string:
        return '';
    }
  }

  final parts = [
    spec.type,
    for (final k in strings) '"$k"',
    if (held != null) '@${held.key}',
    for (final p in spec.props)
      if (!strings.contains(p.key) && p.key != held?.key) p.type.isVariable ? '${p.key}=@' : (p.required ? '${p.key}!' : '${p.key}${kind(p)}'),
    for (final e in spec.events) e.key == 'onChanged' ? 'onChange' : e.key,
    if (spec.children == ChildModel.list || spec.slots.isNotEmpty) '...',
  ];
  return '${parts.join(' ')} : ${_gist(component.purpose)}';
}

/// [d] as the glossary of signatures lists it: its signature with its
/// defaults shortened to their kind (`fill=#…`, `items=[]`; a text's is left
/// out), its slots and what its `//` line says it is, in a few words.
String notationGlossaryDefinitionLine(NotationDefinition d) {
  String shown(String? v) {
    if (v == null) return '';
    if (v == 'true' || v == 'false' || RegExp(r'^-?\d+(\.\d+)?$').hasMatch(v)) return '=$v';
    if (v.startsWith('[')) return '=[]';
    if (RegExp(r'^\{\s*"').hasMatch(v)) return '={}';
    if (v.startsWith('#')) return '=#…';
    return '';
  }

  final parts = [
    '${d.word}${d.variants.map((v) => '.$v').join()}',
    for (final s in d.strings) '"$s"',
    if (d.bind != null) '@${d.bind}${shown(d.bindDefault)}',
    for (final e in d.parameters.entries)
      d.bindables.contains(e.key) ? '${e.key}=@${shown(e.value).replaceFirst('=', '')}' : (d.required.contains(e.key) ? '${e.key}!' : '${e.key}${shown(e.value)}'),
    ...d.events,
    for (final s in d.slots) '...$s',
  ];
  return d.doc.isEmpty ? parts.join(' ') : '${parts.join(' ')} : ${_gist(d.doc)}';
}

/// What a word is for, in about five words: the head of [text]'s first
/// sentence, up to its first clause that says enough, at most seven words,
/// without its article and without a word left hanging (`of`, `a`).
///
/// A text that starts with a question word (`Where a page is: …`, `What a
/// page with unsaved changes shows at its foot …`) names its word by a whole
/// clause that ends with its verb: it is cut only where that clause ends
/// (`: `, `; `, ` (`, ` — `), never inside it at a comma or a `with`, an
/// enumeration in it is shortened to its first item (`a list, a table or a
/// pane` is `a list`), and when it fits in seven words its last word is kept
/// (`where a page is`, not `where a page`).
String _gist(String text) {
  var s = text.trim();
  final end = RegExp(r'[.!?](\s|$)').firstMatch(s);
  if (end != null) s = s.substring(0, end.start);
  s = s.replaceFirst(RegExp(r'^(A|An|The) '), '');
  final clause = RegExp(r'^(What|Where|When|How|Who|Which|Whatever)\b', caseSensitive: false).hasMatch(s);
  const most = 7;
  int words(String t) => t.trim().split(RegExp(r'\s+')).length;
  for (final cut in clause ? const [': ', '; ', ' (', ' — '] : const [': ', '; ', ' (', ' — ', ', ', ' with ']) {
    if (words(s) <= most) break;
    final i = s.indexOf(cut);
    if (i > 0 && words(s.substring(0, i)) >= (cut == ': ' ? 2 : 3)) s = s.substring(0, i);
  }
  if (clause && words(s) > most) {
    s = s.replaceFirst(RegExp(r'(, (?:an?|the|its) [\w-]+)+,? (?:or|and) (?:an?|the|its) [\w-]+'), '');
  }
  var w = s.trim().split(RegExp(r'\s+'));
  const articles = {'a', 'an', 'the'};
  if (clause && w.length <= most) return _lowerFirst(w.join(' ').replaceAll(RegExp(r'[,:;(]+$'), ''));
  if (w.length > most) {
    w = w.take(most).toList();
    // Cut mid-phrase (`as a small`): to before its article.
    final article = w.lastIndexWhere((x) => articles.contains(x.toLowerCase()));
    if (article >= w.length - 2 && article > 1) w = w.take(article).toList();
  }
  const hanging = {...articles, 'of', 'to', 'for', 'as', 'in', 'on', 'with', 'and', 'or', 'at', 'by', 'from', 'is', 'that', 'which', 'its', 'their', 'one', 'two', 'over', 'under', 'between', 'into', 'than', 'when', 'where', 'while', 'if'};
  while (w.length > 2 && hanging.contains(w.last.toLowerCase())) {
    w.removeLast();
  }
  return _lowerFirst(w.join(' ').replaceAll(RegExp(r'[,:;(]+$'), ''));
}

String _lowerFirst(String s) => s.isEmpty ? s : '${s[0].toLowerCase()}${s.substring(1)}';

/// How the open prompt teaches drawing (a page's prompt, after its types):
/// a `customPaint` line under a Box and a line per shape. The indented
/// example expands with no issue and draws (a test reads it from here).
const String notationPaintLines = '''
  A picture (an illustration, a diagram, a dial) is drawn, never stacked from boxes: under a Box a customPaint line, under it a line per shape in the viewBox's units, the later over the earlier:
    Box w=240 h=160
      customPaint viewBox=[240,160] fit=contain
        rect rect=[0,0,240,160] fill=#FFE8F1F8
        circle c=[180,50] radius=24 fill=#FFF4B740
        path d="M0 160 L70 60 L120 120 L160 80 L240 160 Z" fill=#FF2563EB
        line p1=[0,150] p2=[240,150] stroke=#FF5D6D7E strokeWidth=2
  Also rrect (rect= radius=), oval rect=, arc rect= startAngle=0 sweepAngle=3.14, paragraph "Peak" offset=[8,8] style.color=#FF…; each takes fill= or stroke= strokeWidth=. A number may be {an expression}; repeat count={length(list)} draws its lines for each index (rect=[{index*10},0,6,{list[index]}]). viewBox is plain numbers; fit=contain keeps its shape.''';

/// How the open prompt teaches a part whose lines differ on a phone (where
/// rows and columns side by side are taught): an `at phone` block, its
/// `...#id` lines placing the part's own again. The indented example expands
/// with no issue (a test reads it from here).
const String notationAtPhoneLines = '''
  Where a part's lines differ on a phone, write at phone after its own lines and under it the lines it has there; ...#id places its line with that id again. Reach for this before a second copy with show=phone; one value that differs is a prefix on its key (phone.gap=8).
    Row gap=12 middle
      Text.heading2#title "Dishes"
      Select#kind @kind items=["All","Veg"]
      Input#find "Search" @q
      at phone
        Column grow gap=8
          ...#title
          Row gap=8
            ...#kind
            ...#find
  at tablet too (the wider first); never directly under each, if, Grid or App, nor in a definition.''';

/// The taught prompt without what is vocabulary: the `{…}` escape and the
/// reference pages (an unknown word is written, not escaped to JSON), and
/// the behaviour words of a page (a shortcut, a range, a calendar, a table,
/// a reordered list, swipe actions: each is a word a model reaches for by
/// some name, which the alias table maps).
String _openPrompt(String taught, {bool define = true}) {
  final out = <String>[];
  // A window, not a card: the card's prompt has no room for drawing.
  final page = taught.contains('\nPAGES (');
  var behaviours = false, beyond = false;
  for (final line in taught.split('\n')) {
    final l = line.trimRight();
    // The behaviour words: the block under "Also, on a page:".
    if (l.startsWith('  Also, on a page:')) {
      behaviours = true;
      continue;
    }
    if (behaviours && l.startsWith('    ')) continue;
    behaviours = false;
    // The reference pages beyond the notation, to the blank line after them.
    if (l == 'BEYOND THESE WORDS') {
      beyond = true;
      continue;
    }
    if (beyond) {
      beyond = l.isNotEmpty;
      continue;
    }
    // What the notation has for what writers invent words for (a
    // KeyboardShortcut, a LiveStatus, a Clock, a search field): said in a
    // line each, where the lines it belongs with are.
    if (l.startsWith('- every 1000 onTick=')) {
      out
        ..add(line)
        ..add('- key mod+k onPress={focus search} on its own line (top level) is a shortcut of the whole screen (mod: Ctrl, ⌘ on a Mac).');
      continue;
    }
    // A value worked out, and a formula of the writer's own (a `primitive`
    // is a part, not a function: one written as a function is refused).
    if (l.startsWith('- state name=value on its own line (top level) declares')) {
      out.add(
          '$l state total:decimal={price*qty} is worked out and kept up to date, always with its type (:integer, :text, :boolean, :list); with parameters it is your own function, not named as a listed one: state fits(c):boolean={kind=="All" || c.kind==kind}, then each c in filter(cards,c=>fits(c)).');
      continue;
    }
    if (l.startsWith('- Beyond these words:') ||
        l.startsWith('  key mod+k onPress=') ||
        l.startsWith('  device.hover is true') ||
        l.startsWith('    Dialog#edit "Edit" guard=') ||
        l.startsWith('    Text "About Mara" preview=') ||
        // The events of a design system's block: its line in the list of
        // words that already exist names them.
        l.startsWith("  A block's events are on its line") ||
        // Said by the at phone lines, where rows are taught.
        l.startsWith("    A part's lines on a phone go in a block") ||
        // What reflow does, said above it already.
        l.startsWith('    A Row of two Columns that grow') ||
        // Shown by the examples.
        l.startsWith('  Inside a frame everything is written as on a card')) {
      continue;
    }
    // An id written again on a copy for another size, and state and
    // overlays outside their screen's ### line.
    if (l == '- #id only when something else names the node.') {
      out
        ..add('- #id only when something else names the node; each id once in the answer, copies for other sizes included.')
        ..add('- Several screens: each starts at a ### line, with its own state lines and overlays under it, before the next ###.');
      continue;
    }
    out.add(line
        .replaceFirst('; confirm "Delete 2 clips?" "They cannot be restored." ok="Delete" danger then {clips=[]} else {toast "Kept"} asks first (a line of detail under it, the word on its yes button, danger for a red one; else: what a no does); announce "{n} results" tells a screen reader (Text "{n} results" live: each change); focus search puts the caret in Input#search; copy "{link}" copies a text',
            '; announce "{n} results" tells a screen reader (Text "{n} results" live: each change); focus search puts the caret in Input#search')
        .replaceFirst('for the quiet buttons it hides (', 'for the quiet buttons it hides (Input#search "Search" icon="search" @q is a search field, in a bar too; ')
        .replaceFirst(' (stops=[0.5,0.9]: heights it rests at; stop=@at: the one it is at)', '')
        .replaceFirst(' today(), formatDate(', ' today(), now() (the time), formatDate(')
        // A one-time code is one field (six one-digit Inputs were written).
        .replaceFirst('Input "Note" multiline is a text area.', 'Input "Note" multiline is a text area; CodeInput "Code" @code length=6 digits is a one-time code, one field drawn as boxes.')
        .replaceFirst('; Popover#bio arrow points at it', '')
        .replaceFirst(', ${notationPageFunctions.join(', ')}', '')
        // A main string from a variable, and a text with braces of its own.
        .replaceFirst('{name} inside a string shows a variable: "Total: {total}".',
            '{name} inside a string shows a variable ("Total: {total}"), also as the whole string (Icon "{c.icon}", never Icon c.icon); a text with braces of its own is a formula\'s string: Text "{\'if (x) { y }\'}".')
        // The keys writers guess: a Select's value, a chart's lists.
        .replaceFirst('Select and SegmentedButton take items=["A","B"] (', 'Select and SegmentedButton take items=["A","B"] and keep the chosen one in @name (')
        .replaceFirst(' On a page a Donut draws its labels as a legend beside it (under it where there is no room), each with its share: write no legend of your own (legend=false leaves it out).',
            ' A Donut draws its own legend: write none (legend=false leaves it out). A chart follows the state through values={map(rows,r=>r.n)} (a BarChart\'s labels={…} too); a LineChart\'s labels and series and a Donut\'s lists are written out.')
        // Said twice, or what a writer works out.
        .replaceFirst(' "{page+1} of {length(items)}" says which page it is.', '')
        .replaceFirst(' (Gauge {speed} follows a variable)', '')
        .replaceFirst(' onSwipeLeft={…} runs on that swipe.', '')
        .replaceFirst(' (go case-study: an id may have hyphens; go {replace(lower(result)," ","_")} works the page out, in braces, as from a SiteNav\'s link)', ' (go {expression} works the page out)')
        .replaceFirst(' A sidebar\'s item: Row w=fill gap=10 middle pad=[10,7,10,7] radius=6 selected={tab=="orders"} selected.fill=#142563EB onTap={tab="orders"}, an Icon and a Text grow under it. A link:', ' A link:')
        .replaceFirst(' ("variables": {"cart": [], "plan": "pro", "draft": {"value": "", "persist": true}})', '')
        // A table is a word a writer writes, not rows of boxes.
        .replaceFirst(' A table\'s row is a Row whose cells have widths (Text "Status" w=90) and one cell that grows, its header written the same way.', '')
        .replaceFirst(' (shown on hover, focus or a touch hold)', '')
        .replaceFirst(' It reads and sets the page\'s values: a form in a dialog sets them and closes (onTap={saved=true; close}).', '')
        .replaceFirst(': swiped or stepped with its arrows, with a count and thumbnails, opened at the one tapped', ', swiped or stepped, opened at the one tapped')
        .replaceFirst(' (a wide picture, a map)', '')
        .replaceFirst(' is declared once, in site.json\'s variables, a name and its starting value; a page expanded beside that site.json reads and sets it by name with no declaration (project cart=[] before the page says so on the page itself): it is read and set like any other (Select @cart, onTap={cart=append(cart,item)}) and keeps its value from page to page.',
            ' is declared once in site.json\'s variables, or by project cart=[] before the page: read and set like any other, it keeps its value from page to page.')
        .replaceFirst(' (project cart=[] saved, with "persist": true in site.json)', ' (project cart=[] saved)')
        .replaceFirst('hide=phone leaves a node out on a phone, hide=tablet on a tablet and a phone; show=phone shows it on a phone only, show=tablet on a tablet and a phone only.', 'hide=phone leaves a node out on a phone (hide=tablet: on a tablet too); show=phone shows it on a phone only (show=tablet: a tablet too).')
        .replaceFirst(' keeps an enrol panel or a table of contents in view while the page scrolls.', ' keeps it in view.')
        .replaceFirst(' (Section#pricing, or id=pricing on a line)', ' (Section#pricing)')
        .replaceFirst(' Row between spreads its children end to end.', '')
        .replaceFirst(' (w=240): the name, a Row per item, Spacer grow, then what sits at its foot', ' (w=240)')
        .replaceFirst(' a details panel): Pane w=320 pad=16 gap=12', ' a details panel; pad=16 gap=12)')
        .replaceFirst(' They hold on a line under an if too: the condition counts only where the size shows the line.', ''));
    if (page && l.startsWith('  Only Row, Column, Stack, Box, Card, Grid, Pages')) out.add(notationPaintLines);
    if (l.startsWith('  Side by side: Row gap=32')) out.add(notationAtPhoneLines);
  }
  return '$notationOpenPreface${define ? notationDefinePreface : ''}${out.join('\n')}';
}

/// How [component] is called in the notation, on one line, with what it is
/// for: `Stepper @value min max step label enabled onChanged : A number
/// changed one step at a time.`
String notationComponentLine(DesignSystemComponent component) {
  final spec = component.spec;
  final strings = notationStrings(spec);
  final held = spec.props.where((p) => p.type.isVariable && p.key == 'value').firstOrNull ??
      spec.props.where((p) => p.type.isVariable).firstOrNull;
  final rest = [
    for (final p in spec.props)
      if (!strings.contains(p.key) && p.key != held?.key) p.type.isVariable ? '${p.key}=@' : (p.required ? '${p.key}!' : p.key),
  ];
  final parts = [
    spec.type,
    for (final k in strings) '"$k"',
    if (held != null) '@${held.key}',
    ...rest,
    for (final e in spec.events) e.key,
    if (spec.children == ChildModel.list) '(children)',
    if (spec.children == ChildModel.none && spec.slots.isNotEmpty)
      '(lines: ${const ['trailing', 'actions', 'action', 'end'].firstWhere(spec.slots.contains, orElse: () => spec.slots.first)})',
  ];
  return '${parts.join(' ')} : ${component.purpose}';
}
