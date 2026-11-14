// Widget declarations: inputs. One WidgetSpec per type; props with Flutter's
// names and defaults (see ../props.dart). Value types are in inputs_models.dart.
import '../behavior_fields.dart' show AnimationCurveCodec;
import '../behaviors.dart' show AnimationCurve;
import '../json.dart';
import '../props.dart';
import '../values/border.dart';
import '../values/color.dart';
import '../values/enums.dart';
import '../values/geometry.dart';
import '../values/paint.dart';
import '../values/text.dart';
import 'inputs_models.dart';

export 'inputs_models.dart';

const List<WidgetSpec> inputsSpecs = [
  TextFieldProps.spec,
  CheckboxProps.spec,
  SwitchProps.spec,
  RadioProps.spec,
  SliderProps.spec,
  DropdownProps.spec,
  DatePickerProps.spec,
  TimePickerProps.spec,
  DateTimeInputProps.spec,
  SegmentedButtonProps.spec,
  SignatureProps.spec,
];

// --- textField ----------------------------------------------------------------

/// Flutter's `TextInputType`.
enum TextInputType {
  text,
  multiline,
  number,
  phone,
  datetime,
  emailAddress,
  url,
  visiblePassword,
  name,
  streetAddress,
  none,
  webSearch,
  twitter,
}

/// Flutter's `TextInputAction`.
enum TextInputAction {
  none,
  unspecified,
  done,
  go,
  search,
  send,
  next,
  previous,
  continueAction,
  join,
  route,
  emergencyCall,
  newline,
}

/// Flutter's `TextCapitalization`.
enum TextCapitalization { none, words, sentences, characters }

/// Flutter's `BoxHeightStyle` (selection boxes).
enum BoxHeightStyle { tight, max, includeLineSpacingMiddle, includeLineSpacingTop, includeLineSpacingBottom, strut }

/// Flutter's `BoxWidthStyle` (selection boxes).
enum BoxWidthStyle { tight, max }


/// Flutter `TextField` (a `TextFormField` when it validates).
abstract final class TextFieldProps {
  /// The text it starts with (`TextFormField.initialValue`).
  static const initialValue = PropDef<String>('initialValue', Codecs.string, '');
  /// The field's label, hint, helper and error texts, border (per state), fill, padding and icons (Flutter's
  /// `InputDecoration`).
  static const decoration = PropDef<InputDecoration>('decoration', InputCodecs.decoration, InputDecoration.empty);

  /// The typed text's style; unset is the theme's.
  static const style = PropDef<TextStyle>('style', Codecs.textStyle, TextStyle.empty);
  static const textAlign = PropDef<TextAlign>('textAlign', EnumCodec(TextAlign.values), TextAlign.start);
  static const textAlignVertical =
      PropDef<TextAlignVertical?>('textAlignVertical', EnumCodec(TextAlignVertical.values), null);
  /// The on-screen keyboard to show (Flutter's `TextInputType`): `text`, `number`, `emailAddress`, `phone`, `url`,
  /// `multiline`...
  static const keyboardType = PropDef<TextInputType>('keyboardType', EnumCodec(TextInputType.values), TextInputType.text);

  /// A number keyboard with a decimal point (`TextInputType.numberWithOptions(decimal: true)`).
  static const keyboardDecimal = PropDef<bool>('keyboardDecimal', Codecs.bool, false);

  /// A number keyboard with a sign key (`TextInputType.numberWithOptions(signed: true)`).
  static const keyboardSigned = PropDef<bool>('keyboardSigned', Codecs.bool, false);
  static const textInputAction =
      PropDef<TextInputAction?>('textInputAction', EnumCodec(TextInputAction.values), null);
  static const textCapitalization =
      PropDef<TextCapitalization>('textCapitalization', EnumCodec(TextCapitalization.values), TextCapitalization.none);
  static const autocorrect = PropDef<bool>('autocorrect', Codecs.bool, true);
  static const autofocus = PropDef<bool>('autofocus', Codecs.bool, false);
  static const enableInteractiveSelection = PropDef<bool>('enableInteractiveSelection', Codecs.bool, true);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  /// Hides what is typed (a password field).
  static const obscureText = PropDef<bool>('obscureText', Codecs.bool, false);
  static const obscuringCharacter = PropDef<String>('obscuringCharacter', Codecs.string, '•');
  static const readOnly = PropDef<bool>('readOnly', Codecs.bool, false);
  static const showCursor = PropDef<bool?>('showCursor', Codecs.bool, null);
  static const cursorColor = PropDef<Color?>('cursorColor', Codecs.color, null);
  static const cursorHeight = PropDef<double?>('cursorHeight', Codecs.positive, null);
  static const cursorWidth = PropDef<double>('cursorWidth', Codecs.positive, 2);

  /// `Radius.circular(cursorRadius)`.
  static const cursorRadius = PropDef<double?>('cursorRadius', Codecs.positive, null);
  static const maxLength = PropDef<int?>('maxLength', OptionalIntCodec(), null);

  /// 0: no limit (Flutter's `maxLines: null`).
  static const maxLines = PropDef<int>('maxLines', IntCodec(min: 0), 1);
  static const minLines = PropDef<int?>('minLines', OptionalIntCodec(), null);
  static const expands = PropDef<bool>('expands', Codecs.bool, false);
  static const selectionHeightStyle =
      PropDef<BoxHeightStyle>('selectionHeightStyle', EnumCodec(BoxHeightStyle.values), BoxHeightStyle.tight);
  static const selectionWidthStyle =
      PropDef<BoxWidthStyle>('selectionWidthStyle', EnumCodec(BoxWidthStyle.values), BoxWidthStyle.tight);

  /// `AutofillHints` names (`email`, `password`...).
  static const autofillHints = PropDef<List<String>>('autofillHints', InputCodecs.strings, []);
  static const autovalidateMode =
      PropDef<AutovalidateMode>('autovalidateMode', EnumCodec(AutovalidateMode.values), AutovalidateMode.disabled);

  /// Selects the whole text when the field gains focus.
  static const selectAllOnFocus = PropDef<bool>('selectAllOnFocus', Codecs.bool, false);

  /// A ring drawn around the field while it has focus.
  static const focusRingColor = PropDef<Color?>('focusRingColor', Codecs.color, null);
  static const focusRingWidth = PropDef<double>('focusRingWidth', Codecs.positive, 0);

