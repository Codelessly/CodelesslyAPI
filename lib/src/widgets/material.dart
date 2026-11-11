// Widget declarations: material. One WidgetSpec per type; props with Flutter's
// names and defaults (see ../props.dart).
import '../props.dart';
import '../values/border.dart';
import '../values/color.dart';
import '../values/enums.dart';
import '../values/geometry.dart';
import '../values/text.dart';
import 'material_models.dart';

export 'material_models.dart';

const _nullableColor = Codecs.optionalColor;
const _glyph = Codecs.icon;
const _shape = ShapeBorderFields.codec;
const _side = Codecs.optionalBorderSide;
const _insets = Codecs.optionalInsets;
const _optionalDouble = Codecs.optionalDouble;
const _optionalString = Codecs.optionalString;

/// Where a button's icon sits: Flutter's `IconAlignment`.
enum IconAlignment { start, end }

/// Flutter's `NavigationDestinationLabelBehavior` (plus showing only the
/// unselected labels, which `BottomNavigationBar` can).
enum NavigationDestinationLabelBehavior { alwaysShow, alwaysHide, onlyShowSelected, onlyShowUnselected }

enum BottomNavigationBarType { fixed, shifting }

enum BottomNavigationBarLandscapeLayout { spread, centered, linear }

enum ListTileTitleAlignment { threeLine, titleHeight, top, center, bottom }

/// Which `FloatingActionButton` constructor: `FloatingActionButton()`,
/// `.small`, `.large` or `.extended`.
enum FloatingActionButtonType { regular, small, large, extended }

/// Flutter's `FloatingActionButtonLocation`s, by name.
enum FloatingActionButtonLocation {
  startTop,
  miniStartTop,
  centerTop,
  miniCenterTop,
  endTop,
  miniEndTop,
  startFloat,
  miniStartFloat,
  centerFloat,
  miniCenterFloat,
  endFloat,
  miniEndFloat,
  startDocked,
  miniStartDocked,
  centerDocked,
  miniCenterDocked,
  endDocked,
  miniEndDocked,
}

/// `ElevatedButton`, `FilledButton`, `TextButton`, `OutlinedButton`: a
/// label with an optional icon (their `.icon` constructors), styled by a
/// `ButtonStyle`.
abstract final class ButtonProps {
  static const label = PropDef<String>('label', Codecs.string, '');
  static const textAlign = PropDef<TextAlign>('textAlign', EnumCodec(TextAlign.values), TextAlign.start);

  /// The icon beside the label; empty for none.
  static const icon = PropDef<IconGlyph>('icon', _glyph, {});
  static const iconAlignment =
      PropDef<IconAlignment>('iconAlignment', EnumCodec(IconAlignment.values), IconAlignment.start);

  /// Space between the icon and the label.
  static const spacing = PropDef<double>('spacing', Codecs.positive, 8);

  /// False is a disabled button (`onPressed: null`).
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const style = PropDef<ButtonStyle>('style', ButtonStyleFields.codec, ButtonStyle.empty);

  /// `FilledButton.tonal`.
  static const tonal = PropDef<bool>('tonal', Codecs.bool, false);

  static const List<PropDef<Object?>> all = [label, textAlign, icon, iconAlignment, spacing, enabled, style];

  static const elevated = WidgetSpec('elevatedButton', props: all, doc: 'Flutter `ElevatedButton`.');
  static const filled = WidgetSpec('filledButton', props: [...all, tonal], doc: 'Flutter `FilledButton`.');
  static const text = WidgetSpec('textButton', props: all, doc: 'Flutter `TextButton`.');
  static const outlined = WidgetSpec('outlinedButton', props: all, doc: 'Flutter `OutlinedButton`.');
}

/// `IconButton`: an icon, styled by a `ButtonStyle`.
abstract final class IconButtonProps {
  static const icon = PropDef<IconGlyph>('icon', _glyph, {});
  static const enabled = ButtonProps.enabled;
  static const style = ButtonProps.style;
  static const spec = WidgetSpec('iconButton', props: [icon, enabled, style], doc: 'Flutter `IconButton`.');
}

