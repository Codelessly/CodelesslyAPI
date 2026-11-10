// Cloud data as data: collection queries (filters, sorts, paging), the typed
// fields of a collection, and who can read and write each collection.
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../json.dart';

const _listEq = ListEquality<Object?>();

/// A where filter's comparison, Firestore's operators.
enum WhereOperator {
  equal('=='),
  notEqual('!='),
  lessThan('<'),
  lessThanOrEqual('<='),
  greaterThan('>'),
  greaterThanOrEqual('>='),
  arrayContains('array-contains'),
  arrayContainsAny('array-contains-any'),
  inArray('in'),
  notInArray('not-in');

  const WhereOperator(this.symbol);

  /// The operator as Firestore writes it.
  final String symbol;

  /// `<`, `<=`, `>`, `>=`.
  bool get isRange => this == lessThan || this == lessThanOrEqual || this == greaterThan || this == greaterThanOrEqual;

  /// Range filters, `!=` and `not-in`: they need an index on their field.
  bool get isInequality => isRange || this == notEqual || this == notInArray;

  /// `==`, `array-contains`, `array-contains-any`, `in`.
  bool get isEquality => this == equal || this == arrayContains || this == arrayContainsAny || this == inArray;

  /// Whether the compared value is a list (`in`, `not-in`,
  /// `array-contains-any`).
  bool get takesList => this == inArray || this == notInArray || this == arrayContainsAny;
}

/// One filter of a query. [value] is text that may hold `${...}`
/// expressions; the SDK evaluates it when the query runs.
@immutable
final class WhereFilter {
  const WhereFilter(this.field, this.operator, this.value);

  /// The dotted field path.
  final String field;
  final WhereOperator operator;
  final String value;

  static WhereFilter? fromJson(Object? json) {
    final m = readMap(json);
    final field = readString(m?['field']);
    if (m == null || field == null) return null;
    final value = m['value'];
    return WhereFilter(
      field,
      readEnum(WhereOperator.values, m['operator'], WhereOperator.equal),
      value is String ? value : (value == null ? '' : '$value'),
    );
  }

  Json toJson() => {'field': field, 'operator': operator.name, 'value': value};

  @override
  bool operator ==(Object other) =>
      other is WhereFilter && other.field == field && other.operator == operator && other.value == value;

  @override
  int get hashCode => Object.hash(field, operator, value);

  @override
  String toString() => '$field ${operator.symbol} $value';
}

/// One sort of a query.
@immutable
final class OrderBy {
  const OrderBy(this.field, {this.descending = false});

  final String field;
  final bool descending;

  static OrderBy? fromJson(Object? json) {
    final m = readMap(json);
    final field = readString(m?['field']);
    if (m == null || field == null) return null;
    return OrderBy(field, descending: m['sortOrder'] == 'descending' || readBool(m['descending']) == true);
  }

  Json toJson() => {'field': field, if (descending) 'sortOrder': 'descending'};

  @override
  bool operator ==(Object other) => other is OrderBy && other.field == field && other.descending == descending;

  @override
  int get hashCode => Object.hash(field, descending);

  @override
  String toString() => '$field ${descending ? 'desc' : 'asc'}';
}

/// How a list loads the pages after its first.
enum QueryPaging {
  /// The next page loads when the end of the list scrolls into view.
  scroll,

  /// A "Show more" button after the last item loads the next page.
  button,
}

/// A query of a cloud collection, as a data-bound list (`listView.query`)
/// or a cloud data action stores it:
///
/// ```json
/// {"enabled": true, "collectionPath": "tasks", "limit": 20,
///  "whereFilters": [{"field": "done", "operator": "equal", "value": "false"}],
///  "orderByFilters": [{"field": "due", "sortOrder": "descending"}],
///  "loadRelated": ["author"]}
/// ```
@immutable
final class CloudQueryDef {
  const CloudQueryDef({
    this.enabled = false,
    this.collectionPath = '',
    this.where = const [],
    this.orderBy = const [],
    this.limit,
    this.paging = QueryPaging.scroll,
    this.loadRelated = const [],
    this.extra = const {},
  });

  /// Whether the list reads from the cloud database.
  final bool enabled;

  /// The collection's path (`users/${auth.uid}/tasks`); may hold `${...}`.
  final String collectionPath;
  final List<WhereFilter> where;
  final List<OrderBy> orderBy;

