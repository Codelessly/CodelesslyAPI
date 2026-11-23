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
    String? of,
  }) : children = children ?? [] {
    _of = of;
  }

  /// `type` (a line's first word), `parameter` (a key=value), `flag` (a
  /// bare word), `event` (an on… key), `verb` (an action's first word),
  /// `variant` (the word after a type's dot), `alias` (a name read as
  /// another: [to] says which, [of] what kind of word it is), `definition`
  /// (a use of a defined word: [to] the meaning read) or `primitive` (a use
  /// of a word declared with `primitive`, which stands in: [to] the same).
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

  /// What to write in its place, when the reader can say (a word that
  /// takes no lines under it, a parameter its definition does not name, a
  /// list given where an `each` goes); null when it can only be left out.
  String? say;

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
  /// `event`, `verb`, `line`). A definition: `page, over <file>` when the
  /// page's own definition was read over one the design system has (`page,
  /// over the Counter component` over a component).
  /// A universal word (docs/design/21): `parameter`, `flag` or `event`.
  String? get of => kind == 'alias' || kind == 'universal' || kind == 'definition' || kind == 'primitive' ? _of : null;
  String? _of;

  Json toJson() => {
        'kind': kind,
        'word': word,
        if (_of != null) 'of': _of,
        if (to != null) 'to': to,
        if (on != null) 'on': on,
        if (value != null) 'value': value,
        if (node != null) 'node': node,
        if (say != null) 'say': say,
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

/// A universal word applied where the type has no word of that name, or
/// honoured by a stand-in (docs/design/21), of kind [of].
VocabularyUse universalUse({
  required String of,
  required String word,
  required String source,
  required int line,
  required int column,
  String? on,
  String? value,
  List<String> path = const [],
}) =>
    VocabularyUse(kind: 'universal', word: word, source: source, line: line, column: column, on: on, value: value, path: path).._of = of;

/// The kind of the universal word [word] when nothing else says: an event,
/// else a key=value.
String universalKindOf(String word) => RegExp(r'^on[A-Z]').hasMatch(word) ? 'event' : 'parameter';

/// A type read as another: `RangeSlider` is a `Slider`, with its own names
/// for that type's parameters; `GoKey` is a `Button.primary` with `size=lg`.
final class TypeAlias {
  const TypeAlias({this.to, this.variant, this.parameters = const {}, this.add, this.requires = const []});

  /// `"to"` may name a variant after the type (`Button.primary`).
  factory TypeAlias.fromJson(Object? json) {
    final m = json is String ? {'to': json} : readMap(json) ?? const <String, Object?>{};
    final to = readString(m['to']);
    final dot = to?.indexOf('.') ?? -1;
    return TypeAlias(
      to: dot < 0 ? to : to!.substring(0, dot),
      variant: dot < 0 ? null : to!.substring(dot + 1),
      add: readString(m['add']),
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

  /// The variant of [to] it is read as (`primary`: written `"to":
  /// "Button.primary"`), unless the line writes one of its own.
  final String? variant;

  /// Its own names for that type's parameters, flags and events, each by
  /// what it is read as (the forms of [NotationVocabulary.parameters], and
  /// `"$text": "label"`: the line's first string read as `label=`). These
  /// hold whatever the target type calls its own.
  final Map<String, String> parameters;

  /// The keys the line has to have, once its own names are read, for the
  /// alias to hold (a RangeSlider is our Slider only with a variable for each
  /// end); without them the word is left as it was written. A bare `@name`
  /// on the line stands for the next key not written (`RangeSlider @lo @hi`
  /// has its low and its high).
  final List<String> requires;

  /// Whether [parts] has what [requires] names.
  bool holdsOn(LineParts parts) {
    final missing = requires.where((k) => !parts.parts.any((p) => p.kind == 'pair' && (parameters[p.key] ?? p.key) == k)).length;
    return missing <= parts.parts.where((p) => p.kind == 'word' && p.raw.startsWith('@')).length;
  }

  /// Words added to the line, flags and fixed parameters (`selected` on a
  /// chip that is always on; `size=lg selected`). A key or a flag the line
  /// writes itself is the line's.
  final String? add;

  Object toJson() => to != null && parameters.isEmpty && add == null && requires.isEmpty
      ? '$to${variant == null ? '' : '.$variant'}'
      : {
          if (to != null) 'to': '$to${variant == null ? '' : '.$variant'}',
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
///       "types":      {"RangeSlider": {"to": "Slider", "requires": ["low", "high"], "parameters": {"from": "low", "to": "high"}}},
///       "parameters": {"*": {"disabled": "!enabled"}, "ListTile": {"subtitle": "$text"}},
///       "flags":      {"*": {"disabled": "enabled=false"}},
///       "events":     {"*": {"onClick": "onTap"}},
///       "verbs":      {"navigate": "go"}
///     }
///
/// A parameter is read as another key (`enabled`), as that key with its
/// value negated (`!enabled`), or as a further string of the line
/// (`$text`). The key `$text` is the line's first string, read as the
/// parameter it names (`"NumberInput": {"$text": "label"}`: `NumberInput
/// "Strokes"` is `NumberInput label="Strokes"`), on a word that takes no
/// string. A flag is read as the words written (`enabled=false`). `*`
/// holds for every type; a type's own entry comes first.
final class NotationVocabulary {
  const NotationVocabulary({
    this.types = const {},
    this.parameters = const {},
    this.flags = const {},
    this.events = const {},
    this.verbs = const {},
    this.definitions = const {},
    this.dictionary = const {},
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

  /// The words of the dictionaries a caller gave (a folder of definition
  /// files each, [withDictionary]): words we have, read after a page's own
  /// definitions and a design system's or a site's ([definitions]), by word.
  final Map<String, List<NotationDefinition>> dictionary;

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
      dictionary: {...dictionary, ...other.dictionary},
    );
  }

  /// This table with the words defined in [texts] (each a file's text by its
  /// name: `StickyNote.txt`) over its own; what could not be read is left out
  /// ([readDefinitions] says what).
  NotationVocabulary define(Map<String, String> texts) => merge(NotationVocabulary(definitions: readDefinitions(texts).words));

  /// This table with the dictionary [name] (a folder of definition files,
  /// [texts] by file name): its words under the ones [definitions] has, and
  /// over any dictionary given before it. What could not be read is left
  /// out ([readDefinitions] says what).
  NotationVocabulary withDictionary(Map<String, String> texts, {required String name}) =>
      merge(NotationVocabulary(dictionary: readDefinitions(texts, dictionary: name).words));

  Json toJson() => {
        'types': {for (final e in types.entries) e.key: e.value.toJson()},
        'parameters': parameters,
        'flags': flags,
        'events': events,
        'verbs': verbs,
      };

  /// No aliases at all.
  static const none = NotationVocabulary();

  /// The table a reader starts with: the two universal words a control has
  /// under its own name (`disabled` is a control's `enabled=false`,
  /// `readonly` an input's `readOnly`): one word on every line, a box's and
  /// a control's alike. The notation has one name for everything else; a
  /// caller's own words (a design system's, a dictionary's) are the
  /// caller's to give.
  static const core = NotationVocabulary(
    parameters: {
      '*': {'disabled': '!enabled', 'readonly': 'readOnly'},
    },
    flags: {
      '*': {'disabled': 'enabled=false', 'readonly': 'readOnly'},
    },
  );

  /// The names models reach for (SDK tool/vocabulary/corpus) for words the
  /// notation has under one name. None is read: a line that uses one is
  /// said with the line to write, the notation's own word in its place.
  static const otherNames = NotationVocabulary(
    types: {
      // A slider with two thumbs: ours when the line binds a variable for
      // each end (`RangeSlider @lo @hi`, `low=@lo high=@hi`). (Most answers
      // bind one list variable, which ours does not take: those stay
      // unknown.)
      // `end=@hi` (test 10: 6 runs) and `start=`, as a range is often written.
      'RangeSlider': TypeAlias(to: 'Slider', requires: ['low', 'high'], parameters: {'start': 'low', 'end': 'high', 'rangeEnd': 'high'}),
      // A text with what matched a search marked in it.
      'Highlight': TypeAlias(to: 'Text', parameters: {'match': 'mark', 'query': 'mark'}),
      'HighlightText': TypeAlias(to: 'Text', parameters: {'match': 'mark', 'query': 'mark'}),
      // A month in the page.
      'MiniCalendar': TypeAlias(to: 'Calendar'),
      'CalendarMonth': TypeAlias(to: 'Calendar'),
      'MonthGrid': TypeAlias(to: 'Calendar'),
      // The bar at the foot of an app's window (a now-playing bar, a
      // composer, a basket): ours is `Footer` in Main (or `Row sticky bottom`).
      'StickyBar': TypeAlias(to: 'Footer'),
      'StickyFooter': TypeAlias(to: 'Footer'),
      'BottomBar': TypeAlias(to: 'Footer'),
      'FooterBar': TypeAlias(to: 'Footer'),
      'BottomDock': TypeAlias(to: 'Footer'),
      // A QR code (the primitives list's QRCode, review 3): our Barcode, as a
      // QR code.
      'QRCode': TypeAlias(to: 'Barcode', add: 'symbology=qrCode'),
      'QrCode': TypeAlias(to: 'Barcode', add: 'symbology=qrCode'),
      // A round meter, and shares of a whole.
      'Dial': TypeAlias(to: 'Gauge'),
      // A column of lines.
      'List': TypeAlias(to: 'Column'),
      'DonutChart': TypeAlias(to: 'Donut'),
      'PieChart': TypeAlias(to: 'Pie'),
    },
    parameters: {
      // Input (docs/design/21 section 7): the text field's own words under
      // the names answers wrote.
      'Input': {'maxlength': 'maxLength', 'maxChars': 'maxLength', 'rows': 'lines'},
      // A ListTile's second string is its subtitle (10 of 20 apps named it).
      'ListTile': {'subtitle': r'$text', 'title': r'$text'},
      // What a barcode encodes, and how (three self-defining answers named
      // it value or code: the vocabulary loop's Review 5).
      'Barcode': {'value': r'$text', 'code': r'$text', 'format': 'symbology', 'type': 'symbology'},
    },
    events: {
      // A universal event under its other name (docs/design/21).
      '*': {'onDelete': 'onRemove'},
      // An Input submitted from the keyboard (Flutter's onSubmitted), and
      // left after editing.
      'Input': {'onEnter': 'onSubmit', 'onSubmitted': 'onSubmit', 'onSaved': 'onBlur'},
      // A day picked in a month.
      'Calendar': {'onSelect': 'onChange'},
    },
    flags: {
      '*': {'sortable': 'reorder', 'reorderable': 'reorder'},
      'Input': {'uppercase': 'caps', 'allcaps': 'caps'},
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
        // `hovered.fill={…}`, `motion.translateY={p}`: a dotted key whose value
        // is braced or a list is a key=value too (a word, its value would end
        // at its first space).
        // `onKeyDown(key=c)={…}`: an event of a trigger with fields.
        if ((key == null && i == start ? RegExp(r'on[A-Z][A-Za-z0-9]*\([^()]*\)=[{]').matchAsPrefix(text, start) : null) case final ev?) {
          key = text.substring(start, ev.end - 2);
          i = closeOfBalanced(ev.end - 1);
          break;
        }
        if (c == '=' &&
            key == null &&
            i > start &&
            (RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(text.substring(start, i)) ||
                (i + 1 < n && (text[i + 1] == '{' || text[i + 1] == '[') && RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*(\.[A-Za-z_][A-Za-z0-9_-]*)+$').hasMatch(text.substring(start, i))))) {
          key = text.substring(start, i);
          i++;
          // `x=@0.5`, `x=@"text"`, `x=@[0, 100]`: a signature's bound
          // parameter with its default, read whole.
          if (i + 1 < n && text[i] == '@' && (text[i + 1] == '"' || text[i + 1] == '{' || text[i + 1] == '[')) i++;
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
        // `@value=[0, 100]`: a signature's value with its default, read whole.
        if (c == '=' && key == null && text[start] == '@' && i + 1 < n && (text[i + 1] == '{' || text[i + 1] == '[')) {
          i = closeOfBalanced(i + 1);
          break;
        }
        // `style.fontFamily="Georgia"`: a dotted key's quoted value is the
        // key's (round 11b: a paint paragraph's style, 15 lines in 2 builds,
        // read as a word and a second text).
        if (c == '"' && key == null && RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)+=$').hasMatch(text.substring(start, i))) {
          key = text.substring(start, i - 1);
          i = closeOfString(i);
          break;
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
  String word, variant;
  final String id;
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

