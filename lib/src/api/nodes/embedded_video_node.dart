import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'embedded_video_node.g.dart';

/// Source of embedded video.
enum EmbeddedVideoSource {
  /// Youtube video.
  youtube,

  /// Vimeo video.
  vimeo
}

/// This creates a WebView with an embedded video.
/// Source of the video can be any one of the [EmbeddedVideoSource] values.
@JsonSerializable()
class EmbeddedVideoNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'embeddedVideo';

  /// Holds configurable properties of the embedded video.
  @override
  covariant EmbeddedVideoProperties properties;

  /// Whether the video source url is provided.
  bool get hasUrl =>
      properties.url != null && properties.url!.trim().isNotEmpty;

  @override
  bool get supportsPadding => false;

  /// Creates a blank embedded video preview.
  EmbeddedVideoNode.empty()
      : properties = EmbeddedYoutubeVideoProperties(),
        super(
          id: 'EmbeddedVideo',
          name: 'Embedded Video',
          basicBoxLocal:
              NodeBox(0, 0, kSliderDefaultWidth, kSliderDefaultHeight),
        );

  /// Creates a [EmbeddedVideoNode] instance with the given data.
  EmbeddedVideoNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.visible,
    super.alignment,
    super.padding,
    super.margin,
    super.rotationDegrees,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.aspectRatioLock,
    super.constraints,
    super.parentID,
    super.positioningMode,
    super.edgePins,
    // Custom properties.
    required this.properties,
    super.variables,
  });

  /// Creates a [EmbeddedVideoNode] from a JSON object.
  factory EmbeddedVideoNode.fromJson(Map json) =>
      _$EmbeddedVideoNodeFromJson(json);

  @override
  Map toJson() => _$EmbeddedVideoNodeToJson(this);
}

/// Holds configurable properties of the embedded video.
abstract class EmbeddedVideoProperties extends CustomProperties {
  /// Video's source URL.
  String? url;

  /// Video's ID extracted from the URL.
  String? videoId;

  /// Whether to play the video automatically.
  bool autoPlay;

  /// Source of the video, i.e., youtube, vimeo, etc.
  late EmbeddedVideoSource source;

  /// Returns youtube specific video properties.
  EmbeddedYoutubeVideoProperties get forYoutube {
    assert(source == EmbeddedVideoSource.youtube);
    return this as EmbeddedYoutubeVideoProperties;
  }

  /// Returns vimeo specific video properties.
  EmbeddedVimeoVideoProperties get forVimeo {
    assert(source == EmbeddedVideoSource.vimeo);
    return this as EmbeddedVimeoVideoProperties;
  }

  /// Creates a [EmbeddedVideoProperties] instance with the given data.
  EmbeddedVideoProperties({this.url, required this.autoPlay});

  /// Creates a [EmbeddedVideoProperties] instance from a JSON object.
  factory EmbeddedVideoProperties.fromJson(Map json) {
    switch (EmbeddedVideoSource.values.byName(json['source'])) {
      case EmbeddedVideoSource.youtube:
        return EmbeddedYoutubeVideoProperties.fromJson(json);
      case EmbeddedVideoSource.vimeo:
        return EmbeddedVimeoVideoProperties.fromJson(json);
    }
  }
}

/// Holds configurable properties of the embedded youtube video.
@JsonSerializable()
class EmbeddedYoutubeVideoProperties extends EmbeddedVideoProperties {
  /// Creates a [EmbeddedYoutubeVideoProperties] instance with the given data.
  EmbeddedYoutubeVideoProperties({
    super.url,
    this.mute = false,
    this.showControls = true,
    super.autoPlay = false,
    this.showFullscreenButton = true,
    this.showVideoAnnotations = true,
    this.loop = false,
    this.showCaptions = false,
    this.startAt = 0,
    this.endAt,
    this.captionLanguage = 'en',
  });

  @override
  final EmbeddedVideoSource source = EmbeddedVideoSource.youtube;

  /// Whether to mute the video.
  bool mute;

  /// Whether to show controls for the video.
  bool showControls;

  /// Whether to show annotations for the video.
  bool showVideoAnnotations;

  /// Whether to show the full screen button for the video.
  bool showFullscreenButton;

  /// Whether to loop the video.
  bool loop;

  /// Whether to show video captions.
  bool showCaptions;

  /// Starting point of the video.
  int? startAt;

  /// Ending point of the video.
  int? endAt;

  /// Video captions' language.
  String captionLanguage;

  /// Video's metadata.
  YoutubeVideoMetadata? metadata;

  @override
  List<Object?> get props => [
        url,
        mute,
        showControls,
        autoPlay,
        showFullscreenButton,
        showVideoAnnotations,
        loop,
        showCaptions,
        startAt,
        endAt,
        captionLanguage,
        metadata
      ];

