// What a page of an app still owes (`notationUndeclaredNames`): only names
// the app's own writing has and nothing declares. Each case is a line a
// writer wrote whose name was listed as undeclared for a whole run though
// the page declared it, or though no file of the app has it.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/notation_site.dart';
import 'package:codelessly_api/src/core/notation/prompt.dart' show notationLookedUpLines, notationPageFunctions, notationSiteRule;
import 'package:test/test.dart';

NotationResult _page(String text) => parseNotation(text, catalog: standardCatalog, options: const NotationOptions(width: 1440));

({NotationResult page, List<String> owed, List<String> drawn}) _site(Map<String, String> files, {String path = 'pages/home.txt'}) {
  final site = NotationSiteFiles(files, catalog: standardCatalog);
  final page = NotationSiteExpander(site, catalog: standardCatalog).expandPage(path);
  final drawn = <String>[];
  final owed = notationUndeclaredNames(
    page.document,
    text: files[path]!,
    known: {...site.variables.keys, ...site.screens, ...site.definedWords.keys, ...site.sources.keys},
    others: [
      for (final e in files.entries)
        if (!e.key.startsWith('pages/') && e.key != 'site.json') e.value,
    ],
    drawing: drawn,
  );
  return (page: page, owed: owed, drawn: drawn);
}

List<String> _variables(NotationResult r) => [
      for (final scope in (r.document['variables'] as Map? ?? const {}).values)
        for (final v in scope as List) '${(v as Map)['name']}',
    ];

