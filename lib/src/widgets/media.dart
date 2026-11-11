// Widget declarations: media (vector paths, video, audio, web views) and
// slots filled by the app (placeholders, external components). One
// WidgetSpec per type; props with Flutter's names and defaults (see
// ../props.dart).
import '../json.dart';
import '../props.dart';
import '../values/color.dart';
import '../values/enums.dart';

/// A size `[width, height]`, or null.
List<double>? _sizeIn(Object? j) {
  final l = readList(j)?.map(readDouble).toList();
  if (l == null || l.length != 2 || l.any((v) => v == null || v < 0)) return null;
  return l.cast<double>();
}

Object? _sizeOut(List<double>? s) => s?.map(writeDouble).toList();

/// `[width, height]` (a view box, a maximum size).
const _size = ValueCodec<List<double>?>(_sizeIn, _sizeOut, PropType.value('Size'));
const _json = Codecs.json;
const _optionalColor = Codecs.optionalColor;
const _strings = Codecs.strings;

/// Colors one per entry, an entry that isn't a color kept as null (so the
/// others keep their index): a list, or text separated by commas, spaces or
/// semicolons (as a binding may give).
List<Color?>? _colorsIn(Object? j) {
  final items = switch (j) {
    final List l => l,
    final String s => s.split(RegExp(r'[\s,;]+')).where((e) => e.isNotEmpty).toList(),
    _ => null,
  };
  return items?.map((e) => Color.fromJson(e is String ? e.trim() : e)).toList();
}

Object? _colorsOut(List<Color?> v) => [for (final c in v) c?.toJson()];

/// An SVG path, filled and stroked with the node's decoration
/// (Flutter `CustomPaint`).
abstract final class PathProps {
  /// SVG path data (`M0 0 L10 10 Z`).
  static const data = PropDef<String>('data', Codecs.string, '');

  /// The coordinate space of [data], `[width, height]`, scaled to the box.
  /// Null: [data] is in the box's own pixels.
  static const viewBox = PropDef<List<double>?>('viewBox', _size, null);

  /// The stroked part of the path, as fractions of its length.
  static const trimStart = PropDef<double>('trimStart', DoubleCodec(min: 0, max: 1), 0);
  static const trimEnd = PropDef<double>('trimEnd', DoubleCodec(min: 0, max: 1), 1);

  /// How segments meet when stroked (`Paint.strokeJoin`).
  static const strokeJoin = PropDef<StrokeJoin>('strokeJoin', EnumCodec(StrokeJoin.values), StrokeJoin.miter);

  /// Colors of the path's shapes, one per closed subpath (`M ... Z`) in
  /// drawing order, repeating when shorter; a subpath inside the previous
  /// shape's bounds (a hole) belongs to it. They replace the solid fills'
  /// color (keeping each fill's opacity); null keeps the fill's color.
  static const subpathColors = PropDef<List<Color?>>(
    'subpathColors',
    ValueCodec(_colorsIn, _colorsOut, PropType.list(PropTypes.color)),
    [],
  );

  static const spec = WidgetSpec('path',
      props: [data, viewBox, trimStart, trimEnd, strokeJoin, subpathColors],
      decorated: true,
      doc: 'Flutter `CustomPaint` of an SVG path.');
}

/// A network video (`video_player`'s `VideoPlayer`).
abstract final class VideoProps {
  /// A remote HTTPS MP4 URL.
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

  static const spec = WidgetSpec('video', props: [url, autoPlay, showControls, playing, positionSeconds, volume, loop], doc: '`VideoPlayer`.');
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
        showCaptions, captionLanguage, startAt, endAt, metadata,
      ],
      doc: 'An embedded YouTube / Vimeo player (`WebViewWidget`).');
}

/// A network audio player (`just_audio`).
abstract final class AudioPlayerProps {
  /// A remote HTTPS MP3, M4A or WAV URL.
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

  static const spec = WidgetSpec('audioPlayer',
      props: [url, description, autoPlay, showControls, loop, volume, background, playing, positionSeconds], doc: 'An audio player.');
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

/// A widget the app builds (`Codelessly`'s external component builders).
abstract final class ExternalProps {
  /// The id of the app's builder.
  static const builderId = PropDef<String>('builderId', Codecs.string, '');
  static const spec = WidgetSpec('external', props: [builderId], doc: 'A widget built by the app.');
}

/// An empty slot shown at design time (Flutter `SizedBox`).
abstract final class PlaceholderProps {
  static const text = PropDef<String>('text', Codecs.string, '');
  static const leadingAsset = PropDef<String>('leadingAsset', Codecs.string, '');
  static const spec = WidgetSpec('placeholder', props: [text, leadingAsset], doc: 'An empty slot (`SizedBox`).');
}

/// A slot that shows its one child, or keeps its size when empty.
abstract final class SinglePlaceholderProps {
  /// The node types the slot accepts (empty: any) and refuses.
  static const allowedTypes = PropDef<List<String>>('allowedTypes', _strings, []);
  static const deniedTypes = PropDef<List<String>>('deniedTypes', _strings, []);

  /// The largest child it accepts, `[width, height]`.
  static const maxAllowedSize = PropDef<List<double>?>('maxAllowedSize', _size, null);

  /// Its child is temporary (not kept when the slot is filled again).
  static const ephemeral = PropDef<bool>('ephemeral', Codecs.bool, false);

  static const spec = WidgetSpec('singlePlaceholder',
      props: [allowedTypes, deniedTypes, maxAllowedSize, ephemeral],
      children: ChildModel.list,
      doc: 'A one-child slot.');
}

const List<WidgetSpec> mediaSpecs = [
  PathProps.spec,
  VideoProps.spec,
  EmbeddedVideoProps.spec,
  AudioPlayerProps.spec,
  WebViewProps.spec,
  ExternalProps.spec,
  PlaceholderProps.spec,
  SinglePlaceholderProps.spec,
];
