import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'dropdown_menu_style.g.dart';

/// The look of a dropdown's menu when it is drawn as a card anchored under
/// the field instead of the platform's dropdown menu.
///
/// Unset values follow the dropdown's own properties: its dropdown color,
/// corner radius, hover color and item text style.
@JsonSerializable()
class DropdownMenuStyleModel with Equatable, SerializableMixin {
  /// Background of the menu. Null uses the dropdown color.
  final ColorRGBA? color;

  /// Outline of the menu. Null draws none.
  final BorderSideModel? border;

  /// Corner radius of the menu. Null uses the dropdown's border radius.
  final double? radius;

  /// Drop shadows of the menu, e.g. a hard offset shadow (radius 0). Null
  /// draws a soft shadow from the dropdown's elevation; an empty list draws
  /// none.
  final List<Effect>? shadows;

  /// Gap between the field and the menu.
  final double offset;

  /// The tallest the menu grows before it scrolls.
  final double maxHeight;

  /// The narrowest the menu is. It is at least as wide as the field.
  final double minWidth;

  /// Space inside the menu around its rows. Null is 6 at the top and bottom.
  final EdgeInsetsModel? padding;

  /// Space inside each row. Null is 14 at the sides.
  final EdgeInsetsModel? itemPadding;

  /// Height of each row.
  final double itemHeight;

  /// Background of the selected row. Null leaves it unmarked.
  final ColorRGBA? selectedItemColor;

  /// Background of a hovered row. Null uses the dropdown's hover color.
  final ColorRGBA? hoverItemColor;

  /// Changes to the item text style for the selected row, e.g.
  /// `{"fontWeight": "w600"}`.
  final TextStyleModel? selectedTextStyle;

  /// Whether the selected row shows a check mark at its end.
  final bool showCheck;

  /// Color of the check mark. Null uses the item text color.
  final ColorRGBA? checkColor;

  /// Size of the check mark.
  final double checkSize;

  /// Creates a [DropdownMenuStyleModel].
  const DropdownMenuStyleModel({
    this.color,
    this.border,
    this.radius,
    this.shadows,
    this.offset = 6,
    this.maxHeight = 320,
    this.minWidth = 0,
    this.padding,
    this.itemPadding,
    this.itemHeight = 40,
    this.selectedItemColor,
    this.hoverItemColor,
    this.selectedTextStyle,
    this.showCheck = false,
    this.checkColor,
    this.checkSize = 18,
  });

  /// Duplicates this style with the given values replaced.
  DropdownMenuStyleModel copyWith({
    ColorRGBA? color,
    BorderSideModel? border,
    double? radius,
    List<Effect>? shadows,
    double? offset,
    double? maxHeight,
    double? minWidth,
    EdgeInsetsModel? padding,
    EdgeInsetsModel? itemPadding,
    double? itemHeight,
    ColorRGBA? selectedItemColor,
    ColorRGBA? hoverItemColor,
    TextStyleModel? selectedTextStyle,
    bool? showCheck,
    ColorRGBA? checkColor,
    double? checkSize,
  }) => DropdownMenuStyleModel(
    color: color ?? this.color,
    border: border ?? this.border,
    radius: radius ?? this.radius,
    shadows: shadows ?? this.shadows,
    offset: offset ?? this.offset,
    maxHeight: maxHeight ?? this.maxHeight,
    minWidth: minWidth ?? this.minWidth,
    padding: padding ?? this.padding,
    itemPadding: itemPadding ?? this.itemPadding,
    itemHeight: itemHeight ?? this.itemHeight,
    selectedItemColor: selectedItemColor ?? this.selectedItemColor,
    hoverItemColor: hoverItemColor ?? this.hoverItemColor,
    selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
    showCheck: showCheck ?? this.showCheck,
    checkColor: checkColor ?? this.checkColor,
    checkSize: checkSize ?? this.checkSize,
  );

  @override
  List<Object?> get props => [
    color,
    border,
    radius,
    shadows,
    offset,
    maxHeight,
    minWidth,
    padding,
    itemPadding,
    itemHeight,
    selectedItemColor,
    hoverItemColor,
    selectedTextStyle,
    showCheck,
    checkColor,
    checkSize,
  ];

  /// Creates a [DropdownMenuStyleModel] from JSON.
  factory DropdownMenuStyleModel.fromJson(Map json) =>
      _$DropdownMenuStyleModelFromJson(json);

  @override
  Map toJson() => _$DropdownMenuStyleModelOmitDefaults(
    this,
    _$DropdownMenuStyleModelToJson(this),
  );
}
