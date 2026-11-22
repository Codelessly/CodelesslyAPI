// The lines of the notation that are not nodes but a node's ordered records
// (docs/design/22-notation-parity.md, 4.6): a `customPaint` and its draw ops,
// an `animation` and its tracks, a `transition`, each record one line in the grammar's own
// shape, indented under the line that holds it.
//
//   box#mark w=30 h=30
//     customPaint viewBox=[28,28]
//       path d="M7 17 C 7 5, 21 5, 21 17" stroke={theme.colors.accent} strokeWidth=2.6
//       circle c=[14,18.5] radius=2.6 fill={theme.colors.onBrand}
//     animation#enter duration=520 curve=easeOutCubic
//       track path=opacity from=0 to=1
//
// What a record takes is the API's own declaration of it (DrawOpSpecs,
// CustomPaintFields, NodeAnimationFields, AnimationTrackFields), read at run
// time.
part of 'notation.dart';

/// A block of record lines open under a node: what the lines indented under
/// [indent] are.
final class _PaintFrame {
  _PaintFrame(this.indent, this.node, this.kind, this.target, {this.list});
  final int indent;

  /// The node the records are of.
  final String node;

  /// `customPaint` (its lines are the painter's ops, or `foregroundPainter`),
  /// `ops` (its lines are ops of [list] in [target]), `op` (an op: a group's
  /// or repeat's lines are its ops), `animation` (its lines are tracks),
  /// `none` (no line goes under it), `skip` (a line already said wrong).
  final String kind;
  final Json target;
  final String? list;

  /// The condition of the `if` last written among this block's lines (what
  /// an `else` after it is the opposite of); null: none.
  String? lastIf;
}

final _paintFrames = Expando<List<_PaintFrame>>();

/// The repeats of the text's drawings, each with where it is written: read
/// once the text is whole ([_PaintWords._paintRepeatsRead]).
final _paintRepeats = Expando<List<({Json op, int line, int column, String? from})>>();

/// The stroke paint's own fields, written beside `stroke=` on an op's line.
const notationStrokeWords = {'strokeWidth', 'strokeCap', 'strokeJoin', 'strokeMiterLimit', 'dashPattern', 'scaleStroke'};

/// The fields of every paint of an op, written once beside `fill=` and
/// `stroke=` (`circle c=[60,60] radius=30 fill=#80F59E0B blurRadius=18`: a
/// glow).
const notationPaintWords = {'blurRadius'};

/// The first words of the lines [_PaintWords] reads at a node's child depth.
final _paintHead = RegExp(r'^(customPaint|foregroundPainter|animation|transition)(?=[\s#{]|$)');

/// What the record line [text] reads as, for the printer's check of a line
/// it writes (print_paint.dart): an op (`kind` `op`), the `customPaint` head,
/// an `animation` head, a `track` or a `transition`. [issues] gets what is
/// said about it.
Json? readPaintRecord(
  String kind,
  String text, {
  required Catalog catalog,
  required NotationOptions options,
  Map<String, Json> variables = const {},
  List<NotationIssue>? issues,
}) {
  final p = _Parser(catalog, options);
  p.variables.addAll(variables);
  final out = switch (kind) {
    'op' => p._paintOp(text, 1),
    'customPaint' => p._paintRecord(text, 1, CustomPaintFields.all, head: 'customPaint'),
    'animation' => p._paintRecord(text, 1, NodeAnimationFields.all, head: 'animation'),
    'transition' => p._paintRecord(text, 1, TransitionFields.all, head: 'transition'),
    'track' => p._paintRecord(text, 1, AnimationTrackFields.all, head: 'track'),
    _ => null,
  };
  issues?.addAll(p.issues);
  return out;
}

/// The name the item of a drawing's repeat has where the drawing is in an
/// `each` (whose own item is `item` there).
const _repeated = 'repeated';

extension _PaintWords on _Parser {
  List<_PaintFrame> get _paintStack => _paintFrames[this] ??= [];