  /// Documents per page; null for all.
  final int? limit;
  final QueryPaging paging;

  /// Reference fields whose documents load with each result.
  final List<String> loadRelated;

  /// Keys this version doesn't model (a status variable...), kept.
  final Json extra;

  bool get isEmpty => !enabled && collectionPath.isEmpty;

  static const _keys = {'enabled', 'collectionPath', 'whereFilters', 'orderByFilters', 'limit', 'paging', 'loadRelated'};

  static CloudQueryDef fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    final limit = readInt(m['limit']);
    return CloudQueryDef(
      enabled: readBool(m['enabled']) ?? false,
      collectionPath: readString(m['collectionPath']) ?? '',
      where: [...?readList(m['whereFilters'])?.map(WhereFilter.fromJson).nonNulls],
      orderBy: [...?readList(m['orderByFilters'])?.map(OrderBy.fromJson).nonNulls],
      limit: limit != null && limit > 0 ? limit : null,
      paging: readEnum(QueryPaging.values, m['paging'], QueryPaging.scroll),
      loadRelated: readStrings(m['loadRelated']),
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  Json toJson() => {
        if (enabled) 'enabled': true,
        if (collectionPath.isNotEmpty) 'collectionPath': collectionPath,
        if (where.isNotEmpty) 'whereFilters': [for (final w in where) w.toJson()],
        if (orderBy.isNotEmpty) 'orderByFilters': [for (final o in orderBy) o.toJson()],
        'limit': ?limit,
        if (paging != QueryPaging.scroll) 'paging': paging.name,
        if (loadRelated.isNotEmpty) 'loadRelated': loadRelated,
        ...extra,
      };

  @override
  bool operator ==(Object other) => other is CloudQueryDef && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());

  @override
  String toString() => 'CloudQueryDef(${toJson()})';
}

/// The type of a collection field.
enum SchemaFieldType {
  text,
  number,
  boolean,

  /// A date and time (a Firestore timestamp).
  date,

  /// The URL of an image.
  image,

  /// The URL of a file.
  file,

  /// The id of a document in [SchemaField.referenceCollection].
  reference,
  list,
  object,
}

/// A typed field of a collection.
@immutable
final class SchemaField {
  const SchemaField(this.name, {this.type = SchemaFieldType.text, this.required = false, this.defaultValue, this.referenceCollection});

  final String name;
  final SchemaFieldType type;

  /// Whether creating a document needs a value (or [defaultValue]).
  final bool required;

  /// What a new document gets when none is given, as text (`true`, `12`,
  /// `now` for a date).
  final String? defaultValue;

  /// The collection a [SchemaFieldType.reference] points into.
  final String? referenceCollection;

  static SchemaField? fromJson(Object? json) {
    final m = readMap(json);
    final name = readString(m?['name']);
    if (m == null || name == null || name.isEmpty) return null;
    return SchemaField(
      name,
      type: readEnum(SchemaFieldType.values, m['type'], SchemaFieldType.text),
      required: readBool(m['required']) ?? false,
      defaultValue: readString(m['defaultValue']),
      referenceCollection: readString(m['referenceCollection']),
    );
  }

  Json toJson() => {
        'name': name,
        if (type != SchemaFieldType.text) 'type': type.name,
        if (required) 'required': true,
        'defaultValue': ?defaultValue,
        'referenceCollection': ?referenceCollection,
      };

  SchemaField copyWith({bool? required}) => SchemaField(name,
      type: type, required: required ?? this.required, defaultValue: defaultValue, referenceCollection: referenceCollection);

  @override
  bool operator ==(Object other) =>
      other is SchemaField &&
      other.name == name &&
      other.type == type &&
      other.required == required &&
      other.defaultValue == defaultValue &&
      other.referenceCollection == referenceCollection;

  @override
  int get hashCode => Object.hash(name, type, required, defaultValue, referenceCollection);
}

/// The typed fields of a collection.
@immutable
final class CollectionSchema {
  const CollectionSchema(this.name, {this.fields = const []});

  /// The collection's name.
  final String name;
  final List<SchemaField> fields;

  SchemaField? field(String name) => fields.firstWhereOrNull((f) => f.name == name);

  static CollectionSchema? fromJson(Object? json, {String? name}) {
    final m = readMap(json);
    final n = name ?? readString(m?['name']);
    if (m == null || n == null) return null;
    return CollectionSchema(n, fields: [...?readList(m['fields'])?.map(SchemaField.fromJson).nonNulls]);
  }

