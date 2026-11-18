// A page written for a desktop and read with reflow (docs reference
// responsive.md, "What reflow does"): an app's window, its toolbars, a list's
// rows and what sits in a fixed sidebar keep their lines; a website's band of
// cards still wraps; a line with its own width rules is never reflowed over.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

const _page = NotationOptions(width: 1440);

NotationResult _read(String text) {
  final r = parseNotation(text, catalog: standardCatalog, options: _page);
  expect(r.issues, isEmpty, reason: text);
  return r;
}

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

List<Object?> _media(NotationResult r, String id) => (_node(r, id)['media'] as List?) ?? const [];

void main() {
  test('an app window written as a Row of panes, with its own width rules, is not wrapped nor stacked', () {
    // kanban-board's board page: the window is h=fill, its nav says tablet.w=64 hide=phone.
    final r = _read('''
canvas "Board"
Row#window stretch h=fill
  Column#nav w=220 h=fill tablet.w=64 hide=phone
    Text "Stack"
    Row#navBoard gap=10 pad=8
      Icon "view_kanban"
      Text "Board" grow
  Column#main grow h=fill
    Row#toolbar gap=12 h=60
      Column#titleBlock grow
        Text "Sprint 14 board"
        Text "Juniper"
      Row#searchBox gap=6 w=260
        Input "" "Search cards"
      Button "New card"
''');
    expect(_media(r, 'window'), isEmpty);
    expect(_media(r, 'main'), isEmpty);
    // The writer's rules are as written, with nothing of the reflow's over them.
    expect(_media(r, 'nav'), [
      {
        'maxWidth': 1023,
        'patch': {
          'layout': {'width': 64},
        },
      },
      {
        'maxWidth': 699,
        'patch': {
          'visible': false,
          'bind': {'visible': null},
        },
      },
    ]);
    // A bar of a fixed height and a row in a sidebar a phone holds keep their line.
    expect(_media(r, 'toolbar'), isEmpty);
    expect(_media(r, 'navBoard'), isEmpty);
  });

  test('an app window with no width rules of its own is laid out as an App: a tablet drops the panes after the main one, a phone shows it alone', () {
    final r = _read('''
canvas "Mail"
Row#window stretch h=fill
  Column#side w=232 h=fill
    Text "Inbox"
  Column#main grow h=fill
    Column#rows grow h=fill scroll
      Row#mailRow gap=12 pad=10
        Text "Maya Reyes" w=180
        Text "Q4 roadmap review moved to Thursday" grow
        Text "9:41 AM" w=80
  Column#inspector w=300 h=fill
    Text "Details"
''');
    expect(_media(r, 'window'), isEmpty);
    expect(_media(r, 'inspector'), [
      {
        'maxWidth': 1023,
        'patch': {'visible': false},
      },
    ]);
    expect(_media(r, 'side'), [
      {
        'maxWidth': 699,
        'patch': {'visible': false},
      },
    ]);
    // A list's row in a pane keeps its line.
    expect(_media(r, 'mailRow'), isEmpty);
  });

  test("a table's rows in a list and a timeline in a sideways scroll are not wrapped", () {
    final r = _read('''
state rows=[{"name":"Maya","email":"maya@x.com","role":"Owner"}]
canvas "Members"
Column#page w=fill scroll
  Column#table w=fill
    each m in rows
      Row#tr gap=12 pad=8
        Icon "person"
        Text "{m.name}" grow
        Text "{m.role}"
  Row#lanes scroll gap=0
    Column#lane w=2000
      Row#clip gap=6
        Icon "graphic_eq"
        Text "Intro" grow
''');
    expect(_media(r, 'tr'), isEmpty);
    expect(_media(r, 'clip'), isEmpty);
  });

  test("a row in a fixed box a phone holds (a track's head 96 wide) keeps its line", () {
    final r = _read('''
canvas "Editor"
Column#root w=fill
  Row#timeline w=fill
    Column#heads w=96
      Row#head gap=8
        Icon "circle"
        Text "Voice" grow
        Toggle "M"
    Column#lanes grow
      Text "lanes"
''');
    expect(_media(r, 'head'), isEmpty);
  });

  test('keep on a line leaves it and what is in it as written', () {
    final r = _read('''
canvas "Site"
Column#page w=fill scroll
  Row#band gap=24 keep
    Card#a w=fill grow
      Text "One"
      Text "Card"
      Text "Body"
    Card#b w=fill grow
      Text "Two"
      Text "Card"
      Text "Body"
''');
    expect(_media(r, 'band'), isEmpty);
    expect(_media(r, 'a'), isEmpty);
  });

  test("a website's band of cards still wraps, and a line's own rules are never reflowed over", () {
    final r = _read('''
canvas "Site"
Column#page w=fill scroll
  Row#band gap=24
    Card#a w=fill grow
      Text "One"
      Text "Card"
      Text "Body"
    Card#b w=fill grow
      Text "Two"
      Text "Card"
      Text "Body"
    Card#c w=fill grow
      Text "Three"
      Text "Card"
      Text "Body"
  Text#hero "Incidents, resolved" size=56 phone.size=30
''');
    expect(_media(r, 'band').first, {
      'maxWidth': 1023,
      'patch': {
        'props': {'wrap': true, 'runSpacing': 24},
      },
    });
    expect(_media(r, 'a'), isNotEmpty);
    // The headline says its phone size: the reflow's smaller tablet size is not added under it.
    expect(_media(r, 'hero'), [
      {
        'maxWidth': 699,
        'patch': {
          'props': {
            'style': {'fontSize': 30},
          },
        },
      },
    ]);
  });
}
