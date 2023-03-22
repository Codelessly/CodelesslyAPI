// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';

part 'icon_model.g.dart';

/// Base class for holding data for a font based icon.
abstract class IconModel with EquatableMixin, SerializableMixin {
  /// codepoint that represents the icon in the fonts.
  final int codepoint;

  /// Name of the font family that contains the icon.
  final String fontFamily;

  /// Name/Label of the icon.
  final String name;

  /// Type of the icon. This is used to determine sub classes of this class
  /// for deserialization.
  abstract final String type;

  /// The name of the flutter/dart package that provides this font icons if any.
  final String? fontPackage = null;

  /// Creates an icon model with the given data.
  const IconModel({
    required this.codepoint,
    required this.fontFamily,
    required this.name,
  });

  /// Factory constructor for creating a new [IconModel] instance from
  /// JSON data.
  factory IconModel.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'MATERIAL_ICON':
        return MaterialIcon.fromJson(json);
      case 'MATERIAL_SYMBOL':
        return MaterialSymbol.fromJson(json);
      case 'CUPERTINO_ICON':
        return CupertinoIcon.fromJson(json);
    }
    throw UnimplementedError('Unknown icon type');
  }
}

/// Represents different styles for material icons.
enum MaterialIconStyle {
  /// Icons with no fill but outlines.
  outlined('Outlined'),

  /// Icons with fill.
  filled('Filled'),

  /// Icons with rounded corners.
  rounded('Rounded'),

  /// Icons with sharp corners.
  sharp('Sharp'),

  /// This is not supported by flutter out of the box.
  twoTone('Two Tone');

  /// Default constructor for this enum.
  const MaterialIconStyle(this.label);

  /// Factory constructor for creating a new [MaterialIconStyle] instance
  /// from icon category name. Here name refers to [Enum.name].
  factory MaterialIconStyle.fromName(String name) {
    return MaterialIconStyle.values
        .firstWhere((element) => element.name.contains(name));
  }

  /// Displayable string representation of this enum.
  final String label;
}

/// Represents different styles for material symbol.
enum MaterialSymbolStyle {
  /// Icons with no fill but outlines.
  outlined('Outlined'),

  /// Icons with rounded corners.
  rounded('Rounded'),

  /// Icons with sharp corners.
  sharp('Sharp');

  /// Default constructor for this enum.
  const MaterialSymbolStyle(this.label);

  /// Displayable string representation of this enum.
  final String label;
}

/// An icon model that represents a material icon.
@JsonSerializable()
class MaterialIcon extends IconModel {
  /// Style of this material icon.
  final MaterialIconStyle style;

  /// Supported styles for this material icon.
  final List<MaterialIconStyle> supportedStyles;

  @override
  final String type = 'MATERIAL_ICON';

  /// Create a new [MaterialIcon] with given data.
  const MaterialIcon({
    required super.codepoint,
    super.fontFamily = 'MaterialIcons',
    required super.name,
    required this.style,
    required this.supportedStyles,
  });

  /// Duplicates this instance of [MaterialIcon] with given data overrides.
  MaterialIcon copyWith({
    int? codepoint,
    String? name,
    MaterialIconStyle? style,
    List<MaterialIconStyle>? supportedStyles,
  }) =>
      MaterialIcon(
        codepoint: codepoint ?? this.codepoint,
        name: name ?? this.name,
        style: style ?? this.style,
        supportedStyles: supportedStyles ?? this.supportedStyles,
      );

  /// Factory constructor for creating a new [MaterialIcon] instance from
  /// JSON data.
  factory MaterialIcon.fromJson(Map<String, dynamic> json) =>
      _$MaterialIconFromJson(json);

  @override
  List<Object?> get props => [
        codepoint,
        fontFamily,
        name,
        style,
        supportedStyles,
      ];

  @override
  Map toJson() => _$MaterialIconToJson(this)..['type'] = type;
}

/// An icon model that represents a material symbol.
@JsonSerializable()
class MaterialSymbol extends IconModel {
  /// Style of this material symbol.
  final MaterialSymbolStyle style;

  @override
  final String type = 'MATERIAL_SYMBOL';

  /// Creates a new [MaterialSymbol] with given data.
  MaterialSymbol({
    required super.codepoint,
    required super.fontFamily,
    required super.name,
    required this.style,
  });

  /// Duplicates this instance of [MaterialSymbol] with given data override.
  MaterialSymbol copyWith({
    int? codepoint,
    String? name,
    String? fontFamily,
    MaterialSymbolStyle? style,
    List<MaterialSymbolStyle>? supportedStyles,
    List<String>? tags,
    int? version,
    int? popularity,
  }) =>
      MaterialSymbol(
        codepoint: codepoint ?? this.codepoint,
        fontFamily: fontFamily ?? this.fontFamily,
        name: name ?? this.name,
        style: style ?? this.style,
      );

  /// Factory constructor for creating a new [MaterialSymbol] instance from
  /// JSON data.
  factory MaterialSymbol.fromJson(Map<String, dynamic> json) =>
      _$MaterialSymbolFromJson(json);

  @override
  List<Object?> get props => [codepoint, fontFamily, name, style];

  @override
  Map toJson() => _$MaterialSymbolToJson(this)..['type'] = type;
}

/// An icon model that represents a cupertino icon.
@JsonSerializable()
class CupertinoIcon extends IconModel {
  @override
  final String fontPackage = 'cupertino_icons';

  @override
  final String type = 'CUPERTINO_ICON';

  /// Create a new [CupertinoIcon] with given data.
  CupertinoIcon({
    required super.codepoint,
    super.fontFamily = 'CupertinoIcons',
    required super.name,
  });

  /// Duplicates this instance of [CupertinoIcon] with given data override.
  CupertinoIcon copyWith({
    int? codepoint,
    String? name,
    String? fontFamily,
  }) =>
      CupertinoIcon(
        codepoint: codepoint ?? this.codepoint,
        fontFamily: fontFamily ?? this.fontFamily,
        name: name ?? this.name,
      );

  @override
  List<Object?> get props => [codepoint, fontFamily, name];

  /// Factory constructor for creating a new [CupertinoIcon] instance from
  /// JSON data.
  factory CupertinoIcon.fromJson(Map<String, dynamic> json) =>
      _$CupertinoIconFromJson(json);

  @override
  Map toJson() => _$CupertinoIconToJson(this)..['type'] = type;
}
