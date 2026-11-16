/// "Did you mean": the declared name an author meant when they wrote one that
/// is not declared, for every diagnostic that names a key, a type or an id.
///
/// Spelling alone is not enough for names written by models and by people
/// coming from other frameworks: `tap` is one edit from no trigger and is
/// contained in `doubleTap`, yet what is meant is `click`; `onPressed` on a
/// node means its `actions`; `Container` means a `box`. So [didYouMean] tries,
/// in order:
///
/// 1. the same name written another way: case, `_`, `-` and spaces ignored
///    (`on_tap` / `OnTap`), and an `on` prefix dropped (`onChanged` →
///    `changed`);
/// 2. what the word means here ([meantAs]): a word other frameworks, the DOM,
///    React, SwiftUI or Flutter use for one of these names;
/// 3. a near spelling: Damerau (optimal string alignment) distance, so a
///    swapped pair is one edit (`clikc` → `click`), within a limit that grows
///    with the word's length (≤ 4 letters: 1, ≤ 8: 2, longer: 3), ties broken
///    by Jaro-Winkler similarity (the prefix matters most);
/// 4. the same words in another order (`tapDouble` → `doubleTap`);
/// 5. the word as one of a name's words, a name's words all in the word, or
///    the word's words all in a name (`color` → `backgroundColor`,
///    `mainAlignment` → `mainAxisAlignment`), the closest by Jaro-Winkler.
///
/// This is how the best command-line tools suggest (rustc's
/// `find_best_match_for_name`, clap's Jaro threshold, git's weighted
/// Damerau), plus the table of meanings, which no string metric can find.
/// Pub's similarity packages (Dice coefficient, Fuse.js ports, fuzzywuzzy
/// ratios) rank by spelling only; this package keeps no dependency for it.
library;

/// The candidate an author writing [word] most likely meant, or null when none
/// is close enough to suggest.
String? didYouMean(String word, Iterable<String> candidates) {
  final list = candidates is List<String> ? candidates : candidates.toList(growable: false);
  if (list.isEmpty || word.isEmpty) return null;
  final w = _norm(word);
  final bare = _withoutOn(w);

  // 1. The same name written another way.
  for (final c in list) {
    if (c == word) return c;
  }
  // Each candidate normalized once, split into words at most once.
  final norms = [for (final c in list) _norm(c)];
  final split = List<List<String>?>.filled(list.length, null);
  List<String> wordsOf(int i) => split[i] ??= _words(list[i]);
  String? viaOn;
  for (var i = 0; i < list.length; i++) {
    if (norms[i] == w) return list[i];
    if (viaOn == null && bare != null && norms[i] == bare) viaOn = list[i];
  }
  if (viaOn != null) return viaOn;

  // 2. What the word means here.
  for (final key in [w, ?bare]) {
    for (final meant in meantAs[key] ?? const <String>[]) {
      for (final c in list) {
        if (c == meant) return c;
      }
    }
  }

  // 3. A near spelling.
  final limit = word.length <= 4 ? 1 : (word.length <= 8 ? 2 : 3);
  String? best;
  var bestD = limit + 1;
  var bestJw = -1.0;
  for (var i = 0; i < list.length; i++) {
    final n = norms[i];
    if ((n.length - w.length).abs() > limit) continue;
    final d = damerau(w, n);
    if (d > limit) continue;
    final jw = jaroWinkler(w, n);
    if (d < bestD || (d == bestD && jw > bestJw)) {
      best = list[i];
      bestD = d;
      bestJw = jw;
    }
  }
  if (best != null) return best;

  // 4. The same words in another order.
  final words = _words(word)..sort();
  if (words.length > 1) {
    for (var i = 0; i < list.length; i++) {
      final cw = wordsOf(i);
      if (cw.length == words.length && _same([...cw]..sort(), words)) return list[i];
    }
  }

  // 5. One of a name's words, a name's words all in the word, or the word's words all in a name.
  if (w.length >= 3) {
    best = null;
    bestJw = -1;
    final wordSet = words.toSet();
    for (var i = 0; i < list.length; i++) {
      final n = norms[i];
      final cw = wordsOf(i);
      final hit = cw.contains(w) || (cw.length > 1 && wordSet.containsAll(cw)) ||
          (wordSet.length > 1 && cw.toSet().containsAll(wordSet)) || (n.length >= 3 && w.contains(n)) ||
          (w.length >= 4 && n.contains(w));
      if (!hit) continue;
      final jw = jaroWinkler(w, n);
      if (jw > bestJw) {
        best = list[i];
        bestJw = jw;
      }
    }
    if (best != null) return best;
  }
  return null;
}

