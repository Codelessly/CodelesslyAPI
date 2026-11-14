// Declarations as JSON, both ways: what `Catalog.toJson` writes for the
// generated reference, editors and agents, and what `Catalog.fromJson` reads
// back for types declared as data (a hosted plugin's, or a native plugin's
// manifest). A PropType states kind, Flutter type, enum values, bounds, item
// type and object fields, so a [JsonPropCodec] built from one decodes any
// declared value.
import 'action_fields.dart' show ActionCommonFields, TriggerFields;
import 'behavior_fields.dart' show BehaviorFields;
import 'catalog.dart';
import 'json.dart';
import 'props.dart';
import 'triggers.dart' show TriggerType;
import 'value_fields.dart' show DecorationFields, LayoutFields, NodeFields;

/// The JSON form of a [PropType]: `{"kind": "number", "flutter": "double",
/// "min": 0, "max": 5}`, `{"kind": "enumeration", "flutter": "MainAxisAlignment",
/// "values": [...]}`, `{"kind": "list", "item": {...}}`, `{"kind": "object",
/// "flutter": "TextStyle"}` (an object's fields are written once, under the
/// catalog's `valueTypes`, unless [fields] is set).
Json propTypeToJson(PropType t, {bool fields = false}) => t.variableOf != null
    ? {'kind': 'variable', 'of': propTypeToJson(t.variableOf!, fields: fields)}
    : {
  'kind': t.kind.name,
  if (t.kind != PropKind.list) 'flutter': t.name,
  if (t.values.isNotEmpty) 'values': t.values,
  'min': ?t.min,
  'max': ?t.max,
  if (t.item case final item?) 'item': propTypeToJson(item),
  if (fields && t.kind == PropKind.object) 'fields': [for (final f in t.fields) propDefToJson(f)],
};

/// The `kind` a component's `variable` parameter is written with
/// ([PropType.variable]): not a [PropKind], whose values panels switch over.
const String kVariableKind = 'variable';

/// A [PropType] from its JSON; a missing or unknown kind is free JSON.
PropType propTypeFromJson(Object? json) {
  final m = readMap(json) ?? const {};
  if (m['kind'] == kVariableKind) return PropType.variable(propTypeFromJson(m['of']));
  final kind = readEnum(PropKind.values, m['kind'], PropKind.json);
  final name = readString(m['flutter']);
  final min = readDouble(m['min']), max = readDouble(m['max']);
  return switch (kind) {
    PropKind.boolean => const PropType.boolean(),
    PropKind.integer => PropType.integer(min: min?.round(), max: max?.round()),
    PropKind.number => PropType.number(min: min, max: max),
    PropKind.string => const PropType.string(),
    PropKind.enumeration => PropType.enumeration(name ?? 'String', readStrings(m['values'])),
    PropKind.value => PropType.value(name ?? 'Object'),
    PropKind.list => PropType.list(propTypeFromJson(m['item'])),
    PropKind.object => _objectType(name ?? 'Object', [...?readList(m['fields'])?.map(propDefFromJson).nonNulls]),
    PropKind.json => PropType.json(name ?? 'Object'),
  };
}

PropType _objectType(String name, List<PropDef<Object?>> fields) =>
    PropType.record(name, WidgetSpec(name, props: fields));

/// The JSON of [def]: its key, type, default (as JSON), whether it may be
/// unset, and its doc.
Json propDefToJson(PropDef<Object?> def) => {
  'key': def.key,
  'type': propTypeToJson(def.type),
  'default': _encodeDefault(def),
  if (def.nullable) 'nullable': true,
  if (def.required) 'required': true,
  if (def.doc.isNotEmpty) 'doc': def.doc,
};

Object? _encodeDefault(PropDef<Object?> def) {
  final v = def.defaultValue;
  if (v == null) return null;
  try {
    return def.encode(v);
  } catch (_) {
    return null;
  }
}