  /// The input formatter (`{"type": "none"|"email"|"phone"|..., ...}`).
  static const inputFormatter = PropDef<Json>('inputFormatter', InputCodecs.json, {});

  /// Flutter's `TextFormField.validator`, `(value) => String?`: an
  /// expression that reads the field's text as `value` and gives the error
  /// to show under the field, or nothing (empty, null) when it is valid:
  /// `"${= value == '' ? 'Enter your email.' : ''}"`. The field shows it
  /// when its form is validated, and as [autovalidateMode] says.
  static const validator = PropDef<String>('validator', ValueCodec(_validatorIn, _same, PropType.string()), '',
      doc: 'Flutter\'s TextFormField.validator: an expression reading the text as `value`, giving the error or "" when valid.');

  /// Markdown highlighting of the typed text.
  static const markdown = PropDef<Json?>('markdown', InputCodecs.json, null);

  /// Styled ranges over the typed text, merged over [style], as a text's
  /// `runs` are over its text (Flutter's
  /// `TextEditingController.buildTextSpan`): a syntax error's place drawn in
  /// red. A range past the text's end is cut at it; while a word is being
  /// composed the text is drawn plain.
  static const runs = PropDef<List<TextRun>>('runs', Codecs.textRuns, []);

  static const spec = WidgetSpec('textField', hugs: true, props: [
    initialValue, decoration, style, textAlign, textAlignVertical, keyboardType, keyboardDecimal, keyboardSigned, //
    textInputAction, textCapitalization, autocorrect, autofocus, enableInteractiveSelection, enabled, obscureText,
    obscuringCharacter, readOnly, showCursor, cursorColor, cursorHeight, cursorWidth, cursorRadius, maxLength,
    maxLines, minLines, expands, selectionHeightStyle, selectionWidthStyle, autofillHints, autovalidateMode,
    selectAllOnFocus, focusRingColor, focusRingWidth, inputFormatter, validator, markdown, runs,
  ], doc: 'Flutter `TextField`. Leave its height to hug: every input (text field, dropdown, date and time picker) is then the same control height (28); a fixed height picks another step of the control scale (24, 28, 32, 36, 44) and should be the same on the inputs beside it.');
}

// --- checkbox, switch, radio --------------------------------------------------

/// Flutter `Checkbox`, scaled to its box (40 px is Flutter's own size,
/// 18 px when [compact]).
abstract final class CheckboxProps {
  /// Null is the indeterminate state (with [tristate]).
  static const value = PropDef<bool?>('value', Codecs.bool, null);
  static const tristate = PropDef<bool>('tristate', Codecs.bool, false);
  static const autofocus = PropDef<bool>('autofocus', Codecs.bool, false);
  static const checkColor = PropDef<Color?>('checkColor', Codecs.color, null);
  /// The box's fill when checked.
  static const activeColor = PropDef<Color?>('activeColor', Codecs.color, null);
  static const hoverColor = PropDef<Color?>('hoverColor', Codecs.color, null);
  static const focusColor = PropDef<Color?>('focusColor', Codecs.color, null);
  static const splashRadius = PropDef<double?>('splashRadius', Codecs.positive, null);

  /// The box's corners (`shape: RoundedRectangleBorder(borderRadius)`).
  static const borderRadius = PropDef<BorderRadius?>('borderRadius', InputCodecs.radius, null);
  static const side = PropDef<BorderSide?>('side', InputCodecs.borderSide, null);

  /// The border when checked (a `WidgetStateBorderSide`); null keeps [side].
  static const activeSide = PropDef<BorderSide?>('activeSide', InputCodecs.borderSide, null);

  /// The box's fill when unchecked (`fillColor` for the unselected states);
  /// [activeColor] fills it checked. Null keeps Flutter's (transparent).
  static const fillColor = PropDef<Color?>('fillColor', Codecs.optionalColor, null);

  /// Its box is the checkbox itself (18 px), not its tap target (40 px).
  /// The box and its check mark scale to the node, but its [borderRadius]
  /// and sides' widths are node pixels.
  static const compact = PropDef<bool>('compact', Codecs.bool, false);

  /// Text beside it (SSUI's label; Flutter has `CheckboxListTile` for
  /// this): tapping it toggles too, and it names the control to a screen
  /// reader. Empty: the bare control.
  static const label = PropDef<String>('label', Codecs.string, '');

  static const spec = WidgetSpec('checkbox', hugs: true, props: [
    label, value, tristate, autofocus, checkColor, activeColor, hoverColor, focusColor, splashRadius, borderRadius, side, //
    activeSide, fillColor, compact,
  ], doc: 'Flutter `Checkbox`.');
}

/// Flutter `Switch`, scaled to its box (59 px wide is Flutter's own size).
abstract final class SwitchProps {
  /// Whether the switch is on. Bind it to a variable and store the `changed` value in that variable.
  static const value = PropDef<bool>('value', Codecs.bool, false);
  static const autofocus = PropDef<bool>('autofocus', Codecs.bool, false);
  /// The track's color when on.
  static const activeTrackColor = PropDef<Color?>('activeTrackColor', Codecs.color, null);
  static const inactiveTrackColor = PropDef<Color?>('inactiveTrackColor', Codecs.color, null);
  static const activeThumbColor = PropDef<Color?>('activeThumbColor', Codecs.color, null);
  static const inactiveThumbColor = PropDef<Color?>('inactiveThumbColor', Codecs.color, null);
  static const hoverColor = PropDef<Color?>('hoverColor', Codecs.color, null);
  static const focusColor = PropDef<Color?>('focusColor', Codecs.color, null);
  static const splashRadius = PropDef<double?>('splashRadius', Codecs.positive, null);

  /// `trackOutlineColor` when on.
  static const activeTrackOutlineColor = PropDef<Color?>('activeTrackOutlineColor', Codecs.color, null);

  /// `trackOutlineColor` when off.
  static const inactiveTrackOutlineColor = PropDef<Color?>('inactiveTrackOutlineColor', Codecs.color, null);
  static const trackOutlineWidth = PropDef<double?>('trackOutlineWidth', Codecs.positive, null);

  /// The thumb keeps one size on and off (`thumbIcon` set).
  static const uniformThumb = PropDef<bool>('uniformThumb', Codecs.bool, false);

