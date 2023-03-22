// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Represents the Twitter embedded webview color theme.
enum TwitterEmbedTheme {
  /// Light theme.
  light('Light'),

  /// Dark theme.
  dark('Dark');

  /// The string representation of the theme.
  final String label;

  /// Default constructor for this enum.
  const TwitterEmbedTheme(this.label);
}

/// Represents the type of the twitter embed URL.
enum TwitterEmbedType {
  /// A timeline url.
  timeline('Timeline'),

  /// A tweet url.
  tweet('Tweet'),

  /// A mention url.
  mention('Mention'),

  /// A hashtag url.
  hashtag('Hashtag'),

  /// A follow url.
  follow('Follow');

  /// The string representation of the type.
  final String label;

  /// Default constructor for this enum.
  const TwitterEmbedType(this.label);
}