  /// Creates a [EmbeddedYoutubeVideoProperties] instance from a JSON object.
  factory EmbeddedYoutubeVideoProperties.fromJson(Map json) =>
      _$EmbeddedYoutubeVideoPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EmbeddedYoutubeVideoPropertiesToJson(this);
}

/// Holds configurable properties of the embedded vimeo video.
@JsonSerializable()
class EmbeddedVimeoVideoProperties extends EmbeddedVideoProperties {
  @override
  final EmbeddedVideoSource source = EmbeddedVideoSource.vimeo;

  /// Whether to mute the video.
  bool mute;

  /// Whether to show the full screen button for the video.
  bool showFullscreenButton;

  /// Whether to loop the video.
  bool loop;

  /// Video's metadata.
  VimeoVideoMetadata? metadata;

  /// Creates a [EmbeddedVimeoVideoProperties] instance with the given data.
  EmbeddedVimeoVideoProperties({
    super.url,
    this.mute = false,
    super.autoPlay = false,
    this.loop = false,
    this.showFullscreenButton = true,
  });

  @override
  List<Object?> get props => [url, mute, autoPlay, loop, showFullscreenButton];

  /// Creates a [EmbeddedVimeoVideoProperties] instance from a JSON object.
  factory EmbeddedVimeoVideoProperties.fromJson(Map json) =>
      _$EmbeddedVimeoVideoPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EmbeddedVimeoVideoPropertiesToJson(this);
}

/// Holds metadata of the youtube video.
@JsonSerializable()
class YoutubeVideoMetadata with SerializableMixin, EquatableMixin {
  /// Video's source URL.
  final String url;

  /// Video's title.
  final String title;

  /// Name of video's author.
  @JsonKey(name: 'author_name')
  final String author;

  /// URL of video's author page.
  @JsonKey(name: 'author_url')
  final String authorUrl;

  /// Width of video.
  final double width;

  /// Height of video.
  final double height;

  /// URL of video's thumbnail.
  @JsonKey(name: 'thumbnail_url')
  final String thumbnailUrl;

  /// Width of video's thumbnail.
  @JsonKey(name: 'thumbnail_width')
  final double thumbnailWidth;

  /// Height of video's thumbnail.
  @JsonKey(name: 'thumbnail_height')
  final double thumbnailHeight;

  /// Video provider service name, i.e., youtube in this case.
  @JsonKey(name: 'provider_name')
  final String providerName;

  /// HTML code required to render the video iFrame in WebView.
  final String html;

  /// URL of video thumbnail stored in Codelessly servers.
  final String cloudThumbnailUrl;

  /// Creates a [YoutubeVideoMetadata] instance with the given data.
  YoutubeVideoMetadata({
    required this.url,
    required this.title,
    required this.author,
    required this.authorUrl,
    required this.width,
    required this.height,
    required this.thumbnailUrl,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    required this.providerName,
    required this.html,
    this.cloudThumbnailUrl = '',
  });

  /// Creates a mock youtube video preview.
  YoutubeVideoMetadata.empty({
    this.url = '',
    this.title = 'Title',
    this.author = 'author',
    this.authorUrl = '',
    required this.width,
    required this.height,
    this.thumbnailUrl = '',
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    this.providerName = '',
    this.html = '',
    this.cloudThumbnailUrl = '',
  });

  /// Duplicates this [YoutubeVideoMetadata] instance with the given data
  /// overrides.
  YoutubeVideoMetadata copyWith({
    String? url,
    String? title,
    String? author,
    String? authorUrl,
    double? width,
    double? height,
    String? thumbnailUrl,
    double? thumbnailWidth,
    double? thumbnailHeight,
    String? providerName,
    String? html,
    String? cloudThumbnailUrl,
  }) {
    return YoutubeVideoMetadata(
      url: url ?? this.url,
      title: title ?? this.title,
      author: author ?? this.author,
      authorUrl: authorUrl ?? this.authorUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      thumbnailWidth: thumbnailWidth ?? this.thumbnailWidth,
      thumbnailHeight: thumbnailHeight ?? this.thumbnailHeight,
      providerName: providerName ?? this.providerName,
      html: html ?? this.html,
      cloudThumbnailUrl: cloudThumbnailUrl ?? this.cloudThumbnailUrl,
    );
  }

  @override
  List<Object?> get props => [
        url,
        title,
        author,
        authorUrl,
        width,
        height,
        thumbnailUrl,
        thumbnailWidth,
        thumbnailHeight,
        providerName,
        html,
      ];

  /// Creates a [YoutubeVideoMetadata] instance from a JSON object.
  factory YoutubeVideoMetadata.fromJson(Map<String, dynamic> json) =>
      _$YoutubeVideoMetadataFromJson(json);