  /// The track is stretched to the box (no padding or tap target around it).
  static const fillTrack = PropDef<bool>('fillTrack', Codecs.bool, false);

  /// Drop shadows the thumb casts on a filled track ([fillTrack]).
  /// Material's switch has none, so a switch with one is drawn as a plain
  /// toggle (see [thumbInset]).
  static const thumbShadows = PropDef<List<Effect>>('thumbShadows', Codecs.effects, []);

  /// The gap between the thumb and the edges of a filled track: the thumb
  /// is the height less twice this. With one (or [thumbShadows]) the switch
  /// is a plain toggle whose thumb stays round at any size; null keeps
  /// Material's switch scaled to the box.
  static const thumbInset = PropDef<double?>('thumbInset', Codecs.optionalPositive, null);

  /// Off, it shows its value but can't be toggled (dimmed, as Flutter's).
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);

  /// It shows only its value: a tap reports the change (`changed`) and the
  /// reactions set the value, else it stays (a checkout rule that refuses).
  static const controlled = PropDef<bool>('controlled', Codecs.bool, false);

  /// The thumb's border color when on, drawn inside its edge on a filled
  /// track ([fillTrack]). Material's switch has no thumb border, so a
  /// switch with one is drawn as a plain toggle.
  static const activeThumbBorderColor = PropDef<Color?>('activeThumbBorderColor', Codecs.color, null);

  /// The thumb's border color when off (see [activeThumbBorderColor]).
  static const inactiveThumbBorderColor = PropDef<Color?>('inactiveThumbBorderColor', Codecs.color, null);

  /// The thumb border's width; null is 1.
  static const thumbBorderWidth = PropDef<double?>('thumbBorderWidth', Codecs.positive, null);

  /// How long a plain toggle's thumb takes to slide, in milliseconds.
  static const toggleDurationMs = PropDef<int>('toggleDurationMs', IntCodec(min: 0), 220);

  /// A plain toggle's slide easing on; off eases along it flipped.
  static const toggleCurve = PropDef<AnimationCurve>('toggleCurve', AnimationCurveCodec(), AnimationCurve.easeOutCubic);

  /// The track's corner radius: null is a pill (half its height); a square
  /// switch sets a small one. With it the switch is a plain toggle.
  static const trackRadius = PropDef<double?>('trackRadius', Codecs.optionalPositive, null);

  /// The thumb's corner radius: null is round; a square switch sets a small
  /// one. With it the switch is a plain toggle.
  static const thumbRadius = PropDef<double?>('thumbRadius', Codecs.optionalPositive, null);

  /// Text beside it (SSUI's label; Flutter has `CheckboxListTile` for
  /// this): tapping it toggles too, and it names the control to a screen
  /// reader. Empty: the bare control.
  static const label = PropDef<String>('label', Codecs.string, '');

  static const spec = WidgetSpec('switch', hugs: true, props: [
    label, enabled, controlled, value, autofocus, activeTrackColor, inactiveTrackColor, activeThumbColor, inactiveThumbColor, hoverColor, //
    focusColor, splashRadius, activeTrackOutlineColor, inactiveTrackOutlineColor, trackOutlineWidth, uniformThumb,
    fillTrack, thumbShadows, thumbInset, activeThumbBorderColor, inactiveThumbBorderColor, thumbBorderWidth,
    toggleDurationMs, toggleCurve, trackRadius, thumbRadius,
  ], doc: 'Flutter `Switch`.');
}

/// Flutter `Radio<String>`, scaled to its box (32 px is its own size; its
/// ring, 18 px, when [compact]).
abstract final class RadioProps {
  /// The value this radio stands for; it is selected when `groupValue` equals it.
  static const value = PropDef<String>('value', Codecs.string, '');

  /// The group's selected value; this radio is on when it equals [value].
  static const groupValue = PropDef<String?>('groupValue', Codecs.string, null);
  static const toggleable = PropDef<bool>('toggleable', Codecs.bool, false);
  static const autofocus = PropDef<bool>('autofocus', Codecs.bool, false);
  /// The dot's color when selected.
  static const activeColor = PropDef<Color?>('activeColor', Codecs.color, null);

  /// `fillColor` when not selected.
  static const inactiveColor = PropDef<Color?>('inactiveColor', Codecs.color, null);
  static const hoverColor = PropDef<Color?>('hoverColor', Codecs.color, null);
  static const focusColor = PropDef<Color?>('focusColor', Codecs.color, null);
  static const splashRadius = PropDef<double?>('splashRadius', Codecs.positive, null);
  static const side = PropDef<BorderSide?>('side', InputCodecs.borderSide, null);
  static const innerRadius = PropDef<double?>('innerRadius', Codecs.positive, null);
  static const backgroundColor = PropDef<Color?>('backgroundColor', Codecs.color, null);

  /// The ring fills the box (no tap padding around it), as a compact
  /// checkbox's square does: an 18 px radio is an 18 px ring.
  static const compact = PropDef<bool>('compact', Codecs.bool, false);

  /// Text beside it (SSUI's label; Flutter has `CheckboxListTile` for
  /// this): tapping it toggles too, and it names the control to a screen
  /// reader. Empty: the bare control.
  static const label = PropDef<String>('label', Codecs.string, '');

  static const spec = WidgetSpec('radio', hugs: true, props: [
    label, value, groupValue, toggleable, autofocus, activeColor, inactiveColor, hoverColor, focusColor, splashRadius, side, //
    innerRadius, backgroundColor, compact,
  ], doc: 'Flutter `Radio`.');
}

// --- slider -------------------------------------------------------------------

/// Flutter's `ShowValueIndicator`.
enum ShowValueIndicator { onlyForDiscrete, onlyForContinuous, onDrag, alwaysVisible, never }

/// The slider's thumb (`SliderThemeData.thumbShape`).
enum SliderThumbShape {
  /// `RoundSliderThumbShape(enabledThumbRadius: thumbRadius)`.
  circle,

  /// A rounded rectangle of [SliderProps.thumbSize].
  roundedRect,

  /// A rectangle of [SliderProps.thumbSize] with an optional border.
  rectangle,

  /// A drafting ruler's index: a hairline across the track and a triangle
  /// pointing up at it from below, in the thumb color, outlined in
  /// [SliderProps.thumbStrokeColor] (default black).
  pointer,
}

