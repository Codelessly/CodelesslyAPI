// The media library's node types: video, embedded video, audio and web
// views, the platform views and players the SDK's media feature shows. One
// WidgetSpec per type; props with Flutter's names and defaults.
import '../../core/props.dart';
import '../../core/values/color.dart';
import '../../core/values/enums.dart';
import '../../core/json.dart';

const _json = Codecs.json;
const _optionalColor = Codecs.optionalColor;

/// A network video (`video_player`'s `VideoPlayer`).
abstract final class VideoProps {
  /// A remote HTTPS MP4, WebM, MOV or M4V URL.
  static const url = PropDef<String>('url', Codecs.string, '');
  static const autoPlay = PropDef<bool>('autoPlay', Codecs.bool, false);
  static const showControls = PropDef<bool>('showControls', Codecs.bool, true);

  /// Null leaves playback to the built-in controls. Bind or set explicitly
  /// to play/pause from application actions; browser gesture rules still apply.
  static const playing = PropDef<bool?>('playing', Codecs.optionalBool, null);

  /// Absolute source-media time in seconds; null leaves the current time alone.
  static const positionSeconds = PropDef<double?>('positionSeconds', Codecs.optionalPositive, null);
  static const volume = PropDef<double>('volume', DoubleCodec(min: 0, max: 1), 1);
  static const loop = PropDef<bool>('loop', Codecs.bool, false);

  /// How the picture fills the node (`FittedBox`): `contain` letterboxes,
  /// `cover` fills and crops.
  static const fit = PropDef<BoxFit>('fit', EnumCodec(BoxFit.values), BoxFit.contain);

  /// An image URL shown until the video has its first frame (and while a
  /// new source loads), instead of a spinner.
  static const poster = PropDef<String>('poster', Codecs.string, '');

  /// While playing, a changed [positionSeconds] seeks only when the video is
  /// more than this many seconds away from it, so a position bound to a
  /// running clock corrects drift instead of stalling the video with a seek
  /// every frame. Paused, every change seeks (the latest one wins).
  static const syncTolerance = PropDef<double>('syncTolerance', DoubleCodec(min: 0), 0.3);

  /// While playing, fires the changed trigger every this many milliseconds
  /// with `positionSeconds` and `playing` (0: off): the video as a clock.
  static const reportIntervalMs = PropDef<int>('reportIntervalMs', IntCodec(min: 0), 0);

  static const spec = WidgetSpec('video',
      props: [url, autoPlay, showControls, playing, positionSeconds, volume, loop, fit, poster, syncTolerance, reportIntervalMs],
      doc: '`VideoPlayer`. Its changed trigger reports ready/error and, when ready, durationSeconds/positionSeconds '
          'without autoplay; with reportIntervalMs, also positionSeconds/playing while it plays.');
}

/// Where an embedded video is hosted.
enum EmbeddedVideoSource { youtube, vimeo }

/// A YouTube or Vimeo video, played in a web view.
abstract final class EmbeddedVideoProps {
  static const source =
      PropDef<EmbeddedVideoSource>('source', EnumCodec(EmbeddedVideoSource.values), EmbeddedVideoSource.youtube);

  /// The video's page URL.
  static const url = PropDef<String>('url', Codecs.string, '');

  /// The host's id of the video.
  static const videoId = PropDef<String>('videoId', Codecs.string, '');
  static const autoPlay = PropDef<bool>('autoPlay', Codecs.bool, false);
  static const mute = PropDef<bool>('mute', Codecs.bool, false);
  static const loop = PropDef<bool>('loop', Codecs.bool, false);
  static const showControls = PropDef<bool>('showControls', Codecs.bool, true);
  static const showFullscreenButton = PropDef<bool>('showFullscreenButton', Codecs.bool, true);

  /// Optional application playback requests. Null retains provider controls.
  static const playing = PropDef<bool?>('playing', Codecs.optionalBool, null);
  static const positionSeconds = PropDef<double?>('positionSeconds', Codecs.optionalPositive, null);
  static const volume = PropDef<double?>('volume', DoubleCodec(min: 0, max: 1), null);

  /// YouTube only.
  static const showVideoAnnotations = PropDef<bool>('showVideoAnnotations', Codecs.bool, true);
  static const showCaptions = PropDef<bool>('showCaptions', Codecs.bool, false);
  static const captionLanguage = PropDef<String>('captionLanguage', Codecs.string, 'en');

