// The data library's action types as declared fields, for generated
// editors (see core/action_fields.dart).
import '../../core/action_fields.dart';
import '../../core/props.dart';
import '../../core/variables.dart';
import 'actions.dart';

/// [CallApiAction].
abstract final class CallApiFields {
  static const api = PropDef<String>('api', Codecs.string, '', doc: 'An API of services.apis.');
  static const params = PropDef<Object?>('params', Codecs.any, null, doc: 'Its inputs, by name (expressions).');
  static const onSuccess = PropDef<Object?>('onSuccess', Codecs.any, null, doc: 'Nested actions: run after a 2xx response.');
  static const onError = PropDef<Object?>('onError', Codecs.any, null, doc: 'Nested actions: run after a failure.');
  static const List<PropDef<Object?>> all = [api, params, onSuccess, onError];
}

/// [SetStorageAction].
abstract final class SetStorageFields {
  static const operation = PropDef<StorageOperation>('operation', EnumCodec(StorageOperation.values), StorageOperation.write);
  static const key = PropDef<String>('key', Codecs.string, '', doc: 'The key; may be a path. Not for clear.');
  static const valueType = PropDef<VariableType>('valueType', EnumCodec(VariableType.values), VariableType.text,
      doc: 'How the written value is read (write only).');
  static const skipIfExists = PropDef<bool>('skipIfExists', Codecs.bool, false, doc: 'Leaves a key that has a value.');
  static const List<PropDef<Object?>> all = [operation, key, valueType, ...ValueWriteFields.all, skipIfExists];
}

/// [CloudDocumentsAction].
abstract final class CloudDocumentsFields {
  static const operation = PropDef<CloudDocumentsOperation>(
      'operation', EnumCodec(CloudDocumentsOperation.values), CloudDocumentsOperation.add);
  static const path = PropDef<String>('path', Codecs.string, '', doc: 'The collection path (an expression).');
  static const id = PropDef<String>('id', Codecs.string, '', doc: 'The document id (an expression).');
  static const autoId = PropDef<bool>('autoId', Codecs.bool, false, doc: 'Add: a generated id.');
  static const skipIfExists = PropDef<bool>('skipIfExists', Codecs.bool, true, doc: 'Add only.');
  static const document = PropDef<String>('document', Codecs.string, '',
      doc: 'The document (add) or documents (setMany): an expression, or JSON text.');
  static const raw = PropDef<bool>('raw', Codecs.bool, false, doc: 'The document is taken as written: no expressions.');
  static const field = PropDef<String>('field', Codecs.string, '', doc: 'Update: the field (a path).');
  static const valueType = PropDef<VariableType>('valueType', EnumCodec(VariableType.values), VariableType.text,
      doc: 'Update only.');
  static const ids = PropDef<String>('ids', Codecs.string, '', doc: 'RemoveMany: ids, comma separated or a list.');
  static const whereFilters = PropDef<Object?>('whereFilters', Codecs.any, null, doc: 'RemoveMany: the filters.');
  static const idField = PropDef<String>('idField', Codecs.string, 'id');
  static const merge = PropDef<bool>('merge', Codecs.bool, false);
  static const replaceCollection = PropDef<bool>('replaceCollection', Codecs.bool, false);
  static const List<PropDef<Object?>> all = [
    operation, path, id, autoId, skipIfExists, document, raw, field, valueType, ...ValueWriteFields.all, //
    ids, whereFilters, idField, merge, replaceCollection,
  ];
}

/// [LoadCloudDataAction].
abstract final class LoadCloudDataFields {
  static const variable = PropDef<String>('variable', Codecs.string, '');
  static const single = PropDef<bool>('single', Codecs.bool, true, doc: 'One document, or the query\'s documents.');
  static const id = PropDef<String>('id', Codecs.string, '');
  static const query = PropDef<Object?>('query', Codecs.any, null,
      doc: 'The collection and, for a query, its filters, sorts, limit and joins (a CloudQueryDef).');
  static const scope = PropDef<CloudDataScope>('scope', EnumCodec(CloudDataScope.values), CloudDataScope.screen,
      doc: 'Screen: a subscription per screen, until it goes. App: one subscription the whole app shares, '
          'into an app variable every screen reads.');
  static const limit = PropDef<String>('limit', Codecs.string, '',
      doc: 'The most documents: a number or expression; empty: the query\'s, else $kDefaultCloudLoadLimit; 0: all.');
  static const aggregate = PropDef<CloudLoadAggregate>(
      'aggregate', EnumCodec(CloudLoadAggregate.values), CloudLoadAggregate.none,
      doc: 'A number (count, sum, average) instead of the documents, without loading them.');
  static const aggregateField = PropDef<String>('aggregateField', Codecs.string, '', doc: 'Sum and average: the field.');
  static const refreshSeconds = PropDef<int>('refreshSeconds', IntCodec(min: 0), 0,
      doc: 'Aggregate: also runs again this often (writes made elsewhere); 0: after this app\'s writes only.');
  static const reactive = PropDef<bool>('reactive', Codecs.bool, true,
      doc: 'Runs again when a value its query reads changes (\${auth.uid}, a bound limit).');
  static const List<PropDef<Object?>> all = [
    variable, single, id, query, scope, limit, aggregate, aggregateField, refreshSeconds, reactive, //
  ];
}