/// `FloatingActionButton` (and its small, large and extended forms).
abstract final class FloatingActionButtonProps {
  static const type = PropDef<FloatingActionButtonType>(
      'type', EnumCodec(FloatingActionButtonType.values), FloatingActionButtonType.regular);
  static const icon = PropDef<IconGlyph>('icon', _glyph, {});

  /// The extended button's label.
  static const label = PropDef<String>('label', Codecs.string, '');
  static const backgroundColor = PropDef<Color?>('backgroundColor', _nullableColor, null);
  static const foregroundColor = PropDef<Color?>('foregroundColor', _nullableColor, null);
  static const focusColor = PropDef<Color?>('focusColor', _nullableColor, null);
  static const hoverColor = PropDef<Color?>('hoverColor', _nullableColor, null);
  static const splashColor = PropDef<Color?>('splashColor', _nullableColor, null);
  static const elevation = PropDef<double?>('elevation', _optionalDouble, null);
  static const focusElevation = PropDef<double?>('focusElevation', _optionalDouble, null);
  static const hoverElevation = PropDef<double?>('hoverElevation', _optionalDouble, null);
  static const highlightElevation = PropDef<double?>('highlightElevation', _optionalDouble, null);
  static const shape = PropDef<ShapeBorder?>('shape', _shape, null);
  static const extendedTextStyle = PropDef<TextStyle>('extendedTextStyle', Codecs.textStyle, TextStyle.empty);
  static const extendedIconLabelSpacing = PropDef<double?>('extendedIconLabelSpacing', _optionalDouble, null);
  static const extendedPadding = PropDef<EdgeInsets?>('extendedPadding', _insets, null);

  /// Where a screen's `Scaffold` places it.
  static const location = PropDef<FloatingActionButtonLocation>(
      'location', EnumCodec(FloatingActionButtonLocation.values), FloatingActionButtonLocation.endFloat);

  static const spec = WidgetSpec('floatingActionButton',
      props: [
        type, icon, label, backgroundColor, foregroundColor, focusColor, hoverColor, splashColor, elevation, //
        focusElevation, hoverElevation, highlightElevation, shape, extendedTextStyle, extendedIconLabelSpacing,
        extendedPadding, location,
      ],
      doc: 'Flutter `FloatingActionButton`.');
}

/// `Chip`, `ActionChip`, `ChoiceChip`, `FilterChip` and `InputChip`.
abstract final class ChipProps {
  static const label = PropDef<String>('label', Codecs.string, '');
  static const labelStyle = PropDef<TextStyle>('labelStyle', Codecs.textStyle, TextStyle.empty);

  /// An icon glyph, or `{"image": url}` for a `CircleAvatar`.
  static const avatar = PropDef<IconGlyph>('avatar', _glyph, {});
  /// The avatar's box; a selectable chip's checkmark is drawn in it too (at
  /// 75 %), so it sizes the checkmark. Null: Material's.
  static const avatarSize = PropDef<double?>('avatarSize', _optionalDouble, null);
  static const avatarColor = PropDef<Color?>('avatarColor', _nullableColor, null);
  static const deleteIcon = PropDef<IconGlyph>('deleteIcon', _glyph, {});
  static const deleteIconSize = PropDef<double?>('deleteIconSize', _optionalDouble, null);
  static const deleteIconColor = PropDef<Color?>('deleteIconColor', _nullableColor, null);
  static const selected = PropDef<bool>('selected', Codecs.bool, false);
  static const showCheckmark = PropDef<bool>('showCheckmark', Codecs.bool, true);
  static const checkmarkColor = PropDef<Color?>('checkmarkColor', _nullableColor, null);
  static const backgroundColor = PropDef<Color?>('backgroundColor', _nullableColor, null);
  static const selectedColor = PropDef<Color?>('selectedColor', _nullableColor, null);
  static const side = PropDef<BorderSide?>('side', _side, null);
  static const shape = PropDef<ShapeBorder?>('shape', _shape, null);
  static const elevation = PropDef<double?>('elevation', _optionalDouble, null);
  static const shadowColor = PropDef<Color?>('shadowColor', _nullableColor, null);
  static const padding = PropDef<EdgeInsets?>('padding', _insets, null);
  static const labelPadding = PropDef<EdgeInsets?>('labelPadding', _insets, null);
  static const tooltip = PropDef<String?>('tooltip', _optionalString, null);
  static const autofocus = PropDef<bool>('autofocus', Codecs.bool, false);
  static const isEnabled = PropDef<bool>('isEnabled', Codecs.bool, true);

