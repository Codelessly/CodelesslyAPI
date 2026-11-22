// A node's events and their actions (`onTap={…}`) in the notation's words, for
// printNodeLine (print_fields.dart), and the canvas's (`every`, `key` lines)
// for printNotation (print.dart). Design 22 sections 2.2 and 2.3.
//
// Each event is written in the shortest words that read back as the
// reaction: the notation's verbs (`toast "Saved"`, `count=count+1`), a choice
// for an `if` (`ok ? close : toast "Fix it"`), an action of the catalog by its
// type and fields (`animate node=hero command=forward`), and JSON only for an
// action none of these say. Every candidate is checked by parsing it, so a
// word is written only where it gives the same action back.
import 'dart:convert';

import '../catalog.dart';
import '../json.dart';
import '../triggers.dart' show TriggerType;
import 'notation.dart';
import 'print_fields.dart';

/// The words for node [id]'s events and their actions, each written after
/// the line's fields: `onTap={…}`, `onKeyDown(key=Enter)={…}`. Empty when it
/// has none or when one of them has no words (they all stay in the line's
/// `{…}` tail then). The `changed` reaction an `@name` writes is the
/// line's binding, not an event: it is left to the line's fields.
List<String> printEvents(String id, Json node, PrintContext context) {
  final reactions = readList(node['actions']);
  if (reactions == null || reactions.isEmpty) return const [];
  final p = _Printer.of(context);
  final bound = printedBindReaction(id, node, context);
  final out = <String>[];
  for (var i = 0; i < reactions.length; i++) {
    final r = readMap(reactions[i]);
    if (r == null) return const [];
    if (i == bound) continue;
    final word = p.reaction(r, '${node['type']}', named: p.named('${node['type']}'));
    if (word == null) return const [];
    out.add(word);
  }
  return out;
}

/// The lines for the reactions of the document's canvas: `every 1s
/// onTick={…}` for a timer, `key mod+k onPress={…}` for a shortcut. Empty
/// when it has none or when one of them is neither (they stay on the
/// `document {…}` line then).
/// [from]: the reactions before it are said on the canvas line (the walk's
/// `onLoad={…}`, [printCanvasReaction]).
List<String> printCanvasEvents(Json document, PrintContext context, {int from = 0}) {
  final screen = context.options.screen;
  final reactions = readList(readMap(context.nodes[screen])?['actions']);
  if (reactions == null || reactions.length <= from) return const [];
  final p = _Printer.of(context);
  final out = <String>[];
  for (final r in reactions.skip(from)) {
    final line = p.canvasLine(readMap(r));
    if (line == null) return const [];
    out.add(line);
  }
  return out;
}

/// The lines for canvas [id]'s own reactions (a `Canvas#id` block's: its
/// `on`, `key` and `every` lines, under it), or null when one has no line.
List<String>? printCanvasBlockEvents(PrintContext context, String id) {
  final reactions = readList(readMap(context.nodes[id])?['actions']);
  if (reactions == null) return const [];
  final p = _Printer.of(context);
  final out = <String>[];
  for (final r in reactions) {
    final line = p.canvasLine(readMap(r));
    if (line == null) return null;
    out.add(line);
  }
  return out;
}

/// The lines for a component's screen lines (its document's
/// `screenActions`: the `key`, `every` and `on` lines the screen that shows
/// it takes). Empty when it has none or one of them has no line.
List<String> printComponentScreenEvents(Json document, PrintContext context) {
  final reactions = readList(document['screenActions']);
  if (reactions == null || readMap(document['widget']) == null) return const [];
  final p = _Printer.of(context);
  final out = <String>[];
  for (final r in reactions) {
    final line = p.canvasLine(readMap(r));
    if (line == null) return const [];
    out.add(line);
  }
  return out;
}

/// A reaction of a canvas as the word its `canvas` line says it with
/// (`onLoad={…}`), or null: the walk's (print.dart), for what is neither a
/// timer nor a shortcut.
String? printCanvasReaction(Json reaction, PrintContext context) => _Printer.of(context).reaction(reaction, 'Box');

