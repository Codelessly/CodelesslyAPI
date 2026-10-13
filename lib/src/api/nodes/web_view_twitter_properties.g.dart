// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_view_twitter_properties.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$TweetTwitterWebViewPropertiesOmitDefaults(
  TweetTwitterWebViewProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.embedType, TwitterEmbedType.tweet))
    json.remove('embedType');
  if (isJsonDefault(instance.webviewType, WebViewType.twitter))
    json.remove('webviewType');
  return json;
}

Map<String, dynamic> _$TimelineTwitterWebViewPropertiesOmitDefaults(
  TimelineTwitterWebViewProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.embedType, TwitterEmbedType.timeline))
    json.remove('embedType');
  if (isJsonDefault(instance.webviewType, WebViewType.twitter))
    json.remove('webviewType');
  if (isJsonDefault(
    instance.mediaAutoPlaybackPolicy,
    WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
  ))
    json.remove('mediaAutoPlaybackPolicy');
  return json;
}

Map<String, dynamic> _$FollowButtonTwitterWebViewPropertiesOmitDefaults(
  FollowButtonTwitterWebViewProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.embedType, TwitterEmbedType.follow))
    json.remove('embedType');
  if (isJsonDefault(instance.webviewType, WebViewType.twitter))
    json.remove('webviewType');
  if (isJsonDefault(
    instance.mediaAutoPlaybackPolicy,
    WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
  ))
    json.remove('mediaAutoPlaybackPolicy');
  return json;
}

Map<String, dynamic> _$MentionButtonTwitterWebViewPropertiesOmitDefaults(
  MentionButtonTwitterWebViewProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.embedType, TwitterEmbedType.mention))
    json.remove('embedType');
  if (isJsonDefault(instance.webviewType, WebViewType.twitter))
    json.remove('webviewType');
  if (isJsonDefault(
    instance.mediaAutoPlaybackPolicy,
    WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
  ))
    json.remove('mediaAutoPlaybackPolicy');
  return json;
}

Map<String, dynamic> _$HashtagButtonTwitterWebViewPropertiesOmitDefaults(
  HashtagButtonTwitterWebViewProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.embedType, TwitterEmbedType.hashtag))
    json.remove('embedType');
  if (isJsonDefault(instance.webviewType, WebViewType.twitter))
    json.remove('webviewType');
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

TweetTwitterWebViewProperties _$TweetTwitterWebViewPropertiesFromJson(
  Map json,
) =>
    TweetTwitterWebViewProperties(
        tweetURL: json['tweetURL'] as String,
        hideConversation: json['hideConversation'] as bool?,
        theme: $enumDecodeNullable(_$TwitterEmbedThemeEnumMap, json['theme']),
        twitterTailoring: json['twitterTailoring'] as bool?,
        languageCode: json['languageCode'] as String?,
      )
      ..src = _$JsonConverterFromJson<String, String?>(
        json['src'],
        const Base64JsonConverter().fromJson,
      )
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
        json['mediaAutoPlaybackPolicy'],
      )
      ..backgroundColor = json['backgroundColor'] == null
          ? null
          : ColorRGBA.fromJson(json['backgroundColor'])
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..embedType = $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$TweetTwitterWebViewPropertiesToJson(
  TweetTwitterWebViewProperties instance,
) => <String, dynamic>{
  'src': ?const Base64JsonConverter().toJson(instance.src),
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
  'theme': ?_$TwitterEmbedThemeEnumMap[instance.theme],
  'twitterTailoring': ?instance.twitterTailoring,
  'languageCode': ?instance.languageCode,
  'webviewType': _$WebViewTypeEnumMap[instance.webviewType]!,
  'tweetURL': instance.tweetURL,
  'hideConversation': ?instance.hideConversation,
  'embedType': _$TwitterEmbedTypeEnumMap[instance.embedType]!,
};

