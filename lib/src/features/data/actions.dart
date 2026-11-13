// The data library's action types: APIs, storage, cloud data and files, form submissions. One immutable
// class per type, decoded through its ActionSpec ([dataActionSpecs]); the
// SDK's data feature runs them.

import 'package:meta/meta.dart';

import 'action_fields.dart';
import '../../core/actions.dart';
import '../../core/catalog.dart';
import '../../core/json.dart';
import '../../core/variables.dart';
import 'cloud.dart';

/// The fields every action has.
typedef _Common = ActionCommon;

// Reading an action's fields: the core's rules (core/actions.dart).
String _s(Json m, String k, [String def = '']) => switch (m[k]) {
  final String s => s,
  final num n => '$n',
  final bool b => '$b',
  _ => def,
};
double _d(Json m, String k, double def) => readDouble(m[k]) ?? def;
bool _b(Json m, String k, bool def) => readBool(m[k]) ?? def;
T _e<T extends Enum>(List<T> values, Json m, String k, T def) => readEnum(values, m[k], def);
List<ActionDef> _list(Json m, String k) => ActionDef.listFromJson(m[k]);
Json _map(Json m, String k) => readMap(m[k]) ?? const {};
List<Json> _actionsJson(List<ActionDef> l) => [for (final a in l) a.toJson()];

/// Where a form goes.
enum FormService {
  /// Validated and stored in the app's own variables; no network.
  local,

  /// A service this version doesn't run: a submission saved by an older
  /// version with a built-in third-party integration that has since been
  /// removed, or one from a newer version. It decodes so the layout still
  /// loads, and fails without sending anything when it runs (a runtime
  /// reports it as the action's error). It is never offered for new actions.
  unsupported,
}