  /// Reads [text] (indented [indent]) when it is a record line: the head of
  /// a block under a node, or a line inside one. False: not one.
  bool _paintLine(int indent, String text, {int? written}) {
    final frames = _paintStack;
    while (frames.isNotEmpty && frames.last.indent >= indent) {
      frames.removeLast();
    }
    final column = indent + 1;
    if (frames.isNotEmpty) {
      // (A line of the page is the one being read, as a node's is: what is
      // recorded of it carries its own source and the lines it is under.)
      if (_from == null) _track(written ?? indent, text);
      _paintInside(indent, _paintRenamed(text), frames.last, column);
      return true;
    }
    final head = _paintHead.firstMatch(text);
    if (head == null) return false;
    if (_from == null) _track(written ?? indent, text);
    // The node it is under: what a node line at this depth would be under.
    while (_stack.isNotEmpty && _stack.last.indent >= indent) {
      _close(_stack.removeLast());
    }
    final open = _stack.lastOrNull;
    final node = open == null ? null : nodes[open.id];
    if (open == null || node == null) {
      _issue(column, 'A ${head[1]} line goes under the node it belongs to, indented: box w=48 h=48, then "  customPaint viewBox=[48,48]" under it.');
      frames.add(_PaintFrame(indent, '', 'skip', {}));
      return true;
    }
    text = _paintRenamed(text);
    if (head[1] == 'foregroundPainter') {
      // `foregroundPainter` under the node itself (as `customPaint` is): its
      // ops are drawn over the node's content, beside any painter a
      // `customPaint` line gives.
      if (text.trim() != 'foregroundPainter') _issue(column, 'A foregroundPainter line holds only the ops under it; the painter\'s keys (viewBox, fit) go on a customPaint line.');
      final paint = switch (node['customPaint']) {
        final Map m => m.cast<String, Object?>(),
        _ => <String, Object?>{},
      };
      node['customPaint'] = paint;
      _lineTails[open.id]?.remove('customPaint');
      paint['foregroundPainter'] ??= <Object?>[];
      frames.add(_PaintFrame(indent, open.id, 'ops', paint, list: 'foregroundPainter'));
      _paintChanged(open.id, 'customPaint');
      return true;
    }
    if (head[1] == 'customPaint') {
      final paint = _paintRecord(text, column, CustomPaintFields.all, head: 'customPaint');
      if (paint == null) {
        frames.add(_PaintFrame(indent, open.id, 'skip', {}));
        return true;
      }
      // The painter's own keys are values: one worked out is read by
      // nothing (the drawing was in the box's pixels, with nothing said).
      bool worked(Object? v) => v is String ? v.contains(r'${') : v is List && v.any(worked);
      for (final key in [for (final e in paint.entries) if (e.key != 'painter' && e.key != 'foregroundPainter' && worked(e.value)) e.key]) {
        paint.remove(key);
        _issue(column,
            'A customPaint\'s $key is a value, never worked out${key == 'viewBox' ? ': write its numbers (viewBox=[240,160]) and work the shapes out in those units (rect=[{index * 10},0,6,40]); the drawing is scaled to its box' : ''}. $key is left out.');
      }
      // The block is the node's custom paint, whole: written after the
      // line, it replaces a `customPaint` its `{…}` tail gave.
      // A foregroundPainter line written before it, under the node, stays.
      if (node['customPaint'] case final Map before when before['foregroundPainter'] != null && !paint.containsKey('foregroundPainter') && !(_lineTails[open.id]?.containsKey('customPaint') ?? false)) {
        paint['foregroundPainter'] = before['foregroundPainter'];
      }
      node['customPaint'] = paint;
      _lineTails[open.id]?.remove('customPaint');
      frames.add(_PaintFrame(indent, open.id, 'customPaint', paint));
      _paintChanged(open.id, 'customPaint');
    } else {
      // An animation (its tracks under it) or a transition: one more of the node's.
      final animation = head[1] == 'animation';
      final key = animation ? 'animations' : 'transitions';
      final record = _paintRecord(text, column, animation ? NodeAnimationFields.all : TransitionFields.all, head: head[1]!);
      if (record == null) {
        frames.add(_PaintFrame(indent, open.id, 'skip', {}));
        return true;
      }
      node[key] = [...?(node[key] as List?), record];
      // The list the line's tail gave is in it already: merged again, the
      // tail would take the records these lines add away.
      _lineTails[open.id]?.remove(key);
      frames.add(_PaintFrame(indent, open.id, animation ? 'animation' : 'none', record));
      _paintChanged(open.id, key);
    }
    return true;
  }