/// A [PropDef] read from its JSON, with a [JsonPropCodec]; null without a
/// key.
PropDef<Object?>? propDefFromJson(Object? json) {
  final m = readMap(json);
  final key = readString(m?['key']);
  if (m == null || key == null || key.isEmpty) return null;
  final codec = JsonPropCodec(propTypeFromJson(m['type']));
  final nullable = readBool(m['nullable']) ?? m['default'] == null;
  final def = codec.decode(m['default']) ?? (nullable ? null : codec.zero);
  return PropDef<Object?>(key, codec, def, doc: readString(m['doc']) ?? '', required: readBool(m['required']) ?? false);
}

/// [v] within [min] and [max] (either may be absent).
num _clamp(num v, num? min, num? max) => min != null && v < min ? min : (max != null && v > max ? max : v);

/// Reads and writes a value of a [PropType] declared as data: numbers,
/// booleans and text typed; enum values by name; a Flutter value type the
/// core models (`Color`, `EdgeInsets`, `TextStyle`...) as that model; other
/// values as their JSON.
final class JsonPropCodec extends PropCodec<Object?> {
  const JsonPropCodec(this.type);

  @override
  final PropType type;

  /// The value a non-nullable prop has without a default.
  Object? get zero => switch (type.kind) {
    PropKind.boolean => false,
    PropKind.integer => 0,
    PropKind.number => 0.0,
    PropKind.string => '',
    PropKind.enumeration => type.values.firstOrNull,
    PropKind.list => const <Object?>[],
    _ => null,
  };

  static final Map<String, PropCodec<Object?>> _models = {
    for (final c in <PropCodec<Object?>>[
      Codecs.color, Codecs.insets, Codecs.radius, Codecs.alignment, Codecs.offset, Codecs.constraints, //
      Codecs.textStyle, Codecs.borderSide, Codecs.paint,
    ])
      c.type.name: c,
  };

  @override
  Object? decode(Object? json) {
    if (json == null) return null;
    switch (type.kind) {
      case PropKind.boolean:
        return readBool(json);
      case PropKind.integer:
        final v = readInt(json);
        if (v == null) return null;
        return _clamp(v, type.min, type.max).toInt();
      case PropKind.number:
        final v = readDouble(json);
        if (v == null) return null;
        return _clamp(v, type.min, type.max).toDouble();
      case PropKind.string:
        return json is String ? json : (json is num || json is bool ? '$json' : null);
      case PropKind.enumeration:
        return json is String && type.values.contains(json) ? json : null;
      case PropKind.list:
        final item = JsonPropCodec(type.item ?? const PropType.json());
        return readList(json)?.map(item.decode).nonNulls.toList();
      case PropKind.value || PropKind.object:
        return _models[type.name]?.decode(json) ?? json;
      case PropKind.json:
        return json;
    }
  }

  @override
  Object? encode(Object? value) {
    if (value == null) return null;
    if (type.kind == PropKind.list && value is List) {
      final item = JsonPropCodec(type.item ?? const PropType.json());
      return [for (final v in value) item.encode(v)];
    }
    final model = type.kind == PropKind.list ? null : _models[type.name];
    if (model == null) return value;
    try {
      return model.encode(value);
    } catch (_) {
      return value;
    }
  }
}

/// The JSON of [spec]: its type, doc, child model, slots, whether it is
/// decorated, its props and what it reads from each child's layout.
Json widgetSpecToJson(WidgetSpec spec) => {
  'type': spec.type,
  if (spec.doc.isNotEmpty) 'doc': spec.doc,
  'children': spec.children.name,
  if (spec.slots.isNotEmpty) 'slots': spec.slots,
  if (spec.decorated) 'decorated': true,
  'props': [for (final p in spec.props) propDefToJson(p)],
  if (spec.childFields.isNotEmpty) 'childFields': [for (final p in spec.childFields) p.key],
  if (spec.events.isNotEmpty) 'events': [for (final e in spec.events) eventSpecToJson(e)],
  if (spec.states.isNotEmpty) 'states': spec.states,
  if (spec.hugs) 'hugs': true,
};

