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
          : ColorRGBA.fromJson(json['backgroundColor'] as Map)
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..embedType = $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$TweetTwitterWebViewPropertiesToJson(
    TweetTwitterWebViewProperties instance) {
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
  writeNotNull('theme', _$TwitterEmbedThemeEnumMap[instance.theme]);
  writeNotNull('twitterTailoring', instance.twitterTailoring);
  writeNotNull('languageCode', instance.languageCode);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['tweetURL'] = instance.tweetURL;
  writeNotNull('hideConversation', instance.hideConversation);
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
          : ColorRGBA.fromJson(json['backgroundColor'] as Map),
    )
      ..src = _$JsonConverterFromJson<String, String?>(
          json['src'], const Base64JsonConverter().fromJson)
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..embedType = $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$TimelineTwitterWebViewPropertiesToJson(
    TimelineTwitterWebViewProperties instance) {
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
  writeNotNull('theme', _$TwitterEmbedThemeEnumMap[instance.theme]);
  writeNotNull('twitterTailoring', instance.twitterTailoring);
  writeNotNull('languageCode', instance.languageCode);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['timelineURL'] = instance.timelineURL;
  writeNotNull('width', instance.width);
  writeNotNull('height', instance.height);
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
              : ColorRGBA.fromJson(json['backgroundColor'] as Map),
        )
          ..src = _$JsonConverterFromJson<String, String?>(
              json['src'], const Base64JsonConverter().fromJson)
          ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
          ..embedType =
              $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$FollowButtonTwitterWebViewPropertiesToJson(
    FollowButtonTwitterWebViewProperties instance) {
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
  writeNotNull('theme', _$TwitterEmbedThemeEnumMap[instance.theme]);
  writeNotNull('twitterTailoring', instance.twitterTailoring);
  writeNotNull('languageCode', instance.languageCode);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['handle'] = instance.handle;
  writeNotNull('hideUsername', instance.hideUsername);
  writeNotNull('largeButton', instance.largeButton);
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
              : ColorRGBA.fromJson(json['backgroundColor'] as Map),
        )
          ..src = _$JsonConverterFromJson<String, String?>(
              json['src'], const Base64JsonConverter().fromJson)
          ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
          ..embedType =
              $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$MentionButtonTwitterWebViewPropertiesToJson(
    MentionButtonTwitterWebViewProperties instance) {
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
  writeNotNull('theme', _$TwitterEmbedThemeEnumMap[instance.theme]);
  writeNotNull('twitterTailoring', instance.twitterTailoring);
  writeNotNull('languageCode', instance.languageCode);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['handle'] = instance.handle;
  writeNotNull('largeButton', instance.largeButton);
  writeNotNull('prefilledText', instance.prefilledText);
  writeNotNull('recommendedAccounts', instance.recommendedAccounts);
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
              : ColorRGBA.fromJson(json['backgroundColor'] as Map),
        )
          ..src = _$JsonConverterFromJson<String, String?>(
              json['src'], const Base64JsonConverter().fromJson)
          ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
          ..embedType =
              $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$HashtagButtonTwitterWebViewPropertiesToJson(
    HashtagButtonTwitterWebViewProperties instance) {
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
  writeNotNull('theme', _$TwitterEmbedThemeEnumMap[instance.theme]);
  writeNotNull('twitterTailoring', instance.twitterTailoring);
  writeNotNull('languageCode', instance.languageCode);
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  val['hashtag'] = instance.hashtag;
  writeNotNull('largeButton', instance.largeButton);
  writeNotNull('prefilledText', instance.prefilledText);
  writeNotNull('recommendedAccounts', instance.recommendedAccounts);
  writeNotNull('specificURLInTweet', instance.specificURLInTweet);
  val['embedType'] = _$TwitterEmbedTypeEnumMap[instance.embedType]!;
  return val;
}
