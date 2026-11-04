// Value types of the input widgets, by Flutter's names and defaults:
// InputDecoration, InputBorder, BorderSide, ButtonSegment, and the icons
// inputs show (prefix/suffix icons, a dropdown's arrow).
import 'package:meta/meta.dart';

import '../json.dart';
import '../props.dart';
import '../values/color.dart';
import '../values/enums.dart';
import '../values/geometry.dart';
import '../values/text.dart';

/// An immutable value made of declared fields, as a widget's props are:
/// decoding is total, encoding sparse (a field at its default is omitted),
/// equality by value. [spec] lists the fields (the editor's panels read it).
@immutable
abstract base class FieldValue {
  const FieldValue(this.fields);

  /// The values that differ from the defaults.
  final Props fields;

  /// The declared fields.
  WidgetSpec get spec;

  T get<T>(PropDef<T> field) => fields.get(field);

  /// Whether every field has its default.
  bool get isEmpty => fields.isEmpty;

  Json toJson() => fields.toJson(spec);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other.runtimeType == runtimeType && other is FieldValue && other.fields == fields;

  @override
  int get hashCode => Object.hash(runtimeType, fields);

  @override
  String toString() => '$runtimeType(${toJson()})';
}

Object? _valueOut(FieldValue? v) => v?.toJson();
Object? _jsonOut(Json j) => j;
Object? _anyOut(Object? v) => v;
Object? _anyIn(Object? v) => v;
Object? _radiusOut(BorderRadius r) => r.toJson();
Object? _constraintsOut(BoxConstraints c) => c.toJson();
Object? _alignmentOut(Alignment a) => a.toJson();

/// Codecs for the inputs' value types.
abstract final class InputCodecs {
  static const json = ValueCodec<Json>(readMap, _jsonOut);

  /// Any JSON value (a dropdown's selected item).
  static const any = ValueCodec<Object?>(_anyIn, _anyOut);
  static const radius = ValueCodec<BorderRadius>(BorderRadius.fromJson, _radiusOut);
  static const constraints = ValueCodec<BoxConstraints>(BoxConstraints.fromJson, _constraintsOut);
  static const alignment = ValueCodec<Alignment>(Alignment.fromJson, _alignmentOut);
  static const strings = ListCodec<String>(Codecs.string);
  static const borderSide = ValueCodec<BorderSide?>(BorderSide.fromJson, _valueOut);
  static const inputBorder = ValueCodec<InputBorder?>(InputBorder.fromJson, _valueOut);
  static const icon = ValueCodec<InputIcon?>(InputIcon.fromJson, _valueOut);
  static const decoration = ValueCodec<InputDecoration>(InputDecoration.fromJson, _valueOut);
  static const segments = ListCodec<ButtonSegment>(ValueCodec(ButtonSegment.fromJson, _valueOut));
}

// --- BorderSide ---------------------------------------------------------------

/// Flutter's `BorderStyle`.
enum BorderStyle { none, solid }

/// Flutter's `BorderSide`.
final class BorderSide extends FieldValue {
  const BorderSide._(super.fields);

  factory BorderSide({
    Color color = Color.black,
    double width = 1,
    BorderStyle style = BorderStyle.solid,
    StrokeAlign strokeAlign = StrokeAlign.inside,
  }) =>
      BorderSide._(Props.empty
          .set(BorderSideFields.color, color)
          .set(BorderSideFields.width, width)
          .set(BorderSideFields.style, style)
          .set(BorderSideFields.strokeAlign, strokeAlign));

  /// Black, 1 px, solid.
  static const BorderSide standard = BorderSide._(Props.empty);

  static BorderSide? fromJson(Object? json) => readMap(json) == null ? null : BorderSide._(Props.fromJson(BorderSideFields.spec, json));

  @override
  WidgetSpec get spec => BorderSideFields.spec;

  Color get color => get(BorderSideFields.color);
  double get width => get(BorderSideFields.width);
  BorderStyle get style => get(BorderSideFields.style);
  StrokeAlign get strokeAlign => get(BorderSideFields.strokeAlign);

