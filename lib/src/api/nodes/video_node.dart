import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';
import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'video_node.g.dart';

/// Native playback of a remote HTTPS MP4; not an embedded web video.
@FlutterNode('CodelesslyVideo', family: 'codelessly', nodeType: 'video')
@JsonSerializable()
class VideoNode extends SceneNode with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'video';

  @override
  covariant VideoProperties properties;

  @override
  bool get supportsPadding => false;

  VideoNode.empty()
    : properties = VideoProperties(),
      super(id: 'Video', name: 'Video', basicBoxLocal: NodeBox(0, 0, 320, 180));

  VideoNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.visible,
    super.enabled,
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
    required this.properties,
    super.variables,
  });

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<VideoProperties>(
      'Properties',
      'Native video playback settings.',
      () => properties,
      (value) => properties = value,
    ),
  };

  factory VideoNode.fromJson(Map json) => _$VideoNodeFromJson(json);

  @override
  Map toJson() => _$VideoNodeOmitDefaults(this, _$VideoNodeToJson(this));
}

/// A URL is a candidate only; GenUI may enforce an app-supplied host policy.
/// Redirect handling and DNS resolution belong to the platform player and OS.
bool isRemoteMp4Url(String url) {
  if (url.trim() != url || url.contains('\\') || url.contains(RegExp(r'\s')))
    return false;
  final uri = Uri.tryParse(url);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.userInfo.isNotEmpty ||
      uri.hasFragment ||
      uri.host.isEmpty ||
      uri.host.endsWith('.') ||
      !uri.path.toLowerCase().endsWith('.mp4'))
    return false;
  final host = uri.host.toLowerCase();
  if (host == 'localhost' ||
      host.endsWith('.localhost') ||
      host.endsWith('.local') ||
      host.endsWith('.internal') ||
      host == '0.0.0.0' ||
      host == '::1' ||
      host.startsWith('127.') ||
      host.startsWith('10.') ||
      host.startsWith('192.168.') ||
      host.startsWith('169.254.') ||
      host.startsWith('172.') && _private172(host) ||
      !host.contains('.'))
    return false;
  // IP literals and DNS names resolving to private networks require a runtime
  // allowlist and network-level checks; do not treat this syntax check as SSRF protection.
  return true;
}

bool _private172(String host) {
  final parts = host.split('.');
  final second = parts.length > 1 ? int.tryParse(parts[1]) : null;
  return second != null && second >= 16 && second <= 31;
}

/// Checks wire input and output; the runtime must additionally enforce a host allowlist.
String? validateVideoUrl(String? value) {
  if (value != null && !isRemoteMp4Url(value)) {
    throw FormatException('Expected a remote HTTPS MP4 URL', value);
  }
  return value;
}

@JsonSerializable()
class VideoProperties extends CustomProperties with FieldsHolder {
  @JsonKey(fromJson: validateVideoUrl, toJson: validateVideoUrl)
  @FlutterProp(
    'url',
    type: 'string',
    group: 'Content',
    control: 'text',
    field: 'properties.url',
  )
  String? url;

  @FlutterProp(
    'autoPlay',
    type: 'boolean',
    group: 'Playback',
    control: 'switch',
    field: 'properties.autoPlay',
  )
  bool autoPlay;

  @FlutterProp(
    'showControls',
    type: 'boolean',
    group: 'Playback',
    control: 'switch',
    field: 'properties.showControls',
  )
  bool showControls;

  VideoProperties({
    String? url,
    this.autoPlay = false,
    this.showControls = true,
  }) : url = validateVideoUrl(url);

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'url': StringFieldAccess(
      'URL',
      'Remote HTTPS MP4 URL.',
      () => url ?? '',
      (value) => url = value.isEmpty ? null : value,
    ),
    'autoPlay': BoolFieldAccess(
      'Auto Play',
      'Play automatically.',
      () => autoPlay,
      (value) => autoPlay = value,
    ),
    'showControls': BoolFieldAccess(
      'Show Controls',
      'Show playback controls.',
      () => showControls,
      (value) => showControls = value,
    ),
  };

  @override
  List<Object?> get props => [url, autoPlay, showControls];

  factory VideoProperties.fromJson(Map json) => _$VideoPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$VideoPropertiesOmitDefaults(this, _$VideoPropertiesToJson(this));
}