  /// [text] with the item of each `each` it is under read as the document
  /// names it (`item`, `parent.item`), as a node's line is.
  String _paintRenamed(String text) {
    final eaches = [
      for (final open in _stack)
        if (open.each != null) open.each!,
    ];
    final word = RegExp(r'^\S+').stringMatch(text) ?? '';
    var rest = text.substring(word.length);
    // Under a repeat of the drawing, `item` is the repeat's own: where the
    // drawing is itself in an each, the repeat's item has a name of its own
    // ([_repeated]), so the each's item, read as `item`, is not hidden by it.
    if (_paintStack.any((f) => f.kind == 'op' && f.target['as'] == _repeated)) rest = _rename(rest, 'item', _repeated);
    for (var k = 0; k < eaches.length; k++) {
      final around = eaches.length - 1 - k;
      final to = around == 0 ? 'item' : '${'parent.' * (around - 1)}parent.item';
      if (eaches[k] != to) rest = _rename(rest, eaches[k], to);
    }
    // A worked-out value of no type is written out where it is read, as on
    // a node's line.
    for (final d in _derived.entries) {
      if (rest.contains(d.key) && !eaches.contains(d.key)) rest = _rename(rest, d.key, '(${d.value})');
    }
    return '$word$rest';
  }

  /// A line inside the block [frame].
  void _paintInside(int indent, String text, _PaintFrame frame, int column) {
    final frames = _paintStack;
    switch (frame.kind) {
      case 'skip':
        return;
      case 'none':
        _issue(column, 'Nothing goes under this line: write it at the indent of the line above it.');
        frames.add(_PaintFrame(indent, frame.node, 'skip', {}));
        return;
      case 'animation':
        if (!RegExp(r'^track(?=[\s#{]|$)').hasMatch(text)) {
          _issue(column, 'Under an animation each line is a track: track path=opacity from=0 to=1.');
          frames.add(_PaintFrame(indent, frame.node, 'skip', {}));
          return;
        }
        final track = _paintRecord(text, column, AnimationTrackFields.all, head: 'track');
        if (track == null) {
          frames.add(_PaintFrame(indent, frame.node, 'skip', {}));
          return;
        }
        frame.target['tracks'] = [...?(frame.target['tracks'] as List?), track];
        frames.add(_PaintFrame(indent, frame.node, 'none', track));
        _paintChanged(frame.node, 'animations');
        return;
      case 'customPaint' || 'ops' when _paintControl(indent, text, frame, frame.target, frame.kind == 'ops' ? frame.list! : 'painter', column):
        return;
      case 'op' when const {'group', 'repeat'}.contains(DrawOp.opName(frame.target['op'])) && _paintControl(indent, text, frame, frame.target, 'ops', column):
        return;
      case 'customPaint':
        if (RegExp(r'^foregroundPainter(?=\s|$)').hasMatch(text)) {
          if (text.trim() != 'foregroundPainter') _issue(column, 'A foregroundPainter line holds only the ops under it.');
          frame.target['foregroundPainter'] ??= <Object?>[];
          frames.add(_PaintFrame(indent, frame.node, 'ops', frame.target, list: 'foregroundPainter'));
          _paintChanged(frame.node, 'customPaint');
          return;
        }
        _paintAdd(indent, text, frame, frame.target, 'painter', column);
        return;
      case 'ops':
        _paintAdd(indent, text, frame, frame.target, frame.list!, column);
        return;
      case 'op':
        final name = DrawOp.opName(frame.target['op']);
        if (name != 'group' && name != 'repeat') {
          _issue(column, 'A ${frame.target['op']} takes no ops under it: only a group and a repeat do.');
          frames.add(_PaintFrame(indent, frame.node, 'skip', {}));
          return;
        }
        _paintAdd(indent, text, frame, frame.target, 'ops', column);
        return;
    }
  }

