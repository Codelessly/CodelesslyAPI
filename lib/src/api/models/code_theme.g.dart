// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_theme.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$CodeThemeModelOmitDefaults(
  CodeThemeModel instance,
  Map<String, dynamic> json,
) {
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeThemeModel _$CodeThemeModelFromJson(Map json) => CodeThemeModel(
  keyword: json['keyword'] == null ? null : ColorRGBA.fromJson(json['keyword']),
  string: json['string'] == null ? null : ColorRGBA.fromJson(json['string']),
  comment: json['comment'] == null ? null : ColorRGBA.fromJson(json['comment']),
  number: json['number'] == null ? null : ColorRGBA.fromJson(json['number']),
  function: json['function'] == null
      ? null
      : ColorRGBA.fromJson(json['function']),
  punctuation: json['punctuation'] == null
      ? null
      : ColorRGBA.fromJson(json['punctuation']),
  type: json['type'] == null ? null : ColorRGBA.fromJson(json['type']),
  property: json['property'] == null
      ? null
      : ColorRGBA.fromJson(json['property']),
);

Map<String, dynamic> _$CodeThemeModelToJson(CodeThemeModel instance) =>
    <String, dynamic>{
      'keyword': ?instance.keyword?.toJson(),
      'string': ?instance.string?.toJson(),
      'comment': ?instance.comment?.toJson(),
      'number': ?instance.number?.toJson(),
      'function': ?instance.function?.toJson(),
      'punctuation': ?instance.punctuation?.toJson(),
      'type': ?instance.type?.toJson(),
      'property': ?instance.property?.toJson(),
    };
