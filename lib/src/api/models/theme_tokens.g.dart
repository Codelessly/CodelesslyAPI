// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_tokens.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ThemeTokensOmitDefaults(
  ThemeTokens instance,
  Map<String, dynamic> json,
) {
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThemeTokens _$ThemeTokensFromJson(Map json) => ThemeTokens(
  primary: json['primary'] == null ? null : ColorRGBA.fromJson(json['primary']),
  onPrimary: json['onPrimary'] == null
      ? null
      : ColorRGBA.fromJson(json['onPrimary']),
  surface: json['surface'] == null ? null : ColorRGBA.fromJson(json['surface']),
  onSurface: json['onSurface'] == null
      ? null
      : ColorRGBA.fromJson(json['onSurface']),
  error: json['error'] == null ? null : ColorRGBA.fromJson(json['error']),
  success: json['success'] == null ? null : ColorRGBA.fromJson(json['success']),
  warning: json['warning'] == null ? null : ColorRGBA.fromJson(json['warning']),
  fontFamily: json['fontFamily'] as String?,
  titleFontFamily: json['titleFontFamily'] as String?,
  radius: (json['radius'] as num?)?.toDouble(),
  buttonRadius: (json['buttonRadius'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ThemeTokensToJson(ThemeTokens instance) =>
    <String, dynamic>{
      'primary': ?instance.primary?.toJson(),
      'onPrimary': ?instance.onPrimary?.toJson(),
      'surface': ?instance.surface?.toJson(),
      'onSurface': ?instance.onSurface?.toJson(),
      'error': ?instance.error?.toJson(),
      'success': ?instance.success?.toJson(),
      'warning': ?instance.warning?.toJson(),
      'fontFamily': ?instance.fontFamily,
      'titleFontFamily': ?instance.titleFontFamily,
      'radius': ?instance.radius,
      'buttonRadius': ?instance.buttonRadius,
    };
