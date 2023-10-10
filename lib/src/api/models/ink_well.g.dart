// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ink_well.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InkWellModel _$InkWellModelFromJson(Map json) => InkWellModel(
      overlayColor: json['overlayColor'] == null
          ? null
          : ColorRGBA.fromJson(json['overlayColor']),
      highlightColor: json['highlightColor'] == null
          ? null
          : ColorRGBA.fromJson(json['highlightColor']),
      splashColor: json['splashColor'] == null
          ? null
          : ColorRGBA.fromJson(json['splashColor']),
      hoverColor: json['hoverColor'] == null
          ? null
          : ColorRGBA.fromJson(json['hoverColor']),
      focusColor: json['focusColor'] == null
          ? null
          : ColorRGBA.fromJson(json['focusColor']),
    );

Map<String, dynamic> _$InkWellModelToJson(InkWellModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('overlayColor', instance.overlayColor,
      instance.overlayColor?.toJson(), null);
  writeNotNull('highlightColor', instance.highlightColor,
      instance.highlightColor?.toJson(), null);
  writeNotNull('splashColor', instance.splashColor,
      instance.splashColor?.toJson(), null);
  writeNotNull(
      'hoverColor', instance.hoverColor, instance.hoverColor?.toJson(), null);
  writeNotNull(
      'focusColor', instance.focusColor, instance.focusColor?.toJson(), null);
  return val;
}
