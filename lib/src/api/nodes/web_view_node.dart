// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'web_view_node.g.dart';

/// A WebView is a rectangle that displays or embeds a web page or web element.
///
/// It is only available on Android and iOS.
///
/// This node utilizes the [webview_flutter] package.
@JsonSerializable()
class WebViewNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'webView';

  /// Accesses the properties of the webview. There are multiple versions of
  /// webview properties, [WebPageWebViewProperties],
  /// [TwitterWebViewProperties], and [GoogleMapsWebViewProperties].
  WebViewProperties properties;

  /// Returns whether this webview holds actual content in its
  /// [WebViewProperties.src].
  bool get hasData =>
      properties.src != null && properties.src!.trim().isNotEmpty;

  @override
  bool get supportsPadding => false;

  /// Creates a new [WebViewNode] instance with the given parameters.
  WebViewNode({
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

  /// Creates a new [WebViewNode] instance from a JSON map.
  factory WebViewNode.fromJson(Map json) => _$WebViewNodeFromJson(json);

  @override
  Map toJson() => _$WebViewNodeToJson(this);
}

/// A custom serializer and deserializer for the [WebViewProperties.src] field
/// to encode and decode the src to and from a base64 string.
///
/// The [src] can be a URL, an actual HTML string, etc. Hence, it is serialized
/// to a base64 string.
class Base64JsonConverter implements JsonConverter<String?, String> {
  /// Creates a default [Base64JsonConverter] instance.
  const Base64JsonConverter();

  @override
  String? fromJson(String encodedString) =>
      utf8.decode(base64.decode(encodedString));

  @override
  String toJson(String? decodedString) =>
      base64.encode(utf8.encode(decodedString ?? ''));
}

/// An abstract class that holds the common properties that any [WebViewNode]
/// can have.
///
/// There are three classes that implement this class:
/// [WebPageWebViewProperties], [TwitterWebViewProperties], and
/// [GoogleMapsWebViewProperties].
abstract class WebViewProperties with SerializableMixin, EquatableMixin {
  /// The [src] holds the actual content of the webview. It can be either a URL,
  /// an actual HTML string, an asset path, etc.
  @Base64JsonConverter()
  String? src;

  /// The type of webview this instance of [WebViewProperties] is.
  late WebViewType webviewType;

  /// A human-readable label that represents this type of [WebViewProperties].
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String label = 'WebView';

  /// Whether this webview should consume any vertical scroll gestures.
  ///
  /// This is useful for webviews that hold scrollable content as the webview
  /// might be inside a scrollable container itself, creating potential gesture
  /// conflicts.
  ///
  /// Setting this to true will ensure the webview always allow vertical scroll
  /// gestures into it and disallow parent containers from scrolling when the
  /// event is triggered inside the bounds of this webview.
  bool? controlVerticalScrollGesture;

  /// Whether this webview should consume any horizontal scroll gestures.
  ///
  /// This is useful for webviews that hold scrollable content as the webview
  /// might be inside a scrollable container itself, creating potential gesture
  /// conflicts.
  ///
  /// Setting this to true will ensure the webview always allow horizontal
  /// scroll gestures into it and disallow parent containers from scrolling when
  /// the event is triggered inside the bounds of this webview.
  bool? controlHorizontalScrollGesture;

  /// Whether this webview should consume any zooming/scalable or scaling
  /// gestures.
  ///
  /// This is useful for webviews that hold zoomable/scalable content as the
  /// webview might be inside an zoomable/scalable container itself, creating
  /// potential gesture conflicts.
  ///
  /// Setting this to true will ensure the webview always allow zooming/
  /// scaling gestures into it and disallow parent containers from zooming/
  /// scaling when the event is triggered inside the bounds of this webview.
  ///
  /// This is most evident inside [GoogleMapsWebViewProperties] where the
  /// webview is zoomable/scalable.
  bool? controlScaleGesture;

  /// Whether this webview should consume any tap gestures.
  ///
  /// This is useful for webviews that hold clickable content as the webview
  /// might be inside a clickable container itself, creating potential gesture
  /// conflicts.
  ///
  /// Setting this to true will ensure the webview always allow tap gestures
  /// into it and disallow parent containers from triggering tap events when the
  /// event is triggered inside the bounds of this webview.
  bool? controlTapGesture;

  /// Whether this webview should consume any long press gestures.
  ///
  /// This is useful for webviews that hold clickable content as the webview
  /// might be inside a clickable container itself, creating potential gesture
  /// conflicts.
  ///
  /// Setting this to true will ensure the webview always allow long press
  /// gestures into it and disallow parent containers from triggering long press
  /// events when the event is triggered inside the bounds of this webview.
  bool? controlLongPressGesture;

  /// Whether this webview should consume any force press gestures.
  ///
  /// This is useful for webviews that hold clickable content as the webview
  /// might be inside a clickable container itself, creating potential gesture
  /// conflicts.
  ///
  /// Setting this to true will ensure the webview always allow force press
  /// gestures into it and disallow parent containers from triggering force
  /// press events when the event is triggered inside the bounds of this
  /// webview.
  bool? controlForcePressGesture;

  /// Controls whether inline playback of HTML5 videos is allowed on iOS.
  ///
  /// This field is ignored on Android because Android allows it by default.
  ///
  /// By default `allowsInlineMediaPlayback` is false.
  bool? allowsInlineMediaPlayback;

  /// Media auto playback policy is used to control whether HTML5 media
  /// (audio/video) should automatically start playing when the webview is
  /// loaded.
  WebViewMediaAutoPlaybackPolicy mediaAutoPlaybackPolicy;

  /// The background color of the webview is the color that will be shown
  /// behind the webview content. This is the web-engine rendered background
  /// and not the physical paint underneath the webview as a rectangle.
  ///
  /// This will inform the built-in browser engine what initial color to use
  /// for the background of the webpages. You will most often observe this
  /// color when a webview initially attempts to load a webpage and the
  /// background color is shown until the webpage is loaded.
  ColorRGBA? backgroundColor;

  /// Creates a new [WebViewProperties] instance.
  WebViewProperties({
    this.src,
    this.controlVerticalScrollGesture,
    this.controlHorizontalScrollGesture,
    this.controlScaleGesture,
    this.controlTapGesture,
    this.controlLongPressGesture,
    this.controlForcePressGesture,
    this.allowsInlineMediaPlayback,
    this.mediaAutoPlaybackPolicy =
        WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
    this.backgroundColor,
  });

  /// Regenerates the [src] field in whatever way is desired. Some webviews
  /// need extremely specific [src] to work properly.
  ///
  /// See: [TwitterWebViewProperties] and [GoogleMapsWebViewProperties].
  void regenSource();

  /// Creates a new [WebViewProperties] instance from a JSON map.
  ///
  /// The [webviewType] is checked manually in order to return the most
  /// appropriate type of [WebViewProperties] instance.
  ///
  /// TODO: This function is not extendable. If a new type of
  /// [WebViewProperties] is added, this function will need to be updated
  /// manually and it inherently disallows any third-party plugins to add
  /// their own [WebViewProperties] types.
  factory WebViewProperties.fromJson(Map json) {
    switch (WebViewType.values.byName(json['webviewType'])) {
      case WebViewType.webpage:
        return WebPageWebViewProperties.fromJson(json);
      case WebViewType.googleMaps:
        return GoogleMapsWebViewProperties.fromJson(json);
      case WebViewType.twitter:
        return TwitterWebViewProperties.fromJson(json);
    }
  }

  /// This is not a normal copy function. This specifically copies the base
  /// fields inside this abstract [WebViewProperties] instance from [other]
  /// into this instance of [WebViewProperties].
  ///
  /// It only copies the "base" properties, IE: the properties that are common
  /// to all [WebViewProperties] types only, the ones in this specific abstract
  /// class.
  void copyBase(WebViewProperties other) {
    controlVerticalScrollGesture = other.controlVerticalScrollGesture;
    controlHorizontalScrollGesture = other.controlHorizontalScrollGesture;
    controlScaleGesture = other.controlScaleGesture;
    controlTapGesture = other.controlTapGesture;
    controlLongPressGesture = other.controlLongPressGesture;
    controlForcePressGesture = other.controlForcePressGesture;
    allowsInlineMediaPlayback = other.allowsInlineMediaPlayback;
    mediaAutoPlaybackPolicy = other.mediaAutoPlaybackPolicy;
    backgroundColor = other.backgroundColor;
  }

  @override
  List<Object?> get props => [src];
}

/// A [WebViewProperties] implementation that is used to display a webpage
/// given an appropriate input.
@JsonSerializable()
class WebPageWebViewProperties extends WebViewProperties {
  /// The source of the webpage to be displayed. This can be a URL, an HTML
  /// string, or a file path from the assets folder.
  ///
  /// This field is required as it disambiguates user intent. Even if it's
  /// unused for the webview itself, it provides rich information to us as
  /// developers and allows us to build better UI/UX experiences.
  WebViewWebpageSourceType pageSourceType;

  /// Can be a URL, an HTML string, or an asset path.
  ///
  /// Asset path must lead to a [.html] file suffix. It produces meaningless src
  /// because the generated code will be platform dependant.
  String input;

  @override
  late WebViewType webviewType = WebViewType.webpage;

  @override
  late String label = 'Webpage';

  /// Creates a new [WebPageWebViewProperties] instance given a [pageSourceType]
  /// and an [input].
  WebPageWebViewProperties({
    required this.pageSourceType,
    required this.input,
    // Inherited.
    super.controlVerticalScrollGesture,
    super.controlHorizontalScrollGesture,
    super.controlScaleGesture,
    super.controlTapGesture,
    super.controlLongPressGesture,
    super.controlForcePressGesture,
    super.allowsInlineMediaPlayback,
    super.mediaAutoPlaybackPolicy,
    super.backgroundColor,
  }) {
    regenSource();
  }

  /// [src] for webpages equivalent to [input] as it is injected directly into
  /// the webview as-is.
  @override
  void regenSource() {
    src = input;
  }

  @override
  Map toJson() => _$WebPageWebViewPropertiesToJson(this);

  /// Creates a new [WebPageWebViewProperties] instance from a JSON map.
  factory WebPageWebViewProperties.fromJson(Map json) =>
      _$WebPageWebViewPropertiesFromJson(json);

  @override
  List<Object?> get props => [pageSourceType, src];
}
