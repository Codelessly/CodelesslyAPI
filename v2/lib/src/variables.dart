// Variables: the named values a layout's expressions read (`${count}`,
// `${= price * qty}`). Pure data; the SDK's runtime holds their current
// values (see DESIGN.md §5.1).
import 'dart:convert';

import 'package:meta/meta.dart';

import 'json.dart';
import 'values/color.dart';

/// What a variable holds.
enum VariableType {
  /// A whole number (`int`).
  integer,

  /// Text (`String`).
  text,

  /// A number with decimals (`double`).
  decimal,

  /// `true` or `false`.
  boolean,

  /// A color, `#AARRGGBB`.
  color,

  /// A JSON list.
  list,

  /// A JSON object.
  map,

  /// An image URL.
  image,

  /// One of [Variable.options], stored as the option's value.
  choice;

  /// [value] as this type holds it, or null when it can't be read as one.
  /// Text types take any scalar as text; numbers take numeric text; colors
  /// take `#RRGGBB` / `#AARRGGBB` (normalized to `#AARRGGBB`).
  Object? coerce(Object? value) => switch (this) {
        _ when value == null => null,
        text || image || choice => switch (value) {
            final String s => s,
            final num n => _numText(n),
            final bool b => '$b',
            _ => null,
          },
        integer => switch (value) {
            final num n when n.isFinite => n.toInt(),
            final String s => num.tryParse(s.trim())?.let((n) => n.isFinite ? n.toInt() : null),
            _ => null,
          },
        decimal => switch (value) {
            final num n when n.isFinite => n.toDouble(),
            final String s => double.tryParse(s.trim())?.let((d) => d.isFinite ? d : null),
            _ => null,
          },
        boolean => switch (value) {
            final bool b => b,
            final String s => switch (s.trim().toLowerCase()) { 'true' => true, 'false' => false, _ => null },
            _ => null,
          },
        color => Color.fromJson(value is String ? value.trim() : value)?.toJson(),
        list => value is List ? value : (value is String ? _decode(value).let((d) => d is List ? d : null) : null),
        map => readMap(value is String ? _decode(value) : value),
      };

  static Object? _decode(String text) {
    try {
      return jsonDecode(text);
    } catch (_) {
      return null;
    }
  }

  static String _numText(num n) => n is double && n == n.roundToDouble() && n.abs() < 1e15 ? '${n.toInt()}' : '$n';
}

/// One option of a [VariableType.choice] variable.
@immutable
final class VariableOption {
  const VariableOption(this.value, [String? label]) : label = label ?? value;

  final String value;
  final String label;

  static VariableOption? fromJson(Object? json) {
    if (json is String) return VariableOption(json);
    if (json is num || json is bool) return VariableOption('$json');
    final m = readMap(json);
    final v = m?['value'];
    if (v == null) return null;
    return VariableOption('$v', m!['label'] == null ? null : '${m['label']}');
  }

  /// A plain string when the label is the value.
  Object toJson() => label == value ? value : {'value': value, 'label': label};

  @override
  bool operator ==(Object other) => other is VariableOption && other.value == value && other.label == label;

  @override
  int get hashCode => Object.hash(value, label);
}

/// A variable: a name, a type and a default value, or a [formula] that
/// computes it from other variables. JSON (sparse):
///
/// ```json
/// {"id": "v1", "name": "count", "type": "integer", "value": 3}
/// {"id": "v2", "name": "total", "type": "decimal", "formula": "price * qty"}
/// {"id": "v3", "name": "clamp01", "formula": "min(1, max(0, v))", "parameters": ["v"]}
/// {"id": "v4", "name": "draft", "value": "", "persist": true}
/// ```
@immutable
final class Variable {
  const Variable({
    this.id = '',
    required this.name,
    this.type = VariableType.text,
    this.value,
    this.formula = '',
    this.parameters = const [],
    this.options = const [],
    this.persist = false,
    this.extra = const {},
  });

  final String id;

  /// Unique in its scope; what expressions read (`${name}`).
  final String name;
  final VariableType type;

  /// The default value, as [type] holds it (see [VariableType.coerce]);
  /// null when unset.
  final Object? value;

  /// The expression (what goes in `${= ...}`) that computes the value of a
  /// computed variable; empty for a plain one. A computed variable is
  /// read-only: it changes when what its formula reads changes.
  final String formula;

  /// A computed variable with parameters is a function: formulas call it by
  /// name (`clamp01(x)`), and its [formula] reads the arguments by these
  /// names.
  final List<String> parameters;

  /// The options of a [VariableType.choice] variable.
  final List<VariableOption> options;

  /// Whether the app keeps the value on the device: it starts from the
  /// value it had last time (not [value]) and every change is saved. A
  /// draft, a list the user builds up. A computed variable can't persist
  /// ([persists]).
  final bool persist;

  /// Keys this version doesn't model, round-tripped.
  final Json extra;

  bool get isComputed => formula.trim().isNotEmpty;

  /// Whether its value is kept on the device: [persist], and not computed.
  bool get persists => persist && !isComputed;
  bool get isFunction => isComputed && parameters.isNotEmpty;

  Variable copyWith({
    String? id,
    String? name,
    VariableType? type,
    Object? Function()? value,
    String? formula,
    List<String>? parameters,
    List<VariableOption>? options,
    bool? persist,
    Json? extra,
  }) =>
      Variable(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        value: value == null ? this.value : value(),
        formula: formula ?? this.formula,
        parameters: parameters ?? this.parameters,
        options: options ?? this.options,
        persist: persist ?? this.persist,
        extra: extra ?? this.extra,
      );

  static const _keys = {'id', 'name', 'type', 'value', 'formula', 'parameters', 'options', 'persist'};

  /// Decodes a variable; null only without a name.
  static Variable? fromJson(Object? json) {
    final m = readMap(json);
    final name = readString(m?['name']);
    if (m == null || name == null || name.isEmpty) return null;
    final type = readEnum(VariableType.values, m['type'], VariableType.text);
    return Variable(
      id: readString(m['id']) ?? '',
      name: name,
      type: type,
      value: type.coerce(m['value']),
      formula: readString(m['formula']) ?? '',
      parameters: readStrings(m['parameters']),
      options: [...?readList(m['options'])?.map(VariableOption.fromJson).nonNulls],
      persist: readBool(m['persist']) ?? false,
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  static List<Variable> listFromJson(Object? json) => [...?readList(json)?.map(fromJson).nonNulls];

  Json toJson() => {
        if (id.isNotEmpty) 'id': id,
        'name': name,
        if (type != VariableType.text) 'type': type.name,
        'value': ?value,
        if (formula.isNotEmpty) 'formula': formula,
        if (parameters.isNotEmpty) 'parameters': parameters,
        if (options.isNotEmpty) 'options': [for (final o in options) o.toJson()],
        if (persist) 'persist': true,
        ...extra,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Variable &&
          other.id == id &&
          other.name == name &&
          other.type == type &&
          jsonEquality.equals(other.value, value) &&
          other.formula == formula &&
          jsonEquality.equals(other.parameters, parameters) &&
          jsonEquality.equals(other.options, options) &&
          other.persist == persist &&
          jsonEquality.equals(other.extra, extra);

  @override
  int get hashCode => Object.hash(id, name, type, formula);

  @override
  String toString() => 'Variable($name: ${type.name}${isComputed ? ' = $formula' : value == null ? '' : ' = $value'})';
}
