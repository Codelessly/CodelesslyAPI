// The standard catalog: the core and the first-party feature libraries
// (data, auth, commerce, media, engage), and the views kept for code that
// lists every declared type without a catalog of its own. Not part of the
// core: it imports every feature library.
import 'core/action_fields.dart';
import 'core/actions.dart';
import 'core/catalog.dart';
import 'core/json.dart' show readMap, readString;
import 'core/props.dart';
import 'features/auth/catalog.dart';
import 'features/commerce/catalog.dart';
import 'features/data/catalog.dart';
import 'features/engage/catalog.dart';
import 'features/media/catalog.dart';

/// [Catalog.core] and every first-party feature library: what a default
/// Codelessly app reads, and what the editor offers.
const Catalog standardCatalog = Catalog(
  id: 'standard',
  parts: [Catalog.core, dataCatalog, authCatalog, commerceCatalog, mediaCatalog, engageCatalog],
);

/// Every widget declaration of [standardCatalog]: a view kept for code that
/// lists or looks up node types without a catalog of its own.
abstract final class Widgets {
  /// The standard catalog's node types.
  static List<WidgetSpec> get all => standardCatalog.widgets;

  /// The declaration for [type], or null for a type the standard catalog
  /// doesn't declare (its node still decodes and round-trips).
  static WidgetSpec? of(String type) => standardCatalog.widget(type);
}

/// Every action type an editor can make, by JSON type.
abstract final class ActionSpecs {
  /// The standard catalog's action declarations ([standardCatalog]).
  static Iterable<ActionSpec> get all => standardCatalog.actions;

  static ActionSpec? of(String type) => standardCatalog.action(type);

  /// The keys of action JSON [json], and of the actions nested in it, that
  /// its type doesn't have, as paths (`look`, `actions[1].style`): a
  /// misspelled or misplaced field (`style` where a confirm takes `look`)
  /// that decoding drops without a word. A type this version doesn't know
  /// is kept whole, so it has none.
  static List<String> unknownKeys(Object? json, [String path = '']) {
    final m = readMap(json);
    final spec = m == null ? null : of(readString(m['type']) ?? '');
    if (m == null || spec == null) return const [];
    final known = {
      'type', ActionCommonFields.enabled.key, ActionCommonFields.nonBlocking.key, ActionCommonFields.when.key,
      for (final f in spec.fields) f.key,
      ...?ActionDef.fromJson(m, catalog: standardCatalog)?.toJson().keys,
    };
    final out = <String>[];
    for (final e in m.entries) {
      if (!known.contains(e.key)) out.add('$path${e.key}');
      final v = e.value;
      if (v is! List) continue;
      for (var i = 0; i < v.length; i++) {
        final item = v[i];
        if (item is Map && item['type'] is String) out.addAll(unknownKeys(item, '$path${e.key}[$i].'));
      }
    }
    return out;
  }
}

/// Keys of action JSON that no field of its type reads, found in
/// [reactions] (a node's `actions`: reactions `{trigger, actions}`, or a
/// bare list of actions), nested chains included (`then`, `else`,
/// `actions`, `onSuccess`, `onError`, `cancelActions`). Decoding drops such
/// keys silently (a `delay` given `durationMs` waits its default 500 ms), so
/// tools report them: each as "<path>: <type> has no "<key>" (it takes: ...)".
List<String> unknownActionKeys(Object? reactions, {String at = 'actions'}) {
  final out = <String>[];
  const structural = {'type', 'id', 'enabled', 'nonBlocking', 'when'};
  const nested = {'then', 'else', 'actions', 'onSuccess', 'onError', 'cancelActions'};
  void action(Object? a, String path) {
    final m = readMap(a);
    if (m == null) return;
    final type = m['type'];
    final spec = type is String ? ActionSpecs.of(type) : null;
    if (spec != null) {
      final known = {...structural, for (final f in spec.fields) f.key};
      for (final k in m.keys) {
        if (!known.contains(k)) {
          out.add('$path: ${spec.type} has no "$k" (it takes: ${spec.fields.map((f) => f.key).join(', ')})');
        }
      }
    }
    for (final k in nested) {
      if (m[k] case final List list) {
        for (var i = 0; i < list.length; i++) {
          action(list[i], '$path.$k[$i]');
        }
      }
    }
  }

  if (reactions is List) {
    for (var i = 0; i < reactions.length; i++) {
      final r = readMap(reactions[i]);
      if (r == null) continue;
      if (r.containsKey('trigger')) {
        final trigger = readMap(r['trigger']);
        final known = {for (final f in TriggerFields.all) f.key};
        for (final k in trigger?.keys ?? const <String>[]) {
          if (!known.contains(k)) out.add('$at[$i].trigger has no "$k" (it takes: ${known.join(', ')})');
        }
        if (r['actions'] case final List chain) {
          for (var j = 0; j < chain.length; j++) {
            action(chain[j], '$at[$i].actions[$j]');
          }
        }
      } else {
        action(r, '$at[$i]');
      }
    }
  }
  return out;
}