/// The slider's track (`SliderThemeData.trackShape`).
enum SliderTrackShape {
  rectangle,
  roundedRectangle,
  gapped,

  /// A ruler: a strip in the inactive track color, and the active color
  /// filled from zero (or the minimum) to the value under it. It spans the
  /// slider's whole width. Its ticks are drawn with the node's
  /// `customPaint` (the `painter` draws over the track: `size` is the
  /// slider's box).
  ruler,
}

/// The value indicator (`SliderThemeData.valueIndicatorShape`).
enum SliderValueIndicatorShape { rectangle, paddle, drop, roundedRectangle }

/// The tick marks of a discrete slider.
enum SliderTickMarkStyle {
  /// `RoundSliderTickMarkShape(tickMarkRadius)`.
  dot,

  /// Thin notches across the track, every [SliderProps.notchEvery] division.
  notch,
}

/// Flutter `Slider` with its `SliderThemeData`, at its box's design size.
abstract final class SliderProps {
  /// The current value, between `min` and `max`. Bind it to a variable and store the `changed` value in that
  /// variable.
  static const value = PropDef<double>('value', Codecs.double, 0);
  /// The value at the start of the track.
  static const min = PropDef<double>('min', Codecs.double, 0);
  /// The value at the end of the track.
  static const max = PropDef<double>('max', Codecs.double, 1);
  /// Snaps to this many equal steps between `min` and `max`. Null: continuous.
  static const divisions = PropDef<int?>('divisions', OptionalIntCodec(), null);

  /// The value indicator's text; `${value}` is the value.
  static const label = PropDef<String?>('label', Codecs.string, null);

  /// Decimals of `${value}` in [label].
  static const labelFractionDigits = PropDef<int>('labelFractionDigits', IntCodec(min: 0), 0);
  static const autofocus = PropDef<bool>('autofocus', Codecs.bool, false);
  static const secondaryTrackValue = PropDef<double?>('secondaryTrackValue', Codecs.double, null);
  static const padding = PropDef<EdgeInsets?>('padding', Codecs.insets, null);

  // SliderThemeData.
  static const trackHeight = PropDef<double?>('trackHeight', Codecs.positive, null);
  /// The track's color from `min` to the thumb.
  static const activeTrackColor = PropDef<Color?>('activeTrackColor', Codecs.color, null);
  static const inactiveTrackColor = PropDef<Color?>('inactiveTrackColor', Codecs.color, null);
  static const secondaryActiveTrackColor = PropDef<Color?>('secondaryActiveTrackColor', Codecs.color, null);
  static const thumbColor = PropDef<Color?>('thumbColor', Codecs.color, null);
  static const overlayColor = PropDef<Color?>('overlayColor', Codecs.color, null);

  static const activeTickMarkColor = PropDef<Color?>('activeTickMarkColor', Codecs.color, null);
  static const inactiveTickMarkColor = PropDef<Color?>('inactiveTickMarkColor', Codecs.color, null);
  static const valueIndicatorColor = PropDef<Color?>('valueIndicatorColor', Codecs.color, null);
  static const valueIndicatorTextStyle =
      PropDef<TextStyle>('valueIndicatorTextStyle', Codecs.textStyle, TextStyle.empty);
  static const showValueIndicator =
      PropDef<ShowValueIndicator?>('showValueIndicator', EnumCodec(ShowValueIndicator.values), null);
  static const valueIndicatorShape = PropDef<SliderValueIndicatorShape?>(
      'valueIndicatorShape', EnumCodec(SliderValueIndicatorShape.values), null);

  /// `RoundSliderOverlayShape(overlayRadius)`.
  static const overlayRadius = PropDef<double?>('overlayRadius', Codecs.positive, null);
  static const trackShape = PropDef<SliderTrackShape?>('trackShape', EnumCodec(SliderTrackShape.values), null);
  static const thumbShape = PropDef<SliderThumbShape>('thumbShape', EnumCodec(SliderThumbShape.values), SliderThumbShape.circle);

  /// A circle thumb's radius.
  static const thumbRadius = PropDef<double>('thumbRadius', Codecs.positive, 10);

  /// A rectangular thumb's size, `[width, height]` (along a horizontal track).
  static const thumbSize = PropDef<Offset>('thumbSize', Codecs.offset, Offset(20, 20));
  static const thumbCornerRadius = PropDef<double>('thumbCornerRadius', Codecs.positive, 4);
  static const thumbStrokeColor = PropDef<Color?>('thumbStrokeColor', Codecs.color, null);
  static const thumbStrokeWidth = PropDef<double>('thumbStrokeWidth', Codecs.positive, 0);
  static const thumbBorderColor = PropDef<Color?>('thumbBorderColor', Codecs.color, null);
  static const thumbBorderWidth = PropDef<double>('thumbBorderWidth', Codecs.positive, 2);

  /// A blurred glow behind the thumb.
  static const thumbGlowColor = PropDef<Color?>('thumbGlowColor', Codecs.color, null);
  static const thumbGlowBlur = PropDef<double>('thumbGlowBlur', Codecs.positive, 8);
  static const thumbGlowSpread = PropDef<double>('thumbGlowSpread', Codecs.positive, 6);
  static const showThumb = PropDef<bool>('showThumb', Codecs.bool, true);
  static const tickMarkRadius = PropDef<double?>('tickMarkRadius', Codecs.positive, null);
  static const tickMarkStyle =
      PropDef<SliderTickMarkStyle>('tickMarkStyle', EnumCodec(SliderTickMarkStyle.values), SliderTickMarkStyle.dot);
  static const notchEvery = PropDef<int>('notchEvery', IntCodec(min: 1), 1);

  /// Vertical runs bottom (min) to top (max).
  static const orientation = PropDef<Axis>('orientation', EnumCodec(Axis.values), Axis.horizontal);

  /// Runs from the end (right, or top when vertical) instead.
  static const inverted = PropDef<bool>('inverted', Codecs.bool, false);

  /// The active track runs from the thumb to the end.
  static const fillFromEnd = PropDef<bool>('fillFromEnd', Codecs.bool, false);

  /// The part of the track the thumb can be dragged within.
  static const selectableMin = PropDef<double?>('selectableMin', Codecs.double, null);
  static const selectableMax = PropDef<double?>('selectableMax', Codecs.double, null);

