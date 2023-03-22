// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlignmentModel _$AlignmentModelFromJson(Map json) => AlignmentModel(
      json['data'] == null ? null : AlignmentData.fromJson(json['data'] as Map),
    );

Map<String, dynamic> _$AlignmentModelToJson(AlignmentModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('data', instance.data?.toJson());
  return val;
}

AlignmentData _$AlignmentDataFromJson(Map json) => AlignmentData(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$AlignmentDataToJson(AlignmentData instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
    };
