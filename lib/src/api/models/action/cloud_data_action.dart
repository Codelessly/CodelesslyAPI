import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'cloud_data_action.g.dart';

/// What a [CloudDataAction] does.
enum CloudDataOperation {
  /// Adds a document.
  create('Create document'),

  /// Changes fields of a document.
  update('Update document'),

  /// Deletes a document.
  delete('Delete document'),

  /// Reads one document.
  get('Get document'),

  /// Reads the documents matching filters.
  query('Query documents'),

  /// Counts the documents matching filters.
  count('Count documents'),

  /// Adds up a number field of the documents matching filters.
  sum('Sum a field'),

  /// Averages a number field of the documents matching filters.
  average('Average a field');

  /// The name shown to builders.
  final String label;

  const CloudDataOperation(this.label);

  /// Whether this operation writes.
  bool get writes => this == create || this == update || this == delete;

  /// Whether this operation reads a number over many documents.
  bool get aggregates => this == count || this == sum || this == average;

  /// Whether this operation targets one document by id.
  bool get needsDocumentId => this == update || this == delete || this == get;
}

/// How a [CloudFieldWrite] changes its field.
enum CloudFieldOperation {
  /// Sets the field to the value.
  set('Set'),

  /// Adds the value (a number) to the field.
  increment('Increase by'),

  /// Adds the value to the list in the field, once.
  arrayAdd('Add to list'),

  /// Removes the value from the list in the field.
  arrayRemove('Remove from list'),

  /// Deletes the field.
  delete('Delete field'),

  /// Sets the field to the server's time.
  serverTime('Server time');

  /// The name shown to builders.
  final String label;

  const CloudFieldOperation(this.label);

  /// Whether this operation takes a value.
  bool get takesValue => this != delete && this != serverTime;
}

/// One field a create or update writes.
@JsonSerializable()
class CloudFieldWrite with Equatable, SerializableMixin {
  /// The field.
  final String field;

  /// The value, as text that may hold `${...}` data or a formula. It is
  /// converted to the field's type from the collection's schema.
  @JsonKey(defaultValue: '')
  final String value;

  /// How the field changes.
  @JsonKey(defaultValue: CloudFieldOperation.set)
  final CloudFieldOperation operation;

  /// Creates a [CloudFieldWrite].
  const CloudFieldWrite({
    required this.field,
    this.value = '',
    this.operation = CloudFieldOperation.set,
  });

  @override
  List<Object?> get props => [field, value, operation];

  /// Creates a [CloudFieldWrite] from JSON.
  factory CloudFieldWrite.fromJson(Map json) => _$CloudFieldWriteFromJson(json);

  @override
  Map toJson() =>
      _$CloudFieldWriteOmitDefaults(this, _$CloudFieldWriteToJson(this));
}

/// Creates, updates, deletes, reads, queries or aggregates documents of a
/// cloud database collection, with the fields built from the collection's
/// schema instead of JSON.
@JsonSerializable()
class CloudDataAction extends ActionModel with Equatable, SerializableMixin {
  /// What the action does.
  final CloudDataOperation operation;

  /// The collection path; may hold `${...}` data, e.g.
  /// `users/${auth.uid}/tasks`.
  @JsonKey(defaultValue: '')
  final String collection;

  /// The document id for update, delete and get; may hold `${...}` data.
  /// For create, an id to use instead of a generated one.
  @JsonKey(defaultValue: '')
  final String documentId;

  /// The fields a create or update writes.
  @JsonKey(defaultValue: [])
  final List<CloudFieldWrite> fields;

  /// Filters of a query or aggregate.
  @JsonKey(defaultValue: [])
  final List<WhereQueryFilter> whereFilters;

  /// Sorting of a query.
  @JsonKey(defaultValue: [])
  final List<OrderByQueryFilter> orderByFilters;

  /// How many documents a query returns at most.
  final int? limit;

