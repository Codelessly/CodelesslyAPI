// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_view_twitter_properties.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TweetTwitterWebViewProperties _$TweetTwitterWebViewPropertiesFromJson(
        Map json) =>
    TweetTwitterWebViewProperties(
      tweetURL: json['tweetURL'] as String,
      hideConversation: json['hideConversation'] as bool?,
      theme: $enumDecodeNullable(_$TwitterEmbedThemeEnumMap, json['theme']),
      twitterTailoring: json['twitterTailoring'] as bool?,
      languageCode: json['languageCode'] as String?,
    )
      ..src = _$JsonConverterFromJson<String, String?>(
          json['src'], const Base64JsonConverter().fromJson)
      ..controlVerticalScrollGesture =
          json['controlVerticalScrollGesture'] as bool?
      ..controlHorizontalScrollGesture =
          json['controlHorizontalScrollGesture'] as bool?
      ..controlScaleGesture = json['controlScaleGesture'] as bool?
      ..controlTapGesture = json['controlTapGesture'] as bool?
      ..controlLongPressGesture = json['controlLongPressGesture'] as bool?
      ..controlForcePressGesture = json['controlForcePressGesture'] as bool?
      ..allowsInlineMediaPlayback = json['allowsInlineMediaPlayback'] as bool?
      ..mediaAutoPlaybackPolicy = $enumDecode(
          _$WebViewMediaAutoPlaybackPolicyEnumMap,
          json['mediaAutoPlaybackPolicy'])
      ..backgroundColor = json['backgroundColor'] == null
          ? null
          : ColorRGBA.fromJson(json['backgroundColor'])
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..embedType = $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$TweetTwitterWebViewPropertiesToJson(
    TweetTwitterWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

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
  val['mediaAutoPlaybackPolicy'] = _$WebViewMediaAutoPlaybackPolicyEnumMap[
      instance.mediaAutoPlaybackPolicy]!;
  writeNotNull('backgroundColor', instance.backgroundColor,
      instance.backgroundColor?.toJson(), null);
  writeNotNull('theme', instance.theme,
      _$TwitterEmbedThemeEnumMap[instance.theme], null);
  writeNotNull('twitterTailoring', instance.twitterTailoring,
      instance.twitterTailoring, null);
  writeNotNull(
      'languageCode', instance.languageCode, instance.languageCode, null);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['tweetURL'] = instance.tweetURL;
  writeNotNull('hideConversation', instance.hideConversation,
      instance.hideConversation, null);
  val['embedType'] = _$TwitterEmbedTypeEnumMap[instance.embedType]!;
  return val;
}