  BorderSide set<T>(PropDef<T> field, T value) => BorderSide._(fields.set(field, value));
}

abstract final class BorderSideFields {
  static const color = PropDef<Color>('color', Codecs.color, Color.black);
  static const width = PropDef<double>('width', Codecs.positive, 1);
  static const style = PropDef<BorderStyle>('style', EnumCodec(BorderStyle.values), BorderStyle.solid);
  static const strokeAlign = PropDef<StrokeAlign>('strokeAlign', EnumCodec(StrokeAlign.values), StrokeAlign.inside);
  static const spec = WidgetSpec('BorderSide', props: [color, width, style, strokeAlign], doc: 'Flutter `BorderSide`.');
}

// --- InputBorder --------------------------------------------------------------

/// Which of Flutter's `InputBorder`s.
enum InputBorderType {
  /// `InputBorder.none`.
  none,

  /// `OutlineInputBorder`.
  outline,

  /// `UnderlineInputBorder`.
  underline,
}

/// Flutter's `InputBorder`: an `OutlineInputBorder` (the default here), an
/// `UnderlineInputBorder` or `InputBorder.none`.
final class InputBorder extends FieldValue {
  const InputBorder._(super.fields);

  factory InputBorder({
    InputBorderType type = InputBorderType.outline,
    BorderSide borderSide = BorderSide.standard,
    BorderRadius borderRadius = const BorderRadius.circular(4),
    double gapPadding = 4,
  }) =>
      InputBorder._(Props.empty
          .set(InputBorderFields.type, type)
          .set(InputBorderFields.borderSide, borderSide)
          .set(InputBorderFields.borderRadius, borderRadius)
          .set(InputBorderFields.gapPadding, gapPadding));

  /// `OutlineInputBorder()`.
  static const InputBorder outline = InputBorder._(Props.empty);

  static InputBorder? fromJson(Object? json) =>
      readMap(json) == null ? null : InputBorder._(Props.fromJson(InputBorderFields.spec, json));

  @override
  WidgetSpec get spec => InputBorderFields.spec;

  InputBorderType get type => get(InputBorderFields.type);
  BorderSide get borderSide => get(InputBorderFields.borderSide);

  /// The corners (an underline border rounds its bottom corners only, as
  /// Flutter's does).
  BorderRadius get borderRadius => get(InputBorderFields.borderRadius);

  /// Outline only: the gap around a floating label.
  double get gapPadding => get(InputBorderFields.gapPadding);

  InputBorder set<T>(PropDef<T> field, T value) => InputBorder._(fields.set(field, value));
}

abstract final class InputBorderFields {
  static const type = PropDef<InputBorderType>('type', EnumCodec(InputBorderType.values), InputBorderType.outline);
  static const borderSide = PropDef<BorderSide>('borderSide', _sideCodec, BorderSide.standard);
  static const borderRadius = PropDef<BorderRadius>('borderRadius', InputCodecs.radius, BorderRadius.circular(4));
  static const gapPadding = PropDef<double>('gapPadding', Codecs.positive, 4);
  static const spec =
      WidgetSpec('InputBorder', props: [type, borderSide, borderRadius, gapPadding], doc: 'Flutter `InputBorder`.');
}

const _sideCodec = ValueCodec<BorderSide>(_sideIn, _valueOut);
BorderSide? _sideIn(Object? json) => BorderSide.fromJson(json);

// --- InputIcon ----------------------------------------------------------------

/// An icon an input shows (`Icon`): a glyph as the icon node's `icon` prop
/// (`{"source", "name", "codepoint", ...}` or an image), its size and color,
/// and the actions a tap on it runs.
final class InputIcon extends FieldValue {
  const InputIcon._(super.fields);

  factory InputIcon({Json icon = const {}, double size = 24, Color? color, List<Json> actions = const []}) =>
      InputIcon._(Props.empty
          .set(InputIconFields.icon, icon)
          .set(InputIconFields.size, size)
          .set(InputIconFields.color, color)
          .set(InputIconFields.actions, actions));

