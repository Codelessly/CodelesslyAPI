// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'dart:math';

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../codelessly_api.dart';

part 'paint.g.dart';

/// Describes how to paint any portions of the box that are not covered by the
/// image. Directly translates to Flutter's [ImageRepeat].
enum ImageRepeatEnum {
  /// Repeat the image in both the x and y directions until the box is filled.
  repeat('Repeat'),

  /// Repeat the image in the x direction until the box is filled horizontally.
  repeatX('Repeat Horizontally'),

  /// Repeat the image in the y direction until the box is filled vertically.
  repeatY('Repeat Vertically'),

  /// Leave uncovered portions of the box transparent.
  noRepeat('No Repeat');

  /// Default constructor for [ImageRepeatEnum].
  const ImageRepeatEnum(this.label);

  /// Displayable string representation of [ImageRepeatEnum].
  final String label;
}

/// Generates a random id if the given [json] does not contain a value for the
/// given [key]. Required for backwards compatibility.
Object? _readId(Map json, String key) => json[key] ?? generateId();

/// A solid color, gradient, or image texture that can be applied as fill or
/// stroke.
@JsonSerializable()
class PaintModel with EquatableMixin, SerializableMixin {
  /// identifier of this paint.
  @JsonKey(readValue: _readId)
  final String id;

  /// Type of paint.
  final PaintType type;

  /// Whether the paint is visible.
  final bool visible;

  /// Overall opacity of paint.
  /// Colors within the paint can also have opacity
  /// values which would blend with this.
  @JsonKey(toJson: roundDoubleToJson)
  final double opacity;

  // For solid paint:

  /// Solid color of the paint.
  /// This is used with [opacity] to generate Flutter's Color.
  /// This isn't a ColorRGBA because [opacity] is used in images or gradients.
  /// Having two opacity fields for a single color could be confusing.
  final ColorRGB? color;

  // For gradient paint:

  /// Describes how this node blends with nodes behind it in the scene.
  @JsonKey(unknownEnumValue: BlendModeC.srcOver)
  final BlendModeC blendMode;

  /// This field contains three vectors, each of which are a position in
  /// normalized object space (normalized object space is if the top left
  /// corner of the bounding box of the object is (0, 0) and the bottom right
  /// is (1,1)). The first position corresponds to the start of the gradient
  /// (value 0 for the purposes of calculating gradient stops), the second
  /// position is the end of the gradient (value 1), and the third handle
  /// position determines the width of the gradient. See image examples:
  ///
  /// ![linear example](https://www.figma.com/images/developer_app/linear.png)
  /// ![angular example](https://www.figma.com/images/developer_app/angular.png)
  /// ![diamond example](https://www.figma.com/images/developer_app/diamond.png)
  /// ![radial example](https://www.figma.com/images/developer_app/radial.png)
  // final List<Vector2D> gradientTransform;

  final List<num>? gradientTransform;

  /// Positions of key points along the gradient axis with the colors anchored
  /// there. Colors along the gradient are interpolated smoothly between
  /// neighboring gradient stops.
  final List<ColorStop>? gradientStops;

  // For image paint:

  /// Affine transform applied to the image.
  /// A transformation matrix is standard way in computer graphics to represent
  /// translation and rotation. These are the top two rows of a 3x3 matrix.
  /// The bottom row of the matrix is assumed to be [0, 0, 1].
  /// This is known as an affine transform and is enough to represent
  /// translation, rotation, and skew.
  ///
  /// The identity transform is [[1, 0, 0], [0, 1, 0]].
  final List<List<num>>? imageTransform;

  /// Memory bytes to load the image.
  /// If bytes not provided, use [downloadUrl] to retrieve the image.
  /// Bytes should never be sent to server, hence ignored for serialization.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool hasImageBytes;

  /// URL from which the image can be downloaded.
  final String? downloadUrl;

  /// File name for the image fill used when images are put into assets.
  final String? imageName;

  /// A reference to the GIF embedded in this node, if the image is a GIF.
  final String? imageHash;

  /// Marks this image paint model as coming from a specific asset from the
  /// asset library.
  final String? assetID;

  /// The sizing behavior the image will use to fit inside its view.
  /// This is 1-1 with Flutter's [BoxFit].
  final Fit fit;

  /// The alignment positioning of the image relative to its view.
  /// [-1, -1] being the top left corner of the view and [1, 1] being the bottom
  /// right corner of the view, and [0, 0] being the center of the view.
  ///
  /// This corresponds to Flutter's [Alignment].
  final AlignmentModel alignment;

  /// The image scale per-axis.
  final double scaleX, scaleY;

