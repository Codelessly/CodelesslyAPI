// The open vocabulary (docs/design/19-open-vocabulary.md): the words a text
// may use that the notation does not have, what each use is recorded as
// ([VocabularyUse]), and the names read as a word it does have
// ([NotationVocabulary], the alias table).
//
// The grammar is not open: a line is still `Type[.variant][#id] ["text"]
// [key=value ...]`. Only the words are.
import '../json.dart';
import 'define.dart' show NotationDefinition, readDefinitions;

/// One use of a word the notation has no meaning for (or an alias of one it
/// has): what was written, where, and enough of its line to map the word to
/// one that exists or to build it.
final class VocabularyUse {
  VocabularyUse({
    required this.kind,
    required this.word,
    required this.source,
    required this.line,
    required this.column,
    this.on,
    this.value,
    this.to,
    this.node,
    this.path = const [],
    this.texts = const [],
    this.parameters = const {},
    this.flags = const [],
    this.events = const {},
    List<String>? children,
  }) : children = children ?? [];

  /// `type` (a line's first word), `parameter` (a key=value), `flag` (a
  /// bare word), `event` (an on… key), `verb` (an action's first word),
  /// `variant` (the word after a type's dot) or `alias` (a name read as
  /// another: [to] says which, [of] what kind of word it is).
  final String kind;

  /// The word as written (`SeatMap`, `tooltip`, `selectable`, `onSeek`,
  /// `haptic`, `Button.danger`).
  final String word;

  /// The type whose line it is on (null for a type, and for a verb in a
  /// line that is not a node's: `every`, `key`).
  final String? on;

  /// Its value as written (`{row.name}`, `"Archive"`, `3`); a verb's
  /// argument; null for a flag and a type.
  final String? value;

  /// An alias: what the word was read as (`Slider`, `enabled`, `go`, or a
  /// whole line), and in [of] the kind of word it is.
  final String? to;

  /// A stand-in's node id in the document (a `type` only).
  final String? node;

  /// The whole line as written, without its indentation.
  final String source;

  /// 1-based.
  final int line, column;

  /// The words of the lines it is under, outermost first (`App`, `Main`,
  /// `Card`); `if` and `each` lines are not words.
  final List<String> path;

  /// A type's strings, its key=value pairs (as written), its bare words,
  /// its events (the actions as written) and the first words of the lines
  /// directly under it.
  final List<String> texts;
  final Map<String, String> parameters;
  final List<String> flags;
  final Map<String, String> events;
  final List<String> children;

  /// An alias: the kind of word it is (`type`, `parameter`, `flag`,
  /// `event`, `verb`, `line`).
  String? get of => kind == 'alias' ? _of : null;
  String? _of;

  Json toJson() => {
        'kind': kind,
        'word': word,
        if (_of != null) 'of': _of,
        if (to != null) 'to': to,
        if (on != null) 'on': on,
        if (value != null) 'value': value,
        if (node != null) 'node': node,
        'line': line,
        'column': column,
        'source': source,
        'path': path,
        if (kind == 'type') ...{
          'texts': texts,
          'parameters': parameters,
          'flags': flags,
          'events': events,
          'children': children,
        },
      };

  @override
  String toString() => '$kind ${on == null ? '' : '$on.'}$word${to == null ? '' : ' -> $to'} (line $line:$column)';
}

/// An alias use, of a word of kind [of].
VocabularyUse aliasUse({
  required String of,
  required String word,
  required String to,
  required String source,
  required int line,
  required int column,
  String? on,
  String? value,
  List<String> path = const [],
}) =>
    VocabularyUse(kind: 'alias', word: word, to: to, source: source, line: line, column: column, on: on, value: value, path: path).._of = of;

/// A type read as another: `RangeSlider` is a `Slider`, with its own names
/// for that type's parameters.
final class TypeAlias {
  const TypeAlias({this.to, this.parameters = const {}, this.add, this.line, this.requires = const []});

  factory TypeAlias.fromJson(Object? json) {
    if (json is String) return TypeAlias(to: json);
    final m = readMap(json) ?? const <String, Object?>{};
    return TypeAlias(
      to: readString(m['to']),
      add: readString(m['add']),
      line: readString(m['line']),
      requires: [
        for (final k in (m['requires'] as List?) ?? const <Object?>[])
          if (k is String) k,
      ],
      parameters: {
        for (final e in (readMap(m['parameters']) ?? const <String, Object?>{}).entries)
          if (e.value is String) e.key: e.value! as String,
      },
    );
  }