/// [ReloadCloudDataAction].
abstract final class ReloadCloudDataFields {
  static const variable = PropDef<String>('variable', Codecs.string, '', doc: 'A variable a load cloud data action fills.');
  static const List<PropDef<Object?>> all = [variable];
}

/// [CloudFilesAction].
abstract final class CloudFilesFields {
  static const operation =
      PropDef<CloudFilesOperation>('operation', EnumCodec(CloudFilesOperation.values), CloudFilesOperation.upload);
  static const path = PropDef<String>('path', Codecs.string, '', doc: 'The storage folder.');
  static const kind = PropDef<CloudFileKind>('kind', EnumCodec(CloudFileKind.values), CloudFileKind.image);
  static const allowMultiple = PropDef<bool>('allowMultiple', Codecs.bool, true);
  static const maxSizeMB = PropDef<double>('maxSizeMB', Codecs.double, 10);
  static const progressVariable = PropDef<String>('progressVariable', Codecs.string, '');
  static const access = PropDef<CloudFileAccess>('access', EnumCodec(CloudFileAccess.values), CloudFileAccess.public);
  static const source = PropDef<String>('source', Codecs.string, '',
      doc: 'Uploads this instead of asking the user: a data: URL (\${result.image} of a screenshot), or a list.');
  static const fileName = PropDef<String>('fileName', Codecs.string, '', doc: 'The name a source file is stored under.');
  static const actions = PropDef<Object?>('actions', Codecs.any, null, doc: 'Nested actions: run with each file.');
  static const List<PropDef<Object?>> all = [
    operation, path, kind, allowMultiple, maxSizeMB, progressVariable, access, source, fileName, actions, //
  ];
}

/// [CloudDataAction].
abstract final class CloudDataFields {
  static const operation = PropDef<CloudDataOperation>('operation', EnumCodec(CloudDataOperation.values), CloudDataOperation.create);
  static const collection = PropDef<String>('collection', Codecs.string, '');
  static const id = PropDef<String>('id', Codecs.string, '');
  static const fields = PropDef<Object?>('fields', Codecs.any, null, doc: 'Field writes: [{"field", "value", "operation"}].');
  static const whereFilters = PropDef<Object?>('whereFilters', Codecs.any, null);
  static const orderByFilters = PropDef<Object?>('orderByFilters', Codecs.any, null);
  static const limit = PropDef<int?>('limit', Codecs.optionalInt, null);
  static const aggregateField = PropDef<String>('aggregateField', Codecs.string, '');
  static const loadRelated = PropDef<List<String>>('loadRelated', Codecs.strings, []);
  static const resultVariable = PropDef<String>('resultVariable', Codecs.string, '');
  static const List<PropDef<Object?>> all = [
    operation, collection, id, fields, whereFilters, orderByFilters, limit, aggregateField, loadRelated, //
    resultVariable,
  ];
}

/// [CloudBatchAction].
abstract final class CloudBatchFields {
  static const steps = PropDef<Object?>('steps', Codecs.any, null, doc: 'Nested cloudData actions.');
  static const transaction = PropDef<bool>('transaction', Codecs.bool, false,
      doc: 'All or none: more than $kMaxCloudBatchWrites writes fail instead of committing in chunks.');
  static const forEach = PropDef<String>('forEach', Codecs.string, '',
      doc: 'A list: the steps run per item (\${loop.item}, \${loop.index}), all in one commit.');
  static const List<PropDef<Object?>> all = [steps, transaction, forEach];
}

/// [SubmitFormAction].
abstract final class SubmitFormFields {
  /// Only `local` is offered: [FormService.unsupported] marks old data.
  static const service = PropDef<FormService>('service', EnumCodec([FormService.local]), FormService.local);
  static const payload = PropDef<String>('payload', Codecs.string, '', doc: 'An expression yielding a JSON object.');
  static const validationScript = PropDef<String>('validationScript', Codecs.string, '', doc: 'Await a script returning {valid, errors?, payload?}.');
  static const validationArguments = PropDef<Object?>('validationArguments', Codecs.any, null, doc: 'Named script argument expressions.');
  static const responseVariable = PropDef<String>('responseVariable', Codecs.string, '', doc: 'Optional mutable list variable receiving the validated payload. Persist the variable to keep submissions.');
  static const prepend = PropDef<bool>('prepend', Codecs.bool, false);
  static const resultVariable = PropDef<String>('resultVariable', Codecs.string, '');
  static const onSuccess = PropDef<Object?>('onSuccess', Codecs.any, null);
  static const onError = PropDef<Object?>('onError', Codecs.any, null);
  static const List<PropDef<Object?>> all = [service, payload, validationScript, validationArguments, responseVariable,
    prepend, resultVariable, onSuccess, onError];
}
