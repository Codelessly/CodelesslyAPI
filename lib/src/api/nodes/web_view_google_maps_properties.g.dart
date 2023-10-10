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
          : ColorRGBA.fromJson(json['backgroundColor']),
    )
      ..src = _$JsonConverterFromJson<String, String?>(
          json['src'], const Base64JsonConverter().fromJson)
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..url = json['url'] as String
      ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$PlacesGoogleMapsWebViewPropertiesToJson(
    PlacesGoogleMapsWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('src', instance.src,
      const Base64JsonConverter().toJson(instance.src), null);
  writeNotNull(
      'controlVerticalScrollGesture',
      instance.controlVerticalScrollGesture,
      instance.controlVerticalScrollGesture,
      null);
  writeNotNull(
      'controlHorizontalScrollGesture',
      instance.controlHorizontalScrollGesture,
      instance.controlHorizontalScrollGesture,
      null);
  writeNotNull('controlScaleGesture', instance.controlScaleGesture,
      instance.controlScaleGesture, null);
  writeNotNull('controlTapGesture', instance.controlTapGesture,
      instance.controlTapGesture, null);
  writeNotNull('controlLongPressGesture', instance.controlLongPressGesture,
      instance.controlLongPressGesture, null);
  writeNotNull('controlForcePressGesture', instance.controlForcePressGesture,
      instance.controlForcePressGesture, null);
  writeNotNull('allowsInlineMediaPlayback', instance.allowsInlineMediaPlayback,
      instance.allowsInlineMediaPlayback, null);
  writeNotNull(
      'mediaAutoPlaybackPolicy',
      instance.mediaAutoPlaybackPolicy,
      _$WebViewMediaAutoPlaybackPolicyEnumMap[
          instance.mediaAutoPlaybackPolicy]!,
      WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia);
  writeNotNull('backgroundColor', instance.backgroundColor,
      instance.backgroundColor?.toJson(), null);
  writeNotNull('apiKey', instance.apiKey, instance.apiKey, null);
  writeNotNull('zoom', instance.zoom, instance.zoom, null);
  writeNotNull('mapType', instance.mapType,
      _$GoogleMapsMapTypeEnumMap[instance.mapType], null);
  writeNotNull('language', instance.language, instance.language, null);
  writeNotNull('region', instance.region, instance.region, null);
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
          : ColorRGBA.fromJson(json['backgroundColor']),
    )
      ..src = _$JsonConverterFromJson<String, String?>(
          json['src'], const Base64JsonConverter().fromJson)
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..url = json['url'] as String
      ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$ViewGoogleMapsWebViewPropertiesToJson(
    ViewGoogleMapsWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('src', instance.src,
      const Base64JsonConverter().toJson(instance.src), null);
  writeNotNull(
      'controlVerticalScrollGesture',
      instance.controlVerticalScrollGesture,
      instance.controlVerticalScrollGesture,
      null);
  writeNotNull(
      'controlHorizontalScrollGesture',
      instance.controlHorizontalScrollGesture,
      instance.controlHorizontalScrollGesture,
      null);
  writeNotNull('controlScaleGesture', instance.controlScaleGesture,
      instance.controlScaleGesture, null);
  writeNotNull('controlTapGesture', instance.controlTapGesture,
      instance.controlTapGesture, null);
  writeNotNull('controlLongPressGesture', instance.controlLongPressGesture,
      instance.controlLongPressGesture, null);
  writeNotNull('controlForcePressGesture', instance.controlForcePressGesture,
      instance.controlForcePressGesture, null);
  writeNotNull('allowsInlineMediaPlayback', instance.allowsInlineMediaPlayback,
      instance.allowsInlineMediaPlayback, null);
  writeNotNull(
      'mediaAutoPlaybackPolicy',
      instance.mediaAutoPlaybackPolicy,
      _$WebViewMediaAutoPlaybackPolicyEnumMap[
          instance.mediaAutoPlaybackPolicy]!,
      WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia);
  writeNotNull('backgroundColor', instance.backgroundColor,
      instance.backgroundColor?.toJson(), null);
  writeNotNull('apiKey', instance.apiKey, instance.apiKey, null);
  writeNotNull('zoom', instance.zoom, instance.zoom, null);
  writeNotNull('mapType', instance.mapType,
      _$GoogleMapsMapTypeEnumMap[instance.mapType], null);
  writeNotNull('language', instance.language, instance.language, null);
  writeNotNull('region', instance.region, instance.region, null);
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
              : ColorRGBA.fromJson(json['backgroundColor']),
        )
          ..src = _$JsonConverterFromJson<String, String?>(
              json['src'], const Base64JsonConverter().fromJson)
          ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
          ..url = json['url'] as String
          ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$DirectionsGoogleMapsWebViewPropertiesToJson(
    DirectionsGoogleMapsWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('src', instance.src,
      const Base64JsonConverter().toJson(instance.src), null);
  writeNotNull(
      'controlVerticalScrollGesture',
      instance.controlVerticalScrollGesture,
      instance.controlVerticalScrollGesture,
      null);
  writeNotNull(
      'controlHorizontalScrollGesture',
      instance.controlHorizontalScrollGesture,
      instance.controlHorizontalScrollGesture,
      null);
  writeNotNull('controlScaleGesture', instance.controlScaleGesture,
      instance.controlScaleGesture, null);
  writeNotNull('controlTapGesture', instance.controlTapGesture,
      instance.controlTapGesture, null);
  writeNotNull('controlLongPressGesture', instance.controlLongPressGesture,
      instance.controlLongPressGesture, null);
  writeNotNull('controlForcePressGesture', instance.controlForcePressGesture,
      instance.controlForcePressGesture, null);
  writeNotNull('allowsInlineMediaPlayback', instance.allowsInlineMediaPlayback,
      instance.allowsInlineMediaPlayback, null);
  writeNotNull(
      'mediaAutoPlaybackPolicy',
      instance.mediaAutoPlaybackPolicy,
      _$WebViewMediaAutoPlaybackPolicyEnumMap[
          instance.mediaAutoPlaybackPolicy]!,
      WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia);
  writeNotNull('backgroundColor', instance.backgroundColor,
      instance.backgroundColor?.toJson(), null);
  writeNotNull('apiKey', instance.apiKey, instance.apiKey, null);
  writeNotNull('zoom', instance.zoom, instance.zoom, null);
  writeNotNull('mapType', instance.mapType,
      _$GoogleMapsMapTypeEnumMap[instance.mapType], null);
  writeNotNull('language', instance.language, instance.language, null);
  writeNotNull('region', instance.region, instance.region, null);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['url'] = instance.url;
  val['origin'] = instance.origin;
  val['destination'] = instance.destination;
  val['waypoints'] = instance.waypoints;
  writeNotNull('mode', instance.mode,
      _$GoogleMapsDirectionsModeEnumMap[instance.mode], null);
  val['avoid'] = instance.avoid
      .map((e) => _$GoogleMapsDirectionsAvoidEnumMap[e]!)
      .toList();
  writeNotNull(
      'units', instance.units, _$UnitSystemEnumMap[instance.units], null);
  writeNotNull('center', instance.center, instance.center?.toJson(), null);
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
              : ColorRGBA.fromJson(json['backgroundColor']),
        )
          ..src = _$JsonConverterFromJson<String, String?>(
              json['src'], const Base64JsonConverter().fromJson)
          ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
          ..url = json['url'] as String
          ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$StreetViewGoogleMapsWebViewPropertiesToJson(
    StreetViewGoogleMapsWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('src', instance.src,
      const Base64JsonConverter().toJson(instance.src), null);
  writeNotNull(
      'controlVerticalScrollGesture',
      instance.controlVerticalScrollGesture,
      instance.controlVerticalScrollGesture,
      null);
  writeNotNull(
      'controlHorizontalScrollGesture',
      instance.controlHorizontalScrollGesture,
      instance.controlHorizontalScrollGesture,
      null);
  writeNotNull('controlScaleGesture', instance.controlScaleGesture,
      instance.controlScaleGesture, null);
  writeNotNull('controlTapGesture', instance.controlTapGesture,
      instance.controlTapGesture, null);
  writeNotNull('controlLongPressGesture', instance.controlLongPressGesture,
      instance.controlLongPressGesture, null);
  writeNotNull('controlForcePressGesture', instance.controlForcePressGesture,
      instance.controlForcePressGesture, null);
  writeNotNull('allowsInlineMediaPlayback', instance.allowsInlineMediaPlayback,
      instance.allowsInlineMediaPlayback, null);
  writeNotNull(
      'mediaAutoPlaybackPolicy',
      instance.mediaAutoPlaybackPolicy,
      _$WebViewMediaAutoPlaybackPolicyEnumMap[
          instance.mediaAutoPlaybackPolicy]!,
      WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia);
  writeNotNull('backgroundColor', instance.backgroundColor,
      instance.backgroundColor?.toJson(), null);
  writeNotNull('apiKey', instance.apiKey, instance.apiKey, null);
  writeNotNull('zoom', instance.zoom, instance.zoom, null);
  writeNotNull('mapType', instance.mapType,
      _$GoogleMapsMapTypeEnumMap[instance.mapType], null);
  writeNotNull('language', instance.language, instance.language, null);
  writeNotNull('region', instance.region, instance.region, null);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['url'] = instance.url;
  writeNotNull(
      'location', instance.location, instance.location?.toJson(), null);
  writeNotNull('pano', instance.pano, instance.pano, null);
  writeNotNull('heading', instance.heading, instance.heading, null);
  writeNotNull('pitch', instance.pitch, instance.pitch, null);
  writeNotNull('fov', instance.fov, instance.fov, null);
  writeNotNull('center', instance.center, instance.center?.toJson(), null);
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
          : ColorRGBA.fromJson(json['backgroundColor']),
    )
      ..src = _$JsonConverterFromJson<String, String?>(
          json['src'], const Base64JsonConverter().fromJson)
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..url = json['url'] as String
      ..mapMode = $enumDecode(_$GoogleMapsMapModeEnumMap, json['mapMode']);

