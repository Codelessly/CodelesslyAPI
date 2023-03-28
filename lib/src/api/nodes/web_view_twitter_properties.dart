// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:json_annotation/json_annotation.dart';

import '../models/models.dart';
import 'web_view_node.dart';

part 'web_view_twitter_properties.g.dart';

/// A [WebViewProperties] implementation that displays a Twitter webview.
///
/// There are multiple kinds of [TwitterWebViewProperties], which is why
/// this class is abstract and provides a base for all of them.
///
/// See: [TweetTwitterWebViewProperties], [TimelineTwitterWebViewProperties],
/// [FollowButtonTwitterWebViewProperties],
/// [MentionButtonTwitterWebViewProperties],
/// [HashtagButtonTwitterWebViewProperties],
abstract class TwitterWebViewProperties extends WebViewProperties {
  /// The color theme that the Twitter webview should use.
  TwitterEmbedTheme? theme;

  /// Opt-out of tailoring Twitter
  ///
  /// QUOTE:
  ///   When you view Twitter content such as embedded Tweets, buttons, or
  ///   timelines integrated into other websites using Twitter for Websites,
  ///   Twitter may receive information, including the web page you visited,
  ///   your IP address, browser type, operating system, and cookie information.
  ///
  ///   This information helps us to improve our products and services.
  ///
  ///   Learn more about the information we receive and how we use it in our
  ///   privacy policy and cookies policy.
  ///
  /// https://developer.twitter.com/en/docs/twitter-for-websites/privacy
  bool? twitterTailoring;

  /// The language code to use for the Twitter webview.
  ///
  /// QUOTE:
  ///   Translated widget text is available in 34 of the languages supported
  ///   by Twitter.com.
  ///
  ///   Twitter for Websites will extract the most appropriate language from
  ///   its position in the DOM tree, if no language is provided in the widget
  ///   markup. Pages which define an unsupported script or region will be
  ///   mapped to the closest available language: e.g. pt-BR will use pt if
  ///   Portuguese is available but a Brazilian regional localization is not.
  ///
  ///   United States English is the default if a page’s language code does not
  ///   match any available translation.
  ///
  ///   NOTE: Setting the language only affects the language of Twitter elements
  ///   such as action text and timestamp display; Tweet text is always
  ///   displayed in its originally authored language.
  ///
  /// https://developer.twitter.com/en/docs/twitter-for-websites/supported-languages
  String? languageCode;

  @override
  late WebViewType webviewType = WebViewType.twitter;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String label = 'Twitter';

  /// The type of Twitter webview to display. This is set by each sub-type
  /// of [TwitterWebViewProperties].
  late TwitterEmbedType embedType;

