// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_view_google_maps_properties.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$PlacesGoogleMapsWebViewPropertiesOmitDefaults(
  PlacesGoogleMapsWebViewProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(
    instance.mediaAutoPlaybackPolicy,
    WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
  ))
    json.remove('mediaAutoPlaybackPolicy');
  return json;
}

Map<String, dynamic> _$ViewGoogleMapsWebViewPropertiesOmitDefaults(
  ViewGoogleMapsWebViewProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(
    instance.mediaAutoPlaybackPolicy,
    WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
  ))
    json.remove('mediaAutoPlaybackPolicy');
  return json;
}

Map<String, dynamic> _$DirectionsGoogleMapsWebViewPropertiesOmitDefaults(
  DirectionsGoogleMapsWebViewProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(
    instance.mediaAutoPlaybackPolicy,
    WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
  ))
    json.remove('mediaAutoPlaybackPolicy');
  return json;
}

Map<String, dynamic> _$StreetViewGoogleMapsWebViewPropertiesOmitDefaults(
  StreetViewGoogleMapsWebViewProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(
    instance.mediaAutoPlaybackPolicy,
    WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
  ))
    json.remove('mediaAutoPlaybackPolicy');
  return json;
}

Map<String, dynamic> _$SearchGoogleMapsWebViewPropertiesOmitDefaults(
  SearchGoogleMapsWebViewProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(
    instance.mediaAutoPlaybackPolicy,
    WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
  ))
    json.remove('mediaAutoPlaybackPolicy');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlacesGoogleMapsWebViewProperties _$PlacesGoogleMapsWebViewPropertiesFromJson(
  Map json,
) =>
    PlacesGoogleMapsWebViewProperties(
        apiKey: json['apiKey'] as String?,
        query: json['query'] as String,
        zoom: (json['zoom'] as num?)?.toInt(),
        mapType: $enumDecodeNullable(
          _$GoogleMapsMapTypeEnumMap,
          json['mapType'],
        ),
        language: json['language'] as String?,
        region: json['region'] as String?,
        controlVerticalScrollGesture:
            json['controlVerticalScrollGesture'] as bool?,
        controlHorizontalScrollGesture:
            json['controlHorizontalScrollGesture'] as bool?,
        controlScaleGesture: json['controlScaleGesture'] as bool?,
        controlTapGesture: json['controlTapGesture'] as bool?,
        controlLongPressGesture: json['controlLongPressGesture'] as bool?,
        controlForcePressGesture: json['controlForcePressGesture'] as bool?,
        allowsInlineMediaPlayback: json['allowsInlineMediaPlayback'] as bool?,
        mediaAutoPlaybackPolicy:
            $enumDecodeNullable(
              _$WebViewMediaAutoPlaybackPolicyEnumMap,
              json['mediaAutoPlaybackPolicy'],
            ) ??
            WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
        backgroundColor: json['backgroundColor'] == null
            ? null
            : ColorRGBA.fromJson(json['backgroundColor']),
      )
      ..src = _$JsonConverterFromJson<String, String>(
        json['src'],
        const Base64JsonConverter().fromJson,
      )
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..url = json['url'] as String
      ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$PlacesGoogleMapsWebViewPropertiesToJson(
  PlacesGoogleMapsWebViewProperties instance,
) => <String, dynamic>{
  'src': const Base64JsonConverter().toJson(instance.src),
  'controlVerticalScrollGesture': ?instance.controlVerticalScrollGesture,
  'controlHorizontalScrollGesture': ?instance.controlHorizontalScrollGesture,
  'controlScaleGesture': ?instance.controlScaleGesture,
  'controlTapGesture': ?instance.controlTapGesture,
  'controlLongPressGesture': ?instance.controlLongPressGesture,
  'controlForcePressGesture': ?instance.controlForcePressGesture,
  'allowsInlineMediaPlayback': ?instance.allowsInlineMediaPlayback,
  'mediaAutoPlaybackPolicy':
      _$WebViewMediaAutoPlaybackPolicyEnumMap[instance
          .mediaAutoPlaybackPolicy]!,
  'backgroundColor': ?instance.backgroundColor?.toJson(),
  'apiKey': ?instance.apiKey,
  'zoom': ?instance.zoom,
  'mapType': ?_$GoogleMapsMapTypeEnumMap[instance.mapType],
  'language': ?instance.language,
  'region': ?instance.region,
  'webviewType': _$WebViewTypeEnumMap[instance.webviewType]!,
  'url': instance.url,
  'query': instance.query,
  'mapMode': _$GoogleMapsMapModeEnumMap[instance.mapMode]!,
};

