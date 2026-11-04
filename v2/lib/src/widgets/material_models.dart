// Value types of the material widgets, by Flutter's names: immutable, total
// decoding (bad values fall back to defaults), sparse encoding.
import 'package:meta/meta.dart';

import '../json.dart';
import '../values/border.dart';
import '../values/color.dart';
import '../values/geometry.dart';
import '../values/text.dart';

/// An icon glyph, as `IconProps.icon` holds it: `{"source", "codepoint",
/// "name", "style", "fontFamily"?, ...}` or `{"image": url}`.
typedef IconGlyph = Json;

Color? _color(Object? j) => Color.fromJson(j);
IconGlyph? _glyph(Object? j) {
  final m = readMap(j);
  return m == null || m.isEmpty ? null : m;
}

/// Which of Flutter's `OutlinedBorder`s a [ShapeBorder] is.
enum ShapeBorderType {
  /// `RoundedRectangleBorder` (a plain rectangle when the radius is zero).
  roundedRectangle,
  circle,
  stadium,
  continuousRectangle,
  beveledRectangle,
  roundedSuperellipse,
}

/// One of Flutter's `OutlinedBorder`s: its kind, corner radius and side.
/// JSON: `{"type": "stadium", "borderRadius": 8, "side": {...}}`.
@immutable
final class ShapeBorder {
  const ShapeBorder({
    this.type = ShapeBorderType.roundedRectangle,
    this.borderRadius = BorderRadius.zero,
    this.side,
  });

  final ShapeBorderType type;

  /// Corner radii (rectangle types).
  final BorderRadius borderRadius;

  /// The outline; null draws none.
  final BorderSide? side;

  static ShapeBorder? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return ShapeBorder(
      type: readEnum(ShapeBorderType.values, m['type'], ShapeBorderType.roundedRectangle),
      borderRadius: BorderRadius.fromJson(m['borderRadius']),
      side: BorderSide.fromJson(m['side']),
    );
  }

  Json toJson() => {
        if (type != ShapeBorderType.roundedRectangle) 'type': type.name,
        if (!borderRadius.isZero) 'borderRadius': borderRadius.toJson(),
        if (side != null) 'side': side!.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      other is ShapeBorder && other.type == type && other.borderRadius == borderRadius && other.side == side;

  @override
  int get hashCode => Object.hash(type, borderRadius, side);
}

/// Flutter's `ButtonStyle`, as the buttons' `styleFrom` takes it. Null
/// fields are the button's own defaults. The padding is the node's
/// `layout.padding`; the size is the node's box (no minimum size).
@immutable
final class ButtonStyle {
  const ButtonStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.shadowColor,
    this.elevation,
    this.textStyle = TextStyle.empty,
    this.side,
    this.shape,
    this.iconSize,
    this.iconColor,
  });

  static const ButtonStyle empty = ButtonStyle();

  final Color? backgroundColor;

  /// Label (and icon) color.
  final Color? foregroundColor;
  final Color? shadowColor;
  final double? elevation;
  final TextStyle textStyle;
  final BorderSide? side;
  final ShapeBorder? shape;
  final double? iconSize;
  final Color? iconColor;

  static ButtonStyle fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return empty;
    return ButtonStyle(
      backgroundColor: _color(m['backgroundColor']),
      foregroundColor: _color(m['foregroundColor']),
      shadowColor: _color(m['shadowColor']),
      elevation: readDouble(m['elevation']),
      textStyle: TextStyle.fromJson(m['textStyle']),
      side: BorderSide.fromJson(m['side']),
      shape: ShapeBorder.fromJson(m['shape']),
      iconSize: readDouble(m['iconSize']),
      iconColor: _color(m['iconColor']),
    );
  }

  Json toJson() => {
        if (backgroundColor != null) 'backgroundColor': backgroundColor!.toJson(),
        if (foregroundColor != null) 'foregroundColor': foregroundColor!.toJson(),
        if (shadowColor != null) 'shadowColor': shadowColor!.toJson(),
        if (elevation != null) 'elevation': writeDouble(elevation!),
        if (!textStyle.isEmpty) 'textStyle': textStyle.toJson(),
        if (side != null) 'side': side!.toJson(),
        if (shape != null) 'shape': shape!.toJson(),
        if (iconSize != null) 'iconSize': writeDouble(iconSize!),
        if (iconColor != null) 'iconColor': iconColor!.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      other is ButtonStyle &&
      other.backgroundColor == backgroundColor &&
      other.foregroundColor == foregroundColor &&
      other.shadowColor == shadowColor &&
      other.elevation == elevation &&
      other.textStyle == textStyle &&
      other.side == side &&
      other.shape == shape &&
      other.iconSize == iconSize &&
      other.iconColor == iconColor;

  @override
  int get hashCode =>
      Object.hash(backgroundColor, foregroundColor, shadowColor, elevation, textStyle, side, shape, iconSize, iconColor);
}

