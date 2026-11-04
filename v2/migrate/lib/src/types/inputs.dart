// v1 → v2 migrations: inputs widgets. See TypeMigration in ../migrate.dart.
//
// Values are written as SDK 8.x passed them to Flutter (its colors, styles
// and borders), so v2 can render them with Flutter's widgets alone.
import 'package:codelessly_api/codelessly_api.dart';

import '../actions.dart';
import '../migrate.dart';

/// By v1 node type.
final Map<String, TypeMigration> inputsMigrations = {
  'textField': TypeMigration(type: (_) => 'textField', props: _textField),
  'checkbox': TypeMigration(type: (_) => 'checkbox', props: _checkbox),
  'switch': TypeMigration(type: (_) => 'switch', props: _switch),
  'radio': TypeMigration(type: (_) => 'radio', props: _radio),
  'slider': TypeMigration(type: (_) => 'slider', props: _slider),
  'dropdown': TypeMigration(type: (_) => 'dropdown', props: _dropdown),
  'datePicker': TypeMigration(type: (_) => 'datePicker', props: _datePicker),
  'timePicker': TypeMigration(type: (_) => 'timePicker', props: _timePicker),
  'dateTimeInput': TypeMigration(type: (_) => 'dateTimeInput', props: _dateTimeInput),
  'segmentedButton': TypeMigration(type: (_) => 'segmentedButton', props: _segmentedButton),
  'signature': TypeMigration(type: (_) => 'signature', props: _signature),
};

// --- values -------------------------------------------------------------------

String _rgba(ColorRGBA c) => V1Node.rgba(c);
String _rgb(ColorRGB c) => V1Node.rgb(c);

/// [v] unless it equals [def].
void _put(Json p, String key, Object? v, [Object? def]) {
  if (v == null || v == def) return;
  p[key] = v is double ? roundNum(v) : v;
}

Object _radius(CornerRadius r) => radiusJson(r);

Json? _constraints(BoxConstraintsModel c) => c.isEmpty
    ? null
    : {
        if (c.minWidth != null) 'minWidth': roundNum(c.minWidth!),
        if (c.maxWidth != null) 'maxWidth': roundNum(c.maxWidth!),
        if (c.minHeight != null) 'minHeight': roundNum(c.minHeight!),
        if (c.maxHeight != null) 'maxHeight': roundNum(c.maxHeight!),
      };

List<num>? _alignment(AlignmentModel a) => switch (a.data) {
      final AlignmentData d => [roundNum(d.x), roundNum(d.y)],
      null => null,
    };

Json _side(BorderSideModel s) => {
      'color': _rgba(s.color),
      if (s.width != 1) 'width': roundNum(s.width),
      if (s.style == BorderStyleEnum.none) 'style': 'none',
    };

Json _inputBorder(InputBorderModel b) => {
      if (b.borderType != BorderTypeEnum.outline) 'type': b.borderType.name,
      'borderSide': _side(b.borderSide),
      'borderRadius': _radius(b.cornerRadius),
      if (b.gapPadding != 4) 'gapPadding': roundNum(b.gapPadding),
    };

/// The glyph as the icon node's `icon` prop.
Json _glyph(MultiSourceIconModel icon) => {
      'source': icon.type.name,
      ...?icon.icon?.toJson().cast<String, Object?>(),
      if (icon.iconImage != null) 'image': icon.iconImage,
      if (icon.fill != null) 'fill': icon.fill,
      if (icon.weight != null) 'weight': icon.weight,
      if (icon.grade != null) 'grade': icon.grade,
      if (icon.opticalSize != null) 'opticalSize': icon.opticalSize,
      if (icon.scale != 1) 'scale': icon.scale,
    };

/// An icon as SDK 8.x showed it (`retrieveIconWidget`), or null when it
/// shows nothing.
Json? _icon(MultiSourceIconModel icon, {double? size, List<Reaction> actions = const []}) {
  if (!icon.show || icon.isEmpty) return null;
  return {
    'icon': _glyph(icon),
    if ((size ?? icon.size ?? 24) != 24) 'size': roundNum(size ?? icon.size ?? 24),
    if (icon.color case final ColorRGBA c) 'color': _rgba(c),
    if (actions.isNotEmpty) 'actions': ActionMigration().reactions(actions),
  };
}

