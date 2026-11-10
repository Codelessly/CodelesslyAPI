// A layout's variables and conditions, per screen (canvas). Stored in the
// layout document next to its nodes (`variables`, `conditions`), so they
// travel with it; [LayoutDocument.extra] holds them and [LayoutLogic] reads
// them typed.
import 'package:meta/meta.dart';

import 'conditions.dart';
import 'document.dart';
import 'json.dart';
import 'values/paint.dart' show listEquals;
import 'variables.dart';

/// The variables and conditions of each screen of a layout, by canvas id.
/// JSON (two keys of the layout document):
///
/// ```json
/// "variables": {"canvas-a": [{"name": "count", "type": "integer", "value": 0}]},
/// "conditions": {"canvas-a": [{"id": "c1", "branches": [...]}]}
/// ```
@immutable
final class LayoutLogic {
  const LayoutLogic({this.variables = const {}, this.conditions = const {}});

  static const LayoutLogic none = LayoutLogic();

  /// The document keys it's stored under.
  static const String variablesKey = 'variables', conditionsKey = 'conditions';

  /// Canvas id → its variables.
  final Map<String, List<Variable>> variables;

  /// Canvas id → its conditions, in evaluation order.
  final Map<String, List<Condition>> conditions;

  bool get isEmpty => variables.values.every((v) => v.isEmpty) && conditions.values.every((c) => c.isEmpty);

  List<Variable> variablesOf(String canvasId) => variables[canvasId] ?? const [];
  List<Condition> conditionsOf(String canvasId) => conditions[canvasId] ?? const [];

  /// Reads the `variables` and `conditions` of a layout document's JSON
  /// (or its [LayoutDocument.extra]).
  static LayoutLogic fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return none;
    final vars = readMap(m[variablesKey]) ?? const {};
    final conds = readMap(m[conditionsKey]) ?? const {};
    return LayoutLogic(
      variables: {
        for (final e in vars.entries)
          if (Variable.listFromJson(e.value) case final v when v.isNotEmpty) e.key: v,
      },
      conditions: {
        for (final e in conds.entries)
          if (Condition.listFromJson(e.value) case final c when c.isNotEmpty) e.key: c,
      },
    );
  }

  /// The document keys (sparse: none when empty).
  Json toJson() => {
        if (variables.values.any((v) => v.isNotEmpty))
          variablesKey: {
            for (final e in variables.entries)
              if (e.value.isNotEmpty) e.key: [for (final v in e.value) v.toJson()],
          },
        if (conditions.values.any((c) => c.isNotEmpty))
          conditionsKey: {
            for (final e in conditions.entries)
              if (e.value.isNotEmpty) e.key: [for (final c in e.value) c.toJson()],
          },
      };

  @override
  bool operator ==(Object other) {
    if (other is! LayoutLogic) return false;
    bool same<T>(Map<String, List<T>> a, Map<String, List<T>> b) =>
        a.length == b.length && a.entries.every((e) => b[e.key] != null && listEquals(e.value, b[e.key]!));
    return same(other.variables, variables) && same(other.conditions, conditions);
  }

  @override
  int get hashCode => Object.hash(variables.length, conditions.length);
}

extension LayoutDocumentLogic on LayoutDocument {
  /// Its variables and conditions (read from [LayoutDocument.extra]).
  LayoutLogic get logic => LayoutLogic.fromJson(extra);

  /// This document with [logic] as its variables and conditions.
  LayoutDocument withLogic(LayoutLogic logic) => copyWith(extra: {
        for (final e in extra.entries)
          if (e.key != LayoutLogic.variablesKey && e.key != LayoutLogic.conditionsKey) e.key: e.value,
        ...logic.toJson(),
      });
}
