// The compact notation (docs/design/13-compact-notation.md): the form an
// agent writes for levels 0 to 2. One node per line, nesting by indentation:
//
//   Column gap:12
//     Slider =volume
//     Input "Email" =email
//     Toggle "Notifications" =notify
//     Button "Save" -> emit save
//
// [parseNotation] expands it to an ordinary flat document; nothing after
// that (validation, rendering, editing) knows the notation was used.
import 'dart:convert';

import '../catalog.dart';
import '../json.dart';
import '../props.dart';

/// A problem in the notation's text: where and what.
final class NotationIssue {
  const NotationIssue(this.line, this.column, this.message);

  /// 1-based.
  final int line, column;
  final String message;

  @override
  String toString() => 'line $line:$column: $message';
}

/// What [parseNotation] gives: the document and what it could not read.
final class NotationResult {
  const NotationResult(this.document, this.issues);

  /// A schema-3 layout document.
  final Json document;
  final List<NotationIssue> issues;
}

/// How the notation expands.
final class NotationOptions {
  const NotationOptions({
    this.width = 390,
    this.screen = 'screen',
    this.textStyles = defaultTextVariants,
    this.card = defaultCard,
  });

  /// The canvas's width.
  final double width;

  /// The canvas's id (its variables' scope).
  final String screen;

  /// `Text.<variant>`: a style object, or a theme text style's name.
  final Map<String, Object> textStyles;

  /// What `Card` adds to a column: decoration and padding.
  final Json card;
}

/// SSUI's text looks, written out so a document needs no theme.
const Map<String, Object> defaultTextVariants = {
  'title': {'fontSize': 20, 'fontWeight': 600, 'color': '#FF111827'},
  'heading': {'fontSize': 16, 'fontWeight': 600, 'color': '#FF111827'},
  'strong': {'fontSize': 13, 'fontWeight': 600, 'color': '#FF111827'},
  'body': {'fontSize': 13, 'color': '#FF374151'},
  'small': {'fontSize': 12, 'color': '#FF111827'},
  'caption': {'fontSize': 12, 'color': '#FF6B7280'},
  'muted': {'fontSize': 13, 'color': '#FF6B7280'},
  'danger': {'fontSize': 13, 'fontWeight': 600, 'color': '#FFB91C1C'},
  'success': {'fontSize': 13, 'fontWeight': 600, 'color': '#FF15803D'},
};

/// SSUI's card.
const Json defaultCard = {
  'decoration': {
    'fills': [
      {'color': '#FFFFFFFF'},
    ],
    'strokes': [
      {'color': '#FFE5E7EB'},
    ],
    'radius': 8,
  },
  'layout': {'padding': 16},
};

/// Short names: what an agent writes → the node type and what it implies.
const Map<String, ({String type, Json node})> notationTypes = {
  'Input': (type: 'textField', node: {}),
  'Toggle': (type: 'switch', node: {}),
  'Select': (type: 'dropdown', node: {}),
  'Button': (type: 'filledButton', node: {}),
  'Progress': (type: 'progressBar', node: {}),
  'List': (type: 'listView', node: {}),
  // A grid of the children written under it: rows of `cols` equal cells.
  'Grid': (type: 'column', node: {}),
  'Image': (type: 'box', node: {}),
  'Box': (type: 'column', node: {}),
  'Card': (type: 'column', node: {}),
};

/// `Button.<variant>`: the button type and props it stands for.
const Map<String, ({String type, Json props})> buttonVariants = {
  'primary': (type: 'filledButton', props: {}),
  'secondary': (type: 'filledButton', props: {'tonal': true}),
  'tertiary': (type: 'filledButton', props: {'tonal': true}),
  'outline': (type: 'outlinedButton', props: {}),
  'ghost': (type: 'textButton', props: {}),
  'elevated': (type: 'elevatedButton', props: {}),
  'destructive': (
    type: 'filledButton',
    props: {
      'style': {'backgroundColor': '#FFDC2626', 'foregroundColor': '#FFFFFFFF'},
    },
  ),
};

/// The prop a control's value lives in, and the variable type it implies.
const Map<String, ({String prop, String type, Object? start})> _valueProps = {
  'slider': (prop: 'value', type: 'decimal', start: 0),
  'switch': (prop: 'value', type: 'boolean', start: false),
  'checkbox': (prop: 'value', type: 'boolean', start: false),
  'textField': (prop: 'initialValue', type: 'text', start: ''),
  'dropdown': (prop: 'value', type: 'text', start: ''),
  'radio': (prop: 'groupValue', type: 'text', start: ''),
  'segmentedButton': (prop: 'selected', type: 'text', start: ''),
};

const _shortKeys = {'gap': 'props.spacing', 'pad': 'layout.padding', 'w': 'layout.width', 'h': 'layout.height', 'grow': 'layout.flex'};
/// Keys a model reaches for that a type spells otherwise.
const Map<String, Map<String, List<String>>> _typeKeys = {
  'textField': {
    'hint': ['props.decoration.hintText'],
    'placeholder': ['props.decoration.hintText'],
    'label': ['props.decoration.labelText'],
    'helper': ['props.decoration.helperText'],
    'error': ['props.decoration.errorText'],
  },
  'dropdown': {
    'placeholder': ['props.hint'],
  },
  'gridView': {
    'cols': ['props.crossAxisCount'],
    'columns': ['props.crossAxisCount'],
    'gap': ['props.mainAxisSpacing', 'props.crossAxisSpacing'],
    'spacing': ['props.mainAxisSpacing', 'props.crossAxisSpacing'],
  },
};

/// What `=expr` binds on a type that shows a value but takes no input.
const Map<String, String> _shownValue = {'progressBar': 'value', 'circularProgressIndicator': 'value', 'badge': 'label', 'text': 'text'};