/// Flutter's `VisualDensity`.
@immutable
final class VisualDensity {
  const VisualDensity({this.horizontal = 0, this.vertical = 0});

  static const VisualDensity standard = VisualDensity();

  final double horizontal, vertical;

  static VisualDensity? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return VisualDensity(
      horizontal: (readDouble(m['horizontal']) ?? 0).clamp(-4, 4).toDouble(),
      vertical: (readDouble(m['vertical']) ?? 0).clamp(-4, 4).toDouble(),
    );
  }

  Json toJson() => {
        if (horizontal != 0) 'horizontal': writeDouble(horizontal),
        if (vertical != 0) 'vertical': writeDouble(vertical),
      };

  @override
  bool operator ==(Object other) => other is VisualDensity && other.horizontal == horizontal && other.vertical == vertical;

  @override
  int get hashCode => Object.hash(horizontal, vertical);
}

/// An icon with its own size, color and tooltip: an app bar's leading icon
/// or action (Flutter's `IconButton` in `AppBar.actions`). [actions] are
/// its reactions, as a node's.
@immutable
final class IconAction {
  const IconAction({required this.icon, this.size, this.color, this.tooltip, this.actions = const []});

  final IconGlyph icon;
  final double? size;
  final Color? color;
  final String? tooltip;
  final List<Json> actions;

  static IconAction? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return IconAction(
      icon: _glyph(m['icon']) ?? const {},
      size: readDouble(m['size']),
      color: _color(m['color']),
      tooltip: readString(m['tooltip']),
      actions: [...?readList(m['actions'])?.map(readMap).nonNulls],
    );
  }

  Json toJson() => {
        'icon': icon,
        if (size != null) 'size': writeDouble(size!),
        if (color != null) 'color': color!.toJson(),
        if (tooltip != null) 'tooltip': tooltip,
        if (actions.isNotEmpty) 'actions': actions,
      };

  @override
  bool operator ==(Object other) =>
      other is IconAction &&
      jsonEquality.equals(other.icon, icon) &&
      other.size == size &&
      other.color == color &&
      other.tooltip == tooltip &&
      jsonEquality.equals(other.actions, actions);

  @override
  int get hashCode => Object.hash(jsonEquality.hash(icon), size, color, tooltip);
}

/// A navigation bar item: Flutter's `NavigationDestination` (and
/// `BottomNavigationBarItem`). Icon colors are the item's own, over the
/// bar's. [actions] are its reactions.
@immutable
final class NavigationDestination {
  const NavigationDestination({
    this.label = '',
    this.icon = const {},
    this.iconColor,
    this.selectedIcon,
    this.selectedIconColor,
    this.tooltip,
    this.backgroundColor,
    this.actions = const [],
  });

  final String label;
  final IconGlyph icon;
  final Color? iconColor;
  final IconGlyph? selectedIcon;
  final Color? selectedIconColor;
  final String? tooltip;

  /// `BottomNavigationBarItem.backgroundColor` (shifting bars).
  final Color? backgroundColor;
  final List<Json> actions;

  static NavigationDestination? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return NavigationDestination(
      label: readString(m['label']) ?? '',
      icon: _glyph(m['icon']) ?? const {},
      iconColor: _color(m['iconColor']),
      selectedIcon: _glyph(m['selectedIcon']),
      selectedIconColor: _color(m['selectedIconColor']),
      tooltip: readString(m['tooltip']),
      backgroundColor: _color(m['backgroundColor']),
      actions: [...?readList(m['actions'])?.map(readMap).nonNulls],
    );
  }

  Json toJson() => {
        if (label.isNotEmpty) 'label': label,
        if (icon.isNotEmpty) 'icon': icon,
        if (iconColor != null) 'iconColor': iconColor!.toJson(),
        if (selectedIcon != null) 'selectedIcon': selectedIcon,
        if (selectedIconColor != null) 'selectedIconColor': selectedIconColor!.toJson(),
        if (tooltip != null) 'tooltip': tooltip,
        if (backgroundColor != null) 'backgroundColor': backgroundColor!.toJson(),
        if (actions.isNotEmpty) 'actions': actions,
      };

  @override
  bool operator ==(Object other) =>
      other is NavigationDestination &&
      other.label == label &&
      jsonEquality.equals(other.icon, icon) &&
      other.iconColor == iconColor &&
      jsonEquality.equals(other.selectedIcon, selectedIcon) &&
      other.selectedIconColor == selectedIconColor &&
      other.tooltip == tooltip &&
      other.backgroundColor == backgroundColor &&
      jsonEquality.equals(other.actions, actions);

  @override
  int get hashCode => Object.hash(label, jsonEquality.hash(icon), iconColor, tooltip, backgroundColor);
}