/// The marks for node [id] written with [head] (design 13, section 3.1):
/// `@name` for the line's value (a variable, a field of a record variable or
/// of the repeated element, `@item.done`), and on a design system's control
/// `key=@name` for each further variable parameter (`direction=@dir`); the
/// paths they bind (a binding, or a variable parameter, `props.value`), and
/// the index of the reaction the value's mark writes in the node's `actions`
/// (-1: none, as on a design system's control). Null when no mark gives
/// exactly the node's binding and its first reaction; the line's fields and
/// events then say them as they are. Found by reading the marks on the line
/// in the place the node has (under its `each`), so they are written only
/// where they read back as the node.
PrintedBind? printBind(String id, Json node, String head, PrintContext context) => _Printer.of(context).bind(id, node, head);

/// [document] with what the API reads in two spellings in one of them, the
/// one the parser writes: a reaction's trigger given as its type alone
/// (`"trigger": "click"`) is `{"type": "click"}`, and an operand of a
/// condition given as a number or a boolean (`"right": 3`) is its text
/// (`"3"`), which is how `ConditionOperand` reads it. The notation states
/// meaning, and the two spellings mean the same, so printNotation reads a
/// document in this form before it prints it and compares the print with it.
/// [document] itself when it has neither.
Json printNormalized(Json document, Catalog catalog) {
  final nodes = readMap(document['nodes']);
  if (nodes == null) return document;
  var changed = false;

  // A condition: its operands as text, its parts the same.
  Object? condition(Object? c) {
    final m = readMap(c);
    if (m == null) return c;
    return {
      for (final e in m.entries)
        e.key: switch (e.key) {
          'left' || 'right' when e.value is num || e.value is bool => (changed = true, '${e.value}').$2,
          'and' || 'or' when e.value is List => [for (final p in e.value! as List) condition(p)],
          _ => e.value,
        },
    };
  }

  // An action: its `when`, an `if`'s condition, and the actions it holds.
  Object? action(Object? a) {
    final m = readMap(a);
    if (m == null) return a;
    final nested = catalog.action('${m['type']}')?.nested ?? const <String>[];
    return {
      for (final e in m.entries)
        e.key: e.key == 'when' || (e.key == 'condition' && m['type'] == 'if')
            ? condition(e.value)
            : nested.contains(e.key) && e.value is List
                ? [for (final x in e.value! as List) action(x)]
                : e.value,
    };
  }

  Object? reaction(Object? r) {
    final m = readMap(r);
    if (m == null) return r;
    return {
      for (final e in m.entries)
        e.key: switch (e.key) {
          'trigger' when e.value is String => (changed = true, {'type': e.value}).$2,
          'actions' when e.value is List => [for (final a in e.value! as List) action(a)],
          _ => e.value,
        },
    };
  }

  final out = {
    for (final e in nodes.entries)
      e.key: switch (readMap(e.value)) {
        final Json n when n['actions'] is List => {...n, 'actions': [for (final r in n['actions']! as List) reaction(r)]},
        _ => e.value,
      },
  };
  return changed ? {...document, 'nodes': out} : document;
}

/// What prints a document's events: its state, and the parses that check
/// each candidate word, kept for the whole print.
final class _Printer {
  _Printer(this.context, this._heads) {
    // The state the print's `state` lines declare: the screen's, or where a
    // document with other canvases or overlays keeps it (`page_variables`),
    // or its one scope (print.dart's walk reads them from the same place).
    final screen = context.options.screen;
    final vars = readMap(context.document['variables']) ?? const {};
    final scope = vars.length == 1
        ? vars.keys.single
        : vars[screen] == null && vars['page_variables'] != null
            ? 'page_variables'
            : screen;
    _state = [
      for (final v in readList(vars[scope]) ?? const [])
        // (A name the runtime gives a scope has no state line: notationRefusedState.)
        if (v is Map && v['name'] is String && !notationRefusedState(v['name'] as String))
          // A decimal that starts whole (`state stop:decimal=0`) says so:
          // `state stop=0` would read as a whole number.
          'state ${v['name']}${v['type'] == 'decimal' && v['value'] is int ? ':decimal' : ''}=${jsonEncode(v['value'])}',
    ].join('\n');
    _variables = jsonEncode(_parse('')?['variables']);
  }

