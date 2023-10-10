// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edge_insets.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EdgeInsetsModel _$EdgeInsetsModelFromJson(Map json) => EdgeInsetsModel(
      l: (json['l'] as num?)?.toDouble() ?? 0,
      t: (json['t'] as num?)?.toDouble() ?? 0,
      r: (json['r'] as num?)?.toDouble() ?? 0,
      b: (json['b'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$EdgeInsetsModelToJson(EdgeInsetsModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('l', instance.l, instance.l, 0);
  writeNotNull('t', instance.t, instance.t, 0);
  writeNotNull('r', instance.r, instance.r, 0);
  writeNotNull('b', instance.b, instance.b, 0);
  return val;
}