  @override
  Map toJson() => _$YoutubeVideoMetadataToJson(this);
}

/// Holds metadata of the vimeo video.
@JsonSerializable()
class VimeoVideoMetadata with SerializableMixin, EquatableMixin {
  /// Video's source URL.
  final String url;

  /// Video's version.
  final String version;

  /// Video's title.
  final String title;

  /// Name of video's author.
  @JsonKey(name: 'author_name')
  final String author;

  /// URL of video's author page.
  @JsonKey(name: 'author_url')
  final String authorUrl;

  /// Width of video.
  final double width;

  /// Height of video.
  final double height;

  /// Video duration.
  @JsonKey(fromJson: durationFromSeconds)
  final Duration duration;

  /// Video's description.
  final String description;

  /// URL of video's thumbnail.
  @JsonKey(name: 'thumbnail_url')
  final String thumbnailUrl;

  /// Width of video's thumbnail.
  @JsonKey(name: 'thumbnail_width')
  final double thumbnailWidth;

  /// Height of video's thumbnail.
  @JsonKey(name: 'thumbnail_height')
  final double thumbnailHeight;

  /// URL of thumbnail with play button.
  @JsonKey(name: 'thumbnail_url_with_play_button')
  final String thumbnailUrlWithPlayButton;

  /// Upload date of video.
  @JsonKey(name: 'upload_date')
  final String uploadDate;

  /// Video provider service name, i.e., vimeo in this case.
  @JsonKey(name: 'provider_name')
  final String providerName;

  /// HTML code required to render the video iFrame in WebView.
  final String html;

  /// URL of video thumbnail stored in Codelessly servers.
  final String cloudThumbnailUrl;

  /// Creates a [VimeoVideoMetadata] instance with the given data.
  VimeoVideoMetadata({
    required this.url,
    required this.version,
    required this.title,
    required this.author,
    required this.authorUrl,
    required this.width,
    required this.height,
    required this.duration,
    required this.description,
    required this.thumbnailUrl,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    required this.thumbnailUrlWithPlayButton,
    required this.uploadDate,
    required this.providerName,
    required this.html,
    this.cloudThumbnailUrl = '',
  });

  /// Creates a mock vimeo video preview.
  VimeoVideoMetadata.empty({
    this.url = '',
    this.version = '',
    this.title = 'Title',
    this.author = 'author',
    this.authorUrl = '',
    required this.width,
    required this.height,
    this.duration = Duration.zero,
    this.description = '',
    this.thumbnailUrl = '',
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    this.thumbnailUrlWithPlayButton = '',
    this.uploadDate = '',
    this.providerName = '',
    this.html = '',
    this.cloudThumbnailUrl = '',
  });

  /// Duplicates this [VimeoVideoMetadata] instance with the given data
  /// overrides.
  VimeoVideoMetadata copyWith({
    String? url,
    String? version,
    String? title,
    String? author,
    String? authorUrl,
    double? width,
    double? height,
    Duration? duration,
    String? description,
    String? thumbnailUrl,
    double? thumbnailWidth,
    double? thumbnailHeight,
    String? thumbnailUrlWithPlayButton,
    String? uploadDate,
    String? providerName,
    String? html,
    String? cloudThumbnailUrl,
  }) {
    return VimeoVideoMetadata(
      url: url ?? this.url,
      version: version ?? this.version,
      title: title ?? this.title,
      author: author ?? this.author,
      authorUrl: authorUrl ?? this.authorUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      thumbnailWidth: thumbnailWidth ?? this.thumbnailWidth,
      thumbnailHeight: thumbnailHeight ?? this.thumbnailHeight,
      thumbnailUrlWithPlayButton:
          thumbnailUrlWithPlayButton ?? this.thumbnailUrlWithPlayButton,
      uploadDate: uploadDate ?? this.uploadDate,
      providerName: providerName ?? this.providerName,
      html: html ?? this.html,
      cloudThumbnailUrl: cloudThumbnailUrl ?? this.cloudThumbnailUrl,
    );
  }

  @override
  List<Object?> get props => [
        url,
        version,
        title,
        author,
        authorUrl,
        width,
        height,
        duration,
        description,
        thumbnailUrl,
        thumbnailWidth,
        thumbnailHeight,
        thumbnailUrlWithPlayButton,
        uploadDate,
        providerName,
      ];

  /// Creates a [YoutubeVideoMetadata] instance from a JSON object.
  factory VimeoVideoMetadata.fromJson(Map<String, dynamic> json) =>
      _$VimeoVideoMetadataFromJson(json);

  @override
  Map toJson() => _$VimeoVideoMetadataToJson(this);
}

/// Helper method that returns Duration in seconds from the provided [value].
Duration durationFromSeconds(int value) => Duration(seconds: value);
