// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_by_query_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
