// A definition's values worked out as a use is read (docs/design/20 section
// 13): an expression of a body whose names were all put in from the use's
// written values (`{size/4}` with `size=40`, `{upper(label)}` with a written
// label, `level == 1` with `level=2`) reads nothing at run time, so it is
// worked out here, as the formula engine would: `radius=10`, not a binding
// of `40/4`. An expression that still names anything (a variable of the
// page, the row of an `each`, a state of the word's own) is left to the
// engine, as before.

/// The value of [expression] (a formula, as a body's braces hold it once the
/// use's values are put in), or [unknown] when it names anything, calls a
/// function this does not work out, or is not a formula this reads.
Object? foldExpression(String expression) {
  try {
    final p = _Parser(expression);
    final v = p.ternary();
    p.space();
    if (!p.done) return unknown;
    return v;
  } on _Unknown {
    return unknown;
  }
}

/// What [foldExpression] gives for an expression it does not work out.
const Object unknown = _UnknownValue();

final class _UnknownValue {
  const _UnknownValue();
}

final class _Unknown implements Exception {
  const _Unknown();
}

/// Whether [value] counts as true, as the formula engine counts it.
bool foldTruthy(Object? value) => switch (value) {
      null => false,
      final bool b => b,
      final num n => n != 0,
      final String s => s.isNotEmpty && s.toLowerCase() != 'false',
      _ => true,
    };

/// [value] as a line writes it after `key=`: a number as its digits (a whole
/// one without a point), true and false, a colour or a plain word as it is,
/// any other text in quotes. Null for a value that has no such form.
String? foldWritten(Object? value) => switch (value) {
      final bool b => '$b',
      final num n => foldNumber(n),
      final String s when RegExp(r'^(#[0-9A-Fa-f]{6,8}|[A-Za-z_][A-Za-z0-9_]*)$').hasMatch(s) && s != 'true' && s != 'false' && s != 'null' => s,
      final String s when !s.contains('{') => '"${s.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"',
      _ => null,
    };

/// [value] as it shows in a text: a number as its digits, text as it is.
String? foldText(Object? value) => switch (value) {
      final num n => foldNumber(n),
      final bool b => '$b',
      final String s when !s.contains('{') => s,
      _ => null,
    };

/// A number as the engine writes one: a whole number without its point.
String foldNumber(num n) => n == n.roundToDouble() && n.abs() < 1e15 ? '${n.round()}' : '$n';

num _tidy(num n) => n == n.roundToDouble() && n.abs() < 1e15 ? n.round() : n;

num _num(Object? v) => switch (v) {
      null => 0,
      final num n => n,
      final bool b => b ? 1 : 0,
      final String s when s.trim().isEmpty => 0,
      final String s => num.tryParse(s.trim()) ?? (throw const _Unknown()),
      _ => throw const _Unknown(),
    };

String _str(Object? v) => switch (v) {
      null => '',
      final num n => foldNumber(n),
      final bool b => '$b',
      final String s => s,
      _ => throw const _Unknown(),
    };

bool _equals(Object? a, Object? b) {
  if (a == null || b == null) return a == b;
  if (a is num && b is num) return a == b;
  if (a is String && b is String) return a == b;
  if (a is bool && b is bool) return a == b;
  // Text against a number, or a flag: the engine compares them loosely;
  // left to it.
  throw const _Unknown();
}

final class _Parser {
  _Parser(this.s);
  final String s;
  int i = 0;

  bool get done => i >= s.length;

  void space() {
    while (i < s.length && s[i].trim().isEmpty) {
      i++;
    }
  }

  bool eat(String t) {
    space();
    if (s.startsWith(t, i)) {
      i += t.length;
      return true;
    }
    return false;
  }

  Object? ternary() {
    final c = or();
    space();
    if (eat('?')) {
      final a = ternary();
      if (!eat(':')) throw const _Unknown();
      final b = ternary();
      return foldTruthy(c) ? a : b;
    }
    return c;
  }

  Object? or() {
    var a = and();
    while (eat('||')) {
      final b = and();
      a = foldTruthy(a) ? a : b;
    }
    return a;
  }

