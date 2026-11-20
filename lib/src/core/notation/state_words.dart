// A node's states in the notation's words (docs/design/22, "States: the
// form"): what changes while it is hovered, pressed, focused, selected,
// disabled or dragged, written as the media rules are, with the state's name
// as the condition:
//
//   Row#btn gap=8 fill=accent selected={tab == 'a'} hovered.fill=accentDeep pressed.opacity=0.82
//     Icon#glyph "star" btn.selected.color=primaryText
//     Text#label "Save" btn.selected.color=primaryText btn.selected.weight=600
//
// `state.key=value` on a line is that line's node's own state; a descendant
// a state of a line around it restyles writes the word on its own line, after
// that line's id (`btn.selected.color=…`): the patch is read into the
// owner's `states` under the descendant's id. A state's patch is what its
// words change on the line, worked out by the media rules' reader
// (MediaLineReader, media_words.dart): the line read alone with and without
// them. The state names are the API's (`WidgetState`), read at run time.
part of 'notation.dart';

/// A state word as written: the line it is of ([owner]: null for the line's
/// own node), the state, the word after them and where it is.
typedef _StateWord = ({String? owner, String state, String word, int column});

/// The state names a word may start with: `WidgetState`'s.
final Set<String> notationStateNames = {for (final s in WidgetState.values) s.name};

/// The node keys a state's patch may hold: any field of the node, not the
/// tree, its events, its media rules or another state.
bool notationStatePatchKey(String key) =>
    !const {'type', 'id', 'name', 'key', 'children', 'slots', 'states', 'media', 'actions', 'component'}.contains(key);

// An id as the parser reads it after `#` (design 13, section 3): `m-nav` in
// `m-nav.selected.color=…` is the owner's id whole.
final _ownerId = RegExp('^$notationId\$');

/// The states whose patch of the node itself the parser gave as a default
/// (`selected={…}` on a box: the theme's selected fill; `enabled={…}` on a
/// box: half strength), by node: written words replace it.
final _stateDefaults = Expando<Map<String, Set<String>>>();

/// The state names a document's lines use that a variable of it has too,
/// said once each (by the page's parser, `_top`).
final _stateNamesSaid = Expando<Set<String>>();

/// Where a word of [key] (the part before `=`) on a line of [type] is a state
/// word: its owner (null: the line's own node), its state and the length of
/// that prefix with its dot. Null for a key of the type itself (a path the
/// keys read, `states.hovered.btn.opacity`) or a media rule's.
({String? owner, String state, int length})? notationStateKey(String key, String type, Catalog catalog) {
  final parts = key.split('.');
  if (parts.length < 2 || parts.any((p) => p.isEmpty)) return null;
  if (mediaCondition(key) != null || notationKeyPath(key, type, catalog: catalog) != null) return null;
  if (notationStateNames.contains(parts[0])) return (owner: null, state: parts[0], length: parts[0].length + 1);
  if (parts.length >= 3 && notationStateNames.contains(parts[1]) && _ownerId.hasMatch(parts[0])) {
    return (owner: parts[0], state: parts[1], length: parts[0].length + parts[1].length + 2);
  }
  return null;
}

extension _StateWords on _Parser {
  /// Reads the state word [word] at [from] of the line ([t] is past its
  /// key), with its value; false when [word] is none.
  bool _stateWord(_Tokens t, String word, int from, String type, int column, List<_StateWord> words) {
    final eq = word.indexOf('=');
    final key = notationStateKey(eq < 0 ? word : word.substring(0, eq), type, catalog);
    if (key == null) return false;
    if (eq == word.length - 1 && t.peek == '"') t.string();
    if (eq == word.length - 1 && (t.peek == '{' || t.peek == '[')) t.balanced();
    final rest = t.s.substring(from + key.length, t.at);
    if (_mediaLine) {
      // Read alone for a rule's or a state's patch: the line's own states
      // are not read again (said the same with and without the words, so
      // said only where a media rule holds one).
      _issue(column, "A media rule holds the line's own keys, not a state: write $word on its own.");
      return true;
    }
    if (mediaCondition(rest.split('=').first) != null || notationStateKey(rest.split('=').first, type, catalog) != null) {
      _issue(column, "A state holds the line's own keys, not a media rule or another state: $word.");
      return true;
    }
    // A variable of the state's name (`state pressed=…`, the site's
    // `pressed`): on a line `pressed.fill=…` is the node's pressed look,
    // never the variable (notationStateKey reads no variable), while a
    // formula's `pressed.mine` is the variable. Said once a document.
    if (key.owner == null && (variables.containsKey(key.state) || _derived.containsKey(key.state)) && (_stateNamesSaid[_top] ??= <String>{}).add(key.state)) {
      _issue(column,
          '$word: ${key.state} is also a variable here, and on a line ${key.state}.… is always the node\'s ${key.state} look, never the variable '
          '(a formula\'s {${key.state}} or {${key.state}.x} reads the variable). Name the variable otherwise (${key.state}Item) so the two do not read alike.');
    }
    words.add((owner: key.owner, state: key.state, word: rest, column: column));
    return true;
  }

