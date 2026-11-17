// What a definition's lines do with its signature (docs/design/20 section
// 12): the strings and parameters they never read, the events they never
// fire, and the names they read or set that are neither the word's own nor
// declared in it (a variable of the page it was written for). A definition
// that names what it does not use still resolves the word, so the vocabulary
// tool warns on each: a use's value for such a name does nothing.
//
// Read from the lines as written, as the expansion reads them
// (define.dart's _Substitution): a name counts where the expansion would put
// the use's value in, in braces, in a string's braces, in a list, in a
// statement's expression; a variable bound with `@` (`@value`, `open=@open`)
// and named by `menu=`; an event where an action names it.
import 'define.dart';
import 'vocabulary.dart';

/// What [definition]'s lines leave unused, and what they read from outside.
final class DefinitionReads {
  DefinitionReads._(this.definition, this.unread, this.unfired, this.outside);

  final NotationDefinition definition;

  /// Its strings, parameters and `@value` that its lines never read nor
  /// bind, in signature order.
  final List<String> unread;

  /// Its events that no action of its lines runs.
  final List<String> unfired;

  /// The names its lines read, set or bind that are neither its own nor
  /// declared in it (`state`, an `each` item, a function's `x =>`), sorted.
  final List<String> outside;

  bool get isEmpty => unread.isEmpty && unfired.isEmpty && outside.isEmpty;

  /// One message for each (`page:64: PeriodicTable reads elements, …`).
  List<String> get warnings {
    final d = definition;
    final at = '${d.at(d.line)}: ${d.label}';
    return [
      for (final n in unread) '$at names ${d.strings.contains(n) ? '"$n"' : n} and never reads it: a use\'s ${d.strings.contains(n) ? 'string' : '$n='} does nothing.',
      for (final e in unfired) '$at names $e and never runs it: a use\'s $e={…} never runs.',
      if (outside.isNotEmpty)
        '$at reads ${outside.join(', ')}, which ${outside.length == 1 ? 'is' : 'are'} neither its own nor declared in it: it works only on a page that has ${outside.length == 1 ? 'that variable' : 'those variables'}.',
    ];
  }
}

/// The names a formula may read that no line declares.
const _given = {'true', 'false', 'null', 'result', 'index', 'device', 'variant', 'this'};

/// What [definition]'s lines leave unused and read from outside
/// ([DefinitionReads]). A primitive's lines stand in for what no line can
/// express, so what they leave unused is expected: it has none.
DefinitionReads definitionReads(NotationDefinition definition) {
  final d = definition;
  if (d.primitive) return DefinitionReads._(d, const [], const [], const []);
  final scan = _Scan(d.events.toSet());
  for (final l in d.body) {
    scan.line(l.text);
  }
  final own = {...d.strings, ...d.parameters.keys, ?d.bind};
  final used = {...scan.read, ...scan.set};
  return DefinitionReads._(
    d,
    [
      for (final n in [...d.strings, ...d.parameters.keys, ?d.bind])
        if (!used.contains(n) && !scan.bound.contains(n)) n,
    ],
    [for (final e in d.events) if (!scan.fired.contains(e)) e],
    {
      for (final n in used)
        if (!own.contains(n) && !scan.declared.contains(n) && !d.events.contains(n) && !_given.contains(n)) n,
      // A variable bound with @ is the definition's own when the signature
      // names it (`@value`, `open=@`, a parameter a use may bind) or the
      // lines declare it; any other is the page's.
      for (final n in scan.bound)
        if (!own.contains(n) && !scan.declared.contains(n) && !_given.contains(n)) n,
    }.toList()
      ..sort(),
  );
}

final _name = RegExp(r'[A-Za-z_][A-Za-z0-9_]*');
final _identifierOnly = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

/// The names one definition's lines read, set, bind, declare and fire.
final class _Scan {
  _Scan(this.events);
  final Set<String> events;
  final read = <String>{}, set = <String>{}, bound = <String>{}, declared = <String>{}, fired = <String>{};

