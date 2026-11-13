// Finding `${...}` expressions in text, as the SDK's expression engine
// reads them: `${path}` reads a value, `${= formula}` computes one.

/// One `${...}` in a text.
typedef Expression = ({String source, bool formula, int start});

/// What a formula checker tells about one formula (the text inside
/// `${= ...}`): why it doesn't parse (null when it does) and the variable
/// paths it reads (`qty`, `user.name`).
typedef FormulaReport = ({String? error, Set<String> paths});

/// Parses formulas for [validateDocument]. The formula language is the
/// SDK's; pure-Dart validation without one only checks that each `${`
/// closes.
typedef FormulaChecker = FormulaReport Function(String formula);

/// The expressions in [text], and the first syntax problem (an unclosed
/// `${`, an empty `${}`), as the SDK scans them: quotes and nested braces
/// inside an expression are skipped; `\${` is literal.
({List<Expression> expressions, String? error}) scanExpressions(String text) {
  final out = <Expression>[];
  var from = 0;
  while (true) {
    final start = text.indexOf(r'${', from);
    if (start < 0) return (expressions: out, error: null);
    if (start > 0 && text[start - 1] == r'\') {
      from = start + 2;
      continue;
    }
    var depth = 1;
    var pos = start + 2;
    String? quote;
    while (pos < text.length && depth > 0) {
      final c = text[pos];
      if (quote != null) {
        if (c == r'\') {
          pos++;
        } else if (c == quote) {
          quote = null;
        }
      } else if (c == "'" || c == '"') {
        quote = c;
      } else if (c == '{') {
        depth++;
      } else if (c == '}') {
        depth--;
      }
      pos++;
    }
    if (depth > 0) {
      final shown = text.length - start > 40 ? '${text.substring(start, start + 40)}...' : text.substring(start);
      return (
        expressions: out,
        error: '"$shown" is not closed: write \${name} or \${= formula}, with its quotes closed and braces balanced.',
      );
    }
    final inner = text.substring(start + 2, pos - 1);
    final trimmed = inner.trim();
    if (trimmed.isEmpty || trimmed == '=') {
      return (expressions: out, error: 'An empty expression "${text.substring(start, pos)}".');
    }
    final formula = trimmed.startsWith('=');
    out.add((source: formula ? trimmed.substring(1).trim() : trimmed, formula: formula, start: start));
    from = pos;
  }
}

/// The name a `${path}` reads first: `user` of `user.name`, `cart` of
/// `cart[0].qty`. Null when the path doesn't start with a name.
String? rootName(String path) => RegExp(r'^\s*([A-Za-z_$][A-Za-z0-9_$]*)').firstMatch(path)?.group(1);

/// Names the runtime provides to every expression (besides the screen's
/// variables): the app's data, route params, device storage, the screen's
/// size class, the theme, a list's item, the previous action's result,
/// a loop's item, auth, drag and drop, frame timings, node scopes (a drag
/// track, transform gesture, flip card, tilt, view progress, sticky header),
/// scripts and speech.
const Set<String> runtimeScopes = {
  'data', 'route', 'storage', 'screen', 'theme', 'item', 'index', 'parent', 'result', 'loop', 'auth', //
  'drag', 'perf', 'track', 'transform', 'flip', 'tilt', 'view', 'sticky', 'script', 'speech', 'pageOffset',
};