  // One for each set of overlay heads the walk prints (they change what an
  // `open` reads as).
  static final Expando<Map<String, _Printer>> _printers = Expando();
  static _Printer of(PrintContext context) {
    final heads = context.overlayHeads.values.join('\n');
    return (_printers[context.document] ??= {})[heads] ??= _Printer(context, heads);
  }

  final PrintContext context;
  late final String _state;
  late final String _variables;
  final _parsed = <String, Json?>{};

  /// The overlay heads the walk prints (`Dialog#confirm`), read after every
  /// probe: `open confirm` gives the action the dialog's head gives it.
  final String _heads;

  /// [lines] after the state, parsed: the document and what the parse says.
  ({Json document, List<String> said}) _read(String lines) => _reads.putIfAbsent(lines, () {
        final text = [if (_state.isNotEmpty) _state, lines, if (_heads.isNotEmpty) _heads].join('\n');
        final r = parseNotation(text, catalog: context.catalog, options: context.options);
        return (document: r.document, said: [for (final i in r.issues) i.message]);
      });
  final _reads = <String, ({Json document, List<String> said})>{};

  /// [lines] after the state, parsed; null when the parse says anything
  /// is wrong.
  Json? _parse(String lines) => _parsed.putIfAbsent(lines, () {
        final r = _read(lines);
        return r.said.isEmpty ? r.document : null;
      });

  /// [lines] parsed, null when the parse says anything is wrong or declares
  /// a variable the document does not have.
  Json? _probe(String lines) {
    final d = _parse(lines);
    if (d == null || jsonEncode(d['variables']) != _variables) return null;
    return d;
  }

  /// `[head] [word]` parsed, where [head] alone may already say something
  /// or declare a variable (a design system's block called without a
  /// parameter it requires, or with its variable parameter's own): the
  /// document, when [word] adds nothing to what is said or declared.
  Json? _probeWith(String head, String word) {
    final r = _read('$head $word'), alone = _read(head);
    if (!_sameSaid(r.said, alone.said) || jsonEncode(r.document['variables']) != jsonEncode(alone.document['variables'])) return null;
    return r.document;
  }