  Json toJson() => {'name': name, if (fields.isNotEmpty) 'fields': [for (final f in fields) f.toJson()]};

  @override
  bool operator ==(Object other) => other is CollectionSchema && other.name == name && _listEq.equals(other.fields, fields);

  @override
  int get hashCode => Object.hash(name, _listEq.hash(fields));
}

/// Who can read and write a collection.
enum DataRule {
  /// Anyone using the app. The default.
  app,

  /// Signed-in users only.
  signedIn,

  /// Each signed-in user reads and writes only their own documents.
  owner,

  /// Anyone reads; signed-in users write their own documents.
  publicReadOwnerWrite,

  /// Anyone reads; users with the collection's role write.
  roleWrite;

  /// Whether writes record the signed-in user as the document's owner.
  bool get stampsOwner => this == owner || this == publicReadOwnerWrite;

  /// Whether reads return only the signed-in user's documents.
  bool get readsOwnOnly => this == owner;

  /// Whether writing needs a signed-in user.
  bool get writeNeedsSignIn => this != app;
}

/// The rules, schemas, composite indexes and write roles of a project's
/// collections.
@immutable
final class DataRules {
  const DataRules({this.collections = const {}, this.schemas = const {}, this.indexes = const {}, this.roles = const {}});

  /// The field holding the uid of the user who owns a document.
  static const ownerField = 'ownerId';

  /// Top-level collection → rule; unlisted collections are [DataRule.app].
  final Map<String, DataRule> collections;

  /// Collection name → its fields.
  final Map<String, CollectionSchema> schemas;

  /// Collection name → keys of the composite indexes it has
  /// (`field:asc,other:desc`).
  final Map<String, Set<String>> indexes;

  /// Collection name → the role a user needs to write it
  /// ([DataRule.roleWrite]).
  final Map<String, String> roles;

  static DataRules fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    return DataRules(
      collections: {
        for (final e in (readMap(m['collections']) ?? const {}).entries)
          if (DataRule.values.asNameMap()[e.value] case final DataRule r) e.key: r,
      },
      schemas: {
        for (final e in (readMap(m['schemas']) ?? const {}).entries)
          if (CollectionSchema.fromJson(e.value, name: e.key) case final CollectionSchema s) e.key: s,
      },
      indexes: {
        for (final e in (readMap(m['indexes']) ?? const {}).entries)
          if (readList(e.value) case final List<Object?> keys) e.key: {for (final k in keys) '$k'},
      },
      roles: {
        for (final e in (readMap(m['roles']) ?? const {}).entries)
          if (e.value case final String r) e.key: r,
      },
    );
  }

  Json toJson() => {
        if (collections.isNotEmpty) 'collections': {for (final e in collections.entries) e.key: e.value.name},
        if (schemas.isNotEmpty)
          'schemas': {for (final e in schemas.entries) e.key: e.value.toJson()..remove('name')},
        if (indexes.isNotEmpty) 'indexes': {for (final e in indexes.entries) e.key: e.value.toList()},
        if (roles.isNotEmpty) 'roles': roles,
      };

  static final _separator = RegExp(r'[./]');

  /// The top-level collection of [path], which rules are set on.
  static String topCollection(String path) {
    final first = path.trim().split(_separator).first.trim();
    return first.isEmpty ? 'default' : first;
  }

  /// The collection [path] names: its last collection (`tasks` for
  /// `users/u1/tasks`). `${...}` counts as one segment.
  static String? collectionName(String path) {
    final plain = path.trim().replaceAll(RegExp(r'\$\{[^}]*\}'), '_');
    final parts = [
      for (final p in plain.split(_separator))
        if (p.trim().isNotEmpty) p.trim(),
    ];
    return parts.isEmpty ? null : parts[(parts.length - 1) - (parts.length - 1) % 2];
  }

  /// The rule for documents under [path].
  DataRule ruleFor(String path) => collections[topCollection(path)] ?? DataRule.app;

  /// The schema of the collection [path] names, else of its top collection.
  CollectionSchema? schemaFor(String path) => schemas[collectionName(path)] ?? schemas[topCollection(path)];

  /// The composite indexes ready for the collection [path] names.
  Set<String> readyIndexesFor(String path) => indexes[collectionName(path)] ?? const {};

  @override
  bool operator ==(Object other) => other is DataRules && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}
