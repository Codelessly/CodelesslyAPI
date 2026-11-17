// A node's media rules (what changes at other widths) in the notation's words, for
// printNodeLine (print_fields.dart): `hide=phone`, and `phone.pad=16
// tablet.direction=vertical max899.visible={menuOpen}` (docs/design/22
// section 2.4, "Media rules: the form").
//
// Each rule's words are chosen by working the rule out as the parser does
// (MediaLineReader, media_words.dart) from the line printed without them:
// for each field of its patch, the first word that gives that field and
// nothing the patch does not have. A rule no words give exactly leaves all
// of the node's rules to its `{…}` tail.
import 'dart:convert';

import '../json.dart';
import '../media.dart' show MediaRule;
import '../props.dart';
import 'media_words.dart';
import 'notation.dart';
import 'print_fields.dart';

/// The words for node [id]'s media rules, each written after the line's fields;
/// empty when it has none or the notation has no word for them (they stay
/// in the line's `{…}` tail).
List<String> printMedia(String id, Json node, PrintContext context) {
  final rules = readList(node['media']);
  if (rules == null || rules.isEmpty) return const [];
  final type = '${node['type']}';
  final props = context.catalog.widget(type)?.props ?? const <PropDef<Object?>>[];
  final parents = _parents[context.document] ??= _parentTypes(context.nodes);
  final reader = MediaLineReader(
    (text) => parseNotation(text, catalog: context.catalog, options: context.options),
    line: printNodeLine(id, {...node}..remove('media'), context),
    parentType: parents[id],
    props: props,
    bound: readMap(node['bind'])?.keys ?? const [],
  );
  final out = <String>[];
  String? last;
  for (final r in rules) {
    final rule = readMap(r);
    if (rule == null) return const [];
    final hide = mediaHideWords.entries.where((e) => jsonEquality.equals(rule, {...e.value, 'patch': mediaHidden})).firstOrNull;
    if (hide != null) {
      out.add(hide.key);
      last = null;
      continue;
    }
    final condition = mediaConditionWords(rule);
    // Two rules in a row with one condition would read as one.
    if (condition == null || condition == last) return const [];
    final words = _patchWords(readMap(rule['patch']) ?? const {}, reader, type);
    if (words == null) return const [];
    out.addAll([for (final w in words) '$condition.$w']);
    last = condition;
  }
  return out;
}

final _parents = Expando<Map<String, String>>();

Map<String, String> _parentTypes(Json nodes) => {
      for (final e in nodes.entries)
        if (readMap(e.value) case final Json n)
          for (final c in [...readStrings(n['children']), ...(readMap(n['slots']) ?? const {}).values.whereType<String>()]) c: '${n['type']}',
    };

/// Words that give [patch] on the line [reader] reads, or null.
List<String>? _patchWords(Json patch, MediaLineReader reader, String type) {
  if (patch.isEmpty) return null;
  final want = _flat(patch);
  final chosen = <String>[];
  for (final leaf in _leaves(patch)) {
    final mine = _flat({leaf.path.first: _nest(leaf.path.skip(1).toList(), leaf.value)});
    // Given already by a word chosen for another field (`center` sets both axes).
    final now = chosen.isEmpty ? const <String, Object?>{} : _flat(reader.patch(chosen).patch ?? const {});
    if (mine.entries.every((e) => now.containsKey(e.key) && jsonEquality.equals(now[e.key], e.value))) continue;
    String? found;
    for (final c in _candidates(leaf.path, leaf.value, type)) {
      final got = reader.patch([...chosen, c]).patch;
      if (got == null) continue;
      final flat = _flat(got);
      if (flat.entries.every((e) => want.containsKey(e.key) && jsonEquality.equals(want[e.key], e.value)) && mine.keys.every(flat.containsKey)) {
        found = c;
        break;
      }
    }
    if (found == null) return null;
    chosen.add(found);
  }
  return jsonEquality.equals(reader.patch(chosen).patch, patch) ? chosen : null;
}

Object? _nest(List<String> path, Object? v) => path.isEmpty ? v : {path.first: _nest(path.sublist(1), v)};