const _$TwitterEmbedThemeEnumMap = {
  TwitterEmbedTheme.light: 'light',
  TwitterEmbedTheme.dark: 'dark',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

const _$WebViewMediaAutoPlaybackPolicyEnumMap = {
  WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia:
      'requireUserActionForAllMedia',
  WebViewMediaAutoPlaybackPolicy.alwaysPlayAllMedia: 'alwaysPlayAllMedia',
};

const _$WebViewTypeEnumMap = {
  WebViewType.webpage: 'webpage',
  WebViewType.googleMaps: 'googleMaps',
  WebViewType.twitter: 'twitter',
};

const _$TwitterEmbedTypeEnumMap = {
  TwitterEmbedType.timeline: 'timeline',
  TwitterEmbedType.tweet: 'tweet',
  TwitterEmbedType.mention: 'mention',
  TwitterEmbedType.hashtag: 'hashtag',
  TwitterEmbedType.follow: 'follow',
};

TimelineTwitterWebViewProperties _$TimelineTwitterWebViewPropertiesFromJson(
        Map json) =>
    TimelineTwitterWebViewProperties(
      timelineURL: json['timelineURL'] as String,
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      theme: $enumDecodeNullable(_$TwitterEmbedThemeEnumMap, json['theme']),
      twitterTailoring: json['twitterTailoring'] as bool?,
      languageCode: json['languageCode'] as String?,
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
      ..embedType = $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$TimelineTwitterWebViewPropertiesToJson(
    TimelineTwitterWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

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
  writeNotNull('theme', instance.theme,
      _$TwitterEmbedThemeEnumMap[instance.theme], null);
  writeNotNull('twitterTailoring', instance.twitterTailoring,
      instance.twitterTailoring, null);
  writeNotNull(
      'languageCode', instance.languageCode, instance.languageCode, null);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['timelineURL'] = instance.timelineURL;
  writeNotNull('width', instance.width, instance.width, null);
  writeNotNull('height', instance.height, instance.height, null);
  val['embedType'] = _$TwitterEmbedTypeEnumMap[instance.embedType]!;
  return val;
}

FollowButtonTwitterWebViewProperties
    _$FollowButtonTwitterWebViewPropertiesFromJson(Map json) =>
        FollowButtonTwitterWebViewProperties(
          handle: json['handle'] as String,
          hideUsername: json['hideUsername'] as bool?,
          largeButton: json['largeButton'] as bool?,
          theme: $enumDecodeNullable(_$TwitterEmbedThemeEnumMap, json['theme']),
          twitterTailoring: json['twitterTailoring'] as bool?,
          languageCode: json['languageCode'] as String?,
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
          ..embedType =
              $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$FollowButtonTwitterWebViewPropertiesToJson(
    FollowButtonTwitterWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

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
  writeNotNull('theme', instance.theme,
      _$TwitterEmbedThemeEnumMap[instance.theme], null);
  writeNotNull('twitterTailoring', instance.twitterTailoring,
      instance.twitterTailoring, null);
  writeNotNull(
      'languageCode', instance.languageCode, instance.languageCode, null);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['handle'] = instance.handle;
  writeNotNull(
      'hideUsername', instance.hideUsername, instance.hideUsername, null);
  writeNotNull('largeButton', instance.largeButton, instance.largeButton, null);
  val['embedType'] = _$TwitterEmbedTypeEnumMap[instance.embedType]!;
  return val;
}

MentionButtonTwitterWebViewProperties
    _$MentionButtonTwitterWebViewPropertiesFromJson(Map json) =>
        MentionButtonTwitterWebViewProperties(
          handle: json['handle'] as String,
          largeButton: json['largeButton'] as bool?,
          prefilledText: json['prefilledText'] as String?,
          recommendedAccounts: (json['recommendedAccounts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
          theme: $enumDecodeNullable(_$TwitterEmbedThemeEnumMap, json['theme']),
          twitterTailoring: json['twitterTailoring'] as bool?,
          languageCode: json['languageCode'] as String?,
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
          ..embedType =
              $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$MentionButtonTwitterWebViewPropertiesToJson(
    MentionButtonTwitterWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

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
  writeNotNull('theme', instance.theme,
      _$TwitterEmbedThemeEnumMap[instance.theme], null);
  writeNotNull('twitterTailoring', instance.twitterTailoring,
      instance.twitterTailoring, null);
  writeNotNull(
      'languageCode', instance.languageCode, instance.languageCode, null);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['handle'] = instance.handle;
  writeNotNull('largeButton', instance.largeButton, instance.largeButton, null);
  writeNotNull(
      'prefilledText', instance.prefilledText, instance.prefilledText, null);
  writeNotNull('recommendedAccounts', instance.recommendedAccounts,
      instance.recommendedAccounts, null);
  val['embedType'] = _$TwitterEmbedTypeEnumMap[instance.embedType]!;
  return val;
}

HashtagButtonTwitterWebViewProperties
    _$HashtagButtonTwitterWebViewPropertiesFromJson(Map json) =>
        HashtagButtonTwitterWebViewProperties(
          hashtag: json['hashtag'] as String,
          largeButton: json['largeButton'] as bool?,
          prefilledText: json['prefilledText'] as String?,
          recommendedAccounts: (json['recommendedAccounts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
          specificURLInTweet: json['specificURLInTweet'] as String?,
          theme: $enumDecodeNullable(_$TwitterEmbedThemeEnumMap, json['theme']),
          twitterTailoring: json['twitterTailoring'] as bool?,
          languageCode: json['languageCode'] as String?,
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
          ..embedType =
              $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$HashtagButtonTwitterWebViewPropertiesToJson(
    HashtagButtonTwitterWebViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize = shouldSerialize(key, value, jsonValue, defaultValue);

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
  writeNotNull('theme', instance.theme,
      _$TwitterEmbedThemeEnumMap[instance.theme], null);
  writeNotNull('twitterTailoring', instance.twitterTailoring,
      instance.twitterTailoring, null);
  writeNotNull(
      'languageCode', instance.languageCode, instance.languageCode, null);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['hashtag'] = instance.hashtag;
  writeNotNull('largeButton', instance.largeButton, instance.largeButton, null);
  writeNotNull(
      'prefilledText', instance.prefilledText, instance.prefilledText, null);
  writeNotNull('recommendedAccounts', instance.recommendedAccounts,
      instance.recommendedAccounts, null);
  writeNotNull('specificURLInTweet', instance.specificURLInTweet,
      instance.specificURLInTweet, null);
  val['embedType'] = _$TwitterEmbedTypeEnumMap[instance.embedType]!;
  return val;
}
