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

Map<String, dynamic> _$InkWellModelToJson(InkWellModel instance) =>
    <String, dynamic>{
      'overlayColor': ?instance.overlayColor?.toJson(),
      'highlightColor': ?instance.highlightColor?.toJson(),
      'splashColor': ?instance.splashColor?.toJson(),
      'hoverColor': ?instance.hoverColor?.toJson(),
      'focusColor': ?instance.focusColor?.toJson(),
    };