  void line(String text) {
    final t = text.trim();
    if (t.startsWith('...')) {
      final words = slotOf(t).words;
      if (words.isNotEmpty) line('X $words');
      return;
    }
    if (RegExp(r'^state\s+([A-Za-z_][A-Za-z0-9_]*)\s*=(.*)$').firstMatch(t) case final m?) {
      declared.add(m[1]!);
      expression(m[2]!);
      return;
    }
    if (RegExp(r'^(?:if|else if)\s+(.*)$').firstMatch(t) case final m?) return expression(_unbraced(m[1]!));
    if (t == 'else') return;
    if (RegExp(r'^each\s+([A-Za-z_][A-Za-z0-9_]*)\s+in\s+(.*?)(\s+reorder(?:=\S+)?|\s+follow.*)?$').firstMatch(t) case final m?) {
      declared.add(m[1]!);
      return expression(_unbraced(m[2]!));
    }
    if (RegExp(r'^(?:every|key)\s+(.*?)\s+(on[A-Z][A-Za-z0-9]*)=\{(.*)\}\s*$').firstMatch(t) case final m?) {
      final when = RegExp(r'(?:^|\s)when[\s=]+(.*)$').firstMatch(m[1]!);
      if (when != null) expression(_unbraced(when[1]!));
      return actions(m[3]!);
    }
    final p = LineParts.of(t);
    if (p == null) return expression(t);
    for (final x in p.parts) {
      switch (x.kind) {
        case 'string':
          _string(x.raw);
        case 'pair':
          final k = x.key!, v = x.value!;
          if (v.startsWith('@')) {
            _mark(v);
          } else if (v.startsWith('{') && v.endsWith('}')) {
            final inner = v.substring(1, v.length - 1);
            if (x.isEvent) {
              actions(inner);
            } else {
              expression(inner);
            }
          } else if (v.startsWith('[')) {
            expression(v);
          } else if (v.startsWith('"')) {
            _string(v);
          } else if (k == 'menu' && _identifierOnly.hasMatch(v)) {
            bound.add(v);
          }
        case 'word' when x.raw.startsWith('@'):
          _mark(x.raw);
        case 'tail' when x.raw.startsWith('{"'):
          expression(x.raw);
        case 'tail':
          // A value where the text goes (`Ring {share} w=40`), and the line
          // after it.
          final close = _close(x.raw, 0);
          expression(x.raw.substring(1, close - 1 < 1 ? 1 : close - 1));
          final rest = x.raw.substring(close).trim();
          if (rest.isNotEmpty) line('X $rest');
      }
    }
  }

  /// `@name`, `@row.done`: the variable bound (the head of its path).
  void _mark(String written) {
    final head = _name.matchAsPrefix(written, 1)?[0];
    if (head != null) bound.add(head);
  }

  /// A string's `{…}`.
  void _string(String s) {
    var i = 0;
    while (i < s.length) {
      if (s[i] == r'\') {
        i += 2;
        continue;
      }
      if (s[i] == '{') {
        final close = _close(s, i);
        expression(s.substring(i + 1, close - 1 < i + 1 ? i + 1 : close - 1));
        i = close;
        continue;
      }
      i++;
    }
  }

  /// The names an expression reads (not a field's, nor a function it calls,
  /// unless that is an event), and the items of its functions (`x =>`).
  void expression(String e) {
    for (final m in RegExp(r'([A-Za-z_][A-Za-z0-9_]*)\s*=>').allMatches(e)) {
      declared.add(m[1]!);
    }
    var i = 0;
    while (i < e.length) {
      final c = e[i];
      if (c == '"' || c == "'") {
        final end = _stringEnd(e, i);
        if (c == '"') _string(e.substring(i, end));
        i = end;
        continue;
      }
      // A number or a colour: not a name.
      if (RegExp(r'[0-9#]').hasMatch(c)) {
        i = RegExp(r'[0-9#][0-9A-Za-z_.#]*').matchAsPrefix(e, i)!.end;
        continue;
      }
      final m = _name.matchAsPrefix(e, i);
      if (m == null) {
        i++;
        continue;
      }
      final word = m[0]!;
      final field = i > 0 && e[i - 1] == '.';
      i = m.end;
      if (field) continue;
      var k = i;
      while (k < e.length && e[k] == ' ') {
        k++;
      }
      if (k < e.length && e[k] == '(') {
        if (events.contains(word)) fired.add(word);
        continue;
      }
      read.add(word);
    }
  }

