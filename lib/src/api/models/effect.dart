import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../field_access.dart';
import '../generate_id.dart';
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

/// Generates a random id if the given [json] does not contain a value for the
/// given [key]. Required for backwards compatibility.
Object? _readId(Map json, String key) => json[key] ?? generateId();

/// A visual effect such as a shadow or blur.
@JsonSerializable()
class Effect with EquatableMixin, SerializableMixin, FieldsHolder {
  @JsonKey(readValue: _readId)

  /// Unique identifier of the effect.
  final String id;

  /// Type of effect.
  EffectType type;

  /// Whether the affect is visible.
  bool visible;

  /// Radius of the effect.
  double radius;

  /// The shadow spread, before blur is applied.
  double? spread;

  /// The color of the shadow.
  ColorRGBA? color;

  /// Blend mode of the shadow.
  @JsonKey(unknownEnumValue: BlendModeC.srcOver)
  BlendModeC? blendMode;

  /// How far the shadow is projected in the x and y directions.
  Vec? offset;

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
    String? id,
    EffectType? type,
    double? radius,
    bool? visible,
    ColorRGBA? color,
    Vec? offset,
    double? spread,
    BlendModeC? blendMode,
  }) =>
      Effect(
        id: id ?? this.id,
        type: type ?? this.type,
        radius: radius ?? this.radius,
        visible: visible ?? this.visible,
        color: color ?? this.color,
        offset: offset ?? this.offset,
        spread: spread ?? this.spread,
        blendMode: blendMode ?? this.blendMode,
      );

  /// [Effect] can store all types of effects at the same time to allow
  /// switching between different effect types. However, this is not the desired
  /// behavior when applying a effect to another node. This method returns a
  /// sanitized version of this effect model that only contains the data relevant
  /// to the current effect type.
  ///
  /// Resembles [PaintModel.sanitize]. There are no properties to be sanitized
  /// for [Effect] at the moment.
  Effect sanitize({bool changeIds = false}) {
    switch (type) {
      case EffectType.dropShadow:
        return copyWith(id: changeIds ? generateId() : id);
      case EffectType.innerShadow:
        return copyWith(id: changeIds ? generateId() : id);
      case EffectType.layerBlur:
        return copyWith(id: changeIds ? generateId() : id);
      case EffectType.backgroundBlur:
        return copyWith(id: changeIds ? generateId() : id);
    }
  }

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'color': ColorFieldAccess<ColorRGBA?>(
          'Color',
          'The color of the effect.',
          () => color,
          (value) => color = value,
        ),
        'offsetX': NumFieldAccess<double?>(
          'Offset X',
          'How far the shadow is projected in the x and y directions.',
          () => offset?.x,
          (value) => offset = Vec(value ?? 0, offset?.y ?? 0),
        ),
        'offsetY': NumFieldAccess<double?>(
          'Offset Y',
          'How far the shadow is projected in the x and y directions.',
          () => offset?.y,
          (value) => offset = Vec(offset?.x ?? 0, value ?? 0),
        ),
        'spread': NumFieldAccess<double?>(
          'Spread',
          'The shadow spread, before blur is applied.',
          () => spread,
          (value) => spread = value,
        ),
        'radius': NumFieldAccess<double>(
          'Radius',
          'Radius of the effect.',
          () => radius,
          (value) => radius = value,
          min: 0,
        ),
      };

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
  factory Effect.fromJson(Map json) => _$EffectFromJson({
        // TODO: backward compatibility, remove in 1.0.0
        'id': generateId(),
        ...json,
      });

  @override
  Map toJson() => _$EffectToJson(this);
}
