// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_view_google_maps_properties.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlacesGoogleMapsWebViewProperties _$PlacesGoogleMapsWebViewPropertiesFromJson(
        Map json) =>
    PlacesGoogleMapsWebViewProperties(
      apiKey: json['apiKey'] as String?,
      query: json['query'] as String,
      zoom: json['zoom'] as int?,
      mapType: $enumDecodeNullable(_$GoogleMapsMapTypeEnumMap, json['mapType']),
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
      mediaAutoPlaybackPolicy: $enumDecodeNullable(
              _$WebViewMediaAutoPlaybackPolicyEnumMap,
              json['mediaAutoPlaybackPolicy']) ??
          WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
      backgroundColor: json['backgroundColor'] == null
          ? null
          : ColorRGBA.fromJson(json['backgroundColor'] as Map),
    )
      ..src = _$JsonConverterFromJson<String, String?>(
          json['src'], const Base64JsonConverter().fromJson)
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..url = json['url'] as String
      ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$PlacesGoogleMapsWebViewPropertiesToJson(
    PlacesGoogleMapsWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('src', const Base64JsonConverter().toJson(instance.src));
  writeNotNull(
      'controlVerticalScrollGesture', instance.controlVerticalScrollGesture);
  writeNotNull('controlHorizontalScrollGesture',
      instance.controlHorizontalScrollGesture);
  writeNotNull('controlScaleGesture', instance.controlScaleGesture);
  writeNotNull('controlTapGesture', instance.controlTapGesture);
  writeNotNull('controlLongPressGesture', instance.controlLongPressGesture);
  writeNotNull('controlForcePressGesture', instance.controlForcePressGesture);
  writeNotNull('allowsInlineMediaPlayback', instance.allowsInlineMediaPlayback);
  val['mediaAutoPlaybackPolicy'] = _$WebViewMediaAutoPlaybackPolicyEnumMap[
      instance.mediaAutoPlaybackPolicy]!;
  writeNotNull('backgroundColor', instance.backgroundColor?.toJson());
  writeNotNull('apiKey', instance.apiKey);
  writeNotNull('zoom', instance.zoom);
  writeNotNull('mapType', _$GoogleMapsMapTypeEnumMap[instance.mapType]);
  writeNotNull('language', instance.language);
  writeNotNull('region', instance.region);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['url'] = instance.url;
  val['query'] = instance.query;
  val['mapMode'] = _$GoogleMapsMapModeEnumMap[instance.mapMode]!;
  return val;
}

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
) =>
    json == null ? null : fromJson(json as Json);

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
        Map json) =>
    ViewGoogleMapsWebViewProperties(
      apiKey: json['apiKey'] as String?,
      center: Vec.fromJson(json['center'] as Map),
      zoom: json['zoom'] as int?,
      mapType: $enumDecodeNullable(_$GoogleMapsMapTypeEnumMap, json['mapType']),
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
      mediaAutoPlaybackPolicy: $enumDecodeNullable(
              _$WebViewMediaAutoPlaybackPolicyEnumMap,
              json['mediaAutoPlaybackPolicy']) ??
          WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
      backgroundColor: json['backgroundColor'] == null
          ? null
          : ColorRGBA.fromJson(json['backgroundColor'] as Map),
    )
      ..src = _$JsonConverterFromJson<String, String?>(
          json['src'], const Base64JsonConverter().fromJson)
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..url = json['url'] as String
      ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$ViewGoogleMapsWebViewPropertiesToJson(
    ViewGoogleMapsWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('src', const Base64JsonConverter().toJson(instance.src));
  writeNotNull(
      'controlVerticalScrollGesture', instance.controlVerticalScrollGesture);
  writeNotNull('controlHorizontalScrollGesture',
      instance.controlHorizontalScrollGesture);
  writeNotNull('controlScaleGesture', instance.controlScaleGesture);
  writeNotNull('controlTapGesture', instance.controlTapGesture);
  writeNotNull('controlLongPressGesture', instance.controlLongPressGesture);
  writeNotNull('controlForcePressGesture', instance.controlForcePressGesture);
  writeNotNull('allowsInlineMediaPlayback', instance.allowsInlineMediaPlayback);
  val['mediaAutoPlaybackPolicy'] = _$WebViewMediaAutoPlaybackPolicyEnumMap[
      instance.mediaAutoPlaybackPolicy]!;
  writeNotNull('backgroundColor', instance.backgroundColor?.toJson());
  writeNotNull('apiKey', instance.apiKey);
  writeNotNull('zoom', instance.zoom);
  writeNotNull('mapType', _$GoogleMapsMapTypeEnumMap[instance.mapType]);
  writeNotNull('language', instance.language);
  writeNotNull('region', instance.region);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['url'] = instance.url;
  val['center'] = instance.center.toJson();
  val['mapMode'] = _$GoogleMapsMapModeEnumMap[instance.mapMode]!;
  return val;
}

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
              _$GoogleMapsDirectionsModeEnumMap, json['mode']),
          units: $enumDecodeNullable(_$UnitSystemEnumMap, json['units']),
          center: json['center'] == null
              ? null
              : Vec.fromJson(json['center'] as Map),
          zoom: json['zoom'] as int?,
          mapType:
              $enumDecodeNullable(_$GoogleMapsMapTypeEnumMap, json['mapType']),
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
          mediaAutoPlaybackPolicy: $enumDecodeNullable(
                  _$WebViewMediaAutoPlaybackPolicyEnumMap,
                  json['mediaAutoPlaybackPolicy']) ??
              WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
          backgroundColor: json['backgroundColor'] == null
              ? null
              : ColorRGBA.fromJson(json['backgroundColor'] as Map),
        )
          ..src = _$JsonConverterFromJson<String, String?>(
              json['src'], const Base64JsonConverter().fromJson)
          ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
          ..url = json['url'] as String
          ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$DirectionsGoogleMapsWebViewPropertiesToJson(
    DirectionsGoogleMapsWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('src', const Base64JsonConverter().toJson(instance.src));
  writeNotNull(
      'controlVerticalScrollGesture', instance.controlVerticalScrollGesture);
  writeNotNull('controlHorizontalScrollGesture',
      instance.controlHorizontalScrollGesture);
  writeNotNull('controlScaleGesture', instance.controlScaleGesture);
  writeNotNull('controlTapGesture', instance.controlTapGesture);
  writeNotNull('controlLongPressGesture', instance.controlLongPressGesture);
  writeNotNull('controlForcePressGesture', instance.controlForcePressGesture);
  writeNotNull('allowsInlineMediaPlayback', instance.allowsInlineMediaPlayback);
  val['mediaAutoPlaybackPolicy'] = _$WebViewMediaAutoPlaybackPolicyEnumMap[
      instance.mediaAutoPlaybackPolicy]!;
  writeNotNull('backgroundColor', instance.backgroundColor?.toJson());
  writeNotNull('apiKey', instance.apiKey);
  writeNotNull('zoom', instance.zoom);
  writeNotNull('mapType', _$GoogleMapsMapTypeEnumMap[instance.mapType]);
  writeNotNull('language', instance.language);
  writeNotNull('region', instance.region);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['url'] = instance.url;
  val['origin'] = instance.origin;
  val['destination'] = instance.destination;
  val['waypoints'] = instance.waypoints;
  writeNotNull('mode', _$GoogleMapsDirectionsModeEnumMap[instance.mode]);
  val['avoid'] = instance.avoid
      .map((e) => _$GoogleMapsDirectionsAvoidEnumMap[e]!)
      .toList();
  writeNotNull('units', _$UnitSystemEnumMap[instance.units]);
  writeNotNull('center', instance.center?.toJson());
  val['mapMode'] = _$GoogleMapsMapModeEnumMap[instance.mapMode]!;
  return val;
}

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
              : Vec.fromJson(json['location'] as Map),
          pano: json['pano'] as String?,
          heading: json['heading'] as int?,
          pitch: json['pitch'] as int?,
          fov: json['fov'] as int?,
          zoom: json['zoom'] as int?,
          mapType:
              $enumDecodeNullable(_$GoogleMapsMapTypeEnumMap, json['mapType']),
          language: json['language'] as String?,
          region: json['region'] as String?,
          center: json['center'] == null
              ? null
              : Vec.fromJson(json['center'] as Map),
          controlVerticalScrollGesture:
              json['controlVerticalScrollGesture'] as bool?,
          controlHorizontalScrollGesture:
              json['controlHorizontalScrollGesture'] as bool?,
          controlScaleGesture: json['controlScaleGesture'] as bool?,
          controlTapGesture: json['controlTapGesture'] as bool?,
          controlLongPressGesture: json['controlLongPressGesture'] as bool?,
          controlForcePressGesture: json['controlForcePressGesture'] as bool?,
          allowsInlineMediaPlayback: json['allowsInlineMediaPlayback'] as bool?,
          mediaAutoPlaybackPolicy: $enumDecodeNullable(
                  _$WebViewMediaAutoPlaybackPolicyEnumMap,
                  json['mediaAutoPlaybackPolicy']) ??
              WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
          backgroundColor: json['backgroundColor'] == null
              ? null
              : ColorRGBA.fromJson(json['backgroundColor'] as Map),
        )
          ..src = _$JsonConverterFromJson<String, String?>(
              json['src'], const Base64JsonConverter().fromJson)
          ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
          ..url = json['url'] as String
          ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$StreetViewGoogleMapsWebViewPropertiesToJson(
    StreetViewGoogleMapsWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('src', const Base64JsonConverter().toJson(instance.src));
  writeNotNull(
      'controlVerticalScrollGesture', instance.controlVerticalScrollGesture);
  writeNotNull('controlHorizontalScrollGesture',
      instance.controlHorizontalScrollGesture);
  writeNotNull('controlScaleGesture', instance.controlScaleGesture);
  writeNotNull('controlTapGesture', instance.controlTapGesture);
  writeNotNull('controlLongPressGesture', instance.controlLongPressGesture);
  writeNotNull('controlForcePressGesture', instance.controlForcePressGesture);
  writeNotNull('allowsInlineMediaPlayback', instance.allowsInlineMediaPlayback);
  val['mediaAutoPlaybackPolicy'] = _$WebViewMediaAutoPlaybackPolicyEnumMap[
      instance.mediaAutoPlaybackPolicy]!;
  writeNotNull('backgroundColor', instance.backgroundColor?.toJson());
  writeNotNull('apiKey', instance.apiKey);
  writeNotNull('zoom', instance.zoom);
  writeNotNull('mapType', _$GoogleMapsMapTypeEnumMap[instance.mapType]);
  writeNotNull('language', instance.language);
  writeNotNull('region', instance.region);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['url'] = instance.url;
  writeNotNull('location', instance.location?.toJson());
  writeNotNull('pano', instance.pano);
  writeNotNull('heading', instance.heading);
  writeNotNull('pitch', instance.pitch);
  writeNotNull('fov', instance.fov);
  writeNotNull('center', instance.center?.toJson());
  val['mapMode'] = _$GoogleMapsMapModeEnumMap[instance.mapMode]!;
  return val;
}