  static InputIcon? fromJson(Object? json) => readMap(json) == null ? null : InputIcon._(Props.fromJson(InputIconFields.spec, json));

  @override
  WidgetSpec get spec => InputIconFields.spec;

  /// The glyph, as the icon widget's `icon` prop.
  Json get icon => get(InputIconFields.icon);
  double get size => get(InputIconFields.size);
  Color? get color => get(InputIconFields.color);

  /// Reactions run when the icon is tapped.
  List<Json> get actions => get(InputIconFields.actions);

  InputIcon set<T>(PropDef<T> field, T value) => InputIcon._(fields.set(field, value));
}

List<Json>? _actionsIn(Object? j) => readList(j)?.map(readMap).nonNulls.toList();
Object? _actionsOut(List<Json> v) => v;

abstract final class InputIconFields {
  static const icon = PropDef<Json>('icon', InputCodecs.json, {});
  static const size = PropDef<double>('size', Codecs.positive, 24);
  static const color = PropDef<Color?>('color', Codecs.color, null);
  static const actions = PropDef<List<Json>>('actions', ValueCodec(_actionsIn, _actionsOut), []);
  static const spec = WidgetSpec('Icon', props: [icon, size, color, actions], doc: 'Flutter `Icon`.');
}

// --- InputDecoration ----------------------------------------------------------

/// Flutter's `FloatingLabelBehavior`.
enum FloatingLabelBehavior { never, auto, always }

/// Flutter's `InputDecoration`: a text field's border, label, hint, helper,
/// error, prefix and suffix. Every field has Flutter's default (unset: the
/// theme's).
final class InputDecoration extends FieldValue {
  const InputDecoration._(super.fields);

  /// `InputDecoration()`.
  static const InputDecoration empty = InputDecoration._(Props.empty);

  static InputDecoration fromJson(Object? json) => InputDecoration._(Props.fromJson(InputDecorationFields.spec, json));

  @override
  WidgetSpec get spec => InputDecorationFields.spec;

  InputDecoration set<T>(PropDef<T> field, T value) => InputDecoration._(fields.set(field, value));

  InputIcon? get icon => get(InputDecorationFields.icon);
  String? get labelText => get(InputDecorationFields.labelText);
  TextStyle get labelStyle => get(InputDecorationFields.labelStyle);
  TextStyle get floatingLabelStyle => get(InputDecorationFields.floatingLabelStyle);
  String? get helperText => get(InputDecorationFields.helperText);
  TextStyle get helperStyle => get(InputDecorationFields.helperStyle);
  int? get helperMaxLines => get(InputDecorationFields.helperMaxLines);
  String? get hintText => get(InputDecorationFields.hintText);
  TextStyle get hintStyle => get(InputDecorationFields.hintStyle);
  int? get hintMaxLines => get(InputDecorationFields.hintMaxLines);
  String? get errorText => get(InputDecorationFields.errorText);
  TextStyle get errorStyle => get(InputDecorationFields.errorStyle);
  int? get errorMaxLines => get(InputDecorationFields.errorMaxLines);
  FloatingLabelBehavior? get floatingLabelBehavior => get(InputDecorationFields.floatingLabelBehavior);
  bool get isCollapsed => get(InputDecorationFields.isCollapsed);
  bool? get isDense => get(InputDecorationFields.isDense);
  EdgeInsets? get contentPadding => get(InputDecorationFields.contentPadding);
  InputIcon? get prefixIcon => get(InputDecorationFields.prefixIcon);
  BoxConstraints get prefixIconConstraints => get(InputDecorationFields.prefixIconConstraints);
  String? get prefixText => get(InputDecorationFields.prefixText);
  TextStyle get prefixStyle => get(InputDecorationFields.prefixStyle);
  InputIcon? get suffixIcon => get(InputDecorationFields.suffixIcon);
  BoxConstraints get suffixIconConstraints => get(InputDecorationFields.suffixIconConstraints);
  String? get suffixText => get(InputDecorationFields.suffixText);
  TextStyle get suffixStyle => get(InputDecorationFields.suffixStyle);
  String? get counterText => get(InputDecorationFields.counterText);
  TextStyle get counterStyle => get(InputDecorationFields.counterStyle);
  bool? get filled => get(InputDecorationFields.filled);
  Color? get fillColor => get(InputDecorationFields.fillColor);
  Color? get focusColor => get(InputDecorationFields.focusColor);
  Color? get hoverColor => get(InputDecorationFields.hoverColor);
  InputBorder? get errorBorder => get(InputDecorationFields.errorBorder);
  InputBorder? get focusedBorder => get(InputDecorationFields.focusedBorder);
  InputBorder? get focusedErrorBorder => get(InputDecorationFields.focusedErrorBorder);
  InputBorder? get disabledBorder => get(InputDecorationFields.disabledBorder);
  InputBorder? get enabledBorder => get(InputDecorationFields.enabledBorder);
  InputBorder? get border => get(InputDecorationFields.border);
  bool get enabled => get(InputDecorationFields.enabled);
  String? get semanticCounterText => get(InputDecorationFields.semanticCounterText);
  bool? get alignLabelWithHint => get(InputDecorationFields.alignLabelWithHint);
  BoxConstraints get constraints => get(InputDecorationFields.constraints);
}

