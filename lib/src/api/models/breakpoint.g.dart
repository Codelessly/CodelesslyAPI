// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breakpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Breakpoint _$BreakpointFromJson(Map json) => Breakpoint(
      nodeId: json['nodeId'] as String,
      lowerBound: json['lowerBound'] as num,
      upperBound: json['upperBound'] as num,
      scaleMode: $enumDecode(_$ScaleModeEnumMap, json['scaleMode']),
    );

Map<String, dynamic> _$BreakpointToJson(Breakpoint instance) =>
    <String, dynamic>{
      'nodeId': instance.nodeId,
      'lowerBound': instance.lowerBound,
      'upperBound': instance.upperBound,
      'scaleMode': _$ScaleModeEnumMap[instance.scaleMode]!,
    };

const _$ScaleModeEnumMap = {
  ScaleMode.autoScale: 'autoScale',
  ScaleMode.responsive: 'responsive',
};
