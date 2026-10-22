import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'theme_tokens.g.dart';

/// A project's theme: the colors, fonts and corner radii the runtime uses
/// for what it draws itself (confirm dialogs, toasts, the Show more button),
/// published with each layout. Defined in the editor as the project's
/// styles named after each token (a color style "Primary", a text style
/// "Body", ...).
@JsonSerializable()
class ThemeTokens with Equatable, SerializableMixin {
  /// Primary buttons and info toasts.
  final ColorRGBA? primary;

  /// Text on [primary].
  final ColorRGBA? onPrimary;

  /// Dialog backgrounds.
  final ColorRGBA? surface;

  /// Text on [surface].
  final ColorRGBA? onSurface;

  /// Destructive buttons and error toasts.
  final ColorRGBA? error;

  /// Success toasts.
  final ColorRGBA? success;

  /// Warning toasts.
  final ColorRGBA? warning;

  /// Font family of body text and buttons.
  final String? fontFamily;

  /// Font family of titles.
  final String? titleFontFamily;

  /// Corner radius of dialogs.
  final double? radius;

  /// Corner radius of buttons.
  final double? buttonRadius;

  /// Creates [ThemeTokens].
  const ThemeTokens({
    this.primary,
    this.onPrimary,
    this.surface,
    this.onSurface,
    this.error,
    this.success,
    this.warning,
    this.fontFamily,
    this.titleFontFamily,
    this.radius,
    this.buttonRadius,
  });

  /// Whether no token is set.
  bool get isEmpty => props.every((value) => value == null);

  @override
  List<Object?> get props => [
    primary,
    onPrimary,
    surface,
    onSurface,
    error,
    success,
    warning,
    fontFamily,
    titleFontFamily,
    radius,
    buttonRadius,
  ];

  /// Creates [ThemeTokens] from JSON.
  factory ThemeTokens.fromJson(Map json) => _$ThemeTokensFromJson(json);

  @override
  Map toJson() => _$ThemeTokensOmitDefaults(this, _$ThemeTokensToJson(this));
}
