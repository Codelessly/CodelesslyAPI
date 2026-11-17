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

import '../json.dart';
import 'notation.dart';
import 'print_fields.dart';

/// The words for node [id]'s events and their actions, each written after
/// the line's fields: `onTap={…}`, `onKeyDown(key=Enter)={…}`. Empty when it
/// has none or when one of them has no words (they all stay in the line's
/// `{…}` tail then). The `changed` reaction a `bind=name` writes is the
/// line's binding, not an event: it is left to the line's fields.
List<String> printEvents(String id, Json node, PrintContext context) {
  final reactions = readList(node['actions']);
  if (reactions == null || reactions.isEmpty) return const [];
  final p = _Printer.of(context);
  final out = <String>[];
  for (var i = 0; i < reactions.length; i++) {
    final r = readMap(reactions[i]);
    if (r == null) return const [];
    if (i == 0 && _bindReaction(r, node)) continue;
    final word = p.reaction(r, '${node['type']}');
    if (word == null) return const [];
    out.add(word);
  }
  return out;
}

/// The lines for the reactions of the document's canvas: `every 1s
/// onTick={…}` for a timer, `key mod+k onPress={…}` for a shortcut. Empty
/// when it has none or when one of them is neither (they stay on the
/// `document {…}` line then).
List<String> printCanvasEvents(Json document, PrintContext context) {
  final screen = context.options.screen;
  final reactions = readList(readMap(context.nodes[screen])?['actions']);
  if (reactions == null || reactions.isEmpty) return const [];
  final p = _Printer.of(context);
  final out = <String>[];
  for (final r in reactions) {
    final line = p.canvasLine(readMap(r));
    if (line == null) return const [];
    out.add(line);
  }
  return out;
}

/// Whether [r], the first reaction of [node], is the one `bind=name` writes:
/// a change stored in the variable the node shows.
bool _bindReaction(Json r, Json node) {
  final trigger = readMap(r['trigger']);
  final actions = readList(r['actions']);
  if (trigger == null || trigger.length != 1 || trigger['type'] != 'changed') return false;
  if (actions == null || actions.length != 1) return false;
  final set = readMap(actions.single);
  final variable = set?['variable'];
  if (set?['type'] != 'setVariable' || variable is! String) return false;
  final bind = readMap(node['bind']) ?? const {};
  return bind.entries.any((e) => e.key.startsWith('props.') && e.value is String && RegExp('\\b${RegExp.escape(variable)}\\b').hasMatch(e.value! as String));
}

/// What prints a document's events: its state, and the parses that check
/// each candidate word, kept for the whole print.
final class _Printer {
  _Printer(this.context) {
    final screen = context.options.screen;
    _state = [
      for (final v in readList(readMap(context.document['variables'])?[screen]) ?? const [])
        if (v is Map && v['name'] is String) 'state ${v['name']}=${jsonEncode(v['value'])}',
    ].join('\n');
    _variables = jsonEncode(_parse('')?['variables']);
  }

  static final Expando<_Printer> _printers = Expando();
  static _Printer of(PrintContext context) => _printers[context.document] ??= _Printer(context);

  final PrintContext context;
  late final String _state;
  late final String _variables;
  final _parsed = <String, Json?>{};

  /// [lines] after the state, parsed; null when the parse says anything
  /// is wrong or declares a variable the document does not have.
  Json? _parse(String lines) => _parsed.putIfAbsent(lines, () {
        final r = parseNotation(_state.isEmpty ? lines : '$_state\n$lines', catalog: context.catalog, options: context.options);
        if (r.issues.isNotEmpty) return null;
        return r.document;
      });

  Json? _probe(String lines) {
    final d = _parse(lines);
    if (d == null || jsonEncode(d['variables']) != _variables) return null;
    return d;
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
  String? reaction(Json r, String type) {
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
    for (final t in [type, 'Box']) {
      final d = _probe('$t#p $word');
      if (d == null) continue;
      final got = readList(readMap(readMap(d['nodes'])?['p'])?['actions']);
      return got != null && got.isNotEmpty && jsonEquality.equals(got.last, r) ? word : null;
    }
    return null;
  }

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
    final fields = <String>[];
    for (final e in trigger.entries) {
      if (e.key == 'type' || kind == 'event' && e.key == 'event') continue;
      final w = _values(e.value).where((w) => !w.contains(',') || w.startsWith('"') || w.startsWith('{') || w.startsWith('[')).firstOrNull;
      if (w == null) return null;
      fields.add('${e.key}=$w');
    }
    return fields.isEmpty ? name : '$name(${fields.join(', ')})';
  }

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
    if (_whole(text) case final String name when RegExp(r'^[A-Za-z_][A-Za-z0-9_.]*$').hasMatch(name)) return 'copy $name';
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
      case 'openModal' when only({'to'}) && word(a['to']) != null:
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
        if (!v.contains('{')) jsonEncode(v),
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
    if (trigger == null || body == null) return null;
    final when = trigger['when'];
    String? condition;
    if (when != null) {
      condition = when is String ? _formula(when) : null;
      if (condition == null) return null;
    }
    final String line;
    switch (trigger['type']) {
      case 'timer' when trigger.keys.every(const {'type', 'intervalMs', 'when'}.contains):
        final ms = trigger['intervalMs'] ?? 1000;
        final every = switch (ms) {
          final int n when n % 1000 == 0 && n > 0 => '${n ~/ 1000}s',
          final int n => '$n',
          final String f when _formula(f) != null => '{${_formula(f)}}',
          _ => null,
        };
        if (every == null) return null;
        line = 'every $every${condition == null ? '' : ' when $condition'} onTick={$body}';
      case 'keyDown' when trigger.keys.every(const {'type', 'key', 'when'}.contains) && trigger['key'] is String && RegExp(r'^[^\s"]+$').hasMatch(trigger['key']! as String):
        line = 'key ${trigger['key']}${condition == null ? '' : ' when $condition'} onPress={$body}';
      default:
        return null;
    }
    final d = _probe('$line\nBox#p');
    final got = readList(readMap(readMap(d?['nodes'])?[context.options.screen])?['actions']);
    return got != null && got.length == 1 && jsonEquality.equals(got.single, r) ? line : null;
  }
}
