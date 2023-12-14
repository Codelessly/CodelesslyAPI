// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'where_query_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhereQueryFilter _$WhereQueryFilterFromJson(Map json) => WhereQueryFilter(
      field: json['field'] as String,
      operator: $enumDecode(_$WhereQueryOperatorEnumMap, json['operator']),
      value: json['value'],
    );

Map<String, dynamic> _$WhereQueryFilterToJson(WhereQueryFilter instance) {
  final val = <String, dynamic>{
    'field': instance.field,
    'operator': _$WhereQueryOperatorEnumMap[instance.operator]!,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('value', instance.value, instance.value, null);
  return val;
}

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