/// Words that name, in this API, something other than what they spell, each
/// with what it is meant as, most likely first. Keys are normalized (lower
/// case, no `_`, `-` or spaces); a meaning is suggested only when it is one of
/// the candidates, so one table serves keys, types, triggers and actions.
const Map<String, List<String>> meantAs = {
  // Action fields.
  'target': ['node', 'to'],
  'element': ['node'],
  'nodeid': ['node'],
  'scrollto': ['node', 'scrollTo'],
  'filename': ['fileName'],
  'name': ['fileName', 'key'],
  'file': ['fileName'],
  'content': ['text', 'value'],
  'contents': ['text', 'value'],
  'data': ['text', 'value'],
  'body': ['text'],
  'value': ['text'],
  'message': ['text'],
  'label': ['text'],
  'title': ['text'],
  'append': ['add'],
  'push': ['add', 'navigate'],
  'prepend': ['insert'],
  'delete': ['remove', 'removeAt'],
  'pop': ['removeAt', 'closeModal'],
  'increment': ['add'],
  'decrement': ['subtract'],
  'screen': ['to'],
  'destination': ['to'],
  'route': ['to', 'navigate'],
  'page': ['to'],
  'predicate': ['condition'],
  'if': ['condition'],
  'test': ['condition'],
  'variablename': ['variable'],
  'var': ['variable'],
  'storagekey': ['key'],
  // A node's reactions, by the names of its event props elsewhere.
  'tap': ['click'],
  'onclick': ['actions', 'click'],
  'onpress': ['actions', 'click'],
  'onpressed': ['actions', 'click'],
  'ontap': ['actions', 'click'],
  'events': ['actions'],
  'reactions': ['actions'],
  'handlers': ['actions'],
  'listeners': ['actions'],
  'child': ['children'],
  'kids': ['children'],
  'items': ['children', 'data'],
  // Triggers.
  'press': ['click'],
  'pressed': ['click'],
  'touch': ['click'],
  'select': ['click', 'dropdown'],
  'dblclick': ['doubleTap'],
  'doubleclick': ['doubleTap'],
  'longtap': ['longPress'],
  'longclick': ['longPress'],
  'rightclick': ['secondaryClick'],
  'contextmenu': ['secondaryClick'],
  'mouseenter': ['cursorEnter'],
  'mouseover': ['cursorEnter', 'hover'],
  'hoverstart': ['cursorEnter'],
  'mouseleave': ['cursorExit'],
  'mouseexit': ['cursorExit'],
  'mouseout': ['cursorExit'],
  'hoverend': ['cursorExit'],
  'change': ['changed'],
  'input': ['changed', 'textField'],
  'submit': ['submitted', 'submitForm'],
  'focus': ['focusGained', 'focus'],
  'blur': ['focusLost'],
  'unfocus': ['focusLost'],
  'mount': ['load'],
  'mounted': ['load'],
  'init': ['load'],
  'initstate': ['load'],
  'appear': ['load'],
  'ready': ['load'],
  'start': ['load'],
  'keypress': ['keyDown'],
  'visible': ['enterViewport'],
  'inview': ['enterViewport'],
  'tick': ['timer'],
  'interval': ['timer'],
  'every': ['timer'],
  // Node types, by their names in Flutter, the web, SwiftUI and React Native.
  'container': ['box', 'column'],
  'sizedbox': ['spacer', 'box'],
  'image': ['box'],
  'img': ['box'],
  'picture': ['box'],
  'avatar': ['box'],
  'view': ['column', 'box'],
  'div': ['column', 'box'],
  'card': ['column'],
  'vstack': ['column'],
  'hstack': ['row'],
  'zstack': ['stack'],
  'overlay': ['stack'],
  'button': ['filledButton', 'textButton'],
  'textinput': ['textField'],
  'textbox': ['textField'],
  'edittext': ['textField'],
  'textformfield': ['textField'],
  'paragraph': ['text'],
  'heading': ['text'],
  'span': ['text'],
  'p': ['text'],
  'h1': ['text'],
  'h2': ['text'],
  'list': ['listView'],
  'flatlist': ['listView'],
  'grid': ['gridView'],
  'table': ['tableView'],
  'toggle': ['switch'],
  'picker': ['dropdown'],
  'combobox': ['dropdown'],
  'progress': ['progressBar'],
  'spinner': ['activityIndicator', 'circularProgressIndicator'],
  'loader': ['activityIndicator', 'circularProgressIndicator'],
  'dialog': ['modal', 'openModal'],
  'alert': ['modal', 'openModal'],
  'popup': ['modal', 'openModal'],
  'separator': ['divider'],
  'hr': ['divider'],
  'carousel': ['pageView'],
  'pager': ['pageView'],
  // Action types.
  'set': ['setVariable', 'setValue'],
  'setstate': ['setVariable'],
  'assign': ['setVariable'],
  'update': ['setVariable'],
  'updatevariable': ['setVariable'],
  'goto': ['navigate'],
  'go': ['navigate'],
  'navigateto': ['navigate'],
  'openurl': ['openLink'],
  'launchurl': ['openLink'],
  'url': ['openLink'],
  'href': ['openLink'],
  'link': ['openLink'],
  'showdialog': ['openModal'],
  'showmodal': ['openModal'],
  'showbottomsheet': ['openModal'],
  'dismiss': ['closeModal'],
  'close': ['closeModal'],
  'closedialog': ['closeModal'],
  'back': ['closeModal', 'navigate'],
  'fetch': ['callApi'],
  'http': ['callApi'],
  'request': ['callApi'],
  'api': ['callApi'],
  'toast': ['showToast'],
  'snackbar': ['showToast'],
  'notify': ['showToast'],
  'wait': ['delay'],
  'sleep': ['delay'],
  'timeout': ['delay'],
  'log': ['print'],
  'console': ['print'],
  'script': ['runScript'],
  'eval': ['runScript'],
  'copy': ['copyToClipboard'],
  'clipboard': ['copyToClipboard'],
  'vibrate': ['haptic'],
  'sound': ['playSound'],
  'play': ['playSound'],
  'tts': ['speak'],
  'say': ['speak'],
  'download': ['downloadFile'],
  'theme': ['setThemeMode'],
  'darkmode': ['setThemeMode'],
  'save': ['setStorage'],
  'store': ['setStorage'],
  'persist': ['setStorage'],
  'loop': ['forEach'],
  'each': ['forEach'],
  'map': ['forEach'],
  'when': ['if', 'condition'],
};

