// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breakpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Breakpoint _$BreakpointFromJson(Map json) => Breakpoint(
  nodeId: json['nodeId'] as String,
  lowerBound: json['lowerBound'] as num? ?? 0,
  upperBound: json['upperBound'] == null
      ? double.infinity
      : const InfinityNumConverter().fromJson(json['upperBound'] as num?),
);

Map<String, dynamic> _$BreakpointToJson(Breakpoint instance) =>
    <String, dynamic>{
      'nodeId': instance.nodeId,
      'lowerBound': instance.lowerBound,
      'upperBound': ?const InfinityNumConverter().toJson(instance.upperBound),
    };