  /// `if cond`, `else if cond`, `else` and `each x in list` among a
  /// drawing's lines, as on a page: the shapes under an `if` are drawn while
  /// it holds (a group with that `when`), those under an `each` once for
  /// each item of the list (a repeat that names its item, and its position
  /// with `each x, i in list`). False: [text] is none of them.
  bool _paintControl(int indent, String text, _PaintFrame frame, Json into, String list, int column) {
    final t = text.trim();
    Json? op;
    if (RegExp(r'^if\s+\S').hasMatch(t)) {
      final cond = t.substring(2).trim();
      frame.lastIf = cond;
      op = {'op': 'group', 'when': _read(cond)};
    } else if (t == 'else' || RegExp(r'^else\s+if\s+\S').hasMatch(t)) {
      final before = frame.lastIf;
      if (before == null) {
        _issue(column, 'An else follows an if at its indent: there is none before this line.');
        _paintStack.add(_PaintFrame(indent, frame.node, 'skip', {}));
        return true;
      }
      if (t == 'else') {
        frame.lastIf = null;
        op = {'op': 'group', 'when': _read('!($before)')};
      } else {
        final cond = t.replaceFirst(RegExp(r'^else\s+if\s+'), '').trim();
        frame.lastIf = '($before) || ($cond)';
        op = {'op': 'group', 'when': _read('!($before) && ($cond)')};
      }
    } else if (_Parser._eachHead.firstMatch(t) case final each?) {
      frame.lastIf = null;
      final items = t.substring(each.end).trim();
      if (items.isEmpty) return false;
      op = {
        'op': 'repeat',
        'each': _read(items),
        if (each[1] != 'item') 'as': each[1],
        if (each[2] != null && each[2] != 'index') 'indexAs': each[2],
      };
      (_paintRepeats[_top] ??= []).add((op: op, line: _line, column: column, from: _from));
    } else {
      frame.lastIf = null;
      return false;
    }
    into[list] = [...?(into[list] as List?), op];
    _paintStack.add(_PaintFrame(indent, frame.node, 'op', op));
    _paintChanged(frame.node, 'customPaint');
    return true;
  }

  /// Says, once the text is whole, each repeat that draws the same shapes
  /// every time: a set number of times (or once an item) with nothing under
  /// it reading the position or the item. A name its lines read that nothing
  /// declares is named: it was meant as one of the two.
  void _paintRepeatsRead() {
    for (final r in _paintRepeats[_top] ?? const <({Json op, int line, int column, String? from})>[]) {
      final count = r.op['count'], each = r.op['each'];
      if (each == null && !(count is num && count > 1)) continue;
      final item = '${r.op['as'] ?? 'item'}', index = '${r.op['indexAs'] ?? 'index'}';
      final itemWritten = item == _repeated ? 'item' : item;
      final read = <String>[];
      void walk(Object? v) {
        if (v is String) {
          if (v.contains(r'${')) read.add(v);
        } else if (v is List) {
          v.forEach(walk);
        } else if (v is Map) {
          v.values.forEach(walk);
        }
      }

      walk(r.op['ops']);
      bool reads(String name) => read.any((e) => RegExp('(?<![A-Za-z0-9_.])${RegExp.escape(name)}(?![A-Za-z0-9_])').hasMatch(e));
      if (reads(item) || reads(index)) continue;
      final unknown = <String>{};
      for (final e in read) {
        final code = e.replaceAll(RegExp('"[^"]*"|\'[^\']*\''), '""');
        final own = {for (final m in RegExp(r'([A-Za-z_][A-Za-z0-9_]*)\s*=>').allMatches(code)) m[1]!};
        for (final m in RegExp(r'(?<![A-Za-z0-9_.$#])([A-Za-z_][A-Za-z0-9_]*)(?![A-Za-z0-9_])(?!\s*\()').allMatches(code)) {
          final name = m[1]!;
          if (own.contains(name) || const {'true', 'false', 'null', 'item', 'index', 'parent', 'props', 'theme', 'screen', 'result', 'count'}.contains(name)) continue;
          if (variables.containsKey(name) || _projectVariables.contains(name) || options.projectVariables.containsKey(name)) continue;
          unknown.add(name);
        }
      }
      final what = each == null ? 'the position ($index, from 0)' : 'the item ($itemWritten) or its position ($index)';
      final named = unknown.isEmpty
          ? ''
          : ' ${unknown.map((n) => '"$n"').join(', ')} ${unknown.length == 1 ? 'is no name' : 'are no names'} a repeat gives: write $index${each == null ? '' : ' or $itemWritten'}, or name the position on the repeat (indexAs=${unknown.first}).';
      final message = 'This repeat draws the same shapes every time: nothing under it reads $what.$named';
      issues.add(NotationIssue(r.line, r.column, r.from == null ? message : '${r.from}: $message'));
    }
    _paintRepeats[_top] = null;
  }

