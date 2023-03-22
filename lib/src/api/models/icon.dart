// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'icon.g.dart';

/// A model that represents an icon. The icon could be a standard font based
/// icon or an image of an icon. The type of this icon is determined by the
/// [type] property.
/// This model is designed to hold both properties of a font based icon and an
/// image icon.
@JsonSerializable()
class MultiSourceIconModel with EquatableMixin, SerializableMixin {
  /// having [iconData] and [iconImage] despite having an enum [iconType] to
  /// differentiate allows us to preserve user selection for both cases so
  /// when the user toggles the type, previous selection will still be there.
  final String? iconImage; // network image URL

  /// Holds information about the font based icon.
  final IconModel? icon;

  /// Color of the icon.
  final ColorRGBA? color;

  /// Type of the icon.
  final IconTypeEnum type;

  /// Size of the icon.
  final double? size;

  /// Whether to show the icon or not.
  final bool show;

  /// Name of the image icon file. This name is used as the file name if
  /// the image of the icon is put into assets.
  final String? imageName;

  /// Scale of the image icon.
  final double scale;

  /// Whether the type of this icon is image.
  bool get isImageIcon => type == IconTypeEnum.image;

  /// Whether this is a standard font based icon.
  bool get isStandardIcon => type == IconTypeEnum.icon;

  /// Can be used to check if this has any data or is just a placeholder.
  bool get isEmpty => iconImage == null && icon == null;

  /// Creates an instance of this class with standard font based icon.
  const MultiSourceIconModel.icon({
    this.icon,
    this.size = 24,
    this.color = ColorRGBA.black,
    this.show = true,
  })  : type = IconTypeEnum.icon,
        iconImage = null,
        scale = 1,
        imageName = null;

  /// Creates an instance of this class with image icon.
  const MultiSourceIconModel.image({
    this.iconImage,
    this.size = 24,
    this.color = const ColorRGBA(r: 0, g: 0, b: 0, a: 0),
    this.show = true,
    this.imageName,
    this.scale = 1,
  })  : type = IconTypeEnum.image,
        icon = null;

  /// Default constructor of this class.
  const MultiSourceIconModel({
    this.type = IconTypeEnum.icon,
    this.icon,
    this.iconImage,
    this.size = 24,
    this.color,
    this.show = false,
    this.imageName,
    this.scale = 1,
  });

  @override
  List<Object?> get props =>
      [type, icon, iconImage, size, color, show, imageName];

  /// Duplicates this instance with the given properties overrides.
  MultiSourceIconModel copyWith({
    String? iconImage,
    IconModel? icon,
    ColorRGBA? color,
    IconTypeEnum? type,
    double? size,
    double? scale,
    String? semanticLabel,
    bool? show,
    String? imageName,
    bool forceColor = false,
    bool forceIcon = false,
    bool forceSize = false,
    bool forceIconImage = false,
    bool forceImageName = false,
  }) {
    return MultiSourceIconModel(
      iconImage: forceIconImage ? iconImage : (iconImage ?? this.iconImage),
      icon: forceIcon ? icon : (icon ?? this.icon),
      color: forceColor ? color : (color ?? this.color),
      type: type ?? this.type,
      size: forceSize ? size : (size ?? this.size),
      show: show ?? this.show,
      scale: scale ?? this.scale,
      imageName: forceImageName ? imageName : (imageName ?? this.imageName),
    );
  }

  /// Duplicates the [other] instance with missing properties put from this
  /// instance.
  MultiSourceIconModel merge(MultiSourceIconModel? other) {
    if (other == null) return this;
    return MultiSourceIconModel(
      iconImage: other.iconImage ?? iconImage,
      icon: other.icon ?? icon,
      color: other.color ?? color,
      type: other.type,
      size: other.size,
      show: other.show,
      scale: other.scale,
      imageName: other.imageName ?? imageName,
    );
  }

  /// Factory constructor for creating a new [MultiSourceIconModel] instance
  /// from JSON data.
  factory MultiSourceIconModel.fromJson(Map json) =>
      _$MultiSourceIconModelFromJson(json);

  @override
  Map toJson() => _$MultiSourceIconModelToJson(this);
}
