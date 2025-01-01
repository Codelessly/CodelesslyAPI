// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embedded_video_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmbeddedVideoNode _$EmbeddedVideoNodeFromJson(Map json) => EmbeddedVideoNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
      visible: json['visible'] as bool? ?? true,
      enabled: json['enabled'] as bool? ?? true,
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding']),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin']),
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          [],
      horizontalFit:
          $enumDecodeNullable(_$SizeFitEnumMap, json['horizontalFit']) ??
              SizeFit.fixed,
      verticalFit: $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
          SizeFit.fixed,
      flex: (json['flex'] as num?)?.toInt() ?? 1,
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
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..componentId = json['componentId'] as String?
      ..markerType =
          $enumDecodeNullable(_$ComponentMarkerTypeEnumMap, json['markerType'])
      ..componentVersion = (json['componentVersion'] as num?)?.toInt() ?? 1
      ..componentSchema = (json['componentSchema'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e),
          ) ??
          {}
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$EmbeddedVideoNodeToJson(EmbeddedVideoNode instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('reactions', instance.reactions,
      instance.reactions.map((e) => e.toJson()).toList(), const []);
  writeNotNull('variables', instance.variables, instance.variables, {});
  writeNotNull('multipleVariables', instance.multipleVariables,
      instance.multipleVariables, {});
  writeNotNull('componentId', instance.componentId, instance.componentId, null);
  writeNotNull('markerType', instance.markerType,
      _$ComponentMarkerTypeEnumMap[instance.markerType], null);
  writeNotNull('componentVersion', instance.componentVersion,
      instance.componentVersion, 1);
  writeNotNull('componentSchema', instance.componentSchema,
      instance.componentSchema, {});
  val['id'] = instance.id;
  val['name'] = instance.name;
  writeNotNull('visible', instance.visible, instance.visible, true);
  if (!excludeConstraintsIf(instance)) {
    writeNotNull('constraints', instance.constraints,
        instance.constraints.toJson(), const BoxConstraintsModel());
  }
  writeNotNull('edgePins', instance.edgePins, instance.edgePins.toJson(),
      EdgePinsModel.standard);
  writeNotNull(
      'positioningMode',
      instance.positioningMode,
      _$PositioningModeEnumMap[instance.positioningMode]!,
      PositioningMode.align);
  writeNotNull('horizontalFit', instance.horizontalFit,
      _$SizeFitEnumMap[instance.horizontalFit]!, SizeFit.fixed);
  writeNotNull('verticalFit', instance.verticalFit,
      _$SizeFitEnumMap[instance.verticalFit]!, SizeFit.fixed);
  writeNotNull('flex', instance.flex, instance.flex, 1);
  writeNotNull('aspectRatioLock', instance.aspectRatioLock,
      instance.aspectRatioLock, false);
  writeNotNull('alignment', instance.alignment, instance.alignment.toJson(),
      AlignmentModel.none);
  val['basicBoxLocal'] = instance.basicBoxLocal.toJson();
  writeNotNull('margin', instance.margin, instance.margin.toJson(),
      EdgeInsetsModel.zero);
  writeNotNull('padding', instance.padding, instance.padding.toJson(),
      EdgeInsetsModel.zero);
  writeNotNull(
      'rotation', instance.rotationDegrees, instance.rotationDegrees, 0);
  writeNotNull('widthFactor', instance.widthFactor, instance.widthFactor, null);
  writeNotNull(
      'heightFactor', instance.heightFactor, instance.heightFactor, null);
  writeNotNull('enabled', instance.enabled, instance.enabled, true);
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

const _$ComponentMarkerTypeEnumMap = {
  ComponentMarkerType.component: 'component',
  ComponentMarkerType.instance: 'instance',
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
      startAt: (json['startAt'] as num?)?.toInt() ?? 0,
      endAt: (json['endAt'] as num?)?.toInt(),
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

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('url', instance.url, instance.url, null);
  writeNotNull('videoId', instance.videoId, instance.videoId, null);
  writeNotNull('autoPlay', instance.autoPlay, instance.autoPlay, false);
  val['source'] = _$EmbeddedVideoSourceEnumMap[instance.source]!;
  writeNotNull('mute', instance.mute, instance.mute, false);
  writeNotNull(
      'showControls', instance.showControls, instance.showControls, true);
  writeNotNull('showVideoAnnotations', instance.showVideoAnnotations,
      instance.showVideoAnnotations, true);
  writeNotNull('showFullscreenButton', instance.showFullscreenButton,
      instance.showFullscreenButton, true);
  writeNotNull('loop', instance.loop, instance.loop, false);
  writeNotNull(
      'showCaptions', instance.showCaptions, instance.showCaptions, false);
  writeNotNull('startAt', instance.startAt, instance.startAt, 0);
  writeNotNull('endAt', instance.endAt, instance.endAt, null);
  writeNotNull('captionLanguage', instance.captionLanguage,
      instance.captionLanguage, 'en');
  writeNotNull(
      'metadata', instance.metadata, instance.metadata?.toJson(), null);
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

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('url', instance.url, instance.url, null);
  writeNotNull('videoId', instance.videoId, instance.videoId, null);
  writeNotNull('autoPlay', instance.autoPlay, instance.autoPlay, false);
  val['source'] = _$EmbeddedVideoSourceEnumMap[instance.source]!;
  writeNotNull('mute', instance.mute, instance.mute, false);
  writeNotNull('showFullscreenButton', instance.showFullscreenButton,
      instance.showFullscreenButton, true);
  writeNotNull('loop', instance.loop, instance.loop, false);
  writeNotNull(
      'metadata', instance.metadata, instance.metadata?.toJson(), null);
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
    YoutubeVideoMetadata instance) {
  final val = <String, dynamic>{
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
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('cloudThumbnailUrl', instance.cloudThumbnailUrl,
      instance.cloudThumbnailUrl, '');
  return val;
}

VimeoVideoMetadata _$VimeoVideoMetadataFromJson(Map json) => VimeoVideoMetadata(
      url: json['url'] as String,
      version: json['version'] as String,
      title: json['title'] as String,
      author: json['author_name'] as String,
      authorUrl: json['author_url'] as String,
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      duration: durationFromSeconds((json['duration'] as num).toInt()),
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

Map<String, dynamic> _$VimeoVideoMetadataToJson(VimeoVideoMetadata instance) {
  final val = <String, dynamic>{
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
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('cloudThumbnailUrl', instance.cloudThumbnailUrl,
      instance.cloudThumbnailUrl, '');
  return val;
}
