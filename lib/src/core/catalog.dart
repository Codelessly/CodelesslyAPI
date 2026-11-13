// The catalog: what a document may contain. Node types (WidgetSpec), action
// types (ActionSpec), data sources and formula functions, each declared once
// with its fields, so decoding, encoding, an editor's panels, validation and
// the catalog export all read the same declaration (DESIGN.md §8).
//
// A Catalog is an immutable value passed to decoding; it is composed (`+`,
// `parts`), never mutated. A type the catalog doesn't declare still decodes
// and round-trips: a node keeps its props raw (`Props.unknown`), an action is
// an `UnknownAction`.
import 'dart:async';

import 'package:meta/meta.dart';

import 'actions.dart';
import 'catalog_json.dart';
import 'conditions.dart';
import 'json.dart';
import 'props.dart';
import 'widgets/widgets.dart' show coreWidgetSpecs;

/// What a document may contain: declared node types, action types, data
/// sources and formula functions. Immutable; composed with `+` or [parts],
/// never mutated.
///
/// ```dart
/// const acme = Catalog(id: 'acme', widgets: [RatingProps.spec], actions: [ShareAction.spec]);
/// final doc = LayoutDocument.fromJson(json, catalog: standardCatalog + acme);
/// ```
///
/// [Catalog.core] is the core library's; each feature library exports its
/// own (`dataCatalog`, `mediaCatalog`...) and `standardCatalog` is their sum.
///
/// Later entries win by type name, so a plugin can replace a declaration.
@immutable
final class Catalog {
  const Catalog({
    this.id = '',
    this._widgets = const [],
    this._actions = const [],
    this._dataSources = const [],
    this._formulas = const [],
    this.instructions = '',
    this.parts = const [],
  });

  /// The core: node types, layout, decoration, behaviors, triggers and the
  /// core actions.
  static const Catalog core = Catalog(id: 'core', widgets: coreWidgetSpecs, actions: coreActionSpecs, dataSources: [listDataSource]);

  /// A name for messages and the export (`core`, `data`, `acme`).
  final String id;

  /// Catalogs this one is made of, before its own entries.
  final List<Catalog> parts;

  /// Authoring notes for agents and editors (the export carries them).
  final String instructions;

  final List<WidgetSpec> _widgets;
  final List<ActionSpec> _actions;
  final List<DataSourceSpec> _dataSources;
  final List<FormulaSpec> _formulas;

  /// The catalog a decoder uses when it is given none: the one an
  /// enclosing decoder was given (it enters it for the decode, so a reaction
  /// inside a prop decodes with it too) or [run] set; else [Catalog.core].
  /// The core knows no feature library, so code that reads feature types
  /// passes the catalog it was built with (`standardCatalog` from
  /// `package:codelessly_api/codelessly_api.dart`, or the SDK's).
  ///
  /// This is a scope, not a registry: it holds only for the duration of the
  /// decode (or [run]) that set it.
  static Catalog get current => (Zone.current[_zoneKey] as Catalog?) ?? core;

  static final Object _zoneKey = Object();

  /// Runs [body] with [catalog] as [current].
  static R run<R>(Catalog catalog, R Function() body) =>
      identical(current, catalog) ? body() : runZoned(body, zoneValues: {_zoneKey: catalog});

  /// Every node type, [parts] first; a later declaration of a type replaces
  /// an earlier one in place.
  List<WidgetSpec> get widgets => _index.widgets;

  /// Every action type, as [widgets].
  List<ActionSpec> get actions => _index.actions;

  /// Every data source type, as [widgets].
  List<DataSourceSpec> get dataSources => _index.dataSources;

  /// Every formula function, as [widgets].
  List<FormulaSpec> get formulas => _index.formulas;

  /// The declaration of node type [type], or null when this catalog
  /// doesn't declare it.
  WidgetSpec? widget(String type) => _index.widgetsByType[type];

  /// The declaration of action type [type], or null.
  ActionSpec? action(String type) => _index.actionsByType[type];

  /// The declaration of data source type [type], or null.
  DataSourceSpec? dataSource(String type) => _index.dataSourcesByType[type];

  /// The formula function named [name], or null.
  FormulaSpec? formula(String name) => _index.formulasByName[name];

  /// The catalog as JSON, for the generated reference, editors and agents:
  /// every node type with its props (key, kind, Flutter type, default,
  /// enum values, bounds, doc), child model and slots; the node envelope
  /// (layout, decoration, behaviors) once; action types with their fields,
  /// result, nested chains and required capabilities; the trigger types;
  /// data sources; formula functions; the object value types' fields; and
  /// [instructions]. [compact] keeps each prop to key, type name and
  /// default. [Catalog.fromJson] reads the declarations back.
  Json toJson({bool compact = false}) => catalogToJson(this, compact: compact);

  /// Declarations read from JSON (a hosted plugin's `catalog`, a native
  /// plugin's manifest, or [toJson]'s output): node types, action types
  /// (decoding as [DeclaredAction]s), data sources and formula functions.
  static Catalog fromJson(Object? json) => catalogFromJson(json);

  /// Whether this catalog declares every type [other] declares, with the same
  /// declaration: a document decoded with this one needs no decoding again
  /// for [other].
  bool includes(Catalog other) {
    if (identical(this, other)) return true;
    for (final w in other.widgets) {
      if (!identical(widget(w.type), w)) return false;
    }
    for (final a in other.actions) {
      if (!identical(action(a.type), a)) return false;
    }
    return true;
  }

  /// This catalog with [other]'s entries after (and over) its own.
  Catalog operator +(Catalog other) => Catalog(id: id.isEmpty ? other.id : id, parts: [this, other]);