  /// `name=Board` (`node.name=` where the type has a prop of that name): the
  /// node's name, a text. True when [word] was that.
  bool _nameWord(_Tokens t, String word, int from, WidgetSpec spec, Json node, int column) {
    final eq = word.indexOf('=');
    if (eq < 0) return false;
    final key = word.substring(0, eq);
    if (key != 'node.name' && (key != 'name' || spec.props.any((p) => p.key == 'name'))) return false;
    if (eq == word.length - 1 && t.peek == '"') t.string();
    if (eq == word.length - 1 && (t.peek == '{' || t.peek == '[')) t.balanced();
    final raw = t.s.substring(from + eq + 1, t.at);
    final lit = _literal(raw);
    final v = lit.$1 ? lit.$2 : (RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(raw) ? raw : null);
    if (v is String) {
      node['name'] = v;
    } else {
      _issue(column, "A node's name is a text: $key=\"…\".");
    }
    return true;
  }

  /// Reads line [id]'s state words into the states of the nodes they are of
  /// (its own [out], or a line's around it), after the defaults its other
  /// words gave. [base] is the line's words (its state words are not read
  /// again when it is read alone), [parentId] and [parentType] the line
  /// around it, [tail] the node's fields its `{…}` tail gave.
  void _readStates(List<_StateWord> words, String base, String id, String? parentId, String? parentType, String type, Json out, Json tail) {
    // What the defaults gave this node's own states (not its tail).
    final defaults = (_stateDefaults[this] ??= <String, Set<String>>{});
    final own = readMap(out['states']) ?? const {};
    final given = readMap(tail['states']) ?? const {};
    defaults[id] = {
      for (final s in own.keys)
        if (readMap(own[s])?[id] != null && !jsonEquality.equals(readMap(own[s])?[id], readMap(given[s])?[id])) s,
    };
    if (words.isEmpty) return;
    final props = catalog.widget(type)?.props ?? const <PropDef<Object?>>[];
    final reader = MediaLineReader(
      (text) => (_Parser(catalog, options._copy(reflow: false, openVocabulary: options.openVocabulary, vocabulary: options.vocabulary)).._mediaLine = true).parse(text),
      line: base,
      parentType: parentType,
      props: props,
      bound: readMap(out['bind'])?.keys ?? const [],
      keys: notationStatePatchKey,
      rule: 'A state',
      dropBindings: false,
    );
    // The words of one owner and state are one patch, wherever they are on
    // the line.
    final groups = <(String, String), List<_StateWord>>{};
    for (final w in words) {
      (groups[(w.owner ?? id, w.state)] ??= []).add(w);
    }
    for (final g in groups.entries) {
      final (owner, state) = g.key;
      final column = g.value.first.column;
      var at = owner == id ? id : parentId;
      while (at != null && at != owner) {
        at = _parentOf[at];
      }
      if (at == null) {
        _issue(column, "$owner.$state: there is no line $owner around this one. A state is of the line's own node ($state.…) or of a line around it, by its id.");
        continue;
      }
      final read = reader.patch([for (final w in g.value) w.word]);
      for (final m in read.issues) {
        _issue(column, m);
      }
      final patch = read.patch;
      if (patch == null) continue;
      final holder = owner == id ? out : nodes[owner];
      if (holder == null) continue;
      final states = {...?readMap(holder['states'])};
      // Its look written: the default the parser gave it goes.
      if (defaults[owner]?.remove(state) ?? false) {
        final per = {...?readMap(states[state])}..remove(owner);
        if (per.isEmpty) {
          states.remove(state);
        } else {
          states[state] = per;
        }
      }
      final per = {...?readMap(states[state])};
      final had = readMap(per[id]);
      per[id] = had == null ? patch : mergePatch(had, patch, keepNulls: true);
      states[state] = per;
      holder['states'] = states;
      // A line around this one was sent already: what its state now holds
      // for this line is sent to it as it is read.
      if (owner != id && _canvas) {
        ops.add({
          'op': 'patch',
          'id': owner,
          'patch': {
            'states': {
              state: {id: per[id]},
            },
          },
        });
      }
    }
  }
}
