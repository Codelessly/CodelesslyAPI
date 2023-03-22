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

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('left', instance.left);
  writeNotNull('top', instance.top);
  writeNotNull('right', instance.right);
  writeNotNull('bottom', instance.bottom);
  return val;
}