Map<String, dynamic> _$SearchGoogleMapsWebViewPropertiesToJson(
    SearchGoogleMapsWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('src', instance.src,
      const Base64JsonConverter().toJson(instance.src), null);
  writeNotNull(
      'controlVerticalScrollGesture',
      instance.controlVerticalScrollGesture,
      instance.controlVerticalScrollGesture,
      null);
  writeNotNull(
      'controlHorizontalScrollGesture',
      instance.controlHorizontalScrollGesture,
      instance.controlHorizontalScrollGesture,
      null);
  writeNotNull('controlScaleGesture', instance.controlScaleGesture,
      instance.controlScaleGesture, null);
  writeNotNull('controlTapGesture', instance.controlTapGesture,
      instance.controlTapGesture, null);
  writeNotNull('controlLongPressGesture', instance.controlLongPressGesture,
      instance.controlLongPressGesture, null);
  writeNotNull('controlForcePressGesture', instance.controlForcePressGesture,
      instance.controlForcePressGesture, null);
  writeNotNull('allowsInlineMediaPlayback', instance.allowsInlineMediaPlayback,
      instance.allowsInlineMediaPlayback, null);
  writeNotNull(
      'mediaAutoPlaybackPolicy',
      instance.mediaAutoPlaybackPolicy,
      _$WebViewMediaAutoPlaybackPolicyEnumMap[
          instance.mediaAutoPlaybackPolicy]!,
      WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia);
  writeNotNull('backgroundColor', instance.backgroundColor,
      instance.backgroundColor?.toJson(), null);
  writeNotNull('apiKey', instance.apiKey, instance.apiKey, null);
  writeNotNull('zoom', instance.zoom, instance.zoom, null);
  writeNotNull('mapType', instance.mapType,
      _$GoogleMapsMapTypeEnumMap[instance.mapType], null);
  writeNotNull('language', instance.language, instance.language, null);
  writeNotNull('region', instance.region, instance.region, null);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['url'] = instance.url;
  val['query'] = instance.query;
  val['mapMode'] = _$GoogleMapsMapModeEnumMap[instance.mapMode]!;
  return val;
}