  /// Creates a new [TwitterWebViewProperties].
  TwitterWebViewProperties({
    this.theme,
    this.twitterTailoring,
    this.languageCode,

    // inherited
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

  /// Creates a new [TwitterWebViewProperties] from a [json] map.
  ///
  /// The [embedType] is checked manually in order to return the most
  /// appropriate sub-type of [TwitterWebViewProperties] instance.
  ///
  /// TODO: This function is not extendable. If a new type of
  /// [TwitterWebViewProperties] is added, this function will need to be
  /// updated manually and it inherently disallows any third-party plugins to
  /// add their own types of [TwitterWebViewProperties].
  factory TwitterWebViewProperties.fromJson(Map json) {
    switch (TwitterEmbedType.values.byName(json['embedType'])) {
      case TwitterEmbedType.timeline:
        return TimelineTwitterWebViewProperties.fromJson(json);
      case TwitterEmbedType.tweet:
        return TweetTwitterWebViewProperties.fromJson(json);
      case TwitterEmbedType.mention:
        return MentionButtonTwitterWebViewProperties.fromJson(json);
      case TwitterEmbedType.hashtag:
        return HashtagButtonTwitterWebViewProperties.fromJson(json);
      case TwitterEmbedType.follow:
        return FollowButtonTwitterWebViewProperties.fromJson(json);
    }
  }
}

/// Implements the Twitter Tweet embed.
@JsonSerializable()
class TweetTwitterWebViewProperties extends TwitterWebViewProperties {
  /// The URL of the tweet to use.
  String tweetURL;

  /// Whether to hide the tweet's conversation.
  bool? hideConversation;

  @override
  late TwitterEmbedType embedType = TwitterEmbedType.tweet;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String label = 'Twitter - Tweet';

  /// Creates a new [TweetTwitterWebViewProperties] instance given a [tweetURL].
  TweetTwitterWebViewProperties({
    required this.tweetURL,
    this.hideConversation,
    super.theme,
    super.twitterTailoring,
    super.languageCode,
  }) {
    regenSource();
  }

  @override
  void regenSource() {
    src = '<blockquote class="twitter-tweet"'
        '${languageCode == null ? '' : ' data-lang="$languageCode"'}'
        '${theme == null ? '' : ' data-theme="${theme!.name}"'}'
        '${twitterTailoring == null ? '' : ' data-dnt="$twitterTailoring"'}>'
        '<a href="$tweetURL"></a>'
        '</blockquote>'
        '<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>';
  }

  @override
  Map toJson() => _$TweetTwitterWebViewPropertiesToJson(this);

  /// Creates a new [TweetTwitterWebViewProperties] instance from a [json] map.
  factory TweetTwitterWebViewProperties.fromJson(Map json) =>
      _$TweetTwitterWebViewPropertiesFromJson(json);

  @override
  List<Object?> get props =>
      [tweetURL, hideConversation, theme, twitterTailoring, languageCode];

  /// Copies this [TweetTwitterWebViewProperties] instance into a new instance
  /// with optionally changed parameters.
  TweetTwitterWebViewProperties copyWith({
    String? tweetURL,
    bool? hideConversation,
    TwitterEmbedTheme? theme,
    bool? twitterTailoring,
    String? languageCode,
  }) {
    return TweetTwitterWebViewProperties(
      tweetURL: tweetURL ?? this.tweetURL,
      hideConversation: hideConversation ?? this.hideConversation,
      theme: theme ?? this.theme,
      twitterTailoring: twitterTailoring ?? this.twitterTailoring,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

/// Implements the Twitter Timeline embed.
@JsonSerializable()
class TimelineTwitterWebViewProperties extends TwitterWebViewProperties {
  /// The URL of the timeline to be displayed.
  String timelineURL;

  /// The width of the timeline in pixels.
  double? width;

  /// The height of the timeline in pixels.
  double? height;

  @override
  late TwitterEmbedType embedType = TwitterEmbedType.timeline;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String label = 'Twitter - Timeline';

  /// Creates a new [TimelineTwitterWebViewProperties] instance given a
  /// [timelineURL].
  TimelineTwitterWebViewProperties({
    required this.timelineURL,
    this.width,
    this.height,
    super.theme,
    super.twitterTailoring,
    super.languageCode,

    // inherited
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
    src = '<a class="twitter-timeline"'
        '${languageCode == null ? '' : ' data-lang="$languageCode"'}'
        '${theme == null ? '' : ' data-theme="${theme!.name}"'}'
        '${width == null ? '' : ' data-width="${width! * 2}"'}'
        '${height == null ? '' : ' data-height="${height! * 2}"'}'
        '${twitterTailoring == null ? '' : ' data-dnt="$twitterTailoring"'}'
        ' href="$timelineURL"></a>'
        '<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>';
  }

  @override
  Map toJson() => _$TimelineTwitterWebViewPropertiesToJson(this);

  /// Creates a new [TimelineTwitterWebViewProperties] instance from a [json]
  /// map.
  factory TimelineTwitterWebViewProperties.fromJson(Map json) =>
      _$TimelineTwitterWebViewPropertiesFromJson(json);

  @override
  List<Object?> get props =>
      [timelineURL, width, height, theme, twitterTailoring, languageCode];

  /// Copies this [TimelineTwitterWebViewProperties] instance into a new
  /// instance with optionally changed parameters.
  TimelineTwitterWebViewProperties copyWith({
    String? timelineURL,
    double? width,
    double? height,
    TwitterEmbedTheme? theme,
    bool? twitterTailoring,
    String? languageCode,
  }) {
    return TimelineTwitterWebViewProperties(
      timelineURL: timelineURL ?? this.timelineURL,
      width: width ?? this.width,
      height: height ?? this.height,
      theme: theme ?? this.theme,
      twitterTailoring: twitterTailoring ?? this.twitterTailoring,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

/// Implements the Twitter Follow button embed.
@JsonSerializable()
class FollowButtonTwitterWebViewProperties extends TwitterWebViewProperties {
  /// The handle of the user to follow.
  String handle;

  /// Whether to hide the username from the rendered button element.
  bool? hideUsername;

  /// Whether to create a large-form button instead of the standard one.
  bool? largeButton;

  @override
  late TwitterEmbedType embedType = TwitterEmbedType.follow;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String label = 'Twitter - Follow Button';

  /// Creates a new [FollowButtonTwitterWebViewProperties] instance given a
  /// [handle].
  FollowButtonTwitterWebViewProperties({
    required this.handle,
    this.hideUsername,
    this.largeButton,
    super.theme,
    super.twitterTailoring,
    super.languageCode,

    // inherited
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
    final String href = handle.startsWith('https')
        ? handle
        : 'https://twitter.com/intent/tweet?screen_name=${handle.startsWith('@') ? handle.substring(1) : handle}';

    src = '<a class="twitter-follow-button"'
        '${languageCode == null ? '' : ' data-lang="$languageCode"'}'
        '${theme == null ? '' : ' data-theme="${theme!.name}"'}'
        '${largeButton == null ? '' : ' data-size="$largeButton"'}'
        '${hideUsername == null ? '' : ' data-show-screen-name="$hideUsername"'}'
        '${twitterTailoring == null ? '' : ' data-dnt="$twitterTailoring"'}'
        ' href="$href"></a>'
        '<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>';
  }

  @override
  Map toJson() => _$FollowButtonTwitterWebViewPropertiesToJson(this);

  /// Creates a new [FollowButtonTwitterWebViewProperties] instance from a
  /// [json] map.
  factory FollowButtonTwitterWebViewProperties.fromJson(Map json) =>
      _$FollowButtonTwitterWebViewPropertiesFromJson(json);

  @override
  List<Object?> get props => [
        handle,
        hideUsername,
        largeButton,
        theme,
        twitterTailoring,
        languageCode
      ];

  /// Copies this [FollowButtonTwitterWebViewProperties] instance into a new
  /// instance with optionally changed parameters.
  FollowButtonTwitterWebViewProperties copyWith({
    String? handle,
    bool? hideUsername,
    bool? largeButton,
    TwitterEmbedTheme? theme,
    bool? twitterTailoring,
    String? languageCode,
  }) {
    return FollowButtonTwitterWebViewProperties(
      handle: handle ?? this.handle,
      hideUsername: hideUsername ?? this.hideUsername,
      largeButton: largeButton ?? this.largeButton,
      theme: theme ?? this.theme,
      twitterTailoring: twitterTailoring ?? this.twitterTailoring,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

/// Implements the Twitter Mention button embed.
@JsonSerializable()
class MentionButtonTwitterWebViewProperties extends TwitterWebViewProperties {
  /// The handle of the user to mention.
  String handle;

  /// Whether to create a large-form button instead of the standard one.
  bool? largeButton;

  /// The text to include in the tweet, loaded instantly and prefilled, ready
  /// to be edited by the user.
  String? prefilledText;

  /// Additional recommended Twitter accounts to suggest to the user.
  List<String>? recommendedAccounts;

  @override
  late TwitterEmbedType embedType = TwitterEmbedType.mention;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String label = 'Twitter - Mention Button';

  /// Creates a new [MentionButtonTwitterWebViewProperties] instance given a
  /// [handle].
  MentionButtonTwitterWebViewProperties({
    required this.handle,
    this.largeButton,
    this.prefilledText,
    this.recommendedAccounts,
    super.theme,
    super.twitterTailoring,
    super.languageCode,

    // inherited
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
    assert(
      recommendedAccounts == null ||
          (recommendedAccounts!.length <= 2 &&
              recommendedAccounts!.every((tag) => tag.trim().startsWith('@'))),
      'recommendedAccounts must be null or a list of 2 or less handles that start with @',
    );

    regenSource();
  }

  @override
  void regenSource() {
    final String href = handle.startsWith('https')
        ? handle
        : 'https://twitter.com/intent/tweet?screen_name=${handle.startsWith('@') ? handle.substring(1) : handle}';

    src = '<a class="twitter-mention-button"'
        '${languageCode == null ? '' : 'data-lang="$languageCode"'}'
        '${theme == null ? '' : ' data-theme="${theme!.name}"'}'
        '${twitterTailoring == null ? '' : 'data-dnt="$twitterTailoring"'}'
        '${largeButton == null ? '' : ' data-size="$largeButton"'}'
        '${prefilledText == null ? '' : ' data-text="$prefilledText"'}'
        '${recommendedAccounts == null ? '' : ' data-related="${recommendedAccounts!.join(',')}"'}'
        ' href="$href"></a>'
        '<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>';
  }

  @override
  Map toJson() => _$MentionButtonTwitterWebViewPropertiesToJson(this);

  /// Creates a new [MentionButtonTwitterWebViewProperties] instance from a
  /// [json] map.
  factory MentionButtonTwitterWebViewProperties.fromJson(Map json) =>
      _$MentionButtonTwitterWebViewPropertiesFromJson(json);

  @override
  List<Object?> get props => [
        handle,
        largeButton,
        prefilledText,
        recommendedAccounts,
        theme,
        twitterTailoring,
        languageCode
      ];

  /// Copies this [MentionButtonTwitterWebViewProperties] instance into a new
  /// instance with optionally changed parameters.
  MentionButtonTwitterWebViewProperties copyWith({
    String? handle,
    bool? largeButton,
    String? prefilledText,
    List<String>? recommendedAccounts,
    TwitterEmbedTheme? theme,
    bool? twitterTailoring,
    String? languageCode,
  }) {
    return MentionButtonTwitterWebViewProperties(
      handle: handle ?? this.handle,
      largeButton: largeButton ?? this.largeButton,
      prefilledText: prefilledText ?? this.prefilledText,
      recommendedAccounts: recommendedAccounts ?? this.recommendedAccounts,
      theme: theme ?? this.theme,
      twitterTailoring: twitterTailoring ?? this.twitterTailoring,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

/// Implements the Twitter Hashtag button embed.
@JsonSerializable()
class HashtagButtonTwitterWebViewProperties extends TwitterWebViewProperties {
  /// The hashtag to search for.
  String hashtag;

  /// Whether to create a large-form button instead of the standard one.
  bool? largeButton;

  /// The text to include in the tweet, loaded instantly and prefilled, ready
  /// to be edited by the user.
  String? prefilledText;

  /// Additional recommended Twitter accounts to suggest to the user.
  List<String>? recommendedAccounts;

  /// Optional specific URL to associate with the tweet.
  String? specificURLInTweet;

  @override
  late TwitterEmbedType embedType = TwitterEmbedType.hashtag;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String label = 'Twitter - Hashtag Button';

  /// Creates a new [HashtagButtonTwitterWebViewProperties] instance given a
  /// [hashtag].
  HashtagButtonTwitterWebViewProperties({
    required this.hashtag,
    this.largeButton,
    this.prefilledText,
    this.recommendedAccounts,
    this.specificURLInTweet,
    super.theme,
    super.twitterTailoring,
    super.languageCode,

    // inherited
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
    assert(
      recommendedAccounts == null ||
          (recommendedAccounts!.length <= 2 &&
              recommendedAccounts!.every((tag) => tag.trim().startsWith('@'))),
      'recommendedAccounts must be null or a list of 2 or less handles that start with @',
    );
    assert(
      specificURLInTweet == null || specificURLInTweet!.startsWith('https'),
      'specificURLInTweet must be null or a valid URL that starts with https',
    );
    regenSource();
  }

  @override
  void regenSource() {
    final String href = hashtag.startsWith('https')
        ? hashtag
        : 'https://twitter.com/intent/tweet?button_hashtag=${hashtag.startsWith('#') ? hashtag.substring(1) : hashtag}';

    src = '<a class="twitter-hashtag-button"'
        '${languageCode == null ? '' : ' data-lang="$languageCode"'}'
        '${theme == null ? '' : ' data-theme="${theme!.name}"'}'
        '${largeButton == null ? '' : ' data-size="$largeButton"'}'
        '${twitterTailoring == null ? '' : 'data-dnt="$twitterTailoring"'}'
        '${prefilledText == null ? '' : ' data-text="$prefilledText"'}'
        '${recommendedAccounts == null ? '' : ' data-related="${recommendedAccounts!.join(',')}"'}'
        '${specificURLInTweet == null ? '' : ' data-url="$specificURLInTweet"'}'
        ' href="$href"></a>'
        '<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>';
  }

  @override
  Map toJson() => _$HashtagButtonTwitterWebViewPropertiesToJson(this);

  /// Creates a new [HashtagButtonTwitterWebViewProperties] instance from a
  /// [json] map.
  factory HashtagButtonTwitterWebViewProperties.fromJson(Map json) =>
      _$HashtagButtonTwitterWebViewPropertiesFromJson(json);

  @override
  List<Object?> get props => [
        hashtag,
        largeButton,
        prefilledText,
        recommendedAccounts,
        specificURLInTweet,
        theme,
        twitterTailoring,
        languageCode
      ];

  /// Copies this [HashtagButtonTwitterWebViewProperties] instance into a new
  /// instance with optionally changed parameters.
  HashtagButtonTwitterWebViewProperties copyWith({
    String? hashtag,
    bool? largeButton,
    String? prefilledText,
    List<String>? recommendedAccounts,
    String? specificURLInTweet,
    TwitterEmbedTheme? theme,
    bool? twitterTailoring,
    String? languageCode,
  }) {
    return HashtagButtonTwitterWebViewProperties(
      hashtag: hashtag ?? this.hashtag,
      largeButton: largeButton ?? this.largeButton,
      prefilledText: prefilledText ?? this.prefilledText,
      recommendedAccounts: recommendedAccounts ?? this.recommendedAccounts,
      specificURLInTweet: specificURLInTweet ?? this.specificURLInTweet,
      theme: theme ?? this.theme,
      twitterTailoring: twitterTailoring ?? this.twitterTailoring,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
