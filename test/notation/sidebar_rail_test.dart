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

  /// As wide as written at a tablet's width, and what the same text is with
  /// no rail in the design system (the drawer on a phone, the room its
  /// table has).
  void asWritten(String text) {
    final r = read(text);
    expect(media(r), isNot(contains('"width":64')), reason: text);
    expect(media(r), contains(phoneRule), reason: text);
    expect(jsonEncode(r.document), contains('_sidebar'), reason: text);
    expect(jsonEncode(_sorted(r.document)), jsonEncode(_sorted(read(text, rail: false).document)), reason: text);
  }

  group('a sidebar whose lines all fold by themselves is a rail at a tablet', () {
    test('components that declare a rail parameter, whatever their names', () {
      expect(media(read(_app('  Sidebar#side\n    Brand "Acme"\n    NavItem "Inbox" icon="inbox"\n    NavItem "Sent" icon="send"'))), isRail);
    });

    test('with lines that take no width, the foot, an if, an each and a plain Column that hold folding lines', () {
      expect(
          media(read(_app('''
  Sidebar#side
    Brand "Acme"
    Divider
    Column gap=2
      NavItem "Inbox" icon="inbox"
    if length(people) > 0
      NavItem "People" icon="group"
    each p in people
      NavItem "{p.name}" icon="person"
    Spacer
    Footer
      NavItem "Settings" icon="settings"'''))),
          isRail);
    });

    test('with a line that says what it is at a tablet itself: it and the lines under it are its own', () {
      for (final own in ['hide=tablet', 'show=desktop', 'tablet.hidden', 'max899.hidden', 'show=tablet']) {
        expect(media(read(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Row gap=8 $own\n      Icon "bolt"\n      Text "Upgrade"'))), isRail, reason: own);
      }
    });

    test("with a writer's word whose lines are folding words", () {
      expect(media(read(_app('  Sidebar#side\n    Go "Inbox" icon="inbox"\n    Go "Sent" icon="send"', before: 'define Go "label" icon\n  NavItem "{label}" icon={icon}\n'))), isRail);
    });

    test('an empty one too', () {
      expect(media(read('App\n  Sidebar#side\n  Main\n    Text "Hello"\n')), isRail);
    });
  });

  group('a sidebar with a line written by hand is as wide as written at a tablet, and the drawer on a phone', () {
    test('a row of an icon and a text', () {
      asWritten(_app('  Sidebar#side\n    Brand "Acme"\n    NavItem "Inbox" icon="inbox"\n    Row gap=8 middle\n      Icon "bolt"\n      Text "Upgrade"'));
    });

    test('a group label, an account row in the foot, a hand-written line under an if', () {
      asWritten(_app('  Sidebar#side\n    Text.caption "PEOPLE"\n    NavItem "Inbox" icon="inbox"'));
      asWritten(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Footer\n      Row gap=10 middle\n        Avatar "Ada Okafor"\n        Column\n          Text "Ada Okafor"\n          Text "Owner"'));
      asWritten(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    if length(people) > 0\n      Text "People"'));
    });

    test("a writer's word that is a row of its own, and a component with no rail parameter", () {
      asWritten(_app('  Sidebar#side\n    NavTo "Inbox" icon="inbox"\n    NavTo "Sent" icon="send"',
          before: 'define NavTo "label" icon\n  Row w=fill gap=10 middle\n    Icon "{icon}" size=18\n    Text "{label}" grow\n'));
      asWritten(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Tile "Storage"'));
    });

    test('a line that says only what it is on a phone, or on a desktop, is still written by hand at a tablet', () {
      asWritten(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Text "Upgrade" hide=phone'));
      asWritten(_app('  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Text "Upgrade" phone.size=12'));
    });

    test('a sidebar written in a defined word (the app\'s shell)', () {
      asWritten(_app('  Shell', before: 'define Shell\n  Sidebar#side\n    Row gap=8 middle\n      Icon "shield"\n      Text "Tenant"\n    NavItem "Inbox" icon="inbox"\n'));
      expect(media(read(_app('  Shell', before: 'define Shell\n  Sidebar#side\n    Brand "Tenant"\n    NavItem "Inbox" icon="inbox"\n'))), isRail);
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
    const hand = '    Row#brand gap=8 middle\n      Icon "bolt"\n      Text "Acme"';
    test('a block that holds at a tablet is what the part shows there: its lines are the ones that fold', () {
      expect(media(read(_app('  Sidebar#side\n$hand\n    at tablet\n      NavItem "Acme" icon="bolt"'))), isRail);
      expect(media(read(_app('  Sidebar#side\n    NavItem "Acme" icon="bolt"\n    at tablet\n      Row gap=8 middle\n        Icon "bolt"\n        Text "Acme"'))), isNot(contains('"width":64')));
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
      '  Sidebar#side\n    NavItem "Inbox" icon="inbox"\n    Row gap=8 middle\n      Icon "bolt"\n      Text "Upgrade"',
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
}