  static const List<PropDef<Object?>> _common = [
    label, labelStyle, avatar, avatarSize, avatarColor, backgroundColor, side, shape, elevation, shadowColor, //
    padding, labelPadding, autofocus,
  ];
  static const List<PropDef<Object?>> _selectable = [
    selected, showCheckmark, checkmarkColor, selectedColor, tooltip, isEnabled,
  ];

  static const chip = WidgetSpec('chip', props: _common, doc: 'Flutter `Chip`.');
  static const action = WidgetSpec('actionChip', props: [..._common, tooltip, isEnabled], doc: 'Flutter `ActionChip`.');
  static const choice = WidgetSpec('choiceChip', props: [..._common, ..._selectable], doc: 'Flutter `ChoiceChip`.');
  static const filter = WidgetSpec('filterChip', props: [..._common, ..._selectable], doc: 'Flutter `FilterChip`.');
  static const input = WidgetSpec('inputChip',
      props: [..._common, ..._selectable, deleteIcon, deleteIconSize, deleteIconColor], doc: 'Flutter `InputChip`.');
}

/// `Badge`: a small label (or a dot) over its `child` slot.
abstract final class BadgeProps {
  /// The label; null is a dot (`smallSize`).
  static const label = PropDef<String?>('label', _optionalString, null);

  /// `Badge.count`: shown as `maxCount+` above [maxCount].
  static const count = PropDef<int?>('count', OptionalIntCodec(), null);
  static const maxCount = PropDef<int>('maxCount', Codecs.int, 999);
  static const isLabelVisible = PropDef<bool>('isLabelVisible', Codecs.bool, true);
  static const backgroundColor = PropDef<Color?>('backgroundColor', _nullableColor, null);
  static const textColor = PropDef<Color?>('textColor', _nullableColor, null);
  static const textStyle = PropDef<TextStyle>('textStyle', Codecs.textStyle, TextStyle.empty);
  static const smallSize = PropDef<double>('smallSize', Codecs.positive, 6);
  static const largeSize = PropDef<double>('largeSize', Codecs.positive, 16);
  static const padding =
      PropDef<EdgeInsets>('padding', Codecs.insets, EdgeInsets.symmetric(horizontal: 4));
  static const alignment =
      PropDef<Alignment>('alignment', Codecs.alignment, Alignment(1, -1));
  static const offset = PropDef<Offset>('offset', Codecs.offset, Offset(4, -4));

  static const spec = WidgetSpec('badge',
      props: [
        label, count, maxCount, isLabelVisible, backgroundColor, textColor, textStyle, smallSize, largeSize, //
        padding, alignment, offset,
      ],
      children: ChildModel.slots,
      slots: ['child'],
      doc: 'Flutter `Badge`.');
}