  /// Start and end, in seconds (YouTube only).
  static const startAt = PropDef<int?>('startAt', OptionalIntCodec(), null);
  static const endAt = PropDef<int?>('endAt', OptionalIntCodec(), null);

  /// The host's oEmbed metadata (title, author, thumbnail), for previews.
  static const metadata = PropDef<Json>('metadata', _json, {});

  static const spec = WidgetSpec('embeddedVideo',
      props: [
        source, url, videoId, autoPlay, mute, loop, showControls, showFullscreenButton, showVideoAnnotations, //
        showCaptions, captionLanguage, startAt, endAt, metadata, playing, positionSeconds, volume,
      ],
      doc: 'An embedded YouTube / Vimeo player (`WebViewWidget`).');
}

/// A network audio player (`just_audio`).
abstract final class AudioPlayerProps {
  /// A remote HTTPS MP3, M4A, WAV, OGG or AAC URL.
  static const url = PropDef<String>('url', Codecs.string, '');

  /// Shown as the player's title.
  static const description = PropDef<String>('description', Codecs.string, '');
  static const autoPlay = PropDef<bool>('autoPlay', Codecs.bool, false);
  static const showControls = PropDef<bool>('showControls', Codecs.bool, true);
  static const loop = PropDef<bool>('loop', Codecs.bool, false);
  static const volume = PropDef<double>('volume', DoubleCodec(min: 0, max: 1), 1);

  /// Null leaves playback to autoPlay and the player's own controls.
  static const playing = PropDef<bool?>('playing', Codecs.optionalBool, null);
  static const positionSeconds = PropDef<double?>('positionSeconds', Codecs.optionalPositive, null);

  /// Plays without showing a player.
  static const background = PropDef<bool>('background', Codecs.bool, false);

  /// While playing, a changed [positionSeconds] seeks only when playback is
  /// more than this many seconds away from it (see [VideoProps.syncTolerance]).
  static const syncTolerance = PropDef<double>('syncTolerance', DoubleCodec(min: 0), 0.3);

  static const spec = WidgetSpec('audioPlayer',
      props: [url, description, autoPlay, showControls, loop, volume, background, playing, positionSeconds, syncTolerance],
      doc: 'An audio player.');
}

/// What a web view's [WebViewProps.source] is.
enum WebViewSourceType { url, html, asset }

/// Gestures a web view takes from the page around it
/// (`WebViewWidget.gestureRecognizers`).
enum WebViewGesture { verticalDrag, horizontalDrag, scale, tap, longPress, forcePress }

/// A web page (`webview_flutter`'s `WebViewWidget`).
abstract final class WebViewProps {
  static const sourceType =
      PropDef<WebViewSourceType>('sourceType', EnumCodec(WebViewSourceType.values), WebViewSourceType.url);

  /// A URL, an HTML document or a Flutter asset path, per [sourceType].
  static const source = PropDef<String>('source', Codecs.string, '');

  /// The settings an embed (`{"type": "googleMaps"|"twitter", ...}`) was
  /// generated from; [source] holds the generated HTML.
  static const embed = PropDef<Json>('embed', _json, {});
  static const gestures =
      PropDef<List<WebViewGesture>>('gestures', ListCodec(EnumCodec(WebViewGesture.values)), []);
  static const allowsInlineMediaPlayback = PropDef<bool>('allowsInlineMediaPlayback', Codecs.bool, false);
  static const mediaPlaybackRequiresUserAction = PropDef<bool>('mediaPlaybackRequiresUserAction', Codecs.bool, true);
  static const backgroundColor = PropDef<Color?>('backgroundColor', _optionalColor, null);

  static const spec = WidgetSpec('webView',
      props: [
        sourceType, source, embed, gestures, allowsInlineMediaPlayback, mediaPlaybackRequiresUserAction, //
        backgroundColor,
      ],
      doc: '`WebViewWidget`.');
}

/// The media library's node types: video, embedded video, audio and web
/// views (platform views and players).
const List<WidgetSpec> mediaSpecs = [
  VideoProps.spec,
  EmbeddedVideoProps.spec,
  AudioPlayerProps.spec,
  WebViewProps.spec,
];