Json _style(TextProp t) => V1Node.textStyle(t);

String? _nonEmpty(String? s) => s == null || s.isEmpty ? null : s;

// --- textField ----------------------------------------------------------------

Json _textField(V1Node m) {
  final n = m.n as TextFieldNode;
  m.take('properties');
  m.take('initialText');
  m.take('enabled');
  final p = n.properties;
  final d = p.decoration;
  final out = <String, Object?>{};
  _put(out, 'initialValue', n.initialText, '');

  final deco = <String, Object?>{};
  _put(deco, 'icon', _icon(d.icon));
  final label = _nonEmpty(d.labelText);
  _put(deco, 'labelText', label);
  if (label != null) deco['labelStyle'] = _style(d.labelStyle);
  deco['floatingLabelStyle'] = _style(d.floatingLabelStyle);
  _put(deco, 'helperText', _nonEmpty(d.helperText));
  deco['helperStyle'] = _style(d.helperStyle);
  deco['helperMaxLines'] = d.helperMaxLines;
  _put(deco, 'hintText', _nonEmpty(d.hintText));
  deco['hintStyle'] = _style(d.hintStyle);
  deco['hintMaxLines'] = d.hintMaxLines;
  _put(deco, 'errorText', _nonEmpty(d.errorText));
  deco['errorStyle'] = _style(d.errorStyle);
  deco['errorMaxLines'] = d.errorMaxLines;
  _put(deco, 'floatingLabelBehavior', d.floatingLabelBehavior.name, 'auto');
  _put(deco, 'isCollapsed', d.isCollapsed, false);
  deco['isDense'] = d.isDense;
  // Unset: the node's padding (layout.padding), as SDK 8.x did.
  if (d.contentPadding case final EdgeInsetsModel e) deco['contentPadding'] = V1Node.insets(e);
  _put(deco, 'prefixIcon', _icon(d.prefixIcon.icon, actions: d.prefixIcon.reactions));
  _put(deco, 'prefixIconConstraints', _constraints(d.prefixIconConstraints));
  _put(deco, 'prefixText', _nonEmpty(d.prefixText));
  deco['prefixStyle'] = _style(d.prefixStyle);
  _put(deco, 'suffixIcon', _icon(d.suffixIcon.icon, actions: d.suffixIcon.reactions));
  _put(deco, 'suffixIconConstraints', _constraints(d.suffixIconConstraints));
  _put(deco, 'suffixText', _nonEmpty(d.suffixText));
  deco['suffixStyle'] = _style(d.suffixStyle);
  if (!d.showCounter) {
    deco['counterText'] = '';
  } else {
    _put(deco, 'counterText', _nonEmpty(d.counterText));
  }
  deco['counterStyle'] = _style(d.counterStyle);
  if (d.filled) {
    deco['filled'] = true;
    deco['fillColor'] = _rgba(d.fillColor);
    deco['focusColor'] = _rgba(d.focusColor);
    deco['hoverColor'] = _rgba(d.hoverColor);
  }
  deco['errorBorder'] = _inputBorder(d.errorBorder);
  deco['focusedBorder'] = _inputBorder(d.focusedBorder);
  deco['focusedErrorBorder'] = _inputBorder(d.focusedErrorBorder);
  deco['disabledBorder'] = _inputBorder(d.disabledBorder);
  deco['enabledBorder'] = _inputBorder(d.enabledBorder);
  deco['border'] = _inputBorder(d.border);
  _put(deco, 'enabled', d.enabled, true);
  _put(deco, 'semanticCounterText', _nonEmpty(d.semanticCounterText));
  if (label != null) deco['alignLabelWithHint'] = d.alignLabelWithHint;
  _put(deco, 'constraints', _constraints(d.constraints));
  out['decoration'] = deco;

  out['style'] = _style(p.inputStyle);
  _put(out, 'textAlign', switch (p.textAlign) {
    TextAlignHorizontalEnum.left || TextAlignHorizontalEnum.start => null,
    TextAlignHorizontalEnum.end => 'end',
    TextAlignHorizontalEnum.center => 'center',
    TextAlignHorizontalEnum.right => 'right',
    TextAlignHorizontalEnum.justified => 'justify',
  });
  out['textAlignVertical'] = p.textAlignVertical.name;
  _put(out, 'keyboardType', switch (p.keyboardType) {
    TextInputTypeEnum.dateTime => 'datetime',
    final t => t.name,
  }, 'text');
  if (p.keyboardType == TextInputTypeEnum.number) {
    _put(out, 'keyboardDecimal', p.showDecimalKey, false);
    _put(out, 'keyboardSigned', p.showSignKey, false);
  }
  out['textInputAction'] = p.textInputAction.name;
  _put(out, 'textCapitalization', p.textCapitalization.name, 'none');
  _put(out, 'autocorrect', p.autoCorrect, true);
  _put(out, 'autofocus', p.autoFocus, false);
  _put(out, 'enableInteractiveSelection', p.enableInteractiveSelection, true);
  _put(out, 'enabled', p.enabled, true);
  _put(out, 'obscureText', p.obscureText, false);
  _put(out, 'obscuringCharacter', p.obscuringCharacter, '•');
  _put(out, 'readOnly', p.readOnly, false);
  _put(out, 'showCursor', p.showCursor, true);
  out['cursorColor'] = _rgb(p.cursorColor);
  _put(out, 'cursorHeight', p.cursorHeight);
  _put(out, 'cursorWidth', p.cursorWidth, 2.0);
  _put(out, 'cursorRadius', p.cursorRadius);
  _put(out, 'maxLength', p.maxLength);
  // v1's null is no limit, as v2's 0.
  _put(out, 'maxLines', p.maxLines == null || p.maxLines! < 1 ? 0 : p.maxLines, 1);
  _put(out, 'minLines', p.minLines);
  _put(out, 'selectionHeightStyle', p.selectionHeightStyle.name, 'tight');
  _put(out, 'selectionWidthStyle', p.selectionWidthStyle.name, 'tight');
  if (p.autofillHints.isNotEmpty) out['autofillHints'] = [for (final h in p.autofillHints) h.code];
  _put(out, 'autovalidateMode', p.autovalidateMode.name, 'disabled');
  _put(out, 'selectAllOnFocus', p.selectAllOnFocus, false);
  if (p.focusRingWidth > 0) {
    out['focusRingWidth'] = roundNum(p.focusRingWidth);
    out['focusRingColor'] = _rgba(p.focusRingColor);
  }
  // Their names are the editor's labels.
  if (p.formatter is! NoneTextInputFormatterModel) {
    out['inputFormatter'] = Map<String, Object?>.from(p.formatter.toJson())..remove('name');
  }
  if (p.validator is! NoneTextInputValidatorModel) {
    out['validator'] = Map<String, Object?>.from(p.validator.toJson())..remove('name');
  }
  if (p.markdown case final MarkdownStyle md) out['markdown'] = Map<String, Object?>.from(md.toJson());
  return out;
}

