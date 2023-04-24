// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:json_annotation/json_annotation.dart';

import '../models/models.dart';
import 'web_view_node.dart';

part 'web_view_google_maps_properties.g.dart';

/// A [WebViewProperties] implementation that displays a Google Maps webview.
///
/// There are multiple kinds of [GoogleMapsWebViewProperties], which is why
/// this class is abstract and provides a base for all of them.
///
/// See: [PlacesGoogleMapsWebViewProperties], [ViewGoogleMapsWebViewProperties],
/// [DirectionsGoogleMapsWebViewProperties],
/// [StreetViewGoogleMapsWebViewProperties], and
/// [SearchGoogleMapsWebViewProperties].
abstract class GoogleMapsWebViewProperties extends WebViewProperties {
  /// The API key from the Google Cloud Platform Console.
  ///
  /// This is required for all types and sub-types of
  /// [GoogleMapsWebViewProperties].
  String? apiKey;

  /// Sets initial zoom level of the map.
  ///
  /// Values ranging from 0 (the whole world) to 21 (individual buildings).
  /// The upper limit can vary depending on the map data available at the
  /// selected location.
  int? zoom;

  /// Defines type of map tiles to load.
  /// [roadmap] (default) or [satellite].
  GoogleMapsMapType? mapType;

  /// Defines the language to use for UI elements and for the display of labels
  /// on map tiles. By default, visitors will se a map in their own language.
  ///
  /// This parameter is only supported for some country tiles; if the specific
  /// language requested is not supported for the tile set, then the default
  /// language for that tileset will be used.
  String? language;

  /// Defines the appropriate borders and labels to display, based on
  /// geo-political sensitivities.
  ///
  /// Accepts a region code specified as a two-character (non-numeric) unicode
  /// region subtag mapping to familiar ccTLD ("top-level domain") two-character
  /// values.
  ///
  /// See Google Maps Platform Coverage Details for supported regions.
  /// https://developers.google.com/maps/coverage
  String? region;

  @override
  late WebViewType webviewType = WebViewType.googleMaps;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String label = 'Google Maps';

  /// The map mode that helps disambiguate what kind of map is being displayed.
  /// This is used to determine which sub-type of [GoogleMapsWebViewProperties]
  /// a common [GoogleMapsWebViewProperties] instance should or can be casted
  /// to.
  late GoogleMapsMapMode mapMode;

  /// Google Maps webviews are simply <iframe> web elements that hold a Google
  /// Maps URL in their src attribute.
  ///
  /// This field helps isolate the URL from the rest of the processed [src]
  /// field.
  late String url;

  /// Creates a new [GoogleMapsWebViewProperties] instance given an [apiKey].
  GoogleMapsWebViewProperties({
    required this.apiKey,
    this.zoom,
    this.mapType,
    this.language,
    this.region,
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
  });

  /// Creates a new [GoogleMapsWebViewProperties] instance from a JSON map.
  ///
  /// The [mapMode] is checked manually in order to return the most appropriate
  /// sub-type of [GoogleMapsWebViewProperties] instance.
  ///
  /// TODO: This function is not extendable. If a new type of
  /// [GoogleMapsWebViewProperties] is added, this function will need to be
  /// updated manually and it inherently disallows any third-party plugins to
  /// add their own types of [GoogleMapsWebViewProperties].
  factory GoogleMapsWebViewProperties.fromJson(Map json) {
    switch (GoogleMapsMapMode.values.byName(json['mapMode'])) {
      case GoogleMapsMapMode.places:
        return PlacesGoogleMapsWebViewProperties.fromJson(json);
      case GoogleMapsMapMode.view:
        return ViewGoogleMapsWebViewProperties.fromJson(json);
      case GoogleMapsMapMode.directions:
        return DirectionsGoogleMapsWebViewProperties.fromJson(json);
      case GoogleMapsMapMode.streetView:
        return StreetViewGoogleMapsWebViewProperties.fromJson(json);
      case GoogleMapsMapMode.search:
        return SearchGoogleMapsWebViewProperties.fromJson(json);
    }
  }