  static const spec = WidgetSpec('slider', hugs: true, props: [
    value, min, max, divisions, label, labelFractionDigits, autofocus, secondaryTrackValue, padding, trackHeight, //
    activeTrackColor, inactiveTrackColor, secondaryActiveTrackColor, thumbColor, overlayColor, activeTickMarkColor,
    inactiveTickMarkColor, valueIndicatorColor, valueIndicatorTextStyle, showValueIndicator, valueIndicatorShape,
    overlayRadius, trackShape, thumbShape, thumbRadius, thumbSize, thumbCornerRadius, thumbStrokeColor,
    thumbStrokeWidth, thumbBorderColor, thumbBorderWidth, thumbGlowColor, thumbGlowBlur,
    thumbGlowSpread, showThumb, tickMarkRadius, tickMarkStyle, notchEvery, orientation, inverted, fillFromEnd,
    selectableMin, selectableMax,
  ], doc: 'Flutter `Slider`.');
}


// --- dropdown -----------------------------------------------------------------

/// Flutter `DropdownButton<Object>`. Its padding is the node's
/// `layout.padding`.
abstract final class DropdownProps {
  /// The items (their labels), unless [useDataSource].
  static const items = PropDef<List<String>>('items', InputCodecs.strings, []);

  /// The selected item.
  static const value = PropDef<Object?>('value', InputCodecs.any, null);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const isDense = PropDef<bool>('isDense', Codecs.bool, false);
  static const isExpanded = PropDef<bool>('isExpanded', Codecs.bool, false);
  static const autofocus = PropDef<bool>('autofocus', Codecs.bool, false);
  static const enableFeedback = PropDef<bool?>('enableFeedback', Codecs.bool, null);

  /// The menu items' text (`style`).
  static const style = PropDef<TextStyle>('style', Codecs.textStyle, TextStyle.empty);

  /// The menu items' alignment.
  static const itemAlignment = PropDef<Alignment>('itemAlignment', InputCodecs.alignment, Alignment(-1, 0));

  /// The selected item's text in the button.
  static const selectedItemStyle = PropDef<TextStyle>('selectedItemStyle', Codecs.textStyle, TextStyle.empty);

  /// The selected item's alignment in the button.
  static const alignment = PropDef<Alignment>('alignment', InputCodecs.alignment, Alignment(-1, 0));
  /// The text shown while no item is selected.
  static const hint = PropDef<String?>('hint', Codecs.string, null);
  static const hintStyle = PropDef<TextStyle>('hintStyle', Codecs.textStyle, TextStyle.empty);
  static const iconDisabledColor = PropDef<Color?>('iconDisabledColor', Codecs.color, null);
  static const iconEnabledColor = PropDef<Color?>('iconEnabledColor', Codecs.color, null);
  static const iconSize = PropDef<double>('iconSize', Codecs.positive, 24);

  /// The arrow; unset is Flutter's `Icons.arrow_drop_down`.
  static const icon = PropDef<InputIcon?>('icon', InputCodecs.icon, null);
  static const dropdownColor = PropDef<Color?>('dropdownColor', Codecs.color, null);
  static const focusColor = PropDef<Color?>('focusColor', Codecs.color, null);
  static const hoverColor = PropDef<Color?>('hoverColor', Codecs.color, null);
  static const splashColor = PropDef<Color?>('splashColor', Codecs.color, null);
  static const elevation = PropDef<int>('elevation', IntCodec(min: 0), 8);
  static const borderRadius = PropDef<BorderRadius?>('borderRadius', InputCodecs.radius, null);

  /// Draws the field's border: the theme's field shape (an outline of the
  /// control radius, as an unstyled text field's) around the button, padded
  /// 12 at the sides when the node sets no padding; false: no border
  /// (`underline: SizedBox.shrink()`). Material's underline is never drawn.
  static const underline = PropDef<bool>('underline', Codecs.bool, true);

  /// The items come from the bound `data` list; [itemLabel] labels each
  /// (`${item.name}`).
  static const useDataSource = PropDef<bool>('useDataSource', Codecs.bool, false);
  static const itemLabel = PropDef<String>('itemLabel', Codecs.string, '');

  /// An image before each item's label (a URL, may use `${item}`).
  static const itemImage = PropDef<String>('itemImage', Codecs.string, '');
  static const itemImageSize = PropDef<double>('itemImageSize', Codecs.positive, 28);
  static const itemImageRadius = PropDef<double>('itemImageRadius', Codecs.positive, 2);

  /// A card menu anchored under the button instead of Flutter's route menu:
  /// `{"color", "radius", "border", "shadows", "maxHeight", "minWidth",
  /// "offset", "itemHeight", "itemPadding", "padding", "selectedItemColor",
  /// "hoverItemColor", "selectedTextStyle", "showCheck", "checkPosition",
  /// "checkColor", "checkSize"}`.
  static const menuStyle = PropDef<Json?>('menuStyle', InputCodecs.json, null);

  static const spec = WidgetSpec('dropdown', hugs: true, props: [
    items, value, enabled, isDense, isExpanded, autofocus, enableFeedback, style, itemAlignment, selectedItemStyle, //
    alignment, hint, hintStyle, iconDisabledColor, iconEnabledColor, iconSize, icon, dropdownColor, focusColor,
    hoverColor, splashColor, elevation, borderRadius, underline, useDataSource, itemLabel, itemImage, itemImageSize,
    itemImageRadius, menuStyle,
  ], decorated: true, doc: 'Flutter `DropdownButton`; its fill, border, shadow and padding draw a box around it. Leave its height to hug: every input (text field, dropdown, date and time picker) is then the same control height (28); a fixed height picks another step of the control scale (24, 28, 32, 36, 44) and should be the same on the inputs beside it.');
}

// --- date and time ------------------------------------------------------------

/// The look of a date or time picker: by default the design system's select
/// field (a calendar or clock icon, the value, a chevron); with a
/// [PickerFieldProps.decoration] the decoration's border, fill, hint and
/// icons. The value shows in [PickerFieldProps.format]. Tapping opens the
/// picker (a calendar, or hour and minute columns) under the field, or as a
/// bottom sheet on a narrow screen, themed by [PickerFieldProps.pickerTheme].
abstract final class PickerFieldProps {
  /// How the value shows: an intl `DateFormat` pattern (`EEE d MMM yyyy`,
  /// `HH:mm`); empty shows `yyyy-MM-dd` / `HH:mm`.
  static const format = PropDef<String>('format', Codecs.string, '');
  static const style = PropDef<TextStyle>('style', Codecs.textStyle, TextStyle.empty);