SearchGoogleMapsWebViewProperties _$SearchGoogleMapsWebViewPropertiesFromJson(
        Map json) =>
    SearchGoogleMapsWebViewProperties(
      apiKey: json['apiKey'] as String?,
      query: json['query'] as String,
      zoom: json['zoom'] as int?,
      mapType: $enumDecodeNullable(_$GoogleMapsMapTypeEnumMap, json['mapType']),
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
      mediaAutoPlaybackPolicy: $enumDecodeNullable(
              _$WebViewMediaAutoPlaybackPolicyEnumMap,
              json['mediaAutoPlaybackPolicy']) ??
          WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
      backgroundColor: json['backgroundColor'] == null
          ? null
          : ColorRGBA.fromJson(json['backgroundColor'] as Map),
    )
      ..src = _$JsonConverterFromJson<String, String?>(
          json['src'], const Base64JsonConverter().fromJson)
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..url = json['url'] as String
      ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$SearchGoogleMapsWebViewPropertiesToJson(
    SearchGoogleMapsWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('src', const Base64JsonConverter().toJson(instance.src));
  writeNotNull(
      'controlVerticalScrollGesture', instance.controlVerticalScrollGesture);
  writeNotNull('controlHorizontalScrollGesture',
      instance.controlHorizontalScrollGesture);
  writeNotNull('controlScaleGesture', instance.controlScaleGesture);
  writeNotNull('controlTapGesture', instance.controlTapGesture);
  writeNotNull('controlLongPressGesture', instance.controlLongPressGesture);
  writeNotNull('controlForcePressGesture', instance.controlForcePressGesture);
  writeNotNull('allowsInlineMediaPlayback', instance.allowsInlineMediaPlayback);
  val['mediaAutoPlaybackPolicy'] = _$WebViewMediaAutoPlaybackPolicyEnumMap[
      instance.mediaAutoPlaybackPolicy]!;
  writeNotNull('backgroundColor', instance.backgroundColor?.toJson());
  writeNotNull('apiKey', instance.apiKey);
  writeNotNull('zoom', instance.zoom);
  writeNotNull('mapType', _$GoogleMapsMapTypeEnumMap[instance.mapType]);
  writeNotNull('language', instance.language);
  writeNotNull('region', instance.region);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['url'] = instance.url;
  val['query'] = instance.query;
  val['mapMode'] = _$GoogleMapsMapModeEnumMap[instance.mapMode]!;
  return val;
}