  /// Reads the op [text] into [into]'s list [list], and opens its block.
  void _paintAdd(int indent, String text, _PaintFrame frame, Json into, String list, int column) {
    final op = _paintOp(text, column);
    if (op == null) {
      _paintStack.add(_PaintFrame(indent, frame.node, 'skip', {}));
      return;
    }
    if (DrawOp.opName(op['op']) == 'repeat') {
      if (!op.containsKey('as') && _stack.any((o) => o.each != null)) op['as'] = _repeated;
      (_paintRepeats[_top] ??= []).add((op: op, line: _line, column: column, from: _from));
    }
    into[list] = [...?(into[list] as List?), op];
    _paintStack.add(_PaintFrame(indent, frame.node, 'op', op));
    _paintChanged(frame.node, 'customPaint');
  }

  /// The node's [key] changed after its line was sent: sent again.
  void _paintChanged(String id, String key) {
    final node = nodes[id];
    if (node == null) return;
    _patches.add({
      'op': 'patch',
      'id': id,
      'patch': {key: _copyValue(node[key])},
    });
  }

  /// One draw op: `circle#dot c=[12,12] radius=4 fill=#FF22C55E`.
  Json? _paintOp(String text, int column) {
    final parts = LineParts.of(text);
    if (parts == null) {
      _issue(column, 'A line under a customPaint is an op: circle c=[12,12] radius=4 fill=#FF22C55E (${DrawOpSpecs.all.map((s) => s.op).join(', ')}).');
      return null;
    }
    final word = parts.word;
    final spec = DrawOpSpecs.of(DrawOp.opName(word) ?? word);
    final op = <String, Object?>{'op': word};
    if (spec == null) {
      final near = didYouMean(word, [for (final s in DrawOpSpecs.all) s.op]);
      _paintSay('type', word, column, 'No op "$word"${near == null ? '' : ': did you mean $near?'} An op is one of ${DrawOpSpecs.all.map((s) => s.op).join(', ')}.', on: 'customPaint');
    }
    final fields = <PropDef<Object?>>[...DrawOpCommonFields.all, ...?spec?.fields];
    final keys = {for (final f in fields) f.key: f};
    final paints = keys.containsKey('paint');
    if (parts.variant.isNotEmpty) _issue(column, 'An op has no variant: ${parts.variant} is not read.');
    if (parts.id.isNotEmpty) op['id'] = parts.id.substring(1);
    Object? fill, stroke;
    var filled = false, stroked = false;
    final strokeFields = <String, Object?>{}, paintFields = <String, Object?>{};
    final main = switch (spec?.op) {
      'paragraph' => 'text',
      'image' => 'url',
      _ => null,
    };
    var strings = 0;
    for (final p in parts.parts) {
      final col = column + (p.at < 0 ? 0 : p.at);
      switch (p.kind) {
        case 'string':
          if (main == null || strings++ > 0) {
            _issue(col, main == null ? 'A $word takes no text: its fields are written key=value.' : 'A $word takes one text, its $main.');
            continue;
          }
          op[main] = _paintValue(p.raw, col);
        case 'word':
          if (keys[p.raw]?.type.kind == PropKind.boolean || (spec == null && RegExp(r'^[A-Za-z_]\w*$').hasMatch(p.raw))) {
            op[p.raw] = true;
          } else if (paints && p.raw == 'scaleStroke') {
            strokeFields[p.raw] = true;
          } else if (RegExp(r'^([A-Za-z_]\w*)((?:\.[A-Za-z_]\w*)+)=(.+)$').firstMatch(p.raw) case final m? when keys.containsKey(m[1])) {
            // `style.color=#FF… style.fontSize=10`: a field of a record
            // field by its dotted path, as on a node line (test 10: 9 runs).
            final path = '${m[1]}${m[2]}'.split('.');
            var at = op;
            for (final k in path.take(path.length - 1)) {
              at = switch (at[k]) {
                final Map n => n.cast<String, Object?>(),
                _ => at[k] = <String, Object?>{},
              };
            }
            at[path.last] = _paintValue(m[3]!, col);
          } else {
            _paintUnknown(word, p.raw, keys, col, kind: 'flag');
          }
        case 'pair':
          final key = p.key!, value = _paintValue(p.value!, col);
          if (paints && key == 'fill') {
            fill = value;
            filled = true;
          } else if (paints && key == 'stroke') {
            stroke = value;
            stroked = true;
          } else if (paints && notationStrokeWords.contains(key)) {
            strokeFields[key] = value;
          } else if (paints && notationPaintWords.contains(key)) {
            paintFields[key] = value;
          } else if (keys.containsKey(key) || spec == null) {
            op[key] = value;
          } else if (key.contains('.') && keys.containsKey(key.substring(0, key.indexOf('.')))) {
            // `style.color=#FF… style.fontSize=10`: a field of a record
            // field by its dotted path, as on a node line (test 10: 9 runs).
            final path = key.split('.');
            var at = op;
            for (final k in path.take(path.length - 1)) {
              at = switch (at[k]) {
                final Map m => m.cast<String, Object?>(),
                _ => at[k] = <String, Object?>{},
              };
            }
            at[path.last] = value;
          } else {
            _paintUnknown(word, key, keys, col, value: p.value);
            op[key] = value;
          }
        case 'tail':
          final j = _json(p.raw);
          if (j is Map) op.addAll(mergePatch(op, j.cast<String, Object?>(), keepNulls: true));
      }
    }
    if (strokeFields.isNotEmpty && !stroked) {
      _issue(column, '${strokeFields.keys.join(', ')} go${strokeFields.length == 1 ? 'es' : ''} with stroke= (the stroke\'s color): stroke=#FF111827 strokeWidth=2.');
    }
    if (paintFields.isNotEmpty && !filled && !stroked) {
      _issue(column, '${paintFields.keys.join(', ')} go${paintFields.length == 1 ? 'es' : ''} with fill= or stroke= (it softens what they paint): fill=#80F59E0B blurRadius=18.');
    }
    if (filled || stroked) {
      if (op.containsKey('paint')) _issue(column, 'An op\'s paint is fill= and stroke=, or paint=, not both.');
      final strokePaint = {'color': stroke, 'style': 'stroke', ...strokeFields, ...paintFields};
      final fillPaint = paintFields.isEmpty ? fill : {'color': fill, ...paintFields};
      op['paint'] = filled && stroked ? [fillPaint, strokePaint] : stroked ? strokePaint : fillPaint;
    }
    return op;
  }

