// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Type of source for a webview.
enum WebviewWebpageSourceType {
  /// A URL address of some website.
  url('URL link'),

  /// HTML content.
  html('HTML code'),

  /// A local file from assets. Usually an HTML file.
  asset('Asset path');

  /// String representation of the source type.
  final String label;

  /// Default constructor for this enum.
  const WebviewWebpageSourceType(this.label);
}

/// Different types of supported webviews.
enum WebviewType {
  /// A webpage on the web.
  webpage('Webpage'),

  /// Google maps view.
  googleMaps('Google Maps'),

  /// Twitter view.
  twitter('Twitter');

  /// String representation of the webview type.
  final String label;

  /// Default constructor for this enum.
  const WebviewType(this.label);
}

/// Represents media playback policy for a webview.
enum WebviewMediaAutoPlaybackPolicy {
  /// Initiate media playback only on user interaction.
  requireUserActionForAllMedia('Never autoplay any media'),

  /// Initiate media playback automatically.
  alwaysPlayAllMedia('Always autoplay all media');

  /// String representation of the media playback policy.
  final String label;

  /// Default constructor for this enum.
  const WebviewMediaAutoPlaybackPolicy(this.label);
}
