import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

T roundTrip<T>(Object? value) => jsonDecode(jsonEncode(value)) as T;

void main() {
  test('a cloud data action round-trips through JSON and ActionModel', () {
    final CloudDataAction action = CloudDataAction(
      operation: CloudDataOperation.update,
      collection: r'users/${auth.uid}/tasks',
      documentId: r'${item.id}',
      fields: const [
        CloudFieldWrite(field: 'title', value: r'${title}'),
        CloudFieldWrite(
          field: 'likes',
          value: '1',
          operation: CloudFieldOperation.increment,
        ),
        CloudFieldWrite(
          field: 'updatedAt',
          operation: CloudFieldOperation.serverTime,
        ),
      ],
      loadRelated: const ['author'],
      resultVariable: VariableData(id: 'v', name: 'task'),
    );
    final ActionModel back = ActionModel.fromJson(
      roundTrip<Map>(action.toJson()),
    );
    expect(back, isA<CloudDataAction>());
    expect(back, action);
    // Defaults are left out.
    final Map json = CloudDataAction().toJson();
    expect(json.containsKey('fields'), isFalse);
    expect(json.containsKey('loadRelated'), isFalse);
    expect((action.toJson()['fields'] as List)[0], {
      'field': 'title',
      'value': r'${title}',
    });
  });

  test('a batch round-trips with its steps', () {
    final CloudBatchAction batch = CloudBatchAction(
      transaction: true,
      steps: [
        CloudDataAction(
          collection: 'posts',
          operation: CloudDataOperation.create,
        ),
        CloudDataAction(
          collection: 'users',
          documentId: 'u1',
          operation: CloudDataOperation.update,
          fields: const [
            CloudFieldWrite(
              field: 'posts',
              value: '1',
              operation: CloudFieldOperation.increment,
            ),
          ],
        ),
      ],
    );
    final ActionModel back = ActionModel.fromJson(
      roundTrip<Map>(batch.toJson()),
    );
    expect(back, batch);
  });

  test('operations describe themselves', () {
    expect(CloudDataOperation.count.aggregates, isTrue);
    expect(CloudDataOperation.update.writes, isTrue);
    expect(CloudDataOperation.get.needsDocumentId, isTrue);
    expect(CloudFieldOperation.serverTime.takesValue, isFalse);
  });

  test('a collection schema round-trips and finds fields', () {
    const CollectionSchema schema = CollectionSchema(
      name: 'posts',
      fields: [
        SchemaField(name: 'text', required: true),
        SchemaField(
          name: 'likes',
          type: SchemaFieldType.number,
          defaultValue: '0',
        ),
        SchemaField(
          name: 'author',
          type: SchemaFieldType.reference,
          referenceCollection: 'users',
        ),
      ],
    );
    final CollectionSchema back = CollectionSchema.fromJson(
      roundTrip<Map>(schema.toJson()),
    );
    expect(back, schema);
    expect(back.field('author')!.referenceCollection, 'users');
    expect(back.field('missing'), isNull);
    expect((schema.toJson()['fields'] as List)[0], {
      'name': 'text',
      'type': 'text',
      'required': true,
    });
  });
}
