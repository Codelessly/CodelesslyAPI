// Conditions: if / else-if / else rules that set node properties while a
// predicate over variables holds (v1's condition groups of set-value
// actions). Pure data; the SDK evaluates them over its bindings
// (DESIGN.md §5.1).
import 'package:meta/meta.dart';

import 'json.dart';
import 'values/paint.dart' show listEquals;

/// How a [Comparison] compares its operands. Loose, as v1 compared: numbers
/// as numbers, booleans as booleans, anything else as case-insensitive text.
enum ConditionOp {
  equalsTo,
  notEqualsTo,
  greaterThan,
  lessThan,
  greaterThanOrEqualTo,
  lessThanOrEqualTo,

  /// Null, or an empty text, list or map.
  isEmpty,
  isNotEmpty,

  /// A list holds the right operand, a text contains it, a map has it as a key.
  contains,
  isOdd,
  isEven,

  /// Null, or the text `null`.
  isNull,
  isTrue,
  isFalse;

  /// Whether it reads a right operand.
  bool get takesRight => index <= contains.index && this != isEmpty && this != isNotEmpty;
}

/// One side of a [Comparison]: an expression text whose `${...}` are read
/// (`${count}`, `${= a + b}`, `3`, `done`), or, when [raw], a literal taken
/// as written. Both are then parsed loosely (`3` is a number, `true` a bool,
/// `[1, 2]` a list). JSON: the text, or `{"raw": text}`.
@immutable
final class ConditionOperand {
  const ConditionOperand(this.text, {this.raw = false});

  static const ConditionOperand empty = ConditionOperand('');

  final String text;
  final bool raw;

  static ConditionOperand fromJson(Object? json) {
    if (json is String) return ConditionOperand(json);
    if (json is num || json is bool) return ConditionOperand('$json');
    final m = readMap(json);
    if (m != null && m.containsKey('raw')) return ConditionOperand('${m['raw'] ?? ''}', raw: true);
    return empty;
  }

  Object toJson() => raw ? {'raw': text} : text;

  @override
  bool operator ==(Object other) => other is ConditionOperand && other.text == text && other.raw == raw;

  @override
  int get hashCode => Object.hash(text, raw);

  @override
  String toString() => raw ? 'raw($text)' : text;
}

/// What a branch tests.
@immutable
sealed class Predicate {
  const Predicate();

  /// Decodes a predicate; null for anything that isn't one.
  static Predicate? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    for (final join in Join.values) {
      if (readList(m[join.name]) case final List<Object?> parts) {
        final ps = [...parts.map(fromJson).nonNulls];
        return ps.isEmpty ? null : Junction(join, ps);
      }
    }
    if (!m.containsKey('op') && !m.containsKey('left')) return null;
    return Comparison(
      ConditionOperand.fromJson(m['left']),
      readEnum(ConditionOp.values, m['op'], ConditionOp.equalsTo),
      ConditionOperand.fromJson(m['right']),
    );
  }

  Json toJson();

  /// The expression texts it reads, left to right.
  Iterable<ConditionOperand> get operands;
}

/// `left op right` (the right side only for ops that [ConditionOp.takesRight]).
final class Comparison extends Predicate {
  const Comparison(this.left, this.op, [this.right = ConditionOperand.empty]);

  final ConditionOperand left;
  final ConditionOp op;
  final ConditionOperand right;

  @override
  Iterable<ConditionOperand> get operands => [left, if (op.takesRight) right];

  @override
  Json toJson() => {
        'left': left.toJson(),
        'op': op.name,
        if (op.takesRight || right != ConditionOperand.empty) 'right': right.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      other is Comparison && other.left == left && other.op == op && other.right == right;

  @override
  int get hashCode => Object.hash(left, op, right);

  @override
  String toString() => '($left ${op.name} $right)';
}

enum Join { and, or }

/// All of [parts] (`and`) or any of them (`or`). Every part is evaluated.
/// JSON: `{"and": [...]}` / `{"or": [...]}`.
final class Junction extends Predicate {
  const Junction(this.join, this.parts);

  final Join join;
  final List<Predicate> parts;

  @override
  Iterable<ConditionOperand> get operands => parts.expand((p) => p.operands);

  @override
  Json toJson() => {join.name: [for (final p in parts) p.toJson()]};

  @override
  bool operator ==(Object other) => other is Junction && other.join == join && listEquals(other.parts, parts);