  /// The number field a sum or average reads.
  @JsonKey(defaultValue: '')
  final String aggregateField;

  /// Reference fields whose documents a get or query loads too: each
  /// result's reference field then holds the referenced document's data
  /// (with its `id`) instead of the id.
  @JsonKey(defaultValue: [])
  final List<String> loadRelated;

  /// Subcollections a delete removes with the document.
  @JsonKey(defaultValue: [])
  final List<String> deleteSubcollections;

  /// The variable that receives the result: the created document's id, the
  /// document (get), the list of documents (query) or the number
  /// (count, sum, average).
  final VariableData? resultVariable;

  /// Creates a [CloudDataAction].
  CloudDataAction({
    this.operation = CloudDataOperation.create,
    this.collection = '',
    this.documentId = '',
    this.fields = const [],
    this.whereFilters = const [],
    this.orderByFilters = const [],
    this.limit,
    this.aggregateField = '',
    this.loadRelated = const [],
    this.deleteSubcollections = const [],
    this.resultVariable,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.cloudData);

  /// Duplicates this action with the given values replaced.
  CloudDataAction copyWith({
    CloudDataOperation? operation,
    String? collection,
    String? documentId,
    List<CloudFieldWrite>? fields,
    List<WhereQueryFilter>? whereFilters,
    List<OrderByQueryFilter>? orderByFilters,
    int? limit,
    String? aggregateField,
    List<String>? loadRelated,
    List<String>? deleteSubcollections,
    VariableData? resultVariable,
    bool clearResultVariable = false,
  }) => CloudDataAction(
    operation: operation ?? this.operation,
    collection: collection ?? this.collection,
    documentId: documentId ?? this.documentId,
    fields: fields ?? this.fields,
    whereFilters: whereFilters ?? this.whereFilters,
    orderByFilters: orderByFilters ?? this.orderByFilters,
    limit: limit ?? this.limit,
    aggregateField: aggregateField ?? this.aggregateField,
    loadRelated: loadRelated ?? this.loadRelated,
    deleteSubcollections: deleteSubcollections ?? this.deleteSubcollections,
    resultVariable: clearResultVariable
        ? null
        : resultVariable ?? this.resultVariable,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [
    operation,
    collection,
    documentId,
    fields,
    whereFilters,
    orderByFilters,
    limit,
    aggregateField,
    loadRelated,
    deleteSubcollections,
    resultVariable,
  ];

  /// Creates a [CloudDataAction] from JSON.
  factory CloudDataAction.fromJson(Map json) => _$CloudDataActionFromJson(json);

  @override
  Map toJson() =>
      _$CloudDataActionOmitDefaults(this, _$CloudDataActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitCloudDataAction(this);
}

/// Runs several creates, updates and deletes together: all succeed or none
/// do. As a transaction, documents are read and written atomically, so
/// increments and conditions see each other's changes.
@JsonSerializable()
class CloudBatchAction extends ActionModel with Equatable, SerializableMixin {
  /// The writes, in order. Only create, update and delete are run.
  @JsonKey(defaultValue: [])
  final List<CloudDataAction> steps;

  /// Whether to run as a transaction instead of a batch.
  @JsonKey(defaultValue: false)
  final bool transaction;

  /// Creates a [CloudBatchAction].
  CloudBatchAction({
    this.steps = const [],
    this.transaction = false,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.cloudBatch);

  /// Duplicates this action with the given values replaced.
  CloudBatchAction copyWith({
    List<CloudDataAction>? steps,
    bool? transaction,
  }) => CloudBatchAction(
    steps: steps ?? this.steps,
    transaction: transaction ?? this.transaction,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [steps, transaction];

  /// Creates a [CloudBatchAction] from JSON.
  factory CloudBatchAction.fromJson(Map json) =>
      _$CloudBatchActionFromJson(json);

  @override
  Map toJson() =>
      _$CloudBatchActionOmitDefaults(this, _$CloudBatchActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitCloudBatchAction(this);
}
