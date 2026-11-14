// Incremental decoding of a streamed `ui_apply` tool input. LLM APIs deliver
// a tool call's JSON input as text deltas cut anywhere (mid-key, mid-string,
// mid-number); this decoder yields each op the moment its closing brace
// arrives, and, inside a `set` with a `nodes` map, each node the moment its
// own closing brace arrives (so one big op still paints progressively).
//
// It is built around op boundaries, not around the enclosing JSON being
// valid: with eager (fine-grained) tool input streaming a provider does not
// guarantee well-formed JSON, and real models do emit an extra closing brace,
// close the `ops` array early, leave trailing commas or start an op before
// the previous one closed. The scanner keeps a repaired copy of the text
// (stray closers dropped, missing ones inferred, trailing commas removed,
// missing commas inserted), recognizes an op object (`{"op": ...}`) at any
// depth outside another op, and re-synchronises when an op begins inside an
// op that never closed. Each repair is one `malformed_input` warning with
// its character offset; the ops around it are kept.
//
// Guarantees: the ops yielded depend only on the text, not on how it was
// cut into deltas; nothing throws; a stream cut mid-op keeps every op (and
// node) that completed and reports the tail ([OpStreamEnd.truncated]); a
// single stray or missing brace, bracket or comma loses at most the op it is
// in.
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
  const StreamedOp(this.index, this.op, {this.partial = false, this.recovered = false});
  final int index;
  final EditOp op;

  /// A node of a `set` whose `nodes` map has not closed yet.
  final bool partial;

  /// Read after the input stopped being well-formed JSON: a strict JSON
  /// reading of the input would have lost it.
  final bool recovered;

  @override
  String toString() => 'StreamedOp($index${partial ? ' partial' : ''}${recovered ? ' recovered' : ''}: ${op.toJson()})';
}

/// What is left when a stream ends: what could not be read, the tool
/// input's `baseRev` and `atomic`, and the truncated tail if it ended
/// inside an op.
@immutable
final class OpStreamEnd {
  const OpStreamEnd(
      {this.diagnostics = const [],
      this.baseRev,
      this.atomic = false,
      this.truncated,
      this.complete = true,
      this.opCount = 0,
      this.repairs = 0,
      this.recovered = 0});

  /// Ops (or text) that could not be read; a truncated op's `truncated_op`;
  /// each repair of malformed JSON (`malformed_input`, a warning).
  final List<EditDiagnostic> diagnostics;
  final int? baseRev;
  final bool atomic;

  /// The text of the op that was arriving when the stream ended, if any.
  final String? truncated;

  /// Whether the input's JSON closed (every bracket that opened, closed).
  final bool complete;

  /// How many ops began.
  final int opCount;

  /// How many times the decoder repaired malformed JSON.
  final int repairs;

  /// How many ops were read after the input first stopped being well
  /// formed: the ops a strict JSON reading would have lost.
  final int recovered;
}

/// Decodes a streamed `ui_apply` input: [add] each text delta and it returns
/// the ops that delta completed; [close] at the end.
///
/// Accepts `{"ops": [...], "baseRev": n, "atomic": b}` (in any key order),
/// a bare list of ops, one op, text before and after the JSON, and JSON
/// that is not well formed (see the file comment).
class OpStreamDecoder {
  OpStreamDecoder({this.partialSets = true, this.maxReports = 20});

  /// Whether a `set` with `nodes` yields each node as it completes.
  final bool partialSets;

  /// At most this many `malformed_input` warnings; the rest are counted in
  /// one more.
  final int maxReports;

  // The repaired text: what the ops are parsed from.
  final List<int> _clean = [];
  int _pos = 0;

  // Scanner state.
  bool _started = false;
  bool _inString = false;
  bool _escape = false;
  int _unicode = 0;
  int _stringStart = -1;
  bool _stringIsKey = false;
  int _scalarStart = -1;
  bool _dropping = false;
  final List<_Frame> _stack = [];

  // Ops.
  int _opCount = 0;
  int? _baseRev;
  bool _atomic = false;
  final List<EditDiagnostic> _diagnostics = [];
  int _repairs = 0;
  int _recovered = 0;
  int? _firstRepair;
  int _lastOp = -1;

  /// Problems so far (ops that are not ops, invalid JSON, repairs).
  List<EditDiagnostic> get diagnostics => List.unmodifiable(_diagnostics);

