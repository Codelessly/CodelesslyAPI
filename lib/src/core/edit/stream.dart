// Incremental decoding of a streamed `ui_apply` tool input. LLM APIs deliver
// a tool call's JSON input as text deltas cut anywhere (mid-key, mid-string,
// mid-number); this decoder yields each op the moment its closing brace
// arrives, and, inside a `set` with a `nodes` map, each node the moment its
// own closing brace arrives (so one big op still paints progressively).
//
// Guarantees: the ops yielded depend only on the text, not on how it was
// cut into deltas; nothing throws; a stream cut mid-op keeps every op (and
// node) that completed and reports the tail ([OpStreamEnd.truncated]).
import 'dart:convert';

import 'package:meta/meta.dart';

import '../json.dart';
import 'diagnostics.dart';
import 'edit_ops.dart';

/// One op out of a stream: the index of the op it came from in the tool
/// input's `ops`, and whether it is part of a `set` op still arriving (a
/// node of its `nodes` map).
@immutable
final class StreamedOp {
  const StreamedOp(this.index, this.op, {this.partial = false});
  final int index;
  final EditOp op;

  /// A node of a `set` whose `nodes` map has not closed yet.
  final bool partial;

  @override
  String toString() => 'StreamedOp($index${partial ? ' partial' : ''}: ${op.toJson()})';
}

/// What is left when a stream ends: what could not be read, the tool
/// input's `baseRev` and `atomic`, and the truncated tail if it ended
/// inside an op.
@immutable
final class OpStreamEnd {
  const OpStreamEnd({this.diagnostics = const [], this.baseRev, this.atomic = false, this.truncated, this.complete = true, this.opCount = 0});

  /// Ops (or text) that could not be read; a truncated op's `truncated_op`.
  final List<EditDiagnostic> diagnostics;
  final int? baseRev;
  final bool atomic;

  /// The text of the op that was arriving when the stream ended, if any.
  final String? truncated;

  /// Whether the input's JSON closed.
  final bool complete;

  /// How many ops of `ops` began.
  final int opCount;
}

/// Decodes a streamed `ui_apply` input: [add] each text delta and it returns
/// the ops that delta completed; [close] at the end.
///
/// Accepts `{"ops": [...], "baseRev": n, "atomic": b}` (in any key order),
/// a bare list of ops, and text before the first `{` or `[` (skipped).
class OpStreamDecoder {
  OpStreamDecoder({this.partialSets = true});

  /// Whether a `set` with `nodes` yields each node as it completes.
  final bool partialSets;

  final StringBuffer _all = StringBuffer();
  int _pos = 0;
  String? _cache;

  // Scanner state.
  bool _started = false;
  bool _inString = false;
  bool _escape = false;
  int _unicode = 0;
  int _stringStart = -1;
  int _scalarStart = -1;
  bool _done = false;
  final List<_Frame> _stack = [];

  // Ops.
  int _opCount = 0;
  int? _baseRev;
  bool _atomic = false;
  final List<EditDiagnostic> _diagnostics = [];

  /// Problems so far (ops that are not ops, invalid JSON).
  List<EditDiagnostic> get diagnostics => List.unmodifiable(_diagnostics);

  String get _text => _cache ??= _all.toString();

  /// Feeds [delta]; returns the ops it completed, in order.
  List<StreamedOp> add(String delta) {
    if (delta.isEmpty || _done) return const [];
    _all.write(delta);
    _cache = null;
    final out = <StreamedOp>[];
    final end = _pos + delta.length;
    for (; _pos < end; _pos++) {
      _char(delta.codeUnitAt(_pos - (end - delta.length)), _pos, out);
      if (_done) {
        _pos++;
        break;
      }
    }
    return out;
  }

