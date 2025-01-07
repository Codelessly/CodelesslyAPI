import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';

part 'alignment.g.dart';

/// [AlignmentModel] wraps [AlignmentData] and provides standard alignment
/// values such as [topRight] and [bottomCenter] for ease of use.
@JsonSerializable()
class AlignmentModel with EquatableMixin, SerializableMixin {
  /// Holds the actual x and y percentage information.
  final AlignmentData? data;

  /// Creates an AlignmentModel with the given [data].
  const AlignmentModel([this.data]);

  /// Equivalent to having no alignment at all.
  static const AlignmentModel none = AlignmentModel(null);

  /// Returns true if this alignment's data is not null (is not [none]).
  bool get hasData => data != null;

  /// Represents the top-left corner.
  /// Top  o----------------
  /// Left |       |       |
  ///      |       |       |
  ///      -----------------
  ///      |       |       |
  ///      |       |       |
  ///      -----------------
  static const AlignmentModel topLeft =
      AlignmentModel(AlignmentData(-1.0, -1.0));

  /// Represents the top-center position in a rect.
  ///         Top-center
  /// --------o--------
  /// |       |       |
  /// |       |       |
  /// -----------------
  /// |       |       |
  /// |       |       |
  /// -----------------
  static const AlignmentModel topCenter =
      AlignmentModel(AlignmentData(0.0, -1.0));

  /// Represents the top-right corner.
  /// ----------------o Top-right
  /// |       |       |
  /// |       |       |
  /// -----------------
  /// |       |       |
  /// |       |       |
  /// -----------------
  static const AlignmentModel topRight =
      AlignmentModel(AlignmentData(1.0, -1.0));

  /// Represents the center-left position in a rect.
  ///        -----------------
  ///        |       |       |
  ///        |       |       |
  /// Center o----------------
  /// Left   |       |       |
  ///        |       |       |
  ///        -----------------
  static const AlignmentModel centerLeft =
      AlignmentModel(AlignmentData(-1.0, 0.0));

  /// Represents the center position in a rect.
  /// -----------------
  /// |       |       |
  /// |       |       |
  /// --------o--------
  /// |       |center |
  /// |       |       |
  /// -----------------
  static const AlignmentModel center = AlignmentModel(AlignmentData(0.0, 0.0));

  /// Represents the center-right position in a rect.
  /// -----------------
  /// |       |       |
  /// |       |       |
  /// ----------------o Center
  /// |       |       | Right
  /// |       |       |
  /// -----------------
  static const AlignmentModel centerRight =
      AlignmentModel(AlignmentData(1.0, 0.0));

  /// Represents the bottom-left corner.
  ///        -----------------
  ///        |       |       |
  ///        |       |       |
  ///        -----------------
  ///        |       |       |
  /// Bottom |       |       |
  /// Left   o----------------
  static const AlignmentModel bottomLeft =
      AlignmentModel(AlignmentData(-1.0, 1.0));

  /// Represents the bottom-center position in a rect.
  /// -----------------
  /// |       |       |
  /// |       |       |
  /// -----------------
  /// |       |       |
  /// |       |       |
  /// --------o--------
  ///         Bottom-center
  static const AlignmentModel bottomCenter =
      AlignmentModel(AlignmentData(0.0, 1.0));

  /// Represents the bottom-right corner.
  /// -----------------
  /// |       |       |
  /// |       |       |
  /// -----------------
  /// |       |       |
  /// |       |       |
  /// ----------------o Bottom-right
  static const AlignmentModel bottomRight =
      AlignmentModel(AlignmentData(1.0, 1.0));

  /// Whether this alignment is one of the [values].
  bool get isStandard => values.contains(this);

  /// Whether this alignment is one of the standard alignments that represent
  /// either the center or the edge-centers of all four sides. In other words,
  /// whether this alignment falls on the cartesian x or y axes with a
  /// condition that it must be a standard alignment.
  bool get isCardinal =>
      data == center.data ||
      data == centerLeft.data ||
      data == centerRight.data ||
      data == topCenter.data ||
      data == bottomCenter.data;