/// `Badge.<variant>`: its fill and text colours (SSUI's tints).
const Map<String, (String, String)> badgeVariants = {
  'neutral': ('#FFF3F4F6', '#FF374151'),
  'info': ('#FFDBEAFE', '#FF1D4ED8'),
  'success': ('#FFDCFCE7', '#FF15803D'),
  'warning': ('#FFFEF3C7', '#FFB45309'),
  'danger': ('#FFFEE2E2', '#FFB91C1C'),
};

/// Keys written on a Text that belong to its style.
const _textStyleKeys = {
  'color': 'color', 'size': 'fontSize', 'fontSize': 'fontSize', 'weight': 'fontWeight', 'fontWeight': 'fontWeight',
  'bold': 'fontWeight', 'fontFamily': 'fontFamily', 'font': 'fontFamily', 'lineHeight': 'height',
};

const _layoutKeys = {'width', 'height', 'padding', 'margin', 'flex', 'aspectRatio', 'x', 'y', 'align', 'constraints', 'order', 'basis'};
const _decorationKeys = {'radius', 'strokeWidth', 'fills', 'strokes', 'effects', 'clip', 'shape'};
const _mainWords = {'start': 'start', 'center': 'center', 'end': 'end', 'between': 'spaceBetween', 'around': 'spaceAround', 'evenly': 'spaceEvenly'};
const _crossWords = {'top': 'start', 'left': 'start', 'middle': 'center', 'bottom': 'end', 'right': 'end', 'stretch': 'stretch'};

/// [text] in the compact notation as a layout document. Never throws: what
/// cannot be read is reported and skipped.
NotationResult parseNotation(String text, {Catalog? catalog, NotationOptions options = const NotationOptions()}) =>
    _Parser(catalog ?? Catalog.current, options).parse(text);

/// The notation read as it arrives: [add] takes text in any chunks and
/// returns the edit operations of the lines completed so far (a `set` per
/// node under its parent, `vars` for the state a line introduced), ready
/// for `applyOps`; [close] gives the last line's.
final class NotationStream {
  NotationStream({Catalog? catalog, NotationOptions options = const NotationOptions()})
      : _parser = _Parser(catalog ?? Catalog.current, options);

  final _Parser _parser;
  final _buffer = StringBuffer();

  /// What could not be read so far.
  List<NotationIssue> get issues => List.unmodifiable(_parser.issues);

  List<Json> add(String chunk) {
    _buffer.write(chunk);
    final text = _buffer.toString();
    final end = text.lastIndexOf('\n');
    if (end < 0) return const [];
    _buffer
      ..clear()
      ..write(text.substring(end + 1));
    text.substring(0, end).split('\n').forEach(_parser.line);
    return _take();
  }

  List<Json> close() {
    final rest = _buffer.toString();
    _buffer.clear();
    if (rest.isNotEmpty) _parser.line(rest);
    _parser.finish();
    return _take();
  }

  List<Json> _take() {
    final out = [..._parser.ops];
    _parser.ops.clear();
    return out;
  }
}

/// A `Grid`'s rows as its children arrive.
class _Grid {
  _Grid(this.id);
  final String id;
  int cols = 2;
  num gap = 8;
  String? row;
  int inRow = 0;
  int rows = 0;
}

class _Open {
  _Open(this.indent, this.id, this.type, {this.condition, this.grid, this.each});

  /// An `each <name> in …` above: the name its lines call an item by.
  final String? each;

  /// A grid above (its own line, or an `if` inside it): children go in its
  /// rows.
  final _Grid? grid;
  final int indent;

  /// The node children are added to (a condition's: its parent's).
  final String id;
  final String type;

  /// An `if` above: its children are bound visible to it.
  final String? condition;
}

class _Parser {
  _Parser(this.catalog, this.options);
  final Catalog catalog;
  final NotationOptions options;

  final nodes = <String, Json>{};
  final variables = <String, Json>{};
  final issues = <NotationIssue>[];

  /// The edit operations of the lines read so far, not yet taken ([take]).
  final ops = <Json>[];
  final _declared = <String>{};
  final _counts = <String, int>{};
  final _stack = <_Open>[];
  String? _root;
  int _line = 0;

  /// Reads one line (without its newline).
  void line(String raw) {
    _line++;
    if (raw.trim().isEmpty || raw.trimLeft().startsWith('//')) return;
    final indent = raw.length - raw.trimLeft().length;
    final before = nodes.length;
    _lineAt(indent, raw.trim(), indent + 1);
    final added = nodes.keys.skip(before).toList();
    if (added.isEmpty) {
      _emit(null);
    } else {
      added.forEach(_emit);
    }
  }

  /// The operations the line just read adds: the variables it introduced,
  /// then its node under its parent (the first node under a new canvas).
  void _emit(String? id) {
    final screen = options.screen;
    final fresh = {
      for (final v in variables.values)
        if (_declared.add(v['name']! as String)) v['name']! as String: {'type': v['type'], 'value': v['value']},
    };
    if (id == null && fresh.isEmpty) return;
    if (!_canvas) {
      _canvas = true;
      ops
        ..add({'op': 'roots', 'roots': [screen]})
        ..add({
          'op': 'set',
          'id': screen,
          'node': {
            'type': 'canvas',
            'layout': {'width': options.width, 'height': {'hug': 0}},
          },
        });
    }
    if (fresh.isNotEmpty) ops.add({'op': 'vars', 'scope': screen, 'set': fresh});
    ops.addAll(_patches);
    _patches.clear();
    if (id == null) return;
    final node = {...nodes[id]!}..remove('children');
    final parent = _parentOf[id];
    final slot = parent == null ? 'body' : _slotOf[id];
    ops.add({'op': 'set', 'id': id, 'parent': parent ?? screen, if (slot != null) 'slot': slot, 'node': node..remove('slots')});
  }