  /// Image scale.
  double get scale => min(scaleX, scaleY);

  /// Returns true if the rendered image is flipped horizontally by checking
  /// the sign of [scaleX]. Negative values indicate a flipped image.
  bool get isFlippedX => scaleX < 0;

  /// Returns true if the rendered image is flipped vertically by checking
  /// the sign of [scaleY]. Negative values indicate a flipped image.
  bool get isFlippedY => scaleY < 0;

  /// Returns true if the rendered image is flipped horizontally or vertically.
  bool get hasFlippedAxis => isFlippedX || isFlippedY;

  /// Returns true if the rendered image is scaled non-uniformly.
  /// IE: [scaleX] and [scaleY] are mismatched.
  bool get isNonUniformScale => scaleX.abs() != scaleY.abs();

  /// Stores information about the crop of an image.
  final CropData? cropData;

  /// URL of the cropped image.
  /// Not null if the image is cropped.
  final String? croppedImageURL;

  /// Width of the raw source image in pixels.
  /// Not null for [PaintModel.image].
  final double? sourceWidth;

  /// Height of the raw source image in pixels.
  /// Not null for [PaintModel.image].
  final double? sourceHeight;

  /// Tile mode for image fill.
  final ImageRepeatEnum imageRepeat;

  /// Whether image fill type has source size.
  bool get hasImageSourceSize => sourceWidth != null && sourceHeight != null;

  /// Helper constructor for when a black paint is needed, like tests.
  static PaintModel get blackPaint => PaintModel.solid(
        id: generateId(),
        visible: true,
        opacity: 1.0,
        color: ColorRGB.black,
      );

  /// Helper constructor for when a grey paint is needed, like tests.
  static PaintModel get greyPaint => PaintModel.solid(
        id: generateId(),
        visible: true,
        opacity: 1.0,
        color: ColorRGB.grey,
      );

  /// Helper constructor for when a white paint is needed, like tests.
  static PaintModel get whitePaint => PaintModel.solid(
        id: generateId(),
        visible: true,
        opacity: 1.0,
        color: ColorRGB.white,
      );

  /// Helper constructor for when a gradient paint is needed, like tests.
  static PaintModel get linearPaint => PaintModel(
        id: generateId(),
        type: PaintType.gradientLinear,
        visible: true,
        opacity: 1.0,
        gradientStops: const [
          ColorStop(color: ColorRGBA.black, position: 0.0),
          ColorStop(color: ColorRGBA.white, position: 1.0),
        ],
      );

  /// Create a Solid Paint with only the required properties.
  const PaintModel.solid({
    required this.id,
    this.visible = true,
    this.opacity = 1,
    required this.color,
    this.blendMode = BlendModeC.srcOver,
  })  : type = PaintType.solid,
        hasImageBytes = false,
        cropData = null,
        croppedImageURL = null,
        downloadUrl = null,
        imageHash = null,
        gradientTransform = null,
        gradientStops = null,
        imageTransform = null,
        imageName = null,
        fit = Fit.none,
        alignment = AlignmentModel.none,
        scaleX = 1,
        scaleY = 1,
        imageRepeat = ImageRepeatEnum.noRepeat,
        sourceWidth = null,
        sourceHeight = null,
        assetID = null;

  /// Create an Image Paint with only the required properties.
  const PaintModel.image({
    required this.id,
    required this.downloadUrl,
    required this.fit,
    this.visible = true,
    this.opacity = 1,
    this.blendMode = BlendModeC.srcOver,
    this.hasImageBytes = false,
    this.imageHash,
    this.imageTransform,
    this.scaleX = 1,
    this.scaleY = 1,
    this.alignment = AlignmentModel.center,
    this.cropData,
    this.croppedImageURL,
    this.imageRepeat = ImageRepeatEnum.noRepeat,
    this.imageName,
    required this.sourceWidth,
    required this.sourceHeight,
    this.assetID,
  })  : assert(sourceWidth != null && sourceHeight != null,
            'Images must always provide their original size.'),
        type = PaintType.image,
        gradientTransform = null,
        gradientStops = null,
        color = null;

  /// Creates [PaintModel] with linear gradient.
  const PaintModel.linearGradient({
    required this.id,
    this.visible = true,
    this.opacity = 1,
    this.gradientTransform,
    this.gradientStops,
    this.blendMode = BlendModeC.srcOver,
  })  : type = PaintType.gradientLinear,
        color = null,
        imageTransform = null,
        hasImageBytes = false,
        downloadUrl = null,
        imageHash = null,
        fit = Fit.none,
        imageName = null,
        alignment = AlignmentModel.none,
        scaleX = 1,
        scaleY = 1,
        cropData = null,
        imageRepeat = ImageRepeatEnum.noRepeat,
        croppedImageURL = null,
        sourceWidth = null,
        sourceHeight = null,
        assetID = null;

