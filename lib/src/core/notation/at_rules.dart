// The media rules of a design at a width (docs/design/24-a-design-at-a-
// width.md): what the parser writes for an `at` block (at_width.dart) and
// the printer reads back (print_at.dart), worked out the same way by both.
import '../json.dart';
import 'media_words.dart' show mediaCondition, mediaConditionWords, mediaHidden;

/// The condition of `at <words>` (`phone`, `min700.tablet`, `portrait`) and
/// its words as the notation says them (`mobile` is `phone`); null when the
/// words are not a condition a block reads (widths in px and orientations,
/// not a breakpoint by its name).
({Json condition, String words})? atCondition(String words) {
  final read = mediaCondition('$words.x');
  if (read == null || read.length != words.length + 1 || read.problem != null) return null;
  if (read.condition.values.any((v) => v is String && v != 'portrait' && v != 'landscape')) return null;
  return (condition: read.condition, words: mediaConditionWords(read.condition) ?? words);
}

/// The rule that hides a node where [condition] holds.
Json atHidden(Json condition) => {...condition, 'patch': {...mediaHidden, 'bind': {...mediaHidden['bind']! as Map}}};

/// The rules that hide a node where [condition] does not hold: one for each
/// of its bounds (below its least width, above its most, the other
/// orientation).
List<Json> atOutside(Json condition) => [
      if (condition['minWidth'] case final num m) atHidden({'maxWidth': m - 1}),
      if (condition['maxWidth'] case final num m) atHidden({'minWidth': m + 1}),
      if (condition['orientation'] case final String o) atHidden({'orientation': o == 'portrait' ? 'landscape' : 'portrait'}),
    ];

/// Whether condition [a] holds wherever [b] does.
bool atCovers(Json a, Json b) {
  num lo(Json c) => c['minWidth'] as num? ?? 0;
  num hi(Json c) => c['maxWidth'] as num? ?? double.infinity;
  return lo(a) <= lo(b) && hi(a) >= hi(b) && (a['orientation'] == null || a['orientation'] == b['orientation']);
}

/// Whether [condition] holds on a window [width] × [height].
bool atHolds(Json condition, num width, num height) {
  if (condition['minWidth'] case final num m when width < m) return false;
  if (condition['maxWidth'] case final num m when width > m) return false;
  if (condition['orientation'] case final String o) return o == (height >= width ? 'portrait' : 'landscape');
  return true;
}

/// A parent's children read as the parser writes an `at` block under it:
/// its own lines (each hidden where a block holds), then each block's first
/// lines (named `at <words>`, hidden where it does not hold and where a
/// later block holds), and [view]: each of those nodes without what the
/// blocks gave it (its name, those rules). Null when the children are not
/// that (no block, or rules or names that are not the blocks').
({List<String> own, List<({String words, Json condition, List<String> tops})> blocks, Map<String, Json> view})? atBlocksOf(Json parent, Json nodes) {
  try {
    return _atBlocks(parent, nodes);
  } on _NotAt {
    return null;
  }
}

({List<String> own, List<({String words, Json condition, List<String> tops})> blocks, Map<String, Json> view})? _atBlocks(Json parent, Json nodes) {
  final kids = readStrings(parent['children']);
  String? named(String id) {
    final name = readMap(nodes[id])?['name'];
    return name is String && name.startsWith('at ') ? name.substring(3) : null;
  }

  final first = kids.indexWhere((k) => named(k) != null);
  if (first < 0) return null;
  final blocks = <({String words, Json condition, List<String> tops})>[];
  for (var i = first; i < kids.length; i++) {
    final words = named(kids[i]);
    if (words == null) return null;
    final c = atCondition(words);
    if (c == null || c.words != words) return null;
    if (blocks.isNotEmpty && blocks.last.words == words) {
      blocks.last.tops.add(kids[i]);
    } else {
      if (blocks.any((b) => b.words == words)) return null;
      blocks.add((words: words, condition: c.condition, tops: [kids[i]]));
    }
  }
  final view = <String, Json>{};
  Json? without(String id, List<Json> rules, {bool name = false}) {
    final n = readMap(nodes[id]);
    if (n == null) return null;
    final media = [...?readList(n['media'])];
    for (final r in rules) {
      final i = media.lastIndexWhere((m) => jsonEquality.equals(m, r));
      if (i < 0) return null;
      media.removeAt(i);
    }
    final out = {...n}..remove('media');
    if (name) out.remove('name');
    if (media.isNotEmpty) out['media'] = media;
    return out;
  }

  final own = kids.sublist(0, first);
  for (final k in own) {
    view[k] = without(k, [for (final b in blocks) atHidden(b.condition)]) ?? (throw const _NotAt());
  }
  for (var i = 0; i < blocks.length; i++) {
    for (final t in blocks[i].tops) {
      view[t] = without(t, [...atOutside(blocks[i].condition), for (final b in blocks.skip(i + 1)) atHidden(b.condition)], name: true) ?? (throw const _NotAt());
    }
  }
  return (own: own, blocks: blocks, view: view);
}

final class _NotAt implements Exception {
  const _NotAt();
}