  /// The type it is read as.
  final String? to;

  /// Its own names for that type's parameters, flags and events, each by
  /// what it is read as (the forms of [NotationVocabulary.parameters]).
  /// These hold whatever the target type calls its own.
  final Map<String, String> parameters;

  /// The keys the line has to have, once its own names are read, for the
  /// alias to hold (a RangeSlider is our Slider only with a variable for each
  /// end); without them the word is left as it was written.
  final List<String> requires;

  /// Words added to the line (`selected` on a chip that is always on).
  final String? add;

  /// The line is of another shape altogether: the name of the rewrite in
  /// code that reads it ([lineRewrites]: `shortcut`, `confirmDialog`).
  final String? line;

  Object toJson() => to != null && parameters.isEmpty && add == null && line == null && requires.isEmpty
      ? to!
      : {
          if (to != null) 'to': to,
          if (line != null) 'line': line,
          if (requires.isNotEmpty) 'requires': requires,
          if (parameters.isNotEmpty) 'parameters': parameters,
          if (add != null) 'add': add,
        };
}

/// The alias table: many names, one meaning. A name here is never a word
/// the notation (or the design system in use) already has: that word wins.
///
/// JSON (`vocabulary.json` in a design system's folder, or a file given to
/// the tools):
///
///     {
///       "types":      {"RangeSlider": {"to": "Slider", "parameters": {"low": "bind", "high": "bindEnd"}},
///                      "Shortcut": {"line": "shortcut"}},
///       "parameters": {"*": {"disabled": "!enabled"}, "ListTile": {"subtitle": "$text"}},
///       "flags":      {"*": {"disabled": "enabled=false"}},
///       "events":     {"*": {"onClick": "onTap"}},
///       "verbs":      {"navigate": "go"}
///     }
///
/// A parameter is read as another key (`enabled`), as that key with its
/// value negated (`!enabled`), or as a further string of the line
/// (`$text`). A flag is read as the words written (`enabled=false`). `*`
/// holds for every type; a type's own entry comes first.
final class NotationVocabulary {
  const NotationVocabulary({
    this.types = const {},
    this.parameters = const {},
    this.flags = const {},
    this.events = const {},
    this.verbs = const {},
    this.definitions = const {},
  });

  factory NotationVocabulary.fromJson(Json json) {
    Map<String, Map<String, String>> byType(Object? v) => {
          for (final e in (readMap(v) ?? const <String, Object?>{}).entries)
            e.key: {
              for (final a in (readMap(e.value) ?? const <String, Object?>{}).entries)
                if (a.value is String) a.key: a.value! as String,
            },
        };
    return NotationVocabulary(
      types: {
        for (final e in (readMap(json['types']) ?? const <String, Object?>{}).entries) e.key: TypeAlias.fromJson(e.value),
      },
      parameters: byType(json['parameters']),
      flags: byType(json['flags']),
      events: byType(json['events']),
      verbs: {
        for (final e in (readMap(json['verbs']) ?? const <String, Object?>{}).entries)
          if (e.value is String) e.key: e.value! as String,
      },
    );
  }

  final Map<String, TypeAlias> types;
  final Map<String, Map<String, String>> parameters, flags, events;
  final Map<String, String> verbs;

  /// The words defined in the notation itself, by word
  /// (docs/design/20-defined-words.md): each is a word we have. Several for
  /// one word are its meanings, the one a use fits best read.
  final Map<String, List<NotationDefinition>> definitions;

  /// No aliases ([definitions] aside).
  bool get isEmpty => types.isEmpty && parameters.isEmpty && flags.isEmpty && events.isEmpty && verbs.isEmpty;

  /// This table with [other]'s entries added; where both name a word,
  /// [other]'s is the one read (a design system's over the built-in one).
  NotationVocabulary merge(NotationVocabulary other) {
    Map<String, Map<String, String>> both(Map<String, Map<String, String>> a, Map<String, Map<String, String>> b) => {
          for (final k in {...a.keys, ...b.keys}) k: {...?a[k], ...?b[k]},
        };
    return NotationVocabulary(
      types: {...types, ...other.types},
      parameters: both(parameters, other.parameters),
      flags: both(flags, other.flags),
      events: both(events, other.events),
      verbs: {...verbs, ...other.verbs},
      definitions: {...definitions, ...other.definitions},
    );
  }