/// The optimal string alignment distance: insertions, deletions,
/// substitutions and swaps of two neighbours each cost one.
int damerau(String a, String b) {
  final n = a.length, m = b.length;
  if (n == 0) return m;
  if (m == 0) return n;
  var prev2 = List<int>.filled(m + 1, 0);
  var prev = List<int>.generate(m + 1, (j) => j);
  for (var i = 1; i <= n; i++) {
    final cur = List<int>.filled(m + 1, 0)..[0] = i;
    for (var j = 1; j <= m; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      var v = prev[j] + 1;
      if (cur[j - 1] + 1 < v) v = cur[j - 1] + 1;
      if (prev[j - 1] + cost < v) v = prev[j - 1] + cost;
      if (i > 1 && j > 1 && a.codeUnitAt(i - 1) == b.codeUnitAt(j - 2) && a.codeUnitAt(i - 2) == b.codeUnitAt(j - 1)) {
        if (prev2[j - 2] + 1 < v) v = prev2[j - 2] + 1;
      }
      cur[j] = v;
    }
    prev2 = prev;
    prev = cur;
  }
  return prev[m];
}

/// Jaro-Winkler similarity, 0 to 1: shared characters near each other, with
/// a bonus for a shared prefix of up to four.
double jaroWinkler(String a, String b) {
  if (a == b) return 1;
  if (a.isEmpty || b.isEmpty) return 0;
  final range = ((a.length > b.length ? a.length : b.length) ~/ 2 - 1).clamp(0, 1 << 20);
  final aHit = List<bool>.filled(a.length, false), bHit = List<bool>.filled(b.length, false);
  var matches = 0;
  for (var i = 0; i < a.length; i++) {
    final lo = i - range < 0 ? 0 : i - range, hi = i + range + 1 > b.length ? b.length : i + range + 1;
    for (var j = lo; j < hi; j++) {
      if (bHit[j] || a.codeUnitAt(i) != b.codeUnitAt(j)) continue;
      aHit[i] = bHit[j] = true;
      matches++;
      break;
    }
  }
  if (matches == 0) return 0;
  var t = 0, k = 0;
  for (var i = 0; i < a.length; i++) {
    if (!aHit[i]) continue;
    while (!bHit[k]) {
      k++;
    }
    if (a.codeUnitAt(i) != b.codeUnitAt(k)) t++;
    k++;
  }
  final jaro = (matches / a.length + matches / b.length + (matches - t / 2) / matches) / 3;
  var prefix = 0;
  while (prefix < 4 && prefix < a.length && prefix < b.length && a.codeUnitAt(prefix) == b.codeUnitAt(prefix)) {
    prefix++;
  }
  return jaro + prefix * 0.1 * (1 - jaro);
}

final _separators = RegExp(r'[\s_\-]+');
final _wordPattern = RegExp(r'[A-Z]?[a-z0-9]+|[A-Z]+(?![a-z])');

String _norm(String s) => s.toLowerCase().replaceAll(_separators, '');

/// `ontap` → `tap`: event props are often written with an `on` prefix.
String? _withoutOn(String n) => n.length > 3 && n.startsWith('on') ? n.substring(2) : null;

/// `doubleTap`, `double_tap`, `double-tap` → [double, tap].
List<String> _words(String s) => [
      for (final m in _wordPattern.allMatches(s.replaceAll(_separators, ' ')))
        m.group(0)!.toLowerCase(),
    ];

bool _same(List<String> a, List<String> b) {
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
