// A node's states (what changes while it is hovered, pressed, focused,
// selected, disabled, dragged) in the notation's words, for printNodeLine
// (print_fields.dart): `hovered.fill=accentDeep pressed.opacity=0.82` on the
// node's own line, `btn.selected.color=primaryText` on the line of a node
// inside it that its state restyles (docs/design/22, "States: the form").
// Also its name (`name=Board`) and its behaviors that no other word says, by
// the keys' names (`inkWell.hoverColor=hoverOverlay`, `focusable=false`,
// `motion.rotate=90`).
//
// The words are chosen as a media rule's are (printPatchWords,
// print_media.dart): each patch worked out by the reader the parser uses
// (MediaLineReader) from the target's line printed without these words. A
// node whose states cannot all be said leaves all of them to its `{…}` tail.
import 'dart:convert';

import '../behavior_fields.dart' show BehaviorFields;
import '../json.dart';
import '../props.dart';
import 'media_words.dart';
import 'notation.dart';
import 'print_fields.dart';
import 'print_media.dart' show printPatchWords;

/// The node keys these words write: its states, its name, and every
/// behavior but the paint family's records (`customPaint`, `animations`,
/// `transitions`). The fields' own loop leaves them to them.
final Set<String> printStatesKeys = {
  'states',
  'name',
  for (final f in BehaviorFields.all)
    if (!const {'customPaint', 'animations', 'transitions'}.contains(f.key)) f.key,
};

/// Whether node [n]'s `selected` binding goes with state words of its own:
/// `selected={…}` on a box is then not its theme's selected fill but what its
/// words say (print_fields.dart writes the binding).
bool printStatesSelected(Json n) => readMap(readMap(n['states'])?['selected'])?.isNotEmpty ?? false;

/// The words for node [id]'s states, those of the states of the lines
/// around it that restyle it, its name and its behaviors, each written
/// after the line's fields; empty when there are none or no word says them
/// (they stay in the line's `{…}` tail).
List<String> printStates(String id, Json node, PrintContext context) {
  final plan = _plans[context] ??= _StatesPlan(context);
  if (plan.building > 0) return const [];
  return plan.wordsFor(id, node);
}

final _plans = Expando<_StatesPlan>();

// An id as the parser reads it after `#`: its parts may be joined by `-`.
final _ownerId = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(-[A-Za-z0-9_]+)*$');

/// The words of one print, worked out once per node.
final class _StatesPlan {
  _StatesPlan(this.c);

  final PrintContext c;

  /// While a line is printed without these words (to read it alone).
  int building = 0;

  final _words = <String, List<String>>{};
  final _owners = <String, Map<String, List<String>>?>{};
  final _readers = <String, MediaLineReader>{};
  final _alone = <String, Json?>{};

  late final Map<String, String> _parents = () {
    final out = <String, String>{};
    for (final e in c.nodes.entries) {
      final n = readMap(e.value);
      if (n == null) continue;
      for (final k in [...readStrings(n['children']), ...(readMap(n['slots']) ?? const {}).values.whereType<String>()]) {
        out[k] = e.key;
      }
    }
    return out;
  }();

  /// The owners of states that restyle each node (other than itself).
  late final Map<String, Set<String>> _restyledBy = () {
    final out = <String, Set<String>>{};
    for (final e in c.nodes.entries) {
      final states = readMap(readMap(e.value)?['states']);
      if (states == null) continue;
      for (final per in states.values) {
        for (final t in (readMap(per) ?? const {}).keys) {
          if (t != e.key) (out[t] ??= {}).add(e.key);
        }
      }
    }
    return out;
  }();

  String _type(String? id) => id == null ? '' : '${readMap(c.nodes[id])?['type']}';

  List<String> wordsFor(String id, Json node) => _words[id] ??= [
        ..._behaviors(id, node),
        ...?_owner(id)?[id],
        for (final o in _ancestors(id))
          if (_restyledBy[id]?.contains(o) ?? false) ...?_owner(o)?[id],
      ];