  /// Ends the stream: anything still open is reported.
  OpStreamEnd close() {
    final out = <StreamedOp>[];
    // A scalar at the very end (a bare number) completes now.
    if (_scalarStart >= 0) _endScalar(_pos, out);
    String? truncated;
    if (!_started) {
      if (_text.trim().isNotEmpty) {
        _diagnostics.add(EditDiagnostic.of(EditCodes.invalidJson, -1, 'The tool input has no JSON object or list.'));
      } else {
        _diagnostics.add(EditDiagnostic.of(EditCodes.missingField, -1, 'The tool input is empty: send {"ops": [...]}.', path: '/ops'));
      }
    }
    final opFrame = _stack.indexWhere((f) => f.role == _Role.op);
    if (opFrame >= 0) {
      final f = _stack[opFrame];
      truncated = _text.substring(f.start);
      _diagnostics.add(EditDiagnostic.of(EditCodes.truncatedOp, f.index,
          'The input ended inside op ${f.index} (${truncated.length} characters arrived): it was not applied${f.yielded.isEmpty ? '' : ', except the ${f.yielded.length} nodes of it that had arrived whole'}. Resend it.',
          path: '/ops/${f.index}'));
    }
    return OpStreamEnd(
      diagnostics: List.unmodifiable(_diagnostics),
      baseRev: _baseRev,
      atomic: _atomic,
      truncated: truncated,
      complete: _done,
      opCount: _opCount,
    );
  }

  // --- scanning ---------------------------------------------------------------

  static const _quote = 0x22, _backslash = 0x5C, _lbrace = 0x7B, _rbrace = 0x7D, _lbracket = 0x5B, _rbracket = 0x5D, //
      _comma = 0x2C, _colon = 0x3A;

  bool _ws(int c) => c == 0x20 || c == 0x0A || c == 0x0D || c == 0x09;

  void _char(int c, int at, List<StreamedOp> out) {
    if (_inString) {
      if (_unicode > 0) {
        _unicode--;
        return;
      }
      if (_escape) {
        _escape = false;
        if (c == 0x75) _unicode = 4; // \uXXXX
        return;
      }
      if (c == _backslash) {
        _escape = true;
        return;
      }
      if (c == _quote) {
        _inString = false;
        _endString(at, out);
      }
      return;
    }
    if (!_started) {
      if (c == _lbrace || c == _lbracket) {
        _started = true;
      } else {
        return;
      }
    }
    if (_scalarStart >= 0) {
      if (_ws(c) || c == _comma || c == _rbrace || c == _rbracket || c == _colon) {
        _endScalar(at, out);
      } else {
        return;
      }
    }
    if (_ws(c)) return;
    switch (c) {
      case _lbrace || _lbracket:
        _stack.add(_Frame(c == _lbrace, at, _roleOfNew(c == _lbracket), _indexOfNew()));
        if (_stack.last.role == _Role.op) _opCount++;
      case _rbrace || _rbracket:
        if (_stack.isEmpty) return;
        final f = _stack.removeLast();
        _endValue(f.start, at + 1, out, frame: f);
        if (_stack.isEmpty) _done = true;
      case _quote:
        _inString = true;
        _stringStart = at;
      case _colon:
        if (_stack.isNotEmpty && _stack.last.isObject) _stack.last.expectKey = false;
      case _comma:
        if (_stack.isEmpty) return;
        final f = _stack.last;
        if (f.isObject) {
          f.expectKey = true;
          f.key = null;
        } else {
          f.count++;
        }
      default:
        _scalarStart = at;
    }
  }

  /// The role of a container starting now, from where it sits.
  _Role _roleOfNew(bool isList) {
    if (_stack.isEmpty) return isList ? _Role.ops : _Role.input;
    final p = _stack.last;
    switch (p.role) {
      case _Role.input:
        return p.key == 'ops' && isList ? _Role.ops : _Role.other;
      case _Role.ops:
        return isList ? _Role.other : _Role.op;
      case _Role.op:
        return p.key == 'nodes' && !isList ? _Role.nodes : _Role.other;
      case _Role.nodes:
        return isList ? _Role.other : _Role.node;
      default:
        return _Role.other;
    }
  }

  int _indexOfNew() {
    if (_stack.isEmpty) return -1;
    final p = _stack.last;
    return p.role == _Role.ops ? p.count : (p.role == _Role.op || p.role == _Role.nodes ? p.index : -1);
  }

  void _endString(int at, List<StreamedOp> out) {
    if (_stack.isEmpty) return;
    final f = _stack.last;
    final raw = _text.substring(_stringStart, at + 1);
    if (f.isObject && f.expectKey) {
      f.key = _decodeString(raw);
      return;
    }
    _endValue(_stringStart, at + 1, out);
  }

  void _endScalar(int at, List<StreamedOp> out) {
    final start = _scalarStart;
    _scalarStart = -1;
    _endValue(start, at, out);
  }

  String? _decodeString(String raw) {
    try {
      final v = jsonDecode(raw);
      return v is String ? v : null;
    } catch (_) {
      return null;
    }
  }

