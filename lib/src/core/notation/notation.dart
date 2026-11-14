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
  'Grid': (type: 'gridView', node: {}),
  'Image': (type: 'box', node: {}),
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
    return _take();
  }

  List<Json> _take() {
    final out = [..._parser.ops];
    _parser.ops.clear();
    return out;
  }
}

class _Open {
  _Open(this.indent, this.id, this.type, {this.condition});
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
    _emit(nodes.length > before ? nodes.keys.last : null);
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
    if (id == null) return;
    final node = {...nodes[id]!}..remove('children');
    final parent = _parentOf[id];
    ops.add({'op': 'set', 'id': id, 'parent': parent ?? screen, if (parent == null) 'slot': 'body', 'node': node});
  }

  bool _canvas = false;
  final _parentOf = <String, String>{};

  NotationResult parse(String text) {
    const LineSplitter().convert(text).forEach(line);
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

  void _lineAt(int indent, String line, int column) {
    while (_stack.isNotEmpty && _stack.last.indent >= indent) {
      _stack.removeLast();
    }
    if (line.startsWith('state ')) return _state(line.substring(6).trim(), column + 6);
    final parent = _stack.isEmpty ? null : _stack.last;
    if (line.startsWith('if ')) {
      if (parent == null) return _issue(column, 'An "if" needs a parent: indent it under a node.');
      final own = _formula(line.substring(3).trim());
      _stack.add(_Open(indent, parent.id, parent.type, condition: _and(parent.condition, own)));
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
    } else if (variant != null) {
      props['variant'] = variant;
    }
    final spec = catalog.widget(type);
    if (spec == null) {
      _issue(column, 'No node type "$written". Write a type of the catalog (Column, Row, Text, Button, Input, Toggle, Slider…).');
      return;
    }
    if (written == 'Card') {
      decoration.addAll(_copy(readMap(options.card['decoration']) ?? const {}));
      layout.addAll(_copy(readMap(options.card['layout']) ?? const {}));
    }
    final id = head[3] ?? _id(type);
    if (nodes.containsKey(id) || id == options.screen) {
      _issue(column, 'The id "$id" is used twice.');
      return;
    }

    void put(String path, Object? value) {
      final dot = path.indexOf('.');
      final where = dot < 0 ? '' : path.substring(0, dot), key = dot < 0 ? path : path.substring(dot + 1);
      switch (where) {
        case 'props':
          props[key] = value;
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
        final expr = t.until(const [' -> ', ' {']).trim();
        final value = _valueProps[type];
        if (value == null) {
          bind['props.${_mainKey(type, spec) ?? 'text'}'] = _read(expr);
        } else {
          bind['props.${value.prop}'] = _read(expr);
          if (_identifier.hasMatch(expr)) {
            variables.putIfAbsent(expr, () => {'name': expr, 'type': value.type, 'value': props[value.prop] ?? value.start});
            reactions.insert(0, {
              'trigger': {'type': 'changed'},
              'actions': [
                {'type': 'setVariable', 'variable': expr, 'value': r'${result}'},
              ],
            });
          }
        }
      } else {
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
        if (raw.isEmpty && t.peek == '"') raw = jsonEncode(t.string());
        if (raw.isEmpty && (t.peek == '[' || t.peek == '{')) raw = t.balanced();
        if (key == 'fill') {
          if (raw.startsWith('=')) {
            bind['decoration.fills[0].color'] = _read(raw.substring(1));
          } else {
            decoration['fills'] = [
              {'color': _value(raw)},
            ];
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
    // A column starts its children at the leading edge and a row centres
    // them on its line (what a form and a toolbar want), unless written.
    if (type == 'column') props.putIfAbsent('crossAxisAlignment', () => 'start');
    if (type == 'row') props.putIfAbsent('crossAxisAlignment', () => 'center');
    // Text with no variant is the body text, so it always has a colour.
    if (type == 'text' && !props.containsKey('style')) {
      if (options.textStyles['body'] case final Object body) props['style'] = body is Map ? _copy(body.cast<String, Object?>()) : body;
    }
    final inRow = parent?.type == 'row';
    if (!layout.containsKey('width')) {
      final fills = !inRow && (!control || type == 'textField' || type == 'slider' || type == 'dropdown');
      layout['width'] = fills ? {'fill': 0} : {'hug': 0};
    } else {
      layout['width'] = _size(layout['width']);
    }
    layout['height'] = layout.containsKey('height') ? _size(layout['height']) : {'hug': 0};
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
      ((p['children'] as List<Object?>?) ?? (p['children'] = <Object?>[])).add(id);
      _parentOf[id] = parent.id;
    }
    _stack.add(_Open(indent, id, type, condition: null));
  }

  /// The node's main string: a text's text, a button's label, a field's label.
  void _main(String type, WidgetSpec spec, String s, Json props, Json decoration) {
    final text = _interpolate(s);
    if (type == 'textField') {
      final d = (props['decoration'] as Json?) ?? (props['decoration'] = <String, Object?>{});
      d[d.containsKey('labelText') ? 'hintText' : 'labelText'] = text;
      return;
    }
    final key = _mainKey(type, spec);
    if (key == null) {
      _issue(1, 'A $type has no text of its own.');
      return;
    }
    props[key] = key == 'icon' ? s : text;
  }

  String? _mainKey(String type, WidgetSpec spec) {
    if (type == 'box') return 'text';
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
        out.add({'type': 'setVariable', 'variable': set[1], 'value': literal.$1 && literal.$2 is String ? _interpolate(literal.$2! as String) : _formula(v)});
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
  String _interpolate(String s) => s.replaceAllMapped(RegExp(r'(?<!\$)\{([^{}]+)\}'), (m) => _read(m[1]!));

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
    while (!done && !(s[at] == '"' && s[at - 1] != r'\')) {
      at++;
    }
    at++;
    final raw = s.substring(start, at > s.length ? s.length : at);
    try {
      return jsonDecode(raw.endsWith('"') && raw.length > 1 ? raw : '$raw"') as String;
    } catch (_) {
      return raw.replaceAll('"', '');
    }
  }

  /// Up to the next space (a `key:"quoted value"` stops before its quote).
  String word() {
    final start = at;
    while (!done && s[at] != ' ') {
      if (s[at] == '"' || ((s[at] == '[' || s[at] == '{') && at > start && s[at - 1] == ':')) break;
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
