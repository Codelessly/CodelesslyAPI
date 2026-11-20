// Events and actions in the notation (docs/design/22-notation-parity.md
// sections 2.2 and 2.3): `on<Trigger>(field=value, …)={actions}` for every
// trigger type of the catalog, and every action type of the catalog by its
// type name and its fields (`animate node=hero preset=fadeIn`), beside the
// verbs the notation has (`toast`, `go`, `open`…), which _Parser._actions reads.
part of 'notation.dart';

/// The event name the notation has for a trigger type, where it is not `on`
/// and the type's name with a capital (`click` is `onTap`). Every other
/// trigger of the catalog is written under its own name: `onEnterViewport`,
/// `onKeyDown`, `onDragEnd`. `hover` (the pointer moving over a node) is
/// `onHoverMove`, since `onHover` was the pointer coming over it
/// (`cursorEnter`) before the catalog's names were read.
const Map<String, String> notationEventNames = {
  'click': 'onTap',
  'changed': 'onChange',
  'secondaryClick': 'onRightClick',
  'cursorEnter': 'onHover',
  'hover': 'onHoverMove',
  'focusGained': 'onFocus',
  'focusLost': 'onBlur',
  'submitted': 'onSubmit',
};

/// Names read for a trigger that the notation does not write (what models
/// and other frameworks call them).
const Map<String, String> _eventAliases = {
  'onPress': 'click',
  'onPressed': 'click',
  'onContextMenu': 'secondaryClick',
};

/// The names of one event a block may have under another name (design 13
/// section 3): `onTap` on a block whose event is `onPressed` is that event,
/// `onSubmit` one whose event is `onSubmitted`. A name a block has no event
/// of in its family is the catalog's trigger on the line's node (`onTap` on
/// a card whose one event is `onMenu` is a press on the whole card, not its
/// menu).
const List<Set<String>> _blockEventFamilies = [
  {'onTap', 'onPress', 'onPressed', 'onClick'},
  {'onChange', 'onChanged'},
  {'onSubmit', 'onSubmitted'},
  {'onRightClick', 'onSecondaryClick', 'onContextMenu'},
];

/// The event of [events] (a block's, in order) that [key] names: its own
/// name, else the first of its family ([_blockEventFamilies]); null when
/// none.
String? blockEventFor(String key, Iterable<String> events) {
  if (events.contains(key)) return key;
  final family = _blockEventFamilies.where((f) => f.contains(key)).firstOrNull;
  return family == null ? null : events.where(family.contains).firstOrNull;
}