  String _appendParams(GoogleMapsMapMode mapMode, String? src, int? zoom,
      GoogleMapsMapType? mapType, String? language, String? region) {
    var params = <String>[];
    if (zoom != null && mapMode != GoogleMapsMapMode.streetView) {
      params.add('zoom=$zoom');
    }
    if (mapType != null && mapMode != GoogleMapsMapMode.streetView) {
      params.add('maptype=${mapType.name}');
    }

    if (language != null) {
      params.add('language=$language');
    }

    if (region != null) {
      params.add('region=$region');
    }

    if (params.isNotEmpty) {
      return '$src&${params.join('&')}';
    }

    return src!;
  }
}

/// Implements the Google Cloud Platform Places API.
///
/// Refer to: https://developers.google.com/maps/documentation/embed/embedding-map#place_mode
@JsonSerializable()
class PlacesGoogleMapsWebViewProperties extends GoogleMapsWebViewProperties {
  /// Defines map marker location.
  ///
  /// URL-escaped place name, address, plus code, or place ID.
  /// The Maps Embed API supports both + and %20 when escaping spaces.
  /// For example, convert "City Hall, New York, NY" to City+Hall,New+York,NY,
  /// or plus codes "849VCWC8+R9" to 849VCWC8%2BR9.
  String query;

  @override
  late GoogleMapsMapMode mapMode = GoogleMapsMapMode.places;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String label = 'Google Maps - Places';

