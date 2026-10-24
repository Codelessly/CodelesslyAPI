// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embedded_video_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$EmbeddedVideoNodeOmitDefaults(
  EmbeddedVideoNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.visible, true)) json.remove('visible');
  if (excludeConstraintsIf(instance)) json.remove('constraints');
  if (isJsonDefault(instance.constraints, const BoxConstraintsModel()))
    json.remove('constraints');
  if (isJsonDefault(instance.edgePins, EdgePinsModel.standard))
    json.remove('edgePins');
  if (isJsonDefault(instance.positioningMode, PositioningMode.align))
    json.remove('positioningMode');
  if (isJsonDefault(instance.horizontalFit, SizeFit.fixed))
    json.remove('horizontalFit');
  if (isJsonDefault(instance.verticalFit, SizeFit.fixed))
    json.remove('verticalFit');
  if (isJsonDefault(instance.flex, 1)) json.remove('flex');
  if (isJsonDefault(instance.squeezable, false)) json.remove('squeezable');
  if (isJsonDefault(instance.aspectRatioLock, false))
    json.remove('aspectRatioLock');
  if (isJsonDefault(instance.alignment, AlignmentModel.none))
    json.remove('alignment');
  if (isJsonDefault(instance.margin, EdgeInsetsModel.zero))
    json.remove('margin');
  if (isJsonDefault(instance.padding, EdgeInsetsModel.zero))
    json.remove('padding');
  if (isJsonDefault(instance.rotationDegrees, 0)) json.remove('rotation');
  if (isJsonDefault(instance.interactionStates, {}))
    json.remove('interactionStates');
  if (isJsonDefault(instance.tooltip, '')) json.remove('tooltip');
  if (isJsonDefault(instance.zoomable, false)) json.remove('zoomable');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.variables, {})) json.remove('variables');
  if (isJsonDefault(instance.multipleVariables, {}))
    json.remove('multipleVariables');
  if (isJsonDefault(instance.componentVersion, 1))
    json.remove('componentVersion');
  if (isJsonDefault(instance.componentSchema, {}))
    json.remove('componentSchema');
  if (isJsonDefault(instance.reactions, const [])) json.remove('reactions');
  return json;
}

Map<String, dynamic> _$EmbeddedYoutubeVideoPropertiesOmitDefaults(
  EmbeddedYoutubeVideoProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.mute, false)) json.remove('mute');
  if (isJsonDefault(instance.showControls, true)) json.remove('showControls');
  if (isJsonDefault(instance.showVideoAnnotations, true))
    json.remove('showVideoAnnotations');
  if (isJsonDefault(instance.showFullscreenButton, true))
    json.remove('showFullscreenButton');
  if (isJsonDefault(instance.loop, false)) json.remove('loop');
  if (isJsonDefault(instance.showCaptions, false)) json.remove('showCaptions');
  if (isJsonDefault(instance.startAt, 0)) json.remove('startAt');
  if (isJsonDefault(instance.captionLanguage, 'en'))
    json.remove('captionLanguage');
  if (isJsonDefault(instance.autoPlay, false)) json.remove('autoPlay');
  return json;
}

Map<String, dynamic> _$EmbeddedVimeoVideoPropertiesOmitDefaults(
  EmbeddedVimeoVideoProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.mute, false)) json.remove('mute');
  if (isJsonDefault(instance.showFullscreenButton, true))
    json.remove('showFullscreenButton');
  if (isJsonDefault(instance.loop, false)) json.remove('loop');
  if (isJsonDefault(instance.autoPlay, false)) json.remove('autoPlay');
  return json;
}

Map<String, dynamic> _$YoutubeVideoMetadataOmitDefaults(
  YoutubeVideoMetadata instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.cloudThumbnailUrl, ''))
    json.remove('cloudThumbnailUrl');
  return json;
}

Map<String, dynamic> _$VimeoVideoMetadataOmitDefaults(
  VimeoVideoMetadata instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.cloudThumbnailUrl, ''))
    json.remove('cloudThumbnailUrl');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmbeddedVideoNode _$EmbeddedVideoNodeFromJson(Map json) =>
    EmbeddedVideoNode(
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
        rotationDegrees: json['rotation'] == null
            ? 0
            : castRotation(json['rotation']),
        reactions:
            (json['reactions'] as List<dynamic>?)
                ?.map((e) => Reaction.fromJson(e as Map))
                .toList() ??
            const [],
        horizontalFit:
            $enumDecodeNullable(_$SizeFitEnumMap, json['horizontalFit']) ??
            SizeFit.fixed,
        verticalFit:
            $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
            SizeFit.fixed,
        flex: (json['flex'] as num?)?.toInt() ?? 1,
        aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
        constraints: json['constraints'] == null
            ? const BoxConstraintsModel()
            : BoxConstraintsModel.fromJson(json['constraints'] as Map),
        positioningMode:
            $enumDecodeNullable(
              _$PositioningModeEnumMap,
              json['positioningMode'],
            ) ??
            PositioningMode.align,
        edgePins: json['edgePins'] == null
            ? EdgePinsModel.standard
            : EdgePinsModel.fromJson(
                Map<String, dynamic>.from(json['edgePins'] as Map),
              ),
        properties: EmbeddedVideoProperties.fromJson(json['properties'] as Map),
        variables:
            (json['variables'] as Map?)?.map(
              (k, e) => MapEntry(k as String, e as String),
            ) ??
            {},
      )
      ..multipleVariables =
          (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(
              k as String,
              (e as List<dynamic>).map((e) => e as String).toList(),
            ),
          ) ??
          {}
      ..componentId = json['componentId'] as String?
      ..markerType = $enumDecodeNullable(
        _$ComponentMarkerTypeEnumMap,
        json['markerType'],
      )
      ..componentVersion = (json['componentVersion'] as num?)?.toInt() ?? 1
      ..componentSchema =
          (json['componentSchema'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e),
          ) ??
          {}
      ..squeezable = json['squeezable'] as bool? ?? false
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..interactionStates =
          (json['interactionStates'] as Map?)?.map(
            (k, e) => MapEntry(
              $enumDecode(_$InteractionStateEnumMap, k),
              (e as Map).map(
                (k, e) =>
                    MapEntry(k as String, Map<String, dynamic>.from(e as Map)),
              ),
            ),
          ) ??
          {}
      ..tooltip = json['tooltip'] as String? ?? ''
      ..zoomable = json['zoomable'] as bool? ?? false
      ..loopAnimation = json['loopAnimation'] == null
          ? null
          : LoopAnimation.fromJson(json['loopAnimation'] as Map)
      ..type = json['type'] as String;