  /// Feeds [delta]; returns the ops it completed, in order.
  List<StreamedOp> add(String delta) {
    if (delta.isEmpty) return const [];
    final out = <StreamedOp>[];
    for (var i = 0; i < delta.length; i++) {
      _char(delta.codeUnitAt(i), _pos, out);
      _pos++;
    }
    return out;
  }

  /// Ends the stream: anything still open is reported.
  OpStreamEnd close() {
    final out = <StreamedOp>[];
    // A scalar at the very end (a bare number) completes now.
    if (_scalarStart >= 0) _endScalar(out);
    String? truncated;
    if (!_started) {
      if (_pos > 0 && _cleanIsBlankRaw) {
        _diagnostics.add(EditDiagnostic.of(EditCodes.missingField, -1, 'The tool input is empty: send {"ops": [...]}.', path: '/ops'));
      } else if (_pos > 0) {
        _diagnostics.add(EditDiagnostic.of(EditCodes.invalidJson, -1, 'The tool input has no JSON object or list: send {"ops": [...]}.',
            path: '/ops'));
      } else {
        _diagnostics.add(EditDiagnostic.of(EditCodes.missingField, -1,
            'The tool input is empty: the turn ended without ops. Call ui_apply with {"ops": [...]}.',
            path: '/ops'));
      }
    }
    final opFrame = _stack.indexWhere((f) => f.role == _Role.op);
    if (opFrame >= 0) {
      final f = _stack[opFrame];
      truncated = _cleanText(f.cleanStart, _clean.length);
      _diagnostics.add(EditDiagnostic.of(EditCodes.truncatedOp, f.index,
          'The input ended inside op ${f.index} (${_pos - f.start} characters arrived): it was not applied${f.yielded.isEmpty ? '' : ', except the ${f.yielded.length} nodes of it that had arrived whole'}. Resend it.',
          path: '/ops/${f.index}'));
    } else if (_stack.isNotEmpty) {
      _repair(-1, _pos, 'the input ended with ${_stack.length} bracket${_stack.length == 1 ? '' : 's'} still open (every op in it was read)');
    }
    if (_repairs > maxReports) {
      _diagnostics.add(EditDiagnostic.of(EditCodes.malformedInput, -1,
          '${_repairs - maxReports} more repairs of malformed JSON were not listed.'));
    }
    return OpStreamEnd(
      diagnostics: List.unmodifiable(_diagnostics),
      baseRev: _baseRev,
      atomic: _atomic,
      truncated: truncated,
      complete: _started && _stack.isEmpty,
      opCount: _opCount,
      repairs: _repairs,
      recovered: _recovered,
    );
  }

  bool _rawBlank = true;
  bool get _cleanIsBlankRaw => _rawBlank;

  // --- scanning ---------------------------------------------------------------

  static const _quote = 0x22, _backslash = 0x5C, _lbrace = 0x7B, _rbrace = 0x7D, _lbracket = 0x5B, _rbracket = 0x5D, //
      _comma = 0x2C, _colon = 0x3A;

  static bool _ws(int c) => c == 0x20 || c == 0x0A || c == 0x0D || c == 0x09;

  void _repair(int op, int at, String what) {
    _repairs++;
    _firstRepair ??= at;
    if (_repairs > maxReports) return;
    final where = op < 0 && _lastOp >= 0 ? ' (after op $_lastOp)' : '';
    _diagnostics.add(EditDiagnostic.of(EditCodes.malformedInput, op,
        'Malformed JSON at character $at$where: $what. Repaired; the ops around it were read.',
        path: op >= 0 ? '/ops/$op' : ''));
  }

  /// The op a repair at the top of the stack is in (-1: none).
  int get _currentOp {
    for (var i = _stack.length - 1; i >= 0; i--) {
      if (_stack[i].role == _Role.op) return _stack[i].index;
    }
    return -1;
  }