  /// Whether this alignment contains a cardinal top y value.
  bool get hasTop => data?.y == -1;

  /// Whether this alignment contains a cardinal bottom y value.
  bool get hasBottom => data?.y == 1;

  /// Whether this alignment contains a cardinal left x value.
  bool get hasLeft => data?.x == -1;

  /// Whether this alignment contains a cardinal right x value.
  bool get hasRight => data?.x == 1;

  /// All standard alignment values for all for corners, edges and the center.
  static const List<AlignmentModel> values = [
    AlignmentModel.topLeft,
    AlignmentModel.topCenter,
    AlignmentModel.topRight,
    AlignmentModel.centerLeft,
    AlignmentModel.center,
    AlignmentModel.centerRight,
    AlignmentModel.bottomLeft,
    AlignmentModel.bottomCenter,
    AlignmentModel.bottomRight,
    AlignmentModel.none,
  ];

  /// Duplicates this [AlignmentModel] with given data overrides.
  AlignmentModel copyWith({AlignmentData? data}) {
    return AlignmentModel(data ?? this.data);
  }

  @override
  List<Object?> get props => [data];

  /// Factory constructor for creating a new [AlignmentModel] instance from
  /// JSON data.
  factory AlignmentModel.fromJson(Map json) => _$AlignmentModelFromJson(json);

  @override
  Map toJson() => _$AlignmentModelToJson(this);

  /// Displayable string representation of the object.
  String get prettify {
    final AlignmentData? data = this.data;
    if (data == null) return 'None';
    if (data.x == -1 && data.y == -1) return 'Top Left';
    if (data.x == 0 && data.y == -1) return 'Top Center';
    if (data.x == 1 && data.y == -1) return 'Top Right';
    if (data.x == -1 && data.y == 0) return 'Center Left';
    if (data.x == 0 && data.y == 0) return 'Center';
    if (data.x == 1 && data.y == 0) return 'Center Right';
    if (data.x == -1 && data.y == 1) return 'Bottom Left';
    if (data.x == 0 && data.y == 1) return 'Bottom Center';
    if (data.x == 1 && data.y == 1) return 'Bottom Right';
    return 'Custom';
  }

  /// Displayable string representation of the object.
  String get name => switch (this) {
        topLeft => 'topLeft',
        topCenter => 'topCenter',
        topRight => 'topRight',
        centerLeft => 'centerLeft',
        center => 'center',
        centerRight => 'centerRight',
        bottomLeft => 'bottomLeft',
        bottomCenter => 'bottomCenter',
        bottomRight => 'bottomRight',
        none => 'none',
        _ => 'custom',
      };

  /// Scales the x and y values of this alignment by the given scale factors.
  AlignmentModel scale(double scaleX, double scaleY) {
    if (data == null) return this;
    return AlignmentModel(AlignmentData(data!.x * scaleX, data!.y * scaleY));
  }
}

/// A data class that holds the x and y values of the alignment.
@JsonSerializable(useDynamics: true, createToJson: false)
class AlignmentData extends Equatable with DynamicSerializableMixin {
  /// The x value of the alignment that represents how far it is from
  /// the left edge of the rect. -1 means left edge, 0 means center and
  /// 1 means the right edge.
  final double x;

  /// The y value of the alignment that represents how far it is from
  /// the top edge of the rect. -1 means top edge, 0 means center and
  /// 1 means the bottom edge.
  final double y;

  /// Default constructor to create new instance of this class.
  const AlignmentData(this.x, this.y);

  @override
  List<Object?> get props => [x, y];

  /// Duplicates this [AlignmentData] with given data overrides.
  AlignmentData copyWith({double? x, double? y}) =>
      AlignmentData(x ?? this.x, y ?? this.y);

  /// Factory constructor for creating a new [AlignmentData] instance from
  /// JSON data.
  factory AlignmentData.fromJson(dynamic json) {
    if (json case [num x, num y]) {
      return AlignmentData(x.toDouble(), y.toDouble());
    }
    return _$AlignmentDataFromJson(json);
  }

  @override
  dynamic toJson() => [x, y];
}
