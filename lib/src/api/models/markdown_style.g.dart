// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'markdown_style.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$MarkdownStyleOmitDefaults(
  MarkdownStyle instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.codeFontFamily, 'JetBrains Mono'))
    json.remove('codeFontFamily');
  if (isJsonDefault(instance.mentions, const [])) json.remove('mentions');
  if (isJsonDefault(instance.paragraphGap, 8)) json.remove('paragraphGap');
  if (isJsonDefault(instance.showMarkers, false)) json.remove('showMarkers');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarkdownStyle _$MarkdownStyleFromJson(Map json) => MarkdownStyle(
  codeColor: json['codeColor'] == null
      ? null
      : ColorRGBA.fromJson(json['codeColor']),
  codeBackground: json['codeBackground'] == null
      ? null
      : ColorRGBA.fromJson(json['codeBackground']),
  codeFontFamily: json['codeFontFamily'] as String? ?? 'JetBrains Mono',
  linkColor: json['linkColor'] == null
      ? null
      : ColorRGBA.fromJson(json['linkColor']),
  mentionColor: json['mentionColor'] == null
      ? null
      : ColorRGBA.fromJson(json['mentionColor']),
  mentionBackground: json['mentionBackground'] == null
      ? null
      : ColorRGBA.fromJson(json['mentionBackground']),
  mentions:
      (json['mentions'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  bulletColor: json['bulletColor'] == null
      ? null
      : ColorRGBA.fromJson(json['bulletColor']),
  paragraphGap: (json['paragraphGap'] as num?)?.toDouble() ?? 8,
  showMarkers: json['showMarkers'] as bool? ?? false,
  markerColor: json['markerColor'] == null
      ? null
      : ColorRGBA.fromJson(json['markerColor']),
);

Map<String, dynamic> _$MarkdownStyleToJson(MarkdownStyle instance) =>
    <String, dynamic>{
      'codeColor': ?instance.codeColor?.toJson(),
      'codeBackground': ?instance.codeBackground?.toJson(),
      'codeFontFamily': instance.codeFontFamily,
      'linkColor': ?instance.linkColor?.toJson(),
      'mentionColor': ?instance.mentionColor?.toJson(),
      'mentionBackground': ?instance.mentionBackground?.toJson(),
      'mentions': instance.mentions,
      'bulletColor': ?instance.bulletColor?.toJson(),
      'paragraphGap': instance.paragraphGap,
      'showMarkers': instance.showMarkers,
      'markerColor': ?instance.markerColor?.toJson(),
    };