// --- checkbox, switch, radio --------------------------------------------------

Json _checkbox(V1Node m) {
  final n = m.n as CheckboxNode;
  m.take('properties');
  m.take('value');
  m.take('enabled');
  final p = n.properties;
  final out = <String, Object?>{};
  _put(out, 'value', n.value);
  _put(out, 'tristate', p.tristate, false);
  _put(out, 'autofocus', p.autofocus, false);
  out['checkColor'] = _rgba(p.checkColor);
  out['activeColor'] = _rgba(p.activeColor);
  out['hoverColor'] = _rgba(p.hoverColor);
  out['focusColor'] = _rgba(p.focusColor);
  _put(out, 'splashRadius', p.splashRadius, 20.0);
  out['borderRadius'] = _radius(p.cornerRadius);
  out['side'] = {'color': _rgba(p.borderColor), if (p.borderWidth != 1) 'width': roundNum(p.borderWidth)};
  _put(out, 'compact', p.compact, false);
  return out;
}

Json _switch(V1Node m) {
  final n = m.n as SwitchNode;
  m.take('properties');
  m.take('value');
  m.take('enabled');
  final p = n.properties;
  final out = <String, Object?>{};
  _put(out, 'value', n.value, false);
  _put(out, 'autofocus', p.autofocus, false);
  out['activeTrackColor'] = _rgba(p.activeTrackColor);
  out['inactiveTrackColor'] = _rgba(p.inactiveTrackColor);
  out['activeThumbColor'] = _rgba(p.activeThumbColor);
  out['inactiveThumbColor'] = _rgba(p.inactiveThumbColor);
  out['hoverColor'] = _rgba(p.hoverColor);
  out['focusColor'] = _rgba(p.focusColor);
  _put(out, 'splashRadius', p.splashRadius, 20.0);
  if (p.activeTrackBorderColor case final ColorRGBA c) out['activeTrackOutlineColor'] = _rgba(c);
  if (p.inactiveTrackBorderColor case final ColorRGBA c) out['inactiveTrackOutlineColor'] = _rgba(c);
  _put(out, 'trackOutlineWidth', p.trackOutlineWidth, 2.0);
  _put(out, 'uniformThumb', p.uniformThumb, false);
  _put(out, 'fillTrack', p.fillTrack, false);
  return out;
}

