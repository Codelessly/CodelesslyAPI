// v1 → v2 migrations: material widgets. See TypeMigration in ../migrate.dart.
//
// v1's defaults and the values SDK 8.x resolved while rendering (a button's
// default color, a count badge's label, a visual density preset) are
// resolved here, once, into Flutter-named v2 props.
import 'dart:math' as math;

import 'package:codelessly_api/codelessly_api.dart';

import '../actions.dart';
import '../migrate.dart';

String _rgba(ColorRGBA c) => V1Node.rgba(c);
String? _rgbaOrNull(ColorRGBA? c) => c == null ? null : V1Node.rgba(c);
num _n(num v) => roundNum(v);

Object _insets(EdgeInsetsModel e) => V1Node.insets(e);

/// A v1 text style, its color split off (buttons and bars color their
/// labels with a foreground color).
(Json, String?) _styleAndColor(TextProp p) {
  final s = V1Node.textStyle(p);
  final color = s.remove('color') as String?;
  return (s, color);
}

/// An icon glyph as v2's icon prop holds it; null when v1 drew nothing.
Json? glyphOf(MultiSourceIconModel? icon) {
  if (icon == null || !icon.show) return null;
  switch (icon.type) {
    case IconTypeEnum.icon:
      final i = icon.icon;
      if (i == null) return null;
      return {'source': icon.type.name, ...Map<String, Object?>.from(i.toJson())};
    case IconTypeEnum.image:
      final url = icon.iconImage;
      if (url == null) return null;
      return {'source': icon.type.name, 'image': url, if (icon.scale != 1) 'scale': icon.scale};
  }
}

/// v1's `getShape`: the kind, corners and (when both are set) the side.
Json shapeOf(CShapeBorder shape, CornerRadius radius, {ColorRGBA? borderColor, double? borderWidth}) {
  final type = switch (shape) {
    CShapeBorder.rectangle || CShapeBorder.roundedRectangle => null,
    CShapeBorder.circle => 'circle',
    CShapeBorder.stadium => 'stadium',
    CShapeBorder.continuousRectangle => 'continuousRectangle',
    CShapeBorder.beveledRectangle => 'beveledRectangle',
    CShapeBorder.roundedSuperellipse => 'roundedSuperellipse',
  };
  final rounded = shape != CShapeBorder.rectangle && shape != CShapeBorder.circle && shape != CShapeBorder.stadium;
  final tl = radius.tl.x, tr = radius.tr.x, br = radius.br.x, bl = radius.bl.x;
  return {
    'type': ?type,
    if (rounded && (tl != 0 || tr != 0 || br != 0 || bl != 0))
      'borderRadius': tl == tr && tr == br && br == bl ? _n(tl) : [_n(tl), _n(tr), _n(br), _n(bl)],
    if (borderColor != null && borderWidth != null && borderWidth > 0)
      'side': {'color': _rgba(borderColor), if (borderWidth != 1) 'width': _n(borderWidth)},
  };
}

String _textAlign(TextAlignHorizontalEnum a) => switch (a) {
      TextAlignHorizontalEnum.left => 'left',
      TextAlignHorizontalEnum.center => 'center',
      TextAlignHorizontalEnum.right => 'right',
      TextAlignHorizontalEnum.justified => 'justify',
      TextAlignHorizontalEnum.start => 'start',
      TextAlignHorizontalEnum.end => 'end',
    };