/// `ListTile`, its widgets in the `leading`, `title`, `subtitle` and
/// `trailing` slots.
abstract final class ListTileProps {
  static const dense = PropDef<bool>('dense', Codecs.bool, false);
  static const isThreeLine = PropDef<bool>('isThreeLine', Codecs.bool, false);
  static const visualDensity =
      PropDef<VisualDensity?>('visualDensity', VisualDensityFields.codec, null);
  static const shape = PropDef<ShapeBorder?>('shape', _shape, null);
  static const selected = PropDef<bool>('selected', Codecs.bool, false);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const autofocus = PropDef<bool>('autofocus', Codecs.bool, false);
  static const enableFeedback = PropDef<bool>('enableFeedback', Codecs.bool, true);
  static const tileColor = PropDef<Color?>('tileColor', _nullableColor, null);
  static const selectedTileColor = PropDef<Color?>('selectedTileColor', _nullableColor, null);
  static const selectedColor = PropDef<Color?>('selectedColor', _nullableColor, null);
  static const iconColor = PropDef<Color?>('iconColor', _nullableColor, null);
  static const textColor = PropDef<Color?>('textColor', _nullableColor, null);
  static const hoverColor = PropDef<Color?>('hoverColor', _nullableColor, null);
  static const focusColor = PropDef<Color?>('focusColor', _nullableColor, null);
  static const contentPadding = PropDef<EdgeInsets?>('contentPadding', _insets, null);
  static const horizontalTitleGap = PropDef<double?>('horizontalTitleGap', _optionalDouble, null);
  static const minVerticalPadding = PropDef<double?>('minVerticalPadding', _optionalDouble, null);
  static const minLeadingWidth = PropDef<double?>('minLeadingWidth', _optionalDouble, null);
  static const minTileHeight = PropDef<double?>('minTileHeight', _optionalDouble, null);
  static const titleAlignment = PropDef<ListTileTitleAlignment?>(
      'titleAlignment', OptionalEnumCodec(ListTileTitleAlignment.values), null);

  static const spec = WidgetSpec('listTile',
      props: [
        dense, isThreeLine, visualDensity, shape, selected, enabled, autofocus, enableFeedback, tileColor, //
        selectedTileColor, selectedColor, iconColor, textColor, hoverColor, focusColor, contentPadding,
        horizontalTitleGap, minVerticalPadding, minLeadingWidth, minTileHeight, titleAlignment,
      ],
      children: ChildModel.slots,
      slots: ['leading', 'title', 'subtitle', 'trailing'],
      doc: 'Flutter `ListTile`.');
}


/// `AppBar`.
abstract final class AppBarProps {
  static const title = PropDef<String>('title', Codecs.string, '');
  static const titleTextStyle = PropDef<TextStyle>('titleTextStyle', Codecs.textStyle, TextStyle.empty);
  static const centerTitle = PropDef<bool?>('centerTitle', Codecs.optionalBool, null);
  static const titleSpacing = PropDef<double?>('titleSpacing', _optionalDouble, null);
  static const leading = PropDef<IconAction?>('leading', IconActionFields.optionalCodec, null);
  static const leadingWidth = PropDef<double?>('leadingWidth', _optionalDouble, null);
  static const automaticallyImplyLeading = PropDef<bool>('automaticallyImplyLeading', Codecs.bool, true);
  static const actions =
      PropDef<List<IconAction>>('actions', ListCodec(IconActionFields.codec), []);
  static const backgroundColor = PropDef<Color?>('backgroundColor', _nullableColor, null);
  static const foregroundColor = PropDef<Color?>('foregroundColor', _nullableColor, null);
  static const surfaceTintColor = PropDef<Color?>('surfaceTintColor', _nullableColor, null);
  static const shadowColor = PropDef<Color?>('shadowColor', _nullableColor, null);
  static const elevation = PropDef<double?>('elevation', _optionalDouble, null);
  static const scrolledUnderElevation = PropDef<double?>('scrolledUnderElevation', _optionalDouble, null);

  static const spec = WidgetSpec('appBar',
      props: [
        title, titleTextStyle, centerTitle, titleSpacing, leading, leadingWidth, automaticallyImplyLeading, //
        actions, backgroundColor, foregroundColor, surfaceTintColor, shadowColor, elevation, scrolledUnderElevation,
      ],
      doc: 'Flutter `AppBar` (its toolbar height is the node height).');
}


