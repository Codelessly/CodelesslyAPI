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

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('minWidth', instance.minWidth);
  writeNotNull('maxWidth', instance.maxWidth);
  writeNotNull('minHeight', instance.minHeight);
  writeNotNull('maxHeight', instance.maxHeight);
  return val;
}