void main() {
  group('a worked-out value read by a line of the screen', () {
    const page = '''
state idx=0
state list={filter(stories,s=>s.section!="Sport")}
state n={length(list)}
state cur={idx<n ? list[idx] : stories[0]}
key ArrowDown when={idx<n} onPress={idx=idx+1}
key Enter when={idx<n} onPress={idx=min(n,idx+1)}
every 1s when idx<n onTick={idx=idx+1}
on load={idx=n-1}
Column
  Text "{n} stories, {cur.head}"
''';

    test('is written out in a key, an every and an on load line, as on a node\'s line', () {
      final r = _page('state stories=[{"section":"News","head":"A"}]\n$page');
      expect(r.issues.map((i) => '${i.line}: ${i.message}'), isEmpty);
      final reactions = jsonEncode(((r.document['nodes'] as Map).values.firstWhere((n) => (n as Map)['type'] == 'canvas') as Map)['actions']);
      // No bare name left where the formula belongs: each is the list's length.
      expect(RegExp(r'(?<![A-Za-z0-9_.])n(?![A-Za-z0-9_(])').hasMatch(reactions.replaceAll(RegExp(r'"[a-zA-Z]+":'), '')), isFalse, reason: reactions);
      expect('length((filter(stories'.allMatches(reactions).length, greaterThanOrEqualTo(4));
      expect(_variables(r), isNot(contains('n')));
    });

    test('a key that has the name of a worked-out value is still that key', () {
      final r = _page('state cur=3\nstate m={cur+12}\nstate load={cur*2}\nkey m onPress={cur=m+1}\non load={cur=load}\nColumn\n  Text "{m}"\n');
      expect(r.issues.map((i) => '${i.line}: ${i.message}'), isEmpty);
      final reactions = jsonEncode(((r.document['nodes'] as Map).values.firstWhere((n) => (n as Map)['type'] == 'canvas') as Map)['actions']);
      expect(reactions, allOf(contains('"key":"m"'), contains('(cur+12)+1'), contains('"type":"load"'), contains('(cur*2)')));
    });

    test('is not owed: the page states it', () {
      final got = _site({'pages/home.txt': page, 'app.txt': 'state stories=[\n  {"section":"News","head":"A"},\n]\n'});
      expect(got.page.issues, isEmpty);
      expect(got.owed, isEmpty);
      // Before app.txt, what is owed is the app's list, and only that.
      expect(_site({'pages/home.txt': page}).owed, ['stories']);
    });

    test('a record worked out and read by a key\'s actions (cook mode\'s r)', () {
      const cook = '''
state cookStep=0
state r={find(recipes,x=>x.id==cur)}
key ArrowRight onPress={cookStep=min(length(r.steps)-1,cookStep+1)}
key ArrowLeft when={cookStep>0} onPress={cookStep=cookStep-1}
Column
  Text "{r.name}: step {cookStep+1} of {length(r.steps)}"
''';
      final got = _site({'pages/cook.txt': cook, 'app.txt': 'state cur="a"\nstate recipes=[\n  {"id":"a","name":"Dal","steps":["Rinse","Simmer"]},\n]\n'}, path: 'pages/cook.txt');
      expect(got.page.issues, isEmpty);
      expect(got.owed, isEmpty);
    });
  });

  group('a name no file of the app has is not owed', () {
    test('what a row hands the word it calls, under the name of the each\'s own item (Bubble m={m})', () {
      const bubble = '''
define Bubble m={}
  Row w=fill gap=8
    Column gap=4 menu=msgMenu onTap={pick=m.id}
      Text "{m.text}"
''';
      const home = '''
state pick=""
Column
  each m in filter(msgs,m=>m.convo==sel)
    Bubble m={m}
Menu#msgMenu
  Row gap=10 pad=8 onTap={msgs=removeWhere(msgs,x=>x.id==pick)}
    Text "Delete"
''';
      final got = _site({'pages/home.txt': home, 'components/Bubble.txt': bubble, 'app.txt': 'state sel="a"\nstate msgs=[\n  {"id":"1","convo":"a","text":"Hi"},\n]\n'});
      expect(got.owed, isEmpty, reason: 'm is the each\'s item; variables: ${_variables(got.page)}');
      // Without app.txt, the app's own names are still owed.
      expect(_site({'pages/home.txt': home, 'components/Bubble.txt': bubble}).owed, containsAll(['msgs', 'sel']));
    });

    test('a name a component reads is owed until app.txt declares it, though the page\'s text never writes it', () {
      const composer = 'define Composer\n  Row gap=8\n    Input "Message" @draft grow\n    Button "Send" onTap={sent=append(sent,draft)}\n';
      const home = 'Column\n  Composer\n';
      expect(_site({'pages/home.txt': home, 'components/Composer.txt': composer}).owed, containsAll(['draft', 'sent']));
      expect(_site({'pages/home.txt': home, 'components/Composer.txt': composer, 'app.txt': 'state draft=""\nstate sent=[]\n'}).owed, isEmpty);
    });

    test('a name the expansion made itself, in no file (a list beside its detail on a phone)', () {
      final document = <String, Object?>{
        'variables': {
          'page_variables': [
            {'name': 'sel', 'type': 'text', 'value': 'p1'},
            {'name': 'playlists_pane', 'type': 'integer', 'value': 0},
          ],
        },
        'nodes': {
          'playlists': {
            'type': 'canvas',
            'bind': {'props.blockBack': r'${= playlists_pane>0 && screen.width<=903}'},
            'actions': [
              {
                'trigger': {'type': 'backPressed'},
                'actions': [
                  {'type': 'setVariable', 'variable': 'playlists_pane', 'value': r'${= playlists_pane-1}'},
                ],
              },
            ],
          },
          'text1': {
            'type': 'text',
            'props': {'text': r'${= find(playlists,p=>p.id==sel).name} ${= missing}'},
          },
        },
      };
      const text = 'state sel="p1"\nApp\n  Main\n    Text "{find(playlists,p=>p.id==sel).name} {missing}"\n';
      expect(notationUndeclaredNames(document, text: text, known: const {'playlists'}, others: const []), ['missing']);
    });
  });

  group('a name read only inside a drawing', () {
    const home = '''
state step=4
Column
  each c in clips
    Box w=200 h=30
      customPaint viewBox=[200,30] fit=contain
        repeat count=50
          line p1=[{i*step+2},{15-(3+(i*37+c.id*11)%11)}] p2=[{i*step+2},{15+(3+(i*37+c.id*11)%11)}] stroke=#99101214 strokeWidth=2
''';

    test('is listed apart, not as state the app owes: a repeat\'s index is index', () {
      final got = _site({'pages/home.txt': home, 'app.txt': 'state clips=[\n  {"id":1},\n]\n'});
      expect(got.owed, isEmpty);
      expect(got.drawn, ['i']);
      // Written with the name the repeat gives, nothing is owed.
      final right = _site({'pages/home.txt': home.replaceAll('i*', 'index*'), 'app.txt': 'state clips=[\n  {"id":1},\n]\n'});
      expect(right.page.issues, isEmpty);
      expect(right.owed, isEmpty);
      expect(right.drawn, isEmpty);
    });

    test('with no list to take them, they are answered with the rest', () {
      final site = NotationSiteFiles({'pages/home.txt': home}, catalog: standardCatalog);
      final page = NotationSiteExpander(site, catalog: standardCatalog).expandPage('pages/home.txt');
      expect(notationUndeclaredNames(page.document, text: home), containsAll(['clips', 'i']));
    });
  });

  group('what the prompt says', () {
    final prompt = notationPrompt(catalog: standardCatalog, options: const NotationOptions(width: 1440), site: true);

    test('the theme is written right after the first page when the request names a look, and a dark app says so', () {
      expect(notationSiteRule, contains('then site.json when the request names a look'));
      expect(notationSiteRule, contains('write the theme right after the first page and app.txt, before any other page'));
      expect(notationSiteRule, contains('"mode": "dark"'));
      expect(notationSiteRule, isNot(contains('Write it last')));
      expect(notationSiteRule, isNot(contains('not at all when')));
      expect(prompt, contains(notationSiteRule));
    });

    test('the dates are among the functions that exist on a page, with how a month\'s cell reads its events', () {
      for (final f in ['addDays(date,n)', 'addMonths(date,n)', 'diffDays(from,to)', 'weekday(date)', 'daysInMonth(date)']) {
        expect(notationPageFunctions, contains(f));
        expect(prompt.split('\n').firstWhere((l) => l.contains('Only these functions exist')), contains(f));
      }
      final dates = notationLookedUpLines.firstWhere((l) => l.contains('formatDate(addDays'));
      expect(dates, allOf(contains('never numbered by hand'), contains('shown through formatDate'), contains('each e in filter(events,e=>e.date==addDays(start,i))')));
      expect(notationPrompt(catalog: standardCatalog, options: const NotationOptions(width: 390)), isNot(contains('addDays(date,n)')));
    });

    test('a repeat\'s index by its name, once at start, a screen that opens on its main case, a preview by lines', () {
      final lines = notationLookedUpLines.join('\n');
      expect(lines, contains('read by the name index and no other'));
      expect(lines, contains('one drawing repeated, or a gradient alone, is not a picture'));
      expect(lines, contains('on load={'));
      expect(lines, contains('never a timer made to run once'));
      expect(lines, contains('Start a screen on its main case'));
      expect(lines, contains('maxLines=2'));
      for (final line in notationLookedUpLines) {
        expect(line.length, lessThan(560), reason: line);
      }
    });

    // The forms these lines teach are read by the reader's own changes (a
    // drawing's if and each, a word given a condition, an id for each copy,
    // onClose, the press events, scale and shadow, an each line's padding):
    // that each expands with no issue is tested where those are.
    test('the forms a writer reached for are taught, a line each', () {
      final lines = notationLookedUpLines.join('\n');
      for (final said in [
        'beside state, every and key',
        'before its first picture',
        'data, route, storage, screen, theme, auth, drag, perf, script, speech, device',
        'inside a customPaint, if, else if, else and each x in list take shapes under them',
        'indexAs=i renames it',
        'A customPaint takes its size from the line it is under',
        'Row end={m.mine}',
        'Column center={n==1}',
        'under if s.done as Button.primary "Done" and under else as Button.outline "Done"',
        'id={"sec"+m.n}',
        'scroll {m.name} or scroll sec2',
        'onClose={seen=true}',
        'onPointerDown={…} as it starts and onPointerUp={…} as it ends',
        'onPointerDown={held=true} onPointerUp={held=false} with every 120 when held',
        'scale=1.2 rotate=8 translateX=12 translateY=-4 shadow=sm',
        'shadow is small, medium, large or none',
        'each m in msgs follow grow pad=[24,16] gap=6',
        'setThemeMode lower(result)',
        r'a literal brace in a text is \{ and \}',
        'Handle icon="menu"',
        'menu=none',
      ]) {
        expect(lines, contains(said));
        expect(prompt, contains(said));
      }
      expect(notationSiteRule, contains('define SiteNav "current"=home'));
      for (final line in notationLookedUpLines) {
        expect(line.length, lessThan(560), reason: line);
      }
    });

    test('each new line expands with no issue', () {
      String head(String start) => notationLookedUpLines.firstWhere((l) => l.startsWith(start)).split(': ').first;
      final wave = RegExp(r'\((line p1=\S+ p2=\S+ stroke=\S+ strokeWidth=\d) is a waveform\)').firstMatch(notationLookedUpLines.firstWhere((l) => l.startsWith('repeat count=')))!;
      final r = _page('''
state sel=""
state day=""
state start="2026-11-01"
state msgs=[{"id":"m1"}]
state events=[{"date":"2026-11-03","title":"Standup"}]
state n={"body":"A long note that runs on."}
${head('on load=')}
Column
  ${head('Text "{formatDate(')}
  Text "{diffDays(start,today())} {weekday(start)} {daysInMonth(start)} {addMonths(start,1)}"
  each i in range(7)
    each e in filter(events,e=>e.date==addDays(start,i))
      Text "{e.title}"
  ${head('Text "{n.body}"')}
  Box w=240 h=160
    customPaint viewBox=[240,160] fit=contain
      ${head('repeat count=')}
        ${wave[1]}
''');
      expect(r.issues.map((i) => '${i.line}: ${i.message}'), isEmpty);
    });
  });
}
