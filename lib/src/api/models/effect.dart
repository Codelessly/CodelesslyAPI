// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'effect.g.dart';

/// Type of effect.
enum EffectType {
  /// A drop shadow effect applied inwards.
  innerShadow,

  /// A drop shadow effect applied outwards.
  dropShadow,

  /// Blurs out the layer itself.
  layerBlur,

  /// Blurs out layer's background.
  backgroundBlur;
}

/// Represents shadow property.
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

/// A visual effect such as a shadow or blur.
@JsonSerializable()
class Effect with EquatableMixin, SerializableMixin {
  /// Unique identifier of the effect.
  final String id;

  /// Type of effect.
  final EffectType type;

  /// Whether the affect is visible.
  final bool visible;

  /// Radius of the effect.
  final double radius;

  /// The shadow spread, before blur is applied.
  final double? spread;

  /// The color of the shadow.
  final ColorRGBA? color;

  /// Blend mode of the shadow.
  @JsonKey(unknownEnumValue: BlendModeC.srcOver)
  final BlendModeC? blendMode;

  /// How far the shadow is projected in the x and y directions.
  final Vec? offset;

  /// Creates new [Effect] with given data.
  Effect({
    required this.id,
    required this.type,
    required this.radius,
    this.visible = true,
    this.color,
    this.blendMode,
    this.offset,
    this.spread,
  });

  /// Creates a new [Effect] with drop shadow.
  Effect.dropShadow({
    required this.id,
    this.type = EffectType.dropShadow,
    required this.radius,
    this.visible = true,
    required this.color,
    required this.offset,
    required this.spread,
    this.blendMode,
  });

  /// Creates a new [Effect] with inner shadow.
  Effect.innerShadow({
    required this.id,
    this.type = EffectType.innerShadow,
    required this.radius,
    this.visible = true,
    required this.color,
    required this.offset,
    required this.spread,
    this.blendMode,
  });

  /// Creates a new [Effect] with layer blur.
  Effect.layerBlur({
    required this.id,
    this.type = EffectType.layerBlur,
    required this.radius,
    this.visible = true,
    this.color,
    this.blendMode,
    this.offset,
    this.spread,
  });

  /// Creates a new [Effect] with background blur.
  Effect.backgroundBlur({
    required this.id,
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
        id: id,
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
        id,
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