const _$TwitterEmbedThemeEnumMap = {
  TwitterEmbedTheme.light: 'light',
  TwitterEmbedTheme.dark: 'dark',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

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
  Map json,
) =>
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
      ..src = _$JsonConverterFromJson<String, String?>(
        json['src'],
        const Base64JsonConverter().fromJson,
      )
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..embedType = $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$TimelineTwitterWebViewPropertiesToJson(
  TimelineTwitterWebViewProperties instance,
) => <String, dynamic>{
  'src': ?const Base64JsonConverter().toJson(instance.src),
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
  'theme': ?_$TwitterEmbedThemeEnumMap[instance.theme],
  'twitterTailoring': ?instance.twitterTailoring,
  'languageCode': ?instance.languageCode,
  'webviewType': _$WebViewTypeEnumMap[instance.webviewType]!,
  'timelineURL': instance.timelineURL,
  'width': ?instance.width,
  'height': ?instance.height,
  'embedType': _$TwitterEmbedTypeEnumMap[instance.embedType]!,
};

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
      ..src = _$JsonConverterFromJson<String, String?>(
        json['src'],
        const Base64JsonConverter().fromJson,
      )
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..embedType = $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$FollowButtonTwitterWebViewPropertiesToJson(
  FollowButtonTwitterWebViewProperties instance,
) => <String, dynamic>{
  'src': ?const Base64JsonConverter().toJson(instance.src),
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
  'theme': ?_$TwitterEmbedThemeEnumMap[instance.theme],
  'twitterTailoring': ?instance.twitterTailoring,
  'languageCode': ?instance.languageCode,
  'webviewType': _$WebViewTypeEnumMap[instance.webviewType]!,
  'handle': instance.handle,
  'hideUsername': ?instance.hideUsername,
  'largeButton': ?instance.largeButton,
  'embedType': _$TwitterEmbedTypeEnumMap[instance.embedType]!,
};

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
      ..src = _$JsonConverterFromJson<String, String?>(
        json['src'],
        const Base64JsonConverter().fromJson,
      )
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..embedType = $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$MentionButtonTwitterWebViewPropertiesToJson(
  MentionButtonTwitterWebViewProperties instance,
) => <String, dynamic>{
  'src': ?const Base64JsonConverter().toJson(instance.src),
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
  'theme': ?_$TwitterEmbedThemeEnumMap[instance.theme],
  'twitterTailoring': ?instance.twitterTailoring,
  'languageCode': ?instance.languageCode,
  'webviewType': _$WebViewTypeEnumMap[instance.webviewType]!,
  'handle': instance.handle,
  'largeButton': ?instance.largeButton,
  'prefilledText': ?instance.prefilledText,
  'recommendedAccounts': ?instance.recommendedAccounts,
  'embedType': _$TwitterEmbedTypeEnumMap[instance.embedType]!,
};

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
      ..src = _$JsonConverterFromJson<String, String?>(
        json['src'],
        const Base64JsonConverter().fromJson,
      )
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType'])
      ..embedType = $enumDecode(_$TwitterEmbedTypeEnumMap, json['embedType']);

Map<String, dynamic> _$HashtagButtonTwitterWebViewPropertiesToJson(
  HashtagButtonTwitterWebViewProperties instance,
) => <String, dynamic>{
  'src': ?const Base64JsonConverter().toJson(instance.src),
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
  'theme': ?_$TwitterEmbedThemeEnumMap[instance.theme],
  'twitterTailoring': ?instance.twitterTailoring,
  'languageCode': ?instance.languageCode,
  'webviewType': _$WebViewTypeEnumMap[instance.webviewType]!,
  'hashtag': instance.hashtag,
  'largeButton': ?instance.largeButton,
  'prefilledText': ?instance.prefilledText,
  'recommendedAccounts': ?instance.recommendedAccounts,
  'specificURLInTweet': ?instance.specificURLInTweet,
  'embedType': _$TwitterEmbedTypeEnumMap[instance.embedType]!,
};