  static bool _sameSaid(List<String> a, List<String> b) => a.length == b.length && [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((x) => x);

  // --- @name -----------------------------------------------------------------

  /// Each node's parent, by its children and slots.
  late final Map<String, String> _parents = {
    for (final e in context.nodes.entries)
      if (readMap(e.value) case final Json n) ...{
        for (final c in readStrings(n['children'])) c: e.key,
        for (final c in (readMap(n['slots']) ?? const {}).values)
          if (c is String) c: e.key,
      },
  };

  /// The lines node [id]'s line is read under so that `item` is the
  /// element of the list it repeats in (`Column`, `each item in rows`), and
  /// the line's indent; empty when it is in no list, null when it is in a
  /// list in a list (whose element the print names otherwise).
  ({String lines, String indent})? _around(String id) {
    String? list;
    final seen = <String>{};
    for (var at = _parents[id]; at != null && seen.add(at); at = _parents[at]) {
      final n = readMap(context.nodes[at]);
      final data = readMap(n?['bind'])?['data'];
      if ((n?['type'] != 'listView' && n?['type'] != 'gridView') || data is! String) continue;
      if (list != null) return null;
      final name = RegExp(r'^\$\{([A-Za-z_][A-Za-z0-9_.]*)\}$').firstMatch(data)?[1];
      list = name ?? (data.startsWith(r'${= ') && data.endsWith('}') && !data.contains('\n') ? data.substring(4, data.length - 1).trim() : null);
      if (list == null) return null;
    }
    return list == null ? (lines: '', indent: '') : (lines: 'Column\n  each item in $list\n', indent: '    ');
  }

  /// The node `p` of [lines] read, and what the read says.
  ({Json? node, Json document, List<String> said}) _line(String lines) {
    final r = _read(lines);
    return (node: readMap(readMap(r.document['nodes'])?['p']), document: r.document, said: r.said);
  }

  PrintedBind? bind(String id, Json node, String head) {
    final spec = context.catalog.widget('${node['type']}');
    if (spec == null) return null;
    final props = readMap(node['props']) ?? const {}, bound = readMap(node['bind']) ?? const {};
    final reactions = readList(node['actions']) ?? const [];
    // (In a list in a list, read alone: a variable's or a record's field.)
    final around = _around(id) ?? (lines: '', indent: '');
    // (A component a word of the notation shadows is called by its name.)
    final after = named('${node['type']}');
    final alone = _line('${around.lines}${around.indent}$head#p$after');

    // What a mark (`@__v`, or `key=@__v`) writes on this line, learnt from a
    // name no document has: the path it binds and, for a binding, its
    // template; null when it binds nothing there.
    ({String path, String? template})? learn(String mark) {
      final learnt = _line('$head#p$after $mark').node;
      if (learnt == null) return null;
      String? path, template;
      for (final e in (readMap(learnt['bind']) ?? const {}).entries) {
        if ('${e.value}'.contains('__v')) (path, template) = (e.key, '${e.value}');
      }
      for (final e in (readMap(learnt['props']) ?? const {}).entries) {
        if (e.value == '__v') path = 'props.${e.key}';
      }
      return path == null ? null : (path: path, template: template);
    }

    // What a mark would be written with, from what the node holds at [path].
    List<String> candidates(String path, String? template) {
      final out = <String>[];
      final value = bound[path];
      if (template != null && value is String && template.indexOf('__v') == template.lastIndexOf('__v')) {
        final at = template.indexOf('__v');
        final before = template.substring(0, at), after = template.substring(at + 3);
        if (value.length > before.length + after.length && value.startsWith(before) && value.endsWith(after)) {
          out.add(value.substring(before.length, value.length - after.length));
        }
      } else if (template == null) {
        // A design system control's variable parameter: the variable's name or
        // a field's path (`"draft.title"`), or a field of the repeated element
        // (`"rows[" + index + "].done"`).
        final key = path.substring('props.'.length);
        if (props[key] case final String v) out.add(v);
        if (value is String) {
          final m = RegExp(r'^\$\{= "[A-Za-z_][A-Za-z0-9_.]*\[" \+ index \+ "\]\.([A-Za-z_][A-Za-z0-9_]*)"\}$').firstMatch(value);
          if (m != null) out.add('item.${m[1]}');
        }
      }
      return [
        for (final e in out)
          if (RegExp(r'^[^\s{}"=@]+$').hasMatch(e)) e,
      ];
    }

    // [words] read on the line where the node is: the node, when it reads
    // with no more said than the line alone and no variable of its own.
    Json? read(String words) {
      final got = _line('${around.lines}${around.indent}$head#p$after $words');
      if (got.node == null || !_sameSaid(got.said, alone.said) || jsonEncode(got.document['variables']) != _variables) return null;
      return got.node;
    }

    bool same(Json n, String path, String? template) {
      final key = path.substring(path.indexOf('.') + 1);
      return template == null
          ? jsonEquality.equals(readMap(n['props'])?[key], props[key]) && jsonEquality.equals(readMap(n['bind'])?[path], bound[path])
          : jsonEquality.equals(readMap(n['bind'])?[path], bound[path]);
    }

    // The line's value: bare, `@name`.
    PrintedBind? main;
    final value = learn('@__v');
    if (value != null) {
      for (final e in candidates(value.path, value.template)) {
        final n = read('@$e');
        if (n == null || !same(n, value.path, value.template)) continue;
        final wrote = readList(n['actions']) ?? const [];
        // (What only shows a value is written as that value, `value={done/total}`, by the line's fields.)
        if (wrote.isEmpty && value.template == null) {
          main = (word: '@$e', index: -1, paths: [value.path]);
        } else if (wrote.length == 1 && reactions.isNotEmpty && jsonEquality.equals(wrote.single, reactions.first)) {
          main = (word: '@$e', index: 0, paths: [value.path]);
        }
        if (main != null) break;
      }
    }
    // A design system control's further variables: `key=@name`
    // (`direction=@dir`), each kept in its parameter, writing no reaction.
    final words = [?main?.word];
    final paths = [...?main?.paths];
    if (spec.type[0] != spec.type[0].toLowerCase()) {
      for (final p in spec.props) {
        if (!p.type.isVariable || paths.contains('props.${p.key}')) continue;
        final other = learn('${p.key}=@__v');
        if (other == null || other.template != null || other.path != 'props.${p.key}') continue;
        for (final e in candidates(other.path, null)) {
          final n = read([...words, '${p.key}=@$e'].join(' '));
          if (n == null || !same(n, other.path, null) || (readList(n['actions']) ?? const []).length > (main?.index == 0 ? 1 : 0)) continue;
          words.add('${p.key}=@$e');
          paths.add(other.path);
          break;
        }
      }
    }
    if (words.isEmpty) return null;
    return (word: words.join(' '), index: main?.index ?? -1, paths: paths);
  }

  /// The actions [text] gives, as the events of a box.
  List<Object?>? _actions(String text) {
    final d = _probe('Box#p onTap={$text}');
    final r = readList(readMap(readMap(d?['nodes'])?['p'])?['actions']);
    return r == null || r.length != 1 ? null : readList(readMap(r.single)?['actions']);
  }

  bool _gives(String text, List<Object?> actions) => switch (_actions(text)) {
        final List<Object?> got => jsonEquality.equals(got, actions),
        _ => false,
      };

  /// [r] as `on<Event>(fields)={actions}` on a node of [type], or null.
  String? reaction(Json r, String type, {String named = ''}) {
    if (r.keys.any((k) => k != 'trigger' && k != 'actions')) return null;
    final trigger = readMap(r['trigger']);
    final actions = readList(r['actions']) ?? const [];
    if (trigger == null || trigger['type'] is! String) return null;
    final body = sequence(actions);
    if (body == null) return null;
    final head = _event(trigger, type);
    if (head == null) return null;
    final word = '$head={$body}';
    // Checked on a line of the node's type (its events are its own), else on a box.
    // A design system's component a word of the notation shadows is called
    // by its name ([named]): its events are its own.
    // A word that is an overlay at the margin (`Dialog#p`, a design system's
    // Dialog) is probed under a column, where it is the component.
    final overlayWord = RegExp(r'^(Dialog|Modal|Sheet|BottomSheet|Drawer|Menu|Dropdown|Popover|Popup|Lightbox|Canvas)$').hasMatch(type);
    for (final (t, after) in [(overlayWord ? 'Column\n  $type' : type, named), ('Box', '')]) {
      final d = _probeWith('$t#p$after', word);
      if (d == null) continue;
      final got = readList(readMap(readMap(d['nodes'])?['p'])?['actions']);
      return got != null && got.isNotEmpty && jsonEquality.equals(got.last, r) ? word : null;
    }
    return null;
  }

  final _named = <String, String>{};

  /// ` type=Button` where a line of [type] is a design system's component
  /// that a word of the notation shadows (`Button`, `Chip`, `TopBar`): the
  /// line reads as the notation's word without it (design 22, 4.2). Else
  /// empty.
  String named(String type) => _named[type] ??= () {
        if (type.isEmpty || type[0] == type[0].toLowerCase() || context.catalog.widget(type) == null) return '';
        Object? typeOf(String line) => readMap(readMap(_read(line).document['nodes'])?['p'])?['type'];
        return typeOf('$type#p') != type && typeOf('$type#p type=$type') == type ? ' type=$type' : '';
      }();

  /// A trigger as its event's name and its fields in parentheses.
  String? _event(Json trigger, String type) {
    final kind = trigger['type']! as String;
    final String name;
    if (kind == 'event') {
      final e = trigger['event'];
      if (e is! String || !RegExp(r'^on[A-Z][A-Za-z]*$').hasMatch(e)) return null;
      name = e;
    } else {
      name = notationEventName(kind);
    }
    return switch (_fields(trigger, kind)) {
      final String fields => '$name$fields',
      _ => null,
    };
  }

  /// A trigger's fields in parentheses (`(key=Enter, repeat=true)`), empty
  /// when it has none; null when one has no words.
  String? _fields(Json trigger, String kind) {
    final fields = <String>[];
    for (final e in trigger.entries) {
      if (e.key == 'type' || kind == 'event' && e.key == 'event') continue;
      final w = _triggerField(e.key, e.value);
      if (w == null) return null;
      fields.add('${e.key}=$w');
    }
    return fields.isEmpty ? '' : '(${fields.join(', ')})';
  }

  final _fieldWords = <String, String?>{};

  /// The first way of writing [value] that reads back as trigger field
  /// [key] (the fields are every trigger's: read on a tap).
  String? _triggerField(String key, Object? value) => _fieldWords.putIfAbsent('$key\u0000${jsonEncode(value)}', () {
        for (final w in _values(value)) {
          if (w.contains(',') && !w.startsWith('"') && !w.startsWith('{') && !w.startsWith('[')) continue;
          final d = _probe('Box#p onTap($key=$w)={}');
          final r = readList(readMap(readMap(d?['nodes'])?['p'])?['actions']);
          if (r != null && r.length == 1 && jsonEquality.equals(readMap(readMap(r.single)?['trigger'])?[key], value)) return w;
        }
        return null;
      });

  /// [actions] as the notation's words, `;` between them; null when one has none.
  String? sequence(List<Object?> actions) {
    final out = <String>[];
    for (var i = 0; i < actions.length; i++) {
      final a = readMap(actions[i]);
      if (a == null) return null;
      // `copy x` copies and says so: two actions.
      final next = i + 1 < actions.length ? readMap(actions[i + 1]) : null;
      if (a['type'] == 'copyToClipboard' && next != null && next['type'] == 'showToast' && next['message'] == 'Copied' && next.length == 2) {
        final copy = _copy(a);
        if (copy != null && _gives(copy, [a, next])) {
          out.add(copy);
          i++;
          continue;
        }
      }
      final w = action(a);
      if (w == null) return null;
      out.add(w);
    }
    return out.join('; ');
  }

  final _said = <String, String?>{};

  /// One action in the shortest words that give it back.
  String? action(Json a) => _said.putIfAbsent(jsonEncode(a), () {
        for (final c in [..._verbs(a), ?_typed(a), jsonEncode(a)]) {
          if (_gives(c, [a])) return c;
        }
        return null;
      });

  String? _copy(Json a) {
    if (a.length != 2) return null;
    final text = a['text'];
    if (text is! String) return null;

    return _quoted(text) == null ? null : 'copy ${_quoted(text)}';
  }

  /// The notation's verbs that may say [a] (design 13 section 3).
  List<String> _verbs(Json a) {
    final keys = {...a.keys}..remove('type');
    bool only(Set<String> allowed) => keys.every(allowed.contains);
    String? word(Object? v) => v is String && RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(v) ? v : null;
    final quoted = <String>[];
    switch (a['type']) {
      case 'setVariable' when only({'variable', 'value'}) && word(a['variable']) != null && a['value'] is String:
        final v = a['value']! as String, name = a['variable'];
        return [
          if (_formula(v) case final String f) '$name=$f',
          if (word(v) != null && !const {'true', 'false', 'null'}.contains(v)) '$name=$v',
          if (_quoted(v) case final String q) '$name=$q',
        ];
      case 'componentEvent' when only({'event', 'value'}) && word(a['event']) != null:
        final v = a['value'], e = a['event'];
        if (!a.containsKey('value')) return ['emit $e'];
        return [
          if (v is String && _whole(v) != null) 'emit $e ${_whole(v)}',
          if (v is String && RegExp(r'^[A-Za-z][A-Za-z0-9]*( [A-Za-z0-9]+)+$').hasMatch(v)) 'emit $e $v',
          'emit $e ${jsonEncode(v)}',
        ];
      // An overlay printed as its head (`Dialog#confirm`) gives its `open`
      // the fields of its kind (a dialog's presentation): checked as read.
      case 'openModal' when (only({'to'}) || _heads.isNotEmpty) && word(a['to']) != null:
        return ['open ${a['to']}'];
      case 'closeModal' when keys.isEmpty:
        return ['close'];
      case 'navigate' when only({'to'}) && a['to'] is String:
        final to = a['to']! as String;
        return [
          if (word(to) != null) 'go $to',
          if (to.startsWith(r'${= ') && to.endsWith('}')) 'go {${to.substring(4, to.length - 1)}}',
          if (_quoted(to) case final String q) 'go $q',
        ];
      case 'showToast' when only({'message'}) && a['message'] is String:
        if (_quoted(a['message']! as String) case final String q) quoted.add('toast $q');
      case 'announce' when only({'message'}) && a['message'] is String:
        if (_quoted(a['message']! as String) case final String q) quoted.add('announce $q');
      case 'openLink' when only({'url'}) && a['url'] is String:
        final url = a['url']! as String;
        return [
          if (RegExp(r'^[^\s"{}$;]+$').hasMatch(url)) 'link $url',
          if (_quoted(url) case final String q) 'link $q',
        ];
      case 'scrollTo' when only({'node', 'durationMs', 'offset'}) && a['durationMs'] == 400 && a['offset'] == 72 && word(a['node']) != null:
        return ['scroll ${a['node']}'];
      case 'focus' when only({'node'}) && word(a['node']) != null:
        return ['focus ${a['node']}'];
      case 'focus' when only({'unfocus'}) && a['unfocus'] == true:
        return ['blur'];
      case 'confirm' when only({'title', 'actions'}) && a['title'] is String && a['actions'] is List:
        final then = sequence(readList(a['actions'])!), title = _quoted(a['title']! as String);
        if (then != null && title != null) quoted.add('confirm $title then {$then}');
      case 'if' when only({'condition', 'then', 'else'}):
        final c = readMap(a['condition']);
        final left = c?['left'];
        if (c == null || c.length != 2 || c['op'] != 'isTrue' || left is! String || !left.startsWith(r'${= ') || !left.endsWith('}')) return const [];
        final yes = sequence(readList(a['then']) ?? const []), no = a.containsKey('else') ? sequence(readList(a['else']) ?? const []) : '';
        if (yes == null || no == null) return const [];
        // A branch of one action as it is; of more, or one that chooses again, in braces.
        String branch(String s) => s.isEmpty || !s.contains(';') && !s.contains('?') ? s : '{$s}';
        final cond = left.substring(4, left.length - 1);
        return [
          '$cond ? ${branch(yes)} : ${branch(no)}'.trimRight(),
          '$cond ? ${yes.isEmpty ? '' : '{$yes}'} : ${no.isEmpty ? '' : '{$no}'}'.trimRight(),
        ];
    }
    return quoted;
  }

  /// [a] as its type and its fields by name (`animate node=hero
  /// command=forward`), each field's value in the first words that give it
  /// back; null when a field has none.
  String? _typed(Json a) {
    final type = a['type'];
    if (type is! String || context.catalog.action(type) == null) return null;
    final spec = context.catalog.action(type)!;
    final out = StringBuffer(type);
    for (final e in a.entries) {
      if (e.key == 'type') continue;
      final chain = spec.nested.contains(e.key) && e.value is List;
      String? found;
      for (final w in [if (chain) ?_chain(readList(e.value)!), ..._values(e.value)]) {
        if (_gives('$type ${e.key}=$w', [
          {'type': type, e.key: e.value},
        ])) {
          found = w;
          break;
        }
      }
      if (found == null) return null;
      out.write(' ${e.key}=$found');
    }
    return out.toString();
  }

  String? _chain(List<Object?> actions) => switch (sequence(actions)) {
        final String s => '{$s}',
        _ => null,
      };

  /// The ways a field's value may be written, shortest first: a number, a
  /// word, `{expression}`, a quoted string, JSON.
  List<String> _values(Object? v) {
    if (v == null || v is bool || v is num) return [jsonEncode(v)];
    if (v is String) {
      return [
        if (RegExp(r'^[A-Za-z_#][A-Za-z0-9_.#/:@+-]*$').hasMatch(v) && !const {'true', 'false', 'null'}.contains(v) && num.tryParse(v) == null) v,
        if (_whole(v) case final String e) '{$e}',
        if (v.startsWith(r'${= ') && v.endsWith('}') && _spans(v).length == 1) '{${v.substring(4, v.length - 1)}}',
        if (_quoted(v) case final String q) q,
        // As written, which a text holding `${` is read as (`"${= ready}"`).
        if (!v.contains('{') || v.contains(r'${')) jsonEncode(v),
      ];
    }
    return [jsonEncode(v)];
  }

  /// A formula as written after `name=` (`count+1` for `${= count+1}`).
  String? _formula(String v) {
    if (!v.startsWith(r'${= ') || !v.endsWith('}') || _spans(v).length != 1) return null;
    return v.substring(4, v.length - 1);
  }

  /// `name` for `${name}` (a value read by name), or null.
  String? _whole(String v) {
    final m = RegExp(r'^\$\{([A-Za-z_][A-Za-z0-9_.]*)\}$').firstMatch(v);
    return m?[1];
  }

  /// [v] in quotes, each `${…}` in it as the notation's `{…}`; null when it
  /// holds braces of its own, which would be read as values.
  String? _quoted(String v) {
    final spans = _spans(v);
    final texts = <String>[], reads = <String>[];
    var at = 0;
    for (final (start, end) in spans) {
      texts.add(v.substring(at, start));
      reads.add(v.substring(start + (v.startsWith(r'${= ', start) ? 4 : 2), end - 1));
      at = end;
    }
    texts.add(v.substring(at));
    if (texts.any((t) => t.contains('{') || t.contains('}'))) return null;
    // A read that holds quotes keeps them as written (the string is then
    // read as it stands, its \" and \\ undone): the text around it is escaped
    // by hand.
    if (reads.any((r) => r.contains('"'))) {
      if (v.contains('\n')) return null;
      final out = StringBuffer('"');
      for (var i = 0; i < texts.length; i++) {
        out.write(texts[i].replaceAll(r'\', r'\\').replaceAll('"', r'\"'));
        if (i < reads.length) out.write('{${reads[i]}}');
      }
      return (out..write('"')).toString();
    }
    final text = StringBuffer();
    for (var i = 0; i < texts.length; i++) {
      text.write(texts[i]);
      if (i < reads.length) text.write('{${reads[i]}}');
    }
    return jsonEncode(text.toString());
  }

  /// The `${…}` spans of [v], outermost.
  static List<(int, int)> _spans(String v) {
    final out = <(int, int)>[];
    for (var i = 0; i < v.length - 1; i++) {
      if (v[i] != r'$' || v[i + 1] != '{') continue;
      var depth = 0;
      for (var j = i + 1; j < v.length; j++) {
        if (v[j] == '{') depth++;
        if (v[j] == '}' && --depth == 0) {
          out.add((i, j + 1));
          i = j;
          break;
        }
      }
    }
    return out;
  }

  /// A reaction of the canvas as a line of its own: a timer as `every`, a
  /// key as `key`.
  String? canvasLine(Json? r) {
    if (r == null || r.keys.any((k) => k != 'trigger' && k != 'actions')) return null;
    final trigger = readMap(r['trigger']);
    final body = sequence(readList(r['actions']) ?? const []);
    final kind = trigger?['type'];
    if (trigger == null || body == null || kind is! String) return null;
    final when = trigger['when'];
    final condition = when == null ? '' : (when is String && _formula(when) != null ? ' when ${_formula(when)}' : null);
    final lines = <String>[];
    if (condition != null && kind == 'timer' && trigger.keys.every(const {'type', 'intervalMs', 'when'}.contains)) {
      final every = switch (trigger['intervalMs'] ?? 1000) {
        final int n when n % 1000 == 0 && n > 0 => '${n ~/ 1000}s',
        final int n => '$n',
        final String f when _formula(f) != null => '{${_formula(f)}}',
        _ => null,
      };
      if (every != null) lines.add('every $every$condition onTick={$body}');
    }
    if (condition != null && kind == 'keyDown' && trigger.keys.every(const {'type', 'key', 'when'}.contains) && trigger['key'] is String && RegExp(r'^[^\s"]+$').hasMatch(trigger['key']! as String)) {
      lines.add('key ${trigger['key']}$condition onPress={$body}');
    }
    // Any trigger: `on load={…}`, its fields in parentheses.
    if (kind != 'event' && TriggerType.values.any((t) => t.name == kind)) {
      if (_fields(trigger, kind) case final String fields) lines.add('on $kind$fields={$body}');
    }
    for (final line in lines) {
      final d = _probe('$line\nBox#p');
      final got = readList(readMap(readMap(d?['nodes'])?[context.options.screen])?['actions']);
      if (got != null && got.length == 1 && jsonEquality.equals(got.single, r)) return line;
    }
    return null;
  }
}
