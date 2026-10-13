// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breakpoint.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$BreakpointOmitDefaults(
  Breakpoint instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.lowerBound, 0)) json.remove('lowerBound');
  if (isJsonDefault(instance.upperBound, double.infinity))
    json.remove('upperBound');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Breakpoint _$BreakpointFromJson(Map json) => Breakpoint(
  nodeId: json['nodeId'] as String,
  lowerBound: json['lowerBound'] as num? ?? 0,
  upperBound: json['upperBound'] as num? ?? double.infinity,
);

Map<String, dynamic> _$BreakpointToJson(Breakpoint instance) =>
    <String, dynamic>{
      'nodeId': instance.nodeId,
      'lowerBound': instance.lowerBound,
      'upperBound': instance.upperBound,
    };
