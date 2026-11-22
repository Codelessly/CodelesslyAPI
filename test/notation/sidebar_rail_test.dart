// A design system's rail (`sizes.rail` in its theme): an app's Sidebar
// written with no rule for other widths is a rail that wide at a tablet's
// width only when every line under it folds by itself there. A line folds
// when it is a component that declares a `rail` parameter, takes no width of
// its own, or says what it is at that width itself. A sidebar with a line
// written by hand (a Row of an Icon and a Text) is as wide as written there,
// as with no rail: at 64 its labels stood one letter a line.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Object? _sorted(Object? v) => switch (v) {
      final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
      final List l => [for (final e in l) _sorted(e)],
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
    };

/// A component of one row, with the parameters [props] (all texts but
/// `rail`, a boolean).
String _component(String name, List<String> props) => jsonEncode({
      'schema': 3,
      'id': name,
      'roots': ['r'],
      'widget': {
        'type': name,
        'doc': 'A line of a sidebar.',
        'props': [
          for (final p in props)
            p == 'rail'
                ? {'key': p, 'type': {'kind': 'boolean', 'flutter': 'bool'}, 'default': false}
                : {'key': p, 'type': {'kind': 'string', 'flutter': 'String'}, 'default': ''},
        ],
      },
      'nodes': {
        'r': {
          'type': 'row',
          'layout': {
            'width': {'fill': 0},
            'height': 32,
          },
        },
      },
    });

/// A design system whose sidebar words fold (NavItem and Brand declare
/// `rail`; Tile does not), with a rail of [rail] (null: none).
Future<({NotationOptions options, Catalog catalog})> _system({double? rail = 64, double width = 1440}) async {
  final files = {
    'design_system.json': jsonEncode({
      'id': 'acme',
      'name': 'Acme',
      'theme': {
        'sizes': {'sidebar': 248, 'rail': ?rail},
      },
      'components': ['components/NavItem.json', 'components/Brand.json', 'components/Tile.json'],
    }),
    'components/NavItem.json': _component('NavItem', ['label', 'icon', 'rail']),
    'components/Brand.json': _component('Brand', ['label', 'rail']),
    'components/Tile.json': _component('Tile', ['label']),
  };
  final ds = await DesignSystem.load((ref) async => files[ref]);
  return (options: NotationOptions.fromDesignSystem(ds, width: width), catalog: ds.catalogOver(standardCatalog));
}

const _main = '''
  Main
    Nav
      Text "Members"
    Table#t p in people columns=[{"key":"name","label":"Name"},{"key":"role","label":"Role","w":90},{"key":"teams","label":"Teams","w":170},{"key":"status","label":"Status","w":100},{"key":"menu","label":"","w":32}]
''';

const _state = 'state people:list=[{"name":"Ada","role":"Owner","teams":"Core","status":"Active"}]\n';

/// An app whose sidebar is [side] (its line and the lines under it, as
/// written under App).
String _app(String side, {String before = ''}) => '$before${_state}App\n$side\n$_main';

