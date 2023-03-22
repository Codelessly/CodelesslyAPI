// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'effect.g.dart';

/// Type of effect
enum EffectType {
  /// A drop shadow effect applied inwards.
  innerShadow,

  /// A drop shadow effect applied outwards.
  dropShadow,

  /// Blurs the layer itself.
  layerBlur,

  /// A background blur effect.
  backgroundBlur;
}

/// Represents a shadow property.
enum ShadowProperty {
  /// Offset on x-axis.
  offsetX,

  /// Offset on y-axis.
  offsetY,

  /// How far the shadow should spread.
  spread,

  /// Blur radius for the shadow.
  radius;
}

/// A visual effect such as a shadow or blur
@JsonSerializable()
class Effect with EquatableMixin, SerializableMixin {
  /// Type of effect as a string enum
  final EffectType type;

  /// Is the effect active?
  final bool visible;

  /// Radius of the blur effect (applies to shadows as well)
  final double radius;

  // The following properties are for shadows only:
  /// The shadow spread, before blur is applied
  final double? spread;

  /// The color of the shadow
  final ColorRGBA? color;

  /// Blend mode of the shadow
  @JsonKey(unknownEnumValue: BlendModeC.srcOver)
  final BlendModeC? blendMode;

  /// How far the shadow is projected in the x and y directions
  final Vec? offset;

  /// Creates new [Effect] with given data.
  const Effect({
    required this.type,
    required this.radius,
    this.visible = true,
    this.color,
    this.blendMode,
    this.offset,
    this.spread,
  });

  /// Creates a new [Effect] with drop shadow.
  const Effect.dropShadow({
    this.type = EffectType.dropShadow,
    required this.radius,
    this.visible = true,
    required this.color,
    required this.offset,
    required this.spread,
    this.blendMode,
  });

  /// Creates a new [Effect] with inner shadow.
  const Effect.innerShadow({
    this.type = EffectType.innerShadow,
    required this.radius,
    this.visible = true,
    required this.color,
    required this.offset,
    required this.spread,
    this.blendMode,
  });

  /// Creates a new [Effect] with layer blur.
  const Effect.layerBlur({
    this.type = EffectType.layerBlur,
    required this.radius,
    this.visible = true,
    this.color,
    this.blendMode,
    this.offset,
    this.spread,
  });

  /// Creates a new [Effect] with background blur.
  const Effect.backgroundBlur({
    this.type = EffectType.backgroundBlur,
    required this.radius,
    this.visible = true,
    this.color,
    this.blendMode,
    this.offset,
    this.spread,
  });

  /// Duplicates this instance with given data overrides.
  Effect copyWith({
    EffectType? type,
    double? radius,
    bool? visible,
    ColorRGBA? color,
    Vec? offset,
    double? spread,
    BlendModeC? blendMode,
  }) =>
      Effect(
        type: type ?? this.type,
        radius: radius ?? this.radius,
        visible: visible ?? this.visible,
        color: color ?? this.color,
        offset: offset ?? this.offset,
        spread: spread ?? this.spread,
        blendMode: blendMode ?? this.blendMode,
      );

  @override
  List<Object?> get props => [
        type,
        visible,
        blendMode,
        offset,
        spread,
        color,
        radius,
      ];

  /// Factory constructor for creating new [Effect] from JSON data.
  factory Effect.fromJson(Map json) => _$EffectFromJson(json);

  @override
  Map toJson() => _$EffectToJson(this);
}