  bool _canvas = false;
  final _parentOf = <String, String>{};
  final _slotOf = <String, String>{};

  /// Changes a line makes to a node already sent (a grid's row height).
  final _patches = <Json>[];

  /// Texts a line's strings stand for on a type whose text is a child: an
  /// accordion's header, a list tile's title and subtitle.
  final _texts = <String>[];

  /// A label that reads state (`Button "Step {n}"`): bound, since only a
  /// text node reads expressions as written.
  final _labelBinds = <String, String>{};

  NotationResult parse(String text) {
    const LineSplitter().convert(text).forEach(line);
    finish();
    final screen = options.screen;
    return NotationResult({
      'schema': 3,
      'roots': [screen],
      'nodes': {
        screen: {
          'type': 'canvas',
          if (_root != null) 'slots': {'body': _root},
          'layout': {'width': options.width, 'height': {'hug': 0}},
        },
        ...nodes,
      },
      if (variables.isNotEmpty) 'variables': {screen: variables.values.toList()},
    }, issues);
  }

  void _issue(int column, String message) => issues.add(NotationIssue(_line, column, message));

  void _lineAt(int indent, String source, int column) {
    var line = source;
    while (_stack.isNotEmpty && _stack.last.indent >= indent) {
      _close(_stack.removeLast());
    }
    // Inside an `each x in …`, x is the document's `item`.
    for (final open in _stack) {
      if (open.each != null && open.each != 'item') line = _rename(line, open.each!);
    }
    if (line.startsWith('state ')) return _state(line.substring(6).trim(), column + 6);
    final parent = _stack.isEmpty ? null : _stack.last;
    if (line.startsWith('if ')) {
      if (parent == null) return _issue(column, 'An "if" needs a parent: indent it under a node.');
      final own = _formula(line.substring(3).trim());
      _stack.add(_Open(indent, parent.id, parent.type, condition: _and(parent.condition, own), grid: parent.grid));
      return;
    }
    // `each rows` and `List =rows` are `each row in rows`: the element is
    // read as `row` (or `item`).
    final bare = RegExp(r'^each\s+(\S+)$').firstMatch(line) ?? RegExp(r'^List\s+=(\S+)$').firstMatch(line);
    if (bare != null) line = 'each row in ${bare[1]}';
    final each = RegExp(r'^each\s+([A-Za-z_][A-Za-z0-9_]*)\s+in\s+(.+)$').firstMatch(line);
    if (each != null) {
      if (parent == null) return _issue(column, 'An "each" needs a parent: indent it under a node.');
      // A list over the data, its item a column of the lines under it.
      final g = parent.grid;
      final listId = _id(g != null ? 'gridView' : 'listView'), itemId = '${listId}Item';
      nodes[listId] = {
        'type': g != null ? 'gridView' : 'listView',
        'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
        // Under a Grid, the repeated lines are its cells.
        'props': g != null
            ? {'crossAxisCount': g.cols, 'mainAxisSpacing': g.gap, 'crossAxisSpacing': g.gap, 'shrinkWrapRows': true, 'physics': 'never'}
            : {'scrollable': false},
        'bind': {'data': _read(each[2]!.trim()), if (parent.condition != null) 'visible': parent.condition},
        'children': <Object?>[itemId],
      };
      final p = nodes[parent.id]!;
      ((p['children'] as List<Object?>?) ?? (p['children'] = <Object?>[])).add(listId);
      _parentOf[listId] = parent.id;
      nodes[itemId] = {
        'type': 'column',
        'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
        'props': {'crossAxisAlignment': 'start'},
      };
      _parentOf[itemId] = listId;
      _stack.add(_Open(indent, itemId, 'column', each: each[1]));
      return;
    }
    final t = _Tokens(line);
    final head = RegExp(r'^([A-Za-z][A-Za-z0-9]*)(?:\.([A-Za-z][A-Za-z0-9]*))?(?:#([A-Za-z_][A-Za-z0-9_]*))?').firstMatch(line);
    if (head == null) return _issue(column, 'A line starts with a node type: Column, Text "…", Button "…".');
    t.at = head.end;
    final written = head[1]!, variant = head[2];
    final short = notationTypes[written];
    var type = short?.type ?? '${written[0].toLowerCase()}${written.substring(1)}';
    final node = <String, Object?>{};
    final props = <String, Object?>{}, layout = <String, Object?>{}, decoration = <String, Object?>{}, bind = <String, Object?>{};
    final reactions = <Json>[];

    if (written == 'Button' && variant != null) {
      final v = buttonVariants[variant];
      if (v == null) {
        _issue(column + written.length + 1, 'No Button.$variant. Variants: ${buttonVariants.keys.join(', ')}.');
      } else {
        type = v.type;
        props.addAll(_copy(v.props));
      }
    } else if (type == 'text' && variant != null) {
      final style = options.textStyles[variant];
      if (style == null) {
        _issue(column + written.length + 1, 'No Text.$variant. Variants: ${options.textStyles.keys.join(', ')}.');
      } else {
        props['style'] = style is Map ? _copy(style.cast<String, Object?>()) : style;
      }
    } else if (type == 'badge' && variant != null) {
      final v = badgeVariants[variant];
      if (v == null) {
        _issue(column + written.length + 1, 'No Badge.$variant. Variants: ${badgeVariants.keys.join(', ')}.');
      } else {
        props['backgroundColor'] = v.$1;
        props['textColor'] = v.$2;
      }
    } else if (variant != null) {
      _issue(column + written.length + 1, 'A $written has no variants: write $written, with props as key:value.');
    }
    final spec = catalog.widget(type);
    if (spec == null) {
      // A sentence before the UI ("Here is the card:") is not a node.
      // Nor is one after it ("Two limits remain: …").
      if ((_root == null || indent == 0) && line.contains(' ')) return;
      _issue(column, 'No node type "$written". Write a type of the catalog (Column, Row, Text, Button, Input, Toggle, Slider…).');
      return;
    }
    if (written == 'Card') {
      decoration.addAll(_copy(readMap(options.card['decoration']) ?? const {}));
      layout.addAll(_copy(readMap(options.card['layout']) ?? const {}));
    }
    final id = head[3] ?? _id(written == 'Grid' ? 'grid' : type);
    final grid = written == 'Grid' ? _Grid(id) : null;
    if (grid != null) props['spacing'] = grid.gap;
    if (nodes.containsKey(id) || id == options.screen) {
      _issue(column, 'The id "$id" is used twice.');
      return;
    }

    void put(String path, Object? value) {
      final dot = path.indexOf('.');
      final where = dot < 0 ? '' : path.substring(0, dot), key = dot < 0 ? path : path.substring(dot + 1);
      switch (where) {
        case 'props':
          final sub = key.indexOf('.');
          if (sub < 0) {
            props[key] = value;
          } else {
            final inner = (props[key.substring(0, sub)] as Json?) ?? (props[key.substring(0, sub)] = <String, Object?>{});
            inner[key.substring(sub + 1)] = value;
          }
        case 'layout':
          layout[key] = value;
        case 'decoration':
          decoration[key] = value;
        default:
          node[key] = value;
      }
    }

    String pathOf(String key) {
      final short = _shortKeys[key];
      if (short != null) return short;
      if (key == 'visible' || key == 'opacity') return key;
      if (spec.props.any((p) => p.key == key)) return 'props.$key';
      if (key == 'enabled' && spec.props.any((p) => p.key == 'isEnabled')) return 'props.isEnabled';
      if ((key == 'lines' || key == 'rows') && type == 'textField') return 'props.maxLines';
      if ((key == 'selected' || key == 'checked') && (type == 'checkbox' || type == 'switch')) return 'props.value';
      if (_layoutKeys.contains(key)) return 'layout.$key';
      if (_decorationKeys.contains(key)) return 'decoration.$key';
      return 'props.$key';
    }

    while (true) {
      t.skipSpace();
      if (t.done) break;
      final col = column + t.at;
      if (t.peek == '"') {
        _main(type, spec, t.string(), props, decoration);
      } else if (t.rest.startsWith('->')) {
        t.at += 2;
        final tail = _tail(t);
        reactions.add({
          'trigger': {'type': _valueProps.containsKey(type) ? 'changed' : 'click'},
          'actions': _actions(t.rest.substring(0, tail).trim(), col),
        });
        t.at += tail;
      } else if (t.peek == '{') {
        final j = _json(t.rest);
        if (j is Map) {
          _merge(node, j.cast<String, Object?>());
        } else {
          _issue(col, 'The {…} tail is a JSON object merged into the node.');
        }
        break;
      } else if (t.peek == '=') {
        t.at++;
        final expr = t.expression().trim();
        final value = _valueProps[type];
        if (value == null) {
          final shown = _shownValue[type] ?? _mainKey(type, spec);
          if (shown == null) {
            _issue(col, 'A $written has no value to bind with =. Bind a prop: key:=expression.');
          } else {
            bind['props.$shown'] = _read(expr);
            // A share shown from a name not declared yet starts at 0.
            if (shown == 'value' && _identifier.hasMatch(expr) && !expr.contains('.')) {
              variables.putIfAbsent(expr, () => {'name': expr, 'type': 'decimal', 'value': 0});
            }
          }
        } else {
          // A segmented button's selection is a list: one name bound to it
          // is its single choice.
          final list = type == 'segmentedButton';
          bind['props.${value.prop}'] = list ? _formula('[$expr]') : _read(expr);
          if (_identifier.hasMatch(expr)) {
            variables.putIfAbsent(expr, () => {'name': expr, 'type': value.type, 'value': props[value.prop] ?? value.start});
            reactions.insert(0, {
              'trigger': {'type': 'changed'},
              'actions': [
                {'type': 'setVariable', 'variable': expr, 'value': list ? r'${result[0]}' : r'${result}'},
              ],
            });
          }
        }
      } else {
        // An expression where the string goes (`Button open ? "Hide" : "Show"`).
        final from = t.at;
        final bare = t.expression();
        final shownKey = _shownValue[type] ?? _mainKey(type, spec);
        if (shownKey != null && bare.contains(' ') && bare.contains('?') && !RegExp(r'^[A-Za-z]+:').hasMatch(bare)) {
          bind['props.$shownKey'] = _read(bare.trim());
          continue;
        }
        t.at = from;
        final word = t.word();
        if (word.isEmpty) {
          _issue(col, 'Unexpected "${t.peek}".');
          t.at++;
          continue;
        }
        final colon = word.indexOf(':');
        if (colon < 0) {
          if (_mainWords[word] case final String m when type == 'row' || type == 'column') {
            props['mainAxisAlignment'] = m;
          } else if (_crossWords[word] case final String c when type == 'row' || type == 'column') {
            props['crossAxisAlignment'] = c;
          } else if (num.tryParse(word) != null && (_valueProps[type]?.type == 'decimal' || _shownValue[type] == 'value')) {
            // A bare number on a slider or a progress bar is its value.
            props['value'] = num.parse(word);
          } else if (word == 'grow') {
            layout['flex'] = 1;
          } else if (word == 'fill') {
            layout['width'] = {'fill': 0};
          } else if (word == 'hidden') {
            node['visible'] = false;
          } else if (spec.props.any((p) => p.key == word)) {
            props[word] = true;
          } else {
            _issue(col, 'Unknown word "$word" on a $written. Props are written key:value.');
          }
          continue;
        }
        final key = word.substring(0, colon);
        var raw = word.substring(colon + 1);
        if (raw.startsWith('=')) raw = '$raw${t.expression(opened: '('.allMatches(raw).length - ')'.allMatches(raw).length)}';
        if (raw.isEmpty && t.peek == '"') raw = jsonEncode(t.string());
        if (raw.isEmpty && (t.peek == '[' || t.peek == '{')) raw = t.balanced();
        if (grid != null && (key == 'cols' || key == 'columns')) {
          grid.cols = (int.tryParse(raw) ?? 2).clamp(1, 12);
          continue;
        }
        if (grid != null && (key == 'gap' || key == 'spacing')) {
          grid.gap = num.tryParse(raw) ?? 8;
          props['spacing'] = grid.gap;
          continue;
        }
        if (key == 'fill') {
          if (raw.startsWith('=')) {
            bind['decoration.fills[0].color'] = _read(raw.substring(1));
            decoration.putIfAbsent('fills', () => [
                  {'color': '#00000000'},
                ]);
          } else {
            decoration['fills'] = [
              {'color': _value(raw)},
            ];
          }
          continue;
        }
        if (type == 'text' && _textStyleKeys.containsKey(key)) {
          final style = switch (props['style']) { final Map m => m.cast<String, Object?>(), _ => <String, Object?>{} };
          final v = _value(raw);
          style[_textStyleKeys[key]!] = key == 'bold' ? 700 : v;
          props['style'] = style;
          continue;
        }
        if (type == 'segmentedButton' && key == 'items') {
          final items = _value(raw);
          if (items is List) {
            props['segments'] = [for (final i in items) {'value': '$i', 'label': '$i'}];
            continue;
          }
        }
        if (key == 'selected' && type == 'chip') type = 'choiceChip';
        if (key == 'hidden' && raw.startsWith('=')) {
          bind['visible'] = _formula('!(${raw.substring(1)})');
          continue;
        }
        if (_typeKeys[type]?[key] case final List<String> paths) {
          for (final path in paths) {
            if (raw.startsWith('=')) {
              bind[path] = _read(raw.substring(1));
            } else {
              put(path, _value(raw));
            }
          }
          continue;
        }
        final path = pathOf(key);
        if (raw.startsWith('=')) {
          bind[path] = _read(raw.substring(1) + (t.peek == ' ' ? '' : ''));
        } else {
          put(path, _value(raw));
        }
      }
    }

    // Sizes not written: in a column a child fills the width and hugs its
    // height; in a row it hugs both; a control hugs.
    final control = _valueProps.containsKey(type) || type.endsWith('Button') || type.endsWith('Chip');
    if (written == 'Image') {
      final url = props.remove('text');
      decoration['fills'] = [
        {
          'image': {'url': url ?? '', 'fit': 'cover'},
        },
      ];
      layout.putIfAbsent('height', () => 160);
    }
    // Charts: a height of their own, and a line chart's plain values as its
    // data points.
    if (type == 'barChart' || type == 'lineChart') {
      layout.putIfAbsent('height', () => 140);
      // The design system's primary, unless a colour is written.
      props.putIfAbsent(type == 'barChart' ? 'color' : 'lineColor', () => '#FF2563EB');
      if (type == 'lineChart' && props['values'] is List) {
        final values = props.remove('values')! as List;
        props.remove('labels');
        props['data'] = [for (var i = 0; i < values.length; i++) {'x': i, 'y': values[i]}];
        props['xField'] = 'x';
        props['yField'] = 'y';
      }
    }
    // A column starts its children at the leading edge and a row centres
    // them on its line (what a form and a toolbar want), unless written.
    if (type == 'column') props.putIfAbsent('crossAxisAlignment', () => 'start');
    if (type == 'row') props.putIfAbsent('crossAxisAlignment', () => 'center');
    // Text with no variant is the body text, so it always has a colour.
    if (type == 'text' && !props.containsKey('style')) {
      if (options.textStyles['body'] case final Object body) props['style'] = body is Map ? _copy(body.cast<String, Object?>()) : body;
    }
    // In a grid a child is as wide as its cell and as tall as it says (its
    // row is as tall as its tallest child).
    if (parent?.type == 'gridView') {
      layout['width'] = {'fill': 0};
      layout.putIfAbsent('height', () => {'hug': 0});
    }
    // A grid's rows are as tall as their content unless a height is given.
    if (type == 'gridView' && !props.containsKey('mainAxisExtent')) props.putIfAbsent('shrinkWrapRows', () => true);
    final cell = parent?.grid != null && !(grid != null && identical(parent!.grid, grid));
    if (cell) {
      layout['flex'] = 1;
      layout['width'] = {'fill': 0};
    }
    final inRow = !cell && parent?.type == 'row';
    if (inRow && type == 'text' && !layout.containsKey('width')) layout['squeezable'] = true;
    if (!layout.containsKey('width')) {
      // In a tile's slot (leading, trailing) a child is as wide as it is.
      final inTile = parent?.type == 'listTile';
      final fills = layout.containsKey('flex') || !inRow && !inTile && (!control || type == 'textField' || type == 'slider' || type == 'dropdown');
      layout['width'] = fills ? {'fill': 0} : {'hug': 0};
    } else {
      layout['width'] = _size(layout['width']);
    }
    layout['height'] = layout.containsKey('height') ? _size(layout['height']) : {'hug': 0};
    bind.addAll(_labelBinds);
    _labelBinds.clear();
    if (parent?.condition case final String c) {
      final own = bind['visible'];
      bind['visible'] = own is String ? _and(c, own) : c;
    }

    final out = <String, Object?>{
      'type': type,
      'layout': layout,
      if (props.isNotEmpty) 'props': props,
      if (decoration.isNotEmpty) 'decoration': decoration,
      if (bind.isNotEmpty) 'bind': bind,
      if (reactions.isNotEmpty) 'actions': reactions,
    };
    _merge(out, node);
    nodes[id] = out;
    if (parent == null) {
      if (_root != null) {
        _issue(column, 'A second root: the first line is the root, everything else is indented under it.');
        nodes.remove(id);
        return;
      }
      _root = id;
    } else {
      final p = nodes[parent.id]!;
      if (spec.type == 'canvas') return _issue(column, 'A canvas cannot be a child.');
      if (parent.type == 'listTile') {
        final slots = (p['slots'] as Json?) ?? (p['slots'] = <String, Object?>{});
        final slot = type == 'icon' && !slots.containsKey('leading') ? 'leading' : 'trailing';
        slots[slot] = id;
        _slotOf[id] = slot;
      } else {
        ((p['children'] as List<Object?>?) ?? (p['children'] = <Object?>[])).add(id);
      }
      _parentOf[id] = parent.id;
      if (cell) _intoRow(parent.grid!, id);
    }
    _stack.add(_Open(indent, id, type, condition: null, grid: grid));
    // Its strings as text nodes: an accordion's header is its first child, a
    // list tile's are its title and subtitle.
    final texts = [..._texts];
    _texts.clear();
    for (var i = 0; i < texts.length; i++) {
      final tid = _id('text');
      final container = type == 'column' || type == 'row' || type == 'stack';
      final style = options.textStyles[container ? 'body' : i == 0 ? 'strong' : 'muted'];
      nodes[tid] = {
        'type': 'text',
        // In a tile's slot a text is as wide as it is; an accordion's header fills it.
        'layout': {'width': type == 'listTile' ? {'hug': 0} : {'fill': 0}, 'height': {'hug': 0}},
        'props': {'text': texts[i], if (style != null) 'style': style is Map ? _copy(style.cast<String, Object?>()) : style},
      };
      _parentOf[tid] = id;
      if (type == 'listTile') {
        final slot = i == 0 ? 'title' : 'subtitle';
        ((out['slots'] as Json?) ?? (out['slots'] = <String, Object?>{}))[slot] = tid;
        _slotOf[tid] = slot;
      } else {
        ((out['children'] as List<Object?>?) ?? (out['children'] = <Object?>[])).add(tid);
      }
    }
  }

