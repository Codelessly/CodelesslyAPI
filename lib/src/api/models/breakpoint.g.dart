// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breakpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Breakpoint _$BreakpointFromJson(Map json) => Breakpoint(
      nodeId: json['nodeId'] as String,
      lowerBound: json['lowerBound'] as num? ?? 0,
      upperBound: json['upperBound'] as num? ?? double.infinity,
    );

Map<String, dynamic> _$BreakpointToJson(Breakpoint instance) {
  final val = <String, dynamic>{
    'nodeId': instance.nodeId,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('lowerBound', instance.lowerBound, instance.lowerBound, 0);
  writeNotNull(
      'upperBound', instance.upperBound, instance.upperBound, double.infinity);
  return val;
}