/// What `NavigationBar` and `BottomNavigationBar` share: items, the
/// selection, and the selected/unselected label and icon styles.
abstract final class NavigationBarProps {
  static const destinations = PropDef<List<NavigationDestination>>(
      'destinations', ListCodec(NavigationDestinationFields.codec), []);
  static const selectedIndex = PropDef<int>('selectedIndex', Codecs.int, 0);
  static const backgroundColor = PropDef<Color?>('backgroundColor', _nullableColor, null);
  static const elevation = PropDef<double?>('elevation', _optionalDouble, null);
  static const labelBehavior = PropDef<NavigationDestinationLabelBehavior>('labelBehavior',
      EnumCodec(NavigationDestinationLabelBehavior.values), NavigationDestinationLabelBehavior.alwaysShow);
  static const labelTextStyle = PropDef<TextStyle>('labelTextStyle', Codecs.textStyle, TextStyle.empty);
  static const selectedLabelTextStyle =
      PropDef<TextStyle>('selectedLabelTextStyle', Codecs.textStyle, TextStyle.empty);
  static const iconColor = PropDef<Color?>('iconColor', _nullableColor, null);
  static const selectedIconColor = PropDef<Color?>('selectedIconColor', _nullableColor, null);
  static const iconSize = PropDef<double>('iconSize', Codecs.positive, 24);
  static const selectedIconSize = PropDef<double>('selectedIconSize', Codecs.positive, 24);

  /// `NavigationBar.indicatorColor`.
  static const indicatorColor = PropDef<Color?>('indicatorColor', _nullableColor, null);

  /// `BottomNavigationBar.type` and `landscapeLayout`.
  static const type = PropDef<BottomNavigationBarType>(
      'type', EnumCodec(BottomNavigationBarType.values), BottomNavigationBarType.fixed);
  static const landscapeLayout = PropDef<BottomNavigationBarLandscapeLayout>('landscapeLayout',
      EnumCodec(BottomNavigationBarLandscapeLayout.values), BottomNavigationBarLandscapeLayout.spread);

  /// Sits in a `BottomAppBar` notched for a docked floating action button.
  static const notched = PropDef<bool>('notched', Codecs.bool, false);
  static const notchMargin = PropDef<double>('notchMargin', Codecs.positive, 4);

  static const List<PropDef<Object?>> _common = [
    destinations, selectedIndex, backgroundColor, elevation, labelBehavior, labelTextStyle, selectedLabelTextStyle, //
    iconColor, selectedIconColor, iconSize, selectedIconSize, notched, notchMargin,
  ];

  static const spec = WidgetSpec('navigationBar', props: [..._common, indicatorColor], doc: 'Flutter `NavigationBar`.');
  static const bottom = WidgetSpec('bottomNavigationBar',
      props: [..._common, type, landscapeLayout], doc: 'Flutter `BottomNavigationBar`.');
}

/// `Divider` and `VerticalDivider`: a line across the node's box.
abstract final class DividerProps {
  static const thickness = PropDef<double>('thickness', Codecs.positive, 1);

  /// Null is the theme's outline variant.
  static const color = PropDef<Color?>('color', _nullableColor, null);
  static const indent = PropDef<double>('indent', Codecs.positive, 0);
  static const endIndent = PropDef<double>('endIndent', Codecs.positive, 0);

  static const List<PropDef<Object?>> all = [thickness, color, indent, endIndent];
  static const horizontal = WidgetSpec('divider', props: all, doc: 'Flutter `Divider`.');
  static const vertical = WidgetSpec('verticalDivider', props: all, doc: 'Flutter `VerticalDivider`.');
}

/// A dialog: its `trigger` slot is shown in place and opens the `content`
/// slot in a `Dialog`.
abstract final class ModalProps {
  static const spec = WidgetSpec('modal',
      props: [], children: ChildModel.slots, slots: ['trigger', 'content'], doc: 'Flutter `showDialog` + `Dialog`.');
}

const List<WidgetSpec> materialSpecs = [
  ButtonProps.elevated,
  ButtonProps.filled,
  ButtonProps.text,
  ButtonProps.outlined,
  IconButtonProps.spec,
  FloatingActionButtonProps.spec,
  ChipProps.chip,
  ChipProps.action,
  ChipProps.choice,
  ChipProps.filter,
  ChipProps.input,
  BadgeProps.spec,
  ListTileProps.spec,
  AppBarProps.spec,
  NavigationBarProps.spec,
  NavigationBarProps.bottom,
  DividerProps.horizontal,
  DividerProps.vertical,
  ModalProps.spec,
];