  /// Creates a new [PlacesGoogleMapsWebViewProperties] instance given an
  /// [apiKey] and a [query].
  PlacesGoogleMapsWebViewProperties({
    required super.apiKey,
    required this.query,
    super.zoom,
    super.mapType,
    super.language,
    super.region,

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

  @override
  void regenSource() {
    url =
        'https://www.google.com/maps/embed/v1/place?key=$apiKey&q=${Uri.encodeQueryComponent(query)}'
        '';
    url = _appendParams(mapMode, url, zoom, mapType, language, region);
    src = '''
<iframe
  width="100%"
  height="100%"
  style="border:0; overflow:hidden; pointer-events:none;"
  loading="lazy"
  allowfullscreen
  referrerpolicy="no-referrer-when-downgrade"
  src="$url">
</iframe>
''';
  }

  @override
  Map toJson() => _$PlacesGoogleMapsWebViewPropertiesToJson(this);

  /// Creates a new [PlacesGoogleMapsWebViewProperties] instance from a JSON
  /// map.
  factory PlacesGoogleMapsWebViewProperties.fromJson(Map json) =>
      _$PlacesGoogleMapsWebViewPropertiesFromJson(json);

  @override
  List<Object?> get props => [
        apiKey,
        query,
        zoom,
        mapType,
        language,
        region,
      ];
}

/// Implements the Google Cloud Platform View API.
///
/// Refer to: https://developers.google.com/maps/documentation/embed/embedding-map#view_mode
@JsonSerializable()
class ViewGoogleMapsWebViewProperties extends GoogleMapsWebViewProperties {
  /// Defines center of the map view.
  ///
  /// Accepts comma-separated latitude and longitude value;
  /// for example: 37.4218,-122.0840.
  Vec center;

  @override
  late GoogleMapsMapMode mapMode = GoogleMapsMapMode.view;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String label = 'Google Maps - View';

  /// Creates a new [ViewGoogleMapsWebViewProperties] instance given an [apiKey]
  /// and a [center].
  ViewGoogleMapsWebViewProperties({
    required super.apiKey,
    required this.center,
    super.zoom,
    super.mapType,
    super.language,
    super.region,

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

  @override
  void regenSource() {
    url =
        '''https://www.google.com/maps/embed/v1/view?key=$apiKey&center=${center.x},${center.y}''';
    url = _appendParams(mapMode, url, zoom, mapType, language, region);

    src = '''
<iframe
  width="100%"
  height="100%"
  style="border:0"
  loading="lazy"
  allowfullscreen
  referrerpolicy="no-referrer-when-downgrade"
  src="$url">
</iframe>
''';
  }

  @override
  Map toJson() => _$ViewGoogleMapsWebViewPropertiesToJson(this);

  /// Creates a new [ViewGoogleMapsWebViewProperties] instance from a JSON map.
  factory ViewGoogleMapsWebViewProperties.fromJson(Map json) =>
      _$ViewGoogleMapsWebViewPropertiesFromJson(json);

  @override
  List<Object?> get props => [
        apiKey,
        center,
        zoom,
        mapType,
        language,
        region,
      ];
}

/// Implements the Google Cloud Platform Directions View API.
///
/// Refer to: https://developers.google.com/maps/documentation/embed/embedding-map#directions_mode
@JsonSerializable()
class DirectionsGoogleMapsWebViewProperties
    extends GoogleMapsWebViewProperties {
  /// Defines the starting point from which to display directions.
  ///
  /// URL-escaped place name, address, plus code, latitude/longitude
  /// coordinates, or place ID. The Maps Embed API supports both + and %20 when
  /// escaping spaces. For example, convert "City Hall, New York, NY"
  /// to City+Hall,New+York,NY, or plus codes "849VCWC8+R9" to 849VCWC8%2BR9.
  String origin;

  /// Defines the end point of the directions.
  ///
  /// URL-escaped place name, address, plus code, latitude/longitude
  /// coordinates, or place ID. The Maps Embed API supports both + and %20 when
  /// escaping spaces. For example, convert "City Hall, New York, NY"
  /// to City+Hall,New+York,NY, or plus codes "849VCWC8+R9" to 849VCWC8%2BR9.
  String destination;

  /// Specifies one or more intermediary places to route directions between
  /// the origin and destination.
  ///
  /// Place name, address, or place ID. Multiple waypoints can be specified
  /// by using the pipe character (|) to separate places
  /// (e.g. Berlin,Germany|Paris,France).
  ///
  /// Up to 20 waypoints can be specified.
  List<String> waypoints;

  /// Defines the method of travel. If no mode is specified the Maps Embed API
  /// will show one or more of the most relevant modes for the specified route.
  ///
  /// [driving], [walking] (which prefers pedestrian paths and sidewalks,
  /// where available), [bicycling] (which routes via bike paths and preferred
  /// streets where available), [transit], or [flying].
  GoogleMapsDirectionsMode? mode;

  /// Specifies features to avoid in directions. Note that this doesn't preclude
  /// routes that include the restricted feature(s); it biases the result to
  /// more favorable routes.
  ///
  /// [tolls], [ferries] and/or [highways]. Separate multiple values with the
  /// pipe character (e.g. avoid=tolls|highways).
  Set<GoogleMapsDirectionsAvoid> avoid;

  /// Specifies measurement method, metric or imperial, when displaying
  /// distances in the results. If units are not specified, the origin country
  /// of the query determines the units to use.
  ///
  /// [metric] or [imperial]
  UnitSystem? units;

  /// Defines center of the map view.
  ///
  /// Accepts comma-separated latitude and longitude value;
  /// for example: 37.4218,-122.0840.
  Vec? center;

  @override
  late GoogleMapsMapMode mapMode = GoogleMapsMapMode.directions;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String label = 'Google Maps - Directions';

  /// Creates a new [DirectionsGoogleMapsWebViewProperties] instance given an
  /// [apiKey], an [origin], a [destination], [waypoints], and an [avoid] set.
  DirectionsGoogleMapsWebViewProperties({
    required super.apiKey,
    required this.origin,
    required this.destination,
    required this.waypoints,
    required this.avoid,
    this.mode,
    this.units,
    this.center,
    super.zoom,
    super.mapType,
    super.language,
    super.region,

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
    assert(waypoints.length <= 20);

    regenSource();
  }

  @override
  void regenSource() {
    url =
        '''https://www.google.com/maps/embed/v1/directions?key=$apiKey&origin=${Uri.encodeQueryComponent(origin)}&destination=${Uri.encodeQueryComponent(destination)}''';

    final List<String> modifiedWaypoints = [...waypoints]
      ..removeWhere((point) => point.trim().isEmpty);
    if (modifiedWaypoints.isNotEmpty) {
      url =
          '$url&waypoints=${modifiedWaypoints.map((waypoint) => waypoint.trim().replaceAll(' ', ',')).map(Uri.encodeQueryComponent).join('|')}';
    }

    if (mode != null) {
      url = '$url&mode=${mode!.name}';
    }

    if (avoid.isNotEmpty) {
      url = '$url&avoid=${avoid.map((avoid) => avoid.name).join('|')}';
    }

    if (units != null) {
      url = '$url&units=${units!.name}';
    }

    url = _appendParams(mapMode, url, zoom, mapType, language, region);

    src = '''
<iframe
  width="100%"
  height="100%"
  style="border:0"
  loading="lazy"
  allowfullscreen
  referrerpolicy="no-referrer-when-downgrade"
  src="$url">
</iframe>
''';
  }

  @override
  Map toJson() => _$DirectionsGoogleMapsWebViewPropertiesToJson(this);

  /// Creates a new [DirectionsGoogleMapsWebViewProperties] instance from a JSON
  /// map.
  factory DirectionsGoogleMapsWebViewProperties.fromJson(Map json) =>
      _$DirectionsGoogleMapsWebViewPropertiesFromJson(json);

  @override
  List<Object?> get props => [
        apiKey,
        origin,
        destination,
        zoom,
        mapType,
        language,
        region,
      ];
}

/// Implements the Google Cloud Platform Street View View API.
///
/// Refer to: https://developers.google.com/maps/documentation/embed/embedding-map#streetview_mode
@JsonSerializable()
class StreetViewGoogleMapsWebViewProperties
    extends GoogleMapsWebViewProperties {
  /// [location] accepts a latitude and a longitude as comma-separated values
  /// (46.414382,10.013988). The API will display the panorama photographed
  /// closest to this location.
  ///
  /// Because Street View imagery is periodically refreshed, and photographs
  /// may be taken from slightly different positions each time, it's possible
  /// that the location may snap to a different panorama when imagery is
  /// updated.
  Vec? location;

  /// [pano] is a specific panorama ID. Location may also be specified with
  /// panorama ID. The location will be only be used if the API cannot find the
  /// panorama ID.
  String? pano;

  /// Indicates the compass heading of the camera in degrees clockwise from
  /// North.
  ///
  /// Value in degrees from -180° to 360°.
  int? heading;

  /// Specifies the angle, up or down, of the camera. Positive values will
  /// angle the camera up, while negative values will angle the camera down.
  /// The default pitch of 0° is set based on on the position of the camera when
  /// the image was captured.
  ///
  /// Because of this, a pitch of 0° is often, but not always, horizontal.
  ///
  /// For example, an image taken on a hill will likely exhibit a default pitch
  /// that is not horizontal.
  int? pitch;

  /// Determines the horizontal field of view of the image. It defaults to 90°.
  /// When dealing with a fixed-size viewport the field of view is can be
  /// considered the zoom level, with smaller numbers indicating a higher
  /// level of zoom.
  ///
  /// Value in degrees, with a range of 10° - 100°.
  int? fov;

  /// Defines center of the map view.
  ///
  /// Accepts comma-separated latitude and longitude value.
  /// Ex. [37.4218,-122.0840].
  Vec? center;

  @override
  late GoogleMapsMapMode mapMode = GoogleMapsMapMode.streetView;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String label = 'Google Maps - Street View';

  /// Creates a new [StreetViewGoogleMapsWebViewProperties] instance given an
  /// [apiKey] and optionally a [location], [pano], [heading], [pitch], [fov],
  /// or [center].
  StreetViewGoogleMapsWebViewProperties({
    required super.apiKey,
    this.location,
    this.pano,
    this.heading,
    this.pitch,
    this.fov,
    super.zoom,
    super.mapType,
    super.language,
    super.region,
    this.center,

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
    assert(location != null || pano != null);
    assert(heading == null || (heading! >= -180 && heading! <= 360));
    assert(pitch == null || (pitch! >= -90 && pitch! <= 90));
    assert(fov == null || (fov! >= 10 && fov! <= 100));

    regenSource();
  }

  @override
  void regenSource() {
    url = '''https://www.google.com/maps/embed/v1/streetview?key=$apiKey''';

    if (location != null) {
      url =
          '$url&location=${Uri.encodeQueryComponent('${location!.x},${location!.y}')}';
    }

    if (pano != null) {
      url = '$url&pano=${Uri.encodeQueryComponent(pano!)}';
    }

    if (heading != null) {
      url = '$url&heading=$heading';
    }

    if (pitch != null) {
      url = '$url&pitch=$pitch';
    }

    if (fov != null) {
      url = '$url&fov=$fov';
    }

    url = _appendParams(mapMode, url, zoom, mapType, language, region);

    src = '''
<iframe
  width="100%"
  height="100%"
  style="border:0"
  loading="lazy"
  allowfullscreen
  referrerpolicy="no-referrer-when-downgrade"
  src="$url">
</iframe>
''';
  }

  @override
  Map toJson() => _$StreetViewGoogleMapsWebViewPropertiesToJson(this);

  /// Creates a new [StreetViewGoogleMapsWebViewProperties] instance from a JSON
  /// map.
  factory StreetViewGoogleMapsWebViewProperties.fromJson(Map json) =>
      _$StreetViewGoogleMapsWebViewPropertiesFromJson(json);

  @override
  List<Object?> get props => [
        apiKey,
        location,
        heading,
        pitch,
        fov,
        zoom,
        mapType,
        language,
        region,
      ];
}

/// Implements the Google Cloud Platform Search Maps API.
///
/// Refer to: https://developers.google.com/maps/documentation/embed/embedding-map#search_mode
@JsonSerializable()
class SearchGoogleMapsWebViewProperties extends GoogleMapsWebViewProperties {
  /// Defines the search term.
  ///
  /// It can include a geographic restriction, such as in+Seattle or near+98033.
  String query;

  @override
  late GoogleMapsMapMode mapMode = GoogleMapsMapMode.search;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String label = 'Google Maps - Search';

  /// Creates a new [SearchGoogleMapsWebViewProperties] instance given an
  /// [apiKey] and a [query].
  SearchGoogleMapsWebViewProperties({
    required super.apiKey,
    required this.query,
    super.zoom,
    super.mapType,
    super.language,
    super.region,

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

  @override
  void regenSource() {
    url =
        '''https://www.google.com/maps/embed/v1/search?key=$apiKey&q=${Uri.encodeQueryComponent(query)}''';

    url = _appendParams(mapMode, url, zoom, mapType, language, region);

    src = '''
<iframe
  width="100%"
  height="100%"
  style="border:0; overflow:hidden;"
  loading="lazy"
  allowfullscreen
  referrerpolicy="no-referrer-when-downgrade"
  src="$url">
</iframe>
''';
  }

  @override
  Map toJson() => _$SearchGoogleMapsWebViewPropertiesToJson(this);

  /// Creates a new [SearchGoogleMapsWebViewProperties] instance from a JSON
  /// map.
  factory SearchGoogleMapsWebViewProperties.fromJson(Map json) =>
      _$SearchGoogleMapsWebViewPropertiesFromJson(json);

  @override
  List<Object?> get props => [
        apiKey,
        query,
        zoom,
        mapType,
        language,
        region,
      ];
}
