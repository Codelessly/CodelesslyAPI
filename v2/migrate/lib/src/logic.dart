// v1 layout-level variables and conditions (the publish model's
// `SDKLayoutVariables` / `SDKLayoutConditions`, the editor's canvas
// variables and conditions: canvas id → id → JSON) → v2's `variables` and
// `conditions` document keys (API v2 `LayoutLogic`, DESIGN.md §5.1).
import 'package:codelessly_api/codelessly_api.dart';

import 'bindings.dart';
import 'migrate.dart';

/// The v2 `variables` and `conditions` document keys for v1 [variables]
/// and [conditions] (each canvas id → (id → v1 JSON), or the publish
/// model's `{id, variables|conditions: {...}}` wrapper). [nodes] are the
/// layout's decoded v1 nodes: a condition's targets migrate to their v2
/// binding paths. Entries v1 can't decode are dropped (and reported).
Json migrateLayoutLogic({
  Object? variables,
  Object? conditions,
  Map<String, BaseNode> nodes = const {},
  MigrationReport? report,
}) {
  final rep = report ?? MigrationReport();
  final vars = <String, Object?>{};
  for (final e in _canvases(variables, 'variables').entries) {
    final list = [
      for (final v in _entries(e.value))
        if (_variable(v, rep) case final Json j) j,
    ]..sort((a, b) => '${a['name']}'.compareTo('${b['name']}'));
    if (list.isNotEmpty) vars[e.key] = list;
  }
  final conds = <String, Object?>{};
  for (final e in _canvases(conditions, 'conditions').entries) {
    final list = [
      for (final c in _entries(e.value))
        if (_condition(c, nodes, rep) case final Json j) j,
    ];
    if (list.isNotEmpty) conds[e.key] = list;
  }
  return {
    if (vars.isNotEmpty) 'variables': vars,
    if (conds.isNotEmpty) 'conditions': conds,
  };
}

/// canvas id → (id → JSON), unwrapping the publish model's document.
Map<String, Object?> _canvases(Object? json, String key) {
  if (json is! Map) return const {};
  final inner = json[key];
  if (inner is Map && json.containsKey('id')) return inner.cast<String, Object?>();
  return json.cast<String, Object?>();
}

Iterable<Map<String, dynamic>> _entries(Object? json) sync* {
  if (json is Map) {
    for (final v in json.values) {
      if (v is Map) yield v.cast<String, dynamic>();
    }
  } else if (json is List) {
    for (final v in json) {
      if (v is Map) yield v.cast<String, dynamic>();
    }
  }
}

// --- variables ----------------------------------------------------------------

/// A v1 variable as v2 JSON: its value typed (a number is a number, a list
/// a list), a `${= ...}` value or a formula as `formula`.
Json? _variable(Map<String, dynamic> json, MigrationReport report) {
  final VariableData v;
  try {
    v = VariableData.fromJson(json);
  } catch (error) {
    report.undecodable['variable ${json['id'] ?? json['name']}'] = '$error';
    return null;
  }
  if (v.name.isEmpty) return null;
  final formula = v.formula.trim().isNotEmpty
      ? _unwrapFormula(v.formula)
      : (isFormulaValue(v.value) ? _unwrapFormula(v.value) : '');
  final extra = {...v.extra}..remove(VariableData.optionsKey);
  final options = (v.extra[VariableData.optionsKey] as List?) ?? const [];
  Object? value;
  if (formula.isEmpty && v.value.isNotEmpty) {
    value = switch (v.type) {
      // A text that isn't one formula is text, `${...}` and all.
      VariableType.text || VariableType.image || VariableType.choice => v.value,
      VariableType.color => ColorRGBA.fromHex(v.value)?.toHex(),
      _ => v.getValue(),
    };
  }
  return {
    if (v.id.isNotEmpty) 'id': v.id,
    'name': v.name,
    if (v.type != VariableType.text) 'type': v.type.name,
    'value': ?value,
    if (formula.isNotEmpty) 'formula': formula,
    if (v.parameters.isNotEmpty) 'parameters': v.parameters,
    if (options.isNotEmpty) 'options': options,
    ...extra,
  };
}

