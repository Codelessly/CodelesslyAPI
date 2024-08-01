// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhereQueryFilter _$WhereQueryFilterFromJson(Map json) => WhereQueryFilter(
      field: json['field'] as String,
      operator: $enumDecode(_$WhereQueryOperatorEnumMap, json['operator']),
      value: json['value'] as String,
    );

Map<String, dynamic> _$WhereQueryFilterToJson(WhereQueryFilter instance) =>
    <String, dynamic>{
      'field': instance.field,
      'operator': _$WhereQueryOperatorEnumMap[instance.operator]!,
      'value': instance.value,
    };

const _$WhereQueryOperatorEnumMap = {
  WhereQueryOperator.equal: 'equal',
  WhereQueryOperator.notEqual: 'notEqual',
  WhereQueryOperator.lessThan: 'lessThan',
  WhereQueryOperator.lessThanOrEqual: 'lessThanOrEqual',
  WhereQueryOperator.greaterThan: 'greaterThan',
  WhereQueryOperator.greaterThanOrEqual: 'greaterThanOrEqual',
  WhereQueryOperator.arrayContains: 'arrayContains',
  WhereQueryOperator.arrayContainsAny: 'arrayContainsAny',
  WhereQueryOperator.inArray: 'inArray',
  WhereQueryOperator.notInArray: 'notInArray',
};

OrderByQueryFilter _$OrderByQueryFilterFromJson(Map json) => OrderByQueryFilter(
      field: json['field'] as String,
      sortOrder: $enumDecodeNullable(
              _$OrderByQuerySortOrderEnumMap, json['sortOrder']) ??
          OrderByQuerySortOrder.ascending,
    );

Map<String, dynamic> _$OrderByQueryFilterToJson(OrderByQueryFilter instance) {
  final val = <String, dynamic>{
    'field': instance.field,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'sortOrder',
      instance.sortOrder,
      _$OrderByQuerySortOrderEnumMap[instance.sortOrder]!,
      OrderByQuerySortOrder.ascending);
  return val;
}

const _$OrderByQuerySortOrderEnumMap = {
  OrderByQuerySortOrder.ascending: 'ascending',
  OrderByQuerySortOrder.descending: 'descending',
};