void main() {
  late ({NotationOptions options, Catalog catalog}) acme, plain;
  setUpAll(() async {
    acme = await _system();
    plain = await _system(rail: null);
  });

  NotationResult read(String text, {bool rail = true}) {
    final s = rail ? acme : plain;
    final r = Catalog.run(s.catalog, () => parseNotation(text, catalog: s.catalog, options: s.options));
    expect(r.issues, isEmpty, reason: text);
    return r;
  }

  Map<String, Object?> sidebar(NotationResult r) {
    final nodes = (r.document['nodes'] as Map).cast<String, Object?>();
    // (In a defined word's lines its id is the use's: found by its width.)
    return ((nodes['side'] ?? nodes.values.firstWhere((n) => (n! as Map)['type'] == 'column' && ((n as Map)['layout'] as Map?)?['width'] == 248))! as Map).cast<String, Object?>();
  }

  String media(NotationResult r) => jsonEncode(sidebar(r)['media'] ?? const []);

  const railRule = '{"maxWidth":1023,"patch":{"layout":{"width":64}}}';
  const phoneRule = '{"maxWidth":699,"patch":{"visible":false';

  Matcher isRail = allOf(contains(railRule), contains(phoneRule));

  const drawerRule = '{"maxWidth":1023,"patch":{"visible":false}}';

  /// The drawer at a tablet's width, as on a phone: hidden, with no rail.
  void isDrawer(String text) {
    final r = read(text);
    expect(media(r), isNot(contains('"width":64')), reason: text);
    expect(media(r), contains(drawerRule), reason: text);
    expect(media(r), contains(phoneRule), reason: text);
    expect(jsonEncode(r.document), contains('_sidebar'), reason: text);
  }

  /// A rail, in which the node [hidden] is not shown.
  void railWithout(String text, String hidden) {
    final r = read(text);
    expect(media(r), isRail, reason: text);
    final node = ((r.document['nodes'] as Map)[hidden]! as Map);
    expect(jsonEncode(node['media']), contains(drawerRule), reason: '$hidden is hidden where the sidebar is a rail: $text');
  }

  group('a sidebar with a line written by hand that does something is the drawer at a tablet, as on a phone', () {
    test('a row of an icon and a text that is tapped', () {
      isDrawer(_app('  Sidebar#side\n    Brand "Acme"\n    NavItem "Inbox" icon="inbox"\n    Row gap=8 middle onTap={toast "up"}\n      Icon "bolt"\n      Text "Upgrade"'));
    });

    test('a field, a list of rows that are tapped, a box with a button in it', () {
      isDrawer(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Input "Search" @q', before: 'state q=""\n'));
      isDrawer(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    each p in people\n      Row gap=8 onTap={toast "{p.name}"}\n        Text "{p.name}"'));
      isDrawer(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Box#note pad=12\n      Text "Storage is full"\n      Button "Upgrade" onTap={toast "up"}'));
    });

    test("a writer's word that is a row of its own, and a component with no rail parameter", () {
      isDrawer(_app('  Sidebar#side\n    NavTo "Inbox" icon="inbox"\n    NavTo "Sent" icon="send"',
          before: 'define NavTo "label" icon\n  Row w=fill gap=10 middle\n    Icon "{icon}" size=18\n    Text "{label}" grow\n'));
      isDrawer(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Tile "Storage"'));
    });

    test('a sidebar written in a defined word (the app\'s shell)', () {
      isDrawer(_app('  Shell', before: 'define Shell\n  Sidebar#side\n    Row gap=8 middle onTap={toast "t"}\n      Icon "shield"\n      Text "Tenant"\n    NavItem "Inbox" icon="inbox"\n'));
      expect(media(read(_app('  Shell', before: 'define Shell\n  Sidebar#side\n    Brand "Tenant"\n    NavItem "Inbox" icon="inbox"\n'))), isRail);
    });

    test('nothing under it folds and all of it only shows something: no empty rail', () {
      isDrawer(_app('  Sidebar#side\n    Text "About this app"\n    Box pad=8\n      Text "Version 2"'));
    });
  });

  group('a line that only shows something is hidden where its sidebar is a rail', () {
    test('a note in a box at the foot, a group label written as a text, an account row of an avatar and two texts', () {
      railWithout(_app('  Sidebar#side\n    Brand "Acme"\n    NavItem "Inbox" icon="inbox"\n    Spacer\n    Box#note fill=#FFFFF3C4 radius=16 pad=12\n      Text.strong "6-day streak"\n      Text.small "Study today to keep it going."'), 'note');
      railWithout(_app('  Sidebar#side\n    Text.caption#label "PEOPLE"\n    NavItem "Inbox" icon="inbox"'), 'label');
      railWithout(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Footer\n      Row#who gap=10 middle\n        Avatar "Ada Okafor"\n        Column\n          Text "Ada Okafor"\n          Text "Owner"'), 'who');
    });

    test('under an if; with a rule for a phone only', () {
      railWithout(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    if length(people) > 0\n      Text#some "People"'), 'some');
      railWithout(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Text#up "Upgrade" phone.size=12'), 'up');
    });

    test('the lines under it are not hidden a second time, and the drawer shows it', () {
      final r = read(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Box#note pad=12\n      Text#inner "Storage is full"'));
      final nodes = (r.document['nodes'] as Map);
      expect((nodes['inner'] as Map)['media'], isNull);
      expect(jsonEncode(r.document), contains('_sidebar'));
    });
  });

  test("a sidebar with a width rule of the writer's is untouched, folding lines or not", () {
    for (final lines in ['    NavItem "Inbox" icon="inbox"', '    Row gap=8\n      Icon "bolt"\n      Text "Upgrade"']) {
      for (final own in ['tablet.w=72 hide=phone', 'hide=phone', 'hide=tablet', 'w=64']) {
        final text = _app('  Sidebar#side $own\n$lines');
        expect(jsonEncode(_sorted(read(text).document)), jsonEncode(_sorted(read(text, rail: false).document)), reason: text);
      }
    }
  });

  group('a design at a width under the sidebar', () {
    const hand = '    Row#brand gap=8 middle onTap={toast "a"}\n      Icon "bolt"\n      Text "Acme"';
    test('a block that holds at a tablet is what the part shows there: its lines are the ones that fold', () {
      expect(media(read(_app('  Sidebar#side\n$hand\n    at tablet\n      NavItem "Acme" icon="bolt"'))), isRail);
      expect(media(read(_app('  Sidebar#side\n    NavItem "Acme" icon="bolt"\n    at tablet\n      Row gap=8 middle onTap={toast "a"}\n        Icon "bolt"\n        Text "Acme"'))), isNot(contains('"width":64')));
    });

    test('a block that holds on a phone only says nothing of a tablet', () {
      expect(media(read(_app('  Sidebar#side\n    NavItem "Acme" icon="bolt"\n    at phone\n      Row gap=8\n        Icon "bolt"\n        Text "Acme"'))), isRail);
      expect(media(read(_app('  Sidebar#side\n$hand\n    at phone\n      NavItem "Acme" icon="bolt"'))), isNot(contains('"width":64')));
    });
  });

  test('a table beside the sidebar has the room the sidebar leaves at a tablet: more beside a rail', () {
    String hidden(String side) {
      final r = read(_app(side));
      return jsonEncode([
        for (final n in (r.document['nodes'] as Map).values)
          if (jsonEncode((n as Map)['media'] ?? const []).contains('"maxWidth":1023,"patch":{"visible":false')) 1,
      ]);
    }

    final rail = hidden('  Sidebar#side\n    NavItem "Inbox" icon="inbox"');
    final wide = hidden('  Sidebar#side\n    Row gap=8\n      Icon "inbox"\n      Text "Inbox"');
    expect(jsonDecode(wide) as List, hasLength(greaterThan((jsonDecode(rail) as List).length)));
  });

  test('read as it arrives, the operations build the same document, a rail or not', () {
    for (final side in [
      '  Sidebar#side\n    Brand "Acme"\n    NavItem "Inbox" icon="inbox"',
      '  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Row gap=8 middle\n      Icon "bolt"\n      Text "Upgrade"',
      '  Sidebar#side\n    Row#brand gap=8\n      Icon "bolt"\n      Text "Acme"\n    at tablet\n      NavItem "Acme" icon="bolt"',
    ]) {
      final text = _app(side);
      final stream = Catalog.run(acme.catalog, () => NotationStream(catalog: acme.catalog, options: acme.options));
      var doc = LayoutDocument(catalog: acme.catalog);
      void apply(List<Json> ops) {
        if (ops.isEmpty) return;
        final a = applyOps(doc, {'ops': ops}, catalog: acme.catalog);
        expect(a.errors, isEmpty, reason: side);
        doc = a.document;
      }

      for (final line in const LineSplitter().convert(text)) {
        apply(Catalog.run(acme.catalog, () => stream.add('$line\n')));
      }
      apply(Catalog.run(acme.catalog, stream.close));
      final whole = read(text).document;
      final built = {
        ...doc.toJson(),
        for (final e in stream.result!.document.entries)
          if (!const {'nodes', 'roots', 'variables'}.contains(e.key)) e.key: e.value,
      };
      // (A scope the stream declared and left with no variable is no difference.)
      String model(Json d) {
        final json = LayoutDocument.fromJson(d, catalog: acme.catalog).toJson();
        if (json['variables'] case final Map scopes) json['variables'] = {...scopes}..removeWhere((_, v) => v is List && v.isEmpty);
        return jsonEncode(_sorted(json));
      }

      expect(model(built), model(whole), reason: side);
    }
  });

  test('printed and read back, the page is the same document, a rail or not', () {
    for (final side in [
      '  Sidebar#side\n    Brand "Acme"\n    NavItem "Inbox" icon="inbox"',
      '  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Row gap=8 middle onTap={toast "up"}\n      Icon "bolt"\n      Text "Upgrade"',
    ]) {
      final doc = read(_app(side)).document;
      final text = Catalog.run(acme.catalog, () => printNotation(doc, catalog: acme.catalog));
      // The rail is on the printed line as its rules; with no rail, no rule.
      expect(text.contains('tablet.w=64'), side.contains('Brand'), reason: text);
      final back = Catalog.run(acme.catalog, () => parseNotation(text, catalog: acme.catalog, options: notationOptionsFor(doc)));
      expect(jsonEncode(_sorted(back.document)), jsonEncode(_sorted(doc)), reason: text);
    }
  });

  test('a page written for a phone is the same with the rail and without it', () async {
    final phone = await _system(width: 390), phonePlain = await _system(rail: null, width: 390);
    final text = _app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"');
    NotationResult at390(({NotationOptions options, Catalog catalog}) s) =>
        Catalog.run(s.catalog, () => parseNotation(text, catalog: s.catalog, options: s.options));
    expect(jsonEncode(_sorted(at390(phone).document)), jsonEncode(_sorted(at390(phonePlain).document)));
  });

  // A word folds because its sidebar is a rail, not because the window is a
  // tablet's: the sidebar's rule is handed to each component under it that
  // declares `rail`, with `rail` in place of the width.
  group('the components under a sidebar are told where it is a rail', () {
    /// The rules of the nodes of [type] that set `rail`, and the `rail`
    /// each is written with, one entry a node.
    /// Those under the sidebar, or with [drawer] the others (the copies in
    /// the drawer a phone opens).
    List<String> told(NotationResult r, String type, {bool drawer = false}) {
      final nodes = (r.document['nodes'] as Map).cast<String, Object?>();
      final under = <String>{};
      void walk(String id) {
        if (!under.add(id)) return;
        for (final c in ((nodes[id] as Map?)?['children'] as List?) ?? const []) {
          walk(c as String);
        }
      }

      if (nodes.containsKey('side')) walk('side');
      return [
        for (final e in nodes.entries)
          if (e.value case final Map n when n['type'] == type && under.contains(e.key) != drawer)
            jsonEncode([
              (n['props'] as Map?)?['rail'],
              for (final m in (n['media'] as List?) ?? const [])
                if (((m as Map)['patch'] as Map)['props'] case {'rail': _}) m,
            ]),
      ];
    }
    const atRail = '[null,{"maxWidth":1023,"patch":{"props":{"rail":true}}}]';
    const untold = '[null]';

    test("the design system's rail: every folding component, however deep, and nothing else", () {
      final r = read(_app('''
  Sidebar#side
    Brand "Acme"
    Divider
    Column gap=2
      NavItem "Inbox" icon="inbox"
    each p in people
      NavItem "{p.name}" icon="person"
    Go "Sent" icon="send"
    Footer
      NavItem "Settings" icon="settings"''', before: 'define Go "label" icon\n  NavItem "{label}" icon={icon}\n'));
      expect(media(r), isRail);
      expect(told(r, 'NavItem'), List.filled(4, atRail));
      expect(told(r, 'Brand'), [atRail]);
      // The drawer a phone opens holds the same lines, told nothing: it is as wide as written.
      expect(told(r, 'NavItem', drawer: true), List.filled(4, untold));
      expect(jsonEncode(r.document).split('"rail":true'), hasLength(6));
    });

    test('a sidebar with a line written by hand is no rail: its components are told nothing', () {
      final r = read(_app('  Sidebar#side\n    Brand "Acme"\n    NavItem "Inbox" icon="inbox"\n    Row gap=8 middle onTap={toast "up"}\n      Icon "bolt"\n      Text "Upgrade"'));
      expect(told(r, 'NavItem'), [untold]);
      expect(told(r, 'Brand'), [untold]);
      // Nor outside an app's sidebar: a component on a page.
      expect(told(read('Column\n  NavItem "Inbox" icon="inbox"\n'), 'NavItem', drawer: true), [untold]);
    });

    test("a writer's own rail: the rule's width, with or without a rail in the design system", () {
      for (final rail in [true, false]) {
        final r = read(_app('  Sidebar#side tablet.w=72 hide=phone\n    NavItem "Inbox" icon="inbox"\n    Tile "Storage"'), rail: rail);
        expect(told(r, 'NavItem'), [atRail]);
        expect(told(r, 'Tile'), [untold]);
        // A rule that leaves it wide says nothing.
        expect(told(read(_app('  Sidebar#side tablet.w=200\n    NavItem "Inbox" icon="inbox"'), rail: rail), 'NavItem'), [untold]);
      }
    });

    test('a sidebar written as narrow as a rail is one wherever its own rule does not widen it', () {
      expect(told(read(_app('  Sidebar#side w=64\n    NavItem "Inbox" icon="inbox"')), 'NavItem'), ['[true]']);
      expect(told(read(_app('  Sidebar#side w=64 desktop.w=240\n    NavItem "Inbox" icon="inbox"')), 'NavItem'),
          ['[true,{"minWidth":1024,"patch":{"props":{"rail":false}}}]']);
    });

    test('a line that says rail itself keeps what it says', () {
      final r = read('state folded=false\n${_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox" rail={folded}\n    NavItem "Sent" icon="send" rail=false\n    NavItem "Drafts" icon="edit" tablet.rail=false\n    Brand "Acme"')}');
      expect(media(r), isRail);
      final items = told(r, 'NavItem');
      expect(items, hasLength(3));
      expect(items.where((t) => t.contains('"rail":true')), isEmpty);
      expect(told(r, 'Brand'), [atRail]);
    });
  });

  // A window of a sidebar, a list and the main pane drops the sidebar at a
  // tablet's width, and a button for its drawer shows there (in Main's bar,
  // or in a slim bar made for it). A sidebar that is a rail there is not
  // dropped: the button is a phone's only.
  group('the button for the drawer, with a list between the sidebar and the main pane', () {
    String window(String side, {String bar = ''}) =>
        'App\n$side\n  Pane#list w=400\n    Text "Inbox"\n  Main#main\n$bar    Text "Hello"\n';

    /// From which width up the menu button (or the slim bar that holds it)
    /// is hidden.
    Object? hiddenFrom(NotationResult r) {
      final nodes = (r.document['nodes'] as Map).cast<String, Map>();
      final main = [for (final c in nodes['main']!['children'] as List) nodes[c]!];
      final bar = main.first;
      final holder = bar['type'] == 'row' && jsonEncode(bar['media'] ?? const []).contains('"visible":false')
          ? bar
          : nodes.values.firstWhere((n) => n['type'] == 'iconButton' && jsonEncode(n['media'] ?? const []).contains('"visible":false'));
      return [
        for (final m in holder['media'] as List)
          if (((m as Map)['patch'] as Map)['visible'] == false) m['minWidth'],
      ].single;
    }

    const rail = '  Sidebar#side\n    Brand "Acme"\n    NavItem "Inbox" icon="inbox"';
    const hand = '  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Row gap=8 onTap={toast "up"}\n      Icon "bolt"\n      Text "Upgrade"';

    test('a rail: a phone only, in a slim bar and in a bar of the page', () {
      expect(hiddenFrom(read(window(rail))), 700);
      expect(hiddenFrom(read(window(rail, bar: '    Nav\n      Text "Mail"\n'))), 700);
      expect(hiddenFrom(read(window('  Sidebar#side tablet.w=72 hide=phone\n    NavItem "Inbox" icon="inbox"'))), 700);
    });

    test('a sidebar the tablet drops (as wide as written, or with no rail in the design system): a tablet too', () {
      expect(hiddenFrom(read(window(hand))), 1024);
      expect(hiddenFrom(read(window(hand, bar: '    Nav\n      Text "Mail"\n'))), 1024);
      expect(hiddenFrom(read(window(rail), rail: false)), 1024);
    });
  });
}