  Iterable<String> _ancestors(String id) sync* {
    for (var at = _parents[id]; at != null; at = _parents[at]) {
      yield at;
    }
  }

  /// Node [id]'s line printed without these words.
  String _bare(String id, Json node) {
    building++;
    try {
      return printNodeLine(id, node, c);
    } finally {
      building--;
    }
  }

  NotationResult _parse(String text) => parseNotation(text, catalog: c.catalog, options: c.options);

  /// The reader of node [id]'s line, for a patch of the fields [keys] allows
  /// (a state's, unless given).
  MediaLineReader _reader(String id, {bool Function(String)? keys, String tag = ''}) => _readers['$tag$id'] ??= () {
        final n = readMap(c.nodes[id]) ?? const {};
        return MediaLineReader(
          _parse,
          line: _bare(id, n),
          parentType: _type(_parents[id]),
          props: c.catalog.widget('${n['type']}')?.props ?? const <PropDef<Object?>>[],
          bound: readMap(n['bind'])?.keys ?? const [],
          keys: keys ?? notationStatePatchKey,
          rule: 'A state',
          dropBindings: false,
        );
      }();

  /// Node [id]'s line printed without these words, read alone.
  Json? _aloneNode(String id) => _alone.putIfAbsent(id, () {
        final n = readMap(c.nodes[id]);
        if (n == null) return null;
        return mediaLineNode(_parse(mediaLineText(_type(_parents[id]), _bare(id, n))).document);
      });

  // --- states ----------------------------------------------------------------

  /// The words of owner [o]'s states, by the node whose line they go on;
  /// null when it has none or one of them has no words.
  Map<String, List<String>>? _owner(String o) {
    if (_owners.containsKey(o)) return _owners[o];
    _owners[o] = null;
    return _owners[o] = _ownerWords(o);
  }

  Map<String, List<String>>? _ownerWords(String o) {
    final states = readMap(readMap(c.nodes[o])?['states']);
    if (states == null || states.isEmpty) return null;
    final alone = _aloneNode(o);
    if (alone == null) return null;
    // What the line's words give already (`selected={…}` on a box: the
    // theme's selected fill).
    final given = readMap(alone['states']) ?? const {};
    if (given.keys.any((s) => !states.containsKey(s))) return null;
    final out = <String, List<String>>{};
    for (final e in states.entries) {
      final state = e.key;
      final per = readMap(e.value);
      if (per == null || !notationStateNames.contains(state)) return null;
      if (jsonEquality.equals(per, given[state])) continue;
      for (final t in per.entries) {
        final target = t.key, patch = readMap(t.value);
        if (patch == null || patch.isEmpty || readMap(c.nodes[target]) == null) return null;
        // Written on the target's line after the owner's id: the target is
        // inside it, and the id is no media rule's condition.
        if (target != o && (!_ancestors(target).contains(o) || !_ownerId.hasMatch(o) || mediaCondition('$o.x') != null)) return null;
        final type = _type(target);
        final words = printPatchWords(patch, _reader(target), type);
        if (words == null) return null;
        final prefix = target == o ? '$state.' : '$o.$state.';
        // Each word reads as this state's on that line.
        for (final w in words) {
          if (notationStateKey('$prefix$w'.split('=').first, type, c.catalog) == null) return null;
        }
        (out[target] ??= []).addAll([for (final w in words) '$prefix$w']);
      }
    }
    return out;
  }

  // --- the name and the behaviors ---------------------------------------------

