// The formula engine's own functions, by name (codelessly_sdk's
// FormulaEvaluator.functions, as tool/reference/data/formulas.json lists
// them; test/notation_formula_names_test.dart keeps the two the same).
//
// A call reaches the engine's function before a page's function of the same
// name: `state matches(c):boolean={…}` was never called, `matches(c)` was the
// engine's text match (true for every card: test 9, kanban 1). The expander
// says so where such a function is declared.

/// The names of the formula engine's own functions.
const Set<String> notationFormulaFunctionNames = {
  'abs', 'acos', 'addDays', 'addHours', 'addMinutes', 'addMonths', 'addSeconds', 'all', 'alpha', 'any', 'append',
  'asin', 'at', 'atan', 'atan2', 'ceil', 'charCode', 'clamp', 'coalesce', 'codeUnits', 'compact', 'concat',
  'contains', 'cos', 'count', 'currency', 'currencyDecimals', 'currencySymbol', 'day', 'daysInMonth', 'degrees',
  'diffDays', 'diffHours', 'diffMinutes', 'diffSeconds', 'distance', 'duration', 'endsWith', 'exp', 'feetInches',
  'fill', 'filter', 'find', 'findIndex', 'first', 'fixed', 'flatMap', 'flatten', 'floor', 'formatAmount',
  'formatCurrency', 'formatDate', 'formatDuration', 'formatNumber', 'formatPercent', 'formatRelative',
  'fromCharCode', 'fuzzy', 'fuzzyScore', 'get', 'groupBy', 'hour', 'hypot', 'if', 'indexOf', 'insertAt',
  'interpolate', 'isAfter', 'isBefore', 'isEmpty', 'isFuture', 'isNotEmpty', 'isPast', 'isSameDay', 'isToday',
  'join', 'keys', 'last', 'left', 'length', 'lerpColor', 'ln', 'log', 'lower', 'luminance', 'map', 'matchRanges',
  'matchReason', 'matchRuns', 'matches', 'max', 'maxBy', 'merge', 'min', 'minBy', 'minute', 'mix', 'money', 'month',
  'move', 'moveItems', 'newId', 'now', 'nowMs', 'number', 'obj', 'object', 'pad', 'padLeft', 'padRight',
  'parseAmount', 'parseDate', 'pi', 'pick', 'plural', 'pluralCategory', 'pow', 'prepend', 'radians', 'random',
  'range', 'regexMatches', 'regexReplace','removeAt', 'removeWhere', 'replace', 'reverse', 'right', 'round', 'runs', 'second',
  'seconds', 'set', 'setAt', 'sign', 'sin', 'skip', 'slice', 'slug', 'sortBy', 'sortByDesc', 'split', 'sqrt',
  'startsWith', 'substring', 'sum', 'take', 'tan', 'text', 'textDirection', 'textDirectionOf', 'thousands',
  'timeAgo', 'titleCase', 'toMap', 'today', 'trim', 'unique', 'unset', 'updateWhere', 'upper', 'values', 'wallTime',
  'weekday', 'where', 'with', 'without', 'year',
};
