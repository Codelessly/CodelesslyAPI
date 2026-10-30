import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../codelessly_api.dart';
import '../../schema/flutter_prop.dart';

part 'ink_well.g.dart';

/// Represents properties that relate to the [InkWell] widget in Flutter.
@JsonSerializable()
class InkWellModel with Equatable, SerializableMixin {
  /// The overlay color. This is the dominant color field. If this is null, then
  /// the individual [highlightColor], [splashColor], [hoverColor], and
  /// [focusColor] values are used instead.
  @FlutterProp(
    'overlayColor',
    type: 'object',
    group: 'InkWell',
    control: 'color',
    field: 'inkWell.overlayColor',
    flutterParam: false,
    note: 'Nested InkWell styling, not a constructor parameter of the parent node widget.',
    a2ui: false,
  )
  final ColorRGBA? overlayColor;

  /// The highlight color.
  @FlutterProp(
    'highlightColor',
    type: 'object',
    group: 'InkWell',
    control: 'color',
    field: 'inkWell.highlightColor',
    flutterParam: false,
    note: 'Nested InkWell styling, not a constructor parameter of the parent node widget.',
    a2ui: false,
  )
  final ColorRGBA? highlightColor;

  /// The splash color.
  @FlutterProp(
    'splashColor',
    type: 'object',
    group: 'InkWell',
    control: 'color',
    field: 'inkWell.splashColor',
    flutterParam: false,
    note: 'Nested InkWell styling, not a constructor parameter of the parent node widget.',
    a2ui: false,
  )
  final ColorRGBA? splashColor;

  /// The hover color.
  @FlutterProp(
    'hoverColor',
    type: 'object',
    group: 'InkWell',
    control: 'color',
    field: 'inkWell.hoverColor',
    flutterParam: false,
    note: 'Nested InkWell styling, not a constructor parameter of the parent node widget.',
    a2ui: false,
  )
  final ColorRGBA? hoverColor;

  /// The focus color.
  @FlutterProp(
    'focusColor',
    type: 'object',
    group: 'InkWell',
    control: 'color',
    field: 'inkWell.focusColor',
    flutterParam: false,
    note: 'Nested InkWell styling, not a constructor parameter of the parent node widget.',
    a2ui: false,
  )
  final ColorRGBA? focusColor;

  /// Creates an [InkWellModel] instance with the given data.
  const InkWellModel({
    this.overlayColor,
    this.highlightColor,
    this.splashColor,
    this.hoverColor,
    this.focusColor,
  });

  /// Duplicates this instance of [InkWellModel] with given overlay color.
  InkWellModel copyWithOverlayColor(ColorRGBA? color) => InkWellModel(
    overlayColor: color,
    highlightColor: highlightColor,
    splashColor: splashColor,
    hoverColor: hoverColor,
    focusColor: focusColor,
  );

  /// Duplicates this instance of [InkWellModel] with given highlight color.
  InkWellModel copyWithHighlightColor(ColorRGBA? color) => InkWellModel(
    highlightColor: color,
    splashColor: splashColor,
    hoverColor: hoverColor,
    focusColor: focusColor,
  );

  /// Duplicates this instance of [InkWellModel] with given splash color.
  InkWellModel copyWithSplashColor(ColorRGBA? color) => InkWellModel(
    overlayColor: overlayColor,
    highlightColor: highlightColor,
    splashColor: color,
    hoverColor: hoverColor,
    focusColor: focusColor,
  );

  /// Duplicates this instance of [InkWellModel] with given hover color.
  InkWellModel copyWithHoverColor(ColorRGBA? color) => InkWellModel(
    overlayColor: overlayColor,
    highlightColor: highlightColor,
    splashColor: splashColor,
    hoverColor: color,
    focusColor: focusColor,
  );

  /// Duplicates this instance of [InkWellModel] with given focus color.
  InkWellModel copyWithFocusColor(ColorRGBA? color) => InkWellModel(
    overlayColor: overlayColor,
    highlightColor: highlightColor,
    splashColor: splashColor,
    hoverColor: hoverColor,
    focusColor: color,
  );

  /// Factory constructor for creating a new [InkWellModel] instance
  /// from JSON data.
  factory InkWellModel.fromJson(Map<String, dynamic> json) =>
      _$InkWellModelFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$InkWellModelOmitDefaults(this, _$InkWellModelToJson(this));

  @override
  List<Object?> get props => [
    overlayColor,
    highlightColor,
    splashColor,
    hoverColor,
    focusColor,
  ];
}