/// A ButtonNode's `ButtonStyle`, as SDK 8.x's `createMasterButtonStyle` and
/// `getButtonShape` built it.
Json _buttonStyle(ButtonNode n) {
  final p = n.properties;
  final type = p.buttonType;
  final (textStyle, labelColor) = _styleAndColor(p.labelStyle);
  final buttonColor = p.buttonColor ?? (type == ButtonTypeEnum.text ? ColorRGBA.transparent : ColorRGBA.black);
  final outlined = type == ButtonTypeEnum.outlined;
  final shape = shapeOf(
    p.shape,
    p.cornerRadius,
    borderColor: outlined ? p.borderColor ?? buttonColor : p.borderColor,
    borderWidth: outlined ? p.borderWidth ?? 1 : p.borderWidth,
  );
  String? foreground = labelColor;
  if (type == ButtonTypeEnum.icon) {
    // An icon button's ink color, as v1 derived it.
    final a = buttonColor.a;
    final base = a > 0 && a < 0.7 ? buttonColor : (a == 0 ? p.icon.color : null);
    foreground = base == null ? null : _rgba(base.copyWith(a: 0.1));
  }
  final String? background = switch (type) {
    ButtonTypeEnum.outlined => '#00000000',
    // A filled button without a color is the theme's primary.
    ButtonTypeEnum.filled when p.buttonColor == null => null,
    _ => _rgba(buttonColor),
  };
  final iconSize = math.min(p.icon.size ?? 24, n.basicBoxLocal.height);
  return {
    'backgroundColor': ?background,
    'foregroundColor': ?foreground,
    'shadowColor': _rgba(p.shadowColor),
    'elevation': _n(p.elevation),
    if (type != ButtonTypeEnum.icon && textStyle.isNotEmpty) 'textStyle': textStyle,
    if (shape['side'] case final Object side when outlined) 'side': side,
    'shape': shape,
    'iconSize': _n(iconSize),
    'iconColor': ?_rgbaOrNull(p.icon.color),
  };
}

TypeMigration _button(String v2Type) => TypeMigration(
      type: (_) => v2Type,
      props: (m) {
        m.take('properties');
        m.take('enabled');
        final n = m.n as ButtonNode;
        final p = n.properties;
        final style = _buttonStyle(n);
        if (n is IconButtonNode) {
          return {
            'icon': ?glyphOf(p.icon),
            if (!p.enabled) 'enabled': false,
            'style': style,
          };
        }
        return {
          if (p.label.isNotEmpty) 'label': p.label,
          if (p.labelAlignment != TextAlignHorizontalEnum.start) 'textAlign': _textAlign(p.labelAlignment),
          'icon': ?glyphOf(p.icon),
          if (p.placement == IconPlacementEnum.end) 'iconAlignment': 'end',
          if (p.gap != 8) 'spacing': _n(p.gap),
          if (!p.enabled) 'enabled': false,
          'style': style,
          if (p.buttonType == ButtonTypeEnum.filledTonal) 'tonal': true,
        };
      },
    );

Json _fabProps(V1Node m) {
  m.take('properties');
  final p = (m.n as FloatingActionButtonNode).properties;
  final extended = p.type == FloatingActionButtonType.extended;
  // SDK 8.x's getFABShape: a plain circle (stadium when extended) is the
  // button's own; anything else is the shape mixin's.
  final plain = (extended ? p.shape == CShapeBorder.stadium : p.shape == CShapeBorder.circle) &&
      (p.borderColor == null || p.borderWidth == null || p.borderWidth == 0);
  final (labelStyle, labelColor) = _styleAndColor(p.labelStyle);
  return {
    if (p.type != FloatingActionButtonType.regular) 'type': p.type.name,
    'icon': ?glyphOf(p.icon),
    if (p.label.isNotEmpty) 'label': p.label,
    'backgroundColor': _rgba(p.backgroundColor),
    'foregroundColor': _rgba(p.foregroundColor),
    'focusColor': ?_rgbaOrNull(p.focusColor),
    'hoverColor': ?_rgbaOrNull(p.hoverColor),
    'splashColor': ?_rgbaOrNull(p.splashColor),
    'elevation': _n(p.elevation),
    'focusElevation': _n(p.focusElevation),
    'hoverElevation': _n(p.hoverElevation),
    'highlightElevation': _n(p.highlightElevation),
    'shape': plain
        ? {'type': extended ? 'stadium' : 'circle'}
        : shapeOf(p.shape, p.cornerRadius, borderColor: p.borderColor, borderWidth: p.borderWidth),
    if (extended) ...{
      'extendedTextStyle': {...labelStyle, 'color': ?labelColor},
      'extendedIconLabelSpacing': _n(p.extendedIconLabelSpacing),
      'extendedPadding': [10, 2, 10, 2],
    },
    if (p.location != FABLocation.endFloat) 'location': p.location.name,
  };
}