  Object? and() {
    var a = equality();
    while (eat('&&')) {
      final b = equality();
      a = foldTruthy(a) ? b : a;
    }
    return a;
  }

  Object? equality() {
    var a = compare();
    while (true) {
      if (eat('==')) {
        a = _equals(a, compare());
      } else if (eat('!=')) {
        a = !_equals(a, compare());
      } else {
        return a;
      }
    }
  }

  Object? compare() {
    var a = additive();
    while (true) {
      space();
      final op = ['<=', '>=', '<', '>'].where((o) => s.startsWith(o, i)).firstOrNull;
      if (op == null) return a;
      i += op.length;
      final b = additive();
      if (a is! num || b is! num) throw const _Unknown();
      a = switch (op) { '<' => a < b, '<=' => a <= b, '>' => a > b, _ => a >= b };
    }
  }

  Object? additive() {
    var a = multiplicative();
    while (true) {
      space();
      if (i < s.length && (s[i] == '+' || s[i] == '-')) {
        final op = s[i++];
        final b = multiplicative();
        if (op == '+') {
          if (a is String || b is String) {
            final na = a is String ? null : a, nb = b is String ? null : b;
            if (na is num && nb is num) {
              a = _tidy(na + nb);
            } else {
              a = _str(a) + _str(b);
            }
          } else {
            a = _tidy(_num(a) + _num(b));
          }
        } else {
          a = _tidy(_num(a) - _num(b));
        }
      } else {
        return a;
      }
    }
  }

  Object? multiplicative() {
    var a = unary();
    while (true) {
      space();
      if (i < s.length && (s[i] == '*' || s[i] == '/' || s[i] == '%')) {
        final op = s[i++];
        final b = unary();
        final x = _num(a), y = _num(b);
        a = switch (op) {
          '*' => _tidy(x * y),
          '/' => y == 0 ? null : _tidy(x / y),
          _ => y == 0 ? null : _tidy(x % y),
        };
      } else {
        return a;
      }
    }
  }

  Object? unary() {
    space();
    if (i < s.length && s[i] == '!' && !s.startsWith('!=', i)) {
      i++;
      return !foldTruthy(unary());
    }
    if (i < s.length && s[i] == '-') {
      i++;
      return _tidy(-_num(unary()));
    }
    return primary();
  }

  Object? primary() {
    space();
    if (done) throw const _Unknown();
    final c = s[i];
    if (c == '(') {
      i++;
      final v = ternary();
      if (!eat(')')) throw const _Unknown();
      return v;
    }
    if (c == '"' || c == "'") return _string(c);
    if (RegExp(r'[0-9.]').hasMatch(c)) {
      final m = RegExp(r'[0-9]*\.?[0-9]+').matchAsPrefix(s, i);
      if (m == null) throw const _Unknown();
      i = m.end;
      return _tidy(num.parse(m[0]!));
    }
    // A colour as a body writes it (`#FF2563EB`): its text.
    if (c == '#') {
      final m = RegExp(r'#[0-9A-Fa-f]{6,8}(?![0-9A-Za-z_])').matchAsPrefix(s, i);
      if (m == null) throw const _Unknown();
      i = m.end;
      return m[0];
    }
    final m = RegExp(r'[A-Za-z_][A-Za-z0-9_]*').matchAsPrefix(s, i);
    if (m == null) throw const _Unknown();
    i = m.end;
    final word = m[0]!;
    space();
    if (i < s.length && s[i] == '(') {
      i++;
      final args = <Object?>[];
      if (!eat(')')) {
        do {
          args.add(ternary());
        } while (eat(','));
        if (!eat(')')) throw const _Unknown();
      }
      return _call(word, args);
    }
    return switch (word) {
      'true' => true,
      'false' => false,
      'null' => null,
      // A name: read at run time.
      _ => throw const _Unknown(),
    };
  }

  String _string(String q) {
    final b = StringBuffer();
    i++;
    while (i < s.length && s[i] != q) {
      if (s[i] == r'\' && i + 1 < s.length) {
        b.write(s[i + 1]);
        i += 2;
        continue;
      }
      // A value read inside a text (`"{x}"`): the engine's.
      if (s[i] == '{') throw const _Unknown();
      b.write(s[i++]);
    }
    if (i >= s.length) throw const _Unknown();
    i++;
    return b.toString();
  }

