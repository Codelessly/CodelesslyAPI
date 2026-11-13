// Responsive patches: a node's own fields changed per breakpoint.
//
// The same idea as an interaction state's patch (`states`): a JSON merge
// patch over the node, here keyed by a condition on the screen's named
// breakpoint, in ResponsiveFramework's vocabulary (`Condition.equals`,
// `largerThan`, `smallerThan`, `between`). Anything a node holds can then
// differ per breakpoint: a `flex` node's `direction` (a row that becomes a
// column), spacing, alignment, layout, visibility, text style, decoration,
// and the order of its children.
import 'package:meta/meta.dart';

import 'breakpoints.dart';
import 'json.dart';

/// One responsive patch: [patch] applies to the node while the screen's
/// breakpoint meets the condition (exactly one of [equals], [largerThan],
/// [smallerThan], [between]).
@immutable
final class ResponsivePatch {
  const ResponsivePatch({this.equals, this.largerThan, this.smallerThan, this.between, this.patch = const {}});

  /// At this breakpoint only (`Condition.equals`).
  final String? equals;

  /// At every breakpoint wider than this one (`Condition.largerThan`).
  final String? largerThan;

  /// At every breakpoint narrower than this one (`Condition.smallerThan`).
  final String? smallerThan;

  /// From the first breakpoint to the second, both included
  /// (`Condition.between`).
  final List<String>? between;

  /// A JSON merge patch over the node (maps merge, `null` removes, anything
  /// else replaces): `props`, `layout`, `decoration`, `visible`, `opacity`,
  /// `children` (the same ids in another order).
  final Json patch;

  /// The keys a patch may set.
  static const patchKeys = {'props', 'layout', 'decoration', 'visible', 'opacity', 'children'};

  /// The condition keys an entry may have (one of them).
  static const conditionKeys = {'equals', 'largerThan', 'smallerThan', 'between'};

  /// The breakpoint names the condition mentions.
  List<String> get names => [?equals, ?largerThan, ?smallerThan, ...?between];

  /// Whether the condition holds at breakpoint [current] of [breakpoints]
  /// (a name that is not a breakpoint never holds).
  bool holds(Breakpoint current, Breakpoints breakpoints) {
    final at = breakpoints.indexOf(current.id);
    int index(String name) => breakpoints.indexOf(breakpoints.find(name)?.id);
    if (equals case final String e) return index(e) >= 0 && index(e) == at;
    if (largerThan case final String l) return index(l) >= 0 && at > index(l);
    if (smallerThan case final String s) return index(s) >= 0 && at < index(s);
    if (between case [final String a, final String b]) {
      final i = index(a), j = index(b);
      return i >= 0 && j >= 0 && at >= i && at <= j;
    }
    return false;
  }

  /// The condition as text (`smallerThan tablet`).
  String get conditionText => equals != null
      ? 'equals $equals'
      : largerThan != null
          ? 'largerThan $largerThan'
          : smallerThan != null
              ? 'smallerThan $smallerThan'
              : 'between ${between?.join(' and ')}';

  static ResponsivePatch? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final between = readStrings(m['between']);
    return ResponsivePatch(
      equals: readString(m['equals']),
      largerThan: readString(m['largerThan']),
      smallerThan: readString(m['smallerThan']),
      between: between.length == 2 ? between : null,
      patch: readMap(m['patch']) ?? const {},
    );
  }

  static List<ResponsivePatch> listFromJson(Object? json) => [
        for (final e in readList(json) ?? const []) ?ResponsivePatch.fromJson(e),
      ];

  Json toJson() => {
        'equals': ?equals,
        'largerThan': ?largerThan,
        'smallerThan': ?smallerThan,
        'between': ?between,
        'patch': patch,
      };

  @override
  bool operator ==(Object other) =>
      other is ResponsivePatch &&
      other.equals == equals &&
      other.largerThan == largerThan &&
      other.smallerThan == smallerThan &&
      jsonEquality.equals(other.between, between) &&
      jsonEquality.equals(other.patch, patch);

  @override
  int get hashCode => Object.hash(equals, largerThan, smallerThan, jsonEquality.hash(patch));
}

/// The merged patch of [patches] at breakpoint [current]: each entry whose
/// condition holds, in order (a later one wins where two set the same
/// field), keys outside [ResponsivePatch.patchKeys] left out. Null when
/// none holds.
Json? responsivePatchAt(List<ResponsivePatch> patches, Breakpoint current, Breakpoints breakpoints) {
  Json? out;
  for (final p in patches) {
    if (!p.holds(current, breakpoints)) continue;
    final own = {for (final e in p.patch.entries) if (ResponsivePatch.patchKeys.contains(e.key)) e.key: e.value};
    if (own.isEmpty) continue;
    out = out == null ? own : _merge(out, own);
  }
  return out;
}

Json _merge(Json a, Json b) {
  final out = <String, Object?>{...a};
  for (final e in b.entries) {
    final cur = out[e.key];
    out[e.key] = e.value is Map && cur is Map ? _merge(cur.cast<String, Object?>(), (e.value as Map).cast<String, Object?>()) : e.value;
  }
  return out;
}
