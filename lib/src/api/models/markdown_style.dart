import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'markdown_style.g.dart';

/// Renders a text's characters as Markdown: `**bold**`, `_italic_`,
/// `` `code` ``, links, `@mentions`, `- ` and `1. ` list items and blank-line
/// paragraphs. Set on a [TextNode] (`markdown`) for text from data such as
/// message bodies, and on a text field to style what's typed live.
///
/// Colors default to the text's own color where null.
@JsonSerializable()
class MarkdownStyle with Equatable, SerializableMixin {
  /// Inline code text color.
  final ColorRGBA? codeColor;

  /// Inline code background.
  final ColorRGBA? codeBackground;

  /// Inline code font family.
  final String codeFontFamily;

  /// Link color (links are underlined).
  final ColorRGBA? linkColor;

  /// `@mention` color.
  final ColorRGBA? mentionColor;

  /// `@mention` background.
  final ColorRGBA? mentionBackground;

  /// Handles that count as mentions, without `@`. Empty: any `@word`.
  final List<String> mentions;

  /// Bullet and list number color.
  final ColorRGBA? bulletColor;

  /// Extra space between paragraphs (blank lines), in pixels.
  final double paragraphGap;

  /// Keeps the markers (`**`, `_`, backticks, list markers) visible, dimmed
  /// to [markerColor]: the live preview of a text being typed.
  final bool showMarkers;

  /// Color of visible markers.
  final ColorRGBA? markerColor;

  /// Creates a [MarkdownStyle].
  const MarkdownStyle({
    this.codeColor,
    this.codeBackground,
    this.codeFontFamily = 'JetBrains Mono',
    this.linkColor,
    this.mentionColor,
    this.mentionBackground,
    this.mentions = const [],
    this.bulletColor,
    this.paragraphGap = 8,
    this.showMarkers = false,
    this.markerColor,
  });

  /// Duplicates this style with the given values replaced.
  MarkdownStyle copyWith({
    ColorRGBA? codeColor,
    ColorRGBA? codeBackground,
    String? codeFontFamily,
    ColorRGBA? linkColor,
    ColorRGBA? mentionColor,
    ColorRGBA? mentionBackground,
    List<String>? mentions,
    ColorRGBA? bulletColor,
    double? paragraphGap,
    bool? showMarkers,
    ColorRGBA? markerColor,
  }) => MarkdownStyle(
    codeColor: codeColor ?? this.codeColor,
    codeBackground: codeBackground ?? this.codeBackground,
    codeFontFamily: codeFontFamily ?? this.codeFontFamily,
    linkColor: linkColor ?? this.linkColor,
    mentionColor: mentionColor ?? this.mentionColor,
    mentionBackground: mentionBackground ?? this.mentionBackground,
    mentions: mentions ?? this.mentions,
    bulletColor: bulletColor ?? this.bulletColor,
    paragraphGap: paragraphGap ?? this.paragraphGap,
    showMarkers: showMarkers ?? this.showMarkers,
    markerColor: markerColor ?? this.markerColor,
  );

  /// Creates a [MarkdownStyle] from JSON. Colors may be `#RRGGBB` or
  /// `#AARRGGBB` text.
  factory MarkdownStyle.fromJson(Map json) => _$MarkdownStyleFromJson(json);

  @override
  Map toJson() =>
      _$MarkdownStyleOmitDefaults(this, _$MarkdownStyleToJson(this));

  @override
  List<Object?> get props => [
    codeColor,
    codeBackground,
    codeFontFamily,
    linkColor,
    mentionColor,
    mentionBackground,
    mentions,
    bulletColor,
    paragraphGap,
    showMarkers,
    markerColor,
  ];
}