/// The JSON of [e]: `{"key", "payload": PropType, "doc"}`.
Json eventSpecToJson(EventSpec e) => {
  'key': e.key,
  if (e.payload case final p?) 'payload': propTypeToJson(p),
  if (e.doc.isNotEmpty) 'doc': e.doc,
};

/// An [EventSpec] from its JSON (or a bare key); null without a key.
EventSpec? eventSpecFromJson(Object? json) {
  if (json is String) return json.isEmpty ? null : EventSpec(json);
  final m = readMap(json);
  final key = readString(m?['key']);
  if (m == null || key == null || key.isEmpty) return null;
  return EventSpec(key, payload: m['payload'] == null ? null : propTypeFromJson(m['payload']), doc: readString(m['doc']) ?? '');
}

/// A [WidgetSpec] from its JSON; null without a type.
WidgetSpec? widgetSpecFromJson(Object? json) {
  final m = readMap(json);
  final type = readString(m?['type']);
  if (m == null || type == null || type.isEmpty) return null;
  return WidgetSpec(
    type,
    props: [...?readList(m['props'])?.map(propDefFromJson).nonNulls],
    children: readEnum(ChildModel.values, m['children'], ChildModel.none),
    slots: readStrings(m['slots']),
    decorated: readBool(m['decorated']) ?? false,
    doc: readString(m['doc']) ?? '',
    events: [...?readList(m['events'])?.map(eventSpecFromJson).nonNulls],
    states: readStrings(m['states']),
    hugs: readBool(m['hugs']) ?? false,
  );
}

/// The JSON of [spec]: type, label, doc, fields, result, nested chains and
/// required capabilities, and whether it has a Dart class (`typed`).
Json actionSpecToJson(ActionSpec spec) => {
  'type': spec.type,
  'label': spec.label,
  if (spec.doc.isNotEmpty) 'doc': spec.doc,
  'fields': [for (final f in spec.fields) propDefToJson(f)],
  if (spec.result case final r?) 'result': propTypeToJson(r, fields: true),
  if (spec.nested.isNotEmpty) 'nested': spec.nested,
  if (spec.requires.isNotEmpty) 'requires': spec.requires,
};

/// An [ActionSpec] from its JSON (no Dart class: it decodes as a
/// [DeclaredAction]); null without a type.
ActionSpec? actionSpecFromJson(Object? json) {
  final m = readMap(json);
  final type = readString(m?['type']);
  if (m == null || type == null || type.isEmpty) return null;
  return ActionSpec(
    type,
    label: readString(m['label']) ?? type,
    fields: [...?readList(m['fields'])?.map(propDefFromJson).nonNulls],
    doc: readString(m['doc']) ?? '',
    result: m['result'] == null ? null : propTypeFromJson(m['result']),
    nested: readStrings(m['nested']),
    requires: readStrings(m['requires']),
  );
}

Json dataSourceSpecToJson(DataSourceSpec s) => {
  'type': s.type,
  if (s.doc.isNotEmpty) 'doc': s.doc,
  'fields': [for (final f in s.fields) propDefToJson(f)],
  if (s.pages) 'pages': true,
  if (s.requires.isNotEmpty) 'requires': s.requires,
};

DataSourceSpec? dataSourceSpecFromJson(Object? json) {
  final m = readMap(json);
  final type = readString(m?['type']);
  if (m == null || type == null || type.isEmpty) return null;
  return DataSourceSpec(
    type,
    fields: [...?readList(m['fields'])?.map(propDefFromJson).nonNulls],
    pages: readBool(m['pages']) ?? false,
    requires: readStrings(m['requires']),
    doc: readString(m['doc']) ?? '',
  );
}

Json formulaSpecToJson(FormulaSpec f) => {
  'name': f.name,
  if (f.parameters.isNotEmpty) 'parameters': f.parameters,
  if (f.doc.isNotEmpty) 'doc': f.doc,
  'formula': ?f.formula,
};