  /// This table with the words defined in [texts] (each a file's text by its
  /// name: `StickyNote.txt`) over its own; what could not be read is left out
  /// ([readDefinitions] says what).
  NotationVocabulary define(Map<String, String> texts) => merge(NotationVocabulary(definitions: readDefinitions(texts).words));

  Json toJson() => {
        'types': {for (final e in types.entries) e.key: e.value.toJson()},
        'parameters': parameters,
        'flags': flags,
        'events': events,
        'verbs': verbs,
      };

  /// No aliases at all.
  static const none = NotationVocabulary();

  /// The names models reach for (SDK tool/vocabulary/corpus) for words the
  /// notation has under another name. Each was checked against what the
  /// parser accepts; `test/notation_vocabulary_test.dart` expands every one
  /// beside our own spelling.
  static const core = NotationVocabulary(
    types: {
      // A keyboard shortcut of the screen (13 of 20 apps): ours is the line
      // `key mod+k onPress={…}`.
      'Shortcut': TypeAlias(line: 'shortcut'),
      'shortcut': TypeAlias(line: 'shortcut'),
      // A value worked out from the state: ours is `state name=formula`.
      'computed': TypeAlias(line: 'computed'),
      // A question with a yes and a no, over the page: a Dialog with its two
      // buttons.
      'ConfirmDialog': TypeAlias(line: 'confirmDialog'),
      // A slider with two thumbs: ours when the line names a variable for
      // each end. (Most answers bind one list variable, which ours does not
      // take: those stay unknown.)
      'RangeSlider': TypeAlias(to: 'Slider', requires: ['bind', 'bindEnd'], parameters: {
        'low': 'bind', 'lo': 'bind', 'bindLow': 'bind', 'bindStart': 'bind', 'start': 'bind', //
        'high': 'bindEnd', 'hi': 'bindEnd', 'bindHigh': 'bindEnd', 'end': 'bindEnd',
      }),
      // A text with what matched a search marked in it.
      'Highlight': TypeAlias(to: 'Text', parameters: {'match': 'mark', 'query': 'mark'}),
      'HighlightText': TypeAlias(to: 'Text', parameters: {'match': 'mark', 'query': 'mark'}),
      // A month in the page.
      'MiniCalendar': TypeAlias(to: 'Calendar'),
      'CalendarMonth': TypeAlias(to: 'Calendar'),
      'MonthGrid': TypeAlias(to: 'Calendar'),
    },
    parameters: {
      '*': {
        // We teach enabled=; 12 of 20 apps wrote its opposite on a Button.
        'disabled': '!enabled',
      },
      // A ListTile's second string is its subtitle (10 of 20 apps named it).
      'ListTile': {'subtitle': r'$text', 'title': r'$text'},
    },
    flags: {
      '*': {'disabled': 'enabled=false'},
      // A value kept on the device: ours is `state draft="" saved` (12 of 20
      // apps wrote persist, which was read into the value).
      'state': {'persist': 'saved', 'persisted': 'saved', 'persistent': 'saved'},
      'project': {'persist': 'saved', 'persisted': 'saved', 'persistent': 'saved'},
    },
  );
}

/// One part of a line after its head: a string, a key=value, a bare word
/// or the `{…}` at its end.
final class LinePart {
  LinePart.string(this.raw)
      : key = null,
        value = null,
        kind = 'string';
  LinePart.pair(String this.key, String this.value)
      : raw = '$key=$value',
        kind = 'pair';
  LinePart.word(this.raw)
      : key = null,
        value = null,
        kind = 'word';
  LinePart.tail(this.raw)
      : key = null,
        value = null,
        kind = 'tail';

  /// `string`, `pair`, `word` or `tail`.
  final String kind;
  final String? key, value;

  /// As written (a string with its quotes).
  final String raw;

  /// Where it starts in the line, from 0 (-1: not from the text).
  int at = -1;

  bool get isEvent => kind == 'pair' && RegExp(r'^on[A-Z][A-Za-z]*$').hasMatch(key!);
}

