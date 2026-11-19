// What a line's brackets say before anything reads it: a `)` or `]` that
// closes nothing, one that closes the other kind, and a `(` or `[` the line
// never closes, in a formula wherever the notation takes one (an `each`
// list, an `if` condition, a `state` value, a `{…}` value or action, a
// text's `{…}`). Before, the parser kept such a formula as written and the
// engine read nothing from it, with no word: test 10's kanban board wrote
// `each c in sortBy(filter(cards,x=>…)))),x=>…)`, one `)` too many, and drew
// no cards (docs/design/13-compact-notation.md, section 3).
//
// A quoted text is a text: its brackets are its own, but a `{…}` in it is a
// formula, read as one. A `'…'` is a text inside a formula. An unclosed `{`
// and a `}` that closes nothing are left to what reads the line (they are
// said there).
import 'notation.dart' show NotationIssue;

/// The issues of [text]'s brackets, at most one per line, each at its line
/// and column (1-based).
///
/// Lines are joined as the parser joins them: a `node {…}` or `document
/// {…}` whose JSON goes on over the next lines is JSON, said where it is
/// read, and not looked at here; a line that ends with `[`, `(` or `,` left
/// open goes on over the next (up to 60), read as one line, its issue at
/// its first line with the column in the joined line.
List<NotationIssue> notationBracketIssues(String text) {
  final out = <NotationIssue>[];
  final lines = [for (final l in text.split('\n')) l.endsWith('\r') ? l.substring(0, l.length - 1) : l];
  for (var i = 0; i < lines.length; i++) {
    var raw = lines[i];
    final t = raw.trimLeft();
    if (t.isEmpty || t.startsWith('//') || t.startsWith('```')) continue;
    if (_jsonLine.hasMatch(raw) && _opened(raw) > 0) {
      while (i + 1 < lines.length && _opened(raw) > 0) {
        raw = '$raw\n${lines[++i]}';
      }
      continue;
    }
    final start = i;
    if (RegExp(r'[\[(,]\s*$').hasMatch(raw) && _opened(raw) > 0) {
      while (i + 1 < lines.length && i - start < 60 && _opened(raw) > 0) {
        raw = '${raw.trimRight()} ${lines[++i].trim()}';
      }
    }
    if (_lineIssue(raw) case (final column, final message)) {
      out.add(NotationIssue(start + 1, column, i == start ? message : '$message (Lines ${start + 1} to ${i + 1} are read as one line; the column is in it.)'));
    }
  }
  return out;
}

final _jsonLine = RegExp(r'^\s*(?:node(?:#[A-Za-z_][A-Za-z0-9_-]*)?|document)\s*\{');

/// How many brackets [s] leaves open, quoted texts aside.
int _opened(String s) {
  var n = 0;
  var quoted = false;
  for (var k = 0; k < s.length; k++) {
    final c = s[k];
    if (quoted) {
      if (c == r'\') {
        k++;
      } else if (c == '"') {
        quoted = false;
      }
      continue;
    }
    if (c == '"') quoted = true;
    if ('([{'.contains(c)) n++;
    if (')]}'.contains(c)) n--;
  }
  return n;
}

/// What opens a quoted text: `"`, `'` in a formula, `\"` in a text's `{…}`.
const _quotes = {'"', "'", r'\"'};

/// A frame of the scan: a bracket ([open] at [column]), or a quoted text.
typedef _Frame = ({String open, int column, bool event});