  /// [line] with the word [name] read as `item`, outside quoted text and
  /// inside `{…}` within it.
  String _rename(String line, String name) {
    final word = RegExp('(?<![A-Za-z0-9_.])${RegExp.escape(name)}(?![A-Za-z0-9_])');
    final out = StringBuffer();
    var quoted = false, depth = 0, start = 0;
    void flush(int end, bool code) {
      final part = line.substring(start, end);
      out.write(code ? part.replaceAll(word, 'item') : part);
      start = end;
    }

    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"' && (i == 0 || line[i - 1] != r'\')) {
        flush(i, !quoted || depth > 0);
        quoted = !quoted;
        depth = 0;
      } else if (quoted && c == '{') {
        if (depth == 0) flush(i, false);
        depth++;
      } else if (quoted && c == '}' && depth > 0) {
        depth--;
        if (depth == 0) flush(i, true);
      }
    }
    flush(line.length, !quoted);
    return out.toString();
  }

  /// Moves [id], just added under a grid, into the grid's current row (a
  /// new row every `cols` cells).
  void _intoRow(_Grid g, String id) {
    final gridNode = nodes[g.id]!;
    (gridNode['children'] as List<Object?>).remove(id);
    if (g.row == null || g.inRow >= g.cols) {
      final rowId = '${g.id}Row${++g.rows}';
      // Before the cell, so it is sent first.
      final cellNode = nodes.remove(id)!;
      nodes[rowId] = {
        'type': 'row',
        'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
        'props': {'spacing': g.gap, 'crossAxisAlignment': 'stretch'},
        'children': <Object?>[],
      };
      nodes[id] = cellNode;
      (gridNode['children'] as List<Object?>).add(rowId);
      _parentOf[rowId] = g.id;
      g
        ..row = rowId
        ..inRow = 0;
    }
    (nodes[g.row]!['children'] as List<Object?>).add(id);
    _parentOf[id] = g.row!;
    g.inRow++;
  }

  /// A grid ends: its last row is filled out with empty cells, so its cells
  /// are as wide as the rows above.
  void _close(_Open open) {
    final g = open.grid;
    if (g == null || open.id != g.id || open.condition != null || g.row == null) return;
    while (g.inRow < g.cols) {
      final sid = _id('spacer');
      nodes[sid] = {'type': 'spacer', 'layout': {'flex': 1, 'width': {'fill': 0}, 'height': {'hug': 0}}};
      (nodes[g.row]!['children'] as List<Object?>).add(sid);
      _parentOf[sid] = g.row!;
      g.inRow++;
    }
    g.row = null;
  }

  /// The end of the text: what is still open closes.
  void finish() {
    final before = nodes.length;
    while (_stack.isNotEmpty) {
      _close(_stack.removeLast());
    }
    nodes.keys.skip(before).toList().forEach(_emit);
  }

  /// The node's main string: a text's text, a button's label, a field's label.
  void _main(String type, WidgetSpec spec, String s, Json props, Json decoration) {
    final text = _interpolate(s);
    if (type == 'textField') {
      final d = (props['decoration'] as Json?) ?? (props['decoration'] = <String, Object?>{});
      d[d.containsKey('labelText') ? 'hintText' : 'labelText'] = text;
      return;
    }
    // A string on a container is a text inside it.
    if (const {'accordion', 'expansionTile', 'listTile', 'column', 'row', 'stack'}.contains(type)) {
      _texts.add(text);
      return;
    }
    final key = _mainKey(type, spec);
    if (key == null) {
      _issue(1, 'A $type has no text of its own.');
      return;
    }
    if (key != 'icon' && type != 'text' && type != 'box' && text.contains(r'${')) {
      _labelBinds['props.$key'] = text;
      return;
    }
    props[key] = key == 'icon' ? s : text;
  }

  String? _mainKey(String type, WidgetSpec spec) {
    if (type == 'box') return 'text';
    if (type == 'dropdown') return 'hint';
    for (final k in const ['text', 'label', 'title', 'icon', 'hint']) {
      if (spec.props.any((p) => p.key == k)) return k;
    }
    return null;
  }

  void _state(String rest, int column) {
    final m = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)$').firstMatch(rest);
    if (m == null) return _issue(column, 'State is written: state name=value.');
    final value = _value(m[2]!.trim());
    variables[m[1]!] = {
      'name': m[1],
      'type': switch (value) { bool _ => 'boolean', int _ => 'integer', num _ => 'decimal', List _ => 'list', Map _ => 'map', _ => 'text' },
      'value': value,
    };
  }

  List<Json> _actions(String text, int column) {
    final out = <Json>[];
    for (final part in _split(text, ';')) {
      final a = part.trim();
      if (a.isEmpty) continue;
      if (a.startsWith('{')) {
        final j = _json(a);
        if (j is Map) out.add(j.cast<String, Object?>());
        continue;
      }
      final set = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=)\s*(.+)$').firstMatch(a);
      if (set != null) {
        final v = set[2]!.trim();
        final literal = _literal(v);
        // A bare word that names no variable is text (choice=basic).
        final word = !literal.$1 && _identifier.hasMatch(v) && !v.contains('.') && !variables.containsKey(v) && !const {'result', 'item', 'index'}.contains(v);
        out.add({
          'type': 'setVariable',
          'variable': set[1],
          'value': word
              ? v
              : literal.$1 && literal.$2 is String
                  ? _interpolate(literal.$2! as String)
                  : _formula(v),
        });
        if (!variables.containsKey(set[1])) {
          final start = literal.$1 ? literal.$2 : null;
          variables[set[1]!] = {
            'name': set[1],
            'type': switch (start) { bool _ => 'boolean', int _ => 'integer', num _ => 'decimal', _ => 'text' },
            'value': switch (start) { bool _ => false, num _ => 0, _ => '' },
          };
        }
        continue;
      }
      final space = a.indexOf(' ');
      final verb = space < 0 ? a : a.substring(0, space), arg = space < 0 ? '' : a.substring(space + 1).trim();
      final s = arg.startsWith('"') ? _interpolate(_Tokens(arg).string()) : arg;
      switch (verb) {
        case 'emit':
          // The core's "tell the host": outside a component it reaches the
          // session's events (and the app's), with an optional value.
          final sp = s.indexOf(' ');
          final value = sp < 0 ? null : s.substring(sp + 1).trim();
          out.add({
            'type': 'componentEvent',
            'event': sp < 0 ? s : s.substring(0, sp),
            if (value != null && value.isNotEmpty) 'value': _valueOrRead(value),
          });
        case 'open':
          out.add({'type': 'openModal', 'modal': s});
        case 'close':
          out.add({'type': 'closeModal'});
        case 'go':
          out.add({'type': 'navigate', 'to': s});
        case 'toast':
          out.add({'type': 'showToast', 'message': s});
        case 'link':
          out.add({'type': 'openLink', 'url': s});
        default:
          _issue(column, 'Unknown action "$verb". Actions: name=value, emit <event>, toast "…", open <id>, close, go <screen>, link <url>, or JSON.');
      }
    }
    return out;
  }

  Object? _valueOrRead(String raw) {
    final l = _literal(raw);
    return l.$1 ? l.$2 : _read(raw);
  }

  String _id(String type) {
    final n = _counts[type] = (_counts[type] ?? 0) + 1;
    return '$type$n';
  }

  static final _identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_.]*$');

  /// An expression as a binding reads it: a name, or a formula.
  String _read(String expr) => _identifier.hasMatch(expr.trim()) ? '\${${expr.trim()}}' : _formula(expr.trim());

  String _formula(String expr) => '\${= $expr}';

  String _and(String? a, String b) {
    if (a == null) return b;
    String inner(String f) => f.startsWith(r'${= ') ? f.substring(4, f.length - 1) : f.substring(2, f.length - 1);
    return _formula('(${inner(a)}) && (${inner(b)})');
  }

  /// `{name}` in a string is a read: `${name}`.
  String _interpolate(String s) => s.replaceAll(r'\$', r'$').replaceAllMapped(RegExp(r'\{([^{}]+)\}'), (m) => _read(m[1]!));

  (bool, Object?) _literal(String raw) {
    if (raw == 'true') return (true, true);
    if (raw == 'false') return (true, false);
    if (raw == 'null') return (true, null);
    final n = num.tryParse(raw);
    if (n != null) return (true, n);
    if (raw.startsWith('"') && raw.endsWith('"') && raw.length >= 2) {
      try {
        return (true, jsonDecode(raw));
      } catch (_) {}
    }
    if (raw.startsWith('[') || raw.startsWith('{')) {
      final j = _json(raw);
      if (j != null) return (true, j);
    }
    return (false, null);
  }

  Object? _value(String raw) {
    final l = _literal(raw);
    if (l.$1) return l.$2 is String ? _interpolate(l.$2! as String) : l.$2;
    return raw;
  }

  /// A size as the document writes it: a number is fixed; `fill` and `hug`
  /// are fits.
  Object? _size(Object? v) => switch (v) { 'fill' => {'fill': 0}, 'hug' => {'hug': 0}, _ => v };

  Object? _json(String s) {
    try {
      return jsonDecode(s);
    } catch (_) {
      _issue(1, 'Not valid JSON: $s');
      return null;
    }
  }

  /// Where a `{…}` tail starts in what is left ([t.rest].length when none).
  int _tail(_Tokens t) {
    final rest = t.rest;
    var quoted = false;
    for (var i = 0; i < rest.length; i++) {
      final c = rest[i];
      if (c == '"' && (i == 0 || rest[i - 1] != r'\')) quoted = !quoted;
      if (!quoted && c == '{' && i > 0 && rest[i - 1] == ' ' && _trailingJson(rest.substring(i))) return i;
    }
    return rest.length;
  }

  bool _trailingJson(String s) {
    if (!s.trimRight().endsWith('}')) return false;
    try {
      return jsonDecode(s) is Map;
    } catch (_) {
      return false;
    }
  }

  List<String> _split(String s, String sep) {
    final out = <String>[];
    var depth = 0, quoted = false, start = 0;
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '"' && (i == 0 || s[i - 1] != r'\')) quoted = !quoted;
      if (quoted) continue;
      if (c == '{' || c == '[' || c == '(') depth++;
      if (c == '}' || c == ']' || c == ')') depth--;
      if (c == sep && depth == 0) {
        out.add(s.substring(start, i));
        start = i + 1;
      }
    }
    out.add(s.substring(start));
    return out;
  }

  Json _copy(Json m) => (jsonDecode(jsonEncode(m)) as Map).cast<String, Object?>();

  void _merge(Json into, Json from) {
    for (final e in from.entries) {
      final a = into[e.key], b = e.value;
      if (a is Map && b is Map) {
        final m = a.cast<String, Object?>();
        _merge(m, b.cast<String, Object?>());
        into[e.key] = m;
      } else {
        into[e.key] = b;
      }
    }
  }
}

class _Tokens {
  _Tokens(this.s);
  final String s;
  int at = 0;

  bool get done => at >= s.length;
  String get peek => done ? '' : s[at];
  String get rest => done ? '' : s.substring(at);

  void skipSpace() {
    while (!done && s[at] == ' ') {
      at++;
    }
  }

  /// A quoted string at the cursor (JSON escapes).
  String string() {
    final start = at;
    at++;
    var braced = false;
    while (!done && !(s[at] == '"' && s[at - 1] != r'\')) {
      // {an expression} may hold quotes of its own ("{plan=="pro" ? "$9" : "$0"}").
      if (s[at] == '{') {
        final close = _closeOf(at);
        if (close > at) {
          braced = braced || s.substring(at, close).contains('"');
          at = close;
        }
      }
      at++;
    }
    at++;
    final raw = s.substring(start, at > s.length ? s.length : at);
    if (braced) {
      return raw.substring(1, raw.endsWith('"') && raw.length > 1 ? raw.length - 1 : raw.length).replaceAll(r'\"', '"').replaceAll(r'\\', r'\');
    }
    try {
      return jsonDecode(raw.endsWith('"') && raw.length > 1 ? raw : '$raw"') as String;
    } catch (_) {
      return raw.replaceAll('"', '');
    }
  }

  /// Where the `{` at [open] closes on this line (quotes inside it paired),
  /// or -1.
  int _closeOf(int open) {
    var depth = 0, quoted = false;
    for (var i = open; i < s.length; i++) {
      final c = s[i];
      if (c == '"' && s[i - 1] != r'\\') quoted = !quoted;
      if (quoted) continue;
      if (c == '{') depth++;
      if (c == '}' && --depth == 0) return quoted ? -1 : i;
    }
    return -1;
  }

  static final _opAhead = RegExp(r' +(&&|\|\||\?|:(?![=A-Za-z])|==|!=|>=|<=|[<>+*/%]|-(?!>))');
  static final _opBehind = RegExp(r'(&&|\|\||\?|[^A-Za-z0-9_"\])]:|==|!=|>=|<=|[<>+*/%])$');

  /// Up to the next space (a `key:"quoted value"` stops before its quote).
  String word() {
    final start = at;
    while (!done && s[at] != ' ') {
      if (s[at] == '"' || ((s[at] == '[' || s[at] == '{') && at > start && s[at - 1] == ':')) break;
      at++;
    }
    return s.substring(start, at);
  }

  /// The rest of an expression: to the next space outside quotes and
  /// brackets (`to!=""&&len(subject)>0`).
  String expression({int opened = 0}) {
    final start = at;
    var depth = opened, quoted = false;
    while (!done) {
      final c = s[at];
      if (c == '"' && (at == 0 || s[at - 1] != r'\')) quoted = !quoted;
      if (!quoted) {
        if (c == '(' || c == '[') depth++;
        if (c == ')' || c == ']') depth--;
        if (c == ' ' && depth <= 0) {
          // An operator on either side of the space carries on
          // (`a!="" && b!=""`, `open ? "Hide" : "Show"`).
          final ahead = _opAhead.matchAsPrefix(s, at);
          if (ahead != null) {
            at = ahead.end;
            continue;
          }
          if (at > start && (_opBehind.hasMatch(s.substring(start, at)) || s[at - 1] == ':' && s.substring(start, at).contains('?'))) {
            while (!done && s[at] == ' ') {
              at++;
            }
            continue;
          }
          break;
        }
      }
      at++;
    }
    return s.substring(start, at);
  }

  /// A bracketed value at the cursor, to its matching close.
  String balanced() {
    final start = at;
    var depth = 0, quoted = false;
    while (!done) {
      final c = s[at];
      if (c == '"' && s[at - 1] != r'\') quoted = !quoted;
      if (!quoted) {
        if (c == '[' || c == '{') depth++;
        if (c == ']' || c == '}') depth--;
      }
      at++;
      if (depth == 0) break;
    }
    return s.substring(start, at);
  }

  /// Up to the first of [stops] outside quotes (or the end).
  String until(List<String> stops) {
    final start = at;
    var quoted = false;
    while (!done) {
      if (s[at] == '"') quoted = !quoted;
      if (!quoted && stops.any((x) => s.startsWith(x, at))) break;
      at++;
    }
    return s.substring(start, at);
  }
}