  static Object? _call(String name, List<Object?> a) {
    Object? arg(int n) => n < a.length ? a[n] : null;
    return switch (name) {
      'upper' when a.length == 1 => _str(arg(0)).toUpperCase(),
      'lower' when a.length == 1 => _str(arg(0)).toLowerCase(),
      'trim' when a.length == 1 => _str(arg(0)).trim(),
      'round' when a.length == 1 || (a.length == 2 && _num(arg(1)) <= 0) => _num(arg(0)).round(),
      'floor' when a.length == 1 => _num(arg(0)).floor(),
      'ceil' when a.length == 1 => _num(arg(0)).ceil(),
      'abs' when a.length == 1 => _tidy(_num(arg(0)).abs()),
      'min' when a.length == 2 => _tidy(_num(arg(0)) < _num(arg(1)) ? _num(arg(0)) : _num(arg(1))),
      'max' when a.length == 2 => _tidy(_num(arg(0)) > _num(arg(1)) ? _num(arg(0)) : _num(arg(1))),
      'coalesce' when a.isNotEmpty => a.firstWhere((x) => x != null && x != '', orElse: () => a.lastWhere((x) => x != null, orElse: () => null)),
      'if' when a.length == 3 => foldTruthy(arg(0)) ? arg(1) : arg(2),
      'startsWith' when a.length == 2 => _str(arg(0)).startsWith(_str(arg(1))),
      'endsWith' when a.length == 2 => _str(arg(0)).endsWith(_str(arg(1))),
      'replace' when a.length == 3 => _str(arg(0)).replaceAll(_str(arg(1)), _str(arg(2))),
      _ => throw const _Unknown(),
    };
  }
}

/// [expression] with each call of a function [foldExpression] works out
/// (`coalesce(null, "#FF6B7280")`, `round(40/4)`) whose arguments name
/// nothing written as its value, where the rest of the expression still
/// reads something at run time: `(on) ? "#FF2563EB" : coalesce(null,
/// "#FF6B7280")` is `(on) ? "#FF2563EB" : "#FF6B7280"`, as the page words
/// write it.
String foldCalls(String expression) {
  const names = {'upper', 'lower', 'trim', 'round', 'floor', 'ceil', 'abs', 'min', 'max', 'coalesce', 'replace', 'startsWith', 'endsWith'};
  var s = expression;
  var from = 0;
  while (true) {
    final m = RegExp(r'(?<![A-Za-z0-9_.])([A-Za-z_][A-Za-z0-9_]*)\(').allMatches(s, from).where((m) => names.contains(m[1]) && !_quoted(s, m.start)).firstOrNull;
    if (m == null) return s;
    var depth = 0, end = -1;
    for (var k = m.end - 1; k < s.length; k++) {
      final c = s[k];
      if (c == '"' || c == "'") {
        final close = s.indexOf(c, k + 1);
        if (close < 0) return s;
        k = close;
        continue;
      }
      if (c == '(') depth++;
      if (c == ')' && --depth == 0) {
        end = k + 1;
        break;
      }
    }
    if (end < 0) return s;
    final v = foldExpression(s.substring(m.start, end));
    final w = identical(v, unknown) ? null : _literal(v);
    if (w == null) {
      from = m.end;
      continue;
    }
    s = '${s.substring(0, m.start)}$w${s.substring(end)}';
    from = m.start + w.length;
  }
}

bool _quoted(String s, int at) {
  var q = '';
  for (var i = 0; i < at; i++) {
    final c = s[i];
    if (q.isNotEmpty) {
      if (c == r'\') {
        i++;
      } else if (c == q) {
        q = '';
      }
    } else if (c == '"' || c == "'") {
      q = c;
    }
  }
  return q.isNotEmpty;
}

String? _literal(Object? v) => switch (v) {
      null => 'null',
      final bool b => '$b',
      final num n => foldNumber(n),
      final String s when !s.contains('{') && !s.contains('"') && !s.contains(r'\') => '"$s"',
      _ => null,
    };
