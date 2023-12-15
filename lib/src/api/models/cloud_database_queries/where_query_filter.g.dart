// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'where_query_filter.dart';

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
