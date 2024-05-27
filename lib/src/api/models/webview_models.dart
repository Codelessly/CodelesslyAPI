/// Type of source for a webview.
enum WebViewWebpageSourceType {
  /// A URL address of some website.
  url('URL link'),

  /// HTML content.
  html('HTML code'),

  /// A local file from assets. Usually an HTML file.
  asset('Asset path');

  /// String representation of the source type.
  final String label;

  /// Default constructor for this enum.
  const WebViewWebpageSourceType(this.label);
}

/// Different types of supported webviews.
enum WebViewType {
  /// A webpage.
  webpage('Webpage'),

  /// Google maps view.
  googleMaps('Google Maps'),

  /// Twitter view.
  twitter('Twitter');

  /// String representation of the webview type.
  final String label;

  /// Default constructor for this enum.
  const WebViewType(this.label);
}

/// Defines media playback policy for a webview.
enum WebViewMediaAutoPlaybackPolicy {
  /// Initiate media playback only on user interaction.
  requireUserActionForAllMedia('Never autoplay any media'),

  /// Initiate media playback automatically.
  alwaysPlayAllMedia('Always autoplay all media');

  /// String representation of the media playback policy.
  final String label;

  /// Default constructor for this enum.
  const WebViewMediaAutoPlaybackPolicy(this.label);
}