String _capital(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// The event the notation writes for trigger type [trigger] (`onTap` for
/// `click`, `onEnterViewport` for `enterViewport`).
String notationEventName(String trigger) => notationEventNames[trigger] ?? 'on${_capital(trigger)}';

/// The trigger types an event is written for on a node: every one of the
/// catalog's but `event`, a design system block's own (written by its name).
Iterable<String> get _eventTriggers => TriggerType.values.where((t) => t != TriggerType.event).map((t) => t.name);

/// The trigger type event [key] names (`onTap` → `click`, `onScroll` →
/// `scroll`, `onClick` → `click`), or null when it names none.
String? notationEventTrigger(String key) {
  for (final e in notationEventNames.entries) {
    if (e.value == key) return e.key;
  }
  if (_eventAliases[key] case final String t) return t;
  for (final t in _eventTriggers) {
    if ('on${_capital(t)}' == key) return t;
  }
  return null;
}

extension _Events on _Parser {
  /// What is said of event [key] that a line of [written] does not have:
  /// the events, and the nearest name.
  static String noEvent(String written, String key, WidgetSpec? component) {
    final names = [...?component?.events.map((e) => e.key), for (final t in _eventTriggers) notationEventName(t)];
    return 'A $written has no event "$key". Events: onTap, onChange (a control), onLongPress, onDoubleTap, onRightClick, onSwipeLeft (Right, Up, Down), '
        'onHover, onFocus, onBlur, onSubmit, onDrop, and every other trigger by its name (onScroll, onEnterViewport, onKeyDown(key=Enter))'
        '${switch (didYouMean(key, names)) { final String n => '. Did you mean "$n"?', _ => '.' }}';
  }

  /// `onKeyDown(key=Enter, repeat=true)=` at [at] of [s]: the event's name,
  /// its fields as written and where its value starts (after the `=`). Null
  /// when no event with fields starts there.
  static (String, String, int)? withFields(String s, int at) {
    final m = RegExp(r'on[A-Z][A-Za-z]*\(').matchAsPrefix(s, at);
    if (m == null) return null;
    final close = _Parser._closing(s, m.end - 1);
    if (close < 0 || close + 1 >= s.length || s[close + 1] != '=') return null;
    return (s.substring(at, m.end - 1), s.substring(m.end, close), close + 2);
  }

  /// `on load={…}`, `on backPressed(when={editing})={…}`: a reaction of the
  /// screen itself to a trigger that is no timer (`every`) and no shortcut
  /// (`key`), on a line of its own as those are: `on`, the trigger's catalog
  /// name, its fields in parentheses as after an event, and its actions in
  /// braces. Whether [line] is one (said, when it is one written wrong).
  bool canvasEventLine(String line, int column) {
    final head = RegExp(r'^on\s+([A-Za-z]+)').firstMatch(line);
    if (head == null) return false;
    final name = head[1]!;
    const usage = 'A reaction of the screen is a line of its own: on load={…} (the trigger\x27s name, its fields in parentheses: on backPressed(when={editing})={…}).';
    if (!TriggerType.values.any((t) => t.name == name && t != TriggerType.event)) {
      final names = [for (final t in TriggerType.values) if (t != TriggerType.event) t.name];
      _issue(column, 'The screen has no trigger "$name"${_nearest(name, names)} Its triggers: ${names.join(', ')}.');
      return true;
    }
    final trigger = <String, Object?>{'type': name};
    var at = head.end;
    if (at < line.length && line[at] == '(') {
      final close = _Parser._closing(line, at);
      if (close < 0) {
        _issue(column, usage);
        return true;
      }
      triggerFields(trigger, line.substring(at + 1, close), column);
      at = close + 1;
    }
    final body = RegExp(r'^=\{(.*)\}\s*$').firstMatch(line.substring(at));
    if (body == null) {
      _issue(column, usage);
      return true;
    }
    _timers.add({'trigger': trigger, 'actions': _actions(body[1]!.trim(), column)});
    if (_canvas) _patches.add({'op': 'patch', 'id': options.screen, 'patch': {'actions': [..._timers]}});
    return true;
  }

  /// The trigger fields written in an event's parentheses, set on
  /// [trigger]; a field the trigger does not have is said.
  void triggerFields(Json trigger, String written, int column) {
    final known = [for (final f in TriggerFields.all) if (f.key != 'type') f.key];
    for (final (key, raw) in _pairs(written, column, 'A trigger\x27s fields are written by name in its parentheses: onKeyDown(key=Enter, repeat=true)={…}.', commas: true)) {
      if (!known.contains(key)) {
        _issue(column, 'A trigger has no field "$key"${_nearest(key, known)} Its fields: ${known.join(', ')}.');
        continue;
      }
      trigger[key] = _fieldValue(raw, column);
      _literalOnly(TriggerFields.all, key, trigger[key], "A trigger's", column);
    }
  }

  /// [a] as an action of the catalog written by its type name and its fields
  /// (`animate node=hero preset=fadeIn durationMs=300`, `retryFailed`). Null
  /// when [a] does not start with an action type, or starts with a verb of
  /// the notation that is one too (`focus search`, `announce "Saved"`) and
  /// no field follows.
  Json? typedAction(String a, int column) {
    final name = RegExp(r'^[a-z][A-Za-z0-9]*(?=\s|$)').stringMatch(a);
    if (name == null) return null;
    final spec = catalog.action(name);
    if (spec == null) return null;
    final rest = a.substring(name.length).trim();
    final named = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)=(?!=)').firstMatch(rest);
    if (rest.isNotEmpty && named == null) return null;
    if ((_Parser._verbs.contains(name) || name == 'confirm') && (named == null || _actionFields(spec).every((f) => f != named[1]))) return null;
    // `confirm title=… message=… then {…}`: the verb with the action's field
    // names, read by the verb (its then and else), not as the action's fields.
    if (name == 'confirm' && !RegExp(r'(^|\s)actions=').hasMatch(rest) && RegExp(r'\sthen(\s|\{|$)').hasMatch(rest)) return null;
    final out = <String, Object?>{'type': spec.type};
    final fields = _actionFields(spec);
    final usage = 'An action is its type and its fields by name: ${_example(spec)}.';
    for (final (key, raw) in _pairs(rest, column, usage)) {
      if (!fields.contains(key)) {
        _issue(column, 'A ${spec.type} action has no field "$key"${_nearest(key, fields)} Its fields: ${fields.join(', ')}.');
        continue;
      }
      out[key] = _fieldValue(raw, column, chain: spec.nested.contains(key));
      // A predicate field (an `if`'s condition, any action's `when`) given
      // a value worked out (`condition={a || b}`) holds when that value is
      // true. It was written as the bare text of the formula, which reads
      // as no predicate: the `else` ran, with no word said (5 NOCD parts).
      if (_predicateFields.contains(key) && (out[key] is String || out[key] is bool)) {
        final v = out[key];
        out[key] = {'left': v is bool ? '\${= $v}' : v, 'op': 'isTrue'};
      }
      // (After the predicate is made a record: a condition worked out is
      // read, never said.)
      _literalOnly([...spec.fields, ...ActionCommonFields.all], key, out[key], 'A ${spec.type} action\x27s', column);
    }
    // `stopVariable=name`: the stops are shares (0.5), which a whole-number
    // variable would round away.
    if (out['stopVariable'] case final String name when out['snapHeights'] is List && RegExp(r"^[A-Za-z_][A-Za-z0-9_]*$").hasMatch(name)) _widen(name, null);
    // A sheet with stops always draws its grip, the handle its stops are
    // dragged between: `showDragHandle=false` beside them is not read.
    if (out['showDragHandle'] == false && out['snapHeights'] is List && (out['snapHeights']! as List).isNotEmpty) {
      _issue(column, 'A sheet with snapHeights always draws its drag handle (it is what moves the sheet between its stops), so showDragHandle=false is not read beside them. For a sheet without a grip, leave out snapHeights and give it one height (maxHeightFactor=…).');
    }
    _top._actionLines[out] = _line;
    return out;
  }

  /// The action fields that hold a predicate (`ActionIfFields.condition`,
  /// `ActionCommonFields.when`): `{"left": …, "op": …}` or a junction.
  static const _predicateFields = {'condition', 'when'};

  /// Says a value worked out (`${…}`) given to a field that holds only a
  /// value written out (a number, true or false, one of its words): it is
  /// read once, as the document loads, and the `${…}` would be dropped for
  /// the field's default. Names the fields of [fields] that do take one.
  void _literalOnly(List<PropDef<Object?>> fields, String key, Object? value, String whose, int column) {
    if (value is! String || !value.contains(r'${')) return;
    final f = fields.where((f) => f.key == key).firstOrNull;
    if (f == null) return;
    final c = f.codec;
    if (c is! IntCodec && c is! DoubleCodec && c is! BoolCodec && c is! OptionalIntCodec && c is! OptionalDoubleCodec && c is! OptionalBoolCodec && c is! EnumCodec && c is! OptionalEnumCodec) return;
    final worked = [
      for (final g in fields)
        if (g.key != key && (g.codec is ExprCodec || (g.codec is StringCodec && RegExp(r'formula|expression', caseSensitive: false).hasMatch(g.doc)))) g.key,
      // `enabled={…}`: whether the action runs is its `when`.
      if (identical(f, ActionCommonFields.enabled)) 'when',
    ];
    _issue(column,
        '$whose $key is a value written out (${c is BoolCodec || c is OptionalBoolCodec ? 'true or false' : c is EnumCodec || c is OptionalEnumCodec ? 'one of its words' : 'a number'}); it does not read a value worked out, so $value would be dropped for its default. '
        '${worked.isEmpty ? 'Write the value itself.' : 'A value worked out goes in ${worked.map((k) => '$k={…}').join(' or ')}.'}');
  }

  /// Whether [a] starts with an action type's name and a field of it (not a
  /// choice to read as `cond ? a : b`).
  bool startsTyped(String a) {
    final m = RegExp(r'^([a-z][A-Za-z0-9]*)\s+([A-Za-z_][A-Za-z0-9_]*)=(?!=)').firstMatch(a);
    final spec = m == null ? null : catalog.action(m[1]!);
    return spec != null && _actionFields(spec).contains(m![2]);
  }

  /// The fields an action of [spec] is written with: its own, then the ones
  /// every action has.
  List<String> _actionFields(ActionSpec spec) => [for (final f in spec.fields) f.key, for (final f in ActionCommonFields.all) f.key];

  String _example(ActionSpec spec) => [
        spec.type,
        for (final f in spec.fields.take(2)) '${f.key}=…',
      ].join(' ');

  String _nearest(String word, Iterable<String> names) => switch (didYouMean(word, names)) {
        final String n => '. Did you mean "$n"?',
        _ => '.',
      };

  /// The `key=value` pairs of [text], each value as written: a number, a bare
  /// word, a quoted string, braces or brackets. Separated by spaces (and
  /// [commas] in a trigger's parentheses). What is not a pair is said with
  /// [usage] and the rest skipped.
  List<(String, String)> _pairs(String text, int column, String usage, {bool commas = false}) {
    final out = <(String, String)>[];
    final t = _Tokens(text);
    while (true) {
      while (!t.done && (t.peek == ' ' || commas && t.peek == ',')) {
        t.at++;
      }
      if (t.done) break;
      final key = RegExp(r'([A-Za-z_][A-Za-z0-9_]*)=').matchAsPrefix(text, t.at);
      if (key == null) {
        _issue(column, usage);
        break;
      }
      t.at = key.end;
      final start = t.at;
      if (t.peek == '"') {
        t.string();
      } else if (t.peek == '{' || t.peek == '[') {
        t.balanced();
      } else {
        while (!t.done && t.peek != ' ' && !(commas && t.peek == ',')) {
          t.at++;
        }
      }
      out.add((key[1]!, text.substring(start, t.at > text.length ? text.length : t.at)));
    }
    return out;
  }

  /// A field's value as written: a number, `true`, `false`, `null`; a bare
  /// word (that word); a quoted string, whose `{name}` reads a value; braces,
  /// a value worked out (`{count + 1}`) or, holding a key first, JSON
  /// (`{"left": …}`); brackets, JSON for a list. A field that holds actions
  /// ([chain]: `then`, `onError`) takes them in braces (`then={a=1; close}`).
  Object? _fieldValue(String raw, int column, {bool chain = false}) {
    if (chain && raw.startsWith('{') && !raw.startsWith('{"')) {
      return _actions(raw.substring(1, raw.endsWith('}') ? raw.length - 1 : raw.length), column);
    }
    if (raw.startsWith('"')) {
      // `${…}` written in it stays as written, as in a paint op's value
      // (design 22, 4.6): `when="${= ready}"`, a formula that is only a name.
      final s = _Tokens(raw).string();
      return s.contains(r'${') ? s : _interpolate(s);
    }
    if (raw.startsWith('{') && _Parser._bracedExpression(raw)) return _read(raw.substring(1, raw.length - 1));
    if (raw.startsWith('{') || raw.startsWith('[')) {
      try {
        return jsonDecode(raw);
      } catch (_) {
        _issue(column, 'Not valid JSON: $raw (a value worked out is written in braces: field={a + b}).');
        return null;
      }
    }
    final literal = _literal(raw);
    return literal.$1 ? literal.$2 : raw;
  }
}