/// Validates a form's answers and stores them in the app's own variables
/// (`service: local`). See `docs/submit_form.md`.
///
/// A remote destination is an explicit later action (`callApi` in
/// [onSuccess]) to an endpoint the app defines; this action itself never
/// calls a service.
final class SubmitFormAction extends DataAction {
  const SubmitFormAction({
    this.service = FormService.local,
    this.payload = '',
    this.validationScript = '',
    this.validationArguments = const {},
    this.responseVariable = '',
    this.prepend = false,
    this.resultVariable = '',
    this.onSuccess = const [],
    this.onError = const [],
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'submitForm';
  @override
  String get type => typeName;

  final FormService service;

  /// An expression yielding a JSON object. An awaited validator may replace
  /// it with its normalized `payload`.
  final String payload, validationScript, responseVariable, resultVariable;
  final Map<String, String> validationArguments;
  final bool prepend;
  final List<ActionDef> onSuccess, onError;

  @override
  List<ActionDef> get nested => [...onSuccess, ...onError];

  /// Older layouts' newsletter submissions: `service` other than `local`,
  /// or no `service` with the removed provider settings. Their credentials
  /// and field ids are read past, never kept.
  static const _legacyKeys = ['apiKey', 'dataCenter', 'listId', 'emailField', 'firstNameField', 'lastNameField'];

  static FormService _service(Json m) {
    final s = m['service'];
    if (s == null) return _legacyKeys.any(m.containsKey) ? FormService.unsupported : FormService.local;
    return s == FormService.local.name ? FormService.local : FormService.unsupported;
  }

  static SubmitFormAction _fromJson(Json m, _Common c) => SubmitFormAction(
    service: _service(m),
    payload: _s(m, 'payload'),
    validationScript: _s(m, 'validationScript'),
    validationArguments: {for (final e in _map(m, 'validationArguments').entries) if (e.value != null) e.key: '${e.value}'},
    responseVariable: _s(m, 'responseVariable'),
    prepend: _b(m, 'prepend', false),
    resultVariable: _s(m, 'resultVariable'),
    onSuccess: _list(m, 'onSuccess'),
    onError: _list(m, 'onError'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {
    'service': service.name,
    if (payload.isNotEmpty) 'payload': payload,
    if (validationScript.isNotEmpty) 'validationScript': validationScript,
    if (validationArguments.isNotEmpty) 'validationArguments': validationArguments,
    if (responseVariable.isNotEmpty) 'responseVariable': responseVariable,
    if (prepend) 'prepend': true,
    if (resultVariable.isNotEmpty) 'resultVariable': resultVariable,
    if (onSuccess.isNotEmpty) 'onSuccess': _actionsJson(onSuccess),
    if (onError.isNotEmpty) 'onError': _actionsJson(onError),
  };
}

/// The data library's action types: APIs, storage, cloud data and files, form submissions.
sealed class DataAction extends ActionDef {
  const DataAction({super.enabled, super.nonBlocking, super.when});
}

/// Calls API [api] (the publish model's `services.apis`) with [params], its
/// inputs (expressions; an empty one takes the input's default). Then
/// [onSuccess] runs after a 2xx response, [onError] after any other or a
/// failed request, both reading the response as `${result}`. A failed
/// request without [onError] stops the chain.
final class CallApiAction extends DataAction {
  const CallApiAction({
    this.api = '',
    this.params = const {},
    this.onSuccess = const [],
    this.onError = const [],
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'callApi';
  @override
  String get type => typeName;

  final String api;
  final Map<String, String> params;
  final List<ActionDef> onSuccess, onError;

  @override
  List<ActionDef> get nested => [...onSuccess, ...onError];

  static CallApiAction _fromJson(Json m, _Common c) => CallApiAction(
    api: _s(m, 'api'),
    params: {
      for (final e in _map(m, 'params').entries) e.key: e.value is String ? e.value as String : '${e.value ?? ''}',
    },
    onSuccess: _list(m, 'onSuccess'),
    onError: _list(m, 'onError'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {
    'api': api,
    if (params.isNotEmpty) 'params': params,
    if (onSuccess.isNotEmpty) 'onSuccess': _actionsJson(onSuccess),
    if (onError.isNotEmpty) 'onError': _actionsJson(onError),
  };
}

/// What a [SetStorageAction] does.
enum StorageOperation {
  /// Writes key [SetStorageAction.key] ([SetStorageAction.write]).
  write,

  /// Removes the key.
  remove,

  /// Removes every key.
  clear,
}

/// Changes the app's values on the device (read as `${storage.<key>}`). A
/// key may be a path (`prefs.theme`) into a stored map or list.
final class SetStorageAction extends DataAction {
  const SetStorageAction({
    this.operation = StorageOperation.write,
    this.key = '',
    this.valueType = VariableType.text,
    this.write = const ValueWrite(),
    this.skipIfExists = false,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'setStorage';
  @override
  String get type => typeName;

  final StorageOperation operation;
  final String key;

  /// How the written value is read.
  final VariableType valueType;
  final ValueWrite write;

  /// Leaves a key that has a value.
  final bool skipIfExists;

  static SetStorageAction _fromJson(Json m, _Common c) => SetStorageAction(
    operation: _e(StorageOperation.values, m, 'operation', StorageOperation.write),
    key: _s(m, 'key'),
    valueType: _e(VariableType.values, m, 'valueType', VariableType.text),
    write: ValueWrite.fromJson(m),
    skipIfExists: _b(m, 'skipIfExists', false),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {
    if (operation != StorageOperation.write) 'operation': operation.name,
    if (operation != StorageOperation.clear) 'key': key,
    if (operation == StorageOperation.write) ...{
      if (valueType != VariableType.text) 'valueType': valueType.name,
      ...write.toJson(),
      if (skipIfExists) 'skipIfExists': true,
    },
  };
}

/// What a [CloudDocumentsAction] writes.
enum CloudDocumentsOperation {
  /// Adds document [CloudDocumentsAction.value] (a JSON object).
  add,

  /// Changes field [CloudDocumentsAction.field] of a document.
  update,

  /// Removes a document.
  remove,

  /// Removes the documents with [CloudDocumentsAction.ids], or those
  /// matching [CloudDocumentsAction.where] (all, without).
  removeMany,

  /// Writes the list of documents [CloudDocumentsAction.value].
  setMany,
}

/// Writes documents of a cloud collection: one at a time by id, or many at
/// once.
final class CloudDocumentsAction extends DataAction {
  const CloudDocumentsAction({
    this.operation = CloudDocumentsOperation.add,
    this.path = '',
    this.id = '',
    this.autoId = false,
    this.skipIfExists = true,
    this.value = '',
    this.raw = false,
    this.field = '',
    this.valueType = VariableType.text,
    this.write = const ValueWrite(),
    this.ids = '',
    this.where = const [],
    this.idField = 'id',
    this.merge = false,
    this.replaceCollection = false,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'cloudDocuments';
  @override
  String get type => typeName;

  final CloudDocumentsOperation operation;

  /// The collection path (an expression).
  final String path;

  /// The document id (an expression).
  final String id;

  /// [CloudDocumentsOperation.add]: a generated id.
  final bool autoId;
  final bool skipIfExists;

  /// The document ([CloudDocumentsOperation.add]) or list of documents
  /// ([CloudDocumentsOperation.setMany]): an expression, or JSON text.
  final String value;

  /// [value] is taken as written: no expressions.
  final bool raw;

  /// [CloudDocumentsOperation.update]: the field (a path) and how it changes.
  final String field;
  final VariableType valueType;
  final ValueWrite write;

  /// [CloudDocumentsOperation.removeMany]: ids, comma separated or a list
  /// (an expression).
  final String ids;
  final List<WhereFilter> where;
  final String idField;
  final bool merge, replaceCollection;

  static CloudDocumentsAction _fromJson(Json m, _Common c) => CloudDocumentsAction(
    operation: _e(CloudDocumentsOperation.values, m, 'operation', CloudDocumentsOperation.add),
    path: _s(m, 'path'),
    id: _s(m, 'id'),
    autoId: _b(m, 'autoId', false),
    skipIfExists: _b(m, 'skipIfExists', true),
    value: _s(m, 'document'),
    raw: _b(m, 'raw', false),
    field: _s(m, 'field'),
    valueType: _e(VariableType.values, m, 'valueType', VariableType.text),
    write: ValueWrite.fromJson(m),
    ids: _s(m, 'ids'),
    where: [...?readList(m['whereFilters'])?.map(WhereFilter.fromJson).nonNulls],
    idField: _s(m, 'idField', 'id'),
    merge: _b(m, 'merge', false),
    replaceCollection: _b(m, 'replaceCollection', false),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {
    'operation': operation.name,
    'path': path,
    if (id.isNotEmpty) 'id': id,
    if (autoId) 'autoId': true,
    if (operation == CloudDocumentsOperation.add && !skipIfExists) 'skipIfExists': false,
    if (value.isNotEmpty) 'document': value,
    if (raw) 'raw': true,
    if (operation == CloudDocumentsOperation.update) ...{
      'field': field,
      if (valueType != VariableType.text) 'valueType': valueType.name,
      ...write.toJson(),
    },
    if (ids.isNotEmpty) 'ids': ids,
    if (where.isNotEmpty) 'whereFilters': [for (final w in where) w.toJson()],
    if (idField != 'id') 'idField': idField,
    if (merge) 'merge': true,
    if (replaceCollection) 'replaceCollection': true,
  };
}

/// What a [LoadCloudDataAction] keeps in its variable instead of the
/// documents: a number computed by the database over the query.
enum CloudLoadAggregate {
  /// The documents (or the document).
  none,

  /// How many documents match.
  count,

  /// The sum of [LoadCloudDataAction.aggregateField] over them.
  sum,

  /// Its average.
  average,
}

/// The most documents a [LoadCloudDataAction] query loads when neither the
/// action nor its query gives a limit.
const int kDefaultCloudLoadLimit = 500;

/// Streams a cloud document, or a collection query's documents, into
/// variable [variable] while the screen shows: `{status: loading|loaded|
/// error, isLoading, data, error, hasMore}`. A variable of type list gets
/// the documents themselves, and with an [aggregate], a number variable the
/// number. Blocking actions wait for the first value; an initial failure
/// stops the chain. A later subscription failure stops any remaining
/// actions from that invocation and fires the canvas's actionError reaction.
/// Subscriptions close on error or when the screen is disposed.
///
/// One variable has one live load: running the action again (or a
/// [ReloadCloudDataAction]) replaces the earlier subscription. Unless
/// [reactive] is false, the load runs again by itself when a value its
/// query reads changes (`${auth.uid}`, `${search}`, a [limit] bound to a
/// variable), but never for a change of its own variable.
final class LoadCloudDataAction extends DataAction {
  const LoadCloudDataAction({
    this.variable = '',
    this.single = true,
    this.id = '',
    this.query = const CloudQueryDef(),
    this.scope = CloudDataScope.screen,
    this.limit = '',
    this.aggregate = CloudLoadAggregate.none,
    this.aggregateField = '',
    this.refreshSeconds = 0,
    this.reactive = true,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'loadCloudData';
  @override
  String get type => typeName;

  final String variable;

  /// One document ([id] of [query]'s collection) or the query's documents.
  final bool single;
  final String id;

  /// The collection ([CloudQueryDef.collectionPath]) and, for a query, its
  /// filters, sorts, limit and joins.
  final CloudQueryDef query;

  /// Who keeps the subscription: the screen (until it goes), or the app
  /// ([CloudDataScope.app]): one subscription per app, shared by every
  /// screen, writing an app variable. Older runtimes load per screen.
  final CloudDataScope scope;

  /// The most documents to load: a number or an expression (`${shown}`),
  /// over [CloudQueryDef.limit]. Empty: the query's limit, else
  /// [kDefaultCloudLoadLimit]. `0` (or less) loads every document. The
  /// variable's `hasMore` says whether more documents match.
  final String limit;

  /// A number over the query instead of its documents, computed by the
  /// database without loading them.
  final CloudLoadAggregate aggregate;

  /// [CloudLoadAggregate.sum] and [CloudLoadAggregate.average]: the number
  /// field.
  final String aggregateField;

  /// An [aggregate] runs again after this app's writes to the collection
  /// and, when above 0, every this many seconds (writes made elsewhere).
  final int refreshSeconds;

  /// Whether the load runs again when a value its query reads changes.
  final bool reactive;

  static LoadCloudDataAction _fromJson(Json m, _Common c) => LoadCloudDataAction(
    variable: _s(m, 'variable'),
    single: _b(m, 'single', true),
    id: _s(m, 'id'),
    query: CloudQueryDef.fromJson(m['query']),
    scope: readEnum(CloudDataScope.values, m['scope'], CloudDataScope.screen),
    limit: _s(m, 'limit'),
    aggregate: _e(CloudLoadAggregate.values, m, 'aggregate', CloudLoadAggregate.none),
    aggregateField: _s(m, 'aggregateField'),
    refreshSeconds: (readInt(m['refreshSeconds']) ?? 0).clamp(0, 86400),
    reactive: _b(m, 'reactive', true),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {
    'variable': variable,
    if (!single) 'single': false,
    if (id.isNotEmpty) 'id': id,
    'query': query.toJson(),
    if (scope != CloudDataScope.screen) 'scope': scope.name,
    if (limit.isNotEmpty) 'limit': limit,
    if (aggregate != CloudLoadAggregate.none) 'aggregate': aggregate.name,
    if (aggregateField.isNotEmpty) 'aggregateField': aggregateField,
    if (refreshSeconds != 0) 'refreshSeconds': refreshSeconds,
    if (!reactive) 'reactive': false,
  };
}

/// Who keeps a [LoadCloudDataAction]'s live subscription.
enum CloudDataScope {
  /// The screen that ran the action: the subscription ends when it goes,
  /// and each screen that runs it opens its own.
  screen,

  /// The app (the runtime's project instance): the first run opens the
  /// subscription and every later run of the same document or query, from
  /// any screen, shares it; it lives until the app is done (or a run for
  /// the same variable asks for another document or query). Its variable is
  /// an app variable, so every screen reads it.
  app,
}

/// Runs again the live load of [variable] (a [LoadCloudDataAction] that ran
/// on this screen): it subscribes afresh, with the values its query reads
/// now, and waits for the first value. Nothing when the variable has no
/// load. A list's pull to refresh (its `refresh` reaction) runs it.
final class ReloadCloudDataAction extends DataAction {
  const ReloadCloudDataAction({this.variable = '', super.enabled, super.nonBlocking, super.when});

  static const typeName = 'reloadCloudData';
  @override
  String get type => typeName;

  final String variable;

  static ReloadCloudDataAction _fromJson(Json m, _Common c) => ReloadCloudDataAction(
    variable: _s(m, 'variable'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {'variable': variable};
}

/// What a [CloudDataAction] does.
enum CloudDataOperation { create, update, delete, get, query, count, sum, average }

/// How a [CloudFieldWrite] changes its field.
enum CloudFieldOperation { set, increment, arrayAdd, arrayRemove, delete, serverTime }

/// One field a [CloudDataAction] writes: [value] is an expression.
@immutable
final class CloudFieldWrite {
  const CloudFieldWrite(this.field, this.value, {this.operation = CloudFieldOperation.set});

  final String field;
  final String value;
  final CloudFieldOperation operation;

  static CloudFieldWrite? fromJson(Object? json) {
    final m = readMap(json);
    final field = readString(m?['field']);
    if (m == null || field == null) return null;
    return CloudFieldWrite(
      field,
      _s(m, 'value'),
      operation: readEnum(CloudFieldOperation.values, m['operation'], CloudFieldOperation.set),
    );
  }

  Json toJson() => {
    'field': field,
    if (value.isNotEmpty) 'value': value,
    if (operation != CloudFieldOperation.set) 'operation': operation.name,
  };

  @override
  bool operator ==(Object other) =>
      other is CloudFieldWrite && other.field == field && other.value == value && other.operation == operation;

  @override
  int get hashCode => Object.hash(field, value, operation);
}

/// Creates, updates, deletes, reads, queries or aggregates documents of a
/// collection. Its result (the new id, the document, the documents, the
/// number) is the chain's `${result}` and goes in [resultVariable].
final class CloudDataAction extends DataAction {
  const CloudDataAction({
    this.operation = CloudDataOperation.create,
    this.collection = '',
    this.id = '',
    this.fields = const [],
    this.where = const [],
    this.orderBy = const [],
    this.limit,
    this.aggregateField = '',
    this.loadRelated = const [],
    this.resultVariable = '',
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'cloudData';
  @override
  String get type => typeName;

  final CloudDataOperation operation;
  final String collection;
  final String id;
  final List<CloudFieldWrite> fields;
  final List<WhereFilter> where;
  final List<OrderBy> orderBy;
  final int? limit;
  final String aggregateField;
  final List<String> loadRelated;
  final String resultVariable;

  static CloudDataAction _fromJson(Json m, _Common c) => CloudDataAction(
    operation: _e(CloudDataOperation.values, m, 'operation', CloudDataOperation.create),
    collection: _s(m, 'collection'),
    id: _s(m, 'id'),
    fields: [...?readList(m['fields'])?.map(CloudFieldWrite.fromJson).nonNulls],
    where: [...?readList(m['whereFilters'])?.map(WhereFilter.fromJson).nonNulls],
    orderBy: [...?readList(m['orderByFilters'])?.map(OrderBy.fromJson).nonNulls],
    limit: readInt(m['limit']),
    aggregateField: _s(m, 'aggregateField'),
    loadRelated: readStrings(m['loadRelated']),
    resultVariable: _s(m, 'resultVariable'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {
    'operation': operation.name,
    'collection': collection,
    if (id.isNotEmpty) 'id': id,
    if (fields.isNotEmpty) 'fields': [for (final f in fields) f.toJson()],
    if (where.isNotEmpty) 'whereFilters': [for (final w in where) w.toJson()],
    if (orderBy.isNotEmpty) 'orderByFilters': [for (final o in orderBy) o.toJson()],
    'limit': ?limit,
    if (aggregateField.isNotEmpty) 'aggregateField': aggregateField,
    if (loadRelated.isNotEmpty) 'loadRelated': loadRelated,
    if (resultVariable.isNotEmpty) 'resultVariable': resultVariable,
  };
}

/// The most writes one atomic cloud commit takes (Firestore's limit).
const int kMaxCloudBatchWrites = 500;

/// Several [CloudDataAction] writes (create, update, delete) committed at
/// once. With [forEach], [steps] run once per item of that list
/// (`${loop.item}`, `${loop.index}`), every write in the same commit: "mark
/// all read" in one write instead of one per item.
///
/// Up to [kMaxCloudBatchWrites] writes are all or none. More are committed
/// in chunks of that size, each all or none; with [transaction], more fail
/// before anything is written. A batch with a read step (get, query, count,
/// sum, average) runs its steps one by one, as before.
final class CloudBatchAction extends DataAction {
  const CloudBatchAction({
    this.steps = const [],
    this.transaction = false,
    this.forEach = '',
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'cloudBatch';
  @override
  String get type => typeName;

  final List<CloudDataAction> steps;
  final bool transaction;

  /// A list (a path or expression; a cloud data variable's documents): the
  /// steps run per item. Empty: once.
  final String forEach;

  static CloudBatchAction _fromJson(Json m, _Common c) => CloudBatchAction(
    steps: [...ActionDef.listFromJson(m['steps']).whereType<CloudDataAction>()],
    transaction: _b(m, 'transaction', false),
    forEach: _s(m, 'forEach'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {
    'steps': _actionsJson(steps),
    if (transaction) 'transaction': true,
    if (forEach.isNotEmpty) 'forEach': forEach,
  };
}

/// What a [CloudFilesAction] does.
enum CloudFilesOperation { upload, delete }

/// What files an upload picks.
enum CloudFileKind { image, any }

/// Who can read an uploaded file.
enum CloudFileAccess {
  /// Anyone with its URL.
  public,

  /// Only the user who uploaded it.
  private,
}

/// Uploads files the user picks to (or deletes them from) cloud storage
/// folder [path]; [actions] run with each file (`${result.url}`...). With a
/// [source], it uploads that value instead of asking the user (a captured
/// screenshot, a drawing).
final class CloudFilesAction extends DataAction {
  const CloudFilesAction({
    this.operation = CloudFilesOperation.upload,
    this.path = '',
    this.kind = CloudFileKind.image,
    this.allowMultiple = true,
    this.maxSizeMB = 10,
    this.progressVariable = '',
    this.access = CloudFileAccess.public,
    this.source = '',
    this.fileName = '',
    this.actions = const [],
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'cloudFiles';
  @override
  String get type => typeName;

  final CloudFilesOperation operation;
  final String path;
  final CloudFileKind kind;
  final bool allowMultiple;
  final double maxSizeMB;
  final String progressVariable;
  final CloudFileAccess access;

  /// An expression giving what to upload instead of asking the user: a
  /// `data:` URL (what a `captureScreenshot` gives as `${result.image}`), a
  /// map `{"data": "data:...", "name": "shot.png"}`, or a list of them.
  /// Empty: the user picks the files. An older runtime ignores it and asks.
  final String source;

  /// The name a [source] file is stored under (an expression); empty: the
  /// map's `name`, else `file-<time>.<extension of its type>`.
  final String fileName;
  final List<ActionDef> actions;

  @override
  List<ActionDef> get nested => actions;

  static CloudFilesAction _fromJson(Json m, _Common c) => CloudFilesAction(
    operation: _e(CloudFilesOperation.values, m, 'operation', CloudFilesOperation.upload),
    path: _s(m, 'path'),
    kind: _e(CloudFileKind.values, m, 'kind', CloudFileKind.image),
    allowMultiple: _b(m, 'allowMultiple', true),
    maxSizeMB: _d(m, 'maxSizeMB', 10),
    progressVariable: _s(m, 'progressVariable'),
    access: _e(CloudFileAccess.values, m, 'access', CloudFileAccess.public),
    source: _s(m, 'source'),
    fileName: _s(m, 'fileName'),
    actions: _list(m, 'actions'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {
    if (operation != CloudFilesOperation.upload) 'operation': operation.name,
    'path': path,
    if (kind != CloudFileKind.image) 'kind': kind.name,
    if (!allowMultiple) 'allowMultiple': false,
    if (maxSizeMB != 10) 'maxSizeMB': writeDouble(maxSizeMB),
    if (progressVariable.isNotEmpty) 'progressVariable': progressVariable,
    if (access != CloudFileAccess.public) 'access': access.name,
    if (source.isNotEmpty) 'source': source,
    if (fileName.isNotEmpty) 'fileName': fileName,
    if (actions.isNotEmpty) 'actions': _actionsJson(actions),
  };
}

/// The data library's action types ([DataAction]).
const List<ActionSpec> dataActionSpecs = [
  ActionSpec(CallApiAction.typeName, label: 'Call API', fields: CallApiFields.all, decode: CallApiAction._fromJson, nested: ['onSuccess', 'onError'], requires: ['api']),
  ActionSpec(SetStorageAction.typeName, label: 'Set storage', fields: SetStorageFields.all, decode: SetStorageAction._fromJson, requires: ['storage']),
  ActionSpec(CloudDocumentsAction.typeName, label: 'Cloud documents', fields: CloudDocumentsFields.all, decode: CloudDocumentsAction._fromJson, requires: ['cloud']),
  ActionSpec(LoadCloudDataAction.typeName, label: 'Load cloud data', fields: LoadCloudDataFields.all, decode: LoadCloudDataAction._fromJson, requires: ['cloud']),
  ActionSpec(ReloadCloudDataAction.typeName, label: 'Reload cloud data', fields: ReloadCloudDataFields.all, decode: ReloadCloudDataAction._fromJson, requires: ['cloud']),
  ActionSpec(CloudFilesAction.typeName, label: 'Cloud files', fields: CloudFilesFields.all, decode: CloudFilesAction._fromJson, nested: ['actions'], requires: ['cloud']),
  ActionSpec(CloudDataAction.typeName, label: 'Cloud data', fields: CloudDataFields.all, decode: CloudDataAction._fromJson, requires: ['cloud']),
  ActionSpec(CloudBatchAction.typeName, label: 'Cloud batch', fields: CloudBatchFields.all, decode: CloudBatchAction._fromJson, nested: ['steps'], requires: ['cloud']),
  ActionSpec(SubmitFormAction.typeName, label: 'Submit form', fields: SubmitFormFields.all, decode: SubmitFormAction._fromJson, nested: ['onSuccess', 'onError'], requires: ['forms']),
];