/// The expression of `${= expression}` (or [text] as is).
String _unwrapFormula(String text) {
  final t = text.trim();
  if (t.startsWith(r'${=') && t.endsWith('}')) return t.substring(3, t.length - 1).trim();
  return t;
}

// --- conditions ---------------------------------------------------------------

Json? _condition(Map<String, dynamic> json, Map<String, BaseNode> nodes, MigrationReport report) {
  final BaseCondition c;
  try {
    c = BaseCondition.fromJson(json);
  } catch (error) {
    report.undecodable['condition ${json['id']}'] = '$error';
    return null;
  }
  final branches = switch (c) {
    ConditionGroup() => [
        _branch(c.ifCondition.expression, c.ifCondition.actions, nodes, report),
        for (final e in c.elseIfConditions) _branch(e.expression, e.actions, nodes, report),
        if (c.elseCondition != null) _branch(null, c.elseCondition!.actions, nodes, report),
      ],
    Condition() => [_branch(c.mode == ConditionMode.elseMode ? null : c.expression, c.actions, nodes, report)],
    ElseCondition() => [_branch(null, c.actions, nodes, report)],
  };
  return {
    if (c.id.isNotEmpty) 'id': c.id,
    if (c is ConditionGroup && (c.name ?? '').isNotEmpty) 'name': c.name,
    'branches': branches,
  };
}

Json _branch(BaseExpression? when, List<ActionModel> actions, Map<String, BaseNode> nodes, MigrationReport report) {
  final sets = <Json>[];
  final other = <Object?>[];
  for (final a in actions) {
    switch (a) {
      case SetValueAction():
        final node = nodes[a.nodeID];
        for (final v in a.values) {
          final path = node == null ? null : v2BindPath(node, v2TypeOf(node), v.name);
          if (path == null) {
            report.unmappedBindings.update('condition.${node?.type ?? '?'}.${v.name}', (x) => x + 1, ifAbsent: () => 1);
          }
          sets.add({'node': a.nodeID, 'path': path ?? v.name, 'value': _value(v, path)});
        }
      case SetVariantAction():
        sets.add({'node': a.nodeID, 'path': 'props.current', 'value': a.variantID});
      default:
        other.add(a.toJson());
    }
  }
  return {
    if (when != null) 'when': _predicate(when),
    if (sets.isNotEmpty) 'set': sets,
    if (other.isNotEmpty) 'actions': other,
  };
}

/// A set value's value as v2 JSON: text stays text (an expression), colors
/// are `#AARRGGBB`, paints are v2 paints (or their color where the path
/// takes a color).
Object? _value(ValueModel v, String? path) {
  final value = v.value;
  return switch (value) {
    ColorRGBA() => value.toHex(),
    ColorRGB() => value.toColorRGBA()?.toHex(),
    PaintModel() when path != null && (path.endsWith('color') || path.endsWith('Color')) => switch (value.color) {
        final ColorRGB c => Color8.hex((value.opacity * 255).toInt(), c.r, c.g, c.b),
        null => null,
      },
    PaintModel() => V1Node.paint(value),
    _ => value,
  };
}

Json _predicate(BaseExpression e) => switch (e) {
      Expression() => {
          'left': _operand(e.leftPart),
          'op': e.operator.name,
          if (e.operator.requiresRightOperand) 'right': _operand(e.rightPart),
        },
      ExpressionGroup() => {
          e.join.name: [
            ..._flatten(e.leftExpression, e.join),
            ..._flatten(e.rightExpression, e.join),
          ],
        },
    };

/// The parts of [e] joined by [join] (and/or are associative and every part
/// is evaluated, so nested groups of the same join flatten).
Iterable<Json> _flatten(BaseExpression e, ConditionJoin join) sync* {
  if (e is ExpressionGroup && e.join == join) {
    yield* _flatten(e.leftExpression, join);
    yield* _flatten(e.rightExpression, join);
  } else {
    yield _predicate(e);
  }
}

/// A variable part is an expression text; a raw value is a literal (kept
/// raw only when it holds `${`, which a variable part would substitute).
Object _operand(ExpressionPart p) => switch (p) {
      VariablePart() => p.valueString,
      RawValuePart() => p.value.contains(r'${') ? {'raw': p.value} : p.value,
    };
