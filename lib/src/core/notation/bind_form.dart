// The bindings of a line written as codelessly_api 33 read them (`bind=name`,
// `bind={name}`, `bindEnd=name`, a block's variable as `key=name`) in the form
// the notation reads now (`@name` for the line's value, `key=@name` for any
// other property): what the parser says on a line that still writes them, and
// what a tool rewrites a file with (docs/design/13-compact-notation.md,
// section "Binding").
import '../catalog.dart';
import '../props.dart';
import 'notation.dart';
import 'vocabulary.dart';

/// A variable a rewritten line binds, with the value a `state` line for it
/// would start at (the control's natural empty value).
typedef NotationBound = ({String name, Object? start});

/// [line] with its bindings in the form the notation reads ([line] itself
/// when it has none to rewrite).
String notationBindForm(String line, {Catalog? catalog}) => notationBindRewrite(line, catalog: catalog).line;

/// The words a model writes for a slider with two thumbs and for a month,
/// read as ours ([NotationVocabulary.core]).
const _rangeWords = {'RangeSlider': 'slider', 'MiniCalendar': 'calendar', 'CalendarMonth': 'calendar', 'MonthGrid': 'calendar'};

/// A variable, a field of one, or an entry of one: what `@` takes.
final _path = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*|\[[^\]\s]*\])*$');
final _name = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

/// A field of the record a `find` picks (`find(clips,c=>c.id==sel).name`):
/// written back as a variable is.
final _found = RegExp(r'^find\(\S*\)\.[A-Za-z_][A-Za-z0-9_]*$');

