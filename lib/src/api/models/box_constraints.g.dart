// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box_constraints.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoxConstraintsModel _$BoxConstraintsModelFromJson(Map json) =>
    BoxConstraintsModel(
      minWidth: (json['minWidth'] as num?)?.toDouble(),
      maxWidth: (json['maxWidth'] as num?)?.toDouble(),
      minHeight: (json['minHeight'] as num?)?.toDouble(),
      maxHeight: (json['maxHeight'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BoxConstraintsModelToJson(BoxConstraintsModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('minWidth', instance.minWidth, instance.minWidth, null);
  writeNotNull('maxWidth', instance.maxWidth, instance.maxWidth, null);
  writeNotNull('minHeight', instance.minHeight, instance.minHeight, null);
  writeNotNull('maxHeight', instance.maxHeight, instance.maxHeight, null);
  return val;
}