  /// Creates [PaintModel] with radial gradient.
  const PaintModel.radialGradient({
    required this.id,
    this.visible = true,
    this.opacity = 1,
    this.gradientTransform,
    this.gradientStops,
    this.blendMode = BlendModeC.srcOver,
  })  : type = PaintType.gradientRadial,
        color = null,
        imageTransform = null,
        hasImageBytes = false,
        downloadUrl = null,
        imageHash = null,
        fit = Fit.none,
        imageName = null,
        alignment = AlignmentModel.none,
        scaleX = 1,
        scaleY = 1,
        cropData = null,
        croppedImageURL = null,
        imageRepeat = ImageRepeatEnum.noRepeat,
        sourceWidth = null,
        sourceHeight = null,
        assetID = null;

  /// Creates [PaintModel] with angular gradient.
  const PaintModel.angularGradient({
    required this.id,
    this.visible = true,
    this.opacity = 1,
    this.gradientTransform,
    this.gradientStops,
    this.blendMode = BlendModeC.srcOver,
  })  : type = PaintType.gradientAngular,
        color = null,
        imageTransform = null,
        hasImageBytes = false,
        downloadUrl = null,
        imageHash = null,
        fit = Fit.none,
        imageName = null,
        imageRepeat = ImageRepeatEnum.noRepeat,
        alignment = AlignmentModel.none,
        scaleX = 1,
        scaleY = 1,
        cropData = null,
        croppedImageURL = null,
        sourceWidth = null,
        sourceHeight = null,
        assetID = null;

  /// Creates [PaintModel] with given data.
  const PaintModel({
    required this.id,
    required this.type,
    this.visible = true,
    this.opacity = 1,
    this.color,
    this.blendMode = BlendModeC.srcOver,
    this.gradientTransform,
    this.gradientStops,
    this.imageTransform,
    this.hasImageBytes = false,
    this.downloadUrl,
    this.imageHash,
    this.fit = Fit.none,
    this.alignment = AlignmentModel.none,
    this.scaleX = 1,
    this.scaleY = 1,
    this.cropData,
    this.croppedImageURL,
    this.imageName,
    this.sourceWidth,
    this.sourceHeight,
    this.assetID,
    this.imageRepeat = ImageRepeatEnum.noRepeat,
  });

  /// Duplicates this instance with given data overrides.
  PaintModel copyWith({
    PaintType? type,
    bool? visible,
    double? opacity,
    ColorRGB? color,
    BlendModeC? blendMode,
    List<num>? gradientTransform,
    List<ColorStop>? gradientStops,
    List<List<num>>? imageTransform,
    double? scalingFactor,
    String? downloadUrl,
    String? imageName,
    String? imageHash,
    String? assetID,
    Fit? fit,
    AlignmentModel? alignment,
    double? scaleX,
    double? scaleY,
    double? angle,
    bool? hasImageBytes,
    CropData? cropData,
    String? croppedImageURL,
    bool clearCropData = false,
    double? sourceWidth,
    double? sourceHeight,
    ImageRepeatEnum? imageRepeat,
    bool forceSourceSize = false,
  }) =>
      PaintModel(
        id: id,
        type: type ?? this.type,
        visible: visible ?? this.visible,
        opacity: opacity ?? this.opacity,
        color: color ?? this.color,
        blendMode: blendMode ?? this.blendMode,
        gradientTransform: gradientTransform ?? this.gradientTransform,
        gradientStops: gradientStops ?? this.gradientStops,
        imageTransform: imageTransform ?? this.imageTransform,
        hasImageBytes: hasImageBytes ?? this.hasImageBytes,
        downloadUrl: downloadUrl ?? this.downloadUrl,
        imageName: imageName ?? this.imageName,
        imageHash: imageHash ?? this.imageHash,
        fit: fit ?? this.fit,
        alignment: alignment ?? this.alignment,
        scaleX: scaleX ?? this.scaleX,
        scaleY: scaleY ?? this.scaleY,
        sourceWidth:
            forceSourceSize ? sourceWidth : sourceWidth ?? this.sourceWidth,
        sourceHeight:
            forceSourceSize ? sourceHeight : sourceHeight ?? this.sourceHeight,
        cropData: clearCropData ? null : cropData ?? this.cropData,
        croppedImageURL:
            clearCropData ? null : croppedImageURL ?? this.croppedImageURL,
        assetID: assetID ?? this.assetID,
        imageRepeat: imageRepeat ?? this.imageRepeat,
      );