Map<String, dynamic> _$EmbeddedVideoNodeToJson(EmbeddedVideoNode instance) =>
    <String, dynamic>{
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'variables': instance.variables,
      'multipleVariables': instance.multipleVariables,
      'componentId': ?instance.componentId,
      'markerType': ?_$ComponentMarkerTypeEnumMap[instance.markerType],
      'componentVersion': instance.componentVersion,
      'componentSchema': instance.componentSchema,
      'id': instance.id,
      'name': instance.name,
      'visible': instance.visible,
      'constraints': instance.constraints.toJson(),
      'edgePins': instance.edgePins.toJson(),
      'positioningMode': _$PositioningModeEnumMap[instance.positioningMode]!,
      'horizontalFit': _$SizeFitEnumMap[instance.horizontalFit]!,
      'verticalFit': _$SizeFitEnumMap[instance.verticalFit]!,
      'flex': instance.flex,
      'squeezable': instance.squeezable,
      'aspectRatioLock': instance.aspectRatioLock,
      'alignment': instance.alignment.toJson(),
      'basicBoxLocal': instance.basicBoxLocal.toJson(),
      'margin': instance.margin.toJson(),
      'padding': instance.padding.toJson(),
      'rotation': instance.rotationDegrees,
      'widthFactor': ?instance.widthFactor,
      'heightFactor': ?instance.heightFactor,
      'interactionStates': instance.interactionStates.map(
        (k, e) => MapEntry(_$InteractionStateEnumMap[k]!, e),
      ),
      'tooltip': instance.tooltip,
      'zoomable': instance.zoomable,
      'loopAnimation': ?instance.loopAnimation?.toJson(),
      'enabled': instance.enabled,
      'type': instance.type,
      'properties': instance.properties.toJson(),
    };

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

const _$InteractionStateEnumMap = {
  InteractionState.hovered: 'hovered',
  InteractionState.focused: 'focused',
  InteractionState.pressed: 'pressed',
  InteractionState.selected: 'selected',
  InteractionState.disabled: 'disabled',
};

EmbeddedYoutubeVideoProperties _$EmbeddedYoutubeVideoPropertiesFromJson(
  Map json,
) =>
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
              Map<String, dynamic>.from(json['metadata'] as Map),
            );

Map<String, dynamic> _$EmbeddedYoutubeVideoPropertiesToJson(
  EmbeddedYoutubeVideoProperties instance,
) => <String, dynamic>{
  'url': ?instance.url,
  'videoId': ?instance.videoId,
  'autoPlay': instance.autoPlay,
  'source': _$EmbeddedVideoSourceEnumMap[instance.source]!,
  'mute': instance.mute,
  'showControls': instance.showControls,
  'showVideoAnnotations': instance.showVideoAnnotations,
  'showFullscreenButton': instance.showFullscreenButton,
  'loop': instance.loop,
  'showCaptions': instance.showCaptions,
  'startAt': ?instance.startAt,
  'endAt': ?instance.endAt,
  'captionLanguage': instance.captionLanguage,
  'metadata': ?instance.metadata?.toJson(),
};

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
              Map<String, dynamic>.from(json['metadata'] as Map),
            );

Map<String, dynamic> _$EmbeddedVimeoVideoPropertiesToJson(
  EmbeddedVimeoVideoProperties instance,
) => <String, dynamic>{
  'url': ?instance.url,
  'videoId': ?instance.videoId,
  'autoPlay': instance.autoPlay,
  'source': _$EmbeddedVideoSourceEnumMap[instance.source]!,
  'mute': instance.mute,
  'showFullscreenButton': instance.showFullscreenButton,
  'loop': instance.loop,
  'metadata': ?instance.metadata?.toJson(),
};

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
  YoutubeVideoMetadata instance,
) => <String, dynamic>{
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
  duration: durationFromSeconds((json['duration'] as num).toInt()),
  description: json['description'] as String,
  thumbnailUrl: json['thumbnail_url'] as String,
  thumbnailWidth: (json['thumbnail_width'] as num).toDouble(),
  thumbnailHeight: (json['thumbnail_height'] as num).toDouble(),
  thumbnailUrlWithPlayButton: json['thumbnail_url_with_play_button'] as String,
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