String _chipType(BaseNode n) => switch ((n as ChipNode).properties.chipType) {
      ChipType.basic => 'chip',
      ChipType.action => 'actionChip',
      ChipType.choice => 'choiceChip',
      ChipType.filter => 'filterChip',
      ChipType.input => 'inputChip',
    };

Json _chipProps(V1Node m) {
  m.take('properties');
  m.take('enabled');
  final n = m.n as ChipNode;
  final p = n.properties;
  final type = p.chipType;
  final selectable = type == ChipType.choice || type == ChipType.filter;
  final avatarUrl = p.avatar;
  final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
  final icon = hasAvatar ? null : glyphOf(p.icon);
  return {
    if (p.label.isNotEmpty) 'label': p.label,
    if (V1Node.textStyle(p.labelStyle) case final s when s.isNotEmpty) 'labelStyle': s,
    if (hasAvatar) 'avatar': {'image': avatarUrl},
    'avatar': ?icon,
    if (icon != null) 'avatarSize': _n(p.icon!.size ?? 18),
    if (icon != null) 'avatarColor': ?_rgbaOrNull(p.icon!.color),
    if (type == ChipType.input) ...{
      'deleteIcon': ?glyphOf(p.deleteIcon),
      if (glyphOf(p.deleteIcon) != null) 'deleteIconSize': _n(p.deleteIcon!.size ?? 18),
      'deleteIconColor': ?_rgbaOrNull(p.deleteIconColor ?? p.deleteIcon?.color),
    },
    if (selectable && p.selected) 'selected': true,
    if (selectable && !p.showCheckmark) 'showCheckmark': false,
    if (selectable) 'checkmarkColor': ?_rgbaOrNull(p.checkmarkColor),
    'backgroundColor': ?_rgbaOrNull(p.backgroundColor),
    if (selectable) 'selectedColor': ?_rgbaOrNull(p.selectedColor),
    // Without a border color or width, the chip keeps Material 3's border.
    if (p.borderColor != null || p.borderWidth != 1)
      'side': {'color': ?_rgbaOrNull(p.borderColor), if (p.borderWidth != 1) 'width': _n(p.borderWidth)},
    'shape': {if (p.cornerRadius != 0) 'borderRadius': _n(p.cornerRadius)},
    'elevation': _n(p.elevation),
    'shadowColor': ?_rgbaOrNull(p.shadowColor),
    'padding': _insets(p.padding),
    'labelPadding': _insets(p.labelPadding),
    if (type != ChipType.basic && p.tooltip != null && p.tooltip!.isNotEmpty) 'tooltip': p.tooltip,
    if (p.autofocus) 'autofocus': true,
    if (type != ChipType.basic && !n.enabled) 'isEnabled': false,
  };
}

