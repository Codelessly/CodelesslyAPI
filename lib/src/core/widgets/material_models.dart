// Value types of the material widgets, by Flutter's names: immutable, total
// decoding (bad values fall back to defaults), sparse encoding.
import 'package:meta/meta.dart';

import '../json.dart';
import '../props.dart';
import '../triggers.dart';
import '../values/paint.dart' show listEquals;
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
  final List<Reaction> actions;

  static IconAction? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return IconAction(
      icon: _glyph(m['icon']) ?? const {},
      size: readDouble(m['size']),
      color: _color(m['color']),
      tooltip: readString(m['tooltip']),
      actions: Reaction.listFromJson(m['actions']),
    );
  }

  Json toJson() => {
        'icon': icon,
        if (size != null) 'size': writeDouble(size!),
        if (color != null) 'color': color!.toJson(),
        if (tooltip != null) 'tooltip': tooltip,
        if (actions.isNotEmpty) 'actions': [for (final r in actions) r.toJson()],
      };

  @override
  bool operator ==(Object other) =>
      other is IconAction &&
      jsonEquality.equals(other.icon, icon) &&
      other.size == size &&
      other.color == color &&
      other.tooltip == tooltip &&
      listEquals(other.actions, actions);

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
  final List<Reaction> actions;

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
      actions: Reaction.listFromJson(m['actions']),
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
        if (actions.isNotEmpty) 'actions': [for (final r in actions) r.toJson()],
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
      listEquals(other.actions, actions);

  @override
  int get hashCode => Object.hash(label, jsonEquality.hash(icon), iconColor, tooltip, backgroundColor);
}

// --- field declarations ---------------------------------------------------------
//
// The models' fields as PropDefs (JSON keys, codecs, defaults): what a
// properties panel edits. test/value_fields_test.dart checks them against
// the models' own JSON.

Object? _out(Object? v) => v == null ? null : (v as dynamic).toJson();
List<Reaction>? _reactionsIn(Object? j) => readList(j) == null ? null : Reaction.listFromJson(j);
Object? _reactionsOut(List<Reaction> v) => [for (final r in v) r.toJson()];
const _reactions = ValueCodec<List<Reaction>>(_reactionsIn, _reactionsOut, PropType.list(PropType.json('Reaction')));

abstract final class ShapeBorderFields {
  static const type = PropDef<ShapeBorderType>('type', EnumCodec(ShapeBorderType.values), ShapeBorderType.roundedRectangle);
  static const borderRadius = PropDef<BorderRadius>('borderRadius', Codecs.radius, BorderRadius.zero);
  static const side = PropDef<BorderSide?>('side', Codecs.optionalBorderSide, null);
  static const spec = WidgetSpec('ShapeBorder', props: [type, borderRadius, side], doc: 'Flutter `OutlinedBorder`.');
  static const codec = ValueCodec<ShapeBorder?>(ShapeBorder.fromJson, _out, PropType.record('ShapeBorder', spec));
}

abstract final class ButtonStyleFields {
  /// The button's fill.
  static const backgroundColor = PropDef<Color?>('backgroundColor', Codecs.optionalColor, null);
  static const foregroundColor = PropDef<Color?>('foregroundColor', Codecs.optionalColor, null);
  /// The colour of the shadow under a raised button.
  static const shadowColor = PropDef<Color?>('shadowColor', Codecs.optionalColor, null);
  /// How raised the button is (its shadow).
  static const elevation = PropDef<double?>('elevation', Codecs.optionalDouble, null);
  /// The label's style (a TextStyle or a theme style's name). Its colour comes from `foregroundColor`; without a
  /// `fontSize` the label is 12 px.
  static const textStyle = PropDef<TextStyle>('textStyle', Codecs.textStyle, TextStyle.empty);
  /// The button's border.
  static const side = PropDef<BorderSide?>('side', Codecs.optionalBorderSide, null);
  /// The button's shape: `{"type": "roundedRectangle", "borderRadius": 10}`, `stadium`, `circle`...
  static const shape = PropDef<ShapeBorder?>('shape', ShapeBorderFields.codec, null);
  /// The icon's size.
  static const iconSize = PropDef<double?>('iconSize', Codecs.optionalDouble, null);
  /// The icon's colour; without one, `foregroundColor`.
  static const iconColor = PropDef<Color?>('iconColor', Codecs.optionalColor, null);
  static const spec = WidgetSpec('ButtonStyle',
      props: [backgroundColor, foregroundColor, shadowColor, elevation, textStyle, side, shape, iconSize, iconColor],
      doc: 'Flutter `ButtonStyle`.');
  static const codec = ValueCodec<ButtonStyle>(ButtonStyle.fromJson, _out, PropType.record('ButtonStyle', spec));
}

abstract final class VisualDensityFields {
  static const horizontal = PropDef<double>('horizontal', DoubleCodec(min: -4, max: 4), 0);
  static const vertical = PropDef<double>('vertical', DoubleCodec(min: -4, max: 4), 0);
  static const spec = WidgetSpec('VisualDensity', props: [horizontal, vertical], doc: 'Flutter `VisualDensity`.');
  static const codec = ValueCodec<VisualDensity?>(VisualDensity.fromJson, _out, PropType.record('VisualDensity', spec));
}

abstract final class IconActionFields {
  static const icon = PropDef<Json>('icon', Codecs.icon, {});
  static const size = PropDef<double?>('size', Codecs.optionalDouble, null);
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);
  static const tooltip = PropDef<String?>('tooltip', Codecs.optionalString, null);
  static const actions = PropDef<List<Reaction>>('actions', _reactions, []);
  static const spec = WidgetSpec('IconAction', props: [icon, size, color, tooltip, actions], doc: '`IconButton`.');
  static const codec = ValueCodec<IconAction>(IconAction.fromJson, _out, PropType.record('IconAction', spec));
  static const optionalCodec = ValueCodec<IconAction?>(IconAction.fromJson, _out, PropType.record('IconAction', spec));
}

abstract final class NavigationDestinationFields {
  static const label = PropDef<String>('label', Codecs.string, '');
  static const icon = PropDef<Json>('icon', Codecs.icon, {});
  static const iconColor = PropDef<Color?>('iconColor', Codecs.optionalColor, null);
  static const selectedIcon = PropDef<Json?>('selectedIcon', Codecs.optionalIcon, null);
  static const selectedIconColor = PropDef<Color?>('selectedIconColor', Codecs.optionalColor, null);
  static const tooltip = PropDef<String?>('tooltip', Codecs.optionalString, null);
  static const backgroundColor = PropDef<Color?>('backgroundColor', Codecs.optionalColor, null);
  static const actions = PropDef<List<Reaction>>('actions', _reactions, []);
  static const spec = WidgetSpec('NavigationDestination',
      props: [label, icon, iconColor, selectedIcon, selectedIconColor, tooltip, backgroundColor, actions],
      doc: 'Flutter `NavigationDestination`.');
  static const codec = ValueCodec<NavigationDestination>(
      NavigationDestination.fromJson, _out, PropType.record('NavigationDestination', spec));
}