  @override
  int get hashCode => Object.hash(join, Object.hashAll(parts));

  @override
  String toString() => '(${parts.join(' ${join.name} ')})';
}

/// Sets property [path] (a binding path, DESIGN.md §5.1) of node [node] to
/// [value]: a JSON value, where a string is an expression read like a
/// binding's (`${= qty * 2}`, `#FF0000`, `Hello ${name}`).
@immutable
final class PropertySet {
  const PropertySet({required this.node, required this.path, this.value});

  final String node;
  final String path;
  final Object? value;

  static PropertySet? fromJson(Object? json) {
    final m = readMap(json);
    final node = readString(m?['node']), path = readString(m?['path']);
    if (node == null || path == null || node.isEmpty || path.isEmpty) return null;
    return PropertySet(node: node, path: path, value: m!['value']);
  }

  Json toJson() => {'node': node, 'path': path, 'value': value};

  @override
  bool operator ==(Object other) =>
      other is PropertySet && other.node == node && other.path == path && jsonEquality.equals(other.value, value);

  @override
  int get hashCode => Object.hash(node, path, jsonEquality.hash(value));
}

/// One branch: when [when] holds (always, for an `else`: null), the
/// properties in [sets] take their values.
@immutable
final class ConditionBranch {
  const ConditionBranch({this.when, this.sets = const [], this.actions = const []});

  /// The test; null for an `else` branch.
  final Predicate? when;
  final List<PropertySet> sets;

  /// Other actions the branch carried (kept for the editor; the runtime
  /// reads [sets]).
  final List<Json> actions;

  bool get isElse => when == null;

  static ConditionBranch? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return ConditionBranch(
      when: Predicate.fromJson(m['when']),
      sets: [...?readList(m['set'])?.map(PropertySet.fromJson).nonNulls],
      actions: [...?readList(m['actions'])?.map(readMap).nonNulls],
    );
  }

  Json toJson() => {
        if (when != null) 'when': when!.toJson(),
        if (sets.isNotEmpty) 'set': [for (final s in sets) s.toJson()],
        if (actions.isNotEmpty) 'actions': actions,
      };

  @override
  bool operator ==(Object other) =>
      other is ConditionBranch &&
      other.when == when &&
      listEquals(other.sets, sets) &&
      jsonEquality.equals(other.actions, actions);

  @override
  int get hashCode => Object.hash(when, Object.hashAll(sets));
}

/// An if / else-if / else rule. Its first branch whose test holds and
/// that sets a property gives the property its value; when none does, the
/// property keeps its binding's or its own value. JSON:
///
/// ```json
/// {"id": "c1", "name": "Low stock", "branches": [
///   {"when": {"left": "${stock}", "op": "lessThan", "right": "5"},
///    "set": [{"node": "badge", "path": "visible", "value": true}]},
///   {"set": [{"node": "badge", "path": "visible", "value": false}]}]}
/// ```
@immutable
final class Condition {
  const Condition({this.id = '', this.name = '', this.branches = const [], this.extra = const {}});

  final String id;
  final String name;
  final List<ConditionBranch> branches;
  final Json extra;

  /// Every property it sets, as (node, path).
  Iterable<(String, String)> get targets sync* {
    final seen = <(String, String)>{};
    for (final b in branches) {
      for (final s in b.sets) {
        if (seen.add((s.node, s.path))) yield (s.node, s.path);
      }
    }
  }

  static Condition? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return Condition(
      id: readString(m['id']) ?? '',
      name: readString(m['name']) ?? '',
      branches: [...?readList(m['branches'])?.map(ConditionBranch.fromJson).nonNulls],
      extra: {
        for (final e in m.entries)
          if (!const {'id', 'name', 'branches'}.contains(e.key)) e.key: e.value,
      },
    );
  }

  static List<Condition> listFromJson(Object? json) => [...?readList(json)?.map(fromJson).nonNulls];

  Json toJson() => {
        if (id.isNotEmpty) 'id': id,
        if (name.isNotEmpty) 'name': name,
        'branches': [for (final b in branches) b.toJson()],
        ...extra,
      };

  @override
  bool operator ==(Object other) =>
      other is Condition &&
      other.id == id &&
      other.name == name &&
      listEquals(other.branches, branches) &&
      jsonEquality.equals(other.extra, extra);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(branches));
}