  /// A field's decoration (as a text field's); empty keeps the button.
  static const decoration = PropDef<InputDecoration>('decoration', InputCodecs.decoration, InputDecoration.empty);

  /// The picker's title (`showDatePicker`'s `helpText`); empty: none.
  static const helpText = PropDef<String>('helpText', Codecs.string, '');

  /// The picker dialog's look: `{backgroundColor, accentColor, onAccentColor,
  /// textColor, mutedColor, dividerColor, radius, dayRadius, fontFamily,
  /// headlineStyle}` (colors `#AARRGGBB`, `headlineStyle` a text style).
  static const pickerTheme = PropDef<Json?>('pickerTheme', InputCodecs.json, null);

  static const List<PropDef<Object?>> all = [format, style, decoration, helpText, pickerTheme];
}

/// A field showing a date (`yyyy-MM-dd`; empty shows its hint) that opens a
/// calendar (Flutter's `showDatePicker`).
abstract final class DatePickerProps {
  static const value = PropDef<String>('value', Codecs.string, '');
  static const firstDate = PropDef<String?>('firstDate', Codecs.string, null);
  static const lastDate = PropDef<String?>('lastDate', Codecs.string, null);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const spec = WidgetSpec('datePicker', hugs: true,
      props: [value, firstDate, lastDate, enabled, ...PickerFieldProps.all], doc: 'Flutter `showDatePicker` button or field. Leave its height to hug: every input (text field, dropdown, date and time picker) is then the same control height (28); a fixed height picks another step of the control scale (24, 28, 32, 36, 44) and should be the same on the inputs beside it.');
}

/// A field showing a time (`HH:mm`; empty shows its hint) that opens hour and
/// minute columns (Flutter's `showTimePicker`).
abstract final class TimePickerProps {
  static const value = PropDef<String>('value', Codecs.string, '');
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);

  /// The picker's dial and fields in 24-hour time (Flutter's
  /// `MediaQueryData.alwaysUse24HourFormat`, which the picker reads).
  static const alwaysUse24HourFormat = PropDef<bool>('alwaysUse24HourFormat', Codecs.bool, false);
  static const spec = WidgetSpec('timePicker', hugs: true,
      props: [value, enabled, alwaysUse24HourFormat, ...PickerFieldProps.all], doc: 'Flutter `showTimePicker` button or field. Leave its height to hug: every input (text field, dropdown, date and time picker) is then the same control height (28); a fixed height picks another step of the control scale (24, 28, 32, 36, 44) and should be the same on the inputs beside it.');
}

/// What a date/time input picks.
enum DateTimeInputMode { date, time, dateTime }

/// What tapping a date/time input opens: the date and time pickers, or
/// nothing (its own click reactions show a picker the design builds, and set
/// its value).
enum DateTimeInputPicker { dialog, none }

/// A field (Flutter's `InputDecorator`) showing a date, time or both, that
/// opens the pickers.
abstract final class DateTimeInputProps {
  static const mode = PropDef<DateTimeInputMode>('mode', EnumCodec(DateTimeInputMode.values), DateTimeInputMode.date);

  /// ISO: `yyyy-MM-dd`, `HH:mm` or a UTC date-time.
  static const value = PropDef<String>('value', Codecs.string, '');
  static const labelText = PropDef<String?>('labelText', Codecs.string, null);
  static const firstDate = PropDef<String?>('firstDate', Codecs.string, null);
  static const lastDate = PropDef<String?>('lastDate', Codecs.string, null);

  /// The earliest and latest values accepted.
  static const min = PropDef<String?>('min', Codecs.string, null);
  static const max = PropDef<String?>('max', Codecs.string, null);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);

  /// The field's look, as a text field's (fill, borders, icons, hint, error);
  /// empty keeps the outlined default. Its hint and suffix icon win over
  /// [hint] and [icon].
  static const decoration = PropDef<InputDecoration>('decoration', InputCodecs.decoration, InputDecoration.empty);

  /// How the value reads: an `intl` pattern (`MMM d, y`, `h:mm a`); null is
  /// Material's localized date and time.
  static const format = PropDef<String?>('format', Codecs.optionalString, null);

  /// The value's text style.
  static const style = PropDef<TextStyle>('style', Codecs.textStyle, TextStyle.empty);

  /// Shown while empty (null: "Select date" / "Select time").
  static const hint = PropDef<String?>('hint', Codecs.optionalString, null);
  static const hintStyle = PropDef<TextStyle>('hintStyle', Codecs.textStyle, TextStyle.empty);

  /// The icon after the value (null: a calendar or clock).
  static const icon = PropDef<InputIcon?>('icon', InputCodecs.icon, null);

  /// Only the value and its icon, no Material field around them: the node's
  /// own fill, border and padding make the box.
  static const bare = PropDef<bool>('bare', Codecs.bool, false);

  /// Shown instead of the formatted value when set (bind it: "Now · 1:20 PM").
  static const displayText = PropDef<String>('displayText', Codecs.string, '');
  static const picker = PropDef<DateTimeInputPicker>(
      'picker', EnumCodec(DateTimeInputPicker.values), DateTimeInputPicker.dialog);

  static const spec = WidgetSpec('dateTimeInput', hugs: true,
      props: [
        mode, value, labelText, firstDate, lastDate, min, max, enabled, format, style, hint, hintStyle, icon, bare,
        decoration, displayText, picker,
      ],
      decorated: true,
      doc: 'Flutter `InputDecorator`; its fill, border, shadow and padding draw a box around it.');
}

// --- segmentedButton ----------------------------------------------------------

/// How a segmented button is drawn.
enum SegmentedVariant {
  /// Flutter's `SegmentedButton`: outlined segments with dividers.
  material,

  /// A tinted track ([SegmentedButtonProps.backgroundColor], [side],
  /// [borderRadius]) holding the segments, the selected one raised on it
  /// ([SegmentedButtonProps.selectedBackgroundColor], `selectedShadows`),
  /// with no dividers: the filter control of dashboards and toolbars.
  track,
}