  /// Words for node [id]'s name and the behaviors its line does not say.
  List<String> _behaviors(String id, Json node) {
    if (!node.keys.any((k) => k != 'states' && printStatesKeys.contains(k))) return const [];
    final alone = _aloneNode(id);
    if (alone == null) return const [];
    bool keys(String k) => k != 'states' && printStatesKeys.contains(k);
    final changed = {...alone};
    for (final k in printStatesKeys) {
      if (!keys(k)) continue;
      if (node.containsKey(k)) {
        changed[k] = node[k];
      } else {
        changed.remove(k);
      }
    }
    final type = '${node['type']}';
    final props = c.catalog.widget(type)?.props ?? const <PropDef<Object?>>[];
    final patch = mediaPatchBetween(alone, changed, props, keys: keys);
    if (patch == null) return const [];
    final reader = _reader(id, keys: keys, tag: 'behaviors:');
    final out = <String>[];
    for (final e in patch.entries) {
      final words = e.key == 'name'
          ? _nameWords(e.value, reader, props)
          : printPatchWords({e.key: e.value}, reader, type) ?? _drag(e.key, node[e.key], reader, type) ?? _whole(e.key, node[e.key], reader) ?? _some(e.key, e.value, reader, type);
      if (words != null) out.addAll(words);
    }
    // A field the line also binds (`radioGroup.groupValue={budget}`): its value
    // by its full path from the node, a key written once (design 22, 4.8).
    final bound = readMap(node['bind'])?.keys.toSet() ?? const <String>{};
    return [
      for (final w in out)
        switch (w.indexOf('=')) {
          final at when at > 0 && bound.contains(w.substring(0, at)) && !w.substring(at + 1).startsWith('{') => 'node.$w',
          _ => w,
        },
    ];
  }

  /// `name=Board`, `name="Search results"`; `node.name=` where the type has
  /// a prop of that name.
  List<String>? _nameWords(Object? v, MediaLineReader reader, List<PropDef<Object?>> props) {
    if (v is! String) return null;
    final key = props.any((p) => p.key == 'name') ? 'node.name' : 'name';
    for (final w in [
      if (RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(v) && !const {'true', 'false', 'null'}.contains(v)) v,
      jsonEncode(v),
    ]) {
      if (jsonEquality.equals(reader.patch(['$key=$w']).patch, {'name': v})) return ['$key=$w'];
    }
    return null;
  }

  /// A drag source whose data is worked out (`"${item.id}"`, which a key's
  /// value would read as a binding of it): `drag=card(item.id)`, its other
  /// fields by their names after it (`draggable.start=auto`).
  List<String>? _drag(String key, Object? v, MediaLineReader reader, String type) {
    if (key != 'draggable' || v is! Map || v['group'] is! String || !_ownerId.hasMatch('${v['group']}')) return null;
    final data = v['data'];
    final m = data is String ? RegExp(r'^\$\{([A-Za-z_][A-Za-z0-9_.]*)\}$').firstMatch(data) : null;
    if (data != null && m == null) return null;
    final lead = 'drag=${v['group']}${m == null ? '' : '(${m[1]})'}';
    final rest = <String, Object?>{
      for (final e in v.entries)
        if (e.key != 'group' && e.key != 'data') '${e.key}': e.value,
    };
    final after = MediaLineReader(reader.parse,
        line: '${reader.line} $lead', parentType: reader.parentType, props: reader.props, bound: reader.bound, keys: reader.keys, rule: reader.rule, dropBindings: false);
    final more = rest.isEmpty ? const <String>[] : printPatchWords({key: rest}, after, type);
    if (more == null) return null;
    final words = [lead, ...more];
    final got = reader.patch(words).patch;
    return got != null && jsonEquality.equals(got[key], v) ? words : null;
  }

  /// The fields of a record that have words, when not all of them do (a
  /// drop target's `accepts`, not its worked-out `key`): the rest stays in
  /// the line's `{…}` tail.
  List<String>? _some(String key, Object? v, MediaLineReader reader, String type) {
    if (v is! Map) return null;
    final out = <String>[];
    for (final e in v.entries) {
      final words = printPatchWords({
        key: {'${e.key}': e.value},
      }, reader, type);
      if (words != null) out.addAll(words);
    }
    return out.isEmpty ? null : out;
  }

  /// A record whole, as its JSON (`inkWell={…}`), when no word of each of
  /// its fields says it.
  List<String>? _whole(String key, Object? v, MediaLineReader reader) {
    if (v == null) return null;
    final w = '$key=${jsonEncode(v)}';
    if (w.contains(r'${')) return null;
    final got = reader.patch([w]).patch;
    return got != null && jsonEquality.equals(got[key], v) ? [w] : null;
  }
}
