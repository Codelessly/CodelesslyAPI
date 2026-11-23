// Every form the page prompt teaches under "Also, on a page:" (the lines a
// writer looked up or reached for), the drawing's lines and the site rule's
// examples: each is expanded, as the prompt writes it, with no issue and
// with no word that stands in. A form the prompt teaches and the reader
// does not take is a write that fails for doing as it was told.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/prompt.dart' show notationLookedUpLines, notationPaintLines, notationReservedNamesRule, notationSiteRule;
import 'package:test/test.dart';

import 'notation_words.dart';

/// The state the taught lines read.
const _state = '''
state hour=2
state editing=false
state day=1
state picked=[]
state rows=[{"id":1}]
state read=0
state x=0
state y=0
state zoom=1
state held=false
state qty=1
state seen=false
state sel=""
state n=1
state start="2026-11-01"
state msgs=[{"id":"m1","name":"intro","n":1,"mine":true,"body":"A long note that runs on.","done":false}]
state events=[{"date":"2026-11-03","title":"Standup"}]
state shapes=[{"kind":"tree","x":20},{"kind":"rock","x":80}]
state list=[4,8,6]
''';

NotationResult _read(String text) => parseNotation(
      text,
      catalog: standardCatalog,
      options: withTestWords(NotationOptions.fromTheme(const {'primary': '#FF1F3A5F', 'surface': '#FFFFFFFF', 'onSurface': '#FF18181B'}, named: true, width: 1440).open(openVocabulary: true)),
    );

/// What the reader did not take of [text]: its issues, and the words that
/// stand in (a type, a key, a flag, an event, a verb, lines under a word
/// that takes none).
List<String> _notTaken(String text) {
  final r = _read(text);
  return [
    for (final i in r.issues) '${i.line}: ${i.message}',
    for (final u in r.vocabulary)
      if (const {'type', 'parameter', 'flag', 'event', 'variant', 'verb', 'children', 'missing'}.contains(u.kind)) '${u.line}: ${u.kind} ${u.word} (${u.source})',
  ];
}

/// The form a taught line starts with: to its first ": ".
String _head(String line) => line.split(': ').first;

/// [form] where a line of its kind is written: a line of the margin (a
/// key, an on load, a state, an overlay) after the state, a shape under a
/// drawing, any other under a Column (inside an each that names what the
/// taught lines read: m, r, c, s).
String _placed(String form) {
  if (RegExp(r'^(key |on load=|state )').hasMatch(form)) return '$_state$form\nColumn\n  Text "x"\n';
  if (RegExp(r'^(Sheet|Dialog|Drawer|Menu|Popover)#').hasMatch(form)) return '${_state}Column\n  Text "x"\n$form\n  Text "inside"\n';
  if (form.startsWith('customPaint')) return '${_state}Column\n  Box w=240 h=160\n    $form\n      circle c=[10,10] radius=4 fill=#FF000000\n';
  if (form.startsWith('repeat ')) return '${_state}Column\n  Box w=240 h=160\n    customPaint viewBox=[240,160]\n      $form\n        circle c=[{index*20},10] radius=4 fill=#FF000000\n';
  if (form.startsWith('if c.')) {
    return '${_state}Column\n  Box w=240 h=160\n    customPaint viewBox=[240,160]\n      each c in shapes\n        $form\n          circle c=[{c.x},10] radius=4 fill=#FF000000\n';
  }
  if (form.startsWith('each ')) return '${_state}Column h=400\n  $form\n    Text "{m.body}"\n';
  final leaf = RegExp(r'^(Text|Button|Input|Icon|Image|Handle|Divider)\b').hasMatch(form);
  // (A line placed by x= and y= is a Stack's.)
  if (RegExp(r'\sx=').hasMatch(form)) return '${_state}Stack h=240\n  $form\n';
  final item = RegExp(r'\b([mrs])\.').firstMatch(form)?[1];
  if (item == null) return '${_state}Column\n  $form\n${leaf ? '' : '    Text "x"\n'}';
  return '${_state}Column\n  each $item in ${item == 'r' ? 'rows' : 'msgs'}\n    $form\n${leaf ? '' : '      Text "x"\n'}';
}

