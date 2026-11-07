// v1 → v2 migrations: media widgets (vector paths, video, audio, web views)
// and slots the app fills (placeholders, external components). See
// TypeMigration in ../migrate.dart.
import 'package:codelessly_api/codelessly_api.dart';

import '../migrate.dart';

/// By v1 node type.
final Map<String, TypeMigration> mediaMigrations = {
  'path': TypeMigration(type: (_) => 'path', decorated: true, props: _path),
  'video': TypeMigration(type: (_) => 'video', props: _video),
  'embeddedVideo': TypeMigration(type: (_) => 'embeddedVideo', props: _embeddedVideo),
  'audioPlayer': TypeMigration(type: (_) => 'audioPlayer', props: _audioPlayer),
  'webView': TypeMigration(type: (_) => 'webView', props: _webView),
  'external': TypeMigration(type: (_) => 'external', props: _external),
  'placeholder': TypeMigration(type: (_) => 'placeholder', props: _placeholder),
  'singlePlaceholder': TypeMigration(type: (_) => 'singlePlaceholder', props: _singlePlaceholder),
};

Json _path(V1Node m) {
  final n = m.n as PathNode;
  for (final k in const ['pathData', 'viewBoxWidth', 'viewBoxHeight', 'trimStart', 'trimEnd', 'strokeJoin']) {
    m.take(k);
  }
  // Not drawn by SDK 8.x's path: a mask flag and the miter limit (its joins
  // are never mitered past the default).
  m.take('isMask');
  m.take('strokeMiterLimit');
  final w = n.viewBoxWidth, h = n.viewBoxHeight;
  return {
    if (n.pathData.isNotEmpty) 'data': n.pathData,
    if (w != null && h != null) 'viewBox': [roundNum(w), roundNum(h)],
    if (n.trimStart != 0) 'trimStart': roundNum(n.trimStart),
    if (n.trimEnd != 1) 'trimEnd': roundNum(n.trimEnd),
    if (n.strokeJoin.name != 'miter') 'strokeJoin': n.strokeJoin.name,
  };
}

Json _video(V1Node m) {
  m.take('properties');
  final p = (m.n as VideoNode).properties;
  return {
    if (p.url case final String url when url.isNotEmpty) 'url': url,
    if (p.autoPlay) 'autoPlay': true,
    if (!p.showControls) 'showControls': false,
  };
}

Json _embeddedVideo(V1Node m) {
  m.take('properties');
  final p = (m.n as EmbeddedVideoNode).properties;
  final j = <String, Object?>{
    if (p.source != EmbeddedVideoSource.youtube) 'source': p.source.name,
    if (p.url case final String url when url.isNotEmpty) 'url': url,
    if (p.videoId case final String id when id.isNotEmpty) 'videoId': id,
    if (p.autoPlay) 'autoPlay': true,
  };
  switch (p) {
    case EmbeddedYoutubeVideoProperties():
      if (p.mute) j['mute'] = true;
      if (p.loop) j['loop'] = true;
      if (!p.showControls) j['showControls'] = false;
      if (!p.showFullscreenButton) j['showFullscreenButton'] = false;
      if (!p.showVideoAnnotations) j['showVideoAnnotations'] = false;
      if (p.showCaptions) j['showCaptions'] = true;
      if (p.captionLanguage != 'en') j['captionLanguage'] = p.captionLanguage;
      if (p.startAt case final int s when s != 0) j['startAt'] = s;
      if (p.endAt case final int e) j['endAt'] = e;
      if (p.metadata case final YoutubeVideoMetadata md) j['metadata'] = Map<String, Object?>.from(md.toJson());
    case EmbeddedVimeoVideoProperties():
      if (p.mute) j['mute'] = true;
      if (p.loop) j['loop'] = true;
      if (!p.showFullscreenButton) j['showFullscreenButton'] = false;
      if (p.metadata case final VimeoVideoMetadata md) j['metadata'] = Map<String, Object?>.from(md.toJson());
  }
  return j;
}