abstract final class InputDecorationFields {
  static const icon = PropDef<InputIcon?>('icon', InputCodecs.icon, null);
  static const labelText = PropDef<String?>('labelText', Codecs.string, null);
  static const labelStyle = PropDef<TextStyle>('labelStyle', Codecs.textStyle, TextStyle.empty);
  static const floatingLabelStyle = PropDef<TextStyle>('floatingLabelStyle', Codecs.textStyle, TextStyle.empty);
  static const helperText = PropDef<String?>('helperText', Codecs.string, null);
  static const helperStyle = PropDef<TextStyle>('helperStyle', Codecs.textStyle, TextStyle.empty);
  static const helperMaxLines = PropDef<int?>('helperMaxLines', OptionalIntCodec(), null);
  static const hintText = PropDef<String?>('hintText', Codecs.string, null);
  static const hintStyle = PropDef<TextStyle>('hintStyle', Codecs.textStyle, TextStyle.empty);
  static const hintMaxLines = PropDef<int?>('hintMaxLines', OptionalIntCodec(), null);
  static const errorText = PropDef<String?>('errorText', Codecs.string, null);
  static const errorStyle = PropDef<TextStyle>('errorStyle', Codecs.textStyle, TextStyle.empty);
  static const errorMaxLines = PropDef<int?>('errorMaxLines', OptionalIntCodec(), null);
  static const floatingLabelBehavior =
      PropDef<FloatingLabelBehavior?>('floatingLabelBehavior', EnumCodec(FloatingLabelBehavior.values), null);
  static const isCollapsed = PropDef<bool>('isCollapsed', Codecs.bool, false);
  static const isDense = PropDef<bool?>('isDense', Codecs.bool, null);
  static const contentPadding = PropDef<EdgeInsets?>('contentPadding', Codecs.insets, null);
  static const prefixIcon = PropDef<InputIcon?>('prefixIcon', InputCodecs.icon, null);
  static const prefixIconConstraints =
      PropDef<BoxConstraints>('prefixIconConstraints', InputCodecs.constraints, BoxConstraints.none);
  static const prefixText = PropDef<String?>('prefixText', Codecs.string, null);
  static const prefixStyle = PropDef<TextStyle>('prefixStyle', Codecs.textStyle, TextStyle.empty);
  static const suffixIcon = PropDef<InputIcon?>('suffixIcon', InputCodecs.icon, null);
  static const suffixIconConstraints =
      PropDef<BoxConstraints>('suffixIconConstraints', InputCodecs.constraints, BoxConstraints.none);
  static const suffixText = PropDef<String?>('suffixText', Codecs.string, null);
  static const suffixStyle = PropDef<TextStyle>('suffixStyle', Codecs.textStyle, TextStyle.empty);