Json _radio(V1Node m) {
  final n = m.n as RadioNode;
  m.take('properties');
  m.take('value');
  m.take('groupValue');
  m.take('enabled');
  final p = n.properties;
  final out = <String, Object?>{};
  _put(out, 'value', n.value, '');
  _put(out, 'groupValue', n.groupValue);
  _put(out, 'toggleable', p.toggleable, false);
  _put(out, 'autofocus', p.autofocus, false);
  out['activeColor'] = _rgba(p.activeColor);
  out['inactiveColor'] = _rgba(p.inactiveColor);
  out['hoverColor'] = _rgba(p.hoverColor);
  out['focusColor'] = _rgba(p.focusColor);
  _put(out, 'splashRadius', p.splashRadius, 20.0);
  if (p.side case final BorderSideModel s) out['side'] = _side(s);
  _put(out, 'innerRadius', p.innerRadius);
  if (p.backgroundColor case final ColorRGBA c) out['backgroundColor'] = _rgba(c);
  return out;
}

// --- slider -------------------------------------------------------------------

Json _slider(V1Node m) {
  final n = m.n as SliderNode;
  m.take('properties');
  m.take('value');
  m.take('markerValue');
  m.take('enabled');
  final p = n.properties;
  final out = <String, Object?>{};
  _put(out, 'value', n.value, 0.0);
  _put(out, 'min', p.min, 0.0);
  _put(out, 'max', p.max, 1.0);
  if (p.isDiscrete) _put(out, 'divisions', p.divisions);
  final indicator = switch (p.showValueIndicator) {
    null => p.showLabel ? 'onDrag' : 'never',
    final s => s.name,
  };
  out['showValueIndicator'] = indicator;
  if (indicator != 'never') out['label'] = p.label.trim().isEmpty ? r'${value}' : p.label;
  _put(out, 'labelFractionDigits', p.allowFractionalPoints ? 1 : 0, 0);
  _put(out, 'autofocus', p.autofocus, false);
  _put(out, 'secondaryTrackValue', p.secondaryTrackValue);
  if (p.padding case final EdgeInsetsModel e) out['padding'] = V1Node.insets(e);
  _put(out, 'trackHeight', p.trackHeight);
  out['activeTrackColor'] = _rgba(p.activeTrackColor);
  out['inactiveTrackColor'] = _rgba(p.inactiveTrackColor);
  if (p.secondaryActiveTrackColor case final ColorRGBA c) out['secondaryActiveTrackColor'] = _rgba(c);
  out['thumbColor'] = _rgba(p.thumbColor);
  out['overlayColor'] = _rgba(p.overlayColor);
  _put(out, 'deriveOverlayColorFromThumb', p.deriveOverlayColorFromThumb, true);
  out['activeTickMarkColor'] = _rgba(p.activeTickMarkColor);
  out['inactiveTickMarkColor'] = _rgba(p.inactiveTickMarkColor);
  out['valueIndicatorColor'] = _rgba(p.valueIndicatorColor);
  out['valueIndicatorTextStyle'] = {'color': _rgba(p.valueIndicatorTextColor), 'fontSize': roundNum(p.valueIndicatorFontSize)};
  out['valueIndicatorShape'] = p.valueIndicatorShape.name;
  _put(out, 'overlayRadius', p.overlayRadius);
  out['trackShape'] = p.trackShape.name;
  _put(out, 'thumbShape', p.thumbShape.name, 'circle');
  _put(out, 'thumbRadius', p.thumbRadius, 10.0);
  if (p.thumbWidth != 20 || p.thumbHeight != 20) out['thumbSize'] = [roundNum(p.thumbWidth), roundNum(p.thumbHeight)];
  _put(out, 'thumbCornerRadius', p.thumbCornerRadius, 4.0);
  if (p.thumbStrokeColor case final ColorRGBA c) out['thumbStrokeColor'] = _rgba(c);
  _put(out, 'thumbStrokeWidth', p.thumbStrokeWidth, 0.0);
  if (p.thumbBorderColor case final ColorRGBA c) out['thumbBorderColor'] = _rgba(c);
  _put(out, 'thumbBorderWidth', p.thumbBorderWidth, 2.0);
  if (p.thumbGripColor case final ColorRGBA c) out['thumbGripColor'] = _rgba(c);
  if (p.thumbGlowColor case final ColorRGBA c) out['thumbGlowColor'] = _rgba(c);
  _put(out, 'thumbGlowBlur', p.thumbGlowBlur, 8.0);
  _put(out, 'thumbGlowSpread', p.thumbGlowSpread, 6.0);
  _put(out, 'showThumb', p.showThumb, true);
  if (p.isDiscrete) {
    _put(out, 'tickMarkRadius', p.tickMarkRadius);
    _put(out, 'tickMarkStyle', p.tickMarkStyle.name, 'dot');
    _put(out, 'notchEvery', p.notchEvery, 1);
  }
  _put(out, 'orientation', p.orientation.name, 'horizontal');
  _put(out, 'inverted', p.inverted, false);
  _put(out, 'fillFromEnd', p.fillFromEnd, false);
  _put(out, 'activeTrackStartOpacity', p.activeTrackStartOpacity, 1.0);
  _put(out, 'markerValue', n.markerValue);
  _put(out, 'markerColor', _rgba(p.markerColor), '#FFFFFFFF');
  _put(out, 'markerWidth', p.markerWidth, 2.0);
  _put(out, 'markerHeight', p.markerHeight, 14.0);
  _put(out, 'selectableMin', p.selectableMin);
  _put(out, 'selectableMax', p.selectableMax);
  return out;
}