  /// A value (container [frame], or a scalar/string) spanning [start, end)
  /// completed, inside the frame now on top of the stack.
  void _endValue(int start, int end, List<StreamedOp> out, {_Frame? frame}) {
    final parent = _stack.isEmpty ? null : _stack.last;
    if (frame != null && frame.role == _Role.op) {
      _opDone(frame, _text.substring(start, end), out);
      return;
    }
    if (frame != null && frame.role == _Role.node && parent != null) {
      _nodeDone(parent, _text.substring(start, end), out);
      return;
    }
    if (parent == null) return;
    if (parent.role == _Role.op && parent.key == 'op' && frame == null) {
      parent.opName = _decodeString(_text.substring(start, end))?.toLowerCase();
      if (parent.opName == SetOp.opName) _flushDeferred(parent, out);
    } else if (parent.role == _Role.input && frame == null) {
      final v = _scalar(_text.substring(start, end));
      if (parent.key == 'baseRev') _baseRev = readInt(v);
      if (parent.key == 'atomic') _atomic = readBool(v) ?? false;
    } else if (parent.role == _Role.ops && frame == null) {
      // A scalar where an op should be.
      _opDone(_Frame(false, start, _Role.op, parent.count), _text.substring(start, end), out);
    }
  }

  Object? _scalar(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  /// A node of a `nodes` map ([nodes] is the map's frame) completed.
  void _nodeDone(_Frame nodes, String text, List<StreamedOp> out) {
    if (!partialSets) return;
    final key = nodes.key;
    final op = _stack.length >= 2 ? _stack[_stack.length - 2] : null;
    if (key == null || op == null || op.role != _Role.op) return;
    final json = _scalar(text);
    final node = readMap(json);
    if (node == null) return;
    if (op.opName == null) {
      op.deferred.add((key, node));
    } else if (op.opName == SetOp.opName) {
      op.yielded.add(key);
      out.add(StreamedOp(op.index, SetOp(key, node.containsKey('id') ? ({...node}..remove('id')) : node), partial: true));
    }
  }

  void _flushDeferred(_Frame op, List<StreamedOp> out) {
    for (final (key, node) in op.deferred) {
      op.yielded.add(key);
      out.add(StreamedOp(op.index, SetOp(key, node.containsKey('id') ? ({...node}..remove('id')) : node), partial: true));
    }
    op.deferred.clear();
  }

  void _opDone(_Frame f, String text, List<StreamedOp> out) {
    Object? json;
    try {
      json = jsonDecode(text);
    } catch (e) {
      _diagnostics.add(EditDiagnostic.of(EditCodes.invalidJson, f.index, 'Op ${f.index} is not valid JSON: ${'$e'.split('\n').first}.',
          path: '/ops/${f.index}'));
      return;
    }
    final decoded = decodeOps([json]);
    for (final d in decoded.diagnostics) {
      _diagnostics.add(EditDiagnostic(
          op: f.index,
          code: d.code,
          error: d.error,
          path: d.path.replaceFirst('/ops/0', '/ops/${f.index}'),
          message: d.message,
          expected: d.expected,
          suggestion: d.suggestion));
    }
    for (final (_, op) in decoded.ops) {
      // Nodes of a bulk set already yielded are not yielded again.
      if (op is SetOp && f.yielded.contains(op.id) && readMap(json)?['nodes'] != null) continue;
      out.add(StreamedOp(f.index, op));
    }
  }
}

enum _Role { input, ops, op, nodes, node, other }

class _Frame {
  _Frame(this.isObject, this.start, this.role, this.index) : expectKey = isObject;
  final bool isObject;
  final int start;
  final _Role role;

  /// For an op (and what is inside it): the op's index in `ops`.
  final int index;
  bool expectKey;
  String? key;

  /// Elements seen so far (a list).
  int count = 0;

  /// An op's `op`, once read.
  String? opName;

  /// Nodes of an op's `nodes` that completed before its `op` was read.
  final List<(String, Json)> deferred = [];
  final Set<String> yielded = {};
}

/// Decodes [deltas] as they arrive ([OpStreamDecoder]): every op as soon as
/// it is complete. The stream's problems are not reported here: use the
/// decoder for [OpStreamEnd].
Stream<StreamedOp> decodeOpStream(Stream<String> deltas, {bool partialSets = true}) async* {
  final d = OpStreamDecoder(partialSets: partialSets);
  await for (final delta in deltas) {
    yield* Stream.fromIterable(d.add(delta));
  }
  d.close();
}
