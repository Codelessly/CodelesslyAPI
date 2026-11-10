import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';
import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'audio_player_node.g.dart';

/// Native playback of a remote HTTPS MP3, M4A, or WAV audio file.
@FlutterNode(
  'CodelesslyAudioPlayer',
  family: 'codelessly',
  nodeType: 'audioPlayer',
)
@JsonSerializable()
class AudioPlayerNode extends SceneNode
    with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'audioPlayer';

  @override
  covariant AudioPlayerProperties properties;

  @override
  bool get supportsPadding => false;

  AudioPlayerNode.empty()
    : properties = AudioPlayerProperties(),
      super(
        id: 'AudioPlayer',
        name: 'Audio Player',
        basicBoxLocal: NodeBox(0, 0, 320, 64),
      );

  AudioPlayerNode({
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
    'properties': ObjectFieldAccess<AudioPlayerProperties>(
      'Properties',
      'Native audio playback settings.',
      () => properties,
      (value) => properties = value,
    ),
  };

  factory AudioPlayerNode.fromJson(Map json) => _$AudioPlayerNodeFromJson(json);

  @override
  Map toJson() =>
      _$AudioPlayerNodeOmitDefaults(this, _$AudioPlayerNodeToJson(this));
}

/// A syntax check, not an SSRF guarantee. Redirects and DNS belong to the
/// platform player and OS; a runtime host policy must be enforced separately.
bool isRemoteAudioUrl(String url) {
  if (url.trim() != url || url.contains('\\') || url.contains(RegExp(r'\s')))
    return false;
  final uri = Uri.tryParse(url);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.userInfo.isNotEmpty ||
      uri.hasFragment ||
      uri.host.isEmpty ||
      uri.host.endsWith('.') ||
      !RegExp(r'\.(mp3|m4a|wav)$', caseSensitive: false).hasMatch(uri.path))
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
      !host.contains('.'))
    return false;
  final parts = host.split('.');
  final second = parts.length > 1 ? int.tryParse(parts[1]) : null;
  return !(parts.first == '172' &&
      second != null &&
      second >= 16 &&
      second <= 31);
}

/// Validates both incoming and outgoing wire values.
String? validateAudioUrl(String? value) {
  if (value != null && !isRemoteAudioUrl(value)) {
    throw FormatException(
      'Expected a remote HTTPS MP3, M4A, or WAV URL',
      value,
    );
  }
  return value;
}

@JsonSerializable()
class AudioPlayerProperties extends CustomProperties with FieldsHolder {
  @JsonKey(fromJson: validateAudioUrl, toJson: validateAudioUrl)
  @FlutterProp(
    'url',
    type: 'string',
    group: 'Content',
    control: 'text',
    field: 'properties.url',
  )
  String? url;

  @FlutterProp(
    'description',
    type: 'string',
    group: 'Content',
    control: 'text',
    field: 'properties.description',
  )
  String? description;

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

  /// Starts again from the beginning when the end is reached, for ambient
  /// loops such as rain or waves.
  @FlutterProp(
    'loop',
    type: 'boolean',
    group: 'Playback',
    control: 'switch',
    field: 'properties.loop',
  )
  bool loop;

  /// Playback volume, 0 (silent) to 1 (full). Bind `volume` in the node's
  /// variables to follow a slider.
  @FlutterProp(
    'volume',
    type: 'number',
    group: 'Playback',
    control: 'number',
    field: 'properties.volume',
  )
  double volume;

  /// Plays without drawing a player: a sound source driven by state (bind
  /// `playing`, `volume` and `playKey`) instead of by its own controls.
  @FlutterProp(
    'background',
    type: 'boolean',
    group: 'Playback',
    control: 'switch',
    field: 'properties.background',
  )
  bool background;

  AudioPlayerProperties({
    String? url,
    this.description,
    this.autoPlay = false,
    this.showControls = true,
    this.loop = false,
    this.volume = 1,
    this.background = false,
  }) : url = validateAudioUrl(url);

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'url': StringFieldAccess(
      'URL',
      'Remote HTTPS MP3, M4A, or WAV URL.',
      () => url ?? '',
      (value) => url = value.isEmpty ? null : validateAudioUrl(value),
    ),
    'description': StringFieldAccess(
      'Description',
      'Description of the audio.',
      () => description ?? '',
      (value) => description = value.isEmpty ? null : value,
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
    'loop': BoolFieldAccess(
      'Loop',
      'Start again from the beginning at the end.',
      () => loop,
      (value) => loop = value,
    ),
    'volume': NumFieldAccess<double>(
      'Volume',
      'Playback volume, 0 to 1.',
      () => volume,
      (value) => volume = value.clamp(0, 1).toDouble(),
      min: 0,
      max: 1,
    ),
    'background': BoolFieldAccess(
      'Background',
      'Play without showing a player.',
      () => background,
      (value) => background = value,
    ),
  };

  /// Node variable keys that drive playback from state.
  ///
  /// * `url`: the audio URL, e.g. `${sounds.rain}`.
  /// * `volume`: 0..1, e.g. `${rain}` for a mixer slider.
  /// * `playing`: plays while true and pauses while false.
  /// * `playKey`: plays from the start whenever its value changes (a chime
  ///   on every phase change: `${phase}`).
  static const List<String> bindableKeys = ['url', 'volume', 'playing', 'playKey'];

  @override
  List<Object?> get props => [
    url,
    description,
    autoPlay,
    showControls,
    loop,
    volume,
    background,
  ];

  factory AudioPlayerProperties.fromJson(Map json) =>
      _$AudioPlayerPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AudioPlayerPropertiesOmitDefaults(
    this,
    _$AudioPlayerPropertiesToJson(this),
  );
}
