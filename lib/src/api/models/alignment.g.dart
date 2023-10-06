// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlignmentModel _$AlignmentModelFromJson(Map json) => AlignmentModel(
      json['data'] == null ? null : AlignmentData.fromJson(json['data']),
    );

Map<String, dynamic> _$AlignmentModelToJson(AlignmentModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('data', instance.data, instance.data?.toJson(), null);
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
