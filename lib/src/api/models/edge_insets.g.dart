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

Map<String, dynamic> _$EdgeInsetsModelToJson(EdgeInsetsModel instance) =>
    <String, dynamic>{
      'l': instance.l,
      't': instance.t,
      'r': instance.r,
      'b': instance.b,
    };