FormulaSpec? formulaSpecFromJson(Object? json) {
  final m = readMap(json);
  final name = readString(m?['name']);
  if (m == null || name == null || name.isEmpty) return null;
  return FormulaSpec(
    name,
    parameters: readStrings(m['parameters']),
    doc: readString(m['doc']) ?? '',
    formula: readString(m['formula']),
  );
}

/// [catalog] as JSON (see `Catalog.toJson`).
Json catalogToJson(Catalog catalog, {bool compact = false}) {
  // Object value types, written once with their fields.
  final objects = <String, PropType>{};
  void collect(PropType t) {
    if (t.kind == PropKind.object && !objects.containsKey(t.name)) {
      objects[t.name] = t;
      for (final f in t.fields) {
        collect(f.type);
      }
    }
    if (t.item case final item?) collect(item);
  }

  final defs = [
    for (final w in catalog.widgets) ...w.props,
    for (final a in catalog.actions) ...a.fields,
    for (final d in catalog.dataSources) ...d.fields,
    ...LayoutFields.all, ...DecorationFields.all, ...NodeFields.all, ...BehaviorFields.all, //
  ];
  for (final d in defs) {
    collect(d.type);
  }
  Json shortDef(PropDef<Object?> d) =>
      compact ? {'key': d.key, 'type': d.type.typeName, 'default': _encodeDefault(d)} : propDefToJson(d);
  Json shortSpec(Json full, List<PropDef<Object?>> props, String key) =>
      compact ? {...full, key: [for (final p in props) shortDef(p)]} : full;
  return {
    if (catalog.id.isNotEmpty) 'id': catalog.id,
    if (catalog.instructions.isNotEmpty) 'instructions': catalog.instructions,
    'node': {
      'doc': 'Every node: id, type, name, children or slots, layout, decoration, props, bind, actions, behaviors.',
      'layout': [for (final f in LayoutFields.all) shortDef(f)],
      'decoration': [for (final f in DecorationFields.all) shortDef(f)],
      'node': [for (final f in NodeFields.all) shortDef(f)],
      'behaviors': [for (final f in BehaviorFields.all) shortDef(f)],
    },
    'widgets': [for (final w in catalog.widgets) shortSpec(widgetSpecToJson(w), w.props, 'props')],
    'actions': {
      'common': [for (final f in ActionCommonFields.all) shortDef(f)],
      'types': [for (final a in catalog.actions) shortSpec(actionSpecToJson(a), a.fields, 'fields')],
    },
    'triggers': {
      'types': [for (final t in TriggerType.values) t.name],
      'fields': [for (final f in TriggerFields.all) shortDef(f)],
    },
    if (catalog.dataSources.isNotEmpty) 'dataSources': [for (final d in catalog.dataSources) dataSourceSpecToJson(d)],
    if (catalog.formulas.isNotEmpty) 'formulas': [for (final f in catalog.formulas) formulaSpecToJson(f)],
    if (!compact)
      'valueTypes': {
        for (final t in objects.values) t.name: [for (final f in t.fields) propDefToJson(f)],
      },
  };
}

/// A catalog of declarations read from JSON (`widgets`, `actions`,
/// `dataSources`, `formulas`, `instructions`); entries without a type are
/// left out. Its actions have no Dart class: they decode as
/// [DeclaredAction]s.
Catalog catalogFromJson(Object? json) {
  final m = readMap(json) ?? const {};
  final actions = m['actions'];
  return Catalog(
    id: readString(m['id']) ?? '',
    widgets: [...?readList(m['widgets'])?.map(widgetSpecFromJson).nonNulls],
    actions: [...?readList(actions is Map ? actions['types'] : actions)?.map(actionSpecFromJson).nonNulls],
    dataSources: [...?readList(m['dataSources'])?.map(dataSourceSpecFromJson).nonNulls],
    formulas: [...?readList(m['formulas'])?.map(formulaSpecFromJson).nonNulls],
    instructions: readString(m['instructions']) ?? '',
  );
}
