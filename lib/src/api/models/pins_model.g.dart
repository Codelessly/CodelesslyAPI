// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pins_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EdgePinsModel _$EdgePinsModelFromJson(Map json) => EdgePinsModel(
      left: (json['left'] as num?)?.toDouble(),
      top: (json['top'] as num?)?.toDouble(),
      right: (json['right'] as num?)?.toDouble(),
      bottom: (json['bottom'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$EdgePinsModelToJson(EdgePinsModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('left', instance.left, instance.left, null);
  writeNotNull('top', instance.top, instance.top, null);
  writeNotNull('right', instance.right, instance.right, null);
  writeNotNull('bottom', instance.bottom, instance.bottom, null);
  return val;
}
