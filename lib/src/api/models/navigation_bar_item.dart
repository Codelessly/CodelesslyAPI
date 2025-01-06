import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../field_access.dart';
import '../mixins.dart';
import 'models.dart';

part 'navigation_bar_item.g.dart';

/// A base class that represents a navigation bar item.
abstract class NavigationBarItem
    with SerializableMixin, EquatableMixin, ReactionMixin, FieldsHolder {
  /// Unique ID of this item.
  final String id;

  /// Name/label of this item.
  String label;

  /// Icon of this item.
  MultiSourceIconModel icon;

  /// Icon when this item is selected. Defaults to [icon].
  MultiSourceIconModel? selectedIcon;

  /// Whether the [selectedIcon] is different from [icon].
  bool differSelectedIcon;

  /// Tooltip text when hovered. This is equal to the [label] by default.
  String? tooltip;

  /// Creates new [NavigationBarItem] with given data.
  NavigationBarItem({
    required this.id,
    required this.label,
    required this.icon,
    List<Reaction> reactions = const [],
    this.selectedIcon,
    this.tooltip,
    this.differSelectedIcon = false,
  }) {
    setReactionMixin(reactions);
  }

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'label': StringFieldAccess(
          'Label',
          'Name/label of this item.',
          () => label,
          (value) => label = value,
        ),
        'icon': IconFieldAccess<MultiSourceIconModel>(
          'Icon',
          'Icon of this item.',
          () => icon,
          (value) => icon = value,
        ),
        'selectedIcon': IconFieldAccess<MultiSourceIconModel?>(
          'Selected Icon',
          'Icon when this item is selected.',
          () => differSelectedIcon ? selectedIcon : null,
          (value) {
            differSelectedIcon = value != null;
            selectedIcon = value;
          },
          required: false,
        ),
        'tooltip': StringFieldAccess(
          'Tooltip',
          'Tooltip text when hovered.',
          () => tooltip ?? '',
          (value) {
            if (value.isEmpty) {
              tooltip = null;
            } else {
              tooltip = value;
            }
          },
        ),
      };

  @override
  List<Object?> get props =>
      [label, icon, selectedIcon, differSelectedIcon, tooltip, reactions];
}

/// A navigation bar item that adheres to material 2.0 design specs.
@JsonSerializable()
class M2NavigationBarItem extends NavigationBarItem {
  /// Fills the entire navigation bar's background color when this item is
  /// selected.
  /// ONLY used under the following conditions:
  /// - Navigation bar is a material 2 bar.
  /// - The navigation bar type is set to 'shifting' and NOT 'fixed'.
  ColorRGBA? backgroundColor;

  /// Creates new [M2NavigationBarItem] with given data.
  M2NavigationBarItem({
    required super.id,
    required super.label,
    required super.icon,
    super.differSelectedIcon,
    super.tooltip,
    super.selectedIcon,
    this.backgroundColor,
  });

  @override
  FieldsMap generateFields() => {
        'backgroundColor': ColorFieldAccess<ColorRGBA?>(
          'Background Color',
          'Fills the entire navigation bar\'s background color when this item is selected.',
          () => backgroundColor,
          (value) => backgroundColor = value,
        ),
        ...super.generateFields(),
      };

  /// Factory constructor for creating a new [M2NavigationBarItem] instance
  /// from JSON data.
  factory M2NavigationBarItem.fromJson(Map json) =>
      _$M2NavigationBarItemFromJson(json);

  @override
  Map toJson() => _$M2NavigationBarItemToJson(this);
}

/// A navigation bar item that adheres to material 3.0 design specs.
@JsonSerializable()
class M3NavigationBarItem extends NavigationBarItem {
  /// Creates new [M3NavigationBarItem] with given data.
  M3NavigationBarItem({
    required super.id,
    required super.label,
    required super.icon,
    super.tooltip,
    super.selectedIcon,
    super.differSelectedIcon,
  });

  /// Factory constructor for creating a new [M3NavigationBarItem] instance
  /// from JSON data.
  factory M3NavigationBarItem.fromJson(Map json) =>
      _$M3NavigationBarItemFromJson(json);

  @override
  Map toJson() => _$M3NavigationBarItemToJson(this);
}