/// A line split into its head and parts, as the grammar says a line is.
final class LineParts {
  LineParts._(this.word, this.variant, this.id, this.parts);

  /// Null when [text] (one line, no indentation) does not start with a word.
  static LineParts? of(String text) {
    final head = RegExp(r'^([A-Za-z][A-Za-z0-9]*)((?:\.[A-Za-z][A-Za-z0-9]*)*)(#[A-Za-z_][A-Za-z0-9_-]*)?(?= |$)').firstMatch(text);
    if (head == null) return null;
    final parts = <LinePart>[];
    var i = head.end;
    final n = text.length;
    int closeOfString(int open) {
      var depth = 0;
      for (var k = open + 1; k < n; k++) {
        final c = text[k];
        if (c == r'\') {
          k++;
        } else if (c == '{') {
          depth++;
        } else if (c == '}' && depth > 0) {
          depth--;
        } else if (c == '"' && depth == 0) {
          return k + 1;
        }
      }
      return n;
    }

    int closeOfBalanced(int open) {
      var depth = 0, quoted = false;
      for (var k = open; k < n; k++) {
        final c = text[k];
        if (c == '"' && text[k - 1] != r'\') quoted = !quoted;
        if (quoted) continue;
        if (c == '[' || c == '{' || c == '(') depth++;
        if ((c == ']' || c == '}' || c == ')') && --depth == 0) return k + 1;
      }
      return n;
    }

    while (i < n) {
      if (text[i] == ' ') {
        i++;
        continue;
      }
      final start = i;
      if (text[i] == '"') {
        i = closeOfString(i);
        parts.add(LinePart.string(text.substring(start, i))..at = start);
        continue;
      }
      if (text[i] == '{') {
        parts.add(LinePart.tail(text.substring(i))..at = start);
        break;
      }
      // A word, up to a space; a value after = may be a string or bracketed.
      String? key;
      while (i < n && text[i] != ' ') {
        final c = text[i];
        if (c == '=' && key == null && i > start && RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(text.substring(start, i))) {
          key = text.substring(start, i);
          i++;
          if (i < n && text[i] == '"') {
            i = closeOfString(i);
            break;
          }
          if (i < n && (text[i] == '{' || text[i] == '[')) {
            i = closeOfBalanced(i);
            break;
          }
          continue;
        }
        if (c == '"' && key == null) break;
        i++;
      }
      if (i == start) {
        i++;
        continue;
      }
      final raw = text.substring(start, i);
      parts.add((key == null ? LinePart.word(raw) : LinePart.pair(key, raw.substring(key.length + 1)))..at = start);
    }
    return LineParts._(head[1]!, head[2]!, head[3] ?? '', parts);
  }

  /// The line's first word, its `.variant`s and its `#id` (each as written,
  /// with its mark, or empty).
  String word;
  final String variant, id;
  final List<LinePart> parts;

  Iterable<LinePart> get strings => parts.where((p) => p.kind == 'string');
  LinePart? pair(String key) => parts.where((p) => p.kind == 'pair' && p.key == key).firstOrNull;
  bool has(String flag) => parts.any((p) => p.kind == 'word' && p.raw == flag);

  @override
  String toString() => ['$word$variant$id', for (final p in parts) p.raw].join(' ');
}

/// A value as a quoted string of the line: `"Archive"` as it is, `{x}` as
/// `"{x}"`, a bare word in quotes.
String asLineString(String value) {
  if (value.startsWith('"')) return value;
  if (value.startsWith('{') && value.endsWith('}')) return '"$value"';
  return '"$value"';
}

/// A value negated: `{x}` as `{!(x)}`, `true` as `false`.
String negatedValue(String value) {
  final v = value.trim();
  if (v == 'true' || v == '{true}') return 'false';
  if (v == 'false' || v == '{false}') return 'true';
  if (v.startsWith('{') && v.endsWith('}')) return '{!(${v.substring(1, v.length - 1).trim()})}';
  return '{!($v)}';
}

/// The lines a word of another shape is read as (a [TypeAlias.line]), or
/// null when this line is not one the rewrite reads. Each is given the line
/// split into its parts, and the line as written.
typedef LineRewrite = List<String>? Function(LineParts parts, String text);

/// The rewrites [TypeAlias.line] names.
final Map<String, LineRewrite> lineRewrites = {
  'shortcut': _shortcutLine,
  'computed': _computedLine,
  'confirmDialog': _confirmDialogLines,
};

/// `Shortcut "ctrl+k" onPress={open search}`, `Shortcut key="?" onPress={…}`,
/// `shortcut key=t onPress={…}`, `Shortcut "r" when openId!=0 onPress={…}`:
/// the `key` line. What only describes it (hint, description, label) is not
/// kept: a shortcut shows nothing.
List<String>? _shortcutLine(LineParts p, String text) {
  final event = p.parts.where((x) => x.isEvent).firstOrNull;
  if (event == null || !event.value!.startsWith('{')) return null;
  var combo = p.strings.firstOrNull?.raw ?? p.pair('key')?.value ?? p.pair('keys')?.value ?? p.pair('combo')?.value;
  final words = [for (final x in p.parts) if (x.kind == 'word') x];
  // `shortcut space onPress={…}`: the key as a bare word.
  if (combo == null && words.isNotEmpty && words.first.raw != 'when') combo = words.first.raw;
  if (combo == null) return null;
  combo = combo.replaceAll('"', '').replaceAll(' ', '');
  if (combo.isEmpty) return null;
  // `when cond` (words up to the event) or when={cond}.
  String? when;
  if (p.pair('when')?.value case final String w) {
    when = w.startsWith('{') && w.endsWith('}') ? w.substring(1, w.length - 1).trim() : w;
  } else {
    final m = RegExp(r'\swhen\s+(.+?)\s+on[A-Z][A-Za-z]*=\{').firstMatch(text);
    if (m != null) when = m[1]!.trim();
  }
  return ['key $combo${when == null || when.isEmpty ? '' : ' when $when'} onPress=${event.value}'];
}

/// `computed total={sum(cart,x=>x.price)}`: a state written as its formula.
List<String>? _computedLine(LineParts p, String text) {
  final m = RegExp(r'^[A-Za-z]+\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)$').firstMatch(text);
  if (m == null) return null;
  var formula = m[2]!.trim();
  if (formula.startsWith('{') && formula.endsWith('}')) formula = formula.substring(1, formula.length - 1).trim();
  return ['state ${m[1]}=$formula'];
}

/// `ConfirmDialog#ask "Delete this plan?" "This cannot be undone."
/// confirm="Delete" cancel="Keep" onConfirm={…}`: a Dialog with the two
/// buttons, the first closing it and the second doing what a yes does. Lines
/// written under it come before the buttons.
List<String>? _confirmDialogLines(LineParts p, String text) {
  if (p.id.isEmpty) return null;
  final strings = [for (final s in p.strings) s.raw];
  String? text0(List<String> keys) {
    for (final k in keys) {
      if (p.pair(k)?.value case final String v) return asLineString(v);
    }
    return null;
  }

  final title = strings.isNotEmpty ? strings[0] : text0(const ['title']) ?? '"Are you sure?"';
  final message = strings.length > 1 ? strings[1] : text0(const ['message', 'text', 'body', 'description']);
  final yes = text0(const ['confirm', 'confirmLabel', 'confirmText', 'yes', 'ok', 'action']) ?? '"Confirm"';
  final no = text0(const ['cancel', 'cancelLabel', 'cancelText', 'no']) ?? '"Cancel"';
  String actions(List<String> keys) {
    for (final k in keys) {
      final v = p.pair(k)?.value;
      if (v != null && v.startsWith('{') && v.endsWith('}')) return v.substring(1, v.length - 1).trim();
    }
    return '';
  }

  final onYes = actions(const ['onConfirm', 'onYes', 'onOk', 'onAccept', 'onTap']);
  final onNo = actions(const ['onCancel', 'onNo', 'onDismiss']);
  final danger = p.has('destructive') || p.has('danger') || p.pair('tone')?.value == 'danger' || p.pair('destructive') != null;
  String then(String a) => a.isEmpty ? 'close' : (RegExp(r'(^|;)\s*close\s*$').hasMatch(a) ? a : '$a; close');
  return [
    'Dialog${p.id} $title${message == null ? '' : ' $message'}',
    '  Row gap=8 end',
    '    Button.ghost $no onTap={${then(onNo)}}',
    '    Button${danger ? '.destructive' : ''} $yes onTap={${then(onYes)}}',
  ];
}