(int, String)? _lineIssue(String raw) {
  final t = raw.trimLeft();
  final lead = raw.length - t.length;
  final word = RegExp(r'^[A-Za-z]+').stringMatch(t) ?? '';
  final stack = <_Frame>[];
  String clip(String s) => s.length > 40 ? '${s.substring(0, 37)}…' : s;
  // What the frames say the bracket at the top is in.
  String where() {
    for (final f in stack.reversed) {
      if (f.open == '{') return f.event ? 'the actions in {…} at column ${f.column}' : 'the formula in {…} at column ${f.column}';
      if (f.open == '"') return 'the text at column ${f.column}';
    }
    return switch (word) {
      'each' => "the list's formula",
      'if' => 'the condition',
      'state' || 'project' || 'let' => 'the value',
      _ => 'this line',
    };
  }

  bool code() => stack.isEmpty || !_quotes.contains(stack.last.open);
  // The groups that closed at the formula's own level, by region (0: the line; a "{"'s column).
  final closed = <({int open, int close, int region})>[];
  var k = lead;
  // A shortcut's chord is a key, whatever its character (`key [`, `key ]`).
  if (word == 'key') k = lead + (RegExp(r'^key\s+\S*').stringMatch(t)?.length ?? 3);
  // A definition's chord worked out from its use (`key {coalesce(keys, key)}`,
  // docs/design/20 section 13) is a formula: read as one.
  if (RegExp(r'^key\s+\{').hasMatch(t)) k = lead + t.indexOf('{');
  while (k < raw.length) {
    final c = raw[k];
    final col = k + 1;
    if (!code()) {
      final quote = stack.last.open;
      // A text in a text's `{…}` is quoted `\"…\"`.
      if (quote == r'\"' && c == r'\' && k + 1 < raw.length && raw[k + 1] == '"') {
        stack.removeLast();
        k += 2;
        continue;
      }
      if (c == r'\') {
        k += 2;
        continue;
      }
      if (c == quote) {
        stack.removeLast();
      } else if (quote == '"' && c == '{') {
        stack.add((open: '{', column: col, event: false));
      }
      k++;
      continue;
    }
    if (c == r'\' && k + 1 < raw.length && raw[k + 1] == '"') {
      stack.add((open: r'\"', column: col, event: false));
      k += 2;
      continue;
    }
    switch (c) {
      case '"':
        stack.add((open: '"', column: col, event: false));
      case "'":
        // A text in a formula: after an operator or an opening, with its end
        // on the line (an apostrophe elsewhere is a letter).
        final before = raw.substring(lead, k).trimRight();
        final opens = stack.any((f) => f.open != '"') || word == 'each' || word == 'if' || word == 'state';
        if (opens && (before.isEmpty || '=(,[{:?!&|+-<>'.contains(before[before.length - 1])) && raw.indexOf("'", k + 1) > k) {
          stack.add((open: "'", column: col, event: false));
        }
      case '(' || '[':
        stack.add((open: c, column: col, event: false));
      case '{':
        final event = RegExp(r'\bon[A-Z][A-Za-z0-9]*=$').hasMatch(raw.substring(0, k));
        stack.add((open: '{', column: col, event: event));
      case ')' || ']':
        final want = c == ')' ? '(' : '[';
        if (stack.isNotEmpty && stack.last.open == want) {
          final open = stack.removeLast();
          // The outermost group of this formula closed here.
          if (stack.isEmpty || stack.last.open == '{') closed.add((open: open.column, close: col, region: stack.isEmpty ? 0 : stack.last.column));
          break;
        }
        final what = where();
        if (stack.isEmpty || stack.last.open == '{' || stack.last.open == '"') {
          final region = stack.isEmpty ? 0 : stack.last.column;
          // What was read before: a group that closed early, with words after
          // it that were meant inside (`sortBy(filter(…))),x=>…)`).
          final formula = region != 0 || const {'each', 'if', 'state', 'project', 'let'}.contains(word);
          final early = closed.where((o) => o.region == region && raw.substring(o.close, k).trimLeft().startsWith(',')).firstOrNull;
          if (early case final o? when formula) {
            return (
              o.close,
              '$what ends at column ${o.close}: the "${raw[o.open - 1]}" at column ${o.open} is closed there, so the rest "${clip(raw.substring(o.close, k + 1))}" is not read, '
                  'and the "$c" at column $col closes nothing. One "$c" too many at column ${o.close} or before it, or one "$want" too few.',
            );
          }
          final rest = raw.substring(k + 1);
          return (
            col,
            '$what ends at column ${col - 1}: "$c" at column $col closes nothing, so ${rest.trim().isEmpty ? 'it is read without it' : 'the rest "${clip(rest)}" is not read'}. '
                'Remove it, or write the "$want" it closes.',
          );
        }
        final open = stack.last;
        return (
          col,
          '$what: "$c" at column $col closes the "${open.open}" at column ${open.column}, which "${open.open == '(' ? ')' : ']'}" closes. '
              'Close the "${open.open}" first, or write "$want" for it.',
        );
      case '}':
        if (!stack.any((f) => f.open == '{')) break;
        if (stack.last.open == '(' || stack.last.open == '[') {
          final open = stack.last;
          final what = where();
          return (open.column, '$what: "${open.open}" at column ${open.column} is not closed before its "}" at column $col. Close it.');
        }
        while (stack.isNotEmpty && stack.last.open != '{') {
          stack.removeLast();
        }
        stack.removeLast();
    }
    k++;
  }
  // A "(" or "[" the line never closes (an unclosed text or "{" is said by
  // what reads the line).
  if (stack.any((f) => _quotes.contains(f.open))) return null;
  for (var n = 0; n < stack.length; n++) {
    final f = stack[n];
    if (f.open != '(' && f.open != '[') continue;
    stack.removeRange(n + 1, stack.length);
    final what = where();
    return (
      f.column,
      '$what: "${f.open}" at column ${f.column} is never closed on this line, so "${clip(raw.substring(f.column - 1))}" is not read as written. '
          'Close it with "${f.open == '(' ? ')' : ']'}".',
    );
  }
  return null;
}