/// [line] (one line, its indentation and what follows it kept as they are)
/// with its bindings rewritten, and the plain variables it binds (those it
/// already writes with `@` too). A
/// signature (`define Word …`, `primitive Word …`) names the variable the
/// body keeps its value in: `bind=value` is `@value`, and binds nothing of
/// the page's.
({String line, List<NotationBound> bound}) notationBindRewrite(String line, {Catalog? catalog}) {
  final none = (line: line, bound: const <NotationBound>[]);
  if (!line.contains('bind') && !line.contains('=') && !line.contains('@')) return none;
  final c = catalog ?? Catalog.current;
  final indent = line.length - line.trimLeft().length;
  final trimmed = line.substring(indent).trimRight();
  final after = line.substring(indent + trimmed.length);
  var body = trimmed, prefix = '';
  final signature = RegExp(r'^(define|primitive)\s+').firstMatch(body);
  if (signature != null) {
    prefix = signature[0]!;
    body = body.substring(signature.end);
  }
  // An id written from the data (`Input#quick-{col.id}`) is read as one of
  // its length, so that every part keeps its place.
  final dataId = RegExp(r'^[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)*(#\S+)').firstMatch(body);
  final parts = LineParts.of(body) ??
      (dataId == null ? null : LineParts.of(body.replaceRange(dataId.end - dataId[1]!.length, dataId.end, '#${'x' * (dataId[1]!.length - 1)}')));
  if (parts == null || const {'state', 'project', 'let', 'each', 'for', 'if', 'else', 'every', 'key', 'node', 'document'}.contains(parts.word)) return none;
  final word = parts.word;
  final read = notationLineType(word, c);
  final type = _rangeWords[word] ?? read.type;
  final component = signature == null ? read.component : null;
  final range = type == 'slider' || type == 'calendar';
  final ends = type == 'calendar' ? const ('start', 'end') : const ('low', 'high');
  // A list's selection: on a box (or a word the notation does not have).
  final list = (const {'column', 'row', 'stack'}.contains(type) || (component == null && c.widget(type) == null)) && ['selectable', 'reorder', 'sortable', 'reorderable'].any(parts.has);
  final shows = component == null && (notationShowsValue(type) || word == 'Badge');
  final variables = [for (final p in component?.props ?? const <PropDef<Object?>>[]) if (p.type.isVariable) p];
  final mainParam = variables.where((p) => p.key == 'value').firstOrNull ?? variables.firstOrNull;
  num? number(String key) => num.tryParse(parts.pair(key)?.value ?? '');

  Object? startOf(PropDef<Object?> p) => switch (p.type.variableOf?.kind) {
        PropKind.number || PropKind.integer => 0,
        PropKind.boolean => false,
        PropKind.list => const <Object?>[],
        _ => '',
      };
  // The value the line's own variable starts at.
  Object? valueStart() {
    if (mainParam != null) return startOf(mainParam);
    if (type == 'slider') return number('min') ?? 0;
    if (word == 'Pages' || word == 'Dots' || word == 'Lightbox') return 0;
    return notationValueStart(type) ?? '';
  }

  final edits = <({int start, int end, String text})>[];
  final bound = <NotationBound>[];
  void bindName(String name, Object? start) {
    if (signature == null && _name.hasMatch(name) && !bound.any((b) => b.name == name)) bound.add((name: name, start: start));
  }

  // The part [p] replaced by [text] (removed, with the space before it,
  // when [text] is empty).
  void replace(LinePart p, String text) {
    var start = p.at;
    if (text.isEmpty && start > 0 && body[start - 1] == ' ') start--;
    edits.add((start: start, end: p.at + p.raw.length, text: text));
  }

  String? unbraced(String v) {
    final inner = v.startsWith('{') && v.endsWith('}') ? v.substring(1, v.length - 1).trim() : v;
    return inner.isEmpty ? null : inner;
  }

  LinePart? main, end;
  String? mainName, endName;
  // The marks already in the form read now: their variables are bound too.
  var marks = 0;
  for (final p in parts.parts) {
    if (p.kind == 'word' && p.raw.startsWith('@')) {
      final name = p.raw.substring(1);
      bindName(name, ++marks == 2 && range ? (type == 'slider' ? (number('max') ?? 1) : '') : valueStart());
    } else if (p.kind == 'pair' && p.value!.startsWith('@')) {
      final key = p.key!, name = p.value!.substring(1);
      final param = variables.where((x) => x.key == key).firstOrNull;
      bindName(
          name,
          param != null
              ? startOf(param)
              : key == 'selected' && list
                  ? const <Object?>[]
                  : range && key == ends.$2
                      ? (type == 'slider' ? (number('max') ?? 1) : '')
                      : key == 'value' || (range && key == ends.$1)
                          ? valueStart()
                          : '');
    }
  }
  for (final p in parts.parts) {
    if (p.kind == 'word' && p.raw == 'bind' && signature != null) {
      replace(p, '@bind');
      continue;
    }
    if (p.kind != 'pair' || p.isEvent) continue;
    final key = p.key!, v = p.value!;
    if (v.startsWith('@')) continue;
    final inner = unbraced(v);
    if (inner == null) continue;
    final bindKey = RegExp(r'^bind([A-Z][A-Za-z0-9]*)?$').firstMatch(key);
    if (bindKey != null && !(component?.props.any((x) => x.key == key) ?? false)) {
      final rest = bindKey[1];
      if (signature != null) {
        replace(p, rest == null ? '@$inner' : '${rest[0].toLowerCase()}${rest.substring(1)}=@');
        continue;
      }
      if (v.startsWith('{') && !_path.hasMatch(inner) && !_found.hasMatch(inner)) {
        // An expression bound (in braces): a value shown, one way.
        if (rest == null) replace(p, 'value={$inner}');
        continue;
      }
      // Anything else written bare is the variable as it was written (a
      // found record's field, `find(clips,c=>c.id==sel).name`); a quoted
      // value is no variable, and is left as it is.
      if (v.startsWith('"') || v.startsWith('[')) continue;
      final isEnd = rest != null && const {'End', 'High', 'Hi', 'To'}.contains(rest);
      final isStart = rest == null || const {'Start', 'Low', 'Lo', 'From', 'Value'}.contains(rest);
      if (shows && rest == null) {
        final string = word == 'Badge' || type == 'text';
        replace(p, string && parts.strings.isEmpty ? '"{$inner}"' : 'value={$inner}');
      } else if (list && rest == null) {
        replace(p, 'selected=@$inner');
        bindName(inner, const <Object?>[]);
      } else if (range && isEnd) {
        end = p;
        endName = inner;
      } else if (isStart && (range || rest == null)) {
        main = p;
        mainName = inner;
      } else {
        // A further variable of a word the notation does not have
        // (`bindStart=from`): named by what it is.
        replace(p, '${rest[0].toLowerCase()}${rest.substring(1)}=@$inner');
        bindName(inner, '');
      }
      continue;
    }
    if (signature != null) continue;
    // A slider with two thumbs written with its ends' names.
    if (word == 'RangeSlider' && _path.hasMatch(inner)) {
      if (const {'low', 'lo', 'start', 'from'}.contains(key)) {
        main = p;
        mainName = inner;
        continue;
      }
      if (const {'high', 'hi', 'end', 'to'}.contains(key)) {
        end = p;
        endName = inner;
        continue;
      }
    }
    // A block's variable, written by its name or in braces.
    final param = variables.where((x) => x.key == key).firstOrNull;
    if (param != null && _path.hasMatch(inner) && !const {'true', 'false', 'null'}.contains(inner)) {
      replace(p, '$key=@$inner');
      bindName(inner, startOf(param));
    }
  }
  // The line's value, and a range's other end: bare, in order.
  if (main != null && end != null) {
    final first = main.at < end.at ? main : end, second = identical(first, main) ? end : main;
    replace(first, '@$mainName @$endName');
    replace(second, '');
  } else if (main != null) {
    replace(main, '@$mainName');
  } else if (end != null) {
    replace(end, '${range ? ends.$2 : 'end'}=@$endName');
  }
  if (mainName != null) bindName(mainName, valueStart());
  if (endName != null) bindName(endName, type == 'slider' ? (number('max') ?? 1) : '');
  if (edits.isEmpty) return (line: line, bound: bound);
  edits.sort((a, b) => b.start.compareTo(a.start));
  var out = body;
  for (final e in edits) {
    out = out.replaceRange(e.start, e.end, e.text);
  }
  return (line: '${line.substring(0, indent)}$prefix$out$after', bound: bound);
}