  /// Replaces the character counter; `""` hides it.
  static const counterText = PropDef<String?>('counterText', Codecs.string, null);
  static const counterStyle = PropDef<TextStyle>('counterStyle', Codecs.textStyle, TextStyle.empty);
  static const filled = PropDef<bool?>('filled', Codecs.bool, null);
  static const fillColor = PropDef<Color?>('fillColor', Codecs.color, null);
  static const focusColor = PropDef<Color?>('focusColor', Codecs.color, null);
  static const hoverColor = PropDef<Color?>('hoverColor', Codecs.color, null);
  static const errorBorder = PropDef<InputBorder?>('errorBorder', InputCodecs.inputBorder, null);
  static const focusedBorder = PropDef<InputBorder?>('focusedBorder', InputCodecs.inputBorder, null);
  static const focusedErrorBorder = PropDef<InputBorder?>('focusedErrorBorder', InputCodecs.inputBorder, null);
  static const disabledBorder = PropDef<InputBorder?>('disabledBorder', InputCodecs.inputBorder, null);
  static const enabledBorder = PropDef<InputBorder?>('enabledBorder', InputCodecs.inputBorder, null);
  static const border = PropDef<InputBorder?>('border', InputCodecs.inputBorder, null);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const semanticCounterText = PropDef<String?>('semanticCounterText', Codecs.string, null);
  static const alignLabelWithHint = PropDef<bool?>('alignLabelWithHint', Codecs.bool, null);
  static const constraints = PropDef<BoxConstraints>('constraints', InputCodecs.constraints, BoxConstraints.none);

  static const spec = WidgetSpec('InputDecoration', props: [
    icon, labelText, labelStyle, floatingLabelStyle, helperText, helperStyle, helperMaxLines, hintText, hintStyle, //
    hintMaxLines, errorText, errorStyle, errorMaxLines, floatingLabelBehavior, isCollapsed, isDense, contentPadding,
    prefixIcon, prefixIconConstraints, prefixText, prefixStyle, suffixIcon, suffixIconConstraints, suffixText,
    suffixStyle, counterText, counterStyle, filled, fillColor, focusColor, hoverColor, errorBorder, focusedBorder,
    focusedErrorBorder, disabledBorder, enabledBorder, border, enabled, semanticCounterText, alignLabelWithHint,
    constraints,
  ], doc: 'Flutter `InputDecoration`.');
}

// --- ButtonSegment ------------------------------------------------------------

/// Flutter's `ButtonSegment<String>`: one segment of a segmented button.
final class ButtonSegment extends FieldValue {
  const ButtonSegment._(super.fields);

  factory ButtonSegment({required String value, String label = '', InputIcon? icon, String? tooltip, bool enabled = true}) =>
      ButtonSegment._(Props.empty
          .set(ButtonSegmentFields.value, value)
          .set(ButtonSegmentFields.label, label)
          .set(ButtonSegmentFields.icon, icon)
          .set(ButtonSegmentFields.tooltip, tooltip)
          .set(ButtonSegmentFields.enabled, enabled));

  static ButtonSegment? fromJson(Object? json) =>
      readMap(json) == null ? null : ButtonSegment._(Props.fromJson(ButtonSegmentFields.spec, json));

  @override
  WidgetSpec get spec => ButtonSegmentFields.spec;

  String get value => get(ButtonSegmentFields.value);
  String get label => get(ButtonSegmentFields.label);
  InputIcon? get icon => get(ButtonSegmentFields.icon);
  String? get tooltip => get(ButtonSegmentFields.tooltip);
  bool get enabled => get(ButtonSegmentFields.enabled);

  ButtonSegment set<T>(PropDef<T> field, T value) => ButtonSegment._(fields.set(field, value));
}

abstract final class ButtonSegmentFields {
  static const value = PropDef<String>('value', Codecs.string, '');
  static const label = PropDef<String>('label', Codecs.string, '');
  static const icon = PropDef<InputIcon?>('icon', InputCodecs.icon, null);
  static const tooltip = PropDef<String?>('tooltip', Codecs.string, null);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const spec =
      WidgetSpec('ButtonSegment', props: [value, label, icon, tooltip, enabled], doc: 'Flutter `ButtonSegment`.');
}
