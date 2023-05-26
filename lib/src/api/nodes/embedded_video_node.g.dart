// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embedded_video_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmbeddedVideoNode _$EmbeddedVideoNodeFromJson(Map json) => EmbeddedVideoNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      outerBoxLocal: json['outerBoxLocal'] == null
          ? null
          : OuterNodeBox.fromJson(json['outerBoxLocal'] as Map),
      visible: json['visible'] as bool? ?? true,
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding'] as Map),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin'] as Map),
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          const [],
      horizontalFit:
          $enumDecodeNullable(_$SizeFitEnumMap, json['horizontalFit']) ??
              SizeFit.fixed,
      verticalFit: $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
          SizeFit.fixed,
      flex: json['flex'] as int? ?? 1,
      aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
      constraints: json['constraints'] == null
          ? const BoxConstraintsModel()
          : BoxConstraintsModel.fromJson(json['constraints'] as Map),
      positioningMode: $enumDecodeNullable(
              _$PositioningModeEnumMap, json['positioningMode']) ??
          PositioningMode.align,
      edgePins: json['edgePins'] == null
          ? EdgePinsModel.standard
          : EdgePinsModel.fromJson(
              Map<String, dynamic>.from(json['edgePins'] as Map)),
      properties: EmbeddedVideoProperties.fromJson(json['properties'] as Map),
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
    )
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..type = json['type'] as String;

Map<String, dynamic> _$EmbeddedVideoNodeToJson(EmbeddedVideoNode instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'visible': instance.visible,
    'constraints': instance.constraints.toJson(),
    'edgePins': instance.edgePins.toJson(),
    'positioningMode': _$PositioningModeEnumMap[instance.positioningMode]!,
    'horizontalFit': _$SizeFitEnumMap[instance.horizontalFit]!,
    'verticalFit': _$SizeFitEnumMap[instance.verticalFit]!,
    'flex': instance.flex,
    'aspectRatioLock': instance.aspectRatioLock,
    'alignment': instance.alignment.toJson(),
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
    'outerBoxLocal': instance.outerBoxLocal.toJson(),
    'basicBoxLocal': instance.basicBoxLocal.toJson(),
    'margin': instance.margin.toJson(),
    'padding': instance.padding.toJson(),
    'rotation': instance.rotationDegrees,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('widthFactor', instance.widthFactor);
  writeNotNull('heightFactor', instance.heightFactor);
  val['variables'] = instance.variables;
  val['multipleVariables'] = instance.multipleVariables;
  val['type'] = instance.type;
  val['properties'] = instance.properties.toJson();
  return val;
}

const _$SizeFitEnumMap = {
  SizeFit.locked: 'locked',
  SizeFit.fixed: 'fixed',
  SizeFit.expanded: 'expanded',
  SizeFit.flexible: 'flexible',
  SizeFit.shrinkWrap: 'shrinkWrap',
};

const _$PositioningModeEnumMap = {
  PositioningMode.align: 'align',
  PositioningMode.pin: 'pin',
};

EmbeddedYoutubeVideoProperties _$EmbeddedYoutubeVideoPropertiesFromJson(
        Map json) =>
    EmbeddedYoutubeVideoProperties(
      url: json['url'] as String?,
      mute: json['mute'] as bool? ?? false,
      showControls: json['showControls'] as bool? ?? true,
      autoPlay: json['autoPlay'] as bool? ?? false,
      showFullscreenButton: json['showFullscreenButton'] as bool? ?? true,
      showVideoAnnotations: json['showVideoAnnotations'] as bool? ?? true,
      loop: json['loop'] as bool? ?? false,
      showCaptions: json['showCaptions'] as bool? ?? false,
      startAt: json['startAt'] as int? ?? 0,
      endAt: json['endAt'] as int?,
      captionLanguage: json['captionLanguage'] as String? ?? 'en',
    )
      ..videoId = json['videoId'] as String?
      ..source = $enumDecode(_$EmbeddedVideoSourceEnumMap, json['source'])
      ..metadata = json['metadata'] == null
          ? null
          : YoutubeVideoMetadata.fromJson(
              Map<String, dynamic>.from(json['metadata'] as Map));

Map<String, dynamic> _$EmbeddedYoutubeVideoPropertiesToJson(
    EmbeddedYoutubeVideoProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('url', instance.url);
  writeNotNull('videoId', instance.videoId);
  val['autoPlay'] = instance.autoPlay;
  val['source'] = _$EmbeddedVideoSourceEnumMap[instance.source]!;
  val['mute'] = instance.mute;
  val['showControls'] = instance.showControls;
  val['showVideoAnnotations'] = instance.showVideoAnnotations;
  val['showFullscreenButton'] = instance.showFullscreenButton;
  val['loop'] = instance.loop;
  val['showCaptions'] = instance.showCaptions;
  writeNotNull('startAt', instance.startAt);
  writeNotNull('endAt', instance.endAt);
  val['captionLanguage'] = instance.captionLanguage;
  writeNotNull('metadata', instance.metadata?.toJson());
  return val;
}