void main() {
  group('each line under "Also, on a page:"', () {
    for (final line in notationLookedUpLines) {
      final form = _head(line);
      test('starts with a form the reader takes: $form', () {
        expect(_notTaken(_placed(form)), isEmpty, reason: _placed(form));
      });
    }
  });

  group('the forms those lines name after their first', () {
    void taken(String what, String text) => test(what, () => expect(_notTaken('$_state$text'), isEmpty, reason: text));

    taken('a place from the end in a Stack', 'Column\n  Stack h=120\n    Text "Corner" x={"end":8} y=8\n');
    taken('the keys by name, with a modifier', 'key PageDown onPress={day=day+7}\nkey shift+ArrowDown onPress={day=day+1}\nkey a onPress={day=1}\nkey 1 onPress={day=1}\nColumn\n  Text "{day}"\n');
    taken('a click with a key held', 'Column\n  each r in rows\n    Row onTap={picked=result.meta ? [] : result.alt ? [r.id] : picked}\n      Text "{r.id}"\n');
    taken('how far a node is scrolled, in pixels', 'Column scroll h=400 onScroll={read=result.offset}\n  Text "{read}"\n');
    taken('the speed a drag ends at', 'Column\n  Box w=40 h=40 onDrag={x=x+result.dx} onDragEnd={x=result.vx; y=result.vy}\n');
    taken('the theme\'s modes, and which is on', 'Column\n  Button "Light" onTap={setThemeMode light}\n  Button "System" onTap={setThemeMode system}\n  Text "{theme.isDark ? "Dark" : "Light"}"\n');
    taken('a text\'s font, and the window\'s width', 'Column\n  Text "…" fontFamily="Georgia" italic\n  Text "12" tabularFigures=true\n  if screen.width < 700\n    Text "Narrow"\n');
    taken('a drawing\'s shapes, as the line writes them', '''
Column
  Box w=240 h=160
    customPaint viewBox=[240,160] fit=contain
      rect rect=[0,100,240,60] fill=#FFE8F1F8
      circle c=[180,50] radius=24 fill=#FFF4B740
      path d="M0 160 L70 60 L240 160 Z" fill=#FF2563EB
      line p1=[0,150] p2=[240,150] stroke=#FF5D6D7E strokeWidth=2
      rrect rect=[10,10,40,20] radius=4 fill=#FF2563EB
      oval rect=[60,10,40,20] fill=#FF2563EB
      arc rect=[110,10,40,40] startAngle=0 sweepAngle=3.14 stroke=#FF2563EB strokeWidth=2
      paragraph "Peak" offset=[8,8] style.color=#FF111827
      circle c=[{hour*10},{20+hour}] radius={hour+2} fill=#FF000000
''');
    taken('a repeat\'s index, and one renamed', '''
Column
  Box w=240 h=160
    customPaint viewBox=[240,160]
      repeat count=12
        line p1=[{index*20+10},{80-(index*37%50)}] p2=[{index*20+10},{80+(index*37%50)}] stroke=#FF5D6D7E strokeWidth=2
      repeat count=12 indexAs=i
        circle c=[{i*20},10] radius=4 fill=#FF000000
      repeat count={length(list)}
        rect rect=[{index*10},0,6,{list[index]}] fill=#FF2563EB
''');
    taken('a drawing that follows its data: if, else if, else and each', '''
Column
  Box w=240 h=160
    customPaint viewBox=[240,160]
      each c in shapes
        if c.kind=="tree"
          circle c=[{c.x},40] radius=12 fill=#FF2F855A
        else if c.kind=="rock"
          rect rect=[{c.x},60,20,12] fill=#FF718096
        else
          line p1=[{c.x},0] p2=[{c.x},20] stroke=#FF000000 strokeWidth=1
''');
    taken('what runs once when the screen opens', 'on load={sel=first(msgs).id; day=today()}\nColumn\n  Text "{sel} {day}"\n');
    taken('a word of a line given a condition', 'Column center={n==1}\n  each m in msgs\n    Row end={m.mine}\n      Text "{m.body}"\n');
    taken('a variant chosen by an if', 'Column\n  each s in msgs\n    if s.done\n      Button.primary "Done"\n    else\n      Button.outline "Done"\n');
    taken('an id worked out for each copy, and a scroll to it', '''
Column
  Button "Go" onTap={scroll sec2}
  each m in msgs
    Column id={m.name}
      Text "{m.body}"
    Column id={"sec"+m.n}
      Button "Here" onTap={scroll {m.name}}
''');
    taken('what an overlay does as it closes', '''
Column
  Button "Open" onTap={open filters}
Sheet#filters "Filters" onClose={seen=true}
  Text "x"
Dialog#d "Sure?" onClose={seen=true}
  Text "x"
Drawer#w onClose={seen=true}
  Text "x"
Menu#m onClose={seen=true}
  Button "One"
Popover#p onClose={seen=true}
  Text "x"
''');
    taken('a press held, and hold-to-repeat', '''
every 120 when held onTick={qty=qty+1}
Column
  Box w=40 h=40 onPointerDown={held=true} onPointerUp={held=false}
''');
    taken('a line drawn larger, turned or moved, and its shadow', '''
Column
  Box scale=1.2 rotate=8 translateX=12 translateY=-4 shadow=small
  Box scale={zoom} shadow=small
  Box shadow=medium
  Box shadow=large
  Box shadow=none
''');
    taken('an each line\'s padding and gap, a formula for the mode, a literal brace, a grip\'s icon, no menu', '''
Column h=400
  each m in msgs follow grow pad=[24,16] gap=6
    Row menu=none
      Handle icon="menu"
      Text "A set is written \\{a, b\\}"
  Input "Mode" onSubmit={setThemeMode lower(result)}
''');
    taken('the dates, and a month\'s cell reading its events', '''
Column
  Text "{diffDays(start,today())} {weekday(start)} {daysInMonth(start)} {addMonths(start,1)}"
  each i in range(7)
    each e in filter(events,e=>e.date==addDays(start,i))
      Text "{e.title}"
''');
  });

  test('the drawing as the prompt writes it', () {
    final example = RegExp(r'\n(    Box w=240 h=160\n(?:      .*\n)+)').firstMatch(notationPaintLines)![1]!;
    final lines = [for (final l in example.trimRight().split('\n')) l.substring(4)];
    expect(_notTaken('${lines.join('\n')}\n'), isEmpty);
    // Its rectangle reads one way only, and the prompt says which.
    expect(example, contains('rect rect=[0,100,240,60]'));
    expect(notationPaintLines, contains('A rect is [left,top,width,height].'));
    expect(notationLookedUpLines.firstWhere((l) => l.startsWith('customPaint viewBox')), contains('(a rect is [left,top,width,height])'));
    final r = _read('Box w=240 h=160\n  customPaint viewBox=[240,160]\n    rect rect=[0,100,240,60] fill=#FFE8F1F8\n');
    final paint = (r.document['nodes'] as Map).values.map((n) => (n as Map)['customPaint']).whereType<Map>().single;
    expect('$paint', contains('[0, 100, 240, 60]'));
  });

  test('the site rule\'s examples', () {
    expect(_notTaken('define BudgetRow "name" spent=0 limit=100\n  Row\n    Text "{name}"\n    Text "{spent} of {limit}"\n'
        'define SiteNav "current"=home\n  Row\n    Text "{current}"\n'
        'state plan="pro"\nstate income=4800 saved\nstate spent=1200\nstate left={income-spent}\n'
        'state txns=[\n  {"id":1,"name":"Rent"},\n  {"id":2,"name":"Food"},\n]\n'
        'Column\n  SiteNav\n  SiteNav "budgets"\n  BudgetRow "Groceries" spent=320 limit=400\n  Text "{plan} {left} {length(txns)}"\n  Button "Go" onTap={go transactions}\n'
        ), isEmpty);
    expect(notationSiteRule, allOf(contains('"mode": "dark" beside it'), contains('"dark" holds the colours that differ in the dark')));
  });

  test('the names a state may not take: each is refused, and the prompts say them', () {
    final names = RegExp(r'the runtime has: ([a-z, ]+)\.').firstMatch(notationReservedNamesRule)![1]!.split(', ');
    expect(names, ['data', 'route', 'storage', 'screen', 'theme', 'auth', 'drag', 'perf', 'script', 'speech', 'device']);
    for (final name in names) {
      final r = _read('state $name=1\nColumn\n  Text "x"\n');
      expect(r.issues.map((i) => i.message), [startsWith('$name is ')], reason: name);
    }
    expect(_notTaken('state themeName="light"\nstate unread=3\nColumn\n  Text "{themeName} {unread}"\n'), isEmpty);
    // A page's prompt says them in a line; its open prompt (which has no
    // such line) with the state line.
    const page = NotationOptions(width: 1440);
    expect(notationPrompt(catalog: standardCatalog, options: page), contains(names.join(', ')));
    expect(notationPrompt(catalog: standardCatalog, options: page, open: true), contains(notationReservedNamesRule));
  });
}
