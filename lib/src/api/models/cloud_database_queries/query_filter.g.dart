// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_filter.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$WhereQueryFilterOmitDefaults(
  WhereQueryFilter instance,
  Map<String, dynamic> json,
) {
  return json;
}

Map<String, dynamic> _$OrderByQueryFilterOmitDefaults(
  OrderByQueryFilter instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.sortOrder, OrderByQuerySortOrder.ascending))
    json.remove('sortOrder');
  return json;
}

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
  sortOrder:
      $enumDecodeNullable(_$OrderByQuerySortOrderEnumMap, json['sortOrder']) ??
      OrderByQuerySortOrder.ascending,
);

Map<String, dynamic> _$OrderByQueryFilterToJson(OrderByQueryFilter instance) =>
    <String, dynamic>{
      'field': instance.field,
      'sortOrder': _$OrderByQuerySortOrderEnumMap[instance.sortOrder]!,
    };

const _$OrderByQuerySortOrderEnumMap = {
  OrderByQuerySortOrder.ascending: 'ascending',
  OrderByQuerySortOrder.descending: 'descending',
};