const _$GoogleMapsMapTypeEnumMap = {
  GoogleMapsMapType.roadmap: 'roadmap',
  GoogleMapsMapType.satellite: 'satellite',
};

const _$WebViewMediaAutoPlaybackPolicyEnumMap = {
  WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia:
      'requireUserActionForAllMedia',
  WebViewMediaAutoPlaybackPolicy.alwaysPlayAllMedia: 'alwaysPlayAllMedia',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$WebViewTypeEnumMap = {
  WebViewType.webpage: 'webpage',
  WebViewType.googleMaps: 'googleMaps',
  WebViewType.twitter: 'twitter',
};

const _$GoogleMapsMapModeEnumMap = {
  GoogleMapsMapMode.places: 'places',
  GoogleMapsMapMode.view: 'view',
  GoogleMapsMapMode.directions: 'directions',
  GoogleMapsMapMode.streetView: 'streetView',
  GoogleMapsMapMode.search: 'search',
};

ViewGoogleMapsWebViewProperties _$ViewGoogleMapsWebViewPropertiesFromJson(
  Map json,
) =>
    ViewGoogleMapsWebViewProperties(
        apiKey: json['apiKey'] as String?,
        center: Vec.fromJson(json['center']),
        zoom: (json['zoom'] as num?)?.toInt(),
        mapType: $enumDecodeNullable(
          _$GoogleMapsMapTypeEnumMap,
          json['mapType'],
        ),
        language: json['language'] as String?,
        region: json['region'] as String?,
        controlVerticalScrollGesture:
            json['controlVerticalScrollGesture'] as bool?,
        controlHorizontalScrollGesture:
            json['controlHorizontalScrollGesture'] as bool?,
        controlScaleGesture: json['controlScaleGesture'] as bool?,
        controlTapGesture: json['controlTapGesture'] as bool?,
        controlLongPressGesture: json['controlLongPressGesture'] as bool?,
        controlForcePressGesture: json['controlForcePressGesture'] as bool?,
        allowsInlineMediaPlayback: json['allowsInlineMediaPlayback'] as bool?,
        mediaAutoPlaybackPolicy:
            $enumDecodeNullable(
              _$WebViewMediaAutoPlaybackPolicyEnumMap,
              json['mediaAutoPlaybackPolicy'],
            ) ??
            WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
        backgroundColor: json['backgroundColor'] == null
            ? null
            : ColorRGBA.fromJson(json['backgroundColor']),
      )
      ..src = _$JsonConverterFromJson<String, String>(
        json['src'],
        const Base64JsonConverter().fromJson,
      )
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..url = json['url'] as String
      ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$ViewGoogleMapsWebViewPropertiesToJson(
  ViewGoogleMapsWebViewProperties instance,
) => <String, dynamic>{
  'src': const Base64JsonConverter().toJson(instance.src),
  'controlVerticalScrollGesture': ?instance.controlVerticalScrollGesture,
  'controlHorizontalScrollGesture': ?instance.controlHorizontalScrollGesture,
  'controlScaleGesture': ?instance.controlScaleGesture,
  'controlTapGesture': ?instance.controlTapGesture,
  'controlLongPressGesture': ?instance.controlLongPressGesture,
  'controlForcePressGesture': ?instance.controlForcePressGesture,
  'allowsInlineMediaPlayback': ?instance.allowsInlineMediaPlayback,
  'mediaAutoPlaybackPolicy':
      _$WebViewMediaAutoPlaybackPolicyEnumMap[instance
          .mediaAutoPlaybackPolicy]!,
  'backgroundColor': ?instance.backgroundColor?.toJson(),
  'apiKey': ?instance.apiKey,
  'zoom': ?instance.zoom,
  'mapType': ?_$GoogleMapsMapTypeEnumMap[instance.mapType],
  'language': ?instance.language,
  'region': ?instance.region,
  'webviewType': _$WebViewTypeEnumMap[instance.webviewType]!,
  'url': instance.url,
  'center': instance.center.toJson(),
  'mapMode': _$GoogleMapsMapModeEnumMap[instance.mapMode]!,
};

DirectionsGoogleMapsWebViewProperties
_$DirectionsGoogleMapsWebViewPropertiesFromJson(Map json) =>
    DirectionsGoogleMapsWebViewProperties(
        apiKey: json['apiKey'] as String?,
        origin: json['origin'] as String,
        destination: json['destination'] as String,
        waypoints: (json['waypoints'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        avoid: (json['avoid'] as List<dynamic>)
            .map((e) => $enumDecode(_$GoogleMapsDirectionsAvoidEnumMap, e))
            .toSet(),
        mode: $enumDecodeNullable(
          _$GoogleMapsDirectionsModeEnumMap,
          json['mode'],
        ),
        units: $enumDecodeNullable(_$UnitSystemEnumMap, json['units']),
        center: json['center'] == null ? null : Vec.fromJson(json['center']),
        zoom: (json['zoom'] as num?)?.toInt(),
        mapType: $enumDecodeNullable(
          _$GoogleMapsMapTypeEnumMap,
          json['mapType'],
        ),
        language: json['language'] as String?,
        region: json['region'] as String?,
        controlVerticalScrollGesture:
            json['controlVerticalScrollGesture'] as bool?,
        controlHorizontalScrollGesture:
            json['controlHorizontalScrollGesture'] as bool?,
        controlScaleGesture: json['controlScaleGesture'] as bool?,
        controlTapGesture: json['controlTapGesture'] as bool?,
        controlLongPressGesture: json['controlLongPressGesture'] as bool?,
        controlForcePressGesture: json['controlForcePressGesture'] as bool?,
        allowsInlineMediaPlayback: json['allowsInlineMediaPlayback'] as bool?,
        mediaAutoPlaybackPolicy:
            $enumDecodeNullable(
              _$WebViewMediaAutoPlaybackPolicyEnumMap,
              json['mediaAutoPlaybackPolicy'],
            ) ??
            WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
        backgroundColor: json['backgroundColor'] == null
            ? null
            : ColorRGBA.fromJson(json['backgroundColor']),
      )
      ..src = _$JsonConverterFromJson<String, String>(
        json['src'],
        const Base64JsonConverter().fromJson,
      )
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..url = json['url'] as String
      ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$DirectionsGoogleMapsWebViewPropertiesToJson(
  DirectionsGoogleMapsWebViewProperties instance,
) => <String, dynamic>{
  'src': const Base64JsonConverter().toJson(instance.src),
  'controlVerticalScrollGesture': ?instance.controlVerticalScrollGesture,
  'controlHorizontalScrollGesture': ?instance.controlHorizontalScrollGesture,
  'controlScaleGesture': ?instance.controlScaleGesture,
  'controlTapGesture': ?instance.controlTapGesture,
  'controlLongPressGesture': ?instance.controlLongPressGesture,
  'controlForcePressGesture': ?instance.controlForcePressGesture,
  'allowsInlineMediaPlayback': ?instance.allowsInlineMediaPlayback,
  'mediaAutoPlaybackPolicy':
      _$WebViewMediaAutoPlaybackPolicyEnumMap[instance
          .mediaAutoPlaybackPolicy]!,
  'backgroundColor': ?instance.backgroundColor?.toJson(),
  'apiKey': ?instance.apiKey,
  'zoom': ?instance.zoom,
  'mapType': ?_$GoogleMapsMapTypeEnumMap[instance.mapType],
  'language': ?instance.language,
  'region': ?instance.region,
  'webviewType': _$WebViewTypeEnumMap[instance.webviewType]!,
  'url': instance.url,
  'origin': instance.origin,
  'destination': instance.destination,
  'waypoints': instance.waypoints,
  'mode': ?_$GoogleMapsDirectionsModeEnumMap[instance.mode],
  'avoid': instance.avoid
      .map((e) => _$GoogleMapsDirectionsAvoidEnumMap[e]!)
      .toList(),
  'units': ?_$UnitSystemEnumMap[instance.units],
  'center': ?instance.center?.toJson(),
  'mapMode': _$GoogleMapsMapModeEnumMap[instance.mapMode]!,
};

const _$GoogleMapsDirectionsAvoidEnumMap = {
  GoogleMapsDirectionsAvoid.tolls: 'tolls',
  GoogleMapsDirectionsAvoid.highways: 'highways',
  GoogleMapsDirectionsAvoid.ferries: 'ferries',
};

const _$GoogleMapsDirectionsModeEnumMap = {
  GoogleMapsDirectionsMode.driving: 'driving',
  GoogleMapsDirectionsMode.walking: 'walking',
  GoogleMapsDirectionsMode.bicycling: 'bicycling',
  GoogleMapsDirectionsMode.transit: 'transit',
  GoogleMapsDirectionsMode.flying: 'flying',
};

const _$UnitSystemEnumMap = {
  UnitSystem.metric: 'metric',
  UnitSystem.imperial: 'imperial',
};

StreetViewGoogleMapsWebViewProperties
_$StreetViewGoogleMapsWebViewPropertiesFromJson(Map json) =>
    StreetViewGoogleMapsWebViewProperties(
        apiKey: json['apiKey'] as String?,
        location: json['location'] == null
            ? null
            : Vec.fromJson(json['location']),
        pano: json['pano'] as String?,
        heading: (json['heading'] as num?)?.toInt(),
        pitch: (json['pitch'] as num?)?.toInt(),
        fov: (json['fov'] as num?)?.toInt(),
        zoom: (json['zoom'] as num?)?.toInt(),
        mapType: $enumDecodeNullable(
          _$GoogleMapsMapTypeEnumMap,
          json['mapType'],
        ),
        language: json['language'] as String?,
        region: json['region'] as String?,
        center: json['center'] == null ? null : Vec.fromJson(json['center']),
        controlVerticalScrollGesture:
            json['controlVerticalScrollGesture'] as bool?,
        controlHorizontalScrollGesture:
            json['controlHorizontalScrollGesture'] as bool?,
        controlScaleGesture: json['controlScaleGesture'] as bool?,
        controlTapGesture: json['controlTapGesture'] as bool?,
        controlLongPressGesture: json['controlLongPressGesture'] as bool?,
        controlForcePressGesture: json['controlForcePressGesture'] as bool?,
        allowsInlineMediaPlayback: json['allowsInlineMediaPlayback'] as bool?,
        mediaAutoPlaybackPolicy:
            $enumDecodeNullable(
              _$WebViewMediaAutoPlaybackPolicyEnumMap,
              json['mediaAutoPlaybackPolicy'],
            ) ??
            WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
        backgroundColor: json['backgroundColor'] == null
            ? null
            : ColorRGBA.fromJson(json['backgroundColor']),
      )
      ..src = _$JsonConverterFromJson<String, String>(
        json['src'],
        const Base64JsonConverter().fromJson,
      )
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..url = json['url'] as String
      ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$StreetViewGoogleMapsWebViewPropertiesToJson(
  StreetViewGoogleMapsWebViewProperties instance,
) => <String, dynamic>{
  'src': const Base64JsonConverter().toJson(instance.src),
  'controlVerticalScrollGesture': ?instance.controlVerticalScrollGesture,
  'controlHorizontalScrollGesture': ?instance.controlHorizontalScrollGesture,
  'controlScaleGesture': ?instance.controlScaleGesture,
  'controlTapGesture': ?instance.controlTapGesture,
  'controlLongPressGesture': ?instance.controlLongPressGesture,
  'controlForcePressGesture': ?instance.controlForcePressGesture,
  'allowsInlineMediaPlayback': ?instance.allowsInlineMediaPlayback,
  'mediaAutoPlaybackPolicy':
      _$WebViewMediaAutoPlaybackPolicyEnumMap[instance
          .mediaAutoPlaybackPolicy]!,
  'backgroundColor': ?instance.backgroundColor?.toJson(),
  'apiKey': ?instance.apiKey,
  'zoom': ?instance.zoom,
  'mapType': ?_$GoogleMapsMapTypeEnumMap[instance.mapType],
  'language': ?instance.language,
  'region': ?instance.region,
  'webviewType': _$WebViewTypeEnumMap[instance.webviewType]!,
  'url': instance.url,
  'location': ?instance.location?.toJson(),
  'pano': ?instance.pano,
  'heading': ?instance.heading,
  'pitch': ?instance.pitch,
  'fov': ?instance.fov,
  'center': ?instance.center?.toJson(),
  'mapMode': _$GoogleMapsMapModeEnumMap[instance.mapMode]!,
};

SearchGoogleMapsWebViewProperties _$SearchGoogleMapsWebViewPropertiesFromJson(
  Map json,
) =>
    SearchGoogleMapsWebViewProperties(
        apiKey: json['apiKey'] as String?,
        query: json['query'] as String,
        zoom: (json['zoom'] as num?)?.toInt(),
        mapType: $enumDecodeNullable(
          _$GoogleMapsMapTypeEnumMap,
          json['mapType'],
        ),
        language: json['language'] as String?,
        region: json['region'] as String?,
        controlVerticalScrollGesture:
            json['controlVerticalScrollGesture'] as bool?,
        controlHorizontalScrollGesture:
            json['controlHorizontalScrollGesture'] as bool?,
        controlScaleGesture: json['controlScaleGesture'] as bool?,
        controlTapGesture: json['controlTapGesture'] as bool?,
        controlLongPressGesture: json['controlLongPressGesture'] as bool?,
        controlForcePressGesture: json['controlForcePressGesture'] as bool?,
        allowsInlineMediaPlayback: json['allowsInlineMediaPlayback'] as bool?,
        mediaAutoPlaybackPolicy:
            $enumDecodeNullable(
              _$WebViewMediaAutoPlaybackPolicyEnumMap,
              json['mediaAutoPlaybackPolicy'],
            ) ??
            WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
        backgroundColor: json['backgroundColor'] == null
            ? null
            : ColorRGBA.fromJson(json['backgroundColor']),
      )
      ..src = _$JsonConverterFromJson<String, String>(
        json['src'],
        const Base64JsonConverter().fromJson,
      )
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..url = json['url'] as String
      ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$SearchGoogleMapsWebViewPropertiesToJson(
  SearchGoogleMapsWebViewProperties instance,
) => <String, dynamic>{
  'src': const Base64JsonConverter().toJson(instance.src),
  'controlVerticalScrollGesture': ?instance.controlVerticalScrollGesture,
  'controlHorizontalScrollGesture': ?instance.controlHorizontalScrollGesture,
  'controlScaleGesture': ?instance.controlScaleGesture,
  'controlTapGesture': ?instance.controlTapGesture,
  'controlLongPressGesture': ?instance.controlLongPressGesture,
  'controlForcePressGesture': ?instance.controlForcePressGesture,
  'allowsInlineMediaPlayback': ?instance.allowsInlineMediaPlayback,
  'mediaAutoPlaybackPolicy':
      _$WebViewMediaAutoPlaybackPolicyEnumMap[instance
          .mediaAutoPlaybackPolicy]!,
  'backgroundColor': ?instance.backgroundColor?.toJson(),
  'apiKey': ?instance.apiKey,
  'zoom': ?instance.zoom,
  'mapType': ?_$GoogleMapsMapTypeEnumMap[instance.mapType],
  'language': ?instance.language,
  'region': ?instance.region,
  'webviewType': _$WebViewTypeEnumMap[instance.webviewType]!,
  'url': instance.url,
  'query': instance.query,
  'mapMode': _$GoogleMapsMapModeEnumMap[instance.mapMode]!,
};