/// Flutter `SegmentedButton<String>`.
abstract final class SegmentedButtonProps {
  /// The segments, in order: each a value, a label and an optional icon.
  static const segments = PropDef<List<ButtonSegment>>('segments', InputCodecs.segments, []);
  /// The values of the selected segments.
  static const selected = PropDef<List<String>>('selected', InputCodecs.strings, []);
  static const multiSelectionEnabled = PropDef<bool>('multiSelectionEnabled', Codecs.bool, false);
  static const emptySelectionAllowed = PropDef<bool>('emptySelectionAllowed', Codecs.bool, false);
  static const showSelectedIcon = PropDef<bool>('showSelectedIcon', Codecs.bool, true);
  static const selectedIcon = PropDef<InputIcon?>('selectedIcon', InputCodecs.icon, null);
  static const direction = PropDef<Axis>('direction', EnumCodec(Axis.values), Axis.horizontal);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);

  // ButtonStyle (SegmentedButton.styleFrom).
  static const textStyle = PropDef<TextStyle>('textStyle', Codecs.textStyle, TextStyle.empty);
  static const backgroundColor = PropDef<Color?>('backgroundColor', Codecs.color, null);
  static const selectedBackgroundColor = PropDef<Color?>('selectedBackgroundColor', Codecs.color, null);
  static const foregroundColor = PropDef<Color?>('foregroundColor', Codecs.color, null);
  static const selectedForegroundColor = PropDef<Color?>('selectedForegroundColor', Codecs.color, null);
  static const side = PropDef<BorderSide?>('side', InputCodecs.borderSide, null);

  /// `shape: RoundedRectangleBorder(borderRadius)`; unset is Flutter's stadium.
  static const borderRadius = PropDef<BorderRadius?>('borderRadius', InputCodecs.radius, null);

  /// Each segment's padding (`padding`); unset is Flutter's.
  static const padding = PropDef<EdgeInsets?>('padding', Codecs.insets, null);

  /// Each segment's height (`ButtonStyle.minimumSize` / `maximumSize`);
  /// unset is Flutter's 40.
  static const segmentHeight = PropDef<double?>('segmentHeight', Codecs.optionalDouble, null);

  /// The segments share the node's width equally (`expandedInsets: zero`).
  static const expanded = PropDef<bool>('expanded', Codecs.bool, false);

  /// No extra space round the segments for touch (`MaterialTapTargetSize.shrinkWrap`).
  static const shrinkTapTarget = PropDef<bool>('shrinkTapTarget', Codecs.bool, false);

  /// Material's segmented button, or a [SegmentedVariant.track].
  static const variant = PropDef<SegmentedVariant>('variant', EnumCodec(SegmentedVariant.values), SegmentedVariant.material);

  /// A track's inset around its segments.
  static const trackPadding = PropDef<double>('trackPadding', Codecs.double, 3);

  /// The shadows under a track's selected segment.
  static const selectedShadows = PropDef<List<Effect>>('selectedShadows', Codecs.effects, []);

  /// A track's selection is one thumb that slides between its segments
  /// (single selection, horizontal, segments sharing the width); otherwise
  /// each segment fills in place.
  static const slidingThumb = PropDef<bool>('slidingThumb', Codecs.bool, false);

  static const spec = WidgetSpec('segmentedButton', hugs: true, props: [
    segments, selected, multiSelectionEnabled, emptySelectionAllowed, showSelectedIcon, selectedIcon, direction, //
    enabled, textStyle, backgroundColor, selectedBackgroundColor, foregroundColor, selectedForegroundColor, side, borderRadius,
    padding, segmentHeight, expanded, shrinkTapTarget, variant, trackPadding, selectedShadows, slidingThumb,
  ], doc: 'Flutter `SegmentedButton`, or a filter track (`variant: track`).');
}

// --- signature ----------------------------------------------------------------

List<List<Offset>>? _strokesIn(Object? json) => [
      for (final s in readList(json) ?? const [])
        if (readList(s) case final List<Object?> points)
          [
            for (final p in points)
              if (readList(p) case final List<Object?> xy when xy.length >= 2 && readDouble(xy[0]) != null && readDouble(xy[1]) != null)
                Offset(readDouble(xy[0])!, readDouble(xy[1])!),
          ],
    ];
Object? _strokesOut(List<List<Offset>> v) => [
      for (final s in v) [for (final p in s) p.toJson()],
    ];

/// How a signature pad's sign line is stroked.
enum SignLineStyle { solid, dashed }

/// Where a signature pad's mark sits: over the line's start, or before the
/// line (centered on it, the line starting after it).
enum SignMarkPlacement { above, leading }

/// Where a signature pad's placeholder sits.
enum SignaturePlaceholderPosition {
  /// In the middle of the pad.
  center,

  /// Under the sign line, at its start (a form's "Sign here" caption).
  belowLine,
}

/// A signature pad: strokes drawn with a finger or mouse, on a bordered card
/// with a placeholder and a sign line.
abstract final class SignatureProps {
  /// The strokes, each a list of points.
  static const value = PropDef<List<List<Offset>>>('value', ValueCodec(_strokesIn, _strokesOut, PropType.json('List<List<Offset>>')), []);

  /// Points are fractions of the pad's size (0–1) instead of pixels.
  static const normalized = PropDef<bool>('normalized', Codecs.bool, false);
  /// Null: the theme's onSurface (`ControlTheme`), so it reads in light and dark.
  static const inkColor = PropDef<Color?>('inkColor', Codecs.optionalColor, null);
  static const inkWidth = PropDef<double>('inkWidth', Codecs.positive, 2.6);

  /// Strokes drawn as smooth curves through their points; false joins the
  /// points with straight segments.
  static const smooth = PropDef<bool>('smooth', Codecs.bool, true);
  /// Null: the theme's surface (`ControlTheme`), so it reads in light and dark.
  static const backgroundColor = PropDef<Color?>('backgroundColor', Codecs.optionalColor, null);
  /// Null: the theme's outline (`ControlTheme`), so it reads in light and dark.
  static const borderColor = PropDef<Color?>('borderColor', Codecs.optionalColor, null);
  static const borderWidth = PropDef<double>('borderWidth', Codecs.positive, 1.5);
  /// Null: the theme's error (`ControlTheme`), so it reads in light and dark.
  static const errorBorderColor = PropDef<Color?>('errorBorderColor', Codecs.optionalColor, null);
  static const errorBorderWidth = PropDef<double>('errorBorderWidth', Codecs.positive, 2);
  static const borderRadius = PropDef<BorderRadius>('borderRadius', InputCodecs.radius, BorderRadius.circular(4));
  static const placeholder = PropDef<String>('placeholder', Codecs.string, 'SIGN HERE');
  /// Null: the theme's onSurfaceVariant (`ControlTheme`), so it reads in light and dark.
  static const placeholderColor = PropDef<Color?>('placeholderColor', Codecs.optionalColor, null);
  static const placeholderFontSize = PropDef<double>('placeholderFontSize', Codecs.positive, 12);
  /// The placeholder's text style, over [placeholderColor],
  /// [placeholderFontSize], [placeholderFontWeight] and
  /// [placeholderLetterSpacing].
  static const placeholderStyle = PropDef<TextStyle>('placeholderStyle', Codecs.textStyle, TextStyle.empty);