  /// Decodes an action JSON object with this catalog (the action's own
  /// fields); null for anything that isn't an object with a type. A type this
  /// catalog doesn't declare is an [UnknownAction].
  ActionDef? decodeAction(Object? json) => ActionDef.fromJson(json, catalog: this);

  /// [action] decoded with this catalog when it is an [UnknownAction] this
  /// catalog declares (an action decoded with a smaller catalog); else
  /// [action] itself.
  ActionDef upgrade(ActionDef action) {
    if (action is! UnknownAction || this.action(action.type) == null) return action;
    return decodeAction(action.toJson()) ?? action;
  }

  static final Expando<_Index> _indexes = Expando('Catalog index');

  _Index get _index => _indexes[this] ??= _Index(this);

  @override
  String toString() => 'Catalog(${id.isEmpty ? '' : '$id: '}${widgets.length} widgets, ${actions.length} actions)';
}

/// A catalog's entries, flattened and indexed once per catalog.
final class _Index {
  _Index(Catalog catalog) {
    void add(Catalog c) {
      for (final p in c.parts) {
        add(p);
      }
      for (final w in c._widgets) {
        widgetsByType[w.type] = w;
      }
      for (final a in c._actions) {
        actionsByType[a.type] = a;
      }
      for (final d in c._dataSources) {
        dataSourcesByType[d.type] = d;
      }
      for (final f in c._formulas) {
        formulasByName[f.name] = f;
      }
    }

    add(catalog);
    widgets = List.unmodifiable(widgetsByType.values);
    actions = List.unmodifiable(actionsByType.values);
    dataSources = List.unmodifiable(dataSourcesByType.values);
    formulas = List.unmodifiable(formulasByName.values);
  }

  final Map<String, WidgetSpec> widgetsByType = {};
  final Map<String, ActionSpec> actionsByType = {};
  final Map<String, DataSourceSpec> dataSourcesByType = {};
  final Map<String, FormulaSpec> formulasByName = {};
  late final List<WidgetSpec> widgets;
  late final List<ActionSpec> actions;
  late final List<DataSourceSpec> dataSources;
  late final List<FormulaSpec> formulas;
}

/// The fields every action has, read from its JSON: what an
/// [ActionSpec.decode] passes on to the action's constructor.
final class ActionCommon {
  ActionCommon(Json m, {Catalog? catalog})
      : enabled = readBool(m['enabled']) ?? true,
        nonBlocking = readBool(m['nonBlocking']) ?? false,
        when = Predicate.fromJson(m['when']),
        catalog = catalog ?? Catalog.current;

  final bool enabled, nonBlocking;
  final Predicate? when;

  /// The catalog the action is decoded with (nested chains use it).
  final Catalog catalog;
}

/// Decodes one action type's JSON ([json] is the whole object).
typedef ActionDecoder = ActionDef Function(Json json, ActionCommon common);

/// The declaration of one action type: what a `WidgetSpec` is to a node.
/// Its [fields] generate an editor's panel and validate; [decode] makes the
/// typed action. Without [decode] (a type declared as data, by a hosted or
/// native plugin manifest) the action decodes as a [DeclaredAction] holding
/// its fields as [Props].
@immutable
final class ActionSpec {
  const ActionSpec(
    this.type, {
    required this.label,
    required this.fields,
    this.doc = '',
    this.decode,
    this.result,
    this.nested = const [],
    this.requires = const [],
  });

  /// The JSON `type` (`ActionDef.type`).
  final String type;
  final String label;

  /// Its own fields (not `ActionCommonFields`).
  final List<PropDef<Object?>> fields;
  final String doc;

  /// Makes the typed action; null: a [DeclaredAction].
  final ActionDecoder? decode;

  /// What `${result}` holds after it, when it gives one.
  final PropType? result;

  /// The keys of [fields] that hold nested action lists (`then`, `onError`).
  final List<String> nested;

  /// The capabilities it needs (`api`, `cloud`, `auth`, `storage`, `sound`...).
  final List<String> requires;

  PropDef<Object?>? field(String key) {
    for (final f in fields) {
      if (f.key == key) return f;
    }
    return null;
  }

  /// The fields as a record declaration (what [Props] decode with).
  WidgetSpec get fieldSpec => _fieldSpecs[this] ??= WidgetSpec(type, props: fields, doc: doc);
  static final Expando<WidgetSpec> _fieldSpecs = Expando();

  @override
  String toString() => 'ActionSpec($type)';
}

/// A kind of data a list, grid or pagination can load from, declared like a
/// widget so its settings get a panel: `data` (the bound list) in the core,
/// `cloud` and `api` in the data library.
@immutable
final class DataSourceSpec {
  const DataSourceSpec(this.type, {required this.fields, this.pages = false, this.requires = const [], this.doc = ''});

  final String type;
  final List<PropDef<Object?>> fields;

  /// Whether it can serve pagination.
  final bool pages;
  final List<String> requires;
  final String doc;

  @override
  String toString() => 'DataSourceSpec($type)';
}

/// A formula function: its name, parameters and what it does. A built-in
/// one (the expression engine's) or a plugin's (a function variable).
@immutable
final class FormulaSpec {
  const FormulaSpec(this.name, {this.parameters = const [], this.doc = '', this.formula});

  final String name;
  final List<String> parameters;
  final String doc;

  /// A plugin's implementation as a formula over [parameters]; null for a
  /// function the host implements.
  final String? formula;

  @override
  String toString() => 'FormulaSpec($name)';
}

/// The core's data source: the list bound to a list's `data` (or its item
/// count). The data library adds `cloud` and `api`.
const listDataSource = DataSourceSpec('data', fields: [], doc: 'The bound list: the items a binding gives the list.');

/// [Catalog.core]: the core's node types and actions.
const Catalog coreCatalog = Catalog.core;