/// Every leaf of [m] by its dotted path (a binding's key is a path already).
Map<String, Object?> _flat(Json m) {
  final out = <String, Object?>{};
  void walk(Object? v, String at) {
    if (v is Map && v.isNotEmpty) {
      v.forEach((k, e) => walk(e, '$at.$k'));
    } else {
      out[at] = v;
    }
  }

  for (final e in m.entries) {
    if (e.key == 'bind' && e.value is Map) {
      (e.value as Map).forEach((k, v) => out['bind.$k'] = v);
    } else {
      walk(e.value, e.key);
    }
  }
  return out;
}

/// The fields of [patch] a word says: a size or a position whole, a
/// binding by its path (a dropped one goes with the value written for it).
List<({List<String> path, Object? value})> _leaves(Json patch) {
  final out = <({List<String> path, Object? value})>[];
  void walk(Object? v, List<String> at) {
    final whole = at.length == 2 && at.first == 'layout' && const {'width', 'height', 'x', 'y'}.contains(at.last);
    if (v is Map && v.isNotEmpty && !whole) {
      v.forEach((k, e) => walk(e, [...at, '$k']));
    } else {
      out.add((path: at, value: v));
    }
  }

  // In one order whatever the patch's: props, layout, decoration, visible,
  // opacity, motion, bindings.
  for (final k in MediaRule.patchKeys) {
    if (!patch.containsKey(k)) continue;
    if (k == 'bind') {
      for (final b in (readMap(patch[k]) ?? const {}).entries) {
        if (b.value != null) out.add((path: ['bind', b.key], value: b.value));
      }
    } else {
      walk(patch[k], [k]);
    }
  }
  return out;
}

/// The notation's short words for a field, by its path from the node.
const _short = {
  'props.spacing': ['gap'],
  'layout.padding': ['pad'],
  'layout.width': ['w'],
  'layout.height': ['h'],
  'layout.constraints.maxWidth': ['maxw'],
  'props.style.fontSize': ['size'],
  'props.style.fontWeight': ['weight'],
  'props.style.color': ['color'],
  'props.decoration.hintText': ['hint'],
};

/// The words to try for the field at [path] (from the node: `props.spacing`;
/// `bind`, `layout.width` for a binding) set to [value], the shortest first:
/// the notation's word, the field's own name, its path from its section,
/// its full path (docs/design/22 section 2.1).
List<String> _candidates(List<String> path, Object? value, String type) {
  if (path.first == 'bind') {
    final s = '$value';
    final expr = s.startsWith(r'${=') && s.endsWith('}')
        ? s.substring(3, s.length - 1).trim()
        : s.startsWith(r'${') && s.endsWith('}')
            ? s.substring(2, s.length - 1)
            : null;
    if (expr == null) return const [];
    return [for (final k in _keys(path[1].split('.'))) '$k={$expr}'];
  }
  if (path.length == 1) {
    return switch ((path.first, value)) {
      ('visible', false) => const ['hidden', 'visible=false'],
      ('visible', true) => const ['visible=true'],
      (final k, final v) => ['$k=${_value(v).first}'],
    };
  }
  return [
    if (path.join('.') == 'layout.flex' && value == 1) 'grow',
    // One color: fill=.
    if (path.join('.') == 'decoration.fills' && value is List && value.length == 1 && value.single is Map && (value.single as Map).keys.join() == 'color')
      for (final v in _value((value.single as Map)['color'])) 'fill=$v',
    // A row's or a column's main axis by its word (tried: on a column
    // `center` is its cross axis).
    if (path.join('.') == 'props.mainAxisAlignment' && (type == 'row' || type == 'column'))
      if (const {'center': 'center', 'end': 'end', 'spaceBetween': 'between', 'start': 'start'}[value] case final String w) w,
    for (final k in _keys(path))
      for (final v in _value(value)) '$k=$v',
  ];
}

List<String> _keys(List<String> path) {
  final full = path.join('.');
  return {
    ...?_short[full],
    path.last,
    if (path.length > 2) path.skip(1).join('.'),
    full,
  }.toList();
}

List<String> _value(Object? v) => switch (v) {
      final String s when RegExp(r'^[A-Za-z_#][A-Za-z0-9_#-]*$').hasMatch(s) => [s, jsonEncode(s)],
      // A text that reads values: "Sprint 12 · {length(tasks)} tasks".
      final String s when s.contains(r'${') => [jsonEncode(s.replaceAllMapped(RegExp(r'\$\{=?\s*([^{}]*?)\s*\}'), (m) => '{${m[1]}}')), jsonEncode(s)],
      final String s => [jsonEncode(s)],
      _ => [jsonEncode(v)],
    };