  /// Where the placeholder sits in the pad (when [placeholderPosition] is
  /// center), then moved by [placeholderOffset].
  static const placeholderAlignment = PropDef<Alignment>('placeholderAlignment', Codecs.alignment, Alignment.center);
  static const placeholderOffset = PropDef<Offset>('placeholderOffset', Codecs.offset, Offset.zero);
  static const showSignLine = PropDef<bool>('showSignLine', Codecs.bool, true);
  static const signLineColor = PropDef<Color>('signLineColor', Codecs.color, Color(0xFFA9ADA5));
  static const signLineWidth = PropDef<double>('signLineWidth', Codecs.positive, 1);
  static const signLineStyle = PropDef<SignLineStyle>('signLineStyle', EnumCodec(SignLineStyle.values), SignLineStyle.solid);

  /// A dashed line's dash and gap lengths.
  static const signLineDash = PropDef<double>('signLineDash', Codecs.positive, 6);
  static const signLineGap = PropDef<double>('signLineGap', Codecs.positive, 6);

  /// An older name for [signLineBottom], read when that is unset.
  static const signLineOffset = PropDef<double?>('signLineOffset', Codecs.optionalPositive, null);

  /// The line's distance from the pad's left and right edges.
  static const signLineInset = PropDef<double>('signLineInset', Codecs.positive, 20);

  /// An older name for [signLineMark]: either off hides the mark.
  static const showSignMark = PropDef<bool>('showSignMark', Codecs.bool, true);

  /// The mark as an icon; null is a "×" glyph [signMarkSize] high.
  static const signMarkIcon = PropDef<Json?>('signMarkIcon', Codecs.optionalIcon, null);
  static const signMarkSize = PropDef<double>('signMarkSize', Codecs.positive, 16);

  /// Null is [signLineColor].
  static const signMarkColor = PropDef<Color?>('signMarkColor', Codecs.optionalColor, null);
  static const signMarkPlacement =
      PropDef<SignMarkPlacement>('signMarkPlacement', EnumCodec(SignMarkPlacement.values), SignMarkPlacement.above);

  /// The space between the mark and the line: under it ([SignMarkPlacement.above])
  /// or after it ([SignMarkPlacement.leading]).
  static const signMarkGap = PropDef<double>('signMarkGap', Codecs.positive, 4);

  /// A caption under the line ("SIGN ABOVE THE LINE"), shown with or
  /// without strokes.
  static const caption = PropDef<String>('caption', Codecs.string, '');
  static const captionStyle = PropDef<TextStyle>('captionStyle', Codecs.textStyle, TextStyle.empty);

  /// The space between the line and the caption's top.
  static const captionGap = PropDef<double>('captionGap', Codecs.positive, 8);

  /// The caption's alignment between the line's insets.
  static const captionAlign = PropDef<TextAlign>('captionAlign', EnumCodec(TextAlign.values), TextAlign.start);

  /// The × at the start of the sign line.
  static const signLineMark = PropDef<bool>('signLineMark', Codecs.bool, true);

  /// The sign line's distance from the pad's bottom (null: a quarter of its height).
  static const signLineBottom = PropDef<double?>('signLineBottom', Codecs.optionalPositive, null);

  /// Where the placeholder sits: centered, or under the sign line at its start.
  static const placeholderPosition = PropDef<SignaturePlaceholderPosition>(
      'placeholderPosition', EnumCodec(SignaturePlaceholderPosition.values), SignaturePlaceholderPosition.center);
  static const placeholderFontWeight = PropDef<int>('placeholderFontWeight', IntCodec(min: 100), 600);

  /// Null: 12% of the font size.
  static const placeholderLetterSpacing = PropDef<double?>('placeholderLetterSpacing', Codecs.optionalDouble, null);

  /// Shows the error border.
  static const error = PropDef<bool>('error', Codecs.bool, false);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const readOnly = PropDef<bool>('readOnly', Codecs.bool, false);

  static const spec = WidgetSpec('signature', props: [
    value, normalized, inkColor, inkWidth, backgroundColor, borderColor, borderWidth, errorBorderColor, //
    errorBorderWidth, borderRadius, placeholder, placeholderColor, placeholderFontSize, showSignLine, signLineColor,
    signLineMark, signLineInset, signLineBottom, placeholderPosition, placeholderFontWeight, placeholderLetterSpacing,
    placeholderStyle, placeholderAlignment, placeholderOffset, signLineWidth, signLineStyle, signLineDash,
    signLineGap, signLineOffset, showSignMark, signMarkIcon, signMarkSize, signMarkColor,
    signMarkPlacement, signMarkGap, caption, captionStyle, captionGap, captionAlign, smooth, error, enabled, readOnly,
  ], doc: 'A signature pad.');
}

Object? _same(Object? v) => v;

/// A validator: its expression. The object form older documents saved
/// (`{"type": "required"}`, `{"type": "email"}`, never applied) reads as
/// the expression it named; any other object, as none.
String _validatorIn(Object? json) {
  if (json is String) return json;
  final m = readMap(json);
  if (m == null) return '';
  final message = m['message'] is String ? (m['message'] as String).replaceAll("'", "\\'") : null;
  return switch (m['type']) {
    'required' => "\${= trim(value) == '' ? '${message ?? 'Required.'}' : ''}",
    'email' => "\${= matches(value, '^[^@\\s]+@[^@\\s]+\\.[^@\\s]+\$') ? '' : '${message ?? 'Enter a valid email address.'}'}",
    _ => '',
  };
}
