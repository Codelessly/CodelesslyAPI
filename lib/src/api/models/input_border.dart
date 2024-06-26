import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';
import 'border_side.dart';
import 'corner_radius.dart';

part 'input_border.g.dart';

/// Represents the type of input border.
enum BorderTypeEnum {
  /// No border.
  none,

  /// Border around the input field.
  outline,

  /// Border under the input field.
  underline;

  /// A convenience getter to check if this border type is outline.
  bool get isOutline => this == BorderTypeEnum.outline;

  /// A convenience getter to check if this border type is underline.
  bool get isUnderline => this == BorderTypeEnum.underline;

  /// A convenience getter to check if this border type is none.
  bool get isNone => this == BorderTypeEnum.none;
}

/// Represents decoration for an input border.
@JsonSerializable()
class InputBorderModel with EquatableMixin, SerializableMixin {
  /// The type of input border.
  final BorderTypeEnum borderType;

  /// Border side decoration data for the input border.
  final BorderSideModel borderSide;

  /// Border radius for input border.
  final CornerRadius cornerRadius;

  /// Horizontal padding on either side of the border's
  /// [InputDecoration.labelText] width gap.
  final double gapPadding;

  /// A convenience getter to check if this border is outline.
  bool get isOutline => borderType.isOutline;

  /// A convenience getter to check if this border is underline.
  bool get isUnderline => borderType.isUnderline;

  /// A convenience getter to check if this border is none.
  bool get isNone => borderType.isNone;

  /// Creates an instance of input border model.
  const InputBorderModel({
    this.borderType = BorderTypeEnum.outline,
    this.borderSide = const BorderSideModel(),
    this.cornerRadius = const CornerRadius.all(RadiusModel.circular(4)),
    this.gapPadding = 4,
  });

  /// Creates an instance of input border model with no border.
  factory InputBorderModel.none() => const InputBorderModel(
        borderType: BorderTypeEnum.none,
        borderSide: BorderSideModel(width: 0.0, style: BorderStyleEnum.none),
      );

  /// Creates an instance of input border model with outline border.
  factory InputBorderModel.outline({
    BorderSideModel borderSide = const BorderSideModel(),
    CornerRadius cornerRadius = const CornerRadius.all(RadiusModel.circular(4)),
    double gapPadding = 4,
  }) =>
      InputBorderModel(
        borderType: BorderTypeEnum.outline,
        borderSide: borderSide,
        cornerRadius: cornerRadius,
        gapPadding: gapPadding,
      );

  /// Creates an instance of input border model with underline border.
  factory InputBorderModel.underline({
    BorderSideModel borderSide = const BorderSideModel(),
    CornerRadius cornerRadius = const CornerRadius(
      tl: RadiusModel.circular(4),
      tr: RadiusModel.circular(4),
      bl: RadiusModel.circular(4),
      br: RadiusModel.circular(4),
    ),
  }) =>
      InputBorderModel(
        borderType: BorderTypeEnum.underline,
        borderSide: borderSide,
        cornerRadius: cornerRadius,
      );

  /// Duplicates this instance with the given data overrides.
  InputBorderModel copyWith({
    BorderTypeEnum? borderType,
    BorderSideModel? borderSide,
    CornerRadius? cornerRadius,
    double? gapPadding,
  }) =>
      InputBorderModel(
        borderType: borderType ?? this.borderType,
        borderSide: borderSide ?? this.borderSide,
        cornerRadius: cornerRadius ?? this.cornerRadius,
        gapPadding: gapPadding ?? this.gapPadding,
      );

  @override
  List<Object?> get props => [borderType, borderSide, cornerRadius, gapPadding];

  /// Factory constructor for creating a new [InputBorderModel] instance from
  /// JSON data.
  factory InputBorderModel.fromJson(Map json) =>
      _$InputBorderModelFromJson(json);

  @override
  Map toJson() => _$InputBorderModelToJson(this);
}