Json _badgeProps(V1Node m) {
  m.take('properties');
  m.take('childID');
  final p = (m.n as BadgeNode).properties;
  final textStyle = V1Node.textStyle(p.textStyle);
  final align = switch (p.alignment) {
    BadgeAlignment.topRight => null,
    BadgeAlignment.topLeft => [-1, -1],
    BadgeAlignment.bottomRight => [1, 1],
    BadgeAlignment.bottomLeft => [-1, 1],
  };
  final count = p.badgeType == BadgeType.count ? int.tryParse(p.label.trim()) : null;
  return {
    if (p.badgeType != BadgeType.dot && count == null) 'label': p.label,
    'count': ?count,
    if (count != null && p.maxCount != 999) 'maxCount': p.maxCount,
    if (!p.isLabelVisible) 'isLabelVisible': false,
    'backgroundColor': ?_rgbaOrNull(p.backgroundColor),
    'textColor': ?_rgbaOrNull(p.textColor),
    if (textStyle.isNotEmpty) 'textStyle': textStyle,
    if (p.smallSize != 6) 'smallSize': _n(p.smallSize),
    if (p.largeSize != 16) 'largeSize': _n(p.largeSize),
    if (p.padding != const EdgeInsetsModel.symmetric(horizontal: 4)) 'padding': _insets(p.padding),
    'alignment': ?align,
    if (p.offsetX != 4 || p.offsetY != -4) 'offset': [_n(p.offsetX), _n(p.offsetY)],
  };
}

Map<String, String> _badgeSlots(V1Node m) {
  final child = (m.n as BadgeNode).childID;
  return {
    if (child != null && child.isNotEmpty && child != m.n.id && m.nodes.containsKey(child)) 'child': child,
  };
}

Json? _density(VisualDensityModel d) {
  final (h, v) = switch (d.type) {
    VisualDensityType.standard || VisualDensityType.adaptivePlatformDensity => (0.0, 0.0),
    VisualDensityType.comfortable => (-1.0, -1.0),
    VisualDensityType.compact => (-2.0, -2.0),
    _ => (d.horizontal, d.vertical),
  };
  if (h == 0 && v == 0) return null;
  return {if (h != 0) 'horizontal': _n(h), if (v != 0) 'vertical': _n(v)};
}

Json _listTileProps(V1Node m) {
  m.take('properties');
  for (final k in const ['leading', 'title', 'subtitle', 'trailing']) {
    m.take(k);
  }
  final p = (m.n as ListTileNode).properties;
  final shape = shapeOf(p.shape, p.cornerRadius, borderColor: p.borderColor, borderWidth: p.borderWidth);
  return {
    if (p.dense) 'dense': true,
    if (p.isThreeLine) 'isThreeLine': true,
    'visualDensity': ?_density(p.visualDensity),
    if (shape.isNotEmpty) 'shape': shape,
    if (p.selected) 'selected': true,
    if (!p.enabled) 'enabled': false,
    if (p.autofocus) 'autofocus': true,
    if (!p.enableFeedback) 'enableFeedback': false,
    'tileColor': ?_rgbaOrNull(p.tileColor),
    'selectedTileColor': ?_rgbaOrNull(p.selectedTileColor),
    'selectedColor': ?_rgbaOrNull(p.selectedColor),
    'iconColor': ?_rgbaOrNull(p.iconColor),
    'textColor': ?_rgbaOrNull(p.textColor),
    'hoverColor': ?_rgbaOrNull(p.hoverColor),
    'focusColor': ?_rgbaOrNull(p.focusColor),
    'contentPadding': _insets(p.contentPadding),
    if (p.horizontalTitleGap case final double v) 'horizontalTitleGap': _n(v),
    if (p.minVerticalPadding case final double v) 'minVerticalPadding': _n(v),
    if (p.minLeadingWidth case final double v) 'minLeadingWidth': _n(v),
    if (p.minTileHeight case final double v) 'minTileHeight': _n(v),
    'titleAlignment': ?p.titleAlignment?.name,
  };
}

Map<String, String> _listTileSlots(V1Node m) {
  final n = m.n as ListTileNode;
  final p = n.properties;
  return {
    for (final (slot, id, show) in [
      ('leading', n.leading, p.showLeading),
      ('title', n.title, p.showTitle),
      ('subtitle', n.subtitle, p.showSubtitle),
      ('trailing', n.trailing, p.showTrailing),
    ])
      if (show && id != null && m.nodes.containsKey(id)) slot: id,
  };
}