const _$EmbeddedVideoSourceEnumMap = {
  EmbeddedVideoSource.youtube: 'youtube',
  EmbeddedVideoSource.vimeo: 'vimeo',
};

EmbeddedVimeoVideoProperties _$EmbeddedVimeoVideoPropertiesFromJson(Map json) =>
    EmbeddedVimeoVideoProperties(
      url: json['url'] as String?,
      mute: json['mute'] as bool? ?? false,
      autoPlay: json['autoPlay'] as bool? ?? false,
      loop: json['loop'] as bool? ?? false,
      showFullscreenButton: json['showFullscreenButton'] as bool? ?? true,
    )
      ..videoId = json['videoId'] as String?
      ..source = $enumDecode(_$EmbeddedVideoSourceEnumMap, json['source'])
      ..metadata = json['metadata'] == null
          ? null
          : VimeoVideoMetadata.fromJson(
              Map<String, dynamic>.from(json['metadata'] as Map));

Map<String, dynamic> _$EmbeddedVimeoVideoPropertiesToJson(
    EmbeddedVimeoVideoProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('url', instance.url);
  writeNotNull('videoId', instance.videoId);
  val['autoPlay'] = instance.autoPlay;
  val['source'] = _$EmbeddedVideoSourceEnumMap[instance.source]!;
  val['mute'] = instance.mute;
  val['showFullscreenButton'] = instance.showFullscreenButton;
  val['loop'] = instance.loop;
  writeNotNull('metadata', instance.metadata?.toJson());
  return val;
}

YoutubeVideoMetadata _$YoutubeVideoMetadataFromJson(Map json) =>
    YoutubeVideoMetadata(
      url: json['url'] as String,
      title: json['title'] as String,
      author: json['author_name'] as String,
      authorUrl: json['author_url'] as String,
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      thumbnailUrl: json['thumbnail_url'] as String,
      thumbnailWidth: (json['thumbnail_width'] as num).toDouble(),
      thumbnailHeight: (json['thumbnail_height'] as num).toDouble(),
      providerName: json['provider_name'] as String,
      html: json['html'] as String,
      cloudThumbnailUrl: json['cloudThumbnailUrl'] as String? ?? '',
    );

Map<String, dynamic> _$YoutubeVideoMetadataToJson(
        YoutubeVideoMetadata instance) =>
    <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'author_name': instance.author,
      'author_url': instance.authorUrl,
      'width': instance.width,
      'height': instance.height,
      'thumbnail_url': instance.thumbnailUrl,
      'thumbnail_width': instance.thumbnailWidth,
      'thumbnail_height': instance.thumbnailHeight,
      'provider_name': instance.providerName,
      'html': instance.html,
      'cloudThumbnailUrl': instance.cloudThumbnailUrl,
    };

VimeoVideoMetadata _$VimeoVideoMetadataFromJson(Map json) => VimeoVideoMetadata(
      url: json['url'] as String,
      version: json['version'] as String,
      title: json['title'] as String,
      author: json['author_name'] as String,
      authorUrl: json['author_url'] as String,
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      duration: durationFromSeconds(json['duration'] as int),
      description: json['description'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      thumbnailWidth: (json['thumbnail_width'] as num).toDouble(),
      thumbnailHeight: (json['thumbnail_height'] as num).toDouble(),
      thumbnailUrlWithPlayButton:
          json['thumbnail_url_with_play_button'] as String,
      uploadDate: json['upload_date'] as String,
      providerName: json['provider_name'] as String,
      html: json['html'] as String,
      cloudThumbnailUrl: json['cloudThumbnailUrl'] as String? ?? '',
    );

Map<String, dynamic> _$VimeoVideoMetadataToJson(VimeoVideoMetadata instance) =>
    <String, dynamic>{
      'url': instance.url,
      'version': instance.version,
      'title': instance.title,
      'author_name': instance.author,
      'author_url': instance.authorUrl,
      'width': instance.width,
      'height': instance.height,
      'duration': instance.duration.inMicroseconds,
      'description': instance.description,
      'thumbnail_url': instance.thumbnailUrl,
      'thumbnail_width': instance.thumbnailWidth,
      'thumbnail_height': instance.thumbnailHeight,
      'thumbnail_url_with_play_button': instance.thumbnailUrlWithPlayButton,
      'upload_date': instance.uploadDate,
      'provider_name': instance.providerName,
      'html': instance.html,
      'cloudThumbnailUrl': instance.cloudThumbnailUrl,
    };