// --- dropdown -----------------------------------------------------------------

Json _dropdown(V1Node m) {
  final n = m.n as DropdownNode;
  m.take('properties');
  m.take('value');
  m.take('enabled');
  final p = n.properties;
  final out = <String, Object?>{};
  if (p.items.isNotEmpty) out['items'] = p.items;
  _put(out, 'value', n.value);
  _put(out, 'enabled', p.enabled, true);
  _put(out, 'isDense', p.isDense, false);
  _put(out, 'isExpanded', p.isExpanded, false);
  _put(out, 'autofocus', p.autofocus, false);
  _put(out, 'enableFeedback', p.enableFeedback, true);
  out['style'] = _style(p.itemTextStyle);
  _put(out, 'itemAlignment', _alignment(p.itemAlignment) ?? const [-1, 0]);
  out['selectedItemStyle'] = _style(p.selectedItemTextStyle);
  _put(out, 'alignment', _alignment(p.selectedItemAlignment) ?? const [-1, 0]);
  _put(out, 'hint', _nonEmpty(p.hint));
  out['hintStyle'] = _style(p.hintStyle);
  out['iconDisabledColor'] = _rgba(p.iconDisabledColor);
  out['iconEnabledColor'] = _rgba(p.iconEnabledColor);
  _put(out, 'iconSize', p.iconSize, 24.0);
  _put(out, 'icon', _icon(p.icon, size: p.iconSize));
  out['dropdownColor'] = _rgba(p.dropdownColor);
  out['focusColor'] = _rgba(p.focusColor);
  if (p.hoverColor case final ColorRGBA c) out['hoverColor'] = _rgba(c);
  if (p.splashColor case final ColorRGBA c) out['splashColor'] = _rgba(c);
  _put(out, 'elevation', p.elevation, 8);
  out['borderRadius'] = _radius(p.borderRadius);
  _put(out, 'underline', p.underline, true);
  _put(out, 'useDataSource', p.useDataSource, false);
  _put(out, 'itemLabel', p.itemLabel, '');
  _put(out, 'itemImage', p.itemImage, '');
  _put(out, 'itemImageSize', p.itemImageSize, 28.0);
  _put(out, 'itemImageRadius', p.itemImageRadius, 2.0);
  if (p.menuStyle case final DropdownMenuStyleModel s) out['menuStyle'] = _menuStyle(s);
  return out;
}