Json _audioPlayer(V1Node m) {
  m.take('properties');
  final p = (m.n as AudioPlayerNode).properties;
  return {
    if (p.url case final String url when url.isNotEmpty) 'url': url,
    if (p.description case final String d when d.isNotEmpty) 'description': d,
    if (p.autoPlay) 'autoPlay': true,
    if (!p.showControls) 'showControls': false,
    if (p.loop) 'loop': true,
    if (p.volume != 1) 'volume': roundNum(p.volume.clamp(0, 1)),
    if (p.background) 'background': true,
  };
}

/// The settings every v1 web view has; the rest of a map or tweet embed's
/// settings are kept as its `embed`.
const _webViewBase = {
  'src', 'webviewType', 'controlVerticalScrollGesture', 'controlHorizontalScrollGesture', 'controlScaleGesture', //
  'controlTapGesture', 'controlLongPressGesture', 'controlForcePressGesture', 'allowsInlineMediaPlayback',
  'mediaAutoPlaybackPolicy', 'backgroundColor',
};

Json _webView(V1Node m) {
  m.take('properties');
  final p = (m.n as WebViewNode).properties;
  final j = <String, Object?>{};
  switch (p) {
    case WebPageWebViewProperties():
      if (p.pageSourceType != WebViewWebpageSourceType.url) j['sourceType'] = p.pageSourceType.name;
      if (p.input.isNotEmpty) j['source'] = p.input;
    default:
      // A map or tweet embed: SDK 8.x loads the HTML it generated.
      j['sourceType'] = 'html';
      if (p.src case final String src when src.isNotEmpty) j['source'] = src;
      final raw = Map<String, Object?>.from(p.toJson());
      j['embed'] = {
        'type': p.webviewType.name,
        for (final e in raw.entries)
          if (!_webViewBase.contains(e.key) && e.value != null) e.key: e.value,
      };
  }
  final gestures = [
    if (p.controlVerticalScrollGesture == true) 'verticalDrag',
    if (p.controlHorizontalScrollGesture == true) 'horizontalDrag',
    if (p.controlScaleGesture == true) 'scale',
    if (p.controlTapGesture == true) 'tap',
    if (p.controlLongPressGesture == true) 'longPress',
    if (p.controlForcePressGesture == true) 'forcePress',
  ];
  if (gestures.isNotEmpty) j['gestures'] = gestures;
  if (p.allowsInlineMediaPlayback == true) j['allowsInlineMediaPlayback'] = true;
  if (p.mediaAutoPlaybackPolicy == WebViewMediaAutoPlaybackPolicy.alwaysPlayAllMedia) {
    j['mediaPlaybackRequiresUserAction'] = false;
  }
  if (p.backgroundColor case final ColorRGBA c) j['backgroundColor'] = V1Node.rgba(c);
  return j;
}

Json _external(V1Node m) {
  m.take('properties');
  final id = (m.n as ExternalComponentNode).properties.builderID;
  return {if (id != null && id.isNotEmpty) 'builderId': id};
}

Json _placeholder(V1Node m) {
  m.take('text');
  m.take('leadingAsset');
  final n = m.n as PlaceholderNode;
  return {
    if (n.text case final String t when t.isNotEmpty) 'text': t,
    if (n.leadingAsset case final String a when a.isNotEmpty) 'leadingAsset': a,
  };
}

Json _singlePlaceholder(V1Node m) {
  for (final k in const ['allowedTypes', 'deniedTypes', 'maxAllowedSize', 'ephemeral']) {
    m.take(k);
  }
  final n = m.n as SinglePlaceholderNode;
  final max = n.maxAllowedSize;
  return {
    if (n.allowedTypes.isNotEmpty) 'allowedTypes': n.allowedTypes,
    if (n.deniedTypes.isNotEmpty) 'deniedTypes': n.deniedTypes,
    if (max != null) 'maxAllowedSize': [roundNum(max.width), roundNum(max.height)],
    if (n.ephemeral) 'ephemeral': true,
  };
}