  void _paintUnknown(String on, String key, Map<String, PropDef<Object?>> fields, int column, {String kind = 'parameter', String? value}) {
    final keys = fields.keys;
    final near = didYouMean(key, [...keys, 'fill', 'stroke', ...notationStrokeWords, ...notationPaintWords]);
    // A point or a rectangle is one key with its numbers in a list (a
    // circle's `cx=` and `cy=` are its `c=[x,y]`): said as it is written.
    final whole = switch (fields[near]?.type.name) {
      'Offset' => ' $near is a point, both numbers in one key: $near=[x,y].',
      'Rect' => ' $near is a rectangle in one key: $near=[left,top,width,height].',
      _ => '',
    };
    _paintSay(kind, key, column, 'A $on has no "$key"${near == null ? '' : ': did you mean $near?'}$whole It takes ${[...keys, 'fill', 'stroke'].join(', ')}.', on: on, value: value);
  }

  /// A word the record does not take: said, or with the open vocabulary
  /// recorded (design 19).
  void _paintSay(String kind, String word, int column, String message, {required String on, String? value}) {
    if (options.openVocabulary) {
      _use(kind, word, column, on: on, value: value, say: message);
    } else {
      _issue(column, message);
    }
  }

  /// A head or a track: `[head][#id] key=value … [{…}]`, its keys the
  /// declared [fields]. Null when the line is not one.
  Json? _paintRecord(String text, int column, List<PropDef<Object?>> fields, {required String head}) {
    final parts = LineParts.of(text);
    if (parts == null || parts.word != head) {
      _issue(column, 'Expected a $head line.');
      return null;
    }
    final keys = {for (final f in fields) f.key: f};
    final out = <String, Object?>{};
    if (parts.id.isNotEmpty) {
      if (keys.containsKey('id')) {
        out['id'] = parts.id.substring(1);
      } else {
        _issue(column, 'A $head has no id.');
      }
    }
    if (parts.variant.isNotEmpty) _issue(column, 'A $head has no variant: ${parts.variant} is not read.');
    for (final p in parts.parts) {
      final col = column + (p.at < 0 ? 0 : p.at);
      switch (p.kind) {
        case 'string':
          _issue(col, 'A $head takes no text: its fields are written key=value.');
        case 'word':
          if (keys[p.raw]?.type.kind == PropKind.boolean) {
            out[p.raw] = true;
          } else {
            final near = didYouMean(p.raw, keys.keys);
            _paintSay('flag', p.raw, col, 'A $head has no flag "${p.raw}"${near == null ? '' : ': did you mean $near?'}', on: head);
          }
        case 'pair':
          final key = p.key!;
          // A drawing is as big as the line it is under: a size written on
          // it is that line's.
          if (head == 'customPaint' && !keys.containsKey(key) && const {'w', 'h', 'width', 'height', 'size', 'maxw', 'maxh', 'minw', 'minh', 'grow'}.contains(key)) {
            _issue(col, 'A customPaint is the drawing of the line it is under and is as big as that line: write $key= on that line (Box w=240 h=160, the customPaint under it), not on the customPaint. $key=${p.value} is left out.');
            continue;
          }
          if (!keys.containsKey(key)) {
            final near = didYouMean(key, keys.keys);
            _paintSay('parameter', key, col, 'A $head has no "$key"${near == null ? '' : ': did you mean $near?'} It takes ${keys.keys.join(', ')}.', on: head, value: p.value);
          }
          out[key] = _paintValue(p.value!, col);
        case 'tail':
          final j = _json(p.raw);
          if (j is Map) out.addAll(mergePatch(out, j.cast<String, Object?>(), keepNulls: true));
      }
    }
    return out;
  }

