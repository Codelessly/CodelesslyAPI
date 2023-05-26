// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ink_well.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InkWellModel _$InkWellModelFromJson(Map json) => InkWellModel(
      highlightColor: json['highlightColor'] == null
          ? null
          : ColorRGBA.fromJson(json['highlightColor'] as Map),
      splashColor: json['splashColor'] == null
          ? null
          : ColorRGBA.fromJson(json['splashColor'] as Map),
      hoverColor: json['hoverColor'] == null
          ? null
          : ColorRGBA.fromJson(json['hoverColor'] as Map),
      focusColor: json['focusColor'] == null
          ? null
          : ColorRGBA.fromJson(json['focusColor'] as Map),
    );

Map<String, dynamic> _$InkWellModelToJson(InkWellModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('highlightColor', instance.highlightColor?.toJson());
  writeNotNull('splashColor', instance.splashColor?.toJson());
  writeNotNull('hoverColor', instance.hoverColor?.toJson());
  writeNotNull('focusColor', instance.focusColor?.toJson());
  return val;
}