Json _iconAction(IconAppBarActionItem item) => {
      'icon': glyphOf(item.icon) ?? const <String, Object?>{},
      if (item.icon.size case final double s) 'size': _n(s),
      'color': ?_rgbaOrNull(item.icon.color),
      if (item.tooltip case final String t when t.isNotEmpty) 'tooltip': t,
      if (item.reactions.isNotEmpty) 'actions': ActionMigration().reactions(item.reactions),
    };

Json _appBarProps(V1Node m) {
  m.take('properties');
  final p = (m.n as AppBarNode).properties;
  final (titleStyle, titleColor) = _styleAndColor(p.titleStyle);
  final showLeading = p.leading.icon.show;
  return {
    if (p.title.trim().isNotEmpty) 'title': p.title,
    if (titleStyle.isNotEmpty || titleColor != null) 'titleTextStyle': {...titleStyle, 'color': ?titleColor},
    'centerTitle': p.centerTitle,
    'titleSpacing': _n(p.titleSpacing),
    if (showLeading && !p.automaticallyImplyLeading) 'leading': _iconAction(p.leading),
    if (p.leading.icon.size case final double s) 'leadingWidth': _n(s),
    if (!showLeading || !p.automaticallyImplyLeading) 'automaticallyImplyLeading': showLeading && p.automaticallyImplyLeading,
    if (p.actions.isNotEmpty) 'actions': [for (final a in p.actions) _iconAction(a)],
    'backgroundColor': _rgba(p.backgroundColor),
    'surfaceTintColor': _rgba(p.backgroundColor),
    'foregroundColor': ?(_rgbaOrNull(p.foregroundColor) ?? titleColor),
    'shadowColor': _rgba(p.shadowColor),
    'elevation': _n(p.elevation),
    if (p.scrolledUnderElevation case final double v) 'scrolledUnderElevation': _n(v),
  };
}

String _navType(BaseNode n) => (n as NavigationBarNode).properties.styleDefinition == StyleDefinition.material_2
    ? 'bottomNavigationBar'
    : 'navigationBar';

Json _destination(NavigationBarItem item, {bool m2 = false}) => {
      if (item.label.isNotEmpty) 'label': item.label,
      'icon': glyphOf(item.icon) ?? const <String, Object?>{},
      'iconColor': ?_rgbaOrNull(item.icon.color),
      if (item.differSelectedIcon && item.selectedIcon != null) ...{
        'selectedIcon': glyphOf(item.selectedIcon) ?? const <String, Object?>{},
        'selectedIconColor': ?_rgbaOrNull(item.selectedIcon!.color),
      },
      if (item.tooltip case final String t when t != item.label) 'tooltip': t,
      if (m2 && item is M2NavigationBarItem) 'backgroundColor': ?_rgbaOrNull(item.backgroundColor),
      if (item.reactions.isNotEmpty) 'actions': ActionMigration().reactions(item.reactions),
    };

