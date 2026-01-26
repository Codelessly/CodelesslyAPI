// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlignmentModel _$AlignmentModelFromJson(Map json) => AlignmentModel(
  json['data'] == null ? null : AlignmentData.fromJson(json['data']),
);

Map<String, dynamic> _$AlignmentModelToJson(AlignmentModel instance) =>
    <String, dynamic>{'data': ?instance.data?.toJson()};

AlignmentData _$AlignmentDataFromJson(Map json) =>
    AlignmentData((json['x'] as num).toDouble(), (json['y'] as num).toDouble());