Json _menuStyle(DropdownMenuStyleModel s) {
  final t = s.selectedTextStyle;
  return {
    if (s.color case final ColorRGBA c) 'color': _rgba(c),
    if (s.border case final BorderSideModel b) 'border': _side(b),
    if (s.radius case final double r) 'radius': roundNum(r),
    if (s.shadows case final List<Effect> e) 'shadows': [...e.map(V1Node.effect).nonNulls],
    if (s.offset != 6) 'offset': roundNum(s.offset),
    if (s.maxHeight != 320) 'maxHeight': roundNum(s.maxHeight),
    if (s.minWidth != 0) 'minWidth': roundNum(s.minWidth),
    if (s.padding case final EdgeInsetsModel e) 'padding': V1Node.insets(e),
    if (s.itemPadding case final EdgeInsetsModel e) 'itemPadding': V1Node.insets(e),
    if (s.itemHeight != 40) 'itemHeight': roundNum(s.itemHeight),
    if (s.selectedItemColor case final ColorRGBA c) 'selectedItemColor': _rgba(c),
    if (s.hoverItemColor case final ColorRGBA c) 'hoverItemColor': _rgba(c),
    if (t != null)
      'selectedTextStyle': {
        if (t.fontFamily != null) 'fontFamily': t.fontFamily,
        if (t.fontWeight != null) 'fontWeight': int.parse(t.fontWeight!.name.substring(1)),
        if (t.italic == true) 'fontStyle': 'italic',
        if (t.fontSize != null) 'fontSize': roundNum(t.fontSize!),
        if (t.lineHeight != null && t.fontSize != null) 'height': t.lineHeight! / t.fontSize!,
        if (t.letterSpacing != null) 'letterSpacing': roundNum(t.letterSpacing!),
        if (t.color case final ColorRGBA c) 'color': _rgba(c),
      },
    if (s.showCheck) 'showCheck': true,
    if (s.checkPosition != DropdownCheckPosition.trailing) 'checkPosition': s.checkPosition.name,
    if (s.checkColor case final ColorRGBA c) 'checkColor': _rgba(c),
    if (s.checkSize != 18) 'checkSize': roundNum(s.checkSize),
  };
}

// --- date and time ------------------------------------------------------------

Json _datePicker(V1Node m) {
  final n = m.n as DatePickerNode;
  m.take('properties');
  m.take('value');
  m.take('enabled');
  final out = <String, Object?>{'value': n.value};
  _put(out, 'firstDate', n.properties.firstDate);
  _put(out, 'lastDate', n.properties.lastDate);
  _put(out, 'enabled', n.enabled, true);
  return out;
}

Json _timePicker(V1Node m) {
  final n = m.n as TimePickerNode;
  m.take('properties');
  m.take('value');
  m.take('enabled');
  final out = <String, Object?>{'value': n.value};
  _put(out, 'enabled', n.enabled, true);
  return out;
}

Json _dateTimeInput(V1Node m) {
  final n = m.n as DateTimeInputNode;
  m.take('properties');
  m.take('value');
  m.take('mode');
  m.take('enabled');
  final p = n.properties;
  final out = <String, Object?>{};
  _put(out, 'mode', n.mode, 'date');
  _put(out, 'value', n.value, '');
  _put(out, 'labelText', p.label);
  _put(out, 'firstDate', p.firstDate);
  _put(out, 'lastDate', p.lastDate);
  _put(out, 'min', p.min);
  _put(out, 'max', p.max);
  _put(out, 'enabled', n.enabled, true);
  return out;
}

// --- segmentedButton ----------------------------------------------------------

/// Material 3's light `ColorScheme.outline`, the side SDK 8.x drew when only
/// a width was set.
const _m3Outline = '#FF79747E';