Json _navigationBarProps(V1Node m) {
  m.take('properties');
  m.take('selectedIndex');
  final n = m.n as NavigationBarNode;
  final p = n.properties;
  final common = <String, Object?>{
    if (n.selectedIndex != 0) 'selectedIndex': n.selectedIndex,
    if (p.makeNotched) 'notched': true,
    if (p.notchMargin != 4) 'notchMargin': _n(p.notchMargin),
  };
  if (p is M3NavigationBarProperties) {
    return {
      'destinations': [for (final i in p.items) _destination(i)],
      ...common,
      'backgroundColor': ?_rgbaOrNull(p.backgroundColor),
      'elevation': _n(p.elevation),
      if (p.labelBehavior != MaterialNavigationBarLabelBehavior.alwaysShow) 'labelBehavior': p.labelBehavior.name,
      'labelTextStyle': V1Node.textStyle(p.unselectedLabelStyle),
      'selectedLabelTextStyle': V1Node.textStyle(p.selectedLabelStyle),
      'iconColor': ?_rgbaOrNull(p.unselectedIconColor),
      'selectedIconColor': ?_rgbaOrNull(p.selectedIconColor),
      if (p.unselectedIconSize != 24) 'iconSize': _n(p.unselectedIconSize),
      if (p.selectedIconSize != 24) 'selectedIconSize': _n(p.selectedIconSize),
      'indicatorColor': ?_rgbaOrNull(p.indicatorColor),
    };
  }
  final m2 = p as M2NavigationBarProperties;
  return {
    'destinations': [for (final i in m2.items) _destination(i, m2: true)],
    ...common,
    'backgroundColor': ?_rgbaOrNull(m2.backgroundColor),
    'elevation': _n(m2.elevation),
    if (m2.labelBehavior != MaterialNavigationBarLabelBehavior.alwaysShow) 'labelBehavior': m2.labelBehavior.name,
    // The label colors are the item colors (`selectedItemColor`...).
    'labelTextStyle': V1Node.textStyle(m2.unselectedLabelStyle),
    'selectedLabelTextStyle': V1Node.textStyle(m2.selectedLabelStyle),
    'iconColor': ?_rgbaOrNull(m2.unselectedIconColor),
    'selectedIconColor': ?_rgbaOrNull(m2.selectedIconColor),
    if (m2.unselectedIconSize != 24) 'iconSize': _n(m2.unselectedIconSize),
    if (m2.selectedIconSize != 24) 'selectedIconSize': _n(m2.selectedIconSize),
    if (m2.navigationBarType != M2NavigationBarType.fixed) 'type': m2.navigationBarType.name,
    if (m2.landscapeLayout != M2NavigationBarLandscapeLayout.spread) 'landscapeLayout': m2.landscapeLayout.name,
  };
}

Json _dividerProps(V1Node m) {
  m.take('properties');
  final p = (m.n as DividerNode).properties;
  return {
    if (p.thickness != 1) 'thickness': _n(p.thickness),
    'color': _rgba(p.color),
    if (p.indent != 0) 'indent': _n(p.indent),
    if (p.endIndent != 0) 'endIndent': _n(p.endIndent),
  };
}

/// By v1 node type.
final Map<String, TypeMigration> materialMigrations = {
  'elevatedButton': _button('elevatedButton'),
  'filledButton': _button('filledButton'),
  'textButton': _button('textButton'),
  'outlinedButton': _button('outlinedButton'),
  'iconButton': _button('iconButton'),
  'floatingActionButton': TypeMigration(type: (_) => 'floatingActionButton', props: _fabProps),
  'chip': const TypeMigration(type: _chipType, props: _chipProps),
  'badge': TypeMigration(type: (_) => 'badge', props: _badgeProps, slots: _badgeSlots),
  'listTile': TypeMigration(type: (_) => 'listTile', props: _listTileProps, slots: _listTileSlots),
  'appBar': TypeMigration(type: (_) => 'appBar', props: _appBarProps),
  'navigationBar': const TypeMigration(type: _navType, props: _navigationBarProps),
  'divider': TypeMigration(
    type: (n) => (n as DividerNode).properties.isVertical ? 'verticalDivider' : 'divider',
    props: _dividerProps,
  ),
  'modal': TypeMigration(
    type: (_) => 'modal',
    props: (m) {
      // A modal's own enabled flag and aspect lock do nothing (it is its
      // trigger in place).
      for (final k in const ['trigger', 'content', 'enabled', 'aspectRatioLock']) {
        m.take(k);
      }
      return {};
    },
    slots: (m) {
      final n = m.n as ModalNode;
      return {
        if (m.nodes.containsKey(n.trigger)) 'trigger': n.trigger,
        if (m.nodes.containsKey(n.content)) 'content': n.content,
      };
    },
  ),
};