  /// A value of a record's word (design 22, 2.1 and 4.6): a number, true,
  /// false or null, a quoted string (`{name}` in it reads the state, `${…}`
  /// written in it stays), `{expression}`, JSON for a map or a list, a list
  /// with expressions among its items, else the bare word.
  Object? _paintValue(String raw, int column) {
    if (raw == 'true') return true;
    if (raw == 'false') return false;
    if (raw == 'null') return null;
    final n = num.tryParse(raw);
    if (n != null) return n;
    if (raw.startsWith('"')) {
      Object? s;
      try {
        s = jsonDecode(raw);
      } catch (_) {
        s = raw.length > 1 && raw.endsWith('"') ? raw.substring(1, raw.length - 1) : raw.substring(1);
      }
      if (s is! String) return s;
      return s.contains(r'${') ? s : _interpolate(s);
    }
    if (_Parser._bracedExpression(raw)) return _read(raw.substring(1, raw.length - 1));
    if (raw.startsWith('{')) return _json(raw);
    if (raw.startsWith('[')) {
      try {
        return jsonDecode(raw);
      } catch (_) {}
      if (!raw.endsWith(']')) {
        _issue(column, 'A list is closed with ]: $raw');
        return raw;
      }
      final inner = raw.substring(1, raw.length - 1).trim();
      if (inner.isEmpty) return <Object?>[];
      return [for (final e in _split(inner, ',')) _paintValue(e.trim(), column)];
    }
    return raw;
  }
}