  /// The actions of an event, without its braces.
  void actions(String a) {
    for (final part in _split(a, ';')) {
      final t = part.trim();
      if (t.isEmpty) continue;
      if (t.startsWith('{') && _close(t, 0) == t.length) {
        actions(t.substring(1, t.length - 1));
        continue;
      }
      // A choice: `cond ? a : b`, each branch actions.
      final q = _top(t, '?');
      if (q > 0) {
        final rest = t.substring(q + 1);
        final colon = _top(rest, ':');
        expression(t.substring(0, q));
        if (colon >= 0) {
          actions(rest.substring(0, colon));
          actions(rest.substring(colon + 1));
        } else {
          actions(rest);
        }
        continue;
      }
      if (RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)((?:\.[A-Za-z_][A-Za-z0-9_]*|\[[^\]]*\])*)\s*(=(?!=)|\+=|-=|\*=|/=|\+\+|--)(.*)$').firstMatch(t) case final m?) {
        set.add(m[1]!);
        expression('${m[2]} ${m[4]}');
        continue;
      }
      final verb = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*(.*)$').firstMatch(t);
      if (verb == null) {
        expression(t);
        continue;
      }
      final word = verb[1]!, arg = verb[2]!.trim();
      if (events.contains(word)) {
        fired.add(word);
        if (arg.startsWith('(')) expression(arg);
        continue;
      }
      switch (word) {
        case 'open' || 'close' || 'go' || 'scroll' || 'focus':
          // An id or a page; a braced one is worked out.
          if (arg.startsWith('{')) expression(arg);
        case 'toast' || 'announce' || 'copy' || 'link':
          if (arg.startsWith('"')) {
            _string(arg);
          } else if (arg.startsWith('{')) {
            expression(arg);
          }
        case 'emit':
          final value = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*\s*(.*)$').firstMatch(arg)?[1] ?? '';
          if (value.isNotEmpty) expression(value);
        case 'confirm':
          final then = RegExp(r'\sthen\s*\{').firstMatch(arg);
          if (then == null) {
            _string(arg);
          } else {
            _string(arg.substring(0, then.start));
            final open = arg.indexOf('{', then.start);
            actions(arg.substring(open + 1, _close(arg, open) - 1));
          }
        default:
          expression(t);
      }
    }
  }
}

/// [e] without the braces round all of it.
String _unbraced(String e) {
  final t = e.trim();
  return t.startsWith('{') && _close(t, 0) == t.length ? t.substring(1, t.length - 1) : t;
}

/// Where [c] is in [s] outside strings and brackets (-1: nowhere); a `?`
/// of `?.` or `??` is not one.
int _top(String s, String c) {
  var depth = 0;
  for (var i = 0; i < s.length; i++) {
    final ch = s[i];
    if (ch == '"' || ch == "'") {
      i = _stringEnd(s, i) - 1;
      continue;
    }
    if ('([{'.contains(ch)) depth++;
    if (')]}'.contains(ch)) depth--;
    if (depth == 0 && ch == c) {
      if (c == '?' && ((i + 1 < s.length && (s[i + 1] == '.' || s[i + 1] == '?')) || (i > 0 && s[i - 1] == '?'))) continue;
      return i;
    }
  }
  return -1;
}

List<String> _split(String s, String at) {
  final out = <String>[];
  var depth = 0, from = 0;
  for (var i = 0; i < s.length; i++) {
    final ch = s[i];
    if (ch == '"' || ch == "'") {
      i = _stringEnd(s, i) - 1;
      continue;
    }
    if ('([{'.contains(ch)) depth++;
    if (')]}'.contains(ch)) depth--;
    if (depth == 0 && ch == at) {
      out.add(s.substring(from, i));
      from = i + 1;
    }
  }
  out.add(s.substring(from));
  return out;
}

int _stringEnd(String s, int open) {
  final q = s[open];
  var depth = 0;
  for (var k = open + 1; k < s.length; k++) {
    final c = s[k];
    if (c == r'\') {
      k++;
    } else if (c == '{') {
      depth++;
    } else if (c == '}' && depth > 0) {
      depth--;
    } else if (c == q && depth == 0) {
      return k + 1;
    }
  }
  return s.length;
}

/// The end of the bracket opened at [open] (past its close).
int _close(String s, int open) {
  var depth = 0;
  for (var k = open; k < s.length; k++) {
    final c = s[k];
    if (c == '"' || c == "'") {
      k = _stringEnd(s, k) - 1;
      continue;
    }
    if ('([{'.contains(c)) depth++;
    if (')]}'.contains(c) && --depth == 0) return k + 1;
  }
  return s.length;
}