  void _char(int c, int at, List<StreamedOp> out) {
    if (!_ws(c)) _rawBlank = false;
    if (_inString) {
      _clean.add(c);
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
        _endString(out);
      }
      return;
    }
    if (_stack.isEmpty) {
      // Before the JSON, between top-level values, after it: prose.
      if (c == _lbrace || c == _lbracket) {
        _started = true;
        _push(c == _lbrace, at, out);
      }
      return;
    }
    if (_scalarStart >= 0 || _dropping) {
      if (_ws(c) || c == _comma || c == _rbrace || c == _rbracket || c == _colon || c == _quote || c == _lbrace || c == _lbracket) {
        if (_dropping) {
          _dropping = false;
        } else {
          _endScalar(out);
        }
      } else {
        if (!_dropping) _clean.add(c);
        return;
      }
    }
    if (_ws(c)) return;
    final top = _stack.last;
    switch (c) {
      case _lbrace || _lbracket:
        _push(c == _lbrace, at, out);
      case _rbrace || _rbracket:
        _close(c == _rbrace, at, out);
      case _quote:
        if (top.isObject) {
          switch (top.expect) {
            case _Expect.key:
              _stringIsKey = true;
            case _Expect.next:
              _clean.add(_comma);
              _repair(_currentOp, at, 'a missing comma before a key');
              top.expect = _Expect.key;
              _stringIsKey = true;
            case _Expect.colon:
              // The previous key never got a value: drop it.
              _dropKey(top);
              _repair(_currentOp, at, 'a key with no value');
              top.expect = _Expect.key;
              _stringIsKey = true;
            case _Expect.value:
              _stringIsKey = false;
          }
        } else {
          _valueStart(top, at);
          _stringIsKey = false;
        }
        _inString = true;
        _stringStart = _clean.length;
        _clean.add(c);
      case _colon:
        if (top.isObject && top.expect == _Expect.colon) {
          _clean.add(c);
          top.expect = _Expect.value;
        } else {
          _repair(_currentOp, at, 'a colon where none belongs (dropped)');
        }
      case _comma:
        if (top.expect == _Expect.next) {
          _clean.add(c);
          top.expect = top.isObject ? _Expect.key : _Expect.value;
        } else if (top.isObject && (top.expect == _Expect.colon || top.expect == _Expect.value)) {
          _dropKey(top);
          top.expect = _Expect.key;
          _repair(_currentOp, at, 'a key with no value');
        } else {
          _repair(_currentOp, at, 'an extra comma (dropped)');
        }
      default:
        if (top.isObject && top.expect != _Expect.value) {
          _dropping = true;
          _repair(_currentOp, at, 'a bare value where a key belongs (dropped)');
          return;
        }
        if (!top.isObject) _valueStart(top, at);
        _scalarStart = _clean.length;
        _clean.add(c);
    }
  }

  /// A value begins in list [top]: a comma it lacks is inserted.
  void _valueStart(_Frame top, int at) {
    if (!top.isObject && top.expect == _Expect.next) {
      _clean.add(_comma);
      _repair(_currentOp, at, 'a missing comma between two values');
      top.expect = _Expect.value;
    }
  }

  /// Removes [f]'s last key (written, with no value) from the clean text.
  void _dropKey(_Frame f) {
    if (f.keyCleanStart >= 0 && f.keyCleanStart <= _clean.length) _clean.length = f.keyCleanStart;
    f.key = null;
    f.keyCleanStart = -1;
    _trimTrailingComma(f);
  }

  void _trimTrailingComma(_Frame f) {
    if (_clean.length > f.cleanStart + 1 && _clean.last == _comma) _clean.removeLast();
  }

  void _push(bool isObject, int at, List<StreamedOp> out) {
    final parent = _stack.isEmpty ? null : _stack.last;
    var misplaced = false;
    _Expect? saved;
    if (parent != null) {
      if (parent.isObject) {
        switch (parent.expect) {
          case _Expect.value:
            break;
          case _Expect.colon:
            _clean.add(_colon);
            _repair(_currentOp, at, 'a missing colon after "${parent.key}"');
          case _Expect.key || _Expect.next:
            // An object or list where a key belongs: it is kept apart (an op
            // that begins here is still read), then dropped.
            misplaced = true;
            saved = parent.expect;
        }
      } else {
        _valueStart(parent, at);
      }
    }
    final role = _roleOfNew(parent, !isObject, misplaced);
    final f = _Frame(isObject, at, _clean.length, role)
      ..misplaced = misplaced
      ..savedExpect = saved
      ..opDepth = parent == null ? -1 : (parent.role == _Role.op ? _stack.length - 1 : parent.opDepth);
    if (role == _Role.op) {
      f.index = _opCount++;
      f.opDepth = -1;
    }
    _clean.add(isObject ? _lbrace : _lbracket);
    _stack.add(f);
  }

  /// The role of a container starting now under [p].
  _Role _roleOfNew(_Frame? p, bool isList, bool misplaced) {
    if (p == null) return isList ? _Role.ops : _Role.candidate;
    final key = misplaced ? null : p.key;
    switch (p.role) {
      case _Role.ops:
        return isList ? _Role.plain : _Role.op;
      case _Role.op:
        return key == 'nodes' && !isList && !misplaced ? _Role.nodes : _Role.inner;
      case _Role.nodes:
        return isList || misplaced ? _Role.inner : _Role.node;
      case _Role.node || _Role.inner:
        return _Role.inner;
      case _Role.candidate || _Role.plain:
        if (key == 'ops' && isList) return _Role.ops;
        return isList ? _Role.plain : _Role.candidate;
    }
  }

  void _close(bool brace, int at, List<StreamedOp> out) {
    final top = _stack.last;
    if (top.isObject != brace) {
      // A closer of the other kind. When the frame below is of its kind, the
      // top one's own closer is missing: close both. The ops list itself is
      // never closed by a brace: a brace there is stray.
      final below = _stack.length >= 2 ? _stack[_stack.length - 2] : null;
      if (below != null && below.isObject == brace && top.role != _Role.ops) {
        _repair(_currentOp, at, 'a missing "${top.isObject ? '}' : ']'}" (inferred)');
        _closeTop(at, out);
        _close(brace, at, out);
      } else {
        _repair(_currentOp, at, 'a "${brace ? '}' : ']'}" that closes nothing here (ignored)');
      }
      return;
    }
    _closeTop(at, out);
  }

  void _closeTop(int at, List<StreamedOp> out) {
    final f = _stack.last;
    if (f.isObject && (f.expect == _Expect.colon || f.expect == _Expect.value)) {
      _dropKey(f);
      _repair(_currentOp, at, 'a key with no value before "}"');
    } else if (f.expect == (f.isObject ? _Expect.key : _Expect.value) && _clean.last == _comma) {
      _clean.removeLast();
      _repair(_currentOp, at, 'a trailing comma (dropped)');
    }
    _clean.add(f.isObject ? _rbrace : _rbracket);
    _stack.removeLast();
    _frameDone(f, out);
  }

  void _frameDone(_Frame f, List<StreamedOp> out) {
    final parent = _stack.isEmpty ? null : _stack.last;
    if (f.misplaced && f.role == _Role.op) _repair(f.index, f.start, 'op ${f.index} is outside the "ops" list (read)');
    switch (f.role) {
      case _Role.op:
        _opDone(f, null, out);
      case _Role.node:
        if (parent != null) _nodeDone(parent, f, out);
      case _Role.candidate:
        _candidateDone(f, out);
      default:
        // It held ops while it might have been one; it is not.
        for (final s in f.pending) {
          _emit(f, s, out);
        }
    }
    if (f.misplaced) {
      // Out of the parent's text, which goes on as before it.
      _clean.length = f.cleanStart;
      if (parent != null && f.role != _Role.op) {
        parent.expect = f.savedExpect ?? parent.expect;
        _repair(_currentOp, f.start, 'an ${f.isObject ? 'object' : 'list'} where a key belongs (dropped)');
      } else if (parent != null) {
        parent.expect = f.savedExpect ?? parent.expect;
      }
      return;
    }
    if (parent != null) parent.expect = _Expect.next;
  }

  void _endString(List<StreamedOp> out) {
    final top = _stack.last;
    final raw = _cleanText(_stringStart, _clean.length);
    if (_stringIsKey) {
      final key = _decodeString(raw);
      top.key = key;
      top.keyCleanStart = _stringStart;
      top.expect = _Expect.colon;
      top.keys++;
      _keyRead(top, key, out);
      return;
    }
    _valueDone(top, raw, true, out);
    top.expect = _Expect.next;
  }

  void _endScalar(List<StreamedOp> out) {
    final start = _scalarStart;
    _scalarStart = -1;
    if (_stack.isEmpty) return;
    final top = _stack.last;
    _valueDone(top, _cleanText(start, _clean.length), false, out);
    top.expect = _Expect.next;
  }

  /// Keys every op may have: a candidate object with another key is not an
  /// op.
  static final Set<String> _opKeys = {
    for (final s in EditOp.specs)
      for (final f in s.fields) f.key,
  };

  /// Second keys that confirm that an object whose first key names an op
  /// is an op (an action's `"op": "set"` is followed by `variable`).
  static const Set<String> _confirmKeys = {'id', 'ids', 'node', 'nodes', 'patch', 'scope', 'roots', 'parent'};

  static bool _isOpName(String? v) => v != null && EditOp.isOpName(v);

  void _keyRead(_Frame f, String? key, List<StreamedOp> out) {
    if (f.role == _Role.candidate) {
      if (key == null || !_opKeys.contains(key)) f.role = _Role.plain;
      return;
    }
    // An op that begins inside an op (the previous one never closed).
    if (f.isObject && f.keys == 2 && f.maybeOp && _confirmKeys.contains(key) && _opAncestor(f) >= 0) {
      _resync(f, out);
    }
  }

  int _opAncestor(_Frame f) {
    final i = _stack.indexOf(f);
    for (var j = i - 1; j >= 0; j--) {
      if (_stack[j].role == _Role.op) return j;
    }
    return -1;
  }

  /// [f] is an op that began inside op A, which never closed: A is closed
  /// where [f] began (what arrived of it is read if it can be) and [f]
  /// becomes an op of its own.
  void _resync(_Frame f, List<StreamedOp> out) {
    final fi = _stack.indexOf(f);
    final ai = _opAncestor(f);
    final a = _stack[ai];
    final open = _stack.sublist(ai, fi);
    _repair(a.index, f.start, 'op ${a.index} was not closed before the next op began (closed it there)');
    final text = _cleanText(a.cleanStart, f.cleanStart);
    final json = _salvage(text, open);
    _stack.removeRange(ai, fi);
    if (json != null) {
      _opDone(a, json, out);
    } else {
      _diagnostics.add(EditDiagnostic.of(EditCodes.invalidJson, a.index,
          'Op ${a.index} was cut off by the next op and could not be read. Resend it.', path: '/ops/${a.index}'));
    }
    f
      ..role = _Role.op
      ..index = _opCount++
      ..opName = f.firstValue
      ..misplaced = false
      ..savedExpect = null
      ..opDepth = -1;
  }

  /// [text] (a prefix of a value whose open containers are [open], outermost
  /// first) closed and read, dropping an unfinished last member if needed.
  Object? _salvage(String text, List<_Frame> open) {
    var t = text.trimRight();
    for (var attempt = 0; attempt < 4; attempt++) {
      while (t.endsWith(',') || t.endsWith(':')) {
        t = t.substring(0, t.length - 1).trimRight();
      }
      final closers = [for (final f in open.reversed) f.isObject ? '}' : ']'].join();
      try {
        return jsonDecode('$t$closers');
      } catch (_) {
        // Drop the last token (a dangling key, a partial value) and retry.
        final cut = t.lastIndexOf(RegExp(r'[,{\[]'));
        if (cut <= 0) return null;
        t = t[cut] == ',' ? t.substring(0, cut) : t.substring(0, cut + 1);
      }
    }
    return null;
  }

  String? _decodeString(String raw) {
    try {
      final v = jsonDecode(raw);
      return v is String ? v : null;
    } catch (_) {
      return null;
    }
  }

  String _cleanText(int start, int end) => String.fromCharCodes(_clean, start, end);

  /// A scalar or string value [raw] completed inside [parent].
  void _valueDone(_Frame parent, String raw, bool isString, List<StreamedOp> out) {
    final key = parent.key;
    if (parent.isObject && key == 'op' && isString) {
      final name = _decodeString(raw)?.trim().toLowerCase();
      if (parent.keys == 1) parent.firstValue = name;
      switch (parent.role) {
        case _Role.op:
          parent.opName = name;
          if (EditOp.canonical(name) == SetOp.opName) _flushDeferred(parent, out);
        case _Role.candidate:
          if (_isOpName(name)) {
            parent
              ..role = _Role.op
              ..index = _opCount++
              ..opName = name;
          } else {
            parent.role = _Role.plain;
          }
        default:
          if (parent.keys == 1 && _isOpName(name)) parent.maybeOp = true;
      }
      return;
    }
    if (parent.isObject && (parent.role == _Role.plain || parent.role == _Role.candidate) && _stack.length == 1) {
      final v = _scalar(raw);
      if (key == 'baseRev') _baseRev = readInt(v);
      if (key == 'atomic') _atomic = readBool(v) ?? false;
    } else if (parent.role == _Role.ops) {
      // A scalar where an op should be.
      final f = _Frame(false, 0, 0, _Role.op)..index = _opCount++;
      _opDone(f, _scalar(raw) ?? raw, out);
    }
  }

  Object? _scalar(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  /// A node of a `nodes` map ([f], whose parent is the map's frame [nodes])
  /// completed.
  void _nodeDone(_Frame nodes, _Frame f, List<StreamedOp> out) {
    if (!partialSets) return;
    final key = nodes.key;
    final i = _stack.indexOf(nodes);
    final op = i >= 1 ? _stack[i - 1] : null;
    if (key == null || op == null || op.role != _Role.op) return;
    final node = readMap(_scalar(_cleanText(f.cleanStart, _clean.length)));
    if (node == null) return;
    if (op.opName == null) {
      op.deferred.add((key, node));
    } else if (EditOp.canonical(op.opName) == SetOp.opName) {
      op.yielded.add(key);
      _emit(op, StreamedOp(op.index, SetOp(key, node.containsKey('id') ? ({...node}..remove('id')) : node), partial: true, recovered: _isRecovered),
          out);
    }
  }

  bool get _isRecovered => _firstRepair != null;

  void _flushDeferred(_Frame op, List<StreamedOp> out) {
    for (final (key, node) in op.deferred) {
      op.yielded.add(key);
      _emit(op, StreamedOp(op.index, SetOp(key, node.containsKey('id') ? ({...node}..remove('id')) : node), partial: true, recovered: _isRecovered),
          out);
    }
    op.deferred.clear();
  }

  /// [s] (of op frame [op]) goes out now, or waits for the candidate around
  /// [op] to show whether it is an op itself.
  void _emit(_Frame op, StreamedOp s, List<StreamedOp> out) {
    for (var j = _stack.length - 1; j >= 0; j--) {
      final g = _stack[j];
      if (identical(g, op)) continue;
      if (g.role == _Role.candidate) {
        g.pending.add(s);
        return;
      }
    }
    out.add(s);
  }

  /// A candidate closed: an op without "op" (a node or nodes: a set), or not
  /// an op (what it held goes out).
  void _candidateDone(_Frame f, List<StreamedOp> out) {
    final m = readMap(_scalar(_cleanText(f.cleanStart, _clean.length)));
    if (m != null && !m.containsKey('op') && (m['node'] is Map || m['nodes'] is Map)) {
      f
        ..role = _Role.op
        ..index = _opCount++;
      _opDone(f, m, out);
      return;
    }
    for (final s in f.pending) {
      _emit(f, s, out);
    }
  }

  void _opDone(_Frame f, Object? parsed, List<StreamedOp> out) {
    if (f.index > _lastOp) _lastOp = f.index;
    Object? json = parsed;
    if (json == null) {
      final text = _cleanText(f.cleanStart, _clean.length);
      try {
        json = jsonDecode(text);
      } catch (e) {
        _diagnostics.add(EditDiagnostic.of(EditCodes.invalidJson, f.index, 'Op ${f.index} is not valid JSON: ${'$e'.split('\n').first}.',
            path: '/ops/${f.index}'));
        return;
      }
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
    final recovered = _isRecovered;
    if (recovered && decoded.ops.isNotEmpty) _recovered++;
    for (final (_, op) in decoded.ops) {
      // Nodes of a bulk set already yielded are not yielded again.
      if (op is SetOp && f.yielded.contains(op.id) && readMap(json)?['nodes'] != null) continue;
      _emit(f, StreamedOp(f.index, op, recovered: recovered), out);
    }
  }
}

enum _Role {
  /// The list of ops.
  ops,

  /// An op.
  op,

  /// An object outside any op that may be one (it has only op keys so far).
  candidate,

  /// A container outside any op that is not one (the input object).
  plain,

  /// A set's `nodes` map, and one node of it.
  nodes,
  node,

  /// Anything else inside an op.
  inner,
}

enum _Expect { key, colon, value, next }

class _Frame {
  _Frame(this.isObject, this.start, this.cleanStart, this.role) : expect = isObject ? _Expect.key : _Expect.value;
  final bool isObject;

  /// Where it began: in the raw input, and in the clean text.
  final int start;
  final int cleanStart;
  _Role role;
  _Expect expect;

  /// For an op: its index among the input's ops.
  int index = -1;

  /// The stack index of the op it is in (-1: none).
  int opDepth = -1;
  String? key;
  int keyCleanStart = -1;

  /// Keys read so far; the value of the first when it was "op".
  int keys = 0;
  String? firstValue;

  /// Its first key is "op" with an op's name (inside an op: an op that
  /// began before the previous one closed, once a second key confirms it).
  bool maybeOp = false;

  /// It began where its parent wanted a key.
  bool misplaced = false;
  _Expect? savedExpect;

  /// An op's `op`, once read.
  String? opName;

  /// Nodes of an op's `nodes` that completed before its `op` was read.
  final List<(String, Json)> deferred = [];
  final Set<String> yielded = {};

  /// Ops inside a candidate, until it shows whether it is an op itself.
  final List<StreamedOp> pending = [];
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