  /// [PaintModel] can store all types of paints at the same time to allow
  /// switching between different paint types. However, this is not the desired
  /// behavior when applying a paint to another node. This method returns a
  /// sanitized version of this paint model that only contains the data relevant
  /// to the current paint type.
  PaintModel sanitize({bool changeIds = false}) {
    switch (type) {
      case PaintType.solid:
        return PaintModel.solid(
          id: changeIds ? generateId() : id,
          color: color,
          blendMode: blendMode,
          opacity: opacity,
          visible: visible,
        );
      case PaintType.gradientLinear:
      case PaintType.gradientRadial:
      case PaintType.gradientAngular:
      case PaintType.gradientDiamond:
        return PaintModel(
          id: changeIds ? generateId() : id,
          type: type,
          blendMode: blendMode,
          opacity: opacity,
          visible: visible,
          gradientStops: gradientStops,
          gradientTransform: gradientTransform,
        );
      case PaintType.image:
        return PaintModel.image(
          id: changeIds ? generateId() : id,
          downloadUrl: downloadUrl,
          fit: fit,
          sourceWidth: sourceWidth,
          sourceHeight: sourceHeight,
          visible: visible,
          opacity: opacity,
          blendMode: blendMode,
          alignment: alignment,
          scaleX: scaleX,
          scaleY: scaleY,
          cropData: cropData,
          croppedImageURL: croppedImageURL,
          hasImageBytes: hasImageBytes,
          imageHash: imageHash,
          imageName: imageName,
          imageRepeat: imageRepeat,
          imageTransform: imageTransform,
          assetID: assetID,
        );
      case PaintType.emoji:
        throw Exception('Paint type $type is not supported');
    }
  }

  /// [PaintModel]s differentiate themselves with an [id], so we
  /// need to manually compare the other fields.
  bool isEquivalentTo(PaintModel? other) {
    if (other == null) return false;
    if (type != other.type) return false;
    if (visible != other.visible) return false;
    if (opacity != other.opacity) return false;
    if (color != other.color) return false;
    if (blendMode != other.blendMode) return false;
    if (gradientTransform != other.gradientTransform) return false;
    if (gradientStops != other.gradientStops) return false;
    if (imageTransform != other.imageTransform) return false;
    if (hasImageBytes != other.hasImageBytes) return false;
    if (downloadUrl != other.downloadUrl) return false;
    if (imageName != other.imageName) return false;
    if (imageHash != other.imageHash) return false;
    if (fit != other.fit) return false;
    if (alignment != other.alignment) return false;
    if (scaleX != other.scaleX) return false;
    if (scaleY != other.scaleY) return false;
    if (imageRepeat != other.imageRepeat) return false;
    if (assetID != other.assetID) return false;
    if (sourceWidth != other.sourceWidth) return false;
    if (sourceHeight != other.sourceHeight) return false;
    if (cropData != other.cropData) return false;
    if (croppedImageURL != other.croppedImageURL) return false;
    return true;
  }

  @override
  List<Object?> get props => [
        id,
        type,
        visible,
        opacity,
        color,
        blendMode,
        gradientTransform,
        gradientStops,
        imageTransform,
        hasImageBytes,
        downloadUrl,
        imageName,
        imageHash,
        fit,
        alignment,
        scaleX,
        scaleY,
        imageRepeat,
        assetID,
        sourceWidth,
        sourceHeight,
        cropData,
        croppedImageURL,
      ];

  /// Factory constructor for creating [PaintModel] instance from a JSON data.
  factory PaintModel.fromJson(Map json) => _$PaintModelFromJson(json);

  @override
  Map toJson() => _$PaintModelToJson(this);
}

/// Holds the information required to crop an image.
@JsonSerializable()
class CropData with EquatableMixin, SerializableMixin {
  /// The x coordinate of the top left corner of the crop rectangle.
  final double x;

  /// The y coordinate of the top left corner of the crop rectangle.
  final double y;

  /// The width of the crop rectangle.
  final double width;

  /// The height of the crop rectangle.
  final double height;

  /// Creates new [CropData] from given data.
  CropData({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Duplicates this instance with given data overrides.
  CropData copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
  }) =>
      CropData(
        x: x ?? this.x,
        y: y ?? this.y,
        width: width ?? this.width,
        height: height ?? this.height,
      );

  @override
  List<Object?> get props => [x, y, width, height];

  /// Factory constructor for creating [CropData] instance from a JSON data.
  factory CropData.fromJson(Map json) => _$CropDataFromJson(json);

  @override
  Map toJson() => _$CropDataToJson(this);
}