Json _segmentedButton(V1Node m) {
  final n = m.n as SegmentedButtonNode;
  m.take('properties');
  m.take('enabled');
  final p = n.properties;
  final out = <String, Object?>{
    'segments': [
      for (final s in p.segments)
        {
          'value': s.value,
          if (s.label.isNotEmpty) 'label': s.label,
          if (s.icon case final MultiSourceIconModel i) ...{'icon': ?_icon(i)},
          if (_nonEmpty(s.tooltip) case final String t) 'tooltip': t,
          if (!s.enabled) 'enabled': false,
        },
    ],
  };
  if (p.selected.isNotEmpty) out['selected'] = p.selected;
  _put(out, 'multiSelectionEnabled', p.multiSelectionEnabled, false);
  _put(out, 'emptySelectionAllowed', p.emptySelectionAllowed, false);
  _put(out, 'showSelectedIcon', p.showSelectedIcon, true);
  if (p.selectedIcon case final MultiSourceIconModel i) _put(out, 'selectedIcon', _icon(i));
  _put(out, 'direction', p.direction.name, 'horizontal');
  _put(out, 'enabled', n.enabled, true);
  if (p.backgroundColor case final ColorRGBA c) out['backgroundColor'] = _rgba(c);
  if (p.selectedBackgroundColor case final ColorRGBA c) out['selectedBackgroundColor'] = _rgba(c);
  if (p.foregroundColor case final ColorRGBA c) out['foregroundColor'] = _rgba(c);
  if (p.selectedForegroundColor case final ColorRGBA c) out['selectedForegroundColor'] = _rgba(c);
  if (p.borderColor != null || p.borderWidth != 1) {
    out['side'] = {
      'color': p.borderColor == null ? _m3Outline : _rgba(p.borderColor!),
      if (p.borderWidth != 1) 'width': roundNum(p.borderWidth),
    };
  }
  out['borderRadius'] = _radius(p.cornerRadius);
  return out;
}

// --- signature ----------------------------------------------------------------

List<Object> _strokes(List<List<List<double>>> strokes) => [
      for (final s in strokes) [for (final pt in s) [roundNum(pt[0]), roundNum(pt[1])]],
    ];

Json _signature(V1Node m) {
  m.take('properties');
  m.take('value');
  m.take('strokes');
  m.take('signatureKind');
  m.take('enabled');
  final out = <String, Object?>{};
  switch (m.n) {
    case final SignatureNode n:
      final p = n.properties;
      if (n.value.isNotEmpty) out['value'] = _strokes(n.value);
      _put(out, 'inkColor', _rgba(p.inkColor), '#FF13306B');
      _put(out, 'inkWidth', p.inkWidth, 2.6);
      _put(out, 'backgroundColor', _rgba(p.backgroundColor), '#FFF8F8F5');
      _put(out, 'borderColor', _rgba(p.borderColor), '#FFA9ADA5');
      _put(out, 'borderWidth', p.borderWidth, 1.5);
      _put(out, 'errorBorderColor', _rgba(p.errorBorderColor), '#FFD3302F');
      _put(out, 'errorBorderWidth', p.errorBorderWidth, 2.0);
      _put(out, 'borderRadius', _radius(p.cornerRadius), 4);
      _put(out, 'placeholder', p.placeholder, 'SIGN HERE');
      _put(out, 'placeholderColor', _rgba(p.placeholderColor), '#FFA9ADA5');
      _put(out, 'placeholderFontSize', p.placeholderFontSize, 12.0);
      _put(out, 'showSignLine', p.showSignLine, true);
      _put(out, 'signLineColor', _rgba(p.signLineColor), '#FFA9ADA5');
      _put(out, 'error', p.error, false);
      _put(out, 'enabled', p.enabled, true);
    case final SignatureNormalizedNode n:
      // A bare pad: ink only.
      final p = n.properties;
      out['normalized'] = true;
      if (n.strokes.isNotEmpty) out['value'] = _strokes(n.strokes);
      out['inkColor'] = _rgba(p.inkColor);
      _put(out, 'inkWidth', p.strokeWidth, 2.6);
      out['backgroundColor'] = '#00000000';
      out['borderWidth'] = 0;
      out['borderRadius'] = 0;
      out['placeholder'] = '';
      out['showSignLine'] = false;
      _put(out, 'readOnly', p.readOnly, false);
      _put(out, 'enabled', n.enabled, true);
  }
  return out;
}
